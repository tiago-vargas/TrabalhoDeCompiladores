%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "lexer.h"

	void yyerror(const char *s);
	extern FILE *yyin;

	char line[4096];
	char *generated_code; // Global variable to store the generated code
%}

%union {
	int num;
	char *str;
}

%debug

/* Define Token Precedence */
%left OP_REL    /* Relational operators (==, <, >, <=, >=) */
%left OP_ARIT   /* Arithmetic operators (+, -, *, /) */

/* Token Definitions */
%token CONFIG REPITA FIM VAR INTEIRO BOOLEANO TEXTO SE ENTAO SENAO ENQUANTO
%token CONFIGURAR CONFIGURAR_PWM AJUSTAR_PWM ESPERAR CONECTAR_WIFI LIGAR DESLIGAR
%token ESCREVER_SERIAL LER_SERIAL ENVIAR_HTTP CONFIGURAR_SERIAL
%token LER_DIGITAL LER_ANALOGICO
%token <str> ID STRING
%token <num> NUM
%token COMO SAIDA ENTRADA COM VALOR FREQUENCIA RESOLUCAO
%token <str> OP_REL OP_ARIT

%type <str> goal programa declaracao declaracoes config bloco_repita expressao comandos tipo lista_ids configuracao controle acao atribuicao io_comunicacao comando

%start goal

%%

goal
	: programa {
		generated_code = $programa; // Store the generated code
	}
	;

programa
	: declaracoes config bloco_repita {
		asprintf(
			&$$,
			"#include <Arduino.h>\n"
			"#include <WiFi.h>\n"
			"\n"
			"%s"
			"\n"
			"%s"
			"\n"
			"%s",
			$declaracoes, $config, $bloco_repita
		);
	}
	;

declaracoes
	: declaracoes declaracao {
		char *temp;
		asprintf(&temp, "%s%s", $1, $2);
		$$ = temp;
	}
	| {
		$$ = strdup("");
	}
	;

declaracao
	: VAR tipo ':' lista_ids ';'   {
		// $$ = ";\n";
		asprintf(&$$, "%s %s;\n", $tipo, $lista_ids);
	}
	;

tipo
	: INTEIRO {
		// $$ = "int";
		asprintf(&$$, "int");
	}
	| BOOLEANO {
		// $$ = "bool";
		asprintf(&$$, "bool");
	}
	| TEXTO {
		// $$ = "char*";
		asprintf(&$$, "char*");
	}
	;

lista_ids
	: ID {
		asprintf(&$$, "%s", $ID);
	}
	| lista_ids ',' ID {
		asprintf(&$$, "%s, %s", $1, $ID);
	}
	;

config
	: CONFIG comandos FIM  {
		asprintf(&$$, "void setup() {\n%s}\n", $comandos);
	}
	;

bloco_repita
	: REPITA comandos FIM {
		asprintf(&$$, "void loop() {\n%s}\n", $comandos);
	}
	;

comandos
	: comandos comando {
		char *temp;
		asprintf(&temp, "%s%s", $1, $comando);
		$$ = temp;
	}
	| {
		$$ = strdup("");
	}
	;

comando
	: atribuicao
	| configuracao
	| controle
	| acao
	| io_comunicacao
	;

atribuicao
	: ID '=' expressao ';' {
		asprintf(&$$, "%s = %s;\n", $ID, $expressao);
	}
	;

/* Expressions (Numbers, Strings, IDs, Comparisons, Arithmetic) */
expressao
	: NUM       { asprintf(&$$, "%d", $NUM); }
	| STRING    { asprintf(&$$, "%s", $STRING); }
	| ID        { asprintf(&$$, "%s", $ID); }
	| expressao OP_REL expressao { asprintf(&$$, "%s %s %s", $1, $OP_REL, $3); }
	| expressao OP_ARIT expressao { asprintf(&$$, "%s %s %s", $1, $OP_ARIT, $3); }
	;

/* GPIO and PWM Configuration */
configuracao
	: CONFIGURAR ID COMO SAIDA ';' {
		asprintf(&$$, "pinMode(%s, OUTPUT);\n", $ID);
	}
	| CONFIGURAR ID COMO ENTRADA ';' {
		asprintf(&$$, "pinMode(%s, INPUT);\n", $ID);
	}
	| CONFIGURAR_PWM ID COM FREQUENCIA NUM RESOLUCAO NUM ';' {
		asprintf(&$$, "ledcSetup(%s, %d, %d);\n", $ID, $5, $7);
	}
	| CONECTAR_WIFI ID ID ';' {
		asprintf(&$$, "WiFi.begin(%s, %s);\n", $2, $3);
	}
	| CONFIGURAR_SERIAL NUM ';' {
		asprintf(&$$, "Serial.begin(%d);\n", $NUM);
	}
	;

/* Control Structures */
controle
	: SE expressao ENTAO comandos SENAO comandos FIM {
		asprintf(&$$, "if (%s) {\n%s} else {\n%s}\n", $expressao, $4, $6);
	}
	| SE expressao ENTAO comandos FIM {
		asprintf(&$$, "if (%s) {\n%s}\n", $expressao, $comandos);
	}
	| ENQUANTO comandos FIM {
		asprintf(&$$, "while (true) {\n%s}\n", $comandos);
	}
	;

/* GPIO and PWM Actions */
acao
	: AJUSTAR_PWM ID COM VALOR expressao ';' {
		// asprintf(&$$, "analogWrite(%s, %s);\n", $ID, $expressao);
		asprintf(&$$, "ledcWrite(%s, %s);\n", $ID, $expressao);
	}
	| ESPERAR NUM ';' {
		asprintf(&$$, "delay(%d);\n", $NUM);
	}
	| LIGAR ID ';' {
		asprintf(&$$, "digitalWrite(%s, HIGH);\n", $ID);
	}
	| DESLIGAR ID ';' {
		asprintf(&$$, "digitalWrite(%s, LOW);\n", $ID);
	}
	;

/* I/O and Communication */
io_comunicacao
	: ESCREVER_SERIAL STRING ';' {
		asprintf(&$$, "Serial.println(%s);\n", $STRING);
	}
	| ID '=' LER_SERIAL ';' {
		asprintf(&$$, "%s = Serial.read();\n", $ID);
	}
	| ID '=' LER_DIGITAL ID ';' {
		asprintf(&$$, "%s = digitalRead(%s);\n", $1, $4);
	}
	| ID '=' LER_ANALOGICO ID ';' {
		asprintf(&$$, "%s = analogRead(%s);\n", $1, $4);
	}
	| ENVIAR_HTTP STRING STRING ';'                                                                         {}
	;

%%

int main(int argc, char **argv)
{
	if (argc > 1)
	{
		yyin = fopen(argv[1], "r");
		if (NULL == yyin)
		{
			printf("syntax: %s filename\n", argv[0]);
			return 1;
		}
	}
	// yydebug = 1;
	yyparse(); // Calls yylex() for tokens.
	if (generated_code)
	{
		printf("%s", generated_code); // Print the generated code
	}
	return 0;
}

/* Error Handling */
void yyerror(const char *s)
{
	fprintf(stderr, "Erro: %s\n", s);
}

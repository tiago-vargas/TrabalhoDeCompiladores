%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "lexer.h"

	void yyerror(const char *s);
	extern FILE *yyin;

	char line[4096];
	char *generated_code = NULL; // Global variable to store the generated code
%}

%union {
	int num;
	char *str;
}

%define parse.trace
%debug

/* Define Token Precedence */
%left OP_REL /* Relational operators (<, >, <=, >=, ==, !=) */
%left OP_ARIT_1 /* Arithmetic operators (+, -) */
%left OP_ARIT_2 /* Arithmetic operators (*, /) */

/* Token Definitions */
%token CONFIG REPITA FIM VAR INTEIRO BOOLEANO TEXTO SE ENTAO SENAO ENQUANTO
%token CONFIGURAR CONFIGURAR_PWM AJUSTAR_PWM ESPERAR CONECTAR_WIFI LIGAR DESLIGAR
%token ESCREVER_SERIAL LER_SERIAL ENVIAR_HTTP CONFIGURAR_SERIAL
%token LER_DIGITAL LER_ANALOGICO
%token <str> ID STRING
%token <num> NUM
%token COMO SAIDA ENTRADA COM VALOR FREQUENCIA RESOLUCAO
%token EQ LE GE NE
%token <str> OP_REL OP_ARIT_1 OP_ARIT_2

%type <str> goal programa declaracao declaracoes config bloco_repita
%type <str> expressao comandos comando tipo lista_ids configuracao controle acao
%type <str> atribuicao io_entrada io_saida

%printer { fprintf(yyo, "`%s`", $$); } <str>

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
		asprintf(&$$, "%s %s;\n", $tipo, $lista_ids);
	}
	;

tipo
	: INTEIRO {
		$$ = strdup("int");
	}
	| BOOLEANO {
		$$ = strdup("bool");
	}
	| TEXTO {
		$$ = strdup("char*");
	}
	;

lista_ids
	: ID {
		$$ = strdup($ID);
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
	| io_saida
	;

atribuicao
	: ID '=' expressao ';' {
		asprintf(&$$, "%s = %s;\n", $ID, $expressao);
	}
	;

expressao
	: NUM       { asprintf(&$$, "%d", $NUM); }
	| STRING    { $$ = strdup($STRING); }
	| ID        { $$ = strdup($ID); }
	| expressao OP_REL expressao { asprintf(&$$, "%s %s %s", $1, $OP_REL, $3); }
	| expressao OP_ARIT_1 expressao { asprintf(&$$, "%s %s %s", $1, $OP_ARIT_1, $3); }
	| expressao OP_ARIT_2 expressao { asprintf(&$$, "%s %s %s", $1, $OP_ARIT_2, $3); }
	| '(' expressao ')' { asprintf(&$$, "(%s)", $2); }
	| io_entrada
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

/* I/O Input */
io_entrada
	: LER_DIGITAL ID {
		asprintf(&$$, "digitalRead(%s)", $ID);
	}
	| LER_ANALOGICO ID {
		asprintf(&$$, "analogRead(%s)", $ID);
	}
	| LER_SERIAL {
		asprintf(&$$, "Serial.read()");
	}
	;

/* I/O Output */
io_saida
	: ESCREVER_SERIAL STRING ';' {
		asprintf(&$$, "Serial.println(%s);\n", $STRING);
	}
	| ENVIAR_HTTP STRING STRING ';' {
		asprintf(&$$, "http.begin(%s);\nhttp.addHeader(\"Content-Type\", \"application/x-www-form-urlencoded\");\nhttp.POST(%s);\nhttp.end();\n", $2, $3);
	}
	| ENVIAR_HTTP STRING ID ';' {
		asprintf(&$$, "http.begin(%s);\nhttp.addHeader(\"Content-Type\", \"application/x-www-form-urlencoded\");\nhttp.POST(%s);\nhttp.end();\n", $STRING, $ID);
	}
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
	yydebug = 1;
	yyparse(); // Calls yylex() for tokens.
	if (NULL != generated_code)
	{
		printf("%s", generated_code); // Print the generated code
	}
	return 0;
}

void yyerror(const char* message)
{
	fprintf(stderr, "[ERROR] %d: %s\n", yylineno, message);
}

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "lexer.h"

	void yyerror(const char *s);

	extern FILE *yyin;
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
%token CONFIGURAR CONFIGURAR_PWM AJUSTAR_PWM ESPERAR CONECTARWIFI LIGAR DESLIGAR
%token ESCREVER_SERIAL LER_SERIAL ENVIAR_HTTP CONFIGURAR_SERIAL
%token LER_DIGITAL LER_ANALOGICO
%token <str> ID STRING
%token <num> NUM
%token COMO SAIDA ENTRADA COM VALOR FREQUENCIA RESOLUCAO
%token OP_REL OP_ARIT

%start programa

%%

programa
	: declaracoes config bloco_repita
	;

declaracoes
	: declaracoes declaracao
	|
	;

declaracao
	: VAR tipo ':' lista_ids ';'
	;

tipo
	: INTEIRO { printf("int"); }
	| BOOLEANO { printf("bool"); }
	| TEXTO { printf("char*"); }
	;

lista_ids
	: ID { printf("%s", $1); }
	| lista_ids ',' ID
	;

config
	: CONFIG comandos FIM
	;

bloco_repita
	: REPITA comandos FIM
	;

comandos
	: comandos comando
	|
	;

comando
	: atribuicao
	| configuracao
	| controle
	| acao
	| io_comunicacao
	;

atribuicao
	: ID '=' expressao ';'
	;

/* Expressions (Numbers, Strings, IDs, Comparisons, Arithmetic) */
expressao
	: NUM { printf("%d", $1); }
	| STRING { printf("\"%s\"", $1); }
	| ID { printf("%s", $1); }
	| expressao OP_REL expressao
	| expressao OP_ARIT expressao
	;

/* GPIO and PWM Configuration */
configuracao
	: CONFIGURAR ID COMO SAIDA ';'   { printf("pinMode(%s, OUTPUT);\n", $2); }
	| CONFIGURAR ID COMO ENTRADA ';' { printf("pinMode(%s, INPUT);\n", $2); }
	| CONFIGURAR_PWM ID COM FREQUENCIA NUM RESOLUCAO NUM ';' { printf("analogWrite(%s, %d);\n", $2, $5); }
	| CONECTARWIFI ID ID ';'         { printf("WiFi.begin(%s, %s);\n", $2, $3); }
	| CONFIGURAR_SERIAL NUM ';'      { printf("Serial.begin(%d);\n", $2); }
	;

/* Control Structures */
controle
	: SE expressao ENTAO comandos SENAO comandos FIM
	| SE expressao ENTAO comandos FIM
	| ENQUANTO comandos FIM
	;

/* GPIO and PWM Actions */
acao
	: AJUSTAR_PWM ID COM VALOR expressao ';'
	| ESPERAR NUM ';'
	| LIGAR ID ';'
	| DESLIGAR ID ';'
	;

/* I/O and Communication */
io_comunicacao
	: ESCREVER_SERIAL STRING ';'
	| ID '=' LER_SERIAL ';' {
		printf("%s = Serial.read();", $1);
	}
	| ID '=' LER_DIGITAL ID ';' {
		printf("%s = digitalRead(%s);", $1, $4);
	}
	| ID '=' LER_ANALOGICO ID ';'
	| ENVIAR_HTTP STRING STRING ';'
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
	return 0;
}

/* Error Handling */
void yyerror(const char *s)
{
	fprintf(stderr, "Erro: %s\n", s);
}

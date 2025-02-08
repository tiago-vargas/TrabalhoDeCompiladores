%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "src/lexer.h"

	void yyerror(const char *s);
%}

/* Define Token Precedence */
%left OP_REL    /* Relational operators (==, <, >, <=, >=) */
%left OP_ARIT   /* Arithmetic operators (+, -, *, /) */

/* Token Definitions */
%token CONFIG REPITA FIM VAR INTEIRO BOOLEANO TEXTO SE ENTAO SENAO ENQUANTO
%token CONFIGURAR CONFIGURAR_PWM AJUSTAR_PWM ESPERAR CONECTARWIFI LIGAR DESLIGAR
%token ESCREVER_SERIAL LER_SERIAL ENVIAR_HTTP CONFIGURAR_SERIAL
%token LER_DIGITAL LER_ANALOGICO
%token ID NUM STRING
%token IGUAL COM_VALOR COMO SAIDA ENTRADA FREQUENCIA RESOLUCAO
%token OP_REL OP_ARIT

%%

/* Full Program Structure */
programa: declaracoes config bloco_repita ;

/* Variable Declarations */
declaracoes:
	declaracoes declaracao
	|
	;

declaracao: VAR tipo ':' lista_ids ';' ;

tipo:
	INTEIRO
	| BOOLEANO
	| TEXTO
	;

lista_ids:
	ID
	| lista_ids ',' ID
	;

/* Setup (config) block */
config: CONFIG comandos FIM ;

/* Main loop block */
bloco_repita: REPITA comandos FIM ;

/* List of Statements */
comandos:
	comandos comando
	|
	;

/* Statements */
comando:
	atribuicao
	| configuracao
	| controle
	| acao
	| io_comunicacao
	;

/* Variable Assignments */
atribuicao: ID IGUAL expressao ';' ;

/* Expressions (Numbers, Strings, IDs, Comparisons, Arithmetic) */
expressao:
	NUM
	| STRING
	| ID
	| expressao OP_REL expressao
	| expressao OP_ARIT expressao
	;

/* GPIO and PWM Configuration */
configuracao:
	CONFIGURAR ID COMO SAIDA ';'
	| CONFIGURAR ID COMO ENTRADA ';'
	| CONFIGURAR_PWM ID COM_VALOR NUM FREQUENCIA NUM RESOLUCAO NUM ';'
	| CONECTARWIFI ID ID ';'
	| CONFIGURAR_SERIAL NUM ';'
	;

/* Control Structures */
controle:
	SE expressao ENTAO comandos SENAO comandos FIM
	| SE expressao ENTAO comandos FIM
	| ENQUANTO comandos FIM
	;

/* GPIO and PWM Actions */
acao:
	AJUSTAR_PWM ID COM_VALOR expressao ';'
	| ESPERAR NUM ';'
	| LIGAR ID ';'
	| DESLIGAR ID ';'
	;

/* I/O and Communication */
io_comunicacao:
	ESCREVER_SERIAL STRING ';'
	| ID IGUAL LER_SERIAL ';'
	| ID IGUAL LER_DIGITAL ID ';'
	| ID IGUAL LER_ANALOGICO ID ';'
	| ENVIAR_HTTP STRING STRING ';'
	;

%%

int main(int argc, char **argv) {
	if (argc > 1) {
		yyin = fopen(argv[1], "r");
		if (yyin == NULL) {
			printf("syntax: %s filename\n", argv[0]);
		}
	}
	yyparse(); // Calls yylex() for tokens.
	return 0;
}

/* Error Handling */
void yyerror(const char *s) {
	fprintf(stderr, "Erro: %s\n", s);
}

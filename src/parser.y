%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "lexer.h"

	void yyerror(const char *s);
%}

%token CONFIG REPITA FIM VAR INTEIRO BOOLEANO TEXTO SE ENTAO SENAO ENQUANTO
%token CONFIGURAR CONFIGURAR_PWM AJUSTAR_PWM ESPERAR CONECTARWIFI LIGAR DESLIGAR
%token ID NUM STRING
%token IGUAL COM_VALOR COMO SAIDA FREQUENCIA RESOLUCAO

%%

programa: declaracoes config bloco_repita ;

declaracoes: /* vazio */
	| declaracoes declaracao
	;

declaracao: VAR tipo ':' lista_ids ';' ;

tipo:
	| INTEIRO
	| BOOLEANO
	| TEXTO
	;

lista_ids:
	| ID
	| lista_ids ',' ID
	;

config: CONFIG comandos FIM ;

bloco_repita: REPITA comandos FIM ;

comandos: /* vazio */
	| comandos comando
	;

comando:
	| atribuicao
	| configuracao
	| controle
	| acao
	;

atribuicao: ID IGUAL expressao ';' ;

expressao:
	| NUM
	| STRING
	| ID
	;

configuracao:
	| CONFIGURAR ID COMO SAIDA ';'
	| CONFIGURAR_PWM ID COM_VALOR NUM FREQUENCIA NUM RESOLUCAO NUM ';'
	| CONECTARWIFI ID ID ';'
	;

controle:
	| SE expressao ENTAO comandos SENAO comandos FIM
	| ENQUANTO comandos FIM
	;

acao:
	| AJUSTAR_PWM ID COM_VALOR expressao ';'
	| ESPERAR NUM ';'
	| LIGAR ID ';'
	| DESLIGAR ID ';'
	;

%%

void yyerror(const char *s) {
	fprintf(stderr, "Erro: %s\n", s);
}

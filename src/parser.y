%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "src/lexer.h"

	void yyerror(const char *s);
	extern FILE *yyin;
	extern int yylineno;
	extern char *yytext;
%}

/* Token Definitions */
%token CONFIG REPITA FIM VAR INTEIRO BOOLEANO TEXTO SE ENTAO SENAO ENQUANTO
%token CONFIGURAR CONFIGURAR_PWM AJUSTAR_PWM ESPERAR CONECTARWIFI LIGAR DESLIGAR
%token ESCREVER_SERIAL LER_SERIAL ENVIAR_HTTP CONFIGURAR_SERIAL
%token LER_DIGITAL LER_ANALOGICO
%token ID NUM STRING
%token IGUAL COM_VALOR COMO SAIDA ENTRADA COM_FREQUENCIA RESOLUCAO
%token OP_REL OP_ARIT

/* Define Token Precedence */
%left OP_REL    /* Relational operators (==, <, >, <=, >=) */
%left OP_ARIT   /* Arithmetic operators (+, -, *, /) */

%start programa

%%

/* Full Program Structure */
programa:
	declaracoes config bloco_repita {
		// printf("#include <Arduino.h>\n");
		// printf("#include <WiFi.h>\n");
		$$ = "#include <Arduino.h>\n#include <WiFi.h>\n";
	}
	;

/* Variable Declarations */
declaracoes:
	declaracoes declaracao
	|
	;

declaracao: VAR tipo ':' lista_ids ';' ;

tipo:
	INTEIRO    { $$ = "int"; }
	| BOOLEANO { $$ = "bool"; }
	| TEXTO    { $$ = "char *"; }
	;

lista_ids:
	ID         { $$ = $1; }
	| lista_ids ',' ID { /* $$ = sprintf("%s, %s", $1, $3); */ }
	;

/* Setup (config) block */
config: CONFIG comandos FIM

/* Main loop block */
bloco_repita: REPITA comandos FIM

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
atribuicao: ID IGUAL expressao ';' { asprintf(&$$, "%s = ;\n", $1); } ;

/* Expressions (Numbers, Strings, IDs, Comparisons, Arithmetic) */
expressao:
	NUM { $$ = $1; }
	| STRING { $$ = $1; }
	| ID { $$ = $1; }
	| expressao OP_REL expressao { $$ = $1; }
	| expressao OP_ARIT expressao { $$ = $1; }
	;

/* GPIO and PWM Configuration */
configuracao:
	CONFIGURAR ID COMO SAIDA ';' { printf("pinMode(%s, OUTPUT);\n", $2); }
	| CONFIGURAR ID COMO ENTRADA ';' { printf("pinMode(%s, INPUT);\n", $2); }
	| CONFIGURAR_PWM ID COM_FREQUENCIA NUM RESOLUCAO NUM ';' {
		printf("ledcSetup(%s, %d, %d);\n", $2, $4, $6);
		printf("ledcAttachPin(%s, %s);\n", $2, $2);
	}
	| CONECTARWIFI ID ID ';' { printf("WiFi.begin(%s.c_str(), %s.c_str());\nwhile (WiFi.status() != WL_CONNECTED) {\ndelay(500);\nSerial.println(\"Conectando ao WiFi...\");\n}\nSerial.println(\"Conectado ao WiFi!\");\n", $2, $3); }
	| CONFIGURAR_SERIAL NUM ';' { printf("Serial.begin(%d);\n", $2); }
	;

/* Control Structures */
controle:
	SE expressao ENTAO comandos SENAO comandos FIM
	| SE expressao ENTAO comandos FIM
	| ENQUANTO comandos FIM
	;

/* GPIO and PWM Actions */
acao:
	AJUSTAR_PWM ID COM_VALOR expressao ';' { printf("ledcWrite(%s, %s);\n", $2, $4); }
	| ESPERAR NUM ';' { printf("delay(%d);\n", $2); }
	| LIGAR ID ';'    { printf("digitalWrite(%s, HIGH);\n", $2); }
	| DESLIGAR ID ';' { printf("digitalWrite(%s, LOW);\n", $2); }
	;

/* I/O and Communication */
io_comunicacao:
	ESCREVER_SERIAL STRING ';' { printf("Serial.println(%s);\n", $1); }
	| ID IGUAL LER_SERIAL ';' { printf("%s = Serial.readString();\n", $1); }
	| ID IGUAL LER_DIGITAL ID ';' { printf("%s = digitalRead(%s);\n", $1, $4); }
	| ID IGUAL LER_ANALOGICO ID ';' { printf("%s = analogRead(%s);\n", $1, $4); }
	| ENVIAR_HTTP STRING STRING ';' { printf("/* HTTP request code here */\n"); }
	;

%%

int main(int argc, char **argv) {
	if (argc > 1) {
		yyin = fopen(argv[1], "r");
		if (NULL == yyin) {
			printf("syntax: %s filename\n", argv[0]);
			return 1;
		}
	}
	// yydebug = 1;
	yyparse(); // Calls yylex() for tokens.
	return 0;
}

/* Error Handling */
void yyerror(const char *s) {
	fprintf(stderr, "Error: %s at line %d, near '%s'\n", s, yylineno, yytext);
}

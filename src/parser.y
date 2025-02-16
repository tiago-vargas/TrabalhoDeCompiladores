%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "lexer.h"
	#include "ast.h"

	void yyerror(const char *s);
	extern FILE *yyin;

	char *generated_code = NULL;
	struct node *root;
%}

%union {
	int num;
	char *str;
	struct node *node;
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
%token <str> NUM
%token COMO SAIDA ENTRADA COM VALOR FREQUENCIA RESOLUCAO
%token EQ LE GE NE
%token <str> OP_REL OP_ARIT_1 OP_ARIT_2

%type <node> goal programa declaracao declaracoes config bloco_repita
%type <node> expressao comandos comando tipo lista_ids configuracao controle acao
%type <node> atribuicao io_entrada io_saida

%printer { fprintf(yyo, "`%s`", $$->text); } <node>

%start goal

%%

goal
	: programa {
		$$ = node_new("goal", $programa->text);
		node_add_child($$, $programa);
		root = $$;
		generated_code = $programa->text;
	}
	;

programa
	: declaracoes config bloco_repita {
		char *text;
		asprintf(
			&text,
			"#include <Arduino.h>\n"
			"#include <HTTPClient.h>"
			"#include <WiFi.h>\n"
			"\n"
			"%s"
			"\n"
			"%s"
			"\n"
			"%s",
			 $declaracoes->text, $config->text, $bloco_repita->text
		);
		$$ = node_new("programa", text);
		node_add_child($$, $declaracoes);
		node_add_child($$, $config);
		node_add_child($$, $bloco_repita);
	}
	;

declaracoes
	: declaracoes declaracao {
		char *text;
		asprintf(&text, "%s%s", $1->text, $2->text);
		$$ = node_new("declaracoes", text);
		node_add_child($$, $1);
		node_add_child($$, $2);
	}
	| {
		$$ = node_new("declaracoes", strdup(""));
	}
	;

declaracao
	: VAR tipo ':' lista_ids ';' {
		char *text;
		asprintf(&text, "%s %s;\n", $tipo->text, $lista_ids->text);
		$$ = node_new("declaracao", text);
		node_add_child($$, terminal_node("VAR"));
		node_add_child($$, $tipo);
		node_add_child($$, terminal_node(":"));
		node_add_child($$, $lista_ids);
		node_add_child($$, terminal_node(";"));
	}
	;

tipo
	: INTEIRO {
		$$ = node_new("tipo", strdup("int"));
		node_add_child($$, terminal_node("INTEIRO"));
	}
	| BOOLEANO {
		$$ = node_new("tipo", strdup("bool"));
		node_add_child($$, terminal_node("BOOLEANO"));
	}
	| TEXTO {
		$$ = node_new("tipo", strdup("char*"));
		node_add_child($$, terminal_node("TEXTO"));
	}
	;

lista_ids
	: ID {
		$$ = node_new("lista_ids", strdup($ID));
		node_add_child($$, terminal_node($ID));
	}
	| lista_ids ',' ID {
		char *text;
		asprintf(&text, "%s, %s", $1->text, $ID);
		$$ = node_new("lista_ids", text);
		node_add_child($$, $1);
		node_add_child($$, terminal_node(","));
		node_add_child($$, terminal_node($ID));
	}
	;

config
	: CONFIG comandos FIM {
		char *text;
		asprintf(&text, "void setup() {\n%s}\n", $comandos->text);
		$$ = node_new("config", text);
		node_add_child($$, terminal_node("CONFIG"));
		node_add_child($$, $comandos);
		node_add_child($$, terminal_node("FIM"));
	}
	;

bloco_repita
	: REPITA comandos FIM {
		char *text;
		asprintf(&text, "void loop() {\n%s}\n", $comandos->text);
		$$ = node_new("bloco_repita", text);
		node_add_child($$, terminal_node("REPITA"));
		node_add_child($$, $comandos);
		node_add_child($$, terminal_node("FIM"));
	}
	;

comandos
	: comandos comando {
		char *text;
		asprintf(&text, "%s%s", $1->text, $comando->text);
		$$ = node_new("comandos", text);
		node_add_child($$, $1);
		node_add_child($$, $comando);
	}
	| {
		$$ = node_new("comandos", strdup(""));
	}
	;

comando
	: atribuicao {
		$$ = node_new("comando", $atribuicao->text);
		node_add_child($$, $atribuicao);
	}
	| configuracao {
		$$ = node_new("comando", $configuracao->text);
		node_add_child($$, $configuracao);
	}
	| controle {
		$$ = node_new("comando", $controle->text);
		node_add_child($$, $controle);
	}
	| acao {
		$$ = node_new("comando", $acao->text);
		node_add_child($$, $acao);
	}
	| io_saida {
		$$ = node_new("comando", $io_saida->text);
		node_add_child($$, $io_saida);
	}
	;

atribuicao
	: ID '=' expressao ';' {
		char *text;
		asprintf(&text, "%s = %s;\n", $ID, $expressao->text);
		$$ = node_new("atribuicao", text);
		node_add_child($$, terminal_node($ID));
		node_add_child($$, terminal_node("="));
		node_add_child($$, $expressao);
		node_add_child($$, terminal_node(";"));
	}
	;

expressao
	: NUM {
		char *text;
		asprintf(&text, "%s", $NUM);
		$$ = node_new("expressao", text);
		node_add_child($$, terminal_node(text));
	}
	| STRING {
		$$ = node_new("expressao", strdup($STRING));
		node_add_child($$, terminal_node($STRING));
	}
	| ID {
		$$ = node_new("expressao", strdup($ID));
		node_add_child($$, terminal_node($ID));
	}
	| expressao OP_REL expressao {
		char *text;
		asprintf(&text, "%s %s %s", $1->text, $OP_REL, $3->text);
		$$ = node_new("expressao", text);
		node_add_child($$, $1);
		node_add_child($$, terminal_node($OP_REL));
		node_add_child($$, $3);
	}
	| expressao OP_ARIT_1 expressao {
		char *text;
		asprintf(&text, "%s %s %s", $1->text, $OP_ARIT_1, $3->text);
		$$ = node_new("expressao", text);
		node_add_child($$, $1);
		node_add_child($$, terminal_node($OP_ARIT_1));
		node_add_child($$, $3);
	}
	| expressao OP_ARIT_2 expressao {
		char *text;
		asprintf(&text, "%s %s %s", $1->text, $OP_ARIT_2, $3->text);
		$$ = node_new("expressao", text);
		node_add_child($$, $1);
		node_add_child($$, terminal_node($OP_ARIT_2));
		node_add_child($$, $3);
	}
	| '(' expressao ')' {
		char *text;
		asprintf(&text, "(%s)", $2->text);
		$$ = node_new("expressao", text);
		node_add_child($$, terminal_node("("));
		node_add_child($$, $2);
		node_add_child($$, terminal_node(")"));
	}
	| io_entrada {
		$$ = node_new("expressao", $io_entrada->text);
		node_add_child($$, $io_entrada);
	}
	;

/* GPIO and PWM Configuration */
configuracao
	: CONFIGURAR ID COMO SAIDA ';' {
		char *text;
		asprintf(&text, "pinMode(%s, OUTPUT);\n", $ID);
		$$ = node_new("configuracao", text);
		node_add_child($$, terminal_node("CONFIGURAR"));
		node_add_child($$, terminal_node($ID));
		node_add_child($$, terminal_node("COMO"));
		node_add_child($$, terminal_node("SAIDA"));
		node_add_child($$, terminal_node(";"));
	}
	| CONFIGURAR ID COMO ENTRADA ';' {
		char *text;
		asprintf(&text, "pinMode(%s, INPUT);\n", $ID);
		$$ = node_new("configuracao", text);
		node_add_child($$, terminal_node("CONFIGURAR"));
		node_add_child($$, terminal_node($ID));
		node_add_child($$, terminal_node("COMO"));
		node_add_child($$, terminal_node("ENTRADA"));
		node_add_child($$, terminal_node(";"));
	}
	| CONFIGURAR_PWM ID COM FREQUENCIA NUM RESOLUCAO NUM ';' {
		char *text;
		asprintf(&text, "ledcSetup(%s, %s, %s);\n", $ID, $5, $7);
		$$ = node_new("configuracao", text);
		node_add_child($$, terminal_node("CONFIGURAR_PWM"));
		node_add_child($$, terminal_node($ID));
		node_add_child($$, terminal_node("COM"));
		node_add_child($$, terminal_node("FREQUENCIA"));
		node_add_child($$, terminal_node($5));
		node_add_child($$, terminal_node("RESOLUCAO"));
		node_add_child($$, terminal_node($7));
		node_add_child($$, terminal_node(";"));
	}
	| CONECTAR_WIFI ID ID ';' {
		char *text;
		asprintf(&text, "WiFi.begin(%s, %s);\n", $2, $3);
		$$ = node_new("configuracao", text);
		node_add_child($$, terminal_node("CONECTAR_WIFI"));
		node_add_child($$, terminal_node($2));
		node_add_child($$, terminal_node($3));
		node_add_child($$, terminal_node(";"));
	}
	| CONFIGURAR_SERIAL NUM ';' {
		char *text;
		asprintf(&text, "Serial.begin(%s);\n", $NUM);
		$$ = node_new("configuracao", text);
		node_add_child($$, terminal_node("CONFIGURAR_SERIAL"));
		node_add_child($$, terminal_node($NUM));
		node_add_child($$, terminal_node(";"));
	}
	;

/* Control Structures */
controle
	: SE expressao ENTAO comandos SENAO comandos FIM {
		char *text;
		asprintf(&text, "if (%s) {\n%s} else {\n%s}\n", $expressao->text, $4->text, $6->text);
		$$ = node_new("controle", text);
		node_add_child($$, terminal_node("SE"));
		node_add_child($$, $expressao);
		node_add_child($$, terminal_node("ENTAO"));
		node_add_child($$, $4);
		node_add_child($$, terminal_node("SENAO"));
		node_add_child($$, $6);
		node_add_child($$, terminal_node("FIM"));
	}
	| SE expressao ENTAO comandos FIM {
		char *text;
		asprintf(&text, "if (%s) {\n%s}\n", $expressao->text, $comandos->text);
		$$ = node_new("controle", text);
		node_add_child($$, terminal_node("SE"));
		node_add_child($$, $expressao);
		node_add_child($$, terminal_node("ENTAO"));
		node_add_child($$, $comandos);
		node_add_child($$, terminal_node("FIM"));
	}
	| ENQUANTO comandos FIM {
		char *text;
		asprintf(&text, "while (true) {\n%s}\n", $comandos->text);
		$$ = node_new("controle", text);
		node_add_child($$, terminal_node("ENQUANTO"));
		node_add_child($$, $comandos);
		node_add_child($$, terminal_node("FIM"));
	}
	;

/* GPIO and PWM Actions */
acao
	: AJUSTAR_PWM ID COM VALOR expressao ';' {
		char *text;
		asprintf(&text, "ledcWrite(%s, %s);\n", $ID, $expressao->text);
		$$ = node_new("acao", text);
		node_add_child($$, terminal_node("AJUSTAR_PWM"));
		node_add_child($$, terminal_node($ID));
		node_add_child($$, terminal_node("COM"));
		node_add_child($$, terminal_node("VALOR"));
		node_add_child($$, $expressao);
		node_add_child($$, terminal_node(";"));
	}
	| ESPERAR NUM ';' {
		char *text;
		asprintf(&text, "delay(%s);\n", $NUM);
		$$ = node_new("acao", text);
		node_add_child($$, terminal_node("ESPERAR"));
		node_add_child($$, terminal_node($NUM));
		node_add_child($$, terminal_node(";"));
	}
	| LIGAR ID ';' {
		char *text;
		asprintf(&text, "digitalWrite(%s, HIGH);\n", $ID);
		$$ = node_new("acao", text);
		node_add_child($$, terminal_node("LIGAR"));
		node_add_child($$, terminal_node($ID));
		node_add_child($$, terminal_node(";"));
	}
	| DESLIGAR ID ';' {
		char *text;
		asprintf(&text, "digitalWrite(%s, LOW);\n", $ID);
		$$ = node_new("acao", text);
		node_add_child($$, terminal_node("DESLIGAR"));
		node_add_child($$, terminal_node($ID));
		node_add_child($$, terminal_node(";"));
	}
	;

/* I/O Input */
io_entrada
	: LER_DIGITAL ID {
		char *text;
		asprintf(&text, "digitalRead(%s)", $ID);
		$$ = node_new("io_entrada", text);
		node_add_child($$, terminal_node("LER_DIGITAL"));
		node_add_child($$, terminal_node($ID));
	}
	| LER_ANALOGICO ID {
		char *text;
		asprintf(&text, "analogRead(%s)", $ID);
		$$ = node_new("io_entrada", text);
		node_add_child($$, terminal_node("LER_ANALOGICO"));
		node_add_child($$, terminal_node($ID));
	}
	| LER_SERIAL {
		$$ = node_new("io_entrada", strdup("Serial.read()"));
		node_add_child($$, terminal_node("LER_SERIAL"));
	}
	;

/* I/O Output */
io_saida
	: ESCREVER_SERIAL STRING ';' {
		char *text;
		asprintf(&text, "Serial.println(%s);\n", $STRING);
		$$ = node_new("io_saida", text);
		node_add_child($$, terminal_node("ESCREVER_SERIAL"));
		node_add_child($$, terminal_node($STRING));
		node_add_child($$, terminal_node(";"));
	}
	| ENVIAR_HTTP STRING STRING ';' {
		char *text;
		asprintf(
			&text,
			"http.begin(%s);\n"
			"http.addHeader(\"Content-Type\", \"application/x-www-form-urlencoded\");\n"
			"http.POST(%s);\n"
			"http.end();\n",
			$2, $3
		);
		$$ = node_new("io_saida", text);
		node_add_child($$, terminal_node("ENVIAR_HTTP"));
		node_add_child($$, terminal_node($2));
		node_add_child($$, terminal_node($3));
		node_add_child($$, terminal_node(";"));
	}
	| ENVIAR_HTTP STRING ID ';' {
		char *text;
		asprintf(
			&text,
			"http.begin(%s);\n"
			"http.addHeader(\"Content-Type\", \"application/x-www-form-urlencoded\");\n"
			"http.POST(%s);\n"
			"http.end();\n",
			$2, $3
		);
		$$ = node_new("io_saida", text);
		node_add_child($$, terminal_node("ENVIAR_HTTP"));
		node_add_child($$, terminal_node($2));
		node_add_child($$, terminal_node($3));
		node_add_child($$, terminal_node(";"));
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
		printf("%s", generated_code);
	}
	if (NULL != root)
	{
		print_ast(root, 0);
	}
	return 0;
}

void yyerror(const char* message)
{
	fprintf(stderr, "[ERROR] %d: %s\n", yylineno, message);
}

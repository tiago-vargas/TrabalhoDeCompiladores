%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "lexer.h"

	void yyerror(const char *s);
	extern FILE *yyin;

	char *generated_code = NULL;

	struct node* node_new(char *rule_name, char *text, struct node *child1, struct node *child2, struct node *child3);
	void node_add_child(struct node *parent, struct node *child);
	void print_ast(struct node *n, int depth);

	struct node {
		char *rule_name;
		char *text;
		struct node *child1;
		struct node *child2;
		struct node *child3;
	};

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
%token <num> NUM
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
		$$ = node_new("goal", $programa->text, $programa, NULL, NULL);
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
		$$ = node_new("programa", text, $declaracoes, $config, $bloco_repita);
	}
	;

declaracoes
	: declaracoes declaracao {
		char *text;
		asprintf(&text, "%s%s", $1->text, $2->text);
		$$ = node_new("declaracoes", text, $1, $2, NULL);
	}
	| {
		$$ = node_new("declaracoes", strdup(""), NULL, NULL, NULL);
	}
	;

declaracao
	: VAR tipo ':' lista_ids ';' {
		char *text;
		asprintf(&text, "%s %s;\n", $tipo->text, $lista_ids->text);
		$$ = node_new("declaracao", text, $tipo, $lista_ids, NULL);
	}
	;

tipo
	: INTEIRO {
		$$ = node_new("tipo", strdup("int"), NULL, NULL, NULL);
	}
	| BOOLEANO {
		$$ = node_new("tipo", strdup("bool"), NULL, NULL, NULL);
	}
	| TEXTO {
		$$ = node_new("tipo", strdup("char*"), NULL, NULL, NULL);
	}
	;

lista_ids
	: ID {
		$$ = node_new("lista_ids", strdup($ID), NULL, NULL, NULL);
	}
	| lista_ids ',' ID {
		char *text;
		asprintf(&text, "%s, %s", $1->text, $ID);
		$$ = node_new("lista_ids", text, $1, NULL, NULL);
	}
	;

config
	: CONFIG comandos FIM {
		char *text;
		asprintf(&text, "void setup() {\n%s}\n", $comandos->text);
		$$ = node_new("config", text, $comandos, NULL, NULL);
	}
	;

bloco_repita
	: REPITA comandos FIM {
		char *text;
		asprintf(&text, "void loop() {\n%s}\n", $comandos->text);
		$$ = node_new("bloco_repita", text, $comandos, NULL, NULL);
	}
	;

comandos
	: comandos comando {
		char *text;
		asprintf(&text, "%s%s", $1->text, $comando->text);
		$$ = node_new("comandos", text, $1, $comando, NULL);
	}
	| {
		$$ = node_new("comandos", strdup(""), NULL, NULL, NULL);
	}
	;

comando
	: atribuicao {
		$$ = node_new("comando", $atribuicao->text, $atribuicao, NULL, NULL);
	}
	| configuracao {
		$$ = node_new("comando", $configuracao->text, $configuracao, NULL, NULL);
	}
	| controle {
		$$ = node_new("comando", $controle->text, $controle, NULL, NULL);
	}
	| acao {
		$$ = node_new("comando", $acao->text, $acao, NULL, NULL);
	}
	| io_saida {
		$$ = node_new("comando", $io_saida->text, $io_saida, NULL, NULL);
	}
	;

atribuicao
	: ID '=' expressao ';' {
		char *text;
		asprintf(&text, "%s = %s;\n", $ID, $expressao->text);
		$$ = node_new("atribuicao", text, $expressao, NULL, NULL);
	}
	;

expressao
	: NUM {
		char *text;
		asprintf(&text, "%d", $NUM);
		$$ = node_new("expressao", text, NULL, NULL, NULL);
	}
	| STRING {
		$$ = node_new("expressao", strdup($STRING), NULL, NULL, NULL);
	}
	| ID {
		$$ = node_new("expressao", strdup($ID), NULL, NULL, NULL);
	}
	| expressao OP_REL expressao {
		char *text;
		asprintf(&text, "%s %s %s", $1->text, $OP_REL, $3->text);
		$$ = node_new("expressao", text, $1, $3, NULL);
	}
	| expressao OP_ARIT_1 expressao {
		char *text;
		asprintf(&text, "%s %s %s", $1->text, $OP_ARIT_1, $3->text);
		$$ = node_new("expressao", text, $1, $3, NULL);
	}
	| expressao OP_ARIT_2 expressao {
		char *text;
		asprintf(&text, "%s %s %s", $1->text, $OP_ARIT_2, $3->text);
		$$ = node_new("expressao", text, $1, $3, NULL);
	}
	| '(' expressao ')' {
		char *text;
		asprintf(&text, "(%s)", $2->text);
		$$ = node_new("expressao", text, $2, NULL, NULL);
	}
	| io_entrada {
		$$ = node_new("expressao", $io_entrada->text, $io_entrada, NULL, NULL);
	}
	;

/* GPIO and PWM Configuration */
configuracao
	: CONFIGURAR ID COMO SAIDA ';' {
		char *text;
		asprintf(&text, "pinMode(%s, OUTPUT);\n", $ID);
		$$ = node_new("configuracao", text, NULL, NULL, NULL);
	}
	| CONFIGURAR ID COMO ENTRADA ';' {
		char *text;
		asprintf(&text, "pinMode(%s, INPUT);\n", $ID);
		$$ = node_new("configuracao", text, NULL, NULL, NULL);
	}
	| CONFIGURAR_PWM ID COM FREQUENCIA NUM RESOLUCAO NUM ';' {
		char *text;
		asprintf(&text, "ledcSetup(%s, %d, %d);\n", $ID, $5, $7);
		$$ = node_new("configuracao", text, NULL, NULL, NULL);
	}
	| CONECTAR_WIFI ID ID ';' {
		char *text;
		asprintf(&text, "WiFi.begin(%s, %s);\n", $2, $3);
		$$ = node_new("configuracao", text, NULL, NULL, NULL);
	}
	| CONFIGURAR_SERIAL NUM ';' {
		char *text;
		asprintf(&text, "Serial.begin(%d);\n", $NUM);
		$$ = node_new("configuracao", text, NULL, NULL, NULL);
	}
	;

/* Control Structures */
controle
	: SE expressao ENTAO comandos SENAO comandos FIM {
		char *text;
		asprintf(&text, "if (%s) {\n%s} else {\n%s}\n", $expressao->text, $4->text, $6->text);
		$$ = node_new("controle", text, $expressao, $4, $6);
	}
	| SE expressao ENTAO comandos FIM {
		char *text;
		asprintf(&text, "if (%s) {\n%s}\n", $expressao->text, $comandos->text);
		$$ = node_new("controle", text, $expressao, $comandos, NULL);
	}
	| ENQUANTO comandos FIM {
		char *text;
		asprintf(&text, "while (true) {\n%s}\n", $comandos->text);
		$$ = node_new("controle", text, $comandos, NULL, NULL);
	}
	;

/* GPIO and PWM Actions */
acao
	: AJUSTAR_PWM ID COM VALOR expressao ';' {
		char *text;
		asprintf(&text, "ledcWrite(%s, %s);\n", $ID, $expressao->text);
		$$ = node_new("acao", text, $expressao, NULL, NULL);
	}
	| ESPERAR NUM ';' {
		char *text;
		asprintf(&text, "delay(%d);\n", $NUM);
		$$ = node_new("acao", text, NULL, NULL, NULL);
	}
	| LIGAR ID ';' {
		char *text;
		asprintf(&text, "digitalWrite(%s, HIGH);\n", $ID);
		$$ = node_new("acao", text, NULL, NULL, NULL);
	}
	| DESLIGAR ID ';' {
		char *text;
		asprintf(&text, "digitalWrite(%s, LOW);\n", $ID);
		$$ = node_new("acao", text, NULL, NULL, NULL);
	}
	;

/* I/O Input */
io_entrada
	: LER_DIGITAL ID {
		char *text;
		asprintf(&text, "digitalRead(%s)", $ID);
		$$ = node_new("io_entrada", text, NULL, NULL, NULL);
	}
	| LER_ANALOGICO ID {
		char *text;
		asprintf(&text, "analogRead(%s)", $ID);
		$$ = node_new("io_entrada", text, NULL, NULL, NULL);
	}
	| LER_SERIAL {
		$$ = node_new("io_entrada", strdup("Serial.read()"), NULL, NULL, NULL);
	}
	;

/* I/O Output */
io_saida
	: ESCREVER_SERIAL STRING ';' {
		char *text;
		asprintf(&text, "Serial.println(%s);\n", $STRING);
		$$ = node_new("io_saida", text, NULL, NULL, NULL);
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
		$$ = node_new("io_saida", text, NULL, NULL, NULL);
	}
	| ENVIAR_HTTP STRING ID ';' {
		char *text;
		asprintf(
			&text,
			"http.begin(%s);\n"
			"http.addHeader(\"Content-Type\", \"application/x-www-form-urlencoded\");\n"
			"http.POST(%s);\n"
			"http.end();\n",
			$STRING, $ID
		);
		$$ = node_new("io_saida", text, NULL, NULL, NULL);
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
	// yydebug = 1;

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

struct node* node_new(char *rule_name, char *text, struct node *child1, struct node *child2, struct node *child3)
{
	struct node *n = malloc(sizeof(struct node));
	n->rule_name = strdup(rule_name);
	n->text = text;
	n->child1 = child1;
	n->child2 = child2;
	n->child3 = child3;

	return n;
}

void node_add_child(struct node *parent, struct node *child)
{
	if (parent->child1 == NULL) {
		parent->child1 = child;
	} else if (parent->child2 == NULL) {
		parent->child2 = child;
	} else if (parent->child3 == NULL) {
		parent->child3 = child;
	} else {
		fprintf(stderr, "Error: Cannot add more than 3 children to a node.\n");
		exit(1);
	}
}

void print_ast(struct node *n, int depth)
{
	if (NULL == n)
		return;

	for (int i = 0; i < depth - 1; ++i)
	{
		printf("  ");
	}
	printf("- ");
	printf("%s\n", n->rule_name);

	print_ast(n->child1, depth + 1);
	print_ast(n->child2, depth + 1);
	print_ast(n->child3, depth + 1);
}

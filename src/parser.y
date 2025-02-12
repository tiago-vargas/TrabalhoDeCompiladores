%code requires {
    #include "ast.h"  // Incluir ast.h antes das definições do union
}

%{
#include <stdio.h>
#include <string>
#include <iostream>
#include <ostream>
#include "ast.h"

extern "C" {
    extern int yylex(void);
    void yyerror(const char *s);
}

Node* root = nullptr;
extern int yylineno;
%}

%locations
%define parse.error verbose

%union {
    char* str;
    Node* node;
}

%token VAR CONFIG FIM REPITA SE SENAO ENQUANTO ENTAO
%token CONFIGURAR_SERIAL ESCREVER_SERIAL LER_SERIAL ESPERAR
%token CONFIG_PWM AJUSTAR_PWM COM FREQUENCIA RESOLUCAO VALOR
%token WIFI PIN CONECTAR_WIFI ENVIAR_HTTP
%token HIGH LOW INPUT OUTPUT COMO ENTRADA SAIDA CONFIGURAR
%token LIGAR DESLIGAR LER_DIGITAL LER_ANALOGICO
%token <str> NUMERO ID STRING
%token TIPO_INT TIPO_STRING TIPO_BOOL
%token EQ NEQ LEQ GEQ
%token '+' '-' '*' '/'
%token '=' '>' '<' ';' '(' ')' '{' '}'

%type <node> programa declaracoes declaracao tipo
%type <node> bloco_config comandos_config comando_config
%type <node> bloco_repita comandos comando
%type <node> comando_serial comando_pwm comando_if comando_while
%type <node> comando_gpio comando_wifi
%type <node> atribuicao expr condicao valor
%type <node> operador_rel operador_arit
%type <node> ID_LIST

%%

programa:
    declaracoes bloco_config bloco_repita
    {
        root = new Node(NODE_PROGRAM);
        root->children.push_back($1);
        root->children.push_back($2);
        root->children.push_back($3);
    }
    ;

declaracoes:
    { $$ = new Node(NODE_VAR_DECL); }
    | declaracoes declaracao
    {
        $$ = $1;
        $$->children.push_back($2);
    }
    ;

declaracao:
    VAR TIPO_INT ':' ID_LIST ';'
    {
        $$ = new Node(NODE_VAR_DECL, "inteiro");
        $$->children.push_back($4);
    }
    | VAR TIPO_STRING ':' ID_LIST ';'
    {
        $$ = new Node(NODE_VAR_DECL, "texto");
        $$->children.push_back($4);
    }
    ;

ID_LIST:
    ID 
    { 
        $$ = new Node(NODE_VAR_DECL, $1);
    }
    | ID ',' ID_LIST
    {
        $$ = new Node(NODE_VAR_DECL, $1);
        $$->children.push_back($3);
    }
    ;

tipo:
    TIPO_INT { $$ = new Node(NODE_TYPE, "int"); }
    | TIPO_STRING { $$ = new Node(NODE_TYPE, "String"); }
    | TIPO_BOOL { $$ = new Node(NODE_TYPE, "bool"); }
    ;

bloco_config:
    CONFIG comandos_config FIM
    {
        $$ = new Node(NODE_CONFIG);
        if ($2) $$->children.push_back($2);
    }
    ;

comandos_config:
    { $$ = new Node(NODE_COMMANDS); }
    | comandos_config comando_config
    {
        $$ = $1;
        if ($2) $$->children.push_back($2);
    }
    ;

comando_config:
    comando_serial
    | comando_pwm
    | comando_gpio
    | comando_wifi
    | atribuicao ';'
    ;

comando_serial:
    CONFIGURAR_SERIAL NUMERO ';'
    {
        $$ = new Node(NODE_SERIAL, "configurar");
        $$->children.push_back(new Node(NODE_NUMBER, $2));
    }
    | ESCREVER_SERIAL STRING ';'
    {
        $$ = new Node(NODE_SERIAL, "escrever");
        $$->children.push_back(new Node(NODE_STRING, $2));
    }
    ;

comando_pwm:
    CONFIG_PWM NUMERO COM FREQUENCIA NUMERO RESOLUCAO NUMERO ';'
    {
        $$ = new Node(NODE_PWM, "configurar");
        $$->children.push_back(new Node(NODE_NUMBER, $2));
        $$->children.push_back(new Node(NODE_NUMBER, $5));
        $$->children.push_back(new Node(NODE_NUMBER, $7));
    }
    | AJUSTAR_PWM NUMERO COM VALOR valor ';'
    {
        $$ = new Node(NODE_PWM, "ajustar");
        $$->children.push_back(new Node(NODE_NUMBER, $2));
        $$->children.push_back($5);
    }
    ;

valor:
    NUMERO { $$ = new Node(NODE_NUMBER, $1); }
    | ID { $$ = new Node(NODE_VAR_DECL, $1); }
    ;

comando_gpio:
    CONFIGURAR ID COMO SAIDA ';'
    {
        $$ = new Node(NODE_GPIO, "configurar");
        $$->children.push_back(new Node(NODE_VAR_DECL, $2));
        $$->children.push_back(new Node(NODE_STRING, "OUTPUT"));
    }
    ;

comando_wifi:
    CONECTAR_WIFI ID ID ';'
    {
        $$ = new Node(NODE_WIFI, "conectar");
        $$->children.push_back(new Node(NODE_VAR_DECL, $2));
        $$->children.push_back(new Node(NODE_VAR_DECL, $3));
    }
    ;

comando_if:
    SE '(' condicao ')' '{' comandos '}'
    {
        $$ = new Node(NODE_IF);
        $$->children.push_back($3);
        if ($6) {
            for (Node* cmd : $6->children) {
                $$->children.push_back(cmd);
            }
            $6->children.clear();
            delete $6;
        }
    }
    | SE '(' condicao ')' '{' comandos '}' SENAO '{' comandos '}'
    {
        $$ = new Node(NODE_IF);
        $$->children.push_back($3);
        Node* then_block = new Node(NODE_THEN);
        Node* else_block = new Node(NODE_ELSE);
        
        if ($6) {
            for (Node* cmd : $6->children) {
                then_block->children.push_back(cmd);
            }
            $6->children.clear();
            delete $6;
        }
        
        if ($10) {
            for (Node* cmd : $10->children) {
                else_block->children.push_back(cmd);
            }
            $10->children.clear();
            delete $10;
        }
        
        $$->children.push_back(then_block);
        $$->children.push_back(else_block);
    }
    ;

comando_while:
    ENQUANTO '{' comandos '}'
    {
        $$ = new Node(NODE_WHILE);
        if ($3) {
            for (Node* cmd : $3->children) {
                $$->children.push_back(cmd);
            }
            $3->children.clear();
            delete $3;
        }
    }
    ;

condicao:
    expr operador_rel expr
    {
        $$ = new Node(NODE_EXPR, $2->value);
        $$->children.push_back($1);
        $$->children.push_back($3);
        delete $2;
    }
    ;

operador_rel:
    '>' { $$ = new Node(NODE_OPERATOR, ">"); }
    | '<' { $$ = new Node(NODE_OPERATOR, "<"); }
    | EQ { $$ = new Node(NODE_OPERATOR, "=="); }
    | NEQ { $$ = new Node(NODE_OPERATOR, "!="); }
    | LEQ { $$ = new Node(NODE_OPERATOR, "<="); }
    | GEQ { $$ = new Node(NODE_OPERATOR, ">="); }
    ;

atribuicao:
    ID '=' expr
    {
        $$ = new Node(NODE_ASSIGN, $1);
        $$->children.push_back($3);
    }
    | ID '=' STRING
    {
        $$ = new Node(NODE_ASSIGN, $1);
        $$->children.push_back(new Node(NODE_STRING, $3));
    }
    ;

expr:
    NUMERO { $$ = new Node(NODE_NUMBER, $1); }
    | ID { $$ = new Node(NODE_VAR_DECL, $1); }
    | STRING { $$ = new Node(NODE_STRING, $1); }
    | expr operador_arit expr
    {
        $$ = new Node(NODE_EXPR, $2->value);
        $$->children.push_back($1);
        $$->children.push_back($3);
        delete $2;
    }
    ;

operador_arit:
    '+' { $$ = new Node(NODE_OPERATOR, "+"); }
    | '-' { $$ = new Node(NODE_OPERATOR, "-"); }
    | '*' { $$ = new Node(NODE_OPERATOR, "*"); }
    | '/' { $$ = new Node(NODE_OPERATOR, "/"); }
    ;

bloco_repita:
    REPITA comandos FIM
    {
        $$ = new Node(NODE_REPEAT);
        if ($2) $$->children.push_back($2);
    }
    ;

comandos:
    { $$ = new Node(NODE_COMMANDS); }
    | comandos comando
    {
        $$ = $1;
        if ($2) $$->children.push_back($2);
    }
    ;

comando:
    comando_serial { $$ = $1; }
    | comando_pwm { $$ = $1; }
    | comando_gpio { $$ = $1; }
    | comando_wifi { $$ = $1; }
    | comando_if { $$ = $1; }
    | comando_while { $$ = $1; }
    | atribuicao ';' { $$ = $1; }
    | ESPERAR NUMERO ';' { $$ = new Node(NODE_DELAY, $2); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro na linha %d: %s\n", yylineno, s);
}
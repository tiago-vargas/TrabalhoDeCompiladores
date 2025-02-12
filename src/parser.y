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

%token VAR CONFIG FIM REPITA SE SENAO ENQUANTO
%token CONFIGURAR_SERIAL ESCREVER_SERIAL ESPERAR
%token CONFIG_PWM AJUSTAR_PWM COM FREQUENCIA RESOLUCAO VALOR
%token WIFI PIN
%token HIGH LOW INPUT OUTPUT
%token <str> NUMERO ID STRING
%token TIPO_INT TIPO_STRING TIPO_BOOL
%token EQ NEQ
%token '=' '>' '<' ';' '(' ')' '{' '}'

%type <node> programa declaracoes declaracao tipo
%type <node> bloco_config comandos_config comando_config
%type <node> bloco_repita comandos comando
%type <node> comando_serial comando_pwm comando_if
%type <node> atribuicao expr condicao

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
    { 
        $$ = new Node(NODE_VAR_DECL); 
    }
    | declaracoes declaracao
    {
        $$ = $1;
        $$->children.push_back($2);
    }
    ;

declaracao:
    VAR tipo ':' ID ';'
    {
        $$ = new Node(NODE_VAR_DECL, $4);
        $$->children.push_back($2);
    }
    ;

tipo:
    TIPO_INT { 
        $$ = new Node(NODE_VAR_DECL, "int"); 
    }
    | TIPO_STRING { 
        $$ = new Node(NODE_VAR_DECL, "String"); 
    }
    ;

bloco_config:
    CONFIG comandos_config FIM
    {
        $$ = new Node(NODE_CONFIG);
        if ($2) {
            $$->children = $2->children;
            $2->children.clear();
            delete $2;
        }
    }
    ;

comandos_config:
    { 
        $$ = new Node(NODE_CONFIG); 
    }
    | comandos_config comando_config
    {
        $$ = $1;
        if ($2) $$->children.push_back($2);
    }
    ;

comando_config:
    CONFIGURAR_SERIAL NUMERO ';'
    {
        $$ = new Node(NODE_SERIAL, "configurar");
        $$->children.push_back(new Node(NODE_NUMBER, $2));
    }
    | CONFIG_PWM NUMERO COM FREQUENCIA NUMERO RESOLUCAO NUMERO ';'
    {
        $$ = new Node(NODE_PWM, "configurar");
        $$->children.push_back(new Node(NODE_NUMBER, $2));
        $$->children.push_back(new Node(NODE_NUMBER, $5));
        $$->children.push_back(new Node(NODE_NUMBER, $7));
    }
    | atribuicao
    {
        $$ = $1;
    }
    ;

comando_serial:
    ESCREVER_SERIAL STRING ';'
    {
        $$ = new Node(NODE_SERIAL, "escrever");
        $$->children.push_back(new Node(NODE_STRING, $2));
    }
    ;

comando_pwm:
    AJUSTAR_PWM NUMERO COM VALOR NUMERO ';'
    {
        $$ = new Node(NODE_PWM, "ajustar");
        $$->children.push_back(new Node(NODE_NUMBER, $2));
        $$->children.push_back(new Node(NODE_NUMBER, $5));
    }
    ;

bloco_repita:
    REPITA comandos FIM
    {
        std::cout << "DEBUG: Criando bloco repita" << std::endl;
        $$ = new Node(NODE_REPEAT);
        if ($2) {
            std::cout << "DEBUG: comandos não é nulo" << std::endl;
            std::cout << "DEBUG: número de comandos: " << $2->children.size() << std::endl;
            // Ao invés de mover os comandos, vamos copiá-los
            for (Node* cmd : $2->children) {
                if (cmd) {
                    std::cout << "DEBUG: Adicionando comando tipo " << cmd->type << std::endl;
                    // Não transferimos a propriedade do nó
                    $$->children.push_back(cmd);
                }
            }
            // Limpar apenas o container, não os nós
            $2->children.clear();
            delete $2;
        } else {
            std::cout << "DEBUG: comandos é nulo" << std::endl;
        }
        std::cout << "DEBUG: Bloco repita criado com " << $$->children.size() << " comandos" << std::endl;
    }
    ;

comandos:
    { 
        $$ = new Node(NODE_REPEAT); 
    }
    | comandos comando
    {
        if ($1 == nullptr) {
            $1 = new Node(NODE_REPEAT);
        }
        $$ = $1;
        if ($2) $$->children.push_back($2);
    }
    ;

comando:
    comando_if { $$ = $1; }
    | comando_pwm { $$ = $1; }
    | comando_serial { $$ = $1; }
    | ESPERAR '(' NUMERO ')' ';'
    {
        $$ = new Node(NODE_DELAY);
        $$->children.push_back(new Node(NODE_NUMBER, $3));
    }
    ;

comando_if:
    SE '(' condicao ')' '{' comandos '}'
    {
        std::cout << "DEBUG: Criando comando if" << std::endl;
        $$ = new Node(NODE_IF);
        
        if ($3) {
            std::cout << "DEBUG: Adicionando condição ao if, tipo: " << $3->type << std::endl;
            $$->children.push_back($3);
        }
        
        if ($6) {
            std::cout << "DEBUG: Processando " << $6->children.size() << " comandos do if" << std::endl;
            for (Node* cmd : $6->children) {
                if (cmd) {
                    std::cout << "DEBUG: Adicionando comando tipo " << cmd->type << " ao corpo do if" << std::endl;
                    $$->children.push_back(cmd);
                }
            }
            // Limpar apenas o container, não os nós
            $6->children.clear();
            delete $6;
        }
        
        std::cout << "DEBUG: Comando if finalizado com " << $$->children.size() << " filhos" << std::endl;
    }
    ;

condicao:
    expr '>' expr
    {
        $$ = new Node(NODE_EXPR, ">");
        if ($1) $$->children.push_back($1);
        if ($3) $$->children.push_back($3);
    }
    ;

expr:
    ID { $$ = new Node(NODE_VAR_DECL, $1); }
    | NUMERO { $$ = new Node(NODE_NUMBER, $1); }
    ;

atribuicao:
    ID '=' expr ';'
    {
        $$ = new Node(NODE_ASSIGN, $1);
        $$->children.push_back($3);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}
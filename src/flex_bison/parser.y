%{
#include <iostream>
#include <string>
#include <vector>
#include <memory>
#include "ast.hpp"
#include "symbol_table.hpp"
#include "lexer.hpp"
#include "token.hpp"

// Declarações necessárias
extern int yylex();
void yyerror(const char* s);
extern int linha_atual;

// Forward declarations para os tipos usados no union
class Expressao;
class Comando;

TabelaSimbolos tabela_simbolos;
std::vector<std::shared_ptr<Comando>> comandos_globais;
TipoVariavel atual_tipo;
%}

%union {
    char* string_val;
    std::shared_ptr<Expressao>* expr;
    std::shared_ptr<Comando>* cmd;
    std::vector<std::shared_ptr<Comando>>* cmds;
    std::vector<std::string>* ids;
    TipoVariavel tipo;
}

%token CONFIG REPITA FIM VAR
%token TIPO_INTEIRO TIPO_BOOLEANO TIPO_TEXTO
%token SE ENTAO SENAO ENQUANTO
%token CONFIGURAR LIGAR DESLIGAR COMO SAIDA ENTRADA
%token DOIS_PONTOS PONTO_VIRGULA IGUAL IGUAL_IGUAL VIRGULA
%token MAIS MENOS MULTIPLICA DIVIDE
%token MAIOR MENOR MAIOR_IGUAL MENOR_IGUAL DIFERENTE
%token <string_val> IDENTIFICADOR NUMERO STRING_LITERAL

%type <expr> expressao
%type <cmd> comando declaracao atribuicao comando_se comando_repita comando_esp32 comando_enquanto
%type <cmds> lista_comandos bloco_comandos programa
%type <ids> lista_identificadores
%type <tipo> tipo_dado

%left IGUAL_IGUAL DIFERENTE
%left MAIOR MENOR MAIOR_IGUAL MENOR_IGUAL
%left MAIS MENOS
%left MULTIPLICA DIVIDE

%%

programa: 
    lista_comandos
    { 
        comandos_globais = *$1;
        $$ = $1;
    }
    ;

lista_comandos: 
    comando 
    { 
        $$ = new std::vector<std::shared_ptr<Comando>>();
        $$->push_back(*$1);
        delete $1;
    }
    | lista_comandos comando 
    { 
        $1->push_back(*$2);
        $$ = $1;
        delete $2;
    }
    ;

comando:
    declaracao { $$ = $1; }
    | atribuicao { $$ = $1; }
    | comando_se { $$ = $1; }
    | comando_repita { $$ = $1; }
    | comando_esp32 { $$ = $1; }
    | comando_enquanto { $$ = $1; }
    ;

declaracao:
    VAR tipo_dado DOIS_PONTOS lista_identificadores PONTO_VIRGULA
    {
        atual_tipo = $2;
        $$ = new std::shared_ptr<Comando>(
            std::make_shared<ComandoDeclaracao>($2, *$4)
        );
        delete $4;
    }
    ;

tipo_dado:
    TIPO_INTEIRO { $$ = TipoVariavel::INTEIRO; }
    | TIPO_BOOLEANO { $$ = TipoVariavel::BOOLEANO; }
    | TIPO_TEXTO { $$ = TipoVariavel::TEXTO; }
    ;

lista_identificadores:
    IDENTIFICADOR 
    { 
        $$ = new std::vector<std::string>();
        $$->push_back($1);
        tabela_simbolos.inserir($1, atual_tipo);
        free($1);
    }
    | lista_identificadores VIRGULA IDENTIFICADOR
    {
        $1->push_back($3);
        tabela_simbolos.inserir($3, atual_tipo);
        $$ = $1;
        free($3);
    }
    ;

atribuicao:
    IDENTIFICADOR IGUAL expressao PONTO_VIRGULA
    {
        if (!tabela_simbolos.existe($1)) {
            yyerror("Variável não declarada");
        }
        $$ = new std::shared_ptr<Comando>(
            std::make_shared<ComandoAtribuicao>($1, *$3)
        );
        tabela_simbolos.marcar_inicializado($1);
        free($1);
        delete $3;
    }
    ;

comando_se:
    SE expressao ENTAO bloco_comandos FIM
    {
        $$ = new std::shared_ptr<Comando>(
            std::make_shared<ComandoSe>(*$2, *$4)
        );
        delete $2;
        delete $4;
    }
    | SE expressao ENTAO bloco_comandos SENAO bloco_comandos FIM
    {
        $$ = new std::shared_ptr<Comando>(
            std::make_shared<ComandoSe>(*$2, *$4, *$6)
        );
        delete $2;
        delete $4;
        delete $6;
    }
    ;

comando_repita:
    REPITA bloco_comandos FIM
    {
        $$ = new std::shared_ptr<Comando>(
            std::make_shared<ComandoRepita>(*$2)
        );
        delete $2;
    }
    ;

comando_enquanto:
    ENQUANTO expressao bloco_comandos FIM
    {
        $$ = new std::shared_ptr<Comando>(
            std::make_shared<ComandoEnquanto>(*$2, *$3)
        );
        delete $2;
        delete $3;
    }
    ;

comando_esp32:
    CONFIGURAR IDENTIFICADOR COMO SAIDA PONTO_VIRGULA
    {
        if (!tabela_simbolos.existe($2)) {
            yyerror("Pino não declarado");
        }
        $$ = new std::shared_ptr<Comando>(
            std::make_shared<ComandoESP32>(
                ComandoESP32::Tipo::CONFIGURAR_PINO,
                std::vector<std::shared_ptr<Expressao>>{
                    std::make_shared<ExpressaoIdentificador>($2)
                }
            )
        );
    }
    | LIGAR IDENTIFICADOR PONTO_VIRGULA
    {
        if (!tabela_simbolos.existe($2)) {
            yyerror("Pino não declarado");
        }
        $$ = new std::shared_ptr<Comando>(
            std::make_shared<ComandoESP32>(
                ComandoESP32::Tipo::LIGAR,
                std::vector<std::shared_ptr<Expressao>>{
                    std::make_shared<ExpressaoIdentificador>($2)
                }
            )
        );
    }
    | DESLIGAR IDENTIFICADOR PONTO_VIRGULA
    {
        if (!tabela_simbolos.existe($2)) {
            yyerror("Pino não declarado");
        }
        $$ = new std::shared_ptr<Comando>(
            std::make_shared<ComandoESP32>(
                ComandoESP32::Tipo::DESLIGAR,
                std::vector<std::shared_ptr<Expressao>>{
                    std::make_shared<ExpressaoIdentificador>($2)
                }
            )
        );
    }
    ;

bloco_comandos:
    comando
    {
        $$ = new std::vector<std::shared_ptr<Comando>>();
        $$->push_back(*$1);
        delete $1;
    }
    | bloco_comandos comando
    {
        $1->push_back(*$2);
        $$ = $1;
        delete $2;
    }
    ;

expressao:
    NUMERO
    {
        $$ = new std::shared_ptr<Expressao>(
            std::make_shared<ExpressaoLiteral>($1)
        );
        free($1);
    }
    | IDENTIFICADOR
    {
        if (!tabela_simbolos.existe($1)) {
            yyerror("Variável não declarada");
        }
        $$ = new std::shared_ptr<Expressao>(
            std::make_shared<ExpressaoIdentificador>($1)
        );
        free($1);
    }
    | expressao MAIS expressao
    {
        $$ = new std::shared_ptr<Expressao>(
            std::make_shared<ExpressaoBinaria>(
                OperadorBinario::SOMA, *$1, *$3
            )
        );
        delete $1;
        delete $3;
    }
    | expressao MENOS expressao
    {
        $$ = new std::shared_ptr<Expressao>(
            std::make_shared<ExpressaoBinaria>(
                OperadorBinario::SUBTRACAO, *$1, *$3
            )
        );
        delete $1;
        delete $3;
    }
    | expressao MULTIPLICA expressao
    {
        $$ = new std::shared_ptr<Expressao>(
            std::make_shared<ExpressaoBinaria>(
                OperadorBinario::MULTIPLICACAO, *$1, *$3
            )
        );
        delete $1;
        delete $3;
    }
    | expressao DIVIDE expressao
    {
        $$ = new std::shared_ptr<Expressao>(
            std::make_shared<ExpressaoBinaria>(
                OperadorBinario::DIVISAO, *$1, *$3
            )
        );
        delete $1;
        delete $3;
    }
    | expressao MAIOR expressao
    {
        $$ = new std::shared_ptr<Expressao>(
            std::make_shared<ExpressaoBinaria>(
                OperadorBinario::MAIOR, *$1, *$3
            )
        );
        delete $1;
        delete $3;
    }
    | expressao MENOR expressao
    {
        $$ = new std::shared_ptr<Expressao>(
            std::make_shared<ExpressaoBinaria>(
                OperadorBinario::MENOR, *$1, *$3
            )
        );
        delete $1;
        delete $3;
    }
    | expressao MAIOR_IGUAL expressao
    {
        $$ = new std::shared_ptr<Expressao>(
            std::make_shared<ExpressaoBinaria>(
                OperadorBinario::MAIOR_IGUAL, *$1, *$3
            )
        );
        delete $1;
        delete $3;
    }
    | expressao MENOR_IGUAL expressao
    {
        $$ = new std::shared_ptr<Expressao>(
            std::make_shared<ExpressaoBinaria>(
                OperadorBinario::MENOR_IGUAL, *$1, *$3
            )
        );
        delete $1;
        delete $3;
    }
    | expressao IGUAL_IGUAL expressao
    {
        $$ = new std::shared_ptr<Expressao>(
            std::make_shared<ExpressaoBinaria>(
                OperadorBinario::IGUAL, *$1, *$3
            )
        );
        delete $1;
        delete $3;
    }
    | expressao DIFERENTE expressao
    ;

%%

void yyerror(const char* s) {
    std::cerr << "Erro sintático na linha " << linha_atual << ": " << s << std::endl;
}
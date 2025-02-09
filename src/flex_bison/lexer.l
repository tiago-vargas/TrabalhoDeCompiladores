%{
#include <string>
#include <memory>
#include <vector>
#include "ast.hpp"
#include "symbol_table.hpp"
#include "parser.tab.hpp"
#include "lexer.hpp"

// Não definir YY_DECL aqui pois já está definido em outro lugar
%}

%option c++
%option yyclass="AnalisadorLexico"
%option noyywrap
%option yylineno
%option outfile="lexer.cpp"
%option header-file="lexer.hpp"
%option never-interactive
%option stack

%%

[ \t\r]                     ; // Ignora espaços em branco
\n                          { linha_atual_val++; }
"//".*                      ; // Ignora comentários de linha

"config"                    { set_texto_token(std::string(yytext)); return CONFIG; }
"repita"                    { set_texto_token(std::string(yytext)); return REPITA; }
"fim"                       { set_texto_token(std::string(yytext)); return FIM; }
"var"                       { set_texto_token(std::string(yytext)); return VAR; }
"se"                        { set_texto_token(std::string(yytext)); return SE; }
"entao"                     { set_texto_token(std::string(yytext)); return ENTAO; }
"senao"                     { set_texto_token(std::string(yytext)); return SENAO; }
"enquanto"                  { set_texto_token(std::string(yytext)); return ENQUANTO; }

"inteiro"                   { set_texto_token(std::string(yytext)); return TIPO_INTEIRO; }
"booleano"                  { set_texto_token(std::string(yytext)); return TIPO_BOOLEANO; }
"texto"                     { set_texto_token(std::string(yytext)); return TIPO_TEXTO; }

"configurar"                { set_texto_token(std::string(yytext)); return CONFIGURAR; }
"ligar"                     { set_texto_token(std::string(yytext)); return LIGAR; }
"desligar"                  { set_texto_token(std::string(yytext)); return DESLIGAR; }
"como"                      { set_texto_token(std::string(yytext)); return COMO; }
"saida"                     { set_texto_token(std::string(yytext)); return SAIDA; }
"entrada"                   { set_texto_token(std::string(yytext)); return ENTRADA; }

":"                         { set_texto_token(std::string(yytext)); return DOIS_PONTOS; }
";"                         { set_texto_token(std::string(yytext)); return PONTO_VIRGULA; }
"="                         { set_texto_token(std::string(yytext)); return IGUAL; }
"=="                        { set_texto_token(std::string(yytext)); return IGUAL_IGUAL; }
","                         { set_texto_token(std::string(yytext)); return VIRGULA; }
"+"                         { set_texto_token(std::string(yytext)); return MAIS; }
"-"                         { set_texto_token(std::string(yytext)); return MENOS; }
"*"                         { set_texto_token(std::string(yytext)); return MULTIPLICA; }
"/"                         { set_texto_token(std::string(yytext)); return DIVIDE; }
">"                         { set_texto_token(std::string(yytext)); return MAIOR; }
"<"                         { set_texto_token(std::string(yytext)); return MENOR; }
">="                        { set_texto_token(std::string(yytext)); return MAIOR_IGUAL; }
"<="                        { set_texto_token(std::string(yytext)); return MENOR_IGUAL; }
"!="                        { set_texto_token(std::string(yytext)); return DIFERENTE; }

[0-9]+                      { set_texto_token(std::string(yytext)); return NUMERO; }
[a-zA-Z_][a-zA-Z0-9_]*     { set_texto_token(std::string(yytext)); return IDENTIFICADOR; }
\"[^\"]*\"                  { set_texto_token(std::string(yytext)); return STRING_LITERAL; }

[ \t\r\n]+                 ; // Ignora espaços em branco

.                          { printf("Erro léxico: caractere inválido '%s' na linha %d\n", 
                                   yytext, linha_atual_val); }

%%

// Não é necessário implementar funções adicionais aqui
%{
#include <string>
#include "parser.tab.hpp"
#include "token.hpp"

int linha_atual = 1;
%}

%option noyywrap
%option c++

%%

[ \t\r]                     ; // Ignora espaços em branco
\n                          { linha_atual++; }
"//".*                      ; // Ignora comentários de linha

"config"                    { return CONFIG; }
"repita"                    { return REPITA; }
"fim"                       { return FIM; }
"var"                       { return VAR; }
"se"                        { return SE; }
"entao"                     { return ENTAO; }
"senao"                     { return SENAO; }
"enquanto"                  { return ENQUANTO; }

"inteiro"                   { return TIPO_INTEIRO; }
"booleano"                  { return TIPO_BOOLEANO; }
"texto"                     { return TIPO_TEXTO; }

"configurar"                { return CONFIGURAR; }
"ligar"                     { return LIGAR; }
"desligar"                  { return DESLIGAR; }
"como"                      { return COMO; }
"saida"                     { return SAIDA; }
"entrada"                   { return ENTRADA; }

":"                         { return DOIS_PONTOS; }
";"                         { return PONTO_VIRGULA; }
"="                         { return IGUAL; }
"=="                        { return IGUAL_IGUAL; }
","                         { return VIRGULA; }
"+"                         { return MAIS; }
"-"                         { return MENOS; }
"*"                         { return MULTIPLICA; }
"/"                         { return DIVIDE; }
">"                         { return MAIOR; }
"<"                         { return MENOR; }
">="                        { return MAIOR_IGUAL; }
"<="                        { return MENOR_IGUAL; }
"!="                        { return DIFERENTE; }

[0-9]+                      { 
                             yylval.string_val = strdup(yytext);
                             return NUMERO; 
                           }
[a-zA-Z_][a-zA-Z0-9_]*     { 
                             yylval.string_val = strdup(yytext);
                             return IDENTIFICADOR; 
                           }
\"[^\"]*\"                  { 
                             yylval.string_val = strdup(yytext);
                             return STRING_LITERAL; 
                           }

.                          { 
                            printf("Erro léxico: caractere inválido '%s' na linha %d\n", 
                                   yytext, linha_atual); 
                          }

%%
%{
#include <string>
#include "ast.h"
#include "parser.tab.h"

extern "C" {
    int yylex(void);
}
%}

%option noyywrap
%option never-interactive
%option yylineno

%%

[ \t\n]+        { /* ignora espaços em branco */ }
"//".*          { /* ignora comentários */ }

"var"           { return VAR; }
"config"        { return CONFIG; }
"fim"           { return FIM; }
"repita"        { return REPITA; }
"se"            { return SE; }
"senao"         { return SENAO; }
"entao"         { return ENTAO; }
"enquanto"      { return ENQUANTO; }

"configurarSerial" { return CONFIGURAR_SERIAL; }
"escreverSerial"   { return ESCREVER_SERIAL; }
"lerSerial"        { return LER_SERIAL; }
"esperar"          { return ESPERAR; }

"configurarPWM"    { return CONFIG_PWM; }
"ajustarPWM"       { return AJUSTAR_PWM; }
"com"              { return COM; }
"frequencia"       { return FREQUENCIA; }
"resolucao"        { return RESOLUCAO; }
"valor"            { return VALOR; }

"configurar"       { return CONFIGURAR; }
"como"             { return COMO; }
"entrada"          { return ENTRADA; }
"saida"            { return SAIDA; }
"ligar"            { return LIGAR; }
"desligar"         { return DESLIGAR; }
"lerDigital"       { return LER_DIGITAL; }
"lerAnalogico"     { return LER_ANALOGICO; }

"conectarWifi"     { return CONECTAR_WIFI; }
"enviarHttp"       { return ENVIAR_HTTP; }

"inteiro"          { return TIPO_INT; }
"texto"            { return TIPO_STRING; }
"booleano"         { return TIPO_BOOL; }

"=="               { return EQ; }
"!="               { return NEQ; }
"<="               { return LEQ; }
">="               { return GEQ; }

"wifi"            { return WIFI; }
"pin"             { return PIN; }

"high"            { return HIGH; }
"low"             { return LOW; }
"input"           { return INPUT; }
"output"          { return OUTPUT; }

[0-9]+          { yylval.str = strdup(yytext); return NUMERO; }
\"[^\"]*\"      { yylval.str = strdup(yytext); return STRING; }
[a-zA-Z][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return ID; }

[=><(){};:,+\-*/] { return yytext[0]; }

.               { /* ignora caracteres não reconhecidos */ }

%%
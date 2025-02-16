%{
	#include "parser.tab.h"

	extern YYSTYPE yylval;
%}

%option yylineno

%%

"config"        { return CONFIG; }
"repita"        { return REPITA; }
"fim"           { return FIM; }

"var"           { return VAR; }
"inteiro"       { return INTEIRO; }
"booleano"      { return BOOLEANO; }
"texto"         { return TEXTO; }

"se"            { return SE; }
"entao"         { return ENTAO; }
"senao"         { return SENAO; }
"enquanto"      { return ENQUANTO; }

"configurar"       { return CONFIGURAR; }
"configurarPWM"    { return CONFIGURAR_PWM; }
"configurarSerial" { return CONFIGURAR_SERIAL; }
"lerDigital"       { return LER_DIGITAL; }
"lerAnalogico"     { return LER_ANALOGICO; }
"lerSerial"        { return LER_SERIAL; }
"escreverSerial"   { return ESCREVER_SERIAL; }
"ajustarPWM"       { return AJUSTAR_PWM; }
"esperar"          { return ESPERAR; }
"conectarWifi"     { return CONECTAR_WIFI; }
"enviarHttp"       { return ENVIAR_HTTP; }

"ligar"         { return LIGAR; }
"desligar"      { return DESLIGAR; }

"como"          { return COMO; }
"saida"         { return SAIDA; }
"entrada"       { return ENTRADA; }
"com"           { return COM; }
"valor"         { return VALOR; }
"frequencia"    { return FREQUENCIA; }
"resolucao"     { return RESOLUCAO; }

"="             { return '='; }
"=="            { yylval.str = strdup("=="); return OP_REL; }
"<"             { yylval.str = strdup("<"); return OP_REL; }
">"             { yylval.str = strdup(">"); return OP_REL; }
"<="            { yylval.str = strdup("<="); return OP_REL; }
">="            { yylval.str = strdup(">="); return OP_REL; }
"!="            { yylval.str = strdup("!="); return OP_REL; }
"+"             { yylval.str = strdup("+"); return OP_ARIT_1; }
"-"             { yylval.str = strdup("-"); return OP_ARIT_1; }
"*"             { yylval.str = strdup("*"); return OP_ARIT_2; }
"/"             { yylval.str = strdup("/"); return OP_ARIT_2; }
"("             { return '('; }
")"             { return ')'; }
":"             { return ':'; }
","             { return ','; }
";"             { return ';'; }
[0-9]+                    { yylval.str = strdup(yytext); return NUM; }
\"[^\"]*\"                { yylval.str = strdup(yytext); return STRING; }
[a-zA-Z_][a-zA-Z0-9_]*    { yylval.str = strdup(yytext); return ID; }

"//".*          /* Ignore single-line comments */
[ \t\n]+        /* Ignore whitespace */
.               { printf("Unknown character `%s` on line %d\n", yytext, yylineno); }

%%

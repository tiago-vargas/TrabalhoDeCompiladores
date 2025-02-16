%{
	#include "parser.tab.h"

	extern YYSTYPE yylval;
%}

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

"configurar"    { return CONFIGURAR; }
"configurarPWM" { return CONFIGURAR_PWM; }
"ajustarPWM"    { return AJUSTAR_PWM; }
"esperar"       { return ESPERAR; }
"conectarWifi"  { return CONECTAR_WIFI; }

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
"+"             { yylval.str = strdup("+"); return OP_ARIT; }
"-"             { yylval.str = strdup("-"); return OP_ARIT; }
"*"             { yylval.str = strdup("*"); return OP_ARIT; }
"/"             { yylval.str = strdup("/"); return OP_ARIT; }
":"             { return ':'; }
","             { return ','; }
";"             { return ';'; }
[0-9]+                    { yylval.num = atoi(yytext); return NUM; }
\"[^\"]*\"                { yylval.str = strdup(yytext); return STRING; }
[a-zA-Z_][a-zA-Z0-9_]*    { yylval.str = strdup(yytext); return ID; }

[//].*          /* Ignorar comentários */
[ \t\n]+        /* Ignorar espaços em branco */
.               { printf("Caractere desconhecido: `%s`\n", yytext); }

%%

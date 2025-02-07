%{
    #include "parser.h"
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
"conectarWifi"  { return CONECTARWIFI; }

"ligar"         { return LIGAR; }
"desligar"      { return DESLIGAR; }

"como"          { return COMO; }
"com valor"     { return COM_VALOR; }
"frequencia"    { return FREQUENCIA; }
"resolucao"     { return RESOLUCAO; }

[0-9]+          { yylval = atoi(yytext); return NUM; }
\"[^\"]*\"      { yylval = strdup(yytext); return STRING; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval = strdup(yytext); return ID; }

[ \t\n]+        /* Ignorar espaços em branco */
.               { printf("Caractere desconhecido: %s\n", yytext); }

%%

int yywrap() { return 1; }

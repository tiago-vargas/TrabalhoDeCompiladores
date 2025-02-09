#pragma once

#include <string>

enum class TokenType {
    // Palavras-chave
    CONFIG,
    REPITA,
    FIM,
    VAR,
    COMO,
    SAIDA,
    ENTRADA,
    
    // Tipos de dados
    TIPO_INTEIRO,
    TIPO_BOOLEANO,
    TIPO_TEXTO,
    
    // Símbolos
    DOIS_PONTOS,
    PONTO_VIRGULA,
    IGUAL,
    IGUAL_IGUAL,
    VIRGULA,
    
    // Operadores
    MAIS,
    MENOS,
    MULTIPLICA,
    DIVIDE,
    MAIOR,
    MENOR,
    MAIOR_IGUAL,
    MENOR_IGUAL,
    DIFERENTE,
    
    // Outros
    IDENTIFICADOR,
    NUMERO,
    STRING_LITERAL,
    FIM_ARQUIVO,
    
    // Novos tokens para controle de fluxo
    SE,
    SENAO,
    ENTAO,
    ENQUANTO,
    
    // Tokens específicos do ESP32
    CONFIGURAR,
    LIGAR,
    DESLIGAR,
    COMO,
    SAIDA,
    ENTRADA,
};

struct Token {
    TokenType tipo;
    std::string lexema;
    int linha;
    
    Token(TokenType t, std::string l, int lin) : tipo(t), lexema(l), linha(lin) {}
};
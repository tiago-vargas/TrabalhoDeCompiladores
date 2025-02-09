#pragma once

#include <string>

enum class TokenType {
    // Tokens básicos
    IDENTIFICADOR,
    NUMERO,
    STRING_LITERAL,
    
    // Palavras-chave
    VAR,
    CONFIG,
    REPITA,
    FIM,
    SE,
    ENTAO,
    SENAO,
    ENQUANTO,
    
    // Tipos
    TIPO_INTEIRO,
    TIPO_BOOLEANO,
    TIPO_TEXTO,
    
    // Comandos ESP32
    CONFIGURAR,
    LIGAR,
    DESLIGAR,
    COMO,
    SAIDA,
    ENTRADA,
    
    // Símbolos
    DOIS_PONTOS,
    PONTO_VIRGULA,
    IGUAL,
    IGUAL_IGUAL,
    VIRGULA,
    MAIS,
    MENOS,
    MULTIPLICA,
    DIVIDE,
    MAIOR,
    MENOR,
    MAIOR_IGUAL,
    MENOR_IGUAL,
    DIFERENTE,
    
    FIM_ARQUIVO
};

struct Token {
    TokenType tipo;
    std::string lexema;
    int linha;
    
    Token(TokenType t, std::string l, int ln) 
        : tipo(t), lexema(std::move(l)), linha(ln) {}
    
    Token() : tipo(TokenType::FIM_ARQUIVO), linha(0) {}
};
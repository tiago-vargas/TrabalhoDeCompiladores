#include "lexer.hpp"
#include <memory>
#include <vector>
#include "ast.hpp"
#include "symbol_table.hpp"
#include "parser.tab.hpp"
#include <stdexcept>

Token AnalisadorLexico::proximo_token() {
    if (posicao_atual >= codigo.length()) {
        return Token(TokenType::FIM_ARQUIVO, "", linha_atual_val);
    }
    
    // Pular espaços em branco
    while (posicao_atual < codigo.length() && 
           (codigo[posicao_atual] == ' ' || 
            codigo[posicao_atual] == '\t' || 
            codigo[posicao_atual] == '\n')) {
        if (codigo[posicao_atual] == '\n') {
            linha_atual_val++;
        }
        posicao_atual++;
    }
    
    // Retornar EOF se chegou ao fim
    if (posicao_atual >= codigo.length()) {
        return Token(TokenType::FIM_ARQUIVO, "", linha_atual_val);
    }
    
    // Implementar lógica real do lexer aqui
    // Por enquanto, retorna um token de erro
    throw std::runtime_error("Lexer não implementado completamente");
} 
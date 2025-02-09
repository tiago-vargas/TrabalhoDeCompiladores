#pragma once

#include <memory>
#include <vector>
#include "lexer.hpp"
#include "ast.hpp"
#include "token.hpp"
#include "symbol_table.hpp"

class AnalisadorSintatico {
private:
    AnalisadorLexico& lexer;
    Token token_atual;
    TabelaSimbolos tabela_simbolos;
    std::vector<std::shared_ptr<Comando>> comandos;

    Token avancar();
    Token consumir(TokenType tipo);
    bool verificar(TokenType tipo);
    void erro(const std::string& mensagem);

    // Métodos de análise
    std::shared_ptr<Comando> analisarDeclaracao();
    std::shared_ptr<Comando> analisarComando();
    std::shared_ptr<Comando> analisarSe();
    std::shared_ptr<Comando> analisarRepita();
    std::shared_ptr<Comando> analisarEnquanto();
    std::shared_ptr<Comando> analisarComandoESP32();
    std::shared_ptr<Expressao> analisarExpressao();
    std::vector<std::shared_ptr<Comando>> analisarBlocoComandos();

public:
    explicit AnalisadorSintatico(AnalisadorLexico& lex) 
        : lexer(lex) {}

    // Retorna true se a análise foi bem sucedida
    bool analisar();

    // Getters para os comandos e tabela de símbolos
    const std::vector<std::shared_ptr<Comando>>& obter_comandos() const { return comandos; }
    const TabelaSimbolos& obter_tabela_simbolos() const { return tabela_simbolos; }
};
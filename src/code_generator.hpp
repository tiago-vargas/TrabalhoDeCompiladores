#pragma once

#include <sstream>
#include <string>
#include "parser.hpp"
#include "symbol_table.hpp"

class GeradorCodigo {
private:
    std::stringstream codigo;
    const TabelaSimbolos& tabela_simbolos;
    int nivel_indentacao = 0;
    
    void indentacao() {
        for (int i = 0; i < nivel_indentacao; i++) {
            codigo << "    ";
        }
    }
    
    void gerarCabecalho();
    void gerarIncludesESP32();
    void gerarDeclaracaoVariaveis();
    void gerarSetup(const std::vector<std::shared_ptr<Comando>>& comandos_config);
    void gerarLoop(const std::vector<std::shared_ptr<Comando>>& comandos_loop);
    
    void gerarComando(const std::shared_ptr<Comando>& comando);
    void gerarExpressao(const std::shared_ptr<Expressao>& expr);
    void gerarExpressaoBinaria(const ExpressaoBinaria& expr);
    std::string operadorBinarioParaString(OperadorBinario op);
    
public:
    explicit GeradorCodigo(const TabelaSimbolos& tabela) 
        : tabela_simbolos(tabela) {}
    
    std::string gerar(const std::vector<std::shared_ptr<Comando>>& comandos_config,
                     const std::vector<std::shared_ptr<Comando>>& comandos_loop);
};
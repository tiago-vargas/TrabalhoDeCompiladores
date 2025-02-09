#pragma once
#include "parser.hpp"
#include <iostream>

class ASTPrinter {
public:
    static void imprimir(const std::vector<std::shared_ptr<Comando>>& comandos, int nivel = 0) {
        for (const auto& comando : comandos) {
            imprimirComando(comando, nivel);
        }
    }

private:
    static void indentacao(int nivel) {
        for (int i = 0; i < nivel; i++) std::cout << "  ";
    }
    
    static void imprimirComando(const std::shared_ptr<Comando>& comando, int nivel) {
        indentacao(nivel);
        
        if (auto decl = std::dynamic_pointer_cast<ComandoDeclaracao>(comando)) {
            std::cout << "Declaração: " << decl->tipo.lexema << " ";
            for (const auto& id : decl->identificadores) {
                std::cout << id.lexema << " ";
            }
            std::cout << "\n";
        }
        else if (auto se = std::dynamic_pointer_cast<ComandoSe>(comando)) {
            std::cout << "Se\n";
            indentacao(nivel + 1);
            std::cout << "Então:\n";
            imprimir(se->comandos_verdadeiro, nivel + 2);
            if (!se->comandos_falso.empty()) {
                indentacao(nivel + 1);
                std::cout << "Senão:\n";
                imprimir(se->comandos_falso, nivel + 2);
            }
        }
        // ... outros tipos de comandos
    }

    static void imprimirExpressao(const std::shared_ptr<Expressao>& expr) {
        if (auto literal = std::dynamic_pointer_cast<ExpressaoLiteral>(expr)) {
            std::cout << literal->token.lexema;
        }
        else if (auto id = std::dynamic_pointer_cast<ExpressaoIdentificador>(expr)) {
            std::cout << id->nome.lexema;
        }
        else if (auto bin = std::dynamic_pointer_cast<ExpressaoBinaria>(expr)) {
            std::cout << "(";
            imprimirExpressao(bin->esquerda);
            switch (bin->operador) {
                case OperadorBinario::SOMA: std::cout << " + "; break;
                case OperadorBinario::SUBTRACAO: std::cout << " - "; break;
                case OperadorBinario::MULTIPLICACAO: std::cout << " * "; break;
                case OperadorBinario::DIVISAO: std::cout << " / "; break;
                case OperadorBinario::MAIOR: std::cout << " > "; break;
                case OperadorBinario::MENOR: std::cout << " < "; break;
                case OperadorBinario::MAIOR_IGUAL: std::cout << " >= "; break;
                case OperadorBinario::MENOR_IGUAL: std::cout << " <= "; break;
                case OperadorBinario::IGUAL: std::cout << " == "; break;
                case OperadorBinario::DIFERENTE: std::cout << " != "; break;
            }
            imprimirExpressao(bin->direita);
            std::cout << ")";
        }
    }
};

enum class OperadorBinario {
    SOMA,
    SUBTRACAO,
    MULTIPLICACAO,
    DIVISAO,
    MAIOR,
    MENOR,
    MAIOR_IGUAL,
    MENOR_IGUAL,
    IGUAL,
    DIFERENTE
};

class ExpressaoBinaria : public Expressao {
public:
    OperadorBinario operador;
    std::shared_ptr<Expressao> esquerda;
    std::shared_ptr<Expressao> direita;
    
    ExpressaoBinaria(OperadorBinario op, 
                     std::shared_ptr<Expressao> esq, 
                     std::shared_ptr<Expressao> dir)
        : operador(op)
        , esquerda(std::move(esq))
        , direita(std::move(dir)) {}
};
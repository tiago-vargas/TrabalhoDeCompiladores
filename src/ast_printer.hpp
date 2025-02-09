#pragma once
#include <iostream>
#include <memory>
#include <vector>
#include "ast.hpp"  // Já contém todas as definições necessárias

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
    
    static void imprimirComando(const std::shared_ptr<Comando>& comando, int nivel);
    static void imprimirExpressao(const std::shared_ptr<Expressao>& expr);
};
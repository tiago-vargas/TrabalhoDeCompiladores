#include <iostream>
#include <fstream>
#include <sstream>
#include "parser.hpp"
#include "ast_printer.hpp"
#include "code_generator.hpp"

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Uso: " << argv[0] << " arquivo.txt" << std::endl;
        return 1;
    }

    try {
        std::ifstream arquivo(argv[1]);
        if (!arquivo.is_open()) {
            std::cerr << "Erro ao abrir arquivo: " << argv[1] << std::endl;
            return 1;
        }

        std::stringstream buffer;
        buffer << arquivo.rdbuf();
        std::string codigo = buffer.str();

        AnalisadorLexico lexer(codigo);
        AnalisadorSintatico parser(lexer);
        
        auto [comandos_config, comandos_loop] = parser.analisar();
        
        // Imprime a árvore sintática
        std::cout << "Comandos de Configuração:\n";
        ASTPrinter::imprimir(comandos_config);
        std::cout << "\nComandos de Loop:\n";
        ASTPrinter::imprimir(comandos_loop);
        
        // Gera o código C++
        GeradorCodigo gerador(parser.obterTabelaSimbolos());
        std::string codigo_cpp = gerador.gerar(comandos_config, comandos_loop);
        
        std::cout << codigo_cpp;
        
        return 0;
    } catch (const std::exception& e) {
        std::cerr << "Erro: " << e.what() << std::endl;
        return 1;
    }
}
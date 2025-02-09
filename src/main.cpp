#include <iostream>
#include <fstream>
#include <sstream>
#include "parser.hpp"
#include "ast_printer.hpp"
#include "code_generator.hpp"

int main(int argc, char** argv) {
    if (argc != 2) {
        std::cerr << "Uso: " << argv[0] << " <arquivo_entrada>" << std::endl;
        return 1;
    }

    try {
        // Ler o arquivo de entrada
        std::ifstream arquivo(argv[1]);
        if (!arquivo.is_open()) {
            std::cerr << "Erro ao abrir arquivo: " << argv[1] << std::endl;
            return 1;
        }

        // Criar um stringstream para o código
        std::stringstream buffer;
        buffer << arquivo.rdbuf();
        std::string codigo = buffer.str();

        // Criar um stringstream a partir do código e passar para o lexer
        std::istringstream* input = new std::istringstream(codigo);
        AnalisadorLexico lexer(input);
        
        // Criar o analisador sintático
        AnalisadorSintatico parser(lexer);
        
        // Realizar a análise
        if (parser.analisar()) {
            std::cout << "Análise sintática concluída com sucesso!" << std::endl;
            
            // Imprimir a AST
            ASTPrinter printer;
            printer.imprimir(parser.obter_comandos());
            
            // Cria o gerador de código com a tabela de símbolos do parser
            GeradorCodigo gerador(parser.obter_tabela_simbolos());
            
            // Gera o código com os comandos obtidos do parser
            gerador.gerar(parser.obter_comandos(), parser.obter_comandos());
            
            return 0;
        } else {
            std::cerr << "Erro na análise sintática!" << std::endl;
            return 1;
        }
    } catch (const std::exception& e) {
        std::cerr << "Erro: " << e.what() << std::endl;
        return 1;
    }
}
#include <iostream>
#include <string>
#include "parser.tab.h"
#include "translator.h"

extern Node* root;
extern FILE* yyin;

int main(int argc, char** argv) {
    if (argc != 3) {
        std::cerr << "Uso: " << argv[0] << " arquivo_entrada arquivo_saida" << std::endl;
        return 1;
    }
    
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        std::cerr << "Erro ao abrir arquivo de entrada: " << argv[1] << std::endl;
        return 1;
    }
    
    yyparse();
    
    if (root) {
        Translator translator(root, argv[2]);
        
        // Mostra a árvore sintática
        std::cout << "\n=== Árvore Sintática para " << argv[1] << " ===\n";
        translator.printSyntaxTree();
        std::cout << "=====================\n\n";
        
        if (!translator.generateCode()) {
            std::cerr << "Erro durante a geração de código" << std::endl;
            return 1;
        }
    } else {
        std::cerr << "Erro: AST vazia após parsing" << std::endl;
        return 1;
    }
    
    return 0;
}
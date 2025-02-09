#include <iostream>
#include <fstream>
#include "code_generator.h"
#include "parser.tab.h"

extern ASTNode* parseTree;

int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "Uso: " << argv[0] << " arquivo_entrada arquivo_saida\n";
        return 1;
    }

    // Redirecionar entrada para o arquivo de entrada
    FILE* input = fopen(argv[1], "r");
    if (!input) {
        std::cerr << "Erro ao abrir arquivo de entrada\n";
        return 1;
    }
    
    // Fazer o parsing
    yyin = input;
    yyparse();
    fclose(input);
    
    // Gerar código
    if (parseTree) {
        CodeGenerator generator;
        std::string code = generator.generateCode(*parseTree);
        
        // Salvar código gerado
        std::ofstream outFile(argv[2]);
        if (outFile) {
            outFile << code;
            outFile.close();
            std::cout << "Código gerado com sucesso!\n";
        } else {
            std::cerr << "Erro ao criar arquivo de saída\n";
            return 1;
        }
    }
    
    return 0;
}
#ifndef CODE_GENERATOR_H
#define CODE_GENERATOR_H

#include "ast.h"
#include <string>
#include <sstream>

class CodeGenerator {
public:
    std::string generateCode(const ASTNode& root);

private:
    std::stringstream output;
    void generateDeclarations(const ASTNode& node);
    void generateConfigurations(const ASTNode& node);
    void generateCommands(const ASTNode& node);
    void generateSetup(const ASTNode& node);
    void generateLoop(const ASTNode& node);
};

#endif
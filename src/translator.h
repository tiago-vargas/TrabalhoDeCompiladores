#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include "ast.h"
#include <string>

const std::string ESP_HEADERS = "#include <Arduino.h>\n\n";

class Translator {
public:
    Translator(Node* tree, const std::string& outFile) 
        : ast(tree), outputFile(outFile) {}
    
    bool generateCode();
    void printSyntaxTree();

private:
    Node* ast;
    std::string outputFile;
    
    void printAST(Node* node, int depth = 0);
    std::string translateNode(Node* node);
    std::string translateVarDecl(Node* node);
    std::string translateConfig(Node* node);
    std::string translateRepeat(Node* node);
    std::string translateSerial(Node* node);
    std::string translatePWM(Node* node);
    std::string translateAssign(Node* node);
    std::string translateIf(Node* node);
    std::string translateWhile(Node* node);
    std::string translateDelay(Node* node);
    std::string translateExpr(Node* node);
};

#endif
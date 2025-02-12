#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <string>
#include "ast.h"

const std::string ESP_HEADERS = "#include <Arduino.h>\n\n";

class Translator {
public:
    Translator(Node* tree, const std::string& outFile) 
        : ast(tree), outputFile(outFile) {}
    
    void printAST(Node* node = nullptr, int depth = 0);
    void printSyntaxTree();
    bool generateCode();
    std::string output;

private:
    Node* ast;
    std::string outputFile;
    
    std::string translateNode(Node* node);
    std::string translateVarDecl(Node* node);
    std::string translateConfig(Node* node);
    std::string translateRepeat(Node* node);
    std::string translateSerial(Node* node);
    std::string translatePWM(Node* node);
    std::string translateGPIO(Node* node);
    std::string translateWiFi(Node* node);
    std::string translateAssign(Node* node);
    std::string translateIf(Node* node);
    std::string translateWhile(Node* node);
    std::string translateDelay(Node* node);
    std::string translateExpr(Node* node);
};

#endif
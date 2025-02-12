#include "translator.h"
#include <iostream>
#include <fstream>
#include <sstream>

void Translator::printAST(Node* node, int depth) {
    if (!node) return;
    
    std::string indent(depth * 2, ' ');
    std::cout << indent << "Nó: ";
    
    switch(node->type) {
        case NODE_PROGRAM:
            std::cout << "PROGRAMA";
            break;
        case NODE_VAR_DECL:
            std::cout << "DECLARAÇÃO";
            break;
        case NODE_CONFIG:
            std::cout << "CONFIG";
            break;
        case NODE_REPEAT:
            std::cout << "REPITA";
            break;
        case NODE_IF:
            std::cout << "SE";
            break;
        case NODE_SERIAL:
            std::cout << "SERIAL";
            break;
        case NODE_DELAY:
            std::cout << "ESPERAR";
            break;
        case NODE_PWM:
            std::cout << "PWM";
            break;
        case NODE_EXPR:
            std::cout << "EXPRESSÃO";
            break;
        case NODE_NUMBER:
            std::cout << "NÚMERO";
            break;
        case NODE_STRING:
            std::cout << "TEXTO";
            break;
        default:
            std::cout << "TIPO " << node->type;
    }
    
    if (!node->value.empty()) {
        std::cout << " [" << node->value << "]";
    }
    std::cout << std::endl;
    
    for (Node* child : node->children) {
        if (child) printAST(child, depth + 1);
    }
}

void Translator::printSyntaxTree() {
    std::cout << "\n=== Árvore Sintática ===\n";
    printAST(ast);
    std::cout << "=====================\n\n";
}

bool Translator::generateCode() {
    if (!ast) {
        std::cerr << "Erro: AST vazia\n";
        return false;
    }
    
    try {
        std::string code = ESP_HEADERS;
        
        // Variáveis globais
        if (!ast->children.empty() && ast->children[0]) {
            code += "// Variáveis globais\n";
            code += translateVarDecl(ast->children[0]);
            code += "\n";
        }
        
        // Setup
        code += "void setup() {\n";
        if (ast->children.size() > 1 && ast->children[1]) {
            code += translateConfig(ast->children[1]);
        }
        code += "}\n\n";
        
        // Loop
        code += "void loop() {\n";
        if (ast->children.size() > 2 && ast->children[2]) {
            code += translateRepeat(ast->children[2]);
        }
        code += "}\n";
        
        std::ofstream outFile(outputFile);
        if (!outFile) {
            std::cerr << "Erro ao criar arquivo de saída: " << outputFile << std::endl;
            return false;
        }
        
        outFile << code;
        outFile.close();
        
        return true;
        
    } catch (const std::exception& e) {
        std::cerr << "Erro durante a geração de código: " << e.what() << std::endl;
        return false;
    }
}

std::string Translator::translateVarDecl(Node* node) {
    if (!node) return "";
    
    std::string result;
    for (Node* child : node->children) {
        if (child && child->type == NODE_VAR_DECL) {
            std::string type = "int";
            if (!child->children.empty() && child->children[0]) {
                if (child->children[0]->value == "String") {
                    type = "String";
                }
            }
            result += type + " " + child->value + ";\n";
        }
    }
    return result;
}

std::string Translator::translateConfig(Node* node) {
    if (!node) return "";
    std::string result;
    
    for (Node* child : node->children) {
        if (!child) continue;
        result += "    " + translateNode(child) + "\n";
    }
    
    return result;
}

std::string Translator::translateRepeat(Node* node) {
    if (!node) return "";
    std::string result;
    
    for (Node* child : node->children) {
        if (!child) continue;
        result += "    " + translateNode(child) + "\n";
    }
    
    return result;
}

std::string Translator::translateNode(Node* node) {
    if (!node) return "";
    
    try {
        switch (node->type) {
            case NODE_SERIAL:
                return translateSerial(node);
            case NODE_PWM:
                return translatePWM(node);
            case NODE_ASSIGN:
                return translateAssign(node);
            case NODE_IF:
                return translateIf(node);
            case NODE_DELAY:
                return translateDelay(node);
            case NODE_EXPR:
                return translateExpr(node);
            case NODE_VAR_DECL:
                return node->value;
            case NODE_NUMBER:
            case NODE_STRING:
                return node->value;
            default:
                return "";
        }
    } catch (const std::exception& e) {
        std::cerr << "Erro ao traduzir nó: " << e.what() << std::endl;
        return "";
    }
}

std::string Translator::translateSerial(Node* node) {
    if (!node || node->children.empty()) return "";
    
    if (node->value == "configurar") {
        return "Serial.begin(" + node->children[0]->value + ");";
    } else {
        return "Serial.println(" + node->children[0]->value + ");";
    }
}

std::string Translator::translatePWM(Node* node) {
    if (!node || node->children.empty()) return "";
    
    if (node->value == "configurar" && node->children.size() >= 3) {
        return "ledcSetup(" + node->children[0]->value + ", " + 
               node->children[1]->value + ", " + 
               node->children[2]->value + ");";
    } else if (node->value == "ajustar" && node->children.size() >= 2) {
        return "ledcWrite(" + node->children[0]->value + ", " + 
               node->children[1]->value + ");";
    }
    return "";
}

std::string Translator::translateAssign(Node* node) {
    if (!node || node->children.empty()) return "";
    return node->value + " = " + node->children[0]->value + ";";
}

std::string Translator::translateIf(Node* node) {
    if (!node || node->children.empty()) return "";
    
    std::string result = "if (";
    result += translateNode(node->children[0]);
    result += ") {\n";
    
    for (size_t i = 1; i < node->children.size(); i++) {
        if (node->children[i]) {
            result += "        " + translateNode(node->children[i]) + "\n";
        }
    }
    result += "    }";
    return result;
}

std::string Translator::translateExpr(Node* node) {
    if (!node) return "";
    
    if (node->type == NODE_EXPR) {
        if (node->children.size() >= 2) {
            std::string left = translateNode(node->children[0]);
            std::string right = translateNode(node->children[1]);
            return left + " " + node->value + " " + right;
        }
    }
    return node->value;
}

std::string Translator::translateDelay(Node* node) {
    if (!node || node->children.empty()) return "";
    return "delay(" + node->children[0]->value + ");";
}
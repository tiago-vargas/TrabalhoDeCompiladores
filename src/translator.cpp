#include "translator.h"
#include <iostream>
#include <fstream>
#include <sstream>

void Translator::printAST(Node* node, int depth) {
    if (!node) return;
    
    std::string indent(depth * 2, ' ');
    std::cout << indent << "Nó: ";
    
    switch(node->type) {
        case NODE_PROGRAM: std::cout << "PROGRAMA"; break;
        case NODE_VAR_DECL: std::cout << "DECLARAÇÃO"; break;
        case NODE_CONFIG: std::cout << "CONFIG"; break;
        case NODE_REPEAT: std::cout << "REPITA"; break;
        case NODE_COMMANDS: std::cout << "COMANDOS"; break;
        case NODE_IF: std::cout << "SE"; break;
        case NODE_SERIAL: std::cout << "SERIAL"; break;
        case NODE_PWM: std::cout << "PWM"; break;
        case NODE_GPIO: std::cout << "GPIO"; break;
        case NODE_WIFI: std::cout << "WIFI"; break;
        case NODE_DELAY: std::cout << "ESPERAR"; break;
        case NODE_TYPE: std::cout << "TIPO"; break;
        case NODE_EXPR: std::cout << "EXPRESSÃO"; break;
        case NODE_NUMBER: std::cout << "NÚMERO"; break;
        case NODE_STRING: std::cout << "TEXTO"; break;
        default: std::cout << "TIPO " << node->type;
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
    printAST(ast);
}

bool Translator::generateCode() {
    if (!ast) return false;
    
    std::stringstream code;
    
    // Cabeçalho
    code << "#include <Arduino.h>\n"
         << "#include <WiFi.h>\n\n";
    
    // Declarações globais
    for (Node* child : ast->children) {
        if (child && child->type == NODE_VAR_DECL) {
            if (child->value == "inteiro") {
                for (Node* var : child->children) {
                    code << "int " << var->value << ";\n";
                }
            } else if (child->value == "texto") {
                for (Node* var : child->children) {
                    code << "String " << var->value << ";\n";
                }
            }
        }
    }
    code << "\n";
    
    // Setup
    code << "void setup() {\n";
    for (Node* child : ast->children) {
        if (child && child->type == NODE_CONFIG) {
            for (Node* cmd : child->children) {
                if (cmd && cmd->type == NODE_COMMANDS) {
                    for (Node* command : cmd->children) {
                        std::string translated = translateNode(command);
                        if (!translated.empty()) {
                            code << "    " << translated << "\n";
                        }
                    }
                }
            }
        }
    }
    code << "}\n\n";
    
    // Loop
    code << "void loop() {\n";
    for (Node* child : ast->children) {
        if (child && child->type == NODE_REPEAT) {
            for (Node* cmd : child->children) {
                if (cmd && cmd->type == NODE_COMMANDS) {
                    for (Node* command : cmd->children) {
                        std::string translated = translateNode(command);
                        if (!translated.empty()) {
                            code << "    " << translated << "\n";
                        }
                    }
                }
            }
        }
    }
    code << "}\n";
    
    output = code.str();
    
    // Debug
    std::cout << "=== Debug: Código Gerado ===" << std::endl;
    std::cout << output << std::endl;
    std::cout << "===========================" << std::endl;

    // Escrever no arquivo de saída
    std::ofstream outFile(outputFile);
    if (outFile.is_open()) {
        outFile << output;
        outFile.close();
        return true;
    }
    
    return false;
}

std::string Translator::translateNode(Node* node) {
    if (!node) return "";
    
    switch(node->type) {
        case NODE_SERIAL: return translateSerial(node);
        case NODE_PWM: return translatePWM(node);
        case NODE_GPIO: return translateGPIO(node);
        case NODE_WIFI: return translateWiFi(node);
        case NODE_DELAY: return translateDelay(node);
        case NODE_IF: return translateIf(node);
        case NODE_ASSIGN: return translateAssign(node);
        case NODE_EXPR: return translateExpr(node);
        case NODE_VAR_DECL: return node->value;
        case NODE_NUMBER: return node->value;
        case NODE_STRING: return node->value;
        default: return "";
    }
}

std::string Translator::translateVarDecl(Node* node) {
    if (!node || node->children.empty()) return "";
    
    std::string type;
    if (node->value == "inteiro") {
        type = "int";
    } else if (node->value == "texto") {
        type = "String";
    }
    
    return type + " " + node->children[0]->value + ";";
}

std::string Translator::translateSerial(Node* node) {
    if (!node || node->children.empty()) return "";
    
    if (node->value == "configurar") {
        return "Serial.begin(" + node->children[0]->value + ");";
    } else if (node->value == "escrever") {
        return "Serial.println(" + node->children[0]->value + ");";
    }
    return "";
}

std::string Translator::translatePWM(Node* node) {
    if (!node || node->children.empty()) return "";
    
    if (node->value == "configurar") {
        std::string pin = node->children[0]->value;
        std::string freq = node->children[1]->value;
        std::string res = node->children[2]->value;
        return "ledcSetup(0, " + freq + ", " + res + ");\n" +
               "    ledcAttachPin(" + pin + ", 0);";
    } else if (node->value == "ajustar") {
        std::string pin = node->children[0]->value;
        std::string val = node->children[1]->value;
        return "ledcWrite(0, " + val + ");";
    }
    return "";
}

std::string Translator::translateGPIO(Node* node) {
    if (!node || node->children.empty()) return "";
    
    std::string pin = node->children[0]->value;
    std::string mode = node->children[1]->value;
    return "pinMode(" + pin + ", " + mode + ");";
}

std::string Translator::translateWiFi(Node* node) {
    if (!node || node->children.empty()) return "";
    
    std::string ssid = node->children[0]->value;
    std::string pass = node->children[1]->value;
    return "WiFi.begin(" + ssid + ".c_str(), " + pass + ".c_str());";
}

std::string Translator::translateDelay(Node* node) {
    if (!node) return "";
    return "delay(" + node->value + ");";
}

std::string Translator::translateIf(Node* node) {
    if (!node || node->children.empty()) return "";
    
    std::string result = "if (";
    // Traduz a condição (primeiro filho)
    result += translateNode(node->children[0]);
    result += ") {\n";
    
    // Traduz o bloco then (demais filhos)
    for (size_t i = 1; i < node->children.size(); i++) {
        std::string cmd = translateNode(node->children[i]);
        if (!cmd.empty()) {
            result += "        " + cmd + "\n";
        }
    }
    result += "    }";
    return result;
}

std::string Translator::translateExpr(Node* node) {
    if (!node) return "";
    
    switch(node->type) {
        case NODE_EXPR:
            if (node->children.size() >= 2) {
                std::string left = translateNode(node->children[0]);
                std::string right = translateNode(node->children[1]);
                return left + " " + node->value + " " + right;
            }
            break;
        case NODE_VAR_DECL:
            return node->value;
        case NODE_NUMBER:
            return node->value;
    }
    return node->value;
}

std::string Translator::translateAssign(Node* node) {
    if (!node || node->children.empty()) return "";
    
    std::string var = node->value;
    std::string value;
    
    if (node->children[0]->type == NODE_STRING) {
        value = node->children[0]->value;
    } else {
        value = translateNode(node->children[0]);
    }
    
    return var + " = " + value + ";";
}
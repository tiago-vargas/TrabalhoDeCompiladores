#include "code_generator.h"

std::string CodeGenerator::generateCode(const ASTNode& root) {
    output.str("");
    
    // Gerar cabeçalho
    output << "#include <Arduino.h>\n";
    output << "#include <WiFi.h>\n\n";
    
    // Gerar declarações
    output << "// Declarações\n";
    for (const auto& child : root.children) {
        if (child->type == NodeType::DECLARATION) {
            generateDeclarations(*child);
        }
    }
    
    // Gerar setup()
    output << "\nvoid setup() {\n";
    for (const auto& child : root.children) {
        if (child->type == NodeType::CONFIGURATION) {
            generateConfigurations(*child);
        }
    }
    output << "}\n\n";
    
    // Gerar loop()
    output << "void loop() {\n";
    for (const auto& child : root.children) {
        if (child->type == NodeType::COMMAND) {
            generateCommands(*child);
        }
    }
    output << "}\n";
    
    return output.str();
}

void CodeGenerator::generateDeclarations(const ASTNode& node) {
    if (node.value == "INTEIRO") {
        output << "int " << node.children[0]->value << ";\n";
    } else if (node.value == "TEXTO") {
        output << "String " << node.children[0]->value << ";\n";
    }
}

void CodeGenerator::generateConfigurations(const ASTNode& node) {
    if (node.value == "CONFIGURAR") {
        output << "  pinMode(" << node.children[0]->value << ", OUTPUT);\n";
    } else if (node.value == "CONFIGURAR_PWM") {
        output << "  ledcSetup(0, " << node.children[0]->value << ", 8);\n";
        output << "  ledcAttachPin(" << node.children[1]->value << ", 0);\n";
    }
}

void CodeGenerator::generateCommands(const ASTNode& node) {
    if (node.value == "LIGAR") {
        output << "  digitalWrite(" << node.children[0]->value << ", HIGH);\n";
    } else if (node.value == "DESLIGAR") {
        output << "  digitalWrite(" << node.children[0]->value << ", LOW);\n";
    } else if (node.value == "AJUSTAR_PWM") {
        output << "  ledcWrite(0, " << node.children[0]->value << ");\n";
    } else if (node.value == "ESPERAR") {
        output << "  delay(" << node.children[0]->value << ");\n";
    }
}
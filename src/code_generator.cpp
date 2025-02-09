#include "code_generator.hpp"

void GeradorCodigo::gerarCabecalho() {
    codigo << "// Código gerado automaticamente\n";
    codigo << "#include <Arduino.h>\n";
    gerarIncludesESP32();
    codigo << "\n";
}

void GeradorCodigo::gerarIncludesESP32() {
    codigo << "#include <WiFi.h>\n";
    codigo << "#include <ESPmDNS.h>\n";
    codigo << "#include <WiFiUdp.h>\n";
    codigo << "#include <ArduinoOTA.h>\n";
}

void GeradorCodigo::gerarDeclaracaoVariaveis() {
    codigo << "// Declaração de variáveis globais\n";
    for (const auto& [nome, simbolo] : tabela_simbolos.obter_simbolos()) {
        switch (simbolo.tipo) {
            case TipoVariavel::INTEIRO:
                codigo << "int " << nome << ";\n";
                break;
            case TipoVariavel::BOOLEANO:
                codigo << "bool " << nome << ";\n";
                break;
            case TipoVariavel::TEXTO:
                codigo << "String " << nome << ";\n";
                break;
        }
    }
    codigo << "\n";
}

void GeradorCodigo::gerarSetup(const std::vector<std::shared_ptr<Comando>>& comandos_config) {
    codigo << "void setup() {\n";
    nivel_indentacao++;
    
    indentacao();
    codigo << "Serial.begin(115200);\n";
    
    for (const auto& comando : comandos_config) {
        gerarComando(comando);
    }
    
    nivel_indentacao--;
    codigo << "}\n\n";
}

void GeradorCodigo::gerarLoop(const std::vector<std::shared_ptr<Comando>>& comandos_loop) {
    codigo << "void loop() {\n";
    nivel_indentacao++;
    
    for (const auto& comando : comandos_loop) {
        gerarComando(comando);
    }
    
    nivel_indentacao--;
    codigo << "}\n";
}

void GeradorCodigo::gerarComando(const std::shared_ptr<Comando>& comando) {
    indentacao();
    
    if (auto decl = std::dynamic_pointer_cast<ComandoDeclaracao>(comando)) {
        // Declarações já foram tratadas globalmente
        return;
    }
    else if (auto atrib = std::dynamic_pointer_cast<ComandoAtribuicao>(comando)) {
        codigo << atrib->identificador << " = ";
        gerarExpressao(atrib->valor);
        codigo << ";\n";
    }
    else if (auto se = std::dynamic_pointer_cast<ComandoSe>(comando)) {
        codigo << "if (";
        gerarExpressao(se->condicao);
        codigo << ") {\n";
        
        nivel_indentacao++;
        for (const auto& cmd : se->comandos_verdadeiro) {
            gerarComando(cmd);
        }
        nivel_indentacao--;
        
        indentacao();
        codigo << "}\n";
        
        if (!se->comandos_falso.empty()) {
            indentacao();
            codigo << "else {\n";
            nivel_indentacao++;
            for (const auto& cmd : se->comandos_falso) {
                gerarComando(cmd);
            }
            nivel_indentacao--;
            indentacao();
            codigo << "}\n";
        }
    }
    else if (auto repita = std::dynamic_pointer_cast<ComandoRepita>(comando)) {
        codigo << "while (true) {\n";
        nivel_indentacao++;
        for (const auto& cmd : repita->comandos) {
            gerarComando(cmd);
        }
        nivel_indentacao--;
        indentacao();
        codigo << "}\n";
    }
    else if (auto enquanto = std::dynamic_pointer_cast<ComandoEnquanto>(comando)) {
        codigo << "while (";
        gerarExpressao(enquanto->condicao);
        codigo << ") {\n";
        nivel_indentacao++;
        for (const auto& cmd : enquanto->comandos) {
            gerarComando(cmd);
        }
        nivel_indentacao--;
        indentacao();
        codigo << "}\n";
    }
    else if (auto esp32 = std::dynamic_pointer_cast<ComandoESP32>(comando)) {
        switch (esp32->tipo) {
            case ComandoESP32::Tipo::CONFIGURAR_PINO:
                codigo << "pinMode(";
                gerarExpressao(esp32->parametros[0]);
                codigo << ", OUTPUT);\n";
                break;
            case ComandoESP32::Tipo::LIGAR:
                codigo << "digitalWrite(";
                gerarExpressao(esp32->parametros[0]);
                codigo << ", HIGH);\n";
                break;
            case ComandoESP32::Tipo::DESLIGAR:
                codigo << "digitalWrite(";
                gerarExpressao(esp32->parametros[0]);
                codigo << ", LOW);\n";
                break;
            // Adicionar outros comandos ESP32 conforme necessário
        }
    }
}

void GeradorCodigo::gerarExpressao(const std::shared_ptr<Expressao>& expr) {
    if (auto literal = std::dynamic_pointer_cast<ExpressaoLiteral>(expr)) {
        codigo << literal->valor;
    }
    else if (auto id = std::dynamic_pointer_cast<ExpressaoIdentificador>(expr)) {
        codigo << id->nome;
    }
    else if (auto bin = std::dynamic_pointer_cast<ExpressaoBinaria>(expr)) {
        codigo << "(";
        gerarExpressao(bin->esquerda);
        codigo << " " << operadorBinarioParaString(bin->operador) << " ";
        gerarExpressao(bin->direita);
        codigo << ")";
    }
}

std::string GeradorCodigo::operadorBinarioParaString(OperadorBinario op) {
    switch (op) {
        case OperadorBinario::SOMA: return "+";
        case OperadorBinario::SUBTRACAO: return "-";
        case OperadorBinario::MULTIPLICACAO: return "*";
        case OperadorBinario::DIVISAO: return "/";
        case OperadorBinario::MAIOR: return ">";
        case OperadorBinario::MENOR: return "<";
        case OperadorBinario::MAIOR_IGUAL: return ">=";
        case OperadorBinario::MENOR_IGUAL: return "<=";
        case OperadorBinario::IGUAL: return "==";
        case OperadorBinario::DIFERENTE: return "!=";
        default:
            throw std::runtime_error("Operador binário desconhecido");
    }
}

std::string GeradorCodigo::gerar(const std::vector<std::shared_ptr<Comando>>& comandos_config,
                                const std::vector<std::shared_ptr<Comando>>& comandos_loop) {
    codigo.str("");  // Limpa o buffer
    
    gerarCabecalho();
    gerarDeclaracaoVariaveis();
    gerarSetup(comandos_config);
    gerarLoop(comandos_loop);
    
    return codigo.str();
}
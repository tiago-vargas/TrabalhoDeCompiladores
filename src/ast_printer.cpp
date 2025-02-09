#include "ast_printer.hpp"

void ASTPrinter::imprimirComando(const std::shared_ptr<Comando>& comando, int nivel) {
    indentacao(nivel);
    
    if (auto decl = std::dynamic_pointer_cast<ComandoDeclaracao>(comando)) {
        std::cout << "Declaração: " << decl->get_tipo() << " ";
        for (const auto& id : decl->get_identificadores()) {
            std::cout << id << " ";
        }
        std::cout << "\n";
    }
    else if (auto se = std::dynamic_pointer_cast<ComandoSe>(comando)) {
        std::cout << "Se\n";
        indentacao(nivel + 1);
        std::cout << "Condição: ";
        imprimirExpressao(se->condicao);
        std::cout << "\n";
        indentacao(nivel + 1);
        std::cout << "Então:\n";
        imprimir(se->comandos_verdadeiro, nivel + 2);
        if (!se->comandos_falso.empty()) {
            indentacao(nivel + 1);
            std::cout << "Senão:\n";
            imprimir(se->comandos_falso, nivel + 2);
        }
    }
    else if (auto repita = std::dynamic_pointer_cast<ComandoRepita>(comando)) {
        std::cout << "Repita\n";
        imprimir(repita->comandos, nivel + 1);
    }
    else if (auto esp32 = std::dynamic_pointer_cast<ComandoESP32>(comando)) {
        std::cout << "Comando ESP32: ";
        switch (esp32->tipo) {
            case ComandoESP32::Tipo::CONFIGURAR_PINO:
                std::cout << "Configurar Pino ";
                break;
            case ComandoESP32::Tipo::LIGAR:
                std::cout << "Ligar ";
                break;
            case ComandoESP32::Tipo::DESLIGAR:
                std::cout << "Desligar ";
                break;
        }
        for (const auto& param : esp32->parametros) {
            imprimirExpressao(param);
            std::cout << " ";
        }
        std::cout << "\n";
    }
}

void ASTPrinter::imprimirExpressao(const std::shared_ptr<Expressao>& expr) {
    if (auto literal = std::dynamic_pointer_cast<ExpressaoLiteral>(expr)) {
        std::cout << literal->valor;
    }
    else if (auto id = std::dynamic_pointer_cast<ExpressaoIdentificador>(expr)) {
        std::cout << id->nome;
    }
    else if (auto bin = std::dynamic_pointer_cast<ExpressaoBinaria>(expr)) {
        std::cout << "(";
        imprimirExpressao(bin->esquerda);
        switch (bin->operador) {
            case OperadorBinario::SOMA: std::cout << " + "; break;
            case OperadorBinario::SUBTRACAO: std::cout << " - "; break;
            case OperadorBinario::MULTIPLICACAO: std::cout << " * "; break;
            case OperadorBinario::DIVISAO: std::cout << " / "; break;
            case OperadorBinario::MAIOR: std::cout << " > "; break;
            case OperadorBinario::MENOR: std::cout << " < "; break;
            case OperadorBinario::MAIOR_IGUAL: std::cout << " >= "; break;
            case OperadorBinario::MENOR_IGUAL: std::cout << " <= "; break;
            case OperadorBinario::IGUAL: std::cout << " == "; break;
            case OperadorBinario::DIFERENTE: std::cout << " != "; break;
        }
        imprimirExpressao(bin->direita);
        std::cout << ")";
    }
} 
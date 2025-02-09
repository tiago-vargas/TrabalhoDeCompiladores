#include "symbol_table.hpp"
#include <stdexcept>

void TabelaSimbolos::inserir(const std::string& nome, TipoVariavel tipo) {
    if (simbolos.find(nome) != simbolos.end()) {
        throw std::runtime_error("Variável já declarada: " + nome);
    }
    simbolos[nome] = Simbolo(tipo);
}

bool TabelaSimbolos::existe(const std::string& nome) const {
    return simbolos.find(nome) != simbolos.end();
}

TipoVariavel TabelaSimbolos::obter_tipo(const std::string& nome) const {
    auto it = simbolos.find(nome);
    if (it == simbolos.end()) {
        throw std::runtime_error("Variável não declarada: " + nome);
    }
    return it->second.tipo;
}

void TabelaSimbolos::marcar_inicializado(const std::string& nome) {
    auto it = simbolos.find(nome);
    if (it == simbolos.end()) {
        throw std::runtime_error("Variável não declarada: " + nome);
    }
    it->second.inicializado = true;
}

bool TabelaSimbolos::esta_inicializado(const std::string& nome) const {
    auto it = simbolos.find(nome);
    if (it == simbolos.end()) {
        throw std::runtime_error("Variável não declarada: " + nome);
    }
    return it->second.inicializado;
} 
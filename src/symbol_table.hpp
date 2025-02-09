#pragma once

#include <string>
#include <unordered_map>
#include <memory>
#include <stdexcept>
#include "token.hpp"

enum class TipoVariavel {
    INTEIRO,
    BOOLEANO,
    TEXTO
};

struct Simbolo {
    std::string nome;
    TipoVariavel tipo;
    bool inicializada;
    
    Simbolo(std::string n, TipoVariavel t)
        : nome(std::move(n)), tipo(t), inicializada(false) {}
};

class TabelaSimbolos {
private:
    std::unordered_map<std::string, std::shared_ptr<Simbolo>> simbolos;
    
public:
    void inserir(const std::string& nome, TipoVariavel tipo) {
        if (simbolos.find(nome) != simbolos.end()) {
            throw std::runtime_error("Variável '" + nome + "' já declarada");
        }
        simbolos[nome] = std::make_shared<Simbolo>(nome, tipo);
    }
    
    std::shared_ptr<Simbolo> buscar(const std::string& nome) {
        auto it = simbolos.find(nome);
        if (it == simbolos.end()) {
            throw std::runtime_error("Variável '" + nome + "' não declarada");
        }
        return it->second;
    }
    
    void marcarComoInicializada(const std::string& nome) {
        auto simbolo = buscar(nome);
        simbolo->inicializada = true;
    }
    
    bool estaInicializada(const std::string& nome) {
        auto simbolo = buscar(nome);
        return simbolo->inicializada;
    }
    
    TipoVariavel obterTipo(const std::string& nome) {
        auto simbolo = buscar(nome);
        return simbolo->tipo;
    }
};
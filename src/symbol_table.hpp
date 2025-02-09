#pragma once

#include <string>
#include <unordered_map>
#include "ast.hpp"  // Para TipoVariavel

struct Simbolo {
    TipoVariavel tipo;
    bool inicializado;
    
    Simbolo() : tipo(TipoVariavel::INTEIRO), inicializado(false) {}
    
    Simbolo(TipoVariavel t, bool init = false) 
        : tipo(t), inicializado(init) {}
};

class TabelaSimbolos {
private:
    std::unordered_map<std::string, Simbolo> simbolos;

public:
    void inserir(const std::string& nome, TipoVariavel tipo);
    bool existe(const std::string& nome) const;
    TipoVariavel obter_tipo(const std::string& nome) const;
    void marcar_inicializado(const std::string& nome);
    bool esta_inicializado(const std::string& nome) const;
    
    // Adiciona método para obter todos os símbolos
    const std::unordered_map<std::string, Simbolo>& obter_simbolos() const {
        return simbolos;
    }
};
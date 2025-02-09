#pragma once

#include <string>
#include <vector>
#include <memory>

// Forward declarations
class Expressao;
class Comando;

// Enums
enum class OperadorBinario {
    SOMA,
    SUBTRACAO,
    MULTIPLICACAO,
    DIVISAO,
    MAIOR,
    MENOR,
    MAIOR_IGUAL,
    MENOR_IGUAL,
    IGUAL,
    DIFERENTE
};

enum class TipoVariavel {
    INTEIRO,
    BOOLEANO,
    TEXTO
};

// Classes base
class Expressao {
public:
    virtual ~Expressao() = default;
};

class Comando {
public:
    virtual ~Comando() = default;
};

// Expressões
class ExpressaoLiteral : public Expressao {
public:
    std::string valor;
    
    explicit ExpressaoLiteral(std::string v) : valor(std::move(v)) {}
};

class ExpressaoIdentificador : public Expressao {
public:
    std::string nome;
    
    explicit ExpressaoIdentificador(std::string n) : nome(std::move(n)) {}
};

class ExpressaoBinaria : public Expressao {
public:
    OperadorBinario operador;
    std::shared_ptr<Expressao> esquerda;
    std::shared_ptr<Expressao> direita;
    
    ExpressaoBinaria(OperadorBinario op, 
                     std::shared_ptr<Expressao> esq, 
                     std::shared_ptr<Expressao> dir)
        : operador(op)
        , esquerda(std::move(esq))
        , direita(std::move(dir)) {}
};

// Comandos
class ComandoDeclaracao : public Comando {
public:
    TipoVariavel tipo;
    std::vector<std::string> identificadores;
    
    ComandoDeclaracao(TipoVariavel t, std::vector<std::string> ids)
        : tipo(t)
        , identificadores(std::move(ids)) {}
};

class ComandoAtribuicao : public Comando {
public:
    std::string identificador;
    std::shared_ptr<Expressao> valor;
    
    ComandoAtribuicao(std::string id, std::shared_ptr<Expressao> v)
        : identificador(std::move(id))
        , valor(std::move(v)) {}
};

class ComandoSe : public Comando {
public:
    std::shared_ptr<Expressao> condicao;
    std::vector<std::shared_ptr<Comando>> comandos_verdadeiro;
    std::vector<std::shared_ptr<Comando>> comandos_falso;
    
    ComandoSe(std::shared_ptr<Expressao> cond,
              std::vector<std::shared_ptr<Comando>> verdadeiro,
              std::vector<std::shared_ptr<Comando>> falso = {})
        : condicao(std::move(cond))
        , comandos_verdadeiro(std::move(verdadeiro))
        , comandos_falso(std::move(falso)) {}
};

class ComandoRepita : public Comando {
public:
    std::vector<std::shared_ptr<Comando>> comandos;
    
    explicit ComandoRepita(std::vector<std::shared_ptr<Comando>> cmds)
        : comandos(std::move(cmds)) {}
};

class ComandoESP32 : public Comando {
public:
    enum class Tipo {
        CONFIGURAR_PINO,
        LIGAR,
        DESLIGAR
    };
    
    Tipo tipo;
    std::vector<std::shared_ptr<Expressao>> parametros;
    
    ComandoESP32(Tipo t, std::vector<std::shared_ptr<Expressao>> params)
        : tipo(t)
        , parametros(std::move(params)) {}
};
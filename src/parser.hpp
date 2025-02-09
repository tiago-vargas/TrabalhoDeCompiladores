#pragma once

#include "token.hpp"
#include <vector>
#include <memory>
#include <stdexcept>
#include "symbol_table.hpp"

// Definição das classes para a árvore sintática abstrata (AST)
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
    Token token;
    explicit ExpressaoLiteral(Token t) : token(std::move(t)) {}
};

class ExpressaoIdentificador : public Expressao {
public:
    Token nome;
    explicit ExpressaoIdentificador(Token t) : nome(std::move(t)) {}
};

// Comandos
class ComandoDeclaracao : public Comando {
public:
    Token tipo;
    std::vector<Token> identificadores;
    
    ComandoDeclaracao(Token t, std::vector<Token> ids) 
        : tipo(std::move(t)), identificadores(std::move(ids)) {}
};

class ComandoAtribuicao : public Comando {
public:
    Token identificador;
    std::shared_ptr<Expressao> valor;
    
    ComandoAtribuicao(Token id, std::shared_ptr<Expressao> val)
        : identificador(std::move(id)), valor(std::move(val)) {}
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

class ComandoEnquanto : public Comando {
public:
    std::shared_ptr<Expressao> condicao;
    std::vector<std::shared_ptr<Comando>> comandos;
    
    ComandoEnquanto(std::shared_ptr<Expressao> cond,
                    std::vector<std::shared_ptr<Comando>> cmds)
        : condicao(std::move(cond))
        , comandos(std::move(cmds)) {}
};

class ComandoESP32 : public Comando {
public:
    enum class Tipo {
        CONFIGURAR_PINO,
        LIGAR,
        DESLIGAR,
        CONFIGURAR_PWM,
        AJUSTAR_PWM,
        ESPERAR
    };
    
    Tipo tipo;
    std::vector<std::shared_ptr<Expressao>> parametros;
    
    ComandoESP32(Tipo t, std::vector<std::shared_ptr<Expressao>> params)
        : tipo(t), parametros(std::move(params)) {}
};

class AnalisadorSintatico {
private:
    AnalisadorLexico& lexer;
    Token token_atual;
    TabelaSimbolos tabela_simbolos;
    
    Token consumir(TokenType tipo);
    bool verificar(TokenType tipo);
    Token avancar();
    
    std::shared_ptr<Comando> analisarSe();
    std::shared_ptr<Comando> analisarRepita();
    std::shared_ptr<Comando> analisarEnquanto();
    std::shared_ptr<Comando> analisarComandoESP32();
    std::vector<std::shared_ptr<Comando>> analisarBlocoComandos();
    
    TipoVariavel converterTipoToken(TokenType tipo);
    
public:
    explicit AnalisadorSintatico(AnalisadorLexico& l) : lexer(l) {
        token_atual = lexer.proximoToken();
    }
    
    std::vector<std::shared_ptr<Comando>> analisar();
    std::shared_ptr<Comando> analisarDeclaracao();
    std::shared_ptr<Comando> analisarComando();
    std::shared_ptr<Expressao> analisarExpressao();
    
    const TabelaSimbolos& obterTabelaSimbolos() const { return tabela_simbolos; }
};
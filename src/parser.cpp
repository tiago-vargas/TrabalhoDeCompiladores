#include "parser.hpp"
#include "ast.hpp"
#include <iostream>
#include <stdexcept>

// Função auxiliar para converter TokenType para TipoVariavel
TipoVariavel converterTipoToken(TokenType tipo) {
    switch (tipo) {
        case TokenType::TIPO_INTEIRO:
            return TipoVariavel::INTEIRO;
        case TokenType::TIPO_BOOLEANO:
            return TipoVariavel::BOOLEANO;
        case TokenType::TIPO_TEXTO:
            return TipoVariavel::TEXTO;
        default:
            throw std::runtime_error("Tipo de variável inválido");
    }
}

Token AnalisadorSintatico::avancar() {
    int token_type = lexer.yylex();
    if (token_type == 0) { // EOF
        token_atual = Token(TokenType::FIM_ARQUIVO, "", lexer.linha_atual());
    } else {
        token_atual = Token(static_cast<TokenType>(token_type), 
                          lexer.get_texto_token(), 
                          lexer.linha_atual());
    }
    return token_atual;
}

Token AnalisadorSintatico::consumir(TokenType tipo) {
    if (token_atual.tipo == tipo) {
        return avancar();
    }
    erro("Token inesperado");
    return token_atual;
}

bool AnalisadorSintatico::verificar(TokenType tipo) {
    return token_atual.tipo == tipo;
}

void AnalisadorSintatico::erro(const std::string& mensagem) {
    throw std::runtime_error("Erro sintático: " + mensagem);
}

bool AnalisadorSintatico::analisar() {
    try {
        avancar(); // Obtém o primeiro token
        while (token_atual.tipo != TokenType::FIM_ARQUIVO) {
            auto comando = analisarComando();
            if (comando) {
                comandos.push_back(comando);
            }
            if (verificar(TokenType::PONTO_VIRGULA)) {
                avancar();
            }
        }
        return true;
    } catch (const std::exception& e) {
        std::cerr << "Erro durante a análise: " << e.what() << std::endl;
        return false;
    }
}

std::shared_ptr<Comando> AnalisadorSintatico::analisarDeclaracao() {
    avancar(); // Consome 'var'
    Token tipo_token = consumir(TokenType::TIPO_INTEIRO);
    Token id = consumir(TokenType::IDENTIFICADOR);
    
    // Registra a variável na tabela de símbolos
    tabela_simbolos.inserir(id.lexema, converterTipoToken(tipo_token.tipo));
    
    // Cria o vetor de identificadores
    std::vector<std::string> identificadores;
    identificadores.push_back(id.lexema);
    
    // Verifica se há inicialização
    if (verificar(TokenType::IGUAL)) {
        avancar(); // Consome '='
        analisarExpressao(); // Por enquanto, apenas consome a expressão
    }
    
    return std::make_shared<ComandoDeclaracao>(
        converterTipoToken(tipo_token.tipo),
        identificadores
    );
}

std::shared_ptr<Comando> AnalisadorSintatico::analisarComando() {
    if (verificar(TokenType::IDENTIFICADOR)) {
        Token id = consumir(TokenType::IDENTIFICADOR);
        
        // Verificar se a variável foi declarada
        if (!tabela_simbolos.existe(id.lexema)) {
            throw std::runtime_error("Variável não declarada: " + id.lexema);
        }
        
        consumir(TokenType::IGUAL);
        auto expr = analisarExpressao();
        consumir(TokenType::PONTO_VIRGULA);
        
        // Marcar variável como inicializada
        tabela_simbolos.marcar_inicializado(id.lexema);
        
        return std::make_shared<ComandoAtribuicao>(id, expr);
    }
    else if (verificar(TokenType::SE)) {
        return analisarSe();
    }
    else if (verificar(TokenType::REPITA)) {
        return analisarRepita();
    }
    else if (verificar(TokenType::ENQUANTO)) {
        return analisarEnquanto();
    }
    else if (verificar(TokenType::CONFIGURAR) || 
             verificar(TokenType::LIGAR) || 
             verificar(TokenType::DESLIGAR)) {
        return analisarComandoESP32();
    }
    
    throw std::runtime_error("Comando inválido na linha " + 
                           std::to_string(token_atual.linha));
}

std::shared_ptr<Expressao> AnalisadorSintatico::analisarExpressao() {
    if (verificar(TokenType::NUMERO)) {
        return std::make_shared<ExpressaoLiteral>(consumir(TokenType::NUMERO));
    }
    if (verificar(TokenType::IDENTIFICADOR)) {
        Token id = consumir(TokenType::IDENTIFICADOR);
        
        // Verificar se a variável foi declarada
        if (!tabela_simbolos.existe(id.lexema)) {
            throw std::runtime_error("Variável não declarada: " + id.lexema);
        }
        
        return std::make_shared<ExpressaoIdentificador>(id);
    }
    
    throw std::runtime_error("Expressão inválida na linha " + 
                           std::to_string(token_atual.linha));
}

std::shared_ptr<Comando> AnalisadorSintatico::analisarSe() {
    consumir(TokenType::SE);
    auto condicao = analisarExpressao();
    consumir(TokenType::ENTAO);
    
    auto comandos_verdadeiro = analisarBlocoComandos();
    std::vector<std::shared_ptr<Comando>> comandos_falso;
    
    if (verificar(TokenType::SENAO)) {
        consumir(TokenType::SENAO);
        comandos_falso = analisarBlocoComandos();
    }
    
    consumir(TokenType::FIM);
    
    return std::make_shared<ComandoSe>(condicao, comandos_verdadeiro, comandos_falso);
}

std::shared_ptr<Comando> AnalisadorSintatico::analisarRepita() {
    consumir(TokenType::REPITA);
    auto comandos = analisarBlocoComandos();
    consumir(TokenType::FIM);
    
    return std::make_shared<ComandoRepita>(comandos);
}

std::shared_ptr<Comando> AnalisadorSintatico::analisarEnquanto() {
    consumir(TokenType::ENQUANTO);
    auto condicao = analisarExpressao();
    auto comandos = analisarBlocoComandos();
    consumir(TokenType::FIM);
    
    return std::make_shared<ComandoEnquanto>(condicao, comandos);
}

std::shared_ptr<Comando> AnalisadorSintatico::analisarComandoESP32() {
    ComandoESP32::Tipo tipo;
    std::vector<std::shared_ptr<Expressao>> parametros;
    
    if (verificar(TokenType::CONFIGURAR)) {
        consumir(TokenType::CONFIGURAR);
        tipo = ComandoESP32::Tipo::CONFIGURAR_PINO;
        
        parametros.push_back(std::make_shared<ExpressaoIdentificador>(
            consumir(TokenType::IDENTIFICADOR)));
        consumir(TokenType::COMO);
        
        if (verificar(TokenType::SAIDA)) {
            consumir(TokenType::SAIDA);
        } else {
            consumir(TokenType::ENTRADA);
        }
    }
    else if (verificar(TokenType::LIGAR)) {
        consumir(TokenType::LIGAR);
        tipo = ComandoESP32::Tipo::LIGAR;
        parametros.push_back(std::make_shared<ExpressaoIdentificador>(
            consumir(TokenType::IDENTIFICADOR)));
    }
    else if (verificar(TokenType::DESLIGAR)) {
        consumir(TokenType::DESLIGAR);
        tipo = ComandoESP32::Tipo::DESLIGAR;
        parametros.push_back(std::make_shared<ExpressaoIdentificador>(
            consumir(TokenType::IDENTIFICADOR)));
    }
    
    consumir(TokenType::PONTO_VIRGULA);
    return std::make_shared<ComandoESP32>(tipo, parametros);
}

std::vector<std::shared_ptr<Comando>> AnalisadorSintatico::analisarBlocoComandos() {
    std::vector<std::shared_ptr<Comando>> comandos;
    
    while (!verificar(TokenType::FIM) && 
           !verificar(TokenType::SENAO) && 
           !verificar(TokenType::FIM_ARQUIVO)) {
        comandos.push_back(analisarComando());
    }
    
    return comandos;
}
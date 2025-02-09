#include "parser.hpp"

Token AnalisadorSintatico::consumir(TokenType tipo) {
    if (token_atual.tipo == tipo) {
        Token token = token_atual;
        token_atual = lexer.proximoToken();
        return token;
    }
    
    throw std::runtime_error("Erro sintático: esperado token " + 
                           std::to_string(static_cast<int>(tipo)) +
                           " na linha " + std::to_string(token_atual.linha));
}

bool AnalisadorSintatico::verificar(TokenType tipo) {
    return token_atual.tipo == tipo;
}

Token AnalisadorSintatico::avancar() {
    Token token = token_atual;
    token_atual = lexer.proximoToken();
    return token;
}

std::vector<std::shared_ptr<Comando>> AnalisadorSintatico::analisar() {
    std::vector<std::shared_ptr<Comando>> comandos;
    
    while (token_atual.tipo != TokenType::FIM_ARQUIVO) {
        try {
            if (verificar(TokenType::VAR)) {
                comandos.push_back(analisarDeclaracao());
            } else {
                comandos.push_back(analisarComando());
            }
        } catch (const std::exception& e) {
            std::cerr << e.what() << std::endl;
            // Recuperação de erro: avança até encontrar um ponto e vírgula
            while (token_atual.tipo != TokenType::PONTO_VIRGULA && 
                   token_atual.tipo != TokenType::FIM_ARQUIVO) {
                avancar();
            }
            if (token_atual.tipo == TokenType::PONTO_VIRGULA) {
                avancar();
            }
        }
    }
    
    return comandos;
}

std::shared_ptr<Comando> AnalisadorSintatico::analisarDeclaracao() {
    consumir(TokenType::VAR);
    Token tipo_token = consumir(TokenType::TIPO_INTEIRO); // Por enquanto só inteiro
    consumir(TokenType::DOIS_PONTOS);
    
    std::vector<Token> identificadores;
    do {
        Token id = consumir(TokenType::IDENTIFICADOR);
        identificadores.push_back(id);
        
        // Adicionar à tabela de símbolos
        tabela_simbolos.inserir(id.lexema, converterTipoToken(tipo_token.tipo));
        
        if (!verificar(TokenType::VIRGULA)) break;
        consumir(TokenType::VIRGULA);
    } while (true);
    
    consumir(TokenType::PONTO_VIRGULA);
    
    return std::make_shared<ComandoDeclaracao>(tipo_token, identificadores);
}

std::shared_ptr<Comando> AnalisadorSintatico::analisarComando() {
    if (verificar(TokenType::IDENTIFICADOR)) {
        Token id = consumir(TokenType::IDENTIFICADOR);
        
        // Verificar se a variável foi declarada
        tabela_simbolos.buscar(id.lexema);
        
        consumir(TokenType::IGUAL);
        auto expr = analisarExpressao();
        consumir(TokenType::PONTO_VIRGULA);
        
        // Marcar variável como inicializada
        tabela_simbolos.marcarComoInicializada(id.lexema);
        
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
        tabela_simbolos.buscar(id.lexema);
        
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
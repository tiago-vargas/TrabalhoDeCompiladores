#include <iostream>
#include <string>
#include <vector>
#include <fstream>

// Definição dos tipos de tokens
enum TokenType {
    // Palavras-chave
    CONFIG,
    REPITA,
    FIM,
    VAR,
    
    // Tipos de dados
    TIPO_INTEIRO,
    TIPO_BOOLEANO,
    TIPO_TEXTO,
    
    // Símbolos
    DOIS_PONTOS,
    PONTO_VIRGULA,
    IGUAL,
    
    // Outros
    IDENTIFICADOR,
    NUMERO,
    STRING_LITERAL,
    FIM_ARQUIVO
};

// Estrutura para representar um token
struct Token {
    TokenType tipo;
    std::string lexema;
    int linha;
    
    Token(TokenType t, std::string l, int lin) : tipo(t), lexema(l), linha(lin) {}
};

class AnalisadorLexico {
private:
    std::string conteudo;
    size_t posicao;
    int linha_atual;

public:
    AnalisadorLexico(const std::string& codigo) : 
        conteudo(codigo), posicao(0), linha_atual(1) {}
    
    Token proximoToken();
    
private:
    char avancar();
    char peek();
    void pularEspacosEComentarios();
};

// Métodos auxiliares do AnalisadorLexico
char AnalisadorLexico::avancar() {
    if (posicao >= conteudo.length()) {
        return '\0';
    }
    if (conteudo[posicao] == '\n') {
        linha_atual++;
    }
    return conteudo[posicao++];
}

char AnalisadorLexico::peek() {
    if (posicao >= conteudo.length()) {
        return '\0';
    }
    return conteudo[posicao];
}

void AnalisadorLexico::pularEspacosEComentarios() {
    while (posicao < conteudo.length()) {
        char c = peek();
        
        // Pular espaços em branco
        if (isspace(c)) {
            avancar();
            continue;
        }
        
        // Pular comentários de linha
        if (c == '/' && posicao + 1 < conteudo.length() && conteudo[posicao + 1] == '/') {
            while (peek() != '\n' && peek() != '\0') {
                avancar();
            }
            continue;
        }
        
        break;
    }
}

Token AnalisadorLexico::proximoToken() {
    pularEspacosEComentarios();
    
    if (posicao >= conteudo.length()) {
        return Token(TokenType::FIM_ARQUIVO, "", linha_atual);
    }
    
    char c = peek();
    
    // Identificadores e palavras-chave
    if (isalpha(c) || c == '_') {
        std::string lexema;
        while (isalnum(peek()) || peek() == '_') {
            lexema += avancar();
        }
        
        // Verificar palavras-chave
        if (lexema == "config") return Token(TokenType::CONFIG, lexema, linha_atual);
        if (lexema == "repita") return Token(TokenType::REPITA, lexema, linha_atual);
        if (lexema == "fim") return Token(TokenType::FIM, lexema, linha_atual);
        if (lexema == "var") return Token(TokenType::VAR, lexema, linha_atual);
        if (lexema == "inteiro") return Token(TokenType::TIPO_INTEIRO, lexema, linha_atual);
        if (lexema == "booleano") return Token(TokenType::TIPO_BOOLEANO, lexema, linha_atual);
        if (lexema == "texto") return Token(TokenType::TIPO_TEXTO, lexema, linha_atual);
        
        return Token(TokenType::IDENTIFICADOR, lexema, linha_atual);
    }
    
    // Números
    if (isdigit(c)) {
        std::string numero;
        while (isdigit(peek())) {
            numero += avancar();
        }
        return Token(TokenType::NUMERO, numero, linha_atual);
    }
    
    // Strings
    if (c == '"') {
        std::string str;
        avancar(); // Consumir aspas inicial
        
        while (peek() != '"' && peek() != '\0') {
            str += avancar();
        }
        
        if (peek() == '"') {
            avancar(); // Consumir aspas final
            return Token(TokenType::STRING_LITERAL, str, linha_atual);
        } else {
            throw std::runtime_error("String não terminada na linha " + std::to_string(linha_atual));
        }
    }
    
    // Símbolos especiais
    switch (c) {
        case ':':
            avancar();
            return Token(TokenType::DOIS_PONTOS, ":", linha_atual);
        case ';':
            avancar();
            return Token(TokenType::PONTO_VIRGULA, ";", linha_atual);
        case '=':
            avancar();
            if (peek() == '=') {
                avancar();
                return Token(TokenType::IGUAL_IGUAL, "==", linha_atual);
            }
            return Token(TokenType::IGUAL, "=", linha_atual);
    }
    
    // Caractere não reconhecido
    throw std::runtime_error("Caractere inválido '" + std::string(1, c) + 
                           "' na linha " + std::to_string(linha_atual));
}

// Função principal atualizada para testar o analisador léxico
int main() {
    std::string codigo_exemplo = R"(
        var inteiro: ledPin, valor;
        
        config
            ledPin = 2;
            valor = 0;
            configurar ledPin como saida;
        fim
        
        repita
            se valor > 100 entao
                ligar ledPin;
            senao
                desligar ledPin;
            fim
            esperar 1000;
        fim
    )";
    
    try {
        AnalisadorLexico lexer(codigo_exemplo);
        AnalisadorSintatico parser(lexer);
        
        auto comandos = parser.analisar();
        
        // Imprimir a árvore sintática
        std::cout << "Árvore Sintática:\n";
        std::cout << "================\n";
        ASTPrinter::imprimir(comandos);
        std::cout << "\n";
        
        // Gerar código C++
        GeradorCodigo gerador(parser.obterTabelaSimbolos());
        std::string codigo_cpp = gerador.gerar(comandos_config, comandos_loop);
        
        std::cout << "Código C++ gerado:\n";
        std::cout << "==================\n";
        std::cout << codigo_cpp << std::endl;
        
    } catch (const std::exception& e) {
        std::cerr << "Erro: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
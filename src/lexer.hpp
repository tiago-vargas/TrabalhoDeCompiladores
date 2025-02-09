#pragma once

#if !defined(yyFlexLexerOnce)
#define yyFlexLexerOnce
#include <FlexLexer.h>
#endif

#include <string>
#include "token.hpp"

// Forward declaration
class AnalisadorLexico;

// Definição do YY_DECL
#if !defined(YY_DECL)
#define YY_DECL int AnalisadorLexico::yylex()
#endif

class AnalisadorLexico : public yyFlexLexer {
private:
    int linha_atual_val;
    std::string texto_token;

public:
    AnalisadorLexico(std::istream* in = nullptr, std::ostream* out = nullptr)
        : yyFlexLexer(in, out), linha_atual_val(1) {}
    
    virtual ~AnalisadorLexico() {}
    
    // Método que será implementado pelo Flex
    virtual int yylex();
    
    // Métodos auxiliares
    int linha_atual() const { return linha_atual_val; }
    const std::string& get_texto_token() const { return texto_token; }
    void set_texto_token(const std::string& texto) { texto_token = texto; }
};
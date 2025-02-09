/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    CONFIG = 258,                  /* CONFIG  */
    REPITA = 259,                  /* REPITA  */
    FIM = 260,                     /* FIM  */
    VAR = 261,                     /* VAR  */
    INTEIRO = 262,                 /* INTEIRO  */
    BOOLEANO = 263,                /* BOOLEANO  */
    TEXTO = 264,                   /* TEXTO  */
    SE = 265,                      /* SE  */
    ENTAO = 266,                   /* ENTAO  */
    SENAO = 267,                   /* SENAO  */
    ENQUANTO = 268,                /* ENQUANTO  */
    CONFIGURAR = 269,              /* CONFIGURAR  */
    CONFIGURAR_PWM = 270,          /* CONFIGURAR_PWM  */
    AJUSTAR_PWM = 271,             /* AJUSTAR_PWM  */
    ESPERAR = 272,                 /* ESPERAR  */
    CONECTARWIFI = 273,            /* CONECTARWIFI  */
    LIGAR = 274,                   /* LIGAR  */
    DESLIGAR = 275,                /* DESLIGAR  */
    ESCREVER_SERIAL = 276,         /* ESCREVER_SERIAL  */
    LER_SERIAL = 277,              /* LER_SERIAL  */
    ENVIAR_HTTP = 278,             /* ENVIAR_HTTP  */
    CONFIGURAR_SERIAL = 279,       /* CONFIGURAR_SERIAL  */
    LER_DIGITAL = 280,             /* LER_DIGITAL  */
    LER_ANALOGICO = 281,           /* LER_ANALOGICO  */
    ID = 282,                      /* ID  */
    NUM = 283,                     /* NUM  */
    STRING = 284,                  /* STRING  */
    IGUAL = 285,                   /* IGUAL  */
    COM_VALOR = 286,               /* COM_VALOR  */
    COMO = 287,                    /* COMO  */
    SAIDA = 288,                   /* SAIDA  */
    ENTRADA = 289,                 /* ENTRADA  */
    FREQUENCIA = 290,              /* FREQUENCIA  */
    RESOLUCAO = 291,               /* RESOLUCAO  */
    OP_REL = 292,                  /* OP_REL  */
    OP_ARIT = 293                  /* OP_ARIT  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */

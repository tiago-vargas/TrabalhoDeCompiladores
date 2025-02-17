#ifndef _SYMBOL_TABLE_H_
#define _SYMBOL_TABLE_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Tipos de variáveis
typedef enum {
    TYPE_INTEGER,
    TYPE_BOOLEAN,
    TYPE_TEXT,
    TYPE_UNKNOWN
} VarType;

// Tipos de configuração de pinos
typedef enum {
    PIN_UNDEFINED,
    PIN_INPUT,
    PIN_OUTPUT,
    PIN_PWM
} PinConfig;

// Estrutura para armazenar informações de símbolos
typedef struct symbol {
    char *name;
    VarType type;
    PinConfig pin_config;
    int declared;
    int line_declared;
    struct symbol *next;
} Symbol;

// Funções da tabela de símbolos
Symbol* symbol_table_new();
Symbol* symbol_lookup(Symbol *table, const char *name);
Symbol* symbol_add(Symbol *table, const char *name, VarType type, int line);
void symbol_set_pin_config(Symbol *table, const char *name, PinConfig config);
void symbol_table_free(Symbol *table);

// Funções auxiliares para verificação semântica
void semantic_error(const char *message, int line);
VarType get_type_from_string(const char *type_name);
const char* get_type_name(VarType type);
int check_type_compatibility(VarType left, VarType right);
int check_pin_config_for_operation(Symbol *table, const char *pin_name, PinConfig required_config, int line);

#endif 
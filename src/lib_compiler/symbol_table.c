#include "symbol_table.h"

Symbol* symbol_table_new() {
    return NULL;
}

Symbol* symbol_lookup(Symbol *table, const char *name) {
    Symbol *current = table;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

Symbol* symbol_add(Symbol *table, const char *name, VarType type, int line) {
    Symbol *sym = symbol_lookup(table, name);
    if (sym != NULL) {
        semantic_error("Variável já declarada", line);
        return table;
    }

    Symbol *new_symbol = malloc(sizeof(Symbol));
    new_symbol->name = strdup(name);
    new_symbol->type = type;
    new_symbol->pin_config = PIN_UNDEFINED;
    new_symbol->declared = 1;
    new_symbol->line_declared = line;
    new_symbol->next = table;
    
    return new_symbol;
}

void symbol_set_pin_config(Symbol *table, const char *name, PinConfig config) {
    Symbol *sym = symbol_lookup(table, name);
    if (sym != NULL) {
        sym->pin_config = config;
    }
}

void symbol_table_free(Symbol *table) {
    while (table != NULL) {
        Symbol *next = table->next;
        free(table->name);
        free(table);
        table = next;
    }
}

void semantic_error(const char *message, int line) {
    fprintf(stderr, "Erro semântico na linha %d: %s\n", line, message);
    exit(1);
}

VarType get_type_from_string(const char *type_name) {
    if (strcmp(type_name, "inteiro") == 0) return TYPE_INTEGER;
    if (strcmp(type_name, "booleano") == 0) return TYPE_BOOLEAN;
    if (strcmp(type_name, "texto") == 0) return TYPE_TEXT;
    return TYPE_UNKNOWN;
}

const char* get_type_name(VarType type) {
    switch (type) {
        case TYPE_INTEGER: return "inteiro";
        case TYPE_BOOLEAN: return "booleano";
        case TYPE_TEXT: return "texto";
        default: return "desconhecido";
    }
}

int check_type_compatibility(VarType left, VarType right) {
    return left == right;
}

int check_pin_config_for_operation(Symbol *table, const char *pin_name, PinConfig required_config, int line) {
    Symbol *sym = symbol_lookup(table, pin_name);
    if (sym == NULL) {
        semantic_error("Pino não declarado", line);
        return 0;
    }
    
    if (sym->pin_config != required_config) {
        semantic_error("Configuração de pino incompatível com a operação", line);
        return 0;
    }
    
    return 1;
} 
/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#ifndef _SYMBOL_TABLE_H_
#define _SYMBOL_TABLE_H_

#include <stdio.h>
#include "asd.h"
#include "types.h"

typedef enum {
    LITERAL,
    IDENTIFICADOR,
    FUNCAO
} Nature;

typedef struct Param {
    char *name; // Nome do parâmetro
    Type type; // Tipo
} Param;

typedef struct FuncSignature {
    int param_count; // Quantidade de parâmetros
    Param *params;  // Vetor de structs Param
} FuncSignature;

typedef struct Symbol {
    Nature nature;
    Type type;
    FuncSignature *signature; // Se não for função é NULL
    lexical_value_t *lexical_value;
} Symbol;

// Nó em uma lista encadeada de símbolos dentro de um escopo. Isso implementa uma 
// tabela de símbolos como uma lista encadeada simples.
typedef struct SymbolNode {
    Symbol symbol;
    struct SymbolNode *next;
} SymbolNode;

typedef struct Scope {
    SymbolNode *symbols;         // Topo de uma lista encadeada simples de símbolos neste escopo.
    struct Scope *prev;          // O escopo anterior na pilha de escopos.
} Scope;

void initialize_stack();
void destroy_stack();
void create_symbol_table();
void destroy_symbol_table();
void push_scope();
void pop_scope();

SymbolNode *insert_symbol(Symbol s);
SymbolNode *find_symbol(const char *name);
Symbol make_function_symbol(const char *name, Type return_type, FuncSignature *sig);
Symbol make_var_symbol(const char *name, Type type);
FuncSignature *funcsig_new(int param_count);
FuncSignature *build_func_signature(asd_tree_t *param_list_node);
void funcsig_free(FuncSignature *sig);
void insert_params_into_scope(FuncSignature *sig);

#endif //_SYMBOL_TABLE_H_
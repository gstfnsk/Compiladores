/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#include <stdio.h>
#include "asd.h"

typedef struct Scope {
    SymbolNode *symbols;         // Topo de uma lista encadeada simples de símbolos neste escopo.
    struct Scope *prev;          // O escopo anterior na pilha de escopos.
} Scope;

// O topo da pilha de escopos. Se é nulo, significa que a pilha está vazia.
static Scope *g_scope_stack_top = NULL;

// Nó em uma lista encadeada de símbolos dentro de um escopo. Isso implementa uma 
// tabela de símbolos como uma lista encadeada simples.
typedef struct SymbolNode {
    Symbol symbol;
    struct SymbolNode *next;
} SymbolNode;

typedef struct Symbol {
    Nature nature;
    Type type;
    // argumento argumentos;
    lexical_value_t *lexical_value;
} Symbol;

typedef enum {
    LITERAL,
    IDENTIFICADOR,
    FUNCAO
} Nature;

typedef enum {
    INT,
    DECIMAL
} Type;

void free_symbol_list(SymbolNode *head);
void free_one_scope(Scope *s);
void initialize_stack();
void destroy_stack();
void create_symbol_table();
void destroy_symbol_table();
void push_scope();
void pop_scope();
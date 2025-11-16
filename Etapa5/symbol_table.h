/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#ifndef _SYMBOL_TABLE_H_
#define _SYMBOL_TABLE_H_

#include <stdio.h>
#include "asd.h"
#include "types.h"

typedef enum
{
    LITERAL,
    IDENTIFICADOR,
    FUNCAO
} Nature;

typedef struct Param
{
    char *name;         // Nome do parâmetro
    Type type;          // Tipo
    struct Param *next; // Parâmetro anterior na lista
} Param;

typedef struct FuncSignature
{
    int param_count; // Quantidade de parâmetros
    Param *params;   // Vetor de structs Param
} FuncSignature;

typedef struct Arg
{
    Type type;        // Tipo do argumento
    struct Arg *next; // Próximo argumento na lista
} Arg;

typedef struct ArgList
{
    int arg_count; // Quantidade de argumentos
    Arg *args;     // Vetor de structs Arg
} ArgList;

typedef struct Symbol
{
    Nature nature;
    Type type;
    FuncSignature *signature; // Se não for função é NULL
    lexical_value_t *lexical_value;
} Symbol;

// Nó em uma lista encadeada de símbolos dentro de um escopo. Isso implementa uma
// tabela de símbolos como uma lista encadeada simples.
typedef struct SymbolNode
{
    Symbol symbol;
    struct SymbolNode *next;
} SymbolNode;

typedef struct Scope
{
    SymbolNode *symbols; // Topo de uma lista encadeada simples de símbolos neste escopo.
    struct Scope *prev;  // O escopo anterior na pilha de escopos.
} Scope;

void destroy_stack();
void push_scope();
void pop_scope();
void print_scope_stack(Scope *top);

SymbolNode *insert_symbol(Symbol s);
SymbolNode *find_symbol(const char *name);
Symbol make_function_symbol(const char *name, Type return_type, FuncSignature *sig);
FuncSignature *build_func_signature(struct Param *param_list);
Symbol make_var_symbol(const char *name, Type type);
FuncSignature *funcsig_new(int param_count);
void funcsig_free(FuncSignature *sig);
struct Param *param_new(const char *name, Type type);
void param_free(struct Param *p);
struct Arg *arg_new(Type type);
struct ArgList *argslist_new(int arg_count);
void arg_free(struct Arg *arg);
void arglist_free(struct ArgList *arglist);

#endif //_SYMBOL_TABLE_H_
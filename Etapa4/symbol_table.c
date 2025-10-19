/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#include <stdio.h>
#include <stdlib.h>
#include "symbol_table.h"

// Limpa todos os símbolos em uma lista encadeada de símbolos.
static void free_symbol_list(SymbolNode *head) {
    while (head) {
        SymbolNode *next = head->next;

        // head->symbol.lexical_value não é liberado aqui porque o código 
        // da AST é o responsável por liberar lexical_value_t em asd_free.
        free(head);

        head = next;
    }
}

// Retira da pilha e libera um único escopo.
static void free_one_scope(Scope *s) {
    if (!s) return;
    free_symbol_list(s->symbols);
    free(s);
}

void initialize_stack(void) {
    // Não tenho certeza se precisamos de uma initialize_stack, porque o escopo global pode ser inicializado com push_scope.
}

void destroy_stack(void) {
    // Retira e libera todos os escopos.
    while (g_scope_stack_top)
        pop_scope();
}

void create_symbol_table(void) {

};

void destroy_symbol_table(void) {

}

void push_scope(void) {
     Scope *s = calloc(1, sizeof(Scope));
     s->prev = g_scope_stack_top;
     g_scope_stack_top = s;
}

void pop_scope(void) {
     if (g_scope_stack_top) {
         Scope *top = g_scope_stack_top;
         g_scope_stack_top = top->prev;
         free_one_scope(top);
     }
}
/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#ifndef _ILOC_H_
#define _ILOC_H_

#include "asd.h"

// Representa uma operação ILOC
typedef struct iloc_operation {
    char *label;
    int opcode;
    char *args[3];
    char *dest;
    struct iloc_operation *prev;
    struct iloc_operation *next;
} iloc_operation;

// Representa uma lista de operações ILOC
typedef struct iloc_code {
    iloc_operation *head;
    iloc_operation *tail;
} iloc_code;

// Cria um novo nome de registrador temporário
char* new_temporary();

// Cria um novo nome de label
char* new_label();

// Cria uma nova operação ILOC
iloc_operation* create_iloc_op(const char* label, int opcode, const char* arg1, const char* arg2, const char* dest);

// Dá um append em uma lista de código
void append_op(iloc_code* code, iloc_operation* op);

// Concatena duas listas de código
iloc_code* concat_code(iloc_code* code1, iloc_code* code2);

// Imprime o código ILOC na saída padrão
void print_iloc_code(iloc_code* code);

#endif //_ILOC_H_

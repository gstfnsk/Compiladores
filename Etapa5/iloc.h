/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#ifndef _ILOC_H_
#define _ILOC_H_

#include "asd.h"

typedef enum iloc_op_code {
    // NOP
    NOP,
    // Expressões aritméticas
    ADD, SUB, MULT, DIV,
    ADDI, SUBI, RSUBI, MULTI, DIVI, RDIVI,
    // Shifts
    LSHIFT, LSHIFTI, RSHIFT, RSHIFTI,
    // Operações de memória
    LOAD, LOADAI, LOADA0,
    STORE, STOREAI, STOREA0,
    LOADI,
    // Cópia de registrador
    I2I,
    // Comparações
    CMP_LT, CMP_LE, CMP_EQ, CMP_GE, CMP_GT, CMP_NE,
    // Controle de fluxo
    CBR, JUMPI, JUMP
} iloc_op_code;

// Representa uma única operação ILOC
typedef struct iloc_operation {
    char *label;
    iloc_op_code opcode;
    // Pode ter múltiplos argumentos (ex.: add r1, r2 => r3)
    char *args[3];
    // Pode ter múltiplos destinos (ex.: cbr -> L1, L2 ou storeAI r1 => r2, c3)
    char *dest[3];
    struct iloc_operation *prev;
    struct iloc_operation *next;
} iloc_operation;

// Representa uma lista de operações ILOC
typedef struct iloc_code {
    iloc_operation *head;
    iloc_operation *tail;
} iloc_code;

// Cria um novo nome de registrador temporário (ex.: "r0", "r1")
char* new_temporary();

// Cria um novo nome de label (ex.: "L0", "L1")
char* new_label();

// Cria uma nova operação ILOC
iloc_operation* create_iloc_op(const char* label, iloc_op_code opcode, const char* arg1, const char* arg2, const char* arg3, const char* dest1, const char* dest2, const char* dest3);

// Dá um append em uma lista de código
void append_op(iloc_code* code, iloc_operation* op);

// Concatena duas listas de código
iloc_code* concat_code(iloc_code* code1, iloc_code* code2);

// Imprime o código ILOC na saída padrão
void print_iloc_code(iloc_code* code);

#endif //_ILOC_H_

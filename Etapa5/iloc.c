/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "iloc.h"

// Contadores globais para geração de nomes únicos
static int g_label_count = 0;
static int g_temporary_count = 0;

// Cria uma nova label única formatada no estilo "L0", "L1", ...
char* new_label() {
    char buffer[32];
    sprintf(buffer, "L%d", g_label_count++);
    return strdup(buffer);
}

// Cria um novo nome de registrador temporário único formatado no estilo "r0", "r1", ...
char* new_temporary() {
    char buffer[32];
    sprintf(buffer, "r%d", g_temporary_count++);
    return strdup(buffer);
}

const char* opcode_to_string[] = {
    "nop",
    "add", "sub", "mult", "div",
    "addI", "subI", "rsubI", "multI", "divI", "rdivI",
    "lshift", "lshiftI", "rshift", "rshiftI",
    "and", "or", "andI", "orI", "xori",
    "load", "loadAI", "loadA0",
    "store", "storeAI", "storeAO",
    "loadI",
    "i2i",
    "cmp_LT", "cmp_LE", "cmp_EQ", "cmp_GE", "cmp_GT", "cmp_NE",
    "cbr", "jumpI", "jump"
};

int is_single_arrow_op(iloc_op_code opcode) {
    switch (opcode) {
        case CBR:
        case JUMPI:
        case JUMP:
            return 1;
        default:
            return 0;
    }
}

iloc_operation* create_iloc_op(const char* label, iloc_op_code opcode, const char* arg1, const char* arg2, const char* arg3, const char* dest1, const char* dest2, const char* dest3) {
    iloc_operation* op = (iloc_operation*)calloc(1, sizeof(iloc_operation));
    if (label) op->label = strdup(label);
    op->opcode = opcode;
    if (arg1) op->args[0] = strdup(arg1);
    if (arg2) op->args[1] = strdup(arg2);
    if (arg3) op->args[2] = strdup(arg3);
    if (dest1) op->dest[0] = strdup(dest1);
    if (dest2) op->dest[1] = strdup(dest2);
    if (dest3) op->dest[2] = strdup(dest3);
    return op;
}

void append_op(iloc_code* code, iloc_operation* op) {
    if (!code || !op) return;

    if (code->head == NULL) {
        code->head = op;
        code->tail = op;
    } else {
        code->tail->next = op;
        op->prev = code->tail;
        code->tail = op;
    }
}

iloc_code* concat_code(iloc_code* code1, iloc_code* code2) {
    if (!code1) return code2;
    if (!code2) return code1;

    if (code1->tail) {
        code1->tail->next = code2->head;
    } else {
        code1->head = code2->head;
    }

    if (code2->head) {
        code2->head->prev = code1->tail;
    }

    if (code2->tail) {
        code1->tail = code2->tail;
    }

    free(code2);
    return code1;
}

void print_iloc_code(iloc_code* code) {
    if (!code) return;

    for (iloc_operation* op = code->head; op != NULL; op = op->next) {
        if (op->label) {
            printf("%s: ", op->label);
        }
        
        printf("%s", opcode_to_string[op->opcode]);
        
        int arg_count = 0;
        if (op->args[0]) {
            printf(" %s", op->args[0]);
            arg_count++;
        }
        if (op->args[1]) {
            printf(arg_count > 0 ? ", %s" : " %s", op->args[1]);
            arg_count++;
        }
        if (op->args[2]) {
            printf(arg_count > 0 ? ", %s" : " %s", op->args[2]);
        }

        if (op->dest[0]) {
            printf(is_single_arrow_op(op->opcode) ? " -> " : " => ");
            printf("%s", op->dest[0]);
            if (op->dest[1]) {
                printf(", %s", op->dest[1]);
            }
            if (op->dest[2]) {
                printf(", %s", op->dest[2]);
            }
        }
        printf("\n");
    }
}

void free_iloc_code(iloc_code* code) {
    if (!code) return;

    iloc_operation* current = code->head;
    while (current != NULL) {
        iloc_operation* next = current->next;

        if (current->label) free(current->label);

        for (int i = 0; i < 3; i++) {
            if (current->args[i]) free(current->args[i]);
        }

        for (int i = 0; i < 3; i++) {
            if (current->dest[i]) free(current->dest[i]);
        }

        free(current);
        current = next;
    }

    // Finalmente, libera a própria estrutura de código
    free(code);
}

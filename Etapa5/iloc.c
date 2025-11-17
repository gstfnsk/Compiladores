/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "iloc.h"

static int g_label_count = 0;
static int g_temporary_count = 0;

char* new_label() {
    char buffer[32];
    sprintf(buffer, "L%d", g_label_count++);
    return strdup(buffer);
}

char* new_temporary() {
    char buffer[32];
    sprintf(buffer, "r%d", g_temporary_count++);
    return strdup(buffer);
}

iloc_operation* create_iloc_op(const char* label, int opcode, const char* arg1, const char* arg2, const char* dest) {
    iloc_operation* op = (iloc_operation*)calloc(1, sizeof(iloc_operation));
    if (label) op->label = strdup(label);
    op->opcode = opcode;
    if (arg1) op->args[0] = strdup(arg1);
    if (arg2) op->args[1] = strdup(arg2);
    if (dest) op->dest = strdup(dest);
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
            printf("%s:", op->label);
        }

        // TODO: mapear opcodes para strings com um array ou switch.
        printf("\t_opcode%d_ ", op->opcode);

        if (op->args[0]) {
            printf("%s", op->args[0]);
        }
        if (op->args[1]) {
            printf(", %s", op->args[1]);
        }
        if (op->args[2]) {
            printf(", %s", op->args[2]);
        }

        if (op->dest) {
            // TODO: diferenciar entre ops normais e ops de controle de fluxo
            printf(" => %s", op->dest);
        }

        printf("\n");
    }
}

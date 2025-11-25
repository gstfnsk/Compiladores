/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#include "codegen.h"
#include "errors.h"
#include "types.h"
#include <stdlib.h>

asd_tree_t* handle_binary_op(const char* op_label, iloc_op_code op_code, asd_tree_t* child1, asd_tree_t* child2) {
    asd_tree_t* new_node = asd_new(op_label);
    new_node->type = child1->type;
    asd_add_child(new_node, child1);
    asd_add_child(new_node, child2);

    // Concatena o código dos filhos.
    // O nó atual (new_node) agora é o proprietário do código combinado.
    new_node->code = concat_code(child1->code, child2->code);
    child1->code = child2->code = NULL;

    // Os filhos não são mais proprietários de seus códigos, para evitar dupla liberação.
    child1->code = NULL;
    child2->code = NULL;

    char* temp_reg = new_temporary();
    iloc_operation* op = create_iloc_op(NULL, op_code, child1->temp_reg, child2->temp_reg, NULL, temp_reg, NULL, NULL);

    append_op(new_node->code, op);
    new_node->temp_reg = temp_reg;

    return new_node;
}

asd_tree_t* handle_unary_op(const char* op_label, iloc_op_code op_code, asd_tree_t* child) {
    asd_tree_t* new_node = asd_new(op_label);
    new_node->type = child->type;
    asd_add_child(new_node, child);

    // O nó atual (new_node) assume a propriedade do código do filho.
    new_node->code = child->code;
    // O filho não é mais o proprietário, para evitar dupla liberação.
    child->code = NULL;

    char* temp_reg = new_temporary();
    iloc_operation* op = create_iloc_op(NULL, op_code, child->temp_reg, NULL, NULL, temp_reg, NULL, NULL);

    append_op(new_node->code, op);
    new_node->temp_reg = temp_reg;

    return new_node;
}

/* Pequeno helper interno para if / if-else */
static void init_if_like_code(asd_tree_t *node, asd_tree_t *cond) {
    // Herda o código da expressão condicional
    node->code = cond->code;
    cond->code = NULL;

    if (!node->code) {
        node->code = calloc(1, sizeof(iloc_code));
    }
}

/* SE (sem SENAO) */
void generate_if_code(asd_tree_t *node_if, asd_tree_t *cond, asd_tree_t *then_block) {
    if (!node_if || !cond) return;

    init_if_like_code(node_if, cond);

    // Labels: L_true (then), L_false, L_end
    char *label_true = new_label();
    char *label_false = new_label();
    char *label_end = new_label();

    // cbr r_cond -> L_true, L_false
    iloc_operation *cbr_op = create_iloc_op(NULL, CBR, cond->temp_reg, NULL, NULL, label_true, label_false, NULL);
    append_op(node_if->code, cbr_op);

    // L_true: nop
    iloc_operation *then_label = create_iloc_op(label_true, NOP, NULL, NULL, NULL, NULL, NULL, NULL);
    append_op(node_if->code, then_label);

    // Código do bloco THEN
    if (then_block && then_block->code) {
        concat_code(node_if->code, then_block->code);
        then_block->code = NULL;
    }

    // L_false: nop
    iloc_operation *false_label = create_iloc_op(label_false, NOP, NULL, NULL, NULL, NULL, NULL, NULL);
    append_op(node_if->code, false_label);

    // L_end: nop (como no seu código atual)
    iloc_operation *end_label = create_iloc_op(label_end, NOP, NULL, NULL, NULL, NULL, NULL, NULL);
    append_op(node_if->code, end_label);

    free(label_true);
    free(label_false);
    free(label_end);
}

/* SE ... SENAO ... */
void generate_if_else_code(asd_tree_t *node_if, asd_tree_t *cond, asd_tree_t *then_block, asd_tree_t *else_block) {
    if (!node_if || !cond) return;

    init_if_like_code(node_if, cond);

    // Labels: L_true (then), L_false (else), L_end
    char *label_true = new_label();   // e.g. L0
    char *label_false = new_label();  // e.g. L1
    char *label_end = new_label();    // e.g. L2

    // cbr r_cond -> L_true, L_false
    iloc_operation *cbr_op = create_iloc_op(NULL, CBR, cond->temp_reg, NULL, NULL, label_true, label_false, NULL);
    append_op(node_if->code, cbr_op);

    // L_true: nop (início do bloco THEN)
    iloc_operation *l_true_op = create_iloc_op(label_true, NOP, NULL, NULL, NULL, NULL, NULL, NULL);
    append_op(node_if->code, l_true_op);

    // Código do bloco THEN
    if (then_block && then_block->code) {
        concat_code(node_if->code, then_block->code);
        then_block->code = NULL;
    }

    // jumpI -> L_end (pula o bloco ELSE)
    iloc_operation *jump_end = create_iloc_op(NULL, JUMPI, NULL, NULL, NULL, label_end, NULL, NULL);
    append_op(node_if->code, jump_end);

    // L_false: nop (início do bloco ELSE)
    iloc_operation *l_false_op = create_iloc_op(label_false, NOP, NULL, NULL, NULL, NULL, NULL, NULL);
    append_op(node_if->code, l_false_op);

    // Código do bloco ELSE
    if (else_block && else_block->code) {
        concat_code(node_if->code, else_block->code);
        else_block->code = NULL;
    }

    // L_end: nop
    iloc_operation *l_end_op = create_iloc_op(label_end, NOP, NULL, NULL, NULL, NULL, NULL, NULL);
    append_op(node_if->code, l_end_op);

    free(label_true);
    free(label_false);
    free(label_end);
}

/* ENQUANTO (...) [ corpo ] */
void generate_while_code(asd_tree_t *node_while, asd_tree_t *cond, asd_tree_t *body) {
    if (!node_while || !cond) return;

    // Inicializa código do 'enquanto'
    node_while->code = calloc(1, sizeof(iloc_code));

    // Labels: L_start (teste), L_true (corpo), L_end (saída)
    char *label_start = new_label();
    char *label_true = new_label();
    char *label_end = new_label();

    // L_start: nop (ponto de retorno do loop)
    iloc_operation *op_start = create_iloc_op(label_start, NOP, NULL, NULL, NULL, NULL, NULL, NULL);
    append_op(node_while->code, op_start);

    // Código da condição após L_start
    if (cond->code) {
        concat_code(node_while->code, cond->code);
        cond->code = NULL;
    }

    // cbr r_cond -> L_true, L_end
    iloc_operation *op_cbr = create_iloc_op(NULL, CBR, cond->temp_reg, NULL, NULL, label_true, label_end, NULL);
    append_op(node_while->code, op_cbr);

    // L_true: nop (início do corpo)
    iloc_operation *op_true = create_iloc_op(label_true, NOP, NULL, NULL, NULL, NULL, NULL, NULL);
    append_op(node_while->code, op_true);

    // Código do corpo
    if (body && body->code) {
        concat_code(node_while->code, body->code);
        body->code = NULL;
    }

    // jumpI -> L_start (volta ao teste)
    iloc_operation *op_jump = create_iloc_op(NULL, JUMPI, NULL, NULL, NULL, label_start, NULL, NULL);
    append_op(node_while->code, op_jump);

    // L_end: nop (saída do loop)
    iloc_operation *op_end = create_iloc_op(label_end, NOP, NULL, NULL, NULL, NULL, NULL, NULL);
    append_op(node_while->code, op_end);

    free(label_start);
    free(label_true);
    free(label_end);
}
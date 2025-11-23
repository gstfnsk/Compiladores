/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#include "codegen.h"
#include "errors.h"
#include "types.h"
#include <stdlib.h>

asd_tree_t* handle_binary_op(const char* op_label, iloc_op_code op_code, asd_tree_t* child1, asd_tree_t* child2, int line_number) {
    if (child1->type != child2->type) {
        throw_type_mismatch_error(line_number, child1->label, get_label_type(child1->type), child2->label, get_label_type(child2->type));

        // Chama YYABORT no parser
        return NULL; 
    }

    asd_tree_t* new_node = asd_new(op_label);
    new_node->type = child1->type;
    asd_add_child(new_node, child1);
    asd_add_child(new_node, child2);

    // Concatena o código dos filhos.
    // A função concat_code anexa o code2 ao code1 e libera a estrutura de code2.
    // O nó atual (new_node) agora é o proprietário do código combinado.
    new_node->code = child1->code;
    concat_code(new_node->code, child2->code);

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
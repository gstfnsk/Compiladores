/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#ifndef _CODEGEN_H_
#define _CODEGEN_H_

#include "asd.h"
#include "iloc.h"

asd_tree_t* handle_binary_op(const char* op_label, iloc_op_code op_code, asd_tree_t* child1, asd_tree_t* child2, int line_number);
asd_tree_t* handle_unary_op(const char* op_label, iloc_op_code op_code, asd_tree_t* child);
void generate_if_code(asd_tree_t *node_if, asd_tree_t *cond, asd_tree_t *then_block);
void generate_if_else_code(asd_tree_t *node_if, asd_tree_t *cond, asd_tree_t *then_block, asd_tree_t *else_block);
void generate_while_code(asd_tree_t *node_while, asd_tree_t *cond, asd_tree_t *body);
#endif //_CODEGEN_H_
/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#ifndef _ASD_H_
#define _ASD_H_

#include "types.h"

// Forward declaration to break circular dependency with iloc.h
struct iloc_code; 

typedef struct lexical_value {
		int line_number;
		int type;
		char *value;
	} lexical_value_t;

typedef struct asd_tree {
  char *label;
  int number_of_children;
  struct asd_tree **children;
  lexical_value_t *payload;
  Type type;
  struct iloc_code *code;
  char *temp_reg;
} asd_tree_t;

/*
 * Função asd_new, cria um nó sem filhos com o label informado.
 */
asd_tree_t *asd_new(const char *label);

/*
 * Função asd_tree, libera recursivamente o nó e seus filhos.
 */
void asd_free(asd_tree_t *tree);

/*
 * Função asd_add_child, adiciona child como filho de tree.
 */
void asd_add_child(asd_tree_t *tree, asd_tree_t *child);

/*
 * Função asd_print, imprime recursivamente a árvore.
 */
void asd_print(asd_tree_t *tree);

/*
 * Função asd_print_graphviz, idem, em formato DOT
 */
void asd_print_graphviz (asd_tree_t *tree);

void set_current_return_type(Type type);

Type get_current_return_type(void);

#endif //_ASD_H_
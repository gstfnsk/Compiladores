/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "asd.h"
#include "types.h"
#include "iloc.h"
#include "errors.h"

Type g_current_return_type = INT; // Valor padrão

asd_tree_t *asd_new(const char *label)
{
  asd_tree_t *ret = NULL;
  ret = calloc(1, sizeof(asd_tree_t));
  if (ret != NULL)
  {
    ret->label = strdup(label);
    ret->number_of_children = 0;
    ret->children = NULL;
  }
  return ret;
}

void asd_free(asd_tree_t *tree)
{
  if (tree != NULL)
  {
    int i;

    if (tree->payload != NULL)
    {
      free(tree->payload->value);
      free(tree->payload);
    }

    if (tree->code != NULL)
    {
      free_iloc_code(tree->code);
    }

    for (i = 0; i < tree->number_of_children; i++)
    {
      asd_free(tree->children[i]);
    }
    free(tree->children);
    free(tree->label);
    free(tree);
  }
  else
  {
    // printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

void asd_add_child(asd_tree_t *tree, asd_tree_t *child)
{
  if (tree != NULL && child != NULL)
  {
    tree->number_of_children++;
    tree->children = realloc(tree->children, tree->number_of_children * sizeof(asd_tree_t *));
    tree->children[tree->number_of_children - 1] = child;
  }
  else
  {
    // printf("Erro: %s recebeu parâmetro tree = %p / %p.\n", __FUNCTION__, tree, child);
  }
}

static void _asd_print(FILE *foutput, asd_tree_t *tree, int profundidade)
{
  int i;
  if (tree != NULL)
  {
    fprintf(foutput, "%d%*s: Nó '%s' tem %d filhos:\n", profundidade, profundidade * 2, "", tree->label, tree->number_of_children);
    for (i = 0; i < tree->number_of_children; i++)
    {
      _asd_print(foutput, tree->children[i], profundidade + 1);
    }
  }
  else
  {
    // printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

void asd_print(asd_tree_t *tree)
{
  FILE *foutput = stderr;
  if (tree != NULL)
  {
    _asd_print(foutput, tree, 0);
  }
  else
  {
    // printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

static void _asd_print_graphviz(FILE *foutput, asd_tree_t *tree)
{
  int i;
  if (tree != NULL)
  {
    fprintf(foutput, "  %ld [ label=\"%s\" ];\n", (long)tree, tree->label);
    for (i = 0; i < tree->number_of_children; i++)
    {
      fprintf(foutput, "  %ld -> %ld;\n", (long)tree, (long)tree->children[i]);
      _asd_print_graphviz(foutput, tree->children[i]);
    }
  }
  else
  {
    // printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

void asd_print_graphviz(asd_tree_t *tree)
{
  FILE *foutput = stdout;
  if (tree != NULL)
  {
    fprintf(foutput, "digraph grafo {\n");
    _asd_print_graphviz(foutput, tree);
    fprintf(foutput, "}\n");
  }
  else
  {
    // printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

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

    char* temp_reg = new_temporary();
    iloc_operation* op = create_iloc_op(NULL, op_code, child1->label, child2->label, NULL, temp_reg, NULL, NULL);
    
    new_node->code = calloc(1, sizeof(iloc_code));

    // O código dos filhos será agregado no nível da instrução.
    // Nós apenas adicionamos a operação para este nó específico.
    append_op(new_node->code, op);
    new_node->label = temp_reg;

    return new_node;
}

asd_tree_t* handle_unary_op(const char* op_label, asd_tree_t* child, iloc_operation* op) {
    asd_tree_t* new_node = asd_new(op_label);
    new_node->type = child->type;
    asd_add_child(new_node, child);

    char* temp_reg = new_temporary();

    // O último operando da operação é o registrador de destino.
    op->dest[0] = temp_reg;

    new_node->code = calloc(1, sizeof(iloc_code));
    
    // O código dos filhos será agregado no nível da instrução.
    // Nós apenas adicionamos a operação para este nó específico.
    append_op(new_node->code, op);
    new_node->label = temp_reg;

    return new_node;
}


void set_current_return_type(Type type)
{
  g_current_return_type = type;
};

Type get_current_return_type(void)
{
  return g_current_return_type;
};
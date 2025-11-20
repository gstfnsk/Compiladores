/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#include <stdio.h>
#include "asd.h"
#include "symbol_table.h"
#include "iloc.h"

extern int yyparse(void);
extern int yylex_destroy(void);
asd_tree_t *arvore = NULL;
int main (int argc, char **argv)
{
  int ret = yyparse();
  if (arvore) {
    print_iloc_code(arvore->code);
  }
  asd_free(arvore);
  yylex_destroy();
  destroy_stack();
  return ret;
}
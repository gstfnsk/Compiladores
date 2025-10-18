/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#include <stdio.h>
#include "asd.h"

typedef enum {
    LITERAL,
    IDENTIFICADOR,
    FUNCAO
} Nature;

typedef enum {
    INT,
    DECIMAL
} Type;

typedef struct Symbol {
    Nature natureza;
    Type tipo;
    // argumento argumentos;
    lexical_value_t *valor;
} Symbol;

void initialize_stack();
void destroy_stack();
void create_symbol_table();
void destroy_symbol_table();
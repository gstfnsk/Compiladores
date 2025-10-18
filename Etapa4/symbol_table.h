/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#include <stdio.h>
#include "asd.h"

typedef enum {
    LITERAL,
    IDENTIFICADOR,
    FUNCAO
} Natureza;

typedef enum {
    INT,
    DECIMAL
} Tipo;

typedef struct Simbolo {
    Natureza natureza;
    Tipo tipo;
    // argumento argumentos;
    valor_lexico_t *valor;
} Simbolo;

void initialize_stack();
void destroy_stack();
void create_symbol_table();
void destroy_symbol_table();
#include <stdio.h>
#include <stdlib.h>
#include "errors.h"

void throw_undeclared_error(int line, char *input)
{
    printf("[ERR_UNDECLARED] na linha %i.\n--> Identificador \"%s\" está sendo utilizado sem ser declarado.\n", line, input);
    exit(ERR_UNDECLARED);
}

void throw_already_declared_error(int line, char *input)
{
    printf("[ERR_DECLARED] Na linha %i.\n--> Tentativa de nova declaração de identificador \"%s\", o qual já foi utilizado.\n", line, input);
    exit(ERR_DECLARED);
}

void throw_var_used_as_func_error(int line, char *input){
    printf("[ERR_VARIABLE] Na linha %i.\n--> Identificador de variável \"%s\" sendo utilizado como uma função.\n", line, input);
    exit(ERR_VARIABLE);
}

void throw_func_used_as_var_error(int line, char *input){
    printf("[ERR_FUNCTION] Na linha %i.\n--> Identificador de função \"%s\" sendo utilizado como uma variável.\n", line, input);
    exit(ERR_FUNCTION);
}

void throw_type_mismatch_error(int line, char *input1, const char *type1, char *input2, const char *type2){
    printf("[ERR_WRONG_TYPE] Na linha %i.\n--> Tipo de \"%s\" = %s. \n--> Tipo de \"%s\" = %s. \n", line, input1, type1, input2, type2);
    exit(ERR_WRONG_TYPE);
}

void throw_missing_args_error(int line, char *input){
    printf("[ERR_MISSING_ARGS] Na linha %i.\n--> Número menor de argumentos que o necessário na função \"%s\".\n", line, input);
    exit(ERR_MISSING_ARGS);
}

void throw_excess_args_error(int line, char *input){
    printf("[ERR_EXCESS_ARGS] Na linha %i.\n--> Número maior de argumentos que o necessário na função \"%s\".\n", line, input);
    exit(ERR_EXCESS_ARGS);
}

void throw_mismatch_symbol_table_type_error(int line, const char *input){ // Add const
    printf("[ERR_WRONG_TYPE_ARGS] Na linha %i.\n--> Tipo dos argumento incompatível com o declarado anteriormente em \"%s\".\n", line, input);
    exit(ERR_WRONG_TYPE_ARGS);
}

void throw_mismatch_return_type_error(int line, const char *input){ // Add const
    printf("[ERR_WRONG_TYPE] Na linha %i.\n--> Tipo de retorno incompatível com o declarado anteriormente em \"%s\".\n", line, input);
    exit(ERR_WRONG_TYPE);
}
/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#define ERR_UNDECLARED       10 //2.2
#define ERR_DECLARED         11 //2.2
#define ERR_VARIABLE         20 //2.3
#define ERR_FUNCTION         21 //2.3
#define ERR_WRONG_TYPE       30 //2.4
#define ERR_MISSING_ARGS     40 //2.5
#define ERR_EXCESS_ARGS      41 //2.5
#define ERR_WRONG_TYPE_ARGS  42 //2.5

void throw_undeclared_error(int line, char *input); // Caso o identificador não tenha sido declarado no seu uso
void throw_already_declared_error(int line, char *input); // Caso o identificador já tenha sido declarado
void throw_var_used_as_func_error(int line, char *input); // Caso o identificador dito variável seja usado como uma função
void throw_func_used_as_var_error(int line, char *input); // Caso o identificador dito função seja utilizado como variável
void throw_type_mismatch_error(int line, char *input1, const char *type1, char *input2, const char *type2); // Caso haja incompatibilidade de tipos em uma operação
void throw_missing_args_error(int line, char *input); // Caso na hora da chamada da função houver um número menor de argumentos que o necessário
void throw_excess_args_error(int line, char *input); // Caso houver um número maior de argumentos que o necessário
void throw_mismatch_symbol_table_type_error(int line, const char *input); // Caso o número de argumentos seja correto, mas os tipos dos argumentos sejam incompatıveis com os tipos registrados na tabela de sımbolos
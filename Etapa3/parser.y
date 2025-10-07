/* Grupo D */
%{
#include<stdio.h>
#include "asd.h"
extern asd_tree_t *arvore;
int yylex(void);
void yyerror (char const *mensagem);
%}

%define parse.error verbose
%token TK_TIPO
%token TK_VAR
%token TK_SENAO
%token TK_DECIMAL
%token TK_SE
%token TK_INTEIRO
%token TK_ATRIB
%token TK_RETORNA
%token TK_SETA
%token TK_ENQUANTO
%token TK_COM
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_ER

%start programa

%code requires {
    typedef struct asd_tree asd_tree_t;
    typedef struct valor_lexico valor_lexico_t;
}

%union {
	valor_lexico_t *valor_lexico;
	asd_tree_t *node;
}

%token <valor_lexico> TK_ID TK_LI_INTEIRO TK_LI_DECIMAL

%type <node> programa lista elemento definicao_funcao declaracao_variavel_global cabecalho corpo
%type <node> lista_parametros lista_parametros_nao_vazia parametro bloco_comandos
%type <node> comandos_simples comandos_simples_seq comando_atribuicao chamada_funcao
%type <node> comando_retorno construcoes_fluxo_controle expressao declaracao_variavel
%type <node> operacao_binaria_or operacao_binaria_and operacao_binaria_igualdade
%type <node> operacao_binaria_relacional operacao_binaria_soma_sub lista_argumentos
%type <node> operacao_binaria_mult_div operacao_unaria operando argumento

%%

/* Um programa na linguagem é composto por uma lista opcional de elementos. 
Os elementos da lista são separados pelo operador vírgula 
e a lista é terminada pelo operador ponto-e-vírgula. */
programa: lista ';' {
    arvore = asd_new("programa");
    if ($1 != NULL) asd_add_child(arvore, $1);
    $$ = arvore;
	printf("programa nao vazio \n"); } ;

programa: %empty { $$ = NULL; printf("programa vazio \n");}; 

lista: elemento
lista: elemento ',' lista


/* Cada elemento dessa lista é ou uma definição de função 
ou uma declaração de variável. */
elemento: declaracao_variavel_global;
elemento: definicao_funcao;

/* Definição de Função: Ela possui um cabeçalho e um corpo. */
definicao_funcao: cabecalho corpo;

/* O cabeçalho consiste no token TK_ID seguido do token TK_SETA
seguido ou do token TK_DECIMAL ou do token TK_INTEIRO, 
seguido por uma lista opcional de parâmetros seguido do
token TK_ATRIB. */
cabecalho: TK_ID TK_SETA TK_DECIMAL lista_parametros TK_ATRIB {
};
cabecalho: TK_ID TK_SETA TK_INTEIRO lista_parametros TK_ATRIB {
};

/* A lista de parâmetros, quando presente, consiste no token opcional TK_COM
seguido de uma lista, separada por vírgula, de parâmetros.  */
lista_parametros: %empty { $$ = NULL; };
lista_parametros: lista_parametros_nao_vazia {} ;
lista_parametros: TK_COM lista_parametros_nao_vazia {}; 

lista_parametros_nao_vazia: parametro { $$ = $1; };
lista_parametros_nao_vazia: parametro ',' lista_parametros_nao_vazia { };

/* Cada parâmetro consiste no token TK_ID seguido do token TK_ATRIB
seguido ou do token TK_INTEIRO ou do token TK_DECIMAL. */
parametro: TK_ID TK_ATRIB TK_DECIMAL {
	
};
parametro: TK_ID TK_ATRIB TK_INTEIRO {
	
};

/*  O corpo de uma função é um bloco de comandos */
corpo: bloco_comandos { $$ = $1; };

/* Os comandos simples da linguagem podem ser:
bloco de comandos, declaração de variável, comando de atribuição, 
chamada de função, comando de retorno, e construções de fluxo de controle. */
comandos_simples: bloco_comandos { $$ = $1; };
comandos_simples: declaracao_variavel{ $$ = $1; };
comandos_simples: comando_atribuicao{ $$ = $1; };
comandos_simples: chamada_funcao{ $$ = $1; };
comandos_simples: comando_retorno{ $$ = $1; };
comandos_simples: construcoes_fluxo_controle{ $$ = $1; };

/* Bloco de Comandos: 
Definido entre colchetes, e consiste em uma sequência, possivelmente vazia,
de comandos simples. Um bloco de comandos é considerado como um comando único simples
e pode ser utilizado em qualquer construção que aceite um comando simples. */
/* bloco_comandos: '[' ']'; */

bloco_comandos: '[' comandos_simples_seq ']' {
   
}; 

comandos_simples_seq: %empty { $$ = NULL; };
comandos_simples_seq: comandos_simples comandos_simples_seq { };

/* Declaração de variável: 
Esta declaração é idêntica ao comando simples de declaração de variável
sendo que a única e importante diferença é que esse elemento não pode receber valores de inicialização. */
declaracao_variavel_global: TK_VAR TK_ID TK_ATRIB TK_DECIMAL {
};

declaracao_variavel_global: TK_VAR TK_ID TK_ATRIB TK_INTEIRO {
	
};

/* Declaração de Variável: 
Consiste no token TK_VAR seguido do token TK_ID, 
que é por sua vez seguido do token TK_ATRIB e enfim seguido do tipo. 
O tipo pode ser ou o token TK_DECIMAL ou o token TK_INTEIRO. 
Uma variável pode ser opcionalmente inicializada caso sua declaração
seja seguida do token TK_COM e de um literal. 
Um literal pode ser ou o token TK_LI_INTEIRO ou o token TK_LI_DECIMAL. */
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_DECIMAL TK_COM TK_LI_DECIMAL {
	
};
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_INTEIRO TK_COM TK_LI_INTEIRO {
	
};
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_DECIMAL { $$ = asd_new("declaracao_variavel");

};
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_INTEIRO { 
	
};

/* Comando de Atribuição: 
O comando de atribuição consiste em um token TK_ID, 
seguido do token TK_ATRIB e enfim seguido por uma expressão. */
comando_atribuicao: TK_ID TK_ATRIB expressao {
	
};

/* Chamada de Função: 
Uma chamada de função consiste no token TK_ID, seguida de argumentos entre parênteses, 
sendo que cada argumento é separado do outro por vírgula. 
Um argumento é uma expressão. Uma chamada de função pode existir sem argumentos. */
chamada_funcao: TK_ID '(' lista_argumentos ')' {
	
};

lista_argumentos: argumento ',' lista_argumentos {
	
};
lista_argumentos: argumento {
	
};
lista_argumentos: %empty { $$ = NULL; };

/* Um argumento é uma expressão. */
argumento: expressao { $$ = $1; }; 

/* TODO: separar por vírgula */

/* Comando de Retorno: 
Trata-se do token TK_RETORNA seguido de uma expressão, 
seguido do token TK_ATRIB e terminado ou pelo token TK_DECIMAL ou pelo token TK_INTEIRO. */
comando_retorno: TK_RETORNA expressao TK_ATRIB TK_DECIMAL{
	
};
comando_retorno: TK_RETORNA expressao TK_ATRIB TK_INTEIRO {
	
};

/* Comandos de Controle de Fluxo: 
A linguagem possui uma construção condicional e uma
construção iterativa para controle estruturado de fluxo. 
A condicional consiste no token TK_SE seguido de uma expressão entre parênteses 
e então por um bloco de comandos obrigatório. Após este bloco, podemos opcionalmente ter o token
TK_SENAO que, quando aparece, é seguido obrigatoriamente por um bloco de comandos. */
construcoes_fluxo_controle: TK_SE '('expressao ')' bloco_comandos {
	
};
construcoes_fluxo_controle: TK_SE '('expressao ')' bloco_comandos TK_SENAO bloco_comandos {
	
};

/* Temos apenas uma construção de repetição que é o token TK_ENQUANTO 
seguido de uma expressão entre parênteses e de um bloco de comandos. */
construcoes_fluxo_controle: TK_ENQUANTO '('expressao ')' bloco_comandos {
	
};

/* Expressões envolvem operandos e operadores, sendo este opcional. */
expressao: operacao_binaria_or { $$ = $1; };

/* Precedência 7 */
operacao_binaria_or: operacao_binaria_or '|' operacao_binaria_and {
};
operacao_binaria_or: operacao_binaria_and { $$ = $1; };

/* Precedência 6 */
operacao_binaria_and: operacao_binaria_and '&' operacao_binaria_igualdade {
};
operacao_binaria_and: operacao_binaria_igualdade { $$ = $1; }; 

/* Precedência 5 */
operacao_binaria_igualdade: operacao_binaria_igualdade TK_OC_EQ operacao_binaria_relacional {
};
operacao_binaria_igualdade: operacao_binaria_igualdade TK_OC_NE operacao_binaria_relacional {
};
operacao_binaria_igualdade: operacao_binaria_relacional { $$ = $1; };

/* Precedência 4 */
operacao_binaria_relacional: operacao_binaria_relacional '<' operacao_binaria_soma_sub {
};
operacao_binaria_relacional: operacao_binaria_relacional '>' operacao_binaria_soma_sub {
};
operacao_binaria_relacional: operacao_binaria_relacional TK_OC_LE operacao_binaria_soma_sub {
};

operacao_binaria_relacional: operacao_binaria_relacional TK_OC_GE operacao_binaria_soma_sub {
};

operacao_binaria_relacional: operacao_binaria_soma_sub { $$ = $1; };

/* Precedência 3 */
operacao_binaria_soma_sub: operacao_binaria_soma_sub '+' operacao_binaria_mult_div {
};
operacao_binaria_soma_sub: operacao_binaria_soma_sub '-' operacao_binaria_mult_div {
};
operacao_binaria_soma_sub: operacao_binaria_mult_div { $$ = $1; };

/* Precedência 2 */
operacao_binaria_mult_div: operacao_unaria { $$ = $1; } ;
operacao_binaria_mult_div: operacao_binaria_mult_div '*' operacao_unaria {
};
operacao_binaria_mult_div: operacao_binaria_mult_div '/' operacao_unaria {
};
operacao_binaria_mult_div: operacao_binaria_mult_div '%' operacao_unaria {
};

/* Precedência 1 */
operacao_unaria: operando { $$ = $1; };
operacao_unaria: '+' operacao_unaria {
};
operacao_unaria: '-' operacao_unaria {
};
operacao_unaria: '!' operacao_unaria {
};

/* Precedência 0 */
/* Os operandos podem ser identificadores, literais e 
chamada de função ou outras expressões, 
podendo portanto ser formadas recursivamente pelo emprego de operadores */
operando: TK_ID          { $$ = asd_new($1->lexema); };
operando: TK_LI_INTEIRO  { $$ = asd_new($1->lexema); };
operando: TK_LI_DECIMAL  { $$ = asd_new($1->lexema); };
operando: chamada_funcao { $$ = $1; };
operando: '(' expressao ')' {};

/* Elas também permitem o uso de parênteses para forçar
uma associatividade ou precedência diferente daquela tradicional.  */

%%

int get_line_number(void);

void yyerror (char const *mensagem)
{
	int line = get_line_number();
	printf("o erro encontrado foi [%s], na linha [%d] \n", mensagem, line);
}

%{
#include<stdio.h>
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
%token TK_ID
%token TK_LI_INTEIRO
%token TK_LI_DECIMAL
%token TK_ER

%%

/* Um programa na linguagem é composto por uma lista opcional de elementos. 
Os elementos da lista são separados pelo operador vírgula 
e a lista é terminada pelo operador ponto-e-vírgula. */
programa: lista ';';
programa: %empty; 
lista: elemento;
lista: lista ',' elemento;

/* Cada elemento dessa lista é ou uma definição de função 
ou uma declaração de variável. */
elemento: declaracao_variavel;
elemento: definicao_funcao;

/* Definição de Função: Ela possui um cabeçalho e um corpo. */
definicao_funcao: cabecalho corpo;

/* O cabeçalho consiste no token TK_ID seguido do token TK_SETA
seguido ou do token TK_DECIMAL ou do token TK_INTEIRO, 
seguido por uma lista opcional de parâmetros seguido do
token TK_ATRIB. */
cabecalho: TK_ID TK_SETA TK_DECIMAL lista_parametros TK_ATRIB;
cabecalho: TK_ID TK_SETA TK_DECIMAL TK_COM lista_parametros TK_ATRIB;
cabecalho: TK_ID TK_SETA TK_INTEIRO lista_parametros TK_ATRIB;
cabecalho: TK_ID TK_SETA TK_INTEIRO TK_COM lista_parametros TK_ATRIB;

/* A lista de parâmetros, quando presente, consiste no token opcional TK_COM
seguido de uma lista, separada por vírgula, de parâmetros.  */
lista_parametros: %empty;
lista_parametros: parametro lista_parametros_seq;

lista_parametros_seq: %empty;
lista_parametros_seq: ',' parametro lista_parametros_seq;

/* Cada parâmetro consiste no token TK_ID seguido do token TK_ATRIB
seguido ou do token TK_INTEIRO ou do token TK_DECIMAL. */
parametro: TK_ID TK_ATRIB TK_DECIMAL;
parametro: TK_ID TK_ATRIB TK_INTEIRO;

/*  O corpo de uma função é um bloco de comandos */
corpo: '[' bloco_comandos ']';

/* Os comandos simples da linguagem podem ser:
bloco de comandos, declaração de variável, comando de atribuição, 
chamada de função, comando de retorno, e construções de fluxo de controle. */
comandos_simples: '[' bloco_comandos ']';
comandos_simples: declaracao_variavel;
comandos_simples: comando_atribuicao;
comandos_simples: chamada_funcao;
comandos_simples: comando_retorno;
comandos_simples: construcoes_fluxo_controle;

comandos_simples_seq: %empty;
comandos_simples_seq: comandos_simples comandos_simples_seq;

/* Bloco de Comandos: 
Definido entre colchetes, e consiste em uma sequência, possivelmente vazia,
de comandos simples. Um bloco de comandos é considerado como um comando único simples
e pode ser utilizado em qualquer construção que aceite um comando simples. */
bloco_comandos: %empty;
bloco_comandos: comandos_simples comandos_simples_seq; 

/* Declaração de variável: 
Esta declaração é idêntica ao comando simples de declaração de variável
sendo que a única e importante diferença é que esse elemento não pode receber valores de inicialização. */
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_DECIMAL;
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_INTEIRO;

/* Declaração de Variável: 
Consiste no token TK_VAR seguido do token TK_ID, 
que é por sua vez seguido do token TK_ATRIB e enfim seguido do tipo. 
O tipo pode ser ou o token TK_DECIMAL ou o token TK_INTEIRO. 
Uma variável pode ser opcionalmente inicializada caso sua declaração
seja seguida do token TK_COM e de um literal. 
Um literal pode ser ou o token TK_LI_INTEIRO ou o token TK_LI_DECIMAL. */
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_DECIMAL TK_COM TK_LI_DECIMAL;
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_INTEIRO TK_COM TK_LI_INTEIRO;

/* Comando de Atribuição: 
O comando de atribuição consiste em um token TK_ID, 
seguido do token TK_ATRIB e enfim seguido por uma expressão. */
comando_atribuicao: TK_ID TK_ATRIB expressao;

/* Chamada de Função: 
Uma chamada de função consiste no token TK_ID, seguida de argumentos entre parênteses, 
sendo que cada argumento é separado do outro por vírgula. 
Um argumento é uma expressão. Uma chamada de função pode existir sem argumentos. */
chamada_funcao: TK_ID '(' argumentos ')';
/* TODO: separar por vírgula */

/* Comando de Retorno: 
Trata-se do token TK_RETORNA seguido de uma expressão, 
seguido do token TK_ATRIB e terminado ou pelo token TK_DECIMAL ou pelo token TK_INTEIRO. */
comando_retorno: TK_RETORNA expressao TK_ATRIB TK_DECIMAL;
comando_retorno: TK_RETORNA expressao TK_ATRIB TK_INTEIRO;

/* Comandos de Controle de Fluxo: 
A linguagem possui uma construção condicional e uma
construção iterativa para controle estruturado de fluxo. 
A condicional consiste no token TK_SE seguido de uma expressão entre parênteses 
e então por um bloco de comandos obrigatório. Após este bloco, podemos opcionalmente ter o token
TK_SENAO que, quando aparece, é seguido obrigatoriamente por um bloco de comandos. */
construcoes_fluxo_controle: TK_SE '('expressao ')' '[' bloco_comandos']';
construcoes_fluxo_controle: TK_SE '('expressao ')' '[' bloco_comandos']' TK_SENAO '[' bloco_comandos']';

/* Temos apenas uma construção de repetição que é o token TK_ENQUANTO 
seguido de uma expressão entre parênteses e de um bloco de comandos. */
construcoes_fluxo_controle: TK_ENQUANTO '('expressao ')' '[' bloco_comandos']';

/* Um argumento é uma expressão. */
argumentos: %empty;
/* argumentos: expressao; */

expressao: %empty;
/* TODO: implement expressao*/

%%

int get_line_number(void);

void yyerror (char const *mensagem)
{
	int line = get_line_number();
	printf("o erro encontrado foi [%s], na linha [%d] \n", mensagem, line);
}


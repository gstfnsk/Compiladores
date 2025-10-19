/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

%{
#include<stdio.h>
#include "asd.h"
#include "symbol_table.h"
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
    typedef struct lexical_value lexical_value_t;
}

%union {
	lexical_value_t *lexical_value;
	asd_tree_t *node;
}

%token <lexical_value> TK_ID TK_LI_INTEIRO TK_LI_DECIMAL

%type <node> programa lista elemento definicao_funcao declaracao_variavel_global cabecalho corpo
%type <node> escopo_inicio escopo_fim
%type <node> escopo_funcao_inicio escopo_funcao_fim
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
programa: escopo_inicio lista escopo_fim ';' {
    if ($2)  { arvore = $2; }
	// printf("programa nao vazio \n"); 
};

// programa: %empty {
programa: escopo_inicio escopo_fim ';' {
    arvore = NULL; 
    // printf("programa vazio \n");
}; 

// TODO: implementar escopo_inicio e escopo_fim
// Escopo global
escopo_inicio: %empty  // Cria tabela e empilha ela
{
    push_scope();
};
escopo_fim: %empty // Desempilha a tabela do topo e dá um free profundo na memória daquela tabela
{
    // Talvez dê pra chamar pop_scope() aqui e chamar o destroy_stack na main
    destroy_stack();
};

lista: elemento { $$ = $1;};
lista: elemento ',' lista {
    // printf("2\n");
    if ($1 && $3) {
        $$ = $1;
        asd_add_child($1, $3); 
    } else if ($1) {
        $$ = $1;
    } else { // não tenho certeza se precisa
        $$ = $3;
    }
};

/* Cada elemento dessa lista é ou uma definição de função 
ou uma declaração de variável. */
elemento: declaracao_variavel_global {
    $$ = $1; 
    // printf("3\n"); 
};
elemento: definicao_funcao { $$ = $1; };

/* Definição de Função: Ela possui um cabeçalho e um corpo. */
// TODO: implementar escopo_funcao_fim
// Parâmetros são variáveis locais do escopo da função, já inicializadas
// definicao_funcao: cabecalho corpo escopo_funcao_fim {
definicao_funcao: cabecalho corpo {
    if ($1) { $$ = $1; } // adiciona o cabeçalho
    if ($2) { asd_add_child($$, $2); }  // adiciona o corpo
    // printf("5\n");
};

/* O cabeçalho consiste no token TK_ID seguido do token TK_SETA
seguido ou do token TK_DECIMAL ou do token TK_INTEIRO, 
seguido por uma lista opcional de parâmetros seguido do
token TK_ATRIB. */
// TODO: implementar escopo_funcao_inicio
// cabecalho: TK_ID TK_SETA TK_DECIMAL escopo_funcao_inicio lista_parametros TK_ATRIB {
cabecalho: TK_ID TK_SETA TK_DECIMAL lista_parametros TK_ATRIB {
    // printf("6\n");
    $$ = asd_new($1->value);
    if ($4) { asd_add_child($$, $4); }          // parâmetros, se houver
    free($1->value);
    free($1);
};

cabecalho: TK_ID TK_SETA TK_INTEIRO lista_parametros TK_ATRIB {
    // printf("7\n");
    if ($1) {
        $$ = asd_new($1->value);
        free($1->value);
        free($1);
    }
    if ($4) { asd_add_child($$, $4); }         // parâmetros, se houver
};

/* A lista de parâmetros, quando presente, consiste no token opcional TK_COM
seguido de uma lista, separada por vírgula, de parâmetros.  */
lista_parametros: %empty { 
    $$ = NULL; 
    // printf("8\n"); 
};
lista_parametros: lista_parametros_nao_vazia { 
    $$ = $1; 
    // printf("9\n"); 
} ;
lista_parametros: TK_COM lista_parametros_nao_vazia { 
    $$ = $2; 
    // printf("10\n"); 
}; 

lista_parametros_nao_vazia: parametro { 
    $$ = $1; 
    // printf("11\n");
};
lista_parametros_nao_vazia: parametro ',' lista_parametros_nao_vazia {
    if ($1) { asd_add_child($$, $1); }
    if ($3) { asd_add_child($$, $3); }
 };

/* Cada parâmetro consiste no token TK_ID seguido do token TK_ATRIB
seguido ou do token TK_INTEIRO ou do token TK_DECIMAL. */
parametro: TK_ID TK_ATRIB TK_DECIMAL {
	free($1->value);
    free($1);
    $$ = NULL;
};
parametro: TK_ID TK_ATRIB TK_INTEIRO {
	free($1->value);
    free($1);
    $$ = NULL;
};

/*  O corpo de uma função é um bloco de comandos */
corpo: bloco_comandos { $$ = $1; };

/* Os comandos simples da linguagem podem ser:
bloco de comandos, declaração de variável, comando de atribuição, 
chamada de função, comando de retorno, e construções de fluxo de controle. */
comandos_simples: bloco_comandos { $$ = $1; };
comandos_simples: declaracao_variavel { $$ = $1; };
comandos_simples: comando_atribuicao { $$ = $1; };
comandos_simples: chamada_funcao { $$ = $1; };
comandos_simples: comando_retorno { $$ = $1; };
comandos_simples: construcoes_fluxo_controle { $$ = $1; };

/* Bloco de Comandos: 
Definido entre colchetes, e consiste em uma sequência, possivelmente vazia,
de comandos simples. Um bloco de comandos é considerado como um comando único simples
e pode ser utilizado em qualquer construção que aceite um comando simples. */
/* bloco_comandos: '[' ']'; */

bloco_comandos: '[' comandos_simples_seq ']' {
   $$ = $2;
}; 

comandos_simples_seq: %empty { $$ = NULL; 
// printf("dale"); 
};
comandos_simples_seq: comandos_simples comandos_simples_seq {
    if ($1 && $2) {
        asd_add_child($1, $2); 
        $$ = $1;
    } else if ($1) {
        $$ = $1;
    } else {
        $$ = $2;
    }
    };

/* Declaração de variável: 
Esta declaração é idêntica ao comando simples de declaração de variável
sendo que a única e importante diferença é que esse elemento não pode receber valores de inicialização. */
declaracao_variavel_global: TK_VAR TK_ID TK_ATRIB TK_DECIMAL {
    free($2->value);
    free($2);
    $$ = NULL;
};

declaracao_variavel_global: TK_VAR TK_ID TK_ATRIB TK_INTEIRO {
	free($2->value);
    free($2);
    $$ = NULL;
};

/* Declaração de Variável: 
Consiste no token TK_VAR seguido do token TK_ID, 
que é por sua vez seguido do token TK_ATRIB e enfim seguido do tipo. 
O tipo pode ser ou o token TK_DECIMAL ou o token TK_INTEIRO. 
Uma variável pode ser opcionalmente inicializada caso sua declaração
seja seguida do token TK_COM e de um literal. 
Um literal pode ser ou o token TK_LI_INTEIRO ou o token TK_LI_DECIMAL. */
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_DECIMAL TK_COM TK_LI_DECIMAL {
	$$ = asd_new("com");
    if ($2) {
        asd_add_child($$, asd_new($2->value));
        $$->payload = $2;
        free($2->value);
        free($2);
    }
    if ($6) {
        asd_add_child($$, asd_new($6->value));
        $$->payload = $6;
    }
};
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_INTEIRO TK_COM TK_LI_INTEIRO {
	$$ = asd_new("com");
    if ($2) {
        asd_add_child($$, asd_new($2->value));
        $$->payload = $2;
        free($2->value);
        free($2);
    }
    if ($6) {
        asd_add_child($$, asd_new($6->value));
        $$->payload = $6;
    }
};
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_DECIMAL {
    free($2->value);
    free($2);
    $$ = NULL;
};
declaracao_variavel: TK_VAR TK_ID TK_ATRIB TK_INTEIRO { 
	free($2->value);
    free($2);
    $$ = NULL;
};

/* Comando de Atribuição: 
O comando de atribuição consiste em um token TK_ID, 
seguido do token TK_ATRIB e enfim seguido por uma expressão. */
comando_atribuicao: TK_ID TK_ATRIB expressao {
	$$ = asd_new(":="); 
    if($1) { asd_add_child($$, asd_new($1->value)); }
    if($3) { asd_add_child($$, $3); }
    $$->payload = $1;
};

/* Chamada de Função: 
Uma chamada de função consiste no token TK_ID, seguida de argumentos entre parênteses, 
sendo que cada argumento é separado do outro por vírgula. 
Um argumento é uma expressão. Uma chamada de função pode existir sem argumentos. */
chamada_funcao: TK_ID '(' lista_argumentos ')' {
	if($1){
        char nome[256];
        snprintf(nome, sizeof(nome), "call %s", $1->value);
        $$ = asd_new(nome);
        if($3){ asd_add_child($$, $3); }
        $$->payload = $1;
    };
};

lista_argumentos: argumento ',' lista_argumentos {
	$$ = $1;
    if($3){ asd_add_child($$, $3); }
};
lista_argumentos: argumento {
	$$ = $1;
};
lista_argumentos: %empty { $$ = NULL; };

/* Um argumento é uma expressão. */
argumento: expressao { $$ = $1; }; 

/* Comando de Retorno: 
Trata-se do token TK_RETORNA seguido de uma expressão, 
seguido do token TK_ATRIB e terminado ou pelo token TK_DECIMAL ou pelo token TK_INTEIRO. */
comando_retorno: TK_RETORNA expressao TK_ATRIB TK_DECIMAL{
	$$ = asd_new("retorna");
    if($2){ asd_add_child($$, $2); }
};
comando_retorno: TK_RETORNA expressao TK_ATRIB TK_INTEIRO {
	$$ = asd_new("retorna");
    if($2){ asd_add_child($$, $2); }
};

/* Comandos de Controle de Fluxo: 
A linguagem possui uma construção condicional e uma
construção iterativa para controle estruturado de fluxo. 
A condicional consiste no token TK_SE seguido de uma expressão entre parênteses 
e então por um bloco de comandos obrigatório. Após este bloco, podemos opcionalmente ter o token
TK_SENAO que, quando aparece, é seguido obrigatoriamente por um bloco de comandos. */
construcoes_fluxo_controle: TK_SE '('expressao ')' bloco_comandos {
    $$ = asd_new("se");
    if($3){ asd_add_child($$, $3); }
    if($5){ asd_add_child($$, $5); }
};
construcoes_fluxo_controle: TK_SE '('expressao ')' bloco_comandos TK_SENAO bloco_comandos {
	$$ = asd_new("se");
    if($3){ asd_add_child($$, $3); }
    if($5){ asd_add_child($$, $5); }
    if($7){ asd_add_child($$, $7); }
};

/* Temos apenas uma construção de repetição que é o token TK_ENQUANTO 
seguido de uma expressão entre parênteses e de um bloco de comandos. */
construcoes_fluxo_controle: TK_ENQUANTO '('expressao ')' bloco_comandos {
	$$ = asd_new("enquanto");
    if($3){ asd_add_child($$, $3); }
    if($5){ asd_add_child($$, $5); }
};

/* Expressões envolvem operandos e operadores, sendo este opcional. */
expressao: operacao_binaria_or { $$ = $1; };

/* Precedência 7 */
operacao_binaria_or: operacao_binaria_or '|' operacao_binaria_and {
        $$ = asd_new("|");
        if($1){ asd_add_child($$, $1); }
        if($3){ asd_add_child($$, $3); }
};
operacao_binaria_or: operacao_binaria_and { $$ = $1; };

/* Precedência 6 */
operacao_binaria_and: operacao_binaria_and '&' operacao_binaria_igualdade {
    $$ = asd_new("&");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }
};
operacao_binaria_and: operacao_binaria_igualdade { $$ = $1; }; 

/* Precedência 5 */
operacao_binaria_igualdade: operacao_binaria_igualdade TK_OC_EQ operacao_binaria_relacional {
    $$ = asd_new("==");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }
};
operacao_binaria_igualdade: operacao_binaria_igualdade TK_OC_NE operacao_binaria_relacional {
    $$ = asd_new("!=");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }

};
operacao_binaria_igualdade: operacao_binaria_relacional { $$ = $1; };

/* Precedência 4 */
operacao_binaria_relacional: operacao_binaria_relacional '<' operacao_binaria_soma_sub {
    $$ = asd_new("<");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }
};
operacao_binaria_relacional: operacao_binaria_relacional '>' operacao_binaria_soma_sub {
    $$ = asd_new(">");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }
};
operacao_binaria_relacional: operacao_binaria_relacional TK_OC_LE operacao_binaria_soma_sub {
    $$ = asd_new("<=");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }
};
operacao_binaria_relacional: operacao_binaria_relacional TK_OC_GE operacao_binaria_soma_sub {
    $$ = asd_new(">=");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }
};
operacao_binaria_relacional: operacao_binaria_soma_sub { $$ = $1; };

/* Precedência 3 */
operacao_binaria_soma_sub: operacao_binaria_soma_sub '+' operacao_binaria_mult_div {
    $$ = asd_new("+");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }
};
operacao_binaria_soma_sub: operacao_binaria_soma_sub '-' operacao_binaria_mult_div {
    $$ = asd_new("-");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }
};
operacao_binaria_soma_sub: operacao_binaria_mult_div { $$ = $1; };

/* Precedência 2 */
operacao_binaria_mult_div: operacao_unaria { $$ = $1; } ;
operacao_binaria_mult_div: operacao_binaria_mult_div '*' operacao_unaria {
    $$ = asd_new("*");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }
};
operacao_binaria_mult_div: operacao_binaria_mult_div '/' operacao_unaria {
    $$ = asd_new("/");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }
};
operacao_binaria_mult_div: operacao_binaria_mult_div '%' operacao_unaria {
    $$ = asd_new("%");
    if($1){ asd_add_child($$, $1); }
    if($3){ asd_add_child($$, $3); }
};

/* Precedência 1 */
operacao_unaria: operando { $$ = $1; };
operacao_unaria: '+' operacao_unaria {
    $$ = asd_new("+");
    if($2){ asd_add_child($$, $2); }
};
operacao_unaria: '-' operacao_unaria {
    $$ = asd_new("-");
    if($2){ asd_add_child($$, $2); }
};
operacao_unaria: '!' operacao_unaria {
    $$ = asd_new("!");
    if($2){ asd_add_child($$, $2); }
};

/* Precedência 0 */
/* Os operandos podem ser identificadores, literais e 
chamada de função ou outras expressões, 
podendo portanto ser formadas recursivamente pelo emprego de operadores */
operando: TK_ID { $$ = asd_new($1->value); $$->payload = $1;}; // TODO: Verificar se foi declarado
operando: TK_LI_INTEIRO { $$ = asd_new($1->value); $$->payload = $1;};
operando: TK_LI_DECIMAL { $$ = asd_new($1->value); $$->payload = $1; };
operando: chamada_funcao { $$ = $1; };
operando: '(' expressao ')' { $$ = $2; };

/* Elas também permitem o uso de parênteses para forçar
uma associatividade ou precedência diferente daquela tradicional.  */

%%

int get_line_number(void);

void yyerror (char const *mensagem)
{
	int line = get_line_number();
	printf("o erro encontrado foi [%s], na linha [%d] \n", mensagem, line);
}

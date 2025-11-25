/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

%{
#include<stdio.h>
#include "errors.h"
#include "asd.h"
#include <stdlib.h>
#include "symbol_table.h"
#include "types.h"
#include "codegen.h"
#include "iloc.h"
extern asd_tree_t *arvore;
int yylex(void);
void yyerror (char const *mensagem);
int get_line_number(void);
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
    typedef struct Param param_t;
    typedef struct ArgList args_list_t;
    typedef struct Arg arg_t;
    #include "types.h"
    typedef Type type_t;
}

%union {
	lexical_value_t *lexical_value;
	asd_tree_t *node;
    param_t *param;
    args_list_t *arg_list;
    arg_t *arg;
    type_t type;
}

%token <lexical_value> TK_ID TK_LI_INTEIRO TK_LI_DECIMAL

%type <param> parametro lista_parametros lista_parametros_nao_vazia 

%type <arg_list> lista_argumentos
%type <arg> argumento

%type <type> tipo

%type <node> programa lista elemento definicao_funcao declaracao_variavel_global corpo
%type <node> escopo_inicio escopo_fim
%type <node> bloco_comandos bloco_comandos_funcao
%type <node> comandos_simples comandos_simples_seq comando_atribuicao chamada_funcao
%type <node> comando_retorno construcoes_fluxo_controle expressao declaracao_variavel
%type <node> operacao_binaria_or operacao_binaria_and operacao_binaria_igualdade
%type <node> operacao_binaria_relacional operacao_binaria_soma_sub
%type <node> operacao_binaria_mult_div operacao_unaria operando 
%%

/* Um programa na linguagem é composto por uma lista opcional de elementos. 
Os elementos da lista são separados pelo operador vírgula 
e a lista é terminada pelo operador ponto-e-vírgula. */
programa: escopo_inicio lista escopo_fim ';' { 
    if ($2) { arvore = $2; }
};

programa: ';' {
    arvore = NULL; 
}; 

// TODO: implementar escopo_inicio e escopo_fim
// Escopo global
escopo_inicio: %empty  // Cria tabela e empilha ela
{
    push_scope();
};
escopo_fim: %empty // Desempilha a tabela do topo e dá um free profundo na memória daquela tabela
{
    pop_scope();
};

lista: elemento { $$ = $1;};
lista: elemento ',' lista {
    if ($1 && $3) {
        $$ = $1;
        asd_add_child($1, $3); 

        // Propaga/concatena o código entre os elementos da lista
        if ($1->code && $3->code) {
            concat_code($1->code, $3->code);
            $3->code = NULL;
        } else if (!$1->code && $3->code) {
            $1->code = $3->code;
            $3->code = NULL;
        }
        // se só $1 tem código, não precisamos fazer nada

    } else if ($1) {
        $$ = $1;
    } else { 
        $$ = $3;
    }
};

/* Cada elemento dessa lista é ou uma definição de função 
ou uma declaração de variável. */
elemento: declaracao_variavel_global {
    $$ = $1; 
};
elemento: definicao_funcao { $$ = $1; };

/* Definição de Função: Ela possui um cabeçalho e um corpo. */
// TODO: implementar escopo_funcao_fim
// Parâmetros são variáveis locais do escopo da função, já inicializadas

/* O cabeçalho consiste no token TK_ID seguido do token TK_SETA
seguido ou do token TK_DECIMAL ou do token TK_INTEIRO, 
seguido por uma lista opcional de parâmetros seguido do
token TK_ATRIB. */

tipo: TK_INTEIRO { $$ = INT; };
tipo: TK_DECIMAL { $$ = FLOAT; };

definicao_funcao: TK_ID TK_SETA tipo {
    SymbolNode *s_exists = find_symbol($1->value);
    if (s_exists && s_exists->symbol.nature == FUNCAO) {
        throw_already_declared_error($1->line_number, $1->value);
        YYABORT;
    }
    // O símbolo da função é inserido antes de processar os parâmetros e o corpo
    // para permitir a recursão. A assinatura será preenchida depois.
    Symbol func = make_function_symbol($1->value, $3, NULL); 
    insert_symbol(func);
} escopo_inicio lista_parametros TK_ATRIB {
    // Agora que os parâmetros foram processados, encontramos o símbolo da função
    // e finalmente anexamos a assinatura completa a ele.
    SymbolNode *s_func = find_function_symbol($1->value);
    s_func->symbol.signature = build_func_signature($6);
    set_current_return_type($3);
} corpo {
    // Constrói nó da AST
    $$ = asd_new($1->value);
    $$->type = $3; // Define o tipo de retorno da função
    asd_add_child($$, $9);

    // Propaga o código gerado no corpo da função para o nó da função.
    $$->code = $9->code;
    $9->code = NULL;

    free($1->value);
    free($1);
};

/* A lista de parâmetros, quando presente, consiste no token opcional TK_COM
seguido de uma lista, separada por vírgula, de parâmetros.  */
lista_parametros: %empty { 
    $$ = NULL; 
};

lista_parametros: lista_parametros_nao_vazia { 
    $$ = $1; 
} ;
lista_parametros: TK_COM lista_parametros_nao_vazia { 
    $$ = $2; 
}; 

lista_parametros_nao_vazia: parametro { 
    $$ = $1; 
};
lista_parametros_nao_vazia: parametro ',' lista_parametros_nao_vazia {
    $1->next = $3;
    $$ = $1;
 };

/* Cada parâmetro consiste no token TK_ID seguido do token TK_ATRIB
seguido ou do token TK_INTEIRO ou do token TK_DECIMAL. */
parametro: TK_ID TK_ATRIB tipo {
    SymbolNode *s_exists = find_symbol($1->value);
    if (s_exists && s_exists->symbol.nature == IDENTIFICADOR) {
        throw_already_declared_error($1->line_number, $1->value);
        YYABORT;
    }
    Symbol param = make_var_symbol($1->value, $3);
    insert_symbol(param);
    $$ = param_new($1->value, $3);
    free($1->value);
    free($1);
    
};

/*  O corpo de uma função é um bloco de comandos */
corpo: bloco_comandos_funcao { $$ = $1; };

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

bloco_comandos_funcao: '[' comandos_simples_seq escopo_fim ']' {
   $$ = $2 ? $2 : asd_new("bloco_vazio");
};

bloco_comandos: '[' escopo_inicio comandos_simples_seq escopo_fim ']' {
   $$ = $3 ? $3 : asd_new("bloco_vazio");
};

comandos_simples_seq: %empty { $$ = NULL; };

comandos_simples_seq: comandos_simples comandos_simples_seq {
    if ($1 && $2) {
        asd_add_child($1, $2);
        $$ = $1;

        if ($1->code && $2->code) {
            concat_code($1->code, $2->code);
            // Movemos o valor de $2->code e liberamos a referência.
            $2->code = NULL;
        } else if (!$1->code && $2->code) {
            $1->code = $2->code;
            $2->code = NULL;
        }
        // Se apenas $1 tem código, não fazemos nada

    } else if ($1) {
        $$ = $1;
    } else {
        $$ = $2;
    }
};

/* Declaração de variável: 
Esta declaração é idêntica ao comando simples de declaração de variável
sendo que a única e importante diferença é que esse elemento não pode receber valores de inicialização. */
declaracao_variavel_global: TK_VAR TK_ID TK_ATRIB tipo {
    SymbolNode *s_exists = find_symbol($2->value);
    if (s_exists && s_exists->symbol.nature == IDENTIFICADOR) {
        throw_already_declared_error($2->line_number, $2->value);
        YYABORT;
    }

    Symbol var_symbol = make_var_symbol($2->value, $4);
    insert_symbol(var_symbol);

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
declaracao_variavel: TK_VAR TK_ID TK_ATRIB tipo TK_COM TK_LI_DECIMAL {
	$$ = asd_new("com");
    $$->type = FLOAT;
    if ($2) {
        SymbolNode *s_exists = find_symbol($2->value);
        if (s_exists && s_exists->symbol.nature == IDENTIFICADOR) {
            throw_already_declared_error($2->line_number, $2->value);
            YYABORT;
        }

        if ($4 != FLOAT) {
            throw_type_mismatch_error($2->line_number, $2->value, "FLOAT", $6->value, get_label_type($6->type));
            YYABORT;
        }

        Symbol var_symbol = make_var_symbol($2->value, FLOAT);
        insert_symbol(var_symbol);

        asd_tree_t *literal_node = asd_new($2->value);
        asd_add_child($$, literal_node);

        // O valor de $2 foi copiado para o nó, podemos liberar a memória.
        free($2->value);
        free($2);
    }
    if ($6) {
        asd_tree_t *literal_node = asd_new($6->value);
        literal_node->type = FLOAT; // Define o tipo do literal como FLOAT
        asd_add_child($$, literal_node);

        // O valor de $6 foi copiado para o nó, podemos liberar a memória.
        free($6->value);
        free($6);
    }
};

declaracao_variavel: TK_VAR TK_ID TK_ATRIB tipo TK_COM TK_LI_INTEIRO {
	$$ = asd_new("com");
    $$->type = INT;
    if ($2) {
        SymbolNode *s_exists = find_symbol($2->value);
        if (s_exists && s_exists->symbol.nature == IDENTIFICADOR) {
            throw_already_declared_error($2->line_number, $2->value);
            YYABORT;
        }

        if ($4 != INT) {
            throw_type_mismatch_error($2->line_number, $2->value, "INT", $6->value, get_label_type($6->type));
            YYABORT;
        }

        Symbol var_symbol = make_var_symbol($2->value, INT);
        insert_symbol(var_symbol);

        asd_tree_t *literal_node = asd_new($2->value);
        asd_add_child($$, literal_node);

        // O valor de $2 foi copiado para o nó, podemos liberar a memória.
        free($2->value);
        free($2);
    }
    if ($6) {
        asd_tree_t *literal_node = asd_new($6->value);
        literal_node->type = INT; // Define o tipo do literal como INT
        asd_add_child($$, literal_node);

        // O valor de $6 foi copiado para o nó, podemos liberar a memória.
        free($6->value);
        free($6);
    }
};
declaracao_variavel: TK_VAR TK_ID TK_ATRIB tipo {
    SymbolNode *s_exists = find_symbol($2->value);
    if (s_exists && s_exists->symbol.nature == IDENTIFICADOR) {
        throw_already_declared_error($2->line_number, $2->value);
        YYABORT;
    }

    Symbol var_symbol = make_var_symbol($2->value, $4);
    insert_symbol(var_symbol);

    char label[256];
    snprintf(label, sizeof(label), "var %s", $2->value);
    $$ = asd_new(label);
    $$->type = $4;

    free($2->value);
    free($2);
};

/* Comando de Atribuição: 
O comando de atribuição consiste em um token TK_ID, 
seguido do token TK_ATRIB e enfim seguido por uma expressão. */
comando_atribuicao: TK_ID TK_ATRIB expressao {
    SymbolNode *s = find_symbol($1->value);
    if (!s) {
        throw_undeclared_error($1->line_number, $1->value);
        YYABORT;
    }

    if (s->symbol.nature == FUNCAO) {
        throw_func_used_as_var_error($1->line_number, $1->value);
        YYABORT;
    }

    if (s->symbol.type != $3->type) {
        throw_type_mismatch_error($1->line_number, $1->value, get_label_type(s->symbol.type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = asd_new(":=");
    $$->type = s->symbol.type; // Define o tipo do nó de atribuição

    asd_tree_t *var_node = asd_new($1->value);
    var_node->type = s->symbol.type; // Define o tipo do nó da variável
    asd_add_child($$, var_node);

    // Garante que $$->code não seja nulo para que não haja memory leak.
    if ($3->code) {
        $$->code = $3->code;
        $3->code = NULL;
    } else {
        $$->code = calloc(1, sizeof(iloc_code));
    }

    char offset_str[16];
    sprintf(offset_str, "%d", s->symbol.offset * 4);
    const char *base_reg = get_var_base_register($1->value);
    iloc_operation* store_op = create_iloc_op(NULL, STOREAI, $3->temp_reg, NULL, NULL, base_reg, offset_str, NULL);
    append_op($$->code, store_op);

    if($3) { asd_add_child($$, $3); }

    // $1 é usado para criar var_node, então não deve ser o payload principal.
    // O valor de $1 (string) já foi copiado para var_node->label. Liberamos o lexical_value.
    free($1->value);
    free($1);
};

/* Chamada de Função: 
Uma chamada de função consiste no token TK_ID, seguida de argumentos entre parênteses, 
sendo que cada argumento é separado do outro por vírgula. 
Um argumento é uma expressão. Uma chamada de função pode existir sem argumentos. */
chamada_funcao: TK_ID '(' lista_argumentos ')' {
	if($1){
        SymbolNode *s = find_symbol($1->value);
        if (!s) {
            throw_undeclared_error($1->line_number, $1->value);
            YYABORT;
        }
        if (s->symbol.nature != FUNCAO) {
            throw_var_used_as_func_error($1->line_number, $1->value);
            YYABORT;
        }

        // Se a assinatura é nula, uma chamada recursiva está sendo parseada.
        // A verificação será feita implicitamente depois, quando a assinatura for construída.
        if (s->symbol.signature) {
            // Compara o número de argumentos fornecidos com o número de parâmetros esperados
            if ($3->arg_count < s->symbol.signature->param_count) {
                throw_missing_args_error($1->line_number, $1->value);
                YYABORT;
            }
            if ($3->arg_count > s->symbol.signature->param_count) {
                throw_excess_args_error($1->line_number, $1->value);
                YYABORT;
            }

            // Verifica se os tipos dos argumentos coincidem com os tipos dos parâmetros
            arg_t *arg = $3->args;
            for (int i = 0; i < s->symbol.signature->param_count; i++) {

                if (arg->type != s->symbol.signature->params[i].type) {
                    throw_mismatch_symbol_table_type_error($1->line_number, $1->value);
                    YYABORT;
                }
                arg = arg->next;
            }
        } 
        
        iloc_code *args_code = NULL;
        arg_t *curr_arg = $3->args;
        while (curr_arg) {
            if (curr_arg->code) {
                if (args_code) {
                    concat_code(args_code, curr_arg->code);
                } else {
                    args_code = curr_arg->code;
                }
                curr_arg->code = NULL; // Evita double free
            }
            curr_arg = curr_arg->next;
        }

        arglist_free($3);

        char nome[256];
        snprintf(nome, sizeof(nome), "call %s", $1->value);
        $$ = asd_new(nome);
        $$->type = s->symbol.type; // Define o tipo de retorno da chamada de função
        $$->code = args_code; // Anexa o código dos argumentos à chamada de função
         
        // O nome da função já foi copiado para o label do nó. Liberamos o lexical_value.
        free($1->value);
        free($1);
    };
};

chamada_funcao: TK_ID '(' ')' {
    if($1){
        SymbolNode *s = find_symbol($1->value);
        if (!s) {
            throw_undeclared_error($1->line_number, $1->value);
            YYABORT;
        }
        if (s->symbol.nature != FUNCAO) {
            throw_var_used_as_func_error($1->line_number, $1->value);
            YYABORT;
        }
        if (s->symbol.signature && s->symbol.signature->param_count > 0) {
            throw_missing_args_error($1->line_number, $1->value);
            YYABORT;
        }
        char nome[256];
        snprintf(nome, sizeof(nome), "call %s", $1->value);
        $$ = asd_new(nome);
        $$->type = s->symbol.type;
        free($1->value);
        free($1);
    }
};

lista_argumentos: argumento ',' lista_argumentos {
    args_list_t *args_list = $3;
    $1->next = args_list->args;
    args_list->args = $1;
    args_list->arg_count += 1;
    $$ = args_list;
};

lista_argumentos: argumento {
    args_list_t *args_list = argslist_new(1);
    args_list->args = $1;
	$$ = args_list;
};

/* Um argumento é uma expressão. */
argumento: expressao { 
    $$ = arg_new($1->type); 
    
    $$->code = $1->code; // Salva o código da expressão
    $$->temp_reg = $1->temp_reg; // Salva o registrador temporário da expressão
    $1->code = NULL; // Evita double free

    asd_free($1);
};
/* Comando de Retorno: 
Trata-se do token TK_RETORNA seguido de uma expressão, 
seguido do token TK_ATRIB e terminado ou pelo token TK_DECIMAL ou pelo token TK_INTEIRO. */
comando_retorno: TK_RETORNA expressao TK_ATRIB tipo {
	$$ = asd_new("retorna");
    $$->type = $4;

    if ($2->type != $4) {
        // O tipo da expressão não corresponde ao tipo especificado na declaração de retorno.
        throw_type_mismatch_error(get_line_number(), $2->label, get_label_type($2->type), "retorna", get_label_type($4));
        YYABORT;
    }

    asd_add_child($$, $2);

    $$->code = $2->code;         // Herda o código da expressão (ex: loadI 1 => r0)
    $$->temp_reg = $2->temp_reg; // Herda o registrador temporário da expressão
    $2->code = NULL;             // Evita double free
    $2->temp_reg = NULL;         // Evita double free

    type_t current_return_type = get_current_return_type();
    if (current_return_type != $4) {
        throw_mismatch_return_type_error(get_line_number(), "retorna");
        YYABORT;
    }
};

/* Comandos de Controle de Fluxo: 
A linguagem possui uma construção condicional e uma
construção iterativa para controle estruturado de fluxo. 
A condicional consiste no token TK_SE seguido de uma expressão entre parênteses 
e então por um bloco de comandos obrigatório. Após este bloco, podemos opcionalmente ter o token
TK_SENAO que, quando aparece, é seguido obrigatoriamente por um bloco de comandos. */
construcoes_fluxo_controle: TK_SE '(' expressao ')' bloco_comandos {
    if ($3->type != INT) {
        throw_type_mismatch_error(get_line_number(), "se condition", "INT", $3->label, get_label_type($3->type));
        YYABORT;
    }
    $$ = asd_new("se");
    $$->type = $3->type;
    asd_add_child($$, $3);
    asd_add_child($$, $5);

    generate_if_code($$, $3, $5);
};

construcoes_fluxo_controle: TK_SE '(' expressao ')' bloco_comandos TK_SENAO bloco_comandos {
	if ($3->type != INT) {
        throw_type_mismatch_error(get_line_number(), "se condition", "INT", $3->label, get_label_type($3->type));
        YYABORT;
    }

    if ($5 && $7 && $5->type != $7->type) {
        throw_type_mismatch_error(get_line_number(), "se block", get_label_type($5->type), "senao block", get_label_type($7->type));
        YYABORT;
    }

	$$ = asd_new("se");
    $$->type = $3->type;
    asd_add_child($$, $3);
    asd_add_child($$, $5); 
    asd_add_child($$, $7);

    generate_if_else_code($$, $3, $5, $7);
};

/* Temos apenas uma construção de repetição que é o token TK_ENQUANTO 
seguido de uma expressão entre parênteses e de um bloco de comandos. */
construcoes_fluxo_controle: TK_ENQUANTO '(' expressao ')' bloco_comandos {
	if ($3->type != INT) {
        throw_type_mismatch_error(get_line_number(), "enquanto condition", "INT", $3->label, get_label_type($3->type));
        YYABORT;
    }
	$$ = asd_new("enquanto");
    $$->type = $3->type;
    asd_add_child($$, $3);
    asd_add_child($$, $5);

    generate_while_code($$, $3, $5);
};

/* Expressões envolvem operandos e operadores, sendo este opcional. */
expressao: operacao_binaria_or { $$ = $1; };

/* Precedência 7 */
operacao_binaria_or: operacao_binaria_or '|' operacao_binaria_and {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = handle_binary_op("|", OR, $1, $3);
};
operacao_binaria_or: operacao_binaria_and { $$ = $1; };

/* Precedência 6 */
operacao_binaria_and: operacao_binaria_and '&' operacao_binaria_igualdade {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }
    
    $$ = handle_binary_op("&", AND, $1, $3);
};
operacao_binaria_and: operacao_binaria_igualdade { $$ = $1; }; 

/* Precedência 5 */
operacao_binaria_igualdade: operacao_binaria_igualdade TK_OC_EQ operacao_binaria_relacional {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = handle_binary_op("==", CMP_EQ, $1, $3);
};
operacao_binaria_igualdade: operacao_binaria_igualdade TK_OC_NE operacao_binaria_relacional {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = handle_binary_op("!=", CMP_NE, $1, $3);
};
operacao_binaria_igualdade: operacao_binaria_relacional { $$ = $1; };

/* Precedência 4 */
operacao_binaria_relacional: operacao_binaria_relacional '<' operacao_binaria_soma_sub {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = handle_binary_op("<", CMP_LT, $1, $3);
};
operacao_binaria_relacional: operacao_binaria_relacional '>' operacao_binaria_soma_sub {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = handle_binary_op(">", CMP_GT, $1, $3);
};
operacao_binaria_relacional: operacao_binaria_relacional TK_OC_LE operacao_binaria_soma_sub {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = handle_binary_op("<=", CMP_LE, $1, $3);
};
operacao_binaria_relacional: operacao_binaria_relacional TK_OC_GE operacao_binaria_soma_sub {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = handle_binary_op(">=", CMP_GE, $1, $3);
};
operacao_binaria_relacional: operacao_binaria_soma_sub { $$ = $1; };

/* Precedência 3 */
operacao_binaria_soma_sub: operacao_binaria_soma_sub '+' operacao_binaria_mult_div {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = handle_binary_op("+", ADD, $1, $3);
};
operacao_binaria_soma_sub: operacao_binaria_soma_sub '-' operacao_binaria_mult_div {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = handle_binary_op("-", SUB, $1, $3);
};
operacao_binaria_soma_sub: operacao_binaria_mult_div { $$ = $1; };

/* Precedência 2 */
operacao_binaria_mult_div: operacao_unaria { $$ = $1; };
operacao_binaria_mult_div: operacao_binaria_mult_div '*' operacao_unaria {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = handle_binary_op("*", MULT, $1, $3);
};
operacao_binaria_mult_div: operacao_binaria_mult_div '/' operacao_unaria {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = handle_binary_op("/", DIV, $1, $3);
};
operacao_binaria_mult_div: operacao_binaria_mult_div '%' operacao_unaria {
    if ($1->type != $3->type) {
        throw_type_mismatch_error(get_line_number(), $1->label, get_label_type($1->type), $3->label, get_label_type($3->type));
        YYABORT;
    }

    $$ = asd_new("%");
    $$->type = $1->type;
    asd_add_child($$, $1);
    asd_add_child($$, $3);

    // Apenas para evitar problemas com memory leaks e crashes:
    $$->code = concat_code($1->code, $3->code);
    $1->code = NULL;
    $3->code = NULL;
    $$->temp_reg = new_temporary();
};

/* Precedência 1 */
operacao_unaria: operando { $$ = $1; };
operacao_unaria: '+' operacao_unaria {
    $$ = asd_new("+");
    $$->type = $2->type;
    asd_add_child($$, $2);

    // Passa adiante o código e o registrador temporário do filho
    $$->code = $2->code;
    $2->code = NULL; // Evita double free
    $$->temp_reg = $2->temp_reg;
    $2->temp_reg = NULL; // Evita double free
};
operacao_unaria: '-' operacao_unaria {
    asd_tree_t *child = $2;

    $$ = asd_new("-");
    $$->type = $2->type;
    asd_add_child($$, $2);

    // Começa do código do filho
    $$->code = $2->code;
    $2->code = NULL; // Evita double free

    // Gera ILOC:
    char *result_reg = new_temporary();
    iloc_operation *rsub_op = create_iloc_op(NULL, RSUBI, child->temp_reg, "0", NULL, result_reg, NULL, NULL);
    append_op($$->code, rsub_op);

    $$->temp_reg = result_reg;
};
operacao_unaria: '!' operacao_unaria {
    $$ = asd_new("!");
    $$->type = $2->type;
    asd_add_child($$, $2);
};

/* Precedência 0 */
/* Os operandos podem ser identificadores, literais e 
chamada de função ou outras expressões, 
podendo portanto ser formadas recursivamente pelo emprego de operadores */
operando: TK_ID {
    SymbolNode *s = find_symbol($1->value);
    if (!s) {
        throw_undeclared_error($1->line_number, $1->value);
        YYABORT;
    }
    
    if (s->symbol.nature == FUNCAO) {
        throw_func_used_as_var_error($1->line_number, $1->value);
        YYABORT;
    }

    $$ = asd_new($1->value);

    $$->type = s->symbol.type;

    // Gera código para carregar a variável em um registrador temporário.
    $$->code = calloc(1, sizeof(iloc_code));
    $$->temp_reg = new_temporary();
    char offset_str[16];
    sprintf(offset_str, "%d", s->symbol.offset * 4); // Assumindo 4 bytes para inteiros
    const char *base_reg = get_var_base_register($1->value);
    iloc_operation* op = create_iloc_op(NULL, LOADAI, base_reg, offset_str, NULL, $$->temp_reg, NULL, NULL);
    append_op($$->code, op);
    
    // O valor de $1 (string) já foi copiado para o label do nó. Liberamos o lexical_value.
    free($1->value);
    free($1);
};
operando: TK_LI_INTEIRO { 
    $$ = asd_new($1->value);
    $$->type = INT;

    // Gera código ILOC para carregar o literal inteiro em um registrador temporário.
    $$->code = calloc(1, sizeof(iloc_code));
    $$->temp_reg = new_temporary();
    iloc_operation* op = create_iloc_op(NULL, LOADI, $1->value, NULL, NULL, $$->temp_reg, NULL, NULL);
    append_op($$->code, op);

    free($1->value);
    free($1);
};
operando: TK_LI_DECIMAL {
    $$ = asd_new($1->value);
    $$->type = FLOAT;
    free($1->value);
    free($1);
};
operando: chamada_funcao { $$ = $1; };
operando: '(' expressao ')' { $$ = $2; };

/* Elas também permitem o uso de parênteses para forçar
uma associatividade ou precedência diferente daquela tradicional.  */

%%

void yyerror (char const *mensagem)
{
	int line = get_line_number();
	printf("o erro encontrado foi [%s], na linha [%d] \n", mensagem, line);
}

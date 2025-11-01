/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"
#include "parser.tab.h"
#include "errors.h"
#include "types.h"

// A variável global com o topo da pilha de escopos. Se é nulo, significa que a pilha está vazia.
Scope *g_scope_stack_top = NULL;

static void free_symbol_contents(Symbol *s) {
    if (!s) return;

    if (s->lexical_value) {
        free(s->lexical_value->value);
        free(s->lexical_value);
    }

    if (s->nature == FUNCAO && s->signature) {
        funcsig_free(s->signature);
    }
}

// Limpa todos os símbolos em uma lista encadeada de símbolos.
static void free_symbol_list(SymbolNode *head) {
    while (head) {
        SymbolNode *next = head->next;
        free_symbol_contents(&head->symbol);
        free(head);
        head = next;
    }
}

// Retira da pilha e libera um único escopo.
static void free_one_scope(Scope *s) {
    if (!s) return;
    free_symbol_list(s->symbols);
    free(s);
}

void initialize_stack(void) {
    // Não tenho certeza se precisamos de uma initialize_stack, porque o escopo global pode ser inicializado com push_scope.
}

void destroy_stack(void) {
    // Retira e libera todos os escopos.
    while (g_scope_stack_top)
        pop_scope();
}

void create_symbol_table(void) {

};

void destroy_symbol_table(void) {

}

void push_scope(void) {
     Scope *s = calloc(1, sizeof(Scope));
     s->prev = g_scope_stack_top;
     g_scope_stack_top = s;
}

void pop_scope(void) {
     if (g_scope_stack_top) {
         Scope *top = g_scope_stack_top;
         g_scope_stack_top = top->prev;
         free_one_scope(top);
     }
}

// Insere símbolo no escopo atual
SymbolNode *insert_symbol(Symbol s) {
    if (!g_scope_stack_top) return NULL;

    SymbolNode *node = calloc(1, sizeof(SymbolNode));
    node->symbol = s;
    node->next = g_scope_stack_top->symbols;
    g_scope_stack_top->symbols = node;
    return node;
}

// Busca símbolo por nome, subindo na pilha de escopos
// SymbolNode *find_symbol(const char *name) {
//     printf("[DEBUG] find_symbol: Buscando por '%s'\n", name);
//     int scope_level = 0; // Para debug, para saber em qual nível de escopo estamos
//     for (Scope *scope = g_scope_stack_top; scope != NULL; scope = scope->prev) {
//         printf("[DEBUG] find_symbol: Verificando escopo nível %d\n", scope_level);
//         for (SymbolNode *n = scope->symbols; n != NULL; n = n->next) {
//             if (n->symbol.lexical_value && n->symbol.lexical_value->value) {
//                 printf("[DEBUG] find_symbol:   Comparando com '%s'\n", n->symbol.lexical_value->value);
//                 if (strcmp(n->symbol.lexical_value->value, name) == 0) {
//                     printf("[DEBUG] find_symbol: Símbolo '%s' encontrado no escopo %d.\n", name, scope_level);
//                     return n;
//                 }
//             }
//         }
//         scope_level++;
//     }
//     printf("[DEBUG] find_symbol: Símbolo '%s' não encontrado em nenhum escopo.\n", name);
//     return NULL;
// }

// Busca símbolo por nome, subindo na pilha de escopos
SymbolNode *find_symbol(const char *name) {
    for (Scope *scope = g_scope_stack_top; scope != NULL; scope = scope->prev) {
        for (SymbolNode *n = scope->symbols; n != NULL; n = n->next) {
            if (n->symbol.lexical_value && n->symbol.lexical_value->value) {
                if (strcmp(n->symbol.lexical_value->value, name) == 0)
                    return n;
            }
        }
    }
    return NULL;
}

// Transforma função em "Símbolo"
Symbol make_function_symbol(const char *name, Type return_type, FuncSignature *sig) {
    Symbol s;
    s.nature = FUNCAO;
    s.type = return_type;
    s.signature = sig;

    // Cria cópia do valor léxico para ter ele persistente 
    // mesmo que o token original seja liberado
    s.lexical_value = calloc(1, sizeof(lexical_value_t));
    s.lexical_value->value = strdup(name);
    s.lexical_value->line_number = 0;  // TODO: ver como preencher
    s.lexical_value->type = 0;         // idem

    return s;
}

// Transforma variável em "Símbolo"
Symbol make_var_symbol(const char *name, Type type) {
    Symbol s;
    s.nature = IDENTIFICADOR;
    s.type = type;
    s.signature = NULL;

    s.lexical_value = calloc(1, sizeof(lexical_value_t));
    s.lexical_value->value = strdup(name);
    s.lexical_value->line_number = 0;
    s.lexical_value->type = 0;
    return s;
}

// Parte para lidar com os argumentos de funções:
// Declaração e alocação
FuncSignature *funcsig_new(int param_count) {
    FuncSignature *sig = calloc(1, sizeof(FuncSignature)); // Aloca um bloco de memória do tamanho de FuncSignature (struct)
    if (!sig) return NULL;

    sig->param_count = param_count; // Salva o número de parâmetros no campo da struct
    if (param_count > 0) 
        sig->params = calloc(param_count, sizeof(Param)); // Aloca um vetor contínuo de param_count elementos do tipo Param

    if (!sig->params) {
        free(sig);
        return NULL;
    }
    return sig;
}


void insert_params_into_scope(FuncSignature *sig) {
    if (!sig || sig->param_count == 0)
        return;

    for (int i = 0; i < sig->param_count; i++) {
        Symbol param = make_var_symbol(sig->params[i].name, sig->params[i].type);
        insert_symbol(param);
    }
}

// Transforma nó lista_parâmetros da AST em FuncSignature
FuncSignature *build_func_signature(asd_tree_t *param_list_node) {
    if (!param_list_node)
        return funcsig_new(0);

    // Conta quantos parâmetros há
    int count = 0;
    for (asd_tree_t *p = param_list_node; p != NULL; 
         p = (p->number_of_children > 1 ? p->children[1] : NULL))
        count++;

    FuncSignature *sig = funcsig_new(count);

    int i = 0;
    for (asd_tree_t *p = param_list_node; p != NULL; 
         p = (p->number_of_children > 1 ? p->children[1] : NULL)) {

        // O nó do tipo é sempre o primeiro filho
        asd_tree_t *type_node = p->children[0];
        sig->params[i].name = strdup(p->label);
        sig->params[i].type = 
            (strcmp(type_node->label, "inteiro") == 0) ? INT : FLOAT;
        i++;
    }

    return sig;
}

// Desalocação
void funcsig_free(FuncSignature *sig) {
    if (!sig) return;
    if (sig->params) {
        for (int i = 0; i < sig->param_count; ++i) {
            free(sig->params[i].name); // É seguro usar free mesmo se name for NULL
        }
        free(sig->params);
    }
    free(sig);
}

// Type infer_expr_type(asd_tree_t *node) {
//     if (!node) return -1; 
    
//     // Literal
//     if (node->payload && node->payload->type == TK_LI_INTEIRO)
//         return INT;
//     if (node->payload && node->payload->type == TK_LI_DECIMAL)
//         return FLOAT;
    
//     // Variável
//     if (node->payload && node->payload->type == TK_ID) {
//         SymbolNode *sym = find_symbol(node->payload->value);
//         if (!sym) return -1; 
//         return sym->symbol.type;
//     }
    
//     // Operadores unários (+, -): preserva o tipo do operando
//     // NOTA: Precisa verificar ANTES dos binários, pois compartilham os mesmos labels!
//     // Unário tem 1 filho, binário tem 2 filhos
//     if ((strcmp(node->label, "+") == 0 || strcmp(node->label, "-") == 0) 
//         && node->number_of_children == 1) {
//         Type operand = infer_expr_type(node->children[0]);
//         if (operand == -1) return -1;
//         return operand; // Preserva o tipo do operando
//     }
    
//     // Operador unário de negação lógica (!): retorna INT (0 ou 1)
//     if (strcmp(node->label, "!") == 0) {
//         if (node->number_of_children < 1) return -1;
//         Type operand = infer_expr_type(node->children[0]);
//         if (operand == -1) return -1;
//         return INT; // Negação lógica retorna inteiro (boolean)
//     }
    
//     // Expressões binárias aritméticas (+, -, *, /): ambos operandos devem ter o mesmo tipo
//     if (strcmp(node->label, "+") == 0 || strcmp(node->label, "-") == 0 ||
//         strcmp(node->label, "*") == 0 || strcmp(node->label, "/") == 0) {
//         if (node->number_of_children < 2) return -1;
//         Type left = infer_expr_type(node->children[0]);
//         Type right = infer_expr_type(node->children[1]);
//         if (left == -1 || right == -1 || left != right) return -1;
//         return left; // Retorna o tipo dos operandos (são iguais)
//     }
    
//     // Modulo (%): ambos operandos devem ser INT
//     if (strcmp(node->label, "%") == 0) {
//         if (node->number_of_children < 2) return -1;
//         Type left = infer_expr_type(node->children[0]);
//         Type right = infer_expr_type(node->children[1]);
//         if (left != INT || right != INT) return -1;
//         return INT;
//     }
    
//     // Operadores relacionais (<, >, <=, >=): comparam operandos do mesmo tipo, retornam INT
//     if (strcmp(node->label, "<") == 0 || strcmp(node->label, ">") == 0 ||
//         strcmp(node->label, "<=") == 0 || strcmp(node->label, ">=") == 0) {
//         if (node->number_of_children < 2) return -1;
//         Type left = infer_expr_type(node->children[0]);
//         Type right = infer_expr_type(node->children[1]);
//         if (left == -1 || right == -1 || left != right) return -1;
//         return INT; // Operações relacionais retornam "boolean" (INT)
//     }
    
//     // Operadores de igualdade (==, !=): comparam operandos do mesmo tipo, retornam INT
//     if (strcmp(node->label, "==") == 0 || strcmp(node->label, "!=") == 0) {
//         if (node->number_of_children < 2) return -1;
//         Type left = infer_expr_type(node->children[0]);
//         Type right = infer_expr_type(node->children[1]);
//         if (left == -1 || right == -1 || left != right) return -1;
//         return INT; // Operações de igualdade retornam "boolean" (INT)
//     }
    
//     // Operadores lógicos (&, |): operandos devem ter o mesmo tipo, retornam INT
//     if (strcmp(node->label, "&") == 0 || strcmp(node->label, "|") == 0) {
//         if (node->number_of_children < 2) return -1;
//         Type left = infer_expr_type(node->children[0]);
//         Type right = infer_expr_type(node->children[1]);
//         if (left == -1 || right == -1 || left != right) return -1;
//         return INT; // Operações lógicas retornam "boolean" (INT)
//     }
    
//     // Chamada de função: retorna o tipo de retorno da função
//     if (strncmp(node->label, "call ", 5) == 0) {
//         SymbolNode *fsym = find_symbol(node->label + 5); // após "call "
//         if (!fsym || fsym->symbol.nature != FUNCAO) return -1;
//         return fsym->symbol.type; // Tipo de retorno da função
//     }
    
//     // Parênteses: apenas passa o tipo da expressão interna
//     // (Não precisa tratar separadamente se a AST já remove os parênteses)
    
//     return -1; // Tipo desconhecido ou nó inválido
// }

// int validate_call_args(FuncSignature *sig, asd_tree_t *args, int line, const char *func_name) {
//     int argc = 0;
//     asd_tree_t **arg_arr = NULL;
//     // Collect all arguments into an array:
//     if (!args) argc = 0;
//     else {
//         argc = args->number_of_children + 1;
//         arg_arr = malloc(argc * sizeof(asd_tree_t*));
//         arg_arr[0] = args;
//         for (int i = 1; i < argc; ++i) {
//             arg_arr[i] = args->children[i-1];
//         }
//     }
//     if (argc < sig->param_count) {
//         throw_missing_args_error(line, (char*)func_name); return 0;
//     }
//     if (argc > sig->param_count) {
//         throw_excess_args_error(line, (char*)func_name); return 0;
//     }
//     for (int i = 0; i < argc; ++i) {
//         Type given = infer_expr_type(arg_arr[i]);
//         Type wanted = sig->params[i].type;
//         if (given != wanted) {
//             throw_mismatch_symbol_table_type_error(line, func_name); return 0;
//         }
//     }
//     free(arg_arr);
//     return 1;
// }
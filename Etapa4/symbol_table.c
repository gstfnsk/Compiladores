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
    // printf("\n\n---------------------------------------------------------------------------\n");
    // printf("Push de escopo.\n");
    // print_scope_stack(g_scope_stack_top);
    Scope *s = calloc(1, sizeof(Scope));
    s->prev = g_scope_stack_top;
    g_scope_stack_top = s;
    // printf("\nApós push de escopo.\n");
    // print_scope_stack(g_scope_stack_top);
}

void pop_scope(void) {
    if (g_scope_stack_top) {
        // printf("\n\n---------------------------------------------------------------------------\n");
        // printf("Pop de escopo.\n");
        // print_scope_stack(g_scope_stack_top);
        Scope *top = g_scope_stack_top;
        g_scope_stack_top = top->prev;
        free_one_scope(top);
        // printf("\nApós pop de escopo.\n");
        // print_scope_stack(g_scope_stack_top);
    }
}

// Insere símbolo no escopo atual
SymbolNode *insert_symbol(Symbol s) {
    if (!g_scope_stack_top) return NULL;

    // const char *nature_str = (s.nature == LITERAL) ? "LITERAL" :
    //                         (s.nature == IDENTIFICADOR) ? "IDENTIFICADOR" : "FUNCAO";
    // const char *type_str = get_label_type(s.type);
    // printf("\n\nInserindo símbolo '%s' no escopo atual. Natureza: %s. Tipo: %s\n", s.lexical_value->value, nature_str, type_str);
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
    if (param_count > 0) {
        sig->params = calloc(param_count, sizeof(Param)); // Aloca um vetor contínuo de param_count elementos do tipo Param

        if (!sig->params) {
            free(sig);
            return NULL;
        }
    } else {
        sig->params = NULL; // Se não houver parâmetros, seta o ponteiro como NULL
    }
    return sig;
}

// Transforma nó lista_parâmetros da AST em FuncSignature
FuncSignature *build_func_signature(struct Param *param_list) {
    if (!param_list)
        return funcsig_new(0);

    // Conta parâmetros
    int count = 0;
    struct Param *p;
    for (p = param_list; p != NULL; p = p->next) {
        count++;
    }
  
    FuncSignature *sig = funcsig_new(count);
    
    // Copia parâmetros para o vetor
    int i = 0;  
    for (p = param_list; p != NULL; p = p->next) {
        sig->params[i].name = strdup(p->name);
        sig->params[i].type = p->type;
        i++;
    }

    // Libera lista encadeada original
    while (param_list) {
        p = param_list->next;
        free(param_list->name);
        free(param_list);
        param_list = p;
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


// int validate_call_args(FuncSignature *sig, Param *args, int line, const char *func_name) {
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

struct Param *param_new(const char *name, Type type) {
    struct Param *p = calloc(1, sizeof(Param));
    if (!p) return NULL;
    p->name = strdup(name);
    p->type = type;
    p->next = NULL;
    return p;
}

void param_free(struct Param *p) {
    if (!p) return;
    free(p->name);
    free(p);
}

struct Arg *arg_new(Type type)
{
    struct Arg *arg = calloc(1, sizeof(Arg));
    if (!arg) return NULL;
    arg->type = type;
    arg->next = NULL;
    return arg;
}

struct ArgList *argslist_new(int arg_count) {
    struct ArgList *argslist = calloc(1, sizeof(ArgList));
    if (!argslist) {
        printf("Erro de alocação de memória para ArgList\n");
        return NULL;
    }
    argslist->arg_count = arg_count;
    argslist->args = NULL;
    return argslist;
}

void print_scope_stack(Scope *top) {
    int level = 0;
    for (Scope *scope = top; scope != NULL; scope = scope->prev) {
        printf("Escopo nível %d:\n", level);
        for (SymbolNode *sym_node = scope->symbols; sym_node != NULL; sym_node = sym_node->next) {
            Symbol *sym = &sym_node->symbol;
            const char *nature_str = (sym->nature == LITERAL) ? "LITERAL" :
                                     (sym->nature == IDENTIFICADOR) ? "IDENTIFICADOR" : "FUNCAO";
            const char *type_str = get_label_type(sym->type);
            printf("  Símbolo: %s, Natureza: %s, Tipo: %s\n",
                   sym->lexical_value ? sym->lexical_value->value : "(sem nome)",
                   nature_str,
                   type_str);
            if (sym->nature == FUNCAO && sym->signature) {
                printf("    Assinatura da função: %d parâmetros\n", sym->signature->param_count);
                for (int i = 0; i < sym->signature->param_count; ++i) {
                    const char *param_type_str = get_label_type(sym->signature->params[i].type);
                    printf("      Parâmetro %d: Nome: %s, Tipo: %s\n",
                           i + 1,
                           sym->signature->params[i].name,
                           param_type_str);
                }
            }
        }
        level++;
    }
}
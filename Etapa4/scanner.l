/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

%{ 
#include<stdio.h>
#include "parser.tab.h"
#include "asd.h"
#include "types.h"

lexical_value_t *make_lexical_value(const char *yytext, int token_type, int line_number) {
    lexical_value_t *aux = malloc(sizeof(lexical_value_t));
    if (!aux) {
        fprintf(stderr, "Erro: falha ao alocar lexical_value_t\n");
        exit(1);
    }

    aux->value = strdup(yytext);
    aux->line_number = line_number;
    aux->type = token_type;

    if (!aux->value) {
        fprintf(stderr, "Erro: falha ao copiar valor do token\n");
        free(aux);
        exit(1);
    }

    return aux;
}
%}

%option noinput
%option nounput
%option noyywrap
%option yylineno

%%

[ \n\r\t]+ ;
"//"[^\n]* ;

tipo { return TK_TIPO; }
var { return TK_VAR; }
senao { return TK_SENAO; }
decimal { return TK_DECIMAL; }
se { return TK_SE; }
inteiro { return TK_INTEIRO; }
retorna { return TK_RETORNA; }
enquanto { return TK_ENQUANTO; }
com { return TK_COM; }

\<= { return TK_OC_LE; }
>= { return TK_OC_GE; }
== { return TK_OC_EQ; }
!= { return TK_OC_NE; }
:= { return TK_ATRIB; }
-> { return TK_SETA; }

[!*/%+\-<>\[\]()=,;&|]   { return yytext[0]; }

[0-9]*\.[0-9]+ { 
    yylval.lexical_value = make_lexical_value(yytext, TK_LI_DECIMAL, yylineno);
    return TK_LI_DECIMAL;
}

[0-9]+ { 
    yylval.lexical_value = make_lexical_value(yytext, TK_LI_INTEIRO, yylineno);
    return TK_LI_INTEIRO;
}

[a-z_][a-z0-9_]* {
   yylval.lexical_value = make_lexical_value(yytext, TK_ID, yylineno);
   return TK_ID;
}

. { return TK_ER; }

%%

int get_line_number() {
/* return da variavel global*/
return yylineno;
}

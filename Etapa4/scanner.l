/*Grupo D*/
/*00228729 - Matheus Henrique Sabadin*/
/*00289108 - Giulia Chimini Stefainski*/

%{ 
#include<stdio.h>
#include "parser.tab.h"
#include "asd.h"
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
    lexical_value_t *aux = malloc(sizeof(lexical_value_t));

    if(aux == NULL){
       fprintf(stderr, "Erro");
       exit(1);
    }
    aux->value = strdup(yytext);
    aux->line_number = yylineno;
    aux->type = TK_LI_DECIMAL;
    if(aux->value == NULL){
      fprintf(stderr, "Erro");
      free(aux);
      exit(1);
    }
    yylval.valor_lexico = aux;
    return TK_LI_DECIMAL; }

[0-9]+ { 
    lexical_value_t *aux = malloc(sizeof(lexical_value_t));

    if(aux == NULL){
       fprintf(stderr, "Erro");
       exit(1);
    }
    aux->value = strdup(yytext);
    aux->line_number = yylineno;
    aux->type = TK_LI_INTEIRO;
    if(aux->value == NULL){
      fprintf(stderr, "Erro");
      free(aux);
      exit(1);
    }
    yylval.valor_lexico = aux;
    return TK_LI_INTEIRO; }

[a-z_][a-z0-9_]* {
   lexical_value_t *aux = malloc(sizeof(lexical_value_t));

    if(aux == NULL){
       fprintf(stderr, "Erro");
       exit(1);
    }
    aux->value = strdup(yytext);
    aux->line_number = yylineno;
    aux->type = TK_ID;
    if(aux->value == NULL){
      fprintf(stderr, "Erro");
      free(aux);
      exit(1);
    }
    yylval.valor_lexico = aux;
    return TK_ID; }

. { return TK_ER; }

%%

int get_line_number() {
/* return da variavel global*/
return yylineno;
}

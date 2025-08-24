/*Grupo D*/

%{ 
#include "tokens.h"
%}

%option noyywrap
%option yylineno

%%

/* Espaços em branco e comentários */
[ \n\r\t]+ ;
"//"[^\n]* ;

/* Palavras reservadas */
tipo { return TK_TIPO; }
var { return TK_VAR; }
senao { return TK_SENAO; }
decimal { return TK_DECIMAL; }
se { return TK_SE; }
inteiro { return TK_INTEIRO; }
retorna { return TK_RETORNA; }
enquanto { return TK_ENQUANTO; }
com { return TK_COM; }

/* Caracteres especiais */
! { return yytext[0]; }
\* { return yytext[0]; }
\/ { return yytext[0]; }
\% { return yytext[0]; }
\+ { return yytext[0]; }
- { return yytext[0]; }
\< { return yytext[0]; }
> { return yytext[0]; }
\[ { return yytext[0]; }
] { return yytext[0]; }
\( { return yytext[0]; }
\) { return yytext[0]; }
= { return yytext[0]; }
, { return yytext[0]; }
; { return yytext[0]; }
& { return yytext[0]; }
\| { return yytext[0]; }

/* Operadores compostos */
\<= { return TK_OC_LE; }
>= { return TK_OC_GE; }
== { return TK_OC_EQ; }
!= { return TK_OC_NE; }
:= { return TK_ATRIB; }
-> { return TK_SETA; }

/* Erro léxico */
. { return TK_ER; }

/* Literais */
[0-9]*\.[0-9]+ { return TK_LI_DECIMAL; }
[0-9]+ { return TK_LI_INTEIRO; }

%%

int get_line_number() {
/* return da variavel global*/
return yylineno;
}

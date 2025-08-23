/*Grupo D*/

%{ 
#include "tokens.h"
%}

%option noyywrap
%option yylineno

%%

tipo { return TK_TIPO; }
var { return TK_VAR; }
senao { return TK_SENAO; }
decimal { return TK_DECIMAL; }

, { return yytext[0]; }
[ \n\r\t ] 

. { return TK_ER; }

%%

int get_line_number() {
/* return da variavel global*/
return yylineno;
}

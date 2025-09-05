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

programa: lista ';';
programa: %empty;
lista: elemento;
lista: lista ',' elemento;
elemento: declaracao_variavel;
elemento: declaracao_funcao;

declaracao_variavel: TK_INTEIRO;

declaracao_funcao: cabecalho corpo;

cabecalho: TK_ID TK_SETA TK_DECIMAL lista_parametros TK_ATRIB;
cabecalho: TK_ID TK_SETA TK_DECIMAL TK_COM lista_parametros TK_ATRIB;
cabecalho: TK_ID TK_SETA TK_INTEIRO lista_parametros TK_ATRIB;
cabecalho: TK_ID TK_SETA TK_INTEIRO TK_COM lista_parametros TK_ATRIB;

lista_parametros: %empty;
lista_parametros: parametro lista_parametros_seq;

lista_parametros_seq: %empty;
lista_parametros_seq: ',' parametro lista_parametros_seq;

parametro: TK_ID TK_ATRIB TK_DECIMAL;
parametro: TK_ID TK_ATRIB TK_INTEIRO;

corpo: bloco_comandos;
bloco_comandos: TK_INTEIRO;

%%

int get_line_number(void);

void yyerror (char const *mensagem)
{
	int line = get_line_number();
	printf("o erro encontrado foi [%s], na linha [%d] \n", mensagem, line);
}


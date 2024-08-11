%{
#include<stdio.h>
#include <stdlib.h>
int yylex();
void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}
%}
%token BEGIN_DOC 
%token END_DOC
%%
doc_body: BEGIN_DOC
 | BEGIN_DOC END_DOC { printf("A document body"); }
 ;
%%
int main(int argc, char **argv)
{
 yyparse();
}
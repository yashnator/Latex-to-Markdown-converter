%{
#include<stdio.h>
#include <stdlib.h>
#include "AST.hpp"
int yylex();
void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}
%}
%union{
    struct node_h *node;
    char *str;
}
%token <node> BEGIN_DOC END_DOC
%token <str> SENTENCE
%token <str> SPACE EOL

%type <node> doc_body
%type <str> sentence
%%
doc_body: BEGIN_DOC
 | BEGIN_DOC sentence END_DOC { 
    $$ = new node_h; 
    $$->curr_type = body_t;
    printf("Create a doc with body: %s", $2);
    }
 ;
sentence: SENTENCE 
| sentence SENTENCE { $$ = strcat($1, $2); };
| sentence eol { $$ = strcat($1, "\n"); };
| sentence space { $$ = strcat($1, " "); };
eol: EOL;
space: SPACE;
%%
int main(int argc, char **argv)
{
    yyparse();
}
%{
#include<stdio.h>
#include <stdlib.h>
#include "src/AST.hpp"

int yylex();

node_h *latex_root;

char* prepend(char* s, const char* t) {
    size_t len = strlen(t);
    memmove(s + len, s, strlen(s) + 1);
    memcpy(s, t, len);
    return s;
}

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}
%}
%union{
    struct node_h *node;
    char *str;
}
%token <node> BEGIN_DOC END_DOC
%token <str> WORD SPACE EOL
%token <node> BOLD_START ITALICS_START BOLD_END ITALICS_END

%type <node> doc_body doc_element

%type <node> text_element
%type <node> text bold_text italics_text
%type <node> raw_bold_text raw_italics_text
%type <str> raw_text 
%%

doc_body: BEGIN_DOC {
    $$ = new node_h;
    $$->curr_type = body_t;
 }
 | doc_body doc_element {
    ($1->children).push_back($2);
    $$ = $1; 
 }
 | doc_body END_DOC {
    latex_root = $$;
    YYACCEPT;
 }
 ;

doc_element: text_element { $$ = $1; };

text_element: bold_text { $$ = $1; } 
 | italics_text 
 | text { $$ = $1; };

/* TEXT */ 
text: raw_text { $$ = create_node(text_t, $1); }

/* BOLD */

bold_text: raw_bold_text BOLD_END { $$ = $1; }

raw_bold_text: BOLD_START { $$ = create_node(bold_text_t); }
 | raw_bold_text text { $$ = add_child($$, $2); }
 | raw_bold_text italics_text { $$ = add_child($$, $2); }
 | raw_bold_text BOLD_START { };
 ;

/* ITALICS */ 

italics_text: raw_italics_text ITALICS_END { $$ = $1; };

raw_italics_text: ITALICS_START { $$ = create_node(italics_text_t); }
 | raw_italics_text text { $$ = add_child($$, $2); }
 | raw_italics_text bold_text { $$ = add_child($$, $2); }
 | raw_italics_text ITALICS_START { }
 ;

raw_text: WORD
 | EOL
 | SPACE
 ;

%%

int main(int argc, char **argv)
{
    yyparse();
    eval_root("output.md", latex_root);
}
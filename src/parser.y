/**
 * @file parser.y
 * @brief Bison file for parsing a Markdown-like language to create an Abstract Syntax Tree (AST).
 * 
 * This file defines the grammar and parsing rules for a custom Markdown-like language, using Bison.
 * The output is an AST that can be further processed to generate a formatted document.
 */
%{
#include<stdio.h>
#include <stdlib.h>
#include "src/AST.hpp"

int yylex();

node_h *latex_root;

/**
 * @brief Custom error handler for the parser.
 * 
 * @param msg The error message to be printed.
 */
void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}
%}
%union{
    struct node_h *node;            ///< Node used for building the AST.
    char *str;                      ///< String used for storing text tokens.
}

/* Tokens */
%token <node> BEGIN_DOC END_DOC
%token <node> BOLD_START ITALICS_START BOLD_END ITALICS_END
%token <node> VERBATIM_START VERBATIM_END
%token <node> HYPER_LINK
%token <node> IMAGE
%token <node> SECTION SUBSECTION SUBSUBSECTION
%token <str> WORD LIST_TEXT CODE SPACE HREF_TEXT HREF_LINK EOL
%token <str> IMAGE_PATH
%token <str> HRULE PAR
%token <str> SECTION_TEXT

/* Non-terminal types */
%type <node> doc_body doc_element
%type <node> code_block
%type <node> text_element
%type <node> text bold_text italics_text
%type <node> raw_bold_text raw_italics_text
%type <node> href_link
%type <node> image_element
%type <node> section_type_element
%type <str> raw_text

%%

/**
 * @brief The main body of the document.
 * 
 * It consists of a series of document elements including text, code blocks, links, and images that are appended to the
 * document for further processing and writing to a Markdown file
 */
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

/**
 * @brief A single document element, which could be text, a code block, a hyperlink, a table, a list or an image.
 */
doc_element: text_element 
 | code_block 
 | href_link 
 | image_element
 | LIST_TEXT { $$ = create_node(list_t, $1); }
 ;

/**
 * @brief A text element that could be plain text, bold text, italics text, or a section/subsection/subsubsection header.
 */
text_element: bold_text | italics_text | text | section_type_element;

/* Sections, subsections, subsubsections */

/**
 * @brief A section header element, which can be a section, subsection, or subsubsection.
 * 
 * This rule also handles the addition of text to section headers.
 */
section_type_element: SECTION { $$ = create_node(section_t); }
 | SUBSECTION { $$ = create_node(subsection_t); }
 | SUBSUBSECTION { $$ = create_node(subsubsection_t); }
 | section_type_element SECTION_TEXT {
    if(strlen($2) != 0){
        struct node_h* text_child = create_node(text_t, $2);
        add_child($1, text_child);
        $$ = $1;
    } else{
        $$ = $1;
    }
 }
 ;

/* TEXT TYPES */ 

/**
 * @brief A text node containing raw text.
 */
text: raw_text { $$ = create_node(text_t, $1); }

/**
 * @brief A bold text block, enclosed within bold delimiters.
 */
bold_text: raw_bold_text BOLD_END { $$ = $1; }

/**
 * @brief Raw bold text content, without delimiter.
 */
raw_bold_text: BOLD_START { $$ = create_node(bold_text_t); }
 | raw_bold_text text { $$ = add_child($$, $2); }
 | raw_bold_text italics_text { $$ = add_child($$, $2); }
 | raw_bold_text BOLD_START { };
 ;

/**
 * @brief An italics text block, enclosed within italics delimiters.
 */
italics_text: raw_italics_text ITALICS_END { $$ = $1; };

/**
 * @brief Raw italics text content, without delimiter.
 */
raw_italics_text: ITALICS_START { $$ = create_node(italics_text_t); }
 | raw_italics_text text { $$ = add_child($$, $2); }
 | raw_italics_text bold_text { $$ = add_child($$, $2); }
 | raw_italics_text ITALICS_START { }
 ;

/* Code Block */ 

/**
 * @brief A code block created using \begin{verbatim}, paster as-is to the Markdown file.
 */
code_block: VERBATIM_START { $$ = create_node(verbatim_t); }
 | code_block CODE { 
    $1->value = strcat($1->value, $2);
    $$ = $1;
 }
 | code_block VERBATIM_END {
    $$ = $1;
 }

/**
 * @brief A hyperlink, which contains a link and optional link text.
 */
href_link: HYPER_LINK { $$ = create_node(href_t); }
 | href_link HREF_LINK {
    if(strlen($2) != 0){
        struct node_h* link_child = create_node(text_t, $2);
        add_child($1, link_child);
        $$ = $1;
    } else{
        $$ = $1;
    }
 };
 | href_link HREF_TEXT {
    if(strlen($2) != 0){
        struct node_h* link_child = create_node(text_t, $2);
        add_child($1, link_child);
        $$ = $1;
    } else{
        $$ = $1;
    }
 }
 ;

/**
 * @brief An image element, which includes an image path.
 */
image_element: IMAGE { $$ = create_node(image_t); }
 | image_element IMAGE_PATH {
    if(strlen($2) != 0){
        struct node_h* link_child = create_node(text_t, $2);
        add_child($1, link_child);
        $$ = $1;
    } else{
        $$ = $1;
    }
 }
 ;

/**
 * @brief Raw text strings, including words, end-of-line markers, spaces, horizontal rules, and paragraphs.
 */
raw_text: WORD
 | EOL
 | SPACE
 | HRULE
 | PAR
 ;

%%

/**
 * @brief The main function that initiates parsing.
 * 
 * @param argc Argument count.
 * @param argv Argument vector.
 * @return int Returns 0 on success.
 */
int main(int argc, char **argv)
{
    yyparse();
    eval_root(argv[1], latex_root);
}
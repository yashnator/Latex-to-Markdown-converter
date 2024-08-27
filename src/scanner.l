/**
 * @file lexer.l
 * @brief Flex lexer for parsing a custom Markdown-like language with LaTeX commands.
 * 
 * This file defines the lexical analysis for parsing a Markdown-like language that includes
 * LaTeX-style commands for document structure, text formatting, hyperlinks, images, and more.
 */

%option noyywrap stack
%{
#include "parser.tab.h"
#include "src/AST.hpp"

int list_idx = 0;

/**
 * @brief Tracks whether the lexer is currently inside bold text.
 */
bool yy_is_bold = false;

/**
 * @brief Tracks whether the lexer is currently inside italic text.
 */
bool yy_is_italic = false;

/**
 * @brief Counter for tracking nested braces in hyperlinks.
 */
int href_braces;

/**
 * @brief Counter for tracking nested braces in image links.
 */
int image_braces;

/**
 * @brief Counter for tracking nested braces in section headers.
 */
int section_braces;

%}
/* State declarations for different contexts */
%x PREAMBLE
%x BODY
%x BOLD
%x ITALICS
%x VERBATIM
%x HYPERLINK
%x IMAGELINK
%x SECTION_ANY
%x ULIST 
%x OLIST
%%

<INITIAL>(.|\n)*"\\begin{document}"[ \n]* {
  /**
  * @brief Match the beginning of the document.
  */
  yy_push_state(BODY);
  yy_is_bold = false;
  yy_is_italic = false;
  return BEGIN_DOC;
}

<BODY>[ \n]*"\\end{document}" {
  /**
  * @brief Match the end of the document.
  */
  yy_pop_state();
  return END_DOC;
}

<*>"\\href" {
  /**
  * @brief Match the beginning of a hyperlink command.
  */
  yy_push_state(HYPERLINK);
  href_braces = 4;
  return HYPER_LINK;
}

<*>"\\includegraphics" {
  /**
  * @brief Match the beginning of an image inclusion command.
  */
  yy_push_state(IMAGELINK);
  image_braces = 4;
  return IMAGE;
}

<*>"\\section" {
  /**
  * @brief Match the beginning of a section header command.
  */
  section_braces = 2;
  yy_push_state(SECTION_ANY);
  return SECTION;
}

<*>"\\subsection" {
  /**
  * @brief Match the beginning of a subsection header command.
  */
  section_braces = 2;
  yy_push_state(SECTION_ANY);
  return SUBSECTION;
}

<*>"\\subsubsection" {
  /**
  * @brief Match the beginning of a subsubsection header command.
  */
  section_braces = 2;
  yy_push_state(SECTION_ANY);
  return SUBSUBSECTION;
}

<SECTION_ANY>"{"|"}" {
  /**
  * @brief Handle opening and closing braces in section headers.
  */
  --section_braces;
  if(section_braces == 0){
    yy_pop_state();
  }
  char empty[] = "";
  yylval.str = strdup(empty);
  return SECTION_TEXT;
}

<SECTION_ANY>[^{}]+ {
  /**
  * @brief Match text content inside section headers.
  */
  yylval.str = strdup(yytext);
  return SECTION_TEXT;
}

<*>"\\begin{itemize}"[ \n]* {
  ++list_idx;
  char empty[] = "";
  yylval.str = strdup(empty);
  yy_push_state(ULIST);
  return LIST_TEXT;
}

<*>[ \n]*"\\end{itemize}" {
  --list_idx;
  char empty[] = "";
  yylval.str = strdup(empty);
  yy_pop_state();
  return LIST_TEXT;
}

<*>"\\begin{enumerate}"[ \n]* {
  ++list_idx;
  char empty[] = "";
  yylval.str = strdup(empty);
  yy_push_state(OLIST);
  return LIST_TEXT;
}

<*>[ \n]*"\\end{enumerate}" {
  --list_idx;
  char empty[] = "";
  yylval.str = strdup(empty);
  yy_pop_state();
  return LIST_TEXT;
}

<*>[ \n]*"\\item"[ \n]* {
  char s[] = "\n";
  for(int i = 1; i < list_idx; ++i){
    char tab[] = "\t";
    strcat(s, tab);
  }
  if(YYSTATE == 10){
    char it[] = "1. ";
    strcat(s, it);
  } else{
    char it[] = "- ";
    strcat(s, it);
  }
  yylval.str = strdup(s);
  return LIST_TEXT;
}

<HYPERLINK>"{" {
  /**
  * @brief Handle opening braces in hyperlink commands.
  */
  --href_braces;
  char empty[] = "";
  yylval.str = strdup(empty);
  if(href_braces >= 2){
    return HREF_LINK;
  } else{
    return HREF_TEXT;
  }
} 

<IMAGELINK>"\["|"\{" {
  /**
  * @brief Handle opening braces in image link commands.
  */
  --image_braces;
  char empty[] = "";
  yylval.str = strdup(empty);
  return IMAGE_PATH;
}

<HYPERLINK>[^{}]+ {
  /**
  * @brief Match text content inside hyperlink commands.
  */
  yylval.str = strdup(yytext);
  if(href_braces == 3){
    return HREF_LINK;
  } else if(href_braces == 1){
    return HREF_TEXT;
  }
}

<IMAGELINK>[^\[\]{}]* {
  /**
  * @brief Match text content inside image link commands.
  */
  if(image_braces <= 2){
    yylval.str = strdup(yytext);
  } else{
    char empty[] = "";
    yylval.str = strdup(empty);
  }
  return IMAGE_PATH;
}

<HYPERLINK>"}" {
  /**
  * @brief Handle closing braces in hyperlink commands.
  */
  --href_braces;
  char empty[] = "";
  yylval.str = strdup(empty);
  if(href_braces == 0){
    yy_pop_state();
  }
  if(href_braces >= 2){
    return HREF_LINK;
  } else{
    return HREF_TEXT;
  }
}

<IMAGELINK>("}"|"\]") {
  /**
  * @brief Handle closing braces in image link commands.
  */
  --image_braces;
  char empty[] = "";
  yylval.str = strdup(empty);
  if(image_braces == 0){
    yy_pop_state();
  }
  return IMAGE_PATH;
}

<BODY>[ \n]*"\\begin{verbatim}"[\n]? {
  /**
  * @brief Match the beginning of a verbatim block.
  */
  yy_push_state(VERBATIM);
  return VERBATIM_START;
}

<VERBATIM>"\\end{verbatim}"[ \n]* {
  /**
  * @brief Match the end of a verbatim block.
  */
  yy_pop_state();
  return VERBATIM_END;
}

<VERBATIM>[ \n]+ {
  /**
  * @brief Match whitespace inside a verbatim block.
  */
  yylval.str = strdup(yytext);
  return CODE;
}

<VERBATIM>[^ \\\n]+ {
  /**
  * @brief Match non-whitespace characters inside a verbatim block.
  */
  yylval.str = strdup(yytext);
  return CODE;
}

<VERBATIM>[\\]+ {
  /**
  * @brief Match backslashes inside a verbatim block.
  */
  yylval.str = strdup(yytext);
  return CODE;
}

<VERBATIM>\n {
  /**
  * @brief Match newlines inside a verbatim block.
  */
  char nl[] = "\n";
  yylval.str = strdup(nl);
  return CODE;
}

<BODY,BOLD,ITALICS>"\\textbf\{"[ \n]* {
  /**
  * @brief Match the beginning of a bold text block.
  */
  if(!yy_is_bold) yy_push_state(BOLD);
  yy_is_bold = true;
  return BOLD_START;
}

<BODY,BOLD,ITALICS>"\\textit\{"[ \n]* {
  /**
  * @brief Match the beginning of an italic text block.
  */
  if(!yy_is_italic) yy_push_state(ITALICS);
  yy_is_italic = true;
  return ITALICS_START;
}

<BOLD>[ \n]*"}" {
  /**
  * @brief Match the end of a bold text block.
  */
  yy_is_bold = false;
  yy_pop_state();
  return BOLD_END;
}

<ITALICS>[ \n]*"}" {
  /**
  * @brief Match the end of an italic text block.
  */
  yy_is_italic = false;
  yy_pop_state();
  return ITALICS_END;
}

<BODY,BOLD,ITALICS,ULIST,OLIST>([^ \\\n\}]+) {
  /**
  * @brief Match words inside bold or italic blocks or regular text.
  */
  yylval.str = strdup(yytext);
  if(YYSTATE == 9 || YYSTATE == 10) {
    return LIST_TEXT;
  }
  return WORD;
};

<BODY>[ ]*[\n]{2,}[ ]* {
  /**
  * @brief Match multiple newlines, typically used as paragraph breaks.
  */
  char nl[] = "\n\n";
  yylval.str = strdup(nl);
  return EOL;
}

<*>[ \n]*"\\hrule"[ \n] {
  /**
  * @brief Match horizontal rules.
  */
  char rule[] = "\n\n---\n\n";
  yylval.str = strdup(rule);
  return HRULE;
}

<*>[ \n]*"\\par"[ \n] {
  /**
  * @brief Match paragraph breaks.
  */
  char rule[] = "\n\n";
  yylval.str = strdup(rule);
  return PAR;
}

<BODY,BOLD,ITALICS,ULIST,OLIST>[ ]*[\n]{0,1}[ ]* {
  /**
  * @brief Match single spaces.
  */
  char sp[] = " ";
  yylval.str = strdup(sp);
  if(YYSTATE == 9 || YYSTATE == 10) {
    return LIST_TEXT;
  }
  return SPACE;
}

%%

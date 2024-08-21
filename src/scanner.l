%option noyywrap stack
%{
#include "parser.tab.h"
#include "src/AST.hpp"

bool yy_is_bold = false;
bool yy_is_italic = false;

int href_braces;
int image_braces;
int section_braces;

%}
/* States declarations */
%x PREAMBLE
%x BODY
%x BOLD
%x ITALICS
%x VERBATIM
%x HYPERLINK
%x IMAGELINK
%x SECTION_ANY
%%

"\\begin{document}"[ \n]* {
  yy_push_state(BODY);
  yy_is_bold = false;
  yy_is_italic = false;
  return BEGIN_DOC;
}

<BODY>[ \n]*"\\end{document}" {
  yy_pop_state();
  return END_DOC;
}

<*>"\\href" {
  yy_push_state(HYPERLINK);
  href_braces = 4;
  return HYPER_LINK;
}

<*>"\\includegraphics" {
  yy_push_state(IMAGELINK);
  image_braces = 4;
  return IMAGE;
}

<*>"\\section" {
  section_braces = 2;
  yy_push_state(SECTION_ANY);
  return SECTION;
}

<*>"\\subsection" {
  section_braces = 2;
  yy_push_state(SECTION_ANY);
  return SUBSECTION;
}

<*>"\\subsubsection" {
  section_braces = 2;
  yy_push_state(SECTION_ANY);
  return SUBSUBSECTION;
}

<SECTION_ANY>"{"|"}" {
  --section_braces;
  if(section_braces == 0){
    yy_pop_state();
  }
  char empty[] = "";
  yylval.str = strdup(empty);
  return SECTION_TEXT;
}

<SECTION_ANY>[^{}]+ {
  yylval.str = strdup(yytext);
  return SECTION_TEXT;
}

<HYPERLINK>"{" {
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
  --image_braces;
  char empty[] = "";
  yylval.str = strdup(empty);
  return IMAGE_PATH;
}

<HYPERLINK>[^{}]+ {
  yylval.str = strdup(yytext);
  if(href_braces == 3){
    return HREF_LINK;
  } else if(href_braces == 1){
    return HREF_TEXT;
  }
}

<IMAGELINK>[^\[\]{}]* {
  if(image_braces <= 2){
    yylval.str = strdup(yytext);
  } else{
    char empty[] = "";
    yylval.str = strdup(empty);
  }
  return IMAGE_PATH;
}

<HYPERLINK>"}" {
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
  --image_braces;
  char empty[] = "";
  yylval.str = strdup(empty);
  if(image_braces == 0){
    yy_pop_state();
  }
  return IMAGE_PATH;
}

<BODY>[ \n]*"\\begin{verbatim}"[\n]? {
  yy_push_state(VERBATIM);
  return VERBATIM_START;
}

<VERBATIM>"\\end{verbatim}"[ \n]* {
  yy_pop_state();
  return VERBATIM_END;
}

<VERBATIM>[ \n]+ {
  yylval.str = strdup(yytext);
  return CODE;
}

<VERBATIM>[^ \\\n]+ {
  yylval.str = strdup(yytext);
  return CODE;
}

<VERBATIM>[\\]+ {
  yylval.str = strdup(yytext);
  return CODE;
}

<VERBATIM>\n {
  char nl[] = "\n";
  yylval.str = strdup(nl);
  return CODE;
}

<BODY,BOLD,ITALICS>"\\textbf\{"[ \n]* {
  if(!yy_is_bold) yy_push_state(BOLD);
  yy_is_bold = true;
  return BOLD_START;
}

<BODY,BOLD,ITALICS>"\\textit\{"[ \n]* {
  if(!yy_is_italic) yy_push_state(ITALICS);
  yy_is_italic = true;
  return ITALICS_START;
}

<BOLD>[ \n]*"}" {
  yy_is_bold = false;
  yy_pop_state();
  return BOLD_END;
}

<ITALICS>[ \n]*"}" {
  yy_is_italic = false;
  yy_pop_state();
  return ITALICS_END;
}

<BODY,BOLD,ITALICS>([^ \\\n\}]+) {
  yylval.str = strdup(yytext);
  return WORD;
};

<BODY>[ ]*[\n]{2,}[ ]* {
  char nl[] = "\n\n";
  yylval.str = strdup(nl);
  return EOL;
}

<*>[ \n]*"\\hrule"[ \n] {
  char rule[] = "\n\n---\n\n";
  yylval.str = strdup(rule);
  return HRULE;
}

<*>[ \n]*"\\par"[ \n] {
  char rule[] = "\n\n";
  yylval.str = strdup(rule);
  return PAR;
}

<BODY,BOLD,ITALICS>[ ]*[\n]{0,1}[ ]* {
  char sp[] = " ";
  yylval.str = strdup(sp);
  return SPACE;
}

%%

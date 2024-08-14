%option noyywrap stack
%{
#include "parser.tab.h"
#include "src/AST.hpp"

bool yy_is_bold = false;
bool yy_is_italic = false;

%}
/* States declarations */
%x PREAMBLE
%x BODY
%x BOLD
%x ITALICS
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

<BODY,BOLD,ITALICS>[ ]*[\n]{0,1}[ ]* {
  char sp[] = " ";
  yylval.str = strdup(sp);
  return SPACE;
}

%%

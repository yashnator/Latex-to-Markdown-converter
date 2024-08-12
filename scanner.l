%option noyywrap
%{
#include "parser.tab.h"
#include "AST.hpp"
%}
/* States declarations */
%x PREAMBLE
%x BODY
%x BOLD
%%

"\\begin{document}"[\n]+ {
  BEGIN BODY;
  return BEGIN_DOC;
}

<BODY>"\\end{document}" {
  BEGIN INITIAL;
  return END_DOC;
}

<BODY>([^\\\n]+) {
  yylval.str = strdup(yytext);
  return SENTENCE;
};

<BODY>[\n]{2,} {
  return EOL;
}

<BODY>[\n] {
  return SPACE;
}

%%

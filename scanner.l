%option noyywrap
%{
#include "parser.tab.h"
%}
/* States declarations */
%x TABLE 
%x VERBATIM
%x PREAMBLE
%%

"\\begin{document}" {
  return BEGIN_DOC;
}

"\\end{document}" {
  return END_DOC;
}

\n { }
%%

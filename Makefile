all: main.out

main.out: src/scanner.l src/parser.y 
	bison -d src/parser.y -Wcounterexamples
	flex src/scanner.l
	g++ -o $@ parser.tab.c lex.yy.c src/ast.cpp -ll

.PHONY: clean re

clean:
	rm -rf lex.yy.c parser.tab.c parser.tab.h main.out

re: clean all
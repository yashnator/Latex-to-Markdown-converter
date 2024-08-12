main.out: scanner.l parser.y
	bison -d parser.y
	flex scanner.l
	g++ -o $@ parser.tab.c lex.yy.c -ll
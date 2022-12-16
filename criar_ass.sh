bison -d comp.y
flex comp.flex
gcc comp.tab.c lex.yy.c -lfl -o comp
./comp < entrada.c

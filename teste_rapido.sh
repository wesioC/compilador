bison -d comp.y
flex comp.flex
gcc comp.tab.c lex.yy.c -lfl -o comp
./comp < entrada3.c

as out.s -o out.o
ld -s -o out out.o
./out
echo $?
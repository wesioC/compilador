as out.s -o out.o
ld -s -o out out.o
./out
echo $?
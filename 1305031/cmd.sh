bison -d -y 1305031.y
echo '1'
g++ -w -c -o y.o y.tab.c
echo '2'
flex 1305031.l
echo '3'
g++ -w -c -o l.o lex.yy.c
echo '4'
g++ -o a.out y.o l.o -lfl -ly
echo '5'
./a.out in.txt

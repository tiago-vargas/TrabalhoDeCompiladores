CC=g++
CFLAGS=-Wall -std=c++11
FLEX=flex
BISON=bison

all: tradutor

tradutor: parser.tab.o lex.yy.o main.o translator.o
	$(CC) $(CFLAGS) -o tradutor parser.tab.o lex.yy.o main.o translator.o -lfl

translator.o: translator.cpp translator.h ast.h
	$(CC) $(CFLAGS) -c translator.cpp

parser.tab.o: parser.tab.c
	$(CC) $(CFLAGS) -c parser.tab.c

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c lex.yy.c

main.o: main.cpp
	$(CC) $(CFLAGS) -c main.cpp

lex.yy.c: lexer.l parser.tab.h
	$(FLEX) lexer.l

parser.tab.c parser.tab.h: parser.y ast.h
	$(BISON) -d parser.y

clean:
	rm -f tradutor *.o lex.yy.c parser.tab.c parser.tab.h
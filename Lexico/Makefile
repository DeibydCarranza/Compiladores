INPUT_FILE = lexico.l
lexico: lex.yy.c
	gcc -o lexico lex.yy.c -lfl

lex.yy.c: $(INPUT_FILE)
	flex $(INPUT_FILE)

.PHONY: clean

clean:
	rm -f lexico lex.yy.c \
    rm token archLite archSimbol

INPUT_FILE = semantico.l
semantico: lex.yy.c
	gcc -o semantico lex.yy.c -lfl

lex.yy.c: $(INPUT_FILE)
	flex $(INPUT_FILE)

.PHONY: clean

clean:
	rm -f semantico lex.yy.c \
    rm token archLite archSimbol atomos errores

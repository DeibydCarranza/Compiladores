INPUT_FILE = sintactico.l
sintactico: lex.yy.c
	gcc -o sintactico lex.yy.c -lfl

lex.yy.c: $(INPUT_FILE)
	flex $(INPUT_FILE)

.PHONY: clean

clean:
	rm -f sintactico lex.yy.c \
    rm token archLite archSimbol atomos errores

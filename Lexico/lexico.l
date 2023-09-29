%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *archSal;
char* reservadas[] = {"assinado","caso","enquanto","fazer","flutuador",
                      "inteiro","para","quebrar","retorno","se","trocar"};

void buscarPalabra(int clase,char* palabra,char**tabla,int size);
void tokenASCII(int clase, char* valorChar);
int sacarNum(char* cadenaNum);

typedef struct NodoSimbolos NodoSimbolos;
typedef struct ListaSimbolos ListaSimbolos;
typedef struct Simbolos Simbolos;

typedef struct NodoLiterales NodoLiterales;
typedef struct ListaLiterales ListaLiterales;
typedef struct Literales Literales;

/* Definición de estructuras para SIMBOLOS*/
struct Simbolos {
    int pos;
    char *identificador;
    int tipo;
};

struct NodoSimbolos {
    struct Simbolos tabSimb;
    struct NodoSimbolos *next;
};

struct ListaSimbolos {
    struct NodoSimbolos *head;
    int cantidad;
};

ListaSimbolos crearListaSimbolos() {
	ListaSimbolos lista;
	lista.head = NULL;	//Cabeza de la lista
	lista.cantidad = 0; //Es incremental, define la posición
	return lista;
}

/* Definición de estructuras para LITERALES*/
struct Literales {
    int pos;
    char *cadena;
};

struct NodoLiterales {
    struct Literales tabLiterales;
    struct NodoLiterales *next;
};

struct ListaLiterales {
    struct NodoLiterales *head;
    int cantidad;
};

ListaLiterales crearListaLiterales() {
	ListaLiterales lista;
	lista.head = NULL;	//Cabeza de la lista
	lista.cantidad = 0; //Es incremental, define la posición
	return lista;
}


%}
palRes     ("assinado"|"caso"|"enquanto"|"fazer"|"flutuador"|"inteiro"|"para"|"quebrar"|"retorno"|"se"|"trocar")
espaSalTab [ \t\n]
signo      [+\-]
digito     [1-9]
numero     0|{digito}(0|{digito})*
cteEnt     ("("{signo}{numero}")")|{numero}
opMulDiv   ("*"|"/"|"%")
opArit     ({signo}|{opMulDiv})
opLog      ("&&"|"||"|"!")
opRel      ([><=!]=|>|<)
letra      [a-zA-Z]
ident      _({letra}|{digito}|0|_)+
simbEsp    ("("|")"|"{"|"}"|";"|","|"["|"]"|":"|"#")
opAsig     ({signo}|{opMulDiv})?=
cteCad     (\"([^\"]|\\.)*\")
opCad      (&|like)
%%
{opArit}     {tokenASCII(0,yytext);}
{cteEnt}     {sacarNum(yytext);}
{opLog}      {printf("%s es un operador logico\n",yytext);}
{opRel}      {printf("%s es un operador relacional\n",yytext);}
{palRes}     {printf("%s es una palabra reservada\n",yytext);}
{ident}      {printf("%s es un identificador\n",yytext);}
{simbEsp}    {tokenASCII(6,yytext);}
{opAsig}     {printf("%s es un operador de asignacion\n",yytext);}
{cteCad}     {printf("%s es una constante cadena\n",yytext);}
{opCad}      {printf("%s es una operación sobre cadena\n",yytext);}
{espaSalTab} {}
.            {printf("%s [!] Símbolo no definido\n",yytext);}
%%
int main(int argc, char *argv[]){
	if ( (yyin=fopen(argv[1],"r"))==NULL){
		printf("[!] Error al abrir el archivo %s",argv[1]);
		return 1;
	}
	else{
		printf("[+] Lectura del archivo '%s' \n\n",argv[1]);
		archSal=fopen("token.txt","w");
		yylex();
		fclose(archSal);
	}
	fclose(yyin);
	return 0;
}

/* ---------------SECCIÓN DE CATÁLOGOS -------------------------*/

/* Token especial para clase de operadores aritméticos y símbolos especiales*/
void tokenASCII(int clase, char* valorChar){
	//Conversión del operador a ASCII 
	int valASC=(int)valorChar[0];
	//printf("%d,%d",clase,valASC);
	fprintf(archSal, "%d,%d\n",clase,valASC);
}

/*Obtiene el token de constantes numéricas enteras*/
int sacarNum(char* cadenaNum){
	int valor;
	unsigned int tamCad = strlen(cadenaNum);
	
	//Validando si inicia con '(' y termina con ')'
	if (cadenaNum[0] == '(' && cadenaNum[tamCad-1] == ')'){

		//Copia de la cadena original
		char *cadFiltrada = malloc(tamCad-2); //Se omitirá el inicio y final
		if (cadFiltrada != NULL){
			strncpy(cadFiltrada, cadenaNum+1, tamCad-2); //Se copia sin el primer ni último paréntesis
			valor = atoi(cadFiltrada);  // Cadena en un valor entero
		}
		free(cadFiltrada);

	}else{
		valor = atoi(cadenaNum);  // Cadena en un valor entero
	}
	//Generación de token
	fprintf(archSal, "%d,%d\n",3,valor);

}

void buscarPalabra(int clase,char* palabra,char** tabla,int size){ 
    for(int i=0;i<size;i++){
        if(strcmp(tabla[i],palabra)==0){
            printf("4,%d\n",i);
            break;
        }
    }
}








/*  ---------------SECCIÓN DE LISTAS LIGADAS -------------------------   */
/* Imprimiendo las listas con sus valores*/
void imprimirSimbolos(ListaSimbolos lista) {
    if(lista.head==NULL){
    	printf(" LA LISTA ESTA VACIA \n");
    }
    else{
		int i=0,tamano = lista.cantidad;
    	printf(" Los elementos de la lista son: \n");
    	NodoSimbolos *current = lista.head;
   		while (tamano > 0 ) { 
        	printf("Posición: %d\n", current->tabSimb.pos);
            printf("Nombre: %s\n", current->tabSimb.identificador);
			printf("Tipo: %d\n", current->tabSimb.tipo);

			current = current->next;
			tamano--;
   	 	}
	}
}

void imprimirLiterales(ListaLiterales lista) {
    if(lista.head==NULL){
    	printf(" LA LISTA ESTA VACIA \n");
    }
    else{
		int i=0,tamano = lista.cantidad;
    	printf(" Los elementos de la lista son: \n");
    	NodoLiterales *current = lista.head;
   		while (tamano > 0 ) { 
        	printf("Posición: %d\n", current->tabLiterales.pos);
            printf("Nombre: %s\n", current->tabLiterales.cadena);
			
			current = current->next;
			tamano--;
   	 	}
	}
}

/* Agregando elemento al final de la listas*/
void agregarListaSimbolos(struct ListaSimbolos *lista, struct Simbolos simb) {
	int posicion=lista->cantidad;
    
	//Si aún no hay elementos en la lista
	if (lista->head == NULL) {
		NodoSimbolos *nuevoNodo = (struct NodoSimbolos *)malloc(sizeof(struct NodoSimbolos));
		nuevoNodo->tabSimb = simb;
    	nuevoNodo->next = NULL;
        lista->head = nuevoNodo;
    } 
	//Considera la última posicion de la lista
	else {
        struct NodoSimbolos *current = lista->head;
        while (current->next != 0) { //Referencia nula
       		current = current->next;
 		}
		NodoSimbolos *nuevoNodo;
		nuevoNodo = (NodoSimbolos*)malloc(sizeof(NodoSimbolos));
		nuevoNodo->tabSimb = simb;
    	nuevoNodo->next = NULL;
        current->next = nuevoNodo;
    }
	lista->cantidad++;		//Aumento del tamaño de la lista -> referencia
}

void agregarListaLiterales(struct ListaLiterales *lista, struct Literales lit) {
	int posicion=lista->cantidad;
    
	//Si aún no hay elementos en la lista
	if (lista->head == NULL) {
		NodoLiterales *nuevoNodo = (struct NodoLiterales *)malloc(sizeof(struct NodoLiterales));
		nuevoNodo->tabLiterales = lit;
    	nuevoNodo->next = NULL;
        lista->head = nuevoNodo;
    } 
	//Considera la última posicion de la lista
	else {
        struct NodoLiterales *current = lista->head;
        while (current->next != 0) { //Referencia nula
       		current = current->next;
 		}
		NodoLiterales *nuevoNodo;
		nuevoNodo = (NodoLiterales*)malloc(sizeof(NodoLiterales));
		nuevoNodo->tabLiterales = lit;
    	nuevoNodo->next = NULL;
        current->next = nuevoNodo;
    }
	lista->cantidad++;		//Aumento del tamaño de la lista -> referencia
}


/* Regresa la posición del elemento, -1 si no existe para SIMBOLOS, compara 2 cadenas. Se busca si existe X*/
int buscarSimbolo(char* x, ListaSimbolos *lista) {
	NodoSimbolos *tmp=lista->head;
	
	if (tmp == NULL) { //Lista vacía
        return -1; 
    }

	while (tmp!=NULL){ 
		if (strcmp(tmp->tabSimb.identificador, x) == 0){ //Si son iguales ambas cadenas
			return tmp->tabSimb.pos;
		}else{
			tmp=tmp->next;
		}
	}
	return -1; 
}

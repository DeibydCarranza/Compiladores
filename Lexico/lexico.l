%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *archSal;
FILE *archSimbol;
FILE *archLite;

char* reservadas[] = {"assinado","caso","enquanto","fazer","flutuador",
                      "inteiro","para","quebrar","retorno","se","trocar"};
char* relacionales[] = {"==","!=",">","<",">=","<="};
char* logicos[] = {"&&","||","!"};
char* opCadenas[] = {"&","like"};
char* asignacion[] = {"=","+=","-=","*=","/=","%="};

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

ListaLiterales listLit;
Literales tabLiterales;

ListaSimbolos listSim;
Simbolos tabSimbolos;

void buscarPalabra(int clase,char* palabra,char**tabla,int size);
void tokenASCII(int clase, char* valorChar);
int sacarNum(int, char* cadenaNum);
void funcionTablas(int clase,char* ident);
void imprimirSimbolos(ListaSimbolos lista);
void imprimirLiterales(ListaLiterales lista);
void agregarListaSimbolos(struct ListaSimbolos *lista, struct Simbolos simb);
void buscarPalabra(int clase,char* palabra,char**tabla,int size);
void tokenASCII(int clase, char* valorChar);

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
{cteEnt}     {sacarNum(3,yytext);}
{opLog}      {buscarPalabra(1,yytext,logicos,sizeof(logicos)/sizeof(logicos[0]));}
{opRel}      {buscarPalabra(2,yytext,relacionales,sizeof(relacionales)/sizeof(relacionales[0]));}
{palRes}     {buscarPalabra(4,yytext,reservadas,sizeof(reservadas)/sizeof(reservadas[0]));}
{ident}      {funcionTablas(5,yytext);}
{simbEsp}    {tokenASCII(6,yytext);}
{opAsig}     {buscarPalabra(7,yytext,asignacion,sizeof(asignacion)/sizeof(asignacion[0]));}
{cteCad}     {funcionTablas(8,yytext);}
{opCad}      {buscarPalabra(9,yytext,opCadenas,sizeof(opCadenas)/sizeof(opCadenas[0]));}
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
		archSimbol=fopen("archSimbol.txt","w");
		archLite=fopen("archLite.txt","w");

		
		yylex();
		imprimirSimbolos(listSim);
		imprimirLiterales(listLit);

		fclose(archSal);
		fclose(archSimbol);
		fclose(archLite);

	}
	fclose(yyin);
	return 0;
}

/* ---------------SECCIÓN DE CATÁLOGOS -------------------------*/

/* Token especial para clase de operadores aritméticos y símbolos especiales*/
void tokenASCII(int clase, char* valorChar){
	//Conversión del operador a ASCII 
	int valASC=(int)valorChar[0];
	fprintf(archSal, "%d,%d   Op Arit/ Simb Esp\n",clase,valASC); 	
}

/*Obtiene el token de constantes numéricas enteras*/
int sacarNum(int clase, char* cadenaNum){
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
	fprintf(archSal, "%d,%d   Cte NUM\n",clase,valor); 		//Clase 3 -> CTE numéricas

}

/* Itera sobre los catalogos hasta encontrar la palabra encontrada por la expresión regular
   para asignar el valor al token, la clase se pasa en cada caso de las expresiones regulares*/
void buscarPalabra(int clase,char* palabra,char** tabla,int size){ 
    for(int valor=0;valor<size;valor++){
        if(strcmp(tabla[valor],palabra)==0){
			fprintf(archSal,"%d,%d   %s\n",clase,valor,palabra);
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
		int tamano = lista.cantidad;
    	NodoSimbolos *current = lista.head;
   		while (current != NULL ) { 
        	fprintf(archSimbol,"Posicion: %d\n", current->tabSimb.pos);
            fprintf(archSimbol,"Nombre: %s\n", current->tabSimb.identificador);
			fprintf(archSimbol,"Tipo: %d\n\n", current->tabSimb.tipo);
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
    	NodoLiterales *current = lista.head;
   		while (tamano > 0 ) { 
        	fprintf(archLite,"Posicion: %d\n", current->tabLiterales.pos);
            fprintf(archLite,"Nombre: %s\n", current->tabLiterales.cadena);
			
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
	printf("----------------%s", x);

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


/* Creación de estructura para SIMBOLOS*/
void funcionTablas(int clase, char* ident){

	if(clase == 5 && buscarSimbolo(ident,&listSim)==-1){
		Simbolos tabla;
		tabla.pos = listSim.cantidad;
		tabla.identificador = strdup(ident);
		tabla.tipo = -1;
		
		agregarListaSimbolos(&listSim, tabla);
		fprintf(archSal, "%d,%d  Indetificador\n",clase,tabla.pos); 	//Clase 5 -> Identificadores

	}
	else if (clase == 8){
		Literales tabla;
		tabla.pos = listLit.cantidad;
		tabla.cadena = strdup(ident);

		agregarListaLiterales(&listLit, tabla);
		fprintf(archSal, "%d,%d  Literal (Cad)\n",clase,tabla.pos); 	//Clase 8 -> CTE cad 
	}
}
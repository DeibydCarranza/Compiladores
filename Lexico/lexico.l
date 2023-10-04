%{
//BIBLIOTECAS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//ESTRUCTURAS
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
    struct NodoSimbolos* head;
    int cantidad;
};
ListaSimbolos crearListaSimbolos(){
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

//GLOBALES
FILE *tab_tokens;
FILE *tab_simbolos;
FILE *tab_literales;
char* ERROR;
char* reservadas[]   = {"assinado","caso","enquanto","fazer","flutuador","inteiro","para","quebrar","retorno","se","trocar"};
char* relacionales[] = {"==","!=",">","<",">=","<="};
char* logicos[]      = {"&&","||","!"};
char* opCadenas[]    = {"&","like"};
char* asignacion[]   = {"=","+=","-=","*=","/=","%="};
ListaLiterales listLit;
Literales tabLiterales;
ListaSimbolos listSim;
Simbolos tabSimbolos;
int yylineno_anterior;
//ENCABEZADOS
void buscarPalabra(int ,char* ,char**,int );
void tokenASCII(int , char* );
int sacarNum(int, char* );
void funcionTablas(int ,char* );
void imprimirSimbolos(ListaSimbolos );
void imprimirLiterales(ListaLiterales );
void agregarListaSimbolos(ListaSimbolos *, Simbolos);
void yyerror(char*);
void printCaracter_NoHeader(char*);
void printCaracter_Header(char*);

%}
%option yylineno
palRes        ("assinado"|"caso"|"enquanto"|"fazer"|"flutuador"|"inteiro"|"para"|"quebrar"|"retorno"|"se"|"trocar")
espaSalTab    [ \t\n]
signo         [+\-]
digito        [1-9]
numero        0|{digito}(0|{digito})*
cteEnt        ("("{signo}{numero}")")|{numero}
opMulDiv      ("*"|"/"|"%")
opArit        ({signo}|{opMulDiv})
opLog         ("&&"|"||"|"!")
opRel         ([><=!]=|>|<)
letra         [a-zA-Z]
ident         _({letra}|{digito}|0|_)+
simbEsp       ("("|")"|"{"|"}"|";"|","|"["|"]"|":"|"#")
opAsig        ({signo}|{opMulDiv})?=
cteCad        (\"([^\"]|\\.)*\")
opCad         (&|like)
%%
{opArit}      {tokenASCII(0,yytext);}
{cteEnt}      {sacarNum(3,yytext);}
{opLog}       {buscarPalabra(1,yytext,logicos,sizeof(logicos)/sizeof(logicos[0]));}
{opRel}       {buscarPalabra(2,yytext,relacionales,sizeof(relacionales)/sizeof(relacionales[0]));}
{palRes}      {buscarPalabra(4,yytext,reservadas,sizeof(reservadas)/sizeof(reservadas[0]));}
{ident}       {funcionTablas(5,yytext);}
{simbEsp}     {tokenASCII(6,yytext);}
{opAsig}      {buscarPalabra(7,yytext,asignacion,sizeof(asignacion)/sizeof(asignacion[0]));}
{cteCad}      {funcionTablas(8,yytext);}
{opCad}       {buscarPalabra(9,yytext,opCadenas,sizeof(opCadenas)/sizeof(opCadenas[0]));}
{espaSalTab}  {} 																						// iganoramos lo saltos de linea para que no se resetee yylineno
.             {yyerror(yytext);}
%%
int main(int argc, char *argv[]){
	if(argc > 1){
		if ( (yyin=fopen(argv[1],"r"))==NULL){
			printf("compilador: \033[1;31m error: \033[1;0m no such file or directory: %s\ncompilador:\033[1;31m error:\033[1;0m no input files",argv[1]);
			exit(EXIT_FAILURE);
		}else{
			// Abrimos archivos
			tab_tokens=fopen("token","w");
			tab_simbolos=fopen("archSimbol","w");
			tab_literales=fopen("archLite","w");

			// iniciamos el analizador léxico
			yylex();

			// Guardamos tabla de simbolos y literales
			imprimirSimbolos(listSim);
			imprimirLiterales(listLit);

			// Cerramos archivos
			fclose(tab_tokens);
			fclose(tab_simbolos);
			fclose(tab_literales);
			fclose(yyin);
		}
	}else{
		 printf("compilador:\033[1;31m error:\033[1;0m no input files\n");
		 exit(EXIT_FAILURE);
	}
	exit(EXIT_SUCCESS);
}

/* ---------------SECCIÓN DE CATÁLOGOS -------------------------*/

/* Token especial para clase de operadores aritméticos y símbolos especiales*/
void tokenASCII(int clase, char* valorChar){
	//Conversión del operador a ASCII 
	int valASC=(int)valorChar[0];
	fprintf(tab_tokens, "%d,%d   Op Arit/ Simb Esp\n",clase,valASC); 	
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
			free(cadFiltrada);
		}else{
			printf("[!] ERROR: interno - asignación de memoria");
		}
	}else{
		valor = atoi(cadenaNum);  // Cadena en un valor entero
	}
	//Generación de token
	fprintf(tab_tokens, "%d,%d   Cte NUM\n",clase,valor); 		//Clase 3 -> CTE numéricas
}

/* Itera sobre los catalogos hasta encontrar la palabra encontrada por la expresión regular
   para asignar el valor al token, la clase se pasa en cada caso de las expresiones regulares*/
void buscarPalabra(int clase,char* palabra,char** tabla,int size){ 
    for(int valor=0;valor<size;valor++){
        if(strcmp(tabla[valor],palabra)==0){
			fprintf(tab_tokens,"%d,%d   %s\n",clase,valor,palabra);
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
            fprintf(tab_simbolos,"%d,%s,%d", current->tabSimb.pos, current->tabSimb.identificador, current->tabSimb.tipo);
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
        	fprintf(tab_literales,"%d,%s\n", current->tabLiterales.pos,current->tabLiterales.cadena);
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
		NodoSimbolos *nuevoNodo = (NodoSimbolos*)malloc(sizeof(NodoSimbolos));
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
		NodoLiterales *nuevoNodo = (NodoLiterales*)malloc(sizeof(NodoLiterales));
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
	// Se copia el Nodo inicial de la lista 
	NodoSimbolos* tmp=lista->head;
	while (tmp!=NULL){ 
		if (strcmp(tmp->tabSimb.identificador, x) == 0){ //Si son iguales ambas cadenas
			return tmp->tabSimb.pos;
		}else{
			tmp=tmp->next;
		}
	}
	return -1; 
}


/* Rellenando Tabla Simbolos y Literales, y escribiendo tokens*/
void funcionTablas(int clase, char* ident){
	// identificadores
	if(clase == 5){
		Simbolos tabla;
		int busqueda = buscarSimbolo(ident,&listSim);
		// Si no existe
		if(busqueda == -1){
			tabla.pos = listSim.cantidad;
			tabla.identificador = strdup(ident);
			tabla.tipo = -1;
			agregarListaSimbolos(&listSim, tabla);
			fprintf(tab_tokens, "%d,%d\n",clase,tabla.pos); 
		}	
		// Si existe
		else{
			fprintf(tab_tokens, "%d,%d\n",clase,busqueda); 
		}

	}
	// constantes de cadenas
	else{
		Literales tabla;
		tabla.pos = listLit.cantidad;
		tabla.cadena = strdup(ident);

		agregarListaLiterales(&listLit, tabla);
		fprintf(tab_tokens, "%d,%d\n",clase,tabla.pos); 	//Clase 8 -> CTE cad 
	}
}

*/*/
void yyerror(char* mensaje){
	if(yylineno != yylineno_anterior ){
		fprintf(stderr,"\n");
		printCaracter_NoHeader(mensaje);
		// Actualizamos la línea donde se encontro el caracter erroneo
		yylineno_anterior = yylineno;
	}else{
		printCaracter_Header(mensaje);
	}
}

// Imprimir icinio de una cadena errornea 
void printCaracter_NoHeader(char* caracter){
	fprintf(stderr,"Compilador:%d\033[1;31m error:\033[1;0m %s",yylineno,caracter);
}
// Imprimir elementos de la cadena errornea antes encontrada
void printCaracter_Header(char* caracter){
	fprintf(stderr,"%s",caracter);
}
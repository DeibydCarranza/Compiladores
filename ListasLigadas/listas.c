#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
int buscarLiteral(char* x, ListaSimbolos *lista) {
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
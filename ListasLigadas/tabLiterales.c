#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Nodo Nodo;
typedef struct Lista Lista;
typedef struct Literales Literales;

struct Literales{ 
	int pos;
	char *nombre;
};

struct Nodo{
    struct Literales tabLiterales;
    struct Nodo* next;
};

struct Lista{
	struct Nodo* head;
	int cantidad;
};

Lista crearLista(){
	Lista lista;
	lista.head = NULL;	//Cabeza de la lista
	lista.cantidad = 0; //Es incremental, define la posición
	return lista;
}


/* Imprimiendo la lista con sus valores*/
void imprimir(Lista lista) {
    if(lista.head==NULL){
    	printf(" LA LISTA ESTA VACIA \n");
    }
    else{
		int i=0,tamano = lista.cantidad;
    	printf(" Los elementos de la lista son: \n");
    	Nodo *current = lista.head;
   		while (tamano > 0 ) { 
        	printf("Posición: %d\n", current->tabLiterales.pos);
            printf("Nombre: %s\n", current->tabLiterales.nombre);
			
			current = current->next;
			tamano--;
   	 	}
	}
}

/* Agregando elemento al final de la lista*/
void agregarLista(struct Lista *lista, struct Literales lit) {
	int posicion=lista->cantidad;
    
	//Si aún no hay elementos en la lista
	if (lista->head == NULL) {
		Nodo *nuevoNodo = (struct Nodo *)malloc(sizeof(struct Nodo));
		nuevoNodo->tabLiterales = lit;
    	nuevoNodo->next = NULL;
        lista->head = nuevoNodo;
    } 
	//Considera la última posicion de la lista
	else {
        struct Nodo *current = lista->head;
        while (current->next != 0) { //Referencia nula
       		current = current->next;
 		}
		Nodo *nuevoNodo;
		nuevoNodo = (Nodo*)malloc(sizeof(Nodo));
		nuevoNodo->tabLiterales = lit;
    	nuevoNodo->next = NULL;
        current->next = nuevoNodo;
    }
	lista->cantidad++;		//Aumento del tamaño de la lista -> referencia
}




void opciones(){
	printf("\n\t\a -------------------------------------------");
	printf("\n\t | 1) Ver elementos de la lista             |");
	printf("\n\t | 2) Agregar elementos al final            |");
	printf("\n\t | 3) Salir                                 |");
	printf("\n\t  -------------------------------------------    Seleccione una opci%cn: ",162);
}

Literales ingresar(Lista *lista){
	Literales tabla;
	fflush(stdin);
	printf(" Ingrese la pos -> (Automatico incremental juas juas) \n");
	tabla.pos = lista->cantidad;

	printf(" Ingrese la cadena -> ");
    char nombre_buffer[256]; // Ajusta el tamaño según tus necesidades
    fgets(nombre_buffer, sizeof(nombre_buffer), stdin);
    
    // Eliminar el carácter de nueva línea del final de la cadena
    size_t length = strlen(nombre_buffer);
    if (length > 0 && nombre_buffer[length - 1] == '\n') {
        nombre_buffer[length - 1] = '\0';
    }
    
    // Asignar la cadena al campo nombre de la estructura
    tabla.nombre = strdup(nombre_buffer);

	return tabla; 
}


int main(){
	Lista list;
	Literales tabLiterales;

	int opc;
	list = crearLista();
	
	do{
		opciones();
		scanf("%i", &opc);
		
		switch(opc){
			case 1: //Ver elementos de la lista
				fflush(stdin);
				imprimir(list);
				break;
			case 2: //Agregar final
				tabLiterales = ingresar(&list);
				agregarLista(&list,tabLiterales);
				break;
			case 3: //Salir
				break;
			default:
				printf("\nOpcion inv%clida",160);
				break;				
		}
	}while(opc!=4);
	
	Nodo *current = list.head;
    while (current != NULL) {
        Nodo *temp = current;
        current = current->next;
        free(temp->tabLiterales.nombre);
        free(temp);
    }
    list.head = NULL;
	return 0;
}

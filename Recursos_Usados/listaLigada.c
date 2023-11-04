#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Nodo Nodo;
typedef struct Lista Lista;
typedef struct Simbolos Simbolos;

struct Simbolos{ 
	int pos;
	char *nombre;
	int tipo;
};

struct Nodo{
    struct Simbolos tabSimb;
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
        	printf("Posición: %d\n", current->tabSimb.pos);
            printf("Nombre: %s\n", current->tabSimb.nombre);
            printf("Tipo: %d\n", current->tabSimb.tipo);
			
			current = current->next;
			tamano--;
   	 	}
	}
}

/* Agregando elemento al final de la lista*/
void agregarLista(struct Lista *lista, struct Simbolos simb) {
	int posicion=lista->cantidad;
    
	//Si aún no hay elementos en la lista
	if (lista->head == NULL) {
		Nodo *nuevoNodo = (struct Nodo *)malloc(sizeof(struct Nodo));
		nuevoNodo->tabSimb = simb;
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
		nuevoNodo->tabSimb = simb;
    	nuevoNodo->next = NULL;
        current->next = nuevoNodo;
    }
	lista->cantidad++;		//Aumento del tamaño de la lista -> referencia
}


/* Regresa la posición del elemento, -1 si no existe*/
int buscar(char* x, Lista *lista){
	Nodo *tmp=lista->head;
	
	if (tmp == NULL) { //Lista vacía
        return -1; 
    }

	while (tmp!=NULL){ 
		if (strcmp(tmp->tabSimb.nombre, x) == 0){ //Si son iguales ambas cadenas
			return tmp->tabSimb.pos;
		}else{
			tmp=tmp->next;
		}
	}
	return -1; 
}



void opciones(){
	printf("\n\t\a -------------------------------------------");
	printf("\n\t | 1) Ver elementos de la lista             |");
	printf("\n\t | 2) Agregar elementos al final            |");
	printf("\n\t | 3) Buscar un elemento                    |");
	printf("\n\t | 4) Salir                                 |");
	printf("\n\t  -------------------------------------------    Seleccione una opci%cn: ",162);
}

Simbolos ingresar(Lista *lista){
	Simbolos tabla;
	fflush(stdin);
	printf(" Ingrese la pos -> (Automatico incremental juas juas) \n");
	tabla.pos = lista->cantidad;

	printf(" Ingrese el nombre del ident -> ");
    char nombre_buffer[256]; // Ajusta el tamaño según tus necesidades
    fgets(nombre_buffer, sizeof(nombre_buffer), stdin);
    
    // Eliminar el carácter de nueva línea del final de la cadena
    size_t length = strlen(nombre_buffer);
    if (length > 0 && nombre_buffer[length - 1] == '\n') {
        nombre_buffer[length - 1] = '\0';
    }
    
    // Asignar la cadena al campo nombre de la estructura
    tabla.nombre = strdup(nombre_buffer);

	printf(" Ingrese el tipo -> -1 (Automatico)\n");
		tabla.tipo = -1;
	return tabla; 
}



void caso3(Lista *lis) {
    int pos = -1;
    char *x = NULL;

    fflush(stdin);
    printf("\n Ingresa la cadena a buscar: ");

    size_t buffer_size = 256;
    x = (char *)malloc(buffer_size * sizeof(char));

    if (x == NULL) {
        printf(" [!] Error de asignación de memoria\n");
        exit(1);
    }

    fgets(x, buffer_size, stdin);

    // Eliminar el carácter de nueva línea del final de la cadena
    size_t length = strlen(x);
    if (length > 0 && x[length - 1] == '\n') {
        x[length - 1] = '\0';
    }

    pos = buscar(x, lis);
    printf("\n Se encontro en la posicion %d\n", pos);

    free(x);
}




int main(){
	Lista list;
	Simbolos tabSimbolos;

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
				tabSimbolos = ingresar(&list);
				agregarLista(&list,tabSimbolos);
				break;
			case 3: //Buscar
				caso3(&list);				
				fflush(stdin);
				break;
			case 4: //Salir
				fflush(stdin);
				break;
			default:
				printf("\nOpcion inv%clida",160);
				break;				
		}
	}while(opc!=11);
	
	Nodo *current = list.head;
    while (current != NULL) {
        Nodo *temp = current;
        current = current->next;
        free(temp->tabSimb.nombre);
        free(temp);
    }
    list.head = NULL;
	return 0;
}

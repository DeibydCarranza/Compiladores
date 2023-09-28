#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Tablas.h"



void crearTabla(char* lista[], CLexico* nombreTabla[],int sizeTable){
    for(int i=0;i<sizeTable;i++){
        nombreTabla[i]=crearPalabra(lista[i],i);
    }
}   

CLexico* crearPalabra(char *name, int indicador) {
    // Reserva memoria para la estructura
    CLexico *palabra = (CLexico*)malloc(sizeof(CLexico));
    // Reserva memoria para el nombre y copia la cadena
    palabra->nombre = strdup(name);
    // Asigna el índice
    palabra->indice = indicador;
    return palabra;
}

void escribirEnArchivo(CLexico* reservadas[], int num_reservadas, const char *nombre_archivo) {
    FILE *archivo = fopen(nombre_archivo, "w");

    if (archivo == NULL) {
        fprintf(stderr, "Error al abrir el archivo %s\n", nombre_archivo);
        return;
    }

    // Escribir encabezados
    fprintf(archivo, "Indice,Nombre\n");

    // Escribir datos
    for (int i = 0; i < num_reservadas; i++) {
        fprintf(archivo, "%d,%s\n", reservadas[i]->indice, reservadas[i]->nombre);
    }

    fclose(archivo);
}


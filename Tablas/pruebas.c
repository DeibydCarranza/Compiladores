#include <stdio.h>
#include "Tablas.h"

int main(){
    char* pReservadas[11] = {"assassinato", "caso", "equanto", "fazer", "flutuador", 
                          "inteiro", "para", "quebrar", "retorno", "se", "trocar"};
    CLexico *reservadas[11];
    crearTabla (pReservadas,reservadas, 11);
    escribirEnArchivo(reservadas,11,"TReservadas.csv");

    char* opRelacional[6]={"==","!=",">","<",">=","<="};
    CLexico* relacional[6];
    crearTabla (opRelacional,relacional,6);
    escribirEnArchivo(relacional,6,"TRelacional.csv");
    
    char* opLogicos[3]={"&&","||","!"};
    CLexico* logicos[3];
    crearTabla (opLogicos,logicos,3);
    escribirEnArchivo(logicos,3,"TLogicos.csv");
    
    char* opCadenas[2]={"&","like"};
    CLexico* cadenas[2];
    crearTabla(opCadenas,cadenas,2);
    escribirEnArchivo(cadenas,2,"TOpCadenas.csv");
    
    char* opAsignacion[6]={"=","+=","-=","*=","/=","%="};
    CLexico* asignacion[6];
    crearTabla(opAsignacion,asignacion,6);
    escribirEnArchivo(asignacion,6,"TAsignacion.csv");
    return 0;
}

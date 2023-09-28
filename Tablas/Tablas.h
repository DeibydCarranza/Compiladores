typedef struct CLexico {
    int indice;
    char *nombre;
} CLexico;

CLexico* crearPalabra(char *name, int indicador);
void escribirEnArchivo(CLexico* reservadas[], int num_reservadas, const char *nombre_archivo);
void crearTabla(char* lista[],CLexico* nombreTabla[],int sizeTabla);


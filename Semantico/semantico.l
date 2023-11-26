%{
/* -----------------------------------------------
   OBJETIVO: Elaborar un analizador sintáctico en lex/flex que 
   			 sea capaz de reconocer a partir de una gramática,
			 la estructura de un lenguaje.

   ELABORADO 
   POR: 	Carraza Ocho José David
	    	Ramirez Garcia Diego Andres
   ----------------------------------------------- */
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

//GLOBALES
FILE *tab_tokens;
FILE *tab_simbolos;
FILE *tab_literales;
FILE *errores;
FILE *cad_atomos;
// bandera para no imprimir de forma repetida los errores sintácticos
int flag_to_error = 0;
int position_error_sintactico;
char* ERROR;
char car;
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
ListaSimbolos crearListaSimbolos();
ListaLiterales crearListaLiterales();
void buscarPalabra(int ,char* ,char**,int );
void tokenASCII(int , char* );
int sacarNum(int, char* );
void funcionTablas(int ,char* );
void imprimirSimbolos(ListaSimbolos );
void imprimirLiterales(ListaLiterales );
void agregarListaSimbolos(ListaSimbolos *, Simbolos);
void agregarListaLiterales(ListaLiterales *, Literales);
void yyerror(char*);
void PrintErrorAtomos(int);
void printCaracter_NoHeader(char*);
void printCaracter_Header(char*);

void AnalizadorSint();
void Program();
void otraFunc();
void Func();
void TipoF();
void listArg();
void otroArg();
void Cuerpo();
void listDecl();
void Decl();
void Tipo();
void valorIni();
void listaVar();
void tipoVal();
void Asig();
void opArit();
void E();
void EP();
void T();
void TP();
void F();
void R();
void opRel();
void Sent();
void listaS();
void expLogica();
void expLog();
void expRel();
void errorSint(char *);
void opLog();
void Enq();
void Se();
void Q();
void Faz();
void Ret();
void valRet();
void expCad();
void opCad();
void Para();
void Trocar();
void casos();
void Llama();
void listP();
void Param();
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
ident         _{letra}({letra}|{digito}|0|_)*
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
			// Excepciones si el archivo pasado como arguumento no exite en el directorio donde se corre
			printf("compilador: \033[1;31m error: \033[1;0m no such file or directory: %s\ncompilador:\033[1;31m error:\033[1;0m no input files\n",argv[1]);
			exit(EXIT_FAILURE);
		}else{

			listSim = crearListaSimbolos();
			listLit = crearListaLiterales();

			// Abrimos archivos
			tab_tokens=fopen("token","w");
			cad_atomos=fopen("atomos","w");
			tab_simbolos=fopen("archSimbol","w");
			tab_literales=fopen("archLite","w");
			errores=fopen("errores","w");

			// iniciamos el analizador léxico
			yylex();

			//Agregamos explícitamente un salto de línea como delimitador
			//fprintf(cad_atomos, "\n"); 	
			fclose(cad_atomos);

			cad_atomos=fopen("atomos","r");
			AnalizadorSint();
			

			// Guardamos tabla de simbolos y literales
			imprimirSimbolos(listSim);
			imprimirLiterales(listLit);
			fprintf(stderr,"\n");
			fprintf(errores,"\n");

			// Cerramos archivos
			fclose(cad_atomos);
			fclose(tab_tokens);
			fclose(tab_simbolos);
			fclose(tab_literales);
			fclose(errores);
			fclose(yyin);
		}
	}else{
		// Excepción si no se pasa como argumento un archivo
		 printf("compilador:\033[1;31m error:\033[1;0m no input files\n");
		 exit(EXIT_FAILURE);
	}
	exit(EXIT_SUCCESS);
}
/*–––––––––––––––––––––– SECCION PARA INSTANCIAR LISTAS LIGADAS––––––––––––––––––––––––*/
ListaSimbolos crearListaSimbolos(){
	ListaSimbolos lista;
	lista.head = NULL;	//Cabeza de la lista
	lista.cantidad = 0; //Es incremental, define la posición
	return lista;
}
ListaLiterales crearListaLiterales() {
	ListaLiterales lista;
	lista.head = NULL;	//Cabeza de la lista
	lista.cantidad = 0; //Es incremental, define la posición
	return lista;
}
/* ---------------SECCIÓN DE CATÁLOGOS -------------------------*/

/* Token especial para clase de operadores aritméticos y símbolos especiales*/
void tokenASCII(int clase, char* valorChar){
	//Conversión del operador a ASCII 
	int valASC=(int)valorChar[0];
	fprintf(tab_tokens, "%d,%d\n",clase,valASC);
	fprintf(cad_atomos, "%c",valorChar[0]); 	
 	
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
	fprintf(tab_tokens, "%d,%d\n",clase,valor); 		//Clase 3 -> CTE numéricas
	fprintf(cad_atomos, "n"); 							//"n" -> átomo para números

}

/* Itera sobre los catalogos hasta encontrar la palabra encontrada por la expresión regular
   para asignar el valor al token, la clase se pasa en cada caso de las expresiones regulares*/
void buscarPalabra(int clase,char* palabra,char** tabla,int size){ 
    for(int valor=0;valor<size;valor++){
        if(strcmp(tabla[valor],palabra)==0){
			fprintf(tab_tokens,"%d,%d\n",clase,valor);

			if (clase == 1){													//Clase de OpLogicos
				if (strcmp(logicos[0],palabra)==0) fprintf(cad_atomos,"h");
				else if (strcmp(logicos[1],palabra)==0) fprintf(cad_atomos,"j");
				else if (strcmp(logicos[2],palabra)==0) fprintf(cad_atomos,"!");
			}
			else if (clase == 2){												//Clase de OpRelacionales
				if (strcmp(relacionales[0],palabra)==0) fprintf(cad_atomos,"e");
				else if (strcmp(relacionales[1],palabra)==0) fprintf(cad_atomos,"d");
				else if (strcmp(relacionales[2],palabra)==0) fprintf(cad_atomos,">");
				else if (strcmp(relacionales[3],palabra)==0) fprintf(cad_atomos,"<");
				else if (strcmp(relacionales[4],palabra)==0) fprintf(cad_atomos,"m");
				else if (strcmp(relacionales[5],palabra)==0) fprintf(cad_atomos,"w");
			}
			else if (clase == 4){												//Clase de PalReservadas
				if (strcmp(reservadas[0],palabra)==0) fprintf(cad_atomos,"g");
				else if (strcmp(reservadas[1],palabra)==0) fprintf(cad_atomos,"c");
				else if (strcmp(reservadas[2],palabra)==0) fprintf(cad_atomos,"q");
				else if (strcmp(reservadas[3],palabra)==0) fprintf(cad_atomos,"z");
				else if (strcmp(reservadas[4],palabra)==0) fprintf(cad_atomos,"f");
				else if (strcmp(reservadas[5],palabra)==0) fprintf(cad_atomos,"i");
				else if (strcmp(reservadas[6],palabra)==0) fprintf(cad_atomos,"p");
				else if (strcmp(reservadas[7],palabra)==0) fprintf(cad_atomos,"u");
				else if (strcmp(reservadas[8],palabra)==0) fprintf(cad_atomos,"t");
				else if (strcmp(reservadas[9],palabra)==0) fprintf(cad_atomos,"s");
				else if (strcmp(reservadas[10],palabra)==0) fprintf(cad_atomos,"b");
			} 
			else if (clase == 7){												//Clase OpAsignacion
				if (strcmp(asignacion[0],palabra)==0) fprintf(cad_atomos,"=");
				else if (strcmp(asignacion[1],palabra)==0) fprintf(cad_atomos,"x");
				else if (strcmp(asignacion[2],palabra)==0) fprintf(cad_atomos,"y");
				else if (strcmp(asignacion[3],palabra)==0) fprintf(cad_atomos,"k");
				else if (strcmp(asignacion[4],palabra)==0) fprintf(cad_atomos,"r");
				else if (strcmp(asignacion[5],palabra)==0) fprintf(cad_atomos,"o");
			}
			else if (clase == 9){												//Clase OpCadenas
				if (strcmp(opCadenas[0],palabra)==0) fprintf(cad_atomos,"&");
				else if (strcmp(opCadenas[1],palabra)==0) fprintf(cad_atomos,"l");
			}

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
    	NodoSimbolos *current = lista.head;
   		while (current != NULL ) { 
            fprintf(tab_simbolos,"%d,%s,%d\n", current->tabSimb.pos, current->tabSimb.identificador, current->tabSimb.tipo);
			current = current->next;
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
int buscarSimbolo(char* identificador, ListaSimbolos *lista) {
	// Se copia el Nodo inicial de la lista 
	NodoSimbolos* tmp=lista->head;
	while (tmp!=NULL){ 
		if (strcmp(tmp->tabSimb.identificador, identificador) == 0){ //Si son iguales ambas cadenas
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
			fprintf(cad_atomos, "a"); 						//a-> átomo de identificadores

		}	
		// Si existe
		else{
			fprintf(tab_tokens, "%d,%d\n",clase,busqueda); 
			fprintf(cad_atomos, "a"); 						//a-> átomo de identificadores

		}

	}
	// constantes de cadenas
	else{
		Literales tabla;
		tabla.pos = listLit.cantidad;
		tabla.cadena = strdup(ident);

		agregarListaLiterales(&listLit, tabla);
		fprintf(tab_tokens, "%d,%d\n",clase,tabla.pos); 	//Clase 8 -> CTE cad 
		fprintf(cad_atomos, "v"); 							//v-> átomo de cadenas

	}
}

/* Función para detectar los errores e ir imprimiendo en pantalla*/
void yyerror(char* mensaje){
	if(yylineno != yylineno_anterior ){
		fprintf(stderr,"\n");
		fprintf(errores,"\n");
		printCaracter_NoHeader(mensaje);
		// Actualizamos la línea donde se encontro el caracter erroneo
		yylineno_anterior = yylineno;
	}else{
		printCaracter_Header(mensaje);
	}
}

// Imprimir icinio de una cadena errornea 
void printCaracter_NoHeader(char* caracter){
	fprintf(stderr," Lexico::%d\033[1;31m error:\033[1;0m %s",yylineno,caracter);
	fprintf(errores," Lexico:%d error: %s",yylineno,caracter);
}
// Imprimir elementos de la cadena errornea antes encontrada
void printCaracter_Header(char* caracter){
	fprintf(stderr,"%s",caracter);
	fprintf(errores,"%s",caracter);
}
void AnalizadorSint(){
	// Redirigimos el apuntador del stream stdin
	if(freopen("atomos","r",stdin) == NULL){
		exit(EXIT_FAILURE);
	}else{
		// Leemos del stdin
		car = getchar();
		Program();
		if (flag_to_error == 0){
			printf("\nSe ha aceptado el codigo fuente\n");
		}
	}
}
// Función para imprimir la cadena de atomos con el error enmarcado
void PrintErrorAtomos(int ubicacion){
	// reiniciamos el desplazamiento de lectura del archivo
	rewind(cad_atomos);
	char atom_printed;
	printf("           ");
	while((fscanf(cad_atomos,"%c",&atom_printed)) != EOF){
		if(ftell(cad_atomos) == (ubicacion)){
			printf("\033[1;31m%c\033[1;0m",atom_printed);
		}else{
			printf("%c",atom_printed);				
		}
	}
	printf("\n");
}
// Funcón para denotar los errores sintacticos en la salida junto con lo esperado
void errorSint(char* espected){
	flag_to_error = 1;
	if(position_error_sintactico != ftell(stdin)){
		// mensaje
		printf("Sintáctico:%ld:\033[1;31m error:\033[1;0m atomo %c argumentos esperados %s\n",ftell(stdin),car,espected);
		// cadena de atomos con el átomo donde ocurrio el error (recarcado)
		PrintErrorAtomos(ftell(stdin));
		// señalización de los átomos esperados
		printf("           ");
		for(int i = 0;i<ftell(stdin);i++){
			if(i==(ftell(stdin)-1)){
				printf("\033[0;36m|\n");
				printf("           ");
				for(int i = 0;i<ftell(stdin);i++){
					if(i==(ftell(stdin)-1)){
						printf("\033[0;36m%s\033[1;0m\n",espected);
					}else{
						printf(" ");
					}
				}
			}else{
				printf(" ");
			}
		}
		// guardar la posición del último error para no ovlver a imprimir el error
		position_error_sintactico = ftell(stdin);
		printf("\n");
	}
}

void Program(){
	if (car=='g' || car=='f' || car=='i'){
		Func();
		otraFunc();
		return;										

	}else{
		errorSint("g f i");
		return;
	}
}

void otraFunc(){
	if (car=='g' || car=='f' || car=='i'){
		Func();
		otraFunc();
		return;											
	}else if (car==EOF){
		return;
	}else{
		errorSint("g f i ");
		return;
	}
}

void Func(){
	if (car=='g' || car=='f' || car=='i'){
		TipoF();

		if(car =='a') car = getchar();
			else errorSint("a");
		
		if(car =='(') car = getchar();
			else errorSint("(");

		listArg();

		if(car ==')') car = getchar();
			else errorSint(")");

		if(car =='{') car = getchar();
			else errorSint("{");
		
		Cuerpo();

		if(car =='}') car = getchar();
			else errorSint("}");

		return; 							
	} else{
		errorSint("g f i");
		return;
	}
}

void TipoF(){
	if (car=='f' || car=='i'){
		Tipo();
		return; 							
	}else if(car == 'g'){
		car = getchar();
		return; 							
	}else{
		errorSint("f i g");
		return;
	}
}

void listArg(){
	if (car=='f' || car=='i'){
		Tipo();

		if(car =='a') car = getchar();
			else errorSint("a");
		otroArg();
		return;								
	}else if(car == ')'){
		return;
	}else{
		errorSint("f i )");
		return;
	}
}

void otroArg(){
	if (car == ','){
		car = getchar();
		Tipo();

		if(car =='a') car = getchar();
			else errorSint("a");
		
		otroArg();
		return; 							
	}else if(car == ')'){
		return;
	}else{
		errorSint(", )");
		return;
	}
}

void Cuerpo(){
	if (car=='a' || car=='u' || car=='t' || car=='b' || car=='q' || car=='z' || car=='s' || 
		car=='p' || car=='[' || car=='}' || car == 'f' || car == 'i'){

		listDecl();
		listaS();							
		return;								
	}else{
		errorSint("a u t b q z s p [ } f i");
		return;
	}
}

void listDecl(){
	if (car=='a' || car=='u' || car=='t' || car=='b' || car=='q' || car=='z' || car=='s' || 
		car=='p' || car=='[' || car=='}'){

		return;
	}else if(car=='f' || car=='i'){
		Decl();
		listDecl();
		return;
	}else{
		errorSint("a u t b q z s p [ } f i");
		return;
	}
}

void Decl(){
	if(car=='f' || car=='i'){
		Tipo();

		if(car =='a') car = getchar();
			else errorSint("a");
		
		valorIni();
		listaVar();

		if(car ==';') car = getchar();
			else errorSint(";");
		
		return; 							
	}else{
		errorSint("f i");
		return;
	}
}

void Tipo(){
	if (car== 'f'){
		car = getchar();
		return; 						
	}else if(car=='i'){
		car = getchar();
		return;											
	}else{
		errorSint("f i");
		return;
	}
}

void valorIni(){
	if (car== '='){
		car = getchar();
		tipoVal();
		return; 						
	}else if(car==',' || car== ';'){
		return;
	}else{
		errorSint("= , ;");
		return;
	}
}

void listaVar(){
	if (car== ','){
		car = getchar();

		if(car =='a') car = getchar();
			else errorSint("a");

		valorIni();
		listaVar();
		return; 						
	}else if(car== ';'){
		return;
	}else{
		errorSint(", ;");
		return;
	}
}

void tipoVal(){
	if (car== 'n'){
		car = getchar();
		return; 						
	}else if(car== 'v'){
		car = getchar();
		return; 						
	}else{
		errorSint("n v");
		return;
	}
}

void Asig(){
	if (car == 'a'){

		car = getchar();

		opArit();
		E();

		if(car ==';') car = getchar();
		else errorSint(";");

		return; 						
	}else{
		errorSint("a");
		return;
	}
}

void opArit(){
	if (car== '='){
		car = getchar();
		return; 						
	}else if(car== 'x'){
		car = getchar();
		return; 						
	}else if(car== 'y'){
		car = getchar();
		return; 						
	}else if(car== 'k'){
		car = getchar();
		return; 						
	}else if(car== 'r'){
		car = getchar();
		return; 						
	}else if(car== 'o'){
		car = getchar();
		return; 						
	}else{
		errorSint("= x y k r o");
		return;
	}
}

void E(){
	if (car == '(' || car == 'a' || car == 'n' || car == '['){
		T();
		EP();
		return; 						
	}else{
		errorSint("( a n [");
		return;
	}
}

void EP(){
	if (car == '+'){
		car = getchar();
		T();
		EP();
		return; 						

	}else if(car == '-'){
		car = getchar();
		T();
		EP();
		return; 					

	}else if(car == ';' || car == ')' || car == 'h' || car == 'j' || car == '}' || car == '>' || car == '<' ||
			 car == 'e' || car == 'd' || car == 'm' || car == 'w' || car == ','){

		return; 
	}else{
		errorSint("+ - ; ) h j } > < e d m w ,");
		return;
	}
}

void T(){
	if (car == '(' || car == 'a' || car == 'n' || car == '['){
		
		F();
		TP();
		return; 						
	}else{
		errorSint("( a n [");
		return;
	}
}

void TP(){
	if (car == '*'){
		car = getchar();
		F();
		TP();
		return; 						

	}else if(car == '/'){
		car = getchar();
		F();
		TP();
		return; 						

	}else if(car == '%'){
		car = getchar();
		F();
		TP();
		return; 						

	}else if(car == '+' || car== '-' || car== ')' || car== ';' || car== '<' || car== '>' || car== 'e' || 
			car== 'm' || car== 'w' || car== 'd' || car== '}' || car== 'h' || car== 'j' || car== ','){
		
		return;
	}else{
		errorSint("* / % + - ) ; < > e d m w } h j ,");
		return;
	}
}


void F(){
	if (car == '('){
		car = getchar();
		E();

		if(car ==')') car = getchar();
			else errorSint(")");

		return; 						

	}else if(car == 'a'){
		car = getchar();
		return;							

	}else if(car == 'n'){
		car = getchar();
		return;							
		
	}else if(car == '['){
		Llama();					
		return;						
	}else{
		errorSint("( a n [");
		return;
	}
}

void R(){
	if (car=='(' || car=='a' || car=='n' || car=='['){
		E();
		opRel();
		E();
		return;
	}else{
		errorSint("( a n [");
	}
}

void opRel(){
	if (car=='>'){
		car = getchar();
		return;
	}else if(car=='<'){
		car = getchar();
		return;
	}else if(car=='e'){
		car = getchar();
		return;
	}else if(car=='d'){
		car = getchar();
		return;
	}else if(car=='m'){
		car = getchar();
		return;
	}else if(car=='w'){
		car = getchar();
		return;
	}else{
		errorSint("> < e d m w");
	}
}

void Sent(){
	if (car=='a'){
		Asig();
		return;
	}else if(car=='u'){
		Q();
		return;
	}else if(car=='t'){
		Ret();
		return;
	}else if(car=='b'){
		Trocar();
		return;
	}else if(car=='q'){
		Enq();
		return;
	}else if(car=='z'){
		Faz();
		return;
	}else if(car=='s'){
		Se();
		return;
	}else if(car=='p'){
		Para();
		return;
	}else if(car=='['){
		Llama();
		return;
	}else{
		errorSint("a u t b q z s p [");
	}
}
void listaS(){
	if (car=='a' || car=='u'||car=='t'||car=='b'||car=='q'||car=='z'||car=='s'||car=='p'||car=='['){
		Sent();
		listaS();
		return;
	}else if(car=='#' || car=='}'){
		return;
	}else{
		errorSint("a u t b q z s p [ # }");
	}
}
void expLogica(){
	if (car=='!'){
		car = getchar();
		expRel();
		return;
	}else if(car=='(' || car=='a' || car=='n'||car=='['){
		R();
		expLog();
		return;
	}else{
		errorSint("! ( a n [");
	}
}
void expLog(){
	if (car=='h'||car=='j'){
		opLog();
		R();
		return;
	}else if(car==')'){
		return;
	}else{
		errorSint("h j )");
	}
}
void expRel(){
	if (car=='{'){
		car = getchar();
		R();
		if(car=='}') car = getchar();
		else errorSint("}");
		return;
	}else if(car=='(' || car=='a' || car=='n'||car=='['){
		E();
		return;
	}else{
		errorSint("{ ( a n [");
	}
}
void opLog(){
	if (car=='h'){
		car = getchar();
		return;
	}else if(car=='j'){
		car = getchar();
		return;
	}else{
		errorSint("h j");
	}
}
void Enq(){
	if (car=='q'){
		car = getchar();
		if(car=='(') car = getchar();
		else errorSint("(");
		expLogica();
		if(car==')') car = getchar();
		else errorSint(")");
		if(car=='#') car = getchar();
		else errorSint("#");
		listaS();
		if(car=='#') car = getchar();
		else errorSint("#");
		return;
	}else{
		errorSint("q");
	}
}
void Se(){
	if (car=='s'){
		car = getchar();
		if(car=='(') car = getchar();
		else errorSint("(");
		expLogica();
		if(car==')') car = getchar();
		else errorSint(")");
		if(car=='#') car = getchar();
		else errorSint("#");
		listaS();
		if(car=='#') car = getchar();
		else errorSint("#");
		return;
	}else{
		errorSint("s");
	}
}
void Q(){
	if (car=='u'){
		car = getchar();
	
	if(car ==';') car = getchar();
		else errorSint(";");
		
		return;
	}else{
		errorSint("u");
	}
}
void Faz(){
	if (car=='z'){
		car = getchar();
		if(car=='#') car = getchar();
		else errorSint("#");
		listaS();
		if(car=='#') car = getchar();
		else errorSint("#");
		if(car=='q') car = getchar();
		else errorSint("q");
		if(car=='(') car = getchar();
		else errorSint("(");
		expLogica();
		if(car==')') car = getchar();
		else errorSint(")");
		if(car==';') car = getchar();
		else errorSint(";");
		return;
	}else{
		errorSint("z");
	}
}
void Ret(){
	if(car=='t'){
		car = getchar();
		valRet();
		if(car==';') car = getchar();
		else errorSint(";");
		return;
	}else{
		errorSint("t");
	}
}
void valRet(){
	if(car=='(' || car=='a' || car=='n'||car=='['){
		E();
		return;
	}else if(car=='{'){
		car = getchar();
		expCad();
		if(car=='}') car = getchar();
		else errorSint("}");
		return;
	}else if(car==';'){
		return;
	}else{
		errorSint("( a n [ { ;");
	}
}
void expCad(){
	if(car=='a'){
		car = getchar();
		opCad();
		return;
	}else if(car=='v'){
		car = getchar();
		opCad();
		return;
	}else{
		errorSint("a v");
	}
}
void opCad(){
	if(car=='l'){
		car = getchar();
		expCad();
		return;
	}else if(car=='&'){
		car = getchar();
		expCad();
		return;
	}else if(car=='}'){
		return;
	}else{
		errorSint("l & }");
	}
}
void Para(){
	if(car=='p'){
		car = getchar();
		if(car=='a') car = getchar();
		else errorSint("a");
		if(car=='[') car = getchar();
		else errorSint("[");
		if(car=='n') car = getchar();
		else errorSint("n");
		if(car==',') car = getchar();
		else errorSint(",");
		if(car=='n') car = getchar();
		else errorSint("n");
		if(car==']') car = getchar();
		else errorSint("]");
		if(car=='#') car = getchar();
		else errorSint("#");
		listaS();
		if(car=='#') car = getchar();
		else errorSint("#");
		return;
	}else{
		errorSint("p");
	}
}
void Trocar(){
	if(car=='b'){
		car = getchar();
		if(car=='(') car = getchar();
		else errorSint("(");
		if(car=='a') car = getchar();
		else errorSint("a");
		if(car==')') car = getchar();
		else errorSint(")");
		if(car==':') car = getchar();
		else errorSint(":");
		if(car=='#') car = getchar();
		else errorSint("#");
		if(car=='c') car = getchar();
		else errorSint("c");
		if(car=='(') car = getchar();
		else errorSint("(");
		if(car=='n') car = getchar();
		else errorSint("n");
		if(car==')') car = getchar();
		else errorSint(")");
		if(car=='{') car = getchar();
		else errorSint("{");
		listaS();
		if(car=='}') car = getchar();
		else errorSint("}");
		casos();
		if(car=='#') car = getchar();
		else errorSint("#");
		return;
	}else{
		errorSint("b");
	}
}
void casos(){
	if(car=='#'){
		return;
	}else if(car=='c'){
		car = getchar();
		if(car=='(') car = getchar();
		else errorSint("(");
		if(car=='n') car = getchar();
		else errorSint("n");
		if(car==')') car = getchar();
		else errorSint(")");
		if(car=='{') car = getchar();
		else errorSint("{");
		listaS();
		if(car=='}') car = getchar();
		else errorSint("}");
		casos();
		return;
	}else if(car=='('){
		car = getchar();
		if(car==')') car = getchar();
		else errorSint(")");
		if(car=='{') car = getchar();
		else errorSint("{");
		listaS();
		if(car=='}') car = getchar();
		else errorSint("}");
		casos();
		return;
	}else{
		errorSint("# c (");
	}
}
void Llama(){
	if(car=='['){
		car =getchar();
		if(car=='a') car = getchar();
		else errorSint("a");
		if(car=='(') car = getchar();
		else errorSint("(");
		listP();
		if(car==')') car = getchar();
		else errorSint(")");
		if(car==']') car = getchar();
		else errorSint("]");
		return;
	}else{
		errorSint("[");
	}
}
void listP(){
	if(car==')'){
		return;
	}else if(car=='(' || car=='a' || car=='n'||car=='['){
		E();
		Param();
		return;
	}else if(car=='{'){
		car = getchar();
		expCad();
		if(car=='}') car = getchar();
		else errorSint("}");
		Param();
		return;
	}else{
		errorSint(") ( a n [ {");
	}
}
void Param(){
	if(car==','){
		car = getchar();
		listP();
		return;
	}else if(car==')'){
		return;
	}else{
		errorSint(", )");
	}
}















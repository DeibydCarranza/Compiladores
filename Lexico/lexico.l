%{
#include<stdio.h>
#include<string.h>

FILE *yyin;
%}
palRes     assinado|caso|enquanto|fazer|flutuador|inteiro|para|quebrar|retorno|se|trocar
espaSalTab [ \t\n]
signo      [+\-]
opMulDiv   ("*"|"/"|"%")
opArit     ({signo}|{opMulDiv})
opLog      ("&&"|"||"|"!")
opRel      ([><=!]=|>|<)
digito     [1-9]
numero     0|{digito}(0|{digito})*
cteEnt     ("("{signo}{numero}")")|{numero}
letra      [a-zA-Z]
ident      _({letra}|{digito}|0|_)+
simbEsp    ("("|")"|"{"|"}"|";"|","|"["|"]"|":"|"#")
opAsig     ({signo}|{opMulDiv})?=
cteCad     (\"([^\"]|\\.)*\")
opCad      (&|like)
%%
{opArit}     {printf("%s es un operador aritmetico\n",yytext);}
{opLog}      {printf("%s es un operador logico\n",yytext);}
{opRel}      {printf("%s es un operador relacional\n",yytext);}
{cteEnt}     {printf("%s es una constante numérica decimal\n",yytext);}
{palRes}     {printf("%s es una palabra reservada\n",yytext);}
{opCad}      {printf("%s es una operación sobre cadena\n",yytext);}
{ident}      {printf("%s es un identificador\n",yytext);}
{simbEsp}    {printf("%s es un símbolo especial\n",yytext);}
{opAsig}     {printf("%s es un operador de asignacion\n",yytext);}
{cteCad}     {printf("%s es una constante cadena\n",yytext);}
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
		yylex();
	}
	fclose(yyin);
	return 0;
}


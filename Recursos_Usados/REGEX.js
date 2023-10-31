//0 Operadores aritméticos
signo				[+\-]
opMulDiv		("*"|"/"|"%")
opArit			({signo}|{opMulDiv})

//1 Operadores lógicos
opLog				("&&"|"||"|"!")

//2 Operadores relacionales
opRel				([><=!]=|>|<)

//3 Constantes enteras decimales
digito			[1-9]
numero			0|{digito}(0|{digito})*
cteEnt			("("{signo}{numero}")")|{numero}

//4 Palabras reservadas
palRes      assinado|caso|enquanto|fazer|flutuador|inteiro|para|quebrar|retorno|se|trocar

//5 Identificadores
letMay  		[A-Z]
letMin  		[a-z]
ident   		_({letMay}|{letMin}|{digito}|0|_)+

//6 Símbolos especiales
simbEsp			("("|")"|"{"|"}"|";"|","|"["|"]"|":"|"#")

//7 Operadores de asignación
opAsig			({signo}|{opMulDiv})?=

//8 Constantes cadenas
cteCad			(\"([^\"]|\\.)*\")

//9 Operadores sobre cadenas
opCad				(&|like)
  
letMay [A-Z]
letMin [a-z]
dig [0-9]
ident ({letMay}|{letMin}|_)({letMay}|{letMin}|{dig}|_)*
palres break|case|char|float|for|goto
%%
{palres} {printf("%s es una palabra reservada\n",yytext);}
{ident} {printf("%s es un identificador\n",yytext);}
. {printf("%s no reconocido\n",yytext);}
%%

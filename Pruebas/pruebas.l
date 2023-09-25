cteCad  (\"(\\.|[^\"])*\")
%%
{cteCad} {printf("%s es una cadena \n",yytext);}
. {printf("%s [!] No reconocido\n",yytext);}
%%

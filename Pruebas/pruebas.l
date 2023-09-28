digito     [1-9]
letMay     [a-zA-Z]
ident      _({letMay}|{digito}|0|_)+
%%
{ident}   {printf("%s es um ident \n",yytext);}
. {printf("%s [!] No reconocido\n",yytext);}
%%

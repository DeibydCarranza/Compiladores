dig [0-9]
expon [Ee]
sign [+\-]
num_real (({dig}*\.{dig}+)|({dig}+\.))
expo_part ({expon}{sign}?{dig}+)
num_real_expo ({num_real}{expo_part}?)|({dig}+{expo_part})
%%
{num_real_expo} {printf("%s es un numero flotante \n",yytext);}
. {printf("%s [!] No reconocido\n",yytext);}
%%

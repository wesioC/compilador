
%{
#include "comp.tab.h"

int lin=1, col=1;
%}

DIGITO 	[0-9]
LETRA		[A-Za-z_]

%%
" "		{ col+=yyleng;}
\n			{ lin++; col=1; }
"+"		{ col+=yyleng; return MAIS; }
"*"		{ col+=yyleng; return MULT; }
"-"		{ col+=yyleng; return MENOS; }
"("		{ col+=yyleng; return ABRE_PARENTESES; }
")"		{ col+=yyleng; return FECHA_PARENTESES; }
"{"		{ col+=yyleng; return ABRE_CHAVES; }
"}"		{ col+=yyleng; return FECHA_CHAVES; }
";"		{ col+=yyleng; return PONTO_E_VIRGULA; }
"int"		{ col+=yyleng; return INT; }
"main"	{ col+=yyleng; return MAIN; }
"return"	{ col+=yyleng; return RETURN; }
{DIGITO}+	{ col+=yyleng; yylval=atoi(yytext); return NUM; }
{LETRA}({LETRA}|{DIGITO})* { col+=yyleng; return ID; }
.			{ col+=yyleng; return DESCONHECIDO; }
%%


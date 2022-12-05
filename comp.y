
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define TAM 18


extern int lin;
extern int col;
extern int yyleng;
extern char *yytext;
FILE *f;

/*estrutura de dados para gerenciamento de variaáveis*/


typedef struct no{
	char var[25];
	int dado;
	struct no *prox;
}No;

typedef struct hash_table{
	struct no *vet[TAM];
}Hash_table;

//##### funções para manipulação da lista
void mostrar_lista(No **C){
	No *p;
	for (p=*C; p!=NULL; p=p->prox){
		printf("%s = %i ", p->var,p->dado);
	}
}

void inserir_lista(No **C, int valor, char var[]){
	No *novo;
	novo = (No *)malloc(sizeof(No));
	novo->dado = valor;
	strcpy(novo->var,var);
	novo->prox = NULL;	

	if (*C == NULL){
		*C = novo;
	}else{
		novo->prox = *C;
		*C = novo;
	}
}

int buscar_valor_lista(No **C, char var[]){
	No *p;
	for (p=*C; p!=NULL; p=p->prox){
		if(strcmp(p->var,var) == 0)
			return p->dado;
	}
	return -999999;
}
//##### funções para tabela hash
int hash(int k){
	return (k*5)%TAM;
}

void inserir_tabela_hash(Hash_table *T, int valor, char var[]){
	int n = strlen(var);
	inserir_lista(&T->vet[hash(n)], valor, var);
}

int buscar_valor_tabela_hash(Hash_table *T, char var[]){
	int n = strlen(var);
	return buscar_valor_lista(&T->vet[hash(n)], var);
}

void inicializar_tabela(Hash_table *T){
	for (int i=0; i<TAM; i++)
		T->vet[i] = NULL;
}
void mostrar_tabela(Hash_table *T){
	for (int i=0; i<TAM; i++){
		printf("[%i] ", i);
		mostrar_lista(&T->vet[i]);
		printf("\n");
	}
}


/* Geração de código assembly*/
int yyerror(char *msg){
	printf("%s (%i, %i) Erro: \"%s\"\n", msg, lin, col-yyleng, yytext);
	exit(0);
}
int yylex(void);

void montar_codigo_inicial(){
	f = fopen("out.s","w+");
	fprintf(f, ".text\n");
	fprintf(f, "    .global _start\n\n");
    	fprintf(f, "_start:\n\n");
}

void montar_codigo_final(){
	fclose(f);

	printf("Arquivo \"out.s\" gerado.\n\n");
}

void montar_codigo_retorno(){
	fprintf(f, "    popq    %%rbx\n");
	fprintf(f, "    movq    $1, %%rax\n");
	fprintf(f, "    int     $0x80\n\n");
}
void montar_codigo_exp(char op){
	switch(op){
		case '+':
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    addq    %%rbx, %%rax\n");
			fprintf(f, "    pushq     %%rax\n\n");
			break;
		case '-':
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    subq    %%rbx, %%rax\n");
			fprintf(f, "    pushq     %%rax\n\n");
			break;
		case '*':
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    imulq    %%rbx, %%rax\n");
			fprintf(f, "    pushq     %%rax\n\n");
			break;
	}
	
}

void montar_add(int a, int b){
	fprintf(f, "    movq    $%d, %%rax\n", a);
	fprintf(f, "    movq    $%d, %%rbx\n", b);
	fprintf(f, "    addq    %%rax, %%rbx\n");
	fprintf(f, "    movq    $1, %%rax\n");
	fprintf(f, "    int     $0x80\n\n");
}

void montar_sub(int a, int b){
	fprintf(f, "    movq    $%d, %%rbx\n", a);
	fprintf(f, "    subq    $%d, %%rbx\n", b);
	fprintf(f, "    movq    $1, %%rax\n");
	fprintf(f, "    int     $0x80\n\n");
}

void montar_mult(int a, int b){
	fprintf(f, "    movq    $%d, %%rbx\n", a);
	fprintf(f, "    mult    $%d, %%rbx\n", b);
	fprintf(f, "    movq    $1, %%rax\n");
	fprintf(f, "    int     $0x80\n\n");
}
void montar_codigo_empilhar(int a){
	fprintf(f, "    pushq    $%i\n",a);
}
Hash_table T;
%}
%union {
char *string;
int inteiro;
}
%token INT MAIN ABRE_PARENTESES FECHA_PARENTESES ABRE_CHAVES RETURN PONTO_E_VIRGULA FECHA_CHAVES DESCONHECIDO IGUAL
%token MAIS MENOS MULT
%token<string> ID
%token<inteiro> NUM
%left MAIS MENOS
%left MULT
%%

programa	: INT MAIN ABRE_PARENTESES FECHA_PARENTESES ABRE_CHAVES {montar_codigo_inicial();inicializar_tabela(&T);} corpo FECHA_CHAVES {montar_codigo_final();} ;
corpo		: RETURN exp PONTO_E_VIRGULA {montar_codigo_retorno();} corpo
			| var PONTO_E_VIRGULA corpo
			|
			;
exp         : exp MAIS exp {montar_codigo_exp('+');}
			| exp MENOS exp {montar_codigo_exp('-');}
			| exp MULT exp {montar_codigo_exp('*');}
			| ABRE_PARENTESES exp FECHA_PARENTESES
			| NUM {montar_codigo_empilhar($1);}
			| ID {int id = buscar_valor_tabela_hash(&T,$1); if(id !=-999999){montar_codigo_empilhar(id);}else{printf("(%i, %i) Erro: \"Variavel não declarada - %s\"\n", lin, col-yyleng,$1);exit(0);}}
			;
var			: INT ID IGUAL NUM{inserir_tabela_hash(&T,$4,$2);}
			| INT ID {if (buscar_valor_tabela_hash(&T,$2)==-999999){inserir_tabela_hash(&T,0,$2);}else{printf("(%i, %i) Erro: \"Variavel declarada mais de uma vez - %s\"\n", lin, col-yyleng,$2); exit(0);}}
			;
%%
int main(){

	yyparse();
	printf("Programa OK.\n");
	printf("Tabela hash.\n");
	mostrar_tabela(&T);
}

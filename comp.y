
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define TAM 26


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
	return 0;
}
//##### funções para tabela hash
int hash(int k){
	return (k*101)%TAM;
}

void inserir_tabela_hash(Hash_table *T, int valor, char var[]){
	int n = var[0];
	inserir_lista(&T->vet[hash(n)], valor, var);
}

int buscar_valor_tabela_hash(Hash_table *T, char var[]){
	int n = var[0];
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
	fprintf(f, "    pushq	%%rbp\n");
	fprintf(f, "    movq	%%rsp, %%rbp\n");
}

void montar_codigo_final(){
	fclose(f);

	printf("Arquivo \"out.s\" gerado.\n\n");
}

void montar_codigo_retorno(){
	fprintf(f, "    popq    %%rbx\n");
	fprintf(f, "    movl    $1, %%eax\n");
	fprintf(f, "    int     $0x80\n\n");
}

void declarar_id(int d, int num){
	fprintf(f, "    subq    $4, %%rsp\n");
	fprintf(f, "    movl	$%d, -%d(%%rbp)\n\n",num,d);
}
void declarar_id_exp(int d){
	fprintf(f, "    popq    %%rax\n");
	fprintf(f, "    movl	%%eax, -%d(%%rbp)\n\n",d);
	
}

void atribuir_id_id(int a, int b){
	a = a*sizeof(int);
	b = b*sizeof(int);
	fprintf(f, "    movl	-%d(%%rbp), %%eax\n",b);
	fprintf(f, "    movl	 %%eax, -%d(%%rbp)\n",a);
	fprintf(f, "    movl	-%d(%%rbp), %%eax\n\n",a);
}

void montar_codigo_exp(char op){
	switch(op){
		case '+':
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    addl    %%ebx, %%eax\n");
			fprintf(f, "    pushq     %%rax\n\n");
			break;
		case '-':
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    subl    %%ebx, %%eax\n");
			fprintf(f, "    pushq     %%rax\n\n");
			break;
		case '*':
			fprintf(f, "    popq    %%rax\n");
			fprintf(f, "    popq    %%rbx\n");
			fprintf(f, "    imull    %%ebx, %%eax\n");
			fprintf(f, "    pushq     %%rax\n\n");
			break;
	}
	
}
void montar_codigo_empilhar(int a){
	fprintf(f, "    pushq    $%i\n",a);
}
void montar_id_empilhar(int a, int b){
	/*d -> Deslocamento*/
	int d = a*b;
	fprintf(f, "    pushq    -%i(%%rbp)\n",d);
}

Hash_table T;
int cont = 0;
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
			| var corpo
			|
			;
exp         : exp MAIS exp {montar_codigo_exp('+');}
			| exp MENOS exp {montar_codigo_exp('-');}
			| exp MULT exp {montar_codigo_exp('*');}
			| ABRE_PARENTESES exp FECHA_PARENTESES
			| NUM {montar_codigo_empilhar($1);}
			| ID  {int d = buscar_valor_tabela_hash(&T,$1);if(d!=0){montar_id_empilhar(d,sizeof(int));}else{printf("(%i, %i) Erro: \"Variavel não declarada - %s\"\n", lin, col-yyleng,$1);exit(0);}}
			;
var			: INT ID IGUAL NUM PONTO_E_VIRGULA {cont++;declarar_id(sizeof(int)*cont,$4);inserir_tabela_hash(&T,cont,$2);}
			| INT ID PONTO_E_VIRGULA {cont++;declarar_id(sizeof(int)*cont,0);inserir_tabela_hash(&T,cont,$2);}
			| INT ID IGUAL ID PONTO_E_VIRGULA{cont++;declarar_id(sizeof(int)*cont,0);inserir_tabela_hash(&T,cont,$2);int a = buscar_valor_tabela_hash(&T,$2);int b = buscar_valor_tabela_hash(&T,$4);if(a!=0 && b!=0){atribuir_id_id(a,b);}else{printf("(%i, %i) Erro: \"Variavel não declarada - %s\"\n", lin, col-yyleng,$2);exit(0);};}
			| ID IGUAL exp PONTO_E_VIRGULA {int d = buscar_valor_tabela_hash(&T,$1);if(d!=0){declarar_id_exp(sizeof(int)*d);}else{printf("(%i, %i) Erro: \"Variavel não declarada - %s\"\n", lin, col-yyleng,$1);exit(0);};}
			;
%%
int main(){

	yyparse();
	printf("Programa OK.\n");
	//printf("Tabela hash.\n");
	//mostrar_tabela(&T);
}

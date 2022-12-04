
%{
#include <stdio.h>
#include <stdlib.h>
#define TAM 8

extern int lin;
extern int col;
extern int yyleng;
extern char *yytext;
FILE *f;

/*estrutura de dados para gerenciamento de variaáveis*/


typedef struct no{
	char var;
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
		printf("%i ", p->dado);
	}
}

void inserir_lista(No **C, int valor, char var){
	No *novo;
	novo = (No *)malloc(sizeof(No));
	novo->dado = valor;
	novo->var = var;
	novo->prox = NULL;	

	if (*C == NULL){
		*C = novo;
	}else{
		novo->prox = *C;
		*C = novo;
	}
}

int buscar_valor_lista(No **C, int valor){
	No *p;
	for (p=*C; p!=NULL; p=p->prox){
		if(valor == p->dado)
			return 1;
	}
	return 0;
}
//##### funções para tabela hash
int hash(int k){
	return (k*5)%TAM;
}

void inserir_tabela_hash(Hash_table *T, int valor, char var){
	inserir_lista(&T->vet[hash(valor)], valor, var);
}

int buscar_valor_tabela_hash(Hash_table *T, int valor){
	return buscar_valor_lista(&T->vet[hash(valor)], valor);
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
	printf("%s (%i, %i) token encontrado: \"%s\"\n", msg, lin, col-yyleng, yytext);
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
%}

%token INT MAIN ABRE_PARENTESES FECHA_PARENTESES ABRE_CHAVES RETURN PONTO_E_VIRGULA FECHA_CHAVES ID DESCONHECIDO
%token MAIS MENOS MULT
%token NUM
%left MAIS MENOS
%left MULT
%%

programa	: INT MAIN ABRE_PARENTESES FECHA_PARENTESES ABRE_CHAVES {montar_codigo_inicial();} corpo FECHA_CHAVES {montar_codigo_final();} ;
corpo		: RETURN exp PONTO_E_VIRGULA {montar_codigo_retorno();} corpo
			| var PONTO_E_VIRGULA corpo
			|
			;
exp         : exp MAIS exp {montar_codigo_exp('+');}
			| exp MENOS exp {montar_codigo_exp('-');}
			| exp MULT exp {montar_codigo_exp('*');}
			| ABRE_PARENTESES exp FECHA_PARENTESES
			| NUM {montar_codigo_empilhar($1);}
			;
var			: INT ID {Hash_table T;inicializar_tabela(&T);inserir_tabela_hash(&T, 0,$2);printf("Tabela hash.\n");mostrar_tabela(&T);}
			;
%%
int main(){
	yyparse();
	printf("Programa OK.\n");
}

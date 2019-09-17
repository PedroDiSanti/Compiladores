/*---------------------------------------------------------
 *  Limites das estruturas
 *--------------------------------------------------------*/
#define TAM_TSIMB 100  /* Tamanho da tabela de simbolos */
#define TAM_PSEMA 100  /* Tamanho da pilha semantica    */

/*---------------------------------------------------------
 *  Variaveis globais
 *--------------------------------------------------------*/
int TOPO_TSIMB     = 0;  /* TOPO da tabela de simbolos */
int TOPO_PSEMA     = 0;  /* TOPO da pilha semantica */
int ROTULO         = 0;  /* Proximo numero de rotulo */
int CONTA_VARS     = 0;  /* Numero de variaveis */
int POS_SIMB;            /* Pos. na tabela de simbolos */
int aux;                 /* variavel auxiliar */
int numLinha = 1; /* numero da linha no programa */
char atomo[30];   /* nome de um identif. ou numero */

int TOPO_PAUX = 0; 
int amem = 0; /*Quantidade de variaveis armazenadas*/
char PAUX[TAM_PSEMA]; /*Pilha Auxiliar de armazenamento de tipos*/
char verifica[50]; /*Usado para verificar tipos em operacoes*/
int idVerifica = 0; 
char tipoV; 
int atribuicaoVetor = 0; 

int declaracao = 0; /* flag que indica a ocorrencia de uma declaracao */
int declaracaoVetor = 0; /* flag que indica a ocorrencia de uma declaracao de vetor */
int leituraVetor = 0; /* flag que indica a ocorrencia de uma leitura de vetor */
int indiceVetor = 0; /* flag que indica o contexto de indice de um vetor */

//Estrutura de pilha semantica
struct pilha{
  int simbolo;
  struct pilha *prox;
};

typedef struct pilha Pilha;

Pilha *p;

/*---------------------------------------------------------
 *  Rotina geral de tratamento de erro
 *--------------------------------------------------------*/
void ERRO (char *msg, ...) {
  char formato [255];
  va_list arg;
  va_start (arg, msg);
  sprintf (formato, "\n%d: ", numLinha);
  strcat (formato, msg);
  strcat (formato, "\n\n");
  printf ("\nERRO no programa"); 
  vprintf (formato, arg);
  va_end (arg);
  exit (1);
}

/*---------------------------------------------------------
 *  Tabela de Simbolos
 *--------------------------------------------------------*/
struct elem_tab_simbolos {
  char id[30];
  int desloca;
  int tip; 
} TSIMB [TAM_TSIMB], elem_tab;


/*---------------------------------------------------------
 * Funcao que BUSCA um simbolo na tabela de simbolos.       
 *      Retorna -1 se o simbolo nao esta' na tabela        
 *      Retorna i, onde i e' o indice do simbolo na tabela
 *                 se o simbolo esta' na tabela             
 *--------------------------------------------------------*/
int busca_simbolo (char *ident)
{
  int aux = 0;
  aux = funcao_Hash(ident,TAM_TSIMB);
  if(strcmp(TSIMB [aux].id, ident) != 0){
     aux = -1;
  }
  return aux;
}

//Funcao Hash para buscar na tabela de simbolos
int funcao_Hash(char *id, int tam){
  int aux = 0 , i = 0 ,aux2 = 0;
  int peso = 11;

   while(id[i] !='\0'){
      if(i < 2){
        aux = 'z' - id[i];
        aux2 += aux*peso;
        i++;
        peso = 5;
      }
      else{
        aux = 'z' - id[i];
        aux2 += aux;
        i++;
      }      
   }  
  return (aux2%tam);
}

/*---------------------------------------------------------
 * Funcao que INSERE um simbolo na tabela de simbolos.      
 *    Se ja' existe um simbolo com mesmo nome e mesmo nivel 
 *    uma mensagem de erro e' apresentada e o  programa  e' 
 *    interrompido.                                         
 *--------------------------------------------------------*/
void insere_simbolo (struct elem_tab_simbolos *elem, char tip)
{
  struct elem_tab_simbolos *novo = (struct elem_tab_simbolos*)malloc(sizeof(struct elem_tab_simbolos));
  novo = elem;

  if (TOPO_TSIMB == TAM_TSIMB) {
     ERRO ("OVERFLOW - tabela de simbolos");
  }
  else {
     int pos = funcao_Hash(elem->id,TAM_TSIMB);

     if (strcmp(TSIMB [pos].id, elem->id) == 0) {
       ERRO ("Identificador [%s] duplicado", elem->id);
     } 
 
     TSIMB[pos] = *novo;
     TSIMB[pos].tip = tip;	     
     TOPO_TSIMB++;
  }
}


/*---------------------------------------------------------
 * Funcao de insercao de uma variavel na tabela de simbolos
 *---------------------------------------------------------*/
void insere_variavel (char *ident, char tip) {
   strcpy (elem_tab.id, ident);
   elem_tab.desloca = CONTA_VARS;
   insere_simbolo (&elem_tab, tip);
}

/*---------------------------------------------------------
 * Rotinas para manutencao da PILHA SEMANTICA              
 *--------------------------------------------------------*/
void empilha (int n) {
  Pilha* novo = (Pilha*)malloc(sizeof(Pilha));
  
  novo->simbolo = n;
  novo->prox = p;
  
  p = novo;
}

int desempilha () {
  Pilha* aux = p;
  int simbolo = p->simbolo;
  
  p = aux->prox;
  free(aux); 
  
  return simbolo;
}
/*---------------------------------------------------------
 * Rotinas para manutencao da PILHA AUXILIAR              
 *--------------------------------------------------------*/
void empilhaAux (char n) {
  if (TOPO_PAUX == TAM_PSEMA) {
     ERRO ("OVERFLOW - Pilha AUX");
  }
  PAUX[TOPO_PAUX++] = n;
}

char desempilhaAux () {
  if (TOPO_PAUX == 0) {
     ERRO ("UNDERFLOW - Pilha AUX");
  }
  return PAUX[--TOPO_PAUX];
}

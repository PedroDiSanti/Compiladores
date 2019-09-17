%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

#include "utils.c"
#include "lexico.c"
%}

// Simbolo de partida
%start programa

// Simbolos terminais
%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_ABREV
%token T_FECHAV
%token T_LOGICO
%token T_INTEIRO

// Precedencia e associatividade
%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

// Regras de producao

//Detecta o inicio de um programa, com cabeçalho(programa + nome), variaveis, lista de comandos e fim. 
programa
      : cabecalho
           { printf ("\tINPP\n"); }  
        variaveis
        T_INICIO lista_comandos 
        T_FIM
           { 
             printf ("\tDMEM\t%d\n", CONTA_VARS); 
             printf ("\tFIMP\n"); 
           }
      ;

cabecalho
      : T_PROGRAMA T_IDENTIF 
      ;

variaveis
      :  /* vazio */
      |  declaracao_variaveis 
      ;

//Chama lista_variaveis para armazenar variavel. Seta amem = 0 para verificar quantas variaveis foram declaradas. 
declaracao_variaveis
      : declaracao_variaveis
        tipo 
	{ amem = 0; }
        lista_variaveis 
      | tipo 
	{amem = 0;}
        lista_variaveis
      ;

//Seta declaracao = 1 para saber o momento de declaracao de um vetor. Seta tipoV = 1 pra saber o tipo da variavel armazenada. 
tipo
      : T_LOGICO { declaracao = 1; tipoV = 'l';} 
      | T_INTEIRO { declaracao = 1; tipoV = 'i';}
      ;

//Insere variaveis na tabela de simbolos. Incluido T_IDENTIF + termo que trata declaracoes do tipo vetor. 
lista_variaveis
      : lista_variaveis 
        T_IDENTIF 
          { 
            insere_variavel (atomo, tipoV);
            CONTA_VARS++;
            amem++;
	    if(declaracaoVetor == 0) printf ("\tAMEM\t%d\n", amem);
          }

      | T_IDENTIF
          { 
            insere_variavel (atomo, tipoV); 
            CONTA_VARS++;
            amem++;
 	    if(declaracaoVetor == 0) printf ("\tAMEM\t%d\n", amem);
          }

      | T_IDENTIF
        {
          if(declaracao == 1) {
             declaracaoVetor = 1;
             declaracao = 0;
          }
          insere_variavel (atomo, tipoV); 
        }
        termo    
      ;

lista_comandos
      : /* vazio */
      | comando lista_comandos
      ;

comando
      : entrada_saida
      | repeticao
      | selecao
      | atribuicao
      ;

entrada_saida
      : leitura
      | escrita
      ;

leitura
      : T_LEIA  
        T_IDENTIF 
          { 
            POS_SIMB = busca_simbolo (atomo);
            if (POS_SIMB == -1)
                ERRO ("Variavel [%s] nao declarada!",
                           atomo);
	    else {
                printf ("\tLEIA\n");
                printf ("\tARZG\t%d\n", 
                        TSIMB[POS_SIMB].desloca); 
            }
          }

      |

      T_LEIA
      T_IDENTIF 
          { 
            POS_SIMB = busca_simbolo (atomo);
            if (POS_SIMB == -1)
                ERRO ("Variavel [%s] nao declarada!",
                      atomo);
      else
                empilha (TSIMB[POS_SIMB].desloca);
          }

      T_ABREV expressao T_FECHAV 

      {
          printf ("\tLEIA\n");
          printf ("\tARZV\t%d\n", desempilha());
      }
      ;

escrita
      : T_ESCREVA expressao
          { printf ("\tESCR\n"); }
      ;

repeticao
      : T_ENQTO
           { 
             printf ("L%d\tNADA\n", ++ROTULO);
             empilha (ROTULO);
           } 
        expressao 
        T_FACA 
           {
             printf ("\tDSVF\tL%d\n",++ROTULO);
             empilha (ROTULO);
           }
        lista_comandos 
        T_FIMENQTO
           {
             aux = desempilha();
             printf ("\tDSVS\tL%d\n", desempilha()); 
             printf ("L%d\tNADA\n", aux);           
           }
      ;

selecao
      : T_SE 
        expressao 
           {
             printf ("\tDSVF\tL%d\n", ++ROTULO); 
             empilha (ROTULO);
           }  
        T_ENTAO 
        lista_comandos 
        T_SENAO 
           {
             printf ("\tDSVS\tL%d\n", ++ROTULO);
             printf ("L%d\tNADA\n", desempilha()); 
             empilha (ROTULO);
           }
        lista_comandos 
        T_FIMSE
           { 
             printf ("L%d\tNADA\n", desempilha());    
           }
      ;
// Para atribuicao, expressao e termo, é utilizada uma pilha auxiliar que armazena o tipo da variavel que esta sendo testada naquele momento 
atribuicao
      : T_IDENTIF 
          { 
            POS_SIMB = busca_simbolo (atomo);
            if (POS_SIMB == -1) {
                ERRO ("Variavel [%s] nao declarada!",
                      atomo);
	    } else {
                empilha (TSIMB[POS_SIMB].desloca);
                empilhaAux(TSIMB[POS_SIMB].tip);
            } 
          }
        T_ATRIB 
        expressao
          { 
             printf ("\tARZG\t%d\n", desempilha()); 
 	
 	     while (TOPO_PAUX > 0) { 
		verifica[idVerifica] = desempilhaAux();
		idVerifica++;  			 
	     }
	     idVerifica--; 
             while (idVerifica > 0) { 
		if (verifica[idVerifica] != verifica[idVerifica-1])  {
			idVerifica = 0; 
			ERRO ("\nERRO DE ATRIBUICAO\n"); 
		}
		idVerifica--; 
	     }	               
          }
      
      |

      T_IDENTIF 
          { 
            POS_SIMB = busca_simbolo (atomo);
            if (POS_SIMB == -1) {
                ERRO ("Variavel [%s] nao declarada!",
                      atomo);
            } else {
                empilha (TSIMB[POS_SIMB].desloca);
                empilhaAux (TSIMB[POS_SIMB].tip);
                atribuicaoVetor = 1;
            }
          }

      termo
      T_ATRIB
      expressao
      { 
        printf ("\tARZV\t%d\n", desempilha()); 
	     
             while (TOPO_PAUX > 0) { 
		verifica[idVerifica] = desempilhaAux();
		idVerifica++;  			 
	     }
	     idVerifica--; 
             while (idVerifica > 0) { 
		if (verifica[idVerifica] != verifica[idVerifica-1])  {
			idVerifica = 0; 
			ERRO ("\nERRO DE ATRIBUICAO VETOR\n"); 
		}
		idVerifica--; 
	      }
      }

      ;

expressao
      : expressao T_VEZES expressao 
          { 
	     printf ("\tMULT\n");
	     if (desempilhaAux() == 'i' && desempilhaAux() == 'i') { 
		empilhaAux('i'); 
	     } else { 
		ERRO ("\nERRO DE TIPOS\n");
	     }
          }

      | expressao T_DIV expressao
          { 
             printf ("\tDIVI\n");
	     if (desempilhaAux() == 'i' && desempilhaAux() == 'i') {
    		empilhaAux('i'); 
	     } else { 
		ERRO ("\nERRO DE TIPOS\n");
             }	     
          }

      | expressao T_MAIS expressao
          { 
	     printf ("\tSOMA\n"); 
             if (desempilhaAux() == 'i' && desempilhaAux() == 'i') {
    		empilhaAux('i'); 
	     } else { 
		ERRO ("\nERRO DE TIPOS\n");
             }	
          }

      | expressao T_MENOS expressao
          { 
            printf ("\tSUBT\n"); 
            if (desempilhaAux() == 'i' && desempilhaAux() == 'i') {
    	        empilhaAux('i'); 
	    } else { 
		ERRO ("\nERRO DE TIPOS\n");
            }
          }
      | expressao T_MAIOR expressao
          { 
	printf ("\tCMMA\n"); 
	if(indiceVetor == 0){            
            if (desempilhaAux() == 'i' && desempilhaAux() == 'i') {
    	        empilhaAux('i'); 
	    } else { 
		ERRO ("\nERRO DE CONDICIONAL\n");
            }
	}
          }
      | expressao T_MENOR expressao
          {
            printf ("\tCMME\n");
	    if(indiceVetor == 0){             
            if (desempilhaAux() == 'i' && desempilhaAux() == 'i') {
    	        empilhaAux('i'); 
	    } else { 
	        ERRO ("\nERRO DE CONDICIONAL\n");
            }
	   }
          }
      | expressao T_IGUAL expressao
          { 
            printf ("\tCMIG\n");  
	    if(indiceVetor == 0){                        
            if (desempilhaAux() == 'i' && desempilhaAux() == 'i') {
    	        empilhaAux('i'); 
	    } else { 
		ERRO ("\nERRO DE CONDICIONAL\n");
            }
	   }
          }
      | expressao T_E expressao
          { 
            printf ("\tCONJ\n");  
	if(indiceVetor == 0){                       
            if (desempilhaAux() == 'l' && desempilhaAux() == 'l') {
    	        empilhaAux('l'); 
	    } else { 
		ERRO ("\nERRO DE CONJUNCAO\n");
            }
	}
          }
      | expressao T_OU expressao
          { 
            printf ("\tDISJ\n");
		if(indiceVetor == 0){                          
            if (desempilhaAux() == 'l' && desempilhaAux() == 'l') {
    	        empilhaAux('l'); 
	    } else { 
		ERRO ("\nERRO DE DISJUNCAO\n");
            }
	}
          }
      | termo
      ;

termo
      : T_IDENTIF
          {
            POS_SIMB = busca_simbolo (atomo);
            if (POS_SIMB == -1)
               ERRO ("Variavel [%s] nao declarada!",
                         atomo);
	    else {
               printf ("\tCRVG\t%d\n", TSIMB[POS_SIMB].desloca);
               if(indiceVetor == 1) {
                  if(TSIMB[POS_SIMB].tip != 'i'){
                     ERRO ("O indice do vetor deve ser inteiro");
                  }
                indiceVetor = 0;  
               } else {
		  empilhaAux(TSIMB[POS_SIMB].tip);
	       }
            }               
          }

      | T_IDENTIF
          {
            POS_SIMB = busca_simbolo (atomo);
            if (POS_SIMB == -1)
               ERRO ("Variavel [%s] nao declarada!",
                         atomo);
            else {
               empilha(TSIMB[POS_SIMB].desloca);
               if(indiceVetor == 1){
                  if(TSIMB[POS_SIMB].tip != 'i'){
                    ERRO ("O indice do vetor deve ser inteiro");
                  }
                  indiceVetor = 0;
               }
            }  
          }

        termo
          {
            printf ("\tCRVV\t%d\n", desempilha()); 
	    indiceVetor = 1;
          }

      | T_NUMERO
          { 
	    indiceVetor = 0; 
            if(declaracaoVetor == 1){
              printf ("\tAMEM\t%s\n", atomo);
              CONTA_VARS = CONTA_VARS + atoi(atomo); 
              amem++;
              declaracaoVetor = 0;
            } else {
              printf ("\tCRCT\t%s\n", atomo);
	      if (atribuicaoVetor == 1) {
                 atribuicaoVetor = 0; 
              } else { 
		empilhaAux('i');
	      }
            }
          } 
      | T_V
          { 
	    printf ("\tCRCT\t1\n");
            empilhaAux('l');
            if(indiceVetor == 1) {
                ERRO ("O indice do vetor deve ser inteiro");            
            }  
	  } 
      | T_F
          { 
	    printf ("\tCRCT\t0\n"); 	    
            empilhaAux('l'); 
            if(indiceVetor == 1){
                ERRO ("O indice do vetor deve ser inteiro");            
            }  
	  } 
      | T_NAO termo
          { printf ("\tNEGA\n"); }
      | T_ABRE expressao T_FECHA
      | T_ABREV
        {indiceVetor = 1;} 
      expressao T_FECHAV
       {indiceVetor = 0;}
      ;

%%
/*+--------------------------------------------------------+
  |          Corpo principal do programa COMPILADOR        |
  +--------------------------------------------------------+*/

yywrap () {
}

yyerror (char *s)
{
  ERRO ("ERRO SINTATICO");
}

main ()
{
  yyparse ();
}

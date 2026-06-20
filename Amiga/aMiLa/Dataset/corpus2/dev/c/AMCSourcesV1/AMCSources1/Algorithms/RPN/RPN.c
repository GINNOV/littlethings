#include <stdio.h>
#include <stdlib.h>

#define MAX_SIZE_STACK  256

#define NUM     0

#define NODE    1

#define NUOVO( TYPE) (TYPE *)malloc( sizeof( TYPE));

#define res( P_OP)   (( (P_OP)->flag == NODE) ? (P_OP)->u.s.manipola( (P_OP)->u.s.P_left, (P_OP)->u.s.P_right) : (P_OP)->u.P_num->num)

typedef struct numero_E {
           double               num;
           struct numero_E      *next;
        } numero_E;

typedef double (*PFD)( struct tree_elem *, struct tree_elem *);

typedef struct tree_elem {
           char         flag;
           union {
              numero_E          *P_num;
              struct {
                 PFD                    manipola;
                 struct tree_elem       *P_left;
                 struct tree_elem       *P_right;
              } s;      
           } u;
        } tree_elem;    


double sottrazione( tree_elem *P_left, tree_elem *P_right );
double somma( tree_elem *P_left, tree_elem *P_right );
double moltiplicazione( tree_elem *P_left, tree_elem *P_right );
double divisione( tree_elem *P_left, tree_elem *P_right );
void stampa_ino( tree_elem *P_elem );
void stampa_post( tree_elem *P_elem );
numero_E *ins_par_in_list( numero_E **P_P_head, double num);
int leggi_nuovi_parametri( numero_E *P_head);

void main( int argc, char *argv[])
{
  tree_elem     **p, **head, *tmp;
  numero_E      *P_head_param = NULL;
  int           flag;

  head = ( tree_elem **)malloc( MAX_SIZE_STACK * sizeof( tree_elem *)); 
  p = head; 
  
  while( --argc >0 )
    if(( *++argv)[0] == '_') {
        tmp = NUOVO( tree_elem);
        tmp->u.s.P_left = NULL;
        tmp->u.s.P_right = NULL;
        tmp->flag = NODE;
        switch ( *++argv[0]) {
           case '+' :
                tmp->u.s.manipola = somma;
                break;
           case '-' :
                tmp->u.s.manipola = sottrazione;
                break;
           case '/' :
                tmp->u.s.manipola = divisione;
                break;
           case '*' :
                tmp->u.s.manipola = moltiplicazione;
                break;
           default  :
                printf("\nERRORE\n");
                return;
                break;
        }
        tmp->u.s.P_right = *--p;
        tmp->u.s.P_left  = *--p;
        *p++ = tmp;
    }
    else {
        tmp = NUOVO( tree_elem);
        tmp->flag = NUM;
        tmp->u.P_num = ins_par_in_list( &P_head_param, atof( *argv));
        *p++ = tmp;
    }
  flag = 1;
  do { 
     printf("\n"); stampa_ino( p[-1] ); printf("\n");
     printf("\n"); stampa_post( p[-1] ); printf("\n");
     --p;
     printf("risultato: %f\n", res( *p ));
     p++;
     flag = leggi_nuovi_parametri( P_head_param);
  } while( flag );
  return;
}
  
double somma( tree_elem *P_left, tree_elem *P_right)
{
  return( res( P_left) + res( P_right));
}

double sottrazione( tree_elem *P_left, tree_elem *P_right )
{
  return( res( P_left) - res( P_right));
}

double moltiplicazione( tree_elem *P_left, tree_elem *P_right)
{
  return( res( P_left) * res( P_right));
}

double divisione( tree_elem *P_left, tree_elem *P_right )
{
  return( res( P_left) / res( P_right));
}

void stampa_ino( tree_elem *P_elem )
{
  PFD pf;

  if ( P_elem->flag == NUM ) {
    printf(" %.3f ", P_elem->u.P_num->num );
  }
  else { 
    printf("(");
    stampa_ino( P_elem->u.s.P_left );
    pf = P_elem->u.s.manipola; 
    if ( pf == somma ) printf(" + ");
    else if ( pf == sottrazione ) printf(" - ");
         else if ( pf == moltiplicazione) printf(" * "); 
              else printf(" / "); 
    stampa_ino( P_elem->u.s.P_right );
    printf(")");
  }
  return;
}

void stampa_post( tree_elem *P_elem )
{
  PFD pf;

  if ( P_elem->flag == NUM ) {
    printf(" %.3f ", P_elem->u.P_num->num );
  }
  else { 
    stampa_post( P_elem->u.s.P_left );
    stampa_post( P_elem->u.s.P_right );
    pf = P_elem->u.s.manipola; 
    if ( pf == somma ) printf(" + ");
    else if ( pf == sottrazione ) printf(" - ");
         else if ( pf == moltiplicazione) printf(" * "); 
              else printf(" / "); 
  }
  return;
}

numero_E *ins_par_in_list( numero_E **P_P_head, double num)
{
  numero_E      *tmp, *scorri;
  
  tmp = NUOVO( numero_E);
  tmp->num = num;
  tmp->next = NULL;

  if( *P_P_head == NULL)
     *P_P_head = tmp;
  else {
     for( scorri = *P_P_head; scorri->next != NULL; scorri = scorri->next);
     scorri->next = tmp;
  }
  return tmp;
}

int leggi_nuovi_parametri( numero_E *P_head)
{
  numero_E      *scorri;
  char          stringa[32];
  int           i;

  for( scorri = P_head, i = 1; scorri != NULL; scorri = scorri->next, i++) {
     printf("P_%2d:\t",i);
     if ( scanf("%s",stringa) != 1 )
       return 0;
     scorri->num = atof( stringa);
  }
  return 1;
}


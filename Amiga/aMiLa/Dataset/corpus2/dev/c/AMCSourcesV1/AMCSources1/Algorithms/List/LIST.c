#include <stdio.h>
#include <stdlib.h>

typedef struct elem {
        int num;
        struct elem *next;
        } elem;

elem *create( void );
int is_in( int, elem* );
elem *insert( int, elem* );
int delete( int, elem* );
void stampa( elem* );

void main( void )
{
  elem *P_head;
  int dato, c;

  P_head = create();
  while ( 1 ) {
    do {
      printf("Inserisci (0)\t Cancella (1)\t Cerca (2)\t Stampa (3) ");
      scanf("%d", &c );
    } while ( c != 0 && c != 1 && c != 2 && c != 3 );
    if ( c != 3 ) {
      printf("Dato ?: ");
      scanf("%d", &dato );
    }
    switch(c) {
      case 0:
        insert( dato, P_head );
        break;
      case 1: 
        if ( ! delete( dato, P_head )) 
          printf("\t\t%d non presente in lista\n", dato );
        break;
      case 2:
        if ( ! is_in( dato, P_head ))
          printf("\t\t%d non presente in lista\n", dato );
        else
          printf("\t\t%d presente in lista\n", dato );
        break;
      case 3:
        stampa( P_head );
        break;
    }
  }
  return;
}

elem *create( void )
{
  elem *p;
  p = ( elem * )malloc( sizeof( elem ));
  p->next = NULL;
  return p;
}

int is_in( int dato, elem *P_list)
{
  elem *p;
  
  for ( p = P_list; p->next != NULL && p->next->num < dato; p = p->next );
  if ( p->next == NULL || p->next->num > dato ) 
     return 0;
  return 1;
}

elem *insert( int dato, elem *P_list )
{
  elem *p, *tmp; 
  
  for ( p = P_list; p->next != NULL && p->next->num < dato; p = p->next );
  
  if ( p->next == NULL || p->next->num > dato ) 
  {
    tmp = ( elem *)malloc( sizeof( elem ));
    tmp->num = dato;
    tmp->next = p->next;
    p->next = tmp;
  }

  return p->next;
}

int delete( int dato, elem *P_list )
{
  elem *p, *tmp;
  for ( p = P_list; p->next != NULL && p->next->num < dato; p = p->next );
  if ( p->next == NULL || p->next->num > dato )
    return 0;
  else { 
     tmp = p->next; 
     p->next = p->next->next;
     free( tmp );
     return 1;
  }
}

void stampa( elem *P_list )
{
  elem *p;

  for ( p = P_list; p->next != NULL; p = p->next )
    printf("%4d", p->next->num );
  printf("\n");
  return;
}

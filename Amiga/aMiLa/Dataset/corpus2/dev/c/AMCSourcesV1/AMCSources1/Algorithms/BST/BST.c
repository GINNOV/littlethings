#include <stdio.h>
#include <stdlib.h>

#define NEW(TYPE) (TYPE *)malloc( sizeof(TYPE))

struct tnode {
  int           dato;
  unsigned int  count;
  struct tnode *P_left;
  struct tnode *P_right;
};


struct tnode *addtree( struct tnode *, int );
void treeprint( struct tnode * );

void main( void )
{ 
  struct tnode *P_root;
  int           dato;

  P_root = NULL;
  while(1) {
    printf("Inserisci dato: ");
    scanf("%d", &dato );
    P_root = addtree( P_root, dato );
    treeprint( P_root );
  }
  return;
}

struct tnode *addtree( struct tnode *p, int key)
{
  if ( p == NULL ) {      
    p = NEW( struct tnode );
    p->dato = key;
    p->count = 1;
    p->P_left = p->P_right = NULL;
  }
  else if ( p->dato == key )
         p->count++;
  else if ( p->dato > key )
         p->P_left = addtree( p->P_left, key );
  else p->P_right = addtree( p->P_right, key );
  return p;
}

void treeprint( struct tnode *p )
{
  if ( p != NULL ) {
    treeprint(p->P_left);
    printf("%d %2d\n", p->count, p->dato);
    treeprint(p->P_right);
  }
  return;
}


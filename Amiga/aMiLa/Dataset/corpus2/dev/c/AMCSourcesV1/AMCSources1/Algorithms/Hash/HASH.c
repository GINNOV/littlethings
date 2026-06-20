#include <stdio.h>
#include <stdlib.h>

typedef struct elem {
        int col;
        int val;
        struct elem *next;
        } elem;

elem **create( int dim_r);
int set( elem **P_r_v, int dim_r, int dim_c, int row, int col, int val);
void stampa( elem **P_r_v, int dim_r );
void stampa1( elem **P_r_v, int dim_r, int dim_c );

void main( void )
{
  elem **P_row_vect;
  int m_row, m_col, row, col, dato, c;

  printf("N. di righe e colonne della matrice: ");
  scanf("%d %d", &m_row, &m_col );

  P_row_vect = create( m_row );
  while ( 1 ) {
    do {
      printf("Modifica (0)\t Stampa (1) ");
      scanf("%d", &c );
    } while ( c != 0 && c != 1 );
    switch(c) {
      case 0:
        printf("riga colonna valore ");
        scanf("%d %d %d", &row, &col, &dato );
        if ( ! set ( P_row_vect, m_row, m_col, row, col, dato ))
          printf("\nRiga o colonna inesistente (max = [%dx%d])\n", m_row-1, m_col-1);
        break;
      case 1: 
        stampa( P_row_vect, m_row );
        stampa1( P_row_vect, m_row, m_col );
        break;
    }
  }
  return;
}

elem **create( int n_row )
{
  elem **p;
  int i;
  p = ( elem ** )malloc( n_row * sizeof( elem *));
  for ( i = 0; i < n_row; i++ ) {
     p[i] = ( elem *)malloc( sizeof( elem ));
     p[i]->next = NULL;
  }
  return p;
}

int set(elem **P_r_v, int dim_r, int dim_c, int row, int col, int val)
{
elem *p, *tmp;

  if ( row > dim_r-1 || row < 0 || col > dim_c-1 || dim_c < 0 )
    return 0;
  for( p = P_r_v[row]; p->next != NULL && p->next->col < col; p = p->next );
  if ( p->next == NULL || p->next->col > col ) {
    if ( val != 0 ) {
      tmp = ( elem *)malloc( sizeof( elem ));
      tmp->col = col;
      tmp->val = val;
      tmp->next = p->next;
      p->next = tmp;
    }
  }
  else {
    if ( val != 0 )
      p->next->val = val;
    else {
      tmp = p->next; 
      p->next = p->next->next;
      free( tmp );
    }
  }
  return 1; 
}

void stampa( elem **P_r_v, int dim_r )
{
  int i, j;
  elem *p;
  printf("\n");
  for ( i = 0; i < dim_r; i++ ) {
    for ( p = P_r_v[i]; p->next != NULL; p = p->next ) {
      printf("<%d,%d> %d  ", i, p->next->col, p->next->val );
    }
    printf("\n");
  }
  return;
}

void stampa1( elem **P_r_v, int dim_r, int dim_c )
{
  int i, j, prec_col;
  elem *p;
  for ( i = 0; i < dim_r; i++ ) {
    prec_col = -1;
    for ( p = P_r_v[i]; p->next != NULL; p = p->next ) {
      for ( j = prec_col+1; j < p->next->col; j++ )
        printf("%3d", 0 );
      printf("%3d", p->next->val );
      prec_col = p->next->col;
    }
    for ( j = prec_col+1; j < dim_c; j++ )
      printf("%3d", 0 );

    printf("\n");
  }
  return;
}


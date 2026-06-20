/*
 * Binsort
 */

#include <stdio.h>
#include <stdlib.h>

typedef struct elem {
                double val;
                struct elem *next;
                } elem;

int read_file( char *s, double **P_v_P);
elem **create_hash( int dim_r);
int insert( elem *P_list_elem, double val);
void fill_vect( double *P_v, elem **P_h_P, int n);
int write_file( char *s, double *P_v, int n );
void stampa( elem **P_r_v, int dim_r );

void main( int argc, char **argv )
{
  double *P_vect;
  elem  **P_hash_P;
  int n_elem, i;
                                                                  
  if ( argc != 2 ) {
        printf("\nERRORE: linea di comando errata.\n");
        return;
  }
  if (( n_elem = read_file( *++argv, &P_vect )) == 0 ) {
        printf("\nERRORE: file inesistente o formato errato o memoria insufficiente.\n");
        return;
  }    
                   
  P_hash_P = create_hash( n_elem ); 

  for ( i = 0; 
                i < n_elem && 
                insert( P_hash_P[(int)(P_vect[i]*n_elem)], P_vect[i] ) != 0;
                i++ );
  
  if ( i < n_elem ) {
        printf("\nERRORE: memoria insufficiente.\n");
        return;
  }       
  
  stampa( P_hash_P, n_elem );
  fill_vect( P_vect, P_hash_P, n_elem );
  /*
  for ( i = 0; i < n_elem; i++ )
        printf("%.2lf ", P_vect[i] );
  */
  write_file( *argv, P_vect, n_elem );

  return;
}

int read_file( char *s, double **P_v_P)
{
  int n, i, flag;
  FILE *fp;
  if ((fp = fopen( s, "r" )) == NULL ||
          ( fscanf( fp, "%d;", &n )) == EOF ||
          ( *P_v_P = (double *)malloc( n*sizeof( double ))) == NULL ) {
        fclose( fp );
        return 0;
  }
  for ( i = 0, flag = ~EOF; i < n && flag != EOF; i++ ) {
        flag = fscanf( fp, "%lf", *P_v_P + i );
  }
  
  if ( flag == EOF ) {
        fclose( fp );
        return 0;
  }
  fclose( fp );
  return n;
}
  
elem **create_hash( int n_elem )
{
  elem **p;
  int i;
  p = ( elem ** )malloc( n_elem * sizeof( elem *));
  for ( i = 0; i < n_elem; i++ ) {
         p[i] = ( elem *)malloc( sizeof( elem ));
         p[i]->next = NULL;
  }
  return p;
}

int insert( elem *P_list_elem, double val)
{
  elem *p, *tmp;
  for( p = P_list_elem; p->next != NULL && p->next->val < val; p = p->next );

  if (( tmp = ( elem *)malloc( sizeof( elem ))) == NULL)
        return 0;
  tmp->val = val;
  tmp->next = p->next;
  p->next = tmp;
  return 1;
}

void fill_vect( double *P_v, elem **P_h_P, int n )
{
  int ind_hash, ind_vect;  
  elem *p;
  for ( ind_hash = 0, ind_vect = 0; ind_hash < n; ind_hash++)
        for ( p = P_h_P[ind_hash]; p->next != NULL; p = p->next)
          P_v[ind_vect++] = p->next->val;
  return;
}

int write_file( char *s, double *P_v, int n )
{
  int i;
  FILE *fp;
  if ((fp = fopen( s, "w" )) == NULL || fprintf( fp, "%d;\n", n ) < 0) {
        fclose( fp );
        return 0;
  }

  for ( i = 0; i < n && fprintf( fp, "%lf\n", P_v[i] ) > 0; i++ );

  fclose( fp );
  
  if ( i < n )
        return 0;

  return 1;
}

void stampa( elem **P_r_v, int dim_r )
{
  int i;
  elem *p;
  printf("\n");
  for ( i = 0; i < dim_r; i++ ) {
        printf("<%d>  ", i );
        for ( p = P_r_v[i]; p->next != NULL; p = p->next ) {
          printf("%.2f  ", p->next->val );
        }
        printf("\n");
  }
  return;
}

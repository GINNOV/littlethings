/*   MERGE SORT   */

#include <stdio.h>

#define MAX 8

void leggi_vett( char *s, int v[], int inf, int up );
void stampa_vett( char *s, int v[], int inf, int sup );
void merge_sort( int* A, int p, int r );
void merge( int* A, int p, int q, int r );

void main( void )
{
int vet[MAX];

   leggi_vett( "vet", vet, 0, MAX-1 );
   
   merge_sort( vet, 0, MAX-1 );
   
   printf("\nRISULTATO :\n");
   stampa_vett( "vet", vet, 0, MAX-1 );
   return;
}

void merge_sort( int* A, int p, int r )
{
int q;
   stampa_vett( "I", A, p, r );
   if ( p < r ) {
      q = ( p + r ) / 2;
      merge_sort( A, p, q );
      merge_sort( A, q+1, r );
      merge( A, p, q, r );
      stampa_vett( "O", A, p, r );
   }
   else 
      return;
}

void merge( int* A, int p, int q, int r )
{
static int B[MAX];
int i, j, k;

   for ( i = p, j = q+1, k = p; i <= q && j <= r; )
      if ( A[i] < A[j] )
         B[k++] = A[i++];
      else
         B[k++] = A[j++];

   for ( ; i <= q; )
      B[k++] = A[i++];

   for ( ; j <= r; )
      B[k++] = A[j++];

   for ( k = p; k <= r; k++ )
      A[k] = B[k];
}


void leggi_vett( char *s, int v[], int inf, int sup )
{
int j;
   printf("INTRODUCI %s:\n", s);
   for ( j = inf; j <= sup; j++ ) {
      printf ("\t%s[%d] = ", s, j);
      scanf ("%d", &v[j]);
   }
   printf("\n");
}

void stampa_vett( char *s, int v[], int inf, int sup )
{
int i;
   printf("VETTORE %s:\t", s);
   for ( i = inf; i <= sup; i++ )
      printf (" %3d ", v[i]);
   printf("\n");
}


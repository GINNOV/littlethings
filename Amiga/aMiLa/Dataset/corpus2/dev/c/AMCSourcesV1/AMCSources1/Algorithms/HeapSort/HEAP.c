/*
 * HEAP Sort
 */

#include <stdio.h>

#define SIZE 8

#define PARENT(i)  (i>>1)          /* i/2 */
#define LEFT(i)    (i<<1)          /* i*2 */
#define RIGHT(i)   (((i<<1) == SIZE ) ? (i<<1) : ((i<<1)+1))      /* i*2+1 */

void swap( int *ia, int i ,int j );
void build_heap( int A[], int dim );
void heapify( int A[], int i, int heap_size );
void heapsort( int A[], int dim );
void leggi_vett( char *s, int v[], int inf, int sup );
void stampa_vett( char *s, int v[], int inf, int sup );

void main( void )
{
int vett[SIZE+1];

    leggi_vett("A", vett, 1, SIZE );

    stampa_vett("A", vett, 1, SIZE);
   
    heapsort( vett, SIZE );

    stampa_vett("A", vett, 1, SIZE);
    
    return;
}

void heapsort( int *A, int dim )
{
int i, heap_size ;
    heap_size = dim;
    build_heap( A, heap_size );
    stampa_vett("h(A)", A, 1, SIZE);
    for ( i = dim; i >= 2; i-- ) {
        swap( A, 1, i );
        heapify( A, 1, --heap_size );
        stampa_vett("A", A, 1, heap_size);
    }
    return;
}

void heapify( int *A, int i, int heap_size )
{
int l, r, largest;
    l = LEFT(i);
    r = RIGHT(i);
                  
    if (( l <= heap_size ) && ( A[l] > A[i] ))  /* r */
        largest = l;
    else  largest = i;

    if (( r <= heap_size ) && ( A[r] > A[largest] ))
        largest = r;

    if ( largest != i ) { 
        swap( A, i, largest );
        heapify( A, largest, heap_size );
    }

    return;
}

void build_heap( int *A, int heap_size )
{
int i;

    for( i = ( heap_size >> 1 ); i >= 1; i-- )
        heapify( A, i, heap_size );

    return;
}

void swap( int *ia, int i ,int j )
{
int tmp; 
    tmp = ia[i];
    ia[i] = ia[j];
    ia[j] = tmp;
    return;
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


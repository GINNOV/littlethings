#include <stdio.h>

#define MAX 8

void swap ( int *ia, int i, int j );
void qsort ( int *ia, int low, int high );
void leggi_vett( char *s, int v[], int dim );
void stampa_vett( char *s, int v[], int inf, int sup );

int ia1[MAX]; 

void main ( void )
{       
   leggi_vett( "A", ia1, 8 );
   qsort( ia1, 0, 7 );

   return;
}

void swap ( int *ia, int i, int j )
{
int tmp;    
	if ( i != j ) {
	tmp = ia[ i ];
	ia[ i ] = ia[ j ];
	ia[ j ] = tmp;
	}
}

void qsort ( int *ia, int low, int high )
{
int lo, hi, elem;    

	if ( low < high ) {
	lo = low;
	hi = high + 1;
	elem = ia[ low ];
	
	stampa_vett("I", ia, low, high );
	
	for ( ;; ) {
		while ( lo < high && ia[ ++lo ] <= elem )
			printf("%d\t", lo);
			;
		while ( ia[ --hi ] > elem )
			;
		
		if ( lo < hi )
		swap ( ia, lo, hi );
		else break;
	} 
	
	swap ( ia, low, hi );
	qsort ( ia, low, hi-1 );
	qsort ( ia, hi+1, high );
	
	stampa_vett("O", ia, low, high );
	}
}        

void leggi_vett( char *s, int v[], int dim )
{
int j;
   printf("INTRODUCI %s:\n", s);
   for ( j = 0; j < dim; j++ ) {
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

/*
INTRODUCI A:
	A[0] =  A[1] =  A[2] =  A[3] =  A[4] =  A[5] =  A[6] =  A[7] = 
VETTORE I:    44   55   12   42   94   18    6   67 
VETTORE I:    18    6   12   42 
VETTORE I:    12    6 
VETTORE O:     6   12 
VETTORE O:     6   12   18   42 
VETTORE I:    94   55   67 
VETTORE I:    67   55 
VETTORE O:    55   67 
VETTORE O:    55   67   94 
VETTORE O:     6   12   18   42   44   55   67   94 
*/

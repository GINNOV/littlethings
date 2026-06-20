/*   COUNTING SORT                                    */
/*   Programma privo di stampe e formattazione output */

#include <stdio.h>

#define DIM_MAX   8     /*   numero elementi vettore   */
#define VAL_MAX   6     /*   valore massimo nel vettore   */

void stampaT( const char s, const int inf, const int sup);
void stampaD( const int v[], const int inf, const int sup);

void main ( void )
{
int i, j, minvar, vetvar,
    A[DIM_MAX], C[VAL_MAX+1], B[DIM_MAX];

   /*   ciclo di lettura vettore   */
   printf("INTRODUCI IL VETTORE (elementi =  1..%d):\n", VAL_MAX);
   for ( i = 0; i < DIM_MAX; i++) {
      printf ("\tA[%d] = ", i);
      scanf ("%d", &A[i]);
   }
   printf("\n");

   for ( i = 1; i <= VAL_MAX; i++)
      C[i] = 0;
   
   for ( j = 0; j < DIM_MAX; j++)
      C[A[j]] = C[A[j]] + 1;
   
   for ( i = 2; i <= VAL_MAX; i++)
      C[i] = C[i] + C[i-1];
   
   for (j = DIM_MAX-1; j >= 0; j--) {
      B[C[A[j]]-1] = A[j];
      C[A[j]] = C[A[j]] - 1;
   }
   
   stampaT('B',0,DIM_MAX);printf("\n");
   stampaD(B,0,DIM_MAX);printf("\n");
  
   return; 
}

void stampaT( const char s, const int inf, const int sup)
{
int j;
   for (j = inf; j < sup; j++)
      printf (" %c[%d]", s, j);
   return;
}

void stampaD( const int v[], const int inf, const int sup)
{
int j;
   for ( j = inf; j < sup; j++)
      if( v[j] != -1 )
         printf ("%5d", v[j]);
      else printf("     ");
   return;
}

/*   COUNTING SORT                                             */
/*   Programma in cui il secondo ciclo su C e' stato eliminato */
/*   senza pero' avere vantaggi                                */

#include <stdio.h>

#define DIM_MAX   8     /*   numero elementi vettore   */
#define VAL_MAX   6     /*   valore massimo nel vettore   */

void stampaT( const char s, const int inf, const int sup);
void stampaD( const int v[], const int inf, const int sup);

void main ( void )
{
int i, j, k,
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
   
   for( i = 1, j = 0; i <= VAL_MAX; i++)   
      for( k = 1; k <= C[i]; k++) {
         B[j] = i;
         j++;
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

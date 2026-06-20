/*   BUBBLE SORT CON FLAG   */

#include <stdio.h>

#define MAX 8

void main( void )
{
int flag;     /* anche char */
int i, j, k, l, r, tmp;
int vet[MAX];

   /*   ciclo di lettura vettore   */ 
   printf("INTRODUCI IL VETTORE:\n");
   for ( i = 0; i < MAX; i++) {
      printf ("\tvet[%d] = ", i);
      scanf ("%d", &vet[i]);
   }
   printf("\n");
   
   l = 1; r = MAX-1; k = MAX-1;
   for ( flag = 1; ( l < r ) && ( flag == 1 ); l = k+1 ) {
      for ( j = r, flag = 0; j >= l; j-- )
         if ( vet[j-1] > vet[j] ) {
            tmp = vet[j-1]; vet[j-1] = vet[j]; vet[j]=tmp;
            k = j;         
            flag = 1;
         }
      
      printf("CICLO %d %d:\n", l, r);
      for ( i = 0; i < MAX; i++)
         printf (" %3d ", vet[i]);
      printf("\n");
   }

   return;
}

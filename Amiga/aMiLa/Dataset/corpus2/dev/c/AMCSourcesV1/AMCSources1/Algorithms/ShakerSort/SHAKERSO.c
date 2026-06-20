/*   SHAKERSORT CON FLAG                                                 */
/*   In questo algoritmo si tiene memoria del punto in cui e' avvenuto   */
/*   l'ultimo scambio: oltre gli elementi sono certamente tutti ordinati */

#include <stdio.h>

#define MAX 8

void main( void )
{
int i, j, k, l, r, tmp, vet[MAX];

   /*   ciclo di lettura vettore   */
   printf("INTRODUCI IL VETTORE:\n");
   for ( i = 0; i < MAX; i++) {
      printf ("\tvet[%d] = ", i);
      scanf ("%d", &vet[i]);
   }
   printf("\n");
   
   l = 1; r = MAX-1; k = MAX-1;
   do {
      for ( j = r; j >= l; j-- ) 
         if ( vet[j-1] > vet[j] ) {
            tmp = vet[j-1]; vet[j-1] = vet[j]; vet[j]=tmp;
            k = j;
         }
      
      if ( l <= r ) {
          printf("CICLO UP %d %d:\n", l, r);
          for ( i = 0; i < MAX; i++)
             printf (" %3d ", vet[i]);
          printf("\n");
      }

      l = k+1;
      
      for ( j = l; j <= r; j++ ) 
         if ( vet[j-1] > vet[j] ) {
            tmp = vet[j-1]; vet[j-1] = vet[j]; vet[j]=tmp;
            k = j;
         }
      
      if ( l <= r ) {
          printf("CICLO DOWN %d %d:\n", l, r);
          for ( i = 0; i < MAX; i++)
             printf (" %3d ", vet[i]);
          printf("\n");
      }
      
      r = k-1;         
   
   } while ( r >= l );

   return;
}

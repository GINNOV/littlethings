/*
 *  SELECTION SORT
 */

#include <stdio.h>
#define MAX 5

void main ( void )
{
int i       ,
    j       ,
    minvar  ,
    vetvar  ,
    vet[MAX];

   /*   ciclo di lettura vettore   */
   printf("INTRODUCI IL VETTORE:\n");
   for ( i = 0; i < MAX; i++) {
      printf ("\tvet[%d] = ", i);
      scanf ("%d", &vet[i]);
      }
   printf("\n");

   for (i = 0; i < MAX; i++) {
      minvar = i;

      for ( j = i + 1; j < MAX; j++)
         if ( vet[j] < vet[minvar] ) minvar = j;

      /*   anche senza if   */
      if ( minvar != i ) {
         vetvar = vet[minvar];
         vet[minvar] = vet[i];
         vet[i] = vetvar;
      }

      printf("CICLO %d :\n", i);
         for ( j = 0; j < MAX; j++)
            printf (" %3d ", vet[j]);
      printf("\n");
   }

   /*   stampa vettore   */
   printf("\nRISULTATO :\n");
   for ( i = 0; i < MAX; i++)
      printf ("vet[%d] = %d\n", i, vet[i]);

   return;
}

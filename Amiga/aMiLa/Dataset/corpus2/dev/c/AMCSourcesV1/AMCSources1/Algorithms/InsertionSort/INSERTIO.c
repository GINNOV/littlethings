/*   INSERTION SORT   */

#include <stdio.h>

#define MAX 5

void main( void )
{
int i       ,
    j       ,
    vetvar  ,
    vet[MAX];

   /*   ciclo di lettura vettore   */
   printf("INTRODUCI IL VETTORE:\n");
   for (i=0; i<MAX; i++) {
      printf ("\tvet[%d] = ", i);
      scanf ("%d", &vet[i]);
   }
   printf("\n");
   
   for (i = 1; i < MAX; i++) {
      vetvar = vet[i];
      j = i-1;
      while ( j >= 0 && vetvar < vet[j] ) { 
         vet[j+1] = vet[j];
         j--;
      }
      vet[j+1] = vetvar;
   
      printf("CICLO %d :\n", i);
         for (j = 0; j < MAX; j++)
            printf (" %3d ", vet[j]);
      printf("\n");
   }
   
   /*   stampa vettore   */
   printf("\nRISULTATO :\n");
   for (i=0; i<MAX; i++)
      printf ("vet[%d] = %d\n", i,vet[i]);

   return;
}

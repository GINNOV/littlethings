/*
 *  RADIX SORT  (with selection sort)
 */

#include <stdio.h>
#define MAX_DIGIT   3
#define MAX_DIM     7

void main ( void )
{
int i       ,
    j       ,
    digit   ,
    pot     ,
    vetvar  ,
    vet[MAX_DIM];

   /*
    *  ciclo di lettura vettore
    */
   printf("INTRODUCI IL VETTORE:\n");
   for ( i = 0; i < MAX_DIM; i++) {
      printf ("\tvet[%d] = ", i);
      scanf ("%d", &vet[i]);
   }
   printf("\n");

   for ( pot = 1, digit = 1; digit <= MAX_DIGIT; digit++) {
      pot = pot*10;

      for ( i = 1; i < MAX_DIM; i++) {
         vetvar = vet[i];
         j = i;
         while ( --j >= 0 && ( vetvar % pot ) < ( vet[j] % pot ) )
            vet[j+1] = vet[j];

         vet[j+1] = vetvar;
      }

      printf("CIFRA %d :\n", digit);
      for ( j = 0; j < MAX_DIM; j++)
         printf (" %3d ", vet[j]);
      printf("\n");
   }

   /*
    *   stampa vettore
    */
   printf("\nRISULTATO :\n");
   for (i=0; i<MAX_DIM; i++)
      printf ("vet[%d] = %d\n", i,vet[i]);

   return;
}

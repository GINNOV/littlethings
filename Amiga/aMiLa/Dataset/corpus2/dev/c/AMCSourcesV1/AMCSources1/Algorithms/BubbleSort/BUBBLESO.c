/*   BUBBLE SORT CON FLAG   */

#include <stdio.h>

#define MAX 5

void main( void )
{
int flag;     /* anche char */
int i       ,
    j       ,
    vetvar  ,
    vet[MAX];

   /*   ciclo di lettura vettore   */
   printf("INTRODUCI IL VETTORE:\n");
   for ( i = 0; i < MAX; i++) {
      printf ("\tvet[%d] = ", i);
      scanf ("%d", &vet[i]);
   }
   printf("\n");
   
   for ( i = 0, flag = 1; ( i < MAX-1 ) && ( flag == 1); i++) {
      flag = 0;
      for ( j = 0; j < MAX-1-i; j++)
         if ( vet[j] > vet[j+1]) {
            flag = 1;
            vetvar = vet[j];
            vet[j] = vet[j+1];
            vet[j+1] = vetvar;
         }
   
      /*   stampa vettore   */
      printf("CICLO %d:\n", i);
      for ( j = 0; j < MAX; j++)
         printf (" %3d ", vet[j]);
      printf("\n");
   }
   
   /*   stampa vettore   */
   printf("\nRISULTATO :\n");
   for (i=0; i<MAX; i++)
      printf ("vet[%d] = %d\n", i,vet[i]);
   
   return;
}

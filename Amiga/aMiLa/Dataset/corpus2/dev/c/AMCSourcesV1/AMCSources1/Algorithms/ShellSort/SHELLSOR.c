/*   SHELL SORT   */

#include <stdio.h>

#define MAX 8

main ()

{
int i       ,
    j       , 
    step    ,
    vetvar  ,
    vet[MAX];

/*   ciclo di lettura vettore   */
printf("INTRODUCI IL VETTORE:");
for (i=0; i<MAX; i++)
   {
   printf ("\nvet[%d] = ", i);
   scanf ("%d", &vet[i]);
   }
printf("\n\n");

for (step=MAX/2; step>0; step=step/2)
   {
   for (i=step; i<MAX; i++)
      for (j=i-step; j>=0 && vet[j]>vet[j+step]; j=j-step)
         {
         vetvar = vet[j];
         vet[j] = vet[j+step];
         vet[j+step] = vetvar;
         }

   printf("CICLO con step = %d\n", step);
      for (i=0; i<MAX; i++)
         printf ("vet[%d]  ", i);
      printf("\n");
      for (i=0; i<MAX; i++)
         printf ("%4d    ", vet[i]);
      printf("\n");
   }

/*   stampa vettore   */
printf("\nRISULTATO :\n");
for (i=0; i<MAX; i++)
   printf ("vet[%d]  ", i);
printf("\n");
for (i=0; i<MAX; i++)
   printf ("%4d    ", vet[i]);
printf("\n");

}

/*
**  Selectionsort in C
**  Norman Walter, Universität Stuttgart
**  Datum: 21.8.2001
**
**  Eigenschaften: Selection Sort benötigt ungefähr
**  N^2/2 Vergleiche und N Austauschoperationen.
**  Für Dateien mit großen Datensätzen und kleinen
**  Schlüsseln ist Selection Sort linear.
*/

#include <stdio.h>
#include <stdlib.h>

#define maxN 100

void display(int a[], int n)
{

/* Gibt komplettes Array aus */

   int i;
   for (i = 1; i <= n; i++) printf ("%d ", a[i]);
    printf("\n");
}


void selection(int a[], int N)

/* Selection-Sort Algorithmus */
/* Sortieren durch direktes Auswählen */

  {

    /* Wiederholt das kleinste verbleibende Element auswählen */

    int i, j, min, t;
    for (i = 1; i < N; i++)
        {
            min = i;
            for (j = i+1; j <= N; j++)
            if (a[j] < a[min]) min = j;
                /* Elemente Austauschen */
                t = a[min]; a[min] = a[i]; a[i] = t; display(a,N);
         }
  }

int main()

{

int i;
int n, a[maxN+1];

/* Schleife erzeugt zufällige Permutation */

  for(n=0; n<=15; n++)
  {
    i = rand() % 10;
    a[n+1] = i;
    printf ("%d ",i);
  }

printf("\n");

/* Array sortieren */

a[0] = 0; selection(a,n);

return(0);

}

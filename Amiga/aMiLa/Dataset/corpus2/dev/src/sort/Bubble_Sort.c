/*
**  Bubble Sort Algorithmus in C
**  Norman Walter, Universität Stuttgart
**  Datum: 21.8.2001
**
**  Eigenschaften: Bubble Sort benötigt im Durchschnitt
**  und im ungünstigsten Fall ungefähr N^2/2 Vergleiche
**  und N^2/2 Austauschoperationen.
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

void bubble(int a[], int N)

/* Bubble-Sort Algorithmus */
/* Sortieren durch direktes Austauschen */

  {

    /* Durchlaufe immer wieder die Datei und vertausche
    ** jedesmal, wenn es notwendig ist, benachbarte Elemente;
    ** wenn bei einem Durchlauf kein Austausch mehr erforderlich
    ** ist, ist die Datei sortiert.
    */

    int i, j, t;
    for (i = N; i >= 1; i-- )
        for (j = 2; j <= i; j++)
            if (a[j-1] > a[j])
                { t = a[j-1]; a[j-1] = a[j]; a[j] = t;
                    display(a,N); }
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

a[0] = 0; bubble(a,n);

return(0);

}

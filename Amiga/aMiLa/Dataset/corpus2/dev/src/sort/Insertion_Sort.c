/*
**  Insertion Sort Algorithmus in C
**  Norman Walter, Universität Stuttgart
**  Datum: 22.8.2001
**
**  Eigenschaften: Insertion Sort benötigt im Durchschnitt
**  ungefähr N^2/4 Vergleiche und N^2/8 Austauschoperationen,
**  im ungünstigsten Fall doppelt so viele.
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

void insertion(int a[], int N)

/* Insertion-Sort Algorithmus */
/* Sortieren durch direktes Einfügen */

  {
    /* Betrachte die Elemente eines nach dem anderen und füge jedes
    ** an seinen richtigen Platz zwischen den bereits betrachteten
    ** ein, wobei diese sortiert bleiben. Das gerade betrachtete
    ** Element wird eingefügt, indem die größeren Elemente einfach
    ** um eine Position nach rechts bewegt werden und das Element
    ** dann auf dem freigewordenen Platz eingefügt wird.
    */

    int i, j, v;
    for (i = 2; i <= N; i++ )
        {
            v = a[i]; j = i;
            while (a[j-1] > v)
                { a[j] = a[j-1]; j--; }
            a[j] = v;
            display(a,N);
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

a[0] = 0; insertion(a,n);

return(0);

}

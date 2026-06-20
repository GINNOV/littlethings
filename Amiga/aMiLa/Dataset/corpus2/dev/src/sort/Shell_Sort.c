/*
**  Shellsort Algorithmus in C
**  Norman Walter, Universität Stuttgart
**  Datum: 22.8.2001
**
**  Shellsort ist eine einfache Erweiterung von Insertion Sort,
**  bei dem eine Erhöhung der Geschwindigkeit dadurch erzielt
**  wird, daß ein Vertauschen von Elementen ermöglicht wird,
**  die weit voneinander entfernt sind.
**
**  Eigenschaften: Shellsort führt niemals mehr als
**  N^(2/3) Vergleiche aus.
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

void shellsort(int a[], int N)

/* Shellsort Algorithmus */

  {
    /* Durch das h-Sortieren für große h können wir Elemente
    ** im Feld über größere Entfernungen bewegen und damit
    ** eine h-Sortierung für kleinere Werte von h erleichtern.
    ** Indem man eine solche Prozedur für eine beliebige Folge
    ** von Werten von h anwendet, die mit 1 endet, erhält man
    ** eine sortierte Datei.
    */

    int i, j, h, v;
    for (h = 1; h <= N/9; h = 3*h+1);
        for ( ; h > 0; h /= 3)
            for (i = h+1; i <= N; i +=1)
                {
                    v = a[i]; j = i;
                    while (j>h && a[j-h]>v)
                        { a[j] = a[j-h]; j -= h; }
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

a[0] = 0; shellsort(a,n);

return(0);

}

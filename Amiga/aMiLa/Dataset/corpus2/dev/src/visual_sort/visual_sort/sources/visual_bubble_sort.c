/*
 *   Visualisierung elementarer Sortieralgorithmen: Bubble Sort
 *   Norman Walter, Universität Stuttgart
 *   Datum: 1.9.2001
 *
 *   Implementierung nach einem Beispiel aus dem Buch
 *   "Algorithmen in C". Die graphische Ausgabe
 *   erfolgt mittels OpenGL.
 */

#include <stdlib.h>
#include <GL/glut.h>

#define maxN 1000  // Maximale Größe des Arrays definieren

/* Funktionsprototypen */

void malen(void);
void box(int x, int y, int r);
void display(int a[], int n);
void bubble(int a[], int N);
void swap (int a[], int N, int x, int y);
void mix (int a[], int N);

int main (int argc, char **argv)
{

  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
  glutInitWindowSize(300, 300);
  glutInitWindowPosition(100, 100);
  glutCreateWindow("OpenGL Bubble Sort");
  glClearColor(0.0, 0.0, 0.0, 0.0);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(0.0, 100, 0.0, 100, -1.0, 1.0);

  glutDisplayFunc(&malen);
  glutMainLoop();
  return(0);
}

void malen(void)
{

  int n, a[maxN+1];

  /* Array initialisieren */

  for(n=0; n<=100; n++)
  {
    a[n+1] = n;
  }

  /* Zufällige Permutation erzeugen */

  mix(a,n);

  /* Fensterinhalt löschen */
  glClear(GL_COLOR_BUFFER_BIT);

  glColor3f(1.0,0.0,0.0);

  /* Array sortieren */

  a[0] = 0; bubble(a,n);

}

void box(int x, int y, int r)

{
   /* Zeichnet ein Quadrat mit Radius r an den Koordinaten x,y */

   glRectf(x-r,y+r,x+r,y-r);
}


void display(int a[], int n)
{

   /* Gibt komplettes Array aus */

   int i;

   /* Fensterinhalt löschen */
   glClear(GL_COLOR_BUFFER_BIT);

   for (i = 1; i <= n; i++) box(a[i], i, 2);


   glFlush();
   glutSwapBuffers();
}

void bubble(int a[], int N)

 /*  Bubble-Sort Algorithmus:
  *  Sortieren durch direktes Austauschen
  */

  {

    /*  Durchlaufe immer wieder die Datei und vertausche
     *  jedesmal, wenn es notwendig ist, benachbarte Elemente;
     *  wenn bei einem Durchlauf kein Austausch mehr erforderlich
     *  ist, ist die Datei sortiert.
     */

    int i, j, t;
    for (i = N; i >= 1; i-- )
        for (j = 2; j <= i; j++)
            if (a[j-1] > a[j])
            {
              swap(a, N, j-1, j);
              display(a,N);
            }
  }


void swap (int a[], int N, int x, int y)

  {
    /*  Vertauschung der Elemente x und y  */

    int t; // Temporärer Speicher

    t = a[x]; a[x] = a[y]; a[y] = t;
  }

void mix (int a[], int N)

  {
    /*  Erzeugt Permutation durch Vertauschung
     *  zweier zufällig ausgewählter Elemente
     */

    int i;

    for (i = 1; i <= 100; i++)
    {
        swap(a, N, rand()%N, rand()%N);
    }
  }

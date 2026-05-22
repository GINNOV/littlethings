/*
 *   Visualisierung elementarer Sortieralgorithmen: Insertion Sort
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
void insertion(int a[], int N);
void swap (int a[], int N, int x, int y);
void mix (int a[], int N);

int main (int argc, char **argv)
{

  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
  glutInitWindowSize(300, 300);
  glutInitWindowPosition(100, 100);
  glutCreateWindow("OpenGL Insertion Sort");
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

  a[0] = 0; insertion(a,n);

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

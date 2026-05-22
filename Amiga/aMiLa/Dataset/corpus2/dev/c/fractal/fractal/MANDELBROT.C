/* C-Kompaktkurs mit Beispielen in Open GL        */
/* Norman Walter, Universität Stuttgart, 2001     */
/* Mandelbrot Generator in OpenGL                 */

#include <stdio.h>
#include <stdlib.h>
#include <GL/glut.h>
#include <math.h>

void malen(void);

struct struct_farbe
/* Struktur für Rot, Grün und Blauwerte */
{
  GLfloat r;
  GLfloat g;
  GLfloat b;
};

struct struct_farbe apfel(float cx, float cy)
{
  struct struct_farbe farbe;
  float x = 0.0;
  float y = 0.0;
  float tx;
  float ty;
  int n = 0;

  /* Algorhytmus zum Iterieren der Farbwerte */
  while(pow(x, 2) + pow(y, 2) <= 4.0 && n < 100)
    {
      tx = pow(x, 2) - pow(y, 2) + cx;
      ty = 2 * x * y + cy;
      x = tx;
      y = ty;
      n++;
    }

  farbe.r = 1.0;
  farbe.g = 0.0;
  farbe.b = 0.0;

  n -= 50;
  
  farbe.r = farbe.r - sin((float)n/100.0 * M_PI);
  farbe.g = farbe.g + cos((float)n / 100.0 * M_PI);
 
  return farbe;
}


int main(int argc, char **argv)
{
  glutInit(&argc, argv);
  /* Hier wird der Double Buffer Mode Aktiviert */
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
  glutInitWindowSize(400, 300);
  glutInitWindowPosition(100,100);
  glutCreateWindow("OpenGL Mandelbrot");
  glClearColor(0.0,0.0,0.0,0.0);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(-2.3, 1.0, -1.25, 1.25, -1.0, 1.0);
  glutDisplayFunc(&malen);

  glutMainLoop();

  return(0);
   
}


void malen(void)
{
  float x = -2.30;
  float y = -1.25;

  struct struct_farbe farbe;
  glClear(GL_COLOR_BUFFER_BIT);
  glutSwapBuffers();
  
  glBegin(GL_POINTS);

  while(x <= 1.0)
    {
      y = -1.25;
      while(y <= 1.25)
    {
      farbe = apfel(x, y);

      glColor3f(farbe.r, farbe.g, farbe.b);
      glVertex2f(x, y);
      y += 0.005;
    }
      x += 0.005;
    }
  glEnd();
  glFlush();
  /* Alles Gezeichnet -> Screen Swap */
  glutSwapBuffers();
}

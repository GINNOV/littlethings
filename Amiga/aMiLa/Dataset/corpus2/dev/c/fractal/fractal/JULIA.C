/* C-Kompaktkurs mit Beispielen in Open GL        */
/* Norman Walter, Universität Stuttgart, 2001     */
/* Julia Generator in OpenGL                 */

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
  float x = cx;
  float y = cy;
  float a = -0.74543;
  float b = 0.11301;
  float tx;
  float ty;
  int n = 0;

  /* Algorhytmus zum Iterieren der Farbwerte */
  while(pow(x, 2) + pow(y, 2) <= 4.0 && n < 100)
    {
      tx = pow(x, 2) - pow(y, 2) + a;
      ty = 2 * x * y + b;
      x = tx;
      y = ty;
      n++;   
    }
  farbe.r = 1.0;
  farbe.g = 0.0;
  farbe.b = 1.0;

  if (n >=100)
    {  
      farbe.r = x/sqrt(pow(x,2)+pow(y,2));
      farbe.g = y/sqrt(pow(x,2)+pow(y,2));;
    }

  else

    { 
      farbe.r = farbe.g = farbe.b = 0.0;
    }

  return farbe;
}


int main(int argc, char **argv)
{
  glutInit(&argc, argv);
  /* Hier wird der Double Buffer Mode Aktiviert */
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
  glutInitWindowSize(400, 300);
  glutInitWindowPosition(100,100);
  glutCreateWindow("OpenGL Julia");
  glClearColor(0.0,0.0,0.0,0.0);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(-2.0, 2.0, -2.0, 2.0, -1.0, 1.0);
  glutDisplayFunc(&malen);

  glutMainLoop();

  return(0);
   
}


void malen(void)
{
  float x = -2.0;
  float y = -2.0;

  struct struct_farbe farbe;
  glClear(GL_COLOR_BUFFER_BIT);
  
  glBegin(GL_POINTS);

  while(x <= 2.0)
    {
      y = -2.0;
      while(y <= 2.0)
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

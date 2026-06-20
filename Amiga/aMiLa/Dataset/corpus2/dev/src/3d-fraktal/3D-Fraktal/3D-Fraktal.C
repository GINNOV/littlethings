/*  3D Fraktalstern
 *  Autor: Norman Walter, Universität Stuttgart
 *  Datum: 21.2.2002
 *  3-dimensionales, animiertes, rekursives Fraktal mit OpenGL.
 *  Leichte Abwandlung des Fraktalalgorithmus aus dem Buch "Algorithmen in C".
 */

#include <stdio.h>
#include <stdlib.h>
#include <GL/glut.h>

/* Id's für das Menü */

#define ANIMATE 10
#define QUIT 100

static GLboolean Animate = GL_TRUE;

double winkel = 0.0;

void malen(void);
void malen_anstossen(void);
void box(int x, int y, int r);

GLuint DasFraktal;

static void star( int x, int y, int r)

   /* Zeichnet Fraktalstern durch rekursive Funktionsaufrufe */

{
    if (r>0)
        {
            star(x-r,y+r,r/2);
            star(x+r,y+r,r/2);
            star(x-r,y-r,r/2);
            star(x+r,y-r,r/2);
            box(x,y,r);
        }

}

static void ModeMenu(int entry)
{
   /* Menü abfragen */

   if (entry==ANIMATE) {
      Animate = !Animate;
   }
   else if (entry==QUIT) {
      exit(0);
   }

   glutPostRedisplay();
}

int main (int argc, char **argv)
{
  /* Farbe und Position der Lichtquelle */

 GLfloat light0_pos[] = {25.,25.,80.,1.0};
 GLfloat light0_color[] = {1.0,1.0,1.0,1.0};
 GLfloat ambient_light[] = {0.5,0.5,0.5,1.0};

 glutInit(&argc, argv);

 /* Double Buffer und Depth Buffer aktivieren */

 glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
 glutInitWindowSize(400, 300);
 glutInitWindowPosition(100, 100);
 glutCreateWindow("3D-Fraktal");

 glClearColor(0.0, 0.0, 0.0, 0.0);

   glLightModelfv(GL_LIGHT_MODEL_AMBIENT,ambient_light);
   glLightfv(GL_LIGHT0,GL_POSITION,light0_pos);
   glLightfv(GL_LIGHT0, GL_DIFFUSE, light0_color);

   glFrontFace(GL_CW);
   glEnable(GL_LIGHTING);
   glEnable(GL_LIGHT0);

   glEnable(GL_DEPTH_TEST);
   glDepthFunc(GL_LESS);

   glEnable(GL_AUTO_NORMAL);
    glEnable(GL_NORMALIZE);

 /* Fraktal in eine Display-Liste schreiben */

   DasFraktal = glGenLists (1);
   glNewList(DasFraktal, GL_COMPILE);
   star(0,0,12);
   glEndList();

 glMatrixMode(GL_PROJECTION);

 glLoadIdentity();
 glFrustum(-4.,4.,-4.,4., 10.,80.);

 glTranslatef(0.,0.,-45.);

 glutDisplayFunc(&malen);
 glutIdleFunc(&malen_anstossen);

 /* Menü hinzufügen */

 glutCreateMenu(ModeMenu);
 glutAddMenuEntry("Toggle Animation", ANIMATE);
 glutAddMenuEntry("Quit", QUIT);
 glutAttachMenu(GLUT_RIGHT_BUTTON);

 glutMainLoop();

 return(0);

}

void malen(void)
{

  glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glRotatef(winkel,1.0,1.0,1.0);

  /* Fraktal zeichnen */

  glCallList(DasFraktal);

  glFlush();
  glutSwapBuffers();
}

void malen_anstossen(void)
{

  /* Wir drehen das Ganze in 3 Achsen */

  if (Animate) {
    winkel = winkel + 1;
    if (winkel > 360.0)
       winkel = winkel - 360.0;
    glutPostRedisplay();
  }
}

void box(int x,int y,int r)

{
   /* Zeichnet einen Würfel mit Radius r an den Koordinaten x,y */

  glPushMatrix();

  glTranslatef(GLfloat(x),GLfloat(y),GLfloat(r));
  glutSolidCube(GLfloat(r));

  glPopMatrix();
}




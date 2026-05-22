/*  Kochsche Schneeflocke                                                                       */
/*  Norman Walter, Universität Stuttgart                                       */
/*  http://www.norman-interactive.com                                       */
/*  e-mail: walternn@rupert.informatik.uni-stuttgart.de   */

#include <stdio.h>
#include <time.h>
#include <math.h>
#include <GL/glut.h>

void malen(void);
void draw_lines(float X0, float Y0, float X1, float Y1);

int main(int argc, char **argv)
{
  glutInit(&argc, argv);

  glutInitDisplayMode(GLUT_SINGLE|GLUT_RGB);

  glutInitWindowSize(400,300);
  glutInitWindowPosition(100,100);
  glutCreateWindow("Kochsche Schneeflocke");
  glClearColor(0.0, 0.0, 0.0, 0.0);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(-200.0, 600.0, -150.0, 450.0, -1.0, 1.0);
  glutDisplayFunc(&malen);

  glutMainLoop();
  return(0);
}

void malen(void)
{
  /* Koordinaten für drei Punkte */

  float P1X = 0.0;
  float P1Y = 0.0;

  float P2X = 200;
  float P2Y = 200*sqrt(3.0);

  float P3X = 400.0;
  float P3Y = 0.0;

  glClear(GL_COLOR_BUFFER_BIT);

  /* Hier wird die Funktion draw_lines aufgerufen */
  /* Eingabefolge : X0, Y0, X1, Y1                */

  /* Wir zeichnen ein gleichseitiges Dreieck */

  draw_lines(P1X,P1Y,P2X,P2Y);
  draw_lines(P2X,P2Y,P3X,P3Y);
  draw_lines(P3X,P3Y,P1X,P1Y);

  glFlush();

}


void draw_lines(float X0, float Y0, float X1, float Y1)
{
  float AX = X0;
  float AY = Y0;

  float BX = (2.0*X0+X1)/3.0;
  float BY = (2.0*Y0+Y1)/3.0;

  float CX = (X0+X1)/2.0 - sqrt(3.0)/6.0*(Y1-Y0);
  float CY = (Y0+Y1)/2.0 + sqrt(3.0)/6.0*(X1-X0);

  float DX = (X0+2.0*X1)/3.0;
  float DY = (Y0+2.0*Y1)/3.0;

  float EX = X1;
  float EY = Y1;


  /* Es werden nur Linien der Länge < 4 gezeichnet */ 
  if (pow(X0-X1,2)+pow(Y0-Y1,2)<4.0)
  {
    glBegin(GL_LINES);
    glColor3f(1.0,1.0,1.0);
    glVertex2f(X0,Y0);
    glVertex2f(X1,Y1);
    glEnd();
  }

  else

  {
    /* Rekursive Funktionsaufrufe */
    draw_lines(AX,AY,BX,BY); // Linie von a nach b
    draw_lines(BX,BY,CX,CY); // Linie von b nach c
    draw_lines(CX,CY,DX,DY); // Linie von c nach d
    draw_lines(DX,DY,EX,EY); // Linie von d nach e 
  }

}

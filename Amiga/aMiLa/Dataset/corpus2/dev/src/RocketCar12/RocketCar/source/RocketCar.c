/*  RocketCar.c
 *  Drive a raytraced rocket car in a scalable window
 *  Author: Norman Walter
 *  e-mail: walternn@studi.informatik.uni-stuttgart.de
 *  www: http://www.norman-interactive.com
 *  Version 1.1
 *  Date: 29.3.2002
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <GL/glut.h>

/* SGI rgb texture loading routines by Brian Paul */
#ifndef AMIGA
#include "readtex.c"   /* I know, this is a hack. */
#else
GLboolean LoadRGBMipmaps( const char *, GLint );
#endif

#define POINT_FILTER 20
#define LINEAR_FILTER 21
#define RESET 30
#define ABOUT 40
#define QUIT 100

#define Texture "RocketCar.rgb"

#include "requesters.h"
#include "requesters.c"

/* 2.0 Version string for c:Version to find */
UBYTE vers[] = "\0$VER: RocketCar 1.1";

static GLuint Vehicle;

/* struct for coordinates and direction of the car */
struct car
  {
    GLfloat angle;
    GLfloat x;
    GLfloat y;
  };

struct car rocketcar;

static GLfloat DZrot = 5.0;
GLfloat speed = 0.0;
GLfloat zoom = -70.0;


static void Idle( void )
{
   /* proceed acording to actual speed and dircetion */
   rocketcar.y=sin(rocketcar.angle/180.*3.14)*speed+rocketcar.y; // Delta Y
   rocketcar.x=cos(rocketcar.angle/180.*3.14)*speed+rocketcar.x; // Delta X
   /* deaccelerate */
   if (speed > 0.0)
     speed = speed - 0.005;
   else if (speed < 0.0)
     speed = speed + 0.005;

   glutPostRedisplay();

}


static void Display( void )
{
   glClear( GL_COLOR_BUFFER_BIT | GLUT_DEPTH );

   glPushMatrix();

   glTranslatef(rocketcar.x,rocketcar.y,0.0);
   glRotatef(rocketcar.angle, 0.0, 0.0, 1.0);
   glScalef(5.0, 5.0, 5.0);

   glCallList(Vehicle);

   glPopMatrix();

   glFlush();
   glutSwapBuffers();
}


static void Reshape( int width, int height )
{
   glViewport( 0, 0, width, height );
   glMatrixMode( GL_PROJECTION );
   glLoadIdentity();
   glFrustum( -5.0, 5.0, -5.0, 5.0, 10.0, 100.0 );
   glMatrixMode( GL_MODELVIEW );
   glLoadIdentity();
   zoom = -70.0;
   glTranslatef( 0.0, 0.0,-70.0);
}

static void reset(void)
{
   /* Reset the car to starting position */
   rocketcar.x = 0.0;
   rocketcar.y = 0.0;
   rocketcar.angle = 0.0;
   speed = 0.0;
}


static void ModeMenu(int entry)
{
  if (entry==POINT_FILTER) {
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   }
   else if (entry==LINEAR_FILTER) {
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
   }
   else if (entry==RESET) {
      reset();
   }
   else if (entry==ABOUT) {
      ShowAbout();
   }
   else if (entry==QUIT) {
      AskQuit();
   }
   glutPostRedisplay();
}


static void Key( unsigned char key, int x, int y )
{
   switch (key) {
      case 27:
       AskQuit();
      break;
      case 'r':
       reset();
      break;
      case '+':
      /* zoom in */
       if (zoom < -10.0)
         {
           zoom = zoom + 1.0;
           glTranslatef(0.0,0.0,1.0);
           glutPostRedisplay();
         }
      break;
      case '-':
      /* zoom out */
       if (zoom > -100.0)
         {
           zoom = zoom - 1.0;
           glTranslatef(0.0,0.0,-1.0);
           glutPostRedisplay();
         }
      break;
   }
   glutPostRedisplay();
}


static void Init( void )
{

   GLUquadricObj *q = gluNewQuadric();
   Vehicle = glGenLists(1);

   glNewList(Vehicle, GL_COMPILE);

   /* Vehicle */
   gluQuadricNormals(q, GL_SMOOTH);
   gluQuadricTexture(q, GL_TRUE);

   glBegin( GL_POLYGON );

   glTexCoord2f( 1.0, 0.0 );   glVertex2f( -1.0, -1.0 );
   glTexCoord2f( 1.0, 1.0 );   glVertex2f(  1.0, -1.0 );
   glTexCoord2f( 0.0, 1.0 );   glVertex2f(  1.0,  1.0 );
   glTexCoord2f( 0.0, 0.0 );   glVertex2f( -1.0,  1.0 );

   glEnd();

   glEndList();

   gluDeleteQuadric(q);

   /* fitering = nearest, initially */
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

   glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
   glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);

   glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
   glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);

   if (!LoadRGBMipmaps(Texture, GL_RGB)) {
     ShowError();
           exit(1);
   }

   glEnable(GL_CULL_FACE);

   glEnable(GL_TEXTURE_2D);

}


static void SpecialKey( int key, int x, int y )
{
   switch (key) {
      case GLUT_KEY_UP:
      speed = speed + 0.05; // acceleration
         break;
      case GLUT_KEY_DOWN:
      speed = speed - 0.05; // deacceleration
         break;
      case GLUT_KEY_LEFT:
      rocketcar.angle = rocketcar.angle + DZrot; // spin left
         break;
      case GLUT_KEY_RIGHT:
      rocketcar.angle = rocketcar.angle - DZrot; // spin right
         break;
   }

   glutPostRedisplay();
}

int main( int argc, char *argv[] )
{

   glutInit( &argc, argv );
   glutInitWindowSize( 400, 300 );

   glutInitDisplayMode( GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);

   glutCreateWindow(argv[0] );
   glClearColor(0.0,0.0,0.0,0.0);
   Init();

   glutReshapeFunc( Reshape );
   glutKeyboardFunc( Key );
   glutDisplayFunc( Display );
   glutSpecialFunc( SpecialKey );

   glutIdleFunc( Idle );

   glutCreateMenu(ModeMenu);
   glutAddMenuEntry("Point Filtered", POINT_FILTER);
   glutAddMenuEntry("Linear Filtered", LINEAR_FILTER);
   glutAddMenuEntry("Reset", RESET);
   glutAddMenuEntry("About", ABOUT);
   glutAddMenuEntry("Quit", QUIT);
   glutAttachMenu(GLUT_RIGHT_BUTTON);

   glutMainLoop();

   return 0;
}

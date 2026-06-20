/*  Colliding_Stars.c
 *  Shows 3-dimensional collision detection using "Bounding Spheres" apporach.
 *  That means we use invisible spheres arround the objects for
 *  collision detection.
 *  This is a simple but imprecise method.
 *  Nevertheless it is used in many computer- and videogames.
 *  Author: Norman Walter
 *  e-mail: walternn@studi.informatik.uni-stuttgart.de
 *  www: http://www.norman-interactive.com
 *  Date: 11.4.2002
 */


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <GL/glut.h>

#define Texture "Sky.rgb"

#include "requesters.h"
#include "requesters.c"

/* 2.0 Version string for c:Version to find */
UBYTE vers[] = "\0$VER: Colliding Stars 1.0";

/* SGI rgb texture loading routines by Brian Paul */
#ifndef AMIGA
#include "../util/readtex.c"   /* I know, this is a hack. */
#else
GLboolean LoadRGBMipmaps( const char *, GLint );
#endif

#define ANIMATE 10
#define POINT_FILTER 20
#define LINEAR_FILTER 21
#define ABOUT 40
#define QUIT 100

static GLuint Star;

static GLboolean Animate = GL_TRUE;

static GLfloat Drot = 1.0;

/* struct for coordinates of the Star */
struct Position
  {
    GLfloat x;
    GLfloat y;
    GLfloat z;
    GLfloat xmov;
    GLfloat ymov;
    GLfloat zmov;
    GLfloat spin;
    GLfloat BSradius; // Bounding Sphere radius
  };

struct Position StarPos;
struct Position StarPos2;

/* struct for a 3-dimensional area */
struct Zone
  {
    float x1;
    float y1;
    float z1;
    float x2;
    float y2;
    float z2;
  };

struct Zone WinBorder;

static void Idle( void )
{
   float d;

   if (Animate) {
     StarPos.spin += Drot;
     StarPos.x += StarPos.xmov;
     StarPos.y += StarPos.ymov;
     StarPos.z += StarPos.zmov;
     StarPos2.spin += Drot;
     StarPos2.x += StarPos2.xmov;
     StarPos2.y += StarPos2.ymov;
     StarPos2.z += StarPos2.zmov;

      if (StarPos.spin > 360.0)
        {
            StarPos.spin = 0.0;
        }
      if (StarPos2.spin > 360.0)
        {
            StarPos2.spin = 0.0;
        }
      /* Check for borders */
      if (StarPos.x > WinBorder.x1 || StarPos.x < WinBorder.x2 )
        {
            StarPos.xmov = StarPos.xmov * (-1.0);  // Reverse direction
        }
      else if (StarPos.y > WinBorder.y1 || StarPos.y < WinBorder.y2)
        {
            StarPos.ymov = StarPos.ymov * (-1.0);  // Reverse direction
        }
      else if (StarPos.z > WinBorder.z1 || StarPos.z < WinBorder.z2)
        {
            StarPos.zmov = StarPos.zmov * (-1.0);  // Reverse direction
        }
      /* Check for borders */
      if (StarPos2.x > WinBorder.x1 || StarPos2.x < WinBorder.x2 )
        {
            StarPos2.xmov = StarPos2.xmov * (-1.0);  // Reverse direction
        }
      else if (StarPos2.y > WinBorder.y1 || StarPos2.y < WinBorder.y2)
        {
            StarPos2.ymov = StarPos2.ymov * (-1.0);  // Reverse direction
        }
      else if (StarPos2.z > WinBorder.z1 || StarPos2.z < WinBorder.z2)
        {
            StarPos2.zmov = StarPos2.zmov * (-1.0);  // Reverse direction
        }
      /* Collision detection */

      // calculate the distance between the 2 Bounding Spheres
      d=(fabs (sqrt(pow((StarPos2.x-StarPos.x),2)
                   +pow((StarPos2.y-StarPos.y),2)
                   +pow((StarPos2.z-StarPos.z),2))));
      // if the distance is less than the two radii together, we have a collision
      if (d < (StarPos.BSradius+StarPos2.BSradius))
        {
           StarPos.xmov = StarPos.xmov * (-1.0);
           StarPos.ymov = StarPos.ymov * (-1.0);
           StarPos.zmov = StarPos.zmov * (-1.0);
           StarPos2.xmov = StarPos2.xmov * (-1.0);
           StarPos2.ymov = StarPos2.ymov * (-1.0);
           StarPos2.zmov = StarPos2.zmov * (-1.0);
        }
      glutPostRedisplay();
   }
}


static void Display( void )
{
   glClear( GL_COLOR_BUFFER_BIT | GLUT_DEPTH );

   glPushMatrix();

   /* Move the Star */
   glTranslatef(StarPos.x,StarPos.y,StarPos.z);
   /* Rotate it */
   glRotatef(StarPos.spin, 1.0, 0.0, 0.0);
   glRotatef(StarPos.spin, 0.0, 1.0, 0.0);
   glRotatef(StarPos.spin, 0.0, 0.0, 1.0);

   glScalef(10.0, 10.0, 10.0);

   glCallList(Star);

   glPopMatrix();

   glPushMatrix();

   /* Move the Star */
   glTranslatef(StarPos2.x,StarPos2.y,StarPos2.z);
   /* Rotate it */
   glRotatef(StarPos2.spin, 1.0, 0.0, 0.0);
   glRotatef(StarPos2.spin, 0.0, 1.0, 0.0);
   glRotatef(StarPos2.spin, 0.0, 0.0, 1.0);

   glScalef(10.0, 10.0, 10.0);

   glCallList(Star);

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
   glTranslatef( 0.0, 0.0, -70.0 );
}


static void ModeMenu(int entry)
{
   if (entry==ANIMATE) {
      Animate = !Animate;
   }
   else if (entry==POINT_FILTER) {
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   }
   else if (entry==LINEAR_FILTER) {
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
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
   }
   glutPostRedisplay();
}


static void Init( void )
{

   GLUquadricObj *q = gluNewQuadric();
   Star = glGenLists(1);

   glNewList(Star, GL_COMPILE);

     /* Star */
     gluQuadricNormals(q, GL_SMOOTH);
     gluQuadricTexture(q, GL_TRUE);


        glBegin(GL_TRIANGLES);

        // front face

        // Important: count clockwise!

            // Polygon 1
            glVertex3f(0.00049,1.02,0.0);
            glVertex3f(0.31,0.394,0.0);
            glVertex3f(0.00049,0.0,-0.25);

            // Polygon 2
            glVertex3f(0.31,0.394,0.0);
            glVertex3f(1.0,0.294,0.0);
            glVertex3f(0.00049,0.0,-0.25);

            // Polygon 3
            glVertex3f(1.0,0.294,0.0);
            glVertex3f(0.5,-0.193,0.0);
            glVertex3f(0.00049,0.0,-0.25);

            // Polygon 4
            glVertex3f(0.5,-0.193,0.0);
            glVertex3f(0.618,-0.882,0.0);
            glVertex3f(0.00049,0.0,-0.25);

            // Polygon 5
            glVertex3f(0.618,-0.882,0.0);
            glVertex3f(0.00049,-0.557,0.0);
            glVertex3f(0.00049,0.0,-0.25);

            // Polygon 6
            glVertex3f(0.00049,-0.557,0.0);
            glVertex3f(-0.618,-0.882,0.0);
            glVertex3f(0.00049,0.0,-0.25);

            // Polygon 7
            glVertex3f(-0.618,-0.882,0.0);
            glVertex3f(-0.5,-0.193,0.0);
            glVertex3f(0.00049,0.0,-0.25);

            // Polygon 8
            glVertex3f(-0.5,-0.193,0.0);
            glVertex3f(-1.0,0.294,0.0);
            glVertex3f(0.00049,0.0,-0.25);

            // Polygon 9
            glVertex3f(-1.0,0.294,0.0);
            glVertex3f(-0.31,0.394,0.0);
            glVertex3f(0.00049,0.0,-0.25);

            // Polygon 10
            glVertex3f(-0.31,0.394,0.0);
            glVertex3f(0.00049,1.02,0.0);
            glVertex3f(0.00049,0.0,-0.25);


        // back face

        // Important: count anticlockwise for backface culling!

            // Polygon 1
            glVertex3f(0.00049,1.02,0.0);
            glVertex3f(0.00049,0.0,0.25);
            glVertex3f(0.31,0.394,0.0);

            // Polygon 2
            glVertex3f(0.31,0.394,0.0);
            glVertex3f(0.00049,0.0,0.25);
            glVertex3f(1.0,0.294,0.0);

            // Polygon 3
            glVertex3f(1.0,0.294,0.0);
            glVertex3f(0.00049,0.0,0.25);
            glVertex3f(0.5,-0.193,0.0);

            // Polygon 4
            glVertex3f(0.5,-0.193,0.0);
            glVertex3f(0.00049,0.0,0.25);
            glVertex3f(0.618,-0.882,0.0);

            // Polygon 5
            glVertex3f(0.618,-0.882,0.0);
            glVertex3f(0.00049,0.0,0.25);
            glVertex3f(0.00049,-0.557,0.0);

            // Polygon 6
            glVertex3f(0.00049,-0.557,0.0);
            glVertex3f(0.00049,0.0,0.25);
            glVertex3f(-0.618,-0.882,0.0);

            // Polygon 7
            glVertex3f(-0.618,-0.882,0.0);
            glVertex3f(0.00049,0.0,0.25);
            glVertex3f(-0.5,-0.193,0.0);

            // Polygon 8
            glVertex3f(-0.5,-0.193,0.0);
            glVertex3f(0.00049,0.0,0.25);
            glVertex3f(-1.0,0.294,0.0);

            // Polygon 9
            glVertex3f(-1.0,0.294,0.0);
            glVertex3f(0.00049,0.0,0.25);
            glVertex3f(-0.31,0.394,0.0);

            // Polygon 10
            glVertex3f(-0.31,0.394,0.0);
            glVertex3f(0.00049,0.0,0.25);
            glVertex3f(0.00049,1.02,0.0);

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
      ShowError();  // display error requester
      exit(1);
   }

   glEnable(GL_CULL_FACE);  // enable backface culling

   glEnable(GL_TEXTURE_2D);
   glEnable(GL_TEXTURE_GEN_S);
   glEnable(GL_TEXTURE_GEN_T);

}


int main( int argc, char *argv[] )
{
   /* Give the Star its initial position and speed */
   StarPos.x = -10.0;
   StarPos.y = -10.0;
   StarPos.z = -10.0;
   /* movement vectors - units to move per step */
   StarPos.xmov = 0.35;
   StarPos.ymov = 0.15;
   StarPos.zmov = 0.0;
   /* Bounding Sphere's radius */
   StarPos.BSradius = 10.0;
   /* Initial spin */
   StarPos.spin = 1.0;

   /* Give the Star its initial position and speed */
   StarPos2.x = 10.0;
   StarPos2.y = 10.0;
   StarPos2.z = 10.0;
   /* movement vectors - units to move per step */
   StarPos2.xmov = -0.125;
   StarPos2.ymov = -0.25;
   StarPos2.zmov = 0.0;
   /* Bounding Sphere's radius */
   StarPos.BSradius = 10.0;
   /* Initial spin */
   StarPos.spin = 1.5;

   /* Define the bouncing shape */
   WinBorder.x1 =  30.0;
   WinBorder.y1 =  30.0;
   WinBorder.z1 =  15.0;
   WinBorder.x2 = -30.0;
   WinBorder.y2 = -30.0;
   WinBorder.z2 = -15.0;

   glutInit( &argc, argv );
   glutInitWindowSize( 300, 300 );

   glutInitDisplayMode( GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);

   glutCreateWindow(argv[0] );

   /* Define clear color */
   glClearColor(0.0,0.0,0.0,0.0);

   Init();

   glutReshapeFunc( Reshape );
   glutKeyboardFunc( Key );
   glutDisplayFunc( Display );
   glutIdleFunc( Idle );

   glutCreateMenu(ModeMenu);
   glutAddMenuEntry("Point Filtered", POINT_FILTER);
   glutAddMenuEntry("Linear Filtered", LINEAR_FILTER);
   glutAddMenuEntry("Toggle Animation", ANIMATE);
   glutAddMenuEntry("About", ABOUT);
   glutAddMenuEntry("Quit", QUIT);
   glutAttachMenu(GLUT_RIGHT_BUTTON);

   glutMainLoop();
   return 0;
}

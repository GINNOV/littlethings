/*  Textured_Cube.c
 *  Rotating and bouncing textured cube
 *  Author: Norman Walter
 *  e-mail: walternn@studi.informatik.uni-stuttgart.de
 *  www: http://www.norman-interactive.com
 *  Date: 10.4.2002
 */


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <GL/glut.h>

#define Texture "Toast.rgb"

#include "requesters.h"
#include "requesters.c"

/* 2.0 Version string for c:Version to find */
UBYTE vers[] = "\0$VER: Bouncing Cube 1.0";

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

static GLuint Cube;

static GLboolean Animate = GL_TRUE;

GLfloat rot = 0.0;
static GLfloat Drot = 1.0;

/* struct for coordinates of the Cube */
struct Position
  {
    GLfloat x;
    GLfloat y;
    GLfloat xmov;
    GLfloat ymov;
  };

struct Position CubePos;

/* struct for a 2-dimensional area */
struct Zone
  {
    float x1;
    float y1;
    float x2;
    float y2;
  };

struct Zone WinBorder;

static void Idle( void )
{
   if (Animate) {
     rot += Drot;
     CubePos.x += CubePos.xmov;
     CubePos.y += CubePos.ymov;
      if (rot > 360.0)
        {
            rot -= 0.0;
        }
      /* Check for borders */
      if (CubePos.x > WinBorder.x1 || CubePos.x < WinBorder.x2 )
        {
            CubePos.xmov = CubePos.xmov * (-1.0);  // Reverse direction
        }
      if (CubePos.y > WinBorder.y1 || CubePos.y < WinBorder.y2)
        {
            CubePos.ymov = CubePos.ymov * (-1.0);  // Reverse direction
        }
      glutPostRedisplay();
   }
}


static void Display( void )
{
   glClear( GL_COLOR_BUFFER_BIT | GLUT_DEPTH );

   glPushMatrix();

   /* Move the cube */
   glTranslatef(CubePos.x,CubePos.y,0.0);
   /* Rotate it */
   glRotatef(rot, 1.0, 0.0, 0.0);
   glRotatef(rot, 0.0, 1.0, 0.0);
   glRotatef(rot, 0.0, 0.0, 1.0);

   glScalef(20.0, 20.0, 20.0);

   glCallList(Cube);

   glPopMatrix();

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
   Cube = glGenLists(1);

   glNewList(Cube, GL_COMPILE);

     /* Cube */
     gluQuadricNormals(q, GL_SMOOTH);
     gluQuadricTexture(q, GL_TRUE);


        glBegin(GL_QUADS);  // top face
            glTexCoord2f(0.0f, 0.0f); glVertex3f(-0.5f, 0.5f, 0.5f);
            glTexCoord2f(1.0f, 0.0f); glVertex3f(0.5f, 0.5f, 0.5f);
            glTexCoord2f(1.0f, 1.0f); glVertex3f(0.5f, 0.5f, -0.5f);
            glTexCoord2f(0.0f, 1.0f); glVertex3f(-0.5f, 0.5f, -0.5f);
        glEnd();

        glBegin(GL_QUADS);  // front face
            glTexCoord2f(0.0f, 0.0f); glVertex3f(0.5f, -0.5f, 0.5f);
            glTexCoord2f(1.0f, 0.0f); glVertex3f(0.5f, 0.5f, 0.5f);
            glTexCoord2f(1.0f, 1.0f); glVertex3f(-0.5f, 0.5f, 0.5f);
            glTexCoord2f(0.0f, 1.0f); glVertex3f(-0.5f, -0.5f, 0.5f);
        glEnd();

        glBegin(GL_QUADS);  // right face
            glTexCoord2f(0.0f, 0.0f); glVertex3f(0.5f, 0.5f, -0.5f);
            glTexCoord2f(1.0f, 0.0f); glVertex3f(0.5f, 0.5f, 0.5f);
            glTexCoord2f(1.0f, 1.0f); glVertex3f(0.5f, -0.5f, 0.5f);
            glTexCoord2f(0.0f, 1.0f); glVertex3f(0.5f, -0.5f, -0.5f);
        glEnd();

        glBegin(GL_QUADS);  // left face
            glTexCoord2f(0.0f, 0.0f); glVertex3f(-0.5f, -0.5f, 0.5f);
            glTexCoord2f(1.0f, 0.0f); glVertex3f(-0.5f, 0.5f, 0.5f);
            glTexCoord2f(1.0f, 1.0f); glVertex3f(-0.5f, 0.5f, -0.5f);
            glTexCoord2f(0.0f, 1.0f); glVertex3f(-0.5f, -0.5f, -0.5f);
        glEnd();

        glBegin(GL_QUADS);  // bottom face
            glTexCoord2f(0.0f, 0.0f); glVertex3f(0.5f, -0.5f, 0.5f);
            glTexCoord2f(1.0f, 0.0f); glVertex3f(-0.5f, -0.5f, 0.5f);
            glTexCoord2f(1.0f, 1.0f); glVertex3f(-0.5f, -0.5f, -0.5f);
            glTexCoord2f(0.0f, 1.0f); glVertex3f(0.5f, -0.5f, -0.5f);
        glEnd();

        glBegin(GL_QUADS);  // back face
            glTexCoord2f(0.0f, 0.0f); glVertex3f(0.5f, 0.5f, -0.5f);
            glTexCoord2f(1.0f, 0.0f); glVertex3f(0.5f, -0.5f, -0.5f);
            glTexCoord2f(1.0f, 1.0f); glVertex3f(-0.5f, -0.5f, -0.5f);
            glTexCoord2f(0.0f, 1.0f); glVertex3f(-0.5f, 0.5f, -0.5f);
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

   glEnable(GL_CULL_FACE);

   glEnable(GL_TEXTURE_2D);

}


int main( int argc, char *argv[] )
{
   /* Give the cube its initial position and speed */
   CubePos.x = 1.0;
   CubePos.y = 1.0;
   /* movement vectors - units to move per step */
   CubePos.xmov = 0.25;
   CubePos.ymov = 0.125;

   /* Define the bouncing shape */
   WinBorder.x1 =  20.0;
   WinBorder.y1 =  20.0;
   WinBorder.x2 = -20.0;
   WinBorder.y2 = -20.0;

   glutInit( &argc, argv );
   glutInitWindowSize( 300, 300 );

   glutInitDisplayMode( GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);

   glutCreateWindow(argv[0] );

   /* Define clear color */
   glClearColor(0.59,0.46,0.0,0.0);

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

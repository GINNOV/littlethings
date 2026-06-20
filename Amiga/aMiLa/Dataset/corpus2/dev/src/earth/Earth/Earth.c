/*  Earth.c
 *  A little bit different "Hello, World!" program ;-)
 *  Author: Norman Walter
 *  e-mail: walternn@studi.informatik.uni-stuttgart.de
 *  www: http://www.norman-interactive.com
 *  Date: 22.3.2002
 */


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <GL/glut.h>

/* SGI rgb texture loading routines by Brian Paul */
#ifndef AMIGA
#include "../util/readtex.c"   /* I know, this is a hack. */
#else
GLboolean LoadRGBMipmaps( const char *, GLint );
#endif

#define ANIMATE 10
#define POINT_FILTER 20
#define LINEAR_FILTER 21
#define QUIT 100

static GLuint Globe;

static GLboolean Animate = GL_TRUE;

static GLfloat Xrot = -66.55, Yrot = -23.45, Zrot = 0.0;
static DZrot = 1.0;


static void Idle( void )
{
   if (Animate) {
     Zrot += DZrot;
      if (Zrot > 360.0)
        {
            Zrot -= 360.0;
        }
      glutPostRedisplay();
   }
}


static void Display( void )
{
   glClear( GL_COLOR_BUFFER_BIT | GLUT_DEPTH );

   glPushMatrix();

   glRotatef(Xrot, 1.0, 0.0, 0.0);
   glRotatef(Yrot, 0.0, 1.0, 0.0);
   glRotatef(Zrot, 0.0, 0.0, 1.0);
   glScalef(5.0, 5.0, 5.0);

   glCallList(Globe);

   glPopMatrix();

   glutSwapBuffers();
}


static void Reshape( int width, int height )
{
   glViewport( 0, 0, width, height );
   glMatrixMode( GL_PROJECTION );
   glLoadIdentity();
   glFrustum( -1.0, 1.0, -1.0, 1.0, 10.0, 100.0 );
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
   else if (entry==QUIT) {
      exit(0);
   }
   glutPostRedisplay();
}


static void Key( unsigned char key, int x, int y )
{
   switch (key) {
      case 27:
     exit(0);
     break;
   }
   glutPostRedisplay();
}


static void Init( void )
{

   GLUquadricObj *q = gluNewQuadric();
   Globe = glGenLists(1);

   glNewList(Globe, GL_COMPILE);

     /* globe */
     gluQuadricNormals(q, GL_SMOOTH);
     gluQuadricTexture(q, GL_TRUE);

     gluSphere (q, 1.0, 15, 15);

   glEndList();

   gluDeleteQuadric(q);

   /* fitering = nearest, initially */
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

   glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
   glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);

   glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
   glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);

   if (!LoadRGBMipmaps("earth_small.rgb", GL_RGB)) {
      printf("Error: couldn't load texture image\n");
      exit(1);
   }

   glEnable(GL_CULL_FACE);

   glEnable(GL_TEXTURE_2D);

}


int main( int argc, char *argv[] )
{
   glutInit( &argc, argv );
   glutInitWindowSize( 200, 200 );

   glutInitDisplayMode( GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);

   glutCreateWindow(argv[0] );

   Init();

   glutReshapeFunc( Reshape );
   glutKeyboardFunc( Key );
   glutDisplayFunc( Display );
   glutIdleFunc( Idle );

   glutCreateMenu(ModeMenu);
   glutAddMenuEntry("Point Filtered", POINT_FILTER);
   glutAddMenuEntry("Linear Filtered", LINEAR_FILTER);
   glutAddMenuEntry("Toggle Animation", ANIMATE);
   glutAddMenuEntry("Quit", QUIT);
   glutAttachMenu(GLUT_RIGHT_BUTTON);

   glutMainLoop();
   return 0;
}

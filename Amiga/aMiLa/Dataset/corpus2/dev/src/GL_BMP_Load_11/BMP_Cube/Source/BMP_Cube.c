/*  BMP_Cube.c
 *  Rotating textured cube
 *  Demonstrates using of BMP Texture Loader routines
 *  Author: Norman Walter
 *  e-mail: walternn@studi.informatik.uni-stuttgart.de
 *  www: http://www.norman-interactive.com
 *  Date: 9.6.2003
 *
 *  DISCLAIMER: This software is provided "as is".  No representations or
 *  warranties are made with respect to the accuracy, reliability, performance,
 *  currentness, or operation of this software, and all use is at your own risk.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream.h>
#include <string.h>
#include <GL/glut.h>

/* AmigaOS includes */
#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <graphics/gfx.h>
#include <graphics/text.h>
#include <graphics/rastport.h>
#include <libraries/gadtools.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/gadtools_protos.h>

/* Our includes */

#include "bmp.h"
#include "bmp.c"

#include "Requesters.h"
#include "Requesters.c"

#include "Textstuff.h"
#include "Textstuff.cpp"

#include "Bar.h"
#include "Bar.cpp"

/* 2.0 Version string for c:Version to find */
UBYTE vers[] = "\0$VER: BMP Cube 1.1";

/* Global Variables */

GLfloat angle = 0.0;  // angle for rotation
static GLboolean Anim = GL_TRUE;

/* Amiga OS Stuff */

struct Library *DosBase = NULL;
//struct Library *IntuitionBase = NULL;
struct Library *GfxBase = NULL;
struct Library *GadToolsBase = NULL;
struct Screen *Myscreen = NULL;
struct Window *Mywindow = NULL;
struct IntuiMessage *msg = NULL;
struct RastPort *MyRastPort = NULL;
struct TextAttr *MyTextAttr = NULL;

/* Width and Height of the Progresswindow */

#define PRGWINWIDTH 250
#define PRGWINHEIGHT 80

/* Variables for GLUT menu */

#define ANIMATE 10
#define POINT_FILTER 20
#define LINEAR_FILTER 21
#define ABOUT 40
#define QUIT 100

/* Texture Information */

#define TEXTURE1 "data/Cover1.bmp"
#define TEXTURE2 "data/Cover2.bmp"
#define TEXTURE3 "data/Cover3.bmp"
#define TEXTURE4 "data/Cover4.bmp"

BITMAPINFOHEADER	Cover1Info;			// Cover1 texture info header
BITMAPINFOHEADER	Cover2Info;			// Cover2 texture info header
BITMAPINFOHEADER	Cover3Info;			// Cover3 texture info header
BITMAPINFOHEADER	Cover4Info;			// Cover4 texture info header

unsigned char*    Cover1Texture;	// Cover1 texture data
unsigned char*		Cover2Texture;	// Cover2 texture data
unsigned char*		Cover3Texture;	// Cover3 texture data
unsigned char*		Cover4Texture;	// Cover4 texture data

unsigned int		Cover1;        // the Cover1 texture object
unsigned int		Cover2;			// the Cover2 texture object
unsigned int		Cover3;			// the Cover3 texture object
unsigned int		Cover4;			// the Cover4 texture object

/* Variable for display list */
static GLuint Cube;

void close_all(void)
{
  if (GfxBase)
  {
    CloseLibrary(GfxBase);
    GfxBase = NULL;
  } // if

  if (IntuitionBase)
  {
    CloseLibrary(IntuitionBase);
    IntuitionBase = NULL;
  } // if

  if (DosBase)
  {
    CloseLibrary(DosBase);
    DosBase = NULL;
  } // if

  if (GadToolsBase)
  {
    CloseLibrary(GadToolsBase);
    GadToolsBase = NULL;
  } // if

	Exit(TRUE);
}

void open_libs(void)
{
	IntuitionBase = OpenLibrary("intuition.library",39L);
		if (IntuitionBase == NULL)
		 {
		    cerr << "Unable to open intuition.library v 39\n";
		    Exit(FALSE);
		 }

		DosBase = OpenLibrary("dos.library",39L);
		if (DosBase == NULL)
		 {
			 cerr << "Unable to open dos.library v 39\n";
          close_all();
          Exit(FALSE);
		 }

		GfxBase = OpenLibrary("graphics.library",39L);
		if (GfxBase == NULL)
		 {
			 cerr << "Unable to open graphics.library v 39\n";
          close_all();
          Exit(FALSE);
		 }

		GadToolsBase = OpenLibrary("gadtools.library", 39L);
	   if (GfxBase == NULL)
		 {
			 cerr << "Unable to open gadtools.library v 39\n";
          close_all();
          Exit(FALSE);
		 }
}

/* Put a Cube object into the display list */
static void Init_Cube(void)
{
   Cube = glGenLists(1);

   glNewList(Cube, GL_COMPILE);

     /* Cube */

     glBindTexture(GL_TEXTURE_2D, Cover1);

        glBegin(GL_QUADS);  // top face
            glTexCoord2f(0.0f, 0.0f); glVertex3f(-0.5f, 0.5f, 0.5f);
            glTexCoord2f(1.0f, 0.0f); glVertex3f(0.5f, 0.5f, 0.5f);
            glTexCoord2f(1.0f, 1.0f); glVertex3f(0.5f, 0.5f, -0.5f);
            glTexCoord2f(0.0f, 1.0f); glVertex3f(-0.5f, 0.5f, -0.5f);
        glEnd();

     glBindTexture(GL_TEXTURE_2D, Cover2);

        glBegin(GL_QUADS);  // front face
            glTexCoord2f(0.0f, 0.0f); glVertex3f(0.5f, -0.5f, 0.5f);
            glTexCoord2f(1.0f, 0.0f); glVertex3f(0.5f, 0.5f, 0.5f);
            glTexCoord2f(1.0f, 1.0f); glVertex3f(-0.5f, 0.5f, 0.5f);
            glTexCoord2f(0.0f, 1.0f); glVertex3f(-0.5f, -0.5f, 0.5f);
        glEnd();

     glBindTexture(GL_TEXTURE_2D, Cover3);

        glBegin(GL_QUADS);  // right face
            glTexCoord2f(0.0f, 0.0f); glVertex3f(0.5f, 0.5f, -0.5f);
            glTexCoord2f(1.0f, 0.0f); glVertex3f(0.5f, 0.5f, 0.5f);
            glTexCoord2f(1.0f, 1.0f); glVertex3f(0.5f, -0.5f, 0.5f);
            glTexCoord2f(0.0f, 1.0f); glVertex3f(0.5f, -0.5f, -0.5f);
        glEnd();

     glBindTexture(GL_TEXTURE_2D, Cover4);

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

}

/* Load and init texture */

BOOL LoadTextures()
{

   // activate Screen Lock

   if (Myscreen = LockPubScreen(NULL))
   {
      // Open Progress Window
      Mywindow = OpenWindowTags(NULL, WA_Left,          Myscreen->Width/2-PRGWINWIDTH/2,
                                      WA_Top,           Myscreen->Height/2-PRGWINHEIGHT/2,
                                      WA_Height,        PRGWINHEIGHT,
                                      WA_Width,         PRGWINWIDTH,
                                      WA_Title,         "Loading...",
                                      WA_IDCMP,         IDCMP_MOUSEMOVE,
                                      WA_Flags,         WFLG_DRAGBAR | WFLG_DEPTHGADGET |
                                                        WFLG_GIMMEZEROZERO | WFLG_ACTIVATE ,
                                      WA_Gadgets,       NULL,
                                      WA_PubScreen,     Myscreen,
                                      TAG_DONE);

    // remove Screen Lock
    UnlockPubScreen(NULL, Myscreen);

    }

    // get VisualInfo from screen
    vi = GetVisualInfo(Myscreen,TAG_DONE);

    // get font data from screen
    MyTextAttr = Myscreen->Font;

    // set Mousepointer to "busy"
    SetWindowPointer(Mywindow,
                     WA_BusyPointer,  TRUE,
                     WA_PointerDelay, TRUE,
                     TAG_DONE);

    MyRastPort = Mywindow->RPort;

    // open font. See definition in TextStuff.h
    MyTextFont = OpenFont(Myscreen->Font);

    struct TextFont *OldTextFont = Mywindow->RPort->Font; // store old font
    SetFont(Mywindow->RPort, MyTextFont);                 // set font to new one

    char *label;     // String for Fillbar
    char *Wintitle;  // Title of Progresswindow

    // Set text alignment
    // See definitions in Textstuff.h.
    align =  CENTER;
    valign = MIDDLE;

    cellpadding = 3;

    // Rectangular sturcture for the Fillbar and BBox frame
    Rectangle PBar = {20,  // MinX : left, upper corner X
                      10,  // MinY : left, upper corner Y
                      200, // MaxX : width
                      MyTextFont->tf_YSize+cellpadding*2}; // MaxY : height

   draw_progressbar(MyRastPort, PBar.MinX, PBar.MinY, PBar.MaxX, PBar.MaxY, 0);

   SetAPen(MyRastPort, 2L);
   SetDrMd(MyRastPort, JAM1);

   // formatted string output
   sprintf(label,"%d%%",0);
   sprintf(Wintitle,"Loading %s",TEXTURE1);

   // uses routines from TextStuff.cpp
   PlaceText(MyRastPort, label, PBar);

   SetWindowTitles(Mywindow, Wintitle , 0);

	// load the Cover1 texture data
	Cover1Texture = LoadBMP(TEXTURE1, &Cover1Info);
	if (!Cover1Texture)
		return FALSE;

	// generate the Cover1 texture as a mipmap
	glGenTextures(1, &Cover1);
	glBindTexture(GL_TEXTURE_2D, Cover1);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, Cover1Info.biWidth, Cover1Info.biHeight, GL_RGB, GL_UNSIGNED_BYTE, Cover1Texture);

         draw_progressbar(MyRastPort, PBar.MinX, PBar.MinY, PBar.MaxX, PBar.MaxY, 25);

         SetAPen(MyRastPort, 2L);
         SetDrMd(MyRastPort, JAM1);

         sprintf(label,"%d%%",25);
         sprintf(Wintitle,"Loading %s",TEXTURE2);

         PlaceText(MyRastPort, label, PBar);

   SetWindowTitles(Mywindow, Wintitle , 0);

	// load the Cover2 texture data
	Cover2Texture = LoadBMP(TEXTURE2, &Cover2Info);
	if (!Cover2Texture)
		return FALSE;

	// generate the Cover2 texture as a mipmap
	glGenTextures(1, &Cover2);
	glBindTexture(GL_TEXTURE_2D, Cover2);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, Cover2Info.biWidth, Cover2Info.biHeight, GL_RGB, GL_UNSIGNED_BYTE, Cover2Texture);

		   draw_progressbar(MyRastPort, PBar.MinX, PBar.MinY, PBar.MaxX, PBar.MaxY, 50);

         SetAPen(MyRastPort, 2L);
         SetDrMd(MyRastPort, JAM1);

         sprintf(label,"%d%%",50);
         sprintf(Wintitle,"Loading %s",TEXTURE3);

         PlaceText(MyRastPort, label, PBar);

   SetWindowTitles(Mywindow, Wintitle , 0);

	// load the Cover3 texture data
	Cover3Texture = LoadBMP(TEXTURE3, &Cover3Info);
	if (!Cover3Texture)
		return FALSE;

	// generate the Cover3 texture as a mipmap
	glGenTextures(1, &Cover3);
	glBindTexture(GL_TEXTURE_2D, Cover3);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, Cover3Info.biWidth, Cover3Info.biHeight, GL_RGB, GL_UNSIGNED_BYTE, Cover3Texture);

		    draw_progressbar(MyRastPort, PBar.MinX, PBar.MinY, PBar.MaxX, PBar.MaxY, 75);

         SetAPen(MyRastPort, 2L);
         SetDrMd(MyRastPort, JAM1);

         sprintf(label,"%d%%",75);
         sprintf(Wintitle,"Loading %s",TEXTURE4);

         PlaceText(MyRastPort, label, PBar);

   SetWindowTitles(Mywindow, Wintitle , 0);

	// load the Cover4 texture data
	Cover4Texture = LoadBMP(TEXTURE4, &Cover4Info);
	if (!Cover4Texture)
		return FALSE;

	// generate the Cover4 texture as a mipmap
	glGenTextures(1, &Cover4);
	glBindTexture(GL_TEXTURE_2D, Cover4);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, Cover4Info.biWidth, Cover4Info.biHeight, GL_RGB, GL_UNSIGNED_BYTE, Cover4Texture);

		   draw_progressbar(MyRastPort, PBar.MinX, PBar.MinY, PBar.MaxX, PBar.MaxY, 100);

         SetAPen(MyRastPort, 2L);
         SetDrMd(MyRastPort, JAM1);

         sprintf(label,"%d%%",100);

         PlaceText(MyRastPort, label, PBar);

    SetFont(Mywindow->RPort, OldTextFont);
    CloseFont(MyTextFont);

    // set Mousepointer to "normal"
    SetWindowPointer(Mywindow, TAG_DONE);

	CloseWindow(Mywindow);
	FreeVisualInfo(vi);

	return TRUE;
}

/* CleanUp memory */
void CleanUp()
{
	free(Cover1Texture);
	free(Cover2Texture);
	free(Cover3Texture);
	free(Cover4Texture);
}

/* Simple init routine */
void Initialize(void)
{
	glClearColor(0.5f, 0.5f, 0.5f, 0.0f);

	glShadeModel(GL_SMOOTH);			// use smooth shading
	glEnable(GL_DEPTH_TEST);			// hidden surface removal
	glEnable(GL_CULL_FACE);				// do not calculate inside of poly's
	glFrontFace(GL_CCW);			   	// counter clock-wise polygons are out

   /* fitering = nearest, initially */
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

   glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
   glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);

   if (LoadTextures())          // Load all textures
   {
      glEnable(GL_TEXTURE_2D);  // enable textures
   }
   else
   {
      ShowError();              // display error requester
   }

}

/* Render the Scene */
inline void Render(void)
{
	// clear screen and depth buffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

   glPushMatrix();

	glTranslatef(0.0f, 0.0f, 0.0f);		// perform transformations

	glRotatef(angle, 1.0f, 0.0f, 0.0f);	// place cube at (0,-3) and rotate it
	glRotatef(angle, 0.0f, 1.0f, 0.0f);
	glRotatef(angle, 0.0f, 0.0f, 1.0f);

   glScalef(30.0, 30.0, 30.0);

   glCallList(Cube);  // call object from display list

   glPopMatrix();

	glutSwapBuffers();  // bring backbuffer to foreground
}

/* Idle function */
void Idle(void)
{
   if (Anim)
   {
   	if (angle >= 360.0)
	   	angle = 0.0;
	      angle+=1.0;

	   glutPostRedisplay();
	}
}

/* Reshape function */
static void Reshape( int width, int height )
{
   glViewport( 0, 0, width, height );
   glMatrixMode( GL_PROJECTION );
   glLoadIdentity();
   glFrustum( -5.0, 5.0, -5.0, 5.0, 10.0, 80.0 );
   glMatrixMode( GL_MODELVIEW );
   glLoadIdentity();
   glTranslatef( 0.0, 0.0, -70.0 );
}

/* Menu function for GLUT menu */
static void ModeMenu(int entry)
{
   if (entry==ANIMATE) {
      Anim = !Anim;
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

/* MAIN function */
int main( int argc, char *argv[] )
{
   open_libs(); // Librarys öffnen

   glutInit( &argc, argv );
   glutInitWindowSize( 300, 300 );

   glutInitDisplayMode( GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);

   glutCreateWindow(argv[0] );

   /* Init everything */
   Initialize();
   Init_Cube();

   glutReshapeFunc(Reshape);
   glutDisplayFunc(Render);
   glutIdleFunc(Idle);

   /* Create GLUT Menu */
   glutCreateMenu(ModeMenu);
   glutAddMenuEntry("Point Filtered", POINT_FILTER);
   glutAddMenuEntry("Linear Filtered", LINEAR_FILTER);
   glutAddMenuEntry("Toggle Animation", ANIMATE);
   glutAddMenuEntry("About", ABOUT);
   glutAddMenuEntry("Quit", QUIT);
   glutAttachMenu(GLUT_RIGHT_BUTTON);

   glutMainLoop();

   /* Free all Textures */
   CleanUp();

	close_all();  // close all libraries

   return 0;
}
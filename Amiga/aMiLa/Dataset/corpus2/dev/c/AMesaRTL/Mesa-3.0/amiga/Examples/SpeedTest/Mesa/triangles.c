/*
 * triangles.c
 *
 * Modified  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Based on triangles.c from CyberGL
 * Changes to work with AmigaMesaRTL
 *
 * Original copyright notice follows:
 */

/*
**	$VER: triangles.c 1.0 (20.03.1997)
**
**	This is an example program for CyberGL
**
**      Written by Frank Gerberding
**
**	Copyright © 1996-1997 by phase5 digital products
**      All Rights reserved.
**
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#include <clib/exec_protos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#include "gl/gl.h"
#include "gl/mesadriver.h"
#include "gl/outputhandler.h"
#include "gl/glu.h"

#define WIDTH    300
#define HEIGHT   200





void handle_window_events (struct Window *window)
{
  struct IntuiMessage *msg;
  int                  done = 0;

  while (!done)
  {
    Wait (1L << window->UserPort->mp_SigBit);
    while ((!done) && (msg = (struct IntuiMessage *) GetMsg (window->UserPort)))
    {
      switch (msg->Class)
      {
        case IDCMP_CLOSEWINDOW:
          done = 1;
          break;
      }
      ReplyMsg ((struct Message *) msg);
    }
  }
}





void drawTriangles (int num)
{
  int count;
  time_t t1,t2;

  glMatrixMode   (GL_PROJECTION);
  glLoadIdentity ();

  glOrtho        (-400.0, 400.0, -300.0, 300.0, 500.0, -500.0);

  srand (42);

  t1 = time(NULL);
  for (count = 0; count < num; count++)
  {
    glBegin (GL_TRIANGLES);
      glColor3ub (rand () % 256, rand () % 256, rand () % 256);
      glVertex3i (rand () % 800 - 400, rand () % 600 - 300, rand () % 1000 - 500);
      glColor3ub (rand () % 256, rand () % 256, rand () % 256);
      glVertex3i (rand () % 800 - 400, rand () % 600 - 300, rand () % 1000 - 500);
      glColor3ub (rand () % 256, rand () % 256, rand () % 256);
      glVertex3i (rand () % 800 - 400, rand () % 600 - 300, rand () % 1000 - 500);
    glEnd ();
  }
  glFlush();

  t2 = time(NULL);
  printf("Time = %d\n%d triangles per second\n",t2-t1,t2 != t1 ? num/(t2-t1) : num);
}





void main (int argc, char *argv[])
{
  AmigaMesaRTLContext context;
  struct Window *window;
  struct Screen *screen;

  screen = LockPubScreen("Mesa");
  window = OpenWindowTags(NULL,
  			WA_InnerWidth,			WIDTH,
  			WA_InnerHeight,			HEIGHT,
			WA_Title,			"Triangles",
			WA_PubScreen,		screen,
			WA_IDCMP,			IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY,
			WA_CloseGadget, TRUE,
            WA_DepthGadget, TRUE,
            WA_DragBar,     TRUE,
			WA_Activate,	TRUE,
			TAG_END);
  UnlockPubScreen(NULL,screen);

  if (window)
  {
    context = AmigaMesaRTLCreateContext(
    			OH_Output,			window,
    			OH_OutputType,		"Window",
    			AMRTL_RGBAMode,		TRUE,
    			TAG_END);
    if(context)
    {
      AmigaMesaRTLMakeCurrent(context);
      glEnable         (GL_DEPTH_TEST);
      glEnable         (GL_DITHER);
      glShadeModel     (GL_SMOOTH);
      glClear          (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      drawTriangles    (argc == 2 ? atoi(argv[1]) : 500);

      handle_window_events (window);

      AmigaMesaRTLDestroyContext(context);
    }
    CloseWindow(window);
  }
}

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

/*
 * triangles.c
 *
 * Modified  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Some changes to output some stats for comparison with AmigaMesaRTL
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#include <clib/exec_protos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#define CYBERGLNAME             "cybergl.library"
#define CYBERGLVERSION          39L


#define SHARED                  /* we use the cyberglshared library */
#define GL_APICOMPATIBLE        /* we use stubs from cybergl.lib */


#include <libraries/cybergl.h>
#include <libraries/cybergl_display.h>
#include <proto/cybergl.h>

#ifdef SHARED
LONG __oslibversion   = 39L;
LONG __CGLlibversion = CYBERGLVERSION;
#endif


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

#ifndef GL_APICOMPATIBLE
  {
   GLortho glortho;

   glortho.left    = -400.0;
   glortho.right   = 400.0;
   glortho.bottom  = -300.0;
   glortho.top     = 300.0;
   glortho.zNear   = 500.0;
   glortho.zFar    = -500.0;
   glOrtho (&glortho);
  }
#else
  glOrtho        (-400.0, 400.0, -300.0, 300.0, 500.0, -500.0);
#endif
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
  void     *window;
  struct Screen *screen;

  screen = LockPubScreen("Mesa");
  window  = openGLWindowTags (WIDTH, HEIGHT, GLWA_Title, "Triangles",
                                             GLWA_PubScreen, screen,
                                             GLWA_IDCMP, IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY,
                                             GLWA_CloseGadget, TRUE,
                                             GLWA_DepthGadget, TRUE,
                                             GLWA_DragBar,     TRUE,
                                             GLWA_Activate, TRUE,
                                             GLWA_RGBAMode, GL_TRUE,
                                             TAG_DONE);
  UnlockPubScreen(NULL,screen);
  if (window)
  {
    glEnable         (GL_DEPTH_TEST);
    glEnable         (GL_DITHER);
    glShadeModel     (GL_SMOOTH);
    glClear          (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    drawTriangles    (argc == 2 ? atoi(argv[1]) : 500);

    handle_window_events (getWindow (window));

    closeGLWindow (window);
  }
}

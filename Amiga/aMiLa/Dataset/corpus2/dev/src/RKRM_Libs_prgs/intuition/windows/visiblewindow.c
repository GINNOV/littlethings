;/* visiblewindow.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 visiblewindow.c
Blink FROM LIB:c.o,visiblewindow.o TO visiblewindow LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit
*/

/*
Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/


/*
** open a window on the visible part of a screen, with the window as large
** as the visible part of the screen.  It is assumed that the visible part
** of the screen is OSCAN_TEXT, which how the user has set their preferences.
*/
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <graphics/displayinfo.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

/* Minimum window width and height:
** These values should really be calculated dynamically given the size
** of the font and the window borders.  Here, to keep the example simple
** they are hard-coded values.
*/
#define MIN_WINDOW_WIDTH  (100)
#define MIN_WINDOW_HEIGHT (50)

/* minimum and maximum calculations...Note that each argument is
** evaluated twice (don't use max(a++,foo(c))).
*/
#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<=(b)?(a):(b))

struct Library *IntuitionBase;
struct Library *GfxBase;

/* our function prototypes */
VOID handle_window_events(struct Window *win);
VOID fullScreen(VOID);

/*
** open all the libraries and run the code.  Cleanup when done.
*/
VOID main(int argc, char **argv)
{
/* these calls are only valid if we have Intuition version 37 or greater */
if (GfxBase = OpenLibrary("graphics.library",37))
    {
    if (IntuitionBase = OpenLibrary("intuition.library",37))
        {
        fullScreen();

        CloseLibrary(IntuitionBase);
        }
    CloseLibrary(GfxBase);
    }
}


/*
** Open a window on the default public screen, then leave it open until the
** user selects the close gadget. The window is full-sized, positioned in the
** currently visible OSCAN_TEXT area.
*/
VOID fullScreen(VOID)
{
struct Window *test_window;
struct Screen *pub_screen;
struct Rectangle rect;
ULONG screen_modeID;
LONG width, height, left, top;

left  = 0;   /* set some reasonable defaults for left, top, width and height. */
top   = 0;   /* we'll pick up the real values with the call to QueryOverscan(). */
width = 640;
height= 200;

/* get a lock on the default public screen */
if (NULL != (pub_screen = LockPubScreen(NULL)))
    {
    /* this technique returns the text overscan rectangle of the screen that we
    ** are opening on.  If you really need the actual value set into the display
    ** clip of the screen, use the VideoControl() command of the graphics library
    ** to return a copy of the ViewPortExtra structure.  See the Graphics
    ** library chapter and Autodocs for more details.
    **
    ** GetVPModeID() is a graphics call...
    */

    screen_modeID = GetVPModeID(&pub_screen->ViewPort);
    if(screen_modeID != INVALID_ID)
        {
        if (QueryOverscan(screen_modeID, &rect, OSCAN_TEXT))
            {
            /* make sure window coordinates are positive or zero */
            left = max(0, -pub_screen->LeftEdge);
            top  = max(0, -pub_screen->TopEdge);

            /* get width and height from size of display clip */
            width  = rect.MaxX - rect.MinX + 1;
            height = rect.MaxY - rect.MinY + 1;

            /* adjust height for pulled-down screen (only show visible part) */
            if (pub_screen->TopEdge > 0)
                height -= pub_screen->TopEdge;

            /* insure that window fits on screen */
            height = min(height, pub_screen->Height);
            width  = min(width,  pub_screen->Width);

            /* make sure window is at least minimum size */
            width  = max(width,  MIN_WINDOW_WIDTH);
            height = max(height, MIN_WINDOW_HEIGHT);
            }
        }

    /* open the window on the public screen */
    test_window = OpenWindowTags(NULL,
            WA_Left, left,            WA_Width,  width,
            WA_Top,  top,             WA_Height, height,
            WA_CloseGadget, TRUE,
            WA_IDCMP,       IDCMP_CLOSEWINDOW,
            WA_PubScreen,   pub_screen,
            TAG_END);

    /* unlock the screen.  The window now acts as a lock on the screen,
    ** and we do not need the screen after the window has been closed.
    */
    UnlockPubScreen(NULL, pub_screen);

    /* if we have a valid window open, run the rest of the
    ** program, then clean up when done.
    */
    if (test_window)
        {
        handle_window_events(test_window);
        CloseWindow(test_window);
        }
    }
}


/*
** Wait for the user to select the close gadget.
*/
VOID handle_window_events(struct Window *win)
{
struct IntuiMessage *msg;
BOOL done = FALSE;

while (! done)
    {
    /* we only have one signal bit, so we do not have to check which
    ** bit(s) broke the Wait() (i.e. the return value of Wait)
    */
    Wait(1L << win->UserPort->mp_SigBit);

    while ( (! done) &&
            (msg = (struct IntuiMessage *)GetMsg(win->UserPort)))
        {
        /* use a switch statement if looking for multiple event types */
        if (msg->Class == IDCMP_CLOSEWINDOW)
            done = TRUE;

        ReplyMsg((struct Message *)msg);
        }
    }
}

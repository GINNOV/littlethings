;/* winpubscreen.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 winpubscreen.c
Blink FROM LIB:c.o,winpubscreen.o TO winpubscreen LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
** winpubscreen.c
** open a window on the default public screen (usually the Workbench screen)
*/

#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

struct Library *IntuitionBase;

/* our function prototypes */
VOID handle_window_events(struct Window *win);


/*
** Open a simple window on the default public screen,
** then leave it open until the user selects the close gadget.
*/
VOID main(int argc, char **argv)
{
struct Window *test_window = NULL;
struct Screen *test_screen = NULL;

IntuitionBase = OpenLibrary("intuition.library",37);
if (IntuitionBase)
    {
    /* get a lock on the default public screen */
    if (test_screen = LockPubScreen(NULL))
            {
            /* open the window on the public screen */
            test_window = OpenWindowTags(NULL,
                    WA_Left,  10,    WA_Top,    20,
                    WA_Width, 300,   WA_Height, 100,
                    WA_DragBar,         TRUE,
                    WA_CloseGadget,     TRUE,
                    WA_SmartRefresh,    TRUE,
                    WA_NoCareRefresh,   TRUE,
                    WA_IDCMP,           IDCMP_CLOSEWINDOW,
                    WA_Title,           "Window Title",
                    WA_PubScreen,       test_screen,
                    TAG_END);

            /* Unlock the screen.  The window now acts as a lock on
            ** the screen, and we do not need the screen after the
            ** window has been closed.
            */
            UnlockPubScreen(NULL, test_screen);

            /* if we have a valid window open, run the rest of the
            ** program, then clean up when done.
            */
            if (test_window)
                {
                handle_window_events(test_window);
                CloseWindow(test_window);
                }
            }
    CloseLibrary(IntuitionBase);
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
    /* We have no other ports of signals to wait on,
    ** so we'll just use WaitPort() instead of Wait()
    */
    WaitPort(win->UserPort);

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

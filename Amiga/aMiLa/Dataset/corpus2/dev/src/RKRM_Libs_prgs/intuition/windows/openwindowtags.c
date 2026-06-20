;/* openwindowtags.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 openwindowtags.c
Blink FROM LIB:c.o,openwindowtags.o TO openwindowtags LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
** openwindowtags.c - open a window using tags.
*/

#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <intuition/screens.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

#define MY_WIN_LEFT   (20)
#define MY_WIN_TOP    (10)
#define MY_WIN_WIDTH  (300)
#define MY_WIN_HEIGHT (110)

void handle_window_events(struct Window *);

struct Library *IntuitionBase;

struct TagItem win_tags[] =
    {
    {WA_Left,       MY_WIN_LEFT},
    {WA_Top,        MY_WIN_TOP},
    {WA_Width,      MY_WIN_WIDTH},
    {WA_Height,     MY_WIN_HEIGHT},
    {WA_CloseGadget,TRUE},
    {WA_IDCMP,      IDCMP_CLOSEWINDOW},
    {TAG_DONE, NULL},
    };

/*
** Open a simple window using OpenWindowTagList()
*/
VOID main(int argc, char **argv)
{
struct Window *win;

/* these calls are only valid if we have Intuition version 37 or greater */
IntuitionBase = OpenLibrary("intuition.library",37);
if (IntuitionBase!=NULL)
    {
    win = OpenWindowTagList(NULL,win_tags);
    if (win==NULL)
        {
        /* window failed to open */
        }
    else
        {
        /* window successfully opened here */
        handle_window_events(win);

        CloseWindow(win);
        }
    CloseLibrary((struct Library *)IntuitionBase);
    }
}

/* Normally this routine would contain an event loop like the one given
** in the chapter "Intuition Input and Output Methods".  Here we just
** wait for any messages we requested to appear at the Window's port.
*/
VOID handle_window_events(struct Window *win)
{
WaitPort(win->UserPort);
}

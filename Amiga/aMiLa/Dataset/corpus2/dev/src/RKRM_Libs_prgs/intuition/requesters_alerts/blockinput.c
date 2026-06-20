;/* blockinput.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 blockinput.c
Blink FROM LIB:c.o,blockinput.o TO blockinput LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
** blockinput.c -- program to demonstrate how to block the input from a
** window using a minimal requester, and how to put up a busy pointer.
*/
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

/* our function prototypes */
BOOL beginWait(struct Window *win, struct Requester *waitRequest);
VOID endWait(struct Window *win, struct Requester *waitRequest);
VOID processIDCMP(struct Window *win);

struct Library *IntuitionBase;

/* data for a busy pointer.
** this data must be in chip memory!!!
*/
UWORD __chip waitPointer[] =
    {
    0x0000, 0x0000,     /* reserved, must be NULL */

    0x0400, 0x07C0,
    0x0000, 0x07C0,
    0x0100, 0x0380,
    0x0000, 0x07E0,
    0x07C0, 0x1FF8,
    0x1FF0, 0x3FEC,
    0x3FF8, 0x7FDE,
    0x3FF8, 0x7FBE,
    0x7FFC, 0xFF7F,
    0x7EFC, 0xFFFF,
    0x7FFC, 0xFFFF,
    0x3FF8, 0x7FFE,
    0x3FF8, 0x7FFE,
    0x1FF0, 0x3FFC,
    0x07C0, 0x1FF8,
    0x0000, 0x07E0,

    0x0000, 0x0000,     /* reserved, must be NULL */
    };



/*
** main()
**
** Open a window and display a busy-pointer for a short time then wait for
** the user to hit the close gadget (in processIDCMP()).  Normally, the
** application would bracket sections of code where it wishes to block window
** input with the beginWait() and endWait() functions.
*/
VOID main (int argc, char **argv)
{
struct Window *win;

if (IntuitionBase = OpenLibrary("intuition.library",37))
    {
    if (win = OpenWindowTags(NULL,
                        WA_IDCMP, IDCMP_CLOSEWINDOW|IDCMP_INTUITICKS,
                        WA_Activate, TRUE,
                        WA_Width,  320,
                        WA_Height, 100,
                        WA_CloseGadget, TRUE,
                        WA_DragBar, TRUE,
                        WA_DepthGadget, TRUE,
                        WA_SizeGadget, TRUE,
                        WA_MaxWidth, ~0,
                        WA_MaxHeight, ~0,
                        TAG_END))
        {
        processIDCMP(win);
        CloseWindow(win);
        }
    CloseLibrary(IntuitionBase);
    }
}



/*
** beginWait()
**
** Clear the requester with InitRequester.  This makes a requester of
** width = 0, height = 0, left = 0, top = 0; in fact, everything is zero.
** This requester will simply block input to the window until
** EndRequest is called.
**
** The pointer is set to a reasonable 4-color busy pointer, with proper offsets.
*/
BOOL beginWait(struct Window *win, struct Requester *waitRequest)
{
extern UWORD __chip waitPointer[];

InitRequester(waitRequest);
if (Request(waitRequest, win))
    {
    SetPointer(win, waitPointer, 16, 16, -6, 0);
    SetWindowTitles(win,"Busy - Input Blocked",(UBYTE *)~0);
    return(TRUE);
    }
else
    return(FALSE);
}



/*
** endWait()
**
** Routine to reset the pointer to the system default, and remove the
** requester installed with beginWait().
*/
VOID endWait(struct Window *win, struct Requester *waitRequest)
{
ClearPointer(win);
EndRequest(waitRequest, win);
SetWindowTitles(win,"Not Busy",(UBYTE *)~0);
}


/*
** processIDCMP()
**
** Wait for the user to close the window.
*/
VOID processIDCMP(struct Window *win)
{
WORD done;
struct IntuiMessage *msg;
ULONG class;
struct Requester myreq;
UWORD tick_count;

done = FALSE;

/* Put up a requester with no imagery (size zero). */
if (beginWait(win,&myreq))
    {
    /*
    ** Insert code here for a window to act as the requester.
    */

    /* We'll count down INTUITICKS, which come about ten times
    ** a second.  We'll keep the busy state for about three seconds.
    */
    tick_count = 30;
    }

while (!done)
    {
    Wait(1L << win->UserPort->mp_SigBit);

    while (NULL != (msg = (struct IntuiMessage *)GetMsg(win->UserPort)))
        {
        class = msg->Class;
        ReplyMsg((struct Message *)msg);

        switch (class)
            {
            case IDCMP_CLOSEWINDOW:
                done = TRUE;
                break;

            case IDCMP_INTUITICKS:
                if (tick_count > 0)
                    {
                    if (--tick_count == 0)  endWait(win,&myreq);
                    }
                break;
            }
        }
    }
}

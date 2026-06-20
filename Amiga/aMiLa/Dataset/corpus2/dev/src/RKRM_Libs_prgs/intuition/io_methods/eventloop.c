;/* eventloop.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 eventloop.c
Blink FROM LIB:c.o,eventloop.o TO eventloop LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
** eventloop.c - standard technique to handle IntuiMessages from an IDCMP.
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
BOOL handleIDCMP(struct Window *win, BOOL done);

struct Library *IntuitionBase = NULL;


/*
** main routine.
** Open required library and window, then process the events from the
** window.  Free all resources when done.
*/
VOID main(int argc, char **argv)
{
ULONG signals;
UBYTE done;
struct Window *win;

IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library",37);
if (IntuitionBase != NULL)
    {
    if (win = OpenWindowTags(NULL,
                        WA_Title,       "Press Keys and Mouse in this Window",
                        WA_Width,       500,
                        WA_Height,      50,
                        WA_Activate,    TRUE,
                        WA_CloseGadget, TRUE,
                        WA_RMBTrap,     TRUE,
                        WA_IDCMP, IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY |
                            IDCMP_RAWKEY | IDCMP_DISKINSERTED |
                            IDCMP_DISKREMOVED | IDCMP_MOUSEBUTTONS,
                        TAG_END))
        {
        done = FALSE;

        /* perform this loop until the message handling routine signals
        ** that we are done.
        **
        ** When the Wait() returns, check which signal hit and process
        ** the correct port.  There is only one port here, so the test
        ** could be eliminated.  If multiple ports were being watched,
        ** the test would become:
        **
        **    signals = Wait( (1L << win1->UserPort->mp_SigBit) |
        **                    (1L << win2->UserPort->mp_SigBit) |
        **                    (1L << win3->UserPort->mp_SigBit))
        **    if (signals & (1L << win1->UserPort->mp_SigBit))
        **        done = handleWin1IDCMP(win1,done);
        **    else if (signals & (1L << win2->UserPort->mp_SigBit))
        **        done = handleWin2IDCMP(win2,done);
        **    else if (signals & (1L << win3->UserPort->mp_SigBit))
        **        done = handleWin3IDCMP(win3,done);
        **
        ** Note that these could all call the same routine with different
        ** window pointers (if the handling was identical).
        **
        ** handleIDCMP() should remove all of the messages from the port.
        */
        while (!done)
            {
            signals = Wait(1L << win->UserPort->mp_SigBit);
            if (signals & (1L << win->UserPort->mp_SigBit))
                done = handleIDCMP(win,done);
            };
        CloseWindow(win);
        }
    CloseLibrary(IntuitionBase);
    }
}


/*
** handleIDCMP() - handle all of the messages from an IDCMP.
*/
BOOL handleIDCMP(struct Window *win, BOOL done)
{
struct IntuiMessage *message;
USHORT code;
SHORT mousex, mousey;
ULONG class;

/* Remove all of the messages from the port by calling GetMsg()
** until it returns NULL.
**
** The code should be able to handle three cases:
**
** 1.  No messages waiting at the port, and the first call to GetMsg()
** returns NULL.  In this case the code should do nothing.
**
** 2.  A single message waiting.  The code should remove the message,
** processes it, and finish.
**
** 3.  Multiple messages waiting.  The code should process each waiting
** message, and finish.
*/
while (NULL != (message = (struct IntuiMessage *)GetMsg(win->UserPort)))
    {
    /* It is often convenient to copy the data out of the message.
    ** In many cases, this lets the application reply to the message
    ** quickly.  Copying the data is not required, if the code does
    ** not reply to the message until the end of the loop, then
    ** it may directly reference the message information anywhere
    ** before the reply.
    */
    class  = message->Class;
    code   = message->Code;
    mousex = message->MouseX;
    mousey = message->MouseY;

    /* The loop should reply as soon as possible.  Note that the code
    ** may not reference data in the message after replying to the
    ** message.  Thus, the application should not reply to the message
    ** until it is done referencing information in it.
    **
    ** Be sure to reply to every message received with GetMsg().
    */
    ReplyMsg((struct Message *)message);

    /* The class contains the IDCMP type of the message. */
    switch (class)
        {
        case IDCMP_CLOSEWINDOW:
            done = TRUE;
            break;
        case IDCMP_VANILLAKEY:
            printf("IDCMP_VANILLAKEY (%lc)\n",code);
            break;
        case IDCMP_RAWKEY:
            printf("IDCMP_RAWKEY\n");
            break;
        case IDCMP_DISKINSERTED:
            printf("IDCMP_DISKINSERTED\n");
            break;
        case IDCMP_DISKREMOVED:
            printf("IDCMP_DISKREMOVED\n");
            break;
        case IDCMP_MOUSEBUTTONS:
            /* the code often contains useful data, such as the ASCII
            ** value (for IDCMP_VANILLAKEY), or the type of button
            ** event here.
            */
            switch (code)
                {
                case SELECTUP:
                    printf("SELECTUP at %d,%d\n",mousex,mousey);
                    break;
                case SELECTDOWN:
                    printf("SELECTDOWN at %d,%d\n",mousex,mousey);
                    break;
                case MENUUP:
                    printf("MENUUP\n");
                    break;
                case MENUDOWN:
                    printf("MENUDOWN\n");
                    break;
                default:
                    printf("UNKNOWN CODE\n");
                    break;
                }
            break;
        default:
            printf("Unknown IDCMP message\n");
            break;
        }
    }
return(done);
}

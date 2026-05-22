;/* mousetest.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 mousetest.c
Blink FROM LIB:c.o,mousetest.o TO mousetest LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
** mousetest.c - Read position and button events from the mouse.
*/
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <devices/inputevent.h>

#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

#define BUFSIZE 16

/* something to use to track the time between messages
** to test for double-clicks.
*/
typedef struct myTimeVal
    {
    ULONG LeftSeconds;
    ULONG LeftMicros;
    ULONG RightSeconds;
    ULONG RightMicros;
    } MYTIMEVAL;








/* our function prototypes */
VOID doButtons(struct IntuiMessage *msg, MYTIMEVAL *tv);
VOID process_window(struct Window *win);

struct Library *IntuitionBase;
struct GfxBase       *GfxBase;  /* we need GfxBase->DefaultFont */


/*
** main() -- set-up everything.
*/
VOID main(int argc, char **argv)
{
struct Window *win;
struct Screen *scr;
struct DrawInfo *dr_info;
ULONG width;

/* Open the libraries we will use.  Requires Release 2 (KS V2.04, V37) */
if (IntuitionBase = OpenLibrary("intuition.library",37))
    {
    if (GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 37))
        {
        /* Lock the default public screen in order to read its DrawInfo data */
        if (scr = LockPubScreen(NULL))
            {
            if (dr_info = GetScreenDrawInfo(scr))
                {
                /* use wider of space needed for output (18 chars and spaces)
                 * or titlebar text plus room for titlebar gads (approx 18 each)
                 */
                width = max((GfxBase->DefaultFont->tf_XSize * 18),
                            (18 * 2) + TextLength(&scr->RastPort,"MouseTest",9));

                if (win = OpenWindowTags(NULL,
                            WA_Top,    20,
                            WA_Left,   100,
                            WA_InnerWidth,  width,
                            WA_Height, (2 * GfxBase->DefaultFont->tf_YSize) +
                                       scr->WBorTop + scr->Font->ta_YSize + 1 +
                                       scr->WBorBottom,
                            WA_Flags, WFLG_DEPTHGADGET | WFLG_CLOSEGADGET |
                                      WFLG_ACTIVATE    | WFLG_REPORTMOUSE |
                                      WFLG_RMBTRAP     | WFLG_DRAGBAR,
                            WA_IDCMP, IDCMP_CLOSEWINDOW | IDCMP_RAWKEY |
                                      IDCMP_MOUSEMOVE   | IDCMP_MOUSEBUTTONS,
                            WA_Title, "MouseTest",
                            WA_PubScreen, scr,
                            TAG_END))
                    {
                    printf("Monitors the Mouse:\n");
                    printf("    Move Mouse, Click and DoubleClick in Window\n");

                    SetAPen(win->RPort,dr_info->dri_Pens[TEXTPEN]);
                    SetBPen(win->RPort,dr_info->dri_Pens[BACKGROUNDPEN]);
                    SetDrMd(win->RPort,JAM2);

                    process_window(win);

                    CloseWindow(win);
                    }
                FreeScreenDrawInfo(scr, dr_info);
                }
            UnlockPubScreen(NULL,scr);
            }
        CloseLibrary((struct Library *)GfxBase);
        }
    CloseLibrary(IntuitionBase);
    }
}






/*
** process_window() - simple message loop for processing IntuiMessages
*/
VOID process_window(struct Window *win)
{
USHORT done;
struct IntuiMessage *msg;
MYTIMEVAL tv;
UBYTE prt_buff[14];
LONG xText, yText;  /* places to position text in window. */

done = FALSE;
tv.LeftSeconds = 0; /* initial values for testing double-click */
tv.LeftMicros  = 0;
tv.RightSeconds = 0;
tv.RightMicros  = 0;
xText = win->BorderLeft + (win->IFont->tf_XSize * 2);
yText = win->BorderTop + 3 + win->IFont->tf_Baseline;

while (!done)
    {
    Wait((1L<<win->UserPort->mp_SigBit));

    while ((!done) &&
           (msg = (struct IntuiMessage *)GetMsg(win->UserPort)))
        {
        switch (msg->Class)
            {
            case IDCMP_CLOSEWINDOW:
                done = TRUE;
                break;
            /* NOTE NOTE NOTE:  If the mouse queue backs up a lot, Intuition
            ** will start dropping MOUSEMOVE messages off the end until the
            ** queue is serviced.  This may cause the program to lose some
            ** of the MOUSEMOVE events at the end of the stream.
            **
            ** Look in the window structure if you need the true position
            ** of the mouse pointer at any given time.  Look in the
            ** MOUSEBUTTONS message if you need position when it clicked.
            ** An alternate to this processing would be to set a flag that
            ** a mousemove event arrived, then print the position of the
            ** mouse outside of the "while (GetMsg())" loop.  This allows
            ** a single processing call for many mouse events, which speeds
            ** up processing A LOT!  Something like:
            **
            ** while (GetMsg())
            **    {
            **    if (class == IDCMP_MOUSEMOVE)
            **        mouse_flag = TRUE;
            **    ReplyMsg();   NOTE: copy out all needed fields first !
            **    }
            ** if (mouse_flag)
            **    {
            **    process_mouse_event();
            **    mouse_flag = FALSE;
            **    }
            **
            ** You can also use IDCMP_INTUITICKS for slower paced messages
            ** (all messages have mouse coordinates.)
            */
            case IDCMP_MOUSEMOVE:
                /* Show the current position of the mouse relative to the
                ** upper left hand corner of our window
                */
                Move(win->RPort,xText,yText);
                sprintf(prt_buff, "X%5d Y%5d", msg->MouseX, msg->MouseY);
                Text(win->RPort,prt_buff,13);
                break;
            case IDCMP_MOUSEBUTTONS:
                doButtons(msg,&tv);
                break;
            }
        ReplyMsg((struct Message *)msg);
        }
    }
}

/*
** Show what mouse buttons where pushed
*/
VOID doButtons(struct IntuiMessage *msg, MYTIMEVAL *tv)
{
/* Yes, qualifiers can apply to the mouse also.  That is how
** we get the shift select on the Workbench.  This shows how
** to see if a specific bit is set within the qualifier
*/
if (msg->Qualifier & (IEQUALIFIER_LSHIFT | IEQUALIFIER_RSHIFT))
    printf("Shift ");

switch (msg->Code)
    {
    case SELECTDOWN:
        printf("Left Button Down at X%ld Y%ld", msg->MouseX, msg->MouseY);
        if(DoubleClick(tv->LeftSeconds, tv->LeftMicros, msg->Seconds, msg->Micros))
            printf(" DoubleClick!");
        else
            {
            tv->LeftSeconds = msg->Seconds;
            tv->LeftMicros  = msg->Micros;
            tv->RightSeconds = 0;
            tv->RightMicros  = 0;
            }
        break;
    case SELECTUP:
        printf("Left Button Up   at X%ld Y%ld", msg->MouseX, msg->MouseY);
        break;
    case MENUDOWN:
        printf("Right Button down at X%ld Y%ld", msg->MouseX, msg->MouseY);
        if(DoubleClick(tv->RightSeconds, tv->RightMicros, msg->Seconds, msg->Micros))
            printf(" DoubleClick!");
        else
            {
            tv->LeftSeconds = 0;
            tv->LeftMicros  = 0;
            tv->RightSeconds = msg->Seconds;
            tv->RightMicros  = msg->Micros;
            }
        break;
    case MENUUP:
        printf("Right Button Up   at X%ld Y%ld", msg->MouseX, msg->MouseY);
        break;
    }
printf("\n");
}

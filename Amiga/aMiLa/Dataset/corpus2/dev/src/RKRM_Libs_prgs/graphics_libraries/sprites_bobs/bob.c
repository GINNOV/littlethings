/* bob.c
**
** SAS/C V5.10a
** lc -b1 -cfist -v -y bob.c
** blink FROM LIB:c.o bob.o animtools.o LIB LIB:lc.lib LIB:amiga.lib TO bob


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

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuitionbase.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <graphics/gels.h>
#include <libraries/dos.h>
#include <stdlib.h>
#include "animtools.h"

VOID bobDrawGList(struct RastPort *rport, struct ViewPort *vport);
VOID process_window(struct Window *win, struct Bob *myBob);
VOID do_Bob(struct Window *win);

struct GfxBase       *GfxBase;       /* pointer to Graphics library */
struct IntuitionBase *IntuitionBase; /* pointer to Intuition library*/
int return_code;
#define GEL_SIZE  4                  /* number of lines in the bob  */

/* Bob data - two sets that are alternated between.  Note that this */
/* data is at the resolution of the screen.                         */

/* data is 2 planes by 2 words by GEL_SIZE lines                    */
WORD chip bob_data1[2 * 2 * GEL_SIZE] =
        {
        /* plane 1 */
        0xffff, 0x0003, 0xfff0, 0x0003, 0xfff0, 0x0003, 0xffff, 0x0003,
        /* plane 2 */
        0x3fff, 0xfffc, 0x3ff0, 0x0ffc, 0x3ff0, 0x0ffc, 0x3fff, 0xfffc
        };

/* data is 2 planes by 2 words by GEL_SIZE lines                     */
WORD chip bob_data2[2 * 2 * GEL_SIZE] =
        {
        /* plane 1 */
        0xc000, 0xffff, 0xc000, 0x0fff, 0xc000, 0x0fff, 0xc000, 0xffff,
        /* plane 2 */
        0x3fff, 0xfffc, 0x3ff0, 0x0ffc, 0x3ff0, 0x0ffc, 0x3fff, 0xfffc
        };

NEWBOB myNewBob =                     /* Data for the new bob structure defined in animtools.h */
        {                             /* Initial image, WORD width, line height                */
        bob_data2, 2,  GEL_SIZE,      /* Image depth, plane pick, plane on off, VSprite flags  */
        2, 3, 0, SAVEBACK | OVERLAY,  /* dbuf (0=false), raster depth, x,y position, hit mask, */
        0, 8, 160, 100,  0,0,         /* me mask                                               */
        };

struct NewWindow myNewWindow =
        {                             /* information for the new window */
        80, 20, 400, 150, -1, -1, CLOSEWINDOW | INTUITICKS,
        ACTIVATE | WINDOWCLOSE | WINDOWDEPTH | RMBTRAP,
        NULL, NULL, "Bob", NULL, NULL, 0, 0, 0, 0, WBENCHSCREEN
        };

/* Draw the Bobs into the RastPort. */
VOID bobDrawGList(struct RastPort *rport, struct ViewPort *vport)
{
SortGList(rport);
DrawGList(rport, vport);
/* If the GelsList includes true VSprites, MrgCop() and LoadView() here */
WaitTOF() ;
}

/* Process window and dynamically change bob: Get messages. Go away on CLOSEWINDOW.
** Update and redisplay bob on INTUITICKS. Wait for more messages.
*/
VOID process_window(struct Window *win, struct Bob *myBob)
{
struct IntuiMessage *msg;

FOREVER {
        Wait(1L << win->UserPort->mp_SigBit);
        while (NULL != (msg = (struct IntuiMessage *)GetMsg(win->UserPort)))
                {
                /* only CLOSEWINDOW and INTUITICKS are active */
                if (msg->Class == CLOSEWINDOW)
                        {
                        ReplyMsg((struct Message *)msg);
                        return;
                        }
                /* Must be INTUITICKS:  change x and y values on the fly.  Note:
                ** do not have to add window offset, Bob is relative to the
                ** window (sprite relative to screen).
                */
                myBob->BobVSprite->X = msg->MouseX + 20;
                myBob->BobVSprite->Y = msg->MouseY + 1;
                ReplyMsg((struct Message *)msg);
                }
        /* after getting a message, change image data on the fly */
        myBob->BobVSprite->ImageData =
                (myBob->BobVSprite->ImageData == bob_data1) ? bob_data2 : bob_data1;
        InitMasks(myBob->BobVSprite); /* set up masks for new image */
        bobDrawGList(win->RPort, ViewPortAddress(win));
        }
}


/* Working with the Bob: setup the GEL system, and get a new Bob (makeBob()).
** Add the bob to the system and display. Use the Bob.  When done, remove
** the Bob and update the display without the bob. Cleanup everything.
*/
VOID do_Bob(struct Window *win)
{
struct Bob         *myBob;
struct GelsInfo    *my_ginfo;

if (NULL == (my_ginfo = setupGelSys(win->RPort, 0x03)))
        return_code = RETURN_WARN;
else
        {
        if (NULL == (myBob = makeBob(&myNewBob)))
                return_code = RETURN_WARN;
        else
                {
                AddBob(myBob, win->RPort);
                bobDrawGList(win->RPort, ViewPortAddress(win));
                process_window(win, myBob);
                RemBob(myBob);
                bobDrawGList(win->RPort, ViewPortAddress(win));
                freeBob(myBob, myNewBob.nb_RasDepth);
                }
        cleanupGelSys(my_ginfo,win->RPort);
        }
}


/* Example bob program: First open up the libraries and a window. */
VOID main(int argc, char **argv)
{
struct Window      *win;

return_code = RETURN_OK;

if (NULL == (GfxBase = (struct GfxBase *)OpenLibrary(GRAPHICSNAME,37L)))
        return_code = RETURN_FAIL;
else
        {
        if (NULL == (IntuitionBase = (struct IntuitionBase *)OpenLibrary(INTUITIONNAME,37L)))
                return_code = RETURN_FAIL;
        else
                {
                if (NULL == (win = OpenWindow(&myNewWindow)))
                        return_code = RETURN_FAIL;
                else
                        {
                        do_Bob(win);
                        CloseWindow(win);
                        }
                CloseLibrary((struct Library *)IntuitionBase);
                }
        CloseLibrary((struct Library *)GfxBase);
        }
exit(return_code);
}
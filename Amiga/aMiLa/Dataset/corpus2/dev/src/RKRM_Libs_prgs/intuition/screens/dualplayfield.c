;/* dualplayfield.c - Shows how to turn on dual-playfield mode in a screen.
lc -b1 -cfist -v -y -j73 dualplayfield
blink FROM LIB:c.o dualplayfield.o TO dualplayfield LIB LIB:lc.lib LIB:amiga.lib
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


#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <graphics/displayinfo.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>

VOID doDualPF ( struct Window * );
BOOL installDualPF( struct Screen *, struct RastInfo * );
VOID drawSomething( struct RastPort * );
VOID handleIDCMP ( struct Window * );
VOID removeDualPF( struct Screen *s );

struct Library *IntuitionBase;
struct Library *GfxBase;

VOID main(int argc, char **argv)
{
struct Window *win;
struct Screen *scr;

IntuitionBase = OpenLibrary("intuition.library",37);
if (IntuitionBase != NULL)
    {
    GfxBase = OpenLibrary("graphics.library", 37);
    if (GfxBase != NULL)
        {
        scr = OpenScreenTags(NULL,
                             SA_Depth,     2,
                             SA_DisplayID, HIRES_KEY,
                             SA_Title,     "Dual Playfield Test Screen",
                             TAG_END);
        if ( scr != NULL )
            {
            win = OpenWindowTags(NULL,
                                 WA_Title,        "Dual Playfield Mode",
                                 WA_IDCMP,        IDCMP_CLOSEWINDOW,
                                 WA_Width,        200,
                                 WA_Height,       100,
                                 WA_DragBar,      TRUE,
                                 WA_CloseGadget,  TRUE,
                                 WA_CustomScreen, scr,
                                 TAG_END);
            if ( win != NULL )
                {
                doDualPF(win);

                CloseWindow(win);
                }
            CloseScreen(scr);
            }
        CloseLibrary(GfxBase);
        }
    CloseLibrary(IntuitionBase);
    }
}


/*
** Allocate all of the stuff required to add dual playfield to a screen.
*/
VOID doDualPF(struct Window *win)
{
struct Screen   *myscreen;
struct RasInfo  *rinfo2;
struct BitMap   *bmap2;
struct RastPort *rport2;

myscreen = win->WScreen;   /* Find the window's screen */

/* Allocate the second playfield's rasinfo, bitmap, and bitplane */
rinfo2 = (struct RasInfo *) AllocMem(sizeof(struct RasInfo), MEMF_PUBLIC | MEMF_CLEAR);
if ( rinfo2 != NULL )
    {
    /* Get a rastport, and set it up for rendering into bmap2 */
    rport2 = (struct RastPort *) AllocMem(sizeof(struct RastPort), MEMF_PUBLIC );
    if (rport2 != NULL )
        {
        bmap2 = (struct BitMap *) AllocMem(sizeof(struct BitMap), MEMF_PUBLIC | MEMF_CLEAR);
        if (bmap2 != NULL )
            {
            InitBitMap(bmap2, 1, myscreen->Width, myscreen->Height);

            /* extra playfield will only use one bitplane here. */
            bmap2->Planes[0] = (PLANEPTR) AllocRaster(myscreen->Width, myscreen->Height);
            if (bmap2->Planes[0] != NULL )
                {
                InitRastPort(rport2);
                rport2->BitMap = rinfo2->BitMap = bmap2;

                SetRast(rport2, 0);

                if (installDualPF(myscreen,rinfo2))
                    {
                    /* Set foreground color; color 9 is color 1 for
                    ** second playfield of hi-res viewport
                    */
                    SetRGB4(&myscreen->ViewPort, 9, 0, 0xF, 0);

                    drawSomething(rport2);

                    handleIDCMP(win);

                    removeDualPF(myscreen);
                    }
                FreeRaster(bmap2->Planes[0], myscreen->Width, myscreen->Height);
                }
            FreeMem(bmap2, sizeof(struct BitMap));
            }
        FreeMem(rport2, sizeof(struct RastPort));
        }
    FreeMem(rinfo2, sizeof(struct RasInfo));
    }
}


/*
** Manhandle the viewport:
** install second playfield and change modes
*/
BOOL installDualPF(struct Screen *scrn, struct RastInfo *rinfo2)
{
ULONG screen_modeID;
BOOL return_code = FALSE;

screen_modeID = GetVPModeID(&(scrn->ViewPort));
if( screen_modeID != INVALID_ID )
    {
    /* you can only play with the bits in the Modes field
    ** if the upper half of the screen mode ID is zero!!!
    */
    if ( (screen_modeID & 0xFFFF0000L) == 0L )
        {
        return_code = TRUE;

        Forbid();

        /* Install rinfo for viewport's second playfield */
        scrn->ViewPort.RasInfo->Next = rinfo2;
        scrn->ViewPort.Modes |= DUALPF;

        Permit();

        /* Put viewport change into effect */
        MakeScreen(scrn);
        RethinkDisplay();
        }
    }
return(return_code);
}

/*
** Draw some lines in a rast port...This is used to get some data into
** the second playfield.  The windows on the screen will move underneath
** these graphics without disturbing them.
*/
VOID drawSomething(struct RastPort *rp)
{
int width, height;
int r, c;

width = rp->BitMap->BytesPerRow * 8;
height = rp->BitMap->Rows;

SetAPen(rp, 1);

for (r = 0; r < height; r += 40)
    {
    for (c = 0; c < width; c += 40)
        {
        Move(rp, 0L, r);
        Draw(rp, c, 0L);
        }
    }
}

/*
** simple event loop to wait for the user to hit the close gadget
** on the window.
*/
VOID handleIDCMP(struct Window *win)
{
BOOL done = FALSE;
struct IntuiMessage *message = NULL;
ULONG class;
ULONG signals;

while (!done)
    {
    signals = Wait(1L << win->UserPort->mp_SigBit);
    if (signals & (1L << win->UserPort->mp_SigBit))
        {
        while ((!done) &&
               (message = (struct IntuiMessage *)GetMsg(win->UserPort)))
            {
            class = message->Class;
            ReplyMsg((struct Message *)message);

            switch (class)
                {
                case IDCMP_CLOSEWINDOW:
                    done = TRUE;
                    break;
                }
            }
        }
    }
}

/*
** remove the effects of installDualPF().
** only call if installDualPF() succeeded.
*/
VOID removeDualPF(struct Screen *scrn)
{
Forbid();

scrn->ViewPort.RasInfo->Next = NULL;
scrn->ViewPort.Modes &= ~DUALPF;

Permit();

MakeScreen(scrn);
RethinkDisplay();
}

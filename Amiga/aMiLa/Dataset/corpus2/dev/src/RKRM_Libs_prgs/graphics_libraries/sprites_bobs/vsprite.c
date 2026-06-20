/* vsprite.c
**
** SAS/C V5.10a
** lc -b1 -cfist -v -y vsprite.c
** blink FROM LIB:c.o vsprite.o animtools.o LIB LIB:lc.lib LIB:amiga.lib TO vsprite


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
#include <graphics/collide.h>
#include <libraries/dos.h>
#include <stdlib.h>
#include "animtools.h"

VOID borderCheck(struct VSprite *hitVSprite, LONG borderflags);
VOID process_window(struct Window *win, struct RastPort *myRPort, struct VSprite *MyVSprite);
VOID do_VSprite(struct Window *win, struct RastPort *myRPort);
VOID vspriteDrawGList(struct Window *win, struct RastPort *myRPort);

struct GfxBase		 *GfxBase;   /* pointer to Graphics library  */
struct IntuitionBase *IntuitionBase; /* pointer to Intuition library */

int return_code;
#define GEL_SIZE	4 /* number of lines in the vsprite */

/* VSprite data - there are two sets that are alternated between. */
/* note that this data is always displayed as low resolution.	  */
WORD chip vsprite_data1[] = { 0x7ffe, 0x80ff,
                              0x7c3e, 0x803f,
                              0x7c3e, 0x803f,
                              0x7ffe, 0x80ff,
                              0, 0 };

WORD chip vsprite_data2[] = { 0x7ffe, 0xff01,
                              0x7c3e, 0xfc01,
                              0x7c3e, 0xfc01,
                              0x7ffe, 0xff01,
                              0, 0 };

WORD mySpriteColors[] =     { 0x0000, 0x00f0, 0x0f00 };
WORD mySpriteAltColors[] =  { 0x000f, 0x0f00, 0x0ff0 };

NEWVSPRITE myNewVSprite = {              /* information for the new VSprite       */
        /* Image data, sprite color array word width (must be 1 for true VSprite) */
        vsprite_data1, mySpriteColors,1,
        /* Line height, image depth (must be 2 for true VSprite), x, y position   */
        GEL_SIZE, 2, 160, 100,
        /* Flags (VSPRITE == true VSprite), hit mask and me mask                  */
        VSPRITE, 1 << BORDERHIT, 0
        };

struct NewWindow myNewWindow = {        /* information for the new window */
    80, 20, 400, 150, -1, -1, CLOSEWINDOW | INTUITICKS,
    ACTIVATE | WINDOWCLOSE | WINDOWDEPTH | RMBTRAP | WINDOWDRAG,
    NULL, NULL, "VSprite", NULL, NULL, 0, 0, 0, 0, WBENCHSCREEN
    };

/* Basic VSprite display subroutine */
VOID vspriteDrawGList(struct Window *win, struct RastPort *myRPort)
{
SortGList(myRPort);
DrawGList(myRPort, ViewPortAddress(win));
RethinkDisplay();
}

/* Collision routine for vsprite hitting border.  Note that when the collision is VSprite to */
/* VSprite (or Bob to Bob, Bob to AnimOb, etc), then the parameters are both pointers to a VSprite. */
VOID borderCheck(struct VSprite *hitVSprite, LONG borderflags)
{
if (borderflags & RIGHTHIT)
    {
    hitVSprite->SprColors = mySpriteAltColors;
    hitVSprite->VUserExt  = -40;
    }
if (borderflags & LEFTHIT)
    {
    hitVSprite->SprColors = mySpriteColors;
    hitVSprite->VUserExt  = 20;
    }
}

/* Process window and dynamically change vsprite. Get messages. Go away on           */
/* CLOSEWINDOW.  Update and redisplay vsprite on INTUITICKS. Wait for more messages. */
VOID process_window(struct Window *win, struct RastPort *myRPort, struct VSprite *myVSprite)
{
struct IntuiMessage *msg;

FOREVER
    {
    Wait(1L << win->UserPort->mp_SigBit);
    while (NULL != (msg = (struct IntuiMessage *)GetMsg(win->UserPort)))
        {
        /* Only CLOSEWINDOW and INTUITICKS are active */
        if (msg->Class == CLOSEWINDOW)
            {
            ReplyMsg((struct Message *)msg);
            return;
            }
        /* Must be an INTUITICKS:  change x and y values on the fly.  Note offset by
        ** window left and top edge--sprite relative to the screen, not window.  Divide
        ** the MouseY in half to adjust for Lores movement increments on a Hires screen.
        */
        myVSprite->X = win->LeftEdge + msg->MouseX + myVSprite->VUserExt;
        myVSprite->Y = win->TopEdge  + msg->MouseY/2 + 1;
        ReplyMsg((struct Message *)msg);
        }
    /* Got a message, change image data on the fly */
    myVSprite->ImageData = (myVSprite->ImageData == vsprite_data1) ? vsprite_data2 : vsprite_data1;
    SortGList(myRPort);
    DoCollision(myRPort);
    vspriteDrawGList(win, myRPort);
    }
}

/* Working with the VSprite.  Setup the GEL system and get a new VSprite (makeVSprite()).   */
/* Add VSprite to the system and display.  Use the vsprite.  When done, remove VSprite and  */
/* update the display without the VSprite.  Cleanup everything.                             */
VOID do_VSprite(struct Window *win, struct RastPort *myRPort)
{
struct VSprite       *myVSprite;
struct GelsInfo       *my_ginfo;

if (NULL == (my_ginfo = setupGelSys(myRPort, 0xfc)))
    return_code = RETURN_WARN;
else
    {
    if (NULL == (myVSprite = makeVSprite(&myNewVSprite)))
        return_code = RETURN_WARN;
    else
        {
        AddVSprite(myVSprite, myRPort);
        vspriteDrawGList(win, myRPort);
        myVSprite->VUserExt = 20;
        SetCollision(BORDERHIT, (VOID *)borderCheck, myRPort->GelsInfo);
        process_window(win, myRPort, myVSprite);
        RemVSprite(myVSprite);
        freeVSprite(myVSprite);
        }
    vspriteDrawGList(win, myRPort);
    cleanupGelSys(my_ginfo, myRPort);
    }
}

/* Example VSprite program.  First open up the libraries and a window. */
VOID main(int argc, char **argv)
{
struct Window       *win;
struct RastPort    myRPort = {0};

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
            return_code = RETURN_WARN;
        else
            {
            InitRastPort(&myRPort);
            myRPort = win->WScreen->RastPort;       /* Copy the structure. */
            do_VSprite(win, &myRPort);
            CloseWindow(win);
            }
        CloseLibrary((struct Library *)IntuitionBase);
        }
    CloseLibrary((struct Library *)GfxBase);
    }
exit(return_code);
}
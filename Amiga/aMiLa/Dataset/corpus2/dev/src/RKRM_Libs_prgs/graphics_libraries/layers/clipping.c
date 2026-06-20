/* clipping.c
**
** SAS/C 5.10a
** lc -b1 -cfist -v -y clipping
** blink FROM LIB:c.o clipping.o TO clipping LIB LIB:lc.lib LIB:amiga.lib


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

/* Force use of new variable names to help prevent errors */
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <graphics/displayinfo.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/layers_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

#define MY_WIN_WIDTH  (300)
#define MY_WIN_HEIGHT (100)

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Library *LayersBase;

/*
** unclipWindow()
**
** Used to remove a clipping region installed by clipWindow() or
** clipWindowToBorders(), disposing of the installed region and
** reinstalling the region removed.
*/
void unclipWindow(struct Window *win)
{
struct Region     *old_region;

/* Remove any old region by installing a NULL region,
** then dispose of the old region if one was installed.
*/
if (NULL != (old_region = InstallClipRegion(win->WLayer, NULL)))
    DisposeRegion(old_region);
}

/*
** clipWindow()
** Clip a window to a specified rectangle (given by upper left and
** lower right corner.)  the removed region is returned so that it
** may be re-installed later.
*/
struct Region *clipWindow(struct Window *win,
    LONG minX, LONG minY, LONG maxX, LONG maxY)
{
struct Region    *new_region;
struct Rectangle  my_rectangle;

/* set up the limits for the clip */
my_rectangle.MinX = minX;
my_rectangle.MinY = minY;
my_rectangle.MaxX = maxX;
my_rectangle.MaxY = maxY;

/* get a new region and OR in the limits. */
if (NULL != (new_region = NewRegion()))
    {
    if (FALSE == OrRectRegion(new_region, &my_rectangle))
        {
        DisposeRegion(new_region);
        new_region = NULL;
        }
    }

/* Install the new region, and return any existing region.
** If the above allocation and region processing failed, then
** new_region will be NULL and no clip region will be installed.
*/
return(InstallClipRegion(win->WLayer, new_region));
}

/*
** clipWindowToBorders()
** clip a window to its borders.
** The removed region is returned so that it may be re-installed later.
*/
struct Region *clipWindowToBorders(struct Window *win)
{
return(clipWindow(win, win->BorderLeft, win->BorderTop,
    win->Width - win->BorderRight - 1, win->Height - win->BorderBottom - 1));
}

/*
** Wait for the user to select the close gadget.
*/
VOID wait_for_close(struct Window *win)
{
struct IntuiMessage *msg;
SHORT done;

done = FALSE;
while (FALSE == done)
    {
    /* we only have one signal bit, so we do not have to check which
    ** bit broke the Wait().
    */
    Wait(1L << win->UserPort->mp_SigBit);

    while ( (FALSE == done) &&
            (NULL != (msg = (struct IntuiMessage *)GetMsg(win->UserPort))))
        {
        /* use a switch statement if looking for multiple event types */
        if (msg->Class == IDCMP_CLOSEWINDOW)
            done = TRUE;

        ReplyMsg((struct Message *)msg);
        }
    }
}

/*
** Simple routine to blast all bits in a window with color three to show
** where the window is clipped.  After a delay, flush back to color zero
** and refresh the window borders.
*/
VOID draw_in_window(struct Window *win, UBYTE *message)
{
printf("%s...", message); fflush(stdout);
SetRast(win->RPort, 3);
Delay(200);
SetRast(win->RPort, 0);
RefreshWindowFrame(win);
printf("done\n");
}


/*
** Show drawing into an unclipped window, a window clipped to the
** borders and a window clipped to a random rectangle.  It is possible
** to clip more complex shapes by AND'ing, OR'ing and exclusive-OR'ing
** regions and rectangles to build a user clip region.
**
** This example assumes that old regions are not going to be re-used,
** so it simply throws them away.
*/
VOID clip_test(struct Window *win)
{
struct Region    *old_region;

draw_in_window(win,"Window with no clipping");

/* if the application has never installed a user clip region,
** then old_region will be NULL here.  Otherwise, delete the
** old region (you could save it and re-install it later...)
*/
if (NULL != (old_region = clipWindowToBorders(win)))
    DisposeRegion(old_region);
draw_in_window(win,"Window clipped to window borders");
unclipWindow(win);

/* here we know old_region will be NULL, as that is what we
** installed with unclipWindow()...
*/
if (NULL != (old_region = clipWindow(win,20,20,100,50)))
    DisposeRegion(old_region);
draw_in_window(win,"Window clipped from (20,20) to (100,50)");
unclipWindow(win);

wait_for_close(win);
}



/*
** Open and close resources, call the test routine when ready.
*/
VOID main(int argc, char **argv)
{
struct Window *win;

if (NULL != (IntuitionBase =
        (struct IntuitionBase *)OpenLibrary("intuition.library",37)))
    {
    if (NULL != (GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",37)))
        {
        if (NULL != (LayersBase = OpenLibrary("layers.library",37)))
            {
            if (NULL != (win = OpenWindowTags(NULL,
                                WA_Width,       MY_WIN_WIDTH,
                                WA_Height,      MY_WIN_HEIGHT,
                                WA_IDCMP,       IDCMP_CLOSEWINDOW,
                                WA_CloseGadget, TRUE,
                                WA_DragBar,     TRUE,
                                WA_Activate,    TRUE,
                                TAG_END)))
                {
                clip_test(win);

                CloseWindow(win);
                }
            CloseLibrary(LayersBase);
            }
        CloseLibrary((struct Library *)GfxBase);
        }
    CloseLibrary((struct Library *)IntuitionBase);
    }
}
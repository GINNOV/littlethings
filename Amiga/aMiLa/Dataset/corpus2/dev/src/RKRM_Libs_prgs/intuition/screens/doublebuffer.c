;/* doublebuffer.c - Show the use of a double-buffered screen.
lc -b1 -cfist -v -y -j73 doublebuffer
blink FROM LIB:c.o doublebuffer.o TO doublebuffer LIB LIB:lc.lib LIB:amiga.lib
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
#include <intuition/screens.h>

#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>


#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif


/* characteristics of the screen */
#define SCR_WIDTH  (320)
#define SCR_HEIGHT (200)
#define SCR_DEPTH    (2)


/* Prototypes for our functions */
VOID   runDBuff(struct Screen *, struct BitMap ** );
struct BitMap **setupBitMaps( LONG, LONG, LONG );
VOID   freeBitMaps(struct BitMap **,LONG, LONG, LONG );
LONG   setupPlanes(struct BitMap *, LONG, LONG, LONG );
VOID    freePlanes(struct BitMap *, LONG, LONG, LONG );


struct Library *IntuitionBase = NULL;
struct Library *GfxBase       = NULL;

/*
** Main routine.  Setup for using the double buffered screen.
** Clean up all resources when done or on any error.
*/

VOID main(int argc, char **argv)
{
struct BitMap **myBitMaps;
struct Screen  *screen;
struct NewScreen myNewScreen;

IntuitionBase = OpenLibrary("intuition.library", 33L);
if ( IntuitionBase != NULL )
    {
    GfxBase = OpenLibrary("graphics.library", 33L);
    if ( GfxBase != NULL )
        {
        myBitMaps = setupBitMaps(SCR_DEPTH, SCR_WIDTH, SCR_HEIGHT);
        if ( myBitMaps != NULL )
            {
            /* Open a simple quiet screen that is using the first
            ** of the two bitmaps.
            */
            myNewScreen.LeftEdge=0;
            myNewScreen.TopEdge=0;
            myNewScreen.Width=SCR_WIDTH;
            myNewScreen.Height=SCR_HEIGHT;
            myNewScreen.Depth=SCR_DEPTH;
            myNewScreen.DetailPen=0;
            myNewScreen.BlockPen=1;
            myNewScreen.ViewModes=HIRES;
            myNewScreen.Type=CUSTOMSCREEN | CUSTOMBITMAP | SCREENQUIET;
            myNewScreen.Font=NULL;
            myNewScreen.DefaultTitle=NULL;
            myNewScreen.Gadgets=NULL;
            myNewScreen.CustomBitMap=myBitMaps[0];

            screen = OpenScreen(&myNewScreen);
            if (screen != NULL)
                {
                /* Indicate that the rastport is double buffered. */
                screen->RastPort.Flags = DBUFFER;

                runDBuff(screen, myBitMaps);

                CloseScreen(screen);
                }
            freeBitMaps(myBitMaps, SCR_DEPTH, SCR_WIDTH, SCR_HEIGHT);
            }
        CloseLibrary(GfxBase);
        }
    CloseLibrary(IntuitionBase);
    }
}





/*
** setupBitMaps(): allocate the bit maps for a double buffered screen.
*/
struct BitMap **setupBitMaps(LONG depth, LONG width, LONG height)
{
/* this must be static -- it cannot go away when the routine exits. */
static struct BitMap *myBitMaps[2];

myBitMaps[0] = (struct BitMap *) AllocMem((LONG)sizeof(struct BitMap), MEMF_CLEAR);
if (myBitMaps[0] != NULL)
    {
    myBitMaps[1] = (struct BitMap *)AllocMem((LONG)sizeof(struct BitMap), MEMF_CLEAR);
    if (myBitMaps[1] != NULL)
        {
        InitBitMap(myBitMaps[0], depth, width, height);
        InitBitMap(myBitMaps[1], depth, width, height);

        if (NULL != setupPlanes(myBitMaps[0], depth, width, height))
            {
            if (NULL != setupPlanes(myBitMaps[1], depth, width, height))
                return(myBitMaps);

            freePlanes(myBitMaps[0], depth, width, height);
            }
        FreeMem(myBitMaps[1], (LONG)sizeof(struct BitMap));
        }
    FreeMem(myBitMaps[0], (LONG)sizeof(struct BitMap));
    }
return(NULL);
}

/*
** runDBuff(): loop through a number of iterations of drawing into
** alternate frames of the double-buffered screen.  Note that the
** object is drawn in color 1.
*/
VOID runDBuff(struct Screen *screen, struct BitMap **myBitMaps)
{
WORD ktr, xpos, ypos;
WORD toggleFrame;

toggleFrame = 0;
SetAPen(&(screen->RastPort), 1);

for (ktr = 1; ktr < 400; ktr++)
    {
    /* Calculate a position to place the object, these
    ** calculations insure the object will stay on the screen
    ** given the range of ktr and the size of the object.
    */
    xpos = ktr;
    if ((ktr % 100) >= 50)
        ypos = 50 - (ktr % 50);
    else
        ypos = ktr % 50;

    /* switch the bitmap so that we are drawing into the correct place */
    screen->RastPort.BitMap          = myBitMaps[toggleFrame];
    screen->ViewPort.RasInfo->BitMap = myBitMaps[toggleFrame];

    /* Draw the objects.
    ** Here we clear the old frame and draw a simple filled rectangle.
    */
    SetRast(&(screen->RastPort), 0);
    RectFill(&(screen->RastPort), xpos, ypos, xpos+100, ypos+100);

    /* update the physical display to match the newly drawn bitmap. */
    MakeScreen(screen); /* Tell intuition to do its stuff.          */
    RethinkDisplay();   /* Intuition compatible MrgCop & LoadView   */
                        /*               it also does a WaitTOF().  */

    /* switch the frame number for next time through */
    toggleFrame ^= 1;
    }
}

/*
** freeBitMaps(): free up the memory allocated by setupBitMaps().
*/
VOID freeBitMaps(struct BitMap **myBitMaps, LONG depth, LONG width, LONG height)
{
freePlanes(myBitMaps[0], depth, width, height);
freePlanes(myBitMaps[1], depth, width, height);

FreeMem(myBitMaps[0], (LONG)sizeof(struct BitMap));
FreeMem(myBitMaps[1], (LONG)sizeof(struct BitMap));
}

/*
** setupPlanes(): allocate the bit planes for a screen bit map.
*/
LONG setupPlanes(struct BitMap *bitMap, LONG depth, LONG width, LONG height)
{
SHORT plane_num ;

for (plane_num = 0; plane_num < depth; plane_num++)
    {
    bitMap->Planes[plane_num] = (PLANEPTR)AllocRaster(width, height);
    if (bitMap->Planes[plane_num] != NULL )
        BltClear(bitMap->Planes[plane_num], (width / 8) * height, 1);
    else
        {
        freePlanes(bitMap, depth, width, height);
        return(NULL);
        }
    }
return(TRUE);
}

/*
** freePlanes(): free up the memory allocated by setupPlanes().
*/
VOID freePlanes(struct BitMap *bitMap, LONG depth, LONG width, LONG height)
{
SHORT plane_num ;

for (plane_num = 0; plane_num < depth; plane_num++)
    {
    if (bitMap->Planes[plane_num] != NULL)
        FreeRaster(bitMap->Planes[plane_num], width, height);
    }
}

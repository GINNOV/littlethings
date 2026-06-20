;/*  RGBBoxes.c simple ViewPort example -- works with 1.3 and Release 2
LC -b1 -cfistq -v -y -j73 RGBBoxes.c
Blink FROM LIB:c.o,RGBBoxes.o TO RGBBoxes LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;


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
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <graphics/copper.h>
#include <graphics/view.h>
#include <graphics/displayinfo.h>
#include <graphics/gfxnodes.h>
#include <graphics/videocontrol.h>
#include <libraries/dos.h>
#include <utility/tagitem.h>

#include <clib/graphics_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <stdio.h>
#include <stdlib.h>

#define DEPTH 2     /*  The number of bitplanes.  */
#define WIDTH 640   /*  Nominal width and height  */
#define HEIGHT 400  /*  used in 1.3.              */

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

VOID drawFilledBox(WORD , WORD );  /* Function prototypes */
VOID cleanup(int );
VOID fail(STRPTR);

struct GfxBase *GfxBase = NULL;

/*  Construct a simple display.  These are global to make freeing easier.   */
struct View view, *oldview=NULL;  /*  Pointer to old View we can restore it.*/
struct ViewPort viewPort = { 0 };
struct BitMap bitMap = { 0 };
struct ColorMap *cm=NULL;

struct ViewExtra *vextra=NULL;      /* Extended structures used in Release 2 */
struct MonitorSpec *monspec=NULL;
struct ViewPortExtra *vpextra=NULL;
struct DimensionInfo dimquery = { 0 };

UBYTE *displaymem = NULL;     /*  Pointer for writing to BitMap memory.  */

#define BLACK 0x000           /*  RGB values for the four colors used.   */
#define RED   0xf00
#define GREEN 0x0f0
#define BLUE  0x00f

/*
 * main():  create a custom display; works under either 1.3 or Release 2
 */
VOID main(VOID)
{
WORD depth, box;
struct RasInfo rasInfo;
ULONG modeID;

struct TagItem vcTags[] =
{
    {VTAG_ATTACH_CM_SET, NULL },
    {VTAG_VIEWPORTEXTRA_SET, NULL },
    {VTAG_NORMAL_DISP_SET, NULL },
    {VTAG_END_CM, NULL }
};

/*  Offsets in BitMap where boxes will be drawn.  */
static SHORT boxoffsets[] = { 802, 2010, 3218 };

static UWORD colortable[] = { BLACK, RED, GREEN, BLUE };

/* Open the graphics library */
GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 33L);
if(GfxBase == NULL)
    fail("Could not open graphics library\n");

/*  Example steals screen from Intuition if Intuition is around.      */
oldview = GfxBase->ActiView;   /* Save current View to restore later. */

InitView(&view);           /*  Initialize the View and set View.Modes.     */
view.Modes |= LACE;        /*  This is the old 1.3 way (only LACE counts). */

if(GfxBase->LibNode.lib_Version >= 36)
    {
    /* Form the ModeID from values in <displayinfo.h> */
    modeID=DEFAULT_MONITOR_ID | HIRESLACE_KEY;

    /*  Make the ViewExtra structure   */
    if( vextra=GfxNew(VIEW_EXTRA_TYPE) )
        {
        /* Attach the ViewExtra to the View */
        GfxAssociate(&view , vextra);
        view.Modes |= EXTEND_VSTRUCT;

        /* Create and attach a MonitorSpec to the ViewExtra */
        if( monspec=OpenMonitor(NULL,modeID) )
            vextra->Monitor=monspec;
        else
            fail("Could not get MonitorSpec\n");
        }
     else fail("Could not get ViewExtra\n");
     }


/*  Initialize the BitMap for RasInfo.  */
InitBitMap(&bitMap, DEPTH, WIDTH, HEIGHT);

/* Set the plane pointers to NULL so the cleanup routine */
/* will know if they were used.                          */
for(depth=0; depth<DEPTH; depth++)
    bitMap.Planes[depth] = NULL;

/*  Allocate space for BitMap.             */
for (depth=0; depth<DEPTH; depth++)
    {
    bitMap.Planes[depth] = (PLANEPTR)AllocRaster(WIDTH, HEIGHT);
    if (bitMap.Planes[depth] == NULL)
        fail("Could not get BitPlanes\n");
    }

rasInfo.BitMap = &bitMap;       /*  Initialize the RasInfo.  */
rasInfo.RxOffset = 0;
rasInfo.RyOffset = 0;
rasInfo.Next = NULL;

InitVPort(&viewPort);           /*  Initialize the ViewPort.  */
view.ViewPort = &viewPort;      /*  Link the ViewPort into the View.  */
viewPort.RasInfo = &rasInfo;
viewPort.DWidth = WIDTH;
viewPort.DHeight = HEIGHT;

/* Set the display mode the old-fashioned way */
viewPort.Modes=HIRES | LACE;

if(GfxBase->LibNode.lib_Version >= 36)
{
    /* Make a ViewPortExtra and get ready to attach it */
    if( vpextra = GfxNew(VIEWPORT_EXTRA_TYPE) )
        {
        vcTags[1].ti_Data = (ULONG) vpextra;

        /* Initialize the DisplayClip field of the ViewPortExtra */
        if( GetDisplayInfoData( NULL , (UBYTE *) &dimquery ,
                                sizeof(dimquery) , DTAG_DIMS, modeID) )
            {
            vpextra->DisplayClip = dimquery.Nominal;

            /* Make a DisplayInfo and get ready to attach it */
            if( !(vcTags[2].ti_Data = (ULONG) FindDisplayInfo(modeID)) )
                fail("Could not get DisplayInfo\n");
             }
        else fail("Could not get DimensionInfo \n");
        }
    else fail("Could not get ViewPortExtra\n");

    /* This is for backwards compatibility with, for example,   */
    /* a 1.3 screen saver utility that looks at the Modes field */
    viewPort.Modes = (UWORD) (modeID & 0x0000ffff);
    }

/*  Initialize the ColorMap.  */
/*  2 planes deep, so 4 entries (2 raised to the #_planes power).  */
cm = GetColorMap(4L);
if(cm == NULL)
    fail("Could not get ColorMap\n");

if(GfxBase->LibNode.lib_Version >= 36)
    {
    /* Get ready to attach the ColorMap, Release 2-style */
    vcTags[0].ti_Data = (ULONG) &viewPort;

    /* Attach the color map and Release 2 extended structures */
    if( VideoControl(cm,vcTags) )
        fail("Could not attach extended structures\n");
    }
else
    /* Attach the ColorMap, old 1.3-style */
    viewPort.ColorMap = cm;

LoadRGB4(&viewPort, colortable, 4);  /* Change colors to those in colortable. */

MakeVPort( &view, &viewPort ); /* Construct preliminary Copper instruction list.    */

/* Merge preliminary lists into a real Copper list in the View structure. */
MrgCop( &view );

/* Clear the ViewPort */
for(depth=0; depth<DEPTH; depth++)
    {
    displaymem = (UBYTE *)bitMap.Planes[depth];
    BltClear(displaymem, (bitMap.BytesPerRow * bitMap.Rows), 1L);
    }

LoadView(&view);

/*  Now fill some boxes so that user can see something.          */
/*  Always draw into both planes to assure true colors.          */
for (box=1; box<=3; box++)  /* Three boxes; red, green and blue. */
    {
    for (depth=0; depth<DEPTH; depth++)        /*  Two planes.   */
        {
        displaymem = bitMap.Planes[depth] + boxoffsets[box-1];
        drawFilledBox(box, depth);
        }
    }

Delay(10L * TICKS_PER_SECOND);   /*  Pause for 10 seconds.                */
LoadView(oldview);               /*  Put back the old View.               */
WaitTOF();                       /*  Wait until the the View is being     */
                                 /*    rendered to free memory.           */
FreeCprList(view.LOFCprList);    /*  Deallocate the hardware Copper list  */
if(view.SHFCprList)              /*    created by MrgCop().  Since this   */
    FreeCprList(view.SHFCprList);/*    is interlace, also check for a     */
                                 /*    short frame copper list to free.   */
FreeVPortCopLists(&viewPort);    /*  Free all intermediate Copper lists   */
                                 /*    from created by MakeVPort().       */
cleanup(RETURN_OK);              /*  Success.                             */
}


/*
 * fail():  print the error string and call cleanup() to exit
 */
void fail(STRPTR errorstring)
{
printf(errorstring);
cleanup(RETURN_FAIL);
}

/*
 * cleanup():  free everything that was allocated.
 */
VOID cleanup(int returncode)
{
WORD depth;

/*  Free the color map created by GetColorMap().  */
if(cm) FreeColorMap(cm);

/* Free the ViewPortExtra created by GfxNew() */
if(vpextra) GfxFree(vpextra);

/*  Free the BitPlanes drawing area.  */
for(depth=0; depth<DEPTH; depth++)
    {
    if (bitMap.Planes[depth])
        FreeRaster(bitMap.Planes[depth], WIDTH, HEIGHT);
    }

/* Free the MonitorSpec created with OpenMonitor() */
if(monspec) CloseMonitor( monspec );

/* Free the ViewExtra created with GfxNew() */
if(vextra) GfxFree(vextra);

/* Close the graphics library */
CloseLibrary((struct Library *)GfxBase);

exit(returncode);
}


/*
 * drawFilledBox(): create a WIDTH/2 by HEIGHT/2 box of color
 *                  "fillcolor" into the given plane.
 */
VOID drawFilledBox(WORD fillcolor, WORD plane)
{
UBYTE value;
WORD boxHeight, boxWidth, width;

/*  Divide (WIDTH/2) by eight because each UBYTE that */
/* is written stuffs eight bits into the BitMap.      */
boxWidth = (WIDTH/2)/8;
boxHeight = HEIGHT/2;

value = ((fillcolor & (1 << plane)) != 0) ?  0xff : 0x00;

for( ; boxHeight; boxHeight--)
    {
    for(width=0 ; width < boxWidth; width++)
        *displaymem++ = value;

    displaymem += (bitMap.BytesPerRow - boxWidth);
    }
}
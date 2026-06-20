;/*  collide.c - An example of collision detection between objects and between the border.
If EXISTS animtools.c
	LC -b1 -cfist -v -j73 animtools.c  ;  Create AnimTools object file
Else
	Echo "Requires animtools.c (which isn't here) in order to compile."
	Quit
EndIf
LC -b1 -cfist -v -j73 collide.c
Blink FROM LIB:c.o,animtools.o,collide.o TO collide LIBRARY LIB:LC.lib,LIB:Amiga.lib
Quit ;


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
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <graphics/gels.h>
#include <graphics/collide.h>
#include <exec/memory.h>
#include <libraries/dos.h>

#include "animtools.h"
#include "animtools_proto.h"

#include <stdlib.h>
#include <stdio.h>

int CXBRK(void) { return(0); }

/* prototypes for functions in this file */
VOID __stdargs __saveds hit_routine(struct VSprite *vs1,struct VSprite *vs2);
VOID __stdargs __saveds bounceWall(struct VSprite *vs1,LONG borderflags);
struct AnimOb *setupBoing(SHORT dbufing);
VOID runAnimation(struct Window *win, SHORT dbufing,
	              struct AnimOb **animKey, struct BitMap **myBitMaps);
LONG setupPlanes(struct BitMap *bitMap, LONG depth, LONG width, LONG height);
struct BitMap **setupBitMaps(LONG depth, LONG width, LONG height);
VOID freePlanes(struct BitMap *bitMap, LONG depth, LONG width, LONG height);
VOID freeBitMaps(struct BitMap **myBitMaps,
	                LONG depth, LONG width, LONG height);
struct GelsInfo *setupDisplay(struct Window **win, SHORT dbufing,
	                          struct BitMap **myBitMaps);
VOID drawGels(struct Window *win, struct AnimOb **animKey,
	          SHORT dbufing, WORD *toggleFrame, struct BitMap **myBitMaps);

#define RBMWIDTH  320
#define RBMHEIGHT 200
#define RBMDEPTH    4

struct NewScreen ns =
	{
	0, 0, 320, 200, 2, 0, 1, NULL,
	CUSTOMSCREEN, NULL, "Collision With AnimObs", NULL, NULL
	};
struct NewWindow nw =
	{
	50, 50, 220, 100, -1, -1, CLOSEWINDOW,
	WINDOWCLOSE | RMBTRAP, NULL, NULL, "Close Window to Stop", NULL,
	NULL, 150, 100, 150, 100, CUSTOMSCREEN
	};

struct IntuitionBase *IntuitionBase = NULL;
struct GfxBase       *GfxBase       = NULL;

int return_code;

/* these give the number of frames (COUNT), size (HEIGHT, WIDTH, DEPTH),
** and word width (WWIDTH) of the animated object.
*/
#define BOING_COUNT     6
#define BOING_HEIGHT    25
#define BOING_WIDTH     32
#define BOING_DEPTH      1
#define BOING_WWIDTH    ((BOING_WIDTH + 15) / 16)

/* these are the IDs for the system to use for the three objects.
** these numbers will be used for the collision detection system.
**
** Do not use zero (0), as it is reserved by the collision system
** for border hits (see graphics/collide.h, BORDERHIT.)
*/
#define BOING_1     2
#define BOING_2     3
#define BOING_3     4

/* these are the number of counts that each frame is displayed.
** they are all one, so each frame is displayed once then the
** animation system will move on to the next in the sequence
*/
SHORT boing3Times[BOING_COUNT] = { 1, 1, 1, 1, 1, 1 };

/* these are all set to zero as we do not want anything added
** to the X and Y positions using ring motion control.
** all movement is done using the acceleration and velocity
** values.
*/
SHORT boing3YTranses[BOING_COUNT] = { 0, 0, 0, 0, 0, 0 };
SHORT boing3XTranses[BOING_COUNT] = { 0, 0, 0, 0, 0, 0 };

/* no special routines to call when each anim comp is displayed */
WORD (*boing3CRoutines[BOING_COUNT])(struct AnimComp *) =
	{ NULL, NULL, NULL, NULL, NULL, NULL };

UWORD __chip boing3Image[BOING_COUNT][BOING_WWIDTH * BOING_HEIGHT * BOING_DEPTH]
=
	{
	/*----- bitmap Boing, frame 0:  w = 32, h = 25 ------ */
	    {
	    0x0023, 0x0000,  0x004E, 0x3000,  0x00E3, 0x3A00,  0x03C3, 0xC900,
	    0x0787, 0x8780,  0x108F, 0x8700,  0x31F7, 0x8790,  0x61F0, 0x4790,
	    0x63E0, 0xFB90,  0x43E0, 0xF848,  0x3BC0, 0xF870,  0x3801, 0xF870,
	    0x383D, 0xF070,  0x387E, 0x1070,  0x387C, 0x0EE0,  0xD87C, 0x1F10,
	    0x467C, 0x1E10,  0x479C, 0x1E30,  0x6787, 0x3E20,  0x0787, 0xCC60,
	    0x0F0F, 0x8700,  0x048F, 0x0E00,  0x0277, 0x1C00,  0x0161, 0xD800,
	    0x0027, 0x2000,
	    },
	/*----- bitmap Boing, frame 1:  w = 32, h = 25 ------ */
	    {
	    0x0031, 0x8000,  0x0107, 0x1800,  0x00F0, 0x1900,  0x09E1, 0xEC80,
	    0x13C1, 0xE340,  0x1803, 0xE380,  0x387B, 0xC390,  0x30F8, 0x01D0,
	    0x70F8, 0x3DC0,  0xE1F0, 0x3E08,  0x9DF0, 0x7C30,  0x9E30, 0x7C30,
	    0x9E1C, 0x7C30,  0x1C1F, 0x9C30,  0x1C1F, 0x0630,  0x7C1F, 0x0780,
	    0x623F, 0x0798,  0x63DE, 0x0F10,  0x23C1, 0x0F20,  0x33C3, 0xEE20,
	    0x0BC3, 0xC380,  0x0647, 0xC700,  0x023F, 0x8E00,  0x0130, 0xF800,
	    0x0033, 0x8000,
	    },
	/*----- bitmap Boing, frame 2:  w = 32, h = 25 ------ */
	    {
	    0x0019, 0xC000,  0x0103, 0x8800,  0x0278, 0x8D00,  0x0CF0, 0xFE80,
	    0x11F0, 0xF140,  0x0E60, 0xF1E0,  0x1C39, 0xF0C0,  0x1C3E, 0x30C0,
	    0x387E, 0x0CE0,  0xF87C, 0x1F28,  0x8C7C, 0x1F18,  0x8F3C, 0x1F18,
	    0x8F06, 0x1E18,  0x8F07, 0xDE18,  0x8F07, 0xC018,  0x6E0F, 0xC1C0,
	    0x300F, 0x83C8,  0x31EF, 0x8390,  0x31F0, 0x8780,  0x11E0, 0xF720,
	    0x11E1, 0xF1C0,  0x0B61, 0xE300,  0x071B, 0xC600,  0x0138, 0x6C00,
	    0x0031, 0x8000,
	    },
	/*----- bitmap Boing, frame 3:  w = 32, h = 25 ------ */
	    {
	    0x001C, 0xE000,  0x01B1, 0xCC00,  0x031C, 0xC500,  0x0C3C, 0x3680,
	    0x1878, 0x7840,  0x2F70, 0x78E0,  0x0E08, 0x7860,  0x1E0F, 0xB860,
	    0x1C1F, 0x0460,  0xBC1F, 0x07B0,  0xC43F, 0x0788,  0xC7FE, 0x0788,
	    0xC7C0, 0x0F88,  0xC781, 0xEF88,  0xC783, 0xF118,  0x2783, 0xE0E8,
	    0x3983, 0xE1E0,  0x3863, 0xE1C0,  0x1878, 0xC1C0,  0x3878, 0x3380,
	    0x10F0, 0x78C0,  0x0B70, 0xF180,  0x0588, 0xE200,  0x009E, 0x2400,
	    0x0018, 0xC000,
	    },
	/*----- bitmap Boing, frame 4:  w = 32, h = 25 ------ */
	    {
	    0x000E, 0x6000,  0x00F8, 0xE400,  0x030F, 0xE600,  0x061E, 0x1300,
	    0x0C3E, 0x1C80,  0x27FC, 0x1C60,  0x0784, 0x3C60,  0x4F07, 0xFE20,
	    0x8F07, 0xC230,  0x1E0F, 0xC1F0,  0x620F, 0x83C8,  0x61CF, 0x83C8,
	    0x61E1, 0x83C8,  0x63E0, 0x63C8,  0x63E0, 0xF9C8,  0x03E0, 0xF878,
	    0x1DC0, 0xF860,  0x1C21, 0xF0E0,  0x5C3E, 0xF0C0,  0x0C3C, 0x11C0,
	    0x143C, 0x3C40,  0x09B8, 0x3880,  0x05C0, 0x7000,  0x00CF, 0x0400,
	    0x000C, 0x6000,
	    },
	/*----- bitmap Boing, frame 5:  w = 32, h = 25 ------ */
	    {
	    0x0026, 0x2000,  0x00FC, 0x7400,  0x0187, 0x7200,  0x030F, 0x0100,
	    0x0E0F, 0x0E80,  0x319F, 0x0E00,  0x23C6, 0x0F30,  0x63C1, 0xCF30,
	    0x4781, 0xF310,  0x0783, 0xE0D0,  0x7383, 0xE0E0,  0x70C3, 0xE0E0,
	    0x70F9, 0xE1E0,  0x70F8, 0x21E0,  0x70F8, 0x3FE0,  0x91F0, 0x3E38,
	    0x4FF0, 0x7C30,  0x4E10, 0x7C60,  0x4E0F, 0x7860,  0x2E1F, 0x08C0,
	    0x0E1E, 0x0E00,  0x049E, 0x1C80,  0x00E4, 0x3800,  0x00C7, 0x9000,
	    0x000E, 0x6000,
	    }
	};

/* these structures contain the initialization data for the animation
** sequence.
*/
NEWBOB newBoingBob =
	{
	NULL, BOING_WWIDTH, BOING_HEIGHT, BOING_DEPTH, 0x2, 0x0,
	SAVEBACK | OVERLAY, 0, RBMDEPTH, 0,0,0,0,
	};
NEWANIMSEQ newBoingSeq =
	{
	NULL, (WORD *)boing3Image, boing3XTranses, boing3YTranses,
	boing3Times, boing3CRoutines, 0, BOING_COUNT, 0,
	};

/*-------------------------------------------------------------------------
** setupBoing()
**
** make a new animation object.  since all of the boing balls use the same
** underlying data, the initalization structures are hard-coded into the
** routine (newBoingBob and newBoingSeq.)
**
** return a pointer to the object if successful, NULL if failure.
** set a global error code on failure.
*/
struct AnimOb *setupBoing(SHORT dbufing)
{
struct AnimOb   *bngOb;
struct AnimComp *bngComp;

if (NULL != (bngOb = AllocMem((LONG)sizeof(struct AnimOb), MEMF_CLEAR)))
	{
	newBoingBob.nb_DBuf    = dbufing;     /* double-buffer status  */
	newBoingSeq.nas_HeadOb = bngOb;       /* pass down head object */

	if (NULL != (bngComp = makeSeq(&newBoingBob, &newBoingSeq)))
	    {
	    bngOb->HeadComp = bngComp;  /* the head comp is the one that */
	                                /* is returned by makeSeq()      */
	    return(bngOb);
	    }
	FreeMem(bngOb, (LONG)sizeof(struct AnimOb));
	}
return_code = RETURN_WARN;
return(NULL);
}

/*-------------------------------------------------------------------------
** runAnimation()
**
** a simple message handling loop that also draws the successive frames.
*/
VOID runAnimation(struct Window *win, SHORT dbufing,
	              struct AnimOb **animKey, struct BitMap **myBitMaps)
{
struct IntuiMessage  *intuiMsg;
WORD toggleFrame;

/* toggleFrame is used to keep track of which frame of the double buffered
** screen we are currently displaying.  the variable must exist for the life
** of the displayed objects, so it is defined here.
*/
toggleFrame = 0;

/* end the loop on a CLOSEWINDOW event */
for (;;)
	{
	/* draw the gels, then check for messages.
	** check the messages after each display so we get a quick response.
	*/
	drawGels(win, animKey, dbufing, &toggleFrame, myBitMaps);

	/* quit on a control_c */
	if (SetSignal(0L,0L) & SIGBREAKF_CTRL_C)
	    return;

	/* check for a closewindow event, die if found */
	while (intuiMsg = (struct IntuiMessage *)GetMsg(win->UserPort))
	    {
	    if (intuiMsg->Class == CLOSEWINDOW)
	        {
	        ReplyMsg((struct Message *)intuiMsg);
	        return;
	        }
	    ReplyMsg((struct Message *)intuiMsg);
	    }
	}
}

/*-------------------------------------------------------------------------
** setupPlanes()
**
** called only for double-buffered displays.
** allocate and clear each bit-plane in a bitmap structure.
** clean-up on failure.
*/
LONG setupPlanes(struct BitMap *bitMap, LONG depth, LONG width, LONG height)
{
SHORT plane_num ;

for (plane_num = 0; plane_num < depth; plane_num++)
	{
	if (NULL != (bitMap->Planes[plane_num] =
	                (PLANEPTR)AllocRaster(width, height)))
	    BltClear((APTR)(bitMap->Planes[plane_num]), (width / 8) * height, 1);
	else
	    {
	    freePlanes(bitMap, depth, width, height);
	    return_code = RETURN_WARN;
	    return(NULL);
	    }
	}
return(TRUE);
}

/*-------------------------------------------------------------------------
** setupBitMaps()
**
** allocate the two bitmaps for a double-buffered display.
** routine only called when the display is double-buffered.
*/
struct BitMap **setupBitMaps(LONG depth, LONG width, LONG height)
{
static struct BitMap *myBitMaps[2];

/* allocate the two bit-map structures. these do not have to be in CHIP */
if (NULL != (myBitMaps[0] =
	    (struct BitMap *)AllocMem((LONG)sizeof(struct BitMap), MEMF_CLEAR)))
	{
	if (NULL != (myBitMaps[1] =
	    (struct BitMap *)AllocMem((LONG)sizeof(struct BitMap), MEMF_CLEAR)))
	    {
	    /* initialize the bit maps to the correct size. */
	    InitBitMap(myBitMaps[0], (BYTE)depth, (SHORT)width, (SHORT)height);
	    InitBitMap(myBitMaps[1], (BYTE)depth, (SHORT)width, (SHORT)height);

	    /* allocate and initialize the bit-planes for the bit-maps. */
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
/* on failure, everything is freed and a global return code is set. */
return_code = RETURN_WARN;
return(NULL);
}

/*-------------------------------------------------------------------------
** freePlanes()
**
** free all of the bit-planes in a bit-map structure.
*/
VOID freePlanes(struct BitMap *bitMap, LONG depth, LONG width, LONG height)
{
SHORT plane_num ;

for (plane_num = 0; plane_num < depth; plane_num++)
	{
	if (NULL != bitMap->Planes[plane_num])
	    FreeRaster(bitMap->Planes[plane_num], (USHORT)width, (USHORT)height);
	}
}

/*-------------------------------------------------------------------------
** freeBitMaps()
**
** free the two bit-maps from the double buffered display.
** the bit-planes are freed first, then the bit-map structures.
*/
VOID freeBitMaps(struct BitMap **myBitMaps, LONG depth, LONG width, LONG height)
{
freePlanes(myBitMaps[0], depth, width, height);
freePlanes(myBitMaps[1], depth, width, height);

FreeMem(myBitMaps[0], (LONG)sizeof(struct BitMap));
FreeMem(myBitMaps[1], (LONG)sizeof(struct BitMap));
}

/*-------------------------------------------------------------------------
** setupDisplay()
**
** open the screen and the window for the display.
**
** if using double buffered display, assume the bit-maps have been opened
** and correctly set-up.
*/
struct GelsInfo *setupDisplay(struct Window **win, SHORT dbufing,
	                          struct BitMap **myBitMaps)
{
struct GelsInfo    *gInfo;
struct Screen      *screen;

/* if double-buffered, set-up the new screen structure for custom bit map */
if (dbufing)
	{
	ns.Type |= CUSTOMBITMAP;
	ns.CustomBitMap = myBitMaps[0];
	}

/* open everything.  check for failure. */
if ((screen = (struct Screen *)OpenScreen(&ns)) != NULL)
	{
	nw.Screen = screen;
	if ((*win = (struct Window *)OpenWindow(&nw)) != NULL)
	    {
	    if (dbufing)
	        {
	        /* we are double buffered.  set the rastport for it. */
	        (*win)->WScreen->RastPort.Flags = DBUFFER;

	        /* this copies the intuition display (close gadget) to the
	        ** second bit-map so the display does not flash when we change
	        ** between them.
	        */
	        (*win)->WScreen->RastPort.BitMap = myBitMaps[1];
	        BltBitMapRastPort(myBitMaps[0], 0,0, &(*win)->WScreen->RastPort,
	                    0,0, RBMWIDTH, RBMHEIGHT, 0xC0);
	        (*win)->WScreen->RastPort.BitMap = myBitMaps[0];
	        }

	    /* ready the gel system for accepting objects
	    ** this is only done once for each rastport in use.
	    */
	    if (NULL != (gInfo = setupGelSys(&(*win)->WScreen->RastPort, 0x03)))
	        return(gInfo);

	    CloseWindow(*win);
	    }
	CloseScreen(screen);
	}
/* on an error everything is cleaned-up, and a global return code is set. */
return_code = RETURN_WARN;
return(NULL);
}

/*-------------------------------------------------------------------------
** drawGels()
**
** handle the update of the display.  Animate the simulation and check for
** collisions.  If the screen is double buffered, swap the bit map as
** required.
*/
VOID drawGels(struct Window *win, struct AnimOb **animKey, SHORT dbufing,
	          WORD *toggleFrame, struct BitMap **myBitMaps)
{
/* do the required animation stuff.  you must sort both after the animate
** call and after the collision call.
*/
Animate((struct AnimOb **)animKey, &win->WScreen->RastPort);
SortGList(&win->WScreen->RastPort);

DoCollision(&win->WScreen->RastPort);
SortGList(&win->WScreen->RastPort);

/* toggle if double buffered */
if (dbufing)
	win->WScreen->ViewPort.RasInfo->BitMap = myBitMaps[*toggleFrame];

/* draw the new position of the gels into the screen. */
DrawGList(&win->WScreen->RastPort, &win->WScreen->ViewPort);

/* if using a double buffered display, you have a more complicated
** update procedure.
**
** if not, then simply use WaitTOF().
*/
if (dbufing)
	{
	MakeScreen(win->WScreen);
	RethinkDisplay();

	*toggleFrame ^= 1;
	win->WScreen->RastPort.BitMap = myBitMaps[*toggleFrame];
	}
else
	WaitTOF();
}

/*-------------------------------------------------------------------------
** bounceWall()
**
** handle bouncing the animation objects off of the walls.
**
** use __stdargs and __saveds because this routine is not directly called
** by this program.  The call to DoCollision() causes a call back to
** this routine when an animation object comes in contact with a wall.
** __stdargs says the arguments are passed on the stack.
** __saveds says to restore the data segment pointer on entry to the routine.
*/
VOID __stdargs __saveds bounceWall(struct VSprite *vs1,LONG borderflags)
{
struct AnimOb *ob;

/* get a pointer to the object from the sprite pointer. */
ob = vs1->VSBob->BobComp->HeadOb;

/* check for hits and act apropriately.
** for right and left, reverse the x velocity if the object is moving
** towards the wall (it may have already reversed but still be in contact
** with the wall.)
** for the bottom and top you also have to subtract out the velocity.
*/
if (((borderflags & RIGHTHIT) && (ob->XVel > 0)) ||
	((borderflags & LEFTHIT) && (ob->XVel < 0)))
	ob->XVel = -(ob->XVel);
else if (((borderflags & TOPHIT) && (ob->YVel < 0)) ||
	     ((borderflags & BOTTOMHIT) && (ob->YVel > 0)))
	{
	ob->YVel -= ob->YAccel;
	ob->YVel = -(ob->YVel);
	}
}

/*-------------------------------------------------------------------------
** hit_routine()
**
** handle the collision between two animation objects.
** this routine simulates objects bouncing off of each other.
** this does not do a very good job of it, it does not take into account
** the angle of the collision or real physics.
** if anyone wants to fix it, please feel free.
**
** use __stdargs and __saveds because this routine is not directly called
** by this program.  The call to DoCollision() causes a call back to
** this routine when two animation objects overlap.
** __stdargs says the arguments are passed on the stack.
** __saveds says to restore the data segment pointer on entry to the routine.
*/
VOID __stdargs __saveds hit_routine(struct VSprite *vs1,struct VSprite *vs2)
{
LONG vel1, vel2;

/* check that the bob is not being removed!  This is due to a 1.3 bug
** where all bobs are tested for collision, even the ones that are in
** the process of being removed.  See text for more information.
**
** bobs are moved to a very large negative position as they are being
** removed.  if the BOBSAWAY flag is set, then both bobs in the collision
** are in the process of being removed--don't do anything in the collision
** routine.
*/
if (!(vs1->VSBob->Flags & BOBSAWAY))
	{
	/* cache the velocity values
	** Do the X values first (order is not important.)
	*/
	vel1 = vs1->VSBob->BobComp->HeadOb->XVel;
	vel2 = vs2->VSBob->BobComp->HeadOb->XVel;

	/* if the two objects are moving in the opposite direction (X component)
	** then negate the velocities.
	** else swap the velocities.
	*/
	if (((vel1 > 0) && (vel2 < 0)) || ((vel1 < 0) && (vel2 > 0)))
	    {
	    vs1->VSBob->BobComp->HeadOb->XVel = -vel1;
	    vs2->VSBob->BobComp->HeadOb->XVel = -vel2;
	    }
	else
	    {
	    vs1->VSBob->BobComp->HeadOb->XVel = vel2;
	    vs2->VSBob->BobComp->HeadOb->XVel = vel1;
	    }

	/* cache the velocity values
	** Do the Y values second (order is not important.)
	*/
	vel1 = vs1->VSBob->BobComp->HeadOb->YVel;
	vel2 = vs2->VSBob->BobComp->HeadOb->YVel;

	/* if the two objects are moving in the opposite direction (Y component)
	** then negate the velocities.
	** else swap the velocities.
	*/
	if (((vel1 > 0) && (vel2 < 0)) || ((vel1 < 0) && (vel2 > 0)))
	    {
	    vs1->VSBob->BobComp->HeadOb->YVel = -vel1;
	    vs2->VSBob->BobComp->HeadOb->YVel = -vel2;
	    }
	else
	    {
	    vs1->VSBob->BobComp->HeadOb->YVel = vel2;
	    vs2->VSBob->BobComp->HeadOb->YVel = vel1;
	    }
	}
}

/*-------------------------------------------------------------------------
** main routine
**
** run a double buffered display if the user puts any arguments on the
** command line.
**
** open libraries, set-up the display, set-up the animation system and
** the objects, set-up collisions between objects and against walls,
** and run the thing.
**
** clean-up and close resources when done.
*/
VOID main(int argc, char **argv)
{
struct BitMap   **myBitMaps;
struct AnimOb    *boingOb;
struct AnimOb    *boing2Ob;
struct AnimOb    *boing3Ob;
struct Window    *win;
struct Screen    *screen;
struct GelsInfo  *gInfo;
struct AnimOb    *animKey;
SHORT dbufing;

return_code = RETURN_OK;

/* if any arguments, use double-buffering */
if (argc > 1)
	dbufing = 1;
else
	{
	dbufing = 0;
	if (argc)
		printf("Program will run double buffered if there are\nany command line arguments.\n");
	}


/* open required libraries */
if (NULL == (IntuitionBase = (struct IntuitionBase *)
	    OpenLibrary(INTUITIONNAME, 34L)))
	return_code = RETURN_FAIL;
else
	{
	if (NULL == (GfxBase = (struct GfxBase *)
	        OpenLibrary(GRAPHICSNAME, 34L)))
	    return_code = RETURN_FAIL;
	else
	    {
	    /* note that setupBitMaps() will only be called if
	    ** we are double buffering
	    */
	    if ((!dbufing) ||
	        (NULL != (myBitMaps=setupBitMaps(RBMDEPTH,RBMWIDTH,RBMHEIGHT))))
	        {
	        if (NULL != (gInfo = setupDisplay(&win,dbufing,myBitMaps)))
	            {
	            /* you have to initialize the animation key
	            ** before you use it.
	            */
	            InitAnimate(&animKey);

	            /* set-up the first boing ball.
	            ** all of these use the same data, hard coded into setupBoing().
	            ** change the color by changing PlanePick.
	            ** set the ID of the ball (MeMask) to BOING_1.
	            ** HitMask = 0xFF means that it will collide with everything.
	             */
	            newBoingBob.nb_PlanePick = 0x2;
	            newBoingBob.nb_MeMask    = 1L<<BOING_1;
	            newBoingBob.nb_HitMask   = 0xFF;
	            if (NULL != (boingOb = setupBoing(dbufing)))
	                {
	                /* pick an initial position, velocity and acceleration
	                ** and add the object to the system.  NOTE that the
	                ** Y-velocity and X-acceleration are not set (they default
	                ** to zero.)  This means that the objects will maintain
	                ** a constant movement to the left or right, and will
	                ** rely on the Y accelleration for the downward movement.
	                ** The collision routines change these values, producing
	                ** bouncing off of walls and other objects.
	                **
	                ** NOTE:  ANFRACSIZE is a value that shifts animation
	                ** constants past an internal decimal point.  If you
	                ** do not do this, then the values will only be some
	                ** fraction of what you expect.  See the text of the
	                ** Animation chapter.
	                */
	                boingOb->AnY    = 10 << ANFRACSIZE;
	                boingOb->AnX    = 250 << ANFRACSIZE;
	                boingOb->XVel   = -(3 << ANFRACSIZE);
	                boingOb->YAccel = 35;
	                AddAnimOb(boingOb, (APTR)&animKey,
	                            &win->WScreen->RastPort);

	                /* do the second object--see above comments. */
	                newBoingBob.nb_PlanePick = 0x1;
	                newBoingBob.nb_MeMask    = 1L<<BOING_2;
	                newBoingBob.nb_HitMask   = 0xFF;
	                if (NULL != (boing2Ob = setupBoing(dbufing)))
	                    {
	                    boing2Ob->AnY    = 50 << ANFRACSIZE;
	                    boing2Ob->AnX    = 50 << ANFRACSIZE;
	                    boing2Ob->XVel   = 2 << ANFRACSIZE;
	                    boing2Ob->YAccel = 35;
	                    AddAnimOb(boing2Ob, (APTR)&animKey,
	                            &win->WScreen->RastPort);

	                    /* do the second object--see above comments.
	                    ** here we also use PlaneOnOff to change the color.
	                    */
	                    newBoingBob.nb_PlanePick = 0x1;
	                    newBoingBob.nb_PlaneOnOff= 0x2;
	                    newBoingBob.nb_MeMask    = 1L<<BOING_3;
	                    newBoingBob.nb_HitMask   = 0xFF;
	                    if (NULL != (boing3Ob = setupBoing(dbufing)))
	                        {
	                        boing3Ob->AnY    = 80 << ANFRACSIZE;
	                        boing3Ob->AnX    = 150<< ANFRACSIZE;
	                        boing3Ob->XVel   = 1 << ANFRACSIZE;
	                        boing3Ob->YAccel = 35;
	                        AddAnimOb(boing3Ob, (APTR)&animKey,
	                                &win->WScreen->RastPort);

	                        /* set up the collisions between boing balls.
	                        ** NOTE that they all call the same routine.
	                        */
	                        SetCollision(BOING_1,hit_routine,gInfo);
	                        SetCollision(BOING_2,hit_routine,gInfo);
	                        SetCollision(BOING_3,hit_routine,gInfo);

	                        /* set the collisions with the walls. */
	                        SetCollision(BORDERHIT,
                                             (VOID(*)(struct VSprite *, APTR))bounceWall,
                                             gInfo);

	                        /* everything set-up...run the animation. */
	                        runAnimation(win, dbufing, &animKey, myBitMaps);

	                        /* done...
	                        ** free-up everything and clean up the mess.
	                         */
	                        freeOb(boing3Ob, RBMDEPTH);
	                        }
	                    freeOb(boing2Ob, RBMDEPTH);
	                    }
	                freeOb(boingOb, RBMDEPTH);
	                }

	            cleanupGelSys(gInfo, &win->WScreen->RastPort);
	            screen = win->WScreen;
	            CloseWindow(win);
	            CloseScreen(screen);
	            }

	        if (dbufing)
	            freeBitMaps(myBitMaps, RBMDEPTH, RBMWIDTH, RBMHEIGHT);
	        }
	    CloseLibrary((struct Library *)GfxBase);
	    }
	CloseLibrary((struct Library *)IntuitionBase);
	}

/* return the global return code to the system. */
exit(return_code);
}


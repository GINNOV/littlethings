;/*  WBClone.c: To clone the Workbench using graphics calls
LC -b1 -cfist -v -j73 WBClone.c
Blink FROM LIB:c.o,WBClone.o TO WBClone LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
#include <exec/exec.h>
#include <clib/exec_protos.h>
#include <intuition/screens.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <clib/intuition_protos.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <graphics/view.h>
#include <graphics/gfxnodes.h>
#include <graphics/videocontrol.h>
#include <clib/graphics_protos.h>

#include <stdio.h>
#include <stdlib.h>

#define INTUITIONNAME "intuition.library"

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif


/*********************************************************************/
/*                            GLOBAL VARIABLES                       */
/*********************************************************************/

struct IntuitionBase *IntuitionBase = NULL ;
struct GfxBase *GfxBase = NULL ;

/**********************************************************************/
/*                                                                    */
/* VOID Error (char *String)                                          */
/*                                                                    */
/* Print string and exit                                              */
/*                                                                    */
/**********************************************************************/

VOID Error (char *String)
{
	VOID CloseAll (VOID) ;

	printf (String) ;

	CloseAll () ;
	exit(0) ;
}


/**********************************************************************/
/*                                                                    */
/* VOID Init ()                                                       */
/*                                                                    */
/* Opens all the required libraries allocates all memory, etc.        */
/*                                                                    */
/**********************************************************************/

VOID Init ( VOID )
{
	/* Open the intuition library.... */
	if ((IntuitionBase = (struct IntuitionBase *)OpenLibrary (INTUITIONNAME, 37L)) == NULL)
		Error ("Could not open the Intuition.library") ;

	/* Open the graphics library.... */
	if ((GfxBase = (struct GfxBase *)OpenLibrary (GRAPHICSNAME, 37L)) == NULL)
		Error ("Could not open the Graphics.library") ;
}

/**********************************************************************/
/*                                                                    */
/* VOID CloseAll ()                                                   */
/*                                                                    */
/* Closes and tidies up everything that was used.                     */
/*                                                                    */
/**********************************************************************/

VOID CloseAll ( VOID )
{
	/* Close everything in the reverse order in which they were opened */

	/* Close the Graphics Library */
	if (GfxBase)
		CloseLibrary ((struct Library *) GfxBase) ;

	/* Close the Intuition Library */
	if (IntuitionBase)
		CloseLibrary ((struct Library *) IntuitionBase) ;
}
/**********************************************************************/
/*                                                                    */
/* VOID DestroyView(struct View *view)                                */
/*                                                                    */
/* Close and free everything to do with the View                      */
/*                                                                    */
/**********************************************************************/

VOID DestroyView(struct View *view)
{
	struct ViewExtra *ve;

	if (view)
	{
		if (ve = (struct ViewExtra *)GfxLookUp(view))
		{
			if (ve->Monitor)
				CloseMonitor(ve->Monitor);

			GfxFree((struct ExtendedNode *)ve);
		}

		/* Free up the copper lists */
		if (view->LOFCprList)
			FreeCprList(view->LOFCprList);

		if (view->SHFCprList)
			FreeCprList(view->SHFCprList);

		FreeVec(view);
	}
}

/**********************************************************************/
/*                                                                    */
/* struct View *DupView(struct View *v, ULONG ModeID)                 */
/*                                                                    */
/* Duplicate the View.                                                */
/*                                                                    */
/**********************************************************************/

struct View *DupView(struct View *v, ULONG ModeID)
{
	/* Allocate and init a View structure.  Also, get a ViewExtra
	 * structure and attach the monitor type to the View.
	 */

	struct View *view = NULL;
	struct ViewExtra *ve = NULL;
	struct MonitorSpec *mspc = NULL;

	if (view = AllocVec(sizeof(struct View), MEMF_PUBLIC | MEMF_CLEAR))
	{
		if (ve = GfxNew(VIEW_EXTRA_TYPE))
		{
			if (mspc = OpenMonitor(NULL, ModeID))
			{
				InitView(view);
				view->DyOffset = v->DyOffset;
				view->DxOffset = v->DxOffset;
				view->Modes = v->Modes;
				GfxAssociate(view, (struct ExtendedNode *)ve);
				ve->Monitor = mspc;
			}
			else printf("Could not open monitor\n");
		}
		else printf("Could not get ViewExtra\n");
	}
	else printf("Could not create View\n");

	if (view && ve && mspc)
		return(view);
	else
	{
		DestroyView(view);
		return(NULL);
	}
}


/**********************************************************************/
/*                                                                    */
/* VOID DestroyViewPort(struct ViewPort *vp)                          */
/*                                                                    */
/* Close and free everything to do with the ViewPort.                 */
/*                                                                    */
/**********************************************************************/

VOID DestroyViewPort(struct ViewPort *vp)
{
	if (vp)
	{
		/* Find the ViewPort's ColorMap. From that use VideoControl
		 *  to get the ViewPortExtra, and free it.
		 * Then free the ColorMap, and finally the ViewPort itself.
		 */
		struct ColorMap *cm = vp->ColorMap;
		struct TagItem ti[] =
		{
			{VTAG_VIEWPORTEXTRA_GET, NULL},	/* <-- This field will be filled in */
			{VTAG_END_CM, NULL}
		};

		if (cm)
		{
			if (VideoControl(cm, ti) == NULL)
				GfxFree((struct ExtendedNode *)ti[0].ti_Data);
			else
				printf("VideoControl error in DestroyViewPort()\n");

			FreeColorMap(cm);
		}
		else
		{
			printf("Could not free the ColorMap\n");
		}

		FreeVPortCopLists(vp);

		FreeVec(vp);
	}
}

/**********************************************************************/
/*                                                                    */
/* struct ViewPort *DupViewPort(struct ViewPort *vp, ULONG ModeID)    */
/*                                                                    */
/* Duplicate the ViewPort.                                            */
/*                                                                    */
/**********************************************************************/

struct ViewPort *DupViewPort(struct ViewPort *vp, ULONG ModeID)
{
	/* Allocate and initialise a ViewPort. Copy the ViewPort width and
	 * heights, offsets, and modes values.  Allocate and initialize a
	 * ColorMap.
	 *
	 * Also, allocate a ViewPortExtra, and copy the TextOScan values of the
	 * ModeID from the database into the ViewPortExtra.
	 */

	#define COLOURS 32
	struct ViewPort *Myvp;
	struct ViewPortExtra *vpe;
	struct ColorMap *cm;
	struct TagItem ti[] = 			/* to attach everything */
	{
		{VTAG_ATTACH_CM_SET, NULL},	/* these NULLs will be replaced in the code */
		{VTAG_VIEWPORTEXTRA_SET, NULL},
		{VTAG_NORMAL_DISP_SET, NULL},
		{VTAG_END_CM, NULL}
	};
	struct DimensionInfo query = {0};
	UWORD colour;
	int c;
	ULONG gotinfo = NULL;

	if (Myvp = AllocVec(sizeof(struct ViewPort), MEMF_CLEAR | MEMF_PUBLIC))
	{
		if (vpe = (struct ViewPortExtra *)GfxNew(VIEWPORT_EXTRA_TYPE))
		{
			if (cm = GetColorMap(32))
			{
				if (gotinfo = GetDisplayInfoData(NULL, (APTR)&query,
                                                                 sizeof(query), DTAG_DIMS, ModeID))
				{
					InitVPort(Myvp);

					/* duplicate the ViewPort structure */
					Myvp->DWidth = vp->DWidth;
					Myvp->DHeight = vp->DHeight;
					Myvp->DxOffset = vp->DxOffset;
					Myvp->DyOffset = vp->DyOffset;
					Myvp->Modes = vp->Modes;
					Myvp->SpritePriorities = vp->SpritePriorities;
					Myvp->ExtendedModes = vp->ExtendedModes;

					/* duplicate the Overscan values */
					vpe->DisplayClip = query.TxtOScan;

					/* attach everything together */
					ti[0].ti_Data = (ULONG)Myvp;
					ti[1].ti_Data = (ULONG)vpe;
					ti[2].ti_Data = (ULONG)FindDisplayInfo(ModeID);
					if (VideoControl(cm, ti) != NULL)
					{
						printf("VideoControl error in CreateViewPort()\n");
					}

					/* copy the colours from the workbench */
					for (c = 0; c < COLOURS; c++)
					{
						if ((colour = GetRGB4(vp->ColorMap, c)) != -1)
						{
						SetRGB4CM(cm, c, (colour >> 8),
							  ((colour >> 4) & 0xf), (colour & 0xf));
						}
					}
				}
				else printf("Database error\n");
			}
			else printf("Could not get the ColorMap\n");
		}
		else printf("Could not get the ViewPortExtra\n");
	}
	else printf("Could not get the ViewPort\n");

	if (Myvp && vpe && cm && gotinfo)
		return(Myvp);
	else
	{
		DestroyViewPort(vp);
		return(NULL);
	}
}


/***********************************************************************************/
/*                                                                                 */
/* VOID DestroyBitMap(struct BitMap *Mybm, SHORT width, SHORT height, SHORT depth) */
/*                                                                                 */
/* Close and free everything to do with the BitMap                                 */
/*                                                                                 */
/***********************************************************************************/

VOID DestroyBitMap(struct BitMap *Mybm, SHORT width, SHORT height, SHORT depth)
{
	int i;

	if (Mybm)
	{
		for (i = 0; (i < depth); i++)
		{
			if (Mybm->Planes[i])
				FreeRaster(Mybm->Planes[i], width, height);
		}
		FreeVec(Mybm);
	}
}


/***********************************************************************/
/*                                                                     */
/* struct BitMap *CreateBitMap(SHORT width, SHORT height, SHORT depth) */
/*                                                                     */
/* Create the BitMap.                                                  */
/*                                                                     */
/***********************************************************************/

struct BitMap *CreateBitMap(SHORT width, SHORT height, SHORT depth)
{
	/* Allocate a BitMap structure, initialise it, and allocate each plane. */

	struct BitMap *Mybm;
	PLANEPTR allocated = (PLANEPTR) 1;
	int i;

	if (Mybm = AllocVec(sizeof(struct BitMap), MEMF_CLEAR | MEMF_PUBLIC))
	{
		InitBitMap(Mybm, depth, width, height);
		for (i = 0; ((i < depth) && (allocated)); i++)
			allocated = (Mybm->Planes[i] = AllocRaster(width, height));

		if (allocated == NULL)
		{
			printf("Could not allocate all the planes\n");
			DestroyBitMap(Mybm, width, height, depth);
			Mybm = NULL;
		}
	}
	else printf("Could not get BitMap\n");

	return(Mybm);
}

/********************************************************************************/
/*                                                                              */
/* VOID ShowView(struct View *view, struct ViewPort *vp, struct BitMap *bm,    */
/*                                                SHORT width, SHORT height)    */
/*                                                                              */
/* Assemble and display the View.                                               */
/*                                                                              */
/********************************************************************************/

VOID ShowView(struct View *view, struct ViewPort *vp, struct BitMap *bm,
                                               SHORT width, SHORT height)
{
	/* Attach the BitMap to the ViewPort via a RasInfo.  Attach the ViewPort
	 * to the View.  Clear the BitMap, and draw into it by attaching the BitMap
	 * to a RastPort.  Then MakeVPort(), MrgCop() and LoadView().
	 * Just wait for the user to press <RETURN> before returning.
	 */

	struct RastPort *rp;
	struct RasInfo *ri;

	if (rp = AllocVec(sizeof(struct RastPort), MEMF_CLEAR | MEMF_PUBLIC))
	{
		if (ri = AllocVec(sizeof(struct RasInfo), MEMF_CLEAR | MEMF_PUBLIC))
		{
			InitRastPort(rp);
			ri->BitMap = rp->BitMap = bm;
			vp->RasInfo = ri;
			view->ViewPort = vp;

			/* render */
			SetRast(rp, 0);		/* clear the background */
			SetAPen(rp, ((1 << bm->Depth) - 1));	/* use the last pen */
			Move(rp, 0, 0);
			Draw(rp, width, 0);
			Draw(rp, width, height);
			Draw(rp, 0, height);
			Draw(rp, 0, 0);

			/* display it */
			MakeVPort(view, vp);
			MrgCop(view);
			LoadView(view);

			getchar();

			/* bring back the system */
			RethinkDisplay();

			FreeVec(ri);
		}
		else printf("Could not get RasInfo\n");

		FreeVec(rp);
	}
	else printf("Could not get RastPort\n");

}


/**********************************************************************/
/*                                                                    */
/* VOID main (int argc, char *argv[])                                 */
/*                                                                    */
/* Clone the Workbench View using Graphics Library calls.             */
/*                                                                    */
/**********************************************************************/

VOID main (int argc, char *argv[])
{
	struct Screen *wb;
	struct View *Myview;
	struct ViewPort *Myvp;
	struct BitMap *Mybm;
	ULONG ModeID;
	ULONG IbaseLock;

	Init () ;		/* to open the libraries */

	/* To clone the Workbench using graphics calls involves duplicating
	 * the Workbench ViewPort, ViewPort mode, and Intuition's View.
	 * This also involves duplicating the DisplayClip for the overscan
	 * value, the colours, and the View position.
	 *
	 * When this is all done, the View, ViewPort, ColorMap and BitMap
	 * (and ViewPortExtra, ViewExtra and RasInfo) all have to be linked
	 * together, and the copperlists made to create the display.
	 *
	 * This is not as difficult as it sounds (trust me!)
	 */

	/* First, lock the Workbench screen, so no changes can be made to it
	 * while we are duplicating it.
	 */
	if (wb = LockPubScreen("Workbench"))
	{
		/* Find the Workbench's ModeID. This is a 32-bit number that
		 * identifies the monitor type, and the display mode of that monitor.
		 */
		ModeID = GetVPModeID(&wb->ViewPort);

		/* We need to duplicate Intuition's View structure, so lock IntuitionBase
		 * to prevent the View changing under our feet.
		 */
		IbaseLock = LockIBase(0);
		if (Myview = DupView(&IntuitionBase->ViewLord, ModeID))
		{
			/* The View has been cloned, so we don't need to keep it locked. */
			UnlockIBase(IbaseLock);

			/* Now duplicate the Workbench's ViewPort. Remember, we still have
			 * the Workbench locked.
			 */
			if (Myvp = DupViewPort(&wb->ViewPort, ModeID))
			{
				/* Create a BitMap to render into. This will be of the
				 * same dimensions as the Workbench.
				 */
				if (Mybm = CreateBitMap(wb->Width, wb->Height, wb->BitMap.Depth))
				{
					/* Now we have everything copied, show something */
					ShowView(Myview, Myvp, Mybm, wb->Width-1, wb->Height-1);

					/* Now free up everything we have allocated */
					DestroyBitMap(Mybm, wb->Width, wb->Height, wb->BitMap.Depth);
				}
				DestroyViewPort(Myvp);
			}
			DestroyView(Myview);
		}
		else
		{
			UnlockIBase(IbaseLock);
		}
		UnlockPubScreen(NULL, wb);
	}
	CloseAll () ;
}

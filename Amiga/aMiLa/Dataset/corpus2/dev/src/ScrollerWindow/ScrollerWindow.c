/*
****************************************************************************
**
**  $VER: scrollerwindow.c 0.3 (11.6.94)
**
**  Example code which shows how to correctly create a screen resolution
**  sensitive window with scrollbars and arrows.
**
**  Write *ADPAPTIVE* software!  Get *RID* of hard coded values!
**
****************************************************************************
**
**  Copyright © 1994 Christoph Feck, TowerSystems.  You may use methods
**  and code provided in this example in executables for Commodore-Amiga
**  computers.  All other rights reserved.
**
**  For questions and suggestions contact me via email at:
**  feck@informatik.uni-kl.de
**
**  NOTE:  This file is provided "AS-IS" and subject to change without
**  prior notice; no warranties are made.  All use is at your own risk.
**  No liability or responsibility is assumed.
**
****************************************************************************
**
**  Compilation notes:
**
**  - Needs V39 or newer includes and amiga.lib (Fred Fish CD or CATS NDK).
**  - This has to be compiled with stack checking off!
**  - HOOK/A0/A1/A2 needs to be changed, if you don't compile with SAS/C.
**
****************************************************************************
**
**  Sorry if this got too complex, you may also look at older versions :)
**
**  Changes:
**  - gadgetclass doesn't fail on NULL GA_Previous (sorry)
**    (reported by Hartmut Goebel).
**  - closed intuition.library and graphics.library in wrong order
**    (reported by Dave Eaves).
**  - added IDCMP_SIZEVERIFY
**  - GM_LAYOUT for scrollbars (V39)
**  - better buttongclass with delay
**    (suggested by Mark Rose).
**  - no-op backfill hook
**  - keyboard control
**  0.2:
**  - oops!  forgot ReplyMsg()
**  - added input processing
**  - visible based on window size
**  - scrolls the screen in the window :)
**
**  Todo:
**  - drag scrolling
**  - perhaps a picture datatype instead of a cloned screen bitmap?
**  - make it a model
**  - your suggestions/questions
**
****************************************************************************
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <intuition/intuition.h>
#include <intuition/imageclass.h>
#include <intuition/icclass.h>
#include <intuition/gadgetclass.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/utility.h>


/***************************************************************************
 *
 *  Pepo's peculiarities.
 *
 ***************************************************************************
 */

#define NEW(type) ((type *) AllocMem(sizeof(type), MEMF_CLEAR | MEMF_PUBLIC))
#define DISPOSE(stuff) (FreeMem(stuff, sizeof(*stuff)))

#ifndef IM
#define IM(o) ((struct Image *) o)
#endif

#ifndef GAD
#define GAD(o) ((struct Gadget *) o)
#endif

#ifndef MAX
#define MAX(x,y) ((x) > (y) ? (x) : (y))
#endif
#ifndef MIN
#define MIN(x,y) ((x) < (y) ? (x) : (y))
#endif

/* SAS/C specific */
#define HOOK __saveds __asm
#define A0(stuff) register __a0 stuff
#define A1(stuff) register __a1 stuff
#define A2(stuff) register __a2 stuff


/***************************************************************************
 *
 *  Global variables.
 *
 ***************************************************************************
 */

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Library *UtilityBase;
struct Screen *screen;
struct DrawInfo *dri;
BOOL V39;

/* We define a subclass of propgclass so
 * we can overload the GM_LAYOUT method.
 */
Class *mypropgclass;

/* Our new buttongclass which handles a
 * small delay before the repeat starts,
 * and doesn't send a notification when the
 * button gets released.
 */
Class *mybuttongclass;

/* The bitmap we want to display */
struct BitMap *bitmap;

/* If TRUE, we can't draw into the window
 * (size verification).
 */
BOOL frozen = FALSE;


/***************************************************************************
 *
 *  V37 compatible BitMap functions.
 *
 ***************************************************************************
 */

struct BitMap *CreateBitMap(LONG width, LONG height, LONG depth, ULONG flags, struct BitMap *friend)
{
	struct BitMap *bm;

	if (V39)
	{
		bm = AllocBitMap(width, height, depth, flags, friend);
	}
	else
	{
		LONG memflags = MEMF_CHIP;

		if (bm = NEW(struct BitMap))
		{
			InitBitMap(bm, depth, width, height);
			if (flags & BMF_CLEAR) memflags |= MEMF_CLEAR;
			/* For simplicity, we allocate all planes in one big chunk */
			if (bm->Planes[0] = (PLANEPTR) AllocVec(depth * RASSIZE(width, height), memflags))
			{
				LONG i;

				for (i = 1; i < depth; i++)
				{
					bm->Planes[i] = bm->Planes[i - 1] + RASSIZE(width, height);
				}
			}
			else
			{
				DISPOSE(bm);
				bm = NULL;
			}
		}
	}
	return (bm);
}


VOID DeleteBitMap(struct BitMap *bm)
{
	if (bm)
	{
		if (V39)
		{
			FreeBitMap(bm);
		}
		else
		{
			FreeVec(bm->Planes[0]);
			DISPOSE(bm);
		}
	}
}


ULONG BitMapDepth(struct BitMap *bm)
{
	if (V39)
	{
		return (GetBitMapAttr(bm, BMA_DEPTH));
	}
	else
	{
		return (bm->Depth);
	}
}


/***************************************************************************
 *
 *  Calculates the basic size of the resolution.
 *
 ***************************************************************************
 */

int SysISize(VOID)
{
	return (screen->Flags & SCREENHIRES ? SYSISIZE_MEDRES : SYSISIZE_LOWRES);
/* NB: SYSISIZE_HIRES not yet supported. */
}


/***************************************************************************
 *
 *  Object creation stubs.
 *
 ***************************************************************************
 */

/* Creates a sysiclass object. */
Object *NewImageObject(ULONG which)
{
	return (NewObject(NULL, SYSICLASS,
	 SYSIA_DrawInfo, dri,
	 SYSIA_Which, which,
	 SYSIA_Size, SysISize(),
	TAG_DONE));
}


/* Creates an object or our propgclass. */
Object *NewPropObject(ULONG freedom, Tag tag1, ...)
{
	return (NewObject(mypropgclass, NULL,
	/* Send update to IDCMP.  If we make it a model, we would send the
	 * notification to our model object. */
	 ICA_TARGET, ICTARGET_IDCMP,
	 PGA_Freedom, freedom,
	 PGA_NewLook, TRUE,
	/* Borderless does only look right with newlook screens */
	 PGA_Borderless, ((dri->dri_Flags & DRIF_NEWLOOK) && dri->dri_Depth != 1),
	TAG_MORE, &tag1));
}


/* Creates an object of our buttongclass. */
Object *NewButtonObject(Object *image, Tag tag1, ...)
{
	return (NewObject(mybuttongclass, NULL,
	 ICA_TARGET, ICTARGET_IDCMP,
	 GA_Image, image,
	/* No need for GA_Width/Height.  buttongclass is smart :) */
	TAG_MORE, &tag1));
}


/***************************************************************************
 *
 *  Subclass of buttongclass.  The ROM class has two problems, which make
 *  it not quite usable for scrollarrows.  The first problem is the missing
 *  delay.  Once the next INTUITICK gets send by input.device, the ROM
 *  class already sends a notification.  The other problem is that it also
 *  notifies us, when the button finally gets released (which is necessary
 *  for command buttons).
 *
 *  We define a new class with the GM_GOACTIVE and GM_HANDLEINPUT method
 *  overloaded to work around these problems.
 *
 ***************************************************************************
 */

/* Per object instance data */
struct ButtonData
{
	/* The number of ticks we still have to wait
	 * before sending any notification.
	 */
	ULONG TickCounter;
};


/* tagcall stub for OM_NOTIFY */
VOID NotifyAttrChanges(Object *o, struct GadgetInfo *gi, ULONG flags, Tag attr1, ...)
{
	DoMethod(o, OM_NOTIFY, &attr1, gi, flags);
}


ULONG HandleMyButton(struct Gadget *gad, struct gpInput *gpi, struct ButtonData *bd)
{
	UWORD selected = 0;
	struct RastPort *rp;
	ULONG retval = GMR_MEACTIVE;

	/* This also works with classic (non-boopsi) images. */
	if (PointInImage((gpi->gpi_Mouse.X << 16) + (gpi->gpi_Mouse.Y), gad->GadgetRender))
	{
		/* We are hit */
		selected = GFLG_SELECTED;
	}
	if (gpi->gpi_IEvent->ie_Class == IECLASS_RAWMOUSE && gpi->gpi_IEvent->ie_Code == SELECTUP)
	{
		/* Gadgetup, time to go */
		retval = GMR_NOREUSE;
		/* Unselect the gadget on our way out... */
		selected = 0;
	}
	if (gpi->gpi_IEvent->ie_Class == IECLASS_TIMER)
	{
		/* We got a tick.  Decrement counter, and if 0, send notify. */
		if (selected && !(--bd->TickCounter))
		{
			bd->TickCounter = 1;
			NotifyAttrChanges((Object *) gad, gpi->gpi_GInfo, 0,
			 GA_ID, gad->GadgetID,
			TAG_DONE);
		}
	}
	if ((gad->Flags & GFLG_SELECTED) != selected)
	{
		/* Update changes in gadget render */
		gad->Flags ^= GFLG_SELECTED;
		if (rp = ObtainGIRPort(gpi->gpi_GInfo))
		{
			DoMethod((Object *) gad, GM_RENDER, gpi->gpi_GInfo, rp, GREDRAW_UPDATE);
			ReleaseGIRPort(rp);
		}
	}
	return (retval);
}


ULONG HOOK DispatchMyButtongClass(A0(Class *cl), A2(Object *o), A1(struct gpInput *gpi))
{
	struct ButtonData *bd = (struct ButtonData *) INST_DATA(cl, o);

	switch (gpi->MethodID)
	{
	case GM_GOACTIVE:
		/* May define an attribute to make delay configurable */
		bd->TickCounter = 4;
		/* Notify our target that we have initially hit. */
		NotifyAttrChanges(o, gpi->gpi_GInfo, 0,
		 GA_ID, GAD(o)->GadgetID,
		TAG_DONE);
		/* Send more input */
		return (GMR_MEACTIVE);
	case GM_HANDLEINPUT:
		return (HandleMyButton(GAD(o), gpi, bd));
	default:
		/* super class handles everything else */
		return (DoSuperMethodA(cl, o, (Msg) gpi));
	}
}


/***************************************************************************
 *
 *  Our scroller window.  This is not a boopsi object (yet?).
 *
 ***************************************************************************
 */

/* All gadgets and their IDs.
 * Note that we assume they get initialized to NULL.
 */
Object *horizgadget, *vertgadget;
Object *leftgadget, *rightgadget, *upgadget, *downgadget;

#define HORIZ_GID	1
#define VERT_GID	2
#define LEFT_GID	3
#define RIGHT_GID	4
#define UP_GID		5
#define DOWN_GID	6

struct Window *window;

/* These are the images we adapt our layout to. */
Object *sizeimage, *leftimage, *rightimage, *upimage, *downimage;

/* Cached model info */
LONG htotal;
LONG vtotal;
LONG hvisible;
LONG vvisible;

VOID OpenScrollerWindow(Tag tag1, ...)
{
	int resolution = SysISize();
	WORD topborder = screen->WBorTop + screen->Font->ta_YSize + 1;
	/* Do not use screen->BarHeight, which is the height of the
	 * screens bar, not the height of the windows title bar. */
	WORD w = IM(sizeimage)->Width;
	WORD h = IM(sizeimage)->Height;
	WORD bw = (resolution == SYSISIZE_LOWRES) ? 1 : 2;
	WORD bh = (resolution == SYSISIZE_HIRES) ? 2 : 1;
	WORD rw = (resolution == SYSISIZE_HIRES) ? 3 : 2;
	WORD rh = (resolution == SYSISIZE_HIRES) ? 2 : 1;
	WORD gw;
	WORD gh;
	WORD gap;

	gh = MAX(IM(leftimage)->Height, h);
	gh = MAX(IM(rightimage)->Height, gh);
	gw = MAX(IM(upimage)->Width, w);
	gw = MAX(IM(downimage)->Width, gw);

	/* If you have gadgets in the left window border, set 'gap' to the
	 * width of these gadgets. */
	gap = 1;

	horizgadget = NewPropObject(FREEHORIZ,
	 GA_Left, rw + gap,
	 GA_RelBottom, bh - gh + 2,
	 GA_RelWidth, -gw - gap - IM(leftimage)->Width - IM(rightimage)->Width - rw - rw,
	 GA_Height, gh - bh - bh - 2,
	 GA_BottomBorder, TRUE,
	 GA_ID, HORIZ_GID,
	 PGA_Total, htotal,
	 PGA_Visible, hvisible,
	TAG_DONE);
	if (!horizgadget) return;

	vertgadget = NewPropObject(FREEVERT,
	 GA_RelRight, bw - gw + 3,
	 GA_Top, topborder + rh,
	 GA_Width, gw - bw - bw - 4,
	 GA_RelHeight, -topborder - h - IM(upimage)->Height - IM(downimage)->Height - rh - rh,
	 GA_RightBorder, TRUE,
	 GA_Previous, horizgadget,
	 GA_ID, VERT_GID,
	 PGA_Total, vtotal,
	 PGA_Visible, vvisible,
	TAG_DONE);
	if (!vertgadget) return;

	leftgadget = NewButtonObject(leftimage,
	 GA_RelRight, 1 - IM(leftimage)->Width - IM(rightimage)->Width - gw,
	 GA_RelBottom, 1 - IM(leftimage)->Height,
	 GA_BottomBorder, TRUE,
	 GA_Previous, vertgadget,
	 GA_ID, LEFT_GID,
	TAG_DONE);
	if (!leftgadget) return;

	rightgadget = NewButtonObject(rightimage,
	 GA_RelRight, 1 - IM(rightimage)->Width - gw,
	 GA_RelBottom, 1 - IM(rightimage)->Height,
	 GA_BottomBorder, TRUE,
	 GA_Previous, leftgadget,
	 GA_ID, RIGHT_GID,
	TAG_DONE);
	if (!rightgadget) return;

	upgadget = NewButtonObject(upimage,
	 GA_RelRight, 1 - IM(upimage)->Width,
	 GA_RelBottom, 1 - IM(upimage)->Height - IM(downimage)->Height - h,
	 GA_RightBorder, TRUE,
	 GA_Previous, rightgadget,
	 GA_ID, UP_GID,
	TAG_DONE);
	if (!upgadget) return;

	downgadget = NewButtonObject(downimage,
	 GA_RelRight, 1 - IM(downimage)->Width,
	 GA_RelBottom, 1 - IM(downimage)->Height - h,
	 GA_RightBorder, TRUE,
	 GA_Previous, upgadget,
	 GA_ID, DOWN_GID,
	TAG_DONE);
	if (!downgadget) return;

	window = OpenWindowTags(NULL,
	 WA_Gadgets, horizgadget,
	 WA_MinWidth, MAX(80, gw + gap + IM(leftimage)->Width + IM(rightimage)->Width + rw + rw + KNOBHMIN),
	 WA_MinHeight, MAX(50, topborder + h + IM(upimage)->Height + IM(downimage)->Height + rh + rh + KNOBVMIN),
	TAG_MORE, &tag1);
}


VOID CloseScrollerWindow(VOID)
{
	if (window) CloseWindow(window);
	DisposeObject(horizgadget);
	DisposeObject(vertgadget);
	DisposeObject(leftgadget);
	DisposeObject(rightgadget);
	DisposeObject(upgadget);
	DisposeObject(downgadget);
}


/***************************************************************************
 *
 *  Here we do all the stuff necessary to make it work properly.
 *
 ***************************************************************************
 */

/* Calculate visible region based on window size.
 *
 * Can't use global 'window' variable, because our layout
 * method calls this before OpenWindow() returns.
 *
 * GZZWidth/GZZHeight are the inner dimensions even for non GZZ windows.
 */

#define RecalcHVisible(window) (window->GZZWidth)
#define RecalcVVisible(window) (window->GZZHeight)


/* This is the dispatcher for our new propgclass.  The
 * idea behind this is to update the scrollbars to adapt
 * to the new window size BEFORE Intuition redraws
 * them.  This is visually attractive.
 *
 * The GM_LAYOUT method is also called when the window
 * opens.
 *
 * Note that GM_LAYOUT is a feature of Intuition V39 and up.
 * This dispatcher will do nothing for V37.
 */

ULONG HOOK DispatchMyPropgClass(A0(Class *cl), A2(Object *o), A1(struct gpLayout *gpl))
{
	if (gpl->MethodID == GM_LAYOUT)
	{
		struct Window *win = gpl->gpl_GInfo->gi_Window;
		struct PropInfo *pi = (struct PropInfo *) GAD(o)->SpecialInfo;
		LONG visible;

		/* Which one is it? */
		if (pi->Flags & FREEHORIZ)
		{
			hvisible = visible = RecalcHVisible(win);
		}
		else
		{
			vvisible = visible = RecalcVVisible(win);
		}
		/* Do not refresh yourself.  You will be called when it's time. */
		SetAttrs(o, PGA_Visible, visible, TAG_DONE);
		/* fall through */
	}
	/* super class handles everything else */
	return (DoSuperMethodA(cl, o, (Msg) gpl));
}


/* Copy our BitMap into the window */
VOID CopyBitMap(VOID)
{
	ULONG srcx, srcy;

	/* Do not render while in size verification */
	if (!frozen)
	{
		/* Get right place */
		GetAttr(PGA_Top, horizgadget, &srcx);
		GetAttr(PGA_Top, vertgadget, &srcy);
		BltBitMapRastPort(bitmap, srcx, srcy, window->RPort, window->BorderLeft, window->BorderTop, MIN(htotal, hvisible), MIN(vtotal, vvisible), 0xC0);
	}
}


VOID UpdateProp(Object *gadget, ULONG attr, LONG value)
{
	if (SetAttrs(gadget, attr, value, TAG_DONE))
	{
		struct PropInfo *pi = (struct PropInfo *) (GAD(gadget))->SpecialInfo;

		/* Use incremental update.  Avoids flashing.
		 * Seems like SetGadgetAttrs() does not recognize
		 * (direct) subclasses of propgclass :(
		 */
		NewModifyProp(GAD(gadget), window, NULL, pi->Flags, pi->HorizPot, pi->VertPot, pi->HorizBody, pi->VertBody, 1);
	}
}


VOID UpdateScrollerWindow(VOID)
{
	if (!V39)
	{
		/* Only needed for V37.  With V39, our
		 * layout method does the job.
		 */
		hvisible = RecalcHVisible(window);
		UpdateProp(horizgadget, PGA_Visible, hvisible);
		vvisible = RecalcVVisible(window);
		UpdateProp(vertgadget, PGA_Visible, vvisible);
	}
	CopyBitMap();
}


VOID ScrollerLeft(LONG amount)
{
	LONG oldtop;

	GetAttr(PGA_Top, horizgadget, (ULONG *) &oldtop);
	if (oldtop > 0)
	{
		UpdateProp(horizgadget, PGA_Top, MAX(0, oldtop - amount));
		CopyBitMap();
	}
}


VOID ScrollerRight(LONG amount)
{
	LONG oldtop;

	GetAttr(PGA_Top, horizgadget, (ULONG *) &oldtop);
	if (oldtop < htotal - hvisible)
	{
		UpdateProp(horizgadget, PGA_Top, MIN(htotal - hvisible, oldtop + amount));
		CopyBitMap();
	}
}


VOID ScrollerUp(LONG amount)
{
	LONG oldtop;

	GetAttr(PGA_Top, vertgadget, (ULONG *) &oldtop);
	if (oldtop > 0)
	{
		UpdateProp(vertgadget, PGA_Top, MAX(0, oldtop - amount));
		CopyBitMap();
	}
}


VOID ScrollerDown(LONG amount)
{
	LONG oldtop;

	GetAttr(PGA_Top, vertgadget, (ULONG *) &oldtop);
	if (oldtop < vtotal - vvisible)
	{
		UpdateProp(vertgadget, PGA_Top, MIN(vtotal - vvisible, oldtop + amount));
		CopyBitMap();
	}
}


/***************************************************************************
 *
 *  NO-OP backfilling hook.  Since we are going to redraw the whole window
 *  anyway, we can disable backfilling.  This avoids ugly flashing while
 *  resizing or revealing the window.
 *
 *  For V39, you could use WA_BackFill, LAYERS_NOBACKFILL to get the same
 *  effect.
 *
 ***************************************************************************
 */

ULONG HOOK BFHookFunc(VOID)
{
	/* Do nothing */
	return (1);
}


struct Hook BFHook =
{
	NULL, NULL,
	BFHookFunc,
};


/***************************************************************************
 *
 *  Main program and IDCMP handling.
 *
 ***************************************************************************
 */

#define QUAL_SHIFT	(IEQUALIFIER_LSHIFT | IEQUALIFIER_RSHIFT)
#define QUAL_ALT	(IEQUALIFIER_LALT | IEQUALIFIER_RALT)
#define QUAL_CTRL	(IEQUALIFIER_CONTROL)


VOID HandleRawKey(UWORD code, UWORD qual)
{
	switch (code)
	{
	case CURSORLEFT:
		if (qual & QUAL_CTRL)
		{
			/* total */
			ScrollerLeft(htotal);
		}
		else if (qual & QUAL_SHIFT)
		{
			/* visible (minus 1 for 'overlap' to match propgclass) */
			ScrollerLeft(hvisible - 1);
		}
		else if (qual & QUAL_ALT)
		{
			/* big step */
			ScrollerLeft(16);
		}
		else
		{
			/* small step */
			ScrollerLeft(1);
		}
		break;
	case CURSORRIGHT:
		if (qual & QUAL_CTRL) ScrollerRight(htotal);
		else if (qual & QUAL_SHIFT) ScrollerRight(hvisible - 1);
		else if (qual & QUAL_ALT) ScrollerRight(16);
		else ScrollerRight(1);
		break;
	case CURSORUP:
		if (qual & QUAL_CTRL) ScrollerUp(vtotal);
		else if (qual & QUAL_SHIFT) ScrollerUp(vvisible - 1);
		else if (qual & QUAL_ALT) ScrollerUp(16);
		else ScrollerUp(1);
		break;
	case CURSORDOWN:
		if (qual & QUAL_CTRL) ScrollerDown(vtotal);
		else if (qual & QUAL_SHIFT) ScrollerDown(vvisible - 1);
		else if (qual & QUAL_ALT) ScrollerDown(16);
		else ScrollerDown(1);
		break;
	default:
		break;
	}
}


VOID HandleIDCMPUpdate(struct TagItem *attrs)
{
	/* Maybe we want an 'Amount' attribute from our button. */
	LONG amount = 1;

	/* We are only interested in the ID of the involved gadget. */
	switch (GetTagData(GA_ID, 0, attrs))
	{
	case HORIZ_GID:
	case VERT_GID:
		CopyBitMap();
		break;
	case LEFT_GID:
		ScrollerLeft(amount);
		break;
	case RIGHT_GID:
		ScrollerRight(amount);
		break;
	case UP_GID:
		ScrollerUp(amount);
		break;
	case DOWN_GID:
		ScrollerDown(amount);
		break;
	default:
		break;
	}
}


VOID HandleScrollerWindow(VOID)
{
	struct IntuiMessage *imsg;
	BOOL quit = FALSE;

	while (!quit)
	{
		while (!quit && (imsg = (struct IntuiMessage *) GetMsg(window->UserPort)))
		{
			switch (imsg->Class)
			{
			case IDCMP_CLOSEWINDOW:
				quit = TRUE;
				break;
			case IDCMP_SIZEVERIFY:
				/* Do not draw until window has been resized. */
				frozen = TRUE;
				break;
			case IDCMP_NEWSIZE:
				frozen = FALSE;
				UpdateScrollerWindow();
				break;
			case IDCMP_REFRESHWINDOW:
				BeginRefresh(window);
				CopyBitMap();
				EndRefresh(window, TRUE);
				break;
			case IDCMP_VANILLAKEY:
				switch (imsg->Code)
				{
				case 'q':
				case 'Q':
				case 0x1B: /* ESC */
					quit = TRUE;
				default:
					break;
				}
				break;
			case IDCMP_RAWKEY:
				HandleRawKey(imsg->Code, imsg->Qualifier);
				break;
			case IDCMP_IDCMPUPDATE:
				/* IAddress is a pointer to a taglist with new attributes. */
				HandleIDCMPUpdate((struct TagItem *) imsg->IAddress);
				break;
			default:
				break;
			}
			ReplyMsg((struct Message *) imsg);
		}
		if (!quit) WaitPort(window->UserPort);
	}
}


VOID DoScrollerWindow(VOID)
{
	if (screen = LockPubScreen(NULL))
	{
		/* We clone the screen bitmap */
		hvisible = htotal = screen->Width;
		vvisible = vtotal = screen->Height;
		if (bitmap = CreateBitMap(htotal, vtotal, BitMapDepth(screen->RastPort.BitMap), 0, screen->RastPort.BitMap))
		{
			/* Copy it over */
			BltBitMap(screen->RastPort.BitMap, 0, 0, bitmap, 0, 0, htotal, vtotal, 0xC0, ~0, NULL);
			if (dri = GetScreenDrawInfo(screen))
			{
				sizeimage = NewImageObject(SIZEIMAGE);
				leftimage = NewImageObject(LEFTIMAGE);
				rightimage = NewImageObject(RIGHTIMAGE);
				upimage = NewImageObject(UPIMAGE);
				downimage = NewImageObject(DOWNIMAGE);
				if (sizeimage && leftimage && rightimage && upimage && downimage)
				{
					OpenScrollerWindow(WA_PubScreen, screen,
					 WA_Title, "$VER: ScrollerWindow 0.3 (11.6.94)",
					 WA_Flags,
					 	WFLG_CLOSEGADGET |
					 	WFLG_SIZEGADGET |
					 	WFLG_DRAGBAR |
					 	WFLG_DEPTHGADGET |
					 	WFLG_SIMPLE_REFRESH |
					 	WFLG_ACTIVATE |
					 	WFLG_NEWLOOKMENUS,
					 WA_IDCMP,
					 	IDCMP_CLOSEWINDOW |
					 	IDCMP_NEWSIZE |
					 	IDCMP_SIZEVERIFY |
					 	IDCMP_REFRESHWINDOW |
					 	IDCMP_VANILLAKEY |
					 	IDCMP_RAWKEY |
					 	IDCMP_MOUSEMOVE |
					 	IDCMP_MOUSEBUTTONS |
					 	IDCMP_INTUITICKS |
					 	IDCMP_IDCMPUPDATE,
					 WA_InnerWidth, htotal,
					 WA_InnerHeight, vtotal,
					 /* Limit repeated keyboard events */
					 WA_RptQueue, 2,
					 WA_BackFill, &BFHook,
					 /* We must limit the maximum size to the current size
					  * since we can't EraseRect() outside of the bitmap
					  * (because we have a no-op backfill hook).
					  *
					  * This is not really critical for V37/V39, because
					  * the window can't get bigger than the screen.
					  * But future OS versions might have this feature.
					  */
					 WA_MaxWidth, 0,
					 WA_MaxHeight, 0,
					TAG_DONE);
					if (window)
					{
						UpdateScrollerWindow();
						HandleScrollerWindow();
					}
					CloseScrollerWindow();
				}
				DisposeObject(sizeimage);
				DisposeObject(leftimage);
				DisposeObject(rightimage);
				DisposeObject(upimage);
				DisposeObject(downimage);
				FreeScreenDrawInfo(screen, dri);
			}
			WaitBlit();
			DeleteBitMap(bitmap);
		}
		UnlockPubScreen(NULL, screen);
	}
}


/***************************************************************************
 *
 *  Startup.
 *
 ***************************************************************************
 */

void main(int argc, char *argv[])
{
	if (IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", 36))
	{
		/* Do we run V39? */
		V39 = ((struct Library *) IntuitionBase)->lib_Version >= 39;
		if (GfxBase = (struct GfxBase *) OpenLibrary("graphics.library", 36))
		{
			if (UtilityBase = OpenLibrary("utility.library", 36))
			{
				/* Here we create our new classes */
				if (mypropgclass = MakeClass(NULL, PROPGCLASS, NULL, 0, 0))
				{
					mypropgclass->cl_Dispatcher.h_Entry = (ULONG (*)()) DispatchMyPropgClass;
					if (mybuttongclass = MakeClass(NULL, BUTTONGCLASS, NULL, sizeof(struct ButtonData), 0))
					{
						mybuttongclass->cl_Dispatcher.h_Entry = (ULONG (*)()) DispatchMyButtongClass;
						DoScrollerWindow();
						FreeClass(mybuttongclass);
					}
					FreeClass(mypropgclass);
				}
				CloseLibrary(UtilityBase);
			}
			CloseLibrary((struct Library *) GfxBase);
		}
		CloseLibrary((struct Library *) IntuitionBase);
	}
}



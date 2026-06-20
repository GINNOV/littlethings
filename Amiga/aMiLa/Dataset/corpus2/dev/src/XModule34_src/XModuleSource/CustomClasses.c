/*
**	CustomClasses.c
**
**	Copyright (C) 1995 Bernardo Innocenti
**
**	Special custom BOOPSI classes.
*/


#include <exec/types.h>
#include <utility/tagitem.h>
#include <devices/inputevent.h>

#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/gadgetclass.h>
#include <intuition/imageclass.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/alib_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/utility_pragmas.h>

#include "XModule.h"
#include "CustomClasses.h"



/* Per object instance data */
struct ScrollButtonData
{
	/* The number of ticks we still have to wait
	 * before sending any notification.
	 */
	ULONG TickCounter;
};



/* Function prototypes */

static ULONG __asm __saveds ScrollButtonDispatcher (register __a0 Class *cl,
												register __a2 struct Gadget *g,
												register __a1 struct gpInput *gpi);
static void NotifyAttrChanges	(Object *o, struct GadgetInfo *gi, ULONG flags, Tag attr1, ...);
static void DrawPlayImage (struct RastPort *rp, UWORD width, UWORD heigth);
static void DrawStopImage (struct RastPort *rp, UWORD width, UWORD heigth);
static void DrawForwardImage (struct RastPort *rp, UWORD width, UWORD heigth);
static void DrawRewindImage (struct RastPort *rp, UWORD width, UWORD heigth);
static void DrawVImage (struct impDraw *imp, struct Image *im, struct BitMap *bm);



/* tagcall stub for OM_NOTIFY */
static void NotifyAttrChanges (Object *o, struct GadgetInfo *gi, ULONG flags, Tag attr1, ...)
{
	DoSuperMethod (OCLASS(o), o, OM_NOTIFY, &attr1, gi, flags);
}


/*
**	ScrollButtonClass
**
**	Parts of the code have been inspired by ScrollerWindow 0.3 demo
**	Copyright © 1994 Christoph Feck, TowerSystems.
**
**	Subclass of buttongclass.  The ROM class has two problems, which make
**	it not quite usable for scrollarrows.  The first problem is the missing
**	delay.  Once the next INTUITICK gets send by input.device, the ROM
**	class already sends a notification.  The other problem is that it also
**	notifies us, when the button finally gets released (which is necessary
**	for command buttons).
**
**	We define a new class with the GM_GOACTIVE and GM_HANDLEINPUT method
**	overloaded to work around these problems.
*/

static ULONG __asm __saveds ScrollButtonDispatcher (register __a0 Class *cl,
												register __a2 struct Gadget *g,
												register __a1 struct gpInput *gpi)
/* ScrollButton Class Dispatcher entrypoint.
 * Handle BOOPSI messages.
 */
{
	struct ScrollButtonData *bd = (struct ScrollButtonData *) INST_DATA(cl, g);

	switch (gpi->MethodID)
	{
		case GM_GOACTIVE:
			/* May define an attribute to make delay configurable */
			bd->TickCounter = 3;

			/* Notify our target that we have initially hit. */
			NotifyAttrChanges ((Object *)g, gpi->gpi_GInfo, 0,
				GA_ID, g->GadgetID,
				TAG_DONE);

			/* Send more input */
			return GMR_MEACTIVE;

		case GM_HANDLEINPUT:
		{
			struct RastPort *rp;
			ULONG retval = GMR_MEACTIVE;
			UWORD selected = 0;

			/* This also works with classic (non-boopsi) images. */
			if (PointInImage ((gpi->gpi_Mouse.X << 16) + (gpi->gpi_Mouse.Y), g->GadgetRender))
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
			else if (gpi->gpi_IEvent->ie_Class == IECLASS_TIMER)
			{
				/* We got a tick.  Decrement counter, and if 0, send notify. */

				if (bd->TickCounter) bd->TickCounter--;
				else if (selected)
				{
					NotifyAttrChanges ((Object *) g, gpi->gpi_GInfo, 0,
						GA_ID, g->GadgetID,
						TAG_DONE);
				}
			}

			if ((g->Flags & GFLG_SELECTED) != selected)
			{
				/* Update changes in gadget render */
				g->Flags ^= GFLG_SELECTED;
				if (rp = ObtainGIRPort (gpi->gpi_GInfo))
				{
					DoMethod ((Object *) g, GM_RENDER, gpi->gpi_GInfo, rp, GREDRAW_UPDATE);
					ReleaseGIRPort (rp);
				}
			}
			return retval;
		}

		default:
			/* Super class handles everything else */
			return (DoSuperMethodA (cl, (Object *)g, (Msg) gpi));
	}
}



Class *InitScrollButtonClass (void)
{
	Class *class;

	if (class = MakeClass (NULL, BUTTONGCLASS, NULL, sizeof(struct ScrollButtonData), 0))
		class->cl_Dispatcher.h_Entry = (ULONG (*)()) ScrollButtonDispatcher;

	return class;
}



BOOL FreeScrollButtonClass (Class *cl)
{
	return (FreeClass (cl));
}



static ULONG __asm __saveds VImageDispatcher (register __a0 Class *cl,
												register __a2 struct Image *im,
												register __a1 struct opSet *ops)
/* VImage Class Dispatcher entrypoint.
 * Handle BOOPSI messages.
 */
{
	switch (ops->MethodID)
	{
		case OM_NEW:

			/* Create the image structure */
			if (im = (struct Image *)DoSuperMethodA (cl, (Object *)im, (Msg) ops))
			{
				ULONG			 which;
				struct RastPort	 rp;
//				struct DrawInfo *dri;

//				dri = (struct DrawInfo *)GetTagData (GA_DrawInfo, NULL, ops->ops_AttrList);
				which = GetTagData (SYSIA_Which, 0, ops->ops_AttrList);

				InitRastPort (&rp);

				if (Kick30)
					rp.BitMap = AllocBitMap (im->Width, im->Height, 1, BMF_CLEAR, NULL);
				else
				{
					if (rp.BitMap = AllocMem (sizeof (struct BitMap), MEMF_PUBLIC))
					{
						InitBitMap (rp.BitMap, 1, im->Width, im->Height);
						if (!(rp.BitMap->Planes[0] = AllocMem (RASSIZE(im->Width, im->Height), MEMF_CHIP | MEMF_CLEAR)));
						{
							FreeMem (rp.BitMap, sizeof (struct BitMap));
							rp.BitMap = NULL;
						}
					}
				}

				if (rp.BitMap)
				{
					PLANEPTR		planeptr;
					struct TmpRas	tmpras;
					struct AreaInfo	areainfo;
					WORD			areabuffer[(5 * 8 + 1) / 2];

					if (planeptr = AllocRaster (im->Width, im->Height))
					{
						InitTmpRas (&tmpras, planeptr, RASSIZE(im->Width, im->Height));
						InitArea (&areainfo, areabuffer, 8);
						SetAPen (&rp, 1);
						rp.TmpRas = &tmpras;
						rp.AreaInfo = &areainfo;

						switch (which)
						{
							case IM_PLAY:
								DrawPlayImage (&rp, im->Width, im->Height);
								break;

							case IM_STOP:
								DrawStopImage (&rp, im->Width, im->Height);
								break;

							case IM_FWD:
								DrawForwardImage (&rp, im->Width, im->Height);
								break;

							case IM_REW:
								DrawRewindImage (&rp, im->Width, im->Height);
								break;
						}

						FreeRaster (planeptr, im->Width, im->Height);
					}
					/* Failing to allocate the TmpRas will cause the
					 * image to be blank, but no error will be
					 * reported.
					 */

					/* Store the BitMap pointer here for later usage */
					im->ImageData = (UWORD *)rp.BitMap;

					return (ULONG)im;	/* Return new image object */
				}

				DisposeObject (im);
			}

			return NULL;

		case IM_DRAW:
		case IM_DRAWFRAME:
			DrawVImage ((struct impDraw *)ops, im, (struct BitMap *)im->ImageData);
			break;

		case OM_DISPOSE:

			if (Kick30)
				FreeBitMap ((struct BitMap *)im->ImageData);
			else
			{
				FreeMem (((struct BitMap *)im->ImageData)->Planes[0], RASSIZE(im->Width, im->Height));
				FreeMem (((struct BitMap *)im->ImageData), sizeof (struct BitMap));
			}

			/* Now let our superclass free it's istance */
			/* Note: I'm falling through here! */

		default:
			/* Super class handles everything else */
			return (DoSuperMethodA (cl, (Object *)im, (Msg) ops));
	}
}



Class *InitVImageClass (void)
{
	Class *class;

	if (class = MakeClass (NULL, IMAGECLASS, NULL, 0, 0))
		class->cl_Dispatcher.h_Entry = (ULONG (*)()) VImageDispatcher;

	return class;
}



BOOL FreeVImageClass (Class *cl)
{
	return (FreeClass (cl));
}



static void DrawPlayImage (struct RastPort *rp, UWORD width, UWORD height)
{
	UWORD	ymin = height / 4,
			ymax = (height * 3) / 4,
			ymid;

	ymin -= (ymax - ymin) & 1;	/* Force odd heigth for better arrow aspect */
	ymid = (ymin + ymax) / 2;

	RectFill (rp, 1, ymin, (width / 4) - 1, ymax);

	AreaMove (rp, width / 3, ymin);
	AreaDraw (rp, width - 2, ymid);
	AreaDraw (rp, width / 3, ymax);

	AreaEnd (rp);
}



static void DrawStopImage (struct RastPort *rp, UWORD width, UWORD height)
{
	RectFill (rp, width / 4, height / 4, (width * 3) / 4, (height * 3) / 4);
}



static void DrawForwardImage (struct RastPort *rp, UWORD width, UWORD height)
{
	UWORD	ymin = height / 4,
			ymax = (height * 3) / 4,
			ymid;

	ymin -= (ymax - ymin) & 1;	/* Force odd heigth for better arrow aspect */
	ymid = (ymin + ymax) / 2;

	AreaMove (rp, 1, ymin);
	AreaDraw (rp, width / 2, ymid);
	AreaDraw (rp, 1, ymax);

	AreaMove (rp, width / 2, ymin);
	AreaDraw (rp, width - 2, ymid);
	AreaDraw (rp, width / 2, ymax);

	AreaEnd (rp);
}



static void DrawRewindImage (struct RastPort *rp, UWORD width, UWORD height)
{
	UWORD	ymin = height / 4,
			ymax = (height * 3) / 4,
			ymid;

	ymin -= (ymax - ymin) & 1;	/* Force odd heigth for better arrow aspect */
	ymid = (ymin + ymax) / 2;

	AreaMove (rp, width - 2, ymin);
	AreaDraw (rp, width / 2, ymid);
	AreaDraw (rp, width - 2, ymax);

	AreaMove (rp, width / 2 - 1, ymin);
	AreaDraw (rp, 1, ymid);
	AreaDraw (rp, width / 2 - 1, ymax);

	AreaEnd (rp);
}



static void DrawVImage (struct impDraw *imp, struct Image *im, struct BitMap *bm)
{
	BltBitMapRastPort (bm, 0, 0, imp->imp_RPort,
		imp->imp_Offset.X, imp->imp_Offset.Y, im->Width, im->Height, 0x0C0);
}

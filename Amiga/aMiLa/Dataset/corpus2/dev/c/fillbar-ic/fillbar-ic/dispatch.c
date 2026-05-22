/* fillbar image
 * Copyright (c) 1997 Antonio Manuel Santos.
 *
 */

/*****************************************************************************/

#define	DB(x)	;

/*****************************************************************************/

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/imageclass.h>
#include <intuition/classusr.h>
#include <intuition/classes.h>
#include <intuition/cghooks.h>
#include <graphics/displayinfo.h>
#include <graphics/gfxmacros.h>
#include <images/fillbar.h>
#include <string.h>

#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/utility_protos.h>
#include <clib/macros.h>

#include <pragmas/exec_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/utility_pragmas.h>

#include "classbase.h"
#include "classdata.h"

/*****************************************************************************/

#define G(o)		((struct Gadget *)(o))
#define I(o)		((struct Image *)(o))

/*****************************************************************************/

#define setFlag(mask, bit, value)	{										\
										(mask) &= ~(1UL << (bit));			\
										if (value)							\
											(mask) |= (1UL << (bit));		\
									}

#define getFlag(mask, bit)			(((mask) & (1UL << (bit))) ? TRUE : FALSE)

/*****************************************************************************/

static STRPTR defaultLabelLeft = "  0%";
static STRPTR defaultLabelRight = "100%";

/*****************************************************************************/

static LONG setAttrsMethod (Class * cl, struct Image * im, struct opSet * msg, BOOL init)
{
	struct ClassLib *cb = (struct ClassLib *) cl->cl_UserData;
	struct objectData *od = INST_DATA (cl, im);
	struct TagItem *tags = msg->ops_AttrList;
	struct IBox lastBox;
	LONG refresh;

	if (init) {
		od->od_DrawInfo = NULL;
		od->od_ImageBox.Left = od->od_ImageBox.Top = od->od_ImageBox.Width = od->od_ImageBox.Height = 0;
		od->od_BGPen = -1;
		od->od_FGPen = -1;
		od->od_FillPen = -1;
		od->od_FrameAround = od->od_FrameInside = NULL;
		od->od_Flags = 0;
		od->od_AroundBox.Left = od->od_AroundBox.Top = od->od_AroundBox.Width = od->od_AroundBox.Height = 0;
		od->od_frameAroundBox.Left = od->od_frameAroundBox.Top = od->od_frameAroundBox.Width = od->od_frameAroundBox.Height = 0;
		od->od_InsideBox.Left = od->od_InsideBox.Top = od->od_InsideBox.Width = od->od_InsideBox.Height = 0;
		od->od_frameInsideBox.Left = od->od_frameInsideBox.Top = od->od_frameInsideBox.Width = od->od_frameInsideBox.Height = 0;
		od->od_SpaceX = od->od_SpaceY = 0;
		od->od_FillBox.Left = od->od_FillBox.Top = od->od_FillBox.Width = od->od_FillBox.Height = 0;
		setFlag (od->od_Flags, ODB_SIZEREFRESH, TRUE);
		
		refresh = 1;
	} else {
		/* Let the super class handle it first */
		refresh = DoSuperMethodA (cl, (Object *) im, msg);
	}
	
	/* -- check for tags -- */

	setFlag (od->od_Flags, ODB_FRAMEAROUND, GetTagData (FILLBAR_FrameAround, (ULONG) TRUE, tags));
	setFlag (od->od_Flags, ODB_FRAMEINSIDE, GetTagData (FILLBAR_FrameInside, (ULONG) TRUE, tags));
	setFlag (od->od_Flags, ODB_LABELLEFT,	GetTagData (FILLBAR_LabelLeft,	 (ULONG) TRUE, tags));
	setFlag (od->od_Flags, ODB_LABELRIGHT,	GetTagData (FILLBAR_LabelRight,	 (ULONG) TRUE, tags));
	setFlag (od->od_Flags, ODB_LABELINSIDE,	GetTagData (FILLBAR_LabelInside, (ULONG) TRUE, tags));
	
	od->od_Value = (WORD) GetTagData (FILLBAR_Value, (ULONG) 0, tags);
	
	lastBox = od->od_ImageBox;
	
	od->od_ImageBox.Left   = (WORD) GetTagData (IA_Left,   (ULONG) od->od_ImageBox.Left,   tags);
	od->od_ImageBox.Top    = (WORD) GetTagData (IA_Top,    (ULONG) od->od_ImageBox.Top,    tags);
	od->od_ImageBox.Width  = (WORD) GetTagData (IA_Width,  (ULONG) od->od_ImageBox.Width,  tags);
	od->od_ImageBox.Height = (WORD) GetTagData (IA_Height, (ULONG) od->od_ImageBox.Height, tags);
	
	if (!getFlag (od->od_Flags, ODB_SIZEREFRESH)) {
		if (lastBox.Left == od->od_ImageBox.Left &&
			lastBox.Top == od->od_ImageBox.Top &&
			lastBox.Width == od->od_ImageBox.Width &&
			lastBox.Height == od->od_ImageBox.Height) {
			setFlag (od->od_Flags, ODB_SIZEREFRESH, FALSE);
		} else {
			setFlag (od->od_Flags, ODB_SIZEREFRESH, TRUE);
		}
	}
	
	od->od_LabelLeftText = (STRPTR) GetTagData (FILLBAR_LabelLeftString, (ULONG) defaultLabelLeft, tags);
	od->od_LabelRightText = (STRPTR) GetTagData (FILLBAR_LabelRightString, (ULONG) defaultLabelRight, tags);
	
	/* -- drawinfo is really needed !! -- */
	if (od->od_DrawInfo = (struct DrawInfo *) GetTagData (SYSIA_DrawInfo, (ULONG) od->od_DrawInfo, tags)) {
		
		od->od_BGPen   = (LONG) GetTagData (FILLBAR_BGPen,	 (ULONG) od->od_BGPen,	 tags);
		od->od_FGPen   = (LONG) GetTagData (FILLBAR_FGPen,	 (ULONG) od->od_FGPen,	 tags);
		od->od_FillPen = (LONG) GetTagData (FILLBAR_FillPen, (ULONG) od->od_FillPen, tags);
	
		/* -- check for missing pens -- */
		if (od->od_BGPen == -1) {
			od->od_BGPen = od->od_DrawInfo->dri_Pens[BACKGROUNDPEN];
		}
		
		if (od->od_FGPen == -1) {
			od->od_FGPen = od->od_DrawInfo->dri_Pens[TEXTPEN];
		}
		
		if (od->od_FillPen == -1) {
			od->od_FillPen = od->od_DrawInfo->dri_Pens[FILLPEN];
		}
	
		/* -- find layout spacing -- */
		od->od_SpaceY = 2;
		od->od_SpaceX = (od->od_SpaceY * od->od_DrawInfo->dri_Resolution.Y) / od->od_DrawInfo->dri_Resolution.X;
	
		if (init) {
			struct RastPort RastPort;
			struct TextExtent TExtent;
			
			if (getFlag (od->od_Flags, ODB_FRAMEAROUND)) {
				if (!(od->od_FrameAround = NewObject (NULL, FRAMEICLASS, IA_Recessed, TRUE, IA_EdgesOnly, TRUE, TAG_DONE))) {
					refresh = 0;
					goto Fail;
				} else {
					od->od_frameAroundBox.Width = od->od_frameAroundBox.Height = 10;
					DoMethod (od->od_FrameAround, IM_FRAMEBOX,&od->od_frameAroundBox, &od->od_AroundBox, od->od_DrawInfo, 0);
				}
			}
		
			if (getFlag (od->od_Flags, ODB_FRAMEINSIDE)) {
				if (!(od->od_FrameInside = NewObject (NULL, FRAMEICLASS, IA_Recessed, TRUE, IA_EdgesOnly, TRUE, TAG_DONE))) {
					if (getFlag (od->od_Flags, ODB_FRAMEAROUND) && od->od_FrameAround) {
						DisposeObject (od->od_FrameAround);
						od->od_FrameAround = NULL;
					}
					refresh = 0;
					goto Fail;
				} else {
					od->od_frameInsideBox.Width = od->od_frameInsideBox.Height = 10;
					DoMethod (od->od_FrameInside, IM_FRAMEBOX, &od->od_frameInsideBox, &od->od_InsideBox, od->od_DrawInfo, 0);
				}
			}
				
			/* -- we got the objects (if they were requested) -- */
			
			InitRastPort (&RastPort);
			SetFont (&RastPort, od->od_DrawInfo->dri_Font);
			
			/* -- now check for labels size -- */
			
			if (od->od_LabelLeftText != NULL) {
				TextExtent (&RastPort, od->od_LabelLeftText, strlen (od->od_LabelLeftText), &TExtent);
				od->od_LabelLeftBox.Width = TExtent.te_Width - TExtent.te_Extent.MinX + od->od_SpaceX * 4;
				od->od_LabelLeftBox.Height = TExtent.te_Height;
			}
			
			if (od->od_LabelRightText != NULL) {
				TextExtent (&RastPort, od->od_LabelRightText, strlen (od->od_LabelRightText), &TExtent);
				od->od_LabelRightBox.Width = TExtent.te_Width - TExtent.te_Extent.MinX + od->od_SpaceX * 4;
				od->od_LabelRightBox.Height = TExtent.te_Height;
			}
			
			if (getFlag (od->od_Flags, ODB_LABELINSIDE)) {
				/* use this as the bigger string that can be put defaultLabelRight */
				TextExtent (&RastPort, defaultLabelRight, strlen (defaultLabelRight), &TExtent);
				od->od_LabelInsideBox.Width = TExtent.te_Width - TExtent.te_Extent.MinX + od->od_SpaceX * 8;
				od->od_LabelInsideBox.Height = TExtent.te_Height;
			}
		}
	} else {
		refresh = 0;
	}
	
	if (refresh && getFlag (od->od_Flags, ODB_SIZEREFRESH)) {
		/* --- now do the framing according to the image dimensions (if the user requested them... if not just do some calculations of our own) --- */
		if (od->od_ImageBox.Width > 0) {
			od->od_FillBox.Width = od->od_ImageBox.Width - od->od_SpaceX * 2 - (od->od_AroundBox.Width - od->od_frameAroundBox.Width)
			                       - (od->od_InsideBox.Width - od->od_frameInsideBox.Width) - od->od_LabelLeftBox.Width - od->od_LabelRightBox.Width;
		} else {
			od->od_FillBox.Width = 100;
		}
		
		if (od->od_ImageBox.Height > 0) {
			od->od_FillBox.Height = od->od_ImageBox.Height - od->od_SpaceY * 2 - (od->od_AroundBox.Height - od->od_frameAroundBox.Height) - (od->od_InsideBox.Height - od->od_frameInsideBox.Height);
		} else {
			if (getFlag (od->od_Flags, ODB_LABELLEFT)) {
				od->od_FillBox.Height = od->od_LabelLeftBox.Height;
			} else if (getFlag (od->od_Flags, ODB_LABELRIGHT)) {
				od->od_FillBox.Height = od->od_LabelRightBox.Height;
			} else if (getFlag (od->od_Flags, ODB_LABELINSIDE)) {
				od->od_FillBox.Height = od->od_LabelInsideBox.Height;
			} else {
				od->od_FillBox.Height = 8;
			}
			
			od->od_FillBox.Height += od->od_SpaceY * 2;
		}
		
		od->od_FillBox.Left = (od->od_AroundBox.Width - od->od_frameAroundBox.Width) + od->od_SpaceX + od->od_LabelLeftBox.Width + (od->od_InsideBox.Width - od->od_frameInsideBox.Width);
		od->od_FillBox.Top = (od->od_AroundBox.Height - od->od_frameAroundBox.Height) + od->od_SpaceY + (od->od_InsideBox.Height - od->od_frameInsideBox.Height);
		if (getFlag (od->od_Flags, ODB_FRAMEINSIDE)) {
			od->od_frameInsideBox = od->od_FillBox;
			DoMethod (od->od_FrameInside, IM_FRAMEBOX, &od->od_frameInsideBox, &od->od_InsideBox, od->od_DrawInfo, 0);
		} else {
			od->od_InsideBox = od->od_frameInsideBox = od->od_FillBox;
		}

		if (getFlag (od->od_Flags, ODB_FRAMEAROUND)) {
			od->od_frameAroundBox = od->od_InsideBox;
			od->od_frameAroundBox.Left -= od->od_LabelLeftBox.Width + od->od_SpaceX;
			od->od_frameAroundBox.Top -= od->od_SpaceY;
			od->od_frameAroundBox.Width += 2 * od->od_SpaceX + od->od_LabelLeftBox.Width + od->od_LabelRightBox.Width;
			od->od_frameAroundBox.Height += 2 * od->od_SpaceY;
			DoMethod (od->od_FrameAround, IM_FRAMEBOX, &od->od_frameAroundBox, &od->od_AroundBox, od->od_DrawInfo, 0);
		} else {
			od->od_AroundBox = od->od_frameAroundBox = od->od_InsideBox;
		}
			
		/*********************************/
		od->od_ImageBox.Width = od->od_AroundBox.Width;
		od->od_ImageBox.Height = od->od_AroundBox.Height;
			
		od->od_LabelLeftBox.Left = od->od_InsideBox.Left - od->od_LabelLeftBox.Width - od->od_SpaceX * 2;
		od->od_LabelLeftBox.Top = od->od_FillBox.Top + od->od_LabelLeftBox.Height;
			
		od->od_LabelRightBox.Left = od->od_InsideBox.Left + od->od_InsideBox.Width + od->od_SpaceX * 2;
		od->od_LabelRightBox.Top = od->od_FillBox.Top + od->od_LabelRightBox.Height;
			
		od->od_LabelInsideBox.Left = od->od_FillBox.Left + (od->od_FillBox.Width - od->od_LabelInsideBox.Width) / 2;
		od->od_LabelInsideBox.Top = od->od_FillBox.Top + (od->od_FillBox.Height - od->od_LabelInsideBox.Height) / 2 + od->od_LabelInsideBox.Height - 1;
			
		if (od->od_FrameInside != NULL) {
			SetAttrs (od->od_FrameInside,
				IA_Left,	od->od_InsideBox.Left,
				IA_Top,		od->od_InsideBox.Top,
				IA_Width,	od->od_InsideBox.Width,
				IA_Height,	od->od_InsideBox.Height,
				TAG_DONE);
		}
			
		if (od->od_FrameAround != NULL) {
			SetAttrs (od->od_FrameAround,
				IA_Left,	od->od_AroundBox.Left,
				IA_Top,		od->od_AroundBox.Top,
				IA_Width,	od->od_AroundBox.Width,
				IA_Height,	od->od_AroundBox.Height,
				TAG_DONE);
		}

#if 0	
		kprintf ("      ImageBox { %ld %ld %ld %ld }\n", od->od_ImageBox.Left, od->od_ImageBox.Top, od->od_ImageBox.Width, od->od_ImageBox.Height);
		kprintf ("  LabelLeftBox { %ld %ld %ld %ld }\n", od->od_LabelLeftBox.Left, od->od_LabelLeftBox.Top, od->od_LabelLeftBox.Width, od->od_LabelLeftBox.Height);
		kprintf (" LabelRightBox { %ld %ld %ld %ld }\n", od->od_LabelRightBox.Left, od->od_LabelRightBox.Top, od->od_LabelRightBox.Width, od->od_LabelRightBox.Height);
		kprintf ("LabelInsideBox { %ld %ld %ld %ld }\n", od->od_LabelInsideBox.Left, od->od_LabelInsideBox.Top, od->od_LabelInsideBox.Width, od->od_LabelInsideBox.Height);
		kprintf ("        SpaceX : %ld\n", od->od_SpaceX);
		kprintf ("        SpaceY : %ld\n", od->od_SpaceY);
		kprintf ("       FillBox { %ld %ld %ld %ld }\n", od->od_FillBox.Left, od->od_FillBox.Top, od->od_FillBox.Width, od->od_FillBox.Height);
		kprintf ("     AroundBox { %ld %ld %ld %ld }\n", od->od_AroundBox.Left, od->od_AroundBox.Top, od->od_AroundBox.Width, od->od_AroundBox.Height);
		kprintf ("frameAroundBox { %ld %ld %ld %ld }\n", od->od_frameAroundBox.Left, od->od_frameAroundBox.Top, od->od_frameAroundBox.Width, od->od_frameAroundBox.Height);
		kprintf ("     InsideBox { %ld %ld %ld %ld }\n", od->od_InsideBox.Left, od->od_InsideBox.Top, od->od_InsideBox.Width, od->od_InsideBox.Height);
		kprintf ("frameInsideBox { %ld %ld %ld %ld }\n", od->od_frameInsideBox.Left, od->od_frameInsideBox.Top, od->od_frameInsideBox.Width, od->od_frameInsideBox.Height);
		
		kprintf ("         Flags : 0x%08lx\n", od->od_Flags);
#endif
	}
	
Fail:

	/* -- set the image public attributes -- */
	
	im->LeftEdge = od->od_ImageBox.Left;
	im->TopEdge  = od->od_ImageBox.Top;
	im->Width    = od->od_ImageBox.Width;
	im->Height   = od->od_ImageBox.Height;
	
	return (refresh);
}

/*****************************************************************************/

static LONG drawMethod (Class * cl, struct Image * im, struct impDraw * msg)
{
	struct ClassLib *cb = (struct ClassLib *) cl->cl_UserData;
	struct objectData *od = INST_DATA (cl, im);
	struct RastPort *rp;
	WORD tx, ty;

	rp = msg->imp_RPort;
	tx = msg->imp_Offset.X + im->LeftEdge;
	ty = msg->imp_Offset.Y + im->TopEdge;

#if 0
	if (getFlag (od->od_Flags, ODB_SIZEREFRESH)) {
#endif
		if (getFlag (od->od_Flags, ODB_FRAMEAROUND)) {
			DrawImage (rp, (struct Image *) od->od_FrameAround, tx, ty);
		}
	
		if (getFlag (od->od_Flags, ODB_FRAMEINSIDE)) {
			DrawImage (rp, (struct Image *) od->od_FrameInside, tx, ty);
		}
	
		if (getFlag (od->od_Flags, ODB_LABELLEFT)) {
			SetAPen (rp, od->od_FGPen);
			SetBPen (rp, od->od_BGPen);
			SetDrMd (rp, JAM1);
			Move (rp, tx + od->od_LabelLeftBox.Left, ty + od->od_LabelLeftBox.Top);
			Text (rp, od->od_LabelLeftText, strlen (od->od_LabelLeftText));
		}
	
		if (getFlag (od->od_Flags, ODB_LABELRIGHT)) {
			SetAPen (rp, od->od_FGPen);
			SetBPen (rp, od->od_BGPen);
			SetDrMd (rp, JAM1);
			Move (rp, tx + od->od_LabelRightBox.Left, ty + od->od_LabelRightBox.Top);
			Text (rp, od->od_LabelRightText, strlen (od->od_LabelRightText));
		}
#if 0		
		setFlag (od->od_Flags, ODB_SIZEREFRESH, FALSE);
	}
#endif
	
	SetAPen (rp, od->od_FillPen);
	SetDrMd (rp, JAM1);
	
	RectFill (rp, tx + od->od_FillBox.Left, ty + od->od_FillBox.Top, tx + od->od_FillBox.Left + od->od_FillBox.Width * od->od_Value / 100, ty + od->od_FillBox.Top + od->od_FillBox.Height);
	
	SetAPen (rp, od->od_BGPen);
	
	RectFill (rp, tx + od->od_FillBox.Left + od->od_FillBox.Width * od->od_Value / 100, ty + od->od_FillBox.Top, tx + od->od_FillBox.Left + od->od_FillBox.Width, ty + od->od_FillBox.Top + od->od_FillBox.Height);

	if (getFlag (od->od_Flags, ODB_LABELINSIDE)) {
		char buffer[5];
		
		sprintf (buffer, "%3ld%%", od->od_Value);
		
		SetAPen (rp, od->od_FGPen);
		SetDrMd (rp, JAM1);
		Move (rp, tx + od->od_LabelInsideBox.Left, ty + od->od_LabelInsideBox.Top);
		Text (rp, buffer, strlen (buffer));
	}

	return (0);
}

/*****************************************************************************/

static LONG newMethod (Class * cl, struct Image * im, struct opSet * msg)
{
    struct Image *newobj;

    /* Create the new object */
    if (newobj = (struct Image *) DoSuperMethodA (cl, (Object *) im, msg))
    {
	/* Update the attributes */
	setAttrsMethod (cl, newobj, msg, TRUE);
    }

    return ((LONG) newobj);
}

/*****************************************************************************/

static LONG disposeMethod (Class *cl, struct Image *im, Msg msg)
{
	struct ClassLib *cb = (struct ClassLib *) cl->cl_UserData;
	struct objectData *od = INST_DATA (cl, im);

	/* dispose stuff of our object */
	if (od->od_FrameAround) {
		DisposeObject (od->od_FrameAround);
	}
	
	if (od->od_FrameInside) {
		DisposeObject (od->od_FrameInside);
	}
	
	return ((LONG) DoSuperMethodA (cl, (Object *) im, msg));
}

/*****************************************************************************/
	
static LONG getMethod (Class *cl, struct Image *im, struct opGet *msg)
{
	struct ClassLib *cb = (struct ClassLib *) cl->cl_UserData;
	struct objectData *od = INST_DATA (cl, im);

	LONG result = 1;
	
	switch (msg->opg_AttrID) {
		case IA_Left:
			*((WORD *) msg->opg_Storage) = od->od_ImageBox.Left;
			break;
			
		case IA_Top:
			*((WORD *) msg->opg_Storage) = od->od_ImageBox.Top;
			break;
			
		case IA_Width:
			*((WORD *) msg->opg_Storage) = od->od_ImageBox.Width;
			break;
			
		case IA_Height:
			*((WORD *) msg->opg_Storage) = od->od_ImageBox.Height;
			break;
		
		case FILLBAR_FrameAround:
			*((BOOL *) msg->opg_Storage) = (od->od_Flags & ODF_FRAMEAROUND) ? TRUE : FALSE;
			break;
		
		case FILLBAR_FrameInside:
			*((BOOL *) msg->opg_Storage) = (od->od_Flags & ODF_FRAMEINSIDE) ? TRUE : FALSE;
			break;
		
		case FILLBAR_LabelLeft:
			*((BOOL *) msg->opg_Storage) = (od->od_Flags & ODF_LABELLEFT) ? TRUE : FALSE;
			break;
		
		case FILLBAR_LabelRight:
			*((BOOL *) msg->opg_Storage) = (od->od_Flags & ODF_LABELRIGHT) ? TRUE : FALSE;
			break;
		
		case FILLBAR_LabelInside:
			*((BOOL *) msg->opg_Storage) = (od->od_Flags & ODF_LABELINSIDE) ? TRUE : FALSE;
			break;
		
		case FILLBAR_Value:
			*((WORD *) msg->opg_Storage) = od->od_Value;
			break;
		
		default:
			result = (LONG) DoSuperMethodA (cl, (Object *) im, (Msg) msg);
			break;
	}

	return (result);
}

/*****************************************************************************/

LONG ASM ClassDispatcher (REG (a0) Class * cl, REG (a1) ULONG * msg, REG (a2) struct Image * im)
{
    switch (*msg)
    {
	case OM_NEW:
	    return newMethod (cl, im, (struct opSet *) msg);

	case OM_DISPOSE:
		return (disposeMethod (cl, im, (Msg) msg));
	
	case OM_GET:
		return (getMethod (cl, im, (struct opGet *) msg));


	case OM_SET:
	case OM_UPDATE:
	    return (setAttrsMethod (cl, im, (struct opSet *) msg, FALSE));

	case IM_DRAW:
	    return (drawMethod (cl, im, (struct impDraw *) msg));

	default:
	    return ((LONG) DoSuperMethodA (cl, (Object *) im, (Msg) msg));
    }
}

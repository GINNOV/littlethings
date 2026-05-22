/*
 *	File:					IconifyButtonClass.c
 *	Description:	
 *
 *	(C) 1995, Ketil Hunn
 *
 */

/*** PRIVATE INCLUDES ****************************************************************/
#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>
#include <intuition/cghooks.h>
#include <intuition/icclass.h>
#include <utility/tagitem.h>
#include <utility/hooks.h>
#include <graphics/rpattr.h>
#include <graphics/gfxmacros.h>
#include <dos.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/alib_protos.h>
#include <clib/alib_stdio_protos.h>

/*** PROTOTYPES **********************************************************************/

ULONG __asm dispatchIconifyButton(register __a0 Class		*class,
																	register __a2 Object	*o,
																	register __a1 Msg			msg);
__asm  ULONG renderIconifyButton(	register __a0 struct Gadget		*g,
																	register __a1 struct gpRender	*msg);

/*** FUNCTIONS ***********************************************************************/
__asm Class *initIconifyButtonClass(void)
{
	Class	*class;

	if(class=MakeClass(NULL, GADGETCLASS, NULL, NULL, 0))
	{
		class->cl_Dispatcher.h_Entry		=(HOOKFUNC)dispatchIconifyButton;
		class->cl_Dispatcher.h_SubEntry	=NULL;
		class->cl_Dispatcher.h_Data			=(void *)getreg(REG_A4);
	}
	return class;
}


__asm void RenderIconifyButton(	register __a0 Object						*o,
																register __a1 struct GadgetInfo	*gi)
{
	register struct RastPort *rp;

	if(rp=ObtainGIRPort(gi))
	{
		DoMethod(o, GM_RENDER, gi, rp, GREDRAW_REDRAW);
		ReleaseGIRPort(rp);
	}
}

ULONG __asm dispatchIconifyButton(register __a0 Class		*class,
																	register __a2 Object	*o,
																	register __a1 Msg			msg)
{
	ULONG	retval=FALSE;

	putreg(REG_A4, (long)class->cl_Dispatcher.h_Data);
	switch (msg->MethodID)
	{
		case GM_HITTEST:
			retval=GMR_GADGETHIT;
			break;

		case GM_GOACTIVE:
			if(((struct gpInput *)msg)->gpi_IEvent)
			{
				SETBIT(((struct Gadget *)o)->Flags, GFLG_SELECTED);
				RenderIconifyButton(o, ((struct gpInput *)msg)->gpi_GInfo);
				retval=GMR_MEACTIVE;
			}
			else
				retval=GMR_NOREUSE;
			break;

		case GM_GOINACTIVE:
			CLEARBIT(((struct Gadget *)o)->Flags, GFLG_SELECTED);
			RenderIconifyButton(o, ((struct gpGoInactive *)msg)->gpgi_GInfo);
			break;

		case GM_RENDER:
			renderIconifyButton((struct Gadget *)o, (struct gpRender *)msg);
			break;

		case GM_HANDLEINPUT:
			{
				struct Gadget			*g		=(struct Gadget *)o;
				struct gpInput		*gpi	=(struct gpInput *)msg;
				struct InputEvent	*ie		=gpi->gpi_IEvent;

				retval=GMR_MEACTIVE;

				if(ie->ie_Class==IECLASS_RAWMOUSE)
				{
					switch (ie->ie_Code)
					{
						case SELECTUP:
							if(	(gpi->gpi_Mouse.X<0)				||
									(gpi->gpi_Mouse.X>g->Width)	||
									(gpi->gpi_Mouse.Y<0)				||
									(gpi->gpi_Mouse.Y>g->Height))
								retval=GMR_REUSE;
							else
								retval=GMR_NOREUSE|GMR_VERIFY;
							break;

						case MENUDOWN:
							retval=GMR_REUSE;
							break;

						case IECODE_NOBUTTON:
							if(	(gpi->gpi_Mouse.X<0)				||
									(gpi->gpi_Mouse.X>g->Width)	||
									(gpi->gpi_Mouse.Y<0)				||
									(gpi->gpi_Mouse.Y>g->Height))
							{
								if(ISBITSET(g->Flags, GFLG_SELECTED))
								{
									CLEARBIT(g->Flags, GFLG_SELECTED);
									RenderIconifyButton(o, gpi->gpi_GInfo);
								}
							}
							else if(ISBITCLEARED(g->Flags, GFLG_SELECTED))
							{
								SETBIT(g->Flags, GFLG_SELECTED);
								RenderIconifyButton(o, gpi->gpi_GInfo);
							}
							break;
					}
				}
			}
			break;

		default:
			retval=DoSuperMethodA(class, o, msg);
			break;
	}
	return retval;
}

__asm void drawFrame(	register __a0 struct RastPort *rp,
											register __d4 UWORD						pen1,
											register __d5 UWORD						pen2,
											register __d0 WORD						x,
											register __d1 WORD						y,
											register __d2 WORD						w,
											register __d3 WORD						h)
											
{
	SetAPen(rp, pen1);
	Move(rp, x,		y+h-1);
	Draw(rp, x,		y);
	Draw(rp, x+w-1,	y);

	SetAPen(rp, pen2);
	Move(rp, x+w, y+1);
	Draw(rp, x+w, y+h);
	Draw(rp, x+1, y+h);
}

__asm ULONG renderIconifyButton(register __a0 struct Gadget		*g,
																register __a1 struct gpRender	*msg)
{
	struct RastPort		*rp=msg->gpr_RPort;
	ULONG retval			=FALSE;
	UWORD	*pens				=msg->gpr_GInfo->gi_DrInfo->dri_Pens;

	if(rp && pens)
	{
		register BYTE selected=(g->Flags & GFLG_SELECTED);
		register UWORD	x=g->LeftEdge+1,
										y=g->TopEdge,
										w=g->Width-2,
										h=g->Height;
		UWORD hmarg=5, //g->Width/5,
					vmarg=g->Width/7-(g->Height<11 ? 1:0);

		if(ISBITSET(g->Flags, GFLG_RELRIGHT))
			x+=msg->gpr_GInfo->gi_Domain.Width-1;

		SetAPen(rp, pens[SHADOWPEN]);

		Move(rp, x-1, y+1);
		Draw(rp, x-1, y+h);

		if(selected)
		{
			drawFrame(rp, pens[SHADOWPEN], pens[SHINEPEN], x,y,w,h);
			drawFrame(rp, pens[SHINEPEN], pens[SHADOWPEN], x+hmarg,y+vmarg,w-hmarg*2,h-vmarg*2);
			drawFrame(rp, pens[SHADOWPEN], pens[SHINEPEN], x+hmarg+1,y+h-vmarg-3,2,2);
		}
		else
		{
			drawFrame(rp, pens[SHINEPEN], pens[SHADOWPEN], x,y,w,h);
			drawFrame(rp, pens[SHADOWPEN], pens[SHINEPEN], x+hmarg,y+vmarg,w-hmarg*2,h-vmarg*2);
			drawFrame(rp, pens[SHINEPEN], pens[SHADOWPEN], x+hmarg+1,y+h-vmarg-3,2,2);
		}

		retval=TRUE;
	}
	return retval;
}

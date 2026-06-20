/*
 *	File:					GroupFrameClass.c
 *	Description:	GroupFrame BOOPSI class
 *
 *	(C) 1995, Ketil Hunn
 *
 */

/*** PRIVATE INCLUDES ****************************************************************/
#define	INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <intuition/intuitionbase.h>
#include <intuition/classusr.h>
#include <intuition/gadgetclass.h>
#include <intuition/cghooks.h>
#include <intuition/icclass.h>
#include <intuition/classes.h>
#include <intuition/sghooks.h>
#include <graphics/gfxbase.h>
#include <graphics/text.h>
#include <graphics/gfxmacros.h>
#include <utility/tagitem.h>
#include <utility/hooks.h>

#include <clib/macros.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/utility_protos.h>

#define USE_BUILTIN_MATH
#include <string.h>

/*** GLOBALS *************************************************************************/
struct GroupFrameData
{
	UBYTE *title;
	ULONG flags;
};

/*** FUNCTIONS ***********************************************************************/
__asm void DrawBox(	register __a0 struct RastPort	*rp,
										register __d0 WORD						x1,
										register __d1 WORD						y1,
										register __d2 WORD						x2,
										register __d3 WORD						y2,
										register __d4 UBYTE						color)
{
	SetAPen(rp, color);
	Move(rp, x1, y1);
	Draw(rp, x2 , y1);
	Draw(rp, x2 , y2);
	Draw(rp, x1 , y2);
	Draw(rp, x1 , y1);
}

__asm ULONG RenderGroupFrame(	register __a0	Class									*class,
															register __a1 struct Gadget 				*gadget,
															register __a2 struct gpRender				*msg,
															register __a3 struct GroupFrameData *groupframe)
{
	register struct RastPort *rp;

	if(msg->MethodID==GM_RENDER)
		rp=msg->gpr_RPort;
	else
		rp=ObtainGIRPort(msg->gpr_GInfo);

	if(rp)
	{
	  UWORD x	=gadget->LeftEdge,
					y	=gadget->TopEdge,
					w	=gadget->Width,
					h	=gadget->Height;
		UBYTE oldAPen	=rp->FgPen,
					oldDrMd	=rp->DrawMode;

		DrawBox(rp,	x, y,
								x+w-2, y+h-2,
								msg->gpr_GInfo->gi_DrInfo->dri_Pens[SHADOWPEN]);
		DrawBox(rp,	x+1, y+1,
								x+w-1, y+h-1,
								msg->gpr_GInfo->gi_DrInfo->dri_Pens[SHINEPEN]);

		SetAPen(rp, oldAPen);
		SetDrMd(rp, oldDrMd);

		if(msg->MethodID!=GM_RENDER)
			ReleaseGIRPort(rp);
	}
	else
		return FALSE;

	return TRUE;
}

__asm ULONG dispatchGroupFrame(	register __a0 Class		*class,
																register __a2 Object	*object,
																register __a1 Msg			msg)
{
	Object								*newobject;
  struct TagItem				*taglist;
	struct GroupFrameData *groupframe;
  ULONG									retval;

	switch(msg->MethodID)
	{
		case OM_NEW:
			if(newobject=(Object *)DoSuperMethodA(class, object, msg))
			{
				taglist=((struct opSet *)msg)->ops_AttrList;

				groupframe=INST_DATA(class, newobject);
				/* get tags */
			}
			retval=(ULONG)newobject;
			break;
		case OM_DISPOSE:
			break;
		case GM_RENDER:
			groupframe=INST_DATA(class, object);
			retval=RenderGroupFrame(class, (struct Gadget *)object, (struct gpRender *)msg, groupframe);
			break;
		default:
			retval=DoSuperMethodA(class, object ,msg);
			break;
	}
	return retval;
}

__asm __saveds Class *InitGroupFrameClass(void)
{
  Class *class;

	if(class=MakeClass( NULL, "gadgetclass", NULL, sizeof(struct GroupFrameData), 0))
		class->cl_Dispatcher.h_Entry=(ULONG(*)())dispatchGroupFrame;
	return class;
}

__asm __saveds BOOL FreeGroupFrameClass(register __a0 Class *class)
{
	return FreeClass(class);
}


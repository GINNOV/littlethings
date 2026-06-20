/*
 *	File:					GroupFrameClass.c
 *	Description:	Draws frames around groups of gadgets
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

/*** DEFINES *************************************************************************/
#define	TITLEGAP		4

#define	THICKFRAME	1
#define	PLACELEFT		2
#define	PLACERIGHT	4
#define	HIGHLIGHT		8
#define	SHADOW			16

/*** GLOBALS *************************************************************************/
struct GroupFrameInst
{
	STRPTR					title;
	WORD						underline;
	struct TextFont	*font;
	ULONG						flags;
};

/*** PROTOTYPES **********************************************************************/
__asm WORD StrCpyC(	register __a0 UBYTE *dest,
										register __a1 UBYTE *src);
ULONG __asm dispatchGroupFrame(	register __a0 Class		*class,
																register __a2 Object	*o,
																register __a1 Msg			msg);
__asm ULONG renderGroupFrame(	register __a0 Class									*class,
															register __a1 struct Gadget					*g,
															register __a2 struct gpRender				*msg,
															register __a3 struct GroupFrameInst	*inst);
/*** FUNCTIONS ***********************************************************************/

__asm Class *initGroupFrameClass(void)
{
	Class					*class;

	if(class=MakeClass(NULL, GADGETCLASS, NULL, sizeof(struct GroupFrameInst), 0))
	{
		class->cl_Dispatcher.h_Entry		=(HOOKFUNC)dispatchGroupFrame;
		class->cl_Dispatcher.h_SubEntry	=NULL;
		class->cl_Dispatcher.h_Data			=(void *)getreg(REG_A4);
	}
	return class;
}

ULONG __asm dispatchGroupFrame(	register __a0 Class		*class,
																register __a2 Object	*o,
																register __a1 Msg			msg)
{
	struct GroupFrameInst	*inst;
	Object								*object;
	ULONG									retval=FALSE;

	putreg(REG_A4, (long)class->cl_Dispatcher.h_Data);
	switch (msg->MethodID)
	{
		case OM_NEW:
			if(object=(Object *)DoSuperMethodA(class, o, msg))
			{
				struct TagItem					*taglist=((struct opSet *)msg)->ops_AttrList,
																*tstate=taglist;
				register struct TagItem	*tag;
				register STRPTR					title=NULL;

				if(inst=INST_DATA(class, object))
				{
					inst->underline	=-1;
					inst->title			=NULL;
					while(tag=NextTagItem(&tstate))
						switch(tag->ti_Tag)
						{
							case EG_Title:
							case GA_Text:
								title=(STRPTR)tag->ti_Data;
								break;
							case EG_Font:
								inst->font=(struct TextFont *)tag->ti_Data;
								break;
							case EG_ThickFrame:
								IFTRUESETBIT(tag->ti_Data, inst->flags, THICKFRAME);
								break;
							case EG_PlaceTitleLeft:
								IFTRUESETBIT(tag->ti_Data, inst->flags, PLACELEFT);
								break;
							case EG_PlaceTitleRight:
								IFTRUESETBIT(tag->ti_Data, inst->flags, PLACERIGHT);
								break;
							case EG_Highlight:
								IFTRUESETBIT(tag->ti_Data, inst->flags, HIGHLIGHT);
								break;
							case EG_Shadow:
								IFTRUESETBIT(tag->ti_Data, inst->flags, SHADOW);
								break;
						}
						if(title)
						{
							if(inst->title=(STRPTR)AllocVec(strlen(title), 0L))
								inst->underline=StrCpyC(inst->title, title);
							else
							{
		            CoerceMethod(class, o, OM_DISPOSE);
	  	          object=NULL;
							}
						}
				}
				retval=(ULONG)object;
			}
			break;
		case OM_DISPOSE:
			if(inst=INST_DATA(class, o))
				if(inst->title)
					FreeVec(inst->title);
			retval=DoSuperMethodA(class, o, msg);
			break;
		case GM_HITTEST:
			retval=GMR_REUSE;
			break;
		case GM_GOACTIVE:
			retval=GMR_NOREUSE;
			break;
		case GM_RENDER:
			if(inst=INST_DATA(class, o))
				retval=renderGroupFrame(class, (struct Gadget *)o, (struct gpRender *)msg, inst);
			break;
		case GM_HANDLEINPUT:
			retval=GMR_REUSE;
			break;
		default:
			retval=DoSuperMethodA(class, o, msg);
			break;
	}
	return retval;
}

/*
__asm WORD StrCpyC(	register __a0 UBYTE *dest,
										register __a1 UBYTE *src)
{
	register UBYTE *start=src;
	register WORD uline=-1;

	if(src)
	{
		while(*src)
			if(*src=='_')
				uline=src++-start;
			else
				*dest++=*src++;
		*dest='\0';
	}
	return uline;
}
*/
__asm void UText(	register __a2 struct RastPort	*rp,
									register __d0 WORD						x,
									register __d1 WORD						y,
									register __a1 UBYTE 					*text,
									register __d2 WORD						underline)
{
	Move(rp, x, y);
	Text(rp, text, strlen(text));

	if(underline>-1)
	{
		Move(rp, x+=TextLength(rp, text, underline), ++y);
		Draw(rp, x+TextLength(rp, text+underline, 1)-2, y);
	}
}

__asm void DrawBevel(	register __a0 struct RastPort	*rp,
											register __a1 UWORD						*pens,
											register __a2	UBYTE						thick,
											register __d6	UBYTE						raised,
											register __d0 WORD						x,
											register __d1 WORD						y,
											register __d2 WORD						w,
											register __d3 WORD						h,
											register __d4 WORD						titlegap,
											register __d5 WORD						titlegapwidth)
{
	SetAPen(rp, (raised ? pens[SHINEPEN]:pens[SHADOWPEN]));
	Move(rp, x,		y+h-1);
	Draw(rp, x,		y);

	if(thick)
	{
		Move(rp, x+1,		y+h-1);
		Draw(rp, x+1,		y);
	}

	if(titlegap>-1)
	{
		Draw(rp, titlegap , y);
		Move(rp, titlegap+titlegapwidth, y);
	}
	Draw(rp, x+w-1,	y);

	SetAPen(rp, (raised ? pens[SHADOWPEN]:pens[SHINEPEN]));
	Move(rp, x+w, y+1);
	Draw(rp, x+w, y+h);

	if(thick)
	{
		Move(rp, x+w-1,		y+1);
		Draw(rp, x+w-1,		y+h);
	}

	Draw(rp, x+1, y+h);
}

__asm ULONG renderGroupFrame(	register __a0 Class									*class,
															register __a1 struct Gadget					*g,
															register __a2 struct gpRender				*msg,
															register __a3 struct GroupFrameInst	*inst)
{
	struct RastPort		*rp;
	ULONG retval			=FALSE;
	UWORD	*pens				=msg->gpr_GInfo->gi_DrInfo->dri_Pens;

	if(msg->MethodID==GM_RENDER)
		rp=msg->gpr_RPort;
	else
		rp=ObtainGIRPort(msg->gpr_GInfo);

	if(rp && pens)
	{
		register UWORD	x=g->LeftEdge,
										y=g->TopEdge,
										w=g->Width-1,
										h=g->Height-1,
										titleleft	=-1,
										titlewidth;
		struct TextFont	*font=(inst->font==NULL ? rp->Font:inst->font);

		SetFont(rp, font);
		if(ISBITSET(g->Flags, GFLG_RELRIGHT))
			x+=msg->gpr_GInfo->gi_Domain.Width-1;

		if(inst->title)
		{
			titlewidth=TextLength(rp, inst->title, strlen(inst->title))-TITLEGAP/2;

			if(ISBITSET(inst->flags, PLACELEFT))
				titleleft=x+TITLEGAP*2;
			else if(ISBITSET(inst->flags, PLACERIGHT))
				titleleft=x+w-TITLEGAP*2-titlewidth;
			else
				titleleft=x+(w-titlewidth)/2;
		}

		if(ISBITSET(inst->flags, THICKFRAME))
		{
			DrawBevel(rp, pens, TRUE, TRUE,  x+2, y+1, w-4, h-2, titleleft-TITLEGAP, titlewidth+TITLEGAP*2);
			DrawBevel(rp, pens, TRUE, FALSE, x, y, w, h, titleleft-TITLEGAP, titlewidth+TITLEGAP*2);
		}
		else
		{
			DrawBevel(rp, pens, FALSE, TRUE,  x+1, y+1, w-2, h-2, titleleft-TITLEGAP, titlewidth+TITLEGAP*2);
			DrawBevel(rp, pens, FALSE, FALSE, x, y, w, h, titleleft-TITLEGAP, titlewidth+TITLEGAP*2);
		}

		if(inst->title)
		{
			register WORD ypos=y+font->tf_Baseline/2;

			SetDrMd(rp, JAM1);

			if(ISBITSET(inst->flags, SHADOW))
			{
				SetAPen(rp, pens[SHADOWPEN]);
				UText(rp, titleleft, 1+ypos, inst->title, inst->underline);
				SetAPen(rp, pens[HIGHLIGHTTEXTPEN]);
				UText(rp, titleleft-1, ypos, inst->title, inst->underline);
			}
			else
			{
				SetAPen(rp, (ISBITSET(inst->flags, HIGHLIGHT) ? pens[HIGHLIGHTTEXTPEN]:pens[TEXTPEN]));
				UText(rp, titleleft, ypos, inst->title, inst->underline);
			}
		}
		retval=TRUE;
	}
	if(msg->MethodID!=GM_RENDER)
		ReleaseGIRPort(rp);

	return retval;
}

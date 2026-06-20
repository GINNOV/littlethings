#include "headers.h"

#include "buttonclass.h"

#define FLAG_SHOWPERCENT 1

struct ProgressData {
	UWORD min;
	UWORD max;
	UWORD current;
	UWORD flags;
	struct TextFont *textFont;
};

struct ClassGlobalData {
	struct Library *SysBase;
	struct Library *IntuitionBase;
	struct Library *UtilityBase;
	struct Library *GfxBase;
};
typedef struct ClassGlobalData CGLOB;


#define D(x) ;

#define REG(x) register __ ## x

extern ULONG __stdargs DoSuperMethodA( struct IClass *cl, Object *obj, Msg message );
extern ULONG DoMethod( Object *obj, unsigned long MethodID, ... );
static ULONG __asm dispatchProgressGadget(REG(a0) Class *cl, REG(a2) Object *o, REG(a1) Msg msg);
static ULONG RenderProgress(CGLOB *z, Class *cl, struct Gadget *g, struct gpRender *msg, struct ProgressData *inst);
static void SPrintf(struct Library *SysBase, STRPTR buffer, STRPTR format, ...);

#define IntuitionBase	z->IntuitionBase
#define UtilityBase		z->UtilityBase
#define GfxBase			z->GfxBase

Class *initProgressGadgetClass(struct Library *IBase, struct Library *UBase, struct Library *GBase)
{
  Class *cl;
  CGLOB *z;
  struct Library *SysBase= *((void **)4L);

	z= AllocVec(sizeof(CGLOB), MEMF_CLEAR);
	if( z )
		{
		z->SysBase   = SysBase;
		IntuitionBase= IBase;
		UtilityBase  = UBase;
		GfxBase      = GBase;
		if( cl = MakeClass( NULL, "gadgetclass", NULL, sizeof(struct ProgressData), 0) )
			{
			cl->cl_Dispatcher.h_Entry = (ULONG(*)()) dispatchProgressGadget;
			cl->cl_Dispatcher.h_Data  = z;
			return(cl);
			}
		FreeVec(z);
		}
	return(NULL);
}
#define SysBase			z->SysBase

BOOL freeProgressGadgetClass( Class *cl )
{
  CGLOB *z= cl->cl_Dispatcher.h_Data;
  BOOL retval;

	retval= FreeClass(cl);
	FreeVec(z);
	return( retval );
}

static ULONG __asm dispatchProgressGadget(REG(a0) Class *cl, REG(a2) Object *o, REG(a1) Msg msg)
{
  CGLOB  *z= cl->cl_Dispatcher.h_Data;
  struct Gadget *g= (struct Gadget *)o;
  struct RastPort *rp;
  struct ProgressData *inst;
  struct TagItem *ti;
  struct opGet *opget;
  ULONG retval;
  Object *object;


	switch( msg->MethodID )
		{
		case OM_NEW:
			D( kprintf("OM_NEW\n"); )
			if( object = (Object *)DoSuperMethodA(cl, o, msg) )
				{
				ti= ((struct opSet *)msg)->ops_AttrList;

				inst= INST_DATA(cl, object);
				inst->min = GetTagData(PRO_Min,   0, ti);
				inst->max = GetTagData(PRO_Max, 100, ti);
				inst->current = GetTagData(PRO_Current, 0, ti);
				inst->flags = (GetTagData(PRO_ShowPercent, 0, ti) ? FLAG_SHOWPERCENT : 0);
				inst->textFont= (struct TextFont *)GetTagData(PRO_TextFont, 0, ti);
				}
			retval= (ULONG)object;
			break;
		case GM_RENDER:
			D( kprintf("GM_RENDER\n"); )
			inst= INST_DATA(cl, o);
			retval= RenderProgress(z, cl, g, (struct gpRender *)msg, inst);
			break;
		case OM_SET:
			D( kprintf("OM_SET\n"); )
			ti= ((struct opSet *)msg)->ops_AttrList;
			if( FindTagItem(GA_Width,  ti) ||
				FindTagItem(GA_Height, ti) ||
				FindTagItem(GA_Top,    ti) ||
				FindTagItem(GA_Left,   ti) ||
				FindTagItem(PRO_Min, ti) ||
				FindTagItem(PRO_Max, ti) ||
				FindTagItem(PRO_Current, ti) ||
				FindTagItem(PRO_ShowPercent, ti) ||
				FindTagItem(PRO_TextFont, ti) )
				{
				WORD x,y,w,h;
				
				x= g->LeftEdge;
				y= g->TopEdge;
				w= g->Width;
				h= g->Height;

				retval= DoSuperMethodA(cl, o, msg);

				if( rp=ObtainGIRPort( ((struct opSet *)msg)->ops_GInfo) )
					{
					UWORD *pens= ((struct opSet *)msg)->ops_GInfo->gi_DrInfo->dri_Pens;
					struct TagItem *tmp;
					
					if( x!=g->LeftEdge || y!=g->TopEdge || w!=g->Width || h!=g->Height )
						{
						SetAPen(rp, pens[BACKGROUNDPEN]);
						SetDrMd(rp, JAM1);
						RectFill(rp, x, y, x+w, y+h);
						}

					inst= INST_DATA(cl, o);

					inst->min = GetTagData(PRO_Min, (LONG)inst->min, ti);
					inst->max = GetTagData(PRO_Max, (LONG)inst->max, ti);
					inst->current = GetTagData(PRO_Current, (LONG)inst->current, ti);
					inst->textFont= (struct TextFont *)GetTagData(PRO_TextFont, (LONG)inst->textFont, ti);
					if( tmp=FindTagItem(PRO_ShowPercent, ti) )
						{
						inst->flags = ( tmp->ti_Data ? FLAG_SHOWPERCENT : 0);
						}

					DoMethod(o, GM_RENDER, ((struct opSet *)msg)->ops_GInfo, rp, GREDRAW_REDRAW);
					ReleaseGIRPort(rp);
					}
				}
			else
				{
				retval= DoSuperMethodA(cl, o, msg);
				}
			break;
		case OM_GET:
			D( kprintf("OM_GET\n"); )
			opget= (struct opGet *)msg;
			inst= INST_DATA(cl, o);
			retval= TRUE;
			switch( opget->opg_AttrID )
				{
				case PRO_Current:
					*(opget->opg_Storage)= (ULONG)inst->current;
					break;
				case PRO_Min:
					*(opget->opg_Storage)= (ULONG)inst->min;
					break;
				case PRO_Max:
					*(opget->opg_Storage)= (ULONG)inst->max;
					break;
				case PRO_ShowPercent:
					*(opget->opg_Storage)= (ULONG)( inst->flags & FLAG_SHOWPERCENT );
					break;
				case PRO_TextFont:
					*(opget->opg_Storage)= (ULONG)inst->textFont;
					break;
				default:
					retval= DoSuperMethodA(cl, o, msg);
				}
			break;
		case GM_HITTEST:
		case GM_GOACTIVE:
		case GM_HANDLEINPUT:
		case GM_GOINACTIVE:
		default:
			D( kprintf("DEFAULT\n"); )
			retval= DoSuperMethodA(cl, o ,msg);
			break;
		}
	return( retval );
}

static ULONG RenderProgress(CGLOB *z, Class *cl, struct Gadget *g, struct gpRender *msg, struct ProgressData *inst)
{
  struct RastPort *rp;
  ULONG retval=TRUE;
  UWORD *pens= msg->gpr_GInfo->gi_DrInfo->dri_Pens;

	if( msg->MethodID == GM_RENDER )
		{
		rp= msg->gpr_RPort;
		}
	else
		{
		rp= ObtainGIRPort(msg->gpr_GInfo);
		}

	if( rp )
		{
		UBYTE shine, shadow, sel, back;
		UWORD x, y, w, h;
		UBYTE oldAPen, oldDrMd;
		LONG pos, min, max;

		oldAPen= rp->FgPen;
		oldDrMd= rp->DrawMode;

		back  = pens[BACKGROUNDPEN];
		sel   = pens[FILLPEN];
		shine = pens[SHADOWPEN];
		shadow= pens[SHINEPEN];

		x= g->LeftEdge;	
		y= g->TopEdge;
		w= g->Width-1;
		h= g->Height-1;

		pos= (LONG)inst->current;
		min= (LONG)inst->min;
		max= (LONG)inst->max;
		if( pos < min )
			{
			pos = min;
			}
		if( pos > max )
			{
			pos = max;
			}

		pos = (pos - min) * (LONG)(w) / (max - min);

		//SetDrMd(rp, JAM1);
		if( pos > 0 )
			{
			SetAPen(rp, sel);
			RectFill( rp, x+2, y+1, x+pos-2, y+h-1 );
			}

		if( pos < w )
			{
			SetAPen(rp, back);
			RectFill( rp, x+pos+2, y+1, x+w-2, y+h-1 );
			}

		SetAPen(rp, shadow);
		RectFill(rp, x+1, y+h, x+w, y+h);
		RectFill(rp, x+w-1, y+1, x+w-1, y+h);
		RectFill(rp, x+w, y, x+w, y+h);
		

		SetAPen(rp, shine);
		RectFill(rp, x, y, x+w-1, y);
		RectFill(rp, x, y+1, x, y+h);
		RectFill(rp, x+1, y+1, x+1, y+h-1);

		if( inst->flags & FLAG_SHOWPERCENT )
			{
			UBYTE per[5];
			UWORD slen, text_x, text_y;
			struct TextExtent te;

			SPrintf(SysBase, per, "%ld%%", (w ? pos*100/w : 0 ));
			slen= strlen(per);
			TextExtent(rp, per, slen, &te);
			text_x= x + (w+1)/2 - te.te_Width/2;
			text_y= y + (h+1)/2 - (te.te_Extent.MaxY - te.te_Extent.MinY + 1)/2 - te.te_Extent.MinY;

			if( inst->textFont ) SetFont(rp, inst->textFont);
			SetAPen(rp, pens[TEXTPEN]);
			Move(rp, text_x, text_y);
			Text(rp, per, slen);
			}

		SetAPen(rp, oldAPen);
		SetDrMd(rp, oldDrMd);

		if( msg->MethodID != GM_RENDER )
			{
			ReleaseGIRPort(rp);
			}
		}
	else
		{
		retval= FALSE;
		}
	return( retval );
}

#undef SysBase
static void SPrintf(struct Library *SysBase, STRPTR buffer, STRPTR format, ...)
{
	RawDoFmt( format, (APTR)(&format+1), (void (*)())"\x16\xc0\x4E\x75", buffer);
}

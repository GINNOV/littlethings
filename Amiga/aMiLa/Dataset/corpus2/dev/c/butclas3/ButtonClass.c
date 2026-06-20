#include "headers.h"

#include "buttonclass.h"

#define FLAG_DRAWER	1

struct ButtonData {
	BOOL  lastState;		// Refresh only if state changes
	UWORD color;			// Foreground color
	UWORD backcolor;		// Background color
	UWORD flags;			// Currently only DRAWER
	UBYTE *text;			// Text for gadget
	struct Image *image;	// Image for gadget
	struct Image *simage;	// Select Image for gadget
};

struct ClassGlobalData {
	struct Library *SysBase;
	struct Library *IntuitionBase;
	struct Library *UtilityBase;
	struct Library *GfxBase;
	struct TextFont *textFont;
};
typedef struct ClassGlobalData CGLOB;


#define D(x) ;

#define REG(x) register __ ## x

extern ULONG __stdargs DoSuperMethodA( struct IClass *cl, Object *obj, Msg message );
extern ULONG DoMethod( Object *obj, unsigned long MethodID, ... );
static ULONG __asm dispatchButtonGadget(REG(a0) Class *cl, REG(a2) Object *o, REG(a1) Msg msg);
static ULONG RenderButton(CGLOB *z, Class *cl, struct Gadget *g, struct gpRender *msg, struct ButtonData *inst, BOOL sel);

#define IntuitionBase	z->IntuitionBase
#define UtilityBase		z->UtilityBase
#define GfxBase			z->GfxBase

Class *initButtonGadgetClass(struct Library *IBase, struct Library *UBase, struct Library *GBase)
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
		if( cl = MakeClass( NULL, "gadgetclass", NULL, sizeof(struct ButtonData), 0) )
			{
			cl->cl_Dispatcher.h_Entry = (ULONG(*)()) dispatchButtonGadget;
			cl->cl_Dispatcher.h_Data  = z;
			return(cl);
			}
		FreeVec(z);
		}
	return(NULL);
}
#define SysBase			z->SysBase

BOOL freeButtonGadgetClass( Class *cl )
{
  CGLOB *z= cl->cl_Dispatcher.h_Data;
  BOOL retval;

	retval= FreeClass(cl);
	FreeVec(z);
	return( retval );
}

static ULONG __asm dispatchButtonGadget(REG(a0) Class *cl, REG(a2) Object *o, REG(a1) Msg msg)
{
  CGLOB  *z= cl->cl_Dispatcher.h_Data;
  struct Gadget *g= (struct Gadget *)o;
  struct gpInput *gpi = (struct gpInput *)msg;
  struct InputEvent *ie;
  struct RastPort *rp;
  struct ButtonData *inst;
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
				inst->lastState=0;
				inst->text = (UBYTE *)GetTagData(BUT_Text, NULL, ti);
				inst->color= (UWORD)GetTagData(BUT_Color, ~0, ti);
				inst->backcolor= (UWORD) GetTagData(BUT_BackColor, ~0, ti);
				inst->image = (struct Image *) GetTagData(BUT_Image, 0, ti);
				inst->simage= (struct Image *) GetTagData(BUT_SelectImage, 0, ti);
				inst->flags = (WORD)(GetTagData(BUT_Drawer, 0, ti) ? FLAG_DRAWER : 0);
				z->textFont= (struct TextFont *) GetTagData(BUT_TextFont, 0, ti);
				}
			retval= (ULONG)object;
			break;
		case GM_HITTEST:
			D( kprintf("GM_HITEST\n"); )
			retval = GMR_GADGETHIT;
			break;
		case GM_GOACTIVE:
			D( kprintf("GM_GOACTIVE\n"); )
			inst= INST_DATA(cl, o);
			if( gpi->gpi_IEvent && !(g->Flags & GFLG_DISABLED) )
				{
				g->Flags |= GFLG_SELECTED;
				RenderButton(z, cl, g, (struct gpRender *)msg, inst, g->Flags & GFLG_SELECTED);
				retval=  GMR_MEACTIVE;
				}
			else
				{
				retval= GMR_NOREUSE;
				}
			break;
		case GM_RENDER:
			D( kprintf("GM_RENDER\n"); )
			inst= INST_DATA(cl, o);
			retval= RenderButton(z, cl, g, (struct gpRender *)msg, inst, g->Flags & GFLG_SELECTED);
			break;
		case GM_HANDLEINPUT:
			D( kprintf("GM_HANDLEINPUT\n"); )
			retval= GMR_MEACTIVE;

			ie= gpi->gpi_IEvent;
			if( ie == NULL ) break;
			switch( ie->ie_Class )
				{
				case IECLASS_RAWMOUSE:
					switch( ie->ie_Code )
						{
						case SELECTUP:
							if( (gpi->gpi_Mouse.X < 0 ) ||
								(gpi->gpi_Mouse.X > g->Width) ||
								(gpi->gpi_Mouse.Y < 0 ) ||
								(gpi->gpi_Mouse.Y > g->Height) )
								{
								retval= GMR_REUSE;
								}
							else
								{
								retval= GMR_NOREUSE | GMR_VERIFY;
								}
							break;
						case MENUDOWN:
							retval= GMR_NOREUSE;
							break;
						case IECODE_NOBUTTON:
							inst= INST_DATA(cl, o);

							if( (gpi->gpi_Mouse.X < 0 ) ||
								(gpi->gpi_Mouse.X > g->Width) ||
								(gpi->gpi_Mouse.Y < 0 ) ||
								(gpi->gpi_Mouse.Y > g->Height) )
								{
								if( inst->lastState )
									{
									g->Flags &= ~GFLG_SELECTED;
									RenderButton(z, cl, g, (struct gpRender *)msg, inst, FALSE);
									inst->lastState=FALSE;
									}
								}
							else
								{
								if( !inst->lastState )
									{
									g->Flags |= GFLG_SELECTED;
									RenderButton(z, cl, g, (struct gpRender *)msg, inst, TRUE);
									inst->lastState=TRUE;
									}
								}
							break;
						}
					break;
				}
			break;
		case GM_GOINACTIVE:
			D( kprintf("GM_GOINACTIVE\n"); )
			g->Flags &= ~GFLG_SELECTED;
			inst= INST_DATA(cl, o);
			retval= RenderButton(z, cl, g, (struct gpRender *)msg, inst, g->Flags & GFLG_SELECTED);
			break;			
		case OM_SET:
			D( kprintf("OM_SET\n"); )
			ti= ((struct opSet *)msg)->ops_AttrList;
			if( FindTagItem(GA_Width,  ti) ||
				FindTagItem(GA_Height, ti) ||
				FindTagItem(GA_Top,    ti) ||
				FindTagItem(GA_Left,   ti) ||
				FindTagItem(BUT_Text,  ti) ||
				FindTagItem(BUT_Color, ti) ||
				FindTagItem(BUT_BackColor, ti) ||
				FindTagItem(BUT_Image, ti) ||
				FindTagItem(BUT_SelectImage, ti) ||
				FindTagItem(BUT_Drawer, ti) )
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
					inst->text = (UBYTE *)GetTagData(BUT_Text, (ULONG)inst->text, ti);
					inst->color= (UWORD)GetTagData(BUT_Color, inst->color, ti);
					inst->backcolor= (UWORD) GetTagData(BUT_BackColor, inst->backcolor, ti);
					z->textFont= (struct TextFont *)GetTagData(BUT_TextFont, (ULONG)z->textFont, ti);
					inst->image = (struct Image *) GetTagData(BUT_Image, (ULONG)inst->image, ti);
					inst->simage= (struct Image *) GetTagData(BUT_SelectImage, (ULONG)inst->simage, ti);
					if( tmp=FindTagItem(BUT_Drawer, ti) )
						{
						inst->flags = ( tmp->ti_Data ? FLAG_DRAWER : 0);
						}

					DoMethod(o, GM_RENDER, ((struct opSet *)msg)->ops_GInfo, rp, GREDRAW_REDRAW);
					ReleaseGIRPort(rp);
					}
				}
			else if( FindTagItem(GA_Selected, ti) ||
					 FindTagItem(GA_Disabled, ti) )
				{
				/*
				 * GA_Selected and GA_Disabled need a refresh of the gadget.
				 * The parent class will set the selected or disabled bits
				 * of the gadget->Flags.
				 */
				retval= DoSuperMethodA(cl, o, msg);

				if( rp=ObtainGIRPort( ((struct opSet *)msg)->ops_GInfo) )
					{
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
				case BUT_Text:
					*(opget->opg_Storage)= (ULONG)inst->text;
					break;
				case BUT_Color:
					*(opget->opg_Storage)= (ULONG)inst->color;
					break;
				case BUT_BackColor:
					*(opget->opg_Storage)= (ULONG)inst->backcolor;
					break;
				case BUT_Image:
					*(opget->opg_Storage)= (ULONG)inst->image;
					break;
				case BUT_SelectImage:
					*(opget->opg_Storage)= (ULONG)inst->simage;
					break;
				case BUT_Drawer:
					*(opget->opg_Storage)= (ULONG)( inst->flags & FLAG_DRAWER );
					break;
				case BUT_TextFont:
					*(opget->opg_Storage)= (ULONG)z->textFont;
					break;
				default:
					retval= DoSuperMethodA(cl, o, msg);
				}
			break;
		default:
			D( kprintf("DEFAULT\n"); )
			retval= DoSuperMethodA(cl, o ,msg);
			break;
		}
	return( retval );
}

static void drawPoints(CGLOB *z, struct RastPort *rp, WORD b_x, WORD b_y, WORD n, const WORD *pt)
{
	while( n-- )
		{
		Draw(rp, b_x + *pt, b_y + *(pt+1));
		pt += 2;
		}
}

static const WORD draw_points[] = { 11,0, 11,-6, 9,-8, 6,-8, 4,-6, 0,-6, 0,-1, 1,-1, 1,-5, 5,-5, 6,-4, 10,-4};

static UWORD strUcpy(UBYTE *dest, UBYTE *src)
{
  UBYTE *start=src;
  UWORD uline=0;

	while( *src )
		{
		if( *src == '_' )
			{
			uline = src - start + 1;
			src++;
			}
		else
			{
			*dest++ = *src++;
			}
		}
	return(uline);
}

static ULONG RenderButton(CGLOB *z, Class *cl, struct Gadget *g, struct gpRender *msg, struct ButtonData *inst, BOOL sel)
{
  struct RastPort *rp;
  ULONG retval=TRUE;
  UWORD *pens= msg->gpr_GInfo->gi_DrInfo->dri_Pens;
  UWORD slen;
  struct TextExtent te;

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
		UBYTE back, shine, shadow, text;
		UWORD x, y, w, h, text_x, text_y;
		UBYTE *str=NULL;
		UWORD underline;
		UWORD depth= 1 << rp->BitMap->Depth;
		UBYTE oldAPen, oldDrMd;
		struct TextFont *oldTextFont;
		ULONG state;

		oldAPen= rp->FgPen;
		oldDrMd= rp->DrawMode;
		oldTextFont= rp->Font;

		if( sel )
			{
			back  = pens[FILLPEN];
			shine = pens[SHADOWPEN];
			shadow= pens[SHINEPEN];
			text  = pens[FILLTEXTPEN];
			}
		else
			{
			back  = pens[BACKGROUNDPEN];
			shine = pens[SHINEPEN];
			shadow= pens[SHADOWPEN];
			text  = pens[TEXTPEN];
			if( inst->backcolor != (UWORD)~0 )
				{
				back= inst->backcolor;
				}
			}
		if( inst->color != (UWORD)~0 )
			{
			text= inst->color;
			}
		if( (back % depth) == (text % depth) )
			{
			if( (back % depth) == 0 )
				{
				text= 1;
				}
			else
				{
				text= 0;
				}
			}


		x= g->LeftEdge;	
		y= g->TopEdge;
		w= g->Width-1;
		h= g->Height-1;

		if( inst->text )
			{
			if( z->textFont ) SetFont(rp, z->textFont);
			slen= strlen(inst->text);

			if( str = AllocVec(slen, MEMF_ANY) )
				{
				underline = strUcpy(str, inst->text);
				if( underline ) slen--;

				TextExtent(rp, str, slen, &te);
				text_x= x + (w+1)/2 - te.te_Width/2;
				text_y= y + (h+1)/2 - (te.te_Extent.MaxY - te.te_Extent.MinY + 1)/2 - te.te_Extent.MinY;
				}
			}

		SetDrMd(rp, JAM1);
		SetAPen(rp, back);
		RectFill( rp, x+2, y+1, x+w-2, y+h-1 );

		SetAPen(rp, shadow);
		RectFill(rp, x+1, y+h, x+w, y+h);
		RectFill(rp, x+w-1, y+1, x+w-1, y+h);
		RectFill(rp, x+w, y, x+w, y+h);
		
		if( str )
			{
			SetAPen(rp, text);
			Move(rp, text_x, text_y);
			Text(rp, str, slen);

			if( underline )
				{
				slen= TextLength(rp, str, underline - 1);
				text_x += slen;
				slen= TextLength(rp, str + underline - 1, 1);
				RectFill(rp, text_x, text_y + te.te_Extent.MaxY,
							text_x + slen - 1, text_y + te.te_Extent.MaxY);
				}
			}

		if( inst->image || inst->simage )
			{
			UWORD image_x, image_y;
			struct Image *image;

			if( g->Flags & GFLG_SELECTED )
				{
				if( inst->simage )
					{
					state= IDS_NORMAL;
					image= inst->simage;
					}
				else
					{
					state= IDS_SELECTED;
					image= inst->image;
					}
				}
			else
				{
				state= IDS_NORMAL;
				image= inst->image;
				}
			image_x= x + (w+1)/2 - image->Width/2;
			image_y= y + (h+1)/2 - image->Height/2;
			DrawImageState(rp, image, image_x, image_y, state, msg->gpr_GInfo->gi_DrInfo);
			}
		if( inst->flags & FLAG_DRAWER )
			{
			WORD b_x, b_y;

			SetAPen(rp, text);
			b_x = x + (w+1)/2 - 6;
			b_y = y + (h+1)/2 + 3;
			Move(rp, b_x, b_y );
			drawPoints(z, rp, b_x, b_y, 12, draw_points);
			}

		SetAPen(rp, shine);
		RectFill(rp, x, y, x+w-1, y);
		RectFill(rp, x, y+1, x, y+h);
		RectFill(rp, x+1, y+1, x+1, y+h-1);

		if( g->Flags & GFLG_DISABLED )
			{
			UWORD area_pattern[]= {0x1111, 0x4444};
			UWORD *oldAfPt;
			UBYTE oldAfSize;

			oldAfPt= rp->AreaPtrn;
			oldAfSize= rp->AreaPtSz;

			SetAPen(rp, text);
			SetAfPt(rp, area_pattern, 1);
			RectFill(rp, x, y, x+w, y+h);

			SetAfPt(rp, oldAfPt, oldAfSize);
			}

		SetAPen(rp, oldAPen);
		SetDrMd(rp, oldDrMd);
		SetFont(rp, oldTextFont);

		FreeVec(str);

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

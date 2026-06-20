/*
**
**	ShuttleWheelGadget.c	
**	© 1996-1999 by Stephan Rupprecht
**
**	based on DialGadget.c (AmigaDev CD)
**
*/

#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <intuition/imageclass.h>
#include <intuition/icclass.h>
#include <graphics/gfxmacros.h>
#include <graphics/gfxbase.h>
#include <exec/memory.h>
//#include <libraries/mathieeesp.h>

#include <pragma/intuition_lib.h>
#include <pragma/graphics_lib.h>
#include <pragma/utility_lib.h>
#include <pragma/mathieeesingtrans_lib.h>
#include <pragma/mathieeesingbas_lib.h>

#pragma header

/*-INSTANCEDATA AND TAGS--------------------------------------------------*/

struct ShuttleWheelIData { 
	Point	Coord;	/* ray vector of needle			*/
	Point	Base;  	/* vector for base of needle		*/
	Point	PrevCoord;	 
	Point	PrevBase;
	Point	OldCoord;	 
	Point	OldBase;
	WORD	RadiusX;
	WORD	RadiusY;
	UWORD	Min;
	UWORD	Max;
	UWORD	Current;
	UWORD	OldCurrent;
	UWORD	Depth;
	UWORD	MaxPen;
	struct 	AreaInfo	AreaInfo;
	struct 	TmpRas		TmpRas;
	UBYTE	AreaBuffer[4 * 5];
};

#define SW_Min		(TAG_USER + 1)
#define SW_Max		(TAG_USER + 2)
#define SW_Current	(TAG_USER + 3)

/*-PROTOS-----------------------------------------------------------------*/

Class *InitShuttleWheelClass(void);  
ULONG ShuttleWheelDispatcher(register __a0 Class *, register __a2 Object *, register __a1 Msg);
BOOL FreeShuttleWheelClass(Class *);           

/*-NORMALIZECOORDS--------------------------------------------------------*/

/* converts values of coordX coordY to ray equivalent
 * coordinates on ellipse boundary of dial.
 */
void NormalizeCoords(struct ShuttleWheelIData *idata)
{
	struct FPoint	{ float	fX,fY; } edge;
	WORD		halfx = idata -> RadiusX - 1, 
				halfy = idata -> RadiusY - 1;
	float		norm;
	Point		ray;
	
	ray = idata->Coord;
		
	norm = IEEESPSqrt( (float) ((float)(halfy * halfy) * (float) ray.x * (float) ray.x) + 
				(float) ((float)(halfx * halfx) * (float) ray.y * (float) ray.y) );
	
	/* I forgot what clever math leads to this	*/
	edge.fX = (float) halfy * (float) ray.x / (float) norm;
	edge.fY = (float) halfx * (float) ray.y / (float) norm;
	
	idata->Coord.x = (WORD) ( (float) halfx * (float) edge.fX );
	idata->Coord.y = (WORD) ( (float) halfy * (float) edge.fY );
	
	idata->PrevBase = idata->Base;
	
	idata->Base.x = (WORD) ( (float) halfx * ((float) edge.fY / (float) 4.0) );
	idata->Base.y = (WORD) ( (float) halfy * ((float) -edge.fX / (float) 4.0) );
}

/*-SETCOORDS--------------------------------------------------------------*/

void SetCoords(struct ShuttleWheelIData *idata, WORD x, WORD y)
{
	 if(!(x||y))
	 {
		 x = 0; 
		 y = -1; 
	 }
	
	 idata->PrevCoord = idata->Coord;
	
	 idata->Coord.x = x;
	 idata->Coord.y = y;
	
	 NormalizeCoords( idata );
}

/*-SCANATTRLIST-----------------------------------------------------------*/

ULONG ScanAttrList(struct ShuttleWheelIData *idata, struct TagItem *list)
{
	struct TagItem	*ti;
	UWORD  			curr, min, max;
	
	curr = idata->Current;
	min = idata->Min;
	max = idata->Max;
	
	while(ti = NextTagItem(&list)) 
	{
		UWORD data = ti->ti_Data;
		
		switch(ti->ti_Tag)
		{
			case SW_Current: 	
				idata->Current = data;
			break;
			
			case SW_Min:
				idata->Min = data;	
			break;
			
			case SW_Max:
				idata->Max = data;	
			break; 
		}
	}
	
	if(curr != idata->Current || min != idata->Min || max != idata->Max)
	{
		float fr = (float) ( (idata->Current-idata->Min) - ( (idata->Max-idata->Min) /4 ) ) / 
					( (float) ( (idata->Max-idata->Min)/2 ) / (float) 3.14);
							
		SetCoords(idata, (WORD) ( IEEESPCos((float)fr) * (float) (idata->RadiusX) ),
		(WORD) ( IEEESPSin((float)fr) * (float) (idata->RadiusY) ) );
		
		return(1L);
	}
	
	return(0L);
}

/*------------------------------------------------------------------------*/

/* init class */
Class *InitShuttleWheelClass(void)               
{                                              
	Class  *cl;
	
	if(cl =  MakeClass( NULL, "gadgetclass", NULL, sizeof ( struct ShuttleWheelIData ), 0))           
		cl->cl_Dispatcher.h_Entry = (HOOKFUNC) ShuttleWheelDispatcher; 
	
	return (cl);
}

/*------------------------------------------------------------------------*/

/* free class */
BOOL FreeShuttleWheelClass(Class *cl)
{
	return(FreeClass(cl));
}

/*------------------------------------------------------------------------*/

/* OM_NEW */
ULONG ShuttleWheel_NEW(Class *cl, Object *o, Msg msg)
{
	ULONG retval;
	
	if(retval = DoSuperMethodA(cl, o, msg)) 
	{        
		struct ShuttleWheelIData	*idata;
		struct DrawInfo			*dri;
		UWORD	w = ((struct Gadget *)retval)->Width,
				h = ((struct Gadget *)retval)->Height;
	
		idata = INST_DATA(cl, retval);
	
		if(dri = (struct DrawInfo *)GetTagData(GA_DrawInfo, 0L, ((struct opSet *)msg)->ops_AttrList))
		{        
			WORD	xres = dri->dri_Resolution.X,
				  	yres = dri->dri_Resolution.Y, 
				  	maxpen = 0, i,
					pens[] = { SHINEPEN, SHADOWPEN, BACKGROUNDPEN, FILLPEN };
	
			for(i = 0; i < 4; i++)
				if(dri->dri_Pens[pens[i]] > maxpen) 
					maxpen = dri->dri_Pens[pens[i]];
	
			idata->MaxPen = maxpen;
	      	
			if(w > h)   
			{
				UWORD maxw = w;
				
				do { w = h * yres / xres; h--; } 
				while( w > maxw ); 
				
				h++;
			}
			else 
			{
				UWORD maxh = h;
				
				do { h = w * xres / yres; w--; } 
				while( h > maxh );
				
				w++;	
			}	
			
			idata->RadiusX = w = (w / 2) - 8; w *= 2;  
			idata->RadiusY = h = (h / 2) - 6; h *= 2;
			
			idata->Depth = dri->dri_Depth;
			idata->TmpRas.RasPtr = AllocRaster(w * dri->dri_Depth, h);

			idata->Max = 0xffff;
			
			DoMethod(retval, OM_SET, ((struct opSet *)msg)->ops_AttrList, ((struct opSet *)msg)->ops_GInfo);
		} 
		
		if(!(((struct Gadget *)retval)->GadgetRender = NewObject(NULL, "frameiclass", 
			IA_Width, ((struct Gadget *)retval)->Width,
			IA_Height, ((struct Gadget *)retval)->Height, 
			IA_FrameType, FRAME_BUTTON,				       
			TAG_DONE)) || !(dri) || !(idata->TmpRas.RasPtr))
			{
				CoerceMethod(cl, retval, OM_DISPOSE); 
				retval = NULL;
			} 
			else 
			{
				InitArea(&idata->AreaInfo, idata->AreaBuffer, 4);
				InitTmpRas(&idata->TmpRas, idata->TmpRas.RasPtr, RASSIZE(w * dri->dri_Depth, h));
			}
	}
	return(retval);
}

/*------------------------------------------------------------------------*/

/* GM_HITTEST */

#define ABS(x)	( (x) < 0 ? -(x) : (x) )

ULONG ShuttleWheel_HITTEST(Class *cl, struct Gadget *g, struct gpHitTest *gpht)
{
	struct ShuttleWheelIData *idata = INST_DATA(cl, (Object *)g);
	WORD	halfx = idata -> RadiusX, 
			halfy = idata -> RadiusY;
	float	norm;
	Point	ray;
	
	if( ( ray.x = ABS(gpht -> gpht_Mouse . X - g -> Width/2) ) &&
	     ( ray.y = ABS(gpht -> gpht_Mouse . Y - g -> Height/2) ) )
	{
		norm = IEEESPSqrt( (float) (halfy * halfy * ray.x * (float) ray.x) +
			(float) (halfx * halfx * ray.y * (float) ray.y) );
	
		return( ray.x <= (WORD) ( (float) halfx * ( (float) halfy * ray.x / norm ) ) &&
				ray.y <= (WORD) ( (float) halfy * ( (float) halfx * ray.y / norm ) ) );
	}
	
	return TRUE;
}

/*------------------------------------------------------------------------*/

ULONG ShuttleWheel_NOTIFY(Class *cl, Object *o, struct opUpdate *msg, ULONG flags)
{
	 struct ShuttleWheelIData *idata = INST_DATA(cl, o);
	 struct TagItem ti[] = { 	GA_ID, ((struct Gadget *)o)->GadgetID,
						 SW_Current, idata->Current,
						 ICSPECIAL_CODE, idata->Current, 
						 TAG_END 
					}; 
	 struct GadgetInfo *gi;
	
	 if(msg->MethodID == OM_NOTIFY)
	 {
	 	gi = msg->opu_GInfo;
		flags = msg->opu_Flags;
	
		if(msg->opu_AttrList)
	  	{
			ti[3].ti_Tag = TAG_MORE;
			ti[3].ti_Data = (ULONG) msg->opu_AttrList;
	  	}
	 }
	 else gi = ((struct gpInput *)msg)->gpi_GInfo;
	
	return( DoSuperMethod(cl, o, OM_NOTIFY, ti, gi, flags ) );
}

/*------------------------------------------------------------------------*/

/* GM_HANDLEINPUT */
ULONG ShuttleWheel_HANDLEINPUT(Class *cl, struct Gadget *g, struct gpInput *msg)
{
	 struct ShuttleWheelIData *idata = INST_DATA(cl, (Object *)g);
	 struct InputEvent        *ie = msg->gpi_IEvent;
	 ULONG			   retval = 0L;
	
	 if(ie && ie->ie_Class == IECLASS_RAWMOUSE)
	 {
	 	struct GadgetInfo 	*gi = msg->gpi_GInfo;
		struct RastPort   	*rp;
		WORD	 		mousex, mousey;
		BOOL   			hit; 
	  
		if(msg->MethodID == GM_GOACTIVE)
		{
			idata->OldBase = idata->Base;
			idata->OldCoord = idata->Coord;
			idata->OldCurrent = idata->Current;
		}
		
		mousex = msg->gpi_Mouse.X - g->Width/2;
		mousey = msg->gpi_Mouse.Y - g->Height/2;
		
		SetCoords(idata, mousex, mousey);
		
		hit = ShuttleWheel_HITTEST(cl, g, (struct gpHitTest *)&msg->gpi_IEvent);
		
		if(rp = ObtainGIRPort(gi))
		{
			ULONG gredraw = GREDRAW_UPDATE;
			
			if(hit && !(g->Flags & GFLG_SELECTED))
			{
				g -> Flags |= GFLG_SELECTED;
				gredraw = GREDRAW_TOGGLE; 
			} 
			else if(!hit && (g->Flags & GFLG_SELECTED))
			{
				g -> Flags &= ~GFLG_SELECTED;
				gredraw = GREDRAW_TOGGLE;
			}
		 		
			DoMethod(g, GM_RENDER, gi, rp, gredraw);    
			ReleaseGIRPort(rp);
		}
			
		mousey = g->Height/2 - msg->gpi_Mouse.Y;
		
		{      
			UWORD 	max = idata->Max - idata->Min, curr,
					xr = idata->RadiusX, yr = idata->RadiusY;
			FLOAT 	fx = (float) mousex, fy = (float) mousey;  
			
			if(xr > yr) fy *= (float) xr / (float) yr;
			else fx *= (float) yr / (float) xr;
			
			curr = mousey ? (WORD) ( IEEESPAtan( (float) fx / (float) fy ) * (float) (max/2) / (float) 3.14) : 0;
			
			if(mousex >= 0 && !mousey) curr = max/4; 
			if(mousey < 0) 
			if(mousex > 0) curr += max/2-1;
			else if(!mousex) curr = max/2; 
			
			if(mousex < 0) 
			if(mousey < 0) curr += max/2;  
			else if(mousey > 0) curr += max;  
			else if(!mousey) curr = (max*2+max)/4; 
			
			curr += idata->Min;
			
			if(hit && curr != idata->Current) 
			{
				idata->Current = curr;
				ShuttleWheel_NOTIFY(cl, (Object *)g, (struct opUpdate *)msg, OPUF_INTERIM);
			}
		}
			
		if(ie->ie_Code == MENUDOWN || (!hit && ie->ie_Code == SELECTUP) )
		{
			idata->Coord = idata->OldCoord;
			idata->Base = idata->OldBase;
			*msg->gpi_Termination = idata->Current = idata->OldCurrent;
			ShuttleWheel_NOTIFY(cl, (Object *)g, (struct opUpdate *)msg, 0L);  
			retval = GMR_NOREUSE | GMR_VERIFY;
		} 
		else if(ie->ie_Code == SELECTUP) 
		{
			*msg->gpi_Termination = idata->Current;	
			ShuttleWheel_NOTIFY(cl, (Object *)g, (struct opUpdate *)msg, 0L);  
			retval = GMR_NOREUSE | GMR_VERIFY; 
		} 
		else retval = GMR_MEACTIVE;
	 }
	 
	 return(retval);
}
    
/*------------------------------------------------------------------------*/

/* GM_RENDER */
ULONG ShuttleWheel_RENDER(Class *cl, struct Gadget *g, struct gpRender *gpr)
{
	struct RastPort 	  *rp;
	
	/* get rastport */
	if(rp = ( gpr->MethodID == GM_RENDER ? gpr->gpr_RPort : ObtainGIRPort(gpr->gpr_GInfo)))
	{
		struct ShuttleWheelIData *idata = INST_DATA(cl, (Object *)g);
		WORD	x = g->LeftEdge, y = g->TopEdge,
				w = g->Width, h = g->Height, 
				xradius = idata->RadiusX, yradius = idata->RadiusY;
		UWORD	*pens = gpr->gpr_GInfo->gi_DrInfo->dri_Pens, fill;
	
		SetDrMd(rp, JAM1);   
	
		if((gpr->MethodID == GM_RENDER) && (gpr->gpr_Redraw == GREDRAW_REDRAW))
			DrawImageState(rp, g->GadgetRender, x,y, IDS_NORMAL, gpr->gpr_GInfo->gi_DrInfo);
	
		SetMaxPen(rp, idata->MaxPen);
		
		x += w/2; y += h/2; 
		
		fill = pens[(g->Flags & GFLG_SELECTED)?BACKGROUNDPEN:FILLPEN];  
		
		rp->AreaInfo = &idata->AreaInfo;
		rp->TmpRas   = &idata->TmpRas;
		    
		if(!(gpr->MethodID == GM_RENDER && gpr->gpr_Redraw == GREDRAW_UPDATE))
		{   
			SetAPen( rp, fill );
		
			if(!(g->Flags & GFLG_SELECTED)) 
			{ 
				SetOutlinePen(rp, pens[SHADOWPEN]);
				AreaEllipse(rp, x, y, xradius, yradius);
				AreaEnd(rp);     
				BNDRYOFF(rp);    
				SetAPen( rp, pens[SHADOWPEN] );
				DrawEllipse(rp, x, y, xradius+1, yradius+1);
				DrawEllipse(rp, x, y, xradius+1, yradius);
				DrawEllipse(rp, x, y, xradius, yradius+1);
			} 
			else 
			{ 
				EraseRect(rp,  x-xradius, y-yradius, x+xradius, y+yradius); 
				SetAPen(rp, pens[SHINEPEN]); 
				DrawEllipse(rp, x, y, xradius, yradius);
				DrawEllipse(rp, x, y, xradius+1, yradius+1);
				DrawEllipse(rp, x, y, xradius+1, yradius);
				DrawEllipse(rp, x, y, xradius, yradius+1);
			}
		} 
		
		/* clear old needle */
		SetAPen( rp, fill );
		
		AreaEllipse( rp, x + (idata->PrevCoord.x/4 + idata->PrevCoord.x/2), y + (idata->PrevCoord.y/4 + idata->PrevCoord.y/2), xradius/10, yradius/10 );
		AreaEnd( rp );
		DrawEllipse( rp, x + (idata->PrevCoord.x/4 + idata->PrevCoord.x/2), y + (idata->PrevCoord.y/4 + idata->PrevCoord.y/2), xradius/10+1, yradius/10+1 );
		DrawEllipse( rp, x + (idata->PrevCoord.x/4 + idata->PrevCoord.x/2), y + (idata->PrevCoord.y/4 + idata->PrevCoord.y/2), xradius/10+1, yradius/10 );
		DrawEllipse( rp, x + (idata->PrevCoord.x/4 + idata->PrevCoord.x/2), y + (idata->PrevCoord.y/4 + idata->PrevCoord.y/2), xradius/10, yradius/10+1 );

/*		Move( rp, x + idata->PrevBase.x, y + idata->PrevBase.y );
		Draw( rp, x - idata->PrevBase.x, y - idata->PrevBase.y );
		Draw( rp, x + idata->PrevCoord.x, y + idata->PrevCoord.y );
		Draw( rp, x + idata->PrevBase.x, y + idata->PrevBase.y );*/

		
/*		AreaMove( rp, x + idata->PrevBase.x, y + idata->PrevBase.y );
		AreaDraw( rp, x - idata->PrevBase.x, y - idata->PrevBase.y );
		AreaDraw( rp, x + idata->PrevCoord.x, y + idata->PrevCoord.y );
		WaitTOF();
		AreaEnd( rp );*/
		
		/* draw new needle */
/*		SetAPen(rp, pens[g->Flags & GFLG_SELECTED ? FILLPEN : SHINEPEN]); 
		SetOutlinePen(rp, pens[SHADOWPEN]);
		
		AreaMove( rp, x + idata->Base.x, y + idata->Base.y );
		AreaDraw( rp, x - idata->Base.x, y - idata->Base.y );
		AreaDraw( rp, x + idata->Coord.x, y + idata->Coord.y );
		WaitTOF();
		AreaEnd( rp ); 
		BNDRYOFF(rp); */
		

		SetOutlinePen(rp, pens[SHADOWPEN]);
		SetAPen( rp, pens[SHINEPEN] );
		AreaEllipse( rp, x + (idata->Coord.x/4 + idata->Coord.x/2), y + (idata->Coord.y/4 + idata->Coord.y/2), xradius/10, yradius/10 );
		AreaEnd( rp );
		SetAPen( rp, pens[SHADOWPEN] );
		DrawEllipse( rp, x + (idata->Coord.x/4 + idata->Coord.x/2), y + (idata->Coord.y/4 + idata->Coord.y/2), xradius/10+1, yradius/10+1 );
		DrawEllipse( rp, x + (idata->Coord.x/4 + idata->Coord.x/2), y + (idata->Coord.y/4 + idata->Coord.y/2), xradius/10+1, yradius/10 );
		DrawEllipse( rp, x + (idata->Coord.x/4 + idata->Coord.x/2), y + (idata->Coord.y/4 + idata->Coord.y/2), xradius/10, yradius/10+1 );
		
/*		Move( rp, x + idata->Base.x, y + idata->Base.y );
		Draw( rp, x - idata->Base.x, y - idata->Base.y );
		Draw( rp, x + idata->Coord.x, y + idata->Coord.y );
		Draw( rp, x + idata->Base.x, y + idata->Base.y );*/
		
		/* ghost gadget, if flag set */
		if(g->Flags & GFLG_DISABLED) 
		{ 
			ULONG patt = 0x11114444;
			
			SetAfPt(rp, (UWORD *)&patt, 1); SetAPen(rp, pens[SHADOWPEN]); 
			RectFill(rp, g->LeftEdge, g->TopEdge, g->LeftEdge+w-1, g->TopEdge+h-1);
			SetAfPt(rp, NULL, 0); 
		}
		
		if(gpr->MethodID != GM_RENDER) ReleaseGIRPort(rp);
	}
		
	return(0L);
}

/*------------------------------------------------------------------------*/

/* OM_GET */
ULONG ShuttleWheel_GET(Class *cl, Object *o, struct opGet *msg)
{
	struct ShuttleWheelIData *idata = INST_DATA(cl, o);
	ULONG  storage = 0L;
	BOOL   asksuper = FALSE;
	
	switch(msg->opg_AttrID)
	{
		case SW_Current :
			storage = idata->Current;
		break;
		
		case SW_Min :
			storage = idata->Min;
		break;
		
		case SW_Max :
			storage = idata->Max;
		break;
		
		default:
			asksuper = TRUE;
	}
	 
	*(msg->opg_Storage) = storage;
	return( asksuper ? DoSuperMethodA(cl, o, msg) : TRUE );
}

/*------------------------------------------------------------------------*/

/* OM_UPDATE */
ULONG ShuttleWheel_UPDATE(Class *cl, Object *o, struct opUpdate *msg)
{
	struct ShuttleWheelIData *idata = INST_DATA(cl, o);
	struct TagItem	ti = { TAG_END };
	struct RastPort *rp;
	ULONG  retval;
	
	DoSuperMethodA(cl, o, msg);
	
	if( retval = ScanAttrList( idata, msg->opu_AttrList ) )
		if( rp = ObtainGIRPort( msg->opu_GInfo ) )
		{
			DoMethod( o, GM_RENDER, msg->opu_GInfo, rp, GREDRAW_UPDATE );    
			ReleaseGIRPort( rp );
		} 
	
	idata->OldCoord = idata->Coord;
	idata->OldBase = idata->Base;
	
	DoMethod( o, OM_NOTIFY, &ti, msg->opu_GInfo, msg->MethodID == OM_UPDATE ? msg->opu_Flags : 0L );
	
	return(retval);
}

/*------------------------------------------------------------------------*/

/* dispatcher */
ULONG ShuttleWheelRealDispatcher(Class *cl, Object *o, Msg msg)
{
	ULONG retval;
	
	switch(msg->MethodID)
	{
		case GM_GOACTIVE:
		case GM_HANDLEINPUT:
			retval = ShuttleWheel_HANDLEINPUT(cl, (struct Gadget *)o, (struct gpInput *)msg);
		break;
		
		case GM_RENDER:
			retval = ShuttleWheel_RENDER(cl, (struct Gadget *)o, (struct gpRender *)msg);
		break;
		
		case GM_HITTEST:
			retval = ShuttleWheel_HITTEST(cl, (struct Gadget *)o, (struct gpHitTest *)msg);
		break;
		
		case GM_GOINACTIVE:
			((struct Gadget *)o)->Flags &= ~GFLG_SELECTED;
			ShuttleWheel_RENDER(cl, (struct Gadget *)o, (struct gpRender *)msg);
			retval = 0L;
		break;
		
		case OM_SET:
		case OM_UPDATE:
			retval = ShuttleWheel_UPDATE(cl, o, (struct opUpdate *)msg);
		break;
		
		case OM_NOTIFY:
			retval = ShuttleWheel_NOTIFY(cl, o, (struct opUpdate *)msg, 0L);
		break;
		
		case OM_GET:
			retval = ShuttleWheel_GET(cl, o, (struct opGet *)msg);
		break;
		
		case OM_NEW:
			retval = ShuttleWheel_NEW(cl, o, msg);
		break;
		
		case OM_DISPOSE:
		{
			struct ShuttleWheelIData *idata = INST_DATA(cl, o);
		
			if(idata->TmpRas.RasPtr) 
				FreeRaster(idata->TmpRas.RasPtr, (2*idata->RadiusX)*idata->Depth, 2*idata->RadiusY);
				
			if(((struct Gadget *)o)->GadgetRender) 
				DisposeObject(((struct Gadget *)o)->GadgetRender);
		}
		
		default:
			retval = DoSuperMethodA(cl, o, msg);  
	}
	
	return(retval);
}

ULONG ShuttleWheelDispatcher(register __a0 Class *cl, register __a2 Object *o, register __a1 Msg msg)
{
	return( ShuttleWheelRealDispatcher(cl, o, msg) ); 
}

/* EOT */

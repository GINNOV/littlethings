/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*	_____________________________

	ABackup Prefs
	getclass.c

	GetFile BOOPSI image.

	© 1991-1993 Jaba Development.
	Written by Jan van den Baard

	Adapted by Reza Elghazi

	All Rights Reserved
	_____________________________

	Version : 38.0
	Created : 08-May-93
	Modified: 22-Apr-95
	_____________________________
*/

#include "headers.h"
#include "getclass.h"

STATIC VOID	DrawGetImage	(Class *,Object *,Msg,WORD *,UBYTE);
STATIC ULONG __saveds __asm	GetFileClassDispatcher	(register __a0 Class *,register __a2 Object *,register __a1 Msg),
							GetDirClassDispatcher	(register __a0 Class *,register __a2 Object *,register __a1 Msg),
							GetElseClassDispatcher	(register __a0 Class *,register __a2 Object *,register __a1 Msg);
//_____________________________________________________________________________

STATIC __saveds __asm ULONG
GetFileClassDispatcher (register __a0 Class *cl,register __a2 Object *obj,register __a1 Msg msg)
{
	if (msg->MethodID == IM_ERASE || msg->MethodID == IM_DRAW) {
		DrawGetImage(cl,obj,msg,GetFilePoly,GETFILEPOLYCOUNT);
		return(1L);
	}
	else return(DoSuperMethodA(cl,obj,msg));
}
//_____________________________________________________________________________

Class *
InitGetFileClass()
{
	Class	*cl;

	if (cl = MakeClass(NULL,_IMAGECLASS_,NULL,0L,0))
		cl->cl_Dispatcher.h_Entry = (ULONG (*)())GetFileClassDispatcher;

	return(cl);
}
//_____________________________________________________________________________

STATIC __saveds __asm ULONG
GetDirClassDispatcher (register __a0 Class *cl,register __a2 Object *obj,register __a1 Msg msg)
{
	if (msg->MethodID == IM_ERASE || msg->MethodID == IM_DRAW) {
		DrawGetImage(cl,obj,msg,GetDirPoly,GETDIRPOLYCOUNT);
		return(1L);
	}
	else return(DoSuperMethodA(cl,obj,msg));
}
//_____________________________________________________________________________

Class *
InitGetDirClass()
{
	Class	*cl;

	if (cl = MakeClass(NULL,_IMAGECLASS_,NULL,0L,0))
		cl->cl_Dispatcher.h_Entry = (ULONG (*)())GetDirClassDispatcher;

	return(cl);
}
//_____________________________________________________________________________

STATIC __saveds __asm ULONG
GetElseClassDispatcher (register __a0 Class *cl,register __a2 Object *obj,register __a1 Msg msg)
{
	if (msg->MethodID == IM_ERASE || msg->MethodID == IM_DRAW) {
		DrawGetImage(cl,obj,msg,GetElsePoly,GETELSEPOLYCOUNT);
		return(1L);
	}
	else return(DoSuperMethodA(cl,obj,msg));
}
//_____________________________________________________________________________

Class *
InitGetElseClass()
{
	Class	*cl;

	if (cl = MakeClass(NULL,_IMAGECLASS_,NULL,0L,0))
		cl->cl_Dispatcher.h_Entry = (ULONG (*)())GetElseClassDispatcher;

	return(cl);
}
//_____________________________________________________________________________

STATIC VOID
DrawGetImage (Class *cl,Object *obj,Msg msg,WORD *getpoly,UBYTE count)
{
	struct impDraw	*dr;
	struct DrawInfo *dri;
	struct RastPort *rp;
	WORD	left,top,height,diff,poly[38];
	UBYTE	c,bckpen,txtpen;

	if (msg->MethodID != IM_DRAW) return;

	dr	= (struct impDraw *)msg;
	dri	= dr->imp_DrInfo;
	rp	= dr->imp_RPort;

	left	= IMAGE(obj)->LeftEdge+dr->imp_Offset.X;
	top		= IMAGE(obj)->TopEdge +dr->imp_Offset.Y;
	height	= IMAGE(obj)->Height;

	SetDrMd(rp,JAM1);

	if (dr->imp_State == IDS_SELECTED) {
		GFBoxTags[0].ti_Tag = GTBB_Recessed;
		bckpen = dri->dri_Pens[FILLPEN];
		txtpen = dri->dri_Pens[FILLTEXTPEN];
	}
	else {
		GFBoxTags[0].ti_Tag = TAG_IGNORE;
		bckpen = dri->dri_Pens[BACKGROUNDPEN];
		txtpen = dri->dri_Pens[TEXTPEN];
	}

	SetAPen(rp,bckpen);
	RectFill(rp,left,top,left+19,top+height-1);

	SetAPen(rp,txtpen);
	DrawBevelBoxA(rp,left,top,20,height,GFBoxTags);

	left += 4;
	top  += height-3;

	for (c = 0,diff = height-14; c < count; c+= 2) {
		poly[c]   = left+getpoly[c];
		poly[c+1] = top;
			 if (getpoly[c+1]<0) poly[c+1] += (getpoly[c+1]-diff);
		else if (getpoly[c+1])   poly[c+1] += (getpoly[c+1]+diff);
	}

	Move(rp,left,top);

	if (getpoly == GetElsePoly) {
		PolyDraw(rp,1,&poly[36]);
		Move(rp,poly[0],poly[1]);
		count -= 2;
	}

	PolyDraw(rp,count/2,&poly[0]);
}

// Tab size: 4

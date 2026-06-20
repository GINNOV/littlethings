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
/*	___________________

	ABackup Prefs
	fillclass.c

	© 1993 Michael Berg
	     & Reza Elghazi
	     & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 10-Nov-93
	Modified: 22-Apr-95
	___________________
*/

#include "headers.h"
#include "fillclass.h"

STATIC VOID	CreateFrameImage	(struct Image *);

//_____________________________________________________________________________

struct Gadget *
CreateBackfill (struct Gadget *prev,struct NewGadget ng,BYTE id)
{
	struct Gadget	*g;

	ng.ng_LeftEdge	 = ng.ng_TopEdge = 0;
	ng.ng_Width		 = ng.ng_Height  = 1;
	ng.ng_GadgetText = NULL;
	ng.ng_GadgetID	 = id;

	if (g = CreateGadgetA(GENERIC_KIND,prev,&ng,NULL)) {
		struct Image	*back;

		bfTags[0].ti_Data = Offset.MinX;
		bfTags[1].ti_Data = Offset.MinY;
		bfTags[2].ti_Data = MWin[NewID].mw_Width;
		bfTags[3].ti_Data = MWin[NewID].mw_Height;

		if (back = IMAGE(NewObjectA(NULL,"fillrectclass",bfTags))) {
			g->GadgetRender = back;
			g->Flags |= GFLG_GADGHNONE | GFLG_GADGIMAGE;

			back->NextImage = NULL;
			CreateFrameImage(back);
		}
	}
	return(g);
}
//_____________________________________________________________________________

__inline STATIC VOID
CreateFrameImage (struct Image *prev)
{
	if (prev) {
		struct Image	*i1;

		fiTags[0].ti_Data = bfTags[0].ti_Data+ComputeX(4);
		fiTags[1].ti_Data = bfTags[1].ti_Data+2*Aspect;
		fiTags[2].ti_Data = bfTags[2].ti_Data-ComputeX(8);
		fiTags[3].ti_Data = bfTags[3].ti_Data-(6*Aspect+FontY+4);
		fiTags[5].ti_Tag  = TAG_DONE;

		if (i1 = IMAGE(NewObjectA(NULL,frclassID,fiTags))) {
			struct Image	*i2;

			fiTags[0].ti_Data++;
			fiTags[2].ti_Data-= 2;
			fiTags[5].ti_Tag  = IA_EdgesOnly;

			if (i2 = IMAGE(NewObjectA(NULL,frclassID,fiTags))) {
				prev->NextImage = i1;
				i1->NextImage	= i2;
			}
		}
	}
}

// Tab size 4

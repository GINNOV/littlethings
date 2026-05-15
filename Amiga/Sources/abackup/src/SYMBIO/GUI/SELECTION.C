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
/*  _______________________________________________________________________

    ABackup 5.0
    selection.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 29-Jun-94
    Modified: 16-Jan-98
    _______________________________________________________________________
*/
#include "headers.h"

STATIC VOID     RedrawDirEntry  (struct Object *,WORD);

struct DirList DL;

//______________________________________________________________________________

// Build the string to display to show the given object:
BYTE
*BuildEntryText(struct Object *obj)
{
	struct DeviceDef	*def;
	LONG    size;
	BYTE    i,*b,bits[9];
	STATIC BYTE     name[80],vname[80],ssize[11];

	if (ObjIsDevice(obj)) {
		strcpy(vname,obj->obj_Name);

		if (PrgAction == PA_BACKUP) {
			if (NOT MyInfo(obj->obj_Name,name)) strcpy(name,"???");
			else if (b = strchr(name,':')) *b = '\0';
			strcat(vname,name);
		}

		if (obj->obj_Size < ONEMEGABYTE) {
			b = GetStr(MSG_KILOBYTES_SHORT);
			size = obj->obj_Size >> 10L;
		}
		else {
			b = GetStr(MSG_MEGABYTES_SHORT);
			size = obj->obj_Size >> 20L;
		}

		// read filesystem type:
		def = GetDeviceDef(obj);
		bits[4] = '\0';
		memcpy(bits,&(def->dd_Env.de_DosType),4);
		if (bits[3] >= 0 && bits[3] < 10) bits[3]+= '0';

		SPrintf(name,"%-32s %4ld %4s %3ld %s  %s  %s",
				vname,
				def->dd_Env.de_HighCyl-def->dd_Env.de_LowCyl+1,
				GetStr(MSG_CYLINDER_SHORT),
				size,
				b,
				bits,
				def->dd_Name);
	}
	else {

		if (ObjIsDir(obj))
			SPrintf(ssize,"%10s",GetStr(MSG_DRAWER));
		else if (ObjIsLink(obj))
			SPrintf(ssize,"%10s",GetStr(MSG_LINK));
		else
			SPrintf(ssize,LOCALEPATCHED? "%10lU": "%10lu",obj->obj_Size);

		// set protection bits:
		for (i = 7,b = bits; i >= 0; i--)
			*b++ = (obj->obj_Bits^15) & (1L<<i)? "hsparwed"[7-i]: '-';
		*b = 0;

		// set file creation day, date and time:
		b = PackedDateToStr(obj->obj_Date);

		SPrintf(name,"%-30s %s %8s %23s",obj->obj_Name,ssize,bits,b);
	}

	return(name);
}
//______________________________________________________________________________

STATIC VOID
RedrawDirEntry (struct Object *obj,WORD ypos)

/*
 * Display the text line corresponding to the given object, using the
 * informations in the DL structure
 */

{
	struct RastPort *rp;
	UWORD   apen,bpen;
	BYTE    *name;

	// define the primary and secondary pens:
	if (ObjIsDevice(obj)) {

		if (ObjIsSelected(obj)) {
			apen = Pens[FILLTEXTPEN];
			bpen = Pens[FILLPEN];
		}
		else {
			apen = Pens[TEXTPEN];
			bpen = Pens[BACKGROUNDPEN];
		}
	}
	else if (ObjIsDir(obj)) {

		if (obj->obj_SelChildren || ObjIsSelected(obj)) {
			apen = Pens[BACKGROUNDPEN];
			bpen = Pens[HIGHLIGHTTEXTPEN];
		}
		else {
			apen = Pens[HIGHLIGHTTEXTPEN];
			bpen = Pens[BACKGROUNDPEN];
		}
	}
	else {

		if (ObjIsSelected(obj)) {
			apen = Pens[FILLTEXTPEN];
			bpen = Pens[FILLPEN];
		}
		else {
			apen = Pens[TEXTPEN];
			bpen = Pens[BACKGROUNDPEN];
		}
	}

	rp = Win->RPort;
	ypos+= DL.dl_YMin;

	// draw selection box:
	SetAPen(rp,bpen);
	RectFill(rp,DL.dl_XMin,ypos,DL.dl_XMax,ypos+DL.dl_Height-1);

	// set primary and secondary pens:
	SetAPen(rp,apen);
	SetBPen(rp,bpen);
	if ( TxtTFont ) SetFont( Win->RPort , TxtTFont ) ;

	// move pen and write text:
	name = BuildEntryText(obj);
	Move(rp,DL.dl_XMin+3,ypos+1+TxtBLine);
	Text(rp,name,strlen(name));
}
//______________________________________________________________________________
/*
// This function draws a file list using ScrFont instead of TxtFont...

__inline STATIC VOID
DrawFileList (WORD ypos,UWORD apen,UWORD bpen,STRPTR size,STRPTR bits,STRPTR date)
{
	struct RastPort *rp;
	WORD    xpos;
	UBYTE   text[32];

	rp = Win->RPort;
	ypos+= DL.dl_YMin;

	// draw selection box:
	SetAPen(rp,bpen);
	RectFill(rp,DL.dl_XMin,ypos,DL.dl_XMax,ypos+DL.dl_Height-1);

	// set primary and secondary pens:
	SetAPen(rp,apen);
	SetBPen(rp,bpen);

	ypos+= TxtBLine+1;

	SPrintf(text,"%-30s",obj->obj_Name);
	xpos = DL.dl_XMin+3;
	DrawText(xpos,ypos,text);

	SPrintf(text," %10s",size);
	xpos+= 30*ScrFontX;
	DrawText(xpos,ypos,text);

	SPrintf(text," %8s",bits);
	xpos+= 11*ScrFontX;
	DrawText(xpos,ypos,text);

	SPrintf(text," %23s",date);
	xpos+= 9*ScrFontX;
	DrawText(xpos,ypos,text);
}

STATIC VOID
DrawText (WORD xpos,WORD ypos,STRPTR text)
{
	Move(rp,xpos,ypos);
	Text(rp,text,strlen(text));
}
*/
//______________________________________________________________________________

VOID
ScrollDirList (struct Object *dir,ULONG top)

/*
 * Update dirs/files list when the knob is moved or the arrows selected
 * dir = pointer to current directory
 * top = new top element number
 * Uses the informations in the DL structure
 *
 * The drawing operation is optimized: if the list is to scroll of one text
 * line only, use ScrollRaster() and RedrawDirEntry(), which is faster than
 * using RedrawDirList()
 */

{
	LONG    delta;

	// compute scroll amount (in text lines):
	if (delta = top-dir->obj_UserData) {
		// update "top" position:
		SetGad(GD_DirList,GTSC_Top,top);
		dir->obj_UserData = top;

		if (delta == -1L || delta == 1L) {
			struct Object   *obj;

			// scroll up/down area:
			ScrollRaster(Win->RPort,0,DL.dl_Height*delta,
						 DL.dl_XMin,DL.dl_YMin,DL.dl_XMax,DL.dl_YMax);

			// display new (first or last) element:
			if (delta == -1) {
				if (obj = FindObjectByNum(dir,top)) RedrawDirEntry(obj,0);
			}
			else {
				delta = DL.dl_Visible-1L;
				if (obj = FindObjectByNum(dir,top+delta))
					RedrawDirEntry(obj,DL.dl_Height*delta);
			}
		}
		else RedrawDirList(dir);	// other delta: redraw all elements
	}
}
//______________________________________________________________________________

VOID
RedrawDirList (struct Object *dir)

/*
 * Update the dirs/files list using the (new) directory pointed to by dir
 * dir->obj_UserData is assumed to contain the top element number
 */

{
	struct Object   *obj,*next;
	WORD    ypos,num;

	// display loop, until there are no more directory entries
	// or until the bottom of area has been reached:
	for (num = DL.dl_Visible, ypos = 0, obj = FindObjectByNum(dir,dir->obj_UserData);
		 num > 0 && (next = NextChild(obj));
		 num--, ypos+= DL.dl_Height, obj = next) RedrawDirEntry(obj,ypos);

	// erase bottom of area if needed:
	ypos+= DL.dl_YMin;
	if (ypos < DL.dl_YMax)
		EraseRect(Win->RPort,DL.dl_XMin,ypos,DL.dl_XMax,DL.dl_YMax);
}
//______________________________________________________________________________

VOID
SelectDirEntry (struct Object *obj,WORD num,BOOL drag)

/*
 * Toggle selection on the given object (num = ordinal number from top element)
 * If drag is TRUE, we execute the same selection action than last time
 *
 * The object is redrawn only if it's selection status is modified
 */

{
	LONG    oldfc;
	STATIC LONG     act;

	if (drag) {
		// drag select does not touch not empty dir if "Recursive" is off
		if (ObjIsNotEmptyDir(obj) && NOT RecursionFlag) return;
	}
	else {
		if (ObjIsSelected(obj)) {
			// object is already selected (it does support selection):
			// unselect it.
			act = SEL_EXCLOBJECT;
		}
		else if (ObjIsNotEmptyDir(obj)) {
			// object is a not empty directory:
			// select/unselect SHIFT-clicked object.
			act = (obj->obj_SelChildren)? SEL_EXCLOBJECT: SEL_INCLOBJECT;
		}
		else {
			// object is an unselected file or (empty) directory:
			// select it.
			act = SEL_INCLOBJECT;
		}
	}

	oldfc = FilesSelected;
	DoSelect(obj,act,NULL);
	if (oldfc != FilesSelected) RedrawDirEntry(obj,num*DL.dl_Height);
}
//______________________________________________________________________________

UWORD
FindDirEntry (struct Object *dir,UWORD mx,UWORD my,BOOL drag)

/*
 * Compute the ordinal number of the element at (mx,my)
 * dir = pointer to the current directory
 * drag = TRUE if doing drag selection
 * Returns (UWORD)~0 if mouse position is not over the select area
 */

{
	UWORD   pos = dir->obj_UserData;

	if (mx < DL.dl_XMin || mx > DL.dl_XMax);
	else if (my < DL.dl_YMin) {
		if (drag && pos > 0) {
			ScrollDirList(dir,pos-1);
			return(pos);
		}
	}
	else if (my > DL.dl_YMax) {
		if (drag && pos < dir->obj_Size-DL.dl_Visible) {
			ScrollDirList(dir,pos+1);
			return((UWORD)(pos+DL.dl_Visible));
		}
	}
	else return((UWORD)(pos+(my-DL.dl_YMin)/DL.dl_Height));

	return((UWORD)~0);
}

// Tab size: 4

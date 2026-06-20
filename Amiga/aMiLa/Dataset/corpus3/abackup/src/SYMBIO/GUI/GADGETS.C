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
    gadgets.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 13-Dec-93
    Modified: 13-Dec-95
    _______________________________________________________________________
*/
#include "headers.h"

STATIC VOID	SetDirListSize		(VOID);
STATIC WORD	ComputeFromGadget	(WORD,WORD);
STATIC WORD	ComputeBevelBoxSize	(BYTE);

UWORD Pens[NUMDRIPENS];

#define GL(g)   MWin[ID].mw_Gadgets[g].mg_LeftEdge
#define GT(g)   MWin[ID].mw_Gadgets[g].mg_TopEdge
#define GH(g)   MWin[ID].mw_Gadgets[g].mg_Height
#define GW(g)   MWin[ID].mw_Gadgets[g].mg_Width

#define BL(b)   MWin[ID].mw_Boxes[b].bb_LeftEdge
#define BT(b)   MWin[ID].mw_Boxes[b].bb_TopEdge
#define BH(b)   MWin[ID].mw_Boxes[b].bb_Height
#define BW(b)   MWin[ID].mw_Boxes[b].bb_Width

#define FROM(y)         ComputeFromGadget(ID,y)
#define BBSIZE(n)       ComputeBevelBoxSize(n)

//______________________________________________________________________________

VOID
SetGadgetsSize()
{
	WORD	ID,gh,ol,g,yofs;

	gh = ScrFontY+4;
	ol = 2*Aspect+1;

	yofs = Off.MaxY;
	if (Scr->UserData != ABMAINSCREEN) yofs *= 2;

	for (ID = 0; ID < WIN_COUNT; ID++) {
		MWin[ID].mw_Width = ComputeX(MWin[ID].mw_Width);
		for (g = 0; g < GD_COUNT(ID); g++) {
			GL(g) = ComputeX(GL(g));
			GW(g) = ComputeX(GW(g));
			GH(g) = gh;
		}
		for (g = 0; g < MWin[ID].mw_BoxesCount; g++) {
			BL(g) = ComputeX(BL(g));
			BW(g) = ComputeX(BW(g));
		}
	}

	//_____________________________________________________________ Main window:

	ID = WIN_MAIN;

	BT(1) =
	BH(0) = BBSIZE(5);
	BH(1) = BBSIZE(1);

	if (Scr->UserData == ABMAINSCREEN) {
		MWin[ID].mw_Width  = ScrWidth - Off.MaxX ;
		MWin[ID].mw_Height = ScrHeight - Off.MaxY ;

		BL(0) =
		BL(1) = (MWin[ID].mw_Width-BW(0))/2;
		BT(0) = (MWin[ID].mw_Height-BH(0)-BH(1))/2;
		BT(1) = BT(0)+BH(0);

		for (g = 0; g < GD_COUNT(ID); g++) GL(g)+= BL(0);
	}
	else {
		MWin[ID].mw_Width += MAINWIN_EXTRA_SIZE ;
		for (g = 0; g < GD_COUNT(ID); g++) GL(g)+= MAINWIN_EXTRA_SIZE;
		MWin[ID].mw_Height = BH(0)+BH(1);
	}

	GT(GD_BackupFilesDirs) = BT(0)+ol;
	for (g = 1; g <= GD_RebuildCatalog; g++) GT(g) = FROM(g-1);
	GT(GD_Preferences) = BT(1)+ol;

	//_________________________________________________ LoadTree/Catalog window:

	ID = WIN_LOADTREE;

	BT(1) =
	BH(0) = BBSIZE(2);
	BH(1) = BBSIZE(1);

	MWin[ID].mw_Height = BH(0)+BH(1);

	GT(GD_LoadTreeStatus) = BT(0)+ol;
	GT(GD_LoadTree)           = FROM(GD_LoadTreeStatus);
	GT(GD_AbortTree)          = BT(1)+ol;

	//_____________________________________________________ Informations window:

	ID = WIN_INFOS;

	BT(1) =
	BH(0) = BBSIZE(5);
	BH(1) = BBSIZE(1);

	if (Scr->UserData == ABMAINSCREEN) {
		MWin[ID].mw_Width  = ScrWidth  - Off.MaxX;
		MWin[ID].mw_Height = ScrHeight - Off.MaxY;

		BL(0) =
		BL(1) = (MWin[ID].mw_Width-BW(0))/2;
		BT(0) = (MWin[ID].mw_Height-BH(0)-BH(1))/2;
		BT(1) = BT(0)+BH(0);

		for (g = 0; g < GD_COUNT(ID); g++) GL(g)+= BL(0);
	}
	else MWin[ID].mw_Height = BH(0)+BH(1);

	GT(GD_BackupSource)              = BT(0)+ol;
	GT(GD_BackupDate)                =
	GT(GD_BackupFiles)               = FROM(GD_BackupSource);
	GT(GD_BackupTime)                =
	GT(GD_BackupSize)                = FROM(GD_BackupDate);
	GT(GD_BackupCompression) = FROM(GD_BackupTime);
	GT(GD_BackupComment)     = FROM(GD_BackupCompression);
	GT(GD_ContinueInfos)     =
	GT(GD_AbortInfos)                = BT(1)+ol;

	//________________________________________________________ Selection window:

	ID = WIN_SELECTION;

	g = gh+2*ol+4;

	BT(1) =
	BH(0) = BBSIZE(3);
	BH(2) = BBSIZE(1);
	BH(1) = g+((ScrHeight-(yofs+BH(0)+BH(2)+g))/(TxtFontY+1))*(TxtFontY+1);
	BT(2) = BT(1)+BH(1);

	MWin[ID].mw_Height = BH(0)+BH(1)+BH(2);

	GH(GD_Recursive)--;
	GH(GD_Filter)++;
	GH(GD_DirList) = BH(1)-(GH(GD_Root)+2*ol);

	GT(GD_Files)     =
	GT(GD_Filter)    =
	GT(GD_All)               =
	GT(GD_ByName)    = BT(0)+ol;
	GT(GD_Size)              =
	GT(GD_Bytes)     =
	GT(GD_Reverse)   =
	GT(GD_ByDate)    = FROM(GD_Files);
	GT(GD_Directory) =
	GT(GD_ByBits)    = FROM(GD_Size);
	GT(GD_Recursive) = GT(GD_Size)+1;
	GT(GD_Root)              =
	GT(GD_Parent)    = BT(1)+ol;
	GT(GD_DirList)   = FROM(GD_Root)-Aspect;
	GT(GD_Start)     =
	GT(GD_Prefs)     =
	GT(GD_Cancel)    = BT(2)+ol;

	BT(3) = GT(GD_DirList);
	BH(3) = GH(GD_DirList);

	SetDirListSize();

	//__________________________________________________________ Monitor window:

	ID = WIN_MONITOR;

	g = 2*ol+4;

	BT(1) =
	BH(0) = BBSIZE(4);
	BH(2) = BBSIZE(1);
	BH(1) = g+((ScrHeight-(yofs+BH(0)+BH(2)+g))/TxtFontY)*TxtFontY;
	BH(3) = BH(1)-2*ol;
	BT(2) = BT(1)+BH(1);
	BT(3) = BT(1)+ol;

	MWin[ID].mw_Height = BH(0)+BH(1)+BH(2);

	PBounds.MinX = BL(3)+6;
	PBounds.MinY = BT(3)+TxtBLine+2;
	PBounds.MaxX = BW(3)+BL(3)-6;
	PBounds.MaxY = BT(3)+BH(3)-3;

	if (Scr->UserData != ABMAINSCREEN) {
		PBounds.MinX += Off.MinX ;
		PBounds.MinY += Off.MinY ;
		PBounds.MaxX += Off.MinX ;
		PBounds.MaxY += Off.MinY ;
	}

	GT(GD_SavedFiles)        =
	GT(GD_SavedSize)         =
	GT(GD_SavedBytes)        =
	GT(GD_SavedGauge)        = BT(0)+ol;
	GT(GD_LeftFiles)         =
	GT(GD_LeftSize)          =
	GT(GD_LeftBytes)         =
	GT(GD_LeftGauge)         = FROM(GD_SavedFiles);
	GT(GD_DiskNumber)        =
	GT(GD_Time)                      =
	GT(GD_CrunchedGauge) = FROM(GD_LeftFiles);
	GT(GD_Source)            =
	GT(GD_DiskGauge)         = FROM(GD_DiskNumber);
	GT(GD_Report)            =
	GT(GD_Pause)             =
	GT(GD_Abort)             = BT(2)+ol;

	//__________________________________________________________ ArcReq window:

	ID = WIN_ARCREQ;

	for (g=0;g<3;g++) DevsLb[g] = GetStr((LONG)DevsLb[g]);

	BH(0) = BBSIZE(VISIBLEDEVICES+1);
	BT(1) = BT(0)+BH(0);
	BH(1) = BBSIZE(1);
	BT(2) = BT(1)+BH(1);
	BH(2) = BBSIZE(1);

	MWin[ID].mw_Height  = BH(0)+BH(1)+BH(2);

	GH(GD_DevList)      =
	GH(GD_SelList)      = VISIBLEDEVICES*ScrFontY+(GTV39PLUS?4:7);

	GT(GD_ArcType)      = BT(0)+ol;
	GT(GD_DevList)      =
	GT(GD_SelList)      = FROM(GD_ArcType) ;
	GT(GD_ArcFile)      = FROM(GD_DevList)-Aspect ;

	GH(GD_ArcFileReq)   = 14;
	GT(GD_ArcFileReq)   = GT(GD_ArcFile)+(GH(GD_ArcFile)-GH(GD_ArcFileReq))/2;

	GT(GD_UseCatFile)   = BT(1)+(BH(1)-GH(GD_UseCatFile))/2 ;

	GT(GD_OkArcReq)     =
	GT(GD_CancelArcReq) = BT(2)+(BH(2)-GH(GD_OkArcReq))/2;
}
//______________________________________________________________________________

__inline STATIC VOID
SetDirListSize()
{
	struct DrawInfo *di;
	WORD	ID = WIN_SELECTION;

	// read screen DrawInfo pens:
	di = GetScreenDrawInfo(Scr);
	memcpy(Pens,di->dri_Pens,NUMDRIPENS*sizeof(UWORD));
	FreeScreenDrawInfo(Scr,di);

	// setup selection area size:
	DL.dl_XMin	 = BL(3)+2;
	DL.dl_YMin	 = BT(3)+2;
	if (Scr->UserData != ABMAINSCREEN) {
		DL.dl_XMin += Off.MinX;
		DL.dl_YMin += Off.MinY;
	}
	DL.dl_XMax	 = DL.dl_XMin+BW(3)-5;
	DL.dl_YMax	 = DL.dl_YMin+BH(3)-5;
	DL.dl_Height = TxtFontY+1;

	// setup number of "visible" elements:
	DL.dl_Visible = (BH(3)-4)/DL.dl_Height;
	SCFileList[3].ti_Data = (ULONG)DL.dl_Visible;
}
//______________________________________________________________________________

WORD
GetByteID (LONG size)
{
	WORD	sizeID;

		 if (IS_BYTES)          sizeID = MSG_BYTES;
	else if (IS_KILOBYTES)  sizeID = MSG_KILOBYTES;
	else if (IS_MEGABYTES)  sizeID = MSG_MEGABYTES;
	else {
			 if (size < ONEKILOBYTE) sizeID = MSG_BYTES;
		else if (size < ONEMEGABYTE) sizeID = MSG_KILOBYTES;
		else						 sizeID = MSG_MEGABYTES;
	}
	return(sizeID);
}
//______________________________________________________________________________

STATIC WORD
ComputeFromGadget (WORD ID,WORD y)
{
	return((WORD)(GT(y)+GH(y)+Aspect));
}
//______________________________________________________________________________

STATIC WORD
ComputeBevelBoxSize (BYTE n)
{
	return((WORD)(n*(ScrFontY+4+Aspect)+3*Aspect+2));
}
//______________________________________________________________________________

BOOL
UpdateTagData (UBYTE gadID,ULONG tag,ULONG data)
{
	struct TagItem	*ti;

	if (ti = FindTagItem(tag,GD_TAGS(gadID))) {
		ti->ti_Data = data;
		return TRUE;
	}
	return FALSE;
}
//______________________________________________________________________________

VOID
SetGad (UBYTE gadID,ULONG tag,ULONG data)
{
	if (UpdateTagData(gadID,tag,data))
		GT_SetGadgetAttrsA(Gads[gadID],Win,NULL,GD_TAGS(gadID));
}
//______________________________________________________________________________

VOID
SetGadgets()
{
	UBYTE	gadID;

	for (gadID = 0; gadID < GD_COUNT(NewID); gadID++)
		GT_SetGadgetAttrsA(Gads[gadID],Win,NULL,GD_TAGS(gadID));
}
//______________________________________________________________________________

VOID
SetNM2TX (UBYTE gadID,ULONG value,STRPTR str)
{
	// set gadget only if value is new:
	if (value != (ULONG)Gads[gadID]->UserData) {
		SPrintf(str,LOCALEPATCHED? "%lD": "%ld",value);

		SetGad(gadID,GTTX_Text,(ULONG)str);
		Gads[gadID]->UserData = (APTR)value;
	}
}

//______________________________________________________________________________

VOID
SetNM3TX (UBYTE gadID,ULONG value,STRPTR str)
{
	ULONG rem,div;

	// set gadget only if value is new:
	if (value != (ULONG)Gads[gadID]->UserData) {
		if (value) {
			div = GetPreferedUnit(value);
			if (div != 1) {
				rem = value % div ;
				SPrintf(str,LOCALEPATCHED? "%lD.%lD": "%ld.%ld",value/div,(rem * 10)/div);
			}
			else SPrintf(str,LOCALEPATCHED? "%lD": "%ld",value);
		}
		else strcpy(str,"0");
		SetGad(gadID,GTTX_Text,(ULONG)str);
		Gads[gadID]->UserData = (APTR)value;
	}
}

// Tab size: 4

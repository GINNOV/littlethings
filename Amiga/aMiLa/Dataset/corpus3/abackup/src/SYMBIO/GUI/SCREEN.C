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
    screen.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 12-Feb-94
    Modified: 16-Jan-98
    _______________________________________________________________________
*/
#include "headers.h"
#include "screen.h"

BOOL
SetupScreen()
{
	// setup screen title:
	SPrintf(ScreenTitle,"%s %s - %s",_PROGNAME_,_PROGVER_,_COPYRIGHT_);

	// setup preferences program template:
	strcat(ARG_PPATH," SF PS=");

	if (NOT BATCHMODE) {
		// try to open our own public screen:
		if (IS_CUSTOM) {
			SetupFonts();
			if ( (! TxtFont) || (! ScrFont) ) return( FALSE ) ;

			ScrTags[0].ti_Data = (ULONG)ScrWidth;
			ScrTags[1].ti_Data = (ULONG)ScrHeight;
			ScrTags[3].ti_Data = (ULONG)ScreenTitle;
			ScrTags[4].ti_Data = (ULONG)ScrFont;
			ScrTags[7].ti_Data = (ULONG)_PROGNAME_;
			ScrTags[8].ti_Data = (ULONG)PRF_DISPLAYID;

			if (Scr = OpenScreenTagList(NULL,ScrTags)) {
				PubScreenStatus(Scr,0);
				LoadRGB4(&(Scr->ViewPort),PRF_COLORS,4);
				Scr->UserData = ABMAINSCREEN;
				strcat(ARG_PPATH,_PROGNAME_);
				return TRUE;
			}
			else {
				Warning(MSG_WARN_OPEN_SCREEN);
				XOR(PRF_FLAGS,PFL_CUSTOM);
			}
		}

		// try to lock a public screen:
		if (IS_PUBLIC) {
			if (Scr = GetPubScreen(PRF_PUBNAME)) strcat(ARG_PPATH,PRF_PUBNAME);
			else {
				Warning(MSG_WARN_LOCK_SCREEN);
				XOR(PRF_FLAGS,PFL_PUBLIC);
			}
		}
	}

	// try to lock the Workbench:
	if (NOT Scr) {
		if (Scr = GetPubScreen(_WBSCRNAME_)) strcat(ARG_PPATH,_WBSCRNAME_);
		else {
			Warning(MSG_WARN_LOCK_WBSCREEN);
			return FALSE;
		}
	}

	Scr->UserData = ABHOSTSCREEN;

	SetupFonts();
	return TRUE;
}
//_____________________________________________________________________________

VOID
GetScreenInfos()
{
	struct DisplayInfo      	dspinfo;
	struct DimensionInfo    diminfo;
	DisplayInfoHandle       	handle = NULL;

	if (Scr) handle = FindDisplayInfo(GetVPModeID(&(Scr->ViewPort)));

	// read the screen pixels aspect ratio:
	if (GetDisplayInfoData(handle,(STRPTR)&dspinfo,sizeof(dspinfo),DTAG_DISP,PRF_DISPLAYID))
		Aspect = (dspinfo.Resolution.y/dspinfo.Resolution.x == 1)? 2: 1;

	// read the screen visible height:
	if (GetDisplayInfoData(handle,(STRPTR)&diminfo,sizeof(diminfo),DTAG_DIMS,PRF_DISPLAYID)) {
		ScrWidth  = diminfo.StdOScan.MaxX+1;
		ScrHeight = diminfo.StdOScan.MaxY+1;
	}
	else if (Scr) {
		ScrWidth  = Scr->Width;
		ScrHeight = Scr->Height;
	}
}
//______________________________________________________________________________

struct Screen *
GetPubScreen (STRPTR name)
{
	struct Screen   *scr;

	if (scr = LockPubScreen(name)) {
		UnlockPubScreen(NULL,scr);
	//      ScreenToFront(scr);
	}
	return(scr);
}
//______________________________________________________________________________

VOID
SetupOffset()
{
	Off.MinX = Scr->WBorLeft;
	Off.MinY = Scr->WBorTop+Scr->RastPort.TxHeight+1;
	Off.MaxX = Off.MinX+Scr->WBorRight;
	Off.MaxY = Off.MinY+Scr->WBorBottom;
}

// Tab size: 4
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
	requester.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 11-Sep-93
	Modified: 08-May-95
	___________________
*/

#include "headers.h"
#include "requester.h"

BOOL
LoadFile (STRPTR filename,BYTE toload,WORD title)
{
	BOOL	rc = FALSE;

	if (AslBase) {
		struct FileRequester	*filereq;

		if (filereq = AllocAslRequest(ASL_FileRequest,NULL)) {
			UBYTE	pathname[256];
			BOOL	save,prefs;
			STRPTR	pp;

			strcpy(pathname,filename);
			if (pp = PathPart(pathname)) *pp = 0;

			save  = title == MSG_SAVE_PREFS;
			prefs = title == MSG_LOAD_PREFS || save;

			ASLFRTags[0].ti_Data = (ULONG)Win;
			ASLFRTags[3].ti_Data = (ULONG)GetStr(title);
			ASLFRTags[4].ti_Data = (ULONG)Win->LeftEdge;
			ASLFRTags[5].ti_Data = (ULONG)(Win->TopEdge+Offset.MinY);
			ASLFRTags[6].ti_Data = (toload == DIRONLY)? (ULONG)"": (ULONG)FilePart(filename);
			ASLFRTags[7].ti_Data = prefs? (ULONG)PRESETPATH: (ULONG)pathname;
			ASLFRTags[8].ti_Data = save;
			ASLFRTags[9].ti_Data = (toload == DIRONLY);

			if (AslRequest(filereq,ASLFRTags)) {
				if (toload == FILEONLY && NOT filereq->fr_File[0]);
				else {
					strcpy(filename,filereq->fr_Drawer);
					if (toload != DIRONLY && filereq->fr_File[0])
						AddPart(filename,filereq->fr_File,256);
					rc = TRUE;
				}
			}
			FreeAslRequest(filereq);
		}
		else WARNING(MSG_WARN_MEMORY);
	}
	else WARNING(MSG_WARN_OPEN_ASLV36);
	return(rc);
}
//______________________________________________________________________________

UWORD
LoadFont(BOOL scrfont,STRPTR name,UWORD size)
{
	if (AslBase) {
		struct FontRequester	*fontreq;
		UWORD	nameID,sizeID;

		if (scrfont) {
			nameID = GD_ScrFontName;
			sizeID = GD_ScrFontSize;
		}
		else {
			nameID = GD_TxtFontName;
			sizeID = GD_TxtFontSize;
		}

		if (fontreq = AllocAslRequest(ASL_FontRequest,NULL)) {
			ASLFOTags[0].ti_Data = (ULONG)Win;
			ASLFOTags[4].ti_Data = (ULONG)Win->LeftEdge;
			ASLFOTags[5].ti_Data = (ULONG)(Win->TopEdge+Offset.MinY);
			ASLFOTags[6].ti_Data = (ULONG)Win->Width;
			ASLFOTags[7].ti_Data = (ULONG)name;
			ASLFOTags[8].ti_Data = size;
			ASLFOTags[9].ti_Data = NOT scrfont;

			if (AslRequest(fontreq,ASLFOTags)) {
				strcpy (name,fontreq->fo_Attr.ta_Name);
				size = fontreq->fo_Attr.ta_YSize;

				SetGad(nameID,GTST_String,(ULONG)name);
				SetGad(sizeID,GTIN_Number,size);
			}
			FreeAslRequest(fontreq);
		}
		else WARNING(MSG_WARN_MEMORY);
	}
	else WARNING(MSG_WARN_OPEN_ASLV36);
	return(size);
}
//______________________________________________________________________________

VOID
LoadScreen()
{
	if (AslBase && AslBase->lib_Version >= 38) {
		struct ScreenModeRequester	*smodereq;

		ASLSMTags[0].ti_Data = (ULONG)Win;
		ASLSMTags[4].ti_Data = (ULONG)Win->LeftEdge;
		ASLSMTags[5].ti_Data = (ULONG)(Win->TopEdge+Offset.MinY);
		ASLSMTags[6].ti_Data = (ULONG)Win->Width;
		ASLSMTags[7].ti_Data = PRF_DISPLAYID;

		if (smodereq = AllocAslRequest(ASL_ScreenModeRequest,NULL)) {
			if (AslRequest(smodereq,ASLSMTags)) {
				GetScreenModeName(PRF_DISPLAYID = smodereq->sm_DisplayID);
				GT_SetGadgetAttrsA(Gads[GD_ScreenMode],Win,NULL,TXSMod);
			}
			FreeAslRequest(smodereq);
		}
		else WARNING(MSG_WARN_MEMORY);
	}
	else if (ReqToolsBase) {
		struct rtScreenModeRequester *smodereq;

		RTSMTags[0].ti_Data = (ULONG)Win;
		RTSMTags[3].ti_Data = (ULONG)Offset.MinY;
		RTSMTags[4].ti_Data = (ULONG)Font;

		if (smodereq = rtAllocRequestA(RT_SCREENMODEREQ,NULL)) {
			if (rtScreenModeRequestA(smodereq,GetStr(MSG_SELECT_SCREEN_MODE),RTSMTags)) {
				GetScreenModeName(PRF_DISPLAYID = smodereq->DisplayID);
				GT_SetGadgetAttrsA(Gads[GD_ScreenMode],Win,NULL,TXSMod);
			}
			rtFreeRequest(smodereq);
		}
		else WARNING(MSG_WARN_MEMORY);
	}
	else WARNING(MSG_WARN_OPEN_ASLV38);
}
//______________________________________________________________________________

STATIC BOOL __saveds __asm
ScreenModeHook (register __a0 struct Hook *hook,
				register __a2 struct ScreenModeRequester *SMreq,
				register __a1 ULONG modeID)
{
	STATIC struct DimensionInfo    diminfo;

	if (GetDisplayInfoData(NULL,(STRPTR)&diminfo,sizeof(diminfo),DTAG_DIMS,modeID)
		&& diminfo.Nominal.MaxX < 639) return FALSE;
	return TRUE;
}
//______________________________________________________________________________

VOID
LoadPalette()
{
	if (ReqToolsBase) {
		UWORD	c,colors[4];

		// save current palette then set prefs palette:
		for (c = 0; c < 4 ; c++) colors[c] = GetRGB4(Scr->ViewPort.ColorMap,c);
		LoadRGB4(&(Scr->ViewPort),PRF_COLORS,4);

		RTPalTags[0].ti_Data = (ULONG)Win;
		RTPalTags[2].ti_Data = (ULONG)Offset.MinY;
		RTPalTags[5].ti_Data = (ULONG)Font;

		if (rtPaletteRequestA(GetStr(MSG_SELECT_PALETTE),NULL,RTPalTags) != -1)
		{
			for (c = 0; c < 4 ; c++)
				PRF_COLORS[c] = GetRGB4(Scr->ViewPort.ColorMap,c);
		}

		// restore palette:
		if (NOT _EXECFROMABACKUP_) LoadRGB4(&(Scr->ViewPort),colors,4);
	}
	else WARNING(MSG_WARN_OPEN_REQTOOLS);
}

// Tab size: 4

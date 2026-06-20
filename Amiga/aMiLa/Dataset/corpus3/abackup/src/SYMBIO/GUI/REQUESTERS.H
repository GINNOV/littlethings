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
    requesters.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 01-Mar-94
    Modified: 28-Apr-96
    _______________________________________________________________________
*/

#ifndef ABACKUP_REQUESTERS_H
#define ABACKUP_REQUESTERS_H

STATIC UBYTE	GDTrue[32],GDFalse[32];
STATIC UBYTE	TmpBuf[MAXSTR+MAXSTR+1];
STATIC WORD		SRHeight;

static struct TagItem  STTags[] = {{GTST_String,       NULL		       },
							{GTST_MaxChars, NULL			},
							{TAG_MORE,		(ULONG)GATags   }};

STATIC ULONG	NGType[] = {STRING_KIND,BUTTON_KIND,BUTTON_KIND};

//_____ String Requester IDs:

#define GD_ReqString		0
#define GD_ReqTrue			1
#define GD_ReqFalse			2

#define GAD_COUNT_REQ		3

STATIC struct NewGadget NG[] = {
	{  6,0,268,0,NULL,NULL,GD_ReqString,0			,NULL,(APTR)STTags},
	{  6,0, 87,0,NULL,NULL,GD_ReqTrue  ,PLACETEXT_IN,NULL,(APTR)GATags},
	{187,0, 87,0,NULL,NULL,GD_ReqFalse ,PLACETEXT_IN,NULL,(APTR)GATags}
};

STATIC struct IntuiText IT[] = {
	{2,0,JAM1,140, 9,NULL,NULL,&IT[1]},
	{1,0,JAM1,140,18,NULL,NULL,NULL  }
};

// STATIC struct Requester Req;
STATIC struct Window	*RWin;

STATIC struct TagItem RWinTags[] = {
	{WA_Left,		NULL				},
	{WA_Top,		NULL				},
	{WA_Width,		NULL				},
	{WA_Height,		NULL				},
	{WA_IDCMP,		IDCMP_REFRESHWINDOW
					|IDCMP_MOUSEBUTTONS
					|IDCMP_GADGETUP
					|IDCMP_CLOSEWINDOW
					|IDCMP_VANILLAKEY	},
	{WA_Flags,		WFLG_DRAGBAR
					|WFLG_DEPTHGADGET
					|WFLG_CLOSEGADGET
					|WFLG_SMART_REFRESH
					|WFLG_ACTIVATE		},
	{WA_Title,		NULL				},
	{WA_PubScreen,	NULL				},
	{WA_Gadgets,	NULL				},
	{TAG_DONE}
};

STATIC struct BBox ReqBox[] =  {
	{0, 0,280,43,FALSE},
	{0,43,280,18,FALSE},
	{6, 3,268,21,TRUE }
};

#define BOX_COUNT_REQ	3

STATIC struct TagItem AFRTags[] = {
	{ASLFR_Window,			NULL},
	{ASLFR_TitleText,		NULL},
	{ASLFR_InitialFile,		NULL},
	{ASLFR_InitialDrawer,	NULL},
	{ASLFR_SleepWindow,		TRUE},
	{ASLFR_RejectIcons,		TRUE},
	{TAG_DONE}
};

// macros:
#define RBL(b)  ReqBox[b].bb_LeftEdge
#define RBT(b)  ReqBox[b].bb_TopEdge
#define RBW(b)  ReqBox[b].bb_Width
#define RBH(b)  ReqBox[b].bb_Height
#define RBR(b)  ReqBox[b].bb_Recessed

#define NGTE(n) NG[n].ng_TopEdge
#define NGHI(n) NG[n].ng_Height

#endif	// ABACKUP_REQUESTERS_H

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
    windows.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 04-Oct-93
    Modified: 19-Jun-95
    _______________________________________________________________________
*/

#ifndef ABACKUP_WINDOWS_H
#define ABACKUP_WINDOWS_H

APTR			VInfo		= NULL;
struct Window		*Win		= NULL;
struct AppWindow	*AWin		= NULL;
struct DiskObject	*AIDiskObj	= NULL;
struct AppIcon		*AIcon		= NULL;
struct Rectangle	Off;
struct TagItem		BBoxTags[]	 = {{GT_VisualInfo,	NULL			},
									{TAG_DONE}},
					RecessTags[] = {{GTBB_Recessed, TRUE			},
									{TAG_MORE,		(ULONG)BBoxTags }};

STATIC struct TagItem	RPTags[]	 = {{RPTAG_Font,		NULL},
										{RPTAG_APen,		1L	},
										{RPTAG_MaxPen,		2L	},
										{TAG_DONE}},
						MenuTags[]	 = {{GTMN_NewLookMenus, TRUE},
										{TAG_DONE}};
#define DEF_WIN_IDCMP	IDCMP_REFRESHWINDOW|IDCMP_GADGETUP|IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|IDCMP_RAWKEY|IDCMP_VANILLAKEY|IDCMP_CHANGEWINDOW

STATIC struct TagItem  WinTags[] = {{WA_Left,		0L					},
									{WA_Top,		NULL				},
									{WA_Width,		NULL				},
									{WA_Height,		NULL				},
									{WA_IDCMP,		DEF_WIN_IDCMP		},
									{WA_Flags,		WFLG_SMART_REFRESH
													|WFLG_ACTIVATE
													|WFLG_NEWLOOKMENUS	},
									{WA_Title,		NULL				},
									{WA_ScreenTitle,NULL				},
									{WA_AutoAdjust, TRUE				},
									{WA_PubScreen,	NULL				},
									{TAG_DONE}};
//______________________________________________________________________________

static USHORT chip ImageReqData[] =
{
   0x0000, 0x1000,
   0x0000, 0x3000,
   0x0ff0, 0x3000,
   0x0c18, 0x3000,
   0x0c14, 0x3000,
   0x0c12, 0x3000,
   0x0c1f, 0x3000,
   0x0c03, 0x3000,
   0x0c03, 0x3000,
   0x0c03, 0x3000,
   0x0c03, 0x3000,
   0x0fff, 0x3000,
   0x0000, 0x3000,
   0x7fff, 0xf000,
   0xffff, 0xe000,
   0xc000, 0x0000,
   0xc000, 0x0000,
   0xc000, 0x0000,
   0xc000, 0x0000,
   0xc000, 0x0000,
   0xc000, 0x0000,
   0xc000, 0x0000,
   0xc000, 0x0000,
   0xc000, 0x0000,
   0xc000, 0x0000,
   0xc000, 0x0000,
   0xc000, 0x0000,
   0x8000, 0x0000
} ;

struct Image ImageReq = { 0,0,20,14,2,ImageReqData,0x3,0x0,NULL };

//______________________________________________________________________________

struct MinWindow MWin[WIN_COUNT] = {
 {221, 88,MSG_WIN_TITLE_MAIN ,GAD_COUNT_MAIN	 ,BOX_COUNT_MAIN	 ,MG_Main	  ,MainBox		},
 {282, 48,NULL				 ,GAD_COUNT_LOADTREE ,BOX_COUNT_LOADTREE ,MG_LoadTree ,LoadTreeBox	},
 {416, 88,MSG_WIN_TITLE_INFOS,GAD_COUNT_INFOS	 ,BOX_COUNT_INFOS	 ,MG_Infos	  ,InfosBox		},
 {632,232,NULL				 ,GAD_COUNT_SELECTION,BOX_COUNT_SELECTION,MG_Selection,SelectionBox	},
 {632,232,NULL				 ,GAD_COUNT_MONITOR	 ,BOX_COUNT_MONITOR	 ,MG_Monitor  ,MonitorBox	},
 {414,183,MSG_WIN_TITLE_ARCREQ,GAD_COUNT_ARCREQ    ,BOX_COUNT_ARCREQ	   ,MG_ArcReq	    ,ArcReqBox	     }
};

#endif	// ABACKUP_WINDOWS_H

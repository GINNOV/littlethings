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
#ifndef ABPREFS_WINDOWS_H
#define ABPREFS_WINDOWS_H
/*      ___________________

	ABackup Prefs
	windows.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 12-Aug-93
	Modified: 18-Jan-98
	___________________
*/

struct Window   	*Win     = NULL;
struct AppWindow	*AppWin  = NULL;
struct MsgPort  	*MsgPort = NULL;
struct TextAttr 	*Font;
struct Rectangle	Offset;

UWORD   FontX,FontY;

STATIC struct TagItem MenuTags[] = {{GTMN_NewLookMenus, TRUE},{TAG_DONE}},
					  WinTags[]      = {{WA_Left,   	0L      				},
									{WA_Top,		NULL    			},
									{WA_Width,      	NULL    			},
									{WA_Height,     	NULL    			},
									{WA_IDCMP,      	IDCMP_REFRESHWINDOW
													|IDCMP_CHANGEWINDOW
													|IDCMP_MOUSEBUTTONS
													|IDCMP_MOUSEMOVE
													|IDCMP_GADGETDOWN
													|IDCMP_GADGETUP
													|IDCMP_MENUPICK
													|IDCMP_CLOSEWINDOW
													|IDCMP_RAWKEY
													|IDCMP_VANILLAKEY
													|IDCMP_INTUITICKS       },
									{WA_Flags,      	WFLG_DRAGBAR
													|WFLG_DEPTHGADGET
													|WFLG_CLOSEGADGET
													|WFLG_ACTIVATE
													|WFLG_SMART_REFRESH
													|WFLG_NEWLOOKMENUS      },
									{WA_Title,      	NULL    			},
									{WA_AutoAdjust, TRUE    			},
									{WA_PubScreen,  NULL    			},
									{WA_Zoom,       	NULL    			},
									{TAG_DONE}};
//__________________________________________________________________ BevelBoxes:

struct TagItem  BBoxTags[]       = {{GT_VisualInfo,     NULL    		},
								{TAG_DONE}},
				RecessTags[] = {{GTBB_Recessed, TRUE    		},
								{TAG_MORE,      	(ULONG)BBoxTags }};

STATIC struct BBox      BBBackup[]       = {{ 10,  5,404, 74,FALSE},
					    { 10, 81,404, 61,FALSE},
					    {418,  5,204,153,FALSE}},
					BBRestore[]      = {{ 10,  5,404, 74,FALSE},
									{ 10, 81,404, 20,FALSE},
									{ 10,103,404, 47,FALSE},
									{418,  5,204,145,FALSE}},
					BBVerify[]       = {{ 10,  5,404, 19,FALSE},
									{ 10, 26,404, 29,FALSE}},
					BBCompress[] = {{ 10, 20,390,114,FALSE},
									{127, 95,267, 36,TRUE },
									{ 10,136,390, 35,FALSE},
									{404,  5, 99,166,FALSE}},
					BBTape[]	 = {{ 10,  5,404, 48,FALSE},
									{ 10, 55,404, 29,FALSE}},
					BBGUI[] 	 = {{ 10,  5,404, 49,FALSE},
									{ 10, 56,404, 35,FALSE}},
					BBExternal[] = {{ 10,  5,404, 50,FALSE},
									{ 10, 57,404, 29,FALSE}},
					BBMisc[]	 = {{ 10,  5,404, 63,FALSE},
									{ 10, 70,404, 32,FALSE}};

#define BL(b)   MWin[ID].mw_Box[b].bb_LeftEdge
#define BT(b)   MWin[ID].mw_Box[b].bb_TopEdge
#define BW(b)   MWin[ID].mw_Box[b].bb_Width
#define BH(b)   MWin[ID].mw_Box[b].bb_Height
#define BR(b)   MWin[ID].mw_Box[b].bb_Recessed

#define BOXCOUNT	MWin[ID].mw_BoxCnt
// could be defined as sizeof(MWin[ID].mw_Box)/sizeof(struct BBox)

//______________________________________________________________________________

struct MinWindow	MWin[] = {
 {402, 75,MSG_TITLE_MAIN	,GAD_COUNT_MAIN 	,BOX_COUNT_MAIN 	,MGMain 	,NULL   	},
 {632,173,MSG_TITLE_BACKUP      ,GAD_COUNT_BACKUP       ,BOX_COUNT_BACKUP       ,MGBackup       ,BBBackup       },
 {632,169,MSG_TITLE_RESTORE     ,GAD_COUNT_RESTORE      ,BOX_COUNT_RESTORE      ,MGRestore      ,BBRestore      },
 {424, 74,MSG_TITLE_VERIFY      ,GAD_COUNT_VERIFY       ,BOX_COUNT_VERIFY       ,MGVerify       ,BBVerify       },
 {513,183,MSG_TITLE_COMPRESS,GAD_COUNT_COMPRESS ,BOX_COUNT_COMPRESS     ,MGCompress     ,BBCompress     },
 {424,103,MSG_TITLE_TAPE	,GAD_COUNT_TAPE 	,BOX_COUNT_TAPE 	,MGTape 	,BBTape 	},
 {424,110,MSG_TITLE_GUI 	,GAD_COUNT_GUI  	,BOX_COUNT_GUI  	,MGGUI  	,BBGUI  	},
 {424,105,MSG_TITLE_EXTERNAL,GAD_COUNT_EXTERNAL ,BOX_COUNT_EXTERNAL     ,MGExternal     ,BBExternal     },
 {424,121,MSG_TITLE_MISC	,GAD_COUNT_MISC 	,BOX_COUNT_MISC 	,MGMisc 	,BBMisc 	}
};

#define GL(g)   MWin[ID].mw_Gad[g].mg_LeftEdge
#define GT(g)   MWin[ID].mw_Gad[g].mg_TopEdge
#define GH(g)   MWin[ID].mw_Gad[g].mg_Height
#define GW(g)   MWin[ID].mw_Gad[g].mg_Width

#define FROMGAD(y)      ComputeFromGadget(ID,y)
#define FROMBOX 	ComputeFromBevelBox(ID)

#endif  // ABPREFS_WINDOWS_H

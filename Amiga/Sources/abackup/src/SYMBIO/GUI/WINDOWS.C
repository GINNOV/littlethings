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
    windows.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 04-Oct-93
    Modified: 04-Dec-95
    _______________________________________________________________________
*/
#include "headers.h"
#include "gadgets.h"
#include "windows.h"
#include "image.h"

STATIC VOID	ChangeWindow	(VOID);
STATIC BOOL	SetupWindow		(VOID);
STATIC BOOL	SetupGadgets	(VOID);

//_____________________________________________________________________________

BOOL
UpdateWindow()
{
	if (OldID != WIN_FIRST) ChangeWindow();
	if (SetupGadgets()) {
		if (OldID == WIN_FIRST && NOT SetupWindow());
		else {
			PrepareMenus(FALSE);

			Render();

			AddGList(Win,GList,-1,-1,NULL);
			RefreshGList(GList,Win,NULL,-1);
			GT_RefreshWindow(Win,NULL);

			OldID = NewID;
			return TRUE;
		}
	}
	return FALSE;
}
//______________________________________________________________________________

// remove the gadgets and size the window:
__inline STATIC VOID
ChangeWindow()
{
	WORD	left,top,width,height,x,y;
	struct	IntuiMessage *imsg;
	ULONG	flags;
	STRPTR	title;
	BOOL	wait;

	// make sure there are no more outstanding messages:
	StripIntuiMessages();

	width  = MWin[NewID].mw_Width;
	height = MWin[NewID].mw_Height;
	title  = GetStr(MWin[NewID].mw_Title);

	if (Scr->UserData == ABMAINSCREEN) {
		left = (ScrWidth-width)/2;
		if (left < 0) left = 0;
		top  = Off.MinY + (ScrHeight-height-Off.MinY)/2;
		if (top < 0) top = 0;
		SetWindowTitles(Win,(UBYTE *)~0,title);
	}
	else {
		width  += Off.MaxX;
		height += Off.MaxY;
		left = Win->LeftEdge;
		top  = Win->TopEdge;
		SetWindowTitles(Win,title,(UBYTE *)~0);
	}

	CleanupGadgets();
	if (Scr->UserData == ABMAINSCREEN) {
		x = 0 ;
		y = 0 ;
	}
	else {
		x = Off.MinX ;
		y = Off.MinY ;
	}
	EraseRect(Win->RPort,x,y,MWin[OldID].mw_Width+x-1,MWin[OldID].mw_Height+y-1);
	ChangeWindowBox(Win,left,top,width,height);

	// wait for the IDCMP_CHANGEWINDOW message
	wait = TRUE;
	while (wait) {
		WaitPort(Win->UserPort);
		while (wait && (imsg = GT_GetIMsg(Win->UserPort))) {
			if (imsg->Class == IDCMP_CHANGEWINDOW) wait = FALSE;
			GT_ReplyIMsg(imsg);
		}
	}

	// modify IDCMP flags:
	flags = DEF_WIN_IDCMP;
	if ( (NewID == WIN_SELECTION) || (NewID == WIN_ARCREQ) ) flags |= LISTVIEWIDCMP;
	ModifyIDCMP(Win,flags);
}
//_____________________________________________________________________________

__inline STATIC BOOL
SetupWindow()
{
	UBYTE	path[MAXSTR+1],name[31];

	WinTags[2].ti_Data = MWin[NewID].mw_Width +Off.MaxX;
	WinTags[3].ti_Data = MWin[NewID].mw_Height+Off.MaxY;
	if (Scr->UserData == ABMAINSCREEN) {
		WinTags[0].ti_Data  = (ScrWidth-WinTags[2].ti_Data)/2;
		WinTags[1].ti_Data  = Off.MinY+2;
		WinTags[3].ti_Data -= Off.MinY+2;
		WinTags[5].ti_Data |= WFLG_BACKDROP|WFLG_BORDERLESS;
		WinTags[6].ti_Tag   = WA_ScreenTitle;
		WinTags[7].ti_Tag   = TAG_IGNORE;
	}
	else {
		WinTags[5].ti_Data|= WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET;
		WinTags[1].ti_Data = Off.MinY;
		WinTags[7].ti_Data = (ULONG)ScreenTitle;
	}
	WinTags[6].ti_Data = (ULONG)GetStr((LONG)MWin[NewID].mw_Title);
	WinTags[9].ti_Data = (ULONG)Scr;

	if (Menus && LayoutMenusA(Menus,VInfo,MenuTags)) {
		if (Win = OpenWindowTagList(NULL,WinTags)) {
			Win->UserData = (BYTE *)SetWinPtr((APTR)Win);

			if (GFXV39PLUS) {
				if (TxtTFont) {
					RPTags[0].ti_Tag  = RPTAG_Font;
					RPTags[0].ti_Data = (ULONG)TxtTFont;
				}
				else RPTags[0].ti_Tag = TAG_IGNORE;
				SetRPAttrsA(Win->RPort,RPTags);
			}
			else {
				SetAPen(Win->RPort,1);
				if (TxtTFont) SetFont(Win->RPort,TxtTFont);
			}

			SetMenuStrip(Win,Menus);

			if (AWPort) {
				if (IS_WORKBENCH) {
				  AWin	= AddAppWindowA(NULL,NULL,Win,AWPort,NULL);
				}
				else {

				  if (! GetProgramName(name,sizeof(name))) strcpy(name,_PROGNAME_);

				  if (NameFromLock(GetProgramDir(),path,sizeof(path))
				      && AddPart(path,name,sizeof(path))
				      && (AIDiskObj = GetDiskObjectNew(path))) {
				    AppIcon.do_Gadget.Width  = AIDiskObj->do_Gadget.Width ;
				    AppIcon.do_Gadget.Height = AIDiskObj->do_Gadget.Height ;
				    AppIcon.do_Gadget.GadgetRender = AIDiskObj->do_Gadget.GadgetRender ;
				    AppIcon.do_Gadget.SelectRender = AIDiskObj->do_Gadget.SelectRender ;
				  }
				  AIcon = AddAppIconA(NULL,NULL,_PROGNAME_,AWPort,NULL,&AppIcon,NULL);

				}
			}

			return TRUE;
		}
		else Warning(MSG_WARN_OPEN_WINDOW);
	}
	else Warning(MSG_WARN_LAYOUT_MENUS);
	return FALSE;
}
//_____________________________________________________________________________

APTR
SetWinPtr (APTR newptr)
{
	struct Process	*pr;
	APTR	oldptr;

	pr = (struct Process *)FindTask(NULL);

	oldptr = pr->pr_WindowPtr;
	pr->pr_WindowPtr = newptr;

	return(oldptr);
}
//_____________________________________________________________________________

__inline STATIC BOOL
SetupGadgets()
{
	WORD			x,y;
	struct NewGadget	ng;
	struct Gadget		*g;
	UBYTE	count = GD_COUNT(NewID),n;

	if (Scr->UserData == ABMAINSCREEN) {
		x = 0 ;
		y = 0 ;
	}
	else {
		x = Off.MinX ;
		y = Off.MinY ;
	}

	if(Gads = MyAllocMem(sizeof(struct Gadget)*count,NULL)) {
		if (g = CreateContext(&GList)) {
			ng.ng_VisualInfo = VInfo;
			ng.ng_UserData	 = (APTR)-1;
			for (n = 0; n < count; n++) {
				ng.ng_LeftEdge	 = GD_LEFT(n)+x;
				ng.ng_TopEdge	 = GD_TOP(n) +y;
				ng.ng_Width		 = GD_WIDTH(n);
				ng.ng_Height	 = GD_HEIGHT(n);
				ng.ng_GadgetText = GD_TEXT(n)==MSG_VOID?NULL:GetStr(GD_TEXT(n));
				ng.ng_TextAttr	 = GD_TYPE(n)==LISTVIEW_KIND?TxtFont:ScrFont;
				ng.ng_GadgetID	 = n;
				ng.ng_Flags		 = GD_FLAGS(n) /*|NG_HIGHLABEL*/;

				Gads[n] = g = CreateGadgetA(GD_TYPE(n),g,&ng,GD_TAGS(n));
				if (g) {
					if (NewID == WIN_MONITOR && n == GD_Pause)
						g->Activation |= GACT_TOGGLESELECT;
					else if (NewID == WIN_ARCREQ  && n == GD_ArcFileReq) {
						g->Flags      |= GFLG_GADGIMAGE;
						g->Activation |= GACT_RELVERIFY;
						g->GadgetRender = (APTR)&ImageReq;
					}
					continue;
				}

				Warning(MSG_WARN_CREATE_GADGET);
				return FALSE;
			}
			return TRUE;
		}
		else Warning(MSG_WARN_CONTEXT);
	}
	else Warning(MSG_WARN_MEMORY);
	return FALSE;
}
//_____________________________________________________________________________

VOID
Render()
{
	WORD	h,x,y;
	BYTE	b;

	if (NewID == WIN_MAIN) {
		if (Scr->UserData == ABMAINSCREEN) {
			x = ( Win->Width - ImageHaut.Width ) / 2 ;
			y = ( GD_TOP(GD_BackupFilesDirs) - ImageHaut.Height ) / 2 ;
			DrawImage( Win->RPort , &ImageHaut , x , y ) ;
			x = ( Win->Width - ImageBas.Width ) / 2 ;
			y = GD_TOP(GD_Preferences) + GD_HEIGHT(GD_Preferences) ;
			y += ( Win->Height - y - ImageBas.Height ) / 2 ;
			DrawImage( Win->RPort , &ImageBas , x , y ) ;
		}
		else {
			h = Win->Height - Win->BorderTop - Win->BorderBottom ;
			x = Win->BorderLeft + (MAINWIN_EXTRA_SIZE - ImageHaut.Width) / 2 ;
			y = ImageHaut.Height + ImageBas.Height + 8 ;
			if ( y > h ) {
				y = Win->BorderTop + ( h - ImageHaut.Height ) / 2 ;
				DrawImage( Win->RPort , &ImageHaut , x , y ) ;
			}
			else {
				y  = Win->BorderTop + (h - y) / 2 ;
				DrawImage( Win->RPort , &ImageHaut , x , y ) ;
				x  = Win->BorderLeft + (MAINWIN_EXTRA_SIZE - ImageBas.Width) / 2 ;
				y += ImageHaut.Height + 8 ;
				DrawImage( Win->RPort , &ImageBas , x , y ) ;
			}
		}
	}
	else {
		if (Scr->UserData == ABMAINSCREEN) {
			x = 0 ;
			y = 0 ;
		}
		else {
			x = Off.MinX ;
			y = Off.MinY ;
		}
		for (b = 0; b < BOX_COUNT(NewID); b++)
			DrawBevelBoxA(Win->RPort, BOX_LEFT(b)+x,
						BOX_TOP(b) +y,
						BOX_WIDTH(b),
						BOX_HEIGHT(b),
						BOX_RECESSED(b)? RecessTags: BBoxTags);
	}
}
//______________________________________________________________________________

VOID
StripIntuiMessages()
{
	struct IntuiMessage	*imsg;

	ReportMouse(FALSE,Win);
	while (imsg = GT_GetIMsg(Win->UserPort)) GT_ReplyIMsg(imsg);
}

// Tab size 4

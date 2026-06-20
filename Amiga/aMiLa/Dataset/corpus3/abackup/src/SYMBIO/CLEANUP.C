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
    cleanup.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 02-Nov-93
    Modified: 24-Sep-95
    _______________________________________________________________________
*/
#include "headers.h"

STATIC VOID	CleanupPrefs	(VOID);
STATIC VOID	CleanupGUI		(VOID);
STATIC VOID	CleanupLocale	(VOID);
STATIC VOID	CleanupLibs		(VOID);
STATIC VOID	CleanupMain		(VOID);
STATIC VOID	CleanupNotify	(VOID);
STATIC VOID	CleanupHelp		(VOID);

VOID
Cleanup()
{
	CloseArc(Archive);

	CleanupPrefs();
	CleanupAudio();
	CleanupMain();
	CleanupCompTables();
	CleanupNotify();
	CleanupHelp();
	CleanupGUI();

	if (MemPool)    DeletePool(MemPool);

	CleanupLocale();
	CleanupLibs();
}
//______________________________________________________________________________

#pragma libcall CxBase BrokerCommand  c6 802
LONG BrokerCommand(BYTE *,LONG);

__inline STATIC VOID
CleanupPrefs()
{
	struct Library	*CxBase;

	if (CxBase = OpenLibrary("commodities.library",36L)) {
		BrokerCommand("ABPrefs",CXCMD_KILL);
		CloseLibrary(CxBase);
	}
}
//______________________________________________________________________________

VOID
CleanupGadgets()
{
	if (GList) {
		RemoveGList(Win,GList,-1);
		FreeGadgets(GList);
		GList = NULL;
	}
	if (Gads) {
		MyFreeMem(Gads);
		Gads = NULL;
	}
}
//_____________________________________________________________________________

__inline STATIC VOID
CleanupGUI()
{
	CleanupGadgets();
	if (Win) {
		SetWinPtr(Win->UserData);
		if (AWin) RemoveAppWindow(AWin);
		ClearMenuStrip(Win);
		CloseWindow(Win);
	}
	if (Menus)      FreeMenus(Menus);
	if (VInfo)      FreeVisualInfo(VInfo);

	if (AWPort) {
		struct Message	*pMsg;

		if (AIcon) RemoveAppIcon(AIcon);
		if (AIDiskObj) FreeDiskObject(AIDiskObj);

		while (pMsg = GetMsg(AWPort)) ReplyMsg(pMsg);
		DeletePort(AWPort);
	}

	/* closes any opened screen.
	 * after this sequence, Src is either NULL if no screen is open, or not NULL
	 * if our custom screen couldn't be closed, because of visitor windows
	 */
	if (Scr && Scr->UserData == ABMAINSCREEN) {
		do
			if (CloseScreen(Scr)) {
				Scr = NULL;
				break;
			}
		while (YesNoRequest(GetStr(MSG_WARN_CLOSE_VISITORS),NULL,MSG_REQ_RETRY_CANCEL,FALSE));
	}
	else Scr = NULL;

	if (ScrTFont)   CloseFont(ScrTFont);
	if (TxtTFont)   CloseFont(TxtTFont);
}
//_____________________________________________________________________________

__inline STATIC VOID
CleanupLocale()
{
	if (Catalog)    CloseCatalog(Catalog);
	if (LocaleBase) CloseLibrary((struct Library*)LocaleBase);
}
//_____________________________________________________________________________

__inline STATIC VOID
CleanupLibs()
{
	if (muBase)                     CloseLibrary((struct Library*)muBase);
	if (XpkBase)            CloseLibrary(XpkBase);

	if (WorkbenchBase)      CloseLibrary(WorkbenchBase);
	if (AslBase)            CloseLibrary(AslBase);
	if (IFFParseBase)       CloseLibrary(IFFParseBase);
	if (DiskfontBase)       CloseLibrary(DiskfontBase);

	if (IconBase)           CloseLibrary(IconBase);
	if (UtilityBase)        CloseLibrary(UtilityBase);
	if (GadToolsBase)       CloseLibrary(GadToolsBase);
	if (GfxBase)            CloseLibrary((struct Library *)GfxBase);
	if (IntuitionBase)      CloseLibrary((struct Library *)IntuitionBase);
}
//_____________________________________________________________________________

__inline STATIC VOID
CleanupMain()
{
	CleanupChildTask();

	if (pGHdr)              FreeObject(pGHdr);
	if (DevList)    FreeDevList(DevList);
	if (pReq)               FreeAslRequest(pReq);
}
//_____________________________________________________________________________

__inline STATIC VOID
CleanupNotify()
{
	if (NotReq) {
		EndNotify(NotReq);
		MyFreeMem(NotReq);
		if (NotSig != -1L)      FreeSignal(NotSig);
	}
}
//_____________________________________________________________________________

__inline STATIC VOID
CleanupHelp()
{
	if (AmigaGuideBase) {
		if (AGHandle) CloseAmigaGuide(AGHandle);
		CloseLibrary(AmigaGuideBase);
	}
}

// Tab size: 4

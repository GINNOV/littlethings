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
	cleanup.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 22-Sep-93
	Modified: 08-May-95
	___________________
*/

#include "headers.h"

STATIC VOID	CleanupBackfill (VOID);
STATIC VOID	CleanupBOOPSIs	(VOID);
STATIC VOID	CleanupPrefs	(VOID);
STATIC VOID	CleanupCx		(VOID);
STATIC VOID	CleanupLists	(VOID);
STATIC VOID	CleanupHelp	(VOID);

//_____________________________________________________________________________

VOID
Cleanup()
{
	struct Message	*msg;

	if (Menus)      FreeMenus(Menus);

	CleanupHelp();
	CleanupGadgets();
	CleanupBOOPSIs();
	CleanupWindow();
	CleanupPrefs();
	CleanupLists();
	CleanupCx();

	if (IPCMsgPort) {
		while (msg = GetMsg(IPCMsgPort)) FreeVec(msg);
		DeletePort(IPCMsgPort);
	}

	if (Catalog)    CloseCatalog(Catalog);
	if (VInfo)              FreeVisualInfo(VInfo);
	if (RArgs)              FreeVec(RArgs);


	// NOTE: Starting with exec.library V36,
	// it is safe to pass a NULL to CloseLibrary() instead of a library pointer.

	// closing disk-based libraries:
	CloseLibrary((struct Library *)ReqToolsBase);
	CloseLibrary(XpkBase);
	CloseLibrary(DiskfontBase);
	CloseLibrary(AslBase);
	CloseLibrary(IFFParseBase);
	CloseLibrary((struct Library *)LocaleBase);
	CloseLibrary(CxBase);

	// closing ROM libraries:
	CloseLibrary(WorkbenchBase);
	CloseLibrary(IconBase);
	CloseLibrary(UtilityBase);
	CloseLibrary(GadToolsBase);
	CloseLibrary((struct Library *)GfxBase);
	CloseLibrary((struct Library *)IntuitionBase);
}
//______________________________________________________________________________

VOID
CleanupGadgets()
{
	if (Gads) {
		if (GList) {
			RemoveGList(Win,GList,-1);
			CleanupBackfill();
			FreeGadgets(GList);
			GList = NULL;
		}
		FreeVec(Gads);
		Gads = NULL;
	}
}
//_____________________________________________________________________________

__inline STATIC VOID
CleanupBackfill()
{
	struct Gadget	*g;

	if (g = Gads[GD_COUNT(OldID)]) {
		struct Image	*image,*next;

		image = (struct Image *)(g->GadgetRender);
		while (image) {
			next = image->NextImage;
			DisposeObject(image);
			image = next;
		}
	}
}
//_____________________________________________________________________________

__inline STATIC VOID
CleanupBOOPSIs()
{
	if (GetFileImage)       DisposeObject(GetFileImage);
	if (GetDirImage)        DisposeObject(GetDirImage);
	if (GetElseImage)       DisposeObject(GetElseImage);

	if (GetFileClass)       FreeClass(GetFileClass);
	if (GetDirClass)        FreeClass(GetDirClass);
	if (GetElseClass)       FreeClass(GetElseClass);
}
//_____________________________________________________________________________

VOID
CleanupWindow()
{
	if (AppWin) {
		RemoveAppWindow(AppWin);
		AppWin = NULL;
	}
	if (MsgPort) {
		DeleteMsgPort(MsgPort);
		MsgPort = NULL;
	}
	if (Win) {
		SetWinPtr(Win->UserData);
		ClearMenuStrip(Win);
		CloseWindow(Win);
		Win = NULL;
	}
}
//______________________________________________________________________________

__inline STATIC VOID
CleanupPrefs()
{
	if (SavPrf)     FreeVec(SavPrf);
	if (Prefs)      FreeVec(Prefs);
}
//______________________________________________________________________________

__inline STATIC VOID
CleanupCx()
{
	if (Broker) {
		DeleteCxObjAll(Broker);
		if (BrokerMP) {
			struct Message	*msg;

			while(msg = GetMsg(BrokerMP)) ReplyMsg(msg);
			DeletePort(BrokerMP);
		}
	}
}
//______________________________________________________________________________

__inline STATIC VOID
CleanupLists()
{
	if (AllDevsList)        FreeMinList(AllDevsList,TRUE);
	if (SelDevsList)        FreeMinList(SelDevsList,TRUE);
	if (CmpFilterList)      FreeMinList(CmpFilterList,TRUE);
	if (XpkNameList)        FreeMinList(XpkNameList,TRUE);
	if (XpkMethodList)      FreeMinList(XpkMethodList,TRUE);
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

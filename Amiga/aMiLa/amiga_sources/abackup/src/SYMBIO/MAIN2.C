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
    main2.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 13-Jan-98 by extraction from main.c
    Modified: 13-Jan-98
    _______________________________________________________________________
*/

#include "headers.h"

LONG		 HandleWindow	 (VOID);
BYTE		 HandleMain	 (UWORD);
BYTE		 HandleLoadTree  (UWORD);
BYTE		 HandleInfos	 (UWORD);
BYTE		 HandleSelection (UWORD,UWORD);
UWORD		 HandleClick	 (WORD,WORD,UWORD);
BYTE		 HandleMonitor	 (UWORD);
BYTE		 HandleArcReq	 (UWORD,UWORD);
BYTE		 HandleKeys	 (UWORD);
BYTE		 HandleMenus	 (UWORD);
BYTE		 HandleAppMsg	 (struct AppMessage *);

STATIC BYTE TmpBuf[MAXSTR+1];

//______________________________________________________________________________

__inline LONG
HandleWindow()
{
	BYTE	rc = CHANGE_WINDOW;

	NameFilter[0] =
	DateFilter[0] =
	BitsFilter[0] = '\0';

	SendMsgToPrefs((ULONG)Scr);

	do {
		PrepareWindow();
		if (NOT UpdateWindow()) return EXIT_FAILURE;

		if (FirstCall && NewID == WIN_MAIN) {
			FirstCall = FALSE;

			if (ProgramFlags & PF_WBSTART) {
					 if (IS_ARG_BACKUP ) PrgAction = PA_BACKUP;
				else if (IS_ARG_RESTORE) PrgAction = PA_RESTORE;
				else if (IS_ARG_VERIFY ) PrgAction = PA_VERIFY;

				NewID = WIN_LOADTREE;
				continue;
			}
		}

		if ( (NewID == WIN_SELECTION)    &&
		     (ProgramFlags & PF_WBSTART) &&
		     ARG_SELECT[0]		 &&
		     SetupFastMode(pGRoot))
		{
		  NewID = WIN_MONITOR;
		  continue;
		}

		FirstWinAction = TRUE;
		for ( rc = WindowAction() ; rc == KEEP_WINDOW ; rc = HandleIDCMP(TRUE) ) ;

		if (HasBeenQuit()) rc = QUIT;
	} while (rc != QUIT);

	return EXIT_SUCCESS;
}
//______________________________________________________________________________

BYTE
HandleIDCMP(BOOL wait)
{
	struct IntuiMessage		*imsg,msg;
	struct AppMessage		*appmsg;
	struct AmigaGuideMsg	*agmsg;
	ULONG	winsig,notsig,appsig,agsig,allsig,signals;
	UWORD	gadID;
	BYTE	rc = KEEP_WINDOW;

	winsig = Win? 1L<<Win->UserPort->mp_SigBit: NULL;
	notsig = NotSig != -1L? 1L<<NotSig: NULL;
	appsig = AWPort? 1L<<AWPort->mp_SigBit: NULL;
	agsig  = AGHandle? AmigaGuideSignal(AGHandle): NULL;
	allsig = winsig |notsig |appsig |agsig |SIGBREAKF_CTRL_C |SIGBREAKF_CTRL_F;

	do {
		signals = wait? Wait(allsig): SetSignal(NULL,NULL);
		if (NewID == WIN_MONITOR && NOT wait) signals |= winsig;

		// Ctrl-C: Quit.
		if (signals & SIGBREAKF_CTRL_C) return QUIT;

		// Ctrl-F: Activate window and bring it to front.
		if (signals & SIGBREAKF_CTRL_F) {
			WindowToFront(Win);
			ActivateWindow(Win);
		}

		// Prefs file notification:
		if (signals & notsig) ReadPrefs(NULL,&Prefs,FALSE);

		// AppWindow messages:
		if (signals & appsig) {
			while (appmsg = (struct AppMessage *)GetMsg(AWPort))
				rc = HandleAppMsg(appmsg);
		}

		// AmigaGuide messages:
		if (signals & agsig) {
			while (agmsg = GetAmigaGuideMsg(AGHandle))
				ReplyAmigaGuideMsg(agmsg);
		}

		// Drain IDCMP:
		if (signals & winsig) {
			while (imsg = GT_GetIMsg(Win->UserPort)) {
				memcpy(&msg,imsg,sizeof(struct IntuiMessage));
				GT_ReplyIMsg(imsg);

				if (OldID != NewID) continue;

				switch (msg.Class) {
					case IDCMP_REFRESHWINDOW:
						GT_BeginRefresh(Win);
						Render();
						GT_EndRefresh(Win,TRUE);
						break;

					case IDCMP_CLOSEWINDOW:
						if (ConfirmQuit()) return QUIT;
						break;

					case IDCMP_GADGETUP:
						gadID = ((struct Gadget *)msg.IAddress)->GadgetID;
						switch (NewID) {
							case WIN_MAIN:
								rc = HandleMain(gadID);
								break;
							case WIN_LOADTREE:
								rc = HandleLoadTree(gadID);
								break;
							case WIN_INFOS:
								rc = HandleInfos(gadID);
								break;
							case WIN_SELECTION:
								rc = HandleSelection(gadID,msg.Code);
								break;
							case WIN_MONITOR:
								rc = HandleMonitor(gadID);
								break;
							case WIN_ARCREQ:
								rc = HandleArcReq(gadID,msg.Code);
								break;
						}
						break;

					case IDCMP_MOUSEMOVE:
					case IDCMP_GADGETDOWN:
						if (NewID != WIN_SELECTION) break;
						if (DragSelect) msg.Code = SELECTDOWN;
						else {
							if (msg.Code != pCurrentDir->obj_UserData)
								rc = HandleSelection(((struct Gadget *)msg.IAddress)->GadgetID,msg.Code);
							break;
						}

						// CAUTION! FALL THROUGH!

					case IDCMP_MOUSEBUTTONS:
						if (NewID == WIN_SELECTION && msg.Code == SELECTDOWN) {
							cuSecs	 = msg.Seconds;
							cuMicros = msg.Micros;
							stCode	 = HandleClick(msg.MouseX,msg.MouseY,msg.Qualifier);
							stSecs	 = cuSecs;
							stMicros = cuMicros;
						}
						else DragSelect = FALSE;
						break;

					case IDCMP_VANILLAKEY:
						rc = HandleKeys(msg.Code);
						break;

					case IDCMP_RAWKEY:
						if (AGHandle && msg.Code == RAW_HELP)
							SendAmigaGuideCmd(AGHandle,NULL,AGA_Context,NewID,TAG_DONE);
						break;

					case IDCMP_MENUPICK:
						rc = HandleMenus(msg.Code);
						break;
				}
			}
		}
	} while (wait && rc == KEEP_WINDOW);

	return(rc);
}
//______________________________________________________________________________

__inline BYTE
HandleMain (UWORD gadID)
{
	BYTE	rc = CHANGE_WINDOW;

	switch (gadID) {
		case GD_BackupFilesDirs :
			if (ARG_FROM[0]) strcpy(StartDir,ARG_FROM);
			else if (NOT FileRequest(MSG_REQ_TITLE_DIR_REQUESTER,StartDir,FRF_DIRSONLY))
			{
				rc = KEEP_WINDOW;
				break;
			}
			PrgAction = PA_BACKUP;
			NewID = WIN_LOADTREE;
			break;

		case GD_BackupPartitions:
			UpdateDevList( NULL );
			pGRoot = DevList;
			PrgAction = PA_BACKUP;
			NewID = WIN_SELECTION;
			break;

		case GD_Restore:
			PrgAction = PA_RESTORE;
			NewID = WIN_ARCREQ;
			break;

		case GD_Verify:
			PrgAction = PA_VERIFY;
			NewID = WIN_ARCREQ;
			break;

		case GD_RebuildCatalog:
			PrgAction = PA_REBUILD;
			NewID = WIN_ARCREQ;
			break;

		case GD_Preferences:
			CallPrefs();
			rc = KEEP_WINDOW;
			break;
	}

	return(rc);
}
//______________________________________________________________________________

__inline BYTE
HandleLoadTree (UWORD gadID)
{
	if (gadID == GD_AbortTree) {
		SetPrgFlag(PF_BREAKED);
		NewID = WIN_MAIN;
		return CHANGE_WINDOW;
	}
	return KEEP_WINDOW;
}
//______________________________________________________________________________

__inline BYTE
HandleInfos (UWORD gadID)
{
	switch (gadID) {
		case GD_ContinueInfos:
			NewID = WIN_LOADTREE;
			break;
		case GD_AbortInfos:
			NewID = WIN_MAIN;
			break;
	}
	return CHANGE_WINDOW;
}
//______________________________________________________________________________

__inline BYTE
HandleSelection (UWORD gadID,UWORD code)
{
	LONG	rc,bits[2];

	switch (gadID) {
		case GD_Filter:
			FilterMode = code;
			break;

		case GD_Recursive:
			DoSelect(pCurrentDir,SEL_RECURSE,NULL);
			break;

		case GD_All:
			DoSelect(pCurrentDir,FilterMode == FILTER_INCLUDE?SEL_INCLOBJECT:SEL_EXCLOBJECT,NULL);
			RedrawDirList(pCurrentDir);
			break;

		case GD_Reverse:
			DoSelect(pCurrentDir,SEL_REVERSE,NULL);
			RedrawDirList(pCurrentDir);
			break;

		case GD_ByName:
			rc = StringRequest(NameFilter,MINSTR,GetStr(MSG_REQ_SELECTION),GetStr(MSG_REQ_PATTERN),MSG_REQ_PATTERN_GAD);
				 if (rc == TRUE)  DoSelect(pCurrentDir,FilterMode == FILTER_INCLUDE?SEL_INCLMATCH  :SEL_EXCLMATCH  ,NameFilter);
			else if (rc == FALSE) DoSelect(pCurrentDir,FilterMode == FILTER_INCLUDE?SEL_INCLNOMATCH:SEL_EXCLNOMATCH,NameFilter);
			else break;
			RedrawDirList(pCurrentDir);
			break;

		case GD_ByDate:
			if (BUByDate[0].ti_Data == ENABLE) {
				rc = StringRequest(DateFilter,MINSTR,GetStr(MSG_REQ_SELECTION),GetStr(MSG_REQ_DATE),MSG_REQ_DATE_GAD);
					 if (rc == TRUE)  DoSelect(pCurrentDir,FilterMode == FILTER_INCLUDE?SEL_INCLAFTER :SEL_EXCLAFTER ,DateFilter);
				else if (rc == FALSE) DoSelect(pCurrentDir,FilterMode == FILTER_INCLUDE?SEL_INCLBEFORE:SEL_EXCLBEFORE,DateFilter);
				else break;
				RedrawDirList(pCurrentDir);
			}
			break;

		case GD_ByBits:
			if ( (BUByBits[0].ti_Data == ENABLE) && BitRequest( &bits[0] , &bits[1] ) ) {
				DoSelect(pCurrentDir,FilterMode == FILTER_INCLUDE?SEL_INCLBIT:SEL_EXCLBIT,(BYTE *)bits);
				RedrawDirList(pCurrentDir);
			}
			break;

		case GD_Start:
			if (FilesSelected != 0L) {
				InitOperation();

				NewID = WIN_MONITOR;
				return CHANGE_WINDOW;
			}
			YesNoRequest(GetStr(MSG_WARN_NOTHING_SELECTED),NULL,MSG_REQ_OK,FALSE);
			break;

		case GD_Root:
			if (pCurrentDir != pGRoot) {
				DoSelect(pCurrentDir,SEL_ROOT,NULL);
				EnterDir(pGRoot);
			}
			break;

		case GD_Parent:
			if (pCurrentDir->obj_Parent) {
				DoSelect(pCurrentDir,SEL_PARENT,NULL);
				EnterDir(pCurrentDir->obj_Parent);
			}
			break;

		case GD_DirList:
			ScrollDirList(pCurrentDir,code);
			break;

		case GD_Prefs:
			HandleMain(GD_Preferences);
			break;

		case GD_Cancel:
			NewID = WIN_MAIN;
			return CHANGE_WINDOW;
	}
	return KEEP_WINDOW;
}
//______________________________________________________________________________

__inline UWORD
HandleClick (WORD mx,WORD my,UWORD qual)
{
	struct Object	*obj;
	UWORD	num,count;

	num = FindDirEntry(pCurrentDir,mx,my,DragSelect);
	if (obj = FindObjectByNum(pCurrentDir,num)) {
		if (NOT DragSelect) {
			if (num == stCode
			 && DoubleClick(stSecs,stMicros,cuSecs,cuMicros)
			 && NOT ObjIsDir(obj))
			{
				BlockWinInput();
				DisplayObject(obj);
				ReleaseWinInput();
			}
			else if (ObjIsNotEmptyDir(obj) && NOT(qual & RAW_SHIFTED)) {
				DoSelect(obj,SEL_ENTERDIR,NULL);
				EnterDir(obj);
				num = (UWORD)~0;
			}
			else {
				SelectDirEntry(obj,num-pCurrentDir->obj_UserData,DragSelect);
				DragSelect = TRUE;
			}
		}
		else if (num < stCode) {
			for (count = num; count < stCode; count++, obj = NextChild(obj))
				SelectDirEntry(obj,count-pCurrentDir->obj_UserData,DragSelect);
		}
		else if (num > stCode) {
			for (count = num; count > stCode; count--, obj = PrevChild(obj))
				SelectDirEntry(obj,count-pCurrentDir->obj_UserData,DragSelect);
		}
	}
	else num = (UWORD)~0;

	if (num == (UWORD)~0) DragSelect = FALSE;
	ReportMouse(DragSelect,Win);
	return(num);
}
//______________________________________________________________________________

__inline BYTE
HandleMonitor (UWORD gadID)
{
	struct Gadget	*g;

	switch (gadID) {
		case GD_Pause:
			g = Gads[gadID];

			if (HasBeenPaused())    ClearPrgFlag(PF_PAUSED);
			else					SetPrgFlag(PF_PAUSED);
			break;

		case GD_Abort:
			if (NOT HasBeenBreaked()
			 && NOT YesNoRequest(GetStr(MSG_REQ_ABORT),NULL,MSG_REQ_YES_NO,FALSE));
			else {
				SetPrgFlag(PF_BREAKED);
				ReportBreaked();
				return CHANGE_WINDOW;
			}
			break;
	}
	return KEEP_WINDOW;
}
//______________________________________________________________________________

__inline BYTE
HandleArcReq (UWORD gadID,UWORD code)
{
	BYTE rc = KEEP_WINDOW;

	switch (gadID) {
		case GD_ArcType:
			DEL(PRF_RESFLAGS,RFL_FROMFILE|RFL_FROMTAPE);

			UpdateTagData(GD_ArcType,GTCY_Active,code);
			UpdateTagData(GD_ArcFile,GA_Disabled,DISABLE);
			if (GTV39PLUS) {
				UpdateTagData(GD_DevList,GA_Disabled,DISABLE);
				UpdateTagData(GD_SelList,GA_Disabled,DISABLE);
			}

			switch (code) {
				case 0: if (GTV39PLUS) {
						UpdateTagData(GD_DevList,GA_Disabled,ENABLE);
						UpdateTagData(GD_SelList,GA_Disabled,ENABLE);
					}
					break;

				case 1: OR(PRF_RESFLAGS,RFL_FROMFILE);
					UpdateTagData(GD_ArcFile,GA_Disabled,ENABLE);
					break;

				case 2: OR(PRF_RESFLAGS,RFL_FROMTAPE);
					break;
			}

			if (GTV39PLUS) {
				GT_SetGadgetAttrsA(Gads[GD_DevList],Win,NULL,LVDLst);
				GT_SetGadgetAttrsA(Gads[GD_SelList],Win,NULL,LVDevs);
			}
			GT_SetGadgetAttrsA(Gads[GD_ArcFile],Win,NULL,STArcF);
			break;
		case GD_DevList:
			AddDevsNode(code,TRUE);
			break;
		case GD_SelList:
			AddDevsNode(code,FALSE);
			break;
		case GD_ArcFile:
			strcpy(PRF_RESFROM,((struct StringInfo *)Gads[gadID]->SpecialInfo)->Buffer);
			break;
		case GD_ArcFileReq:
			if (IS_RFL_FROMFILE && FileRequest(MSG_WIN_TITLE_ARCREQ,PRF_RESFROM,NULL))
				SetGad(GD_ArcFile,GTST_String,(ULONG)PRF_RESFROM);
			break;
		case GD_UseCatFile:
			XOR(PRF_RESFLAGS,RFL_USECATFILE);
			SetGad(GD_UseCatFile,GTCB_Checked,IS_RFL_USECATFILE?TRUE:FALSE);
			break;
		case GD_OkArcReq:
		case GD_CancelArcReq:
			if (IS_RFL_FROMDEVICE) ListToString(&SelDevsList,PRF_RESFROM);
			else if (IS_RFL_FROMTAPE) strcpy(PRF_RESFROM,"TAPE:");
			if (gadID == GD_CancelArcReq) {
				NewID = WIN_MAIN;
				rc = CHANGE_WINDOW;
			}
			else if (PRF_RESFROM[0]) {
				NewID = (PrgAction == PA_REBUILD) ? WIN_MONITOR : WIN_LOADTREE;
				rc = CHANGE_WINDOW;
			}
			else DisplayBeep(Scr);
			break;
	}
	return(rc);
}

//______________________________________________________________________________

__inline BYTE
HandleKeys (UWORD code)
{
	BYTE	rc = KEEP_WINDOW;

	switch (NewID) {
		case WIN_MAIN:
			if (code == 0x1B && ConfirmQuit()) return QUIT;
			else if (SHCUT(MSG_BACKUP_FILES))               rc = HandleMain(GD_BackupFilesDirs);
			else if (SHCUT(MSG_BACKUP_PARTITIONS))  rc = HandleMain(GD_BackupPartitions);
			else if (SHCUT(MSG_RESTORE))                    rc = HandleMain(GD_Restore);
			else if (SHCUT(MSG_VERIFY))                             rc = HandleMain(GD_Verify);
			else if (SHCUT(MSG_REBUILD_CATALOG))    rc = HandleMain(GD_RebuildCatalog);
			else if (SHCUT(MSG_PREFERENCES))                rc = HandleMain(GD_Preferences);
			break;

		case WIN_LOADTREE:
			if (code == 0x1B || SHCUT(MSG_ABORT))
				rc = HandleLoadTree(GD_AbortTree);
			break;

		case WIN_INFOS:
			if (code == 0x0D || SHCUT(MSG_CONTINUE))
				rc = HandleInfos(GD_ContinueInfos);
			else if (code == 0x1B || SHCUT(MSG_ABORT))
				rc = HandleInfos(GD_AbortInfos);
			break;

		case WIN_SELECTION:
			if (code == 0x0D
				|| PrgAction == PA_BACKUP  && SHCUT(MSG_START_BACKUP)
				|| PrgAction == PA_RESTORE && SHCUT(MSG_START_RESTORE)
				|| PrgAction == PA_VERIFY  && SHCUT(MSG_START_VERIFY))
				rc = HandleSelection(GD_Start,NULL);
			else if (code == 0x1B || SHCUT(MSG_CANCEL))
				rc = HandleSelection(GD_Cancel,NULL);
			else if (SHCUT(MSG_FILTER)) {
				FLIP(FilterMode);
				SetGad(GD_Filter,GTCY_Active,FilterMode);
			}
			else if (SHCUT(MSG_RECURSIVE)) {
				rc = HandleSelection(GD_Recursive,NULL);
				SetGad(GD_Recursive,GTCB_Checked,RecursionFlag);
			}
			else if (SHCUT(MSG_PREFERENCES))    rc = HandleSelection(GD_Prefs,NULL);
			else if (SHCUT(MSG_ALL))                rc = HandleSelection(GD_All,NULL);
			else if (SHCUT(MSG_REVERSE))    rc = HandleSelection(GD_Reverse,NULL);
			else if (SHCUT(MSG_BYNAME))             rc = HandleSelection(GD_ByName,NULL);
			else if (SHCUT(MSG_BYDATE))             rc = HandleSelection(GD_ByDate,NULL);
			else if (SHCUT(MSG_BYBITS))             rc = HandleSelection(GD_ByBits,NULL);
			else if (SHCUT(MSG_ROOT))               rc = HandleSelection(GD_Root,NULL);
			else if (SHCUT(MSG_PARENT))             rc = HandleSelection(GD_Parent,NULL);
			break;

		case WIN_MONITOR:
			if (SHCUT(MSG_PAUSE)) {
				rc = HandleMonitor(GD_Pause);
				RemoveGadget(Win,Gads[GD_Pause]);
				Gads[GD_Pause]->NextGadget = NULL ;
				if ( HasBeenPaused() ) Gads[GD_Pause]->Flags |=  GFLG_SELECTED ;
						  else Gads[GD_Pause]->Flags &= ~GFLG_SELECTED ;
				AddGadget(Win,Gads[GD_Pause],0);
				RefreshGList(Gads[GD_Pause],Win,NULL,1);
			}
			else if (code == 0x1B || SHCUT(MSG_ABORT))
				rc = HandleMonitor(GD_Abort);
			break;

		case WIN_ARCREQ :
			if (SHCUT(MSG_ARC_TYPE)) {
				if (IS_RFL_FROMFILE) code = 2;
				else if (IS_RFL_FROMTAPE) code = 0;
				else code = 1;
				SetGad(GD_ArcType,GTCY_Active,code);
				rc = HandleArcReq(GD_ArcType,code);
			}
			else if (SHCUT(MSG_ARC_FILE)) {
				code = 1;
				SetGad(GD_ArcType,GTCY_Active,code);
				rc = HandleArcReq(GD_ArcType,code);
				ActivateGadget(Gads[GD_ArcFile],Win,NULL);
			}
			else if (SHCUT(MSG_ARC_CATFILE))              rc = HandleArcReq(GD_UseCatFile  ,0);
			else if ((code == 0x0D) || SHCUT(MSG_OK))     rc = HandleArcReq(GD_OkArcReq    ,0);
			else if ((code == 0x1B) || SHCUT(MSG_CANCEL)) rc = HandleArcReq(GD_CancelArcReq,0);
			break;
	}
	return(rc);
}
//______________________________________________________________________________

__inline BYTE
HandleMenus (UWORD code)
{
	UBYTE	item;
	BYTE	rc = KEEP_WINDOW;

	while (code != MENUNULL) {
		item = ITEMNUM(code);
		switch (MENUNUM(code)) {
			case MENU_PROJECT:
				switch (item) {
					case MENU_PROJECT_ESTIMATE:
						Notify(MSG_REQUEST,Estimate(pGRoot,NULL),MSG_REQ_OK,NULL,NULL);
						break;

					case MENU_PROJECT_PRINT:
						PrintCurrentList(pCurrentDir);
						break;

					case MENU_PROJECT_ADDDIR:
						TmpBuf[0] = '\0';
						if (FileRequest(MSG_REQ_TITLE_DIR_REQUESTER,TmpBuf,FRF_DIRSONLY)) {
							pGRoot = AddDirTree(pGRoot,TmpBuf);
							EnterDir(pGRoot);
						}
						break ;

					case MENU_PROJECT_ABOUT:
						About();
						break;

					case MENU_PROJECT_QUIT:
						if (ConfirmQuit()) rc = QUIT;
						break;
				}
				break;

			case MENU_SELECT:
				switch (item) {
					case MENU_SELECT_OPEN:
						strcpy(FullName,PRF_SELECTPATH);
						if (FileRequest(MSG_REQ_TITLE_SELECTION_FILE,FullName,NULL))
							LoadSelectFile(FullName);
						break;

					case MENU_SELECT_RECORD:
						strcpy(FullName,PRF_SELECTPATH);
						if (FileRequest(MSG_REQ_TITLE_SELECTION_FILE,FullName,NULL))
						{
							if (RecordSelect(FullName)) PrepareMenus(TRUE);
							else HandleError(FullName,ABERR_CANNOT_OPEN);
						}
						break;

					case MENU_SELECT_SAVE:
						PrepareMenus(FALSE);
						SaveSelect();
						break;

					case MENU_SELECT_ABORT:
						PrepareMenus(FALSE);
						AbortSelect();
						break;
				}
				break;
		}
		code = (ItemAddress(Menus,(ULONG)code))->NextSelect;
	}
	return(rc);
}
//______________________________________________________________________________

__inline BYTE
HandleAppMsg (struct AppMessage *pMsg)
{
	struct WBArg	*pArg;
	LONG	k;
	BYTE	rc;

	// Double-click on the AppIcon?

	if ( pMsg->am_Type == AMTYPE_APPICON ) {
		ScreenToFront(Scr);
		WindowToFront(Win);
	}

	/*
	 *	Concatenate all argument's names in TmpBuf[]
	 *	multiple argument's names will be separated by a comma
	 */

	TmpBuf[0] = '\0' ;
	for (k = 0L; k < pMsg->am_NumArgs; k++) {
		pArg = &(pMsg->am_ArgList[k]);
		if (pArg->wa_Lock && NameFromLock(pArg->wa_Lock,IOBuf,MAXSTR));
		else IOBuf[0] = '\0';
		if (pArg->wa_Name[0]) AddPart(IOBuf,pArg->wa_Name,MAXSTR);
		if (k && TmpBuf[0]) strcat(TmpBuf,",");
		strcat(TmpBuf,IOBuf);
	}

	ReplyMsg((struct Message *)pMsg);
	if (NOT k) return(KEEP_WINDOW);

	/*
	 *	Determine argument type:
	 *	-1	unknown
	 *	 0	prefs file
	 *	 1	selection file
	 *	 2	archive file or volume
	 *	 3	directory, volume or list of volumes
	 */

	if (TmpBuf[0]) {
		if (strchr(TmpBuf,',')) k = 3;
		else {
			k = strlen(TmpBuf)-1;
			if (TmpBuf[k] == ':') {
				if (NOT MyInfo(TmpBuf,NULL) && IoErr() == ERROR_NOT_A_DOS_DISK)
					 k = 2;
				else k = 3;
			}
			else if (MyExamine(TmpBuf)) {
				if (GFib.fib_DirEntryType > 0L) k = 3;
				else {
					k = GetFileType(TmpBuf,FALSE);
						 if (k == FTYPE_IFFOTHER)       k = 0;
					else if (k == FTYPE_ASCII)              k = 1;
					else if (k == FTYPE_ABACKUP)    k = 2;
					else							k = -1;
				}
			}
			else k = -1;
		}
	}

	// Reacts using NewID and argument type:

	rc = KEEP_WINDOW;
	switch (k) {
		case 0:
			ReadPrefs(TmpBuf,&Prefs,FALSE);
			break;

		case 1:
			if (NewID == WIN_SELECTION) LoadSelectFile(TmpBuf);
			break;

		case 2:
			if (NewID == WIN_MAIN) {
				strcpy(StartDir,TmpBuf);
				PrgAction = PA_RESTORE;
				NewID = WIN_LOADTREE;
				rc = CHANGE_WINDOW;
			}
			break;

		case 3:
			if (NewID == WIN_MAIN) {
				strcpy(StartDir,TmpBuf);
				PrgAction = PA_BACKUP;
				NewID = WIN_LOADTREE;
				rc = CHANGE_WINDOW;
			}
			else if ( (NewID == WIN_SELECTION) && (PrgAction == PA_BACKUP) && (pGRoot != DevList) ) {
				pGRoot = AddDirTree(pGRoot,TmpBuf);
				EnterDir(pGRoot);
			}
			break;
	}
	return(rc);
}

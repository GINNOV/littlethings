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
    main.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 03-Oct-93
    Modified: 13-Jan-98
    _______________________________________________________________________
*/
#include "headers.h"
#include "main.h"

#ifdef _PROFILE
#include <sprof.h>
extern void SetupProfile(void);
extern void CleanupProfile(void);
#endif

VOID    	 PrepareWindow   (VOID);
BYTE    	 WindowAction    (VOID);
VOID    	 EnterDir        (struct Object *);
BOOL    	 ConfirmQuit     (VOID);
BOOL    	 SendMsgToPrefs  (ULONG);
VOID    	 CallPrefs       (VOID);
VOID    	 LoadSelectFile  (BYTE *);
VOID    	 AddDevsNode     (UWORD,BOOL);
BOOL    	 MakeAllDevsList (VOID);

extern long __stack, __STKNEED ;
extern struct ExecBase *SysBase ;

//______________________________________________________________________________

int
main (int argc,char *argv[])
{
	LONG    rc;

#ifdef _PROFILE
	SetupProfile();
#endif

#ifdef _M68060
	if (! (SysBase->AttnFlags & AFF_68060)) return( RETURN_FAIL ) ;
#endif

	/* the two following variables control the stack space */
	__STKNEED = KBYTES(4) ;  // minimum free stack when entering a recursive function
	__stack   = KBYTES(20) ; // stack space to allocate if less then __STKNEED bytes free

	NewList(&SelDevsList);
	NewList(&AllDevsList);

	if (Setup(argc) && MakeAllDevsList()) {
		if (argc) {
				 if (IS_ARG_BACKUP ) rc = BatchBackup();
			else if (IS_ARG_RESTORE) rc = BatchRestore();
			else if (IS_ARG_VERIFY ) rc = BatchVerify();
			CloseArc(Archive);
		}
		if (rc != EXIT_FAILURE && NOT BATCHMODE) rc = HandleWindow();
	}
	else rc = EXIT_FAILURE;

	FreeNameList(&SelDevsList);
	FreeNameList(&AllDevsList);
	Cleanup();

#ifdef _PROFILE
	CleanupProfile();
#endif

	// if custom screen couldn't be closed, because of visitor windows,
	// then we NEVER exit, so the screen remain opened
	if (Scr) Wait(0L);

	return(rc);
}
//______________________________________________________________________________

__inline VOID
PrepareWindow()
{
	BYTE    *p,*q;

	FOREVER {
		switch (NewID) {
			case WIN_MAIN:
				DoSelect(DevList,SEL_EXCLOBJECT,NULL);
				ClearPrgFlag(PF_BREAKED|PF_PAUSED|PF_CATALFOUND);

				CryptLen	  =  0;
				CryptSum	  = -1;
				PrgAction         = -1;
				FilesSelected =
				BytesSelected = 0L;
				pCurrentDir       = NULL;
				DevList->obj_UserData = 0;

				if (NOT FirstCall) EraseAllArgs(FALSE);

				if (pGRoot && pGRoot != DevList) {
					if (ObjIsCatalog(pGRoot)) FreeCatalog(pGRoot);
					else FreeDirTree(pGRoot);
					pGRoot = NULL;
				}
				CloseArc(Archive);
				break;

			case WIN_LOADTREE:
				if (PrgAction == PA_BACKUP) {
					WIN_TITLE       			= MSG_WIN_TITLE_LOADING_TREE;
					TXTreeStatus[0].ti_Data = (ULONG)GetStr(MSG_LOADING_TREE);
					TXDirTree[0].ti_Data    = (ULONG)StartDir;
				}
				else {
					WIN_TITLE       			= MSG_WIN_TITLE_LOADING_CATALOG;
					TXTreeStatus[0].ti_Data = (ULONG)GetStr(MSG_SEARCHING_CATALOG);
					TXDirTree[0].ti_Data    = (ULONG)GetStr(MSG_CATALOG);
				}
				break;

			case WIN_INFOS:
				p = PackedDateToStr(IdntDate);
				p+= 4;
				if (q = strchr(p,' ')) *q++ = '\0';

				TXSource[0].ti_Data     = (ULONG)RootName;
				TXDate[0].ti_Data       = (ULONG)p;
				TXTime[0].ti_Data       = (ULONG)q;

				switch (GArcInfo.ai_CType) {
					case 1:
						p = GetStr(MSG_CTYPE_NONE);
						break;
					case 2:
						p = GetStr(MSG_CTYPE_INTERNAL);
						break;
					case 3:
						p = GetStr(MSG_CTYPE_EXTERNAL);
						break;
					case 4:
						SPrintf(TmpBuf,GetStr(MSG_CTYPE_XPKLIB),GArcInfo.ai_XpkMethod);
						p = TmpBuf;
						break;
				}
				TXCompress[0].ti_Data = (ULONG)p;
				TXComment[0].ti_Data  = (ULONG)pGHdr->h_Comment;
				break;

			case WIN_SELECTION:
				ClearPrgFlag(PF_BREAKED|PF_PAUSED);
				switch (PrgAction) {
					case PA_BACKUP:
						WIN_TITLE       			= MSG_WIN_TITLE_BACKUP_SELECTION;
						GD_TEXT(GD_Start)       	= MSG_START_BACKUP;

						GetFullName(FullName,pGRoot);
						break;

					case PA_RESTORE:
						WIN_TITLE       			= MSG_WIN_TITLE_RESTORE_SELECTION;
						GD_TEXT(GD_Start)       	= MSG_START_RESTORE;

						BuildDestName(FullName,pGRoot);
						break;

					case PA_VERIFY:
						WIN_TITLE       			= MSG_WIN_TITLE_VERIFY_SELECTION;
						GD_TEXT(GD_Start)       	= MSG_START_VERIFY;

						GetFullName(FullName,pGRoot);
						break;
				}

				if (ObjIsDevice(pGRoot)) {
					GD_TEXT(GD_Files)       	= MSG_PARTITIONS;
					GD_TEXT(GD_Directory)   = MSG_VOID;

					TXDir[0].ti_Data		= NULL;
					TXDir[1].ti_Data		= FALSE;

					BUByDate[0].ti_Data     	=
					BUByBits[0].ti_Data     	=
					BURoot[0].ti_Data       	=
					BUParent[0].ti_Data     	= DISABLE;
				}
				else {
					GD_TEXT(GD_Files)       	= MSG_FILES;
					GD_TEXT(GD_Directory)   = MSG_DIRECTORY;

					TXDir[0].ti_Data		= (ULONG)FullName;
					TXDir[1].ti_Data		= TRUE;

					BUByDate[0].ti_Data     	=
					BUByBits[0].ti_Data     	= ENABLE;
					BURoot[0].ti_Data       	=
					BUParent[0].ti_Data     	= (BOOL)(NOT pGRoot->obj_Parent);
				}

				CYFilter[1].ti_Data     	= (ULONG)FilterMode;
				CBRecursive[0].ti_Data  = (ULONG)RecursionFlag;
				TXFiles[0].ti_Data      	=
				TXSize[0].ti_Data       	= NULL;
				break;

			case WIN_MONITOR:
				switch (PrgAction) {
					case PA_BACKUP:
						WIN_TITLE       			= MSG_WIN_TITLE_BACKUP;
						GD_TEXT(GD_SavedFiles)  = MSG_SAVED;
						GD_TEXT(GD_Source)      	= MSG_DESTINATION;
						TXReport[1].ti_Data     	= IS_BFL_REPORT;
						break;
					case PA_RESTORE:
						WIN_TITLE       			= MSG_WIN_TITLE_RESTORE;
						GD_TEXT(GD_SavedFiles)  = MSG_RESTORED;
						GD_TEXT(GD_Source)      	= MSG_SOURCE;
						TXReport[1].ti_Data     	= IS_RFL_REPORT;
						break;
					case PA_VERIFY:
						WIN_TITLE       			= MSG_WIN_TITLE_VERIFY;
						GD_TEXT(GD_SavedFiles)  = MSG_VERIFIED;
						GD_TEXT(GD_Source)      	= MSG_SOURCE;
						TXReport[1].ti_Data     	= IS_VFL_REPORT;
						break;
					case PA_REBUILD:
						WIN_TITLE       			= MSG_WIN_TITLE_REBUILD;
						GD_TEXT(GD_SavedFiles)  = MSG_READ;
						GD_TEXT(GD_Source)      	= MSG_SOURCE;
					default:
						TXReport[1].ti_Data     	= FALSE;
						break;
				}

				TXDestination[0].ti_Data =
				TXSavedGauge[0].ti_Data  =
				TXLeftGauge[0].ti_Data   =
				TXCompGauge[0].ti_Data   =
				TXDiskGauge[0].ti_Data   =
				TXReport[0].ti_Data     	 = NULL;

				BytesWritten = 0L;
				break;

			case WIN_ARCREQ :

				LVDLst[1].ti_Data = (ULONG)&AllDevsList;
				LVDevs[1].ti_Data = (ULONG)&SelDevsList;

				if (IS_RFL_FROMDEVICE) {
					FreeNameList(&SelDevsList);
					StringToList(&SelDevsList,PRF_RESFROM);
					PRF_RESFROM[0]    = '\0';
					CYDevs[1].ti_Data = 0L;
					LVDLst[0].ti_Data =
					LVDevs[0].ti_Data = ENABLE;
					STArcF[0].ti_Data = DISABLE;
				}
				else {
					LVDLst[0].ti_Data =
					LVDevs[0].ti_Data = DISABLE;

					if (IS_RFL_FROMFILE) {
						CYDevs[1].ti_Data = 1L;
						STArcF[0].ti_Data = ENABLE;
					}
					else {
						PRF_RESFROM[0] = '\0';
						CYDevs[1].ti_Data = 2L;
						STArcF[0].ti_Data = DISABLE;
					}
				}
				STArcF[1].ti_Data = (ULONG)PRF_RESFROM;
				CBCatF[0].ti_Data = IS_RFL_USECATFILE?TRUE:FALSE;
				break ;
		}
		return;
	}
}
//______________________________________________________________________________

__inline BYTE
WindowAction()
{
	BOOL    rc;

	switch (NewID) {
		case WIN_LOADTREE:
			if (NOT FirstWinAction) break;
			FirstWinAction = FALSE;

				 if (ARG_FROM[0])       		 strcpy(StartDir,ARG_FROM);
			else if (PrgAction != PA_BACKUP) strcpy(StartDir,PRF_RESFROM);

			if (PrgAction != PA_BACKUP && NOT(ProgramFlags & PF_CATALFOUND)) {
				if (FindCatalog(StartDir,IS_RFL_USECATFILE)) {
					if (NOT OldArchiveFmt()) NewID = WIN_INFOS;
				}
				else NewID = WIN_MAIN;
			}
			else {
				pGRoot = PrgAction == PA_BACKUP? LoadDirTree(StartDir): LoadCatalog(IS_RFL_USECATFILE);
				if (pGRoot) {
					if (PrgAction == PA_VERIFY && NOT IS_VFL_SELECTIVE) {
						DoSelect(pGRoot,SEL_INCLOBJECT,NULL);
						NewID = WIN_MONITOR;
						InitOperation();
					}
					else NewID = WIN_SELECTION;
				}
				else NewID = WIN_MAIN;
			}
			if (Archive) StopArc(Archive,TRUE);
			return CHANGE_WINDOW;

		case WIN_INFOS:
			SetNM2TX(GD_BackupFiles,GArcInfo.ai_NumFiles,TFiles);
			SetNM2TX(GD_BackupSize ,GArcInfo.ai_NumBytes,TBytes);
			break;

		case WIN_SELECTION:
			if (FirstWinAction) EnterDir(pGRoot);
			FirstWinAction = FALSE;

			SetNM2TX(GD_Files,FilesSelected,TFiles);
			SetNM3TX(GD_Size ,BytesSelected,TBytes);
			SetGad(GD_Bytes,GTTX_Text,(ULONG)GetStr(GetByteID(BytesSelected)));
			break;

		case WIN_MONITOR:
			if (NOT FirstWinAction) break;
			FirstWinAction = FALSE;

			// reset infos position:
			YPos = PBounds.MinY;

			// restore default pens:
			SetAPen(Win->RPort,Pens[TEXTPEN]);
			SetBPen(Win->RPort,Pens[BACKGROUNDPEN]);

			MonitorStatus(Archive);
#ifdef _PROFILE
			PROFILE_ON();
#endif

			switch (PrgAction) {
				case PA_BACKUP:
					SetGauge(GD_DiskGauge,0L,perDisk);
					rc = DoBackup(pGRoot,ARG_TO[0]? ARG_TO: PRF_BUPTO);
					break;
				case PA_RESTORE:
					rc = DoRestore(pGRoot,ARG_TO[0]? ARG_TO: PRF_RESTO);
					break;
				case PA_VERIFY:
					rc = DoVerify(pGRoot);
					if (NOT strcmp(StartDir,PRF_RESFROM))
						strcpy(StartDir,"RAM:");
					break;
				case PA_REBUILD:
					rc = DoRebuild(PRF_RESFROM);
					break;
			}

#ifdef _PROFILE
			PROFILE_OFF();
#endif
			MonitorStatus(Archive);

			if (rc) {
				if ( (PrgAction == PA_RESTORE) && (NOT strcmp(StartDir,PRF_RESFROM)) )
					strcpy( StartDir , "RAM:" ) ;
				if (PrgAction == PA_RESTORE || PrgAction == PA_VERIFY) StopArc(Archive,TRUE);
				NewID = WIN_MAIN;
				if (PrgAction != PA_REBUILD) {
					WakeUpUser();
					if (NOT YesNoRequest(GetStr(MSG_REQ_FINISHED),NULL,MSG_REQ_YES_NO,FALSE))
						NewID = WIN_SELECTION;
				}
				if (NewID == WIN_MAIN) CloseArc(Archive);
			}
			else {
				if (PrgAction == PA_REBUILD) {
					CloseArc(Archive);
					NewID = WIN_MAIN;
				}
				else {
					if (PrgAction == PA_BACKUP) CloseArc(Archive);
					else StopArc(Archive,TRUE);
					NewID = WIN_SELECTION;
				}
			}
			ClearPrgFlag(PF_WBSTART);
			return CHANGE_WINDOW;
	}
	return KEEP_WINDOW;
}
//______________________________________________________________________________

VOID
EnterDir (struct Object *obj)
{
	if (PrgAction == PA_RESTORE) BuildDestName(FullName,obj);
	else    					 GetFullName(FullName,obj);
	SetGad(GD_Directory,GTTX_Text,(ULONG)FullName);

	SCFileList[1].ti_Data = (ULONG)obj->obj_UserData;
	SCFileList[2].ti_Data = (ULONG)obj->obj_Size;
	GT_SetGadgetAttrsA(Gads[GD_DirList],Win,NULL,SCFileList);
/*
	SetGad(GD_DirList,GTSC_Top      ,(ULONG)obj->obj_UserData);
	SetGad(GD_DirList,GTSC_Total,(ULONG)obj->obj_Size);
*/
	if (obj->obj_Parent) {
		SetGad(GD_Parent,GA_Disabled,ENABLE);
		SetGad(GD_Root  ,GA_Disabled,ENABLE);
	}
	else {
		SetGad(GD_Parent,GA_Disabled,DISABLE);
		SetGad(GD_Root  ,GA_Disabled,DISABLE);
	}

	pCurrentDir = obj;
	RedrawDirList(pCurrentDir);
	DragSelect = FALSE;
}
//______________________________________________________________________________

BOOL
ConfirmQuit()
{
	if (YesNoRequest(GetStr(MSG_REQ_QUIT),NULL,MSG_REQ_YES_NO,FALSE)) {
		SetPrgFlag(PF_BREAKED|PF_QUIT);
		ReportBreaked();
		return TRUE;
	}
	return FALSE;
}
//______________________________________________________________________________

BOOL
SendMsgToPrefs( ULONG data )
{
	struct MsgPort *IPCMsgPort;
	struct Message *msg = NULL;

	Forbid();
	if (IPCMsgPort = FindPort(_IPC_PORT_NAME_)) {
		if (msg = AllocVec(sizeof(struct Message),MEMF_CLEAR|MEMF_PUBLIC)) {
			msg->mn_Length = data;
			PutMsg(IPCMsgPort,msg);
		}
	}
	Permit();

	if (IPCMsgPort && (NOT msg)) {
		Warning(MSG_WARN_MEMORY);
		IPCMsgPort = NULL;
	}
	return( (BOOL)IPCMsgPort );
}

//______________________________________________________________________________

__inline VOID
CallPrefs()
{
	TEXT    command[512];
	BYTE    winnum;
	BPTR    fh;

	switch (PrgAction) {
		case PA_BACKUP:
			winnum = 1;     // call prefs 'Backup Options' window
			break;
		case PA_RESTORE:
			winnum = 2;     // call prefs 'Restore Options' window
			break;
		case PA_VERIFY:
			winnum = 3;     // call prefs 'Verify Options' window
			break;
		default:
			winnum = 0;     // call prefs main window
			break;
	}

	if (NOT SendMsgToPrefs( (winnum << 1) | 0x01 )) {
		SPrintf(command,"%s W=%ld",ARG_PPATH,winnum);
		SysTLTags[0].ti_Data = (ULONG)(fh = Open("NIL:",MODE_OLDFILE));
		if (SystemTagList(command,SysTLTags) != RETURN_OK) {
			if (fh) Close(fh);
			if (IoErr() == ERROR_OBJECT_NOT_FOUND)
				Warning(MSG_WARN_PREFS_NOT_FOUND);
		}
	}
}
//______________________________________________________________________________

VOID
LoadSelectFile (BYTE *name)
{
	struct Object   *dir;

	BlockWinInput();
	dir = PlaySelect(pCurrentDir,name);
	ReleaseWinInput();

	if (dir) EnterDir(dir);
	RedrawDirList(pCurrentDir);
}
//______________________________________________________________________________

VOID
AddDevsNode (UWORD code,BOOL add)
{
	struct Node     *nn;

	SetGad(GD_SelList,GTLV_Labels,(ULONG)~0);

	if (nn = FindDevNode(add?&AllDevsList:&SelDevsList,code)) {
		if (add) {
			if(! FindName(&SelDevsList,nn->ln_Name))
				AddName(&SelDevsList,nn->ln_Name);
		}
		else {
			Remove(nn);
			MyFreeMem(nn);
		}
	}

	SetGad(GD_SelList,GTLV_Labels,(ULONG)&SelDevsList);
}

//______________________________________________________________________________

BOOL
MakeAllDevsList()
{
  struct Object *p, *q;

  for ( p = FirstChild(DevList);q = NextChild(p); p = q )
    if (NOT AddName(&AllDevsList,p->obj_Name)) return(FALSE);

  return(TRUE);
}


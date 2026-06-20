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
/*      ___________________

	ABackup Prefs
	handle.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 18-Jan-98 by extraction from main.c
	Modified: 18-Jan-98
	___________________
*/

#include "headers.h"

STATIC VOID AddDevsNode (UWORD,BOOL);
STATIC VOID CheckFontSize (UWORD,STRPTR,UWORD *);
STATIC VOID CheckFontName (UWORD,STRPTR,UWORD);

//______________________________________________________________________________

BYTE HandleMain (UWORD gadID,UWORD code)
{
	switch (gadID) {
		case GD_Backup  :       NewID = WIN_BACKUP;
							break;
		case GD_Restore :       NewID = WIN_RESTORE;
							break;
		case GD_Verify  :       NewID = WIN_VERIFY;
							break;
		case GD_Compress:       NewID = WIN_COMPRESS;
							break;
		case GD_Tape    :       NewID = WIN_TAPE;
							break;
		case GD_GUI     	:       NewID = WIN_GUI;
							break;
		case GD_External:       NewID = WIN_EXTERNAL;
							break;
		case GD_Misc    :       NewID = WIN_MISC;
							break;

		case GD_Save:   if (NOT WRITE_ENVARC) return FALSE;
		case GD_Use     :       if (NOT WRITE_ENV)        return FALSE;
		case GD_Quit:   return DISAPPEAR;
	}
	return SAVE;
}
//______________________________________________________________________________

VOID HandleBackup (UWORD gadID,UWORD code)
{
	switch (gadID) {
		case GD_BackupTo:
			DEL(PRF_BUPFLAGS,BFL_TOFILE|BFL_TOTAPE);

			UpdateTagData(GD_BackupTo       	,GTCY_Active,code);
			UpdateTagData(GD_BackupArcFile  ,GA_Disabled,DISABLE);
			if (GTV39PLUS) {
				UpdateTagData(GD_BackupDeviceList       ,GA_Disabled,DISABLE);
				UpdateTagData(GD_BackupDevices  	,GA_Disabled,DISABLE);
			}

			switch (code) {
				case 0: if (GTV39PLUS) {
							UpdateTagData(GD_BackupDeviceList       ,GA_Disabled,ENABLE);
							UpdateTagData(GD_BackupDevices  	,GA_Disabled,ENABLE);
						}
						break;

				case 1: OR(PRF_BUPFLAGS,BFL_TOFILE);
						UpdateTagData(GD_BackupArcFile,GA_Disabled,ENABLE);
						break;

				case 2: OR(PRF_BUPFLAGS,BFL_TOTAPE);
						break;
			}

			if (GTV39PLUS) {
				GT_SetGadgetAttrsA(Gads[GD_BackupDeviceList],Win,NULL,LVDLst);
				GT_SetGadgetAttrsA(Gads[GD_BackupDevices]       ,Win,NULL,LVDevs);
			}
			GT_SetGadgetAttrsA(Gads[GD_BackupArcFile],Win,NULL,STArcF);
			break;

		case GD_BackupDeviceList:
			AddDevsNode(code,TRUE);
			break;

		case GD_BackupDevices:
			AddDevsNode(code,FALSE);
			break;

		case GD_BackupArcFile:
			// NOTE: accessibility isn't checked here...
			GDST_COPY(PRF_BUPTO);
			break;
		case GD_BackupArcFileLoad:
			if (IS_BFL_TOFILE && LoadFile(PRF_BUPTO,DIRORFILE,MSG_SELECT_BACKUP_DESTINATION))
				SetGad(GD_BackupArcFile,GTST_String,(ULONG)PRF_BUPTO);
			break;

		case GD_BufferSize:
			PRF_BUFSIZE = code;
			break;

		case GD_LogFile:
			GDST_COPY(PRF_LOGFILE);
			break;
		case GD_LogFileLoad:
			if (LoadFile(PRF_LOGFILE,FILEONLY,MSG_SELECT_LOG_FILE)) {
				strmfe(PRF_LOGFILE,PRF_LOGFILE,"log");
				SetGad(GD_LogFile,GTST_String,(ULONG)PRF_LOGFILE);
			}
			break;

		case GD_DefaultComment:
			GDST_COPY(PRF_DEFCOMMENT);
			break;

		case GD_BackupReport:
			XOR(PRF_BUPFLAGS,BFL_REPORT);
			SetGad(GD_BackupReportTo,  GA_Disabled,NOT IS_BFL_REPORT);
			SetGad(GD_BackupReportType,GA_Disabled,NOT IS_BFL_REPORT);
			break;
		case GD_BackupReportTo:
			XOR(PRF_BUPFLAGS,BFL_REPTOFILE);
			UpdateTagData(GD_BackupReportTo,GTCY_Active,IS_BFL_REPTOFILE);
			break;
		case GD_BackupReportType:
			XOR(PRF_BUPFLAGS,BFL_REPSHORT);
			UpdateTagData(GD_BackupReportType,GTCY_Active,NOT IS_BFL_REPSHORT);
			break;

		case GD_BackupVerify:
			XOR(PRF_BUPFLAGS,BFL_VERIFY);
			break;
		case GD_UseChildTask:
			XOR(PRF_BUPFLAGS,BFL_CHILDTASK);
			break;
		case GD_BackupLinks:
			XOR(PRF_BUPFLAGS,BFL_LINKS);
			break;
		case GD_AddComment:
			XOR(PRF_BUPFLAGS,BFL_ADDCOMMENT);
			SetGad(GD_DefaultComment,GA_Disabled,NOT IS_BFL_ADDCOMMENT);
			break;
		case GD_AddIcon:
			XOR(PRF_BUPFLAGS,BFL_ADDICON);
			break;
		case GD_CompressData:
			XOR(PRF_BUPFLAGS,BFL_COMPRESS);
			break;
		case GD_CompressCatalog:
			XOR(PRF_BUPFLAGS,BFL_CATCOMP);
			break;
		case GD_Encrypt:
			XOR(PRF_BUPFLAGS,BFL_ENCRYPT);
			break;
		case GD_SetArchiveBit:
			XOR(PRF_BUPFLAGS,BFL_SETABIT);
			break;
		case GD_DuplicateCatalog:
			XOR(PRF_BUPFLAGS,BFL_DUPCATALOG);
			break;
		case GD_IgnoreSkipme:
			XOR(PRF_BUPFLAGS,BFL_IGNSKIPME);
			break;
	}
}
//______________________________________________________________________________

VOID HandleRestore (UWORD gadID,UWORD code)
{
	switch (gadID) {
		case GD_RestoreFrom:
			DEL(PRF_RESFLAGS,RFL_FROMFILE|RFL_FROMTAPE);

			UpdateTagData(GD_RestoreFrom    	   ,GTCY_Active,code);
			UpdateTagData(GD_RestoreArcFile  ,GA_Disabled,DISABLE);
			if (GTV39PLUS) {
				UpdateTagData(GD_RestoreDeviceList       ,GA_Disabled,DISABLE);
				UpdateTagData(GD_RestoreDevices 	 ,GA_Disabled,DISABLE);
			}

			switch (code) {
				case 0: if (GTV39PLUS) {
							UpdateTagData(GD_RestoreDeviceList       ,GA_Disabled,ENABLE);
							UpdateTagData(GD_RestoreDevices 	 ,GA_Disabled,ENABLE);
						}
						break;

				case 1: OR(PRF_RESFLAGS,RFL_FROMFILE);
						UpdateTagData(GD_RestoreArcFile,GA_Disabled,ENABLE);
						break;

				case 2: OR(PRF_RESFLAGS,RFL_FROMTAPE);
						break;
			}

			if (GTV39PLUS) {
				GT_SetGadgetAttrsA(Gads[GD_RestoreDeviceList],Win,NULL,LVDLst);
				GT_SetGadgetAttrsA(Gads[GD_RestoreDevices]       ,Win,NULL,LVDevs);
			}
			GT_SetGadgetAttrsA(Gads[GD_RestoreArcFile],Win,NULL,STArcF);
			break;

		case GD_RestoreDeviceList:
			AddDevsNode(code,TRUE);
			break;

		case GD_RestoreDevices:
			AddDevsNode(code,FALSE);
			break;

		case GD_RestoreArcFile:
			// NOTE: accessibility isn't checked here...
			GDST_COPY(PRF_RESFROM);
			break;
		case GD_RestoreArcFileLoad:
			if (IS_RFL_FROMFILE && LoadFile(PRF_RESFROM,DIRORFILE,MSG_SELECT_RESTORE_SOURCE))
				SetGad(GD_RestoreArcFile,GTST_String,(ULONG)PRF_RESFROM);
			break;

		case GD_RestoreTo:
			ISDIRVALID(PRF_RESTO);
			break;
		case GD_RestoreToLoad:
			if (LoadFile(PRF_RESTO,DIRONLY,MSG_SELECT_RESTORE_DESTINATION))
				SetGad(GD_RestoreTo,GTST_String,(ULONG)PRF_RESTO);
			break;

		case GD_ExistingFiles:
			DEL(PRF_RESFLAGS,RFL_REPLACE|RFL_ASKREPLACE|RFL_OLDREPLACE|RFL_RENAME);

			UpdateTagData(GD_ExistingFiles,GTCY_Active,code);
			switch (code) {
				case 0: OR(PRF_RESFLAGS,RFL_REPLACE);
						break;
				case 2: OR(PRF_RESFLAGS,RFL_ASKREPLACE);
						break;
				case 3: OR(PRF_RESFLAGS,RFL_OLDREPLACE);
						break;
				case 4: OR(PRF_RESFLAGS,RFL_RENAME);
						break;
			}
			break;

		case GD_BadFiles:
			DEL(PRF_RESFLAGS,RFL_DELBAD|RFL_ASKDELBAD);

			UpdateTagData(GD_BadFiles,GTCY_Active,code);
			switch (code) {
				case 0: OR(PRF_RESFLAGS,RFL_DELBAD);
						break;
				case 2: OR(PRF_RESFLAGS,RFL_ASKDELBAD);
						break;
			}
			break;

		case GD_RestoreReport:
			XOR(PRF_RESFLAGS,RFL_REPORT);
			SetGad(GD_RestoreReportTo,      GA_Disabled,NOT IS_RFL_REPORT);
			SetGad(GD_RestoreReportType,GA_Disabled,NOT IS_RFL_REPORT);
			break;
		case GD_RestoreReportTo:
			XOR(PRF_RESFLAGS,RFL_REPTOFILE);
			UpdateTagData(GD_RestoreReportTo,GTCY_Active,IS_RFL_REPTOFILE);
			break;
		case GD_RestoreReportType:
			XOR(PRF_RESFLAGS,RFL_REPSHORT);
			UpdateTagData(GD_RestoreReportType,GTCY_Active,NOT IS_RFL_REPSHORT);
			break;

		case GD_RestoreTree:
			XOR(PRF_RESFLAGS,RFL_DIRTREE);
			break;
		case GD_RestoreDate:
			XOR(PRF_RESFLAGS,RFL_DATE);
			break;
		case GD_RestoreLinks:
			XOR(PRF_RESFLAGS,RFL_LINKS);
			break;
		case GD_RestoreEmptyDirs:
			XOR(PRF_RESFLAGS,RFL_EMPTYDIRS);
			break;
		case GD_UseCatalogFile:
			XOR(PRF_RESFLAGS,RFL_USECATFILE);
			break;
	}
}
//______________________________________________________________________________

VOID HandleVerify (UWORD gadID,UWORD code)
{
	switch (gadID) {
		case GD_VerifyReport:
			XOR(PRF_VERFLAGS,VFL_REPORT);
			SetGad(GD_VerifyReportTo,  GA_Disabled,NOT IS_VFL_REPORT);
			SetGad(GD_VerifyReportType,GA_Disabled,NOT IS_VFL_REPORT);
			break;
		case GD_VerifyReportTo:
			XOR(PRF_VERFLAGS,VFL_REPTOFILE);
			UpdateTagData(GD_VerifyReportTo,GTCY_Active,IS_VFL_REPTOFILE);
			break;
		case GD_VerifyReportType:
			XOR(PRF_VERFLAGS,VFL_REPSHORT);
			UpdateTagData(GD_VerifyReportType,GTCY_Active,NOT IS_VFL_REPSHORT);
			break;

		case GD_CompareData:
			XOR(PRF_VERFLAGS,VFL_COMPARE);
			break;
		case GD_SelectFiles:
			XOR(PRF_VERFLAGS,VFL_SELECTIVE);
			break;
		case GD_IgnoreFilesDate:
			XOR(PRF_VERFLAGS,VFL_IGNOREDATE);
			break;
	}
}
//______________________________________________________________________________

VOID HandleCompress (UWORD gadID,UWORD code)
{
	struct Node     *node;
	UBYTE   filter[FILTERLEN];

	switch (gadID) {
		case GD_CompressMethod:
			DEL(PRF_FLAGS,PFL_EXTERNAL|PFL_XPKLIB);

			UpdateTagData(GD_CompressMethod,GTCY_Active,code);

			if (GTV39PLUS) UpdateTagData(GD_XpkLibs,GA_Disabled,DISABLE);
			UpdateTagData(GD_XpkMode,GA_Disabled,DISABLE);

			switch (code) {
				case 1:
					OR(PRF_FLAGS,PFL_EXTERNAL);
					UpdateTagData(GD_ExternalComp,  GA_Disabled,ENABLE);
					UpdateTagData(GD_ExternalDecomp,GA_Disabled,ENABLE);
					break;

				case 2:
					OR(PRF_FLAGS,PFL_XPKLIB);
					if (GTV39PLUS) UpdateTagData(GD_XpkLibs,GA_Disabled,ENABLE);
					UpdateTagData(GD_XpkMode,GA_Disabled,ENABLE);
				default:
					UpdateTagData(GD_ExternalComp,  GA_Disabled,DISABLE);
					UpdateTagData(GD_ExternalDecomp,GA_Disabled,DISABLE);
					break;
			}
			if (GTV39PLUS) GT_SetGadgetAttrsA(Gads[GD_XpkLibs],Win,NULL,LVXpk);
			GT_SetGadgetAttrsA(Gads[GD_XpkMode      	 ],Win,NULL,SLXMod);
			GT_SetGadgetAttrsA(Gads[GD_ExternalComp  ],Win,NULL,STComp);
			GT_SetGadgetAttrsA(Gads[GD_ExternalDecomp],Win,NULL,STDcmp);
			break;

		case GD_XpkLibs:
			UpdateTagData(GD_XpkLibs,GTLV_Selected,code);
			GetXpkName(code);
			UpdateXpkSL();
			UpdateXpkMode(PRF_XPKMODE,TRUE);
			GT_SetGadgetAttrsA(Gads[GD_XpkMode],Win,NULL,SLXMod);
			break;

		case GD_XpkMode:
			UpdateTagData(GD_XpkMode,GTSL_Level,code);
			UpdateXpkMode(PRF_XPKMODE = code,TRUE);
			break;

		case GD_FilterString:
			GDST_COPY(filter);
			if (filter[0] && strlen(PRF_FILTER)+strlen(filter)+1 < FILTERLEN) {
				SetGad(GD_FilterList,GTLV_Labels,(ULONG)~0);
				if (NOT FindName((struct List *)CmpFilterList,filter)) {
					AddName(CmpFilterList,filter);
					LVCFlt[0].ti_Data = LVCFlt[1].ti_Data = LVCFlt[4].ti_Data = UpdateCmpFilter();
				}
				SetGad(GD_FilterList,GTLV_Labels,(ULONG)((struct List *)CmpFilterList));
			}
			break;
		case GD_FilterList:
			LVCFlt[0].ti_Data = LVCFlt[1].ti_Data = LVCFlt[4].ti_Data = code;
			break;
		case GD_FilterDelete:
			gadID = GD_FilterString;
			GDST_COPY(filter);

			SetGad(GD_FilterList,GTLV_Labels,(ULONG)~0);
			if (node = FindName((struct List *)CmpFilterList,filter)) {
				Remove(node);
				UpdateCmpFilter();
			}
			SetGad(GD_FilterList,GTLV_Labels,(ULONG)((struct List *)CmpFilterList));
			break;

		case GD_ExternalComp:
			GETSTR(PRF_COMP);
			break;
		case GD_ExternalDecomp:
			GETSTR(PRF_DECOMP);
			break;
		case GD_ExternalCompLoad:
			if (IS_EXTERNAL && LOADFILE(PRF_COMP))
				SetGad(GD_ExternalComp,GTST_String,(ULONG)PRF_COMP);
			break;
		case GD_ExternalDecompLoad:
			if (IS_EXTERNAL && LOADFILE(PRF_DECOMP))
				SetGad(GD_ExternalDecomp,GTST_String,(ULONG)PRF_DECOMP);
			break;
	}
}
//______________________________________________________________________________

VOID HandleTape (UWORD gadID,UWORD code)
{
	LONG bsize;

	switch (gadID) {
		case GD_DeviceDriver:
			CheckDiskDevice(gadID);
			CheckSCSIInquiry();
			break;
		case GD_SCSIPort:
			GDIN_COPY(PRF_SCSIPORT);
			CheckSCSIInquiry();
			break;
		case GD_BlockSize:
			GDIN_COPY(bsize);
			if (bsize < 512) {
				DisplayBeep(Scr);
				SetGadgets();
			}
			else PRF_BLOCKSIZE = bsize;
			break;

		case GD_Rewind:
			XOR(PRF_TAPFLAGS,TFL_REWIND);
			break;
		case GD_Eject:
			XOR(PRF_TAPFLAGS,TFL_EJECT);
			break;
		case GD_AutoRetention:
			XOR(PRF_TAPFLAGS,TFL_RETENTION);
			break;
		case GD_FastMemBuffer:
			XOR(PRF_TAPFLAGS,TFL_FASTBUFFER);
			break;

		case GD_SCSIInquiry:
			SCSIInquiry(PRF_DEVICEDRIVER,PRF_SCSIPORT,FALSE);
			break;
	}
}
//______________________________________________________________________________

VOID HandleGUI (UWORD gadID,UWORD code)
{
	ULONG   displayID;

	switch (gadID) {
		case GD_ScreenType:
			DEL(PRF_FLAGS,PFL_CUSTOM|PFL_PUBLIC);

			UpdateTagData(GD_ScreenType,GTCY_Active,code);
			UpdateTagData(GD_PubScreenName,GA_Disabled,DISABLE);

			switch (code) {
				case 1:
					OR(PRF_FLAGS,PFL_CUSTOM);
					displayID = PRF_DISPLAYID;
					break;

				case 2:
					OR(PRF_FLAGS,PFL_PUBLIC);
					UpdateTagData(GD_PubScreenName,GA_Disabled,ENABLE);
				default:
					displayID = CheckPubScreen(code?PRF_PUBNAME:_WBSCRNAME_);
					break;
			}
			GetScreenModeName(displayID);

			GT_SetGadgetAttrsA(Gads[GD_PubScreenName],Win,NULL,STPbSc);
			GT_SetGadgetAttrsA(Gads[GD_ScreenMode   ],Win,NULL,TXSMod);
			break;

		case GD_PubScreenName:
			displayID = CheckPubScreen(GDST_BUF);

			if (displayID == INVALID_ID
				&& Notify(MSG_WARNING,GetStr(MSG_WARN_FIND_PUBSCREEN),MSG_RETRY_CANCEL,&GDST_BUF))
			{
				SetGad(gadID,GTST_String,(ULONG)PRF_PUBNAME);
				ActivateGadget(Gads[GD_PubScreenName],Win,NULL);
			}
			else {
				strcpy(PRF_PUBNAME,GDST_BUF);
				GetScreenModeName(displayID);
				GT_SetGadgetAttrsA(Gads[GD_ScreenMode],Win,NULL,TXSMod);
			}
			break;

		case GD_ScreenModeLoad:
			if (IS_CUSTOM) LoadScreen();
			break;

		case GD_ScrFontName:
			CheckFontName(gadID,PRF_SCREENFONTNAME,PRF_SCREENFONTSIZE);
			break;
		case GD_ScrFontSize:
			CheckFontSize(gadID,PRF_SCREENFONTNAME,&PRF_SCREENFONTSIZE);
			break;
		case GD_ScrFontLoad:
			PRF_SCREENFONTSIZE = LoadFont(TRUE,PRF_SCREENFONTNAME,PRF_SCREENFONTSIZE);
			break;

		case GD_TxtFontName:
			CheckFontName(gadID,PRF_TEXTFONTNAME,PRF_TEXTFONTSIZE);
			break;
		case GD_TxtFontSize:
			CheckFontSize(gadID,PRF_TEXTFONTNAME,&PRF_TEXTFONTSIZE);
			break;
		case GD_TxtFontLoad:
			PRF_TEXTFONTSIZE = LoadFont(FALSE,PRF_TEXTFONTNAME,PRF_TEXTFONTSIZE);
			break;

		case GD_Palette:
			LoadPalette();
			break;
	};
}
//______________________________________________________________________________

VOID HandleExternal (UWORD gadID,UWORD code)
{
	switch (gadID) {
		case GD_ExternalASCII:
			GETSTR(PRF_EXTERNAL[EXT_ASCII]);
			break;
		case GD_ExternalILBM:
			GETSTR(PRF_EXTERNAL[EXT_ILBM]);
			break;
		case GD_ExternalOthers:
			GETSTR(PRF_EXTERNAL[EXT_OTHERS]);
			break;

		case GD_ExternalASCIILoad:
			if (LOADFILE(PRF_EXTERNAL[EXT_ASCII]))
				SetGad(GD_ExternalASCII,GTST_String,(ULONG)PRF_EXTERNAL[EXT_ASCII]);
			break;
		case GD_ExternalILBMLoad:
			if (LOADFILE(PRF_EXTERNAL[EXT_ILBM]))
				SetGad(GD_ExternalILBM,GTST_String,(ULONG)PRF_EXTERNAL[EXT_ILBM]);
			break;
		case GD_ExternalOthersLoad:
			if (LOADFILE(PRF_EXTERNAL[EXT_OTHERS]))
				SetGad(GD_ExternalOthers,GTST_String,(ULONG)PRF_EXTERNAL[EXT_OTHERS]);
			break;

		case GD_ExternalAsynchro:
			XOR(PRF_FLAGS,PFL_VISASYNCHRO);
			break;
		case GD_ExternalConfirm:
			XOR(PRF_FLAGS,PFL_VISCONFIRM);
			break;
	}
}
//______________________________________________________________________________

VOID HandleMisc (UWORD gadID,UWORD code)
{
	switch (gadID) {
		case GD_Alert:
			DEL(PRF_FLAGS,PFL_BEEP|PFL_FLASH);

			switch (code) {
				case 0: OR(PRF_FLAGS,PFL_BEEP);
						break;
				case 1: OR(PRF_FLAGS,PFL_FLASH);
						break;
				case 2: OR(PRF_FLAGS,PFL_BEEP|PFL_FLASH);
						break;
			}
			break;

		case GD_FilesSize:
			DEL(PRF_FLAGS,PFL_BYTES|PFL_KILOBYTES|PFL_MEGABYTES);

			switch (code) {
				case 1: OR(PRF_FLAGS,PFL_BYTES);
						break;
				case 2: OR(PRF_FLAGS,PFL_KILOBYTES);
						break;
				case 3: OR(PRF_FLAGS,PFL_MEGABYTES);
						break;
			}
			break;

		case GD_TempDirectory:
			ISDIRVALID(PRF_TEMPDIR);
			break;
		case GD_TempDirectoryLoad:
			if (LOADDIR(PRF_TEMPDIR))
				SetGad(GD_TempDirectory,GTST_String,(ULONG)PRF_TEMPDIR);
			break;

		case GD_SelectionPath:
			ISDIRVALID(PRF_SELECTPATH);
			break;
		case GD_SelectionPathLoad:
			if (LOADDIR(PRF_SELECTPATH))
				SetGad(GD_SelectionPath,GTST_String,(ULONG)PRF_SELECTPATH);
			break;

		case GD_PrintLabels:
			XOR(PRF_BUPFLAGS,BFL_PRINTLABELS);
			SetGad(GD_LabelsLength,GA_Disabled,NOT IS_BFL_PRINTLABELS);
			break;
		case GD_LabelsLength:
			GDIN_COPY(PRF_LABELSLENGTH);
			break;
	}
}
//______________________________________________________________________________

STATIC VOID
CheckFontName (UWORD gadID,STRPTR oldname,UWORD size)
{
	UBYTE   newname[MAXFONTNAME];

	GDST_COPY(newname);

	if (CheckFont(newname,size)) strcpy(oldname,newname);
	else SetGad(gadID,GTST_String,(ULONG)oldname);
}
//______________________________________________________________________________

STATIC VOID
CheckFontSize (UWORD gadID,STRPTR name,UWORD *oldsize)
{
	UWORD   newsize;

	GDIN_COPY(newsize);

	if (newsize = CheckFont(name,newsize)) *oldsize = newsize;
	else SetGad(gadID,GTIN_Number,(ULONG)*oldsize);
}
//______________________________________________________________________________

STATIC VOID
AddDevsNode (UWORD code,BOOL add)
{
	struct Node     *nn;

	if (NewID == WIN_BACKUP)
		SetGad(GD_BackupDevices ,GTLV_Labels,(ULONG)~0);
	else
		SetGad(GD_RestoreDevices,GTLV_Labels,(ULONG)~0);

	if (nn = FindDevNode(add?AllDevsList:SelDevsList,code)) {
		if (add) {
			if(! FindName((struct List *)SelDevsList,nn->ln_Name))
				AddName(SelDevsList,nn->ln_Name);
		}
		else {
			Remove(nn);
			FreeVec(nn);
		}
	}

	if (NewID == WIN_BACKUP)
		SetGad(GD_BackupDevices ,GTLV_Labels,(ULONG)((struct List *)SelDevsList));
	else
		SetGad(GD_RestoreDevices,GTLV_Labels,(ULONG)((struct List *)SelDevsList));
}


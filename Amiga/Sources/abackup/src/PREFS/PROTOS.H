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
#ifndef ABPREFS_PROTOS_H
#define ABPREFS_PROTOS_H
/*      ___________________

	ABackup Prefs
	protos.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 13-Aug-93
	Modified: 18-Jan-98
	___________________
*/

// sprintf.a:
GLOBAL VOID __stdargs   SPrintf (BYTE *,BYTE *,...);

// bcpl2c.a:
GLOBAL VOID __stdargs   BCPL2C  (BYTE *,BYTE *);

// cleanup.c
GLOBAL VOID     Cleanup 		(VOID);
GLOBAL VOID     CleanupGadgets  (VOID);
GLOBAL VOID     CleanupWindow   (VOID);

// fillclass.c
GLOBAL struct Gadget    *CreateBackfill (struct Gadget *,struct NewGadget,BYTE);

// gadgets.c
GLOBAL VOID     SetGad  		(UBYTE,ULONG,ULONG);
GLOBAL VOID     SetGadgets      	(VOID);
GLOBAL VOID     UpdateGadgets   (VOID);

// getclass.c
GLOBAL Class *  InitGetFileClass	(VOID);
GLOBAL Class *  InitGetDirClass 	(VOID);
GLOBAL Class *  InitGetElseClass	(VOID);

// handle.c
GLOBAL BYTE     HandleMain      	(UWORD,UWORD);
GLOBAL VOID     HandleBackup    (UWORD,UWORD);
GLOBAL VOID     HandleRestore   (UWORD,UWORD);
GLOBAL VOID     HandleVerify    (UWORD,UWORD);
GLOBAL VOID     HandleCompress  (UWORD,UWORD);
GLOBAL VOID     HandleTape      	(UWORD,UWORD);
GLOBAL VOID     HandleGUI       	(UWORD,UWORD);
GLOBAL VOID     HandleExternal  (UWORD,UWORD);
GLOBAL VOID     HandleMisc      	(UWORD,UWORD);

// io.c
GLOBAL BOOL     ParsePrefs      (STRPTR,BOOL,BOOL);

// locale.c
GLOBAL STRPTR   GetStr  		(LONG);
GLOBAL VOID     	ReformatBlock   (VOID);
GLOBAL BOOL     	Shortcut		(UWORD,WORD,BOOL);

// menus.c
GLOBAL VOID     SetupMenus      (VOID);

// requester.c
GLOBAL BOOL     	LoadFile	(STRPTR,BYTE,WORD);
GLOBAL UWORD    LoadFont	(BOOL,STRPTR,UWORD);
GLOBAL VOID     	LoadScreen      (VOID);
GLOBAL VOID     	LoadPalette     (VOID);

// scsi.c
GLOBAL BOOL     SCSIInquiry     		(STRPTR,LONG,BOOL);
GLOBAL VOID     CheckDiskDevice 	(UWORD);
GLOBAL VOID     CheckSCSIInquiry	(VOID);

// setup.c
GLOBAL BOOL     Setup   			(BOOL);
GLOBAL VOID     CopyDefaults    	(VOID);
GLOBAL VOID     CopyPrefs       		(BYTE);
GLOBAL VOID     GetScreenModeName       (ULONG);

// update.c
GLOBAL VOID     	UpdateLabels    	(VOID);
GLOBAL BOOL     	UpdateTagData   	(UBYTE,ULONG,ULONG);
GLOBAL VOID     	UpdateXpkLV     		(VOID);
GLOBAL VOID     	UpdateCmpFilterLV       (VOID);
GLOBAL UWORD    UpdateCmpFilter 	(VOID);

// utility.c
GLOBAL struct Node *    FindDevNode     	(struct MinList *, UWORD);
GLOBAL VOID     	SortDevList     	(struct MinList *, LONG, LONG);
GLOBAL VOID     	StringToList    	(struct MinList *,STRPTR);
GLOBAL UWORD    	ListToString    	(struct MinList *,STRPTR);
GLOBAL BOOL     	AddName 		(struct MinList *,STRPTR);
GLOBAL VOID     	FreeMinList     	(struct MinList *,BOOL);
GLOBAL VOID     	SetCycle		(UWORD,struct TagItem *,UBYTE,BOOL);
GLOBAL BOOL     	Access  		(STRPTR);
GLOBAL VOID     	CheckAccess     	(UWORD,STRPTR,BYTE);
GLOBAL LONG     	CheckPubScreen  (STRPTR);
GLOBAL UWORD    CheckFont       	(STRPTR,UWORD);
GLOBAL LONG     	Notify  		(WORD,STRPTR,WORD,STRPTR *);
GLOBAL VOID     	NotifyError     	(WORD,STRPTR);

// window.c
GLOBAL BOOL     	UpdateWindow    (VOID);
GLOBAL APTR     	SetWinPtr       	(APTR);
GLOBAL VOID     	SetupSizes      	(VOID);
GLOBAL UWORD    ComputeX		(UWORD);
GLOBAL UWORD    ComputeY		(UWORD);
GLOBAL VOID     	Render  		(VOID);

// xpk.h
GLOBAL VOID     SetupXpk		(VOID);
GLOBAL VOID     GetXpkName      	(UWORD);
GLOBAL VOID     UpdateXpkMode   (ULONG,BOOL);
GLOBAL VOID     UpdateXpkSL     	(VOID);

#endif  // ABPREFS_PROTOS_H

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
    main.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 11-Nov-93
    Modified: 15-Mar-98
    _______________________________________________________________________
*/
#ifndef ABACKUP_MAIN_H
#define ABACKUP_MAIN_H

STRPTR	_VERSION_	= "\0$VER: ABackup 5.23 " __AMIGADATE__ ;

STRPTR	_PROGNAME_	= "ABackup";
STRPTR	_PROGVER_	= "v5.23";
STRPTR	_COPYRIGHT_	= "Copyright © 1992-2002 Denis Gounelle" ;

STRPTR	_HELPNAME_	= "abackup.guide" ;
STRPTR	_PREFSFILE_	= "ENV:ABackup.prefs";
STRPTR	_IPC_PORT_NAME_ = "ABackup_IPC_port";

BYTE	OldID = WIN_FIRST,
	NewID = WIN_MAIN;
//__________________________________________________________ minimal stack size:

#ifdef _DEBUG
#	define MYSTACKSIZE	KBYTES(48)
#else
#	define MYSTACKSIZE	KBYTES(12)
#endif

//______________________________________________________________________________

LONG	__stack = MYSTACKSIZE;

UBYTE	CompType;
TEXT	FullName[MAXSTR+1],RootName[MAXSTR+1];

LONG			ProgramFlags	= 0;
LONG			WBufSize	= 0;	// size of child task buffer
BYTE			*WriteBuf	= NULL; // child task buffer
struct List		SelDevsList,
			AllDevsList,
			*Archive	= NULL; // archive units list
struct Object		*DevList	= NULL, // root of partitions list
			*pGRoot 	= NULL,
			*pCurrentDir	= NULL;

struct Header		*pGHdr	= NULL;
struct FileRequester	*pReq	= NULL;

WORD	GPathIndex ;				// index in GPathTable
BYTE	GPathTable[PATHTABLE+1] ;		// global path table
BYTE	PrgAction;				// current action
BYTE	IOBuf[IOBUFSIZE];			// private I/O buffer for newfmt.c/oldfmt.c
BYTE	StartDir[MAXSTR+1] = "RAM:",
		 DestDir[MAXSTR+1];

ABPREFS Prefs;	// current preferences setting

__aligned struct InfoData	GInfo;
__aligned struct OldHeader	OldHdr;
__aligned struct FileInfoBlock	GFib;
__aligned BYTE			GIOBuf[IOBUFSIZE];	// global I/O buffer

//______________________________________________________________________________

TEXT		 NameFilter[MINSTR+1],
		 DateFilter[MINSTR+1],
		 BitsFilter[MINSTR+1];

BOOL		 FirstCall	 = TRUE,
		 DragSelect	 = FALSE,
		 FirstWinAction  = TRUE;
BYTE		 FilterMode	 = FILTER_INCLUDE;
UWORD		 stCode 	 = (UWORD)~0;
ULONG		 stSecs 	 = 0L,
		 stMicros	 = 0L,
		 cuSecs,cuMicros;

STATIC BYTE	 TmpBuf[MAXSTR+1];	 // just an other temporary buffer...

struct TagItem	 SysTLTags[] = {
	{SYS_Input ,NULL},
	{SYS_Output,NULL},
	{SYS_Asynch,TRUE},
	{TAG_DONE}
};

//______________________________________________________________________________

AMIGAGUIDECONTEXT AGHandle = NULL;

STRPTR NAGContext[] = {
	"MainWin" ,
	"LoadTreeWin",
	"InfoWin",
	"SelectionWin",
	"MonitorWin",
	"ArchiveWin",
	NULL
};

#endif	// ABACKUP_MAIN_H

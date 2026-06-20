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
#ifndef ABPREFS_SETUP_H
#define ABPREFS_SETUP_H
/*	___________________

	ABackup Prefs
	setup.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 22-Aug-93
	Modified: 14-Oct-95
	___________________
*/

// for communication whith ABackup
STRPTR _IPC_PORT_NAME_ = "ABackup_IPC_port" ;
struct MsgPort *IPCMsgPort = NULL ;

// global structure declarations:
ABPREFS *Prefs	= NULL,
		*SavPrf = NULL;

struct IntuitionBase	*IntuitionBase	= NULL;
struct GfxBase			*GfxBase		= NULL;
struct LocaleBase		*LocaleBase		= NULL;
struct Library			*AslBase		= NULL,
						*CxBase 		= NULL,
						*DiskfontBase	= NULL,
						*GadToolsBase	= NULL,
						*IconBase		= NULL,
						*IFFParseBase	= NULL,
						*UtilityBase	= NULL,
						*AmigaGuideBase = NULL,
						*WorkbenchBase	= NULL;
struct ReqToolsBase		*ReqToolsBase	= NULL;
struct Catalog			*Catalog		= NULL;
struct Screen			*Scr;
struct MinList			*AllDevsList	= NULL,
						*SelDevsList	= NULL;

STATIC struct TagItem ObjTags[] = {{IA_Height,NULL},{TAG_DONE}};
struct _Object	*GetFileImage	= NULL,
				*GetDirImage	= NULL,
				*GetElseImage	= NULL;

APTR	VInfo  = NULL;
LONG	*RArgs = NULL;
BYTE	Aspect = 1;
BOOL	_EXECFROMABACKUP_ = FALSE;

// statics:
STATIC BYTE	TmpBuf[32];
STATIC UBYTE	ModeInfo[DISPLAYNAMELEN];
STATIC UBYTE	PubScreenName[MAXPUBSCREENNAME+1];
STATIC BYTE		**TType;
STATIC BOOL		UseScreenFont;

STATIC struct TextAttr Attr;

#define DEFHELPPATH "HELP:%s/"
STATIC UBYTE	HelpPath[256] ;

#define CATNAME "abackupprefs.catalog"
STATIC struct TagItem LocaleTags[] = {{OC_Version,38L},{TAG_DONE}};

// maximum size of child task buffer (kBytes):
#define BUFFMAX 2048

// commodity misc.:
CxObj			*Broker   = NULL;
struct MsgPort	*BrokerMP = NULL;

#define BROKERNAME	"ABackupPrefs"
STATIC struct NewBroker NBroker = {
	NB_VERSION,BROKERNAME,NULL,NULL,NBU_UNIQUE|NBU_NOTIFY,COF_SHOW_HIDE,0,0,0
};

STATIC struct NewAmigaGuide NAGuide = {
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	"ABACKUPPREFS_HELP",
	NULL,
	HTF_CACHE_NODE,
	NAGContext,
	NULL,
	NULL,
	NULL,
	NULL
};

#endif	// ABPREFS_SETUP_H

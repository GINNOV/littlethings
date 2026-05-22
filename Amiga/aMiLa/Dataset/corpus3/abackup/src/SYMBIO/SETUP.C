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
    setup.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 03-Oct-93
    Modified: 14-Oct-95
    _______________________________________________________________________
*/
#include "headers.h"
#include "setup.h"

STATIC VOID     SetupLocale     	(VOID);
STATIC BOOL     SetupLibs       	(VOID);
STATIC BOOL     CheckAWPort     	(VOID);
STATIC VOID     CheckValidity   (VOID);
STATIC BOOL     SetupMain       	(VOID);
STATIC VOID     CopyDefaults    (ABPREFS *);
STATIC VOID     TranslateLabels (VOID);
STATIC VOID     SetupNotify     	(VOID);
STATIC VOID     SetupHelp       	(VOID);
STATIC VOID     GetLanguageName (BYTE *);

BOOL
Setup (LONG argc)       // opening libraries, screen, fonts, etc...
{
	BOOL    rc = TRUE;

	SetupLocale();

	if (SetupLibs()) {
		if (CheckAWPort()) {
			CheckValidity();

			if (SetupMain()) {
				SetupAudio();

				EraseAllArgs(TRUE);

				if (argc > 1) rc = ReadCLIArgs();
				else if (NOT argc) rc = ReadWbArgs();

				if (rc) {
					if (NOT Access(ARG_PPATH)) strcpy(ARG_PPATH,DEFPREFSNAME);
					AddPart(ARG_PPATH,_PROGNAME_,MAXSTR);
					if (NOT Access(ARG_HPATH)) {
						GetLanguageName(TmpBuf);
						SPrintf(ARG_HPATH,DEFHELPNAME,TmpBuf);
					}
					AddPart(ARG_HPATH,_HELPNAME_,MAXSTR);

					ReadPrefs(ARG_PREFS,&Prefs,TRUE);

					if (SetupScreen()) {
						if (WorkbenchBase) AWPort = CreatePort(_PROGNAME_,0L);
						if (VInfo = GetVisualInfo(Scr,TAG_END)) {
							BBoxTags[0].ti_Data = (ULONG)VInfo;

							SetupOffset();
							SetupMenus();

							TranslateLabels();

							SetGadgetsSize();
							SetRequestSize();
							PrepareBitRequest();

							SetupChildTask();
							SetupNotify();
							SetupHelp();

							return TRUE;
						}
						else Warning(MSG_WARN_GET_VISUALINFO);
					}
				}
			}
			else Warning(MSG_WARN_OPEN_RESOURCES);
		}
		else Warning(MSG_WARN_ALREADY_RUNNING);
	}
	return FALSE;
}
//______________________________________________________________________________

__inline STATIC VOID
SetupLocale()
{
	if (LocaleBase = (struct LocaleBase *)OpenLibrary("locale.library",38L)) {
		Catalog = OpenCatalogA(NULL,CATNAME,LocaleTags);
		ReformatBlock();
	}
}
//______________________________________________________________________________

__inline STATIC BOOL
SetupLibs()
{
	UBYTE   msg[81];

	if (IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library",NULL))
	{
		if (IntuitionBase->LibNode.lib_Version >= MINLIBVER) {
			if ((GfxBase    	= (struct GfxBase *)OpenLibrary("graphics.library",MINLIBVER))
			 && (GadToolsBase       = OpenLibrary("gadtools.library",MINLIBVER))
			 && (UtilityBase	= OpenLibrary("utility.library",MINLIBVER))
			 && (IconBase   	= OpenLibrary("icon.library",MINLIBVER)))
			{
				AslBase 		= OpenLibrary("asl.library",MINLIBVER);
				DiskfontBase    = OpenLibrary("diskfont.library",MINLIBVER);
				IFFParseBase    = OpenLibrary("iffparse.library",MINLIBVER);
				WorkbenchBase   = OpenLibrary("workbench.library",MINLIBVER);
				XpkBase 		= OpenLibrary("xpkmaster.library",2L);
				muBase  		= (struct muBase *)OpenLibrary("multiuser.library",39L);
				return TRUE;
			}
		}
		else {
			msg[0] = '\0';
			SPrintf(&msg[1],"\x08\x0B%.77s\x00\x00",GetStr(MSG_ALERT_KICK_V37PLUS));
			DisplayAlert(RECOVERY_ALERT,msg,19);
		}
	}
	return FALSE;
}
//______________________________________________________________________________

__inline STATIC BOOL
CheckAWPort()
{
	struct MsgPort  *port;

	Forbid();
	port = FindPort(_PROGNAME_);
	Permit();

	return((BOOL)(NOT port));
}
//______________________________________________________________________________

__inline STATIC VOID
CheckValidity()
{
#ifdef _DEBUG
	Printf("Header   : size %3lD, version at %3lD\n",sizeof(struct Header)   ,offsetof(struct Header,h_Version));
	Printf("BadCyl   : size %3lD, version at %3lD\n",sizeof(struct BadCylMap),offsetof(struct BadCylMap,bcm_Version));
	Printf("OldHeader: size %3lD, version at %3lD\n",sizeof(struct OldHeader),offsetof(struct OldHeader,th_version));
#endif

	// verify structures integrity:
	assert(sizeof(struct Header) <= MAXDATA);
	assert(offsetof(struct Header,h_Version) == VERSIONOFS);
	assert(sizeof(struct BadCylMap) <= MAXDATA);
	assert(offsetof(struct BadCylMap,bcm_Version) == VERSIONOFS);
	assert(sizeof(struct OldHeader) == TD_SECTOR);
	assert(offsetof(struct OldHeader,th_version) == VERSIONOFS);
	assert(sizeof(struct ArcInfo) <= sizeof(struct DeviceDef)+MINSTR);
}
//______________________________________________________________________________

STATIC BOOL
SetupMain()

/* $DOC
 * FUNCTION
 *      Performs all initializations for the program (except for the GUI)
 * OUTPUTS
 *      Result = FALSE if some required resources couldn't be opened
 *      	IN THIS CASE, THE PROGRAM MUST BE TERMINATED !!
 * SEE ALSO
 *      CleanupMain()
 * $END
 */

{
	GLOBAL VOID     XpkGetMethodList (VOID);

	// tries to allocate a memory pool
	if (SysBase->LibNode.lib_Version >= 39L)
		MemPool = CreatePool(POOL_MEMFLAGS,POOL_PUDDLESIZE,POOL_TRESHSIZE);
#ifdef _DEBUG
	if ( MemPool ) Printf("Using V39 memory pool (MemPool at %lx)\n",MemPool);
#endif

	// allocate a header structure:
	if (pGHdr = AllocObject(ABO_HEADER,NULL)) {
		// loads list of all partitions:
		if (DevList = LoadDevList()) {
			// allocate an ASL file requester:
			pReq = (struct FileRequester *)AllocAslRequest(ASL_FileRequest,NULL);
			if (pReq) {
				// get a list of all available XPK methods:
				if (XpkBase) XpkGetMethodList();
				return TRUE;
			}
		}
	}
	return FALSE;
}
//______________________________________________________________________________

STATIC VOID
CopyDefaults (ABPREFS *prefs)
{
	strcpy(prefs->ab_TempDir		,DEF_TEMPDIR    );
	strcpy(prefs->ab_SelectionPath  ,DEF_SELECTPATH );
	strcpy(prefs->ab_External[0]    ,DEF_V39_ASCII  );
	strcpy(prefs->ab_External[1]    ,DEF_V39_ILBM   );
	strcpy(prefs->ab_External[2]    ,DEF_OTHERS     	);
	strcpy(prefs->ab_BackupTo       	,DEF_BUPTO      	);
	strcpy(prefs->ab_RestoreFrom    ,DEF_RESFROM    );
	strcpy(prefs->ab_RestoreTo      	,DEF_RESTO      	);
	strcpy(prefs->ab_XpkMethod      	,DEF_XPKMETHOD  );
	strcpy(prefs->ab_Compressor     	,DEF_COMP       	);
	strcpy(prefs->ab_Decompressor   ,DEF_DECOMP     	);
	strcpy(prefs->ab_Filter 		,DEF_FILTER     	);

	prefs->ab_Flags 		= DEF_FLAGS;
	prefs->ab_BufferSize    = DEF_BUFSIZE;
	prefs->ab_BackupFlags   = DEF_BUPFLAGS;
	prefs->ab_RestoreFlags  = DEF_RESFLAGS;
	prefs->ab_VerifyFlags   = DEF_VERFLAGS;
	prefs->ab_XpkMode       	= DEF_XPKMODE;
}
//______________________________________________________________________________

__inline STATIC BOOL
LoadPrefs(struct IFFHandle *iff,ABPREFS *prefs,BOOL gui)
{
	struct ContextNode *p;
	LONG k, num, result;

	/*
	 * declares all data chunks
	 * NOTE: the ID_PRHD chunk is currently ignored
	 */

	for ( k = 0 ; ChunkTable[k].cd_ID ; k++ )
		if ( StopChunk(iff,ID_PREF,ChunkTable[k].cd_ID) ) return FALSE;

	// read loop
	for (num = 0 ; NOT (result = ParseIFF(iff,IFFPARSE_SCAN)) ; num++ ) {
		p = CurrentChunk(iff);
		if ( (p->cn_ID == ID_GUIP) && (NOT gui) ) continue ;

		// searches the current chunk in the table
		for ( k = 0 ; ChunkTable[k].cd_ID ; k++ )
			if ( ChunkTable[k].cd_ID == p->cn_ID ) break;

		// found: reads chunk data
		if ( ChunkTable[k].cd_ID == p->cn_ID ) {
			if (ReadChunkBytes(iff,(BYTE *)prefs+ChunkTable[k].cd_Start,ChunkTable[k].cd_Length) != ChunkTable[k].cd_Length)
				return FALSE;
		}
		else return FALSE;
	}

	if ( (result == IFFERR_EOF) && (num == 7) ) return TRUE;
	return FALSE;
}

//______________________________________________________________________________

BOOL
ReadPrefs (STRPTR name,ABPREFS *prefs,BOOL gui)
{
	struct IFFHandle	*iff;
	BOOL    rc = FALSE;

	if ( (NOT name) || (NOT Access(name)) ) name = _PREFSFILE_;

	if (IFFParseBase) {
		if (iff = AllocIFF()) {
			if (iff->iff_Stream = Open(name,MODE_OLDFILE)) {
				InitIFFasDOS(iff);
				if (NOT OpenIFF(iff,IFFF_READ)) {
					rc = LoadPrefs(iff,prefs,gui);
					if (IS_BFL_TOTAPE)   strcpy(PRF_BUPTO  ,"TAPE:");
					if (IS_RFL_FROMTAPE) strcpy(PRF_RESFROM,"TAPE:");
					CloseIFF(iff);
				}
				Close(iff->iff_Stream);
			}
			FreeIFF(iff);
		}
	}
	else Warning(MSG_WARN_OPEN_IFFPARSE);

	if (rc == FALSE) CopyDefaults(prefs);

	return(rc);
}
//______________________________________________________________________________

__inline STATIC VOID
TranslateLabels()
{
	UBYTE   n;

	// set selection filter cycle gadget labels:
	for (n = 0; Filter[n] != NULL; n++) Filter[n] = GetStr((LONG)Filter[n]);
}
//______________________________________________________________________________

__inline STATIC VOID
SetupNotify()
{
	if (NotReq = MyAllocMem(sizeof(struct NotifyRequest),NULL)) {
		NotSig = AllocSignal(-1);
		if (NotSig != -1L) {
			NotReq->nr_Name  = _PREFSFILE_;
			NotReq->nr_Flags = NRF_SEND_SIGNAL;
			NotReq->nr_stuff.nr_Signal.nr_Task = (struct Task *)FindTask(NULL);
			NotReq->nr_stuff.nr_Signal.nr_SignalNum = NotSig;

			StartNotify(NotReq);
		}
	}
}
//______________________________________________________________________________

__inline STATIC VOID
SetupHelp()
{
	if (AmigaGuideBase = OpenLibrary("amigaguide.library",MINLIBVER)) {
		NAGuide.nag_Name	= ARG_HPATH ;
		NAGuide.nag_BaseName    = _PROGNAME_;
		NAGuide.nag_Screen      = Scr;

		if (AGHandle = OpenAmigaGuideAsyncA(&NAGuide,TAG_END))
			SetAmigaGuideContext(AGHandle,NULL,NULL);
		else HandleError(NAGuide.nag_Name,HERR_IOERR);
	}
}

//______________________________________________________________________________

__inline STATIC VOID
GetLanguageName(BYTE *p)
{
  struct Locale *ploc ;

  ploc = NULL;
  if (LocaleBase && (ploc = OpenLocale(NULL))) {
	strcpy(p,ploc->loc_LanguageName);
	if (p = strchr(p,'.')) *p = '\0';
	CloseLocale(ploc);
  }
  else strcpy(p,"english");
}

// Tab size: 4

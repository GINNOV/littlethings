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
	setup.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 22-Aug-93
	Modified: 14-Oct-95
	___________________
*/

#include "headers.h"
#include "template.h"
#include "setup.h"

STATIC BOOL	SetupCx 		(VOID);
STATIC BOOL	ReadCLIArgs		(VOID);
STATIC BOOL	ReadToolTypes	(VOID);
STATIC BOOL	SetupPrefs		(VOID);
STATIC VOID	SetupDevs		(VOID);
STATIC VOID	SetupOffset		(VOID);
STATIC VOID	SetupFont		(VOID);
STATIC VOID	ComputeFont		(VOID);
STATIC VOID	SetupRequesters (VOID);
STATIC VOID	SetupBoopsi		(VOID);
STATIC VOID	GetPixelsAspect (VOID);
STATIC VOID	SetupHelp	(VOID);
STATIC VOID	GetLanguageName (BYTE *);

//______________________________________________________________________________

// opening libraries, locking screen, opening system font, etc...
BOOL
Setup (BOOL fromCLI)
{
	if ((IntuitionBase      = (struct IntuitionBase *)OpenLibrary("intuition.library",37L))
	 && (GfxBase            = (struct GfxBase *)OpenLibrary(GRAPHICSNAME,37L))
	 && (GadToolsBase       = OpenLibrary("gadtools.library",37L))
	 && (UtilityBase        = OpenLibrary("utility.library",37L))
	 && (IconBase           = OpenLibrary(ICONNAME,37L))
	 && (WorkbenchBase      = OpenLibrary(WORKBENCH_NAME,37L)))
	{
		LocaleBase = (struct LocaleBase *)OpenLibrary("locale.library",38L);
		if (LocaleBase) {
			Catalog = OpenCatalogA(NULL,CATNAME,LocaleTags);
			ReformatBlock();
		}

		if (IFFParseBase = OpenLibrary("iffparse.library",NULL)) {
			strcpy(PubScreenName,_WBSCRNAME_);
			GetLanguageName(TmpBuf);
			SPrintf(HelpPath,DEFHELPPATH,TmpBuf);

			if (fromCLI && ReadCLIArgs() || NOT fromCLI && ReadToolTypes()) {
				AddPart(HelpPath,_HELPNAME_,256);

				// let's be a commodity:
				if (NOT SetupCx()) return FALSE;

				IPCMsgPort = CreatePort( _IPC_PORT_NAME_ , 0 ) ;

				// the libraries below are optional:
				AslBase 	  = OpenLibrary(AslName,36L);
				DiskfontBase  = OpenLibrary("diskfont.library",37L);
				ReqToolsBase  = (struct ReqToolsBase *)OpenLibrary("reqtools.library",38L);

				if (Scr = LockPubScreen(PubScreenName)) {
					UnlockPubScreen(NULL,Scr);
					if (VInfo = GetVisualInfo(Scr,TAG_END)) {
						if (SetupPrefs()) {
							ULONG	totalmem;

							totalmem = AvailMem(MEMF_TOTAL)/1024L+1L;
							SLBuff[1].ti_Data = MIN(BUFFMAX,totalmem);

							GetPixelsAspect();

							GFBoxTags[1].ti_Data =
							BBoxTags[0].ti_Data	 = (ULONG)VInfo;

							SetupXpk();
							SetupDevs();

							UpdateLabels();
							UpdateGadgets();

							SetupOffset();
							SetupFont();
							SetupMenus();
							SetupRequesters();
							SetupBoopsi();
							SetupSizes();
							SetupHelp();

							return TRUE;
						}
					}
				}
				else WARNING(MSG_WARN_LOCK_PUBSCREEN);
			}
		}
		else WARNING(MSG_WARN_OPEN_IFFPARSE);
	}
	return FALSE;
}
//______________________________________________________________________________

__inline STATIC BOOL
ReadCLIArgs()
{
	BOOL	rc = FALSE;

	if (RArgs = AllocVec(sizeof(LONG)*OPT_COUNT,MEMF_CLEAR)) {
		struct RDArgs	*rdargs;

		if (rdargs = ReadArgs(TEMPLATE,RArgs,NULL)) {
			if (NOT RArgs[OPT_EDIT] && (RArgs[OPT_USE] || RArgs[OPT_SAVE])) {
				if (SetupPrefs()) {
					if (RArgs[OPT_USE])     WRITE_ENV;
					else				WRITE_ENVARC;
				}
			}
			else {
				UseScreenFont = (BOOL)RArgs[OPT_SCREENFONT];

				if (RArgs[OPT_PUBSCREEN])
					strcpy(PubScreenName,(STRPTR)RArgs[OPT_PUBSCREEN]);

				_EXECFROMABACKUP_ = NOT Stricmp(PubScreenName,"ABackup");

				if (RArgs[OPT_WINDOW]) NewID = *(LONG *)RArgs[OPT_WINDOW];
				if (NewID < 0 || NewID >= WIN_COUNT) NewID = WIN_MAIN;

				rc = TRUE;
			}
			FreeArgs(rdargs);
		}
		else PrintFault(IoErr(),NULL);
	}
	return(rc);
}
//______________________________________________________________________________

__inline STATIC BOOL
ReadToolTypes()
{
	BOOL	rc = FALSE;

	if (*_WBenchMsg->sm_ArgList->wa_Name) {
		struct DiskObject	*diskobj;

		if (diskobj = GetDiskObjectNew(_WBenchMsg->sm_ArgList->wa_Name)) {
			TType = diskobj->do_ToolTypes;

			if (FindToolType(TType,TT_SAVE)) {
				if (SetupPrefs()) WRITE_ENVARC;
			}
			else if (FindToolType(TType,TT_USE)) {
				if (SetupPrefs()) WRITE_ENV;
			}
			else {
				BYTE	*s;

				if (s = FindToolType(TType,TT_CREATEICONS)) AddIcon = MatchToolValue(s,TT_YES);
				if (s = FindToolType(TType,TT_PUBSCREEN)) strcpy(PubScreenName,s);
				if (s = FindToolType(TType,TT_HELPPATH)) strcpy(HelpPath,s);

				UseScreenFont = (BOOL)FindToolType(TType,TT_SCREENFONT);

				NBroker.nb_Pri = (BYTE)FindToolType(TType,TT_CXPRIORITY);

				rc = TRUE;
			}
			FreeDiskObject(diskobj);
		}
	}
	return(rc);
}
//______________________________________________________________________________

__inline STATIC BOOL
SetupCx()
{
	if (CxBase = OpenLibrary("commodities.library",36L)) {
		if (BrokerMP = CreateMsgPort()) {
			LONG	error;

			NBroker.nb_Title = GetStr(MSG_CX_TITLE);
			NBroker.nb_Descr = GetStr(MSG_CX_DESCR);
			NBroker.nb_Port  = BrokerMP;

			Broker = CxBroker(&NBroker,&error);

			if (error != CBERR_OK) return FALSE;
		}
	}
	return TRUE;
}
//______________________________________________________________________________

STATIC BOOL
SetupPrefs()
{
	if ((Prefs      = AllocVec(sizeof(ABPREFS),MEMF_CLEAR))
	 && (SavPrf     = AllocVec(sizeof(ABPREFS),NULL)))
	{
		STRPTR	name;

		name = (RArgs && RArgs[OPT_FROM])? (STRPTR)RArgs[OPT_FROM]: _ENVNAME_;
		if (NOT Access(name) || NOT READPREFS(name)) CopyDefaults();
		CopyPrefs(SAVE);
		return TRUE;
	}
	else WARNING(MSG_WARN_MEMORY);
	return FALSE;
}
//______________________________________________________________________________

VOID
CopyDefaults()
{
	UBYTE	c;

	strcpy(PRF_TEMPDIR              ,DEF_TEMPDIR            );
	strcpy(PRF_SELECTPATH   ,DEF_SELECTPATH         );
	strcpy(PRF_EXTERNAL[2]  ,DEF_OTHERS                     );
	strcpy(PRF_BUPTO                ,DEF_BUPTO                      );
	strcpy(PRF_LOGFILE              ,DEF_LOGFILE            );
	strcpy(PRF_DEFCOMMENT   ,DEF_DEFCOMMENT         );
	strcpy(PRF_RESFROM              ,DEF_RESFROM            );
	strcpy(PRF_RESTO                ,DEF_RESTO                      );
	strcpy(PRF_XPKMETHOD    ,DEF_XPKMETHOD          );
	strcpy(PRF_COMP                 ,DEF_COMP                       );
	strcpy(PRF_DECOMP               ,DEF_DECOMP                     );
	strcpy(PRF_FILTER               ,DEF_FILTER                     );
	strcpy(PRF_DEVICEDRIVER ,DEF_DEVICEDRIVER       );

	if (GFXV39PLUS) {
		strcpy(PRF_EXTERNAL[0],DEF_V39_ASCII);
		strcpy(PRF_EXTERNAL[1],DEF_V39_ILBM     );
	}
	else {
		strcpy(PRF_EXTERNAL[0],DEF_V36_ASCII);
		strcpy(PRF_EXTERNAL[1],DEF_V36_ILBM     );
	}

	PRF_FLAGS		 = DEF_FLAGS;
	PRF_BUFSIZE		 = DEF_BUFSIZE;
	PRF_BUPFLAGS	 = DEF_BUPFLAGS;
	PRF_RESFLAGS	 = DEF_RESFLAGS;
	PRF_VERFLAGS	 = DEF_VERFLAGS;
	PRF_LABELSLENGTH = DEF_LABELSLENGTH;
	PRF_XPKMODE		 = DEF_XPKMODE;
	PRF_DISPLAYID	 = GetVPModeID(&(Scr->ViewPort));

	GetDefaultPubScreen(PRF_PUBNAME);
	for (c = 0; c < 4; c++) PRF_COLORS[c] = GetRGB4(Scr->ViewPort.ColorMap,c);

	// reading system font name and size:
	Forbid();
	strcpy(PRF_SCREENFONTNAME,Scr->RastPort.Font->tf_Message.mn_Node.ln_Name);
	strcpy(PRF_TEXTFONTNAME,GfxBase->DefaultFont->tf_Message.mn_Node.ln_Name);

	PRF_SCREENFONTSIZE	= Scr->RastPort.Font->tf_YSize;
	PRF_TEXTFONTSIZE	= GfxBase->DefaultFont->tf_YSize;
	Permit();

	// tape options:
	PRF_TAPFLAGS	= DEF_TAPFLAGS;
	PRF_SCSIPORT	= DEF_SCSIPORT;
	PRF_BLOCKSIZE	= DEF_BLOCKSIZE;
}
//______________________________________________________________________________

VOID
CopyPrefs (BYTE type)
{
	if (type == SAVE) CopyMem(Prefs,SavPrf,sizeof(ABPREFS));
	else			  CopyMem(SavPrf,Prefs,sizeof(ABPREFS));
}

//______________________________________________________________________________

__inline STATIC VOID
SetupDevs()
{
	struct DevInfo	*dvi;
	ULONG	flags = LDF_DEVICES|LDF_WRITE;
	UBYTE	name[128];
	WORD	n;

	if ((AllDevsList = AllocVec(sizeof(struct MinList),NULL))
	 && (SelDevsList = AllocVec(sizeof(struct MinList),NULL)))
	{
		NewList((struct List *)AllDevsList);
		NewList((struct List *)SelDevsList);

		// fill AllDevsList with remaining disk devices:
		n = 0;
		dvi = (struct DevInfo *)LockDosList(flags);
		while (dvi = (struct DevInfo *)NextDosEntry((struct DosList *)dvi,flags)) {
			if (dvi->dvi_Startup & 0x0ffffff0) {
				BCPL2C((STRPTR)(dvi->dvi_Name<<2),name);
				strcat(name,":");
				if (AddName(AllDevsList,name)) n++ ;
			}
		}
		UnLockDosList(flags);
		if (n > 1) SortDevList(AllDevsList,0,n-1);

		LVDLst[1].ti_Data = (ULONG)((struct List *)AllDevsList);
		LVDevs[1].ti_Data = (ULONG)((struct List *)SelDevsList);
	}
	else WARNING(MSG_WARN_MEMORY);
}
//______________________________________________________________________________

VOID
GetScreenModeName (ULONG ID)
{
	struct NameInfo ninfo;

	if (ID != INVALID_ID
		&& GetDisplayInfoData(NULL,(STRPTR)&ninfo,sizeof(ninfo),DTAG_NAME,ID))
	{
		strcpy(ModeInfo,ninfo.Name);
		TXSMod[0].ti_Data = (ULONG)ModeInfo;
	}
	else TXSMod[0].ti_Data = (ULONG)GetStr(MSG_WARN_INEFFECTIVE);
}
//______________________________________________________________________________

__inline STATIC VOID
SetupOffset()
{
	Offset.MinX = Scr->WBorLeft;
	Offset.MinY = Scr->WBorTop+Scr->RastPort.TxHeight+1;
	Offset.MaxX = Offset.MinX+Scr->WBorRight;
	Offset.MaxY = Offset.MinY+Scr->WBorBottom;
}
//_____________________________________________________________________________

__inline STATIC VOID
SetupFont()
{
	struct TextFont *tf;

	Font = &Attr;
	Forbid();
	tf = UseScreenFont?	Scr->RastPort.Font: GfxBase->DefaultFont;

	Font->ta_Name  = (STRPTR)tf->tf_Message.mn_Node.ln_Name;
	Font->ta_YSize = FontY = tf->tf_YSize;
					 FontX = tf->tf_XSize;
	Permit();

	ComputeFont();
}
//______________________________________________________________________________

__inline STATIC VOID
ComputeFont()
{
	UWORD	width = MWin[WIN_WIDEST].mw_Width,
			dx = ComputeX(width),
			dy = ComputeY(MWin[WIN_TALLEST].mw_Height);

	if (dx+Offset.MaxX > Scr->Width || dy+Offset.MaxY > Scr->Height) {
		Font->ta_Name = (STRPTR)"topaz.font";
		FontX = FontY = Font->ta_YSize = 8;
	}
	else if (dx < width) FontX = 8;
}
//______________________________________________________________________________

__inline STATIC VOID
SetupRequesters()
{
	// requesters font:
	ASLFRTags[2].ti_Data = ASLFOTags[2].ti_Data = ASLSMTags[2].ti_Data = (ULONG)Font;

	// requesters labels:
	ASLFOTags[3].ti_Data = (ULONG)GetStr(MSG_SELECT_FONT);
	ASLSMTags[3].ti_Data = (ULONG)GetStr(MSG_SELECT_SCREEN_MODE);
}
//______________________________________________________________________________

__inline STATIC VOID
SetupBoopsi()
{
	GetFileClass = InitGetFileClass();
	GetDirClass  = InitGetDirClass();
	GetElseClass = InitGetElseClass();

	ObjTags[0].ti_Data = FontY+6;	// Getxx gadgets height

	GetFileImage = NewObjectA(GetFileClass,NULL,ObjTags);
	GetDirImage  = NewObjectA(GetDirClass, NULL,ObjTags);
	GetElseImage = NewObjectA(GetElseClass,NULL,ObjTags);
}
//_____________________________________________________________________________

__inline STATIC VOID
GetPixelsAspect()
{
	struct DisplayInfo	dspinfo;

	if (GetDisplayInfoData(FindDisplayInfo(GetVPModeID(&(Scr->ViewPort))),(STRPTR)&dspinfo,sizeof(dspinfo),DTAG_DISP,NULL))
		if (dspinfo.Resolution.y/dspinfo.Resolution.x == 1) Aspect = 2;
}

//______________________________________________________________________________

__inline STATIC VOID
SetupHelp()
{
	if (AmigaGuideBase = OpenLibrary("amigaguide.library",37L)) {
		NAGuide.nag_Name	= HelpPath;
		NAGuide.nag_BaseName	= "abackupprefs";
		NAGuide.nag_Screen	= Scr;

		if (AGHandle = OpenAmigaGuideAsyncA(&NAGuide,TAG_END))
			SetAmigaGuideContext(AGHandle,NULL,NULL);
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

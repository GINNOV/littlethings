/*
**	$VER: Main.c 4.0 (8.6.95) Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	This source code is provided "AS-IS" without warranties of any kind and
**	is subject to change without notice.
**	All use is at your own risk.  No liability or responsibility is assumed.
**
**	Use 4 chars wide TABs to read this source
**	Compile me with SAS/C V6.51 or better
*/

#include <exec/execbase.h>
#include <exec/lists.h>
#include <dos/dos.h>
#include <dos/dostags.h>
#include <libraries/gadtools.h>
#include <clib/utility_protos.h>

#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/icon_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/icon_pragmas.h>
#include <pragmas/utility_pragmas.h>


#include "XModule.h"
#include "Gui.h"



/* Local functions prototypes */

static LONG GetShellArgs (void);
static LONG GetWBArgs (void);
static void DisposeArgs (void);
static void HandleFrom (void);
static void Cleanup (LONG err);
static LONG Setup (void);



/* This structure holds data to open required libraries automatically. */

struct OpenLibs
{
	struct Library **Base;
	UBYTE *Name;
	LONG Version;
};

static const struct OpenLibs openlibs[] =
{
	{ (struct Library **)&IntuitionBase,	"intuition.library",	37L },
	{ (struct Library **)&GfxBase,			"graphics.library",		37L },
	{ (struct Library **)&LayersBase,		"layers.library",		37L },
	{ (struct Library **)&UtilityBase,		"utility.library",		37L },
	{ (struct Library **)&GadToolsBase,		"gadtools.library",		37L },
	{ (struct Library **)&KeymapBase,		"keymap.library",		37L },
	{ (struct Library **)&IFFParseBase,		"iffparse.library",		37L },
	{ (struct Library **)&WorkbenchBase,	"workbench.library",	37L },
	{ (struct Library **)&IconBase,			"icon.library",			37L },
	{ (struct Library **)&DiskfontBase,		"diskfont.library",		36L },

	NULL
};



/* Used for argument parsing.
 * NOTE: All fields must be 4 bytes long.
 */

static struct
{
	STRPTR	*From,
			 PubScreen,
			 PortName,
			 Settings;
	LONG	 CxPopup;		/* Set to TRUE by default. */
	STRPTR	 CxPopKey;
	LONG	*CxPriority,
			*IconX,
			*IconY;
	STRPTR	 IconName;
} XMArgs = { 0 };


static struct RDArgs *RDArgs = NULL;

#define ARGS_TEMPLATE	"FROM/M,PUBSCREEN/K,PORTNAME/K,SETTINGS/K,CX_POPUP/T,CX_POPKEY/K,CX_PRIORITY/K/N,ICONXPOS/K/N,ICONYPOS/K/N,ICONNAME/K"




LONG __stdargs __main (void)

/* XModule main entry point.  Get arguments from CLI/Workbench,
 * setup environment, open required files and call main event
 * handling loop.
 */
{
	LONG err;

	if (!(err = Setup())) /* Setup environment */
		err = HandleGui();

	Cleanup (err);

	return err;
}	/* End main() */



static LONG GetShellArgs (void)

/* Parse command line arguments */
{
	if (!(RDArgs = ReadArgs (ARGS_TEMPLATE, (LONG *)&XMArgs, NULL)))
		return IoErr();

	return RETURN_OK;

} /* End GetShellArgs() */



static LONG GetWBArgs (void)

/* Parse Workbench arguments */
{
	struct DiskObject *dobj;
	STRPTR val;
	UWORD i;


	/* Get Multiselect args.
	 * Create a NULL-terminated array of STRPTRs
	 * in the same way ReadArgs() would have done.
	 */
	if (WBenchMsg->sm_NumArgs > 1)
		if (!(XMArgs.From = AllocVec (WBenchMsg->sm_NumArgs * sizeof (STRPTR), MEMF_CLEAR)))
			return RETURN_FAIL;

	for (i = 1; i < WBenchMsg->sm_NumArgs; i++)
	{
		UBYTE buf[PATHNAME_MAX];

		if (NameFromLock (WBenchMsg->sm_ArgList[i].wa_Lock, buf, PATHNAME_MAX))
			if (AddPart (buf, WBenchMsg->sm_ArgList[i].wa_Name, PATHNAME_MAX))
			{
				if (XMArgs.From[i-1] = AllocVec (strlen (buf), MEMF_ANY))
					strcpy (XMArgs.From[i-1], buf);
				else break;
			}
	}


	/* Get ToolTypes */

	if (!(dobj = GetProgramIcon()))
		return RETURN_FAIL;

	if (val = FindToolType (dobj->do_ToolTypes, "PUBSCREEN"))
		if (XMArgs.PubScreen = AllocVec (strlen (val), MEMF_ANY))
			strcpy (XMArgs.PubScreen, val);

	if (val = FindToolType (dobj->do_ToolTypes, "PORTNAME"))
		if (XMArgs.PortName = AllocVec (strlen (val), MEMF_ANY))
			strcpy (XMArgs.PortName, val);

	if (val = FindToolType (dobj->do_ToolTypes, "SETTINGS"))
		if (XMArgs.Settings = AllocVec (strlen (val), MEMF_ANY))
			strcpy (XMArgs.Settings, val);

	if (val = FindToolType (dobj->do_ToolTypes, "CX_POPUP"))
		XMArgs.CxPopup = MatchToolValue (val, "YES");

	if (val = FindToolType (dobj->do_ToolTypes, "CX_POPKEY"))
		if (XMArgs.CxPopKey = AllocVec (strlen (val), MEMF_ANY))
			strcpy (XMArgs.CxPopKey, val);

	if (val = FindToolType (dobj->do_ToolTypes, "CX_PRIORITY"))
		if (XMArgs.CxPriority = AllocVec (sizeof (LONG), MEMF_ANY))
			StrToLong (val, XMArgs.CxPriority);

	if (val = FindToolType (dobj->do_ToolTypes, "ICONXPOS"))
		if (XMArgs.IconX = AllocVec (sizeof (LONG), MEMF_ANY))
			StrToLong (val, XMArgs.IconX);

	if (val = FindToolType (dobj->do_ToolTypes, "ICONYPOS"))
		if (XMArgs.IconY = AllocVec (sizeof (LONG), MEMF_ANY))
			StrToLong (val, XMArgs.IconY);

	if (val = FindToolType (dobj->do_ToolTypes, "ICONNAME"))
		if (XMArgs.IconName = AllocVec (strlen (val), MEMF_ANY))
			strcpy (XMArgs.IconName, val);

	FreeDiskObject (dobj);

	return RETURN_OK;
} /* End GetWBArgs() */



static void DisposeArgs (void)
{
	if (RDArgs)
	{
		FreeArgs (RDArgs);
		RDArgs = NULL;
	}
	else	/* Workbench */
	{
		/* NULL is a valid parameter for FreeVec() */
		FreeVec (XMArgs.IconName);
		FreeVec (XMArgs.IconY);
		FreeVec (XMArgs.IconX);
		FreeVec (XMArgs.CxPriority);
		FreeVec (XMArgs.CxPopKey);
		FreeVec (XMArgs.Settings);
		FreeVec (XMArgs.PortName);
		FreeVec (XMArgs.PubScreen);

		if (XMArgs.From)
		{
			STRPTR *tmp = XMArgs.From;

			while (*tmp)
			{
				FreeVec (*tmp);
				tmp++;
			}

			FreeVec (XMArgs.From);
		}
	}

	memset (&XMArgs, 0, sizeof (XMArgs));
}



static void HandleFrom (void)
{
	if (XMArgs.From)
	{
		STRPTR				*name = XMArgs.From;
		struct AnchorPath	*ap;
		struct SongInfo		*si;
		LONG err;

		if (ap = AllocMem (sizeof (struct AnchorPath) + PATHNAME_MAX, MEMF_CLEAR))
		{
			OpenProgressWindow();

			ap->ap_Strlen = PATHNAME_MAX;

			while (*name)
			{
				err = MatchFirst (*name, ap);

				while (!err)
				{
					if (si = LoadModule (NULL, ap->ap_Buf))
						AddSongInfo (si);

					err = MatchNext (ap);
				}

				if (err != ERROR_NO_MORE_ENTRIES)
				{
					UBYTE buf[FAULT_MAX];

					Fault (err, NULL, buf, FAULT_MAX);
					ShowMessage (MSG_ERR_LOAD, *name, buf);
				}

				MatchEnd (ap);
				name++;
			}

			CloseProgressWindow();

			FreeMem (ap, sizeof (struct AnchorPath) + PATHNAME_MAX);
		}
	}
}



static void Cleanup (LONG err)

/* Cleanup routine.  Display error message, free all resources & exit */
{
	UWORD i;

	if (err > 100)
		PrintFault (err, PrgName);

	/* Free all allocated resources */

	CleanupAudio();

	DisposeArgs();

	FreeFReq();
	CloseDownScreen();

	FreeVec (ScreenAttr.ta_Name);
	FreeVec (WindowAttr.ta_Name);
	FreeVec (ListAttr.ta_Name);
	FreeVec (EditorAttr.ta_Name);

	/* Free all songs in SongList */
	{
		struct SongInfo *si;

		while (si = (struct SongInfo *)RemTail (&SongList))
			FreeSongInfo (si);
	}

	/* Remove AppIcons/AppWindows Port */
	CleanupApp();

	/* Remove Commodity Broker */
	CleanupCx();

	/* Remove ARexx port */
	DeleteRexxPort();

	CleanupLocale();

	/* Remove global memory pool */
	if (Pool) LibDeletePool (Pool);

	/* Close all libraries */
	for (i = 0 ; openlibs[i].Base ; i++)
		/* starting with V36, NULL is a valid parameter for CloseLibrary(). */
		CloseLibrary (*(openlibs[i].Base));
}



static LONG Setup (void)
{
	LONG err;
	UWORD i;

	if (SysBase->lib_Version >= 39) Kick30 = TRUE;	/* Find KS version */

	SetProgramName (PrgName);

	/* Initialize view lists */
	NewList (&WindowList);
	NewList	(&SongList);
	NewList (&LogList);
	NewList (&PatternsList);
	NewList (&SequenceList);
	NewList (&InstrList);

	/* Install graphics function replacements */
	InstallGfxFunctions();

	/* Initialize ScrInfo structure */
	strcpy (ScrInfo.PubScreenName, BaseName);

	/* Initialize PubPort name */
	strcpy (PubPortName, BaseName);

	/* Initialize PubPort name */
	strcpy (IconName, PrgName);


	/* Open required libraries */
	for (i = 0 ; openlibs[i].Base ; i++)
		if (!(*(openlibs[i].Base) = MyOpenLibrary (openlibs[i].Name, openlibs[i].Version)))
			return RETURN_FAIL;

	/* Create global memory pool */
	if (!(Pool = LibCreatePool (MEMF_ANY, 16*1024, 4*1024)))
		return ERROR_NO_FREE_STORE;

	if (Kick30)
		UniqueID = GetUniqueID();	/* Get ID for HelpGroup and other jobs */

	/* Get startup arguments */
	XMArgs.CxPopup = TRUE;

	if (WBenchMsg) err = GetWBArgs();
	else err = GetShellArgs();

	if (err) return err;

	SetupLocale();

	/* Try to load XModule preferences */
	if (XMArgs.Settings)
	{
		if (LoadPrefs (XMArgs.Settings))
		{
			UBYTE buf[FAULT_MAX];

			Fault (IoErr(), NULL, buf, FAULT_MAX);
			ShowMessage (MSG_ERR_LOAD, XMArgs.Settings, buf);
		}
	}
	else
	{
		if (LoadPrefs ("PROGDIR:" BASENAME ".prefs"))
			LoadPrefs ("ENV:" BASENAME ".prefs");
	}


	/* Use startup Arguments */

	if (XMArgs.PubScreen)
		strncpy (ScrInfo.PubScreenName, XMArgs.PubScreen, 31);

	if (XMArgs.PortName)
		strncpy (PubPortName, XMArgs.PortName, 15);

	CxPopup = XMArgs.CxPopup;

	if (XMArgs.CxPopKey)
		strncpy (CxPopKey, XMArgs.CxPopKey, 31);

	if (XMArgs.CxPriority)
		CxPri = *XMArgs.CxPriority;

	if (XMArgs.IconX)
		IconX = *XMArgs.IconX;

	if (XMArgs.IconY)
		IconY = *XMArgs.IconY;

	if (XMArgs.IconName)
		strncpy (IconName, XMArgs.IconName, 15);

	/* Setup FileRequesters if LoadPrefs() hasn't already done it */
	if (!AslBase && !ReqToolsBase)
		if (err = SetupRequesters())
			return err;

	/* Setup App Message Port */
	SetupApp();

	/* Setup Rexx Host */
	CreateRexxPort();

	/* Setup Commodity object */
	SetupCx();

	/* Allocate a new SongInfo structure */
	if (!songinfo)
	{
		struct SongInfo *si;

		if (si = NewSong())
			AddSongInfo (si);
		else
			return ERROR_NO_FREE_STORE;
	}

	/* Open screen and ToolBox window */
	if (CxPopup)
		if (err = SetupScreen())
			return err;


	/* Load modules requested with Shell/Workbench startup arguments */

	HandleFrom();

	DisposeArgs();

	return 0;
}

/*
**	Rexx.c
**
**	Copyright (C) 1994,1995 by Bernardo Innocenti
**
**	Routines to handle XModule's ARexx interface
*/

#include <rexx/rxslib.h>
#include <rexx/storage.h>
#include <rexx/errors.h>

#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/utility_protos.h>
#include <clib/rexxsyslib_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/rexxsyslib_pragmas.h>

#include "XModule.h"
#include "Gui.h"



struct RexxCmd
{
	const STRPTR Cmd;
	const STRPTR Template;
	LONG (*Func)(struct RexxMsg *, LONG *);
};


/* Local function prototypes */

static LONG ExecRexxCmd			(struct RexxMsg *msg, struct RexxCmd *cmd, const UBYTE *rexxargs);

static LONG RexxActivate		(struct RexxMsg *msg, LONG *args);
static LONG RexxClear			(struct RexxMsg *msg, LONG *args);
static LONG RexxClose			(struct RexxMsg *msg, LONG *args);
static LONG RexxColumn			(struct RexxMsg *msg, LONG *args);
static LONG RexxCopy			(struct RexxMsg *msg, LONG *args);
static LONG RexxCursor			(struct RexxMsg *msg, LONG *args);
static LONG RexxCut				(struct RexxMsg *msg, LONG *args);
static LONG RexxDeactivate		(struct RexxMsg *msg, LONG *args);
static LONG RexxErase			(struct RexxMsg *msg, LONG *args);
static LONG RexxGotoBookmark	(struct RexxMsg *msg, LONG *args);
static LONG RexxGotoColumn		(struct RexxMsg *msg, LONG *args);
static LONG RexxGotoLine 		(struct RexxMsg *msg, LONG *args);
static LONG RexxGotoColumn		(struct RexxMsg *msg, LONG *args);
static LONG RexxHelp			(struct RexxMsg *msg, LONG *args);
static LONG RexxLine			(struct RexxMsg *msg, LONG *args);
static LONG RexxLockGui			(struct RexxMsg *msg, LONG *args);
static LONG RexxNew				(struct RexxMsg *msg, LONG *args);
static LONG RexxOpen			(struct RexxMsg *msg, LONG *args);
static LONG RexxOptimize		(struct RexxMsg *msg, LONG *args);
static LONG RexxPaste			(struct RexxMsg *msg, LONG *args);
static LONG RexxPrint			(struct RexxMsg *msg, LONG *args);
static LONG RexxQuit			(struct RexxMsg *msg, LONG *args);
static LONG RexxRequestFile		(struct RexxMsg *msg, LONG *args);
static LONG RexxRequestResponse	(struct RexxMsg *msg, LONG *args);
static LONG RexxRequestNotify	(struct RexxMsg *msg, LONG *args);
static LONG RexxSave			(struct RexxMsg *msg, LONG *args);
static LONG RexxScreenToBack	(struct RexxMsg *msg, LONG *args);
static LONG RexxScreenToFront	(struct RexxMsg *msg, LONG *args);
static LONG RexxSetBookmark		(struct RexxMsg *msg, LONG *args);
static LONG RexxShowMessage		(struct RexxMsg *msg, LONG *args);
static LONG RexxUnLockGui		(struct RexxMsg *msg, LONG *args);
static LONG RexxVersion			(struct RexxMsg *msg, LONG *args);


struct Library *RexxSysBase = NULL;

struct MsgPort *PubPort = NULL;
ULONG PubPortSig = 0L;

UBYTE PubPortName[16];	/* ARexx host name */


struct RexxCmd RexxCmds[] =
{
	{ "ACTIVATE",		NULL,				RexxActivate },
	{ "CLEAR",			"FORCE/S",			RexxClear },
	{ "CLOSE",			"FORCE/S",			RexxClose },
	{ "COLUMN",			"/N/A",				RexxColumn },
	{ "COPY",			NULL,				RexxCopy },
	{ "CURSOR",			"UP/S,DOWN/S,LEFT/S,RIGHT/S",	RexxCursor },
	{ "CUT",			NULL,				RexxCut },
	{ "DEACTIVATE",		NULL,				RexxDeactivate },
	{ "ERASE",			"FORCE/S",			RexxErase },
	{ "GOTOBOOKMARK",	NULL,				RexxGotoBookmark },
	{ "GOTOCOLUMN",		"/N/A",				RexxGotoColumn },
	{ "GOTOLINE",		"/N/A",				RexxGotoLine },
	{ "GOTOCOLUMN",		"/N/A",				RexxGotoColumn },
	{ "HELP",			"COMMAND,PROMPT/S",	RexxHelp },
	{ "LINE",			"/N/A",				RexxLine },
	{ "LOCKGUI",		NULL,				RexxLockGui },
	{ "NEW",			"PORTNAME/K",		RexxNew },
	{ "OPEN",			"FILENAME,FORCE/S",	RexxOpen },
	{ "OPTIMIZE",		NULL,				RexxOptimize },
	{ "PASTE",			NULL,				RexxPaste },
	{ "PRINT",			"PROMPT/S",			RexxPrint },
	{ "QUIT",			"FORCE/S",			RexxQuit },
	{ "REQUESTFILE",	"TITLE/K,PATH/K,FILE/K,PATTERN/K", RexxRequestFile },
	{ "REQUESTRESPONSE","TITLE/K,PROMPT/K", RexxRequestResponse },
	{ "REQUESTNOTIFY",	"PROMPT/K",			RexxRequestNotify },
	{ "SAVE",			"NAME",				RexxSave },
	{ "SCREENTOBACK",	NULL,				RexxScreenToBack },
	{ "SCREENTOFRONT",	NULL,				RexxScreenToFront },
	{ "SETBOOKMARK",	NULL,				RexxSetBookmark },
	{ "SHOWMESSAGE",	"MSG/A",			RexxShowMessage },
	{ "UNLOCKGUI",		NULL,				RexxUnLockGui },
	{ "VERSION",		NULL,				RexxVersion },
	{ NULL, NULL, NULL }
};

#define COMMAND_CNT (sizeof (RexxCmds) / sizeof (struct RexxCmd))



/* Arexx command handler */
void HandleRexxMsg (void)
{
	struct RexxMsg *msg;
	struct RexxCmd *CurrentCmd = RexxCmds;

	while (msg = (struct RexxMsg *) GetMsg (PubPort))
	{
		if (IsRexxMsg (msg))
		{
			msg->rm_Result1 = RETURN_FAIL;

			/* Find ARexx Command. TODO: Binary search! */
			while (CurrentCmd->Cmd)
			{
				if (!Strnicmp (CurrentCmd->Cmd, ARG0(msg), strlen (CurrentCmd->Cmd)))
				{
					msg->rm_Result1 = ExecRexxCmd (msg, CurrentCmd,
						ARG0(msg) + strlen (CurrentCmd->Cmd));
					break; /* Exit from loop */
				}
				CurrentCmd++;
			}
		}

		ReplyMsg ((struct Message *)msg);
	}
}



static LONG ExecRexxCmd (struct RexxMsg *msg, struct RexxCmd *cmd, const UBYTE *rexxargs)
{
	struct RDArgs *rdargs;
	UBYTE *argbuf;
	ULONG arglen = strlen (rexxargs) + 1;	/* Space for newline */
	LONG rc = RC_ERROR;
	LONG argarray[12] = { 0L };

	ShowRequesters = FALSE;

	if (!cmd->Template)
		rc = (cmd->Func)(msg, NULL);	/* Call command directly */
	else if (argbuf = AllocVec (arglen, MEMF_ANY))
	{
		/* Copy arguments to temporary buffer.
		 * ReadArgs() also requires a newline.
		 */
		strcpy (argbuf, rexxargs);
		argbuf[arglen-1] = '\n';

		if (rdargs = AllocDosObject (DOS_RDARGS, NULL))
		{
			rdargs->RDA_Source.CS_Buffer = argbuf;
			rdargs->RDA_Source.CS_Length = arglen;
			rdargs->RDA_Flags |= RDAF_NOPROMPT;

			if (ReadArgs ((volatile STRPTR)cmd->Template, argarray, rdargs))
			{
				/* Call Command server */
				rc = (cmd->Func)(msg, argarray);

				FreeArgs (rdargs);
			}
			FreeDosObject (DOS_RDARGS, rdargs);
		}
		FreeVec (argbuf);
	}

	ShowRequesters = TRUE;

	return rc;
}



LONG CreateRexxPort (void)

/* Setup public port for ARexx host */
{
	ULONG i = 0;

	if (!PubPortName[0]) return RETURN_FAIL;

	if (!(RexxSysBase = OpenLibrary (RXSNAME, 36L)))
		return RETURN_FAIL;

	if (!(PubPort = CreateMsgPort ())) return ERROR_NO_FREE_STORE;

	PubPortSig = 1 << PubPort->mp_SigBit;
	Signals |= PubPortSig;

	Forbid();
	while (FindPort (PubPortName))
		SPrintf (PubPortName, "XMODULE.%ld", ++i);

	PubPort->mp_Node.ln_Name = PubPortName;
	PubPort->mp_Node.ln_Pri = 1;
	AddPort (PubPort);
	Permit();

	return RETURN_OK;
}


void DeleteRexxPort (void)
{
	if (PubPort)
	{
		RemPort (PubPort);
		KillMsgPort (PubPort); PubPort = NULL;
	}

	if (RexxSysBase)
		{ CloseLibrary (RexxSysBase); RexxSysBase = NULL; }
}

/************************/
/* Rexx Command servers */
/************************/

static LONG RexxActivate		(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}

static LONG RexxClear			(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}

static LONG RexxClose			(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}

static LONG RexxColumn			(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}

static LONG RexxCopy			(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}

static LONG RexxCursor			(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}

static LONG RexxCut				(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}

static LONG RexxDeactivate		(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}



static LONG RexxErase			(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}



static LONG RexxGotoBookmark	(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}



static LONG RexxGotoColumn		(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}



static LONG RexxGotoLine 		(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}



static LONG RexxHelp			(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}



static LONG RexxLine			(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}



static LONG RexxLockGui		(struct RexxMsg *msg, LONG *args)
{
	LockWindows();

	return RETURN_OK;
}



static LONG RexxNew				(struct RexxMsg *msg, LONG *args)
{
	struct SongInfo *si;

	if (si = NewSong())
	{
		AddSongInfo (si);
		return RETURN_OK;
	}

	return RETURN_FAIL;
}



static LONG RexxOpen (struct RexxMsg *msg, LONG *args)
{
	struct SongInfo *si;

	LockWindows();

	if (args[0])
	{
		if (si = LoadModule (songinfo, (STRPTR)args[0]))
			AddSongInfo (si);
	}
	else
	{
		UBYTE filename[PATHNAME_MAX];

		filename[0] = '\0';

		if (FileRequest (FREQ_LOADMOD, filename))
		{
			if (si = LoadModule (songinfo, filename))
				AddSongInfo(si);
		}
	}

	UnlockWindows();

	return LastErr;
}



static LONG RexxOptimize (struct RexxMsg *msg, LONG *args)
{
	OptPerformClicked ();
	return RETURN_OK;
}



static LONG RexxPaste			(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}



static LONG RexxPrint			(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}



static LONG RexxQuit (struct RexxMsg *msg, LONG *args)
{
	Quit = 1;
	if (args[0]) GuiSwitches.AskExit = FALSE;

	return RETURN_OK;
}



static LONG RexxRequestFile		(struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}



static LONG RexxRequestResponse	(struct RexxMsg *msg, LONG *args)
{
	return ShowRequestStr ((STRPTR)args[0], (STRPTR)args[1], NULL);
}



static LONG RexxRequestNotify	(struct RexxMsg *msg, LONG *args)
{
	ShowRequestStr ((STRPTR)args[0], NULL, NULL);
	return RETURN_OK;
}



static LONG RexxSave (struct RexxMsg *msg, LONG *args)
{
	if (songinfo)
	{
		if (args[0])
			strncpy (songinfo->SongPath, (STRPTR)args[0], PATHNAME_MAX);

		LastErr = SaveModule (songinfo, songinfo->SongPath, SaveSwitches.SaveType);
	}

	return LastErr;
}



static LONG RexxScreenToBack (struct RexxMsg *msg, LONG *args)
{
	if (Scr) ScreenToBack (Scr);

	return RETURN_OK;
}



static LONG RexxScreenToFront (struct RexxMsg *msg, LONG *args)
{
	if (Scr)
	{
		ScreenToFront (Scr);
		if (ThisTask->pr_WindowPtr) ActivateWindow (ThisTask->pr_WindowPtr);
	}

	return RETURN_OK;
}



static LONG RexxSetBookmark (struct RexxMsg *msg, LONG *args)
{
	return RETURN_FAIL;
}



static LONG RexxShowMessage (struct RexxMsg *msg, LONG *args)
{
	ShowString ((STRPTR)args[0], NULL);

	return RETURN_OK;
}



static LONG RexxUnLockGui (struct RexxMsg *msg, LONG *args)
{
	if (WinLockCount)
	{
		UnlockWindows();
		return RETURN_OK;
	}
	return RETURN_FAIL;
}



static LONG RexxVersion (struct RexxMsg *msg, LONG *args)
{
	UBYTE RexxVer[8];

	SPrintf (RexxVer, "%ld.%ld", VERSION, REVISION);

//	SetRexxVar ((struct Message *)msg, "RESULT", RexxVer, strlen (RexxVer));
	msg->rm_Result2=(LONG)CreateArgstring (RexxVer, (LONG)strlen(RexxVer));

	return RETURN_OK;
}

/*
**	ProgressWin.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Parts of this code are:
**
**	Copyright © 1990-1993 by Olaf `Olsen' Barthel & MXM
**		All Rights Reserved
**
**	Report status information for an operation in progress.
*/

#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <libraries/asl.h>

#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/layers_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/layers_pragmas.h>

#include "Gui.h"
#include "XModule.h"



/* Gadgets IDs */
enum
{
	GD_ProgressAbort,
	GD_Percent,
	GD_Action,
	Progress_CNT
};

enum
{
	GD_LogList,
	Log_CNT
};


/* Local functions prototypes */

static void ProgressAbortClicked (void);
static void ShowStats (struct Gadget *Gadget, LONG Value, LONG Max);


struct Gadget	*ProgressGadgets[Progress_CNT];
struct Gadget	*LogGadgets[Log_CNT];
static UWORD	 LogLines = 0;
static UWORD	 ProgressOpenCount = 0;
struct List		 LogList;

static struct IntuiText ProgressIT = { 0 };


UWORD ProgressGTypes[] = {
	BUTTON_KIND,
	TEXT_KIND,
	TEXT_KIND
};

UWORD LogGTypes[] = {
	LISTVIEW_KIND
};


struct NewGadget ProgressNGad[] =
{
	114, 25, 91, 12, (UBYTE *)"_Abort", NULL, GD_ProgressAbort, PLACETEXT_IN, NULL, (APTR)ProgressAbortClicked,
	4, 11, 311, 12, NULL, NULL, GD_Percent, 0, NULL, NULL,
	4, 0, 311, 11, NULL, NULL, GD_Action, 0, NULL, NULL
};

struct NewGadget LogNGad[] = {
	2, 1, 627, 48, NULL, NULL, GD_LogList, 0, NULL, (APTR)ProgressAbortClicked
};


ULONG ProgressGTags[] = {
	TAG_DONE,
	GTTX_Border, TRUE, TAG_DONE,
	GTTX_Text, (ULONG)"Working...", TAG_DONE
};

ULONG LogGTags[] = {
	GTLV_ReadOnly, TRUE, TAG_DONE
};


struct WinUserData ProgressWUD =
{
	{ NULL, NULL },
	NULL,
	ProgressGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	NULL,
	CloseProgressWindow,
	NULL,
	NULL,
	NULL,

	{ 145, 70, 318, 38 },
	NULL,
	ProgressGTypes,
	ProgressNGad,
	ProgressGTags,
	Progress_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET,
	BUTTONIDCMP|TEXTIDCMP|IDCMP_REFRESHWINDOW,
	NULL
};


struct WinUserData LogWUD =
{
	{ NULL, NULL },
	NULL,
	LogGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	NULL,
	CloseLogWindow,
	NULL,
	NULL,
	NULL,

	{ 0, 136, 632, 50 },
	NULL,
	LogGTypes,
	LogNGad,
	LogGTags,
	Log_CNT,
	WFLG_CLOSEGADGET|WFLG_DRAGBAR|WFLG_DEPTHGADGET,
	LISTVIEWIDCMP|IDCMP_REFRESHWINDOW|IDCMP_CLOSEWINDOW,
	"XModule Log"
};



LONG OpenProgressWindow (void)
{
	ProgressOpenCount++;
	if (ProgressOpenCount >1) return 0;

	LockWindows();

	if (!MyOpenWindow (&ProgressWUD)) return 1;

	ProgressIT.FrontPen	= DrawInfo->dri_Pens[FILLTEXTPEN] ? DrawInfo->dri_Pens[FILLTEXTPEN] : DrawInfo->dri_Pens[FILLPEN];

	ProgressIT.DrawMode = (DrawInfo->dri_Pens[FILLPEN] == DrawInfo->dri_Pens[FILLTEXTPEN] || !DrawInfo->dri_Pens[FILLTEXTPEN]) ?
		(JAM1 | COMPLEMENT) : (JAM1);

	ProgressIT.ITextFont = ProgressWUD.Attr;

	return 0;
}



void CloseProgressWindow (void)
{
	if (!ProgressWUD.Win) return;

	ProgressOpenCount--;
	if (ProgressOpenCount) return;

	MyCloseWindow (ProgressWUD.Win);
	UnlockWindows ();
}



LONG OpenLogWindow (void)
{
	return (!MyOpenWindow (&LogWUD));
}



void CloseLogWindow (void)
{
	MyCloseWindow (LogWUD.Win);

	/* Free ListView nodes */
	while (!IsListEmpty(&LogList))
		RemListViewNode (LogList.lh_Head);

	LogLines = 0;
}



void DisplayAction (ULONG msg)

/* Tell user what is happening in the Progress window. */
{
	if (ProgressWUD.Win)
		GT_SetGadgetAttrs (ProgressGadgets[GD_Action], ProgressWUD.Win, NULL,
			GTTX_Text, STR(msg),
			TAG_DONE);

	if (GuiSwitches.Verbose) ShowMessage (msg);
}



/* Tell user how are things going.  Also check for abort */
LONG DisplayProgress (LONG Num, LONG Max)
{
	struct Gadget *g = ProgressWUD.Gadgets[GD_Percent];

	/* Check for CTRL-C Break */
	if (SetSignal (0L, SIGBREAKF_CTRL_C) & SIGBREAKF_CTRL_C)
		return ERROR_BREAK;

	if (ProgressWUD.Win)
	{
		struct IntuiMessage	*msg;
		struct Window		*win;
		struct Layer_Info	*layerinfo;
		UWORD class;
		UBYTE buf[32];

		/* Check for "Abort" button */
		while (msg = GT_GetIMsg (WinPort))
		{
			class = msg->Class;
			win = msg->IDCMPWindow;

			GT_ReplyIMsg (msg);
			if (win == ProgressWUD.Win && class == IDCMP_GADGETUP)
				return ERROR_BREAK;
		}


		/* Attempt locking the LayerInfo associated with the
		 * screen where ProgressWindow resides in.
		 *
		 * We do this to prevent the operation in progress
		 * blocking when someone else (e.g. Intuition) is
		 * keeping the lock.
		 *
		 * Note that there is no AttemptLockLayerInfo() function
		 * and LockLayerInfo() will wait if the layer is already
		 * locked, which is what we are trying to avoid.  The
		 * workaround is to check the LockLayersCount before
		 * locking the LayerInfo.
		 */

		/* Perhaps using Scr->LayerInfo would be the same */
		layerinfo = ProgressWUD.Win->RPort->Layer->LayerInfo;

		Forbid();
		if (!layerinfo->LockLayersCount)
		{
			LockLayerInfo (layerinfo);
			Permit();

			/* Update Stats */
			ShowStats (g, Num, Max);

			/* Display progress string */

			SPrintf (buf, STR(MSG_PERCENT_DONE), Num, Max, (Num * 100) / Max);

			ProgressIT.IText = buf;

			PrintIText (ProgressWUD.Win->RPort, &ProgressIT,
				g->LeftEdge + 2 + (g->Width - 4 - IntuiTextLength (&ProgressIT)) / 2,
				g->TopEdge + 1 + (g->Height - 2 - ProgressWUD.Win->RPort->TxHeight) / 2);

			UnlockLayerInfo (layerinfo);
		}
		else
			Permit();
	}

	return FALSE;
}



static void ShowStats (struct Gadget *Gadget, LONG Value, LONG Max)

/* Show the percentage bars. */
{
	struct RastPort	*RPort = ProgressWUD.Win->RPort;
	LONG	MaxWidth = Gadget->Width - 4,
			Width;
	UBYTE FgPen = ReadAPen (RPort);

	if (Max < 1)		Max = 0;
	if (Value > Max)	Value = Max;


	if((Width = (MaxWidth * Value) / Max) > 0)
	{
		if(Width != MaxWidth)
		{
			SetAPen (RPort,0);
			RectFill (RPort, Gadget->LeftEdge + 2 + Width - 1, Gadget->TopEdge + 1,
				Gadget->LeftEdge + Gadget->Width - 3, Gadget->TopEdge + Gadget->Height - 2);
		}

		SetAPen (RPort, DrawInfo->dri_Pens[FILLPEN]);
		RectFill (RPort,Gadget->LeftEdge + 2,Gadget->TopEdge + 1,
			Gadget->LeftEdge + Width + 1, Gadget->TopEdge + Gadget->Height - 2);
	}
	else
	{
		SetAPen (RPort, 0);
		RectFill (RPort, Gadget->LeftEdge + 2, Gadget->TopEdge + 1,
			Gadget->LeftEdge + Gadget->Width - 3, Gadget->TopEdge + Gadget->Height - 2);
	}

	SetAPen (RPort, FgPen);
}




void ShowMessage (ULONG msg, ...)

/* Localized interface to ShowString(). */
{
	ShowString (STR(msg), (LONG *)(&msg+1));
}


void ShowString (STRPTR s, LONG *args)

/* Formats a string and shows it to the user in the Log Window.
 * If the Log Window can't be opened, this function will fall
 * to ShowRequest() or to Printf().
 */
{
	if (!IntuitionBase)
	{
		if (StdOut) VPrintf ((STRPTR)s, args);
		return;
	}

	if (!LogWUD.Win && Scr) OpenLogWindow();

	if (LogWUD.Win)
	{
		GT_SetGadgetAttrs (LogGadgets[GD_LogList], LogWUD.Win, NULL,
			GTLV_Labels, ~0,
			TAG_DONE);

		if (LogLines > 30)
		{
			RemListViewNode (LogList.lh_Head);
			LogLines--;
		}

		if (AddListViewNodeA (&LogList, s, args))
			LogLines++;
		else
			DisplayBeep(Scr);

		GT_SetGadgetAttrs (LogGadgets[GD_LogList], LogWUD.Win, NULL,
			GTLV_Labels, &LogList,
			GTLV_Top, 30,
			TAG_DONE);
	}
	else
		ShowRequestStr (s, NULL, args);
}



void ShowFault (ULONG msg, BOOL req)

/* Shows the dos reason for some failure. <msg> is any MSG_#? number
 * describing what has gone wrong.  If <req> is TRUE, the message
 * will be shown in a requester.
 */
{
	UBYTE buf[FAULT_MAX + 20];

	if (Fault (IoErr(), STR(msg), buf, FAULT_MAX + 20))
	{
		if (req) ShowRequestStr (buf, NULL, NULL);
		else ShowString (buf, NULL);
	}
}



/********************/
/* Progress Gadgets */
/********************/

static void ProgressAbortClicked (void)
{
	/* This is just a dummy function */
}

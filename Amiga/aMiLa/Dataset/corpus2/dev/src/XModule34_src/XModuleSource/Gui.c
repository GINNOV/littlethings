/*
**	Gui.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Graphic User Interface handling routines.
*/

#include <exec/nodes.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <utility/tagitem.h>
#include <graphics/rpattr.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/layers_protos.h>
#include <clib/keymap_protos.h>
#include <clib/utility_protos.h>
#include <clib/commodities_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/layers_pragmas.h>
#include <pragmas/keymap_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/commodities_pragmas.h>

#include "XModule.h"
#include "Gui.h"

struct Screen		*Scr = NULL;
struct ScrInfo		 ScrInfo = {0};
APTR				 VisualInfo = NULL;
struct DrawInfo		*DrawInfo = NULL;


struct TextAttr
	TopazAttr = { "topaz.font", 8, FS_NORMAL, FPF_ROMFONT },
	ScreenAttr = { 0 },
	WindowAttr = { 0 },
	ListAttr = { 0 },
	EditorAttr = { 0 };



struct WUDS Wuds[] =
{
	&ToolBoxWUD,		OpenToolBoxWindow,
	&InstrumentsWUD,	OpenInstrumentsWindow,
	&SongInfoWUD,		OpenSongInfoWindow,
	&SequenceWUD,		OpenSequenceWindow,
	&ProgressWUD,		OpenProgressWindow,
	&LogWUD,			OpenLogWindow,
	&SaveFormatWUD,		OpenSaveFormatWindow,
	&OptimizationWUD,	OpenOptimizationWindow,
	&ClearWUD,			OpenClearWindow,
	&PatternWUD,		OpenPatternWindow,
	&PrefsWUD,			OpenPrefsWindow,
	&PlayWUD,			OpenPlayWindow,
	&PattPrefsWUD,		OpenPattPrefsWindow,
	&PattSizeWUD,		OpenPattSizeWindow,
	NULL,               NULL
};


UWORD				 OffX, OffY;				/* X and Y offsets for window rendering	*/
struct MsgPort		*WinPort = NULL;			/* Shared IDCMP port for all windows	*/
ULONG				 IDCMPSig = 0;				/* Signal for above mentioned port		*/
ULONG				 Signals = SIGBREAKFLAGS;	/* Signals for Wait() in main loop		*/
struct IntuiMessage	 IntuiMsg;					/* A copy of the last received IntuiMsg	*/
struct List			 WindowList;				/* Linked list of all open windows		*/

UBYTE				 ActiveKey	= 0;			/* These three are used to handle		*/
struct Gadget		*ActiveGad	= NULL;			/*		selection of button gadgets		*/
struct Window		*ActiveWin	= NULL;			/*		with keyboard shortcuts.		*/
static struct Window *OldPrWindowPtr = (struct Window *)1L;

LONG	LastErr			= 0;
ULONG	UniqueID;						/* An ID got from GetUniqueID()				*/
UWORD	WinLockCount	= 0;			/* Allow nesting of window locking			*/
BOOL	Quit			= FALSE;
BOOL	DoNextSelect	= TRUE;			/* Menu selection, see menu handling code	*/
BOOL	ShowRequesters	= TRUE;
BOOL	OwnScreen		= FALSE;		/* Are we owners or visitors?				*/
BOOL	Reopening		= FALSE;		/* Set to TRUE while reopening windows		*/



struct GuiSwitches GuiSwitches =
{
	TRUE,		/* SaveIcons		*/
	TRUE,		/* AskOverwrite		*/
	TRUE,		/* AskExit			*/
	FALSE,		/* Verbose			*/
	TRUE,		/* ShowAppIcon		*/
	FALSE,		/* UseReqTools		*/
	TRUE,		/* SmartRefresh		*/
	TRUE,		/* UseDataTypes		*/
	TRUE,		/* InstrSaveIcons	*/
	INST_8SVX,	/* InstrSaveMode	*/
	1			/* SampDrawMode		*/
};



/* Wait pointer image data */
static chip UWORD WaitPointer[] =
{
	0x0000, 0x0000,

	0x0400, 0x07c0,
	0x0000, 0x07c0,
	0x0100, 0x0380,
	0x0000, 0x07e0,
	0x07c0, 0x1ff8,
	0x1ff0, 0x3fec,
	0x3ff8, 0x7fde,
	0x3ff8, 0x7fbe,
	0x7ffc, 0xff7f,
	0x7efc, 0xffff,
	0x7ffc, 0xffff,
	0x3ff8, 0x7ffe,
	0x3ff8, 0x7ffe,
	0x1ff0, 0x3ffc,
	0x07c0, 0x1ff8,
	0x0000, 0x07e0,

	0x0000, 0x0000
};



/* Local function prototypes */

static void	HandleIDCMP		(void);
static void HandleKey		(void);
static void SelectButton	(struct Window *win, struct Gadget *gad);
static void DeselectButton	(void);
static void ComputeFont		(struct WinUserData *wud);




LONG HandleGui (void)

/* Handle XModule's GUI - Main event handling loop */
{
	ULONG recsig;	/* Received Signals	*/
	LONG rc = 0;	/* Return Code		*/


	/* This is the main event handling loop */

	while (!Quit)
	{
		recsig = Wait (Signals);

		if (recsig & AudioSig)
			HandleAudio();

		if (recsig & IDCMPSig)
			HandleIDCMP();

		if (recsig & PubPortSig)
			HandleRexxMsg();

		if (recsig & AppSig)
			HandleAppMessage();

		if (recsig & FileReqSig)
			HandleFileRequest();

		if (recsig & CxSig)
			HandleCx();

		if (recsig & AmigaGuideSig)
			HandleAmigaGuide();

		/* Check break signals */
		if (recsig & SIGBREAKFLAGS)
		{
			if (recsig & SIGBREAKF_CTRL_C)
			{
				Quit = 1;
				rc = ERROR_BREAK;
			}

			if (recsig & SIGBREAKF_CTRL_D)
				if (MyBroker) ActivateCxObj (MyBroker, FALSE);

			if (recsig & SIGBREAKF_CTRL_E)
				if (MyBroker) ActivateCxObj (MyBroker, TRUE);

			if (recsig & SIGBREAKF_CTRL_F)
				DeIconify();
		}


		if (LastErr)
		{
			switch (LastErr)
			{
				case ERROR_NO_FREE_STORE:
					ShowMessage (MSG_NO_FREE_STORE);
					break;

				case ERROR_BREAK:
					ShowMessage (MSG_BREAK);
					break;

				default:
					break;
			}

			DisplayBeep (Scr);
			LastErr = 0;
		}

		if (Quit && GuiSwitches.AskExit)
			if (!ShowRequestArgs (MSG_REALLY_QUIT_XMODULE, MSG_YES_OR_NO, NULL))
			{
				Quit = 0;
				rc = 0;
			}

	}	/* End main loop */

	return rc;
}



/* Intuition Event Handler.  Based on GadToolsBox's HandleIDCMP() */
static void HandleIDCMP (void)
{
	struct IntuiMessage	*m;
	struct MenuItem		*n;
	struct Window		*win;
	struct WinUserData	*wud;

	while (m = GT_GetIMsg (WinPort))
	{
		CopyMem (m, &IntuiMsg, sizeof(struct IntuiMessage));
		GT_ReplyIMsg (m);

		win = IntuiMsg.IDCMPWindow;
		wud = (struct WinUserData *)win->UserData;

		switch (IntuiMsg.Class)
		{
			case	IDCMP_REFRESHWINDOW:

				GT_BeginRefresh (win);

				if (wud->RenderWin)
				{
					if (win->Flags & WFLG_SIZEGADGET)
					{
						/* Lock this window's Layer so its size won't
						 * change while we are rendering on it.
						 */
						LockLayer (NULL, win->WLayer);
						wud->RenderWin();
						UnlockLayer (win->WLayer);
					}
					else wud->RenderWin();
				}

				GT_EndRefresh (win, TRUE);
				break;

			case	IDCMP_RAWKEY:
				HandleKey ();
				break;

			case	IDCMP_CLOSEWINDOW:
				if (win == ToolBoxWUD.Win)
					Quit = 1;
				else
					((struct WinUserData *)win->UserData)->CloseWin();
				break;

			case	IDCMP_GADGETUP:
			case	IDCMP_GADGETDOWN:
				/* Execute function */
				((void (*)(void)) ((struct Gadget *)IntuiMsg.IAddress)->UserData) ();
				break;

			case	IDCMP_MENUPICK:
				while (IntuiMsg.Code != MENUNULL)
				{
					n = ItemAddress (win->MenuStrip, IntuiMsg.Code);
					((void (*)(void))(GTMENUITEM_USERDATA(n))) ();

					/* Some window operations invalidate the menu
					 * we are working on.  For istance, Re-opening a
					 * window causes the old MenuStrip to be killed.
					 * The DoNextSelect flag provides a way to stop
					 * this loop and avoid a nasty crash.
					 */
					if (!DoNextSelect)
					{
						DoNextSelect = TRUE;
						break;
					}
					IntuiMsg.Code = n->NextSelect;
				}
				break;

			case IDCMP_INACTIVEWINDOW:
				DeselectButton();
				break;

			case IDCMP_MENUHELP:
			case IDCMP_GADGETHELP:
				HandleHelp (&IntuiMsg);
				break;

			default:
				if (wud->IDCMPFunc) ((void (*)(void)) wud->IDCMPFunc) ();
				break;

		}	/* End switch (IntuiMsg.Class) */

		if (!WinPort) break;

	}	/* End while (GT_GetIMsg ()) */
}



static void HandleKey (void)
{
	struct Window		*win = IntuiMsg.IDCMPWindow;
	struct WinUserData	*wud = (struct WinUserData *)win->UserData;
	UWORD i;
	UBYTE keycode;


	/* Handle key up for buttons */

	if (IntuiMsg.Code & IECODE_UP_PREFIX)
	{
		struct Gadget *gad = ActiveGad;

		DeselectButton();
		if (gad && (ActiveKey == (IntuiMsg.Code & ~IECODE_UP_PREFIX)))
			((void (*)(void)) gad->UserData) ();

		return;
	}

	switch (IntuiMsg.Code)
	{
		case 0x5F:	/* HELP */
			HandleHelp (&IntuiMsg);
			return;

		case CURSORUP:
		case CURSORDOWN:
			for (i = 0; i < wud->GCount; i++)
				if (wud->GTypes[i] == LISTVIEW_KIND)
				{
					struct Gadget *g = wud->Gadgets[i];
					LONG selected, top = ~0;

					if (GadToolsBase->lib_Version < 39)
						// top = *(short *)(((char *)gad) + sizeof(struct Gadget) + 6);
						selected = (LONG)(*(UWORD *)(((char *)g)+sizeof(struct Gadget)+48));
					else
						GT_GetGadgetAttrs (g, win, NULL,
							GTLV_Selected,	&selected,
							GTLV_Top,		&top,
							TAG_DONE);

					selected = (LONG)((WORD) selected);	/* Extend to long */

					if (selected == ~0)
						selected = top;	/* Scroll Top */
					else
						top = ~0;

					if (IntuiMsg.Code == CURSORUP)
					{
						if (IntuiMsg.Qualifier & IEQUALIFIER_SHIFT)
							selected -= 5;
						else if (IntuiMsg.Qualifier & IEQUALIFIER_ALT)
							selected = 0;
						else
							selected--;
					}
					else /* CURSORDOWN */
					{
						if (IntuiMsg.Qualifier & IEQUALIFIER_SHIFT)
							selected += 5;
						else if (IntuiMsg.Qualifier & IEQUALIFIER_ALT)
							selected = 1000;
						else
							selected++;
					}

					if (selected < 0) selected = 0;

						GT_SetGadgetAttrs (g, win, NULL,
							(top == ~0) ? GTLV_Selected : GTLV_Top,			selected,
							(top == ~0) ? GTLV_MakeVisible : TAG_IGNORE,	selected,
							TAG_DONE);

					if (GadToolsBase->lib_Version < 39)
						selected = (LONG)(*(UWORD *)(((char *)g)+sizeof(struct Gadget)+48));
					else
						GT_GetGadgetAttrs (g, win, NULL,
							GTLV_Selected,	&selected,
							TAG_DONE);

					IntuiMsg.Code = selected;
					((void (*)(void)) g->UserData)();
					break; /* Stop for() loop */
				}
			return;

		case 0x42:	/* TAB */
			if (IntuiMsg.Qualifier & IEQUALIFIER_ALT)
			{
				struct WinUserData *nextwud;

				if (IntuiMsg.Qualifier & IEQUALIFIER_SHIFT)
				{
					/* ALT+SHIFT+TAB: Cycle windows backwards */

					nextwud = (struct WinUserData *)wud->Link.mln_Pred;

					if (!(nextwud->Link.mln_Pred))	/* List head? */
						nextwud = (struct WinUserData *)WindowList.lh_TailPred;
				}
				else
				{
					/* ALT+TAB: Cycle windows */

					nextwud = (struct WinUserData *)wud->Link.mln_Succ;

					if (!(nextwud->Link.mln_Succ))	/* List tail? */
						nextwud = (struct WinUserData *)WindowList.lh_Head;
				}

				RevealWindow (nextwud);
				return;
			}

		default:
			break;

	} /* End switch (IntuiMsg.Code) */


	/*	Convert the IDCMP_RAWKEY IntuiMessage to the single
	 *	character representation it corresponds to. If this isn't
	 *	possible (e.g. a HELP key or cursor key) then abort.
	 */
	{
		static struct InputEvent ie;		/* Ensure initalised to 0 */

		ie.ie_Class			= IECLASS_RAWKEY;
		ie.ie_Code			= IntuiMsg.Code;
		ie.ie_Qualifier		= IntuiMsg.Qualifier & IEQUALIFIER_CONTROL;	/* Filter qualifiers. */
		ie.ie_EventAddress	= *(APTR *)IntuiMsg.IAddress;
		if (MapRawKey (&ie, &keycode, 1, NULL) != 1)
			return;
	}


	/* Handle IDCMP_VANILLAKEY */

	/* Check special keys */
	switch (keycode)
	{
		case 0x03:	/* CTRL-C */
			Signal ((struct Task *)ThisTask, SIGBREAKF_CTRL_C);
			return;

		case 0x09:	/* TAB */
		case 0x0D:	/* RETURN */
			for (i = 0; i < wud->GCount; i++)
				if (wud->GTypes[i] == STRING_KIND || wud->GTypes[i] == INTEGER_KIND)
					ActivateGadget (wud->Gadgets[i],win, NULL);
			return;

		case 0x1B:	/* ESC */
			if (win != ToolBoxWUD.Win)
				wud->CloseWin();
			return;

		default:
			break;
	}


	/* Look for gadget shortcuts */

	for (i = 0; i < wud->GCount; i++)
	{
		if (wud->Keys[i] == keycode)	/* Case insensitive compare */
		{
			struct Gadget *g = wud->Gadgets[i];
			LONG disabled = FALSE;

			/* Check disabled */

			if (GadToolsBase->lib_Version < 39)
				disabled = g->Flags & GFLG_DISABLED;
			else
			{
				GT_GetGadgetAttrs (g, win, NULL,
					GA_Disabled, &disabled,
					TAG_DONE);
			}

			if (disabled) break;	/* Stop for() loop */

			switch (wud->GTypes[i])
			{
				case BUTTON_KIND:
					if (!(IntuiMsg.Qualifier & IEQUALIFIER_REPEAT))
						SelectButton (win, g);
				break;

				case CHECKBOX_KIND:
					GT_SetGadgetAttrs (g, win, NULL,
						GTCB_Checked, !(g->Flags & GFLG_SELECTED),
						TAG_DONE);
					((void (*)(void)) g->UserData)();
					break;

				case INTEGER_KIND:
				case STRING_KIND:
					ActivateGadget (g, win, NULL);
					break;

				case CYCLE_KIND:
					if (Kick30)
					{
						LONG act, max;
						UBYTE **lab;

						/* ON V37: active = *(short *)(((char *)gad) + sizeof(struct Gadget) + 6); */

						GT_GetGadgetAttrs (g, win, NULL,
							GTCY_Active, &act,
							GTCY_Labels, &lab,
							TAG_DONE);

						act = (LONG)((UWORD)act);	/* Extend to LONG */

						if (IntuiMsg.Qualifier & IEQUALIFIER_SHIFT)
							act--;
						else
							act++;

						for (max = 0; lab[max]; max++);	/* Count labels */

						if (act >= max) act = 0;
						else if (act < 0) act = max - 1;

						GT_SetGadgetAttrs (g, win, NULL,
							GTCY_Active, act,
							TAG_DONE);

						IntuiMsg.Code = act;
						((void (*)(void)) g->UserData)();
					}
					break;

				case MX_KIND:
				{
					LONG act;

					if (GadToolsBase->lib_Version < 39)
						act = (LONG)(*(UWORD *)(((char *)g)+sizeof(struct Gadget)+24));	/* 38? */
					else
					{
						GT_GetGadgetAttrs (g, win, NULL,
							GTMX_Active, &act,
							TAG_DONE);
						act = (LONG)((UWORD)act);	/* Extend to LONG */
					}

					if (IntuiMsg.Qualifier & IEQUALIFIER_SHIFT)
						act--;
					else
						act++;

					GT_SetGadgetAttrs (g, win, NULL,
						GTMX_Active, act,
						TAG_DONE);

					if (GadToolsBase->lib_Version < 39)
						act = (LONG)(*(UWORD *)(((char *)g)+sizeof(struct Gadget)+24));
					else
					{
						GT_GetGadgetAttrs (g, win, NULL,
							GTMX_Active, &act,
							TAG_DONE);
						act = (LONG)((UWORD)act);	/* Extend to LONG */
					}

					IntuiMsg.Code = act;
					((void (*)(void)) g->UserData)();

					break;
				}

				case SLIDER_KIND:
					if (Kick30)
					{
						LONG min, max, level;

						GT_GetGadgetAttrs (g, win, NULL,
							GTSL_Min, &min,
							GTSL_Max, &max,
							GTSL_Level, &level,
							TAG_DONE);

						/* Extend to LONG */
						min = (LONG)((WORD)min);
						max = (LONG)((WORD)max);
						level = (LONG)((WORD)level);

						if (IntuiMsg.Qualifier & IEQUALIFIER_SHIFT)
						{
							if (IntuiMsg.Qualifier & IEQUALIFIER_ALT)
								level = min;
							else level--;
						}
						else
						{
							if (IntuiMsg.Qualifier & IEQUALIFIER_ALT)
								level = max;
							else level++;
						}

						if (level > max) level = max;
						if (level < min) level = min;

						GT_SetGadgetAttrs (g, win, NULL,
							GTSL_Level, level,
							TAG_DONE);

						IntuiMsg.Code = level;
						((void (*)(void)) g->UserData)();
					}
					break;

				default:
					break;
			}

			return; /* Stop for() loop */
		}
	}	/* End for() */


	/* There is no apparent use for this key event,
	 * let's pass the IntuiMessage to user's IDCMPFunc()...
	 */
	if (wud->IDCMPFunc) ((void (*)(void)) wud->IDCMPFunc) ();
}



static void SelectButton (struct Window *win, struct Gadget *gad)

/* Selects the button gadget <gad>.  This operation is illegal with
 * GadTools gadgets, but many programs do it anyway, so this trick
 * will probably be supported in future OS releases :-).
 */
{
	UWORD gadpos;

	if (ActiveGad) DeselectButton();

	gadpos = RemoveGadget (win, gad);

	gad->Flags |= GFLG_SELECTED;
	AddGadget (win, gad, gadpos);
	RefreshGList (gad, win, NULL, 1);

	ActiveKey = IntuiMsg.Code;
	ActiveGad = gad;
	ActiveWin = win;
}



static void DeselectButton (void)

/* Deselects the button previously selected with SelectButton() */
{
	if	(ActiveGad)
	{
		UWORD gadpos = RemoveGadget (ActiveWin, ActiveGad);

		ActiveGad->Flags &= ~GFLG_SELECTED;
		AddGadget (ActiveWin, ActiveGad, gadpos);
		RefreshGList (ActiveGad, ActiveWin, NULL, 1);

		ActiveGad = NULL;
	}
}



void LockWindows (void)

/* Disable user input in all windows */
{
	struct WinUserData	*wud;
	struct Window		*win;
	struct WindowLock	*lock;


	/* Are the windows already locked? */
	WinLockCount++;
	if (WinLockCount > 1) return;

	for (wud = (struct WinUserData *) WindowList.lh_Head;
		wud->Link.mln_Succ;
		wud = (struct WinUserData *)wud->Link.mln_Succ)
	{
		win = wud->Win;

		/* Set wait pointer */
		if (Kick30)
			SetWindowPointer (win, WA_BusyPointer, TRUE, TAG_DONE);
		else
			SetPointer (win, WaitPointer, 16, 16, -6, 0);

		/* Do not block input in Progress window */
		if (wud == &ProgressWUD) continue;

		/* Set an invisible Requester in window to block user input.
		 * We allocate 4 more bytes after the requester structure to store
		 * the IDCMP flags before modifying them.  MEMF_PUBLIC is used
		 * because intuition is going to process the Requester structure.
		 */

		if (!(lock = AllocMem (sizeof (struct WindowLock), MEMF_PUBLIC)))
			continue;

		InitRequester (&lock->Req);
		lock->Req.Flags = SIMPLEREQ | NOREQBACKFILL;

		/* Disable window resizing */
		if (win->Flags & WFLG_SIZEGADGET)
		{
			lock->OldMinWidth	= win->MinWidth;
			lock->OldMinHeight	= win->MinHeight;
			lock->OldMaxWidth	= win->MaxWidth;
			lock->OldMaxHeight	= win->MaxHeight;
			WindowLimits (win, win->Width, win->Height,
				win->Width, win->Height);
		}

		/* Disable IDCMP messages except IDCMP_REFRESHWINDOW events.
		 * WARNING: ModifyIDCMP (win, 0) would free the shared port!!
		 */
		lock->OldIDCMPFlags = win->IDCMPFlags;
		ModifyIDCMP (win, IDCMP_REFRESHWINDOW);

		Request (&lock->Req, win);
	}
}



void UnlockWindows (void)

/* Restore user input in all windows. */
{
	struct WinUserData	*wud;
	struct Window		*win;
	struct WindowLock	*lock;


	/* Check lock nesting */
	WinLockCount--;
	if (WinLockCount) return;

	for (wud = (struct WinUserData *) WindowList.lh_Head;
		wud->Link.mln_Succ;
		wud = (struct WinUserData *)wud->Link.mln_Succ)
	{
		win = wud->Win;

		if (lock = (struct WindowLock *) win->FirstRequest)
		{
			/* Restore old window IDCMP */
			ModifyIDCMP (win, lock->OldIDCMPFlags);

			/* Re-enable window sizing and restore old window limits */
			if (win->Flags & WFLG_SIZEGADGET)
				WindowLimits (win, lock->OldMinWidth, lock->OldMinHeight,
					lock->OldMaxWidth, lock->OldMaxHeight);

			EndRequest (&lock->Req, wud->Win);
			FreeMem (lock, sizeof (struct WindowLock));
		}

		/* Restore standard pointer */
		if (Kick30)
			SetWindowPointer (win, TAG_DONE);
		else
			ClearPointer (win);
	}
}



void RevealWindow (struct WinUserData *wud)
{
	WindowToFront (wud->Win);
	ActivateWindow (wud->Win);

	/* Make the window visible on the screen */
    if (Kick30)
    	ScreenPosition (Scr, SPOS_MAKEVISIBLE,
			wud->Win->LeftEdge, wud->Win->TopEdge,
			wud->Win->LeftEdge + wud->Win->Width - 1,
			wud->Win->TopEdge + wud->Win->Height - 1);
}



void SetGadgets (struct WinUserData *wud, ULONG arg, ...)

/* Update status of gadgets in the window associated to <wud>.
 * <arg> is the first of a -1 terminated array of commands.
 * Each command is represented by a pair of LONGs, where the
 * first LONG is the gadget number, and the second is the value
 * to set for that gadget, depending on the gadget type.
 */

{
	ULONG *cmd = &arg;

	static ULONG actions[] =
	{
		TAG_DONE,		// GENERIC_KIND
		TAG_DONE,		// BUTTON_KIND
		GTCB_Checked,	// CHECKBOX_KIND
		GTIN_Number,	// INTEGER_KIND
		GTLV_Selected,	// LISTVIEW_KIND
		GTMX_Active,	// MX_KIND
		GTNM_Number,	// NUMBER_KIND
		GTCY_Active,	// CYCLE_KIND
		GTPA_Color,		// PALETTE_KIND
		TAG_DONE,		// SCROLLER_KIND
		TAG_DONE,		// -- reserved --
		GTSL_Level,		// SLIDER_KIND
		GTST_String,	// STRING_KIND
		GTTX_Text		// TEXT_KIND
	};

	while (*cmd != -1)
	{
		GT_SetGadgetAttrs (wud->Gadgets[*cmd], wud->Win, NULL,
			actions[wud->GTypes[*cmd]], *(cmd+1),
			TAG_DONE);

		cmd += 2;
	}
}



LONG AddListViewNode (struct List *lv, STRPTR label, ...)

/* Var-args stub for AddListViewNodeA */
{
	return AddListViewNodeA (lv, label, (LONG *) (&label)+1);
}



LONG AddListViewNodeA (struct List *lv, STRPTR label, LONG *args)

/* Allocate and add a new node to a ListView list.  The label
 * is printf()-formatted and copied to a buffer just after the
 * node structure.  Call RemListViewNode() to deallocate the node.
 *
 * RETURNS
 *   0 for failure (no memory), any other value for success.
 */
{
	struct Node *n;
	UBYTE buf[256];

	if (args)
	{
		VSPrintf (buf, label, args);
		label = buf;
	}

	if (!(n = AllocVec (sizeof (struct Node) + strlen (label) + 1, MEMF_PUBLIC)))
		return FALSE;

	n->ln_Name = ((UBYTE *)n) + sizeof (struct Node);

	strcpy (n->ln_Name, label);
	n->ln_Pri = 0;	/* Selected */

	AddTail (lv, n);

	return TRUE;
}



void RemListViewNode (struct Node *n)
{
	Remove (n);
	FreeVec (n);
}



void RenderWindowTexts (struct WinUserData *wud, struct IntuiText *texts, UWORD tnum)

/* Render an array of IntuiTexts on a window */
{
	struct IntuiText	it;
	UWORD				i;

	for (i = 0; i < tnum; i++)
	{
		memcpy (&it, &texts[i], sizeof (struct IntuiText));
		it.ITextFont	= wud->Attr;
		it.LeftEdge		= ComputeX (wud, it.LeftEdge) - (IntuiTextLength (&it) >> 1);
		it.TopEdge		= ComputeY (wud, it.TopEdge) - (wud->Attr->ta_YSize >> 1);
		PrintIText (wud->Win->RPort, &it, OffX, OffY);
	}
}



void RenderBevelBox (struct WinUserData *wud, WORD x1, WORD y1, WORD x2, WORD y2)
{
	DrawBevelBox (wud->Win->RPort,
		OffX + ComputeX (wud, x1), OffY + ComputeY (wud, y1),
		ComputeX (wud, x2), ComputeY (wud, y2),
		GT_VisualInfo,	VisualInfo,
		GTBB_Recessed,	TRUE,
		TAG_DONE );
}


struct Gadget *CreateGadgets (struct WinUserData *wud)
{
	struct Gadget		*g;
	UBYTE				*gkey, *c;
	ULONG				 SpecialTags[8];
	struct TagItem		*Tags, *tmp;
	Class				*class;
	struct NewGadget	 ng;
	UWORD				 lc, tc, stc, gkind;

	/* Allocate Array for Key Equivalents */
	if (!(gkey = wud->Keys = AllocMem (wud->GCount, MEMF_CLEAR)))
		return NULL;

	if (!(g = CreateContext (&wud->GList)))
	{
		DeleteGadgets (wud);
		return NULL;
	}

	SpecialTags[0] = GT_Underscore;
	SpecialTags[1] = (ULONG) '_';

	for (lc = 0, tc = 0; lc < wud->GCount; lc++)
	{
		memcpy (&ng, &(wud->NGad[lc]), sizeof(struct NewGadget));
		Tags = (struct TagItem *)SpecialTags;
		gkind = wud->GTypes[lc];
		stc = 2;

		ng.ng_VisualInfo	= VisualInfo;
		ng.ng_TextAttr		= /*(gkind == LISTVIEW_KIND) ? &ListAttr :*/ wud->Attr;
		ng.ng_LeftEdge		= OffX + ComputeX (wud, ng.ng_LeftEdge);
		ng.ng_TopEdge		= OffY + ComputeY (wud, ng.ng_TopEdge);
		ng.ng_Width			= ComputeX (wud, ng.ng_Width);
		ng.ng_Height		= ComputeY (wud, ng.ng_Height);


		/* Setup SpecialTags */
		switch (gkind)
		{
			case GENERIC_KIND:
				Tags = NULL;

				if (tmp = FindTagItem (XMGAD_BoopsiClass, (struct TagItem *)&wud->GTags[tc]))
					class = (Class *) tmp->ti_Data;
				else
					class = NULL;

				break;

			case CHECKBOX_KIND:
				SpecialTags[stc++] = GTCB_Scaled;
				SpecialTags[stc++] = TRUE;
				break;

			case INTEGER_KIND:
				/* Editing in right-justified integer gadgets
				 * is very uncomfortable!!
				 *
				 * SpecialTags[stc++] = STRINGA_Justification;
				 * SpecialTags[stc++] = GACT_STRINGRIGHT;
				 */
				SpecialTags[stc++] = STRINGA_ExitHelp;
				SpecialTags[stc++] = TRUE;
				break;

			case LISTVIEW_KIND:
				if (tmp = FindTagItem (GTLV_ShowSelected, (struct TagItem *)&wud->GTags[tc]))
					if (tmp->ti_Data) tmp->ti_Data = (ULONG)g;


				if (tmp = FindTagItem (GTLV_Labels, (struct TagItem *)&wud->GTags[tc]))
				{
					struct List *l = (struct List *)(tmp->ti_Data);

					l->lh_Type = 0;	/* Selected Item */
					l->l_pad = 0;	/* Item Count */
				}

				if (GadToolsBase->lib_Version < 39)
					ng.ng_Height -= 4;

				break;

			case MX_KIND:
				SpecialTags[stc++] = GTMX_Scaled;
				SpecialTags[stc++] = TRUE;
				SpecialTags[stc++] = GTMX_Spacing;
				SpecialTags[stc++] = 2;
				break;

			case NUMBER_KIND:
				/* Under V39 and below, GTJ_RIGHT does not
				 * work properly.
				 */

				if (GadToolsBase->lib_Version > 39)
				{
					SpecialTags[stc++] = GTNM_Justification;
					SpecialTags[stc++] = GTJ_RIGHT;
				}
				break;

			case PALETTE_KIND:
				SpecialTags[stc++] = GTPA_IndicatorWidth;
				SpecialTags[stc++] = ComputeX (wud, 16);
				break;

			case SCROLLER_KIND:
				SpecialTags[stc++] = GTSC_Arrows;
				SpecialTags[stc++] = 13;
				break;

			case STRING_KIND:
				SpecialTags[stc++] = STRINGA_ExitHelp;
				SpecialTags[stc++] = TRUE;
				break;

			default:
				break;
		}	/* End switch (gkind) */


		if (wud->GTags[tc] != TAG_DONE)
		{
			/* Add user Tags */
			SpecialTags[stc++] = TAG_MORE;
			SpecialTags[stc] = (ULONG) (&wud->GTags[tc]);
		}
		else SpecialTags[stc] = TAG_DONE;

		if (gkind == GENERIC_KIND && class)
		{
			/* BOOPSI Gadget. Let SetupFunc() allocate the gadget */

			if (tmp = FindTagItem (XMGAD_SetupFunc, (struct TagItem *)&wud->GTags[tc]))
			{
				if (g->NextGadget = ((struct Gadget * (*)(Class *, struct NewGadget *)) (tmp->ti_Data)) (class, &ng))
				{
					/* Record it into the list */
					wud->Gadgets[lc] = g = g->NextGadget;
				}
				else
				{
					DeleteGadgets (wud);
					return NULL;
				}
			}
			else
			{
				DeleteGadgets (wud);
				return NULL;
			}
		}
		else
		{
			/* Normal GadTools gadget */

			if (!(wud->Gadgets[lc] = g = CreateGadgetA ((ULONG)wud->GTypes[lc], g, &ng, Tags)))
			{
				DeleteGadgets (wud);
				return NULL;
			}

			/* Call custom setup function */
			if (gkind == GENERIC_KIND)
				if (tmp = FindTagItem (XMGAD_SetupFunc, (struct TagItem *)&wud->GTags[tc]))
					if (((LONG (*)(struct Gadget *)) (tmp->ti_Data)) (g))
					{
						DeleteGadgets (wud);
						return NULL;
					}
		}

		while (wud->GTags[tc]) tc += 2; /* Skip Tags */
		tc++;	/* Skip TAG_DONE */


		/* Look for the key equivalent of this gadget. */
		if (c = ng.ng_GadgetText)
			for ( ; *c ; c++)
				if (*c == '_')
				{
					/* Found! Now store in the key array */
					*gkey = *(++c) | (1<<5);	/* Lower case. */
					break;
				}

		gkey++;	/* Go to next Key byte. */
	}

	return (wud->GList);
}



void DeleteGadgets (struct WinUserData *wud)
{
	FreeGadgets (wud->GList);	wud->GList = NULL;

	if (wud->Keys)
		{ FreeMem (wud->Keys, wud->GCount); wud->Keys = NULL; }
}



struct Window *MyOpenWindow (struct WinUserData *wud)

/* Open & setup a window using the passed WinUserData structure. */
{
	struct Menu			*Menus = NULL;

	static LONG ExtraWindowTags[] =
	{
		WA_ScreenTitle,		(ULONG)Version+6,
		WA_AutoAdjust,		TRUE,
		WA_MenuHelp,		TRUE,
		WA_MouseQueue,		2,
		WA_RptQueue,		2,
		WA_NewLookMenus,	TRUE,
		TAG_DONE
	};
	UWORD wleft = wud->WindowSize.Left, wtop = wud->WindowSize.Top;

	if (wud->Win)
	{
		RevealWindow (wud);
		return wud->Win;
	}

	if (!Scr) return NULL;


	ComputeFont (wud);


	if (wud->GCount)
		if (!(CreateGadgets (wud)))
			return NULL;

	if (wud->NewMenu)
	{
		if (!(Menus = CreateMenusA (wud->NewMenu, NULL)))
			goto error1;
		if (!(LayoutMenus (Menus, VisualInfo,
			GTMN_NewLookMenus, TRUE,
			TAG_DONE)))
			goto error1;
	}


	/* Setup zoom size */

	if (wud->Flags & WFLG_SIZEGADGET)
	{
		wud->WindowZoom.Left = 0;
		wud->WindowZoom.Top = 1;
		wud->WindowZoom.Width = Scr->Width;
		wud->WindowZoom.Height = Scr->Height;
	}
	else
	{
		wud->WindowZoom.Left = wleft;
		wud->WindowZoom.Top = wtop;
		if (wud->Title)
			wud->WindowZoom.Width = TextLength (&Scr->RastPort, wud->Title,
				strlen(wud->Title)) + 80;
		else
			wud->WindowZoom.Width = 80;
		wud->WindowZoom.Height = Scr->WBorTop + Scr->RastPort.TxHeight + 1;

		/* TODO: Under V39 specifying ~0,~0 as Zoom X,Y, intuition
		 * will only size-zoom the window.  Consider implementing it...
		 */
	}

	/* Open the Window */

	if (!(wud->Win = OpenWindowTags (NULL,
		WA_Left,			wleft,
		WA_Top,				wtop,
		WA_InnerWidth,		(wud->Flags & WFLG_SIZEGADGET) ? wud->WindowSize.Width : ComputeX (wud, wud->WindowSize.Width),
		WA_InnerHeight,		(wud->Flags & WFLG_SIZEGADGET) ? wud->WindowSize.Height : ComputeY (wud, wud->WindowSize.Height),

		/* Set user preferred refresh method unless this window
		 * requests simple refresh explicitly.
		 */
		WA_Flags,			(wud->Flags | ((wud->Flags & WFLG_REFRESHBITS) ?
			0 : (GuiSwitches.SmartRefresh ? WFLG_SMART_REFRESH : WFLG_SIMPLE_REFRESH)))
			& (Reopening ? ~WFLG_ACTIVATE : ~0),
		WA_Gadgets,			wud->GList,
		WA_Title,			wud->Title,
		WA_Zoom,			&(wud->WindowZoom),
		WA_PubScreen,		Scr,
		WA_HelpGroup,		UniqueID,
		TAG_MORE,			ExtraWindowTags)))
	goto error1;

	wud->Win->UserData = (BYTE *) wud;
	wud->Win->UserPort = WinPort;

	/* Set default font for this window */
	if (wud->Font) SetFont (wud->Win->RPort, wud->Font);

	if (!(ModifyIDCMP (wud->Win, wud->IDCMPFlags |
		IDCMP_RAWKEY | IDCMP_MENUHELP | IDCMP_GADGETHELP | IDCMP_INACTIVEWINDOW)))
		goto error2;

	if (Menus) SetMenuStrip (wud->Win, Menus);

	/* Do initial refresh */
	GT_RefreshWindow (wud->Win, NULL);
	if (wud->RenderWin) wud->RenderWin();

	/* Make the window visible on the screen */
	if (!Reopening && Kick30)
	    ScreenPosition (Scr, SPOS_MAKEVISIBLE,
			wud->Win->LeftEdge, wud->Win->TopEdge,
			wud->Win->LeftEdge + wud->Win->Width - 1,
			wud->Win->TopEdge + wud->Win->Height - 1);


	/* Make it an AppWindow if it is required */
	if (wud->DropIcon) AddAppWin (wud);

	/* Link to opened windows list */
	AddHead (&WindowList, (struct Node *)wud);
	wud->WUDFlags &= ~WUDF_REOPENME;

	return wud->Win;

error2:
	CloseWindow (wud->Win);	wud->Win = NULL;
error1:
	FreeMenus (Menus);
	return NULL;
}



/* Close a window and all related resources */
void MyCloseWindow (struct Window *win)
{
	void *tmp;
	struct WinUserData *wud;
	struct Requester *req;

	if (!win) return;

	wud = (struct WinUserData *) win->UserData;

	DeselectButton();

	/* Cleanup locked window */
	if (req = wud->Win->FirstRequest)
	{
		EndRequest (req, wud->Win);
		FreeMem (req, sizeof (struct WindowLock));
	}

	/* Remove AppWindow */
	if (wud->AppWin) RemAppWin (wud);


	/* Free MenuStrip */
	if (tmp = win->MenuStrip)
	{
		ClearMenuStrip (win);
		FreeMenus (tmp);
		DoNextSelect = 0;	/* Do not loop any more on this window's MenuStrip */
	}


	/* Now remove any pending message from the shared IDCMP port */

	Forbid();
	{
		struct Node *succ;
		struct Message *msg = (struct Message *) win->UserPort->mp_MsgList.lh_Head;

		while (succ = msg->mn_Node.ln_Succ)
		{
			if (((struct IntuiMessage *)msg)->IDCMPWindow ==  win)
			{
				Remove ((struct Node *)msg);
				ReplyMsg (msg);
			}
			msg = (struct Message *) succ;
		}

		win->UserPort = NULL;	/* Keep intuition from freeing our port... */
		ModifyIDCMP (win, 0L);	/* ...and from sending us any more messages. */
	}
	Permit();


	/* Save Window position and clear window pointer */

	wud->WindowSize.Left	= win->LeftEdge;
	wud->WindowSize.Top		= win->TopEdge;

	if (win->Flags & WFLG_SIZEGADGET)
	{
		wud->WindowSize.Width	= win->Width - win->BorderLeft - win->BorderRight;
		wud->WindowSize.Height	= win->Height - win->BorderTop - win->BorderBottom;
	}


	CloseWindow (win);	wud->Win = NULL;

	DeleteGadgets (wud);

	if (wud->Font)
		{ CloseFont (wud->Font); wud->Font = NULL; }

	Remove ((struct Node *) wud);
}



void ReopenWindows (void)

/* Reopen windows that were previously open */
{
	struct WUDS *wuds = Wuds;

	Reopening = TRUE;

	while (wuds->Wud)
	{
		if (wuds->Wud->WUDFlags & WUDF_REOPENME)
			wuds->OpenWin();
		wuds++;
	}

	Reopening = FALSE;
}



LONG SetupScreen (void)
{
	struct Screen *DefScr;
	struct DrawInfo *DefDri;

	static LONG ExtraScreenTags[] =
	{
		SA_SysFont,			1,
		SA_FullPalette,		TRUE,
		SA_SharePens,		TRUE,	/* These three Tags are valid only under
		SA_LikeWorkbench,	TRUE,	 * V39 and are properly ignored by V37.
		SA_MinimizeISG,		TRUE,	 */
		SA_Interleaved,		TRUE,
		TAG_DONE
	};

	if (Scr)
	{
		/* If screen is already open, pop it to front and activate
		 * the main window.
		 */
		ScreenToFront (Scr);
		if (ThisTask->pr_WindowPtr)
			RevealWindow ((struct WinUserData *)(((struct Window *)(ThisTask->pr_WindowPtr))->UserData));

		return RETURN_OK;
	}

	/* Try the user selected Public Screen */

	if (!(Scr = LockPubScreen (ScrInfo.PubScreenName[0] ? ScrInfo.PubScreenName : NULL)))
	{
		/* Try to open own screen */

		if (ScrInfo.DisplayID)
		{
			static UWORD		 PensArray[1] = {(UWORD)~0};
			ULONG				*ColorTable	= NULL;
			struct ColorSpec	*ColorSpec	= NULL;
			ULONG				 i;

			/* Color map translation */

			if (ScrInfo.OwnPalette)
			{
				if (Kick30)
				{
					if (ColorTable = AllocMem (((32 * 3) + 2) * sizeof (LONG), MEMF_PUBLIC))
					{
						ULONG	*col = ColorTable,
								 tmp;

						*col++ = 32 << 16;

						for (i = 0; i < 32; i++)
						{
							tmp = (ScrInfo.Colors[i] >> 16);			/* Red */
							tmp |= tmp << 8 | tmp << 16 | tmp << 24;
							*col++ = tmp;

							tmp = (ScrInfo.Colors[i] >> 8) & 0xFF;		/* Green */
							tmp |= tmp << 8 | tmp << 16 | tmp << 24;
							*col++ = tmp;

							tmp = ScrInfo.Colors[i] & 0xFF;				/* Blue */
							tmp |= tmp << 8 | tmp << 16 | tmp << 24;
							*col++ = tmp;
						}

						*col = 0;
					}
				}
				else	/* V37 */
				{
					if (ColorSpec = AllocMem (33 * sizeof (struct ColorSpec), MEMF_PUBLIC))
					{
						for (i = 0; i < 32; i++)
						{
							ColorSpec[i].ColorIndex = i;
							ColorSpec[i].Red	= ScrInfo.Colors[i] >> 20;
							ColorSpec[i].Green	= ScrInfo.Colors[i] >> 12 & 0xF;
							ColorSpec[i].Blue	= ScrInfo.Colors[i] >>  4 & 0xF;
						}

						ColorSpec[i].ColorIndex = -1;
					}
				}
			}


			/* Use user requested attributes for screen */

			Scr = OpenScreenTags (NULL,
				SA_Width,			ScrInfo.Width,
				SA_Height,			ScrInfo.Height,
				SA_Depth,			ScrInfo.Depth,
				SA_DisplayID,		ScrInfo.DisplayID,
				SA_Overscan,		ScrInfo.OverscanType,
				SA_AutoScroll,		ScrInfo.AutoScroll,
				SA_Title,			ScrInfo.PubScreenName,
				SA_PubName,			ScrInfo.PubScreenName,
				SA_Pens,			PensArray,
				ScrInfo.OwnPalette ? (Kick30 ? SA_Colors32 : SA_Colors) : TAG_IGNORE,
					Kick30 ? (ULONG)ColorTable : (ULONG)ColorSpec,

				TAG_MORE,			ExtraScreenTags);

			if (ColorTable)	FreeMem (ColorTable, ((32 * 3) + 2) * sizeof (LONG));
			if (ColorSpec)	FreeMem (ColorSpec, 33 * sizeof (struct ColorSpec));
			if (Scr) OwnScreen = TRUE;
		}

		if (!Scr)
		{
			/* Try to clone the Default (Workbench) Screen */

			if (!(DefScr = LockPubScreen (NULL)))
				return RETURN_FAIL;

			DefDri = GetScreenDrawInfo (DefScr);

			if (Scr = OpenScreenTags (NULL,
				SA_Depth,			DefDri->dri_Depth,
				SA_DisplayID,		GetVPModeID (&DefScr->ViewPort),
				SA_Overscan,		OSCAN_TEXT,
				SA_AutoScroll,		TRUE,
				SA_Title,			ScrInfo.PubScreenName,
				SA_PubName,			ScrInfo.PubScreenName,
				SA_Pens,			DefDri->dri_Pens,
				TAG_MORE,			ExtraScreenTags))
			{
				UnlockPubScreen (NULL, DefScr);
				OwnScreen = TRUE;
			}
			else
				Scr = DefScr;

			FreeScreenDrawInfo (DefScr, DefDri);
		}

		/* Make our screen really public */
		if (OwnScreen) PubScreenStatus (Scr, 0);
	}

	if (!(VisualInfo = GetVisualInfoA (Scr, NULL)))
	{
		CloseDownScreen();
		return ERROR_NO_FREE_STORE;
	}

	DrawInfo = GetScreenDrawInfo (Scr);

	OffX = Scr->WBorLeft;
	OffY = Scr->RastPort.TxHeight + Scr->WBorTop + 1;

	/* Setup fonts */
	if (!WindowAttr.ta_Name) CopyTextAttr (Scr->Font, &WindowAttr);
	if (!ListAttr.ta_Name) CopyTextAttr (Scr->Font, &ListAttr);
	if (!EditorAttr.ta_Name) CopyTextAttr (&TopazAttr, &EditorAttr);


	/* Setup windows shared Message Port */
	if (!(WinPort = CreateMsgPort()))
	{
		CloseDownScreen();
		return ERROR_NO_FREE_STORE;
	}
	IDCMPSig = 1 << WinPort->mp_SigBit;
	Signals |= IDCMPSig;

	if (OpenToolBoxWindow())
	{
		CloseDownScreen();
		return ERROR_NO_FREE_STORE;
	}

	/* Set Process Window pointer for DOS requesters */
	OldPrWindowPtr = ThisTask->pr_WindowPtr;
	ThisTask->pr_WindowPtr = ToolBoxWUD.Win;

	ReopenWindows();

	/* Bring screen to front in case it was hidden */
	ScreenToFront (Scr);	// Not a good idea :-)

	return RETURN_OK;
}



void CloseDownScreen (void)

/* Free screen and all associated resources */
{
	struct WinUserData *wud;

	if (!Scr) return;

	/* Close AmigaGuide help window */
	CleanupHelp();

	/* Close all windows */
	for (wud = (struct WinUserData *)WindowList.lh_Head; wud->Link.mln_Succ;
			wud = (struct WinUserData *)wud->Link.mln_Succ)
	{
		wud->CloseWin();
		wud->WUDFlags |= WUDF_REOPENME;
	}

	if (WinPort)
	{
		Signals &= ~IDCMPSig;
		IDCMPSig = 0;
		DeleteMsgPort (WinPort); WinPort = NULL;
	}

	FreeScreenDrawInfo (Scr, DrawInfo);	DrawInfo = NULL;
	FreeVisualInfo (VisualInfo);		VisualInfo = NULL;

	if (OwnScreen)
	{
		while (!CloseScreen (Scr))
			ShowRequestArgs (MSG_CLOSE_ALL_WINDOWS, MSG_CONTINUE, NULL);
	}
	else UnlockPubScreen (NULL, Scr);

	if (OldPrWindowPtr != (struct Window *)1L)
	{
		ThisTask->pr_WindowPtr = OldPrWindowPtr;
		OldPrWindowPtr = (struct Window *)1L;
	}

	Scr = NULL;
	OwnScreen = FALSE;
}



UWORD ComputeX (struct WinUserData *wud, UWORD value)
{
	return ((UWORD)(( (wud->Font->tf_XSize * value) + 4 ) / 8 ));
}



UWORD ComputeY (struct WinUserData *wud, UWORD value)
{
	return ((UWORD)(( (wud->Font->tf_YSize * value) + 4 ) / 8 ));
}



static void ComputeFont (struct WinUserData *wud)
{
	wud->Attr = &WindowAttr;

	if (wud->Font = OpenFont (wud->Attr))
	{
		if ((ComputeX (wud, wud->WindowSize.Width) + OffX + Scr->WBorRight) > Scr->Width)
			goto UseTopaz;
		if ((ComputeY (wud, wud->WindowSize.Height) + OffY + Scr->WBorBottom) > Scr->Height)
			goto UseTopaz;

		return;
	}

UseTopaz:

	if (wud->Font) CloseFont (wud->Font);
	wud->Attr = &TopazAttr;
	wud->Font = OpenFont (wud->Attr);
}

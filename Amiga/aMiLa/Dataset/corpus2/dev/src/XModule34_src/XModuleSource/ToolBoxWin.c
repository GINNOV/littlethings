/*
**	ToolBoxWin.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Handle ToolBox panel.
*/

#include <exec/nodes.h>
#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <libraries/asl.h>
#include <workbench/workbench.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/wb_protos.h>
#include <clib/asl_protos.h>
#include <clib/icon_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/wb_pragmas.h>
#include <pragmas/asl_pragmas.h>
#include <pragmas/icon_pragmas.h>

#include "Gui.h"
#include "XModule.h"


#define ToolBoxWnd		ToolBoxWUD.Win
#define ToolBoxLeft		ToolBoxWUD.WindowSize.Left
#define ToolBoxTop		ToolBoxWUD.WindowSize.Top
#define ToolBoxWidth	ToolBoxWUD.WindowSize.Width
#define ToolBoxHeight	ToolBoxWUD.WindowSize.Height


/* Gadgets IDs */

enum
{
	GD_EditInstruments,
	GD_EditSequence,
	GD_EditPatterns,
	GD_Optimization,
	GD_Play,
	GD_EditSongs,
	ToolBox_CNT
};


/*****************************/
/* Local function prototypes */
/*****************************/

static void EditInstrumentsClicked (void);
static void EditSequenceClicked (void);
static void EditPatternsClicked (void);
static void OptimizationClicked (void);
static void PlayClicked (void);
static void EditSongsClicked (void);

static void ToolBoxMiNew (void);
static void ToolBoxMiOpen (void);
static void ToolBoxMiSave (void);
static void ToolBoxMiSaveAs (void);
static void ToolBoxMiClearMod (void);
static void ToolBoxMiAbout (void);
static void ToolBoxMiHelp (void);
static void ToolBoxMiIconify (void);
static void ToolBoxMiQuit (void);
static void ToolBoxMiSaveFormat (void);
static void ToolBoxMiUserInterface (void);
static void ToolBoxMiSaveIcons (void);
static void ToolBoxMiOverwrite (void);
static void ToolBoxMiAskExit (void);
static void ToolBoxMiVerbose (void);
static void ToolBoxMiOpenSettings (void);
static void ToolBoxMiSaveSettings (void);
static void ToolBoxMiSaveSettingsAs (void);


struct Gadget         *ToolBoxGadgets[ToolBox_CNT];



static struct NewMenu ToolBoxNewMenu[] = {
	NM_TITLE, (STRPTR)"Project", NULL, 0, NULL, NULL,
	NM_ITEM, (STRPTR)"New", (STRPTR)"N", 0, 0L, (APTR)ToolBoxMiNew,
	NM_ITEM, (STRPTR)"Open...", (STRPTR)"O", 0, 0L, (APTR)ToolBoxMiOpen,
	NM_ITEM, (STRPTR)"Save", (STRPTR)"S", 0, 0L, (APTR)ToolBoxMiSave,
	NM_ITEM, (STRPTR)"Save As...", (STRPTR)"A", 0, 0L, (APTR)ToolBoxMiSaveAs,
	NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
	NM_ITEM, (STRPTR)"Clear Module...", (STRPTR)"K", 0, 0L, (APTR)ToolBoxMiClearMod,
	NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
	NM_ITEM, (STRPTR)"About...", (STRPTR)"?", 0, 0L, (APTR)ToolBoxMiAbout,
	NM_ITEM, (STRPTR)"Help...", NULL, 0, 0L, (APTR)ToolBoxMiHelp,
	NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
	NM_ITEM, (STRPTR)"Iconify", (STRPTR)"I", 0, 0L, (APTR)ToolBoxMiIconify,
	NM_ITEM, (STRPTR)"Quit", (STRPTR)"Q", 0, 0L, (APTR)ToolBoxMiQuit,
	NM_TITLE, (STRPTR)"Settings", NULL, 0, NULL, NULL,
	NM_ITEM, (STRPTR)"Save Format...", NULL, 0, 0L, (APTR)ToolBoxMiSaveFormat,
	NM_ITEM, (STRPTR)"User Interface...", NULL, 0, 0L, (APTR)ToolBoxMiUserInterface,
	NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
	NM_ITEM, (STRPTR)"Save Icons?", NULL, CHECKIT|MENUTOGGLE, 0L, (APTR)ToolBoxMiSaveIcons,
	NM_ITEM, (STRPTR)"Confirm Overwrite?", NULL, CHECKIT|MENUTOGGLE, 0L, (APTR)ToolBoxMiOverwrite,
	NM_ITEM, (STRPTR)"Confirm Exit?", NULL, CHECKIT|MENUTOGGLE, 0L, (APTR)ToolBoxMiAskExit,
	NM_ITEM, (STRPTR)"Verbose?", NULL, CHECKIT|MENUTOGGLE, 0L, (APTR)ToolBoxMiVerbose,
	NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
	NM_ITEM, (STRPTR)"Open Settings...", NULL, 0, 0L, (APTR)ToolBoxMiOpenSettings,
	NM_ITEM, (STRPTR)"Save Settings", NULL, 0, 0L, (APTR)ToolBoxMiSaveSettings,
	NM_ITEM, (STRPTR)"Save Settings As...", NULL, 0, 0L, (APTR)ToolBoxMiSaveSettingsAs,
	NM_END, NULL, NULL, 0, 0L, NULL
};



UWORD ToolBoxGTypes[] = {
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND
};



struct NewGadget ToolBoxNGad[] = {
	158, 1, 153, 12, (UBYTE *)"_Instruments...", NULL, GD_EditInstruments, PLACETEXT_IN, NULL, (APTR)EditInstrumentsClicked,
	313, 1, 153, 12, (UBYTE *)"Se_quence...", NULL, GD_EditSequence, PLACETEXT_IN, NULL, (APTR)EditSequenceClicked,
	3, 1, 153, 12, (UBYTE *)"_Patterns...", NULL, GD_EditPatterns, PLACETEXT_IN, NULL, (APTR)EditPatternsClicked,
	158, 14, 153, 12, (UBYTE *)"_Optimization...", NULL, GD_Optimization, PLACETEXT_IN, NULL, (APTR)OptimizationClicked,
	313, 14, 153, 12, (UBYTE *)"Play...", NULL, GD_Play, PLACETEXT_IN, NULL, (APTR)PlayClicked,
	3, 14, 153, 12, (UBYTE *)"_Songs...", NULL, GD_EditSongs, PLACETEXT_IN, NULL, (APTR)EditSongsClicked
};



ULONG ToolBoxGTags[] = {
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE
};



struct WinUserData ToolBoxWUD =
{
	{ NULL, NULL },
	NULL,
	ToolBoxGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	NULL,
	CloseToolBoxWindow,
	ToolBoxDropIcon,
	NULL,
	NULL,

	{ 0, 1, 469, 27 },
	ToolBoxNewMenu,
	ToolBoxGTypes,
	ToolBoxNGad,
	ToolBoxGTags,
	ToolBox_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE,
	BUTTONIDCMP|IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW,
	"ToolBox"
};



/*********************/
/* ToolBox Functions */
/*********************/

LONG OpenToolBoxWindow (void)
{
	if (!MyOpenWindow (&ToolBoxWUD)) return 1;

	UpdateGuiSwitches();

	return 0;
}



void CloseToolBoxWindow (void)
{
	MyCloseWindow (ToolBoxWUD.Win);
}



void ToolBoxDropIcon (struct AppMessage *msg)
{
	struct SongInfo *si;
	struct WBArg	*wba = msg->am_ArgList;
	BPTR olddir;
	UWORD i;

	LockWindows();

	olddir = CurrentDir (wba->wa_Lock);

	for (i = 0; i < msg->am_NumArgs; i++)
	{
		CurrentDir (wba->wa_Lock);

		if (si = LoadModule (i ? NULL : songinfo, wba->wa_Name))
			AddSongInfo (si);
		else
			break;

		wba++;
	}

	CurrentDir (olddir);
	UnlockWindows();
}



void ToolBoxOpenModule (STRPTR file, ULONG num, ULONG count)

/* Handle FileRequester Open Module message */
{
	struct SongInfo *si;

	LockWindows();

	if (si = LoadModule (num ? NULL : songinfo, file))
		AddSongInfo (si);

	UnlockWindows();
}


void UpdateGuiSwitches (void)
{
	struct Menu *menustrip;
	struct MenuItem *item;

	if (ToolBoxWUD.Win)
	{
		menustrip = ToolBoxWUD.Win->MenuStrip;
		ClearMenuStrip (ToolBoxWUD.Win);

		item = ItemAddress (menustrip, SHIFTMENU(1) | SHIFTITEM(3) );

		/* Save Icons? */
		if (GuiSwitches.SaveIcons)
			item->Flags |= CHECKED;
		else
			item->Flags &= ~CHECKED;

		/* Confirm Overwrite? */
		item = item->NextItem;
		if (GuiSwitches.AskOverwrite)
			item->Flags |= CHECKED;
		else
			item->Flags &= ~CHECKED;

		/* Confirm Exit? */
		item = item->NextItem;
		if (GuiSwitches.AskExit)
			item->Flags |= CHECKED;
		else
			item->Flags &= ~CHECKED;

		/* Verbose? */
		item = item->NextItem;
		if (GuiSwitches.Verbose)
			item->Flags |= CHECKED;
		else
			item->Flags &= ~CHECKED;

		ResetMenuStrip (ToolBoxWUD.Win, menustrip);
	}
}



/*******************/
/* ToolBox Gadgets */
/*******************/

static void EditInstrumentsClicked (void)
{
	OpenInstrumentsWindow();
}

static void EditSequenceClicked (void)
{
	OpenSequenceWindow();
}

static void OptimizationClicked (void)
{
	OpenOptimizationWindow();
}

static void PlayClicked (void)
{
	OpenPlayWindow();
}

static void EditSongsClicked (void)
{
	OpenSongInfoWindow();
}

static void EditPatternsClicked (void)
{
	OpenPatternWindow();
}



/**************/
/* Menu Items */
/**************/

static void ToolBoxMiNew (void)
{
	struct SongInfo *si;

	if (si = NewSong())
		AddSongInfo (si);
}



static void ToolBoxMiOpen (void)
{
	StartFileRequest (FREQ_LOADMOD, ToolBoxOpenModule);
}



static void ToolBoxMiSave (void)
{
	LockWindows();

	if (songinfo)
		if (!(LastErr = SaveModule (songinfo, songinfo->SongPath, SaveSwitches.SaveType)))
			songinfo->Changes = 0;

	UnlockWindows();
}



static void ToolBoxMiSaveAs (void)
{
	if (!songinfo) return;

	LockWindows();

	if (FileRequest (FREQ_SAVEMOD, songinfo->SongPath))
		ToolBoxMiSave();

	UnlockWindows();
}



static void ToolBoxMiClearMod (void)
{
	OpenClearWindow();
}



static void ToolBoxMiAbout (void)
{
	ShowRequest (MSG_ABOUT_TEXT, MSG_CONTINUE,
		XMODULEVER,
		XMODULEDATE,
		XMODULECOPY,
		AvailMem (MEMF_CHIP) >> 10,
		AvailMem (MEMF_FAST) >> 10,
		ScrInfo.PubScreenName[0] ? ScrInfo.PubScreenName : STR(MSG_DEFAULT),
		PubPort ? PubPortName : STR(MSG_DISABLED),
		CxPort ? CxPopKey : STR(MSG_DISABLED),
		Catalog ? Catalog->cat_Language : (UBYTE *)"English");
}



static void ToolBoxMiHelp (void)
{
	HandleHelp (NULL);
}

static void ToolBoxMiIconify (void)
{
	Iconify();
	DoNextSelect = FALSE;
}



static void ToolBoxMiQuit (void)
{
	DoNextSelect = 0;
	Quit = 1;
}



static void ToolBoxMiSaveFormat (void)
{
	OpenSaveFormatWindow();
}

static void ToolBoxMiUserInterface (void)
{
	OpenPrefsWindow();
}



static void ToolBoxMiSaveIcons (void)
{
	GuiSwitches.SaveIcons ^= 1;
}



static void ToolBoxMiOverwrite (void)
{
	GuiSwitches.AskOverwrite ^= 1;
}



static void ToolBoxMiAskExit (void)
{
	GuiSwitches.AskExit ^= 1;
}



static void ToolBoxMiVerbose (void)
{
	GuiSwitches.Verbose ^= 1;
}



static void ToolBoxMiOpenSettings (void)
{
	UBYTE filename[PATHNAME_MAX];

	strcpy (filename, "XModule.prefs");

	if (FileRequest (FREQ_LOADMISC, filename))
		LastErr = LoadPrefs (filename);
}



static void ToolBoxMiSaveSettings (void)
{
	LastErr = SavePrefs ("PROGDIR:XModule.prefs");
}



static void ToolBoxMiSaveSettingsAs (void)
{
	UBYTE filename[PATHNAME_MAX];

	strcpy (filename, "PROGDIR:XModule.prefs");

	if (FileRequest (FREQ_SAVEMISC, filename))
		LastErr = SavePrefs (filename);
}

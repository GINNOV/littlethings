/*
**	PrefsWin.c
**
**	Copyright (C) 1994,1995 by Bernardo Innocenti
**
**	Preferences panel handling routines.
*/

#include <intuition/intuition.h>
#include <libraries/gadtools.h>
#include <libraries/asl.h>
#include <graphics/displayinfo.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/gadtools_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/gadtools_pragmas.h>

#include "Gui.h"
#include "XModule.h"



/* Gadgets IDs */

enum {
	GD_DisplayMode,
	GD_WindowFont,
	GD_EditorFont,
	GD_PubScreen,
	GD_GetPubScreen,
	GD_GetDisplayMode,
	GD_GetWindowFont,
	GD_GetEditorFont,
	GD_Requesters,
	GD_Refresh,
	GD_UseDataTypes,
	GD_AppIcon,
	GD_PrefsUse,
	GD_PrefsCancel,

	Prefs_CNT
};



/* Local functions prototypes */

static void PubScreenClicked (void);
static void GetPubScreenClicked (void);
static void GetDisplayModeClicked (void);
static void GetWindowFontClicked (void);
static void GetEditorFontClicked (void);
static void RequestersClicked (void);
static void RefreshClicked (void);
static void UseDataTypesClicked (void);
static void AppIconClicked (void);
static void PrefsUseClicked (void);
static void PrefsCancelClicked (void);


/* Local data */

static struct ScrInfo NewScrInfo;
static struct GuiSwitches NewGuiSwitches;
static struct TextAttr NewWindowAttr;
static struct TextAttr NewListAttr;
static struct TextAttr NewEditorAttr;



static struct Gadget	*PrefsGadgets[Prefs_CNT];

static UBYTE *Requesters11Labels[] = {
	(UBYTE *)"Asl",
	(UBYTE *)"ReqTools",
	NULL };

static UBYTE *Refresh11Labels[] = {
	(UBYTE *)"Simple",
	(UBYTE *)"Smart",
	NULL };



UWORD PrefsGTypes[] =
{
	TEXT_KIND,
	TEXT_KIND,
	TEXT_KIND,
	STRING_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	CYCLE_KIND,
	CYCLE_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	BUTTON_KIND,
	BUTTON_KIND
};



struct NewGadget PrefsNGad[] =
{
	138, 18, 201, 11, (UBYTE *)"Display Mode", NULL, GD_DisplayMode, PLACETEXT_LEFT, NULL, NULL,
	138, 31, 201, 11, (UBYTE *)"Window Font", NULL, GD_WindowFont, PLACETEXT_LEFT, NULL, NULL,
	138, 44, 201, 11, (UBYTE *)"Editor Font", NULL, GD_EditorFont, PLACETEXT_LEFT, NULL, NULL,
	138, 3, 201, 13, (UBYTE *)"_Public Screen", NULL, GD_PubScreen, PLACETEXT_LEFT, NULL, (APTR)PubScreenClicked,
	344, 3, 65, 13, (UBYTE *)"Get...", NULL, GD_GetPubScreen, PLACETEXT_IN, NULL, (APTR)GetPubScreenClicked,
	344, 18, 65, 11, (UBYTE *)"Get...", NULL, GD_GetDisplayMode, PLACETEXT_IN, NULL, (APTR)GetDisplayModeClicked,
	344, 31, 65, 11, (UBYTE *)"Get...", NULL, GD_GetWindowFont, PLACETEXT_IN, NULL, (APTR)GetWindowFontClicked,
	344, 44, 65, 11, (UBYTE *)"Get...", NULL, GD_GetEditorFont, PLACETEXT_IN, NULL, (APTR)GetEditorFontClicked,
	138, 57, 96, 13, (UBYTE *)"_Requesters", NULL, GD_Requesters, PLACETEXT_LEFT, NULL, (APTR)RequestersClicked,
	138, 72, 96, 13, (UBYTE *)"Refres_h", NULL, GD_Refresh, PLACETEXT_LEFT, NULL, (APTR)RefreshClicked,
	383, 57, 26, 11, (UBYTE *)"Use _DataTypes", NULL, GD_UseDataTypes, PLACETEXT_LEFT, NULL, (APTR)UseDataTypesClicked,
	383, 72, 26, 11, (UBYTE *)"App _Icon", NULL, GD_AppIcon, PLACETEXT_LEFT, NULL, (APTR)AppIconClicked,
	3, 90, 92, 11, (UBYTE *)"_Use", NULL, GD_PrefsUse, PLACETEXT_IN, NULL, (APTR)PrefsUseClicked,
	324, 90, 92, 11, (UBYTE *)"_Cancel", NULL, GD_PrefsCancel, PLACETEXT_IN, NULL, (APTR)PrefsCancelClicked
};

static ULONG PrefsGTags[] = {
	GTTX_Border, TRUE, TAG_DONE,
	GTTX_Border, TRUE, TAG_DONE,
	GTTX_Border, TRUE, TAG_DONE,
	GTST_MaxChars, 16, TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	GTCY_Labels, (ULONG)Requesters11Labels, TAG_DONE,
	GTCY_Labels, (ULONG)Refresh11Labels, TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE
};



struct WinUserData PrefsWUD =
{
	{ NULL, NULL },
	NULL,
	PrefsGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	NULL,
	ClosePrefsWindow,
	NULL,
	NULL,
	NULL,

	{ 40, 90, 420, 102 },
	NULL,
	PrefsGTypes,
	PrefsNGad,
	PrefsGTags,
	Prefs_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE,
	TEXTIDCMP|STRINGIDCMP|CHECKBOXIDCMP|BUTTONIDCMP|CYCLEIDCMP|IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW,
	"User Interface Settings"
};


LONG OpenPrefsWindow (void)
{
	if (MyOpenWindow (&PrefsWUD))
	{
		memcpy (&NewScrInfo, &ScrInfo, sizeof (struct ScrInfo));
		memcpy (&NewGuiSwitches, &GuiSwitches, sizeof (struct GuiSwitches));
		CopyTextAttr (&WindowAttr, &NewWindowAttr);
		CopyTextAttr (&ListAttr, &NewListAttr);
		CopyTextAttr (&EditorAttr, &NewEditorAttr);

		UpdatePrefsWindow();
		return 0;
	}
	return 1;
}


void ClosePrefsWindow (void)
{
	FreeVec (NewWindowAttr.ta_Name);	NewWindowAttr.ta_Name = NULL;
	FreeVec (NewListAttr.ta_Name);		NewListAttr.ta_Name = NULL;
	FreeVec (NewEditorAttr.ta_Name);	NewEditorAttr.ta_Name = NULL;

	MyCloseWindow (PrefsWUD.Win);
}


/********************/
/* Prefs Functions  */
/********************/

void UpdatePrefsWindow()
{
	/* These variables are declared static because gadtools text
	 * gadgets do not buffer their texts and require them to be
	 * accessible whenever a refresh is needed.
	 */
	static UBYTE windowfont[40], editorfont[40], listfont[40];
	static struct NameInfo nameinfo;


	if (!PrefsWUD.Win) return;

	if (NewScrInfo.DisplayID)
		GetDisplayInfoData (NULL, (void *)&nameinfo, sizeof (nameinfo), DTAG_NAME, NewScrInfo.DisplayID);
	else
		strcpy (nameinfo.Name, "--Clone Default Screen--");

	SPrintf (windowfont, "%s/%ld", NewWindowAttr.ta_Name, NewWindowAttr.ta_YSize);
	SPrintf (listfont, "%s/%ld", NewListAttr.ta_Name, NewListAttr.ta_YSize);
	SPrintf (editorfont, "%s/%ld", NewEditorAttr.ta_Name, NewEditorAttr.ta_YSize);

	SetGadgets (&PrefsWUD,
		GD_Requesters,		NewGuiSwitches.UseReqTools,
		GD_UseDataTypes,	NewGuiSwitches.UseDataTypes,
		GD_Refresh,			NewGuiSwitches.SmartRefresh,
		GD_AppIcon,			NewGuiSwitches.ShowAppIcon,
		GD_DisplayMode,		nameinfo.Name,
		GD_PubScreen,		NewScrInfo.PubScreenName,
		GD_WindowFont,		windowfont,
		GD_EditorFont,		editorfont,
		-1);
}



/******************/
/* Prefs Gadgets  */
/******************/

static void PubScreenClicked (void)
{
	strncpy (NewScrInfo.PubScreenName, GetString (PrefsGadgets[GD_PubScreen]), 31);
}


static void GetPubScreenClicked (void)
{
}

static void GetDisplayModeClicked (void)
{
	ScrModeRequest (&NewScrInfo);
	UpdatePrefsWindow();
}

static void GetWindowFontClicked (void)
{
	FontRequest (&NewWindowAttr, 0);
	UpdatePrefsWindow();
}

static void GetListFontClicked (void)
{
	FontRequest (&NewListAttr, 0);
	UpdatePrefsWindow();
}

static void GetEditorFontClicked (void)
{
	FontRequest (&NewEditorAttr, FOF_FIXEDWIDTHONLY);
	UpdatePrefsWindow();
}

static void RequestersClicked (void)
{
	NewGuiSwitches.UseReqTools ^= 1;
}

static void RefreshClicked (void)
{
	NewGuiSwitches.SmartRefresh ^= 1;
}

static void UseDataTypesClicked (void)
{
	NewGuiSwitches.UseDataTypes ^= 1;
}

static void AppIconClicked (void)
{
	NewGuiSwitches.ShowAppIcon ^= 1;
}


static void PrefsUseClicked (void)
{
	BOOL	change_screen	= FALSE,
			change_reqs		= FALSE,
			change_pattern	= FALSE;

	if (memcmp (&ScrInfo, &NewScrInfo, sizeof (struct ScrInfo)))
	{
		change_screen = TRUE;
		memcpy (&ScrInfo, &NewScrInfo, sizeof (struct ScrInfo));
	}

	if (memcmp (&GuiSwitches, &NewGuiSwitches, sizeof (struct GuiSwitches)))
	{
		if (GuiSwitches.UseReqTools != NewGuiSwitches.UseReqTools)
			change_reqs = TRUE;
		if (GuiSwitches.SmartRefresh != NewGuiSwitches.SmartRefresh)
			change_screen = TRUE;

		memcpy (&GuiSwitches, &NewGuiSwitches, sizeof (struct GuiSwitches));
	}

	if (CmpTextAttr (&NewWindowAttr, &WindowAttr))
	{
		CopyTextAttr (&NewWindowAttr, &WindowAttr);
		change_screen = TRUE;
	}

	if (CmpTextAttr (&NewListAttr, &ListAttr))
	{
		CopyTextAttr (&NewListAttr, &ListAttr);
		change_screen = TRUE;
	}

	if (CmpTextAttr (&NewEditorAttr, &EditorAttr))
	{
		CopyTextAttr (&NewEditorAttr, &EditorAttr);
		change_pattern = TRUE;
	}

	ClosePrefsWindow();

	if (change_reqs)
		SetupRequesters();

	if (GuiSwitches.ShowAppIcon)
		CreateAppIcon (ToolBoxDropIcon);
	else
		DeleteAppIcon ();

	if (change_screen)
	{
		CloseDownScreen();
		if (SetupScreen())
		{
			/* For some reason we have lost the screen: exit immediatly! */
			Quit = TRUE;
			ShowRequesters = FALSE;
		}
	}
	else if (change_pattern && PatternWUD.Win)
	{
		MyCloseWindow (PatternWUD.Win);
		OpenPatternWindow();
	}
}



static void PrefsCancelClicked (void)
{
	ClosePrefsWindow();
}

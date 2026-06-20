/*
**	FaveFormatWin.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	SaveFormat panel handling functions.
*/


#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>

#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>

#include "Gui.h"
#include "XModule.h"



#define ALLOWS_NO_SEQ	(1<<0)
#define ALLOWS_NO_INST	(1<<1)
#define ALLOWS_NO_PATT	(1<<2)
#define ALLOWS_NO_NAMES	(1<<3)


UBYTE FormatProperties[] =
{
	ALLOWS_NO_SEQ|ALLOWS_NO_INST|ALLOWS_NO_PATT|ALLOWS_NO_NAMES,	// XModule
	ALLOWS_NO_INST,													// NoiseTracker
	ALLOWS_NO_INST,													// ProTracker
	ALLOWS_NO_INST,													// SoundTracker
	0,																// Oktalyzer
	ALLOWS_NO_INST|ALLOWS_NO_NAMES,									// MED
	ALLOWS_NO_INST|ALLOWS_NO_NAMES,									// OctaMED
	0,																// TakeTracker
	0,																// ScreamTracker
	0,																// StarTrekker
	ALLOWS_NO_INST|ALLOWS_NO_NAMES									// MIDI File
};



struct SaveSwitches SaveSwitchesBackup;



/* Gadgets IDs */
enum {
	GD_SaveSequence,
	GD_SaveInstruments,
	GD_SavePatterns,
	GD_SaveType,
	GD_SaveIcons,
	GD_PackMode,
	GD_PackOptions,
	GD_FormatUse,
	GD_FormatCancel,
	GD_SaveNames,

	SaveFormat_CNT
};


/*****************************/
/* Local function prototypes */
/*****************************/

static void SaveFormatRender (void);

static void SaveSequenceClicked (void);
static void SaveInstrumentsClicked (void);
static void SavePatternsClicked (void);
static void SaveTypeClicked (void);
static void SaveIconsClicked (void);
static void PackModeClicked (void);
static void PackOptionsClicked (void);
static void FormatUseClicked (void);
static void FormatCancelClicked (void);
static void SaveNamesClicked (void);


struct SaveSwitches SaveSwitches = {0, 1, 1, 1, 1, 1};

static struct Gadget *SaveFormatGadgets[SaveFormat_CNT];

static UBYTE *SaveLabels[] =
{
	"XModule",
	"NoiseTracker",
	"ProTracker",
	"SoundTracker",
	"Oktalyzer",
	"MED",
	"OctaMED",
	"TakeTracker",
	"ScreamTracker",
	"StarTrekker",
	"MIDI File",
	NULL
};

static UBYTE *PackModeLabels[] =
{
	"None",
	"XPK",
	"LhA",
	NULL
};

static struct IntuiText SaveFormatIText[] = {
	2, 0, JAM1,240, 7, NULL, (UBYTE *)"Objects To Save", NULL,
	2, 0, JAM1,213, 81, NULL, (UBYTE *)"Compression", NULL };

#define SaveFormat_TNUM 2

static UWORD SaveFormatGTypes[] =
{
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	MX_KIND,
	CHECKBOX_KIND,
	CYCLE_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	CHECKBOX_KIND
};

static struct NewGadget SaveFormatNGad[] = {
	174, 13, 26, 11, (UBYTE *)"Se_quence", NULL, GD_SaveSequence, PLACETEXT_RIGHT, NULL, (APTR)SaveSequenceClicked,
	174, 25, 26, 11, (UBYTE *)"_Instruments", NULL, GD_SaveInstruments, PLACETEXT_RIGHT, NULL, (APTR)SaveInstrumentsClicked,
	174, 37, 26, 11, (UBYTE *)"_Patterns", NULL, GD_SavePatterns, PLACETEXT_RIGHT, NULL, (APTR)SavePatternsClicked,
	11, 4, 16, 8, (UBYTE *)"Save _Format", NULL, GD_SaveType, PLACETEXT_RIGHT, NULL, (APTR)SaveTypeClicked,
	174, 61, 26, 11, (UBYTE *)"Add I_con", NULL, GD_SaveIcons, PLACETEXT_RIGHT, NULL, (APTR)SaveIconsClicked,
	226, 87, 99, 13, (UBYTE *)"_Mode", NULL, GD_PackMode, PLACETEXT_LEFT, NULL, (APTR)PackModeClicked,
	226, 101, 99, 13, (UBYTE *)"Options...", NULL, GD_PackOptions, PLACETEXT_IN, NULL, (APTR)PackOptionsClicked,
	3, 118, 92, 13, (UBYTE *)"_Use", NULL, GD_FormatUse, PLACETEXT_IN, NULL, (APTR)FormatUseClicked,
	239, 118, 92, 13, (UBYTE *)"_Cancel", NULL, GD_FormatCancel, PLACETEXT_IN, NULL, (APTR)FormatCancelClicked,
	174, 49, 26, 11, (UBYTE *)"Names", NULL, GD_SaveNames, PLACETEXT_RIGHT, NULL, (APTR)SaveNamesClicked
};



static ULONG SaveFormatGTags[] =
{
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	GTMX_Labels, (ULONG)SaveLabels, TAG_DONE,
	TAG_DONE,
	GTCY_Labels, (LONG)PackModeLabels, TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE
};



struct WinUserData SaveFormatWUD =
{
	{ NULL, NULL },
	NULL,
	SaveFormatGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	SaveFormatRender,
	CloseSaveFormatWindow,
	NULL,
	NULL,
	NULL,

	{ 146, 26, 334, 133 },
	NULL,
	SaveFormatGTypes,
	SaveFormatNGad,
	SaveFormatGTags,
	SaveFormat_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_ACTIVATE,
	CHECKBOXIDCMP|MXIDCMP|BUTTONIDCMP|CYCLEIDCMP|IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW,
	"Module Format"
};



static void SaveFormatRender (void)
{
	RenderBevelBox (&SaveFormatWUD, 167, 75, 163, 41);
	RenderBevelBox (&SaveFormatWUD, 167,  1, 163, 73);
	RenderBevelBox (&SaveFormatWUD,   3,  1, 161, 115);
	RenderWindowTexts (&SaveFormatWUD, SaveFormatIText, SaveFormat_TNUM);
}


LONG OpenSaveFormatWindow (void)
{
	struct Window *win;

	if (!(win = MyOpenWindow (&SaveFormatWUD))) return 1;

	UpdateSaveSwitches();

	/* Backup SaveSwitches for "Cancel" option */
	memcpy (&SaveSwitchesBackup, &SaveSwitches, sizeof (SaveSwitchesBackup));

	return 0;
}



void CloseSaveFormatWindow (void)
{
	MyCloseWindow (SaveFormatWUD.Win);
}


void UpdateSaveSwitches (void)
{
	if (SaveFormatWUD.Win)
	{
		UBYTE properties;

		SetGadgets (&SaveFormatWUD,
			GD_SaveSequence,	SaveSwitches.SaveSeq,
			GD_SaveInstruments,	SaveSwitches.SaveInstr,
			GD_SavePatterns,	SaveSwitches.SavePatt,
			GD_SaveType,		SaveSwitches.SaveType,
			GD_SaveIcons,		SaveSwitches.SaveIcons,
			GD_SaveNames,		SaveSwitches.SaveNames,
			-1);

		properties = FormatProperties[SaveSwitches.SaveType];

		GT_SetGadgetAttrs (SaveFormatGadgets[GD_SaveSequence], SaveFormatWUD.Win, NULL,
			GA_Disabled, !(properties & ALLOWS_NO_SEQ),
			TAG_DONE);

		GT_SetGadgetAttrs (SaveFormatGadgets[GD_SavePatterns], SaveFormatWUD.Win, NULL,
			GA_Disabled, !(properties & ALLOWS_NO_PATT),
			TAG_DONE);

		GT_SetGadgetAttrs (SaveFormatGadgets[GD_SaveInstruments], SaveFormatWUD.Win, NULL,
			GA_Disabled, !(properties & ALLOWS_NO_INST),
			TAG_DONE);

		GT_SetGadgetAttrs (SaveFormatGadgets[GD_SaveNames], SaveFormatWUD.Win, NULL,
			GA_Disabled, !(properties & ALLOWS_NO_NAMES),
			TAG_DONE);
	}
}


/**********************/
/* SaveFormat Gadgets */
/**********************/


static void SaveSequenceClicked (void)
{
	SaveSwitches.SaveSeq ^= 1;
}

static void SaveInstrumentsClicked (void)
{
	SaveSwitches.SaveInstr ^= 1;
}

static void SavePatternsClicked (void)
{
	SaveSwitches.SavePatt ^= 1;
}

static void SaveTypeClicked (void)
{
	SaveSwitches.SaveType = IntuiMsg.Code;
	UpdateSaveSwitches();
}

static void SaveIconsClicked (void)
{
	SaveSwitches.SaveIcons ^= 1;
}


static void PackModeClicked (void)
{

}

static void PackOptionsClicked (void)
{

}

static void FormatUseClicked (void)
{
	CloseSaveFormatWindow();
}

static void FormatCancelClicked (void)
{
	/* Restore old SaveSwitches */
	memcpy (&SaveSwitches, &SaveSwitchesBackup, sizeof (SaveSwitchesBackup));

	CloseSaveFormatWindow();
}

static void SaveNamesClicked (void)
{
	SaveSwitches.SaveNames ^= 1;
}

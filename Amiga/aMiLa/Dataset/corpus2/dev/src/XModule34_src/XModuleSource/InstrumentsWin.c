/*
**	InstrumentsWin.c
**
**	Copyright (C) 1994,1995 Bernardo Innocenti
**
**	Instruments editor handling functions.
*/

#include <exec/nodes.h>
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

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/graphics_pragmas.h>

#include "Gui.h"
#include "XModule.h"



/* Gadgets IDs */

enum
{
	GD_InstrAdd,
	GD_InstrDel,
	GD_InstrUp,
	GD_InstrDown,
	GD_InstrName,
	GD_InstrList,
	GD_InstrLen,
	GD_InstrVolume,
	GD_InstrFineTune,
	GD_InstrEdit,
	GD_InstrKind,
	GD_InstrSwap,

	Instruments_CNT
};



/*****************************/
/* Local function prototypes */
/*****************************/

static void InstrumentsDropIcon (struct AppMessage *msg);

void UpdateInstrInfo	(void);
void UpdateInstrList	(void);

static void InstrAddClicked (void);
static void InstrDelClicked (void);
static void InstrUpClicked (void);
static void InstrSwapClicked (void);
static void InstrDownClicked (void);
static void InstrNameClicked (void);
static void InstrListClicked (void);
static void InstrVolumeClicked (void);
static void InstrFineTuneClicked (void);
static void InstrEditClicked (void);
static void InstrKindClicked (void);

static void InstrumentsMiLoad (void);
static void InstrumentsMiSave (void);
static void InstrumentsMiSaveAs (void);
static void InstrumentsMiRemap (void);
static void InstrumentsMiSaveIcons (void);
static void InstrumentsMiSaveCompressed (void);
static void InstrumentsMiSaveRaw (void);


struct List				 InstrList;
static struct Gadget	*InstrumentsGadgets[Instruments_CNT];
static ULONG			 InstrSecs = 0, InstrMicros = 0;



UBYTE *InstrKind1Labels[] = {
	(UBYTE *)"Sample",
	(UBYTE *)"Synth",
	(UBYTE *)"Hybrid",
	NULL };

struct NewMenu InstrumentsNewMenu[] = {
	NM_TITLE, (STRPTR)"Instruments", NULL, 0, NULL, NULL,
	NM_ITEM, (STRPTR)"Load...", (STRPTR)"L", 0, 0L, (APTR)InstrumentsMiLoad,
	NM_ITEM, (STRPTR)"Save", (STRPTR)"S", 0, 0L, (APTR)InstrumentsMiSave,
	NM_ITEM, (STRPTR)"Save As...", (STRPTR)"A", 0, 0L, (APTR)InstrumentsMiSaveAs,
	NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
	NM_ITEM, (STRPTR)"Remap", (STRPTR)"R", 0, 0L, (APTR)InstrumentsMiRemap,
	NM_TITLE, (STRPTR)"Settings", NULL, 0, NULL, NULL,
	NM_ITEM, (STRPTR)"Save Icons?", NULL, CHECKIT|MENUTOGGLE, 0L, (APTR)InstrumentsMiSaveIcons,
	NM_ITEM, (STRPTR)"Save Compressed?", NULL, CHECKIT|MENUTOGGLE, 4L, (APTR)InstrumentsMiSaveCompressed,
	NM_ITEM, (STRPTR)"Save Raw?", NULL, CHECKIT|MENUTOGGLE, 2L, (APTR)InstrumentsMiSaveRaw,
	NM_END, NULL, NULL, 0, 0L, NULL };


UWORD InstrumentsGTypes[] = {
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	STRING_KIND,
	LISTVIEW_KIND,
	NUMBER_KIND,
	SLIDER_KIND,
	SLIDER_KIND,
	BUTTON_KIND,
	CYCLE_KIND,
	BUTTON_KIND
};



struct NewGadget InstrumentsNGad[] = {
	272, 1, 65, 12, (UBYTE *)"_Add", NULL, GD_InstrAdd, PLACETEXT_IN, NULL, (APTR)InstrAddClicked,
	272, 15, 65, 12, (UBYTE *)"Del", NULL, GD_InstrDel, PLACETEXT_IN, NULL, (APTR)InstrDelClicked,
	272, 43, 65, 12, (UBYTE *)"_Up", NULL, GD_InstrUp, PLACETEXT_IN, NULL, (APTR)InstrUpClicked,
	272, 57, 65, 12, (UBYTE *)"_Down", NULL, GD_InstrDown, PLACETEXT_IN, NULL, (APTR)InstrDownClicked,
	3, 69, 266, 14, NULL, NULL, GD_InstrName, 0, NULL, (APTR)InstrNameClicked,
	3, 1, 266, 72, NULL, NULL, GD_InstrList, 0, NULL, (APTR)InstrListClicked,
	433, 23, 113, 12, (UBYTE *)"Length", NULL, GD_InstrLen, PLACETEXT_LEFT, NULL, NULL,
	433, 1, 113, 9, (UBYTE *)"_Volume", NULL, GD_InstrVolume, PLACETEXT_LEFT, NULL, (APTR)InstrVolumeClicked,
	433, 12, 113, 9, (UBYTE *)"_Fine Tune", NULL, GD_InstrFineTune, PLACETEXT_LEFT, NULL, (APTR)InstrFineTuneClicked,
	433, 52, 113, 13, (UBYTE *)"_Edit...", NULL, GD_InstrEdit, PLACETEXT_IN, NULL, (APTR)InstrEditClicked,
	433, 37, 113, 13, (UBYTE *)"_Kind", NULL, GD_InstrKind, PLACETEXT_LEFT, NULL, (APTR)InstrKindClicked,
	272, 29, 65, 12, (UBYTE *)"_Swap", NULL, GD_InstrSwap, PLACETEXT_IN, NULL, (APTR)InstrSwapClicked
};

ULONG InstrumentsGTags[] = {
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	GTST_MaxChars, 31, TAG_DONE,
	GTLV_ShowSelected, NULL, TAG_DONE,
	GTNM_Border, TRUE, TAG_DONE,
	GTSL_Max, 64, GTSL_MaxLevelLen, 3, GTSL_LevelFormat, (ULONG)"%ld", GTSL_LevelPlace, PLACETEXT_RIGHT, PGA_Freedom, LORIENT_HORIZ, GA_RelVerify, TRUE, TAG_DONE,
	GTSL_Min, -8, GTSL_Max, 7, GTSL_MaxLevelLen, 3, GTSL_LevelFormat, (ULONG)"%ld", GTSL_LevelPlace, PLACETEXT_RIGHT, PGA_Freedom, LORIENT_HORIZ, GA_RelVerify, TRUE, TAG_DONE,
	TAG_DONE,
	GTCY_Labels, (ULONG)&InstrKind1Labels[0], TAG_DONE,
	TAG_DONE
};


struct WinUserData InstrumentsWUD =
{
	{ NULL, NULL },
	NULL,
	InstrumentsGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	NULL,
	CloseInstrumentsWindow,
	InstrumentsDropIcon,
	NULL,
	NULL,

	{ 20, 48, 580, 86 },
	InstrumentsNewMenu,
	InstrumentsGTypes,
	InstrumentsNGad,
	InstrumentsGTags,
	Instruments_CNT,
	WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET | WFLG_ACTIVATE,
	CHECKBOXIDCMP|BUTTONIDCMP|STRINGIDCMP|LISTVIEWIDCMP|INTEGERIDCMP|NUMBERIDCMP|IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW,
	"Instruments"
};



LONG OpenInstrumentsWindow (void)
{
	struct Window *win;
	if (win = MyOpenWindow (&InstrumentsWUD))
	{
		UpdateInstrList();
		UpdateInstrSwitches();
	}

	return (!win);
}



void CloseInstrumentsWindow (void)
{
	if(InstrumentsWUD.Win)
	{
		MyCloseWindow (InstrumentsWUD.Win);

		while (!IsListEmpty(&InstrList))
			RemListViewNode (InstrList.lh_Head);
	}
}



static void InstrumentsDropIcon (struct AppMessage *msg)
{
	struct WBArg	*wba = msg->am_ArgList;
	BPTR olddir;
	UWORD i, j;

	if (!songinfo) return;

	LockWindows();

	olddir = CurrentDir (wba->wa_Lock);

	for (i = 0, j = songinfo->CurrentInst;
		(i < msg->am_NumArgs) && j < MAXINSTRUMENTS;
		i++, j++)
	{
		CurrentDir (msg->am_ArgList->wa_Lock);

		if (LastErr = LoadInstrument (&songinfo->Inst[j], wba->wa_Name))
			break;

		wba++;
	}

	CurrentDir (olddir);
	UnlockWindows();
}



/*************************/
/* Instruments Functions */
/*************************/

void UpdateInstrList (void)
{
	struct Instrument *inst;
	UWORD i;

	if (!InstrumentsWUD.Win) return;

	GT_SetGadgetAttrs (InstrumentsGadgets[GD_InstrList], InstrumentsWUD.Win, NULL,
		GTLV_Labels, ~0,
		TAG_DONE);

	/* Empty previous list */
	while (!IsListEmpty (&InstrList))
		RemListViewNode (InstrList.lh_Head);

	if (songinfo)
	{
		if (songinfo->CurrentInst < 1) songinfo->CurrentInst = 1;
		if (songinfo->CurrentInst > MAXINSTRUMENTS-1) songinfo->CurrentInst = MAXINSTRUMENTS-1;

		for (i = 1 ; i < MAXINSTRUMENTS; i++)
		{
			inst = &songinfo->Inst[i];
			AddListViewNode (&InstrList, "%02lx %s", i,
				(inst->SampleData || inst->Name[0]) ? inst->Name : (STRPTR)"--empty--");
		}

	}

	GT_SetGadgetAttrs (InstrumentsGadgets[GD_InstrList], InstrumentsWUD.Win, NULL,
		GTLV_Labels, &InstrList,
		GTLV_Selected, songinfo ? songinfo->CurrentInst-1 : ~0,
		TAG_DONE);

	UpdateInstrInfo();
}



void UpdateInstrInfo (void)
{
	if (InstrumentsWUD.Win && songinfo)
	{
		struct Instrument *inst = &songinfo->Inst[songinfo->CurrentInst];

		SetGadgets (&InstrumentsWUD,
			GD_InstrName,		inst->Name,
			GD_InstrVolume,		inst->Volume,
			GD_InstrFineTune,	inst->FineTune,
			GD_InstrLen,		inst->Length,
			-1);
	}

	UpdateSample();
	UpdateEditorInst();
}

void UpdateInstrSwitches (void)
{
	struct Menu *menustrip;
	struct MenuItem *item;

	if (InstrumentsWUD.Win)
	{
		menustrip = InstrumentsWUD.Win->MenuStrip;
		ClearMenuStrip (InstrumentsWUD.Win);

		item = ItemAddress (menustrip, SHIFTMENU(1) | SHIFTITEM(0) );

		/* Save Icons? */
		if (GuiSwitches.InstrSaveIcons)
			item->Flags |= CHECKED;
		else
			item->Flags &= ~CHECKED;

		ResetMenuStrip (InstrumentsWUD.Win, menustrip);
	}
}


static void InstrumentsLoad (STRPTR name, ULONG num, ULONG count)
{
	UWORD instnum = songinfo->CurrentInst + num;

	if (!songinfo || instnum >= MAXINSTRUMENTS) return;

	LockWindows();

	LoadInstrument (&songinfo->Inst[instnum], name);

	UnlockWindows();
}


/***********************/
/* Instruments Gadgets */
/***********************/

static void InstrAddClicked (void)
{
	if (!songinfo) return;
	StartFileRequest (FREQ_LOADINST, InstrumentsLoad);
}

static void InstrDelClicked (void)
{
	if (!songinfo) return;

	FreeInstr (&(songinfo->Inst[songinfo->CurrentInst]));
	songinfo->CurrentInst++;
	UpdateSongInfo();
}



static void InstrUpClicked (void)
{
	struct Instrument tmp;

	if (!songinfo) return;

	/* Swap actual instrument with the previous one */
	if (songinfo->CurrentInst <= 1) return;

	memcpy (&tmp, &(songinfo->Inst[songinfo->CurrentInst]), sizeof (struct Instrument));
	memcpy (&(songinfo->Inst[songinfo->CurrentInst]), &(songinfo->Inst[songinfo->CurrentInst-1]), sizeof (struct Instrument));
	memcpy (&(songinfo->Inst[songinfo->CurrentInst-1]), &tmp, sizeof (struct Instrument));
	songinfo->CurrentInst--;
	UpdateInstrList();
}

static void InstrDownClicked (void)
{
	struct Instrument tmp;

	if (!songinfo) return;

	/* Swap actual instrument with the next one */
	if (songinfo->CurrentInst == MAXINSTRUMENTS-1) return;

	memcpy (&tmp, &(songinfo->Inst[songinfo->CurrentInst]), sizeof (struct Instrument));
	memcpy (&(songinfo->Inst[songinfo->CurrentInst]), &(songinfo->Inst[songinfo->CurrentInst+1]), sizeof (struct Instrument));
	memcpy (&(songinfo->Inst[songinfo->CurrentInst+1]), &tmp, sizeof (struct Instrument));
	songinfo->CurrentInst++;
	UpdateInstrList();
}



static void InstrSwapClicked (void)
{
	if (!songinfo) return;

}



static void InstrNameClicked (void)
{
	if (!songinfo) return;

	strcpy (songinfo->Inst[songinfo->CurrentInst].Name,
		GetString (InstrumentsGadgets[GD_InstrName]));
	UpdateInstrList();
}



static void InstrListClicked (void)
{
	if (songinfo->CurrentInst != IntuiMsg.Code + 1)
	{
		songinfo->CurrentInst = IntuiMsg.Code + 1;
		UpdateInstrInfo();
	}
	else
	{
		/* Check Double Click */
		if (DoubleClick (InstrSecs, InstrMicros, IntuiMsg.Seconds, IntuiMsg.Micros))
			OpenSampleWindow();
	}

	InstrSecs = IntuiMsg.Seconds;
	InstrMicros = IntuiMsg.Micros;
}



static void InstrVolumeClicked (void)
{
	WORD vol = (WORD) IntuiMsg.Code;

	if (!songinfo) return;

	songinfo->Inst[songinfo->CurrentInst].Volume = (UWORD) vol;
}



static void InstrFineTuneClicked (void)
{
	WORD finetune = (WORD) IntuiMsg.Code;

	if (!songinfo) return;

	songinfo->Inst[songinfo->CurrentInst].FineTune = finetune;
}



static void InstrKindClicked (void)
{
	if (!songinfo) return;
}



static void InstrEditClicked (void)
{
	OpenSampleWindow();
}

/**************/
/* Menu Items */
/**************/


static void InstrumentsMiLoad (void)
{
	StartFileRequest (FREQ_LOADINST, InstrumentsLoad);
}

static void InstrumentsMiSave (void)
{
	if (!songinfo) return;

	LockWindows();
	SaveInstrument (&(songinfo->Inst[songinfo->CurrentInst]), songinfo->Inst[songinfo->CurrentInst].Name);
	UnlockWindows();
}

static void InstrumentsMiSaveAs (void)
{
	UBYTE buf[PATHNAME_MAX];

	if (!songinfo) return;

	LockWindows();
	if (FileRequest (FREQ_SAVEINST, buf))
	SaveInstrument (&(songinfo->Inst[songinfo->CurrentInst]), buf);
	UnlockWindows();
}

static void InstrumentsMiRemap (void)
{
	if (!songinfo) return;

	RemapInstruments (songinfo);
	UpdateSongInfo ();
}

static void InstrumentsMiSaveIcons (void)
{
	GuiSwitches.InstrSaveIcons ^= 1;
}

static void InstrumentsMiSaveCompressed (void)
{

}

static void InstrumentsMiSaveRaw (void)
{

}

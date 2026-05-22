/*
**	ClearWin.c
**
**	Copyright (C) 1994,1995 Bernardo Innocenti
**
**	Clear panel handling functions.
*/

#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>

#include <clib/alib_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>

#include "Gui.h"
#include "XModule.h"

#define ClearWnd	ClearWUD.Win


/* Gadgets IDs */

enum {
	GD_ClearPerform,
	GD_ClearSequence,
	GD_ClearInstruments,
	GD_ClearPatterns,

	Clear_CNT
};


/*****************************/
/* Local function prototypes */
/*****************************/

static void ClearPerformClicked (void);
static void ClearSequenceClicked (void);
static void ClearInstrumentsClicked (void);
static void ClearPatternsClicked (void);



static void ClearRender (void);


struct Gadget	*ClearGadgets[Clear_CNT];


struct ClearSwitches ClearSwitches =
{ 1, 1, 1 };



UWORD ClearGTypes[] = {
	BUTTON_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND
};


struct NewGadget ClearNGad[] = {
	38, 49, 91, 14, (UBYTE *)"_Clear", NULL, GD_ClearPerform, PLACETEXT_IN, NULL, (APTR)ClearPerformClicked,
	10, 4, 26, 11, (UBYTE *)"_Sequence", NULL, GD_ClearSequence, PLACETEXT_RIGHT, NULL, (APTR)ClearSequenceClicked,
	10, 19, 26, 11, (UBYTE *)"_Instruments", NULL, GD_ClearInstruments, PLACETEXT_RIGHT, NULL, (APTR)ClearInstrumentsClicked,
	10, 34, 26, 11, (UBYTE *)"_Patterns", NULL, GD_ClearPatterns, PLACETEXT_RIGHT, NULL, (APTR)ClearPatternsClicked
};



ULONG ClearGTags[] = {
	(TAG_DONE),
	(TAG_DONE),
	(TAG_DONE),
	(TAG_DONE)
};




struct WinUserData ClearWUD =
{
	{ NULL, NULL },
	NULL,
	ClearGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	ClearRender,
	CloseClearWindow,
	NULL,
	NULL,
	NULL,

	{ 228, 38, 168, 64 },
	NULL,
	ClearGTypes,
	ClearNGad,
	ClearGTags,
	Clear_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE,
	CHECKBOXIDCMP|BUTTONIDCMP|IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW,
	"Clear Module"
};



static void ClearRender (void)
{
	RenderBevelBox (&ClearWUD, 3, 1, 161, 47);
}

LONG OpenClearWindow (void)
{
	if (MyOpenWindow (&ClearWUD))
	{
		UpdateClearSwitches();
		return 0;
	}

	return 1;
}

void CloseClearWindow (void)
{
	MyCloseWindow (ClearWUD.Win);
}


void UpdateClearSwitches (void)
{
	if (ClearWUD.Win)
		SetGadgets (&ClearWUD,
			GD_ClearSequence, ClearSwitches.ClearSeq,
			GD_ClearInstruments, ClearSwitches.ClearInstr,
			GD_ClearPatterns, ClearSwitches.ClearPatt,
			-1);
}


/*****************/
/* Clear Gadgets */
/*****************/

static void ClearPerformClicked (void)
{
	UWORD i;

	if (ClearSwitches.ClearPatt)
	{
		for (i = 0 ; i < songinfo->NumPatterns ; i++)
			FreeTracks (songinfo->PattData[i].Notes,
				songinfo->PattData[i].Lines, songinfo->MaxTracks);

		if (AllocTracks (songinfo->PattData[0].Notes, DEF_PATTLEN, songinfo->MaxTracks))
		{
			LastErr = ERROR_NO_FREE_STORE;
			FreeSongInfo (songinfo);
			return;
		}

		songinfo->PattData[0].Tracks = songinfo->MaxTracks;
		songinfo->PattData[0].Lines = DEF_PATTLEN;

		songinfo->NumPatterns = 1;

	}

	if (ClearSwitches.ClearInstr)
	{
		for (i = 0 ; i < MAXINSTRUMENTS ; i++)
		if (songinfo->Inst[i].SampleData)
			FreeMem (songinfo->Inst[i].SampleData, songinfo->Inst[i].Length);

		memset (songinfo->Inst, 0, sizeof (struct Instrument) * MAXINSTRUMENTS);
	}

	if (ClearSwitches.ClearSeq)
	{
		SetSongLen (songinfo, 1);
		songinfo->Sequence[0] = 0;
	}

	UpdateSongInfo();
	CloseClearWindow();
}

static void ClearSequenceClicked (void)
{
	ClearSwitches.ClearSeq ^= 1;
}

static void ClearInstrumentsClicked (void)
{
	ClearSwitches.ClearInstr ^= 1;
}

static void ClearPatternsClicked (void)
{
	ClearSwitches.ClearPatt ^= 1;
}

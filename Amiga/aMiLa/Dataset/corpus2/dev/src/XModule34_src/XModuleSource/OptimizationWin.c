/*
**	OptimizationWin.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Song optimization panel.
*/


#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>

#include "Gui.h"
#include "XModule.h"



/* Gadgets IDs */

enum
{
	GD_OptPerform,
	GD_RemPatts,
	GD_RemDupPatts,
	GD_RemInstr,
	GD_CutAfterLoop,
	GD_CutEndZero,

	Optimization_CNT
};


/* Local functions prototypes */

static void OptimizationRender (void);

static void RemPattsClicked (void);
static void RemDupPattsClicked (void);
static void RemInstrClicked (void);
static void CutAfterLoopClicked (void);
static void CutEndZeroClicked (void);


struct Gadget	*OptimizationGadgets[Optimization_CNT];


struct OptSwitches OptSwitches = { 1, 1, 1, 1, 1};


UWORD OptimizationGTypes[] =
{
	BUTTON_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND
};


struct NewGadget OptimizationNGad[] = {
	90, 79, 91, 14, (UBYTE *)"_Optimize", NULL, GD_OptPerform, PLACETEXT_IN, NULL, (APTR)OptPerformClicked,
	12, 4, 26, 11, (UBYTE *)"Remove Unused _Patterns", NULL, GD_RemPatts, PLACETEXT_RIGHT, NULL, (APTR)RemPattsClicked,
	12, 19, 26, 11, (UBYTE *)"Remove _Duplicate Patterns", NULL, GD_RemDupPatts, PLACETEXT_RIGHT, NULL, (APTR)RemDupPattsClicked,
	12, 34, 26, 11, (UBYTE *)"Remove Unused _Instruments", NULL, GD_RemInstr, PLACETEXT_RIGHT, NULL, (APTR)RemInstrClicked,
	12, 49, 26, 11, (UBYTE *)"Cut Instruments After _Loop", NULL, GD_CutAfterLoop, PLACETEXT_RIGHT, NULL, (APTR)CutAfterLoopClicked,
	12, 64, 26, 11, (UBYTE *)"Cut Instrument _Zero Tails", NULL, GD_CutEndZero, PLACETEXT_RIGHT, NULL, (APTR)CutEndZeroClicked
};


ULONG OptimizationGTags[] = {
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE
};


struct WinUserData OptimizationWUD =
{
	{ NULL, NULL },
	NULL,
	OptimizationGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	OptimizationRender,
	CloseOptimizationWindow,
	NULL,
	NULL,
	NULL,

	{ 168, 37, 271, 94 },
	NULL,
	OptimizationGTypes,
	OptimizationNGad,
	OptimizationGTags,
	Optimization_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE,
	BUTTONIDCMP|CHECKBOXIDCMP|IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW,
	"Module Optimization"
};



static void OptimizationRender (void)
{
	RenderBevelBox (&OptimizationWUD, 3, 1, 266, 77);
}



LONG OpenOptimizationWindow (void)
{
	if (!MyOpenWindow (&OptimizationWUD)) return 1;

	UpdateOptSwitches();
	return 0;
}



void CloseOptimizationWindow (void)
{
	MyCloseWindow (OptimizationWUD.Win);
}



void UpdateOptSwitches (void)
{
	if (OptimizationWUD.Win)
		SetGadgets (&OptimizationWUD,
			GD_RemPatts,		OptSwitches.RemPatts,
			GD_RemDupPatts,		OptSwitches.RemDupPatts,
			GD_RemInstr,		OptSwitches.RemInstr,
			GD_CutAfterLoop,	OptSwitches.CutAfterLoop,
			GD_CutEndZero,		OptSwitches.CutEndZero,
			-1);
}



/************************/
/* Optimization Gadgets */
/************************/

void OptPerformClicked (void)
{
	ULONG oldsize = CalcSongSize (songinfo), newsize;

	if (OptSwitches.RemPatts) DiscardPatterns (songinfo);
	if (OptSwitches.RemDupPatts)
	{
		CutPatterns (songinfo);
		RemDupPatterns (songinfo);
	}
	if (OptSwitches.RemInstr)
	{
		RemUnusedInstruments (songinfo);
		RemDupInstruments (songinfo);
	}
	if (OptSwitches.CutAfterLoop) OptimizeInstruments (songinfo);
	if (OptSwitches.CutEndZero) OptimizeInstruments (songinfo);

	UpdateSongInfo();


	newsize = CalcSongSize (songinfo);
	ShowMessage (MSG_SAVED_X_BYTES, oldsize - newsize, ((oldsize - newsize) * 100) / oldsize );

	CloseOptimizationWindow();
}

static void RemPattsClicked (void)
{
	OptSwitches.RemPatts ^= 1;
}

static void RemDupPattsClicked (void)
{
	OptSwitches.RemDupPatts ^= 1;
}

static void RemInstrClicked (void)
{
	OptSwitches.RemInstr ^= 1;
}

static void CutAfterLoopClicked (void)
{
	OptSwitches.CutAfterLoop ^= 1;
}

static void CutEndZeroClicked (void)
{
	OptSwitches.CutEndZero ^= 1;
}

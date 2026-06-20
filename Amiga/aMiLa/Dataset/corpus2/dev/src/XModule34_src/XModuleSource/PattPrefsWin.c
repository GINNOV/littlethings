/*
**	PattPrefsWin.c
**
**	Copyright (C) 1995 Bernardo Innocenti
**
**	Pattern preferences panel and pattern size panel handling functions.
*/

#include <intuition/intuition.h>
#include <libraries/gadtools.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/utility_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/utility_pragmas.h>

#include "Gui.h"
#include "XModule.h"
#include "PattEditClass.h"


static void LinesPenClicked (void);
static void TextPenClicked (void);
static void AdvanceTracksClicked (void);
static void AdvanceLinesClicked (void);
static void MaxUndoLevelsClicked (void);
static void MaxUndoMemClicked (void);
static void WrapVertClicked (void);
static void WrapHorizClicked (void);
static void HexLineNumbersClicked (void);
static void BlankZeroClicked (void);
static void InverseTextClicked (void);
static void ClipUnitClicked (void);

static void PattSizeLinesClicked (void);
static void PattSizeTracksClicked (void);
static void PattSizeDoubleLClicked (void);
static void PattSizeHalveLClicked (void);
static void PattSizeDoubleTClicked (void);
static void PattSizeHalveTClicked (void);
static void PattSizeOKClicked (void);
static void PattSizeCancelClicked (void);



enum {
	GD_LinesPen,
	GD_TextPen,
	GD_AdvanceTracks,
	GD_AdvanceLines,
	GD_MaxUndoLevels,
	GD_MaxUndoMem,
	GD_WrapVert,
	GD_WrapHoriz,
	GD_HexLineNumbers,
	GD_BlankZero,
	GD_InverseText,
	GD_ClipUnit,

	PattPrefs_CNT
};

enum {
	GD_PattSizeLines,
	GD_PattSizeTracks,
	GD_PattSizeDoubleL,
	GD_PattSizeHalveL,
	GD_PattSizeDoubleT,
	GD_PattSizeHalveT,
	GD_PattSizeOK,
	GD_PattSizeCancel,

	PattSize_CNT
};



static struct PattSwitches OldPattSwitches;
static struct Pattern OldPatt = { 0 };
static ULONG OldPattNum = 0;


static UWORD PattPrefsGTypes[] = {
	PALETTE_KIND,
	PALETTE_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	CHECKBOX_KIND,
	INTEGER_KIND
};

static UWORD PattSizeGTypes[] = {
	INTEGER_KIND,
	INTEGER_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND
};


static struct NewGadget PattPrefsNGad[] = {
	148, 71, 286, 20, (UBYTE *)"Lines _Pen:", NULL, GD_LinesPen, PLACETEXT_LEFT, NULL, (APTR)LinesPenClicked,
	148, 92, 286, 20, (UBYTE *)"Text P_en:", NULL, GD_TextPen, PLACETEXT_LEFT, NULL, (APTR)TextPenClicked,
	148, 1, 61, 13, (UBYTE *)"Advance _Tracks:", NULL, GD_AdvanceTracks, PLACETEXT_LEFT, NULL, (APTR)AdvanceTracksClicked,
	148, 15, 61, 13, (UBYTE *)"Advance _Lines:", NULL, GD_AdvanceLines, PLACETEXT_LEFT, NULL, (APTR)AdvanceLinesClicked,
	148, 29, 61, 13, (UBYTE *)"Max _Undo Levels:", NULL, GD_MaxUndoLevels, PLACETEXT_LEFT, NULL, (APTR)MaxUndoLevelsClicked,
	148, 43, 61, 13, (UBYTE *)"Max Undo _Memory:", NULL, GD_MaxUndoMem, PLACETEXT_LEFT, NULL, (APTR)MaxUndoMemClicked,
	407, 16, 26, 11, (UBYTE *)"_Vertical Wrap:", NULL, GD_WrapVert, PLACETEXT_LEFT, NULL, (APTR)WrapVertClicked,
	407, 2, 26, 11, (UBYTE *)"_Horizontal Wrap:", NULL, GD_WrapHoriz, PLACETEXT_LEFT, NULL, (APTR)WrapHorizClicked,
	407, 30, 26, 11, (UBYTE *)"He_x Line numbers:", NULL, GD_HexLineNumbers, PLACETEXT_LEFT, NULL, (APTR)HexLineNumbersClicked,
	407, 44, 26, 11, (UBYTE *)"Blank _Zero Digits:", NULL, GD_BlankZero, PLACETEXT_LEFT, NULL, (APTR)BlankZeroClicked,
	407, 58, 26, 11, (UBYTE *)"_Inverse Text:", NULL, GD_InverseText, PLACETEXT_LEFT, NULL, (APTR)InverseTextClicked,
	148, 57, 61, 13, (UBYTE *)"_Clipboard Unit:", NULL, GD_ClipUnit, PLACETEXT_LEFT, NULL, (APTR)ClipUnitClicked
};

static struct NewGadget PattSizeNGad[] = {
	84, 4, 61, 13, (UBYTE *)"_Lines:", NULL, GD_PattSizeLines, PLACETEXT_LEFT, NULL, (APTR)PattSizeLinesClicked,
	84, 18, 61, 13, (UBYTE *)"_Tracks:", NULL, GD_PattSizeTracks, PLACETEXT_LEFT, NULL, (APTR)PattSizeTracksClicked,
	148, 4, 81, 13, (UBYTE *)"_Double", NULL, GD_PattSizeDoubleL, PLACETEXT_IN, NULL, (APTR)PattSizeDoubleLClicked,
	232, 4, 81, 13, (UBYTE *)"_Halve", NULL, GD_PattSizeHalveL, PLACETEXT_IN, NULL, (APTR)PattSizeHalveLClicked,
	148, 18, 81, 13, (UBYTE *)"D_ouble", NULL, GD_PattSizeDoubleT, PLACETEXT_IN, NULL, (APTR)PattSizeDoubleTClicked,
	232, 18, 81, 13, (UBYTE *)"H_alve", NULL, GD_PattSizeHalveT, PLACETEXT_IN, NULL, (APTR)PattSizeHalveTClicked,
	2, 35, 81, 13, (UBYTE *)"_OK", NULL, GD_PattSizeOK, PLACETEXT_IN, NULL, (APTR)PattSizeOKClicked,
	238, 35, 81, 13, (UBYTE *)"_Cancel", NULL, GD_PattSizeCancel, PLACETEXT_IN, NULL, (APTR)PattSizeCancelClicked
};


static ULONG PattPrefsGTags[] = {
	GTPA_Color, 0, GTPA_ColorTable, NULL, GTPA_NumColors, 0, TAG_DONE,
	GTPA_Color, 0, GTPA_NumColors, 0, GTPA_ColorOffset, 1, TAG_DONE,
	GTIN_MaxChars, 3, TAG_DONE,
	GTIN_MaxChars, 5, TAG_DONE,
	GTIN_MaxChars, 6, TAG_DONE,
	GTIN_MaxChars, 10, TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	GTIN_MaxChars, 3, TAG_DONE
};

static ULONG PattSizeGTags[] =
{
	GTIN_MaxChars, 5, TAG_DONE,
	GTIN_MaxChars, 2, TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE
};


static struct Gadget *PattPrefsGadgets[PattPrefs_CNT];

struct WinUserData PattPrefsWUD =
{
	{ NULL, NULL },
	NULL,
	PattPrefsGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	NULL,
	ClosePattPrefsWindow,
	NULL,
	NULL,
	NULL,

	{ 70, 16, 438, 114},
	NULL,
	PattPrefsGTypes,
	PattPrefsNGad,
	PattPrefsGTags,
	PattPrefs_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE,
	IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|BUTTONIDCMP|INTEGERIDCMP|PALETTEIDCMP|CHECKBOXIDCMP,
	"Pattern Editor Settings"
};


static struct Gadget *PattSizeGadgets[PattSize_CNT] = { 0 };

struct WinUserData PattSizeWUD =
{
	{ NULL, NULL },
	NULL,
	PattSizeGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	NULL,
	ClosePattSizeWindow,
	NULL,
	NULL,
	NULL,

	{ 160, 60, 322, 50 },
	NULL,
	PattSizeGTypes,
	PattSizeNGad,
	PattSizeGTags,
	PattSize_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE,
	IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|BUTTONIDCMP|INTEGERIDCMP,
	"Pattern Attributes"
};



static UBYTE *ColorTable;

LONG OpenPattPrefsWindow (void)
{
	ULONG i, j, numcols;

	numcols = 1 << Scr->RastPort.BitMap->Depth;

	if (!ColorTable)
	{
		if (!(ColorTable = AllocVecPooled (Pool, numcols)))
			return 1;

		/* Fill ColorTable */
		for (i = 0, j = 0; i < numcols; i++)
			if (!(i & PattSwitches.TextPen))
				ColorTable[j++] = i;

		/* Clear remaining colors */
		for (i = j ; i < numcols; i++)
			ColorTable[i] = 0;

		PattPrefsGTags[1] = PattSwitches.LinesPen;
		PattPrefsGTags[3] = (ULONG) ColorTable;
		PattPrefsGTags[5] = j;
		PattPrefsGTags[8] = PattSwitches.TextPen;
		PattPrefsGTags[10] = numcols - 1;

		OldPattSwitches = PattSwitches;
	}

	if (MyOpenWindow (&PattPrefsWUD))
	{
		UpdatePattPrefs();

		return 0;
	}

	return 1;
}



void ClosePattPrefsWindow (void)
{
	MyCloseWindow (PattPrefsWUD.Win);
	FreeVecPooled (Pool, ColorTable); ColorTable = NULL;
}



LONG OpenPattSizeWindow (void)
{
	if (MyOpenWindow (&PattSizeWUD))
	{
		UpdatePattSize();
		return 0;
	}

	return 1;
}


void UpdatePattPrefs (void)
{
	if (PattPrefsWUD.Win)
		SetGadgets (&PattPrefsWUD,
			GD_AdvanceTracks,	PattSwitches.AdvanceTracks,
			GD_AdvanceLines,	PattSwitches.AdvanceLines,
			GD_MaxUndoLevels,	PattSwitches.MaxUndoLevels,
			GD_MaxUndoMem,		PattSwitches.MaxUndoMem,
			GD_WrapHoriz,		PattSwitches.Flags & PEF_HWRAP,
			GD_WrapVert,		PattSwitches.Flags & PEF_VWRAP,
			GD_HexLineNumbers,	PattSwitches.Flags & PEF_HEXMODE,
			GD_BlankZero,		PattSwitches.Flags & PEF_BLANKZERO,
			GD_TextPen,			PattSwitches.TextPen,
			GD_LinesPen,		PattSwitches.LinesPen,
			-1);
}



void ClosePattSizeWindow (void)
{
	FreeTracks (OldPatt.Notes, OldPatt.Lines, OldPatt.Tracks);
	OldPatt.Lines	= 0;
	OldPatt.Tracks	= 0;

	MyCloseWindow (PattSizeWUD.Win);
}



void UpdatePattSize (void)
{
	if (songinfo && PattSizeWUD.Win)
	{
		struct Pattern *patt = &songinfo->PattData[songinfo->CurrentPatt];

		/* Free previous backup copy, if any */

		FreeTracks (OldPatt.Notes, OldPatt.Lines, OldPatt.Tracks);
		OldPatt.Lines	= 0;
		OldPatt.Tracks	= 0;

		/* Make a local backup copy of the current pattern (it may fail) */

		OldPattNum = songinfo->CurrentPatt;
		CopyPattern (&songinfo->PattData[OldPattNum], &OldPatt);

		/* Update gadgets */
		SetGadgets (&PattSizeWUD,
			GD_PattSizeLines, patt->Lines,
			GD_PattSizeTracks, patt->Tracks,
			-1);
	}
}

static void LinesPenClicked (void)
{
	PattSwitches.LinesPen = (UWORD) IntuiMsg.Code;

	if (PatternWUD.Win)
		SetGadgetAttrs (PatternWUD.Gadgets[0], PatternWUD.Win, NULL,
			PATTA_LinesPen,	PattSwitches.LinesPen,
			TAG_DONE);
}

static void TextPenClicked (void)
{
	ULONG i, j, numcols = 1 << Scr->RastPort.BitMap->Depth;

	PattSwitches.TextPen = (UWORD) IntuiMsg.Code;

	/* Recalculate Lines colors */
	for (i = 0, j = 0; i < numcols; i++)
		if (!(i & PattSwitches.TextPen))
			ColorTable[j++] = i;

	/* Clear remaining colors */
	for (i = j ; i < numcols; i++)
		ColorTable[i] = 0;

	if (PattSwitches.LinesPen & PattSwitches.TextPen)
		PattSwitches.LinesPen = ColorTable[(j > 1) ? 1 : 0];

	GT_SetGadgetAttrs (PattPrefsGadgets[GD_LinesPen], PattPrefsWUD.Win, NULL,
		GTPA_Color,			PattSwitches.LinesPen,
		GTPA_ColorTable,	ColorTable,
		GTPA_NumColors,		j,
		TAG_DONE);

	if (PatternWUD.Win)
		SetGadgetAttrs (PatternWUD.Gadgets[0], PatternWUD.Win, NULL,
			PATTA_TextPen,	PattSwitches.TextPen,
			TAG_DONE);
}

static void AdvanceTracksClicked (void)
{
	PattSwitches.AdvanceTracks = (WORD) GetNumber (PattPrefsGadgets[GD_AdvanceTracks]);

	if (PatternWUD.Win)
		SetGadgetAttrs (PatternWUD.Gadgets[0], PatternWUD.Win, NULL,
			PATTA_AdvanceCurs,	(PattSwitches.AdvanceTracks << 16) |
								((UWORD)PattSwitches.AdvanceLines),
			TAG_DONE);
}

static void AdvanceLinesClicked (void)
{
	PattSwitches.AdvanceLines = (WORD) GetNumber(PattPrefsGadgets[GD_AdvanceLines]);

	if (PatternWUD.Win)
		SetGadgetAttrs (PatternWUD.Gadgets[0], PatternWUD.Win, NULL,
			PATTA_AdvanceCurs,	(PattSwitches.AdvanceTracks << 16) |
								((UWORD)PattSwitches.AdvanceLines),
			TAG_DONE);
}

static void MaxUndoLevelsClicked (void)
{
	PattSwitches.MaxUndoLevels = (WORD) GetNumber (PattPrefsGadgets[GD_MaxUndoLevels]);

	if (PatternWUD.Win)
		SetGadgetAttrs (PatternWUD.Gadgets[0], PatternWUD.Win, NULL,
			PATTA_MaxUndoLevels,	PattSwitches.MaxUndoLevels,
			TAG_DONE);
}

static void MaxUndoMemClicked (void)
{
	PattSwitches.MaxUndoMem = (WORD) GetNumber (PattPrefsGadgets[GD_MaxUndoMem]);

	if (PatternWUD.Win)
		SetGadgetAttrs (PatternWUD.Gadgets[0], PatternWUD.Win, NULL,
			PATTA_MaxUndoMem,	PattSwitches.MaxUndoMem,
			TAG_DONE);
}

static void WrapVertClicked (void)
{
	PattSwitches.Flags ^= PEF_VWRAP;

	if (PatternWUD.Win)
		SetGadgetAttrs (PatternWUD.Gadgets[0], PatternWUD.Win, NULL,
			PATTA_Flags,	PattSwitches.Flags,
			TAG_DONE);
}

static void WrapHorizClicked (void)
{
	PattSwitches.Flags ^= PEF_HWRAP;

	if (PatternWUD.Win)
		SetGadgetAttrs (PatternWUD.Gadgets[0], PatternWUD.Win, NULL,
			PATTA_Flags,	PattSwitches.Flags,
			TAG_DONE);
}

static void HexLineNumbersClicked (void)
{
	PattSwitches.Flags ^= PEF_HEXMODE;

	if (PatternWUD.Win)
		SetGadgetAttrs (PatternWUD.Gadgets[0], PatternWUD.Win, NULL,
			PATTA_Flags,	PattSwitches.Flags,
			TAG_DONE);
}

static void BlankZeroClicked (void)
{
	PattSwitches.Flags ^= PEF_BLANKZERO;

	if (PatternWUD.Win)
		SetGadgetAttrs (PatternWUD.Gadgets[0], PatternWUD.Win, NULL,
			PATTA_Flags,	PattSwitches.Flags,
			TAG_DONE);
}

static void InverseTextClicked (void)
{
}

static void ClipUnitClicked (void)
{
	PattSwitches.ClipboardUnit = (UBYTE) GetNumber (PattPrefsGadgets[GD_ClipUnit]);
}



static void PattSizeLinesClicked (void)
{
}

static void PattSizeTracksClicked (void)
{
}



static void PattSizeDoubleLClicked (void)
{
	if (songinfo)
	{
		struct Pattern *patt = &songinfo->PattData[songinfo->CurrentPatt];
		struct Pattern oldpatt;
		UWORD i, j;

		if (patt->Lines > MAXPATTLINES/2)
			ShowMessage (MSG_PATT_TOO_LONG);

		memcpy (&oldpatt, patt, sizeof (struct Pattern));

		if (!AllocTracks (patt->Notes, patt->Lines << 1, patt->Tracks))
		{
			patt->Lines <<= 1;

			for (i = 0; i < patt->Tracks; i++)
				for (j = 0; j < oldpatt.Lines; j++)
					memcpy (&patt->Notes[i][j*2], &oldpatt.Notes[i][j], sizeof (struct Note));

			FreeTracks (oldpatt.Notes, oldpatt.Lines, oldpatt.Tracks);
			UpdatePattern();
		}
		else
		{
			memcpy (patt, &oldpatt, sizeof (struct Pattern));
			LastErr = ERROR_NO_FREE_STORE;
		}
	}
}



static void PattSizeHalveLClicked (void)
{
	if (songinfo)
	{
		struct Pattern *patt = &songinfo->PattData[songinfo->CurrentPatt];
		struct Pattern oldpatt;
		UWORD i, j;

		memcpy (&oldpatt, patt, sizeof (struct Pattern));

		if (!AllocTracks (patt->Notes, patt->Lines >> 1, patt->Tracks))
		{
			patt->Lines >>= 1;

			for (i = 0; i < patt->Tracks; i++)
				for (j = 0; j < patt->Lines; j++)
					memcpy (&patt->Notes[i][j], &oldpatt.Notes[i][j*2], sizeof (struct Note));

			FreeTracks (oldpatt.Notes, oldpatt.Lines, oldpatt.Tracks);
			UpdatePattern();
		}
		else
		{
			memcpy (patt, &oldpatt, sizeof (struct Pattern));
			LastErr = ERROR_NO_FREE_STORE;
		}
	}
}



static void PattSizeDoubleTClicked (void)
{
}

static void PattSizeHalveTClicked (void)
{
}



static void PattSizeOKClicked (void)
{
	ClosePattSizeWindow();
}



static void PattSizeCancelClicked (void)
{
	if (OldPatt.Tracks)
	{
		struct Pattern *patt = &songinfo->PattData[OldPattNum];
		UWORD i;

		/* Restore original pattern */

		FreeTracks (patt->Notes, patt->Lines, patt->Tracks);

		patt->Lines		= OldPatt.Lines;
		patt->Tracks	= OldPatt.Tracks;

		for (i = 0; i < patt->Tracks; i++)
			patt->Notes[i] = OldPatt.Notes[i];

		memset (&OldPatt, 0, sizeof (OldPatt));
	}

	UpdatePattern();

	ClosePattSizeWindow();
}

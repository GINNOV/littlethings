/*
**	SequenceWin.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Sequence editor handling functions.
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



/* Gadget IDs */

enum
{
	GD_SeqList,
	GD_PattAdd,
	GD_PattDel,
	GD_PattUp,
	GD_PattDown,
	GD_PattName,
	GD_PattList,
	GD_SeqDel,
	GD_SeqUp,
	GD_SeqDown,
	GD_SeqInsert,
	Sequence_CNT
};



/* Local function prototypes */

static void SeqListClicked (void);
static void PattAddClicked (void);
static void PattDelClicked (void);
static void PattUpClicked (void);
static void PattDownClicked (void);
static void PattNameClicked (void);
static void PattListClicked (void);
static void SeqDelClicked (void);
static void SeqUpClicked (void);
static void SeqDownClicked (void);
static void SeqInsertClicked (void);


struct Gadget	*SequenceGadgets[Sequence_CNT];
struct List		 SequenceList;
struct List		 PatternsList;
static ULONG	 SequenceSecs = 0, SequenceMicros = 0;
static ULONG	 PatternSecs = 0, PatternMicros = 0;



UWORD SequenceGTypes[] = {
	LISTVIEW_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	STRING_KIND,
	LISTVIEW_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND
};

struct NewGadget SequenceNGad[] = {
	91, 62, 229, 64, (UBYTE *)"Sequence", NULL, GD_SeqList, PLACETEXT_LEFT|NG_HIGHLABEL, NULL, (APTR)SeqListClicked,
	324, 1, 65, 12, (UBYTE *)"_Add", NULL, GD_PattAdd, PLACETEXT_IN, NULL, (APTR)PattAddClicked,
	324, 15, 65, 12, (UBYTE *)"Del", NULL, GD_PattDel, PLACETEXT_IN, NULL, (APTR)PattDelClicked,
	324, 29, 65, 12, (UBYTE *)"Up", NULL, GD_PattUp, PLACETEXT_IN, NULL, (APTR)PattUpClicked,
	324, 43, 65, 12, (UBYTE *)"Down", NULL, GD_PattDown, PLACETEXT_IN, NULL, (APTR)PattDownClicked,
	91, 45, 229, 14, (UBYTE *)"Name", NULL, GD_PattName, PLACETEXT_LEFT, NULL, (APTR)PattNameClicked,
	91, 1, 229, 48, (UBYTE *)"Patterns", NULL, GD_PattList, PLACETEXT_LEFT|NG_HIGHLABEL, NULL, (APTR)PattListClicked,
	324, 76, 65, 12, (UBYTE *)"Del", NULL, GD_SeqDel, PLACETEXT_IN, NULL, (APTR)SeqDelClicked,
	324, 90, 65, 12, (UBYTE *)"_Up", NULL, GD_SeqUp, PLACETEXT_IN, NULL, (APTR)SeqUpClicked,
	324, 104, 65, 12, (UBYTE *)"_Down", NULL, GD_SeqDown, PLACETEXT_IN, NULL, (APTR)SeqDownClicked,
	324, 62, 65, 12, (UBYTE *)"_Ins", NULL, GD_SeqInsert, PLACETEXT_IN, NULL, (APTR)SeqInsertClicked
};


ULONG SequenceGTags[] = {
	(GTLV_ShowSelected), NULL, TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	GTST_MaxChars, MAXPATTNAME-1, TAG_DONE,
	GTLV_ShowSelected, NULL, TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE
};


struct WinUserData SequenceWUD =
{
	{ NULL, NULL },
	NULL,
	SequenceGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	NULL,
	CloseSequenceWindow,
	NULL,
	NULL,
	NULL,

	{ 124, 24, 392, 124 },
	NULL,
	SequenceGTypes,
	SequenceNGad,
	SequenceGTags,
	Sequence_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE,
	BUTTONIDCMP|LISTVIEWIDCMP|IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW,
	"Sequence Editor"
};



LONG OpenSequenceWindow (void)
{
	struct Window *win;

	if (win = MyOpenWindow (&SequenceWUD))
		UpdatePatternList();

	return (!win);
}



void CloseSequenceWindow (void)
{
	if (SequenceWUD.Win)
	{
		MyCloseWindow (SequenceWUD.Win);

		while (!IsListEmpty (&SequenceList))
			RemListViewNode (SequenceList.lh_Head);

		while (!IsListEmpty (&PatternsList))
			RemListViewNode (PatternsList.lh_Head);
	}
}



/**********************/
/* Sequence Functions */
/**********************/

void UpdateSequenceList (void)
{
	ULONG i;
	UWORD pos;

	if (songinfo)
		if (songinfo->CurrentPos >= songinfo->Length)
			songinfo->CurrentPos = songinfo->Length - 1;

	if (!SequenceWUD.Win) return;

	GT_SetGadgetAttrs (SequenceGadgets[GD_SeqList], SequenceWUD.Win, NULL,
		GTLV_Labels, ~0,
		TAG_DONE);

	while (!IsListEmpty (&SequenceList))
		RemListViewNode (SequenceList.lh_Head);

	if (songinfo)
		for (i = 0 ; i < songinfo->Length; i++)
		{
			pos = songinfo->Sequence[i];
			AddListViewNode (&SequenceList, "%03lu - %03ld %s", i, pos,
				(pos >= songinfo->NumPatterns) ? (STRPTR)"--none--" : songinfo->PattData[pos].PattName);
		}

	GT_SetGadgetAttrs (SequenceGadgets[GD_SeqList], SequenceWUD.Win, NULL,
		GTLV_Labels, &SequenceList,
		GTLV_Selected, songinfo ? songinfo->CurrentPos : ~0,
		GTLV_MakeVisible, songinfo ? songinfo->CurrentPos : 0,
		TAG_DONE);
}



void UpdatePatternList (void)
{
	ULONG i;
	struct Pattern *patt;

	if (songinfo)
		if (songinfo->CurrentPatt >= songinfo->NumPatterns)
			songinfo->CurrentPatt = 0;

	if (SequenceWUD.Win)
	{

		GT_SetGadgetAttrs (SequenceGadgets[GD_PattList], SequenceWUD.Win, NULL,
			GTLV_Labels, ~0,
			TAG_DONE);

		while (!IsListEmpty (&PatternsList))
			RemListViewNode (PatternsList.lh_Head);


		if (songinfo)
		{
			for (i = 0 ; i < songinfo->NumPatterns; i++)
			{
				patt = &songinfo->PattData[i];

				AddListViewNode (&PatternsList, "%03lu (%lu,%lu) %s",
					i, patt->Tracks, patt->Lines,
					patt->PattName[0] ? patt->PattName : (STRPTR) "--unnamed--");
			}

			GT_SetGadgetAttrs (SequenceGadgets[GD_PattName], SequenceWUD.Win, NULL,
				GTST_String, songinfo->NumPatterns ? songinfo->PattData[songinfo->CurrentPatt].PattName : NULL,
				TAG_DONE);
		}

		GT_SetGadgetAttrs (SequenceGadgets[GD_PattList], SequenceWUD.Win, NULL,
			GTLV_Labels, &PatternsList,
			GTLV_Selected, songinfo ? songinfo->CurrentPatt : ~0,
			GTLV_MakeVisible, songinfo ? songinfo->CurrentPatt : ~0,
			TAG_DONE);

		UpdateSequenceList();
	}

	UpdatePattern();
}



/********************/
/* Sequence Gadgets */
/********************/

static void SeqListClicked (void)
{
	if (IntuiMsg.Code == songinfo->CurrentPos)
	{
		/* Check Double Click */
		if (DoubleClick (SequenceSecs, SequenceMicros, IntuiMsg.Seconds, IntuiMsg.Micros))
		{
			songinfo->Sequence[songinfo->CurrentPos] = songinfo->CurrentPatt;
			UpdateSequenceList();
		}
	}
	SequenceSecs = IntuiMsg.Seconds;
	SequenceMicros = IntuiMsg.Micros;

	songinfo->CurrentPos = IntuiMsg.Code;
}



static void PattAddClicked (void)
{
	struct Pattern *newpatt;

	if (!songinfo) return;

	if (songinfo->NumPatterns >= MAXPATTERNS)
	{
		DisplayBeep (Scr);
		return;
	}

	newpatt = &(songinfo->PattData[songinfo->NumPatterns]);

	newpatt->Lines = songinfo->PattData[songinfo->CurrentPatt].Lines;
	newpatt->Tracks = songinfo->MaxTracks;
	newpatt->PattName[0] = '\0';
	if (!AllocTracks (newpatt->Notes, newpatt->Lines, newpatt->Tracks))
	{
		songinfo->CurrentPatt = songinfo->NumPatterns;
		songinfo->NumPatterns++;
		UpdateSongInfo();	/* this also calls UpdatePatternList() */
	}
}



static void PattDelClicked (void)
{
	struct Pattern *patt = &songinfo->PattData[songinfo->CurrentPatt];

	if (!songinfo) return;

	if (songinfo->NumPatterns <= 1)
	{
		DisplayBeep (Scr);
		return;
	}

	FreeTracks (patt->Notes, patt->Lines, patt->Tracks);
	RemovePattern (songinfo, songinfo->CurrentPatt, 0);

	UpdateSongInfo();
}



static void PattUpClicked (void)
{
	if (songinfo)
	{
		if (songinfo->CurrentPatt == 0)
			DisplayBeep (Scr);
		else
		{
			struct Pattern
				*patt1 = &songinfo->PattData[songinfo->CurrentPatt],
				*patt2 = &songinfo->PattData[songinfo->CurrentPatt - 1],
				tmp_patt;

			/* Swap pattern with its predecessor */
			memcpy (&tmp_patt, patt1, sizeof (struct Pattern));
			memcpy (patt1, patt2, sizeof (struct Pattern));
			memcpy (patt2, &tmp_patt, sizeof (struct Pattern));

			songinfo->CurrentPatt--;
			UpdatePatternList();
		}
	}
}

static void PattDownClicked (void)
{
	if (songinfo)
	{
		if (songinfo->CurrentPatt >= songinfo->NumPatterns - 1)
			DisplayBeep (Scr);
		else
		{
			struct Pattern
				*patt1 = &songinfo->PattData[songinfo->CurrentPatt],
				*patt2 = &songinfo->PattData[songinfo->CurrentPatt + 1],
				tmp_patt;

			/* Swap pattern with its predecessor */
			memcpy (&tmp_patt, patt1, sizeof (struct Pattern));
			memcpy (patt1, patt2, sizeof (struct Pattern));
			memcpy (patt2, &tmp_patt, sizeof (struct Pattern));

			songinfo->CurrentPatt++;
			UpdatePatternList();
		}
	}
}

static void PattNameClicked (void)
{
	if (!songinfo) return;

	strncpy (songinfo->PattData[songinfo->CurrentPatt].PattName,
		GetString (SequenceGadgets[GD_PattName]), MAXPATTNAME-1);
	UpdatePatternList();
}



static void PattListClicked (void)
{
	if (IntuiMsg.Code == songinfo->CurrentPatt)
	{
		/* Check Double Click */
		if (DoubleClick (PatternSecs, PatternMicros, IntuiMsg.Seconds, IntuiMsg.Micros))
			OpenPatternWindow();
	}
	else
	{
		songinfo->CurrentPatt = IntuiMsg.Code;

		GT_SetGadgetAttrs (SequenceGadgets[GD_PattName], SequenceWUD.Win, NULL,
			GTST_String, songinfo->PattData[songinfo->CurrentPatt].PattName,
			TAG_DONE);

		UpdatePattern();
	}

	PatternSecs = IntuiMsg.Seconds;
	PatternMicros = IntuiMsg.Micros;
}



static void SeqDelClicked (void)
{
	ULONG i;

	if (!songinfo) return;

	/* You can't have a null sequence */
	if (songinfo->Length == 1)
	{
		DisplayBeep (Scr);
		return;
	}

	/* Shift positions back */
	for (i = songinfo->CurrentPos ; i < songinfo->Length; i++)
		songinfo->Sequence[i] = songinfo->Sequence[i+1];

	if (songinfo->CurrentPos > songinfo->Length)
		songinfo->CurrentPos--;

	SetSongLen (songinfo, songinfo->Length - 1);

	UpdateSongInfo();	/* Will call also UpdateSequenceList() */
}



static void SeqUpClicked (void)
{
	UWORD temp;

	if (!songinfo) return;

	if (songinfo->CurrentPos < 1) return;

	temp = songinfo->Sequence[songinfo->CurrentPos];
	songinfo->Sequence[songinfo->CurrentPos] = songinfo->Sequence[songinfo->CurrentPos - 1];
	songinfo->Sequence[songinfo->CurrentPos - 1] = temp;

	songinfo->CurrentPos--;
	UpdateSequenceList();
}



static void SeqDownClicked (void)
{
	UWORD temp;

	if (!songinfo) return;

	if (songinfo->CurrentPos >= songinfo->Length - 1)
		return;

	temp = songinfo->Sequence[songinfo->CurrentPos];
	songinfo->Sequence[songinfo->CurrentPos] = songinfo->Sequence[songinfo->CurrentPos + 1];
	songinfo->Sequence[songinfo->CurrentPos + 1] = temp;

	songinfo->CurrentPos++;
	UpdateSequenceList();
}



static void SeqInsertClicked (void)
{
	ULONG i;

	if (!songinfo) return;

	if (songinfo->Length >= MAXPOSITIONS)
	{
		DisplayBeep (Scr);
		return;
	}

	if (!(SetSongLen (songinfo, songinfo->Length + 1)))
	{
		DisplayBeep (Scr);
		return;
	}

	for (i = songinfo->Length - 1; i > songinfo->CurrentPos; i--)
		songinfo->Sequence[i] = songinfo->Sequence[i-1];

	songinfo->Sequence[songinfo->CurrentPos] = songinfo->CurrentPatt;

	UpdateSongInfo();	/* This will update the sequence list too */
}

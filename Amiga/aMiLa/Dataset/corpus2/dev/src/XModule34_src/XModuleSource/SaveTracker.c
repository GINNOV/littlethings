/*
**	SaveTracker.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Save internal structures to a SoundTracker module with 15 instruments
**	or to a 31 instruments Noise/ProTracker unpacked module.
*/

#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>

#include "XModule.h"
#include "Gui.h"
#include "TrackerID.h"


/* Local function prototypes */
static void	BreakPattern	(struct Note **arr, UWORD rows, UWORD tracks);
static void SetGlobalSpeed (struct SongInfo *si, UWORD tracks);
static LONG	ResizePatterns	(struct SongInfo *si);


const ULONG TakeTrackerIDs[32] =
{
	'TDZ1', 'TDZ2',	'TDZ3', 'TDZ4',
	'5CHN', '6CHN', '7CHN', '8CHN',
	'9CHN', '10CH', '11CH', '12CH',
	'13CH', '14CH', '15CH', '16CH',
	'17CH', '18CH', '19CH', '20CH',
	'21CH', '22CH', '23CH', '24CH',
	'25CH', '26CH', '27CH', '28CH',
	'29CH', '30CH', '31CH', '32CH'
};


LONG SaveTracker (struct SongInfo *si, BPTR fs, UWORD st_type)
{
	struct Instrument *inst = si->Inst;
	ULONG	l;
	ULONG	pattcount = 0, maxnumpatt = 64, numtracks = 4, songlength;
	ULONG	i, j, k;			/* Loop counters */
	UWORD	w;
	UBYTE c;
	struct { UWORD Note; UBYTE InstEff; UBYTE EffVal; }
		strow; /* Temporary storage for a SoundTracker row */


	if (GuiSwitches.Verbose)
	{
		if (si->MaxTracks == 4)
			ShowMessage (MSG_SAVING_TRACKER);
		else
			ShowMessage (MSG_SAVING_TAKETRACKER, si->MaxTracks);
	}

	/* Adapt module to #?Tracker peculiarities... */
	ResizePatterns (si);


	/* Calculate pattcount */

	songlength = min (si->Length, 128);

	for (i = 0 ; i < songlength ; i++)
		if (si->Sequence[i] > pattcount)
			pattcount = si->Sequence[i];

	pattcount++;	/* Pattern numbering starts from 0 */

	if (pattcount < si->NumPatterns)
		ShowMessage (MSG_SOME_PATTS_NOT_SAVED);


	/* Write Song name */
	if (Write (fs, si->SongName, 20) != 20) return ERR_READWRITE;


	/* Write instruments name, length, volume, repeat, replen */

	DisplayAction (MSG_WRITING_INSTINFO);

	for ( j = 1 ; j < (st_type == FMT_STRACKER ? 16 : 32) ; j++ )
	{
		UBYTE namebuf[22];

		/* Some Trackers require the instrument buffer to be
		 * padded with 0's.
		 */
		memset (namebuf, 0, 22);
		strncpy (namebuf, inst[j].Name, 22);

		/* Put Instrument name (22 chars) */
		if (Write (fs, namebuf, 22) != 22) return ERR_READWRITE;

		/* Put Length/2 (WORD) */

		/* SoundTracker cannot handle instruments longer than 64K */
		if (inst[j].Length > 0xFFFE)
		{
			w = 0x7FFF;
			ShowMessage (MSG_INSTR_TOO_LONG, j);
 		}
		else w = inst[j].Length >> 1;

		if (!inst[j].SampleData) w = 0;

		if (Write (fs, &w, 2) != 2) return ERR_READWRITE;

		/* Put Volume (WORD) */
		w = inst[j].Volume | ((inst[j].FineTune & 0x0F) << 8);
		if (Write (fs, &w, 2) != 2) return ERR_READWRITE;

		/* Put Repeat */
		w = inst[j].Repeat >> 1;
		if (Write (fs, &w, 2) != 2) return ERR_READWRITE;

		/* Put Replen/2 */
		w = inst[j].Replen >> 1;
		if (w == 0) w = 1;
		if (Write (fs, &w, 2) != 2) return ERR_READWRITE;
	}


	/******************************************/
	/* Put number of positions in song (BYTE) */
	/******************************************/

	c = songlength;
	if (Write (fs, &c, 1) != 1) return ERR_READWRITE;


	/*****************************************/
	/* Put number of patterns in song (BYTE) */
	/*****************************************/

	switch (st_type)
	{
		case FMT_STRACKER:
			/* SoundTracker stores the number of patterns here */
			c = pattcount;
			break;

		case FMT_STARTREKKER:
			/* StarTrekker modules store restart value here */
			c = si->Restart;
			break;

		default:
			/* Noise/ProTracker stores $7F as the number of patterns.
			 * The correct number of patterns is calculated by looking
			 * for the highest pattern referenced in the position table.
			 * Therefore, unused patterns MUST be removed, or the Tracker
			 * will get confused loading the module.
			 */
			c = 0x7F;
			break;
	}

	if (Write (fs, &c, 1) != 1) return ERR_READWRITE;


	/********************/
	/* Choose module ID */
	/********************/

	switch (st_type)
	{
		case FMT_STRACKER:
			l = 0;
			break;

		case FMT_PTRACKER:
			if (pattcount > 64)
			{
				l = ID_PROTRACKER100;
				maxnumpatt = 100;
				ShowMessage (MSG_EXCEEDS_64_PATTS);
			}
			else l = ID_PROTRACKER;
			break;

		case FMT_NTRACKER:
			l = ID_NOISETRACKER;
			break;

		case FMT_STARTREKKER:
			l = ID_STARTREKKER4;
			break;

		case FMT_TAKETRACKER:
			numtracks = si->MaxTracks;
			l = TakeTrackerIDs[si->MaxTracks - 1];
			maxnumpatt = 100;
			break;

		default:
			l = ID_PROTRACKER;
			break;
	}

	if (pattcount >= maxnumpatt)
	{
		pattcount = maxnumpatt;
		ShowMessage (MSG_EXCEEDS_MAXPAATTS, maxnumpatt);
	}


	/************************/
	/* Write position table */
	/************************/
	{
		UBYTE postable[128];

		memset (postable, 0, 128);

		/* All this thing must be done because ProTracker has serious
		 * problems dealing with modules whose postable has references
		 * to inexistent patterns.
		 */
		for (i = 0; i < songlength; i++)
		{
			postable[i] = si->Sequence[i];

			if (postable[i] >= pattcount)
				postable[i] = 0;
		}

		if (Write (fs, postable, 128) != 128) return ERR_READWRITE;
	}


	/*******************/
	/* Write module ID */
	/*******************/

	if (l)
		if (Write (fs, &l, 4) != 4) return ERR_READWRITE;



	/**********************/
	/* Write pattern data */
	/**********************/

	SetGlobalSpeed (si, numtracks);

	DisplayAction (MSG_WRITING_PATTS);

	for (i = 0 ; i < pattcount ; i++)
	{
		struct Note **pn = si->PattData[i].Notes;

		if (DisplayProgress (i, pattcount))
			return ERROR_BREAK;

		for (j = 0 ; j < 0x40 ; j++)
		{
			for (k = 0 ; k < numtracks ; k++)
			{
				/* Translate Note */
				strow.Note = TrackerNotes[pn[k][j].Note];

				/* Translate instr # (high nibble) & effect (low nibble) */
				c = pn[k][j].Inst;

				if (c > 0x0F && st_type != FMT_STRACKER)
				{
					/* Noise/ProTracker stores the high bit of the
					 * instrument number in bit 15 of the note value.
					 */
					strow.Note |= 0x1000;
				}

				strow.InstEff = (c<<4) | Effects[pn[k][j].EffNum][0];

				/* Copy effect value */
				strow.EffVal = pn[k][j].EffVal;

				/* Write the Row */
				if (Write (fs, &strow, 4) != 4) return ERR_READWRITE;
			}
		}
	}


	/********************/
	/* Save Instruments */
	/********************/

	DisplayAction (MSG_WRITING_INSTDATA);

	for (i = 1 ; i < (st_type == FMT_STRACKER ? 16 : 32) ; i++)
	{
		ULONG len = inst[i].Length & (~1);

		/* Adapt instrument to SoundTracker 64K limit */
		if (len > 0xFFFE) len = 0xFFFE;

		if (DisplayProgress(i, st_type == FMT_STRACKER ? 16 : 32))
			return ERROR_BREAK;

		if ((inst[i].Length == 0) || (!inst[i].SampleData))
			continue;

		if (Write (fs, inst[i].SampleData, len) != len)
			return(ERR_READWRITE);
	}

	return (0);
}



static void BreakPattern (struct Note **arr, UWORD row, UWORD tracks)

/* Put a break command at the end of a pattern */
{
	ULONG i;

	/* Try to find a free effect slot in the row... */
	for (i = 0 ; i < tracks ; i++)
		if (arr[i][row].EffNum == 0 && arr[i][row].EffVal == 0)
			break;

	if (i == tracks) i = 0;

	arr[i][row].EffNum = EFF_PATTERNBREAK; /* ...and break the pattern */
	arr[i][row].EffNum = 0;
}



static void SetGlobalSpeed (struct SongInfo *si, UWORD tracks)

/* Put a speed command ($F) at the first line played in the song */
{
	struct Pattern *patt = &si->PattData[si->Sequence[0]];
	struct Note **pn = patt->Notes;
	ULONG i;

	tracks = min (tracks, patt->Tracks);

	/* Do it only if required */
	if (si->GlobalSpeed != DEF_SONGSPEED)
	{
		/* Ensure a SetSpeed command does not exist yet in the first row... */
		for (i = 0 ; i < tracks ; i++)
			if (pn[i][0].EffNum == EFF_SETSPEED)
				goto settempo;	/* Speed is already set, now for the Tempo... */

		/* Try to find a free effect slot in the row... */
		for (i = 0 ; i < tracks ; i++)
			if (pn[i][0].EffNum == EFF_NULL && pn[i][0].EffVal == 0)
					break;

		pn[i][0].EffNum = EFF_SETSPEED;
		pn[i][0].EffVal = si->GlobalSpeed;
	}

settempo:
	if (si->GlobalTempo != DEF_SONGTEMPO)
	{
		/* Ensure a SetTempo command does not exist yet in the first row... */
		for (i = 0 ; i < tracks ; i++)
			if (pn[i][0].EffNum == EFF_SETTEMPO)
				return;	/* Tempo is already set, nothing else to do... */

		/* Try to find a free effect slot in the row... */
		for (i = 0 ; i < tracks ; i++)
			if (pn[i][0].EffNum == 0 && pn[i][0].EffVal == 0)
				break;

		pn[i][0].EffNum = EFF_SETTEMPO;
		pn[i][0].EffVal = si->GlobalTempo;
	}
}



static LONG ResizePatterns (struct SongInfo *si)

/* Find out what patterns are not exactly 64 notes long and either break
 * them (<64) or split them in two shorter ones (>64).  Pattern
 * splitting will automatically recurse when more than one split is
 * needed (>128).
 *
 * This function returns 0 to mean succes, any other value means failure.
 *
 * Note: This function is a bit messy, but should work all right ;-)
 */
{
	struct Note		*newpatt[MAXTRACKS], *newpatt2[MAXTRACKS];
	struct Pattern	*pd;
	ULONG i, j;
	UWORD len;
	BOOL do_update = FALSE;

	for (i = 0 ; i < si->NumPatterns ; i++)
	{
		pd = &si->PattData[i];

		if ((len = pd->Lines) != 0x40) /* Is the pattern length standard? */
		{
			/* Remember to update GUI later */
			do_update = TRUE;

			/* Reallocate pattern */
			if (AllocTracks (newpatt, 0x40, si->MaxTracks))
				return ERROR_NO_FREE_STORE;

			if (len < 0x40)
			{
				/* BREAK PATTERN */
				if (GuiSwitches.Verbose)
					ShowMessage (MSG_PATT_WILL_GROW, i, len);

				/* Copy the old notes in the new (longer) pattern */
				for (j = 0 ; j < si->MaxTracks ; j++)
					memcpy (newpatt[j], pd->Notes[j],
							(sizeof (struct Note)) * len);

				/* Break the $40 pattern */
				BreakPattern (newpatt, len-1, si->MaxTracks);

				/* Free old pattern */
				FreeTracks (pd->Notes, len, si->MaxTracks);

				/* Substitute the new pattern in the song */
				for (j = 0 ; j < si->MaxTracks ; j++)
					pd->Notes[j] = newpatt[j];

				/* Update length */
				pd->Lines = 0x40;
			}
			else
			{
				/* SPLIT PATTERN */

				if (GuiSwitches.Verbose)
					ShowMessage (MSG_SPLITTING_PATT, i, len);

				/* Allocate memory for extra pattern */
				if (AllocTracks (newpatt2, len - 0x40, si->MaxTracks))
					return ERROR_NO_FREE_STORE;

				/* Copy first $40 rows of the pattern */
				for (j = 0 ; j < si->MaxTracks ; j++)
					memcpy (newpatt[j], pd->Notes[j],
							(sizeof (struct Note)) * 0x40);

				/* Copy the rest of the pattern */
				for (j = 0 ; j < si->MaxTracks ; j++)
					memcpy (newpatt2[j], pd->Notes[j] + 0x40,
							(sizeof (struct Note)) * (len-0x40));

				/* Free old pattern */
				FreeTracks (pd->Notes, len, si->MaxTracks);

				/* Make room for the new pattern */
				if (InsertPattern(si, i))
				{
					/* There are no more free pattern slots */
					FreeTracks (newpatt2, len-0x40, si->MaxTracks);
					continue;
				}

				/* Substitute the old pattern */
				for (j = 0 ; j < si->MaxTracks ; j++)
					pd->Notes[j] = newpatt[j];
				pd->Lines = 0x40; /* Update length */

				/* Insert the other part of the new pattern */
				for (j = 0 ; j < si->MaxTracks ; j++)
					si->PattData[i+1].Notes[j] = newpatt2[j];

				/* Set length for new pattern.  If len-64 is not exactly
				 * 64 lines, this pattern will be splitted/breaked
				 * once again in the next loop.
				 */
				si->PattData[i+1].Lines = len - 0x40;
			}
		}
	}	/* End for(i) */

	if (do_update)
		UpdateSongInfo();

	return 0;

}	/* End ResizePatterns */

/*
**	GetTracker.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Load a Sound/Noise/ProTracker module with 15 or 31 instruments, decode
**	it and store into internal structures.
*/

#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>

#include "XModule.h"
#include "Gui.h"
#include "TrackerID.h"


struct StRow
{
	UWORD Note;
	UBYTE InstEff;
	UBYTE EffVal;
};



/* Local function prototypes */

static __inline UWORD DecodeNote (UWORD Note, UWORD Patt, UWORD Line, UWORD Track);
static __inline UBYTE DecodeEff (UBYTE eff, UBYTE effval);



LONG GetTracker (struct SongInfo *si, BPTR fp, UWORD st_type)
{
	struct Note *note;
	struct Instrument	*inst = si->Inst;
	struct Pattern		*patt;
	struct StRow		*stpatt,	/* Temporary storage for a Tracker pattern */
						*strow;
	STRPTR typename;
	ULONG i, j, k;		/* Loop counters */
	ULONG pattsize;
	UWORD numtracks = 4, numpatterns, songlen;
	UWORD w; UBYTE c;	/* Read buffers */


	/* Get the score name */

	if (Read (fp, si->SongName, 20) != 20) return ERR_READWRITE;
	si->SongName[20] = '\0'; /* Ensure the string is Null-terminated */


	/* Get the Instruments name, length, cycle, effects */

	DisplayAction (MSG_READING_INSTS_INFO);

	for ( j = 1 ; j < (st_type == FMT_STRACKER ? 16 : 32); j++ )
	{
		/* Read instrument name  */
		if (Read (fp, inst[j].Name, 22) != 22) return ERR_READWRITE;
		inst[j].Name[22] = '\0'; /* Ensure the string is Null-terminated */

		/* Get the length */
		if (Read (fp, &w, 2) != 2) return ERR_READWRITE;
		inst[j].Length = ((ULONG)w)<<1;

		/* Get FineTune & Volume */
		if (Read (fp, &w, 2) != 2) return ERR_READWRITE;
		inst[j].Volume = w & 0x00FF;
		w = (w >> 8) & 0x0F;	/* Get Low nibble of high byte */
		inst[j].FineTune = (w & 0x08 ? (w | 0xFFF0) : w);	/* Fix sign */

		/* Get Repeat Start */
		if (Read (fp, &w, 2) != 2) return ERR_READWRITE;
		inst[j].Repeat = ((ULONG)w) << 1;

		/* Get RepLen */
		if (Read (fp, &w, 2) != 2) return ERR_READWRITE;
		if (w == 1) w = 0;
		inst[j].Replen = ((ULONG)w)<<1;
	}

	GuessAuthor(si);


	/* Read song length */

	if (Read (fp, &c, 1) != 1) return ERR_READWRITE;
	songlen = c;

	/* Read & Ignore number of song patterns.
	 *
	 * Noise/ProTracker stores $7F as the number of patterns.
	 * The correct number of patterns is calculated by looking
	 * for the highest pattern referenced in the position table.
	 * The OctaMED saver wrongly puts the number of patterns
	 * when saving as a ProTracker module.
	 * SoundTracker should save the correct number of patterns,
	 * but some 15 instrument modules I found had incorrect
	 * values here.  So we always ignore this field.
	 */
	if (Read (fp, &c, 1) != 1) return ERR_READWRITE;


	/* Read the song sequence */
	{
		UBYTE postable[128];

		if (Read (fp, postable, 128) != 128) return ERR_READWRITE;

		if (!(SetSongLen (si, songlen)))
			return ERROR_NO_FREE_STORE;

		for (i = 0; i < si->Length; i++)
			si->Sequence[i] = postable[i];
	}

	/* Search for the highest pattern referenced in the
	 * position table to find out the actual number of patterns.
	 */

	numpatterns = 0;

	for (i = 0 ; i < si->Length ; i++)
		if (si->Sequence[i] > numpatterns)
			numpatterns = si->Sequence[i];

	numpatterns++;	/* Pattern numbering starts from 0 */


	/* Check module ID */

	if (st_type != FMT_STRACKER)
	{
		ULONG __aligned id;

		if (Read (fp, &id, 4) != 4) return ERR_READWRITE;

		switch (id)
		{
			case ID_PROTRACKER:
				typename = "ProTracker";
				break;

			case ID_PROTRACKER100:
				typename = "ProTracker 100 Patterns";
				break;

			case ID_NOISETRACKER:
				typename = "NoiseTracker";
				break;

			case ID_STARTREKKER4:
				typename = "StarTrekker";
				break;

			case ID_STARTREKKER8:
				typename = "StarTrekker 8Ch";
				break;

			case ID_UNICTRACKER:
				typename = "UnicTracker";
				break;

			default:

				for (i = 0; i < 32; i++)
				{
					if (id == TakeTrackerIDs[i])
					{
						if (id == '6CHN' || id == '8CHN')
							typename = "FastTracker";
						else
							typename = "TakeTracker";

						numtracks = i+1;
						break;
					}
				}

				if (i < 32) break;

				/* The module ID could have been stripped away in modules
				 * coming from games and intros to make the module harder
				 * to rip, therefore the absence of the id is acceptable.
				 */
				typename = "Invalid ID";
				break;
		}
	}
	else typename = "SoundTracker 15 instruments";


	if (GuiSwitches.Verbose)
	{
		if (numtracks == 4)
			ShowMessage (MSG_READING_TYPE_MODULE, typename);
		else
			ShowMessage (MSG_READING_TYPE_MODULE_CHN, typename, numtracks);
	}

	/* Allocate memory for a full SoundTracker pattern */

	si->MaxTracks = numtracks;
	pattsize = (sizeof (struct StRow) * 0x40) * numtracks;

	if (!(stpatt = AllocMem (pattsize, 0)))
		return ERROR_NO_FREE_STORE;


	/* Read pattern data */

	DisplayAction (MSG_READING_PATTS);

	for (i = 0; i < numpatterns; i++)
	{
		if (DisplayProgress (i, numpatterns))
		{
			FreeMem (stpatt, pattsize);
			return ERROR_BREAK;
		}

		/* Read a whole Tracker row */
		if (Read (fp, stpatt, pattsize) != pattsize)
		{
			FreeMem (stpatt, pattsize);
			return ERR_READWRITE;
		}

		/* Reset note counter */
		strow = stpatt;

		/* Allocate memory for pattern */
		if (!(patt = AddPattern (si, numtracks, 64)))
		{
			FreeMem (stpatt, pattsize);
			return ERROR_NO_FREE_STORE;
		}

		for ( j = 0 ; j < 0x40 ; j++ )
		{
			for ( k = 0 ; k < numtracks ; k++, strow++ )
			{
				/* Get address of the current pattern row */
				note = &patt->Notes[k][j];

				/* Decode note (highest nibble is cleared) */
				note->Note = DecodeNote (strow->Note & 0xFFF, i, j, k);

				/* Decode instrument number (high nibble) */
				c = strow->InstEff >> 4; /* Get instrument nr. */
				if (st_type != FMT_STRACKER && (strow->Note & 0x1000))
					c |= 0x10;	/* High bit of Noise/ProTracker instrument */
				note->Inst = c;

				/* Decode effect (low nibble) */
				note->EffNum = DecodeEff (strow->InstEff & 0x0F, strow->EffVal);

				/* Copy effect value */
				note->EffVal = strow->EffVal;
			}
		}
	}

	FreeMem (stpatt, pattsize);


	/* Look for a SetSpeed command ($F) in the first row and
	 * set si->GlobalSpeed.  If Speed is higher than 31,
	 * si->GlobalTempo should be initialized instead.
	 */

	/* TODO */ si->GlobalSpeed = 6;
	/* TODO */ si->GlobalTempo = 125;

	/* Load Instruments */

	DisplayAction (MSG_READING_INSTS);

	for (j = 1 ; j < (st_type == FMT_STRACKER ? 16 : 32) ; j++)
	{
		/* Check if instrument exists */
		if (inst[j].Length == 0) continue;

		if (DisplayProgress (j, st_type == FMT_STRACKER ? 16 : 32))
			return ERROR_BREAK;

		if (!(inst[j].SampleData = (UBYTE *) AllocVec (inst[j].Length, MEMF_SAMPLE)))
			return ERROR_NO_FREE_STORE;

		if (Read (fp, inst[j].SampleData, inst[j].Length) != inst[j].Length)
		{
			FreeInstr (&inst[j]);

			/* Clear instrument lengths */
			for (i = j; i < MAXINSTRUMENTS; i++)
				inst[i].Length = 0;

			if (j == 0)
			{
				ShowMessage (MSG_SONG_HAS_NO_INSTS);

				return RETURN_WARN;	/* Tell 'em this is a damn song. */
			}

			return ERR_READWRITE;
		}
	}

	/* Check for extra data following the module */
	if (Read (fp, &c, 1) == 1)
		ShowMessage (MSG_EXTRA_DATA_AFTER_MOD);

	return RETURN_OK;
}



static __inline UWORD DecodeNote (UWORD Note, UWORD Patt, UWORD Line, UWORD Track)
{
	if (!Note) return 0;

	{
		UWORD n, mid, low = 1, high = MAXTABLENOTE - 1;

		/* The nice binary search learnt at school ;-) */
		do
		{
			mid = (low + high) >> 1;
			if ((n = TrackerNotes[mid]) > Note) low = mid+1;
			else if (n < Note) high = mid-1;
			else return (mid);
		} while (low <= high);
	}
	ShowMessage (MSG_INVALID_NOTE, Note, Patt, Track, Line);
	return 0;
}



static __inline UBYTE DecodeEff (UBYTE eff, UBYTE effval)
{
	UBYTE i;

	if (eff == 0 && effval)
		return (EFF_ARPEGGIO);

	if (eff == 0x0F) /* Speed */
	{
		if (effval < 0x20)
			return EFF_SETSPEED;
		else
			return EFF_SETTEMPO;
	}

	for ( i = 0 ; i < MAXTABLEEFFECTS ; i++ )
		if (eff == Effects[i][0])
			return i;

	return 0;
}



LONG IsTracker (BPTR fh)

/* Determine if the given file is a Star/Noise/ProTracker module.
 * Note: On exit the file position will have changed.
 */
{
	__aligned LONG id;
	ULONG i;

	Seek (fh, 1080, OFFSET_BEGINNING);
	if (Read (fh, &id, 4) != 4)
		return FMT_UNKNOWN;

	/* Check Noise/ProTracker */
	if (id == ID_NOISETRACKER || id == ID_PROTRACKER || id == ID_UNICTRACKER)
		return FMT_NTRACKER;

	/* Check for Multi/Fast Tracker */
	for (i = 0; i < 32; i++)
		if (id == TakeTrackerIDs[i])
			return FMT_TAKETRACKER;

	if ((id == ID_STARTREKKER4) || (id == ID_STARTREKKER8))
		return FMT_STARTREKKER;

	if (id == ID_PROTRACKER100)
		return FMT_PTRACKER;

	return FMT_UNKNOWN;
}

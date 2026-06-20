/*
**	Song.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Song handling functions.
*/

#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/icon_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/icon_pragmas.h>

#include "XModule.h"
#include "Gui.h"


/* Local function prototypes */
static WORD ModType (BPTR fh);



/* Load a module */

struct SongInfo *LoadModule (struct SongInfo *oldsong, const STRPTR filename)
{
	struct SongInfo *si;
	ULONG err;
	BPTR fh, compressed = 0;
	UWORD type;


	/* Open source file */
	if (!(fh = Open (filename, MODE_OLDFILE)))
	{
		UBYTE buf[FAULT_MAX];

		Fault (IoErr(), NULL, buf, 61);
		ShowMessage (MSG_ERR_LOAD, filename, buf);
		return NULL;
	}


	/* Check wether the file is compressed */

	if (type = CruncherType (fh))
	{
		Close (fh);

		if (compressed = DecompressFile (filename, type))
		{
			if (!(fh = OpenFromLock (compressed)))
			{
				UnLock (compressed);
				DecompressFileDone();
				return NULL;
			}
		}
		else
			return NULL;
	}
	else Seek (fh, 0, OFFSET_BEGINNING);

	/* Find out what the file format is */

	if ((type = ModType (fh)) == FMT_UNKNOWN)
	{
		Close (fh);
		if (compressed) DecompressFileDone ();
		return NULL;
	}

	Seek (fh, 0, OFFSET_BEGINNING);	/* Reset file */


	FreeSongInfo (oldsong);			/* Free old song... */
	if (!(si = AllocSongInfo()))	/* ...and allocate a new one. */
	{
		Close (fh);
		if (compressed) DecompressFileDone ();
		return NULL;
	}

	OpenProgressWindow();


	/* Set SongName & Path.
	 * File name will be replaced by the real song name if the
	 * load format supports embedded song names (e.g. SoundTracker).
	 */
	strcpy (si->SongPath, filename);
	strcpy (si->SongName, FilePart (filename));


	switch (type)
	{
		case FMT_XMODULE:
			err = GetXModule (si, fh);
			break;

		case FMT_NTRACKER:
			err = GetTracker (si, fh, FMT_NTRACKER);
			break;

		case FMT_PTRACKER:
			err = GetTracker (si, fh, FMT_PTRACKER);
			break;

		case FMT_STRACKER:
			err = GetTracker (si, fh, FMT_STRACKER);
			break;

		case FMT_OKTALYZER:
			err = GetOktalyzer (si, fh);
			break;

		case FMT_MED:
			err = GetMED (si, fh);
			break;

		case FMT_OCTAMED:
			err = GetMED (si, fh);
			break;

		case FMT_TAKETRACKER:
			err = GetTracker (si, fh, FMT_TAKETRACKER);
			break;

		case FMT_STARTREKKER:
			err = GetTracker (si, fh, FMT_STARTREKKER);
			break;

		case FMT_SCREAMTRACKER:
			err = GetS3M (si, fh);
			break;

		default:
			err = RETURN_FAIL;
			break;
	}


	if (err == ERR_READWRITE)
	{
		UBYTE buf[FAULT_MAX];

		if (err = IoErr())
			Fault (err, NULL, buf, FAULT_MAX);
		else
			strcpy (buf, STR(MSG_UNESPECTED_EOF));

		ShowMessage (MSG_ERROR_READING, FilePart (filename), buf);
	}


	Close (fh);

	FixSong (si);

	if (!err)
		if (GuiSwitches.Verbose) DisplayAction (MSG_MODULE_LOADED_OK);
	else
		LastErr = err;

	if (compressed) DecompressFileDone ();

	CloseProgressWindow();

	return si;
}



LONG SaveModule (struct SongInfo *si, const STRPTR filename, UWORD type)

/* Save a module to the specified file format */
{
	LONG err;
	BPTR fh;

	if (!(fh = Open (filename, MODE_NEWFILE)))
	{
		UBYTE buf[FAULT_MAX];

		Fault (IoErr(), NULL, buf, FAULT_MAX);
		ShowMessage (MSG_CANT_OPEN, filename, buf);

		return RETURN_FAIL;
	}

	OpenProgressWindow();

	switch (type)
	{
		case FMT_XMODULE:
			err = SaveXModule (si, fh);
			break;

		case FMT_NTRACKER:
			err = SaveTracker (si, fh, FMT_NTRACKER);
			break;

		case FMT_PTRACKER:
			err = SaveTracker (si, fh, FMT_PTRACKER);
			break;

		case FMT_STRACKER:
			err = SaveTracker (si, fh, FMT_STRACKER);
			break;

		case FMT_OKTALYZER:
			err = SaveOktalyzer (si, fh);
			break;

		case FMT_MED:
			err = SaveMED (si, fh, 0);
			break;

		case FMT_OCTAMED:
			err = SaveMED (si, fh, 1);
			break;

		case FMT_TAKETRACKER:
			err = SaveTracker (si, fh, FMT_TAKETRACKER);
			break;

		case FMT_SCREAMTRACKER:
			ShowString ("Sorry, ScreamTracker modules are not supported yet.", NULL);
			err = 20;
			break;

		case FMT_STARTREKKER:
			err = SaveTracker (si, fh, FMT_STARTREKKER);
			break;

		case FMT_MIDI:
			err = SaveMIDI (si, fh);
			break;

		case FMT_FASTTRACKER2:
			ShowString ("Sorry, FastTracker 2.0 modules are not supported yet.", NULL);
			err = 20;
			break;

		default:
			ShowMessage (MSG_UNKNOWN_SAVE_FORMAT);
			err = 20;
	}

	Close (fh);
	SetComment (filename, VERS " by Bernardo Innocenti");

	if (err)
	{
		/* Delete incomplete file */
		DeleteFile (filename);

		if (err == ERR_READWRITE)
		{
			UBYTE buf[FAULT_MAX];

			Fault (IoErr(), NULL, buf, FAULT_MAX);
			ShowMessage (MSG_ERROR_WRITING, filename, buf);

			err = 20;
		}
	}
	else
	{
		if (SaveSwitches.SaveIcons)
			PutIcon ("def_Module", filename);
		if (GuiSwitches.Verbose) DisplayAction (MSG_MODULE_SAVED_OK);
	}

	CloseProgressWindow();

	return err;
}



void FixSong (struct SongInfo *si)

/* Fixes dangerous errors in songs. */
{
	struct Instrument *inst = si->Inst;
	ULONG i;

	/* Check instruments */

	for (i = 1 ; i < MAXINSTRUMENTS ; i++)
	{
		/* Filter instrument names */
		FilterName (inst[i].Name);

		/* Some sensible sanity checks on loops :-) */

		if (inst[i].Repeat && (inst[i].Repeat >= inst[i].Length))
		{
			inst[i].Repeat = inst[i].Replen = 0;
			ShowMessage (MSG_INVALID_LOOP_REMOVED, i);
		}
		else if (inst[i].Repeat + inst[i].Replen > inst[i].Length)
		{
			inst[i].Replen = inst[i].Length - inst[i].Repeat;
			ShowMessage (MSG_INVALID_LOOP_FIXED, i);
		}
	}

	/* Check patterns */
	for (i = 0; i < si->NumPatterns; i++)
		FilterName (si->PattData[i].PattName);

	/* Can't have a song with no patterns!!! */
	if (si->NumPatterns == 0)
	{
		ShowMessage (MSG_SONG_HAS_NO_PATTS);
		AddPattern (si, si->MaxTracks, DEF_PATTLEN);
	}

	/* Better force a song to a minimum lenght of 1. */
	if (si->Length == 0)
	{
		ShowMessage (MSG_SONG_HAS_NO_SEQ);
		SetSongLen (si, 1);
	}

	/* Check sequence */
	for (i = 0; i < si->Length; i++)
	{
		if (si->Sequence[i] >= si->NumPatterns)
		{
			if (GuiSwitches.Verbose)
				ShowMessage (MSG_INVALID_SONG_POS, i, si->Sequence[i]);
			si->Sequence[i] = si->NumPatterns - 1;
		}
	}

	FilterName (si->SongName);
	FilterName (si->Author);
}



static WORD ModType (BPTR fh)

/* Guess source module type */
{
	UBYTE __aligned str[0x30];
	WORD trackertype;

	if (Read (fh, str, 0x30) != 0x30)
		return -1;

	/* Check XModule */
	if (!(strncmp (str, "FORM", 4) || strncmp (str+8, "XMOD", 4)))
		return FMT_XMODULE;

	/* Check MED */
	if (!(strncmp (str, "MMD", 3)))
		return FMT_MED;

	/* Check Oktalyzer */
	if (!(strncmp (str, "OKTASONG", 8)))
		return FMT_OKTALYZER;

	if (!(strncmp (&str[0x2C], "SCRM", 4)))
		return FMT_SCREAMTRACKER;

	if (!(strncmp (str, "Extended module: ", 17)))
		return FMT_FASTTRACKER2;

	/* Check #?Tracker */
	if ((trackertype = IsTracker (fh)) != FMT_UNKNOWN)
		return trackertype;

	switch (ShowRequestArgs (MSG_UNKNOWN_MOD_FORMAT, MSG_SOUND_PRO_CANCEL, NULL))
	{
		case 1:
			return FMT_STRACKER;
			break;

		case 2:
			return FMT_PTRACKER;
			break;

		default:
			break;
	}

	return FMT_UNKNOWN;
}



#define tolower(c) ((c) | (1<<5))

void GuessAuthor (struct SongInfo *si)

/* Try to find the author of the song looking up the instrument names */
{
	struct Instrument *in = si->Inst;
	UBYTE *name;
	ULONG i, j;

	for (i = 0; i < MAXINSTRUMENTS; i++, in++)
	{
		name = in->Name;

		/* Check for IntuiTracker-style author */
		if (name[0] == '#')
		{
			for (j = 1; name[j] == ' '; j++); /* Skip extra blanks */

			/* Skip "by " */
			if ((tolower(name[j]) == 'b') && (tolower(name[j+1]) == 'y') && name[j+2] == ' ')
				j += 3;

			for (; name[j] == ' '; j++); /* Skip extra blanks */

			if (name[j])
			{
				strncpy (si->Author, &(name[j]), MAXAUTHNAME); /* Copy author name */
				return; /* Stop looking for author */
			}
		}

		/* Now look for the occurence of "by ", "by:", "by\0" or "(c)".  Ignore case. */
		for (j = 0; name[j]; j++)
		{
			if (( (tolower(name[j]) == 'b') && (tolower(name[j+1]) == 'y') &&
				((name[j+2] == ' ') || (name[j+2] == ':') || (name[j+2] == '\0')) ) ||
				((name[j] == '(') && (tolower(name[j+1]) == 'c') && (name[j+2] == ')') ))
			{
				j+=3;	/* Skip 'by ' */

				/* Skip extra blanks/punctuations */
				while (name[j] == ' ' || name[j] == ':' || name[j] == '.') j++;

				if (name[j]) /* Check if the end is reached */
					/* The name of the author comes (hopefully) after the 'by ' */
					strncpy (si->Author, &(name[j]), MAXAUTHNAME); /* Copy author name */
				else
					/* The name of the author is stored in the next instrument */
					if (i < MAXINSTRUMENTS-1)
						strncpy (si->Author, (in+1)->Name, MAXAUTHNAME); /* Copy author name */

				return; /* Stop loop */
			}
		}
	}
}



UWORD *SetSongLen (struct SongInfo *si, ULONG len)

/* Allocates space for the song sequence table of the given length.
 *
 * If no sequence exists yet, a new one is allocated.
 * Increasing the song length may require the sequence
 * table to be expanded, in which case it will be
 * re-allocated.
 * Decreasing the song length could also cause a reallocation
 * of the sequence table if the size drops down enough.
 * Setting the length to 0 will free the sequence table and
 * return NULL.
 *
 * RESULT
 *	Pointer to the newly allocated sequence table or NULL for failure,
 *	in which case the previous sequence table is left untouched.
 */
{
	ULONG len_quantized;

	if (len == 0)
	{
		/* Deallocate sequence */

		FreeVecPooled (si->Pool, si->Sequence);
		si->Sequence = NULL;
		si->Length = 0;
		return NULL;
	}

	/* Check for too many song positions */

	if (len > MAXPOSITIONS)
		return NULL;


	len_quantized = (len + SEQUENCE_QUANTUM - 1) & ~(SEQUENCE_QUANTUM - 1);


	if (!si->Sequence)
	{
		/* Create a new sequence table */

		if (si->Sequence = AllocVecPooled (si->Pool,
			len_quantized * sizeof (UWORD)))
		{
			si->Length = len;
			memset (si->Sequence, 0, len * sizeof (UWORD));	/* Clear sequence table */
		}
		return si->Sequence;
	}

	if (si->Length > len_quantized)
	{
		UWORD *newseq;

		/* Shrink sequence table */

		si->Length = len;

		if (newseq = AllocVecPooled (si->Pool, len_quantized * sizeof (UWORD)))
		{
			CopyMem (si->Sequence, newseq, len * sizeof (UWORD));
			FreeVecPooled (si->Pool, si->Sequence);
			si->Sequence = newseq;
			return newseq;
		}

		/* If the previous allocation failed we ignore it and continue
		 * without shrinking the sequence table.
		 */
		return si->Sequence;
	}

	if (si->Length <= len_quantized - SEQUENCE_QUANTUM)
	{
		UWORD *newseq;

		/* Expand the sequence table */

		if (!(newseq = AllocVecPooled (si->Pool, len_quantized * sizeof (UWORD))))
			return NULL;

		/* Now replace the the old sequence with the new and delete the old one */

		CopyMem (si->Sequence, newseq, si->Length * sizeof (UWORD));
		FreeVecPooled (si->Pool, si->Sequence);

		/* Clear the new sequence table entries */
		memset (newseq + si->Length, 0, (len - si->Length) * sizeof (UWORD));
		si->Length = len;
		si->Sequence = newseq;
		return newseq;
	}

	/* No reallocation */

	if (si->Length > len)
		/* Clear the new sequence table entries */
		memset (si->Sequence + si->Length, 0, (si->Length - len) * sizeof (UWORD));

	si->Length = len;
	return si->Sequence;
}



struct SongInfo *AllocSongInfo (void)

/* Allocates and initializes a SongInfo structure.
 * Always check return code for NULL.
 */
{
	struct SongInfo	*si;
	ULONG i;

	if (!(si = CAllocPooled (Pool, sizeof (struct SongInfo))))
		return NULL;

	/* Initialize song information structure */
	si->Link.ln_Name	= si->SongName;
	si->MaxTracks		= DEF_NUMTRACKS;
	si->GlobalSpeed		= DEF_SONGSPEED;
	si->GlobalTempo		= DEF_SONGTEMPO;
	strcpy (si->Author, STR(MSG_AUTHOR_UNKNOWN));
	strcpy (si->SongName, STR(MSG_SONG_UNTITLED));
	strcpy (si->SongPath, si->SongName);
	si->Pool			= Pool;

	/* Initialize Active Tracks */
	for (i = 0 ; i < MAXTRACKS ; i++)
		si->ActiveTracks[i] = 1;

	return si;
}



struct SongInfo *NewSong (void)
{
	struct SongInfo *si;

	if (!(si = AllocSongInfo()))
	{
		LastErr = ERROR_NO_FREE_STORE;
		return NULL;
	}

	/* Add one position to the new song */
	if (!(SetSongLen (si, 1)))
	{
		FreeSongInfo (si);
		LastErr = ERROR_NO_FREE_STORE;
		return NULL;
	}

	/* Add one pattern to the new song */

	if (!AddPattern (si, si->MaxTracks, DEF_PATTLEN))
	{
		FreeSongInfo (si);
		LastErr = ERROR_NO_FREE_STORE;
		return NULL;
	}

	/* Add one instrument to the new song */
	si->CurrentInst = 1;

	return si;
}



void FreeSongInfo (struct SongInfo *si)

/* Free a SongInfo structure allocated by AllocSongInfo() */
{
	ULONG i;

	if (!si) return;

	RemoveSongInfo (si);

	/* Free patterns */
	for (i = 0; i < si->NumPatterns ; i++)
		FreeTracks (si->PattData[i].Notes, si->PattData[i].Lines, si->PattData[i].Tracks);

	/* Free instruments */
	for (i = 1 ; i < MAXINSTRUMENTS ; i++)
		FreeInstr (&(si->Inst[i]));

	/* Remove song sequence */
	SetSongLen (si, 0);

	FreePooled (Pool, si, sizeof (struct SongInfo));
}



ULONG CalcInstSize (struct SongInfo *si)

/* Calculate total size of all instruments in a song. */
{
	UWORD i;
	ULONG size = 0;

	for (i = 1; i < MAXINSTRUMENTS; i++)
		size += si->Inst[i].Length ? (si->Inst[i].Length + sizeof (struct Instrument)) : 0;

	return size;
}



ULONG CalcSongSize (struct SongInfo *si)

/* Calculate total size of a song */
{
	ULONG i;
	struct Pattern *patt;
	ULONG size = sizeof (struct SongInfo)
		- (sizeof (struct Pattern) * MAXPATTERNS)
		- (sizeof (struct Instrument) * MAXINSTRUMENTS)
		+ CalcInstSize (si);

	/* Calculate total patterns size */

	for ( i = 0; i < si->NumPatterns; i++)
	{
		patt = &(si->PattData[i]);
		size += patt->Lines * patt->Tracks * sizeof (struct Note) + sizeof (struct Pattern);
	}

	return size;
}



ULONG CalcSongTime (struct SongInfo *si)

/* Calculate song length in seconds
 *
 * One note lasts speed/50 seconds at 125bpm.
 */
{
	ULONG i, j, k;
	struct Pattern *patt;
	struct Note *note;
	ULONG speed = si->GlobalSpeed,
//		tempo = si->GlobalTempo,
		ticks = speed * 20,
		millisecs = 0;


	for (i = 0; i < si->Length; i++)
	{
		patt = &si->PattData[si->Sequence[i]];

		for (j = 0; j < patt->Lines; j++)
			for (k = 0; k < patt->Tracks; k++)
			{
				note = &patt->Notes[k][j];

				switch (note->EffNum)
				{
					case EFF_POSJUMP:
						if (note->EffVal > i)
						{
							i = note->EffVal;
							j = patt->Lines;
							k = patt->Tracks;
						}
						else return millisecs;
						break;

					case EFF_SETSPEED:
						/* At speed 1, one line lasts one VBlank,
						 * that is 20 milliseconds.
						 */
						ticks = note->EffVal * 20;
						break;

					case EFF_PATTERNBREAK:
						j = patt->Lines;
						k = patt->Tracks;
						break;

					/* case EFF_MISC: Loop */
				}

				millisecs += ticks;
			}
	}

	return millisecs;
}

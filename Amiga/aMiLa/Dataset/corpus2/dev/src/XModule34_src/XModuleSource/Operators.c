/*
**	Operators.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	General pourpose module handling/processing functions.
*/

#include <exec/memory.h>

#include <clib/exec_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>

#include "XModule.h"



UWORD InsertPattern (struct SongInfo *si, UWORD patnum)

/* Insert a pattern at any song position.  Patterns >= patnum will be moved
 * ahead one slot.  The position table is updated inserting references to
 * the new pattern immediately before each occurence of patnum, so that the
 * two patterns are allways played together.
 *
 * NOTE
 *	This function does *NOT* allocate the new pattern.  The slot number
 *	<patnum> becomes free and should be initialized to a valid pattern just
 *	after calling this function.
 *
 * RESULT
 *	0 to mean succes,
 *	any other value means failure.
 */
{
	ULONG i, k;

	if (si->NumPatterns > MAXPATTERNS-1)
	{
		ShowMessage (MSG_CANT_INSERT_PATT);
		return 1;
	}

	/* Shift subsequent patterns one position ahead */
	for (i = si->NumPatterns ; i > patnum ; i--)
		memcpy ((void *)(&(si->PattData[i])), (void *)(&(si->PattData[i-1])),
			sizeof (struct Pattern));

	si->NumPatterns++;	/* Update number of patterns */

	/* Adjust position table */
	for (i = 0 ; i < si->Length ; i++)
	{
		/* Song can't grow bigger than MAXPOSITIONS */
		if (si->Length >= MAXPOSITIONS)
			return 2;	/* TODO: better error handling */

		/* Fix pattern numbers */
		if (si->Sequence[i] > patnum) si->Sequence[i]++;

		/* Insert references to the new pattern in the position table */
		if (si->Sequence[i] == patnum)
		{
			/* Grow song */
			if (SetSongLen (si, si->Length + 1))
			{
				/* Shift subsequent positions ahead 1 slot */
				for (k = si->Length - 1; k > i ; k--)
					si->Sequence[k] = si->Sequence[k-1];

				si->Sequence[i+1] = patnum+1;	/* Restore old pattern */

				i++;			/* Avoid processing this pattern again */

				/* TODO: It would be nice to fix Pattern Jump commands too... */
			}
			else return 1;
		}
	}

	return 0;
}



void RemovePattern (struct SongInfo *si, UWORD patnum, UWORD newpatt)

/* Remove a pattern from a song.  All patterns >= <patnum> will be moved
 * back one slot.  The position table is updated replacing each
 * occurence of <patnum> with pattern <newpatt>.
 *
 * NOTE
 *	This function does *NOT* free the removed pattern.  The pattern
 *	slot <patnum> should be freed just *before* calling this function.
 */
{
	UWORD i;

	/* Scroll subsequent patterns */
	for (i = patnum; i < si->NumPatterns; i++)
		memcpy (&si->PattData[i], &si->PattData[i+1], sizeof (struct Pattern));


	/* Adjust position table */

	for (i = 0 ; i < si->Length ; i++)
	{
		/* Substitute references to the old pattern in the position table */
		if (si->Sequence[i] == patnum) si->Sequence[i] = newpatt;

		/* Fix pattern numbers */
		if (si->Sequence[i] > patnum) si->Sequence[i]--;
	}

	si->NumPatterns--;
}



void DiscardPatterns (struct SongInfo *si)

/* Discard patterns beyond the last pattern referenced
 * in the song.
 */
{
	ULONG i, j;
	UBYTE used[MAXPATTERNS] = {0};
	struct Pattern *patt;

	/* Flag patterns REALLY used in the song */
	for (i = 0; i < si->Length ; i++)
		used[si->Sequence[i]]++;


	for (i = 0; i < si->NumPatterns; i++)
	{
		patt = &si->PattData[i];

		if (!used[i] && patt->Tracks)
		{
			ShowMessage (MSG_PATT_UNUSED, i);
			FreeTracks (patt->Notes, patt->Lines, patt->Tracks);
			si->NumPatterns--;

			/* Shift all subsequent patterns one position back */
			for (j = i; j < si->NumPatterns; j++)
			{
				memcpy (&si->PattData[j], &si->PattData[j+1], sizeof (struct Pattern));
				used[j] = used[j+1];
			}

			memset (&si->PattData[si->NumPatterns], 0, sizeof (struct Pattern));

			/* Rearrange Position Table */
			for (j = 0; j < si->Length; j++)
				if (si->Sequence[j] > i) si->Sequence[j]--;

			/* TODO: It would be nice to fix Pattern Jump commands too... */

			i--; /* Process this pattern # again, since it is now another pattern */
		}
	}
}



void CutPatterns (struct SongInfo *si)

/* Find out what patterns are breaked (effect D) and resize them */
{
	ULONG i, j, k, l;
	struct Pattern *patt;

	for (i = 0; i < si->NumPatterns; i++)
	{
		patt = &si->PattData[i];

		for (j = 0; j < patt->Lines; j++)
			for (k = 0; k < patt->Tracks; k++)
				if (patt->Notes[k][j].EffNum == EFF_PATTERNBREAK)
				{
					struct Note *notes[MAXTRACKS];

					ShowMessage (MSG_PATT_CUT, i, j+1);

					/* Allocate new pattern */
					if (!AllocTracks (notes, j+1, patt->Tracks))
					{
						/* Remove break command */
						patt->Notes[k][j].EffNum = 0;
						patt->Notes[k][j].EffVal = 0;

						/* Copy notes */
						for (l = 0; l < patt->Tracks; l++)
							CopyMem (patt->Notes[l], notes[l], sizeof (struct Note) * (j+1));

						/* Free old pattern */
						FreeTracks (patt->Notes, patt->Lines, patt->Tracks);

						/* Replace with new notes */
						for (l = 0; l < patt->Tracks; l++)
							patt->Notes[l] = notes[l];

						/* Update length & break loop */
						j = patt->Lines = j+1;
						k = patt->Tracks;
					}
				}
	}
}



void RemDupPatterns (struct SongInfo *si)

/* Find out identical patterns and cut them out */
{
	UWORD i, j, k;
	struct Pattern *patta, *pattb;

	if (si->NumPatterns < 2) return;

	for (i = 0; i < si->NumPatterns-1; i++)
	{
		patta = &si->PattData[i];
		for (j = i+1; j < si->NumPatterns; j++)
		{
			pattb = &si->PattData[j];
			if (patta->Lines == pattb->Lines && patta->Tracks == pattb->Tracks)
			{
				for (k = 0; k < patta->Tracks; k++)
					if (memcmp (patta->Notes[k], pattb->Notes[k], sizeof (struct Note) * patta->Lines))
						break;

				if (k == patta->Tracks)
				{
					FreeTracks (pattb->Notes, pattb->Lines, pattb->Tracks);
					RemovePattern (si, j, i);
					ShowMessage (MSG_PATT_DUPE, i, j);
					j--;
				}
			}
		}
	}
}



struct SongInfo *MergeSongs (struct SongInfo *songa, struct SongInfo *songb)

/* Merges <songa> with <songb> in a new song where the notes of the
 * two sources are played at the same time.
 */
{
	struct SongInfo *songc;
	struct Pattern *patta, *pattb, *pattc;
	struct Note *note;
	struct Instrument *inst, *source;
	LONG slen, plen, ntrk, i, j, k;

	if (!(songc = AllocSongInfo ()))
		return NULL;

	/* Initialize various SongInfo fields */

	songc->Length = 0;
	songc->MaxTracks = songa->MaxTracks + songb->MaxTracks;
	songc->GlobalSpeed = songa->GlobalSpeed;
	songc->GlobalTempo = songa->GlobalTempo;
	songc->Restart = songa->Restart;
	strncpy (songc->SongName, songa->SongName, MAXSONGNAME);
	strncat	(songc->SongName, " + ", MAXSONGNAME);
	strncat	(songc->SongName, songb->SongName, MAXSONGNAME);

	/* Set Author */

	if (songa->Author[0])
		strncpy (songc->Author, songa->Author, MAXAUTHNAME);
	if (songb->Author[0])
	{
		if (songa->Author[0])
		{
			strncat (songc->Author, " & ", MAXAUTHNAME);
			strncat (songc->Author, songb->Author, MAXAUTHNAME);
		}
		else strncpy (songc->Author, songb->Author, MAXAUTHNAME);
	}

	if (songa->Length != songb->Length)
		ShowMessage (MSG_SONG_LEN_DIFFERENT);

	slen = min (songa->Length, songb->Length);
	SetSongLen (songc, slen);

	for (i = 0; i < slen; i++)
	{
		patta = &songa->PattData[songa->Sequence[i]];
		pattb = &songb->PattData[songb->Sequence[i]];
		pattc = &songc->PattData[i];

		if (patta->Lines != pattb->Lines)
			ShowMessage (MSG_PATT_LEN_DIFFERENT, i);

		plen = min (patta->Lines, pattb->Lines);
		ntrk = patta->Tracks + pattb->Tracks;

		if (ntrk > MAXTRACKS)
		{
			ShowMessage (MSG_PATT_TOO_MANY_TRACKS, MAXTRACKS);
			ntrk = MAXTRACKS;
		}

		if (AllocTracks (pattc->Notes, plen, ntrk))
		{
			FreeSongInfo (songc);
			LastErr = ERROR_NO_FREE_STORE;
			return NULL;
		}

		songc->NumPatterns++;
		songc->Sequence[i] = i;

		pattc->Tracks = ntrk;
		pattc->Lines = plen;

		/* Set pattern name */
		if (patta->PattName[0] && pattb->PattName[0])
		{
			strncpy (pattc->PattName, patta->PattName, MAXPATTNAME);
			strncat	(pattc->PattName, " + ", MAXPATTNAME);
			strncat	(pattc->PattName, pattb->PattName, MAXPATTNAME);
		}
		else
			SPrintf (pattc->PattName, "%ld + %ld", songa->Sequence[i], songb->Sequence[i]);

		/* Copy tracks from source A */
		for (j = 0; j < patta->Tracks; j++)
			CopyMem (patta->Notes[j], pattc->Notes[j], sizeof (struct Note) * plen);

		/* Copy tracks from source B */
		for (j = 0; j < pattb->Tracks; j++)
		{
			if (j + patta->Tracks >= MAXTRACKS) break;

			note = pattc->Notes[j + patta->Tracks];
			CopyMem (pattb->Notes[j], note, sizeof (struct Note) * plen);

			for (k = 0; k < plen; k++)
				if (note[k].Note)
				{
					if (note[k].Inst > MAXINSTRUMENTS/2)
					{
						ShowMessage (MSG_ERR_INSTR_BEYOND_LIMIT, MAXINSTRUMENTS/2);
						ShowMessage (MSG_TRY_INSTR_REMAP);
						FreeSongInfo (songc);
						return NULL;
					}

					note[k].Inst += MAXINSTRUMENTS/2;
				}
		}
	}


	/* Copy instruments */

	for (i = 0; i < MAXINSTRUMENTS; i++)
	{
		inst = &songc->Inst[i];

		if (i < MAXINSTRUMENTS/2)
			source = &songa->Inst[i];
		else
			source = &songb->Inst[i-(MAXINSTRUMENTS/2)];

		memcpy (inst, source, sizeof (struct Instrument));

		if (source->SampleData)
		{
			if (!(inst->SampleData = AllocVec (inst->Length, MEMF_ANY)))
			{
				inst->Length = 0;
				FreeSongInfo (songc);
				LastErr = ERROR_NO_FREE_STORE;
				return NULL;
			}
			CopyMem (source->SampleData, inst->SampleData, inst->Length);
		}
	}

	return songc;
}



struct SongInfo *JoinSongs (struct SongInfo *songa, struct SongInfo *songb)

/* Joins <songa> with <songb> in a new song where the notes of the
 * two sources are played one after the oder.
 */
{
	struct SongInfo *songc;
	struct Pattern *patta, *pattb, *pattc;
	struct Note *note;
	struct Instrument *inst, *source;
	ULONG plen, ntrk, i, j, k;
	UWORD songclen;

	if (!(songc = AllocSongInfo ()))
		return NULL;


	/* Initialize various SongInfo fields */

	if ((songa->Length + songb->Length) > MAXPOSITIONS)
	{
		ShowMessage (MSG_SONG_TOO_LONG);
		songclen = MAXPOSITIONS;
	}
	else songclen = songa->Length + songb->Length;

	if ((songa->NumPatterns + songb->NumPatterns) > MAXPATTERNS)
		ShowMessage (MSG_SONG_HAS_TOO_MANY_PATT);

	songc->MaxTracks = max(songa->MaxTracks,songb->MaxTracks);
	songc->GlobalSpeed = songa->GlobalSpeed;
	songc->GlobalTempo = songa->GlobalTempo;
	songc->Restart = songa->Restart;
	strncpy (songc->SongName, songa->SongName, MAXSONGNAME);
	strncat	(songc->SongName, " & ", MAXSONGNAME);
	strncat	(songc->SongName, songb->SongName, MAXSONGNAME);

	/* Set Author */

	if (songa->Author[0])
		strncpy (songc->Author, songa->Author, MAXAUTHNAME);
	if (songb->Author[0])
	{
		if (songa->Author[0])
		{
			strncat (songc->Author, " & ", MAXAUTHNAME);
			strncat (songc->Author, songb->Author, MAXAUTHNAME);
		}
		else strncpy (songc->Author, songb->Author, MAXAUTHNAME);
	}

	if (SetSongLen (songc, songclen))
	{
		/* Copy position table of song A */
		memcpy (songc->Sequence, songa->Sequence, songa->Length * sizeof (UWORD));

		/* Append position table of song B */
		for (i = 0; i < songb->Length; i++)
		{
			if (i + songa->Length >= songc->Length) break;
			songc->Sequence[i + songa->Length] = (songb->Sequence[i] + songa->NumPatterns > MAXPATTERNS) ?
				songb->Sequence[i] : (songb->Sequence[i] + songa->NumPatterns);
		}
	}
	else
	{
		FreeSongInfo (songc);
		LastErr = ERROR_NO_FREE_STORE;
		return NULL;
	}


	/* Copy song A patterns */

	for (i = 0; i < songa->NumPatterns; i++)
	{
		patta = &songa->PattData[i];
		pattc = &songc->PattData[i];
		plen = patta->Lines;
		ntrk = patta->Tracks;

		if (AllocTracks (pattc->Notes, plen, ntrk))
		{
			FreeSongInfo (songc);
			LastErr = ERROR_NO_FREE_STORE;
			return NULL;
		}

		/* Set pattern attributes */

		songc->NumPatterns++;
		pattc->Tracks = ntrk;
		pattc->Lines = plen;

		strcpy (pattc->PattName, patta->PattName);


		/* Copy tracks from source A */

		for (j = 0; j < ntrk; j++)
			CopyMem (patta->Notes[j], pattc->Notes[j], sizeof (struct Note) * plen);
	}


	/* Append song B patterns */

	for (i = 0; i < songb->NumPatterns; i++)
	{
		if (songc->NumPatterns >= MAXPATTERNS)
			break;

		pattb = &songb->PattData[i];
		pattc = &songc->PattData[songa->NumPatterns + i];
		plen = pattb->Lines;
		ntrk = pattb->Tracks;

		if (AllocTracks (pattc->Notes, plen, ntrk))
		{
			FreeSongInfo (songc);
			LastErr = ERROR_NO_FREE_STORE;
			return NULL;
		}

		/* Set pattern attributes */

		songc->NumPatterns++;
		pattc->Tracks = ntrk;
		pattc->Lines = plen;

		strcpy (pattc->PattName, patta->PattName);


		/* Copy tracks from source B */

		for (j = 0; j < ntrk; j++)
			CopyMem (pattb->Notes[j], pattc->Notes[j], sizeof (struct Note) * plen);

		/* Adjust instruments references */

		for (j = 0; j < ntrk; j++)
			for (k = 0; k < plen; k++)
			{
				note = &pattc->Notes[j][k];

				if (note->Inst)
				{
					if (note->Inst > MAXINSTRUMENTS/2)
					{
						ShowMessage (MSG_ERR_INSTR_BEYOND_LIMIT, MAXINSTRUMENTS/2);
						ShowMessage (MSG_TRY_INSTR_REMAP);
						FreeSongInfo (songc);
						return NULL;
					}

					note->Inst += MAXINSTRUMENTS / 2;
				}
			}
	}


	/* Copy instruments */

	for (i = 0; i < MAXINSTRUMENTS; i++)
	{
		inst = &songc->Inst[i];

		if (i < MAXINSTRUMENTS/2)
			source = &songa->Inst[i];
		else
			source = &songb->Inst[i-(MAXINSTRUMENTS/2)];

		memcpy (inst, source, sizeof (struct Instrument));

		if (source->SampleData)
		{
			if (!(inst->SampleData = AllocVec (inst->Length, MEMF_ANY)))
			{
				inst->Length = 0;
				FreeSongInfo (songc);
				LastErr = ERROR_NO_FREE_STORE;
				return NULL;
			}
			CopyMem (source->SampleData, inst->SampleData, inst->Length);
		}
	}

	return songc;
}



UWORD AllocTracks (struct Note **arr, UWORD lines, UWORD tracks)

/* Allocate enough memory to store a whole pattern with the requested
 * number of lines and tracks.  The allocated memory can be freed using
 * FreeTracks().
 *
 * RETURNS
 *    0        - success.
 *    non-zero - not enough memory.
 */
{
	ULONG i;

	if (!lines || !tracks)
		return ERROR_BAD_NUMBER;

	for (i = 0 ; i < tracks ; i++)
	{
		if (!(arr[i] = AllocMem (sizeof (struct Note) * lines, MEMF_CLEAR)))
		{
			FreeTracks (arr, lines, i);
			return ERROR_NO_FREE_STORE;
		}
	}
	return RETURN_OK;
}



void FreeTracks (struct Note **arr, UWORD lines, UWORD tracks)

/* Free the memory allocated by AllocTracks().
 * <lines> and <tracks> must match the values previously passed to
 * AllocTracks().
 */
{
	ULONG i;

	if (!lines) return;

	for (i = 0 ; i < tracks ; i++)
		if (arr[i])
		{
			FreeMem (arr[i], lines * sizeof (struct Note));
			arr[i] = NULL;
		}
}



struct Pattern *AddPattern (struct SongInfo *si, UWORD tracks, UWORD lines)

/* Add a pattern to the current song.
 * Returns a pointer to the newly allocated pattern or NULL for failure.
 */
{
	struct Pattern *patt = &si->PattData[si->NumPatterns];

	if (si->NumPatterns >= MAXPATTERNS - 1)
		return NULL;

	if (AllocTracks (patt->Notes, lines, tracks))
		return NULL;

	si->NumPatterns++;

	patt->Tracks	= tracks;
	patt->Lines		= lines;

	return patt;
}



LONG CopyPattern (struct Pattern *src, struct Pattern *dest)

/* Makes a copy of the notes and attributes of the <src>
 * pattern to the <dest> pattern.  Memory for the tracks in
 * the <dest> pattern is allocated with AllocTracks().
 *
 * RETURNS
 *    0        - success.
 *    non-zero - not enough memory.
 */
{
	ULONG i;

	if (!src->Tracks) return RETURN_OK;

	if (!AllocTracks (dest->Notes, src->Lines, src->Tracks))
	{
		dest->Lines		= src->Lines;
		dest->Tracks	= src->Tracks;

		for (i = 0; i < src->Tracks; i++)
			CopyMem (src->Notes[i], dest->Notes[i],
				sizeof (struct Note) * src->Lines);

		return RETURN_OK;
	}

	return ERROR_NO_FREE_STORE;
}

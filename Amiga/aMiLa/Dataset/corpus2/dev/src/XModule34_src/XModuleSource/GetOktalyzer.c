/*
**	GetOktalyzer.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Originally based on Gerardo Iula's Tracker sources.
**
**	Read and decode an Oktalyzer 1.1-1.5 module.
*/


#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>

#include "XModule.h"
#include "Gui.h"



#define OKT_MODE4	1	/* Mode 4: play 8 bit instruments */
#define OKT_MODE8	0	/* Mode 8: play 7 bit instruments */
#define OKT_MODEB	2	/* Mode B: play both 8 & 7 bit instruments */


/* Oktalyzer chunk IDs */

#define ID_OKTA 'OKTA'
#ifndef ID_SONG			/* Workaround for a SAS/C bug which produces silly warnings */
#define ID_SONG 'SONG'
#endif	/* ID_SONG */
#define ID_CMOD 'CMOD'
#define ID_SAMP	'SAMP'
#define ID_SPEE	'SPEE'
#define ID_SLEN	'SLEN'
#define ID_PLEN	'PLEN'
#ifndef ID_PATT			/* Workaround for a SAS/C bug which produces silly warnings */
#define ID_PATT 'PATT'
#endif	/* ID_PATT */
#define ID_PBOD 'PBOD'
#define ID_SBOD 'SBOD'



static __inline UBYTE DecodeEff (UBYTE eff, UBYTE effval, UWORD patt, UWORD line, UWORD track);



LONG GetOktalyzer (struct SongInfo *si, BPTR fh)
{
	struct Instrument	*inst = si->Inst;
	struct Pattern		*patt;
	ULONG i, j, k;	/* Loop counters	*/
	ULONG size;		/* Read buffer		*/
	ULONG l;		/* Read buffer		*/
	UWORD voices, numpatts, songlen, instr_mode[37];
	UWORD w;
	UBYTE oktanote[4], c;


	/* Check file header OKTASONGCMOD */
	{
		LONG id[3];

		if (Read (fh, id, 12) != 12) return ERR_READWRITE;
		if ((id[0] != ID_OKTA) || (id[1] != ID_SONG) || (id[2] != ID_CMOD))
			return ERR_NOTMODULE;
	}


	/* TODO: set si->SongName */

	/* CMOD Chunk size ($0000 0008) */
	Seek (fh, 4, OFFSET_CURRENT); /* Skip 4 bytes */

	voices = 4;		/* Set minimum voices and check others	*/
	for (i = 0 ; i<4 ; i++)
	{
		if (Read (fh, &w, 2) != 2) return ERR_READWRITE;
		if (w) voices++;
	}

	si->MaxTracks = voices;

	if (GuiSwitches.Verbose)
		ShowMessage (MSG_READING_OKTALYZER, voices);

	/* Get Sample Name, Length, Repeat Replen, Volume for each instr. */

	/* Check header SAMP */
	if (Read (fh, &l, 4) != 4) return ERR_READWRITE;
	if (l != ID_SAMP) return ERR_NOTMODULE;

	/* SAMP Chunk Size ($0000 0480) */
	Seek (fh, 4, OFFSET_CURRENT); /* Skip 4 bytes */

	DisplayAction (MSG_READING_INSTS_INFO);

	/* Read in 36 instruments */
	for ( j = 1 ; j <= 36 ; j++ )
	{
		/* Get instrument name */
		if (Read (fh, &inst[j].Name, 20) != 20) return ERR_READWRITE;

		/* Get Length */
		if (Read (fh, &size, 4) != 4) return ERR_READWRITE;

		/* Oktalyzer sometimes saves odd lengths for instruments,
		 * but the data saved in SBOD is always rounded _down_ to
		 * an even nuber!  It took me two weeks to find and kill this bug.
		 */
		inst[j].Length = size & (~1);

		/* Get Repeat */
		if (Read (fh, &w, 2) != 2) return ERR_READWRITE;
		inst[j].Repeat = ((ULONG)w)<<1;

		/* Get Replen */
		if (Read (fh, &w, 2) != 2) return ERR_READWRITE;
		inst[j].Replen = ((ULONG)w)<<1;

		/* Get Volume */
		if (Read (fh, &inst[j].Volume, 2) != 2) return ERR_READWRITE;

		/* Oktalyzer instrument modes:
		 *	mode 8 $00 7 bit instruments
		 *	mode 4 $01 normal instruments
		 *	mode B $02 both 8bit & 7bit
		 */
		Read (fh, &instr_mode[j], 2);
	}


	/* Get global song speed */

	/* Check speed header "SPEE" */
	if (Read (fh, &l, 4) != 4) return ERR_READWRITE;
	if (l != ID_SPEE) return ERR_NOTMODULE;

	/* SPEE Chunk size ($0000 0002) */
	Seek (fh, 4, OFFSET_CURRENT); /* Skip 4 bytes */

	/* Get Song Global Speed */
	if (Read (fh, &si->GlobalSpeed, 2) != 2) return ERR_READWRITE;


	/* Get number of patterns */

	/* Check header SLEN */
	if (Read (fh, &l, 4) != 4) return ERR_READWRITE;
	if (l != ID_SLEN) return ERR_NOTMODULE;

	/* SLEN Chunk size ($0000 0002) */
	Seek (fh, 4, OFFSET_CURRENT); /* Skip 4 bytes */

	/* Get number of patterns */
	if (Read (fh, &numpatts, 2) != 2) return ERR_READWRITE;

	/* Check value */
	if (numpatts > MAXPATTERNS)
	{
		ShowMessage (MSG_SONG_HAS_TOO_MANY_PATT);
		numpatts = MAXPATTERNS - 1;
	}


	/* Get number of positions in song (Length) */

	/* Check header PLEN */
	if (Read (fh, &l, 4) != 4) return ERR_READWRITE;
	if (l != ID_PLEN) return ERR_NOTMODULE;

	/* Chunk size ($0000 0002) */
	Seek (fh, 4, OFFSET_CURRENT); /* Skip 4 bytes */

	/* Get number of patterns */
	if (Read (fh, &songlen, 2) != 2) return ERR_READWRITE;

	/* Check value */
	if (songlen > MAXPOSITIONS)
	{
		ShowMessage (MSG_SONG_TOO_LONG);
		 songlen = MAXPOSITIONS;
	}


	/* Get position table */

	/* Check header PATT */
	if (Read (fh, &l, 4) != 4) return ERR_READWRITE;
	if (l != ID_PATT) return ERR_NOTMODULE;

	/* PATT Chunk size ($0000 0080) */
	Seek (fh, 4, OFFSET_CURRENT); /* Skip 4 bytes */

	/* Read song sequence */
	{
		UBYTE postable[128];

		if (Read (fh, postable, 128) != 128) return ERR_READWRITE;

		if (!(SetSongLen (si, songlen)))
			return ERROR_NO_FREE_STORE;

		for (i = 0; i < si->Length; i++)
			si->Sequence[i] = postable[i];
	}


	/* Get pattern bodies and convert them */

	DisplayAction (MSG_READING_PATTS);

	for (j = 0; j < numpatts; j++)
	{
		if (DisplayProgress (j+1, numpatts))
			return ERROR_BREAK;

		/* Check header "PBOD" */
		if (Read (fh, &l, 4) != 4) return ERR_READWRITE;
		if (l != ID_PBOD) return ERR_NOTMODULE;

		/* Skip Chunk Length (Lines * Tracks * 4 + 2) */
		Seek (fh, 4, OFFSET_CURRENT);

		/* Get pattern length */
		if (Read (fh, &w, 2) != 2) return ERR_READWRITE;

		/* Allocate memory for all tracks */
		if (!(patt = AddPattern (si, voices, w)))
			return ERROR_NO_FREE_STORE;

		for ( k = 0 ; k < patt->Lines ; k++)
		{
			for (i = 0; i < voices; i++)
			{
				struct Note *n = &patt->Notes[i][k];

				/* Read a whole track row */
				if (Read (fh, oktanote, 4) != 4) return ERR_READWRITE;

				/* Convert Note:
				 *
				 * Oktalyzer supports 3 octaves (1 to 3).
				 * Notes are numbered from 1 (C-1) to 36 (B-3).
				 * 0 means no note.
				 */
				if (oktanote[0] <= 36)
					n->Note = (oktanote[0] ? (oktanote[0] + 12) : 0);	/* Add one octave */
				else
					ShowMessage (MSG_INVALID_NOTE, oktanote[0], j, i, k);

				/* Store Instrument Number */
				n->Inst = (n->Note ? (oktanote[1] + 1) : 0);

				/* Convert Effect */
				n->EffNum = DecodeEff (oktanote[2], oktanote[3], j, k, i);

				/* Store Effect Value */
				n->EffVal = oktanote[3];

				/* Effect Exceptions */
				if (n->EffNum == EFF_MISC)
				{
					/* Oktalyzer has SetFilter values inverted! */
					if ((n->EffVal >> 4) == 1)
						n->EffVal = 0x10 | (n->EffVal & 0x0F ? 0 : 1);
				}
			}	/* end for (i) */
		}	/* End for (k) */
	}	/* End for (j) */


	/* Load instruments */

	DisplayAction (MSG_READING_INSTS);

	for (j = 1 ; j <= 36 ; j++)
	{
		/* Check if instrument exists */
		if (inst[j].Length == 0) continue;

		if (DisplayProgress(j, 36))
			return ERROR_BREAK;

		if (!(inst[j].SampleData = AllocVec (inst[j].Length, MEMF_SAMPLE)))
			return ERROR_NO_FREE_STORE;

		/* Check header SBOD */
		if (Read (fh, &l, 4) != 4) return ERR_READWRITE;
		if (l != ID_SBOD) return ERR_NOTMODULE;

		/* Read chunk size (length of instrument) & check it */
		if (Read (fh, &size, 4) != 4) return ERR_READWRITE;
		if (size != inst[j].Length) return ERR_NOTMODULE;

		/* Read instrument body */
		if (Read (fh, inst[j].SampleData, inst[j].Length) != inst[j].Length)
			return ERR_READWRITE;

		/* Double sample data */
		if (instr_mode[j] == OKT_MODE8 || instr_mode[j] == OKT_MODEB)
		{
			BYTE *data = inst[j].SampleData;

			for (i = 0; i < inst[j].Length; i++)
				*data++ <<= 1;
		}
	}

	/* Check for extra data following the module */
	if (Read (fh, &c, 1) == 1)
		ShowMessage (MSG_EXTRA_DATA_AFTER_MOD);

	return 0;
}


static __inline UBYTE DecodeEff (UBYTE eff, UBYTE effval, UWORD patt, UWORD line, UWORD track)

/*	Inputs: old effect & old type.
 *	Outputs: new effect in requested newtype.
 */
{
	UBYTE i;

	for ( i = 0 ; i < MAXTABLEEFFECTS ; i++ )
		if (eff == Effects[i][1])
			return i;

	ShowMessage (MSG_UNKNOWN_EFF, eff, patt, track, line);
	return 0;
}

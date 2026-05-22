/*
**	SaveOktalyzer.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Originally based on Gerardo Iula's Tracker sources.
**
**	Save internal data to an Oktalyzer 1.1-1.57 module.
*/


#include <clib/dos_protos.h>
#include <clib/exec_protos.h>

#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_sysbase_pragmas.h>

#include "XModule.h"
#include "Gui.h"



#define OKT_MODE4	1	/* Mode 4: play 8 bit instruments */
#define OKT_MODE8	0	/* Mode 8: play 7 bit instruments */
#define OKT_MODEB	2	/* Mode B: play both 8 & 7 bit instruments */



LONG SaveOktalyzer (struct SongInfo *si, BPTR fh)
{
	struct Instrument *inst = si->Inst;
	ULONG	i, j, k;
	UWORD	voices, instr_mode, songlen;
	ULONG	l;		/* Write buffers */
	UWORD	w;
	UBYTE	oktanote[4];

	/* Check number of tracks and fix data */
	voices = si->MaxTracks;
	if (voices < 4) voices = 4;
	if (voices > 8) voices = 8;

	if (GuiSwitches.Verbose)
		ShowMessage (MSG_WRITING_OKTALYZER, voices);

	/* Oktalyzer does not support pattern break (D) command */
	CutPatterns (si);

	/* Write file header */
	if (Write (fh, "OKTASONGCMOD", 12) != 12) return ERR_READWRITE;


	/* Write maximum number of tracks */
	l = 8;
	if (Write (fh, &l, 4) != 4) return ERR_READWRITE;

	/* Write active tracks (only 5 to 8: tracks 1..4 are always on)
	 * TODO: Ask user what tracks should be made active, or loadnig and
	 * saving back the same module will result in the lost of the original
	 * track order.
	 */
	for (i = 5 ; i <= 8 ; i++)
	{
		if (voices >= i) w = 1;
			else w = 0;
		if (Write (fh, &w, 2) != 2) return ERR_READWRITE;
	}

	/* Choose mode for instruments.
	 * When the module is 4 channels, we can always use mode 4.
	 * On modules with 5-7 channels, it is hard to guess which instruments
	 * could be made mode 4, 8 or B, so we always choose mode B.
	 * for 8 channels modules, we just use mode 8 for all instruments.
	 */
	switch (voices)
	{
		case 4:
			instr_mode = OKT_MODE4;
			break;

		case 8:
			instr_mode = OKT_MODE8;
			break;

		default:
			instr_mode = OKT_MODEB;
	}

	/* Write sample names, length, effects, volume */
	DisplayAction (MSG_WRITING_INSTINFO);

	if (Write (fh, "SAMP", 4) != 4) return ERR_READWRITE;

	/* Write chunk length */
	l = 0x480;
	if (Write (fh, &l, 4) != 4) return ERR_READWRITE;

	for ( j = 1 ; j <= 36 ; j++ )
	{
		/* Name */
		if (Write (fh, inst[j].Name, 20) != 20) return ERR_READWRITE;

		/* Length (LONG) */
		if (Write (fh, &inst[j].Length, 4) != 4) return ERR_READWRITE;

		/* Repeat (WORD) */
		w = inst[j].Repeat >> 1;
		if (Write (fh, &w, 2) != 2) return ERR_READWRITE;

		/* Replen (WORD) */
		w = inst[j].Replen >> 1;
		if (Write (fh, &w, 2) != 2) return ERR_READWRITE;

		/* Volume (WORD) */
		w = inst[j].Volume;
		if (Write (fh, &w, 2) != 2) return ERR_READWRITE;

		/* Mode (WORD) */

		if (inst[j].Length)	w = instr_mode;
		else				w = 0;
		if (Write (fh, &w, 2) != 2) return ERR_READWRITE;
	}


	/* Write global song speed */

	if (Write (fh, "SPEE", 4) != 4) return ERR_READWRITE;
	l = 2;
	if (Write (fh, &l, 4) != 4) return ERR_READWRITE;

	w = si->GlobalSpeed;
	if (Write (fh, &w, 2) != 2) return ERR_READWRITE;


	if (Write (fh, "SLEN", 4) != 4) return ERR_READWRITE;
	l = 2;
	if (Write (fh, &l, 4) != 4) return ERR_READWRITE;

	w = si->NumPatterns;
	if (Write (fh, &w, 2) != 2) return ERR_READWRITE;


	/* Write patterns number */

	if (Write (fh, "PLEN", 4) != 4) return ERR_READWRITE;
	l = 2;
	if (Write (fh, &l, 4) != 4) return ERR_READWRITE;

	songlen = min (si->Length, 128);
	if (Write (fh, &songlen, 2) != 2) return ERR_READWRITE;


	/* Write patterns sequence */

	if (Write (fh, "PATT", 4) != 4) return ERR_READWRITE;
	l = 128;
	if (Write (fh, &l, 4) != 4) return ERR_READWRITE;

	{
		UBYTE postable[128];

		memset (postable, 0, 128);

		for (i = 0; i < songlen; i++)
			postable[i] = si->Sequence[i];

		if (Write (fh, postable, 128) != 128) return ERR_READWRITE;
	}


	/* Write patterns */
	DisplayAction (MSG_WRITING_PATTS);

	for ( j = 0 ; j < si->NumPatterns ; j++)
	{
		if (DisplayProgress (j+1, si->NumPatterns))
			return ERROR_BREAK;

		if (Write (fh, "PBOD", 4) != 4) return ERR_READWRITE;
		l = si->PattData[j].Lines * si->MaxTracks * 4 + 2;
		if (Write (fh, &l, 4) != 4) return ERR_READWRITE;

		/* Write pattern length (WORD) */
		w = si->PattData[j].Lines;
		if (Write (fh, &w, 2) != 2) return ERR_READWRITE;

		for (k = 0 ; k < si->PattData[j].Lines ; k++)
		{
			for ( i = 0 ; i < voices ; i++)
			{
				struct Note *n = &(si->PattData[j].Notes[i][k]);

				if (n->Note)
				{
					if (n->Note < 13)
					{
						ShowMessage (MSG_NOTE_TOO_LOW, j, i, k);
						oktanote[0] = n->Note;
					}
					else
					{
						if (n->Note > 48)
						{
							ShowMessage (MSG_NOTE_TOO_HIGH, j, i, k);
							oktanote[0] = n->Note - 24;
						}
						else
							oktanote[0] = n->Note - 12;
					}
				}
				else oktanote[0] = 0;

				oktanote[1] = (n->Inst ? (n->Inst-1) : 0);
				oktanote[2] = Effects[n->EffNum][1];

				/* Effect Exceptions */
				switch (n->EffNum)
				{
					case EFF_MISC:
						if ((n->EffVal >> 4) == 1)	/* Filter On/Off */
							oktanote[3] = (n->EffVal ? 0 : 1);
						break;

					case EFF_SETSPEED:
						if (n->EffVal > 0x0F)
							oktanote[3] = 0x0F;
						else
							oktanote[3] = n->EffVal;
						break;

					default:
						oktanote[3] = n->EffVal;
						break;
				}

				if (Write (fh, oktanote, 4) != 4) return ERR_READWRITE;

			}	/* end for(i) */
		}	/* End for(k) */
	}	/* End for(j) */


	/* Write Instruments Data */

	DisplayAction (MSG_WRITING_INSTDATA);

	for (j = 1 ; j <= 36 ; j++)
	{
		BYTE *samp;
		BOOL free_samp = FALSE;

		if (DisplayProgress(j, 36))
			return ERROR_BREAK;

		l = inst[j].Length;

		/* Skip empty instruments slots */
		if (l == 0)
			continue;

		if (instr_mode == OKT_MODE8 || instr_mode == OKT_MODEB)
		{
			if (samp = AllocVec (l, MEMF_ANY))
			{
				/* Halve volume */
				for (i = 0; i < l; i++)
					samp[i] = inst[j].SampleData[i] >> 1;

				free_samp = TRUE;	/* Free this when done */
			}
			else
			{
				ShowMessage (MSG_NO_MEM_TO_HALVE, j);
				samp = inst[j].SampleData;
			}
		}
		else
			samp = inst[j].SampleData;


		if (!samp) l = 0;

		if (Write (fh, "SBOD", 4) != 4) return ERR_READWRITE;
		if (Write (fh, &l, 4) != 4) return ERR_READWRITE;

		if (l)
			if (Write (fh, samp, l) != l)
				return ERR_READWRITE;

		if (free_samp)
			FreeVec (samp);
	}

	return 0;
}

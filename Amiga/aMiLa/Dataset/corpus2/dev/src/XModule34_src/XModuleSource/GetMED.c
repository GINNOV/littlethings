/*
**	GetMED.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Load an MMD0 or MMD1 (MED/OctaMED) module.
*/

#include <exec/types.h>

#include <clib/dos_protos.h>
#include <clib/exec_protos.h>

#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_sysbase_pragmas.h>

#include "XModule.h"
#include "Gui.h"
#include "OctaMed.h"


static __inline UBYTE DecodeEff (UBYTE eff, UBYTE *effval, UBYTE flags, UBYTE flags2);



LONG GetMED (struct SongInfo *si, BPTR fp)
{
	struct Instrument *inst = si->Inst;
	struct MMD0 mmd0;
	struct MMD0song song;
	ULONG i, j, k, mmdtype, len;

	/******************************/
	/*      Read MMD0 header      */
	/******************************/

	if (Read (fp, &mmd0, sizeof (mmd0)) != sizeof (mmd0))
		return ERR_READWRITE;

	mmdtype = mmd0.id & 0xFF;

	if (GuiSwitches.Verbose)
		ShowMessage (MSG_READING_MMD, mmdtype);

	mmdtype -= '0';

	if (mmdtype > 1)
	{
		ShowMessage (MSG_UNSUPPORTED_MMD_FORMAT);
		return ERR_NOTMODULE;
	}


	/******************************/
	/*  Read MMD0song structure   */
	/******************************/

	if (Seek (fp, (LONG)mmd0.song, OFFSET_BEGINNING) == -1)
		return ERR_READWRITE;

	if (Read (fp, &song, sizeof (song)) != sizeof (song))
		return ERR_READWRITE;


	/* Set instruments parameters */

	for (i = 0; i <= song.numsamples; i++)
	{
		inst[i+1].Volume = song.sample[i].svol;

		if (song.sample[i].rep || song.sample[i].replen != 1)
		{
			inst[i+1].Repeat = song.sample[i].rep << 1;
			inst[i+1].Replen = song.sample[i].replen << 1;
		}
	}

	/* Set position table */
	if (SetSongLen (si, song.songlen))
		for (i = 0; i < si->Length; i++)
			si->Sequence[i] = song.playseq[i];


	if (song.flags2 & FLAG2_BPM)
		si->GlobalTempo = (song.deftempo * 4) / ((song.flags2 & FLAG2_BMASK) + 1);
	else
		si->GlobalTempo = song.deftempo;

	si->GlobalSpeed = song.tempo2;



	/******************************/
	/*   Read MMD0exp structure   */
	/******************************/

	if (mmd0.expdata)
	{
		struct MMD0exp exp;

		if (Seek (fp, (LONG)mmd0.expdata, OFFSET_BEGINNING) == -1)
			return ERR_READWRITE;

		if (Read (fp, &exp, sizeof (exp)) != sizeof (exp))
			return ERR_READWRITE;


		/******************************/
		/*  Read InstrExt structures  */
		/******************************/

		if (exp.exp_smp && (exp.s_ext_entrsz >= 4))
		{
			struct InstrExt	instrext;
			ULONG			size = min (exp.s_ext_entrsz, sizeof (instrext));

			if (Seek (fp, (LONG)exp.exp_smp, OFFSET_BEGINNING) == -1)
				return ERR_READWRITE;

			for (i = 1; i <= exp.s_ext_entries; i++)
			{
				if (Read (fp, &instrext, size) != size)
					return ERR_READWRITE;

				inst[i].FineTune = instrext.finetune;
				if (exp.s_ext_entrsz > size)
					if (Seek (fp, exp.s_ext_entrsz - size, OFFSET_CURRENT) == -1)
						return ERR_READWRITE;
			}
		}

		/******************************/
		/*      Read Annotation       */
		/******************************/

		if (exp.annotxt && exp.annolen > 1)
		{
			ULONG len = min (exp.annolen, MAXAUTHNAME-1);

			if (Seek (fp, (LONG)exp.annotxt, OFFSET_BEGINNING) == -1)
				return ERR_READWRITE;

			if (Read (fp, si->Author, len) != len)
				return ERR_READWRITE;
		}


		/******************************/
		/*  Read InstrInfo structures */
		/******************************/

		if (exp.iinfo && (exp.i_ext_entrsz >= sizeof (struct MMDInstrInfo)))
		{
			struct MMDInstrInfo instrinfo;

			if (Seek (fp, (LONG)exp.iinfo, OFFSET_BEGINNING) == -1)
				return ERR_READWRITE;

			for (i = 1; i <= exp.i_ext_entries; i++)
			{
				if (Read (fp, &instrinfo, sizeof (instrinfo)) != sizeof (instrinfo))
					return ERR_READWRITE;

				strncpy (inst[i].Name, instrinfo.name, MAXINSTNAME - 1);

				if (exp.i_ext_entrsz > sizeof (struct MMDInstrInfo))
					if (Seek (fp, exp.i_ext_entrsz - sizeof (struct MMDInstrInfo), OFFSET_CURRENT) == -1)
						return ERR_READWRITE;
			}
		}

		/******************************/
		/*       Read SongName        */
		/******************************/

		if (exp.songname && exp.songnamelen > 1)
		{
			ULONG size = min (exp.songnamelen, MAXSONGNAME-1);

			if (Seek (fp, (LONG)exp.songname, OFFSET_BEGINNING) == -1)
				return ERR_READWRITE;

			if (Read (fp, si->SongName, size) != size)
				return ERR_READWRITE;
		}
	}


	/******************************/
	/*        Read blocarr        */
	/******************************/

	if (mmd0.blockarr)
	{
		LONG *blockarr;

		DisplayAction (MSG_READING_PATTS);

		if (Seek (fp, (LONG)mmd0.blockarr, OFFSET_BEGINNING) == -1)
			return ERR_READWRITE;

		if (!(blockarr = AllocMem (song.numblocks * 4, MEMF_ANY)))
			return ERROR_NO_FREE_STORE;

		if (Read (fp, blockarr, song.numblocks * 4) != song.numblocks * 4)
		{
			FreeMem (blockarr, song.numblocks * 4);
			return ERR_READWRITE;
		}



		/***************/
		/* Read blocks */
		/***************/

		for (i = 0; i < song.numblocks; i++)
		{
			struct Pattern		*patt;
			struct Note			*note;
			struct MMD1block	 block;
			struct MMD0block	 mmd0block;
			struct BlockInfo	 blockinfo;
			ULONG mednote;

			if (DisplayProgress (i, song.numblocks))
			{
				FreeMem (blockarr, song.numblocks * 4);
				return ERROR_BREAK;
			}

			if (Seek (fp, (LONG)blockarr[i], OFFSET_BEGINNING) == -1)
				ShowMessage (MSG_ERR_CANT_LOAD_PATT, i);
			else
			{
				if (mmdtype == 0)
					len = Read (fp, &mmd0block, sizeof (struct MMD0block));
				else
					len = Read (fp, &block, sizeof (struct MMD1block));

				if (len != (mmdtype ? sizeof (struct MMD1block) : sizeof (struct MMD0block)))
					ShowMessage (MSG_ERR_CANT_LOAD_PATT, i);
				else
				{
					if (mmdtype == 0)	/* Convert MMD0 block */
					{
						block.numtracks	= mmd0block.numtracks;
						block.lines	= mmd0block.lines;
						block.info	= 0;
					}

					if (block.numtracks >= MAXTRACKS)
					{
						ShowMessage (MSG_PATT_TOO_MANY_TRACKS, i, MAXTRACKS);
						continue;
					}

					if (si->MaxTracks < block.numtracks)
						si->MaxTracks = block.numtracks;

					if (block.lines > MAXPATTLINES - 1)
					{
						ShowMessage (MSG_PATT_TOO_MANY_LINES, i, MAXPATTLINES);
						block.lines = MAXPATTLINES - 1;
					}

					if (!(patt = AddPattern (si, block.numtracks, block.lines + 1)))
					{
						FreeMem (blockarr, song.numblocks * 4);
						return ERROR_NO_FREE_STORE;
					}

					/***************/
					/* Read Tracks */
					/***************/

					for (k = 0; k < patt->Lines; k++)
					{
						for (j = 0; j < patt->Tracks; j++)
						{
							note = &patt->Notes[j][k];

							if (mmdtype == 0)
							{
								if (Read (fp, &mednote, MMD0ROW) != MMD0ROW)
									return ERR_READWRITE;

								mednote >>= 8;

								note->EffVal = mednote & 0xFF;
								note->EffNum = DecodeEff ((mednote >> 8) & 0x0F, &note->EffVal, song.flags, song.flags2);
								note->Note = ((mednote >> 16) & 0x3F);
								if (note->Note) note->Note += 12;
								note->Inst = ((mednote >> 12) & 0xF) |
									((mednote & (1<<22)) ? 0x20 : 0) | ((mednote & (1<<23)) ? 0x10 : 0);
							}
							else
							{
								if (Read (fp, &mednote, MMD1ROW) != MMD1ROW)
									return ERR_READWRITE;

								note->EffVal = mednote & 0xFF;
								note->EffNum = DecodeEff ((mednote >> 8) & 0xFF, &note->EffVal, song.flags, song.flags2);
								note->Inst = ((mednote >> 16) & 0x3F);
								note->Note = ((mednote >> 24) & 0x7F);

								if (note->Note) note->Note += 12;
							}
						}
					}	/* End for (patt->Tracks) */

					/******************/
					/* Read BlockInfo */
					/******************/

					if (block.info)
						if (Seek (fp, (LONG)block.info, OFFSET_BEGINNING) != -1);
						{
							if (Read (fp, &blockinfo, sizeof (blockinfo)) == sizeof(blockinfo))
							{
								if (blockinfo.blockname)
									if (Seek (fp, (LONG)blockinfo.blockname, OFFSET_BEGINNING) != -1);
									{
										Read (fp, patt->PattName, min (blockinfo.blocknamelen, MAXPATTNAME));
										patt->PattName[MAXPATTNAME-1] = '\0';	/* Ensure NULL-termination */
									}
							}
						}
				}
			}
		}	/* End for (song->numblocks) */

		FreeMem (blockarr, song.numblocks * 4);
	}



	/******************************/
	/*        Read smplarr        */
	/******************************/

	if (mmd0.smplarr)
	{
		LONG *smplarr;
		struct InstrHdr instrhdr;

		DisplayAction (MSG_READING_INSTS);

		if (Seek (fp, (LONG)mmd0.smplarr, OFFSET_BEGINNING) == -1)
			return ERR_READWRITE;

		if (!(smplarr = AllocMem (song.numsamples * 4, MEMF_ANY)))
			return ERROR_NO_FREE_STORE;

		if (Read (fp, smplarr, song.numsamples * 4) != song.numsamples * 4)
		{
			FreeMem (smplarr, song.numsamples * 4);
			return ERR_READWRITE;
		}


		/******************************/
		/*        Read samples        */
		/******************************/

		for (i = 1; i <= song.numsamples ; i++)
		{
			if (!smplarr[i-1]) continue;

			if (DisplayProgress (i, song.numsamples))
			{
				FreeMem (smplarr, song.numsamples * 4);
				return ERROR_BREAK;
			}

			if (Seek (fp, smplarr[i-1], OFFSET_BEGINNING) == -1)
				ShowMessage (MSG_ERR_CANT_LOAD_INST, i);
			else
			{
				if (Read (fp, &instrhdr, sizeof (instrhdr)) != sizeof (instrhdr))
					ShowMessage (MSG_ERR_CANT_LOAD_INST, i);
				else
				{
					switch (instrhdr.type)
					{
						case SAMPLE:
							inst[i].Length = instrhdr.length;

							if (!(inst[i].SampleData = (UBYTE *) AllocVec (inst[i].Length, MEMF_SAMPLE)))
							{
								ShowMessage (MSG_ERR_NO_MEM_FOR_INST, i);
								break;
							}

							if (Read (fp, inst[i].SampleData, inst[i].Length) != inst[i].Length)
								ShowMessage (MSG_ERR_CANT_LOAD_INST, i);

							/* Double sample data */
							if (song.flags & FLAG_8CHANNEL)
							{
								BYTE *data = inst[i].SampleData;

								for (j = 0; j < inst[j].Length; j++)
									*data++ <<= 1;
							}
							break;

						default:
							ShowMessage (MSG_ERR_NOT_A_SAMPLE, i);
							break;
					}
				}
			}
		}

		FreeMem (smplarr, song.numsamples * 4);
	}

	return RETURN_OK;
}



static __inline UBYTE DecodeEff (UBYTE eff, UBYTE *effval, UBYTE flags, UBYTE flags2)
{
	UBYTE i;

	switch (eff)
	{
		case 0x00:
			if (*effval) return EFF_ARPEGGIO;
			else return EFF_NULL;

		case 0x0C:	/* Volume */
			if (!(flags & FLAG_VOLHEX))
				/* Convert decimal volumes */
				*effval = (*effval & 0x0F) + (*effval >> 4) * 10;
			return EFF_SETVOLUME;

		case 0x0F:	/* Tempo */
			if (*effval == 0) return EFF_PATTERNBREAK;
			if (*effval <= 0x0A) return EFF_SETSPEED;
			if (*effval <= 0xF0)
			{
				*effval = (*effval * 4) / ((flags2 & FLAG2_BMASK) + 1);
				return EFF_SETTEMPO;
			}
			if (*effval == 0xF8)
			{
				*effval = 1;
				return EFF_MISC;	/* Filter off */
			}
			if (*effval == 0xF9)
			{
				*effval = 0;
				return EFF_MISC;	/* Filter on */
			}
			return EFF_NULL;

		default:
			for ( i = 0 ; i < MAXTABLEEFFECTS ; i++ )
				if (eff == Effects[i][2])
					return i;
	}

	return 0;
}

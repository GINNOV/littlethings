/*
**	SaveMED.c
**
**	Copyright (C) 1994,95 by Bernardo Innocenti
**
**	Save internal data to an MMD0 or MMD1 module.
**
**	Note: Sorry, this source is a bit of a mess, but the MMD
**	      format is really complex <grin>.
**
**	Structure of an MMD0/1/2 module as saved by SaveMED():
**
**	MMD0
**	MMD0song
**	MMD0exp
**	InstrExt[]
**	InstrInfo[]
**	<AnnoTxt>
**	<SongName>
**	NotationInfo
**	MMD0blockarr
**	MMD0samparr
**		<blocks>
**		<BlockInfo>		/* Only for MMD1/MMD2 */
**		<BlockName>		/* Only for MMD1/MMD2 */
**	<samples>
*/

#include <exec/types.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>

#include "XModule.h"
#include "Gui.h"
#include "OctaMed.h"


#define OFFSET_MMD0song		sizeof (struct MMD0)
#define OFFSET_MMD0exp		(sizeof (struct MMD0) + sizeof (struct MMD0song))
#define OFFSET_InstrExt		(sizeof (struct MMD0) + sizeof (struct MMD0song) + sizeof (struct MMD0exp))



LONG SaveMED (struct SongInfo *si, BPTR fp, UWORD mmd_type)
{
	struct Instrument	*inst = si->Inst;
	struct Pattern		*patt = si->PattData;
	ULONG	modlen, blockslen, instlen, blockptr, offset_blockarr,
			i, j, k, lastinstr;
	BOOL	halve_instr;

	if (GuiSwitches.Verbose)
		ShowMessage (MSG_WRITING_MMD, mmd_type + '0');

	DisplayAction (MSG_WRITING_HEADER);


	/*********************************/
	/* Calculate total patterns size */
	/*********************************/
	{
		if (mmd_type > 0)	/* MMD1 */
		{
			for (i = 0, blockslen = 0; i < si->NumPatterns ; i++)
			{
				blockslen += sizeof (struct MMD1block) +
					(MMD1ROW * patt[i].Lines * patt[i].Tracks) +
					(patt[i].PattName[0] ?
						 (sizeof (struct BlockInfo) + strlen (patt[i].PattName) + 1)
						 : 0);

				if (blockslen & 1) blockslen++; /* Pad to words */
			}
		}
		else	/* MMD0 */
		{
			for (i = 0, blockslen = 0; i < si->NumPatterns ; i++)
			{
				blockslen += sizeof (struct MMD0block) +
					(MMD0ROW * patt[i].Lines * patt[i].Tracks);

				if (blockslen & 1) blockslen++; /* Pad to words */
			}
		}
	}

	/* Find last used instrument */
	for (lastinstr = 63; lastinstr > 0 ; lastinstr--)
		if (inst[lastinstr].Length || inst[lastinstr].Name[0]) break;

	/* Calculate Total instruments size */
	for (i = 1, instlen = 0; i <= lastinstr; i++)
		instlen += (inst[i].Length) ? (si->Inst[i].Length + sizeof (struct InstrHdr)) : 0;

	/* Calculate blockarr offset */
	offset_blockarr = sizeof (struct MMD0) + sizeof (struct MMD0song) + sizeof (struct MMD0exp) +
		lastinstr * (sizeof (struct InstrExt) + sizeof (struct MMDInstrInfo));

	offset_blockarr += strlen (si->Author) + 1;
	if (offset_blockarr & 1) offset_blockarr++;		/* Pad to word */
	offset_blockarr += strlen (si->SongName) + 1;
	if (offset_blockarr & 1) offset_blockarr++;		/* Pad to word */

	/* Calculate Total module size */
	modlen =	offset_blockarr +
				si->NumPatterns * 4 +		/* blockarr		*/
				lastinstr * 4 +				/* samplearr	*/
				blockslen +
				instlen;

	/**********************************/
	/* Fill-in & write module header */
	/*********************************/
	{
		struct MMD0 mmd0;

		memset (&mmd0, 0, sizeof (mmd0));

		mmd0.id			= mmd_type ? ID_MMD1 : ID_MMD0;
		mmd0.modlen 	= modlen;
		mmd0.song		= (struct MMD0song *) OFFSET_MMD0song;
//		mmd0.reserved0	= 0;
		mmd0.blockarr	= (struct MMD0Block **) offset_blockarr;
//		mmd0.reserved1  = si->NumPatterns;
		mmd0.smplarr	= (struct InstrHdr **) (offset_blockarr + (si->NumPatterns * 4));
//		mmd0.reserved2	= lastinst * sizeof (LONG);
		mmd0.expdata	= (struct MMD0exp *) OFFSET_MMD0exp;
//		mmd0.reserved3	= 0;					/* expsize */
//		mmd0.pstate		= 0;					/* the state of the player */
		mmd0.pblock		= si->CurrentPatt;		/* current block */
//		mmd0.pline		= 0;					/* current line */
		mmd0.pseqnum	= si->CurrentPos;		/* current # of playseqlist */
		mmd0.actplayline= -1;					/* OBSOLETE!! DON'T TOUCH! */
//		mmd0.counter	= 0;					/* delay between notes */
//		mmd0.extra_songs= 0;

		/* Write file header */
		if (Write (fp, &mmd0, sizeof (mmd0)) != sizeof (mmd0))
			return ERR_READWRITE;

	}

	/************************************/
	/* Fill-in and write Song structure */
	/************************************/
	{
		struct MMD0song song;

		for (i = 0; i < 63 ; i++)
		{
			song.sample[i].rep			= inst[i+1].Repeat >> 1;
			song.sample[i].replen		= inst[i+1].Replen >> 1;
			song.sample[i].midich		= 0;
			song.sample[i].midipreset	= 0;
			song.sample[i].svol			= inst[i+1].Volume;
			song.sample[i].strans		= 0;
		}

		song.numblocks	= si->NumPatterns;
		song.songlen	= min (si->Length, 256);

		for (i = 0; i < song.songlen; i++)
			song.playseq[i] = si->Sequence[i];

		song.deftempo	= si->GlobalTempo;
		song.playtransp	= 0;
		halve_instr		= si->MaxTracks > 4;
		song.flags		= (halve_instr ? FLAG_8CHANNEL : 0) | FLAG_STSLIDE | FLAG_VOLHEX;
		song.flags2		= 3 | FLAG2_BPM;
		song.tempo2		= si->GlobalSpeed;

		for (i = 0; i <16; i++)
			song.trkvol[i] = 64;

		song.mastervol	= 64;
		song.numsamples	= lastinstr;

		if (Write (fp, &song, sizeof (song)) != sizeof (song))
			return ERR_READWRITE;
	}

	/*****************************/
	/* Write extension (MMD0exp) */
	/*****************************/
	{
		struct MMD0exp mmd0exp;
		LONG len;

		memset (&mmd0exp, 0, sizeof (mmd0exp));

		mmd0exp.exp_smp			= (struct InstrExt *) OFFSET_InstrExt;
		mmd0exp.s_ext_entries	= lastinstr;
		mmd0exp.s_ext_entrsz	= sizeof (struct InstrExt);
		mmd0exp.annotxt			= (STRPTR) (OFFSET_InstrExt + lastinstr * (sizeof (struct InstrExt) + sizeof (struct MMDInstrInfo)));
		mmd0exp.annolen			= strlen (si->Author) + 1;
		mmd0exp.iinfo			= (struct MMDInstrInfo *) (OFFSET_InstrExt + lastinstr * sizeof (struct InstrExt));
		mmd0exp.i_ext_entries	= lastinstr;
		mmd0exp.i_ext_entrsz	= sizeof (struct MMDInstrInfo);
		mmd0exp.songname		= mmd0exp.annotxt + mmd0exp.annolen + ((mmd0exp.annolen & 1) ? 1 : 0);
		mmd0exp.songnamelen		= strlen (si->SongName) + 1;

		if (Write (fp, &mmd0exp, sizeof (mmd0exp)) != sizeof (mmd0exp))
			return ERR_READWRITE;


		/************************/
		/* Write InstrExt array */
		/************************/
		{
			struct InstrExt instrext = { 0 };

			for (i = 1; i <= lastinstr; i++)
			{
				// instrext.hold				= 0;
				// instrext.decay				= 0;
				// instrext.suppress_midi_off	= 0;
				instrext.finetune				= si->Inst[i].FineTune;
				// instrext.default_pitch		= 0;
				// instrext.instr_flags			= 0;
				// instrext.long_midi_preset	= 0;
				// instrext.output_device		= 0;
				// instrext.reserved			= 0;

				if (Write (fp, &instrext, sizeof (instrext)) != sizeof (instrext))
					return ERR_READWRITE;
			}
		}

		/*************************/
		/* Write InstrInfo array */
		/*************************/
		{
			struct MMDInstrInfo instrinfo = { 0 };

			for (i = 1; i <= lastinstr; i++)
			{
				strcpy (instrinfo.name, si->Inst[i].Name);

				if (Write (fp, &instrinfo, sizeof (instrinfo)) != sizeof (instrinfo))
					return ERR_READWRITE;
			}
		}

		/* Write AnnoTxt */

		len = strlen (si->Author) + 1;
		if (len & 1) len++;	/* Pad to WORD */
		if (Write (fp, si->Author, len) != len)
			return ERR_READWRITE;

		/* Write SongName */

		len = strlen (si->SongName) + 1;
		if (len & 1) len++;	/* Pad to WORD */
		if (Write (fp, si->SongName, len) != len)
			return ERR_READWRITE;
	}

	/*************************************/
	/* Write pattern pointers (blockarr) */
	/*************************************/
	{
		blockptr = offset_blockarr + (si->NumPatterns * 4) + (lastinstr * 4);

		for (i = 0; i < si->NumPatterns; i++)
		{
			if (Write (fp, &blockptr, 4) != 4)
				return ERR_READWRITE;

			if (mmd_type)	/* MMD1 and up */
			{
				blockptr += sizeof (struct MMD1block) +
					(MMD1ROW * patt[i].Tracks * patt[i].Lines) +
					((patt[i].PattName[0]) ?
					(sizeof (struct BlockInfo) + strlen (patt[i].PattName) + 1)
					: 0);
			}
			else	/* MMD0 */
			{
				blockptr += sizeof (struct MMD0block) +
					(MMD0ROW * patt[i].Tracks * patt[i].Lines);
			}

			/* Pad to words */
			if (blockptr & 1)	blockptr++;
		}
	}

	/*************************************/
	/* Write sample pointers (samplearr) */
	/*************************************/
	{
		ULONG sampleptr = blockptr, x;

		for (i = 1; i <= lastinstr; i++)
		{
			x = ((inst[i].Length && inst[i].SampleData) ? sampleptr : 0);

			if (Write (fp, &x, 4) != 4)
				return ERR_READWRITE;

			if (x) sampleptr += inst[i].Length + sizeof (struct InstrHdr);
		}
	}

	/********************************/
	/* Write patterns (blocks) data */
	/********************************/
	{
		struct Note	*note;
		ULONG		 mednote;
		LONG		 blockinfoptr = offset_blockarr + (si->NumPatterns * 4) + (lastinstr * 4);
		UBYTE		 eff, effval;
		BOOL		 quiet = FALSE;


		DisplayAction (MSG_WRITING_PATTS);


		for (i = 0; i < si->NumPatterns; i++)
		{
			if (DisplayProgress (i, si->NumPatterns))
				return ERROR_BREAK;

			/* Write Header */

			if (mmd_type)	/* MMD1 and higher */
			{
				struct MMD1block	 block;

				blockinfoptr +=  sizeof (struct MMD1block) +
					(MMD1ROW * patt[i].Tracks * patt[i].Lines);

				block.numtracks = patt[i].Tracks;
				block.lines = patt[i].Lines - 1;

				/* Write BlockInfo only if this pattern has a name */
				block.info = (struct BlockInfo *)(patt[i].PattName[0] ? blockinfoptr : 0);

				if (Write (fp, &block, sizeof (block)) != sizeof (block))
					return ERR_READWRITE;
			}
			else	/* MMD0 */
			{
				struct MMD0block	 block;

				block.numtracks = patt[i].Tracks;
				block.lines = patt[i].Lines - 1;

				if (Write (fp, &block, sizeof (block)) != sizeof (block))
					return ERR_READWRITE;
			}


			/* Write Tracks */
			for (k = 0; k < patt[i].Lines; k++)
			{
				for (j = 0; j < patt[i].Tracks; j++)
				{
					note = &patt[i].Notes[j][k];
					eff = Effects[note->EffNum][2];

					if (note->EffNum == EFF_MISC)
					{
						switch (note->EffNum >> 4)
						{
							case 0x6:	/* Loop */
								eff = 0x16;
								effval = note->EffNum & 0x0F;
								break;
							case 0xC:	/* Note Cut */
								eff = 0x18;
								break;
							case 0xE:	/* Replay line */
								eff = 0x1E;
								effval = note->EffNum & 0x0F;
								break;
						}
					}
					else if (note->EffNum == EFF_PATTERNBREAK)
						effval = 0;
					else
						effval = note->EffVal;

				//	if (note->EffNum == EFF_SETTEMPO)
				//		effval /= 4;

					if (mmd_type)	/* MMD1 and up */
					{
						mednote = effval |
							((ULONG)eff << 8) |
							((ULONG)(note->Inst & 0x3F) << 16) |
							((ULONG)((note->Note ? (note->Note - 12) : 0) & 0x7F) << 24);

						if (Write (fp, &mednote, MMD1ROW) != MMD1ROW)
							return ERR_READWRITE;
					}
					else
					{
						if ((eff > 0x0F) && !quiet)
						{
							ShowMessage (MSG_WRONG_EFFECT_IN_MMD0, eff);
							quiet = TRUE;
						}

						mednote = (effval |
							((ULONG)(eff & 0x0F) << 8) |
							((ULONG)(note->Inst & 0x0F) << 12) |
							((ULONG)((note->Note ? (note->Note - 12) : 0) & 0x3F) << 16) |
							((ULONG)(note->Inst & 0x20) << 17) |
							((ULONG)(note->Inst & 0x10) << 19)) << 8;

						if (Write (fp, &mednote, MMD0ROW) != MMD0ROW)
							return ERR_READWRITE;
					}
				}
			}

			if (mmd_type)
			{
				if (patt[i].PattName[0])
				{
					/*****************************/
					/* Write BlockInfo structure */
					/*****************************/

					struct BlockInfo blockinfo;

					blockinfoptr += sizeof (blockinfo);

					memset (&blockinfo, 0, sizeof (blockinfo));
					blockinfo.blockname = (UBYTE *)blockinfoptr;
					blockinfo.blocknamelen = strlen (patt[i].PattName) + 1;

					if (Write (fp, &blockinfo, sizeof (blockinfo)) != sizeof (blockinfo))
						return ERR_READWRITE;

					if (Write (fp, patt[i].PattName, blockinfo.blocknamelen) != blockinfo.blocknamelen)
						return ERR_READWRITE;

					blockinfoptr += sizeof (struct BlockInfo) + blockinfo.blocknamelen;

					/* Pad to words */
					if (blockinfoptr & 1)
					{
						UBYTE dummy;

						if (Write (fp, &dummy, 1) != 1)
							return ERR_READWRITE;

						blockinfoptr++;
					}
				}
			}
			else	/* MMD0 */
			{
				/* Add a pad byte when length is not even */
				if ((patt[i].Lines * patt[i].Tracks) & 1)
				{
					UBYTE dummy = 0;

					if (Write (fp, &dummy, 1) != 1)
						return ERR_READWRITE;
				}
			}
		}	/* End for (si->NumPatterns) */
	}


	/**********************/
	/* Write samples data */
	/**********************/
	{
		struct InstrHdr instrhdr;
		UBYTE *samp;
		LONG l;
		BOOL free_samp;

		DisplayAction (MSG_WRITING_INSTDATA);

		for (i = 1; i <= lastinstr; i++)
		{
			free_samp = FALSE;

			l = inst[i].Length;
			if (!l || (!inst[i].SampleData)) continue;

			if (DisplayProgress (i, lastinstr))
				return ERROR_BREAK;

			if (halve_instr)
			{
				if (samp = AllocVec (l, MEMF_ANY))
				{
					/* Halve Volume */
					for (k = 0; k < l; k++)
						samp[k] = inst[i].SampleData[k] >> 1;

					free_samp = TRUE;	/* Free this buffer when you are done */
				}
				else
				{
					ShowMessage (MSG_NO_MEM_TO_HALVE, i);
					samp = inst[i].SampleData;
				}
			}
			else samp = inst[i].SampleData;

			instrhdr.length = l;
			instrhdr.type = SAMPLE;

			if (Write (fp, &instrhdr, sizeof (instrhdr)) != sizeof (instrhdr))
				return ERR_READWRITE;

			if (l)
				if (Write (fp, samp, l) != l)
					return ERR_READWRITE;

			if (free_samp)
				FreeVec (samp);
		}
	}

	return RETURN_OK;
}

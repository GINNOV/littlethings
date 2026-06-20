/*
**	GetS3M.c
**
**	Copyright (C) 1995 Bernardo Innocenti
**
**	Load a ScreamTracker 3.01 module with any number of tracks.
**	Only sample instruments are supported.
*/

#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>

#include "XModule.h"
#include "Gui.h"

/* Local function prototypes */
static __inline UBYTE DecodeEff (UBYTE eff, UBYTE effval);


/* Convert an Intel style WORD to Motorola format */
#define I2M(x) ( (UWORD) ( (((UWORD)(x)) >> 8) | (((UWORD)(x)) << 8) ) )

/* Convert an Intel style LONG to Motorola format */
#define I2ML(x) ( I2M((x)>>16) | (I2M((x))<<16) )

/* Convert a ParaPointer to a normal file offset */
#define PARA(x) (((ULONG)I2M(x)) << 4)

/* Convert a 3-byte ParaPointer to a normal file offset */
#define PARAL(x) (( (ULONG)x[0]<<16 | (ULONG)x[2]<<8 | (ULONG)x[1] ) << 4)


struct S3MHeader
{
	UBYTE SongName[28];
	UBYTE Constant;
	UBYTE Type;
	UWORD Pad0;
	UWORD OrdNum;		/* Number of positions */
	UWORD InsNum;
	UWORD PatNum;
	UWORD Flags;
	UWORD CreatedWith;
	UWORD FileFormat;	/* See below */
	ULONG ID;			/* Should be ID_SCRM */
	UBYTE GlobalVolume;
	UBYTE InitialSpeed;
	UBYTE InitialTempo;
	UBYTE MasterVolume;
	UBYTE Pad1[10];
	UWORD Special;
	UBYTE Channels[32];
};

/* Values for S3MHeader->FileFormat */

#define S3MFF_SIGNEDSAMPLES		1
#define S3MFF_UNSIGNEDSAMPLES	2



struct S3MSamp
{
	UBYTE Type;			/* See ITYPE_#? definitions below.	*/
	UBYTE DosName[12];
	UBYTE MemSeg[3];	/* :-))) Parapointer to sample data	*/
	ULONG Length;
	ULONG LoopBeg;
	ULONG LoopEnd;
	UBYTE Volume;
	UBYTE Pad0;
	UBYTE Pack;			/* See SPACK_#? definitions below. */
	UBYTE Flags;		/* See SFLAG_#? definitions below. */
	ULONG C2Spd;
	ULONG Pad1;
	UWORD Reserved0[2];
	ULONG Reserved1[1];
	UBYTE SampleName[28];
	ULONG SampID;		/* Should be ID_SCRS */
};


/* S3M Instrument types */

#define ITYPE_NONE			0
#define ITYPE_SAMPLE		1
#define ITYPE_ADLIB_MELODY	2
#define ITYPE_ADLIB_SNARE	3
#define ITYPE_ADLIB_TOM		4
#define ITYPE_ADLIB_CYMBAL	5
#define ITYPE_ADLIB_HIHAT	6


/* S3M Sample packing */

#define SPACK_NONE			0
#define SPACK_ADPCM			1	/* Unsupported by ST3.01 */


/* S3M Sample Flags */
#define SFLAG_LOOP			1
#define SFLAG_STEREO		2	/* Unsupported by ST3.01 */
#define SFLAG_16BIT			4	/* Unsupported by ST3.01 */


/* S3M IDs */

#define ID_SCRM MAKE_ID('S','C','R','M')	/* ScreamTracker Module	*/
#define ID_SCRS MAKE_ID('S','C','R','S')	/* ScreamTracker Sample	*/
#define ID_SCRI MAKE_ID('S','C','R','I')	/* ScreamTracker Instr	*/




LONG GetS3M (struct SongInfo *si, BPTR fp)
{
	UWORD				*ParaInst,
						*ParaPatt;
	struct Note			*note;
	struct Pattern		*patt;
	struct S3MHeader	 s3mhd;

	ULONG		i, j;			/* Loop counters */
	LONG		err = 0;
	UWORD		numchannels = 0, w;
	LONG		l;				/* Dummy read buffer */


	/* Read module header */
	if (Read (fp, &s3mhd, sizeof (s3mhd)) != sizeof (s3mhd))
		return ERR_READWRITE;

	/* Fix Intel WORD format */
	s3mhd.OrdNum		= I2M (s3mhd.OrdNum);
	s3mhd.InsNum		= I2M (s3mhd.InsNum);
	s3mhd.PatNum		= I2M (s3mhd.PatNum);
	s3mhd.Flags			= I2M (s3mhd.Flags);
	s3mhd.CreatedWith	= I2M (s3mhd.CreatedWith);
	s3mhd.FileFormat	= I2M (s3mhd.FileFormat);
	s3mhd.Special		= I2M (s3mhd.Special);


	for (i = 0; i < 32; i++)
		if (s3mhd.Channels[i] != 255) numchannels++;

	si->MaxTracks = numchannels;

	if (GuiSwitches.Verbose)
		ShowMessage (MSG_READING_S3M, numchannels);



	/* Get the song name */
	strncpy (si->SongName, s3mhd.SongName, 28);
	si->SongName[28] = '\0';	/* Ensure Null-termination */


	/* Read the pattern sequence */

	if (!SetSongLen (si, s3mhd.OrdNum))
		return ERROR_NO_FREE_STORE;

	for (i = 0; i < s3mhd.OrdNum; i++)
	{
		if ((l = FGetC (fp)) != -1L)
			si->Sequence[i] = l;
		else
			return ERR_READWRITE;
	}

	if (s3mhd.OrdNum & 1) FGetC (fp);	/* Keep WORD alignament */

	if (!Flush (fp))
		return ERR_READWRITE;



	/*******************/
	/* Get Instruments */
	/*******************/

	DisplayAction (MSG_READING_INSTS);

	/* Get parapointers to instruments */

	if (!(ParaInst = AllocVec (s3mhd.InsNum * sizeof (UWORD), MEMF_PUBLIC)))
		return ERROR_NO_FREE_STORE;

	if (!(ParaPatt = AllocVec (s3mhd.PatNum * sizeof (UWORD), MEMF_PUBLIC)))
	{
		FreeVec (ParaInst);
		return ERROR_NO_FREE_STORE;
	}

	if (Read (fp, ParaInst, s3mhd.InsNum * sizeof (UWORD)) == s3mhd.InsNum * sizeof (UWORD))
	{
		if (Read (fp, ParaPatt, s3mhd.PatNum * sizeof (UWORD)) == s3mhd.PatNum * sizeof (UWORD))
		{
			struct S3MSamp samp;

			for (i = 0; i < s3mhd.InsNum; i++)
			{
				struct Instrument *inst = &si->Inst[i+1];

				if (DisplayProgress (i+1, s3mhd.InsNum))
				{
					err = ERROR_BREAK;
					break;
				}

				if (Seek (fp, PARA(ParaInst[i]), OFFSET_BEGINNING) == -1)
				{
					err = ERR_READWRITE;
					break;
				}
				else
				{
					if (Read (fp, &samp, sizeof (samp)) != sizeof (samp))
					{
						err = ERR_READWRITE;
						break;
					}

					/* Get instrument name */

					strncpy (inst->Name, samp.SampleName, 28);
					inst->Name[27] = '\0';	/* Ensure Null-termination */

					if (samp.Type == 0)
						;	/* Do nothing */
					else if (samp.Type == ITYPE_SAMPLE)
					{
						if (samp.Pack != SPACK_NONE)
							ShowMessage (MSG_UNKNOWN_SAMPLE_COMPRESSION, i + 1);

						if (samp.Flags & SFLAG_STEREO)
							ShowMessage (MSG_INST_IS_STEREO, i + 1);

						if (samp.Flags & SFLAG_16BIT)
						{
							ShowMessage (MSG_INST_IS_16BIT, i + 1);
							continue;
						}


						/* Get instrument Length, Volume and Loop */

						inst->Length = I2ML(samp.Length);
						inst->Volume = (samp.Volume > 64) ? 64 : samp.Volume;
						if (samp.Flags & SFLAG_LOOP)
						{
							inst->Repeat = I2ML(samp.LoopBeg);
							inst->Replen = I2ML(samp.LoopEnd) - I2ML(samp.LoopBeg) - 2;
						}

						/* Seek where the sample is stored */
						if (Seek (fp, PARAL(samp.MemSeg), OFFSET_BEGINNING) == -1)
						{
							err = ERR_READWRITE;
							break;
						}

						/* Allocate memory for sample */

						if (!(inst->SampleData = AllocVec (inst->Length, MEMF_SAMPLE)))
						{
							err = ERROR_NO_FREE_STORE;
							inst->Length = 0;
							break;
						}

						/* Load sample data */

						if (Read (fp, inst->SampleData, inst->Length) != inst->Length)
						{
							err = ERR_READWRITE;
							break;
						}

						if (s3mhd.FileFormat >= S3MFF_UNSIGNEDSAMPLES)
						{
							/* unsigned -> signed  conversion */
							for (j = 0; j < inst->Length; j++)
								inst->SampleData[j] ^= 0x80;
						}
					}
					else if (samp.Type <= ITYPE_ADLIB_HIHAT)
					{
						static UBYTE *ADLibNames[] =
						{
							"Melody",
							"Snare Drum",
							"Tom",
							"Cymbal",
							"Hihat"
						};

						ShowMessage (MSG_ADLIB_INSTR, i + 1, ADLibNames[samp.Type - 2]);
					}
					else
						ShowMessage (MSG_ERR_NOT_A_SAMPLE, i + 1);
				}
			}
		}
		else err = ERR_READWRITE;
	}
	else err = ERR_READWRITE;

	FreeVec (ParaInst);

	GuessAuthor(si);

	if (err)
	{
		FreeVec (ParaPatt);
		return err;
	}


	/****************/
	/* Get Patterns */
	/****************/

	DisplayAction (MSG_READING_PATTS);

	for (i = 0; i < s3mhd.PatNum; i++)
	{
		if (DisplayProgress (i + 1, s3mhd.PatNum))
		{
			err = ERROR_BREAK;
			break;
		}

		if (Seek (fp, PARA(ParaPatt[i]), OFFSET_BEGINNING) == -1)
		{
			err = ERR_READWRITE;
			break;
		}
		else
		{
			LONG ch = 0;	/* Channel number */

			/* Read size */

			if (Read (fp, &w, sizeof (UWORD)) != sizeof (UWORD))
			{
				err = ERR_READWRITE;
				break;
			}

			if (patt = AddPattern (si, numchannels, 64))
			{
				/* Loop on rows */
				for (j = 0; (j < 64) && (ch != -1L); j++)
				{
					while ((ch = FGetC (fp)) != -1L)
					{
						if (ch == 0)	/* End of row */
							break;

						if ((ch & 31) >= numchannels)
						{
							ShowMessage (MSG_TRACK_OUT_OF_RANGE, ch & 31);
							note = &patt->Notes[0][j];
						}
						else
							note = &patt->Notes[ch & 31][j];

						if (ch & 32)	/* Note and instrument follows */
						{
							l = FGetC (fp);
							if (l != 255)
								note->Note = ((((l >> 4) - 2) * 12) | (l & 0x0F)) + 1;
							note->Inst = FGetC (fp);
						}
						if (ch & 64)	/* Volume */
						{
							l = FGetC (fp);
							note->EffNum = EFF_SETVOLUME;
							note->EffVal = l;
						}

						if (ch & 128)	/* Command and Info */
						{
							note->EffNum = FGetC (fp);
							note->EffVal = FGetC (fp);
							note->EffNum = DecodeEff (note->EffNum, note->EffVal);
						}
					}
				}

				if (ch == -1)
				{
					err = ERR_READWRITE;
					break;
				}
			}
			else
			{
				err = ERROR_NO_FREE_STORE;
				break;
			}

			/* Flush (fp); */
		}
	}

	FreeVec (ParaPatt);

	return err;
}



static __inline UBYTE DecodeEff (UBYTE eff, UBYTE effval)
{
	UBYTE i;

	if ((eff == 0) && effval) /* Speed/Tempo */
	{
		if (effval < 0x20)
			return EFF_SETSPEED;
		else
			return EFF_SETTEMPO;
	}

	for (i = 0 ; i < MAXTABLEEFFECTS; i++)
		if (eff == Effects[i][3])
			return i;

	return 0;
}

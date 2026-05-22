/*
**	Instr.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Instrument loading/saving/handling routines.
*/

#define IFFPARSE_V37_NAMES_ONLY

#include <exec/memory.h>
#include <libraries/iffparse.h>
#include <libraries/maud.h>
#include <datatypes/soundclass.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/iffparse_protos.h>
#include <clib/datatypes_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/iffparse_pragmas.h>
#include <pragmas/datatypes_pragmas.h>

#include "XModule.h"
#include "Gui.h"


#define UNITY 0x10000L


/* Local function prototypes */
static LONG DTLoadInstrument (struct Instrument *inst, const STRPTR filename);
static LONG LoadMAUDInstrument (struct Instrument *inst, struct IFFHandle *iff, const STRPTR filename);
static LONG RawLoadInstrument (struct Instrument *inst, const STRPTR filename, UWORD mode);
static void VhdrToInstr (struct VoiceHeader *vhdr, struct Instrument *inst);
static void InstrToVhdr (struct Instrument *inst, struct VoiceHeader *vhdr);
static BYTE D1Unpack (UBYTE source[], LONG n, BYTE dest[], BYTE x);
static void DUnpack (UBYTE source[], LONG n, BYTE dest[]);



struct Library *DataTypesBase = NULL;



LONG LoadInstrument (struct Instrument *inst, const STRPTR filename)

/* Load an instrument file to the slot pointed by inst.
 * Will use DataTypes if available, otherwise will use
 * the built-in loaders.
 */
{
	LONG err = IFFERR_NOTIFF;

	/* Try to load with DataTypes */

	if (GuiSwitches.UseDataTypes)
		if (DataTypesBase = OpenLibrary ("datatypes.library", 39L))
		{
			err = DTLoadInstrument (inst, filename);
			CloseLibrary (DataTypesBase);	DataTypesBase = NULL;
		}


	/* Try again using built-in loaders */

	if (err)
	{
		struct IFFHandle *iff;

		if (iff = AllocIFF())
		{
			if (iff->iff_Stream = (ULONG) Open (filename, MODE_OLDFILE))
			{
				InitIFFasDOS (iff);

				if (!(err = OpenIFF (iff, IFFF_READ)))
				{
					if (!(err = ParseIFF (iff, IFFPARSE_RAWSTEP)))
					{
						LONG type = CurrentChunk (iff)->cn_Type;
						switch (type)
						{
							case ID_8SVX:
								strncpy (inst->Name, FilePart (filename), MAXINSTNAME);
								err = Load8SVXInstrument (inst, iff);
								break;

							case ID_MAUD:
								err = LoadMAUDInstrument (inst, iff, filename);
								break;

							default:
							{
								UBYTE buf[5];

								IDtoStr (type, buf);
								ShowMessage (MSG_UNKNOWN_IFF, buf);
								err = ERROR_OBJECT_WRONG_TYPE;
								break;
							}
						}
					}
				}

				Close (iff->iff_Stream);
			}
			else err = IoErr();

			FreeIFF (iff);
		}
		else err = ERROR_NO_FREE_STORE;
	}

	if (err == IFFERR_MANGLED || err == IFFERR_SYNTAX)
		ShowMessage (MSG_ILLEGAL_IFF_STRUCTURE);

	if (err == IFFERR_NOTIFF)
	{
		LONG mode;

		if (mode = ShowRequestArgs (MSG_SELECT_RAW_MODE,
		MSG_RAW_MODES, NULL))
			err = RawLoadInstrument (inst, filename, mode);
		else err = 0;
	}

	UpdateInstrList();

	if (err) LastErr = err;
	return err;
}



static LONG DTLoadInstrument (struct Instrument *inst, const STRPTR filename)
{
	Object *dto;
	LONG err;
	UBYTE *instname;

	if (dto = NewDTObject (filename,
		DTA_GroupID, GID_SOUND,
		TAG_DONE))
	{
		struct VoiceHeader *vhdr;
		LONG Len;
		UBYTE *Sample;
		UBYTE *errorstring;

		if (GetDTAttrs (dto,
			SDTA_VoiceHeader, &vhdr,
			SDTA_SampleLength, &Len,
			SDTA_Sample, &Sample,
			DTA_Name, &instname,
			TAG_DONE) == 4)
		{
			/* Detach sample from DataType Object, so it won't
			 * be freed when we dispose the object.
			 */
			SetDTAttrs (dto, NULL, NULL,
				SDTA_Sample, NULL,
				TAG_DONE);

			/* Free old sample */
			FreeInstr (inst);

			/* Fill-in Instrument structure */
			inst->SampleData = Sample;
			inst->Repeat = vhdr->vh_OneShotHiSamples;
			inst->Length = Len;
			inst->Replen = vhdr->vh_RepeatHiSamples;

			/* The sound.datatype returns volumes in
			 * the normal Amiga range 0-64.  This
			 * behavior is different from 8SVX
			 * specifications, where the maximum
			 * volume is $10000.
			 */
			inst->Volume = vhdr->vh_Volume;
			strncpy (inst->Name, instname, MAXINSTNAME);
		}
		else err = RETURN_FAIL;


		if (GetDTAttrs (dto,
			DTA_ErrorString, &errorstring,
			TAG_DONE) == 1)
			ShowMessage (MSG_DATATYPES_ERROR, errorstring);

		DisposeDTObject (dto);
	}
	else err = IoErr();

	return err;
}



LONG Load8SVXInstrument (struct Instrument *inst, struct IFFHandle *iff)

/* Load an IFF 8SVX file to the instrument slot pointed by inst.
 * Can decode Fibonacci Delta encoded samples.
 */
{
	struct ContextNode	*cn;
	struct VoiceHeader vhdr;
	LONG err;
	BOOL is_valid_8svx = FALSE;

	static LONG stopchunks[] =
	{
		ID_8SVX, ID_VHDR,
		ID_8SVX, ID_BODY,
		ID_8SVX, ID_NAME
	};


	if (err = StopChunks (iff, stopchunks, 3))
		return err;

	if (err = StopOnExit (iff, ID_8SVX, ID_FORM))
		return err;

	while (1)
	{
		if (err = ParseIFF (iff, IFFPARSE_SCAN))
		{
			if (err == IFFERR_EOF || err == IFFERR_EOC) err = RETURN_OK;
			break; /* Free resources & exit */
		}

		if ((cn = CurrentChunk (iff)) && (cn->cn_Type == ID_8SVX))
		{
			switch (cn->cn_ID)
			{
				case ID_VHDR:
					if ((err = ReadChunkBytes (iff, &vhdr, sizeof (vhdr))) !=
						sizeof (vhdr)) return err;

					/* Fill-in Instrument structure */
					VhdrToInstr (&vhdr, inst);

					is_valid_8svx = TRUE;
					break;

				case ID_BODY:
					/* Free old sample */
					FreeVec (inst->SampleData);

					inst->Length = cn->cn_Size;
					if (!(inst->SampleData = AllocVec (cn->cn_Size, MEMF_SAMPLE)))
						return ERROR_NO_FREE_STORE;

					/* We only require that at least some data is
					 * read.  This way if, say, you have a corrupted
					 * 8SVX file, you can still load part of the
					 * instrument data.
					 */
					if ((err = ReadChunkBytes (iff, inst->SampleData,
						cn->cn_Size)) < 0) return err;

					is_valid_8svx = TRUE;
					break;

				case ID_NAME:
					ReadChunkBytes (iff, inst->Name, min(cn->cn_Size, MAXINSTNAME));
					inst->Name[MAXINSTNAME-1] = '\0'; /* Ensure string termination */
					break;

				default:
					break;
			}
		}
	}

	if (is_valid_8svx)
	{
		if (!err)
		{
			if (vhdr.vh_Compression == CMP_FIBDELTA)
			{
				BYTE *buf;
				if (buf = AllocVec (inst->Length * 2, MEMF_SAMPLE))
				{
					DUnpack (inst->SampleData, inst->Length + 2, buf);
					FreeVec (inst->SampleData);
					inst->SampleData = buf;
					inst->Length *= 2;
				}
			}
			else if (vhdr.vh_Compression != CMP_NONE)
				ShowMessage (MSG_UNKNOWN_COMPRESSION);
		}
	}
	else err = IFFERR_NOTIFF;

	return err;
}



/* Number of samples loaded & processed at one time */
#define MAUDBLOCKSIZE 32768

static LONG LoadMAUDInstrument (struct Instrument *inst, struct IFFHandle *iff, const STRPTR filename)

/* Load an IFF MAUD file to the instrument slot pointed by <inst>.
 * MAUD is the standard file format for Macrosystem's audio boards
 * Toccata and Maestro.
 */
{
	struct ContextNode	*cn;
	struct MaudHeader mhdr;
	LONG err;
	BOOL	name_loaded = FALSE,
			is_valid_maud = FALSE;

	static LONG stopchunks[] =
	{
		ID_MAUD, ID_MHDR,
		ID_MAUD, ID_MDAT,
		ID_MAUD, ID_NAME
	};


	if (err = StopChunks (iff, stopchunks, 3))
		return err;

	if (err = StopOnExit (iff, ID_MAUD, ID_FORM))
		return err;


	while (1)
	{
		if (err = ParseIFF (iff, IFFPARSE_SCAN))
		{
			if (err == IFFERR_EOF || err == IFFERR_EOC) err = RETURN_OK;
			break; /* Free resources & exit */
		}

		if ((cn = CurrentChunk (iff)) && (cn->cn_Type == ID_MAUD))
		{
			switch (cn->cn_ID)
			{
				case ID_MHDR:
					if ((err = ReadChunkBytes (iff, &mhdr, sizeof (mhdr))) !=
						sizeof (mhdr)) return err;

					if (mhdr.mhdr_SampleSizeU != 8 && mhdr.mhdr_SampleSizeU != 16)
					{
						ShowMessage (MSG_SAMPLE_WRONG_SIZE, mhdr.mhdr_SampleSizeU);
						return IFFERR_SYNTAX;
					}

					if (mhdr.mhdr_ChannelInfo != MCI_MONO)
					{
						ShowMessage (MSG_SAMPLE_NOT_MONO, mhdr.mhdr_ChannelInfo);
						return IFFERR_SYNTAX;
					}

					if (mhdr.mhdr_Channels != 1)
					{
						ShowMessage (MSG_SAMPLE_WRONG_NUMBER_OF_CHANNELS, mhdr.mhdr_Channels);
						return IFFERR_SYNTAX;
					}

					is_valid_maud = TRUE;
					break;

				case ID_MDAT:
				{
					ULONG i;

					/* Free old sample */
					FreeVec (inst->SampleData);

					inst->Length = (mhdr.mhdr_Samples + 1) & (~1);
					if (!(inst->SampleData = AllocVec (inst->Length , MEMF_SAMPLE)))
					{
						inst->Length = 0;
						return ERROR_NO_FREE_STORE;
					}


					if (mhdr.mhdr_SampleSizeU == 8)				/* 8 bit */
					{
						/* We only require that at least some data is
						 * read.  This way if, say, you have a corrupted
						 * MAUD file, you can still load part of the
						 * sample data.
						 */
						if ((err = ReadChunkBytes (iff, inst->SampleData,
							inst->Length)) == 0) return err;

						SampChangeSign8 (inst->SampleData, inst->Length);

					}
					else if (mhdr.mhdr_SampleSizeU == 16)		/* 16 bit */
					{
						WORD *tmp;
						ULONG actual, current = 0;

						if (!(tmp = AllocMem (MAUDBLOCKSIZE * sizeof (WORD), MEMF_ANY)))
							return ERROR_NO_FREE_STORE;

						for (;;)
						{
							actual = ReadChunkBytes (iff, tmp, MAUDBLOCKSIZE * sizeof (WORD)) >> 1;

							if (actual == 0) break;

							// Filter (tmp, actual);

							/* Convert 16bit signed data to 8bit signed data */
							for (i = 0; (i < actual) && (current < mhdr.mhdr_Samples); i++, current++)
								inst->SampleData[current] = tmp[i] >> 8;
						}

						FreeMem (tmp, MAUDBLOCKSIZE * sizeof (WORD));
					}

					is_valid_maud = TRUE;
					break;
				}

				case ID_NAME:
					ReadChunkBytes (iff, inst->Name, min(cn->cn_Size, MAXINSTNAME));
					inst->Name[MAXINSTNAME-1] = '\0'; /* Ensure string termination */
					if (inst->Name[0])
						name_loaded = TRUE;
					break;

				default:
					break;
			}
		}
	}

	if (is_valid_maud)
	{
		/* Put the file name if the optional NAME propriety is missing */
		if (!name_loaded) strncpy (inst->Name, FilePart (filename), MAXINSTNAME);

		if (!err)
		{
			if (mhdr.mhdr_Compression == CMP_FIBDELTA)
			{
				BYTE *buf;
				if (buf = AllocVec (inst->Length * 2, MEMF_SAMPLE))
				{
					DUnpack (inst->SampleData, inst->Length + 2, buf);
					FreeVec (inst->SampleData);
					inst->SampleData = buf;
					inst->Length *= 2;
				}
			}
			else if (mhdr.mhdr_Compression != CMP_NONE)
				ShowMessage (MSG_UNKNOWN_COMPRESSION);
		}
	}
	else err = IFFERR_NOTIFF;

	return err;
}



static LONG RawLoadInstrument (struct Instrument *inst, const STRPTR filename, UWORD mode)

/* Load a raw file to the instrument slot pointed by inst.
 * mode   1 - signed 8bit
 *        2 - unsigned 8bit
 */
{
	BPTR lock, fh;
	struct FileInfoBlock *fib;
	LONG err = 0;
	ULONG len;

	if (lock = Lock (filename, ACCESS_READ))
	{
		/* Get file size */
		if (fib = AllocDosObject (DOS_FIB, NULL))
		{
			if (Examine (lock, fib))
				len = fib->fib_Size;
			else err = IoErr();
			FreeDosObject (DOS_FIB, fib);
		}
		else err = ERROR_NO_FREE_STORE;

		if (!err)
		{
			if (fh = OpenFromLock (lock))
			{
				/* Free old sample */
				FreeInstr (inst);

				if (inst->SampleData = AllocVec (len, MEMF_SAMPLE))
				{
					/* We do not check for failure here to
					 * be more error tolerant.  This way you
					 * can load at least part of an instrument
					 * from a corrupted file ;-)
					 */
					Read (fh, inst->SampleData, len);

					inst->Length = len;
					strncpy (inst->Name, FilePart (filename), MAXINSTNAME);
					inst->Repeat = inst->Replen = 0;
					inst->Volume = 64;

					if (mode == 2)
						SampChangeSign8 (inst->SampleData, inst->Length);
				}
				else
				{
					inst->Length = 0;
					err = ERROR_NO_FREE_STORE;
				}

				Close (fh);
			}
			else err = IoErr();
		}

		UnLock (lock);
	}
	else err = IoErr();

	return err;
}



LONG SaveInstrument (struct Instrument *inst, const STRPTR filename)
{
	LONG err;
	struct IFFHandle *iff;


	if (iff = AllocIFF())
	{
		if (iff->iff_Stream = (ULONG) Open (filename, MODE_NEWFILE))
		{
			InitIFFasDOS (iff);

			if (!(err = OpenIFF (iff, IFFF_WRITE)))
			{
				err = Save8SVXInstrument (inst, iff);
				CloseIFF (iff);
			}

			Close (iff->iff_Stream);
		}
		else err = IoErr();

		FreeIFF (iff);
	}
	else return ERROR_NO_FREE_STORE;

	if (!err)
	{
		if (GuiSwitches.InstrSaveIcons)
			/* Write icon */
			PutIcon ("def_Instrument", filename);
	}
	else
	{
		/* Remove incomplete file */
		LastErr = err;
		DeleteFile (filename);
	}

	return (err);
}



LONG Save8SVXInstrument (struct Instrument *inst, struct IFFHandle *iff)

/* Save the instrument pointed by inst to a standard
 * IFF 8SVX file.
 */
{
	struct VoiceHeader vhdr;
	LONG err;


	/* Write 8SVX */

	if (err = PushChunk (iff, ID_8SVX, ID_FORM, IFFSIZE_UNKNOWN))
		return err;

	/* Write VHDR */

	InstrToVhdr (inst, &vhdr);

	if (err = PushChunk (iff, ID_8SVX, ID_VHDR, sizeof (vhdr)))
		return err;
	if ((err = WriteChunkBytes (iff, &vhdr, sizeof (vhdr))) !=
		sizeof (vhdr))
		return err;
	if (err = PopChunk (iff)) return err;	/* Pop VHDR */


	/* Write NAME */
	{
		ULONG l = strlen (inst->Name) + 1;

		if (err = PushChunk (iff, ID_8SVX, ID_NAME, l))
			return err;
		if ((err = WriteChunkBytes (iff, inst->Name, l)) != l)
			return err;
		if (err = PopChunk (iff)) return err;	/* Pop NAME */
	}

	/* Write BODY */

	if (inst->SampleData)
	{
		if (PushChunk (iff, ID_8SVX, ID_BODY, inst->Length))
			return err;
		if ((err = WriteChunkBytes (iff, inst->SampleData, inst->Length)) !=
			inst->Length) return err;
		if (err = PopChunk (iff)) return err;	/* Pop BODY */
	}

	PopChunk (iff);	/* Pop 8SVX */

	return err;
}



static void VhdrToInstr (struct VoiceHeader *vhdr, struct Instrument *inst)

/* Convert data passed in a VoiceHeader structure to an
 * XModule Instrument structure
 */
{
	if (vhdr->vh_RepeatHiSamples)
	{
		/* Loop */
		inst->Repeat = vhdr->vh_OneShotHiSamples;
		inst->Replen = vhdr->vh_RepeatHiSamples;
	}
	else
	{
		/* No Loop */
		inst->Repeat = 0;
		inst->Replen = 0;
	}

	inst->Volume = (vhdr->vh_Volume * 64) / UNITY;
}


static void InstrToVhdr (struct Instrument *inst, struct VoiceHeader *vhdr)

/* Convert data contained in XModule Instrument structure to a standard
 * VoiceHeader structure.
 */
{
	if (inst->Replen)
	{
		/* Loop */
		vhdr->vh_OneShotHiSamples = inst->Repeat;
		vhdr->vh_RepeatHiSamples = inst->Replen;
	}
	else
	{
		/* No Loop */
		vhdr->vh_OneShotHiSamples = inst->Length;
		vhdr->vh_RepeatHiSamples = 0;
	}

	vhdr->vh_SamplesPerHiCycle = 0;
	vhdr->vh_SamplesPerSec = 8363;
	vhdr->vh_Octaves = 1;
	vhdr->vh_Compression = CMP_NONE;
	vhdr->vh_Volume = (inst->Volume * UNITY) / 64;
}



void FreeInstr (struct Instrument *inst)
{
	if (inst->SampleData) FreeVec (inst->SampleData);

	memset (inst, 0, sizeof (struct Instrument));
/*	inst->SampleData	= NULL;
	inst->Length		= 0;
	inst->Name[0]		= '\0';
	inst->InstType		= 0;
*/
}



void OptimizeInstruments (struct SongInfo *si)

/* Remove useless sample data (cut beyond loops and zero-tails) */
{
	UWORD	i;
	ULONG	newlen;
	struct Instrument *inst;

	for (i = 1 ; i < MAXINSTRUMENTS ; i++)
	{
		inst = &(si->Inst[i]);
		if (!inst->SampleData) continue;
		newlen = inst->Length;

		if (inst->Replen)
		{
			if (inst->Length > inst->Repeat + inst->Replen)
				newlen = inst->Repeat + inst->Replen; /* Cut instrument after loop */
		}
		else
		{
			BYTE *tail;

			inst->Repeat = 0;	/* Kill null loops */

			/* Kill instrument zero-tail.
			 * In order to reduce the instrument even more,
			 * 1 & -1 are treated the same as zero.
			 */

			tail = inst->SampleData + inst->Length - 1;
			while ((*tail < 1) && (*tail > -1) && (tail > inst->SampleData))
				tail--;

			newlen = tail - inst->SampleData;
			if (newlen & 1) newlen++;	/* Pad instrument size to words */

			/* leave 2 end zeroes to prevent an audible end-of-instrument click. */
			if (newlen) newlen += 2;
		}

		if (newlen == 0)
			FreeInstr (inst);	/* This instrument is mute!  Free it... */

		else if (newlen < inst->Length)
		{
			/* Resize the instrument if necessary */
			BYTE *newinstr;

			/* Allocate memory for optimized instrument */
			if (!(newinstr = AllocVec (newlen, MEMF_SAMPLE)))
			{
					ShowMessage (MSG_NO_MEMORY_TO_OPTIMIZE_INSTR, i);
					continue;	/* Try next instrument */
			}

			ShowMessage (MSG_INSTR_WILL_SHRINK, i, inst->Length, newlen);

			/* Copy first part of instrument */
			memcpy (newinstr, inst->SampleData, newlen);

			/* Free old instrument */
			FreeVec (inst->SampleData);

			/* Replace with new instrument */
			inst->SampleData = newinstr;
			inst->Length = newlen;
		}
	}
}



void RemDupInstruments (struct SongInfo *si)
/* Find out identical patterns and cut them out */
{
	UWORD i, j, k, w, v;
	struct Instrument *insta, *instb;
	struct Pattern *patt;
	struct Note *note;


	for (i = 0; i < MAXINSTRUMENTS-1; i++)
	{
		insta = &si->Inst[i];
		if (!insta->Length) continue;

		for (j = i+1; j < MAXINSTRUMENTS; j++)
		{
			instb = &si->Inst[j];

			if (insta->Length == instb->Length &&
				insta->Repeat == instb->Repeat &&
				insta->Replen == instb->Replen &&
				insta->Volume == instb->Volume &&
				insta->InstType == instb->InstType &&
				insta->FineTune == instb->FineTune)
			{
				if (!memcmp (insta->SampleData, instb->SampleData, insta->Length))
				{
					FreeInstr (instb);

					for (k = 0; k < si->NumPatterns; k++)
					{
						patt = &si->PattData[k];
						for (w = 0; w < patt->Tracks; w++)
						{
							note = patt->Notes[w];
							for (v = 0; v < patt->Lines; v++, note++)
								if (note->Inst == j) note->Inst = i;
						}
					}

					ShowMessage (MSG_INSTR_DUPES_REMOVED, i, j);
				}
			}
		}
	}

}



void RemapInstruments (struct SongInfo *si)

/* Remove empty slots between instruments, to allow those module formats
 * that support less instruments to use even the last instruments.
 */
{
	UWORD i, j, k;
	UWORD newpos[MAXINSTRUMENTS];
	struct Instrument *instr = si->Inst;
	struct Pattern *patt;
	struct Note *note;

	newpos[0] = 0;

	/* Build instrument remap table &  compress instruments */
	for (i = 1, j = 0; i < MAXINSTRUMENTS; i++)
	{
		if (instr[i].Length)
		{
			j++;
			newpos[i] = j;

			if (j != i)
			{
				memcpy (&instr[j], &instr[i], sizeof (struct Instrument));
				memset (&instr[i], 0, sizeof (struct Instrument));
			}
		}
		else newpos[i] = 0;
	}


	/* Update score */
	for (i = 0 ; i < si->NumPatterns ; i++)
	{
		patt = &si->PattData[i];

		for (j = 0 ; j < patt->Tracks ; j++)
		{
			note = patt->Notes[j];

			for (k = 0; k < patt->Lines ; k++, note++)
				if (note->Note)
				{
					note->Inst = newpos[note->Inst];
					if (!note->Inst)
						note->Note = 0;
				}
		}
	}
}



void RemUnusedInstruments (struct SongInfo *si)
{
	ULONG usecount[MAXINSTRUMENTS] = { 0 };
	struct Pattern *patt;
	struct Note *note;
	UWORD i, j, k;

	for (i = 0; i < si->NumPatterns; i++)
	{
		patt = &si->PattData[i];

		for (j = 0; j < patt->Tracks; j++)
		{
			note = patt->Notes[j];

			for (k = 0; k < patt->Lines; k++, note++)
				usecount[note->Inst]++;
		}
	}

	for (i = 1; i < MAXINSTRUMENTS ; i++)
	{
		if (usecount[i] == 0 && si->Inst[i].Length)
		{
			ShowMessage (MSG_INSTR_UNUSED, i);
			FreeInstr (&si->Inst[i]);
		}
	}
}



/* DUnpack.c --- Fibonacci Delta decompression by Steve Hayes */

/* Fibonacci delta encoding for sound data */
static const BYTE codeToDelta[16] = {-34,-21,-13,-8,-5,-3,-2,-1,0,1,2,3,5,8,13,21};


static BYTE D1Unpack (UBYTE source[], LONG n, BYTE dest[], BYTE x)

/* Unpack Fibonacci-delta encoded data from n byte source
 * buffer into 2*n byte dest buffer, given initial data
 * value x.  It returns the last data value x so you can
 * call it several times to incrementally decompress the data.
 */
{
	UBYTE d;
	LONG i, lim;

	lim = n << 1;
	for (i = 0; i < lim; ++i)
	{
		/* Decode a data nibble, high nibble then low nibble */
		d = source[i >> 1];		/* get a pair of nibbles		*/
		if (i & 1)				/* select low or high nibble	*/
			d &= 0xf;			/* mask to get the low nibble	*/
		else
			d >>= 4;			/* shift to get the high nibble	*/
		x += codeToDelta[d];	/* add in the decoded delta		*/
		dest[i] = x;			/* store a 1 byte sample		*/
	}
	return x;
}


static void DUnpack (UBYTE source[], LONG n, BYTE dest[])

/* Unpack Fibonacci-delta encoded data from n byte
 * source buffer into 2*(n-2) byte dest buffer.
 * Source buffer has a pad byte, an 8-bit initial
 * value, followed by n-2 bytes comprising 2*(n-2)
 * 4-bit encoded samples.
 */
{
	D1Unpack (source+2, n-2, dest, (BYTE)source[1]);
}



void SampChangeSign8 (UBYTE *samp, ULONG len)

/* Performs a sign conversion on a 8bit sample.  The same function can be
 * used to convert a signed sample into an unsigned one and vice versa.
 */
{
	while (len)
		samp[--len] ^= 0x80;
}

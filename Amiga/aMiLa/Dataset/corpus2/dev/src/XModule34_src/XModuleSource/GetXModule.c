/*
**	GetXModule.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Load an IFF XMOD module
*/


#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/iffparse_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/iffparse_pragmas.h>

#include "XModule.h"
#include "XModuleClass.h"
#include "Gui.h"



LONG GetXModule (struct SongInfo *si, BPTR fh)
{
	struct IFFHandle *iff;
	struct ContextNode *cn;
	LONG err;

	if (iff = AllocIFF())
	{
		iff->iff_Stream = (ULONG) fh;

		InitIFFasDOS (iff);

		if (!(err = OpenIFF (iff, IFFF_READ)))
		{
			struct ModuleHeader mhdr;

			static LONG stopchunks[] =
			{
				ID_XMOD,	ID_NAME,
				ID_XMOD,	ID_MHDR,
				ID_SONG,	ID_FORM
			};

			if (err = StopChunks (iff, stopchunks, 3))
				goto error;

			if (err = StopOnExit (iff, ID_XMOD, ID_FORM))
				goto error;

			/* Scan module */

			while (1)
			{
				if (err = ParseIFF (iff, IFFPARSE_SCAN))
				{
					if (err == IFFERR_EOF || err == IFFERR_EOC) err = RETURN_OK;
					break; /* Free resources & exit */
				}

				if (cn = CurrentChunk (iff))
				{
					switch (cn->cn_ID)
					{
						case ID_NAME:
							ReadChunkBytes (iff, si->SongName, min(cn->cn_Size, MAXSONGNAME));
							si->SongName[min(cn->cn_Size, MAXSONGNAME-1)] = '\0'; /* Ensure string termination */
							break;

						case ID_MHDR:
							if ((err = ReadChunkBytes (iff, &mhdr, sizeof (mhdr))) != sizeof(mhdr))
								goto error;
							break;

						case ID_FORM:
							if (cn->cn_Type == ID_SONG)
								if (err = GetSong (iff, si))
									goto error;
							break;

						default:
							break;
					}
				}
			}
error:
			CloseIFF (iff);
		}

		FreeIFF (iff);
	}
	else err = ERROR_NO_FREE_STORE;

	return err;
}



LONG GetSong (struct IFFHandle *iff, struct SongInfo *si)
{
	LONG err, len;
	struct ContextNode *cn;
	struct Pattern *patt = si->PattData;
	struct Instrument *inst = si->Inst + 1;
	struct SongHeader shdr;
	UWORD instcount = 0;

	static LONG stopchunks[] =
	{
		ID_SONG,	ID_NAME,
		ID_SONG,	ID_SHDR,
		ID_SONG,	ID_SEQN,
		ID_PATT,	ID_FORM,
		ID_8SVX,	ID_FORM
	};

	if (err = StopChunks (iff, stopchunks, 5))
		return err;

	if (err = StopOnExit (iff, ID_SONG, ID_FORM))
		return err;

	/* Scan song */

	while (1)
	{
		if (err = ParseIFF (iff, IFFPARSE_SCAN))
		{
			if (err == IFFERR_EOF || err == IFFERR_EOC) err = RETURN_OK;
			break; /* Free resources & exit */
		}

		if (cn = CurrentChunk (iff))
		{
			switch (cn->cn_ID)
			{
				case ID_NAME:
					ReadChunkBytes (iff, si->SongName, min(cn->cn_Size, MAXSONGNAME));
					si->SongName[min(cn->cn_Size, MAXSONGNAME-1)] = '\0'; /* Ensure string termination */
					break;

				case ID_SHDR:
					if ((err = ReadChunkBytes (iff, &shdr, sizeof (shdr))) != sizeof(shdr))
						return err;

					si->MaxTracks	= shdr.MaxTracks;
					si->GlobalSpeed	= shdr.GlobalSpeed;
					si->GlobalTempo	= shdr.GlobalTempo;
					si->Restart		= shdr.Restart;
					si->CurrentPatt	= shdr.CurrentPatt;
					si->CurrentPos	= shdr.CurrentPos;
					si->CurrentInst	= shdr.CurrentInst;

					break;

				case ID_SEQN:
					len	= min (cn->cn_Size / 2, MAXPOSITIONS);

					if (SetSongLen (si, len))
					{
						if ((err = ReadChunkBytes (iff, si->Sequence, si->Length * 2))
							!= si->Length * 2)
							return err;
					}
					else return ERROR_NO_FREE_STORE;

					break;

				case ID_FORM:
					if (cn->cn_Type == ID_PATT)
					{
						if (!si->NumPatterns)
							DisplayAction (MSG_READING_PATTS);

						if (DisplayProgress (si->NumPatterns, shdr.NumPatterns))
							return ERROR_BREAK;

						if (err = GetPattern (iff, patt++))
							return err;

						si->NumPatterns++;
					}
					else if (cn->cn_Type == ID_8SVX)
					{
						if (!instcount)
							DisplayAction (MSG_READING_INSTS);

						instcount++;
						if (DisplayProgress (instcount, shdr.NumInstruments))
							return ERROR_BREAK;

						if (err = Load8SVXInstrument (inst, iff))
							return err;
						inst++;
					}

					break;

				default:
					break;
			}
		}
	}

	return err;
}



LONG GetPattern (struct IFFHandle *iff, struct Pattern *patt)
{
	LONG err, tracksize;
	struct ContextNode *cn;
	struct PatternHeader phdr;
	UWORD i;
	BOOL phdr_loaded = FALSE;

	static LONG stopchunks[] =
	{
		ID_PATT, ID_NAME,
		ID_PATT, ID_PHDR,
		ID_PATT, ID_BODY
	};

	if (err = StopChunks (iff, stopchunks, 3))
		return err;

	if (err = StopOnExit (iff, ID_PATT, ID_FORM))
		return err;

	/* Scan Pattern */

	while (1)
	{
		if (err = ParseIFF (iff, IFFPARSE_SCAN))
		{
			if (err == IFFERR_EOF || err == IFFERR_EOC) err = RETURN_OK;
			break; /* Free resources & exit */
		}

		if ((cn = CurrentChunk (iff)) && (cn->cn_Type == ID_PATT))
		{
			switch (cn->cn_ID)
			{
				case ID_NAME:
					ReadChunkBytes (iff, patt->PattName, min(cn->cn_Size, MAXPATTNAME));
					patt->PattName[min(cn->cn_Size, MAXPATTNAME-1)] = '\0'; /* Ensure string termination */
					break;

				case ID_PHDR:
					if ((err = ReadChunkBytes (iff, &phdr, sizeof (phdr))) != sizeof(phdr))
						return err;

					FreeTracks (patt->Notes, patt->Lines, patt->Tracks);

					patt->Lines = phdr.Lines;
					patt->Tracks = min (phdr.Tracks, MAXTRACKS);
					tracksize = phdr.Lines * sizeof (struct Note);

					if (AllocTracks (patt->Notes, patt->Lines, patt->Tracks))
					{
						patt->Lines = patt->Tracks = 0;
						return ERROR_NO_FREE_STORE;
					}

					phdr_loaded = TRUE;

					break;

				case ID_BODY:

					if (!phdr_loaded) return ERROR_OBJECT_WRONG_TYPE;

					for (i = 0; i < patt->Tracks; i++)
					{
						if ((err = ReadChunkBytes (iff, patt->Notes[i], tracksize)) != tracksize)
						{
							FreeTracks (patt->Notes, patt->Lines, patt->Tracks);
							patt->Lines = patt->Tracks = 0;
							return err;
						}
					}

					break;

				default:
					break;
			}
		}
	}

	if (!err && !phdr_loaded) err = ERROR_OBJECT_NOT_FOUND;

	return err;
}

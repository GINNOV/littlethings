/*
**	SaveXModule.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Save internal structures to an IFF XMOD module.
*/

#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/iffparse_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/iffparse_pragmas.h>

#include "XModuleClass.h"
#include "XModule.h"
#include "Gui.h"



LONG SaveXModule (struct SongInfo *si, BPTR fh)
{
	struct IFFHandle *iff;
	LONG err;

	if (iff = AllocIFF())
	{
		iff->iff_Stream = (ULONG) fh;

		InitIFFasDOS (iff);

		if (!(err = OpenIFF (iff, IFFF_WRITE)))
		{

			/* Write XMOD */
			if (err = PushChunk (iff, ID_XMOD, ID_FORM, IFFSIZE_UNKNOWN))
				goto error;

			/* Write module NAME */
			if (err = WriteNameChunk (iff, FilePart (si->SongPath)))
				goto error;

			/* Write Module Header (MHDR) */
			{
				struct ModuleHeader mhdr;

				mhdr.XModuleVersion = VERSION;
				mhdr.XModuleRevision = REVISION;
				mhdr.NumSongs	= 1;
				mhdr.ActiveSong	= 1;
				mhdr.MasterVolume = 0xFFFF;
				mhdr.MixingRate = 44100;

				if (err = PushChunk (iff, ID_XMOD, ID_MHDR, sizeof (mhdr)))
					goto error;
				if ((err = WriteChunkBytes (iff, &mhdr, sizeof (mhdr))) != sizeof(mhdr))
					goto error;
				if (err = PopChunk (iff)) goto error;	/* Pop MHDR */
			}

			if (err = SaveSong (iff, si))
				goto error;

			err = PopChunk (iff);		/* Pop FORM XMOD */

error:
			CloseIFF (iff);
		}
		else err = IFFERR_NOTIFF;

		FreeIFF (iff);
	}
	else err = ERROR_NO_FREE_STORE;

	return (UWORD) err;
}



LONG SaveSong (struct IFFHandle *iff, struct SongInfo *si)
{
	LONG err;
	UWORD lastinstr;

	if (err = PushChunk (iff, ID_SONG, ID_FORM, IFFSIZE_UNKNOWN))
		return err;

	/* Write Song Name */
	WriteNameChunk (iff, si->SongName);

	/* Write Song Header (SHDR) */
	{
		struct SongHeader shdr;

		if (err = PushChunk  (iff, ID_SONG, ID_SHDR, IFFSIZE_UNKNOWN))
			return err;

		/* Find last used instrument */
		for (lastinstr = 63; lastinstr > 0 ; lastinstr--)
			if (si->Inst[lastinstr].Length || si->Inst[lastinstr].Name[0])
				break;

		shdr.Length			= si->Length;
		shdr.MaxTracks		= si->MaxTracks;
		shdr.NumPatterns	= si->NumPatterns;
		shdr.NumInstruments	= lastinstr;
		shdr.GlobalSpeed	= si->GlobalSpeed;
		shdr.GlobalTempo	= si->GlobalTempo;
		shdr.Restart		= si->Restart;
		shdr.CurrentPatt	= si->CurrentPatt;
		shdr.CurrentLine	= 0;
		shdr.CurrentTrack	= 0;
		shdr.CurrentPos		= si->CurrentPos;
		shdr.CurrentInst	= si->CurrentInst;

		if ((err = WriteChunkBytes (iff, &shdr, sizeof (shdr))) != sizeof (shdr))
			return err;

		if (err = PopChunk (iff))	/* Pop SHDR */
			return err;
	}


	if (err = SaveSequence (iff, si))
		return err;
	if (err = SavePatterns (iff, si))
		return err;
	if (err = SaveInstruments (iff, si, lastinstr))
		return err;

	err = PopChunk (iff);	/* Pop FORM SONG */

	return err;
}



LONG SaveSequence (struct IFFHandle *iff, struct SongInfo *si)
{
	LONG	err;

	if (err = PushChunk (iff, 0, ID_SEQN, si->Length * 2))
		return err;

	if ((err = WriteChunkBytes (iff, si->Sequence, si->Length * 2)) != si->Length * 2)
		return err;

	err = PopChunk (iff);

	return err;
}



LONG SavePatterns (struct IFFHandle *iff, struct SongInfo *si)
{
	LONG	err;
	ULONG	i;

	DisplayAction (MSG_WRITING_PATTS);

	for (i = 0; i < si->NumPatterns; i++)
	{
		if (DisplayProgress (i, si->NumPatterns))
			return ERROR_BREAK;

		if (err = SavePattern (iff, &si->PattData[i]))
			return err;
	}

	return RETURN_OK;
}



LONG SaveInstruments (struct IFFHandle *iff, struct SongInfo *si, UWORD lastinstr)
{
	LONG	err;
	ULONG	i;

	DisplayAction (MSG_WRITING_INSTS);

	for (i = 1; i <= lastinstr; i++)
	{
		if (DisplayProgress (i, lastinstr))
			return ERROR_BREAK;

		if (err = Save8SVXInstrument (&si->Inst[i], iff))
			return err;
	}

	return RETURN_OK;
}



LONG SavePattern (struct IFFHandle *iff, struct Pattern *patt)
{
	LONG err;

	if (err = PushChunk (iff, ID_PATT, ID_FORM, IFFSIZE_UNKNOWN))
		return err;

	/* Write pattern NAME */

	if (err = WriteNameChunk (iff, patt->PattName))
		return err;

	/* Write pattern header (PHDR) */
	{
		struct PatternHeader phdr;

		phdr.Lines = patt->Lines;
		phdr.Tracks = patt->Tracks;

		if (err = PushChunk (iff, 0, ID_PHDR, sizeof (struct PatternHeader)))
			return err;

		if ((err = WriteChunkBytes (iff, &phdr, sizeof (phdr))) != sizeof (phdr))
			return err;

		if (err = PopChunk (iff))	/* PHDR */
			return err;
	}

	/* Write pattern BODY */
	{
		ULONG tracksize = sizeof (struct Note) * patt->Lines;
		ULONG i;

		if (err = PushChunk (iff, 0, ID_BODY, tracksize * patt->Tracks))
			return err;

		for (i = 0; i < patt->Tracks; i++)
		{
			if ((err = WriteChunkBytes (iff, patt->Notes[i], tracksize)) != tracksize)
				return err;
		}

		if (err = PopChunk (iff))	/* BODY */
			return err;
	}

	err = PopChunk (iff);	/* PATT */

	return err;
}



LONG WriteNameChunk (struct IFFHandle *iff, STRPTR name)
{
	LONG err;
	ULONG len;

	if (!name[0] || !SaveSwitches.SaveNames)
		return RETURN_OK;

	if (err = PushChunk (iff, 0, ID_NAME, len = strlen (name)))
		return err;

	if ((err = WriteChunkBytes (iff, name, len)) != len)
		return err;

	err = PopChunk (iff);

	return err;
}

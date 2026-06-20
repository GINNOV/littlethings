#ifndef XMODULE_CLASS_H
#define XMODULE_CLASS_H
/*
**	XModuleClass.h
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Use 4 chars wide TABs to read this file
**
**	IFF XMOD file format definition.
*/


#ifndef IFFPARSE_H
#include <libraries/iffparse.h>
#endif

#ifndef	DATATYPES_SOUNDCLASS_H
#include <datatypes/soundclass.h>
#endif


#define ID_XMOD MAKE_ID('X','M','O','D')
#define ID_MHDR MAKE_ID('M','H','D','R')

#define ID_SONG MAKE_ID('S','O','N','G')
#define ID_SHDR MAKE_ID('S','H','D','R')
#define ID_SEQN MAKE_ID('S','E','Q','N')

#define ID_PATT MAKE_ID('P','A','T','T')
#define ID_PHDR MAKE_ID('P','H','D','R')


struct ModuleHeader
{
	UWORD XModuleVersion;	/* XModule version used to save this file	*/
	UWORD XModuleRevision;	/* XModule revision used to save this file	*/
	UWORD NumSongs;			/* Number of songs in this module			*/
	UWORD ActiveSong;
	UWORD MasterVolume;
	UWORD MixingMode;
	ULONG MixingRate;
};



struct SongHeader
{
	UWORD	MaxTracks;		/* Number of tracks in song			*/
	UWORD	Length;			/* Number of positions in song		*/
	UWORD	NumPatterns;	/* Number of patterns in song		*/
	UWORD	NumInstruments;	/* Number of instruments in song,	*/
							/*	excluding instrument 0.			*/
	UWORD	GlobalSpeed;	/* Global song speed				*/
	UWORD	GlobalTempo;	/* Global song tempo				*/
	UWORD	Restart;		/* Position to restart from			*/
	UWORD	CurrentPatt;
	UWORD	CurrentLine;
	UWORD	CurrentTrack;
	UWORD	CurrentPos;
	UWORD	CurrentInst;
};



struct PatternHeader
{
	UWORD	Tracks;			/* Number of tracks in pattern		*/
	UWORD	Lines;			/* Number of lines in pattern		*/
};


#ifndef STRUCT_NOTE
#define STRUCT_NOTE
struct Note
{
	UBYTE Note;				/* See below for more info.	*/
	UBYTE Inst;				/* Instrument number		*/
	UBYTE EffNum;			/* See definitions below.	*/
	UBYTE EffVal;			/* Effect value ($00-$FF)	*/
};
#endif /* STRUCT_NOTE */


/* Note values:
 *
 *  0  - no note
 *  1  - C-0
 *  2  - C#0
 * ...
 * 13  - C-1
 * ...
 * 72  - B-5
 */



/* Values for Note->EffNum */

enum {
	EFF_NULL,				/* $00 */
	EFF_PORTAMENTOUP,		/* $01 */
	EFF_PORTAMENTODOWN,		/* $02 */
	EFF_TONEPORTAMENTO,		/* $03 */
	EFF_VIBRATO,			/* $04 */
	EFF_TONEPVOLSLIDE,		/* $05 */
	EFF_VIBRATOVOLSLIDE,	/* $06 */
	EFF_TREMOLO,			/* $07 */
	EFF_UNUSED,				/* $08 */
	EFF_SAMPLEOFFSET,		/* $09 */
	EFF_VOLSLIDE,			/* $0A */
	EFF_POSJUMP,			/* $0B */
	EFF_SETVOLUME,			/* $0C */
	EFF_PATTERNBREAK,		/* $0D */
	EFF_MISC,				/* $0E */
	EFF_SETSPEED,			/* $0F */
	EFF_SETTEMPO,			/* $10 */
	EFF_ARPEGGIO,			/* $11 */

	EFF_COUNT				/* $12 */
};



struct InstrumentInfo
{
	WORD	 InstNum;		/* Instrument slot number			*/
	UWORD	 InstType;		/* Instrument type (see defs)		*/
	WORD	 FineTune;		/* Instrument FineTune (-8..+7)		*/
};

/* Possible values for Instrument->InstType */
enum {
	ITYPE_SAMPLE8,		/* signed 8bit sample					*/
	ITYPE_SAMPLE16,		/* TODO: signed 16bit sample			*/
	ITYPE_SYNTH,		/* TODO: Synthetic instrument			*/
	ITYPE_HYBRID,		/* TODO: Both Synth & Sample			*/
	ITYPE_MIDI			/* TODO: Played by external MIDI device	*/
};


#endif /* XMODULE_CLASS_H */

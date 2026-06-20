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



/* Convert an Intel style WORD to Motorola format */
#define I2M(x) ( (UWORD) ( (((UWORD)(x)) >> 8) | (((UWORD)(x)) << 8) ) )

/* Convert an Intel style LONG to Motorola format */
#define I2ML(x) ( I2M((x)>>16) | (I2M((x))<<16) )



struct FT2Header
{
	UBYTE	ID[17];			/* ID text: "Extended module: "				*/
	UBYTE	Name[20];		/* Module name, padded with zeroes			*/
	UBYTE	Dummy;			/* Constant: $1a							*/
	UBYTE	Tracker[20];	/* Tracker name								*/
	UBYTE	Revision;		/* minor version number	($03)				*/
	UBYTE	Version;		/* major version number ($01)				*/
	ULONG	HeaderSize;
	UWORD	Length;			/* Song length (in patten order table)		*/
	UWORD	Restart;		/* Restart position							*/
	UWORD	Channels;		/* Number of channels (2,4,6,8,10,...,32)	*/
	UWORD	NumPatt;		/* Number of patterns (max 256)				*/
	UWORD	NumInstr;		/* Number of instruments (max 128)			*/
	UWORD	Flags;			/* See below...								*/
	UWORD	DefTempo;		/* Default tempo							*/
	UWORD	DefBPM;			/* Default BeatsPerMinute					*/
	UBYTE	Orders;			/* Pattern order table						*/
};


struct FT2Pattern
{
	ULONG	Size;			/* Header size, sizeof (FT2Pattern)			*/
	UBYTE	Packing;		/* Packing type (always 0)					*/

	/* Two words at odd offsetts! Argh!!! */
	UBYTE	RowsL;			/* Number of rows in pattern (1..256)		*/
	UBYTE	RowsH;
	UBYTE	PackSizeL;		/* Packed patterndata size					*/
	UBYTE	PackSizeH;

	/* Packed pattern data follows, but this structure's size is
	 * variable!  Check FT2Pattern->Length to find out...
	 */
};


struct FT2Instrument
{
	ULONG	Size;			/* Instrument size							*/
	UBYTE	Name[22];		/* Instrument name							*/
	UBYTE	Type;			/* Instrument type (always 0)				*/

	/* Yet another time: words at odd offsetts! */
	UBYTE	SamplesL;		/* If the number of samples > 0,			*/
	UBYTE	SamplesH;		/*  then an FT2Sample structure will follow	*/
};


struct FT2InstExt
{
	ULONG	Size;			/* Sample size								*/
	UBYTE	Number[96];		/* Sample number for all notes				*/
	UBYTE	VolEnv[48];		/* Points for volume envelope				*/
	UBYTE	PanEnv[48];		/* Points for panning envelope				*/
	UBYTE	VolCount;		/* Number of volume points					*/
	UBYTE	PanCount;		/* Number of panning points					*/
	UBYTE	VolSustain;		/* Volume sustain point						*/
	UBYTE	VolLoopStart;	/* Volume loop start point					*/
	UBYTE	VolLoopEnd;		/* Volume loop end point					*/
	UBYTE	PanSustain;		/* Panning sustain point					*/
	UBYTE	PanLoopStart;	/* Panning loop start point					*/
	UBYTE	PanLoopEnd;		/* Panning loop end point					*/
	UBYTE	VolType;		/* Volume type: bit 0:On; 1:Sustain; 2:Loop	*/
	UBYTE	PanType;		/* Panning type: bit 0:On; 1:Sustain; 2:Loop*/
	UBYTE	VibType;		/* Vibrato type								*/
	UBYTE	VibSweep;		/* Vibrato sweep							*/
	UBYTE	VibDepth;		/* Vibrato depth							*/
	UBYTE	VibRate;		/* Vibrato rate								*/
	UBYTE	VolFadeoutL;
	UBYTE	VolFadeoutH;
	UBYTE	ReservedL;
	UBYTE	ReservedH;
};


struct FT2Sample
{
	ULONG	Length;			/* Sample length			*/
	ULONG	Repeat;			/* Sample loop start		*/
	ULONG	Replen;			/* Sample loop length		*/
	UBYTE	Volume;
	BYTE	Finetune;		/* (signed byte -16..+15)	*/
	UBYTE	Type;			/* See below...				*/
	UBYTE	Panning;		/* Panning (0-255)			*/
	BYTE	RelNote;		/* Relative note number		*/
	UBYTE	Reserved;
	UBYTE	Name[22];
};


/* Flags for FT2Sample->Type */

#define STYP_LOOPMASK	3	/* bits 0-1				*/
#define STYPF_FWDLOOP	1	/* Forward loop			*/
#define STYPF_PINGLOOP	2	/* Ping-Pong loop		*/
#define STYPF_16BIT		16	/* 16-bit sampledata	*/


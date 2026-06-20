/*
**	Data.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Define & initialize global conversion tables and other public structures.
*/

#include "XModule.h"

/* For startup module: minimum stack required to run XModule */
ULONG __stack = 8192;

/* Library bases */
struct IntuitionBase	*IntuitionBase	= NULL;
struct GfxBase			*GfxBase		= NULL;
struct Library			*LayersBase		= NULL;
struct Library			*UtilityBase	= NULL;
struct Library			*GadToolsBase	= NULL;
struct Library			*DiskfontBase	= NULL;
struct Library			*AslBase		= NULL;
struct Library			*IFFParseBase	= NULL;
struct Library			*WorkbenchBase	= NULL;
struct Library			*IconBase		= NULL;
struct Library			*ReqToolsBase	= NULL;
struct Library			*CxBase			= NULL;
struct Library			*KeymapBase		= NULL;



/* Global environment variables */
struct SongInfo *songinfo = NULL;	/* Global song data */
void			*Pool = NULL;
BOOL			 Kick30 = FALSE;



/* Note conversion table for Sound/Noise/ProTracker */
const UWORD TrackerNotes[] =
{
	0x000,										/* Null note */

	0x6B0, 0x650, 0x5F5, 0x5A0, 0x54D, 0x501,	/* Octave 0 */
	0x4B9, 0x475, 0x435, 0x3F9, 0x3C1, 0x38B,

	0x358, 0x328, 0x2FA, 0x2D0, 0x2A6, 0x280,	/* Octave 1 */
	0x25C, 0x23A, 0x21A, 0x1FC, 0x1E0, 0x1C5,

	0x1AC, 0x194, 0x17D, 0x168, 0x153, 0x140,	/* Octave 2 */
	0x12E, 0x11d, 0x10D, 0x0FE, 0x0F0, 0x0E2,

	0x0D6, 0x0CA, 0x0BE, 0x0B4, 0x0AA, 0x0A0,	/* Octave 3 */
	0x097, 0x08F, 0x087, 0x07F, 0x078, 0x071,

	0x06B, 0x065, 0x05F, 0x05A, 0x055, 0x050,	/* Octave 4 */
	0x04C, 0x047, 0x043, 0x040, 0x03C, 0x039,

	0x035, 0x032, 0x030, 0x02D, 0x02A, 0x028,	/* Octave 5 */
	0x026, 0x024, 0x022, 0x020, 0x01E, 0x01C
};



/* Effects conversion table
 * Originally based on Gerardo Iula's "Tracker" source.
 */
const UBYTE Effects[MAXTABLEEFFECTS][4] =
{
/*    STRK  OKTA   MED   S3M		XModule			Val */

	{ 0x00, 0x00, 0x00, 0x00 },	//	Null effect		$00

	{ 0x01, 0x01, 0x01, 0x05 },	//	Portamento Up	$01
	{ 0x02, 0x02, 0x02, 0x04 },	//	Portamento Down	$02
	{ 0x03, 0x00, 0x03, 0x06 },	//	Tone Portamento	$03
	{ 0x04, 0x00, 0x14, 0x07 },	//	Vibrato			$04
	{ 0x05, 0x00, 0x05, 0x0B },	//	ToneP + VolSl	$05
	{ 0x06, 0x00, 0x16, 0x0A },	//	Vibra + VolSl	$06
	{ 0x07, 0x00, 0x07, 0x08 },	//	Tremolo			$07
	{ 0x08, 0x00, 0x08, 0x00 },	//	Set Hold/Decay	$08
	{ 0x09, 0x00, 0x19, 0x0E },	//	Sample Offset	$09
	{ 0x0A, 0x1E, 0x0A, 0x03 },	//	Volume Slide	$0A
	{ 0x0B, 0x19, 0x0B, 0x01 },	//	Position Jump  	$0B
	{ 0x0C, 0x1F, 0x0C, 0x12 },	//	Set Volume		$0C
	{ 0x0D, 0x00, 0x0F, 0x02 },	//	Pattern break	$0D
	{ 0x0E, 0x00, 0x00, 0x10 },	//	Misc			$0E
	{ 0x0F, 0x1C, 0x09, 0x00 },	//	Set Speed		$0F
	{ 0x0F, 0x00, 0x0F, 0x11 },	//	Set Tempo		$10
	{ 0x00, 0x1A, 0x00, 0x09 },	//	Arpeggio		$11

	{ 0x03, 0x11, 0x00, 0x03 },	//	Oktalyzer H
	{ 0x03, 0x15, 0x00, 0x03 }	//	Oktalyzer L
};


/*
UBYTE const TextNotes[MAXTABLENOTE][4] =
{
	"---",
	"C-0", "C#0", "D-0", "D#0", "E-0", "F-0",
	"F#0", "G-0", "G#0", "A-0", "A#0", "B-0",

	"C-1", "C#1", "D-1", "D#1", "E-1", "F-1",
	"F#1", "G-1", "G#1", "A-1", "A#1", "B-1",

	"C-2", "C#2", "D-2", "D#2", "E-2", "F-2",
	"F#2", "G-2", "G#2", "A-2", "A#2", "B-2",

	"C-3", "C#3", "D-3", "D#3", "E-3", "F-3",
	"F#3", "G-3", "G#3", "A-3", "A#3", "B-3",

	"C-4", "C#4", "D-4", "D#4", "E-4", "F-4",
	"F#4", "G-4", "G#4", "A-4", "A#4", "B-4",

	"C-5", "C#5", "D-5", "D#5", "E-5", "F-5",
	"F#5", "G-5", "G#5", "A-5", "A#5", "B-5"
};
*/



/* Martin Taillefer's block pointer */
/*
chip UWORD BlockPointer[] =
{
	0x0000, 0x0000,

	0x0000, 0x0100,
	0x0100, 0x0280,
	0x0380, 0x0440,
	0x0100, 0x0280,
	0x0100, 0x0ee0,
	0x0000, 0x2828,
	0x2008, 0x5834,
	0x783c, 0x8002,
	0x2008, 0x5834,
	0x0000, 0x2828,
	0x0100, 0x0ee0,
	0x0100, 0x0280,
	0x0380, 0x0440,
	0x0100, 0x0280,
	0x0000, 0x0100,
	0x0000, 0x0000,

	0x0000, 0x0000
};
*/


/* Version tag */
const UBYTE Version[] = "$VER: " VERS " (" DATE ") " XMODULECOPY;
UBYTE BaseName[] = BASENAME;
UBYTE PrgName[] = PRGNAME;

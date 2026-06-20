/*
**	Locale.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Routines to handle localization.
**
**	This file was created automatically by `FlexCat V1.5'
**	Do NOT edit by hand!
*/

#include <libraries/locale.h>

#include <clib/exec_protos.h>
#include <clib/locale_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/locale_pragmas.h>

#include "XModule.h"


#define CATALOGVERSION	0
#define CATALOGNAME		"XModule.catalog"
#define MSG_COUNT		124


STRPTR AppStrings[] =
{
	"Ok",
	"Yes|No",
	"Retry|Cancel",
	"Continue",
	"Insufficient memory.",
	"Aborted.",
	"Unable to load \"%s\": %s.",
	"Cannot open file \"%s\" %s.",
	"Error reading \"%s\": %s.",
	"Error writing \"%s\" %s.",
	"Decrunching...",
	"Nothing found in archive \"%s\".",
	"Unable to load compressed file.",
	"Error decompressing file \"%s\": %s.",
	"Bad Commodity HotKey description.",
	"Reading Patterns...",
	"Reading Instruments Info...",
	"Reading Instruments...",
	"ERROR: Couldn't load pattern %ld.",
	"ERROR: Couldn't load instrument %lx.",
	"ERROR: Not enough memory for instrument %lx.",
	"ERROR: Instrument %lx is not a sample.",
	"WARNING: Song length exceeds maximum. Will be truncated.",
	"WARNING: Song exceeds maximum number of patterns.",
	"WARNING: Pattern %ld has too many tracks. Cropping to %ld tracks.",
	"WARNING: Pattern %ld has too many lines. Cropping to %ld lines.",
	"WARNING: Invalid note %ld (Patt %ld Track %ld Line %ld).",
	"Unknown effect: $%lx (Patt %ld Track %ld Line %ld).",
	"WARNING: Extra data found after valid module: Will be ignored.",
	"Writing Header...",
	"Writing Patterns...",
	"Writing Instruments...",
	"Writing Instruments Info...",
	"Writing Instruments Data...",
	"WARNING: Note at Patt %ld Track %ld Line %ld is too low.",
	"WARNING: Note at Patt %ld Track %ld Line %ld is too high.",
	"WARNING: Not enough memory to halve volume of instrument %lx.",
	"WARNING: Instrument %lx is too long.",
	"Loading MMD%lc module...",
	"Saving MMD%lc module...",
	"ERROR: Unsupported OctaMED format.",
	"WARNING: Effect %lx is not supported in MMD0 format. Use MMD1 or better.",
	"Loading Oktalyzer module with %ld tracks...",
	"Saving Oktalyzer 1.1 module (%ld tracks)...",
	"Reading ScreamTracker 3.0 module with %ld channels...",
	"ERROR: Instrument %lx is an ADLib %s.",
	"WARNING: Track %lx is out of range.",
	"WARNING: Unknown sample compression for instrument %lx.",
	"WARNING: Instrument %lx is a stereo sample.",
	"WARNING: Instrument %lx is 16bit: unable to load it.",
	"Reading %s module...",
	"WARNING: Module exceeds 64 patterns.  You need ProTracker 2.3 in order to play it.",
	"Reading %s module with %ld tracks...",
	"This file is a song and doesn't contain instruments.",
	"Saving Sound/Noise/ProTracker module...",
	"Saving Fast/TakeTracker module with %ld tracks...",
	"WARNING: Module execeeds %ld patterns.",
	"Pattern %ld will grow to 64 lines (was %ld lines long).",
	"Splitting pattern %ld (was %ld lines long).",
	"WARNING: some patterns are not being saved!",
	"Choosing Channels...",
	"Writing MIDI Tracks...",
	"ERROR: Song requires too many MIDI channels.",
	"Really Quit XModule?",
	"Please close all visitor windows\n"\
	"and then select `Continue'.",
	"Unknown IFF format %s.",
	"Illegal IFF structure.",
	"Unrecognized instrument format.\n"\
	"Please select RAW mode.",
	"Signed 8bit|Unsigned 8bit|Cancel",
	"DataTypes error: %s.",
	"Unknown compression type.",
	"%lu bit samples are not supported.",
	"Samples other than MONO are not supported.",
	"Samples with %ld channels are not supported.",
	"WARNING: insufficient memory to optimize instrument %lx.",
	"Instrument %lx will shrink from %ld to %ld.",
	"Duplicate instruments found and removed: %lx == %lx.",
	"Instrument %lx is never used and is being removed.",
	"Couldn't open %s version %ld or greater.",
	"Unable to insert pattern: Maximum number of patterns reached.",
	"Pattern %ld is not used and is beeing deleted.",
	"Pattern %ld will be cut at line %ld.",
	"Duplicate patterns found and removed: %ld == %ld.",
	"WARNING: Song lengths are different. Using shorter one.",
	"WARNING: Different pattern lengths at position %ld. Using shorter one.",
	"ERROR: Can't merge modules with instruments beyond %lx.",
	"Merge aborted: Try remapping the instruments.",
	"Incorrect version of preferences file",
	"XModule Request",
	"Clone Workbench Screen",
	"Please close FileRequester\n and then select `Continue'.",
	"Select Module(s)...",
	"Select Instrument(s)...",
	"Select Pattern...",
	"Save Module...",
	"Save Instrument...",
	"Save Pattern...",
	"File \"%s\"\nalready exists.",
	"Overwrite|Choose Another|Abort",
	"Unespected end of file.",
	"Module loaded OK.",
	"Module saved OK.",
	"ERROR: Unrecognized save format.",
	"Removed invalid loop for instrument %lx.",
	"Fixed invalid loop for instrument %lx.",
	"WARNING: Song has no patterns.",
	"WARNING: Song has no sequence.",
	"WARNING: Song position %ld references pattern %ld, which doesn't exist.",
	"Unable to identify module format.\n"\
	"(Loading a data file as a module is unwise)",
	"SoundTracker 15|ProTracker|Cancel",
	"Unknown",
	"Untitled",
	"AmigaGuide error:",
	"ERROR: Pattern would exceed the maximum number of lines.",
	"Player initialization error: %ld.",
	"Couldn't open player",
	"%ld of %ld (%ld%% done)",
	"ERROR: Join requires two songs.",
	"ERROR: Merge requires two songs.",
	"Discard current song?",
	"%s %s\n"\
	"A Music Module Processing Utility\n\n"\
	"%s\n"\
	"All rights reserved.\n\n"\
	"Internet: bernie@shock.nervous.com\n\n"\
	"FidoNet:  2:332/118.4\n"\
	"Free CHIP Memory: %ldKB\n"\
	"Free FAST Memory: %ldKB\n\n"\
	"Public Screen: %s\n"\
	"ARexx Port: %s\n"\
	"Cx HotKey: %s\n"\
	"Language: %s",
	"--Default--",
	"--Disabled--",
	"Saved %ld bytes (%ld%%)"
};

struct Library			*LocaleBase = NULL;
struct Catalog			*Catalog = NULL;



void SetupLocale (void)
{
	/* Try to open locale.library */
	if (LocaleBase = OpenLibrary ("locale.library", 38L))
	{
		/* Try to get catalog for current language */
  		if (Catalog = OpenCatalog (NULL, CATALOGNAME,
			OC_BuiltInLanguage,	"english",
			OC_Version,			CATALOGVERSION,
			TAG_DONE))
		{
			/* Read in locale language strings */
			UBYTE **as = AppStrings;
			ULONG i;

			/* Get translation strings */
			for (i = 0; i < MSG_COUNT; i++, as++)
			*as = GetCatalogStr (Catalog, i, *as);
		}
	}
}



void CleanupLocale (void)
{
	if (LocaleBase)
	{
		CloseCatalog (Catalog);	/* No need to check for NULL */
		CloseLibrary (LocaleBase);
	}
}

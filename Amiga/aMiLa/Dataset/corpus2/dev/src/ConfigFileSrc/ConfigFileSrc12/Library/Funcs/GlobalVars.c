/*
**		$PROJECT: ConfigFile.library
**		$FILE: GlobalVars.c
**		$DESCRIPTION: Definition file of the global vars
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

UBYTE	Bin2SType[8] = { 0,0,0,0,0,0x03,0x02,0x01 };
UBYTE	SType2Bin[4] = { 0,0x38,0x30,0x28 };

UWORD	OModes[3] = { MODE_OLDFILE, MODE_NEWFILE, MODE_READWRITE };

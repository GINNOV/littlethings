/*
**		$PROJECT: ConfigFile.library
**		$FILE: CType.h
**		$DESCRIPTION: Character Class Table def file
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef CTYPE_H
#define CTYPE_H 1

/* CType -- Character Class Table */

#define CTB_LOWER				0
#define CTB_NAME_CHARS		1
#define CTB_STRING_CHARS	2
#define CTB_BOOL				4
#define CTB_HEX				7

#define CT_LOWER				0x01
#define CT_NAME_CHARS		0x02
#define CT_STRING_CHARS		0x04
#define CT_SPACE_CHARS		0x08
#define CT_BOOL				0x40
#define CT_HEX					0x80

IMPORT UBYTE CType [256];

#endif /* CTYPE_H */

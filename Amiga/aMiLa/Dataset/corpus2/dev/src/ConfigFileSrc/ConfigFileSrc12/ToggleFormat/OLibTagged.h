/*
**		$FILE: OLibTagged.h
**		$DESCRIPTION: Header file of TaggedOpenLibrary().
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef OLIBTAGGED_H
#define OLIBTAGGED_H 1

enum {
	TLIB_GRAPHICS = 1,
	TLIB_LAYERS,
	TLIB_INTUITION,
	TLIB_DOS,
	TLIB_ICON,
	TLIB_EXPANSION,
	TLIB_UTILITY,
	TLIB_KEYMAP,
	TLIB_GADTOOLS,
	TLIB_WORKBENCH,
};

APTR TaggedOpenLibrary ( LONG );
#pragma libcall SysBase TaggedOpenLibrary  32a 001

#endif /* OLIBTAGGED_H */

*
*  $PROJECT: ConfigFile.library
*  $FILE: RomTag.h
*  $DESCRIPTION: Resident tag file for the library.
*
*  (C) Copyright 1996-1997 Marcel Karas
*      All Rights Reserved.
*

	INCLUDE	"exec/types.i"
	INCLUDE	"exec/nodes.i"
	INCLUDE	"exec/resident.i"

	INCLUDE	"ConfigFile.library_rev.i"

	XREF	_LibInitTab

	SECTION	text,CODE

*---------------------------------------------------------------------------

	MOVEQ	#-1,D0
	RTS

*---------------------------------------------------------------------------

InitDesc:

	DC.W	RTC_MATCHWORD
	DC.L	InitDesc
	DC.L	EndCode
	DC.B	RTF_AUTOINIT
	DC.B	VERSION
	DC.B	NT_LIBRARY
	DC.B	100
	DC.L	_LibName
	DC.L	_LibID
	DC.L	_LibInitTab

EndCode:

*---------------------------------------------------------------------------

	XDEF	_LibID

	DC.B	0

	DC.B	'$VER: '
_LibID:
	VERS
	DC.B	' ('
	DATE
	DC.B	') '
	DC.B	'©1996-1997 Marcel Karas, '

;	DC.B	'68000 version.',0
	DC.B	'68020+ version.',0

	XDEF	_LibName

_LibName:
	DC.B	'configfile.library',0

*---------------------------------------------------------------------------

*	XREF	__BSSBAS
*	XREF	__BSSLEN

*	DC.L	__BSSBAS
*	DC.L	__BSSLEN

*---------------------------------------------------------------------------

	END

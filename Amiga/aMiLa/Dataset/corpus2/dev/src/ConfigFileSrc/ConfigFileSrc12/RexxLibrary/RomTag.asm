*
*  $PROJECT: RexxConfigFile.library
*  $FILE: RomTag.h
*  $DESCRIPTION: Resident tag file for the library.
*
*  (C) Copyright 1997 Marcel Karas
*      All Rights Reserved.
*

	INCLUDE	"exec/types.i"
	INCLUDE	"exec/nodes.i"
	INCLUDE	"exec/resident.i"

	INCLUDE	"RexxConfigFile.library_rev.i"

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
	DC.B	'©1997 Marcel Karas, '

	DC.B	'68000 version.',0

	XDEF	_LibName

_LibName:
	DC.B	'rexxconfigfile.library',0

*---------------------------------------------------------------------------

*	XREF	__BSSBAS
*	XREF	__BSSLEN

*	DC.L	__BSSBAS
*	DC.L	__BSSLEN

*---------------------------------------------------------------------------

	SECTION	data,data

*---------------------------------------------------------------------------

	XDEF	_LibVersion
	XDEF	_LibRevision

_LibVersion:
	DC.W	VERSION

_LibRevision:
	DC.W	REVISION

*---------------------------------------------------------------------------

	END

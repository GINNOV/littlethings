	IFND	VIDI_VIDI_LIB_I
VIDI_VIDI_LIB_I	SET	1

*****************************************************************************
*
*  ROMBO Productions -- Vidi-Amiga Library Include File
*
*****************************************************************************
*
*  Details:
*
*	Vidi-Amiga:Vidi/Include/vidi_lib.i
*	version 1.15, as of Thursday 18th January 1990
*	by Keith Wilson, Rombo
*
*****************************************************************************

_LVOAddPlane		EQU	-30
_LVOAllocBitMap		EQU	-36
_LVOClearBitMap		EQU	-42
_LVOClearPlane		EQU	-48
_LVOCopyBitMap		EQU	-54
_LVOFreeBitMap		EQU	-60
_LVOGrabFrame		EQU	-66
_LVOEasyScreen		EQU	-72
_LVOMergeRGB		EQU	-78
_LVOPixelPop4		EQU	-84
_LVOReadBitMap		EQU	-90
_LVOPrintDump		EQU	-96
_LVORemPlane		EQU	-102
_LVOShowBitMap		EQU	-108
_LVOSyncTest		EQU	-114
_LVODisownVidi		EQU	-120
_LVOOwnVidi		EQU	-126
_LVOReadWindow		EQU	-132

_LVOOpenIFF		EQU	-138
_LVOCloseIFF		EQU	-144
_LVOWriteChunk		EQU	-150
_LVOCloseChunk		EQU	-156
_LVOChunkData		EQU	-162
_LVOILBMChunk		EQU	-168
_LVOBMHDChunk		EQU	-174
_LVOCMAPChunk		EQU	-180
_LVOCAMGChunk		EQU	-186
_LVOBODYChunk		EQU	-192
_LVOReadChunk		EQU	-198


VIDINAME MACRO
	dc.b	'vidi.library',0
	ENDM

CALLVIDI MACRO
	move.l	_VidiBase,a6
	jsr	_LVO\1(a6)
	ENDM

	ENDC


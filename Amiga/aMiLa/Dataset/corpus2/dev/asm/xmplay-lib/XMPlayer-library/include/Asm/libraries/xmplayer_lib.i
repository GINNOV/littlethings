	IFND LIBRARIES_XMPLAYER_LIB_I
LIBRARIES_XMPLAYER_LIB_I EQU 1
**
**	$Filename: libraries/xmplayer_lib.i $
**	$Release: 1.0a $
**	$Revision: 1.0a $
**
**	xmplayer.library definitions
**
**	Library coded by CruST / Amnesty^.humbug.
**	Released by .humbug. 17.04.2001
**	
**	Library based on the PS3M source 
**	Copyright (c) Jarno Paananen a.k.a. Guru / S2 1994-96.
**

	IFND LIBRARIES_XMPLATER_I
	include "libraries/xmplayer.i"
	ENDC


;======================================================================
; xmplayer.library functions
;======================================================================

_LVOXMPl_Init		=	-30
_LVOXMPl_Play		=	-36
_LVOXMPl_StopPlay	=	-42
_LVOXMPl_PausePlay	=	-48
_LVOXMPl_ContPlay	=	-54
_LVOXMPl_SetPos		=	-60
_LVOXMPl_GetPos		=	-66
_LVOXMPl_DeInit		=	-72

   ENDC ; LIBRARIES_XMPLAYER_LIB_I

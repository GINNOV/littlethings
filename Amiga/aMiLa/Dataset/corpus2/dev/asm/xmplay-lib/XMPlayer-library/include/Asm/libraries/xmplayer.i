	IFND LIBRARIES_XMPLAYER_I
LIBRARIES_XMPLAYER_I EQU 1
**
**	$Filename: libraries/xmplayer.i $
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

	IFND LIBRARIES_XMPLATER_LIB_I
	include "libraries/xmplayer_lib.i"
	ENDC

	IFND LIBRARIES_EXEC_TYPES_I
	include "exec/types.i"
	ENDC

XMPLAYERNAME	MACRO
	dc.b	"xmplayer.library",0
   ENDM

XMPLAYERVERSION		equ	1

;======================================================================
; XMPlayer Structure
;======================================================================

    STRUCTURE	XMPlayerInfo,0

	APTR	XMPl_Cont
	LONG	XMPl_Mixtype
	LONG	XMPl_Mixfreq
	LONG	XMPl_Vboost
	APTR	XMPl_PrName
	LONG	XMPl_PrPri

	LABEL	XMPlayerInfo_SIZE

;======================================================================
; XMPlayerPos Structure
;======================================================================

    STRUCTURE	XMPlayerPos,0

	LONG	XMPl_ModPos
	LONG	XMPl_PattPos

	LABEL	XMPlayerPos_SIZE


;======================================================================
; XM MIX Types
;======================================================================

XM_MONO		equ	0
XM_STEREO	equ	1
XM_SURROUND	equ	2
XM_REALSURR	equ	3
XM_STEREO14	equ	4


   ENDC ; LIBRARIES_XMPLAYER_I

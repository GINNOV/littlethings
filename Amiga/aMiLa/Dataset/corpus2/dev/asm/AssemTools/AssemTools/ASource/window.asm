;
; ###        v 1.00 ###
;
; - Created 871130 by JM -
;
;
; Opens a window - delays - closes the window - exits.
;
;
;
; Bugs: None known.
;
;
; Edited:
;
;
;
		INCLUDE	"exec/types.i"
;		INCLUDE "exec/alerts.i"
;		INCLUDE "exec/libraries.i"
		INCLUDE "libraries/dos.i"
		INCLUDE "intuition/intuition.i"
		INCLUDE "graphics/gfxbase.i"



		XREF	_LVOOpenLibrary
		XREF	_LVOCloseLibrary
		XREF	_LVOOutput
		XREF	_LVOWrite
		XREF	_LVOOpenWindow
		XREF	_LVOCloseWindow


SETC		MACRO
		OR	#1,CCR
		ENDM

CLRC		MACRO
		AND	#254,CCR
		ENDM

SETX		MACRO
		OR	#16,CCR
		ENDM

CLRX		MACRO
		AND	#239,CCR
		ENDM

		JMP	Start


MyWindow	DC.W	0,0,200,100	;upper x,y , bottom x,y
		DC.B	1,2		;detailpen, blockpen
		DC.L	0		;IDCMPFlags
		DC.L	WINDOWSIZING	;Flags
		DC.L	0		;gadgets
		DC.L	0		;checkmark
		DC.L	MyWinTitle	;title
		DC.L	0		;screen
		DC.L	0		;bitmap
		DC.W	0,0,300,200	;min-max size
		DC.W	WBENCHSCREEN	;type

MyWinTitle	DC.B	'ThisIsMine!',0,0

		DS.L	0
		


Start		MOVEM.L	D2-D7/A2-A6,-(sp)
		MOVE.L	D0,_CMDLen
		MOVE.L	A0,_CMDBuf
		BSR	OpenDOS
		BEQ	NoDOS

		BSR	OpenIN
		BEQ	NoIN

		BSR	OpenGFX
		BEQ	NoGFX



		LEA	MyWindow(PC),A0
		MOVE.L	_INBase(PC),A6
		JSR	_LVOOpenWindow(A6)
		MOVE.L	D0,_Ikkuna

		MOVE.L	#100000,D0
Loop:		SUBQ.L	#1,D0
		BNE	Loop


		MOVE.L	_Ikkuna(PC),A0
		MOVE.L	_INBase(PC),A6
		JSR	_LVOCloseWindow(A6)


Leave		BSR	CloseGFX
NoGFX		BSR	CloseIN
NoIN		BSR	CloseDOS		

NoDOS		MOVEM.L	(sp)+,D2-D7/A2-A6
		RTS






OpenDOS		MOVE.L	4,A6		;get execbase
		LEA	DOSLib(PC),A1	;get addr of library name
		MOVEQ.L	#0,D0		;any revision of dos
		JSR	_LVOOpenLibrary(A6)
		MOVE.L	D0,_DOSBase	;save base address
		RTS

CloseDOS	MOVE.L	_DOSBase(PC),A1	;library pointer
		MOVE.L	4,A6		;execbase
		JSR	_LVOCloseLibrary(A6)
		RTS


OpenIN		MOVE.L	4,A6		;get execbase
		LEA	INLib(PC),A1	;get addr of library name
		MOVEQ.L	#0,D0		;any revision of intuition
		JSR	_LVOOpenLibrary(A6)
		MOVE.L	D0,_INBase	;save base address
		RTS

CloseIN		MOVE.L	_INBase(PC),A1	;library pointer
		MOVE.L	4,A6		;execbase
		JSR	_LVOCloseLibrary(A6)
		RTS


OpenGFX		MOVE.L	4,A6		;get execbase
		LEA	GFXLib(PC),A1	;get addr of library name
		MOVEQ.L	#0,D0		;any revision of graphics library
		JSR	_LVOOpenLibrary(A6)
		MOVE.L	D0,_GFXBase	;save base address
		RTS

CloseGFX	MOVE.L	_GFXBase(PC),A1	;library pointer
		MOVE.L	4,A6		;execbase
		JSR	_LVOCloseLibrary(A6)
		RTS


DOSLib		DC.B	'dos.library',0,0
		DS.L	0
INLib		DC.B	'intuition.library',0,0
		DS.L	0
GFXLib		DC.B	'graphics.library',0,0

		DS.L	0

_DOSBase	DS.L	1
_INBase		DS.L	1
_GFXBase	DS.L	1
_OutFile	DS.L	1
_Ikkuna		DS.L	1
_CMDLen		DS.L	1
_CMDBuf		DS.L	1



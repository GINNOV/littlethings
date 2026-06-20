;*******************************************************
;*     Window Example show how to make some basic      *
;*  library calls. And how to use the include files    *
;*                                                     *
;*      ASM-One example coded by Rune Gram-Madsen      *
;*                                                     *
;*       All rights reserved. Copyright (c) 1990       *
;*******************************************************

	INCDIR	df0:include/

;---  Open library  ---

	include	exec/exec_lib.i
	include	libraries/dos_lib.i
	include	libraries/dos.i
	include	intuition/intuition_lib.i

J	BSR.S	DOS_LIBOPEN		; Open dos library
	BSR.L	INT_LIBOPEN		; Open intuition library
	BSR.L	WORKBENCH_FRONT		; Put the workbench to front
	BSR.L	WINDOW_OPEN		; Open window

;--- Print "Input your name:" ---

	MOVE.L	#TEXT1,D2		; Text start
	MOVEQ	#TEXT1_END-TEXT1,D3	; text length
	BSR.L	TEXT_WRITE		; Print text

;--- Input name ---

	MOVE.L	#BUFFER1,D2		; Input buffer
	MOVEQ	#BUFFER1_END-BUFFER1,D3	; Max input length
	BSR.L	TEXT_READ		; Input text

	MOVE.L	D0,-(A7)		; Store input length

;--- Print "Your name are" ---

	MOVE.L	#TEXT2,D2		; Text start
	MOVEQ	#TEXT2_END-TEXT2,D3	; text length
	BSR.L	TEXT_WRITE		; Print text

;--- Print name ---

	MOVE.L	#BUFFER1,D2		; The old input buffer
	MOVE.L	(A7)+,D3		; Length of the name
	BSR.L	TEXT_WRITE		; Print the text

;--- Print "Press <return>" ---

	MOVE.L	#TEXT3,D2		; Text start
	MOVEQ	#TEXT3_END-TEXT3,D3	; text length
	BSR.L	TEXT_WRITE		; print text

;--- Read <return> ---

	MOVE.L	#BUFFER2,D2		; buffer
	MOVEQ	#BUFFER2_END-BUFFER2,D3	; buffer length
	BSR.L	TEXT_READ		; read <return>

;--- Close down ---

	BSR.S	WINDOW_CLOSE		; Close window
	BSR.L	WORKBENCH_BACK		; workbench back again
	BSR.S	INT_LIBCLOSE		; close intuition lib
	BSR.S	DOS_LIBCLOSE		; close dos
	RTS

;--- Open dos library ---

DOS_LIBOPEN
	LEA.L	_DOSNAME(PC),A1
	MOVEQ	#0,D0
	CALLEXEC OpenLibrary
	MOVE.L	D0,_DOSBASE
	RTS

;--- Close dos library ---

DOS_LIBCLOSE
	MOVE.L	_DOSBASE(PC),A1
	CALLEXEC CloseLibrary
	RTS

;--- Open intuition library ---

INT_LIBOPEN
	LEA.L	_INTNAME(PC),A1
	MOVEQ	#0,D0
	CALLEXEC OpenLibrary
	MOVE.L	D0,_INTUITIONBASE
	RTS

;--- Close intuition library ---

INT_LIBCLOSE
	MOVE.L	_INTUITIONBASE(PC),A1
	CALLEXEC CloseLibrary
	RTS

;--- Open window ---

WINDOW_OPEN
	MOVE.L	#_WINDOWNAME,D1
	MOVE.L	#MODE_OLDFILE,D2
	CALLDOS	Open
	MOVE.L	D0,_WINDOWHANDLE
	RTS

;--- Close window ---

WINDOW_CLOSE
	MOVE.L	_WINDOWHANDLE(PC),D1
	CALLDOS	Close
	RTS

;--- Workbench to front ---

WORKBENCH_FRONT
	CALLINT	WbenchToFront
	RTS

;--- Workbench to back ---

WORKBENCH_BACK
	CALLINT	WbenchToBack
	RTS

TEXT_READ
	MOVE.L	_WINDOWHANDLE,D1
	CALLDOS	Read
	RTS

TEXT_WRITE
	MOVE.L	_WINDOWHANDLE,D1
	CALLDOS	Write
	RTS

_WINDOWNAME	DC.B	'CON:10/10/600/100/My Window',0
_WINDOWHANDLE	DC.L	0
_DOSNAME	DOSNAME
_DOSBASE	DC.L	0
_INTNAME	DC.B	'intuition.library',0
_INTUITIONBASE	DC.L	0
TEXT1		DC.B	'Input your name: '
TEXT1_END
TEXT2		DC.B	'Your name is: '
TEXT2_END
TEXT3		DC.B	'Press <return> '
TEXT3_END
BUFFER1		DCB.B	80,0
BUFFER1_END
BUFFER2		DCB.B	1,0
BUFFER2_END

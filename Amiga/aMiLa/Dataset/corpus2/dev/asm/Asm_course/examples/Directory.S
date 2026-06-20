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

J	LEA	PATH(PC),A0		; Default CLI message
	MOVE.L	A0,-(A7)		; Store CLI message

	BSR.W	DOS_LIBOPEN		; Open dos library
	BSR.L	WINDOW_OPEN		; Open window
	BSR.L	INT_LIBOPEN		; Open intuition library
	BSR.L	WORKBENCH_FRONT		; Put the workbench to front

	MOVE.L	(A7)+,D1		; Path pointer
	MOVEQ	#-2,D2			; Read mode
	CALLDOS	Lock			; Lock
	TST.L	D0
	BEQ.S	.ERROR			; Not found ??
	MOVE.L	D0,D5

	MOVE.L	D5,D1
	MOVE.L	#FILEINFO,D2
	CALLDOS	EXAMINE			; Examine first lock
	TST.L	D0
	BEQ.S	.ERROR

	MOVE.L	#TEXT2,D2
	MOVEQ	#TEXT2_END-TEXT2,D3
	MOVE.L	_WINDOWHANDLE(PC),D1
	CALLDOS	Write

.LOOP	MOVE.L	#FILEINFO+8,D0		; Disk/Dir/File-name ptr
	BSR.W	TEXT_PRINT		; Print name

	MOVE.L	D5,D1
	MOVE.L	#FILEINFO,D2
	CALLDOS	EXNEXT			; Next name on the disk
	TST.L	D0
	BNE.B	.LOOP

.ERROR	CALLDOS	IOERR			; Get message

;--- Close down ---

	MOVE.L	#TEXT1,D2
	MOVEQ	#TEXT1_END-TEXT1,D3
	MOVE.L	_WINDOWHANDLE(PC),D1
	CALLDOS	Write

	MOVE.L	#RETURN,D2
	MOVEQ	#1,D3
	MOVE.L	_WINDOWHANDLE(PC),D1
	CALLDOS	Read

	BSR.L	WORKBENCH_BACK		; workbench back again
	BSR.W	INT_LIBCLOSE		; close intuition lib
	BSR.S	WINDOW_CLOSE		; Close window
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

;---  Print text  ---

TEXT_PRINT:
	MOVE.L	D0,A0
.LOOP	TST.B	(A0)+
	BNE.S	.LOOP
	SUB.L	D0,A0
	SUBQ.L	#1,A0
	MOVE.L	A0,D3
	MOVE.L	D0,D2
	MOVE.L	_WINDOWHANDLE(PC),D1
	CALLDOS	Write
	MOVE.L	#RETURN,D2
	MOVEQ	#1,D3
	MOVE.L	_WINDOWHANDLE(PC),D1
	CALLDOS	Write
	RTS

;--- Open window ---

WINDOW_OPEN:
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

;--- Workbench to front ---

WORKBENCH_FRONT
	CALLINT	WbenchToFront
	RTS

;--- Workbench to back ---

WORKBENCH_BACK
	CALLINT	WbenchToBack
	RTS

TEXT1:		DC.B	$9B,'3',$6D,'Press <RETURN> : '
TEXT1_END:
TEXT2:		DC.B	$9B,'3',$6D,'Root name : ',$9B,'0',$6D
TEXT2_END:
RETURN:		DC.B	10
_WINDOWNAME	DC.B	'CON:10/10/400/180/Directory',0
	EVEN
_WINDOWHANDLE	DC.L	0
_DOSNAME	DOSNAME
_DOSBASE	DC.L	0
_INTNAME	DC.B	'intuition.library',0
_INTUITIONBASE	DC.L	0

PATH:		DC.B	'DF0:',0,0

	CNOP	0,4

FILEINFO:	DCB.L	260,0

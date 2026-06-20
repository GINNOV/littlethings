*crt0.asm
*   Copyright (C) 1990 Paul Gittings.
*
* This file is part of aMIGA gARGANTUAN c cOMPILER (agcc).
*
* agcc is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 1, or (at your option)
* any later version.
*
* agcc is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with agcc; see the file COPYING.  If not, write to
* the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
*
*
*	A startup/__main routine for use with agcc and CCLib.library
*	ctr0.o		should be used if floating point is required.
*	ctr0_no_fp.o	should be used when an application does not use
*			floating point.
*	The following libraries are loaded:
*		Dos.library
*		CCLib.library
*		MathIeeeDoubBas.library
*	
*	This routine is based on: 
*	Robert Albrecht's _main.c and
*	Bryce Nesbitt's BothStartup.asm 
*
*	Paul Gittings	21/2/1990
*	ACSnet          paulg@tplrd.tpl.oz
*	snail		172 Union St.
*			Erskineville 2043
*			NSW
*			Australia
*
******* Included Files *************************************************

;	NOLIST
;	INCLUDE "exec/types.i"


;	IFND EXEC_ABLES_I
;	INCLUDE "exec/ables.i"
;	ENDC
	
FORBID	MACRO
	IFC	'\1',''
	ADDQ.B	#1,TDNestCnt(A6)
	ENDC
	IFNC	'\1',''
	MOVE.L	4,\1
	ADDQ.B	#1,TDNestCnt(\1)
	ENDC
	ENDM

;	IFND EXEC_EXECBASE_I
;	INCLUDE "exec/execbase.i"
;	ENDC

ThisTask	EQU	$114
TDNestCnt	EQU	$127

;	IFND LIBRARIES_DOS_I
;	INCLUDE "libraries/dos.i"
;	ENDC

;	IFND LIBRARIES_DOESEXTENS_I
;	INCLUDE "libraries/dosextens.i"
;	ENDC

pr_CLI		EQU	$0ac
pr_MsgPort	EQU	$05c

;
;       Offsets into user data
;
ud_argc		EQU	 96
ud_argv		EQU	100

******* Imported *******************************************************

	xref	_main			; C code entry point

;	cclib routines.

	xref	_ClearSTDIO
	xref	_SetupSTDIO
	xref	_GetSTDIO

callsys macro
	xref	_LVO\1
	jsr	_LVO\1(a6)
	endm

******* Exported *******************************************************

	xdef	_SysBase
	xdef	_DOSBase
	xdef	_MathIeeeDoubBasBase
	xdef	_CCLibBase

	xdef	_errno
	xdef	_stdin
	xdef	_stdout
	xdef	_stderr
	xdef	__math
	xdef	_blocksize
	xdef	_exit_fcn
	xdef	_type

	xdef	_exit			; standard C exit function
	xdef	__exit

************************************************************************
*
*	Standard Program Entry Point
*
*	If called from CLI then a0 will point to a buffer containing the
*	command line but not including the command name. Also, d0 will
*	contain the length of this line.
*
*
;
;a3 - frame pointer
;a4 - ThisTask
dosCmdLen	equr	d6
dosCmdBuf	equr	d5
;
startup:	move.l	d0,dosCmdLen
		move.l	a0,dosCmdBuf
		lea.l	ss,a3		; set up "frame pointer"
		clr.l	(a3)+		; _errno
		clr.l	(a3)+		; _exit_fcn
		move.l	sp,(a3)+	; _initialSP

	;------ get Exec's library base pointer:
		move.l	4,a6		; get _AbsExecBase
		move.l	a6,(a3)+	; _SysBase

	;------ Open the DOS library:

		clr.l	d0
		lea.l	DOSName(pc),A1
		callsys OpenLibrary
		tst.l	d0
		beq	bailout
		move.l	d0,(a3)+	; _DOSBase

	;------ Open Math Ieee Double library:

		clr.l	d0
		lea.l	MathIeeeName(pc),a1
		callsys	OpenLibrary
		tst.l	d0
		beq	bailout
		move.l	d0,(a3)+	; _MathIeeeDoubBasBase

	;------ Open CCLib library:

		clr.l	d0
		lea.l	CCLibName(pc),a1
		callsys	OpenLibrary
		tst.l	d0
		beq	bailout
		move.l	d0,(a3)+	; _CCLibBase

	;------ get the address of our task
		move.l	ThisTask(a6),a4

	;------ were we started from the Workbench
		tst.l	pr_CLI(A4)
		beq.s	fromWorkbench

	;------ No, then we were started by CLI.
	;------ so clear out workbench msg pointer
		clr.l	(a3)+		; returnMsg
		bra.s	skipwbstartup

;
;------- Do some Workbench specific startup work
;

	;------ we are now set up.  wait for a message from our starter
fromWorkbench:	;[a4=ThisTask]
nostartupmsg:
		lea.l	pr_MsgPort(A4),a0	; our process base
		callsys WaitPort
	;------ Get the message and save in returnMsg
		lea.l	pr_MsgPort(A4),a0	; our process base
		callsys GetMsg
		tst.l	d0
		beq.s	nostartupmsg    ; ROM kernal manual says we could
					; get a signal but no msg...

		move.l	d0,(a3)+ 	; returnMsg

skipwbstartup:
		clr.l	(a3)+		; _stdin
		clr.l	(a3)+		; _stdout
		clr.l	(a3)+		; _stderr
		clr.l	(a3)+		; _type
		clr.l	(a3)		; _blocksize
		lea.l	ss,a3
;
;  SetupSTDIO(&stdin, &stdout, &stderr, &errno, &blocksize, &type,
;		MathIeeeDoubBasBase, dosCmdLen, dosCmdBuf, returnMsg,
;		_exit)
;

		pea	__exit
		move.l	returnMsg-ss(a3),-(sp)
		move.l	dosCmdBuf,-(SP)
		move.l	dosCmdLen,-(SP)
		move.l	_MathIeeeDoubBasBase-ss(a3),-(sp)
		pea	_type-ss(a3)
		pea	_blocksize-ss(a3)
		pea	_errno-ss(a3)
		pea	_stderr-ss(a3)
		pea	_stdout-ss(a3)
		pea	_stdin-ss(a3)
		jsr	_SetupSTDIO

		add.w	#44,sp
		tst.l	d0
		beq.s	bailout

	;------ get pointer to the block of user data (ud) belonging to
	;------ this task.

		jsr	_GetSTDIO	; put ud into d0
		tst.l	d0
		beq.s	bailout

	;------ push argv and argc from the ud onto the stack
	;------ and call main()
		move.l	d0,a1
		move.l  ud_argv(a1),-(sp)	; put ud->_argv onto stack
		clr.l	d0
		move.w	ud_argc(a1),d0	; get ud->_argc and
		move.l	d0,-(sp)	; push to stack

		jsr _main		; hand over to C main routine.

		clr.l	_errno		; Successful return code
		bra.s	exit2

	;------ get here if something went wrong during startup.
bailout:
		move.l	#$DEADBEEF,_errno
		bra.s	exit2

************************************************************************
*
*	C Program exit(returncode) Function
*
*
; a1 - general
; a3 - Frame pointer
; a6 - Exec Base pointer
_exit:
__exit:
		move.l	4(SP),_errno	 ; save error code
exit2:		lea.l	ss,a3		 ; set "frame pointer" back up

	;------ check for an exit function set up by call to atexit().
	;------ If there is one execute it.

		move.l	_exit_fcn-ss(a3),a1
		cmp.l	#0,a1
		beq.s	no_atexit_fcn
		jsr	(a1)

no_atexit_fcn:
		move.l	_initialSP-ss(a3),SP	; restore stack pointer

		move.l	4,a6

	;------ If MathIeeeDoubBas.library is open close it
		move.l	_MathIeeeDoubBasBase-ss(a3),a1
		cmp.l	#0,a1
		beq.s	no_MIDB
		callsys CloseLibrary
no_MIDB:
	;------ If CCLib.library is open close it
		move.l	_CCLibBase-ss(a3),a2
		cmp.l	#0,a2
		beq.s	no_CCLib
	;------ close all files free memory 
		jsr _ClearSTDIO
		move.l	a2,a1
		callsys CloseLibrary

no_CCLib:
	;------ If DOS library is open close it
		move.l	_DOSBase-ss(a3),a1
		cmp.l	#0,a1
		beq.s	exitToDOS
		callsys CloseLibrary

exitToDOS:
		move.l	_errno-ss(a3),d0	; save return code
		rts
******* DATA ***********************************************************

DOSName:	dc.b 'dos.library',0
		EVEN
MathIeeeName:	dc.b 'mathieeedoubbas.library',0
		EVEN
CCLibName:	dc.b 'CClib.library',0
		EVEN
__math		dc.w 1	; Set to indicate MathIEEEDoubBas is loaded.
		EVEN
		BSS	b.crt0
ss			; placemarker
_errno		ds.l 1	; error number from OS routines
_exit_fcn	ds.l 1	; exit function ptr. setup by call to atexit
_initialSP	ds.l 1	; initial stack pointer
_SysBase	ds.l 1	; exec library base pointer
_DOSBase	ds.l 1	; dos library base pointer
_MathIeeeDoubBasBase	ds.l 1	; Math Ieee Double library base pointer
_CCLibBase	ds.l 1	; CCLib library base pointer
returnMsg	ds.l 1	; Workbench message, or zero for CLI startup
_stdin		ds.l 1	;       STANDARD 
_stdout 	ds.l 1	;	        I/O FILE
_stderr 	ds.l 1	;			POINTERS
_type		ds.l 1
_blocksize	ds.l 1	; blocksize global variable

		END

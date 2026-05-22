;****** Auto-Revision Header (do not edit) *******************************
;*
;* © Copyright by MMSoftware
;*
;* Filename         : Decrunch.s
;* Created on       : 02-Nov-90
;* Created by       : M.Meany
;* Current revision : V0.000
;*
;*
;* Purpose: Small utility to decrunch PowerPacked data files. Mainly so
;*          I could assign it to a button in SID!
;*                                                    M.Meany (02-Nov-90)
;*          
;*
;* V0.000 : --- Initial release ---
;*
;*************************************************************************
REVISION        MACRO
                dc.b "0.000"
                ENDM
REVDATE         MACRO
                dc.b "02-Nov-90"
                ENDM


	incdir	sys:include/
	include exec/exec.i
	include exec/exec_lib.i

	include libraries/dos.i
	include libraries/dosextens.i
	include libraries/dos_lib.i

	include graphics/gfxbase.i
	include	graphics/graphics_lib.i

	include intuition/intuition.i
	include intuition/intuition_lib.i

	include	devices/console_lib.i
	include devices/inputevent.i
	include	source:include/mmMacros.i

		include		source:include/ppbase.i
		include		source:include/powerpacker_lib.i

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		lea		Variables,a5		a5->var base
	
		move.l		a0,_args(a5)		save addr of CLI args
		move.l		d0,_argslen(a5)		and the length
		move.b		#0,-1(a0,d0)

		bsr.s		Openlibs		open libraries
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr.s		Init			Initialise data
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		Main

no_win		bsr		DeInit			free resources

no_libs		bsr		Closelibs		close open libraries

		rts					finish


;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		dosname(pc),a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_DOSBase		save base ptr
		beq.s		.lib_error		quit if error

		lea		intname(pc),a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLSYS		OpenLibrary		and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq.s		.lib_error		quit if error

		lea		gfxname(pc),a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLSYS		OpenLibrary		and open it
		move.l		d0,_GfxBase		save base ptr
		beq.s		.lib_error		quit if error

		lea		ppname(pc),a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLSYS		OpenLibrary		and open it
		move.l		d0,_PPBase		save base ptr

.lib_error	rts

*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		moveq.l		#0,d0
		tst.l		returnMsg		from WorkBench?
		bne.s		.error			yes, quit now!

		CALLDOS		Output			determine CLI handle
		move.l		d0,STD_OUT(a5)		save it for later
		beq.s		.err			quit if no handle

		move.l		_args(a5),a0		get addr of CLI args
		cmpi.b		#'?',(a0)		is the first arg a ?
		bne.s		.ok			no, skip next bit

		lea		_UsageText(pc),a0	a0->the usage text
		bsr.s		DosPrint		and display it
.err		moveq.l		#0,d0			set an error
		bra.s		.error			and finish

;--------------	Your Initialisations should start here

.ok		moveq.l		#1,d0			no errors

.error		rts					back to main

***************	Release any additional resources used

DeInit
		rts

***************	Close all open libraries

; Closes any libraries the program managed to open.

Closelibs	move.l		_DOSBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_IntuitionBase,d0	d0=base ptr	
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLSYS		CloseLibrary		close lib

		move.l		_GfxBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLSYS		CloseLibrary		close lib

		move.l		_PPBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLSYS		CloseLibrary		close lib

.lib_error	rts


*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

;--------------
;--------------	Writes a NULL terminated message to STD_OUT
;--------------

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosPrint	movem.l		d0-d3/a0-a3,-(sp) 	save registers

		tst.l		STD_OUT(a5)		test for open console
		beq.s		.error			quit if not one

		move.l		a0,a1			get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3			reset counter
.loop		addq.l		#1,d3			bump counter
		tst.b		(a1)+			is this byte a 0
		bne.s		.loop			if not loop back

;--------------	Make sure there was a message

		tst.l		d3			was there a message ?
		beq.s		.error			no, graceful exit

;--------------	Get handle of output file

		move.l		STD_OUT(a5),d1		d1=file handle
		beq.s		.error			leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2			d2=address of message
		CALLDOS		Write			and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3	restore registers
		rts

**************	Load a file using powerpacker.library

; Requires following variables accessed by a5:

;LoadFileBuff	 rs.l		1		ponter to loaded data
;LoadFileBuffLen rs.l		1		byte size of loaded data

; Subroutine that loads a file into a block of memory.

; Entry		a0-> filename
;		d0=  type of memory

; Exit		d0= length of buffer allocated
;		a0->buffer

; Corrupt	d0,a0

PPLoadFile	movem.l		d1-d7/a1-a6,-(sp)

; Use powerpacker.library to load data from disk

.NoFile		moveq.l		#DECR_POINTER,d0	effect
		moveq.l		#0,d1
		lea		LoadFileBuff(a5),a1
		lea		LoadFileBuffLen(a5),a2
		move.l		d1,a3
		CALLNICO	ppLoadData

; Set return data

		move.l		LoadFileBuff(a5),a0
		move.l		LoadFileBuffLen(a5),d0

		movem.l		(sp)+,d1-d7/a1-a6

		rts

*****************************************************************************
*			Data Section					    *
*****************************************************************************

		dc.b		'$VER: v'
		REVISION
		dc.b		', © M.Meany ('
		REVDATE
		dc.b		')',0
		even

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even
ppname		dc.b		'powerpacker.library',0
		even
		
; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'Decrunch v'
		REVISION
		dc.b		', © M.Meany ('
		REVDATE
		dc.b		')',$0a
		dc.b		'Usage: Decrunch <filename>',$0a,$0a,0
		even

;***********************************************************
;	SECTION	Vars,BSS
;***********************************************************

		rsreset
_args		rs.l		1
_argslen	rs.l		1

STD_OUT		rs.l		1

LoadFileBuff	 rs.l		1		ponter to loaded data
LoadFileBuffLen rs.l		1		byte size of loaded data

varsize		rs.b		0

		SECTION	Vars,BSS

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_PPBase		ds.l		1

Variables	ds.b		varsize

		section		Skeleton,code

***** Your code goes here!!!

; NOTES: dos, graphics and intuition libraries are open.
;	 Register a5 is used to access variables, add your own to defenitions
;	 above.
;	 _args(a5) and _argslen(a5) contain startup values of a0,d0

; Load and decrunch the data file

Main		move.l		(a5),a0			filename
		moveq.l		#0,d0			any memory
		bsr		PPLoadFile
		tst.l		d0
		beq.s		.done

; Now open file

		move.l		(a5),d1			filename
		move.l		#MODE_NEWFILE,d2	for writing
		CALLDOS		Open			open it
		move.l		d0,d7
		beq.s		.Error1

; Write decrunched data into it

		move.l		d7,d1			handle
		move.l		LoadFileBuff(a5),d2	buffer
		move.l		LoadFileBuffLen(a5),d3	size
		CALLSYS		Write

; Close the file

		move.l		d7,d1
		CALLSYS		Close

; Release memory for loaded data

.Error1		move.l		LoadFileBuff(a5),a1	buffer
		move.l		LoadFileBuffLen(a5),d0	size
		CALLEXEC	FreeMem

; All done so exit

.done		rts




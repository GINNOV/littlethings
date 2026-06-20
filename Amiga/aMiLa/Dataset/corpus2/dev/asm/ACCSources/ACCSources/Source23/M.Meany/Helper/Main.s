
*****	Title		Helper
*****	Function	General purpose information displayer
*****			
*****			
*****	Size		Quite big considering!
*****	Author		Mark Meany
*****	Date Started	8 March 92
*****	This Revision	9 March 92
*****	Notes		At last!
*****			Still needs some word on graphics and a file requester
*****
*****			Main window opening.
*****			Sleep and search gadgets working.
*****			Sleep window 'wakes up' via RMB press.
*****			Intro message displayed at start.
*****			Error message displayed if source not found.
*****			Approx 60% of structures data added.
*****			Windows remember their position while sleeping.
*****			
*****	9 March		RMB can be used to send window to sleep.
*****			Up/Down scroll now implemented under INTUITICKS.
*****	- IDEA -	Allow program to load 'ANY' text file and use this
*****			as the search base ... also allow search by subfield
*****			( with next/previous features ) and printing of
*****			solution.
*****
*****	10 March	Have cut data file from source and attempted to
*****			implement a 'loader' into the program. Life would
*****			have been so much easier if I'd decided on this
*****			approach right from the start. Maybe I'll pay more
*****			attention in future .... cheers DE, lesson learnt!

*****	11 March	National 'No Smoking' day, arrggg. 

*****			Can now specify name of help file to load as a CLI
*****			parameter

	incdir	sys:include/
;	incdir	df2:
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


		include	sysmacros.i

		section		SHlp,code		name of code section

Start		move.b		#0,-1(a0,d0)		NULL cli param list
		move.l		a0,DefaultFile		save pointer

		bsr		OpenLibs		open DOS, Int & Gfx
		tst.l		d0			errors?
		beq		QuitFast		if so get out now!

; lets start as we mean to carry on, using a mem block for vars. Throught the
;rest of the program, a5 will point to this block.

		move.l		#VarSize,d0		block size
		move.l		#MEMF_CLEAR,d1		type
		CALLEXEC	AllocMem		get block
		tst.l		d0			test addr
		beq		Error1			quit if none
		movea.l		d0,a5			into addr reg

; Now build the line list

		move.l		DefaultFile,a0		a0->filename
		bsr		LoadData		load it
		tst.l		d0			error?
		bne.s		.CanGo			skip if not

; If specified file not present, try default file!

		lea		DefaultFile1,a0
		bsr		LoadFile
		tst.l		d0
		beq		Error1
			
; Set up some default values

; starting with the string gadget buffers

.CanGo		lea		SearchGadg,a0		a0->gadget
		move.l		gg_SpecialInfo(a0),a0	a0->StringInfo
		lea		SearchBuff(a5),a1	a1->buffer
		move.l		a1,(a0)+		write address
		addq.l		#4,a1			a1->undo buffer
		move.l		a1,(a0)			write address

; now the IText structure used to display the solution

		lea		PrintBuff(a5),a0	a0->expansion
		move.l		a0,L1ptr

; and a little intro message

		move.l		#IntroMsg,LastSoln(a5)	set message pointer

; Get going on the main routine

		bsr		Helper			go to main code

; free memory used for line list

		tst.l		LineLen(a5)
		beq.s		Error2
		move.l		LineList(a5),a1
		move.l		LineLen(a5),d0
		CALLEXEC	FreeMem

; free memory used for variables

Error2		move.l		a5,a1			mem block address
		move.l		#VarSize,d0		size
		CALLEXEC	FreeMem			release it

; close libraries

Error1		bsr		CloseLibs		close 'em all

; and finish

QuitFast	moveq.l		#0,d0			no DOS errors
		rts					exit

****************************************************************************
*		Subroutines						   *
****************************************************************************


;--------------
;--------------	Open system libraries
;--------------

* Function	Opens all libraries required by a program and stores base
;		pointers.

* Entry		None

* Exit		d0=0 if no errors occurred, else d0 holds addr of name
;		of library that failed to open.

* Corrupt	d0

OpenLibs	movem.l		d1-d2/a0-a2/a6,-(sp)	save registers

; Open DOS library

		lea		dosname,a1		a1->libname
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open it
		move.l		d0,_DOSBase		save base pointer
		bne.s		.DoInt			next lib if no errors
		move.l		#dosname,d0		else set error
		bra.s		.LibError		and quit

; Open Intuition library

.DoInt		lea		intname,a1		a1->libname
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open it
		move.l		d0,_IntuitionBase	save base pointer
		bne.s		.DoGfx			next lib if no errors
		move.l		#intname,d0		else set error
		bra.s		.LibError		and quit

; Open Graphics library

.DoGfx		lea		gfxname,a1		a1->libname
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open it
		move.l		d0,_GfxBase		save base pointer
		bne.s		.DoNext			next lib if no errors
		move.l		#gfxname,d0		else set error
		bra.s		.LibError		and quit

; Open any addittional libraries here

.DoNext		nop				open extra libs here

.LibError	movem.l		(sp)+,d1-d2/a0-a2/a6	restore
		rts

;--------------
;--------------	Close system libraries
;--------------

* Function	Closes all libraries opened by OpenLibs. If a library base
;		pointer is NULL, does not attempt to close the library.

* Entry		None

* Exit		None

* Corrupt	None

CloseLibs	movem.l		d0-d3/a0-a3/a6,-(sp)	save

; Close DOS library

		move.l		_DOSBase,d0		get base pointer
		beq.s		.DoInt			skip if not there
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close the library

.DoInt		move.l		_IntuitionBase,d0	get base pointer
		beq.s		.DoGfx			skip if not there
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close the library

.DoGfx		move.l		_GfxBase,d0		get base pointer
		beq.s		.Done			skip if not there
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close the library

.Done		movem.l		(sp)+,d0-d3/a0-a3/a6	restore
		rts


;--------------
;--------------		******* Main routine *******
;--------------

Helper		bsr		OpenMain
		tst.l		d0
		beq.s		.Error
		
; deal with user interaction

		HANDLEIDCMP	#MainHandaler		IDCMP server routine
		move.l		d0,d7			save return value

; close the set up window

		bsr		CloseMain

.Error		rts

;--------------
;--------------	Universal quit routine
;--------------

DoQuit		move.l		#CLOSEWINDOW,d2
		moveq.l		#0,d7
		rts

;--------------
;--------------	FOR DEVELOPMENT ONLY
;--------------

DoNothing	rts

		include		SearchSubs

		include		loadfile.i

		include		Subroutines.i

****************************************************************************
*		String Data						   *
****************************************************************************

		section		strings,data

;--------------
;--------------	Data required by OpenLibs and CloseLibs
;--------------

; intro text - why not!

IntroMsg	dc.b	'*',$09,'Programmed by: Mark Meany.',0
		dc.b	$09,0
		dc.b	$09,'Address        12 Hinkler rd.,',0
		dc.b	$09,'               Thornhill,',0
		dc.b	$09,'               Southampton,',0
		dc.b	$09,'               Hants.',0
		dc.b	0
		even

NotFoundMsg	dc.b	'*',$09,'Sorry, not info on that structure!',0
		dc.b	0
		even
		
; library names ( must be lower case )

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even

DefaultFile	dc.l		1	'df1:helputil/structures.txt',0
		even
DefaultFile1	dc.b		'source:helper/struct.hlp',0
		even

; library base pointers, official names used for compatability.

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

; The data base.

****************************************************************************
*		Variables						   *
****************************************************************************

		rsreset

window.ptr	rs.l		1
window.up	rs.l		1
window.rp	rs.l		1

OldXm		rs.w		1
OldYm		rs.w		1
OldXz		rs.w		1
OldYz		rs.w		1

RFfile_name	rs.l		1
RFfile_lock	rs.l		1
RFfile_info	rs.l		1
RFfile_len	rs.l		1

StructData	rs.l		1
StructDataLen	rs.l		1

LastSoln	rs.l		1
LineList	rs.l		1
LineLen		rs.l		1

TopLine		rs.l		1
BottomLine	rs.l		1
DisplayLines	rs.l		1

GadgetSub	rs.l		1

SearchBuff	rs.b		32
UndoBuff	rs.b		32
PrintBuff	rs.b		100

VarSize		rs.l		0

****************************************************************************
*		Intuition Structures					   *
****************************************************************************

		section		IntStuff,data

		include		Win.i



; Skeleton code written for ACC Intuition tutorials.

; Code will assemble and can be launched from WB or CLI. Opens an Intuition
;window and waits for close gadget. Other tests also included: Gadgets
;and menus.

; A number of useful subroutines are also included. See documentation.

; Usage text is supported from the CLI. ( see line 420 ).

; © M.Meany, June 1991.

;		opt 		o+,ow-

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

;		include		"misc/easystart.i"

		move.l		a0,_args	save addr of CLI args
		move.l		d0,_argslen	and the length

		bsr.s		Openlibs	open libraries
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		Init		Initialise data
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		MyProcess	generate include file

no_win		bsr		DeInit		free resources

no_libs		bsr		Closelibs	close open libraries

		rts				finish


;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base ptr

		rts

*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		CALLDOS		Output		determine CLI handle
		move.l		d0,STD_OUT	and save it for later
		beq.s		.err		quit if there is no handle

		move.l		_args,a0	get addr of CLI args
		cmpi.b		#'?',(a0)	is the first arg a ?
		bne.s		.ok		if not skip the next bit

		lea		_UsageText,a0	a0->the usage text
		bsr		DosMsg		and display it
.err		moveq.l		#0,d0		set an error
		bra.s		.error		and finish

;--------------	Your Initialisations should start here

.ok		moveq.l		#1,d0		no errors

.error		rts				back to main

***************	Release any additional resources used

DeInit
		rts

***************	Close all open libraries

; Closes any libraries the program managed to open.

Closelibs	move.l		_DOSBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts


MyProcess	lea		incfile,a0	file name
		move.l		#MEMF_PUBLIC,d0		mem type
		bsr		LoadFile	load file in
		move.l		d0,d5		save mem len
		beq		.error		quit if error

		move.l		a0,a5		save mem pointer

		lea		WorkingText,a0	a0->the text
		bsr		DosMsg		and display it

		move.l		#incfile,d1	file
		move.l		#MODE_NEWFILE,d2	create
		CALLDOS		Open
		move.l		d0,d6		save handle
		beq		.error1		quit if error

		move.l		d0,d1		handle
		move.l		#header,d2	buffer
		move.l		#headerlen,d3	length
		CALLSYS		Write		save header

		move.l		d6,d1		handle
		move.l		a5,d2		buffer
		move.l		d5,d3		length
		CALLSYS		Write		save offsets

		move.l		d6,d1		handle
		CALLSYS		Close		and close the file

.error1		move.l		a5,a1		buffer
		move.l		d5,d0		size
		CALLEXEC	FreeMem		and release it

.error		rts

*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

***************	Subroutine to display any message in the CLI window

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosMsg		movem.l		d0-d3/a0-a3,-(sp) save registers

		tst.l		STD_OUT		test for open console
		beq		.error		quit if not one

		move.l		a0,a1		get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3		reset counter
.loop		addq.l		#1,d3		bump counter
		tst.b		(a1)+		is this byte a 0
		bne.s		.loop		if not loop back

;--------------	Make sure there was a message

		tst.l		d3		was there a message ?
		beq.s		.error		if not, graceful exit

;--------------	Get handle of output file

		move.l		STD_OUT,d1	d1=file handle
		beq.s		.error		leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2		d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3 restore registers
		rts


; Subroutine that loads a file into a block of memory.

; Entry		a0-> filename
;		d0=  type of memory ( either CHIPMEM, FASTMEM or PUBLICMEM )

; Exit		d0= length of buffer allocated
;		a0->buffer

; Corrupt	d0,a0

LoadFile	movem.l		d1/d5/d6/a4/a5,-(sp)

		move.l		d0,d1		save requirements
		move.l		a0,a4		save filename pointer

		jsr		FileLen		obtain thhe size of the file

		move.l		d0,d5		save file size
		beq.s		.error		quit if zero

;--------------	Filesize determined so allocate a buffer. NB d1= requirements.

		CALLEXEC	AllocMem	get buffer
		move.l		d0,a5		save pointer
		tst.l		d0		all ok?
		bne.s		.cont		if so skip next bit

		moveq.l		#0,d5		set error
		bra		.error		and quit

.cont		move.l		a4,d1		d1->filename
		move.l		#MODE_OLDFILE,d2 access mode
		CALLDOS		Open		open the file
		move.l		d0,d6		save handle
		bne		.cont1		quit if error

		move.l		a5,a1		buffer
		move.l		d5,d1		length
		CALLEXEC	FreeMem		and release it
		moveq.l		#0,d5		set error
		bra		.error		and quit

.cont1		move.l		d0,d1		handle
		move.l		a5,d2		buffer
		move.l		d5,d3		file length
		CALLDOS		Read		and load the file

		move.l		d6,d1		handle
		CALLDOS		Close		close the file

		move.l		a5,a0		a0->buffer
.error		move.l		d5,d0		d0=return value
		movem.l		(sp)+,d1/d5/d6/a4/a5
		rts

****************

; Subroutine that returns the length of a file in bytes.

; Entry		a0-> filename

; Exit		d0 = length of file in bytes or 0 if any error occurred

; Corrupted	d0

; M.Meany, Feb 91

; Save register values

FileLen		movem.l		d1-d7/a0-a6,-(sp)

; Save address of filename and clear file length

		move.l		a0,-(sp)
		move.l		#0,d5

; Allocate some memory for the File Info block

		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,d6
		beq		.error1
		
; Lock the file
		
		move.l		(sp),d1
		move.l		#ACCESS_READ,d2
		CALLDOS		Lock
		move.l		d0,d7
		beq		.error2

; Use Examine to load the File Info block

		move.l		d0,d1
		move.l		d6,d2
		CALLDOS		Examine

; Copy the length of the file into d5

		move.l		d6,a0
		move.l		fib_Size(a0),d5

; Release the file

		move.l		d7,d1
		CALLDOS		UnLock

; Release allocated memory

.error2		move.l		d6,a1
		move.l		#fib_SIZEOF,d0
		CALLEXEC	FreeMem

; All done so return

.error1		move.l		(sp)+,a0
		move.l		d5,d0
		movem.l		(sp)+,d1-d7/a0-a6
		rts

*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even

;incfile		dc.b		'ram:acc_lib.i',0
;		even

incfile		dc.b		'df1:Project/lib_development/acc_lib.i',0
		even

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'Utility for generating assembler include file for acc.library.'
		dc.b		$0a
		dc.b		'                   © M.Meany, Oct 91.',$0a
		dc.b		$0a
		dc.b		0
		even

WorkingText	dc.b		$0a,' Generating the assembler include file!',$0a,$0a,0
		even


header
	dc.b	'; acc.library assembler include file. © M.Meany, 1991.',$0a,$0a
	dc.b	'; First a few constants for use with library functions.',$0a,$0a
	dc.b	'PUBLICMEM	equ	0',$0a
	dc.b	'FASTMEM		equ	1',$0a
	dc.b	'CHIPMEM		equ	2',$0a,$0a

	dc.b	'; Now the structure for nodes in the supported list code:',$0a,$0a
	dc.b	'		rsreset',$0a
	dc.b	'nd_Succ	rs.l		1',$0a
	dc.b	'nd_Pred	rs.l		1',$0a
	dc.b	'nd_Data	rs.l		1',$0a
	dc.b	'nd_SIZEOF	rs.l		1',$0a

	dc.b	$0a
	dc.b	'; Next come the name and calling macros:',$0a,$0a
	dc.b	'ACCNAME		macro',$0a
	dc.b	"		dc.b		'acc.library',0",$0a
	dc.b	'		even',$0a
	dc.b	'		endm',$0a
	dc.b	$0a
	dc.b	'CALLACC		macro',$0a
	dc.b	'		move.l		_AccBase,a6',$0a
	dc.b	'		jsr		_LVO\1(a6)',$0a
	dc.b	'		endm',$0a
	dc.b	$0a
	dc.b	'; Finally the function offsets themselves:',$0a
	dc.b	$0a
headerlen	equ	*-header
		even

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1

_DOSBase	ds.l		1

STD_OUT		ds.l		1



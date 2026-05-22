
; Skeleton DOS startup code.

; Code will assemble and can be launched from WB or CLI. Opens an Console
;window if run from the WorkBench and uses this for i/o.

; A number of useful subroutines are also included. See documentation.

; Usage text is supported from the CLI. ( see line 363 ).

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

MYEXEC		macro
		move.l		a6,-(sp)
		move.l		4.w,a6
		jsr		_LVO\1(a6)
		move.l		(sp)+,a6
		endm

MYDOS		macro
		move.l		a6,-(sp)
		move.l		_DOSBase,a6
		jsr		_LVO\1(a6)
		move.l		(sp)+,a6
		endm


		section		Skeleton,code

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		move.l		a0,_args	save addr of CLI args
		move.l		d0,_argslen	and the length

		bsr.s		Openlibs	open libraries
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		Init		Initialise data
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

; ************
; 		bsr		Main		Your routine

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

.lib_error	rts

*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		tst.l		returnMsg	are we from WorkBench?
		bne.s		.err		if so quit!

		CALLDOS		Output		determine CLI handle
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


*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

****************

; Subroutine that loads a file into a block of memory.

; Entry		a0-> filename
;		d0=  type of memory ( either CHIPMEM, FASTMEM or PUBLICMEM )

; Exit		d0= length of buffer allocated
;		a0->buffer

; Corrupt	d0,a0

LoadFile	movem.l		d1/d5/d6/a4/a5,-(sp)

		move.l		d0,d1		save requirements
		move.l		a0,a4		save filename pointer

		bsr		FileLen		obtain thhe size of the file

		move.l		d0,d5		save file size
		beq.s		.error		quit if zero

;--------------	Filesize determined so allocate a buffer. NB d1= requirements.

		MYEXEC		AllocMem	get buffer
		move.l		d0,a5		save pointer
		tst.l		d0		all ok?
		bne.s		.cont		if so skip next bit

		moveq.l		#0,d5		set error
		bra		.error		and quit

.cont		move.l		a4,d1		d1->filename
		move.l		#MODE_OLDFILE,d2 access mode
		MYDOS		Open		open the file
		move.l		d0,d6		save handle
		bne		.cont1		quit if error

		move.l		a5,a1		buffer
		move.l		d5,d1		length
		MYEXEC		FreeMem		and release it
		moveq.l		#0,d5		set error
		bra		.error		and quit

.cont1		move.l		d0,d1		handle
		move.l		a5,d2		buffer
		move.l		d5,d3		file length
		MYDOS		Read		and load the file

		move.l		d6,d1		handle
		MYDOS		Close		close the file

		move.l		a5,a0		a0->buffer
.error		move.l		d5,d0		d0=return value
		movem.l		(sp)+,d1/d5/d6/a4/a5
		rts

****************

; Routine to create a file and write data to it.

; Entry		a0->Filename
;		a1->Buffer
;		d0=buffer size ( number of bytes to write ).

; Exit		d0=0 if an error occurred, non zero if file created.

; Corrupted	d0,a0

SaveFile	movem.l		d1-d5/a1-a4,-(sp)

		move.l		d0,d4		working copies
		move.l		a1,a4

		move.l		a0,d1		filename
		move.l		#MODE_NEWFILE,d2 access mode
		MYDOS		Open		and open file
		move.l		d0,d5		save handle
		beq		.error		quit if no file

		move.l		d0,d1		handle
		move.l		a4,d2		buffer
		move.l		d4,d3		size
		MYDOS		Write		write data to file

		move.l		d5,d1		handle
		MYDOS		Close		close file

.error		move.l		d5,d0		  set return code
		movem.l		(sp)+,d1-d5/a1-a4
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

		move.l		a0,a6
		move.l		#0,d5

; Allocate some memory for the File Info block

		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		MYEXEC		AllocMem
		move.l		d0,d6
		beq		.error1
		
; Lock the file
		
		move.l		a6,d1
		move.l		#ACCESS_READ,d2
		MYDOS		Lock
		move.l		d0,d7
		beq		.error2

; Use Examine to load the File Info block

		move.l		d0,d1
		move.l		d6,d2
		MYDOS		Examine

; Copy the length of the file into d5

		move.l		d6,a0
		move.l		fib_Size(a0),d5

; Release the file

		move.l		d7,d1
		MYDOS		UnLock

; Release allocated memory

.error2		move.l		d6,a1
		move.l		#fib_SIZEOF,d0
		MYEXEC		FreeMem

; All done so return

.error1		move.l		d5,d0
		movem.l		(sp)+,d1-d7/a0-a6
		rts

****************

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

***************	Converts text string to upper case.

;Entry		a0->start of null terminated text string

;Exit		a0->end of text string ( the zero byte ).

;corrupted	a0

ucase		tst.b		(a0)
		beq.s		.error
		
.loop		cmpi.b		#'a',(a0)+
		blt.s		.ok
		
		cmp.b		#'z',-1(a0)
		bgt.s		.ok
		
		subi.b		#$20,-1(a0)
		
.ok		tst.b		(a0)
		bne.s		.loop
		
.error		rts

*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'This is only a skeleton routine written for:'
		dc.b		$0a
		dc.b		'       DOS startups by M.Meany.'
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1

_DOSBase	ds.l		1

RFfile_lock	ds.l		1
RFfile_info	ds.l		1
RFfile_name	ds.l		1
RFfile_len	ds.l		1

STD_OUT		ds.l		1

		section		Skeleton,code

***********************************************************
;		Your code starts here
;***********************************************************

Main		rts


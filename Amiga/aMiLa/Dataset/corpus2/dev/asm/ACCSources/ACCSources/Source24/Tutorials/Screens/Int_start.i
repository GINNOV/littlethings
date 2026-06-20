*****	Function	A basic Intuition startup module
*****			
*****			
*****	Size		 bytes
*****	Author		Mark Meany
*****	Date Started	May 92
*****	This Revision	May 92
*****	Notes		
*****			
*****			

; © M.Meany, May 1992.

;		incdir		"include2.0:include/"		Devpac3
		incdir		sys:include/
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		libraries/dos_lib.i
		include		libraries/dosextens.i
		include		graphics/graphics_lib.i
		include		graphics/gfx.i

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

		section		Skeleton,code

__start		move.l		a0,_args	save addr of CLI args
		move.l		d0,_argslen	and the length


		clr.l		_returnMsg

		sub.l		a1,a1
		CALLEXEC 	FindTask		find us
		move.l		d0,a4

		tst.l		pr_CLI(a4)
		beq.s		.fromWorkbench

; we were called from the CLI

		bra		.end_startup		and run the user prog

; we were called from the Workbench

.fromWorkbench	lea		pr_MsgPort(a4),a0
		CALLEXEC 	WaitPort		wait for a message
		lea		pr_MsgPort(a4),a0
		CALLEXEC 	GetMsg			then get it
		move.l		d0,_returnMsg		save for reply later

; Open Dos library and a con window

.end_startup	lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		tst.l		d0
		beq.s		.error
		
		lea		intname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_IntuitionBase
		tst.l		d0
		beq.s		.error1
		
		lea		grafname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_GfxBase
		tst.l		d0
		beq.s		.error2
		

		move.l		_args,a0
		move.l		_argslen,d0
		bsr		Main		Your routine


; returns to here

		move.l		_GfxBase,d0
		beq.s		.error2
		move.l		d0,a1
		CALLEXEC	CloseLibrary

.error2		move.l		_IntuitionBase,d0
		beq.s		.error1
		move.l		d0,a1
		CALLEXEC	CloseLibrary

.error1		move.l		_DOSBase,d0
		beq.s		.error
		move.l		d0,a1
		CALLEXEC	CloseLibrary

.error		tst.l		_returnMsg
		beq.s		.exitToDOS		if I was a CLI

		CALLEXEC 	Forbid
		move.l		_returnMsg,a1
		CALLEXEC 	ReplyMsg

.exitToDOS	moveq.l		#0,d0
		rts

	
*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************


; Subroutine that waits for the left mouse button to be pressed and then
;released before returning. Use this to pause a program while the user looks
;at screen displays etc.	

LeftMouse	btst		#6,$bfe001
		bne		LeftMouse
.loop		btst		#6,$bfe001
		beq		.loop
		rts

; Subroutine that waits for the right mouse button to be pressed and then
;released before returning. Use this to pause a program while the user looks
;at screen displays etc.	

RightMouse	btst		#2,$dff016
		bne.s		RightMouse
.Again		btst		#2,$dff016
		beq.s		.Again
		rts


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
		CALLSYS		Close		close the file

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
		CALLDOS		Open		and open file
		move.l		d0,d5		save handle
		beq		.error		quit if no file

		move.l		d0,d1		handle
		move.l		a4,d2		buffer
		move.l		d4,d3		size
		CALLSYS		Write		write data to file

		move.l		d5,d1		handle
		CALLSYS		Close		close file

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

		move.l		a0,_temp
		move.l		#0,d5

; Allocate some memory for the File Info block

		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,d6
		beq		.error1
		
; Lock the file
		
		move.l		_temp,d1
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
		CALLSYS		UnLock

; Release allocated memory

.error2		move.l		d6,a1
		move.l		#fib_SIZEOF,d0
		CALLEXEC	FreeMem

; All done so return

.error1		move.l		d5,d0
		movem.l		(sp)+,d1-d7/a0-a6
		rts

*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
grafname	dc.b		'graphics.library',0
		even

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1
_returnMsg	ds.l		1
_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

RFfile_lock	ds.l		1
RFfile_info	ds.l		1
RFfile_name	ds.l		1
RFfile_len	ds.l		1

_temp		ds.l		1

		section		Skeleton,code

***********************************************************
;		Your code starts here
;***********************************************************




*****	Title		DOS_Start.s
*****	Function	A basic DOS startup module
*****			
*****			
*****	Size		812 bytes
*****	Author		Mark Meany
*****	Date Started	Jan 92
*****	This Revision	Jan 92
*****	Notes		Contains LoadFile, SaveFile, FileLen etc...
*****			Also specific macros
*****			do da DOS


; Skeleton DOS startup code.

; Code will assemble and can be launched from WB or CLI. Opens a Console
;window if run from the WorkBench and uses this for i/o.

; A number of useful subroutines are also included. See documentation.

; Usage text is supported from the CLI.

; © M.Meany, April 1992.

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

DisplayReg	macro		<reg>
		move.l		#0,_RegString
		move.w		#'\1',_RegString
		move.l		\1,-(sp)
		bsr		_BuildString
		move.l		(sp)+,\1
		endm

DisplayMem	macro		<label>
		move.l		#'mem ',_RegString
		move.l		\1,-(sp)
		bsr		_BuildString
		move.l		(sp)+,\1
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
		
.ok		move.l		#_ConWin,d1
		move.l		#MODE_OLDFILE,d2
		CALLDOS		Open
		move.l		d0,STD_OUT

		move.l		_args,a0
		cmpi.b		#'?',(a0)	is the first arg a ?
		bne.s		.ok1		if not skip the next bit

		lea		_UsageText,a0	a0->the usage text
		bsr		DosMsg		and display it
		bsr		MousePress	wait for mouse
		bra.s		.error		and finish

.ok1		move.l		_args,a0
		move.l		_argslen,d0
		bsr		Main		Your routine


; returns to here

		lea		_MouseMsg,a0
		bsr		DosMsg
		bsr		MousePress

.error		move.l		STD_OUT,d1
		beq.s		.sk1
		CALLDOS		Close

.sk1		move.l		_DOSBase,d0
		beq.s		.sk2
		move.l		d0,a1
		CALLEXEC	CloseLibrary

.sk2		tst.l		_returnMsg
		beq.s		.exitToDOS		if I was a CLI

		CALLEXEC 	Forbid
		move.l		_returnMsg,a1
		CALLEXEC 	ReplyMsg
		rts


.exitToDOS	moveq.l		#0,d0
		moveq.l		#0,d1
		CALLDOS		Exit			kill process

		rts					just in case!

	
*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************


; Subroutine that waits for the left mouse button to be pressed and then
;released before returning. Use this to pause a program while the user looks
;at screen displays etc.	

MousePress	btst		#6,$bfe001
		bne		MousePress
.loop		btst		#6,$bfe001
		beq		.loop
		rts

;--------------
;--------------	Build text for register/memory contents and prints it
;--------------

; Entry		value on stack!

_BuildString	movem.l		d0-d3/a0-a6,-(sp)
		move.l		4*12(sp),d0
		move.l		d0,_DS1			save
		move.l		d0,_DS1+4
		bsr		_MakeBinStr
		lea		_Template,a0
		lea		_DStream,a1
		lea		_PutC,a2
		lea		_DBuff,a3
		CALLEXEC	RawDoFmt
		lea		_DBuff,a0
		bsr		DosMsg
		movem.l		(sp)+,d0-d3/a0-a6
		rts


;--------------
;--------------	Build a binary string for a long word
;--------------


; Entry		d0=longword value to convert

; Exit		_BinString contains binary string

; Corrupt	None


_MakeBinStr	movem.l		d0-d2/a0,-(sp)		save
		moveq.l		#31,d1			counter
		lea		_BinString(pc),a0	buffer

.loop		move.b		#'0',d2			default
		rol.l		#1,d0			next bit into C flag
		bcc.s		.ok			skip if bit=0
		move.b		#'1',d2

.ok		move.b		d2,(a0)+		write next char
		dbra		d1,.loop		and loop
		
		movem.l		(sp)+,d0-d2/a0		restore
							
		rts					exit

;--------------
;--------------	For RawDoFmt
;--------------

_PutC		move.b		d0,(a3)+
		rts

;--------------
;--------------	Print message
;--------------


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

;--------------
;--------------	Routine to print a BSTRING into the CLI, no EOL.
;--------------

; Entry		a0->BSTR

; Exit		none

; Corrupt	none

BPrint		movem.l		d0-d4/a0-a6,-(sp)

		moveq.l		#0,d3			clear
		move.b		(a0)+,d3		string length
		beq.s		.done			skip if NULL
		
		move.l		STD_OUT,d1		handle
		move.l		a0,d2			address
		CALLDOS		Write			print it

.done		movem.l		(sp)+,d0-d4/a0-a6
		rts

;--------------
;--------------	Print a BSTR followed by a new line
;--------------

BPrintNL	movem.l		d0-d4/a0-a6,-(sp)

		bsr		BPrint

;--------------	Print a line feed

		move.l		STD_OUT,d1
		beq.s		.error
		move.l		#_EOLbyte,d2
		moveq.l		#1,d3
		CALLDOS		Write

.error		movem.l		(sp)+,d0-d4/a0-a6
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
		dc.b		'       ACCM tutorials by M.Meany.'
		dc.b		$0a
		dc.b		0
		even

_MouseMsg	dc.b		$0a,'Press Left Mouse Button To Exit!',$0a,0
		even

_ConWin		dc.b		'con:0/0/640/200/ACCM-Example',0
		even

_Template	dc.b		'%s = %c%s,%11ld,$%08lx',$0a,0
		even

_EOLbyte	dc.b		$0a
		even

_DStream	dc.l		_RegString
		dc.w		'%'
		dc.l		_BinString
_DS1		dc.l		0
		dc.l		0

_RegString	ds.b		6
_BinString	ds.b		32
		dc.w		0		NULL terminate
_DBuff		ds.b		82

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1
_returnMsg	ds.l		1
_DOSBase	ds.l		1

RFfile_lock	ds.l		1
RFfile_info	ds.l		1
RFfile_name	ds.l		1
RFfile_len	ds.l		1

_temp		ds.l		1

STD_OUT		ds.l		1

		section		Skeleton,code

***********************************************************
;		Your code starts here
;***********************************************************





; Test the buffered file routines. Reads text from a file through a 20 byte
;buffer. Each line of text is clipped at 10 characters. These are silly values
;used to test function of routine, in practise a larger buffer would be used.

		incdir		sys:Include/
		include		exec/exec_lib.i
		include		exec/memory.i
		include		libraries/dos.i
		include		libraries/dos_lib.i

; Open dos.library

Start		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		Error

; Obtain CLI output handle

		CALLDOS		Output
		move.l		d0,std

; Call custom routine to open file for buffered reading. Specify a 20 byte
;buffer is to be used.

		lea		fname,a0
		moveq.l		#20,d0			20 byte buffer
		bsr		OpenLN
		move.l		d0,handle
		beq		AllDone

; Set EOL byte to $0a so we can use Write()

		move.l		d0,a0
		move.b		#$0a,rln_EOL(a0)

; Read a line of text from file. Text is copied into tbuffer and the maximum
;permitted line length is 10 characters, which includes the EOL byte.

ReadNext	move.l		handle,a0
		lea		tbuffer,a1
		moveq.l		#10,d0
		bsr		ReadLN
		tst.l		d0
		beq.s		Fin

; Display text read in CLI window

		move.l		std,d1
		move.l		#tbuffer,d2
		move.l		d0,d3
		CALLDOS		Write

		bra.s		ReadNext

; When no more text to read, close file and free buffers

Fin		move.l		handle,a0
		bsr		CloseLN

; Close dos.library

AllDone		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary

; Wait for LMB to be pressed

Error1		btst		#6,$bfe001
		bne.s		Error1

; exit

Error		moveq.l		#0,d0
		rts

dosname		dc.b		'dos.library',0
		even

_DOSBase	dc.l		0
std		dc.l		0

fname		dc.b		'dh0:s/acc0',0
		even

handle		ds.l		1
tbuffer		ds.b		100

*****************************************************************************
*		 Subroutines to preform buffered IO on a file.		    *
*****************************************************************************

; OpenLN	-- Open a file and allocate buffers
; ~~~~~~

; LNHandle = OpenLN( filename, buffersize )
;    d0		     	a0	  d0

; ReadNextLN	-- Copy data from file into specified buffer. Maximum length
; ~~~~~~~~~~	   of line can be specified.

; error = ReadNextLN( LNHandle, DestBuffer, MaxLen )
;   d0			a0	   a1	      d0

; CloseLN	-- Close file and releases buffers.
; ~~~~~~~

; CloseLN( LNHandle )
;	      a0

;			Considerations
;			~~~~~~~~~~~~~~
; 1. Multiple files can be accessed at any time, all data specific to a file
;    is maintained in the LNHandle structure.
; 2. dos.library must be open and it's base pointer stored in _DOSBase.
; 3. The size of buffer specified when calling OpenLN() will determine the
;    speed of ReadLN(). The larger the buffer, the faster the routine.
; 4. If OpenLN() fails to allocate the buffer you specify, it will attempt
;    to open a 1K buffer. Should this fail, a NULL pointer is returned.
; 5. By default, every line of text will be NULL terminated when copied into
;    the line buffer you specify when calling ReadLN(). If you want the lines
;    terminated with some other byte value, write it to the rln_EOL field
;    after calling OpenLN() and prior to calling ReadLN(). ie to ensure that
;    all lines are terminated with a $0a byte:

;		bsr		OpenLN
;		move.l		d0,L_handle
;		beq		.file_error

;		move.l		d0,a0
;		move.b		#$0a,rln_EOL(a0)
; 6. Lines are clipped at the length you specify when calling ReadLN(). If a
;    line exceeds the maximum length, it is split and an EOL byte is inserted
;    at the break point.

		*********************************
		*    Equates Used By Routines	*
		*********************************

RLN_EOL		equ		$0a		NULL terminate each line

		rsreset
rln_Handle	rs.l		1
rln_Buffer	rs.l		1		pointer to file buffer
rln_BufferSize	rs.l		1		Size of file buffer
rln_Cursor	rs.l		1		position in buffer
rln_Counter	rs.l		1		end of buffer
rln_EOL		rs.w		1		line terminating byte
rln_SizeOf	rs.b		0		structure size

		*****************************************
		*    Open File & Allocate buffers	*
		*****************************************

; Entry		a0->filename
;		d0=size of buffer to use, bigger the better.

; Exit		d0=pointer to custom handle structure

; Corrupt	d0

OpenLN		movem.l		d1-d7/a0-a6,-(sp)

; Make copies of parameters

		move.l		d0,d5
		move.l		a0,a4

; Allocate a handle structure

		moveq.l		#rln_SizeOf,d0		size
		move.l		#MEMF_CLEAR,d1		any old memory
		CALLEXEC	AllocMem
		move.l		d0,d7			save address
		beq		.done			exit on error

		move.l		d7,a5			a5->handle
		
; Allocate file buffer

		move.l		d5,d0
		move.l		d5,rln_BufferSize(a5)
		move.l		#MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,rln_Buffer(a5)	save pointer
		bne		.GotBuffer
	
	; Allocation failed, attempt a 1K buffer
	
		move.l		#1024,d0
		move.l		d0,rln_BufferSize(a5)
		move.l		#MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,rln_Buffer(a5)	save pointer
		bne.s		.GotBuffer
	
	; That failed as well, release handle structure and exit
	
		move.l		a5,a1
		moveq.l		#rln_SizeOf,d0
		CALLEXEC	FreeMem
		moveq.l		#0,d0			signal error
		bra		.done

; Attempt to open the file

.GotBuffer	move.l		a4,d1			filename
		move.l		#MODE_OLDFILE,d2	access mode
		CALLDOS		Open
		move.l		d0,rln_Handle(a5)	save handle
		bne.s		.FileOpen
	
	; Could not open file, release memory and exit
	
		move.l		rln_Buffer(a5),a1
		move.l		rln_BufferSize(a5),d0
		CALLEXEC	FreeMem
		
		move.l		a5,a1
		moveq.l		#rln_SizeOf,d0
		CALLEXEC	FreeMem
		
		moveq.l		#0,d7
		bra		.done

; File open and all memory allocated. Initialise buffer cursor.

.FileOpen	move.l		rln_Buffer(a5),d0
		move.l		d0,rln_Cursor(a5)
;		add.l		rln_BufferSize(a5),d0
;		move.l		d0,rln_MaxCursor(a5)

.done		move.l		d7,d0			d0->handle
		movem.l		(sp)+,d1-d7/a0-a6
		rts

		*****************************************
		*     Close File And Release Buffers	*
		*****************************************

; Entry		a0->custom handle structure

; Exit		nothing useful

; Corrupt	d0-d2,d5,a0-a2/a5/a6


CloseLN		move.l		a0,d5			exit if NULL pointer
		beq		.done

		move.l		a0,a5

; Close the file

		move.l		rln_Handle(a5),d1	handle
		CALLDOS		Close

; Release file buffer

		move.l		rln_Buffer(a5),a1	block
		move.l		rln_BufferSize(a5),d0	size
		CALLEXEC	FreeMem

; Release handle structure

		move.l		a5,a1			block
		moveq.l		#rln_SizeOf,d0		size
		CALLEXEC	FreeMem

; And exit

.done		rts


		*********************************
		*    Read Next Line Of Text	*
		*********************************

; ReadLN	-- read text from file and copy to buffer

; Entry		a0->handle structure returned by OpenLN()
;		a1->buffer to copy line of text into
;		d0=max line length ( >1 )

; Exit		d0=number of chars in line including EOL character or 0 if
;		   all text has been read.

; Corrupt	d0

ReadLN		movem.l		d1-d7/a0-a6,-(sp)

		moveq.l		#0,d7			clear char counter

; Copy entry parameters

		move.l		a0,a5
		subq.l		#1,d0			allow for clipping
		move.l		d0,d6
		move.l		a1,a4
		
; See if file buffer contains data

		move.l		rln_Counter(a5),d5	get num chars in buf
		bne.s		.GotData		skip if not empty

	; No data in file, read in next buffer load
	
.ReadFile	move.l		rln_Handle(a5),d1	handle
		move.l		rln_Buffer(a5),d2	buffer
		move.l		rln_BufferSize(a5),d3	number of bytes
		CALLDOS		Read
		move.l		d0,d5
		beq		.done

		move.l		rln_Buffer(a5),rln_Cursor(a5)
		move.l		d0,rln_Counter(a5)

; Buffer contains data, start copying into dest buffer

.GotData	move.l		rln_Cursor(a5),a3	a3->next char

.CharLoop	tst.l		rln_Counter(a5)		check data in buffer
		beq.s		.ReadFile		read more if not

		subq.l		#1,rln_Counter(a5)	dec buffer counter

		addq.l		#1,d7			bump chars copied
		move.b		(a3)+,d0
		cmp.b		#$0a,d0			EOL ???
		beq.		.AtEOL			yep, return the line
		move.b		d0,(a4)+		else copy char
		cmp.b		d7,d6			max length reached?
		bgt.s		.CharLoop		no, keep going!

		addq.l		#1,d7			include new LF

.AtEOL		move.b		rln_EOL(a5),(a4)	terminate line
		move.l		a3,rln_Cursor(a5)

.done		move.l		d7,d0			return len of line
		movem.l		(sp)+,d1-d7/a0-a6	restore other regs
		rts


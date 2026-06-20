
;--------------
;--------------	read in and accomodate a data file
;--------------

*entry		a0->filename

*exit		d0=0 if something has gone horribly wrong ... exit if d0=0

*corrupt	a0-a2/a4, d0-d2 ( as far as I'm aware! )

; note, this routine frees memory used for any file currently in memory and
;so it is NOT safe to continue if a new file fails to load!

LoadData	

		move.l		a0,a4		save filename pointer

; release memory for current file

		tst.l		StructDataLen(a5)	file loaded?
		bne.s		.Fresh			skip if not

		move.l		StructData(a5),a1	address
		move.l		StructDataLen(a5),d0	size
		CALLEXEC	FreeMem			release it

; and current line list

		move.l		LineList(a5),a1
		move.l		LineLen(a5),d0
		CALLEXEC	FreeMem
		move.l		#0,LineList(a5)		signal change

; Now load new file

.Fresh		move.l		a4,a0			filename
		moveq.l		#0,d0			any mem type
		bsr		LoadFile		load it
		tst.l		d0			all ok?
		beq.s		.error			skip if not

		move.l		a0,StructData(a5)	address
		move.l		d0,StructDataLen(a5)	size

; And build LineList

		bsr		BuildList		build line list
		move.l		d0,LineList(a5)		save address
		beq		.error1			quit if error
		move.l		d1,LineLen(a5)		save length

; all done, so exit

.error		rts

; if we get here memory is very short! Exit fast.

.error1		move.l		StructData(a5),a1	address
		move.l		StructDataLen(a5),d0	size
		CALLEXEC	FreeMem			release it

		moveq.l		#0,d0			signal error
		rts					and exit
		



****************

; Subroutine that loads a file into a block of memory.

; Entry		a0-> filename
;		d0=  type of memory ( either CHIPMEM, FASTMEM or PUBLICMEM )

; Exit		d0= length of buffer allocated or NULL if error
;		a0->buffer

; Corrupt	d0,a0

LoadFile	movem.l		d1/d5-d7/a4/a5,-(sp)

		move.l		d0,d1		save requirements
		move.l		a0,a4		save filename pointer

		bsr		FileLen		obtain thhe size of the file

		move.l		d0,d5		save file size
		beq.s		.error		quit if zero

;--------------	Filesize determined so allocate a buffer. NB d1= requirements.

		CALLEXEC	AllocMem	get buffer
		move.l		d0,d7		save pointer
		tst.l		d0		all ok?
		bne.s		.cont		if so skip next bit

		moveq.l		#0,d5		set error
		bra		.error		and quit

.cont		move.l		a4,d1		d1->filename
		move.l		#MODE_OLDFILE,d2 access mode
		CALLDOS		Open		open the file
		move.l		d0,d6		save handle
		bne		.cont1		quit if error

		move.l		d7,a1		buffer
		move.l		d5,d1		length
		CALLEXEC	FreeMem		and release it
		moveq.l		#0,d5		set error
		bra		.error		and quit

.cont1		move.l		d0,d1		handle
		move.l		d7,d2		buffer
		move.l		d5,d3		file length
		CALLDOS		Read		and load the file

		move.l		d6,d1		handle
		CALLDOS		Close		close the file

		move.l		d7,a0		a0->buffer
.error		move.l		d5,d0		d0=return value
		movem.l		(sp)+,d1/d5-d7/a4/a5
		rts


***************	Subroutine that returns the length of a file in bytes.

; Entry		a0 = address of file name

; Exit		d0 = length of file in bytes or 0 if any error occurred

; Corrupted	a0

;-------------- Save register values

FileLen		movem.l		d1-d4/a1-a4,-(sp)

;-------------- Save address of filename and clear file length

		move.l		a0,RFfile_name(a5)
		move.l		#0,RFfile_len(a5)

;-------------- Allocate some memory for the File Info block

		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,RFfile_info(a5)
		beq		.error1
		
;-------------- Lock the file
		
		move.l		RFfile_name(a5),d1
		move.l		#ACCESS_READ,d2
		CALLDOS		Lock
		move.l		d0,RFfile_lock(a5)
		beq		.error2

;-------------- Use Examine to load the File Info block

		move.l		d0,d1
		move.l		RFfile_info(a5),d2
		CALLSYS		Examine

;-------------- Copy the length of the file into RFfile_len

		move.l		RFfile_info(a5),a0
		move.l		fib_Size(a0),RFfile_len(a5)

;-------------- Release the file

		move.l		RFfile_lock(a5),d1
		CALLSYS		UnLock

;-------------- Release allocated memory

.error2		move.l		RFfile_info(a5),a1
		move.l		#fib_SIZEOF,d0
		CALLEXEC	FreeMem

;--------------	All done so return

.error1		move.l		RFfile_len(a5),d0
		movem.l		(sp)+,d1-d4/a1-a4
		rts
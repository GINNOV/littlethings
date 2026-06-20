
; A very crude patch that revectors dos.library Open() routine to a custom
;version that will attempt to make powerpacked files available to the caller
;without the need for caller to know the file it is reading is crunched.

; Works by decrunching the file to a temporary file in ram: ( that is not
;deleted, this would require a patch on Close() as well ). The application
;gets the handle of this temporary file.

; Biggest set back is that attempting to read more than one crunched file
;has weird and wonderful effects. It will also become impossible to write
;over a crunched file without calling Delete() first. Oh well, it was worth
;a try:-) M.Meany

; To stop the patch send a break to the CLI from where it was started or
;press CTRL-C. MM.

; The routine to load a crunched file into a buffer could be ripped from this
;source and used as an alternative to powerpacker.library for loading crunched
;files:-) This source was supplied with an early version, PD, of PowerPacker
;but seems to work ok with with files crunched using newer versions.

; Open DOS

		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/memory.i
		include		libraries/dos_lib.i
		include		libraries/dosextens.i

Start		move.l		#DefaultName,_SFPPname	default file name
		move.b		#0,-1(a0,d0)		terminate CLI params
		
		tst.b		(a0)			were there any?
		beq.s		.DoPatch		no, so skip
		
		move.l		a0,_SFPPname

.DoPatch	lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		Error

; Cannot use SetFunction() on dos.library. Must replace vector, signal library
;changed and call SumLibrary(). 

; Stop multitasking

		CALLEXEC	Forbid

; Replace Open() vector with a vector to new routine

		move.l		_DOSBase,a1
		lea		_LVOOpen(a1),a4
		addq.l		#2,a4
		move.l		(a4),Vector+2
		move.l		#NewFunction,(a4)

; Signal that library has been changed to prevent a Guru tea break:-)

		or.b		#LIBF_CHANGED,LIB_FLAGS(a1)	signal

; Recalculate libraries checksum

		CALLEXEC	SumLibrary

; Multi tasking back on

		CALLEXEC	Permit

; Wait for user to press CTRL-C (( run from CLI only ))

waiting		move.l		#$1000,d0		CTRL-C
		CALLEXEC	Wait			wait for an event
		
		
		btst		#12,d0			test for CTRL-C
		beq.s		waiting			loop back if not

; Stop multitasking

		CALLEXEC	Forbid

; Replace systems vector

		move.l		_DOSBase,a1
		lea		_LVOOpen(a1),a4
		addq.l		#2,a4
		move.l		Vector+2,(a4)

; Again signal library has been changed

		or.b		#LIBF_CHANGED,LIB_FLAGS(a1)	signal

; Recalculate checksum

		CALLEXEC	SumLibrary

; multi tasking back on

		CALLEXEC	Permit

; And exit.

Error		moveq.l		#0,d0
		rts

dosname		DOSNAME
_DOSBase	dc.l		0

DefaultName	dc.b		'ram:Sara',0
		even

*****************************************************************************

; Subroutine that will open a file and see if it is a powerpacked data file.
;If it is, file is decrunched to ram: as ram:temp and handle to this file is
;returned, else handle of the file is returned!

; Entry		d1->filename
;		d2=MODE_OLDFILE

; Exit		d0=handle of a file or NULL if an error occurred!

NewOpen		movem.l		d2-d7/a2-a6,-(sp)

		bsr		Vector
		move.l		d0,d7			save handle
		beq		.error

; read 4 bytes from the file

		move.l		#0,-(sp)		space on stack
		move.l		d0,d1			handle
		move.l		sp,d2			buffer
		moveq.l		#4,d3			1 long word
		CALLDOS		Read			read long word

; See if a powerpacked data file, exit if not!

		move.l		(sp)+,d0		get ID
		cmp.l		#'PP20',d0		powerpacked?
		bne		.done			no, skip this bit

; Is packed, decrunch it.

		move.l		d7,d1			handle
		moveq.l		#0,d2			memory required
		bsr		LoadCrunch
		move.l		a0,a5			save buffer ptr
		move.l		d0,d5			and size
		bne.s		.copyfile		skip if OK.

	; could not decrunch, do error exit!

		move.l		d7,d1			handle
		CALLDOS		Close			close file
		moveq.l		#0,d7			signal error
		bra		.error			and exit

; Create ram:Temp or whatever, containing crunched data

.copyfile	move.l		d7,d1			original file
		CALLDOS		Close			close it
		moveq.l		#0,d7			clear handle

		move.l		_SFPPname,d1		name
		move.l		#MODE_NEWFILE,d2	access mode
		bsr		Vector			open temp file
		move.l		d0,d7			save handle
		bne.s		.StartWriting		skip if valid
	
	; Could not open copy, free memory and exit
	
		move.l		a5,a1			buffer
		move.l		d5,d0			size
		CALLEXEC	FreeMem			release it
		bra		.error
	
; Write buffer into file

.StartWriting	move.l		d7,d1			handle
		move.l		a5,d2			buffer
		move.l		d5,d3			size
		CALLDOS		Write			write the data

; now free buffer memory

		move.l		a5,a1			buffer
		move.l		d5,d0			size
		CALLEXEC	FreeMem			release it
		
; Reset file cursor to start of file.

.done		move.l		d7,d1			handle
		moveq.l		#0,d2			distance
		moveq.l		#-1,d3			OFFSET_BEGINNING
		CALLDOS		Seek

.error		move.l		d7,d0			handle into d0
		movem.l		(sp)+,d2-d7/a2-a6
		rts					and exit

_SFPPname	dc.l		0

*****************************************************************************

; Subroutine to load a crunched data file and decrunch it, returning a buffer
;containing decrunched data. Calling routine must free the buffer when it has
;finished with it!

; Entry		d1->filename handle of open file
;		d2=memory requirements

;		dos.library is open.

; Exit		d0=size of buffer allocated or NULL on error
;		a0->buffer

; Corrupt	d0-d1/a0-a1

LoadCrunch	movem.l		d2-d7/a2-a6,-(sp)

		move.l		d1,d5			handle
		move.l		d2,d6			mem type
		moveq.l		#0,d7			length of buffer
		
; Determine length of decrunched file

		moveq.l		#-4,d2
		moveq.l		#1,d3			OFFSET_END
		CALLDOS		Seek

		move.l		#0,-(sp)		make room on stack
		move.l		d5,d1			handle
		move.l		sp,d2			buffer
		moveq.l		#4,d3			1 long word
		CALLDOS		Read			get decrunch info
		
		move.l		(sp)+,d0		
		asr.l		#8,d0			correct
		move.l		d0,d4			will be file length

; Allocate buffer for the file

		move.l		d6,d1			requirements
		add.l		#64,d0			safety margin!
		CALLEXEC	AllocMem		get buffer
		move.l		d0,d6			save buffer address
		beq		.Error			exit if not one

		move.l		d4,d7			size of buffer

; Move file cursor to start of file and read data into buffer

		move.l		d5,d1			handle
		moveq.l		#0,d2
		moveq.l		#-1,d3			OFFSET_BEGINNING
		CALLDOS		Seek

		move.l		d5,d1			handle
		move.l		d6,d2			buffer
		move.l		d7,d3			size of buffer
		CALLDOS		Read			get crunched data

; Decrunch the data

		move.l		d0,a0			bytes read
		add.l		d6,a0			into buffer
		move.l		d6,a1			address at which
		move.l		4(a1),d0		( efficiency )
		lea		64(a1),a1		to decrunch to
		bsr		PPDecrunch		decrunch it
		
; Free the 64 byte safety margin at the start of the file.

		move.l		d6,a1			buffer
		moveq.l		#64,d0			size
		CALLEXEC	FreeMem			release it

; Correct address of buffer ready for return.

		add.l		#64,d6			bump pointer

.Error		move.l		d6,a0			buffer
		move.l		d7,d0			length
		movem.l		(sp)+,d2-d7/a2-a6
		rts

;
; PowerPacker Decrunch assembler subroutine V1.1
;
; NOTE:
;    Decrunch a few bytes higher (safety margin) than the crunched file
;    to decrunch in the same memory space. (64 bytes suffice)
;

* Entry	a0->End of crunched data + 1
*	a1->Start of decrunch block
*	d0=efficiency file was crunched with.

PPDecrunch
	movem.l d1-d7/a2-a6,-(a7)
	bsr.s Decrunch
	movem.l (a7)+,d1-d7/a2-a6
	rts

Decrunch:
	lea myBitsTable(PC),a5
	move.l d0,(a5)
	move.l a1,a2
	move.l -(a0),d5
	moveq #0,d1
	move.b d5,d1
	lsr.l #8,d5
	add.l d5,a1
	move.l -(a0),d5
	lsr.l d1,d5
	move.b #32,d7
	sub.b d1,d7
LoopCheckCrunch:
	bsr.s ReadBit
	tst.b d1
	bne.s CrunchedBytes
NormalBytes:
	moveq #0,d2
Read2BitsRow:
	moveq #2,d0
	bsr.s ReadD1
	add.w d1,d2
	cmp.w #3,d1
	beq.s Read2BitsRow
ReadNormalByte:
	move.w #8,d0
	bsr.s ReadD1
	move.b d1,-(a1)
	dbf d2,ReadNormalByte
	cmp.l a1,a2
	bcs.s CrunchedBytes
	rts
CrunchedBytes:
	moveq #2,d0
	bsr.s ReadD1
	moveq #0,d0
	move.b (a5,d1.w),d0
	move.l d0,d4
	move.w d1,d2
	addq.w #1,d2
	cmp.w #4,d2
	bne.s ReadOffset
	bsr.s ReadBit
	move.l d4,d0
	tst.b d1
	bne.s LongBlockOffset
	moveq #7,d0
LongBlockOffset:
	bsr.s ReadD1
	move.w d1,d3
Read3BitsRow:
	moveq #3,d0
	bsr.s ReadD1
	add.w d1,d2
	cmp.w #7,d1
	beq.s Read3BitsRow
	bra.s DecrunchBlock
ReadOffset:
	bsr.s ReadD1
	move.w d1,d3
DecrunchBlock:
	move.b (a1,d3.w),d0
	move.b d0,-(a1)
	dbf d2,DecrunchBlock
EndOfLoop:
_pp_DecrunchColor:
	move.w a1,$dff1a2
	cmp.l a1,a2
	bcs.s LoopCheckCrunch
	rts
ReadBit:
	moveq #1,d0
ReadD1:
	moveq #0,d1
	subq.w #1,d0
ReadBits:
	lsr.l #1,d5
	roxl.l #1,d1
	subq.b #1,d7
	bne.s No32Read
	move.b #32,d7
	move.l -(a0),d5
No32Read:
	dbf d0,ReadBits
	rts
myBitsTable:
	dc.b $09,$0a,$0b,$0b

_pp_CalcCheckSum:
	move.l 4(a7),a0
	moveq #0,d0
	moveq #0,d1
sumloop:
	move.b (a0)+,d1
	beq.s exitasm
	ror.w d1,d0
	add.w d1,d0
	bra.s sumloop
_pp_CalcPasskey:
	move.l 4(a7),a0
	moveq #0,d0
	moveq #0,d1
keyloop:
	move.b (a0)+,d1
	beq.s exitasm
	rol.l #1,d0
	add.l d1,d0
	swap d0
	bra.s keyloop
exitasm:
	rts
_pp_Decrypt:
	move.l 4(a7),a0
	move.l 8(a7),d1
	move.l 12(a7),d0
	move.l d2,-(a7)
	addq.l #3,d1
	lsr.l #2,d1
	subq.l #1,d1
encryptloop:
	move.l (a0),d2
	eor.l d0,d2
	move.l d2,(a0)+
	dbf d1,encryptloop
	move.l (a7)+,d2
	rts

*****************************************************************************

NewFunction	move.l		#MODE_NEWFILE,d0	trap this mode
		and.l		d2,d0			got one?
		beq.s		Vector			no, call open!

; A MODE_OLDFILE has been requested, do the dirty deed ----

		bsr		NewOpen			open the file
		rts					and return

; Tut-Tut, relocatable code. I've kept it some distance from the modifier
;though.

Vector		jsr		$fffffff0
		
		rts


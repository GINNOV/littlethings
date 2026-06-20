

; This program displays all the chunks in an IFF file along with their size.
;There is a slight bug that causes the last chunk to be repeated sometimes,
;sorry! This was written so that I could look at DPaint files, but figured
;it may be of use to someone else.

		opt ow-

		incdir		source:include/
		include		marks/MM_Macros.i

		
; Entry		name of a file as cli parameter

Start		move.b		#0,-1(a0,d0)		null terminate
		move.l		a0,filename
		
		OPENDOS

		move.l		filename,d1		filename
		move.l		#MODE_OLDFILE,d2	access mode
		CALLDOS		Open			open it
		move.l		d0,File_Handle		save handle
		beq.s		.Error
		
		move.l		File_Handle,d1		file
		move.l		#Form,d2		buffer
		moveq.l		#4,d3			1 long
		CALLDOS		Read			get Id & Size
		
		cmpi.l		#'FORM',Form		IFF file ?
		bne.s		.Error1			no, exit
		
		move.l		File_Handle,d1		file
		move.l		#ThisChunkSize,d2	buffer
		moveq.l		#4,d3			1 long
		CALLDOS		Read			get file Size

		move.l		File_Handle,d1		file
		move.l		#ThisChunkID,d2		buffer
		moveq.l		#4,d3			1 long
		CALLDOS		Read			get IFF ID
		
.Loop		bsr		DisplayChunk
		
		bsr		LocateNext
		tst.l		d0
		bne.s		.Loop

.Error1		move.l		File_Handle,d1		file
		CALLDOS		Close			close it		

.Error		CLEANUP



*****	Locate start of next chunk

; Entry		None

; Exit		d0=0 when end of file reached.

LocateNext	move.l		File_Handle,d1		file
		move.l		ThisChunkSize,d2	distance
		move.l		#OFFSET_CURRENT,d3	from here
		CALLDOS		Seek			move to it
		
		move.l		File_Handle,d1		file
		move.l		#ThisChunkID,d2		buffer
		moveq.l		#8,d3			2 longs
		CALLDOS		Read			get Id & Size

		rts

*****	Display chunk details

DisplayChunk	PUTSTR		#msg4
		
		move.l		MM_std_out,d1
		move.l		#ThisChunkID,d2
		moveq.l		#4,d3
		CALLDOS		Write
				
		PUTSTR		#msg5

		lea		Template,a0		C format string
		lea		ThisChunkSize,a1	data stream
		lea		PutChar,a2		subroutine
		lea		TextBuffer,a3		buffer
		CALLEXEC	RawDoFmt		build text
		
		PUTSTR		#TextBuffer		print text

		rts

		include		marks/MM_subs.i


PutChar		move.b		d0,(a3)+
		rts

filename	dc.l		0
Form		dc.l		0
File_Handle	dc.l		0
FileSize	dc.l		0
ThisChunkID	dc.l		0
ThisChunkSize	dc.l		0

TextBuffer	ds.l		100

Template	dc.b		'Chunk Size: %ld bytes.',$0a,$0a,0
		even

; Messages displayed by the program.

msg1		dc.b		'Attempting to open file: ',0
		even
msg2		dc.b		'File failed to open...Aborting!',$0a,0
		even
msg3		dc.b		'Not an IFF File...Aborting!',$0a,0
		even
msg4		dc.b		'Chunk Name: ',0
		even
msg5		dc.b		' .',$0a,0
		even
msg6		dc.b		'Chunk Size: xxxxxxx bytes',$0a,0
		even



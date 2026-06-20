
*******	Subroutine to print data from memory as dc.w statements to a file

; Entry		a0->Start of data
;		d0=number of words to save
;		std_out=file handle to save to

; Exit		same

; Corrupt	none

DataPrint	movem.l		d0-d7/a0-a6,-(sp)

		move.l		a0,a5
		move.l		d0,d5

.Loop		cmp.l		#8,d5
		blt		.LastLine
		
		lea		.Temp,a0		template
		move.l		a5,a1			data stream
		lea		.PutC,a2		PutChar routine
		lea		.Buffer,a3		buffer
		CALLEXEC	RawDoFmt		generate Text
		
		lea		.Buffer,a0		a0->text
		bsr		DOSPrint		print it to file

		addq.l		#8,a5			bump pointer
		addq.l		#8,a5
		subq.l		#8,d5			dec counter
		beq		.AllDone		exit if no data left
		bra		.Loop			else loop

.LastLine	move.l		d5,d0
		subq.w		#1,d0
		mulu		#6,d0
		add.w		#11,d0
		lea		.Temp,a4
		add.l		d0,a4
		move.b		#$0a,(a4)
		move.b		#0,1(a4)
		
		lea		.Temp,a0		template
		move.l		a5,a1			data stream
		lea		.PutC,a2		PutChar routine
		lea		.Buffer,a3		buffer
		CALLEXEC	RawDoFmt		generate Text
		
		lea		.Buffer,a0		a0->text
		bsr		DOSPrint		print it to file
		
		move.b		#',',(a4)		restore
		move.b		#'$',1(a4)		template
		
.AllDone	movem.l		(sp)+,d0-d7/a0-a6
		rts

.PutC		move.b		d0,(a3)+
		rts

.Temp	dc.b	$09,'dc.w',$09
	dc.b	'$%04x,$%04x,$%04x,$%04x,$%04x,$%04x,$%04x,$%04x',$0a,0
	even

.Buffer dc.b	' dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00',0
	 even

	

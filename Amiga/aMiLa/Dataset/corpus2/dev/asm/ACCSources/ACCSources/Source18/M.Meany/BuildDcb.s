
; Routine that builds data statements of the form:

;		dc.w		$xxxx,$xxxx,$xxxx

; Eight word values will be saved on each line! The lines are output to an
;open device, ie disc or printer.

;Entry		a0->start of memory address to convert to dc.b's.
;		d0= number of bytes to convert.
;		d1= handle of open file.

BuildDCB	movem.l		d0-d7/a0-a6,-(sp)

		move.l		d1,d6		save file handle
		move.l		a0,a4		save data pointer

		move.l		d0,d7		copy of num bytes
		addq.l		#1,d7		round up to next even val
		asr.l		#1,d7		div by 2 for word values

		divu		#8,d7		get div and mod
		subq.w		#1,d7		adjust div for dbra
		bmi		.do_last	skip line builder if no lines

.loop		moveq.l		#7,d2		d2= word count - 1
		lea		dstream,a1	a1->DataStream buffer
.loop1		move.w		(a4)+,(a1)+	copy next word
		dbra		d2,.loop1	'till all 8 are copied

		lea		Tm0,a0		a0->Template
		lea		dstream,a1	a1->data stream
		lea		PutChar1,a2	a2->subroutine
		lea		lbuf,a3		a3->line buffer

		CALLEXEC	RawDoFmt	build the line
		
		move.l		d6,d1		d1=handle
		move.l		#lbuf,d2	d2=addr of buffer
		move.l		#lbuf_size,d3	d3=number of bytes
		CALLDOS		Write		and write the line

		dbra		d7,.loop	for all lines

.do_last	swap		d7		d7.w = mod value
		subq.w		#1,d7		adjust for dbra
		bmi		.error		quit if no bytes
		move.l		d7,d2		get working copy

		lea		dstream,a1	a1->DataStream buffer
.loop2		move.w		(a4)+,(a1)+	copy next word
		dbra		d2,.loop2	'till all 8 are copied

		lea		TmTab,a0	a0->Template table
		asl.w		#2,d7		x4, 4 bytes per address
		move.l		0(a0,d7),a0	a0->template

		lea		dstream,a1	a1->data stream
		lea		PutChar2,a2	a2->subroutine
		lea		lbuf,a3		a3->line buffer

		move.l		#0,lcount	clear counter

		CALLEXEC	RawDoFmt	build the line
		
		move.l		d6,d1		d1=handle
		move.l		#lbuf,d2	d2=addr of buffer
		move.l		lcount,d3	d3=number of bytes
		CALLDOS		Write		and write the line

.error		movem.l		(sp)+,d0-d7/a0-a6
		rts

PutChar1	move.b		d0,(a3)+
		rts

PutChar2	move.b		d0,(a3)+
		addq.l		#1,lcount
		rts


TmTab		dc.l		Tm1
		dc.l		Tm2
		dc.l		Tm3
		dc.l		Tm4
		dc.l		Tm5
		dc.l		Tm6
		dc.l		Tm7


Tm0		dc.b		$09,$09,'dc.w',$09,'$%04x,$%04x,$%04x,$%04x,$%04x,$%04x,$%04x,$%04x',$0a,0
		even
Tm1		dc.b		$09,$09,'dc.w',$09,'$%04x',$0a,0
		even
Tm2		dc.b		$09,$09,'dc.w',$09,'$%04x,$%04x',$0a,0
		even
Tm3		dc.b		$09,$09,'dc.w',$09,'$%04x,$%04x,$%04x',$0a,0
		even
Tm4		dc.b		$09,$09,'dc.w',$09,'$%04x,$%04x,$%04x,$%04x',$0a,0
		even
Tm5		dc.b		$09,$09,'dc.w',$09,'$%04x,$%04x,$%04x,$%04x,$%04x',$0a,0
		even
Tm6		dc.b		$09,$09,'dc.w',$09,'$%04x,$%04x,$%04x,$%04x,$%04x,$%04x',$0a,0
		even
Tm7		dc.b		$09,$09,'dc.w',$09,'$%04x,$%04x,$%04x,$%04x,$%04x,$%04x,$%04x',$0a,0
		even

lbuf		dc.b		$09,$09,'dc.w',$09,'$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000',$0a,0
lbuf_size	equ		*-lbuf
		even

lcount		dc.l		1
dstream		ds.w		9

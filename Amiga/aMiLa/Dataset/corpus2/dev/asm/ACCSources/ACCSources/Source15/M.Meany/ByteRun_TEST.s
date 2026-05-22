
; ByteRun algorithm. For ArtWerx by M.Meany, July 1991.


Start		lea		Data,a0
		move.l		#DSize,d0
		lea		Buffer,a1
		bsr		Crunch

		lea		Buffer,a0
		lea		-4(a0),a0
		lea		Buffer1,a1
		bsr		DeCrunch


		rts

Data		dc.b		0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,55,4,4,3,3,2,2,1,1
		dcb.b		300,$0a
DSize		equ		*-Data
		even

Buffer		ds.b		500

Buffer1		ds.b		500



; This subroutine will attempt to crunch an area of memory using the IFF
;byterun method. If the crunched size exceeds the original size, the routine
;aborts.


; Entry		a0-> Data to be crunched
;		d0=size of data to crunch
;		a1-> Buffer to store crunched data at (2 bytes more than d0)

; Exit		d0=size of crunched file or 0 if failure

Crunch		move.l		d0,d7		save a copy
		subq.l		#1,d0		adjust for dbra
		moveq.l		#0,d1		clear counter

.loop		moveq.l		#1,d2		byte counter
		move.b		(a0)+,d3	get a byte
.inner		cmp.b		(a0)+,d3	compare with next byte
		bne.s		.write		if different save byte/count
		addq.b		#1,d2		bump count
		bcc		.ok		if < 255 keep going
		move.l		#255,d2		step back
		bra		.write		and save byte/count

.ok		dbra		d0,.inner	loop back if not finished
		bra		.done		else finish up

.write		lea		-1(a0),a0	step back a byte
		move.b		d3,(a1)+	save byte
		move.b		d2,(a1)+	save count
		addq.l		#2,d1		bump crunched length
		cmp.l		d7,d1		crunched>original ?
		bgt		.abort		if so abort!
		dbra		d0,.loop	else loop back
		move.l		d1,d0		d0=crunched size
		rts				and finish

.done		move.b		d3,(a1)+	save byte
		move.b		d2,(a1)+	save count
		addq.l		#2,d1		bump crunched length
		move.l		d1,d0		d0=crunched size
		rts				and finish

.abort		moveq.l		#0,d0		signal error
		rts				and finish



; ByteRun decrunch algorithm. For ArtWerk by M.Meany, July 1991.

; The 1st long word of a crunched data block is the length of the block
;when decrunched. It is up to you to allocate memory for the decrunched
;data. This is not a problem if you have crunched a series of graphics
;that all fit into the same size display as only one block need be obtained.

; Entry		a0->Crunched Data
;		a1->Memory to decrunch into

DeCrunch	lea		4(a0),a0	a0->data

.outer		tst.w		(a0)		end of crunched data ?
		beq		.done		if so quit

		move.b		(a0)+,d0	get value

;		move.w		d0,$dff180	change color0 
		moveq.l		#0,d1		clear counter
		move.b		(a0)+,d1	and count
		subq.l		#1,d1		adjust for dbra

.inner		move.b		d0,(a1)+	copy next byte
		dbra		d1,.inner	count times

		bra		.outer		go back for more

.done		rts				all decrunched


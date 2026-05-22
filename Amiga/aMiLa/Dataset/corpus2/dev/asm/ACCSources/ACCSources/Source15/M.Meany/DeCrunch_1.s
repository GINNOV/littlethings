		lea	gfx,a0

		bsr	DeCrunch
		tst.l	d0
		beq.s	quit

		move.l	a0,a1		a1->mem
		move.l	$4.w,a6		SysBase
		jsr	-$00d2(a6)	FreeMem
quit		rts


; ByteRun decrunch algorithm. For ArtWerk by M.Meany, July 1991.

; This version of the decrunch routine will allocate memory ( CHIP ) for
;the decrunched program using AllocMem(). It is up to you to release this
;when your program has finished with the decrunched data!

; Always test register d0 after calling this subroutine. If it is 0 then
;memory could not be allocated for the decrunched data and your program
;should act accordingly.

; Entry		a0->Crunched Data

; Exit		a0->DeCrunched Data
;		d0=Size Of DeCrunched Data or 0 if a memory allocation error
;		   occured.
;		a1->Original Crunched Data

DeCrunch	move.l		a0,-(sp)	save it

		move.l		(a0)+,d0	d0=size of decrunched data
		move.l		d0,-(sp)	save it
		move.l		#$2,d1		get CHIP memory
		move.l		$4.w,a6		SysBase
		jsr		-$00c6(a6)	AllocMem
		move.l		d0,-(sp)	save it
		beq		.done		quit if error

		move.l		8(sp),a0	get addr of crunched data
		lea		4(a0),a0	point after length
		move.l		d0,a1		a1->decrunch buffer

.outer		tst.w		(a0)		end of crunched data ?
		beq		.done		if so quit

		move.b		(a0)+,d0	get value

; Remove the semi-colon from the following line for pp efx.

;		move.w		d0,$dff180	change color0 

		moveq.l		#0,d1		clear 
		move.b		(a0)+,d1	get count
		subq.l		#1,d1		adjust for dbra

.inner		move.b		d0,(a1)+	copy next byte
		dbra		d1,.inner	count times

		bra		.outer		go back for more

.done		move.l		(sp)+,a0	addr of decrunched data
		move.l		(sp)+,d0	size of decrunched data
		move.l		(sp)+,a1	addr of crunched data
		cmp.l		#0,a0		got buffer?
		bne.s		.ok		if so jump next line
		moveq.l		#0,d0		set d0=0 for error
.ok		rts				all decrunched


gfx		incbin		source:bitmaps/crunched_level1.gfx


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

; Remove the semi-colon from the following line for pp efx.

;		move.w		d0,$dff180	change color0 

		moveq.l		#0,d1		clear 
		move.b		(a0)+,d1	get count
		subq.l		#1,d1		adjust for dbra

.inner		move.b		d0,(a1)+	copy next byte
		dbra		d1,.inner	count times

		bra		.outer		go back for more

.done		rts				all decrunched

	
;--------------	Compare two words.

; Assumes each word is followed by some terminating byte that is ignored.
; Terminating byte should be counted in the strings length.

; Entry a0->start of first word
;	a1->start of second word
;	d0= length of first word
;	d1= length of second word

; Exit	d0=0 if words the same
;	d0=1 if first word < second word
;	d0=2 if first word > second word

; corrupted d0,d1,a0,a1

compare_words	move.l		d2,-(sp)
		moveq.l		#0,d2
		cmp.l		d0,d1
		beq.s		.ok
		blt.s		.ok1
		moveq.l		#1,d2
		bra.s		.ok
.ok1		moveq.l		#2,d2
		move.l		d1,d0
.ok		subq.l		#2,d0
.loop		cmp.b		(a0)+,(a1)+
		dbne		d0,.loop
		bgt.s		.first
		blt.s		.second
		move.l		d2,d0
		bra.s		.done
		
.first		moveq.l		#1,d0
		bra.s		.done
		
.second		moveq.l		#2,d0

.done		move.l		(sp)+,d2
		rts


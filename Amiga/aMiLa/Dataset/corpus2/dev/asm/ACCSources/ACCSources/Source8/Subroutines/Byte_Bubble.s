
;--------------	Acending sort routine. Sorts a list of bytes.

; Entry		a0->start of null or $0A terminated list

; Corrupted	a0,d0,d1

bubble		moveq.l		#0,d1

		tst.b		(a0)
		beq.s		.error

		move.l		a0,-(sp)

.loop		tst.b		1(a0)
		beq.s		.done
		cmpi.b		#$0a,1(a0)
		beq.s		.done
		
		move.b		(a0)+,d0
		cmp.b		(a0),d0
		ble.s		.ok
		move.l		#1,d1
		move.b		(a0),-1(a0)
		move.b		d0,(a0)
		
.ok		bra		.loop

.done		move.l		(sp)+,a0
		tst.l		d1
		bne.s		bubble
		
.error		rts


start
		moveq	#0,d0
.lp
		lea	table,a0
		move.w	(a0,d0),$dff180
		addq.w	#2,d0
		cmp.w	#20,d0
		bne.s	.lp
		clr.w	d0
		bra.s	.lp

table
		dc.w	$f00,$700,$000,$070,$00f,$07f,$0ff,$7ff,$fff,$ff0



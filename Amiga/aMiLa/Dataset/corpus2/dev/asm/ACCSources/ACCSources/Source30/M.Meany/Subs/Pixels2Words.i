

;pixel width (d0) to word width (d1)

		moveq.l		#0,d1
		ror.l		#4,d0
		move.w		d0,d1
		swap		d0
		tst.w		d0
		beq.s		.Multiple
		addq.w		#1,d1
.Multiple
	


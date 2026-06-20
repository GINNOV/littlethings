; MoveMouse ; SK 16 Feb 91

		clr.l		d6
		clr.l		d7
		move.b		$dff00b,d6
		move.b		d6,d7
loop		cmp.b		d6,d7
		bne.s		endit
		move.b		d6,d7
		move.b		$dff00b,d6
		bra.s		loop
endit		rts


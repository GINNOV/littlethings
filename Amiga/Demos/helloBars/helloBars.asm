	clr.w	d0
loop:
	addq.w	#1,d0
	move.w	d0,$dff180	; flash screen
	cmp.w	#$fff,d0
	bne	loop
	clr.w	d0
	bra 	loop	
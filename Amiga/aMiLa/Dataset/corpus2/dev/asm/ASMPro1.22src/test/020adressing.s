;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
	jsr ([label,d0.l*2])
	jsr ([label,d0.l*4])
	jsr ([label,d0.l*8])
	jsr ([label,a0])
	jsr ([label,pc])
	jsr ([100.l])	
	jsr ([label])

	rts
	

	blk.l	1000
label


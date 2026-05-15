START:
	; shift values around (word size)
	move.w	#1,d0
	lsl.w	#1,d0
	lsl.w	#1,d0
	nop
	lsr.w	#2,d0
	
	; shift values around (byte size)
	move.b	#1,d0
	lsl.b	#1,d0
	lsl.b	#3,d0
	nop
	lsr.b	#3,d0
	
	; rotate bit pattern
	move.w	#$A6,d0
	ror.w	#4,d0
	rol.w	#4,d0
	
	nop
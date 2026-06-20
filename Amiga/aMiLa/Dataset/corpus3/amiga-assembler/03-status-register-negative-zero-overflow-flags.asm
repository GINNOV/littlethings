START:
	; Negative Flag
	move.b #50,d0
	sub.b #100,d0
	nop
	
	; Zero Flag
	move.b #$ff,d0
	sub.b #$ff,d0
	nop
	
	; Overflow
	move.b #100,d0
	add.b #$1E,d0
	nop
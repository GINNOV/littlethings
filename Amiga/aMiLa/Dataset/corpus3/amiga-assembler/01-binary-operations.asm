START:
	; AND
	move.b #$ff,d0
	and.b #$7a,d0
	
	nop
	nop
	
	; OR
	move.b #$0f,d0
	or.b #$f0,d0
	
	nop
	nop
	
	; NOT
	move.w #231,d0
	not.b d0
	
	nop
	nop
	
	; XOR
	move.b #$ff,d0
	eor.b #$39,d0
	
	nop
	nop
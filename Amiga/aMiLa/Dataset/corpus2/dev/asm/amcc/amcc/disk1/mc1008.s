; mc1008.s 						; EXG and CMPM
; not on disk
; explanation on letter_10.pdf / p.20

; only program fragmets

start:
							; In this machine code chapter, we examine two instructions labeled EXG and CMPM.
							; We start with the simpler instruction first: the EXG (which stands for EXCHANGE). This
							; instruction exchanged the values of two registers. Notice that it always changes all 32 bits. It
							; can change both the data register to data register, data register to address register address
							; register to address register and address register to data register.
							; Here are some examples:
	EXG D0,D1	
	EXG D0,A6	
	EXG A0,A2	
							; This instruction should be easy enough to understand.
							; Let us turn to the second instruction CMPM, which is a variant of the CMP instruction.
							; CMPM is an abbreviation for COMPARE MEMORY.

;We demonstrate this with a small program example:
	move.l #$10000,a0	
	move.l #$20000,A1	
loop:		
	cmpm.w (a0)+,(a1)+	
	beq.s loop	
	rts	

	end

	This program example will compare the values in respectively address $10000 and $20000. If
	these values are equal, it will jump up again and compare the values at address $10002 and
	$20002, etc. When it finds two different values it breaks the loop and returns from the
	program.
	You can try different numbers or exchange the BEQ instruction with a BNE instruction. Try it
	yourself - do not forget that it is very important that you try yourself. You learn a lot from
	your own failure.

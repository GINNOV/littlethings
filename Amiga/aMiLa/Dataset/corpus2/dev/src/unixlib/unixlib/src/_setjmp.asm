	XDEF	__setjmp
	XDEF	__longjmp
	
	csect	text,0,,2,2

__setjmp:
	move.l	4(a7),a0		; Get jmp_buf
	move.l	(a7),(a0)+		; Save return address
	movem.l	a2-a7/d2-d7,(a0)	; Save registers
	moveq	#0,d0
	rts

__longjmp:
	move.l	4(a7),a0		; Get jmp_buf
	move.l	8(a7),d0		; Get result
	bne.s	ok
	moveq	#1,d0			; Return must be != 0
ok	move.l	(a0)+,a1		; Get return address
	movem.l	(a0),a2-a7/d2-d7	; Get registers
	addq.l	#4,a7			; Pop return address
	jmp	(a1)			; And return to setjmp call

	end

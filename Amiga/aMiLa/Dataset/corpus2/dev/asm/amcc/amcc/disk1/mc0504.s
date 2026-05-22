; mc0504.s		; stack
; not on disk
; from Mark Wrobel course letter 15

start:
	move.l a7,a0			; save SP in a0
	move.l #$10,d0			; move $10 into d0
	move.l #$20,d1			; move $20 into d1
	movem.l d0-d1,-(a7)		; push d0-d1 on stack
	move.l a7,a1			; save SP in a1
	clr.l d0				; clear d0
	clr.l d1				; clear d1
	movem.l (a7)+,d0-d1		; pop d0-d1 from stack
	move.l a7,a2			; save SP in a2

	rts						; return from subroutine
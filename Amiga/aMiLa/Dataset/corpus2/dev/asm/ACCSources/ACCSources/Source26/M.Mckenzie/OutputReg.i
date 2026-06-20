
display_reg
	movem.l	d0-d2/a0-a2,-(sp)
	moveq.l	#0,d2		; clear d2
	move.l	d2,d1		; and d1

	lea	Plr1Scr,a0	; initialise registers for the
	move.l	d6,d0		; decimal conversion routine 
	bsr	dec_con		; and then call it

	movem.l	(sp)+,d0-d2/a0-a2
	rts			; all done so leave
	
; A subroutine to convert a word to a decimal number for printing
; ENTRY     d0=word to be converted.
; CORRUPTED a0,d0,d1

dec_con	moveq	#' ',d1		; d1=ASCII code of space
	move.b	d1,(a0)+	; 1st char=space
	move.b	d1,(a0)+	; 2nd char=space
	move.b	d1,(a0)+	; 3rd char=space
	move.b	d1,(a0)+	; 4th char=space
	move.b	#'0',(a0)+	; 5th char=a zero (routine quits
;				; if called with d0=0
DIVLOOP	tst.w	d0		; test if d0=0
	beq.s	FIN		; if it does then exit
	divu.w	#$0A,d0		; divide num by 10
	move.l	d0,d1		; copy result
	swap	d1		; move remainder int MSW
	addi.w	#'0',d1		; convert to ASCII digit
	move.b	d1,-(a0)	; store this digit
	and.l	#$FFFF,d0	; mask off remainder
	bra.s	DIVLOOP		; loop back for next digit
	
FIN	rts			; finished so exit


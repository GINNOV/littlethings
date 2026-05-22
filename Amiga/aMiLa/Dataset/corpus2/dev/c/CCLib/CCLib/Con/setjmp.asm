;
; setjmp - saves the context of a process(?) in a buffer so a call
;	   to longjmp can restore it.
;
;
;
	XDEF _setjmp
	XDEF _longjmp

; CODE setjmp_code  (this had to be removed as Aztec doesn't like)
	EVEN
_setjmp:
	move.l	4(sp),a0        ; get pointer to save array
	move.l	(sp),a1        ; get return address
	move.l	a1,(a0) ; save return address
	movem.l d2-d7/a2-a7,4(a0)

	clr.l	d0
	rts

;
; longjmp - restores the context saved by a call to setjmp, which causes
;	    the process to do a jump to where the setjmp was called
;	    i.e. looks like the setjmp returned again.
;
;
_longjmp:
	move.l	4(sp),a0        ;get pointer to save_env
	move.l	8(sp),d0        ;get return value
	tst.l	d0
	bne	not_zero	; if the return value is zero set it to 1
	move.l	#1,d0
not_zero:
	movem.l 4(a0),d2-d7/a2-a7
	move.l	(a0),(sp)       ; write return address

	rts ;here goes nothing.

	END




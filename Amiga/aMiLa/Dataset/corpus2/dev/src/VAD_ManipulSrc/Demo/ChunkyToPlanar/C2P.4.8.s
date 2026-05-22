; -----------------------------------------------------------------------------
; Procedure:	ChunkyToPlanar
; Function:	Convert chunky to planar
; In:
;	d5.l	plane size
;	a0.l	pointer to chunky map
;	a1.l	pointer to planar map
; Out:
;	none
; Crash regs:
;	all
; -----------------------------------------------------------------------------

CONVERT_8_PIXELS MACRO
		move.l	(a0)+,d0		; 12
		move.l	(a0)+,d1		; 12
		lsr.l	#4,d1			; 16
		or.l	d1,d0			;  8
		move.l	d0,d1			;  4
		and.l	d7,d1			;  8
		move.w	d1,d2			;  4
		clr.w	d1			;  4
		lsl.l	#2,d1			; 12
		lsr.w	#2,d2			; 10
		or.w	d2,d1			;  4
		swap	d0			;  4
		and.l	d7,d0			;  8
		or.l	d0,d1			;  8
		move.l	d1,d2			;  4
		lsr.l	#7,d2			; 22
		move.l	d1,d0			;  4
		and.l	d6,d0			;  8
		eor.l	d0,d1			;  8
		move.l	d2,d4			;  4
		and.l	d6,d4			;  8
		eor.l	d4,d2			;  8
		or.l	d4,d1			;  8
		lsr.l	#1,d1			; 10

		move.b	d1,(a4)+		;  8
		swap	d1			;  4
		move.b	d1,(a2)+		;  8

		or.l	d0,d2			;  8

		move.b	d2,(a3)+		;  8
		swap	d2			;  4
		move.b	d2,(a1)+		;  8

		ENDM				; 246/8 = 30.75 cycles/pixel


ChunkyToPlanar	lea	(a1,d5.l),a2
		lea	(a2,d5.l),a3
		lea	(a3,d5.l),a4

		lsr.w	#2,d5
		subq.w	#1,d5

		move.l	#$55555555,d6
		move.l	#$3333cccc,d7

ctp_Loop0	CONVERT_8_PIXELS
		CONVERT_8_PIXELS
		CONVERT_8_PIXELS
		CONVERT_8_PIXELS

		dbra	d5,ctp_Loop0

		rts

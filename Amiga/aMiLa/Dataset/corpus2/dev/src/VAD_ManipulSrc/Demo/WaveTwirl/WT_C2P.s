; -----------------------------------------------------------------------------
; Procedure:	GF_ChunkyToPlanar
; Function:	Convert chunky to planar
; In:
;	a0.l	pointer to chunky map
;	a1.l	pointer to planar map
; Out:
;	none
; Crash regs:
;	all
; -----------------------------------------------------------------------------

WT_CONVERT_8_PIXELS MACRO
		move.l	(a0)+,d0		; 12
		move.l	(a0)+,d1		; 12

		move.l	a3,d2
		and.l	d0,d2

		eor.l	d2,d0			;  8

		move.l	a3,d3
		and.l	d1,d3

		eor.l	d3,d1			;  8
		lsl.l	#4,d2			; 16
		or.l	d3,d2			;  8
		lsr.l	#4,d1			; 16
		or.l	d1,d0			;  8
		move.l	d2,d3			;  4
		and.l	d7,d3			;  8
		move.w	d3,d1			;  4
		clr.w	d3			;  4
		lsl.l	#2,d3			; 12
		lsr.w	#2,d1			; 10
		or.w	d1,d3			;  4
		swap	d2			;  4
		and.l	d7,d2			;  8
		or.l	d2,d3			;  8
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

		move.b	d1,7*WT_WIDTH_B(a1)	; 12
		swap	d1			;  4
		move.b	d1,5*WT_WIDTH_B(a1)	; 12

		or.l	d0,d2			;  8

		move.b	d2,6*WT_WIDTH_B(a1)	; 12
		swap	d2			;  4
		move.b	d2,4*WT_WIDTH_B(a1)	;  12

		move.l	d3,d2			;  4
		lsr.l	#7,d2			; 22
		move.l	d3,d0			;  4
		and.l	d6,d0			;  8
		eor.l	d0,d3			;  8
		move.l	d2,d4			;  4
		and.l	d6,d4			;  8
		eor.l	d4,d2			;  8
		or.l	d4,d3			;  8
		lsr.l	#1,d3			; 10

		move.b	d3,3*WT_WIDTH_B(a1)	; 12
		swap	d3			;  4
		move.b	d3,1*WT_WIDTH_B(a1)	; 12

		or.l	d0,d2			;  8

		move.b	d2,2*WT_WIDTH_B(a1)	; 12
		swap	d2			;  4
		move.b	d2,(a1)+		;  8
						;=532/8=66.5 cycles per pixel
		ENDM


WT_ChunkyToPlanar	
		movea.l	a1,a2
		adda.l	#WT_WIDTH_B*8*WT_WHEIGHT,a2

		move.l	#$0f0f0f0f,a3
		move.l	#$55555555,d6
		move.l	#$3333cccc,d7

WT_ctp_Loop0
		moveq	#WT_WWIDTH_B-1,d5
WT_ctp_Loop1
		WT_CONVERT_8_PIXELS

		dbra	d5,WT_ctp_Loop1

		lea	(WT_WIDTH_B-WT_WWIDTH_B+WT_WIDTH_B*7)(a1),a1

		cmpa.l	a2,a1
		bne	WT_ctp_Loop0

		rts

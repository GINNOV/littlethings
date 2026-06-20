; -----------------------------------------------------------------------------
; Procedure:	ChunkyToPlanar
; Function:	Convert chunky to planar
; In:
;	a0.l	pointer to chunky map
;	a1.l	pointer to planar map
; Out:
;	none
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

		move.b	d1,1*C2P_PLANE_SIZE(a2)	; 12
		swap	d1			;  4
		move.b	d1,1*C2P_PLANE_SIZE(a1)	; 12

		or.l	d0,d2			;  8

		move.b	d2,(a2)+		;  8
		swap	d2			;  4
		move.b	d2,(a1)+		;  8

		ENDM				; 254/8 = 31.75 cycles/pixel


WAIT_BLITTER	MACRO
wb\@		btst.b	#6,(a6)
		bne.b	wb\@
		ENDM


TEST_8_PIXELS	MACRO

		move.w	a4,(a5)

		ENDM


ctp_Skip0	TEST_8_PIXELS

		addq.l	#8,a0

		moveq	#0,d0
		move.b	d0,1*C2P_PLANE_SIZE(a2)
		move.b	d0,(a2)+
		move.b	d0,1*C2P_PLANE_SIZE(a1)
		move.b	d0,(a1)+

		dbra	d5,ctp_Loop1

		rts

ChunkyToPlanar
		lea	2*C2P_PLANE_SIZE(a1),a2

		move.w	#C2P_PLANE_SIZE-1,d5
		move.l	#$55555555,d6
		move.l	#$3333cccc,d7

		lea	CUSTOM+2,a6
		lea	CUSTOM+bltsize,a5
		lea	$0044.w,a4

		WAIT_BLITTER
		move.l	a0,bltcpt-2(a6)
		move.l	#$02aa0000,bltcon0-2(a6)
		move.w	#0,bltcmod-2(a6)
		move.w	a4,(a5)

ctp_Loop1	WAIT_BLITTER

ctp_Loop0	btst.b	#5,(a6)
		bne.w	ctp_Skip0

		TEST_8_PIXELS

		CONVERT_8_PIXELS

		dbra	d5,ctp_Loop1

		rts

; -----------------------------------------------------------------------------
; Procedure:	ChunkyToPlanar
; Function:	Convert chunky to planar
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

MERGE_WORD	MACRO	; r1,r2,rtmp
		move.w	\2,\3
		move.w	\1,\2
		swap	\2
		move.w	\2,\1
		move.w	\3,\2
		ENDM				; 20 cycles


CONVERT_32_PIXELS MACRO

		movem.l	(a0)+,d0/d7		; 28
		lsr.l	#4,d7			; 16
		or.l	d7,d0			; 8 = 52

		movem.l	(a0)+,d1/d3/d4/d7	; 44
		lsr.l	#4,d3			; 16
		or.l	d3,d1			; 8
		lsr.l	#4,d7			; 16
		or.l	d7,d4			; 8 = 92

		movem.l	(a0)+,d6/d7
		lsr.l	#4,d7
		or.l	d7,d6			; 52


		move.l	d0,d7			; 4
		and.l	d5,d0			; 8
		eor.l	d0,d7			; 8
		lsl.l	#8,d7			; 24
		move.l	d1,d3			; 4
		and.l	d5,d3			; 8
		eor.l	d3,d1			; 8
		lsr.l	#8,d3			; 24
		or.l	d3,d0			; 8
		or.l	d7,d1			; 8 = 92

		move.l	d4,d7
		and.l	d5,d4
		eor.l	d4,d7
		lsl.l	#8,d7
		move.l	d6,d3
		and.l	d5,d3
		eor.l	d3,d6
		lsr.l	#8,d3
		or.l	d3,d4
		or.l	d7,d6			; 92


		MERGE_WORD	d0,d4,d7	; 20
		MERGE_WORD	d1,d6,d7	; 20


		move.l	d0,d7			; 4
		move.l	d4,d3			; 4
		and.l	d2,d0			; 8
		and.l	d2,d3			; 8
		eor.l	d0,d7			; 8
		eor.l	d3,d4			; 8
		lsl.l	#2,d7			; 12
		lsr.l	#2,d3			; 12
		or.l	d7,d4			; 8
		or.l	d3,d0			; 8 = 80

		move.l	d1,d7
		move.l	d6,d3
		and.l	d2,d1
		and.l	d2,d3
		eor.l	d1,d7
		eor.l	d3,d6
		lsl.l	#2,d7
		lsr.l	#2,d3
		or.l	d7,d6
		or.l	d3,d1			; 80


		move.l	a5,d7			; 4
		move.l	a5,d3			; 4
		and.l	d0,d7			; 8
		and.l	d1,d3			; 8
		eor.l	d7,d0			; 8
		eor.l	d3,d1			; 8
		add.l	d0,d0			; 8
		lsr.l	#1,d3			; 10
		or.l	d0,d1			; 8
		or.l	d3,d7			; 8 = 74

		move.l	d1,(a3)+		; 12
		move.l	d7,(a4)+		; 12

		move.l	a5,d7
		move.l	a5,d3
		and.l	d4,d7
		and.l	d6,d3
		eor.l	d7,d4
		eor.l	d3,d6
		add.l	d4,d4
		lsr.l	#1,d3
		or.l	d4,d6
		or.l	d3,d7			; 74

		move.l	d7,(a2)+		; 12
		move.l	d6,(a1)+		; 12

		ENDM				; 776/32=24.25 cycles/pixel


ChunkyToPlanar	lea	ChunkyMap,a0
		movea.l	VRAM_Render(pc),a1
		lea	PLANE_SIZE(a1),a2
		lea	2*PLANE_SIZE(a1),a3
		lea	3*PLANE_SIZE(a1),a4
		lea	ChunkyMap+SCREEN_WIDTH*SCREEN_HEIGHT,a6

		move.l	#$ff00ff00,d5
		move.l	#$cccccccc,d2
		move.l	#$aaaaaaaa,a5

ctp_Loop0	CONVERT_32_PIXELS

		cmpa.l	a6,a0
		bne	ctp_Loop0

		rts

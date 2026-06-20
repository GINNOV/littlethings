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

MERGE		MACRO	; r1,r2,rtmp1,rtmp2,mask,shift
		move.l	\5,\3			; 4
		move.l	\5,\4			; 4
		and.l	\1,\3			; 8
		and.l	\2,\4			; 8
		eor.l	\3,\1			; 8
		eor.l	\4,\2			; 8
	IFEQ	\6-1
		add.l	\3,\3			; 8
	ELSE
		lsl.l	#\6,\3			; 8+2*\6
	ENDC
		lsr.l	#\6,\2			; 8+2*\6
		or.l	\2,\1			; 8
		or.l	\4,\3			; 8
		ENDM				; shift=8  104 cycles
						; shift=4   88 cycles
						; shift=2   80 cycles
						; shift=1   74 cycles

CONVERT_32_PIXELS MACRO

		movem.l	(a0)+,d0-d7		; 76

		MERGE_WORD	d0,d4,a4	; 20
		MERGE_WORD	d1,d5,a4	; 20
		MERGE_WORD	d2,d6,a4	; 20
		MERGE_WORD	d3,d7,a4	; 20

		move.l	d5,a3			; 4
		move.l	d7,a4			; 4
		MERGE	d0,d2,d5,d7,a6,8	; 104
		MERGE	d1,d3,d7,d2,a6,8	; 104
		MERGE	d4,d6,d2,d3,a6,8	; 104
		exg	a3,d5			; 6
		exg	a4,d7			; 6
		MERGE	d5,d7,d3,d6,a6,8	; 104

		MERGE	d0,d1,d6,d7,a5,4	; 88
		MERGE	d4,d5,d7,d1,a5,4	; 88
		MERGE	d2,d3,d1,d5,a5,4	; 88
		exg	a3,d6			; 6
		exg	a4,d7			; 6
		MERGE	d6,d7,d5,d3,a5,4	; 88

		MERGE	d0,d4,d3,d7,a1,2	; 80
		MERGE	d6,d2,d7,d4,a1,2	; 80
		MERGE	d5,d1,d4,d2,a1,2	; 80
		exg	a3,d3			; 6
		exg	a4,d7			; 6
		MERGE	d3,d7,d2,d1,a1,2	; 80

		MERGE	d0,d6,d1,d7,a2,1	; 74
		MERGE	d3,d5,d7,d6,a2,1	; 74
		MERGE	d2,d4,d6,d5,a2,1	; 74
		move.l	d1,2*PLANE_SIZE(a7)	; 16
		move.l	a3,d1			; 4
		move.l	d7,-2*PLANE_SIZE(a7)	; 16
		move.l	a4,d7			; 4
		MERGE	d1,d7,d5,d4,a2,1	; 74

		move.l	d0,3*PLANE_SIZE(a7)	; 16
		move.l	d1,1*PLANE_SIZE(a7)	; 16
		move.l	d3,-1*PLANE_SIZE(a7)	; 16
		move.l	d2,-3*PLANE_SIZE(a7)	; 16
		move.l	d6,-4*PLANE_SIZE(a7)	; 16
		move.l	d5,(a7)+		; 12
		ENDM				; 1716/32=53.625 cycles/pixel


WAIT_BLITTER	MACRO
wb\@		btst.b	#6,dmaconr+CUSTOM
		bne.b	wb\@
		ENDM


TEST_32_PIXELS	MACRO

		move.w	#$0050,bltsize+CUSTOM

		ENDM


ctp_Skip0	TEST_32_PIXELS 

		lea	32(a0),a0

		moveq	#0,d0
		move.l	d0,3*PLANE_SIZE(a7)
		move.l	d0,2*PLANE_SIZE(a7)
		move.l	d0,1*PLANE_SIZE(a7)
		move.l	d0,-1*PLANE_SIZE(a7)
		move.l	d0,-2*PLANE_SIZE(a7)
		move.l	d0,-3*PLANE_SIZE(a7)
		move.l	d0,-4*PLANE_SIZE(a7)
		move.l	d0,(a7)+

		cmpa.l	#ChunkyMap+SCREEN_WIDTH*SCREEN_HEIGHT,a0
		bne.b	ctp_Loop1

		move.l	StackTmp(pc),sp
		rts

ChunkyToPlanar	move.l	sp,StackTmp
		lea	ChunkyMap,a0
		movea.l	VRAM_Render(pc),a7
		lea	4*PLANE_SIZE(a7),a7

		move.l	#$00ff00ff,a6
		move.l	#$0f0f0f0f,a5
		move.l	#$33333333,a1
		move.l	#$55555555,a2

		WAIT_BLITTER
		move.l	a0,bltcpt+CUSTOM
		move.l	#$02aa0000,bltcon0+CUSTOM
		move.w	#0,bltcmod+CUSTOM
		TEST_32_PIXELS

ctp_Loop1	WAIT_BLITTER

ctp_Loop0	btst.b	#5,dmaconr+CUSTOM
		bne.w	ctp_Skip0

		TEST_32_PIXELS

		CONVERT_32_PIXELS

		cmpa.l	#ChunkyMap+SCREEN_WIDTH*SCREEN_HEIGHT,a0
		bne	ctp_Loop0

		move.l	StackTmp(pc),sp
		rts

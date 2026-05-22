; -----------------------------------------------------------------------------
; Procedure:	ChunkyToPlanar
; Function:	Convert chunky to planar
; In:
;	a0.l	pointer to chunky map
;	a1.l	pointer to planar map
;	C2P_PLANE_SIZE	plane size
; Out:
;	none
; Crash regs:
;	all
; -----------------------------------------------------------------------------

MERGE_WORD	MACRO	; r1,r2,rtmp

		move.w	\2,\3
		move.w	\1,\2
		swap	\2
		move.w	\2,\1
		move.w	\3,\2

		ENDM				; 20 cycles


MERGE		MACRO	; r1,r2,rtmp1,rtmp2,rmask,shift

		move.l	\5,\3
		move.l	\5,\4
		and.l	\1,\3
		and.l	\2,\4
		eor.l	\3,\1
		eor.l	\4,\2
		lsl.l	#\6,\3
		lsr.l	#\6,\2
		or.l	\2,\1
		or.l	\4,\3

		ENDM


MERGE2		MACRO	; r1,rtmp1,rtmp2,planeA,planeB

		move.l	a3,\2			; 4
		and.l	\1,\2			; 8
		eor.l	\2,\1			; 8

		move.l	\1,\3			; 4
		lsr.l	#1,\3			; 10
		or.l	\3,\1			; 8
		move.l	\1,\5			; 16

		move.l	\2,\3			; 4
		add.l	\3,\3			; 8
		or.l	\3,\2			; 8
		move.l	\2,\4			; 12|16

		ENDM				; 90|94


CONVERT_16_PIXELS MACRO

		movem.l	(a0)+,d0-d3		; 44

		MERGE_WORD	d0,d2,d4	; 20
		MERGE_WORD	d1,d3,d4	; 20

		MERGE	d0,d1,d4,d5,a6,8	; 104
		MERGE	d2,d3,d1,d5,a6,8	; 104

		MERGE	d0,d2,d3,d5,a5,4	; 88
		MERGE	d4,d1,d2,d5,a5,4	; 88

		MERGE	d0,d4,d1,d5,a4,2	; 80
		MERGE	d3,d2,d4,d5,a4,2	; 80

		MERGE2	d0,d2,d5,2*COM_WIDTH_B(a2),3*COM_WIDTH_B(a2)	; 90
		MERGE2	d1,d2,d5,(a2)+,COM_WIDTH_B(a2)			; 90
		MERGE2	d3,d2,d5,2*COM_WIDTH_B(a1),3*COM_WIDTH_B(a1)	; 94
		MERGE2	d4,d2,d5,(a1)+,COM_WIDTH_B(a1)			; 90

		move.l	-4(a1),8*COM_WIDTH_B-4(a1)
		move.l	COM_WIDTH_B-4(a1),9*COM_WIDTH_B-4(a1)
		move.l	2*COM_WIDTH_B-4(a1),10*COM_WIDTH_B-4(a1)
		move.l	3*COM_WIDTH_B-4(a1),11*COM_WIDTH_B-4(a1)
		move.l	4*COM_WIDTH_B-4(a1),12*COM_WIDTH_B-4(a1)
		move.l	5*COM_WIDTH_B-4(a1),13*COM_WIDTH_B-4(a1)
		move.l	6*COM_WIDTH_B-4(a1),14*COM_WIDTH_B-4(a1)
		move.l	7*COM_WIDTH_B-4(a1),15*COM_WIDTH_B-4(a1)

		ENDM				; 992/16=62


COM_ChunkyToPlanar	
		lea	4*COM_WIDTH_B(a1),a2

		move.l	#$00ff00ff,a6
		move.l	#$0f0f0f0f,a5
		move.l	#$33333333,a4
		move.l	#$55555555,a3

		move.w	#C2P_CONV_NUM/10/2-1,d6

COM_ctp_Loop1	moveq	#9,d7

COM_ctp_Loop0	CONVERT_16_PIXELS

		dbra	d7,COM_ctp_Loop0

		lea	(7+8)*COM_WIDTH_B(a1),a1
		lea	(7+8)*COM_WIDTH_B(a2),a2

		dbra	d6,COM_ctp_Loop1

		rts

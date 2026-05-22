; -----------------------------------------------------------------------------
; Procedure:	ChunkyToPlanarIR
; Function:	Convert chunky to planar (special version for IR scaner)
; In:
;	a0.l	pointer to chunky map
;	a1.l	pointer to planar map
;	C2P_PLANE_SIZE	plane size
; Out:
;	none
; Crash regs:
;	all
; Warning:	macros from C2P.COM.s
; -----------------------------------------------------------------------------

COM_ChunkyToPlanarIR
		lea	4*COM_WIDTH_B(a1),a2

		move.l	#$00ff00ff,a6
		move.l	#$0f0f0f0f,a5
		move.l	#$33333333,a4
		move.l	#$55555555,a3

		move.w	#42/2-1,d6

COM_ctpir_Loop1	moveq	#1,d7

COM_ctpir_Loop0	CONVERT_16_PIXELS

		dbra	d7,COM_ctpir_Loop0

		lea	(7+8)*COM_WIDTH_B+32(a1),a1
		lea	(7+8)*COM_WIDTH_B+32(a2),a2

		dbra	d6,COM_ctpir_Loop1

		rts

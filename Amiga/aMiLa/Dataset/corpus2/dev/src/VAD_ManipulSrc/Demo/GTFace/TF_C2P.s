; -----------------------------------------------------------------------------
; Procedure:	TF_ChunkyToPlanar
; Function:	Convert chunky to planar (TF section)
; In:
;	a0.l	pointer to chunky map
;	a1.l	pointer to planar map
; Out:
;	none
; Crash regs:
;	all
; -----------------------------------------------------------------------------

TF_ChunkyToPlanar	
		movea.l	a1,a2
		adda.l	#GF_WIDTH_B*8*GF_WHEIGHT,a2

		move.l	#$0f0f0f0f,a3
		move.l	#$55555555,d6
		move.l	#$3333cccc,d7

TF_ctp_Loop0
		moveq	#GF_WWIDTH_B-1,d5
TF_ctp_Loop1
		GF_CONVERT_8_PIXELS

		dbra	d5,TF_ctp_Loop1

		lea	(GF_WIDTH_B-GF_WWIDTH_B+GF_WIDTH_B*7)(a1),a1

		cmpa.l	a2,a1
		bne	TF_ctp_Loop0

		rts

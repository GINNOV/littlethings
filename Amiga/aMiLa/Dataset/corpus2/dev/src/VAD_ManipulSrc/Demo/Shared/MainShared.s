; ===========================================================================
; Name:		Main shared procedures
; File:		MainShared.s
; Author:	Noe / Venus Art
; Copyright:	© 1995 by Venus Art
; ---------------------------------------------------------------------------
; History:
; 30.04.1995	SetBplPtrs
;
; ===========================================================================

		SECTION	MainShared,CODE

; ===========================================================================
; Procedure:	SetCopperBplPtrs
; Function:	Make copper list with bitplane pointers
; In:
;	a0.l	pointer to copper list
;	d0.l	pointer to planes
;	d1.l	size of one plane
;	d7.w	depth of view -1
; Out:
;	none
; Crash regs:
;	d0/d1/d2/d7/a0
; ===========================================================================

SetCopperBplPtrs
		move.w	#bplpt,d2

sbp_Loop	move.w	d2,(a0)+
		addq.w	#2,d2
		swap	d0
		move.w	d0,(a0)+
 		move.w	d2,(a0)+
		addq.w	#2,d2
		swap	d0
		move.w	d0,(a0)+

		add.l	d1,d0

		dbra	d7,sbp_Loop

		rts


; ===========================================================================
; Procedure:	SetCopperPalette
; Function:	Make copper list with palette
; In:
;	a0.l	pointer to copper list
;	a1.l	pointer to 32bit palette or NULL if all colors black
;	d7.w	number of colors  -1
; Out:
;	none
; Crash regs:
;	d0-d7/a0/a1
; ===========================================================================

SetCopperPalette
		move.l	#bplcon3<<16+$0000,d0
		move.l	#bplcon3<<16+$0200,d1

scp_Loop1	moveq	#31,d6
		cmpi.w	#32,d7
		bge.b	scp0

		move.w	d7,d6

scp0		move.w	d6,d5
		addq.w	#2,d5
		lsl.w	#2,d5

		move.w	#color,d2

		move.l	d1,(a0,d5.w)
		move.l	d0,(a0)+

		addi.w	#$2000,d0
		addi.w	#$2000,d1

scp_Loop0	moveq	#0,d3
		moveq	#0,d4
		tst.l	a1
		beq.b	scp1

		move.l	(a1)+,d3
		move.l	d3,d4

		lsr.l	#4,d3
		lsl.b	#4,d3
		lsl.w	#4,d3
		lsr.l	#8,d3

		lsl.b	#4,d4
		lsl.w	#4,d4
		lsr.l	#8,d4
		andi.w	#$0fff,d4

scp1		move.w	d2,(a0,d5.w)
		move.w	d4,2(a0,d5.w)
		move.w	d2,(a0)+
		move.w	d3,(a0)+

		addq.w	#2,d2

		subq.w	#1,d7
		dbra	d6,scp_Loop0

		add.w	d5,a0

		tst.w	d7
		bpl.b	scp_Loop1

		rts


; ===========================================================================
; Procedure:	SetPalette
; Function:	Set palette (directly to AGA registers)
; In:
;	a0.l	pointer to 32bit palette or NULL if all colors black
;	d7.w	number of colors  -1
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

SetPalette
		lea	CUSTOM,a5

		move.w	#$0000,d0
		move.w	#$0200,d1

sp_Loop1	moveq	#31,d6
		cmpi.w	#32,d7
		bge.b	sp0

		move.w	d7,d6

sp0		move.w	#color,d2

sp_Loop0	moveq	#0,d3
		moveq	#0,d4
		cmpa.w	#0,a0
		beq.b	sp1

		move.l	(a0)+,d3
		move.l	d3,d4

		lsr.l	#4,d3
		lsl.b	#4,d3
		lsl.w	#4,d3
		lsr.l	#8,d3

		lsl.b	#4,d4
		lsl.w	#4,d4
		lsr.l	#8,d4
		andi.w	#$0fff,d4

sp1		move.w	d0,bplcon3(a5)
		move.w	d3,(a5,d2.w)
		move.w	d1,bplcon3(a5)
		move.w	d4,(a5,d2.w)

		addq.w	#2,d2

		subq.w	#1,d7
		dbra	d6,sp_Loop0

		addi.w	#$2000,d0
		addi.w	#$2000,d1

		tst.w	d7
		bpl.b	sp_Loop1

		rts

; ===========================================================================
; Procedure:	Wait
; Function:	Wait n ticks (ticks = 1/50 sec)
; In:
;	d0.w	ticks number
; Out:
;	none
; Crash regs:
;
; ===========================================================================

Wait		movem.l	d1/a5,-(sp)
		lea	$dff004,a5
Wait_		move.l	(a5),d1
		andi.l	#$0001ff00,d1
		cmpi.l	#$00012d00,d1
		bne.b	Wait_
Wait_2		move.l	(a5),d1
		andi.l	#$0001ff00,d1
		cmpi.l	#$00001000,d1
		bne.b	Wait_2
		dbra	d0,Wait_
		movem.l	(sp)+,d1/a5
		rts

; ===========================================================================
; Procedure:	RasterLineWait
; Function:	Wait n raster lines
; In:
;	d0.l	raster lines number
; Out:
;	none
; Crash regs:
;
; ===========================================================================

RasterLineWait	movem.l	d1-d3/a5,-(sp)
		lea	$dff004,a5
		move.l	#$0001ff00,d2
		move.l	(a5),d3
		and.l	d2,d3

RLWait_		move.l	(a5),d1
		and.l	d2,d1
		cmp.l	d3,d1
		beq.b	RLWait_
		move.l	d1,d3
		dbra	d0,RLWait_

		movem.l	(sp)+,d1-d3/a5
		rts

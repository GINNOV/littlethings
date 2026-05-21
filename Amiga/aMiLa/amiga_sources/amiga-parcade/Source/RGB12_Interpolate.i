;RGB12_Interpolate_Small:
;	movem.l	d3-d6,-(a7)		; 4
;	moveq	#$0000000f,d3		; 2
;	moveq	#$ffffffff,d4		; 2
;.LoopRGB
;	move.w	d0,d5			; 2
;	move.w	d1,d6			; 2
;	and.w	d3,d5			; 2
;	and.w	d3,d6			; 2

;	sub.w	d5,d6			; 2
;	muls.w	d2,d6			; 2
;	divs.w	#15,d6			; 4
;	and.w	d4,d6			; 2
;	add.w	d6,d0			; 2

;	asl.w	#4,d4			; 2
;	lsl.w	#4,d3			; 2
;	bgt.s	.LoopRGB		; 2

;	movem.l	(a7)+,d3-d6		; 4
;	rts


RGB12_Interpolate_Fast_BuildTable:
	lea	RGB12_Interpolate_Table(pc),a0
	moveq	#-15,d7
.LoopColor
	moveq	#0,d6
.LoopScale
	move.w	d7,d0
	muls.w	d6,d0
	divs.w	#15,d0
	move.b	d0,(a0)+
	asl.b	#4,d0
	move.b d0,(a0)+
	addq.w	#1,d6
	cmp.w	#16,d6
	bne.b	.LoopScale
	addq.w	#1,d7
	cmp.w	#16,d7
	bne.b	.LoopColor
	rts

*****************************************************************************
* Interpolates between 2 12 bit colors. Use for fades.
* IN:		d0, color source
*		d1, color dest
*		d2, step (0-15)
* OUT:		d0, new color
* TRASHED:	d0-d2
*****************************************************************************

RGB12_Interpolate_Fast:
	move.w	d3,-(a7)		; 8
	move.w	d4,-(a7)		; 8
	move.w	#$0f0,d3		; 8
	add.w	d3,d2			; 4
	add.w	d2,d2			; 4

	move.w	d3,d4			; 4
	and.w	d0,d3			; 4
	and.w	d1,d4			; 4
	sub.w	d3,d4			; 4
	add.w	d4,d4			; 4
	add.w	d2,d4			; 4
	add.b	RGB12_Interpolate_Table+1(pc,d4.w),d0	; 14

	move.w	#$00f,d3		; 8
	move.w	d3,d4			; 4
	and.w	d0,d3			; 4
	and.w	d1,d4			; 4
	sub.w	d3,d4			; 4
	asl.w	#4+1,d4			; 6+2*5=16
	add.w	d2,d4			; 4
	add.b	RGB12_Interpolate_Table(pc,d4.w),d0	; 14

	move.w	d0,d3			; 4
	clr.b	d3			; 4
	clr.b	d1			; 4
	sub.w	d3,d1			; 4
	asr.w	#8-(4+1),d1		; 6+2*3=12
	add.w	d2,d1			; 4
	move.w	RGB12_Interpolate_Table(pc,d1.w),d1	; 14
	clr.b	d1			; 4
	add.w	d1,d0			; 4

	move.w	(a7)+,d4		; 8
	move.w	(a7)+,d3		; 8
	rts				; 16

RGB12_Interpolate_Table:	DS.W	31*16		; [-15..15]x[0..15]


	moveq	#1,d2
	moveq	#-1,d3
	lea	Count(pc),a0
	lea	$bfd000,a4

Start	bsr	Loop
	btst	#6,$bfe001
	bne	Start
	moveq	#0,d0
	rts

Loop	moveq	#2-1,d7
.1	bsr	.2
	add.b	d2,(a0)
	cmp.b	(a0),d3
	bne	.1
	exg.l	d2,d3
	dbf	d7,.1
	rts
.2	moveq	#0,d0
	move.b	(a0),d0
	lsl.w	#2,d0
.3	bset	#1,$bfe001
	bsr	.5
	not.b	d0
.4	bclr	#1,$bfe001
	bsr	.5
	rts
.5	move.b	#$7f,$d00(a4)
	move.b	#$08,$e00(a4)
	move.b	d0,$400(a4)
	lsr.w	#8,d0
	move.b	d0,$500(a4)
.6	btst	#0,$d00(a4)
	beq.s	.6
	move.b	#$81,$d00(a4)
	rts

Count	dc.b	1


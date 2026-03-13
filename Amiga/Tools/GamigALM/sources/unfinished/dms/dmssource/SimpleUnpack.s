
	lea	$1b0000,a0
	lea	$1c0000,a1
	move.l	#11264,d0
	bsr	PSimple
	rts

;--------------------------------------;
;	a0 = Source
;	a1 = Destination
;	d0 = Length

DNoComp	subq.w	#1,d0
	moveq	#0,d1
	moveq	#0,d2
.1	move.b	(a0)+,d2
	move.b	d2,(a1)+
	add.w	d2,d1
	dbf	d0,.1
	move.w	d1,Thing
	rts

;--------------------------------------;
;	a0 = Source
;	a1 = Destination
;	d0 = Length

PSimple	lea	(a0,d0),a2
	move.w	#$90,d2
	move.w	#$ff,d4
	move.w	#$7ffe,d5
	moveq	#0,d1
	moveq	#0,d3
	moveq	#0,d6
	move.b	(a0)+,d3
	add.w	d3,d6
.1	move.w	d5,d0
.2	cmp.l	a2,a0
	bge.s	.3
	move.b	(a0)+,d1
	add.w	d1,d6
	cmp.b	d1,d3
	bne.s	.3
	dbf	d0,.2
	addq.w	#1,d0
.3	sub.w	d5,d0
	neg.w	d0
	addq.w	#1,d0
	cmp.w	#1,d0
	bne.s	.5
	cmp.b	d2,d3
	bne.s	.4
	move.b	d3,(a1)+
	clr.b	(a1)+
	bra.s	.9

.4	move.b	d3,(a1)+
	bra.s	.9

.5	cmp.w	#2,d0
	bne.s	.7
	cmp.b	d2,d3
	bne.s	.6
	move.b	d3,(a1)+
	clr.b	(a1)+
	move.b	d3,(a1)+
	clr.b	(a1)+
	bra.s	.9

.6	move.b	d3,(a1)+
	move.b	d3,(a1)+
	bra.s	.9

.7	cmp.w	d4,d0
	bge.s	.8
	move.b	d2,(a1)+
	move.b	d0,(a1)+
	move.b	d3,(a1)+
	bra.s	.9

.8	move.b	d2,(a1)+
	move.b	d4,(a1)+
	move.b	d3,(a1)+
	move.b	d0,1(a1)
	lsr.w	#8,d0
	move.b	d0,(a1)
	addq.l	#2,a1

.9	cmp.l	a2,a0
	bge.s	.10
	move.b	d1,d3
	bra.s	.1

.10	cmp.b	d1,d3
	beq.s	.12
	cmp.b	d2,d1
	bne.s	.11

	move.b	d1,(a1)+
	clr.b	(a1)+
	bra.s	.12

.11	move.b	d1,(a1)+
.12	move.w	d6,Thing
	move.l	a1,d0
	rts

;--------------------------------------;
;	a0 = Source
;	a1 = Destination
;	d0 = Length

DSimple	lea	(a0,d0),a2
	move.b	#$90,d2
	moveq	#0,d0
	moveq	#0,d3
.1	cmp.l	a2,a0
	bge	.7
	move.b	(a0)+,d0
	cmp.b	d2,d0
	beq	.2
	move.b	d0,(a1)+
	add.w	d0,d3
	bra	.1
.2	moveq	#0,d1
	move.b	(a0)+,d1
	tst.b	d1
	bne.s	.3
	move.b	d0,(a1)+
	add.w	d0,d3
	bra	.1
.3	cmp.b	#-1,d1
	bne	.5
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	lsl.w	#8,d1
	or.b	(a0)+,d1
	subq.w	#1,d1
.4	move.b	d0,(a1)+
	add.w	d0,d3
	dbf	d1,.4
	bra	.1
.5	move.b	(a0)+,d0
	subq.w	#1,d1
.6	move.b	d0,(a1)+
	add.w	d0,d3
	dbf	d1,.6
	bra	.1
.7	move.w	d3,Thing
	move.l	a1,d0
	rts

;--------------------------------------;

Thing	dc.w	0

Data	incbin	"DH1:Charts/Page0"
DataEnd

Space	dcb.b	10000,0

; mandel.asm from The Source
; fixed for AGA, 2.0, low memory etc by Kyzer/CSG
	include	cados.asm

planes=5

Mandel	lea	.cols(pc),a0
	moveq	#0,d0
	move	#1<<planes,d1
	jsr	_SetColoursRGB

	move	#320,d0
	move	#200,d1
	moveq	#planes,d2
	move	#128,d3
	moveq	#44,d4
	moveq	#0,d5
	moveq	#MSF_NOBORDER,d6
	jsr	_MakeScreen
	tst.l	a0
	beq.s	.nomem
	lea	.bmap(pc),a2
	move.l	a1,(a2)
	lea	.cop(pc),a2
	move.l	a0,(a2)

	setcop	a0
	dmaon	COPPER,RASTER

	get.l	.bmap,a4
	moveq	#0,d4
	move.l	#-$8000000*2,a1
	move.l	#100,a2
	move.l	#8000,a3
				;$1333333 each x
				;$28f5c2 each y
	move.l	#$199999,d1
	move.l	#$28f5c2,d2
	move.l	#319,d5
	moveq	#$f,d6
	moveq	#7,d7

.yloop	move.l	d5,d3
	move.l	#$8000000*2,a0
	
.xloop	move.l	a2,d0

	movem.l	d1-d7/a2-a6,-(a7)
	move.w	d0,d3
	moveq	#0,d4		; q1 = 0
	moveq	#0,d5		; q2 = 0
	moveq	#0,d6		; x  = 0
	moveq	#0,d7		; y  = 0
	subq.w	#1,d3

.loop	move.l	d6,d1		; D1 = oldx;
	move.l	d4,d6
	sub.l	d5,d6
	add.l	a0,d6		; x(D6) = q1(D4) - q2(D5) + acoo(A0);
	move.l	d1,d2
	bpl.b	.pos1
	neg.l	d1
.pos1	eor.l	d7,d2
	tst.l	d7
	bpl.b	.pos2
	neg.l	d7
.pos2	move.l	d1,d0
	swap	d0
	move.w	d0,d2
	mulu	d7,d0
	clr.w	d0
	swap	d0
	swap	d7
	mulu	d7,d1
	clr.w	d1
	swap	d1
	mulu	d2,d7
	add.l	d0,d7
	add.l	d1,d7
	tst.l	d2
	bpl.b	.pos3
	neg.l	d7
.pos3	moveq	#6,d0
	asl.l	d0,d7
	add.l	a1,d7	; y(D7) = 2 * oldx(D1) * y(D7) + bcoo(A1);
	moveq	#5,d0
	move.l	d7,d5
	bpl.b	.pos4
	neg.l	d5
.pos4	move.l	d5,d2
	swap	d5
	mulu	d5,d2
	clr.w	d2
	swap	d2
	mulu	d5,d5
	add.l	d2,d5
	add.l	d2,d5
	asl.l	d0,d5		; q2(D4) = y(D7)^2;
	bvs.b	.exit
	move.l	d6,d4
	bpl.b	.pos5
	neg.l	d4
.pos5	move.l	d4,d2
	swap	d4
	mulu	d4,d2
	clr.w	d2
	swap	d2
	mulu	d4,d4
	add.l	d2,d4
	add.l	d2,d4
	asl.l	d0,d4		; q1(D4) = x(D6)^2;
	bvs.b	.exit
	move.l	d4,d0
	add.l	d5,d0
	bvs.b	.exit
	cmpi.l	#536870912,d0	;$8000000 * 4
	bgt.b	.exit
	dbf	d3,.loop

	moveq	#1,d3
.exit	subq.w	#1,d3
	move.l	d3,d0
	movem.l	(a7)+,d1-d7/a2-a6

	tst.w	d0
	beq.b	.nextx

	movem.l	d2-d4/a4,-(sp)	
	move.l	d3,d2
	lsr.w	#3,d3
	add.w	d3,d4
	and.w	d7,d2
	eor.b	d6,d2
	add.l	d4,a4

	lsr.w	#1,d0
	bcc.b	.nobp0
	bset.b	d2,(a4)
.nobp0	add.w	a3,a4
	lsr.w	#1,d0
	bcc.b	.nobp1
	bset.b	d2,(a4)
.nobp1	add.w	a3,a4
	lsr.w	#1,d0
	bcc.b	.nobp2
	bset.b	d2,(a4)
.nobp2	add.w	a3,a4
	lsr.w	#1,d0
	bcc.b	.nobp3
	bset.b	d2,(a4)
.nobp3	add.w	a3,a4
	lsr.w	#1,d0
	bcc.b	.nobp4
	bset.b	d2,(a4)
.nobp4	movem.l	(sp)+,d2-d4/a4

.nextx	sub.l	d1,a0
	btst	#6,$bfe001
	beq.b	.MW
	dbra	d3,.xloop

.nexty	add.l	d2,a1
	add.w	#40,d4
	cmpi.w	#(200*40),d4
	blt.w	.yloop
	
.MW	btst	#6,$bfe001
	bne.b	.MW
	dmaoff	COPPER,RASTER
	lea	.bmap(pc),a1
	move.l	(a1),d0
	jsr	_FreeMem
	lea	.cop(pc),a1
	move.l	(a1),d0
	jsr	_FreeMem
.nomem	rts

.bmap	dc.l	0
.cop	dc.l	0
.cols	colfade	0,0,0,255,0,0,(1<<planes)/2,1
	dc.b	$ff,$bb,0
	colfade	0,0,16,0,0,255,((1<<planes)/2)-1,1


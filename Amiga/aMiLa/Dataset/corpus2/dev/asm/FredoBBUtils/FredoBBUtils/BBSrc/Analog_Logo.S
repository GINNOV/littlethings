* Analog BootIntro
* Resourced by Frédo '97

lb_0000
	dc.b	'dos',0
	dc.l	0,$370
start:
	move.l	4.w,a6

	movem.l	d1-d7/a1-a5,-(a7)
	jsr	-$0084(a6)
	jsr	-$0078(a6)
	lea	$00dff056,a5
	lea	$0003fffc,a0
	moveq	#-$01,d7
lb_0026	clr.l	(a0)+
	dbf	d7,lb_0026
	lea	(a0),a2
	lea	lb_026e(pc),a3
	move	#$0080,$000a(a5)
	move.l	d7,-$0012(a5)
	move.l	#$ffff8000,$001c(a5)
	moveq	#$06,d0
	move	d0,-$0006(a5)
	move	d0,-$000e(a5)
	move	d0,-$0002(a5)
	lea	lb_03d0(pc),a0
	move.l	a0,$002e(a5)
	clr	$0034(a5)
	move	#$87c0,$0040(a5)
	movem	(a3),d0-d7
	lea	lb_027d(pc),a0
lb_006c	move.b	(a0)+,d1
	bne	lb_0104
	addq	#2,a0
	move.l	#$09f0000a,-$0016(a5)
	moveq	#-$02,d0
	move	d0,-$0004(a5)
	move	d0,(a5)
	move.l	d1,$000e(a5)
	move	#$8000,$0002(a5)
	lea	$0005420c,a2
	lea	$3bfc(a2),a3
	move	#$0100,d4
	move.b	#$a2,(a0)
lb_00a0	btst	#$06,$00bfe001
	beq.b	lb_00e4
lb_00aa	move.l	-$0052(a5),d2
	lsr.l	#8,d2
	andi	#$01ff,d2
	cmpi	#$000a,d2
	bne.b	lb_00aa
	lea	$012a(a5),a4
	move.l	#$0fff0000,(a4)+
	move.l	#$0ccc0000,(a4)
	movem.l	a2/a3,$008a(a5)
	adda	#$0182,a2
	adda	#$0102,a3
lb_00d8	cmpi.b	#$0b,-$0050(a5)
	bne.b	lb_00d8
	dbf	d4,lb_00a0
lb_00e4	clr.b	(a0)
	movem.l	(a7)+,d1-d7/a1-a5
	lea	lb_03f4(pc),a1
	jsr	-$0060(a6)
	move.l	d0,a0
	move.l	$0016(a0),a0
	jsr	-$007e(a6)
	jsr	-$008a(a6)
	moveq	#$00,d0
	rts	
lb_0104	add	d1,-$00d0(a3)
	move.b	(a0)+,-$00cb(a3)
lb_010c	move.b	(a0)+,d7
	beq	lb_006c
	bpl.b	lb_0118
	move.b	(a0)+,d0
	move.b	(a0)+,d1
lb_0118	move.b	d7,(a2)
	andi	#$001f,d7
lb_011e	btst	#$06,(a2)
	beq.b	lb_0130
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	bsr.b	lb_018a
	btst	#$05,(a2)
	beq.b	lb_0184
lb_0130	move	d7,-(a7)
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	move.b	(a0)+,d4
	move.b	(a0)+,d5
	move.b	(a0)+,d6
	move.b	(a0)+,d7
	lea	lb_0222(pc),a4
	lea	(a3),a1
	movem	d0-d7,(a3)
lb_0148	movem	d0/d1,-(a7)
	movem	(a3),d0-d7
	mulu	(a4),d0
	mulu	(a4)+,d1
	mulu	(a4),d2
	mulu	(a4)+,d3
	mulu	-(a1),d4
	mulu	(a1),d5
	mulu	-(a1),d6
	mulu	(a1),d7
	add.l	d0,d2
	add.l	d4,d2
	add.l	d6,d2
	swap	d2
	add.l	d1,d3
	add.l	d5,d3
	add.l	d7,d3
	swap	d3
	movem	(a7)+,d0/d1
	bsr.b	lb_018a
	cmpa.l	a3,d4
	bcs.b	lb_0148
	movem	$000c(a3),d2/d3
	bsr.b	lb_018a
	move	(a7)+,d7
lb_0184	dbf	d7,lb_011e
	bra.b	lb_010c
lb_018a	movem	d2/d3,-(a7)
	cmp	d1,d3
	bhi.b	lb_0198
	beq.b	lb_0208
	exg	d0,d2
	exg	d1,d3
lb_0198	move	d0,d5
	move	d1,d6
	addi	#$0000,d5
lb_019e=*-2
	addi	#$0000,d6
	mulu	#$0080,d6
	lsr	#3,d5
	add	d5,d6
	moveq	#$00,d4
	sub	d1,d3
	sub	d0,d2
	bpl.b	lb_01b8
	moveq	#$02,d4
	neg	d2
lb_01b8	move	d3,d1
	add	d1,d1
	cmp	d2,d1
	dbhi	d3,lb_01c2
lb_01c2	move	d3,d1
	sub	d2,d1
	bpl.b	lb_01cc
	exg	d2,d3
	addq	#1,d4
lb_01cc	add	d2,d2
	move	d2,d1
	sub	d3,d2
	addx	d4,d4
	add	lb_019e(pc),d0
	andi	#$000f,d0
	ror	#4,d0
	ori	#$0b4a,d0
	bsr.b	lb_0210
	move	d2,-$0004(a5)
	sub	d3,d2
	lsl	#6,d3
	addq	#2,d3
	move	d0,-$0016(a5)
	move.b	lb_021a(pc,d4.l),-$0013(a5)
	move	d6,-$000c(a5)
	move	d6,(a5)
	movem	d1/d2,$000c(a5)
	move	d3,$0002(a5)
lb_0208	movem	(a3),d2-d6
	movem	(a7)+,d0/d1
lb_0210	btst	#$0e,-$0054(a5)
	bne.b	lb_0210
	rts	
lb_021a
	dc.b	$03,$43,$13,$53,$0b,$4b,$17,$57
lb_0222	dc.b	$db,$7d,$22,$a8,$ba,$a0,$3e,$35
	dc.b	$9d,$37,$53,$3b,$83,$12,$62,$4e
	dc.b	$6c,$00,$6c,$00,$57,$cf,$70,$e5
	dc.b	$46,$4e,$71,$91,$37,$4c,$6e,$98
	dc.b	$2a,$98,$68,$8b,$20,$00,$60,$00
	dc.b	$17,$54,$55,$89,$10,$62,$49,$ba
	dc.b	$0a,$fa,$3d,$27,$06,$e9,$30,$62
	dc.b	$04,$00,$24,$00,$02,$0c,$18,$93
	dc.b	$00,$dd,$0e,$b0,$00,$42,$06,$e9
	dc.b	$00,$08,$01,$d3
lb_026e
	dc.b	$00,$a9,$00,$41,$00,$6e,$00,$61
	dc.b	$00,$6c,$00,$6f,$00,$67
lb_027c
	dc.b	$00
lb_027d	dc.b	$04,$03,$c7
lb_0280
	dc.b	$02,$e4,$53,$1b,$97,$1b,$e5,$e4
	dc.b	$a6,$e4,$99,$bf,$4a,$bf,$3d,$e4
	dc.b	$02,$e4,$c2,$57,$95,$72,$44,$8a
	dc.b	$95,$57,$95,$00,$e8,$1f,$e1,$04
	dc.b	$c8,$04,$58,$04,$49,$04,$49,$02
	dc.b	$3a,$39,$3a,$3b,$43,$3b,$43,$3b
	dc.b	$4b,$21,$44,$40,$51,$38,$64,$38
	dc.b	$76,$38,$9b,$3e,$9b,$63,$41,$9b
	dc.b	$c8,$67,$c8,$60,$67,$73,$67,$4d
	dc.b	$3b,$52,$3b,$70,$41,$3b,$c8,$04
	dc.b	$c8,$00
lb_02d2
	dc.b	$9e,$21,$e0,$41,$63,$0d,$63,$0d
	dc.b	$42,$2b,$35,$53,$35,$20,$76,$35
	dc.b	$94,$42,$94,$5d,$61,$94,$a5,$94
	dc.b	$ae,$94,$b8,$99,$c6,$64,$c6,$62
	dc.b	$bf,$62,$bf,$62,$b4,$24,$5e,$bd
	dc.b	$51,$ca,$39,$ca,$08,$ca,$02,$ae
	dc.b	$02,$9a,$04,$72,$32,$6a,$62,$6a
	dc.b	$62,$5a,$62,$4d,$53,$4d,$44,$4d
	dc.b	$41,$5a,$41,$63,$a2,$62,$84,$62
	dc.b	$8f,$62,$9c,$59,$a5,$4a,$b4,$34
	dc.b	$a3,$39,$93,$3b,$86,$53,$84,$62
	dc.b	$84,$00,$9c,$03,$c3,$02,$1b,$36
	dc.b	$1b,$36,$e4,$02,$e4,$02,$1b,$00
	dc.b	$39,$21,$a3,$53,$35,$83,$35,$a6
	dc.b	$4b,$a6,$7b,$a6
lb_0346
	dc.b	$b8,$76,$ca,$53,$ca,$23,$ca,$02
	dc.b	$ab,$02,$7d,$04,$58,$16,$35,$53
	dc.b	$35,$a3,$53,$54,$69,$54,$6d,$6a
	dc.b	$6d,$7d,$6d,$8f,$69,$a9,$53,$a9
	dc.b	$44,$a9,$39,$9a,$39,$7b,$39,$63
	dc.b	$41,$54,$53,$54,$00,$a9,$3b,$c2
	dc.b	$6f,$33,$72,$1f,$a6,$1f,$a6,$9c
	dc.b	$21,$a6,$d7,$74,$e4,$51,$e2,$39
	dc.b	$e2,$0b,$db,$0b,$b2,$60,$3f,$b2
	dc.b	$3f,$ba,$44,$c1,$53,$c3,$24,$72
	dc.b	$c3,$6f,$ab,$6f,$91,$67,$a0,$53
	dc.b	$a7,$41,$a7,$1c,$a7,$02,$88,$02
	dc.b	$61,$02,$39,$1c
lb_03aa
	dc.b	$1b,$41,$1b,$5a,$1b,$67,$21,$6f
	dc.b	$33,$a3,$55,$39,$67,$39,$6f,$4d
	dc.b	$6f,$5f,$6f,$77,$69,$86,$55,$86
	dc.b	$46,$86,$3b,$79,$3b,$61,$3b,$40
	dc.b	$4c,$39,$55,$39,$00,$00
lb_03d0
	dc.b	$01,$00
	dc.b	$82,$00,$01,$02,$00,$00,$01,$08
	dc.b	$00,$28,$01,$0a,$00,$28,$00,$8e
	dc.b	$1a,$71,$00,$90,$3c,$d1,$00,$92
	dc.b	$00,$30,$00,$94,$00,$d8,$ff,$ff
	dc.b	$ff,$fe
lb_03f4
	dc.b	$64,$6f,$73,$2e,$6c,$69,$62,$72
	dc.b	$61,$72,$79,$00
lb_0400

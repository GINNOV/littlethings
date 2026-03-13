;L531	move.l	d6,d0
;	asl.l	#$2,d0
;	movea.l	$00(a3,d0.l),a0
;	lea	L496(pc),a1
;	jsr	L1248(pc)
;	tst.w	d0
;	bne.s	L532
;	st	-$2520(a4)
;	addq.w	#$1,d6
;	move.l	d6,d0
;	asl.l	#$2,d0
;	movea.l	$00(a3,d0.l),a0
;	jsr	L626(pc)
;	bra.l	L553
;
;
;	movea.l	-$254c(a4),a0
;	jsr	E630(pc)
;
;
;
;	move.w	$0150(a4),d0
;	move.l	-$254c(a4),a0
;	bsr	E633

;	lea	PassWrd(pc),a0
;	bsr	l626

	lea	$1a004c,a0
	move.l	#$2c00,d0
	bsr	E630

	

	rts

;--------------------------------------;

FndEVal	move.l	a0,a3
	clr.w	EncrVal
.1	tst.b	(a3)
	beq.s	.2
	move.w	EncrVal(pc),d0
	move.l	d0,d1
	lsr.w	#8,d1
	and.w	#$ff,d1
	moveq	#0,d2
	move.b	(a3)+,d2
	eor.w	d2,d0
	and.w	#$ff,d0
	moveq	#0,d2
	move.w	d0,d2
	add.l	d2,d2
	lea	CRCTble(pc),a0
	move.w	(a0,d2),d0
	eor.w	d0,d1
	move.w	d1,EncrVal
	bra.s	.1
.2	rts

;--------------------------------------;

E630	move.l	a0,a3
	move.l	d0,d7
E631	move.l	d7,d0
	subq.w	#1,d7
	tst.w	d0
	beq	E632
	moveq	#$00,d0
	move.b	(a3),d0
	move.w	EncrVal(pc),d1
	eor.w	d1,d0
	move.b	d0,(a3)
	move.w	EncrVal(pc),d1
	lsr.w	#1,d1
	move.w	d1,EncrVal
	moveq	#0,d0
	move.b	(a3)+,d0
	add.w	d0,EncrVal
	bra	E631
E632	rts

;--------------------------------------;

E633	move.l	a0,a3
	move.l	d0,d7
E634	move.l	d7,d0
	subq.w	#1,d7
	tst.w	d0
	beq.s	E635
	move.b	(a3),d6
	moveq	#0,d0
	move.b	(a3),d0
	move.w	EncrVal(pc),d1
	eor.w	d1,d0
	move.b	d0,(a3)+
	move.w	EncrVal(pc),d0
	lsr.w	#1,d0
	move.w	d0,EncrVal
	moveq	#0,d0
	move.b	d6,d0
	add.w	d0,EncrVal
	bra.s	E634
E635	rts

;--------------------------------------;

E636	moveq	#1,d0
	rts

EncrVal	dc.w	$d015
PassWrd	dc.b	"ROB",0

CRCTble	dc.l	$0000c0c1,$c1810140,$c30103c0,$0280c241
	dc.l	$c60106c0,$0780c741,$0500c5c1,$c4810440
	dc.l	$cc010cc0,$0d80cd41,$0f00cfc1,$ce810e40
	dc.l	$0a00cac1,$cb810b40,$c90109c0,$0880c841
	dc.l	$d80118c0,$1980d941,$1b00dbc1,$da811a40
	dc.l	$1e00dec1,$df811f40,$dd011dc0,$1c80dc41
	dc.l	$1400d4c1,$d5811540,$d70117c0,$1680d641
	dc.l	$d20112c0,$1380d341,$1100d1c1,$d0811040
	dc.l	$f00130c0,$3180f141,$3300f3c1,$f2813240
	dc.l	$3600f6c1,$f7813740,$f50135c0,$3480f441
	dc.l	$3c00fcc1,$fd813d40,$ff013fc0,$3e80fe41
	dc.l	$fa013ac0,$3b80fb41,$3900f9c1,$f8813840
	dc.l	$2800e8c1,$e9812940,$eb012bc0,$2a80ea41
	dc.l	$ee012ec0,$2f80ef41,$2d00edc1,$ec812c40
	dc.l	$e40124c0,$2580e541,$2700e7c1,$e6812640
	dc.l	$2200e2c1,$e3812340,$e10121c0,$2080e041
	dc.l	$a00160c0,$6180a141,$6300a3c1,$a2816240
	dc.l	$6600a6c1,$a7816740,$a50165c0,$6480a441
	dc.l	$6c00acc1,$ad816d40,$af016fc0,$6e80ae41
	dc.l	$aa016ac0,$6b80ab41,$6900a9c1,$a8816840
	dc.l	$7800b8c1,$b9817940,$bb017bc0,$7a80ba41
	dc.l	$be017ec0,$7f80bf41,$7d00bdc1,$bc817c40
	dc.l	$b40174c0,$7580b541,$7700b7c1,$b6817640
	dc.l	$7200b2c1,$b3817340,$b10171c0,$7080b041
	dc.l	$500090c1,$91815140,$930153c0,$52809241
	dc.l	$960156c0,$57809741,$550095c1,$94815440
	dc.l	$9c015cc0,$5d809d41,$5f009fc1,$9e815e40
	dc.l	$5a009ac1,$9b815b40,$990159c0,$58809841
	dc.l	$880148c0,$49808941,$4b008bc1,$8a814a40
	dc.l	$4e008ec1,$8f814f40,$8d014dc0,$4c808c41
	dc.l	$440084c1,$85814540,$870147c0,$46808641
	dc.l	$820142c0,$43808341,$410081c1,$80814040


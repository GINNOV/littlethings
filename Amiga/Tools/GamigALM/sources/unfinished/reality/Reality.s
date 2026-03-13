Address	= $1a0000

	JMP	Address
	ORG	Address
	LOAD	Address

Start	lea	$00dff000,a5
	move.w	$0002(a5),d0
	bset	#$0f,d0
	move.w	d0,-(a7)
	move.w	$001c(a5),d0
	bset	#$0f,d0
	move.w	d0,-(a7)
	move.w	#$7fff,$0096(a5)
	move.w	#$7fff,$009a(a5)
	move.l   ($006c).w,-(a7)
	clr.l    ($0000).w
	bsr.l	L2
	move.w	#$7fff,$0096(a5)
	move.w	#$7fff,$009a(a5)
	move.l   (a7)+,($006c).w
	move.w	(a7)+,$009a(a5)
	move.w	(a7)+,$0096(a5)
	movea.l  ($0004).w,a6
	lea	L1,a1
	moveq	#$00,d0
	jsr	-$0228(a6)
	movea.l	d0,a1
	move.l	$0026(a1),$0080(a5)
	jsr	-$019e(a6)
	moveq	#$00,d0
	rts	

L1	dc.b	'graphics.library',$00
	dc.b	$00

L2	bsr.l	L18
	bsr.l	L7
	bsr.l	L20
	bsr.l	L23
	move.w	#-$7820,$0096(a5)
	movea.l	L16,a0
	bsr.l	L85
	move.l   #L27,($006c).w
	move.w	#$0020,$009c(a5)
	move.w	#-$3fe0,$009a(a5)
L3	movea.l	L14,a0
L4	bsr.l	L48
	move.w	#$0190,L30
L5	btst	#$06,$00bfe001
	beq.s	L6
	tst.w	L30
	bne.s	L5
	cmpi.b	#$5c,(a0)
	bne.s	L4
	bra.s	L3

L6	bsr.l	L89
	rts	

L7	lea	DatList,a0
	lea	L12,a1
	move.l	a0,d1
	move.w	#$0004,d7
L8	move.l	(a0)+,d0
	add.l	d1,d0
	move.l	d0,(a1)+
	dbf	d7,L8

	move.w	(a0)+,d6
	move.w	d6,L17
	moveq	#1,d7
	lsl.w	d6,d7
	subq.w	#1,d7
	lea	L152,a1
L9	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbf	d7,L9

	move.l	a0,L11

	ror.w	#4,d6
	or.w	d6,L155

	movea.l	L13,a0
	move.w	#$0007,d7
	lea	L163,a1
L10	move.w	(a0)+,(a1)
	addq.l	#4,a1
	dbf	d7,L10
	move.l	a0,L13
	move.l	L15,L42
	rts	

L11	dcb.b	4,$00
L12	dcb.b	4,$00
L13	dcb.b	4,$00
L14	dcb.b	4,$00
L15	dcb.b	4,$00
L16	dcb.b	4,$00
L17	dcb.b	2,$00

L18	lea	$4a000,a0
	move.w	#$2b6d,d7
L19	clr.w	(a0)+
	dbf	d7,L19
	rts	

L20	lea	L154,a0
	move.l	L11,d0
	move.w	L17,d7
	subq.w	#1,d7
L21	swap	d0
	move.w	d0,2(a0)
	swap	d0
	move.w	d0,6(a0)
	addq.w	#8,a0
	add.l	#80*(320/8),d0
	dbf	d7,L21

	lea	L159,a0
	move.l	#$0014b388,d0
	swap	d0
	move.w	d0,$0002(a0)
	swap	d0
	move.w	d0,$0006(a0)
	addi.l	#$000014c8,d0
	swap	d0
	move.w	d0,$0012(a0)
	swap	d0
	move.w	d0,$0016(a0)
	addi.l	#$000014c8,d0
	swap	d0
	move.w	d0,$000a(a0)
	swap	d0
	move.w	d0,$000e(a0)

	lea	L164,a0
	move.l	#$0014f2ec,d0
	move.w	#$0002,d7
L22	swap	d0
	move.w	d0,$0002(a0)
	swap	d0
	move.w	d0,$0006(a0)
	addq.w	#$8,a0
	addi.l	#$00000150,d0
	dbf	d7,L22

	lea	L153,a0
	move.l	#L168,d0
	move.w	d0,$0006(a0)
	swap	d0
	move.w	d0,$0002(a0)
	move.l	#L169,d0
	move.w	d0,$000e(a0)
	swap	d0
	move.w	d0,$000a(a0)
	move.l	#L151,$0080(a5)
	clr.w	$0088(a5)
	rts	

L23	lea	$0014a000,a0
	move.w	#$0095,d7
L24	clr.w	(a0)+
	clr.l	(a0)+
	bsr.l	L25
	andi.w	#$01ff,d0
	move.w	d0,(a0)+
	bsr.l	L25
	andi.w	#$007f,d0
	move.w	d0,(a0)+
	bsr.l	L25
	andi.w	#$03ff,d0
	move.w	d0,(a0)+
	dbf	d7,L24
	rts	

L25	move.w	L26,d0
	mulu	#12345,d0
	move.w	d0,L26
	eor.w	#42025,d0
	addq.w	#1,L26
	rts	

L26	dc.b	$00,$7b
L27	dc.b	$48,$e7,$ff,$fe

	bsr.l	E31
	bsr.l	E33
	bsr.l	E43
	bsr.l	E69
	tst.w	L51
	beq.s	E28
	bsr.l	E53
E28	tst.w	L30
	beq.s	E29
	subq.w	#$1,L30
E29	bsr.l	E90
	move.w	#$0020,$00dff09c
	movem.l	(a7)+,d0-d7/a0-a6
	rte	

L30	dc.b	$00,$00

E31	move.w	L32,d0
	addq.w	#$8,d0
	andi.w	#$00fe,d0
	move.w	d0,L32
	lea	L84,a0
	move.w	$00(a0,d0.w),d1
	muls	#$0036,d1
	swap	d1
	addi.w	#$001b,d1
	moveq	#$37,d0
	sub.w	d1,d0
	addq.b	#$1,d0
	move.b	d0,L165
	addq.b	#$7,d0
	move.b	d0,L166
	rts	

L32	dc.b	$00,$00,$00,$1e

E33	btst	#$06,$0002(a5)
	bne.s	E33
	move.l	#-$06100000,$0040(a5)
	move.l	#-$00000001,$0044(a5)
	move.l	#$0014f2ec,$0050(a5)
	move.l	#$0014f2ea,$0054(a5)
	clr.l	$0064(a5)
	move.w	#$0615,$0058(a5)
	subq.w	#$1,L41
	bne.l	E40
	move.w	#$0008,L41
	movea.l	L42,a0
	moveq	#$00,d0
	move.b	(a0)+,d0
	bne.s	E34
	movea.l	L15,a0
	move.b	#$20,d0
E34	cmpi.b	#$0a,d0
	bne.s	E35
	move.b	#$20,d0
E35	cmpi.b	#$61,d0
	bcs.s	E36
	subi.b	#$20,d0
E36	move.l	a0,L42
	subi.b	#$20,d0
	add.w	d0,d0
	lea	L167,a0
	movea.l	L13,a1
	adda.w	$00(a0,d0.w),a1
E37	btst	#$06,$0002(a5)
	bne.s	E37
	move.w	#$09f0,$0040(a5)
	move.l	#$00260028,$0064(a5)
	move.l	a1,$0050(a5)
	move.l	#$0014f314,$0054(a5)
	move.w	#$0201,$0058(a5)
	adda.w	#$0348,a1
E38	btst	#$06,$0002(a5)
	bne.s	E38
	move.l	a1,$0050(a5)
	move.l	#$0014f464,$0054(a5)
	move.w	#$0201,$0058(a5)
	adda.w	#$0348,a1
E39	btst	#$06,$0002(a5)
	bne.s	E39
	move.l	a1,$0050(a5)
	move.l	#$0014f5b4,$0054(a5)
	move.w	#$0201,$0058(a5)
E40	rts	

L41	dc.b	$00,$08
L42	dc.b	$00,$00,$00,$00

E43	btst	#$06,$0002(a5)
	bne.s	E43
	move.l	#$09f00000,$0040(a5)
	move.l	#-$00000001,$0044(a5)
	move.l	#$00020002,$0064(a5)
	move.l	#L157,$0050(a5)
	move.l	#L156,$0054(a5)
	move.w	#$0d01,$0058(a5)
E44	btst	#$06,$0002(a5)
	bne.s	E44
	move.l	#-$00050006,$0064(a5)
	move.l	#L161,$0050(a5)
	move.l	#L162,$0054(a5)
	move.w	#$0d01,$0058(a5)
E45	btst	#$06,$0002(a5)
	bne.s	E45
	movea.l	L81,a0
	move.w	(a0)+,d0
	bne.s	E46
	lea	L83,a0
	move.w	(a0)+,d0
E46	move.w	d0,L158
	move.l	a0,L81
	movea.l	L82,a0
	move.w	(a0)+,d0
	bne.s	E47
	lea	L83,a0
	move.w	(a0)+,d0
E47	move.w	d0,L160
	move.l	a0,L82
	rts	

L48	clr.b	L49
	move.b	#$27,L50
	move.l	#$0014a708,L52
	bsr.l	L58
	move.w	#-$0001,L51
	rts	

L49	dcb.b	1,$00
L50	dcb.b	1,$00
L51	dcb.b	2,$00
L52	dcb.b	4,$00

E53	tst.b	L49
	beq.s	E55
	subq.b	#$1,L49
E54	btst	#$06,$0002(a5)
	bne.s	E54
	move.l	#-$76100000,$0040(a5)
	move.l	#-$00000001,$0044(a5)
	clr.l	$0064(a5)
	move.l	#$0014dd98,$0050(a5)
	move.l	#$0014dd96,$0054(a5)
	move.w	#$2015,$0058(a5)
	rts	

E55	move.b	#$01,L49
	tst.b	L50
	beq.s	E57
	subq.b	#$1,L50
	movea.l	L52,a0
	lea	$0014ddbe,a1
	move.w	#$000f,d7
E56	movea.l	(a0)+,a2
	move.b	(a2),(a1)
	move.b	$0028(a2),$002a(a1)
	move.b	$0050(a2),$0054(a1)
	move.b	$0078(a2),$007e(a1)
	move.b	$00a0(a2),$00a8(a1)
	move.b	$00c8(a2),$00d2(a1)
	move.b	$00f0(a2),$00fc(a1)
	clr.b	$0126(a1)
	adda.w	#$0150,a1
	dbf	d7,E56
	move.l	a0,L52
	bra.l	E53

E57	clr.w	L51
	rts	

L58	lea	$0014b108,a1
	move.w	#$009f,d7
L59	move.l	#$20202020,(a1)+
	dbf	d7,L59
	lea	$0014b108,a1
L60	moveq	#$00,d0
	movea.l	a1,a2
	move.w	#$0027,d7
	bra.s	L62

L61	addq.w	#$1,d0
L62	cmpi.b	#$0a,$00(a0,d0.w)
	dbeq	d7,L61
	move.w	d0,d2
	lsr.w	#$1,d0
	moveq	#$14,d1
	sub.w	d0,d1
	adda.w	d1,a2
	bra.s	L64

L63	move.b	(a0)+,(a2)+
L64	dbf	d2,L63
	adda.w	#$0028,a1
L65	cmpi.b	#$0a,(a0)+
	bne.s	L65
	cmpi.b	#$5c,(a0)
	bne.s	L60
	addq.w	#$2,a0
	lea	$0014b108,a1
	lea	$0014a708,a2
	lea	L150,a3
	move.w	#$0027,d7
L66	move.w	#$000f,d6
	moveq	#$00,d0
L67	move.b	$00(a1,d0.w),d1
	cmpi.b	#$61,d1
	bcs.s	L68
	subi.b	#$20,d1
L68	subi.b	#$20,d1
	ext.w	d1
	add.w	d1,d1
	move.w	$00(a3,d1.w),d2
	movea.l	L12,a4
	adda.w	d2,a4
	move.l	a4,(a2)+
	addi.w	#$0028,d0
	dbf	d6,L67
	addq.w	#$1,a1
	dbf	d7,L66
	rts	

E69	move.w	L70,d0
	addq.w	#$2,d0
	andi.w	#$01fe,d0
	move.w	d0,L70
	lea	L84,a0
	move.w	$00(a0,d0.w),d2
	lea	$0080(a0),a0
	move.w	$00(a0,d0.w),d0
	muls	#$0190,d0
	swap	d0
	addi.w	#$00c8,d0
	muls	#$03e8,d2
	swap	d2
	addi.w	#$01f4,d2
	move.w	L71,d1
	subq.w	#$3,L71
	bsr.l	E72
	rts	

L70	dc.b	$00,$00
L71	dc.b	$00,$00

E72	lea	$0014a000,a0
	lea	L78,a1
	lea	L79,a2
	lea	L80,a3
	moveq	#$0a,d6
	move.w	#$0095,d7
E73	move.w	(a0)+,d3
	move.l	(a0)+,d4
	beq.s	E74
	movea.l	d4,a4
	and.w	d3,(a4)
	and.w	d3,$14c8(a4)
E74	movem.w	(a0)+,d3-d5
	add.w	d0,d3
	andi.w	#$01ff,d3
	subi.w	#$00a0,d3
	add.w	d1,d4
	andi.w	#$007f,d4
	subi.w	#$0042,d4
	add.w	d2,d5
	andi.w	#$03ff,d5
	move.w	d5,-(a7)
	addi.w	#$0200,d5
	ext.l	d3
	ext.l	d4
	asl.l	d6,d3
	asl.l	d6,d4
	divs	d5,d3
	divs	d5,d4
	addi.w	#$00a0,d3
	addi.w	#$0042,d4
	cmpi.w	#$0140,d3
	bcc.s	E77
	cmpi.w	#$0085,d4
	bcc.s	E77
	add.w	d3,d3
	add.w	d4,d4
	move.w	$00(a2,d4.w),d4
	add.w	$00(a1,d3.w),d4
	lea	$0014b388,a4
	adda.w	d4,a4
	andi.w	#$001e,d3
	move.w	$00(a3,d3.w),d5
	move.w	$20(a3,d3.w),d3
	move.w	(a7)+,d4
	or.w	d5,(a4)
	btst	#$08,d4
	bne.s	E75
	and.w	d3,(a4)
E75	or.w	d5,$14c8(a4)
	btst	#$09,d4
	bne.s	E76
	and.w	d3,$14c8(a4)
E76	move.w	d3,-$000c(a0)
	move.l	a4,-$000a(a0)
	dbf	d7,E73
	rts	

E77	addq.w	#$2,a7
	clr.l	-$000a(a0)
	dbf	d7,E73
	rts	

L78	dcb.b	33,$00
	dc.b	$02,$00,$02,$00,$02,$00
	dc.b	$02,$00,$02,$00,$02,$00
	dc.b	$02,$00,$02,$00,$02,$00
	dc.b	$02,$00,$02,$00,$02,$00
	dc.b	$02,$00,$02,$00,$02,$00
	dc.b	$02,$00,$04,$00,$04,$00
	dc.b	$04,$00,$04,$00,$04,$00
	dc.b	$04,$00,$04,$00,$04,$00
	dc.b	$04,$00,$04,$00,$04,$00
	dc.b	$04,$00,$04,$00,$04,$00
	dc.b	$04,$00,$04,$00,$06,$00
	dc.b	$06,$00,$06,$00,$06,$00
	dc.b	$06,$00,$06,$00,$06,$00
	dc.b	$06,$00,$06,$00,$06,$00
	dc.b	$06,$00,$06,$00,$06,$00
	dc.b	$06,$00,$06,$00,$06,$00
	dc.b	$08,$00,$08,$00,$08,$00
	dc.b	$08,$00,$08,$00,$08,$00
	dc.b	$08,$00,$08,$00,$08,$00
	dc.b	$08,$00,$08,$00,$08,$00
	dc.b	$08,$00,$08,$00,$08,$00
	dc.b	$08,$00,$0a,$00,$0a,$00
	dc.b	$0a,$00,$0a,$00,$0a,$00
	dc.b	$0a,$00,$0a,$00,$0a,$00
	dc.b	$0a,$00,$0a,$00,$0a,$00
	dc.b	$0a,$00,$0a,$00,$0a,$00
	dc.b	$0a,$00,$0a,$00,$0c,$00
	dc.b	$0c,$00,$0c,$00,$0c,$00
	dc.b	$0c,$00,$0c,$00,$0c,$00
	dc.b	$0c,$00,$0c,$00,$0c,$00
	dc.b	$0c,$00,$0c,$00,$0c,$00
	dc.b	$0c,$00,$0c,$00,$0c,$00
	dc.b	$0e,$00,$0e,$00,$0e,$00
	dc.b	$0e,$00,$0e,$00,$0e,$00
	dc.b	$0e,$00,$0e,$00,$0e,$00
	dc.b	$0e,$00,$0e,$00,$0e,$00
	dc.b	$0e,$00,$0e,$00,$0e,$00
	dc.b	$0e,$00,$10,$00,$10,$00
	dc.b	$10,$00,$10,$00,$10,$00
	dc.b	$10,$00,$10,$00,$10,$00
	dc.b	$10,$00,$10,$00,$10,$00
	dc.b	$10,$00,$10,$00,$10,$00
	dc.b	$10,$00,$10,$00,$12,$00
	dc.b	$12,$00,$12,$00,$12,$00
	dc.b	$12,$00,$12,$00,$12,$00
	dc.b	$12,$00,$12,$00,$12,$00
	dc.b	$12,$00,$12,$00,$12,$00
	dc.b	$12,$00,$12,$00,$12,$00
	dc.b	$14,$00,$14,$00,$14,$00
	dc.b	$14,$00,$14,$00,$14,$00
	dc.b	$14,$00,$14,$00,$14,$00
	dc.b	$14,$00,$14,$00,$14,$00
	dc.b	$14,$00,$14,$00,$14,$00
	dc.b	$14,$00,$16,$00,$16,$00
	dc.b	$16,$00,$16,$00,$16,$00
	dc.b	$16,$00,$16,$00,$16,$00
	dc.b	$16,$00,$16,$00,$16,$00
	dc.b	$16,$00,$16,$00,$16,$00
	dc.b	$16,$00,$16,$00,$18,$00
	dc.b	$18,$00,$18,$00,$18,$00
	dc.b	$18,$00,$18,$00,$18,$00
	dc.b	$18,$00,$18,$00,$18,$00
	dc.b	$18,$00,$18,$00,$18,$00
	dc.b	$18,$00,$18,$00,$18,$00
	dc.b	$1a,$00,$1a,$00,$1a,$00
	dc.b	$1a,$00,$1a,$00,$1a,$00
	dc.b	$1a,$00,$1a,$00,$1a,$00
	dc.b	$1a,$00,$1a,$00,$1a,$00
	dc.b	$1a,$00,$1a,$00,$1a,$00
	dc.b	$1a,$00,$1c,$00,$1c,$00
	dc.b	$1c,$00,$1c,$00,$1c,$00
	dc.b	$1c,$00,$1c,$00,$1c,$00
	dc.b	$1c,$00,$1c,$00,$1c,$00
	dc.b	$1c,$00,$1c,$00,$1c,$00
	dc.b	$1c,$00,$1c,$00,$1e,$00
	dc.b	$1e,$00,$1e,$00,$1e,$00
	dc.b	$1e,$00,$1e,$00,$1e,$00
	dc.b	$1e,$00,$1e,$00,$1e,$00
	dc.b	$1e,$00,$1e,$00,$1e,$00
	dc.b	$1e,$00,$1e,$00,$1e,$00
	dc.b	$20,$00,$20,$00,$20,$00
	dc.b	$20,$00,$20,$00,$20,$00
	dc.b	$20,$00,$20,$00,$20,$00
	dc.b	$20,$00,$20,$00,$20,$00
	dc.b	$20,$00,$20,$00,$20,$00
	dc.b	$20,$00,$22,$00,$22,$00
	dc.b	$22,$00,$22,$00,$22,$00
	dc.b	$22,$00,$22,$00,$22,$00
	dc.b	$22,$00,$22,$00,$22,$00
	dc.b	$22,$00,$22,$00,$22,$00
	dc.b	$22,$00,$22,$00,$24,$00
	dc.b	$24,$00,$24,$00,$24,$00
	dc.b	$24,$00,$24,$00,$24,$00
	dc.b	$24,$00,$24,$00,$24,$00
	dc.b	$24,$00,$24,$00,$24,$00
	dc.b	$24,$00,$24,$00,$24,$00
	dc.b	$26,$00,$26,$00,$26,$00
	dc.b	$26,$00,$26,$00,$26,$00
	dc.b	$26,$00,$26,$00,$26,$00
	dc.b	$26,$00,$26,$00,$26,$00
	dc.b	$26,$00,$26,$00,$26,$00
	dc.b	$26
L79	dc.b	$00,$00,$00,$28,$00,$50
	dc.b	$00,$78,$00,$a0,$00,$c8
	dc.b	$00,$f0,$01,$18,$01,$40
	dc.b	$01,$68,$01,$90,$01,$b8
	dc.b	$01,$e0,$02,$08,$02,$30
	dc.b	$02,$58,$02,$80,$02,$a8
	dc.b	$02,$d0,$02,$f8,$03,$20
	dc.b	$03,$48,$03,$70,$03,$98
	dc.b	$03,$c0,$03,$e8,$04,$10
	dc.b	$04,$38,$04,$60,$04,$88
	dc.b	$04,$b0,$04,$d8,$05,$00
	dc.b	$05,$28,$05,$50,$05,$78
	dc.b	$05,$a0,$05,$c8,$05,$f0
	dc.b	$06,$18,$06,$40,$06,$68
	dc.b	$06,$90,$06,$b8,$06,$e0
	dc.b	$07,$08,$07,$30,$07,$58
	dc.b	$07,$80,$07,$a8,$07,$d0
	dc.b	$07,$f8,$08,$20,$08,$48
	dc.b	$08,$70,$08,$98,$08,$c0
	dc.b	$08,$e8,$09,$10,$09,$38
	dc.b	$09,$60,$09,$88,$09,$b0
	dc.b	$09,$d8,$0a,$00,$0a,$28
	dc.b	$0a,$50,$0a,$78,$0a,$a0
	dc.b	$0a,$c8,$0a,$f0,$0b,$18
	dc.b	$0b,$40,$0b,$68,$0b,$90
	dc.b	$0b,$b8,$0b,$e0,$0c,$08
	dc.b	$0c,$30,$0c,$58,$0c,$80
	dc.b	$0c,$a8,$0c,$d0,$0c,$f8
	dc.b	$0d,$20,$0d,$48,$0d,$70
	dc.b	$0d,$98,$0d,$c0,$0d,$e8
	dc.b	$0e,$10,$0e,$38,$0e,$60
	dc.b	$0e,$88,$0e,$b0,$0e,$d8
	dc.b	$0f,$00,$0f,$28,$0f,$50
	dc.b	$0f,$78,$0f,$a0,$0f,$c8
	dc.b	$0f,$f0,$10,$18,$10,$40
	dc.b	$10,$68,$10,$90,$10,$b8
	dc.b	$10,$e0,$11,$08,$11,$30
	dc.b	$11,$58,$11,$80,$11,$a8
	dc.b	$11,$d0,$11,$f8,$12,$20
	dc.b	$12,$48,$12,$70,$12,$98
	dc.b	$12,$c0,$12,$e8,$13,$10
	dc.b	$13,$38,$13,$60,$13,$88
	dc.b	$13,$b0,$13,$d8,$14,$00
	dc.b	$14,$28,$14,$50,$14,$78
	dc.b	$14,$a0,$14,$c8,$14,$f0
	dc.b	$15,$18,$15,$40,$15,$68
	dc.b	$15,$90,$15,$b8,$15,$e0
	dc.b	$16,$08,$16,$30,$16,$58
	dc.b	$16,$80,$16,$a8,$16,$d0
	dc.b	$16,$f8,$17,$20,$17,$48
	dc.b	$17,$70,$17,$98,$17,$c0
	dc.b	$17,$e8,$18,$10,$18,$38
	dc.b	$18,$60,$18,$88,$18,$b0
	dc.b	$18,$d8,$19,$00,$19,$28
	dc.b	$19,$50,$19,$78,$19,$a0
	dc.b	$19,$c8,$19,$f0,$1a,$18
	dc.b	$1a,$40,$1a,$68,$1a,$90
	dc.b	$1a,$b8,$1a,$e0,$1b,$08
	dc.b	$1b,$30,$1b,$58,$1b,$80
	dc.b	$1b,$a8,$1b,$d0,$1b,$f8
	dc.b	$1c,$20,$1c,$48,$1c,$70
	dc.b	$1c,$98,$1c,$c0,$1c,$e8
	dc.b	$1d,$10,$1d,$38,$1d,$60
	dc.b	$1d,$88,$1d,$b0,$1d,$d8
	dc.b	$1e,$00,$1e,$28,$1e,$50
	dc.b	$1e,$78,$1e,$a0,$1e,$c8
	dc.b	$1e,$f0,$1f,$18,$1f,$40
	dc.b	$1f,$68,$1f,$90,$1f,$b8
	dc.b	$1f,$e0,$20,$08,$20,$30
	dc.b	$20,$58,$20,$80,$20,$a8
	dc.b	$20,$d0,$20,$f8,$21,$20
	dc.b	$21,$48,$21,$70,$21,$98
	dc.b	$21,$c0,$21,$e8,$22,$10
	dc.b	$22,$38,$22,$60,$22,$88
	dc.b	$22,$b0,$22,$d8,$23,$00
	dc.b	$23,$28,$23,$50,$23,$78
	dc.b	$23,$a0,$23,$c8,$23,$f0
	dc.b	$24,$18,$24,$40,$24,$68
	dc.b	$24,$90,$24,$b8,$24,$e0
	dc.b	$25,$08,$25,$30,$25,$58
	dc.b	$25,$80,$25,$a8,$25,$d0
	dc.b	$25,$f8,$26,$20,$26,$48
	dc.b	$26,$70,$26,$98,$26,$c0
	dc.b	$26,$e8,$27,$10,$27,$38
	dc.b	$27,$60,$27,$88,$27,$b0
	dc.b	$27,$d8
L80	dc.b	$80,$00,$40,$00,$20,$00
	dc.b	$10,$00,$08,$00,$04,$00
	dc.b	$02,$00,$01,$00,$00,$80
	dc.b	$00,$40,$00,$20,$00,$10
	dc.b	$00,$08,$00,$04,$00,$02
	dc.b	$00,$01,$7f,$ff,$bf,$ff
	dc.b	$df,$ff,$ef,$ff,$f7,$ff
	dc.b	$fb,$ff,$fd,$ff,$fe,$ff
	dc.b	$ff,$7f,$ff,$bf,$ff,$df
	dc.b	$ff,$ef,$ff,$f7,$ff,$fb
	dc.b	$ff,$fd,$ff,$fe
L81	dc.l	L83
L82	dc.l	L83
L83	dc.b	$00,$0f,$01,$1f,$02,$2f
	dc.b	$03,$3f,$04,$4f,$05,$5f
	dc.b	$06,$6f,$07,$7f,$08,$8f
	dc.b	$09,$9f,$0a,$af,$0b,$bf
	dc.b	$0c,$cf,$0d,$df,$0e,$ef
	dc.b	$0f,$ff,$0f,$ff,$0e,$ef
	dc.b	$0d,$df,$0c,$cf,$0b,$bf
	dc.b	$0a,$af,$09,$9f,$08,$8f
	dc.b	$07,$7f,$06,$6f,$05,$5f
	dc.b	$04,$4f,$03,$3f,$02,$2f
	dc.b	$01,$1f,$00,$0f,$00,$00
L84	dc.b	$00,$00,$03,$24,$06,$47
	dc.b	$09,$6a,$0c,$8b,$0f,$ab
	dc.b	$12,$c7,$15,$e1,$18,$f8
	dc.b	$1c,$0b,$1f,$19,$22,$23
	dc.b	$25,$27,$28,$26,$2b,$1e
	dc.b	$2e,$10,$30,$fb,$33,$de
	dc.b	$36,$b9,$39,$8c,$3c,$56
	dc.b	$3f,$16,$41,$cd,$44,$7a
	dc.b	$47,$1c,$49,$b3,$4c,$3f
	dc.b	$4e,$bf,$51,$33,$53,$9a
	dc.b	$55,$f4,$58,$42,$5a,$81
	dc.b	$5c,$b3,$5e,$d6,$60,$eb
	dc.b	$62,$f1,$64,$e7,$66,$ce
	dc.b	$68,$a5,$6a,$6c,$6c,$23
	dc.b	$6d,$c9,$6f,$5e,$70,$e1
	dc.b	$72,$54,$73,$b5,$75,$03
	dc.b	$76,$40,$77,$6b,$78,$83
	dc.b	$79,$89,$7a,$7c,$7b,$5c
	dc.b	$7c,$29,$7c,$e2,$7d,$89
	dc.b	$7e,$1c,$7e,$9c,$7f,$08
	dc.b	$7f,$61,$7f,$a6,$7f,$d7
	dc.b	$7f,$f5,$7f,$ff,$7f,$f5
	dc.b	$7f,$d7,$7f,$a6,$7f,$61
	dc.b	$7f,$08,$7e,$9c,$7e,$1c
	dc.b	$7d,$89,$7c,$e2,$7c,$29
	dc.b	$7b,$5c,$7a,$7c,$79,$89
	dc.b	$78,$83,$77,$6b,$76,$40
	dc.b	$75,$03,$73,$b5,$72,$54
	dc.b	$70,$e1,$6f,$5e,$6d,$c9
	dc.b	$6c,$23,$6a,$6c,$68,$a5
	dc.b	$66,$ce,$64,$e7,$62,$f1
	dc.b	$60,$eb,$5e,$d6,$5c,$b3
	dc.b	$5a,$81,$58,$42,$55,$f4
	dc.b	$53,$9a,$51,$33,$4e,$bf
	dc.b	$4c,$3f,$49,$b3,$47,$1c
	dc.b	$44,$7a,$41,$cd,$3f,$16
	dc.b	$3c,$56,$39,$8c,$36,$b9
	dc.b	$33,$de,$30,$fb,$2e,$10
	dc.b	$2b,$1e,$28,$26,$25,$27
	dc.b	$22,$23,$1f,$19,$1c,$0b
	dc.b	$18,$f8,$15,$e1,$12,$c7
	dc.b	$0f,$ab,$0c,$8b,$09,$6a
	dc.b	$06,$47,$03,$24,$00,$00
	dc.b	$fc,$db,$f9,$b8,$f6,$95
	dc.b	$f3,$74,$f0,$54,$ed,$38
	dc.b	$ea,$1e,$e7,$07,$e3,$f4
	dc.b	$e0,$e6,$dd,$dc,$da,$d8
	dc.b	$d7,$d9,$d4,$e1,$d1,$ef
	dc.b	$cf,$04,$cc,$21,$c9,$46
	dc.b	$c6,$73,$c3,$a9,$c0,$e9
	dc.b	$be,$32,$bb,$85,$b8,$e3
	dc.b	$b6,$4c,$b3,$c0,$b1,$40
	dc.b	$ae,$cc,$ac,$65,$aa,$0b
	dc.b	$a7,$bd,$a5,$7e,$a3,$4c
	dc.b	$a1,$29,$9f,$14,$9d,$0e
	dc.b	$9b,$18,$99,$31,$97,$5a
	dc.b	$95,$93,$93,$dc,$92,$36
	dc.b	$90,$a1,$8f,$1e,$8d,$ab
	dc.b	$8c,$4a,$8a,$fc,$89,$bf
	dc.b	$88,$94,$87,$7c,$86,$76
	dc.b	$85,$83,$84,$a3,$83,$d6
	dc.b	$83,$1d,$82,$76,$81,$e3
	dc.b	$81,$63,$80,$f7,$80,$9e
	dc.b	$80,$59,$80,$28,$80,$0a
	dc.b	$80,$00,$80,$0a,$80,$28
	dc.b	$80,$59,$80,$9e,$80,$f7
	dc.b	$81,$63,$81,$e3,$82,$76
	dc.b	$83,$1d,$83,$d6,$84,$a3
	dc.b	$85,$83,$86,$76,$87,$7c
	dc.b	$88,$94,$89,$bf,$8a,$fc
	dc.b	$8c,$4a,$8d,$ab,$8f,$1e
	dc.b	$90,$a1,$92,$36,$93,$dc
	dc.b	$95,$93,$97,$5a,$99,$31
	dc.b	$9b,$18,$9d,$0e,$9f,$14
	dc.b	$a1,$29,$a3,$4c,$a5,$7e
	dc.b	$a7,$bd,$aa,$0b,$ac,$65
	dc.b	$ae,$cc,$b1,$40,$b3,$c0
	dc.b	$b6,$4c,$b8,$e3,$bb,$85
	dc.b	$be,$32,$c0,$e9,$c3,$a9
	dc.b	$c6,$73,$c9,$46,$cc,$21
	dc.b	$cf,$04,$d1,$ef,$d4,$e1
	dc.b	$d7,$d9,$da,$d8,$dd,$dc
	dc.b	$e0,$e6,$e3,$f4,$e7,$07
	dc.b	$ea,$1e,$ed,$38,$f0,$54
	dc.b	$f3,$74,$f6,$95,$f9,$b8
	dc.b	$fc,$db,$00,$00,$03,$24
	dc.b	$06,$47,$09,$6a,$0c,$8b
	dc.b	$0f,$ab,$12,$c7,$15,$e1
	dc.b	$18,$f8,$1c,$0b,$1f,$19
	dc.b	$22,$23,$25,$27,$28,$26
	dc.b	$2b,$1e,$2e,$10,$30,$fb
	dc.b	$33,$de,$36,$b9,$39,$8c
	dc.b	$3c,$56,$3f,$16,$41,$cd
	dc.b	$44,$7a,$47,$1c,$49,$b3
	dc.b	$4c,$3f,$4e,$bf,$51,$33
	dc.b	$53,$9a,$55,$f4,$58,$42
	dc.b	$5a,$81,$5c,$b3,$5e,$d6
	dc.b	$60,$eb,$62,$f1,$64,$e7
	dc.b	$66,$ce,$68,$a5,$6a,$6c
	dc.b	$6c,$23,$6d,$c9,$6f,$5e
	dc.b	$70,$e1,$72,$54,$73,$b5
	dc.b	$75,$03,$76,$40,$77,$6b
	dc.b	$78,$83,$79,$89,$7a,$7c
	dc.b	$7b,$5c,$7c,$29,$7c,$e2
	dc.b	$7d,$89,$7e,$1c,$7e,$9c
	dc.b	$7f,$08,$7f,$61,$7f,$a6
	dc.b	$7f,$d7,$7f,$f5,$7f,$ff

L85	movea.l	L16,a0
	movea.l	a0,a1
	adda.l	#$000003b8,a1
	moveq	#$7f,d0
	moveq	#$00,d1
L86	move.l	d1,d2
	subq.w	#$1,d0
L87	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	L86
	dbf	d0,L87
	addq.b	#$1,d2
	lea	L145(pc),a1
	asl.l	#$8,d2
	asl.l	#$2,d2
	addi.l	#$0000043c,d2
	add.l	a0,d2
	movea.l	d2,a2
	moveq	#$1e,d0
L88	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#$00,d1
	move.w	$002a(a0),d1
	asl.l	#$1,d1
	adda.l	d1,a2
	adda.l	#$0000001e,a0
	dbf	d0,L88
	ori.b	#$02,$00bfe001
	move.b	#$06,L139
	clr.w	$00dff0a8
	clr.w	$00dff0b8
	clr.w	$00dff0c8
	clr.w	$00dff0d8
	clr.b	L140
	clr.b	L142
	clr.w	L141
	rts	

L89	clr.w	$00dff0a8
	clr.w	$00dff0b8
	clr.w	$00dff0c8
	clr.w	$00dff0d8
	move.w	#$000f,$00dff096
	rts	

E90	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	movea.l	L16,a0
	addq.b	#$1,L142
	move.b	L142,d0
	cmp.b	L139,d0
	blt.s	E91
	clr.b	L142
	bra.l	E98

E91	lea	E146(pc),a6
	lea	$00dff0a0,a5
	bsr.l	E120
	lea	E147(pc),a6
	lea	$00dff0b0,a5
	bsr.l	E120
	lea	E148(pc),a6
	lea	$00dff0c0,a5
	bsr.l	E120
	lea	E149(pc),a6
	lea	$00dff0d0,a5
	bsr.l	E120
	bra.l	E107

E92	moveq	#$00,d0
	move.b	L142,d0
	divs	#$0003,d0
	swap	d0
	cmpi.w	#$0000,d0
	beq.s	E94
	cmpi.w	#$0002,d0
	beq.s	E93
	moveq	#$00,d0
	move.b	$0003(a6),d0
	lsr.b	#$4,d0
	bra.s	E95

E93	moveq	#$00,d0
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	bra.s	E95

E94	move.w	$0010(a6),d2
	bra.s	E97

E95	asl.w	#$1,d0
	moveq	#$00,d1
	move.w	$0010(a6),d1
	lea	E138(pc),a0
	moveq	#$24,d7
E96	move.w	$00(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	E97
	addq.l	#$2,a0
	dbf	d7,E96
	rts	

E97	move.w	d2,$0006(a5)
	rts	

E98	movea.l	L16,a0
	movea.l	a0,a3
	movea.l	a0,a2
	adda.l	#$0000000c,a3
	adda.l	#$000003b8,a2
	adda.l	#$0000043c,a0
	moveq	#$00,d0
	move.l	d0,d1
	move.b	L140,d0
	move.b	$00(a2,d0.w),d1
	asl.l	#$8,d1
	asl.l	#$2,d1
	add.w	L141,d1
	clr.w	L144
	lea	$00dff0a0,a5
	lea	E146(pc),a6
	bsr.s	E99
	lea	$00dff0b0,a5
	lea	E147(pc),a6
	bsr.s	E99
	lea	$00dff0c0,a5
	lea	E148(pc),a6
	bsr.s	E99
	lea	$00dff0d0,a5
	lea	E149(pc),a6
	bsr.s	E99
	bra.l	E103

E99	move.l	$00(a0,d1.l),(a6)
	addq.l	#$4,d1
	moveq	#$00,d2
	move.b	$0002(a6),d2
	andi.b	#-$10,d2
	lsr.b	#$4,d2
	move.b	(a6),d0
	andi.b	#-$10,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	E101
	moveq	#$00,d3
	lea	L145(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#$2,d2
	mulu	#$001e,d4
	move.l	$00(a1,d2.l),$0004(a6)
	move.w	$00(a3,d4.l),$0008(a6)
	move.w	$02(a3,d4.l),$0012(a6)
	move.w	$04(a3,d4.l),d3
	tst.w	d3
	beq.s	E100
	move.l	$0004(a6),d2
	asl.w	#$1,d3
	add.l	d3,d2
	move.l	d2,$000a(a6)
	move.w	$04(a3,d4.l),d0
	add.w	$06(a3,d4.l),d0
	move.w	d0,$0008(a6)
	move.w	$06(a3,d4.l),$000e(a6)
	move.w	$0012(a6),$0008(a5)
	bra.s	E101

E100	move.l	$0004(a6),d2
	add.l	d3,d2
	move.l	d2,$000a(a6)
	move.w	$06(a3,d4.l),$000e(a6)
	move.w	$0012(a6),$0008(a5)
E101	move.w	(a6),d0
	andi.w	#$0fff,d0
	beq.l	E129
	move.b	$0002(a6),d0
	andi.b	#$0f,d0
	cmpi.b	#$03,d0
	bne.s	E102
	bsr.l	E108
	bra.l	E129

E102	move.w	(a6),$0010(a6)
	andi.w	#$0fff,$0010(a6)
	move.w	$0014(a6),d0
	move.w	d0,$00dff096
	clr.b	$001b(a6)
	move.l	$0004(a6),(a5)
	move.w	$0008(a6),$0004(a5)
	move.w	$0010(a6),d0
	andi.w	#$0fff,d0
	move.w	d0,$0006(a5)
	move.w	$0014(a6),d0
	or.w	d0,L144
	bra.l	E129

E103	move.w	#$012c,d0
E104	dbf	d0,E104
	move.w	L144,d0
	ori.w	#-$8000,d0
	move.w	d0,$00dff096
	move.w	#$012c,d0
E105	dbf	d0,E105
	lea	$00dff000,a5
	lea	E149(pc),a6
	move.l	$000a(a6),$00d0(a5)
	move.w	$000e(a6),$00d4(a5)
	lea	E148(pc),a6
	move.l	$000a(a6),$00c0(a5)
	move.w	$000e(a6),$00c4(a5)
	lea	E147(pc),a6
	move.l	$000a(a6),$00b0(a5)
	move.w	$000e(a6),$00b4(a5)
	lea	E146(pc),a6
	move.l	$000a(a6),$00a0(a5)
	move.w	$000e(a6),$00a4(a5)
	addi.w	#$0010,L141
	cmpi.w	#$0400,L141
	bne.s	E107
E106	clr.w	L141
	clr.b	L143
	addq.b	#$1,L140
	andi.b	#$7f,L140
	move.b	L140,d1
	movea.l	L16,a0
	cmp.b	$03b6(a0),d1
	bne.s	E107
	clr.b	L140
E107	tst.b	L143
	bne.s	E106
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts	

E108	move.w	(a6),d2
	andi.w	#$0fff,d2
	move.w	d2,$0018(a6)
	move.w	$0010(a6),d0
	clr.b	$0016(a6)
	cmp.w	d0,d2
	beq.s	E109
	bge.s	E110
	move.b	#$01,$0016(a6)
	rts	

E109	clr.w	$0018(a6)
E110	rts	

E111	move.b	$0003(a6),d0
	beq.s	E112
	move.b	d0,$0017(a6)
	clr.b	$0003(a6)
E112	tst.w	$0018(a6)
	beq.s	E110
	moveq	#$00,d0
	move.b	$0017(a6),d0
	tst.b	$0016(a6)
	bne.s	E114
	add.w	d0,$0010(a6)
	move.w	$0018(a6),d0
	cmp.w	$0010(a6),d0
	bgt.s	E113
	move.w	$0018(a6),$0010(a6)
	clr.w	$0018(a6)
E113	move.w	$0010(a6),$0006(a5)
	rts	

E114	sub.w	d0,$0010(a6)
	move.w	$0018(a6),d0
	cmp.w	$0010(a6),d0
	blt.s	E113
	move.w	$0018(a6),$0010(a6)
	clr.w	$0018(a6)
	move.w	$0010(a6),$0006(a5)
	rts	

E115	move.b	$0003(a6),d0
	beq.s	E116
	move.b	d0,$001a(a6)
E116	move.b	$001b(a6),d0
	lea	E137(pc),a4
	lsr.w	#$2,d0
	andi.w	#$001f,d0
	moveq	#$00,d2
	move.b	$00(a4,d0.w),d2
	move.b	$001a(a6),d0
	andi.w	#$000f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$0010(a6),d0
	tst.b	$001b(a6)
	bmi.s	E117
	add.w	d2,d0
	bra.s	E118

E117	sub.w	d2,d0
E118	move.w	d0,$0006(a5)
	move.b	$001a(a6),d0
	lsr.w	#$2,d0
	andi.w	#$003c,d0
	add.b	d0,$001b(a6)
	rts	

E119	move.w	$0010(a6),$0006(a5)
	rts	

E120	move.w	$0002(a6),d0
	andi.w	#$0fff,d0
	beq.s	E119
	move.b	$0002(a6),d0
	andi.b	#$0f,d0
	tst.b	d0
	beq.l	E92
	cmpi.b	#$01,d0
	beq.s	E125
	cmpi.b	#$02,d0
	beq.l	E127
	cmpi.b	#$03,d0
	beq.l	E111
	cmpi.b	#$04,d0
	beq.l	E115
	move.w	$0010(a6),$0006(a5)
	cmpi.b	#$0a,d0
	beq.s	E121
	rts	

E121	moveq	#$00,d0
	move.b	$0003(a6),d0
	lsr.b	#$4,d0
	tst.b	d0
	beq.s	E123
	add.w	d0,$0012(a6)
	cmpi.w	#$0040,$0012(a6)
	bmi.s	E122
	move.w	#$0040,$0012(a6)
E122	move.w	$0012(a6),$0008(a5)
	rts	

E123	moveq	#$00,d0
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	sub.w	d0,$0012(a6)
	bpl.s	E124
	clr.w	$0012(a6)
E124	move.w	$0012(a6),$0008(a5)
	rts	

E125	moveq	#$00,d0
	move.b	$0003(a6),d0
	sub.w	d0,$0010(a6)
	move.w	$0010(a6),d0
	andi.w	#$0fff,d0
	cmpi.w	#$0071,d0
	bpl.s	E126
	andi.w	#-$1000,$0010(a6)
	ori.w	#$0071,$0010(a6)
E126	move.w	$0010(a6),d0
	andi.w	#$0fff,d0
	move.w	d0,$0006(a5)
	rts	

E127	clr.w	d0
	move.b	$0003(a6),d0
	add.w	d0,$0010(a6)
	move.w	$0010(a6),d0
	andi.w	#$0fff,d0
	cmpi.w	#$0358,d0
	bmi.s	E128
	andi.w	#-$1000,$0010(a6)
	ori.w	#$0358,$0010(a6)
E128	move.w	$0010(a6),d0
	andi.w	#$0fff,d0
	move.w	d0,$0006(a5)
	rts	

E129	move.b	$0002(a6),d0
	andi.b	#$0f,d0
	cmpi.b	#$0e,d0
	beq.s	E130
	cmpi.b	#$0d,d0
	beq.s	E131
	cmpi.b	#$0b,d0
	beq.s	E132
	cmpi.b	#$0c,d0
	beq.s	E133
	cmpi.b	#$0f,d0
	beq.s	E135
	rts	

E130	move.b	$0003(a6),d0
	andi.b	#$01,d0
	asl.b	#$1,d0
	andi.b	#-$03,$00bfe001
	or.b	d0,$00bfe001
	rts	

E131	not.b	L143
	rts	

E132	move.b	$0003(a6),d0
	subq.b	#$1,d0
	move.b	d0,L140
	not.b	L143
	rts	

E133	cmpi.b	#$40,$0003(a6)
	ble.s	E134
	move.b	#$40,$0003(a6)
E134	move.b	$0003(a6),$0008(a5)
	rts	

E135	move.b	$0003(a6),d0
	andi.w	#$001f,d0
	beq.s	E136
	clr.b	L142
	move.b	d0,L139
E136	rts	

E137	dc.b	$00,$18,$31,$4a,$61,$78
	dc.b	$8d,$a1,$b4,$c5,$d4,$e0
	dc.b	$eb,$f4,$fa,$fd,$ff,$fd
	dc.b	$fa,$f4,$eb,$e0,$d4,$c5
	dc.b	$b4,$a1,$8d,$78,$61,$4a
	dc.b	$31,$18
E138	dc.b	$03,$58,$03,$28,$02,$fa
	dc.b	$02,$d0,$02,$a6,$02,$80
	dc.b	$02,$5c,$02,$3a,$02,$1a
	dc.b	$01,$fc,$01,$e0,$01,$c5
	dc.b	$01,$ac,$01,$94,$01,$7d
	dc.b	$01,$68,$01,$53,$01,$40
	dc.b	$01,$2e,$01,$1d,$01,$0d
	dc.b	$00,$fe,$00,$f0,$00,$e2
	dc.b	$00,$d6,$00,$ca,$00,$be
	dc.b	$00,$b4,$00,$aa,$00,$a0
	dc.b	$00,$97,$00,$8f,$00,$87
	dc.b	$00,$7f,$00,$78,$00,$71
	dc.b	$00,$00,$00,$00
L139	dc.b	$06
L140	dcb.b	1,$00
L141	dcb.b	2,$00
L142	dcb.b	1,$00
L143	dcb.b	1,$00
L144	dcb.b	2,$00
L145	dcb.b	1,$00
	dc.b	$05,$a7,$4a,$00,$05,$af
	dc.b	$22,$00,$05,$ca,$84,$00
	dc.b	$05,$e4,$c4,$00,$05,$ea
	dc.b	$94,$00,$05,$f2,$42,$00
	dc.b	$06,$08,$a6,$00,$06,$08
	dc.b	$a6,$00,$06,$2d,$c0,$00
	dc.b	$06,$2d,$c0,$00,$06,$2d
	dc.b	$c0,$00,$06,$2d,$c0,$00
	dc.b	$06,$40,$3a,$00,$06,$40
	dc.b	$3a,$00,$06,$40,$3a,$00
	dc.b	$06,$40,$3a,$00,$06,$40
	dc.b	$3a,$00,$06,$40,$3a,$00
	dc.b	$06,$40,$3a,$00,$06,$40
	dc.b	$3a,$00,$06,$40,$3a,$00
	dc.b	$06,$40,$3a,$00,$06,$40
	dc.b	$3a,$00,$06,$40,$3a,$00
	dc.b	$06,$40,$3a,$00,$06,$40
	dc.b	$3a,$00,$06,$40,$3a,$00
	dc.b	$06,$40,$3a,$00,$06,$40
	dc.b	$3a,$00,$06,$40,$3a,$00
	dc.b	$06,$40,$3a
E146	dc.b	$00,$00,$00,$00,$00,$05
	dc.b	$ca,$84,$0d,$20,$00,$05
	dc.b	$ca,$84,$00,$01,$00,$d6
	dc.b	$00,$40,$00,$01,$00,$01
	dcb.b	4,$00
E147	dcb.b	5,$00
	dc.b	$05,$ea,$94,$03,$d7,$00
	dc.b	$05,$ea,$94,$00,$01,$01
	dc.b	$7d,$00,$37,$00,$02,$00
	dc.b	$02
	dcb.b	4,$00
E148	dcb.b	5,$00
	dc.b	$06,$2d,$c0,$09,$3d,$00
	dc.b	$06,$2d,$c0,$00,$01,$00
	dc.b	$be,$00,$40,$00,$04,$00
	dc.b	$04
	dcb.b	4,$00
E149	dcb.b	5,$00
	dc.b	$06,$2d,$c0,$09,$3d,$00
	dc.b	$06,$2d,$c0,$00,$01,$01
	dc.b	$7d,$00,$40,$00,$08,$00
	dc.b	$08
	dcb.b	4,$00
L150	dcb.b	3,$00
	dc.b	$01,$00,$02,$00,$03,$00
	dc.b	$04,$00,$05,$00,$06,$00
	dc.b	$07,$00,$08,$00,$09,$00
	dc.b	$0a,$00,$0b,$00,$0c,$00
	dc.b	$0d,$00,$0e,$00,$0f,$00
	dc.b	$10,$00,$11,$00,$12,$00
	dc.b	$13,$00,$14,$00,$15,$00
	dc.b	$16,$00,$17,$00,$18,$00
	dc.b	$19,$00,$1a,$00,$1b,$00
	dc.b	$1c,$00,$1d,$00,$1e,$00
	dc.b	$1f,$00,$20,$00,$21,$00
	dc.b	$22,$00,$23,$00,$24,$00
	dc.b	$25,$00,$26,$00,$27,$01
	dc.b	$18,$01,$19,$01,$1a,$01
	dc.b	$1b,$01,$1c,$01,$1d,$01
	dc.b	$1e,$01,$1f,$01,$20,$01
	dc.b	$21,$01,$22,$01,$23,$01
	dc.b	$24,$01,$25,$01,$26,$01
	dc.b	$27,$01,$28,$01,$29,$01
	dc.b	$2a,$01,$2b,$01,$2c,$01
	dc.b	$2d,$01,$2e,$01,$2f,$01
	dc.b	$30,$01,$31,$01,$32,$01
	dc.b	$33,$01,$34,$01,$35
L151	dc.b	$00,$8e,$28,$81,$00,$90
	dc.b	$29,$c1,$00,$92,$00,$38
	dc.b	$00,$94,$00,$d0,$01,$02
	dc.b	$00,$00,$01,$04,$00,$00
	dc.b	$01,$08,$00,$00,$01,$0a
	dc.b	$00,$00,$01,$80
L152	dc.b	$00,$00,$01,$82,$08,$00
	dc.b	$01,$84,$0b,$00,$01,$86
	dc.b	$0d,$00,$01,$88,$0f,$22
	dc.b	$01,$8a,$0f,$55,$01,$8c
	dc.b	$0f,$aa,$01,$8e,$03,$07
	dc.b	$01,$90,$05,$0a,$01,$92
	dc.b	$07,$0d,$01,$94,$09,$0f
	dc.b	$01,$96,$0b,$5f,$01,$98
	dc.b	$0f,$af,$01,$9a,$00,$0a
	dc.b	$01,$9c,$00,$0e,$01,$9e
	dc.b	$02,$2f,$01,$a0,$04,$4f
	dc.b	$01,$a2,$07,$7f,$01,$a4
	dc.b	$0b,$bf,$01,$a6,$00,$50
	dc.b	$01,$a8,$00,$80,$01,$aa
	dc.b	$00,$b0,$01,$ac,$00,$e0
	dc.b	$01,$ae,$06,$e6,$01,$b0
	dc.b	$09,$f9,$01,$b2,$08,$0d
	dc.b	$01,$b4,$08,$81,$01,$b6
	dc.b	$0b,$b2,$01,$b8,$0d,$d4
	dc.b	$01,$ba,$0f,$f6,$01,$bc
	dc.b	$0f,$fb,$01,$be,$0f,$ff
L153	dc.b	$01,$20,$00,$00,$01,$22
	dc.b	$00,$00,$01,$24,$00,$00
	dc.b	$01,$26,$00,$00,$01,$28
	dc.b	$00,$00,$01,$2a,$00,$00
	dc.b	$01,$2c,$00,$00,$01,$2e
	dc.b	$00,$00,$01,$30,$00,$00
	dc.b	$01,$32,$00,$00,$01,$34
	dc.b	$00,$00,$01,$36,$00,$00
	dc.b	$01,$38,$00,$00,$01,$3a
	dc.b	$00,$00,$01,$3c,$00,$00
	dc.b	$01,$3e,$00,$00
L154	dc.b	$00,$e0,$00,$00,$00,$e2
	dc.b	$00,$00,$00,$e4,$00,$00
	dc.b	$00,$e6,$00,$00,$00,$e8
	dc.b	$00,$00,$00,$ea,$00,$00
	dc.b	$00,$ec,$00,$00,$00,$ee
	dc.b	$00,$00,$00,$f0,$00,$00
	dc.b	$00,$f2,$00,$00,$28,$01
	dc.b	$ff,$fe,$01,$00
L155	dc.b	$02,$00,$78,$01,$ff,$fe
	dc.b	$01,$00,$02,$00,$01,$82
	dc.b	$0f,$ff,$01,$84,$0f,$ff
	dc.b	$01,$86,$0f,$ff,$01,$88
	dc.b	$08,$88,$01,$8a,$04,$44
	dc.b	$01,$8c,$0f,$ff,$01,$8e
	dc.b	$0f,$ff,$01,$a2,$05,$57
	dc.b	$01,$a4,$04,$46,$01,$a6
	dc.b	$02,$24,$01,$0a,$00,$02
	dc.b	$79,$13,$ff,$fe,$01,$80
L156	dc.b	$0f,$00,$01,$80
L157	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
L158	dc.b	$0f,$00,$7a,$01,$ff,$fe
	dc.b	$01,$00,$32,$00,$01,$80
	dc.b	$00,$00
L159	dc.b	$00,$e0,$00,$00,$00,$e2
	dc.b	$00,$00,$00,$e4,$00,$00
	dc.b	$00,$e6,$00,$00,$00,$e8
	dc.b	$00,$00,$00,$ea,$00,$00
	dc.b	$ff,$0f,$ff,$fe,$01,$00
	dc.b	$02,$00,$01,$80
L160	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
	dc.b	$0f,$00,$01,$80,$0f,$00
	dc.b	$01,$80,$0f,$00,$01,$80
L161	dc.b	$0f,$00,$01,$80
L162	dc.b	$0f,$00,$00,$0f,$ff,$fe
	dc.b	$01,$80
L163	dc.b	$00,$00,$01,$82,$0f,$5f
	dc.b	$01,$84,$0d,$4d,$01,$86
	dc.b	$0b,$3b,$01,$88,$09,$29
	dc.b	$01,$8a,$08,$18,$01,$8c
	dc.b	$07,$07,$01,$8e,$04,$04
L164	dc.b	$00,$e0,$00,$00,$00,$e2
	dc.b	$00,$00,$00,$e4,$00,$00
	dc.b	$00,$e6,$00,$00,$00,$e8
	dc.b	$00,$00,$00,$ea,$00,$00
	dc.b	$01,$08,$00,$02,$01,$0a
	dc.b	$00,$02
L165	dc.b	$01,$0f,$ff,$fe,$01,$00
	dc.b	$32,$00
L166	dc.b	$08,$0f,$ff,$fe,$01,$00
	dc.b	$02,$00,$ff,$ff,$ff,$fe

L167	dc.b	$00,$00,$00,$02,$00,$04
	dc.b	$00,$06,$00,$08,$00,$0a
	dc.b	$00,$0c,$00,$0e,$00,$10
	dc.b	$00,$12,$00,$14,$00,$16
	dc.b	$00,$18,$00,$1a,$00,$1c
	dc.b	$00,$1e,$00,$20,$00,$22
	dc.b	$00,$24,$00,$26,$01,$18
	dc.b	$01,$1a,$01,$1c,$01,$1e
	dc.b	$01,$20,$01,$22,$01,$24
	dc.b	$01,$26,$01,$28,$01,$2a
	dc.b	$01,$2c,$01,$2e,$01,$30
	dc.b	$01,$32,$01,$34,$01,$36
	dc.b	$01,$38,$01,$3a,$01,$3c
	dc.b	$01,$3e,$02,$30,$02,$32
	dc.b	$02,$34,$02,$36,$02,$38
	dc.b	$02,$3a,$02,$3c,$02,$3e
	dc.b	$02,$40,$02,$42,$02,$44
	dc.b	$02,$46,$02,$48,$02,$4a
	dc.b	$02,$4c,$02,$4e,$02,$50
	dc.b	$02,$52,$02,$54,$02,$56

L168	dc.b	$f6,$d0,$fe,$00,$5f,$ff
	dc.b	$60,$00,$20,$00,$40,$00
	dc.b	$79,$a6,$40,$00,$09,$ed
	dc.b	$04,$00,$19,$af,$14,$00
	dc.b	$b1,$ad,$c8,$00,$00,$00
	dc.b	$00,$00,$bf,$ff,$c0,$00
	dc.b	$00,$00,$00,$00
L169	dc.b	$f6,$d8,$fe,$00,$ff,$fe
	dc.b	$00,$00,$00,$18,$00,$00
	dc.b	$6b,$9e,$00,$00,$6b,$58
	dc.b	$00,$00,$6b,$58,$00,$00
	dc.b	$7b,$9d,$00,$03,$18,$00
	dc.b	$00,$00,$fb,$fd,$00,$03
	dcb.b	4,$00

;--------------------------------------;

DatList	dc.l	MainFnt-DatList
	dc.l	ScrlFnt-DatList
	dc.l	MainTxt-DatList
	dc.l	ScrlTxt-DatList
	dc.l	mt_data-DatList

;--------------------------------------;

RealPic	dc.w	3
	dc.w	$000,$fff,$bfc,$8c9
	dc.w	$596,$464,$151,$131
	incbin	"DH1:Reality/Reality.raw"

;-------------------;

MainFnt	incbin	"DH1:Reality/MainTxt.raw"

;-------------------;

ScrlFnt	dc.w	$000,$fff,$ece,$e9e
	dc.w	$d7d,$d4d,$c2c,$c0c
	incbin	"DH1:Reality/Scrolly.raw"

;-------------------;

MainTxt	incbin	"DH1:Reality/MainTxt.txt"
	dc.b	0
	even

;-------------------;

ScrlTxt	incbin	"DH1:Reality/Scrolly.txt"
	dc.b	0,0
	even

;-------------------;

mt_data	incbin	"DH1:Reality/mod.WarningSign"
	dc.l	0

	END

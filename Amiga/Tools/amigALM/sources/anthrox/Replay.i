;	I THINK THIS MUSIC WAS RIPPED FROM ANOTHER INTRO BEFORE.
;	ANTHROX DIDN'T RIP IT RIGHT THOUGH AS PARTS OF THE OTHER
;	INTRO'S ADDRESSES ARE STILL THERE.


B1	lea	$306b4,a0
	move.w	#$0034,d1
	move.w	(a0),$00031b6c
B2	move.w	$0008(a0),(a0)
	addq.w	#8,a0
	dbf	d1,B2
	move.w	$00031b6c,(a0)
	rts

	dc.w	51

MT_Init	bset	#1,$bfe001
	bsr.s	E33
	rts	

	rts
	rts
	rts
	rts
	rts
	rts

E33	bsr.l	E34
	lea	E137(pc),a3
	cmp.l	#1,(a3)
	bne.l	E37
	rts	

E34	lea	MT_Data(pc),a0
	adda.l	-$002c(a0),a0
	lea	E129(pc),a1
	move.l	a0,(a1)
	lea	MT_Data(pc),a0
	adda.l	-$0028(a0),a0
	lea	E130(pc),a1
	move.l	a0,(a1)
	lea	MT_Data(pc),a0
	adda.l	-$0024(a0),a0
	lea	E131(pc),a1
	move.l	a0,(a1)
	lea	MT_Data(pc),a0
	adda.l	-$0020(a0),a0
	lea	E132(pc),a1
	move.l	a0,(a1)
	move.w	#$000f,$00dff096
	lea	E125(pc),a0
	moveq	#$1f,d0
E35	clr.l	(a0)+
	dbf	d0,E35
	moveq	#$03,d0
	lea	MT_Data(pc),a0
	adda.l	-$000c(a0),a0
	move.l	a0,d7
	lea	E125(pc),a0
	lea	E129(pc),a1
	lea	$00dff0a0,a3
E36	movea.l	(a1)+,a2
	moveq	#$01,d5
	move.l	a2,(a0)+
	move.l	(a2),d5
	lea	MT_Data(pc),a4
	adda.l	-$0008(a4),a4
	add.w	d5,d5
	add.w	d5,d5
	adda.w	d5,a4
	movea.l	(a4),a4
	adda.l	d7,a4
	movea.l	a4,a2
	move.l	a4,(a0)+
	moveq	#$00,d6
	move.b	$0001(a2),d6
	subq.b	#$1,d6
	lea	MT_Data(pc),a4
	adda.l	-$001c(a4),a4
	lsl.w	#$5,d6
	adda.w	d6,a4
	move.l	a4,(a0)+
	move.l	#-$66670000,(a0)+
	move.l	#$00000800,(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.w	#$0010,$0004(a3)
	clr.w	$0008(a3)
	lea	$0010(a3),a3
	dbf	d0,E36
	lea	E123(pc),a0
	move.l	#-$00000001,(a0)
	lea	E124(pc),a0
	move.l	#$00000001,(a0)
	move.w	#-$7ff1,$00dff096
	rts	

E37	lea	E137(pc),a0
	cmpi.l	#$00000001,(a0)
	beq.s	E38
	lea	E42(pc),a1
	dc.b	$23,$78,$00,$6c,$00,$02
	;	move.l   ($006c).w,$0002(a1)
	lea	MT_Music(pc),a1
	nop	
	nop	
	move.l	#$00000001,(a0)

E38	lea	E134(pc),a0
	clr.l	(a0)
	lea	E135(pc),a0
	clr.l	(a0)
	lea	MT_Data(pc),a0
	adda.l	-$0014(a0),a0
	lea	$0020(a0),a0
	lea	E136(pc),a1
	move.l	(a0),(a1)
	rts	

	dc.b	$41,$fa,$0e,$a8,$4a,$90
	dc.b	$67,$14,$43,$fa,$01,$06
	dc.b	$21,$e9,$00,$02,$00,$6c
	dc.b	$33,$fc,$00,$0f,$00,$df
	dc.b	$f0,$96,$42,$90,$4e,$75

MT_Music	movem.l	d0-d7/a0-a6,-(a7)
	lea	E138(pc),a0
	move.w	#$0001,(a0)
	lea	E125(pc),a0
	lea	$00dff0a0,a1
	lea	E129(pc),a5
	bsr.l	E43
	lea	E138(pc),a0
	move.w	#$0002,(a0)
	lea	E126(pc),a0
	lea	$00dff0b0,a1
	lea	E130(pc),a5
	bsr.l	E43
	lea	E138(pc),a0
	move.w	#$0008,(a0)
	lea	E128(pc),a0
	lea	$00dff0d0,a1
	lea	E132(pc),a5
	bsr.l	E43
	lea	E138(pc),a0
	move.w	#$0004,(a0)
	lea	E127(pc),a0
	lea	$00dff0c0,a1
	lea	E131(pc),a5
	bsr.l	E43
	lea	E136(pc),a0
	addq.l	#$1,(a0)
	lea	MT_Data(pc),a1
	adda.l	-$0014(a1),a1
	lea	$0020(a1),a1
	move.l	(a1),d0
	cmp.l	(a0),d0
	bcc.s	E40
	clr.l	(a0)
E40	lea	E134(pc),a1
	clr.l	(a1)
	lea	E135(pc),a1
	clr.l	(a1)
	tst.l	(a0)
	bne.s	E41
	lea	E123(pc),a0
	lea	MT_Data(pc),a1
	adda.l	-$0014(a1),a1
	lea	$0018(a1),a1
	addq.l	#$1,(a0)
	move.l	(a0),d0
	cmp.l	(a1),d0
	bne.s	E41
	clr.l	(a0)
	lea	E134(pc),a0
	move.l	#$00000001,(a0)
	lea	E124(pc),a0
	lea	MT_Data(pc),a1
	adda.l	-$0014(a1),a1
	lea	$001c(a1),a1
	lea	E135(pc),a2
	addq.l	#$1,(a0)
	move.l	(a1),d0
	cmp.l	(a0),d0
	bhi.s	E41
	move.l	#$00000001,(a0)
	move.l	#$00000001,(a2)
E41	bsr.l	E108
	bsr.l	E107
	bsr.l	E86
	movem.l	(a7)+,d0-d7/a0-a6
E42	rts	

	dc.b	$00,$fc,$0c,$d8

E43	lea	E119(pc),a6
	clr.l	(a6)
	lea	E120(pc),a6
	clr.l	(a6)
	lea	E121(pc),a6
	clr.l	(a6)
	lea	E99(pc),a6
	clr.l	(a6)
	lea	E122(pc),a6
	clr.w	(a6)
	lea	E136(pc),a6
	tst.l	(a6)
	bne.l	E58
	lea	E134(pc),a6
	cmpi.l	#$00000001,(a6)
	bne.s	E45
	clr.b	$0013(a0)
	addq.l	#$6,(a0)
	lea	E135(pc),a6
	cmpi.l	#$00000001,(a6)
	bne.s	E44
	move.l	(a5),(a0)
E44	movea.l	(a0),a2
	move.l	(a2),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	MT_Data(pc),a2
	adda.l	-$0008(a2),a2
	movea.l	$00(a2,d0.w),a2
	lea	MT_Data(pc),a6
	adda.l	-$000c(a6),a6
	adda.l	a6,a2
	move.l	a2,$0004(a0)
E45	tst.b	$0013(a0)
	bne.l	E57
	movea.l	$0004(a0),a2
	clr.w	d0
	move.b	$0001(a2),d0
	tst.b	d0
	beq.l	E49
	subq.w	#$1,d0
	lsl.w	#$5,d0
	lea	MT_Data(pc),a3
	adda.l	-$001c(a3),a3
	adda.w	d0,a3
	lea	E122(pc),a6
	move.w	#$0010,(a6)
	tst.b	$001f(a0)
	beq.s	E46
	move.w	E138(pc),$00dff096
E46	clr.b	$001f(a0)
	move.l	(a3),d0
	cmpi.b	#$10,d0
	bcc.l	E78
E47	clr.b	$001c(a0)
	move.b	d0,$001d(a0)
	subq.b	#$1,d0
	lsl.w	#$4,d0
	lea	MT_Data(pc),a4
	adda.l	-$0010(a4),a4
	adda.w	d0,a4
	moveq	#$00,d1
	move.b	(a4),d1
	move.b	$0001(a4),$001e(a0)
	subq.w	#$1,d1
	lsl.w	#$5,d1
	lea	MT_Data(pc),a6
	adda.l	-$0018(a6),a6
	add.l	a6,d1
	lea	E99(pc),a6
	cmpi.l	#$00000001,(a6)
	beq.s	E48
	lea	E119(pc),a6
	move.l	d1,(a6)
E48	move.l	a3,$0008(a0)
	clr.b	$0012(a0)
	clr.w	$001a(a0)
	clr.w	$0016(a0)
	move.b	$0004(a2),$0013(a0)
	bra.s	E50

E49	tst.b	(a2)
	beq.s	E50
	moveq	#$00,d0
	move.b	$0004(a2),$0013(a0)
	move.b	$001d(a0),d0
	moveq	#$01,d1
	tst.b	$001f(a0)
	bne.l	E78
E50	moveq	#$00,d1
	move.b	(a2),d1
	tst.b	d1
	beq.l	E56
	cmpi.b	#-$01,d1
	bne.s	E51
	move.b	$0004(a2),$0013(a0)
	bra.l	E56

E51	move.b	$0004(a2),$0013(a0)
	lea	E133(pc),a3
	movea.l	(a0),a4
	add.b	$0005(a4),d1
	add.w	d1,d1
	move.w	$00(a3,d1.w),d2
	movea.l	a4,a6
	movea.l	$0008(a0),a4
	clr.w	d3
	move.b	$001e(a4),d3
	lsl.w	#$3,d3
	move.w	d3,d2
	lsl.w	#$4,d2
	add.w	d2,d3
	adda.w	d3,a3
	move.w	$02(a3,d1.w),d2
	movea.l	a6,a4
	move.w	d2,$000c(a0)
	move.b	d1,$0010(a0)
	lea	E120(pc),a6
	move.w	d2,(a6)
	clr.b	$0012(a0)
	clr.w	$0014(a0)
	clr.w	$0016(a0)
	clr.w	$001a(a0)
	clr.b	$000f(a0)
	move.b	$0002(a2),d2
	tst.b	d2
	bne.s	E52
	tst.b	$0003(a2)
	beq.l	E55
	movea.l	$0008(a0),a3
	lea	$0014(a3),a3
	move.b	$0003(a2),$0001(a3)
	move.b	$0003(a2),(a3)
	move.b	$0004(a2),$0013(a0)
	clr.b	$000f(a0)
	movea.l	$0008(a0),a3
	move.b	$001d(a3),$0019(a0)
	clr.b	$001e(a0)
	bra.l	E56

E52	cmpi.b	#$02,d2
	bne.s	E53
	lea	MT_Data(pc),a6
	adda.l	-$0014(a6),a6
	lea	$0020(a6),a6
	move.b	$0003(a2),$0003(a6)
	move.b	$0004(a2),$0013(a0)
	clr.b	$000f(a0)
	movea.l	$0008(a0),a3
	move.b	$001d(a3),$0019(a0)
	clr.b	$001e(a0)
	bra.s	E56

E53	cmpi.b	#$03,d2
	bne.s	E54
	lea	MT_Data(pc),a6
	adda.l	-$0014(a6),a6
	lea	$0018(a6),a6
	move.b	$0003(a2),$0003(a6)
	clr.b	$000f(a0)
	move.b	$0004(a2),$0013(a0)
	movea.l	$0008(a0),a3
	move.b	$001d(a3),$0019(a0)
	clr.b	$001e(a0)
	bra.l	E56

E54	add.b	$0005(a4),d2
	move.b	d2,$000e(a0)
	move.b	$0003(a2),$000f(a0)
	move.b	$0004(a2),$0013(a0)
E55	movea.l	$0008(a0),a3
	move.b	$001d(a3),$0019(a0)
E56	addq.w	#$5,a2
	move.l	a2,$0004(a0)
	bra.s	E58

E57	subq.b	#$1,$0013(a0)
E58	movea.l	$0008(a0),a3
	lea	$0014(a3),a3
	clr.w	d3
	clr.w	d2
	clr.w	d1
	lea	E121(pc),a6
	move.b	$0012(a0),d1
	tst.b	d1
	beq.s	E59
	addq.w	#$2,a3
	cmpi.b	#$02,d1
	beq.s	E60
	addq.w	#$2,a3
	cmpi.b	#$04,d1
	beq.s	E62
	addq.w	#$2,a3
	cmpi.b	#$06,d1
	beq.l	E63
	bra.l	E65

E59	move.b	(a3),d1
	move.b	$0001(a3),d2
	move.b	$0014(a0),d3
	add.w	d1,d3
	move.w	d3,(a6)
	move.b	d3,$0014(a0)
	cmp.w	d2,d3
	bls.l	E65
	addq.b	#$2,$0012(a0)
	move.w	d2,(a6)
	move.b	d2,$0014(a0)
	bra.l	E65

E60	move.b	(a3),d1
	move.b	$0001(a3),d2
	move.b	$0014(a0),d3
	sub.w	d1,d3
	move.w	d3,(a6)
	move.b	d3,$0014(a0)
	cmp.w	d2,d3
	bls.s	E61
	cmpi.w	#-$0100,d3
	bcc.s	E61
	bra.l	E65

E61	addq.b	#$2,$0012(a0)
	move.w	d2,(a6)
	move.b	d2,$0014(a0)
	move.b	$0002(a3),$0015(a0)
	bra.l	E65

E62	move.b	$0014(a0),d3
	move.w	d3,(a6)
	subq.b	#$1,$0015(a0)
	tst.b	$0015(a0)
	bne.l	E65
	addq.b	#$2,$0012(a0)
	bra.l	E65

E63	move.b	(a3),d1
	move.b	$0001(a3),d2
	move.b	$0014(a0),d3
	sub.w	d1,d3
	move.w	d3,(a6)
	move.b	d3,$0014(a0)
	cmp.w	d2,d3
	bls.s	E64
	cmpi.w	#-$0100,d3
	bhi.s	E64
	bra.s	E65

E64	addq.b	#$2,$0012(a0)
	move.w	d2,(a6)
	move.b	d2,$0014(a0)
E65	movea.l	$0008(a0),a2
	addq.b	#$1,$0011(a0)
	andi.b	#$0f,$0011(a0)
	clr.w	d1
	move.b	$0011(a0),d1
	lea	$0004(a2),a2
	adda.w	d1,a2
	move.b	(a2),d1
	clr.w	d2
	move.b	$0010(a0),d2
	add.w	d1,d1
	add.b	d1,d2
	lea	E133(pc),a2
	adda.w	d2,a2
	move.w	(a2),d2
	movea.l	$0008(a0),a6
	clr.w	d3
	move.b	$001e(a6),d3
	lsl.w	#$3,d3
	move.w	d3,d2
	lsl.w	#$4,d2
	add.w	d2,d3
	adda.w	d3,a2
	move.w	(a2),d2
	move.w	d2,$000c(a0)
	lea	E120(pc),a6
	move.w	d2,(a6)
	clr.w	d3
	move.b	$000f(a0),d3
	tst.b	d3
	beq.l	E67
	neg.b	d3
	ext.w	d3
	clr.w	d4
	move.b	$000e(a0),d4
	add.w	d4,d4
	lea	E133(pc),a4
	adda.w	d4,a4
	movea.l	$0008(a0),a6
	moveq	#$00,d5
	move.b	$001e(a6),d5
	lsl.w	#$3,d5
	move.w	d5,d4
	lsl.w	#$4,d4
	add.w	d4,d5
	adda.w	d5,a4
	move.w	(a4),d4
	btst	#$0f,d3
	beq.s	E66
	move.w	$0016(a0),d2
	add.w	d3,d2
	add.w	d2,$000c(a0)
	move.w	d2,$0016(a0)
	move.w	$000c(a0),d2
	cmp.w	d2,d4
	bcs.s	E67
	move.b	$000e(a0),d3
	add.b	d3,d3
	move.b	d3,$0010(a0)
	move.w	d4,$000c(a0)
	clr.w	$0016(a0)
	clr.b	$000f(a0)
	bra.l	E67

E66	move.w	$0016(a0),d2
	add.w	d3,d2
	add.w	d2,$000c(a0)
	move.w	d2,$0016(a0)
	move.w	$000c(a0),d2
	cmp.w	d2,d4
	bhi.s	E67
	move.b	$000e(a0),d3
	add.b	d3,d3
	move.b	d3,$0010(a0)
	move.w	d4,$000c(a0)
	clr.w	$0016(a0)
	clr.b	$000f(a0)
E67	movea.l	$0008(a0),a4
	tst.b	$001c(a4)
	beq.s	E69
	tst.b	$0019(a0)
	bne.s	E68
	moveq	#$00,d0
	move.b	$001c(a4),d0
	subq.b	#$1,d0
	lsl.w	#$5,d0
	lea	MT_Data(pc),a6
	adda.l	-$0018(a6),a6
	add.l	a6,d0
	movea.l	d0,a4
	addq.b	#$1,$0018(a0)
	andi.b	#$1f,$0018(a0)
	clr.w	d0
	move.b	$0018(a0),d0
	adda.w	d0,a4
	clr.w	d1
	move.b	(a4),d1
	ext.w	d1
	ext.l	d1
	asr.w	#$2,d1
	add.w	d1,$000c(a0)
	bra.l	E69

E68	subq.b	#$1,$0019(a0)
E69	movea.l	$0008(a0),a4
	move.b	$001f(a4),d4
	ext.w	d4
	neg.w	d4
	add.w	d4,$001a(a0)
	move.w	$001a(a0),d4
	add.w	d4,$000c(a0)
	tst.b	$001f(a0)
	bne.s	E73
	tst.b	$001e(a0)
	bne.s	E72
	cmpi.b	#$10,$001c(a0)
	beq.s	E71
	lea	MT_Data(pc),a2
	adda.l	-$0010(a2),a2
	clr.w	d0
	move.b	$001d(a0),d0
	subq.b	#$1,d0
	lsl.w	#$4,d0
	adda.w	d0,a2
	clr.w	d0
	move.b	$001c(a0),d0
	adda.w	d0,a2
	cmpi.b	#-$01,(a2)
	bne.s	E70
	move.b	$0001(a2),$001c(a0)
	andi.b	#-$02,$001c(a0)
	bra.s	E71

E70	lea	MT_Data(pc),a3
	adda.l	-$0018(a3),a3
	move.b	(a2),d0
	subq.b	#$1,d0
	lsl.w	#$5,d0
	adda.w	d0,a3
	lea	E119(pc),a6
	move.l	a3,(a6)
	move.b	$0001(a2),$001e(a0)
	addq.b	#$2,$001c(a0)
E71	bra.s	E73

E72	subq.b	#$1,$001e(a0)
E73	lea	E119(pc),a6
	tst.l	(a6)
	beq.s	E74
	lea	E119(pc),a6
	move.l	(a6),(a1)
E74	lea	E120(pc),a6
	tst.l	(a6)
	beq.s	E75
	move.w	$000c(a0),$0006(a1)
E75	lea	E121(pc),a6
	tst.l	(a6)
	beq.s	E76
	move.w	(a6),d0
	lsr.w	#$2,d0
	move.w	d0,$0008(a1)
E76	lea	E122(pc),a6
	tst.w	(a6)
	beq.s	E77
	move.w	(a6),$0004(a1)
E77	move.w	#-$7ff1,$00dff096
	rts	

E78	movem.l	d0-d7/a0-a6,-(a7)
	lea	E104(pc),a6
	move.l	a5,(a6)
	lea	E105(pc),a6
	move.l	a3,(a6)
	lea	E138(pc),a6
	cmpi.w	#$0001,(a6)
	bne.s	E79
	lea	E100(pc),a5
	bra.s	E82

E79	cmpi.w	#$0002,(a6)
	bne.s	E80
	lea	E101(pc),a5
	bra.s	E82

E80	cmpi.w	#$0004,(a6)
	bne.s	E81
	lea	E102(pc),a5
	bra.s	E82

E81	lea	E103(pc),a5
E82	tst.b	$001f(a0)
	beq.s	E83
	move.w	(a6),$00dff096
E83	move.l	d0,d1
	subi.w	#$0010,d0
	asl.w	#$5,d0
	lea	MT_Data(pc),a3
	adda.l	-$0004(a3),a3
	addq.w	#$4,a3
	adda.w	d0,a3
	move.l	d1,d0
	lea	MT_Data(pc),a4
	adda.l	-$0004(a4),a4
	adda.l	(a4),a4
	addq.w	#$4,a4
	adda.l	(a3),a4
	lea	E119(pc),a6
	move.l	a4,(a6)
	lea	E99(pc),a6
	move.l	#$00000001,(a6)
	lea	MT_Data(pc),a4
	adda.l	-$0004(a4),a4
	adda.l	(a4),a4
	addq.w	#$4,a4
	cmpi.l	#$00030d3f,$0004(a3)		; ABSOLUTE ADDRESS?
	bne.s	E84
	movea.l	#-$00000001,a4
	bra.s	E85

E84	adda.l	$0004(a3),a4
E85	move.l	a4,(a5)
	move.l	a4,d1
	lea	MT_Data(pc),a4
	adda.l	-$0004(a4),a4
	adda.l	(a4),a4
	addq.w	#$4,a4
	adda.l	$0008(a3),a4
	suba.l	d1,a4
	move.l	a4,d1
	asr.l	#$1,d1
	move.l	d1,$0004(a5)
	movea.l	E119(pc),a4
	lea	MT_Data(pc),a5
	adda.l	-$0004(a5),a5
	adda.l	(a5),a5
	addq.w	#$4,a5
	suba.l	a5,a4
	move.l	$0008(a3),d2
	sub.l	a4,d2
	asr.l	#$1,d2
	lea	E122(pc),a6
	move.w	d2,(a6)
	move.b	#$01,$001f(a0)
	movem.l	(a7)+,d0-d7/a0-a6
	cmpi.l	#$00000001,d1
	beq.l	E50
	bra.l	E47

E86	lea	E125(pc),a0
	lea	E100(pc),a1
	cmpi.b	#$01,$001f(a0)
	bne.l	E87
	move.b	#$02,$001f(a0)
	bra.l	E89

E87	cmpi.b	#$02,$001f(a0)
	bne.l	E89
	move.b	#$03,$001f(a0)
	cmpi.l	#-$00000001,(a1)
	beq.s	E88
	move.l	(a1),$00dff0a0
	move.l	$0004(a1),d0
	move.w	d0,$00dff0a4
	bra.s	E89

E88	lea	E106(pc),a0
	move.l	a0,$00dff0a0
	move.w	#$0001,$00dff0a4
E89	lea	E126(pc),a0
	lea	E101(pc),a1
	cmpi.b	#$01,$001f(a0)
	bne.s	E90
	move.b	#$02,$001f(a0)
	bra.s	E92

E90	cmpi.b	#$02,$001f(a0)
	bne.s	E92
	move.b	#$03,$001f(a0)
	cmpi.l	#-$00000001,(a1)
	beq.s	E91
	move.l	(a1),$00dff0b0
	move.l	$0004(a1),d0
	move.w	d0,$00dff0b4
	bra.s	E92

E91	lea	E106(pc),a0
	move.l	a0,$00dff0b0
	move.w	#$0001,$00dff0b4
E92	lea	E127(pc),a0
	lea	E102(pc),a1
	cmpi.b	#$01,$001f(a0)
	bne.s	E93
	move.b	#$02,$001f(a0)
	bra.s	E95

E93	cmpi.b	#$02,$001f(a0)
	bne.s	E95
	move.b	#$03,$001f(a0)
	cmpi.l	#-$00000001,(a1)
	beq.s	E94
	move.l	(a1),$00dff0c0
	move.l	$0004(a1),d0
	move.w	d0,$00dff0c4
	bra.s	E95

E94	lea	E106(pc),a0
	move.l	a0,$00dff0c0
	move.w	#$0001,$00dff0c4
E95	lea	E128(pc),a0
	lea	E103(pc),a1
	cmpi.b	#$01,$001f(a0)
	bne.s	E96
	move.b	#$02,$001f(a0)
	bra.s	E98

E96	cmpi.b	#$02,$001f(a0)
	bne.s	E98
	move.b	#$03,$001f(a0)
	cmpi.l	#-$00000001,(a1)
	beq.s	E97
	move.l	(a1),$00dff0d0
	move.l	$0004(a1),d0
	move.w	d0,$00dff0d4
	bra.s	E98

E97	lea	E106(pc),a0
	move.l	a0,$00dff0d0
	move.w	#$0001,$00dff0d4
E98	rts	

E99	dc.b	$00,$00,$00,$00
E100	dc.b	$00,$04,$ab,$d1
	dc.b	$00,$00,$0c,$00
E101	dc.b	$00,$04,$ab,$d1
	dc.b	$00,$00,$0c,$00
E102	dc.b	$00,$04,$ab,$d1
	dc.b	$00,$00,$0c,$00
E103	dc.b	$00,$04,$ab,$d1
	dc.b	$00,$00,$0c,$00
E104	dc.b	$00,$04,$7b,$4a
E105	dc.b	$00,$04,$84,$fe
E106	dc.b	$00,$00

E107	lea	MT_Data(pc),a0
	adda.l	-$0018(a0),a0
	lea	E117(pc),a6
	adda.l	(a6),a0
	neg.b	(a0)
	rts	

E108	lea	MT_Data(pc),a0
	adda.l	-$0014(a0),a0
	lea	$0024(a0),a0
	move.l	(a0),d0
	beq.l	E111
	lea	E115(pc),a6
	tst.l	(a6)
	bne.l	E110
	move.l	(a0),(a6)
	lea	MT_Data(pc),a6
	adda.l	-$0014(a6),a6
	move.l	(a6),d0
	subq.w	#$1,d0
	lsl.w	#$5,d0
	lea	MT_Data(pc),a0
	adda.l	-$0018(a0),a0
	adda.w	d0,a0
	lea	MT_Data(pc),a6
	adda.l	-$0014(a6),a6
	addq.w	#$8,a6
	move.l	(a6),d0
	subq.w	#$1,d0
	asl.w	#$5,d0
	lea	MT_Data(pc),a1
	adda.l	-$0018(a1),a1
	adda.w	d0,a1
	lea	E117(pc),a6
	addq.l	#$1,(a6)
	andi.l	#$0000001f,(a6)
	lea	MT_Data(pc),a6
	adda.l	-$0014(a6),a6
	lea	$0010(a6),a6
	move.l	(a6),d0
	subq.w	#$1,d0
	asl.w	#$5,d0
	lea	MT_Data(pc),a2
	adda.l	-$0018(a2),a2
	adda.w	d0,a2
	lea	E117(pc),a6
	move.l	(a6),d1
	moveq	#$1f,d0
E109	clr.w	d2
	clr.w	d3
	move.b	$00(a0,d0.w),d2
	move.b	$00(a1,d1.w),d3
	addi.b	#-$80,d2
	addi.b	#-$80,d3
	add.w	d3,d2
	asr.w	#$1,d2
	subi.b	#-$80,d2
	move.b	d2,$00(a2,d0.w)
	subq.w	#$1,d1
	andi.w	#$001f,d1
	dbf	d0,E109
E110	lea	E115(pc),a6
	subq.l	#$1,(a6)
E111	lea	MT_Data(pc),a1
	adda.l	-$0014(a1),a1
	lea	$0028(a1),a1
	move.l	(a1),d0
	beq.l	E114
	lea	E116(pc),a2
	tst.l	(a2)
	bne.l	E113
	move.l	(a1),(a2)
	lea	MT_Data(pc),a0
	adda.l	-$0014(a0),a0
	addq.w	#$4,a0
	move.l	(a0),d0
	subq.w	#$1,d0
	asl.w	#$5,d0
	lea	MT_Data(pc),a0
	adda.l	-$0018(a0),a0
	adda.w	d0,a0
	lea	MT_Data(pc),a1
	adda.l	-$0014(a1),a1
	lea	$000c(a1),a1
	move.l	(a1),d0
	subq.w	#$1,d0
	asl.w	#$5,d0
	lea	MT_Data(pc),a1
	adda.l	-$0018(a1),a1
	adda.w	d0,a1
	lea	E118(pc),a6
	addq.l	#$1,(a6)
	andi.l	#$0000001f,(a6)
	lea	MT_Data(pc),a6
	adda.l	-$0014(a6),a6
	lea	$0014(a6),a6
	move.l	(a6),d0
	subq.w	#$1,d0
	asl.w	#$5,d0
	lea	MT_Data(pc),a2
	adda.l	-$0018(a2),a2
	adda.w	d0,a2
	lea	E118(pc),a6
	move.l	(a6),d1
	moveq	#$1f,d0
E112	clr.w	d2
	clr.w	d3
	move.b	$00(a0,d0.w),d2
	move.b	$00(a1,d1.w),d3
	addi.b	#-$80,d2
	addi.b	#-$80,d3
	add.w	d3,d2
	asr.w	#$1,d2
	subi.b	#-$80,d2
	move.b	d2,$00(a2,d0.w)
	subq.w	#$1,d1
	andi.w	#$001f,d1
	dbf	d0,E112
E113	lea	E116(pc),a6
	subq.l	#$1,(a6)
E114	rts	

E115	dc.b	$00,$00,$00,$05
E116	dcb.b	4,$00
E117	dcb.b	3,$00
	dc.b	$12
E118	dcb.b	4,$00
E119	dcb.b	4,$00
E120	dcb.b	4,$00
E121	dcb.b	4,$00
E122	dcb.b	4,$00
E123	dcb.b	3,$00
	dc.b	$24
E124	dc.b	$00,$00,$00,$01
E125	dc.b	$00,$03,$2b,$ba,$00,$03
	dc.b	$38,$0b,$00,$03,$32,$6a
	dc.b	$01,$90,$00,$00,$5e,$0f
	dc.b	$02,$1b,$80,$00,$00,$00
	dc.b	$0f,$00,$00,$00,$10,$01
	dc.b	$00,$00
E126	dc.b	$00,$03,$2d,$16,$00,$03
	dc.b	$39,$d7,$00,$03,$51,$0a
	dc.b	$0c,$9c,$00,$00,$00,$0f
	dc.b	$08,$1b,$00,$00,$00,$00
	dc.b	$0f,$00,$0c,$93,$02,$00
	dc.b	$56,$00
E127	dc.b	$00,$03,$2e,$72,$00,$03
	dc.b	$39,$d7,$00,$03,$51,$0a
	dc.b	$0c,$9c,$00,$00,$00,$0f
	dc.b	$08,$1b,$00,$00,$00,$00
	dc.b	$0f,$00,$0c,$93,$02,$00
	dc.b	$56,$00
E128	dc.b	$00,$03,$2f,$ce,$00,$03
	dc.b	$39,$dc,$00,$03,$32,$aa
	dc.b	$06,$50,$17,$00,$2e,$0f
	dc.b	$02,$1b,$93,$00,$00,$00
	dc.b	$01,$00,$00,$00,$10,$0e
	dc.b	$00,$00
E129	dc.b	$00,$03,$2b,$ba
E130	dc.b	$00,$03,$2d,$16
E131	dc.b	$00,$03,$2e,$72
E132	dc.b	$00,$03,$2f,$ce
E133	dc.b	$00,$00,$16,$80,$15,$30
	dc.b	$14,$00,$12,$e0,$11,$d0
	dc.b	$10,$d0,$0f,$e0,$0f,$00
	dc.b	$0e,$20,$0d,$60,$0c,$a0
	dc.b	$0b,$e8,$0b,$40,$0a,$98
	dc.b	$0a,$00,$09,$70,$08,$e8
	dc.b	$08,$68,$07,$f0,$07,$80
	dc.b	$07,$10,$06,$b0,$06,$50
	dc.b	$05,$f4,$05,$a0,$05,$4c
	dc.b	$05,$00,$04,$b8,$04,$74
	dc.b	$04,$34,$03,$f8,$03,$c0
	dc.b	$03,$88,$03,$58,$03,$28
	dc.b	$02,$fa,$02,$d0,$02,$a6
	dc.b	$02,$80,$02,$5c,$02,$3a
	dc.b	$02,$1a,$01,$fc,$01,$e0
	dc.b	$01,$c4,$01,$ac,$01,$94
	dc.b	$01,$7d,$01,$68,$01,$53
	dc.b	$01,$40,$01,$2e,$01,$1d
	dc.b	$01,$0d,$00,$fe,$00,$f0
	dc.b	$00,$e2,$00,$d6,$00,$ca
	dc.b	$00,$be,$00,$b4,$00,$aa
	dc.b	$00,$a0,$00,$97,$00,$8f
	dc.b	$00,$87,$00,$7f
	dcb.b	16,$00
	dc.b	$0f,$bc,$0e,$de,$0e,$00
	dc.b	$0d,$42,$0c,$84,$0b,$c5
	dc.b	$0b,$27,$0a,$88,$09,$ea
	dc.b	$09,$5b,$08,$dc,$08,$5d
	dc.b	$07,$de,$07,$6f,$07,$00
	dc.b	$06,$a1,$06,$42,$05,$e3
	dc.b	$05,$94,$05,$44,$04,$f5
	dc.b	$04,$ae,$04,$6e,$04,$2f
	dc.b	$03,$ef,$03,$b8,$03,$80
	dc.b	$03,$51,$03,$21,$02,$f2
	dc.b	$02,$ca,$02,$a2,$02,$7b
	dc.b	$02,$57,$02,$37,$02,$18
	dc.b	$01,$f8,$01,$dc,$01,$c0
	dc.b	$01,$a9,$01,$91,$01,$79
	dc.b	$01,$65,$01,$51,$01,$36
	dc.b	$01,$2c,$01,$1c,$01,$0c
	dc.b	$00,$fc,$00,$ee,$00,$e0
	dc.b	$00,$d5,$00,$c9,$00,$bd
	dc.b	$00,$b3,$00,$a9,$00,$9f
	dc.b	$00,$96,$00,$8e,$00,$86
	dcb.b	16,$00
	dc.b	$0f,$99,$0e,$bd,$0d,$e0
	dc.b	$0d,$24,$0c,$67,$0b,$ab
	dc.b	$0b,$0e,$0a,$70,$09,$d3
	dc.b	$09,$46,$08,$c8,$08,$4a
	dc.b	$07,$cd,$07,$5f,$06,$f0
	dc.b	$06,$92,$06,$34,$05,$d6
	dc.b	$05,$87,$05,$38,$04,$ea
	dc.b	$04,$a3,$04,$64,$04,$25
	dc.b	$03,$e7,$03,$b0,$03,$78
	dc.b	$03,$49,$03,$1a,$02,$eb
	dc.b	$02,$c4,$02,$9c,$02,$75
	dc.b	$02,$52,$02,$32,$02,$13
	dc.b	$01,$f4,$01,$d8,$01,$bc
	dc.b	$01,$a5,$01,$8d,$01,$76
	dc.b	$01,$62,$01,$4e,$01,$3b
	dc.b	$01,$29,$01,$19,$01,$0a
	dc.b	$00,$fa,$00,$ec,$00,$de
	dc.b	$00,$d3,$00,$c7,$00,$bb
	dc.b	$00,$b1,$00,$a7,$00,$9e
	dc.b	$00,$95,$00,$8d,$00,$85
	dcb.b	16,$00
	dc.b	$0f,$75,$0e,$9b,$0d,$c1
	dc.b	$0d,$06,$0c,$4b,$0b,$90
	dc.b	$0a,$f4,$0a,$58,$09,$bd
	dc.b	$09,$31,$08,$b4,$08,$37
	dc.b	$07,$bb,$07,$4e,$06,$e1
	dc.b	$06,$83,$06,$26,$05,$c8
	dc.b	$05,$7a,$05,$2c,$04,$df
	dc.b	$04,$99,$04,$5a,$04,$1c
	dc.b	$03,$de,$03,$a7,$03,$71
	dc.b	$03,$42,$03,$13,$02,$e4
	dc.b	$02,$bd,$02,$96,$02,$70
	dc.b	$02,$4d,$02,$2d,$02,$0e
	dc.b	$01,$ef,$01,$d4,$01,$b9
	dc.b	$01,$a1,$01,$8a,$01,$72
	dc.b	$01,$5f,$01,$4b,$01,$38
	dc.b	$01,$27,$01,$17,$01,$07
	dc.b	$00,$f8,$00,$ea,$00,$dd
	dc.b	$00,$d1,$00,$c5,$00,$b9
	dc.b	$00,$b0,$00,$a6,$00,$9c
	dc.b	$00,$94,$00,$8c,$00,$84
	dcb.b	16,$00
	dc.b	$0f,$51,$0e,$79,$0d,$a1
	dc.b	$0c,$e8,$0c,$2f,$0b,$75
	dc.b	$0a,$db,$0a,$41,$09,$a6
	dc.b	$09,$1b,$08,$a0,$08,$24
	dc.b	$07,$a9,$07,$3d,$06,$d1
	dc.b	$06,$74,$06,$18,$05,$bb
	dc.b	$05,$6e,$05,$21,$04,$d3
	dc.b	$04,$8e,$04,$50,$04,$12
	dc.b	$03,$d5,$03,$9f,$03,$69
	dc.b	$03,$3a,$03,$0c,$02,$de
	dc.b	$02,$b7,$02,$91,$02,$6a
	dc.b	$02,$47,$02,$28,$02,$09
	dc.b	$01,$eb,$01,$d0,$01,$b5
	dc.b	$01,$9d,$01,$86,$01,$6f
	dc.b	$01,$5c,$01,$49,$01,$35
	dc.b	$01,$24,$01,$14,$01,$05
	dc.b	$00,$f6,$00,$e8,$00,$db
	dc.b	$00,$cf,$00,$c3,$00,$b8
	dc.b	$00,$ae,$00,$a5,$00,$9b
	dc.b	$00,$92,$00,$8a,$00,$83
	dcb.b	16,$00
	dc.b	$0f,$2e,$0e,$57,$0d,$81
	dc.b	$0c,$ca,$0c,$12,$0b,$5b
	dc.b	$0a,$c2,$0a,$29,$09,$90
	dc.b	$09,$06,$08,$8c,$08,$11
	dc.b	$07,$97,$07,$2c,$06,$c1
	dc.b	$06,$65,$06,$09,$05,$ae
	dc.b	$05,$61,$05,$15,$04,$c8
	dc.b	$04,$83,$04,$46,$04,$09
	dc.b	$03,$cc,$03,$96,$03,$61
	dc.b	$03,$33,$03,$05,$02,$d7
	dc.b	$02,$b1,$02,$8b,$02,$64
	dc.b	$02,$42,$02,$23,$02,$05
	dc.b	$01,$e6,$01,$cb,$01,$b1
	dc.b	$01,$9a,$01,$83,$01,$6c
	dc.b	$01,$59,$01,$46,$01,$32
	dc.b	$01,$21,$01,$12,$01,$03
	dc.b	$00,$f3,$00,$e6,$00,$d9
	dc.b	$00,$cd,$00,$c2,$00,$b6
	dc.b	$00,$ad,$00,$a3,$00,$99
	dc.b	$00,$91,$00,$89,$00,$82
	dcb.b	16,$00
	dc.b	$0f,$0b,$0e,$36,$0d,$62
	dc.b	$0c,$ac,$0b,$f6,$0b,$40
	dc.b	$0a,$a9,$0a,$11,$09,$7a
	dc.b	$08,$f1,$08,$78,$07,$ff
	dc.b	$07,$86,$07,$1b,$06,$b1
	dc.b	$06,$56,$05,$fb,$05,$a0
	dc.b	$05,$55,$05,$09,$04,$bd
	dc.b	$04,$79,$04,$3c,$04,$00
	dc.b	$03,$c3,$03,$8e,$03,$59
	dc.b	$03,$2b,$02,$fe,$02,$d0
	dc.b	$02,$ab,$02,$85,$02,$5f
	dc.b	$02,$3d,$02,$1e,$02,$00
	dc.b	$01,$e2,$01,$c7,$01,$ad
	dc.b	$01,$96,$01,$7f,$01,$68
	dc.b	$01,$56,$01,$43,$01,$30
	dc.b	$01,$1f,$01,$0f,$01,$00
	dc.b	$00,$f1,$00,$e4,$00,$d7
	dc.b	$00,$cb,$00,$c0,$00,$b4
	dc.b	$00,$ab,$00,$a2,$00,$98
	dc.b	$00,$90,$00,$88,$00,$80
	dcb.b	2,$00
E134	dcb.b	4,$00
E135	dcb.b	4,$00
E136	dcb.b	3,$00
	dc.b	$02
E137	dc.l	1
E138	dc.b	$00,$04,$00,$00
	dc.b	$00,$24,$00,$00
	dc.b	$01,$80,$00,$00
	dc.b	$02,$dc,$00,$00
	dc.b	$04,$38,$00,$00
	dc.b	$05,$94,$00,$00
	dc.b	$09,$94,$00,$00
	dc.b	$0b,$54,$00,$00
	dc.b	$0b,$80,$00,$00
	dc.b	$0c,$70,$00,$00
	dc.b	$15,$a0,$00,$00
	dc.b	$16,$90

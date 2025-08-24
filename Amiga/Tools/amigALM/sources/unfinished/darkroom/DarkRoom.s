;--------------------------------------;

WaitBm	MACRO
.1\@	tst.b	5(a6)
	beq	.1\@
.2\@	tst.b	5(a6)
	bne	.2\@
	ENDM

WaitBlt	MACRO
.1\@	btst	#6,2(a6)
	bne.s	.1\@
	ENDM

;--------------------------------------;

seg0	move.l	4.w,a6
	moveq	#0,d0
	lea	GfxName(pc),a1
	jsr	-552(a6)
	move.l	d0,GfxBase
	beq.l	Error
	move.l	d0,a6
	move.l	34(a6),OldView
	sub.l	a1,a1
	jsr	-222(a6)
	jsr	-270(a6)
	jsr	-270(a6)
	jsr	-228(a6)
	bsr.l	PlayMus
	lea	$dff000,a6
	move.w	#$0020,$96(a6)
	clr.l	$140(a6)

	move.l	#CopNull,$80(a6)
	bsr.l	ClrArea
	bsr.l	L7
	move.l	#CopNull,$80(a6)
	bsr.l	ClrArea
	bsr.l	L47
	move.l	#CopNull,$80(a6)
	bsr.l	ClrArea
	bsr.l	L81
	move.l	#CopNull,$80(a6)
	bsr.l	ClrArea
	bsr.l	L117

	bsr.l	StopMus
	move.w	#$8020,$dff096
	move.l	GfxBase(pc),a6
	jsr	-228(a6)
	move.l	OldView(pc),a1
	jsr	-222(a6)
	jsr	-270(a6)
	jsr	-270(a6)
	move.l	38(a6),$dff080
	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)
Error	moveq	#0,d0
	rts

;--------------------------------------;

ClrArea	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	lea	L221,a4
	move.w	#($30000>>8)-1,d4
.1	REPT	8
	movem.l	d0-d3/a0-a3,-(a4)
	ENDR
	dbf	d4,.1
	rts

;--------------------------------------;

GfxName	dc.b	"graphics.library",0,0
GfxBase	dc.l	0
OldView	dc.l	0

;--------------------------------------;

L7	bsr.l	L13
L8	bsr.l	L15

;	move.w	#$0fff,$dff182
	move.l	#L223,$0080(a6)
	bsr.l	L21
	bsr.l	L15
;	move.w	#$0fff,$dff182
	move.l	#L225,$0080(a6)
	bsr.l	L26

	move.w	L184(pc),d0
	move.b	L185(pc),d1
	sf	L35
	lea	L189,a0
	cmpi.w	#$0004,d0
	bne.s	L9
	cmpi.b	#-$10,d1
	bcs.s	L10
	lea	L192,a0
L9	cmpi.w	#$0008,d0
	bne.s	L10
	lea	L192,a0
L10	cmpi.w	#$000c,d0
	bcs.s	L11
	lea	L190,a0
	st	L35
L11	cmpi.w	#$0010,d0
	beq.s	L12
	move.l	a0,L17
	btst	#$06,$00bfe001
	bne.w	L8
L12	rts

;-------------------;

L13	lea	L224,a0
	move.l	#L204,d2
	lea	L225,a1
	move.l	#L215,d3
	moveq	#$00,d1
	moveq	#$03,d0
L14	move.w	d2,6(a0,d1)
	swap	d2
	move.w	d2,2(a0,d1)
	swap	d2
	move.w	d3,6(a1,d1)
	swap	d3
	move.w	d3,2(a1,d1)
	swap	d3
	addq.w	#8,d1
	addi.l	#$00002800,d2
	addi.l	#$00002800,d3
	dbf	d0,L14

	lea	L189,a0
	move.w	#$017f,d2
	move.w	#$0181,d3
	bsr.l	L18
	lea	L190,a0
	move.w	#-$0001,d2
	move.w	#$0180,d3
	bsr.l	L18
	lea	L192,a0
	move.w	#$0180,d2
	move.w	#$0001,d3
	bsr.l	L18
	move.l	#L223,$0080(a6)
	rts

;-------------------;

L15	addq.w	#$1,L16
	bsr.l	L36
	bsr.l	L31
	bsr.l	L41
	bsr.l	L39
	rts

L16	dc.b	$00,$00
L17	dc.l	L189

L18	move.w	d3,d6
	asl.w	#$2,d3
	move.w	d2,d5
	asl.w	#$2,d2
	add.w	d5,d2
	moveq	#$08,d1
L19	move.w	d2,d7
	moveq	#$0a,d0
L20	move.w	d3,d4
	add.w	d7,d4
	move.w	d4,(a0)+
	sub.w	d5,d7
	dbf	d0,L20
	sub.w	d6,d3
	dbf	d1,L19
	rts

L21	WaitBlt
	moveq	#0,d0
	move.l	d0,$40(a6)
	move.l	d0,$60(a6)
	move.l	d0,$64(a6)
	moveq	#-1,d0
	move.l	d0,$44(a6)
	move.w	#$0f80,$40(a6)
	move.l	#L208,$50(a6)
	move.l	#L210,$4c(a6)
	move.l	#L213,$48(a6)
	move.l	#L219,$54(a6)
	move.w	#256<<6+(320/16),$58(a6)
	WaitBlt
	move.w	#$0008,$62(a6)
	move.w	#$0fe6,$40(a6)
	move.l	#L219,$50(a6)
	move.l	#L198,$4c(a6)
	move.l	#L204,$48(a6)
	move.l	#L215,$54(a6)
	move.w	#256<<6+(320/16),$58(a6)
	WaitBlt
	move.w	#$0000,$62(a6)
	move.w	#$0f9a,$40(a6)
	move.l	#L204,$50(a6)
	move.l	#L215,$4c(a6)
	move.l	#L208,$48(a6)
	move.l	#L216,$54(a6)
	move.w	#256<<6+(320/16),$58(a6)
	WaitBlt
	move.w	#$0f9a,$40(a6)
	move.l	#L208,$50(a6)
	move.l	#L216,$4c(a6)
	move.l	#L210,$48(a6)
	move.l	#L217,$54(a6)
	move.w	#256<<6+(320/16),$58(a6)
	WaitBlt
	move.w	#$0f9a,$40(a6)
	move.l	#L210,$50(a6)
	move.l	#L217,$4c(a6)
	move.l	#L213,$48(a6)
	move.l	#L218,$54(a6)
	move.w	#256<<6+(320/16),$58(a6)
	rts

L26	WaitBlt
	moveq	#0,d0
	move.l	d0,$40(a6)
	move.l	d0,$60(a6)
	move.l	d0,$64(a6)
	moveq	#-1,d0
	move.l	d0,$44(a6)
	move.w	#$0f01,$40(a6)
	move.l	#L216,$50(a6)
	move.l	#L217,$4c(a6)
	move.l	#L218,$48(a6)
	move.l	#L219,$54(a6)
	move.w	#256<<6+(320/16),$58(a6)
	WaitBlt
	move.w	#$0008,$62(a6)
	move.w	#$0f89,$40(a6)
	move.l	#L219,$50(a6)
	move.l	#L198,$4c(a6)
	move.l	#L215,$48(a6)
	move.l	#L204,$54(a6)
	move.w	#256<<6+(320/16),$58(a6)
	WaitBlt
	move.w	#$0000,$0062(a6)
	move.w	#$0fa6,$0040(a6)
	move.l	#L215,$0050(a6)
	move.l	#L204,$004c(a6)
	move.l	#L216,$0048(a6)
	move.l	#L208,$0054(a6)
	move.w	#256<<6+(320/16),$0058(a6)
	WaitBlt
	move.w	#$0fa6,$0040(a6)
	move.l	#L216,$0050(a6)
	move.l	#L208,$004c(a6)
	move.l	#L217,$0048(a6)
	move.l	#L210,$0054(a6)
	move.w	#256<<6+(320/16),$0058(a6)
	WaitBlt
	move.w	#$0fa6,$0040(a6)
	move.l	#L217,$0050(a6)
	move.l	#L210,$004c(a6)
	move.l	#L218,$0048(a6)
	move.l	#L213,$0054(a6)
	move.w	#256<<6+(320/16),$0058(a6)
	rts

L31	move.l	L46(pc),d0
	add.w	L16(pc),d0
	ror.l	#$5,d0
	eori.w	#$1dc4,d0
	move.l	d0,L46
	lea	L198,a0
	tst.b	L35
	bne.s	L33
	moveq	#$03,d1
L32	eor.b	d0,$17b3(a0)
	swap	d0
	eor.b	d0,$17b4(a0)
	adda.w	#$0030,a0
	add.w	a0,d0
	ror.l	#$1,d0
	dbf	d1,L32
	rts

L33	moveq	#$03,d1
L34	clr.b	$17b3(a0)
	clr.b	$17b4(a0)
	adda.w	#$0030,a0
	dbf	d1,L34
	rts

L35	dc.b	$00,$00

L36	moveq	#$1f,d0
	and.w	L16(pc),d0
	add.w	d0,d0
	lea	L37(pc),a0
	move.w	$00(a0,d0.w),d0
	move.w	d0,L38
	rts

L37	dc.b	$00,$00,$00,$10,$00,$08
	dc.b	$00,$18,$00,$04,$00,$14
	dc.b	$00,$0c,$00,$1c,$00,$02
	dc.b	$00,$12,$00,$0a,$00,$1a
	dc.b	$00,$06,$00,$16,$00,$0e
	dc.b	$00,$1e,$00,$01,$00,$11
	dc.b	$00,$09,$00,$19,$00,$05
	dc.b	$00,$15,$00,$0d,$00,$1d
	dc.b	$00,$03,$00,$13,$00,$0b
	dc.b	$00,$1b,$00,$07,$00,$17
	dc.b	$00,$0f,$00,$1f
L38	dc.b	$00,$00

L39	move.w	L38(pc),d0
	muls	#$0018,d0
	move.w	L38(pc),d1
	asr.w	#$4,d1
	add.w	d1,d0
	add.w	d0,d0
	ext.l	d0
	lea	L220,a0
	suba.l	d0,a0
	move.w	L38(pc),d1
	ror.w	#$4,d1
	andi.w	#-$1000,d1
	ori.w	#$09f0,d1
	WaitBlt
	move.w	d1,$0040(a6)
	move.l	#$00000000,$44(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$00000000,$60(a6)
	move.l	#$00000000,$64(a6)
	move.l	a0,$0050(a6)
	move.l	#L198,$0054(a6)
	move.w	#$4018,$0058(a6)
	rts

L41	lea	L197,a0
	lea	L219,a4
	move.w	L38(pc),d5
	move.w	d5,d4
	muls	#$0180,d5
	add.w	d4,d5
	subq.w	#$1,d5
	move.w	#$0803,d3
	movea.l	L17(pc),a1
	adda.w	#$062c,a4
	adda.w	#$062c,a0
	move.w	#$062c,d7
	moveq	#$08,d6
	lea	$00dff002,a6
L42	btst	#6,(a6)
	bne.s	L42
	move.w	#$0000,$40(a6)
	move.l	#$ffffffff,$42(a6)
	move.l	#$002a002a,$62(a6)
L43	moveq	#$0a,d4
L44	move.w	(a1)+,d0
	add.w	d5,d0
	moveq	#$0f,d2
	and.w	d0,d2
	add.w	d2,d2
	move.w	l45.1(pc,d2.w),d2
	asr.w	#$3,d0
	lea	$00(a0,d0.w),a3
L45	btst	#$06,(a6)
	bne.s	L45
	move.w	d2,$003e(a6)
	movem.l	a3-a4,$004e(a6)
	move.w	d3,$0056(a6)
	subq.w	#$4,a0
	subq.w	#$4,a4
	dbf	d4,L44
	adda.w	d7,a0
	adda.w	d7,a4
	dbf	d6,L43
	lea	$00dff000,a6
	rts

l45.1	dc.w	$f9f0,$e9f0,$d9f0,$c9f0
	dc.w	$b9f0,$a9f0,$99f0,$89f0
	dc.w	$79f0,$69f0,$59f0,$49f0
	dc.w	$39f0,$29f0,$19f0,$09f0
L46	dc.b	$de,$ad,$be,$ef

;--------------------------------------;

L47	lea	$dff000,a6
L48	WaitBm
	movem.l	L59(pc),d0-d3
	move.l	d0,d4
	move.l	d1,d0
	move.l	d2,d1
	move.l	d3,d2
	move.l	d4,d3
	movem.l	d0-d3,L59

	move.l	d0,$e0(a6)
	move.l	d1,$e4(a6)
	move.l	d2,$e8(a6)
	move.l	#L214,$ec(a6)

	move.w	L55(pc),d0
	addq.w	#1,d0
	move.w	d0,L55
	move.l	L57(pc),a0
	cmp.w	L56(pc),d0
	bne.s	L51
	addq.w	#4,a0
	tst.b	1(a0)
	bpl.s	L50
	lea	L58(pc),a0

L50	moveq	#$00,d1
	move.b	(a0),d1
	add.w	d0,d1
	move.w	d1,L56
	move.l	a0,L57

L51	move.b	$0002(a0),d0
	move.b	$0003(a0),d1
	bsr.l	L69
	bsr.l	L75
	move.w	L55(pc),d0
	move.w	L184(pc),d0
	move.b	L185(pc),d1
	cmpi.w	#$0018,d0
	beq.s	L54
	cmpi.w	#$0014,d0
	bne.s	L52
	cmpi.b	#-$20,d1
	bcs.s	L52
	bsr.l	L61
L52	andi.w	#$007c,d1
	cmpi.b	#$40,d1
	bne.s	L53
	bsr.l	L66
L53	bsr.l	L68
	move.l	#L226,$0080(a6)
	btst	#6,$bfe001
	bne.l	L48
L54	rts

L55	dc.w	0
L56	dc.w	1
L57	dc.l	L58
L58	dc.b	$01,$00,$05,$ff
	dc.b	$01,$00,$02,$00
	dc.b	$01,$00,$07,$ff
	dc.b	$01,$00,$00,$00
	dc.b	$01,$00,$01,$ff
	dc.b	$01,$00,$06,$00
	dc.b	$01,$00,$03,$ff
	dc.b	$01,$00,$04,$00
	dc.b	$ff,$ff,$ff,$ff
L59	dc.l	L198
L60	dc.l	L206
	dc.l	L209
	dc.l	L211

L61	lea	L227,a0
	moveq	#$0f,d3
L62	addq.w	#$2,a0
	move.w	(a0),d0
	move.w	d0,d1
	move.w	d0,d2
	andi.w	#$000f,d0
	andi.w	#$00f0,d1
	andi.w	#$0f00,d2
	subq.w	#$1,d0
	bpl.s	L63
	moveq	#$00,d0
L63	subi.w	#$0010,d1
	bpl.s	L64
	moveq	#$00,d1
L64	subi.w	#$0100,d2
	bpl.s	L65
	moveq	#$00,d2
L65	or.w	d2,d0
	or.w	d1,d0
	move.w	d0,(a0)+
	dbf	d3,L62
	rts

L66	movea.l	L60(pc),a0
	adda.w	#$1192,a0
	moveq	#-$01,d0
	moveq	#$07,d1
L67	move.l	d0,(a0)
	move.l	d0,$0028(a0)
	move.l	d0,$0050(a0)
	move.l	d0,$0078(a0)
	adda.w	#$00a0,a0
	dbf	d1,L67
	rts

L68	movea.l	L60(pc),a0
	adda.w	#$1180,a0
	lea	L188,a1
	lea	L214,a2
	adda.w	#$1180,a2
	moveq	#$1f,d0
	and.w	L55(pc),d0
	mulu	#$0028,d0
	adda.w	d0,a0
	adda.w	d0,a1
	adda.w	d0,a2
	move.l	(a1)+,d2
	or.l	d2,(a0)+
	move.l	d2,(a2)+
	move.l	(a1)+,d2
	or.l	d2,(a0)+
	move.l	d2,(a2)+
	move.l	(a1)+,d2
	or.l	d2,(a0)+
	move.l	d2,(a2)+
	move.l	(a1)+,d2
	or.l	d2,(a0)+
	move.l	d2,(a2)+
	move.l	(a1)+,d2
	or.l	d2,(a0)+
	move.l	d2,(a2)+
	move.l	(a1)+,d2
	or.l	d2,(a0)+
	move.l	d2,(a2)+
	move.l	(a1)+,d2
	or.l	d2,(a0)+
	move.l	d2,(a2)+
	move.l	(a1)+,d2
	or.l	d2,(a0)+
	move.l	d2,(a2)+
	move.l	(a1)+,d2
	or.l	d2,(a0)+
	move.l	d2,(a2)+
	move.l	(a1)+,d2
	or.l	d2,(a0)+
	move.l	d2,(a2)+
	rts

L69	movea.l	L59(pc),a0
	lea	L203,a1
	move.w	#$00ff,d4
	moveq	#$28,d2
	WaitBlt
	moveq	#$00,d3
	move.w	d3,$0042(a6)
	move.l	d3,$0064(a6)
	moveq	#-$01,d3
	move.l	d3,$0044(a6)
L71	move.w	d1,d3
	eor.w	d4,d3
	btst	d0,d3
	beq.s	L73
	WaitBlt
	move.w	#$19f0,$0040(a6)
	movem.l	a0-a1,$0050(a6)
	move.w	#$0105,$0058(a6)
	adda.w	d2,a0
	adda.w	d2,a1
	dbf	d4,L71
	rts

L73	addq.w	#$2,a0
	WaitBlt
	move.w	#-$0610,$0040(a6)
	movem.l	a0-a1,$0050(a6)
	move.w	#$0105,$0058(a6)
	adda.w	#$0026,a0
	adda.w	d2,a1
	dbf	d4,L71
	rts

L75	lea	L203,a0
	lea	$0028(a0),a1
	suba.w	#$0028,a0
	movea.l	L60(pc),a2
	moveq	#-$20,d2
	moveq	#$13,d6
	WaitBlt
	move.w	#$0000,$0042(a6)
	moveq	#$26,d3
	move.w	d3,$0062(a6)
	move.w	d3,$0064(a6)
	move.w	d3,$0066(a6)
	moveq	#-$01,d3
	move.l	d3,$0044(a6)
L77	moveq	#$0f,d5
L78	move.w	d1,d3
	eor.w	d2,d3
	add.w	d4,d4
	btst	d0,d3
	bne.s	L79
	addq.w	#$1,d4
L79	addq.w	#$1,d2
	dbf	d5,L78
	WaitBlt
	move.w	#$0dd8,$0040(a6)
	movem.l	a0-a2,$004c(a6)
	move.w	d4,$0070(a6)
	move.w	#$4001,$0058(a6)
	addq.w	#$2,a0
	addq.w	#$2,a1
	addq.w	#$2,a2
	dbf	d6,L77
	rts

;--------------------------------------;

L81	lea	$dff000,a6
	bsr.l	L96
	bsr.l	L94
L82	WaitBm
	addq.w	#$1,L86
	move.w	#$07fe,d1
	move.l	L87(pc),d2
	add.l	L85(pc),d2
	move.l	d2,L87
	swap	d2
	addi.l	#$00000800,L85
	move.w	d2,d0
	and.w	d1,d0
	lea	L189,a0
	lea	$0200(a0),a1
	lea	L93(pc),a2
	move.w	$00(a0,d0.w),(a2)+
	move.w	$00(a1,d0.w),(a2)+
	lsr.w	#$1,d2
	addi.w	#$0780,d2
	move.w	d2,d0
	and.w	d1,d0
	move.w	$00(a0,d0.w),(a2)+
	move.w	$00(a1,d0.w),(a2)+
	lsr.w	#$1,d2
	addi.w	#$0780,d2
	move.w	d2,d0
	and.w	d1,d0
	move.w	$00(a0,d0.w),(a2)+
	move.w	$00(a1,d0.w),(a2)+
	lsr.w	#$1,d2
	addi.w	#$0780,d2
	move.w	d2,d0
	and.w	d1,d0
	move.w	$00(a0,d0.w),(a2)+
	move.w	$00(a1,d0.w),(a2)+
	lsr.w	#$1,d2
	addi.w	#$0780,d2
	move.w	d2,d0
	and.w	d1,d0
	move.w	$00(a0,d0.w),(a2)+
	move.w	$00(a1,d0.w),(a2)+
	dc.l	$4CFA001F
	dc.w	$0086
;	movem.l	L92(pc),d0-d4
	lea	L194,a0
	lea	$00(a0,d1.w),a1
	lea	$00(a0,d2.w),a2
	lea	$00(a0,d3.w),a3
	lea	$00(a0,d4.w),a4
	adda.w	d0,a0
	bsr.l	L114
	movem.l	L93(pc),d0-d4
	lea	L195,a0
	lea	$00(a0,d1.w),a1
	lea	$00(a0,d2.w),a2
	lea	$00(a0,d3.w),a3
	lea	$00(a0,d4.w),a4
	adda.w	d0,a0
	bsr.l	L108
	move.l	L89(pc),$0080(a6)
	lea	L88(pc),a0
	movem.l	(a0),d0-d3
	exg	d0,d1
	exg	d2,d3
	movem.l	d0-d3,(a0)
	cmpi.w	#$0020,L184
	beq.s	L84
	btst	#$06,$00bfe001
	bne.l	L82
L84	rts

L85	dc.b	$00,$08
	dcb.b	2,$00
L86	dcb.b	2,$00
L87	dcb.b	4,$00
L88	dc.l	L202
L89	dc.l	L207
L90	dc.l	L198
L91	dc.l	L199
L92	EQU	seg0+$00000a6a
L93	dcb.b	20,$00

L94	lea	L189,a0
	lea	$0400(a0),a1
	moveq	#$00,d4
	move.w	#$00ff,d3
L95	move.l	d4,d0
	swap	d0
	addi.l	#$000c90fe,d4
	move.w	d0,d2
	move.w	d0,d1
	mulu	d1,d1
	lsl.l	#$4,d1
	swap	d1
	mulu	d1,d0
	divu	#$1800,d0
	sub.w	d0,d2
	mulu	d1,d0
	divu	#$5000,d0
	add.w	d0,d2
	mulu	d1,d0
	divu	#-$5800,d0
	sub.w	d0,d2
	asr.w	#$4,d2
	move.w	d2,(a0)+
	move.w	d2,$07fe(a0)
	move.w	d2,-(a1)
	neg.w	d2
	move.w	d2,$03fe(a0)
	move.w	d2,$0400(a1)
	dbf	d3,L95
	rts

L96	lea	L200,a1
	lea	L201,a0
	moveq	#-1,d1
	moveq	#(320/8/4)-1,d0
L97	move.l	d1,(a0)+
	clr.l	(a1)+
	dbf	d0,L97
	lea	L101(pc),a0
	move.l	L88(pc),a1
	move.l	L89(pc),a2
	moveq	#$11,d0
L98	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,L98
	move.l	L90(pc),d0
	move.l	L88(pc),a0
	bsr.l	L99
	move.l	L91(pc),d0
	move.l	L89(pc),a0
	bsr.l	L99
	bsr.l	L102
	bsr.l	L106
	rts

L99	moveq	#$03,d1
L100	move.w	d0,$002e(a0)
	swap	d0
	move.w	d0,$002a(a0)
	swap	d0
	addq.w	#$8,a0
	addi.l	#$00000028,d0
	dbf	d1,L100
	rts

L101	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0100,$5000,$0102,$0000
	dc.w	$0104,$0000,$0180,$0000
	dc.w	$0108,$ffd8,$010a,$ffd8
	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000

L102	lea	L212,a0
	lea	$1200(a0),a1
	lea	L105(pc),a3
	lea	L113,a4
	moveq	#$00,d4
	moveq	#$3f,d7
L103	move.l	a0,(a4)+
	move.l	#L200,d1
	move.w	#$00f2,(a0)+
	move.w	d1,(a0)+
	move.w	#$00f0,(a0)+
	swap	d1
	move.w	d1,(a0)+
	move.l	#L201,d1
	move.w	#$00f2,(a1)+
	move.w	d1,(a1)+
	move.w	#$00f0,(a1)+
	swap	d1
	move.w	d1,(a1)+
	move.w	#$0180,d1
	move.w	#$01a0,d2
	moveq	#$0f,d6
L104	andi.w	#$007e,d4
	move.w	$00(a3,d4.w),d3
	addq.w	#$8,d4
	move.w	d1,(a0)+
	move.w	d3,(a0)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	addq.w	#$2,d1
	addq.w	#$2,d2
	dbf	d6,L104
	addq.w	#$2,d4
	dbf	d7,L103
	rts

L105	dcb.b	51,$00
	dc.b	$01,$00,$02,$00,$03,$00
	dc.b	$04,$00,$05,$00,$06,$00
	dc.b	$07,$00,$08,$00,$09,$00
	dc.b	$0a,$00,$0b,$00,$0c,$00
	dc.b	$0d,$00,$0e,$00,$0f,$02
	dc.b	$2f,$04,$4f,$08,$8f,$0a
	dc.b	$af,$0c,$cf,$0e,$ef,$0f
	dc.b	$ff,$0f,$ff,$0f,$ff,$0f
	dc.b	$ff,$0f,$ff,$0f,$ff,$0f
	dc.b	$ff,$0e,$ef,$0c,$cf,$0a
	dc.b	$af,$08,$8f,$01,$1e,$00
	dc.b	$0c,$00,$0a,$00,$08,$00
	dc.b	$06,$00,$04,$00,$02
	dcb.b	67,$00
	dc.b	$01,$00,$02,$00,$03,$00
	dc.b	$04,$00,$05,$00,$06,$00
	dc.b	$07,$00,$08,$00,$09,$00
	dc.b	$0a,$00,$0b,$00,$0c,$00
	dc.b	$0d,$00,$0e,$00,$0f,$00
	dc.b	$0e,$00,$0d,$00,$1c,$00
	dc.b	$2b,$00,$3a,$00,$49,$00
	dc.b	$58,$00,$67,$00,$76,$00
	dc.b	$85,$00,$94,$00,$a3,$00
	dc.b	$b2,$00,$c1,$00,$d0,$00
	dc.b	$e0,$00,$f0,$00,$e0,$00
	dc.b	$d0,$01,$c0,$02,$b0,$03
	dc.b	$a0,$04,$90,$05,$80,$06
	dc.b	$70,$07,$60,$08,$50,$09
	dc.b	$40,$0a,$30,$0b,$20,$0c
	dc.b	$10,$0d,$00,$0e,$00,$0f
	dc.b	$00,$0e,$00,$0d,$00,$0c
	dc.b	$00,$0b,$00,$0a,$00,$09
	dc.b	$00,$08,$00,$07,$00,$06
	dc.b	$00,$05,$00,$04,$00,$03
	dc.b	$00,$02,$00,$01,$00

L106	lea	L193,a0
	lea	$0400(a0),a1
	move.w	#$01ff,d0
L107	moveq	#$05,d2
	add.w	d0,d2
	move.l	#$00000100,d1
	divu	d2,d1
	move.b	d1,(a0)+
	move.b	d1,-(a1)
	dbf	d0,L107
	rts

L108	move.l	#$2c01fffe,d1
	move.l	#$01000000,d2
	movea.l	L89(pc),a5
	adda.w	#$0048,a5
	moveq	#$7f,d3
	WaitBlt
	move.l	#$09f00000,$40(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$00000000,$64(a6)
L110	move.b	(a0)+,d0
	add.b	(a1)+,d0
	add.b	(a2)+,d0
	add.b	(a3)+,d0
	add.b	(a4)+,d0
	andi.w	#$00fc,d0
	move.l	L113(pc,d0),d0
	move.l	d1,(a5)+
	add.l	d2,d1
	WaitBlt
	move.l	d0,$0050(a6)
	move.l	a5,$0054(a6)
	move.w	#$0109,$0058(a6)
	adda.w	#$0048,a5
	move.b	(a0)+,d0
	add.b	(a1)+,d0
	add.b	(a2)+,d0
	add.b	(a3)+,d0
	add.b	(a4)+,d0
	andi.w	#$00fc,d0
	move.l	L113(pc,d0.w),d0
	addi.l	#$00001200,d0
	move.l	d1,(a5)+
	add.l	d2,d1
	bcc.s	L112
	move.l	#-$001e0002,(a5)+
L112	WaitBlt
	move.l	d0,$0050(a6)
	move.l	a5,$0054(a6)
	move.w	#$0109,$0058(a6)
	adda.w	#$0048,a5
	dbf	d3,L110
	move.l	#$01800000,(a5)+
	move.l	#-$00000002,(a5)+
	rts

L113	dcb.b	256,$00

L114	movea.l	L91(pc),a5
	moveq	#$09,d7
L115	moveq	#$0f,d5
L116	move.b	(a0)+,d0
	add.b	(a1)+,d0
	add.b	(a2)+,d0
	add.b	(a3)+,d0
	add.b	(a4)+,d0
	add.b	d0,d0
	addx.l	d4,d4
	add.b	d0,d0
	addx.l	d3,d3
	add.b	d0,d0
	addx.l	d2,d2
	add.b	d0,d0
	addx.l	d1,d1
	move.b	(a0)+,d0
	add.b	(a1)+,d0
	add.b	(a2)+,d0
	add.b	(a3)+,d0
	add.b	(a4)+,d0
	add.b	d0,d0
	addx.l	d4,d4
	add.b	d0,d0
	addx.l	d3,d3
	add.b	d0,d0
	addx.l	d2,d2
	add.b	d0,d0
	addx.l	d1,d1
	dbf	d5,L116
	move.l	d4,120(a5)
	move.l	d3,80(a5)
	move.l	d2,40(a5)
	move.l	d1,(a5)+
	dbf	d7,L115
	rts

;--------------------------------------;

L117	lea	$dff000,a6
	move.b	#$ac,CredTop
	move.b	#$ac,CredBtm
	bsr.l	L139
L118	WaitBm
	bsr.s	ShwCred

	movem.l	L141(pc),d0-d1
	exg	d0,d1
	movem.l	d0-d1,L141
	addi.l	#$00000500,d0
	move.l	d0,$00e0(a6)
	move.l	d0,$00e4(a6)
	move.l	#L231,$00e8(a6)
	addq.w	#$1,L120
	bsr.l	L123
	bsr.l	L124
	bsr.l	L128
	move.l	#L228,$0080(a6)
	btst	#$06,$00bfe001
	bne.l	L118
	rts

L120	dc.b	$00,$00

ShwCred	move.b	CredTop,d0
	cmp.b	#$99,d0
	beq.s	.1
	subq.b	#1,CredTop
	addq.b	#1,CredBtm
.1	rts

L123	WaitBlt
	move.l	#$01000000,$40(a6)
	move.w	#$0000,$66(a6)
	move.l	L142(pc),a0
	add.w	#((320-256)/2)*(320/8),a0
	move.l	a0,$54(a6)
	move.w	#256<<6+(320/16),$58(a6)
	rts

L124	move.l	#$ffff,d2
	move.w	L120(pc),d6
	moveq	#64,d0
	sub.w	d6,d0
	bmi.s	L125
	asr.w	#2,d0
	ror.l	d0,d2
L125	moveq	#0,d5
	sub.w	#32,d6
	add.w	d6,d6
	ror.w	d6,d2
	move.w	d6,d7
	lea	L189,a1
	lea	L191,a2
	move.w	L120(pc),d5
	btst	#8,d5
	bne.s	L126
	not.w	d5
	add.w	#256,d5
L126	sub.w	#128,d5
	ext.w	d5
	asl.w	#4,d5
	and.w	#%11111110,d6
	and.w	#%11111110,d7

	moveq	#64-1,d4
L127	move.w	d5,d0
	add.w	(a1,d7),d0
	add.w	(a1,d6),d0
	move.w	64(a1,d7),d1
	add.w	64(a1,d6),d1
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	ror.w	#1,d2
	addq.b	#4,d6
	addq.b	#8,d7
	dbf	d4,L127
	rts

L128	movea.l	L142(pc),a0
	adda.w	#$1914,a0
	lea	L191,a1
	WaitBlt
	moveq	#-1,d2
	move.l	d2,$0044(a6)
	moveq	#$28,d2
	move.w	d2,$0060(a6)
	move.w	d2,$0066(a6)
	move.w	#$8000,$0074(a6)
	moveq	#$3f,d5
L130	movem.w	(a1)+,d0-d1/d4
	moveq	#$00,d2
	tst.w	d0
	bpl.s	L131
	neg.w	d0
	moveq	#$10,d2
L131	tst.w	d1
	bpl.s	L132
	neg.w	d1
	addq.w	#$8,d2
L132	cmp.w	d0,d1
	bcs.s	L134
	bne.s	L133
	tst.w	d0
	beq.s	L138
L133	exg	d0,d1
	addq.w	#$4,d2
	move.w	#$2002,d3
	bra.s	L135

L134	move.w	#$2802,d3
L135	add.w	d1,d1
	WaitBlt
	move.w	d4,$0072(a6)
	move.l	a0,$0048(a6)
	move.l	a0,$0054(a6)
	move.w	d1,$0062(a6)
	sub.w	d0,d1
	bpl.s	L137
	addq.w	#$2,d2
L137	move.w	#$0bea,$0040(a6)
	move.w	L138.1(pc,d2),$42(a6)
	move.w	d1,$0052(a6)
	sub.w	d0,d1
	move.w	d1,$0064(a6)
	move.w	d3,$0058(a6)
L138	dbf	d5,L130
	rts

L138.1	dc.b	$00,$11,$00,$51,$00,$01
	dc.b	$00,$41,$00,$19,$00,$59
	dc.b	$00,$05,$00,$45,$00,$15
	dc.b	$00,$55,$00,$09,$00,$49
	dc.b	$00,$1d,$00,$5d,$00,$0d
	dc.b	$00,$4d

L139	lea	L189,a0
	lea	128(a0),a1
	move.l	#3294200,d4
	moveq	#31,d3
L140	move.l	d4,d0
	swap	d0
	add.l	#6588400,d4
	move.w	d0,d2
	move.w	d0,d1
	mulu	d1,d1
	lsl.l	#4,d1
	swap	d1
	mulu	d1,d0
	divu	#$1000,d0
	sub.w	d0,d2
	mulu	d1,d0
	divu	#$5000,d0
	add.w	d0,d2
	mulu	d1,d0
	divu	#$a800,d0
	sub.w	d0,d2
	asr.w	#2,d2
	move.w	d2,(a0)+
	move.w	d2,256-2(a0)
	move.w	d2,-(a1)
	neg.w	d2
	move.w	d2,128-2(a0)
	move.w	d2,128(a1)
	dbf	d3,L140
	rts

L141	dc.l	L198
L142	dc.l	L205

;--------------------------------------;

Music	include	"DH1:Storage/Unfinished/DarkRoom/Replay.i"
Module	incbin	"DH1:Storage/Unfinished/DarkRoom/DarkRoom.mod"
L188	incbin	"DH1:Storage/Unfinished/DarkRoom/DarkRoom.raw"

	SECTION	segment1,BSS

L189	ds.b	200
L190	ds.b	160
L191	ds.b	40
L192	ds.b	2160
L193	ds.b	352
L194	ds.b	32
L195	ds.b	1152

	SECTION	segment2,BSS

L196	ds.b	62456
L197	ds.b	3080

L198	ds.b	160
L199	ds.b	160
L200	ds.b	40
L201	ds.b	40
L202	ds.b	9880
L203	ds.b	2008
L204	ds.b	512
L205	ds.b	7760
L206	ds.b	320
L207	ds.b	1648
L208	ds.b	8272
L209	ds.b	1968
L210	ds.b	8272
L211	ds.b	320
L212	ds.b	1648
L213	ds.b	8272
L214	ds.b	1968
L215	ds.b	10240
L216	ds.b	10240
L217	ds.b	10240
L218	ds.b	14336
L219	ds.b	3082
L220	ds.b	95222
L221

;--------------------------------------;

	SECTION	segment3,DATA

CopNull	dc.w	$0100,$0000,$0180,$0000
	dc.w	$ffff,$fffe

;--------------------------------------;

L223	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0100,$4000,$0102,$0000

	dc.w	$0180,$0000,$0182,$0001
	dc.w	$0184,$0002,$0186,$0003
	dc.w	$0188,$0004,$018a,$0005
	dc.w	$018c,$0006,$018e,$0007
	dc.w	$0190,$0008,$0192,$0009
	dc.w	$0194,$000a,$0196,$000b
	dc.w	$0198,$000c,$019a,$000d
	dc.w	$019c,$000e,$019e,$000f

L224	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$ffff,$fffe

;--------------------------------------;

L225	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$ffff,$fffe

;--------------------------------------;

L226	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0100,$4000,$0102,$0000
	dc.w	$0108,$0000,$010a,$0000

L227	dc.w	$0180,$0000,$0182,$0226
	dc.w	$0184,$0226,$0186,$033a
	dc.w	$0188,$0226,$018a,$033a
	dc.w	$018c,$033a,$018e,$044f
	dc.w	$0190,$044f,$0192,$066f
	dc.w	$0194,$066f,$0196,$0aaf
	dc.w	$0198,$066f,$019a,$0aaf
	dc.w	$019c,$0aaf,$019e,$0fff
	dc.w	$ffff,$fffe

;--------------------------------------;

L228	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0100,$2000,$0102,$0001
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0180,$0000,$0182,$0006
	dc.w	$0184,$0006,$0186,$000c
	dc.w	$0188,$0ccc,$018a,$0ccf
	dc.w	$018c,$0ccf,$018e,$0ccf

CredTop	dc.w	$9911,$fffe,$0100,$3000
CredBtm	dc.w	$bf11,$fffe,$0100,$2000
	dc.w	$ffff,$fffe

;--------------------------------------;

L231	incbin	"DH1:Storage/Unfinished/DarkRoom/Credits.raw"

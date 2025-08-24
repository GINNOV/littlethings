mt_init	lea	mt_data,a0
	move.l	a0,mt_SongDataPtr
	movea.l	a0,a1
	lea	$03b8(a1),a1
	moveq	#$7f,d0
	moveq	#$00,d1
mtloop	move.l	d1,d2
	subq.w	#$1,d0
mtloop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mtloop
	dbf	d0,mtloop2
	addq.b	#$1,d2

	lea	mt_SampleStarts(pc),a1
	asl.l	#$8,d2
	asl.l	#$2,d2
	addi.l	#$0000043c,d2
	add.l	a0,d2
	movea.l	d2,a2
	moveq	#$1e,d0
L45	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#$00,d1
	move.w	$002a(a0),d1
	asl.l	#$1,d1
	adda.l	d1,a2
	adda.l	#$0000001e,a0
	dbf	d0,L45
	ori.b	#$02,$00bfe001
	move.b	#$06,L174
	clr.b	L175
	clr.b	L176
	clr.w	L183
mt_end	clr.w	$00dff0a8
	clr.w	$00dff0b8
	clr.w	$00dff0c8
	clr.w	$00dff0d8
	move.w	#$000f,$00dff096
	rts

mt_music
	movem.l	d0-d7/a0-a6,-(a7)
	addq.b	#$1,L175
	move.b	L175(pc),d0
	cmp.b	L174(pc),d0
	bcs.s	L48
	clr.b	L175
	tst.b	L182
	beq.s	L50
	bsr.s	L49
	bra.l	L67

L48	bsr.s	L49
	bra.l	L72

L49	lea	$00dff0a0,a5
	lea	L168(pc),a6
	bsr.l	L73
	lea	$00dff0b0,a5
	lea	L169(pc),a6
	bsr.l	L73
	lea	$00dff0c0,a5
	lea	L170(pc),a6
	bsr.l	L73
	lea	$00dff0d0,a5
	lea	L171(pc),a6
	bra.l	L73

L50	movea.l	mt_SongDataPtr(pc),a0
	lea	$000c(a0),a3
	lea	$03b8(a0),a2
	lea	$043c(a0),a0
	moveq	#$00,d0
	moveq	#$00,d1
	move.b	L176(pc),d0
	move.b	$00(a2,d0.w),d1
	asl.l	#$8,d1
	asl.l	#$2,d1
	add.w	L183(pc),d1
	clr.w	L184
	lea	$00dff0a0,a5
	lea	L168(pc),a6
	bsr.s	L51
	lea	$00dff0b0,a5
	lea	L169(pc),a6
	bsr.s	L51
	lea	$00dff0c0,a5
	lea	L170(pc),a6
	bsr.s	L51
	lea	$00dff0d0,a5
	lea	L171(pc),a6
	bsr.s	L51
	bra.l	L64

L51	tst.l	(a6)
	bne.s	L52
	bsr.l	L75
L52	move.l	$00(a0,d1.l),(a6)
	addq.l	#$4,d1
	moveq	#$00,d2
	move.b	$0002(a6),d2
	andi.b	#-$10,d2
	lsr.b	#$4,d2
	move.b	(a6),d0
	andi.b	#-$10,d0
	or.b	d0,d2
	tst.b	d2
	beq.l	L56
	moveq	#$00,d3
	lea	mt_SampleStarts(pc),a1
	move.w	d2,d4
	subq.l	#$1,d2
	asl.l	#$2,d2
	mulu	#$001e,d4
	move.l	$00(a1,d2.l),$0004(a6)
	move.w	$00(a3,d4.l),$0008(a6)
	move.w	$00(a3,d4.l),$0028(a6)
	move.b	$02(a3,d4.l),$0012(a6)
	move.b	$03(a3,d4.l),$0013(a6)
	move.w	$04(a3,d4.l),d3
	tst.w	d3
	beq.s	L54
	move.l	$0004(a6),d2
	asl.w	#$1,d3
	add.l	d3,d2
	move.l	d2,$000a(a6)
	move.l	d2,$0024(a6)
	move.w	$04(a3,d4.l),d0
	add.w	$06(a3,d4.l),d0
	move.w	d0,$0008(a6)
	move.w	$06(a3,d4.l),$000e(a6)
	moveq	#$00,d0
	move.b	$0013(a6),d0
R1	cmpi.b	#$40,d0
	blt.s	L53
R2	moveq	#$40,d0
L53	move.w	d0,$0008(a5)
	bra.s	L56

L54	move.l	$0004(a6),d2
	add.l	d3,d2
	move.l	d2,$000a(a6)
	move.l	d2,$0024(a6)
	move.w	$06(a3,d4.l),$000e(a6)
	moveq	#$00,d0
	move.b	$0013(a6),d0
R3	cmpi.b	#$40,d0
	blt.s	L55
R4	moveq	#$40,d0
L55	move.w	d0,$0008(a5)
L56	move.w	(a6),d0
	andi.w	#$0fff,d0
	beq.l	L139
	move.w	$0002(a6),d0
	andi.w	#$0ff0,d0
	cmpi.w	#$0e50,d0
	beq.s	L57
	move.b	$0002(a6),d0
	andi.b	#$0f,d0
	cmpi.b	#$03,d0
	beq.s	L58
	cmpi.b	#$05,d0
	beq.s	L58
	cmpi.b	#$09,d0
	bne.s	L59
	bsr.l	L139
	bra.s	L59

L57	bsr.l	L144
	bra.s	L59

L58	bsr.l	L88
	bra.l	L139

L59	movem.l	d0-d1/a0-a1,-(a7)
	move.w	(a6),d1
	andi.w	#$0fff,d1
	lea	L167(pc),a1
	moveq	#$00,d0
	moveq	#$24,d7
L60	cmp.w	$00(a1,d0.w),d1
	bcc.s	L61
	addq.l	#$2,d0
	dbf	d7,L60
L61	moveq	#$00,d1
	move.b	$0012(a6),d1
	mulu	#$0048,d1
	adda.l	d1,a1
	move.w	$00(a1,d0.w),$0010(a6)
	movem.l	(a7)+,d0-d1/a0-a1
	move.w	$0002(a6),d0
	andi.w	#$0ff0,d0
	cmpi.w	#$0ed0,d0
	beq.l	L139
	move.w	$0014(a6),$00dff096
	btst	#$02,$001e(a6)
	bne.s	L62
	clr.b	$001b(a6)
L62	btst	#$06,$001e(a6)
	bne.s	L63
	clr.b	$001d(a6)
L63	move.l	$0004(a6),(a5)
	move.w	$0008(a6),$0004(a5)
	move.w	$0010(a6),d0
	move.w	d0,$0006(a5)
	move.w	$0014(a6),d0
	or.w	d0,L184
	bra.l	L139

L64	move.w	#$012c,d0
L65	dbf	d0,L65
	move.w	L184(pc),d0
	ori.w	#-$8000,d0
	move.w	d0,$00dff096
	move.w	#$012c,d0
L66	dbf	d0,L66
	lea	$00dff000,a5
	lea	L171(pc),a6
	move.l	$000a(a6),$00d0(a5)
	move.w	$000e(a6),$00d4(a5)
	lea	L170(pc),a6
	move.l	$000a(a6),$00c0(a5)
	move.w	$000e(a6),$00c4(a5)
	lea	L169(pc),a6
	move.l	$000a(a6),$00b0(a5)
	move.w	$000e(a6),$00b4(a5)
	lea	L168(pc),a6
	move.l	$000a(a6),$00a0(a5)
	move.w	$000e(a6),$00a4(a5)
L67	addi.w	#$0010,L183
	move.b	L181,d0
	beq.s	L68
	move.b	d0,L182
	clr.b	L181
L68	tst.b	L182
	beq.s	L69
	subq.b	#$1,L182
	beq.s	L69
	subi.w	#$0010,L183
L69	tst.b	L179
	beq.s	L70
	sf	L179
	moveq	#$00,d0
	move.b	L177(pc),d0
	clr.b	L177
	lsl.w	#$4,d0
	move.w	d0,L183
L70	cmpi.w	#$0400,L183
	bcs.s	L72
L71	moveq	#$00,d0
	move.b	L177(pc),d0
	lsl.w	#$4,d0
	move.w	d0,L183
	clr.b	L177
	clr.b	L178
	addq.b	#$1,L176
	andi.b	#$7f,L176
	move.b	L176(pc),d1
	movea.l	mt_SongDataPtr(pc),a0
	cmp.b	$03b6(a0),d1
	bcs.s	L72
	clr.b	L176
L72	tst.b	L178
	bne.s	L71
	movem.l	(a7)+,d0-d7/a0-a6
	rts

L73	bsr.l	L162
	move.w	$0002(a6),d0
	andi.w	#$0fff,d0
	beq.s	L75
	move.b	$0002(a6),d0
	andi.b	#$0f,d0
	beq.s	L76
	cmpi.b	#$01,d0
	beq.l	L83
	cmpi.b	#$02,d0
	beq.l	L86
	cmpi.b	#$03,d0
	beq.l	L93
	cmpi.b	#$04,d0
	beq.l	L100
	cmpi.b	#$05,d0
	beq.l	L110
	cmpi.b	#$06,d0
	beq.l	L111
	cmpi.b	#$0e,d0
	beq.l	L140
	move.w	$0010(a6),$0006(a5)
	cmpi.b	#$07,d0
	beq.l	L112
	cmpi.b	#$0a,d0
	beq.l	L127
L74	rts

L75	move.w	$0010(a6),$0006(a5)
	rts

L76	moveq	#$00,d0
	move.b	L175(pc),d0
	divs	#$0003,d0
	swap	d0
	cmpi.w	#$0000,d0
	beq.s	L78
	cmpi.w	#$0002,d0
	beq.s	L77
	moveq	#$00,d0
	move.b	$0003(a6),d0
	lsr.b	#$4,d0
	bra.s	L79

L77	moveq	#$00,d0
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	bra.s	L79

L78	move.w	$0010(a6),d2
	bra.s	L81

L79	asl.w	#$1,d0
	moveq	#$00,d1
	move.b	$0012(a6),d1
	mulu	#$0048,d1
	lea	L167(pc),a0
	adda.l	d1,a0
	moveq	#$00,d1
	move.w	$0010(a6),d1
	moveq	#$24,d7
L80	move.w	$00(a0,d0.w),d2
	cmp.w	(a0),d1
	bcc.s	L81
	addq.l	#$2,a0
	dbf	d7,L80
	rts

L81	move.w	d2,$0006(a5)
	rts

L82	tst.b	L175
	bne.s	L74
	move.b	#$0f,L180
L83	moveq	#$00,d0
	move.b	$0003(a6),d0
	and.b	L180(pc),d0
	move.b	#-$01,L180
	sub.w	d0,$0010(a6)
	move.w	$0010(a6),d0
	andi.w	#$0fff,d0
	cmpi.w	#$0071,d0
	bpl.s	L84
	andi.w	#-$1000,$0010(a6)
	ori.w	#$0071,$0010(a6)
L84	move.w	$0010(a6),d0
	andi.w	#$0fff,d0
	move.w	d0,$0006(a5)
	rts

L85	tst.b	L175
	bne.l	L74
	move.b	#$0f,L180
L86	clr.w	d0
	move.b	$0003(a6),d0
	and.b	L180(pc),d0
	move.b	#-$01,L180
	add.w	d0,$0010(a6)
	move.w	$0010(a6),d0
	andi.w	#$0fff,d0
	cmpi.w	#$0358,d0
	bmi.s	L87
	andi.w	#-$1000,$0010(a6)
	ori.w	#$0358,$0010(a6)
L87	move.w	$0010(a6),d0
	andi.w	#$0fff,d0
	move.w	d0,$0006(a5)
	rts

L88	move.l	a0,-(a7)
	move.w	(a6),d2
	andi.w	#$0fff,d2
	moveq	#$00,d0
	move.b	$0012(a6),d0
	mulu	#$004a,d0
	lea	L167(pc),a0
	adda.l	d0,a0
	moveq	#$00,d0
L89	cmp.w	$00(a0,d0.w),d2
	bcc.s	L90
	addq.w	#$2,d0
	cmpi.w	#$004a,d0
	bcs.s	L89
	moveq	#$46,d0
L90	move.b	$0012(a6),d2
	andi.b	#$08,d2
	beq.s	L91
	tst.w	d0
	beq.s	L91
	subq.w	#$2,d0
L91	move.w	$00(a0,d0.w),d2
	movea.l	(a7)+,a0
	move.w	d2,$0018(a6)
	move.w	$0010(a6),d0
	clr.b	$0016(a6)
	cmp.w	d0,d2
	beq.s	L92
	bge.l	L74
	move.b	#$01,$0016(a6)
	rts

L92	clr.w	$0018(a6)
	rts

L93	move.b	$0003(a6),d0
	beq.s	L94
	move.b	d0,$0017(a6)
	clr.b	$0003(a6)
L94	tst.w	$0018(a6)
	beq.l	L74
	moveq	#$00,d0
	move.b	$0017(a6),d0
	tst.b	$0016(a6)
	bne.s	L95
	add.w	d0,$0010(a6)
	move.w	$0018(a6),d0
	cmp.w	$0010(a6),d0
	bgt.s	L96
	move.w	$0018(a6),$0010(a6)
	clr.w	$0018(a6)
	bra.s	L96

L95	sub.w	d0,$0010(a6)
	move.w	$0018(a6),d0
	cmp.w	$0010(a6),d0
	blt.s	L96
	move.w	$0018(a6),$0010(a6)
	clr.w	$0018(a6)
L96	move.w	$0010(a6),d2
	move.b	$001f(a6),d0
	andi.b	#$0f,d0
	beq.s	L99
	moveq	#$00,d0
	move.b	$0012(a6),d0
	mulu	#$0048,d0
	lea	L167(pc),a0
	adda.l	d0,a0
	moveq	#$00,d0
L97	cmp.w	$00(a0,d0.w),d2
	bcc.s	L98
	addq.w	#$2,d0
	cmpi.w	#$0048,d0
	bcs.s	L97
	moveq	#$46,d0
L98	move.w	$00(a0,d0.w),d2
L99	move.w	d2,$0006(a5)
	rts

L100	move.b	$0003(a6),d0
	beq.s	L103
	move.b	$001a(a6),d2
	andi.b	#$0f,d0
	beq.s	L101
	andi.b	#-$10,d2
	or.b	d0,d2
L101	move.b	$0003(a6),d0
	andi.b	#-$10,d0
	beq.s	L102
	andi.b	#$0f,d2
	or.b	d0,d2
L102	move.b	d2,$001a(a6)
L103	move.b	$001b(a6),d0
	lea	L166(pc),a4
	lsr.w	#$2,d0
	andi.w	#$001f,d0
	moveq	#$00,d2
	move.b	$001e(a6),d2
	andi.b	#$03,d2
	beq.s	L106
	lsl.b	#$3,d0
	cmpi.b	#$01,d2
	beq.s	L104
	move.b	#-$01,d2
	bra.s	L107

L104	tst.b	$001b(a6)
	bpl.s	L105
	move.b	#-$01,d2
	sub.b	d0,d2
	bra.s	L107

L105	move.b	d0,d2
	bra.s	L107

L106	move.b	$00(a4,d0.w),d2
L107	move.b	$001a(a6),d0
	andi.w	#$000f,d0
	mulu	d0,d2
	lsr.w	#$7,d2
	move.w	$0010(a6),d0
	tst.b	$001b(a6)
	bmi.s	L108
	add.w	d2,d0
	bra.s	L109

L108	sub.w	d2,d0
L109	move.w	d0,$0006(a5)
	move.b	$001a(a6),d0
	lsr.w	#$2,d0
	andi.w	#$003c,d0
	add.b	d0,$001b(a6)
	rts

L110	bsr.l	L94
	bra.l	L127

L111	bsr.s	L103
	bra.l	L127

L112	move.b	$0003(a6),d0
	beq.s	L115
	move.b	$001c(a6),d2
	andi.b	#$0f,d0
	beq.s	L113
	andi.b	#-$10,d2
	or.b	d0,d2
L113	move.b	$0003(a6),d0
	andi.b	#-$10,d0
	beq.s	L114
	andi.b	#$0f,d2
	or.b	d0,d2
L114	move.b	d2,$001c(a6)
L115	move.b	$001d(a6),d0
	lea	L166(pc),a4
	lsr.w	#$2,d0
	andi.w	#$001f,d0
	moveq	#$00,d2
	move.b	$001e(a6),d2
	lsr.b	#$4,d2
	andi.b	#$03,d2
	beq.s	L118
	lsl.b	#$3,d0
	cmpi.b	#$01,d2
	beq.s	L116
	move.b	#-$01,d2
	bra.s	L119

L116	tst.b	$001b(a6)
	bpl.s	L117
	move.b	#-$01,d2
	sub.b	d0,d2
	bra.s	L119

L117	move.b	d0,d2
	bra.s	L119

L118	move.b	$00(a4,d0.w),d2
L119	move.b	$001c(a6),d0
	andi.w	#$000f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	moveq	#$00,d0
	move.b	$0013(a6),d0
	tst.b	$001d(a6)
	bmi.s	L120
	add.w	d2,d0
	bra.s	L121

L120	sub.w	d2,d0
L121	bpl.s	L122
	clr.w	d0
L122	cmpi.w	#$0040,d0
	bls.s	L123
	move.w	#$0040,d0
L123	move.w	d0,$0008(a5)
	move.b	$001c(a6),d0
	lsr.w	#$2,d0
	andi.w	#$003c,d0
	add.b	d0,$001d(a6)
	rts

L124	moveq	#$00,d0
	move.b	$0003(a6),d0
	beq.s	L125
	move.b	d0,$0020(a6)
L125	move.b	$0020(a6),d0
	lsl.w	#$7,d0
	cmp.w	$0008(a6),d0
	bge.s	L126
	sub.w	d0,$0008(a6)
	lsl.w	#$1,d0
	add.l	d0,$0004(a6)
	rts

L126	move.w	#$0001,$0008(a6)
	rts

L127	moveq	#$00,d0
	move.b	$0003(a6),d0
	lsr.b	#$4,d0
	tst.b	d0
	beq.s	L130
L128	add.b	d0,$0013(a6)
	cmpi.b	#$40,$0013(a6)
	bmi.s	L129
	move.b	#$40,$0013(a6)
L129	move.b	$0013(a6),d0
	move.w	d0,$0008(a5)
	rts

L130	moveq	#$00,d0
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
L131	sub.b	d0,$0013(a6)
	bpl.s	L132
	clr.b	$0013(a6)
L132	move.b	$0013(a6),d0
	move.w	d0,$0008(a5)
	rts

L133	move.b	$0003(a6),d0
	subq.b	#$1,d0
	move.b	d0,L176
L134	clr.b	L177
	st	L178
	rts

L135	moveq	#$00,d0
	move.b	$0003(a6),d0
	cmpi.b	#$40,d0
	bls.s	L136
	moveq	#$40,d0
L136	move.b	d0,$0013(a6)
	move.w	d0,$0008(a5)
	rts

L137	moveq	#$00,d0
	move.b	$0003(a6),d0
	move.l	d0,d2
	lsr.b	#$4,d0
	mulu	#$000a,d0
	andi.b	#$0f,d2
	add.b	d2,d0
	cmpi.b	#$3f,d0
	bhi.s	L134
	move.b	d0,L177
	st	L178
	rts

L138	move.b	$0003(a6),d0
	beq.l	L74
	clr.b	L175
	move.b	d0,L174
	rts

L139	bsr.l	L162
	move.b	$0002(a6),d0
	andi.b	#$0f,d0
	cmpi.b	#$09,d0
	beq.l	L124
	cmpi.b	#$0b,d0
	beq.l	L133
	cmpi.b	#$0d,d0
	beq.s	L137
	cmpi.b	#$0e,d0
	beq.s	L140
	cmpi.b	#$0f,d0
	beq.s	L138
	cmpi.b	#$0c,d0
	beq.l	L135
	bra.l	L75

L140	move.b	$0003(a6),d0
	andi.b	#-$10,d0
	lsr.b	#$4,d0
	beq.s	L141
	cmpi.b	#$01,d0
	beq.l	L82
	cmpi.b	#$02,d0
	beq.l	L85
	cmpi.b	#$03,d0
	beq.s	L142
	cmpi.b	#$04,d0
	beq.l	L143
	cmpi.b	#$05,d0
	beq.l	L144
	cmpi.b	#$06,d0
	beq.l	L145
	cmpi.b	#$07,d0
	beq.l	L149
	cmpi.b	#$09,d0
	beq.l	L150
	cmpi.b	#$0a,d0
	beq.l	L156
	cmpi.b	#$0b,d0
	beq.l	L157
	cmpi.b	#$0c,d0
	beq.l	L158
	cmpi.b	#$0d,d0
	beq.l	L159
	cmpi.b	#$0e,d0
	beq.l	L160
	cmpi.b	#$0f,d0
	beq.l	L161
	rts

L141	move.b	$0003(a6),d0
	andi.b	#$01,d0
	asl.b	#$1,d0
	andi.b	#-$03,$00bfe001
	or.b	d0,$00bfe001
	rts

L142	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	andi.b	#-$10,$001f(a6)
	or.b	d0,$001f(a6)
	rts

L143	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	andi.b	#-$10,$001e(a6)
	or.b	d0,$001e(a6)
	rts

L144	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	move.b	d0,$0012(a6)
	rts

L145	tst.b	L175
	bne.l	L74
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	beq.s	L148
	tst.b	$0022(a6)
	beq.s	L147
	subq.b	#$1,$0022(a6)
	beq.l	L74
L146	move.b	$0021(a6),L177
	st	L179
	rts

L147	move.b	d0,$0022(a6)
	bra.s	L146

L148	move.w	L183(pc),d0
	lsr.w	#$4,d0
	move.b	d0,$0021(a6)
	rts

L149	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	lsl.b	#$4,d0
	andi.b	#$0f,$001e(a6)
	or.b	d0,$001e(a6)
	rts

L150	move.l	d1,-(a7)
	moveq	#$00,d0
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	beq.s	L155
	moveq	#$00,d1
	move.b	L175(pc),d1
	bne.s	L151
	move.w	(a6),d1
	andi.w	#$0fff,d1
	bne.s	L155
	moveq	#$00,d1
	move.b	L175(pc),d1
L151	divu	d0,d1
	swap	d1
	tst.w	d1
	bne.s	L155
L152	move.w	$0014(a6),$00dff096
	move.l	$0004(a6),(a5)
	move.w	$0008(a6),$0004(a5)
	move.w	#$012c,d0
L153	dbf	d0,L153
	move.w	$0014(a6),d0
	bset	#$0f,d0
	move.w	d0,$00dff096
	move.w	#$012c,d0
L154	dbf	d0,L154
	move.l	$000a(a6),(a5)
	move.l	$000e(a6),$0004(a5)
L155	move.l	(a7)+,d1
	rts

L156	tst.b	L175
	bne.l	L74
	moveq	#$00,d0
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	bra.l	L128

L157	tst.b	L175
	bne.l	L74
	moveq	#$00,d0
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	bra.l	L131

L158	moveq	#$00,d0
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	cmp.b	L175(pc),d0
	bne.l	L74
	clr.b	$0013(a6)
	move.w	#$0000,$0008(a5)
	rts

L159	moveq	#$00,d0
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	cmp.b	L175,d0
	bne.l	L74
	move.w	(a6),d0
	beq.l	L74
	move.l	d1,-(a7)
	bra.l	L152

L160	tst.b	L175
	bne.l	L74
	moveq	#$00,d0
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	tst.b	L182
	bne.l	L74
	addq.b	#$1,d0
	move.b	d0,L181
	rts

L161	tst.b	L175
	bne.l	L74
	move.b	$0003(a6),d0
	andi.b	#$0f,d0
	lsl.b	#$4,d0
	andi.b	#$0f,$001f(a6)
	or.b	d0,$001f(a6)
	tst.b	d0
	beq.l	L74
L162	movem.l	d1/a0,-(a7)
	moveq	#$00,d0
	move.b	$001f(a6),d0
	lsr.b	#$4,d0
	beq.s	L164
	lea	L165(pc),a0
	move.b	$00(a0,d0.w),d0
	add.b	d0,$0023(a6)
	btst	#$07,$0023(a6)
	beq.s	L164
	clr.b	$0023(a6)
	move.l	$000a(a6),d0
	moveq	#$00,d1
	move.w	$000e(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	movea.l	$0024(a6),a0
	addq.l	#$1,a0
	cmpa.l	d0,a0
	bcs.s	L163
	movea.l	$000a(a6),a0
L163	move.l	a0,$0024(a6)
	moveq	#-$01,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
L164	movem.l	(a7)+,d1/a0
	rts

L165	dc.b	$00,$05,$06,$07,$08,$0a
	dc.b	$0b,$0d,$10,$13,$16,$1a
	dc.b	$20,$2b,$40,$80
L166	dc.b	$00,$18,$31,$4a,$61,$78
	dc.b	$8d,$a1,$b4,$c5,$d4,$e0
	dc.b	$eb,$f4,$fa,$fd,$ff,$fd
	dc.b	$fa,$f4,$eb,$e0,$d4,$c5
	dc.b	$b4,$a1,$8d,$78,$61,$4a
	dc.b	$31,$18
L167	dc.b	$03,$58,$03,$28,$02,$fa
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
	dc.b	$03,$52,$03,$22,$02,$f5
	dc.b	$02,$cb,$02,$a2,$02,$7d
	dc.b	$02,$59,$02,$37,$02,$17
	dc.b	$01,$f9,$01,$dd,$01,$c2
	dc.b	$01,$a9,$01,$91,$01,$7b
	dc.b	$01,$65,$01,$51,$01,$3e
	dc.b	$01,$2c,$01,$1c,$01,$0c
	dc.b	$00,$fd,$00,$ef,$00,$e1
	dc.b	$00,$d5,$00,$c9,$00,$bd
	dc.b	$00,$b3,$00,$a9,$00,$9f
	dc.b	$00,$96,$00,$8e,$00,$86
	dc.b	$00,$7e,$00,$77,$00,$71
	dc.b	$03,$4c,$03,$1c,$02,$f0
	dc.b	$02,$c5,$02,$9e,$02,$78
	dc.b	$02,$55,$02,$33,$02,$14
	dc.b	$01,$f6,$01,$da,$01,$bf
	dc.b	$01,$a6,$01,$8e,$01,$78
	dc.b	$01,$63,$01,$4f,$01,$3c
	dc.b	$01,$2a,$01,$1a,$01,$0a
	dc.b	$00,$fb,$00,$ed,$00,$e0
	dc.b	$00,$d3,$00,$c7,$00,$bc
	dc.b	$00,$b1,$00,$a7,$00,$9e
	dc.b	$00,$95,$00,$8d,$00,$85
	dc.b	$00,$7d,$00,$76,$00,$70
	dc.b	$03,$46,$03,$17,$02,$ea
	dc.b	$02,$c0,$02,$99,$02,$74
	dc.b	$02,$50,$02,$2f,$02,$10
	dc.b	$01,$f2,$01,$d6,$01,$bc
	dc.b	$01,$a3,$01,$8b,$01,$75
	dc.b	$01,$60,$01,$4c,$01,$3a
	dc.b	$01,$28,$01,$18,$01,$08
	dc.b	$00,$f9,$00,$eb,$00,$de
	dc.b	$00,$d1,$00,$c6,$00,$bb
	dc.b	$00,$b0,$00,$a6,$00,$9d
	dc.b	$00,$94,$00,$8c,$00,$84
	dc.b	$00,$7d,$00,$76,$00,$6f
	dc.b	$03,$40,$03,$11,$02,$e5
	dc.b	$02,$bb,$02,$94,$02,$6f
	dc.b	$02,$4c,$02,$2b,$02,$0c
	dc.b	$01,$ef,$01,$d3,$01,$b9
	dc.b	$01,$a0,$01,$88,$01,$72
	dc.b	$01,$5e,$01,$4a,$01,$38
	dc.b	$01,$26,$01,$16,$01,$06
	dc.b	$00,$f7,$00,$e9,$00,$dc
	dc.b	$00,$d0,$00,$c4,$00,$b9
	dc.b	$00,$af,$00,$a5,$00,$9c
	dc.b	$00,$93,$00,$8b,$00,$83
	dc.b	$00,$7c,$00,$75,$00,$6e
	dc.b	$03,$3a,$03,$0b,$02,$e0
	dc.b	$02,$b6,$02,$8f,$02,$6b
	dc.b	$02,$48,$02,$27,$02,$08
	dc.b	$01,$eb,$01,$cf,$01,$b5
	dc.b	$01,$9d,$01,$86,$01,$70
	dc.b	$01,$5b,$01,$48,$01,$35
	dc.b	$01,$24,$01,$14,$01,$04
	dc.b	$00,$f5,$00,$e8,$00,$db
	dc.b	$00,$ce,$00,$c3,$00,$b8
	dc.b	$00,$ae,$00,$a4,$00,$9b
	dc.b	$00,$92,$00,$8a,$00,$82
	dc.b	$00,$7b,$00,$74,$00,$6d
	dc.b	$03,$34,$03,$06,$02,$da
	dc.b	$02,$b1,$02,$8b,$02,$66
	dc.b	$02,$44,$02,$23,$02,$04
	dc.b	$01,$e7,$01,$cc,$01,$b2
	dc.b	$01,$9a,$01,$83,$01,$6d
	dc.b	$01,$59,$01,$45,$01,$33
	dc.b	$01,$22,$01,$12,$01,$02
	dc.b	$00,$f4,$00,$e6,$00,$d9
	dc.b	$00,$cd,$00,$c1,$00,$b7
	dc.b	$00,$ac,$00,$a3,$00,$9a
	dc.b	$00,$91,$00,$89,$00,$81
	dc.b	$00,$7a,$00,$73,$00,$6d
	dc.b	$03,$2e,$03,$00,$02,$d5
	dc.b	$02,$ac,$02,$86,$02,$62
	dc.b	$02,$3f,$02,$1f,$02,$01
	dc.b	$01,$e4,$01,$c9,$01,$af
	dc.b	$01,$97,$01,$80,$01,$6b
	dc.b	$01,$56,$01,$43,$01,$31
	dc.b	$01,$20,$01,$10,$01,$00
	dc.b	$00,$f2,$00,$e4,$00,$d8
	dc.b	$00,$cc,$00,$c0,$00,$b5
	dc.b	$00,$ab,$00,$a1,$00,$98
	dc.b	$00,$90,$00,$88,$00,$80
	dc.b	$00,$79,$00,$72,$00,$6c
	dc.b	$03,$8b,$03,$58,$03,$28
	dc.b	$02,$fa,$02,$d0,$02,$a6
	dc.b	$02,$80,$02,$5c,$02,$3a
	dc.b	$02,$1a,$01,$fc,$01,$e0
	dc.b	$01,$c5,$01,$ac,$01,$94
	dc.b	$01,$7d,$01,$68,$01,$53
	dc.b	$01,$40,$01,$2e,$01,$1d
	dc.b	$01,$0d,$00,$fe,$00,$f0
	dc.b	$00,$e2,$00,$d6,$00,$ca
	dc.b	$00,$be,$00,$b4,$00,$aa
	dc.b	$00,$a0,$00,$97,$00,$8f
	dc.b	$00,$87,$00,$7f,$00,$78
	dc.b	$03,$84,$03,$52,$03,$22
	dc.b	$02,$f5,$02,$cb,$02,$a3
	dc.b	$02,$7c,$02,$59,$02,$37
	dc.b	$02,$17,$01,$f9,$01,$dd
	dc.b	$01,$c2,$01,$a9,$01,$91
	dc.b	$01,$7b,$01,$65,$01,$51
	dc.b	$01,$3e,$01,$2c,$01,$1c
	dc.b	$01,$0c,$00,$fd,$00,$ee
	dc.b	$00,$e1,$00,$d4,$00,$c8
	dc.b	$00,$bd,$00,$b3,$00,$a9
	dc.b	$00,$9f,$00,$96,$00,$8e
	dc.b	$00,$86,$00,$7e,$00,$77
	dc.b	$03,$7e,$03,$4c,$03,$1c
	dc.b	$02,$f0,$02,$c5,$02,$9e
	dc.b	$02,$78,$02,$55,$02,$33
	dc.b	$02,$14,$01,$f6,$01,$da
	dc.b	$01,$bf,$01,$a6,$01,$8e
	dc.b	$01,$78,$01,$63,$01,$4f
	dc.b	$01,$3c,$01,$2a,$01,$1a
	dc.b	$01,$0a,$00,$fb,$00,$ed
	dc.b	$00,$df,$00,$d3,$00,$c7
	dc.b	$00,$bc,$00,$b1,$00,$a7
	dc.b	$00,$9e,$00,$95,$00,$8d
	dc.b	$00,$85,$00,$7d,$00,$76
	dc.b	$03,$77,$03,$46,$03,$17
	dc.b	$02,$ea,$02,$c0,$02,$99
	dc.b	$02,$74,$02,$50,$02,$2f
	dc.b	$02,$10,$01,$f2,$01,$d6
	dc.b	$01,$bc,$01,$a3,$01,$8b
	dc.b	$01,$75,$01,$60,$01,$4c
	dc.b	$01,$3a,$01,$28,$01,$18
	dc.b	$01,$08,$00,$f9,$00,$eb
	dc.b	$00,$de,$00,$d1,$00,$c6
	dc.b	$00,$bb,$00,$b0,$00,$a6
	dc.b	$00,$9d,$00,$94,$00,$8c
	dc.b	$00,$84,$00,$7d,$00,$76
	dc.b	$03,$71,$03,$40,$03,$11
	dc.b	$02,$e5,$02,$bb,$02,$94
	dc.b	$02,$6f,$02,$4c,$02,$2b
	dc.b	$02,$0c,$01,$ee,$01,$d3
	dc.b	$01,$b9,$01,$a0,$01,$88
	dc.b	$01,$72,$01,$5e,$01,$4a
	dc.b	$01,$38,$01,$26,$01,$16
	dc.b	$01,$06,$00,$f7,$00,$e9
	dc.b	$00,$dc,$00,$d0,$00,$c4
	dc.b	$00,$b9,$00,$af,$00,$a5
	dc.b	$00,$9c,$00,$93,$00,$8b
	dc.b	$00,$83,$00,$7b,$00,$75
	dc.b	$03,$6b,$03,$3a,$03,$0b
	dc.b	$02,$e0,$02,$b6,$02,$8f
	dc.b	$02,$6b,$02,$48,$02,$27
	dc.b	$02,$08,$01,$eb,$01,$cf
	dc.b	$01,$b5,$01,$9d,$01,$86
	dc.b	$01,$70,$01,$5b,$01,$48
	dc.b	$01,$35,$01,$24,$01,$14
	dc.b	$01,$04,$00,$f5,$00,$e8
	dc.b	$00,$db,$00,$ce,$00,$c3
	dc.b	$00,$b8,$00,$ae,$00,$a4
	dc.b	$00,$9b,$00,$92,$00,$8a
	dc.b	$00,$82,$00,$7b,$00,$74
	dc.b	$03,$64,$03,$34,$03,$06
	dc.b	$02,$da,$02,$b1,$02,$8b
	dc.b	$02,$66,$02,$44,$02,$23
	dc.b	$02,$04,$01,$e7,$01,$cc
	dc.b	$01,$b2,$01,$9a,$01,$83
	dc.b	$01,$6d,$01,$59,$01,$45
	dc.b	$01,$33,$01,$22,$01,$12
	dc.b	$01,$02,$00,$f4,$00,$e6
	dc.b	$00,$d9,$00,$cd,$00,$c1
	dc.b	$00,$b7,$00,$ac,$00,$a3
	dc.b	$00,$9a,$00,$91,$00,$89
	dc.b	$00,$81,$00,$7a,$00,$73
	dc.b	$03,$5e,$03,$2e,$03,$00
	dc.b	$02,$d5,$02,$ac,$02,$86
	dc.b	$02,$62,$02,$3f,$02,$1f
	dc.b	$02,$01,$01,$e4,$01,$c9
	dc.b	$01,$af,$01,$97,$01,$80
	dc.b	$01,$6b,$01,$56,$01,$43
	dc.b	$01,$31,$01,$20,$01,$10
	dc.b	$01,$00,$00,$f2,$00,$e4
	dc.b	$00,$d8,$00,$cb,$00,$c0
	dc.b	$00,$b5,$00,$ab,$00,$a1
	dc.b	$00,$98,$00,$90,$00,$88
	dc.b	$00,$80,$00,$79,$00,$72
L168	dcb.b	21,$00
	dc.b	$01
	dcb.b	22,$00
L169	dcb.b	21,$00
	dc.b	$02
	dcb.b	22,$00
L170	dcb.b	21,$00
	dc.b	$04
	dcb.b	22,$00
L171	dcb.b	21,$00
	dc.b	$08
	dcb.b	22,$00
mt_SampleStarts	dcb.b	124,$00
mt_SongDataPtr	dcb.b	4,$00
L174	dc.b	$06
L175	dcb.b	1,$00
L176	dcb.b	1,$00
L177	dcb.b	1,$00
L178	dcb.b	1,$00
L179	dcb.b	1,$00
L180	dcb.b	1,$00
L181	dcb.b	1,$00
L182	dcb.b	2,$00
L183	dcb.b	2,$00
L184	dcb.b	2,$00

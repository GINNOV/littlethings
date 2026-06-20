
; Maxon C++ Compiler
; LS2:work/voGL/hershey/src/htext.c
	mc68020
	mc68881
	XREF	_rmv
	XREF	_move2
	XREF	_gexit
	XREF	_rdr
	XREF	_hallocate
	XREF	_check_loaded
	XREF	_strlen
	XREF	_strrchr
	XREF	_strcmp
	XREF	_strcat
	XREF	_strcpy
	XREF	_getenv
	XREF	_free
	XREF	_cos__r
	XREF	_sin__r
	XREF	_exit
	XREF	_fread
	XREF	_fprintf
	XREF	_fclose
	XREF	_fopen
	XREF	_std__in
	XREF	_std__out
	XREF	_std__err
	XREF	___MEMFLAGS
	XREF	_vdevice

	SECTION ":0",CODE


	XDEF	_hfont
_hfont
L57	EQU	-$8
	link	a5,#L57+8
L58	EQU	$C00
	movem.l	a2/a3,-(a7)
	move.l	$8(a5),a2
	XREF	userbreak_flagpos
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	cmp.b	#$2F,(a2)
	bne	L2
	pea	_old_font
	pea	$2F.w
	move.l	a2,-(a7)
	jsr	_strrchr
	addq.l	#$8,a7
	move.l	d0,a3
	addq.l	#1,a3
	move.l	a3,-(a7)
	jsr	_strcmp
	addq.l	#$8,a7
	tst.l	d0
	bne	L1
	movem.l	(a7)+,a2/a3
	unlk	a5
	rts
L1
	bra.b	L4
L2
	pea	_old_font
	move.l	a2,-(a7)
	jsr	_strcmp
	addq.l	#$8,a7
	tst.l	d0
	bne	L3
	movem.l	(a7)+,a2/a3
	unlk	a5
	rts
L3
L4
	move.l	a2,-(a7)
	jsr	_hershfont
	addq.l	#4,a7
	tst.l	d0
	bne	L5
	move.l	a2,-(a7)
	pea	L60
	pea	_std__err
	jsr	_fprintf
	lea	$C(a7),a7
	jsr	_gexit
	pea	1.w
	jsr	_exit
	addq.l	#4,a7
L5
	cmp.b	#$2F,(a2)
	bne	L6
	pea	$2F.w
	move.l	a2,-(a7)
	jsr	_strrchr
	addq.l	#$8,a7
	move.l	d0,a3
	addq.l	#1,a3
	move.l	a3,-(a7)
	pea	_old_font
	jsr	_strcpy
	addq.l	#$8,a7
	bra	L7
L6
	move.l	a2,-(a7)
	pea	_old_font
	jsr	_strcpy
	addq.l	#$8,a7
L7
	movem.l	(a7)+,a2/a3
	unlk	a5
	rts

	XDEF	_hnumchars
_hnumchars
L61	EQU	0
L62	EQU	0
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L63
	jsr	_check_loaded
	addq.l	#4,a7
	move.w	_nchars,d0
	ext.l	d0
	rts

	XDEF	_hsetpath
_hsetpath
L64	EQU	-$C
	link	a5,#L64+8
L65	EQU	$804
	movem.l	d2/a3,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	move.l	$8(a5),-(a7)
	pea	_fpath
	jsr	_strcpy
	addq.l	#$8,a7
	pea	_fpath
	jsr	_strlen
	addq.l	#4,a7
	move.l	d0,d2
	move.l	#_fpath,a3
	cmp.b	#$2F,0(a3,d2.l)
	beq	L8
	move.l	#_fpath,a3
	cmp.b	#$3A,0(a3,d2.l)
	beq	L8
	pea	L66
	pea	_fpath
	jsr	_strcat
	addq.l	#$8,a7
L8
	movem.l	(a7)+,d2/a3
	unlk	a5
	rts

_hershfont
L67	EQU	-$124
	link	a5,#L67+20
L68	EQU	$4C84
	movem.l	d2/d7/a2/a3/a6,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	move.l	#_fpath,a3
	tst.b	(a3)
	beq	L9
	pea	_fpath
	pea	-$110(a5)
	jsr	_strcpy
	addq.l	#$8,a7
	move.l	$8(a5),-(a7)
	pea	-$110(a5)
	jsr	_strcat
	addq.l	#$8,a7
	bra	L17
L9
	pea	L69
	jsr	_getenv
	addq.l	#4,a7
	move.l	d0,a6
	cmp.w	#0,a6
	beq	L11
	move.l	a6,-(a7)
	pea	-$110(a5)
	jsr	_strcpy
	addq.l	#$8,a7
	lea	-$110(a5),a3
	pea	-$110(a5)
	jsr	_strlen
	addq.l	#4,a7
	subq.l	#1,d0
	cmp.b	#$3A,0(a3,d0.l)
	beq	L10
	pea	L66
	pea	-$110(a5)
	jsr	_strcat
	addq.l	#$8,a7
L10
	move.l	$8(a5),-(a7)
	pea	-$110(a5)
	jsr	_strcat
	addq.l	#$8,a7
	bra	L16
L11
	pea	L70
	jsr	_getenv
	addq.l	#4,a7
	move.l	d0,a6
	cmp.w	#0,a6
	beq	L13
	move.l	a6,-(a7)
	pea	-$110(a5)
	jsr	_strcpy
	addq.l	#$8,a7
	lea	-$110(a5),a3
	pea	-$110(a5)
	jsr	_strlen
	addq.l	#4,a7
	subq.l	#1,d0
	cmp.b	#$3A,0(a3,d0.l)
	beq	L12
	pea	L66
	pea	-$110(a5)
	jsr	_strcat
	addq.l	#$8,a7
L12
	move.l	$8(a5),-(a7)
	pea	-$110(a5)
	jsr	_strcat
	addq.l	#$8,a7
	bra	L15
L13
	pea	L71
	pea	-$110(a5)
	jsr	_strcpy
	addq.l	#$8,a7
	lea	-$110(a5),a3
	pea	-$110(a5)
	jsr	_strlen
	addq.l	#4,a7
	subq.l	#1,d0
	cmp.b	#$3A,0(a3,d0.l)
	beq	L14
	pea	L66
	pea	-$110(a5)
	jsr	_strcat
	addq.l	#$8,a7
L14
	move.l	$8(a5),-(a7)
	pea	-$110(a5)
	jsr	_strcat
	addq.l	#$8,a7
L15
L16
L17
	pea	L72
	pea	-$110(a5)
	jsr	_fopen
	addq.l	#$8,a7
	move.l	d0,a2
	cmp.w	#0,a2
	bne	L18
	pea	L72
	move.l	$8(a5),-(a7)
	jsr	_fopen
	addq.l	#$8,a7
	move.l	d0,a2
	cmp.w	#0,a2
	bne	L18
	move.l	$8(a5),-(a7)
	pea	-$110(a5)
	pea	L73
	pea	_std__err
	jsr	_fprintf
	lea	$10(a7),a7
	pea	1.w
	jsr	_exit
	addq.l	#4,a7
L18
	move.l	a2,-(a7)
	pea	1.w
	pea	2.w
	pea	_nchars
	jsr	_fread
	lea	$10(a7),a7
	cmp.l	#1,d0
	beq	L19
	moveq	#0,d0
	movem.l	(a7)+,d2/d7/a2/a3/a6
	unlk	a5
	rts
L19
	move.l	a2,-(a7)
	pea	1.w
	pea	2.w
	pea	-$A(a5)
	jsr	_fread
	lea	$10(a7),a7
	cmp.l	#1,d0
	beq	L20
	moveq	#0,d0
	movem.l	(a7)+,d2/d7/a2/a3/a6
	unlk	a5
	rts
L20
	move.l	a2,-(a7)
	pea	1.w
	pea	2.w
	pea	-$C(a5)
	jsr	_fread
	lea	$10(a7),a7
	cmp.l	#1,d0
	beq	L21
	moveq	#0,d0
	movem.l	(a7)+,d2/d7/a2/a3/a6
	unlk	a5
	rts
L21
	move.w	-$C(a5),d0
	ext.l	d0
	move.l	d0,_ftab
	move.l	a2,-(a7)
	pea	1.w
	pea	2.w
	pea	-$C(a5)
	jsr	_fread
	lea	$10(a7),a7
	cmp.l	#1,d0
	beq	L22
	moveq	#0,d0
	movem.l	(a7)+,d2/d7/a2/a3/a6
	unlk	a5
	rts
L22
	move.w	-$C(a5),d0
	ext.l	d0
	move.l	d0,_ftab+4
	move.l	a2,-(a7)
	pea	1.w
	pea	2.w
	pea	-$C(a5)
	jsr	_fread
	lea	$10(a7),a7
	cmp.l	#1,d0
	beq	L23
	moveq	#0,d0
	movem.l	(a7)+,d2/d7/a2/a3/a6
	unlk	a5
	rts
L23
	move.w	-$C(a5),d0
	ext.l	d0
	move.l	d0,_ftab+$8
	tst.l	_hLoaded
	beq	L26
	move.l	_ftab+$10,a3
	moveq	#0,d0
	tst.l	0(a3,d0.l*4)
	beq	L24
	move.l	_ftab+$10,a3
	moveq	#0,d0
	move.l	0(a3,d0.l*4),-(a7)
	jsr	_free
	addq.l	#4,a7
L24
	tst.l	_ftab+$10
	beq	L25
	move.l	_ftab+$10,-(a7)
	jsr	_free
	addq.l	#4,a7
L25
	clr.l	_hLoaded
L26
	move.w	_nchars,d0
	ext.l	d0
	addq.l	#1,d0
	asl.l	#2,d0
	move.l	d0,-(a7)
	jsr	_hallocate
	addq.l	#4,a7
	move.l	d0,_ftab+$10
	move.w	-$A(a5),d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,-(a7)
	jsr	_hallocate
	addq.l	#4,a7
	move.l	d0,_ftab+$C
	moveq	#0,d2
	bra	L28
L27
	move.l	a2,-(a7)
	pea	1.w
	pea	2.w
	pea	-$C(a5)
	jsr	_fread
	lea	$10(a7),a7
	cmp.l	#1,d0
	beq	L30
	moveq	#0,d0
	movem.l	(a7)+,d2/d7/a2/a3/a6
	unlk	a5
	rts
L30
	move.l	a2,-(a7)
	move.w	-$C(a5),d0
	ext.l	d0
	move.l	d0,-(a7)
	pea	1.w
	move.l	_ftab+$C,-(a7)
	jsr	_fread
	lea	$10(a7),a7
	move.w	-$C(a5),d7
	ext.l	d7
	cmp.l	d7,d0
	beq	L31
	moveq	#0,d0
	movem.l	(a7)+,d2/d7/a2/a3/a6
	unlk	a5
	rts
L31
	move.l	_ftab+$10,a3
	move.l	_ftab+$C,0(a3,d2.l*4)
	move.w	-$C(a5),d0
	ext.l	d0
	add.l	d0,_ftab+$C
L29
	addq.l	#1,d2
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
L28
	move.w	_nchars,d0
	ext.l	d0
	cmp.l	d0,d2
	blt	L27
	move.l	_ftab+$10,a3
	move.w	_nchars,d0
	ext.l	d0
	move.l	_ftab+$C,0(a3,d0.l*4)
	move.l	a2,-(a7)
	jsr	_fclose
	addq.l	#4,a7
	move.l	#1,_hLoaded
	moveq	#1,d0
	movem.l	(a7)+,d2/d7/a2/a3/a6
	unlk	a5
	rts

	XDEF	_hgetcharsize
_hgetcharsize
L74	EQU	$24
L75	EQU	$4CC4
	movem.l	d2/d6/d7/a2/a3/a6,-(a7)
	fmovem.x fp7,-(a7)
	move.b	L74+4(a7),d2
	move.l	L74+6(a7),a2
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L76
	jsr	_check_loaded
	addq.l	#4,a7
	move.l	_ftab,d7
	sub.l	_ftab+4,d7
	fmove.l	d7,fp7
	fmul.s	_SCSIZEY,fp7
	move.l	L74+$A(a7),a3
	fmove.s	fp7,(a3)
	tst.l	_Fixedwidth
	beq	L32
	fmove.l	_ftab+$8,fp7
	fmul.s	_SCSIZEX,fp7
	fmove.s	fp7,(a2)
	bra	L33
L32
	move.l	_ftab+$10,a3
	extb.l	d2
	move.l	d2,d7
	sub.l	#$20,d7
	move.l	0(a3,d7.l*4),a6
	move.b	1(a6),d7
	extb.l	d7
	move.l	_ftab+$10,a3
	extb.l	d2
	move.l	d2,d6
	sub.l	#$20,d6
	move.l	0(a3,d6.l*4),a6
	move.b	(a6),d6
	extb.l	d6
	sub.l	d6,d7
	fmove.l	d7,fp7
	fmul.s	_SCSIZEX,fp7
	fmove.s	fp7,(a2)
L33
	fmovem.x (a7)+,fp7
	movem.l	(a7)+,d2/d6/d7/a2/a3/a6
	rts

	XDEF	_hdrawchar
_hdrawchar
L77	EQU	-$78
	link	a5,#L77+60
L78	EQU	$4CFC
	movem.l	d2-d7/a2/a3/a6,-(a7)
	fmovem.x fp6/fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L79
	jsr	_check_loaded
	addq.l	#4,a7
	move.l	$8(a5),d7
	sub.l	#$20,d7
	move.l	d7,-$10(a5)
	cmp.l	#0,-$10(a5)
	bge	L34
	clr.l	-$10(a5)
L34
	move.l	-$10(a5),d7
	move.w	_nchars,d6
	ext.l	d6
	cmp.l	d6,d7
	blt	L35
	move.w	_nchars,d7
	ext.l	d7
	subq.l	#1,d7
	move.l	d7,-$10(a5)
L35
	moveq	#1,d4
	clr.l	-$20(a5)
	move.l	-$20(a5),-$1C(a5)
	tst.l	_Justify
	bne	L36
	tst.l	_Fixedwidth
	beq	L80
	move.l	_ftab+$8,d0
	neg.l	d0
	divs.l	#2,d0
	bra.b	L81
L80
	move.l	_ftab+$10,a3
	move.l	-$10(a5),d7
	move.l	0(a3,d7.l*4),a6
	move.b	(a6),d7
	extb.l	d7
	sub.l	#$52,d7
	move.l	d7,d0
L81
	move.l	d0,-$1C(a5)
	move.l	_ftab+4,-$20(a5)
	bra	L38
L36
	cmp.l	#2,_Justify
	bne	L37
	tst.l	_Fixedwidth
	beq	L82
	move.l	_ftab+$8,d0
	divs.l	#2,d0
	bra.b	L83
L82
	move.l	_ftab+$10,a3
	move.l	-$10(a5),d7
	move.l	0(a3,d7.l*4),a6
	move.b	(a6),d7
	extb.l	d7
	sub.l	#$52,d7
	neg.l	d7
	move.l	d7,d0
L83
	move.l	d0,-$1C(a5)
	move.l	_ftab+4,-$20(a5)
L37
L38
	move.l	_ftab+$10,a3
	move.l	-$10(a5),d7
	addq.l	#1,d7
	move.l	0(a3,d7.l*4),-$8(a5)
	move.l	_ftab+$10,a3
	move.l	-$10(a5),d7
	move.l	0(a3,d7.l*4),a6
	addq.l	#2,a6
	move.l	a6,a2
	clr.l	-$3C(a5)
	move.l	-$3C(a5),-$38(a5)
	bra	L40
L39
	move.b	(a2)+,d7
	extb.l	d7
	sub.l	#$52,d7
	move.l	d7,-$14(a5)
	move.b	(a2)+,d7
	extb.l	d7
	moveq	#$52,d6
	sub.l	d7,d6
	move.l	d6,-$18(a5)
	cmp.l	#-$32,-$14(a5)
	beq	L43
	move.l	-$14(a5),d7
	sub.l	-$1C(a5),d7
	fmove.l	d7,fp7
	fmul.s	_SCSIZEX,fp7
	fmove.s	fp7,d3
	move.l	-$18(a5),d7
	sub.l	-$20(a5),d7
	fmove.l	d7,fp7
	fmul.s	_SCSIZEY,fp7
	fmove.s	fp7,d2
	move.l	d3,d5
	fmove.s	_tcos,fp7
	fmul.s	d5,fp7
	fmove.s	_tsin,fp6
	fmul.s	d2,fp6
	fsub.x	fp6,fp7
	fmove.s	fp7,d3
	fmove.s	_tsin,fp7
	fmul.s	d5,fp7
	fmove.s	_tcos,fp6
	fmul.s	d2,fp6
	fadd.x	fp6,fp7
	fmove.s	fp7,d2
	fmove.s	d3,fp7
	fsub.s	-$38(a5),fp7
	fmove.s	fp7,-$24(a5)
	fmove.s	d2,fp7
	fsub.s	-$3C(a5),fp7
	fmove.s	fp7,-$28(a5)
	move.l	d3,-$38(a5)
	move.l	d2,-$3C(a5)
	tst.l	d4
	beq	L41
	moveq	#0,d4
	clr.l	-(a7)
	move.l	-$28(a5),-(a7)
	move.l	-$24(a5),-(a7)
	jsr	_rmv
	lea	$C(a7),a7
	bra	L42
L41
	clr.l	-(a7)
	move.l	-$28(a5),-(a7)
	move.l	-$24(a5),-(a7)
	jsr	_rdr
	lea	$C(a7),a7
L42
	bra.b	L44
L43
	moveq	#1,d4
L44
L40
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	cmp.l	-$8(a5),a2
	blt	L39
	tst.l	_Fixedwidth
	beq	L84
	fmove.l	_ftab+$8,fp7
	fmove.s	fp7,d7
	bra.b	L85
L84
	move.l	_ftab+$10,a3
	move.l	-$10(a5),d7
	move.l	0(a3,d7.l*4),a6
	move.b	1(a6),d7
	extb.l	d7
	move.l	_ftab+$10,a3
	move.l	-$10(a5),d6
	move.l	0(a3,d6.l*4),a6
	move.b	(a6),d6
	extb.l	d6
	sub.l	d6,d7
	fmove.l	d7,fp7
	fmove.s	fp7,d7
L85
	move.l	d7,d5
	fmove.s	d5,fp7
	fmul.s	_SCSIZEX,fp7
	fmove.s	fp7,d5
	fmove.s	_tcos,fp7
	fmul.s	d5,fp7
	fsub.s	-$38(a5),fp7
	fmove.s	fp7,-$24(a5)
	fmove.s	_tsin,fp7
	fmul.s	d5,fp7
	fsub.s	-$3C(a5),fp7
	fmove.s	fp7,-$28(a5)
	clr.l	-(a7)
	move.l	-$28(a5),-(a7)
	move.l	-$24(a5),-(a7)
	jsr	_rmv
	lea	$C(a7),a7
	fmovem.x (a7)+,fp6/fp7
	movem.l	(a7)+,d2-d7/a2/a3/a6
	unlk	a5
	rts

	XDEF	_htextsize
_htextsize
L86	EQU	$18
L87	EQU	$C4
	movem.l	d2/d6/d7,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L88
	jsr	_check_loaded
	addq.l	#4,a7
	move.l	_ftab+$8,d7
	move.l	_ftab,d6
	sub.l	_ftab+4,d6
	cmp.l	d6,d7
	bge	L89
	move.l	_ftab,d7
	sub.l	_ftab+4,d7
	bra.b	L90
L89
	move.l	_ftab+$8,d7
L90
	fmove.l	d7,fp7
	fmove.s	fp7,d2
	fmove.s	d2,fp7
	fcmp.s	#$.00000000,fp7
	fbuge.w	L91
	fmove.s	d2,fp7
	fneg.x	fp7
	fmove.s	fp7,d7
	bra.b	L92
L91
	move.l	d2,d7
L92
	fmove.s	L86+4(a7),fp7
	fdiv.s	d7,fp7
	fmove.s	fp7,_SCSIZEX
	fmove.s	d2,fp7
	fcmp.s	#$.00000000,fp7
	fbuge.w	L93
	fmove.s	d2,fp7
	fneg.x	fp7
	fmove.s	fp7,d7
	bra.b	L94
L93
	move.l	d2,d7
L94
	fmove.s	L86+$8(a7),fp7
	fdiv.s	d7,fp7
	fmove.s	fp7,_SCSIZEY
	fmovem.x (a7)+,fp7
	movem.l	(a7)+,d2/d6/d7
	rts

	XDEF	_hgetfontwidth__r
_hgetfontwidth__r
L95	EQU	$10
L96	EQU	$80
	move.l	d7,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L97
	jsr	_check_loaded
	addq.l	#4,a7
	move.l	_ftab+$8,d0
	move.l	_ftab,d7
	sub.l	_ftab+4,d7
	cmp.l	d7,d0
	bge	L98
	move.l	_ftab,d0
	sub.l	_ftab+4,d0
	bra.b	L99
L98
	move.l	_ftab+$8,d0
L99
	fmove.l	d0,fp0
	fmove.s	_SCSIZEX,fp7
	fmul.x	fp0,fp7
	fmove.x	fp7,fp0
	fmovem.x (a7)+,fp7
	movem.l	(a7)+,d7
	rts

	XDEF	_hgetfontheight__r
_hgetfontheight__r
L100	EQU	$10
L101	EQU	$80
	move.l	d7,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L102
	jsr	_check_loaded
	addq.l	#4,a7
	move.l	_ftab+$8,d0
	move.l	_ftab,d7
	sub.l	_ftab+4,d7
	cmp.l	d7,d0
	bge	L103
	move.l	_ftab,d0
	sub.l	_ftab+4,d0
	bra.b	L104
L103
	move.l	_ftab+$8,d0
L104
	fmove.l	d0,fp0
	fmove.s	_SCSIZEY,fp7
	fmul.x	fp0,fp7
	fmove.x	fp7,fp0
	fmovem.x (a7)+,fp7
	movem.l	(a7)+,d7
	rts

	XDEF	_hgetfontsize
_hgetfontsize
L105	EQU	4
L106	EQU	$800
	move.l	a3,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L107
	jsr	_check_loaded
	addq.l	#4,a7
	bsr	_hgetfontwidth__r
	move.l	L105+4(a7),a3
	fmove.s	fp0,(a3)
	bsr	_hgetfontheight__r
	move.l	L105+$8(a7),a3
	fmove.s	fp0,(a3)
	move.l	(a7)+,a3
	rts

	XDEF	_hgetdecender__r
_hgetdecender__r
L108	EQU	0
L109	EQU	0
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L110
	jsr	_check_loaded
	addq.l	#4,a7
	fmove.l	_ftab+4,fp0
	fmul.s	_SCSIZEY,fp0
	rts

	XDEF	_hgetascender__r
_hgetascender__r
L111	EQU	0
L112	EQU	0
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L113
	jsr	_check_loaded
	addq.l	#4,a7
	fmove.l	_ftab,fp0
	fmul.s	_SCSIZEY,fp0
	rts

	XDEF	_hcharstr
_hcharstr
L114	EQU	-$4E
	link	a5,#L114+52
L115	EQU	$447C
	movem.l	d2-d6/a2/a6,-(a7)
	fmovem.x fp6/fp7,-(a7)
	move.l	$8(a5),a6
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	move.l	a6,a2
	pea	L116
	jsr	_check_loaded
	addq.l	#4,a7
	bsr	_hgetfontheight__r
	fmove.s	fp0,d3
	move.l	a6,-(a7)
	jsr	_hstrlength__r
	addq.l	#4,a7
	fmove.s	fp0,d6
	moveq	#0,d4
	move.l	d4,d5
	cmp.l	#1,_Justify
	bne	L45
	fmove.s	d3,fp7
	fdiv.s	#$.40000000,fp7
	fmove.s	fp7,d3
	fmove.s	d6,fp7
	fdiv.s	#$.40000000,fp7
	fmove.s	fp7,d6
	fmove.s	d3,fp7
	fmul.s	_tsin,fp7
	fmove.s	d6,fp6
	fmul.s	_tcos,fp6
	fsub.x	fp6,fp7
	fmove.s	fp7,d5
	fmove.s	d3,fp7
	fneg.x	fp7
	fmul.s	_tcos,fp7
	fmove.s	d6,fp6
	fmul.s	_tsin,fp6
	fsub.x	fp6,fp7
	fmove.s	fp7,d4
	bra	L47
L45
	cmp.l	#2,_Justify
	bne	L46
	moveq	#0,d3
	fmove.s	d3,fp7
	fmul.s	_tsin,fp7
	fmove.s	d6,fp6
	fmul.s	_tcos,fp6
	fsub.x	fp6,fp7
	fmove.s	fp7,d5
	fmove.s	d3,fp7
	fneg.x	fp7
	fmul.s	_tcos,fp7
	fmove.s	d6,fp6
	fmul.s	_tsin,fp6
	fsub.x	fp6,fp7
	fmove.s	fp7,d4
L46
L47
	clr.l	-(a7)
	move.l	d4,-(a7)
	move.l	d5,-(a7)
	jsr	_rmv
	lea	$C(a7),a7
	move.l	_Justify,-$1A(a5)
	clr.l	_Justify
	bra	L49
L48
	extb.l	d2
	move.l	d2,-(a7)
	bsr	_hdrawchar
	addq.l	#4,a7
L49
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	move.b	(a2)+,d2
	bne.b	L48
	move.l	-$1A(a5),_Justify
	fmovem.x (a7)+,fp6/fp7
	movem.l	(a7)+,d2-d6/a2/a6
	unlk	a5
	rts

_istrlength
L117	EQU	$1C
L118	EQU	$4C9C
	movem.l	d2-d4/d7/a2/a3/a6,-(a7)
	move.l	L117+4(a7),a2
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	moveq	#0,d4
	tst.l	_Fixedwidth
	beq	L50
	move.l	a2,-(a7)
	jsr	_strlen
	addq.l	#4,a7
	mulu.l	_ftab+$8,d0
	movem.l	(a7)+,d2-d4/d7/a2/a3/a6
	rts
L50
	bra.b	L52
L51
	extb.l	d3
	move.l	d3,d0
	sub.l	#$20,d0
	move.l	d0,d2
	cmp.l	#0,d2
	blt	L119
	move.w	_nchars,d0
	ext.l	d0
	cmp.l	d0,d2
	blt	L53
L119
	move.w	_nchars,d0
	ext.l	d0
	subq.l	#1,d0
	move.l	d0,d2
L53
	move.l	_ftab+$10,a3
	move.l	0(a3,d2.l*4),a6
	move.b	1(a6),d0
	extb.l	d0
	move.l	_ftab+$10,a3
	move.l	0(a3,d2.l*4),a6
	move.b	(a6),d7
	extb.l	d7
	sub.l	d7,d0
	add.l	d0,d4
L52
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	move.b	(a2)+,d3
	bne.b	L51
	move.l	d4,d0
	movem.l	(a7)+,d2-d4/d7/a2/a3/a6
	rts
L54
	movem.l	(a7)+,d2-d4/d7/a2/a3/a6
	rts

	XDEF	_hstrlength__r
_hstrlength__r
L120	EQU	0
L121	EQU	0
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L122
	jsr	_check_loaded
	addq.l	#4,a7
	move.l	L120+4(a7),-(a7)
	bsr	_istrlength
	addq.l	#4,a7
	fmove.l	d0,fp0
	fmul.s	_SCSIZEX,fp0
	rts

	XDEF	_hboxtext
_hboxtext
L123	EQU	-$30
	link	a5,#L123+40
L124	EQU	$48C
	movem.l	d2/d3/d7/a2,-(a7)
	fmovem.x fp6/fp7,-(a7)
	move.l	$18(a5),a2
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L125
	jsr	_check_loaded
	addq.l	#4,a7
	move.l	_SCSIZEX,d3
	move.l	_SCSIZEY,d2
	move.l	a2,-(a7)
	bsr	_istrlength
	addq.l	#4,a7
	fmove.l	d0,fp7
	fmove.s	$10(a5),fp6
	fdiv.x	fp7,fp6
	fmove.s	fp6,_SCSIZEX
	move.l	_ftab,d7
	sub.l	_ftab+4,d7
	fmove.l	d7,fp7
	fmove.s	$14(a5),fp6
	fdiv.x	fp7,fp6
	fmove.s	fp6,_SCSIZEY
	move.l	$C(a5),-(a7)
	move.l	$8(a5),-(a7)
	jsr	_move2
	addq.l	#$8,a7
	move.l	a2,-(a7)
	bsr	_hcharstr
	addq.l	#4,a7
	move.l	d3,_SCSIZEX
	move.l	d2,_SCSIZEY
	fmovem.x (a7)+,fp6/fp7
	movem.l	(a7)+,d2/d3/d7/a2
	unlk	a5
	rts

	XDEF	_hboxfit
_hboxfit
L126	EQU	$1C
L127	EQU	$80
	move.l	d7,-(a7)
	fmovem.x fp6/fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	pea	L128
	jsr	_check_loaded
	addq.l	#4,a7
	move.l	L126+$C(a7),d0
	muls.l	_ftab+$8,d0
	fmove.l	d0,fp7
	fmove.s	L126+4(a7),fp6
	fdiv.x	fp7,fp6
	fmove.s	fp6,_SCSIZEX
	move.l	_ftab,d7
	sub.l	_ftab+4,d7
	fmove.l	d7,fp7
	fmove.s	L126+$8(a7),fp6
	fdiv.x	fp7,fp6
	fmove.s	fp6,_SCSIZEY
	fmovem.x (a7)+,fp6/fp7
	movem.l	(a7)+,d7
	rts

	XDEF	_hcentertext
_hcentertext
L129	EQU	0
L130	EQU	0
	tst.l	L129+4(a7)
	beq	L131
	moveq	#1,d0
	bra.b	L132
L131
	moveq	#0,d0
L132
	move.l	d0,_Justify
	rts

	XDEF	_hrightjustify
_hrightjustify
L133	EQU	0
L134	EQU	0
	tst.l	L133+4(a7)
	beq	L135
	moveq	#2,d0
	bra.b	L136
L135
	moveq	#0,d0
L136
	move.l	d0,_Justify
	rts

	XDEF	_hleftjustify
_hleftjustify
L137	EQU	0
L138	EQU	0
	tst.l	L137+4(a7)
	beq	L139
	moveq	#0,d0
	bra.b	L140
L139
	moveq	#2,d0
L140
	move.l	d0,_Justify
	rts

	XDEF	_hfixedwidth
_hfixedwidth
L141	EQU	0
L142	EQU	0
	move.l	L141+4(a7),_Fixedwidth
	rts

	XDEF	_htextang
_htextang
L143	EQU	$10
L144	EQU	4
	move.l	d2,-(a7)
	fmovem.x fp7,-(a7)
	move.s	L143+4(a7),d2
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L59
	fmove.s	d2,fp7
	fmul.d	#$.3F91DF46.A2529D2E,fp7
	fmove.d	fp7,-(a7)
	jsr	_cos__r
	addq.l	#$8,a7
	fmove.s	fp0,_tcos
	fmove.s	d2,fp7
	fmul.d	#$.3F91DF46.A2529D2E,fp7
	fmove.d	fp7,-(a7)
	jsr	_sin__r
	addq.l	#$8,a7
	fmove.s	fp0,_tsin
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L144
	rts

L59
	XREF	userbreak
	jsr	userbreak

L66
	dc.b	'/',0
L69
	dc.b	'HFONTLIB',0
L70
	dc.b	'VFONTLIB',0
L128
	dc.b	'hboxfit',0
L125
	dc.b	'hboxtext',0
L116
	dc.b	'hcharstr',0
L79
	dc.b	'hdrawchar',0
L71
	dc.b	'hershey:',0
L73
	dc.b	'hershlib: Can',$27,'t open Hershey fontfile ',$27,'%s',$27
	dc.b	' or ',$27,'./%s',$27,'.',$A,0
L60
	dc.b	'hershlib: problem reading font file ',$27,'%s',$27,'.',$A
	dc.b	0
L113
	dc.b	'hgetascender',0
L76
	dc.b	'hgetcharsize',0
L110
	dc.b	'hgetdecender',0
L102
	dc.b	'hgetfontheight',0
L107
	dc.b	'hgetfontsize',0
L97
	dc.b	'hgetfontwidth',0
L63
	dc.b	'hnumchars',0
L122
	dc.b	'hstrlength',0
L88
	dc.b	'htextsize',0
L72
	dc.b	'rb',0

	SECTION ":1",DATA

_tcos
	dc.l	$3F800000
_tsin
	dc.l	0
_SCSIZEX
	dc.l	$3F800000
_SCSIZEY
	dc.l	$3F800000
_Justify
	dc.l	0
_Fixedwidth
	dc.l	0
	XDEF	_hLoaded
_hLoaded
	dc.l	0
_old_font
	dc.b	0
	ds.b	255
_fpath
	dc.b	0
	ds.b	255

	SECTION ":2",BSS

_nchars
	ds.w	1
	CNOP	0,4
_ftab
	ds.b	20

	SECTION ":0",CODE


L59
	jsr	userbreak

	END

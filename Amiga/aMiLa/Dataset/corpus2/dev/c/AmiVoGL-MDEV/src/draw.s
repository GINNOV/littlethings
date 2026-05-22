
; Maxon C++ Compiler
; LS2:work/voGL/src/draw.c
	mc68020
	mc68881
	XREF	_newtokens
	XREF	_multvector
	XREF	_WtoVy
	XREF	_WtoVx
	XREF	_verror
	XREF	_quickclip
	XREF	_clip
	XREF	_std__in
	XREF	_std__out
	XREF	_std__err
	XREF	___MEMFLAGS
	XREF	_vdevice

	SECTION ":0",CODE


	XDEF	_draw
_draw
L13	EQU	-$40
	link	a5,#L13+36
L14	EQU	$4CFC
	movem.l	d2-d7/a2/a3/a6,-(a7)
	move.s	$10(a5),d4
	move.s	$C(a5),d5
	XREF	userbreak_flagpos
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	tst.b	_vdevice
	bne	L1
	pea	L16
	jsr	_verror
	addq.l	#4,a7
L1
	tst.b	_vdevice+2
	beq	L2
	pea	4.w
	jsr	_newtokens
	addq.l	#4,a7
	move.l	d0,-4(a5)
	move.l	d0,a3
	moveq	#0,d7
	move.l	#$8,0(a3,d7.l*4)
	moveq	#1,d7
	move.l	$8(a5),0(a3,d7.l*4)
	moveq	#2,d7
	move.l	d5,0(a3,d7.l*4)
	moveq	#3,d7
	move.l	d4,0(a3,d7.l*4)
	move.l	#_vdevice+$28,a3
	moveq	#0,d7
	move.l	$8(a5),0(a3,d7.l*4)
	move.l	#_vdevice+$28,a3
	moveq	#1,d7
	move.l	d5,0(a3,d7.l*4)
	move.l	#_vdevice+$28,a3
	moveq	#2,d7
	move.l	d4,0(a3,d7.l*4)
	clr.b	_vdevice+5
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L14
	unlk	a5
	rts
L2
	tst.b	_vdevice+5
	bne	L3
	move.l	_vdevice+$14,a2
	move.l	#_vdevice+$28,a3
	move.l	#_vdevice+$38,a6
	jsr	_multvector
L3
	move.l	#_vdevice+$28,a3
	moveq	#0,d7
	move.l	$8(a5),0(a3,d7.l*4)
	move.l	#_vdevice+$28,a3
	moveq	#1,d7
	move.l	d5,0(a3,d7.l*4)
	move.l	#_vdevice+$28,a3
	moveq	#2,d7
	move.l	d4,0(a3,d7.l*4)
	move.l	_vdevice+$14,a2
	move.l	#_vdevice+$28,a3
	lea	-$1C(a5),a6
	jsr	_multvector
	tst.b	_vdevice+1
	beq	L4
	pea	-$1C(a5)
	jsr	_WtoVx
	addq.l	#4,a7
	move.l	d0,d3
	pea	-$1C(a5)
	jsr	_WtoVy
	addq.l	#4,a7
	move.l	d0,d2
	move.l	_vdevice+$A4,a3
	move.l	d2,-(a7)
	move.l	d3,-(a7)
	jsr	(a3)
	addq.l	#$8,a7
	move.l	d3,_vdevice+$7C
	move.l	d2,_vdevice+$80
	clr.b	_vdevice+5
	bra	L7
L4
	tst.b	_vdevice+5
	beq	L5
	lea	-$1C(a5),a3
	move.l	#_vdevice+$38,a6
	jsr	_quickclip
	bra	L6
L5
	lea	-$1C(a5),a3
	move.l	#_vdevice+$38,a6
	jsr	_clip
L6
L7
	lea	-$1C(a5),a3
	moveq	#0,d7
	move.l	#_vdevice+$38,a6
	moveq	#0,d6
	move.l	0(a3,d7.l*4),0(a6,d6.l*4)
	lea	-$1C(a5),a3
	moveq	#1,d7
	move.l	#_vdevice+$38,a6
	moveq	#1,d6
	move.l	0(a3,d7.l*4),0(a6,d6.l*4)
	lea	-$1C(a5),a3
	moveq	#2,d7
	move.l	#_vdevice+$38,a6
	moveq	#2,d6
	move.l	0(a3,d7.l*4),0(a6,d6.l*4)
	lea	-$1C(a5),a3
	moveq	#3,d7
	move.l	#_vdevice+$38,a6
	moveq	#3,d6
	move.l	0(a3,d7.l*4),0(a6,d6.l*4)
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L14
	unlk	a5
	rts

	XDEF	_draws
_draws
L17	EQU	-$10
	link	a5,#L17+16
L18	EQU	$80
	movem.l	#L18,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	move.w	$C(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	move.w	$A(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	move.w	$8(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	bsr	_draw
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L18
	unlk	a5
	rts

	XDEF	_drawi
_drawi
L19	EQU	-$C
	link	a5,#L19+12
L20	EQU	0
	movem.l	#L20,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	fmove.l	$10(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_draw
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L20
	unlk	a5
	rts

	XDEF	_draw2
_draw2
L21	EQU	0
	link	a5,#L21
L22	EQU	0
	movem.l	#L22,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	tst.b	_vdevice
	bne	L8
	pea	L23
	jsr	_verror
	addq.l	#4,a7
L8
	clr.l	-(a7)
	move.l	$C(a5),-(a7)
	move.l	$8(a5),-(a7)
	bsr	_draw
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L22
	unlk	a5
	rts

	XDEF	_draw2s
_draw2s
L24	EQU	-$10
	link	a5,#L24+16
L25	EQU	$80
	movem.l	#L25,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	move.w	$A(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	move.w	$8(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	bsr	_draw2
	addq.l	#$8,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L25
	unlk	a5
	rts

	XDEF	_draw2i
_draw2i
L26	EQU	-$C
	link	a5,#L26+12
L27	EQU	0
	movem.l	#L27,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_draw2
	addq.l	#$8,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L27
	unlk	a5
	rts

	XDEF	_rdr
_rdr
L28	EQU	-$14
	link	a5,#L28+20
L29	EQU	$880
	movem.l	#L29,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	tst.b	_vdevice
	bne	L9
	pea	L30
	jsr	_verror
	addq.l	#4,a7
L9
	move.l	#_vdevice+$28,a3
	moveq	#2,d7
	fmove.s	0(a3,d7.l*4),fp7
	fadd.s	$10(a5),fp7
	fmove.s	fp7,-(a7)
	move.l	#_vdevice+$28,a3
	moveq	#1,d7
	fmove.s	0(a3,d7.l*4),fp7
	fadd.s	$C(a5),fp7
	fmove.s	fp7,-(a7)
	move.l	#_vdevice+$28,a3
	moveq	#0,d7
	fmove.s	0(a3,d7.l*4),fp7
	fadd.s	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_draw
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L29
	unlk	a5
	rts

	XDEF	_rdrs
_rdrs
L31	EQU	-$10
	link	a5,#L31+16
L32	EQU	$80
	movem.l	#L32,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	move.w	$C(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	move.w	$A(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	move.w	$8(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	bsr	_rdr
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L32
	unlk	a5
	rts

	XDEF	_rdri
_rdri
L33	EQU	-$C
	link	a5,#L33+12
L34	EQU	0
	movem.l	#L34,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	fmove.l	$10(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_rdr
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L34
	unlk	a5
	rts

	XDEF	_rdr2
_rdr2
L35	EQU	-$14
	link	a5,#L35+20
L36	EQU	$880
	movem.l	#L36,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	tst.b	_vdevice
	bne	L10
	pea	L37
	jsr	_verror
	addq.l	#4,a7
L10
	clr.l	-(a7)
	move.l	#_vdevice+$28,a3
	moveq	#1,d7
	fmove.s	0(a3,d7.l*4),fp7
	fadd.s	$C(a5),fp7
	fmove.s	fp7,-(a7)
	move.l	#_vdevice+$28,a3
	moveq	#0,d7
	fmove.s	0(a3,d7.l*4),fp7
	fadd.s	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_draw
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L36
	unlk	a5
	rts

	XDEF	_rdr2s
_rdr2s
L38	EQU	-$10
	link	a5,#L38+16
L39	EQU	$80
	movem.l	#L39,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	move.w	$A(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	move.w	$8(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	bsr	_rdr2
	addq.l	#$8,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L39
	unlk	a5
	rts

	XDEF	_rdr2i
_rdr2i
L40	EQU	-$C
	link	a5,#L40+12
L41	EQU	0
	movem.l	#L41,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_rdr2
	addq.l	#$8,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L41
	unlk	a5
	rts

	XDEF	_bgnline
_bgnline
L42	EQU	0
L43	EQU	0
	movem.l	#L43,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	tst.b	_vdevice+$DC
	beq	L11
	pea	L44
	jsr	_verror
	addq.l	#4,a7
L11
	move.b	#2,_vdevice+$DC
	move.b	#1,_vdevice+$DD
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L43
	rts

	XDEF	_endline
_endline
L45	EQU	0
L46	EQU	0
	movem.l	#L46,-(a7)
	clr.b	_vdevice+$DC
	clr.b	_vdevice+$DD
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L46
	rts

	XDEF	_bgnclosedline
_bgnclosedline
L47	EQU	0
L48	EQU	0
	movem.l	#L48,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	tst.b	_vdevice+$DC
	beq	L12
	pea	L49
	jsr	_verror
	addq.l	#4,a7
L12
	move.b	#3,_vdevice+$DC
	move.b	#1,_vdevice+$DD
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L48
	rts

	XDEF	_endclosedline
_endclosedline
L50	EQU	0
	link	a5,#L50
L51	EQU	0
	movem.l	#L51,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L15
	clr.b	_vdevice+$DC
	move.l	_vdevice+$D8,-(a7)
	move.l	_vdevice+$D4,-(a7)
	move.l	_vdevice+$D0,-(a7)
	bsr	_draw
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L51
	unlk	a5
	rts

L15
	XREF	userbreak
	jsr	userbreak

L23
	dc.b	'draw2: vogl not initialised',0
L16
	dc.b	'draw: vogl not initialised',0
L37
	dc.b	'rdr2: vogl not initialised',0
L30
	dc.b	'rdr: vogl not initialised',0
L49
	dc.b	'vogl: bgncloseline mode already belongs to some other bgn ro'
	dc.b	'utine',0
L44
	dc.b	'vogl: bgnline mode already belongs to some other bgn routine'
	dc.b	0

	SECTION ":0",CODE


L15
	jsr	userbreak

	END

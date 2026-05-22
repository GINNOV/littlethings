
; Maxon C++ Compiler
; LS2:work/voGL/src/rect.c
	mc68020
	mc68881
	XREF	_pclos
	XREF	_pdr2
	XREF	_pmv2
	XREF	_newtokens
	XREF	_move2
	XREF	_verror
	XREF	_draw2
	XREF	_std__in
	XREF	_std__out
	XREF	_std__err
	XREF	___MEMFLAGS
	XREF	_vdevice

	SECTION ":0",CODE


	XDEF	_rect
_rect
L4	EQU	-$10
	link	a5,#L4+16
L5	EQU	$3C
	movem.l	d2-d5,-(a7)
	move.s	$C(a5),d2
	move.s	$8(a5),d3
	move.s	$14(a5),d4
	move.s	$10(a5),d5
	XREF	userbreak_flagpos
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L6
	tst.b	_vdevice
	bne	L1
	pea	L7
	jsr	_verror
	addq.l	#4,a7
L1
	move.l	d2,-(a7)
	move.l	d3,-(a7)
	jsr	_move2
	addq.l	#$8,a7
	move.l	d2,-(a7)
	move.l	d5,-(a7)
	jsr	_draw2
	addq.l	#$8,a7
	move.l	d4,-(a7)
	move.l	d5,-(a7)
	jsr	_draw2
	addq.l	#$8,a7
	move.l	d4,-(a7)
	move.l	d3,-(a7)
	jsr	_draw2
	addq.l	#$8,a7
	move.l	d2,-(a7)
	move.l	d3,-(a7)
	jsr	_draw2
	addq.l	#$8,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L5
	unlk	a5
	rts

	XDEF	_recti
_recti
L8	EQU	-$C
	link	a5,#L8+12
L9	EQU	0
	movem.l	#L9,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L6
	fmove.l	$14(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$10(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_rect
	lea	$10(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L9
	unlk	a5
	rts

	XDEF	_rects
_rects
L10	EQU	-$10
	link	a5,#L10+16
L11	EQU	$80
	movem.l	#L11,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L6
	move.w	$E(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
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
	bsr	_rect
	lea	$10(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L11
	unlk	a5
	rts

	XDEF	_rectf
_rectf
L12	EQU	-$20
	link	a5,#L12+28
L13	EQU	$CBC
	movem.l	#L13,-(a7)
	move.s	$C(a5),d2
	move.s	$8(a5),d3
	move.s	$14(a5),d4
	move.s	$10(a5),d5
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L6
	tst.b	_vdevice
	bne	L2
	pea	L7
	jsr	_verror
	addq.l	#4,a7
L2
	tst.b	_vdevice+2
	beq	L3
	pea	5.w
	jsr	_newtokens
	addq.l	#4,a7
	move.l	d0,a2
	move.l	a2,a3
	moveq	#0,d7
	move.l	#$2C,0(a3,d7.l*4)
	move.l	a2,a3
	moveq	#1,d7
	move.l	d3,0(a3,d7.l*4)
	move.l	a2,a3
	moveq	#2,d7
	move.l	d2,0(a3,d7.l*4)
	move.l	a2,a3
	moveq	#3,d7
	move.l	d5,0(a3,d7.l*4)
	move.l	a2,a3
	moveq	#4,d7
	move.l	d4,0(a3,d7.l*4)
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L13
	unlk	a5
	rts
L3
	move.l	d2,-(a7)
	move.l	d3,-(a7)
	jsr	_pmv2
	addq.l	#$8,a7
	move.l	d2,-(a7)
	move.l	d5,-(a7)
	jsr	_pdr2
	addq.l	#$8,a7
	move.l	d4,-(a7)
	move.l	d5,-(a7)
	jsr	_pdr2
	addq.l	#$8,a7
	move.l	d4,-(a7)
	move.l	d3,-(a7)
	jsr	_pdr2
	addq.l	#$8,a7
	move.l	d2,-(a7)
	move.l	d3,-(a7)
	jsr	_pdr2
	addq.l	#$8,a7
	jsr	_pclos
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L13
	unlk	a5
	rts

	XDEF	_rectfi
_rectfi
L14	EQU	-$C
	link	a5,#L14+12
L15	EQU	0
	movem.l	#L15,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L6
	fmove.l	$14(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$10(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_rectf
	lea	$10(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L15
	unlk	a5
	rts

	XDEF	_rectfs
_rectfs
L16	EQU	-$10
	link	a5,#L16+16
L17	EQU	$80
	movem.l	#L17,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L6
	move.w	$E(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
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
	bsr	_rectf
	lea	$10(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L17
	unlk	a5
	rts

L6
	XREF	userbreak
	jsr	userbreak

L7
	dc.b	'rect: vogl not initialised',0

	SECTION ":0",CODE


L6
	jsr	userbreak

	END

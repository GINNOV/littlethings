
; Maxon C++ Compiler
; LS2:work/voGL/src/move.c
	mc68020
	mc68881
	XREF	_newtokens
	XREF	_multvector
	XREF	_WtoVy
	XREF	_WtoVx
	XREF	_verror
	XREF	_std__in
	XREF	_std__out
	XREF	_std__err
	XREF	___MEMFLAGS
	XREF	_vdevice

	SECTION ":0",CODE


	XDEF	_move
_move
L7	EQU	-$20
	link	a5,#L7+28
L8	EQU	$4C9C
	movem.l	d2-d4/d7/a2/a3/a6,-(a7)
	move.s	$10(a5),d2
	move.s	$C(a5),d3
	move.s	$8(a5),d4
	XREF	userbreak_flagpos
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
	tst.b	_vdevice
	bne	L1
	pea	L10
	jsr	_verror
	addq.l	#4,a7
L1
	move.l	#_vdevice+$28,a3
	moveq	#0,d7
	move.l	d4,0(a3,d7.l*4)
	move.l	#_vdevice+$28,a3
	moveq	#1,d7
	move.l	d3,0(a3,d7.l*4)
	move.l	#_vdevice+$28,a3
	moveq	#2,d7
	move.l	d2,0(a3,d7.l*4)
	clr.b	_vdevice+5
	tst.b	_vdevice+2
	beq	L2
	pea	4.w
	jsr	_newtokens
	addq.l	#4,a7
	move.l	d0,-4(a5)
	move.l	d0,a3
	moveq	#0,d7
	move.l	#$11,0(a3,d7.l*4)
	moveq	#1,d7
	move.l	d4,0(a3,d7.l*4)
	moveq	#2,d7
	move.l	d3,0(a3,d7.l*4)
	moveq	#3,d7
	move.l	d2,0(a3,d7.l*4)
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L8
	unlk	a5
	rts
L2
	tst.b	_vdevice+1
	beq	L3
	move.l	_vdevice+$14,a2
	move.l	#_vdevice+$28,a3
	move.l	#_vdevice+$38,a6
	jsr	_multvector
	pea	_vdevice+$38
	jsr	_WtoVx
	addq.l	#4,a7
	move.l	d0,_vdevice+$7C
	pea	_vdevice+$38
	jsr	_WtoVy
	addq.l	#4,a7
	move.l	d0,_vdevice+$80
L3
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L8
	unlk	a5
	rts

	XDEF	_moves
_moves
L11	EQU	-$10
	link	a5,#L11+16
L12	EQU	$80
	movem.l	#L12,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
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
	bsr	_move
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L12
	unlk	a5
	rts

	XDEF	_movei
_movei
L13	EQU	-$C
	link	a5,#L13+12
L14	EQU	0
	movem.l	#L14,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
	fmove.l	$10(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_move
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L14
	unlk	a5
	rts

	XDEF	_move2
_move2
L15	EQU	0
	link	a5,#L15
L16	EQU	0
	movem.l	#L16,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
	tst.b	_vdevice
	bne	L4
	pea	L17
	jsr	_verror
	addq.l	#4,a7
L4
	clr.l	-(a7)
	move.l	$C(a5),-(a7)
	move.l	$8(a5),-(a7)
	bsr	_move
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L16
	unlk	a5
	rts

	XDEF	_move2s
_move2s
L18	EQU	-$10
	link	a5,#L18+16
L19	EQU	$80
	movem.l	#L19,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
	move.w	$A(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	move.w	$8(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	bsr	_move2
	addq.l	#$8,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L19
	unlk	a5
	rts

	XDEF	_move2i
_move2i
L20	EQU	-$C
	link	a5,#L20+12
L21	EQU	0
	movem.l	#L21,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_move2
	addq.l	#$8,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L21
	unlk	a5
	rts

	XDEF	_rmv
_rmv
L22	EQU	-$14
	link	a5,#L22+20
L23	EQU	$880
	movem.l	#L23,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
	tst.b	_vdevice
	bne	L5
	pea	L24
	jsr	_verror
	addq.l	#4,a7
L5
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
	bsr	_move
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L23
	unlk	a5
	rts

	XDEF	_rmvs
_rmvs
L25	EQU	-$10
	link	a5,#L25+16
L26	EQU	$80
	movem.l	#L26,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
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
	bsr	_rmv
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L26
	unlk	a5
	rts

	XDEF	_rmvi
_rmvi
L27	EQU	-$C
	link	a5,#L27+12
L28	EQU	0
	movem.l	#L28,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
	fmove.l	$10(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_rmv
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L28
	unlk	a5
	rts

	XDEF	_rmv2
_rmv2
L29	EQU	-$14
	link	a5,#L29+20
L30	EQU	$880
	movem.l	#L30,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
	tst.b	_vdevice
	bne	L6
	pea	L31
	jsr	_verror
	addq.l	#4,a7
L6
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
	bsr	_move
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L30
	unlk	a5
	rts

	XDEF	_rmv2s
_rmv2s
L32	EQU	-$10
	link	a5,#L32+16
L33	EQU	$80
	movem.l	#L33,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
	move.w	$A(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	move.w	$8(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	bsr	_rmv2
	addq.l	#$8,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L33
	unlk	a5
	rts

	XDEF	_rmv2i
_rmv2i
L34	EQU	-$C
	link	a5,#L34+12
L35	EQU	0
	movem.l	#L35,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L9
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_rmv2
	addq.l	#$8,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L35
	unlk	a5
	rts

L9
	XREF	userbreak
	jsr	userbreak

L17
	dc.b	'move2: vogl not initialised',0
L10
	dc.b	'move: vogl not initialised',0
L31
	dc.b	'rmv2: vogl not initialised',0
L24
	dc.b	'rmv: vogl not initialised',0

	SECTION ":0",CODE


L9
	jsr	userbreak

	END

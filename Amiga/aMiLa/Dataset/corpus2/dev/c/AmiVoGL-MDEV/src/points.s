
; Maxon C++ Compiler
; LS2:work/voGL/src/points.c
	mc68020
	mc68881
	XREF	_move
	XREF	_verror
	XREF	_draw
	XREF	_std__in
	XREF	_std__out
	XREF	_std__err
	XREF	___MEMFLAGS
	XREF	_vdevice

	SECTION ":0",CODE


	XDEF	_pnt
_pnt
L3	EQU	-$C
	link	a5,#L3+12
L4	EQU	$1C
	movem.l	d2-d4,-(a7)
	move.s	$10(a5),d2
	move.s	$C(a5),d3
	move.s	$8(a5),d4
	XREF	userbreak_flagpos
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L5
	tst.b	_vdevice
	bne	L1
	pea	L6
	jsr	_verror
	addq.l	#4,a7
L1
	move.l	d2,-(a7)
	move.l	d3,-(a7)
	move.l	d4,-(a7)
	jsr	_move
	lea	$C(a7),a7
	move.l	d2,-(a7)
	move.l	d3,-(a7)
	move.l	d4,-(a7)
	jsr	_draw
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L4
	unlk	a5
	rts

	XDEF	_pnts
_pnts
L7	EQU	-$10
	link	a5,#L7+16
L8	EQU	$80
	movem.l	#L8,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L5
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	move.w	$A(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	move.w	$8(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	bsr	_pnt
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L8
	unlk	a5
	rts

	XDEF	_pnti
_pnti
L9	EQU	-$C
	link	a5,#L9+12
L10	EQU	0
	movem.l	#L10,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L5
	fmove.l	$10(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_pnt
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L10
	unlk	a5
	rts

	XDEF	_pnt2
_pnt2
L11	EQU	-$8
	link	a5,#L11+8
L12	EQU	$C
	movem.l	#L12,-(a7)
	move.s	$C(a5),d2
	move.s	$8(a5),d3
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L5
	clr.l	-(a7)
	move.l	d2,-(a7)
	move.l	d3,-(a7)
	jsr	_move
	lea	$C(a7),a7
	clr.l	-(a7)
	move.l	d2,-(a7)
	move.l	d3,-(a7)
	jsr	_draw
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L12
	unlk	a5
	rts

	XDEF	_pnt2s
_pnt2s
L13	EQU	-$10
	link	a5,#L13+16
L14	EQU	$80
	movem.l	#L14,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L5
	move.w	$A(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	move.w	$8(a5),d7
	ext.l	d7
	fmove.l	d7,fp7
	fmove.s	fp7,-(a7)
	bsr	_pnt2
	addq.l	#$8,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L14
	unlk	a5
	rts

	XDEF	_pnt2i
_pnt2i
L15	EQU	-$C
	link	a5,#L15+12
L16	EQU	0
	movem.l	#L16,-(a7)
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L5
	fmove.l	$C(a5),fp7
	fmove.s	fp7,-(a7)
	fmove.l	$8(a5),fp7
	fmove.s	fp7,-(a7)
	bsr	_pnt2
	addq.l	#$8,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L16
	unlk	a5
	rts

	XDEF	_bgnpoint
_bgnpoint
L17	EQU	0
L18	EQU	0
	movem.l	#L18,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L5
	tst.b	_vdevice+$DC
	beq	L2
	pea	L19
	jsr	_verror
	addq.l	#4,a7
L2
	move.b	#1,_vdevice+$DC
	clr.b	_vdevice+$DD
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L18
	rts

	XDEF	_endpoint
_endpoint
L20	EQU	0
L21	EQU	0
	movem.l	#L21,-(a7)
	clr.b	_vdevice+$DC
	clr.b	_vdevice+$DD
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L21
	rts

L5
	XREF	userbreak
	jsr	userbreak

L6
	dc.b	'pnt: vogl not initialised',0
L19
	dc.b	'vogl: bgnpoint mode already belongs to some other bgn routin'
	dc.b	'e',0

	SECTION ":0",CODE


L5
	jsr	userbreak

	END

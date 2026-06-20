
; Maxon C++ Compiler
; LS2:work/voGL/src/scale.c
	mc68020
	mc68881
	XREF	_newtokens
	XREF	_verror
	XREF	_std__in
	XREF	_std__out
	XREF	_std__err
	XREF	___MEMFLAGS
	XREF	_vdevice

	SECTION ":0",CODE


	XDEF	_scale
_scale
L3	EQU	$24
L4	EQU	$C9C
	movem.l	d2-d4/d7/a2/a3,-(a7)
	fmovem.x fp7,-(a7)
	move.s	L3+$C(a7),d2
	move.s	L3+$8(a7),d3
	move.s	L3+4(a7),d4
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
	tst.b	_vdevice+2
	beq	L2
	pea	4.w
	jsr	_newtokens
	addq.l	#4,a7
	move.l	d0,a2
	move.l	a2,a3
	moveq	#0,d7
	move.l	#$28,0(a3,d7.l*4)
	move.l	a2,a3
	moveq	#1,d7
	move.l	d4,0(a3,d7.l*4)
	move.l	a2,a3
	moveq	#2,d7
	move.l	d3,0(a3,d7.l*4)
	move.l	a2,a3
	moveq	#3,d7
	move.l	d2,0(a3,d7.l*4)
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L4
	rts
L2
	move.l	_vdevice+$14,a3
	moveq	#0,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d4,fp7
	move.l	_vdevice+$14,a3
	moveq	#0,d7
	fmove.s	fp7,0(a3,d7.l*4)
	move.l	_vdevice+$14,a3
	moveq	#1,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d4,fp7
	move.l	_vdevice+$14,a3
	moveq	#1,d7
	fmove.s	fp7,0(a3,d7.l*4)
	move.l	_vdevice+$14,a3
	moveq	#2,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d4,fp7
	move.l	_vdevice+$14,a3
	moveq	#2,d7
	fmove.s	fp7,0(a3,d7.l*4)
	move.l	_vdevice+$14,a3
	moveq	#3,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d4,fp7
	move.l	_vdevice+$14,a3
	moveq	#3,d7
	fmove.s	fp7,0(a3,d7.l*4)
	move.l	_vdevice+$14,a3
	lea	$10(a3),a3
	moveq	#0,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d3,fp7
	move.l	_vdevice+$14,a3
	lea	$10(a3),a3
	moveq	#0,d7
	fmove.s	fp7,0(a3,d7.l*4)
	move.l	_vdevice+$14,a3
	lea	$10(a3),a3
	moveq	#1,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d3,fp7
	move.l	_vdevice+$14,a3
	lea	$10(a3),a3
	moveq	#1,d7
	fmove.s	fp7,0(a3,d7.l*4)
	move.l	_vdevice+$14,a3
	lea	$10(a3),a3
	moveq	#2,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d3,fp7
	move.l	_vdevice+$14,a3
	lea	$10(a3),a3
	moveq	#2,d7
	fmove.s	fp7,0(a3,d7.l*4)
	move.l	_vdevice+$14,a3
	lea	$10(a3),a3
	moveq	#3,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d3,fp7
	move.l	_vdevice+$14,a3
	lea	$10(a3),a3
	moveq	#3,d7
	fmove.s	fp7,0(a3,d7.l*4)
	move.l	_vdevice+$14,a3
	lea	$20(a3),a3
	moveq	#0,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d2,fp7
	move.l	_vdevice+$14,a3
	lea	$20(a3),a3
	moveq	#0,d7
	fmove.s	fp7,0(a3,d7.l*4)
	move.l	_vdevice+$14,a3
	lea	$20(a3),a3
	moveq	#1,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d2,fp7
	move.l	_vdevice+$14,a3
	lea	$20(a3),a3
	moveq	#1,d7
	fmove.s	fp7,0(a3,d7.l*4)
	move.l	_vdevice+$14,a3
	lea	$20(a3),a3
	moveq	#2,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d2,fp7
	move.l	_vdevice+$14,a3
	lea	$20(a3),a3
	moveq	#2,d7
	fmove.s	fp7,0(a3,d7.l*4)
	move.l	_vdevice+$14,a3
	lea	$20(a3),a3
	moveq	#3,d7
	fmove.s	0(a3,d7.l*4),fp7
	fmul.s	d2,fp7
	move.l	_vdevice+$14,a3
	lea	$20(a3),a3
	moveq	#3,d7
	fmove.s	fp7,0(a3,d7.l*4)
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L4
	rts

L5
	XREF	userbreak
	jsr	userbreak

L6
	dc.b	'scale: vogl not initialised',0

	SECTION ":0",CODE


L5
	jsr	userbreak

	END

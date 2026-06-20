
; Maxon C++ Compiler
; LS2:work/voGL/src/viewing.c
	mc68020
	mc68881
	XREF	_rotate
	XREF	_translate
	XREF	_identmatrix
	XREF	_multmatrix
	XREF	_loadmatrix
	XREF	_verror
	XREF	_sqrt__r
	XREF	_cos__r
	XREF	_sin__r
	XREF	_std__in
	XREF	_std__out
	XREF	_std__err
	XREF	___MEMFLAGS
	XREF	_vdevice

	SECTION ":0",CODE


	XDEF	_polarview
_polarview
L20	EQU	-$10
	link	a5,#L20+16
L21	EQU	$80
	move.l	d7,-(a7)
	fmovem.x fp7,-(a7)
	XREF	userbreak_flagpos
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L22
	tst.b	_vdevice
	bne	L1
	pea	L23
	jsr	_verror
	addq.l	#4,a7
L1
	fmove.s	$8(a5),fp7
	fneg.x	fp7
	fmove.s	fp7,-(a7)
	clr.l	-(a7)
	clr.l	-(a7)
	jsr	_translate
	lea	$C(a7),a7
	move.b	#$7A,-(a7)
	move.w	$10(a5),d7
	ext.l	d7
	neg.l	d7
	move.w	d7,-(a7)
	jsr	_rotate
	addq.l	#4,a7
	move.b	#$78,-(a7)
	move.w	$E(a5),d7
	ext.l	d7
	neg.l	d7
	move.w	d7,-(a7)
	jsr	_rotate
	addq.l	#4,a7
	move.b	#$7A,-(a7)
	move.w	$C(a5),d7
	ext.l	d7
	neg.l	d7
	move.w	d7,-(a7)
	jsr	_rotate
	addq.l	#4,a7
	fmovem.x (a7)+,fp7
	move.l	(a7)+,d7
	unlk	a5
	rts

_normallookat
L24	EQU	-$9C
	link	a5,#L24+68
L25	EQU	$48FC
	movem.l	d2-d7/a3/a6,-(a7)
	fmovem.x fp5/fp6/fp7,-(a7)
	move.s	$1C(a5),d4
	move.s	$14(a5),d5
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L22
	fmove.s	d5,fp7
	fsub.s	$8(a5),fp7
	fmove.s	d5,fp6
	fsub.s	$8(a5),fp6
	fmul.x	fp6,fp7
	fmove.s	d4,fp6
	fsub.s	$10(a5),fp6
	fmove.s	d4,fp5
	fsub.s	$10(a5),fp5
	fmul.x	fp5,fp6
	fadd.x	fp6,fp7
	fmove.d	fp7,-(a7)
	jsr	_sqrt__r
	addq.l	#$8,a7
	fmove.s	fp0,d2
	fmove.s	d5,fp7
	fsub.s	$8(a5),fp7
	fmove.s	d5,fp6
	fsub.s	$8(a5),fp6
	fmul.x	fp6,fp7
	fmove.s	$18(a5),fp6
	fsub.s	$C(a5),fp6
	fmove.s	$18(a5),fp5
	fsub.s	$C(a5),fp5
	fmul.x	fp5,fp6
	fadd.x	fp6,fp7
	fmove.s	d4,fp6
	fsub.s	$10(a5),fp6
	fmove.s	d4,fp5
	fsub.s	$10(a5),fp5
	fmul.x	fp5,fp6
	fadd.x	fp6,fp7
	fmove.d	fp7,-(a7)
	jsr	_sqrt__r
	addq.l	#$8,a7
	fmove.s	fp0,d3
	fmove.s	d3,fp7
	ftst.x	fp7
	fbeq.w	L2
	fmove.s	$C(a5),fp7
	fsub.s	$18(a5),fp7
	fdiv.s	d3,fp7
	fmove.s	fp7,-$10(a5)
	fmove.s	d2,fp7
	fdiv.s	d3,fp7
	fmove.s	fp7,-$18(a5)
	pea	-$58(a5)
	jsr	_identmatrix
	addq.l	#4,a7
	lea	-$58(a5),a3
	lea	$20(a3),a3
	moveq	#2,d7
	move.l	-$18(a5),0(a3,d7.l*4)
	lea	-$58(a5),a6
	lea	$10(a6),a6
	moveq	#1,d6
	move.l	0(a3,d7.l*4),0(a6,d6.l*4)
	lea	-$58(a5),a3
	lea	$10(a3),a3
	moveq	#2,d7
	move.l	-$10(a5),0(a3,d7.l*4)
	fmove.s	-$10(a5),fp7
	fneg.x	fp7
	lea	-$58(a5),a3
	lea	$20(a3),a3
	moveq	#1,d7
	fmove.s	fp7,0(a3,d7.l*4)
	pea	-$58(a5)
	jsr	_multmatrix
	addq.l	#4,a7
L2
	fmove.s	d2,fp7
	ftst.x	fp7
	fbeq.w	L3
	fmove.s	d5,fp7
	fsub.s	$8(a5),fp7
	fdiv.s	d2,fp7
	fmove.s	fp7,-$C(a5)
	fmove.s	$10(a5),fp7
	fsub.s	d4,fp7
	fdiv.s	d2,fp7
	fmove.s	fp7,-$14(a5)
	pea	-$58(a5)
	jsr	_identmatrix
	addq.l	#4,a7
	lea	-$58(a5),a3
	lea	$20(a3),a3
	moveq	#2,d7
	move.l	-$14(a5),0(a3,d7.l*4)
	lea	-$58(a5),a6
	moveq	#0,d6
	move.l	0(a3,d7.l*4),0(a6,d6.l*4)
	fmove.s	-$C(a5),fp7
	fneg.x	fp7
	lea	-$58(a5),a3
	moveq	#2,d7
	fmove.s	fp7,0(a3,d7.l*4)
	lea	-$58(a5),a3
	lea	$20(a3),a3
	moveq	#0,d7
	move.l	-$C(a5),0(a3,d7.l*4)
	pea	-$58(a5)
	jsr	_multmatrix
	addq.l	#4,a7
L3
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L25
	unlk	a5
	rts

	XDEF	_lookat
_lookat
L26	EQU	-$1C
	link	a5,#L26+28
L27	EQU	$9C
	movem.l	#L27,-(a7)
	fmovem.x fp7,-(a7)
	move.s	$10(a5),d2
	move.s	$C(a5),d3
	move.s	$8(a5),d4
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L22
	tst.b	_vdevice
	bne	L4
	pea	L28
	jsr	_verror
	addq.l	#4,a7
L4
	move.b	#$7A,-(a7)
	move.w	$20(a5),d7
	ext.l	d7
	neg.l	d7
	move.w	d7,-(a7)
	jsr	_rotate
	addq.l	#4,a7
	move.l	$1C(a5),-(a7)
	move.l	$18(a5),-(a7)
	move.l	$14(a5),-(a7)
	move.l	d2,-(a7)
	move.l	d3,-(a7)
	move.l	d4,-(a7)
	bsr	_normallookat
	lea	$18(a7),a7
	fmove.s	d2,fp7
	fneg.x	fp7
	fmove.s	fp7,-(a7)
	fmove.s	d3,fp7
	fneg.x	fp7
	fmove.s	fp7,-(a7)
	fmove.s	d4,fp7
	fneg.x	fp7
	fmove.s	fp7,-(a7)
	jsr	_translate
	lea	$C(a7),a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L27
	unlk	a5
	rts

	XDEF	_perspective
_perspective
L29	EQU	-$88
	link	a5,#L29+52
L30	EQU	$8FC
	movem.l	#L30,-(a7)
	fmovem.x fp6/fp7,-(a7)
	move.s	$12(a5),d3
	move.s	$E(a5),d4
	move.w	$8(a5),d5
	move.s	$A(a5),d6
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L22
	tst.b	_vdevice
	bne	L5
	pea	L31
	jsr	_verror
	addq.l	#4,a7
L5
	fmove.s	d6,fp7
	ftst.x	fp7
	fbne.w	L6
	pea	L32
	jsr	_verror
	addq.l	#4,a7
L6
	fmove.s	d3,fp7
	fsub.s	d4,fp7
	ftst.x	fp7
	fbne.w	L7
	pea	L33
	jsr	_verror
	addq.l	#4,a7
L7
	tst.w	d5
	beq	L34
	cmp.w	#$708,d5
	bne	L8
L34
	pea	L35
	jsr	_verror
	addq.l	#4,a7
L8
	ext.l	d5
	fmove.l	d5,fp7
	fdiv.d	#$.40240000.00000000,fp7
	fmove.s	fp7,d2
	pea	-$40(a5)
	jsr	_identmatrix
	addq.l	#4,a7
	fmove.s	d2,fp7
	fmul.d	#$.3F91DF46.A2529D2E,fp7
	fdiv.d	#$.40000000.00000000,fp7
	fmove.d	fp7,-(a7)
	jsr	_cos__r
	addq.l	#$8,a7
	fmove.s	d2,fp7
	fmul.d	#$.3F91DF46.A2529D2E,fp7
	fdiv.d	#$.40000000.00000000,fp7
	fmove.d	fp7,-(a7)
	fmove.d	fp0,-$4C(a5)
	jsr	_sin__r
	addq.l	#$8,a7
	fmove.d	-$4C(a5),fp7
	fdiv.x	fp0,fp7
	fdiv.s	d6,fp7
	lea	-$40(a5),a3
	moveq	#0,d7
	fmove.s	fp7,0(a3,d7.l*4)
	fmove.s	d2,fp7
	fmul.d	#$.3F91DF46.A2529D2E,fp7
	fdiv.d	#$.40000000.00000000,fp7
	fmove.d	fp7,-(a7)
	jsr	_cos__r
	addq.l	#$8,a7
	fmove.s	d2,fp7
	fmul.d	#$.3F91DF46.A2529D2E,fp7
	fdiv.d	#$.40000000.00000000,fp7
	fmove.d	fp7,-(a7)
	fmove.d	fp0,-$54(a5)
	jsr	_sin__r
	addq.l	#$8,a7
	fmove.d	-$54(a5),fp7
	fdiv.x	fp0,fp7
	lea	-$40(a5),a3
	lea	$10(a3),a3
	moveq	#1,d7
	fmove.s	fp7,0(a3,d7.l*4)
	fmove.s	d3,fp7
	fadd.s	d4,fp7
	fneg.x	fp7
	fmove.s	d3,fp6
	fsub.s	d4,fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$20(a3),a3
	moveq	#2,d7
	fmove.s	fp7,0(a3,d7.l*4)
	lea	-$40(a5),a3
	lea	$20(a3),a3
	moveq	#3,d7
	move.l	#$BF800000,0(a3,d7.l*4)
	fmove.s	d3,fp7
	fmul.d	#$.C0000000.00000000,fp7
	fmove.s	d4,fp6
	fmul.x	fp6,fp7
	fmove.s	d3,fp6
	fsub.s	d4,fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$30(a3),a3
	moveq	#2,d7
	fmove.s	fp7,0(a3,d7.l*4)
	lea	-$40(a5),a3
	lea	$30(a3),a3
	moveq	#3,d7
	clr.l	0(a3,d7.l*4)
	pea	-$40(a5)
	jsr	_loadmatrix
	addq.l	#4,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L30
	unlk	a5
	rts

	XDEF	_window
_window
L36	EQU	-$74
	link	a5,#L36+52
L37	EQU	$8FC
	movem.l	#L37,-(a7)
	fmovem.x fp6/fp7,-(a7)
	move.s	$18(a5),d2
	move.s	$1C(a5),d3
	move.s	$14(a5),d4
	move.s	$10(a5),d5
	move.s	$C(a5),d6
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L22
	tst.b	_vdevice
	bne	L9
	pea	L38
	jsr	_verror
	addq.l	#4,a7
L9
	fmove.s	d6,fp7
	fsub.s	$8(a5),fp7
	ftst.x	fp7
	fbne.w	L10
	pea	L39
	jsr	_verror
	addq.l	#4,a7
L10
	fmove.s	d4,fp7
	fsub.s	d5,fp7
	ftst.x	fp7
	fbne.w	L11
	pea	L40
	jsr	_verror
	addq.l	#4,a7
L11
	fmove.s	d3,fp7
	fsub.s	d2,fp7
	ftst.x	fp7
	fbne.w	L12
	pea	L41
	jsr	_verror
	addq.l	#4,a7
L12
	pea	-$40(a5)
	jsr	_identmatrix
	addq.l	#4,a7
	fmove.s	d2,fp7
	fmul.d	#$.40000000.00000000,fp7
	fmove.s	d6,fp6
	fsub.s	$8(a5),fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	moveq	#0,d7
	fmove.s	fp7,0(a3,d7.l*4)
	fmove.s	d2,fp7
	fmul.d	#$.40000000.00000000,fp7
	fmove.s	d4,fp6
	fsub.s	d5,fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$10(a3),a3
	moveq	#1,d7
	fmove.s	fp7,0(a3,d7.l*4)
	fmove.s	d6,fp7
	fadd.s	$8(a5),fp7
	fmove.s	d6,fp6
	fsub.s	$8(a5),fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$20(a3),a3
	moveq	#0,d7
	fmove.s	fp7,0(a3,d7.l*4)
	fmove.s	d4,fp7
	fadd.s	d5,fp7
	fmove.s	d4,fp6
	fsub.s	d5,fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$20(a3),a3
	moveq	#1,d7
	fmove.s	fp7,0(a3,d7.l*4)
	fmove.s	d3,fp7
	fadd.s	d2,fp7
	fneg.x	fp7
	fmove.s	d3,fp6
	fsub.s	d2,fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$20(a3),a3
	moveq	#2,d7
	fmove.s	fp7,0(a3,d7.l*4)
	lea	-$40(a5),a3
	lea	$20(a3),a3
	moveq	#3,d7
	move.l	#$BF800000,0(a3,d7.l*4)
	fmove.s	d3,fp7
	fmul.d	#$.C0000000.00000000,fp7
	fmove.s	d2,fp6
	fmul.x	fp6,fp7
	fmove.s	d3,fp6
	fsub.s	d2,fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$30(a3),a3
	moveq	#2,d7
	fmove.s	fp7,0(a3,d7.l*4)
	lea	-$40(a5),a3
	lea	$30(a3),a3
	moveq	#3,d7
	clr.l	0(a3,d7.l*4)
	pea	-$40(a5)
	jsr	_loadmatrix
	addq.l	#4,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L37
	unlk	a5
	rts

	XDEF	_ortho
_ortho
L42	EQU	-$74
	link	a5,#L42+52
L43	EQU	$8FC
	movem.l	#L43,-(a7)
	fmovem.x fp6/fp7,-(a7)
	move.s	$1C(a5),d2
	move.s	$18(a5),d3
	move.s	$14(a5),d4
	move.s	$10(a5),d5
	move.s	$C(a5),d6
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L22
	tst.b	_vdevice
	bne	L13
	pea	L44
	jsr	_verror
	addq.l	#4,a7
L13
	fmove.s	d6,fp7
	fsub.s	$8(a5),fp7
	ftst.x	fp7
	fbne.w	L14
	pea	L45
	jsr	_verror
	addq.l	#4,a7
L14
	fmove.s	d4,fp7
	fsub.s	d5,fp7
	ftst.x	fp7
	fbne.w	L15
	pea	L46
	jsr	_verror
	addq.l	#4,a7
L15
	fmove.s	d2,fp7
	fsub.s	d3,fp7
	ftst.x	fp7
	fbne.w	L16
	pea	L47
	jsr	_verror
	addq.l	#4,a7
L16
	pea	-$40(a5)
	jsr	_identmatrix
	addq.l	#4,a7
	fmove.s	d6,fp7
	fsub.s	$8(a5),fp7
	fmove.d	#$.40000000.00000000,fp6
	fdiv.x	fp7,fp6
	lea	-$40(a5),a3
	moveq	#0,d7
	fmove.s	fp6,0(a3,d7.l*4)
	fmove.s	d4,fp7
	fsub.s	d5,fp7
	fmove.d	#$.40000000.00000000,fp6
	fdiv.x	fp7,fp6
	lea	-$40(a5),a3
	lea	$10(a3),a3
	moveq	#1,d7
	fmove.s	fp6,0(a3,d7.l*4)
	fmove.s	d2,fp7
	fsub.s	d3,fp7
	fmove.d	#$.C0000000.00000000,fp6
	fdiv.x	fp7,fp6
	lea	-$40(a5),a3
	lea	$20(a3),a3
	moveq	#2,d7
	fmove.s	fp6,0(a3,d7.l*4)
	fmove.s	d6,fp7
	fadd.s	$8(a5),fp7
	fneg.x	fp7
	fmove.s	d6,fp6
	fsub.s	$8(a5),fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$30(a3),a3
	moveq	#0,d7
	fmove.s	fp7,0(a3,d7.l*4)
	fmove.s	d4,fp7
	fadd.s	d5,fp7
	fneg.x	fp7
	fmove.s	d4,fp6
	fsub.s	d5,fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$30(a3),a3
	moveq	#1,d7
	fmove.s	fp7,0(a3,d7.l*4)
	fmove.s	d2,fp7
	fadd.s	d3,fp7
	fneg.x	fp7
	fmove.s	d2,fp6
	fsub.s	d3,fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$30(a3),a3
	moveq	#2,d7
	fmove.s	fp7,0(a3,d7.l*4)
	pea	-$40(a5)
	jsr	_loadmatrix
	addq.l	#4,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L43
	unlk	a5
	rts

	XDEF	_ortho2
_ortho2
L48	EQU	-$70
	link	a5,#L48+48
L49	EQU	$8BC
	movem.l	#L49,-(a7)
	fmovem.x fp6/fp7,-(a7)
	move.s	$14(a5),d2
	move.s	$10(a5),d3
	move.s	$C(a5),d4
	move.s	$8(a5),d5
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L22
	tst.b	_vdevice
	bne	L17
	pea	L50
	jsr	_verror
	addq.l	#4,a7
L17
	pea	-$40(a5)
	jsr	_identmatrix
	addq.l	#4,a7
	fmove.s	d4,fp7
	fsub.s	d5,fp7
	ftst.x	fp7
	fbne.w	L18
	pea	L51
	jsr	_verror
	addq.l	#4,a7
L18
	fmove.s	d2,fp7
	fsub.s	d3,fp7
	ftst.x	fp7
	fbne.w	L19
	pea	L52
	jsr	_verror
	addq.l	#4,a7
L19
	fmove.s	d4,fp7
	fsub.s	d5,fp7
	fmove.d	#$.40000000.00000000,fp6
	fdiv.x	fp7,fp6
	lea	-$40(a5),a3
	moveq	#0,d7
	fmove.s	fp6,0(a3,d7.l*4)
	fmove.s	d2,fp7
	fsub.s	d3,fp7
	fmove.d	#$.40000000.00000000,fp6
	fdiv.x	fp7,fp6
	lea	-$40(a5),a3
	lea	$10(a3),a3
	moveq	#1,d7
	fmove.s	fp6,0(a3,d7.l*4)
	lea	-$40(a5),a3
	lea	$20(a3),a3
	moveq	#2,d7
	move.l	#$BF800000,0(a3,d7.l*4)
	fmove.s	d4,fp7
	fadd.s	d5,fp7
	fneg.x	fp7
	fmove.s	d4,fp6
	fsub.s	d5,fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$30(a3),a3
	moveq	#0,d7
	fmove.s	fp7,0(a3,d7.l*4)
	fmove.s	d2,fp7
	fadd.s	d3,fp7
	fneg.x	fp7
	fmove.s	d2,fp6
	fsub.s	d3,fp6
	fdiv.x	fp6,fp7
	lea	-$40(a5),a3
	lea	$30(a3),a3
	moveq	#1,d7
	fmove.s	fp7,0(a3,d7.l*4)
	pea	-$40(a5)
	jsr	_loadmatrix
	addq.l	#4,a7
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L49
	unlk	a5
	rts

L22
	XREF	userbreak
	jsr	userbreak

L28
	dc.b	'lookat: vogl not initialised',0
L52
	dc.b	'ortho2: bottom clipping plane same as top one.',0
L51
	dc.b	'ortho2: left clipping plane same as right one.',0
L50
	dc.b	'ortho2: vogl not initialised',0
L46
	dc.b	'ortho: bottom clipping plane same as top one.',0
L45
	dc.b	'ortho: left clipping plane same as right one.',0
L47
	dc.b	'ortho: near clipping plane same as far one.',0
L44
	dc.b	'ortho: vogl not initialised',0
L35
	dc.b	'perspective: bad field of view passed.',0
L32
	dc.b	'perspective: can',$27,'t have zero aspect ratio!',0
L33
	dc.b	'perspective: near clipping plane same as far one.',0
L31
	dc.b	'perspective: vogl not initialised',0
L23
	dc.b	'polarview: vogl not initialised',0
L40
	dc.b	'window: bottom clipping plane same as top one.',0
L39
	dc.b	'window: left clipping plane same as right one.',0
L41
	dc.b	'window: near clipping plane same as far one.',0
L38
	dc.b	'window: vogl not initialised',0

	SECTION ":0",CODE


L22
	jsr	userbreak

	END

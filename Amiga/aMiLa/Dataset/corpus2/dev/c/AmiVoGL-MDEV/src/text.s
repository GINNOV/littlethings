
; Maxon C++ Compiler
; LS2:work/voGL/src/text.c
	mc68020
	mc68881
	XREF	_newtokens
	XREF	_move
	XREF	_VtoWxy
	XREF	_verror
	XREF	_strlen
	XREF	_strcpy
	XREF	_std__in
	XREF	_std__out
	XREF	_std__err
	XREF	___MEMFLAGS
	XREF	_vdevice

	SECTION ":0",CODE


	XDEF	_font
_font
L21	EQU	$10
L22	EQU	$C84
	movem.l	d2/d7/a2/a3,-(a7)
	move.w	L21+4(a7),d2
	XREF	userbreak_flagpos
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L23
	tst.b	_vdevice
	bne	L1
	pea	L24
	jsr	_verror
	addq.l	#4,a7
L1
	cmp.w	#0,d2
	blt	L25
	ext.l	d2
	cmp.l	_vdevice+$16E,d2
	blt	L2
L25
	pea	L26
	jsr	_verror
	addq.l	#4,a7
L2
	tst.b	_vdevice+2
	beq	L3
	pea	2.w
	jsr	_newtokens
	addq.l	#4,a7
	move.l	d0,a2
	move.l	a2,a3
	moveq	#0,d7
	move.l	#$C,0(a3,d7.l*4)
	ext.l	d2
	move.l	a2,a3
	moveq	#1,d7
	move.l	d2,0(a3,d7.l*4)
	movem.l	(a7)+,d2/d7/a2/a3
	rts
L3
	cmp.w	#1,d2
	bne	L5
	move.l	_vdevice+$B0,a3
	move.l	_vdevice+$88,-(a7)
	jsr	(a3)
	addq.l	#4,a7
	tst.l	d0
	bne	L4
	pea	L27
	jsr	_verror
	addq.l	#4,a7
L4
	bra.b	L8
L5
	tst.w	d2
	bne	L7
	move.l	_vdevice+$B0,a3
	move.l	_vdevice+$8C,-(a7)
	jsr	(a3)
	addq.l	#4,a7
	tst.l	d0
	bne	L6
	pea	L28
	jsr	_verror
	addq.l	#4,a7
L6
L7
L8
	ext.l	d2
	move.l	_vdevice+$18,a3
	move.l	d2,$E(a3)
	movem.l	(a7)+,d2/d7/a2/a3
	rts

_getcharwidth__r
L29	EQU	-$1C
	link	a5,#L29+12
L30	EQU	0
	fmovem.x fp7,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L23
	pea	-$10(a5)
	pea	-$C(a5)
	move.l	_vdevice+$20,-(a7)
	move.l	_vdevice+$24,-(a7)
	jsr	_VtoWxy
	lea	$10(a7),a7
	pea	-$8(a5)
	pea	-4(a5)
	clr.l	-(a7)
	clr.l	-(a7)
	jsr	_VtoWxy
	lea	$10(a7),a7
	fmove.s	-$C(a5),fp7
	fsub.s	-4(a5),fp7
	fmove.s	fp7,-$C(a5)
	fmove.s	-$C(a5),fp0
	fmovem.x (a7)+,fp7
	unlk	a5
	rts

	XDEF	_charstr
_charstr
L31	EQU	-$5A
	link	a5,#L31+48
L32	EQU	$4CFC
	movem.l	d2-d7/a2/a3/a6,-(a7)
	fmovem.x fp7,-(a7)
	move.l	$8(a5),a2
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L23
	move.b	_vdevice+1,d7
	extb.l	d7
	move.l	d7,-$16(a5)
	move.l	a2,-(a7)
	jsr	_strlen
	addq.l	#4,a7
	move.l	d0,-$1A(a5)
	tst.b	_vdevice
	bne	L9
	pea	L33
	jsr	_verror
	addq.l	#4,a7
L9
	tst.b	_vdevice+2
	beq	L10
	move.l	a2,-(a7)
	jsr	_strlen
	addq.l	#4,a7
	lsr.l	#2,d0
	addq.l	#2,d0
	move.l	d0,-(a7)
	jsr	_newtokens
	addq.l	#4,a7
	move.l	d0,a6
	move.l	a6,a3
	moveq	#0,d7
	move.l	#$A,0(a3,d7.l*4)
	move.l	a2,-(a7)
	move.l	a6,a3
	addq.l	#4,a3
	move.l	a3,-(a7)
	jsr	_strcpy
	addq.l	#$8,a7
	fmovem.x (a7)+,fp7
	movem.l	(a7)+,d2-d7/a2/a3/a6
	unlk	a5
	rts
L10
	move.l	#_vdevice+$28,a3
	moveq	#0,d7
	move.l	0(a3,d7.l*4),-4(a5)
	move.l	#_vdevice+$28,a3
	moveq	#1,d7
	move.l	0(a3,d7.l*4),-$8(a5)
	move.l	#_vdevice+$28,a3
	moveq	#2,d7
	move.l	0(a3,d7.l*4),-$C(a5)
	move.b	#1,_vdevice+1
	move.l	_c_z,-(a7)
	move.l	_c_y,-(a7)
	move.l	_c_x,-(a7)
	jsr	_move
	lea	$C(a7),a7
	tst.l	-$16(a5)
	beq	L11
	move.l	_vdevice+$C8,a3
	move.l	a2,-(a7)
	jsr	(a3)
	addq.l	#4,a7
	bra	L17
L11
	move.l	_vdevice+$7C,d4
	fmove.s	_vdevice+$20,fp7
	fmove.l	fp7,d7
	move.l	_vdevice+$80,d6
	sub.l	d7,d6
	move.l	d6,d3
	fmove.s	_vdevice+$20,fp7
	fmove.l	fp7,d7
	move.l	d3,d6
	add.l	d7,d6
	move.l	d6,-$26(a5)
	move.l	-$1A(a5),d7
	addq.l	#1,d7
	fmove.l	d7,fp7
	fmul.s	_vdevice+$24,fp7
	fmove.l	fp7,d7
	move.l	d4,d6
	add.l	d7,d6
	move.l	d6,-$2A(a5)
	cmp.l	_vdevice+$60,d4
	ble	L12
	cmp.l	_vdevice+$64,d3
	bge	L12
	move.l	-$26(a5),d7
	cmp.l	_vdevice+$68,d7
	ble	L12
	move.l	-$2A(a5),d7
	cmp.l	_vdevice+$5C,d7
	bge	L12
	move.l	_vdevice+$C8,a3
	move.l	a2,-(a7)
	jsr	(a3)
	addq.l	#4,a7
	bra	L16
L12
	bra.b	L14
L13
	move.l	_vdevice+$7C,d7
	cmp.l	_vdevice+$60,d7
	ble	L15
	move.l	_vdevice+$7C,d7
	fmove.s	_vdevice+$24,fp7
	fmove.l	fp7,d6
	move.l	_vdevice+$5C,d5
	sub.l	d6,d5
	cmp.l	d5,d7
	bge	L15
	move.l	_vdevice+$94,a3
	move.b	d2,-(a7)
	jsr	(a3)
	addq.l	#2,a7
L15
	fmove.s	_vdevice+$24,fp7
	fmove.l	fp7,d7
	add.l	d7,_vdevice+$7C
L14
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L23
	move.b	(a2)+,d2
	bne.b	L13
L16
L17
	bsr	_getcharwidth__r
	fmove.l	-$1A(a5),fp7
	fmul.x	fp7,fp0
	fmove.s	_c_x,fp7
	fadd.x	fp0,fp7
	fmove.s	fp7,_c_x
	move.l	-$C(a5),-(a7)
	move.l	-$8(a5),-(a7)
	move.l	-4(a5),-(a7)
	jsr	_move
	lea	$C(a7),a7
	move.l	-$16(a5),d7
	move.b	d7,_vdevice+1
	fmovem.x (a7)+,fp7
	movem.l	(a7)+,d2-d7/a2/a3/a6
	unlk	a5
	rts

	XDEF	_cmov
_cmov
L34	EQU	$18
L35	EQU	$C9C
	movem.l	d2-d4/d7/a2/a3,-(a7)
	move.s	L34+$C(a7),d2
	move.s	L34+$8(a7),d3
	move.s	L34+4(a7),d4
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L23
	tst.b	_vdevice+2
	beq	L18
	pea	4.w
	jsr	_newtokens
	addq.l	#4,a7
	move.l	d0,a2
	move.l	a2,a3
	moveq	#0,d7
	move.l	#$2D,0(a3,d7.l*4)
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
	movem.l	(a7)+,#L35
	rts
L18
	move.l	d4,_c_x
	move.l	d3,_c_y
	move.l	d2,_c_z
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L35
	rts

	XDEF	_cmov2
_cmov2
L36	EQU	0
L37	EQU	0
	movem.l	#L37,-(a7)
	move.l	L36+4(a7),_c_x
	move.l	L36+$8(a7),_c_y
	clr.l	_c_z
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L37
	rts

	XDEF	_cmovi
_cmovi
L38	EQU	$C
L39	EQU	0
	movem.l	#L39,-(a7)
	fmovem.x fp7,-(a7)
	fmove.l	L38+4(a7),fp7
	fmove.s	fp7,_c_x
	fmove.l	L38+$8(a7),fp7
	fmove.s	fp7,_c_y
	fmove.l	L38+$C(a7),fp7
	fmove.s	fp7,_c_z
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L39
	rts

	XDEF	_cmovs
_cmovs
L40	EQU	$C
L41	EQU	0
	movem.l	#L41,-(a7)
	fmovem.x fp7,-(a7)
	move.w	L40+4(a7),d0
	ext.l	d0
	fmove.l	d0,fp7
	fmove.s	fp7,_c_x
	move.w	L40+6(a7),d0
	ext.l	d0
	fmove.l	d0,fp7
	fmove.s	fp7,_c_y
	move.w	L40+$8(a7),d0
	ext.l	d0
	fmove.l	d0,fp7
	fmove.s	fp7,_c_z
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L41
	rts

	XDEF	_cmov2i
_cmov2i
L42	EQU	$C
L43	EQU	0
	movem.l	#L43,-(a7)
	fmovem.x fp7,-(a7)
	fmove.l	L42+4(a7),fp7
	fmove.s	fp7,_c_x
	fmove.l	L42+$8(a7),fp7
	fmove.s	fp7,_c_y
	clr.l	_c_z
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L43
	rts

	XDEF	_cmov2s
_cmov2s
L44	EQU	$C
L45	EQU	0
	movem.l	#L45,-(a7)
	fmovem.x fp7,-(a7)
	move.w	L44+4(a7),d0
	ext.l	d0
	fmove.l	d0,fp7
	fmove.s	fp7,_c_x
	move.w	L44+6(a7),d0
	ext.l	d0
	fmove.l	d0,fp7
	fmove.s	fp7,_c_y
	clr.l	_c_z
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L45
	rts

	XDEF	_getwidth
_getwidth
L46	EQU	0
L47	EQU	0
	movem.l	#L47,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L23
	tst.b	_vdevice
	bne	L19
	pea	L48
	jsr	_verror
	addq.l	#4,a7
L19
	fmove.s	_vdevice+$24,fp0
	fmove.l	fp0,d0
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L47
	rts

	XDEF	_getheight
_getheight
L49	EQU	0
L50	EQU	0
	movem.l	#L50,-(a7)
	move.l	userbreak_flagpos,a1
	btst	#4,(a1)
	bne	L23
	tst.b	_vdevice
	bne	L20
	pea	L51
	jsr	_verror
	addq.l	#4,a7
L20
	fmove.s	_vdevice+$20,fp0
	fmove.l	fp0,d0
	fmovem.x (a7)+,[LATEST]
	movem.l	(a7)+,#L50
	rts

L23
	XREF	userbreak
	jsr	userbreak

L33
	dc.b	'charstr: vogl not initialized',0
L26
	dc.b	'font: font number is out of range',0
L27
	dc.b	'font: unable to open large font',0
L28
	dc.b	'font: unable to open small font',0
L24
	dc.b	'font: vogl not initialised',0
L51
	dc.b	'getheight: vogl not initialized',0
L48
	dc.b	'getwidth: vogl not initialised',0

	SECTION ":2",BSS

_c_x
	ds.l	1
_c_y
	ds.l	1
_c_z
	ds.l	1

	SECTION ":0",CODE


L23
	jsr	userbreak

	END

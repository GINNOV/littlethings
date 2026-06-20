;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
	incdir	includes:

	include	lvos.i
	include	lvo/mrq_lib.i
	include	exec/exec.i
	include	graphics/gfx.i
	include	graphics/modeid.i
	include	intuition/intuition.i


	section	code,code_p

szer=640
wys=480
x_offs=0
y_offs=0


	move.l	4,a6
	moveq	#$00,d0
	lea	mrqlib,a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,mrqbase
	tst.l	d0
	beq.w	_stupid_error

	move.l	mrqbase,a6
	jsr	_LVOMisterQInit(a6)	;inicjalizacja biblioteki, struktur

	tst.l	d0
	beq.w	_eext

	move.l	d0,lib_base
	move.l	lib_base,a5
;-------

	move.l	#szer,d0
	move.l	#wys,d1
;	move.l	#HIRESLACE_KEY+PAL_MONITOR_ID,d2
	move.l	#$00,d2

	lea	paleta,a0
	jsr	_LVOMOpenScreen(a6)
	tst.l	d0
	beq.w	_cs_sc
	move.l	d0,screenbase

	move.l	d0,a0
	move.l	s_Win_Base(a0),a0
	move.l	wd_UserPort(a0),a0
	move.l	a0,userport

	fmove.x	mxa,fp0
	fsub.x	mna,fp0
	fdiv.x	mxx,fp0
	fmove.x	fp0,kroka

	fmove.x	mxb,fp0
	fsub.x	mnb,fp0
	fdiv.x	mxy,fp0
	fmove.x	fp0,krokb

;a=fp0 b=fp1
;x=fp2 y=fp3

	fmove.x	mnb,fp0
	move.l	#0,d7
nexti	fmove.x	mna,fp1
	move.l	#0,d6
nextj	
	fmove.x	#0,fp2
	fmove.x	#0,fp3

	move.l	#0,d2
nextq	

	fmove.x	fp2,fp4
	fmul.x	fp4,fp4
	fmove.x	fp4,fp6

	fmove.x	fp3,fp5
	fmul.x	fp5,fp5
	fmove.x	fp5,fp7
	fsub.x	fp5,fp4
	fadd.x	fp1,fp4

	fmove.x	fp3,fp5
	fmul.x	fp2,fp5
	fadd.x	fp5,fp5
	fadd.x	fp0,fp5
	fmove.x	fp5,fp3

	fmove.x	fp4,fp2

	fadd.x	fp7,fp6

	fcmp.x	#4,fp6
	fbgt	break

	add.l	#1,d2
	cmp.l	ile,d2
	bne.b	nextq
	move.l	#0,d2
break
	move.l	d6,d0
	move.l	d7,d1
	asl.b	#2,d2

	bsr.w	plot

	movem.l	d0/a0,-(sp)

	move.l	userport,a0
	jsr	_LVOGetDynamicMessage(a6)
	move.l	d0,a0
	move.l	im_Class(a0),d0
	cmp.l	#IDCMP_RAWKEY,d0
	beq.b	_key1
	bra.b	_czekaj1
_key1	
	move.w	im_Code(a0),d0
	and.l	#$000000ff,d0
	cmp.b	#95,d0
	bne.b	_czekaj1

	movem.l	(sp)+,d0/a0
	bra.b	manend

_czekaj1
	movem.l	(sp)+,d0/a0

	fadd.x	kroka,fp1

	addq.l	#1,d6
	cmp.l	#szer,d6
	bne.w	nextj

	fadd.x	krokb,fp0

	addq.l	#1,d7
	cmp.l	#wys,d7
	bne.w	nexti

_czekaj2
	move.l	userport,a0
	jsr	_LVOGetMessage(a6)
	move.l	d0,a0
	move.l	im_Class(a0),d0
	cmp.l	#IDCMP_RAWKEY,d0
	beq.b	_key2
	bra.b	_czekaj2
_key2	move.w	im_Code(a0),d0
	and.l	#$000000ff,d0
	cmp.b	#95,d0
	bne.b	_czekaj2
manend


_cs_sc	move.l	screenbase,a0
	jsr	_LVOMCloseScreen(a6)

_ext	move.l	lib_base,a0
	jsr	_LVOMisterQCleanUp(a6)
_eext	move.l	4,a6
	move.l	mrqbase,a1
	jsr	_LVOCloseLibrary(a6)
	rts
;-------
get	

	movem.l	d1-a6,-(sp)

petla	move.l	a0,-(sp)
	move.l	gadbase(a5),a6
	jsr	_LVOGT_GetIMsg(a6)
	move.l	(sp)+,a0
	tst.l	d0		
	bne.b	jest
	moveq	#$00,d0
	bra.b	jest2
jest	move.l	d0,a1
	movem.l	d0/a0,-(sp)
	move.l	gadbase(a5),a6
	jsr	_LVOGT_ReplyIMsg(a6)
	movem.l	(sp)+,d0/a0
jest2
	movem.l	(sp)+,d1-a6

	rts
;-------
plot	
	movem.l	d1-a6,-(sp)
	move.l	gfxbase(a5),a6
	move.l	s_RastPort(a5),a1
	movem.l	d0/d1,-(sp)
	move.l	d2,d0
	jsr	_LVOSetAPen(a6)
	movem.l	(sp)+,d0/d1
	jsr	_LVOWritePixel(a6)	
	movem.l	(sp)+,d1-a6
	rts
;-------
_stupid_error
	moveq	#$00,d0
	rts
;-------
userport	dc.l	$00
ile		dc.l	700
mna		dc.x	-0.76649008
mxa		dc.x	-0.76646719
mnb		dc.x	0.09993625
mxb		dc.x	0.09992023
mxx		dc.x	640
mxy		dc.x	480
kroka		dc.x	0
krokb		dc.x	0
;-------
mrqbase		dc.l	$00
lib_base	dc.l	$00
screenbase	dc.l	$00
;-------
mrqlib		dc.b	'mrq.library',0
paleta		incbin	gfx:widok_640\512.rgb32
;-------


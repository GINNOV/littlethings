	incdir	asm:
	include	exec/execbase.i
	include	math.i
	include	phxmacros.i

	mc68040

	xref	_SysBase
	xref	_exit

	EXTERN_LIB	AllocVec
	EXTERN_LIB	FreeVec

	section	sincos,code

;Init table with polynomial coefficients

	xdef	_INIT_1_FastSincos
_INIT_1_FastSincos
	move.l	_SysBase,a6
	move.w	AttnFlags(a6),d0
	btst	#AFB_68040,d0
	beq	.ret
	move.l	#360*30*8*3,d0
	moveq	#0,d1
	callsys	AllocVec
	move.l	d0,sintab
	beq	.exit
	move.l	#360*30*8*3,d0
	moveq	#0,d1
	callsys	AllocVec
	move.l	d0,costab
	beq	.exit
	fmove.d	#PI180,fp0
	fmul.d	#1.0/30.0,fp0
	fmove.d	fp0,#PI180/30.0
	fmove.s	#30,fp0
	fmul.d	#1.0/PI180,fp0
	fmove.d	fp0,#30.0/PI180
	moveq	#0,d0
	move.l	sintab,a0
	move.l	costab,a1

.loop
	fmove.w	d0,fp0
	fmul.d	#PI180/30.0,fp0
	move.w	d0,d1
	beq	.loopeq0
	fmove.x	fp6,fp4
	fmove.x	fp7,fp5
	bra	.cont

.loopeq0
	fmove.s	#1,fp4
	fmove.s	#0,fp5

.cont
	inc.w	d1
	fmove.w	d1,fp1
	fmul.d	#PI180/30.0,fp1
	fsincos.x	fp1,fp6:fp7
	fmove.x	fp6,fp3
	fsub.x	fp4,fp3
	fmul.s	#0.5,fp3 
	fmul.d	#30.0/PI180,fp3
	move.w	d0,d1
	neg.w	d1
	add.w	d1,d1
	dec.w	d1
	fmove.w	d1,fp2
	fmul.d	#PI180/30.0,fp2
	fmul.d	#PI180/30.0,fp2 
	fmul.x	fp3,fp2
	fadd.x	fp7,fp2
	fsub.x	fp5,fp2
	fmul.d	#30.0/PI180,fp2
	fmove.x	fp3,fp1
	fmul.x	fp0,fp1
	fadd.x	fp2,fp1
	fmul.x	fp0,fp1
	fneg.x	fp1
	fadd.x	fp5,fp1
	fmove.d	fp3,(a0)+
	fmove.d	fp2,(a0)+
	fmove.d	fp1,(a0)+
	fmove.x	fp5,fp3
	fsub.x	fp7,fp3
	fmul.s	#0.5,fp3
	fmul.d	#30.0/PI180,fp3
	move.w	d0,d1
	neg.w	d1
	add.w	d1,d1
	dec.w	d1
	fmove.w	d1,fp2
	fmul.d	#PI180/30.0,fp2
	fmul.d	#PI180/30.0,fp2
	fmul.x	fp3,fp2
	fadd.x	fp6,fp2
	fsub.x	fp4,fp2
	fmul.d	#30.0/PI180,fp2
	fmove.x	fp3,fp1
	fmul.x	fp0,fp1
	fadd.x	fp2,fp1
	fmul.x	fp0,fp1
	fneg.x	fp1
	fadd.x	fp4,fp1
	fmove.d	fp3,(a1)+
	fmove.d	fp2,(a1)+
	fmove.d	fp1,(a1)+
	inc.w	d0
	cmp.w	#360*30,d0
	blo	.loop

.ret
	rts

.exit
	pea	20
	jsr	_exit

	xdef	_EXIT_1_FastSincos
_EXIT_1_FastSincos
	move.l	sintab,a1
	callsys	FreeVec,SysBase
	move.l	costab,a1
	callsys	FreeVec
	rts

costab
	dc.l	0
sintab
	dc.l	0

	section	fastsin___r_d,code

	xdef	fastsin___r_d
	xdef	_fastsin__r
fastsin___r_d
_fastsin__r
	pushm.l	d0/a0
	fmove.d	12(sp),fp0
	jsr	fastsin
	popm.l	d0/a0
	rts

	section	fastsin,code

	xdef	fastsin
fastsin
	fpush.x	fp1
	ftst.x	fp0
	fblt	.minus
	fcmp.d	#TWOPI,fp0
	fblt	.cont1
	fmul.d	#1.0/TWOPI,fp0	;this frac() is faster than fmod
	fintrz.x	fp0,fp1
	fsub.x	fp1,fp0
	fmul.d	#TWOPI,fp0

.cont1
	fmove.x	fp0,fp1
	fmul.d	#30.0/PI180,fp0
	fintrz.x	fp0
	fmove.l	fp0,d0
	mulu.w	#24,d0
	move.l	sintab,a0
	add.l	d0,a0
	fmove.d	(a0)+,fp0
	fmul.x	fp1,fp0
	fadd.d	(a0)+,fp0	
	fmul.x	fp1,fp0
	fadd.d	(a0),fp0

.ret
	fpop.x	fp1
	rts

.minus
	fabs.x	fp0
	fcmp.d	#TWOPI,fp0
	fblt	.cont2
	fmul.d	#1.0/TWOPI,fp0	;this frac() is faster than fmod
	fintrz.x	fp0,fp1
	fsub.x	fp1,fp0
	fmul.d	#TWOPI,fp0

.cont2
	fmove.x	fp0,fp1
	fmul.d	#30.0/PI180,fp0
	fintrz.x	fp0	;This one is required. Dont skip it !
	fmove.l	fp0,d0

;evaluate value from coefficient table
	mulu.w	#24,d0
	move.l	sintab,a0
	add.l	d0,a0
	fmove.d	(a0)+,fp0
	fmul.x	fp1,fp0
	fadd.d	(a0)+,fp0	
	fmul.x	fp1,fp0
	fadd.d	(a0),fp0
	fneg.x	fp0
	fpop.x	fp1
	rts

	section	fastcos___r_d,code

	xdef	fastcos___r_d
	xdef	_fastcos__r
fastcos___r_d
_fastcos__r
	pushm.l	d0/a0
	fmove.d	12(sp),fp0
	jsr	fastcos
	popm.l	d0/a0
	rts

	section	fastcos,code

	xdef	fastcos
fastcos
	fpush.x	fp1
	fabs.x	fp0
	fcmp.d	#TWOPI,fp0
	fblt	.cont

;replaces fmod on a 040/060
	fmul.d	#1.0/TWOPI,fp0
	fintrz.x	fp0,fp1
	fsub.x	fp1,fp0
	fmul.d	#TWOPI,fp0

.cont
	fmove.x	fp0,fp1
	fmul.d	#30.0/PI180,fp0
	fintrz.x	fp0	;This one is required. Dont skip it !
	fmove.l	fp0,d0

;evaluate value from coefficient table
	mulu.w	#24,d0
	move.l	costab,a0
	add.l	d0,a0
	fmove.d	(a0)+,fp0
	fmul.x	fp1,fp0
	fadd.d	(a0)+,fp0
	fmul.x	fp1,fp0
	fadd.d	(a0),fp0

.ret
	fpop.x	fp1
	rts

	section	fastsincos__dRdRd,code

	xdef	fastsincos__dRdRd
fastsincos__dRdRd
	fabs.d	4(sp),fp0
	fcmp.d	#TWOPI,fp0
	fblt	.conts1
	fmul.d	#1.0/TWOPI,fp0
	fintrz.x	fp0,fp1
	fsub.x	fp1,fp0
	fmul.d	#TWOPI,fp0

.conts1
	fmove.x	fp0,fp1
	fmul.d	#30.0/PI180,fp0
	fintrz.x	fp0
	fmove.l	fp0,d0
	mulu.w	#24,d0
	move.l	sintab,a0
	add.l	d0,a0
	fmove.d	(a0)+,fp0
	fmul.x	fp1,fp0
	fadd.d	(a0)+,fp0	
	fmul.x	fp1,fp0
	fadd.d	(a0),fp0
	tst.l	4(sp)
	bpl	.conts2
	fneg.x	fp0
	
.conts2
	move.l	12(sp),a0
	fmove.d	fp0,(a0)

	move.l	costab,a0
	add.l	d0,a0
	fmove.d	(a0)+,fp0
	fmul.x	fp1,fp0
	fadd.d	(a0)+,fp0	
	fmul.x	fp1,fp0
	fadd.d	(a0),fp0
	move.l	16(sp),a0
	fmove.d	fp0,(a0)
	rts


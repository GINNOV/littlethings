	incdir	asm:
	include	exec/execbase.i
	include	math.i
	include	phxmacros.i

	xref	fastacos___r_d
	xref	fastacos

;w=atan(y/x)=fastacos(x/sqrt(x*x+y*y))

	xdef	fastatan2___r_dd
	xdef	_fastatan2__r
fastatan2___r_dd
_fastatan2__r
	fmove.d	4(sp),fp0
	fmove.d	12(sp),fp1
	fbeq	.xnull
	fmul.x	fp0,fp0
	fmul.x	fp1,fp1
	fadd.x	fp0,fp1
	fsqrt.x	fp1
	fmove.d	12(sp),fp0
	fdiv.x	fp1,fp0
	fmove.d	fp0,-(sp)
	jsr	fastacos___r_d
	add.w	#8,sp
	bra	.cont

.xnull
	ftst.x	fp0
	fbeq	.ynull
	fmove.d	#PI2,fp0

.cont
	tst.l	4(sp)	;faster than ftst.d
	bpl	.ret
	fneg.x	fp0

.ret
	rts

.ynull
	fmove.s	#0,fp0
	rts

	xdef	fastatan2
fastatan2
	fmove.d	4(sp),fp0
	fmove.d	12(sp),fp1
	fbeq	.xnull
	fmul.x	fp0,fp0
	fmul.x	fp1,fp1
	fadd.x	fp0,fp1
	fsqrt.x	fp1
	fmove.d	12(sp),fp0
	fdiv.x	fp1,fp0
	jsr	fastacos
	bra	.cont

.xnull
	ftst.x	fp0
	fbeq	.ynull
	fmove.d	#PI2,fp0

.cont
	tst.l	4(sp)	;faster than ftst.d
	bpl	.ret
	fneg.x	fp0

.ret
	rts

.ynull
	fmove.s	#0,fp0
	rts

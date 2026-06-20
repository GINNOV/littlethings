	incdir	asm:
	include	exec/execbase.i
	include	math.i
	include	phxmacros.i

	mc68040

	xref	_SysBase
	xref	_exit

	EXTERN_LIB	AllocVec
	EXTERN_LIB	FreeVec

dacos
	fcmp.d	#1,fp0
	fbne	.cont
	fmove.d	#-1e5,fp0
	rts

.cont
	fmove.d	#1,fp1
	fmul.x	fp0,fp0
	fsub.x	fp0,fp1
	fsqrt.x	fp1
	fmove.d	#-1,fp0
	fdiv.x	fp1,fp0
	rts

	xdef	_INIT_1_FastACos
_INIT_1_FastACos
	move.l	_SysBase,a6
	move.w	AttnFlags(a6),d0
	btst	#AFB_68040,d0
	beq	.ret
	move.l	#24*9999,d0
	moveq	#0,d1
	callsys	AllocVec
	move.l	d0,acostab
	beq	.exit
	move.l	d0,a0

	moveq	#0,d0
	moveq	#1,d1

.loop
	fmove.w	d0,fp2
	fmul.d	#1e-4,fp2
	fmove.w	d1,fp3
	fmul.d	#1e-4,fp3
	fmove.x	fp2,fp4
	facos.x	fp4 ;y

;p->a=(dacos(x1)-dacos(x))*20000;
	fmove.x	fp3,fp0
	bsr	dacos
	fmove.x	fp0,fp5
	fmove.x	fp2,fp0
	bsr	dacos
	fsub.x	fp0,fp5
	fmul.d	#20000,fp5
	fmove.d	fp5,(a0)+

;p->b=(acos(x1)-y)*10000-p->a*(2*x+1e-4);
	facos.x	fp3
	fsub.x	fp4,fp3
	fmul.d	#10000,fp3
	fmove.x	fp2,fp0
	fadd.x	fp0,fp0
	fadd.d	#1e-4,fp0
	fmul.x	fp5,fp0
	fsub.x	fp0,fp3
	fmove.d	fp3,(a0)+

;p->c=y-(p->a*x+p->b)*x;
	fmul.x	fp2,fp5
	fadd.x	fp3,fp5
	fmul.x	fp2,fp5
	fsub.x	fp5,fp4
	fmove.d	fp4,(a0)+
	inc.w	d1
	inc.w	d0
	cmp.w	#9999,d0
	blo	.loop

.ret
	rts

.exit
	pea	20
	jsr	_exit

	xdef	_EXIT_1_FastACos
_EXIT_1_FastACos
	move.l	acostab,a1
	callsys	FreeVec,SysBase
	rts

acostab
	dc.l	0

	xdef	fastacos___r_d
	xdef	_fastacos__r
fastacos___r_d
_fastacos__r
	pushm.l	d0/a0
	fmove.d	12(sp),fp0
	bsr	fastacos
	popm.l	d0/a0
	rts

	xdef	fastacos
fastacos
	fpush.x	fp1
	fpush.x	fp0
	fabs.x	fp0
	fcmp.d	#1,fp0
	fble	.cont
	fmove.s	#0,fp0
	bra	.contx

.cont
	fmove.x	fp0,fp1
	fmul.s	#10000,fp0
	fintrz.x	fp0	;This one is required. Dont skip it !
	fmove.w	fp0,d0
	cmp.w	#9999,d0
	blo	.cont1	;Avoid infinity
	fpop.x	fp0
	facos.x	fp0
	fpop.x	fp1
	rts

.cont1
	mulu.w	#24,d0
	move.l	acostab,a0
	add.l	d0,a0
	fmove.d	(a0)+,fp0
	fmul.x	fp1,fp0
	fadd.d	(a0)+,fp0
	fmul.x	fp1,fp0		
	fadd.d	(a0),fp0

.contx
	fpop.x	fp1
	fbge	.cont2
	fneg.x	fp0
	fadd.d	#PI,fp0

.cont2
	fpop.x	fp1
	rts

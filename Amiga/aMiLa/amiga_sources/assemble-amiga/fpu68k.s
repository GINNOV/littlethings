	include	"comequ.s"
	opt	p=68030,p=68882
	XREF	FPUcr,FPUk,FindEqu,GetEvFonc
	XDEF	FPUImm,FpuEval,FpuConv
	section TEXT

;  #[ Priority equs:
;unaires
PLUS_PRI		equ	5
MINUS_PRI		equ	5
NOT_PRI		equ	5
;binaires
ADD_PRI		equ	2
SUB_PRI		equ	2
MUL_PRI		equ	3
DIV_PRI		equ	3
CMP_PRI		equ	1
;  #] Priority equs:
;  #[ Misc Equs:
RVALUE		equr	d3
RPRIO		equr	d6
VAR_TYPE	equr	d7

EVAL_STR	equr	a0
OPERAND_JT	equr	a3
OPERATOR_JT	equr	a4

;  #] Misc Equs:
	
;  #[ Macros:
JSOPERAND	MACRO
	IFNE	_68000
	add.w	d1,d1
	move.w	0(OPERAND_JT,d1.w),d1
	ELSEIF
	move.w	0(OPERAND_JT,d1.w*2),d1
	ENDC	;_68000
	jsr	0(OPERAND_JT,d1.w)
	ENDM

JSOPERATOR	MACRO
	IFNE	_68000
	add.w	d1,d1
	move.w	0(OPERATOR_JT,d1.w),d1
	ELSEIF
	move.w	0(OPERATOR_JT,d1.w*2),d1
	ENDC	;_68000
	jsr	0(OPERATOR_JT,d1.w)
	ENDM

JMOPERAND	MACRO
	IFNE	_68000
	add.w	d1,d1
	move.w	0(OPERAND_JT,d1.w),d1
	ELSEIF
	move.w	0(OPERAND_JT,d1.w*2),d1
	ENDC
	jmp	0(OPERAND_JT,d1.w)
	ENDM

JMOPERATOR	MACRO
	IFNE	_68000
	add.w	d1,d1
	move.w	0(OPERATOR_JT,d1.w),d1
	ELSEIF
	move.w	0(OPERATOR_JT,d1.w*2),d1
	ENDC
	jmp	0(OPERATOR_JT,d1.w)
	ENDM
;  #] Macros:

FPU_VAL_SIZE	equ	4*3

;In: a0=@eval string, a1=@result buffer
;Out: d1=error code
FpuEval:	movem.l	d2-d7/a2-a6,-(sp)
	lea	fpu_operand_jt(pc),OPERAND_JT
	lea	fpu_operator_jt(pc),OPERATOR_JT
	moveq	#0,RPRIO	;pri
	moveq	#0,d1
	move.l	d1,_parnestcnt		;+_foncnestcnt
	move.b	(EVAL_STR)+,d1
	ble.s	.err
	move.l	a1,RVALUE
	JSOPERAND
	bmi.s	.end
	moveq	#0,d1
.end:	movem.l	(sp)+,d2-d7/a2-a6
	rts
.err:	bsr	err_unexp_end
	bra.s	.end

;  #[ FpEval:
;In: RPRIO.w=niveau de priorite,EVAL_STR=@chaine courante
;Out: RVALUE.l=valeur
;Internal: RVALUE=value,SIGN.b=sign
FpEval:	moveq	#0,d1
	move.b	(EVAL_STR)+,d1
	ble.s	.err
	JMOPERAND
.err:	bra	err_unexp_end
;  #] FpEval:
;  #[ Get2ndOp:
get_2nd_op:
	moveq	#0,d1
	move.b	(EVAL_STR)+,d1
	ble.s	_end
	JMOPERATOR
;	 #[ END OF EXPR '\0',-1:
_end:	subq.w	#1,EVAL_STR
	tst.w	_parnestcnt
	bne.s	.errp
	rts
.errp:	clr.w	_parnestcnt
	bra	err_matching
;	 #] END OF EXPR '\0',-1:
;  #] Get2ndOp:

;  #[ PARENTHESIS ')':
close_parent:
	tst.w	RPRIO
	beq.s	.niv0
	subq.w	#1,EVAL_STR	;pas avaler la parenthese
	rts			;et revenir
.niv0:	subq.w	#1,_parnestcnt
	bmi.s	.errp
	rts
.errp:	clr.w	_parnestcnt
	bra	err_unexp_par
;  #] PARENTHESIS ')':
;  #[ virgule: ','
next_arg:	tst.w	_foncnestcnt
	beq	err_illeg_char
	subq.w	#1,EVAL_STR
	rts
;  #] virgule: ','
;  #[ '(':
open_parent:
	addq.w	#1,_parnestcnt
	move.w	RPRIO,-(sp)		;niveau
	moveq	#0,RPRIO
	bsr	FpEval
	bmi.s	.out
	movem.w	(sp)+,RPRIO
	bra	get_2nd_op
.out:	rts
;  #] '(':
;  #[ hex string:
_binary_string:
_hex_string:
	move.l	EVAL_STR,a1
	lea	.hextab(pc),a5
	moveq	#0,d1
.cnt:	move.b	(a1)+,d1
	tst.b	0(a5,d1.w)
	bpl.s	.cnt
	subq.w	#1,a1
	move.l	a1,d5		;suite de l'expr
	move.l	a1,d0
	sub.l	EVAL_STR,d0
	ble.s	.errhex		;pas 1 seul nbre hexa
	cmp.w	#8*3,d0
	bgt.s	.toolong
	move.l	RVALUE,a2
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	moveq	#0,d0

.hexloop:	;1er digit
	moveq	#0,d1
	move.b	-(a1),d0
	move.b	0(a5,d0.w),d1
	cmp.l	EVAL_STR,a1
	bls.s	.hexput

	;2eme digit
	move.b	-(a1),d0
	move.b	0(a5,d0.w),d0
.hexput:	lsl.b	#4,d0
	or.b	d0,d1
	or.b	d1,-(a2)
	cmp.l	EVAL_STR,a1
	bhi.s	.hexloop
	move.l	d5,EVAL_STR
	moveq	#0,d1
	bra	get_2nd_op

.toolong:	moveq	#EVAL_LNUM,d1
	rts
.errhex:	moveq	#EVAL_ILLRADIX,d1
	rts
.hextab:	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	+0,+1,+2,+3,+4,+5,+6,+7,+8,+9,-1,-1,-1,-1,-1,-1
	dc.b	-1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
;  #] hex string:
;  #[ dec string:
_dec_string:
	subq.w	#1,EVAL_STR
	moveq	#2,d0	;extended
	jsr	FPUImm
	bmi.s	.end
	move.l	RVALUE,a2
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1),(a2)
	bra	get_2nd_op
.end:	rts
;  #] dec string:
;  #[ vars & foncs:
fpu_var:	subq.w	#1,EVAL_STR
	bsr	getvarlen
	move.w	d0,d5
	cmp.b	#'(',0(EVAL_STR,d5.w)
	beq.s	.fonc
	jsr	FindEqu
	beq.s	.varnf
	add.w	d5,EVAL_STR
	move.l	d0,a1
	move.l	RVALUE,a2
	move.b	VAR_type(a1),d1
	and.b	#$7f,d1
;	cmp.b	#EQU_EQU,d1
	beq.s	.conv		;EQU_EQU=0
	cmp.b	#EQU_SET,d1
	beq.s	.conv
	cmp.b	#EQU_FEQU,d1
	beq.s	.float
	cmp.b	#EQU_FSET,d1
	bne.s	.errtype
.float:	move.l	VAR_value(a1),a1
	addq.w	#2,a1		;skip size
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1),(a2)
	bra.s	.end
.conv:	tst.b	VAR_sec(a1)
	bpl.s	.errtype
	move.l	VAR_value(a1),d1
	tst.b	VAR_type(a1)
	bpl.s	.plus
	neg.l	d1
.plus:	fmove.l	d1,fp0
	fmove.x	fp0,(a2)
.end:	moveq	#0,d1
	bra	get_2nd_op
.errtype:	bra	err_var_type
.varnf:	bra	err_var_nf
	;d5=size
.fonc:	move.l	EVAL_STR,a1
	move.w	d5,d0
	move.l	a0,-(sp)
	lea	fpu_foncs_tab(pc),a0
	moveq	#FP_FONCS_NB,d1
	bsr	GetEvFonc
	move.l	(sp)+,a0
	tst.l	d0
	beq	err_fonc_nf
	add.w	d5,EVAL_STR
	move.l	d0,a1
	moveq	#0,d0
	move.b	FS_nargs(a1),d0
	move.w	d0,d1
	mulu	#FPU_VAL_SIZE,d1	;place pour les args
	add.w	#12,d1
	sub.w	d1,sp
	move.w	d1,(sp)

	move.w	d0,2(sp)		;nbre d'args
	move.l	a1,4(sp)
	move.l	RVALUE,8(sp)
	addq.w	#1,_foncnestcnt
	addq.w	#1,_parnestcnt
.evarg:	move.w	2(sp),d0
	subq.w	#1,d0
	mulu	#FPU_VAL_SIZE,d0
	lea	12(sp,d0.w),a2
	move.l	a2,RVALUE
	addq.w	#1,EVAL_STR
	move.w	RPRIO,-(sp)
	moveq	#0,RPRIO
	bsr	FpEval
	movem.w	(sp)+,RPRIO
	bmi.s	.errev
	move.l	4(sp),a1
	subq.w	#1,2(sp)
	beq.s	.args_ok
	cmp.b	#',',(EVAL_STR)
	beq.s	.evarg		;arg. suivant
	bra.s	.errarg
.args_ok:	cmp.b	#')',-1(EVAL_STR)
	bne.s	.errarg
	move.l	FS_fonc(a1),a5
	move.l	8(sp),RVALUE
	move.l	RVALUE,a1
	lea	12(sp),a2
	jsr	(a5)
	bmi.s	.out
	subq.w	#1,_foncnestcnt
	add.w	(sp),sp
	bra	get_2nd_op
.errev:	clr.w	_foncnestcnt
.out:	add.w	(sp),sp
	tst.l	d1
	rts
.errarg:	add.w	(sp),sp
	bra	err_fonc_args
;  #] vars & foncs:
;  #[ Operations & foncs unaires:
u_plus:	move.w	RPRIO,-(sp)
	moveq	#PLUS_PRI,RPRIO
	bsr	FpEval
	movem.w	(sp)+,RPRIO
	bmi.s	.out
	bra	get_2nd_op
.out:	rts

u_minus:	move.w	RPRIO,-(sp)
	moveq	#MINUS_PRI,RPRIO
	move.l	RVALUE,-(sp)
	bsr	FpEval
	bmi.s	.err
	move.l	(sp)+,RVALUE
	move.l	RVALUE,a1
	fneg.x	(a1),fp0
	fmove.x	fp0,(a1)
	move.w	(sp)+,RPRIO
	bra	get_2nd_op
.err:	addq.w	#8,sp
	rts

SNGLOP	MACRO
	\1.x	(a2),fp0
	fmove.x	fp0,(a1)
	rts
	ENDM

;; -- fonctions --
_sqrt:	SNGLOP	fsqrt
_abs:	SNGLOP	fabs
_cos:	SNGLOP	fcos
_acos:	SNGLOP	facos
_cosh:	SNGLOP	fcosh
_tan:	SNGLOP	ftan
_tanh:	SNGLOP	ftanh
_atan:	SNGLOP	fatan
_atanh:	SNGLOP	fatanh
_sin:	SNGLOP	fsin
_asin:	SNGLOP	fasin
_sinh:	SNGLOP	fsinh
_etoxm1:	SNGLOP	fetoxm1
_etox:	SNGLOP	fetox
_getexp:	SNGLOP	fgetexp
_getman:	SNGLOP	fgetman
_int:	SNGLOP	fint
_intrz:	SNGLOP	fintrz
_log10:	SNGLOP	flog10
_log2:	SNGLOP	flog2
_logn:	SNGLOP	flogn
_lognp1:	SNGLOP	flognp1
_tentox:	SNGLOP	ftentox
_twotox:	SNGLOP	ftwotox

_getcr:	fmove.x	(a2),fp0
	fintrz.x	fp0,fp1
	fsub.x	fp0,fp1
	dc.l	$f23c4900,0,0,0	;fmove.x	#0,fp2
	fcmp.x	fp2,fp1
	fbne	.badcr	;le cr doit etre entier
	fmove.l	fp0,d0
	tst.l	d0
	beq.s	.pi
	cmp.l	#$40,d0
	bhs.s	.badcr
	add.w	d0,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0		;offset*6
	sub.w	#$b*6,d0
	bmi.s	.badcr
	cmp.w	#($f-$b)*6,d0
	bhi.s	.sup_f
	jsr	.b_f(pc,d0.w)
	bra.s	.conv
.sup_f:	sub.w	#($30-$b)*6,d0
	bmi.s	.badcr
	cmp.w	#$10*6,d0
	bhs.s	.badcr
	jsr	.30_3f(pc,d0.w)
.conv:	fmove.x	fp0,(a1)
	moveq	#0,d1
	rts
.badcr:	moveq	#EVAL_ILLOP,d1
	rts
.pi:	fmovecr	#0,fp0
	bra.s	.conv

GENCR	MACRO
	fmovecr	#\1,fp0
	rts
	ENDM
.b_f:
FPUCR	SET	$b
	REPT	$f-$b+1
	GENCR	FPUCR
FPUCR	SET	FPUCR+1
	ENDR

.30_3f:
FPUCR	SET	$30
	REPT	16
	GENCR	FPUCR
FPUCR	SET	FPUCR+1
	ENDR

;fonctions a n arguments:
;a1=@resultat
;a2=@tableau des args en ordre inverse
_modulo:	fmove.x	(a2),fp0
	fmod.x	FPU_VAL_SIZE(a2),fp0
	fmove.x	fp0,(a1)
	rts
_remainder:
	fmove.x	(a2),fp0
	frem.x	FPU_VAL_SIZE(a2),fp0
	fmove.x	fp0,(a1)
	rts
_scale:	fmove.x	(a2),fp0
	fscale.x	FPU_VAL_SIZE(a2),fp0
	fmove.x	fp0,(a1)
	rts

;  #] Operations & foncs unaires:
;  #[ Operations et foncs binaires:
_minus:	moveq	#SUB_PRI,d1
	lea	.sub(pc),a5
	bra.s	do_bop
.sub:	fmove.x	(a1),fp0
	fsub.x	(a2),fp0
	fmove.x	fp0,(a1)
	rts

_mul:	moveq	#MUL_PRI,d1
	lea	.mul(pc),a5
	bra.s	do_bop
.mul:	fmove.x	(a1),fp0
	fmul.x	(a2),fp0
	fmove.x	fp0,(a1)
	rts

_div:	moveq	#DIV_PRI,d1
	lea	.div(pc),a5
	bra.s	do_bop
.div:	fmove.x	(a1),fp0
	fdiv.x	(a2),fp0
	fmove.x	fp0,(a1)
	rts

_plus:	moveq	#ADD_PRI,d1
	lea	.plus(pc),a5
	bra.s	do_bop
.plus:	fmove.x	(a1),fp0
	fadd.x	(a2),fp0
	fmove.x	fp0,(a1)
	rts

do_bop:	cmp.w	RPRIO,d1
	ble.s	.out
	move.w	RPRIO,-(sp)
	move.l	RVALUE,-(sp)
	move.w	d1,RPRIO
	lea	-FPU_VAL_SIZE(sp),sp
	move.l	sp,RVALUE
	move.l	a5,-(sp)
	bsr	FpEval
	move.l	(sp)+,a5
	bmi.s	.err
	move.l	sp,a2			;2eme arg.
	move.l	FPU_VAL_SIZE(sp),a1		;1er arg.
	jsr	(a5)
	move.l	a1,RVALUE
	lea	FPU_VAL_SIZE+4(sp),sp
	move.w	(sp)+,RPRIO
	moveq	#0,d1
	bra	get_2nd_op
.err:	lea	6+FPU_VAL_SIZE(sp),sp
	bra.s	.end
.out:	subq.w	#1,EVAL_STR
	moveq	#0,d1
.end:	rts
;  #] Operations et foncs binaires:
;  #[ getvarlen:
;In:
;EVAL_STR.l:string+1
;Out:
;d0.l:strlen ou <0
;Garb:d1/a1
getvarlen:
	move.l	EVAL_STR,a1
	moveq	#-1,d0
	moveq	#0,d1
.loop1:	move.b	(a1)+,d1
	move.b	.vartable(pc,d1.w),d1
	dbne	d0,.loop1
	bmi.s	.error
	not.l	d0
	rts
.error:	bra	err_illeg_char
;	 #[ vartable:
.vartable:
 dc.b +1		;$00
 dc.b -1		;$01
 dc.b -1		;$02
 dc.b -1		;$03
 dc.b -1		;$04
 dc.b -1		;$05
 dc.b -1		;$06
 dc.b -1		;$07
 dc.b -1		;$08
 dc.b -1		;$09
 dc.b -1		;$0a
 dc.b -1		;$0b
 dc.b -1		;$0c
 dc.b -1		;$0d
 dc.b -1		;$0e
 dc.b -1		;$0f
 dc.b -1		;$10
 dc.b -1		;$11
 dc.b -1		;$12
 dc.b -1		;$13
 dc.b -1		;$14
 dc.b -1		;$15
 dc.b -1		;$16
 dc.b -1		;$17
 dc.b -1		;$18
 dc.b -1		;$19
 dc.b -1		;$1a
 dc.b -1		;$1b
 dc.b -1		;$1c
 dc.b -1		;$1d
 dc.b -1		;$1e
 dc.b -1		;$1f

 dc.b -1		;$20 ' '
 dc.b +1		;$21 !
 dc.b -1		;$22 "
 dc.b -1		;$23 #
 dc.b 0		;$24 $
 dc.b -1		;$25 %
 dc.b +1		;$26 &
 dc.b -1		;$27 '
 dc.b +1		;$28 (
 dc.b +1		;$29 )
 dc.b +1		;$2a *
 dc.b +1		;$2b +
 dc.b +1		;$2c ,
 dc.b +1		;$2d -
 dc.b 0		;$2e .
 dc.b +1		;$2f /

 dc.b 0		;$30 0
 dc.b 0		;$31 1
 dc.b 0		;$32
 dc.b 0		;$33
 dc.b 0		;$34
 dc.b 0		;$35
 dc.b 0		;$36
 dc.b 0		;$37
 dc.b 0		;$38
 dc.b 0		;$39 9
 dc.b -1		;$3a :
 dc.b -1		;$3b ;
 dc.b +1		;$3c <
 dc.b +1		;$3d =
 dc.b +1		;$3e >
 dc.b 0		;$3f ?

 dc.b -1		;$40 @
 dc.b 0		;$41 A
 dc.b 0		;$42
 dc.b 0		;$43
 dc.b 0		;$44
 dc.b 0		;$45
 dc.b 0		;$46
 dc.b 0		;$47
 dc.b 0		;$48
 dc.b 0		;$49
 dc.b 0		;$4a
 dc.b 0		;$4b
 dc.b 0		;$4c
 dc.b 0		;$4d
 dc.b 0		;$4e
 dc.b 0		;$4f O

 dc.b 0		;$50 P
 dc.b 0		;$51
 dc.b 0		;$52
 dc.b 0		;$53
 dc.b 0		;$54
 dc.b 0		;$55
 dc.b 0		;$56
 dc.b 0		;$57
 dc.b 0		;$58
 dc.b 0		;$59
 dc.b 0		;$5a Z
 dc.b -1		;$5b [
 dc.b -1		;$5c \
 dc.b -1		;$5d ]
 dc.b +1		;$5e ^
 dc.b 0		;$5f _

 dc.b -1		;$60 `
 dc.b 0		;$61 a
 dc.b 0		;$62
 dc.b 0		;$63
 dc.b 0		;$64
 dc.b 0		;$65
 dc.b 0		;$66
 dc.b 0		;$67
 dc.b 0		;$68
 dc.b 0		;$69
 dc.b 0		;$6a
 dc.b 0		;$6b
 dc.b 0		;$6c
 dc.b 0		;$6d
 dc.b 0		;$6e
 dc.b 0		;$6f o

 dc.b 0		;$70 p
 dc.b 0		;$71
 dc.b 0		;$72
 dc.b 0		;$73
 dc.b 0		;$74
 dc.b 0		;$75
 dc.b 0		;$76
 dc.b 0		;$77
 dc.b 0		;$78
 dc.b 0		;$79
 dc.b 0		;$7a z
 dc.b -1		;$7b {
 dc.b +1		;$7c |
 dc.b -1		;$7d }
 dc.b +1		;$7e ~
 dc.b -1		;$7f delta

 REPT $7f
 dc.b -1
 ENDR
 dc.b +1
;	 #] vartable:
;  #] getvarlen:
;  #[ errors:
;les erreurs:
err_bop_expected:
	moveq	#EVAL_BOPEXP,d1
	rts
err_illegal_op:
	moveq	#EVAL_ILLOP,d1
	rts
err_illeg_char:
	moveq	#EVAL_SYNTAX,d1
	rts
err_unexp_bop:
	moveq	#EVAL_BOPUNEXP,d1
	rts
err_unexp_end:
	moveq	#EVAL_EOE,d1
	rts
err_unexp_par:
	moveq	#EVAL_PARUNEXP,d1
	rts
err_var_type:
	moveq	#EVAL_TYPE,d1
	rts
err_var_nf:
	moveq	#EVAL_NFVAR,d1
	rts
err_matching:
	moveq	#EVAL_MATCH,d1
	rts
err_fonc_nf:
	moveq	#EVAL_NFFUNC,d1
	rts
err_fonc_args:
	moveq	#EVAL_NBARGS,d1
	rts
;  #] errors:
;  #[ Operand jt: 1st Eval
fpu_operand_jt:
t1	equ	*
	dc.w	err_unexp_end-t1	;0
	REPT	$19
	dc.w	err_illeg_char-t1	;1
	ENDR
	dc.w	err_illeg_char-t1	;1a TOKENQUOTE
	dc.w	err_illeg_char-t1	;1b
	dc.w	err_illeg_char-t1	;1c
	dc.w	err_illeg_char-t1	;1d
	dc.w	err_illeg_char-t1	;1e
	dc.w	err_illeg_char-t1	;1f
	dc.w	err_illeg_char-t1	;20 SPACE
	dc.w	err_unexp_bop-t1	;21 !
	dc.w	err_illeg_char-t1	;22 "
	dc.w	err_illeg_char-t1	;23 #
	dc.w	_hex_string-t1	;24 $
	dc.w	_binary_string-t1	;25 %
	dc.w	err_unexp_bop-t1	;26 &
	dc.w	err_illeg_char-t1	;27 '
	dc.w	open_parent-t1	;28 (
	dc.w	err_unexp_par-t1	;29 )
	dc.w	err_unexp_bop-t1	;2a *
	dc.w	u_plus-t1		;2b +
	dc.w	err_illeg_char-t1	;2c ,
	dc.w	u_minus-t1	;2d -
	dc.w	err_var_type-t1	;2e .
	dc.w	err_unexp_bop-t1	;2f /
	REPT	10		;30-39
	dc.w	_dec_string-t1
	ENDR
	dc.w	_hex_string-t1	;3a :
	dc.w	err_illeg_char-t1	;3b ;
	dc.w	err_unexp_bop-t1	;3c <
	dc.w	err_unexp_bop-t1	;3d =
	dc.w	err_unexp_bop-t1	;3e >
	dc.w	err_var_type-t1	;3f ?
	dc.w	err_illeg_char-t1	;40 @
	REPT	'Z'-'A'+1
	dc.w	fpu_var-t1	;41-5a
	ENDR
	dc.w	err_illeg_char-t1	;5b [
	dc.w	err_illeg_char-t1	;5c \
	dc.w	err_illeg_char-t1	;5d ]
	dc.w	err_unexp_bop-t1	;5e ^
	dc.w	fpu_var-t1	;5f _
	dc.w	err_illeg_char-t1	;60 `
	REPT	'z'-'a'+1
	dc.w	fpu_var-t1	;61-7a
	ENDR
	dc.w	err_illeg_char-t1	;7b {
	dc.w	err_unexp_bop-t1	;7c |
	dc.w	err_illeg_char-t1	;7d }
	dc.w	err_illegal_op-t1		;7e ~
	dc.w	err_illeg_char-t1	;7f
;  #] Operand jt:
;  #[ Operator jt:
fpu_operator_jt:
t2	equ	*
	dc.w	_end-t2	;0
	REPT	$19
	dc.w	err_illeg_char-t2	;1
	ENDR
	dc.w	err_illeg_char-t2	;1a TOKENQUOTE
	dc.w	err_illeg_char-t2	;1b
	dc.w	err_illeg_char-t2	;1c
	dc.w	err_illeg_char-t2	;1d
	dc.w	err_illeg_char-t2	;1e
	dc.w	err_illeg_char-t2	;1f
	dc.w	err_illeg_char-t2	;20 SPACE
	dc.w	err_illegal_op-t2		;21 !
	dc.w	err_illeg_char-t2	;22 "
	dc.w	err_illeg_char-t2	;23 #
	dc.w	err_bop_expected-t2	;24 $
	dc.w	err_bop_expected-t2	;25 %
	dc.w	err_illegal_op-t2	;26 &
	dc.w	err_bop_expected-t2	;27 '
	dc.w	err_bop_expected-t2	;28 (
	dc.w	close_parent-t2	;29 )
	dc.w	_mul-t2		;2a *
	dc.w	_plus-t2		;2b +
	dc.w	next_arg-t2	;2c ,
	dc.w	_minus-t2		;2d -
	dc.w	err_bop_expected-t2	;2e .
	dc.w	_div-t2		;2f /
	REPT	10
	dc.w	err_bop_expected-t2	;30-39
	ENDR
	dc.w	err_bop_expected-t2	;3a :
	dc.w	err_illeg_char-t2	;3b ;
	dc.w	err_illegal_op-t2	;3c <
	dc.w	err_illegal_op-t2	;3d =
	dc.w	err_illegal_op-t2	;3e >
	dc.w	err_illeg_char-t2	;3f ?
	dc.w	err_bop_expected-t2	;40 @
	REPT	'Z'-'A'+1
	dc.w	err_bop_expected-t2	;41-5a
	ENDR
	dc.w	err_illeg_char-t2	;5b [
	dc.w	err_bop_expected-t2	;5c \
	dc.w	err_illeg_char-t2	;5d ]
	dc.w	err_illegal_op-t2	;5e ^
	dc.w	err_bop_expected-t2	;5f _
	dc.w	err_illeg_char-t2	;60 `
	REPT	'z'-'a'+1
	dc.w	err_bop_expected-t2	;61-7a
	ENDR
	dc.w	err_illeg_char-t2	;7b {
	dc.w	err_illegal_op-t2	;7c |
	dc.w	err_illeg_char-t2	;7d }
	dc.w	err_bop_expected-t2	;7e ~
	dc.w	err_illeg_char-t2	;7f
;  #] Operator jt:

;  #[ foncs_table:
fpu_foncs_tab:	;size,@name-foncs_table,fonc
.t:
	dc.b	4,1
	dc.w	.sqrt-.t
	dc.l	_sqrt

	dc.b	3,1
	dc.w	.abs-.t
	dc.l	_abs

	dc.b	6,1		;fpurom
	dc.w	.getcr-.t
	dc.l	_getcr

	dc.b	4,1
	dc.w	.acos-.t
	dc.l	_acos

	dc.b	3,1
	dc.w	.cos-.t
	dc.l	_cos

	dc.b	4,1
	dc.w	.cosh-.t
	dc.l	_cosh

	dc.b	3,1
	dc.w	.tan-.t
	dc.l	_tan

	dc.b	4,1
	dc.w	.atan-.t
	dc.l	_atan

	dc.b	4,1
	dc.w	.tanh-.t
	dc.l	_tanh

	dc.b	5,1
	dc.w	.atanh-.t
	dc.l	_atanh

	dc.b	3,1
	dc.w	.sin-.t
	dc.l	_sin

	dc.b	4,1
	dc.w	.asin-.t
	dc.l	_asin

	dc.b	4,1
	dc.w	.sinh-.t
	dc.l	_sinh

	dc.b	6,1
	dc.w	.etoxm1-.t
	dc.l	_etoxm1

	dc.b	4,1
	dc.w	.etox-.t
	dc.l	_etox

	dc.b	3,1
	dc.w	.exp-.t
	dc.l	_getexp

	dc.b	3,1
	dc.w	.man-.t
	dc.l	_getman

	dc.b	3,1
	dc.w	.int-.t
	dc.l	_int

	dc.b	5,1
	dc.w	.intrz-.t
	dc.l	_intrz

	dc.b	5,1
	dc.w	.log10-.t
	dc.l	_log10

	dc.b	4,1
	dc.w	.log2-.t
	dc.l	_log2

	dc.b	4,1
	dc.w	.logn-.t
	dc.l	_logn

	dc.b	6,1
	dc.w	.lognp1-.t
	dc.l	_lognp1

	dc.b	3,2
	dc.w	.mod-.t
	dc.l	_modulo

	dc.b	3,2
	dc.w	.rem-.t
	dc.l	_remainder

	dc.b	5,2
	dc.w	.scale-.t
	dc.l	_scale

	dc.b	6,1
	dc.w	.tentox-.t
	dc.l	_tentox

	dc.b	6,1
	dc.w	.twotox-.t
	dc.l	_twotox


FP_FONCS_NB	EQU	(*-.t)/FS_SIZEOF
.sqrt:	dc.b	"sqrt"
.abs:	dc.b	"abs"
.getcr:	dc.b	"fpurom"
.acos:	dc.b	"acos"
.cos:	dc.b	"cos"
.cosh:	dc.b	"cosh"
.tan:	dc.b	"tan"
.atan:	dc.b	"atan"
.tanh:	dc.b	"tanh"
.atanh:	dc.b	"atanh"
.sin:	dc.b	"sin"
.asin:	dc.b	"asin"
.sinh:	dc.b	"sinh"
.etoxm1:	dc.b	"etoxm1"
.etox:	dc.b	"etox"
.exp:	dc.b	"exp"
.man:	dc.b	"man"
.int:	dc.b	"int"
.intrz:	dc.b	"intrz"
.log10:	dc.b	"log10"
.log2:	dc.b	"log2"
.logn:	dc.b	"logn"
.lognp1:	dc.b	"lognp1"
.mod:	dc.b	"mod"
.rem:	dc.b	"rem"
.scale:	dc.b	"scale"
.tentox:	dc.b	"tentox"
.twotox:	dc.b	"twotox"
	even
;  #] foncs_tab:
;  #[ FpuConv:
;In: a1=@valeur, d0=Opsize
;convertit du type extended (5) vers le type d0
FpuConv:	fmove.x	(a1),fp0
	subq.w	#3,d0		;SINGLE
	bmi.s	.end
	jmp	.Single(pc,d0.w*8)
.Single:	fmove.s	fp0,(a1)
	nop
	bra.s	.end
.d:	fmove.d	fp0,(a1)
	nop
	bra.s	.end
.x:	fmove.x	fp0,(a1)
	nop
	bra.s	.end
.p:	move.w	FPUk,d0
	fmove.p	fp0,(a1){d0}
.end:	rts
;  #] FpuConv:
;  #[ FPUImm:
;IN:
;d0:	size(0..3)
;a0:	string @
;OUT:
;d1:	 0
;	-1 (syntax_error)
;	-2 (range_error)
;a0:	end of ascii
;a1:	result buffer address
FPUImm:	movem.l	d3-d7/a2,-(sp)
	move.w	d0,FloatFormatFlag
	moveq	#0,d0
	move.w	FPUcr,d0
	fmove.l	d0,fpcr
	lea	TmpBuffer,a1
	clr.w	ISize
	clr.w	DSize
	clr.w	MSize
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
.ILoop1:
	move.b	(a0)+,d0
	bmi	.EndPass1
	cmp.b	#'.',d0
	beq	.DecimalPart
	cmp.b	#'e',d0
	beq	.ExponantPart
	cmp.b	#'E',d0
	beq	.ExponantPart
	sub.b	#'0',d0
	beq.s	.ILoop1
	cmp.b	#9,d0
	bhi	.EndPass1
	addq.w	#1,ISize
	addq.w	#1,MSize
	REPT	4
	andi	#$ef,ccr
	add.l	d7,d7
	addx.l	d6,d6
	addx.l	d5,d5
	ENDR
	add.b	d0,d7
.ILoop2:
	move.b	(a0)+,d0
	bmi	.EndPass1
	cmp.b	#'.',d0
	beq.s	.DecimalPart
	cmp.b	#'e',d0
	beq	.ExponantPart
	cmp.b	#'E',d0
	beq	.ExponantPart
	sub.b	#'0',d0
	bmi	.EndPass1
	cmp.b	#9,d0
	bhi	.EndPass1
	addq.w	#1,ISize
	addq.w	#1,MSize
	cmp.w	#17,MSize
	bgt	.RangeError
	REPT	4
	andi	#$ef,ccr
	add.l	d7,d7
	addx.l	d6,d6
	addx.l	d5,d5
	ENDR
	add.b	d0,d7
	bra.s	.ILoop2
.DecimalPart:
	tst.b	(a0)
	bmi	.SyntaxError
	cmp.b	#'e',(a0)
	beq	.SyntaxError
	cmp.b	#'E',(a0)
	beq	.SyntaxError
.DLoop:
	move.b	(a0)+,d0
	bmi	.EndPass1
	cmp.b	#'e',d0
	beq.s	.ExponantPart
	cmp.b	#'E',d0
	beq.s	.ExponantPart
	sub.b	#'0',d0
	bmi	.EndPass1
	cmp.b	#9,d0
	bhi	.EndPass1
	addq.w	#1,DSize
	addq.w	#1,MSize
	cmp.w	#17,MSize
	bgt	.RangeError
	REPT	4
	andi	#$ef,ccr
	add.l	d7,d7
	addx.l	d6,d6
	addx.l	d5,d5
	ENDR
	add.b	d0,d7
	bra.s	.DLoop

.ExponantPart:
	sf	ESignFlag
	tst.b	(a0)
	bmi	.SyntaxError
	cmp.b	#'+',(a0)
	beq.s	.SignTest
	cmp.b	#'-',(a0)
	bne.s	.ELoop
	st	ESignFlag
.SignTest:
	addq.w	#1,a0
	tst.b	(a0)
	bmi	.SyntaxError
.ELoop:
	move.b	(a0)+,d0
	bmi.s	.EndPass1
	sub.b	#'0',d0
	bmi.s	.EndPass1
	cmp.b	#9,d0
	bhi.s	.EndPass1
	mulu	#10,d4
	add.b	d0,d4
	cmp.w	#999,d4
	bgt	.RangeError
	bra.s	.ELoop

.EndPass1:
	clr.l	(a1)
	clr.l	4(a1)
	clr.l	8(a1)
	move.b	ISignFlag,d0
	and.b	#$80,d0
	or.b	d0,(a1)
	move.b	ESignFlag,d0
	and.b	#$40,d0
	or.b	d0,(a1)
	move.w	ISize,d0
	subq.w	#1,d0
	bmi.s	.zero	;.SyntaxError
	add.w	d0,d4
.zero:	cmp.w	#999,d4
	bgt	.RangeError
	move.w	MSize,d0
	sub.w	#17,d0
	neg.w	d0
	lsl.w	#2,d0
	subq.w	#1,d0
	bmi.s	.NoMShift
.MShiftLoop:
	andi	#$ef,ccr
	add.l	d7,d7
	addx.l	d6,d6
	addx.l	d5,d5
	dbf	d0,.MShiftLoop
.NoMShift:
	or.l	d5,(a1)
	or.l	d6,4(a1)
	or.l	d7,8(a1)
	ext.l	d4
	divu	#100,d4
	lsl.w	#8,d4
	or.w	d4,(a1)
	swap	d4
	ext.l	d4
	divu	#10,d4
	lsl.w	#4,d4
	or.w	d4,(a1)
	swap	d4
	or.w	d4,(a1)
	fmove.p	(a1),fp0
	lea	Buffer,a2
	move.w	FloatFormatFlag,d0
	jmp	.Single(pc,d0.w*8)
.Single:
	fmove.s	fp0,(a2)
	nop
	bra.s	.EndConvert
.Double:
	fmove.d	fp0,(a2)
	nop
	bra.s	.EndConvert
.Extended:
	fmove.x	fp0,(a2)
	nop
	bra.s	.EndConvert
.Packed:
	move.w	FPUk,d0
	fmove.p	fp0,(a2){d0}
.EndConvert:
	move.l	a2,a1
	subq.w	#1,a0
	moveq	#0,d1
.End:	movem.l	(sp)+,d3-d7/a2
	rts

.SyntaxError:
	moveq	#-1,d1
	bra.s	.End

.RangeError:
	moveq	#-2,d1
	bra.s	.End
;  #] FPUImm:

	BSS
Buffer:
 ds.l 3

TmpBuffer:
 ds.l 3

FloatFormatFlag:
 ds.w 1

ISignFlag:
 ds.b 1
ESignFlag:
 ds.b 1
ISize:
 ds.w 1
DSize:
 ds.w 1
MSize:
 ds.w 1
_parnestcnt:	ds.w	1
_foncnestcnt:	ds.w	1
	END

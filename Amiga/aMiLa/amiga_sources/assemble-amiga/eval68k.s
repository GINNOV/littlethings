;REGARDER VAR_STACK/a2

	XDEF	Evaluate,GloEval,LocEval,ForEval,OptEval
	XDEF	EvalErrP,EvalErrN,LValAlloc,FreeEval
	XDEF	GetEvFonc

	XREF	Eval1,GloEval1,LocEval1,ForEval1,OptEval1
	XREF	GetGloVar,GetLocVar,ForceGloVar,ForceLocVar
	XREF	icmpsort,FindEqu
	XREF	MyMalloc,MyMfree,GetXref

	XREF	CurSection,SecSize,TextSize
	XREF	GlobPatchFlag,LocPatchFlag

	include	"comequ.s"

LOCSTACK_SIZEOF	EQU	8
VALMEMSPACE	EQU	1000	;1k/bloc de valeurs
EVALONE		EQU	1
VAL_SIZE		EQU	10
;  #[ A faire:
;voir les cas de non EQU_EQU ni EQU_SET ni EQU_EQUR
;  #] A faire:
;  #[ Equrs:
VALUE		equr	d3
SIGN		equr	d4
PRIO		equr	d6
VAR_TYPE		equr	d7

EVAL_STR		equr	a0
VAR_STACK		equr	a2
OPERAND_JT	equr	a3
OPERATOR_JT	equr	a4
START_STACK	equr	a6

EVAL_REGS	REG	d3-d7/a0-a4/a6
GLOB_REGS	REG	d3-d7/a0-a4/a6
;  #] Equrs:
;  #[ Priority equs:
;unaires
PLUS_PRI		equ	6
MINUS_PRI		equ	6
NOT_PRI		equ	6
;binaires
ADD_PRI		equ	2
SUB_PRI		equ	2
MUL_PRI		equ	3
DIV_PRI		equ	3
OR_PRI		equ	4
AND_PRI		equ	4
XOR_PRI		equ	4
CMP_PRI		equ	1
EQUAL_PRI		equ	1
SHIFT_PRI		equ	5
;  #] Priority equs:
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

COMPL2	MACRO	;value,sign
	tst.b	\2
	beq.s	.\@
	sf	\2
	neg.l	\1
.\@:
	ENDM

PUSHEVAL	MACRO
;	movem.l	EVAL_REGS,-(sp)
	movem.l	EVAL_REGS,_regsbuf
	ENDM

POPEVAL	MACRO
;	movem.l	(sp)+,EVAL_REGS
	movem.l	_regsbuf,EVAL_REGS
	ENDM

PUSHGLOB	MACRO
;	movem.l	GLOB_REGS,-(sp)
	movem.l	GLOB_REGS,_regsbuf
	ENDM

POPGLOB	MACRO
;	movem.l	(sp)+,GLOB_REGS
	movem.l	_regsbuf,GLOB_REGS
	ENDM

;  #] Macros:

;  #[ Eval Entries:
;	 #[ First eval:
;Internal: PRIO=pri,ParNestCnt=parent_cnt,START_STACK=start sp
;Out: d1 = -errno ou 0 ou (0:expr_size:ff si evalone:type backpatch)
;d2 = SIGN
Evaluate:
	IFNE	EVALONE
	tst.w	d0
	beq	Eval1
	ENDC
	PUSHEVAL
	suba.l	VAR_STACK,VAR_STACK
	lea	pass1_operand_jt(pc),OPERAND_JT
	lea	numonly_operator_jt(pc),OPERATOR_JT
	moveq	#0,PRIO	;pri
	move.l	sp,START_STACK
	clr.l	_global_found	;+local+set
	moveq	#0,d1
	move.b	(EVAL_STR)+,d1
	ble.s	.err
	JSOPERAND
	move.l	VALUE,d0
	move.b	SIGN,d2
	bne.s	.neg
	moveq	#0,d1
	POPEVAL
	rts
.neg:	neg.l	d0
	bgt.s	.overf
.noerr:	moveq	#0,d1
	POPEVAL
	rts
.err:	bra	err_unexp_end
.overf:	cmp.l	VALUE,d0
	beq.s	.noerr
	bra	err_overflow
;	 #] First eval:
;	 #[ ForceEval:
;a priori meme operator_jt qu'en global patch
;renvoie dans d1 00:SIGN:00:section+1
ForEval:
	IFNE	EVALONE
	tst.w	d0
	beq	ForEval1
	ENDC
	PUSHEVAL
	lea	force_operand_jt(pc),OPERAND_JT
	lea	type_operator_jt(pc),OPERATOR_JT
	moveq	#0,PRIO	;pri
	move.l	sp,START_STACK
	moveq	#0,VAR_TYPE
	moveq	#0,d1
	move.b	(EVAL_STR)+,d1
	ble.s	.err
	JSOPERAND
	move.l	VALUE,d0
	tst.b	SIGN
	bne.s	.neg
	swap	SIGN
	or.l	SIGN,VAR_TYPE
	move.l	VAR_TYPE,d1
	POPEVAL
	rts
.neg:	tst.l	d0
	bmi.s	.overf
.noerr:	swap	SIGN
	or.l	SIGN,VAR_TYPE
	move.l	VAR_TYPE,d1
	POPEVAL
	rts
.err:	bra	err_unexp_end
.overf:	cmp.l	#$80000000,d0
	beq.s	.noerr
	bra	err_overflow
;	 #] ForceEval:
;	 #[ LocEval:
LocEval:
	IFNE	EVALONE
	tst.b	d0
	beq	LocEval1
	ENDC
	PUSHEVAL
	lea	local_operand_jt(pc),OPERAND_JT
	lea	type_operator_jt(pc),OPERATOR_JT
	lea	_val_table,VAR_STACK
	sf	_global_found
	moveq	#0,PRIO	;pri
	move.l	sp,START_STACK
	moveq	#0,VAR_TYPE
	moveq	#0,d1
	move.b	(EVAL_STR)+,d1
	ble.s	.err
	JSOPERAND
	move.l	VALUE,d0
	tst.b	SIGN
	bne.s	.neg
	move.l	VAR_TYPE,d1
	beq.s	.end
	moveq	#EVAL_RELOC,d1
.end:	POPEVAL
	rts
.neg:	neg.l	d0
	bgt.s	.overf
.noerr:	moveq	#1,d1
	swap	d1
	or.w	VAR_TYPE,d1
	beq.s	.end
	addq.w	#EVAL_RELOC,d1
	POPEVAL
	rts
.err:	bra	err_unexp_end
.overf:	cmp.l	VALUE,d0
	beq.s	.noerr
	bra	err_overflow
;	 #] LocEval:
;	 #[ GloEval:
GloEval:
	IFNE	EVALONE
	tst.b	d0
	beq	GloEval1
	ENDC
	PUSHGLOB
	move.l	EXP_backval(a3),VAR_STACK
	lea	glob_operand_jt(pc),OPERAND_JT
	lea	type_operator_jt(pc),OPERATOR_JT
	moveq	#0,PRIO	;pri
	move.l	sp,START_STACK
	moveq	#0,d1
	move.b	(EVAL_STR)+,d1
	ble.s	.err
	JSOPERAND
	move.l	VALUE,d0
	move.b	SIGN,d2
	bne.s	.neg
.end:	move.l	VAR_TYPE,d1
	POPGLOB
	rts
.neg:	neg.l	d0
	bgt.s	.overf
.noerr:	move.l	VAR_TYPE,d1
	POPGLOB
	rts
.err:	bra	err_unexp_end
.overf:	cmp.l	VALUE,d0
	beq.s	.noerr
	bra	err_overflow
;	 #] GloEval:
;	 #[ OptiEval: 
;Internal: PRIO=pri,ParNestCnt=parent_cnt,START_STACK=start sp
;Out: d1 = -errno ou 0 ou (0:expr_size:ff si evalone:type backpatch)
OptEval:
	IFNE	EVALONE
	tst.w	d0
	beq	OptEval1
	ENDC
	PUSHEVAL
	suba.l	VAR_STACK,VAR_STACK
	lea	opti_operand_jt(pc),OPERAND_JT
	lea	opti_operator_jt(pc),OPERATOR_JT
	moveq	#0,PRIO	;pri
	move.l	sp,START_STACK
	clr.l	_global_found	;+local+set
	moveq	#0,d1
	move.b	(EVAL_STR)+,d1
	ble.s	.err
	JSOPERAND
	move.l	VALUE,d0
	tst.b	SIGN
	beq.s	.plus
	neg.l	d0
	bgt.s	.overf
.plus:	move.l	VAR_TYPE,d1
	beq.s	._end
	swap	d1
	move.w	#EVAL_OPTI,d1
._end:	POPEVAL
	rts
.err:	bra	err_unexp_end
.overf:	cmp.l	VALUE,d0
	beq.s	.plus
	bra	err_overflow
;	 #] OptiEval:
;  #] Eval Entries:
;  #[ Eval Exits:
;	 #[ First Eval:
;(global ou local) + set
set_found_exit:
	move.w	d0,d3
	addq.w	#1,d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	ext.l	d0
	move.l	d0,d2
	bsr	LValAlloc
	beq.s	.no_mem
	lea	_val_table,a2
	move.l	d0,a1
	move.w	d3,(a1)+
	subq.w	#1,d3
.cp: 	move.l	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	dbf	d3,.cp
	clr.l	(a1)
	st	_global_found
	bra.s	fskip_x
.no_mem:	bra	err_nomem

;global ou local found
first_skip_exit:
	move.w	_setcnt,d0
	bne.s	set_found_exit
	moveq	#0,d0
fskip_x:	clr.l	ParNestCnt	;+FoncNestCnt
	move.l	EVAL_STR,d1
	sub.l	_a0_buf,d1
	subq.w	#1,d1
	swap	d1
	lea	_global_found,a1
	tst.b	(a1)+
	bne.s	.gf
;_local_found mis obligatoirement
	addq.w	#EVAL_LOC,d1
	POPEVAL
	rts
.gf:	tst.b	(a1)	;_local_found
	bne.s	.lgf	;cas marginal
	addq.w	#EVAL_GLO,d1
	POPEVAL
	rts
.lgf:	addq.w	#EVAL_LOCGLO,d1
	POPEVAL
	rts
;	 #] First Eval:
;	 #[ LocEval:
;y'a forcement un local dans l'expr	
glob_found_exit:	;LocalPatch uniquement
	clr.l	ParNestCnt	;+FoncNestCnt
	move.l	VAR_STACK,d0
	lea	_val_table,a2
	sub.l	a2,d0
	IFNE	BLINDOS
	beq.s	.illeg	;impossible
	ENDC
	move.l	d0,d2
	addq.l	#6,d0
	bsr	LValAlloc
	beq.s	.no_mem
	move.l	d0,a1
	clr.w	(a1)+
	lea	4(a1),a3
	move.l	a3,(a1)+
	lsr.w	#2,d2		;/4
	subq.w	#1,d2
.cp: 	move.l	(a2)+,(a1)+
	dbf	d2,.cp
	moveq	#EVAL_LOCGLO+EVAL_RELOC,d1
	POPEVAL
.end:	rts
.no_mem:	bra	err_nomem
	IFNE	BLINDOS
.illeg:	_Debugger
	ENDC
	
;	 #] LocEval:
;  #] Eval Exits:

;  #[ Eval:
;In: PRIO.w=niveau de priorite,EVAL_STR=@chaine courante
;Out: VALUE.l=valeur
;Internal: VALUE=value,SIGN.b=sign
Eval:	moveq	#0,d1
	move.b	(EVAL_STR)+,d1
	ble.s	.err
	JMOPERAND
.err:	bra	err_unexp_end
;  #] Eval:
;  #[ Get2ndOp:
get_2nd_op:
	moveq	#0,d1
	move.b	(EVAL_STR)+,d1
	ble.s	_end
	JMOPERATOR
;	 #[ END OF EXPR '\0',-1:
_end:	subq.w	#1,EVAL_STR
	tst.w	ParNestCnt
	bne.s	.errp
	rts
.errp:	bra	err_matching
;	 #] END OF EXPR '\0',-1:
;  #] Get2ndOp:

;  #[ Operand:
; 	#[ Commun:
;		#[ Fonctions:
EvalFonc:	move.l	EVAL_STR,a1
	move.l	a0,-(sp)
	lea	intg_foncs_table(pc),a0
	moveq	#FONCS_NB,d1
	bsr	GetEvFonc
	move.l	(sp)+,a0
	tst.l	d0
	beq	err_fonc_nf
	add.w	d5,EVAL_STR
	move.l	d0,a1
	moveq	#0,d0
	move.b	FS_nargs(a1),d0
	move.w	d0,d1
	mulu	#VAL_SIZE,d1	;pour les args
	add.w	#12,d1		;pour le controle
	sub.w	d1,sp
	move.w	d1,(sp)

	move.w	d0,2(sp)		;nbre d'args
	move.l	a1,4(sp)
;	move.l	RVALUE,8(sp)
	addq.w	#1,FoncNestCnt
	addq.w	#1,ParNestCnt
.evarg:	move.w	2(sp),d0
	subq.w	#1,d0
	mulu	#VAL_SIZE,d0
	lea	12(sp,d0.w),a2
	addq.w	#1,EVAL_STR
	move.l	FS_ev_fonc(a1),a5
	move.l	a2,-(sp)
	move.w	PRIO,-(sp)
	moveq	#0,PRIO
	jsr	(a5)		;eval de l'arg.
	move.w	(sp)+,PRIO
	move.l	(sp)+,a2
	move.l	VALUE,(a2)+
	move.l	VAR_TYPE,(a2)+
	move.w	SIGN,(a2)+
	move.l	4(sp),a1
	subq.w	#1,2(sp)
	beq.s	.args_ok
	cmp.b	#',',(EVAL_STR)
	beq.s	.evarg		;arg. suivant
	bra.s	.errarg
.args_ok:	cmp.b	#')',-1(EVAL_STR)
	bne.s	.errarg
	move.l	FS_fonc(a1),a5
;	move.l	8(sp),RVALUE
;	move.l	RVALUE,a1
	lea	12(sp),a2
	jsr	(a5)
	bmi.s	.out
	subq.w	#1,FoncNestCnt
	add.w	(sp),sp
	bra	get_2nd_op
.errev:	clr.w	FoncNestCnt
.out:	add.w	(sp),sp
	tst.l	d1
	rts
.errarg:	add.w	(sp),sp
	bra	err_fonc_args

;In: a0=@table fonctions,a1=@fonc name, d0.w=len
; d1.w=nbre de foncs de la table
;Out: d0.L=@fonction struct
;aussi appelee par FpuEval
GetEvFonc:
	movem.l	d1/d2/d7/a0-a4,-(sp)
	move.l	a0,a2
	move.l	a1,a3
	move.w	d0,d2
	move.l	a2,a4
	subq.w	#1,d1
	bmi.s	.endnf
.l1:	cmp.b	(a2),d2
	bne.s	.next
	move.w	2(a2),a0
	add.l	a4,a0
	move.l	a3,a1
	move.w	d2,d7
	subq.w	#1,d7
	jsr	icmpsort
	bne.s	.next
	move.l	a2,d0
	bra.s	.end
.next:	lea	FS_SIZEOF(a2),a2
	dbf	d1,.l1
.endnf:	moveq	#0,d0
.end:	movem.l	(sp)+,d1/d2/d7/a0-a4
	rts
;		#] Fonctions:
;		#[ Octal:
_octal_string:
	moveq	#0,VAR_TYPE
	sf	SIGN
	moveq	#'0',d1
	moveq	#7,d2
	moveq	#0,VALUE
.l1:
	REPT	4
	move.b	(EVAL_STR)+,d0
	sub.b	d1,d0
	bmi.s	.end
	cmp.b	d2,d0
	bhi.s	.end
	add.l	VALUE,VALUE
	bcs.s	.errbig
	add.l	VALUE,VALUE
	bcs.s	.errbig
	add.l	VALUE,VALUE
	bcs.s	.errbig
	or.b	d0,VALUE
	ENDR
	bra.s	.l1
.end:	subq.w	#1,EVAL_STR
	bra	get_2nd_op
.errbig:	bra	err_num2big
;		#] Octal:
;		#[ Binary:
_binary_string:
	moveq	#0,VAR_TYPE
	sf	SIGN
	moveq	#'0',d1
	moveq	#1,d2
	moveq	#0,VALUE
.l1:
	REPT	8
	move.b	(EVAL_STR)+,d0
	sub.b	d1,d0
	bmi.s	.end
	cmp.b	d2,d0
	bhi.s	.end
	add.l	VALUE,VALUE
	bcs.s	.errbig
	or.b	d0,VALUE
	ENDR
	bra	.l1
.end:	subq.w	#1,EVAL_STR
	bra	get_2nd_op
.errbig:	bra	err_num2big
;		#] Binary:
;		#[ Strings: voir TOKENQUOTE
_quote_string:
	moveq	#0,VALUE
	sf	SIGN
;	move.b	-1(EVAL_STR),d0
	moveq	#TOKENQUOTE,d0
	REPT	4
	move.b	(EVAL_STR)+,d1
;	ble.s	.err
	cmp.b	d0,d1
	beq.s	.end
	cmp.b	#"'",d1
	beq.s	.end
	cmp.b	#'"',d1
	beq.s	.end
	lsl.l	#8,VALUE
	or.b	d1,VALUE
	ENDR
	cmp.b	(EVAL_STR)+,d0
	bne.s	.long
.end:	moveq	#0,VAR_TYPE
	bra	get_2nd_op
.err:	bra	err_unexp_end
.long:	bra	err_str2long
;		#] Strings:
;		#[ Space: inutile ?
space_operand:
	moveq	#' ',d0
	cmp.b	(EVAL_STR)+,d0
	beq.s	space_operand
	subq.w	#1,EVAL_STR
	bra	Eval
;		#] Space:
;		#[ Decimal number:
;Out:a1=@start dec string
_dec_string:
	moveq	#0,VAR_TYPE
	moveq	#'0',d1
	moveq	#0,VALUE
	lea	-1(EVAL_STR),a1
	move.b	(a1),VALUE
	sub.b	d1,VALUE
	moveq	#10,d2
	sf	SIGN
	moveq	#0,d0
	REPT	7		;8 digits sans erreur
	move.b	(EVAL_STR)+,d0
	sub.b	d1,d0
	bmi.s	*+6		;.end
	cmp.b	d2,d0
	bcs.s	*+8		;.add
;.end:
	subq.w	#1,EVAL_STR
	bra	get_2nd_op
;.add:
	add.l	VALUE,VALUE
	move.l	VALUE,d5	;a*2
	add.l	VALUE,VALUE
	add.l	VALUE,VALUE	;a*8
	add.l	d5,VALUE	;a*10
	add.l	d0,VALUE
	ENDR
.get:	move.b	(EVAL_STR)+,d0
	sub.b	d1,d0
	bmi.s	.end
	add.l	VALUE,VALUE
	bcs.s	.error
	move.l	VALUE,d5	;a*2
	add.l	VALUE,VALUE
	bcs.s	.error
	add.l	VALUE,VALUE	;a*8
	bcs.s	.error
	add.l	d5,VALUE
	bcs.s	.error
	add.l	d0,VALUE
	bcc.s	.get
	bra.s	.error
.end:	subq.w	#1,EVAL_STR
	bra	get_2nd_op
.error:	bra	err_num2big
;		#] Decimal number:
;		#[ Hex number:
_hex_string:
	moveq	#0,VAR_TYPE
	sf	SIGN
	moveq	#4,d2
	moveq	#0,d1
	move.b	(EVAL_STR)+,d1
	move.b	hextab(pc,d1.w),d1
	bne.s	.chk
.fst:	move.b	(EVAL_STR)+,d1	;0 debute le nbre
	move.b	hextab(pc,d1.w),d1
	beq.s	.fst
	bgt.s	.notz
	moveq	#0,VALUE
.endh:	subq.w	#1,EVAL_STR
.end:	bra	get_2nd_op	;sortie 1
.chk:	bmi.s	.err
.notz:	move.l	d1,VALUE
.l1:
	REPT	7
	move.b	(EVAL_STR)+,d1
	move.b	hextab(pc,d1.w),d1
	bmi.s	.endh
	lsl.l	d2,VALUE
	or.b	d1,VALUE
	ENDR
	move.b	(EVAL_STR),d1
	move.b	hextab(pc,d1.w),d1
	bmi.s	.end	;sortie 2
.lnum:	bra	err_num2big
.err:	bra	err_bad_hexa
;		#[ Hex tab:
hextab:	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
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
;		#] Hex tab:
;		#] Hex number:
;		#[ '(':
open_parent:
	addq.w	#1,ParNestCnt
	move.w	PRIO,-(sp)		;niveau
	moveq	#0,PRIO
	bsr	Eval
	move.w	(sp)+,PRIO
	bra	get_2nd_op
;		#] '(':
;		#[ Unary plus: tous types d'eval
u_plus: 	move.w	PRIO,-(sp)
	moveq	#PLUS_PRI,PRIO
	bsr	Eval
	move.w	(sp)+,PRIO
	bra	get_2nd_op
;		#] Unary plus:
; 	#] Commun:
; 	#[ 1st Eval:
;		#[ Unary minus:
u_minus:	move.w	PRIO,-(sp)
	moveq	#MINUS_PRI,PRIO
	bsr	Eval
	not.b	SIGN
	move.w	(sp)+,PRIO
	bra	get_2nd_op
;		#] Unary minus:
;		#[ Not:
_not:	move.w	PRIO,-(sp)
	moveq	#NOT_PRI,PRIO
	bsr	Eval
	COMPL2	VALUE,SIGN
	not.l	VALUE
	bpl.s	.plus
	neg.l	VALUE
	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.err:	bra	err_operr
;		#] Not:
;		#[ *:PC
u_star:	moveq	#0,VAR_TYPE
	move.w	CurSection,VAR_TYPE
	addq.w	#1,VAR_TYPE
	move.l	VAR_STACK,d0
	bne.s	.notfst
	clr.w	_setcnt
	lea	_val_table,VAR_STACK
.notfst:	move.l	SecSize,(VAR_STACK)+
	clr.b	(VAR_STACK)+		;sign
	move.b	VAR_TYPE,(VAR_STACK)+
	addq.w	#1,_setcnt
	bra	FirstEvalSkip
;		#] *:
;		#[ Var/Equate:
var_pass1:
	moveq	#0,VAR_TYPE
	subq.w	#1,EVAL_STR
	bsr	getvarlen
	move.w	d0,d5
	cmp.b	#'(',0(EVAL_STR,d5.w)
	beq.s	.fonc
	jsr	FindEqu
	add.w	d5,EVAL_STR
	beq.s	.equnf
	move.l	d0,a1
	move.l	VAR_value(a1),VALUE
	move.b	VAR_sec(a1),VAR_TYPE
	addq.b	#1,VAR_TYPE
	bgt.s	.reloc		;equ/set en reloc pour GlobPatch
	move.b	VAR_type(a1),d1
	lsl.b	#1,d1
	scs	SIGN
	beq	get_2nd_op	;VAR_EQU
	subq.b	#EQU_SET*2,d1
	bne.s	.equr
	bsr.s	.stset		;VAR_SET -> stocker valeur
	bra	get_2nd_op
.reloc:	cmp.b	#EQU_SET,VAR_type(a1)
	bne.s	.equnf
	bsr.s	.stset
.equnf:	st	_global_found
	bra	FirstEvalSkip
.equr:	tst.b	(EVAL_STR)
	bpl.s	.errequr
	move.l	VALUE,d0
	move.l	START_STACK,sp
	POPEVAL
	moveq	#EVAL_EQUR,d1
	rts
.errequr:	bra	err_equr
.fonc:	bra	EvalFonc

	;SET variable
.stset:	move.l	VAR_STACK,d0
	bne.s	.notfst
	clr.w	_setcnt
	lea	_val_table,VAR_STACK
.notfst:	move.l	VALUE,(VAR_STACK)+
	move.b	SIGN,(VAR_STACK)+
	move.b	VAR_TYPE,(VAR_STACK)+
	addq.w	#1,_setcnt
	rts
;		#] Var/Equate:
;		#[ Local:
local_pass1:
	bsr	getvarlen
	ble.s	.errsyn
	add.w	d0,EVAL_STR
	st	_local_found
	bra	FirstEvalSkip
.errsyn:	bra	err_varchar
;		#] Local:
; 	#] 1st Eval:
; 	#[ Global patch:
;		#[ Unary minus: global+force+local+opti
local_u_minus:
force_u_minus:
glob_u_minus:
opti_u_minus:
	move.w	PRIO,-(sp)
	moveq	#MINUS_PRI,PRIO
	bsr	Eval
	tst.w	VAR_TYPE
	bne.s	.errt
	not.b	SIGN
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.errt:	bra	err_operr
;		#] Unary minus:
;		#[ Not: global+force+local+opti
local_not:
force_not:
opti_not:
glob_not:	move.w	PRIO,-(sp)
	moveq	#NOT_PRI,PRIO
	bsr	Eval
	tst.w	VAR_TYPE
	bne.s	.err
	COMPL2	VALUE,SIGN
	not.l	VALUE
	bpl.s	.plus
	neg.l	VALUE
	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.err:	bra	err_operr
;		#] Not:
;		#[ *:PC
;aussi appele par var_globpatch
global_set:
	move.l	VAR_STACK,d0
	beq.s	.fwset
	move.b	(VAR_STACK),d0
	cmp.b	1(VAR_STACK),d0
	bge.s	.fwset
	addq.b	#1,(VAR_STACK)
	ext.w	d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0	;(compteur set)*6
	move.l	2(VAR_STACK,d0.w),VALUE
	move.b	6(VAR_STACK,d0.w),SIGN
	move.b	7(VAR_STACK,d0.w),VAR_TYPE
	IFNE	ATARI
	cmp.b	#SEC_data+1,VAR_TYPE
	bne.s	.no_data
	add.l	TextSize,VALUE
.no_data:	ENDC
	bra	get_2nd_op
.fwset:	bra	err_set_forward
;		#] *:
;		#[ Var/Equate:
var_globpatch:
	moveq	#0,VAR_TYPE
	subq.w	#1,EVAL_STR
	bsr	getvarlen
	move.w	d0,d5
	cmp.b	#'(',0(EVAL_STR,d0.w)
	beq.s	.fonc
	jsr	GetGloVar
	beq.s	.xref
	add.w	d5,EVAL_STR
	move.l	d0,VALUE
	addq.b	#1,d1		;sec++
	bne.s	.rel
	moveq	#0,d1
.rel:	move.l	d1,VAR_TYPE	;#+0+sec
	move.b	VAR_type(a1),d1
	lsl.b	#1,d1
	scs	SIGN
	beq	get_2nd_op	;EQU_EQU
	subq.b	#EQU_SET*2,d1
	beq.s	global_set	;SET variable
	subq.b	#(EQU_GLOB-EQU_SET)*2,d1
	beq	get_2nd_op
	bra	err_type		;ni EQU_SET ni EQU_EQU
.errvar:	bra	err_var_nf
.fonc:	bra	EvalFonc
.xref:	move.w	d5,d0
	jsr	GetXref
	beq.s	.errvar
	add.w	d5,a0
	moveq	#0,VALUE
	sf	SIGN
	swap	d0		;#<<16
	move.l	d0,d1
	st	d1		;undef
	move.l	d1,VAR_TYPE
	bra	get_2nd_op
;		#] Var/Equate:
;		#[ Local:
local_globpatch:
	move.w	(VAR_STACK),d0
	ext.w	d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d0,d1
	move.l	2(VAR_STACK,d1.w),d0
	bmi.s	.notfst
	move.l	d0,_loc_list
	neg.l	d0
	move.l	d0,2(VAR_STACK,d1.w)
.notfst:	bsr	getvarlen
	ble.s	.errsyn		;impossible?
	add.w	d0,EVAL_STR
	move.l	_loc_list,a1
	IFNE	AMIGA
	move.l	(a1)+,VAR_TYPE
	move.l	(a1)+,VALUE
	ENDC
	IFNE	ATARI
	move.l	(a1)+,d1
	move.l	(a1)+,VALUE
;	subq.b	#SEC_data+1,d1
	cmp.b	#SEC_data+1,d1
	bne.s	.nodata
	add.l	TextSize,VALUE
;	addq.b	#SEC_data+1,d1
.nodata:	move.l	d1,VAR_TYPE
	ENDC	;ATARI
.end:	sf	SIGN
	bset	#8,d1
	move.l	a1,_loc_list
	bra	get_2nd_op
.errsyn:	bra	err_varchar
;		#] Local:
; 	#] Global patch:
; 	#[ Force:
;		#[ *:PC
force_u_star:
	moveq	#0,VAR_TYPE
	move.w	CurSection,VAR_TYPE
	addq.w	#1,VAR_TYPE
	move.l	SecSize,VALUE
	moveq	#0,SIGN
	bra	get_2nd_op
;		#] *:
;		#[ Var/Equate:
var_force:
	moveq	#0,VAR_TYPE
	subq.w	#1,EVAL_STR
	bsr	getvarlen
	move.w	d0,d2
	cmp.b	#'(',0(EVAL_STR,d0.w)
	beq.s	.fonc
	jsr	FindEqu
	beq.s	.equnf
	move.l	d0,a1
	move.l	VAR_value(a1),VALUE
	move.b	VAR_type(a1),d1
	lsl.b	#1,d1
	scs	SIGN
	subq.b	#EQU_EQUR*2,d1
	beq.s	.errequr
	move.b	VAR_sec(a1),VAR_TYPE
	addq.b	#1,VAR_TYPE
	add.w	d2,EVAL_STR
	bra	get_2nd_op
.equnf:	move.w	d2,d0
	jsr	ForceGloVar
	beq.s	.errnf
	add.w	d2,EVAL_STR
	sf	SIGN
	move.b	VAR_sec(a1),VAR_TYPE
	addq.b	#1,VAR_TYPE
	move.l	d0,VALUE
	bra	get_2nd_op
.errnf:	bra	err_must_eval
.errequr:	bra	err_equr
.fonc:	bra	EvalFonc
;		#] Var/Equate:
;		#[ Local:
local_force:
	moveq	#0,VAR_TYPE
	bsr	getvarlen
	ble.s	.errsyn
	move.w	d0,d2
	jsr	ForceLocVar
	beq.s	.errnf
	add.w	d2,EVAL_STR
	move.b	VAR_sec(a1),VAR_TYPE
	addq.b	#1,VAR_TYPE
	sf	SIGN
	move.l	d0,VALUE
	bra	get_2nd_op
.errsyn:	bra	err_varchar
.errnf:	bra	err_must_eval
;		#] Local:
; 	#] Force:
; 	#[ Local Patch:
;		#[ *: PC
local_u_star:
	st	_global_found	;forcer GlobalPatch
	bra	LocalEvalSkip
;		#] *:
;		#[ Var/Equate:
var_locpatch:
	moveq	#0,VAR_TYPE
	subq.w	#1,EVAL_STR
	bsr	getvarlen
	move.w	d0,d5
	cmp.b	#'(',0(EVAL_STR,d0.w)
	beq.s	.fonc
	jsr	FindEqu
	beq.s	.equnf
	add.w	d5,EVAL_STR
	move.l	d0,a1
	move.l	VAR_value(a1),VALUE
	move.b	VAR_sec(a1),VAR_TYPE
	addq.b	#1,VAR_TYPE
	move.b	VAR_type(a1),d1
	lsl.b	#1,d1
	scs	SIGN
	beq	get_2nd_op
	subq.b	#EQU_SET*2,d1
	bne.s	.equr
	st	_global_found	;set -> global patch obligatoire
	bra	LocalEvalSkip
.equr:	tst.b	(EVAL_STR)
	bpl.s	.errequr
	move.l	VALUE,d0
	move.l	START_STACK,sp
	POPEVAL
	moveq	#EVAL_EQUR,d1
	rts
.errequr:	bra	err_equr
.equnf:	st	_global_found
	add.w	d5,EVAL_STR
	bra	LocalEvalSkip
.fonc:	bra	EvalFonc
;		#] Var/Equate:
;		#[ Local:
local_locpatch:
	bsr	getvarlen
	ble.s	.errsyn
	pea	0(EVAL_STR,d0.w)
	jsr	GetLocVar
	beq.s	.errvar
	move.l	(sp)+,EVAL_STR
	IFNE	ATARI
	subq.b	#SEC_data,d1
	beq.s	.data
	addq.w	#1+SEC_data,d1
	ENDC
	IFNE	AMIGA
	addq.w	#1,d1
	ENDC
	move.l	d1,(VAR_STACK)+
	move.l	d0,(VAR_STACK)+
	moveq	#1,VAR_TYPE
	sf	SIGN
	move.l	d0,VALUE
	bra	get_2nd_op
.errsyn:	bra	err_varchar
.errvar:	bra	err_local_nf
;la reference a un local en section data sera resolue en GlobalPatch
	IFNE	ATARI
.data:	addq.w	#1+SEC_data,d1
	move.l	d1,(VAR_STACK)+
	move.l	d0,(VAR_STACK)+
	st	_global_found
	bra	LocalEvalSkip
	ENDC
;		#] Local:
; 	#] Local Patch:
; 	#[ Opti:
;		#[ *:PC
opti_u_star:
	moveq	#0,VAR_TYPE
	move.w	CurSection,VAR_TYPE
	addq.w	#1,VAR_TYPE
	move.l	VAR_STACK,d0
	bne.s	.notfst
	clr.w	_setcnt
	lea	_val_table,VAR_STACK
.notfst:	move.l	SecSize,(VAR_STACK)+
	clr.b	(VAR_STACK)+		;sign
	move.b	VAR_TYPE,(VAR_STACK)+
	addq.w	#1,_setcnt
	bra	get_2nd_op
;		#] *:
;		#[ Var/Equate:
var_opti:	moveq	#0,VAR_TYPE
	subq.w	#1,EVAL_STR
	bsr	getvarlen
	move.w	d0,d2
	cmp.b	#'(',0(EVAL_STR,d0.w)
	beq.s	.fonc
	jsr	FindEqu
	beq.s	.equnf
	move.l	d0,a1
	move.l	VAR_value(a1),VALUE
	move.b	VAR_type(a1),d1
	move.b	VAR_sec(a1),VAR_TYPE
	addq.b	#1,VAR_TYPE
	sne	_global_found
	lsl.b	#1,d1
	scs	SIGN
	bne.s	.notequ
	add.w	d2,EVAL_STR
	bra	get_2nd_op
.equnf:	move.w	d2,d0
	st	_global_found
	jsr	ForceGloVar
	beq.s	.glonf
	add.w	d2,EVAL_STR
	sf	SIGN
	move.b	VAR_sec(a1),VAR_TYPE
	addq.b	#1,VAR_TYPE
	move.l	d0,VALUE
	st	_global_found
	bra	get_2nd_op
.glonf:	bra	FirstEvalSkip
.fonc:	bra	EvalFonc
.notequ:	subq.b	#EQU_SET*2,d1
	beq.s	.set
.equr:	tst.b	(EVAL_STR)
	bpl.s	.errequr
	move.l	VALUE,d0
	move.l	START_STACK,sp
	POPEVAL
	moveq	#EVAL_EQUR,d1
	rts
.errequr:	bra	err_equr
.set:	move.l	VAR_STACK,d0
	bne.s	.notfst
	clr.w	_setcnt
	lea	_val_table,VAR_STACK
.notfst:	move.l	VALUE,(VAR_STACK)+
	move.b	SIGN,(VAR_STACK)+
	move.b	VAR_TYPE,(VAR_STACK)+
	addq.w	#1,_setcnt
	bra	get_2nd_op
;		#] Var/Equate:
;		#[ Local:
local_opti:
	moveq	#0,VAR_TYPE
	bsr.s	getvarlen
	ble.s	.errsyn
	st	_local_found
	move.w	d0,d2
	jsr	ForceLocVar
	add.w	d2,EVAL_STR
	beq.s	.locnf
	move.b	VAR_sec(a1),VAR_TYPE
	addq.b	#1,VAR_TYPE
	sf	SIGN
	move.l	d0,VALUE
	bra	get_2nd_op
.locnf:	bra	FirstEvalSkip
.errsyn:	bra	err_varchar
;		#] Local:
; 	#] Opti:
; 	#[ getvarlen:
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
	move.b	_vartable(pc,d1.w),d1
	dbne	d0,.loop1
	bmi.s	.error
	not.l	d0
	rts
.error:	bra	err_varchar
;	 #[ vartable:
_vartable:
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
;	 #] getvarlen:
;  #] Operand:
;  #[ Operator:
;	 #[ virgule: ','
_next_arg:
	tst.w	FoncNestCnt
	beq	err_illeg_char
	subq.w	#1,EVAL_STR
	rts
;	 #] virgule: ','
;	 #[ SWAP(x): fonction
;In: a2=@tab de (VALUE.L / VAR_TYPE.L / SIGN.W) * args #
;Out: VALUE/VAR_TYPE/SIGN
_fonc_swap:
	tst.w	4+2(a2)
	bne.s	.err
	move.l	(a2),VALUE
	move.w	8(a2),SIGN
	COMPL2	VALUE,SIGN
	swap	VALUE
	tst.l	VALUE
	smi	SIGN
	bpl.s	.out
	neg.l	VALUE
.out:	moveq	#0,VAR_TYPE
	rts
.err:	bra	err_type

_fonc_sizeof:
	move.l	(a2),a1		;@var struct.SIZEOF
	move.l	VAR_value(a1),VALUE
	moveq	#0,SIGN
	moveq	#0,VAR_TYPE
	rts

_arg_sizeof_eval:	;meme I/O que Eval
	bsr	getvarlen
	move.w	d0,d5
	beq.s	.errname
	cmp.b	#')',0(a0,d0.w)
	bne.s	.errname
	lea	-256(sp),sp
	move.l	sp,a1
	subq.w	#1,d0
.cp:	move.b	(a0)+,(a1)+
	dbf	d0,.cp
	lea	.sizeof(pc),a5
.cp1:	move.b	(a5)+,(a1)+
	bne.s	.cp1
	move.w	d5,d0
	addq.w	#7,d0
	move.l	a0,a5
	move.l	sp,a0
	jsr	FindEqu
	lea	1(a5),a0
	lea	256(sp),sp
	beq.s	.errnf
	move.l	d0,VALUE
	bra.s	close_parent
.errname:	bra	err_varchar
.errnf:	bra	err_var_nf
.sizeof:	dc.b	".SIZEOF",0
;  #] Eval:
;	 #] SWAP(x):
;	 #[ PARENTHESIS ')':
close_parent:
	tst.w	PRIO
	beq.s	.niv0
	subq.w	#1,EVAL_STR	;pas avaler la parenthese
	rts			;et revenir
.niv0:	subq.w	#1,ParNestCnt
	bmi.s	.errp
	rts
.errp:	bra	err_unexp_par
;	 #] PARENTHESIS ')':
;	 #[ SPACE ' ': inutile ?
space_operator:
	moveq	#' ',d0
	cmp.b	(EVAL_STR)+,d0
	beq.s	space_operator
	subq.w	#1,EVAL_STR
	bra	get_2nd_op
;	 #] SPACE ' ':
;	 #[ 1st pass: VAR_TYPE=0
;		#[ PLUS '+':
out_plus:	subq.w	#1,EVAL_STR
	rts
_plus:	moveq	#ADD_PRI,d1
	cmp.w	PRIO,d1
	ble.s	out_plus
	move.w	PRIO,-(sp)
	move.l	VALUE,-(sp)
	move.b	SIGN,-(sp)
	move.w	d1,PRIO
	bsr	Eval
do_plus:	move.b	(sp)+,d0
	beq.s	.pa
	tst.b	SIGN
	beq.s	.mapb
;.mamb: -a+(-b)=-(a+b)
	add.l	(sp)+,VALUE	;SIGN already <0
	bcs.s	.overf
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.mapb:	;-a+b = b-a
	sub.l	(sp)+,VALUE
	bpl.s	.end
	st	SIGN
	neg.l	VALUE
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.pa:	tst.b	SIGN
	bne.s	.pamb
;.papb:	a+b
	add.l	(sp)+,VALUE	;SIGN already >0
	bcs.s	.overf
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.pamb:	;a+(-b) = a-b
	move.l	(sp)+,d0
	sub.l	VALUE,d0
	bmi.s	.endminus
	sf	SIGN
	move.l	d0,VALUE
.end:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.endminus:
	neg.l	d0
	move.l	d0,VALUE
	st	SIGN
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.overf:	bra	err_overflow
;		#] PLUS '+':
;		#[ MINUS '-':
out_minus:
	subq.w	#1,EVAL_STR
	rts
_minus:	moveq	#SUB_PRI,d1
	cmp.w	PRIO,d1
	ble.s	out_minus
	move.w	PRIO,-(sp)
	move.l	VALUE,-(sp)
	move.b	SIGN,-(sp)
	move.w	d1,PRIO
	bsr	Eval
do_minus:	move.b	(sp)+,d0
	beq.s	.pa
	tst.b	SIGN
	beq.s	.mapb
;.mamb -a-(-b) = b-a, no overflow
	sub.l	(sp)+,VALUE
	smi	SIGN
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.mapb:	;-a-b = -(a+b) overflow
	add.l	(sp)+,VALUE
	bcs.s	.overf
	st	SIGN
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.pa:	tst.b	SIGN
	bne.s	.pamb
;.papb	;a-b, no overflow
	move.l	(sp)+,d0
	sub.l	VALUE,d0
	bpl.s	.end1
	st	SIGN
	neg.l	d0
.end1:	move.l	d0,VALUE
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.pamb:	;a-(-b) = a+b, overflow
	add.l	(sp)+,VALUE
	bcs.s	.overf
	sf	SIGN
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.overf:	bra	err_overflow
;		#] MINUS '-':
;		#[ OR '|','!':
_or:	moveq	#OR_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	COMPL2	VALUE,SIGN
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	COMPL2	VALUE,SIGN
	or.l	(sp)+,VALUE
	bpl.s	.plus
	neg.l	VALUE
	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.out:	subq.w	#1,EVAL_STR
	rts
;		#] OR '|','!':
;		#[ XOR '^':
_eor:	moveq	#XOR_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	COMPL2	VALUE,SIGN
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	COMPL2	VALUE,SIGN
	move.l	(sp)+,d0
	eor.l	d0,VALUE
	bpl.s	.plus
	neg.l	VALUE
	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.out:	subq.w	#1,EVAL_STR
	rts
;		#] XOR '^':
;		#[ AND '&':
_and:	moveq	#AND_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	COMPL2	VALUE,SIGN
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	COMPL2	VALUE,SIGN
	and.l	(sp)+,VALUE
	bpl.s	.plus
	neg.l	VALUE
	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.out:	subq.w	#1,EVAL_STR
	rts
;		#] AND '&':
;		#[ LT & LSHIFT: '<','<=','<<'
_shift_left:
	cmp.b	#'<',(EVAL_STR)
	beq.s	.shift
	moveq	#CMP_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	move.l	VALUE,-(sp)
	move.b	SIGN,-(sp)
	move.w	d1,PRIO
	cmp.b	#'=',(EVAL_STR)
	beq.s	.le
	bsr	Eval
do_lt	equ	*
	move.b	(sp)+,d0
	move.l	(sp)+,d2
	moveq	#0,d1
	cmp.l	VALUE,d2
	blo.s	.inf
	beq.s	.same
	sf	SIGN	;|a|>|b|
	tst.b	d0
	beq.s	.end
.true:	st	SIGN
	addq.l	#1,d1
.end:	move.l	d1,VALUE
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.inf:	tst.b	SIGN	;|a|<|b|
	beq.s	.true
	sf	SIGN
	bra.s	.end
.same:	cmp.b	SIGN,d0
	blt.s	.true
	sf	SIGN
	bra.s	.end
.out:	subq.w	#1,EVAL_STR
	rts
.shift:	moveq	#SHIFT_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	addq.w	#1,EVAL_STR
	move.w	PRIO,-(sp)
	COMPL2	VALUE,SIGN
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	tst.b	SIGN
	bne.s	.err_neg
	move.l	VALUE,d0
	move.l	(sp)+,VALUE
	lsl.l	d0,VALUE
;	tst.l	VALUE
;	bpl.s	.plus
;	neg.l	VALUE
;	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.err_neg:	bra	err_neg_shift
.le:	addq.w	#1,EVAL_STR
	bsr	Eval
do_le:	move.b	(sp)+,d0	;sign
	move.l	(sp)+,d2	;value
	moveq	#0,d1
	cmp.l	VALUE,d2
	bls.s	.inf
	beq.s	.same
	sf	SIGN	;|a|>=|b|
	tst.b	d0
	beq.s	.end
.true:	st	SIGN
	addq.l	#1,d1
.end:	move.l	d1,VALUE
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.inf:	tst.b	SIGN	;|a|<=|b|
	beq.s	.true
	sf	SIGN
	bra.s	.end
.same:	cmp.b	SIGN,d0
	bls.s	.true
	sf	SIGN
	bra.s	.end
;		#] LT & LSHIFT:
;		#[ GT & RSHIFT: '>','>=','>>'
;1>2	;b>0 ok
;-1>2	;b>0 ok
;1>-2	;b<0 inversion
;-1>-2	;b<0 inversion	->inversion quand b<0
;
;2>1	;ok
;-2>1	;inversion
;2>-1	;ok
;-2>-1	;inversion	->inversion quand a<0
_shift_right:
	cmp.b	#'>',(EVAL_STR)
	beq.s	.shift
;'>'
	moveq	#CMP_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	move.l	VALUE,-(sp)
	move.b	SIGN,-(sp)
	move.w	d1,PRIO
	cmp.b	#'=',(EVAL_STR)
	beq.s	ge
	bsr	Eval
do_gt	equ	*
	move.b	(sp)+,d0
	move.l	(sp)+,d2
	moveq	#0,d1
	cmp.l	VALUE,d2
	bcc.s	.sup
	tst.b	SIGN
	beq.s	.end	;false
.true:	st	SIGN
	addq.l	#1,d1
.end:	move.l	d1,VALUE
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.sup:	beq.s	.same
	tst.b	d0
	beq.s	.true
	sf	SIGN
	bra.s	.end
.same:	cmp.b	SIGN,d0
	bgt.s	.true
	sf	SIGN
	bra.s	.end
.out:	subq.w	#1,EVAL_STR
	rts
.shift:	moveq	#SHIFT_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	addq.w	#1,EVAL_STR
	move.w	PRIO,-(sp)
	COMPL2	VALUE,SIGN
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	tst.b	SIGN
	bne.s	.errneg
	move.l	VALUE,d0
	move.l	(sp)+,VALUE
	lsr.l	d0,VALUE
;	tst.l	VALUE
;	bpl.s	.plus
;	neg.l	VALUE
;	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.errneg:	bra	err_neg_shift
;>=
ge:	addq.w	#1,EVAL_STR
	bsr	Eval
do_ge:	move.b	(sp)+,d0
	move.l	(sp)+,d2
	moveq	#0,d1
	cmp.l	VALUE,d2
	bhs.s	.sup
	tst.b	SIGN
	beq.s	.end	;false
.true:	st	SIGN
	addq.l	#1,d1
.end:	move.l	d1,VALUE
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.sup:	beq.s	.same
	tst.b	d0
	beq.s	.true
	sf	SIGN
	bra.s	.end
.same:	cmp.b	SIGN,d0
	bge.s	.true
	sf	SIGN
	bra.s	.end
;		#] GT & RSHIFT:
;		#[ DIVIDE '/':
_div:	moveq	#DIV_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	move.b	SIGN,-(sp)
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
do_div	equ	*
	move.l	VALUE,d1
	beq.s	.zero
	move.l	(sp)+,d0	;d0/d1
	moveq	#0,VALUE
	moveq	#0,d5
	moveq	#31,d6		;PRIO
.loop:	add.l	VALUE,VALUE
	roxl.l	d0
	roxl.l	d5
	cmp.l	d1,d5
	blt.s	.clrbt
	addq.l	#1,VALUE
	sub.l	d1,d5
.clrbt:	dbf	d6,.loop
	cmp.b	(sp)+,SIGN
	sne	SIGN
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.zero:	bra	err_zero_divide
.out:	subq.w	#1,EVAL_STR
	rts
;		#] DIVIDE '/':
;		#[ MULTIPLY '*':
_mul:	moveq	#MUL_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	move.b	SIGN,-(sp)
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
do_mul	equ	*
	move.l	(sp)+,d6	;PRIO
	move.l	d6,d5
	swap	d5
	move.w	VALUE,d0
	move.w	VALUE,d1
	swap	VALUE
	tst.w	VALUE		; test a1
	beq.s	.1
	tst.w	d5		; test a2
	bne.s	.overf		; Must Have ((a1==0)|(a2==0))
.1:	mulu	d6,d1	; b1*b2
	mulu	d5,d0		; a1*b2
	swap	d0
	tst.w	d0
	bne.s	.overf
	add.l	d0,d1		; (b1*b2)+(a1*b2)
	move.w	VALUE,d0		; a2
	mulu	d6,d0	; a2*b1
	swap	d0
	tst.w	d0
	bne.s	.overf
	add.l	d0,d1		; (b1*b2)+(a1*b2)+(a2*b1)
	move.l	d1,VALUE
	cmp.b	(sp)+,SIGN
	sne	SIGN
	move.w	(sp)+,PRIO
	bra	get_2nd_op
.overf:	bra	err_overflow
.out:	subq.w	#1,EVAL_STR
	rts
;		#] MULTIPLY '*':
;		#[ EQUAL: '=','=='
_equal:	moveq	#EQUAL_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	move.l	VALUE,-(sp)
	move.b	SIGN,-(sp)
	cmp.b	#'=',(EVAL_STR)
	bne.s	.eval
	addq.w	#1,EVAL_STR
.eval:	move.w	d1,PRIO
	bsr	Eval
	move.b	(sp)+,d0
	cmp.l	(sp)+,VALUE
	bne.s	.diff
	cmp.b	SIGN,d0
	bne.s	.diff
	st	SIGN
	moveq	#1,VALUE
.end:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.diff:	moveq	#0,VALUE
	sf	SIGN
	bra.s	.end
.out:	subq.w	#1,EVAL_STR
	rts
;		#] EQUAL:
;		#[ '$': pour local
dollar_op:
	move.b	-2(EVAL_STR),d0
	cmp.b	#'0',d0
	blt.s	.err
	cmp.b	#'9',d0
	bhi.s	.err
	st	_local_found
	bra	FirstEvalSkip
.err:	bra	err_bop_expected
;		#] '$':
;	 #] 1st pass:
;	 #[ Patch & force & opti: type checking
;		#[ PLUS: '+'
t_plus:	moveq	#ADD_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	move.l	VALUE,-(sp)
	move.b	SIGN,-(sp)
	move.l	VAR_TYPE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	tst.w	VAR_TYPE
	beq.s	.l1
	tst.l	(sp)+
	beq	do_plus
	bra	err_operr
.l1:	move.l	(sp)+,VAR_TYPE
	bra	do_plus
.out:	subq.w	#1,EVAL_STR
	rts
;		#] PLUS:
;		#[ MINUS: '-'
t_minus:	moveq	#SUB_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	move.l	VALUE,-(sp)
	move.b	SIGN,-(sp)
	move.l	VAR_TYPE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	tst.w	VAR_TYPE
	beq.s	.l1
	move.l	(sp)+,d0
	beq.s	.err		;cste-label:erreur
	addq.b	#1,d0
	beq.s	.err		;xref-label:erreur
	addq.b	#1,VAR_TYPE
	beq.s	.err		;label-xref:erreur
	cmp.b	VAR_TYPE,d0
	bne.s	.err		;sec1-sec2 = erreur
	moveq	#0,VAR_TYPE	;label-label
	bra	do_minus
.l1:	move.l	(sp)+,VAR_TYPE
	bra	do_minus
.out:	subq.w	#1,EVAL_STR
	rts
.err:	bra	err_operr
;		#] MINUS:
;		#[ OR: '|','!'
t_or:   	moveq	#OR_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	tst.w	VAR_TYPE
	bne.s	.err
	move.w	PRIO,-(sp)
	COMPL2	VALUE,SIGN
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	tst.w	VAR_TYPE
	bne.s	.err
	COMPL2	VALUE,SIGN
	or.l	(sp)+,VALUE
	bpl.s	.plus
	neg.l	VALUE
	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.err:	bra	err_operr
.out:	subq.w	#1,EVAL_STR
	rts
;		#] OR:
;		#[ XOR: '^'
t_eor:	moveq	#XOR_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
  	tst.w	VAR_TYPE
	bne.s	.err
	move.w	PRIO,-(sp)
	COMPL2	VALUE,SIGN
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	tst.w	VAR_TYPE
	bne.s	.err
	move.l	(sp)+,d0
	COMPL2	VALUE,SIGN
	eor.l	d0,VALUE
	bpl.s	.plus
	neg.l	VALUE
	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.err:	bra	err_operr
.out:	subq.w	#1,EVAL_STR
	rts
;		#] XOR:
;		#[ AND: '&'
t_and:	moveq	#AND_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
 	tst.w	VAR_TYPE
	bne.s	.err
	move.w	PRIO,-(sp)
	COMPL2	VALUE,SIGN
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	tst.w	VAR_TYPE
	bne.s	.err
	COMPL2	VALUE,SIGN
	and.l	(sp)+,VALUE
	bpl.s	.plus
	neg.l	VALUE
	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.err:	bra	err_operr
.out:	subq.w	#1,EVAL_STR
	rts
;		#] AND:
;		#[ LT & LSHIFT: '<','<=','<<'
t_sft_left:
	cmp.b	#'<',(EVAL_STR)
	beq.s	.shift
;'<' label<label ou cste<cste
	moveq	#CMP_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	move.l	VALUE,-(sp)
	move.b	SIGN,-(sp)
	move.w	VAR_TYPE,-(sp)
	cmp.b	#'=',(EVAL_STR)
	beq.s	t_le
	move.w	d1,PRIO
	bsr	Eval
	tst.w	(sp)+
	beq.s	.a_cst
	tst.w	VAR_TYPE
	beq.s	.err	;label<cste
	moveq	#0,VAR_TYPE
	bra	do_lt
.a_cst:	tst.w	VAR_TYPE
	beq	do_lt
.err:	bra	err_operr
.out:	subq.w	#1,EVAL_STR
	rts

.shift:	moveq	#SHIFT_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	addq.w	#1,EVAL_STR
	tst.w	VAR_TYPE
	bne.s	.err
	move.w	PRIO,-(sp)
	COMPL2	VALUE,SIGN
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	tst.w	VAR_TYPE
	bne.s	.err
	tst.b	SIGN
	bne.s	.errneg
	move.l	VALUE,d0
	move.l	(sp)+,VALUE
	lsl.l	d0,VALUE
;	tst.l	VALUE
;	bpl.s	.plus
;	neg.l	VALUE
;	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.errneg:	bra	err_neg_shift

t_le:	addq.w	#1,EVAL_STR
	move.w	d1,PRIO
	bsr	Eval
	tst.w	(sp)+
	beq.s	.a_cst
	tst.w	VAR_TYPE
	beq.s	.err	;label<cste
	moveq	#0,VAR_TYPE
	bra	do_le
.a_cst:	tst.w	VAR_TYPE
	beq	do_le
.err:	bra	err_operr
.out:	subq.w	#1,EVAL_STR
	rts
;		#] LT & LSHIFT:
;		#[ GT & RSHIFT: '>','>=','>>'
t_sft_right:
	cmp.b	#'>',(EVAL_STR)
	beq.s	.shift
;'>' label>label ou cste>cste
	moveq	#CMP_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	move.l	VALUE,-(sp)
	move.b	SIGN,-(sp)
	move.w	VAR_TYPE,-(sp)
	move.w	d1,PRIO
	cmp.b	#'=',(EVAL_STR)
	beq.s	t_ge
	bsr	Eval
	tst.w	(sp)+
	beq.s	.a_cst
	tst.w	VAR_TYPE
	beq.s	.err	;cste>label
	moveq	#0,VAR_TYPE
	bra	do_gt
.a_cst:	tst.w	VAR_TYPE
	beq	do_gt
.err:	bra	err_operr
.out:	subq.w	#1,EVAL_STR
	rts

.shift:	;cste>>cste
	moveq	#SHIFT_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	tst.w	VAR_TYPE
	bne.s	.err
	addq.w	#1,EVAL_STR
	move.w	PRIO,-(sp)
	COMPL2	VALUE,SIGN
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	tst.w	VAR_TYPE
	bne.s	.err
	tst.b	SIGN
	bne.s	.errneg
	move.l	VALUE,d0
	move.l	(sp)+,VALUE
	lsr.l	d0,VALUE
;	tst.l	VALUE
;	bpl.s	.plus
;	neg.l	VALUE
;	st	SIGN
.plus:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.errneg:	bra	err_neg_shift
;>=
t_ge:	addq.w	#1,EVAL_STR
	bsr	Eval
	tst.w	(sp)+
	beq.s	.a_cst
	tst.w	VAR_TYPE
	beq.s	.err	;cste>label
	moveq	#0,VAR_TYPE
	bra	do_ge
.a_cst:	tst.w	VAR_TYPE
	beq	do_ge
.err:	bra	err_operr
;		#] GT & RSHIFT:
;		#[ DIVIDE: '/'
t_div:	moveq	#DIV_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	tst.w	VAR_TYPE
	bne.s	.err
	move.w	PRIO,-(sp)
	move.b	SIGN,-(sp)
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	tst.w	VAR_TYPE
	beq	do_div
.err:	bra	err_operr
.out:	subq.w	#1,EVAL_STR
	rts
;		#] DIVIDE:
;		#[ MULTIPLY: '*'
t_mul:	moveq	#MUL_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	tst.w	VAR_TYPE
	bne.s	.err
	move.w	PRIO,-(sp)
	move.b	SIGN,-(sp)
	move.l	VALUE,-(sp)
	move.w	d1,PRIO
	bsr	Eval
	tst.w	VAR_TYPE
	beq	do_mul
.err:	bra	err_operr
.out:	subq.w	#1,EVAL_STR
	rts
;		#] MULTIPLY:
;		#[ EQUAL: '=','=='
t_equal:	moveq	#EQUAL_PRI,d1
	cmp.w	PRIO,d1
	ble.s	.out
	move.w	PRIO,-(sp)
	move.l	VALUE,-(sp)
	move.b	SIGN,-(sp)
	move.l	VAR_TYPE,-(sp)
	cmp.b	#'=',(EVAL_STR)
	bne.s	.eval
	addq.w	#1,EVAL_STR
.eval:	move.w	d1,PRIO
	bsr	Eval
	move.l	(sp)+,d1
	or.b	d1,VAR_TYPE
	bmi.s	.erropr
	moveq	#0,VAR_TYPE
	move.b	(sp)+,d0
	cmp.l	(sp)+,VALUE
	bne.s	.diff
	cmp.b	SIGN,d0
	bne.s	.diff
	st	SIGN
	moveq	#1,VALUE
.end:	move.w	(sp)+,PRIO
	bra	get_2nd_op
.diff:	moveq	#0,VALUE
	sf	SIGN
	bra.s	.end
.out:	subq.w	#1,EVAL_STR
	rts
.erropr:	bra	err_operr
;		#] EQUAL:
;		#[ '$': (pour local) sauf opti
t_dollar_op:
	move.b	-2(EVAL_STR),d0
	cmp.b	#'0',d0
	blt	err_bop_expected
	cmp.b	#'9',d0
	bhi	err_bop_expected
	tst.b	GlobPatchFlag
	bne.s	.glo
	tst.b	LocPatchFlag
	bne.s	.loc
;Force
	move.l	EVAL_STR,d5
	sub.l	a1,d5
	move.w	d5,d0
	move.l	a1,a0
	jsr	ForceLocVar
	add.w	d5,a0
	beq.s	.errnf
	move.b	VAR_sec(a1),VAR_TYPE
	addq.b	#1,VAR_TYPE
	sf	SIGN
	move.l	d0,VALUE
	bra	get_2nd_op
.errnf:	bra	err_must_eval

;Local Patch	
.loc:	move.l	EVAL_STR,d5
	sub.l	a1,d5
	move.w	d5,d0
	move.l	a1,a0
	jsr	GetLocVar
	add.w	d5,a0
	beq.s	.errvar
	IFNE	ATARI
	subq.b	#SEC_data,d1
	beq.s	.data
	addq.w	#1+SEC_data,d1
	ENDC
	IFNE	AMIGA
	addq.w	#1,d1
	ENDC
	move.l	d1,(VAR_STACK)+
	move.l	d0,(VAR_STACK)+
	moveq	#1,VAR_TYPE
	sf	SIGN
	move.l	d0,VALUE
	bra	get_2nd_op
.errsyn:	bra	err_varchar
.errvar:	bra	err_local_nf
;la reference a un local en section data sera resolue en GlobalPatch
	IFNE	ATARI
.data:	addq.w	#1+SEC_data,d1
	move.l	d1,(VAR_STACK)+
	move.l	d0,(VAR_STACK)+
	st	_global_found	;force global patch
	bra	LocalEvalSkip
	ENDC
;GlobalPatch
;on branche pas sur local_globpatch a cause de son getvarlen
.glo:	move.w	(VAR_STACK),d0
	ext.w	d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d0,d1
	move.l	2(VAR_STACK,d1.w),d0
	bmi.s	.notfst
	move.l	d0,_loc_list
	neg.l	d0
	move.l	d0,2(VAR_STACK,d1.w)
.notfst:	move.l	_loc_list,a1
	IFNE	AMIGA
	move.l	(a1)+,VAR_TYPE
	move.l	(a1)+,VALUE
	ENDC
	IFNE	ATARI
	move.l	(a1)+,d1
	move.l	(a1)+,VALUE
	subq.b	#SEC_data+1,d1
	bne.s	.nodata
	add.l	TextSize,VALUE
	addq.b	#SEC_data+1,d1
.nodata:	move.l	d1,VAR_TYPE
	ENDC	;ATARI
.end:	sf	SIGN
	move.l	a1,_loc_list
	bra	get_2nd_op
;		#] '$':
;	 #] Patch & force & opti:
;	 #[ Opti: ce qui est specifique a cette eval
opti_dollar_op:
	move.b	-2(EVAL_STR),d0
	cmp.b	#'0',d0
	blt	err_bop_expected
	cmp.b	#'9',d0
	bhi	err_bop_expected
	move.l	EVAL_STR,d2
	sub.l	a1,d2
	move.w	d2,d0
	move.l	a1,a0
	jsr	ForceLocVar
	add.w	d2,a0
	beq.s	.nf
	move.b	VAR_sec(a1),VAR_TYPE
	addq.b	#1,VAR_TYPE
	sf	SIGN
	move.l	d0,VALUE
	bra	get_2nd_op
.nf:	st	_local_found
	bra	FirstEvalSkip
;	 #] Opti:
;  #] Operator:

;  #[ LocalEvalSkip:
;appele quand symbole inconnu en Local Patch
;quand on rencontre une locale, stocker sa valeur
LocalEvalSkip:
	moveq	#0,d4
.get:	move.b	(EVAL_STR)+,d4
	ble.s	.end
	move.b	.skip_tab(pc,d4.w),d4
	beq.s	.get
	ext.w	d4
	jmp	.saut(pc,d4.w)
.dollar:	moveq	#'0',d1
	moveq	#'9',d2
	lea	-1(EVAL_STR),a1
	move.b	-(a1),d0
	cmp.b	d1,d0
	blo.s	LocalEvalSkip
	cmp.b	d2,d0
	bhi.s	LocalEvalSkip
;remonter juste avant nombre$
.loc:	move.b	-(a1),d0
	cmp.b	d2,d0
	bhi.s	.locstrt
.saut:	cmp.b	d1,d0
	bhs.s	.loc
.locstrt:	move.l	EVAL_STR,a3
	move.l	a3,d0
	addq.l	#1,a1
	sub.l	a1,d0
	move.l	a1,a0
.getloc:	jsr	GetLocVar
	beq.s	.errvar
	move.l	a3,EVAL_STR
	addq.l	#1,d1
	move.l	d1,(VAR_STACK)+	;# sec
	move.l	d0,(VAR_STACK)+	;val
	bra.s	LocalEvalSkip
.errvar:	bra	err_local_nf
.errsyn:	bra	err_varchar
.end:	move.l	START_STACK,sp
	bra	glob_found_exit
.point:	bsr	getvarlen
	ble.s	.errsyn
	lea	0(EVAL_STR,d0.w),a3
	bra.s	.getloc
.quote:	moveq	#TOKENQUOTE,d0
.q:	cmp.b	(EVAL_STR)+,d0
	bne.s	.q
	bra.s	LocalEvalSkip
;	 #[ Skip table:
.skip_tab:
 dc.b 0		;$00
 dc.b 0		;$01
 dc.b 0		;$02
 dc.b 0		;$03
 dc.b 0		;$04
 dc.b 0		;$05
 dc.b 0		;$06
 dc.b 0		;$07
 dc.b 0		;$08
 dc.b 0		;$09
 dc.b 0		;$0a
 dc.b 0		;$0b
 dc.b 0		;$0c
 dc.b 0		;$0d
 dc.b 0		;$0e
 dc.b 0		;$0f

 dc.b 0		;$10
 dc.b 0		;$11
 dc.b 0		;$12
 dc.b 0		;$13
 dc.b 0		;$14
 dc.b 0		;$15
 dc.b 0		;$16
 dc.b 0		;$17
 dc.b 0		;$18
 dc.b 0		;$19
 dc.b .quote-.saut	;$1a
 dc.b 0		;$1b
 dc.b 0		;$1c
 dc.b 0		;$1d
 dc.b 0		;$1e
 dc.b 0		;$1f

 dc.b 0		;$20 ' '
 dc.b 0		;$21 !
 dc.b .quote-.saut	;$22 "
 dc.b 0		;$23 #
 dc.b .dollar-.saut	;$24 $
 dc.b 0		;$25 %
 dc.b 0		;$26 &
 dc.b .quote-.saut	;$27 '
 dc.b 0		;$28 (
 dc.b 0		;$29 )
 dc.b 0		;$2a *
 dc.b 0		;$2b +
 dc.b 0		;$2c ,
 dc.b 0		;$2d -
 dc.b .point-.saut	;$2e .
 dc.b 0		;$2f /

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
 dc.b 0		;$3a :
 dc.b 0		;$3b ;
 dc.b 0		;$3c <
 dc.b 0		;$3d =
 dc.b 0		;$3e >
 dc.b 0		;$3f ?

 dc.b 0		;$40 @
 dc.b 0	;$41 A
 dc.b 0	;$42
 dc.b 0	;$43
 dc.b 0	;$44
 dc.b 0	;$45
 dc.b 0	;$46
 dc.b 0	;$47
 dc.b 0	;$48
 dc.b 0	;$49
 dc.b 0	;$4a
 dc.b 0	;$4b
 dc.b 0	;$4c
 dc.b 0	;$4d
 dc.b 0	;$4e
 dc.b 0	;$4f O

 dc.b 0	;$50 P
 dc.b 0	;$51
 dc.b 0	;$52
 dc.b 0	;$53
 dc.b 0	;$54
 dc.b 0	;$55
 dc.b 0	;$56
 dc.b 0	;$57
 dc.b 0	;$58
 dc.b 0	;$59
 dc.b 0	;$5a Z
 dc.b 0		;$5b [
 dc.b 0		;$5c \
 dc.b 0		;$5d ]
 dc.b 0		;$5e ^
 dc.b 0	;$5f _

 dc.b 0		;$60 `
 dc.b 0	;$61 a
 dc.b 0	;$62
 dc.b 0	;$63
 dc.b 0	;$64
 dc.b 0	;$65
 dc.b 0	;$66
 dc.b 0	;$67
 dc.b 0	;$68
 dc.b 0	;$69
 dc.b 0	;$6a
 dc.b 0	;$6b
 dc.b 0	;$6c
 dc.b 0	;$6d
 dc.b 0	;$6e
 dc.b 0	;$6f o

 dc.b 0	;$70 p
 dc.b 0	;$71
 dc.b 0	;$72
 dc.b 0	;$73
 dc.b 0	;$74
 dc.b 0	;$75
 dc.b 0	;$76
 dc.b 0	;$77
 dc.b 0	;$78
 dc.b 0	;$79
 dc.b 0	;$7a z
 dc.b 0		;$7b {
 dc.b 0		;$7c |
 dc.b 0		;$7d }
 dc.b 0		;$7e ~
 dc.b 0		;$7f delta
;	 #] Skip table:
;  #] LocalEvalSkip:
;  #[ FirstEvalSkip:
;but: engranger les valeurs des SETs et *
firstevalskip:
.storePC:	move.l	VAR_STACK,d0
	bne.s	.notfst2
	clr.w	_setcnt
	lea	_val_table,VAR_STACK
.notfst2:	move.l	SecSize,(VAR_STACK)+
	clr.b	(VAR_STACK)+		;sign
	move.w	CurSection,d0
	addq.w	#1,d0
	move.b	d0,(VAR_STACK)+
	addq.w	#1,_setcnt
	bra.s	FirstEvalSkip
.point:	bsr	getvarlen
	ble.s	.errsyn
	st	_local_found
	add.w	d0,EVAL_STR
	bra.s	FirstEvalSkip
.eqfound:	move.l	d0,a1
	move.b	VAR_type(a1),d0
	lsl.b	#1,d0
	beq.s	FirstEvalSkip	;VAR_EQU
	scs	d1
	subq.b	#EQU_SET*2,d0
	bne.s	.equr
	move.l	VAR_STACK,d0
	bne.s	.notfst
	clr.w	_setcnt
	lea	_val_table,VAR_STACK
.notfst:	move.l	VAR_value(a1),(VAR_STACK)+
	move.b	d1,(VAR_STACK)+
	move.b	VAR_sec(a1),d0
	addq.b	#1,d0
	move.b	d0,(VAR_STACK)+
	addq.w	#1,_setcnt
	st	_global_found
	bra.s	FirstEvalSkip
.errsyn:	bra	err_varchar
.end:	move.l	START_STACK,sp
	bra	first_skip_exit
.star:	moveq	#0,d0
	move.b	-2(EVAL_STR),d0
	lea	operators_tab(pc),a1
	tst.b	0(a1,d0.w)
	beq.s	FirstEvalSkip	;operande
	bra	.storePC
FirstEvalSkip	equ	*
	moveq	#0,d4
.get:	move.b	(EVAL_STR)+,d4
	ble.s	.end
	add.w	d4,d4
	move.w	.skip_tab(pc,d4.w),d4
	beq.s	.get
	jmp	.saut(pc,d4.w)
.glo:	subq.w	#1,EVAL_STR
	bsr	getvarlen
	move.w	d0,d3
	jsr	FindEqu
	add.w	d3,EVAL_STR
	bne.s	.eqfound
	st	_global_found
	bra.s	FirstEvalSkip
;probablement erreur
.equr:	tst.b	(EVAL_STR)
	bpl.s	.errequr
	move.l	VAR_value(a1),d0
	move.l	START_STACK,sp
	POPEVAL
	moveq	#EVAL_EQUR,d1
	rts
.errequr:	bra	err_equr
.dollar:	move.b	-2(EVAL_STR),d0
.saut:	sub.b	#'0',d0
	bmi.s	.hexa		;saut arbitrairement ici
	cmp.b	#9,d0
	bhi.s	.hexa
	st	_local_found
	bra.s	FirstEvalSkip
.hexa:	moveq	#0,d4
.hex:	lea	hextab(pc),a2
	move.b	(EVAL_STR)+,d4
	ble	.end
	tst.b	0(a2,d4.w)
	bpl.s	.hex
	subq.w	#1,EVAL_STR
	bra.s	FirstEvalSkip
.quote:	move.b	-1(EVAL_STR),d1
	move.b	(EVAL_STR)+,d0
	ble	.end
	cmp.b	d1,d0
	bne.s	.quote
	bra	FirstEvalSkip
;	 #[ Skip table:
;0:non symbole (operateur,chiffre)
.skip_tab:
 dc.w 0		;$00
 dc.w 0		;$01
 dc.w 0		;$02
 dc.w 0		;$03
 dc.w 0		;$04
 dc.w 0		;$05
 dc.w 0		;$06
 dc.w 0		;$07
 dc.w 0		;$08
 dc.w 0		;$09
 dc.w 0		;$0a
 dc.w 0		;$0b
 dc.w 0		;$0c
 dc.w 0		;$0d
 dc.w 0		;$0e
 dc.w 0		;$0f

 dc.w 0		;$10
 dc.w 0		;$11
 dc.w 0		;$12
 dc.w 0		;$13
 dc.w 0		;$14
 dc.w 0		;$15
 dc.w 0		;$16
 dc.w 0		;$17
 dc.w 0		;$18
 dc.w 0		;$19
 dc.w .quote-.saut	;$1a
 dc.w 0		;$1b
 dc.w 0		;$1c
 dc.w 0		;$1d
 dc.w 0		;$1e
 dc.w 0		;$1f

 dc.w 0		;$20 ' '
 dc.w 0		;$21 !
 dc.w .quote-.saut	;$22 "
 dc.w 0		;$23 #
 dc.w .dollar-.saut	;$24 $
 dc.w 0		;$25 %
 dc.w 0		;$26 &
 dc.w .quote-.saut	;$27 '
 dc.w 0		;$28 (
 dc.w 0		;$29 )
 dc.w .star-.saut	;$2a *
 dc.w 0		;$2b +
 dc.w 0		;$2c ,
 dc.w 0		;$2d -
 dc.w .point-.saut	;$2e .
 dc.w 0		;$2f /

 dc.w 0		;$30 0
 dc.w 0		;$31 1
 dc.w 0		;$32
 dc.w 0		;$33
 dc.w 0		;$34
 dc.w 0		;$35
 dc.w 0		;$36
 dc.w 0		;$37
 dc.w 0		;$38
 dc.w 0		;$39 9
 dc.w 0		;$3a :
 dc.w 0		;$3b ;
 dc.w 0		;$3c <
 dc.w 0		;$3d =
 dc.w 0		;$3e >
 dc.w 0		;$3f ?

 dc.w 0		;$40 @
 dc.w .glo-.saut	;$41 A
 dc.w .glo-.saut	;$42
 dc.w .glo-.saut	;$43
 dc.w .glo-.saut	;$44
 dc.w .glo-.saut	;$45
 dc.w .glo-.saut	;$46
 dc.w .glo-.saut	;$47
 dc.w .glo-.saut	;$48
 dc.w .glo-.saut	;$49
 dc.w .glo-.saut	;$4a
 dc.w .glo-.saut	;$4b
 dc.w .glo-.saut	;$4c
 dc.w .glo-.saut	;$4d
 dc.w .glo-.saut	;$4e
 dc.w .glo-.saut	;$4f O

 dc.w .glo-.saut	;$50 P
 dc.w .glo-.saut	;$51
 dc.w .glo-.saut	;$52
 dc.w .glo-.saut	;$53
 dc.w .glo-.saut	;$54
 dc.w .glo-.saut	;$55
 dc.w .glo-.saut	;$56
 dc.w .glo-.saut	;$57
 dc.w .glo-.saut	;$58
 dc.w .glo-.saut	;$59
 dc.w .glo-.saut	;$5a Z
 dc.w 0		;$5b [
 dc.w 0		;$5c \
 dc.w 0		;$5d ]
 dc.w 0		;$5e ^
 dc.w .glo-.saut	;$5f _

 dc.w 0		;$60 `
 dc.w .glo-.saut	;$61 a
 dc.w .glo-.saut	;$62
 dc.w .glo-.saut	;$63
 dc.w .glo-.saut	;$64
 dc.w .glo-.saut	;$65
 dc.w .glo-.saut	;$66
 dc.w .glo-.saut	;$67
 dc.w .glo-.saut	;$68
 dc.w .glo-.saut	;$69
 dc.w .glo-.saut	;$6a
 dc.w .glo-.saut	;$6b
 dc.w .glo-.saut	;$6c
 dc.w .glo-.saut	;$6d
 dc.w .glo-.saut	;$6e
 dc.w .glo-.saut	;$6f o

 dc.w .glo-.saut	;$70 p
 dc.w .glo-.saut	;$71
 dc.w .glo-.saut	;$72
 dc.w .glo-.saut	;$73
 dc.w .glo-.saut	;$74
 dc.w .glo-.saut	;$75
 dc.w .glo-.saut	;$76
 dc.w .glo-.saut	;$77
 dc.w .glo-.saut	;$78
 dc.w .glo-.saut	;$79
 dc.w .glo-.saut	;$7a z
 dc.w 0		;$7b {
 dc.w 0		;$7c |
 dc.w 0		;$7d }
 dc.w 0		;$7e ~
 dc.w 0		;$7f delta
;	 #] Skip table:
;  #] FirstEvalSkip:
;  #[ Operand jt: 1st Eval
pass1_operand_jt:
.t:	dc.w	err_unexp_end-.t	;0
	REPT	$19
	dc.w	err_illeg_char-.t	;1
	ENDR
	dc.w	_quote_string-.t	;1a TOKENQUOTE
	dc.w	err_illeg_char-.t	;1b
	dc.w	err_illeg_char-.t	;1c
	dc.w	err_illeg_char-.t	;1d
	dc.w	err_illeg_char-.t	;1e
	dc.w	err_illeg_char-.t	;1f
	dc.w	space_operand-.t	;20 SPACE
	dc.w	err_unexp_bop-.t	;21 !
	dc.w	_quote_string-.t	;22 "
	dc.w	err_illeg_char-.t	;23 #
	dc.w	_hex_string-.t	;24 $
	dc.w	_binary_string-.t	;25 %
	dc.w	err_unexp_bop-.t	;26 &
	dc.w	_quote_string-.t	;27 '
	dc.w	open_parent-.t	;28 (
	dc.w	err_unexp_par-.t	;29 )
	dc.w	u_star-.t		;2a *
	dc.w	u_plus-.t		;2b +
	dc.w	err_illeg_char-.t	;2c ,
	dc.w	u_minus-.t	;2d -
	dc.w	local_pass1-.t	;2e .
	dc.w	err_unexp_bop-.t	;2f /
	REPT	10		;30-39
	dc.w	_dec_string-.t
	ENDR
	dc.w	err_illeg_char-.t	;3a :
	dc.w	err_illeg_char-.t	;3b ;
	dc.w	err_unexp_bop-.t	;3c <
	dc.w	err_illeg_char-.t	;3d =
	dc.w	err_unexp_bop-.t	;3e >
	dc.w	var_pass1-.t	;3f ?
	dc.w	_octal_string-.t	;40 @
	REPT	'Z'-'A'+1
	dc.w	var_pass1-.t	;41-5a
	ENDR
	dc.w	err_illeg_char-.t	;5b [
	dc.w	err_illeg_char-.t	;5c \
	dc.w	err_illeg_char-.t	;5d ]
	dc.w	err_unexp_bop-.t	;5e ^
	dc.w	var_pass1-.t	;5f _
	dc.w	err_illeg_char-.t	;60 `
	REPT	'z'-'a'+1
	dc.w	var_pass1-.t	;61-7a
	ENDR
	dc.w	err_illeg_char-.t	;7b {
	dc.w	err_unexp_bop-.t	;7c |
	dc.w	err_illeg_char-.t	;7d }
	dc.w	_not-.t		;7e ~
	dc.w	err_illeg_char-.t	;7f
;  #] Operand jt:
;  #[ Operand jt: Force Eval
force_operand_jt:
.t:	dc.w	err_unexp_end-.t	;0
	REPT	$19
	dc.w	err_illeg_char-.t
	ENDR
	dc.w	_quote_string-.t	;1a TOKENQUOTE
	dc.w	err_illeg_char-.t	;1b
	dc.w	err_illeg_char-.t	;1c
	dc.w	err_illeg_char-.t	;1d
	dc.w	err_illeg_char-.t	;1e
	dc.w	err_illeg_char-.t	;1f
	dc.w	space_operand-.t	;20 SPACE
	dc.w	err_unexp_bop-.t	;21 !
	dc.w	_quote_string-.t	;22 "
	dc.w	err_illeg_char-.t	;23 #
	dc.w	_hex_string-.t	;24 $
	dc.w	_binary_string-.t	;25 %
	dc.w	err_unexp_bop-.t	;26 &
	dc.w	_quote_string-.t	;27 '
	dc.w	open_parent-.t	;28 (
	dc.w	err_unexp_par-.t	;29 )
	dc.w	force_u_star-.t	;2a *
	dc.w	u_plus-.t		;2b +
	dc.w	err_illeg_char-.t	;2c ,
	dc.w	force_u_minus-.t	;2d -
	dc.w	local_force-.t	;2e .
	dc.w	err_unexp_bop-.t	;2f /
	REPT	10
	dc.w	_dec_string-.t
	ENDR
	dc.w	err_illeg_char-.t	;3a :
	dc.w	err_illeg_char-.t	;3b ;
	dc.w	err_unexp_bop-.t	;3c <
	dc.w	err_illeg_char-.t	;3d =
	dc.w	err_unexp_bop-.t	;3e >
	dc.w	var_force-.t	;3f ?
	dc.w	_octal_string-.t	;40 @
	REPT	'Z'-'A'+1
	dc.w	var_force-.t	;41-5a
	ENDR
	dc.w	err_illeg_char-.t	;5b [
	dc.w	err_illeg_char-.t	;5c \
	dc.w	err_illeg_char-.t	;5d ]
	dc.w	err_unexp_bop-.t	;5e ^
	dc.w	var_force-.t	;5f _
	dc.w	err_illeg_char-.t	;60 `
	REPT	'z'-'a'+1
	dc.w	var_force-.t	;61-7a
	ENDR
	dc.w	err_illeg_char-.t	;7b {
	dc.w	err_unexp_bop-.t	;7c |
	dc.w	err_illeg_char-.t	;7d }
	dc.w	force_not-.t	;7e ~
	dc.w	err_illeg_char-.t	;7f
;  #] Operand jt:
;  #[ Operand jt: Local Patch
local_operand_jt:
.t:	dc.w	err_unexp_end-.t	;0
	REPT	$19
	dc.w	err_illeg_char-.t
	ENDR
	dc.w	_quote_string-.t	;1a TOKENQUOTE
	dc.w	err_illeg_char-.t	;1b
	dc.w	err_illeg_char-.t	;1c
	dc.w	err_illeg_char-.t	;1d
	dc.w	err_illeg_char-.t	;1e
	dc.w	err_illeg_char-.t	;1f
	dc.w	space_operand-.t	;20 SPACE
	dc.w	err_unexp_bop-.t	;21 !
	dc.w	_quote_string-.t	;22 "
	dc.w	err_illeg_char-.t	;23 #
	dc.w	_hex_string-.t	;24 $
	dc.w	_binary_string-.t	;25 %
	dc.w	err_unexp_bop-.t	;26 &
	dc.w	_quote_string-.t	;27 '
	dc.w	open_parent-.t	;28 (
	dc.w	err_unexp_par-.t	;29 )
	dc.w	local_u_star-.t	;2a *
	dc.w	u_plus-.t		;2b +
	dc.w	err_illeg_char-.t	;2c ,
	dc.w	local_u_minus-.t	;2d -
	dc.w	local_locpatch-.t	;2e .
	dc.w	err_unexp_bop-.t	;2f /
	REPT	10
	dc.w	_dec_string-.t	;30 0
	ENDR
	dc.w	err_illeg_char-.t	;3a :
	dc.w	err_illeg_char-.t	;3b ;
	dc.w	err_unexp_bop-.t	;3c <
	dc.w	err_illeg_char-.t	;3d =
	dc.w	err_unexp_bop-.t	;3e >
	dc.w	var_locpatch-.t	;3f ?
	dc.w	_octal_string-.t	;40 @
	REPT	'Z'-'A'+1
	dc.w	var_locpatch-.t	;41-5a
	ENDR
	dc.w	err_illeg_char-.t	;5b [
	dc.w	err_illeg_char-.t	;5c \
	dc.w	err_illeg_char-.t	;5d ]
	dc.w	err_unexp_bop-.t	;5e ^
	dc.w	var_locpatch-.t	;5f _
	dc.w	err_illeg_char-.t	;60 `
	REPT	'z'-'a'+1
	dc.w	var_locpatch-.t	;61-7a
	ENDR
	dc.w	err_illeg_char-.t	;7b {
	dc.w	err_unexp_bop-.t	;7c |
	dc.w	err_illeg_char-.t	;7d }
	dc.w	local_not-.t	;7e ~
	dc.w	err_illeg_char-.t	;7f
;  #] Operand jt:
;  #[ Operand jt: Global Patch
glob_operand_jt:
.t:	dc.w	err_unexp_end-.t	;0
	REPT	$19
	dc.w	err_illeg_char-.t	;1
	ENDR
	dc.w	_quote_string-.t	;1a TOKENQUOTE
	dc.w	err_illeg_char-.t	;1b
	dc.w	err_illeg_char-.t	;1c
	dc.w	err_illeg_char-.t	;1d
	dc.w	err_illeg_char-.t	;1e
	dc.w	err_illeg_char-.t	;1f
	dc.w	space_operand-.t	;20 SPACE
	dc.w	err_unexp_bop-.t	;21 !
	dc.w	_quote_string-.t	;22 "
	dc.w	err_illeg_char-.t	;23 #
	dc.w	_hex_string-.t	;24 $
	dc.w	_binary_string-.t	;25 %
	dc.w	err_unexp_bop-.t	;26 &
	dc.w	_quote_string-.t	;27 '
	dc.w	open_parent-.t	;28 (
	dc.w	err_unexp_par-.t	;29 )
	dc.w	global_set-.t	;2a *
	dc.w	u_plus-.t		;2b +
	dc.w	err_illeg_char-.t	;2c ,
	dc.w	glob_u_minus-.t	;2d -
	dc.w	local_globpatch-.t	;2e .
	dc.w	err_unexp_bop-.t	;2f /
	REPT	10
	dc.w	_dec_string-.t
	ENDR
	dc.w	err_illeg_char-.t	;3a :
	dc.w	err_illeg_char-.t	;3b ;
	dc.w	err_unexp_bop-.t	;3c <
	dc.w	err_illeg_char-.t	;3d =
	dc.w	err_unexp_bop-.t	;3e >
	dc.w	var_globpatch-.t	;3f ?
	dc.w	_octal_string-.t	;40 @
	REPT	'Z'-'A'+1
	dc.w	var_globpatch-.t	;41-5a
	ENDR
	dc.w	err_illeg_char-.t	;5b [
	dc.w	err_illeg_char-.t	;5c \
	dc.w	err_illeg_char-.t	;5d ]
	dc.w	err_unexp_bop-.t	;5e ^
	dc.w	var_globpatch-.t	;5f _
	dc.w	err_illeg_char-.t	;60 `
	REPT	'z'-'a'+1
	dc.w	var_globpatch-.t	;61-7a
	ENDR
	dc.w	err_illeg_char-.t	;7b {
	dc.w	err_unexp_bop-.t	;7c |
	dc.w	err_illeg_char-.t	;7d }
	dc.w	glob_not-.t	;7e ~
	dc.w	err_illeg_char-.t	;7f
;  #] Operand jt:
;  #[ Operand jt: Opti Eval
opti_operand_jt:
.t:	dc.w	err_unexp_end-.t	;0
	REPT	$19
	dc.w	err_illeg_char-.t	;1
	ENDR
	dc.w	_quote_string-.t	;1a TOKENQUOTE
	dc.w	err_illeg_char-.t	;1b
	dc.w	err_illeg_char-.t	;1c
	dc.w	err_illeg_char-.t	;1d
	dc.w	err_illeg_char-.t	;1e
	dc.w	err_illeg_char-.t	;1f
	dc.w	space_operand-.t	;20 SPACE
	dc.w	err_unexp_bop-.t	;21 !
	dc.w	_quote_string-.t	;22 "
	dc.w	err_illeg_char-.t	;23 #
	dc.w	_hex_string-.t	;24 $
	dc.w	_binary_string-.t	;25 %
	dc.w	err_unexp_bop-.t	;26 &
	dc.w	_quote_string-.t	;27 '
	dc.w	open_parent-.t	;28 (
	dc.w	err_unexp_par-.t	;29 )
	dc.w	opti_u_star-.t	;2a *
	dc.w	u_plus-.t		;2b +
	dc.w	err_illeg_char-.t	;2c ,
	dc.w	opti_u_minus-.t	;2d -
	dc.w	local_opti-.t	;2e .
	dc.w	err_unexp_bop-.t	;2f /
	REPT	10		;30-39
	dc.w	_dec_string-.t
	ENDR
	dc.w	err_illeg_char-.t	;3a :
	dc.w	err_illeg_char-.t	;3b ;
	dc.w	err_unexp_bop-.t	;3c <
	dc.w	err_illeg_char-.t	;3d =
	dc.w	err_unexp_bop-.t	;3e >
	dc.w	var_opti-.t	;3f ?
	dc.w	_octal_string-.t	;40 @
	REPT	'Z'-'A'+1
	dc.w	var_opti-.t	;41-5a
	ENDR
	dc.w	err_illeg_char-.t	;5b [
	dc.w	err_illeg_char-.t	;5c \
	dc.w	err_illeg_char-.t	;5d ]
	dc.w	err_unexp_bop-.t	;5e ^
	dc.w	var_opti-.t	;5f _
	dc.w	err_illeg_char-.t	;60 `
	REPT	'z'-'a'+1
	dc.w	var_opti-.t	;61-7a
	ENDR
	dc.w	err_illeg_char-.t	;7b {
	dc.w	err_unexp_bop-.t	;7c |
	dc.w	err_illeg_char-.t	;7d }
	dc.w	opti_not-.t	;7e ~
	dc.w	err_illeg_char-.t	;7f
;  #] Operand jt:

;  #[ Operator jt: 1st Eval - No type checking
numonly_operator_jt:
.t:	dc.w	_end-.t	;0
	REPT	$19
	dc.w	err_illeg_char-.t	;1
	ENDR
	dc.w	err_bop_expected-.t	;1a TOKENQUOTE
	dc.w	err_illeg_char-.t	;1b
	dc.w	err_illeg_char-.t	;1c
	dc.w	err_illeg_char-.t	;1d
	dc.w	err_illeg_char-.t	;1e
	dc.w	err_illeg_char-.t	;1f
	dc.w	space_operator-.t	;20 SPACE
	dc.w	_or-.t		;21 !
	dc.w	err_bop_expected-.t	;22 "
	dc.w	err_illeg_char-.t	;23 #
	dc.w	dollar_op-.t	;24 $
	dc.w	err_bop_expected-.t	;25 %
	dc.w	_and-.t		;26 &
	dc.w	err_bop_expected-.t	;27 '
	dc.w	err_bop_expected-.t	;28 (
	dc.w	close_parent-.t	;29 )
	dc.w	_mul-.t		;2a *
	dc.w	_plus-.t		;2b +
	dc.w	_next_arg-.t	;2c ,
	dc.w	_minus-.t		;2d -
	dc.w	err_bop_expected-.t	;2e .
	dc.w	_div-.t		;2f /
	REPT	10	
	dc.w	err_bop_expected-.t	;30-39
	ENDR
	dc.w	err_illeg_char-.t	;3a :
	dc.w	err_illeg_char-.t	;3b ;
	dc.w	_shift_left-.t	;3c <
	dc.w	_equal-.t		;3d =
	dc.w	_shift_right-.t	;3e >
	dc.w	err_illeg_char-.t	;3f ?
	dc.w	err_bop_expected-.t	;40 @
	REPT	'Z'-'A'+1
	dc.w	err_bop_expected-.t	;41-5a
	ENDR
	dc.w	err_illeg_char-.t	;5b [
	dc.w	err_bop_expected-.t	;5c \
	dc.w	err_illeg_char-.t	;5d ]
	dc.w	_eor-.t		;5e ^
	dc.w	err_bop_expected-.t	;5f _
	dc.w	err_illeg_char-.t	;60 `
	REPT	'z'-'a'+1
	dc.w	err_bop_expected-.t	;61-7a
	ENDR
	dc.w	err_illeg_char-.t	;7b {
	dc.w	_or-.t		;7c |
	dc.w	err_illeg_char-.t	;7d }
	dc.w	err_bop_expected-.t	;7e ~
	dc.w	err_illeg_char-.t	;7f
;  #] Operator jt:
;  #[ Operator jt: glo+loc+force - type checking
type_operator_jt:
.t:	dc.w	_end-.t	;0
	REPT	$19
	dc.w	err_illeg_char-.t
	ENDR
	dc.w	err_bop_expected-.t	;1a TOKENQUOTE
	dc.w	err_illeg_char-.t	;1b
	dc.w	err_illeg_char-.t	;1c
	dc.w	err_illeg_char-.t	;1d
	dc.w	err_illeg_char-.t	;1e
	dc.w	err_illeg_char-.t	;1f
	dc.w	space_operator-.t	;20 SPACE
	dc.w	t_or-.t		;21 !
	dc.w	err_bop_expected-.t	;22 "
	dc.w	err_illeg_char-.t	;23 #
	dc.w	t_dollar_op-.t	;24 $
	dc.w	err_bop_expected-.t	;25 %
	dc.w	t_and-.t		;26 &
	dc.w	err_bop_expected-.t	;27 '
	dc.w	err_bop_expected-.t	;28 (
	dc.w	close_parent-.t	;29 )
	dc.w	t_mul-.t		;2a *
	dc.w	t_plus-.t		;2b +
	dc.w	_next_arg-.t	;2c ,
	dc.w	t_minus-.t	;2d -
	dc.w	err_bop_expected-.t	;2e .
	dc.w	t_div-.t		;2f /
	REPT	10
	dc.w	err_bop_expected-.t
	ENDR
	dc.w	err_illeg_char-.t	;3a :
	dc.w	err_illeg_char-.t	;3b ;
	dc.w	t_sft_left-.t	;3c <
	dc.w	t_equal-.t	;3d =
	dc.w	t_sft_right-.t	;3e >
	dc.w	err_illeg_char-.t	;3f ?
	dc.w	err_bop_expected-.t	;40 @
	REPT	'Z'-'A'+1
	dc.w	err_bop_expected-.t	;41-5a
	ENDR
	dc.w	err_illeg_char-.t	;5b [
	dc.w	err_bop_expected-.t	;5c \
	dc.w	err_illeg_char-.t	;5d ]
	dc.w	t_eor-.t	;5e ^
	dc.w	err_bop_expected-.t	;5f _
	dc.w	err_illeg_char-.t	;60 `
	REPT	'z'-'a'+1
	dc.w	err_bop_expected-.t	;61-7a
	ENDR
	dc.w	err_illeg_char-.t	;7b {
	dc.w	t_or-.t		;7c |
	dc.w	err_illeg_char-.t	;7d }
	dc.w	err_bop_expected-.t	;7e ~
	dc.w	err_illeg_char-.t	;7f
;  #] Operator jt:
;  #[ Operator jt: opti eval - type checking
opti_operator_jt:
.t:	dc.w	_end-.t	;0
	REPT	$19
	dc.w	err_illeg_char-.t
	ENDR
	dc.w	err_bop_expected-.t	;1a TOKENQUOTE
	dc.w	err_illeg_char-.t	;1b
	dc.w	err_illeg_char-.t	;1c
	dc.w	err_illeg_char-.t	;1d
	dc.w	err_illeg_char-.t	;1e
	dc.w	err_illeg_char-.t	;1f
	dc.w	space_operator-.t	;20 SPACE
	dc.w	t_or-.t		;21 !
	dc.w	err_bop_expected-.t	;22 "
	dc.w	err_illeg_char-.t	;23 #
	dc.w	opti_dollar_op-.t	;24 $
	dc.w	err_bop_expected-.t	;25 %
	dc.w	t_and-.t		;26 &
	dc.w	err_bop_expected-.t	;27 '
	dc.w	err_bop_expected-.t	;28 (
	dc.w	close_parent-.t	;29 )
	dc.w	t_mul-.t		;2a *
	dc.w	t_plus-.t		;2b +
	dc.w	_next_arg-.t	;2c ,
	dc.w	t_minus-.t	;2d -
	dc.w	err_bop_expected-.t	;2e .
	dc.w	t_div-.t		;2f /
	REPT	10
	dc.w	err_bop_expected-.t
	ENDR
	dc.w	err_illeg_char-.t	;3a :
	dc.w	err_illeg_char-.t	;3b ;
	dc.w	t_sft_left-.t	;3c <
	dc.w	t_equal-.t	;3d =
	dc.w	t_sft_right-.t	;3e >
	dc.w	err_illeg_char-.t	;3f ?
	dc.w	err_bop_expected-.t	;40 @
	REPT	'Z'-'A'+1
	dc.w	err_bop_expected-.t	;41-5a
	ENDR
	dc.w	err_illeg_char-.t	;5b [
	dc.w	err_bop_expected-.t	;5c \
	dc.w	err_illeg_char-.t	;5d ]
	dc.w	t_eor-.t	;5e ^
	dc.w	err_bop_expected-.t	;5f _
	dc.w	err_illeg_char-.t	;60 `
	REPT	'z'-'a'+1
	dc.w	err_bop_expected-.t	;61-7a
	ENDR
	dc.w	err_illeg_char-.t	;7b {
	dc.w	t_or-.t		;7c |
	dc.w	err_illeg_char-.t	;7d }
	dc.w	err_bop_expected-.t	;7e ~
	dc.w	err_illeg_char-.t	;7f
;  #] Operator jt:
;  #[ Operators tab:
;0:non operateur
operators_tab:
	REPT	$21
	dc.b	0
	ENDR
	dc.b -1	;$21 !
	dc.b 0	;$22 "
	dc.b -1	;$23 #
	dc.b 0	;$24 $
	dc.b 0	;$25 %
	dc.b -1	;$26 &
	dc.b 0	;$27 '
	dc.b -1	;$28 (
	dc.b 0	;$29 )
	dc.b -1	;$2a *
	dc.b -1	;$2b +
	dc.b -1	;$2c ,
	dc.b -1	;$2d -
	dc.b 0	;$2e .
	dc.b -1	;$2f /
	REPT	10	;les chiffres
	dc.b 0
	ENDR
	dc.b 0	;$3a :
	dc.b 0	;$3b ;
	dc.b -1	;$3c <
	dc.b -1	;$3d =
	dc.b -1	;$3e >
	dc.b 0	;$3f ?
	dc.b 0	;$40 @
	REPT	26
	dc.b	0	;les majuscules
	ENDR
	dc.b 0	;$5b [
	dc.b 0	;$5c \
	dc.b 0	;$5d ]
	dc.b -1	;$5e ^
	dc.b 0	;$5f _
	dc.b 0	;$60 `
	REPT	26
	dc.b	0	;les minuscules
	ENDR
	dc.b 0	;$7b {
	dc.b -1	;$7c |
	dc.b 0	;$7d }
	dc.b -1	;$7e ~
	dc.b 0	;$7f delta
	even
;  #] Operators tab:

;  #[ Memory allocation:
;In d0.L=size
LValAlloc:
	movem.l	d1/a0-a1,-(sp)
	move.l	d0,d1
	move.l	ValMemCur,d0
	move.l	d0,a0
	beq.s	.alloc
.got:	move.l	MEMBLOCK_cur(a0),a1
	add.l	d1,a1
	cmp.l	MEMBLOCK_end(a0),a1
	bhi.s	.alloc
	move.l	MEMBLOCK_cur(a0),d0
	add.l	d1,MEMBLOCK_cur(a0)
.end:	movem.l	(sp)+,d1/a0-a1
	rts
.alloc:	move.l	a0,a1
	move.l	#VALMEMSPACE+MEMBLOCK_SIZEOF,d0
	jsr	MyMalloc
	move.l	d0,ValMemCur
	beq.s	.end
	move.l	d0,a0
	move.l	a1,d0	;prev
	beq.s	.fst
	move.l	a0,MEMBLOCK_next(a1)	;link
.l1:	lea	MEMBLOCK_SIZEOF(a0),a1
	move.l	a1,MEMBLOCK_cur(a0)
	lea	VALMEMSPACE(a1),a1
	move.l	a1,MEMBLOCK_end(a0)
	clr.l	MEMBLOCK_next(a0)
	bra.s	.got
.fst:	move.l	a0,ValMemHead
	bra.s	.l1

FreeEval:	movem.l	d0-d1/a0,-(sp)
	move.l	ValMemHead,d1
	beq.s	.end
.nx:	move.l	d1,a0
	move.l	MEMBLOCK_next(a0),d1
;	move.l	#VALMEMSPACE+MEMBLOCK_SIZEOF,d0
	jsr	MyMfree
	tst.l	d1
	bne.s	.nx
.end:	movem.l	(sp)+,d0-d1/a0
	rts
;  #] Memory allocation:
;  #[ Errors:
err_fonc_args:
	moveq	#EVAL_NBARGS,d1
	bra.s	err_exit
err_fonc_nf:
	moveq	#EVAL_NFFUNC,d1
	bra.s	err_exit
err_neg_shift:
	moveq	#EVAL_NEGSFT,d1
	bra.s	err_exit
err_set_forward:
	moveq	#EVAL_FW_SET,d1
	bra.s	err_exit
err_num2big:
	moveq	#EVAL_LNUM,d1
	bra.s	err_exit
err_bad_hexa:
	moveq	#EVAL_SYNTAX,d1
	bra.s	err_exit
err_unexp_bop:
	moveq	#EVAL_BOPUNEXP,d1
	bra.s	err_exit
err_bop_expected:
	moveq	#EVAL_BOPEXP,d1
	bra.s	err_exit
err_illeg_char:
	moveq	#EVAL_SYNTAX,d1
	bra.s	err_exit
err_unexp_end:
	moveq	#EVAL_EOE,d1
	bra.s	err_exit
err_matching:
	moveq	#EVAL_MATCH,d1
	bra.s	err_exit
err_unexp_par:
	moveq	#EVAL_PARUNEXP,d1
	bra.s	err_exit
err_zero_divide:
	moveq	#EVAL_DIV0,d1
	bra.s	err_exit
err_overflow:
	moveq	#EVAL_OVERFLOW,d1
	bra.s	err_exit
err_str2long:
	moveq	#EVAL_LSTR,d1
	bra.s	err_exit
err_nomem:
	moveq	#EVAL_MEM,d1
	bra.s	err_exit
err_equr:
	moveq	#EVAL_COMPEQUR,d1
	bra.s	err_exit
err_varchar:
	moveq	#EVAL_SYNTAX,d1
	bra.s	err_exit
err_local_nf:
	moveq	#EVAL_NFVAR,d1
	bra.s	err_exit
err_var_nf:
	moveq	#EVAL_NFVAR,d1
	bra.s	err_exit
err_operr:
	moveq	#EVAL_OPERR,d1
	bra.s	err_exit
err_type:	moveq	#EVAL_TYPE,d1
	bra.s	err_exit
err_must_eval:
	moveq	#EVAL_MUSTEVAL,d1
;	bra.s	err_exit
err_exit:
	clr.l	ParNestCnt	;+FoncNestCnt
	move.l	START_STACK,sp
	moveq	#0,d0
	move.l	_a0_buf,EvalErrP
	subq.w	#1,a0
	move.l	a0,_a0_buf		;ecraser A0 du movem
	POPEVAL
	move.l	d1,EvalErrN
	rts
;  #] Errors:
;  #[ Table des fonctions entieres:
intg_foncs_table:	;size,args #,@name-foncs_table,@fonc,@arg eval fonc
.t:	;swap
	dc.b	4,1
	dc.w	.swap-.t
	dc.l	_fonc_swap
	dc.l	Eval
	;sizeof
	dc.b	6,1
	dc.w	.sizeof-.t
	dc.l	_fonc_sizeof
	dc.l	_arg_sizeof_eval
FONCS_NB	EQU	(*-.t)/FS_SIZEOF
.swap:	dc.b	"swap"
.sizeof:	dc.b	"sizeof"
	even
;  #] Table des fonctions entieres:
	BSS
;  #[ Bss:
_regsbuf:	ds.l	5	;d3-d7
_a0_buf:	ds.l	1	;a0
	ds.l	5	;a1-a4/a6
_val_table:	ds.b	128*LOCSTACK_SIZEOF
	even
;1 LONG pour les flags
_global_found:	ds.b	1
_local_found:	ds.b	1
_setcnt:		ds.w	1
_loc_list:	ds.l	1
;ParNestCnt et FoncNestCnt doivent etre consecutifs
ParNestCnt:	ds.w	1
FoncNestCnt:	ds.w	1
EvalErrP:	ds.l	1
EvalErrN:	ds.l	1
ValMemCur:	ds.l	1
ValMemHead:	ds.l	1
;  #] Bss:
	END

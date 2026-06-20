;	include	"comequ.s"
;	XDEF	GetEa
;	XREF	Evaluate,GetEqur,GetEqur3

D8MEMMODE	EQU	(MEM_MODE<<8)|_D8ANXN_MODE
D8PCMODE	EQU	(PC_MODE<<8)|_D8PCXN_MODE

BDMEMMODE	EQU	(MEM_MODE<<8)|_BDANXN_MODE
BDPCMODE	EQU	(PC_MODE<<8)|_BDPCXN_MODE
BDZPCMODE	EQU	(PC_MODE<<8)|_BDZPCXN_MODE

ZXNREG	EQU	$ff
ZANZXNREG	EQU	$ffff
PCZXNREG	EQU	(BDPCXN_REG<<8)|ZXNREG
ZPCZXNREG	EQU	(BDPCXN_REG<<8)|ZXNREG

BDPCZXNMODE	EQU	(PCZXNREG<<16)|BDPCMODE
BDZANZXNMODE	EQU	(ZANZXNREG<<16)|BDMEMMODE
BDZPCZXNMODE	EQU	(ZPCZXNREG<<16)|BDZPCMODE

;!! changer bra Opti_ si plus rts !!
EA_END	MACRO
	rts
	ENDM

ZSZZSC	MACRO
	clr.w	EA_xnsz(EAPTR)		;;XNW_SZ+scale1=W*1
	ENDM

EAJMP	MACRO
.space:	moveq	#0,\1
	move.b	-(a0),\1
	IFNE	EABLINDOS
	bmi.s	.rea
	ENDC
	IFNE	_68000
	add.w	\1,\1
	move.w	.t(pc,\1.w),d1
	jmp	.t(pc,d1.w)
	ELSEIF
	move.w	.t(pc,\1*2),d1
	jmp	.t(pc,d1.w)
	ENDC	;;_68000
	IFNE	EABLINDOS
.rea:	_Debugger
	ENDC	;;EABLINDOS
	ENDM

;  #[ GetEA:
GetEa:	move.b	(FIELDPTR),d0
	bmi.s	.rempt
	cmp.b	#TOKENA0,d0		;Dn=000
	blt.s	.dn
	cmp.b	#TOKENA7,d0		;An=001
	bls.s	.an
	cmp.b	#'#',d0
	beq.s	.im
	move.l	LINE_tokend(FIELDPTR),a0
	EAJMP	d1
.rempt:	bra	Errea_exp
.reoo:	lea	1(FIELDPTR),a0		;errp
	bra	Erreoo_exp
.dn:	tst.b	1(FIELDPTR)		;EOL
	bpl.s	.reoo
.asdn:	clr.b	EA_mode(EAPTR)		;DN_MODE
	move.b	d0,EA_an(EAPTR)
	EA_END
.an:	tst.b	1(FIELDPTR)		;EOL
	bpl.s	.reoo
.asan:	move.b	#AN_MODE,EA_mode(EAPTR)
	subq.b	#TOKENA0,d0
	move.b	d0,EA_an(EAPTR)
	EA_END
.im:	bra	EAIm
.t:	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.cpar-.t,.alph-.t,.plus-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.rb:	bra	Errb_forb
.word:	move.b	#ABS_WORD_REG,EA_an(EAPTR);abs.w
	bra.s	.abs
.long:	move.b	#ABS_LONG_REG,EA_an(EAPTR);abs.l
.abs:	st	(a0)			;viros size
	move.l	FIELDPTR,a0
	EAEVAL
	bmi.s	.revabs
	move.b	#ABS_MODE,EA_mode(EAPTR)
	EA_END
.alph:	move.l	FIELDPTR,a0		;abs,eqr
	EAEVAL
	ble.s	.eqr?
.expabs:	move.b	#ABS_MODE,EA_mode(EAPTR)	;111.000,111.001
	move.b	#ABS_LONG_REG,EA_an(EAPTR)
	EA_END
.eqr?:	beq.s	.relabs
	cmp.b	#EVAL_EQUR,d1
	bne.s	.revabs
	cmp.b	#TOKEND7,d0
	bls	.asdn
	cmp.b	#TOKENA7,d0
	bls	.asan
	bra.s	.rinp
.revabs:	bra	ErrEv_abs
.relabs:	move.b	#ABS_MODE,EA_mode(EAPTR)
	tst.w	OptiLAbs2WFlg
	beq.s	.labs
	move.l	#32767,d1
	cmp.l	d1,d0
	bgt.s	.labs
	not.l	d1			;->-32768
	cmp.l	d1,d0
	blt.s	.labs
	move.b	#ABS_WORD_REG,EA_an(EAPTR)
	bra	Opti_labs2w		;EA_END
.labs:	move.b	#ABS_LONG_REG,EA_an(EAPTR)
	EA_END
.plus:	cmp.b	#')',-(a0)		;(An)+
	bne.s	.rinp
	move.b	-(a0),d0
	cmp.b	#LASTTOKEN,d0
	bhi.s	.eqplus
.anplus:	subq.b	#TOKENA0,d0
	bmi.s	.ran
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.ran
	move.b	d0,EA_an(EAPTR)
	move.b	#ANPOST_MODE,EA_mode(EAPTR)
	EA_END
.rinp:	bra	Errcant_input
.eqplus:	st	1(a0)
	lea	1(FIELDPTR),a0
	jsr	GetEqur
	bpl.s	.anplus
.ran:	bra	Erran_exp

.pre:	lea	2(FIELDPTR),a1
	move.b	(a1)+,d0
	cmp.b	#LASTTOKEN,d0
	bhi.s	.eqrpre
	cmp.l	a0,a1
	bne.s	.rinp
.asprean:	subq.b	#TOKENA0,d0
	bmi.s	.ran
	cmp.b	#TOKENA7,d0
	bhi.s	.ran
	move.b	d0,EA_an(EAPTR)
	move.b	#ANPRE_MODE,EA_mode(EAPTR)
	EA_END

.eqrpre:	st	(a0)
	lea	-1(a1),a0
	jsr	GetEqur
	bpl.s	.asprean
	bra.s	.ran

.asabs:	move.l	FIELDPTR,a0
	EAEVAL
	bmi	.revabs
	beq	.relabs
	bra	.expabs

.cpar:	subq.w	#1,LINE_par0nb(FIELDPTR)	;marginal
	bne.s	.d8d16			;(d8/d16)(*)
	cmp.w	#'-(',(FIELDPTR)		;-(*)
	beq.s	.pre
	cmp.b	#'(',d0
	beq	EAPar			;nomal
;	tst.w	LINE_eval(FIELDPTR)
;	bne.s	.asabs
.d8d16:	bra.s	EAd8d16			;nomal

;  #] GetEA:
;  #[ EAIm:	#i
EAIm:	move.b	#IMMEDIATE_MODE,EA_mode(EAPTR)
	move.b	#IMMEDIATE_REG,EA_an(EAPTR)
	lea	1(FIELDPTR),a0
	EAEVAL
	bmi.s	.reval
	EA_END
.reval:	bra	ErrEv_immed
;  #] EAIm:
;  #[ EAd8d16:	*(*)=d8PnXn,d16Pn=d8(PnEqur),d8(PnEqur*?),d16(Equr)
EAd8d16:		;In:a1 on ')',Out: a1 on '(' + 1
	EAJMP	d0

.t:	dc.w	.d?xn-.t,.d?xn-.t,.d?xn-.t,.d?xn-.t,.d?xn-.t,.d?xn-.t,.d?xn-.t,.d?xn-.t
	dc.w	.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.sca1-.t,.sca2-.t,.sca4-.t,.sca8-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.d16pc-.t,.rinp-.t,.rinp-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.rb:	bra	Errb_forb

.rxnsz:	bra	Errxnorsz_exp
.rinp:	bra	Errcant_input

.sca1:	;pas gerer equr*scale
.sca2:
.sca4:
.sca8:
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	sub.b	#TOKENSC1,d0
	move.b	d0,EA_xnsc(EAPTR)
	move.b	-(a0),d0
	cmp.b	#TOKENW,d0
	beq.s	.wsc
	cmp.b	#TOKENL,d0
	beq.s	.lsc
	clr.b	EA_xnsz(EAPTR)
	bra.s	.asc
.wsc:	clr.b	EA_xnsz(EAPTR)		;XNW_SZ
	bra.s	.sz
.lsc:	move.b	#XNL_SZ,EA_xnsz(EAPTR)
	bra.s	.sz

.d8eqrsz:	moveq	#',',d0			;d8?EqrSz
	jsr	GetEqur3
	bmi.s	.rinp
	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
	move.b	d0,EA_xn(EAPTR)		;Xn
	bra	.asd?xn2

.word:	ZSZZSC
	bra.s	.sz
.long:	move.w	#XNL_SZ<<8,EA_xnsz(EAPTR)	;+scale=*1
.sz:	move.b	-(a0),d0
.asc:	cmp.b	#LASTTOKEN,d0
	bhi.s	.d8eqrsz
	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
	move.b	d0,EA_xn(EAPTR)		;Xn
	bra.s	.asd?xn

.d8eqrdn:	moveq	#'(',d0
	jsr	GetEqur3
	bmi.s	.rinp
	bra.s	.asan2

.d16an:
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	cmp.b	#'(',-(a0)
	bne.s	.ropar2
	subq.b	#TOKENA0,d0
.asd16an:	move.b	d0,EA_an(EAPTR)		;An
	move.b	#D16AN_MODE,EA_mode(EAPTR)
	SETEOL	(a0)
	move.l	FIELDPTR,a0
	EAWEVAL
	bne.s	.revd16?
	tst.w	OptiZD16Flg
	beq.s	.noz
	tst.w	d0
	bne.s	.noz
	move.b	#ANINDIR_MODE,EA_mode(EAPTR)	;0(An)->(An)
	bsr	Opti_zd16
.noz:
.end:	EA_END
.revd16?:	bgt.s	.end
	bra	ErrEv_d16
;.noz:	tst.w	OptiLD162LBdFlg
;	beq.s	.end
;	tst.b	d2

.ropar2:	bra	Erropar_exp
.rxn:	bra	Errxn_exp

.an:	tst.w	LINE_parnb(FIELDPTR)	;d8PnAn,d16An
	beq.s	.d16an

.d?xn:	ZSZZSC
	IFNE	_68000
	move.b	(a0),EA_xn(EAPTR)		;Xn
	ELSEIF
	move.b	d0,EA_xn(EAPTR)		;Xn
	ENDC	;_68000
.asd?xn:	cmp.b	#',',-(a0)		;,
	bne.s	.rcomma
.asd?xn2:	move.b	-(a0),d0			;Pn
	cmp.b	#LASTTOKEN,d0
	bhi.s	.d8eqrdn
	cmp.b	#'(',-(a0)
	bne.s	.ropar
.asan2:	cmp.b	#TOKENPC,d0		;PC
	beq.s	.d8pcdn
	subq.b	#TOKENA0,d0		;An
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.rpn
	move.b	d0,EA_an(EAPTR)
	move.w	#D8MEMMODE,EA_mode(EAPTR)
	SETEOL	(a0)
	move.l	FIELDPTR,a0
	EAWEVAL
	bmi.s	.revd8
	moveq	#-128,d1
	cmp.l	d1,d0
	blt.s	.rmb
	not.l	d1
	cmp.l	d1,d0
	bgt.s	.rpb
	EA_END
.revd8:	bra	ErrEv_d8
.rmb:
.rpb:	bra	Errd8_ge

.d8pcdn:	move.b	#D8PCXN_REG,EA_an(EAPTR)
	move.w	#D8PCMODE,EA_mode(EAPTR)
	bra.s	.pceval

.ropar:	bra	Erropar_exp
.rcomma:	bra	Errcomma_exp
.rdn:	bra	Errdn_forb
.rpn:	bra	Errpn_exp

.d8?eqr:	ZSZZSC
	bra	.d8eqrsz

.alph:	tst.w	LINE_parnb(FIELDPTR)	;d8PnEqr,d16Eqr
	bne.s	.d8?eqr
	moveq	#'(',d0
	jsr	GetEqur3			;d16Eqr
	bmi	.rinp
	cmp.b	#TOKENPC,d0
	beq.s	.asd16pc
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.rpn
	bra	.asd16an

.d16pc:	cmp.b	#'(',-(a0)
	bne.s	.ropar
.asd16pc:	move.b	#D16PC_MODE,EA_mode(EAPTR)
	move.b	#D16PC_REG,EA_an(EAPTR)
;	bra.s	.pceval
.pceval:	SETEOL	(a0)
	move.l	FIELDPTR,a0
	EALEVAL
	ble.s	.revpd16
	EA_END
.revpd16:	bra	ErrEv_d16

;  #] EAd8d16:
;  #[ EAPar:	(*),([*)
EAPar:	lea	1(FIELDPTR),a1		;skip (
	cmp.b	#'[',(a1)
	beq	EABra
	clr.b	EA_odsz(EAPTR)		;Zod
					;a0=end @,a1=start @
	move.w	LINE_parnb(FIELDPTR),d0	;commas #
;keep tight
	 ;#[ EAGetPar:	(*)		;In:a0=end @,a1=start @
	beq	EAPar0
	subq.w	#1,d0
	beq	EAPar11
	 ;#] EAGetPar:
;keep tight
	 ;#[ EAPar2:	bdPnXn
EAPar2:
	EAJMP	d0
.t:	dc.w	.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t
	dc.w	.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.sc1-.t,.sc2-.t,.sc4-.t,.sc8-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.rb:	bra	Errb_forb

.rxnsz:	bra	Errxnorsz_exp

.sc1:	;pas gerer equr*scale
.sc2:
.sc4:
.sc8:
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	sub.b	#TOKENSC1,d0
	move.b	d0,EA_xnsc(EAPTR)		;Sc
	move.b	-(a0),d0
	cmp.b	#TOKENL,d0
	beq.s	.lsc
	clr.b	EA_xnsz(EAPTR)		;XNW_SZ
	cmp.b	#TOKENW,d0
	beq.s	.asz
	bra.s	.asc
.lsc:	move.b	#XNL_SZ,EA_xnsz(EAPTR)
	bra.s	.asz

.alph:	ZSZZSC
.eqrsz:	moveq	#',',d0
	jsr	GetEqur3			;d8?EqrSz
	bmi.s	.rinp
	bra.s	.asxn

.word:	ZSZZSC
	bra.s	.asz
.long:	move.w	#XNL_SZ<<8,EA_xnsz(EAPTR)	;+scale=*1
.asz:	move.b	-(a0),d0
.asc:	cmp.b	#LASTTOKEN,d0
	bhi.s	.eqrsz

.asxn:	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
	move.b	d0,EA_xn(EAPTR)		;Xn
	bra.s	.axn

.eqrxn:	moveq	#',',d0
	jsr	GetEqur3
	bmi.s	.rinp
	addq.w	#1,a0			;quick patch BAL
	bra.s	.asxn2

.rxn:	bra	Errxn_exp
.rinp:	bra	Errcant_input
.rcomma:	bra	Errcomma_exp

.an:
.dn:	ZSZZSC
	IFNE	_68000
	move.b	(a0),EA_xn(EAPTR)		;Xn
	ELSEIF
	move.b	d0,EA_xn(EAPTR)		;Xn
	ENDC	;_68000
.axn:	cmp.b	#',',-(a0)		;,
	bne.s	.rcomma
	move.b	-(a0),d0			;Pn
	cmp.b	#LASTTOKEN,d0
	bhi.s	.eqrxn
.asxn2:	cmp.b	#',',-(a0)
	bne.s	.rcomma
	cmp.b	#TOKENA7,d0
	bls.s	.isan
	cmp.b	#TOKENPC,d0		;PC
	beq	.pcxn
	cmp.b	#TOKENZAN,d0		;PC
	beq.s	.zanxn
	cmp.b	#TOKENZPC,d0		;PC
	beq	.zpcxn
.rpn:	bra	Erran_exp

.rdn:	bra	Errdn_forb

.zanxn:	moveq	#-1,d0			;ZAn
	bra.s	.asan

.isan:	subq.b	#TOKENA0,d0		;An
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.rpn

.asan:	move.b	d0,EA_an(EAPTR)
	move.w	#BDMEMMODE,EA_mode(EAPTR)
	move.b	-(a0),d0
	sub.b	#TOKENW,d0
	ble.s	.wbd
	subq.b	#TOKENL-TOKENW,d0
	beq	.lbd
	SETEOL	1(a0)
	move.l	a1,a0
	EALEVAL
	bmi.s	.revbd
	bne	.aslbd
	tst.w	OptiBdFlg
	beq.s	.aslbd
	moveq	#127,d1
	tst.b	d2
	bne.s	.moins
	tst.b	EA_an(EAPTR)
	bmi.s	.nobbdp
	cmp.l	d1,d0
	bhi.s	.nobbdp
	bra.s	.optib
.nobbdp:	tst.l	d0
	beq.s	.zbd
	move.w	#$7fff,d1
	cmp.l	d1,d0
	bhi.s	.aslbd
	bra.s	.optiw
.moins:	tst.b	EA_an(EAPTR)
	bmi.s	.nobbdm
	not.l	d1
	cmp.l	d1,d0
	blt.s	.nobbdm
.optib:	bsr	Opti_bd2d8
	bra	.asbbd
.nobbdm:	tst.l	d0
	beq.s	.zbd
	move.w	#$8000,d1
	cmp.l	d1,d0
	blt.s	.aslbd
.optiw:	bsr	Opti_bd2w
	bra.s	.aswbd
.revbd:	bra	ErrEv_bd

.wbd:	bmi.s	.bbd
	SETEOL	(a0)
	move.l	a1,a0
	EAWEVAL
	bmi.s	.revbd
.aswbd:	move.b	#BDW_SZ,EA_bdsz(EAPTR)
	EA_END

.lbd:	SETEOL	(a0)
	move.l	a1,a0
	EALEVAL
	bmi.s	.revbd
.aslbd:	move.b	#BDL_SZ,EA_bdsz(EAPTR)
	EA_END

.zbd:	bsr	Opti_bd2z
	move.b	#BD0_SZ,EA_bdsz(EAPTR)
	EA_END

.ropar:	bra	Erropar_exp

.bbd:	SETEOL	(a0)
	move.l	a1,a0
	EABEVAL
	bmi.s	.revd8
	moveq	#-128,d1
	cmp.l	d1,d0
	blt.s	.rmb
	not.l	d1
	cmp.l	d1,d0
	bgt.s	.rpb
.asbbd:	move.w	#D8MEMMODE,EA_mode(EAPTR)	;(bd.b,An,*)
	EA_END
.revd8:	bra	ErrEv_d8
.rmb:
.rpb:	bra	Errd8_ge

.pcxn:	move.w	#BDPCMODE,EA_mode(EAPTR)	;(bdSz,PC,*)
.aspc:	move.b	#BDPCXN_REG,EA_an(EAPTR)	
	move.b	-(a0),d0
	sub.b	#TOKENW,d0
	ble.s	.wbdpc
	subq.b	#TOKENL-TOKENW,d0
	beq.s	.lbdpc
	SETEOL	1(a0)
	move.l	a1,a0
	EALEVAL
	ble.s	.revpcbd
	move.b	#BDL_SZ,EA_bdsz(EAPTR)	;prov
	EA_END
.revpcbd:	bra	ErrEv_bd

.zpcxn:	move.w	#BDZPCMODE,EA_mode(EAPTR)	;(bdSz,ZPC,*)
	cmp.b	#TOKENB,-1(a0)		;forbid Sz=B->(d8,ZPC,*)
	bhi.s	.aspc
	bra	.rinp

.wbdpc:	bmi.s	.bpc
	move.b	#BDW_SZ,EA_bdsz(EAPTR)
.aswbdpc:	SETEOL	(a0)
	move.l	a1,a0
	EALEVAL
	ble.s	.revpcbd
	EA_END

.lbdpc:	move.b	#BDL_SZ,EA_bdsz(EAPTR)
	bra.s	.aswbdpc

.bpc:	move.w	#D8PCMODE,EA_mode(EAPTR)
	move.b	#D8PCXN_REG,EA_an(EAPTR)
	SETEOL	(a0)
	move.l	a1,a0
	EALEVAL
	ble.s	.revpcd8
	EA_END
.revpcd8:	bra	ErrEv_d8
	 ;#] EAPar2:
	 ;#[ EAPar1:	PnXn,bdXn,bdPn->Sc,Sz,Dn,An,Alph
		;#[ EAPar11:	An,Dn
EAPar11:	st	EA_an(EAPTR)		;indicate Xn is Dn
	EAJMP	d0
.t:	dc.w	.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t
	dc.w	.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.sc1-.t,.sc2-.t,.sc4-.t,.sc8-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.pc-.t,.zan-.t,.zpc-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.rb:	bra	Errb_forb

.zan:	move.l	#BDZANZXNMODE,EA_f(EAPTR)	;(bdSz,ZAn)
	bra	EAGetBd

.zpc:	move.l	#BDZPCZXNMODE,EA_f(EAPTR)	;(bdSz,ZPC)
	bra.s	.aspc

.pc:	move.l	#BDPCZXNMODE,EA_f(EAPTR)	;(bdSz,PC)
.aspc:	bra	EAGetPC

.sc1:	;pas gerer equr*scale
.sc2:
.sc4:
.sc8:
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	sub.b	#TOKENSC1,d0
	move.b	d0,EA_xnsc(EAPTR)		;Sc
	move.b	-(a0),d0
	cmp.b	#TOKENL,d0
	beq.s	.lsc
	clr.b	EA_xnsz(EAPTR)		;XNW_SZ
	cmp.b	#TOKENW,d0
	beq.s	.asz
	bra.s	.asc
.lsc:	move.b	#XNL_SZ,EA_xnsz(EAPTR)
	bra.s	.asz

.alph:	ZSZZSC
	moveq	#',',d0
	jsr	GetEqur3			;d8?EqrSz
	bmi.s	.rinp
	cmp.b	#TOKEND7,d0
	bls.s	.aldn
	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
	move.b	d0,EA_an(EAPTR)		;An?
.aldn:	move.b	d0,EA_xn(EAPTR)		;Xn?
	bra.s	EAPar12

.eqrsz:	moveq	#',',d0
	jsr	GetEqur3			;d8?EqrSz
	bmi.s	.rinp
	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
	move.b	d0,EA_xn(EAPTR)		;Xn
	bra.s	EAPar12

.word:	ZSZZSC
	bra.s	.asz
.long:	move.w	#XNL_SZ<<8,EA_xnsz(EAPTR)	;+scale=*1
.asz:	move.b	-(a0),d0
.asc:	cmp.b	#LASTTOKEN,d0
	bhi.s	.eqrsz

	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
	move.b	d0,EA_xn(EAPTR)		;Xn
	bra.s	.axn

.rxn:	bra	Errxn_exp
.rinp:	bra	Errcant_input
.rcomma:	bra	Errcomma_exp

.an:	ZSZZSC				;(An,An),(Eqr,An),(Bd,An)
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	move.b	d0,EA_an(EAPTR)		;An
	move.b	d0,EA_xn(EAPTR)		;Xn
	bra.s	.axn

.dn:	ZSZZSC				;(An,Dn),(Eqr,Dn),(Bd,Dn)
	IFNE	_68000
	move.b	(a0),EA_xn(EAPTR)		;Xn
	ELSEIF
	move.b	d0,EA_xn(EAPTR)		;Xn
	ENDC	;_68000
.axn:	cmp.b	#',',-(a0)		;Pn, Eqr, Bd,
	bne.s	.rcomma
		;#] EAPar11:
;keep tight
		;#[ EAPar12:
EAPar12:
	EAJMP	d0
.t:	dc.w	.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t
	dc.w	.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.pc-.t,.zan-.t,.zpc-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.eqrpc:	move.w	#D8PCMODE,EA_mode(EAPTR)	;(PC,Xn*)
	move.b	#D8PCXN_REG,EA_an(EAPTR)
	clr.l	EA_vtype(EAPTR)
	clr.w	EA_value+2(EAPTR)
	EA_END

.eqrzan:	move.w	#BDMEMMODE,EA_mode(EAPTR)	;(ZAn,Xn*)
	st	EA_an(EAPTR)
	bra.s	.z

.eqrzpc:	move.w	#BDZPCMODE,EA_mode(EAPTR)	;(ZPC,Xn*)
	move.b	#BDPCXN_REG,EA_an(EAPTR)	
.z:	move.b	#BD0_SZ,EA_bdsz(EAPTR)	;ZBd
	EA_END

.eqran:	cmp.b	#TOKENPC,d0
	beq.s	.eqrpc
	cmp.b	#TOKENZAN,d0
	beq.s	.eqrzan
	cmp.b	#TOKENZPC,d0
	beq.s	.eqrzpc
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.rpn
	move.b	d0,EA_an(EAPTR)
	clr.l	EA_vtype(EAPTR)
	clr.w	EA_value+2(EAPTR)
	move.w	#D8MEMMODE,EA_mode(EAPTR)
	EA_END

.zan:	move.w	#BDMEMMODE,EA_mode(EAPTR)	;(ZAn,Xn*)
	st	EA_an(EAPTR)
	bra.s	.endz

.zpc:	move.w	#BDZPCMODE,EA_mode(EAPTR)	;(ZPC,Xn*)
	move.b	#BDPCXN_REG,EA_an(EAPTR)	
.endz:	move.b	#BD0_SZ,EA_bdsz(EAPTR)	;ZBd
	bra.s	.endpar

.pc:	move.w	#D8PCMODE,EA_mode(EAPTR)	;(PC,Xn*)
	move.b	#D8PCXN_REG,EA_an(EAPTR)
	bra.s	.clrd8

.ropar:	bra	Erropar_exp
.rinp:	bra	Errcant_input
.rb:	bra	Errb_forb
.rpn:	bra	Erran_exp
.rdn:	bra	Errdn_forb

.an:					;(An,*)=0(An,Xn)
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	subq.b	#TOKENA0,d0
	move.b	d0,EA_an(EAPTR)
	move.w	#D8MEMMODE,EA_mode(EAPTR)
.clrd8:	clr.l	EA_vtype(EAPTR)
	clr.w	EA_value+2(EAPTR)
.endpar:	cmp.l	a0,a1
	bne.s	.ropar
	EA_END

.alph:	SETEOL	1(a0)			;(BdSZ,* (EqrSZ,*
	move.l	a1,a0
	EALEVAL
	bmi.s	.eqr?
	bne.s	.aslalph
	tst.w	OptiBdFlg
	beq.s	.aslalph
	tst.l	d0
	beq.s	.aszbd
	move.l	#$7fff,d1
	tst.b	d2
	bne.s	.moins
	cmp.l	d1,d0
	bhi.s	.aslalph
	bra.s	.asasw
.moins:	not.l	d1
	cmp.l	d1,d0
	blt.s	.aslalph
.asasw:	bsr	Opti_bd2w
.aswalph:	move.b	#BDW_SZ,EA_bdsz(EAPTR)	;(Bd.w,Xn*)
	bra.s	.endalph
.aszbd:	bsr	Opti_bd2z
	move.b	#BD0_SZ,EA_bdsz(EAPTR)	;ZBd
	bra.s	.endalph
.aslalph:	move.b	#BDL_SZ,EA_bdsz(EAPTR)	;(Bd.l,Xn*)
.endalph:	tst.b	EA_an(EAPTR)
	bmi.s	.xnisxn
	subq.b	#TOKENA0,EA_an(EAPTR)	;An
	st	EA_xn(EAPTR)		;ZXn
.xnisxn:	move.w	#BDMEMMODE,EA_mode(EAPTR)
	EA_END

.eqr?:	cmp.b	#EVAL_EQUR,d1
	beq	.eqran
.revbd:	bra	ErrEv_bd

.word:	SETEOL	(a0)
	move.l	a1,a0
	EAWEVAL
	bmi.s	.revbd
	bra.s	.aswalph

.long:	SETEOL	(a0)
	move.l	a1,a0
	EALEVAL
	bmi.s	.revbd
	bra.s	.aslalph

		;#] EAPar12:
	 ;#] EAPar1:
	 ;#[ EAPar0:	RnSzSc,An,absWL,eqr,bdWL->Sc,Sz,Dn,An,Alph
EAPar0:
	EAJMP	d0
.t:	dc.w	.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t
	dc.w	.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.sc1-.t,.sc2-.t,.sc4-.t,.sc8-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.pc-.t,.zan-.t,.zpc-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.sc8:
.sc4:
.sc2:
.sc1:
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	sub.b	#TOKENSC1,d0		;(*Sc)=(Zbd,ZAn,XnSzSc)
	move.b	d0,EA_xnsc(EAPTR)
	cmp.l	a0,a1
	beq.s	.rinp			;(Sc)
	move.b	-(a0),d0			;(*Sc)
	cmp.b	#TOKENA7,d0		;(XnSc)
	bls.s	.asscw
	cmp.b	#LASTTOKEN,d0		;(EqSc) notimp
	bhi.s	.scalph
	cmp.b	#TOKENW,d0
	beq.s	.scw			;(*WSc)
	cmp.b	#TOKENL,d0
	beq.s	.scl			;(*LSc)
.rinp:	bra	Errcant_input
.rb?:	blt.s	.rinp
.rb:	bra	Errb_forb

.scalph:	st	1(a0)			;(Eq*Sc)
	move.l	a1,a0
	jsr	GetEqur
	bmi.s	.rxn
	cmp.b	#TOKENA7,d0
	bls.s	.asdn
	bra.s	.rxn

.asscw:	clr.b	EA_xnsz(EAPTR)
	bra.s	.asdn
.scl:	move.b	#XNL_SZ,EA_xnsz(EAPTR)	;Sz=.L
	bra.s	.scsz
.scw:	clr.b	EA_xnsz(EAPTR)		;Sz=.W
.scsz:	move.b	-(a0),d0			;(*WSc)
	cmp.b	#TOKENA7,d0		;(XnWSc)
	bls.s	.asdn
	cmp.b	#LASTTOKEN,d0		;(EqWSc)
	bhi.s	.scalph
	bra.s	.rinp

.dn:	cmp.l	a0,a1			;(Dn)
	bne.s	.rinp
.asdn1:	ZSZZSC
.asdn:
	IFNE	_68000
	move.b	(a0),EA_xn(EAPTR)		;Xn
	ELSEIF
	move.b	d0,EA_xn(EAPTR)		;Xn
	ENDC	;_68000
	st	EA_an(EAPTR)		;ZAn
	move.w	#(MEM_MODE<<8)|_BDANXN_MODE,EA_mode(EAPTR)	;+mode2
	move.b	#BD0_SZ,EA_bdsz(EAPTR)	;ZBd
	rts

.rxn:	bra	Errxn_exp

.word:	move.b	-(a0),d0			;(bd.w),(eqr.w),(Xn.w)
	cmp.b	#LASTTOKEN,d0
	bhi.s	.walph
.asxnw:	cmp.b	#TOKENA7,d0
	bls.s	.asdn1
	bra.s	.rinp

.walph:	st	1(a0)			;(bd.w),(eq.w)
	move.l	a1,a0
	EAWEVAL
	bmi.s	.wreval
;	move.w	#BDMEMMODE,EA_mode(EAPTR)	;+mode2
	move.l	#BDZANZXNMODE,EA_f(EAPTR)	;(bd)=(bd,ZAn,ZXn)
	move.b	#BDW_SZ,EA_bdsz(EAPTR)	;(bd.w)
	rts
.wreval:	cmp.b	#EVAL_EQUR,d1
	beq.s	.asxnw			;(eq.w)
.revbd:	bra	ErrEv_bd

.long:	move.b	-(a0),d0			;(bd.l),(eq.l)
	cmp.b	#LASTTOKEN,d0
	bhi.s	.lalph
.asxnl1:	move.w	#XNL_SZ<<8,EA_xnsz(EAPTR)	;.L*1
	cmp.b	#TOKENA7,d0
	bls.s	.asdn
	bra	.rinp
.lalph:	st	1(a0)			;(bd.l),(eq.l)
	move.l	a1,a0
	EALEVAL				;a0 set
	bmi.s	.lreval
;	move.w	#BDMEMMODE,EA_mode(EAPTR)	;+mode2
	move.l	#BDZANZXNMODE,EA_f(EAPTR)	;(bd)=(bd,ZAn,ZXn)
	move.b	#BDL_SZ,EA_bdsz(EAPTR)	;(bd.l)
	rts
.lreval:	cmp.b	#EVAL_EQUR,d1
	beq.s	.asxnl1			;(eq.l)
	bra.s	.revbd

.rinp2:	bra	Errcant_input

.zan:	move.l	#BDZANZXNMODE,EA_f(EAPTR)	;(ZAn)=(Zbd,ZAn,ZXn)
	bra.s	.zbd

.zpc:	move.l	#BDZPCZXNMODE,EA_f(EAPTR)	;(ZPC)=(Zbd,ZPC,ZXn)
	bra.s	.zbd

.pc:	move.l	#BDPCZXNMODE,EA_f(EAPTR)	;(PC)=(Zbd,PC,ZXn)
.zbd:	move.b	#BD0_SZ,EA_bdsz(EAPTR)	;Zbd=BD0_SZ
	rts

.an:	cmp.l	a0,a1			;(An)
	bne.s	.rinp2
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
.asan:	subq.b	#TOKENA0,d0
	move.b	d0,EA_an(EAPTR)
	move.b	#ANINDIR_MODE,EA_mode(EAPTR)
	rts

.alph:	st	1(a0)			;(bd),(eq),(eqSc)
	move.l	a1,a0
	EALEVAL
	bmi.s	.alreval
	move.l	#BDZANZXNMODE,EA_f(EAPTR)	;ZAnZXn
	move.b	#BDL_SZ,EA_bdsz(EAPTR)	;(bd.l)
	rts				;check bd size

.alreval:	cmp.b	#EVAL_EQUR,d1		;(eq)
	bne.s	.revalph
.aleqr:	cmp.b	#TOKEND7,d0		;(Dn)
	bls	.asdn1
	cmp.b	#TOKENA7,d0		;(An)
	bls.s	.asan
	cmp.b	#TOKENPC,d0		;(PC)
	beq.s	.pc
	cmp.b	#TOKENZAN,d0		;(ZAn)
	beq.s	.zan
	cmp.b	#TOKENZPC,d0		;(ZPC)
	beq.s	.zpc
	bra	Errcant_input

.revalph:	bra	ErrEv_bd

	 ;#] EAPar0:
	 ;#[ EAGetBd:	(Bd,ZAn
EAGetBd:	cmp.b	#',',-(a0)
	bne.s	.rcomma
	move.b	-(a0),d0
	sub.b	#TOKENW,d0
	beq.s	.wbd
	subq.b	#TOKENL-TOKENW,d0
	beq.s	.lbd
	SETEOL	1(a0)
	move.l	a1,a0
	EALEVAL
	bmi.s	.revbd
	move.b	#BDL_SZ,EA_bdsz(EAPTR)	;prov avant opti
	EA_END
.revbd:	bra	ErrEv_bd
.rcomma:	bra	Errcomma_exp

.lbd:	move.b	#BDL_SZ,EA_bdsz(EAPTR)
	SETEOL	(a0)
	move.l	a1,a0
	EALEVAL
	bmi.s	.revbd
	EA_END
.wbd:	move.b	#BDW_SZ,EA_bdsz(EAPTR)
	SETEOL	(a0)
	move.l	a1,a0
	EALEVAL
	bmi.s	.revbd
	EA_END
	 ;#] EAGetBd:
	 ;#[ EAGetPC:	(Bd,PC (Bd,ZPC
EAGetPC:	cmp.b	#',',-(a0)
	bne.s	.rcomma
	move.b	-(a0),d0
	sub.b	#TOKENW,d0
	beq.s	.wbdpc
	subq.b	#TOKENL-TOKENW,d0
	beq.s	.lbdpc
	SETEOL	1(a0)
	move.l	a1,a0
	EALEVAL
	ble.s	.revpcbd
	move.b	#BDL_SZ,EA_bdsz(EAPTR)	;prov
	EA_END
.revpcbd:	bra	ErrEv_bd
.rcomma:	bra	Errcomma_exp

.lbdpc:	move.b	#BDL_SZ,EA_bdsz(EAPTR)
	bra.s	.aswbdpc
.wbdpc:	move.b	#BDW_SZ,EA_bdsz(EAPTR)
.aswbdpc:	SETEOL	(a0)
	move.l	a1,a0
	EALEVAL
	ble.s	.revpcbd
	EA_END
	 ;#] EAGetPC:
;  #] EAPar:
;  #[ EABra:	[*]
EABra:	move.w	LINE_parnb(FIELDPTR),d0	;commas #
	beq.s	.EAOd0
	move.l	LINE_tokend(FIELDPTR),a0	;od end @
	subq.w	#1,a0			;-> )
	move.l	LINE_btokend(FIELDPTR),a1	;od start @
	addq.w	#2,a1			;skip ],
	subq.w	#1,d0
	beq.s	EAOd1
	subq.w	#1,d0
	beq	EAOd2
	bra	Errcomma_2many

.EAOd0:	move.b	#OD0_SZ,EA_odsz(EAPTR)	;Zod=OD0_SZ
	bra	EABraPre

	 ;#[ EAOd1:	[*]		;In:a0=end @,a1=start @
EAOd1:
	EAJMP	d0
.t:	dc.w	.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t
	dc.w	.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.sc1-.t,.sc2-.t,.sc4-.t,.sc8-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rpc-.t,.rzan-.t,.rzpc-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.sc8:
.sc4:
.sc2:
.sc1:
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	sub.b	#TOKENSC1,d0		;*Sc)=XnSzSc)
	move.b	d0,EA_xnsc(EAPTR)
	cmp.l	a0,a1
	beq.s	.rinp			;Sc)
	move.b	-(a0),d0			;*Sc)
	cmp.b	#TOKENA7,d0		;XnSc)
	bls.s	.asscw
	cmp.b	#LASTTOKEN,d0		;EqSc) notimp
	bhi.s	.scalph
	cmp.b	#TOKENW,d0
	beq.s	.scw			;*WSc)
	cmp.b	#TOKENL,d0
	beq.s	.scl			;*LSc)
.rinp:	bra	Errcant_input
.rb?:	blt.s	.rinp
.rb:	bra	Errb_forb

.scalph:	st	1(a0)			;Eq*Sc)
	move.l	a1,a0
	jsr	GetEqur
	bmi.s	.rxn
	cmp.b	#TOKENA7,d0
	bls.s	.asdn
	bra.s	.rxn

.asscw:	clr.b	EA_xnsz(EAPTR)
	bra.s	.asdn
.scl:	move.b	#XNL_SZ,EA_xnsz(EAPTR)	;Sz=.L
	bra.s	.scsz
.scw:	clr.b	EA_xnsz(EAPTR)		;Sz=.W
.scsz:	move.b	-(a0),d0			;*WSc)
	cmp.b	#TOKENA7,d0		;XnWSc)
	bls.s	.asdn
	cmp.b	#LASTTOKEN,d0		;EqWSc)
	bhi.s	.scalph
	bra.s	.rinp

.dn:	cmp.l	a0,a1			;Dn)
	bne.s	.rinp
	IFNE	_68000
	move.b	(a0),d0			;reprendre Xn
	ENDC	;_68000
.asdn1:	ZSZZSC
.asdn:	move.b	d0,EA_xn(EAPTR)		;Xn
	move.b	#ODPOST0_SZ,EA_odsz(EAPTR)	;([],Xn,ZOd)
	bra	EABraPst

.rxn:	bra	Errxn_exp

.word:	move.b	-(a0),d0			;od.w),eqr.w),Xn.w)
	cmp.b	#LASTTOKEN,d0
	bhi.s	.walph
.asxnw:	cmp.b	#TOKENA7,d0
	bls.s	.asdn1
	bra.s	.rinp

.walph:	st	1(a0)			;od.w),eq.w)
	move.l	a1,a0
	EAODWEVAL
	bmi.s	.wreval
	beq.s	.wend
	move.l	a1,EA_odsrc(EAPTR)		;for patch
.wend:	move.b	#ODW_SZ,EA_odsz(EAPTR)	;bd.w)
	bra	EABraPre

.wreval:	cmp.b	#EVAL_EQUR,d1
	beq.s	.asxnw			;eq.w)
.revod:	bra	ErrEv_od

.long:	move.b	-(a0),d0			;bd.l),eq.l)
	cmp.b	#LASTTOKEN,d0
	bhi.s	.lalph
.asxnl1:	move.w	#XNL_SZ<<8,EA_xnsz(EAPTR)	;.L*1
	cmp.b	#TOKENA7,d0
	bls.s	.asdn
	bra	.rinp

.lalph:	st	1(a0)			;bd.l),eq.l)
	move.l	a1,a0
	EAODLEVAL				;a0 set
	bmi.s	.lreval
	beq.s	.lend
.lpatch:	move.l	a1,EA_odsrc(EAPTR)		;for patch
.lend:	move.b	#ODL_SZ,EA_odsz(EAPTR)	;bd.l)
	bra	EABraPre

.lreval:	cmp.b	#EVAL_EQUR,d1
	beq.s	.asxnl1			;eq.l)
	bra.s	.revod

.rpc:
.rzan:
.rzpc:
.rinp2:	bra	Errcant_input

.alph:	st	1(a0)			;od),eq),eqSc)
	move.l	a1,a0
	EAODLEVAL
	bmi.s	.alreval
	bne.s	.lpatch
	tst.w	OptiOdFlg
	beq.s	.lend
	tst.l	d0
	beq.s	.zod
	move.l	#$7fff,d1
	tst.b	d2
	bne.s	.moins
	cmp.l	d1,d0
	bhi.s	.lend
.asasw:	bsr	Opti_od2w
	bra	.wend
.moins:	not.l	d1
	cmp.l	d1,d0
	blt.s	.lend
	bra.s	.asasw

.zod:	bsr	Opti_od2z
	move.b	#OD0_SZ,EA_odsz(EAPTR)
	bra	EABraPre

.alreval:	cmp.b	#EVAL_EQUR,d1		;eq)
	bne.s	.revalph
.aleqr:	cmp.b	#TOKENA7,d0		;Xn)
	bls	.asdn1
	cmp.b	#TOKENPC,d0		;PC)
	beq.s	.rpc
	cmp.b	#TOKENZAN,d0		;ZAn)
	beq.s	.rzan
	cmp.b	#TOKENZPC,d0		;ZPC)
	beq.s	.rzpc
	bra	Errcant_input

.revalph:	bra	ErrEv_od
	 ;#] EAOd1:	[*]
	 ;#[ EAOd2:	[*]		;In:a0=end @,a1=start @
EAOd2:	move.l	a0,a1
	moveq	#',',d0
.l1:	cmp.b	-(a1),d0			;get comma (crade mais bon)
	bne.s	.l1
	addq.w	#1,a1			;skip comma
	move.b	-(a0),d0
	cmp.b	#TOKENW,d0
	beq.s	.wod
	cmp.b	#TOKENL,d0
	beq.s	.lod
	st	1(a0)
	move.l	a1,a0
	EAODLEVAL
	bmi.s	.revod
	bne.s	.lpatch
	tst.w	OptiOdFlg
	beq.s	.lend
	tst.l	d0
	beq.s	.zod
	move.l	#$7fff,d1
	tst.b	d2
	bne.s	.moins
	cmp.l	d1,d0
	bhi.s	.lend
.asaswod:	bsr	Opti_od2w
	bra.s	.wend
.moins:	not.l	d1
	cmp.l	d1,d0
	blt.s	.lend
	bra.s	.asaswod
.revod:	bra	ErrEv_od

.zod:	bsr	Opti_od2z
	move.b	#ODPOST0_SZ,EA_odsz(EAPTR)
	bra.s	.getxn

.wod:	st	(a0)			;od.w)
	move.l	a1,a0
	EAODWEVAL
	bmi.s	.revod
	beq.s	.wend
	move.l	a1,EA_odsrc(EAPTR)
.wend:	move.b	#ODPOSTW_SZ,EA_odsz(EAPTR)
	bra.s	.getxn

.lod:	st	(a0)			;od.l)
	move.l	a1,a0
	EAODLEVAL
	bmi.s	.revod
	beq.s	.lend
.lpatch:	move.l	a1,EA_odsrc(EAPTR)
.lend:	move.b	#ODPOSTL_SZ,EA_odsz(EAPTR)
;	bra.s	.getxn

.getxn:	lea	-1(a1),a0
	move.l	LINE_btokend(FIELDPTR),a1	;od start @
	addq.w	#2,a1			;skip ],
	EAJMP	d0
.t:	dc.w	.xn-.t,.xn-.t,.xn-.t,.xn-.t,.xn-.t,.xn-.t,.xn-.t,.xn-.t
	dc.w	.xn-.t,.xn-.t,.xn-.t,.xn-.t,.xn-.t,.xn-.t,.xn-.t,.xn-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.sc1-.t,.sc2-.t,.sc4-.t,.sc8-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rpc-.t,.rzan-.t,.rzpc-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.rb:	bra	Errb_forb

.sc8:
.sc4:
.sc2:
.sc1:
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	sub.b	#TOKENSC1,d0		;*Sc=XnSzSc
	move.b	d0,EA_xnsc(EAPTR)
	cmp.l	a0,a1
	beq.s	.rinp			;Sc
	move.b	-(a0),d0			;*Sc
	cmp.b	#TOKENA7,d0		;XnSc
	bls.s	.asxnw
	cmp.b	#LASTTOKEN,d0		;EqSc notimp
	bhi.s	.scalph
	cmp.b	#TOKENW,d0
	beq.s	.scw			;*WSc
	cmp.b	#TOKENL,d0
	beq.s	.scl			;*LSc
.rinp:	bra	Errcant_input
.asxnw:	clr.b	EA_xnsz(EAPTR)
	bra.s	.asxn

.scalph:	SETEOL	1(a0)			;Eq*Sc
	move.l	a1,a0
.eqr:	jsr	GetEqur
	bmi.s	.rxn
	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
.asxn:	move.b	d0,EA_xn(EAPTR)
	bra	EABraPst

.scl:	move.b	#XNL_SZ,EA_xnsz(EAPTR)	;Sz=.L
	bra.s	.scsz
.scw:	clr.b	EA_xnsz(EAPTR)		;Sz=.W

.scsz:	move.b	-(a0),d0			;*WSc
	cmp.b	#TOKENA7,d0		;XnWSc
	bls.s	.asxn
	cmp.b	#LASTTOKEN,d0		;EqWSc
	bhi.s	.scalph
	bra.s	.rinp

.alph:	ZSZZSC
	SETEOL	(a0)			;eqr
	move.l	a1,a0
	bra.s	.eqr

.rpc:
.rzan:
.rzpc:
.rxn:	bra	Errxn_exp

.long:	move.w	#XNL_SZ<<8,EA_xnsz(EAPTR)	;.L*1
	bra.s	.xnsz
.word:	ZSZZSC				;.W*1
.xnsz:	move.b	-(a0),d0			;eqr.w,Xn.w
	cmp.b	#TOKENA7,d0
	bls.s	.asxn
	cmp.b	#LASTTOKEN,d0
	bls.s	.rxn

	SETEOL	1(a0)			;eqr.w
	move.l	a1,a0
	bra.s	.eqr

.xn:	cmp.l	a0,a1			;Dn)
	bne.s	.rinp
	ZSZZSC
	IFNE	_68000
	move.b	(a0),EA_xn(EAPTR)		;Xn
	ELSEIF
	move.b	d0,EA_xn(EAPTR)		;Xn
	ENDC	;_68000
	bra	EABraPst

	 ;#] EAOd2:	[*]
	 ;#[ EABraPre:	[*]		;In:a0=end @,a1=start @
EABraPre:
.bra:	move.l	LINE_btokend(FIELDPTR),a0	;end @
	lea	2(FIELDPTR),a1		;start @ (skip ([)
	move.w	LINE_branb(FIELDPTR),d0	;commas #
	beq	EAPre0
	subq.w	#1,d0
	beq	EAPre1
	subq.w	#1,d0
	bne	Errcomma_2many
;keep tight
	 ;#[ EABra2:	[bdPnXn]
EABra2:
	EAJMP	d0
.t:	dc.w	.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t
	dc.w	.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.sc1-.t,.sc2-.t,.sc4-.t,.sc8-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.rb:	bra	Errb_forb

.rxnsz:	bra	Errxnorsz_exp

.sc1:	;pas gerer equr*scale
.sc2:
.sc4:
.sc8:
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	sub.b	#TOKENSC1,d0
	move.b	d0,EA_xnsc(EAPTR)		;Sc
	move.b	-(a0),d0
	cmp.b	#TOKENL,d0
	beq.s	.lsc
	clr.b	EA_xnsz(EAPTR)		;XNW_SZ
	cmp.b	#TOKENW,d0
	beq.s	.asz
	bra.s	.asc
.lsc:	move.b	#XNL_SZ,EA_xnsz(EAPTR)
	bra.s	.asz

.alph:	ZSZZSC
.eqrsz:	moveq	#',',d0
	jsr	GetEqur3			;d8?EqrSz
	bmi.s	.rinp
	bra.s	.asxn

.word:	ZSZZSC
	bra.s	.asz
.long:	move.w	#XNL_SZ<<8,EA_xnsz(EAPTR)	;+scale=*1
.asz:	move.b	-(a0),d0
.asc:	cmp.b	#LASTTOKEN,d0
	bhi.s	.eqrsz

.asxn:	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
	move.b	d0,EA_xn(EAPTR)		;Xn
	bra.s	.axn

.eqrxn:	moveq	#',',d0
	jsr	GetEqur3
	bmi.s	.rinp
	bra.s	.asxn2

.rxn:	bra	Errxn_exp
.rinp:	bra	Errcant_input
.rcomma:	bra	Errcomma_exp

.an:
.dn:	ZSZZSC
	IFNE	_68000
	move.b	(a0),EA_xn(EAPTR)		;Xn
	ELSEIF
	move.b	d0,EA_xn(EAPTR)		;Xn
	ENDC	;_68000
.axn:	cmp.b	#',',-(a0)		;,
	bne.s	.rcomma
	move.b	-(a0),d0			;Pn
	cmp.b	#LASTTOKEN,d0
	bhi.s	.eqrxn
.asxn2:	cmp.b	#',',-(a0)
	bne.s	.rcomma
	cmp.b	#TOKENA7,d0
	bls.s	.isan
	cmp.b	#TOKENPC,d0		;PC
	beq	.pcxn
	cmp.b	#TOKENZAN,d0		;PC
	beq.s	.zanxn
	cmp.b	#TOKENZPC,d0		;PC
	beq	.zpcxn
.rpn:	bra	Erran_exp

.rdn:	bra	Errdn_forb

.zanxn:	moveq	#-1,d0			;ZAn
	bra.s	.asan

.isan:	subq.b	#TOKENA0,d0		;An
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.rpn

.asan:	move.b	d0,EA_an(EAPTR)
	move.w	#BDMEMMODE,EA_mode(EAPTR)
	move.b	-(a0),d0
	sub.b	#TOKENW,d0
	ble.s	.wbd
	subq.b	#TOKENL-TOKENW,d0
	beq.s	.lbd
	SETEOL	1(a0)
	move.l	a1,a0
	EALEVAL
	bmi.s	.revbd
	move.b	#BDL_SZ,EA_bdsz(EAPTR)	;prov
	EA_END
.revbd:	bra	ErrEv_bd

.wbd:	bmi.s	.bbd
	move.b	#BDW_SZ,EA_bdsz(EAPTR)
	SETEOL	(a0)
	move.l	a1,a0
	EAWEVAL
	bmi.s	.revbd
	EA_END

.lbd:	move.b	#BDL_SZ,EA_bdsz(EAPTR)
	SETEOL	(a0)
	move.l	a1,a0
	EALEVAL
	bmi.s	.revbd
	EA_END

.ropar:	bra	Erropar_exp

.bbd:	move.w	#D8MEMMODE,EA_mode(EAPTR)	;(bd.b,An,*)
	SETEOL	(a0)
	move.l	a1,a0
	EABEVAL
	bmi.s	.revd8
	moveq	#-128,d1
	cmp.l	d1,d0
	blt.s	.rmb
	not.l	d1
	cmp.l	d1,d0
	bgt.s	.rpb
	EA_END
.revd8:	bra	ErrEv_d8
.rmb:
.rpb:	bra	Errd8_ge

.pcxn:	move.w	#BDPCMODE,EA_mode(EAPTR)	;(bdSz,PC,*)
.aspc:	move.b	#BDPCXN_OD_REG,EA_an(EAPTR)	
	move.b	-(a0),d0
	sub.b	#TOKENW,d0
	ble.s	.wbdpc
	subq.b	#TOKENL-TOKENW,d0
	beq.s	.lbdpc
	SETEOL	1(a0)
	move.l	a1,a0
	EALEVAL
	ble.s	.revpcbd
	move.b	#BDL_SZ,EA_bdsz(EAPTR)	;prov
	EA_END
.revpcbd:	bra	ErrEv_bd

.zpcxn:	move.w	#BDZPCMODE,EA_mode(EAPTR)	;(bdSz,ZPC,*)
	cmp.b	#TOKENB,-1(a0)		;forbid Sz=B->(d8,ZPC,*)
	bhi.s	.aspc
	bra	.rinp

.wbdpc:	bmi.s	.bpc
	move.b	#BDW_SZ,EA_bdsz(EAPTR)
.aswbdpc:	SETEOL	(a0)
	move.l	a1,a0
	EALEVAL
	ble.s	.revpcbd
	EA_END

.lbdpc:	move.b	#BDL_SZ,EA_bdsz(EAPTR)
	bra.s	.aswbdpc

.bpc:	move.w	#D8PCMODE,EA_mode(EAPTR)
	move.b	#D8PCXN_REG,EA_an(EAPTR)
	SETEOL	(a0)
	move.l	a1,a0
	EALEVAL
	ble.s	.revpcd8
	EA_END
.revpcd8:	bra	ErrEv_d8
	 ;#] EABra2:
	 ;#[ EAPre1:	PnXn,bdXn,bdPn->Sc,Sz,Dn,An,Alph
		;#[ EAPre1:	An,Dn
EAPre1:	st	EA_an(EAPTR)		;Xn is Dn
	EAJMP	d0
.t:	dc.w	.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t
	dc.w	.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.sc1-.t,.sc2-.t,.sc4-.t,.sc8-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.pc-.t,.zan-.t,.zpc-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.rb:	bra	Errb_forb

.zan:	move.l	#BDZANZXNMODE,EA_f(EAPTR)	;(bdSz,ZAn)
	bra	EAGetBd

.zpc:	move.l	#BDZPCZXNMODE,EA_f(EAPTR)	;(bdSz,ZPC)
	bra.s	.aspc

.pc:	move.l	#BDPCZXNMODE,EA_f(EAPTR)	;(bdSz,PC)
.aspc:	bra	EAGetPC

.sc1:	;pas gerer equr*scale
.sc2:
.sc4:
.sc8:
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	sub.b	#TOKENSC1,d0
	move.b	d0,EA_xnsc(EAPTR)		;Sc
	move.b	-(a0),d0
	cmp.b	#TOKENL,d0
	beq.s	.lsc
	clr.b	EA_xnsz(EAPTR)		;XNW_SZ
	cmp.b	#TOKENW,d0
	beq.s	.asz
	bra.s	.asc
.lsc:	move.b	#XNL_SZ,EA_xnsz(EAPTR)
	bra.s	.asz

.alph:	ZSZZSC
	moveq	#',',d0
	jsr	GetEqur3			;d8?EqrSz
	bmi.s	.rinp
	cmp.b	#TOKEND7,d0
	bls.s	.aldn
	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
	move.b	d0,EA_an(EAPTR)		;An?
.aldn:	move.b	d0,EA_xn(EAPTR)		;Xn?
	bra.s	EAPre12

.eqrsz:	moveq	#',',d0
	jsr	GetEqur3			;d8?EqrSz
	bmi.s	.rinp
	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
	move.b	d0,EA_xn(EAPTR)		;Xn
	bra.s	EAPre12

.word:	ZSZZSC
	bra.s	.asz
.long:	move.w	#XNL_SZ<<8,EA_xnsz(EAPTR)	;+scale=*1
.asz:	move.b	-(a0),d0
.asc:	cmp.b	#LASTTOKEN,d0
	bhi.s	.eqrsz

	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
	move.b	d0,EA_xn(EAPTR)		;Xn
	bra.s	.axn

.rxn:	bra	Errxn_exp
.rinp:	bra	Errcant_input
.rcomma:	bra	Errcomma_exp

.an:	ZSZZSC				;(An,An),(Eqr,An),(Bd,An)
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	move.b	d0,EA_an(EAPTR)		;An
	move.b	d0,EA_xn(EAPTR)		;Xn
	bra.s	.axn

.dn:	ZSZZSC				;(An,Dn),(Eqr,Dn),(Bd,Dn)
	IFNE	_68000
	move.b	(a0),EA_xn(EAPTR)		;Xn
	ELSEIF
	move.b	d0,EA_xn(EAPTR)		;Xn
	ENDC	;_68000
.axn:	cmp.b	#',',-(a0)		;Pn, Eqr, Bd,
	bne.s	.rcomma
		;#] EAPre1:
;keep tight
		;#[ EAPre12:
EAPre12:
	EAJMP	d0
.t:	dc.w	.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t
	dc.w	.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.pc-.t,.zan-.t,.zpc-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.eqrpc:	move.w	#BDPCMODE,EA_mode(EAPTR)	;[PC,Xn*]	^
	move.b	#BDPCXN_REG,EA_an(EAPTR)	;	^
	bra.s	.z

.eqrzan:	move.w	#BDMEMMODE,EA_mode(EAPTR)	;(ZAn,Xn*)
	st	EA_an(EAPTR)
	bra.s	.z

.eqrzpc:	move.w	#BDZPCMODE,EA_mode(EAPTR)	;(ZPC,Xn*)
	move.b	#BDPCXN_REG,EA_an(EAPTR)	
.z:	move.b	#BD0_SZ,EA_bdsz(EAPTR)	;ZBd
	EA_END

.eqran:	cmp.b	#TOKENPC,d0
	beq.s	.eqrpc
	cmp.b	#TOKENZAN,d0
	beq.s	.eqrzan
	cmp.b	#TOKENZPC,d0
	beq.s	.eqrzpc
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.rpn
	move.b	d0,EA_an(EAPTR)
	move.w	#BDMEMMODE,EA_mode(EAPTR)	;	^
	bra.s	.z

.zan:	move.w	#BDMEMMODE,EA_mode(EAPTR)	;(ZAn,Xn*)
	st	EA_an(EAPTR)
	bra.s	.endz

.zpc:	move.w	#BDZPCMODE,EA_mode(EAPTR)	;(ZPC,Xn*)
	move.b	#BDPCXN_REG,EA_an(EAPTR)	
.endz:	move.b	#BD0_SZ,EA_bdsz(EAPTR)	;ZBd
	cmp.l	a0,a1
	bne.s	.ropar
	EA_END

.pc:	move.w	#BDPCMODE,EA_mode(EAPTR)	;[PC,Xn*]	^
	move.b	#BDPCXN_REG,EA_an(EAPTR)	;	^
	bra.s	.endz

.ropar:	bra	Erropar_exp
.rinp:	bra	Errcant_input
.rb:	bra	Errb_forb
.rpn:	bra	Erran_exp
.rdn:	bra	Errdn_forb

.an:					;[An,*]=[ZBd,An,Xn]
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	subq.b	#TOKENA0,d0
	move.b	d0,EA_an(EAPTR)
	move.w	#BDMEMMODE,EA_mode(EAPTR)	;	^
	bra.s	.endz

.alph:	SETEOL	1(a0)			;(BdSZ,* (EqrSZ,*
	move.l	a1,a0
	EALEVAL
	bmi.s	.eqr?
	bne.s	.aslalph
	tst.w	OptiBdFlg
	beq.s	.aslalph
	tst.l	d0
	beq.s	.aszbd
	move.l	#$7fff,d1
	tst.b	d2
	bne.s	.moins
	cmp.l	d1,d0
	bhi.s	.aslalph
	bra.s	.asasw
.moins:	not.l	d1
	cmp.l	d1,d0
	blt.s	.aslalph
.asasw:	bsr	Opti_bd2w
.aswalph:	move.b	#BDW_SZ,EA_bdsz(EAPTR)	;(Bd.w,Xn*)
	bra.s	.endalph
.aszbd:	bsr	Opti_bd2z
	move.b	#BD0_SZ,EA_bdsz(EAPTR)	;ZBd
	bra.s	.endalph
.aslalph:	move.b	#BDL_SZ,EA_bdsz(EAPTR)	;(Bd.l,Xn*)
.endalph:	tst.b	EA_an(EAPTR)
	bmi.s	.xnisxn
	subq.b	#TOKENA0,EA_an(EAPTR)	;An
	st	EA_xn(EAPTR)		;ZXn
.xnisxn:	move.w	#BDMEMMODE,EA_mode(EAPTR)
	EA_END

.eqr?:	cmp.b	#EVAL_EQUR,d1
	beq	.eqran
.revbd:	bra	ErrEv_bd

.word:	SETEOL	(a0)
	move.l	a1,a0
	EAWEVAL
	bmi.s	.revbd
	bra.s	.aswalph

.long:	SETEOL	(a0)
	move.l	a1,a0
	EALEVAL
	bmi.s	.revbd
	bra.s	.aslalph

		;#] EAPre12:
	 ;#] EAPre1:
	 ;#[ EAPre0:	RnSzSc,An,absWL,eqr,bdWL->Sc,Sz,Dn,An,Alph
EAPre0:
	EAJMP	d0
.t:	dc.w	.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t,.dn-.t
	dc.w	.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.sc1-.t,.sc2-.t,.sc4-.t,.sc8-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.pc-.t,.zan-.t,.zpc-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.zan-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.sc8:
.sc4:
.sc2:
.sc1:
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
	sub.b	#TOKENSC1,d0		;(*Sc)=(Zbd,ZAn,XnSzSc)
	move.b	d0,EA_xnsc(EAPTR)
	cmp.l	a0,a1
	beq.s	.rinp			;(Sc)
	move.b	-(a0),d0			;(*Sc)
	cmp.b	#TOKENA7,d0		;(XnSc)
	bls.s	.asscw
	cmp.b	#LASTTOKEN,d0		;(EqSc) notimp
	bhi.s	.scalph
	cmp.b	#TOKENW,d0
	beq.s	.scw			;(*WSc)
	cmp.b	#TOKENL,d0
	beq.s	.scl			;(*LSc)
.rinp:	bra	Errcant_input
.rb?:	blt.s	.rinp
.rb:	bra	Errb_forb

.scalph:	st	1(a0)			;(Eq*Sc)
	move.l	a1,a0
	jsr	GetEqur
	bmi.s	.rxn
	cmp.b	#TOKENA7,d0
	bls.s	.asdn
	bra.s	.rxn

.asscw:	clr.b	EA_xnsz(EAPTR)
	bra.s	.asdn
.scl:	move.b	#XNL_SZ,EA_xnsz(EAPTR)	;Sz=.L
	bra.s	.scsz
.scw:	clr.b	EA_xnsz(EAPTR)		;Sz=.W
.scsz:	move.b	-(a0),d0			;(*WSc)
	cmp.b	#TOKENA7,d0		;(XnWSc)
	bls.s	.asdn
	cmp.b	#LASTTOKEN,d0		;(EqWSc)
	bhi.s	.scalph
	bra.s	.rinp

.dn:	cmp.l	a0,a1			;(Dn)
	bne.s	.rinp
.asdn1:	ZSZZSC
.asdn:
	IFNE	_68000
	move.b	(a0),EA_xn(EAPTR)		;Xn
	ELSEIF
	move.b	d0,EA_xn(EAPTR)		;Xn
	ENDC	;_68000
	st	EA_an(EAPTR)		;ZAn
	move.w	#(MEM_MODE<<8)|_BDANXN_MODE,EA_mode(EAPTR)	;+mode2
	move.b	#BD0_SZ,EA_bdsz(EAPTR)	;ZBd
	EA_END

.rxn:	bra	Errxn_exp

.word:	move.b	-(a0),d0			;(bd.w),(eqr.w),(Xn.w)
	cmp.b	#LASTTOKEN,d0
	bhi.s	.walph
.asxnw:	cmp.b	#TOKENA7,d0
	bls.s	.asdn1
	bra.s	.rinp

.walph:	st	1(a0)			;(bd.w),(eq.w)
	move.l	a1,a0
	EAWEVAL
	bmi.s	.wreval
.aswalph:	move.l	#BDZANZXNMODE,EA_f(EAPTR)	;ZAnZXn
	move.b	#BDW_SZ,EA_bdsz(EAPTR)	;(bd.w)
	EA_END
.wreval:	cmp.b	#EVAL_EQUR,d1
	beq.s	.asxnw			;(eq.w)
.revbd:	bra	ErrEv_bd

.long:	move.b	-(a0),d0			;(bd.l),(eq.l)
	cmp.b	#LASTTOKEN,d0
	bhi.s	.lalph
.asxnl1:	move.w	#XNL_SZ<<8,EA_xnsz(EAPTR)	;.L*1
	cmp.b	#TOKENA7,d0
	bls.s	.asdn
	bra	.rinp
.lalph:	st	1(a0)			;(bd.l),(eq.l)
	move.l	a1,a0
	EALEVAL				;a0 set
	bmi.s	.lreval
.aslalph:	move.l	#BDZANZXNMODE,EA_f(EAPTR)	;ZAnZXn
	move.b	#BDL_SZ,EA_bdsz(EAPTR)	;(bd.l)
	EA_END
.lreval:	cmp.b	#EVAL_EQUR,d1
	beq.s	.asxnl1			;(eq.l)
	bra.s	.revbd

.rinp2:	bra	Errcant_input

.an:	cmp.l	a0,a1			;[An]	^
	bne.s	.rinp2
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
.asan:	subq.b	#TOKENA0,d0
	move.b	d0,EA_an(EAPTR)
	st	EA_xn(EAPTR)		;ZXn
	move.w	#BDMEMMODE,EA_mode(EAPTR)	;	^
	bra.s	.zbd			;	^

.alph:	st	1(a0)			;(bd),(eq),(eqSc)
	move.l	a1,a0
	EALEVAL
	bmi.s	.alreval
	bne.s	.aslalph
	tst.w	OptiBdFlg
	beq.s	.aslalph
	tst.l	d0
	beq.s	.aszbd
	move.l	#$7fff,d1
	tst.b	d2
	bne.s	.moins
	cmp.l	d1,d0
	bhi.s	.aslalph
.asasw:	bsr	Opti_bd2w
	bra	.aswalph
.moins:	not.l	d1
	cmp.l	d1,d0
	blt.s	.aslalph
	bra.s	.asasw

.aszbd:	bsr	Opti_bd2z
.zan:	move.l	#BDZANZXNMODE,EA_f(EAPTR)	;(ZAn)=(ZBd,ZAn,ZXn)
	bra.s	.zbd

.zpc:	move.l	#BDZPCZXNMODE,EA_f(EAPTR)	;(ZPC)=(ZBd,ZPC,ZXn)
	bra.s	.zbd

.pc:	move.l	#BDPCZXNMODE,EA_f(EAPTR)	;(PC)=(ZBd,PC,ZXn)
.zbd:	move.b	#BD0_SZ,EA_bdsz(EAPTR)	;Zbd=BD0_SZ
	EA_END

.alreval:	cmp.b	#EVAL_EQUR,d1		;(eq)
	bne.s	.revalph
.aleqr:	cmp.b	#TOKEND7,d0		;(Dn)
	bls	.asdn1
	cmp.b	#TOKENA7,d0		;(An)
	bls	.asan
	cmp.b	#TOKENPC,d0		;(PC)
	beq.s	.pc
	cmp.b	#TOKENZAN,d0		;(ZAn)
	beq.s	.zan
	cmp.b	#TOKENZPC,d0		;(ZPC)
	beq.s	.zpc
	bra	Errcant_input

.revalph:	bra	ErrEv_bd

	 ;#] EAPre0:
	 ;#] EABraPre:
	 ;#[ EABraPst:	[*]		;In:a0=end @,a1=start @
EABraPst:
.bra:	move.l	LINE_btokend(FIELDPTR),a0	;end @
	lea	2(FIELDPTR),a1		;start @ (skip ([)
	move.w	LINE_branb(FIELDPTR),d0	;commas #
	beq	EAPst0
	subq.w	#1,d0
	bne	Errcomma_2many
;keep tight
	 ;#[ EAPst1:	bdPn->An,Alph
EAPst1:
	EAJMP	d0
.t:	dc.w	.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t
	dc.w	.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t
	dc.w	.rb-.t,.rword-.t,.rlong-.t,.rsc1-.t,.rsc2-.t,.rsc4-.t,.rsc8-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.pc-.t,.zan-.t,.zpc-.t

	dc.w	.space-.t,.rinp-.t,.alph-.t,.rinp-.t,.alph-.t,.rinp-.t,.rinp-.t,.alph-.t
	dc.w	.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.rb:	bra	Errb_forb

.zan:	move.w	#BDMEMMODE,EA_mode(EAPTR)	;(bdSz,ZAn)
	st	EA_an(EAPTR)
	bra	EAGetBd

.zpc:	move.w	#BDZPCMODE,EA_mode(EAPTR)	;(bdSz,PC)
	bra.s	.aspc

.pc:	move.w	#BDPCMODE,EA_mode(EAPTR)	;(bdSz,PC)
.aspc:	move.b	#BDPCXN_REG,EA_an(EAPTR)
	bra	EAGetPC

.alph:	moveq	#',',d0
	jsr	GetEqur3
	bmi.s	.rinp
	cmp.b	#TOKENA0,d0
	blt.s	.rdn
	cmp.b	#TOKENA7,d0
	ble.s	.aan
	cmp.b	#TOKENPC,d0
	beq.s	.pc
	cmp.b	#TOKENZAN,d0
	beq.s	.zan
	cmp.b	#TOKENZPC,d0
	beq.s	.zpc
;keep tight
.rdn:
.rsc1:
.rsc2:
.rsc4:
.rsc8:
.rword:
.rlong:
.rinp:	bra	Errcant_input
.rcomma:	bra	Errcomma_exp

.an:					;(Bd,An)
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
.aan:	subq.b	#TOKENA0,d0
	move.b	d0,EA_an(EAPTR)		;An
	move.w	#BDMEMMODE,EA_mode(EAPTR)
	bra	EAGetBd
	 ;#] EAPst1:
	 ;#[ EAPst0:	[],RnSzSc,An,absWL,eqr,bdWL->Sc,Sz,Dn,An,Alph
EAPst0:
	EAJMP	d0
.t:	dc.w	.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t,.rdn-.t
	dc.w	.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t,.an-.t
	dc.w	.rb-.t,.word-.t,.long-.t,.rsc1-.t,.rsc2-.t,.rsc4-.t,.rsc8-.t,.rinp-.t
	dc.w	.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.pc-.t,.zan-.t,.zpc-.t

	dc.w	.space-.t,.alph-.t,.alph-.t,.rinp-.t,.alph-.t,.alph-.t,.rinp-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.rinp-.t,.alph-.t,.alph-.t,.rinp-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.rinp-.t,.alph-.t

	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.lbra-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t
	dc.w	.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t,.alph-.t

.rb:	bra	Errb_forb

.word:	move.b	-(a0),d0			;(bd.w),(eqr.w),(Xn.w)
	cmp.b	#LASTTOKEN,d0
	bls.s	.rinp

	st	1(a0)			;(bd.w),(eq.w)
	move.l	a1,a0
	EAWEVAL
	bmi.s	.revbd
	move.b	#BDW_SZ,EA_bdsz(EAPTR)	;(bd.w)
	bra.s	.alphzan

.long:	move.b	-(a0),d0			;(bd.l),(eq.l)
	cmp.b	#LASTTOKEN,d0
	bls.s	.rinp
	st	1(a0)			;(bd.l),(eq.l)
	move.l	a1,a0
	EALEVAL				;a0 set
	bpl.s	.aslalph
.revbd:	bra	ErrEv_bd

.rdn:
.rsc1:
.rsc2:
.rsc4:
.rsc8:
.rinp:	bra	Errcant_input

.lbra:
.zan:	move.w	#BDMEMMODE,EA_mode(EAPTR)	;(ZAn)=(Zbd,ZAn)
	st	EA_an(EAPTR)
	bra.s	.zbd

.zpc:	move.w	#BDZPCMODE,EA_mode(EAPTR)	;(ZPC)=(Zbd,ZPC)
	bra.s	.aspc

.pc:	move.w	#BDPCMODE,EA_mode(EAPTR)	;(PC)=(Zbd,PC)
.aspc:	move.b	#BDPCXN_REG,EA_an(EAPTR)
.zbd:	move.b	#BD0_SZ,EA_bdsz(EAPTR)	;Zbd=BD0_SZ
	rts

.an:	cmp.l	a0,a1			;[An]	^
	bne.s	.rinp
	IFNE	_68000
	move.b	(a0),d0
	ENDC	;_68000
.asan:	subq.b	#TOKENA0,d0
	move.b	d0,EA_an(EAPTR)
	move.w	#BDMEMMODE,EA_mode(EAPTR)	;	^
	bra.s	.zbd			;	^

.alph:	st	1(a0)			;(bd),(eq),(eqSc)
	move.l	a1,a0
	EALEVAL
	bmi.s	.alreval
.aslalph:	move.b	#BDL_SZ,EA_bdsz(EAPTR)	;(bd.l)
.alphzan:	move.w	#BDMEMMODE,EA_mode(EAPTR)	;+mode2 ZAn
	st	EA_an(EAPTR)
	rts				;check bd size

.alreval:	cmp.b	#EVAL_EQUR,d1		;(eq)
	bne.s	.revalph
.aleqr:	cmp.b	#TOKEND7,d0		;(Dn)
	bls.s	.rdn
	cmp.b	#TOKENA7,d0		;(An)
	bls.s	.asan
	cmp.b	#TOKENPC,d0		;(PC)
	beq.s	.pc
	cmp.b	#TOKENZAN,d0		;(ZAn)
	beq.s	.zan
	cmp.b	#TOKENZPC,d0		;(ZPC)
	beq.s	.zpc
	bra	Errcant_input

.revalph:	bra	ErrEv_bd

	 ;#] EAPst0:
	 ;#] EABraPst:
;  #] EABra:


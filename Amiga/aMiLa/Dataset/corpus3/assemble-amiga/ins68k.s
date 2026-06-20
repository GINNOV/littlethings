	XREF	Evaluate,ForEval,OptEval,GetEa,BuildEa,IsFPU,FPUImm,SprintDisp
	XDEF	WPokeBin,LPokeBin

;jmp/jsr abs odd
;equrs ds
;filenames rel in src level?
;chk d16 ge
;FPU ID#
;empty reglist in fmovem
;PVALID PFLUSH pour 51
;FMOVEM fpiar,An//An,fpiar
;optimiser:
;abs.l could be abs.w / pc.w
;adda/suba en lea
;lsl #1,dn en add dn,dn
;roxl #1,dn en addx
;move #0,ea en clr ea
;move.l #0,ea-{Dn} en clr.l ea
;verifier:
;always pc-rel
;immediate in bounds
;even indirection
;check imm
;68ec040 ds movec

FIELDSNB	EQUR	d3
EAOPCODE	EQUR	d4

	IFNE	BLINDOS
CHKEVN	MACRO
	btst	#0,SecSize+3
	beq.s	.even
	_Debugger
.even:
	ENDM
	ELSEIF
CHKEVN	MACRO
	ENDM
	ENDC

;privileged:move fusp,tusp,fsr(680>0),tsr,ori,andi,eori sr
;  #[ BuildDst:
;EAPTR pointe vers buffer de flags
;d1=opcode + mode simple
;d7=flags d'ea
BuildDst:	tst.b	SecPokeFlg
	beq.s	.rdata
	movem.l	a0-a1,-(sp)
	tst.w	SrcType
	bne.s	.src
.aftsrc:	moveq	#0,d1		;ea= simple | (simple & (brief | full))
	moveq	#0,d0
	move.b	EA_mode+EA_SIZEOF(EAPTR),d1	;traitement destination
	move.b	EA_an+EA_SIZEOF(EAPTR),d2
	bmi.s	.zan1
	lsl.w	#3,d2
	or.b	d2,d1
.zan1:	lsl.w	#6,d1
	bra.s	_BuildOp
.rdata:	jmp	Errdata_in_bss
.src:	bsr	LinnAlloc		;petit bloc src
	bra.s	.aftsrc
;  #] BuildDst: 
;  #[ BuildOp:
BuildOp:	tst.b	SecPokeFlg
	beq.s	.rdata
	movem.l	a0-a1,-(sp)
	tst.w	SrcType
	bne.s	.src
.aftsrc:	moveq	#0,d1
	moveq	#0,d0
_BuildOp:	equ	*
	move.b	EA_mode(EAPTR),d0	;traitement source
	lsl.w	#3,d0
	or.b	d0,d1
	move.b	EA_an(EAPTR),d2
	bmi.s	.zan
	or.b	d2,d1
.zan:	or.w	OpCode,d1
	bsr	GetBinBuffer
	move.l	a0,d0
	moveq	#2,d2
	lsr.w	#1,d0
	bcc.s	.pair
	clr.b	(a0)+
	addq.w	#1,d2
.pair:	move.w	d1,(a0)+
	add.l	d2,SecSize
	CHKEVN
	move.l	a0,BinBuffer
	movem.l	(sp)+,a0-a1
	rts
.rdata:	jmp	Errdata_in_bss
.src:	bsr	LinnAlloc		;petit bloc src
	bra.s	.aftsrc
;  #] BuildOp: 
;  #[ BPokeBin:
BPokeBin:	tst.b	SecPokeFlg
	beq.s	.rdata
	movem.l	d0/a0-a1,-(sp)
	bsr	GetBinBuffer
	move.b	EAOPCODE,(a0)+
	move.l	a0,BinBuffer
	addq.l	#1,SecSize
	movem.l	(sp)+,d0/a0-a1
	rts
.rdata:	jmp	Errdata_in_bss
;  #] BPokeBin: 
StartRoutines:
;  #[ PACK,UNPACK:	Dn,Dn,#adj//-(An),-(An),#adj Equated	;20/30/40
_pack:	cmp.w	#MPU_20,MPUType
	blt.s	.rmpu
	subq.w	#3,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	bsr.s	do_bcd
	INC2FIELD
	bra	_as_stop
.rmpu:	bra	Err20_forb
.roper:	bra	Errbad_opernb
;  #] PACK,UNPACK: 
;  #[ ABCD,SBCD:	Dn,Dn//-(An),-(An) real unsized None
_bcd:	subq.w	#2,FIELDSNB
	bne	Errbad_opernb
_bcd2:	move.l	FIELDPTR,a0		;@ 1st field
do_bcd:	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	ble.s	.Dn
;.preAn:
	cmp.b	#'-',d0
	bne.s	.errpre
	cmp.b	#'(',(a0)+
	bne.s	.erropar
	move.b	(a0)+,d0
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.erran
	or.b	d0,EAOPCODE
	tst.b	1(a0)			;TOKENEOL
	bpl.s	.reoo
	lea	FIELDNEXT(FIELDPTR),a0
	cmp.b	#'-',(a0)+
	bne.s	.errmin
	cmp.b	#'(',(a0)+
	bne.s	.erropar
	move.b	(a0)+,d0
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.erran
	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	bset	#3,EAOPCODE
	tst.b	1(a0)			;TOKENEOL
	bpl.s	.reoo
	bra	WPokeOpBin
.errpre:	bra	Errdn_or_pre_exp
.erropar:	bra	Erropar_exp
.rdn:	bra	Errdn_forb
.erran:	bra	Erran_exp
.reoo:	bra	Erreoo_exp
.errmin:	bra	Errmin_exp
.Dn:	or.b	d0,EAOPCODE
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
	lea	FIELDNEXT(FIELDPTR),a0
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.rdn
	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
	bra	WPokeOpBin
;  #] ABCD,SBCD: 
;  #[ ADD,SUB:	Dn,ea//#i,ea//ea,Dn//ea,An sized Relocated Eqr
;Dn,ea->ADD
;#i,ea->ADDI

;ea-{Dn,#i},Dn->ADD
;ea,An->ADDA

;bref:
;regarder source
;si #i, regarder quick -> ADDQ

;sinon, regarder destination
;si Dn, alors ea,Dn
;s1 An, alors ea,An ->ADDA

;sinon, regarder source
;si #i, alors #i,ea ->ADDI
;si Dn, alors Dn,ea

;idem avec equr

;sinon Errea_forb (ea,ea)
_arithm:	subq.w	#2,FIELDSNB
	bne.s	.erroper
	tst.w	OpSize
	bpl.s	.sizeset
	neg.w	OpSize
.sizeset:	cmp.b	#'#',(FIELDPTR)		;#i,ea
	beq.s	.ifquick

	move.b	FIELDNEXT(FIELDPTR),d0
	cmp.b	#TOKEND7,d0	;ea-{#i},Dn
.eadn:	bls	Ea_Dn
	subq.b	#TOKENA0,d0
	cmp.b	#TOKENA7-TOKENA0,d0	;ea-{#i},An
.eaa:	bls	_as_arithma

	lea	FIELDNEXT(FIELDPTR),a0
	bsr	GetEqur
	bmi.s	.noteadn
	cmp.b	#TOKEND7,d0	;ea-{#i},Dn
	bls.s	.eadn
	subq.b	#TOKENA0,d0
	cmp.b	#TOKENA7-TOKENA0,d0	;ea-{#i},An
	bls.s	.eaa
.errea:	bra	Errea_forb	;ea-{#i,Dn},ea-{Dn,An}
.erroper:	bra	Errbad_opernb

.noteadn:	move.b	(FIELDPTR),d0
	cmp.b	#TOKEND7,d0	;Dn,ea-{Dn,An}
.dnea:	bls	Dn_Ea

	move.l	FIELDPTR,a0	;@ 1st field
	bsr	GetEqur
	bmi.s	.errea
	cmp.b	#TOKEND7,d0	;Dn,ea-{Dn,An}
	bls.s	.dnea
	bra.s	.errea

.ifquick:	lea	1(FIELDPTR),a0
	JEAEVAL
	bmi.s	.err
	tst.w	OptiAri2QFlg
	beq.s	.noquick
	tst.l	d0
	ble.s	.noquick
	cmp.l	#8,d0
	bhi.s	.noquick
	INC3REF
	move.l	d0,-(sp)
	jsr	Opti_ari2q
	move.l	(sp)+,d0
	cmp.l	#8,d0
	blt	_as_aq			;1<=d0<=7
	bra	_as_aq8			;0->d0
.err:	jmp	ErrEv_immed
.noquick:	lea	FIELDNEXT(FIELDPTR),a0		;set for aa
	move.b	(a0),d0
	cmp.b	#TOKEND7,d0
	bls.s	.i
	subq.b	#TOKENA0,d0
	cmp.b	#TOKENA7-TOKENA0,d0
	bls.s	_as_arithma
	bsr	GetEqur
	bmi.s	.i
	subq.b	#TOKENA0,d0
	bmi.s	.i
	cmp.b	#TOKENA7-TOKENA0,d0
	bls.s	_as_arithma
.i:	move.b	#IMMEDIATE_MODE,EA_mode(EAPTR)
	move.b	#IMMEDIATE_REG,EA_an(EAPTR)
	bra	_as_arithmi

;ADD/SUB/CMP/AND/OR ea,Dn
;size is:
;%000,%001,%010
Ea_Dn:	move.b	d0,EA_an+EA_SIZEOF(EAPTR)		;reg nb
	move.b	OpSize+1,EA_mode+EA_SIZEOF(EAPTR)	;Op-Mode special
	move.w	EAOPCODE,OpCode
	jsr	GetEa
	bsr	BuildDst		;source et dest construit en single
	move.l	REF_left(REFPTR),d7	;source construit seulement en ea
	jmp	BuildEa

;ADD/SUB/CMP/AND/OR/EOR Dn,ea
;%100,%101,%110
Dn_Ea:	move.b	d0,EA_an+EA_SIZEOF(EAPTR)
	moveq	#%100,d1		;bit 2
	add.b	OpSize+1,d1
	move.b	d1,EA_mode+EA_SIZEOF(EAPTR)
	move.w	EAOPCODE,OpCode
	INCFIELD
	jsr	GetEa		;ea dest
	bsr	BuildDst		;construire source+dest en single
	move.l	REF_right(REFPTR),d7
	jmp	BuildEa		;mais seulement source en ea
;  #] ADD,SUB: 
;  #[ ADDA,SUBA,CMPA:	ea,An sized Eqr
_as_arithma:			;ea,An
	INCREF
	bra.s	_aa
_arithma:	subq.w	#2,FIELDSNB
	bne.s	.erroper
	lea	FIELDNEXT(FIELDPTR),a0
	move.b	(a0)+,d0
	bmi.s	.erran
	cmp.b	#TOKEND7,d0
	ble.s	.rdn
	cmp.b	#TOKENA7,d0
	ble.s	.ok
	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.erran
	subq.b	#TOKENA0,d0
	bpl.s	.ok2
.rdn:	bra	Errdn_forb
.erroper:	bra	Errbad_opernb
.erran:	bra	Erran_exp
.reoo:	bra	Erreoo_exp
.ok:	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
.ok2:	tst.w	OpSize
	bpl.s	.sizeset
	neg.w	OpSize
.sizeset:
_aa:	move.b	d0,EA_an+EA_SIZEOF(EAPTR)	;areg nb
	move.w	REF_opcode(REFPTR),OpCode
	jsr	GetEa
	move.b	OpSize+1,d0		;special OpMode
	subq.b	#1,d0
	beq.s	.wordAn
.longAn:	moveq	#%111,d0
	bra.s	.setopAn
.wordAn:	moveq	#%011,d0
.setopAn:	move.b	d0,EA_mode+EA_SIZEOF(EAPTR)
	bsr	BuildDst			;left+right en single
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa			;lest is ea
;  #] ADDA,SUBA,CMPA: 
;  #[ ADDI,SUBI,CMPI:	#i,ea-{An si <32} sized Relocated
_as_arithmi:	;ADD,SUB,CMP #i
	INC2REF
	bra.s	_ai			;bra.s	_arithmi.ai
_arithmi:	tst.w	OpSize
	bpl.s	.sizeset
	neg.w	OpSize
.sizeset:	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.b	#IMMEDIATE_MODE,EA_mode(EAPTR)
	move.b	#IMMEDIATE_REG,EA_an(EAPTR)
	move.l	FIELDPTR,a0		;@ 1st field
	cmpi.b	#'#',(a0)+
	bne.s	.ri
	JEAEVAL
	bmi.s	.rev
	bra.s	_ai
.roper:	bra	Errbad_opernb
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed

_ai:	move.w	REF_opcode(REFPTR),EAOPCODE
	move.w	OpSize,d0
	lsl.w	#6,d0			;taille 6-7
	or.w	d0,EAOPCODE
	move.w	EAOPCODE,OpCode		;opcode
	INCEA
	INCFIELD
	jsr	GetEa			;<ea>
	bsr	BuildOp		;opcode

	DECEA				;reset flags
	DECFIELD
	move.l	REF_left(REFPTR),d7
	jsr	BuildEa			;#i
	INCEA
	INCFIELD
	move.l	REF_right(REFPTR),d7
	jmp	BuildEa			;<ea>
;  #] ADDI,SUBI,CMPI: 
;  #[ ADDQ,SUBQ:	#i,ea siz Equ Eval,ea
_arithmq:	move.w	OpSize,d1
	bpl.s	.sizeset
	neg.w	OpSize
.sizeset:	subq.w	#2,FIELDSNB
	bne.s	.erroper
	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	#'#',(a0)+
	bne.s	.erri
	JEAEVAL
	bmi.s	.errev
	bgt.s	_as_aq8			;poker 0 en cas d'EXP
	tst.l	d0
	ble.s	.errq
	moveq	#8,d1
	cmp.l	d1,d0
	blt.s	_as_aq
	beq.s	_as_aq8
.errq:	bra	Errq_exp
.erroper:	bra	Errbad_opernb
.erri:	bra	Erri_exp
.errev:	bra	ErrEv_immed

;#8,ea
_as_aq8:	moveq	#0,d0
;#q,ea
_as_aq:	move.w	REF_opcode(REFPTR),EAOPCODE
	moveq	#9,d1
	lsl.w	d1,d0			;d0.w=quick value
	or.w	d0,EAOPCODE

	move.w	OpSize,d0
	lsl.w	#6,d0			;size 6-7
	or.w	d0,EAOPCODE
	INCEA
	INCFIELD
	jsr	GetEa

	move.w	EAOPCODE,OpCode
	bsr	BuildOp

	move.l	EA_vtype-EA_SIZEOF(EAPTR),d1
	beq.s	.noexp

	DECFIELD
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	move.l	EA_value-EA_SIZEOF(EAPTR),d0
	moveq	#P_W911,d2
	jsr	StoreEXP			;d0/d1 set
	INCFIELD
.noexp:	move.l	REF_right(REFPTR),d7
	jmp	BuildEa

;	bsr	Warnari_2q
;	rts
;  #] ADDQ,SUBQ: 
;  #[ ADDX,SUBX:	Dn,Dn//-(An),-(An) sized None
_arithmx:	subq.w	#2,FIELDSNB
	bne.s	.erroper
	move.w	OpSize,d1
	bmi.s	.word
	lsl.w	#6,d1
	or.w	d1,EAOPCODE
	bra	_bcd2
.word:	bset	#6,EAOPCODE
	bra	_bcd2
.erroper:	bra	Errbad_opernb
;  #] ADDX,SUBX: 
;  #[ AND,OR:	ea,Dn//Dn,ea//#i,ea/ccr/sr sized Relocated Eq
_logic:	tst.w	OpSize
	bpl.s	.sizeset
	neg.w	OpSize
.sizeset:	subq.w	#2,FIELDSNB
	bne.s	.erroper
	move.l	FIELDPTR,a0	;@ 1st field
	cmp.b	#'#',(a0)+
	beq	_as_li		;ea/ccr/sr

	lea	FIELDNEXT(FIELDPTR),a0	;ordre indispensable!
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.notdn1
	tst.b	(a0)		;TOKENEOL
	bmi	Ea_Dn
	bra.s	.noteqr1

.notdn1:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.noteqr1
	cmp.b	#TOKEND7,d0
	bls	Ea_Dn

.noteqr1:	move.l	FIELDPTR,a0	;@ 1st field
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.notdn2
	tst.b	(a0)		;TOKENEOL
	bmi	Dn_Ea
	bra.s	.noteqr2

.notdn2:	lea	FIELDNEXT(FIELDPTR),a0
	bsr	GetEqur
	bmi.s	.noteqr2
	cmp.b	#TOKEND7,d0
	bls	Ea_Dn

.noteqr2:	move.l	FIELDPTR,a0
	bsr	GetEqur
	bmi.s	.errea
	cmp.b	#TOKEND7,d0
	bls	Dn_Ea

.errea:	bra	Errea_forb
.erroper:	bra	Errbad_opernb

_logicccr:				;#i,ccr
	move.w	OpSize,d1
	bmi.s	.sizedef
	subq.w	#1,d1
	bgt.s	.rsize
.sizedef:	move.l	REF_left(REFPTR),EAOPCODE	;%0000001000111100
	lea	1(FIELDPTR),a0
	JNEVAL
	beq.s	.nopatch
	bmi.s	.rimm
	clr.w	EAOPCODE			;i=0
	bsr	LPokeOpBin		;opcode+i
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_DCW,d2		;provisoire il faut du BYTE
	jmp	StoreEXP			;d0/d1 set
.rsize:	bra	Errsz_forb
.rimm:	bra	ErrEv_immed
.nopatch:	cmp.l	#$ff,d0
	bhi.s	.rgeb
	move.w	d0,EAOPCODE		;i
	bra	LPokeOpBin		;opcode+i
.rgeb:	bra	Errsz_ge_b

_logicsr:	move.w	OpSize,d1
	bmi.s	.sizedef
	subq.w	#1,d1			;#i,sr
	bgt.s	.rsize
.sizedef:	tst.w	SuprFlg
	bne.s	.rsup
	move.l	REF_left(REFPTR),EAOPCODE	;%0000001001111100
	bset	#6+16,EAOPCODE
	lea	1(FIELDPTR),a0
	JNEVAL
	beq.s	.nopatch
	bmi.s	.rimm
	clr.w	EAOPCODE			;i=0
	bsr	LPokeOpBin		;opcode+i
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_DCW,d2
	jmp	StoreEXP			;d0/d1 set
.rsize:	bra	Errsz_forb
.rsup:	bra	Errsuper_forb
.rimm:	bra	ErrEv_immed
.nopatch:	;cmp.l	#$ffff,d0
	;bhi.s	.rgeb
	move.w	d0,EAOPCODE
	bra	LPokeOpBin
;.rgeb:	bra	Errsz_ge_w
;  #] AND,OR: 
;  #[ EOR:	Dn,ea//#i,ea//#i,ccr//#i,sr sized
;source: #i -> eori
_eor:	tst.w	OpSize
	bpl.s	.sizeset
	neg.w	OpSize
.sizeset:	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0)+,d0
	cmp.b	#'#',d0
	beq.s	_as_li
	cmp.b	#TOKEND7,d0
	bls	Dn_Ea
	bra	Errea_forb
.roper:	bra	Errbad_opernb
;  #] EOR: 
;  #[ ANDI,ORI,EORI:	#i,ea//#i,ccr//#i,sr sized Relocated
_as_li:	INCREF
	bra.s	_as_li2
_logici:	tst.w	OpSize
	bpl.s	.sizeset
	neg.w	OpSize
.sizeset:	subq.w	#2,FIELDSNB
	bne.s	.erroper
	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	#'#',(a0)+
	beq.s	_as_li2
.erri:	bra	Erri_exp
.erroper:	bra	Errbad_opernb
_as_li2:	move.w	FIELDNEXT(FIELDPTR),d0
	cmp.w	#(TOKENSR<<8)|TOKENEOL,d0
	beq.s	.sr
	cmp.w	#(TOKENCCR<<8)|TOKENEOL,d0
	beq.s	.ccr

	INCFIELD
	jsr	GetEa		;2nd field is ea
	move.w	REF_opcode(REFPTR),EAOPCODE
	move.w	OpSize,d0
	lsl.w	#6,d0
	or.w	d0,EAOPCODE	;size (7-6)
	move.w	EAOPCODE,OpCode
	bsr	BuildOp
	DECFIELD

	lea	1(FIELDPTR),a0
	JNEVAL			;1st field is i
	beq.s	.nopatch
	bmi.s	.errev

	moveq	#0,EAOPCODE
	move.w	OpSize,d2
	beq.s	.wpatch
	subq.w	#WORD_SIZE,d2
	beq.s	.wpatch
	bsr	LPokeBin
	moveq	#P_DCL,d2
	bra.s	.patch
.wpatch:	bsr	WPokeBin
	moveq	#P_DCW,d2
.patch:	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	jsr	StoreEXP		;d0/d1 set

	INCFIELD
	move.l	REF_right(REFPTR),d7
	jmp	BuildEa		;ea
.errev:	bra	ErrEv_immed
.sr:	bra	_logicsr
.ccr:	bra	_logicccr

.nopatch:	move.l	d0,EAOPCODE
	move.w	OpSize,d2
	beq.s	.bnopat
	subq.w	#WORD_SIZE,d2
	beq.s	.wnopat
	bsr	LPokeBin
	bra.s	.bea
.bnopat:	andi.w	#$ff,EAOPCODE
.wnopat:	bsr	WPokeBin
.bea:	INCFIELD
	move.l	REF_right(REFPTR),d7
	jmp	BuildEa		;ea
;  #] ANDI,ORI,EORI: 
;  #[ ASLR,LSLR,ROLR,ROXLR:	Dn,Dn//#i,Dn//ea//Dn ea sized Eqr
;1 element->
;	Dn->#1,Dn
;	ea->ea
;2 elements->
;	#1,ea->ea
;	Dn,Dn
;	#i,Dn
_shifts:	subq.w	#1,FIELDSNB
	bmi.s	.erroper
	beq	_1shifts		;one field->ea//dn
	subq.w	#1,FIELDSNB
	bgt.s	.erroper		;2 fields max->dn,dn//#i,dn

	lea	FIELDNEXT(FIELDPTR),a0	;2nd field
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0	;,equr//,ea
	bhi.s	.notdn
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
.asdn:	or.b	d0,EAOPCODE	;2nd Dn done

	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0)+,d0
	cmp.b	#'#',d0
	beq.s	.i		;#i,Dn
	cmp.b	#TOKEND7,d0	;Dn,Dn
	bhi.s	.equr
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo

.dn_dn:	bset	#5,EAOPCODE	;Dn flag (5)
	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE	;count/reg (11-9)
	move.w	OpSize,d0
	bpl.s	.sizeset
	neg.w	d0
.sizeset:	lsl.b	#6,d0
	or.b	d0,EAOPCODE	;size (7-6)
	bra	WPokeOpBin
.erroper:	bra	Errbad_opernb
.err8:	bra	Errshift_ge_8

.notdn:	INCFIELD
	jsr	GetEa		;,ea
	DECFIELD
	tst.b	EA_mode(EAPTR)	;DN_MODE
	bne.s	.as_ea
	move.b	EA_an(EAPTR),d0
	cmp.b	#TOKEND7,d0
	bls.s	.asdn
	bra.s	.rdn

.equr:	subq.w	#1,a0		;equr,
	bsr	GetEqur
	bmi.s	.errea
	cmp.b	#TOKEND7,d0
	bls.s	.dn_dn
.rdn:	bra	Errdn_exp
.errea:	bra	Errea_forb
.reoo:	bra	Erreoo_exp

.i:	JNEVAL			;#:(#i,Dn//#1,ea)
	bgt.s	.8		;as 0
	bmi.s	.errev
	tst.l	d0
	ble.s	.err8
	moveq	#8,d2
	cmp.l	d2,d0
	beq.s	.8
	bhi.s	.err8
	moveq	#9,d2
	lsl.w	d2,d0
	or.w	d0,EAOPCODE	;count/reg (11-9)
.8:	move.w	OpSize,d2
	bpl.s	.isize
	neg.w	d2
.isize:	lsl.b	#6,d2
	or.b	d2,EAOPCODE	;size (7-6)
	tst.l	d1
	beq	WPokeOpBin
	bsr	WPokeOpBin
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_W911,d2
	jmp	StoreEXP		;d0/d1 set

.as_ea:	move.l	FIELDPTR,a0
	cmp.b	#'#',(a0)+
	bne.s	.errea
	JNEVAL
	beq.s	.eaok
	bmi.s	.errev

	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_EA1,d2
	jsr	StoreEXP		;d0/d1 set
	bra.s	.bea
.errev:	bra	ErrEv_immed
.eaok:	subq.l	#1,d0
	bne.s	.errea1
.bea:	move.w	OpSize,d0
	bmi.s	.easize
	subq.w	#WORD_SIZE,d0
	bne.s	.errw
.easize:	move.w	#%11,OpSize
	move.w	REF_right(REFPTR),OpCode	;ea opcode
	bsr	BuildOp
	INCFIELD
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa
.errea1:	bra	Errshift_ea_1
.errw:	bra	Errw_exp

_1shifts:	move.l	FIELDPTR,a0			;@ 1st field
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.notdn
	tst.b	(a0)			;TOKENEOL
	bpl.s	.notdn	
	or.b	d0,EAOPCODE		;#1,Dn->Dn
.as_dn:	move.w	OpSize,d1
	bpl.s	.sizeset
	neg.w	d1
.sizeset:	lsl.w	#6,d1			;size 7-6
	or.w	d1,EAOPCODE
	bset	#9,EAOPCODE		;#1
	bra	WPokeOpBin
.equr:	or.b	EA_an(EAPTR),EAOPCODE	;Dn
	bra.s	.as_dn
.notdn:	jsr	GetEa			;check ea or equr
	tst.b	EA_mode(EAPTR)		;DN_MODE if equr
	beq.s	.equr
	move.w	OpSize,d0
	bmi.s	.sizedef
	subq.w	#WORD_SIZE,d0
	bne.s	.errw
.sizedef:	move.w	REF_right(REFPTR),EAOPCODE	;ea opcode
	move.w	#%11,OpSize
	move.w	EAOPCODE,OpCode
	bsr	BuildOp
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa
.errw:	bra	Errw_exp
;  #] ASLR,LSLR,ROLR,ROXLR: 
;  #[ BCHG,BCLR,BSET:	Dn,ea//#i,ea sized differently Equated
_bitop:	subq.w	#2,FIELDSNB
	bne.s	.erroper
	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0)+,d0
	cmp.b	#'#',d0
	beq.s	_bitopi
	cmp.b	#TOKEND7,d0
	bhi.s	.rdn
.dn_ea:	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE

	move.w	EAOPCODE,OpCode
	INCFIELD
	jsr	GetEa

	move.w	OpSize,d0
	bmi.s	.sizedef
	tst.b	EA_mode(EAPTR)	;Dn->long
	beq.s	.must_l
	tst.w	d0		;other must be byte
	beq.s	.sizedef
.errsize:	bra	Erropsz_forb
.erroper:	bra	Errbad_opernb
.rdn:	bra	Errea_forb
.must_l:	subq.w	#LONG_SIZE,d0
	bne.s	.errsize
.sizedef:	bsr	BuildOp
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa

;In:a0=immed	#i,ea
_bitopi:	move.w	REF_right(REFPTR),OpCode
	JEAEVAL				;f0/ea0
	beq.s	.nopatch
	bmi.s	.errev

	moveq	#0,EAOPCODE
	INCEA
	INCFIELD
	jsr	GetEa			;f1/ea1
	bsr.s	.chkbiti
	bsr	BuildOp
	bsr	WPokeBin
	DECFIELD
	DECEA
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	movem.l	EA_value(EAPTR),d0-d1
	moveq	#P_BIT32,d2		;a changer
	tst.b	EA_mode(EAPTR)		;Dn->long+<32
	beq.s	.patchdn
	moveq	#P_BIT8,d2
.patchdn:	jsr	StoreEXP			;d0/d1 set
	INCEA
	INCFIELD
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa
.errev:	bra	ErrEv_immed

.nopatch:	move.l	d0,EAOPCODE
	INCEA
	INCFIELD
	jsr	GetEa			;f1/ea1
	bsr.s	.chkbiti
	bsr	BuildOp
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa

.chkbiti:	tst.l	EAOPCODE			;#i>=0
	bmi.s	.errge64

	tst.b	EA_mode(EAPTR)		;Dn->long+<32
	beq.s	.dn

	move.w	OpSize,d0
	bgt.s	.errsize			;ea->byte+<8
	move.w	#1,OpSize
	moveq	#7,d0
	cmp.l	d0,EAOPCODE
	bhi.s	.warn8
	rts
.dn:	move.w	OpSize,d0
	bmi.s	.sizedef
	subq.w	#LONG_SIZE,d0
	bne.s	.errsize
.sizedef:	move.w	#1,OpSize
	moveq	#31,d0
	cmp.l	d0,EAOPCODE
	bhi.s	.warn32
	rts
.errsize:	bra	Erropsz_forb
.errge64:	bra	Errbitge64
.warn8:	moveq	#63,d0			;#i<64
	cmp.l	d0,EAOPCODE
	bhi.s	.errge64
	bra	Warn_bitmod8
.warn32:	moveq	#63,d0			;#i<64
	cmp.l	d0,EAOPCODE
	bhi.s	.errge64
	bra	Warn_bitmod32
;  #] BCHG,BCLR,BSET: 
;  #[ BTST:	Dn,ea//#i,ea
_btst:	subq.w	#2,FIELDSNB
	bne.s	.erroper
	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	ble.s	.dn_ea
	cmp.b	#'#',d0
	beq	_bitopi
	bra	Errea_forb
.erroper:	bra	Errbad_opernb
.dn_ea:	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	move.w	EAOPCODE,OpCode
	INCFIELD
	jsr	GetEa

	move.w	OpSize,d0
	bmi.s	.sizedef
	tst.b	EA_mode(EAPTR)
	beq.s	.must_l
	tst.w	d0		;must_be_byte
	bne.s	.errsize
.sizedef:	move.w	#1,OpSize
	bsr	BuildOp

	move.l	REF_left(REFPTR),d7
	bset	#12,d7			;#i
	jmp	BuildEa
.must_l:	subq.w	#LONG_SIZE,d0
	beq.s	.sizedef
.errsize:	bra	Erropsz_forb
;  #] BTST: 
;  #[ BFEXTUS,BFFFO:	Bitfields diadiques ea{},Dn real sized Eqr	;20/30/40
_bitfdia:	cmp.w	#MPU_20,MPUType
	blt.s	.rmpu
	subq.w	#3,FIELDSNB
	bne.s	.roper
	move.w	EAOPCODE,OpCode		;1st word 1st field
	jsr	GetEa
	bsr	BuildOp

	lea	FIELDNEXT*2(FIELDPTR),a0		;2nd word but 3rd field
	moveq	#0,EAOPCODE
	move.b	(a0)+,EAOPCODE
	cmp.b	#TOKEND7,EAOPCODE
	bhi.s	.equr
.asdn:	moveq	#12,d1
	lsl.w	d1,EAOPCODE
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
	INCFIELD
	bsr	_dobitf			;2nd field
	DECFIELD
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa
.rmpu:	bra	Err20_forb
.roper:	bra	Errbad_opernb
.reoo:	bra	Erreoo_exp
.equr:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.rdn
	move.b	d0,EAOPCODE
	cmp.b	#TOKEND7,EAOPCODE
	bls.s	.asdn
.rdn:	bra	Errdn_exp
;  #] BFEXTUS,BFFFO: 
;  #[ BFINS:	Bitfields diadiques Dn,ea{} real sized	;20/30/40
_bitf2dia:
	cmp.w	#MPU_20,MPUType
	blt.s	.rmpu
	subq.w	#3,FIELDSNB
	bne.s	.roper
	move.w	EAOPCODE,OpCode
	INCFIELD			;1st word but 2nd field
	jsr	GetEa
	bsr	BuildOp

	lea	FIELDPREV(FIELDPTR),a0	;2nd word but 1st field
	moveq	#0,EAOPCODE
	move.b	(a0)+,EAOPCODE
	cmp.b	#TOKEND7,EAOPCODE
	bhi.s	.equr
.asdn:	moveq	#12,d1
	lsl.w	d1,EAOPCODE
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
	INCFIELD
	bsr.s	_dobitf		;3rd field
	DECFIELD
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa
.rmpu:	bra	Err20_forb
.roper:	bra	Errbad_opernb
.reoo:	bra	Erreoo_exp
.equr:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.rdn
	move.b	d0,EAOPCODE
	cmp.b	#TOKEND7,EAOPCODE
	bls.s	.asdn
.rdn:	bra	Errdn_exp
;  #] BFINS: 
;  #[ BFCHG,BFCLR,BFSET,BFTST:	Bitfields monadiques ea{} real sized	;20/30/40
_bitfmona:
	cmp.w	#MPU_20,MPUType
	blt.s	.rmpu
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.w	EAOPCODE,OpCode	;1st word/1st field
	jsr	GetEa
	bsr	BuildOp
	moveq	#0,EAOPCODE	;2nd word/2nd field
	INCFIELD
	bsr.s	_dobitf		;2nd field
	DECFIELD
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa
.rmpu:	bra	Err20_forb
.roper:	bra	Errbad_opernb

FOPENED_BRACE	equr	d7
FCLOSED_BRACE	equr	d6
FSEMI_COLON	equr	d5
_dobitf:	INCEA
	moveq	#'{',d7
	moveq	#'}',d6
	moveq	#':',d5
	move.l	FIELDPTR,a0
	cmp.b	(a0)+,FOPENED_BRACE
	bne.s	.rbra
	moveq	#0,d0			;Offset
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	ble.s	.dn_1
	subq.w	#1,a0
	move.l	a0,a1
.l1:	move.b	(a1)+,d0
	bmi.s	.rsemi
	cmp.b	FSEMI_COLON,d0
	bne.s	.l1
	SETEOL	-1(a1)
	move.l	a1,-(sp)
	JNEVAL
	bmi.s	.rimm
	beq.s	.nopat1
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_W610,d2
	jsr	StoreEXP			;d0/d1 set
	move.l	(sp)+,a0
	moveq	#0,d0
	bra.s	.good1
.rbra:	bra	Errbrace_exp
.rsemi:	bra	Errsemi_exp
.rimm:	addq.w	#4,sp
	bra	ErrEv_immed
.nopat1:	move.l	(sp)+,a0
	cmp.l	#31,d0
	bls.s	.good1
	bra.s	.rge32
.dn_1:	bset	#11,EAOPCODE		;D1 flag
	cmp.b	(a0)+,FSEMI_COLON
	bne.s	.rsemi
.good1:	lsl.w	#6,d0
	or.w	d0,EAOPCODE
	moveq	#0,d0			;Width
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bls.s	.dn_2
	subq.w	#1,a0
	move.l	a0,a1
.l2:	move.b	(a1)+,d0
	bmi.s	.rbrac
	cmp.b	FCLOSED_BRACE,d0
	bne.s	.l2
	tst.b	(a1)			;TOKENEOL
	bpl.s	.reoo
	SETEOL	-1(a1)
	move.l	a0,-(sp)
	JNEVAL
	bmi.s	.rimm2
	move.l	(sp)+,a0
	beq.s	.nopat2
	move.l	LINE_srccomma(FIELDPTR),a1
	moveq	#P_W05,d2
	jsr	StoreEXP			;d0/d1 set
	bra.s	.end
.reoo:	bra	Erreoo_exp
.rimm2:	addq.w	#4,sp
	bra	ErrEv_immed
.rbrac:	bra	Errbrace_exp
.nopat2:	moveq	#32,d1
	cmp.l	d1,d0
	beq.s	.end
	blt.s	.good2
.rge32:	bra	Errwidth_ge_32
.dn_2:	bset	#5,EAOPCODE		;D2 flag
	cmp.b	(a0)+,FCLOSED_BRACE		;'}'
	bne.s	.rbrac
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
.good2:	or.w	d0,EAOPCODE
.end:	DECEA
	bra	WPokeBin
;  #] BFCHG,BFCLR,BFSET,BFTST: 
;  #[ Bcc,BRA,BSR:	PCrel
_bcc:	subq.w	#1,FIELDSNB
	bne.s	.roper
	tst.w	OptiBBccFlg
	bne.s	.opti
.noopti:	move.l	FIELDPTR,a0		;@ 1st field
	JNEVAL
	ble.s	.rev
	move.l	LINE_srcstart(FIELDPTR),a1
	move.w	OpSize,d2
	bmi.s	.word
	beq.s	.short
	subq.w	#1,d2
	beq.s	.word
	subq.w	#1,d2
	beq.s	.long
	bra.s	.short		;SINGLE
.asword:	move.l	LINE_srcstart(FIELDPTR),a1
.word:	bsr	WPokeOpBin		;opcode
	moveq	#0,EAOPCODE
	bsr	WPokeBin		;disp
	moveq	#P_BCCW,d2
	jmp	StoreEXP		;d0/d1 set
.short:	bsr	WPokeOpBin	;opcode+disp(0)
	moveq	#P_BCCB,d2
	jmp	StoreEXP
.long:	cmp.w	#MPU_32,MPUType
	blt.s	.rmpu
	st	EAOPCODE		;move.b #-1,EAOPCODE
	bsr	WPokeOpBin
	moveq	#0,EAOPCODE
	bsr	LPokeBin
	moveq	#P_BCCL,d2
	jmp	StoreEXP		;d0/d1 set
.roper:	bra	Errbad_opernb
.rev:	bra	ErrEv_pc
.rmpu:	bra	Err20_forb
.opti:	tst.w	OpSize
	bpl.s	.noopti
	move.l	FIELDPTR,a0		;@ 1st field
	JOEVAL
	ble.s	.rev
	cmp.b	#EVAL_OPTI,d1
	bne.s	.asword
	swap	d1
	subq.b	#1,d1
	cmp.b	CurSecType+1,d1
	bne	.noopti
	subq.l	#2,d0
	sub.l	SecSize,d0	;-=PC
	btst	#0,d0
	bne.s	.wodd
.aodd:	move.b	d0,d1
	ext.w	d1
	cmp.w	d0,d1
	bne.s	.notbyte
	move.b	d0,EAOPCODE
	bsr	WPokeOpBin	;opcode+disp(0)
	bra	Opti_bwbcc2b
.notbyte:	move.w	d0,d1
	ext.l	d1
	cmp.l	d0,d1
	bne.s	.notword
	bsr	WPokeOpBin	;opcode
	move.l	d0,EAOPCODE
	bra	WPokeBin		;disp
.notword:	cmp.w	#MPU_20,MPUType
	blt.s	.rgew
	st	EAOPCODE		;move.b #-1,EAOPCODE
	bsr	WPokeOpBin
	move.l	d0,EAOPCODE
	bsr	LPokeBin
	bra	Opti_bwbcc2l
.rgew:	bra	Err_wunreach
.wodd:	move.l	d0,-(sp)
	bsr	Warn_oddbranch
	move.l	(sp)+,d0
	bra.s	.aodd

;	ble.s	.notbyte
;	neg.l	d1		;-127->+128
;	cmp.l	d1,d0
;	bgt.s	.notbyte
;	;bsr	Warn_
;	move.b	d0,EAOPCODE
;	bra	WPokeOpBin	;opcode+disp(0)
;.notbyte:	move.w	#-32768,d1	;-32767<=x<=+32768
;	cmp.l	d1,d0
;	ble.s	.notword
;	neg.l	d1
;	cmp.l	d1,d0
;	bgt.s	.notword
;;	bsr	Warn_
;	bsr	WPokeOpBin	;opcode
;	move.l	d0,EAOPCODE
;	bra	WPokeBin		;disp
;.notword:	st	EAOPCODE		;move.b #-1,EAOPCODE
;	;bsr	Warn_
;	bsr	WPokeOpBin
;	move.l	d0,EAOPCODE
;	bra	LPokeBin
;.short_0:	cmp.b	#$61,EAOPCODE
;	beq.s	.rbsr
;	move.w	#$4e71,EAOPCODE
;	bsr	WPokeOpBin
;	bra	Opti_zbccb2nop
;.rbsr:	bra	Errilleg_bsrs

;	subq.l	#2,d0
;	sub.l	SecSize,d0	;-=PC
;	beq.s	.short_0
;	moveq	#-128,d1		;-127<=x<=+128
;	cmp.l	d1,d0
;	ble.s	.notbyte
;	neg.l	d1		;-127->+128
;	cmp.l	d1,d0
;	bgt.s	.notbyte
;	;bsr	Warn_
;	move.b	d0,EAOPCODE
;	bra	WPokeOpBin	;opcode+disp(0)
;.notbyte:	move.w	#-32768,d1	;-32767<=x<=+32768
;	cmp.l	d1,d0
;	ble.s	.notword
;	neg.l	d1
;	cmp.l	d1,d0
;	bgt.s	.notword
;;	bsr	Warn_
;	bsr	WPokeOpBin	;opcode
;	move.l	d0,EAOPCODE
;	bra	WPokeBin		;disp
;.notword:	st	EAOPCODE		;move.b #-1,EAOPCODE
;	;bsr	Warn_
;	bsr	WPokeOpBin
;	move.l	d0,EAOPCODE
;	bra	LPokeBin
;.short_0:	cmp.b	#$61,EAOPCODE
;	beq.s	.rbsr
;	move.w	#$4e71,EAOPCODE
;	bsr	WPokeOpBin
;	bra	Opti_zbccb2nop
;.rbsr:	bra	Errilleg_bsrs

;  #] Bcc,BRA,BSR: 
;  #[ BKPT:	#i real unsized	;10/20/30/40/32
_bkpt:	tst.w	MPUType
	beq.s	.rmpu
	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JNEVAL
	beq.s	.nopat
	bmi.s	.rev
	bsr	WPokeOpBin	;EAOPCODE set
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_W02,d2
	jmp	StoreEXP		;d0/d1 set
.rmpu:	bra	Err10_forb
.roper:	bra	Errbad_opernb
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed
.nopat:	cmp.l	#8,d0
	bhi.s	.rge8
	or.w	d0,EAOPCODE
	bra	WPokeOpBin
.rge8:	bra	Errbkptge_8
;  #] BKPT: 
;  #[ DBcc:	PCrel
_dbcc:	subq.w	#2,FIELDSNB
	bne.s	.roper
	INCFIELD
	move.l	FIELDPTR,a0
	JNEVAL
	ble.s	.rev
	movem.l	d0-d1,-(sp)
	DECFIELD
	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.equr
.asdn:	or.b	d0,EAOPCODE
	bsr	WPokeOpBin
	moveq	#0,EAOPCODE
	bsr	WPokeBin
	movem.l	(sp)+,d0-d1
	INCFIELD
	move.l	LINE_srcstart(FIELDPTR),a1
	moveq	#P_DBCC,d2
	jmp	StoreEXP		;d0/d1 set
.equr:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.rdn
	cmp.b	#TOKEND7,d0
	bls.s	.asdn
.rdn:	addq.w	#8,sp
	bra	Errdn_exp
.roper:	bra	Errbad_opernb
.rev:	moveq	#0,d2
	bra	ErrEv_pc
;  #] DBcc: 
;  #[ CAS:	Dn,Dn,ea sized	;20/30/40
_cas:	cmp.w	#MPU_20,MPUType
	blt.s	.rmpu
	subq.w	#3,FIELDSNB
	bne.s	.roper
	INC2FIELD		;ea 3rd field
	jsr	GetEa

	move.w	OpSize,d0		;size
	bpl.s	.not_def
	moveq	#%01,d0
.not_def:	addq.w	#1,d0
	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	move.w	EAOPCODE,OpCode
	bsr	BuildOp	;build 1st word

	lea	FIELDPREV*2(FIELDPTR),a0		;Dc
	moveq	#0,EAOPCODE
	move.b	(a0)+,EAOPCODE
	cmp.b	#TOKEND7,EAOPCODE
	bhi.s	.equr1
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo

.asdn1:	lea	FIELDPREV(FIELDPTR),a0	;Dn
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.equr2
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo

.asdn2:	lsl.w	#6,d0
	or.w	d0,EAOPCODE
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa
.rmpu:	bra	Err20_forb
.roper:	bra	Errbad_opernb
.reoo:	bra	Erreoo_exp
.equr1:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.rdn
	cmp.b	#TOKEND7,d0
	bhi.s	.asdn1
.rdn:	bra	Errdn_exp
.equr2:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.rdn
	cmp.b	#TOKEND7,d0
	bhi.s	.asdn2
	bra.s	.rdn
;  #] CAS: 
;  #[ CAS2:Dn:	Dn,DN:Dn,(Xn):(Xn) real unsized Eqr	;20/30/40
_cas2:	cmp.w	#MPU_20,MPUType
	blt	.rmpu
	subq.w	#3,FIELDSNB
	bne	.roper
	move.w	OpSize,d0
	bpl.s	.sizedef
	moveq	#%01,d0
.sizedef:	addq.w	#1,d0
	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	bsr	WPokeOpBin

	moveq	#0,EAOPCODE		;1st word
	moveq	#0,d5			;2nd ds d5
	moveq	#':',d6
	moveq	#TOKEND7,d7

	moveq	#'(',d3

	move.l	FIELDPTR,a0			;1st field = Dc1:Dc2
	move.b	(a0)+,EAOPCODE		;Dc1
	cmp.b	d7,EAOPCODE
	bhi.s	.equr1
.asdn1:	cmp.b	(a0)+,d6			;':'
	bne.s	.rsemi
	move.b	(a0)+,d5			;Dc2
	cmp.b	d7,d5
	bhi.s	.equr2
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo

.asdn2:	lea	LINE_SIZEOF(FIELDPTR),FIELDPTR		;2nd field = Du1:Du2
	move.l	FIELDPTR,a0
	moveq	#0,d0
	move.b	(a0)+,d0			;Du1
	cmp.b	d7,d0
	bhi.s	.equr3

.asdn3:	cmp.b	(a0)+,d6			;':'
	bne.s	.rsemi

	lsl.w	#6,d0
	or.w	d0,EAOPCODE
	moveq	#0,d0
	move.b	(a0)+,d0			;Du2
	cmp.b	d7,d0
	bhi.s	.equr4

	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo

.asdn4:	lsl.w	#6,d0
	or.w	d0,d5
	bra.s	.rn
.equr1:	subq.w	#1,a0
	move.b	d6,d0
	bsr	GetEqur2
	bmi.s	.reqr1
	move.b	d0,EAOPCODE
	cmp.b	d7,d0
	bls.s	.asdn1
.rdn:	bra	Errdn_exp
.rmpu:	bra	Err20_forb
.reoo:	bra	Erreoo_exp
.roper:	bra	Errbad_opernb
.reqr1:	addq.w	#1,d0
	beq.s	.rdn
.rsemi:	bra	Errsemi_exp
.ropar:	bra	Erropar_exp
.rcpar:	bra	Errcpar_exp
.equr2:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.rdn
	move.b	d0,d5
	cmp.b	d7,d0
	ble.s	.asdn2
	bra.s	.rdn
.equr3:	subq.w	#1,a0
	move.b	d6,d0
	bsr	GetEqur2
	bmi.s	.reqr1
	cmp.b	d7,d0
	ble.s	.asdn3
	bra.s	.rdn
.equr4:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.rdn
	cmp.b	d7,d0
	ble.s	.asdn4
	bra.s	.rdn
.rn:	lea	LINE_SIZEOF(FIELDPTR),a0		;(Rn1):(Rn2)
	cmp.b	(a0)+,d3			;'('
	bne.s	.ropar

	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	d7,d0
	bls.s	.dn_1
	cmp.b	#TOKENA7,d0
	bhi.s	.equr5
	subq.b	#TOKENA0,d0
	bset	#3,d0
.dn_1:	cmp.b	#')',(a0)+
	bne.s	.rcpar
	moveq	#12,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE

	cmp.b	(a0)+,d6			;':'
	bne.s	.rsemi
	cmp.b	(a0)+,d3			;'('
	bne.s	.ropar

	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	d7,d0
	ble.s	.dn_2
	cmp.b	#TOKENA7,d0
	bhi.s	.equr6
	subq.b	#TOKENA0,d0
	bset	#3,d0
.dn_2:	cmp.b	#')',(a0)+
	bne.s	.rcpar
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo2
	moveq	#12,d1
	lsl.w	d1,d0
	or.w	d0,d5
	swap	EAOPCODE
	move.w	d5,EAOPCODE
	bra	LPokeBin
.reoo2:	bra	Erreoo_exp
.equr5:	subq.w	#1,a0
	moveq	#')',d0
	bsr	GetEqur2
	bmi.s	.reqr2
	cmp.b	d7,d0
	ble.s	.dn_1
	subq.b	#TOKENA0,d0
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.rxn
	bset	#3,d0		;An
	bra.s	.dn_1
.equr6:	subq.w	#1,a0
	moveq	#')',d0
	bsr	GetEqur2
	bmi.s	.reqr2
	cmp.b	d7,d0
	ble.s	.dn_2
	subq.b	#TOKENA0,d0
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.rxn
	bset	#3,d0		;An
	bra.s	.dn_2
.reqr2:	addq.w	#1,d0
	bne	.rcpar
.rxn:	bra	Errxn_exp
;  #] CAS2: 
;  #[ CHK:	ea,Dn sized
_chk:	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.w	OpSize,d0
	bpl.s	.sizeset
	neg.w	OpSize
	bra.s	.word
.sizeset:	subq.w	#1,d0
	bne.s	.long
.word:	bset	#7,EAOPCODE
.long:	bset	#8,EAOPCODE

	jsr	GetEa		;1ere ea
	INCFIELD
	move.l	FIELDPTR,a0		;registre
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.rdn
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	move.w	EAOPCODE,OpCode
	bsr	BuildOp	;ea
	DECFIELD
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa
.roper:	bra	Errbad_opernb
.rdn:	bra	Errdn_exp
.reoo:	bra	Erreoo_exp
;  #] CHK: 
;  #[ CHK2,CMP2:	ea,Rn sized	;20/30/40/32
_chk2:	cmp.w	#MPU_20,MPUType
	blt.s	.rmpu
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.w	OpSize,d0
	bpl.s	.set
	neg.w	OpSize
	neg.w	d0
.set: 	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	move.w	EAOPCODE,OpCode
	jsr	GetEa		;1ere ea
	bsr	BuildOp	;poker 1st word

	move.w	REF_opcode+2(REFPTR),EAOPCODE	;registre
	lea	FIELDNEXT(FIELDPTR),a0		;@ 2nd field
	moveq	#0,d0
	move.b	(a0)+,d0
	moveq	#TOKENA0,d1
	cmp.b	d1,d0
	blt.s	.dn
	cmp.b	#TOKENA7,d0
	bhi.s	.rdn
	sub.b	d1,d0
	bset	#15,EAOPCODE
.dn:	moveq	#12,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	jmp	BuildEa
.rmpu:	bra	Err20_forb
.roper:	bra	Errbad_opernb
.rdn:	bra	Errdn_exp
.reoo:	bra	Erreoo_exp
;  #] CHK2,CMP2: 
;  #[ CMP:	ea,Dn//ea,An//#i,ea//Dn,ea//(An)+,(An)+//-(A0),-(A1) sized
;#i,ea->CMPI

;ea-{Dn,#i},Dn->CMP
;ea,An->CMPA

;regarder source
;si #i,ea-{An} alors #i,ea ->CMPI
;si #i,An alors ea,An ->CMPA
;regarder dest
;si ea,Dn alors ea,Dn ->CMP
;s1 ea,An alors ea,An ->CMPA
;regarder source:
;si Dn,ea alors Dn,ea ->CMP
;si pas '(' checker equr
;regarder dest:
;si '(', alors (an)+,(an)+	->CMPM
;si equr alors Dn ou An

;sinon Errea_forb (ea,ea)
_cmp:	tst.w	OpSize
	bpl.s	.set
	neg.w	OpSize
.set:	cmp.w	#2,FIELDSNB
	bne.s	.roper
	lea	FIELDNEXT(FIELDPTR),a0
	move.b	(a0),d0
	cmp.b	#TOKEND7,d0	;ea-{#i},Dn
	bls	Ea_Dn
	subq.b	#TOKENA0,d0
	cmp.b	#TOKENA7-TOKENA0,d0	;ea-{#i},An
	bls	_as_arithma

	cmp.b	#'(',(a0)
	beq.s	.noteadn
	bsr	GetEqur
	bmi.s	.noteadn

	cmp.b	#TOKEND7,d0	;ea-{#i},Dn
	bls	Ea_Dn
	subq.b	#TOKENA0,d0
	cmp.b	#TOKENA7-TOKENA0,d0	;ea-{#i},An
	bls	_as_arithma
.rforb:	bra	Errea_forb
.roper:	bra	Errbad_opernb

.noteadn:
;;;;;;;;;;;;;;;;;;
	cmp.b	#'#',(FIELDPTR)	;#i,xxx
	beq.s	.i
;;;;;;;;;;;;;;;;;;
	move.l	FIELDPTR,a0
	move.b	(a0),d0
	cmp.b	#TOKEND7,d0	;Dn,ea-{Dn,An}
	bls	Dn_Ea
	cmp.b	#'(',d0
	beq.s	.notdnea
	bsr	GetEqur
	bmi.s	.rforb
	cmp.b	#TOKEND7,d0	;Dn,ea-{Dn,An}
	bls	Dn_Ea
.notdnea:
.cmpm:	move.l	FIELDPTR,a0	;ea-{#i,Dn},ea-{Dn,An}
	lea	FIELDNEXT(FIELDPTR),a1
	bra	_as_cmpm		;ea-{#i,Dn},(...
				;OpSize,a1 et a0 positionnes
.reval:	bra	ErrEv_immed
.doa:	bra	_as_arithma

.iftst:	tst.l	EA_vtype(EAPTR)
	bne.s	.notst
	tst.l	EA_value(EAPTR)
	bne.s	.notst
	lea	FIELDNEXT(FIELDPTR),FIELDPTR	;field++
	move.w	#%0100101000000000,EAOPCODE	;opcode is TST
	moveq	#1,FIELDSNB			;one field only
	bsr	_monadea
	bra	Opti_cmp2tst

.i:	lea	1(FIELDPTR),a0
	JEAEVAL
	bmi.s	.reval
	lea	FIELDNEXT(FIELDPTR),a0
	move.b	(a0),d0
	cmp.b	#TOKEND7,d0
	bls.s	.doi
	subq.b	#TOKENA0,d0
	cmp.b	#TOKENA7-TOKENA0,d0
	bls.s	.doa
	bsr	GetEqur
	bmi.s	.doi
	cmp.b	#TOKEND7,d0
	bls.s	.doi
	subq.b	#TOKENA0,d0
	cmp.b	#TOKENA7-TOKENA0,d0
	bls.s	.doa
.doi:	tst.w	OptiCmp2TstFlg
	bne.s	.iftst
.notst:	move.b	#IMMEDIATE_MODE,EA_mode(EAPTR)
	move.b	#IMMEDIATE_REG,EA_an(EAPTR)
	INC2REF

_ci:	move.w	REF_opcode(REFPTR),EAOPCODE
	move.w	OpSize,d0
	lsl.w	#6,d0			;taille 6-7
	or.w	d0,EAOPCODE
	move.w	EAOPCODE,OpCode		;opcode
	INCEA
	INCFIELD
	jsr	GetEa			;<ea>
	bsr	BuildOp		;opcode
	DECEA				;reset flags
	DECFIELD
	move.l	REF_left(REFPTR),d7
	jsr	BuildEa			;#i
	INCEA
	INCFIELD
	move.l	REF_right(REFPTR),d7
	cmp.w	#MPU_10,MPUType
	bhi.s	.pcok
	andi.l	#%11111111111111111001111111111111,d7	;forbid d16PC d8PC
.pcok:	jmp	BuildEa			;<ea>

_cmpi:	tst.w	OpSize
	bpl.s	.sizeset
	neg.w	OpSize
.sizeset:	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.b	#IMMEDIATE_MODE,EA_mode(EAPTR)
	move.b	#IMMEDIATE_REG,EA_an(EAPTR)
	move.l	FIELDPTR,a0		;@ 1st field
	cmpi.b	#'#',(a0)+
	bne.s	.ri
	JEAEVAL
	bmi.s	.rev
	bra	_ci
.roper:	bra	Errbad_opernb
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed

;  #] CMP: 
;  #[ CMPM:	(An)+,(An)+
_cmpm:	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.w	OpSize,d1
	bpl.s	.sizeset
	neg.w	OpSize
.sizeset:	move.l	FIELDPTR,a0		;@ 1st field
	lea	FIELDNEXT(FIELDPTR),a1
	bra.s	_do_cmpm
.roper:	bra	Errbad_opernb
_as_cmpm:	INC3REF
	move.w	REF_opcode(REFPTR),EAOPCODE
_do_cmpm:	moveq	#TOKENA0,d1
	moveq	#0,d7
	moveq	#0,d6
	cmp.b	#'(',(a1)+		;Ax=dest
	bne.s	.ropar
	move.b	(a1)+,d7
	sub.b	d1,d7
	bmi.s	.ran
	cmp.b	d1,d7
	bge.s	.ran
	cmp.b	#')',(a1)+
	bne.s	.rcpar
	cmp.b	#'+',(a1)+
	bne.s	.rplus
	tst.b	(a1)			;TOKENEOL
	bpl.s	.reoo

	cmp.b	#'(',(a0)+		;Ay=source
	bne.s	.ropar
	move.b	(a0)+,d6
	sub.b	d1,d6
	bmi.s	.ran
	cmp.b	d1,d6
	bge.s	.ran
	cmp.b	#')',(a0)+
	bne.s	.rcpar
	cmp.b	#'+',(a0)+
	bne.s	.rplus
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
	moveq	#9,d1
	lsl.w	d1,d7
	or.w	d7,EAOPCODE			;Ax
	or.w	d6,EAOPCODE			;Ay
	move.w	OpSize,d0
	lsl.w	#6,d0
	or.w	d0,EAOPCODE			;size
	bra	WPokeOpBin
.rea:	bra	Errea_forb
.ran:	bra	Erran_exp
.ropar:	bra	Erropar_exp
.rcpar:	bra	Errcpar_exp
.rplus:	bra	Errplus_exp
.reoo:	bra	Erreoo_exp
;  #] CMPM: 
;  #[ DIVUS,MULUS:	ea,Dn//ea,Dn:Dn	;xx	;20/30/40/32
;d7=Dr
;d6=Dq
_divwl:	subq.w	#2,FIELDSNB
	bne.s	.roper
	jsr	GetEa		;ea
	moveq	#0,d7		;Dr
	moveq	#0,d6		;Dq
	move.w	REF_right(REFPTR),OpCode	;opcode=long form opcode par defaut

	lea	FIELDNEXT(FIELDPTR),a0		;Dn field
	move.b	(a0)+,d7
	cmp.b	#LASTTOKEN,d7
	bhi.s	.eqr1
.aeqr1:	cmp.b	#TOKEND7,d7
	bhi.s	.rdn
	move.w	OpSize,d1
	move.b	(a0)+,d0
	cmp.b	#':',d0
	beq.s	.lformrq

	tst.w	d1
	bpl.s	.sizeset
	neg.w	OpSize
	bra.s	.wform
.roper:	bra	Errbad_opernb
.eqr1:	subq.w	#1,a0
	moveq	#':',d0
	bsr	GetEqur4
	move.l	d0,d7
	bpl.s	.aeqr1
.rdn:	bra	Errdn_exp
.sizeset:	subq.w	#WORD_SIZE,d1
	beq.s	.wform
;.long:
	tst.b	d0			;TOKENEOL
	bpl.s	.reoo
	cmp.w	#MPU_32,MPUType
	blt.s	.rmpu
	move.w	d7,d6			;Dq=Dr
	move.w	REF_right+2(REFPTR),EAOPCODE	;
	bra	_as_divl
.reoo:	bra	Erreoo_exp
.lformrq:	tst.w	d1			;DIV.L Dr:Dq
	bmi.s	.good
	cmp.w	#LONG_SIZE,d1
	bne.s	.rsize
.good:	move.b	(a0)+,d6			;Dq
	bmi.s	.rdn
	cmp.b	#LASTTOKEN,d6
	bhi.s	.eqr2
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
.aeqr2:	cmp.b	#TOKEND7,d6
	bhi.s	.rdn			;EQR!!
	cmp.w	#MPU_32,MPUType
	blt.s	.rmpu
	move.w	REF_right+2(REFPTR),EAOPCODE
	bset	#10,EAOPCODE		;Dr present
	bra	_as_divl
.rsize:	bra	Erropsz_forb
.rmpu:	bra	Err20_forb
.wform:	moveq	#9,d1
	lsl.w	d1,d7
	or.w	d7,EAOPCODE
	move.w	EAOPCODE,OpCode
	bsr	BuildOp
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.eqr2:	subq.w	#1,a0
	bsr	GetEqur
	move.l	d0,d6
	bpl.s	.aeqr2
	bra	.rdn
;  #] DIVUS,MULUS: 
;  #[ DIVUL,DIVSL:	ea,Dn:Dn			;20/30/40/32
_divl:	cmp.w	#MPU_32,MPUType
	blt.s	.rmpu
	subq.w	#2,FIELDSNB
	bne.s	.roper
	tst.w	OpSize
	bpl.s	.sizeset
	neg.w	OpSize
.sizeset:	jsr	GetEa
	moveq	#0,d7		;Dr
	moveq	#0,d6		;Dq
	move.w	EAOPCODE,OpCode

	lea	FIELDNEXT(FIELDPTR),a0	;Dn field
	move.b	(a0)+,d7		;Dn
	cmp.b	#LASTTOKEN,d7
	bhi.s	.eqr1
.aeqr1:	cmp.b	#TOKEND7,d7
	bhi.s	.rdn
	cmp.b	#':',(a0)+	;':'
	bne.s	.rsemi
	move.b	(a0)+,d6		;Dq
	bmi.s	.rdn
	cmp.b	#LASTTOKEN,d6
	bhi.s	.eqr2
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
.aeqr2:	cmp.b	#TOKEND7,d6
	bhi.s	.rdn
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	bra.s	_as_divl
.rmpu:	bra	Err20_forb
.roper:	bra	Errbad_opernb
.eqr1:	subq.w	#1,a0
	moveq	#':',d0
	bsr	GetEqur2
	move.l	d0,d7
	bpl.s	.aeqr1
	addq.w	#1,d0
	bne.s	.rsemi
.rdn:	bra	Errdn_exp
.rsemi:	bra	Errsemi_exp
.eqr2:	subq.w	#1,a0
	bsr	GetEqur
	move.l	d0,d6
	bpl.s	.aeqr2
	bra.s	.rdn
.reoo:	bra	Erreoo_exp

_as_divl:	bsr	BuildOp
	or.w	d7,EAOPCODE		;Dr
	moveq	#12,d1
	lsl.w	d1,d6
	or.w	d6,EAOPCODE		;Dq
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
;  #] DIVUL,DIVSL: 
;  #[ EXG:	Dn,Dn//Dn,An//An,Dn//An,An real unsized
;d7=Xx
;d6=Xy
;d5=
;Dx,Dy -> %01000
;Ax,Ay -> %01001
;Dx,Ay/Ax,Dy -> %10001
_exg:	subq.w	#2,FIELDSNB
	bne.s	.roper
	moveq	#0,d7
	moveq	#0,d6
	;dont touch EAOPCODE
	moveq	#TOKENA7,d3
	moveq	#TOKENA0,d2

	move.l	FIELDPTR,a0		;@ 1st field
	lea	FIELDNEXT(FIELDPTR),a1
	move.b	(a0)+,d7
	cmp.b	d2,d7
	blt	.Dx
	cmp.b	d3,d7
	bhi.s	.lequr
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
.Ax:	sub.b	d2,d7
	move.b	(a1)+,d6
	cmp.b	d2,d6
	blt.s	.Ax_Dy
	cmp.b	d3,d6
	bhi.s	.requr1
	tst.b	(a1)		;TOKENEOL
	bpl.s	.reoo
.Ax_Ay:	sub.b	d2,d6
	moveq	#%01001,d5
.build:	or.w	d6,EAOPCODE
	lsl.w	#3,d5
	or.w	d5,EAOPCODE
	moveq	#9,d1
	lsl.w	d1,d7
	or.w	d7,EAOPCODE
	bra	WPokeOpBin
.roper:	bra	Errbad_opernb
.Ax_Dy:	tst.b	(a1)		;TOKENEOL
	bpl.s	.reoo
.e_Ax_Dy:	moveq	#%10001,d5
	exg	d7,d6
	bra.s	.build
.lequr:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.rxn
	move.b	d0,d7
	cmp.b	d2,d7
	blt.s	.e_Dx
	cmp.b	d3,d7
	ble.s	.Ax
.rxn:	bra	Errxn_exp
.reoo:	bra	Erreoo_exp
.requr1:	lea	-1(a1),a0
	bsr	GetEqur
	bmi.s	.rxn
	move.b	d0,d6
	cmp.b	d2,d6
	blt.s	.e_Ax_Dy
	cmp.b	d3,d6
	ble.s	.Ax_Ay
	bra.s	.rxn
.requr2:	lea	-1(a1),a0
	bsr	GetEqur
	bmi.s	.rxn
	move.b	d0,d6
	cmp.b	d2,d6
	blt.s	.e_Dx_Dy
	cmp.b	d3,d6
	ble.s	.Dx_Ay
	bra.s	.rxn
.Dx:	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
.e_Dx:	move.b	(a1)+,d6
	cmp.b	d2,d6
	blt.s	.Dx_Dy
	cmp.b	d3,d6
	bhi.s	.requr2
	tst.b	(a1)		;TOKENEOL
	bpl.s	.reoo
.Dx_Ay:	sub.b	d2,d6
	moveq	#%10001,d5
	bra.s	.build
.Dx_Dy:	tst.b	(a1)		;TOKENEOL
	bpl.s	.reoo
.e_Dx_Dy:	moveq	#%01000,d5
	bra	.build
;  #] EXG: 
;  #[ EXT,EXTB:	Dn real unsized	;xx	;20/30/40/32
_extb:	cmp.w	#MPU_32,MPUType
	blt.s	.rmpu
	moveq	#%111,d2
	bra.s	_as_ext
.rmpu:	bra	Err20_forb
_ext:	moveq	#%010,d2		;default is word
	move.w	OpSize,d0
	bmi.s	.word
	subq.w	#WORD_SIZE,d0
	beq.s	.word
	moveq	#%011,d2		;long
.word:
_as_ext:	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.eqr
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
.asdn:	or.w	d0,EAOPCODE
	lsl.w	#6,d2
	or.w	d2,EAOPCODE
	bra	WPokeOpBin
.roper:	bra	Errbad_opernb
.reoo:	bra	Erreoo_exp
.eqr:	subq.w	#1,a0
	jsr	GetEqur
	bmi.s	.rdn
	cmp.b	#TOKEND7,d0
	bls.s	.asdn
.rdn:	bra	Errdn_exp
;  #] EXT,EXTB: 
;  #[ fsd1ari:	FSABS,FDABS,FSNEG,FDNEG,FSSQRT,FDSQRT	;40
_fsd1ari:
	cmp.w	#FPU_40,FPUType
	beq.s	_f1ari
	bra	Err_fpu_forb
;  #] fsd1ari: 
;  #[ f1ari:	ea,FPn//FPm,FPn//FPn	;81
;FABS,FACOS,FASIN,FATAN,FATANH,FCOS,FCOSH,FETOX,FETOXM1,FGETEXP,FGETMAN,FINT
;FINTRZ,FLOG10,FLOG2,FLOGN,FLOGNP1,FNEG,FSIN,FSQRT,FTAN,FTANH,FTENTOX
;FTWOTOX
_f1ari:	tst.w	FPUType
	beq.s	.rfpu
	tst.w	FIELDSNB
	ble.s	.roper
	cmp.w	#2,FIELDSNB
	bhi.s	.roper
	move.l	FIELDPTR,a0	;@ 1st field
	bsr	getfp
	bmi.s	.ea_fpn
	move.w	OpSize,d1		;fpn,fpn
	bmi.s	.sizedef
	cmp.w	#EXTEND_SIZE,d1
	bne.s	.rx
.sizedef:	bsr	WPokeOpBin
	move.w	REF_opcode+2(REFPTR),EAOPCODE

	moveq	#10,d1
	lsl.w	d1,d0		;source register
	or.w	d0,EAOPCODE
	subq.w	#1,FIELDSNB	;un seul champ
	bne.s	.tworegs
	lsr.w	#3,d0		;=lsl #7,d0
	or.w	d0,EAOPCODE
	bra	WPokeBin

.tworegs:	lea	FIELDNEXT(FIELDPTR),a0
	bsr	getfp
	bmi.s	.rfpn
	lsl.w	#7,d0		;destination register
	or.w	d0,EAOPCODE
	bra	WPokeBin
.rfpu:	bra	Err_fpu_forb
.roper:	bra	Errbad_opernb
.rx:	bra	Errx_exp
.rfpn:	bra	Errfp_exp

.ea_fpn:	tst.w	OpSize
	bpl.s	.sizeset
	neg.w	OpSize		;move.w	#%01,OpSize
.sizeset:	move.w	EAOPCODE,OpCode
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	bset	#14,EAOPCODE		;ea flag (R/M)
	lea	FIELDNEXT(FIELDPTR),a0		;fpn
	bsr.s	getfp
	bmi.s	.rfpn
	lsl.w	#7,d0
	or.w	d0,EAOPCODE
	bsr.s	getfpsize			;size
	or.w	d0,EAOPCODE	

	bsr	EaGetFPU
	bmi.s	.noti
	rts
.noti:	jsr	GetEa
	cmp.w	#SINGLE_SIZE,OpSize	;if ea = Dn, size must be <= SINGLE
	ble.s	.nochk
	tst.b	EA_mode(EAPTR)	;DN_MODE
	beq.s	.rsize
.nochk:	bsr	BuildOp
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.rsize:	bra	Errfpu_dn_sz_forb

;transforme size interne en size fpu (shiftee)
getfpsize:
	move.w	OpSize,d0
	bmi.s	.sizedef
	move.b	.FpuSize(pc,d0.w),d0
	moveq	#10,d1
	lsl.w	d1,d0
	rts
.sizedef:	moveq	#%100,d0
	moveq	#10,d1
	lsl.w	d1,d0
	rts
.FpuSize:	dc.b	%110	;byte
	dc.b	%100	;word
	dc.b	%000	;long
	dc.b	%001	;single
	dc.b	%101	;double
	dc.b	%010	;extended
	dc.b	%011	;packed
	even

;reconnait fpn (0-7)
getfp:	move.w	(a0)+,d0
	andi.w	#$dfdf,d0
	cmp.w	#'FP',d0
	bne.s	.rfp
	moveq	#0,d0
	move.b	(a0)+,d0
	sub.b	#'0',d0
	bmi.s	.rfp
	cmp.b	#7,d0
	bhi.s	.rfp
	tst.b	(a0)			;TOKENEOL
	bpl.s	.rfp
.end:	tst.l	d0
	rts
.rfp:	moveq	#-1,d0
	bra.s	.end
;  #] f1ari: 
;  #[ fsd2ari:	FSADD,FDADD,FSDIV,FDDIV,FSMUL,FDMUL,FSSUB,FDSUB	;40
_fsd2ari:
	cmp.w	#FPU_40,FPUType
	beq.s	_f2ari
	bra	Err_fpu_forb
;  #] fsd2ari: 
;  #[ f2ari:	ea,FPn//FPm,FPn
;FADD,FCMP,FDIV,FMOD,FMUL,FREM,FSCALE,FSGLDIV,FSGLMUL,FSUB
_f2ari:	tst.w	FPUType
	beq.s	.rfpu
	subq.w	#2,FIELDSNB
	bne.s	.roper
          move.l	FIELDPTR,a0		;@ 1st field
	bsr.s	getfp
	bmi.s	.ea_fpn
	move.w	OpSize,d1			;fpn,fpn
	bmi.s	.sizedef
	cmp.w	#EXTEND_SIZE,d1
	bne.s	.rx
.sizedef:	bsr	WPokeOpBin
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	moveq	#10,d1			;source reg
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	lea	FIELDNEXT(FIELDPTR),a0
	bsr.s	getfp
	bmi.s	.rfp
	lsl.w	#7,d0			;destination reg
	or.w	d0,EAOPCODE
	bra	WPokeBin
.roper:	bra	Errbad_opernb
.rx:	bra	Errx_exp
.rfp:	bra	Errfp_exp
.rfpu:	bra	Err_fpu_forb
.ea_fpn:	tst.w	OpSize
	bpl.s	.sizeset
	neg.w	OpSize
.sizeset:	move.w	EAOPCODE,OpCode
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	bset	#14,EAOPCODE		;ea flag (R/M)
	lea	FIELDNEXT(FIELDPTR),a0	;fpn
	bsr	getfp
	bmi.s	.rfp
	lsl.w	#7,d0
	or.w	d0,EAOPCODE
	bsr	getfpsize			;size
	or.w	d0,EAOPCODE	
	bsr	EaGetFPU
	bmi.s	.noti
	rts
.noti:	bsr	GetEa
	cmp.w	#SINGLE_SIZE,OpSize		;Dn -> size must be >= SINGLE
	ble.s	.nochk
	tst.b	EA_mode(EAPTR)		;DN_MODE
	beq.s	.rsize
.nochk:	bsr	BuildOp
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.rsize:	bra	Errfpu_dn_sz_forb
;  #] f2ari: 
;species=FBcc,FDBcc/FMOVE/F?MOVE,FMOVECR,FMOVEM/FSINCOS,FTRAPCC,FTST
;  #[ FBcc,PBcc:	PCrel	;51
_pbcc:	cmp.w	#MMU_51,MMUType
	bne	Err_mmu_forb
	tst.w	SuprFlg
	bne	Errsuper_forb
_fbcc:	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	JNEVAL
	ble.s	.rev
	move.w	OpSize,d2
	bmi.s	.word
	beq.s	.rsize
	subq.w	#WORD_SIZE,d2
	bne.s	.long
.word:	swap	EAOPCODE
	clr.w	EAOPCODE
	bsr	LPokeOpBin
	moveq	#P_DBCC,d2
	bra.s	.store
.roper:	bra	Errbad_opernb
.rev:	moveq	#0,d2
	bra	ErrEv_pc
.rsize:	bra	Erropsz_forb
.long:	bset	#6,EAOPCODE	;size
	bsr	WPokeOpBin
	moveq	#0,EAOPCODE
	bsr	LPokeBin
	moveq	#P_BCCL,d2
.store:	move.l	FIELDPTR,a0
	move.l	LINE_srcstart(FIELDPTR),a1
	jmp	StoreEXP		;d0/d1 set
;  #] FBcc,PBcc: 
;  #[ FDBcc,PDBcc:	PCrel	;51
_pdbcc:	cmp.w	#MMU_51,MMUType
	bne	Err_mmu_forb
	tst.w	SuprFlg
	bne	Errsuper_forb
_fdbcc:	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.equr
.asdn:	or.b	d0,EAOPCODE
	swap	EAOPCODE
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	bsr	LPokeOpBin
	INCFIELD
	move.l	FIELDPTR,a0
	JNEVAL
	ble.s	.rev
	moveq	#0,EAOPCODE
	bsr	WPokeBin
	move.l	FIELDPTR,a0
	move.l	LINE_srcstart(FIELDPTR),a1
	moveq	#P_DBCC,d2
	jmp	StoreEXP		;d0/d1 set
.roper:	bra	Errbad_opernb
.rev:	moveq	#0,d2
	bra	ErrEv_pc
.equr:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.rdn
	cmp.b	#TOKEND7,d0
	bls.s	.asdn
.rdn:	bra	Errdn_exp
;  #] FDBcc,PDBcc: 
;  #[ FSMOVE/FDMOVE:
;ea,fpn (BWLSDXP)
_fsdmove:	cmp.w	#FPU_40,FPUType
	bne.s	.rfpu
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.w	EAOPCODE,OpCode
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	bra	__fmove
.rfpu:	bra	Err_fpu_forb
.roper:	bra	Errbad_opernb
;  #] FSMOVE/FDMOVE: 
;  #[ FMOVE:
;fpn,ea{Dn}//fpn,ea{#i} (P)
;fpn,fpn (BWLSDXP)
;ea,fpn//fpn,ea (BWLSDXP) -> float
;ea,fpcr//fpcr,ea (L)
_fmove:	tst.w	FPUType
	beq	Err_fpu_forb
	move.w	EAOPCODE,OpCode
	move.w	REF_opcode+2(REFPTR),EAOPCODE

	subq.w	#2,FIELDSNB
	bmi	.roper
	subq.w	#1,FIELDSNB			;3 operands?
	beq	.kfact
	bgt	.roper

	move.w	OpSize,d0
	bmi.s	.long?
	cmp.w	#LONG_SIZE,d0		;size is long
	bne.s	.nolong
.long?:	move.l	FIELDPTR,a0		;@ 1st field
	bsr	getfpcr			;check fpcr
	bpl	.lfpcrea			;long fpcr,ea
	lea	FIELDNEXT(FIELDPTR),a0
	bsr	getfpcr
	bpl	.leafpcr			;long ea,fpcr

.nolong:	move.l	FIELDPTR,a0		;ea,FPn//FPn,ea
	bsr	getfp
	bmi.s	.ea_fpn			;ea,fpn
	move.w	d0,d3			;fpn,ea or fpn,fpn
	INCFIELD
	move.l	FIELDPTR,a0
	bsr	getfp
	bpl	.fpn_fpn			;fpn,fpn
	lsl.w	#7,d3			;9-7
	or.w	d3,EAOPCODE
	bsr	GetEa
	cmp.w	#SINGLE_SIZE,OpSize		;fmove.{b,w,l,s} fpn,Dn
	ble.s	.nochk
	cmp.w	#PACKED_SIZE,OpSize		;default k-factor is +17
	bne.s	.notp
	or.w	#17,EAOPCODE
.notp:	tst.b	EA_mode(EAPTR)		;DN_MODE
	beq.s	.rsize
.nochk:	ori.w	#%0110000000000000,EAOPCODE	;14-13
	bsr	BuildOp
	bsr	getfpsize
	or.w	d0,EAOPCODE
	bsr	WPokeBin	
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.roper:	bra	Errbad_opernb
.rsize:	bra	Errfpu_dn_sz_forb
.rfp:	bra	Errfp_exp
__fmove:	equ	*
.ea_fpn:	bset	#14,EAOPCODE
	lea	FIELDNEXT(FIELDPTR),a0
	bsr	getfp
	bmi.s	.rfp
	lsl.w	#7,d0
	or.w	d0,EAOPCODE
	bsr	getfpsize
	or.w	d0,EAOPCODE
	bsr	EaGetFPU
	bmi.s	.noti
	rts

.noti:	bsr	GetEa
	cmp.w	#SINGLE_SIZE,OpSize		;Dn -> size must be >= SINGLE
	ble.s	.nochk2
	tst.b	EA_mode(EAPTR)		;DN_MODE
	beq.s	.rsize
.nochk2:	bsr	BuildOp
	bsr	WPokeBin	
	move.l	REF_left(REFPTR),d7
	bra	BuildEa

.fpn_fpn:	move.w	OpSize,d1			;only fmove.x
	bmi.s	.ok
	subq.w	#EXTEND_SIZE,d1
	bne.s	.rfsize
.ok:	swap	EAOPCODE			;save 2nd word
	move.w	OpCode,EAOPCODE
	bsr	WPokeOpBin
	swap	EAOPCODE			;restore 2nd word
	lsl.w	#7,d0
	or.w	d0,EAOPCODE

	moveq	#10,d1
	lsl.w	d1,d3
	or.w	d3,EAOPCODE
	bra	WPokeBin
.rfsize:	bra	Errfpu_fp_sz_forb

;fpn,ea{Dn}//fpn,ea{#i}
.kfact:	move.w	OpSize,d0
	bmi.s	.sizedef
	cmp.w	#PACKED_SIZE,d0		;size is P?
	bne.s	.rpack
.sizedef:	move.w	#PACKED_SIZE,OpSize
	move.l	FIELDPTR,a0
	bsr	getfp
	bmi	.rfp
	lsl.w	#7,d0		;9-7
	or.w	d0,EAOPCODE
	bsr	getfpsize
	or.w	d0,EAOPCODE
	ori.w	#%0110000000000000,EAOPCODE	;14-13
	INCFIELD
	bsr	GetEa

	cmp.w	#SINGLE_SIZE,OpSize		;Dn -> size must be >= SINGLE
	ble.s	.nochk3
	tst.b	EA_mode(EAPTR)		;DN_MODE
	beq	.rsize

.nochk3:	bsr	BuildOp
	INCFIELD
	bsr	setkfact		;3rd field=k-factor
	DECFIELD
	move.l	REF_left(REFPTR),d7
	bra	BuildEa		;2nd field=ea
.rpack:	bra	Err_p_exp

.lfpcrea:	INCFIELD			;fpcr,ea
	bset	#13,EAOPCODE	;dr
.leafpcr:	moveq	#10,d1		;ea,fpcr
	lsl.w	d1,d0		;viros en meme temps les 2 bits
	or.w	d0,EAOPCODE	;10-12
	bset	#15,EAOPCODE	;creation du 2nd word (%10000000)
	bsr	GetEa
	move.l	REF_left(REFPTR),d7
	cmp.b	#AN_MODE,EA_mode(EAPTR)	;if An, FPIAR only
	bne.s	.notan
	btst	#10,EAOPCODE
	beq.s	.rfpiar
	bset	#1,d7		;allow An ea
.notan:	bsr	BuildOp
	bsr	WPokeBin
	bra	BuildEa
.rfpiar:	bra	Errfpiar_exp

getfpcr:	move.w	(a0)+,d0		;reconnaitre FP
	bmi.s	.rfpcr
	andi.w	#$dfdf,d0
	cmp.w	#'FP',d0
	bne.s	.rfpcr
	move.w	(a0)+,d0		;CR,SR,IAR?
	bmi.s	.rfpcr
	andi.w	#$dfdf,d0
	cmp.w	#'CR',d0
	beq.s	.cr
	cmp.w	#'SR',d0
	beq.s	.sr
	cmp.w	#'IA',d0
	bne.s	.rfpcr
	move.b	(a0)+,d0
	bmi.s	.rfpcr
	bclr	#5,d0
	cmp.b	#'R',d0
	bne.s	.rfpcr
.iar	moveq	#%001,d0		;FPIAR
	bra.s	.tsteoo
.sr:	moveq	#%010,d0		;FPSR
	bra.s	.tsteoo
.cr:	moveq	#%100,d0		;FPCR
.tsteoo:	tst.b	(a0)+		;TOKENEOL
	bpl.s	.reoo
.end:	tst.l	d0	
	rts
.rfpcr:
.reoo:	moveq	#-1,d0
	bra.s	.end

setkfact:	move.l	FIELDPTR,a0			;EOL,{Dn},{#i}
	move.b	(a0)+,d0
	bmi.s	.empty
	cmp.b	#'{',d0
	bne.s	.rbra
	move.b	(a0)+,d0
	cmp.b	#'#',d0
	bne.s	.dn
	move.l	a0,a1
.l1:	move.b	(a1)+,d0
	bmi.s	.rbra
	cmp.b	#'}',d0
	bne.s	.l1
	tst.b	(a1)			;TOKENEOL
	bpl.s	.reoo
	SETEOL	-1(a1)
	JNEVAL				;static k-factor
	beq.s	.nopatch
	bmi.s	.rev
	bsr	WPokeBin
	lea	2(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#2,a1
	moveq	#P_K06,d2
	jmp	StoreEXP			;d0/d1 set

.empty:	bra	WPokeBin
.reqr:	addq.w	#1,d0
	beq.s	.rdn
.rbra:	bra	Errbrace_exp
.reoo:	bra	Erreoo_exp
.rev:	bra	ErrEv_immed
.rge:	bra	Err_kfactor_ge
.nopatch:	moveq	#63,d1
	cmp.l	d1,d0
	bgt.s	.rge
	not.l	d1
	cmp.l	d1,d0
	blt.s	.rge
	or.b	d0,EAOPCODE
	bra	WPokeBin

.dn:	cmp.b	#TOKEND7,d0
	bhi.s	.equr
.asdn:	cmp.b	#'}',(a0)+
	bne.s	.rbra
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
	lsl.b	#4,d0			;rrr0000
	or.b	d0,EAOPCODE
	bset	#12,EAOPCODE		;Dest format = Dyn k-factor
	bra	WPokeBin

.equr:	subq.w	#1,a0
	moveq	#'}',d0
	bsr	GetEqur2
	bmi.s	.reqr
	cmp.b	#TOKEND7,d0
	bls.s	.asdn
.rdn:	bra	Errdn_exp

EaGetFPU:	move.w	OpSize,d5
	subq.w	#SINGLE_SIZE,d5
	bmi.s	.noti
	cmp.b	#'#',(FIELDPTR)
	bne.s	.noti
	swap	EAOPCODE			;save 2nd word
	move.w	OpCode,EAOPCODE
	move.b	#%111100,EAOPCODE		;imm ea (bit 6-7 toujours a 0)
	bsr	WPokeOpBin		;poke opcode
	swap	EAOPCODE			;restore 2nd word
	bsr	WPokeBin			;2nd opcode word
	jsr	IsFPU
	bmi.s	.rfpu
	lea	1(FIELDPTR),a0
	move.w	d5,d0
	lea	-12(sp),sp
	move.l	sp,a1
	jsr	FpuEval
	bpl.s	.eval_ok
	lea	12(sp),sp
	bra	ErrEv_fpu
.eval_ok:	move.l	sp,a1
	move.w	OpSize,d0
	jsr	FpuConv
	add.w	d5,d5
	move.w	.t(pc,d5.w),d0
	ext.l	d0
	move.l	sp,a0
	bsr	PokeBinBuffer
	lea	12(sp),sp
	moveq	#0,d0
	rts
.noti:	moveq	#-1,d0
	rts
.rfpu:	bra	Errfpu_req
.t:	dc.w	4,8,12,12

;  #] FMOVE: 
;  #[ FMOVECR:	#fpcr,fpn real unsized: tester la taille de l'immediate
_fmovecr:	tst.w	FPUType
	beq.s	.rfpu
	move.l	REF_opcode(REFPTR),EAOPCODE
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field i
	cmpi.b	#'#',(a0)+
	bne.s	.ri
	JNEVAL
	beq.s	.nopatch
	bmi.s	.rev
	lea	FIELDNEXT(FIELDPTR),a0
	bsr	getfp		;fpcr
	bmi.s	.rfp
	lsl.w	#7,d0		;9-7
	or.w	d0,EAOPCODE
	bsr	LPokeOpBin
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_L06,d2
	jmp	StoreEXP
.rfpu:	bra	Err_fpu_forb
.roper:	bra	Errbad_opernb
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed
.rfpcr:	bra	Errfpcr_exp
.rfp:	bra	Errfp_exp
.nopatch:	moveq	#$3f,d1
	cmp.l	d1,d0
	bhi.s	.rfpcr
	or.b	d0,EAOPCODE	;6-0
	lea	FIELDNEXT(FIELDPTR),a0	;fpcr
	bsr	getfp
	bmi.s	.rfp
	lsl.w	#7,d0		;9-7
	or.w	d0,EAOPCODE
	bra	LPokeOpBin
;  #] FMOVECR: 
;  #[ FMOVEM:	lst,ea ea,lst
_fmovem:	tst.w	FPUType
	beq.s	.rfpu
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.w	EAOPCODE,OpCode
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	move.w	OpSize,d0
	bpl.s	.sizeset
	neg.w	OpSize
	bra.s	.sizedef
.sizeset:	cmp.w	#LONG_SIZE,d0
	beq.s	.lfmovem
	cmp.w	#EXTEND_SIZE,d0
	beq	.xfmovem
	bra	Erropsz_forb	;normalement impossible
.rfpu:	bra	Err_fpu_forb
.roper:	bra	Errbad_opernb
.sizedef:	;reconnaitre les champs: fpcr->.l,sinon .x
	move.l	FIELDPTR,a0	;1st field
	bsr	getcrlist
	bpl.s	.dlistea
	addq.w	#1,d0
	bne	.rlist1
	lea	FIELDNEXT(FIELDPTR),a0
	bsr	getcrlist
	bpl.s	.dealist
	addq.w	#1,d0
	bne.s	.rlist1
	bra	.xfmovem
.lfmovem:	move.l	FIELDPTR,a0	;fpcr,regs
	bsr	getcrlist
	bpl.s	.dlistea
	addq.w	#1,d0
	bne.s	.rlist1
.lealist:	lea	FIELDNEXT(FIELDPTR),a0
	bsr	getcrlist
	bpl.s	.dealist
	bra.s	.rlist2
.dlistea:	INCFIELD
	bset	#13,EAOPCODE	;dr flag
	move.l	REF_right(REFPTR),d7
	bra.s	.llist
.dealist:	move.l	REF_left(REFPTR),d7
.llist:	bsr	GetEa
	move.w	EAOPCODE,d0
	moveq	#0,d1
	moveq	#1,d2
	addx.w	d1,d1
	moveq	#0,d1
	rol.w	#6,d0
	lsr.w	#1,d0
	subx.w	d1,d2
	lsr.w	#1,d0
	subx.w	d1,d2
	lsr.w	#1,d0
	subx.w	d1,d2
	tst.w	d2
	bne.s	.notone
	cmp.b	#AN_MODE,EA_mode(EAPTR)	;if An, FPIAR only
	bne.s	.notan
	btst	#10,EAOPCODE
	beq.s	.rfpiar
.notan:	ori.w	#%11,d7		;allow An/Dn
	bclr	#14,EAOPCODE	;fmovem.x->fmovem.l
.notone:	bsr	BuildOp
	bsr	WPokeBin
	bra	BuildEa
.rfpiar:	bra	Errfpiar_exp
.rlist2:	addq.w	#1,d0
	beq	Errreglist_exp	;-1
.rlist1:	addq.w	#1,d0
	beq	Errdn_or_sep_exp	;-2
	addq.w	#1,d0
	beq	Errreg_twice	;-3
	addq.w	#1,d0
	beq	Erreoo_exp	;-4
	addq.w	#1,d0
	beq	Errbad_reglist	;-5
	bra	Errfp_exp		;-6

.xealist:	addq.w	#1,d0
	bne.s	.rlist1
	bsr	GetEa
	bsr	BuildOp
	lea	FIELDNEXT(FIELDPTR),a0
	bsr	getfreglist
	bmi.s	.rlist2
	btst	#11,d3		;no inv if dynamic
	bne.s	.noinv
	bsr	invbbits		;cant be predec
.noinv:	or.w	d0,EAOPCODE	;reglist

	bset	#12,EAOPCODE	;mode field not pre = post or control
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa

.xfmovem:	move.l	FIELDPTR,a0	;reglist
	bsr	getfreglist
	bmi.s	.xealist
	move.l	d0,d3
;.xlistea:
	INCFIELD
	bsr	GetEa
	bsr	BuildOp
	bset	#13,EAOPCODE	;dr flag: FPn->memory
	cmp.b	#ANPRE_MODE,EA_mode(EAPTR)
	beq.s	.noinv2
	bset	#12,EAOPCODE	;mode field not pre = post or control
	btst	#11,d3		;no inv if dynamic
	bne.s	.noinv2
	move.b	d3,d0
	bsr	invbbits
	move.b	d0,d3
.noinv2:	or.w	d3,EAOPCODE
	bsr	WPokeBin
	move.l	REF_right(REFPTR),d7
	bra	BuildEa

;In:
;a0=field@
;Out:
;d0:
;>=0:reglist
;<0:rlist
getcrlist:
	move.l	REFPTR,-(sp)	;a2
	tst.b	(a0)		;rien ou fin
	bmi.s	.good
.l0:	lea	.CrTable(pc),a1
.l3:	move.l	a0,a2
.l1:	move.b	(a1)+,d0
	beq.s	.found			;fin de registre
	bmi.s	.nolist			;fin de table
	move.b	(a2)+,d1
	bmi.s	.nolist
	bclr	#5,d1
	cmp.b	d1,d0
	beq.s	.l1
.next_cr:	tst.b	(a1)+
	bne.s	.next_cr
	tst.b	(a1)+
	bra.s	.l3
.found:	move.b	(a2),d0
	bmi.s	.ok			;TOKENEOL
	cmp.b	#'/',d0
	bne.s	.rsep
	addq.w	#1,a2
.ok:	move.b	(a1),d1
	bset	d1,EAOPCODE
	bne.s	.rtwice
	move.l	a2,a0
	tst.b	d0			;TOKENEOL
	bpl.s	.l0
.good:	moveq	#0,d0
.end:	move.l	(sp)+,REFPTR
	rts
.nolist:	moveq	#-1,d0
	bra.s	.end
.rsep:	moveq	#-2,d0
	bra.s	.end
.rtwice:	moveq	#-3,d0
	bra.s	.end

.CrTable:	dc.b	"FPCR",0,12
	dc.b	"FPSR",0,11
	dc.b	"FPIAR",0,10
	dc.b	-1
	even

;In:
;a0=reglist @
;Out:
;d0=reglist
getfreglist:
	move.l	d3,-(sp)
	moveq	#0,d0
	move.b	(a0),d0
	cmp.b	#LASTTOKEN,d0
	bls	.dn
;	moveq	#0,d1			;?????
	moveq	#'/',d5
	moveq	#'-',d6
	moveq	#TOKEND7,d7
	moveq	#0,d3			;reg list
.morereg:	;registre
	moveq	#0,d2			;flag de '-'
	move.b	(a0)+,d0			;TOKENEOL
	bmi	.good
	bclr	#5,d0
	cmp.b	#'F',d0
	bne	.alph11?
	move.b	(a0)+,d0			;TOKENEOL
	bmi.s	.good
	bclr	#5,d0
	cmp.b	#'P',d0
	bne	.alph12?
	move.b	(a0)+,d0	
	sub.b	#'0',d0
	bmi	.alph13?
	cmp.b	d7,d0
	bhi	.alph13?
.aalpha1:	bset	d0,d3
	bne.s	.rtwice
.moresep:	move.b	(a0)+,d1			;separateur
	bmi.s	.good
	cmp.b	d5,d1			;'/'
	beq.s	.morereg
	cmp.b	d6,d1			;'-'
	bne.s	.rsep
	tas	d2
	bne.s	.rlist
	move.b	(a0)+,d1
	bmi.s	.rfp
	bclr	#5,d1
	cmp.b	#'F',d1
	bne	.alph21?
	move.b	(a0)+,d1			;'-'
	bmi	.alph22?
	bclr	#5,d1
	cmp.b	#'P',d1
	bne	.alph22?
	move.b	(a0)+,d1	
	sub.b	#'0',d1
	bmi	.alph23?
	cmp.b	d7,d1
	bhi	.alph23?
.aalpha2:	addq.b	#1,d0
.again:	bset	d0,d3
	bne.s	.rtwice
	addq.b	#1,d0
	cmp.b	d1,d0
	ble.s	.again
	bra.s	.moresep
.good:	move.l	d3,d0
.end:	movem.l	(sp)+,d3
	rts
.dn:	cmp.b	#TOKEND7,d0
	bhi.s	.rlist
	tst.b	1(a0)			;TOKENEOL
	bpl.s	.reoo
	bset	#11,d0			;dynamic
	lsl.b	#4,d0			;<<=4
	bra.s	.end
.nolist:	moveq	#-1,d0
	bra.s	.end
.rsep:	moveq	#-2,d0
	bra.s	.end
.rtwice:	moveq	#-3,d0
	bra.s	.end
.reoo:	moveq	#-4,d0
	bra.s	.end
.rlist:	moveq	#-5,d0
	bra.s	.end
.rfp:	moveq	#-6,d0
	bra.s	.end

.alph13?:	subq.w	#1,a0
.alph12?:	subq.w	#1,a0
.alph11?:	subq.w	#1,a0
	move.l	a0,a1
.l1:	move.b	(a1)+,d0
	bmi.s	.eqr1
	cmp.b	d5,d0
	beq.s	.eqr1
	cmp.b	d6,d0
	bne.s	.l1
.eqr1:	move.l	a1,d0
	sub.l	a0,d0
	subq.l	#1,d0
	bsr	FindEqu
	beq.s	.nolist
	move.l	d0,a1
	add.w	VAR_len(a1),a0
	move.b	VAR_type(a1),d1
	move.l	VAR_value(a1),d0
	subq.b	#EQU_EQUR,d1
	bmi.s	.nolist
	beq.s	.eqrdn
	subq.b	#EQU_FEQUR-EQU_EQUR,d1
	beq	.aalpha1
	subq.b	#EQU_FREG-EQU_FEQUR,d1
	bne.s	.nolist
.asfreg:	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
	tst.l	d3
	bne.s	.nolist
	bra.s	.end
.eqrdn:	cmp.b	#TOKEND7,d0
	bhi.s	.rlist
	bset	#11,d0			;dynamic
	lsl.b	#4,d0			;<<=4
	bra.s	.asfreg

.alph23?:	subq.w	#1,a0
.alph22?:	subq.w	#1,a0
.alph21?:	subq.w	#1,a0
	move.l	d0,d1
	move.l	a0,a1
.l2:	move.b	(a1)+,d0
	bmi.s	.eqr2
	cmp.b	d5,d0
	beq.s	.eqr2
	cmp.b	d6,d0
	bne.s	.l2
.eqr2:	move.b	-(a1),-(sp)
	SETEOL	(a1)
	bsr	GetFEqur
	move.b	(sp)+,(a1)
	tst.l	d0
	bmi	.nolist
	exg	d0,d1
	move.l	a1,a0
	bra	.aalpha2

;d0.b inverse
invbbits:	moveq	#0,d1
	addx.w	d1,d1
	moveq	#0,d1
	REPT	8
	add.b	d0,d0
	roxr.b	#1,d1
	ENDR
	move.b	d1,d0	;.l ?!?
	rts
;  #] FMOVEM:
;  #[ PScc:	ea real unsized	;51
_pscc:	cmp.w	#MMU_51,MMUType
	bne.s	.rmmu
	tst.w	SuprFlg
	beq.s	_cpscc
	bra	Errsuper_forb
.rmmu:	bra	Err_mmu_forb
;  #] PScc: 
;keep near
;  #[ FScc:	ea real unsized	;81/40
_fscc:	move.w	FPUType,d0
	subq.w	#FPU_81,d0
	beq.s	_cpscc
	subq.w	#FPU_40-FPU_81,d0
	bne	Err_fpu_forb
;  #] FScc: 
;keep tight
;  #[ cpScc:	ea real unsized	;51	;81/40
_cpscc:	subq.w	#1,FIELDSNB
	bne.s	.roper
	clr.w	OpSize
	move.w	EAOPCODE,OpCode
	bsr	GetEa
	bsr	BuildOp
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.roper:	bra	Errbad_opernb
;  #] cpScc: 
;  #[ FSINCOS:	ea,fpn:fpn//fpn,fpn:fpn	gerer #i
_fsincos:	cmp.w	#FPU_81,FPUType
	bne.s	.rfpu
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	bsr	getfp
	bmi.s	.ea_fpn
	move.w	OpSize,d1			;fpn,fpn
	bmi.s	.sizedef
	subq.w	#EXTEND_SIZE,d1
	bne.s	.rx
.sizedef:	bsr	WPokeOpBin
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	moveq	#10,d1
	lsl.w	d1,d0		;source register
	or.w	d0,EAOPCODE
	lea	FIELDNEXT(FIELDPTR),a0
	bsr	getfp2
	bmi.s	.rfp
	lsl.w	#7,d0		;dest register
	or.w	d0,EAOPCODE
	swap	d0
	or.w	d0,EAOPCODE
	bra	WPokeBin
.rfpu:	bra	Err_fpu_forb
.roper:	bra	Errbad_opernb
.rx:	bra	Errx_exp
.rfp:	bra	Errfp_exp
.ea_fpn:	tst.w	OpSize
	bpl.s	.set
	neg.w	OpSize		;move.w	#%01,OpSize
.set:	move.w	EAOPCODE,OpCode
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	bset	#14,EAOPCODE	;ea flag (R/M)
	lea	FIELDNEXT(FIELDPTR),a0	;fpn1
	bsr.s	getfp2
	bmi.s	.rfp
	lsl.w	#7,d0
	or.w	d0,EAOPCODE
	swap	d0
	or.w	d0,EAOPCODE
	bsr	getfpsize		;size
	or.w	d0,EAOPCODE	
	bsr	EaGetFPU
	bmi.s	.noti
	rts

.noti:	bsr	GetEa
	cmp.w	#SINGLE_SIZE,OpSize	;if ea=Dn size must be <= SINGLE
	ble.s	.nochk
	tst.b	EA_mode(EAPTR)	;DN_MODE
	beq.s	.rsize
.nochk:	bsr	BuildOp
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.rsize:	bra	Errfpu_dn_sz_forb

;reconnait fpn (0-7):fpn (0-7)
getfp2:	moveq	#0,d0
	move.b	(a0)+,d0
	bclr	#5,d0
	cmp.b	#'F',d0
	bne.s	.not_fp
	move.b	(a0)+,d0
	bclr	#5,d0
	cmp.b	#'P',d0
	bne.s	.not_fp
	move.b	(a0)+,d0
	sub.b	#'0',d0
	bmi.s	.not_fp
	cmp.b	#7,d0
	bhi.s	.not_fp
	cmp.b	#':',(a0)+
	bne.s	.rsemi
	swap	d0
	move.b	(a0)+,d0
	bclr	#5,d0
	cmp.b	#'F',d0
	bne.s	.not_fp
	move.b	(a0)+,d0
	bclr	#5,d0
	cmp.b	#'P',d0
	bne.s	.not_fp
	move.b	(a0)+,d0
	sub.b	#'0',d0
	bmi.s	.not_fp
	cmp.b	#7,d0
	bhi.s	.not_fp
	tst.b	(a0)+			;TOKENEOL
	bpl.s	.reoo
.end:	tst.l	d0
	rts
.rsemi:	bra	Errsemi_exp
.not_fp:	moveq	#-1,d0
	bra.s	.end
.reoo:	bra	Erreoo_exp
;  #] FSINCOS: 
;  #[ PTRAPcc:	#i//#i,l		;51
_ptrapcc:	cmp.w	#MMU_51,MMUType
	bne.s	.rmmu
	tst.w	SuprFlg
	bne.s	_cptrapcc
	bra	Errsuper_forb
.rmmu:	bra	Err_mmu_forb
;  #] PTRAPcc: 
;keep near
;  #[ FTRAPcc:	#i//#i,l		;81/40
_ftrapcc:	move.w	FPUType,d0
	subq.w	#FPU_81,d0
	beq.s	_cptrapcc
	subq.w	#FPU_40,d0
	bne	Err_fpu_forb
;  #] FTRAPcc: 
;keep tight
;  #[ cpTRAPcc:	#i//#i,l		;51	;81/40
_cptrapcc:
	subq.w	#1,FIELDSNB
	bmi.s	.nooper
	bgt.s	.roper
	move.l	REF_opcode(REFPTR),EAOPCODE
	move.w	OpSize,d0
	bmi.s	.sizedef
	subq.w	#1,d0
	beq.s	.wform
.lform:	or.l	#%011<<16,EAOPCODE	;long form
	bsr	LPokeOpBin
	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JNEVAL
	bgt.s	.patch1
	bmi.s	.rev
	move.l	d0,EAOPCODE
	bra	LPokeBin

.patch1:	moveq	#0,EAOPCODE
	bsr	LPokeBin
	moveq	#P_ABSL,d2
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	jmp	StoreEXP		;d0-d1 set
.roper:	bra	Erroper_2many

.nooper:	tst.w	OpSize		;no oper form
	bpl.s	.rsize
	move.l	REF_opcode(REFPTR),EAOPCODE
	bset	#2+16,EAOPCODE	;no oper flag (2)
	bra	LPokeOpBin
.rsize:	bra	Erropsz_forb
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed

.sizedef:	neg.w	OpSize
.wform:	bset	#1+16,EAOPCODE	;word form
	bsr	LPokeOpBin
	moveq	#0,EAOPCODE
	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JNEVAL
	bgt.s	.patch2
	bmi.s	.rev
	move.l	d0,EAOPCODE
	cmp.l	#$ffff,EAOPCODE
	bls	WPokeBin
.rgew:	bra	Errsz_ge_w
.patch2:	moveq	#0,EAOPCODE
	bsr	WPokeBin
	moveq	#P_ABSW,d2
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	jmp	StoreEXP		;d0-d1 set
;  #] cpTRAPcc: 
;  #[ FTST:	ea//fpn
_ftst:	tst.w	FPUType
	beq.s	.rfpu
	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	bsr	getfp
	bmi.s	.ea
.fpn:	move.w	OpSize,d1
	bmi.s	.sizedef
	subq.w	#EXTEND_SIZE,d1
	bne.s	.rx
.sizedef:	bsr	WPokeOpBin
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	moveq	#10,d1			;source register
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	bra	WPokeBin
.rx:	bra	Errx_exp
.rfpu:	bra	Err_fpu_forb
.roper:	bra	Errbad_opernb

.ea:	tst.w	OpSize
	bpl.s	.sizeset
	neg.w	OpSize			;move.w	#%01,OpSize
.sizeset:	;traiter '#' en flottant
	bsr	GetEa

	tst.b	EA_mode(EAPTR)
	bne.s	.not_dn
	cmp.w	#LONG_SIZE,OpSize		;ea = Dn-> size must be <= long
	bgt.s	.rsize
.not_dn:	move.w	EAOPCODE,OpCode
	bsr	BuildOp
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	bset	#14,EAOPCODE		;ea flag
	bsr	getfpsize			;size
	or.w	d0,EAOPCODE	
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.rsize:	bra	Errfpu_dn_sz_forb
;  #] FTST: 
;  #[ LEA:	ea,An real sized
_lea:	subq.w	#2,FIELDSNB
	bne.s	.roper
	lea	FIELDNEXT(FIELDPTR),a0	;2nd field
;	moveq	#0,d3
	move.b	(a0)+,d3
	subq.b	#TOKENA0,d3
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d3
	bhi.s	.equr
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
.asan:	move.w	d3,d0
	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	move.w	EAOPCODE,OpCode
	bsr	GetEa
	tst.w	OptiLea2QFlg
	bne.s	.ariq?
.noariq:	bsr	BuildOp
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.roper:	bra	Errbad_opernb
.rdn:	bra	Errdn_forb
.reoo:	bra	Erreoo_exp
.equr:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.erran
	move.l	d0,d3
	subq.b	#TOKENA0,d3
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d3
	ble.s	.asan
.erran:	bra	Erran_exp
.ariq?:	cmp.b	#D16AN_MODE,EA_mode(EAPTR)	;lea	d16(An)
	bne.s	.noariq
	tst.l	EA_vtype(EAPTR)		;backw ref
	bne.s	.noariq
	cmp.b	EA_an(EAPTR),d3		;An==An
	bne.s	.noariq
	move.w	EA_value+2(EAPTR),d0	;d16
	beq.s	.noariq			;lea	0(An),An??
	bmi.s	.chksubq

	cmp.w	#8,d0
	bgt.s	.noariq
	bne.s	.notadd8
	moveq	#0,d0
.notadd8:	move.w	#%0101000001001000,EAOPCODE
	bra.s	.ariq

.chksubq:	neg.w	d0
	cmp.w	#8,d0
	bhi.s	.noariq			;bhi a cause de neg 8000
	bne.s	.notsub8
	moveq	#0,d0
.notsub8:	move.w	#%0101000101001000,EAOPCODE	;size=W,ea=An
.ariq:	or.b	d3,EAOPCODE		;areg
	moveq	#9,d1
	lsl.w	d1,d0			;d0.w=quick value
	or.w	d0,EAOPCODE
	bsr	WPokeOpBin
	bra	Opti_lea2q
	
;  #] LEA: 
;  #[ LINK:	#i,An real unsized	;xx	;20/30/40/32
_link:	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.w	OpSize,d1
	bpl.s	.sizeset
	neg.w	OpSize
	neg.w	d1
.sizeset:	subq.w	#1,d1
	beq.s	.word1
	cmp.w	#MPU_32,MPUType
	blt.s	.rmpu
.word1:
	IFNE	_68000
	add.w	d1,d1
	move.w	0(REFPTR,d1.w),EAOPCODE	;link.w/link.l
	ELSEIF	;_68000
	move.w	0(REFPTR,d1.w*2),EAOPCODE
	ENDC	;_68000

	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0)+,d0
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.equr
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
.asan:	or.b	d0,EAOPCODE
	bsr	WPokeOpBin

	INCFIELD
	move.l	FIELDPTR,a0		;@ 2nd field
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JNEVAL
	beq.s	.nopatch
	bmi.s	.rev
	moveq	#0,EAOPCODE
	subq.w	#1,OpSize
	beq.s	.paw
.pal:	bsr	LPokeBin
	moveq	#P_DCL,d2
	bra.s	.patch
.roper:	bra	Errbad_opernb
.rmpu:	bra	Err20_forb
.paw:	bsr	WPokeBin
	moveq	#P_DCW,d2
.patch:	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	jmp	StoreEXP		;d0/d1 set
.rdn:	bra	Errdn_forb
.reoo:	bra	Erreoo_exp
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed

.nopatch:	btst	#0,d0
	bne.s	.wodd
.awarn:	move.w	OpSize,d1
	subq.w	#1,d1
	beq.s	.word2
	move.l	d0,EAOPCODE
	bra	LPokeBin
.equr:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.ran
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bls	.asan
.ran:	bra	Erran_exp
.word2:	cmp.l	#$ffff,d0
	bls.s	.vok
	btst	#15,d0
	beq.s	.rgew
	move.l	d0,d1
	swap	d1
	cmp.w	#$ffff,d1
	bne.s	.rgew
.vok:	move.w	d0,EAOPCODE
	bra	WPokeBin
.wodd:	move.l	d0,-(sp)
	bsr	Warn_oddsp
	move.l	(sp)+,d0
	bra.s	.awarn
.rgew:	bra	Errsz_ge_w
;  #] LINK: 
;  #[ UNLK:	An real unsized
_unlk:	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0)+,d0
	bmi.s	.ran
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.equr
	tst.b	(a0)				;TOKENEOL
	bpl.s	.reoo
	or.b	d0,EAOPCODE
	bra	WPokeOpBin
.roper:	bra	Errbad_opernb
.ran:	bra	Erran_exp
.rdn:	bra	Errdn_forb
.reoo:	bra	Erreoo_exp
.equr:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.ran
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.ran
	or.b	d0,EAOPCODE
	bra	WPokeOpBin
;  #] UNLK: 
;  #[ MOVE,MOVEA:	sized	;xx	;10/20/30/40/32
_dum_move:
.rdn:	bra	Errdn_forb
.ran:	bra	Erran_exp
.usp:	tst.w	SuprFlg
	bne.s	.rsup
	move.w	OpSize,d0
	bmi.s	.uspszok
	subq.w	#WORD_SIZE,d0
	ble.s	.rsize
.uspszok:	move.b	(a0)+,d0
	bmi.s	.ran			;TOKENEOL
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.ran

	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
	or.b	d0,EAOPCODE
	bra	WPokeOpBin
.rsize:	bra	Errsz_forb
.rsup:	bra	Errsuper_forb
.reoo:	bra	Erreoo_exp
.tccr:	lea	.movetccr_ref(pc),REFPTR	;ea,ccr
	moveq	#BYTE_SIZE,d0
	bra.s	.spe
.fccr:	lea	.movefccr_ref(pc),REFPTR	;ccr,ea
	moveq	#BYTE_SIZE,d0
	INCFIELD
	tst.w	MPUType
	bne.s	.spe
	bra	Err10_forb
.tsr:	lea	.movetsr_ref(pc),REFPTR	;ea,sr
	moveq	#WORD_SIZE,d0
	bra.s	.chkusr
.fsr:	lea	.movefsr_ref(pc),REFPTR	;sr,ea
	moveq	#WORD_SIZE,d0
	INCFIELD
	tst.w	MPUType
	beq.s	.spe
;	bra.s	.chkusr
.chkusr:	tst.w	SuprFlg
	bne.s	.rsup
.spe:	move.w	OpSize,d1
	bmi.s	.ok
	cmp.w	d0,d1
	bne.s	.rsize
.ok:	move.w	#WORD_SIZE,OpSize
	move.w	REF_opcode(REFPTR),EAOPCODE
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
	moveq	#1,FIELDSNB
	bra	_umonadics

.roper:	bra	Errbad_opernb

;ea,An -> MOVEA
_movea:	EQU	*
;ea,ea -> MOVE
;ea,An -> MOVEA
_move:	EQU	*
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0)+,d0
	cmp.b	#LASTTOKEN,d0		;ptet + rapide
	bhi.s	.nxt
	sub.b	#TOKENA7,d0
	ble.s	.nxt
	subq.b	#TOKENSR-TOKENA7,d0
	beq.s	.fsr
	subq.b	#TOKENCCR-TOKENSR,d0
	beq	.fccr
	subq.b	#TOKENUSP-TOKENCCR,d0
	beq.s	.fusp

.nxt:	lea	FIELDNEXT(FIELDPTR),a0
	move.b	(a0)+,d0
	cmp.b	#LASTTOKEN,d0
	bhi.s	.chk
	sub.b	#TOKENA7,d0
	ble.s	.chk
	subq.b	#TOKENSR-TOKENA7,d0
	beq.s	.tsr
	subq.b	#TOKENCCR-TOKENSR,d0
	beq	.tccr
	subq.b	#TOKENUSP-TOKENCCR,d0
	beq.s	.tusp

.chk:	move.w	OpSize,d0
	bmi.s	.sizedef
	subq.w	#WORD_SIZE,d0
	bmi.s	.byte
	beq.s	.word
.long:	move.w	#%10<<12,EAOPCODE
	bsr	GetEa			;Left ea
	INCEA
	INCFIELD
	bsr	GetEa			;Right ea
	DECEA
	DECFIELD

	cmp.b	#'#',(FIELDPTR)		;#i->moveq,movea,suba
	bne.s	.build
	tst.l	EA_vtype(EAPTR)		;forward ref
	bne.s	.build

	move.b	EA_SIZEOF+EA_mode(EAPTR),d0	;DN_MODE
	beq	.todn
	subq.b	#AN_MODE,d0
	beq	.toan
	bra.s	.build

.fusp:	lea	.movefusp_ref(pc),REFPTR	;usp,ea
	move.l	REF_opcode(REFPTR),EAOPCODE
	lea	FIELDNEXT(FIELDPTR),a0
	bra	.usp
.tusp:	lea	.movetusp_ref(pc),REFPTR	;ea,usp
	move.l	REF_opcode(REFPTR),EAOPCODE
	move.l	FIELDPTR,a0
	bra	.usp

.byte:	move.w	#%01<<12,EAOPCODE
	bra.s	.poke
.sizedef:	neg.w	OpSize
.word:	move.w	#%11<<12,EAOPCODE
.poke:	bsr	GetEa			;Left ea
	INCEA
	INCFIELD
	bsr	GetEa			;Right ea
	DECEA
	DECFIELD

	cmp.b	#'#',(FIELDPTR)		;#i->moveq,movea,suba
	bne.s	.build
	tst.l	EA_vtype(EAPTR)		;forward ref
	bne.s	.build

	move.b	EA_SIZEOF+EA_mode(EAPTR),d0
	beq.s	.todnw
	subq.b	#AN_MODE,d0
	beq.s	.toanw

.build:	move.w	EAOPCODE,OpCode
	bsr	BuildDst
	move.l	REF_left(REFPTR),d7
	bsr	BuildEa
	INCEA
	INCFIELD
	move.l	REF_right(REFPTR),d7
	bra	BuildEa

.todn:	tst.w	OptiMv2QFlg		;-128<=x<=127
	beq.s	.build

	move.l	EA_value(EAPTR),d0
	moveq	#-128,d1
	cmp.l	d1,d0
	blt.s	.build
	not.l	d1
	cmp.l	d1,d0
	bgt.s	.build
	move.w	#%111<<12,EAOPCODE
	or.b	d0,EAOPCODE
	move.b	EA_SIZEOF+EA_an(EAPTR),d0
	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	bsr	WPokeOpBin
	bra	Opti_move2q

.todnw:	tst.w	OptiMvZ2ClrFlg
	beq.s	.build
	tst.w	EA_value+2(EAPTR)		;move.w #0,Dn
	bne.s	.build
	move.w	#%0100001001000000,EAOPCODE	;clr.w
	or.b	EA_SIZEOF+EA_an(EAPTR),EAOPCODE
	bsr	WPokeOpBin
	bra	Opti_move2clr

.toan:	tst.w	OptiMvaL2WFlg
	bne.s	.l2w
.toanw:	tst.l	EA_value(EAPTR)
	bne	.build
.2sub?:	tst.w	OptiMva2SubFlg
	beq	.build
	move.w	#%1001000111001000,EAOPCODE	;suba.l	An,
.a2sub:	move.b	EA_SIZEOF+EA_an(EAPTR),d0
	or.b	d0,EAOPCODE		;An,
	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE		;,An
	bsr	WPokeOpBin
	bra	Opti_a2sub

.l2w:	move.l	EA_value(EAPTR),d0
	beq.s	.2sub?
	move.w	d0,d1
	ext.l	d1
	cmp.l	d0,d1
	bne	.build

	move.w	#WORD_SIZE,OpSize
	move.w	#%11<<12,EAOPCODE
	bsr	Opti_al2w
	bra	.build

.movefccr_ref:
	dc.l	%01000010110000000000000000000000
	dc.l	%00000000000000000000111111111101
	dc.l	0
	dc.w	0
	dc.b	FUNC_NOFLAGS,FUNC_68010|FUNC_68020|FUNC_68030|FUNC_68040|FUNC_CPU32
.movetccr_ref:
	dc.l	%01000100110000000000000000000000
	dc.l	%00000000000000111111111111111101
	dc.l	0
	dc.w	0
	dc.b	FUNC_NOFLAGS,FUNC_68000|FUNC_68010|FUNC_68020|FUNC_68030|FUNC_68040|FUNC_CPU32
.movefsr_ref:
	dc.l	%01000000110000000000000000000000
	dc.l	%00000000000000000000111111111101
	dc.l	0
	dc.w	0
	dc.b	FUNC_SUPER,FUNC_68000|FUNC_68010|FUNC_68020|FUNC_68030|FUNC_68040|FUNC_CPU32
.movetsr_ref:
	dc.l	%01000110110000000000000000000000
	dc.l	%00000000000000111111111111111101
	dc.l	0
	dc.w	0
	dc.b	FUNC_SUPER,FUNC_68000|FUNC_68010|FUNC_68020|FUNC_68030|FUNC_68040|FUNC_CPU32
.movefusp_ref:
	dc.l	%00000000000000000100111001101000
	dc.l	%00000000000000000000000000000010
	dc.l	0
	dc.w	0
	dc.b	FUNC_SUPER,FUNC_68000|FUNC_68010|FUNC_68020|FUNC_68030|FUNC_68040|FUNC_CPU32
.movetusp_ref:
	dc.l	%00000000000000000100111001100000
	dc.l	%00000000000000000000000000000010
	dc.l	0
	dc.w	0
	dc.b	FUNC_SUPER,FUNC_68000|FUNC_68010|FUNC_68020|FUNC_68030|FUNC_68040|FUNC_CPU32
	
;  #] MOVE,MOVEA: 
;  #[ MOVEC:	Rn,Rc//Rc,Rn real unsized	;10/20/30/40/32
;d7=Rn
;d6=Rc
_movec:	tst.w	MPUType
	beq.s	.rmpu
	tst.w	SuprFlg
	bne.s	.rsup
	subq.w	#2,FIELDSNB
	bne.s	.roper
	moveq	#0,d7
	moveq	#0,d6
	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0),d0
	cmp.b	#TOKENA7,d0
	bls.s	.Rn_Rc
	bsr	get_Rc			;Rc_Rn
	bmi.s	.Eqr_Rc
	lea	FIELDNEXT(FIELDPTR),a0
	move.b	(a0),d0
	cmp.b	#LASTTOKEN,d0
	bhi.s	.Rc_Eqr
	tst.b	1(a0)			;TOKENEOL
	bpl.s	.reoo
.ok_Eqr:	moveq	#TOKENA0,d1
	cmp.b	d1,d0
	blt.s	.dn
	sub.b	d1,d0			;An
	bset	#3,d0
.dn:	move.b	d0,d7
;	bra.s	.build
.build:	bsr	WPokeOpBin
	move.w	d6,EAOPCODE
	moveq	#12,d1
	lsl.w	d1,d7
	or.w	d7,EAOPCODE
	bra	WPokeBin
.rmpu:	bra	Err10_forb
.rsup:	bra	Errsuper_forb
.roper:	bra	Errbad_opernb
.Rc_Eqr:	bsr	GetEqur
	bmi.s	.rxn
	cmp.b	#TOKENA7,d0
	bls.s	.ok_Eqr
	bra.s	.rxn
.Eqr_Rc:	move.l	FIELDPTR,a0
	bsr	GetEqur
	bmi.s	.rxn
	cmp.b	#TOKENA7,d0
	bls.s	.Eqr_ok
.rxn:	bra	Errxn_exp
.Rn_Rc:	tst.b	1(a0)			;TOKENEOL
	bpl.s	.reoo
.Eqr_ok:	bset	#0,EAOPCODE
	moveq	#TOKENA0,d1
	cmp.b	d1,d0
	blt.s	.dn_2
	sub.b	d1,d0			;An
	bset	#3,d0
.dn_2:	move.b	d0,d7
	lea	FIELDNEXT(FIELDPTR),a0
	bsr.s	get_Rc
	bpl.s	.build
.rcr:	bra	Errcr_exp
.reoo:	bra	Erreoo_exp

;$000,SFC		;10/20/30/40/32
;$001,DFC		;id
;$800,USP		;id
;$801,VBR		;id
;$002,CACR	;20/30/40
;$802,CAAR	;20/30
;$803,MSP		;20/30/40
;$804,ISP		;id
;$003,TC		;40/LC40
;$004,ITT0	;id
;$005,ITT1	;id
;$006,DTT0	;id
;$007,DTT1	;id
;$805,MMUSR	;id
;$805,PSR		;id
;$806,URP		;id
;$807,SRP		;id
;$004,IACR0	;EC40
;$005,IACR1	;id
;$006,DACR0	;id
;$007,DACR1	;id
;Input:	a0=@ nom termine par TOKENEOL
;Output:	d6=Rc
get_Rc:	moveq	#0,d0		;IACR
	moveq	#0,d1
	moveq	#8,d2
	moveq	#0,d6
	move.b	(a0)+,d6		;TOKENEOL
	bmi.s	.rcr
	cmp.b	#TOKENUSP,d6
	beq.s	.usp
	cmp.b	#'#',d6
	beq	.immed
	move.b	.t(pc,d6.w),d0

	REPT	3
	tst.b	(a0)		;;TOKENEOL
	bmi.s	.cmpregs
	lsl.l	d2,d0
	move.b	(a0)+,d6
	move.b	.t(pc,d6.w),d0
	ENDR

	tst.b	(a0)		;TOKENEOL
	bmi.s	.cmpregs
	move.b	(a0)+,d6
	move.b	.t(pc,d6.w),d1
	tst.b	(a0)		;TOKENEOL
	bpl.s	.rcr

.cmpregs:	lea	.crs(pc),a0
.l1:	move.l	(a0)+,d2
	beq.s	.rcr
	move.l	(a0)+,d6
	addq.w	#2,a0
	cmp.l	d0,d2
	bne.s	.l1
	cmp.w	d1,d6
	bne.s	.l1
	move.w	MPUType,d0
	move.w	-2(a0),d1
	btst	d0,d1
	beq.s	.rmccr
	swap	d6
.good:	moveq	#0,d0
	rts
.rcr:	moveq	#-1,d0
	rts
.usp:	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
	move.w	#$800,d6
	bra.s	.good
.rmccr:	bra	Errmccr_forb
.reoo:	bra	Erreoo_exp
	CASETAB
.crs:	dc.w	 'S','FC',$000,$00,%11111110
	dc.w	 'D','FC',$001,$00,%11111110
;	dc.w	 'U','SP',$800,$00,%11111110	;done as token
	dc.w	 'V','BR',$801,$00,%11111110
	dc.w	'CA','CR',$002,$00,%11111000
	dc.w	'CA','AR',$802,$00,%00011000
	dc.w	 'M','SP',$803,$00,%11111000
	dc.w	 'I','SP',$804,$00,%11111000
	IFNE	_68040
	dc.w	 $00,'TC',$003,$00,%11100000
	dc.w	'IT','T0',$004,$00,%11100000
	dc.w	'IT','T1',$005,$00,%11100000
	dc.w	'DT','T0',$006,$00,%11100000
	dc.w	'DT','T1',$007,$00,%11100000
	dc.w	 'P','SR',$805,$00,%11100000
	dc.w	'MM','US',$805,'R',%11100000
	dc.w	 'U','RP',$806,$00,%11100000
	dc.w	 'S','RP',$807,$00,%11100000
	dc.w	'IA','CR',$004,'0',%11100000
	dc.w	'IA','CR',$005,'1',%11100000
	dc.w	'DA','CR',$006,'0',%11100000
	dc.w	'DA','CR',$007,'1',%11100000
	ENDC
	dc.l	0
.immed:	JFEVAL
	bmi.s	.reval
	move.l	d0,d6
	bra	.good
.reval:	bra	ErrEv_immed
;  #] MOVEC: 
;  #[ MOVEM:	Xn-Xn/Xn,ea//ea,Xn-Xn/Xn sized
_movem:	subq.w	#2,FIELDSNB
	bne.s	.ifempty
	move.w	OpSize,d0
	bpl.s	.sizeset
	neg.w	OpSize
	bra.s	.word
.roper:	bra	Errbad_opernb
.rsize:	bra	Erropsz_forb
.ifempty:	addq.w	#1,FIELDSNB		;one field=ea,
	bne.s	.roper
	bsr	Warnreg_empty
	moveq	#0,d0			;d3->d0
	bra.s	.ea_list
.sizeset:	subq.w	#WORD_SIZE,d0
	beq.s	.word
	bmi.s	.rsize
.long:	bset	#6,EAOPCODE
.word:	move.l	FIELDPTR,a0		;@ 1st field
	bsr.s	getreglist		;list,ea
	bpl.s	.list_ea
	lea	FIELDNEXT(FIELDPTR),a0	;ea,list
	bsr.s	getreglist
	bmi.s	.rlist
;	bpl.s	.ea_list
;	move.l	FIELDPTR,a0		;reg,ea
;	bsr	GetRegEqu
;	bpl.s	.reg_ea
;	lea	FIELDNEXT(FIELDPTR),a0	;ea,reg
;	bsr	GetRegEqu
;	bmi.s	.rlist
;.ea_reg:
.ea_list:	move.l	d0,d3
	bsr	GetEa
	bset	#10,EAOPCODE
	move.w	EAOPCODE,OpCode
	bsr	BuildOp
	move.w	d3,EAOPCODE
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.rlist:	bra	Errreglist_exp
;.reg_ea:
.list_ea:	move.l	d0,d3
	INCFIELD
	bsr	GetEa
	move.w	EAOPCODE,OpCode
	bsr	BuildOp
	move.w	d3,EAOPCODE		;traiter l'inversion
	cmp.b	#ANPRE_MODE,EA_mode(EAPTR)
	bne.s	.not_pre
	move.w	d3,d0
	bsr	invbits
	move.w	d0,EAOPCODE
.not_pre:	bsr	WPokeBin
	move.l	REF_right(REFPTR),d7
	bra	BuildEa

getreglist:
	moveq	#0,d0			;octet cleane
	moveq	#0,d1			;octet cleane
	moveq	#0,d3			;reg list
	moveq	#'/',d5
	moveq	#'-',d6
	moveq	#TOKENA7,d7
.morereg:	moveq	#0,d2			;flag de '-'
	move.b	(a0)+,d0			;TOKENEOL
	bmi.s	.empty?
	cmp.b	d7,d0
	bhi.s	.alpha1?
.aalpha1:	bset	d0,d3
	bne.s	.rtwice
.moresep:	move.b	(a0)+,d1			;separateur
	bmi.s	.empty?			;TOKENEOL
	cmp.b	d5,d1			;'/'
	beq.s	.morereg
	cmp.b	d6,d1			;'-'
	bne.s	.rsep
	tas	d2
	bne.s	.rlist
	move.b	(a0)+,d1			;'-'
	bmi.s	.xnexp
	cmp.b	d7,d1			;A7
	bhi	.alpha2?
.aalpha2:	addq.w	#1,d0
	cmp.w	d1,d0
	bhi.s	.rlist
.again:	bset	d0,d3
	bne.s	.rtwice
	addq.w	#1,d0
	cmp.w	d1,d0
	ble.s	.again
	bra.s	.moresep

.empty?:	move.l	d3,d0
	beq.s	.wempty
	rts
.wempty:	bsr	Warnreg_empty
	move.l	d3,d0
	rts

.xnexp:	bra	Errxn_exp
.rtwice:	bra	Errreg_twice
.rsep:	bra	Errdn_or_sep_exp
.rlist:	bra	Errbad_reglist

.alpha1?:	subq.w	#1,a0
	move.l	a0,a1
	cmp.b	#'#',(a1)+		;#
	beq.s	.diese
.l1:	move.b	(a1)+,d0
	bmi.s	.eqr1
	cmp.b	d5,d0
	beq.s	.eqr1
	cmp.b	d6,d0
	bne.s	.l1
.eqr1:	move.l	a1,d0
	sub.l	a0,d0
	subq.l	#1,d0
	bsr	FindEqu
	beq.s	.nolist
	move.l	d0,a1
	add.w	VAR_len(a1),a0
	move.b	VAR_type(a1),d1
	move.l	VAR_value(a1),d0
	subq.b	#EQU_EQUR,d1		;equr
	bne.s	.isreg1?
	cmp.b	d7,d0
	bls	.aalpha1
.reqr:	bra	Errbad_eqr
.isreg1?:	subq.b	#EQU_REG-EQU_EQUR,d1	;reg
	bne.s	.nolist
	tst.b	(a0)
	bpl.s	.reoo
	tst.l	d3
	bne.s	.nolist
	tst.l	d0
	rts
.nolist:	moveq	#-1,d0
	rts

.alpha2?:	move.l	d0,d1
	move.l	a0,a1
	subq.w	#1,a0
.l2:	move.b	(a1)+,d0
	bmi.s	.eqr2
	cmp.b	d5,d0
	beq.s	.eqr2
	cmp.b	d6,d0
	bne.s	.l2
.eqr2:	move.b	-(a1),-(sp)
	SETEOL	(a1)
	bsr	GetEqur
	move.b	(sp)+,(a1)
	tst.l	d0
	bmi.s	.nolist
	exg	d0,d1
	move.l	a1,a0
	cmp.b	d7,d1
	bls	.aalpha2
	bra.s	.reqr

.reoo:	bra	Erreoo_exp

.diese:	tst.l	d3		;#REG,#<expr>
	bne.s	.nolist
	addq.w	#1,a0
	bsr	GetRegEqu		;#REG?
	bmi.s	.expr
	tst.l	d0
	rts

.expr:	moveq	#1,d0		;#<expr>
	jsr	ForEval		;crade car pas la macro
	bmi.s	.nolist
;	and.l	#$ffff,d0		;16 bits mask max
	tst.l	d0
	rts

;d0.w inverse
invbits:	moveq	#0,d1
	REPT	16
	add.w	d0,d0
	roxr.w	#1,d1
	ENDR
	move.w	d1,d0
	rts

;  #] MOVEM: 
;  #[ MOVEP:	ea,dn//dn,ea
_movep:	subq.w	#2,FIELDSNB
	bne.s	.roper
	moveq	#%100,d7		;word
	moveq	#%101,d6		;long
	move.l	FIELDPTR,a0	;@ 1st field
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bls	.dn_ea
;.ea_dn:
	lea	FIELDNEXT(FIELDPTR),a0
	move.b	(a0),d0
	cmp.b	#TOKEND7,d0
	bls.s	.rest

	jsr	GetEqur
	bmi.s	.eq_ea?
	cmp.b	#TOKEND7,d0
	bls.s	.rest
.rdn:	bra	Errdn_exp
.roper:	bra	Errbad_opernb

.eq_ea?:	move.l	FIELDPTR,a0
	jsr	GetEqur
	bmi.s	.rdn
	cmp.b	#TOKEND7,d0
	bhi.s	.rdn
	bra.s	.dn_ea

.rest:	moveq	#9,d1		;Dn
	lsl.w	d1,d0
	or.w	d0,EAOPCODE

	move.w	OpSize,d0		;size
	bmi.s	.word
	subq.w	#1,d0
	beq.s	.word
	move.w	d6,d0
	bra.s	.set

.word:	move.w	d7,d0
.set:	lsl.w	#6,d0
	or.w	d0,EAOPCODE

	lea	OptiZD16Flg,a0	;disabler optizd16
	move.w	(a0),-(sp)
	clr.w	(a0)
	bsr	GetEa
	move.w	(sp)+,OptiZD16Flg
	cmp.b	#ANINDIR_MODE,EA_mode(EAPTR)
	bne.s	.noindir
	clr.l	EA_value(EAPTR)
	clr.l	EA_vtype(EAPTR)
	bra.s	.emuld16
.noindir:	cmp.b	#D16AN_MODE,EA_mode(EAPTR)
	bne.s	.rd16
.emuld16:	or.b	EA_an(EAPTR),EAOPCODE
	bsr	WPokeOpBin
	move.w	EA_value+2(EAPTR),EAOPCODE	;verifier si ==0 si d1!=0
	move.l	EA_vtype(EAPTR),d1
	beq	WPokeBin
	bsr	WPokeBin
	move.l	FIELDPTR,a0
	move.l	LINE_srcstart(FIELDPTR),a1
	move.l	EA_value(EAPTR),d0
	moveq	#P_DCW,d2
	jmp	StoreEXP
.dn_ea:	INCFIELD
	bset	#1,d6
	bset	#1,d7
	bra	.rest
.rd16:	bra	Errd16_exp
;  #] MOVEP: 
;  #[ MOVEQ:	#i,Dn real unsized Eqr
_moveq:	subq.w	#2,FIELDSNB
	bne.s	.roper
	lea	FIELDNEXT(FIELDPTR),a0		;2nd field=Dn
	moveq	#0,d0
	move.b	(a0)+,d0
	bmi.s	.rdn
	cmp.b	#TOKEND7,d0
	bhi.s	.equr
.asdn:	moveq	#9,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE

	move.l	FIELDPTR,a0			;1st field=i
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JNEVAL
	beq.s	.nopatch
	bmi.s	.rev
	bsr	WPokeOpBin
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_W07,d2
	jmp	StoreEXP
.nopatch:	or.b	d0,EAOPCODE
	moveq	#127,d1
	tst.b	d2
	bne.s	.moins
	cmp.l	d1,d0
	bls.s	.poke
	add.l	d1,d1
	addq.l	#1,d1
	cmp.l	d1,d0
	bhi.s	.rmq
.wmq:	bsr	Warnmq_ext
.poke:	bra	WPokeOpBin
.moins:	not.l	d1
	cmp.l	d1,d0
	blt.s	.rmq
	bra	WPokeOpBin
.roper:	bra	Errbad_opernb
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed
.equr:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.rdn
	cmp.b	#TOKEND7,d0
	bls.s	.asdn
.rdn:	bra	Errdn_exp
.rmq:	bsr	Errmq_ge
	bra	WPokeOpBin
;  #] MOVEQ: 
;  #[ MOVES:	Rn,ea//ea,Rn sized	;10/20/30/40/32
_moves:	tst.w	MPUType
	beq.s	.rmpu
	tst.w	SuprFlg
	bne.s	.rsup
	subq.w	#2,FIELDSNB
	bne.s	.roper
	tst.w	OpSize
	bpl.s	.set
	neg.w	OpSize
.set:	cmp.b	#TOKENA7,(FIELDPTR)	;1st field
	ble.s	.Rn_ea
;.ea_Rn:
	bsr	GetEa		;1st field
	move.w	OpSize,d0
	lsl.w	#6,d0
	or.w	d0,EAOPCODE
 	move.w	EAOPCODE,OpCode
	bsr	BuildOp

	moveq	#0,EAOPCODE		;deuxieme word
	lea	FIELDNEXT(FIELDPTR),a0	;2nd field
.reste:	moveq	#0,d0
	move.b	(a0)+,d0			;Rn
	moveq	#TOKENA0,d1
	cmp.b	d1,d0
	blt.s	.dn_1
	cmp.b	#TOKENA7,d0
	bhi.s	.rxn
	sub.b	d1,d0
	bset	#15,EAOPCODE
.dn_1:	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
	moveq	#12,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa		;ea
.rmpu:	bra	Err10_forb
.rsup:	bra	Errsuper_forb
.roper:	bra	Errbad_opernb
.rxn:	bra	Errxn_exp
.reoo:	bra	Erreoo_exp

.Rn_ea:	INCFIELD
	bsr	GetEa		;2nd field

	move.w	OpSize,d0
	lsl.w	#6,d0
	or.w	d0,EAOPCODE
 	move.w	EAOPCODE,OpCode
	bsr	BuildOp

	move.w	#%100000000000,EAOPCODE	;deuxieme word
	lea	FIELDPREV(FIELDPTR),a0	;1st field
	bra.s	.reste
;  #] MOVES: 
;  #[ Monadiques unsized super mmu:	PSAVE,PRESTORE,PFLUSHR	;51
_psuperumon:
	cmp.w	#MMU_51,MMUType
	bne	Err_mmu_forb
	tst.w	SuprFlg
	beq.s	_umonadics
	bra	Errsuper_forb
;  #] Monadiques unsized super mmu: 
;keep near
;  #[ Monadiques unsized super fpu:	FSAVE,FRESTORE	;81/40
_fsuperumon:
	move.w	FPUType,d0
	subq.w	#FPU_81,d0
	beq.s	.ok
	subq.w	#FPU_40-FPU_81,d0
	bne	Err_fpu_forb
.ok:	tst.w	SuprFlg
	beq.s	_umonadics
	bra	Errsuper_forb
;  #] Monadiques unsized super fpu: 
;keep near
;  #[ Monadiques a ea unsized:	NBCD,Scc,TAS
_bmonadea:
	clr.w	OpSize		;default size is byte
;	bra.s	_as_monadea
;  #] Monadiques a ea unsized: 
;keep near
;  #[ Monadiques a ea standard (6-7):	CLR,NEG,NEGX,NOT	pas TST
_monadea:	move.w	OpSize,d0
	bpl.s	.set
	neg.w	d0
	neg.w	OpSize
.set:	lsl.w	#6,d0
	or.w	d0,EAOPCODE
;  #] Monadiques a ea standard (6-7): 
;keep tight
;  #[ Monadiques unsized:		JMP,JSR,PEA
_umonadics:
_as_monadea:
	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.w	EAOPCODE,OpCode
	bsr	GetEa
	bsr	BuildOp
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.roper:	bra	Errbad_opernb
;  #] Monadiques unsized: 
;  #[ PFLUSH:	pfc,#i//pfc,#i,ea: size+i	;30/40/51	;30
_pflush:	move.l	MPUType,d0
	cmp.w	#MMU_30,d0
	beq.s	.mmu30
	cmp.w	#MMU_51,d0
	beq	_pflushs
	cmp.l	#(MPU_40<<16)|MMU_40,d0
	beq	_pflushn
	cmp.l	#(MPU_40<<16)|MMU_EC,d0
	beq	_pflushn
	bra	Err_mmu_forb
.mmu30:	tst.w	SuprFlg
	bne.s	.rsup
	move.l	REF_opcode(REFPTR),EAOPCODE	;high=ea,low=pfc
	swap	EAOPCODE		;get ea field
	subq.w	#2,FIELDSNB
	bmi.s	.roper
	subq.w	#1,FIELDSNB		;let it as ea flag
	bmi.s	.noea
	bgt.s	.roper

	INCEA			;2nd ma
	INC2FIELD			;3rd field
	bsr	GetEa
	move.w	EAOPCODE,OpCode	;ea opcode
	bsr	BuildOp
	DECFIELD			;2nd field for immediate
	DECEA			;and 1st ma
	swap	EAOPCODE		;get pfc word
	bset	#11,EAOPCODE	;set ea flag
	bra.s	.afterea
.rsup:	bra	Errsuper_forb
.roper:	bra	Errbad_opernb

.noea:	bsr	WPokeOpBin	;direct opcode
	INCFIELD			;2nd field and 1st ma
	swap	EAOPCODE		;get pfc word
.afterea:	move.l	FIELDPTR,a0		;2nd field is i
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JEAEVAL
	beq.s	.nopatch
	bmi.s	.rev

	DECFIELD			;1st field is pfc
	bsr	setpfc

	INCFIELD			;2nd field is i
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	movem.l	EA_value(EAPTR),d0-d1	;+EA_vtype
 	moveq	#P_L57,d2		;prov L58
	jsr	StoreEXP		;d0-d1 set
	tst.w	FIELDSNB
	bmi.s	.end
	INCEA			;2nd ma
	INCFIELD			;3rd field is ea
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed
.end:	rts

.nopatch:	lsl.w	#5,d0
	or.w	d0,EAOPCODE	;mask (8-5)
	DECFIELD			;1st field is pfc
	bsr	setpfc

	tst.w	FIELDSNB
	bmi.s	.end
	INCEA			;2nd ma
	INC2FIELD			;3rd field is ea
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
;  #] PFLUSH: 
;  #[ PFLUSHS:	pfc,#i//pfc,#i,ea: size+i	;51
_pflushs:	cmp.w	#MMU_51,MMUType
	bne.s	.rmmu
	tst.w	SuprFlg
	bne.s	.rsup
	move.l	REF_opcode(REFPTR),EAOPCODE	;high=ea,low=pfc
	swap	EAOPCODE		;get ea field
	subq.w	#2,FIELDSNB
	bmi.s	.roper
	subq.w	#1,FIELDSNB		;let it as ea flag
	bmi.s	.noea
	bgt.s	.roper

	INCEA			;2nd ma
	INC2FIELD			;3rd field
	bsr	GetEa
	move.w	EAOPCODE,OpCode	;ea opcode
	bsr	BuildOp
	DECFIELD			;2nd field for immediate
	DECEA			;and 1st ma
	swap	EAOPCODE		;get pfc word
	bset	#11,EAOPCODE	;set ea flag
	bra.s	.afterea
.rmmu:	bra	Err_mmu_forb
.rsup:	bra	Errsuper_forb
.roper:	bra	Errbad_opernb

.noea:	bsr	WPokeOpBin	;direct opcode
	INCFIELD			;2nd field and 1st ma
	swap	EAOPCODE		;get pfc word
.afterea:	move.l	FIELDPTR,a0		;2nd field is i
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JEAEVAL
	beq.s	.nopatch
	bmi.s	.rev

	DECFIELD			;1st field is pfc
	bsr	setpfc

	INCFIELD			;2nd field is i
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	movem.l	EA_value(EAPTR),d0-d1	;+EA_vtype
 	moveq	#P_L57,d2		;prov L58
	jsr	StoreEXP		;d0-d1 set
	tst.w	FIELDSNB
	bmi.s	.end
	INCEA			;2nd ma
	INCFIELD			;3rd field is ea
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed
.end:	rts

.nopatch:	lsl.w	#5,d0
	or.w	d0,EAOPCODE	;mask (8-5)
	DECFIELD			;1st field is pfc
	bsr	setpfc

	tst.w	FIELDSNB
	bmi.s	.end
	INCEA			;2nd ma
	INC2FIELD			;3rd field is ea
	move.l	REF_left(REFPTR),d7
	bra	BuildEa

;  #] PFLUSHS: 
;  #[ PFLUSHN:	(An) 	;40
_pflushn:	cmp.w	#MPU_40,MPUType
	bne.s	.rmpu
	move.w	MMUType,d0
	cmp.w	#MMU_EC,d0
	beq.s	.wec
	cmp.w	#MMU_40,d0
	bne.s	.rmmu
.sup:	tst.w	SuprFlg
	bne.s	.rsup
	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0
	cmp.b	#'(',(a0)+
	bne.s	.ropar
	move.b	(a0)+,d0
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.eqr
.asan:	cmp.b	#')',(a0)+
	bne.s	.rcpar
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
	or.b	d0,EAOPCODE
	bra	WPokeOpBin
.wec:	bsr	Warnec_40
	bra.s	.sup
.rmpu:	bra	Err40_forb
.rmmu:	bra	Err_mmu_forb
.rsup:	bra	Errsuper_forb
.roper:	bra	Errbad_opernb
.ropar:	bra	Erropar_exp
.reqr:	addq.w	#1,d0
	beq.s	.ran
.rcpar:	bra	Errcpar_exp
.rdn:	bra	Errdn_forb
.reoo:	bra	Erreoo_exp
.eqr:	subq.w	#1,a0
	moveq	#')',d0
	bsr	GetEqur2
	bmi.s	.reqr
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bls.s	.asan
.ran:	bra	Erran_exp
;  #] PFLUSHN: 
;  #[ PLOADR,PLOADW:	pfc,ea	;51/30
_pload:	move.w	MMUType,d0
	subq.w	#MMU_51,d0
	beq.s	.mmuok
	subq.w	#MMU_30-MMU_51,d0
	bne.s	.rmmu
.mmuok:	tst.w	SuprFlg
	bne.s	.rsup
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.l	REF_opcode(REFPTR),EAOPCODE
	swap	EAOPCODE
	INCFIELD
	bsr	GetEa
	move.w	EAOPCODE,OpCode
	bsr	BuildOp
	DECFIELD
	swap	EAOPCODE
	bsr	setpfc		;1st field
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.rmmu:	bra	Err_mmu_forb
.rsup:	bra	Errsuper_forb
.roper:	bra	Errbad_opernb
;  #] PLOADR,PLOADW: 
;  #[ PMOVE:	fc,ea//ea,fc	;51/30/EC30
_pmove:	move.l	MPUType,d0	;MPU|MMU
	subq.w	#MMU_51,d0
	beq.s	.mmuok
	subq.w	#MMU_30-MMU_51,d0
	beq.s	.mmuok
	subq.w	#MMU_EC-MMU_30,d0
	bne.s	.rmmu
	swap	d0
	cmp.w	#MPU_30,d0
	bne.s	.rmmu
.mmuok:	tst.w	SuprFlg
	bne.s	.rsup
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.w	EAOPCODE,OpCode
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	move.l	FIELDPTR,a0		;@ 1st field
	bsr.s	getpfc2
	bmi.s	.ea_mrn
.mrn_ea:	bset	#9,EAOPCODE	;pfc,ea R/W flag
	moveq	#10,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	INCFIELD
	bsr	GetEa		;2nd field
	bsr	BuildOp
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.rmmu:	bra	Err_mmu_forb
.rsup:	bra	Errsuper_forb
.roper:	bra	Errbad_opernb

.ea_mrn:	bsr	GetEa		;ea,pfc
	lea	FIELDNEXT(FIELDPTR),a0	;@ 2nd field
	bsr.s	getpfc2
	bmi.s	.errpfc
	moveq	#10,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	bsr	BuildOp
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.errpfc:	bra	Errpfc_exp

;TT0,TT1
;SRC,CRP,TC->bset #14
;MMUSR->bset #13,14 (btst #8,EAOPCODE)
;PSR->MMUSR
getpfc2:	move.w	(a0)+,d1
	andi.w	#$dfdf,d1
	cmp.w	#'TT',d1
	beq.s	.tt
	cmp.w	#'SR',d1
	beq.s	.sr
	cmp.w	#'CR',d1
	beq.s	.cr
	cmp.w	#'TC',d1
	beq	.tc
	cmp.w	#'MM',d1
	beq	.mm
	cmp.w	#'PS',d1
	beq	.ps
.notpfc:	moveq	#-1,d0
.end:	tst.l	d0
	rts
.tt:	move.w	(a0)+,d1
	cmp.w	#$30ff,d1			;0+TOKENEOL
	beq.s	.tt0
	cmp.w	#$31ff,d1			;1+TOKENEOL
	bne.s	.notpfc
	move.w	OpSize,d1			;tt1
	bmi.s	.sizedef
	subq.w	#LONG_SIZE,d1
	bne.s	.rsize
.sizedef:	moveq	#%011,d0
	bra.s	.end
.tt0:	move.w	OpSize,d1
	bmi.s	.ok2
	subq.w	#LONG_SIZE,d1
	bne.s	.rsize
.ok2:	moveq	#%010,d0
	bra.s	.end
.sr:	move.w	(a0)+,d1
	andi.w	#$dfff,d1
	cmp.w	#$50ff,d1			;P
	bne.s	.notpfc
	move.w	OpSize,d1
	bmi.s	.ok3
	subq.w	#DOUBLE_SIZE,d1
	bne.s	.rsize
.ok3:	moveq	#%010,d0
	bset	#14,EAOPCODE
	bra.s	.end
.cr:	move.w	(a0)+,d1
	andi.w	#$dfff,d1
	cmp.w	#$50ff,d1			;P
	bne.s	.notpfc
	move.w	OpSize,d1
	bmi.s	.ok4
	subq.w	#DOUBLE_SIZE,d1
	bne.s	.rsize
.ok4:	moveq	#%011,d0
	bset	#14,EAOPCODE
	bra.s	.end
.rsize:	bra	Erropsz_forb
.tc:	tst.b	(a0)			;TOKENEOL
	bpl.s	.notpfc
	move.w	OpSize,d1
	bmi.s	.ok5
	subq.w	#LONG_SIZE,d1
	bne.s	.rsize
.ok5:	moveq	#%000,d0
	bset	#14,EAOPCODE
	bra	.end
.mm:	move.w	(a0)+,d1
	andi.w	#$dfdf,d1
	cmp.w	#$5553,d1			;US
	bne	.notpfc
.ps:	move.w	(a0)+,d1
	andi.w	#$dfff,d1
	cmp.w	#$52ff,d1			;R
	bne	.notpfc
	btst	#8,EAOPCODE		;?
	bne.s	.rpsr
	move.w	OpSize,d1
	bmi.s	.ok6
	subq.w	#WORD_SIZE,d1
	bne.s	.rsize
.ok6:	moveq	#0,d0
	bset	#13,EAOPCODE		;?
	bset	#14,EAOPCODE		;?
	bra	.end
.rpsr:	bra	Errmmusr_forb
;  #] PMOVE: 
;  #[ PMOVEFD:	ea,pfc		;30
_pmovefd:	tst.w	SuprFlg
	bne.s	.rsup
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.w	EAOPCODE,OpCode
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	bsr	GetEa
	lea	FIELDNEXT(FIELDPTR),a0	;@ 2nd field
	bsr	getpfc2
	bmi.s	.rpfc
	moveq	#10,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	bsr	BuildOp
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.rsup:	bra	Errsuper_forb
.roper:	bra	Errbad_opernb
.rpfc:	bra	Errpfc_exp
;  #] PMOVEFD: 
;  #[ PTESTR,PTESTW:	pfc,ea,#i[,An] ;51/30/EC30/40/EC40 tst #level
_ptest:	tst.w	SuprFlg
	bne	.rsup
	subq.w	#3,FIELDSNB	;4th field = An ?
	bmi	.roper
	subq.w	#1,FIELDSNB
	bgt	.roper

	move.l	REF_opcode(REFPTR),EAOPCODE	;high=ea,low=pfc
	swap	EAOPCODE		;get ea field
	INCFIELD			;2nd field+1st ma
	bsr	GetEa
	move.w	EAOPCODE,OpCode	;ea opcode
	bsr	BuildOp
	INCFIELD			;3rd field for immediate
	INCEA			;and 2nd ma
	swap	EAOPCODE		;get pfc word

	tst.w	FIELDSNB
	bmi.s	.notan

	lea	FIELDNEXT(FIELDPTR),a0
	move.b	(a0)+,d0
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.equr
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
.asan:	lsl.b	#5,d0
	or.b	d0,EAOPCODE
	bset	#8,EAOPCODE	;A flag (8)

.notan:	move.l	FIELDPTR,a0
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JEAEVAL
	beq.s	.nopatch
	bmi.s	.rev

	DEC2FIELD			;1st field is pfc
	bsr	setpfc

	INC2FIELD			;3rd field is i
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	movem.l	EA_value(EAPTR),d0-d1	;+EA_vtype
 	moveq	#P_L1012,d2
	jsr	StoreEXP		;d0-d1 set

	DECEA			;1st ma
	DECFIELD			;2nd field is ea
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.rsup:	bra	Errsuper_forb
.roper:	bra	Errbad_opernb
.rdn:	bra	Errdn_forb
.reoo:	bra	Erreoo_exp
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed
.equr:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.ran
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bls	.asan
.ran:	bra	Erran_exp

.nopatch:	moveq	#10,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE	;level (12-10)

	DEC2FIELD			;1st field is pfc
	bsr	setpfc

	DECEA			;1st ma
	INCFIELD			;2nd field
	move.l	REF_left(REFPTR),d7
	bra	BuildEa

setpfc:	move.l	FIELDPTR,a0		;#i/Dn/sfc/dfc (PFLUSH/S,PLOADR/W,PTESTR/W)
	move.b	(a0)+,d0
	cmp.b	#'#',d0
	beq.s	.i
	cmp.b	#TOKEND7,d0
	ble.s	.dn
	subq.w	#1,a0
	move.l	(a0)+,d1
	moveq	#0,d0
	cmp.l	#$736663ff,d1	;sfc+TOKENEOL
	beq.s	.end
	cmp.l	#$646663ff,d1	;dfc+TOKENEOL
	bne.s	.rpfc
	moveq	#1,d0
	bra.s	.end
.dn:	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
	bset	#3,d0		;dn flag
	bra.s	.end
.rpfc:	bra	Errpfc_exp
.reoo:	bra	Erreoo_exp
.i:	JNEVAL
	beq.s	.nopatch
	bmi.s	.rev
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_L02,d2
	jsr	StoreEXP
	moveq	#%10000,d0	;(4)
	bra.s	.end
.nopatch:	cmp.l	#%111,d0
	bhi.s	.rge7
	bset	#4,d0
.end:	or.b	d0,EAOPCODE
	bra	WPokeBin
.rge7:	bra	Errpfc_ge_7
.rev:	bra	ErrEv_immed
;  #] PTESTR,PTESTW: 
;  #[ PVALID:*	VAL,ea//An,ea	;51
_pvalid:	cmp.w	#MMU_51,MMUType
	bne.s	.rmmu
	subq.w	#2,FIELDSNB
	bne.s	.roper
	bra	Errnot_imp	;prov
	rts
.rmmu:	bra	Err_mmu_forb
.roper:	bra	Errbad_opernb
;  #] PVALID: 
;  #[ RTD:	;10/20/30/40/32
_rtd:	tst.w	MPUType
	beq.s	.rmpu
	subq.w	#1,FIELDSNB
	bne.s	.roper
	bsr	WPokeOpBin
	bra.s	_as_stop
.rmpu:	bra	Err10_forb
.roper:	bra	Errbad_opernb
;  #] RTD: 
;  #[ STOP:	#i real unsized
_stop:	tst.w	SuprFlg
	bne	Errsuper_forb
	subq.w	#1,FIELDSNB
	bne	Errbad_opernb
	bsr	WPokeOpBin
_as_stop:	move.l	FIELDPTR,a0		;@ i field
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JNEVAL
	beq.s	.nopatch
	bmi.s	.rev
	moveq	#0,EAOPCODE
	bsr	WPokeBin
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_DCW,d2
	jmp	StoreEXP
.nopatch:	move.l	d0,EAOPCODE
	bsr	WPokeBin
	cmp.l	#$ffff,d0
	bhi.s	.rgew
	rts
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed
.rgew:	bra	Errsz_ge_w
;  #] STOP: 
;  #[ SWAP:	Dn real unsized
_swap:	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0)+,d0
	bmi.s	.rdn
	cmp.b	#TOKEND7,d0
	bhi.s	.eqr
	cmp.b	#TOKENEOL,(a0)
	bne.s	.reoo
.asdn:	or.b	d0,EAOPCODE
	bra	WPokeOpBin
.eqr:	subq.w	#1,a0
	bsr	GetEqur
	bmi.s	.rdn
	cmp.b	#TOKEND7,d0
	bls.s	.asdn
.rdn:	bra	Errdn_exp
.roper:	bra	Errbad_opernb
.reoo:	bra	Erreoo_exp
;  #] SWAP: 
;  #[ TRAP:	#i real unsized
_trap:	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JNEVAL
	beq.s	.nopatch
	bmi.s	.rev
	bsr	WPokeOpBin
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_W03,d2
	jmp	StoreEXP			;d0/d1 set
.nopatch:	moveq	#15,d1
	cmp.l	d1,d0
	bhi.s	.rge15
	or.w	d0,EAOPCODE
	bra	WPokeOpBin
.roper:	bra	Errbad_opernb
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed
.rge15:	bra	Errtrap_ge_15
;  #] TRAP: 
;  #[ TRAPcc:	//#i			;20/30/40/32
_trapcc:	cmp.w	#MPU_32,MPUType
	blt.s	.rmpu
	subq.w	#1,FIELDSNB
	bmi.s	.nooper
	bgt.s	.roper
	move.w	OpSize,d0
	bmi.s	.wform
	subq.w	#1,d0
	beq.s	.wform
.lform:	or.b	#%011,EAOPCODE
	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JNEVAL
	beq.s	.lnopat
	bmi.s	.rev
	bsr	WPokeOpBin		;Opcode
	moveq	#0,EAOPCODE
	bsr	LPokeBin			;i
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_ABSL,d2
	jmp	StoreEXP			;d0/d1 set
.rmpu:	bra	Err20_forb
.roper:	bra	Errbad_opernb
.ri:	bra	Erri_exp
.rev:	bra	ErrEv_immed
.nooper:	tst.w	OpSize
	bpl.s	.rsize
	or.b	#%100,EAOPCODE
	bra	WPokeOpBin
.rsize:	bra	Erropsz_forb
.wform:	or.b	#%010,EAOPCODE
	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JNEVAL
	beq.s	.wnopat
	bmi.s	.rev
	swap	EAOPCODE
	clr.w	EAOPCODE
	bsr	LPokeOpBin
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	moveq	#P_ABSW,d2
	jmp	StoreEXP			;d0/d1 set
.lnopat:	bsr	WPokeOpBin
	move.l	d0,EAOPCODE
	bra	LPokeBin
.wnopat:	cmp.l	#$ffff,d0
	bhi.s	.rgew
	swap	EAOPCODE
	move.w	d0,EAOPCODE
	bra	LPokeOpBin
.rgew:	bra	Errsz_ge_w
;  #] TRAPcc: 
;  #[ TST:	monadea spe si mpu>10
_tst:	move.w	OpSize,d0
	bpl.s	.set
	neg.w	d0
	neg.w	OpSize
.set:	lsl.w	#6,d0
	or.w	d0,EAOPCODE
	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.w	EAOPCODE,OpCode
	bsr	GetEa
	bsr	BuildOp
	move.l	REF_left(REFPTR),d7
	cmp.w	#MPU_10,MPUType
	bhi	BuildEa
	andi.l	#%111000111111111101,d7
	bra	BuildEa
.roper:	bra	Errbad_opernb
;  #] TST: 

	IFNE	_68020
;  #[ CALLM:	#i,ea real unsized	;20
_callm:	cmp.w	#MPU_20,MPUType
	bne.s	.rmpu
	move.w	EAOPCODE,OpCode
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	#'#',(a0)+
	bne.s	.ri
	JEAEVAL
	bgt.s	.patch
	bmi.s	.rev
	cmp.l	#$ff,d0
	bhi.s	.rgeb
	move.l	d0,EAOPCODE
.ok:	INCEA
	INCFIELD
	bsr	GetEa		;2nd field
	bsr	BuildOp
	bsr	WPokeBin
	DECFIELD
	DECEA
	move.l	EA_vtype(EAPTR),d1
	beq.s	.nopatch
	lea	1(FIELDPTR),a0
	move.l	LINE_srcstart(FIELDPTR),a1
	addq.w	#1,a1
	move.l	EA_value(EAPTR),d0
	moveq	#P_ABSB,d2
	jsr	StoreEXP
.nopatch:	INCEA
	INCFIELD
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.rmpu:	bra	Err20_forb
.roper:	bra	Errbad_opernb
.ri:	bra	Erri_exp
.patch:	moveq	#0,EAOPCODE
	bra.s	.ok
.rev:	bra	ErrEv_immed
.rgeb:	bra	Errsz_ge_b
;  #] CALLM: 
;  #[ RTM:	Xn	;20
_rtm:	cmp.w	#MPU_20,MPUType
	bne.s	.rmpu
	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	moveq	#0,d0
	move.b	(a0)+,d0
	moveq	#TOKENA0,d1
	cmp.b	d1,d0
	blt.s	.dn
	sub.b	d1,d0
	cmp.b	d1,d0
	bhi.s	.eqr
	tst.b	(a0)
	bpl.s	.reoo
.asan:	bset	#3,EAOPCODE
	bra.s	.asdn
.dn:	tst.b	(a0)
	bpl.s	.reoo
.asdn:	or.w	d0,EAOPCODE
	bra	WPokeOpBin
.rmpu:	bra	Err20_forb
.roper:	bra	Errbad_opernb
.reoo:	bra	Erreoo_exp
.eqr:	subq.w	#1,a0
	jsr	GetEqur
	bmi.s	.rxn
	cmp.b	#TOKEND7,d0
	bls.s	.asdn
	cmp.b	#TOKENA7,d0
	bls.s	.asan
.rxn:	bra	Errxn_exp
;  #] RTM: 
	ENDC	;68020
	IFNE	_68040
;  #[ CINVLP,CPUSHLP:	CL,(An)		;40
_cpushlp:
_cinvlp:	cmp.w	#MPU_40,MPUType
	bne.s	.rmpu
	tst.w	SuprFlg
	bne.s	.rsup
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	bsr.s	getcline
	bmi.s	.rline
	lsl.b	#6,d0		;cache (7-6)
	or.b	d0,EAOPCODE
	lea	FIELDNEXT(FIELDPTR),a0	;(An)
	cmp.b	#'(',(a0)+
	bne.s	.ropar
	move.b	(a0)+,d0
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.ran
	or.b	d0,EAOPCODE
	cmp.b	#')',(a0)+
	bne.s	.rcpar
	tst.b	(a0)		;TOKENEOL
	bmi	WPokeOpBin
.reoo:	bra	Erreoo_exp
.roper:	bra	Errbad_opernb
.rmpu:	bra	Err40_forb
.rsup:	bra	Errsuper_forb
.rline:	bra	Errcline_exp
.rdn:	bra	Errdn_forb
.ran:	bra	Erran_exp
.ropar:	bra	Erropar_exp
.rcpar:	bra	Errcpar_exp

;NC,DC,IC,BC
getcline:	move.w	(a0)+,d1
	andi.w	#$dfdf,d1
	cmp.w	#'NC',d1
	beq.s	.nc
	cmp.w	#'DC',d1
	beq.s	.dc
	cmp.w	#'IC',d1
	beq.s	.ic
	cmp.w	#'BC',d1
	bne.s	.nocache
.bc:	moveq	#%11,d0
	bra.s	.tsteoo
.ic:	moveq	#%10,d0
	bra.s	.tsteoo
.dc:	moveq	#%01,d0
	bra.s	.tsteoo
.nc:	moveq	#%00,d0
;	bra.s	.tsteoo
.tsteoo:	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
.end:	tst.l	d0
	rts
.nocache:	moveq	#-1,d0
	bra.s	.end
.reoo:	bra	Erreoo_exp
;  #] CINVLP,CPUSHLP: 
;  #[ CINVA,CPUSHA:	CL		;40
_cpusha:
_cinva:	cmp.w	#MPU_40,MPUType
	bne.s	.rmpu
	tst.w	SuprFlg
	bne.s	.rsup
	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	bsr.s	getcline
	bmi.s	.rline
	lsl.w	#6,d0
	or.w	d0,EAOPCODE	
	bra	WPokeOpBin
.rmpu:	bra	Err40_forb
.rsup:	bra	Errsuper_forb
.roper:	bra	Errbad_opernb
.rline:	bra	Errcline_exp
;  #] CINVA,CPUSHA: 
;  #[ MOVE16:	(An)+,(An)+//asb.l,(An)//abs.l,(An)+//(An),abs.l//(An)+,abs.l	;40
_move16:
;bset#14,EAOPCODE+Ax,Ay<<12
;Ay,Mode<<3
;	00=(An)+,abs.l
;	01=abs.l,(An)+
;	10=(An),abs.l
;	11=abs.l,(An)
;,long=@
	cmp.w	#MPU_40,MPUType
	bne.s	.rmpu
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	lea	FIELDNEXT(FIELDPTR),a1
	cmp.b	#'(',(a0)+
	bne.s	.long_an
	cmp.b	#'(',(a1)+
	bne	.an_long
.an_an:	bset	#5,EAOPCODE
	moveq	#0,d0
	move.b	(a0)+,d0
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.ran			;equr
	cmp.b	#')',(a0)+
	bne.s	.rcpar
	cmp.b	#'+',(a0)+
	bne.s	.rplus
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
	or.b	d0,EAOPCODE
	swap	EAOPCODE
	move.w	REF_opcode+2(REFPTR),EAOPCODE
;	moveq	#0,d0
	move.b	(a1)+,d0
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.ran
	cmp.b	#')',(a1)+
	bne.s	.rcpar
	cmp.b	#'+',(a1)+
	bne.s	.rplus
	tst.b	(a1)			;TOKENEOL
	bpl.s	.reoo
	moveq	#12,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE
	bra	LPokeOpBin
.rmpu:	bra	Err40_forb
.roper:	bra	Errbad_opernb
.rdn:	bra	Errdn_forb
.ran:	bra	Erran_exp
.ropar:	bra	Erropar_exp
.rcpar:	bra	Errcpar_exp
.rplus:	bra	Errplus_exp
.reoo:	bra	Erreoo_exp

.long_an:	bset	#3,EAOPCODE
	move.l	a1,a0
	bsr.s	getanorpost
	bsr	WPokeOpBin
	move.l	FIELDPTR,a0
	JNEVAL
	beq.s	.nopatch
	bmi.s	.rev
	moveq	#0,EAOPCODE
	bsr	LPokeBin
	move.l	LINE_srcstart(FIELDPTR),a1
	moveq	#P_ABSL,d2
	jmp	StoreEXP		;d0/d1 set
.nopatch:	move.l	d0,EAOPCODE
	bra	LPokeBin
.rev:	bra	ErrEv_immed

.an_long:	subq.w	#1,a0
	bsr.s	getanorpost
	bsr	WPokeOpBin
	INCFIELD
	move.l	FIELDPTR,a0
	JNEVAL
	beq.s	.nopatch
	bmi.s	.rev
	moveq	#0,EAOPCODE
	bsr	LPokeBin
	move.l	FIELDPTR,a0
	move.l	LINE_srcstart(FIELDPTR),a1
	moveq	#P_ABSL,d2
	jmp	StoreEXP		;d0/d1 set

getanorpost:			;(An) ou (An)+ ?
	cmp.b	#'(',(a0)+
	bne.s	.ropar
	moveq	#0,d0
	move.b	(a0)+,d0
	subq.b	#TOKENA0,d0
	bmi.s	.rdn
	cmp.b	#TOKENA7-TOKENA0,d0
	bhi.s	.ran
	or.b	d0,EAOPCODE
	cmp.b	#')',(a0)+
	bne.s	.rcpar
	move.b	(a0)+,d0
	bmi.s	.no_post
	cmp.b	#'+',d0
	bne.s	.rplus
	cmp.b	#TOKENEOL,(a0)
	bne.s	.reoo
	rts
.no_post:	bset	#4,EAOPCODE
	rts
.rdn:	bra	Errdn_forb
.ran:	bra	Erran_exp
.ropar:	bra	Erropar_exp
.rcpar:	bra	Errcpar_exp
.rplus:	bne	Errplus_exp
.reoo:	bra	Erreoo_exp
;  #] MOVE16: 
	ENDC	;_68040
	IFNE	_CPU32
;  #[ LPSTOP:	#i real unsized	;32
_lpstop:	cmp.w	#MPU_32,MPUType
	bne.s	.rmpu
	tst.w	SuprFlg
	bne.s	.rsup
	subq.w	#1,FIELDSNB
	bne.s	.roper
	move.l	REF_opcode(REFPTR),EAOPCODE
	bsr	LPokeOpBin
	bra	_as_stop
.rmpu:	bra	Err32_forb
.rsup:	bra	Errsuper_forb
.roper:	bra	Errbad_opernb
;  #] LPSTOP: 
;  #[ TBLS/N,TBLU/N:	ea,Dn//Dn:Dn,Dn sized	;32
_tbl:	cmp.w	#MPU_32,MPUType
	bne.s	.rmpu
	subq.w	#2,FIELDSNB
	bne.s	.roper
	move.w	EAOPCODE,OpCode
	move.w	REF_opcode+2(REFPTR),EAOPCODE
	move.w	OpSize,d0
	bpl.s	.set
	neg.w	OpSize
	neg.w	d0
.set:	lsl.w	#6,d0
	or.w	d0,EAOPCODE

	move.l	FIELDPTR,a0		;Dym?
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bls.s	.dn_dn

	bsr	GetEa		;1st ea

	lea	LINE_SIZEOF(FIELDPTR),a0	;Dx
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.rdn
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
	moveq	#12,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE

	bsr	BuildOp		;ea
	bsr	WPokeBin
	move.l	REF_left(REFPTR),d7
	bra	BuildEa
.rmpu:	bra	Err32_forb
.roper:	bra	Errbad_opernb
.rdn:	bra	Errdn_exp
.dn_dn:	swap	EAOPCODE
	move.w	OpCode,EAOPCODE
	or.b	d0,EAOPCODE	;Dym
	swap	EAOPCODE
	cmp.b	#':',(a0)+
	bne.s	.rsemi
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.rdn
	or.w	d0,EAOPCODE	;Dyn
	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
	lea	FIELDNEXT(FIELDPTR),a0
	move.b	(a0)+,d0
	cmp.b	#TOKEND7,d0
	bhi.s	.rdn
	moveq	#12,d1
	lsl.w	d1,d0
	or.w	d0,EAOPCODE	;Dx
	tst.b	(a0)		;TOKENEOL
	bmi	LPokeOpBin
.reoo:	bra	Erreoo_exp
.rsemi:	bra	Errsemi_exp
;  #] TBLS/N,TBLU/N: 
	ENDC	;_CPU32
;  #[ Warnings:
Warnreg_empty:
	moveq	#empty_reglist_warnno,d0
	bra.s	InsPWarn
Warn_oddsp:
	moveq	#oddsp_warnno,d0
	bra.s	InsPWarn
Warn_bitmod8:
	moveq	#bitmod8_warnno,d0
	bra.s	InsPWarn
Warn_bitmod32:
	moveq	#bitmod32_warnno,d0
	bra.s	InsPWarn
Warnmq_ext:
	moveq	#mq_ext_warnno,d0
	bra.s	InsPWarn
Warnec_40:
	moveq	#ec_forb_warnno,d0
	bra.s	InsPWarn
Warn_oddbranch:
	moveq	#oddbranch_warnno,d0
;	bra.s	InsPWarn
InsPWarn:	move.l	a0,-(sp)
	neg.w	d0
	lea	insmsg,a0
	move.w	#MSG_WARN,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	clr.w	MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	move.l	(sp)+,a0
	rts
;  #] Warnings: 
;  #[ Optis:
Opti_bwbcc2b:
	moveq	#bwbcc2b_warnno,d0
	moveq	#2,d1
	move.w	WOptBBccFlg,d2
	bra.s	InsPOpti
Opti_bwbcc2l:
	moveq	#bwbcc2l_warnno,d0
;	moveq	#-2,d1
	move.w	WOptBBccFlg,d2
	bra.s	InsPOptN
Opti_move2q:
	moveq	#move2q_warnno,d0
	moveq	#4,d1
	move.w	WOptMv2QFlg,d2
	bra.s	InsPOpti
Opti_ari2q:
	moveq	#ari2q_warnno,d0
	bsr	OpSizeOpti
	move.w	WOptAri2QFlg,d2
	bra.s	InsPOpti
;Opti_zbccb2nop:
;	moveq	#zbccb2nop_warnno,d0
;	move.w	WOptNopFlg,d2
;	bra.s	InsPOptN
Opti_ari2lea:
	moveq	#ari2lea_warnno,d0
	move.w	WOptAri2LeaFlg,d2
	bra.s	InsPOptN
Opti_lea2q:
	moveq	#lea2q_warnno,d0
	moveq	#2,d1
	move.w	WOptLea2QFlg,d2
	bra.s	InsPOpti
Opti_al2w:
	moveq	#moveal2w_warnno,d0
	moveq	#2,d1
	move.w	WOptMvaL2WFlg,d2
	bra.s	InsPOpti
Opti_a2sub:
	moveq	#movea2sub_warnno,d0
	bsr.s	OpSizeOpti
	move.w	WOptMva2SubFlg,d2
	bra.s	InsPOpti
Opti_move2clr:
	moveq	#move2clr_warnno,d0
	moveq	#2,d1
	move.w	WOptMvaL2WFlg,d2
	bra.s	InsPOpti
Opti_cmp2tst:
	moveq	#cmp2tst_warnno,d0
	bsr.s	OpSizeOpti
	move.w	WOptCmp2TstFlg,d2
;	bra.s	InsPOpti
InsPOpti:	add.l	d1,OptiSz
InsPOptN:	addq.l	#1,OptiNb
	tst.w	d2
	bne.s	.msg
	rts
.msg:	neg.w	d0
	lea	insmsg,a0
	move.w	#MSG_OPTI,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	clr.w	MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jmp	OutMsg

OpSizeOpti:
	moveq	#0,d1
	move.w	OpSize,d1
	move.b	.tab(pc,d1.w),d1
	rts
	dc.b	2
.tab:	dc.b	2,2,4
	even
;  #] Optis: 
;  #[ Errors:
Erropsz_forb:
	moveq	#opsz_forb_errno,d0
	bra.s	insperror
;Errxnorsz_exp:
Errsz_exp:
	moveq	#sz_exp_errno,d0
	bra.s	insperror
Errsc_exp:
	moveq	#sc_exp_errno,d0
	bra.s	insperror
Errsc_or_sz_exp:
	moveq	#sz_sc_exp_errno,d0
	bra.s	insperror
;Errea_exp:
Errcant_input:
	moveq	#cant_input_errno,d0
	bra.s	insperror
Errpn_exp:
Erran_exp:
	moveq	#an_exp_errno,d0
	bra.s	insperror
Errdn_forb:
	moveq	#dn_forb_errno,d0
	bra.s	insperror
Erran_forb:
	moveq	#an_forb_errno,d0
	bra.s	insperror
Erropar_exp:
	moveq	#opar_exp_errno,d0
	bra.s	insperror
Errcpar_exp:
	moveq	#cpar_exp_errno,d0
	bra.s	insperror
Errcomma_2many:
	moveq	#comma_2many_errno,d0
	bra.s	insperror
Errxn_exp:
	moveq	#xn_exp_errno,d0
	bra.s	insperror
Errsz_ge_b:
	moveq	#sz_ge_b_errno,d0
	bra.s	insperror
Errsz_ge_w:
	moveq	#sz_ge_w_errno,d0
	bra.s	insperror
Errd16ge:
	moveq	#d16_ge_errno,d0
	bra.s	insperror
Errd8_ge:
	moveq	#d8_ge_errno,d0
	bra.s	insperror
Errsc_forb:
	moveq	#sc_forb_errno,d0
	bra.s	insperror
Errxn_2many:
	moveq	#xn_2many_errno,d0
	bra.s	insperror
Errdn_or_pre_exp:
	moveq	#dn_or_pre_exp_errno,d0
	bra.s	insperror
Errdn_exp:
	moveq	#dn_exp_errno,d0
	bra.s	insperror
Erreoo_exp:
	moveq	#eoo_exp_errno,d0
	bra.s	insperror
Errmin_exp:
	moveq	#min_exp_errno,d0
	bra.s	insperror
Errsz_forb:
	moveq	#sz_forb_errno,d0
	bra.s	insperror
Errea_forb:
	moveq	#ea_forb_errno,d0
	bra.s	insperror
Erri_exp:
	moveq	#i_exp_errno,d0
	bra.s	insperror
Errq_exp:
	moveq	#q_exp_errno,d0
	bra.s	insperror
Errshift_ge_8:
	moveq	#shift_ge_8_errno,d0
	bra.s	insperror
Errw_exp:
	moveq	#w_exp_errno,d0
	bra.s	insperror
Errbitge64:
	moveq	#bitge64_errno,d0
	bra.s	insperror
Errbkptge_8:
	moveq	#bkptge8_errno,d0
	bra.s	insperror
Errsemi_exp:
	moveq	#semi_exp_errno,d0
	bra.s	insperror
;Errcomma_exp:
Errbrace_exp:
	moveq	#brace_exp_errno,d0
	bra.s	insperror
Erroffset_ge_32:
	moveq	#offset_ge_32_errno,d0
;	bra.s	insperror
insperror:
	move.l	a0,-(sp)
;	move.l	a0,d1
;	sub.l	FIELDPTR,d1
;	add.l	LINE_srcstart(FIELDPTR),d1
;	sub.l	CurLPtr,d1
	neg.w	d0
	lea	insmsg,a0
	move.w	#MSG_CORR,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	clr.w	MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	move.l	(sp)+,a0
	rts
Errwidth_ge_32:
	moveq	#width_ge_32_errno,d0
	bra.s	insperror
Errplus_exp:
	moveq	#plus_exp_errno,d0
	bra.s	insperror
Errtrap_ge_15:
	moveq	#trap_gt_15_errno,d0
	bra.s	insperror
Errcr_exp:
	moveq	#cr_exp_errno,d0
	bra.s	insperror
Errreglist_exp:
	moveq	#reglist_exp_errno,d0
	bra.s	insperror
Errd16_exp:
	moveq	#d16_exp_errno,d0
	bra.s	insperror
Errx_exp:
	moveq	#x_exp_errno,d0
	bra.s	insperror
Errfp_exp:
	moveq	#fp_exp_errno,d0
	bra.s	insperror
Errreg_twice:
	moveq	#reg_twice_errno,d0
	bra.s	insperror
Errdn_or_sep_exp:
	moveq	#dn_or_sep_exp_errno,d0
	bra.s	insperror
Errbad_eqr:
Errbad_reglist:
	moveq	#bad_reglist_errno,d0
	bra.s	insperror
Errfpu_dn_sz_forb:
	moveq	#fpu_dn_sz_forb_errno,d0
	bra.s	insperror
Errfpcr_exp:
	moveq	#fpcr_exp_errno,d0
	bra.s	insperror
Errfpu_fp_sz_forb:
	moveq	#fpu_fp_sz_forb_errno,d0
	bra.s	insperror
Err_kfactor_ge:
	moveq	#kfactor_ge_errno,d0
	bra.s	insperror
Errfpiar_exp:
	move	#fpiar_exp_errno,d0
	bra.s	insperror
Errfpu_req:
	move	#fpu_req_errno,d0
	bra	insperror
Errpfc_exp:
	moveq	#pfc_exp_errno,d0
	bra	insperror
Errpfc_ge_7:
	moveq	#pfc_ge_7_errno,d0
	bra	insperror
Errmmusr_forb:
	moveq	#mmusr_forb_errno,d0
	bra	insperror
Errcline_exp:
	moveq	#cline_exp_errno,d0
	bra	insperror
Errshift_ea_1
	moveq	#shift_ea_1_errno,d0
	bra	insperror
Err_wunreach:
	jsr	SprintDisp
	move	#pcw_not_reached_errno,d0
	bra	insperror
Errsuper_forb:
	move	#super_forb_errno,d0
	bra	insperror
Err10_forb:
	move	#mc10_forb_errno,d0
	bra	insperror
Err20_forb:
	move	#mc20_forb_errno,d0
	bra	insperror
Err30_forb:
	move	#mc30_forb_errno,d0
	bra	insperror
Err40_forb:
	move	#mc40_forb_errno,d0
	bra	insperror
Err60_forb:
	move	#mc60_forb_errno,d0
	bra	insperror
Err32_forb:	;ok
	move	#mc32_forb_errno,d0
	bra	insperror
Err_mmu_forb:
	move	#mmu_forb_errno,d0
	bra	insperror
Err_fpu_forb:
	move	#fpu_forb_errno,d0
	bra	insperror
Errmccr_forb:
	move	#mccr_forb_errno,d0
	bra	insperror
Errnot_imp:
	moveq	#not_imp_errno,d0
	bra	insperror
Errmq_ge:	moveq	#sz_ge_b_errno,d0
	bra	insperror
Err_p_exp:	move	#p_exp_errno,d0
	bra	insperror

ErrEv_fpu:
ErrEv_prep:
ErrEv_immed:
	moveq	#eval_immed_errno,d0
	bra.s	inspeverr
ErrEv_pc:	moveq	#eval_pc_errno,d0
;	bra.s	inspeverr
inspeverr:   
	move.l	a0,-(sp)
	neg.w	d0
	neg.w	d1
;	move.l	a0,d2
;	sub.l	FIELDPTR,d2
;	add.l	LINE_srcstart(FIELDPTR),d2
;	sub.l	CurLPtr,d2
	lea	insmsg,a0
	move.w	#MSG_EVAL|MSG_CORR,MSG_flags(a0)
	move.w	d1,MSG_no(a0)
	move.w	d0,MSG_ev(a0)
	clr.w	MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	move.l	(sp)+,a0
	rts

;  #] Errors: 
;  #[ BGND:	;32
_bgnd:	cmp.w	#MPU_32,MPUType
	beq.s	_wpokeusr
	bra	Err32_forb
;  #] BGND: 
;keep near
;  #[ _wpokesup:	RESET,RTE
_wpokesup:
	tst.w	SuprFlg
	bne	Errsuper_forb
;  #] _wpokesup: 
;keep tight
;  #[ _wpokeusr:	BGND,ILLEGAL,NOP,RTR,RTS,TRAPV
_wpokeusr:
	move.w	REF_opcode(REFPTR),EAOPCODE	;opcode
;  #] _wpokeusr: 
;keep tight
;  #[ WPokeOpBin:	None
WPokeOpBin:
	tst.w	SrcType
	bne.s	.src
WPokeBin:	equ	*
	tst.b	SecPokeFlg
	beq.s	.rdata
.poke:	movem.l	d0-d1/a0-a1,-(sp)
	bsr	GetBinBuffer
	move.l	a0,d0
	moveq	#2,d1
	lsr.w	#1,d0
	bcc.s	.pair
	clr.b	(a0)+
	addq.w	#1,d1
	bsr	Err_even
.pair:	move.w	EAOPCODE,(a0)+
	add.l	d1,SecSize
	CHKEVN
	move.l	a0,BinBuffer
	movem.l	(sp)+,d0-d1/a0-a1
	rts
.rdata:	jmp	Errdata_in_bss
.src:	tst.b	SecPokeFlg
	beq.s	.rdata
	bsr	LinnAlloc			;petit bloc src
	bra.s	.poke
;  #] WPokeOpBin: 

;  #[ _pflusha:	;51/30/40
_pflusha:	move.w	MMUType,d0
	cmp.w	#MMU_51,d0
	beq.s	_lpokeusr
	cmp.w	#MMU_30,d0
	beq.s	_lpokeusr
	cmp.w	#MMU_40,d0
	beq.s	_lpokeusr
	bra	Err_mmu_forb
;  #] _pflusha: 
;keep near
;  #[ _fnop:		;40/81
_fnop:	or.w	FPUId,EAOPCODE
	tst.w	FPUType
	bne.s	_lpokeusr
	bra	Err_fpu_forb
;  #] _fnop: 
;keep near
;  #[ _pflushan:	;40
_pflushan:
	cmp.w	#MMU_40,MMUType
	bne	Err_mmu_forb
;  #] _pflushan: 
;keep near
;  #[ _lpokesup:	PFLUSHA (51/30/40),PFLUSHAN (40)
_lpokesup:
	tst.w	SuprFlg
	bne	Errsuper_forb
;  #] _lpokesup: 
;keep tight
;  #[ _lpokeusr:	FNOP
_lpokeusr:	move.l	REF_opcode(REFPTR),EAOPCODE	;opcode
;  #] _lpokeusr: 
;keep tight
;  #[ ANDI/ORI to CCR/SR,FDBcc,FMOVECR,...:	Equated
LPokeOpBin:
	tst.w	SrcType
	bne.s	.src
LPokeBin:	equ	*
	tst.b	SecPokeFlg
	beq.s	.rdata
.poke:	movem.l	d0-d1/a0-a1,-(sp)
	bsr	GetBinBuffer
	move.l	a0,d0
	moveq	#4,d1
	lsr.w	#1,d0
	bcc.s	.pair
	clr.b	(a0)+
	addq.w	#1,d1
	bsr	Err_even
.pair:	move.l	EAOPCODE,(a0)+
	add.l	d1,SecSize
	CHKEVN
	move.l	a0,BinBuffer
	movem.l	(sp)+,d0-d1/a0-a1
	rts
.rdata:	jmp	Errdata_in_bss
.src:	tst.b	SecPokeFlg
	beq.s	.rdata
	bsr	LinnAlloc			;petit bloc src
	bra.s	.poke
;  #] ANDI/ORI to CCR/SR,FDBcc,FMOVECR,...: 
	BSS
;  #[ BSS:
maflags:	ds.b	EA_SIZEOF*3	;max 3 ea/instruction
insmsg:	ds.b	MSG_SIZEOF
;  #] BSS: 
	TEXT


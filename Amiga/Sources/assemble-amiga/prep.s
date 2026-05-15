	XREF	IncbinSize,GetIncBin,UsrTxt
	XREF	get_drive,get_path,get_wd,TestFile,LstOpen,LstClose
	XREF	FpuEval,LValAlloc,FpuConv,IsAbsFname

	XDEF	OutType,SecSizes,TextSize,DataSize,BssSize
	XDEF	_text,_data,SecSize,SrcOrgName,OutSetFlg
	XDEF	SrcCurStart,SrcCurName,CurLNb,CurLPtr
	XDEF	MacStuff,PrefTbl,OutName
	XDEF	DbgType,SrcType,EquFFlg,WarnFlg,CorrFlg,SMemFlg
	XDEF	CorSaveA6,CoringFlg,FPUcr,FPUk,GDbgType,MPUType
	XDEF	OptiLAbs2WFlg,OptiZD16Flg,OptiBdFlg,OptiOdFlg,OptiNopFlg,OptiFBccFlg
	XDEF	WOptLAbs2WFlg,WOptZD16Flg,WOptBdFlg,WOptOdFlg,WOptNopFlg,WOptFBccFlg
	XDEF	SlowFlg,VarRamFlg,FstTime,TotTime,StopFlg,LstCnt,OptiNb,OptiSz
	XDEF	LstPgFlg,LstMttl,LstSttl,LstLnNb,LstPgNb,LstLnLen,LstPgLen,LstSymFlg,LstName,LstHand
	XDEF	CurSection,CurSecType,SecPokeFlg

	XDEF	StartRoutines,Ligne,FieldsPtr,maflags,_fail,prepnocor
	IFNE	AMIGA
	XREF	AddSection,InitSections,ExitSections
	ENDC

	section TEXT
;  #[ A voir:
;Condition: refaire recherche d'instructions
;- reconnaitre macro en decl de macro (nested macros)
;rept 0 pas compatible avec Devpac
;rept/include/endr en mode Slow
;EXITR
;self-inclusion
;  #] A voir:
;  #[ Rs:
	STRUCTINIT
	WORD	IFccNestCnt
	WORD	IFccCant
	WORD	IFccCondValue
	PTR	IFccContext
	PTR	IFccCurBuf
	SIZEOF	IFCC_STUFF_SIZEOF

MACCTXT_BLK_SIZE	equ	1000
;  #] Rs:
;  #[ Err routines:
;	 #[ oper errors:
Errbad_opernb:
	bgt.s	Erroper_2many
Erroper_exp:
	moveq	#oper_exp_errno,d0
	bra	preperror
Erroper_2many:
	moveq	#oper_2many_errno,d0
	bra	preperror
Errstartq_exp:
	moveq	#startq_exp_errno,d0
	bra	preperror
Errendq_exp:
	moveq	#endq_exp_errno,d0
	bra	preperror
;	 #] oper errors:
;  #] Err routines:
;  #[ Prep Routines:
;	 #[ ASCIIx:	string
_ascii:	subq.w	#1,d3
	bmi.s	.roper
	tst.w	SrcType
	bne.s	.src
.asrc:	moveq	#TOKENQUOTE,d7
.nxt:	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	(a0)+,d7
	bne.s	.rquote
	move.l	LINE_tokend(FIELDPTR),d0
	sub.l	a0,d0
	subq.l	#1,d0
	beq.s	.inc		;ligne vide
	bsr	PokeBinBuffer
.inc:	INCFIELD
	dbf	d3,.nxt
	rts
.roper:	bra	Errbad_opernb
.rquote:	bra	Errquote_exp
.src:	bsr	LinnAlloc 		;petit bloc src
	bra.s	.asrc

_asciil:	subq.w	#1,d3
	bmi.s	.roper
	tst.w	SrcType
	bne.s	.src
.asrc:	moveq	#TOKENQUOTE,d7
.nxt:	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	(a0)+,d7
	bne.s	.rquote
	move.l	LINE_tokend(FIELDPTR),d4
	sub.l	a0,d4
	subq.l	#1,d4
	beq.s	.inc		;ligne vide
	bsr	BPokeBin
	move.l	d4,d0
	bsr	PokeBinBuffer
.inc:	INCFIELD
	dbf	d3,.nxt
	rts
.roper:	bra	Errbad_opernb
.rquote:	bra	Errquote_exp
.src:	bsr	LinnAlloc 		;petit bloc src
	bra.s	.asrc

_asciiz:	subq.w	#1,d3
	bmi.s	.roper
	tst.w	SrcType
	bne.s	.src
.asrc:	moveq	#TOKENQUOTE,d7
.nxt:	move.l	FIELDPTR,a0		;@ 1st field
	cmp.b	(a0)+,d7
	bne.s	.rquote
	move.l	LINE_tokend(FIELDPTR),d0
	sub.l	a0,d0
	subq.l	#1,d0
	beq.s	.0		;ligne vide
	bsr	PokeBinBuffer
.0:	moveq	#0,d4
	bsr	BPokeBin
.inc:	INCFIELD
	dbf	d3,.nxt
	rts
.roper:	bra	Errbad_opernb
.rquote:	bra	Errquote_exp
.src:	bsr	LinnAlloc 		;petit bloc src
	bra.s	.asrc
;	 #] ASCIIx:
;	 #[ BSS:		void
_bss:
do_bss:	bsr	doweven
	bsr	end_locals	;a virer
	sf	SecPokeFlg
	moveq	#SEC_bss,d2
	IFNE	AMIGA
	jmp	AddSection
	ENDC
	IFNE	ATARI
	lea	SecSizes,a0
	move.w	CurSection,d0
	bmi.s	.new		;old section=offset
	cmp.w	d2,d0
	beq.s	.end		;deja bss
	lea	BinNumbers,a1
	move.w	CurBinNb,0(a1,d0.w)
	move.l	SecSize,0(a0,d0.w)
.new:	move.l	SEC_bss(a0),SecSize
	move.w	d2,CurSection
	move.w	d2,CurSecType
.end:	rts
	ENDC	;ATARI
;	 #] BSS:
;	 #[ CARGS/PARGS:	names
_pargs:	move.w	d3,d4
	subq.w	#1,d4
	bmi.s	.roper
	moveq	#4,d6			;default offset (4)
	move.w	d4,d0
	mulu	#LINE_SIZEOF,d0
	add.w	d0,FIELDPTR
.l1:	lea	LINE_field(FIELDPTR),a0
	cmp.b	#'#',(a0)
	bne.s	.nooff
	addq.w	#1,a0
	FEVAL
	bmi.s	.reval
	add.l	d0,d6
	bra.s	.nxt
.nooff:	moveq	#2,d5			;default is word
	cmp.b	#'.',(a0)
	beq.s	.rloc
	move.l	LINE_tokend(FIELDPTR),a0
	move.l	a0,d3
	sub.l	FIELDPTR,d3		;label len
	beq.s	.nxt
	moveq	#0,d1
	move.b	-(a0),d1
	sub.b	#TOKENB,d1
	bmi.s	.rinp
	cmp.b	#TOKENL-TOKENB,d1
	bgt.s	.nosz
	add.w	d1,d1
	add.w	d1,d1
	move.l	.t(pc,d1.w),d5
	subq.l	#1,d3
.nosz:	move.w	d3,d0			;length
	moveq	#EQU_EQU,d1		;type
	move.l	d6,d2			;value
	st	d3			;section
	move.l	LINE_srcstart(FIELDPTR),a0	;label start in source
	bsr	stock_rs
	bsr	stock_equate	;a0=pointeur sur struct a inserer dans EquPtr
	add.l	d5,d6
.nxt:	DECFIELD
	dbf	d4,.l1
.end:	rts
.roper:	bra	Errbad_opernb
.reval:	bra	ErrEv_immed
.rloc:	bra	Errlocal_forb
.rinp:	bra	Errcant_input
.t:	dc.l	2,2,4

_cargs:	move.w	d3,d4
	subq.w	#1,d4
	bmi.s	.roper
	moveq	#4,d6			;default offset (4)

.l1:	lea	LINE_field(FIELDPTR),a0
	cmp.b	#'#',(a0)
	bne.s	.nooff
	addq.w	#1,a0
	FEVAL
	bmi.s	.reval
	add.l	d0,d6
	bra.s	.nxt
.nooff:	moveq	#2,d5			;default is word
	cmp.b	#'.',(a0)
	beq.s	.rloc
	move.l	LINE_tokend(FIELDPTR),a0
	move.l	a0,d3
	sub.l	FIELDPTR,d3		;label len
	beq.s	.nxt
	moveq	#0,d1
	move.b	-(a0),d1
	sub.b	#TOKENB,d1
	bmi.s	.rinp
	cmp.b	#TOKENL-TOKENB,d1
	bgt.s	.nosz
	add.w	d1,d1
	add.w	d1,d1
	move.l	.t(pc,d1.w),d5
	subq.l	#1,d3
.nosz:	move.w	d3,d0			;label len
	moveq	#EQU_EQU,d1		;type
	move.l	d6,d2			;value
	st	d3			;section
	move.l	LINE_srcstart(FIELDPTR),a0	;label start in source
	bsr	stock_rs
	bsr	stock_equate	;a0=pointeur sur struct a inserer dans EquPtr
	add.l	d5,d6
.nxt:	INCFIELD
	dbf	d4,.l1
.end:	rts
.roper:	bra	Errbad_opernb
.reval:	bra	ErrEv_immed
.rloc:	bra	Errlocal_forb
.rinp:	bra	Errcant_input
.t:	dc.l	2,2,4
;	 #] CARGS/PARGS:
;	 #[ CNOP: 	value,value
_cnop:	subq.w	#2,d3
	bne.s	.roper
	move.l	FIELDPTR,a0
	FEVAL
	bmi.s	.errev
	tst.b	d1
	bne.s	.errrel
	swap	d1
	tst.b	d1
	bne.s	.errmi
	move.l	d0,d3
	lea	FIELDNEXT(FIELDPTR),FIELDPTR
	move.l	FIELDPTR,a0
	FEVAL
	bmi.s	.errev
	swap	d1
	tst.b	d1
	bne.s	.errmi
	move.l	d0,d4
	beq.s	.end
	move.l	d4,d1
	move.l	SecSize,d5
	move.l	d5,d0
	bsr.s	.ldiv		;d0/d1->d2
	move.l	d2,d0
	move.l	d4,d1
	bsr.s	.lmul		;d0*d1->d2
	sub.l	d2,d5		;reste
	beq.s	.end
	sub.l	d5,d4
	move.l	d4,d5
	tst.b	SecPokeFlg
	beq.s	.nopoke
	moveq	#0,d4
	add.w	d3,d5
	subq.w	#1,d5
	bmi.s	.end
.pad:	bsr	BPokeBin
	dbf	d5,.pad
.end:	rts
.nopoke:	ext.l	d5
	add.l	d3,d5
	add.l	d5,SecSize
	rts
.roper:	bra	Errbad_opernb
.errev:	bra	ErrEv_immed
.errrel:	bra	Errrel_forb
.errmi:	bra	Errmin_forb

.ldiv:	;d0/d1->d2
	movem.l	d5-d6,-(sp)
	moveq	#0,d2
	moveq	#0,d5
	moveq	#31,d6
.loop:	add.l	d2,d2
	roxl.l	d0
	roxl.l	d5
	cmp.l	d1,d5
	blt.s	.clrbt
	addq.l	#1,d2
	sub.l	d1,d5
.clrbt:	dbf	d6,.loop
	movem.l	(sp)+,d5-d6
	rts

.lmul:	;d0*d1->d2
	movem.l	d3-d6,-(sp)
	move.l	d0,d6
	move.l	d1,d3
	move.l	d6,d5
	swap	d5
	move.w	d3,d0
	move.w	d3,d1
	swap	d3
	mulu	d6,d1
	mulu	d5,d0
	swap	d0
	add.l	d0,d1
	move.w	d3,d0
	mulu	d6,d0
	swap	d0
	add.l	d0,d1
	move.l	d1,d2
	movem.l	(sp)+,d3-d6
	rts
;	 #] CNOP:
;	 #[ DC.x:+F	value,
_dc_b:	move.l	#$ff,d5
	moveq	#-128,d6
	moveq	#TOKENQUOTE,d7
.next:	move.l	FIELDPTR,a0		;@ 1st field
	move.b	(a0),d1
	bmi.s	.nx
	cmp.b	d7,d1
	beq.s	.string
	NEVAL
	bmi.s	.errev
	beq.s	.nopatch
	moveq	#0,d4
	bsr	BPokeBin
;	move.l	FIELDPTR,a0
	move.l	LINE_srcstart(FIELDPTR),a1
	moveq	#P_DCB,d2
	jsr	StoreEXP
	bra.s	.nx
.nopatch: move.l	d0,d4
	bsr	BPokeBin
	cmp.l	d5,d0
	bls.s	.nx
	tst.b	d2
	beq.s	.errsize
	cmp.l	d6,d0
	blt.s	.errsize
.nx:	INCFIELD
	dbf	d3,.next
.end:	rts
.errsize: bra	Errsz_ge_b
.errev:	bra	ErrEv_immed

.string:	move.l	LINE_tokend(FIELDPTR),d0
	sub.l	a0,d0
	subq.l	#2,d0
	beq.s	.nx		;ligne vide
	addq.w	#1,a0
	bsr	PokeBinBuffer
	bra.s	.nx

_dc_l:	move.l	FIELDPTR,a0
	NEVAL
	bmi.s	.errev
	bgt.s	.patch
	move.l	d0,d4
	bsr	LPokeBin
.nx:	INCFIELD
	dbf	d3,_dc_l
.end:	rts
.patch:	moveq	#0,d4
	bsr	LPokeBin
;	move.l	FIELDPTR,a0
	move.l	LINE_srcstart(FIELDPTR),a1
	moveq	#P_DCL,d2
	jsr	StoreEXP
	bra.s	.nx
.errev:	bra	ErrEv_immed

_dc_w:	subq.w	#1,d3
	bmi.s	.no_args
	tst.w	SrcType
	bne.s	.src
.asrc:	move.w	OpSize,d0
	bmi.s	.word
	beq	_dc_b
	subq.w	#1,d0
	bne.s	_dc_l
.word:	move.l	#$ffff,d5
	move.l	#-32768,d6
.next:	move.l	FIELDPTR,a0
	NEVAL
	beq.s	.nopatch
	bmi.s	.errev
	moveq	#0,d4
	bsr	WPokeBin
;	move.l	FIELDPTR,a0
	move.l	LINE_srcstart(FIELDPTR),a1
	moveq	#P_DCW,d2
	jsr	StoreEXP
	bra.s	.nx
.src:	bsr	LinnAlloc 		;petit bloc src
	bra.s	.asrc
.nopatch: move.l	d0,d4
	bsr	WPokeBin
	cmp.l	d5,d0
	bls.s	.nx
	tst.b	d2
	beq.s	.errsize
	cmp.l	d6,d0
	blt.s	.errsize
.nx:	INCFIELD
	dbf	d3,.next
	rts
.no_args: bra	Erroper_exp
.errsize: bra	Errsz_ge_w
.errev:	bra	ErrEv_immed
;	 #] DC.x:
;	 #[ DS.x:+F	value,
_ds_w:	subq.w	#1,d3
	bne	Errbad_opernb
	move.w	OpSize,d3
	bpl.s	.sizeset
	neg.w	d3
.sizeset: move.l	FIELDPTR,a0		;@ 1st field
	FEVAL
	bmi.s	.errev
	tst.b	d1
	bne.s	.errrel
	swap	d1
	tst.b	d1
	bne.s	.errmi
	tst.b	SecPokeFlg
	bne.s	.poke
	lea	SecSize,a0
	tst.w	d3
	beq.s	.add
	btst	#0,3(a0)
	beq.s	.pair
	addq.l	#1,(a0)
	bsr	Err_even
.pair:	lsl.l	d3,d0
.add:	add.l	d0,(a0)
	rts
.poke:	tst.w	SrcType
	bne.s	.src
.asrc:	moveq	#0,d1
	subq.w	#1,d3
	bmi	FillBBinBuffer
	btst	#0,SecSize+3
	beq.s	.pair2
	moveq	#0,d4
	bsr	BPokeBin
	bsr	Err_even
.pair2:	subq.w	#1,d3
	bmi	FillWBinBuffer
	bra	FillLBinBuffer
.errev:	bra	ErrEv_immed
.errrel:	bra	Errrel_forb
.errmi:	bra	Errmin_forb
.src:	bsr	LinnAlloc
	bra.s	.asrc
;	 #] DS.x:
;	 #[ DCB.x:+F	value[,value]
_dcb_b:	tst.b	d1
	bne.s	.neg
	cmp.l	#$ff,d0
	bhi.s	.errsize
.fill:	move.l	d0,d1
	move.l	d4,d0
	bra	FillBBinBuffer
.neg:	cmp.l	#128,d0
	bhi.s	.errsize
	neg.l	d0
	bra.s	.fill
.errsize: bra	Errsz_ge_b

_dcb:	moveq	#0,d4
	subq.w	#1,d3
	bmi.s	.roper
	subq.w	#1,d3
	bgt.s	.roper
	tst.w	SrcType
	bne.s	.src

.asrc:	move.l	FIELDPTR,a0		;@ 1st field
	FEVAL
	bmi.s	.rev
	tst.b	d1
	bne.s	.rrel
	swap	d1
	tst.b	d1
	bne.s	.rmi
	move.l	d0,d4
	moveq	#0,d0
	moveq	#0,d1
	addq.w	#1,d3
	beq.s	.got
	lea	FIELDNEXT(FIELDPTR),FIELDPTR
	move.l	FIELDPTR,a0
	FEVAL
	bmi.s	.rev
	tst.b	d1
	bne.s	.rrel
	swap	d1
.got:	move.w	OpSize,d2
	bmi.s	_dcb_w
	beq.s	_dcb_b
	subq.w	#1,d2
	beq.s	_dcb_w
	bra.s	_dcb_l
.roper:	bra	Errbad_opernb
.rmi:	bra	Errmin_forb
.rev:	bra	ErrEv_immed
.rrel:	bra	Errrel_forb
.src:	bsr	LinnAlloc
	bra.s	.asrc

_dcb_w:	tst.b	d1
	bne.s	.neg
	cmp.l	#$ffff,d0
	bhi.s	.rsize
.fill:	move.l	d0,d1
	move.l	d4,d0
	bra	FillWBinBuffer
.neg:	cmp.l	#32768,d0
	bhi.s	.rsize
	neg.l	d0
	bra.s	.fill
.rsize:	bra	Errsz_ge_w

_dcb_l:	tst.b	d1
	beq.s	.pos
	neg.l	d0
.pos:	move.l	d0,d1
	move.l	d4,d0
	bra	FillLBinBuffer
;	 #] DCB.x:
;	 #[ TEXT: 	void
_text:	moveq	#SEC_text,d2
	bra.s	swapsec
;	 #] TEXT:
;	 #[ DATA: 	void
_data:	moveq	#SEC_data,d2
;In: d2=SEC_text ou SEC_data uniquement
swapsec:	IFNE	ATARI
	tst.w	SrcType
	beq.s	.nosrc
	bsr	LinrEnd
	ENDC
.nosrc:	bsr	doweven
	st	SecPokeFlg
	bsr	end_locals	;a virer
	IFNE	AMIGA
	jmp	AddSection
	ENDC	;AMIGA
	IFNE	ATARI
	lea	SecSizes,a0
	lea	SecSize,a1
	move.w	CurSection,d0
	bmi.s	.newsz		;cursection=offset
	cmp.w	d2,d0
	beq.s	.end

	move.l	(a1),0(a0,d0.w)
.newsz:	move.l	0(a0,d2.w),(a1)
	move.w	d2,CurSection
	move.w	d2,CurSecType
;	bsr	update_bin_sec
.end:	;rts

;In: d0=old section, d2=new section (SEC_text ou SEC_data)
update_bin_sec:
	lea	BinNumbers,a0
	cmp.w	#SEC_data,d0
	bhi.s	.l2
	move.w	CurBinNb,0(a0,d0.w)
.l2:	move.w	0(a0,d2.w),CurBinNb
	move.l	CurBinPtr,d0		;current(text)
	beq.s	.end			;none
	move.l	d0,a0
	move.l	BinBuffer,BIN_cur(a0)	;update end (text) addr
	move.l	LstBinPtr,a0		;last
	bra.s	.comp
.l1:	move.l	BIN_prev(a0),d0		;get last prev
	beq.s	.clr			;no old from same section
	move.l	d0,a0
.comp:	cmp.w	BIN_sec(a0),d2
	bne.s	.l1
	move.l	a0,CurBinPtr		;new cur
	move.l	BIN_start(a0),FstBinBuffer
	move.l	BIN_cur(a0),BinBuffer
	move.l	BIN_end(a0),EndBinBuffer
.end:	rts
.clr:	clr.l	CurBinPtr
	clr.l	FstBinBuffer
	clr.l	BinBuffer
	clr.l	EndBinBuffer
	rts
	ENDC	;ATARI
;	 #] DATA:
;	 #[ END:		void
_end:	addq.w	#4,sp
	jmp	EndAsm
;	 #] END:
;	 #[ ENDC: 	void
_endc:	lea	IfccStuff,a2
	tst.w	IFccCant(a2)
	beq.s	.can
	subq.w	#1,IFccCant(a2)
	rts
.can:	subq.w	#1,IFccNestCnt(a2)
	bmi.s	.unexp
	tst.b	IFccCondValue(a2)
	bne.s	.true
	subq.w	#1,PrepSkipCnt
.true:	move.l	IFccContext(a2),a4
	move.l	IFCC_backptr(a4),a0
	move.l	a0,IFccContext(a2)
	bsr.s	.free
;	move.w	IFCC_canteval(a0),IFccCant(a2)
	move.l	a0,d0
	beq.s	.end
	move.b	IFCC_result(a0),IFccCondValue(a2)
.end:	rts
.unexp:	addq.w	#1,IFccNestCnt(a2)
	bra	Errunexp_endc

.free:	movem.l	a0/a1,-(sp)
	IFNE	BLINDOS
	tst.l	IFccCurBuf(a2)
	beq.s	.err
	ENDC
	move.l	IFccCurBuf(a2),a0
	moveq	#IFCC_SIZEOF,d0
	sub.l	d0,IFCCBUF_cur(a0)
	subq.w	#1,IFCCBUF_nb(a0)
	bmi.s	.back
.out:	movem.l	(sp)+,a0/a1
	rts
.back:	move.l	IFCCBUF_prev(a0),IFccCurBuf(a2)
	IFNE	BLINDOS
	beq.s	.err
	ENDC
	bsr	MyMfree
	bra.s	.out
	IFNE	BLINDOS
.err:	_Debugger
	ENDC
;	 #] ENDC:
;	 #[ ENDM: 	void
_endm:	lea	MacStuff,a5
	tst.b	InMacFlg(a5)
	beq.s	end_mac_exp
	sf	InMacFlg(a5)
	subq.w	#1,PrepSkipCnt	;fin de declaration macro
	rts

;fin d'expansion de macro
;a5=@MacStuff
end_mac_exp:
	move.l	MacStackPtr(a5),a2
	tst.w	ReptNestCnt
	bne	.cross
.depile:	subq.w	#1,MacNestCnt(a5)
	bmi	.error
	tst.b	MacAroUsedFlg(a5)
	bne.s	.used
	subq.l	#1,GloMacAroCnt(a5)
.used:	move.b	MACCTXT_aroused(a2),MacAroUsedFlg(a5)
	move.l	MACCTXT_arocnt(a2),LocMacAroCnt(a5)
	move.l	MACCTXT_cur(a2),MacCurPtr(a5)
	move.w	MACCTXT_nbargs(a2),MacNbArgs(a5)
	move.w	MACCTXT_argshift(a2),MacShift(a5)
	move.l	MACCTXT_lnb(a2),CurLNb
	move.l	MACCTXT_incnum(a2),incnum
	move.w	MACCTXT_ifcc(a2),MacIfccCnt(a5)
	move.l	MACCTXT_edblock(a2),CurEditBlock
	move.l	MACCTXT_backsrc(a2),a6
	move.w	ReptNestCnt,d0
	cmp.w	MACCTXT_rept(a2),d0
	beq.s	.same
	move.l	ReptContext,a0
	move.l	a6,REPT_macsrc(a0)
.same:	move.l	MACCTXT_mod(a2),a0
	move.l	a0,CurModPtr
	move.l	MOD_addr(a0),SrcCurStart
	move.l	MOD_num(a0),CurModNb
	bsr	UpdVarRamFlg
	move.l	a6,MacCurExpPtr(a5)
	bsr	FreeMacLine
	move.l	MACCTXT_curbuf(a2),MacCurBufPtr(a5)
	move.l	a2,a0
	move.l	MACCTXT_prev(a0),d2
	bsr	FreeMacCtxt
	move.l	d2,MacStackPtr(a5)
	tst.w	MacNestCnt(a5)
	bne.s	.end
	move.l	#RetNor,(sp)
	tst.w	PrepSkipCnt	;
	beq.s	.end		;ALEX IFNE non ferme en macro
	jmp	Condition 	;
.end:	rts
.cross:		;REPT/ENDM
	move.l	ReptContext,a0
	move.l	REPT_value(a0),d0
	cmp.l	REPT_count(a0),d0	;1ere occurence du REPT?
	beq	.depile		;oui->encore ds la macro
	move.l	REPT_macsrc(a0),d0
	beq	.depile
	move.l	d0,a6
	move.l	d0,MacCurExpPtr(a5)
	rts
.error:	addq.w	#1,MacNestCnt(a5)
.err:	bra	Errmac_unexp_endm
;	 #] ENDM:
;	 #[ ENDR: 	void
_endr:	move.w	ReptNestCnt,d0
	beq.s	.unexp
	move.l	ReptContext,a1
	move.l	a1,a0
	subq.l	#1,REPT_count(a0)
	beq.s	.depile
	move.l	REPT_srcaddr(a0),a6
	move.l	a6,MacStuff+MacCurExpPtr
	move.l	REPT_mod(a0),CurModPtr
	lea	incnum,a1
	move.l	REPT_incnum(a0),(a1)+
	move.l	REPT_lnb(a0),(a1)
	move.l	REPT_edblock(a0),CurEditBlock
	rts
.unexp:	bra	Errunexp_endr
.depile:	subq.w	#1,d0
	move.w	d0,ReptNestCnt
	move.l	REPT_backptr(a1),ReptContext
	move.l	a1,a0
	bra	MyMfree
;	 #] ENDR:
;	 #[ EQU:		value
_fequ:	jsr	IsFPU
	bmi.s	.rfpu
	move.w	#5,OpSize
	move.w	length_variable,d5
	beq.s	.rlabel
	clr.w	length_variable
	tst.b	loc_flag
	bne.s	.rdot
	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	lea	-4*3(sp),sp
	move.l	sp,a1
	jsr	FpuEval
	bpl.s	.evalok
	lea	4*3(sp),sp
	bra	ErrEv_fpu
.evalok:	move.l	sp,a1
	move.l	a1,a2
	move.w	OpSize,d0
	jsr	FpuConv
	; alloue la valeur
	moveq	#14,d0
	jsr	LValAlloc
	beq.s	.nomem
	move.l	d0,a4
	move.w	OpSize,(a4)+
	move.l	(a2)+,(a4)+
	move.l	(a2)+,(a4)+
	move.l	(a2)+,(a4)+
	move.l	a2,sp

	moveq	#EQU_FEQU,d1
	move.l	d0,d2		;VAR_value
	move.w	d5,d0		;VAR_len
	move.l	start_variable,a0
	moveq	#-1,d3		;VAR_sec
	jsr	stock_rs
	bra	stock_equate	;a0=ptr sur struct a inserer dans EquPtr
.rfpu:	bra	Errfpu_req
.roper:	bra	Errbad_opernb
.rev:	bra	ErrEv_immed
.rdot:	bra	Errlocal_forb
.rlabel:	bra	Errlabel_exp
.nomem:	bra	Errglo_ram

_equ:	move.w	length_variable,d5
	beq.s	.rlabel
	clr.w	length_variable
	tst.b	loc_flag
	bne.s	.rdot
	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	FEVAL
	bmi.s	.rev
	move.l	d0,d2		;VAR_value
	subq.b	#1,d1
	move.b	d1,d3		;VAR_seq
	swap	d1
	move.w	d1,d0
	moveq	#EQU_EQU,d1
	tst.w	d0
	beq.s	.plus
	bset	#VAR_MINUS,d1	;VAR_type
.plus:	move.w	d5,d0
	move.l	start_variable,a0
	jsr	stock_rs
	bra	stock_equate	;a0=ptr sur struct a inserer dans EquPtr
.rlabel:	bra	Errlabel_exp
.roper:	bra	Errbad_opernb
.rev:	bra	ErrEv_immed
.rdot:	bra	Errlocal_forb
;	 #] EQU:
;	 #[ FEQUR:	fregister
_fequr:	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0	;@ 1st field
	move.w	(a0)+,d2		;VAR_value
	bmi.s	.reqr
	andi.w	#$dfdf,d2
	cmp.w	#'FP',d2
	bne.s	.reqr
	moveq	#0,d2
	move.b	(a0)+,d2
	sub.b	#'0',d2
	bmi.s	.reqr
	cmp.b	#7,d2
	bhi.s	.reqr
	moveq	#EQU_FEQUR,d1	;VAR_type
	tst.b	(a0)		;TOKENEOL
	bmi	_puteqr
.roper:	bra	Errbad_opernb
.reqr:	bra	Errreg_equr
;	 #] FEQUR:
;	 #[ EQUR: 	register
_equr:	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0	;@ 1st field
	moveq	#0,d2
	move.b	(a0)+,d2		;VAR_value
	bmi.s	.reqr
	cmp.b	#TOKENA7,d2
	bhi.s	.reqr
	moveq	#EQU_EQUR,d1	;VAR_type
	tst.b	(a0)		;TOKENEOL
	bmi.s	_puteqr
.roper:	bra	Errbad_opernb
.reqr:	bra	Errreg_equr

_puteqr:	lea	length_variable,a0
	move.w	(a0),d0
	beq.s	.rlabel
	clr.w	(a0)
	tst.b	loc_flag
	bne.s	.rdot
	st	d3		;VAR_sec
	move.l	start_variable,a0
	jsr	stock_rs
	bra	stock_equate	;a0=pointeur sur struct a inserer dans EquPtr
.rlabel:	bra	Errlabel_exp
.rdot:	bra	Errlocal_forb
;	 #] EQUR:
;	 #[ FREG: 	freglist
_freg:	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0	;@ 1st field
	bsr	getfreglist
	bmi.s	.rlist
	moveq	#EQU_FREG,d1
	move.l	d0,d2		;VAR_value
	bra.s	_putreg
.roper:	bra	Errbad_opernb
.rlist:	bra	Errreglist_exp
;	 #] FREG:
;	 #[ REG:		reglist
_reg:	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0	;@ 1st field
	bsr	getreglist
	bmi.s	.rlist
	move.l	d0,d2		;VAR_value
	moveq	#EQU_REG,d1
	bra.s	_putreg
.roper:	bra	Errbad_opernb
.rlist:	bra	Errreglist_exp

_putreg:	lea	length_variable,a0
	move.w	(a0),d0
	beq.s	.rlabel
	clr.w	(a0)
	tst.b	loc_flag
	bne.s	.rdot
	st	d3		;VAR_sec
	move.l	start_variable,a0
	jsr	stock_rs
	bra	stock_equate	;a0=pointeur sur struct a inserer dans EquPtr
.rlabel:	bra	Errlabel_exp
.rdot:	bra	Errlocal_forb
;	 #] REG:
;	 #[ RS:	b,w,l,f,rsreset,rsset,rseven+F
_rs_w:	move.w	OpSize,d0
	bpl.s	.ok
	neg.w	d0
.ok:	moveq	#1,d5
	lsl.l	d0,d5
	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0	;@ 1st field
	FEVAL
	bmi.s	.reval
	tst.b	d1
	bne.s	.rrel
	swap	d1
	tst.w	d1
	bne.s	.rmin
	mulu	d5,d0
	move.l	RsCountPtr,a0
	move.l	VAR_value(a0),d3
	subq.l	#1,d5
	beq.s	.add
	btst	#0,d3
	beq.s	.add
	addq.l	#1,d3
	addq.l	#1,d0
.add:	add.l	d0,VAR_value(a0)
	lea	length_variable,a0
	move.w	(a0),d0
	beq.s	.end
	clr.w	(a0)
	tst.b	loc_flag
	bne.s	.rloc
	move.l	start_variable,a0
	lea	StrcName,a1
	move.w	(a1),d1
	bne.s	.addstrc
.asstrc:	move.l	d3,d2		;value
	st	d3
	moveq	#EQU_EQU,d1
	jsr	stock_rs
	bra	stock_equate	;a0=pointeur sur struct a inserer dans EquPtr
.roper:	bra	Errbad_opernb
.reval:	moveq	#0,d2
	bra	ErrEv_prep
.rrel:	bra	Errrel_forb
.rmin:	bra	Errmin_forb
.end:	rts
.rloc:	bra	Errlocal_forb
.addstrc: bsr.s	addstrc
	bne.s	.asstrc
.rmem:	bra	Errstrc_ram

addstrc:	move.l	a0,a2
	move.w	d0,d2
	add.w	d0,d1		;new length
	addq.w	#1,d1		;for dot
	moveq	#0,d0
	move.w	d1,d0
	bsr	AllocString
	beq.s	.rmem
	move.l	d0,a0		;new start
	move.l	a0,a3
	move.w	(a1)+,d0
	subq.w	#1,d0
	bmi.s	.skip1
.l1:	move.b	(a1)+,(a3)+
	dbf	d0,.l1
.skip1:	move.b	#'.',(a3)+
	subq.w	#1,d2
	bmi.s	.skip2
.l2:	move.b	(a2)+,(a3)+
	dbf	d2,.l2
.skip2:	move.w	d1,d0		;new length
.rmem:	rts

_rsset:	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0
	FEVAL
	bmi.s	.rev
	tst.b	d1
	bne.s	.rrel
	swap	d1
	tst.b	d1
	beq.s	.end
	neg.l	d0
.end:	move.l	RsCountPtr,a0
	move.l	d0,VAR_value(a0)
	rts
.roper:	bra	Errbad_opernb
.rev:	moveq	#0,d2
	bra	ErrEv_prep
.rrel:	bra	Errrel_forb

_rseven:	move.l	RsCountPtr,a0
	move.l	VAR_value(a0),d0
	move.w	OpSize,d1
	bpl.s	.sizeset
.word:	btst	#0,d0
	beq.s	.end
	addq.l	#1,VAR_value(a0)
.end:	rts

.sizeset: subq.w	#2,d1
	bmi.s	.word
	beq.s	.long
	moveq	#%111,d1
	moveq	#8,d2
	beq.s	.do
.long:	moveq	#%11,d1
	moveq	#4,d2
.do:	and.l	d1,d0
	beq.s	.end
	sub.l	d0,d2
	add.l	d2,VAR_value(a0)
	rts

_rsreset: move.l	RsCountPtr,a0
	clr.l	VAR_value(a0)
	rts

_rsstruct:
_rsunion:	lea	length_variable,a0
	lea	StrcName,a1
	move.w	(a0),(a1)
	beq.s	.end
	clr.w	(a0)
	tst.b	loc_flag
	bne.s	.rloc
	bsr.s	_rsreset
	move.l	start_variable,a0
	move.w	(a1)+,d0		;length
	subq.w	#1,d0
.l1:	move.b	(a0)+,(a1)+	;copy
	dbf	d0,.l1
.end:	rts
.rloc:	bra	Errlocal_forb

_rsend:	move.l	RsCountPtr,a0
	move.l	VAR_value(a0),d3
	lea	.sizeof(pc),a0
	moveq	#6,d0
	lea	StrcName,a1
	move.w	(a1),d1
	beq.s	.rstrc
	bsr	addstrc
	beq.s	.rmem
	clr.w	StrcName
	move.l	d3,d2		;value
	st	d3
	moveq	#EQU_EQU,d1
	jsr	stock_rs
	bra	stock_equate	;a0=pointeur sur struct a inserer dans EquPtr
.rstrc:	bra	Errstrc_end_unexp
.rmem:	bra	Errstrc_ram
.sizeof:	dc.b	"SIZEOF"
	even

;	 #] RS:
;	 #[ SET:		value
_fset:	jsr	IsFPU
	bmi.s	.rfpu
	move.w	#5,OpSize
	moveq	#EQU_FSET,d4
	lea	length_variable,a1
	move.w	(a1),d5
	beq.s	.rlabel
	clr.w	(a1)
	tst.b	loc_flag-length_variable(a1)
	bne.s	.rdot
	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	lea	-4*3(sp),sp
	move.l	sp,a1
	move.l	a1,a2
	jsr	FpuEval
	bmi.s	.errev
	move.l	a2,a1
	move.w	OpSize,d0
	jsr	FpuConv

	move.w	d5,d0
	move.l	start_variable,a0
	bsr	FindEqu
	beq.s	.fstset
	move.l	d0,a0
	move.b	VAR_type(a0),d1
	sub.b	d4,d1
	bne.s	.setequ		;set sur un equate

	move.l	VAR_value(a0),a1
	move.w	OpSize,(a1)+
	REPT	3
	move.l	(a2)+,(a1)+
	ENDR
	move.l	CurLNb,VAR_lnb(a0)
	move.w	CurModNb+2,VAR_mod(a0)
.end:	lea	4*3(sp),sp
	rts
.rfpu:	bra	Errfpu_req
.rlabel:	bra	Errlabel_exp
.roper:	bra	Errbad_opernb
.rdot:	bra	Errlocal_forb
.errev:	bsr	ErrEv_fpu
	bra.s	.end
.setequ:	bsr	Errlabel_equ
	bra.s	.end

.fstset:	moveq	#14,d0
	jsr	LValAlloc
	move.l	d0,d2		;VAR_value
	bne.s	.memok
	lea	4*3(sp),sp
	bra	Errglo_ram
.memok:	move.l	d0,a1
	move.w	OpSize,(a1)+
	REPT	3
	move.l	(a2)+,(a1)+
	ENDR
	lea	4*3(sp),sp
	move.l	start_variable,a0
	move.l	d4,d1
	move.w	d5,d0
	moveq	#-1,d3		;VAR_sec
	jsr	stock_rs
	bra	stock_equate	;a0=pointeur sur struct a inserer dans EquPtr

_set:	moveq	#EQU_SET,d4
	move.w	length_variable,d5
	beq.s	.rlabel
	clr.w	length_variable
	tst.b	loc_flag
	bne.s	.rdot
	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	FEVAL
	bmi.s	.rev
	move.l	d0,d2		;VAR_value
	subq.b	#1,d1
	move.b	d1,d3		;VAR_seq
	swap	d1
	tst.b	d1
	beq.s	.plus
	bset	#VAR_MINUS,d4		;VAR_type
.plus:	move.w	d5,d0
	move.l	start_variable,a0
	bsr	FindEqu
	beq.s	.fstset
	move.l	d0,a0
	move.b	VAR_type(a0),d1
	bclr	#7,d1
	subq.b	#EQU_SET,d1
	bne.s	.setequ		;set sur un equate
	move.l	d2,VAR_value(a0)
	move.b	d4,VAR_type(a0)
	move.b	d3,VAR_sec(a0)
	move.l	CurLNb,VAR_lnb(a0)
	move.w	CurModNb+2,VAR_mod(a0)
	rts
.rlabel:	bra	Errlabel_exp
.roper:	bra	Errbad_opernb
.rdot:	bra	Errlocal_forb
.rev:	bra	ErrEv_immed

.fstset:	move.l	d4,d1
	move.w	d5,d0
	move.l	start_variable,a0
	jsr	stock_rs
	bra	stock_equate	;a0=pointeur sur struct a inserer dans EquPtr

.setequ:	bra	Errlabel_equ
;	 #] SET:
;	 #[ ERROR:	<#>[,<"message">]
_error:	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	FEVAL
	bne.s	.reval
	neg.w	d0
	bra	preperror
.roper:	bra	Errbad_opernb
.reval:	bra	ErrEv_immed
;	 #] ERROR:
;	 #[ WARNING:	<#>[,<"message">]
_warning:	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	FEVAL
	bne.s	.reval
	neg.w	d0
	bra	prepwarn
.roper:	bra	Errbad_opernb
.reval:	bra	ErrEv_immed
;	 #] WARNING:
;	 #[ EVEN: F a gerer
_align:
_even:	move.w	OpSize,d0
	bpl.s	doleven
doweven:	btst	#0,SecSize+3
	beq.s	.end
	tst.b	SecPokeFlg
	beq.s	.add
	bsr	GetBinBuffer
	clr.b	(a0)+
	move.l	a0,BinBuffer
.add:	addq.l	#1,SecSize
.end:	rts

doleven:	subq.w	#2,d0
	bmi.s	doweven
	beq.s	.long
	moveq	#%111,d1	;quad
	moveq	#8,d2
	bra.s	.do
.long:	moveq	#%11,d1
	moveq	#4,d2
.do:	move.l	SecSize,d0
	and.l	d1,d0
	beq.s	.end
	sub.l	d0,d2
	tst.b	SecPokeFlg
	beq.s	.add
	bsr	GetBinBuffer
	move.w	d2,d0
	subq.w	#1,d0
.l1:	clr.b	(a0)+
	dbf	d0,.l1
	move.l	a0,BinBuffer
.add:	add.l	d2,SecSize
.end:	rts

;	 #] EVEN:
;	 #[ FAIL: 	[<"message">]
_fail:
	IFNE	BLINDOS
	illegal
	ENDC	;BLINDOS
	subq.w	#1,d3
	bmi.s	.rfail
	bgt.s	.roper
	move.l	FIELDPTR,a0
	lea	UsrTxt,a1
	moveq	#TOKENQUOTE,d0
	cmp.b	(a0)+,d0
	beq.s	.l1
	moveq	#0,d0
	subq.w	#1,a0
.l1:	move.b	(a0)+,d1
	cmp.b	d1,d0
	beq.s	.out
	move.b	d1,(a1)+
	bra.s	.l1
.out:	clr.b	(a1)
.rfail:	bra	Errfail
.roper:	bra	Errbad_opernb
;	 #] FAIL:
;	 #[ LISTING: list listchar llen noformat nopage page plen spc subttl ttl
;		#[ LIST:	+,-,void
_list:	subq.w	#1,d3
	bmi.s	.on
	beq.s	.oper
	bra	Errbad_opernb
.on:	clr.w	LstCnt
	rts
.oper:	move.w	(FIELDPTR),d0
	cmp.w	#('+'<<8)|TOKENEOL,d0
	bne.s	.minus
	addq.w	#1,LstCnt
	rts
.minus:	cmp.w	#('-'<<8)|TOKENEOL,d0
	bne.s	.on
	subq.w	#1,LstCnt
	rts
;		#] LIST:
;		#[ NOLIST:	void
_nolist:	move.w	#-1,LstCnt
	rts
;		#] NOLIST:
;		#[ NOPAGE:	void
_nopage:	sf	LstPgFlg
	rts
;		#] NOPAGE:
;		#[ PAGE:	+,-,#,void
_page:	tst.w	d3		;for PASM
	beq.s	.ff
	cmp.w	#1,d3
	bhi.s	.roper
	move.w	(FIELDPTR),d0
	cmp.w	#'+'<<8+TOKENEOL,d0
	beq.s	.on
	cmp.w	#'-'<<8+TOKENEOL,d0
	bne.s	_plen
.off:	sf	LstPgFlg		;page	-
	rts
.on:	st	LstPgFlg		;page	+
	rts
.ff:	moveq	#$c,d0		;Form feed
	jsr	PrtChar
	addq.l	#1,LstPgNb
	clr.l	LstLnNb
	rts
.roper:	bra	Errbad_opernb
;		#] PAGE:
;		#[ LLEN,PLEN:	#
_llen:	lea	LstLnLen,a4
	bra.s	__len
_plen:	lea	LstPgLen,a4
__len:	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0
	FEVAL
	bmi.s	.reval
	move.w	d0,(a4)
	rts
.roper:	bra	Errbad_opernb
.reval:	bra	ErrEv_immed
;		#] LLEN,PLEN:
;		#[ TTL,SUBTTL:	""
_subttl:	lea	LstSttl,a1
	bra.s	__ttl
_ttl:	lea	LstMttl,a1
__ttl:	subq.w	#1,d3
	bne.s	.roper
	move.l	LINE_srcstart(FIELDPTR),a0
	move.w	#255-1,d2
	move.b	(a0)+,d0
	cmp.b	#'"',d0
	beq.s	.cpy
	cmp.b	#"'",d0
	beq.s	.cpy
	moveq	#10,d0
.cpy:	move.b	(a0)+,d1
	beq.s	.end
	cmp.b	d0,d1
	beq.s	.end
	move.b	d1,(a1)+
	dbf	d2,.cpy
.end:	clr.b	(a1)
	rts
.roper:	bra	Errbad_opernb
;		#] TTL,SUBTTL:
;		#[ LISTCHAR:	#[,...]
_listchar:
	subq.w	#1,d3
	bmi.s	.roper
.l1:	move.l	FIELDPTR,a0
	FEVAL
	bmi.s	.reval
	jsr	PrtChar
	INCFIELD
	dbf	d3,.l1
	rts
.roper:	bra	Erroper_exp
.reval:	bra	ErrEv_immed
;		#] LISTCHAR:
;		#[ SPC:	#[,...]
_spc:	tst.w	d3
	beq.s	.one
	subq.w	#1,d3
.one:	lea	.crlf(pc),a4
.l1:	move.l	FIELDPTR,a0
	FEVAL
	bmi.s	.reval
	move.l	d0,d4
.l2:	move.l	a4,a0
	jsr	PrtLine
	dbf	d4,.l2
	INCFIELD
	dbf	d3,.l1
	rts
.roper:	bra	Errbad_opernb
.reval:	bra	ErrEv_immed
.crlf:	dc.b	13,10,0
	even
;		#] SPC:
;		#[ FORMAT:	#[,#[,#]]
_format:
_noformat:
	bra	Errnot_imp
;		#] FORMAT:
;	 #] LISTING:
;	 #[ IFcc: 	<value>
;In: d2.b=cond value (true/false), d3.b=Ifcc type
;20 nested IFCCs / block
ifcc:	lea	IfccStuff,a5
	move.l	IFccCurBuf(a5),d0
	move.l	d0,a0
	beq	.alloc
.got:	addq.w	#1,IFCCBUF_nb(a0)
	cmp.w	#20,IFCCBUF_nb(a0)
	bgt.s	.next
	move.l	a0,a1
	move.l	IFCCBUF_cur(a1),a0
	moveq	#IFCC_SIZEOF,d0
	add.l	d0,IFCCBUF_cur(a1)
	move.l	IFccContext(a5),IFCC_backptr(a0)
	move.l	a0,IFccContext(a5)
	tst.w	IFccCant(a5)
	beq.s	.ok
	sf	d2
.ok:	move.b	d2,IFccCondValue(a5)
	move.b	d2,IFCC_result(a0)
	move.w	d4,IFCC_canteval(a0)
	move.b	d3,IFCC_type(a0)
	move.l	CurLPtr,IFCC_srcaddr(a0)
	move.l	CurModPtr,IFCC_mod(a0)
	move.l	CurLNb,IFCC_lnb(a0)
	addq.w	#1,IFccNestCnt(a5)
	tst.b	d2
	bne.s	.end
	addq.w	#1,PrepSkipCnt	;not taken
	tst.w	MacStuff+MacNestCnt
	bne.s	.end
	jsr	Condition
	add.l	d7,incnum
.end:	rts
.next:	subq.w	#1,IFCCBUF_nb(a0)
.alloc:	move.l	a0,d1	;prev
	move.l	#IFCC_SIZEOF*20+IFCCBUF_SIZEOF,d0
	bsr	MyMalloc
	beq	Errifcc_ram
	move.l	d0,a0
	clr.l	IFCCBUF_next(a0)
	clr.w	IFCCBUF_nb(a0)
	add.l	#IFCCBUF_SIZEOF,d0
	move.l	d0,IFCCBUF_cur(a0)
	move.l	a0,IFccCurBuf(a5)
	move.l	d1,IFCCBUF_prev(a0)
	beq	.got
	move.l	d1,a1
	move.l	a0,IFCCBUF_next(a1)
	bra	.got

_ifne:	bsr.s	ifcc_eval
	sne	d2
	moveq	#IFNE_TYPE,d3
	bra	ifcc

_ifeq:	bsr.s	ifcc_eval
	seq	d2
	moveq	#IFEQ_TYPE,d3
	bra	ifcc

_ifge:	bsr.s	ifcc_eval
	sge	d2
	moveq	#IFGE_TYPE,d3
	bra	ifcc

ifcc_eval:
	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	FEVAL
	bmi.s	.reval
	tst.b	d1
	bne.s	.rrel
	swap	d1
	tst.b	d1
	bne.s	.neg
	tst.l	d0
	rts
.neg:	neg.l	d0
	rts
.reval:	bra	ErrEv_prep
.roper:	bra	Errbad_opernb
.rrel:	bra	Errrel_forb
;.unable: move.w	IfccStuff+IFccCant,d4
;	addq.w	#1,IfccStuff+IFccCant
;	moveq	#-1,d1
;	rts

_ifgt:	bsr.s	ifcc_eval
	sgt	d2
	moveq	#IFGT_TYPE,d3
	bra	ifcc

_ifle:	bsr.s	ifcc_eval
	sle	d2
	moveq	#IFNE_TYPE,d3
	bra	ifcc

_iflt:	bsr.s	ifcc_eval
	slt	d2
	moveq	#IFNE_TYPE,d3
	bra	ifcc

_ifnc:	subq.w	#2,d3
	bne.s	.erroper
	bsr.s	comp_prep_strs
	not.b	d2
	moveq	#IFNC_TYPE,d3
	bra	ifcc
.erroper: bra	Errbad_opernb

_ifc:	subq.w	#2,d3
	bne.s	.erroper
	bsr.s	comp_prep_strs
	moveq	#IFC_TYPE,d3
	bra	ifcc
.erroper: bra	Errbad_opernb

comp_prep_strs:
	move.l	FIELDPTR,a0		;@ 1st field
	lea	LINE_SIZEOF(FIELDPTR),a1	;@ 2nd field
	moveq	#"'",d2
	moveq	#TOKENEOL,d3
	moveq	#TOKENQUOTE,d4
	move.b	(a0)+,d0
	cmp.b	d0,d2
	beq.s	.1
	cmp.b	d0,d4
	bne.s	.errstr
.1:	move.b	(a1)+,d0
	cmp.b	d0,d2
	beq.s	.next
	cmp.b	d0,d4
	bne.s	.errstr
.next:	move.b	(a0)+,d0
	cmp.b	d0,d4
	beq.s	.endstr1
	move.b	(a1)+,d1
	cmp.b	d1,d4
	beq.s	.endstr2
	cmp.b	d3,d0
	beq.s	.errendq
	cmp.b	d3,d1
	beq.s	.errendq
	cmp.b	d0,d1
	beq.s	.next
	moveq	#0,d2
	bra.s	.end
.errstr:	bra	Errstartq_exp
.endstr1: cmp.b	(a0),d3
	bne.s	.errgarb
	cmp.b	(a1),d4
	seq	d2
	bra.s	.end
.endstr2: cmp.b	(a1),d3
	bne.s	.errgarb
	cmp.b	d0,d4
	seq	d2
.end:	rts
.errendq: bra	Errendq_exp
.errgarb: bra	Errgarbage_after_str

_ifd:	bsr.s	find_var
	sne	d2
	moveq	#IFD_TYPE,d3
	bra	ifcc

_ifnd:	bsr.s	find_var
	seq	d2
	moveq	#IFND_TYPE,d3
	bra	ifcc

;Out: d0: 0 si not found
find_var:	movem.l	d5/a0,-(sp)
	move.l	FIELDPTR,a0		;@ 1st field
	PMSTRLEN
	move.w	d0,d5
	move.l	FIELDPTR,a0
	move.b	(a0),d1
	cmp.b	#'.',d1
	bne.s	.nodot
	addq.w	#1,a0
	subq.w	#1,d0
	bra.s	.local
.nodot:	sub.b	#'0',d1
	bmi.s	.noloc
	sub.b	#10,d1
	bmi.s	.local
.noloc:	bsr	FindEqu
	bne.s	.end
	move.l	FIELDPTR,a0
	move.w	d5,d0
	jsr	ForceGloVar
	bne.s	.end
	move.l	FIELDPTR,a0
	move.w	d5,d0
	jsr	ForceXRef
	bra.s	.end
	move.l	FIELDPTR,a0
.local:	move.w	d0,d5
	jsr	ForceLocVar
	bne.s	.end
	moveq	#0,d0
.end:	movem.l	(sp)+,d5/a0
	rts

	IFNE	0
sort_loc: tst.l	LocNb
	beq.s	.nosort
	jsr	createl2	;cree la table sans mise a 0 des VARL_nb
	move.l	LocTbl,a0
	move.l	LocNb,d0
	suba.l	a1,a1	;pas de doubly defined
	jmp	QsortL
.nosort:	rts

sort_glo: tst.l	GloNb
	beq.s	.nosort
	jsr	create_globals_table
	move.l	GloTbl,a0
	move.l	GloNb,d0
	suba.l	a1,a1	;pas de traitement des doubly defined
	jsr	QsortL
	move.l	GloNb,d0
	jsr	create_sizes_table
.nosort:	jmp	create_xref_table
	ENDC
;	 #] IFcc:
;	 #[ INCBIN:	<fname>
_incbin:	bra	__incbin	;crade mais bon
;	 #] INCBIN:
;	 #[ Get_prep_fname:
;In:
;a0=source name start, surrounded with single/double quotes
;a1=real name start, ended with 0
get_prep_fname:
	movem.l	d2/d3/a1,-(sp)
	cmp.b	#TOKENQUOTE,(a0)
	beq.s	.q_fname
	move.l	LINE_srcstart(FIELDPTR),a0

	moveq	#13,d1
	moveq	#10,d2
	moveq	#9,d3
.l1:	move.b	(a0)+,d0
	cmp.b	d1,d0
	beq.s	.end
	cmp.b	d2,d0
	beq.s	.end
	cmp.b	d3,d0
	beq.s	.end
	cmp.b	#';',d0
	beq.s	.end
	cmp.b	#' ',d0
	beq.s	.end
	move.b	d0,(a1)+
	bne.s	.l1
	bra.s	.end

.q_fname:	moveq	#TOKENQUOTE,d0
	moveq	#TOKENEOL,d1
	addq.l	#1,a0
.l2:	move.b	(a0)+,d2
	cmp.b	d1,d2
	beq.s	.rend
	cmp.b	d0,d2
	beq.s	.end
	move.b	d2,(a1)+
	bne.s	.l2
.rend:	bra	Errendq_exp

.end:	clr.b	(a1)
	movem.l	(sp)+,d2/d3/a1
	rts
;	 #] Get_prep_fname:
;	 #[ INCLUDE:	<fname>
_include:	subq.w	#1,d3
	bmi	Errfile_exp
	bgt	Erroper_2many
	tst.w	SlowFlg
	beq.s	.nopatch
	bsr	end_locals
.nopatch:	tst.w	SrcType
	beq.s	.nosrc
	bsr	LinrEnd
.nosrc:	lea	-PATHSZ*2(sp),sp
	lea	MacStuff,a5
	move.l	sp,a1
	move.l	sp,a2
	move.l	FIELDPTR,a0		;@ 1st field
	bsr	get_prep_fname
	move.l	a2,a0
	tst.b	IEnvFlg
	beq.s	.noienv
	;;;;; IENV ;;;;;
	bsr	GetIEnvFile
	beq.s	.noienv
	move.l	d0,a3
	bsr	.backctxt
	move.l	MOD_orgnam(a3),a0
	lea	SrcCurName,a1
	bsr	strcpy2
	move.l	a3,a0
	bsr	ModUpdate
	move.l	MOD_addr(a3),a3
	bra.s	.end
	;;;;;;;;;;;;;;;;
.noienv:	tst.w	SlowFlg
	beq.s	.load
	move.l	CurModPtr,a1
	bsr	unload_src
	move.l	d1,d2		;utilise si erreur de chargement
.load:	move.l	a2,a0
	lea	PATHSZ(a2),a1
	bsr	FindIncFile
	bmi.s	.errload
.ffound:	lea	PATHSZ(a2),a0	;nom complet
	moveq	#0,d0
	moveq	#0,d1
	jsr	LoadSrc
	move.l	d0,d3	;src size
	move.l	a0,a3	;@src
	move.l	a2,a0
	lea	SrcCurName,a1
	bsr	strcpy2
	bsr.s	.backctxt
	lea	PATHSZ(a2),a0
	bsr	ModAlloc
	move.l	CurModPtr,a0
	move.l	a3,MOD_addr(a0)
	move.l	d3,MOD_size(a0)

.end:	move.l	a3,SrcCurStart
	clr.l	CurLNb
	moveq	#1,d0
	move.l	d0,incnum
	move.l	a3,a6
	move.l	a3,MacCurExpPtr(a5)
.out:	bsr	UpdVarRamFlg
	lea	PATHSZ*2(sp),sp
	rts

.errload: tst.w	SlowFlg
	beq.s	.go_err
	;recharger le module qui fait l'include pour
	;afficher la ligne de l'erreur
	move.l	CurModPtr,a0
	move.l	d2,MOD_curoffs(a0)
	bsr	reload_src
.go_err:	bsr	Errload_include
	bra.s	.out

.backctxt:
	move.l	CurModPtr,a1
	move.l	a6,d0
	tst.w	MacNestCnt(a5)
	beq.s	.nomac
	move.l	MacCurExpPtr(a5),d0
.nomac:	move.l	d0,MOD_cursrc(a1)
	move.l	CurLNb,MOD_curlnb(a1)
	move.l	incnum,MOD_incnum(a1)
	rts
;	 #] INCLUDE:
;	 #[ INCDIR:	<path>
_incdir:	subq.w	#1,d3
	bne	Errbad_opernb
	lea	-PATHSZ(sp),sp
	move.l	sp,a2
	move.l	a2,a1
	move.l	FIELDPTR,a0
	bsr	get_prep_fname
	move.l	a2,a0
	bsr	AddPath
	lea	PATHSZ(sp),sp
	bmi	Errstrc_ram
	rts
;	 #] INCDIR:
;	 #[ ELSEIF:	void
_else:
_elsif:	lea	IfccStuff,a5
	tst.w	IFccNestCnt(a5)
	beq.s	.spur
	move.l	IFccContext(a5),a0
	not.b	IFCC_result(a0)
	not.b	IFccCondValue(a5)
	beq.s	.false
	subq.w	#1,PrepSkipCnt
	rts
.false:	addq.w	#1,PrepSkipCnt
	tst.w	MacStuff+MacNestCnt
	bne.s	.end
	jsr	Condition
	add.l	d7,incnum
.end:	rts
.spur:	bra	Errunexp_elseif

;In: d2.b=cond value (true/false), d3.b=Ifcc type
elsifcc:	lea	IfccStuff,a5
	tst.w	IFccNestCnt(a5)
	beq	Errunexp_elseif
	move.l	IFccContext(a5),a0
	move.b	d2,IFCC_result(a0)
	move.b	d3,IFCC_type(a0)
	cmp.b	IFccCondValue(a5),d2
	beq.s	.same
	move.b	d2,IFccCondValue(a5)
	bne.s	.taken
	addq.w	#1,PrepSkipCnt	;true/false
.cond:	tst.w	MacStuff+MacNestCnt
	bne.s	.end
	jsr	Condition
	add.l	d7,incnum
.end:	rts
.same:	move.b	d2,IFccCondValue(a5)
	tst.b	d2
	bne.s	.end		;true/true
	bra.s	.cond		;false/false
.taken:	subq.w	#1,PrepSkipCnt	;false/true
	beq.s	.end
	bra.s	.cond

_elsifne: bsr	ifcc_eval
	sne	d2
	moveq	#IFNE_TYPE,d3
	bra	elsifcc

_elsifeq: bsr	ifcc_eval
	seq	d2
	moveq	#IFEQ_TYPE,d3
	bra	elsifcc

_elsifd:	bsr	find_var
	sne	d2
	moveq	#IFD_TYPE,d3
	bra	elsifcc

_elsifge: bsr	ifcc_eval
	sge	d2
	moveq	#IFGE_TYPE,d3
	bra	elsifcc

_elsifgt: bsr	ifcc_eval
	sgt	d2
	moveq	#IFGT_TYPE,d3
	bra	elsifcc

_elsifle: bsr	ifcc_eval
	sle	d2
	moveq	#IFNE_TYPE,d3
	bra	elsifcc

_elsiflt: bsr	ifcc_eval
	slt	d2
	moveq	#IFNE_TYPE,d3
	bra	elsifcc

_elsifnc: subq.w	#2,d3
	bne	Errbad_opernb
	bsr	comp_prep_strs
	not.b	d2
	moveq	#IFNC_TYPE,d3
	bra	elsifcc

_elsifc:	subq.w	#2,d3
	bne	Errbad_opernb
	bsr	comp_prep_strs
	moveq	#IFC_TYPE,d3
	bra	elsifcc

_elsifnd: bsr	find_var
	seq	d2
	moveq	#IFND_TYPE,d3
	bra	elsifcc

cond_elsifcc:
	rts
;	 #] ELSEIF:
;	 #[ MACRO:	void
_macro:	lea	opcode,a1
	move.l	start_variable,a0
	move.w	length_variable,d0
	beq	Errbad_opernb
	moveq	#'a',d2
	moveq	#'z'+1,d3
	moveq	#'a'-'A',d5
	moveq	#'.',d6			;checking de '.'
	subq.w	#1,d0
	moveq	#0,d4
.cp:	move.b	(a0)+,d4
	cmp.b	d6,d4
	beq.s	.rmac
	cmp.b	d2,d4
	bcs.s	.dbf
	cmp.b	d3,d4
	bcc.s	.dbf
	sub.b	d5,d4
.dbf:	add.w	d4,d4
	move.w	d4,(a1)+
	dbf	d0,.cp
	move.w	#'@'*2,(a1)+
	lea	opcode,a0
	jsr	ISearch_nosize
.rmac:	bpl	Errmac_opcode

	lea	MacStuff,a5
	bsr	AllocMacro
	beq	Errmac_ram
	move.l	d0,a2
	move.l	d0,MacCurDecl(a5)
	move.l	CurLNb,MAC_linestart(a2)
	move.l	incnum,MAC_incline(a2)
	move.l	CurLPtr,MAC_curline(a2)
	move.l	a6,MAC_srcstart(a2)
	move.l	CurModPtr,MAC_modstart(a2)
	move.l	CurEditBlock,MAC_edblock(a2)
	bsr	VarAlloc
	beq	.errmem
	move.l	d0,a0
	move.l	start_variable,a1
	move.w	length_variable,d4
	tst.w	VarRamFlg
	bne.s	.copy
.fast:	move.l	a1,VAR_start(a0)
	move.w	d4,VAR_len(a0)
	clr.w	length_variable
	move.w	CurModNb+2,VAR_mod(a0)	;module courant
	move.l	a2,VAR_ptrmac(a0)
	moveq	#EQU_MACRO,d0
	move.b	d0,VAR_type(a0)
	move.l	CurLNb,VAR_lnb(a0)
	movem.l	a2/a5,-(sp)
	jsr	stock_macro		;pas de retour si erreur mem
	st	InMacFlg(a5)
	addq.w	#1,PrepSkipCnt
	move.l	a6,-(sp)
	jsr	Condition
	add.l	d7,incnum
	move.l	(sp)+,d1
	movem.l	(sp)+,a2/a5
	tst.w	SlowFlg
	beq.s	.end
	move.l	HeadMacSrcList(a5),d0
	bne	.link_mac
	move.l	a6,d0
	sub.l	d1,d0
	move.l	d0,d2
	bsr	MyMalloc
	beq.s	.errmem
	move.l	d0,MAC_srcstart(a2)
	move.l	d0,a1
	move.l	d1,a0
.cpmac:	move.b	(a0)+,(a1)+
	subq.l	#1,d2
	bne.s	.cpmac
.end:	rts
.errmem:	bra	Errmac_ram
.copy:	move.l	a0,-(sp)
	move.w	d4,d0
	bsr	AllocString
	beq.s	.errmem
	move.l	a1,a0
	move.l	d0,a1
	move.w	d4,d0
	STRNCPY
	sub.w	d4,a1
	move.l	(sp)+,a0
	bra	.fast
.link_mac:
	movem.l	a3/a4/a6,-(sp)
	moveq	#0,d1
	move.l	d0,a6
.nxm:	move.l	d0,a0
	;somme de la taille des bouts de macros
	movem.l	4(a0),a3-a4
	sub.l	a3,a4
	add.l	a4,d1
	move.l	(a0),d0
	bne.s	.nxm
	;allocation
	move.l	d1,d0
	bsr	MyMalloc
	beq	Errmac_ram
	move.l	d0,a1
	move.l	d0,MAC_srcstart(a2)
	;recopie
	move.l	a6,d1
.nxm2:	move.l	d1,a0
	movem.l	4(a0),a3-a4
.cp2:	move.b	(a3)+,(a1)+
	cmpa.l	a3,a4
	bne.s	.cp2
	move.l	(a0),d1
	bsr	MyMfree	;la struct de 12 octets
	tst.l	d1
	bne.s	.nxm2
	movem.l	(sp)+,a3/a4/a6
	clr.l	HeadMacSrcList(a5)
	clr.l	CurMacSrcList(a5)
	bra	.end
;	 #] MACRO:
;	 #[ SHIFTM:
_shiftm:	lea	MacStuff,a5
	tst.w	MacNestCnt(a5)
	beq.s	.rshiftm
	addq.w	#1,MacShift(a5)
	rts
.rshiftm:	bra	Err_shiftm
;	 #] SHIFTM:
;	 #[ MC68xxx/CPU32:	-,id
_mc68881: subq.w	#1,d3
	bmi.s	.noarg
	bgt.s	.roper
	cmp.w	#'-'<<8+TOKENEOL,(FIELDPTR)
	beq.s	.clr
	move.l	FIELDPTR,a0
	FEVAL
	bmi.s	.reval
	tst.b	d2
	bne.s	.rid
	moveq	#7,d1		;[0-7]
	cmp.l	d1,d0
	bhi.s	.rid
	moveq	#9,d1
	lsl.w	d1,d0
	move.w	d0,FPUId
.noarg:	moveq	#FPU_81,d0
.set:	move.w	d0,FPUType
	rts
.clr:	moveq	#0,d0
	bra.s	.set
.roper:	bra	Errbad_opernb
.reval:	bra	ErrEv_prep
.rid:	bra	Errfpuid_forb

_mc68851: subq.w	#1,d3
	bmi.s	.noarg
	bgt.s	.roper
	cmp.w	#'-'<<8+TOKENEOL,(FIELDPTR)
	bne.s	.rinp
	moveq	#0,d0
.set:	move.w	d0,MMUType
	rts
.noarg:	moveq	#MMU_51,d0
	bra.s	.set
.roper:	bra	Errbad_opernb
.rinp:	bra	Errcant_input

_mc68000: lea	MPUType,a0
	clr.w	(a0)+
	clr.l	(a0)+
	move.w	#$0200,(a0)
	rts
_mc68010: lea	MPUType,a0
	move.w	#MPU_10,(a0)+
	clr.l	(a0)+
	move.w	#$0200,(a0)
	rts
_mc68020: lea	MPUType,a0
	move.w	#MPU_20,(a0)+
	clr.l	(a0)+
	move.w	#$0200,(a0)
	rts
_mc68030: lea	MPUType,a0
	move.w	#MPU_30,(a0)+
	move.w	#MMU_30,(a0)+
	clr.w	(a0)+
	move.w	#$0200,(a0)
	rts
_mc68040: lea	MPUType,a0
	move.w	#MPU_40,(a0)+
	move.w	#MMU_40,(a0)+
	move.w	#FPU_40,(a0)+
	move.w	#$0200,(a0)
	rts
_mc68ec030:
	lea	MPUType,a0
	move.w	#MPU_30,(a0)+
	move.w	#MMU_EC,(a0)+
	clr.w	(a0)+
	move.w	#$0200,(a0)
	rts
_mc68ec040:
	lea	MPUType,a0
	move.w	#MPU_40,(a0)+
	move.w	#MMU_EC,(a0)+
	clr.w	(a0)+
	move.w	#$0200,(a0)
	rts
_mc68060: lea	MPUType,a0
	move.w	#MPU_60,(a0)+
	move.w	#MMU_60,(a0)+
	move.w	#FPU_60,(a0)+
	move.w	#$0200,(a0)
	rts
_mccpu32: lea	MPUType,a0
	move.w	#MPU_32,(a0)+
	clr.l	(a0)+
	move.w	#$0200,(a0)
	rts
;	 #] MC68xxx/CPU32:
;	 #[ MEXIT:	void
_mexit:	lea	MacStuff,a5
	tst.w	MacNestCnt(a5)
	beq	Err_exitm
	move.w	IfccStuff+IFccNestCnt,d0
	sub.w	MacIfccCnt(a5),d0
	beq	end_mac_exp
	move.w	d0,-(sp)
.back:	bsr	_endc
	subq.w	#1,(sp)
	bne.s	.back
	addq.w	#2,sp
	bra	end_mac_exp
;	 #] MEXIT:
;	 #[ NOOBJ:	void
_noobj:	move.w	#-1,ChckFlg
	rts
;	 #] NOOBJ:
;	 #[ OPT:	.+,@#,b+,c+,d+,e+,ip,l012+,m+,n+,o=,o#,ow+,p=,r+,s+,t#,u+,v+,w+,x+,y+
_opt:	bra	__opt
;	 #] OPT:
;	 #[ FOPT: ID=,ROUND=,PREC=,K=
_fopt:	subq.w	#1,d3
	bmi.s	.roper
.l1:	move.l	FIELDPTR,a0		;@ 1st field
	moveq	#1,d0			;not in cmd line
	bsr.s	GetFopt
	bmi.s	.err
	tst.b	(a0)			;TOKENEOL
	bpl.s	.reoo
	INCFIELD
	dbf	d3,.l1
	rts
.roper:	bra	Erroper_exp
.err:	bra	preperror
.reoo:	bra	Erreoo_exp

GetFopt:	moveq	#'=',d1
	bsr	.getup
	cmp.b	#'I',d0
	beq.s	.id
	cmp.b	#'K',d0
	beq.s	.k
	cmp.b	#'P',d0
	beq.s	.prec
	cmp.b	#'R',d0
	beq	.round
.rinp:	bra	Errcant_input

.id:	bsr	.getup
	cmp.b	#'D',d0
	bne.s	.rinp
	cmp.b	(a0)+,d1
	bne.s	.rinp
	FEVAL
	bmi.s	.reval
	tst.b	d2
	bmi.s	.rid
	moveq	#7,d1			;[0-7]
	cmp.l	d1,d0
	bgt.s	.rid
	moveq	#9,d1
	lsl.w	d1,d0
	move.w	d0,FPUId
	bra	.good
.reval:	bra	ErrEv_prep
.rid:	bra	Errfpuid_forb

.k:	cmp.b	(a0)+,d1
	bne.s	.rinp
	FEVAL
	bmi.s	.reval
	moveq	#-64,d1
	cmp.l	d1,d0
	blt.s	.rk
	moveq	#17,d1
	cmp.l	d1,d0
	bgt.s	.rk
	move.w	d0,FPUk
	bra.s	.good
.rk:	bra	Errfpuk_forb

.prec:	bsr	.getup
	cmp.b	#'R',d0
	bne.s	.rinp
	bsr	.getup
	cmp.b	#'E',d0
	bne.s	.rinp
	bsr	.getup
	cmp.b	#'C',d0
	bne.s	.rinp
	cmp.b	(a0)+,d1
	bne	.rinp
	bsr	.getup
	move.w	FPUcr,d1
	andi.b	#%11001111,d1	;4,5
	cmp.b	#'N',d0
	beq.s	.gfpcr
	cmp.b	#'Z',d0
	beq.s	.z
	cmp.b	#'P',d0
	beq.s	.p
	cmp.b	#'M',d0
	beq.s	.m
.rprec:	bra	Errfpuprec_forb
.z:	bset	#4,d1		;4
	bra.s	.gfpcr
.p:	bset	#5,d1		;5
	bra.s	.gfpcr
.m:	ori.b	#%110000,d1	;4+5
.gfpcr:	move.w	d1,FPUcr
.good:	moveq	#0,d0
	rts

.getup:	move.b	(a0)+,d0
	bclr	#5,d0
	rts

.round:	bsr.s	.getup
	cmp.b	#'O',d0
	bne	.rinp
	bsr.s	.getup
	cmp.b	#'U',d0
	bne	.rinp
	bsr.s	.getup
	cmp.b	#'N',d0
	bne	.rinp
	bsr.s	.getup
	cmp.b	#'D',d0
	bne	.rinp
	cmp.b	(a0)+,d1
	bne	.rinp
	bsr.s	.getup
	move.w	FPUcr,d1
	andi.b	#%00111111,d1	;6,7
	cmp.b	#'X',d0
	beq.s	.gfpcr
	cmp.b	#'S',d0
	beq.s	.s
	cmp.b	#'D',d0
	beq.s	.d
.rround:	bra	Errfpuround_forb
.s:	bset	#6,d1		;6
	bra.s	.gfpcr
.d:	bset	#7,d1		;7
	bra.s	.gfpcr

;	 #] FOPT:
;	 #[ ORG:		value
_org:	subq.w	#1,d3
	bne.s	.roper
	move.l	FIELDPTR,a0		;@ 1st field
	FEVAL
	bmi.s	.reval
	tst.b	d1
	bne.s	.rrel
	swap	d1
	tst.b	d1
	beq.s	.ok
	neg.l	d0
.ok:	move.w	CurSecType,d1
	cmp.w	#SEC_bss,d1
	beq.s	.rbss
	move.l	d0,SecSize
	rts
.roper:	bra	Errbad_opernb
.reval:	bra	ErrEv_prep
.rrel:	bra	Errrel_forb
.rbss:	bra	Errorg_in_bss
;	 #] ORG:
;	 #[ OFFSET:	value
_offset:	move.l	CurOffset,d0
	tst.w	d3
	beq.s	.switch
	move.l	FIELDPTR,a0		;@ 1st field
	FEVAL
	bmi.s	.rev
	tst.b	d1
	bne.s	.rrel
	swap	d1
	tst.b	d1
	beq.s	.put
	neg.l	d0
.put:	move.l	d0,CurOffset
.switch:	move.l	d0,d3
	moveq	#SEC_off,d2
	move.w	CurSecType,d0
	move.w	d2,CurSecType
	move.w	d2,CurSection
	cmp.w	d2,d0
	beq.s	.end
	cmp.w	#SEC_bss,d0
	beq.s	.size
	;sauver le bin # de la section text ou data
	lea	BinNumbers,a1
	move.w	CurBinNb,0(a1,d0.w)
.size:	lea	SecSizes,a0
	move.l	SecSize,0(a0,d0.w)
.end:	sf	SecPokeFlg
	move.l	d3,SecSize
	rts
.rev:	bra	ErrEv_prep
.rrel:	bra	Errrel_forb
;	 #] OFFSET:
;	 #[ OUTPUT:	fname
_output:	subq.w	#1,d3
	bne.s	.errfile
	move.l	FIELDPTR,a0		;@ 1st field
	lea	-PATHSZ(sp),sp
	move.l	sp,a1
	bsr	get_prep_fname
	move.l	sp,a0
	bsr	SetOutName
	lea	PATHSZ(sp),sp
	rts
.errfile: blt	Errfile_exp
	bra	Erroper_2many
;	 #] OUTPUT:
;	 #[ REPT: 	value
_rept:	subq.w	#1,d3
	bne	Errbad_opernb
	move.l	FIELDPTR,a0		;@ 1st field
	FEVAL
	bmi.s	.reval
	tst.b	d1
	bne.s	.rrel
	swap	d1
	tst.b	d1
	bne.s	.errmi
	move.l	d0,d2
	beq.s	.errmi
	moveq	#REPT_SIZEOF,d0
	jsr	MyMalloc
	beq.s	.errmem
	addq.w	#1,ReptNestCnt
	move.l	d0,a0
	lea	ReptContext,a1
	move.l	(a1),(a0)+	;REPT_backptr
	move.l	d0,(a1)
	move.l	d2,(a0)+		;REPT_count
	move.l	d2,(a0)+		;REPT_value
	tst.w	MacStuff+MacNestCnt
	beq.s	.nomac
	move.l	MacStuff+MacCurExpPtr,a6
.nomac:	move.l	a6,(a0)+		;REPT_srcaddr
	clr.l	(a0)+		;REPT_macsrc
	move.l	CurModPtr,(a0)+	;REPT_mod
	lea	incnum,a1
	movem.l	(a1),d0-d2	;REPT_incnum,linenum,decladdr
	movem.l	d0-d2,(a0)
	move.l	CurEditBlock,12(a0)
	rts
.reval:	bra	ErrEv_prep
.rrel:	bra	Errrel_forb
.errmi:	bra	Errrept_neg
.errmem:	bra	Errrept_ram
;	 #] REPT:
;	 #[ SECTION:	name
_section: tst.w	d3
	beq	Errbad_opernb
	IFNE	AMIGA
	bsr	_even
	bsr	end_locals
	move.l	FIELDPTR,a0
	moveq	#SEC_text,d2
	jmp	AddSection
	ENDC
	IFNE	ATARI
	move.l	FIELDPTR,a0		;@ 1st field
	move.l	(a0)+,d0
	andi.l	#$dfdfdfdf,d0
	cmp.l	#'BSS'<<8+$df,d0	;BSS+EOL
	beq	do_bss
	move.b	(a0),d1
	cmp.b	#TOKENEOL,d1
	bne.s	.inval
	cmp.l	#'TEXT',d0	;TEXT
	beq	_text
	cmp.l	#'DATA',d0	;DATA
	beq	_data
.inval:	bra	Errsec_name
	ENDC	;ATARI
;	 #] SECTION:
;	 #[ SUPER/USER:	void
_super:	clr.w	SuprFlg
	rts

_user:	move.w	#-1,SuprFlg
	rts
;	 #] SUPER/USER:
;	 #[ Xef:
XEF	MACRO
_x\1ef:	tst.w	OutType+2
	bne.s	.link
	bra	Warnx\1ef_spur	;skip XDEF if executable
.roper:	bra	Erroper_exp
.rloc:	bsr	Errlocal_forb
	bra	.nxt2
.link:	subq.w	#1,d3
	bmi.s	.roper

	move.l	x\1efs_ptr,d0
	bne.s	.nofirst
	bsr	alloc_xef_block
	move.l	d0,x\1efs_ptr
.nofirst: move.l	d0,a2		;a2=pointeur sur 1er XREFL

.putxef:	cmp.b	#'.',LINE_field(FIELDPTR)
	beq.s	.rloc

	move.l	LINE_tokend(FIELDPTR),d4
	sub.l	FIELDPTR,d4		;name len
	move.l	LINE_srcstart(FIELDPTR),a4	;name @
	tst.w	VarRamFlg
	bne.s	.alloc
.fast:	move.w	VARL_nb(a2),d0
	cmp.w	#XREFS_PER_BLOCK,d0
	bne.s	.more
	tst.l	VARL_next(a2)
	beq.s	.no_next
	move.l	VARL_next(a2),a2
	bra.s	.fast

.rvarram: jmp	Errx\1ef_ram
.rnamram: jmp	Errname_ram

.alloc:	move.w	d4,d0		;alloc name
	jsr	AllocString
	beq.s	.rnamram
	move.l	a4,a0		;copy from token to alloc
	move.l	d0,a4		;new name @
	move.l	a4,a1
	move.w	d4,d0
	STRNCPY
	bra.s	.fast

.no_next: bsr	alloc_xef_block	;block plein -> creer suivant
	move.l	d0,VARL_next(a2)
	move.l	d0,a2

.more:	move.w	VARL_nb(a2),d0
	move.l	VARL_block(a2),a1
	add.w	d0,d0
	add.w	d0,d0
	lea	0(a1,d0.w),a1	;adresse ou stocker pointeur sur xdef_struct

	jsr	VarAlloc
	beq.s	.rvarram
	move.l	d0,a0
	move.l	a0,(a1)		;stockage de l'XEF
	addq.w	#1,VARL_nb(a2)
.nxt:	move.l	a4,VAR_start(a0)
	move.w	d4,VAR_len(a0)
	clr.l	VAR_value(a0)
	move.w	CurModNb+2,VAR_mod(a0)	;module courant
	move.w	#VAR_X\2EF<<8,VAR_type(a0)
	move.l	CurLNb,VAR_lnb(a0)
	addq.l	#1,X\1efNb
.nxt2:	INCFIELD
	dbf	d3,.putxef
	rts
	ENDM
;	 #] Xef:
;	 #[ XDEF: 	name,
	XEF	d,D
;	 #] XDEF:
;	 #[ XREF: 	name,
	XEF	r,R
;	 #] XREF:
;	 #[ A faire + tard:*
_iif:
_module:
_endmod:	bra	Errnot_imp
;	 #] A faire + tard:
;  #] Prep Routines:
;  #[ Macro Stuff:
;	 #[ StartMacExp:
;In: d3=champs-2
StartMacExp:
	tst.w	SrcType
	beq.s	.nosrc
	jsr	LinnAlloc
.nosrc:	move.l	LINE_srcstart(FIELDPTR),a2
	lea	MacStuff,a5
	tst.w	MacNestCnt(a5)
	beq.s	.fst
	move.l	MacCurExpPtr(a5),a6
.fst:	move.l	MacNb,a4
	move.l	sp,a1
	lea	-500(sp),sp
;analyse des arguments
	move.l	a1,a3
	moveq	#0,d0
	move.b	MacCallSize(a5),d0
	move.w	d0,-(a1)		;param \0
	clr.l	-(a1)
	move.w	d3,d0
	beq.s	.noargs
	move.l	a2,a0		;l'ascii du source
	bsr	ParseMacArgs
	move.w	d0,d3		;nb d'args
.noargs:	move.l	MacNARGptr(a5),a0
	ext.l	d0
	move.l	d0,VAR_value(a0)
	move.l	a3,d0
	sub.l	a1,d0
	move.w	d0,d2
;allocation contexte
	moveq	#MACCTXT_SIZEOF,d1
	add.l	d1,d0
	bsr	AllocMacCtxt
	tst.l	d0
	beq	Errmac_ram
	move.l	d0,a2
	move.l	MacStackPtr(a5),MACCTXT_prev(a2)
	move.l	a2,MacStackPtr(a5)
;sauvegarde contexte
	move.l	MacCurBufPtr(a5),MACCTXT_curbuf(a2)
	move.l	CurLNb,MACCTXT_lnb(a2)
	move.l	incnum,MACCTXT_incnum(a2)
	move.l	CurLPtr,MACCTXT_lptr(a2)	;uniquement pour erreurs
	move.l	MacCurPtr(a5),MACCTXT_cur(a2)
	move.w	MacNbArgs(a5),MACCTXT_nbargs(a2)
	move.w	MacShift(a5),MACCTXT_argshift(a2)
	move.l	CurModPtr,MACCTXT_mod(a2)
	move.w	ReptNestCnt,MACCTXT_rept(a2)
	move.w	MacIfccCnt(a5),MACCTXT_ifcc(a2)
	move.l	a6,MACCTXT_backsrc(a2)	;src derriere l'appel macro
	move.l	CurEditBlock,MACCTXT_edblock(a2)
	move.b	MacAroUsedFlg(a5),MACCTXT_aroused(a2)
	move.l	LocMacAroCnt(a5),MACCTXT_arocnt(a2)
;recopie des arguments
	add.l	d1,a2
	move.w	d3,d0
.cp:	move.w	-(a3),(a2)+
	move.l	-(a3),(a2)+
	dbf	d0,.cp
;nouveau contexte
	bsr	AllocMacLine
	move.l	d0,MacCurBufPtr(a5)
	sf	MacAroUsedFlg(a5)
	move.l	GloMacAroCnt(a5),LocMacAroCnt(a5)
	addq.l	#1,GloMacAroCnt(a5)
	move.l	a4,MacCurPtr(a5)
	move.w	IfccStuff+IFccNestCnt,MacIfccCnt(a5)
	move.l	VAR_ptrmac(a4),a0
	move.l	MAC_srcstart(a0),MacCurExpPtr(a5)
	move.l	MAC_linestart(a0),CurLNb
	move.l	MAC_incline(a0),incnum
	move.w	d3,MacNbArgs(a5)
	clr.w	MacShift(a5)
	move.l	FstModPtr,a0
	move.w	VAR_mod(a4),d0
	subq.w	#2,d0
	bmi.s	.fstmod
.l1:	move.l	MOD_next(a0),a0
	dbf	d0,.l1
.fstmod:	move.l	a0,CurModPtr
	move.l	MOD_num(a0),CurModNb
	move.l	MOD_addr(a0),SrcCurStart
	addq.w	#1,MacNestCnt(a5)
	bsr	UpdVarRamFlg
.noinc:	lea	504(sp),sp
	jmp	RetMac
;	 #] StartMacExp:
;	 #[ GetMacro:
;In:
;a0=variable string
;Out:
;d0.l=@struct macro, 0 sinon
;A1=@instr dans src
;d4=instr size ds source
;d5=.SIZE
; a1,d5,d0 = valeurs temporaires dans line.s
GetMacro:
	movem.l	d1-d3/a0-a2,-(sp)
	move.l	a1,a0
	move.b	d0,MacStuff+MacCallSize
	move.w	d5,d0
	jsr	find_macro
	beq.s	.nf
	move.l	d0,a0
.end:	movem.l	(sp)+,d1-d3/a0-a2
	rts
.nf:	moveq	#0,d0
	bra.s	.end
;	 #] GetMacro:
;	 #[ ParseMacArgs:
;In: a0=@operands src line, a1=@macro stack, a6=@start next src line
;    a5=@MacStuff
;Out: d0=nb d'args, a1=@macro stack, a6=@start next src line
ParseMacArgs:
	move.l	a3,-(sp)
	moveq	#0,d2	;nb d'args
	moveq	#' ',d4
	moveq	#9,d5
	moveq	#10,d6
	moveq	#13,d7
	move.l	a0,a3
.srch:	move.b	(a0)+,d0
	beq.s	.end
	cmp.b	#';',d0
	beq.s	.go_eol
	cmp.b	d4,d0
	beq.s	.srch
	cmp.b	d5,d0
	beq.s	.srch
	cmp.b	d6,d0
	beq.s	.lf
	cmp.b	d7,d0
	beq.s	.cr
	lea	-1(a0),a3
	bsr.s	GetMacArg
	addq.w	#1,d2
	move.w	d1,-(a1)	;quote flag+size
	move.l	a3,-(a1)	;ptr
	move.l	a0,a3
	bra.s	.srch
.lf:	cmp.b	(a0),d7
	bne.s	.end
	addq.l	#1,a0
.cr:	cmp.b	(a0),d6
	bne.s	.end
	addq.l	#1,a0
.end:	cmp.b	#',',-1(a3)
	beq.s	.see_next_line
._end:	move.l	(sp)+,a3
	move.w	d2,d0
	rts
.go_eol:	move.b	(a0)+,d0
	beq.s	.end
	cmp.b	(a0),d6
	beq.s	.lf
	cmp.b	(a0),d7
	bne.s	.go_eol
	bra.s	.cr

.see_next_line:
	cmp.b	#'&',(a6)
	bne.s	._end
	clr.w	length_variable
	addq.w	#1,a6
	move.l	a6,a0
;mettre a6 au debut de la ligne suivante
.l1:	move.b	(a6)+,d0
	beq.s	.go
	cmp.b	d7,d0
	beq.s	.cr2
	cmp.b	d6,d0
	bne.s	.l1
	cmp.b	(a6),d7	;lf
	bne.s	.go
	addq.l	#1,a6
.cr2:	cmp.b	(a6),d6
	bne.s	.go
	addq.l	#1,a6
.go:	addq.l	#1,CurLNb
	bra	.srch
;	 #] ParseMacArgs:
;	 #[ GetMacArg:
;Input:a3=@field_start
;Output: d1=quote_flag|size, a0=@field_end+1, a3=@field_start
GetMacArg:
	move.l	a3,a0
	cmp.b	#'<',(a0)
	beq.s	quoteMarg
.getc:	move.b	(a0)+,d0
	beq.s	.endlast
	cmp.b	d6,d0	;LF
	beq.s	.endlast
	cmp.b	d7,d0	;CR
	beq.s	.endlast
	cmp.b	d4,d0	;' '
	beq.s	.go_eof
	cmp.b	d5,d0
	beq.s	.go_eof	;'\t'
	cmp.b	#',',d0
	beq.s	.endnxt
	cmp.b	#';',d0
	bne.s	.getc
.endlast: subq.w	#1,a0	;rester sur le caractere de fin
	move.l	a0,d1
	sub.l	a3,d1
	rts
.endnxt:	move.l	a0,d1	;passer au champ suivant
	sub.l	a3,d1
	subq.w	#1,d1
.out:	rts
	;aller jusqu'au bout du champ
.go_eof:	move.l	a0,d1
	sub.l	a3,d1
	subq.w	#1,d1
.l1:	move.b	(a0)+,d0
	cmp.b	#',',d0
	beq.s	.out
	cmp.b	d4,d0	;' '
	beq.s	.l1
	cmp.b	d5,d0	;TAB
	beq.s	.l1
;<param  truc> -> truc est un commentaire (y'a deja eu un warning)
.go_eol:	move.b	(a0)+,d0
	beq.s	.out1
	cmp.b	d6,d0
	beq.s	.out1
	cmp.b	d7,d0
	bne.s	.go_eol
.out1:	subq.w	#1,a0
	rts

quoteMarg:  ;<par[>>]am>
	addq.l	#1,a3	;skipper '<'
	addq.l	#1,a0
	moveq	#'>',d1
.nxc:	move.b	(a0)+,d0
	beq.s	.err
	cmp.b	d1,d0
	beq.s	.endbrack
	cmp.b	d6,d0	;LF
	beq.s	.err
	cmp.b	d7,d0	;CR
	bne.s	.nxc
;'>' manquant
.err:	bsr	Errmac_enclos
	bra.s	.end
.endbrack:
	cmp.b	(a0)+,d1
	beq.s	.nxc	;on quote ">>"
.end:	subq.w	#2,a0
	move.l	a0,d1
	sub.l	a3,d1
	or.w	#$ff00,d1 ;flag de quote
	addq.w	#1,a0
.go_eof:	move.b	(a0)+,d0	;goto end of field
	beq.s	.out
	cmp.b	#',',d0
	beq.s	.out
	cmp.b	d7,d0	;CR
	beq.s	.out
	cmp.b	d6,d0	;LF
	beq.s	.out
	cmp.b	d4,d0	;' '
	beq.s	.go_eol
	cmp.b	d5,d0
	beq.s	.go_eol
	;garbage derriere le '>' fermant
	bra	Errmac_enclos
.out:	rts
.go_eol:	move.b	(a0)+,d0
	cmp.b	d7,d0
	bhi.s	.go_eol
	beq.s	.out_eol
	cmp.b	d6,d0
	beq.s	.out_eol
	tst.b	d0
	bne.s	.go_eol
.out_eol: subq.w	#1,a0
	rts
;	 #] GetMacArg:
;	 #[ Alloc & Free:
AllocMacLine:
	movem.l	a0/a1,-(sp)
	move.l	MacBufCur(a5),d0
	move.l	d0,a0
	beq.s	.alloc
.got:	addq.w	#1,MACBUF_nb(a0)
	cmp.w	#10,MACBUF_nb(a0)
	bgt.s	.next
	move.l	MACBUF_cur(a0),d0
	add.l	#256,MACBUF_cur(a0)
	movem.l	(sp)+,a0/a1
	rts

.next:	subq.w	#1,MACBUF_nb(a0)
.alloc:	move.l	a0,a1
	move.l	#256*10+MACBUF_SIZEOF,d0
	jsr	MyMalloc
	beq	Errmac_ram
	move.l	d0,a0
	clr.l	MACBUF_next(a0)
	clr.w	MACBUF_nb(a0)
	add.l	#MACBUF_SIZEOF,d0
	move.l	d0,MACBUF_cur(a0)
	move.l	a0,MacBufCur(a5)
	move.l	a1,MACBUF_prev(a0)
	beq.s	.got
	move.l	a0,MACBUF_next(a1)
	bra.s	.got

;In:
;a5=mac stuff
FreeMacLine:
	move.l	a1,-(sp)
	IFNE	BLINDOS
	tst.l	MacBufCur(a5)
	beq.s	.err
	ENDC
	move.l	MacBufCur(a5),a0
	sub.l	#256,MACBUF_cur(a0)
	subq.w	#1,MACBUF_nb(a0)
	bmi.s	.back
.end:	move.l	(sp)+,a1
	rts
.back:	move.l	MACBUF_prev(a0),MacBufCur(a5)
	IFNE	BLINDOS
	beq.s	.err
	ENDC
	jsr	MyMfree
	bra.s	.end
	IFNE	BLINDOS
.err:	_Debugger
	ENDC

;1 struct/macro declaree
;In: a5=@MacStuff
AllocMacro:
	movem.l	d1/a0/a1,-(sp)
	moveq	#MAC_SIZEOF,d1
	move.l	MacMemCur(a5),d0
	move.l	d0,a0
	beq.s	.alloc
.got:	move.l	MEMBLOCK_cur(a0),a1
	add.l	d1,a1
	cmp.l	MEMBLOCK_end(a0),a1
	bhi.s	.alloc
	addq.l	#1,TotMacNb
	move.l	MEMBLOCK_cur(a0),d0
	add.l	d1,MEMBLOCK_cur(a0)
.end:	movem.l	(sp)+,d1/a0/a1
	rts
.alloc:	move.l	a0,a1
	move.l	#MAC_SIZEOF*10+MEMBLOCK_SIZEOF,d0
	jsr	MyMalloc
	move.l	d0,MacMemCur(a5)
	beq.s	.end
	move.l	d0,a0
	move.l	a1,d0	;prev
	beq.s	.fst
	move.l	a0,MEMBLOCK_next(a1)	;link
.l1:	lea	MEMBLOCK_SIZEOF(a0),a1
	move.l	a1,MEMBLOCK_cur(a0)
	add.l	d1,a1
	move.l	a1,MEMBLOCK_end(a0)
	clr.l	MEMBLOCK_next(a0)
	bra.s	.got
.fst:	move.l	a0,MacMemHead(a5)
	bra.s	.l1

FreeMacros:
	movem.l	d0-d1/a0/a5,-(sp)
	lea	MacStuff,a5
	move.l	MacMemHead(a5),d1
	beq.s	.l1
.nx:	move.l	d1,a0
	tst.w	SlowFlg
	beq.s	.free
	bsr.s	.freetxt
.free:	move.l	MEMBLOCK_next(a0),d1
	jsr	MyMfree
	tst.l	d1
	bne.s	.nx
.l1:	move.l	MacMemCtxtCur(a5),d1
	beq.s	.end
.nx2:	move.l	d1,a0
	move.l	MEMBLOCK_prev(a0),d1
	jsr	MyMfree
	tst.l	d1
	bne.s	.nx2
.end:	movem.l	(sp)+,d0-d1/a0/a5
	rts
;en mode slow, on free le texte des macros
.freetxt: movem.l	a0/a2,-(sp)
	move.l	a0,a2
	lea	MEMBLOCK_SIZEOF(a0),a1
.nxtxt:	move.l	MAC_srcstart(a1),a0
	jsr	MyMfree
	lea	MAC_SIZEOF(a1),a1
	cmp.l	MEMBLOCK_cur(a2),a1
	bne.s	.nxtxt
	movem.l	(sp)+,a0/a2
	rts

;In: d0=size (struct + params)
;Out: d0=@struct MACCTXT
;on utilise la struct MEMBLOCK avec MEMBLOCK_prev
AllocMacCtxt:
	movem.l	d1/a1,-(sp)
	move.l	d0,d1
	move.l	MacMemCtxtCur(a5),d0
	move.l	d0,a0
	beq.s	._alloc
.got:	move.l	MEMBLOCK_cur(a0),a1
	add.l	d1,a1
	cmp.l	MEMBLOCK_end(a0),a1
	bhi.s	.alloc
	move.l	MEMBLOCK_cur(a0),d0
	addq.w	#1,MEMBLOCK_nb(a0)
	add.l	d1,MEMBLOCK_cur(a0)
.end:	movem.l	(sp)+,d1/a1
	rts
.alloc:	move.l	a0,a1
	move.l	MEMBLOCK_next(a0),d0
	bne.s	.next
._alloc:	move.l	a0,a1
	move.l	#MACCTXT_BLK_SIZE+MEMBLOCK_SIZEOF,d0
	jsr	MyMalloc
	beq.s	.end
	move.l	d0,a0
	clr.l	MEMBLOCK_next(a0)
.next:	move.l	d0,a0
	move.l	a1,MEMBLOCK_prev(a0)
	move.l	a1,d0
	beq.s	.l1
	move.l	a0,MEMBLOCK_next(a1)
.l1:	lea	MEMBLOCK_SIZEOF(a0),a1
	move.l	a1,MEMBLOCK_cur(a0)
	lea	MACCTXT_BLK_SIZE(a1),a1
	move.l	a1,MEMBLOCK_end(a0)
	clr.w	MEMBLOCK_nb(a0)
	move.l	a0,MacMemCtxtCur(a5)
	bra.s	.got

;In:
;a0=MacStackPtr courant
;a5=Macro Stuff
;garde le 1er block pour reutilisation
FreeMacCtxt:
	movem.l	d1/d2,-(sp)
	move.l	a0,d1
	move.l	MacMemCtxtCur(a5),a0
	subq.w	#1,MEMBLOCK_nb(a0)
	beq.s	.down
.end:	move.l	d1,MEMBLOCK_cur(a0)
	movem.l	(sp)+,d1/d2
	rts
.down:	move.l	MEMBLOCK_prev(a0),d2
	beq.s	.end
.free:	jsr	MyMfree
	move.l	d2,MacMemCtxtCur(a5)
	move.l	d2,d1
	move.l	d1,a0
	add.l	#MEMBLOCK_SIZEOF,d1
;en memoire non systeme, garder le bloc pour reutilisation
	tst.w	SMemFlg
	beq.s	.end
	clr.l	MEMBLOCK_next(a0)
	bra.s	.end
;	 #] Alloc & Free:
;	 #[ ExpandMacLine:
;In: a0=src line,a1=@buffer d'expansion
;Internal: d3=initial a1
ExpandMacLine:
	lea	MacStuff,a5
	move.l	MacCurExpPtr(a5),a0
	move.l	MacCurBufPtr(a5),a1
	moveq	#'\',d2
	moveq	#10,d4
	moveq	#13,d5
	move.l	a1,d3
	move.w	#$0d0a,(a1)+	;pour Reset_CurLine
.getc:	move.b	(a0)+,d0
	beq.s	.eof
	cmp.b	#';',d0
	beq.s	.comment
	cmp.b	d0,d2
	bne.s	.copy
	move.b	(a0)+,d0
	cmp.b	d0,d2
	bne.s	.exp
	move.b	d0,(a1)+	;quote '\'
	bra.s	.getc
.comment: cmp.b	(a0),d0
	bne.s	.copy
	bra	.skip2eol
.eof:	bsr	End_of_include
	move.l	a6,a0
	bra.s	.getc
.exp:	cmp.b	#'@',d0
	bne.s	.not_arobace
	bsr	ExpMCount
	bra.s	.getc
.not_arobace:
	cmp.b	#'<',d0
	bne.s	.not_sup
	bsr	ExpSymbol
	bra.s	.getc
.not_sup: cmp.b	#'#',d0
	bne.s	.nodiese
	bsr	ExpNARG
	bra.s	.getc
.nodiese:	cmp.b	#'?',d0
	bne.s	.no?
	bsr	ExpPrmSize
	bra.s	.getc
.no?:	cmp.b	#':',d0
	bne.s	.noname
	bsr	ExpMName
	bra.s	.getc
.noname:	bsr	ExpandMacParam
	bra.s	.getc
.copy:	move.b	d0,(a1)+
	cmp.b	d4,d0
	beq.s	.lf
	cmp.b	d5,d0
	bne.s	.getc
	cmp.b	(a0),d4	;.cr
	bne.s	.end
	move.b	(a0)+,(a1)+
	bra.s	.end
.lf:	cmp.b	(a0),d5
	bne.s	.end
	move.b	(a0)+,(a1)+
.end:	move.l	a1,d0
	sub.l	d3,d0
	move.w	d0,MacLineSize(a5)
	move.b	#' ',(a1)
	move.l	a0,MacCurExpPtr(a5)
	move.l	MacCurBufPtr(a5),a6
	addq.w	#2,a6
	move.l	a6,CurLPtr
	rts
.go_eol:	move.b	(a0)+,d0
	beq.s	.put_end
	cmp.b	d4,d0
	beq.s	.put_end
	cmp.b	d5,d0
	beq.s	.put_end
	move.b	d0,(a1)+
	bra.s	.go_eol
.put_end: move.b	d5,(a1)+
	move.b	d4,(a1)+
;	clr.b	(a1)+
	bra.s	.end
.skip2eol:
	move.b	(a0)+,d0
	beq.s	.put_end
	cmp.b	d5,d0
	beq.s	.put_end
	cmp.b	d4,d0
	beq.s	.put_end
	bra.s	.skip2eol

;	 #[ Misc expansions:
;\?n -> taille du param. n, opsize pour \?0
ExpPrmSize:
	movem.l	a2/a3,-(sp)
	move.b	(a0)+,d0
	cmp.b	#'0',d0
	beq.s	.opsize
	move.l	a1,a2
	bsr	ExpandMacParam
	move.l	a0,a3
	move.l	a1,d0
	sub.l	a2,d0
	move.l	a2,a1
	move.l	d0,-(sp)
	move.l	a1,a0
	lea	dec_form(pc),a1
	jsr	Sprintf
	addq.w	#4,sp
	move.l	a3,a0
	lea	0(a2,d0.w),a1
.end:	movem.l	(sp)+,a2/a3
	rts
.opsize:	move.l	MacStackPtr(a5),a2
	lea	MACCTXT_SIZEOF(a2),a2
	move.b	1(a2),d0
	beq.s	.nothing
.sizeset:	lea	.sztab-2(pc),a2
	moveq	#6-1,d1
.tst:	addq.l	#2,a2
	cmp.b	(a2),d0
	dbeq	d1,.tst
	bne.s	.nothing
	move.b	1(a2),(a1)+
	bra.s	.end
.nothing:	move.b	#'0',(a1)+
	bra.s	.end
.sztab:	dc.b	'B','1','S','1','W','2','L','3','D','4','X','5','P','6'

;\@ -> uniq label
ExpMCount:
	st	MacAroUsedFlg(a5)
	move.l	a0,-(sp)
	move.l	a1,a0
	move.b	#'_',(a0)+

	move.l	LocMacAroCnt(a5),d0
	cmp.l	#999,d0
	bhi.s	.bigger
	move.w	MacAroDigit,-(sp)
	move.l	sp,d1
	move.l	d0,-(sp)
	lea	.fix_txt(pc),a1
	jsr	Sprintf
	addq.w	#6,sp
	bra.s	.end
.bigger:	move.l	d0,-(sp)
	lea	dec_form(pc),a1
	jsr	Sprintf
	addq.w	#4,sp
.end:	lea	0(a0,d0.w),a1
	move.l	(sp)+,a0
	rts
.fix_txt: dc.b	"%0*ld",0
	even

ExpSymbol:	;d4-d5 = cr-lf
	movem.l	d3/a2-a3,-(sp)
	move.b	(a0),d1
	cmp.b	#'$',d1
	seq	d3
	ext.w	d3
	sub.w	d3,a0
	bsr.s	GetMacSym
	bne.s	.end
	move.l	a0,a3
	tst.l	d0
	bpl.s	.plus
	neg.l	d0
	move.b	#'-',(a1)+
.plus:	move.l	a1,a2
	move.l	a1,a0
	lea	dec_form(pc),a1
	tst.b	d3
	beq.s	.push
	lea	hex_form(pc),a1
.push:	move.l	d0,-(sp)
	jsr	Sprintf
	addq.w	#4,sp
	lea	0(a2,d0.w),a1
	move.l	a3,a0
.end:	movem.l	(sp)+,d3/a2-a3
	rts

;In: a0=@ascii apres '<[$]'
;Out: d0=valeur du symbole - !Z=erreur
GetMacSym:
	movem.l	d2-d3/a1-a3,-(sp)
	moveq	#'>',d1
	move.l	a0,a3
.nxc:	move.b	(a0)+,d2
	beq.s	.unxpend
	cmp.b	d1,d2
	beq.s	.end_sym
	cmp.b	d4,d2		;lf
	beq.s	.unxpend
	cmp.b	d5,d2		;cr
	bne.s	.nxc
.end_sym:	move.l	a0,d0
	sub.l	a3,d0
	subq.w	#1,d0
	move.l	a0,a2
	move.l	a3,a0
	lea	-VAR_SIZEOF(sp),sp
	move.l	sp,a1
	jsr	GetEquate
	movem.l	(sp),d0
	lea	VAR_SIZEOF(sp),sp
	beq.s	.eqnf
	move.l	a2,a0
	moveq	#0,d1
.end:	movem.l	(sp)+,d2-d3/a1-a3
	rts
.unxpend: bsr	Errmac_unbal_sup
	moveq	#-1,d0
	bra.s	.end
.eqnf:	bsr	Errmac_eqnf
	moveq	#-1,d0
	bra.s	.end

;\# -> nbre de parametres macro
ExpNARG:	movem.l	a0/a2,-(sp)
	move.l	a1,a2
	move.w	MacNbArgs(a5),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	a1,a0
	lea	dec_form(pc),a1
	jsr	Sprintf
	addq.w	#4,sp
	move.l	a2,a0
	STRLEN
	lea	0(a2,d0.w),a1
	movem.l	(sp)+,a0/a2
	rts

;\: -> macro name
ExpMName:	movem.l	a0/a2,-(sp)
	move.l	MacCurPtr(a5),a2
	move.l	VAR_start(a2),a0
	move.w	VAR_len(a2),d0
	STRNCPY
	movem.l	(sp)+,a0/a2
	rts
;	 #] Misc expansions:
;	 #] ExpandMacLine:
;	 #[ ExpandMacParam:
;\0-9, \a-z, \A-Z, \~<equate>
ExpandMacParam:
	moveq	#10,d1
	cmp.b	#'`',d0
	beq.s	.bckq
	sub.b	#'0',d0
	beq.s	ExpN
	bpl.s	.nosize
.error:	bra	Errmac_inv_par
.nosize:	cmp.b	d1,d0
	blo.s	ExpN
	sub.b	#'A'-'0',d0
	bmi.s	.error
	cmp.b	#'Z'-'A',d0
	bhi.s	.test_az
	add.b	d1,d0
	bra.s	ExpN
.test_az: sub.b	#'a'-'A',d0
	bmi.s	.error
	cmp.b	#'z'-'a',d0
	bhi.s	.error
	add.b	d1,d0
	bra.s	ExpN
.end:	rts

.bckq:	cmp.b	#'<',(a0)+
	bne.s	.badparm
	bsr	GetMacSym
	bne.s	.end
	cmp.l	#MAX_MAC_ARGS,d0
	bhi.s	.badparm
	bsr	ExpN
	bra.s	.end

.badparm:	bsr	Errmac_inv_par
	bra.s	.end

;expande l'argument d0.b
ExpN:	movem.l	d2/a2-a3,-(sp)
	move.l	MacStackPtr(a5),a2
	lea	MACCTXT_SIZEOF(a2),a2
	ext.w	d0
	bne.s	.nosize
	;opsize
	move.w	(a2),d0
	move.b	d0,(a1)+
	bne.s	.end
	move.b	#'W',-1(a1)
	bra.s	.end
.nosize:	move.w	MacNbArgs(a5),d1
	sub.w	MacShift(a5),d1
	cmp.w	d1,d0
	bhi.s	.argnf
	add.w	MacShift(a5),d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d0,d1	;n*6
	move.l	2(a2,d1.w),a3	;@param string (in src)
	move.w	0(a2,d1.w),d0	;quote_flg | size
	bmi.s	.quoted
	subq.w	#1,d0
	bmi.s	.end
.cp:	move.b	(a3)+,(a1)+
	dbf	d0,.cp
.end:	moveq	#0,d0
._end:	movem.l	(sp)+,d2/a2-a3
	rts
.argnf:	moveq	#-1,d0
	bra.s	._end
.quoted:	ext.w	d0
	subq.w	#1,d0
	bmi.s	.end
	moveq	#'>',d2
.cmp:	move.b	(a3)+,d1
	cmp.b	d2,d1
	beq.s	.skipbrack
.put:	move.b	d1,(a1)+
	dbf	d0,.cmp
	bra.s	.end
.skipbrack:
	cmp.b	(a3)+,d1
	dbne	d0,.put
	; -- ne devrait pas arriver --
	IFNE	BLINDOS
	_Debugger
	ENDC
	subq.w	#1,a3
	dbf	d0,.cmp
	bra.s	.end
;	 #] ExpandMacParam:
;	 #[ Format Strings:
dec_form: dc.b	"%=ld",0
hex_form: dc.b	"%=lx",0
;	 #] Format Strings:
;  #] Macro Stuff:
;  #[ Misc Stuff:
;	 #[ alloc_xef_block:
alloc_xef_block:
	move.l	#VARL_SIZEOF+XREFS_PER_BLOCK*4,d0	;1 long/xref
	jsr	MyMalloc
	beq.s	.rmem
	move.l	d0,a1
	clr.l	VARL_next(a1)
	clr.w	VARL_nb(a1)
	moveq	#VARL_SIZEOF,d1
	add.l	d1,d0
	move.l	d0,VARL_block(a1)
	move.l	a1,d0
	rts
.rmem:	jmp	Errxreft_ram
;	 #] alloc_xef_block:
;	 #[ OPT:	.+,@#,b+,c+,d+,e+,ip,l012+,m+,n+,o=,o#,ow+,p=,r+,s+,t#,u+,v+,w+,x+,y+
__opt:	subq.w	#1,d3
	bmi.s	.roper
.l1:	move.l	FIELDPTR,a0		;@ 1st field
	moveq	#1,d0			;not in cmd line
	bsr.s	GetOpt
	bmi.s	.err
	tst.b	IncBuf
	bne.s	.incl		;opt i
.tst:	tst.b	(a0)		;TOKENEOL
	bpl.s	.reoo
	INCFIELD
	dbf	d3,.l1
	rts
.roper:	bra	Erroper_exp
.err:	bra	preperror
.reoo:	bra	Erreoo_exp
.incl:	move.l	a0,-(sp)
	lea	IncBuf,a2
	move.l	a2,a0
	bsr	AddPath
	clr.b	(a2)
	move.l	(sp)+,a0
	bra.s	.tst
;In:	a0=@ opt
;Out:	a0=@ end opt
GetOpt:	move.w	d0,d2			;in cmd line flg
	moveq	#0,d0
	move.b	(a0)+,d0
	bmi.s	.rinp
	sub.b	#' ',d0
	bmi.s	.rinp
	add.w	d0,d0
	move.w	.tab(pc,d0.w),d0
	jmp	.tab(pc,d0.w)
.rinp:	moveq	#cant_input_errno,d0
	rts
.tab:	dc.w	.rinp-.tab,.rinp-.tab,.rinp-.tab,.rinp-.tab ; !"#
	dc.w	.rinp-.tab,.rinp-.tab,.rinp-.tab,.rinp-.tab ;$%&'
	dc.w	.rinp-.tab,.rinp-.tab,.rinp-.tab,.rinp-.tab ;()*+
	dc.w	.rinp-.tab,.rinp-.tab,.rinp-.tab,.rinp-.tab ;,-./
	dc.w	.rinp-.tab,.rinp-.tab,.rinp-.tab,.rinp-.tab ;0123
	dc.w	.rinp-.tab,.rinp-.tab,.rinp-.tab,.rinp-.tab ;4567
	dc.w	.rinp-.tab,.rinp-.tab,.rinp-.tab,.rinp-.tab ;89:;
	dc.w	.rinp-.tab,.rinp-.tab,.rinp-.tab,.rinp-.tab ;<=>?
	dc.w	.arob-.tab,.rinp-.tab,.save-.tab,.case-.tab ;@ABC
	dc.w	.ddri-.tab,.equa-.tab,.cfly-.tab,.glob-.tab ;DEFG
	dc.w	.rinp-.tab,.incl-.tab,.rinp-.tab,.rinp-.tab ;HIJK
	dc.w	.link-.tab,.mlst-.tab,.slow-.tab,OpOpt-.tab ;LMNO
	dc.w	OpMCU-.tab,.rinp-.tab,.rmem-.tab,.lsym-.tab ;PQRS
	dc.w	.tabs-.tab,.user-.tab,.verb-.tab,.warn-.tab ;TUVW
	dc.w	.dext-.tab,.dsrc-.tab,.rinp-.tab,.rinp-.tab ;XYZ[
	dc.w	.rinp-.tab,.rinp-.tab,.rinp-.tab,.rinp-.tab ;\]^_
	dc.w	.rinp-.tab,.rinp-.tab,.save-.tab,.case-.tab ;`abc
	dc.w	.ddri-.tab,.equa-.tab,.cfly-.tab,.glob-.tab ;defg
	dc.w	.rinp-.tab,.incl-.tab,.rinp-.tab,.rinp-.tab ;hijk
	dc.w	.link-.tab,.mlst-.tab,.slow-.tab,OpOpt-.tab ;lmno
	dc.w	OpMCU-.tab,.rinp-.tab,.rmem-.tab,.lsym-.tab ;pqrs
	dc.w	.tabs-.tab,.user-.tab,.verb-.tab,.warn-.tab ;tuvw
	dc.w	.dext-.tab,.dsrc-.tab,.rinp-.tab,.rinp-.tab ;xyz{
	dc.w	.rinp-.tab,.rinp-.tab,.rinp-.tab,.rinp-.tab ;|}~

.tabs:	lea	LstTabs,a1
	bra.s	.digit
.arob:	lea	MacAroDigit,a1
.digit:	moveq	#0,d0
	move.b	(a0)+,d0
	sub.b	#'0',d0
	ble.s	.rinp2
	cmp.b	#9,d0
	bgt.s	.rinp2
	move.w	d0,(a1)
	moveq	#0,d0
	rts

.link:	moveq	#0,d0
	move.b	(a0)+,d0
	IFNE	ATARI
	bmi.s	.rinp2
	cmp.b	#'-',d0
	beq.s	.prg
	cmp.b	#'+',d0
	beq	.rimp
	sub.w	#'0',d0
	bmi.s	.rinp2
	cmp.w	#BSD_OBJ,d0
	ble.s	.setlnk
	ENDC	;ATARI
	IFNE	AMIGA
	bmi.s	.dolnk
	cmp.b	#'-',d0
	beq.s	.prg
	cmp.b	#'+',d0
	bne.s	.rinp2
.dolnk:	moveq	#DRI_OBJ,d0
	bra.s	.setlnk
	ENDC	;AMIGA
.rinp2:	moveq	#cant_input_errno,d0
	rts
.prg:	moveq	#PRG_OBJ,d0
.setlnk:	cmp.w	OutType+2,d0
	beq.s	.good
	tst.l	FstBinPtr 		;already bin?
	bne.s	.rlnk
	move.l	XdefNb,d1 		;already xdef?
	add.l	XrefNb,d1 		;already xref?
	bne.s	.rlnk
	move.w	d0,OutType+2
	tst.b	d2
	beq.s	.lncmd
	move.l	OutTypePtr,a1
	move.l	d0,VAR_value(a1)
.lncmd:	jsr	InitOutName
.good:	moveq	#0,d0
	rts
.rlnk:	move	#link_misp_errno,d0
	rts

.incl:	cmp.b	#'=',(a0)
	bne.s	.incl1
	addq.w	#1,a0
.incl1:	lea	IncBuf,a1
	tst.b	(a1)
	beq.s	.cp
.tstinc:	tst.b	(a1)+
	bne.s	.tstinc
	move.b	#',',-1(a1)
.cp:	move.b	(a0)+,(a1)+
	bgt.s	.cp
	clr.b	-1(a1)
	subq.w	#1,a0
	bra.s	.good

.def:	tst.b	d2
	bne.s	.rcmd
	lea	DefBuf,a1 		;format: exp(-1)exp...(00)
.defl1:	tst.b	(a1)+
	bne.s	.defl1
	subq.w	#1,a1
	addq.w	#1,a0
.defl2:	move.b	(a0)+,(a1)+
	bgt.s	.defl2
	clr.b	(a1)
	bra.s	.good

.rimp:	moveq	#not_imp_errno,d0		;o
	rts

.rmem:	tst.b	d2
	bne.s	.rcmd
	lea	SMemFlg,a1
	bsr	OptYesNo
	tst.w	SlowFlg
	beq.s	.good
	tst.w	(a1)			;If slow, cant remove smem
	bne.s	.good
.rcmd:	moveq	#cant_input_errno,d0	;should be opt_forbid_errno
	rts

.slow:	tst.b	d2
	bne.s	.rcmd
	lea	SlowFlg,a1
	bsr	OptYesNo
	move.w	(a1),VarRamFlg		;pb si ienv
	beq.s	.noslow
	move.w	#-1,SMemFlg		;slow->sysmem
.noslow:	move.w	MacStuff+MacNestCnt,d0
	or.w	d0,VarRamFlg
.good2:	moveq	#0,d0
	rts
.ddri:	cmp.b	#'=',(a0)
	beq.s	.def
	lea	DbgType,a1
	bsr	OptYesNo
;	moveq	#0,d0			;unnecessary
	tst.w	(a1)
	beq.s	.pokedbg
	moveq	#DBG_DRI,d0
.pokedbg: move.w	d0,(a1)
	move.l	DbgTypePtr,a1
.pokevar:	tst.w	d2			;prov for cmd line
	beq.s	.good2
	move.l	d0,VAR_value(a1)
	bra.s	.good2
.dext:	lea	DbgType,a1
	bsr	OptYesNo
	moveq	#0,d0
	tst.w	(a1)
	beq.s	.pokedbg
	moveq	#DBG_EXT,d0
	bra.s	.pokedbg
.dsrc:	lea	SrcType,a1
	bsr.s	OptYesNo
	tst.w	(a1)
	move.l	SrcTypePtr,a1		;intentionnel
	beq.s	.pokevar
	moveq	#1,d0
	bra.s	.pokevar
.glob:	lea	GDbgType,a1
	bra.s	OptYesNo
.user:	lea	SuprFlg,a1
	bra.s	OptYesNo
.save:	lea	ChckFlg,a1
	bra.s	OptYesNo
.lsym:	lea	LstSymFlg,a1
	bra.s	OptYesNo
.mlst:	lea	LstMacFlg,a1
	bra.s	OptYesNo
.case:	lea	CaseFlg,a1
	bra.s	OptYesNo
.equa:	lea	EquFFlg,a1
	bra.s	OptYesNo
.verb:	lea	VerbFlg,a1
	bra.s	OptYesNo
.cfly:	lea	CorrFlg,a1
	bra.s	OptYesNo
.warn:	lea	WarnFlg,a1
;	bra.s	OptYesNo

OptYesNo: move.b	(a0)+,d0
	sub.b	#'+',d0
	beq.s	.yes
	subq.b	#'-'-'+',d0
	beq.s	.no
	subq.w	#1,a0
.yes:	move.w	#-1,(a1)
	bra.s	.good
.no:	clr.w	(a1)
.good:	moveq	#0,d0
	rts

;o=,o[#][+]/-,o[w][#][+]/-
OpOpt:	lea	OptiFlags,a1
	moveq	#0,d0
	move.b	(a0)+,d0			;EOO
	bmi.s	.asallon
	cmp.b	#'=',d0
	beq	.output
	cmp.b	#'W',d0
	beq.s	.isw
	cmp.b	#'w',d0
	bne.s	.notw
.isw:	lea	WOptFlags,a1
	move.b	(a0)+,d0
	bmi.s	.asallon

.notw:	cmp.b	#'+',d0			;+
	beq.s	.allon
	cmp.b	#'-',d0			;-
	beq.s	.alloff
	sub.b	#'1',d0
	bmi.s	.rinp
	beq.s	.10
	cmp.b	#9-1,d0
	bhi.s	.rinp
	move.w	d0,d1
.asone:	move.b	(a0)+,d0			;EOO
	bmi.s	.asoneon
	sub.b	#'+',d0			;+
	beq.s	.oneon
	subq.b	#'-'-'+',d0		;-
	beq.s	.oneoff
.rinp:	moveq	#cant_input_errno,d0
	rts

.asallon: subq.w	#1,a0
.allon:	moveq	#-1,d0
.allset:	moveq	#OPTI_NB-1,d1
.l1:	move.w	d0,(a1)+
	dbf	d1,.l1
.good:	moveq	#0,d0
	rts
.alloff:	moveq	#0,d0			;o-
	bra.s	.allset

.asoneon: subq.w	#1,a0
.oneon:	moveq	#-1,d0
.oneset:
	IFNE	_68000
	add.w	d1,d1
	move.w	d0,0(a1,d1.w)
	ELSEIF	;_68000
	move.w	d0,0(a1,d1.w*2)
	ENDC	;_68000
	bra.s	.good
.oneoff:	moveq	#0,d0
	bra.s	.oneset

.10:	moveq	#0,d1
	move.b	(a0)+,d0
	bmi.s	.asoneon			;o1
	cmp.b	#'+',d0
	beq.s	.oneon			;o1+
	cmp.b	#'-',d0
	beq.s	.oneoff			;o1-
	moveq	#10,d1
	sub.b	#'0',d0
	bmi.s	.rinp
	cmp.b	#OPTI_NB-10,d0
	bhi.s	.rinp
	add.w	d0,d1
	bra.s	.asone

.output:	move.l	a0,a1
	MSTRLEN
	clr.b	-1(a0)
	move.l	a1,a0
	bsr	SetOutName
	bra	.good

OpMCU:	move.l	d3,-(sp)
	cmp.b	#'=',(a0)+
	bne	.prnt
	lea	MPUType,a1
	moveq	#0,d0
	moveq	#5,d1			;for bclr
	moveq	#0,d3			;EC,LC flag
	move.b	(a0)+,d0
	cmp.b	#'6',d0			;6+
	beq.s	.pu
	bclr	d1,d0
	cmp.b	#'C',d0			;CPU32
	beq.s	.cpu32
.pu:	cmp.b	#'8',(a0)+		;8
	bne.s	.rinp
	move.b	(a0)+,d0
	cmp.b	#'0',d0			;0|
	beq.s	.mpu
	cmp.b	#'8',d0			;8|
	beq	.cpu
	bclr	d1,d0
	cmp.b	#'E',d0			;E
	bne.s	.rinp
	moveq	#MMU_EC,d3
	move.b	(a0)+,d0
	bclr	d1,d0
	cmp.b	#'C',d0			;C
	bne.s	.rinp
	cmp.b	#'0',(a0)+
	beq.s	.mpu
.rinp:	moveq	#cant_input_errno,d0
	bra	.end
.cpu32:	move.b	(a0)+,d0
	bclr	d1,d0
	cmp.b	#'P',d0
	bne.s	.rinp
	move.b	(a0)+,d0
	bclr	d1,d0
	cmp.b	#'U',d0
	bne.s	.rinp
	cmp.b	#'3',(a0)+
	bne.s	.rinp
	cmp.b	#'2',(a0)+
	bne.s	.rinp
	moveq	#MPU_32,d0
	bra.s	.goodmpu
.mpu:	move.b	(a0)+,d0
	sub.b	#'0',d0			;0-4
	bmi.s	.rinp
	beq.s	.mc0010
	cmp.b	#1,d0
	beq.s	.mc0010
	cmp.b	#4,d0
	bhi.s	.rinp
	addq.b	#1,d0			;for CPU32
.mc0010:	cmp.b	#'0',(a0)+		;0
	bne.s	.rinp			;00-10-20-30-40
	tst.b	d3			;EC
	beq.s	.goodmpu
	cmp.w	#MPU_10,d0		;68EC010 interdit
	beq.s	.rinp
.goodmpu:
	IFNE	_68000
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	move.w	.tab(pc,d1.w),2(a1)
	move.w	.tab+2(pc,d1.w),4(a1)
	ELSEIF
	move.w	.tab(pc,d0.w*4),2(a1)
	move.w	.tab+2(pc,d0.w*4),4(a1)
	ENDC	;_68000
	tst.b	d3			;EC,LC
	beq.s	.poke
	move.w	d3,2(a1)
.poke:	move.w	d0,(a1)
.good:	move.w	#$0200,6(a1)
	tst.b	d2
	beq.s	.nopoke
	move.l	MPUTypePtr,a2
	move.w	(a1)+,VAR_value+2(a2)
	move.l	MMUTypePtr,a2
	move.w	(a1)+,VAR_value+2(a2)
	move.l	FPUTypePtr,a2
	move.w	(a1)+,VAR_value+2(a2)
.nopoke:	moveq	#0,d0
.end:	movem.l	(sp)+,d3
	rts
.cpu:	move.b	(a0)+,d0
	cmp.b	#'8',d0			;8
	beq.s	.fpu
	cmp.b	#'5',d0			;5
	bne	.rinp			;pmmu
	cmp.b	#'1',(a0)+		;1
	bne	.rinp
	move.w	#MMU_51,2(a1)
	bra.s	.good
.fpu:	move.b	(a0)+,d0
	sub.b	#'0',d0			;1
	ble	.rinp			;fpu
	cmp.b	#2,d0			;2
	bhi	.rinp
	move.w	#FPU_81,4(a1)
	bra.s	.good
.tab:	dc.w	MMU_NO,FPU_NO		;68000
	dc.w	MMU_NO,FPU_NO		;68010
	dc.w	MMU_NO,FPU_NO		;CPU32
	dc.w	MMU_NO,FPU_NO		;68020
	dc.w	MMU_30,FPU_NO		;68030
	dc.w	MMU_40,FPU_40		;68040
	dc.w	MMU_60,FPU_60		;68060
.prnt:	subq.w	#1,a0
	jsr	LstClose
	lea	LstName,a1
.l1:	move.b	(a0)+,(a1)+
	bpl.s	.l1
	clr.b	-(a1)
	subq.w	#1,a0			;->EOL
	jsr	LstOpen
	bra.s	.nopoke
;	 #] OPT:
;  #] Misc Stuff:
;  #[ Init & Exit Preproc:
InitPrep: st	SecPokeFlg	;TEXT
	st	IfccStuff+IFccCondValue
	moveq	#0,d0
	move.l	d0,ReptContext
	move.w	d0,ReptNestCnt
	move.w	d0,MacStuff+MacNestCnt
	move.w	d0,PrepSkipCnt
	moveq	#-1,d0
	lea	BinNumbers,a0
	move.w	d0,SEC_text(a0)
	move.w	d0,SEC_data(a0)
	move.w	d0,LstBinNb
	neg.l	d0		;-1->1
	move.l	d0,MacStuff+GloMacAroCnt	;default aro = 1
	move.l	d0,MacStuff+LocMacAroCnt	;default aro = 1
	IFNE	AMIGA
	jsr	InitSections
	ENDC
	rts

ExitPreproc:
	movem.l	d0-a6,-(sp)
	jsr	ExitSections
	bsr	FreeMacros
	tst.b	MacStuff+InMacFlg
	beq.s	.l1
	bsr	Errmac_endm_exp
.l1:	tst.w	ReptNestCnt
	beq.s	.l2
	bsr	Errendr_exp
	bsr.s	.repts
.l2:	tst.w	IFccNestCnt+IfccStuff
	beq.s	.l3
	bsr	Errendc_exp
;free de IFCC/ENDC + macros
.l3:	move.l	IfccStuff+IFccCurBuf,d1
	beq.s	.noifcc
.nx:	move.l	d1,a0
	move.L	IFCCBUF_prev(a0),d1
	jsr	MyMfree
	tst.l	d1
	bne.s	.nx
.noifcc:	move.l	MacStuff+MacBufCur,d0
	beq.s	.macptrs
	move.l	d0,a0
	jsr	MyMfree
.macptrs: move.l	macs_ptr,d1
	beq.s	.src
.nxmac:	move.l	d1,a0
	move.l	VARL_next(a0),d1
	jsr	MyMfree
	tst.l	d1
	bne.s	.nxmac
.src:
;	tst.w	SlowFlg
;	beq.s	.end
;	move.l	CurModPtr,a0
;	move.l	MOD_addr(a0),d0
;	beq.s	.end
;	move.l	d0,a0
;	jsr	MyMfree
.end:	movem.l	(sp)+,d0-a6
	rts

.repts:	move.w	ReptNestCnt,d2
	subq.w	#1,d2
	move.l	ReptContext,a1
.nxrept:	move.l	REPT_backptr(a1),d1
	move.l	a1,a0
	jsr	MyMfree
	move.l	d1,a1
	dbf	d2,.nxrept
	rts

	IFNE	ATARI
ExitSections:
	bsr	doweven
	bsr	end_locals
	move.w	CurSection,d2
	cmp.w	#SEC_off,d2
	beq.s	.update
	lea	SecSizes,a0
	move.l	SecSize,0(a0,d2.w)
.update:	moveq	#SEC_text,d2
	move.w	d2,d0
	bsr	update_bin_sec
	moveq	#SEC_data,d2
	move.w	d2,d0
	bsr	update_bin_sec
.end:	clr.l	SecSize
	rts
	ENDC	;ATARI

;  #] Init & Exit Preproc:
;  #[ Include+Incbin stuff:
InitPaths:
	lea	-PATHSZ(sp),sp
	move.l	sp,a0
	jsr	get_wd
	move.l	sp,a0
	bsr.s	AddPath
.end:	lea	PATHSZ(sp),sp
	rts

;In: a0=@string: path1[,path2]...
AddPathList:
	movem.l	d2-d3/a2,-(sp)
	moveq	#',',d2
	move.l	a0,a2
.l1:	move.b	(a0)+,d0
	beq.s	.put
	cmp.b	d2,d0
	bne.s	.l1
	clr.b	-1(a0)		;++ALB
.put:	exg	a0,a2
	move.b	d0,d3
	bsr.s	AddPath
	bmi.s	.end
	move.l	a2,a0
	tst.b	d3
	bne.s	.l1
	moveq	#0,d0
.end:	movem.l	(sp)+,d2-d3/a2
	rts

;In:a0=@chemin complet
;renvoie d0<0 si erreur (mem)
AddPath:	move.l	a2,-(sp)
	move.l	a0,a2
	STRLEN
	add.l	#PATH_SIZEOF+2,d0
	jsr	AllocString
	tst.l	d0
	beq.s	.err
	addq.l	#1,d0		;++ALB
	bclr	#0,d0
	move.l	d0,a1
	clr.l	PATH_next(a1)	;next
	move.l	PathList,d0
	bne.s	.notlst
	move.l	a1,PathList
	bra.s	.cp
.notlst:	move.l	d0,a0
	move.l	(a0),d0
	bne.s	.notlst
	move.l	a1,(a0)
.cp:	lea	PATH_str(a1),a1
	move.l	a2,a0
	move.l	a1,a2
	STRCPY
	move.l	a2,a0
	bsr	ChkPath
	moveq	#0,d0
.end:	move.l	(sp)+,a2
	rts
.err:	moveq	#-1,d0
	bra.s	.end

;In:a0=path @
ChkPath:
.l1:	tst.b	(a0)+
	bne.s	.l1
	cmp.b	#DIRSEP,-2(a0)
	beq.s	.end
	IFNE	AMIGA
	cmp.b	#':',-2(a0)
	beq.s	.end
	ENDC
	move.b	#DIRSEP,-1(a0)
	clr.b	(a0)
.end:	rts

;a1=@MOD courant,a5=@MacStuff
;Out: d1=old MOD_curoffs
unload_src:
	move.w	d2,-(sp)
	move.l	a6,d0
	move.w	MacNestCnt(a5),d2
	subq.w	#1,d2
	bmi.s	.nomac
	;remonte au niveau 0 des appels macro
	;(il faudrait voir le cas de modules differents)
	move.l	MacStackPtr(a5),a0
	moveq	#MACCTXT_SIZEOF,d0
.prev:	move.l	(a0),a0
	add.w	d0,a0
	dbf	d2,.prev
	move.l	MACCTXT_backsrc-MACCTXT_SIZEOF(a0),d0
	;
.nomac:	move.l	MOD_curoffs(a1),d1
	tst.l	MOD_headed(a1)	;si le src est dans EDIT...
	bne.s	.nofree		;alors pas freer et laisser
	sub.l	SrcCurStart,d0	;MOD_curoffs a 0
	add.l	d0,MOD_curoffs(a1)
	move.l	MOD_addr(a1),a0
	jsr	MyMfree
	clr.l	MOD_addr(a1)
.nofree:	move.w	(sp)+,d2
	rts

;appelee par EndAsm,ExpandMacLine,Condition
End_of_include:
	movem.l	d0/a0/a1/a5,-(sp)
	lea	MacStuff,a5
	tst.b	IEnvFlg
	beq.s	.nolink
	move.l	CurEditBlock,d0
	beq.s	.nolink
	move.l	d0,a0
	move.l	TXT_next(a0),d0	;pour le moment, doit valoir
	beq.s	.nolink		;0 tout le temps
	move.l	d0,a0
	tst.l	TXT_size(a0)
	beq.s	.nolink
	move.l	TXT_text(a0),a6
	move.l	a0,CurEditBlock
	bra	.end
.nolink:	move.l	CurModPtr,a0
	tst.w	SlowFlg
	beq.s	.nofree
	;; mode slow
	tst.b	InMacFlg(a5)
	beq.s	.nomac
	bsr	.link_mac
	bra.s	.nolocp
.nomac:	bsr	end_locals
.nolocp:	move.l	a0,a1
;	tst.w	SrcType
;	beq.s	.nosrc
;	move.l	a1,-(sp)
;	bsr	EndLinr
;	move.l	(sp)+,a1
.nosrc:	tst.l	MOD_headed(a1)		;si src dans Edit...
	bne.s	.nofree			;alors pas freer
	move.l	MOD_addr(a1),a0
	jsr	MyMfree
	clr.l	MOD_addr(a1)
	move.l	a1,a0
	;;
.nofree:	move.l	MOD_father(a0),d0
	beq	.error
	tst.b	CoringFlg
	bne.s	.endcor
	move.l	d0,a0
	move.l	a0,CurModPtr
	move.l	MOD_cursrc(a0),a6
	move.l	a6,MacStuff+MacCurExpPtr
	move.l	MOD_curlnb(a0),CurLNb
	move.l	MOD_incnum(a0),incnum
	move.l	MOD_num(a0),CurModNb
	move.l	MOD_addr(a0),SrcCurStart
	move.l	MOD_headed(a0),HeadEditBlock
	move.l	MOD_cured(a0),CurEditBlock
	move.l	MOD_orgnam(a0),a0
	clr.w	length_variable
	lea	SrcCurName,a1
	bsr	strcpy2
	tst.w	SlowFlg
	beq.s	.end
	move.l	CurModPtr,a0
	bsr	reload_src
.end:	bsr	UpdVarRamFlg
	moveq	#0,d0
	movem.l	(sp)+,d0/a0/a1/a5
	rts
.endcor:	sf	CoringFlg
	move.l	CorSaveA6,a6
	moveq	#0,d0
	bra.s	.end
.error:	bsr	Errunexp_eosrc
	moveq	#-1,d0
	bra.s	.end
;fin d'include en declaration macro en mode Slow ->linker les bouts
;de source
.link_mac:
	movem.l	a0-a1/d1,-(sp)
	moveq	#12,d0
	jsr	MyMalloc
	beq	Errmac_ram
	move.l	d0,a0
	move.l	CurMacSrcList(a5),d1
	beq.s	.fst
	move.l	d1,a1
	move.l	a0,(a1)
.l1:	clr.l	(a0)	;next
	move.l	MacCurDecl(a5),a1
	move.l	MAC_srcstart(a1),4(a0)
	move.l	a6,8(a0)
	move.l	a0,CurMacSrcList(a5)
	rts
.fst:	move.l	d0,HeadMacSrcList(a5)
	movem.l	(sp)+,a0-a1/d1
	bra.s	.l1

;In: a0=@MOD a recharger
;    a5=@MacStuff
reload_src:
	move.l	a2,-(sp)
	move.l	a0,a2
	tst.l	MOD_headed(a2)	;si module dans Edit...
	bne.s	.end		;alors pas recharger
	move.l	MOD_curoffs(a2),d0
	move.l	MOD_expnam(a2),a0
	move.l	MOD_size(a2),d1
	sub.l	d0,d1
	jsr	LoadSrc
	move.l	a0,MOD_addr(a2)
	move.l	a0,SrcCurStart
	move.l	a0,MacCurExpPtr(a5)
	move.l	a0,a6
.end:	move.l	(sp)+,a2
	rts

;A merger avec FindIncFile
;In: a0=@ orgfname
;Out: d0=@ MOD struct si module present dans Edit
GetIEnvFile:
	movem.l	d2-d7/a2-a4,-(sp)
	lea	-PATHSZ(sp),sp
	move.l	sp,a3
	move.l	a0,a4

;;;;;;;;;;; a virer qd FindIncFile
	cmp.b	#DIRSEP,(a0)
	beq.s	.abspath
	cmp.b	#':',1(a0)
	beq.s	.abspath
	;path relatif -> path absolu
	jsr	get_drive
	add.b	#'A',d0
	move.l	a3,a0
	move.b	d0,(a0)+
	move.b	#':',(a0)+
	jsr	get_path
	move.l	a3,a0
	STRLEN
	lea	0(a3,d0.w),a1
	move.b	#DIRSEP,(a1)+
	move.l	a4,a0
.abspath: bsr.s	File2Upr
;;;;;;;;;;; a virer qd FindIncFile

	move.l	IEnvPtr,a2
	move.l	IENV_mod(a2),d0
	beq.s	.none		;on sait jamais ...
.nx:	move.l	d0,a2
	move.l	a3,a0
	move.l	MOD_expnam(a2),a1
	bsr	strcmp
	bne.s	.next
	move.l	a4,a0		;update orgname
	move.l	MOD_orgnam(a2),a1
	STRCPY
	move.l	a2,d0
	bra.s	.end
.next:	move.l	MOD_nextram(a2),d0
	bne.s	.nx
.none:	moveq	#0,d0
.end:	lea	PATHSZ(sp),sp
	movem.l	(sp)+,d2-d7/a2-a4
	rts

;In:
;a0=src @
;a1=dst @
File2Upr:	move.l	a0,-(sp)
	;tst.b	F2UprFlg
	;
.l1:	move.b	(a0)+,d0
	cmp.b	#'a',d0
	blo.s	.cp
	cmp.b	#'z'+1,d0
	bhs.s	.cp
	sub.b	#'a'-'A',d0
.cp:	move.b	d0,(a1)+
	bne.s	.l1
	move.l	(sp)+,a0
	rts

;In:a0=@nom de fichier present dans le source
;   a1=@buffer pour nom de fichier complet
;Out: d0=0 si trouve,-1 sinon
FindIncFile:
	movem.l	a1-a4,-(sp)
	move.l	a0,a3
	move.l	a1,a4
	jsr	IsAbsFname
	beq.s	.abs
	move.l	PathList,d0
	beq.s	.nf
.tst:	move.l	d0,a2
	lea	PATH_str(a2),a0
	move.l	a4,a1
	STRCPY
	subq.l	#1,a1
	move.l	a3,a0
	bsr	File2Upr
;	STRCPY
	move.l	a4,a0
	jsr	TestFile
	beq.s	.found
	move.l	PATH_next(a2),d0
	bne.s	.tst
.nf:	moveq	#-1,d0
.end:	movem.l	(sp)+,a1-a4
	rts
.found:	moveq	#0,d0
	bra.s	.end
.abs:	jsr	TestFile		;nom en absolu dans le source
	bne.s	.nf
	move.l	a3,a0
	move.l	a4,a1
	STRCPY
	bra.s	.found

__incbin:	lea	-PATHSZ*2(sp),sp
	tst.b	SecPokeFlg
	beq	.rsec
	subq.w	#1,d3
	bmi	.rfile
	move.l	FIELDPTR,a0		;@ 1st field
	move.l	sp,a1
	bsr	get_prep_fname
	move.l	sp,a0
	lea	PATHSZ(sp),a1
	bsr	FindIncFile
	bmi	.rnf
	moveq	#-1,d5			;size
	moveq	#0,d6			;offset
	subq.w	#1,d3
	bmi.s	.noargs
	INCFIELD
	move.l	FIELDPTR,a0
	FEVAL
	bmi	.reval
	move.l	d0,d5			;size
	tst.b	d1
	bne	.rrel
	swap	d1
	tst.b	d1
	beq.s	.plus
	subq.l	#1,d0			;=-1
	bne	.rmin
	moveq	#-1,d5			;all file
.plus:	subq.w	#1,d3
	bmi.s	.noargs
	bgt	.roper
	INCFIELD
	move.l	FIELDPTR,a0
	FEVAL
	bmi	.reval
	move.l	d0,d6			;offset
	tst.b	d1
	bne	.rrel
	swap	d1
	tst.b	d1
	bne	.rmin
.noargs:	lea	PATHSZ(sp),a0
	jsr	GetIncBin
	move.l	a0,a3	;name
	move.l	d0,d3	;size
	ble	.end
	cmp.l	d3,d6
	bhi	.rfoff
	sub.l	d6,d3
	tst.l	d5
	bmi.s	.whole
	cmp.l	d3,d5
	bhi	.rfoff
	move.l	d5,d3
.whole:	move.w	CurSection,d4
	move.l	a3,a0
	STRLEN
	addq.l	#1,d0
	jsr	AllocString
	beq	.rfname
	move.l	d0,a2
	move.l	a3,a0
	move.l	a2,a1
	STRCPY
	jsr	UpdateBinBuffer
	jsr	AllocBin
	move.l	d0,a0
	jsr	BinLink
	IFNE	AMIGA
	move.l	CurSecPtr,a1
	tst.l	SECTION_bin_bl(a1)
	bne.s	.already
	move.l	a0,SECTION_bin_bl(a1)
.already:	ENDC	;AMIGA
	move.w	d4,BIN_sec(a0)
	clr.l	BIN_start(a0)		;start=NULL->INCBIN
	move.l	d3,BIN_size(a0)		;cur=length
	move.l	a2,BIN_name(a0)		;end=name
	move.l	d6,BIN_off(a0)		;offset (-1 if none)
	clr.l	CurBinPtr
	clr.l	FstBinBuffer
	clr.l	BinBuffer
	clr.l	EndBinBuffer
	add.l	d3,SecSize
	cmp.l	IncbinSize,d3
	blt.s	.end
	move.l	d3,IncbinSize
.end:	lea	PATHSZ*2(sp),sp
	rts
.rfile:	bsr	Errfile_exp
	bra.s	.end
.reval:	bsr	ErrEv_immed
	bra.s	.end
.rrel:	bsr	Errrel_forb
	bra.s	.end
.rmin:	bsr	Errmin_forb
	bra.s	.end
.rnf:	bsr	Errincbin_nf
	bra.s	.end
.roper:	bsr	Erroper_2many
	bra.s	.end
.rsec:	bsr	Errdata_in_bss
	bra.s	.end
.rfoff:	bsr	Errfoff_2big
	bra.s	.end
.rfname:	jsr	Errfname_ram
	bra.s	.end

UpdVarRamFlg:
	movem.l	d0/a0,-(sp)
	move.l	CurModPtr,a0
	moveq	#0,d0
	tst.l	MOD_headed(a0)	;sous Edit: vars deja en memoire
	bne.s	.edt
	move.w	SlowFlg,d0
.edt:	tst.w	MacNestCnt+MacStuff	;en macro: toujours recopier les vars
	beq.s	.poke
	moveq	#-1,d0
.poke:	move.w	d0,VarRamFlg
	movem.l	(sp)+,d0/a0
	rts
;  #] Include+Incbin stuff:
;  #[ End Locales:
end_locals:
	movem.l	d0-a6,-(sp)	;tri eventuel des locales
	move.l	LocNb,d0
	beq.s	.nolocal
	jsr	create_locals_table ;cree la table et met a 0 les VARL_nb
	move.l	LocTbl,a0
	move.l	LocNb,d0
	lea	Qs_doubly,a1
	jsr	QsortL
.nolocal: jsr	LocalPatch
	jsr	ResetLocEXPs
	lea	LocNb,a2
	move.l	(a2),d1
	beq.s	.really_no_local
	add.l	d1,TotLocNb
	cmp.l	#1000,d1
	ble.s	.nofree
	move.l	LocTbl,a0
	jsr	MyMfree			;table de locales a freeer
	move.l	CstLocTbl,LocTbl		;remettre table de 1000
.nofree:	clr.l	(a2)
.really_no_local:
	movem.l	(sp)+,d0-a6
	rts
;  #] End Locales:
;  #[ InitOutName:
;sur autre que TOS, gaffe au nom sans extension
;a0=new output name
InitOutName:
	movem.l	d0-d4/a0-a4,-(sp)
	lea	-256(sp),sp
	lea	.prg(pc),a3
	tst.w	OutType+2
	beq.s	.exe
	lea	.o(pc),a3
.exe:	lea	OutName,a1
	lea	SrcOrgName,a0
	moveq	#'.',d1
	moveq	#DIRSEP,d2
	moveq	#':',d3
	tst.b	OutSetFlg
	beq.s	.main
	move.l	a1,a2
	moveq	#0,d0
.l0:	addq.w	#1,d0
	tst.b	(a2)+
	bne.s	.l0
	subq.w	#2,d0	;empty
	bmi.s	.main
	subq.w	#2,a2
	cmp.b	(a2),d2	;DIRSEP
	beq.s	.sep
	cmp.b	(a2),d3	;':'
	beq.s	.sep

	IFNE	ATARI
.l00:	move.b	-(a2),d4
	cmp.b	d1,d4	;'.'
	beq.s	.ext0
	cmp.b	d2,d4	;DIRSEP
	beq.s	.end
	cmp.b	d3,d4	;':'
	dbeq	d0,.l00
	beq.s	.end
	bra.s	.asep

.ext0:	move.l	a2,a4	;point to ".ext"
	move.l	sp,a3
.l01:	move.b	(a4)+,(a3)+
	bne.s	.l01
	move.l	sp,a3
	clr.b	(a2)	;clr '.'
	subq.w	#1,a2	;point to sep
	cmp.b	(a2),d2	;DIRSEP
	beq.s	.sep
	cmp.b	(a2),d3	;':'
	beq.s	.sep
	ENDC	;ATARI

.asep:	move.l	a1,a0
.main:	PSTRCCPY
	lea	-1(a1,d0.w),a0
	move.l	a0,a1
	subq.w	#2,d0
	bmi.s	.clr
.l1:	move.b	-(a0),d4
	cmp.b	d1,d4	;'.'
	beq.s	.ext
	cmp.b	d2,d4	;DIRSEP
	beq.s	.noext
	cmp.b	d3,d4	;':'
	dbeq	d0,.l1
.noext:	move.l	a1,a0
.ext:	move.b	(a3)+,(a0)+
	bne.s	.ext
.clr:	clr.b	(a0)
.end:	lea	256(sp),sp
	movem.l	(sp)+,d0-d4/a0-a4
	rts
.sep:	addq.w	#1,a2	;p:,p:\,u:\ram\
	moveq	#0,d0
.l2:	addq.w	#1,d0
	tst.b	(a0)+
	bne.s	.l2
	subq.w	#2,d0
	bmi.s	.end
	subq.w	#1,a0
.l3:	cmp.b	-(a0),d2	;\myfold\mysource[.s]
	beq.s	.copy
	cmp.b	(a0),d3	;d:mysource[.s]
	dbeq	d0,.l3
	bne.s	.l4
.copy:	addq.w	#1,a0	;mysource
.l4:	move.b	(a0)+,(a2)+
	bne.s	.l4
	bra.s	.asep	;->p:mysource[.s]
.o:	ASCIIZ	".o"
.prg:	
	IFNE	ATARI
	ASCIIZ	".prg"
	ENDC	;ATARI
	IFNE	AMIGA
	ASCIIZ	""
	ENDC	;AMIGA
	even
;  #] InitOutName:
;  #[ SetOutName:
;sur autre que ST, gaffe au nom sans extension
;a0=new output name
SetOutName:
	movem.l	d3-d4,-(sp)
	cmp.b	#'.',(a0)
	beq.s	.dot
	lea	OutName,a1
	bsr	strcpy2
	bra.s	.end
.dot:	move.l	a0,-(sp)
	lea	SrcOrgName,a0
	lea	OutName,a1
	bsr	strcpy2
	lea	-1(a1,d0.w),a1
	move.l	a1,a0
	subq.w	#2,d0
	bmi.s	.end
	moveq	#'.',d1
	moveq	#DIRSEP,d2
	moveq	#':',d3
.l0:	move.b	-(a1),d4
	cmp.b	d1,d4
	beq.s	.ext
	cmp.b	d2,d4
	beq.s	.noext
	cmp.b	d3,d4
	dbeq	d0,.l0
.noext:	move.l	a0,a1
.ext:	move.l	(sp)+,a0
	bsr	strcpy2
.end:	st	OutSetFlg
	movem.l	(sp)+,d3-d4
	rts
;  #] SetOutName:
;  #[ Strcpy2:
strcpy2:	movem.l	a0-a1,-(sp)
	moveq	#0,d0
.l1:	addq.w	#1,d0
	move.b	(a0)+,(a1)+
	bne.s	.l1
	movem.l	(sp)+,a0-a1
	rts
;  #] Strcpy2:
;  #[ Strcmp:
;a0=@str1
;a1=@str2
strcmp:
.l1:	move.b	(a0)+,d0
	beq.s	.end1
	move.b	(a1)+,d1
	beq.s	.end2
	cmp.b	d0,d1
	beq.s	.l1
	rts
.end1:	tst.b	(a1)+
	rts
.end2:	moveq	#-1,d0
	rts
;  #] Strcmp:
;  #[ Msg:
;	 #[ Misc errors:
Errquote_exp:
	move	#quote_exp_errno,d0
	bra.s	preperror
Errfail:
	move	#fail_errno,d0
	bra.s	preperror
Errsec_name:
	move	#sec_name_errno,d0
	bra.s	preperror
Errmin_forb:
	move	#min_forb_errno,d0
	bra.s	preperror
Errreg_equr:
	move	#equr_reg_errno,d0
	bra.s	preperror
Errlocal_forb:
	move	#local_forb_errno,d0
	bra.s	preperror
Errlabel_exp:
	move	#label_exp_errno,d0
	bra.s	preperror
Errstrc_end_unexp:
	move	#strc_end_unexp_errno,d0
	bra.s	preperror
Errrel_forb:
	move	#rel_forb_errno,d0
	bra.s	preperror
Errfpuid_forb:
Errfpuk_forb:
Errfpuprec_forb:
Errfpuround_forb:
	move	#not_imp_errno,d0
	bra.s	preperror
Err_even: move.l	d0,-(sp)
	move.w	#force_even_errno,d0
	bsr.s	preperror
	move.l	(sp)+,d0
	rts
Errorg_in_bss:
Errdata_in_bss:
	move	#data_in_bss_errno,d0
;	bra.s	preperror
;	 #] Misc errors:
;keep tight
;	 #[ preperror:
preperror:
	move.l	a0,-(sp)
;	move.l	a0,d1
;	sub.l	FIELDPTR,d1
;	add.l	LINE_srcstart(FIELDPTR),d1
;	sub.l	CurLPtr,d1
	neg.w	d0
	lea	premsg,a0
	move.w	#MSG_CORR,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	clr.w	MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	move.l	(sp)+,a0
	rts
;	 #] preperror:
;	 #[ ifcc/endcc/rept/endr:
Errunexp_elseif:
	move	#ifcc_else_unexp_errno,d0
	bra.s	preperror
Errgarbage_after_str:			;Erreoo_exp?
	move	#ifcc_garbage_errno,d0
	bra.s	preperror
Errunexp_endc:
	move	#ifcc_endif_unexp_errno,d0
	bra	prepnocor
Errunexp_endr:
	move	#rept_endr_unexp_errno,d0
	bra	prepnocor
Errrept_neg:
	move	#rept_neg_errno,d0
	bra.s	preperror
Errendr_exp:	;pas de correction
	movem.l	a0/a1,-(sp)
	move.l	ReptContext,a1
	lea	premsg,a0
	clr.w	MSG_flags(a0)
	move.w	#-rept_endr_exp_errno,MSG_no(a0)
	move.l	REPT_lnb(a1),MSG_lnb(a0)
	move.l	REPT_mod(a1),MSG_mod(a0)
	move.l	REPT_decladdr(a1),MSG_ln(a0)
	jsr	OutMsg
	movem.l	(sp)+,a0/a1
	rts
Errendc_exp:	;pas de correction
	movem.l	a0/a1,-(sp)
	move.l	IfccStuff+IFccContext,a1
	lea	premsg,a0
	clr.w	MSG_flags(a0)
	move.w	#-ifcc_endif_exp_errno,MSG_no(a0)
	move.l	IFCC_lnb(a1),MSG_lnb(a0)
	move.l	IFCC_mod(a1),MSG_mod(a0)
	move.l	IFCC_srcaddr(a1),MSG_ln(a0)
	jsr	OutMsg
	movem.l	(sp)+,a0/a1
	rts
;	 #] ifcc/endcc/rept/endr:
;	 #[ macros:
Errmac_inv_par:
	move	#mac_inv_par_errno,d0
	bra.s	mac_error
Errmac_enclos:			;par<am> interdit
	move	#mac_enclos_errno,d0
	bra	preperror
Errmac_opcode:
	move	#mac_opcode_errno,d0
	bra	preperror
Errmac_unbal_sup:
	move.w	#mac_sup_unbal_errno,d0
	bra.s	mac_error
Errmac_eqnf:
	move.w	#mac_eqnf_errno,d0
;	bra.s	mac_error
mac_error:	;passe MacCurExpPtr comme ligne courante
	move.l	a0,-(sp)
	lea	premsg,a0
	clr.w	MSG_flags(a0)
	neg.w	d0
	move.w	d0,MSG_no(a0)
	clr.w	MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	MacStuff+MacCurExpPtr,MSG_ln(a0)
	jsr	OutMsg
	move.l	(sp)+,a0
	rts
Errmac_endm_exp:	;pas de correction
	movem.l	a0/a1,-(sp)
	lea	premsg,a0
	clr.w	MSG_flags(a0)
	move.w	#-mac_endm_exp_errno,MSG_no(a0)
	move.l	MacStuff+MacCurDecl,a1
	move.l	MAC_modstart(a1),MSG_mod(a0)
	move.l	MAC_linestart(a1),MSG_lnb(a0)
	move.l	MAC_curline(a1),MSG_ln(a0)
	jsr	OutMsg
	movem.l	(sp)+,a0/a1
	rts
Errmac_2many_decl:
	move	#mac_2many_decl_errno,d0
	bra.s	prepnocor
Errmac_unexp_endm:
	move	#mac_endm_unexp_errno,d0
	bra.s	prepnocor
Err_exitm:
	move	#mac_exitm_unexp_errno,d0
	bra.s	prepnocor
Err_shiftm:
	move	#mac_shiftm_unexp_errno,d0
	bra.s	prepnocor
Errmac_2many_calls: 			;(nested)
	move	#mac_2many_calls_errno,d0
;	bra.s	prepnocor
;	 #] macros:
;keep tight
;	 #[ prepnocor:
prepnocor:
	move.l	a0,-(sp)
	neg.w	d0
	lea	premsg,a0
	clr.w	MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	move.l	(sp)+,a0
	rts
;	 #] prepnocor:
;	 #[ Include errors:
Errunexp_eosrc:
	moveq	#unexp_eosrc_errno,d0
	bra.s	prepnocor
Errfile_exp:
	move	#file_exp_errno,d0
	bra	preperror
Errload_include:
	move	#load_include_errno,d0
	bra	preperror
Errincbin_nf:
	move.w	#open_errno,d0
	bra	prepfatal
Errfoff_2big:
	move.w	#foff_2big_errno,d0
	bra	prepfatal
;	 #] Include errors:
;	 #[ Mem errors:
Errmac_ram:
	move	#macram_errno,d0
	bra.s	prepfatal
Errifcc_ram:
	move	#ifccram_errno,d0
	bra.s	prepfatal
Errstrc_ram:
	move	#varram_errno,d0
	bra.s	prepfatal
Errrept_ram:
	move	#reptram_errno,d0
;	bra.s	prepfatal
;	 #] Mem errors:
;keep tight
;	 #[ prepfatal:
prepfatal:
	neg.w	d0
	lea	premsg,a0
	move.w	#MSG_FATL,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jmp	OutMsg
;	 #] prepfatal:
;	 #[ Warnings:
Warnxref_spur:
	moveq	#xref_spur_warnno,d0
	bra.s	prepwarn
Warnxdef_spur:
	moveq	#xdef_spur_warnno,d0
;	bra.s	prepwarn
;	 #] Warnings:
;keep tight
;	 #[ prepwarn:
prepwarn: neg.w	d0
	lea	premsg,a0
	move.w	#MSG_WARN,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jmp	OutMsg
;	 #] prepwarn:
;  #] Msg:
	BSS
;  #[ Global stuff:
	even
premsg:	ds.b	MSG_SIZEOF
FstTime:	ds.l	1	;compteur de temps d'assemblage
TotTime:	ds.l	1	;temps total
CenTime:	ds.l	1	;centiemes
SecTime:	ds.l	1	;secondes

;les 3 qui suivent doivent imperativement etre consecutifs
incnum:	ds.l	1	;increment de ligne
CurLNb:	ds.l	1	;numero de ligne courant
CurLPtr:	ds.l	1	;ligne courante

PathList:	ds.l	1

;Current Source
SrcCurStart:	ds.l	1	;@
SrcCurName:	ds.b	PATHSZ	;nom du source en cours d'assemblage
SrcOldName:	ds.b	PATHSZ	;sauvegarde du precedent

;Main Source
SrcOrgName:	ds.b	PATHSZ	;nom du premier source a assembler
SrcOrgStart:	ds.l	1	;adresse de debut du source principal
SrcOrgLen:	ds.l	1	;longueur du source principal

;Sections
SecSizes:
TextSize: 	ds.l	1	;TEXT size (=DATA offset)
DataSize: 	ds.l	1	;DATA size (=BSS offset)
BssSize:		ds.l	1	;BSS size
CurOffset:	ds.l	1	;offset section size
OrgSize:		ds.l	1	;reserved
;  #] Global stuff:
;  #[ Preproc stuff:
	even		;must stay even
PrefTbl:
CaseFlg:		ds.w	1	;Labels case sensitive
WarnFlg:		ds.w	1	;Warnings on/off
VerbFlg:		ds.w	1	;Verbose on/off
ChckFlg:		ds.w	1	;Do not create executable
SlowFlg:		ds.w	1	;Low memory
SMemFlg:		ds.w	1	;Use system memory
EquFFlg:		ds.w	1	;Flush equs
CorrFlg:		ds.w	1	;Dynamic correct
SuprFlg:		ds.w	1	;Supervisor allowed
IndeFlg:		ds.w	1	;Indep check
DbgType:		ds.w	1	;None/DRI/Extended/Pure
SrcType:		ds.w	1	;None/Relative/Absolute
MPUType:		ds.w	1	;Main PU Ordre=MPU MMU FPU ID!
MMUType:		ds.w	1	;PMMU
FPUType:		ds.w	1	;FPU
FPUId:		ds.w	1	;FPU Id
FPUcr:		ds.w	1	;FPU FPCR
FPUk:		ds.w	1	;FPU packed conversion k-factor
MacAroDigit:	ds.w	1	;Arobace digits #
OutType:		ds.l	1	;Output format
DefBuf:		ds.b	256	;DEFINE buffer
OutName:		ds.b	PATHSZ	;OUTPUT file name
IncBuf:		ds.b	PATHSZ	;INCDIR buffer
LstSymFlg:	ds.w	1	;LIST symbol table
LstMacFlg:	ds.w	1	;LIST macro
LstIFccFlg:	ds.w	1	;LIST IFcc
LstReptFlg:	ds.w	1	;LIST rept
LstCnt:		ds.w	1	;LIST #/NOLIST
LstTabs:		ds.w	1	;Tab stop value
LstLnLen: 	ds.w	1	;Line length
LstPgLen: 	ds.w	1	;Page length
LstMttl:		ds.b	256	;Page main title
LstSttl:		ds.b	256	;Page sub title
LstName:		ds.b	PATHSZ	;Listing filename
OptiFlags:			;18+2 bytes
OptiBBccFlg:	ds.w	1	;Bcc		->	Bcc.?
OptiZD16Flg:	ds.w	1	;0(An)		->	(An)
OptiLAbs2WFlg	ds.w	1	;$7fff		->	$7fff.w
OptiMv2QFlg:	ds.w	1	;move.l	#1,Dn	->	moveq	#1,Dn
OptiAri2QFlg:	ds.w	1	;add	#1,Xn	->	addq	#1,Xn
OptiFBccFlg:	ds.w	1	;fwd bcc.s	->	warn
OptiNopFlg:	ds.w	1	;illegal Bcc.s	->	NOP
OptiBdFlg:	ds.w	1	;bd		->	bd.w/d8
OptiOdFlg:	ds.w	1	;od		->	od.w
OptiAri2LeaFlg:	ds.w	1	;;;adda.w #d16>8,An ->	lea d16(An),An
OptiLea2QFlg:	ds.w	1	;lea d16<9(An),An	->	ariq #i,An
OptiMvaL2WFlg:	ds.w	1	;movea.l	#1,An	->	movea.w	#1,An
OptiMva2SubFlg:	ds.w	1	;movea.?	#0,An	->	suba.l	An,An
OptiMvZ2ClrFlg:	ds.w	1	;move.w	#0,Dn	->	clr.w	Dn
OptiCmp2TstFlg:	ds.w	1	;cmp	#0,ea	->	tst.w	ea
OptiLsl2AddFlg:	ds.w	1	;lsl	#1,Dn	->	add Dn,Dn
OptiRoxl2AddxFlg:	ds.w	1	;roxl	#1,Dn	->	addx Dn,Dn
OptiLD162LBdFlg:	ds.w	1	;;;d16(An)	->	(bd.l,An)
		ds.w	2	;->20
WOptFlags:			;Warn on opti
WOptBBccFlg:	ds.w	1
WOptZD16Flg:	ds.w	1
WOptLAbs2WFlg	ds.w	1
WOptMv2QFlg:	ds.w	1
WOptAri2QFlg:	ds.w	1
WOptFBccFlg:	ds.w	1
WOptNopFlg:	ds.w	1
WOptBdFlg:	ds.w	1
WOptOdFlg:	ds.w	1
WOptAri2LeaFlg:	ds.w	1
WOptLea2QFlg:	ds.w	1
WOptMvaL2WFlg:	ds.w	1
WOptMva2SubFlg:	ds.w	1
WOptMvZ2ClrFlg:	ds.w	1
WOptCmp2TstFlg:	ds.w	1
WOptLsl2AddFlg:	ds.w	1
WOptRoxl2AddxFlg:	ds.w	1
WOptLD162LBdFlg:	ds.w	1
		ds.w	2	;->20

;	internal flags
	even
PrepSkipCnt:	ds.w	1	;IF #
GDbgType: 	ds.w	1	;Output global symbols
VarRamFlg:	ds.w	1	;Copy vars to memory
OutSetFlg:	ds.b	1	;Output name is manually set
CoringFlg:	ds.b	1	;on bosse sur le buffer de correction
SecPokeFlg:	ds.b	1	;allowed data flag
LstPgFlg: 	ds.b	1	;Paging on/off
StopFlg:		ds.b	1	;abort assembly
	even
TotLNb:		ds.l	1	;nombre total de lignes
OptiNb:		ds.l	1	;nb d'optimisations
OptiSz:		ds.l	1	;taille economisee
;	Macros
	even
MacStuff: 	ds.b	MAC_STUFF_SIZEOF
MacNb:		ds.l	1
TotMacNb: 	ds.l	1
;	Rept
ReptContext:	ds.l	1
ReptNestCnt:	ds.w	1
;	IFcc-Elseif-endc
IfccStuff:	ds.b	IFCC_STUFF_SIZEOF
EndcCnt:		ds.w	1
;	Sections
CurSection:	ds.w	1
CurSecType:	ds.w	1
SecSize:		ds.l	1	;current section size
;	Equates
DbgTypePtr:	ds.l	1	;__DBG
SrcTypePtr:	ds.l	1	;__SRC
FPUTypePtr:	ds.l	1	;__FPU
MMUTypePtr:	ds.l	1	;__MMU
MPUTypePtr:	ds.l	1	;__MPU
OutTypePtr:	ds.l	1	;__LK
RsCountPtr:	ds.l	1	;__RS
;FilePtr: 	ds.l	1	;__FILE
StrcName:		ds.w	1
 	ds.b	256	;struct name
;	Listing
LstHand:		ds.l	1	;File handle (NULL=screen)
LstLnNb:		ds.l	1	;Line #
LstPgNb:		ds.l	1	;Page #
;	Correct
CorSaveA6:	ds.l	1	;le src derriere la ligne d'erreur
	even
;  #] Preproc stuff:
	section TEXT

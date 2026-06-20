	include	"comequ.s"
	IFNE	AMIGA
	include	"amig_equ.s"
	ENDC

	XDEF	StoreEXP,ResetLocEXPs,FreeEXPs,SetEXPErr,SprintDisp,BsdCreateOffsets
	XDEF	HeadExp,CurGloExp,TotExpNb,LocRelNb,BsdOffsets
	XDEF	GlobalPatch,LocalPatch
	XDEF	GlobPatchFlag,LocPatchFlag

	XREF	MyMalloc,MyMfree,GloEval,LocEval,AllocString,AllocLocString
	XREF	LoadSrc,OutMsg,Sprintf

	XREF	SrcCurStart,SrcCurName,CurLNb,CurModPtr,CurLPtr,CurSection
	XREF	FstBinPtr,CurBinNb,FstBinBuffer,BinBuffer,SecSize,GloTbl
	XREF	FstModPtr,CurModNb,MacStuff,SlowFlg,LocStrMemHead
	XREF	OutType,StopFlg,UsrTxt
	XREF	OptiNb,OptiNopFlg,OptiFBccFlg,WOptNopFlg,WOptFBccFlg
	XREF	TextSize,DataSize

	IFNE	AMIGA
	XREF	TabSecs,CurSecPtr
	ENDC
XREFS_PER_LBLOCK	EQU	100
;  #[ A faire:
;patch errors plus precises
;  #] A faire:
;  #[ StoreEXP:
;In:
;d0.l=@ liste locales si type=3
;LO(d1.L)=flag_evalone | expr type (1,2,3)
;HI(d1.L)=expr size
;d2.w=patch type
;a0.l=expr @ (token) - inutilise -
;a1.l=expr @ (source)
StoreEXP:	subq.b	#EVAL_LOC,d1
	bpl	StoreLocalEXP
	movem.l	d1-d5/a0-a3,-(sp)
	move.l	d1,d5
	move.l	d0,d3
	move.l	a1,d4
.store:	move.l	CurGloExp,d0		;1st block
	beq	.newHEAD
	move.l	d0,a3
	move.l	HEAD_current(a3),d0		;current EXP
	cmp.l	HEAD_end(a3),d0		;last EXP
	bge	.newHEAD
.storeEXP:
	addq.l	#1,TotExpNb		;ExpNb++
	move.l	d0,a2
	move.l	d3,EXP_backval(a2)		;sets
	move.l	CurLNb,EXP_lnb(a2)		;line #
	tst.w	d5
	spl	EXP_eval(a2)		;expr complexe
	move.w	CurModNb+2,EXP_mod(a2)	;module #
	move.l	SecSize,EXP_PC(a2)		;cur section size
	move.w	CurSection,EXP_secnum(a2)
	move.w	d2,EXP_patch(a2)		;backpatch type
	IFNE	AMIGA
	cmp.w	#P_ABSL,d2
	beq.s	.addrel
	cmp.w	#P_DCL,d2
	bne.s	.norel
.addrel:	move.l	CurSecPtr,a0
	addq.l	#1,SECTION_maxreloc(a0)
	ENDC	;AMIGA
.norel:	move.w	CurBinNb,EXP_bin(a2)	;binary block #
	IFNE	BLINDOS
	bmi.s	.binerr
	ENDC
	move.l	BinBuffer,d0
	sub.l	FstBinBuffer,d0
	move.w	d0,EXP_poke(a2)		;binary offset
	swap	d5
	move.w	d5,EXP_sec(a2)		;expr len + sec (0)
	IFNE	BLINDOS
	beq.s	.errempt
.aempty:
	ENDC	;BLINDOS
	tst.w	MacStuff+MacNestCnt
	bne	.macro
	sub.l	SrcCurStart,d4
	move.l	CurModPtr,a0
	add.l	MOD_curoffs(a0),d4
	move.l	d4,EXP_start(a2)		;offset source integral
.ares:	addq.w	#1,HEAD_nb(a3)		;+1 EXP
	add.l	#EXP_SIZEOF,HEAD_current(a3)	;+1 element
.end:	movem.l	(sp)+,d1-d5/a0-a3
	rts
.errmem:	bra	Errgexp_ram
	IFNE	BLINDOS
.errempt:	_Debugger
	moveq	#0,d1
	bsr	patpeval
	bra.s	.aempty
.binerr:	_Debugger
	ENDC	;BLINDOS

.newHEAD:	move.l	#HEAD_SIZEOF+EXP_SIZEOF*EXP_BLOCK_NB,d0
	jsr	MyMalloc
	beq.s	.errmem
	move.l	d0,a3
	add.l	#HEAD_SIZEOF,d0
	move.l	CurGloExp,d1
	beq.s	.fstHEAD
	move.l	d1,HEAD_prev(a3)
	exg	d1,a3
	move.l	d1,HEAD_next(a3)
	exg	d1,a3
.inHEAD:	clr.l	HEAD_next(a3)
	move.l	d0,HEAD_start(a3)
	move.l	d0,HEAD_current(a3)
	add.l	#EXP_SIZEOF*EXP_BLOCK_NB,d0
	move.l	d0,HEAD_end(a3)
	clr.w	HEAD_nb(a3)
	move.l	a3,CurGloExp
	bra	.store
.fstHEAD:	move.l	a3,HeadExp
	clr.l	HEAD_prev(a3)
	bra.s	.inHEAD

.macro:	move.w	MacStuff+MacLineSize,d1		;expr en macro
	move.w	d1,d0
	addq.w	#1,d0
	move.l	MacStuff+MacCurBufPtr,a0
.str:	jsr	AllocString
	beq	.errmem
	move.l	d0,a1
	move.w	d1,d0
	PSTRNCPY
	sub.l	a0,d4		;offset/debut de la ligne
	add.w	d4,a1
	move.l	a1,EXP_start(a2)
	neg.w	EXP_mod(a2)	;in ram
	bra	.ares
;  #] StoreEXP:
;  #[ StoreLocalEXP:
;expr avec uniquement des locales donc evaluable au local backpatching
;-globale-locale/locale-globale = constante
;	->rien faire ds local patch
;	->patcher ds global patch
;	stocker dans le fantome l'expr a reevaluer -> EXP_len>0
;-locale sans reloc
;	->patcher ds local patch
;	pas de fantome
;-locale avec reloc
;	->patcher ds local patch
;	fantome sans expr -> sans backpatch -> EXP_len==0
;In:
;d0.l=@ liste locales si type=3
;d1.b=expr type (1,2,3)
;d2.w=patch type
;a0.l=expr @ (token)
;a1.l=expr @ (source)
StoreLocalEXP:
	movem.l	d1-d5/a0-a3,-(sp)
	move.w	d2,d3
	move.l	d0,d2
	move.l	a1,d4
	move.l	d1,d5
	move.l	CurLocExp,d0		;1st block
	beq	.newHEAD
	move.l	d0,a3
.store:	move.l	HEAD_current(a3),d0		;current EXP
	cmp.l	HEAD_end(a3),d0		;last EXP
	bge	.nxtHEAD
.storeEXP:
	move.l	d0,a2
	move.l	d2,EXP_backval(a2)		;sets
	move.l	CurLNb,EXP_lnb(a2)		;line #
	tst.w	d5
	spl	EXP_eval(a2)
	move.w	CurModNb+2,EXP_mod(a2)	;module #
	move.l	SecSize,EXP_PC(a2)		;cur section size
	move.w	CurSection,EXP_secnum(a2)
	move.w	d3,EXP_patch(a2)		;backpatch type
	move.w	CurBinNb,EXP_bin(a2)	;binary block #
	move.l	BinBuffer,d0
	sub.l	FstBinBuffer,d0
	move.w	d0,EXP_poke(a2)		;offset patch ds l'exec
	clr.l	EXP_dupliq(a2)		;no ghost(default)
	swap	d5
	move.b	d5,EXP_len(a2)
	IFNE	BLINDOS
	beq.s	.bug
	ENDC
	tst.w	MacStuff+MacNestCnt
	bne.s	.macro
	sub.l	SrcCurStart,d4
;	move.l	CurModPtr,a0
;	add.l	MOD_curoffs(a0),d4
	move.l	d4,EXP_start(a2)		;offset source partiel
.tstrel:	swap	d5

	IFNE	ATARI
	cmp.w	#P_ABSL,d3
	beq.s	.ghost
	cmp.w	#P_DCL,d3
	beq.s	.ghost
	ENDC	;ATARI

	IFNE	AMIGA
	cmp.w	#P_ABSL,d3
	beq.s	.addrel
	cmp.w	#P_DCL,d3
	bne.s	.tstcomb
.addrel:	move.l	CurSecPtr,a0
	addq.l	#1,SECTION_maxreloc(a0)
	bra.s	.ghost
	ENDC	;AMIGA

.tstcomb:	subq.w	#EVAL_LOCGLO-EVAL_LOC,d5
	bne.s	._end
.ghost:	bsr	.cpy2glo			;loc+reloc=ghost
._end:	addq.w	#1,HEAD_nb(a3)		;+1 EXP
	add.l	#EXP_LOC_SIZEOF,HEAD_current(a3)	;+1 loc
	moveq	#0,d0
.end:	movem.l	(sp)+,d1-d5/a0-a3
	rts
	IFNE	BLINDOS
.bug:	_Debugger
	bra.s	._end
	ENDC

;.slow:	moveq	#0,d0
;	move.w	d5,d0
;	move.l	d4,a0
;	bra.s	.str
.macro:	move.w	MacStuff+MacLineSize,d5
	move.w	d5,d0
	addq.w	#1,d0
	move.l	MacStuff+MacCurBufPtr,a0
.str:	jsr	AllocLocString
	beq.s	.errmem
	move.l	d0,a1
	move.w	d5,d0
	PSTRNCPY
	sub.l	a0,d4		;offset/debut de la ligne
	add.w	d4,a1
	move.l	a1,EXP_start(a2)	;insuffisant en cas de glo-loc
	neg.w	EXP_mod(a2)	;in ram
	bra.s	.tstrel

.nxtHEAD:	move.l	HEAD_next(a3),d0
	beq.s	.resnext
	move.l	d0,a3		;recuperer un bloc precedemment alloue
	move.l	d0,CurLocExp
	move.l	HEAD_start(a3),HEAD_current(a3)
	clr.w	HEAD_nb(a3)
	bra	.store
.errmem:	bra	Errlexp_ram
.resnext:	move.l	#HEAD_SIZEOF+EXP_LOC_SIZEOF*EXP_BLOCK_NB,d0
	jsr	MyMalloc
	beq.s	.errmem
	move.l	d0,a3
	add.l	#HEAD_SIZEOF,d0
	move.l	CurLocExp,d1
	move.l	d1,HEAD_prev(a3)
	exg	d1,a3
	move.l	d1,HEAD_next(a3)
	exg	d1,a3
.inHEAD:	clr.l	HEAD_next(a3)
	move.l	d0,HEAD_start(a3)
	move.l	d0,HEAD_current(a3)
	add.l	#EXP_LOC_SIZEOF*EXP_BLOCK_NB,d0
	move.l	d0,HEAD_end(a3)
	clr.w	HEAD_nb(a3)
	move.l	a3,CurLocExp
	bra	.store
.newHEAD:	move.l	#HEAD_SIZEOF+EXP_LOC_SIZEOF*EXP_BLOCK_NB,d0
	jsr	MyMalloc
	beq.s	.errmem
	move.l	d0,a3
	add.l	#HEAD_SIZEOF,d0
	move.l	a3,HeadLocExp
	clr.l	HEAD_prev(a3)
	bra.s	.inHEAD

;expr contenant seulement des locales et relogeable
;ou expr contenant glo-loc
;allouer une EXP globale et copier
;Out:
;A1=new EXP
.cpy2glo:	move.l	CurGloExp,d0
	beq.s	.gloHEAD
	move.l	d0,a0
.go_exp:	move.l	HEAD_current(a0),d0
	cmp.l	HEAD_end(a0),d0
	bge.s	.gloHEAD
	addq.l	#1,TotExpNb		;Tot EXP #++
	addq.w	#1,HEAD_nb(a0)		;Block EXP #++
	add.l	#EXP_SIZEOF,HEAD_current(a0)	;+1 glo
	move.l	d0,EXP_dupliq(a2)
	move.l	d0,a1
	move.l	a2,a0
	moveq	#EXP_SIZEOF/2-1,d1
.cp:	move.w	(a0)+,(a1)+
	dbf	d1,.cp
	;updater l'offset source du ghost
	move.l	CurModPtr,a0
	move.l	MOD_curoffs(a0),d1
	add.l	d1,EXP_start-EXP_SIZEOF(a1)
	move.l	d0,a1			;new global EXP
	rts
.gloHEAD:	;copie du bloc ci-dessus en global
	move.l	#HEAD_SIZEOF+EXP_SIZEOF*EXP_BLOCK_NB,d0
	jsr	MyMalloc
	beq.s	.errgmem
	move.l	d0,a1
	add.l	#HEAD_SIZEOF,d0
	move.l	CurGloExp,d1
	beq.s	.fsgHEAD
	move.l	d1,a0
	move.l	a0,HEAD_prev(a1)
	move.l	a1,HEAD_next(a0)
.ingHEAD:	clr.l	HEAD_next(a1)
	move.l	d0,HEAD_start(a1)
	move.l	d0,HEAD_current(a1)
	add.l	#EXP_SIZEOF*EXP_BLOCK_NB,d0
	move.l	d0,HEAD_end(a1)
	clr.w	HEAD_nb(a1)
	move.l	a1,CurGloExp
	move.l	a1,a0
	bra	.go_exp
.errgmem:	bra	Errgexp_ram
.fsgHEAD:	move.l	a1,HeadExp
	clr.l	HEAD_prev(a1)
	bra.s	.ingHEAD
;  #] StoreLocalEXP:
;  #[ ResetLocEXPs:
ResetLocEXPs:
	movem.l	d0/a0/a1,-(sp)
	move.l	HeadLocExp,d0
	beq.s	.end
	move.l	d0,a0
	move.l	d0,CurLocExp
	clr.w	HEAD_nb(a0)
	move.l	HEAD_start(a0),HEAD_current(a0)
	move.l	LocStrMemHead,d0
	beq.s	.end
	move.l	d0,a0
	lea	MEMBLOCK_SIZEOF(a0),a1
	move.l	a1,MEMBLOCK_cur(a0)
.end:	movem.l	(sp)+,d0/a0/a1
	rts
;  #] ResetLocEXPs:
;  #[ patch:
RELPCDATA	MACRO
	IFNE	ATARI
	tst.b	GlobPatchFlag
	beq.s	.\@
	cmp.w	#SEC_data,BIN_sec(a6)
	bne.s	.\@
	sub.l	TextSize,d0
.\@:	ENDC
	ENDM

;Input:
;a0:@ ou patcher
;a6:@ struct BIN de la reference
;d0:valeur a patcher
;LO(d1.L):type de patch*2
;HI(d1.L):sign
;Inside:
;d0-d2 garbage
patch:	subq.w	#2,a0			;par defaut
	IFNE	BLINDOS
	cmp.w	#P_MAX,d1
	bhi.s	.err
	ENDC	;BLINDOS
	move.w	.tab(pc,d1.w),d1		;deja *2
	jmp	.tab(pc,d1.w)		;a0=@opcode
	IFNE	BLINDOS
.err:	_Debugger
	rts
	ENDC	;BLINDOS
.tab:	dc.w	.w911-.tab	;P_W911
	dc.w	.ea1-.tab		;P_EA1
	dc.w	.bit8-.tab	;P_BIT8
	dc.w	.bit32-.tab	;P_BIT32
	dc.w	.w07-.tab		;P_W07
	dc.w	.w05-.tab		;P_W05
	dc.w	.w610-.tab	;P_W610
	dc.w	.w02-.tab		;P_W02
	dc.w	.l02-.tab		;P_L02
	dc.w	.l1012-.tab	;P_L1012
	dc.w	.w03-.tab		;P_W03
	dc.w	.l06-.tab		;P_L06
	dc.w	.k06-.tab		;P_K06
	dc.w	.l57-.tab		;P_L57
	dc.w	.ftrapw-.tab	;P_FTRAPW
	dc.w	.ftrapl-.tab	;P_FTRAPL
	dc.w	.d8-.tab		;P_D8
	dc.w	.d16-.tab		;P_D16
	dc.w	.absb-.tab	;P_ABSB
	dc.w	.absw-.tab	;P_ABSW
	dc.w	.absl-.tab	;P_ABSL
	dc.w	.dcb-.tab		;P_DCB
	dc.w	.dcw-.tab		;P_DCW
	dc.w	.dcl-.tab		;P_DCL
	dc.w	.pcd8-.tab	;P_D8PC
	dc.w	.pcd16-.tab	;P_D16PC
	dc.w	.dbcc-.tab	;P_DBCC
	dc.w	.bccb-.tab	;P_BCCB
	dc.w	.bccw-.tab	;P_BCCW
	dc.w	.bccl-.tab	;P_BCCL
	dc.w	.bdpcw-.tab	;P_BDPCW
	dc.w	.bdpcl-.tab	;P_BDPCL

.w911:	move.l	d0,d1		;0<x<=8
	and.b	#%111,d1		;8->0
	add.b	d1,d1		;lsl.b	#1,d0
	or.b	d1,(a0)
	tst.l	d0
	ble.s	.rq
	cmp.l	#8,d0
	bhi.s	.rq
	rts
.rq:	bra	Err_q_exp

.ea1:	subq.l	#1,d0		;d0==1
	bne.s	.rea
	rts
.rea:	bra	Err_shiftea1

.bit8:	move.w	d0,(a0)
	tst.l	d0		;0<=x<8
	bmi.s	.rge64
	moveq	#7,d1
	cmp.l	d1,d0
	bhi.s	.warn8
	rts
.rge64:	bra	Err_bitge64
.warn8:	moveq	#63,d1
	cmp.l	d1,d0
	bhi.s	.rge64
	bra	Warn_bitmod8

.bit32:	move.w	d0,(a0)
	tst.l	d0		;0<=x<32
	bmi.s	.rge64
	moveq	#31,d1
	cmp.l	d1,d0
	bhi.s	.warn32
	rts
.warn32:	moveq	#63,d1
	cmp.l	d1,d0
	bhi.s	.rge64
	bra	Warn_bitmod32

.dcb:
.d8:
.absb:
.w07:	move.b	d0,1(a0)
	moveq	#127,d2		;-128<=x<=127
	cmp.l	d2,d0
	bhi.s	.bytemi
	rts			;127<=(unsigned x)<=0
.bytemi:	bgt.s	.rgeb		;(signed x)>127
	swap	d1
	tst.b	d1
	beq.s	.rgeb
	not.l	d2		;-128
	cmp.l	d2,d0
	blt.s	.rgeb		;(signed x)<-128
	rts
.rgeb:	bra	Err_sizegeb

.w05:	or.w	d0,2(a0)
	moveq	#31,d1		;-31<x<31
	cmp.l	d1,d0
	bhi.s	.rge32
	rts
.rge32:	bra	Err_widthge32

.w610:	move.l	d0,d1
	lsl.w	#6,d1
	or.w	d1,2(a0)
	moveq	#31,d2		;-31<x<31
	cmp.l	d2,d0
	bhi.s	.rg32
	rts
.rg32:	bra	Err_offsetge32

.w02:	or.w	d0,(a0)
	tst.l	d0		;0<=x<=7
	bmi.s	.rbkpt
	moveq	#7,d1
	cmp.l	d1,d0
	bhi.s	.rbkpt
	rts
.rbkpt:	bra	Err_bkptge8

.l02:	or.w	d0,2(a0)
	tst.l	d0		;0<=x<=7
	bmi.s	.rpfc
	moveq	#7,d1
	cmp.l	d1,d0
	bhi.s	.rpfc
	rts
.rpfc:	bra	Err_pfcge7

.l1012:
;	moveq	#7,d1		;-7<=x<=7
;	cmp.l	d1,d0
;	bhi.s	.rge7
	ror.w	#6,d0
	or.w	d0,(a0)
	rts
;.rge7:	bra	Error_level_ge_7

.w03:	or.w	d0,(a0)
	tst.l	d0		;0<=x<=15
	bmi.s	.rgt15
	moveq	#15,d1
	cmp.l	d1,d0
	bhi.s	.rgt15
	rts
.rgt15:	bra	Err_trapgt15

.k06:
.l06:	andi.w	#%1111111,d0	;test a faire
	or.w	d0,(a0)
	rts

.l57:	andi.w	#%111,d0		;a tester
	lsl.w	#5,d0
	or.w	d0,(a0)
	rts

.ftrapw:	move.w	d0,(a0)		;inutilise pour le moment
	rts

.ftrapl:	move.l	d0,(a0)		;inutilise pour le moment
	rts

.d16:	move.w	d0,(a0)
	cmp.l	#$7fff,d0		;-32767<=x<=32767
	bhi.s	.d16mi
	rts
.d16mi:	swap	d1
	tst.b	d1
	beq.s	.dcwerr
	tst.w	d0
	bpl.s	.dcwerr
	swap	d0
	addq.w	#1,d0
	bne.s	.dcwerr
	rts

.dcw:	move.w	d0,(a0)
	cmp.l	#$ffff,d0		;-65535<=x<=65535
	bhi.s	.dcwmi
	rts
.dcwmi:	swap	d1
	tst.b	d1
	beq.s	.dcwerr
	swap	d0
	addq.w	#1,d0
	bne.s	.dcwerr
	rts
.dcwerr:	bra	Err_sizegew

.absw:	move.w	d0,(a0)
	cmp.l	#$7fff,d0
	bgt.s	.dcwerr
	cmp.l	#-32768,d0
	blt.s	.dcwerr
	rts

.dcl:
.absl:	move.l	d0,-2(a0)
	rts

.bccb:	RELPCDATA
	sub.l	EXP_PC(a3),d0		;-128<=x<=127
	beq.s	.short_0
	move.b	d0,1(a0)
	moveq	#-128,d1
	cmp.l	d1,d0
	blt.s	.rmb
	not.l	d1
	cmp.l	d1,d0
	bgt.s	.rpb
	btst	#0,d0
	bne	Warn_oddbranch
	rts
.short_0:	cmp.b	#$61,(a0)
	beq.s	.rzbccb
	tst.w	OptiNopFlg
	beq.s	.rzbccb
	move.w	#$4e71,(a0)
	bra	Opti_zbccb2nop
.rzbccb:	bra	Errzbccb_forb
.rmb:
.rpb:	bra	Err_bunreach

.pcd8:	RELPCDATA
	addq.l	#2,d0
	sub.l	EXP_PC(a3),d0
	move.b	d0,1(a0)
	moveq	#-128,d1
	cmp.l	d1,d0
	blt.s	.rmb
	not.l	d1
	cmp.l	d1,d0
	bgt.s	.rpb
	rts

.dbcc:	RELPCDATA
	addq.l	#2,d0
	sub.l	EXP_PC(a3),d0
	move.w	d0,(a0)
	move.l	#$7fff,d1
	cmp.l	d1,d0
	bgt.s	.rw
	not.l	d1
	cmp.l	d1,d0
	blt.s	.rw
	btst	#0,d0
	bne	Warn_oddbranch
	rts

.bccw:	RELPCDATA
	addq.l	#2,d0
	sub.l	EXP_PC(a3),d0
	move.w	d0,(a0)			;poke d'abord
	move.l	#$7fff,d1			;teste ensuite
	cmp.l	d1,d0
	bgt.s	.rw
	not.l	d1
	cmp.l	d1,d0
	blt.s	.rw
	btst	#0,d0
	bne.s	.oddbccw
.aoddw:	tst.w	OptiFBccFlg
	beq.s	.endpcw
	moveq	#$7f,d1
	cmp.l	d1,d0
	bls.s	.optw			;ou ble ?
.endpcw:	rts
.rw:	bra	Err_wunreach
.optw:	bra	Opti_fwbcc2b
.oddbccw:	move.l	d0,-(sp)
	bsr	Warn_oddbranch
	move.l	(sp)+,d0
	bra.s	.aoddw

.pcd16:	RELPCDATA
	addq.l	#2,d0
	sub.l	EXP_PC(a3),d0
	move.w	d0,(a0)
	move.l	#$7fff,d1
	cmp.l	d1,d0
	bgt.s	.rw
	not.l	d1
	cmp.l	d1,d0
	blt.s	.rw
	rts

.bdpcw:	RELPCDATA
	addq.l	#4,d0
	sub.l	EXP_PC(a3),d0
	move.w	d0,(a0)
	move.l	#$7fff,d1
	cmp.l	d1,d0
	bgt.s	.rw
	not.l	d1
	cmp.l	d1,d0
	blt.s	.rw
	rts

.bccl:	RELPCDATA
	addq.l	#4,d0
	sub.l	EXP_PC(a3),d0
	move.l	d0,-2(a0)
	btst	#0,d0
	bne.s	.oddbccl
.aoddl:	tst.w	OptiFBccFlg
	bne.s	.optl
.endbccl:	rts
.optl:	moveq	#$7f,d1
	cmp.l	d1,d0
	bls	.optw			;ou ble ?
	move.l	#$7fff,d1
	cmp.l	d1,d0
	bgt.s	.endbccl
	not.l	d1
	cmp.l	d1,d0
	blt.s	.endbccl
	bra	Opti_fwbcc2w
.oddbccl:	move.l	d0,-(sp)
	bsr	Warn_oddbranch
	move.l	(sp)+,d0
	bra.s	.aoddl

.bdpcl:	RELPCDATA
	addq.l	#6,d0
	sub.l	EXP_PC(a3),d0
	move.l	d0,-2(a0)
	rts
;  #] patch:
;  #[ LocalPatch:
;reevalue les exp contenant des locales|var+loc
;d3:# EXP
;d4:# MOD
;d5:# BIN
;d6:start BIN
;d7:last char
;a2:@ HEAD
;a3:@ EXP
;a4:@ MOD
;a5:pas touche
;a6:@ BIN
LocalPatch:
	movem.l	d0-a6,-(sp)
	move.l	HeadLocExp,d0
	beq	.end
	st	LocPatchFlag
	moveq	#0,d5		;BIN # (0=impossible)
	move.l	FstBinPtr,a6
	move.l	BIN_start(a6),d6
	moveq	#0,d4		;MOD # (0=impossible)
	suba.l	a4,a4
.nxtHEAD:	move.l	d0,a2
	move.l	HEAD_start(a2),a3
	move.w	HEAD_nb(a2),d3
	subq.w	#1,d3
	bmi	.end		;peut arriver
	clr.w	HEAD_nb(a2)
.nxtEXP:	cmp.w	EXP_mod(a3),d4
	bne	.newmod
.samemod:	move.l	EXP_start(a3),a0
	add.l	a4,a0		;MOD start
	moveq	#0,d0
	move.b	EXP_len(a3),d0
	lea	0(a0,d0.w),a1
	move.b	(a1),d7
	SETEOL	(a1)
	move.b	EXP_eval(a3),d0
	bsr	LocEval
	beq.s	.patch		;no reloc
	bmi.s	.reval
	move.b	d7,(a1)
	subq.b	#EVAL_RELOC,d1	;reloc+(loc-glob/glob-loc) ?
	bne	.updateghost	;EVAL_LOCGLO ou EVAL_RELOC+EVAL_LOCGLO
.noghost:	move.w	EXP_patch(a3),a0	;patch d'1 expr possiblement relogeable
	move.w	.tab(pc,a0.w),a0	;deja *2
	jmp	.tab(pc,a0.w)
.reval:	bra	._erreval
.reloc:	move.l	EXP_dupliq(a3),a0	;reloc & patch
	move.w	CurSection,d1
	addq.b	#1,d1
	move.b	d1,EXP_sec(a0)
	addq.l	#1,LocRelNb
	bra.s	.dup
.patch:	move.b	d7,(a1)
	move.l	EXP_dupliq(a3),d2
	beq.s	.nodup
	move.l	d2,a0
.dup:	clr.b	EXP_len(a0)	;for ghost
.nodup:	cmp.w	EXP_bin(a3),d5
	bne.s	.newbin
.samebin:	move.l	d6,a0		;bin start
	add.w	EXP_poke(a3),a0	;patch addr
	move.w	EXP_patch(a3),d1
	moveq	#SEC_text+1,d7
	bsr	patch		;d0=value
.next:	lea	EXP_LOC_SIZEOF(a3),a3
	dbf	d3,.nxtEXP
	move.l	HEAD_next(a2),d0
	bne	.nxtHEAD
.end:	sf	LocPatchFlag
	movem.l	(sp)+,d0-a6
	rts
.newbin:	move.w	d5,d1
	move.w	EXP_bin(a3),d5
	sub.w	d5,d1
	IFNE	BLINDOS
	bpl.s	.prevbin
	ENDC
.l2:	move.l	BIN_next(a6),a6
	addq.w	#1,d1
	bne.s	.l2
	move.l	BIN_start(a6),d6
	bra.s	.samebin
;en local patch on doit pas pouvoir reculer d'1 buffer binaire
	IFNE	BLINDOS
.prevbin:	_Debugger
	ENDC

.tab:	dc.w	.rrel-.tab	;P_W911
	dc.w	.rrel-.tab	;P_EA1
	dc.w	.rrel-.tab	;P_BIT8
	dc.w	.rrel-.tab	;P_BIT32
	dc.w	.rrel-.tab	;P_W07
	dc.w	.rrel-.tab	;P_W05
	dc.w	.rrel-.tab	;P_W610
	dc.w	.rrel-.tab	;P_W02
	dc.w	.rrel-.tab	;P_L02
	dc.w	.rrel-.tab	;P_L1012
	dc.w	.rrel-.tab	;P_W03
	dc.w	.rrel-.tab	;P_L06
	dc.w	.rrel-.tab	;P_K06
	dc.w	.rrel-.tab	;P_L57
	dc.w	.rrel-.tab	;P_FTRAPW
	dc.w	.rrel-.tab	;P_FTRAPL
	dc.w	.rrel-.tab	;P_D8
	dc.w	.rrel-.tab	;P_D16
	dc.w	.rrel-.tab	;P_ABSB
	dc.w	.rrel-.tab	;P_ABSW
	dc.w	.reloc-.tab	;P_ABSL
	dc.w	.rrel-.tab	;P_DCB
	dc.w	.rrel-.tab	;P_DCW
	dc.w	.reloc-.tab	;P_DCL
	dc.w	.patch-.tab	;P_D8PC
	dc.w	.patch-.tab	;P_D16PC
	dc.w	.patch-.tab	;P_DBCC
	dc.w	.patch-.tab	;P_BCCB
	dc.w	.patch-.tab	;P_BCCW
	dc.w	.patch-.tab	;P_BCCL
	dc.w	.patch-.tab	;P_BDPCW
	dc.w	.patch-.tab	;P_BDPCL

.newmod:	move.w	EXP_mod(a3),d4
	bmi.s	.macro
	move.l	FstModPtr,a4
	move.w	d4,d1
	subq.w	#2,d1
	bmi.s	.fstmod
.l3:	move.l	MOD_next(a4),a4
	dbf	d1,.l3
.fstmod:	move.l	MOD_addr(a4),a4
	bra	.samemod
.macro:	suba.l	a4,a4
	bra	.samemod

;Expression avec globales+locales et/ou relogeable
;d0=liste de valeurs locales
;a3=expr source
.updateghost:
	tst.l	d0
	beq	.reloc		;reloger mais pas reevaluer
.stloc:	move.l	EXP_dupliq(a3),d1
	bne.s	.do_dup
	move.l	d0,a0
	move.l	(a0),d0	;recuperer la valeur
	bra	.noghost
.do_dup:	move.l	d1,a1	;storer les locales pour globpatch
	move.l	EXP_backval(a1),d2	;plantos ($ff)
	beq.s	.noset
	move.l	d2,a0
	move.w	(a0),d2
	add.w	d2,d2
	move.w	d2,d1
	add.w	d1,d1
	add.w	d2,d1	;*6
	addq.l	#6,d0	;skip @+set count
	move.l	d0,2(a0,d1.w)
	bra.s	.rel
.noset:	move.l	d0,EXP_backval(a1)
.rel:	move.w	CurSection,d1
	addq.b	#1,d1
	move.b	d1,EXP_sec(a1)
	bra	.next

.rrel:	moveq	#EVAL_NOREL,d1
;	bra	._erreval
._erreval:
	move.b	d7,(a1)
	move.l	EXP_dupliq(a3),d0
	beq.s	.do_err
	move.l	d0,a1
	clr.b	EXP_len(a1)	;ne pas globalpatcher si erreur !
.do_err:	bsr	patpeval
	tst.b	StopFlg
	beq	.next
	bra	.end
;  #] LocalPatch:
;  #[ GlobalPatch:
;d3:# EXP
;d4:# MOD
;d5:# BIN
;d6:BIN start
;d7:last char
;a2:@ HEAD
;a3:@ EXP
;a4:MOD start
;a5:pas touche
;a6:@ BIN
GlobalPatch:
	movem.l	d0-a6,-(sp)
	move.l	HeadExp,d0
	beq	.ok
	st	GlobPatchFlag
	moveq	#0,d5
	move.l	FstBinPtr,a6
	move.l	BIN_start(a6),d6
	moveq	#0,d4		;MOD # (0=impossible)
	move.w	d4,CurModule
.nxblock:	move.l	d0,a2
	move.l	HEAD_start(a2),a3
	move.w	HEAD_nb(a2),d3
	subq.w	#1,d3
	bmi	.end
.nxtEXP:	move.w	EXP_sec(a3),d0	;sec+size
	andi.w	#$ff,d0		;viros section
	beq	.locrel		;fantome pour la reloc
	cmp.w	EXP_mod(a3),d4
	bne	.newmod
.samemod:	move.l	EXP_start(a3),a0
	add.l	a4,a0		;MOD start
	lea	0(a0,d0.w),a1
	move.b	(a1),d7
	SETEOL	(a1)
;	move.l	EXP_backval(a3),d1
	move.b	EXP_eval(a3),d0
	bsr	GloEval		;utilise a3
	bmi.s	.reval
	move.b	d7,(a1)
	move.l	d1,-(sp)		;sauve d1
	btst	#8,d1		;local with reloc
	sne	EXP_backval(a3)
	beq.s	.noloc
	addq.l	#1,LocRelNb
.noloc:	swap	d1
	move.w	d1,d7		;var #
	move.b	d2,d1		;sign
	swap	d1
	cmp.w	EXP_bin(a3),d5
	bne	.newbin
.samebin:	move.b	d1,EXP_sec(a3)	;reloc->section+1,(ff if undef)
	bmi	.xref
.patch:	lea	.t(pc),a0
	move.w	EXP_patch(a3),d2
	move.w	0(a0,d2.w),d2
	jmp	0(a0,d2.w)
.next:	move.l	(sp)+,EXP_varnb(a3)	;var #|00|(section+1 ou ff if undef)
.next2:	lea	EXP_SIZEOF(a3),a3
	dbf	d3,.nxtEXP
	move.l	HEAD_next(a2),d0
	bne	.nxblock
	move.w	CurModule,d0
	beq.s	.ok
	bsr	free_module
.ok:	moveq	#0,d0
.end:	sf	GlobPatchFlag
	movem.l	(sp)+,d0-a6
	rts
;reference relogeable a un local - pas d'evaluation
.locrel:	st	EXP_backval(a3)
	IFNE	AMIGA
	bsr	store_reloc
	ENDC
	bra.s	.next2
;erreur d'eval
.reval:	move.b	d7,(a1)
	bsr	patpeval
	tst.b	StopFlg
	beq.s	.next2
	bra.s	.end

.newmod:	tst.w	SlowFlg
	bne.s	.slow
	move.w	EXP_mod(a3),d4
	bmi.s	.macro
	move.l	FstModPtr,a4
	move.w	d4,d1
	subq.w	#2,d1
	bmi.s	.fstmod
.l3:	move.l	MOD_next(a4),a4
	dbf	d1,.l3
.fstmod:	move.l	MOD_addr(a4),a4
	bra	.samemod
.macro:	suba.l	a4,a4
	bra	.samemod
.slow:	bsr	slow_getmod
	bra	.samemod

.newbin:	move.w	d5,d2
	move.w	EXP_bin(a3),d5
	sub.w	d5,d2
	bpl.s	.binprev
.l2:	move.l	BIN_next(a6),a6
	addq.w	#1,d2
	bne.s	.l2
	move.l	BIN_start(a6),d6
	bra	.samebin
.binprev:	move.l	BIN_prev(a6),a6
	subq.w	#1,d2
	bne.s	.binprev
	move.l	BIN_start(a6),d6
	bra	.samebin

;	 #[ check xref:
.xref:	move.w	EXP_patch(a3),a1
	IFNE	BLINDOS
	cmp.w	#P_MAX,a1
	bhi.s	.bug
	ENDC	;BLINDOS
	move.w	.tab(pc,a1.w),a0	;deja *2
	jmp	.tab(pc,a0.w)
	IFNE	BLINDOS
.bug:	_Debugger
	bra	.next
	ENDC	;BLINDOS

;----------------- XREF ATARI ------------------
	IFNE	ATARI
.tab:	dc.w	.rlnk-.tab	;P_W911
	dc.w	.rlnk-.tab	;P_EA1
	dc.w	.rlnk-.tab	;P_BIT8
	dc.w	.rlnk-.tab	;P_BIT32
	dc.w	.rlnk-.tab	;P_W07
	dc.w	.rlnk-.tab	;P_W05
	dc.w	.rlnk-.tab	;P_W610
	dc.w	.rlnk-.tab	;P_W02
	dc.w	.rlnk-.tab	;P_L02
	dc.w	.rlnk-.tab	;P_L1012
	dc.w	.rlnk-.tab	;P_W03
	dc.w	.rlnk-.tab	;P_L06
	dc.w	.rlnk-.tab	;P_K06
	dc.w	.rlnk-.tab	;P_L57
	dc.w	.rlnk-.tab	;P_FTRAPW
	dc.w	.rlnk-.tab	;P_FTRAPL
	dc.w	.rlnk-.tab	;P_D8
	dc.w	.rlnk-.tab	;P_D16
	dc.w	.xrb-.tab		;P_ABSB
	dc.w	.xrw-.tab		;P_ABSW
	dc.w	.xrl-.tab		;P_ABSL
	dc.w	.xrb-.tab		;P_DCB
	dc.w	.xrw-.tab		;P_DCW
	dc.w	.xrl-.tab		;P_DCL
	dc.w	.xrpcb-.tab	;P_D8PC
	dc.w	.xrpcw-.tab	;P_D16PC
	dc.w	.xrpcw-.tab	;P_PCDBCC
	dc.w	.xrpcb-.tab	;P_BCCB
	dc.w	.xrpcw-.tab	;P_BCCW
	dc.w	.xrpcl-.tab	;P_BCCL
	dc.w	.xrpcw-.tab	;P_BDPCW
	dc.w	.xrpcl-.tab	;P_BDPCL

.rlnk:	bsr	Errlink_rest
	bra	.next

.xrb:
.xrpcb:	cmp.w	#BSD_OBJ,OutType+2	;BSD xref abs.b/pc.b only
	bne.s	.rlnk
	move.w	.offtab(pc,a1.w),a0	;all xref abs.b/pc.b
	add.l	d6,a0
	add.w	EXP_poke(a3),a0
	move.b	d0,(a0)
	bra	.next

;Input: a1.w=type de patch
.xrw:	cmp.w	#DRI_OBJ,OutType+2	;DRI xref abs.w forbid
	beq.s	.rlnk
.xrpcw:	move.w	.offtab(pc,a1.w),a0	;all xref pc.w
	add.l	d6,a0
	add.w	EXP_poke(a3),a0
	move.w	d0,(a0)
	bra	.next

.xrpcl:	cmp.w	#DRI_OBJ,OutType+2	;DRI xref pc.l forbid
	beq.s	.rlnk
.xrl:	move.w	.offtab(pc,a1.w),a0	;all xref abs.l
	add.l	d6,a0
	add.w	EXP_poke(a3),a0
	move.l	d0,(a0)
	bra	.next

.offtab:
;P_W911,P_EA1,P_BIT8,P_BIT32,P_W07,P_W05,P_W610,P_W02
	dc.w	-2,-2,-2,-2,-1,-2,-2,-2
;P_L02,P_L1012,P_W03,P_L06,P_K06,P_L57,P_FTRAPW,P_FTRAPL
	dc.w	0,-2,-2,-2,-2,-2,-2,-2
;P_D8,P_D16,P_ABSB,P_ABSW,P_ABSL,P_DCB,P_DCW,P_DCL
	dc.w	-1,-2,-1,-2,-4,-1,-2,-4
;P_D8PC,P_D16PC,P_DBCC,P_BCCB,P_BCCW,P_BCCL,P_BDPCW,P_BDPCL
	dc.w	-1,-2,-2,-1,-2,-4,-2,-4
	ENDC	;ATARI

;----------------- XREF AMIGA ------------------
	IFNE	AMIGA
.tab:	dc.w	.rlnk-.tab	;P_W911
	dc.w	.rlnk-.tab	;P_EA1
	dc.w	.rlnk-.tab	;P_BIT8
	dc.w	.rlnk-.tab	;P_BIT32
	dc.w	.rlnk-.tab	;P_W07
	dc.w	.rlnk-.tab	;P_W05
	dc.w	.rlnk-.tab	;P_W610
	dc.w	.rlnk-.tab	;P_W02
	dc.w	.rlnk-.tab	;P_L02
	dc.w	.rlnk-.tab	;P_L1012
	dc.w	.rlnk-.tab	;P_W03
	dc.w	.rlnk-.tab	;P_L06
	dc.w	.rlnk-.tab	;P_K06
	dc.w	.rlnk-.tab	;P_L57
	dc.w	.rlnk-.tab	;P_FTRAPW
	dc.w	.rlnk-.tab	;P_FTRAPL
	dc.w	.rlnk-.tab	;P_D8
	dc.w	.rlnk-.tab	;P_D16
	dc.w	.rlnk-.tab	;P_ABSB
	dc.w	.rlnk-.tab	;P_ABSW	abs16
	dc.w	.xrl-.tab		;P_ABSL
	dc.w	.rlnk-.tab	;P_DCB
	dc.w	.rlnk-.tab	;P_DCW	abs16
	dc.w	.xrl-.tab		;P_DCL
	dc.w	.xrpcb-.tab	;P_D8PC
	dc.w	.xrpcw-.tab	;P_D16PC
	dc.w	.xrpcw-.tab	;P_PDBCC
	dc.w	.xrpcb-.tab	;P_BCCB
	dc.w	.xrpcw-.tab	;P_BCCW
	dc.w	.rlnk-.tab	;P_BCCL	relatif 32
	dc.w	.xrpcw-.tab	;P_BDPCW
	dc.w	.rlnk-.tab	;P_BDPCL	relatif 32

.rlnk:	bsr	Errlink_rest
	bra	.next

.xrpcb:	move.w	.offtab(pc,a1.w),a0
	move.w	a0,d2
	swap	d2
	move.w	#132,d2		;ext_ref8
	add.l	d6,a0
	add.w	EXP_poke(a3),a0
	move.b	d0,(a0)
	bsr	add_xref
	bra	.next

.xrpcw:	move.w	.offtab(pc,a1.w),a0
	move.w	a0,d2
	swap	d2
	move.w	#131,d2		;ext_ref16
	add.l	d6,a0
	add.w	EXP_poke(a3),a0
	move.w	d0,(a0)
	bsr	add_xref
	bra	.next

.xrl:	move.w	.offtab(pc,a1.w),a0
	move.w	a0,d2
	swap	d2
	move.w	#129,d2		;ext_ref32
	add.l	d6,a0
	add.w	EXP_poke(a3),a0
	move.l	d0,(a0)
	bsr	add_xref
	bra	.next

.offtab:
;P_W911,P_EA1,P_BIT8,P_BIT32,P_W07,P_W05,P_W610,P_W02
	dc.w	-2,-2,-2,-2,-1,-2,-2,-2
;P_L02,P_L1012,P_W03,P_L06,P_K06,P_L57,P_FTRAPW,P_FTRAPL
	dc.w	0,-2,-2,-2,-2,-2,-2,-2
;P_D8,P_D16,P_ABSB,P_ABSW,P_ABSL,P_DCB,P_DCW,P_DCL
	dc.w	-1,-2,-1,-2,-4,-1,-2,-4
;P_D8PC,P_D16PC,P_DBCC,P_BCCB,P_BCCW,P_BCCL,P_BDPCW,P_BDPCL
	dc.w	-1,-2,-2,-1,-2,-4,-2,-4

	ENDC	;AMIGA

;	 #] check xref:
;	 #[ check rel:
.t:	dc.w	.norel-.t		;P_W911
	dc.w	.norel-.t		;P_EA1
	dc.w	.norel-.t		;P_BIT8
	dc.w	.norel-.t		;P_BIT32
	dc.w	.norel-.t		;P_W07
	dc.w	.norel-.t		;P_W05
	dc.w	.norel-.t		;P_W610
	dc.w	.norel-.t		;P_W02
	dc.w	.norel-.t		;P_L02
	dc.w	.norel-.t		;P_L1012
	dc.w	.norel-.t		;P_W03
	dc.w	.norel-.t		;P_L06
	dc.w	.norel-.t		;P_K06
	dc.w	.norel-.t		;P_L57
	dc.w	.norel-.t		;P_FTRAPW
	dc.w	.norel-.t		;P_FTRAPL
	dc.w	.norel-.t		;P_D8
	dc.w	.norel-.t		;P_D16
	dc.w	.norel-.t		;P_ABSB
	dc.w	.norel-.t		;P_ABSW
	dc.w	.any-.t		;P_ABSL
	dc.w	.norel-.t		;P_DCB
	dc.w	.norel-.t		;P_DCW
	dc.w	.any-.t		;P_DCL
	dc.w	.pcb-.t		;P_D8PC
	dc.w	.pcw-.t		;P_D16PC
	dc.w	.pcw-.t		;P_DBCC
	dc.w	.pcb-.t		;P_BCCB
	dc.w	.pcw-.t		;P_BCCW
	dc.w	.pcl-.t		;P_BCCL
	dc.w	.pcw-.t		;P_BDPCW
	dc.w	.pcl-.t		;P_BDPCL

	IFNE	ATARI
.pcb:	tst.w	OutType+2		;if object
	beq.s	.rel
	subq.b	#1,d1		;sec+1->sec
	cmp.b	BIN_sec+1(a6),d1	;if sec(sym)!=sec(bin)
	beq.s	.dopatch
	bra	.rlnk		;pc.b forbid

.pcl:	tst.w	OutType+2		;if object
	beq.s	.rel
	subq.b	#1,d1		;sec+1->sec
	cmp.b	BIN_sec+1(a6),d1	;if sec(sym)!=sec(bin)
	beq.s	.dopatch
;	cmp.w	#PURE_OBJ,OutType+2	;if Pure obj
;	beq.s	.sub2pc
	bra	.rlnk		;pc.l forbid

.pcw:	tst.w	OutType+2		;if obj
	beq.s	.rel
	subq.b	#1,d1		;sec+1->sec
	cmp.b	BIN_sec+1(a6),d1	;if sec(sym)!=sec(bin)
	beq.s	.dopatch
	bra	.rlnk		;pc.l forbid

;.sub2pc:	move.l	GloTbl,a0
;	move.l	d7,d1
;	add.l	d1,d1
;	add.l	d1,d1
;	move.l	0(a0,d1.l),a0
;	sub.l	VAR_value(a0),d0	;d0-=value(sym)
;	bra.s	.dopatch
	ENDC	;ATARI

.rel:	tst.b	d1
	bhi.s	.dopatch
	bsr	Errrel_req
	bra	.next

.norel:	tst.b	d1		;forbid reloc
	bne.s	.rrel
	IFNE	ATARI
.any:	cmp.w	#BSD_OBJ,OutType+2
	bne.s	.dopatch		;stupid BSD relocation
	subq.b	#1,d1
	bmi.s	.dopatch		;who knows
	andi.w	#%1100,d1		;must be TEXT,DATA or BSS
	lea	BsdOffsets,a0
	add.l	0(a0,d1.w),d0
	ENDC	;ATARI
.dopatch:	move.w	EXP_patch(a3),d1
	move.l	d6,a0
	add.w	EXP_poke(a3),a0
	bsr	patch		;d0=value
	bra	.next
.rrel:	moveq	#EVAL_NOREL,d1
	bsr	patpeval
	bra	.next

	IFNE	AMIGA
.any:	tst.b	EXP_sec(a3)
	beq.s	.dopatch
	bsr.s	store_reloc
	bra.s	.dopatch

.pcw:
.pcl:
.pcb:	subq.b	#1,d1
	cmp.b	EXP_secnum+1(a3),d1
	beq.s	.dopatch
	bsr	Errrel_oos
	bra	.next
	ENDC	;AMIGA

	IFNE	AMIGA
;In: a3=@EXP a reloger
store_reloc:
	move.l	d0,-(sp)
	move.w	EXP_secnum(a3),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	TabSecs,a0
	move.l	0(a0,d0.w),a0
	move.l	SECTION_currel(a0),a1
	move.b	EXP_sec(a3),d0
	subq.b	#1,d0
	ext.w	d0
	move.w	d0,(a1)+
	move.l	EXP_PC(a3),d0
	subq.l	#4,d0
	move.l	d0,(a1)+
	move.l	a1,SECTION_currel(a0)
	addq.l	#1,SECTION_relocnb(a0)
	move.l	(sp)+,d0
	rts

;In: a3=@EXP a reloger - d7.w = xref # - HI(d2.L)=add poke - LO(d2.l)=xref type
add_xref:	move.l	a2,-(sp)
	move.w	EXP_secnum(a3),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	TabSecs,a0
	move.l	0(a0,d0.w),a2
	addq.l	#1,SECTION_xrefnb(a2)
	move.l	SECTION_xreflist(a2),d0
	beq.s	.alloc
	move.l	d0,a0
	move.l	XREFL_cur(a0),a1
	cmp.l	XREFL_end(a0),a1
	bge.s	.alloc
.got:	move.w	d7,(a1)+		;var #
	move.w	d2,(a1)+		;ref type
	move.l	EXP_PC(a3),d0
	swap	d2
	ext.l	d2
	add.l	d2,d0
	move.l	d0,(a1)+
	move.l	a1,XREFL_cur(a0)
	addq.w	#1,XREFL_nb(a0)
	move.l	(sp)+,a2
	rts
.alloc:	;d0=@bloc actuel plein ou inexistant
	move.l	d0,a1
	move.l	#XREFL_SIZEOF+XREFS_PER_LBLOCK*8,d0
	jsr	MyMalloc
	beq.s	.errmem
	move.l	d0,SECTION_xreflist(a2)
	move.l	d0,a0
	add.l	#XREFL_SIZEOF,d0
	move.l	a1,XREFL_next(a0)
	move.l	d0,XREFL_cur(a0)
	move.l	d0,XREFL_start(a0)
	move.l	d0,a1
	add.l	#XREFS_PER_LBLOCK*8,d0
	move.l	d0,XREFL_end(a0)
	clr.w	XREFL_nb(a0)
	bra.s	.got
.errmem:	bra	Errgexp_ram
	ENDC	;AMIGA
	
;	 #] check rel:
;	 #[ Reload & free modules:
;Input: a3=@struct EXP, d4=cur mod #, 0:first,<0:macro
slow_getmod:
	move.w	d0,-(sp)
	move.w	EXP_mod(a3),d0
	tst.w	d4
	ble.s	.frommac	;ou 1ere exp
	tst.w	d0
	bmi.s	.end0	;mod->macro
	;mod1->mod2
	bra.s	.free
.frommac:	tst.w	d0
	bmi.s	.end0	;macro/rien->macro
	;macro/rien->module
	cmp.w	CurModule,d0
	bne.s	.free
	bsr.s	getmod
	move.l	MOD_addr(a0),a4
	bra.s	.end
.free:	move.w	CurModule,d0
	beq.s	.load
	bsr.s	free_module
.load:	move.w	EXP_mod(a3),d0
	bsr.s	load_module
	move.l	a0,a4
	move.w	d0,CurModule
.end:	move.w	EXP_mod(a3),d4
	move.w	(sp)+,d0
	rts
.end0:	suba.l	a4,a4
	bra.s	.end

;In: d0=module #
load_module:
	movem.l	d0/d1/a1-a2,-(sp)
	bsr.s	getmod
	move.l	a0,a2
	tst.l	MOD_headed(a2)
	bne.s	.edit
	move.l	MOD_addr(a2),d0
	beq.s	.nofree
	move.l	d0,a0
	jsr	MyMfree
.nofree:	move.l	MOD_expnam(a2),a0
	moveq	#0,d0
	move.l	MOD_size(a2),d1
	jsr	LoadSrc
	bmi	Errload_mod
	move.l	a0,MOD_addr(a2)
.end:	movem.l	(sp)+,d0/d1/a1-a2
	rts
.edit:	move.l	MOD_addr(a2),a0
	bra.s	.end

;In: d0=module #
free_module:
	bsr.s	getmod
	tst.l	MOD_headed(a0)	;pas freer src de Edit
	bne.s	.rts
	move.l	a0,a1
	move.l	MOD_addr(a1),a0
	clr.l	MOD_addr(a1)
	jmp	MyMfree
.rts:	rts

;In: d0=module #
;Out: MOD @
getmod:	move.l	FstModPtr,a0
	move.w	d0,d1
	subq.w	#2,d1
	bmi.s	.fstmod
.l3:	move.l	MOD_next(a0),a0
	dbf	d1,.l3
.fstmod:	rts
;	 #] Reload & free modules:
;	 #[ BsdCreateOffsets:
BsdCreateOffsets:
	lea	BsdOffsets,a0	;build offsets for stupid BSD format
	clr.l	(a0)+		;text off=0L
	move.l	TextSize,d0
	move.l	d0,(a0)+		;data off=textsize
	add.l	DataSize,d0
	move.l	d0,(a0)+		;bss off=textsize+datasize
	clr.l	(a0)+		;abs off=0L
	rts
;	 #] BsdCreateOffsets:
;  #] GlobalPatch:
;  #[ Patch Errors:
;d1=eval error #
patpeval:	movem.l	a0-a1,-(sp)
	lea	patmsg,a0
	move.w	#MSG_EVAL,MSG_flags(a0)
	neg.w	d1
	move.w	d1,MSG_no(a0)
	move.l	a3,a1
	bsr	SetEXPErr
	move.w	EXP_patch(a3),d0		;code erreur
	IFNE	BLINDOS
	cmp.w	#P_MAX,d0
	bhi.s	.bug
	ENDC	;BLINDOS
	move.w	.errnums(pc,d0.w),MSG_ev(a0)
	jsr	OutMsg
.end:	movem.l	(sp)+,a0-a1
	rts
	IFNE	BLINDOS
.bug:	_Debugger
	bra.s	.end
	ENDC	;BLINDOS
.errnums:	dc.w	-eval_immed_errno	;P_W911
	dc.w	-eval_immed_errno	;P_EA1
	dc.w	-eval_immed_errno	;P_BIT8
	dc.w	-eval_immed_errno	;P_BIT32
	dc.w	-eval_immed_errno	;P_W07
	dc.w	-eval_immed_errno	;P_W05
	dc.w	-eval_immed_errno	;P_W610
	dc.w	-eval_immed_errno	;P_W02
	dc.w	-eval_immed_errno	;P_L02
	dc.w	-eval_immed_errno	;P_L1012
	dc.w	-eval_immed_errno	;P_W03
	dc.w	-eval_immed_errno	;P_L06
	dc.w	-eval_immed_errno	;P_K06
	dc.w	-eval_immed_errno	;P_L57
	dc.w	-eval_immed_errno	;P_FTRAPW
	dc.w	-eval_immed_errno	;P_FTRAPL
	dc.w	-eval_d8_errno	;P_D8
	dc.w	-eval_d16_errno	;P_D16
	dc.w	-eval_d8_errno	;P_ABSB
	dc.w	-eval_d16_errno	;P_ABSW
	dc.w	-eval_immed_errno	;P_ABSL
	dc.w	-eval_immed_errno	;P_DCB
	dc.w	-eval_immed_errno	;P_DCW
	dc.w	-eval_immed_errno	;P_DCL
	dc.w	-eval_d8_errno	;P_D8PC
	dc.w	-eval_d16_errno	;P_D16PC
	dc.w	-eval_pc_errno	;P_DBCC
	dc.w	-eval_pc_errno	;P_BCCB
	dc.w	-eval_pc_errno	;P_BCCW
	dc.w	-eval_pc_errno	;P_BCCL
	dc.w	-eval_pc_errno	;P_BDPCW
	dc.w	-eval_pc_errno	;P_BDPCL

Err_bunreach:
	sub.l	d1,d0
	bsr.s	SprintDisp
	moveq	#pcb_not_reached_errno,d0
	bra.s	patperror
Err_wunreach:
	sub.l	d1,d0
	bsr.s	SprintDisp
	moveq	#pcw_not_reached_errno,d0
	bra.s	patperror
SprintDisp:
	tst.l	d0
	bpl.s	.ok
	neg.l	d0
.ok:	move.l	d0,-(sp)
	lea	UsrTxt,a0
	lea	.fmt(pc),a1
	bsr	Sprintf
	addq.w	#4,sp
	rts
.fmt:	dc.b	"$%=lx byte(s)",0
	even
Err_sizegew:
	moveq	#sz_ge_w_errno,d0
	bra.s	patperror
Err_shiftea1:
	moveq	#shift_ea_1_errno,d0
	bra.s	patperror
Err_bitge64:
	moveq	#bitge64_errno,d0
	bra.s	patperror
Err_q_exp:
	moveq	#q_exp_errno,d0
	bra.s	patperror
Err_bkptge8:
	moveq	#bkptge8_errno,d0
	bra.s	patperror
Err_shift_ge_8:
	moveq	#shift_ge_8_errno,d0
	bra.s	patperror
Err_sizegeb:
	moveq	#sz_ge_b_errno,d0
	bra.s	patperror
Err_widthge32:
	moveq	#width_ge_32_errno,d0
	bra.s	patperror
Err_offsetge32:
	moveq	#offset_ge_32_errno,d0
	bra.s	patperror
Err_pfcge7:
	moveq	#pfc_ge_7_errno,d0
	bra.s	patperror
Err_trapgt15:
	moveq	#trap_gt_15_errno,d0
	bra.s	patperror
Err_w_exp:
	moveq	#w_exp_errno,d0
	bra.s	patperror
Errzbccb_forb:
	moveq	#zbccb_forb_errno,d0
	bra.s	patperror
Errlink_rest:
	move	#link_rest_errno,d0
	bra.s	patperror
Errrel_oos:
	move	#rel_oos_sec_errno,d0
	bra.s	patperror
Errrel_req:
	moveq	#eval_errno,d0
;	bra.s	patperror

patperror:
	neg.w	d0
	lea	patmsg,a0
	clr.w	MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	move.l	a3,a1
	bsr.s	SetEXPErr
	jmp	OutMsg

;Input:
;a0:error @
;a1:EXP @
SetEXPErr:
	movem.l	d0-d3/a0-a4,-(sp)
	move.l	a0,a4
	move.l	a1,a3
	move.l	EXP_lnb(a3),d0
	andi.l	#$ffffff,d0
	move.l	d0,MSG_lnb(a4)
	move.w	EXP_mod(a3),d0
	bsr.s	.getmod
	move.l	a0,MSG_mod(a4)
	move.l	a1,a0
	add.l	EXP_start(a3),a0
	bsr.s	.getsrc
	move.l	a0,MSG_ln(a4)
	movem.l	(sp)+,d0-d3/a0-a4
	rts

;In: d0=module #
;Out: a0=@MOD struct,a1=@src start
.getmod:	move.w	d0,d1
	bgt.s	.ok
	neg.w	d1
.ok:	move.l	FstModPtr,a0
	subq.w	#2,d1
	bmi.s	.fst
.l3:	move.l	MOD_next(a0),a0
	dbf	d1,.l3
.fst:	suba.l	a1,a1
	tst.w	d0
	ble.s	.end
	move.l	MOD_addr(a0),a1
.end:	rts

;remonte au debut de la ligne
;a0=@expr, a1=@debut du source
.getsrc:	moveq	#10,d1
	moveq	#13,d2
	move.w	#256,d3
.nxt:	cmp.l	a0,a1
	beq.s	.strt
	move.b	-(a0),d0
	cmp.b	d1,d0
	beq.s	.out
	cmp.b	d2,d0
	dbeq	d3,.nxt
.out:	addq.w	#1,a0
.strt:	rts

;  #] Patch Errors:
;  #[ Other errors & warnings:
Errgexp_ram:
Errlexp_ram:
	lea	patmsg,a0
	move.w	#MSG_FATL,MSG_flags(a0)
	move.w	#-expram_errno,MSG_no(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jmp	OutMsg
Errload_mod:
	move	#load_include_errno,d0
;	bra.s	patpfat
patpfat:	neg.w	d0
	lea	patmsg,a0
	move.w	#MSG_FATL,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	move.l	a3,a1
	bsr	SetEXPErr
	jmp	OutMsg

Warn_bitmod8:
	moveq	#bitmod8_warnno,d0
	bra.s	patpwarn
Warn_bitmod32:
	moveq	#bitmod32_warnno,d0
	bra.s	patpwarn
Warn_oddbranch:
	moveq	#oddbranch_warnno,d0
;	bra.s	patpwarn
patpwarn:	neg.w	d0
	lea	patmsg,a0
	move.w	#MSG_WARN,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	move.l	a3,a1
	bsr	SetEXPErr
	jmp	OutMsg

Opti_zbccb2nop:
	moveq	#zbccb2nop_warnno,d0
	move.w	WOptNopFlg,d1
	bra.s	patpopti
Opti_fwbcc2b:
	move.w	WOptFBccFlg,d1
	beq.s	patpopti
	bsr	SprintDisp
	moveq	#fwbcc2b_warnno,d0
	bra.s	patpopti
Opti_fwbcc2w:
	move.w	WOptFBccFlg,d1
	beq.s	patpopti
	bsr	SprintDisp
	moveq	#fwbcc2w_warnno,d0
;	bra.s	patpopti
patpopti:	addq.l	#1,OptiNb
	tst.w	d1
	bne.s	.msg
	rts
.msg:	neg.w	d0
	lea	patmsg,a0
	move.w	#MSG_OPTI,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	move.l	a3,a1
	bsr	SetEXPErr
	jmp	OutMsg

;  #] Other errors & warnings:
;  #[ Free Exprs:
FreeEXPs:	move.l	HeadLocExp,d1
	bsr.s	.free
	move.l	HeadExp,d1
.free:	beq.s	.out
.nx:	move.l	d1,a0
	move.l	HEAD_next(a0),d1
	jsr	MyMfree
	tst.l	d1
	bne.s	.nx
.out:	rts
;  #] Free Exprs:
;  #[ BLINDOS:
	IFNE	BLINDOS
	XREF	GloEval1,LocEval1
;remplacer l'appel a LocEval par cette routine
eval_loc:	move.b	EXP_eval(a3),d0
	bne	LocEval
	move.l	a2,-(sp)
	move.l	a0,a2
	bsr	LocEval1
	move.b	d1,-(sp)
	move.l	a2,a0
	bsr	LocEval
	cmp.b	(sp)+,d1
	bne.s	.err
	move.l	(sp)+,a2
	tst.l	d1
	rts
.err:	move.l	(sp)+,a2
	_Debugger

;remplacer l'appel a GloEval par cette routine
eval_glo:	move.b	EXP_eval(a3),d0
	bne	GloEval
	bsr	GloEval1
	move.b	d1,-(sp)
	bsr	GloEval
	cmp.b	(sp)+,d1
	bne.s	.err
	tst.l	d1
	rts
.err:	_Debugger
	ENDC	;BLINDOS
;  #] BLINDOS:
	BSS
;  #[ BSS:
HeadExp:		ds.l	1	;@ du premier descripteur
CurGloExp:	ds.l	1	;@ du descripteur courant
HeadLocExp:	ds.l	1	;@ du head descripteur local
CurLocExp:	ds.l	1	;@ du descripteur courant local
TotExpNb:		ds.l	1	;Total EXP #
LocRelNb:		ds.l	1	;Nb d'exps locales relogeables
GlobPatchFlag:	ds.b	1
LocPatchFlag:	ds.b	1
CurModule:	ds.w	1
patmsg:		ds.b	MSG_SIZEOF
BsdOffsets:	ds.l	4	;offsets for stupid BSD reloc
;  #] BSS:
	END


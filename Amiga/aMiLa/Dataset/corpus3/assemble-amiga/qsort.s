	XREF	IVarPError,VarPError
	XDEF	GetLocVar,GetGloVar,ForceLocVar,ForceGloVar,FindEqu
	XDEF	GetREquate,GetXref,BuildXdef,QsortV
	XDEF	GetEqur,GetEqur3
	XDEF	LocNb,VarNb,GloNb,LocTbl,GloTbl,CstLocTbl
	XDEF	EqusPtr,XrefTbl,XrefNb,XdefTbl,XdefNb
	XDEF	TxtVarNb,DatVarNb,BssVarNb,OffVarNb
	XDEF	icmpsort
	section	TEXT

QBLINDOS	EQU	1

;  #[ Create Start Variables:
CreateIntVars:
	lea	.t(pc),a2
.l1:	tst.l	(a2)
	beq.s	.end
	bsr	VarAlloc
	beq	.rmem
	move.l	d0,a1
	move.l	(a2)+,a0		;def string
	moveq	#0,d0
	move.b	(a0)+,d0
	move.l	a0,VAR_start(a1)
	move.w	d0,VAR_len(a1)
	move.l	(a2)+,VAR_value(a1)	;def value
	move.l	(a2)+,d0
	move.b	d0,VAR_type(a1)
	st	VAR_sec(a1)
	clr.w	VAR_mod(a1)
	clr.l	VAR_lnb(a1)
	move.l	(a2)+,d0
	beq.s	.noptr
	move.l	d0,a0
	move.l	a1,(a0)			;@ struct
.noptr:	move.l	a1,a0
	move.l	a2,-(sp)
	bsr	stock_equate
	move.l	(sp)+,a2
	bra.s	.l1
.end:	move.l	DbgTypePtr,a0
	move.w	DbgType,VAR_value+2(a0)
	move.l	SrcTypePtr,a0
	move.w	SrcType,VAR_value+2(a0)
	lea	MPUType,a1
	move.l	MPUTypePtr,a0
	move.w	(a1)+,VAR_value+2(a0)
	move.l	MMUTypePtr,a0
	move.w	(a1)+,VAR_value+2(a0)
	move.l	FPUTypePtr,a0
	move.w	(a1)+,VAR_value+2(a0)
	move.l	OutTypePtr,a0
	move.l	OutType,VAR_value(a0)
	rts
.rmem:	bra	Erreq_ram
.t:	dc.l	.asm,VERSION,EQU_EQU,0
	dc.l	.dbg,0,EQU_EQU,DbgTypePtr
	dc.l	.fpu,0,EQU_EQU,FPUTypePtr
	dc.l	.lk,0,EQU_EQU,OutTypePtr
	dc.l	.mmu,0,EQU_EQU,MMUTypePtr
	dc.l	.mpu,0,EQU_EQU,MPUTypePtr
	dc.l	.narg,0,EQU_EQU,MacStuff+MacNARGptr
	dc.l	.rs,0,EQU_SET,RsCountPtr
	dc.l	.src,0,EQU_EQU,SrcTypePtr
	dc.l	0
.asm:	dc.b	5,"__ASM"
.dbg:	dc.b	5,"__DBG"
.fpu:	dc.b	5,"__FPU"
.lk:	dc.b	4,"__LK"
.mmu:	dc.b	5,"__MMU"
.mpu:	dc.b	5,"__MPU"
.narg:	dc.b	4,"NARG"
.rs:	dc.b	4,"__RS"
.src:	dc.b	5,"__SRC"
;.time:	dc.b	6,"__TIME"
;.date:	dc.b	6,"__DATE"
;.file:	dc.b	6,"__FILE"
;.line:	dc.b	6,"__LINE"
	even

CreateDefVars:
	lea	DefBuf,a3
.l1:	move.l	a3,a2
	move.l	a3,a0
	moveq	#0,d5			;length
.l2:	move.b	(a0)+,d0
	bmi.s	.create
	beq.s	.end
	addq.w	#1,d5
	cmp.b	#'=',d0
	bne.s	.l2
	subq.w	#1,d5
.eval:	moveq	#1,d0
	jsr	ForEval
	bmi.s	.reval
	move.l	d0,d2			;value
	swap	d1
	move.w	d1,d0
	moveq	#EQU_EQU,d1
	tst.w	d0
	beq.s	.acreate
	bset	#VAR_MINUS,d1
.acreate:	st	d3			;section
	move.w	d5,d0			;length
	move.l	a2,a0			;name
	bsr	stock_rs
	bsr	stock_equate
.l3:	tst.b	(a3)+
	bgt.s	.l3
	tst.b	(a3)
	bne.s	.l1
.end:	rts
.create:	moveq	#1,d2
	moveq	#EQU_EQU,d1		;type
	bra.s	.acreate
.reval:	bra	ErrEv_prep
;  #] Create Start Variables: 
;  #[ Init_Var:
init_var:	bsr	FstVarAlloc
	move.w	#-1,CurBinNb	;init a -1 pour addq #1
	move.l	#VARL_SIZEOF+GLOBALS_PER_BLOCK*VAR_SIZEOF,d0
	bsr	MyMalloc
	beq.s	.errmem
	move.l	d0,a1
	moveq	#VARL_SIZEOF,d1
	add.l	d1,d0
	clr.l	VARL_next(a1)
	clr.w	VARL_nb(a1)
	move.l	d0,VARL_block(a1)
	move.l	a1,GloPtr

	move.l	#VARL_SIZEOF+LOCALS_PER_BLOCK*VAR_SIZEOF,d0		;50
	bsr	MyMalloc
	beq.s	.errmem
	move.l	d0,a1
	moveq	#VARL_SIZEOF,d1
	add.l	d1,d0
	clr.l	VARL_next(a1)
	clr.w	VARL_nb(a1)
	move.l	d0,VARL_block(a1)
	move.l	a1,LocPtr
	clr.l	EqusPtr
	clr.l	LocNb
	clr.l	GloNb
	clr.l	VarNb

	move.l	#LOCPTR_PER_BLOCK*4,d0
	bsr	MyMalloc
	move.l	d0,CstLocTbl
	move.l	d0,LocTbl
	beq.s	.errmem
	moveq	#0,d0
	rts
.errmem:	bra	Errglo_ram
;  #] Init_Var:
;  #[ Free Vars:
FreeLocals:
	movem.l	d0-d1/a0,-(sp)
	move.l	CstLocTbl,a0
;	move.l	#LOCPTR_PER_BLOCK*4,d0
	bsr	MyMfree
	move.l	LocPtr,d1
	beq.s	.end
.nx:	move.l	d1,a0
	move.l	VARL_next(a0),d1
;	move.l	#VARL_SIZEOF+LOCALS_PER_BLOCK*VAR_SIZEOF,d0		;50
	bsr	MyMfree
	tst.l	d1
	bne.s	.nx
.end:	movem.l	(sp)+,d0-d1/a0
	rts

FreeAllVars:
;tables de ptrs xref et xdef
	move.l	XdefTbl,d0
	beq.s	.noxdef
	move.l	d0,a0
	bsr	MyMfree
.noxdef:	move.l	XrefTbl,d0
	beq.s	.noxref
	move.l	d0,a0
	bsr	MyMfree
;blocks de ptrs xref et xdef
.noxref:	move.l	xrefs_ptr,d1
	bsr.s	.freevarlist
	move.l	xdefs_ptr,d1
	bsr.s	.freevarlist
;les variables allouees marginalement: macros,def-variables,xref-xdef
	bsr	FreeVars
;table de ptrs sur globales
	move.l	GloTbl,d0
	beq.s	.noglob
	move.l	d0,a0
	bsr	MyMfree
;les blocks d'equate
.noglob:	move.l	EqusPtr,d1
	bsr.s	.freevarlist
;les blocks de globales
	move.l	GloPtr,d1
	bsr.s	.freevarlist
	rts

.freevarlist:
	tst.l	d1
	beq.s	.out
.nx:	move.l	d1,a0
	move.l	VARL_next(a0),d1
	bsr	MyMfree
	tst.l	d1
	bne.s	.nx
.out:	rts
;  #] Free Vars:
;  #[ StockVar:	globale/locale
StockVar:	tst.b	loc_flag
	bne	stock_local

.asrc:	move.l	d3,-(sp)
	lea	length_variable,a0
	move.w	(a0),d0
	clr.w	(a0)
	moveq	#VAR_GLOB,d1
	move.l	SecSize,d2
	move.w	CurSecType,d3
	bmi.s	.stock
	lea	TxtVarNb,a0
	addq.l	#1,0(a0,d3.w)
.stock:	move.w	CurSection,d3
	move.l	start_variable,a0
	bsr	stock_global
	tst.w	SrcType
	bne.s	.src
.end:	move.l	(sp)+,d3
	rts
.src:	bsr	LinrAlloc			;gros bloc source
	bra.s	.end

;Garb:d0/a0/a1
stock_local:
	move.l	a2,-(sp)
	move.l	LocPtr,a2
.nxtbl: 	move.w	VARL_nb(a2),d0
	cmp.w	#LOCALS_PER_BLOCK,d0
	bne.s	.enough_room
	move.l	VARL_next(a2),d0
	beq.s	.this
	move.l	d0,a2
	bra.s	.nxtbl
.this:	bsr	alloc_local_block	;block plein -> creer suivant
	move.l	d0,VARL_next(a2)
	move.l	d0,a2
	move.w	VARL_nb(a2),d0
.enough_room:
	move.l	VARL_block(a2),a3
	mulu	#VAR_SIZEOF,d0		;nombre de vars dans le block
	lea	0(a3,d0.w),a0		;adresse ou stocker pointeur sur var

	move.l	start_variable,a1
	addq.w	#1,VARL_nb(a2)
	tst.w	VarRamFlg
	bne.s	.copy
.fast:	move.l	a1,VAR_start(a0)	;@ var
	lea	length_variable,a1
	move.w	(a1),VAR_len(a0)	;taille var
	clr.w	(a1)

	move.b	#VAR_LOC,VAR_type(a0)
	move.b	CurSection+1,VAR_sec(a0)
	move.l	SecSize,VAR_value(a0)
	move.w	CurModNb+2,VAR_mod(a0)	;module courant
	move.l	CurLNb,VAR_lnb(a0)
	addq.l	#1,LocNb
.end:	move.l	(sp)+,a2
	rts

.copy:	move.w	d2,-(sp)
	move.w	length_variable,d2
	move.w	d2,d0
	bsr	AllocString
	beq.s	.errram
	move.l	a0,-(sp)
	move.l	a1,a0
	move.l	d0,a1
	move.w	d2,d0
	STRNCPY
	sub.w	d2,a1
	move.l	(sp)+,a0
	move.w	(sp)+,d2
	bra.s	.fast
.errram:	move.w	(sp)+,d2
	bsr	Errloc_ram
	bra.s	.end

;  #] StockVar:
;  #[ Stock_global: (global, equ, equr, reg, set, rs, cargs, pargs).
;Input:
;a0:start_variable
;d0:length_variable
;d1:type
;d2:value
;d3:section

;In:
;a4:start_variable
;d2:value
;d3:section
;d4:length_variable
;d5:type

;Out:
;a0:adresse de la VAR

stock_global:
	jsr	end_locals
	addq.l	#1,GloNb
stock_rs:	movem.l	d3-d7/a2-a4,-(sp)
	move.l	a0,a4		;label start
	move.w	d0,d4		;label length
	move.w	d1,d5		;var type
	move.l	GloPtr,a2
.bl_loop:	move.w	VARL_nb(a2),d0
	cmp.w	#GLOBALS_PER_BLOCK,d0
	bne.s	.this
	move.l	VARL_next(a2),d0
	bne.s	.nxt_bl
	bsr	alloc_global_block	;block plein -> creer suivant
	move.l	d0,VARL_next(a2)
.nxt_bl:	move.l	d0,a2
	bra.s	.bl_loop

.this:	move.l	VARL_block(a2),a3
	mulu	#VAR_SIZEOF,d0
	lea	0(a3,d0),a0		;adresse de stockage de la variable
	move.l	a4,a1

	addq.w	#1,VARL_nb(a2)
	addq.l	#1,VarNb
	tst.w	VarRamFlg
	bne.s	.ramcopy
.fast:	move.l	a1,VAR_start(a0)	;@ var
	move.w	d4,VAR_len(a0)	;taille var
	move.b	d5,VAR_type(a0)
	move.b	d3,VAR_sec(a0)
.ok:	move.l	d2,VAR_value(a0)
	move.w	CurModNb+2,VAR_mod(a0)		;module courant
	move.l	CurLNb,VAR_lnb(a0)
	movem.l	(sp)+,d3-d7/a2-a4
	rts

.ramcopy:	move.w	d4,d0
	bsr	AllocString
	beq.s	.rram
	move.l	a0,-(sp)
	move.l	a1,a0
	move.l	d0,a1
	move.w	d4,d0
	STRNCPY
	sub.w	d4,a1
	move.l	(sp)+,a0
	bra.s	.fast
.rram:	bra	Errglo_ram

;  #] Stock_global:
;  #[ QsortL:
QsortL:	movem.l	d0/a0/a6,-(sp)
	lea	scmpsort(pc),a6	;case sensitive cmp
	tst.w	CaseFlg
	bne.s	.nocase
	lea	icmpsort(pc),a6	;case insensitive cmp
.nocase:	move.l	a1,a5		;routine de traitement d'egalite
	subq.l	#1,d0
	ble.s	.noerr
	add.l	d0,d0
	add.l	d0,d0
	move.l	a0,a3		;pointeur sur 1ere struct
	lea	0(a0,d0.l),a4	;pointeur sur last struct
	moveq	#-4,d6
	move.l	a3,d2
	move.l	a4,d3
	moveq	#0,d1
	bsr.s	.qsort1
	movem.l	(sp)+,d0/a0/a6
	tst.l	d1
	bne.s	.err
	rts
.noerr:	movem.l	(sp)+,d0/a0/a6
	rts
.err:	move.l	a5,d1
	bne	PMdef
	rts		;pas de routine d'egalite->pas de traitement
.qsort1:	move.l	d2,a3
	move.l	d3,a4

	move.l	a4,d4
	sub.l	a3,d4
	lsr.l	#1,d4
	and.l	d6,d4
	add.l	a3,d4
	move.l	d4,a0		;pointeur sur structure pivot

	move.l	(a0),a0		;adresse structure pivot
	move.w	VAR_len(a0),d4		;taille pivot
	move.l	VAR_start(a0),a2		;pointeur ascii pivot

	move.l	(a3),a0			;adresse struct
	cmp.w	VAR_len(a0),d4
	bls.s	.up2
.up_loop:	addq.w	#4,a3
.up:	move.l	(a3),a0			;adresse struct
	cmp.w	VAR_len(a0),d4
	bhi.s	.up_loop
.up2:	bne.s	.down

;sizes are the same: compare strings
	move	d4,d7
	subq	#1,d7
	move.l	VAR_start(a0),a1		;pointeur ascii variable
	cmp.l	a1,a2
	beq.s	.down
	move.l	a2,a0
	jsr	(a6)
	beq.s	.equup
	bhi.s	.down
	bra.s	.up_loop

.dn_loop:	subq.w	#4,a4
.down:	move.l	(a4),a0
	cmp.w	VAR_len(a0),d4
	blt.s	.dn_loop
	bne.s	.inv
;sizes are the same: compare strings
	move.w	d4,d7
	subq.w	#1,d7
	move.l	VAR_start(a0),a1		;pointeur ascii variable
	cmp.l	a1,a2
	beq.s	.inv
	move.l	a2,a0
	jsr	(a6)
	bhi.s	.dn_loop
	beq.s	.equdown
.inv:	cmpa.l	a4,a3
	bhi.s	.stop
	move.l	(a3),d0
	move.l	(a4),(a3)
	move.l	d0,(a4)
	addq.w	#4,a3
	subq.w	#4,a4
	cmpa.l	a4,a3
	ble.s	.up

.stop:	cmp.l	a4,d2
	bge.s	.remonte
	movem.l	d2-d3/a3,-(sp)
	move.l	a4,d3
	bsr	.qsort1
	movem.l	(sp)+,d2-d3/a3

.remonte:	cmp.l	d3,a3
	bge.s	.end
	movem.l	d2-d3,-(sp)
	move.l	a3,d2
	bsr	.qsort1
	movem.l	(sp)+,d2-d3
.end:	rts
.equup:	move.l	(a3),a0
	move.l	a5,d0
	beq.s	.down		;pas de routine d'egalite
	jsr	(a5)
	bra.s	.down
.equdown:	move.l	(a4),a0
	move.l	a5,d0
	beq.s	.inv		;pas de routine d'egalite
	jsr	(a5)
	bra.s	.inv

scmpsort:
.l1:	cmpm.b	(a0)+,(a1)+
	dbne	d7,.l1
	rts

icmpsort:	move.l	d1,-(sp)
	moveq	#0,d0
	moveq	#0,d1
.l1:	move.b	(a0)+,d0
	move.b	.t(pc,d0.w),d0
	move.b	(a1)+,d1
	move.b	.t(pc,d1.w),d1
	cmp.b	d0,d1
	dbne	d7,.l1
	movem.l	(sp)+,d1
	rts
	CASETAB

;  #] QsortL:
;  #[ QsortV:
QsortV:	movem.l	d3-d7/a2-a4,-(sp)
	subq.l	#1,d0
	ble.s	.noerr
	add.l	d0,d0
	add.l	d0,d0
	move.l	a0,a3		;pointeur sur 1ere struct
	lea	0(a0,d0.l),a4	;pointeur sur last struct
	moveq	#-4,d6
	move.l	a3,d2
	move.l	a4,d3
	moveq	#0,d1
	bsr	.qsort1
.noerr:	movem.l	(sp)+,d3-d7/a2-a4
	rts
.qsort1:	move.l	d2,a3
	move.l	d3,a4

	move.l	a4,d4
	sub.l	a3,d4
	lsr.l	#1,d4
	and.l	d6,d4
	add.l	a3,d4
	move.l	d4,a0		;pointeur sur structure pivot

	move.l	(a0),a0		;adresse structure pivot
	move.l	VAR_value(a0),d4	;valeur pivot

	move.l	(a3),a0		;adresse struct
	cmp.l	VAR_value(a0),d4
	bls.s	.up2
.upl1:	addq.w	#4,a3
.up:	move.l	(a3),a0		;adresse struct
	cmp.l	VAR_value(a0),d4
	bhi.s	.upl1
.up2:	bra.s	.down
.dnl1:	subq.w	#4,a4
.down:	move.l	(a4),a0
	cmp.l	VAR_value(a0),d4
	blt.s	.dnl1
.inv:	cmpa.l	a4,a3
	bhi.s	.stop
	move.l	(a3),d0
	move.l	(a4),(a3)
	move.l	d0,(a4)
	addq.w	#4,a3
	subq.w	#4,a4
	cmpa.l	a4,a3
	ble.s	.up

.stop:	cmp.l	a4,d2
	bge.s	.remonte
	movem.l	d2-d3/a3,-(sp)
	move.l	a4,d3
	bsr	.qsort1
	movem.l	(sp)+,d2-d3/a3

.remonte:	cmp.l	d3,a3
	bge.s	.end
	movem.l	d2-d3,-(sp)
	move.l	a3,d2
	bsr	.qsort1
	movem.l	(sp)+,d2-d3
.end:	rts

;  #] QsortV:
;  #[ Doubly defined error:
;Input:
;d5=tbl #
;a6=tbl @
;Output:
;d1:doubly var len
;d4:mdef #
;a1:doubly var @
;a3:start doubly @

;In:
;a0:array @
;a1:var name @
;a2:block @
;d1:name length
;d2:block var #
;Garb:None
pminit:	movem.l	d3/a3,-(sp)
	move.l	a0,a3
	move.l	d0,d3
	move.l	(a2)+,a0		;next doubly
	move.l	VAR_start(a0),a1	;var
	move.w	VAR_len(a0),d1
.l1:	move.l	(a3)+,a0		;scan var table
	cmp.w	VAR_len(a0),d1
	bne.s	.nxt1
	move.l	VAR_start(a0),a0
	move.w	d1,d0
	subq.w	#1,d0
	bsr	cmpmdef
	beq.s	.end		;1st name found
.nxt1:	subq.l	#1,d3
	bgt.s	.l1
	IFNE	QBLINDOS
	_Debugger
	ENDC	;QBLINDOS
.end:	move.l	a3,a0
	move.l	d3,d0
	movem.l	(sp)+,d3/a3
	rts

pmcnt:	movem.l	d3-d4/a3,-(sp)
	move.l	a0,a3
	move.l	d0,d3
	moveq	#-1,d4		;-1 for dbf, -1 for first print
	subq.l	#1,d3
.l1:	move.l	(a3)+,a0
	cmp.w	VAR_len(a0),d1
	bne.s	.end
	move.l	VAR_start(a0),a0
	move.w	d1,d0
	subq.w	#1,d0
	bsr	cmpmdef
	bne.s	.end
	addq.l	#1,d4
	subq.l	#1,d3
	bgt.s	.l1
.end:	move.l	d4,d0
	movem.l	(sp)+,d3-d4/a3
	rts

;In:
;a0=@ fst var
;d0=mdef var nb (-2)
pmsort:	movem.l	d1-d4/a1-a4,-(sp)
	move.l	a0,a3
	move.l	d0,d4
	move.l	d4,d3

.l1:	move.l	(a3)+,a0
	move.l	(a3),a1

	move.w	VAR_mod(a0),d0		;tri par module
	cmp.w	VAR_mod(a1),d0
	beq.s	.lnb
	blt.s	.nxt

	move.l	a0,(a3)
	move.l	a1,-4(a3)
	bra.s	.cmp
	
.lnb:	move.l	VAR_lnb(a0),d0		;et par # de ligne
	cmp.l	VAR_lnb(a1),d0
	ble.s	.nxt
	move.l	a0,(a3)
	move.l	a1,-4(a3)

.cmp:	cmp.w	d4,d3
	beq.s	.nxt
	subq.w	#8,a3
	addq.w	#2,d4
.nxt:	dbf	d4,.l1
	movem.l	(sp)+,d1-d4/a1-a4
	rts

;In:
;d2:mdef head #
;d3:cur var #
;d4:mdef #
;d5:tot var #
;a2:mdef head @
;a3:cur var @
;a4:mdef @
;a6:head var @
PMdef:	movem.l	d2-d5/a2-a4/a6,-(sp)
	move.l	d0,d5		;nombre d'elements de la table
	move.l	a0,a6		;pointeur sur table de pointeur triee

	move.l	DoublyPtr,a4	;struct mdef
.nextbl:	move.l	VARL_block(a4),a2
	move.w	VARL_nb(a4),d2
	subq.w	#1,d2
	bmi.s	.err

.nextvar:	move.l	d5,d0		;reinit var tbl
	move.l	a6,a0
	bsr	pminit		;init a0,d0
	move.l	a0,a3		;first var
	bsr	pmcnt		;init d1
	move.l	d0,d4		;same vars #
	subq.w	#4,a3
	move.l	a3,a0
	bsr	pmsort

	move.l	(a3)+,a0
	move.l	d4,d0
	addq.l	#2,d0
	jsr	IVarPError	;affichage message 1+2

.l1:	move.l	(a3)+,a0
	jsr	VarPError		;affichage message 2
	dbf	d4,.l1
	dbf	d2,.nextvar
	move.l	VARL_next(a4),d0
	move.l	d0,a4
	bne.s	.nextbl

.free:	move.l	DoublyPtr,d2
.l2:	move.l	d2,a0
	move.l	VARL_next(a0),d2
	bsr	MyMfree
	tst.l	d2
	bne.s	.l2
.allfree:	clr.l	DoublyPtr
	movem.l	(sp)+,d2-d5/a2-a4/a6
	rts
	IFNE	QBLINDOS
.err:	_Debugger
	ENDC	;QBLINDOS
	bra.s	.allfree

;In:
;a0=new var
;a1=start var
;d1=length var
;Garb:d0,a0
cmpmdef:	tst.w	CaseFlg
	beq.s	.case
	move.l	a1,-(sp)
.l1:	cmpm.b	(a0)+,(a1)+
	dbne	d0,.l1
	move.l	(sp)+,a1
	rts
.case:	movem.l	d1-d2/a1,-(sp)
	moveq	#0,d2
	moveq	#0,d1
.l2:	move.b	(a0)+,d2
	move.b	.t(pc,d2.w),d2
	move.b	(a1)+,d1
	move.b	.t(pc,d1.w),d1
	cmp.b	d2,d1
	dbne	d0,.l2
	movem.l	(sp)+,d1-d2/a1
	rts
	CASETAB

;  #] Doubly defined error:
;  #[ Find_Global:
RECHERCHE_REG	REG	d2-d7/a2-a4
;In:
;a0.l:@ var string
;d0.w:strlen
;Out:
;d0.l:var #
;a1.l/d1.l:@ structure (NULL if nf)
find_global:
	movem.l	RECHERCHE_REG,-(sp)
	lea	scmpsrch(pc),a4
	tst.w	CaseFlg
	bne.s	.nocase
	lea	icmpsrch(pc),a4
.nocase:	move.l	VarNb,d5
	subq.l	#1,d5
	ble.s	.one

	move.w	d0,d1
	subq.w	#1,d1

	IFNE	_68000
	asl.w	#4,d0
	lea	glob_table,a2
	add.w	d0,a2
	ELSEIF
	add.w	d0,d0
	lea	(glob_table.l,d0.w*8),a2
	ENDC	;_68000
	move.l	(a2)+,a1
	move.l	(a2)+,d7
	bmi.s	.nofound
	move.l	(a2)+,d3		;# anterieur

	moveq	#0,d5
	moveq	#-4,d6
	bra.s	.boucle

.moins:	move.l	d4,d7
	add.l	d6,d7		;sub.l	#4,d7
	bmi.s	.nofound

.boucle:	move.l	d5,d4
	add.l	d7,d4
	lsr.l	#1,d4
	and.l	d6,d4

	move.l	0(a1,d4.l),a2	;pointeur sur struct
	move.l	VAR_start(a2),a2
	move.l	a0,a3
	move.w	d1,d0
	jsr	(a4)
	bmi.s	.moins
.plus:	beq.s	.found
	move.l	d4,d5
	sub.l	d6,d5		;add.l	#4,d5
	cmp.l	d7,d5
	bls.s	.boucle

.nofound:	moveq	#0,d1
	movem.l	(sp)+,RECHERCHE_REG
	rts

.found:	move.l	0(a1,d4.l),a1	;pointeur sur struct
.asfound:	move.l	d4,d0
	add.l	d3,d0
	lsr.l	#2,d0		;var #
	move.l	a1,d1
	movem.l	(sp)+,RECHERCHE_REG
	rts

.one:	bmi.s	.nofound
	moveq	#0,d4		;var #
	moveq	#0,d3		;prev var #
	move.l	GloPtr,a1
	move.l	VARL_block(a1),a1
	cmp.w	VAR_len(a1),d0
	bne.s	.nofound
	move.l	(a1),a2
	move.l	a0,a3
	subq.w	#1,d0
	jsr	(a4)
	beq.s	.asfound
	bra.s	.nofound

scmpsrch:
.l1:	cmpm.b	(a2)+,(a3)+
	dbne	d0,.l1
	rts

icmpsrch:	movem.l	d1-d2,-(sp)
	moveq	#0,d2
	moveq	#0,d1
.l1:	move.b	(a2)+,d2
	move.b	.t(pc,d2.w),d2
	move.b	(a3)+,d1
	move.b	.t(pc,d1.w),d1
	cmp.b	d2,d1
	dbne	d0,.l1
	movem.l	(sp)+,d1-d2
	rts
	CASETAB

;  #] Find_Global:
;  #[ GetXref:
;In:
;a0.l=variable string
;d0.w=label length
;Out:
;a1.l=@ xref (NULL if not found)
;d0.l=xref nb
;Garb:d2
GetXref:			;eval,evalone
;  #] GetXref:
;keep tight
;  #[ Find_Xref:
;In:
;a0.l:@ var string
;d0.w:  strlen
;Out:ccr!=0+a1.l+d1.l
find_xref:
  	move.l	XrefTbl,a1
	move.l	XrefNb,d1
	bra	find_dicho
;  #] Find_Xref:
;  #[ Find_Local:
;In:
;a0.l:@ var string
;d0.w:strlen
;Out:
;a1.l/d1.l:@ structure (NULL if nf)
find_local:
  	move.l	LocTbl,a1
	move.l	LocNb,d1
;	bra	find_dicho
;  #] Find_Local:
;  #[ Find_dicho:
;In:
;a0.l:@ var string
;d0.w:  strlen
;a1.l:@ table de longs
;d1.l:  nombre de structs dans la table
;Out:ccr!=0+a1.l+d1.l+d0.l
find_dicho:
	movem.l	RECHERCHE_REG,-(sp)
	lea	scmpsrch(pc),a4
	tst.w	CaseFlg
	bne.s	.nocase
	lea	icmpsrch(pc),a4
.nocase:	move.l	d1,d7
	subq.l	#1,d7
	ble.s	.one
	move.w	d0,d2
	move.w	d0,d1
	subq.w	#1,d1

	moveq	#0,d5
	add.l	d7,d7
	add.l	d7,d7
	moveq	#-4,d6

.boucle:	move.l	d5,d4
	add.l	d7,d4
	lsr.l	#1,d4
	and.l	d6,d4

	move.l	0(a1,d4.l),a2
	cmp.w	VAR_len(a2),d2
	blt.s	.moins
	beq.s	.same

.plus:	move.l	d4,d5
	sub.l	d6,d5		;add.l	#4,d5
	cmp.l	d7,d5
	bls.s	.boucle
	bra.s	.nofound

.same:	move.l	VAR_start(a2),a2		;pointeur ascii variable
	move.l	a0,a3
	move.w	d1,d0
	jsr	(a4)
	bhi.s	.plus
	beq.s	.found
.moins:	move.l	d4,d7
	add.l	d6,d7		;sub.l	#4,d7
	bge.s	.boucle

.nofound:	moveq	#0,d1
	movem.l	(sp)+,RECHERCHE_REG
	rts

.found:	move.l	d4,d0
	lsr.l	#2,d0		;xref #
	move.l	0(a1,d4.l),a1	;adresse de la structure cherchee
.asfound:	move.l	a1,d1
	movem.l	(sp)+,RECHERCHE_REG
	rts

.one:	bmi.s	.nofound
	move.l	(a1),a1
	cmp.w	VAR_len(a1),d0
	bne.s	.nofound
	move.l	VAR_start(a1),a2		;pointeur ascii variable
	move.l	a0,a3
	subq.w	#1,d0
	jsr	(a4)
	bne.s	.nofound
	moveq	#0,d0
	bra.s	.asfound
;  #] Find_dicho:
;  #[ GetGloVar:
;** Machine dependent ! **
;In:
;a0.l=variable string
;d0.w=label length
;Out:
;a1.l=@ var (NULL if not found)
;d0.l=var value
;d1.b=var sec
;Garb:d2
GetGloVar:
	bsr	find_global
	beq.s	.nf
	move.l	d0,d1
	move.l	VAR_value(a1),d0
	swap	d1
	IFNE	AMIGA
	clr.w	d1
	move.b	VAR_sec(a1),d1
	move.l	a1,d2
.nf:	rts
	ENDC	;AMIGA
	IFNE	ATARI
	clr.w	d1
	move.b	VAR_sec(a1),d1
	ble.s	.end		;offset+text
	tst.w	OutType+2		;if obj, keep section & @
	bne.s	.end
	subq.b	#SEC_data,d1	;if prg clr section & add @
	beq.s	.data
.bss:	add.l	DataSize,d0
.data:	add.l	TextSize,d0
				;moveq	#0,d1
.end:	move.l	a1,d2
.nf:	rts
	ENDC	;ATARI
;  #] GetGloVar:
;  #[ GetLocVar:
;** Machine dependent ! **
;In:
;a0.l=variable string
;d0.w=label length
;Out:
;a1.l=@ var (NULL if not found)
;d0.l=var value
;d1.b=var sec
;Garb:d2
GetLocVar:
	bsr	find_local
	beq.s	.nf
	move.l	VAR_value(a1),d0
	moveq	#0,d1
	tst.w	OutType+2
	bne.s	.end
	move.b	VAR_sec(a1),d1
.end:	move.l	a1,d2
.nf:	rts
;  #] GetLocVar:
;  #[ ForceVar:
SEQSEARCH_REG	REG	d2/a2-a5
XSEQSEARCH_REG	REG	d2/a2-a6
ForceXRef:
	movem.l	XSEQSEARCH_REG,-(sp)
	move.l	xrefs_ptr,a1
	move.l	XrefNb,d1
;pareil que _seq sauf que la table contient des pointeurs
	beq.s	.nf
	lea	scmpsrch(pc),a5
	tst.w	CaseFlg
	bne.s	.nocase
	lea	icmpsrch(pc),a5
.nocase:
	move.w	d0,d2
.next_block:
 	move.w	VARL_nb(a1),d1
	beq.s	.nf			;a cause des locales
	move.l	VARL_block(a1),a6

.l1:	move.l	(a6)+,a4
	cmp.w	VAR_len(a4),d2
	bne.s	.nxt
	move.l	a0,a2
	move.l	VAR_start(a4),a3
	move.w	d2,d0
	subq.w	#1,d0
	jsr	(a5)
	beq.s	.found
.nxt:	subq.w	#1,d1
	bgt.s	.l1
	move.l	VARL_next(a1),d1
	beq.s	.nf
	move.l	d1,a1
	bra.s	.next_block
.nf:	moveq	#0,d1
	movem.l	(sp)+,XSEQSEARCH_REG
	rts
.found:	move.l	a4,d1
	move.l	a4,a1
	movem.l	(sp)+,XSEQSEARCH_REG
	rts

locseqsearch:
	movem.l	SEQSEARCH_REG,-(sp)
	move.l	LocPtr,a1
	move.l	LocNb,d1
	bra.s	_seq

gloseqsearch:
	movem.l	SEQSEARCH_REG,-(sp)
	move.l	GloPtr,a1
	move.l	GloNb,d1
_seq:	beq.s	.nf
	lea	scmpsrch(pc),a5
	tst.w	CaseFlg
	bne.s	.nocase
	lea	icmpsrch(pc),a5
.nocase:
	move.w	d0,d2
.next_block:
 	move.w	VARL_nb(a1),d1
	beq.s	.nf			;a cause des locales
	move.l	VARL_block(a1),a4

.l1:	cmp.w	VAR_len(a4),d2
	bne.s	.nxt
	move.l	a0,a2
	move.l	VAR_start(a4),a3
	move.w	d2,d0
	subq.w	#1,d0
	jsr	(a5)
	beq.s	.found
.nxt:	lea	VAR_SIZEOF(a4),a4
	subq.w	#1,d1
	bgt.s	.l1
	move.l	VARL_next(a1),d1
	beq.s	.nf
	move.l	d1,a1
	bra.s	.next_block
.nf:	moveq	#0,d1
	movem.l	(sp)+,SEQSEARCH_REG
	rts
.found:	move.l	a4,d1
	move.l	a4,a1
	movem.l	(sp)+,SEQSEARCH_REG
	rts

;In:
;a0.l=variable string
;d0.w=label length
;Out:
;a1.l=@ var (NULL if not found)
;d0.l=var value
;Garb:d1/a1
ForceLocVar:
	bsr.s	locseqsearch
	bra.s	_force

;In:
;a0.l=variable string
;d0.w=label length
;Out:
;a1.l=@ var (NULL if not found)
;d0.l=var value
;Garb:d1/a1
ForceGloVar:
	bsr.s	gloseqsearch
_force:	beq.s	.end
	move.l	VAR_value(a1),d0
	move.l	a1,d1
.end:	rts
;  #] ForceVar:
;  #[ Create xref table:
create_xref_table:
	tst.w	OutType+2
	bne.s	.link
.none:	rts			;skip xref if executable
.link:	move.l	XrefNb,d0
	beq.s	.none
	move.l	XrefTbl,d1
	beq.s	.alloc
	bsr	.free
.alloc:	add.l	d0,d0
	add.l	d0,d0
	bsr	MyMalloc
	beq	Errxref_ram
	move.l	d0,XrefTbl
	move.l	d0,a0
	move.l	xrefs_ptr,a1
.bl_loop:
	move.l	VARL_block(a1),a2
	move.w	VARL_nb(a1),d7
	subq.w	#1,d7
.l1:	move.l	(a2)+,(a0)+
	dbf	d7,.l1
	move.l	VARL_next(a1),d1
	beq.s	.no_more
	move.l	d1,a1
	bra.s	.bl_loop

.no_more:	tst.l	GloNb
	beq.s	.sort
	move.l	XrefTbl,a3
	move.l	XrefNb,d7
.verloop:
	move.l	(a3)+,a1
	move.l	VAR_start(a1),a0
	move.w	VAR_len(a1),d0
	bsr	find_global
	beq.s	.nf
	move.l	-4(a3),a0
	moveq	#2,d0
	jsr	IVarPError
.nf:	subq.l	#1,d7
	bgt.s	.verloop
.sort:	move.l	XrefTbl,a0
	move.l	XrefNb,d0
	suba.l	a1,a1		;pas d'erreur
	bra	QsortL

.free:	move.l	d0,-(sp)
	move.l	d1,a0
	bsr	MyMfree
	clr.l	XrefTbl
	move.l	(sp)+,d0
	rts
;  #] Create xref table:
;  #[ Create xdef table:
;
; Appeler quand besoin; cree une liste de pointeur sur les structures XDEF
; a exporter dans XdefTbl
;
BuildXdef:
	tst.w	OutType+2
	bne.s	.link
.none:	rts
.rram:	bra	Errxdef_ram
.link:	move.l	XdefNb,d0
	beq.s	.none
	movem.l	d3-d4/d7/a2-a6,-(sp)
	lea	scmpsrch(pc),a6
	tst.w	CaseFlg
	bne.s	.nocase
	lea	icmpsrch(pc),a6
.nocase:	add.l	d0,d0
	add.l	d0,d0
	bsr	MyMalloc
	beq.s	.rram
	move.l	d0,XdefTbl
	move.l	d0,a0
	moveq	#0,d3		;real xdef nb
	move.l	xdefs_ptr,d1
.bl_loop:	move.l	d1,a1
	move.l	VARL_block(a1),a4
	move.w	VARL_nb(a1),d7
	subq.w	#1,d7
.l1:	move.l	(a4)+,a5
	bsr	.cmpxdef
	beq.s	.next		;double def skippe
	move.l	a5,(a0)+
	addq.l	#1,d3
.next:	dbf	d7,.l1
	move.l	VARL_next(a1),d1
	bne.s	.bl_loop

	move.l	d3,XdefNb		;real xdef nb
	move.l	XdefTbl,a3
.verloop:	move.l	(a3),a1
	move.l	VAR_start(a1),a0
	move.w	VAR_len(a1),d0
	bsr	find_global
	beq.s	.nf
	move.l	a1,(a3)+
	bset	#VAR_DEFED,VAR_type(a1)	;defined
.nxt:	subq.l	#1,d3
	bgt.s	.verloop
	movem.l	(sp)+,d3-d4/d7/a2-a6
	rts

.nf:	move.l	(a3)+,a1
	lea	premsg,a0
	clr.w	MSG_flags(a0)
	move.w	#-xdef_undef_errno,MSG_no(a0)
	clr.w	MSG_len(a0)
	move.l	VAR_lnb(a1),MSG_lnb(a0)
	clr.l	MSG_ln(a0)		;a changer un jour
	move.w	VAR_mod(a1),d0
	move.l	FstModPtr,a1
	subq.w	#2,d0
	bmi.s	.this
.l2:	move.l	MOD_next(a1),a1
	dbf	d0,.l2
.this:	move.l	a1,MSG_mod(a0)
	jsr	OutMsg
	bra.s	.nxt

.cmpxdef:	movem.l	a0-a5,-(sp)
	move.w	d3,d4
	subq.w	#1,d4
	bmi.s	.nosame
	move.w	VAR_len(a5),d2
	move.l	VAR_start(a5),a4
	move.l	XdefTbl,a5
.cmploop:	move.l	(a5)+,a3		;comparer tout a5+[d4] avec d0 (et a4 si besoin)
	cmp.w	VAR_len(a3),d2
	bne.s	.papa
	move.l	VAR_start(a3),a3
	move.w	d2,d0
	subq.w	#1,d0
	move.l	a4,a2
	jsr	(a6)
	beq.s	.pabon
.papa:	dbf	d4,.cmploop
.nosame:	moveq	#-1,d0
.pabon:	movem.l	(sp)+,a0-a5
	rts
;  #] Create xdef table:
;  #[ Create locals table:
create_locals_table:
	movem.l	d0-d2/d7/a0-a2,-(sp)
	move.l	LocNb,d0
	beq.s	.end
	move.l	LocPtr,a1
	tst.l	VARL_nb(a1)
	beq.s	.end	;table deja triee, block free
	cmp.l	#LOCPTR_PER_BLOCK,d0
	bhi.s	.alloc
.got:	move.l	LocTbl,a0
	move.l	LocPtr,a1
	moveq	#VAR_SIZEOF,d2
.bl_loop:
	move.l	VARL_block(a1),a2
	move.w	VARL_nb(a1),d7
	beq.s	.end
	subq.w	#1,d7
.l1:	move.l	a2,(a0)+
	add.w	d2,a2
	dbf	d7,.l1
	clr.w	VARL_nb(a1)		;pour future reutilisation
	move.l	VARL_next(a1),d1
	beq.s	.end
	move.l	d1,a1
	bra.s	.bl_loop
.end:	movem.l	(sp)+,d0-d2/d7/a0-a2
	rts
.alloc:	add.l	d0,d0
	add.l	d0,d0
	bsr	MyMalloc
	move.l	d0,LocTbl
	bne.s	.got
	bra	Errloct_ram

	IFNE	0	;si IFD trie
;pareil que create_locals_table mais sans les clr.w VARL_nb
createl2:
	movem.l	d0-d2/d7/a0-a2,-(sp)
	move.l	LocNb,d0
	beq.s	.no_more
	cmp.l	#LOCPTR_PER_BLOCK,d0
	bhi.s	.alloc
.got:	move.l	LocTbl,a0
	move.l	LocPtr,a1
	moveq	#VAR_SIZEOF,d2
.bl_loop:
	move.l	VARL_block(a1),a2
	move.w	VARL_nb(a1),d7
	beq.s	.no_more
	subq.w	#1,d7
.l1:	move.l	a2,(a0)+
	add.w	d2,a2
	dbf	d7,.l1
	move.l	VARL_next(a1),d1
	beq.s	.no_more
	move.l	d1,a1
	bra.s	.bl_loop
.no_more:	movem.l	(sp)+,d0-d2/d7/a0-a2
	rts
.alloc:	add.l	d0,d0
	add.l	d0,d0
	bsr	MyMalloc
	move.l	d0,LocTbl
	bne.s	.got
	bra	Errloct2_ram
	ENDC	;0
;  #] Create locals table:
;  #[ Create globals table:
create_globals_table:
	movem.l	d2/d3/d7-a2,-(sp)
	move.l	GloNb,d0
	beq.s	.no_more
	move.l	GloTbl,d1
	bne.s	.fr_prev
.alloc:	add.l	d0,d0
	add.l	d0,d0
	bsr	MyMalloc
	beq	Errglot_ram
	move.l	d0,GloTbl
	move.l	d0,a0
	move.l	GloPtr,a1
	moveq	#VAR_SIZEOF,d2
	moveq	#VAR_GLOB,d3
.bl_loop:	move.l	VARL_block(a1),a2
	move.w	VARL_nb(a1),d7
	subq.w	#1,d7
	bmi.s	.nxbl
.l1:	cmp.b	VAR_type(a2),d3	;ne compter que les globales
	bne.s	.nx
	move.l	a2,(a0)+
.nx:	add.w	d2,a2
	dbf	d7,.l1
.nxbl:	move.l	VARL_next(a1),d1
	beq.s	.no_more
	move.l	d1,a1
	bra.s	.bl_loop
.no_more:	movem.l	(sp)+,d2/d3/d7-a2
	rts
.fr_prev:	move.l	d0,-(sp)
	move.l	d1,a0
	bsr	MyMfree
	move.l	(sp)+,d0
	bra.s	.alloc
;  #] Create globals table:
;  #[ Create vars table:
create_vars_table:
	movem.l	d2/d7-a2,-(sp)
	move.l	VarNb,d0
	beq.s	.no_more
	move.l	GloTbl,d1
	bne.s	.fr_prev
.alloc:	add.l	d0,d0
	add.l	d0,d0
	bsr	MyMalloc
	beq	Errglot_ram
	move.l	d0,GloTbl
	move.l	d0,a0
	move.l	GloPtr,a1
	moveq	#VAR_SIZEOF,d2
.bl_loop:	move.l	VARL_block(a1),a2
	move.w	VARL_nb(a1),d7
	subq.w	#1,d7
	bmi.s	.nxbl
.l1:	move.l	a2,(a0)+
	add.w	d2,a2
	dbf	d7,.l1
.nxbl:	move.l	VARL_next(a1),d1
	beq.s	.no_more
	move.l	d1,a1
	bra.s	.bl_loop
.no_more:	movem.l	(sp)+,d2/d7-a2
	rts
.fr_prev:	move.l	d0,-(sp)
	move.l	d1,a0
	bsr	MyMfree
	move.l	(sp)+,d0
	bra.s	.alloc
;  #] Create vars table:
;  #[ Create_sizes_table:
;In: d0=nb d'elems
;Garb:d0-d4/a0-a1
create_sizes_table:
	moveq	#0,d4		;prev #
	move.l	d0,d3
	subq.l	#1,d3
	bmi	.end
	move.l	GloTbl,a0		;table triee
	lea	glob_table,a1	;table par taille pour recherche

	moveq	#0,d1		;strlen
	moveq	#-1,d0
	move.l	(a0),a2
.l1:	cmp.w	VAR_len(a2),d1
	beq.s	.found
	addq.w	#4,a1		;@
	move.l	d0,(a1)+		;#
	move.l	d4,(a1)+		;tot #
	addq.w	#4,a1		;dummy
.nxt:	addq.b	#1,d1
	bcc.s	.l1
	bra.s	.end

.found:	move.l	a0,(a1)+		;@
	moveq	#0,d2		;#
.l2:	subq.l	#1,d3
	bcs.s	.stop
	addq.w	#4,a0
	move.l	(a0),a2
	cmp.w	VAR_len(a2),d1
	bne.s	.plusun
	addq.l	#4,d2
	bra.s	.l2
.plusun:	move.l	d2,(a1)+		;#
	move.l	d4,(a1)+
	addq.l	#4,d4
	add.l	d2,d4
	addq.w	#4,a1
	bra.s	.nxt

.stop:	move.l	d2,(a1)+		;#
	move.l	d4,(a1)+
	addq.l	#4,d4
	add.l	d2,d4
	addq.w	#4,a1
.endloop:	addq.b	#1,d1
	bcs.s	.end
	addq.w	#4,a1		;@
	move.l	d0,(a1)+		;#
	move.l	d4,(a1)+
	addq.w	#4,a1
	bra.s	.endloop
.end:	rts
;  #] Create_sizes_table:
;  #[ Stock equate & macro:
;In:
;a0.l=@ struct EQUATE a stocker
stock_macro:
	move.l	macs_ptr,d0
	bne.s	stock_prep
	move.l	a0,a2
	bsr	alloc_equ_block		;creation d'un bloc de pointeurs
	move.l	d0,macs_ptr
	move.l	d0,a3
	addq.w	#1,EQUL_nb(a3)
	move.l	EQUL_block(a3),a1
	move.l	a2,(a1)
	rts

stock_equate:
	addq.l	#1,TotEquNb
	move.l	EqusPtr,d0
	bne.s	stock_prep
	move.l	a0,a2
	bsr	alloc_equ_block		;creation d'un bloc de pointeurs
	move.l	d0,EqusPtr
	move.l	d0,a1			;a3->a1 AL
	addq.w	#1,EQUL_nb(a1)
	move.l	EQUL_block(a1),a1
	move.l	a2,(a1)
	rts

PUT_EQU	MACRO
	add.w	d4,d4
	add.w	d4,d4
	move.l	EQUL_block(a3),a1
	move.l	a2,0(a1,d4.w)
	ENDM

;In:
;d0.l=@ de base du tableau chaine (non nul)
;a0=@struct var stockee in glo variable
stock_prep:
	movem.l	d3-d7/a2-a5,-(sp)
	move.l	a0,a2
	lea	scmpequ(pc),a5
	tst.w	CaseFlg
	bne.s	.search_block
	lea	icmpequ(pc),a5
.search_block:
	move.l	d0,a3
	move.l	EQUL_block(a3),a1
	move.w	EQUL_nb(a3),d0	;!=0
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a1,d0.w),a0
	jsr	(a5)
	beq	.double_defined
	blo.s	.block_found
	move.l	EQUL_next(a3),d0
	bne.s	.search_block
;inserer derriere le dernier element du dernier block
	move.w	EQUL_nb(a3),d4
	cmp.w	#EQUS_PER_BLOCK,d4
	bne.s	.enough_room
;block plein -> creer suivant
	bsr	alloc_equ_block
	move.l	d0,EQUL_next(a3)
	move.l	d0,a4
	move.l	EQUL_block(a4),a1
	move.l	a2,(a1)
	addq.w	#1,EQUL_nb(a4)
	bra	.good
.enough_room:
	add.w	d4,d4
	add.w	d4,d4
	move.l	EQUL_block(a3),a1
	move.l	a2,0(a1,d4.w)
	addq.w	#1,EQUL_nb(a3)
	bra	.good
.block_found:
;a3=@ block ou faire la dichotomie
	move.l	EQUL_block(a3),a4
	move.w	EQUL_nb(a3),d7
	subq.w	#1,d7
	moveq	#0,d5
	moveq	#-4,d6
	add.w	d7,d7		;*sizeof(long)
	add.w	d7,d7		;*sizeof(long)
.boucle:
	move.w	d5,d4
	add.w	d7,d4
	lsr.w	#1,d4		;*sizeof(long) et div 2
	and.w	d6,d4
	move.l	0(a4,d4.w),a0
	jsr	(a5)
	beq	.double_defined
	blo.s	.moins
;.plus
	addq.w	#4,d4
	move.w	d4,d5
	cmp.w	d5,d7
	bge.s	.boucle
	bra.s	.found
.moins:
	subq.w	#4,d4
	move.w	d4,d7
	cmp.w	d5,d7
	bge.s	.boucle
	addq.w	#4,d4
;d4=indice d'insertion
.found:
	lsr.w	#2,d4		;reajuster en indice
.got_d4:
	cmp.w	#EQUS_PER_BLOCK,EQUL_nb(a3)
	bne.s	.not_full
;le bloc d'insertion est plein
	move.l	EQUL_next(a3),d0
	bne.s	.next_exists
;et c'est le dernier -> creer un block suivant
	bsr	alloc_equ_block
	move.l	d0,EQUL_next(a3)
	move.l	d0,a4
.not_last_elt:
;mettre dernier elt du bloc a3 ds bloc a4
	move.l	EQUL_block(a3),a0
	move.l	EQUL_block(a4),a1
	move.l	4*(EQUS_PER_BLOCK-1)(a0),(a1)
	addq.w	#1,EQUL_nb(a4)
;decaler block a3 de l'indice d'insertion a la fin
;	move.l	EQUL_block(a3),a0
	move.w	d4,d0
	move.w	EQUL_nb(a3),d1
	subq.w	#1,d1
	bsr	decale_equs
;et placer l'equate
	PUT_EQU
	bra.s	.good
;a3=block courant plein, d0=@block suivant
.next_exists:
	move.l	d0,a4
	cmp.w	#EQUS_PER_BLOCK,EQUL_nb(a4)
	bne.s	.next_not_full
;inserer un block entre les 2
	bsr	alloc_equ_block
	move.l	d0,EQUL_next(a3)
	move.l	d0,a0
	move.l	a4,EQUL_next(a0)
	move.l	a0,a4
	bra.s	.not_last_elt
	
.next_not_full:
;decaler le suivant
	moveq	#0,d0
	move.w	EQUL_nb(a4),d1
	move.l	EQUL_block(a4),a0
	bsr.s	decale_equs
	bra.s	.not_last_elt
.not_full:
	move.w	d4,d0
	move.w	EQUL_nb(a3),d1
	move.l	EQUL_block(a3),a0
	bsr.s	decale_equs
	PUT_EQU
	addq.w	#1,EQUL_nb(a3)
.good:	moveq	#0,d0
.end:	movem.l	(sp)+,d3-d7/a2-a5
	rts
.err:	moveq	#-1,d0
	bra.s	.end
;a2 a inserer, a0 trouve
.double_defined:
	move.b	VAR_type(a2),d0
	bclr	#7,d0		;signe
	move.b	VAR_type(a0),d1
	bclr	#7,d1		;signe
	subq.b	#EQU_SET,d0	;verif set
	bne.s	.no_set
	subq.b	#EQU_SET,d1	;verif set
	bne.s	.r2equ		;redef equ par set
;changer la valeur de la set-variable
	move.l	VAR_value(a2),VAR_value(a0)
	subq.l	#1,TotEquNb
	bra.s	.good
.no_set:	sub.b	#EQU_MACRO-EQU_SET,d0	;redef macro par macro
	beq.s	.rmacmdef
;c'est donc un equate
	subq.b	#EQU_GLOB,d1	;pas set donc eq
	bmi.s	.requmdef
	bsr	Errlabel_set	;redef set par equ
	bra.s	.err
.r2equ:	bsr	Errlabel_equ
	bra.s	.err
.rmacmdef:
	bsr	Errmac_mdef
	bra.s	.err
.requmdef:
	bsr	Errequ_mdef
	bra.s	.err

;put_equ:	add.w	d4,d4
;	add.w	d4,d4
;	move.l	EQUL_block(a3),a1
;	move.l	a2,0(a1,d4.w)
;	rts

;In:
;a0.l=@ block d'equs
;d0.w=indice de depart
;d1.w=indice de fin (non inclus)
decale_equs:
;	move.w	d2,-(sp)
	move.w	d1,d2
	sub.w	d0,d2
	add.w	d1,d1
	add.w	d1,d1
	lea	4(a0,d1.w),a1
	lea	-4(a1),a0
	bra.s	.db
;tower ?
.cp:	move.l	-(a0),-(a1)
.db:	dbf	d2,.cp
;	move.w	(sp)+,d2
	rts
	
;In: a0,a2 structs equate a0 ref,a2 a inserer
;Out: flags
scmpequ:	move.w	VAR_len(a0),d0
	move.w	VAR_len(a2),d1
	cmp.w	d0,d1
	beq.s	.sizeq
	rts
.sizeq:	move.l	a0,-(sp)
	move.l	VAR_start(a0),a0
	move.l	VAR_start(a2),a1
	subq.w	#1,d0
.l1:	cmpm.b	(a0)+,(a1)+
	dbne	d0,.l1
	move.l	(sp)+,a0
	rts

;In: a0,a2 structs equate a0 ref,a2 a inserer
;Out: flags
icmpequ:	move.w	VAR_len(a0),d0
	move.w	VAR_len(a2),d1
	cmp.w	d0,d1
	beq.s	.sizeq
	rts
.sizeq:	move.l	a0,-(sp)
	move.l	VAR_start(a0),a0
	move.l	VAR_start(a2),a1
	subq.w	#1,d0
	moveq	#0,d2
	moveq	#0,d1
.l1:	move.b	(a0)+,d2
	move.b	.t(pc,d2.w),d2
	move.b	(a1)+,d1
	move.b	.t(pc,d1.w),d1
	cmp.b	d2,d1
	dbne	d0,.l1
	move.l	(sp)+,a0
	rts
	CASETAB

alloc_equ_block:
	move.l	#EQUL_SIZEOF+EQUS_PER_BLOCK*4,d0
	bsr	MyMalloc
	beq.s	.rmem
	move.l	d0,a1
	clr.l	EQUL_next(a1)
	clr.w	EQUL_nb(a1)
	add.l	#EQUL_SIZEOF,d0
	move.l	d0,EQUL_block(a1)
	move.l	a1,d0
	rts
.rmem:	bra	Erreqt_ram

;  #] Stock equate & macro:
;  #[ Find equate & macro:
FINDEQU_REG	REG	d2-d5/a2-a6

find_macro:
	move.l	macs_ptr,d1
	bne.s	find_equ_mac
	moveq	#0,d0
	rts

FindEqu: 	move.l	EqusPtr,d1
;In:
;a0.l=@ var string
;d0.w=var len
;d1.l=@ tbl
;Out:
;d0.l=@(NULL if nf)
;Garb:d1/a1
find_equ_mac:
	movem.l	FINDEQU_REG,-(sp)
	lea	scmpsrch(pc),a6
	tst.w	CaseFlg
	bne.s	.nocase
	lea	icmpsrch(pc),a6
.nocase:	move.l	d1,a5
	move.w	d0,d1
;
;Stocker la plus grande taille d'equate insere dans le bloc a chaque insertion
;
	move.l	EQUL_block(a5),a4
	move.w	EQUL_nb(a5),d2		;!=0
	subq	#1,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	0(a4,d2.w),a1
	move.w	VAR_len(a1),d0
	cmp.w	d1,d0
	ble.s	.block_loop

;
;a4=pointeur debut, a1=pointeur fin
;
.block_found:
	moveq	#0,d5
	moveq	#-4,d3
.boucle:	move.w	d5,d4
	add.w	d2,d4
	lsr.w	#1,d4
	and.w	d3,d4
	move.l	VAR_start(a4,d4.w),a1

	cmp.w	VAR_len(a1),d1
	bhi.s	.moins
	beq.s	.same
.plus:	move.w	d4,d2
	add.w	d3,d2
	bge.s	.boucle
	bra.s	.nf

.same:	move.l	(a1),a3
	move.l	a0,a2
	move.w	d1,d0
	subq.w	#1,d0
	jsr	(a6)
	bhi.s	.plus
	bne.s	.moins
.d4_found:
	move.l	a1,d0
.end:	movem.l	(sp)+,FINDEQU_REG
	rts

.moins:	sub.w	d3,d4
	move.w	d4,d5
	cmp.w	d2,d5
	bls.s	.boucle
.nf:	moveq	#0,d0
	bra.s	.end

.another_block:
	move.l	d0,a5
	move.l	EQUL_block(a5),a4
	move.w	EQUL_nb(a5),d2		;!=0
	subq	#1,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	0(a4,d2.w),a1
	move.w	VAR_len(a1),d0
	cmp.w	d1,d0
	bhi.s	.block_found
.block_loop:
	beq.s	.same_size
	move.l	EQUL_next(a5),d0
	bne.s	.another_block
	bra.s	.nf

.same_size:
	move.l	VAR_start(a1),a3
	move.l	a0,a2
	move.w	d1,d0
	subq.w	#1,d0
	jsr	(a6)
	bhi	.block_found
	bne.s	.block_loop
	move.l	0(a4,d2.w),d0
	bra.s	.end

;In:
;a0.l=variable string
;a1.l=value buffer (10 bytes)
;d0.w=strlen
;Out:
;d0.w=variable string length (NULL if not found)
GetEquate:		;prep:_macro
	movem.l	d1/a1-a2,-(sp)
	move.l	a1,a2
	bsr	FindEqu
	beq.s	.end
	move.l	d0,a1
	move.l	VAR_value(a1),d1
	move.b	VAR_type(a1),d0
	bpl.s	.l1
	bclr	#7,d0
	neg.l	d1
	tst.b	d0
.l1:	beq.s	.put		;EQU_EQU
	subq.b	#EQU_SET,d0
	bne.s	.not_equ
.put:	move.l	d1,(a2)+
	move.b	VAR_sec(a1),(a2)
	move.w	VAR_len(a1),d0
.end:	movem.l	(sp)+,d1/a1-a2
	rts
.not_equ:
	moveq	#0,d0
	movem.l	(sp)+,d1-d2/a0-a2
	rts

;In:
;a0.l=label
;d0.w=strlen
;Out:
;d0.l=equate token (<0 if nf)
GetREquate:		;eval,evalone
	bsr	FindEqu
	move.l	d0,a0
	beq.s	.notequ
	moveq	#0,d1
	move.b	VAR_type(a0),d1
	bpl.s	.l1
	bclr	#7,d1
	tst.b	d1
.l1:	beq.s	.put
	cmp.b	#EQU_SET,d1
	beq.s	.put
	cmp.b	#EQU_EQUR,d1
	bne.s	.notequ
.put:	move.l	VAR_value(a0),d0
	tst.l	d1
.end:	rts
.notequ:	moveq	#-1,d1
	bra.s	.end

;In:
;a0.l=label
;Out:
;d0.l=equate token (<0 if nf)
;used in ea,ins
GetFEqur:	movem.l	d1/a1,-(sp)
	move.l	a0,a1
	moveq	#-1,d0
.l1:	tst.b	(a1)+
	dble	d0,.l1
	not.l	d0
	bsr	FindEqu
	move.l	d0,a1
	beq.s	.notequr
	cmp.b	#EQU_FEQUR,VAR_type(a1)
	bne.s	.notequr
.put:	move.l	VAR_value(a1),d0
.end:	movem.l	(sp)+,d1/a1
	rts
.notequr:	moveq	#-1,d0
	bra.s	.end

;In:
;a0.l=label
;Out:
;d0.l=equate token (<0 if nf)
;used in ea,ins
GetAnyEqr:
	move.l	a1,-(sp)
	move.l	a0,a1
	moveq	#-1,d0
.l1:	tst.b	(a1)+
	dble	d0,.l1
	not.l	d0
	bsr	FindEqu
	move.l	d0,a1
	beq.s	.notequr
	add.w	VAR_len(a1),a0
	move.b	VAR_type(a1),d1
	move.l	VAR_value(a1),d0
.end:	move.l	(sp)+,a1
	rts
.notequr:	moveq	#-1,d0
	bra.s	.end

;In:
;a0.l=label
;Out:
;d0.l=equate token (<0 if nf)
;used in ea,ins
GetEqur:	movem.l	d1/a1,-(sp)
	move.l	a0,a1
	moveq	#-1,d0
.l1:	tst.b	(a1)+
	dble	d0,.l1
	not.l	d0
	bsr	FindEqu
	move.l	d0,a1
	beq.s	.notequr
	cmp.b	#EQU_EQUR,VAR_type(a1)
	bne.s	.notequr
.put:	move.l	VAR_value(a1),d0
.end:	movem.l	(sp)+,d1/a1
	rts
.notequr:	moveq	#-1,d0
	bra.s	.end

;In:
;a0.l=label
;d0.b=ending char
;Out:
;d0.l=equate token (<0 if nf)
;a0.l=end string @
;used in ea,ins
GetEqur2:	movem.l	d1/a1,-(sp)
	move.l	a0,a1
.l1:	move.b	(a1)+,d1
	bmi.s	.notend
	cmp.b	d1,d0
	bne.s	.l1
	move.l	a1,d0
	sub.l	a0,d0
	subq.l	#1,d0
	bsr	FindEqu
	beq.s	.notequr
	move.l	d0,a1
	cmp.b	#EQU_EQUR,VAR_type(a1)
	bne.s	.notequr
.put:	add.w	VAR_len(a1),a0
	move.l	VAR_value(a1),d0
.end:	movem.l	(sp)+,d1/a1
	rts
.notequr:	moveq	#-1,d0
	bra.s	.end
.notend:	moveq	#-2,d0
	bra.s	.end

;In:
;a0.l=@ end label
;d0.b=leading char
;Out:
;d0.l=equate token (<0 if nf)
;a0.l=start string @
;used in ea,ins
GetEqur3:	movem.l	d1/a1,-(sp)
	move.b	d0,d1
	moveq	#-1,d0
.l1:	cmp.b	-(a0),d1
	dbeq	d0,.l1
	neg.l	d0
	addq.w	#1,a0
	bsr	FindEqu
	beq.s	.notequr
	subq.w	#1,a0
	move.l	d0,a1
	cmp.b	#EQU_EQUR,VAR_type(a1)
	bne.s	.notequr
.put:	move.l	VAR_value(a1),d0
.end:	movem.l	(sp)+,d1/a1
	rts
.notequr:	moveq	#-1,d0
	bra.s	.end

;In:
;a0.l=label
;d0.b=ending char
;Out:
;d0.l=equate token (<0 if nf)
;a0.l=end string @
;used in ea,ins
GetEqur4:	movem.l	d1/a1,-(sp)
	move.l	a0,a1
.l1:	move.b	(a1)+,d1
	bmi.s	.out
	cmp.b	d1,d0
	bne.s	.l1
.out:	move.l	a1,d0
	sub.l	a0,d0
	subq.l	#1,d0
	bsr	FindEqu
	beq.s	.notequr
	move.l	d0,a1
	cmp.b	#EQU_EQUR,VAR_type(a1)
	bne.s	.notequr
.put:	add.w	VAR_len(a1),a0
	move.l	VAR_value(a1),d0
.end:	movem.l	(sp)+,d1/a1
	rts
.notequr:	moveq	#-1,d0
	bra.s	.end

;In:
;a0.l=@ field
;Out:
;d0.l=reglist (<0 if nf)
GetRegEqu:		;reftable:_movem,_fmovem
	movem.l	d1/a1,-(sp)
	move.l	a0,a1
	moveq	#-1,d0
.l1:	tst.b	(a1)+
	dble	d0,.l1
	not.l	d0
	bsr	FindEqu
	move.l	d0,a1
	beq.s	.notequr
	cmp.b	#EQU_REG,VAR_type(a1)
	bne.s	.notequr
.put:	move.l	VAR_value(a1),d0
.end:	movem.l	(sp)+,d1/a1
	rts
.notequr:	moveq	#-1,d0
	bra.s	.end

;  #] Find equate & macro:
;  #[ Vars allocations:
alloc_global_block:
	move.l	a1,-(sp)
	move.l	#VARL_SIZEOF+GLOBALS_PER_BLOCK*VAR_SIZEOF,d0
	bsr	MyMalloc
	beq.s	.errmem
	move.l	d0,a1
	clr.l	VARL_next(a1)
	clr.w	VARL_nb(a1)
	add.l	#VARL_SIZEOF,d0
	move.l	d0,VARL_block(a1)
	move.l	a1,d0
	move.l	(sp)+,a1
	rts
.errmem:	bra	Errglot_ram

alloc_local_block:
	move.l	a1,-(sp)
	move.l	#VARL_SIZEOF+LOCALS_PER_BLOCK*VAR_SIZEOF,d0
	bsr	MyMalloc
	beq.s	.errmem
	move.l	d0,a1
	clr.l	VARL_next(a1)
	clr.w	VARL_nb(a1)
	add.l	#VARL_SIZEOF,d0
	move.l	d0,VARL_block(a1)
	move.l	a1,d0
	move.l	(sp)+,a1
	rts
.errmem:	bra	Errloct_ram
;  #] Vars allocations:
;  #[ Errors:
;	 #[ Doubly defined:
Errlabel_equ:
Errequ_mdef:
	move	#mdefequ_errno,d0
	bra.s	QsPError
Errlabel_set:
	move	#mdefset_errno,d0
	bra.s	QsPError
Errmac_mdef:
Errlabel_mac:
	move	#mdefmac_errno,d0
;	bra.s	QsPError
QsPError:	jmp	preperror
;	 #] Doubly defined:
;	 #[ Doubly defined:
;In: a0=pointeur sur struct d'une var doubly defined
;Out: d1=compteur de variables doubly defined differentes
;
Qs_doubly:
	movem.l	d0/d2-d4/a0-a5,-(sp)
	lea	scmpsrch(pc),a5
	tst.w	CaseFlg
	bne.s	.nocase
	lea	icmpsrch(pc),a5
.nocase:	move.l	DoublyPtr,d0
	bne.s	.nofirst
	move.l	#VARL_SIZEOF+DOUBLY_PER_BLOCK*4,d0
	bsr	MyMalloc
	beq	.rmem
	move.l	d0,a1
	clr.l	VARL_next(a1)
	clr.w	VARL_nb(a1)
	add.l	#VARL_SIZEOF,d0
	move.l	d0,VARL_block(a1)
	move.l	a1,DoublyPtr
	move.l	a1,d0

.nofirst:	move.l	d0,a1
	tst.w	VARL_nb(a1)
	beq.s	.first
	move.w	VAR_len(a0),d4
	move.l	VARL_block(a1),a4
	move.w	VARL_nb(a1),d2
	subq.w	#1,d2
.search:	move.l	(a4)+,a3
	cmp.w	VAR_len(a3),d4
	bne.s	.next
	move.l	VAR_start(a3),a3
	move.w	d4,d0
	subq.w	#1,d0
	move.l	VAR_start(a0),a2
	jsr	(a5)
	beq.s	.found
.next:	dbf	d2,.search
	move.l	VARL_next(a1),d0
	bne.s	.nofirst

.first:	addq.l	#1,d1

	move.w	VARL_nb(a1),d2
	addq.w	#1,d2
	cmp.w	#DOUBLY_PER_BLOCK,d2
	ble.s	.notfull

	move.l	#VARL_SIZEOF+DOUBLY_PER_BLOCK*4,d0
	bsr	MyMalloc
	beq.s	.rmem
	move.l	d0,VARL_next(a1)
	move.l	d0,a1
	clr.l	VARL_next(a1)
	add.l	#VARL_SIZEOF,d0
	move.l	d0,VARL_block(a1)
	moveq	#1,d2

.notfull:	move.w	d2,VARL_nb(a1)
	subq.w	#1,d2
	move.l	VARL_block(a1),a4
	IFNE	_68000
	add.w	d2,d2
	add.w	d2,d2
	move.l	a0,0(a4,d2.w)
	ELSEIF	;_68000
	move.l	a0,0(a4,d2.w*4)
	ENDC	;_68000

.found:	movem.l	(sp)+,d0/d2-d4/a0-a5
	rts
.rmem:

Erreq_ram:
Errloc_ram:
Errglo_ram:
Errxref_ram:
Errxdef_ram:
Erreqt_ram:
Errloct_ram:
Errloct2_ram:
Errglot_ram:
Errxreft_ram:
Errxdeft_ram:
Errname_ram:
	move	#varram_errno,d0
	bra.s	QsPFatal
Errfname_ram:
Errmod_ram:
	move	#modram_errno,d0
	bra.s	QsPFatal
Errlinn_ram:
Errlinr_ram:
	move	#dbgram_errno,d0
	bra.s	QsPFatal
Errbin_ram:
	move	#binram_errno,d0
QsPFatal:	jmp	prepfatal
;	 #] Doubly defined:
;  #] Errors:
;  #[ BSS:
	BSS
TotEquNb:		ds.l	1
EqusPtr:		ds.l	1
DoublyPtr:	ds.l	1
VarNb:		ds.l	1
GloNb:		ds.l	1
GloTbl:		ds.l	1
GloPtr:		ds.l	1
LocPtr:		ds.l	1
LocNb:		ds.l	1
LocTbl:		ds.l	1
CstLocTbl:	ds.l	1
TotLocNb:		ds.l	1
macs_ptr:		ds.l	1
XrefTbl:		ds.l	1
XdefTbl:		ds.l	1
xrefs_ptr:	ds.l	1
XrefNb:		ds.l	1
xdefs_ptr:	ds.l	1
XdefNb:		ds.l	1
TxtVarNb:		ds.l	1
DatVarNb:		ds.l	1
BssVarNb:		ds.l	1
OffVarNb:		ds.l	1
glob_table:	ds.l	256*4
;  #] BSS:
	section	TEXT


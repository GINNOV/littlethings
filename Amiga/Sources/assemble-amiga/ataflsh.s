	XDEF	FlushPrg
	XDEF	OutSize,IncbinSize

	XREF	create_file,write_file,seek_file,rel_seek_file,close_file
	XREF	LoadBin,MyMalloc,MyMfree,OutMsg
	XREF	BuildXdef,QsortV

	XREF	FlshBuf,DbgType,GDbgType,SrcType,EquFFlg,OutName
	XREF	SecSizes,TextSize,DataSize,BssSize,OutType,BsdOffsets
	XREF	TxtVarNb,DatVarNb,BssVarNb,LocRelNb
	XREF	LstBinNb,FstBinPtr
	XREF	TotExpNb,GloTbl,VarNb,HeadExp,EqusPtr,XrefTbl,XrefNb,XdefTbl,XdefNb
	XREF	FstModPtr,FstLinrPtr
	XREF	CurLinrNb,CurLinnNb,TotModNb

	include	"comequ.s"
	section	TEXT
;  #[ A faire:
;pas de reloc si org
;finir variables en psrc
;pc-rel inter-section en dri & pc
;  #] A faire:
;  #[ FlushPrg:
FlushPrg:	move.l	d4,-(sp)
	clr.l	prg_ssize
	clr.l	relsize
	moveq	#0,d0
	move.w	LstBinNb,d0
	bmi.s	.norbin
	addq.l	#1,d0
	add.l	d0,d0
	add.l	d0,d0
	jsr	MyMalloc
	move.l	d0,BinTbl
	beq.s	.rmem
	bsr.s	BldBinTbl
.norbin:	move.l	IncbinSize,d0
	beq.s	.norincb
	jsr	MyMalloc
	move.l	d0,IncbinPtr
	beq.s	.rmem
.norincb:	lea	OutName,a0
	bsr	create_file
	bmi.s	.rcrea
	move.l	d0,d4
	bsr.s	_flshprg
	bne.s	.rwrite
.clse:	move.l	d4,d0
	bsr	close_file
	tst.w	LstBinNb
	bmi.s	.nofbin
	move.l	BinTbl,a0
	jsr	MyMfree
.nofbin:	tst.l	IncbinSize
	beq.s	.end
	move.l	IncbinPtr,a0
	jsr	MyMfree
.end:	move.l	(sp)+,d4
	rts
.rmem:	bsr	Errfile_ram
	bra.s	.end
.rcrea:	bsr	Errfile_create
	bra.s	.end
.rwrite:	bsr	Errfile_write
	bra.s	.clse

;In:d0=@
BldBinTbl:
	move.l	d0,a0
	move.l	FstBinPtr,d0
	beq.s	.end
.l1:	move.l	d0,(a0)+
	move.l	d0,a1
	move.l	BIN_next(a1),d0
	bne.s	.l1
.end:	rts

_flshprg:	cmp.w	#PURE_OBJ,OutType+2
	beq.s	.pure
	cmp.w	#BSD_OBJ,OutType+2
	beq.s	.bsd

	move.l	d4,d0
	bsr	tprgwhdr
	bne.s	.clse

	move.l	d4,d0
	moveq	#SEC_text,d1
	bsr	flshbin
	bne.s	.clse
	move.l	d4,d0
	moveq	#SEC_data,d1
	bsr	flshbin
	bne.s	.clse

	cmp.w	#DRI_OBJ,OutType+2
	beq.s	.dri

	move.w	DbgType,d0
	beq.s	.nodbg
	subq.b	#DBG_DRI,d0
	bne.s	.dbgx
	move.l	d4,d0
	bsr	wprgsym		;symbols
	bne.s	.clse
	bra.s	.nodbg
.dbgx:	move.l	d4,d0
	bsr	wprgsymx
	bne.s	.clse
.nodbg:	move.l	d4,d0
	bsr	writerel
	move.l	d4,d0
	bsr	psrcflsh		;src debug
	bne.s	.clse
.sym:	tst.l	prg_ssize
	beq.s	.clse
	moveq	#0,d0
	move.l	d4,d1
	bsr	seek_file
	bmi.s	.clse
	move.l	d4,d0
	bsr	tprgwhdr
.clse:	rts
.dri:	move.l	d4,d0
	bsr	flshdri		;image+symbols+reloc
	bra.s	.sym
.pure:	move.l	d4,d0
	bsr	purewobj
	bra.s	.clse
.bsd:	move.l	d4,d0
	bsr	bsdwobj
	bra.s	.clse
;  #] FlushPrg:
;  #[ flshbin:
;a0=BIN
;d0=handle
;OUT:
;CCR
wincbin:	movem.l	d3-d4/a2,-(sp)
	move.l	d0,d4		;handle
	move.l	BIN_size(a0),d3
	tst.b	imgflg
	bne.s	.img		;if flushing image
	move.l	BIN_off(a0),d1	;offset
	move.l	BIN_name(a0),a0	;fname
	move.l	a0,a2		;???
	move.l	IncbinPtr,a1	;@
	move.l	d3,d0		;size
	bsr	LoadBin
	bmi.s	.err
.img:	move.l	IncbinPtr,a0
	move.l	d3,d0
	move.l	d4,d1
	bsr	write_file
.end:	movem.l	(sp)+,d3-d4/a2
	rts
.err:	bsr	Errincbin
	bra.s	.img

flshbin:	movem.l	d4-d7/a4,-(sp)
	move.l	d0,d4
	move.w	d1,d7
	moveq	#0,d6
	move.l	FstBinPtr,d0
	beq.s	.good
.l1:	move.l	d0,a4
	cmp.w	BIN_sec(a4),d7
	bne.s	.next
	move.l	BIN_start(a4),d0
	bne.s	.noinc
	move.l	a4,a0
	move.l	d4,d0
	bsr	wincbin
	bne.s	.clse
	add.l	d0,d6
	bra.s	.next
.noinc:	move.l	d0,a0
	move.l	BIN_cur(a4),d0
	sub.l	a0,d0
	add.l	d0,d6
	move.l	d4,d1
	bsr	write_file
	bne.s	.clse
.next:	move.l	BIN_next(a4),d0
	bne.s	.l1
.good:	moveq	#0,d0
.clse:	add.l	d6,OutSize
	tst.l	d0
	movem.l	(sp)+,d4-d7/a4
	rts
;  #] flshbin:
;  #[ PRG rel:
;parcourir les exp (deja triees) suivant la section & sauver les abs.l

R_STEP	equ	254

R_SEC	equr	d1
R_LSTOFF	equr	d3	;last offset
;	equr	d4
R_BINNB	equr	d5	;# BIN
R_END	equr	d6	;@ End buffer
R_EXPNB	equr	d7	;# EXP in head

R_BIN	equr	a1	;@ BIN
R_HEAD	equr	a2	;@ HEAD
R_EXP	equr	a3	;@ EXP
R_HANDLE	equr	a4	;handle
R_CUR	equr	a6	;@ Cur buffer

;	 #[ reloc1:
;In:
;d1=section
;Sets:
;@ Exp block
;@ Exp
;@ Bin block
;# Bin block
;# EXP #
scanrexp:	move.l	HeadExp,d0
	beq.s	.norel
.nxtblk:	move.l	d0,R_HEAD
	move.l	HEAD_start(R_HEAD),R_EXP	;fst EXP
	move.w	HEAD_nb(R_HEAD),R_EXPNB	;#EXP in block
	subq.w	#1,R_EXPNB
.l1:	tst.b	EXP_sec(R_EXP)
	beq.s	.nxt		;no reloc
	move.w	EXP_patch(R_EXP),d0
	cmp.w	#P_ABSL,d0
	beq.s	.rel		;reloc ABSL
	cmp.w	#P_DCL,d0
	beq.s	.rel		;and DCL
.nxt:	lea	EXP_SIZEOF(R_EXP),R_EXP
	dbf	R_EXPNB,.l1
	move.l	HEAD_next(R_HEAD),d0
	bne.s	.nxtblk
.norel:	;moveq	#0,d0
	rts

.rel:	move.w	EXP_bin(R_EXP),R_BINNB
	IFNE	_68000
	moveq	#0,d0
	move.w	R_BINNB,d0
	add.l	d0,d0
	add.l	d0,d0
	move.l	BinTbl,a0
	move.l	0(a0,d0.l),R_BIN
	ELSEIF
	move.l	([BinTbl],R_BINNB.w*4),R_BIN
	ENDC

.fstbin:	cmp.w	BIN_sec(R_BIN),R_SEC
	bne.s	.nxt
	move.l	BIN_off(R_BIN),a0
	add.w	EXP_poke(R_EXP),a0	;new offset
	subq.w	#4,a0
	move.l	a0,d0
	rts

;but: trouver:
;la 1ere EXP a reloger -> le 1er buffer binaire -> la 1ere section

;Out:
;d0=error/no error=0
;d1=section
getrel1:	moveq	#SEC_text,R_SEC
	bsr	scanrexp
	bne.s	.found
	moveq	#SEC_data,R_SEC
	bsr	scanrexp
.found:	movem.l	d0/d4-d7/a1-a3,rellast	;off,maxsz,bin#,cursz,exp#,head@,exp@,handle,bin@,rel@
	move.l	d0,(R_CUR)+
	moveq	#0,d0
	rts

;In:
;d1=sec #
;Out:
;d0=error/no error=0
;d1=sec #
resetre1:	bsr	scanrexp
	beq.s	.nodata
	move.l	rellast,d1
	movem.l	d0/d4-d7/a1-a3,rellast	;off,maxsz,bin#,cursz,exp#,head@,exp@,handle,bin@,rel@
	sub.l	d1,d0
	bra.s	newrel
.nodata:	clr.l	rellast
	rts
;	 #] reloc1:
;	 #[ reldata:	;reloc data from text
reldata:	move.l	FstBinPtr,d0
	beq.s	.good
	moveq	#SEC_data,d1
	move.l	TextSize,d2
.l1:	move.l	d0,a0
	cmp.w	BIN_sec(a0),d1
	bne.s	.next
	add.l	d2,BIN_off(a0)
.next:	move.l	BIN_next(a0),d0
	bne.s	.l1
.good:	rts
;	 #] reldata:
;	 #[ addrel:
addrel:	move.b	d0,(R_CUR)+
	cmp.l	R_CUR,R_END
	ble.s	clserel
	moveq	#0,d0
	rts

clserel:	movem.l	d1/a1,-(sp)
	move.l	FlshBuf,a0
	move.l	a0,-(sp)
	move.l	R_HANDLE,d1
	move.l	R_CUR,d0
	sub.l	a0,d0
	add.l	d0,relsize
	bsr	write_file
	move.l	(sp)+,R_CUR
	movem.l	(sp)+,d1/a1
	rts
;	 #] addrel:
;	 #[ newrel:
;Input:
;d0:relative offset
newrel:	move.l	d3,-(sp)
	move.l	d0,d3
.nxtmult:	sub.l	#R_STEP,d3	;-254
	bmi.s	.rel
	beq.s	.254
	moveq	#1,d0		;write overflow=1
	bsr	addrel
	bne.s	.end
	bra.s	.nxtmult
.254:	move.b	#R_STEP,d3
	bra.s	.single
.rel:	add.l	#R_STEP,d3	;+254
.single:	move.b	d3,d0		;write offset (byte)
	bsr	addrel
.end:	movem.l	(sp)+,d3
	rts
;	 #] newrel:
;	 #[ calcrel:
calcrel:	cmp.w	EXP_bin(R_EXP),R_BINNB
	bne.s	.newbin		;not same bin buffer
.goodbin:	tst.b	EXP_sec(R_EXP)
	beq.s	.next		;no reloc
	move.w	EXP_patch(R_EXP),d0
	cmp.w	#P_ABSL,d0
	beq.s	.dorel		;reloc ABSL
	cmp.w	#P_DCL,d0
	bne.s	.next		;and DCL
.dorel:	move.l	BIN_off(R_BIN),a0
	add.w	EXP_poke(R_EXP),a0	;new offset
	subq.w	#4,a0
	move.l	a0,d0		;ressort dans a0 et d0
.rel:	moveq	#1,d1
	rts
.next:	moveq	#-1,d1
	rts
	IFNE	BLINDOS
.err:	_Debugger
	ENDC	BLINDOS
.nomore:	moveq	#0,d1
	rts

.newbin:	move.w	BIN_sec(R_BIN),R_SEC	;required section
.nxtbin:	move.w	EXP_bin(R_EXP),R_BINNB
	IFNE	_68000
	moveq	#0,d0
	move.w	R_BINNB,d0
	add.l	d0,d0
	add.l	d0,d0
	move.l	BinTbl,a0
	move.l	0(a0,d0.l),R_BIN
	ELSEIF
	move.l	([BinTbl],R_BINNB.w*4),R_BIN
	ENDC

.cmpbin:	cmp.w	BIN_sec(R_BIN),R_SEC	;is it?
	beq.s	.goodbin

.l2:	cmp.w	EXP_bin(R_EXP),R_BINNB
	bne.s	.nxtbin			;not same bin buffer
	lea	EXP_SIZEOF(R_EXP),R_EXP
	dbf	R_EXPNB,.l2
	move.l	HEAD_next(R_HEAD),d0
	beq.s	.nomore
	move.l	d0,R_HEAD
	move.l	HEAD_start(R_HEAD),R_EXP	;fst EXP
	move.w	HEAD_nb(R_HEAD),R_EXPNB	;#EXP in block
	subq.w	#1,R_EXPNB
	bra.s	.l2
;	 #] calcrel:
;	 #[ flshrel:
;Input:
;d1:section
flshrel:	movem.l	rellast,d3-d7/a1-a3	;off,maxsz,bin#,exp#,cursz,bin@,head@,exp@
	bra.s	.next

.nxtblk:	move.l	d0,R_HEAD
	move.l	HEAD_start(R_HEAD),R_EXP	;fst EXP
	move.w	HEAD_nb(R_HEAD),R_EXPNB	;#EXP in block
	subq.w	#1,R_EXPNB
.nxtEXP:	bsr	calcrel
	bmi.s	.next
	beq.s	.endEXP

	sub.l	R_LSTOFF,d0	;moins l'offset d'avant
	IFNE	BLINDOS
	ble.s	.err
	ENDC	BLINDOS
	move.l	a0,R_LSTOFF	;next entry offset
	bsr	newrel
	bne.s	.end

.next:	lea	EXP_SIZEOF(R_EXP),R_EXP
	dbf	R_EXPNB,.nxtEXP
	move.l	HEAD_next(R_HEAD),d0
	bne.s	.nxtblk
.endEXP:	moveq	#0,d0
.end:	move.l	R_LSTOFF,rellast
	tst.l	d0
	rts
	IFNE	BLINDOS
.err:	_Debugger
	bra.s	.endEXP
	ENDC	BLINDOS
;	 #] flshrel:
;	 #[ endrel:
endrel:	bsr	clserel
	bne.s	.end
	btst	#0,relsize+3
	bne.s	.odd
.end:	rts
.odd:	moveq	#0,d0		;even
	bsr	addrel
	bne.s	.end
	bra	clserel
;	 #] endrel:
;	 #[ writerel:
writerel:	movem.l	d3-d7/a2-a4/a6,-(sp)
	move.l	d0,R_HANDLE	;file handle

	bsr	reldata

	move.l	FlshBuf,R_CUR	;rel buf @
	move.l	R_CUR,R_END
	add.l	#FLSHBUF_SIZE,R_END	;rel end @

	bsr	getrel1		;1st reloc
	bne.s	.clse
	tst.l	rellast
	beq.s	.norel
	tst.w	d1		;SEC_text
	bne.s	.notext

	;moveq	#SEC_text,d1
	bsr	flshrel		;text reloc
	bne.s	.clse

	moveq	#SEC_data,d1	;reset data
	bsr	resetre1
	bne.s	.clse

	tst.l	rellast
	beq.s	.endrel

.notext:	;moveq	#SEC_data,d1
	bsr	flshrel		;data reloc
	bne.s	.clse

.endrel:	moveq	#0,d0		;0.b
	bsr	addrel		;write last zero
	bne.s	.clse
.norel:	bsr	endrel
	bne.s	.clse
	move.l	relsize,d0
	add.l	d0,OutSize
	moveq	#0,d0
.clse:	movem.l	(sp)+,d3-d7/a2-a4/a6
	rts
;	 #] writerel:
;  #] PRG rel:
;  #[ DRI prg:
;	 #[ tprgwhdr:
tprgwhdr:
	move.l	d0,d1
	lea	prg_hdr,a0
	move.l	a0,a1
	move.w	#$601a,(a1)+
	move.l	TextSize,(a1)+
	move.l	DataSize,(a1)+
	move.l	BssSize,(a1)+
;	clr.l	(a1)+		;symsize
;	clr.l	(a1)+		;res1
;	clr.l	(a1)+		;flags
;	clr.w	(a1)+		;res2
	moveq	#$1c,d0
	bra	write_file
;	 #] tprgwhdr:
;	 #[ wprgsym:
;rajouter les regs?
wprgsym:	movem.l	d3-d7/a2-a4,-(sp)
	move.l	d0,d4
	moveq	#0,d6		;taille totale symboles
	move.l	GloTbl,a2
	lea	-14(sp),sp
	move.l	sp,a4

;	lea	SecSizes,a0
;	lea	.reltab+4(pc),a1
;	move.l	SEC_text(a0),d0
;	move.l	d0,(a1)+
;	add.l	SEC_data(a0),d0
;	move.l	d0,(a1)+

	move.l	VarNb,d7
	beq.s	.end

.l0:	move.l	(a2)+,a3
	moveq	#0,d2
	move.b	VAR_sec(a3),d2
	bmi.s	.nx_var		;offset

	move.l	VAR_start(a3),a0	;name
	move.w	VAR_len(a3),d0
	move.l	a4,a1
	bsr	cpy8sym
	lea	8(a4),a1
	move.w	.symtab+2(pc,d2.w),(a1)+
	move.l	VAR_value(a3),d0
	add.l	.reltab(pc,d2.w),d0	;data|bss
	move.l	d0,(a1)+
	move.l	a4,a0
	moveq	#14,d0
	move.l	d4,d1
	bsr	write_file
	bne.s	.clse
	add.l	#14,d6
.nx_var:	subq.l	#1,d7
	bgt.s	.l0
.end:	move.l	d6,prg_ssize
	moveq	#0,d0
.clse:	lea	14(sp),sp
	movem.l	(sp)+,d3-d7/a2-a4
	rts
.symtab:	dc.l	$8200,$8400,$8100,$c000
.reltab:	ds.l	4		;text/data/bss/equ
;	 #] wprgsym:
;	 #[ wprgsymx:
wprgsymx:	movem.l	d3-d7/a2-a4,-(sp)
	move.l	d0,d4
	moveq	#0,d6		;taille totale symboles
	move.l	GloTbl,a2
	lea	-28(sp),sp
	move.l	sp,a4

;	lea	SecSizes,a0
;	lea	.reltab+4(pc),a1
;	move.l	SEC_text(a0),d0
;	move.l	d0,(a1)+
;	add.l	SEC_data(a0),d0
;	move.l	d0,(a1)+

	move.l	VarNb,d7
	beq	.end

.l0:	move.l	(a2)+,a3
	moveq	#0,d2
	move.b	VAR_sec(a3),d2
	bmi.s	.nx_var		;skip offset
.ok:	move.l	VAR_start(a3),a0
	move.l	a4,a1
	moveq	#14,d5		;dri
	move.w	VAR_len(a3),d0
	cmp.w	#8,d0
	blt.s	.clrdri
	beq.s	.cpydri
	moveq	#28,d5		;h
	moveq	#8-1,d0
	bra.s	.l2
.clrdri:	clr.l	(a1)
	clr.l	4(a1)
.cpydri:	subq.w	#1,d0
.l2:	move.b	(a0)+,(a1)+
	dbf	d0,.l2
	lea	8(a4),a1
	move.w	.symtab+2(pc,d2.w),d0
	cmp.w	#14,d5
	beq.s	.noth
	move.b	#$48,d0
.noth:	move.w	d0,(a1)+
;	move.l	VAR_value(a3),d0
;	add.l	.reltab(pc,d2.w),d0	;data|bss
;	move.l	d0,(a1)+
	move.l	VAR_value(a3),(a1)+
	cmp.w	#14,d5
	beq.s	.write
	move.w	VAR_len(a3),d0
	subq.w	#8,d0
	cmp.w	#14,d0
	blt.s	.clrh
	beq.s	.cpyh
	moveq	#14-1,d0
	bra.s	.l3
.clrh:
	REPT	3
	clr.l	(a1)+
	ENDR
	clr.w	(a1)
.cpyh:	lea	14(a4),a1
	subq.w	#1,d0
.l3:	move.b	(a0)+,(a1)+
	dbf	d0,.l3

.write:	move.l	a4,a0
	move.l	d5,d0
	move.l	d4,d1
	bsr	write_file
	bne.s	.clse
	add.l	d5,d6
.nx_var:	subq.l	#1,d7
	bgt	.l0
.end:	move.l	d6,prg_ssize
	moveq	#0,d0
.clse:	lea	28(sp),sp
	movem.l	(sp)+,d3-d7/a2-a4
	rts
.symtab:	dc.l	$8200,$8400,$8100,$c000	;org=equ
.reltab:	ds.l	4		;text/data/bss/equ
;	 #] wprgsymx:
;  #] DRI prg:
;  #[ DRI obj:
;	 #[ clrbin:
;Strategie:
;ecrire les symboles dans un ordre fixe ({XREF+XDEF}|{XREF+SYM})
;(ajouter eventuellement les equ et reg)
;vider binaire+incbin
;marquer les binaires avec les EXP, section connue ou # xref
;ecrire le tout
;0:BSS
;1:TEXT
;2:DATA
;3:undefined
;4:reglist
;5:global
;6:constant
;7:defined
clrbin:	move.l	FstBinPtr,d0
	beq.s	.good
.l1:	move.l	d0,a1
	move.l	BIN_start(a1),d0
	beq.s	.next
	move.l	d0,a0
	move.l	BIN_cur(a1),d0
	sub.l	a0,d0
.l2:	clr.b	(a0)+
	subq.l	#1,d0
	bgt.s	.l2
.next:	move.l	BIN_next(a1),d0
	bne.s	.l1
.good:	rts
;	 #] clrbin:
;	 #[ clrinc:
clrinc:	move.l	IncbinSize,d0
	beq.s	.good
	move.l	IncbinPtr,a0
	lsr.l	#1,d0
	beq.s	.one
	bcs.s	.odd
.l1:	clr.w	(a0)+
	subq.l	#1,d0
	bne.s	.l1
.good:	rts
.odd:	clr.w	(a0)+
	subq.l	#1,d0
	bne.s	.odd
.one:	clr.b	(a0)+
	rts
;	 #] clrinc:
;	 #[ bdriimg:
;d7/d6
;a2/a3
bdriimg:	movem.l	d3-d7/a2-a5,-(sp)
	moveq	#0,d6		;reloc size
	move.l	HeadExp,d0
	beq.s	.endEXP
	moveq	#0,d5
	move.l	FstBinPtr,a5
	move.l	BIN_start(a5),d4
.nxtblk:	move.l	d0,a2
	move.l	HEAD_start(a2),a3	;fst EXP
	move.w	HEAD_nb(a2),d7	;#EXP in block
	subq.w	#1,d7
;	bmi.s	.endEXP
.nxtEXP:	cmp.w	EXP_bin(a3),d5
	bne.s	.newbin
.samebin:	move.l	d4,a1
	add.w	EXP_poke(a3),a1	;where to poke
	tst.b	EXP_sec(a3)
	beq.s	.next		;no reloc
	bmi.s	.xref		;xref
	move.w	EXP_patch(a3),d0
	cmp.w	#P_D8PC,d0
	bge.s	.dopc
.asabs:	cmp.w	#P_ABSL,d0
	beq.s	.dorel		;reloc ABSL
	cmp.w	#P_DCL,d0
	bne.s	.next		;and DCL
.dorel:	moveq	#0,d0
	move.b	EXP_sec(a3),d0
	subq.w	#1,d0		;section--(reloc)
	move.l	.tabsec(pc,d0.w),-4(a1)
.next:	lea	EXP_SIZEOF(a3),a3
	dbf	d7,.nxtEXP
	move.l	HEAD_next(a2),d0
	bne.s	.nxtblk
.endEXP:	movem.l	(sp)+,d3-d7/a2-a5
	rts
.tabsec:	dc.l	$50002,$50001,$50003	;TEXT,DATA,BSS
	IFNE	BLINDOS
.err:	_Debugger
	ENDC	BLINDOS

.newbin:	move.w	EXP_bin(a3),d5
	IFNE	_68000
	moveq	#0,d1
	move.w	d5,d1
	add.l	d1,d1
	add.l	d1,d1
	move.l	BinTbl,a1
	move.l	0(a1,d1.l),a5
	ELSEIF
	move.l	([BinTbl],d5.w*4),a5
	ENDC	;_68000
	move.l	BIN_start(a5),d4
	bra.s	.samebin

.dopc:	move.w	BIN_sec(a5),d0	;sec(sym)!=sec(bin)?asxref:asabs
	addq.w	#1,d0
	cmp.b	EXP_sec(a3),d0
	beq.s	.asabs

.xref:	move.w	EXP_patch(a3),d0
	move.w	.tab(pc,d0.w),d0	;deja *2
	jmp	.tab(pc,d0.w)

.reloc:	moveq	#5,d0
	swap	d0
	move.w	EXP_varnb(a3),d0
	lsl.w	#3,d0		;*8
	addq.w	#4,d0		;+4
	move.l	d0,-4(a1)
	bra.s	.next

.relpc:	move.w	EXP_varnb(a3),d0
	lsl.w	#3,d0		;*8
	addq.w	#6,d0		;+6
	move.w	d0,-2(a1)
	bra.s	.next

.relbdpc:	move.w	EXP_varnb(a3),d0
	lsl.w	#3,d0		;*8
	addq.w	#6,d0		;+6
	move.w	d0,(a1)
	bra	.next

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
	dc.w	.rpcb-.tab	;P_PCD8
	dc.w	.relpc-.tab	;P_D16PC
	dc.w	.relpc-.tab	;P_DBCC
	dc.w	.rpcb-.tab	;P_BCCB
	dc.w	.relpc-.tab	;P_BCCW
	dc.w	.rpcl-.tab	;P_BCCL
	dc.w	.relbdpc-.tab	;P_BDPCW
	dc.w	.rpcl-.tab	;P_BDPCL

.rpcb:
.rpcl:
.rrel:
	IFNE	BLINDOS
	_Debugger
	ENDC
	bra	.next
;	 #] bdriimg:
;	 #[ wdrixref:
wdrixref:	movem.l	d3-d7/a2-a4,-(sp)
	move.l	d0,d4
	move.w	#%10001000<<8,d5	;xref=defined+undefined
	moveq	#0,d6		;sym size
	move.l	XrefTbl,a2
	lea	-14(sp),sp
	move.l	sp,a4
	move.l	XrefNb,d7
	beq.s	.good
.l0:	move.l	(a2)+,a3		;get var
	move.l	VAR_start(a3),a0	;name
	move.w	VAR_len(a3),d0	;name length
	move.l	a4,a1
	bsr	cpy8sym
	lea	8(a4),a1
	move.w	d5,(a1)+
	move.l	VAR_value(a3),(a1)+	;sym value
	move.l	a4,a0
	moveq	#14,d0		;sym length
	move.l	d4,d1
	bsr	write_file
	bne.s	.clse
	add.l	#14,d6
.nx_var:	subq.l	#1,d7
	bgt.s	.l0
	add.l	d6,prg_ssize
.good:	moveq	#0,d0
.clse:	lea	14(sp),sp
	movem.l	(sp)+,d3-d7/a2-a4
	rts
;	 #] wdrixref:
;	 #[ wdrixdef:
wdrixdef:	movem.l	d3-d7/a2-a4,-(sp)
	move.l	d0,d4
	move.w	#%10100000<<8,d5	;xdef=defined+global
	moveq	#0,d6		;sym size
	move.l	XdefTbl,a2
	lea	-14(sp),sp
	move.l	sp,a4
	move.l	XdefNb,d7
	beq.s	.good
.l0:	move.l	(a2)+,a3		;get var
	move.l	VAR_start(a3),a0	;name
	move.w	VAR_len(a3),d0	;name length
	move.l	a4,a1
	bsr.s	cpy8sym
	lea	8(a4),a1
	move.b	VAR_sec(a3),d0
	and.w	#%1100,d0
	move.w	.tab+2(pc,d0.w),(a1)
	or.w	d5,(a1)+
	move.l	VAR_value(a3),(a1)+	;sym value
	move.l	a4,a0
	moveq	#14,d0		;sym length
	move.l	d4,d1
	bsr	write_file
	bne.s	.clse
	add.l	#14,d6
.nx_var:	subq.l	#1,d7
	bgt.s	.l0
	add.l	d6,prg_ssize
.good:	moveq	#0,d0
.clse:	lea	14(sp),sp
	movem.l	(sp)+,d3-d7/a2-a4
	rts
.tab:	dc.l	2<<8,4<<8,1<<8,64<<8	;bit 0,1,2,6(section=equ)
;	 #] wdrixdef:
;	 #[ cpy8sym:
;In:
;a0=src
;a1=dst
;d0=len
cpy8sym:	cmp.w	#8,d0
	blt.s	.clr
	beq.s	.cpy
	moveq	#8-1,d0
.l1:	move.b	(a0)+,(a1)+
	dbf	d0,.l1
	bra.s	.s1
.clr:	addq.w	#8,a1
	clr.l	-(a1)
	clr.l	-(a1)
.cpy:	subq.w	#1,d0
.l2:	move.b	(a0)+,(a1)+
	dbf	d0,.l2
.s1:	rts
;	 #] cpy8sym:
;	 #[ wdrisym:
wdrisym:	movem.l	d3-d7/a2-a4,-(sp)
	move.l	d0,d4
	move.w	#%10000000<<8,d5	;sym=defined
	moveq	#0,d6		;sym size
	move.l	GloTbl,a2
	lea	-14(sp),sp
	move.l	sp,a4
	move.l	VarNb,d7
	beq.s	.good
.l0:	move.l	(a2)+,a3
	move.l	VAR_start(a3),a0
	move.w	VAR_len(a3),d0	;name length
	move.l	a4,a1
	bsr	cpy8sym
	lea	8(a4),a1
	move.b	VAR_sec(a3),d0
	and.w	#%1100,d0
	move.w	.tab+2(pc,d0.w),d0	;sym type
	btst	#VAR_DEFED,VAR_type(a3)
	beq.s	.noxdef
	bset	#5+8,d0		;xdef=global
.noxdef:	or.w	d5,d0
	move.w	d0,(a1)+
	move.l	VAR_value(a3),(a1)+	;sym value
	move.l	a4,a0
	moveq	#14,d0		;sym length
	move.l	d4,d1
	bsr	write_file
	bne.s	.clse
	add.l	#14,d6
.nx_var:	subq.l	#1,d7
	bgt.s	.l0
	add.l	d6,prg_ssize
.good:	moveq	#0,d0
.clse:	lea	14(sp),sp
	movem.l	(sp)+,d3-d7/a2-a4
	rts
.tab:	dc.l	2<<8,4<<8,1<<8,$c000	;bit 0,1,2,6(section=equ)
;	 #] wdrisym:
;	 #[ wdriequ:
;wdriequ:	movem.l	d3-d7/a2-a5,-(sp)
;	move.l	d0,d4
;	move.w	#%11000000<<8,d5	;equ=defined+constant
;	moveq	#0,d6		;sym size
;	lea	-14(sp),sp
;	move.l	sp,a4
;	move.l	EqusPtr,d0
;	beq.s	.good
;.l0:	move.l	d0,a5
;	move.l	EQUL_block(a5),a3
;	move.w	EQUL_nb(a5),d7
;	subq.w	#1,d7
;.l1:	move.l	(a3)+,a2
;	move.b	VAR_type(a2),d0
;	subq.b	#EQU_SET,d0
;	bgt.s	.nx_var
;	move.l	a4,a1
;	move.l	VAR_start(a2),a0
;	move.w	VAR_len(a2),d0	;name length
;	bsr	cpy8sym
;	lea	8(a4),a1
;	move.w	d5,(a1)+
;	move.l	VAR_value(a2),(a1)+	;eq value
;	move.l	a4,a0
;	moveq	#14,d0		;sym length
;	move.l	d4,d1
;	bsr	write_file
;	bne.s	.clse
;	add.l	#14,d6
;.nx_var:	dbf	d7,.l1
;	move.l	EQUL_next(a5),d0
;	bne.s	.l0
;	add.l	d6,prg_ssize
;.good:	moveq	#0,d0
;.clse:	lea	14(sp),sp
;	movem.l	(sp)+,d3-d7/a2-a5
;	rts
;	 #] wdriequ:
;	 #[ flshdri:
;In:d0.l=handle
flshdri:	move.l	d4,-(sp)
	tst.w	XrefNb		;<65536
	bne.s	.rvar
	move.l	d0,d4
;	move.l	d4,d0
	bsr	wdrixref
	bne.s	.clse
	jsr	BuildXdef
	move.l	d4,d0
	tst.w	DbgType
	bne.s	.dbg
	bsr	wdrixdef
	bne.s	.clse
	bra.s	.s1
.dbg:	bsr	wdrisym
	bne.s	.clse
;	tst.b	EquFFlg
;	beq.s	.s1
;	move.l	d4,d0
;	bsr	wdriequ
;	bne.s	.clse
.s1:	bsr	clrbin
	bsr	clrinc
	bsr	bdriimg
	st	imgflg
	move.l	d4,d0
	moveq	#SEC_text,d1
	bsr	flshbin
	bne.s	.clse
	move.l	d4,d0
	moveq	#SEC_data,d1
	bsr	flshbin
;	bne.s	.clse
.clse:	sf	imgflg
	movem.l	(sp)+,d4		;keep ccr
	rts
.rvar:	bra	Errvar_2many
;	 #] flshdri:
;  #] DRI obj:
;  #[ PURE src:
PSRC_H	equr	d4	;handle
;	 #[ psrcuphd:
psrcuphd:	move.l	PDbgoffset,d0
	neg.l	d0
	move.l	PSRC_H,d1
	bsr	rel_seek_file
	bmi.s	.end
	lea	PDbgheader,a0
	moveq	#PDbgheader_SIZEOF,d0
	move.l	PSRC_H,d1
	bra	write_file
.end:	rts
;	 #] psrcuphd:
;keep tight
;	 #[ psrcwhd:
psrcwhd:	lea	PDbgheader,a0		;header
	move.l	#'QDB1',d0
	add.b	OutType+3,d0		;'QDB1'->'QDB2'
	move.l	d0,(a0)

	;update taille modules
	move.l	TotModNb,d0
	lsl.l	#3,d0
	move.l	d0,PDbgmodsize

	;update taille lignes
	move.l	CurLinrNb,d0
	mulu	#20,d0
	move.l	CurLinnNb,d1
	add.l	d1,d1
	add.l	d1,d0
	move.l	d0,PDbglinsize

	;taille names deja update
	moveq	#PDbgheader_SIZEOF,d0
	move.l	PSRC_H,d1
	bra	write_file
;	 #] psrcwhd:
;	 #[ psrcwmod:
psrcwmod:	movem.l	d3-d7/a2,-(sp)
	subq.w	#8,sp
	moveq	#0,d6			;first name offset
	move.l	FstModPtr,d0		;1st module
	beq.s	.good
.l1:	move.l	d0,a2
	clr.l	PMOD_time(sp)		;module timestamp
	move.l	d6,PMOD_name(sp)		;module name offset

	move.l	sp,a0
	moveq	#8,d0
	move.l	PSRC_H,d1
	bsr	write_file
	bne.s	.end

	;reloc next name
	move.l	MOD_expnam(a2),a0
	STRLEN
	addq.l	#1,d0
	add.l	d0,d6

	move.l	MOD_next(a2),d0
	bne.s	.l1
	move.l	d6,PDbgnamsize
.good:	moveq	#0,d0
.end:	addq.w	#8,sp
	movem.l	(sp)+,d3-d7/a2
	rts
;	 #] psrcwmod:
;	 #[ psrcwlin:
PSRC_END	equr	d7
PSRC_CUR	equr	a4

psrcwlin:	movem.l	d3-d7/a2-a3,-(sp)
	move.l	FlshBuf,PSRC_CUR
	move.l	PSRC_CUR,PSRC_END
	add.l	#FLSHBUF_SIZE-20,PSRC_END	;-20 pour LINR

	move.l	CurLinrNb,d3		;nb struct lignes
	beq	.end
	move.l	FstLinrPtr,a2		;premiere ligne
	moveq	#0,d6			;module offset
.l1:	move.l	a2,a0			;line record
	move.l	LINR_mod(a0),d0		;module offset
	subq.l	#1,d0			;1->0
	lsl.l	#3,d0			;*=8
	move.l	d0,LINR_mod(a0)

	tst.w	OutType+2
	beq.s	.nolnk
	move.l	LINR_var(a0),d0
	bne.s	.varset
	move.w	LINR_sec(a0),d0
	lsr.w	#2,d0			;0->0 4->1
	add.w	ptotvarnb,d0
	bra.s	.asset
.varset:	move.l	d0,a1			;set var # instead of addr
	move.l	VAR_nb(a1),d0
.asset:	swap	d0
	move.l	d0,LINR_addr(a0)
	bra.s	.notdata
.nolnk:	cmp.w	#SEC_data,LINR_sec(a0)	;reloger les datas
	bne.s	.notdata
	move.l	TextSize,d0
	add.l	d0,LINR_addr(a0)
.notdata:
.wlinr:	moveq	#20/4-1,d0
.l2:	move.l	(a0)+,(PSRC_CUR)+
	dbf	d0,.l2
	cmp.l	PSRC_CUR,PSRC_END
	bgt.s	.nxtlinr
	bsr.s	.clse
	bne.s	.end

.nxtlinr:	move.l	LINR_count(a2),d5		;line number
	beq.s	.no_nb
	move.l	LINR_first(a2),a3

.wlinn:	move.w	(a3),(PSRC_CUR)+
	cmp.l	PSRC_CUR,PSRC_END
	bgt.s	.nxtlinn
	bsr.s	.clse
	bne.s	.end

.nxtlinn:	move.l	LINN_next(a3),a3
	subq.l	#1,d5
	bgt.s	.wlinn

.no_nb:	move.l	LINR_next(a2),a2
	subq.l	#1,d3
	bgt.s	.l1
	bsr.s	.clse
.end:	movem.l	(sp)+,d3-d7/a2-a3
	rts

.clse:	move.l	FlshBuf,a0
	move.l	a0,-(sp)
	move.l	PSRC_H,d1
	move.l	PSRC_CUR,d0
	sub.l	a0,d0
	bsr	write_file
	move.l	(sp)+,PSRC_CUR
	rts	

;	 #] psrcwlin:
;	 #[ psrcwsym:
;In:
;a0=var tbl
;d0=var #
psrcwsym:	movem.l	d3-d6/a2-a4/a6,-(sp)	;flushe au format pascal
	move.l	d0,d3
	beq.s	.end
	move.l	FlshBuf,a4
	move.l	a4,d6
	add.l	#FLSHBUF_SIZE,d6
	move.l	a0,a3
	move.l	PDbgnamsize,a6		;offset nom
.l1:	move.l	(a3)+,a2
	lea	14(a4),a0
	cmp.l	a0,d6
	ble.s	.doclse
.nxt:	move.b	#8,(a4)+		;type=globalfunc
	moveq	#0,d0
	move.b	VAR_sec(a2),d0
	bmi.s	.no
	lsr.b	#2,d0
	addq.b	#4,d0
	move.b	d0,(a4)+		;segment
	move.l	a6,(a4)+		;name offset
	subq.b	#4,d0
	mulu	#16,d0
	move.l	d0,(a4)+		;type offset
	move.l	VAR_value(a2),d0
	cmp.w	#PURE_OBJ,OutType+2
	bne.s	.ok
	move.l	VAR_nb(a2),d0
	swap	d0
.ok:	move.l	d0,(a4)+		;addr
	add.w	VAR_len(a2),a6	;nxt offset
	addq.w	#1,a6
	addq.l	#1,PDbgsymnb
.no:	subq.l	#1,d3
	bgt.s	.l1
	bsr.s	.clse
.end:	movem.l	(sp)+,d3-d6/a2-a4/a6
	rts
.doclse:	bsr.s	.clse
	beq.s	.nxt
	bra.s	.end

.clse:	move.l	FlshBuf,a0
	move.l	a4,d0
	sub.l	a0,d0
	beq.s	.nowrit
	add.l	d0,PDbgsymsize
	move.l	a0,-(sp)
	move.l	PSRC_H,d1
	bsr	write_file
	move.l	(sp)+,a4
.nowrit:	rts	
;	 #] psrcwsym:
;	 #[ psrcwsco:
psrcwsco:	lea	-20(sp),sp
	move.l	sp,a0
	move.w	#3,(a0)+		;class
	clr.w	(a0)+		;parent
	move.w	#1,(a0)+		;enclosed scopes
	move.w	PDbgsymnb+2,(a0)+	;sym nb
	clr.l	(a0)+		;1st sym
	moveq	#0,d0
	cmp.w	#PURE_OBJ,OutType+2
	bne.s	.ok
	move.l	ptotlvarnb,d0	;text var #
	swap	d0
.ok:	move.l	d0,(a0)+		;addr
	lea	SecSizes,a1
	move.l	(a1)+,d0
	add.l	(a1)+,d0
	add.l	(a1)+,d0
	move.l	d0,(a0)+		;length
	move.l	PSRC_H,d1
	moveq	#20,d0
	add.l	d0,PDbgscosize
	move.l	sp,a0
	bsr	write_file
	lea	20(sp),sp
	rts
;	 #] psrcwsco:
;	 #[ psrcwtyp:
psrcwtyp:	move.l	PSRC_H,d1
	moveq	#16*3,d0
	add.l	d0,PDbgtypsize
	lea	.typs(pc),a0
	bra	write_file
.typs:	dc.b	10,10		;text = void fct()
	dc.l	0,0,0
	dc.w	0
	dc.b	10,10		;data/bss = void *
	dc.l	0,0,0
	dc.w	0
	dc.b	10,10		;data/bss = void *
	dc.l	0,0,0
	dc.w	0
;	 #] psrcwtyp:
;	 #[ psrcwmna:
psrcwmna:	movem.l	d3-d7/a2,-(sp)
	move.l	FstModPtr,d0		;1st mod
	beq.s	.end
.l1:	move.l	d0,a2
	move.l	MOD_expnam(a2),a0
	STRLEN
	addq.l	#1,d0
	move.l	MOD_expnam(a2),a0
	move.l	PSRC_H,d1
	bsr	write_file
	bne.s	.end
	move.l	MOD_next(a2),d0
	bne.s	.l1
.end:	movem.l	(sp)+,d3-d7/a2
	rts
;	 #] psrcwmna:
;	 #[ psrcwgna:
;In:
;a0=var tbl
;d0=var #
psrcwgna:	movem.l	d3-d6/a2-a4,-(sp)
	move.l	d0,d3
	beq.s	.end
	move.l	FlshBuf,a4
	move.l	a4,d6
	add.l	#FLSHBUF_SIZE,d6
	move.l	a0,a3

.l1:	move.l	(a3)+,a2
	move.w	VAR_len(a2),d5
	lea	1(a4,d5.w),a0
	cmp.l	a0,d6
	ble.s	.doclse
.nxt:	subq.w	#1,d5
	move.l	VAR_start(a2),a2
.l2:	move.b	(a2)+,(a4)+
	dbf	d5,.l2
	clr.b	(a4)+
	subq.l	#1,d3
	bgt.s	.l1
	bsr.s	.clse
.end:	movem.l	(sp)+,d3-d6/a2-a4
	rts
.doclse:	bsr.s	.clse
	beq.s	.nxt
	bra.s	.end

.clse:	move.l	FlshBuf,a0
	move.l	a4,d0
	sub.l	a0,d0
	beq.s	.nowrit
	add.l	d0,PDbgnamsize
	move.l	a0,-(sp)
	move.l	PSRC_H,d1
	bsr	write_file
	move.l	(sp)+,a4
.nowrit:	rts	
;	 #] psrcwgna:
;	 #[ psrcwoff:
;In: d0=offset
psrcwoff:	cmp.w	#PURE_OBJ,OutType+2	;header offset (exec only)
	beq.s	.nooff
	move.l	d0,-(sp)
	move.l	sp,a0
	moveq	#4,d0
	add.l	d0,PDbgoffset
	move.l	PSRC_H,d1
	bsr	write_file
	addq.w	#4,sp
.nooff:	rts
;	 #] psrcwoff:
;	 #[ psrcflsh:
psrcflsh:	move.l	PSRC_H,-(sp)
	tst.w	SrcType
	beq	.end
	move.l	d0,PSRC_H
	bsr	psrcwhd		;header
	bne.s	.end
	bsr	psrcwmod		;modules
	bne.s	.end
	bsr	psrcwlin		;lines
	bne.s	.end
	tst.w	GDbgType
	beq.s	.nog1
	move.l	GloTbl,a0
	move.l	VarNb,d0
	bsr	psrcwsym
	bne.s	.end
	bsr	psrcwsco
	bne.s	.end
	bsr	psrcwtyp
	bne.s	.end
.nog1:	bsr	psrcwmna		;mod names
	bne.s	.end
	tst.w	GDbgType
	beq.s	.nog2
	move.l	GloTbl,a0
	move.l	VarNb,d0
	bsr	psrcwgna
	bne.s	.end

.nog2:	moveq	#PDbgheader_SIZEOF,d0
	lea	PDbgheader+4,a0
	moveq	#7-1,d1
.l1:	add.l	(a0)+,d0		;mod+lines+sym+sco+typ+mem+nam
	dbf	d1,.l1
	move.l	d0,PDbgoffset	;offset
	bsr	psrcwoff
	bne.s	.end
	move.l	PDbgoffset,d0
	add.l	d0,OutSize	;prgsize+=offset
	bsr	psrcuphd		;update header
;	bne.s	.end
.end:	movem.l	(sp)+,PSRC_H
	rts
;	 #] psrcflsh:
;  #] PURE src:
;  #[ PURE obj:
;	 #[ pobjwsym:
P_VARNB	equr	d2
P_LSTOFF	equr	d3
P_HANDLE	equr	d4
P_SEC	equr	d5
P_END	equr	d6
P_EXPNB	equr	d7

P_HEAD	equr	a2
P_EXP	equr	a3
P_VAR	equr	a4
P_BIN	equr	a5
P_CUR	equr	a6
;0: Null action
;1: End of object
;2: Advance
;3: Start new text segment
;4: Start new data segment
;5: Start new bss segment
;6: Start new offset segment

;7: Define new global module
;8: Define new local module
;9: Global entrypoint
;10: Local entrypoint
;11: Absolute long reference to
;12: Absolute word reference to
;13: PC-relative long reference to
;14: PC-relative word reference to
;15: Null reference to

;In:
;d0=abs EXP offset
;a0=id
;Out:
;d0=rel EXP offset
;(d1)ccr
pobjwsym:	movem.l	d1/a1,-(sp)
.l1:	tst.l	P_VARNB		;still vars?
	beq.s	.novar
	move.l	(P_VAR),a1
	addq.w	#4,P_VAR
	subq.l	#1,P_VARNB
	cmp.b	VAR_sec(a1),P_SEC	;same section?
	bne.s	.l1
	cmp.l	VAR_value(a1),d0	;before EXP offset?
	blt.s	.notthis
	move.l	d0,a0		;EXP abs offset
	move.l	VAR_value(a1),d0	;VAR abs offset
	sub.l	P_LSTOFF,d0	;VAR rel offset
	move.l	VAR_value(a1),P_LSTOFF	;lst abs offset = VAR abs offset
	bsr	advprec
	bne.s	.end
	btst	#VAR_DEFED,VAR_type(a1)
	bne.s	.xdef
	ori.w	#$0a00,d0		;new local entrypoint
	bra.s	.s1
.xdef:	ori.w	#$0800,d0		;new local module
.s1:	swap	d0
	move.w	VAR_nb+2(a1),d0
	bsr	addprec
	bne.s	.end
	move.l	a0,d0		;EXP abs offset
	bra.s	.l1
.notthis:	subq.w	#4,P_VAR
	addq.l	#1,P_VARNB
.novar:	sub.l	P_LSTOFF,d0	;EXP rel offset
	move.l	a0,P_LSTOFF	;lst abs offset = EXP abs offset
.good:	moveq	#0,d1
.end:	movem.l	(sp)+,d1/a1
	rts

pobjendsym:
	move.l	a1,-(sp)
	tst.l	P_VARNB
	beq.s	.end
.l1:	move.l	(P_VAR)+,a1
	cmp.b	VAR_sec(a1),P_SEC
	bne.s	.nxt
	move.l	VAR_value(a1),a0
	move.l	a0,d0
	sub.l	P_LSTOFF,d0
	move.l	a0,P_LSTOFF
	bsr	advprec
	bne.s	.end
	btst	#VAR_DEFED,VAR_type(a1)
	bne.s	.xdef
	ori.w	#$0a00,d0		;new local entrypoint
	bra.s	.s1
.xdef:	ori.w	#$0800,d0		;new local module
.s1:	swap	d0
	move.w	VAR_nb+2(a1),d0
	bsr	addprec
	bne.s	.end
.nxt:	subq.l	#1,P_VARNB
	bgt.s	.l1
.end:	move.l	(sp)+,a1
	rts

;	 #] pobjwsym:
;	 #[ pobjwsec:

pobjgbin:
	IFNE	_68000
	moveq	#0,d0
	move.w	EXP_bin(P_EXP),d0
	add.l	d0,d0
	add.l	d0,d0
	move.l	BinTbl,a0
	move.l	0(a0,d0.l),P_BIN
	ELSEIF
	move.w	EXP_bin(P_EXP),d0
	move.l	([BinTbl],d0*4),P_BIN
	ENDC	;_68000
	cmp.w	BIN_sec(P_BIN),P_SEC
	bne.s	.nxt
	move.l	BIN_off(P_BIN),a0
	add.w	EXP_poke(P_EXP),a0	;new offset
.nxt:	rts

;In:
;P_SEC=section
;Out:
;@ Exp block
;@ Exp
;@ Bin block
;# Bin block
;# EXP #
;ccr
pobjwsec:	movem.l	P_EXPNB/P_EXP,-(sp)
	move.l	HeadExp,d0
	beq.s	.norel
.nxtblk:	move.l	d0,P_HEAD
	move.l	HEAD_start(P_HEAD),P_EXP	;fst EXP
	move.w	HEAD_nb(P_HEAD),P_EXPNB	;#EXP in block
	subq.w	#1,P_EXPNB
.l1:	move.w	EXP_patch(P_EXP),d0		;D16,ABSW,ABSL,DCW,DCL,PCW,PCL,BDPCW,BDPCL
	move.w	.tab(pc,d0.w),d0		;deja *2
	jmp	.tab(pc,d0.w)
.nxt:	lea	EXP_SIZEOF(P_EXP),P_EXP
	dbf	P_EXPNB,.l1
	move.l	HEAD_next(P_HEAD),d0
	bne.s	.nxtblk
.norel:	moveq	#0,d0
.end:	movem.l	(sp)+,P_EXPNB/P_EXP
	rts

.relpcl:
.relbdpcl:
	tst.b	EXP_sec(P_EXP)	;generer pc relatif si xref
	bpl.s	.nxt
	bsr	pobjgbin
	bne.s	.nxt
	subq.w	#4,a0
	moveq	#13,d1
	bra.s	.wrel

.relpcw:
.relbdpcw:
	moveq	#14,d1		;generer pc relatif si xref
	bra.s	.asw

.relw:	moveq	#12,d1
.asw:	tst.b	EXP_sec(P_EXP)	;generer abs.w si xref
	bpl.s	.nxt
	bsr	pobjgbin
	bne.s	.nxt
	subq.w	#2,a0
	bra.s	.wrel

.rell:	tst.b	EXP_sec(P_EXP)	;;;;;;rien a faire
	beq.s	.nxt		;;;;;;
	bsr	pobjgbin		;generer abs.l ds ts les cas (reloc)
	bne.s	.nxt
	subq.w	#4,a0
	moveq	#11,d1
;	bra.s	.wrel
.wrel:	move.l	a0,d0
	bsr	pobjwsym
	bne.s	.end
	bsr.s	advprec
	bne.s	.end
	lsl.w	#8,d1
	or.w	d1,d0
	swap	d0
	move.w	EXP_varnb(P_EXP),d0
	tst.b	EXP_sec(P_EXP)
	bpl.s	.notxref
	add.w	VarNb+2,d0	;xrefnb+=varnb
.notxref:	bsr.s	addprec
	bne.s	.end
	bra.s	.nxt

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
	dc.w	.relw-.tab	;P_ABSW
	dc.w	.rell-.tab	;P_ABSL
	dc.w	.rrel-.tab	;P_DCB
	dc.w	.relw-.tab	;P_DCW
	dc.w	.rell-.tab	;P_DCL
	dc.w	.rpcb-.tab	;P_PCD8
	dc.w	.relpcw-.tab	;P_D16PC
	dc.w	.relpcw-.tab	;P_DBCC
	dc.w	.rpcb-.tab	;P_BCCB
	dc.w	.relpcw-.tab	;P_BCCW
	dc.w	.relpcl-.tab	;P_BCCL
	dc.w	.relbdpcw-.tab	;P_BDPCW
	dc.w	.relbdpcl-.tab	;P_BDPCL

.rrel:
.rpcb:
;	IFNE	BLINDOS
;	_Debugger
;	ENDC
	bra	.nxt

;In:
;d0=new offset
;Out:
;d0=offset<=256
;ccr
advprec:	move.l	d7,-(sp)
	move.l	d0,d7
	lsr.l	#8,d0		;advance 256
	beq.s	.no
	ori.l	#$02000000,d0
	bsr.s	addprec
	bne.s	.end
.no:	move.l	d7,d0
	and.l	#$ff,d0
	moveq	#0,d7
.end:	movem.l	(sp)+,d7
	rts

addprec:	move.l	d0,(P_CUR)+
	cmp.l	P_CUR,P_END
	ble.s	clsepsec
	moveq	#0,d0
	rts

clsepsec:	movem.l	d0-d2/a0-a1,-(sp)
	move.l	FlshBuf,a0
	move.l	a0,-(sp)
	move.l	P_HANDLE,d1
	move.l	P_CUR,d0
	sub.l	a0,d0
	add.l	d0,PObjsyminfo
	bsr	write_file
	move.l	(sp)+,P_CUR
	movem.l	(sp)+,d0-d2/a0-a1
	rts	

flshpsec:	movem.l	d3-d7/a2-a6,-(sp)
	movem.l	d0/a0,-(sp)
	move.l	d1,P_HANDLE

	move.l	FlshBuf,P_CUR
	move.l	P_CUR,P_END
	add.l	#FLSHBUF_SIZE,P_END

	moveq	#0,d7		;section name count

	movem.l	(sp),P_VARNB/P_VAR
	moveq	#0,P_LSTOFF	;;;TEXT

	tst.l	TextSize
	bne.s	.dotxt
	tst.l	TxtVarNb
	beq.s	.notxt

.dotxt:	move.l	#$0300ffff,d0	;text anonymous
	bsr	addprec
	bne	.end

	move.w	#$0900,d0		;global entrypoint
	swap	d0
	move.w	ptotvarnb,d0	;#
	bsr	addprec
	bne	.end

	moveq	#SEC_text,P_SEC
	bsr	pobjwsec
	bne	.end

	moveq	#SEC_text,P_SEC
	bsr	pobjendsym	;flusher les vars restant
	bne	.end

	addq.l	#1,d7

.notxt:	movem.l	(sp),P_VARNB/P_VAR	;;;DATA

	tst.l	DataSize
	bne.s	.dodat
	tst.l	DatVarNb
	beq.s	.nodat

.dodat:	move.l	TextSize,d0	;advance end text - lst off
	sub.l	P_LSTOFF,d0
	bsr	advprec
	bne	.end

	ori.w	#$0400,d0		;data
	swap	d0
	move.w	#-1,d0		;anonymous
	bsr	addprec
	bne	.end

	move.w	#$0900,d0		;global entrypoint
	swap	d0
	move.w	ptotvarnb,d0	;#
	add.w	d7,d0
	bsr	addprec
	bne	.end

	moveq	#0,P_LSTOFF

	moveq	#SEC_data,P_SEC
	bsr	pobjwsec
	bne	.end

	moveq	#SEC_data,P_SEC
	bsr	pobjendsym	;flusher les vars restant
	bne	.end

	addq.l	#1,d7

.nodat:	movem.l	(sp),P_VARNB/P_VAR	;;;BSS
	tst.l	BssSize
	bne.s	.dobss
	tst.l	BssVarNb
	beq.s	.nobss

.dobss:	move.l	DataSize,d0	;advance end data or text - lst off
	bne.s	.ok1
	move.l	TextSize,d0
.ok1:	sub.l	P_LSTOFF,d0
	bsr	advprec
	bne.s	.end

	ori.w	#$0500,d0		;bss
	swap	d0
	move.w	#-1,d0		;anonymous
	bsr	addprec
	bne.s	.end

	move.w	#$0900,d0		;global entrypoint
	swap	d0
	move.w	ptotvarnb,d0	;#
	add.w	d7,d0
	bsr	addprec
	bne.s	.end

	moveq	#0,P_LSTOFF

	moveq	#SEC_bss,P_SEC
	bsr	pobjendsym	;flusher les vars restant
	bne.s	.end

	addq.l	#1,d7

.nobss:	move.l	BssSize,d0
	bne.s	.ok2
	move.l	DataSize,d0
	bne.s	.ok2
	move.l	TextSize,d0
.ok2:	sub.l	P_LSTOFF,d0	;advance end mod - lst off
	bsr	advprec
	bne.s	.end
	ori.w	#$100,d0		;eoo
	swap	d0
	move.w	#-1,d0		;anonymous
	bsr	addprec
	bne.s	.end

	bsr	clsepsec		;end of module

	move.l	ptotlvarnb,d0	;<65536 vars
	swap	d0
	tst.w	d0
	bne.s	.rvar

	moveq	#0,d0
.end:	addq.w	#8,sp
	movem.l	(sp)+,d3-d7/a2-a6
	rts
.rvar:	bra	Errvar_2many

;	 #] pobjwsec:
;	 #[ pobjwonam:
;In:
;a0=var tbl
;d0=var #
;d1=handle
pobjwonam:
	movem.l	d3-d6/a2-a4,-(sp)	;flushe au format pascal
	move.l	d0,d3
	beq.s	.end
	move.l	d1,d6
	move.l	FlshBuf,a4
	move.l	a4,d4
	add.l	#FLSHBUF_SIZE,d4
	move.l	a0,a3

.l1:	move.l	(a3)+,a2
	move.w	VAR_len(a2),d5
	lea	1(a4,d5.w),a0
	cmp.l	a0,d4
	ble.s	.doclse
.nxt:	move.b	d5,(a4)+
	subq.w	#1,d5
	move.l	VAR_start(a2),a2
.l2:	move.b	(a2)+,(a4)+
	dbf	d5,.l2
	subq.l	#1,d3
	bgt.s	.l1
	bsr.s	.clse
.end:	movem.l	(sp)+,d3-d6/a2-a4
	rts
.doclse:	bsr.s	.clse
	beq.s	.nxt
	bra.s	.end

.clse:	move.l	FlshBuf,a0
	move.l	a4,d0
	sub.l	a0,d0
	beq.s	.nowrit
	add.l	d0,PObjnames
	move.l	a0,-(sp)
	move.l	d6,d1
	bsr	write_file
	move.l	(sp)+,a4
.nowrit:	rts	
;	 #] pobjwonam:
;	 #[ pobjwlnam:
;In:
;d0=loc #
;d1=handle
pobjwlnam:
	movem.l	d3-d5/a4,-(sp)	;flushe les locals
	move.l	d0,d3
	beq.s	.end
	move.l	d1,d5
	move.l	FlshBuf,a4
	move.l	a4,d4
	add.l	#FLSHBUF_SIZE,d4

.l1:	cmp.l	a4,d4
	ble.s	.doclse
.nxt:	clr.b	(a4)+
	subq.l	#1,d3
	bgt.s	.l1
	bsr.s	.clse
.end:	movem.l	(sp)+,d3-d5/a4
	rts
.doclse:	bsr.s	.clse
	beq.s	.nxt
	bra.s	.end

.clse:	move.l	FlshBuf,a0
	move.l	a4,d0
	sub.l	a0,d0
	beq.s	.nowrit
	add.l	d0,PObjnames
	move.l	a0,-(sp)
	move.l	d5,d1
	bsr	write_file
	move.l	(sp)+,a4
.nowrit:	rts	
;	 #] pobjwlnam:
;	 #[ pobjwsnam:
pobjwsnam:
	move.l	d0,d1
	moveq	#4,d0
	add.l	d0,PObjnames
	clr.l	-(sp)		;dummy names for sections
	move.l	sp,a0
	move.l	d4,d1
	bsr	write_file
	bne.s	.end
	btst	#0,PObjnames+3	;align
	beq.s	.end
	moveq	#1,d0
	add.l	d0,PObjnames
	move.l	sp,a0
	move.l	d4,d1
	bsr	write_file
.end:	addq.w	#4,sp
	rts
;	 #] pobjwsnam:
;	 #[ purewobj:

purewobj:	movem.l	d3-d7/a2-a6,-(sp)
	move.l	d0,d4

	jsr	BuildXdef

	move.l	VarNb,d3
	move.l	LocRelNb,d0
	add.l	d0,d3
	move.l	d3,d1
	add.l	XrefNb,d1
	move.l	d1,ptotlvarnb
	move.l	d3,d2			;Glo+Xref+LocRel
	add.l	d2,d2
	add.l	d2,d2			;*4
	mulu	#VAR_SIZEOF,d0		;loc var array
	add.l	d2,d0
	jsr	MyMalloc
	beq	.rmem
	move.l	d0,a3

	lea	0(a3,d2.l),a0
	bsr	.cpyvars

	lea	PObjheader,a0
	move.l	#$4efa001c,(a0)
	move.l	TextSize,d0
	add.l	DataSize,d0
	move.l	d0,4(a0)
	move.l	d4,d1
	moveq	#PObjheader_SIZEOF,d0
	bsr	write_file
	bne	.end

	move.l	d4,d0
	moveq	#SEC_text,d1
	bsr	flshbin
	bne	.end

	move.l	d4,d0
	moveq	#SEC_data,d1
	bsr	flshbin
	bne	.end

	move.l	a3,a0
	move.l	d3,d0
	jsr	QsortV			;sort by value

	move.l	a3,a0
	move.l	d3,d0
	move.l	d4,d1
	bsr	flshpsec			;flush EXP+var
	bne.s	.end

	move.l	GloTbl,a0
	move.l	VarNb,d0
	move.l	d4,d1
	bsr	pobjwonam			;flush glo names
	bne.s	.end

	move.l	XrefTbl,a0
	move.l	XrefNb,d0
	move.l	d4,d1
	bsr	pobjwonam			;flush xref name
	bne.s	.end

	move.l	LocRelNb,d0
	move.l	d4,d1
	bsr	pobjwlnam			;flush loc names
	bne.s	.end

	move.l	d4,d0
	bsr	pobjwsnam			;flush sec names
	bne.s	.end

	move.l	a3,a0
	jsr	MyMfree

	move.l	d4,d0
	bsr	psrcflsh
	bne.s	.end

	moveq	#0,d0
	move.l	d4,d1
	bsr	seek_file
	bmi.s	.end

	lea	PObjheader,a0
	tst.w	SrcType
	beq.s	.nosrc
	move.l	4(a0),d0
	add.l	8(a0),d0
	add.l	12(a0),d0
	move.l	d0,20(a0)

.nosrc:	move.l	d4,d1
	moveq	#PObjheader_SIZEOF,d0
	bsr	write_file
;	bne.s	.end

.end:	movem.l	(sp)+,d3-d7/a2-a6
	rts
.rmem:	bsr	Errfile_ram
	bra.s	.end

;In:
;a0/a3
.cpyvars:	movem.l	d3-d4/a2-a4/a6,-(sp)
	move.l	a3,a6
	move.l	a0,-(sp)
	moveq	#0,d4			;var #
	move.l	VarNb,d0
	beq.s	.noglo
	move.l	GloTbl,a1
.l1:	move.l	(a1)+,a0
	move.l	a0,(a3)+
	move.l	d4,VAR_nb(a0)
	addq.l	#1,d4
	subq.l	#1,d0
	bgt.s	.l1
.noglo:	move.l	XrefNb,d0
	beq.s	.noxref
	move.l	XrefTbl,a1
.l2:	move.l	(a1)+,a0
	move.l	d4,VAR_nb(a0)
	addq.l	#1,d4
	subq.l	#1,d0
	bgt.s	.l2
.noxref:	move.l	(sp)+,a0
	moveq	#SEC_text+1,d1
	bsr.s	.bldrel
	moveq	#SEC_data+1,d1
	bsr.s	.bldrel
	bsr.s	.clrexp
	movem.l	(sp)+,d3-d4/a2-a4/a6
	rts

.bldrel:	move.l	LocRelNb,d0
	beq.s	.norel
	move.l	HeadExp,d3
.nxtblk:	move.l	d3,a1
	move.l	HEAD_start(a1),a2
	move.w	HEAD_nb(a1),d2
	subq.w	#1,d2

.l3:	tst.b	EXP_backval(a2)	;local reloc?
	beq.s	.nxtexp
	cmp.b	EXP_sec(a2),d1	;tst SEC / XREF
	bne.s	.nxtexp

	move.l	a0,(a3)+
	move.w	d1,VAR_type(a0)	;+VAR_sec
	subq.w	#1,VAR_type(a0)
	move.l	d4,VAR_nb(a0)	;var #
	move.w	d4,EXP_varnb(a2)	;id
	addq.l	#1,d4		;var # ++

	IFNE	_68000
	moveq	#0,d3
	move.w	EXP_bin(a2),d3
	add.l	d3,d3
	add.l	d3,d3
	move.l	BinTbl,a4
	move.l	0(a4,d3.l),a4
	ELSEIF
	move.w	EXP_bin(a2),d3
	move.l	([BinTbl],d3.w*4),a4
	ENDC	;_68000
	move.l	BIN_start(a4),a4
	add.w	EXP_poke(a2),a4	;new offset
	move.l	-4(a4),VAR_value(a0)
	lea	VAR_SIZEOF(a0),a0

	subq.l	#1,d0
	beq.s	.norel

.nxtexp:	lea	EXP_SIZEOF(a2),a2
	dbf	d2,.l3
	move.l	HEAD_next(a1),d3
	bne.s	.nxtblk
.norel:	rts

.clrexp:	move.l	VarNb,d4
	add.l	LocRelNb,d4
	move.l	HeadExp,d3
	beq.s	.noexp
.nxtblk2:	move.l	d3,a1
	move.l	HEAD_start(a1),a2
	move.w	HEAD_nb(a1),d2
	subq.w	#1,d2
.l4:	move.b	EXP_sec(a2),d0	;tst RELOC
	bmi.s	.nxtexp2
	btst	#0,d0
	beq.s	.nxtexp2
	move.w	EXP_patch(a2),d0
	cmp.w	#P_ABSL,d0
	beq.s	.clr
	cmp.w	#P_DCL,d0
	bne.s	.nxtexp2
.clr:	move.w	EXP_varnb(a2),d0
	move.l	d4,d1
	move.l	a6,a0
	bsr.s	getvarnb
	IFNE	_68000
	moveq	#0,d3
	move.w	EXP_bin(a2),d3
	add.l	d3,d3
	add.l	d3,d3
	move.l	BinTbl,a4
	move.l	0(a4,d3.l),a4
	ELSEIF
	move.w	EXP_bin(a2),d3
	move.l	([BinTbl],d3.w*4),a4
	ENDC	;_68000

	move.l	BIN_start(a4),a4
	add.w	EXP_poke(a2),a4	;new offset
	sub.l	d0,-4(a4)		;unreloc

.nxtexp2:	lea	EXP_SIZEOF(a2),a2
	dbf	d2,.l4
	move.l	HEAD_next(a1),d3
	bne.s	.nxtblk2
.noexp:	rts

RECHERCHE_REG	REG	d3-d7/a2-a4

;In:
;d0.w:var #
;a0:table
;d1.l:#
;Out:
;d0.l:var value
getvarnb:	movem.l	RECHERCHE_REG,-(sp)
	move.l	d1,d7
	subq.l	#1,d7
	ble.s	.one
	move.w	d0,d3

	moveq	#0,d5
	add.l	d7,d7
	add.l	d7,d7
	moveq	#-4,d6

.boucle:	move.l	d5,d4
	add.l	d7,d4
	lsr.l	#1,d4
	and.l	d6,d4

	move.l	0(a0,d4.l),a2
	cmp.w	VAR_nb+2(a2),d3
	blt.s	.moins
	beq.s	.found

.plus:	move.l	d4,d5
	sub.l	d6,d5		;add.l	#4,d5
	cmp.l	d7,d5
	bls.s	.boucle

	bra.s	.nofound
.moins:	move.l	d4,d7
	add.l	d6,d7		;sub.l	#4,d7
	bge.s	.boucle

.nofound:
	IFNE	BLINDOS
	_Debugger
	ENDC	;BLINDOS
	moveq	#0,d0
	movem.l	(sp)+,RECHERCHE_REG
	rts

.found:	move.l	0(a0,d4.l),a0	;adresse de la structure cherchee
.asfound:	move.l	VAR_value(a0),d0
	movem.l	(sp)+,RECHERCHE_REG
	rts

.one:	bmi.s	.nofound
	move.l	(a0),a0
	cmp.w	VAR_nb+2(a0),d0
	bne.s	.nofound
	bra.s	.asfound

;	 #] purewobj:
;  #] PURE obj:
;  #[ BSD obj:
BSD_OBJ_MAGIC	equ	$107
BSD_REL_SIZEOF	equ	8

BSD_SYM_SIZEOF	equ	12
;	 #[ bsdwhdr:
;In: d0=handle
bsdwhdr:	move.l	d0,d1
	lea	bsd_hdr,a0
	move.l	a0,a1
	move.l	#BSD_OBJ_MAGIC,(a1)+
	move.l	TextSize,(a1)+
	move.l	DataSize,(a1)+
	move.l	BssSize,(a1)+
;	clr.l	(a1)+		;symbols
;	clr.l	(a1)+		;entry
;	clr.l	(a1)+		;trsize
;	clr.l	(a1)+		;drsize
	moveq	#BSD_HDR_SIZEOF,d0
	bra	write_file
;	 #] bsdwhdr:
;	 #[ bsdbrel:
;Input:
;d0=handle
;d1=data flag
;In:
;d3=data flag
;d4=bin offset
;d5=bin #
;d6=relsz
;d7=exp #
;a2=head @
;a3=exp @
;a4=handle
;a5=bin @
;a6=buf @
bsdbrel:	movem.l	d3-d7/a2-a5,-(sp)
	move.l	d0,a4		;handle
	move.l	d1,d3		;data flag
	bsr	bsdorel
	move.l	HeadExp,d0
	beq.s	.endEXP
	moveq	#0,d5		;head #
	move.l	FstBinPtr,a5	;bin @
	moveq	#0,d4		;bin off
.nxtblk:	move.l	d0,a2
	move.l	HEAD_start(a2),a3	;fst EXP
	move.w	HEAD_nb(a2),d7	;#EXP in block
	subq.w	#1,d7
;	bmi.s	.endEXP
.nxtEXP:	cmp.w	EXP_bin(a3),d5
	bne.s	.newbin
.samebin:	cmp.w	BIN_sec(a5),d3
	bne.s	.next
	move.b	EXP_sec(a3),d0
	beq.s	.next		;nothing to do
	bmi.s	.xref		;xref
	move.w	EXP_patch(a3),d0
	cmp.w	#P_D8PC,d0
	bge.s	.dopc		;all pc-rel
.asabs:	cmp.w	#P_ABSL,d0
	beq.s	.dorel		;reloc ABSL
	cmp.w	#P_DCL,d0
	bne.s	.next		;and DCL
.dorel:	moveq	#0,d0
	move.b	EXP_sec(a3),d0
	subq.w	#1,d0		;section--(reloc)
	move.l	.tabsec(pc,d0.w),d0
	moveq	#-4,d1
	bsr	bsdwrel
	bmi.s	.endEXP
.next:	lea	EXP_SIZEOF(a3),a3
	dbf	d7,.nxtEXP
	move.l	HEAD_next(a2),d0
	bne.s	.nxtblk
	bsr	bsdcrel
.endEXP:	movem.l	(sp)+,d3-d7/a2-a5
	rts
.tabsec:	dc.l	$440,$640,$840,$240	;TEXT,DATA,BSS,ABS
	IFNE	BLINDOS
.err:	_Debugger
	ENDC	BLINDOS

.newbin:	move.w	EXP_bin(a3),d5
	IFNE	_68000
	moveq	#0,d1
	move.w	d5,d1
	add.l	d1,d1
	add.l	d1,d1
	move.l	BinTbl,a1
	move.l	0(a1,d1.l),a5
	ELSEIF
	move.l	([BinTbl],d5.w*4),a5
	ENDC	;_68000
	move.l	BIN_off(a5),d4
	bra.s	.samebin

.dopc:	move.w	BIN_sec(a5),d0	;sec(sym)!=sec(bin)?asxref:asabs
	addq.w	#1,d0
	cmp.b	EXP_sec(a3),d0
	beq.s	.asabs

.xref:	move.w	EXP_patch(a3),d0
	move.w	.tab(pc,d0.w),d0	;deja *2
	jmp	.tab(pc,d0.w)

.reloc:	ror.l	#4,d0
	move.w	EXP_varnb(a3),d0
	rol.l	#8,d0
	bsr.s	bsdwrel
	bra.s	.next

.relb:	moveq	#%0001,d0
	moveq	#-1,d1
	bra.s	.reloc
.relw:	moveq	#%0011,d0
	moveq	#-2,d1
	bra.s	.reloc
.rell:	moveq	#%0101,d0
	moveq	#-4,d1
	bra.s	.reloc
.relpcb:	moveq	#%1001,d0
	moveq	#-1,d1
	bra.s	.reloc
.relbdpcw:
.relpcw:	moveq	#%1011,d0
	moveq	#-2,d1
	bra.s	.reloc

.relbdpcl:
.relpcl:
	moveq	#%1101,d0
	moveq	#-4,d1
	bra.s	.reloc

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
	dc.w	.relb-.tab	;P_D8
	dc.w	.relw-.tab	;P_D16
	dc.w	.relb-.tab	;P_ABSB
	dc.w	.relw-.tab	;P_ABSW
	dc.w	.rell-.tab	;P_ABSL
	dc.w	.relb-.tab	;P_DCB
	dc.w	.relw-.tab	;P_DCW
	dc.w	.rell-.tab	;P_DCL
	dc.w	.relpcb-.tab	;P_PCD8
	dc.w	.relpcw-.tab	;P_D16PC
	dc.w	.relpcw-.tab	;P_DBCC
	dc.w	.relpcb-.tab	;P_BCCB
	dc.w	.relpcw-.tab	;P_BCCW
	dc.w	.relpcl-.tab	;P_BCCL
	dc.w	.relbdpcw-.tab	;P_BDPCW
	dc.w	.relbdpcl-.tab	;P_BDPCL

.rrel:
	IFNE	BLINDOS
	_Debugger
	ENDC
	bra	.next

bsdorel:	move.l	FlshBuf,a6	;rel buf
	moveq	#0,d6		;rel size
	rts

;In:
;d0=bitfield
;d1=offset
bsdwrel:	cmp.l	#FLSHBUF_SIZE-BSD_REL_SIZEOF,d6
	ble.s	.poke
	bsr.s	bsdcrel
	bmi.s	.end
	bsr	bsdorel
.poke:	move.l	d4,a0
	add.w	EXP_poke(a3),a0
	add.l	d1,a0		;would be .tab(pc,patch)
	move.l	a0,(a6)+
	move.l	d0,(a6)+
	addq.l	#BSD_REL_SIZEOF,d6
.end:	rts

bsdcrel:	movem.l	d0-d1,-(sp)
	move.l	d6,d0
	beq.s	.none		;ccr ok (!N)
	lea	bsd_trsize,a0	;update trel or drel
	add.l	d6,0(a0,d3.w)
	move.l	a4,d1
	move.l	FlshBuf,a0
	bsr	write_file
.none:	movem.l	(sp)+,d0-d1
	rts

;	 #] bsdbrel:
;	 #[ bsdwxref:
;Input: d0=handle
;In:
;d3=stroff
;d4=handle
;d5=xref magic
;d6=sym size
;d7=xrefnb
;a2=xreftbl @
;a3=var @
;a4=symbuf
bsdwxref:	movem.l	d3-d7/a2-a4,-(sp)
	move.l	d0,d4		;handle
	move.l	bsd_strsz,d3	;str off
	moveq	#1,d5
	ror.l	#8,d5		;xref=EXT+UNDEF
	moveq	#0,d6		;sym size
	move.l	XrefTbl,a2
	lea	-BSD_SYM_SIZEOF(sp),sp
	move.l	sp,a4
	move.l	XrefNb,d7
	beq.s	.good
.l0:	move.l	(a2)+,a3		;var
	move.l	a4,a1
	move.l	d3,(a1)+		;name
	move.l	d5,(a1)+		;type
	move.l	VAR_value(a3),(a1)+	;value
	moveq	#1,d0
	add.w	VAR_len(a3),d0
	add.l	d0,d3		;strsz+=strlen(var)+1
	move.l	a4,a0
	moveq	#BSD_SYM_SIZEOF,d0	;length
	move.l	d4,d1
	bsr	write_file
	bne.s	.clse
	add.l	#BSD_SYM_SIZEOF,d6
.nx_var:	subq.l	#1,d7
	bgt.s	.l0
	add.l	d6,bsd_ssize
	move.l	d3,bsd_strsz
.good:	moveq	#0,d0
.clse:	lea	BSD_SYM_SIZEOF(sp),sp
	movem.l	(sp)+,d3-d7/a2-a4
	rts
;	 #] bsdwxref:
;	 #[ bsdwxdef:
;Input: d0=handle
;In:
;d3=stroff
;d4=handle
;d5=xdef magic
;d6=sym size
;d7=xdefnb
;a2=xdeftbl @
;a3=var @
;a4=symbuf
bsdwxdef:	movem.l	d3-d7/a2-a4,-(sp)
	move.l	d0,d4		;handle
	move.l	bsd_strsz,d3	;str off
	moveq	#0,d6		;sym size
	move.l	XdefTbl,a2
	lea	-BSD_SYM_SIZEOF(sp),sp
	move.l	sp,a4
	move.l	XdefNb,d7
	beq.s	.good
.l0:	move.l	(a2)+,a3		;var
	move.l	a4,a1
	move.l	d3,(a1)+		;name
	move.b	VAR_sec(a3),d0
	and.w	#%1100,d0
	move.l	.tab(pc,d0.w),(a1)+	;type
	lea	BsdOffsets,a0
	move.l	0(a0,d0.w),d0
	add.l	VAR_value(a3),d0
	move.l	d0,(a1)+		;value
	moveq	#1,d0
	add.w	VAR_len(a3),d0
	add.l	d0,d3		;strsz+=strlen(var)+1
	move.l	a4,a0
	moveq	#BSD_SYM_SIZEOF,d0	;length
	move.l	d4,d1
	bsr	write_file
	bne.s	.clse
	add.l	#BSD_SYM_SIZEOF,d6
.nx_var:	subq.l	#1,d7
	bgt.s	.l0
	add.l	d6,bsd_ssize
	move.l	d3,bsd_strsz
.good:	moveq	#0,d0
.clse:	lea	BSD_SYM_SIZEOF(sp),sp
	movem.l	(sp)+,d3-d7/a2-a4
	rts
.tab:	dc.l	5<<24,7<<24,9<<24,3<<24	;TEXT,DATA,BBS,ABS (section=abs)
;	 #] bsdwxdef:
;	 #[ bsdwsym:
;Input: d0=handle
;In:
;d3=stroff
;d4=handle
;d5=(none)
;d6=sym size
;d7=xdefnb
;a2=xdeftbl @
;a3=var @
;a4=symbuf
bsdwsym:	movem.l	d3-d7/a2-a4,-(sp)
	move.l	d0,d4
	move.l	bsd_strsz,d3	;str off
;	moveq	#0,d5		;sym=none (this is clr)
	moveq	#0,d6		;sym size
	move.l	GloTbl,a2
	lea	-BSD_SYM_SIZEOF(sp),sp
	move.l	sp,a4
	move.l	VarNb,d7
	beq.s	.good
.l0:	move.l	(a2)+,a3
	move.l	a4,a1
	move.l	d3,(a1)+		;name
	moveq	#0,d0
	move.b	VAR_sec(a3),d0
	and.w	#%1100,d0
	moveq	#0,d1
	move.w	.tab+2(pc,d0.w),d1	;type
	btst	#VAR_DEFED,VAR_type(a3)
	beq.s	.noxdef
	bset	#0,d1		;xdef=EXT
.noxdef:	ror.l	#8,d1
	move.l	d1,(a1)+		;type
	lea	BsdOffsets,a0
	move.l	0(a0,d0.w),d0
	add.l	VAR_value(a3),d0
	move.l	d0,(a1)+		;value
	moveq	#1,d0
	add.w	VAR_len(a3),d0
	add.l	d0,d3		;strsz+=strlen(var)+1
	move.l	a4,a0
	moveq	#BSD_SYM_SIZEOF,d0	;length
	move.l	d4,d1
	bsr	write_file
	bne.s	.clse
	add.l	#BSD_SYM_SIZEOF,d6
.nx_var:	subq.l	#1,d7
	bgt.s	.l0
	add.l	d6,bsd_ssize
	move.l	d3,bsd_strsz
.good:	moveq	#0,d0
.clse:	lea	BSD_SYM_SIZEOF(sp),sp
	movem.l	(sp)+,d3-d7/a2-a4
	rts
.tab:	dc.l	4,6,8,2	;TEXT,DATA,BBS,ABS (section=abs)
;	 #] bsdwsym:
;	 #[ bsdbstrs:
;Input:d0=handle
;d3=var #
;d4=handle
;a2=Glo @
;a3=buf size
;a4=buf @
bsdlstrs:
.l0:	move.l	(a2)+,a0

	cmp.l	#FLSHBUF_SIZE-256-6,a3	;for even+0L
	ble.s	.poke
	bsr	bsdcstrs
	bmi.s	.clse
	bsr	bsdostrs
.poke:	move.w	VAR_len(a0),d0
	lea	1(a3,d0.w),a3
	subq.w	#1,d0
	move.l	VAR_start(a0),a0
.l1:	move.b	(a0)+,(a4)+
	dbf	d0,.l1
	clr.b	(a4)+
.next:	subq.l	#1,d3
	bgt.s	.l0
.good:	moveq	#0,d0
.clse:	rts

bsdbstrs:	movem.l	d3-d4/a2-a4,-(sp)
	move.l	d0,d4		;handle
	bsr.s	bsdostrs

	move.l	XrefNb,d3
	beq.s	.noxref
	move.l	XrefTbl,a2
	bsr	bsdlstrs
	bmi.s	.clse

.noxref:	tst.w	DbgType
	bne.s	.allsym

	move.l	XdefNb,d3
	beq.s	.end
	move.l	XdefTbl,a2
	bsr	bsdlstrs
	bmi.s	.clse
	bra.s	.end

.allsym:	move.l	VarNb,d3
	beq.s	.end
	move.l	GloTbl,a2
	bsr	bsdlstrs
	bmi.s	.clse

.end:	addq.w	#1,a3
	move.l	a3,d0
	bclr	#0,d0
	move.l	d0,a3
	move.l	FlshBuf,a0	;poke stupid 0L
	clr.l	0(a0,a3.l)
	addq.w	#4,a3
	bsr.s	bsdcstrs
.clse:	movem.l	(sp)+,d3-d4/a2-a4
	rts

bsdostrs:	move.l	FlshBuf,a4
	suba.l	a3,a3
	rts

bsdcstrs:	move.l	a0,-(sp)
	move.l	a3,d0
	beq.s	.none		;ccr ok (!N)
	move.l	d4,d1
	move.l	FlshBuf,a0
	bsr	write_file
.none:	move.l	(sp)+,a0
	rts
;	 #] bsdbstrs:
;	 #[ bsdwobj:
;In:d0.l=handle
bsdwobj:	move.l	d4,-(sp)
	tst.w	XrefNb		;<=$ffffff	should be tst.b
	bne	.rvar

	move.l	d0,d4

;	move.l	d4,d0
	bsr	bsdwhdr
	bne	.clse

	move.l	d4,d0
	moveq	#SEC_text,d1
	bsr	flshbin
	bne.s	.clse
	move.l	d4,d0
	moveq	#SEC_data,d1
	bsr	flshbin
	bne.s	.clse

	move.l	d4,d0
	moveq	#SEC_text,d1	;text
	bsr	bsdbrel
	bne.s	.clse
	move.l	d4,d0
	moveq	#SEC_data,d1	;data
	bsr	bsdbrel
	bne.s	.clse

	moveq	#4,d0		;init string table size to 4
	move.l	d0,bsd_strsz

	move.l	d4,d0
	bsr	bsdwxref
	bne.s	.clse
	jsr	BuildXdef
	move.l	d4,d0
	tst.w	DbgType
	bne.s	.dbg
	bsr	bsdwxdef
	bne.s	.clse
	bra.s	.strs
.dbg:	bsr	bsdwsym
	bne.s	.clse
.strs:	lea	bsd_strsz,a0
	moveq	#4,d0
	move.l	d4,d1
	bsr	write_file
	bne.s	.clse
	move.l	d4,d0
	bsr	bsdbstrs
	bne.s	.clse

	moveq	#0,d0
	move.l	d4,d1
	bsr	seek_file
	bmi.s	.clse

	move.l	d4,d0
	bsr	bsdwhdr
;	bne.s	.clse

.clse:	movem.l	(sp)+,d4		;keep ccr
	rts
.rvar:	bra.s	Errvar_2many
;	 #] bsdwobj:
;  #] BSD obj:
;  #[ Errors:
Errincbin:
	move	#read_errno,d0
Errfile_ram:
	move	#fileram_errno,d0
	bra.s	flshperr
Errfile_create:
	move	#create_errno,d0
	bra.s	flshperr
Errfile_write:
	move	#write_errno,d0
	bra.s	flshperr
Errvar_2many:
	move	#var_2many_errno,d0
;	bra.s	flshperr
flshperr:	neg.w	d0
	lea	flshmsg,a0
	move.w	#MSG_FATL,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	clr.l	MSG_lnb(a0)
	clr.l	MSG_mod(a0)
	clr.l	MSG_ln(a0)
	jmp	OutMsg
;  #] Errors:
;  #[ BSS:
	BSS
;;;	ALL
BinTbl:		ds.l	1	;@ tableau ptr sur les binaires
OutSize:		ds.l	1	;taille du binaire genere sur disque
IncbinSize:	ds.l	1	;max incbin size
IncbinPtr:	ds.l	1	;max incbin buffer

;;;	DRI
prg_hdr:				;tos prg header
prg_magic:	ds.w	1
prg_tsize:	ds.l	1
prg_dsize:	ds.l	1
prg_bsize:	ds.l	1
prg_ssize:	ds.l	1
		ds.l	1	;reserved
prg_flags:	ds.l	1	;Bit 0:Clear only BSS/1:Load TTRAM/2:Malloc TTRAM
		ds.w	1	;abs
relsize:		ds.l	1	;REL max size
rellast:		ds.l	10	;save buffer
rellstoff:	ds.l	1	;REL last offset
imgflg:		ds.w	1	;if DRI image

;;;	PURE
PDbgheader:	ds.l	1	;'QDB1'
PDbgmodsize:	ds.l	1
PDbglinsize:	ds.l	1
PDbgsymsize:	ds.l	1
PDbgscosize:	ds.l	1
PDbgtypsize:	ds.l	1
PDbgmemsize:	ds.l	1
PDbgnamsize:	ds.l	1
PDbgheader_SIZEOF	equ	*-PDbgheader
PDbgoffset:	ds.l	1	;header offset
PDbgsymnb:	ds.l	1	;sym tot nb
PObjheader:	ds.l	1	;$4efa001c
PObjimgsz:	ds.l	1	;image size
PObjsyminfo:	ds.l	1	;symbols size
PObjnames:	ds.l	1	;name size
PObjversion:	ds.l	1	;0?
PObjdebug:	ds.l	1	;debug offset
		ds.l	2	;reserved?
PObjheader_SIZEOF	equ	*-PObjheader
ptotlvarnb:	ds.w	1	;same as vv but long
ptotvarnb:	ds.w	1	;Pure total vars #

;;;	BSD
bsd_hdr:				;BSD header
bsd_magic:	ds.l	1
bsd_tsize:	ds.l	1
bsd_dsize:	ds.l	1
bsd_bsize:	ds.l	1
bsd_ssize:	ds.l	1
bsd_entry:	ds.l	1
bsd_trsize:	ds.l	1
bsd_drsize:	ds.l	1
BSD_HDR_SIZEOF	equ	*-bsd_hdr
bsd_strsz:	ds.l	1
flshmsg:		ds.b	MSG_SIZEOF
;  #] BSS:
	END


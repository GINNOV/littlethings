	XDEF	FstBinPtr,CurBinNb,FstBinBuffer,BinBuffer
	XDEF	CurBinPtr,EndBinBuffer,LstBinNb
	XDEF	FstModPtr,CurModNb,TotModNb
	XDEF	FstLinrPtr,CurLinrNb,CurLinnNb
	XDEF	BinAlloc
	IFNE	AMIGA
	XREF	CurSecPtr
	XDEF	LinrEnd
	ENDC

;EndLinn:	move.l	CurLinnPtr,a0
;	move.l	CurLinrPtr,a1
;a0=linn
;a1=linr
;code>255 pas gere!!!!!!!!!!! A FAIRE
linn_set:	move.l	CurLNb,d0			;line increment
	sub.l	LINR_base(a1),d0
	sub.l	LINR_curbase(a1),d0
	move.l	#255,d1
.l1:	cmp.l	d1,d0
	ble.s	.lessFF
	sub.l	d1,d0
	move.b	d1,LINN_inc(a0)
	clr.b	LINN_off(a0)
	add.l	d1,LINR_curbase(a1)		;update for next
	movem.l	d0-d1,-(sp)
	bsr.s	linn_alloc
	bsr.s	linn_link
	movem.l	(sp)+,d0-d1
	bra.s	.l1
.lessFF:	move.b	d0,LINN_inc(a0)
	add.l	d0,LINR_curbase(a1)		;update for next
	move.l	SecSize,d0		;code offset
	sub.l	LINR_addr(a1),d0
	sub.l	LINR_curaddr(a1),d0
	move.b	d0,LINN_off(a0)
	add.l	d0,LINR_curaddr(a1)		;update for next
	add.l	d0,LINR_size(a1)
.end:	rts

;a0=new linn to link
;returns a1 = CurLinrPtr !!
linn_link:
	move.l	CurLinnPtr,a1		;first is NULL
	clr.l	LINN_next(a0)		;next is null
	move.l	a1,d0			;next from old
	beq.s	.first
	move.l	a0,LINN_next(a1)
.first:	move.l	a0,CurLinnPtr		;current
	addq.l	#1,CurLinnNb		;sert pour le nb et la taille finale

	move.l	CurLinrPtr,a1		;current line record
	addq.l	#1,LINR_count(a1)		;more one line number
	tst.l	LINR_first(a1)		;first?
	bne.s	.not_fst
	move.l	a0,LINR_first(a1)
	clr.l	LINR_curaddr(a1)
	clr.l	LINR_curbase(a1)
.not_fst:	rts

linn_alloc:
	move.l	CurLinnBlock,d0
	move.l	d0,a0
	beq.s	.alloc
.got:	move.l	MEMBLOCK_cur(a0),d0
	addq.l	#LINN_SIZEOF,d0
	cmp.l	MEMBLOCK_end(a0),d0
	bhi.s	.alloc
	move.l	MEMBLOCK_cur(a0),d0
	addq.l	#LINN_SIZEOF,MEMBLOCK_cur(a0)
	move.l	d0,a0
	rts
.alloc:	move.l	a1,-(sp)
	move.l	a0,a1
	move.l	#MEMBLOCK_SIZEOF+LINN_SIZEOF*1000,d0
	jsr	MyMalloc
	move.l	d0,CurLinnBlock
	beq.s	.errmem
	move.l	d0,a0
	move.l	a1,d0	;prev
	beq.s	.fst
	move.l	a0,MEMBLOCK_next(a1)	;link
.l1:	lea	MEMBLOCK_SIZEOF(a0),a1
	move.l	a1,MEMBLOCK_cur(a0)
	lea	LINN_SIZEOF*1000(a1),a1
	move.l	a1,MEMBLOCK_end(a0)
	clr.l	MEMBLOCK_next(a0)
	move.l	(sp)+,a1
	bra.s	.got
.fst:	move.l	a0,LinnMemHead
	bra.s	.l1
.errmem:	bra	Errlinn_ram

LinnAlloc:
	tst.w	MacStuff+MacNestCnt
	bne.s	._end
	movem.l	d0-a2,-(sp)
	tst.l	FstLinrPtr
	beq.s	.fst
	move.l	CurLinrPtr,a1		;first is NULL
	move.l	LINR_mod(a1),d0
	cmp.l	CurModNb,d0
	bne.s	.new
	move.w	LINR_sec(a1),d0
	cmp.w	CurSection,d0
	beq.s	.same			;plutot rechercher
.new:	bsr	LinrGetBlk		;l'ancien de la bonne sec
	suba.l	a1,a1
	bsr.s	linr_set
.same:	bsr	linn_alloc
	bsr	linn_link
	bsr	linn_set
.end:	movem.l	(sp)+,d0-a2
._end:	rts
.fst:	bsr	LinrGetBlk
	suba.l	a1,a1
	bsr.s	linr_set
	move.l	a0,FstLinrPtr
	bra.s	.same

;a0=line record
;a1=var @
linr_set:	;first is NULL
	move.l	a1,LINR_var(a0)		;VAR @
	move.l	CurLinrPtr,a1
	clr.l	LINR_next(a0)		;next is null
	move.l	a1,d0			;next from old
	beq.s	.first
	move.l	a0,LINR_next(a1)
.first:	move.l	a0,CurLinrPtr		;current
	addq.l	#1,CurLinrNb		;sert pour le nb et la taille finale

	move.l	CurModNb,LINR_mod(a0)	;# current module (relocated & -1 at flush time)
	move.l	SecSize,LINR_addr(a0)	;binary (text) offset
	move.w	CurSection,LINR_sec(a0)	;current section
	clr.l	LINR_size(a0)		;code length
	move.l	CurLNb,d0		;start line
	subq.l	#1,d0			;1->0
.nosub:	move.l	d0,LINR_base(a0)
	clr.l	LINR_count(a0)		;lines # (updated by AllocLinnBuffer)
	clr.l	LINR_first(a0)		;first line number struct (updated by AllocLinnBuffer)
	rts

;In: a0 = var @
LinrAlloc:
	move.w	CurSecType,d0		;forbid OFFSET & BSS
	bmi.s	.no
	cmp.w	#SEC_bss,d0
	beq.s	.no
	movem.l	a0/a2,-(sp)
	IFNE	AMIGA
	move.w	CurSection,d0
	ENDC
	move.l	CurLinrPtr,d1
	beq.s	.fst
	move.l	d1,a0
	cmp.w	LINR_sec(a0),d0		;if not same sec, no last linn
	bne.s	.fst			;(should be set already)
	bsr	linn_alloc		;creer le dernier linn du linr precedent
	bsr	linn_link
	bsr	linn_set
.fst:	bsr.s	LinrGetBlk
	movem.l	(sp),a1/a2		;only to get a0->a1
	bsr	linr_set
	tst.l	FstLinrPtr
	bne.s	.end
	move.l	a0,FstLinrPtr
.end:	movem.l	(sp)+,a0/a2
.no:	rts

;Out: a0=LINR @
LinrGetBlk:
	move.l	CurLinrBlock,d0
	move.l	d0,a0
	beq.s	.alloc
.got:	move.l	MEMBLOCK_cur(a0),d0
	add.l	#LINR_SIZEOF,d0
	cmp.l	MEMBLOCK_end(a0),d0
	bhi.s	.alloc
	move.l	MEMBLOCK_cur(a0),d0
	add.l	#LINR_SIZEOF,MEMBLOCK_cur(a0)
	move.l	d0,a0
	rts
.alloc:	move.l	a1,-(sp)
	move.l	a0,a1
	move.l	#MEMBLOCK_SIZEOF+LINR_SIZEOF*200,d0
	jsr	MyMalloc
	move.l	d0,CurLinrBlock
	beq.s	.errmem
	move.l	d0,a0
	move.l	a1,d0	;prev
	beq.s	.fst
	move.l	a0,MEMBLOCK_next(a1)	;link
.l1:	lea	MEMBLOCK_SIZEOF(a0),a1
	move.l	a1,MEMBLOCK_cur(a0)
	lea	LINR_SIZEOF*200(a1),a1
	move.l	a1,MEMBLOCK_end(a0)
	clr.l	MEMBLOCK_next(a0)
	move.l	(sp)+,a1
	bra.s	.got
.fst:	move.l	a0,LinrMemHead
	bra.s	.l1
.errmem:	bra	Errlinr_ram

LinrEnd:	move.w	CurSecType,d0		;forbid OFFSET & BSS
	bmi.s	.no
	cmp.w	#SEC_bss,d0
	beq.s	.no
	tst.l	CurLinrPtr
	beq.s	.no
	bsr	linn_alloc		;creer le dernier linn du linr precedent
	bsr	linn_link
	bsr.s	linn_end	;bsr	linn_set
.no:	rts

linn_end:	clr.b	LINN_inc(a0)
	add.l	d0,LINR_curbase(a1)		;update for next
	move.l	SecSize,d0		;code offset
	sub.l	LINR_addr(a1),d0
	sub.l	LINR_curaddr(a1),d0
	move.b	d0,LINN_off(a0)
	add.l	d0,LINR_curaddr(a1)		;update for next
	add.l	d0,LINR_size(a1)
	rts

;In: a0=@expname
;Uses SrcCurName to get orgname
ModAlloc:	movem.l	d1-a3,-(sp)
	move.l	a0,a3
	STRLEN
	move.l	d0,d1
	;ajouter la taille du nom du (nouveau) source courant a la taille des noms
	lea	SrcCurName,a0
	STRLEN
	add.l	d1,d0
	add.l	#MOD_SIZEOF+2,d0	;place pour le 2*(nom+0 final)+structure
	tst.b	IEnvFlg		;allouer ds AEdit
	beq.s	.noenv
	move.l	IEnvPtr,a0
	move.l	IENV_alloc(a0),a0
	jsr	(a0)
	bra.s	.aalloc
.noenv:	bsr	MyMalloc
.aalloc:	beq	.rmem
	move.l	d0,a2
	move.l	CurModPtr,MOD_father(a2)	;is included in
	clr.l	MOD_next(a2)		;next is null
	move.l	LastModPtr,a1		;first is NULL
	move.l	a1,MOD_prev(a2)		;old is previous
	beq.s	.first
	move.l	a2,MOD_next(a1)		;next from old
.first:	move.l	a2,CurModPtr		;current
	move.l	a2,LastModPtr
	addq.l	#1,LastModNb	;servira de reference a Lin
	move.l	LastModNb,CurModNb
	addq.l	#1,TotModNb
	move.l	CurModNb,MOD_num(a2)
	lea	MOD_SIZEOF(a2),a0	;orgname
	move.l	a0,MOD_orgnam(a2)
	move.l	a0,a1		;SrcCurName->orgname
	lea	SrcCurName,a0
	STRCPY
	move.l	a1,MOD_expnam(a2)	;expname
	move.l	a3,a0
	STRCPY
	clr.l	MOD_curoffs(a2)
	clr.l	MOD_headed(a2)
	clr.l	MOD_cured(a2)
	moveq	#1,d0
	movem.l	(sp)+,d1-a3
	rts
.rmem:	bra	Errmod_ram

;appele au lieu de ModAlloc pour un source present en IEnv
;In: a0=new module
;garbage rien
ModUpdate:
	move.l	a1,-(sp)
	move.l	CurModPtr,MOD_father(a0)
	clr.l	MOD_next(a0)		;next is null
	move.l	LastModPtr,a1		;first is NULL
	move.l	a1,MOD_prev(a0)		;old is previous
	beq.s	.first
	move.l	a0,MOD_next(a1)		;next from old
.first:	move.l	a0,CurModPtr		;current
	move.l	a0,LastModPtr
	addq.l	#1,LastModNb	;servira de reference a Lin
	move.l	LastModNb,CurModNb
	addq.l	#1,TotModNb
	move.l	CurModNb,MOD_num(a0)

	clr.l	MOD_curoffs(a0)
	move.l	MOD_headed(a0),d0
	move.l	d0,MOD_cured(a0)		;current is head block
	move.l	d0,HeadEditBlock
	move.l	d0,CurEditBlock
	move.l	(sp)+,a1
	rts
.errmem:	bra	Errmod_ram

;a0 seul touche
GetBinBuffer:
	move.l	a1,-(sp)
	move.l	BinBuffer,a0
	lea	22(a0),a1
	cmp.l	EndBinBuffer,a1
	bge.s	.realloc
.end:	move.l	(sp)+,a1
	rts
.realloc:	move.l	d0,-(sp)
	bsr.s	UpdateBinBuffer
	bsr.s	BinAlloc
	move.l	d0,a0
	move.l	(sp)+,d0
	bra.s	.end

UpdateBinBuffer:
	movem.l	d0/a0,-(sp)
	move.l	CurBinPtr,d0
	beq.s	.end
	move.l	d0,a0
	move.l	BinBuffer,BIN_cur(a0)	;updater l'adresse de fin
.end:	movem.l	(sp)+,d0/a0
	rts

AllocBin:	moveq	#BIN_SIZEOF,d0
	bsr	MyMalloc
	beq.s	.errmem
	rts
.errmem:	bra	Errbin_ram

;liste des blocs binaires alloues:
;adresse debut
;adresse courante (=adresse de fin effective quand block plus utilise)
;adresse fin
;Out:
;d0=new block
BinAlloc:	movem.l	d1-d3/a0-a1,-(sp)
	move.l	#BIN_block_size,d3
	moveq	#BIN_SIZEOF,d0
	add.l	d3,d0
	bsr	MyMalloc		;block binaire+header
	beq.s	.errmem
	move.l	d0,a0
	moveq	#BIN_SIZEOF,d1
	add.l	d1,d0
	btst	#0,SecSize+3
	beq.s	.even
	addq.l	#1,d0		;odd
	subq.l	#1,d3		;size--
.even:	bsr.s	BinLink
	move.l	a0,CurBinPtr
	IFNE	AMIGA
	move.l	CurSecPtr,a1
	tst.l	SECTION_bin_bl(a1)
	bne.s	.deja
	move.l	a0,SECTION_bin_bl(a1)
	move.l	d0,SECTION_bin_start(a1)
	ENDC
.deja:	move.w	CurSection,BIN_sec(a0)
	move.l	SecSize,BIN_off(a0)
	move.l	d0,BIN_start(a0)
	move.l	d0,BIN_cur(a0)
	move.l	d0,FstBinBuffer
	move.l	d0,BinBuffer
	move.l	d0,d1
	add.l	d3,d1
	move.l	d1,BIN_end(a0)
	move.l	d1,EndBinBuffer
	movem.l	(sp)+,d1-d3/a0-a1
	rts
.errmem:	bra	Errbin_ram

BinLink:	movem.l	d0/a1,-(sp)
	tst.l	FstBinPtr
	bne.s	.nofst
	move.l	a0,FstBinPtr
	clr.l	BIN_prev(a0)	;first
	bra.s	.after
.nofst:	move.l	LstBinPtr,d0
	bne.s	.cur
	move.l	FstBinPtr,d0
.cur:	move.l	d0,a1
	move.l	a1,BIN_prev(a0)	;prev()
	move.l	a0,BIN_next(a1)	;next()
.after:	clr.l	BIN_next(a0)	;last
	move.l	a0,LstBinPtr
	addq.w	#1,LstBinNb
	move.w	LstBinNb,CurBinNb
	movem.l	(sp)+,d0/a1
	rts

;In: d0.l taille a poker
;    a0=@ buffer
PokeBinBuffer:
	movem.l	d1-d3/a1-a2,-(sp)
	tst.b	SecPokeFlg
	beq.s	.err
	move.l	d0,d3
.nextblk:	move.l	BinBuffer,d1
	bne.s	.bin_ok
	move.l	a0,a2
	bsr	GetBinBuffer
	move.l	BinBuffer,d1
	move.l	a2,a0
.bin_ok:	move.l	d1,a1
	lea	0(a1,d0.w),a2
	cmp.l	EndBinBuffer,a2
	bge.s	.full
	move.l	a2,BinBuffer
	add.l	d0,SecSize
	sub.l	d0,d3
	subq.w	#1,d0
.cp:	move.b	(a0)+,(a1)+
	dbf	d0,.cp
	move.l	d3,d0
	bne.s	.nextblk
.end:	movem.l	(sp)+,d1-d3/a1-a2
	rts
.err:	jsr	Errdata_in_bss
	bra.s	.end
.full:	move.l	EndBinBuffer,d0
	sub.l	a1,d0
	add.l	d0,SecSize
	sub.l	d0,d3
	subq.w	#1,d0
	bpl.s	.cp1
	moveq	#0,d0
	bra.s	.alloc	;on peut rien poker
.cp1:	move.b	(a0)+,(a1)+
	dbf	d0,.cp1
	move.l	a1,BinBuffer
	move.l	a0,a2
.alloc:	bsr	UpdateBinBuffer
	bsr	BinAlloc
	move.l	a2,a0
	move.l	d3,d0
	bra	.nextblk

;In: d1.b a poker,d0.l=nbre d'occurences
FillBBinBuffer:
	movem.l	d1-d4/a1-a2,-(sp)
	tst.b	SecPokeFlg
	beq.s	.err
	move.l	d0,d3
	beq.s	.end
	move.b	d1,d4
.nextblk:	move.l	BinBuffer,d1
	bne.s	.bin_ok
	bsr	GetBinBuffer
	move.l	BinBuffer,d1
.bin_ok:	move.l	d1,a1
	lea	0(a1,d0.l),a2
	cmp.l	EndBinBuffer,a2
	bge.s	.full
	move.l	a2,BinBuffer
	add.l	d0,SecSize
	sub.l	d0,d3
	move.l	d0,d1
	beq.s	.end
	swap	d1
	subq.w	#1,d0
.cp:	move.b	d4,(a1)+
	dbf	d0,.cp
	dbf	d1,.cp
	move.l	d3,d0
	bne.s	.nextblk
.end:	movem.l	(sp)+,d1-d4/a1-a2
	rts
.err:	jsr	Errdata_in_bss
	bra.s	.end
.full:	move.l	EndBinBuffer,d0
	sub.l	a1,d0
	add.l	d0,SecSize
	sub.l	d0,d3
	subq.w	#1,d0
	bmi.s	.alloc	;on peut rien poker
.cp1:	move.b	d4,(a1)+
	dbf	d0,.cp1
	move.l	a1,BinBuffer
.alloc:	bsr	UpdateBinBuffer
	bsr	BinAlloc
	move.l	d3,d0
	bra.s	.nextblk

;In: d1.w a poker,d0.l=nbre d'occurences
FillWBinBuffer:
	movem.l	d1-d4/a1-a2,-(sp)
	tst.b	SecPokeFlg
	beq.s	.err
	add.l	d0,d0
	move.l	d0,d3
	move.w	d1,d4
.nextblk:	move.l	BinBuffer,d1
	bne.s	.bin_ok
	bsr	GetBinBuffer
	move.l	BinBuffer,d1
.bin_ok:	move.l	d1,a1
	lsr.w	#1,d1
	bcc.s	.pair
	addq.l	#1,SecSize
	clr.b	(a1)+
	move.l	a1,BinBuffer
	jsr	Err_even
.pair:	lea	0(a1,d0.l),a2
	cmp.l	EndBinBuffer,a2
	bge.s	.full
	move.l	a2,BinBuffer
	add.l	d0,SecSize
	sub.l	d0,d3
	lsr.l	#1,d0
	move.l	d0,d1
	beq.s	.end
	swap	d1
	subq.w	#1,d0
.cp:	move.w	d4,(a1)+
	dbf	d0,.cp
	dbf	d1,.cp
	move.l	d3,d0
	bne.s	.nextblk
.end:	movem.l	(sp)+,d1-d4/a1-a2
	rts
.err:	jsr	Errdata_in_bss
	bra.s	.end
.full:	move.l	EndBinBuffer,d0
	sub.l	a1,d0
	add.l	d0,SecSize
	sub.l	d0,d3
	lsr.l	#1,d0
	move.l	d0,d1
	swap	d1
	subq.w	#1,d0
	bmi.s	.alloc ;on peut rien poker
.cp1:	move.w	d4,(a1)+
	dbf	d0,.cp1
	dbf	d1,.cp1
	move.l	a1,BinBuffer
.alloc:	bsr	UpdateBinBuffer
	bsr	BinAlloc
	move.l	d3,d0
	bra	.nextblk

;In: d1.l a poker,d0.l=nbre d'occurences
FillLBinBuffer:
	movem.l	d1-d4/a1-a2,-(sp)
	tst.b	SecPokeFlg
	beq.s	.err
	add.l	d0,d0
	add.l	d0,d0
	move.l	d0,d3
	move.l	d1,d4
.nextblk:	move.l	BinBuffer,d1
	bne.s	.bin_ok
	bsr	GetBinBuffer
	move.l	BinBuffer,d1
.bin_ok:	move.l	d1,a1
	lsr.w	#1,d1
	bcc.s	.pair
	addq.l	#1,SecSize
	clr.b	(a1)+
	move.l	a1,BinBuffer
	jsr	Err_even
.pair:	move.l	d3,d0
	beq.s	.end
	lea	0(a1,d0.l),a2
	cmp.l	EndBinBuffer,a2
	bge.s	.full
	add.l	d0,SecSize
	move.l	d0,d1
	swap	d1
	lsr.w	#2,d0
	subq.w	#1,d0
.cp:	move.l	d4,(a1)+
	dbf	d0,.cp
	dbf	d1,.cp
	move.l	a1,BinBuffer
.end:	movem.l	(sp)+,d1-d4/a1-a2
	rts
.err:	jsr	Errdata_in_bss
	bra.s	.end
.full:	move.l	EndBinBuffer,d0
	sub.l	a1,d0
	addq.l	#3,d0
	and.l	#~3,d0
	beq.s	.alloc	;au moins 4 octets
	add.l	d0,SecSize
	sub.l	d0,d3
	move.l	d0,d1
	swap	d1
	lsr.w	#2,d0
	subq.w	#1,d0
.cp1:	move.l	d4,(a1)+
	dbf	d0,.cp1
	dbf	d1,.cp1
	move.l	a1,BinBuffer
.alloc:	bsr	UpdateBinBuffer
	bsr	BinAlloc
	bra	.nextblk

	; #[ ReserveMemory:
ReserveMemory:
	IFNE	ATARI
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDC
	IFNE	AMIGA
;attention, faut freer sur Amiga
	move.l	a6,-(sp)
	move.l	4.w,a6
	moveq	#0,d1
	jsr	AllocMem(a6)
	move.l	(sp)+,a6
	ENDC	;d'AMIGA
	tst.l	d0
	rts
	; #] ReserveMemory:
	; #[ FreeMemory:
FreeMemory:	;d0,a1
	IFNE	ATARI
	move.l	d0,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.w	#6,sp
	ENDC
	IFNE	AMIGA
	move.l	a6,-(sp)
	move.l	4.w,a6
	jsr	FreeMem(a6)
	move.l	(sp)+,a6
	rts
	ENDC	;d'AMIGA
	; #] FreeMemory:
;  #[ Free Binary Blocks:
FreeBinBlocks:
	move.l	FstBinPtr,d1
	beq.s	.end
.nx:	move.l	d1,a0
	move.l	BIN_next(a0),d1
	bsr	MyMfree
	tst.l	d1
	bne.s	.nx
.end:	rts
;  #] Free Binary Blocks:
;  #[ Free Modules:
FreeMods:	move.l	a2,-(sp)
	move.l	LastModPtr,d1
	beq.s	.end
.nx:	move.l	d1,a2
	move.l	MOD_prev(a2),d1
	tst.l	MOD_headed(a2)
	bne.s	.next		;pas freer src+mod de AEdit
	move.l	MOD_addr(a2),d0
	beq.s	.noaddr
	move.l	d0,a0
	bsr	MyMfree
.noaddr:	tst.b	IEnvFlg		;pas freer mod si AEdit
	bne.s	.next
	move.l	a2,a0
	bsr	MyMfree
.next:	tst.l	d1
	bne.s	.nx
.end:	move.l	(sp)+,a2
	rts

;.freeenv:	move.l	MOD_headed(a2),d1
;	beq.s	.noaddr
;.nxtxt:	move.l	d1,a1
;	move.l	TXT_text(a1),a0
;	bsr	MyMfree
;	move.l	TXT_next(a1),d1
;	move.l	a1,a0
;	bsr	MyMfree
;	tst.l	d1
;	bne.s	.nxtxt
;	bra.s	.noaddr
;  #] Free Modules:
;  #[ Free Src:
FreeSrc:	movem.l	d2-d3/a2,-(sp)
	move.l	LinnMemHead,d1
	bsr.s	.free
	move.l	LinrMemHead,d1
	bsr.s	.free
	movem.l	(sp)+,d2-d3/a2
	rts
.free:	beq.s	.endfr
	move.l	d1,a0
	move.l	MEMBLOCK_next(a0),d1
	jsr	MyMfree
	tst.l	d1
	bne.s	.free
.endfr:	rts
;  #] Free Src:
	BSS
;buffer binaire (text/data)
FstBinPtr:	ds.l	1	;ref blocks text/data
LstBinPtr:	ds.l	1	;last ref blocks text/data
CurBinPtr:	ds.l	1	;ptr sur descripteur courant
FstBinBuffer:	ds.l	1	;@ de debut du buffer d'assemblage
BinBuffer:	ds.l	1	;@ courante du buffer d'assemblage
EndBinBuffer:	ds.l	1	;@ de fin du buffer d'assemblage
CurBinNb:		ds.w	1	;current bin #
LstBinNb:		ds.w	1	;toujours le dernier # de block alloue
BinNumbers:	ds.l	2	;cur bin # (text+data)

;modules
FstModPtr:	ds.l	1
CurModPtr:	ds.l	1
LastModPtr:	ds.l	1
CurModNb:	ds.l	1
TotModNb:	ds.l	1
LastModNb:	ds.l	1

;line records
FstLinrPtr:	ds.l	1
CurLinrPtr:	ds.l	1
CurLinrNb:	ds.l	1

;line numbers
;FstLinnPtr:	ds.l	1
CurLinnPtr:	ds.l	1
CurLinnNb:	ds.l	1
CurLinnBlock:	ds.l	1
LinnMemHead:	ds.l	1
CurLinrBlock:	ds.l	1
LinrMemHead:	ds.l	1

DbgBinSize:	ds.l	1
	section TEXT

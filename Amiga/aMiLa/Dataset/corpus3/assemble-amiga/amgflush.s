; a faire:
;- changer message rel PC inter-sections
;- prendre @ dans les labels a cause de Lattice C
;- sortir l'erreur en creation du fichier de sortie
;- sortir les refs rel32

	XDEF	FlushPrg,IncbinSize

	XREF	LoadBinary,create_file,write_file,seek_file
	XREF	close_file,rel_seek_file
	XREF	MyMalloc,MyMfree,UpdateBinBuffer,OutMsg
	XREF	DbgType,SrcType,LinrEnd
	XREF	LinkPrep,FstBinPtr
	XREF	VarNb,GloTbl,HeadExp
	XREF	FstModPtr,FstLinrPtr,XrefTbl
	XREF	CurLinrNb,CurLinnNb,TotModNb,OutType,SrcOrgName
	XREF	XdefTbl,XdefNb,BuildXdef
	XREF	OutName,CurGloExp,FlshBuf,FileError
	;-- SECTIONS --
	XDEF	AddSection,InitSections,ExitSections,FreeSections
	XDEF	CurSecPtr,TabSecs
	XREF	SecSize,CurSection,SecPokeFlg,CurSecType
	XREF	CurBinPtr,BinBuffer,AllocString,prepnocor
	include	"comequ.s"
	include	"amig_equ.s"

	section	TEXT
;	 #[ FlushPrg:
FlushPrg:	movem.l	d3-d7/a2-a6,-(sp)
	lea	OutName,a0
	bsr	create_file
	bmi.s	.rcrea
	move.l	d0,d4
	move.l	IncbinSize,d0
	beq.s	.noinc
	jsr	MyMalloc
	move.l	d0,IncbinPtr
	beq.s	.rmem
.noinc:	move.l	d4,d0
	bsr.s	_flushprg
	sne	d3
	move.l	IncbinPtr,d0
	beq.s	.close
	move.l	d0,a0
	jsr	MyMfree
.close:	move.l	d4,d0
	bsr	close_file
	tst.b	d3
	beq.s	.end
	bsr	Errfile_write
.end:	movem.l	(sp)+,d3-d7/a2-a6
	rts
.rmem:	bsr	Errfile_ram
	sf	d3
	bra.s	.close
.rcrea:	bsr	Errfile_create
	bra.s	.end

_flushprg:
	movem.l	d7/a6,-(sp)
	jsr	UpdateBinBuffer
	moveq	#0,d7
	tst.w	OutType+2
	beq.s	.l3
	jsr	BuildXdef
.l3:	move.l	SectionsHead,a6
	move.l	d4,d0
	tst.w	OutType+2
	beq.s	.l1
	bsr	FlushUnit
	bra.s	.l2
.l1:	bsr	FlushHead
.l2:	bne.s	.end
	tst.w	SrcType
	beq.s	.nosrc
	move.l	d4,d0
	bsr	FlushSrc
	bne.s	.end
.nosrc:	moveq	#1,d7
	move.l	a6,d0
.next:	move.l	d0,a6
	tst.w	OutType+2
	beq.s	.bin
	move.l	d4,d0
	bsr	FlushName
	bne.s	.end
.bin:	move.l	d4,d0
	bsr	FlushBin
	bne.s	.end
	move.l	d4,d0
	bsr	FlushRel
	bne.s	.end
	tst.w	OutType+2
	beq.s	.nolnk
	move.l	d4,d0
	bsr	FlushExt
	bne.s	.end
.nolnk:	move.l	d4,d0
	bsr	FlushSym
	bne.s	.end
	move.l	d4,d0
	bsr	Flush3F2
	bne.s	.end
.gonext:	move.l	SECTION_next(a6),d0
	bne.s	.next
	moveq	#0,d0
.end:	movem.l	(sp)+,d7/a6
	rts
;	 #] FlushPrg:

;  #[ Flush:
;Input:	a6=@section descriptor
;	d0=d4=file handle
FlushHead:
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	MergedNbSecs,d0
	move.l	d0,d5
	move.l	d0,d3
	lsl.l	#2,d3		;tailles des hunks
	add.l	#4*5,d3		;$3f3,0,nb_hunks,first,last
	sub.l	d3,sp
	move.l	sp,a2
	move.l	a2,a0
	move.l	#HUNK_HEADER,(a0)+
	clr.l	(a0)+
	move.l	d5,d0
	move.l	d0,(a0)+	;Number of hunks
	clr.l	(a0)+		;first hunk
	subq.l	#1,d0
	move.l	d0,(a0)+	;last hunk (overlay ?)
.nx:	move.l	SECTION_size(a6),d1
	addq.l	#3,d1
	lsr.l	#2,d1
	move.b	SECTION_mem(a6),d2
	beq.s	.poke
	bset	d2,d1
.poke:	move.l	d1,(a0)+	;Section Size (quad aligned)
	move.l	SECTION_next(a6),a6
	dbf	d0,.nx
	move.l	a2,a0	;@
	move.l	d4,d1	;handle
	move.l	d3,d0	;size
	bsr	write_file
	add.l	d3,sp
	movem.l	(sp)+,d2-d7/a2-a6
	rts

FlushUnit:
	movem.l	d2-d7/a2-a5,-(sp)
	move.l	d0,d4
	lea	line_buffer,a2
	move.l	#HUNK_UNIT,(a2)+
	move.l	a2,a1
	lea	SrcOrgName,a0
put_name:	bsr	ascii_lw
	lea	-4(a2),a0
	addq.l	#4,d0
	move.l	d4,d1
	bsr	write_file
	movem.l	(sp)+,d2-d7/a2-a5
	rts

FlushName:
	movem.l	d2-d7/a2-a5,-(sp)
	move.l	d0,d4
	lea	line_buffer,a2
	move.l	#HUNK_NAME,(a2)+
	move.l	a2,a1
	move.l	SECTION_name(a6),a0
	bra.s	put_name

FlushExt:	movem.l	d2-d7/a2-a6,-(sp)
	move.l	a6,d6
	move.l	d0,d4
	move.l	SECTION_xreflist(a6),d0
	beq	.endxrefs
	move.l	SECTION_xrefnb(a6),d7
	beq	.endxrefs
	bsr	flsh_ext_head
	move.l	FlshBuf,a4
	lea	32000(a4),a5
	move.l	SECTION_xreflist(a6),a3
	move.l	XREFL_start(a3),a2
.nxvar:	IFNE	BLINDOS
	move.l	a3,d0
	bne.s	.ok
	_Debugger
.ok:	ENDC
	move.w	(a2),d2		;var #
	move.w	2(a2),d1		;xref type
	; -- flusher le type/nom --
	move.w	d2,d0
	bsr	get_xref_name	;out d0=taille symbole,a0=@sym
	move.w	d0,d3
	swap	d0
	move.w	d1,d0
	lsl.w	#8,d0
	swap	d0
	addq.w	#3,d0
	and.w	#~3,d0		;taille alignee
	lea	4(a4,d0.w),a6
	lsr.w	#2,d0		;taille en longs
	move.l	d0,(a4)+
	subq.w	#1,d3
.cp:	move.b	(a0)+,(a4)+
	dbf	d3,.cp
	REPT	3
	clr.b	(a4)+
	ENDR
	lea	4(a6),a4		;a6=@cpt de references
	; -- compter les references --
	moveq	#0,d3
	suba.l	a0,a0
.cmpref:	cmp.w	(a2),d2
	bne.s	.notthis
	cmp.w	2(a2),d1
	bne.s	.notthis
	move.l	4(a2),(a4)+
	st	2(a2)		;marquer la reference
	addq.l	#1,d3
	cmp.l	a5,a4
	blt.s	.gonxt
	; -- fin du buffer atteinte
	bsr	.flush
	bne.s	.endxrefs
	tst.l	d7
	beq.s	.endxrefs
	move.l	a0,d0
	beq.s	.gonxt2
	move.l	d0,a3
	move.l	a1,a2
	bra.s	.nxvar
.gonxt2:	addq.w	#8,a2
	cmp.l	XREFL_cur(a3),a2
	blt.s	.nxvar
	move.l	XREFL_next(a3),d0
	beq.s	.endxrefs
	move.l	d0,a3
	bra.s	.nxvar

.notthis:	move.l	a0,d0
	bne.s	.gonxt
	tst.b	2(a2)
	bne.s	.gonxt
	move.l	a3,a0	;la 1ere ref non faite qui colle pas
	move.l	a2,a1
.gonxt:	addq.w	#8,a2
	cmp.l	XREFL_cur(a3),a2
	blt.s	.cmpref
.nxblock:	move.l	XREFL_next(a3),d0
	beq.s	.endthisref
	move.l	d0,a3
	move.l	XREFL_start(a3),a2
	bra.s	.cmpref
.endthisref:
	move.l	d3,(a6)
	move.l	a0,a3
	move.l	a1,a2
	sub.l	d3,d7
	bne	.nxvar
	bsr.s	.flush

.endxrefs:
	move.l	d6,a6
	bne.s	.end
	bsr	flush_xdefs
	bne.s	.end
	tst.b	hh_flushed
	beq.s	.end
	; -- flusher 0 pour finir --
	lea	HunkBuf,a0
	clr.l	(a0)
	move.l	d4,d1
	moveq	#4,d0
	bsr	write_file
.end:	movem.l	(sp)+,d2-d7/a2-a6
	rts

; -- depassement ou fin -> flusher et reprendre --
.flush:	movem.l	a0/a1,-(sp)
	move.l	d3,(a6)
	sub.l	d3,d7
	move.l	FlshBuf,a0
	move.l	a4,d0
	sub.l	a0,d0
	move.l	d4,d1
	bsr	write_file
	movem.l	(sp)+,a0/a1
	bne.s	.endflsh
	moveq	#0,d3
	move.l	FlshBuf,a4
	moveq	#0,d0
.endflsh:	rts

flsh_ext_head:
	tst.b	hh_flushed
	bne.s	.end
	st	hh_flushed
	lea	HunkBuf,a0
	move.l	#HUNK_EXT,(a0)
	moveq	#4,d0
	move.l	d4,d1
	bra	write_file
.end:	rts

;In: d0 = xref #
;out d0=taille symbole,a0=@sym
get_xref_name:
	move.l	XrefTbl,a0
	ext.l	d0
	add.l	d0,d0
	add.l	d0,d0
	move.l	0(a0,d0.l),a0
	move.w	VAR_len(a0),d0
	move.l	VAR_start(a0),a0
	rts

;Out: d6=nb de vars flushees et flags (!Z=erreur de flush)
flush_xdefs:
	moveq	#0,d6
	move.b	SECTION_num+1(a6),d7
	move.l	XdefNb,d2
	beq.s	.end
	move.l	XdefTbl,a2
.l1:	move.l	(a2)+,a3
	cmp.b	VAR_sec(a3),d7
	beq.s	.flush
.tst:	subq.l	#1,d2
	bne.s	.l1
.end:	rts
.flush:	addq.l	#1,d6
	tst.b	hh_flushed
	bne.s	.flushed
	lea	HunkBuf,a0
	move.l	#HUNK_EXT,(a0)
	moveq	#4,d0
	move.l	d4,d1
	st	hh_flushed
	bsr	write_file
	bne.s	.end
.flushed:	lea	line_buffer,a4
	lea	4(a4),a1
	move.w	VAR_len(a3),d0
	moveq	#0,d1
	move.w	d0,d1
	move.l	VAR_start(a3),a0
	subq.w	#1,d0
.cp:	move.b	(a0)+,(a1)+
	dbf	d0,.cp
	REPT	3
	clr.b	(a1)+
	ENDR
	addq.w	#3,d1
	and.w	#~3,d1
	move.l	d1,d3		;size
	lsr.w	#2,d3
	or.l	#$01000000,d3	;abs_def
	move.l	d3,(a4)
	lea	4(a4,d1.w),a1
	move.l	VAR_value(a3),(a1)
	move.l	a4,a0
	move.l	d1,d0
	addq.l	#8,d0
	move.l	d4,d1
	bsr	write_file
	beq.s	.tst
	bra.s	.end

FlushBin:	movem.l	d4-d7/a5-a6,-(sp)
	move.l	d0,d4
	move.l	SECTION_size(a6),d3
	lea	HunkBuf,a0
	move.l	#HUNK_CODE,d1
	move.w	SECTION_type(a6),d0
	beq.s	.type	;text
	subq.w	#4,d0
	bne	.bss
	addq.w	#1,d1	;data
.type:	move.l	d1,(a0)
	addq.l	#3,d3
	lsr.l	#2,d3
	move.l	d3,4(a0)	;section size (quad aligned)
	move.l	d4,d1
	moveq	#8,d0
	bsr	write_file
	bne.s	.end

	moveq	#0,d6
	move.l	a6,d0
.nxsec:	move.l	d0,a6
	move.l	SECTION_bin_bl(a6),a5
	move.l	SECTION_partsize(a6),d5
	beq.s	.gosame
	move.l	SECTION_bin_start(a6),d0
	bne.s	.noinc
.l1:	move.l	BIN_start(a5),d0
	bne.s	.noinc
	move.l	a5,a0
	move.l	d4,d0
	bsr	writeincbin
	bne.s	.end
	add.l	d0,d6
	sub.l	d0,d5
	bra.s	.next
.noinc:	move.l	d0,a0
	move.l	BIN_cur(a5),d0
	sub.l	a0,d0
	cmp.l	d0,d5
	bge.s	.write
	move.l	d5,d0
.write:	add.l	d0,d6
	sub.l	d0,d5
	move.l	d4,d1
	bsr	write_file
	bne.s	.end
.next:	move.l	BIN_next(a5),a5
	tst.l	d5
	bgt.s	.l1
.gosame:	move.l	SECTION_samenext(a6),d0
	bne.s	.nxsec
;aligner au long mot
	lsl.l	#2,d3
	sub.l	d6,d3
	beq.s	.end
	move.l	d3,d0
	lea	HunkBuf,a0
	clr.l	(a0)
	move.l	d4,d1
	bsr	write_file
.end:	movem.l	(sp)+,d4-d7/a5-a6
	rts

.bss:	addq.w	#2,d1
	move.l	d1,(a0)+
	addq.l	#3,d3
	lsr.l	#2,d3
	move.l	d3,(a0)
	subq.l	#4,a0
	move.l	d4,d1
	moveq	#8,d0
	bsr	write_file
	bra.s	.end

FlushSym:	movem.l	d2-d7/a2-a5,-(sp)
	move.l	d0,d4
	tst.w	DbgType
	beq.s	._end
.dbg:	move.l	sp,a3
	lea	-256(a3),a3
	lea	-2000(sp),sp
	move.l	sp,a2
	move.l	a2,d6
	sf	hh_flushed
	move.b	SECTION_num+1(a6),d7
	move.l	VarNb,d2
	beq.s	.end
	move.l	GloTbl,a4
	;taille totale symboles
.nxsym:	move.l	(a4)+,a5
	cmp.b	VAR_sec(a5),d7
	bne.s	.next
	bsr.s	.write
	bne.s	.end
.next:	subq.l	#1,d2
	bne.s	.nxsym
	tst.b	hh_flushed
	beq.s	.end
	clr.l	(a2)+
	bsr	.flush
.end:	lea	2000(sp),sp
._end:	movem.l	(sp)+,d2-d7/a2-a5
	rts

.write:	tst.b	hh_flushed
	bne.s	.head_ok
	st	hh_flushed
	move.l	#HUNK_SYMBOL,(a2)+
.head_ok:	move.w	VAR_len(a5),d0
	ext.l	d0
	move.l	d0,d5
	addq.w	#3,d0
	and.w	#~3,d0
	move.l	d0,d3
	lsr.w	#2,d0
	move.l	d0,(a2)+
;ascii symbole
	move.l	VAR_start(a5),a0
	move.w	d5,d0
	subq.w	#1,d0
.cp:	move.b	(a0)+,(a2)+
	dbf	d0,.cp
;aligner au long
	sub.l	d5,d3
	beq.s	.value
	subq.w	#1,d3
.clr:	clr.b	(a2)+
	dbf	d3,.clr
.value:	move.l	VAR_value(a5),(a2)+
	cmp.l	a3,a2
	bge.s	.flush
	moveq	#0,d0
.w_end:	rts

.flush:	move.l	a2,d0
	sub.l	d6,d0
	move.l	d6,a0
	move.l	d4,d1
	bsr	write_file
	move.l	d6,a2
	bra.s	.w_end

FlushRel:	movem.l	d3-d7/a2-a6,-(sp)
	sf	hh_flushed
	move.l	d0,d4
	tst.l	SECTION_reltab(a6)
	beq	.end
	move.l	d0,a3
	move.l	SECTION_relocnb(a6),d7
	beq	.end
	move.l	FlshBuf,a4
	lea	32000(a4),a5
	move.l	a4,a0
	move.l	#HUNK_RELOC32,(a0)
	moveq	#4,d0
	move.l	d4,d1
	bsr	write_file
	bne	.end
	moveq	#0,d5	;section #
.nxsec:	move.l	SECTION_reltab(a6),a3
	move.l	SECTION_relocnb(a6),d6
	lea	-32000+8(a5),a4	;nb d'offsets+section
	moveq	#0,d3		;nb d'offsets
.nxexp:	cmp.b	1(a3),d5
	bne.s	.notthis
.thissec:	addq.l	#1,d3
	move.l	2(a3),(a4)+
	cmp.l	a5,a4
	blt.s	.l1
	bsr.s	.flush	;flusher car on a depasse le buffer
	bne.s	.end
	moveq	#0,d3	;on repart a 0 reloc
	lea	-32000+8(a5),a4	;nb d'offsets+section
.l1:	subq.l	#1,d7
	bgt.s	.notthis
	; -- toutes relocs traitees -> flusher et quitter
	bsr.s	.flush
	bne.s	.end
	moveq	#0,d3
	bra.s	.endrel
.notthis:	addq.w	#6,a3
	subq.l	#1,d6
	bgt.s	.nxexp
	; -- flusher les relocs de cette section
	bsr.s	.flush
	bne.s	.end
	; -- passer a la suivante
	addq.l	#1,d5
	cmp.l	MergedNbSecs,d5
	blt.s	.nxsec

.endrel:	move.l	FlshBuf,a0
	clr.l	(a0)
	moveq	#4,d0
	move.l	d4,d1
	bsr	write_file
.end:	movem.l	(sp)+,d3-d7/a2-a6
.rts:	rts

.flush:	move.l	FlshBuf,a0
	move.l	d3,(a0)	;nb d'offsets
	beq.s	.rts
	move.l	d5,4(a0)	;hunk reference
	move.l	d3,d0
	lsl.l	#2,d0
	addq.l	#8,d0
	move.l	d4,d1
	bra	write_file

Flush3F2:	lea	HunkBuf,a0
	move.l	#HUNK_END,(a0)
	move.l	d0,d1
	moveq	#4,d0
	jmp	write_file

;In: a0=@symbole, a1=@buffer
;Out: d0=taille en octets du truc ecrit
ascii_lw:	move.l	a2,-(sp)
	move.l	a1,a2
	clr.l	(a2)+
	move.l	a2,a1
	STRCPY
	move.l	a2,a0
	STRLEN
	lea	0(a2,d0.w),a1
	REPT	3
	clr.b	(a1)+
	ENDR
	addq.l	#3,d0
	lsr.l	#2,d0
	move.l	d0,-4(a2)
	addq.l	#1,d0
	lsl.l	#2,d0
	move.l	(sp)+,a2
	rts

;In: a1=@buffer (taille hunk+header=$24 octets)
FlshSrcHead:
	move.l	a5,d0
	add.l	#4+PDbgheader_SIZEOF,d0
	neg.l	d0
	move.l	d4,d1
	jsr	rel_seek_file	;en arriere

	lea	HunkBuf,a0
	move.l	a5,d0
	lsr.l	#2,d0
	add.l	#(PDbgheader_SIZEOF/4),d0
	move.l	d0,(a0)
	move.l	d4,d1
	moveq	#4,d0
	jsr	write_file	;poker taille hunk

	lea	PDbgheader,a0
	move.l	#'QDB1',(a0)
	;update taille modules
	move.l	TotModNb,d0
	lsl.l	#3,d0
	move.l	d0,PDbgmodsize-PDbgheader(a0)
	;update taille lignes
	move.l	CurLinrNb,d0
	mulu	#20,d0
	move.l	CurLinnNb,d1
	add.l	d1,d1
	add.l	d1,d0
	move.l	d0,PDbglinsize-PDbgheader(a0)

	moveq	#PDbgheader_SIZEOF,d0
	move.l	d4,d1
	jsr	write_file
	bne.s	.end

	move.l	d4,d1
	move.l	a5,d0
	jmp	rel_seek_file	;revenir
.end:	rts

PSRC_END	equr	d7
PSRC_CUR	equr	a4
;In: a5=taille ecrite
FlushSrc:	movem.l	d2-a6,-(sp)
	lea	-(8+PDbgheader_SIZEOF)(sp),sp
	tst.w	SrcType
	beq	.out
	move.l	d0,d4
	move.l	sp,a0
	move.l	#HUNK_DEBUG,(a0)
	clr.l	4(a0)
	move.l	d4,d1
	moveq	#8+PDbgheader_SIZEOF,d0
	jsr	write_file
	bne	.out

	suba.l	a5,a5
	bsr	FlshSrcMods
	bne	.out

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

	move.w	LINR_sec(a2),d0		;AMIGA
	move.l	TabSecs,a0
	lsl.w	#2,d0
	move.l	0(a0,d0.w),a0
	move.l	SECTION_offs(a0),d0
	add.l	d0,LINR_addr(a2)

	move.l	a2,a0
	moveq	#20/4-1,d0
.l2:	move.l	(a0)+,(PSRC_CUR)+
	dbf	d0,.l2
	cmp.l	PSRC_CUR,PSRC_END
	bgt.s	.nxtlinr
	bsr.s	.clse
	bne.s	.out

.nxtlinr:	move.l	LINR_count(a2),d5		;line number
	beq.s	.no_nb
	move.l	LINR_first(a2),a3

.wlinn:	move.w	(a3),(PSRC_CUR)+
	cmp.l	PSRC_CUR,PSRC_END
	bgt.s	.nxtlinn
	bsr.s	.clse
	bne.s	.out

.nxtlinn:	move.l	LINN_next(a3),a3
	subq.l	#1,d5
	bgt.s	.wlinn

.no_nb:	move.l	LINR_next(a2),a2
	subq.l	#1,d3
	bgt.s	.l1
	bsr.s	.clse

	bsr	FlshSrcNames
	bne.s	.out
	bsr	FlshSrcSecSizes
	bne.s	.out

.end:	;poker la taille ecrite
	bsr.s	.padlong
	bne.s	.out
	bsr	FlshSrcHead
.out:	lea	8+PDbgheader_SIZEOF(sp),sp
	movem.l	(sp)+,d2-a6
	rts
.clse:	move.l	FlshBuf,a0
	move.l	a0,-(sp)
	move.l	d4,d1
	move.l	PSRC_CUR,d0
	sub.l	a0,d0
	add.l	d0,a5
	bsr	write_file
	move.l	(sp)+,PSRC_CUR
.rts:	rts

.padlong:	move.l	a5,d1
	moveq	#4,d0
	and.w	#3,d1
	beq.s	.rts
	sub.w	d1,d0
	add.w	d0,a5
	lea	HunkBuf,a0
	move.l	d4,d1
	clr.l	(a0)
	jmp	write_file

FlshSrcMods:
	movem.l	d3-d7/a2,-(sp)
	subq.w	#8,sp
	moveq	#0,d6			;first name offset
	move.l	FstModPtr,d0		;1st module
	beq.s	.good
.l1:	move.l	d0,a2
	clr.l	PMOD_time(sp)		;module timestamp
	move.l	d6,PMOD_name(sp)		;module name offset

	move.l	sp,a0
	moveq	#8,d0
	move.l	d4,d1
	addq.l	#8,a5
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

FlshSrcNames:
	movem.l	d3-d7/a2,-(sp)
	move.l	FstModPtr,d0
	beq.s	.end
.l1:	move.l	d0,a2
	move.l	MOD_expnam(a2),a0
	STRLEN
	addq.l	#1,d0
	add.l	d0,a5
	move.l	MOD_expnam(a2),a0
	move.l	d4,d1
	bsr	write_file
	bne.s	.end
	move.l	MOD_next(a2),d0
	bne.s	.l1
.end:	movem.l	(sp)+,d3-d7/a2
	rts

;sort les tailles reelles (non padees au long) des sections
FlshSrcSecSizes:
	move.l	d2,-(sp)
	move.l	MergedNbSecs,d2
	lsl.l	#2,d2
	sub.l	d2,sp
	move.l	sp,a1
	move.l	SectionsHead,d0
.l1:	move.l	d0,a0
	move.l	SECTION_size(a0),(a1)+
	move.l	SECTION_next(a0),d0
	bne.s	.l1
	move.l	sp,a0
	move.l	d2,d0
	move.l	d4,d1
	add.l	d0,a5		;inc size
	bsr	write_file
	add.l	d2,sp
	movem.l	(sp)+,d2
	rts
;	 #[ loadincbin:
;a0=BIN
;d0=handle
;OUT:
;d0=@
writeincbin:
	movem.l	d3-d4/a2,-(sp)
	move.l	d0,d4
	move.l	BIN_cur(a0),d3
	move.l	BIN_off(a0),d1
	move.l	BIN_end(a0),a0
	move.l	IncbinPtr,a1
	move.l	d3,d0
	bsr	LoadBinary
	bmi.s	.err		;errno ds d0
	move.l	IncbinPtr,a0
	move.l	d3,d0
	move.l	d4,d1
	bsr	write_file
.end:	movem.l	(sp)+,d3-d4/a2
	rts
.err:	bsr	FileError
	moveq	#-1,d0
	bra.s	.end
;	 #] loadincbin: 
	IFNE	0
;	 #[ flushmod:
flushmod:	movem.l	d3-d7/a2-a5,-(sp)
	move.l	d0,d4			;file handle
	moveq	#0,d6			;first name offset
	move.l	FstModPtr,d0		;1st module
	beq.s	.good
.l1:	move.l	d0,a5
	clr.l	MOD_time(a5)		;module timestamp
	move.l	d6,MOD_name(a5)		;module name offset

	move.l	a5,a0
	moveq	#8,d0
	move.l	d4,d1
	bsr	write_file
	bne.s	.end

	;reloc next name
	move.l	MOD_nambuf(a5),a0
	STRLEN
	addq.l	#1,d0
	add.l	d0,d6

	move.l	MOD_next(a5),d0
	bne.s	.l1

.good:	moveq	#0,d0
.end:	movem.l	(sp)+,d3-d7/a2-a5
	rts
;	 #] flushmod:
	ENDC
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
	bra.s	flshperr
Error_memory:
Error_noram:
	move.w	#varram_errno,d0
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

;SECTIONS
;  #[ Sections Stuff:
InitSections:
	moveq	#DESC_SECTION_SIZEOF,d0
	jsr	MyMalloc
	move.l	d0,SectionsHead
	beq	Error_memory
	move.l	d0,CurSecPtr
	move.l	d0,a0
	move.l	a0,a1
	moveq	#0,d0
	move.w	#(DESC_SECTION_SIZEOF/2)-1,d1
.clr:	move.w	d0,(a0)+
	dbf	d1,.clr
	move.l	SecNames(pc),SECTION_name(a1)	;'TEXT'
	move.w	d0,NbSections
	rts

FreeSections:
	move.l	d2,-(sp)
	move.l	SectionsHead,d2
	beq.s	.end
.nx:	move.l	d2,a0
	move.l	SECTION_next(a0),d2
	move.l	a0,a1
	move.l	SECTION_samenext(a1),d1
	beq.s	.nosame
.l2:	move.l	d1,a0
	move.l	SECTION_samenext(a0),d1
	jsr	MyMfree
	tst.l	d1
	bne.s	.l2
.nosame:	move.l	SECTION_reltab(a1),d0
	beq.s	.l1
	move.l	d0,a0
	jsr	MyMfree
.l1:	move.l	SECTION_xreflist(a1),d1
	beq.s	.l3
.nxref:	move.l	d1,a0
	move.l	XREFL_next(a0),d1
	jsr	MyMfree
	tst.l	d1
	bne.s	.nxref
.l3:	move.l	a1,a0
	jsr	MyMfree
	tst.l	d2
	bne.s	.nx
.end:	move.l	TabSecs,d0
	beq.s	.end2
	move.l	d0,a0
	jsr	MyMfree
.end2:	move.l	(sp)+,d2
	rts

; -- Input --
; d2=type section si juste TEXT,DATA ou BSS ds le src
; d3=nb de champs
; 0-> text,data ou bss
; 1-> section truc -> type text
; 2-> section truc,type[_c|_f]
; -- In --
; d4 = section memtype
; a2 = @section name
AddSection:
	movem.l	d1-d7/a1-a5,-(sp)
	moveq	#0,d4
	tst.w	d3
	bne.s	.args
	lea	SecNames(pc),a1
	move.l	0(a1,d2.w),a2
	bra	.do_it
	;NOM de la section
.args:	moveq	#SEC_text,d2	;default
	move.l	a3,a0
	MSTRLEN
	move.l	d0,d7
	addq.l	#1,d0
	jsr	AllocString
	beq	Error_memory
	move.l	a3,a0
	move.l	d0,a2
	move.l	d0,a1
	move.l	d7,d0
	STRNCPY
	clr.b	(a1)
	INCFIELD
	subq.w	#1,d3
	beq	.do_it

	;TYPE de la section
	move.l	(a3)+,d0
	and.l	#$dfdfdfdf,d0
	cmp.l	#'CODE',d0
	beq.s	.mem
	cmp.l	#'DATA',d0
	bne.s	.bss
	moveq	#SEC_data,d2
	bra.s	.mem
.bss:	lsr.l	#8,d0
	cmp.l	#'BSS',d0
	bne	.errs
	subq.w	#1,a3
	moveq	#SEC_bss,d2
.mem:	move.b	(a3)+,d0
	ble.s	.do_it
	cmp.b	#'_',d0
	bne	.errs
	move.b	(a3)+,d0
	and.b	#$df,d0
	cmp.b	#'C',d0
	bne.s	.no_c
	moveq	#30,d4	;chip
	bra.s	.l1
.no_c:	cmp.b	#'F',d0
	bne	.errs
	moveq	#31,d4	;fast
.l1:	tst.b	(a3)	;TOKENEOL expected
	bpl	.errs

.do_it:	; virer la 1ere section cree par defaut si elle est vide
	move.l	SecSize,d1
	bne.s	.close
	tst.w	CurSection
	bne.s	.close
	cmp.w	#SEC_bss,d2
	bne.s	.nobss
	tst.w	OutType
	beq	.sbss
;update first section
.nobss:	move.l	CurSecPtr,a0
	bsr	.com_update
	bra	.end
.close:	bsr	CloseSection	;fermer la section courante
.create:	bsr	secs_cmp		;comparer le nom aux precedents
	move.l	d0,d3
	moveq	#DESC_SECTION_SIZEOF,d0
	jsr	MyMalloc
	beq	Error_memory
	move.l	CurSecPtr,a0
	move.l	d0,SECTION_next(a0)
	move.l	d0,a0
	move.l	a0,CurSecPtr
	tst.l	d3
	beq.s	.nosame
	bsr	update_same_sec	;chainer sections de meme nom
	bra.s	.upd
.nosame:	addq.b	#1,SaveCurSection+1
	bmi	.ovfsec
	move.w	SaveCurSection,CurSection
	clr.l	SecSize
	clr.l	SECTION_maxreloc(a0)
	clr.l	SECTION_sameprev(a0)
.upd:	clr.l	SECTION_next(a0)
	clr.l	SECTION_samenext(a0)
	clr.l	SECTION_size(a0)
	clr.l	SECTION_reltab(a0)
	clr.l	SECTION_relocnb(a0)
	clr.l	SECTION_xreflist(a0)
	clr.l	SECTION_xrefnb(a0)
	bsr.s	.com_update
	move.w	CurSection,SECTION_num(a0)
	sf	SECTION_ok(a0)
	move.l	CurBinPtr,SECTION_bin_bl(a0)
	move.l	BinBuffer,SECTION_bin_start(a0)
	move.l	CurGloExp,d0
	move.l	d0,SECTION_expstrtbl(a0)
	beq.s	.noexp2
	move.l	d0,a1
	move.l	HEAD_current(a1),SECTION_expstrtcur(a0)
.noexp2:	addq.w	#1,NbSections
.end:	movem.l	(sp)+,d1-d7/a1-a5
	rts

.ovfsec:	move.w	#sec_2many_errno,d0
.perr:	bsr	prepnocor
	bra.s	.end
.errs:	move.w	#sec_name_errno,d0
	bra.s	.perr
.sbss:	move.w	#sec_start_errno,d0
	bra.s	.perr

.com_update:
	move.w	d2,SECTION_type(a0)
	move.w	d2,CurSecType
	move.b	d4,SECTION_mem(a0)
	move.l	a2,SECTION_name(a0)
	cmp.w	#SEC_bss,d2
	sne	SecPokeFlg
	rts

;Out: d0=previous same section
secs_cmp:	movem.l	d1-d2/a0-a3,-(sp)
	move.l	SectionsHead,d0
	moveq	#0,d2
.nx:	move.l	d0,a0
	move.l	SECTION_name(a0),a1
	move.l	a2,a3
.nxcar:	move.b	(a1)+,d0
	beq.s	.end1
	move.b	(a3)+,d1
	beq.s	.go_nx
	cmp.b	d1,d0
	beq.s	.nxcar
	bra.s	.go_nx
.end1:	tst.b	(a3)
	bne.s	.go_nx
	move.l	a0,d2		;match
.go_nx:	move.l	SECTION_next(a0),d0
	bne.s	.nx
	move.l	d2,d0
	movem.l	(sp)+,d1-d2/a0-a3
	rts

;In: d3=@sec sameprev, a0=@cur sec,d2/d4=type/mem
update_same_sec:
	move.l	a3,-(sp)
	move.l	d3,a3
	move.l	a0,SECTION_samenext(a3)
	move.l	a3,SECTION_sameprev(a0)
;reprend la taille de la precedente
	move.l	SECTION_size(a3),d0
	move.l	d0,SECTION_size(a0)
	move.l	d0,SecSize
;reprend les relocs de la precedente
	move.l	SECTION_maxreloc(a3),d0
	move.l	d0,SECTION_maxreloc(a0)
;reprend son type et check au passage
	move.w	SECTION_num(a3),CurSection
	cmp.w	SECTION_type(a3),d2
	bne.s	.err
	cmp.b	SECTION_mem(a3),d4
	bne.s	.err
.end:	move.l	(sp)+,a3
	rts
.err:	move.w	d0,-(sp)
	move.w	#sec_difftypes_errno,d0
	bsr	prepnocor
	move.w	SECTION_type(a3),d2
	move.b	SECTION_mem(a3),d4
	move.w	(sp)+,d0
	bra.s	.end

CloseSection:
	movem.l	d0-d1/a0-a1,-(sp)
	tst.w	SrcType
	beq.s	.nosrc
	bsr	LinrEnd
.nosrc:	move.l	CurSecPtr,a0
	move.l	SecSize,d0
	move.l	d0,SECTION_size(a0)
	move.l	SECTION_sameprev(a0),d1
	beq.s	.noprev
	move.l	d1,a1
	sub.l	SECTION_size(a1),d0
.noprev:	move.l	d0,SECTION_partsize(a0)	;utilise par FlushBin
	move.l	CurGloExp,d0
	beq.s	.end
	move.l	d0,a1
	move.l	d0,SECTION_expendbl(a0)
	move.l	HEAD_current(a1),d0
	move.l	d0,HEAD_end(a1)
	move.l	d0,SECTION_expendcur(a0)
.end:	movem.l	(sp)+,d0-d1/a0-a1
	rts

ExitSections:
	movem.l	d2-d7/a2-a6,-(sp)
	addq.w	#1,NbSections
	bsr.s	CloseSection
	bsr	MergeSections
	move.l	d0,MergedNbSecs
	beq.s	.end_ok
	lsl.l	#2,d0
	jsr	MyMalloc
	move.l	d0,TabSecs
	beq.s	.enderr
	moveq	#0,d7
	move.l	d0,a3
	move.l	SectionsHead,d1
.next:	move.l	d1,a2
	move.l	a2,(a3)+
	move.l	SECTION_maxreloc(a2),d0
	add.l	d0,d0
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0	;*6
	beq.s	.l1
	jsr	MyMalloc
	tst.l	d0
	beq.s	.enderr
.l1:	move.l	d0,SECTION_reltab(a2)
	move.l	d0,SECTION_currel(a2)
	move.l	d7,SECTION_offs(a2)
	move.w	SECTION_type(a2),d0
	beq.s	.addsz
	subq.w	#SEC_data,d0
	bne.s	.nx
.addsz:	add.l	SECTION_size(a2),d7
.nx:	move.l	SECTION_next(a2),d1
	bne.s	.next
.end_ok:	moveq	#0,d0
.end:	movem.l	(sp)+,d2-d7/a2-a6
	rts
.enderr:	bsr	Error_memory
	moveq	#-1,d0
	bra.s	.end

;Out: d0=nb de sections mergees
MergeSections:
	movem.l	d2-d3,-(sp)
	move.l	SectionsHead,d1
	beq.s	.end
	moveq	#0,d0
	moveq	#0,d2	;prev
.nx:	move.l	d1,a0
	tst.b	SECTION_ok(a0)
	bne.s	.next
	move.l	a0,d3
	addq.l	#1,d0
	tst.l	d2
	beq.s	.first
	move.l	d2,a1
	move.l	a0,SECTION_next(a1)
.first:	move.l	a0,d2
	move.l	SECTION_samenext(a0),d1
	beq.s	.next
.nxsame:	move.l	d1,a1
	st	SECTION_ok(a1)
	move.l	SECTION_samenext(a1),d1
	bne.s	.nxsame
	move.l	SECTION_size(a1),SECTION_size(a0)
	move.l	SECTION_maxreloc(a1),SECTION_maxreloc(a0)
.next:	move.l	SECTION_next(a0),d1
	bne.s	.nx
	move.l	d2,a0
	clr.l	SECTION_next(a0)
.end:	movem.l	(sp)+,d2-d3
	rts

;  #] Sections Stuff:
;  #[ Datas:
SecNames:	dc.l	.text,.data,.bss
.text:	dc.b	"TEXT",0
.data:	dc.b	"DATA",0
.bss:	dc.b	"BSS",0
	even
;  #] Datas:

	IFNE	BLINDOS
internal_error:
	_Debugger
	ENDC

	BSS
;  #[ BSS:
IncbinSize:	ds.l	1	;max incbin size
IncbinPtr:	ds.l	1	;max incbin buffer
HunkBuf:		ds.l	2
line_buffer:	ds.b	256
flshmsg:		ds.b	MSG_SIZEOF
hh_flushed:	ds.b	1
	even
CurHunk:		ds.l	1
NbSections:	ds.w	1
MergedNbSecs:	ds.w	1
SaveCurSection:	ds.w	1
CurSecPtr:	ds.l	1
SectionsHead:	ds.l	1
TabSecs:		ds.l	1

PDbgheader:	ds.l	1	;'QDB1'
PDbgmodsize:	ds.l	1
PDbglinsize:	ds.l	1
PDbgsymsize:	ds.l	1
PDbgscosize:	ds.l	1
PDbgtypsize:	ds.l	1
PDbgmemsize:	ds.l	1
PDbgnamsize:	ds.l	1
PDbgheader_SIZEOF	equ	*-PDbgheader
;  #] BSS: 
	END


;===================================================================
;	
;	Routine to allow MED modules to be saved out and re-used 
;	after being loaded an relocated using Teijo's _RelocModule.
;	Could be used for many things including a MED Ripper.
;	Based on Teijo's _RelocModule routine.
;
;	Function: _UnRelocModule(a0)
;	a0 = pointer to module
;
;	By Steve Marshall	Compiles with Devpac 2
;
;===================================================================

_UnRelocModule:
	movem.l	a2-a3/d2-d3,-(sp)
	movea.l a0,a2
	move.l  a2,d1		;d1 = ptr to start of module
	lea     8(a2),a0
	bsr.s   .relocentr	;reloc song ptr
	addq.l  #4,a0
	bsr.s   .relocentr	;reloc blockarr ptr
	addq.l  #4,a0
	bsr.s   .relocentr	;reloc smplarr ptr
	addq.l  #4,a0
	bsr.s   .relocentr	;reloc expdata ptr
	movea.l 24(a2),a0
	add.l	d1,a0
	movea.l 8(a2),a1
	add.l	d1,a1
	moveq   #0,d0
	move.b  787(a1),d0	;number of samples
	subq.b  #1,d0
.relocs	bsr.s   .relocentr
	move.l	-4(a0),d3	;sample ptr
	add.l	d1,d3
	beq.s	.nosyn
	move.l	d3,a3
	tst.b	5(a3)
	bpl.s	.nosyn		;type >= 0
	move.b	20(a3),d2	;number of waveforms
	lsl.w	#8,d2
	move.b	21(a3),d2
	lea	278(a3),a3	;ptr to wf ptrs
	subq.w	#1,d2
.relsyn	sub.l	d3,(a3)+
	dbf	d2,.relsyn
.nosyn	dbf     d0,.relocs
	movea.l 16(a2),a0
	add.l	d1,a0
	move.w  504(a1),d0
	subq.b  #1,d0
.relocb bsr.s   .relocentr
	dbf     d0,.relocb
	move.l	32(a2),d0	;extension struct
	add.l	d1,d0
	beq.s	.rel_ex
	move.l	d0,a0
	addq.l	#4,a0		;pass "reserved"
	bsr.s	.relocentr	;InstrExt...
	addq.l	#4,a0		;pass sizes of InstrExt
	bsr.s	.relocentr	;annotxt
.rel_ex	movem.l	(sp)+,d2-d3/a2-a3
	rts

.relocentr
	tst.l   (a0)
	beq.s   .norel
	sub.l   d1,(a0)
.norel	addq.l  #4,a0
	rts

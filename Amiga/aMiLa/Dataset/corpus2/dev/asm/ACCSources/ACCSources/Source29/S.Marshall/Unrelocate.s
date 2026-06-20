;===========================================================

;	Function: _UnRelocModule(a0)
;	a0 = pointer to module

:	Modified from Teijo's relocation routine 
:	By Steve Marshall
:
; ***** The unrelocation routine *****
unreloci	move.l	24(a2),d0
		beq.s	unxloci
		movea.l	d0,a0
		moveq   #0,d0
		move.b  787(a1),d0	;number of samples
		subq.b  #1,d0
.relocs:	bsr.s   unrelocentr
		move.l	-4(a0),d3	;sample ptr
		beq.s	.nosyn
		add.l	d1,d3
		move.l	d3,a3
		tst.w	4(a3)
		bpl.s	.nosyn		;type >= 0
		move.w	20(a3),d2	;number of waveforms
		lea	278(a3),a3	;ptr to wf ptrs
		subq.w	#1,d2
.relsyn		sub.l	d3,(a3)+
		dbf	d2,.relsyn
.nosyn		dbf     d0,.relocs
unxloci		rts
unrelocentr	tst.l   (a0)
		beq.s   .norel
		sub.l   d1,(a0)+
		rts
.norel		addq.l	#4,a0
		rts
_UnRelocModule	movem.l	a2-a3/d2-d3,-(sp)
		move.l	a0,a2
		move.l  a2,d1		;d1 = ptr to start of module
		movea.l 8(a2),a1
		bsr.s	unreloci
.rel_lp		bsr.s	unrelocb
		move.l	32(a2),d0	;extension struct
		beq.s	unrel_ex
		move.l	d0,a0
		bsr.s	unrelocentr	;ptr to next module
		bsr.s	unrelocentr	;InstrExt...
		addq.l	#4,a0		;skip sizes of InstrExt
		bsr.s	unrelocentr	;annotxt
		addq.l	#4,a0		;annolen
		bsr.s	unrelocentr	;InstrInfo
		addq.l	#8,a0
		bsr.s	unrelocentr	;rgbtable (not useful for most people)
		addq.l	#4,a0		;skip channelsplit
		bsr.s	unrelocentr	;NotationInfo
		bsr.s	unrelocentr	;songname
		addq.l	#4,a0		;skip song name length
		bsr.s	unrelocentr	;MIDI dumps
		bsr.s	unrelocmdd
		move.l	d0,a0
		move.l	(a0),d0
		beq.s	unrel_ex
		move.l	d0,a2
		;bsr.s	unrelocp
		movea.l 8(a2),a1
		bra.s	.rel_lp

unrel_ex	lea	8(a2),a0
		bsr.s	unrelocentr
		addq.l	#4,a0
		bsr.s	unrelocentr
		addq.l	#4,a0
		bsr.s	unrelocentr
		addq.l	#4,a0
		bsr.s	unrelocentr

		movem.l	(sp)+,d2-d3/a2-a3
		rts

unrelocb	move.l	16(a2),d0
		beq.s	unxlocb
		movea.l	d0,a0
		move.w  504(a1),d0
		subq.b  #1,d0
.rebl		bsr.s   unrelocentr
		dbf     d0,.rebl
		cmp.b	#'1',3(a2)	;test MMD type
		beq.s	unrelocbi
unxlocb		rts
unrelocmdd	tst.l	-(a0)
		beq.s	unxlocmdd
		movea.l	(a0),a0
		add.l	d1,a0
		move.w	(a0),d0		;# of msg dumps
		addq.l	#8,a0
unmddloop	beq.s	unxlocmdd
		bsr	unrelocentr
		bsr.s	unrelocdmp
		subq.w	#1,d0
		bra.s	unmddloop
unxlocmdd	rts
unrelocdmp	move.l	-4(a0),d3
		add.l	d1,d3		
		beq.s	unxlocdmp
		exg.l	a0,d3		;save
		addq.l	#4,a0
		bsr	unrelocentr	;reloc data pointer
		move.l	d3,a0		;restore
unxlocdmp	rts
unrelocbi	move.w	504(a1),d0
		move.l	a0,a3
.biloop		subq.w	#1,d0
		bmi.s	unxlocdmp
		move.l	-(a3),a0
		add.l	d1,a0
		addq.l	#4,a0
		bsr	unrelocentr	;BlockInfo ptr
		tst.l	-(a0)
		beq.s	.biloop
		move.l	(a0),a0
		bsr	unrelocentr	;hldata
		bsr	unrelocentr	;block name
		bra.s	.biloop
	

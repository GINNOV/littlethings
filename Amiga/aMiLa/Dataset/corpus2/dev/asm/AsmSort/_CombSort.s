
; Comb sort in MC68020+ ASM.
; (c) Mattias Nilsson (c-lous@freenet.hut.fi)
;
; Sorts an array of 16 bit INTS.

ListSize	=	256

	xdef	_CombSort


_CombSort

; Create some "random" numbers
	Lea.l	List(Pc),a0
	Move.l	#ListSize-1,d7
.Loop:	Move.w	$dff006,d0
	Muls	d7,d0
	Lsr.w	#7,d0
	Move.w	d0,(a0)+
	Dbf	d7,.Loop

; Comb sort the array.

	Lea.l	List(Pc),a0
	Move.l	#ListSize,d7	; Number of values

	Move.l	d7,d1		; d1=Gap
.MoreSort
	MoveQ	#0,d0		; d0=Switch
	Asl.l	#8,d1
	Divu.w	#333,d1		; 1.3*256 = 332.8
	And.l	#$ffff,d1	; gap=gap/1.3

	Cmp.w	#1,d1		; if gap<1 then gap:=1
	Bpl	.okgap
	Moveq	#1,d1
.okgap:
	Move.l	d7,d2		; d2=Top
	Sub.l	d1,d2		; D2=NMAX-gap
	Move.l	a0,a1
	Lea.l	(a1,d1.w*2),a2	; a2=a1+gap
	Subq.w	#1,d2
.Loop:	Move.w	(a1)+,d3
	Cmp.w	(a2)+,d3
	Bmi	.okval
	Beq	.okval

	Move.w	-2(a1),d3	; swap
	Move.w	-2(a2),-2(a1)
	Move.w	d3,-2(a2)

	Moveq	#1,d0
.okval:
	Dbf	d2,.Loop

	Cmp.w	#1,d1		; gap < 1 ?
	Bne	.MoreSort
	Tst.w	d0		; Any entries swapped ?
	Bne	.MoreSort
	Rts

List:	ds.w	ListSize

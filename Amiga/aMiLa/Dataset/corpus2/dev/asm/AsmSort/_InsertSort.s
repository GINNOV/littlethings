
; Insert sort in MC68020+ ASM.
; (c) Mattias Nilsson (c-lous@freenet.hut.fi)
;
; Sorts an array of 16 bit INTS.

ListSize	=	256

	xdef	_InsertSort


_InsertSort:

; Create some "random" numbers
	Lea.l	List(Pc),a0
	Move.l	#ListSize-1,d7
.Loop:	Move.w	$dff006,d0
	Muls	d7,d0
	Lsr.w	#7,d0
	Move.w	d0,(a0)+
	Dbf	d7,.Loop


; Insert sort the list.

	Lea.l	List(Pc),a0
	MoveQ	#0,d7			; i
.Loop1:	Move.l	d7,d5			; d5=mp=i
.Loop2:	Tst.l	d5
	Beq.s	.OutLoop2
	Move.w	(a0,d5.w*2),d0
	Cmp.w	-2(a0,d5.w*2),d0
	Bhi.w	.OutLoop2

	Move.w	-2(a0,d5.w*2),(a0,d5.w*2)
	Move.w	d0,-2(a0,d5.w*2)
	Subq.l	#1,d5
	Bra.s	.Loop2
.OutLoop2:
	Addq.l	#1,d7
	Cmp.l	#ListSize,d7
	Blo.s	.Loop1
	Rts

List:	Ds.w	ListSize

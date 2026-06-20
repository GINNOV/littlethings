
; Bubble sort in MC68020+ ASM.
; (c) Mattias Nilsson (c-lous@freenet.hut.fi)
;
; Sorts an array of 16 bit INTS.

ListSize	=	256

	xdef	_BubbleSort


_BubbleSort:

; Create some "random" numbers
	Lea.l	List(Pc),a0
	Move.l	#ListSize-1,d7
.Loop:	Move.w	$dff006,d0
	Muls	d7,d0
	Lsr.w	#7,d0
	Move.w	d0,(a0)+
	Dbf	d7,.Loop

	
; Bubble sort the array.

.BubbleSort:
	Move.l	a1,a0
	Move.l	d2,d0
	clr.w	d1
Loop:	move.b	1(a0),d3
	cmp.b	(a0)+,d3
	bcc.s	.noswap
	move.b	-1(a0),d1
	move.b	(a0),-1(a0)
	move.b	d1,(a0)
	bset	#0,d1

.noswap:dbf	d0,Loop
	tst.w	d1
	bne.s	.BubbleSort
	Rts

List:	Ds.w	ListSize

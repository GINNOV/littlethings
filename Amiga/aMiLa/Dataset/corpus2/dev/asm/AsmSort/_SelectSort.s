
; Select sort in MC68020+ ASM.
; (c) Mattias Nilsson (c-lous@freenet.hut.fi)
;
; Sorts an array of 16 bit INTS.

ListSize	=	256

	xdef	_SelectSort


_SelectSort:

; Create some "random" numbers
	Lea.l	List(Pc),a0
	Move.l	#ListSize-1,d7
.Loop:	Move.w	$dff006,d0
	Muls	d7,d0
	Lsr.w	#7,d0
	Move.w	d0,(a0)+
	Dbf	d7,.Loop


; Select sort the array.

	Lea.l	List(Pc),a0
	MoveQ	#0,d7			; i
.Loop1:
	Move.l	d7,d5			; d5=mp
	Move.l	d7,d6			; d6=j
	Move.w	(a0,d5.w*2),d0		; d0=tdat[mp]
.Loop2:
	Cmp.w	(a0,d6.w*2),d0		; tdat[mp]>tdat[j] ?
	Blo.s	.Nah
	Move.w	d6,d5			; mp=j
	Move.w	(a0,d5.w*2),d0		; d0=tdat[mp]
.Nah:	Addq.l	#1,d6
	Cmp.l	#ListSize,d6
	Blo.s	.Loop2

	; Swap(i,mp)
	Move.w	(a0,d7.w*2),d0		; d0=tdat[i]
	Move.w	(a0,d5.w*2),(a0,d7.w*2)	; tdat[i]:=tdat[mp]
	Move.w	d0,(a0,d5.w*2)		; tdat[mp]:=tdat[i]

	Addq.l	#1,d7
	Cmp.l	#ListSize,d7
	Blo.s	.Loop1
	Rts

List:	Ds.w	MaxListSize

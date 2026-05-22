
;1. AmigaOS and AsmOne
;2. should be equal to LHA, LZX and so on
;3. no warranty of any kind is given
;4. further optimisations are very welcome
;
;zeeball@interia.pl



	;bsr	MakeCRC32Tab
	;rept 20
	;lea.l	$f80000,a0
	;move.l	#512000,d2
	;bsr	CalcCRC32
	;endr
	rts


	cnop	0,4
CalcCRC32:

	;a0 - buffer
	;d2 - size

	addq.l	#1,d2

	moveq	#0,d7
	not.b	d7

	lea.l	CRC32tab,a3
	move.l	#$EDB88320,d4			;classic

	move.l	a0,a5
	bra.s	.A

	cnop	0,4
.loop:
	moveq	#0,d1
	move.b	(a5)+,d1

	move.l	d4,d0
	eor.l	d1,d4
	and.l	d7,d4
	
	lsl.l	#2,d4				;for 020+ shortens to
	move.l	(a3,d4.L),d4			;move.l	(a3,d4.L*4),d4

	lsr.l	#8,d0
	eor.l	d0,d4
.A:
	subq.l	#1,d2
	bne.b	.loop

	move.l	d4,d0
	rts


	cnop	0,4
MakeCRC32Tab:
	move.l	#$100,d4
	lea.l	$EDB88320,a3			;classic
	lea.l	CRC32tab(pc),a0
	moveq	#0,d1
.A
	move.l	d1,d6
	moveq	#0,d5
.B
	move.l	d6,d0
	lsr.l	#1,d0
	btst	#0,d6
	beq.s	.C
	move.l	a3,d6
	eor.l	d0,d6
	bra.b	.D

	cnop	0,4

.C	move.l	d0,d6
.D
	addq.l	#1,d5
	moveq	#8,d0
	cmp.l	d0,d5
	bcs.s	.B
	addq.l	#1,d1
	
	move.l	d6,(a0)+
	cmp.l	d4,d1
	bcs.s	.A
	rts

CRC32tab:	ds.b	1024

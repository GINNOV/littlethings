
 * Note: Monitor this code with MonAm if you have never used the BF
 *       instructions before, to get an idea of how they work.

 * Bit Field instructions work on the bases that the <ea> is known as the
 * base address, offset is the number of bits to skip from the leftmost bit
 * and width is a value between 0-31. Note: the byte, word and long is
 * treated as reversed - bit 31 is the LSB and bit 0 is the MSB (bits 0 to
 * 31 are in left to right order).


 * BFCLR <ea>{offset from ea's leftmost bit : width/number of bits to clear}
 *
 * The BFCLR below will clear bits 8 to 11 of the memory at a0.

	lea	buf(pc),a0
	lea	16(a0),a0
	moveq	#0,d0
	moveq	#8,d1
	moveq	#4,d2
	bfclr	0(a0,d0.w){d1:d2}

 * The BFCLR below will clear bits 8 to 15 of the memory at a0 -12 +d0.

	lea	buf(pc),a0
	lea	16(a0),a0
	moveq	#2,d0
	moveq	#8,d1
	moveq	#8,d2
	bfclr	-12(a0,d0.w){d1:d2}

 * BFCHG, BFSET and BFTST take the same syntax as BFCLR.

 * The BFSET below will set bits 7 to 2 of the value inside d0.

	moveq	#0,d0
	moveq	#24,d1		; points to bit 7
	moveq	#6,d2		; set bits 7, 6, 5, 4, 3 and 2.
	bfset	d0{d1:d2}

 * The BFCHG below will exchange bits d1 (ie 7) to d2 (ie 2) of the value
 * inside d0.

	bfchg	d0{d1:d2}
	bfchg	d0{d1:d2}

 * The BFCHG below will exchange bits 8 to 15 of the memory at a0 -12 +d0.

	lea	buf(pc),a0
	lea	16(a0),a0
	moveq	#2,d0
	moveq	#8,d1
	moveq	#8,d2
	bfchg	-12(a0,d0.w){d1:d2}
	bfchg	-12(a0,d0.w){d1:d2}

 * The BFTST below will test bits 7 to 2 of the value inside d0.

	moveq	#0,d0
	moveq	#24,d1		; points to bit 7
	moveq	#6,d2		; set bits 7, 6, 5, 4, 3 and 2.
	bftst	d0{d1:d2}
	beq.s	zero

	nop

zero

 * The BFTST below will test bits 8 to 15 of the memory at a0 -12 +d0.

	lea	buf(pc),a0
	lea	16(a0),a0
	moveq	#2,d0
	moveq	#8,d1
	moveq	#8,d2
	bftst	-12(a0,d0.w){d1:d2}
	beq.s	zero_tst

	nop

zero_tst



	moveq	#0,d0
	rts

buf	dcb.b	64,255

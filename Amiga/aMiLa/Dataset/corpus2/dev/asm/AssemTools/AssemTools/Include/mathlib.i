
* Include File for METACC AMIGA MACRO ASSEMBLER
* for handling long integer values arithmetically
* 011188 v1.0 by TM + JM


;  sortentry.comments added -> v1.1  04.03.89
;  pull d2 -> pull d2/d2 for a68k -> v1.2 11.03.89
;  "badd, bsub, bneg, bclr, btst, bchk, bcmp, bmove",
;  "order" -> v1.3 20.06.89
;  "sqr, sqrt, hyp" -> v1.4 21.06.89
;  "random" -> v1.41 17.07.89


*T
*T	MATHLIB.I * Metacc Include File
*T		Version 1.41
*T	       Date 17.07.89
*T
*B

;  mulu		(multiply / 32*32->64 bits, unsigned /)
;  in:		d0, d1: integer;
;  call:	mathlib	mulu;
;  out:		d1 (63..32), d0 (31..0): double longint;

;  muls		(multiply / 32*32->64 bits, signed /)
;  in:		d0, d1: integer;
;  call:	mathlib	muls;
;  out:		d1 (63..32), d0 (31..0): double longint;

;  divu		(divide / 32/32->32 bits, unsigned /)
;  in:		d0, d1: integer;  { d0/d1 }
;  call:	mathlib divu;
;  out:		d0: d0 div d1;
;  		d1: d0 mod d1;

;  divs		(divide / 32/32->32 bits, signed /)
;  in:		d0, d1: integer;  { d0/d1 }
;  call:	mathlib divs;
;  out:		d0: d0 div d1;
;  		d1: d0 mod d1;

;  abs		(abs(x))
;  in:		d0: integer;
;  call:	mathlib abs;
;  out:		d0: positive integer;

;  sgn		(sgn(x))
;  in:		d0: integer;
;  call:	mathlib sgn;
;  out:		d0: integer in (-1,0,1);

;  sqr		(x²)
;  in:		d0: integer;
;  call:	mathlib	sqr;
;  out:		d0: integer; /-1 if error/

;  sqrt		(sqrt(x))
;  in:		d0: integer;
;  call:	mathlib	sqrt;
;  out:		d0: integer; /-1 if error/
;  notes:	Rounded to lower integer, if decimals in root

;  hyp		(sqrt(x²+y²))
;  in:		d0, d1: integer;
;  call:	mathlib	hyp;
;  out:		d0: integer;
;  notes:	See "sqrt"

;  extbl	(sign extend byte to long)
;  in:		d0: byte;
;  call:	mathlib extbl;
;  out:		d0: long;

;  order	(return higher and lower of two)
;  in:		d0, d1: integer;
;  call:	mathlib	order;
;  out:		d0: lower, d1: higher;

;  random	(generate 'random' numbers)
;  in:		d0: uword range, d1: word seed;
;  call:	mathlib	random;
;  out:		d0: uword number, d1: word new_seed;
;  notes:	The number returned is in the range from,
;		and including, 0, up to, but excluding, the
;		value given in d0, or, [0,d0[.
;		The new_seed can be given back to the routine
;		on the next calling.

;  bmove	(move and extend bcd)
;  in:		a0, d0: bcd; a1, d1: bcd;  {a1=a0}
;  call:	mathlib	bmove;
;  notes:	See "badd";
;		If the bcd a1 is longer than a0, the
;		value is sign-extended to full length.

;  badd		(add bcd)
;  in:		a0, d0: bcd; a1, d1: bcd;  {a0=a0+a1}
;  call:	mathlib	badd;
;  notes:	d0 is UWORD length of bcd a0 (in bytes),
;  		d1 is the same for a1. Action taken when
;  		either of the lengths is zero is undefined.
;  		The pointers a0, a1 point to the first (most
;  		significant) byte of the signed bcd.

;  bsub		(subtract bcd)
;  in:		a0, d0: bcd; a1, d1: bcd;  {a0=a0-a1}
;  call:	mathlib	bsub;
;  notes:	See "badd"

;  bcmp		(compare bcd)
;  in:		a0, d0: bcd1; a1, d1: bcd2;  {cmp a1,a0}
;  call:	mathlib	cbmp;
;  out:		d0: sign_of_result = in {-1, 0, 1};
;		p.flags = set_according_to_comparison;
;  notes:	See "badd"

;  bneg		(negate bcd)
;  in:		a0, d0: bcd;  {a0=-a0}
;  call:	mathlib	bneg;
;  notes:	See "badd"

;  bclr		(clear bcd)
;  in:		a0, d0: bcd;  {a0=0}
;  call:	mathlib	bclr;
;  notes:	See "badd"

;  btst		(test bcd)
;  in:		a0, d0: bcd;  {a0?}
;  call:	mathlib	btst;
;  out:		d0: integer in {-1, 0, 1};
;  notes:	See "badd"

;  bchk		(check bcd)
;  in:		a0, d0: bcd;  {check if valid bcd value}
;  call:	mathlib	bchk;
;  out:		d0: result; {if 0, value is OK}
;  notes:	See "badd"

*E

;;;


mathlib	macro
	  ifnc	  '\1',''
_MATHF\1    set	    1
	    bsr	    _MATH\1
	    mexit
	  endc

	    ifd	  _MATHFrandom
		xref	_custom
_MATHrandom	push	d2/a0
		lea.l	_custom,a0
		move.w	6(a0),d2
		lsl.w	#7,d1
		eor.w	d1,d2
		eor.w	#$f62a,d2
		move.w	d2,d1
		mulu.w	d0,d2
		swap	d2
		moveq.l	#0,d0
		move.w	d2,d0
		pull	d2/a0
		rts
	    endc

	    ifd	  _MATHFhyp
_MATHhyp	push	d1
		mathlib	sqr
		exg.l	d0,d1
		mathlib	sqr
		add.l	d1,d0
		mathlib	sqrt
		pull	d1/d1
		rts
	    endc

	    ifd	  _MATHFsqr
_MATHsqr	tst.l	d0
		bpl.s	_MATHsqr1
		neg.l	d0
_MATHsqr1	cmp.l	#65535,d0
		bhi.s	_MATHsqr0
		mulu.w	d0,d0
		rts
_MATHsqr0	moveq	#-1,d0
		rts
	    endc

	    ifd	  _MATHFsqrt
_MATHsqrt	push	d1-d4
		tst.l	d0
		bmi.s	_MATHsqrt4
		moveq.l	#0,d2
		move.l	#46340,d3
_MATHsqrt1	move.l	d2,d1
		add.l	d3,d1
		asr.l	#1,d1
		cmp.l	d2,d3
		beq.s	_MATHsqrt0
		move.l	d1,d4
		mulu.w	d4,d4
		cmp.l	d0,d4
		blt.s	_MATHsqrt2
		bgt.s	_MATHsqrt3
_MATHsqrt0	move.l	d1,d0
		pull	d1-d4
		rts
_MATHsqrt2	add.l	d1,d4
		add.l	d1,d4
		cmp.l	d0,d4
		bge.s	_MATHsqrt0
		move.l	d1,d2
		bra.s	_MATHsqrt1
_MATHsqrt3	move.l	d1,d3
		bra.s	_MATHsqrt1
_MATHsqrt4	moveq	#-1,d1
		bra.s	_MATHsqrt0
	    endc

	    ifd	  _MATHForder
_MATHorder	cmp.l	d0,d1
		bge.s	_MATHorder1
		exg.l	d0,d1
_MATHorder1	rts
	    endc

	    ifd	  _MATHFabs
_MATHabs	tst.l	d0
		bpl.s	_MATHabs1
		neg.l	d0
_MATHabs1	rts
	    endc

	    ifd	  _MATHFsgn
_MATHsgn	tst.l	d0
		beq.s	_MATHsgn1
		bpl.s	_MATHsgn2
		moveq.l	#-1,d0
_MATHsgn1	rts
_MATHsgn2	moveq.l	#1,d0
		rts
	    endc

	    ifd	  _MATHFextbl
_MATHextbl	ext.w	d0
		ext.l	d0
		rts
	    endc

	    ifd	  _MATHFbmove
_MATHbmove	push	a0-a3/d0-d3
		clr.b	d2
		cmp.b	#$49,(a0)
		bls.s	_MATHbmove1
		move.b	#$99,d2
_MATHbmove1	add.w	d0,a0
		add.w	d1,a1
_MATHbmove2	tst.w	d1
		beq.s	_MATHbmove0
		subq.w	#1,d1
		tst.w	d0
		bne.s	_MATHbmove3
		move.b	d2,-(a1)
		bra.s	_MATHbmove2
_MATHbmove3	subq.w	#1,d0
		move.b	-(a0),-(a1)
		bra.s	_MATHbmove2
_MATHbmove0	pull	a0-a3/d0-d3
		rts
	    endc

	    ifd	  _MATHFbclr
_MATHbclr	push	a0/d0
		add.w	d0,a0
_MATHbclr1	tst.w	d0
		beq.s	_MATHbclr0
		subq.w	#1,d0
		clr.b	-(a0)
		bra.s	_MATHbclr1
_MATHbclr0	pull	a0/d0
		rts
	    endc

	    ifd	  _MATHFbtst
_MATHbtst	push	a0-a3/d1-d3
		moveq	#-1,d1
		cmp.b	#$49,(a0)
		bhi.s	_MATHbtst0
		moveq	#1,d1
_MATHbtst1	tst.b	(a0)+
		bne.s	_MATHbtst0
		subq.w	#1,d0
		bne.s	_MATHbtst1
		moveq	#0,d1
_MATHbtst0	move.l	d1,d0
		pull	a0-a3/d1-d3
		rts
	    endc

	    ifd	  _MATHFbneg
_MATHbneg	push	a0-a3/d0-d3
		moveq	#0,d3
		add.w	d0,a0
_MATHbneg1	tst.w	d0
		beq.s	_MATHbneg0
		subq.w	#1,d0
		roxr.w	#1,d3
		nbcd.b	-(a0)
		roxl.w	#1,d3
		bra.s	_MATHbneg1
_MATHbneg0	pull	a0-a3/d0-d3
		rts
	    endc

	    ifd	  _MATHFbadd
_MATHbadd	push	a0-a3/d0-d3
		clr.w	-(sp)
		cmp.b	#$49,(a1)
		bls.s	_MATHbadd0b
		move.w	#$9999,(sp)
_MATHbadd0b	add.w	d0,a0
		add.w	d1,a1
		moveq	#0,d3
_MATHbadd1	tst.w	d0
		beq.s	_MATHbadd0
		subq.w	#1,d0
		lea.l	2(sp),a2
		tst.w	d1
		beq.s	_MATHbadd2
		subq.w	#1,d1
		move.l	a1,a2
_MATHbadd2	roxr.w	#1,d3
		abcd.b	-(a2),-(a0)
		roxl.w	#1,d3
		move.l	a2,a1
		bra.s	_MATHbadd1
_MATHbadd0	pull	a0-a3/d0-d3
		rts
	    endc

	    ifd	  _MATHFbsub
_MATHbsub	push	a0-a3/d0-d3
		clr.w	-(sp)
		cmp.b	#$49,(a1)
		bls.s	_MATHbsub0b
		move.w	#$9999,(sp)
_MATHbsub0b	add.w	d0,a0
		add.w	d1,a1
		moveq	#0,d3
_MATHbsub1	tst.w	d0
		beq.s	_MATHbsub0
		subq.w	#1,d0
		lea.l	2(sp),a2
		tst.w	d1
		beq.s	_MATHbsub2
		subq.w	#1,d1
		move.l	a1,a2
_MATHbsub2	roxr.w	#1,d3
		sbcd.b	-(a2),-(a0)
		roxl.w	#1,d3
		move.l	a2,a1
		bra.s	_MATHbsub1
_MATHbsub0	pull	a0-a3/d0-d3
		rts
	    endc

	    ifd	  _MATHFbcmp
_MATHbcmp	push	a0-a3/d1-d7
		clr.b	d6	;a0 pad
		cmp.b	#$49,(a0)
		bls.s	1$
		move.b	#$99,d6
1$		clr.b	d7	;a1 pad
		cmp.b	#$49,(a1)
		bls.s	2$
		move.b	#$99,d7
2$		move.b	d6,d2
		cmp.w	d1,d0
		blo.s	3$
		move.b	(a0)+,d2
		subq.w	#1,d0
		move.b	d7,d3
		cmp.w	d0,d1
		blo.s	4$
3$		move.b	(a1)+,d3
		subq.w	#1,d1
4$		clrx
		setz
		sbcd.b	d3,d2
		cmp.b	#$49,d2
		bhi.s	_MATHbcmp.lt
		tst.b	d2
		bne.s	_MATHbcmp.gt
		tst.w	d0
		bne.s	2$
		tst.w	d1
		bne.s	2$
		moveq	#0,d0
		bra.s	_MATHbcmp0
_MATHbcmp.lt	moveq	#-1,d0
		bra.s	_MATHbcmp0
_MATHbcmp.gt	moveq	#1,d0
_MATHbcmp0	pull	d1-d7/a0-a3
		cmp.w	#0,d0
		rts
	    endc

	    ifd	  _MATHFbchk
_MATHbchk	push	a0
		add.w	d0,a0
_MATHbchk1	tst.w	d0
		beq.s	_MATHbchk0
		subq.w	#1,d0
		cmp.b	#$99,-(a0)
		bls.s	_MATHbchk1
		moveq	#-1,d0
_MATHbchk0	pull	a0
		ext.l	d0
		rts
	    endc

	    ifd	  _MATHFmuls
_MATHmuls	push	d2
		move.l	d0,d2
		eor.l	d1,d2
		tst.l	d0
		bpl.s	_muls1
		neg.l	d0
_muls1		tst.l	d1
		bpl.s	_muls2
		neg.l	d1
_muls2		mathlib	mulu
		tst.l	d2
		bpl.s	_muls3
		neg.l	d0
		negx.l	d1
_muls3		pull	d2/d2
		rts
	    endc

	    ifd	  _MATHFmulu
_MATHmulu	push	d2-d4
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
_mulu1		lsr.l	#1,d0
		bcc.s	_mulu2
		add.l	d1,d2
		addx.l	d4,d3
_mulu2		asl.l	#1,d1
		roxl.l	#1,d4
		tst.l	d0
		bne.s	_mulu1
		move.l	d2,d0
		move.l	d3,d1
		pull	d2-d4
		rts
	    endc

	    ifd	  _MATHFdivs
_MATHdivs	push	d2-d3
		move.l	d0,d2
		move.l	d0,d3
		eor.l	d1,d2
		tst.l	d0
		bpl.s	_divs1
		neg.l	d0
_divs1		tst.l	d1
		bpl.s	_divs2
		neg.l	d1
_divs2		mathlib	divu
		tst.l	d2
		bpl.s	_divs3
		neg.l	d0
_divs3		tst.l	d3
		bpl.s	_divs4
		neg.l	d1
_divs4		pull	d2-d3
		rts
	    endc

	    ifd	  _MATHFdivu
_MATHdivu	push	d2-d4
		moveq.l	#0,d2
		moveq.l	#31,d4
_divu1		roxl.l	#1,d0	; divident
		roxl.l	#1,d2	; work accum
		cmp.l	d1,d2	; cmp with divisor
		blo.s	_divu2
		sub.l	d1,d2
		setx
_divu2		roxl.l	#1,d3	; result
		dbf	d4,_divu1
		move.l	d3,d0
		move.l	d2,d1
		pull	d2-d4
		rts
	    endc

	endm



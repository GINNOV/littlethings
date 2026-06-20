
* Include file for Amiga A68k macro assembler *
* created 19.07.89 JM - Supervisor Software *
* for handling Motorola FFP numbers *

*T
*T	FFPLIB.I * A68k Include File
*T		Version 1.00
*T	      Date 20.07.1989
*T

;  "atof, ftoa" created -> v0.10 19.07.89
;  "adjust" created -> v1.00 20.07.89



*B

;  atof		(convert ASCII to FFP)
;  in:		a0=*string;
;  call:	ffplib	atof;
;  out:		d0=FFP_number;
;		a0=*last_digit+1;
;		p.c=error;
;		p.v=overflow;
;  notes:	/uses a huge table; still needs some/
;		/cleanup/

;  ftoa		(convert FFP to ASCII)
;  in:		a0=*buffer;
;  call:	ffplib	ftoa;
;  out:		a0=*NULL;
;		d0=???;
;  notes:	/uses a huge table; still needs some/
;		/cleanup/
;		/output format: "S.abcdefghESij"/
;		/where S is "+" or "-" and a...j/
;		/are decimal digits 0...9/
;		/example: "-.12340000E+12"

;  adjust	(adjust an ASCII FFP number)
;  in:		a0=*string;
;  call:	ffplib	adjust;
;  out:		a0=*NULL;
;  notes:	/converts a FFP ASCII number into more/
;		/readable form/
;		/accepts input from ffplib ftoa/
;		/Output format:/
;		/number			format/
;		/ |X| < 1E-6		Sa.bcdefghE-ij/
;		/-1E8 < X <  1E8	Sa[b[c]d]]][.e[f[g[h]]]]/
;		/ 1E8 < X		 a.bcdefghE+ij/
;		/       X < -1E8	-a.bcdefghE+ij/

*E







_FFPFftoa	set	0
_FFPFatof	set	0


ffplib		macro	name
		ifnc	'\1',''
_FFPF\1	set	1
		bsr	_FFP\1
		mexit
		endc

		ifne	_FFPFftoa!_FFPFatof
	dc.b	$00,$40,$8a,$c7,$23,$05,$00,$3c,$de,$0b,$6b,$3a
	dc.b	$00,$39,$b1,$a2,$bc,$2f,$00,$36,$8e,$1b,$c9,$bf
	dc.b	$00,$32,$e3,$5f,$a9,$32,$00,$2f,$b5,$e6,$20,$f5
	dc.b	$00,$2c,$91,$84,$e7,$2a,$00,$28,$e8,$d4,$a5,$10
	dc.b	$00,$25,$ba,$43,$b7,$40,$00,$22,$95,$02,$f9,$00
	dc.b	$00,$1e,$ee,$6b,$28,$00,$00,$1b,$be,$bc,$20,$00
	dc.b	$00,$18,$98,$96,$80,$00,$00,$14,$f4,$24,$00,$00
	dc.b	$00,$11,$c3,$50,$00,$00,$00,$0e,$9c,$40,$00,$00
	dc.b	$00,$0a,$fa,$00,$00,$00,$00,$07,$c8,$00,$00,$00
	dc.b	$00,$04,$a0,$00,$00,$00
FFP10TBL
	dc.b	$00,$01,$80,$00,$00,$00,$ff,$fd,$cc,$cc,$cc,$cd
	dc.b	$ff,$fa,$a3,$d7,$0a,$3d,$ff,$f7,$83,$12,$6e,$98
	dc.b	$ff,$f3,$d1,$b7,$17,$59,$ff,$f0,$a7,$c5,$ac,$47
	dc.b	$ff,$ed,$86,$37,$bd,$06,$ff,$e9,$d6,$bf,$94,$d6
	dc.b	$ff,$e6,$ab,$cc,$77,$12,$ff,$e3,$89,$70,$5f,$41
	dc.b	$ff,$df,$db,$e6,$fe,$cf,$ff,$dc,$af,$eb,$ff,$0c
	dc.b	$ff,$d9,$8c,$bc,$cc,$09,$ff,$d5,$e1,$2e,$13,$42
	dc.b	$ff,$d2,$b4,$24,$dc,$35,$ff,$cf,$90,$1d,$7c,$f7
	dc.b	$ff,$cb,$e6,$95,$94,$bf,$ff,$c8,$b8,$77,$aa,$32
	dc.b	$ff,$c5,$93,$92,$ee,$8f,$ff,$c1,$ec,$1e,$4a,$7e
	dc.b	$ff,$be,$bc,$e5,$08,$65,$ff,$bb,$97,$1d,$a0,$50
	dc.b	$ff,$b7,$f1,$c9,$00,$81,$ff,$b4,$c1,$6d,$9a,$01
	dc.b	$ff,$b1,$9a,$be,$14,$cd,$ff,$ad,$f7,$96,$87,$ae
	dc.b	$ff,$aa,$c6,$12,$06,$25,$ff,$a7,$9e,$74,$d1,$b8
	dc.b	$ff,$a3,$fd,$87,$b5,$f3

	endc



	ifne	_FFPFatof

_FFPatof	push	d1-d5
		bsr.s	FPAATOF
		pull	d1-d5
		rts

FPAATOF	moveq	#0,d0		clear result
	moveq	#0,d1		clear exponent
	bsr	FPANXT		.eq if num, .c if error, .ne if sign; d5=num
	beq.s	FPANMB		-> jump if a decimal digit
	bcs.s	FPANOS		handle error somehow
	cmpi.b	#'-',d5		(comes here if char was plus or minus)
	seq	d1
	swap	d1
	bsr	FPANXT
	beq.s	FPANMB
FPANOS	cmpi.b	#'.',d5		decimal point?
	bne.s	FPABAD
	bsr	FPANXT
	beq.s	FPADOF
FPABAD	subq.l	#1,a0		error, return .C=1
	setc
	rts	 

FPANXD	bsr	FPANXT		get next byte of string
	bne.s	FPANOD		-> jump if not a digit
FPANMB	bsr.s	FPAX10		*10, add curr. dig. in d5, result in d0
	bcc.s	FPANXD		-> loop if no error (gets next byte)

FPAMOV	addq.w	#1,d1		skip here the least significant digits
	bsr.s	FPANXT		and do not store them.
	beq.s	FPAMOV		end of loop if not a digit
	cmpi.b	#'.',d5		is it a decimal point?
	bne.s	FPATSE		no -> check if it's an exponent
FPASRD	bsr.s	FPANXT		get next digit (skips digits after dp)
	beq.s	FPASRD		and loop until not a digit
FPATSE	cmpi.b	#'E',d5		is it "E"?
	beq.s	1$
	cmpi.b	#'e',d5
	bne.s	FPACNV		no -> exit to FFPDBF
1$	bsr.s	FPANXT		get digit of exponent
	beq.s	FPANTE		-> jump if a digit
	bcs.s	FPABAD		exit immediately with C=1 if error
	rol.l	#8,d1
	cmpi.b	#'-',d5		"-" negative exponent?
	seq	d1		if yes, set a flag
	ror.l	#8,d1
	bsr.s	FPANXT		get first digit of exponent
	bne.s	FPABAD		if not a digit, exit immediately
FPANTE	move.w	d5,d4		save current digit
FPANXE	bsr.s	FPANXT		get next
	bne.s	FPAFNE		jump if not a digit
	mulu.w	#10,d4		multiply old digit by 10
	cmpi.w	#$07d0,d4	check for overflow
	bhi.s	FPABAD		over/underflow -> exit immediately
	add.w	d5,d4		add new digit
	bra.s	FPANXE		continue loop until exponent taken

FPAFNE	tst.l	d1		end of exponent, test negative flag
	bpl.s	FPAADP
	neg.w	d4		negate exponent if necessary
FPAADP	add.w	d4,d1		... well, sets the bias, I think...
FPACNV	subq.l	#1,a0
	bra.s	FFPDBF		exit

FPANOD	cmpi.b	#'.',d5		comes here when the first numeric ends, "."?
	bne.s	FPATSE		-> no, check for exponent
FPADPN	bsr.s	FPANXT
	bne.s	FPATSE		-> exit if all digits eaten
FPADOF	bsr.s	FPAX10		get next digit (after dp)
	bcs.s	FPASRD
	subq.w	#1,d1		subtract one from exponent
	bra.s	FPADPN

FPAX10	move.l	d0,d3		put result into temporary register
	lsl.l	#1,d3		d3 temp. working register
	bcs.s	FPAXRT
	lsl.l	#1,d3
	bcs.s	FPAXRT
	lsl.l	#1,d3
	bcs.s	FPAXRT
	add.l	d0,d3
	bcs.s	FPAXRT
	add.l	d0,d3
	bcs.s	FPAXRT
	add.l	d5,d3		add current digit
	bcs.s	FPAXRT
	move.l	d3,d0		give result in d0
FPAXRT	rts	 

FPANXT	moveq	#0,d5		Ascii to FP NeXT char
	move.b	(a0)+,d5
	cmpi.b	#'+',d5		plus?
	beq.s	FPASGN		yes -> handle sign
	cmpi.b	#'-',d5		minus?
	beq.s	FPASGN		yes -> handle sign
	cmpi.b	#'0',d5
	bcs.s	FPAOTR		<0 -> out of range
	cmpi.b	#'9',d5
	bhi.s	FPAOTR		>9 -> out of range
	andi.b	#$0f,d5		make it a number
	move	#$0004,ccr	Z=1
	rts	 

FPASGN	move	#0,ccr		it was a sign		Z=C=0
	rts	 

FPAOTR	move	#1,ccr		error: out of range	C=1
	rts	 


FFPDBF	moveq	#$20,d5		I don't comprehend this...
	tst.l	d0
	beq	FPDRTN		if result=0, exit
	bmi.s	FPDINM
	moveq	#$1f,d5		get $1f if result is positive
FPDNMI	add.l	d0,d0		aha, it adjusts the number to the correct
	dbmi	d5,FPDNMI	bit position in d0 here!
FPDINM	cmpi.w	#$0012,d1
	bgt.s	FPDOVF		-> overflow, exit with V=1
	cmpi.w	#-$001c,d1
	blt.s	FPDRT0		-> underflow, returns a zero
	move.w	d1,d4		copy exponent
	neg.w	d4		negate it
	muls	#6,d4		and multiply by 6
	move.l	a0,-(sp)	save sourceptr
	lea	FFP10TBL(pc),a0	get table address
	add.w	0(a0,d4.w),d5	ummm...
	move.w	d5,d1		- " -
	move.l	2(a0,d4.w),d3	hmm...
	movea.l	(sp),a0		restore sourceptr
	move.l	d3,(sp)		save d3
	move.w	d0,d5
	mulu	d3,d5
	clr.w	d5
	swap	d5
	moveq	#0,d4
	swap	d3
	mulu	d0,d3
	add.l	d3,d5
	addx.b	d4,d4
	swap	d0
	move.w	d0,d3
	mulu	2(sp),d3
	add.l	d3,d5
	bcc.s	FPDNOC
	addq.b	#1,d4
FPDNOC	move.w	d4,d5
	swap	d5
	mulu	(sp),d0
	lea	4(sp),sp
	add.l	d5,d0
	bmi.s	FPDNON
	add.l	d0,d0
	subq.w	#1,d1
FPDNON	addi.l	#$00000080,d0
	bcc.s	FPDROK
	roxr.l	#1,d0
	addq.w	#1,d1
FPDROK	moveq	#9,d3
	move.w	d1,d4
	asl.w	d3,d1
	bvs.s	FPDXOV
	eori.w	#-$8000,d1
	lsr.l	d3,d1
	move.b	d1,d0			set exponent to d0
	beq.s	FPDRT0
FPDRTN	rts	 

FPDRT0	moveq	#0,d0			return a zero
	rts	 

FPDXOV	tst.w	d4
	bmi.s	FPDRT0
FPDOVF	moveq	#-1,d0			overflow: return V=1
	swap	d1
	roxr.b	#1,d1
	roxr.b	#1,d0
	tst.b	d0
	setv
	rts	 
	endc



	ifne	_FFPFftoa

_FFPftoa
	push	d1-d5/a1/a2		save registers
	move.l	a0,a2
	tst.b	d0			check if value is zero
	bne.s	FPFNOT0			jump if not zero
	moveq	#$41,d0			$41 represents zero
FPFNOT0	move.b	#'+',(a0)+
	move.b	#'.',(a0)+		store "+."
	move.b	d0,d1
	bpl.s	FPFPLS			jump if positive
	addq.b	#2,(a2)			make "+" a "-"
FPFPLS	add.b	d1,d1
	move.b	#-$80,d0
	eor.b	d0,d1
	ext.w	d1
	asr.w	#1,d1
	moveq	#1,d3
	lea.l	FFP10TBL(pc),a1		get table address
	cmp.w	(a1),d1
	blt.s	FPFMIN
	bgt.s	FPFPLU
FPFEQE	cmp.l	2(a1),d0
	bcc.s	FPFFND
FPFBCK	addq.w	#6,a1
	subq.w	#1,d3
	bra.s	FPFFND

FPFPLU	lea.l	-6(a1),a1
	addq.w	#1,d3
	cmp.w	(a1),d1
	bgt.s	FPFPLU
	beq.s	FPFEQE
	bra.s	FPFBCK

FPFMIN	lea.l	6(a1),a1
	subq.w	#1,d3
	cmp.w	(a1),d1
	blt.s	FPFMIN
	beq.s	FPFEQE
FPFFND	move.b	#'E',10(a2)	put seed of exponent
	move.b	#'+',11(a2)
	move.b	#'0',12(a2)
	move.b	#'0',13(a2)
	move.w	d3,d2
	bpl.s	FPFPEX
	neg.w	d2
	addq.b	#2,11(a2)	change "+" to "-"
FPFPEX	cmpi.w	#10,d2
	bcs.s	FPFGEN
	addq.b	#1,12(a2)	increment MSD of exponent
	subi.w	#10,d2
FPFGEN	or.b	d2,13(a2)	set LSD of exponent
	moveq	#7,d2
	tst.l	d0
	bpl.s	FPFZRO
	tst.b	5(a1)
	bne.s	FPFNXI
FPFZRO	clr.b	d0
FPFNXI	move.w	d1,d4
	sub.w	(a1)+,d4
	move.l	(a1)+,d5
	lsr.l	d4,d5
	moveq	#9,d4
FPFINC	sub.l	d5,d0
	dbcs	d4,FPFINC
	bcs.s	FPFNIM
	clr.b	d4
FPFNIM	add.l	d5,d0
	subi.b	#9,d4
	neg.b	d4
	ori.b	#'0',d4
	move.b	d4,(a0)+		stores an ASCII byte here! :-)
	dbf	d2,FPFNXI
	move.w	d3,d0
	ext.l	d0
	lea.l	14(a2),a0
	clr.b	(a0)
	pull	d1-d5/a1/a2
	rts	 

	endc



		ifd	_FFPFadjust

_FFPadjust	push	a1/d0-d2
		cmpi.b	#'-',(a0)		value negative?
		beq.s	01$			yes -> jump
		move.b	#' ',(a0)		replc plus with a space
01$		moveq	#0,d1			clear exponent
		moveq	#0,d0
		move.b	12(a0),d1		MSD
		mulu.w	#10,d1
 		move.b	13(a0),d0
		add.w	d0,d1			LSD
		sub.w	#('0'*10+'0'),d1	compensate for ASCII
		move.w	d1,d0
		cmpi.b	#'-',11(a0)		negative exponent?
		bne.s	1$			-> no
		neg.w	d1
1$		cmp.w	#9,d1			how big is the exponent?
		bge.s	_FFPadj_big		-> go handle big numbers
		tst.w	d1
		bgt.s	_FFPadj_spe		small positive exponent
		cmp.w	#-6,d1
		ble.s	_FFPadj_big		-> go handle small numbers


_FFPadj_sne	lea.l	10(a0),a1		addr of E
		moveq	#7,d2			# of digits to shift -1
		lea.l	1(a1,d0.w),a0
1$		move.b	-(a1),1(a1,d0.w)	shift mantissa to the right
		dbf	d2,1$
4$		move.b	#'0',-1(a1)		put integers (0)
		move.b	#'.',(a1)+		put dp
		subq.w	#1,d0
		bmi.s	_FFPadj_eze
2$		move.b	#'0',(a1)+		fill with zeros after dp
		dbf	d0,2$
_FFPadj_eze	cmp.b	#'0',-(a0)		blank unnecessary zeros
		beq.s	_FFPadj_eze
		cmp.b	#'.',(a0)		if no decimals, remove dp
		beq.s	1$
		addq.l	#1,a0
1$		clr.b	(a0)			add null
		pull	a1/d0-d2
		rts

_FFPadj_spe	subq.w	#1,d0			small positive exponent
		lea.l	2(a0),a1
1$		move.b	(a1)+,-2(a1)
		dbf	d0,1$
		move.b	#'.',-1(a1)
		lea	9(a0),a0
		bra.s	_FFPadj_eze		eat zeros

_FFPadj_big	move.b	1(a0),d0		swap first digit and dp
		move.b	2(a0),1(a0)
		move.b	d0,2(a0)
		subq.w	#1,d1			decrement exponent by one
_FFPadj_pet	tst.w	d1			test sign of exponent
		bmi.s	1$			jump if negative
		move.b	#'+',11(a0)		write plus sign
		bra.s	2$
1$		move.b	#'-',11(a0)		write minus sign
		neg.w	d1			make exponent positive again
2$		divu.w	#10,d1			separate digits
		or.b	#'0',d1
		lea	12(a0),a0
		move.b	d1,(a0)+		write MSD
		swap	d1
		or.b	#'0',d1
		move.b	d1,(a0)+		write LSD
		clr.b	(a0)			add NULL
		pull	a1/d0-d2
		rts
		endc		

		endm


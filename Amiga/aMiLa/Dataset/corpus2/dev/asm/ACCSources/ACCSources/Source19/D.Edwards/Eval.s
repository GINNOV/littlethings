


		opt	d+


* Test program to devise an expression evaluator.


		include	DF0:my_exec.i
		include	DF0:my_dos.i


* Variables


		rsreset

dos_base		rs.l	1
cli_in		rs.l	1
cli_out		rs.l	1

exprbuf		rs.l	1
restext		rs.l	1

value		rs.l	1

vars_sizeof	rs.w	0


main		move.l	#vars_sizeof,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1

		CALLEXEC	AllocMem
		tst.l	d0
		beq	cock_up_1

		move.l	d0,a6

		lea	dos_name(pc),a1
		moveq	#0,d0
		CALLEXEC	OpenLibrary
		move.l	d0,dos_base(a6)
		beq	cock_up_2

		CALLDOS	Input
		move.l	d0,cli_in(a6)

		CALLDOS	Output
		move.l	d0,cli_out(a6)

		lea	buffer(pc),a0
		move.l	a0,exprbuf(a6)

loop		lea	prompt(pc),a0
		bsr	StrLen
		move.l	a0,d2
		move.l	d7,d3
		move.l	cli_out(a6),d1
		CALLDOS	Write

		move.l	exprbuf(a6),d2
		moveq	#80,d3
		move.l	cli_in(a6),d1
		CALLDOS	Read

		move.l	exprbuf(a6),a0
		cmp.b	#"#",(a0)
		beq	cock_up_3

honk		clr.b	-1(a0,d0.l)

		move.l	exprbuf(a6),a0
		lea	CompOps(pc),a1
		lea	Funcs(pc),a2

		bsr	DoExp
		move.l	d1,value(a6)

		move.l	d1,d0
		move.l	exprbuf(a6),a0
		bsr	LtoAS
		move.l	a0,restext(a6)

		lea	result(pc),a0
		bsr	StrLen
		move.l	d7,d3
		move.l	a0,d2
		move.l	cli_out(a6),d1
		CALLDOS	Write

		move.l	restext(a6),a0
		bsr	StrLen
		move.l	d7,d3
		move.l	a0,d2
		move.l	cli_out(a6),d1
		CALLDOS	Write

		lea	hexb1(pc),a0
		bsr	StrLen
		move.l	d7,d3
		move.l	a0,d2
		move.l	cli_out(a6),d1
		CALLDOS	Write

		move.l	exprbuf(a6),a0
		move.l	value(a6),d0
		bsr	MakeHexL

		bsr	StrLen
		move.l	d7,d3
		move.l	a0,d2
		move.l	cli_out(a6),d1
		CALLDOS	Write

		lea	hexb2(pc),a0
		bsr	StrLen
		move.l	d7,d3
		move.l	a0,d2
		move.l	cli_out(a6),d1
		CALLDOS	Write

		bra	loop

cock_up_3	move.l	dos_base(a6),a1
		CALLEXEC	CloseLibrary

cock_up_2	move.l	a6,a1
		move.l	#vars_sizeof,d0
		CALLEXEC	FreeMem

cock_up_1	moveq	#0,d0
		rts


* THINGS TO DO :

* 1) Now that it works for syntactically correct expressions,
*	make it trap errors properly.

* 2) Add the necessary code to the GetNumVal() function to
*	allow it to obtain symbol values from an assembler
*	symbol table.

* 3) Make it handle expressions containing unary minus, unary
*	NOT and functions such as SIN().


* DoExp(a0,a1,a2) -> d0,d1
* a0 = ptr to expression string
* a1 = ptr to table of binary operators to use
* a2 = ptr to table of unary operators to use

* Evaluate an expression from scratch. Initialises parenthesis
* count, then falls through to DoSimpleExp() below.

* Returns :

* d0 =	error code (NULL if ok)
* d1 =	value of expression if NULL error code,
*	(undefined if error found)

* d0-d5/a0/a3 corrupt


DoExp		moveq	#0,d4		;initial parenthesis count
		move.l	d4,d5		;initial error code

		moveq	#-1,d0
		move.w	d0,-(sp)
		bsr	DoSimpleExp
		move.w	(sp)+,d0
		rts


* DoSimpleExp(a0,a1,a2) -> d0,d1
* a0 = ptr to expression string
* a1 = ptr to table of binary operators to use
* a2 = ptr to table of unary operators to use

* Evaluate a simple expression from scratch.
* Falls through to SimpleExp() below unless an
* error encountered or EOS hit.

* Not so simple now that it handles parentheses!

* Returns :

* d0 =	error code (NULL if ok)
* d1 =	value of expression if NULL error code,
*	(undefined if error found)

* d0-d5/a0/a3 corrupt


DoSimpleExp	moveq	#-1,d0		;initial 'no operator'
		moveq	#0,d1		;initial operand

		move.l	d1,d3		;make copies
		move.w	d0,d2

		tst.b	(a0)		;hit EOS already?
		beq	SEP_Done		;exit if so

		exg	a1,a2		;check for preceding
		bsr	GetOp		;unary operator
		bmi.s	DSP_3

		cmp.b	#"(",(a0)	;hit "("?
		bne.s	DSP_4		;continue if not

		addq.l	#1,a0		;point past "("
		addq.w	#1,d4		;update () nest count
		move.w	d0,-(sp)		;save unary operator
		moveq	#-1,d0
		move.w	d0,-(sp)		;signal new level
		exg	a1,a2		;recover normal table ptrs order
		bsr	DoSimpleExp	;evaluate (...)
		tst.w	(sp)+		;tidy the stack
		move.w	(sp)+,d0		;recover operator
		bra.s	DSP_5		;and do unary op

DSP_4		move.w	d0,d2		;save operator
		bsr	GetNumVal	;get value following unary op
		move.w	d2,d0		;recover unary operator
		exg	a1,a2		;recover normal table ptrs

DSP_5		bsr	DoUnary		;perform unary operation on it
		bra.s	DSP_6

		tst.b	(a0)		;hit EOS already?
		beq	SEP_Done		;exit if so

		cmp.b	#")",(a0)	;hit ")" already?
		beq	SEP_Done		;exit if so

DSP_3		exg	a1,a2
		cmp.b	#"(",(a0)	;hit "("?
		bne.s	DSP_1		;continue if not

		addq.l	#1,a0		;point past "("
		addq.w	#1,d4		;update () nest count

		move.w	d0,-(sp)		;signal new level
		bsr	DoSimpleExp	;else evaluate (...)
		move.w	(sp)+,d0		;tidy the stack

BKPT1		tst.b	(a0)		;hit EOS?
		beq	SEP_Done		;exit if so

		cmp.b	#")",(a0)	;hit ")"?
		bne.s	DSP_2		;continue if so

		addq.l	#1,a0		;point past ")"
		subq.w	#1,d4		;update () nest count
		rts			;and return		

DSP_1		bsr	GetNumVal	;get operand value

DSP_6		tst.b	(a0)		;hit EOS?
		beq	SEP_Done		;exit if so

		cmp.b	#")",(a0)	;hit ")" already?
		bne.s	DSP_2		;continue if not

		addq.l	#1,a0		;else skip past ")"
		subq.w	#1,d4		;update () nest count
		rts			;and exit

DSP_2		bsr	GetOp		;get an operator

		bpl.s	SimpleExp
		moveq	#1,d5		;else return error
		bra	SEP_Done		;(illegal operator)


* SimpleExp(d0,d1,a0,a1) -> d0,d1
* d0 = operator from previous fetch
* d1 = operand from previous fetch
* a0 = ptr to expression string
* a1 = ptr to table of operands to use

* Evaluate a 'simple' expression.

* Returns :

* d0 =	error code (NULL if ok)
* d1 =	value of expression if NULL error code,
*	(undefined if error found)

* d0-d5/a0/a3 corrupt


SimpleExp	move.l	d1,d3		;save previous op
		move.w	d0,d2		;values

		moveq	#-1,d0		;tmp invalid operator

		tst.b	(a0)		;hit EOS?
		beq	SEP_4		;do last operation if so

		exg	a1,a2		;check for a unary operator
		bsr	GetOp		;got it?
		bmi.s	SEP_9		;skip if not

		cmp.b	#"(",(a0)	;hit "("?
		bne.s	SEP_10		;skip if not

		addq.l	#1,a0		;point past "("
		addq.w	#1,d4		;update () nest count
		move.w	d0,-(sp)		;save unary operator
		moveq	#-1,d0
		move.w	d0,-(sp)		;signal new level
		exg	a1,a2		;recover normal table ptrs order
		move.l	d3,-(sp)		;save old operand & operator
		move.w	d2,-(sp)
		bsr	DoSimpleExp	;evaluate (...)
		move.w	(sp)+,d2		;recover prev operand, operator
		move.l	(sp)+,d3
		tst.w	(sp)+		;tidy the stack
		move.w	(sp)+,d0		;recover operator
		bra.s	SEP_11		;and do unary op

SEP_10		move.w	d0,-(sp)		;save unary operator
		bsr	GetNumVal	;get following operand
		move.w	(sp)+,d0		;recover operand
		exg	a1,a2		;recover normal table ptrs

SEP_11		bsr	DoUnary		;do unary operation
		bra.s	SEP_7		;and continue on

SEP_9		exg	a1,a2		;recover normal table ptrs
		cmp.b	#"(",(a0)	;hit "("?
		bne.s	SEP_5		;continue if not

		addq.l	#1,a0		;point past "("
		addq.w	#1,d4		;update () nest count

		move.l	d3,-(sp)		;save operand
		move.w	d2,-(sp)		;save operator
		move.w	d0,-(sp)		;signal new nesting level

		bsr	DoSimpleExp	;evaluate (...)

BKPT2		move.w	(sp)+,d0		;tidy stack
		move.w	(sp)+,d2		;recover operator
		move.l	(sp)+,d3		;recover operand
		bra.s	SEP_7		;and continue

SEP_5		bsr	GetNumVal	;get new operand

SEP_7		moveq	#-1,d0		;tmp invalid operator

		tst.b	(a0)		;hit EOS?
		beq.s	SEP_4		;do last operation if so

		cmp.b	#")",(a0)	;hit ")"?
		bne.s	SEP_8		;continue if not

		addq.l	#1,a0		;point past ")"
		subq.w	#1,d4		;update () nest count

		bsr	DoTerm		;do last part of (...)

		rts			;and return

SEP_8		bsr	GetOp		;get an operator
		bpl.s	SEP_3		;and continue if OK

		moveq	#1,d5		;else error
		bra.s	SEP_Done		;(illegal operator)

SEP_3		cmp.b	d2,d0		;new op > prev op?
		bhi.s	SEP_1		;skip if so

SEP_4		bsr	DoTerm		;else compute this term

		tst.b	(a0)
		beq.s	SEP_Done

		tst.w	4(sp)
		bpl.s	SEP_Done

		tst.w	d0
		bpl	SimpleExp

SEP_Done		rts			;else back to caller

SEP_Error	rts


* Come here if most recent operator fetched from string has a
* higher precedence than the previous operator.


SEP_1		move.l	d3,-(sp)		;save prev opnd, op
		move.w	d2,-(sp)

;		bsr	NestExp		;get a new term to compute
		bsr	SimpleExp

BKPT3		move.w	(sp)+,d2		;recover old ops
		move.l	(sp)+,d3

		bsr	DoTerm		;compute left over term

		tst.b	(a0)		;hit EOS?
		beq.s	SEP_Done		;exit if so

		tst.w	d0		;got a following operator?
		bpl	SimpleExp	;skip if so

;		bsr	GetOp		;else get it
;		bra	SimpleExp

		rts			;else done


* This code mimics SimpleExp() except for behaving differently
* when called as a result of higher precedence operations
* overriding the normal left-to-right evaluation sequence. The
* main difference is that an extra check for a pending operator
* is made, forcing an exit back to the next level up if one exists.


NestExp		move.l	d1,d3		;save previous op
		move.w	d0,d2		;values

		tst.b	(a0)		;hit EOS?
		beq.s	NEP_4		;do last operation if so

		cmp.b	#"(",(a0)	;hit a "("?
		bne.s	NEP_5		;continue if not

		addq.l	#1,a0		;point past "("
		addq.w	#1,d4		;update () nest count

		move.l	d3,-(sp)		;save previous ops
		move.w	d2,-(sp)
		bsr	DoSimpleExp	;eval expr in (...)
		bsr	DoTerm		;eval last part of (...)
		move.w	(sp)+,d2		;recover previous ops
		move.l	(sp)+,d3

		bra.s	NEP_6		;and evaluate (...)

NEP_5		move.w	d0,-(sp)
		bsr	GetNumVal	;get new operand
		move.w	(sp)+,d0

NEP_6		cmp.b	#")",(a0)	;hit ")"?
		bne.s	NEP_7		;continue if not

		bsr	DoTerm		;evaluate end expression

		addq.l	#1,a0		;skip past ")"
		subq.w	#1,d4		;update () nest count

		bsr	GetOp		;CHECK THIS!

		rts

NEP_7		moveq	#-1,d0		;tmp invalid operator
		tst.b	(a0)		;hit EOS?
		beq.s	NEP_4		;do last operation if so

		bsr	GetOp		;get an operator
		bpl.s	NEP_3		;and continue if OK

		moveq	#1,d5		;else error
		bra.s	NEP_Done		;(illegal operator)

NEP_3		cmp.b	d2,d0		;new op > prev op?
		bhi.s	NEP_1		;skip if so

NEP_4		bsr	DoTerm		;else compute this term

		tst.w	d0		;another operator to do?
		bpl.s	NEP_Done		;skip if so

		tst.b	(a0)		;hit EOS?
		bne	SimpleExp	;continue if not

NEP_Done		rts


NEP_1		move.l	d3,-(sp)		;save prev opnd, op
		move.w	d2,-(sp)

		bsr	NestExp		;get a new term to compute
		bsr	DoTerm

		move.w	(sp)+,d2		;recover old ops
		move.l	(sp)+,d3

		bsr	DoTerm		;compute left over term

		tst.b	(a0)		;hit EOS?
		bne	SimpleExp	;continue if not
		rts			;else done


* DoTerm(d1,d2,d3) -> d1

* d1,d3 = operands
* d2 = operator to use

* Evaluate a term. Return value in d1.

* d2/d3/a3 corrupt


DoTerm		exg	d1,d3		;change operand order
		lea	CompTable(pc),a3
		clr.b	d2
		lsr.w	#6,d2		;operator no * 4
		add.w	d2,a3		;point to jump table entry
		move.l	(a3),a3		;get arith routine address
		jmp	(a3)		;execute it


* DoUnary(d0,d1) -> d1

* d1 = operands
* d0 = operator to use

* Evaluate a unary term. Return value in d1.

* d0/a3 corrupt


DoUnary		lea	FuncTable(pc),a3
		clr.b	d0
		lsr.w	#6,d0		;operator no * 4
		add.w	d0,a3		;point to jump table entry
		move.l	(a3),a3		;get arith routine address
		jmp	(a3)		;execute it


CompTable	dc.l	DoPower
		dc.l	DoDiv
		dc.l	DoMul
		dc.l	DoLShift
		dc.l	DoRShift
		dc.l	DoAdd
		dc.l	DoSub
		dc.l	DoR_GE
		dc.l	DoR_LE
		dc.l	DoR_GT
		dc.l	DoR_LT
		dc.l	DoR_NE
		dc.l	DoR_EQ
		dc.l	DoB_AND
		dc.l	DoB_XOR
		dc.l	DoB_OR
		dc.l	DoL_AND
		dc.l	DoL_AND
		dc.l	DoL_OR
		dc.l	DoL_OR


FuncTable	dc.l	DoNeg
		dc.l	DoNot
		dc.l	DoNot


* GetNumVal(a0) -> d0,d1
* a0 = ptr to value string

* returns:

* d0 = error code (NULL if ok)
* d1 = value represented by ASCII digit/label string

* a0 corrupt


GetNumVal	moveq	#0,d1		;init value
		move.l	d1,d0

		move.l	d2,-(sp)		;save this

		move.b	(a0)+,d0		;get 1st char

		cmp.b	#"0",d0		;digit?
		bcs.s	GNV_1		;skip if before "0"

		cmp.b	#"9",d0		;digit?
		bls.s	GNV_Dec		;skip if decimal value

GNV_1		cmp.b	#"$",d0		;hex value?
		beq.s	GNV_Hex		;skip if so

		cmp.b	#"%",d0		;binary value?
		beq.s	GNV_Bin		;skip if so

		cmp.b	#"@",d0		;octal value?
		beq.s	GNV_Oct		;skip if so

		nop			;else it's a label

GNV_Done		subq.l	#1,a0		;point to 1st operator char!
		move.l	(sp)+,d2		;recover this
		moveq	#0,d0		;signal no error

		rts


GNV_Dec		move.l	d1,d2		;current value

		add.l	d1,d1
		add.l	d1,d1
		add.l	d2,d1
		add.l	d1,d1		;current value * 10

		sub.b	#"0",d0
		add.l	d0,d1		;plus new digit

		moveq	#0,d0
		move.b	(a0)+,d0		;get char
		cmp.b	#"0",d0		;digit?
		bcs.s	GNV_Done		;exit if not
		cmp.b	#"9",d0
		bhi.s	GNV_Done
		bra.s	GNV_Dec		;else continue evaluation


GNV_Hex		moveq	#0,d0
		move.b	(a0)+,d0		;get char
		sub.b	#"0",d0		;create digit
		cmp.b	#9,d0		;digit 0-9?
		bls.s	GNV_2		;skip if so
		subq.b	#7,d0		;digit A-F? (prev 6!)
		cmp.b	#$A,d0
		bcs.s	GNV_Done
		cmp.b	#$F,d0
		bls.s	GNV_2
		sub.b	#$20,d0
		cmp.b	#$A,d0
		bcs.s	GNV_Done
		cmp.b	#$F,d0		;digit a-f?
		bhi.s	GNV_Done		;exit if not
GNV_2		lsl.l	#4,d1
		add.l	d0,d1		;create hex value
		bra.s	GNV_Hex		;back for next char


GNV_Bin		moveq	#0,d0
		move.b	(a0)+,d0		;get char
		sub.b	#"0",d0		;ASCII to digit convert
		cmp.b	#1,d0		;check if binary digit
		bhi.s	GNV_Done		;exit if not-done
		add.l	d1,d1
		add.l	d0,d1		;create binary value
		bra.s	GNV_Bin


GNV_Oct		moveq	#0,d0
		move.b	(a0)+,d0		;get char
		sub.b	#"0",d0		;ASCII to digit convert
		cmp.b	#7,d0		;check if octal digit
		bhi.s	GNV_Done		;exit if not-done
		add.l	d1,d1
		add.l	d1,d1
		add.l	d1,d1
		add.l	d0,d1		;create octal value
		bra.s	GNV_Oct


* GetOp(a0,a1) -> d0
* a0 = ptr to expression text
* a1 = ptr to table of operators to scan

* Get operator + precedence (returns -1 if error)

* No other registers corrupt


GetOp		move.l	d2,-(sp)		;save this
		moveq	#0,d2		;operator number
		move.l	a1,-(sp)		;save operator table ptr

GetOp_0		move.b	(a1)+,d0		;char count
		beq.s	GetOp_Err	;oops...
		move.l	a0,-(sp)		;save text ptr

GetOp_1		cmp.b	(a0)+,(a1)+	;chars equal?
		bne.s	GetOp_2		;skip if not
		subq.b	#1,d0		;done all chars?
		bne.s	GetOp_1		;back for more if not

		move.b	d2,d0		;else copy operator number
		lsl.w	#8,d0
		move.b	(a1)+,d0		;and precedence

		tst.l	(sp)+		;clean stack

		move.l	(sp)+,a1		;recover table ptr
		move.l	(sp)+,d2		;recover this
		tst.w	d0		;signal OK
		rts			;done

GetOp_2		subq.b	#1,d0		;done all chars?
		beq.s	GetOp_3
		addq.l	#1,a1		;else next table char
		bra.s	GetOp_2		;and back for more

GetOp_3		addq.l	#1,a1		;point past precedence
		move.l	(sp)+,a0		;recover text pointer
		addq.w	#1,d2		;next operator number
		bra.s	GetOp_0		;and get next one

GetOp_Err	move.l	(sp)+,a1		;recover table ptr
		move.l	(sp)+,d2		;recover this
		moveq	#-1,d0		;return error code
		rts


* TABLE OF FUNCTIONS TO EXECUTE WHEN BINARY OPERATOR ENCOUNTERED


* DoDiv(d1,d2) -> d1
* d1,d2 = values to act on
* returns d1/d2 in d1

* Same protocol for DoMul() etc


DoDiv		move.l	d6,-(sp)		;save this

		movem.l	d1/d3,-(sp)	;save original parms

		tst.l	d1		;1st arg positive?
		bpl.s	DoDiv_5		;skip if so
		neg.l	d1		;else make positive

DoDiv_5		tst.l	d3		;2nd arg positive?
		bpl.s	DoDiv_6		;skip if so
		neg.l	d3		;else make positive

DoDiv_6		moveq	#0,d6	;shift count

		tst.l	d3	;division by zero?
		beq.s	DoDiv_1	;skip to error if so

DoDiv_4		swap	d3
		tst.w	d3	;high word zero?
		bne.s	DoDiv_2	;no, so change shift count
		swap	d3
		bra.s	DoDiv_3	;else use as is

DoDiv_2		swap	d3	;replace high word
		asr.l	#1,d3	;shift
		addq.w	#1,d6	;update shift count
		bra.s	DoDiv_4	;test again

DoDiv_3		divu	d3,d1	;perform division
		bvs.s	DoDiv_9	;oops...
		ext.l	d1	;make result full 32-bit

		asr.l	d6,d1	;normalise the result

DoDiv_10		tst.l	(sp)+	;check sign of arg #1
		bpl.s	DoDiv_7	;skip if positive
		neg.l	d1	;else negate

DoDiv_7		tst.l	(sp)+	;check sign of arg #2
		bpl.s	DoDiv_8	;skip if positive
		neg.l	d1	;else negate

DoDiv_8		move.l	(sp)+,d6	;tidy stack
		rts

DoDiv_1		moveq	#2,d5	;return error code
		move.l	(sp)+,d6	;and tidy stack
		rts


* Come here if the result of the division won't fit into 16 bits.


DoDiv_9		addq.w	#1,d6		;shift count
		add.l	d3,d3		;divisor * 2
		divu	d3,d1		;do division again
		bvs.s	DoDiv_9		;and retry if overflow

		asl.l	d6,d1		;remultiply result
		bra.s	DoDiv_10		;and normalise result


* DoMul(d1,d3)
* d1,d3 = arguments to multiply together

* This complex routine takes account of multiplying two long ints
* together (68000 MULU/MULS only takes 16-bit args) by doing the
* multiplication in stages:

* Stage 1 : Low word of D1 * low word of D3

* Stage 2 : High word of D1 * low word of D3

* Stage 3 : Low word of D1 * high word of D3

* Stage 4 : High word of D1 * high word of D3

* Total result is a 64-bit quantity. if each stage is split
* into words as follows:

*	Stage 1 :	A B
*	Stage 2 :	C D
*	Stage 3 :	E F
*	Stage 4 :	G H

* then the final result is formed as:

*		0 0 A B		(Here 0 represents a
*		0 C D 0	+	 zero WORD, i.e.,
*		0 E F 0	+	 $0000.W)
*		G H 0 0	+

* For this code, only the LOW LONG WORD is used. Other users of
* this code might like to alter it to use the ENTIRE 64-bit
* result.


DoMul		movem.l	d4-d7,-(sp)	;save workspace
		movem.l	d1/d3,-(sp)	;save original args
		tst.l	d1
		bpl.s	DoMul_1
		neg.l	d1		;force positive
DoMul_1		tst.l	d3
		bpl.s	DoMul_2
		neg.l	d3		;force positive
DoMul_2		move.w	d1,d4
		mulu	d3,d4		;do Arg1L * Arg2L

		swap	d1
		move.w	d1,d5
		mulu	d3,d5		;do Arg1H * Arg2L

		swap	d1
		swap	d3
		move.w	d1,d6
		mulu	d3,d6		;do Arg1L * Arg2H

		swap	d1
		swap	d3
		move.w	d1,d7
		mulu	d3,d7		;do Arg1H * Arg2H

		add.l	d5,d6
		swap	d6
		clr.w	d6
		add.l	d4,d6
		move.l	d6,d1

		tst.l	(sp)+
		bpl.s	DoMul_3
		neg.l	d1
DoMul_3		tst.l	(sp)+
		bpl.s	DoMul_4
		neg.l	d1
DoMul_4		movem.l	(sp)+,d4-d7	;recover these
		rts

		muls	d3,d1
		rts

DoLShift		asl.l	d3,d1
		rts

DoRShift		asr.l	d3,d1
		rts

DoAdd		add.l	d3,d1
		rts

DoSub		sub.l	d3,d1
		rts

DoR_GE		cmp.l	d3,d1
		sge	d1
		ext.w	d1
		ext.l	d1
		rts


DoR_LE		cmp.l	d3,d1
		sle	d1
		ext.w	d1
		ext.l	d1
		rts

DoR_GT		cmp.l	d3,d1
		sgt	d1
		ext.w	d1
		ext.l	d1
		rts

DoR_LT		cmp.l	d3,d1
		slt	d1
		ext.w	d1
		ext.l	d1
		rts


DoR_NE		cmp.l	d3,d1
		sne	d1
		ext.w	d1
		ext.l	d1
		rts


DoR_EQ		cmp.l	d3,d1
		seq	d1
		ext.w	d1
		ext.l	d1
		rts

DoB_AND		and.l	d3,d1
		rts


DoB_XOR		eor.l	d3,d1
		rts

DoB_OR		or.l	d3,d1
		rts

DoL_AND		and.l	d3,d1
		sne	d1
		ext.w	d1
		ext.l	d1
		rts


DoL_OR		or.l	d3,d1
		sne	d1
		ext.w	d1
		ext.l	d1
		rts


DoLowByte	move.b	d1,d3
		moveq	#0,d1
		move.b	d3,d1
		rts


DoHighByte	move.w	d1,d3
		moveq	#0,d1
		move.w	d3,d1
		lsr.w	#8,d1
		rts

DoPower		move.l	d7,-(sp)
		move.l	d1,d7
		tst.l	d3
		beq.s	DoPower_2

DoPower_1	subq.l	#1,d3
		beq.s	DoPower_3
		move.l	d3,-(sp)
		move.l	d7,d3
		bsr	DoMul
		move.l	(sp)+,d3
		bra.s	DoPower_1

DoPower_3	move.l	(sp)+,d7

		rts

DoPower_2	moveq	#1,d1
		rts


* TABLE OF FUNCTIONS TO EXECUTE WHEN UNARY OPERATOR ENCOUNTERED


DoNeg		neg.l	d1
		rts

DoNot		not.l	d1
		rts


* StrLen(a0) -> d7
* a0 = ptr to string to scan

* return string length in d7

* No other registers corrupt


StrLen		move.l	a0,-(sp)		;save string pointer
		moveq	#0,d7		;initial length

StrLen_1		tst.b	(a0)+		;hit EOS?
		beq.s	StrLen_2		;skip if so

		addq.l	#1,d7		;else update char count
		bra.s	StrLen_1

StrLen_2		move.l	(sp)+,a0		;recover string pointer
		rts


* LtoA(a0,d0) -> a0
* d0 = UNSIGNED long int to convert to string
* a0 = buffer for string creation

* Convert a long integer into an ASCII string. Returns
* pointer to ASCII digit string in a0.

* d0-d3/a0-a1 corrupt


LtoA		move.l	a0,-(sp)		;save buffer ptr

		lea	NumBase(pc),a1	;ptr to base values

LtoA_1		moveq	#0,d1		;no of B^Ns in number

		move.l	(a1)+,d2		;get B^N
		beq.s	LtoA_Done	;exit if 0 - done!
		cmp.l	d2,d0		;num > B^N?
		bcs.s	LtoA_3		;skip if not

		move.l	d2,d3		;copy B^N
LtoA_2		addq.w	#1,d1		;at least this many B^Ns
		add.l	d2,d3		;add another one
		cmp.l	d3,d0		;num > (f * B^N) ?
		bcc.s	LtoA_2		;back if so

		sub.l	d3,d0		;create num - (f * B^N)
		add.l	d2,d0		;for next round

LtoA_3		add.b	#"0",d1		;create ASCII digit
		move.b	d1,(a0)+		;insert char

		bra.s	LtoA_1

LtoA_Done	clr.b	(a0)+		;append EOS to string

		move.l	(sp)+,a0		;recover buffer ptr

LtoA_4		cmp.b	#"0",(a0)+	;skip initial "0"s
		beq.s	LtoA_4

		subq.l	#1,a0		;correct pointer
		tst.b	(a0)
		bne.s	LtoA_5

		subq.l	#1,a0		;handle zero case

LtoA_5		rts


* LtoAS(a0,d0)
* a0 = ptr to buffer for string
* d0 = SIGNED long int to convert

* Perform same as LtoA() above, but for signed long ints.

* d0-d3/a0-a1 corrupt


LtoAS		move.l	d0,-(sp)		;save original long int

		tst.l	d0		;create absolute value
		bpl.s	LtoAS_1		;skip if already positive
		neg.l	d0		;else make it positive
LtoAS_1		bsr	LtoA		;perform conversion

		tst.l	(sp)+		;original negative?
		bpl.s	LtoAS_2

		move.b	#"-",-(a0)	;prepend minus sign

LtoAS_2		rts


* MakeHexL(a0,d0)
* a0 = ptr to buffer for string
* d0 = long int to convert to hex digit string

* d0-d2 corrupt


MakeHexL		move.l	a0,-(sp)

		moveq	#8,d1

MHL_1		moveq	#0,d2
		rol.l	#4,d0
		move.b	d0,d2
		and.b	#$F,d2
		add.b	#"0",d2
		cmp.b	#"9",d2
		bls.s	MHL_2
		addq.b	#7,d2
MHL_2		move.b	d2,(a0)+
		subq.w	#1,d1
		bne.s	MHL_1

		clr.b	(a0)+

		move.l	(sp)+,a0

		rts




;CompOps		dc.b	1,"/",4
		dc.b	1,"*",4
		dc.b	1,"+",2
		dc.b	1,"-",2
		dc.b	0		;end of operators!

CompOps		dc.b	2,"^^",12	; exponentiation
		dc.b	1,"/",11		; division
		dc.b	1,"*",11		; multipication
		dc.b	2,"<<",10	; left shift
		dc.b	2,">>",10	; right shift
		dc.b	1,"+",9		; addition
		dc.b	1,"-",9		; subtraction
		dc.b	2,">=",7		; relational >=
		dc.b	2,"<=",7		; relational <=
		dc.b	1,">",7		; relational >
		dc.b	1,"<",7		; relational <
		dc.b	2,"!=",6		; <> relational
		dc.b	2,"==",6		; = relational
		dc.b	1,"&",5		; bitwise AND
		dc.b	1,"^",4		; bitwise XOR
		dc.b	1,"|",3		; bitwise OR
		dc.b	3,"AND",2	; logical AND
		dc.b	3,"and",2	; logical AND
		dc.b	2,"OR",1		; logical OR
		dc.b	2,"or",1		; logical OR
		dc.b	0

Funcs		dc.b	1,"-",2
		dc.b	3,"NOT",1
		dc.b	3,"not",1
		dc.b	0

NumBase		dc.l	1000000000,100000000,10000000,1000000
		dc.l	100000,10000,1000,100,10,1,0


dos_name		dc.b	"dos.library",0

prompt		dc.b	10,10
		dc.b	"Enter Expression : ",0

result		dc.b	10,10
		dc.b	"Value is : ",0

hexb1		dc.b	" ($",0

hexb2		dc.b	")",0

		ds.b	4
buffer		ds.b	256









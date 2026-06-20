
**********************************************************************
*
*	AnyLongToStr - Convert 32-bit value to ASCII
*
* Input:  d0 - the value to convert
*         d1 - flags
*         a0 - pointer to a buffer 
* Output: d0 - number of characters written (or null for error)
*         a0 - address of the terminating null
*
*
*	Flags are:
*   LTS_DECIMAL   - normal decimal conversion
*   LTS_SIGN_LONG - decimal signed mode (longword)
*   LTS_SIGN_WORD - signed (word)
*   LTS_SIGN_BYTE - signed (byte)
*   LTS_BINARY    - convert to binary
*   LTS_HEX_UPPER - convert to hex (A-F)
*   LTS_HEX_LOWER - convert to hex (a-f)
*
*
*	You should pass a buffer with at least 11/12 (decimal/negative
* decimal), 9 (hex) or 33 (binary) bytes of space.
*	If flags = #1, checks the 31 bit and if it is high, assumes
* the  value is lower than 0.
*	This string is null-terminated. Address of the terminating
* null is returned in a0. The null is included in number of chars
* written.
*
*	When you specify decimal non-signed mode, then even if
* bit 31 is set you'll get value in range 0 to 4.294.967.295. In
* signed mode you'll get values in range from -2.147.483.647 to
* 2.147.483.648 (negative when bit 31/15/7 is set, depending on the
* choosen mode). Minus sign is written, if needed (and added to chars
* counter returned in d0).
*
*	No prefix is written in hex/bin mode!!! If you need it, write
* it yourself. That's how you can choose between '$'/'0x' :-)
*
*	Alters only scratch registers (d0, d1, a0, a1). Uses 12 bytes
* of stack.
*
*
*	© 1996 by Tadek Knapik (tadek@student.uci.agh.edu.pl).
*		 Public Domain. E-mail appreciated :-)
*
**********************************************************************


LTS_DECIMAL	equ	0
LTS_BINARY	equ	2
LTS_HEX_UPPER	equ	4
LTS_HEX_LOWER	equ	8
LTS_SIGN_LONG	equ	16
LTS_SIGN_WORD	equ	32
LTS_SIGN_BYTE	equ	64
LTS_NEGATIVE	equ	LTS_SIGN_LONG
LTS_HEX		equ	LTS_HEX_UPPER


AnyLongToStr:
	movem.l	d2-d4,-(sp)
	moveq	#0,d2			;the counter

	cmpi.l	#LTS_DECIMAL,d1
	beq	LTSDecConvert

	cmpi.l	#LTS_SIGN_LONG,d1
	beq	LTSMinDecConvert

	cmpi.l	#LTS_SIGN_WORD,d1
	beq	LTSMinWDecConvert

	cmpi.l	#LTS_SIGN_BYTE,d1
	beq	LTSMinBDecConvert

	cmpi.l	#LTS_BINARY,d1
	beq	LTSBinConvert

	move.l	#'A',d2			;ASCII base uppercased

	cmpi.l	#LTS_HEX_UPPER,d1
	beq	LTSHexConvert

	move.l	#'a',d2			;ASCII base lowercased

	cmpi.l	#LTS_HEX_LOWER,d1
	beq	LTSHexConvert

LTSError:
	movem.l	(sp)+,d2-d4
	moveq	#0,d1
	moveq	#0,d0
	rts

;--------------------

LTSMinBDecConvert:
	ext.w	d0			;extend to word
LTSMinWDecConvert
	ext.l	d0			;extend to longword

LTSMinDecConvert:
	btst	#31,d0
	beq	LTSDecConvert
	move.b	#'-',(a0)+		;the minus sign
	addq.l	#1,d2
	neg.l	d0			;so I need plus now

LTSDecConvert:
	moveq	#0,d1			;zeroes flag
	move.l	#1000000000,d4		;32-bit max power of 10

LTSDecAgain:
	cmp.l	d4,d0
	bcc	LTSDecMatch

	tst.l	d1			;write zeroes?
	beq	LTSDecNextPass		;not yet

	move.b	#'0',(a0)+		;write it
	addq.l	#1,d2			;one character more
	bra	LTSDecNextPass

LTSDecMatch:
	moveq	#1,d1			;means write zeros from now
	moveq	#0,d3			;clear temporary

LTSDecLoop:
	addq.l	#1,d3			;

	sub.l	d4,d0
	bpl	LTSDecLoop		;branch if not less than 0

	add.l	d4,d0			;did it too many times
	subq.l	#1,d3			;as well

	addi.l	#'0',d3			;ASCII 0
	move.b	d3,(a0)+
	addq.l	#1,d2			;the counter

LTSDecNextPass:
	bsr	LTSDecDivideByTen
	tst.l	d4
	beq	LTSError

	cmpi.l	#1,d4
	bne	LTSDecAgain

;less than 10 in d0..

	addi.l	#'0',d0
	move.b	d0,(a0)+
	addq.l	#1,d2

LTSDecOver:
	move.b	#0,(a0)
	suba.l	#1,a0
	addq.l	#1,d2			;null is a character, too
	move.l	d2,d0
	movem.l	(sp)+,d2-d4
	rts


LTSDecDivideByTen:

;
;if your proggy is to be run on 020+ only!
;
;	mulu.l	#10,d4
;	rts

;now 68000 part. Thanks for Simon N Goodwin for this routine!

	moveq   #0,d3			;temporary register
	swap    d4			;higher 16 bits
	move.w  d4,d3			;
	divu    #10,d3                  ;divide higher 16 bits
	swap    d3			;store in high word of d3
	move.w  d3,d4			;safe?
	swap    d4			;
	divu    #10,d4                  ;divide lower 16 bits
	move.w  d4,d3			;
	exg	d3,d4			;
	rts


;--------------------

LTSHexConvert:
	move.l	#8,d4			;8 characters

LTSHexLoop:
	rol.l	#4,d0			;prepare next nybble

	move.l	d0,d1			;spare
	andi.l	#$0000000F,d1		;the nybble

	move.l	#'0',d3			;ASCII base (for 0-9)

	cmpi.l	#9,d1			;normal or a-f
	ble	LTSHexDec

	move.l	d2,d3			;new base (A-F or a-f)
	subi.l	#$A,d1			;new value :-)

LTSHexDec:
	add.l	d1,d3			;add soup base, cover it and
	move.b	d3,(a0)+		;wait for 3 minutes :-)

	subq.l	#1,d4			;
	bne	LTSHexLoop

	move.b	#0,(a0)			;terminate
	suba.l	#1,a0			;
	movem.l	(sp)+,d2-d4		;give it back..
	move.l	#9,d0			;no way for 8 :-)
	rts

;--------------------


LTSBinConvert:
	move.l	#32,d4			;8 characters

LTSBinLoop:
	rol.l	#1,d0			;one bit

	move.l	d0,d1			;spare
	andi.l	#$00000001,d1		;the bit

	move.l	#'0',d3			;ASCII base

	add.l	d1,d3			;do it again
	move.b	d3,(a0)+		;

	subq.l	#1,d4			;
	bne	LTSBinLoop

	move.b	#0,(a0)			;terminate
	suba.l	#1,a0			;
	movem.l	(sp)+,d2-d4		;give it back..
	move.l	#33,d0			;am I sure of that?
	rts


**********************************************************************



**********************************************************************
*
*	AnyStrToLong - convert ASCII string to 32-bit value
*
* Input:  a0 - null terminated string
* Output: d0 - the value, or $FFFFFFFF if error
*         d1 - success (boolean)
*
*	As string you can pass decimal (no prefix), binary (prefix '%')
* or hex (prefixes '$' or '0x'). Check d1 for success or failure (fails
* when non-specific characters are found, or if null string).
*	In hex/bin mode, when you pass too many characters, only last
* 8/32 are used. In dec mode, maximal value is 4.294.967.295
* ($FFFFFFFF). Decimal values may be negative (prefix '-'), then the
* range is from -2.147.483.647 to 2.147.483.648 (otherwise the result
* is not reliable).
*
*	Alters only scratch registers (d0, d1, a0, a1). Uses 16 bytes
* of stack (decimal mode only).
*
*
*	© 1996 by Tadek Knapik (tadek@student.uci.agh.edu.pl).
*		 Public Domain. E-mail appreciated :-)
*
**********************************************************************



AnyStrToLong:
	cmpi.b	#0,(a0)			;null string?
	beq	AnyStrToLongError

	moveq	#0,d0			;negative flag in decimal mode

	cmpi.b	#'-',(a0)		;negative?
	beq	DecStrToLong0

	cmpi.b	#'%',(a0)		;binary?
	beq	BinStrToLong0		;yes!

	cmpi.b	#'$',(a0)		;hex
	beq	HexStrToLong0		;yes!

	cmpi.b	#'0',(a0)		;hex (0x)
	bne	DecStrToLong		;no!

	movea.l	a0,a1			;string pointer
	adda.l	#1,a1
	cmpi.b	#'x',(a1)		;'x'?
	bne	DecStrToLong		;

	adda.l	#2,a0			;omit '0x'
	bra	HexStrToLong


;--------------------

;convert hex to long.

HexStrToLong0:
	adda.l	#1,a0			;next byte (omit '$')

HexStrToLong:
	moveq	#0,d0
	moveq	#0,d1

HexNextNybble:
	cmpi.b	#0,(a0)			;the end?
	beq	AnyStrToLongEnd		;yes

;next character

	lsl.l	#4,d0			;prepare next 4 bits
	moveq	#0,d1			;clr
	move.b	(a0)+,d1		;next cipher

	cmpi.b	#'0',d1			;lower than 0?
	blt	AnyStrToLongError

	cmpi.b	#'f',d1			;higher than f?
	bgt	AnyStrToLongError

	subi.b	#'0',d1			;ASCII '0'
	bmi	AnyStrToLongError

;now we have 0-9. Or not..

	cmpi.b	#9,d1			;more than '9'?
	ble	HexReady		;no, we're done

	subi.b	#7,d1			;try this

;If A-F, we have 10-15, unless <, >, @ etc., or a-f

	cmpi.b	#10,d1			;less than 'A'?
	blt	AnyStrToLongError	;yes, jump @ Error

	cmpi.b	#15,d1			;more than 'F'
	ble	HexReady		;OK

;so, probably a-f

	subi.b	#32,d1			;case change?

	cmpi.b	#10,d1			;less?
	blt	AnyStrToLongError	;yes, probably XYZ

	cmpi.b	#15,d1			;more than 'f'
	ble	HexReady		;no, OK
	bra	AnyStrToLongError	;error, probably xyz

;in d1 we have value in range 0-15

HexReady:
	or.b	d1,d0			;set those bits
	bra	HexNextNybble		;next one, please


AnyStrToLongError:
	move.l	#-1,d0			;if -1 in d0, then 
	moveq	#0,d1			;d1 is boolean failure
	rts

AnyStrToLongEnd:
	moveq	#1,d1			;
	rts

;--------------------

;convert binary to long.

BinStrToLong0:
	adda.l	#1,a0			;next byte
BinStrToLong:
	cmpi.b	#0,(a0)			;nothing?
	beq	AnyStrToLongError

	moveq	#0,d0
	moveq	#0,d1

BinNextBit:
	cmpi.b	#0,(a0)			;coô jeszcze
	beq	AnyStrToLongEnd

;what do we have here..

	lsl.l	#1,d0			;prepare next bit

	moveq	#0,d1
	move.b	(a0)+,d1

	subi.b	#'0',d1			;
	bmi	AnyStrToLongError

	cmpi.b	#1,d1			;more than 1?
	bgt	AnyStrToLongError

;now we have 0 or 1 in d1.

	or.b	d1,d0			;to set or not to set
	bra	BinNextBit

;--------------------


;Convert decimal ASCII to 32 bit long.
;Maximum - 4.294.967.295 ($FFFFFFFF)
;If you pass in [x*4.294.967.295+y], it will probably return [y].


DecStrToLong0:
	adda.l	#1,a0			;next byte (omit '-')
	moveq	#1,d0

DecStrToLong:
	cmpi.b	#0,(a0)			;nic?
	beq	AnyStrToLongError
	movem.l	d2-d5,-(sp)
	move.l	d0,d5			;negative flag

	moveq	#0,d1			;clr
	moveq	#0,d0			;the value
	movea.l	a0,a1			;string
	adda.l	#1,a1			;cause I add immediately

;length of the string without last null character

DecStrLengthLoop:
	addq.l	#1,d1
	tst.b	(a1)+
	bne	DecStrLengthLoop	

;now in d1 we have the weight  of the first cipher plus 1

DecNextCipherLoop:
	subq.l	#1,d1			;sub 1

	tst.l	d1			;if null, this is the last one
	beq	DecLastCipher
	move.l	d1,d2

	moveq	#0,d3
	move.b	(a0)+,d3		;the cipher

	subi.b	#'0',d3			;
	bmi	DecStrToLongError	;

	cmpi.b	#9,d3			;
	bgt	DecStrToLongError


DecMultipleLoop:
	move.l	d3,d4			;copy it

	lsl.l	#3,d3			;*8
	lsl.l	#1,d4			;*2
	add.l	d4,d3			;x*2+x*8=x*(2+8)=x*10

	subq.l	#1,d2
	bne	DecMultipleLoop

	add.l	d3,d0			;
	bra	DecNextCipherLoop


DecLastCipher:
	moveq	#0,d3
	move.b	(a0)+,d3

	subi.b	#'0',d3			;
	bmi	DecStrToLongError	;

	cmpi.b	#9,d3			;
	bgt	DecStrToLongError

	add.l	d3,d0

DecStrToLongEnd:
	tst.l	d5				;was it negative?
	beq	DecStrToLongPositiveEnd		;
	neg.l	d0				;negate it

DecStrToLongPositiveEnd:
	movem.l	(sp)+,d2-d5
	bra	AnyStrToLongEnd

DecStrToLongError:
	movem.l	(sp)+,d2-d5
	bra	AnyStrToLongError

**********************************************************************


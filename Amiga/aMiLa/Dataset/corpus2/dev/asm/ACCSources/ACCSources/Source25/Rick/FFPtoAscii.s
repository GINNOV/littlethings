*************************************************************************
*			   FFPAscii ()					*
*************************************************************************
*  This is a routine to convert Motorola Fast Floating Point numbers    *
*   into a null-terminated ASCII string.  The maximum length of the	*
*       string is 16 characters, including the null terminator		*
*									*
* ON ENTRY : d0=number to convert					*
*	     a0=string buffer						*
* ON EXIT  : Registers preserved					*
*************************************************************************
*    Thanks go to the author of Amiga.lib - the place where I got the   *
*         method from, and I have used his table in the source		*
*************************************************************************


FFPZero	move.b	#'0',(a0)+
	bra	FFPEnd
FFPAscii:
	movem.l	d0-6/a0-1,-(sp)
	move.b	d0,d3		; Test exponent
	beq.s	FFPZero		; Number is 0:no need for full routine
	bpl.s	FFPMain		; If number is negtive...
	move.b	#'-',(a0)+	; Put negative sign at front
	and.b	#$7f,d3		; Make number positive (clear sign)
FFPMain	sub.b	#$40,d3		; Get real exponent
	ext.w	d3

; Find ffp value and exponent of first decimal digit

	moveq.b	#1,d1		; d1=decimal exponent
	lea	FFPTab(pc),a1	; a0=table of FFP values
FFPFind	cmp.w	(a1),d3		; Compare exponent with table's
	beq.s	FFPEqu		; Act accordingly
	blt.s	FFPMin
FFPPlus	subq.l	#6,a1		; Move up table for larger exponent
	addq.b	#1,d1		; Add 1 to decimal exponent
	cmp.w	(a1),d3		; Compare exponent
	bgt.s	FFPPlus		; Repeat if still too small
	beq.s	FFPEqu		; Found the right one!
	bra	FFPPrev		; This one's too big, use the last one
FFPMin	addq.l	#6,a1		; Move down table for smaller exponent
	subq.b	#1,d1		; Take 1 from decimal exponent
	cmp.w	(a1),d3		; Compare new exponent
	blt.s	FFPMin		; Repeat if still too big
	beq.s	FFPEqu		; Got the one we need
	bra	FFPMake
FFPEqu	cmp.l	2(a1),d0	; Make sure number bigger than 10Ed0
	bcc.s	FFPMake		; If so, generate number
FFPPrev	addq.l	#6,a1		; Move one entry down table
	subq.b	#1,d1		; Take 1 from decimal exponent

; We now know the exponent of 10 to start with, so make the number

FFPMake	moveq.l	#6,d5		; No. of significant figures (7 is max)
	clr.b	d2		; d2=Exponent flag (0=no exponent displayed)
	cmp.b	#8,d1		; If decimal exponent <-4 or >7 then
	bge.s	FFPExpo		; print in exponent form
	cmp.b	#-4,d1
	bge.s	FFPDec
FFPExpo	move.b	d1,d2		; d2=real decimal exponent
	move.b	#1,d1		; Print number as 0-10 E xx
FFPDec	tst.b	d1		; If exponent is negative, print decimal
	bpl	FFPGo		; place and 0s
	move.b	#'.',(a0)+
FFPDec1	addq.b	#1,d1		; Add 1 to exponent until reached 0
	beq	FFPGo1
	move.b	#'0',(a0)+	; And add a '0' each time we haven't
	bra	FFPDec1
FFPGo	bne.s	FFPGo1		; At first decimanl place?
	move.b	#'.',(a0)+	; Insert a decimal point
FFPGo1	move.w	d3,d4
	sub.w	(a1)+,d4	; d4=different in binary exponent between
	move.l	(a1)+,d6	; this power of 10 and the original number
	lsr.l	d4,d6		; Adjust mantissa accordingly
	beq	FFPEnd
	move.b	#48,d4		; Start at 0
FFPGo2	sub.l	d6,d0		; Subtract power of ten from number
	bcs.s	FFPGo3		; Overflow?
	addq.b	#1,d4		; No:Increase digit if possible
	bra	FFPGo2
FFPGo3	add.l	d6,d0		; Overflowed:add power of 10 back again
	move.b	d4,(a0)+	; Add number to string
	subq.b	#1,d1		; Subtract 1 from exponent
	dbra	d5,FFPGo	; Do other digits

; Remove trailing 0s

FFP0s	addq.b	#1,d1		; If positive exponent, leave alone
	bpl	FFPDExp		; otherwise 600 would become 6
	cmp.b	#'0',-(a0)	; If negative exponent, check for a 0
	beq	FFP0s		; Keep going back if found
	addq.l	#1,a0		; bump counter

; If an exponent is needed, this prints it

FFPDExp	tst.b	d2		; Exponent needed?
	beq	FFPEnd		; Nope
	move.b	#'E',(a0)+	; Put exponent indicator
	subq.b	#1,d2		; adjust exponent
	tst.b	d2		; if exponent is negative
	bpl	FFPExp2
	neg.b	d2		; Make it positive
	move.b	#'-',(a0)+	; And put a minus sign infront
FFPExp2	cmp.b	#10,d2		; Exponent>9?
	bcs	FFPExp3		; If so...
	move.b	#'1',(a0)+	; Print 1
	sub.b	#10,d2		; Subtract 10
FFPExp3	add.b	#48,d2		; Add ascii value of 0
	move.b	d2,(a0)+	; Add last digit of exponent
FFPEnd	clr.b	(a0)		; Null terminate string
	movem.l	(sp)+,d0-6/a0-1
	rts			; And go - phew!

*************************************************************************
*	  TABLE OF EXPONENTS/MANTISSAS FOR MULTIPLES OF 10		*
*************************************************************************

;	section	Gibberish,nowt

; Values for 1E18 to 10
	dc.l	$00408ac7,$2305003c,$de0b6b3a,$0039b1a2
	dc.l	$bc2f0036,$8e1bc9bf,$0032e35f,$a932002f
	dc.l	$b5e620f5,$002c9184,$e72a0028,$e8d4a510
	dc.l	$0025ba43,$b7400022,$9502f900,$001eee6b
	dc.l	$2800001b,$bebc2000,$00189896,$80000014
	dc.l	$f4240000,$0011c350,$0000000e,$9c400000
	dc.l	$000afa00,$00000007,$c8000000,$0004a000
	dc.w	0
;----------------------------------------------------------------------
FFPTab	dc.w	$0001		; Entry for 1
	dc.l	$80000000
;----------------------------------------------------------------------
	dc.l	$fffdcccc,$cccdfffa
	dc.l	$a3d70a3d,$fff78312,$6e98fff3,$d1b71759
	dc.l	$fff0a7c5,$ac47ffed,$8637bd06,$ffe9d6bf
	dc.l	$94d6ffe6,$abcc7712,$ffe38970,$5f41ffdf
	dc.l	$dbe6fecf,$ffdcafeb,$ff0cffd9,$8cbccc09
	dc.l	$ffd5e12e,$1342ffd2,$b424dc35,$ffcf901d
	dc.l	$7cf7ffcb,$e69694bf,$ffc8b877,$aa32ffc5
	dc.l	$9392ee8f,$ffc1ec1e,$4a7effbe,$bce50865
	dc.l	$ffbb971d,$a050ffb7,$f1c90001,$ffb4c16d
	dc.l	$9a01ffb1,$9abe14cd,$ffadf796,$87aeffaa
	dc.l	$c6120625,$ffa79e74,$d1b8ffa3,$fd87b5f3

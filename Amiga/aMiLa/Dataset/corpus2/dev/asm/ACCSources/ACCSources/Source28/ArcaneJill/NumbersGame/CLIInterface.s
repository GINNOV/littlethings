
	incdir	include
	include	earth/earth.i
	include	earth/earth_lib.i
	include	libraries/arpbase.i
	include	numbersgame.i

	XDEF	InputSeeds,InputTarget
	XDEF	PrintMethodNicely
	XDEF	ScanNumber

	XREF	_ArpBase
	XREF	_EarthBase
	XREF	SeedValues,NumSeeds

	XREF	CreateScheme,DeleteScheme
	XREF	CreateResult,DeleteResult
	XREF	CreateMethod,DeleteMethod

;-----------------------
; success = InputSeeds()
; d0

InputSeeds
ISRegs	reg	d2/a2-a3
	movem.l	ISRegs,-(sp)
	lea.l	-MaxInputBuf(sp),sp	Create input buffer on stack
	lea.l	SeedValues(_data),a3	a3 = address of seed array
;
; Give the user a prompt.
;
ISPrompt
	lea.l	M_SeedHail(pc),a0
	BSRARP	Printf			Ask user for seeds
;
; Input the seed values.
;
IsInput	move.l	#0,d2			d2 counts number of seeds
.loop	move.l	sp,a0
	BSRARP	ReadLine		Input number
	move.l	sp,a0
	bsr	ScanNumber		d0 = number
	bcs.b	.loop			Try again if invalid character
	tst.l	d0
	beq.b	ISTestNumSeeds		Zero counts as a terminator
	add.l	#1,d2			Count it
	cmp.l	#8,d2
	bhi.b	.loop
	move.l	d0,(a3)+		Store number in seed array
	bra.b	.loop			Loop back for next one
;
; Now see if the number of seeds was valid.
;
ISTestNumSeeds
	cmp.l	#2,d2
	bhs.b	.cont			Branch unless too few seeds
	lea.l	M_TooFew(pc),a0
	BSRARP	Printf			Warn the user
	bra.b	ISFail

.cont	cmp.l	#8,d2
	bls.b	ISPass			Branch unless too many seeds
	lea.l	M_TooMany(pc),a0
	BSRARP	Printf			Warn the user
	bra.b	ISFail
;
; Finally, construct an array to hold the seed values.
;
ISPass	move.l	d2,NumSeeds(_data)
	move.l	d2,d0
	bra.b	ISExit
;
; All done. Tidy up and exit.
; We deal with the failure case here.
;
ISFail	move.l	#0,d0
	move.l	d0,NumSeeds(_data)

ISExit	lea.l	MaxInputBuf(sp),sp	Restore the stack
	movem.l	(sp)+,ISRegs
	rts

;-----------------------
; target = InputTarget()
; d0

InputTarget
ITRegs	reg	d2/a2
	movem.l	ITRegs,-(sp)
	lea.l	SeedValues(_data),a2
	move.l	NumSeeds(_data),d2
;
; Print a meaningful prompt message.
;
ITPrompt
	lea.l	M_TargetHail1(pc),a0
	BSRARP	Printf			Print the start of the prompt
	bra.b	.next
.loop	move.b	#' ',d0
	bsr	PutChar
	move.l	(a2)+,d0
	bsr	PrintValue		Print each seed value
.next	dbra	d2,.loop
	lea.l	M_TargetHail2(pc),a0
	BSRARP	Printf			Print the end of the prompt
;
; Input the target value.
;
	lea.l	-MaxInputBuf(sp),sp	Create input buffer on stack
	move.l	sp,a0
	BSRARP	ReadLine		Input the target
	move.l	sp,a0
	bsr.b	ScanNumber		Convert to decimal
	bcs.b	ITPrompt		Loop back if illegal
	lea.l	MaxInputBuf(sp),sp
	movem.l	(sp)+,ITRegs
	rts

;----------------------------
; number = ScanNumber(buffer)
; d0                  a0
;
; In the event of an error (ie. an invalid character or an overflow)
; a suitable error message will be printed, and we return with the
; carry flag set.
;
; If all went well we return with carry flag reset.

ScanNumber
	move.l	#0,d0
	move.l	#0,d1
.loop	move.b	(a0)+,d1		Get next character
	beq.b	SCExit			Exit if finished
	cmp.b	#' ',d1
	beq.b	SCExit
	sub.b	#'0',d1
	blo.b	SCInvChar		Branch if invalid character
	cmp.b	#9,d1
	bhi.b	SCInvChar		Branch if invalid character
	mulu	#10,d0
	add.l	d1,d0
	cmp.w	#MAX_LEGAL_VALUE,d0
	bls.b	.loop			Loop back for next character

SCOverflow
	lea.l	M_Overflow(pc),a0
	bra.b	SCError
SCInvChar
	lea.l	M_InvChar(pc),a0
SCError	BSRARP	Printf			Print error message
	ori.b	#1,ccr			Set the carry flag
SCExit	rts

;---------------------------------
; PrintMethodNicely(method,target)
;                   a0     d0
;
; Same as PrintMethod(), but with some explanatory text also.

PrintMethodNicely
PMNRegs	reg	a2
	movem.l	PMNRegs,-(sp)
	move.l	a0,a2			a2 = method
	move.w	mth_Value(a0),d1
	cmp.w	d0,d1
	bne.b	.approx			Branch unless exact match

	lea.l	M_Success(pc),a0
	bra.b	.print

.approx	lea.l	M_Failure(pc),a0
.print	BSRARP	Printf			Print appropriate message
	move.l	a2,a0
	bsr.b	PrintMethod		Print the method itself
	movem.l	(sp)+,PMNRegs
	rts

;--------------------
; PrintMethod(method)
;             a0
;
; This function prints a method (to standard output)
; in a human-readable form.
;
; Note that this routine is recursive.

PrintMethod
PMRegs	reg	a2
	movem.l	PMRegs,-(sp)
	move.l	a0,a2			a2 = method

	tst.b	mth_Type(a2)
	beq.b	PMExit			Branch if this is a seed

	move.l	mth_Parent1(a2),a0
	bsr.b	PrintMethod		Print method for left parent
	move.l	mth_Parent2(a2),a0
	bsr.b	PrintMethod		Print method for right parent

	move.l	mth_Parent1(a2),a0
	move.w	mth_Value(a0),d0	d0 = left value
	bsr.b	PrintValue		Print this value
	move.l	#' ',d0
	bsr.b	PutChar			Print a space
	move.b	mth_Type(a2),d0
	bsr.b	PutChar			Print the operator
	move.l	#' ',d0
	bsr.b	PutChar			Print a space
	move.l	mth_Parent2(a2),a0
	move.w	mth_Value(a0),d0	d0 = right value
	bsr.b	PrintValue
	lea.l	M_Equals(pc),a0
	BSRARP	Printf			Print an equals sign
	move.w	mth_Value(a2),d0
	bsr.b	PrintValue		Print total value
	move.l	#$A,d0
	bsr.b	PutChar			Print a newline

PMExit	movem.l	(sp)+,PMRegs
	rts

;--------------
; PutChar(char)
;         d0
;
; Print a single character to standard output.

PutChar	clr.l	-(sp)
	move.b	d0,3(sp)		Stick character on stack
	lea.l	M_Character(pc),a0
	move.l	sp,a1
	BSRARP	Printf			Printf("%c",character);
	add.l	#4,sp
	rts

;------------------
; PrintValue(value)
;            d0
;
; Print a decimal number to standard output.

PrintValue
	ext.l	d0
	move.l	d0,-(sp)		Stick number on stack
	lea.l	M_Number(pc),a0
	move.l	sp,a1
	BSRARP	Printf			Printf("%d",number);
	add.l	#4,sp
	rts

;=========
; Strings

M_SeedHail	dc.b	$A,"Please input starting values",$A
		dc.b	"Enter each value followed by newline",$A
		dc.b	"When finished, press newline again",$A,0
M_TargetHail1	dc.b	"Please enter target value (for seeds",0
M_TargetHail2	dc.b	") : ",0
M_TooFew	dc.b	"Too few seeds (minimum is 2)",$A,0
M_TooMany	dc.b	"Too many seeds (maximum is 8)",$A,0
M_InvChar	dc.b	"Invalid character in number - please try again",$A,0
M_Overflow	dc.b	"Number too big - please try again",$A,0
M_Success	dc.b	"Success!",$A,0
M_Failure	dc.b	"Can't do that one. Best I can manage is:",$A,0
M_Character	dc.b	"%lc",0
M_Number	dc.b	"%ld",0
M_Equals	dc.b	" = ",0

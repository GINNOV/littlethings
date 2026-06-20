*
*
*	Doc-Protext V1.0 -- This program will produce a value from an
*	ASCII file which you can use to protect your doc files with!
*
*	See documentation for more information

	SECTION	DOC-Protect,CODE
	OPT	C-

**********

	INCDIR	SYS:INCLUDE/
	INCLUDE	EXEC/EXEC_LIB.I
	INCLUDE	EXEC/EXEC.I
	INCLUDE	LIBRARIES/DOS_LIB.I
	INCLUDE	MISC/POWERPACKER_LIB.I
	INCLUDE	MISC/PPBASE.I

**********

CALLSYS	MACRO
	JSR	_LVO\1(A6)
	ENDM

**********

Start	movem.l	a0/d0,-(sp)		Save 'em on stack
	lea	PPname,a1
	moveq.l	#0,d0
	move.l	$4,a6
	CALLSYS	OpenLibrary
	move.l	d0,Powerbase
	beq	QExit

**********

Main	movem.l	(sp)+,a0/d0		Restore 'em
	cmpi.l	#1,d0			Just a CR?
;	beq.s	Usage-Text
	beq	Quit

	move.l	a0,-(sp)		Save A0
.Loop	cmpi.b	#$0a,(a0)		CR?
	beq.s	.GotIt
	adda.l	#1,a0
	bra.s	.Loop

.GotIt	move.b	#0,(a0)			name must be null terminated
	move.l	(sp)+,a0		A0 = Filename
	
.OK	MOVE.L	#DECR_POINTER,D0	FLASH POINTER
	MOVE.L	#MEMF_PUBLIC,D1		ANY MEMORY
	LEA	FileBuffer,A1		ADDRESS OF POINTER
	LEA	FileLength,A2		ADDRESS OF POINTER
	MOVE.L	#0,A3			NOTHING SPECIAL!

	MOVE.L	Powerbase,A6
	CALLSYS	ppLoadData		READ FILE

	TST.L	D0
	bne	Quit			Loading Problems!


.OK2	move.l	FileBuffer,a0
	move.l	FileLength,d1

**********

*	Generate DPval-Routine		Entry: A0 = Start of ASCII text
*					       D1 = Length of Text

*					Exit:  D0 = DP-Value

GetDpVal
	moveq.l	#0,d0
	subi.l	#1,d1			Correct d1 for dbra Loop
.Loop	add.b	(a0)+,d0		Total all the bytes
	dbra	d1,.Loop
	rol.l	#7,d0			Make the number a bit 'nicer'!!!
	rol.w	#3,d0
	not.l	d0
	ror.l	#3,d0
	rol.w	#6,d0
	not.w	d0
	swap	d0
	eori.l	#$3a5d74f2,d0
	move.l	d0,d1
	rol.l	#5,d1
	eor	d1,d0
*		     \
*		      D0 now contains DP-value

**********

	lea	PrintBuffer,a0
	move.l	d0,d1			Store value
	move.l	#7,d2			8 Loops

.Loop3	andi.b	#$0f,d0			Mask all but low 4 bits.
	cmpi.b	#$a,d0			less $a = numerical
	blt.s	.Numb

.Lett	addi.b	#$37,d0			Offset for alphabet ASCII characters
	bra.s	.Cont			Skip next bit

.Numb	addi.b	#$30,d0			Generate ASCII character

.Cont	move.b	d0,0(a0,d2.l)		Addr reg. indirect+disp+index!
	ror.l	#4,d1			Rotate bits
	move.l	d1,d0
	dbra	d2,.Loop3

	lea	Dosname,a1
	moveq.l	#0,d0
	move.l	$4,a6
	CALLSYS	OpenLibrary

	move.l	d0,a6
	beq.s	Quit
	CALLSYS	Output			Get CLI ouput handle
	move.l	d0,d1
	move.l	#PrintText,d2
	move.l	#PrintTextLen,d3	Length of String

	CALLSYS	Write			Print it

**********

	move.l	a6,a1
	move.l	$4,a6
	CALLSYS	CloseLibrary		Close DOS

**********

Quit	tst.l	FileBuffer		File Loaded
	beq.s	.Cont			Don't free mem then
	move.l	FileBuffer,a1
	move.l	FileLength,d0	
	move.l	$4,a6
	CALLSYS	FreeMem

.Cont	move.l	Powerbase,a1
	CALLSYS	CloseLibrary
	move.l	#0,d0			NO CLI ERROR MESSAGE

QExit	rts				BYE!!!

**********

PPname	dc.b	'powerpacker.library',0
	even

DOSname	dc.b	'dos.library',0
	even

Powerbase	dc.l	0

FileBuffer	dc.l	0
FileLength	dc.l	0

PrintText	dc.b	'The DP-Value for your file is: '
PrintBuffer	dcb.b	8,0		place to store value
		dc.b	$a		Just a 'CR'
PrintTextLen	equ	*-PrintText

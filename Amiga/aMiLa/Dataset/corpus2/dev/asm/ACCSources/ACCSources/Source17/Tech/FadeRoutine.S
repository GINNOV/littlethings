*
*	FadeRoutine - ©1991 By Neil Johnston - This source is P.D.
*
*	Hi folks! This is the first bit of source I've done for a
*	while, pretty simple, but quite useful (maybe!) Feel free
*	to use and abuse, as you wish!

	Section	FadeRoutine,code_c		Chip mem

**********

	incdir	sys:include/
	include	hardware/custom.i
	include	exec/exec_lib.i

**********

CALLSYS	MACRO				BASIC CALLSYS MACRO
	JSR	_LVO\1(A6)
	ENDM

**********

Start	move.l	A7,STPoint		Save stack pointer
	movem.l	a0-a6/d0-d7,-(a7)	Save all registers
	move.l	#$dff000,a5		A5 used as HW offset reg.
	move.l	$4,a6
	CALLSYS	Forbid
	lea	GFXname(pc),a1
	moveq.l	#0,D0
	CALLSYS	OpenLibrary		Open GFX Lib
	move.l	d0,GFXbase
	move.w	dmaconr(a5),DMASave	Save Dma settings

.Wait	cmpi.b	#255,$dff006
	bne.s	.Wait

	move.w	#$7fff,dmacon(a5)	All DMA off
	move.l	#NewCop,cop1lc(a5)	New copper in...
	move.l	copjmp1(a5),d0		...And strobe it
	move.w	#%1000001110000000,dmacon(a5)

**********

Main	move.l	#Pic,d0
	move.w	d0,PL1L
	swap	d0
	move.w	d0,PL1H
	swap	d0
	add.l	#10240,d0
	move.w	d0,PL2L
	swap	d0
	move.w	d0,PL2H
	swap	d0
	add.l	#10240,d0
	move.w	d0,PL3L
	swap	d0
	move.w	d0,PL3H

*	This is all that's required to set up a fade in/out!:

	move.l	#8,d0			8 colours
	move.l	#10,d1			'Speed' of 15
	move.l	#1,d2			Want to fade a pic 'IN'
	move.l	#Cols,a0		Starting addr. of cols. in CList.
	move.l	#Table,a1		Addr. of final GFX colours

	bsr	Fade			Start fading!

.Loop2	cmpi.b	#255,$dff006
	bne.s	.Loop2			Wait for 1 frame

	cmpi.l	#0,d0			Was the fade completed last time?
	beq.s	.Loop			Yes it was!

	bsr	Fade			Fade it a little more

	bra.s	.Loop2			Keep on rollin'...

.Loop	btst	#6,$bfe001		Test for LMB
	bne.s	.Loop

	move.l	#8,d0			8 colours
	move.l	#10,d1			'Speed' of 15
	move.l	#0,d2			Want to fade a pic 'OUT'
	move.l	#Cols,a0		Starting addr. of cols. in CList.
	move.l	#Table2,a1		Addr. of block to hold faded cols

	bsr	Fade			Start fading!

.Loop3	cmpi.b	#255,$dff006
	bne.s	.Loop3			Wait for 1 frame

	cmpi.l	#0,d0			Was the fade completed last time?
	beq.s	.Exit			Yes it was!

	bsr	Fade			Fade it a little more

	bra.s	.Loop3			Keep on rollin'...

.Exit	bra	QUIT			Erm,

**********************************************************************

* FadeRoutine:

*	Call by 'BSR FADE' once each frame, until result from d0 = '0'

*	On entry:	d0 : Number of colours to fade
*			d1 : Speed Of Fading
*			d2 : '0' = Fade colours out, '1' = Fade colours in
*			a0 : Start address of colours (in copperlist)
*			a1 : Pointer to colours to fade in or blank table
*			     for old colour values

*	On exit:	d0 : '0' = All fading finished, '1' = Fading not 
*			     yet finished

Fade	cmpi.b	#1,FadeStarted		Was fade started earlier?
	bne.s	PrepFade		No? Then initialise certain things

DoFade	cmp.l	#0,FadeSpeed		Do we want a slow fade?
	beq.s	.Cont			Fade this time round
	sub.l	#1,FadeSpeed		Decrement delay
	move.l	#1,d0			Fade not yet finished
	rts

.Cont	move.l	FadeSpeed2,FadeSpeed	Restore fade delay
	cmp.b	#0,FadeInOut		Want to fade screen out?
	beq.s	InitFadeOut		Fade screen out then
	bra	InitFadeIn		Otherwise fade screen in

**********

FadeCompleted
	cmpi.b	#1,FadeDone		Were any colours faded?
	bne.s	.Yes			Yes they were!
	move.l	#0,d0			All fading done!
	move.b	#0,FadeStarted		Ready for next time!
	bra.s	.Cont			Skip next two lines
.Yes	move.l	#1,d0			Fading not yet finished

.Cont	rts				Need I say more?

**********

PrepFade
	move.b	#1,FadeStarted		So we know we've init'ed stuff
	move.l	d0,NoCols		Store number of colours
	move.l	d1,FadeSpeed		Store speed of fade
	move.l	d1,FadeSpeed2		Store speed of fade
	move.b	d2,FadeInOut		Store type of fade
	move.l	a0,ColStore		Store location of colours
	move.l	a1,ColTable		Store location of colour table

	cmpi.l	#0,d2			Want to fade screen out?
	bne	DoFade			Get ready to fade

**********	This stores the original colour values in a table

PrepFadeOut
	addq.l	#2,a0			Make a0 point to actual colours
	subq.l	#1,d0			Correct d0 for dbra loop
.Loop	move.w	(a0),(a1)+		Copy colours into a table
	addq.l	#4,a0			Point a0 to next colour
	dbra	d0,.Loop		Do all colours
	bra	DoFade			Get ready to fade

InitFadeOut
	move.l	ColStore,a0		Address of colours (in CopList)
	move.l	NoCols,d2		Number of colours to fade
	subq.l	#1,d2			Correct d2 for dbra loop
	move.b	#1,FadeDone		To test if the fade has finished

DoFadeOut
	moveq.l	#0,d0			Clear d0
	move.w	2(a0),d0		Get actual colour

**********	Fade blue component out:

	move.l	d0,d1			Store colour in d1
	andi.w	#$000f,d0		Mask all but blue component
	cmpi.w	#0,d0			Is blue '0'?
	bne.s	.Cont			No
	move.l	d1,d0			Restore original colour
	bra.s	.Cont1			Skip 'Fade Blue' section

.Cont	subi.b	#1,d0			Subtract 1 from blue component
	move.b	#0,FadeDone		Colour fading not yet finished
	andi.w	#$fff0,d1		Kill original blue component
	or.w	d1,d0			Insert new blue colour

**********	Fade green component out:

.Cont1	move.l	d0,d1			Store colour in d1
	andi.w	#$00f0,d0		Mask all but green component
	ror.w	#4,d0			Rotate to get green into LSB
	cmpi.w	#0,d0			Is green '0'?
	bne.s	.Cont2			No
	move.l	d1,d0			Restore original colour
	bra.s	.Cont3			Skip 'Fade Green' section

.Cont2	subi.b	#1,d0			Subtract 1 from green component
	move.b	#0,FadeDone		Colour fading not yet finished
	andi.w	#$ff0f,d1		Kill original green component
	rol.w	#4,d0			Restore green's correct position
	or.w	d1,d0			Insert new green colour

**********	Fade red component out:

.Cont3	move.l	d0,d1			Store colour in d1
	andi.w	#$0f00,d0		Mask all but red component
	ror.w	#8,d0			Rotate to get red into LSB
	cmpi.w	#0,d0			Is red '0'?
	bne.s	.Cont4			No
	move.l	d1,d0			Restore original colour
	bra.s	.Cont5			Skip 'Fade Red' section

.Cont4	subi.b	#1,d0			Subtract 1 from red component
	move.b	#0,FadeDone		Colour fading not yet finished
	andi.w	#$f0ff,d1		Kill original red component
	rol.w	#8,d0			Restore red's correct position
	or.w	d1,d0			Insert new red colour

**********	D0 now contains correct (faded) colour

.Cont5	move.w	d0,2(a0)		Insert new colour in CopList
	addq.l	#4,a0			Point a0 to next colour
	dbra	d2,DoFadeOut		Next colour, please!

AllDone	bra	FadeCompleted		That's all for now!

**********	Fade new colours in

InitFadeIn
	movem.l	d3-d4,-(sp)		Better save d3/d4!
	move.l	ColStore,a0		Address of colours (in CopList)
	move.l	ColTable,a1		Address of colours (in table)
	move.l	NoCols,d2		Number of colours to fade
	subq.l	#1,d2			Correct d2 for dbra loop
	move.b	#1,FadeDone		To test if the fade has finished

DoFadeIn
	moveq.l	#0,d0			Clear d0
	move.l	d0,d3			Clear d3
	move.w	2(a0),d0		Get actual colour
	move.w	(a1)+,d3		Get required colour

**********	Fade blue component in:

	move.l	d0,d1			Store colour in d1
	move.l	d3,d4			Store colour in d4
	andi.w	#$000f,d0		Mask all but blue component
	andi.w	#$000f,d3		Mask all but blue component
	cmp.w	d3,d0			Is blue correct?
	bne.s	.Cont			No
	move.l	d1,d0			Restore original colour
	move.l	d4,d3			Restore original colour
	bra.s	.Cont1			Skip 'Fade Blue' section

.Cont	addq.b	#1,d0			Add 1 to blue component
	move.b	#0,FadeDone		Colour fading not yet finished
	andi.w	#$fff0,d1		Kill original blue component
	or.w	d1,d0			Insert new blue colour
	move.l	d4,d3			Restore original colour

**********	Fade green component in:

.Cont1	move.l	d0,d1			Store colour in d1
	move.l	d3,d4			Store colour in d4
	andi.w	#$00f0,d0		Mask all but green component
	andi.w	#$00f0,d3		Mask all but green component
	cmp.w	d3,d0			Is green correct?
	bne.s	.Cont2			No
	move.l	d1,d0			Restore original colour
	move.l	d4,d3			Restore original colour
	bra.s	.Cont3			Skip 'Fade Green' section

.Cont2	ror.w	#4,d0			Move green into LSB
	addq.b	#1,d0			Add 1 to green component
	rol.w	#4,d0			Correct green's position
	move.b	#0,FadeDone		Colour fading not yet finished
	andi.w	#$ff0f,d1		Kill original green component
	or.w	d1,d0			Insert new green colour
	move.l	d4,d3			Restore original colour

**********	Fade red component in:

.Cont3	move.l	d0,d1			Store colour in d1
	move.l	d3,d4			Store colour in d4
	andi.w	#$0f00,d0		Mask all but red component
	andi.w	#$0f00,d3		Mask all but red component
	cmp.w	d3,d0			Is red correct?
	bne.s	.Cont4			No
	move.l	d1,d0			Restore original colour
	move.l	d4,d3			Restore original colour
	bra.s	.Cont5			Skip 'Fade Red' section

.Cont4	ror.w	#8,d0			Move red into LSB
	addq.b	#1,d0			Add 1 to red component
	rol.w	#8,d0			Correct red's position
	move.b	#0,FadeDone		Colour fading not yet finished
	andi.w	#$f0ff,d1		Kill original red component
	or.w	d1,d0			Insert new red colour
	move.l	d4,d3			Restore original colour


**********	D0 now contains correct (faded) colour

.Cont5	move.w	d0,2(a0)		Insert new colour in CopList
	addq.l	#4,a0			Point a0 to next colour
	dbra	d2,DoFadeIn		Next colour, please!

AllDone2
	movem.l	(sp)+,d3-d4		Better save d3/d4!
	bra	FadeCompleted		That's all for now!

**********	ColourFade Variables:

NoCols		dc.l	0
FadeSpeed	dc.l	0
FadeSpeed2	dc.l	0
ColStore	dc.l	0
ColTable	dc.l	0
FadeInOut	dc.b	0
FadeStarted	dc.b	0
FadeDone	dc.b	0
		even

**********************************************************************

QUIT	move.w	DMASave,d7
	bset	#$f,d7
	move.w	d7,dmacon(a5)

	move.l	GFXbase,a0
	move.l	$26(a0),cop1lc(a5)	Replace system copper
	
	move.l	GFXbase,a1
	move.l	$4,a6
	CALLSYS	CloseLibrary		Close GFX Lib
	CALLSYS	Permit
	movem.l	(a7)+,a0-a6/d0-d7	
	move.l	STPoint,a7
	rts

**********

NewCop	DC.W	bplcon0,$3200		CHANGE 1ST DIGIT FOR 1-5 BPL
	DC.W	bplcon1,$0000
	DC.W	diwstrt,$2281		THIS IS ALL
	DC.W	diwstop,$22C1
	DC.W	ddfstrt,$0038		STANDARD SCREEN CRAP.
	DC.W	ddfstop,$00D0
	DC.W	bpl1mod,$0000		CHANGE IT TO
	DC.W	bpl2mod,$0000


Cols	dc.w	$0180,$0
	dc.w	$0182,$0
	dc.w	$0184,$0
	dc.w	$0186,$0
	dc.w	$0188,$0
	dc.w	$018A,$0
	dc.w	$018C,$0
	dc.w	$018E,$0


	DC.W	bplpt+$00		SET UP COPPER BPLANE POINTERS
PL1H	DC.W	0,bplpt+$02
PL1L	DC.W	0,bplpt+$04
PL2H	DC.W	0,bplpt+$06
PL2L	DC.W	0,bplpt+$08
PL3H	DC.W	0,bplpt+$0A
PL3L	DC.W	0

	DC.W	$FFFF,$FFFE		AND WAIT FOR THE IMPOSSIBLE!

**********				LABELS CRAP FOLLOWS...

GFXname		DC.B	'graphics.library'
		EVEN

GFXbase		DC.L	0
STPoint		DC.L	0
DMASave		DC.W	0

Pic	incbin	df1:bitmaps/acc-pic.raw

Table	dc.w	$0000
	dc.w	$0FFF
	dc.w	$0B00
	dc.w	$0080
	dc.w	$024C
	dc.w	$0EB0
	dc.w	$0B52
	dc.w	$0F0F


Table2	dcb.w	8,0			Colours will be stored in here

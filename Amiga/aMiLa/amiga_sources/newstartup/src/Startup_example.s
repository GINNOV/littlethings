*******************************************************************************
*									      *
*	Startup example for "Startup.asm" version 3.9			      *
*									      *
*	© 1995,1996 Kenneth C. Nilsen					      *
*									      *
*	Please read bottom line!					      *
*									      *
*******************************************************************************

StartSkip	=	0		;0=WB/CLI, 1=CLI only (eg. from AsmOne)

Processor	=	68020		;0/680x0/0x0 (= 0 is faster than 68000)
MathProc	=	68881		;FPU: 0(none)/6888x/88x/68040/68060

* You must activate these to have the CPU and Math check:

;CpuCheck	SET	1		;activate CPU check routine
;MathCheck	SET	1		;activate MATH check routine

* Activate this label to see the differences with DebugDump etc.:

;DODUMP		SET	1		;activcate DebugDump/Init routines

	incdir	inc:			;your include dir
	include	Startup.asm		;our file
*------------------------------------------------------------------------------
*## here is our init section (Init: label and DefLib macro are required)
*------------------------------------------------------------------------------

	dc.b	"$VER: Example 3.9 (06.10.96)",0
	even

Init:	InitDebugHandler	"CON:0/20/640/160/Debug Dump/WAIT/CLOSE"

;AsmOne:
		TaskName "Startup test 1.0"	;set our task name
;Devpac/BarFly	TaskName "<Startup test 1.0>"

	TaskPri	1			;set task pri

	DefLib	intuition,0		;open intuition.library ver. 0
	DefLib	dos,37			;open dos.library ver. 37
	DefEnd				;ALWAYS REQUIRED!!!

*------------------------------------------------------------------------------
;## our main example code comes from here (Start: label is required!)
*------------------------------------------------------------------------------

;The InitDebugHandler macro will only be assembled if DODUMP is active. The
;same thing with the DebugDump macro!

Start:	InitDebugHandler	"CON:0/20/640/160/Debug Output/WAIT/CLOSE"

;If DebugDump gets an error while assembling then please try to do this:
;	DebugDump	"<Program start!>",0   ; <- DevPac/BarFly

	DebugDump	"Program start!",0

	LibBase	dos			;use dos.library base

	DebugDump	"Try to get default output handler",1

	jsr	-60(a6)			;Output()
	move.l	d0,d1			;copy handler
	beq.b	noOut			;null? then skip

	move.l	#Text,d2		;pointer to our text
	move.l	#TextL,d3		;length of text

	DebugDump	"Write a text to Default IO:",2

	jsr	-48(a6)			;Write() (to handler)

*------------------------------------------------------------------------------
;## if we started from Wb then blink (just to differ a little)
*------------------------------------------------------------------------------

noOut	DebugDump	"Check where we started from...",3

	StartFrom			;a macro which tells you where the prg.
	beq.w	CLI			;started from. (=0 cli / <>0 wb)

WB	DebugDump	"From WB...",4

	LibBase	intuition		;use "LibBase" to get library bases

*------------------------------------------------------------------------------
;## now intuition.library base is put into A6 and we can start using it:
*------------------------------------------------------------------------------

	move.l	60(a6),a0		;frontmost screen (hehe, wonder how?)

	DebugDump	"Call DisplayBeep()...",5

	jsr	-96(a6)			;DisplayBeep(), blink the screen

	TaskPointer			;get pointer to this task in d0.
					;use it what you want :)
*------------------------------------------------------------------------------
;here we demostrade the argument parsing. You get one seperate argument by
;each time you use the "NextArg" macro. Pointer to argument [0] in d0 or NULL:
*------------------------------------------------------------------------------

CLI	DebugDump	"From CLI...",6

	NextArg				;macro which gives us the pointer to
	beq.w	Exit			;our arg. in D0 (or NULL in D0)
					;Branch EQual if end of args.
	move.l	d0,d2			;we store pointer to buffer in D2

*------------------------------------------------------------------------------
;## print arguments to default output (in cli) to see some actions:
*------------------------------------------------------------------------------

	LibBase	dos			;internal macro (dosbase in a6)

	DebugDump	"Print argument...",7

	jsr	-60(a6)			;Output()
	move.l	d0,d1			;handler
	beq.b	Exit			;no handler? then exit printing

	moveq	#0,d3			;length
	move.l	d2,a0			;copy buffer address to a0
.count	move.b	(a0)+,d0		;get one byte from buffer
	beq.b	.gotLen			;found null, exit loop
	addq	#1,d3			;add one to length in D3
	bra.b	.count			;count some more...

.gotLen	jsr	-48(a6)			;Write(), print argument in cli

	jsr	-60(a6)			;Output()
	move.l	d0,d1			;output handler in D1
	move.l	#Text,d2		;pointer to text/linefeed
	moveq	#1,d3			;length
	jsr	-48(a6)			;Write(), print linefeed in cli

	bra.w	CLI			;repeat until no args are left

Exit	Return	0			;return code and bye bye!

*-----------------------------------------------------------------------------*
;## Our data section for this example source:
*-----------------------------------------------------------------------------*

Text	dc.b	10,'Startup.asm example 3.9',10
	dc.b	'Give some arguments to test the NextArg macro:',10,10
TextL	=*-Text

*-----------------------------------------------------------------------------*
*######	BOTTOM LINE
*-----------------------------------------------------------------------------*
;	Remember that supporting Workbench startup will make more people happy!
;	And by using this startup code you have easy support for that AND extra
;	features like reading arguments very easy, dump debug info, protect
;	your machine from crashing if you have lower processor or mathprocessor
;	than required and much more.
;
;	The assembled startup code is itself only about 1Kb (!) including
;	CPU and MATH check (if not CPU/Math check the header will be less than
;	1 Kb) and that's worth making your programs safe and programming more
;	powerful!
;
;	Feel free to contact me if any problems occure or if you want features
;	included. If you change the Startup.asm source it would be nice to see
;	what you have done :)
;
;	New addresses:
;
;	E-mail: kennecni@idgOnline.no
;		kenneth@norconnect.no (soon obsolete)
;
;	Digital Surface
;	Kenneth Nilsen
;	Briskåsen 1
;	N-3535 Krøderen
;	Norway
*-----------------------------------------------------------------------------*

*
*
*	TECH-MENU V1.00 -- COMMENCED: 17/05/91
*	
*	Important: Please don't assemble and run from memory in GenAm
*	as it often crashes afterwards, but doesn't from CLI!

	Section	Techmenu,code_c		Chip mem

**********

	incdir	sys:include/
	include	hardware/custom.i
	include	exec/exec_lib.i
	include	misc/arpbase.i

**********

CALLSYS	MACRO				BASIC CALLSYS MACRO
	JSR	_LVO\1(A6)
	ENDM

**********

Start	movem.l	a0-a6/d0-d7,-(a7)	Save all registers
	move.l	A7,STPoint		Save stack pointer
	
ReStart	move.l	#$dff000,a5		A5 used as HW offset reg.
	move.l	$4,a6

	lea	ARPname(pc),a1
	moveq.l	#0,D0
	CALLSYS	OpenLibrary		Open GFX Lib
	move.l	d0,ARPbase

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
	move.w	#%1000001111000000,dmacon(a5)

	move.l	#ColTab,ColPtr

	jsr	SetUpScroll

	move.l	$6c,OldInt+2
	move.l	#NewInt,$6c

**********

Main	move.l	#MenuGFX,d0		Gfx On
	move.w	d0,PL1L
	swap	d0
	move.w	d0,PL1H
	swap	d0
	addi.l	#20480,d0
	move.w	d0,PL2L
	swap	d0
	move.w	d0,PL2H

*********

PrintTitle
	lea	TitleText,a0
	lea	HeaderFont,a1
	lea	MenuGFX,a2
	adda.l	#4*80,a2		4 lines down

	bsr	GetLength
	add.l	d0,a2			D0 has correct offset for centre
	
	bsr	PrintText		Print Title bar

**********

PrintItems
	lea	ProgramText,a0
	
	lea	TextFont,a1
	lea	MenuGFX,a2
	moveq.l	#0,d1			D1 = Current entry number
	move.l	#18*80,d0		Start of 1st gadget
	adda.l	#1,a2			Indent text start slightly
	add.l	d0,a2			A2 = where to start printing
	move.l	a2,d2			Save initial position for later

ItemLoop
	bsr	PrintText

	cmpi.b	#$ff,(a0)		End of list?
	beq.s	EndOfItems		End if so

	addi.l	#1,d1

	cmpi.b	#13,d1			End of 1st column?
	beq.s	EndOfColumn
	cmpi.b	#26,d1			End of 2nd column?
	beq.s	EndOfColumn
	cmpi.b	#39,d1			End of Last column?
	beq.s	EndOfItems

	adda.l	#14*80,a2		A2 now points to next gadget
	bra.s	ItemLoop

**********

EndOfColumn
	addi.l	#26,d2
	move.l	d2,a2			Restore d7

	bra.s	ItemLoop

**********

EndOfItems
	move.l	#0,CrntItem		Reset 'Current Item' pointer

**********

	lea	TechText,a0
	lea	ScrollFont,a1
	lea	MenuGFX,a2
	adda.l	#80*200+70,a2

	bsr	PrintText		Print the little "Tech '91" Logo

	bsr	Select

**********

CheckMouse
	moveq.l	#0,d0
	move.w	$dff00a,d0		Mouse input
	andi.b	#$00,d0
	ror.w	#8,d0			Want Vertical component

	move.l	d0,d2			Save value

.Loop	btst	#6,$bfe001
	beq	RunProgram		Execute the selection

	move.w	$dff00a,d0		Mouse input
	andi.b	#$00,d0
	ror.w	#8,d0			Wany Vertical component

	cmp.w	d0,d2
	bne.s	Moved
	move.l	d0,d2
	bra.s	.Loop	

Moved	cmp.w	d0,d2
	blt.s	MouseDn

MouseUp	cmpi.w	#15,UpSens
	bge.s	.Cont
	addi.w	#1,UpSens
	bra	CheckMouse

.Cont	move.w	#0,UpSens
	cmpi.l	#0,CrntItem
	beq.s	CheckMouse
	bsr.s	Select
	subi.l	#1,CrntItem
	bsr.s	Select
	bra.s	CheckMouse

MouseDn	cmpi.w	#15,DnSens
	bge.s	.Cont
	addi.w	#1,DnSens
	bra	CheckMouse

.Cont	move.w	#0,DnSens
	cmpi.l	#38,CrntItem
	beq	CheckMouse
	bsr.s	Select
	addi.l	#1,CrntItem
	bsr.s	Select
	bra	CheckMouse

**********

Select	lea	MenuGFX,a0
	adda.l	#14*80,a0
	move.l	CrntItem,d0
	cmpi.l	#13,d0
	blt.s	SelCont
	cmpi.l	#26,d0
	blt.s	Col2Sel

Col3Sel	adda.l	#52,a0
	subi.l	#26,d0			Correct d0 for column
	bra.s	SelCont

Col2Sel	adda.l	#26,a0
	subi.l	#13,d0			Correct d0 for column

SelCont	mulu	#14,d0
	mulu	#80,d0
	adda.l	d0,a0

	move.l	a0,a1			Save a0
	move.l	#14,d7
	moveq.l	#0,d0

.Loop2	move.l	#25,d6

.Loop	move.b	(a0),d0
	not.b	d0
	move.b	d0,(a0)+
;	move.b	20480(a0),d0		Optional bit-Remove '+' from previous
;	not.b	d0			line though.
;	move.b	d0,20480(a0)
;	adda.l	#1,a0
	dbra	d6,.Loop
	move.l	a1,a0			Restore a0
	adda.l	#80,a0
	move.l	a0,a1
	dbra	d7,.Loop2

	rts

**********

RunProgram
	lea	Commands,a2
	move.l	CrntItem,d0
	tst.l	d0			Special case for Crnt=0
	beq.s	RunIt

	subi.l	#1,d0
.Loop	tst.b	(a2)+
	bne.s	.Loop
	dbra	d0,.Loop

RunIt	tst.b	(a2)
	beq	CheckMouse

	bsr	ShutDown		Shut down all

	move.l	STPoint,a7

	move.l	ARPbase,a6
	CALLSYS	Output
	move.l	d0,d1

	move.l	a2,a0			Command to SyncRun()
	move.l	#0,a1
	moveq.l	#0,d0

	move.l	a2,-(sp)
.Loop2	cmp.b	#1,(a2)			A '1' signifies an argument
	beq.s	.GotIt
	cmp.b	#0,(a2)
	beq.s	.Cont
	adda.l	#1,a2
	bra.s	.Loop2

.GotIt	move.b	#0,(a2)			A null for the end of main command
	lea	1(a2),a1		Start of argument

.Cont	move.l	(sp)+,a2		Restore pointer

	CALLSYS	SyncRun

	move.l	ARPbase,a1
	move.l	$4,a6
	CALLSYS	CloseLibrary		Close ARP

	movem.l	(a7)+,a0-a6/d0-d7	

Quit	rts				Au Revoir!


**********

*	PrintText. Entry : A0 = Pointer to Null terminated text string
*			   A1 = Pointer to font
*			   A2 = Place to start printing text

*		   Exit:   A0 = Points to position after end of string

**********

PrintText
	move.l	a2,-(sp)		A2 must be returned

.Loop	moveq.l	#0,d0
	move.b	(a0)+,d0
	tst.b	d0
	beq	.End

	move.l	a1,-(sp)
	subi.b	#32,d0
	mulu	#8,d0
	add.l	d0,a1

	move.l	a2,-(sp)
	move.l	#7,d7

.Loop2	move.b	(a1)+,(a2)
	move.b	(a2),20480(a2)		Write to 2nd Bpl as well
	adda.l	#80,a2
	dbra	d7,.Loop2

	move.l	(sp)+,a2
	adda.l	#1,a2
	move.l	(sp)+,a1		Restore font
	bra.s	.Loop

.End	
	move.l	(sp)+,a2		Restore a2
	rts

**********

GetLength
	move.l	a0,-(sp)
	moveq.l	#0,d0
.Loop	tst.b	(a0)+	
	beq.s	.GotIt
	addi.b	#1,d0
	bra.s	.Loop

.GotIt	move.l	(sp)+,a0
	move.l	#80,d1
	sub.l	d0,d1
	divu	#2,d1
	move.b	d1,d0
	rts	

**********

ShutDown
	move.l	OldInt+2,$6c		Restore Lvl3 Cop Interrupt
	move.w	DMASave,d7
	bset	#$f,d7
	move.w	d7,dmacon(a5)

	move.l	GFXbase,a0
	move.l	$26(a0),cop1lc(a5)	Replace system copper
	moveq.l	#0,d0
	move.l	GFXbase,a1
	move.l	$4,a6
	CALLSYS	CloseLibrary		Close GFX Lib
	CALLSYS	Permit
	rts

**********

NewInt
	movem.l	a0-a2/a5-a6/d0-d7,-(a7)	Save all registers

	jsr	DoScroll

	move.l	#0,a0
	move.l	ColPtr,a0
	cmpi.w	#$ffff,(a0)
	bne.s	.Cont
	move.l	#ColTab,a0
.Cont	
	move.w	(a0)+,TextCol
	move.l	a0,ColPtr

	movem.l	(a7)+,a0-a2/a5-a6/d0-d7	

OldInt	jmp	$0			Self modifying code -- Naughty!!

**********

NewCop	DC.W	bplcon0,$0200		CHANGE 1ST DIGIT FOR 1-5 BPL
	DC.W	bplcon1,$0000
	DC.W	diwstrt,$2281		THIS IS ALL
	DC.W	diwstop,$22C1
	DC.W	ddfstrt,$003c		STANDARD SCREEN CRAP.
	DC.W	ddfstop,$00D4
	DC.W	bpl1mod,$0000		CHANGE IT TO
	DC.W	bpl2mod,$0000

	dc.w	$3009,$fffe,bplcon0,$a200
	
	DC.W	bplpt+$00		SET UP COPPER BPLANE POINTERS
PL1H	DC.W	0,bplpt+$02
PL1L	DC.W	0,bplpt+$04
PL2H	DC.W	0,bplpt+$06
PL2L	DC.W	0,bplpt+$08
PL3H	DC.W	0,bplpt+$0A
PL3L	DC.W	0,bplpt+$0C
PL4H	DC.W	0,bplpt+$0E
PL4L	DC.W	0,bplpt+$10
PL5H	DC.W	0,bplpt+$12
PL5L	DC.W	0

	dc.w	$0180,$0324
	dc.w	$0182,$0fff
	dc.w	$0184
TextCol	dc.w	$0
	dc.w	$0186,$00F0

	dc.w	$3009,$fffe

*	This pretty complex list produces the double height/multi-colour
*	Header

	dc.w	$3109,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$3141,$fffe,$0186,$000f,$31d1,$fffe,$0186,$0fff

	dc.w	$3209,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$3241,$fffe,$0186,$000f,$32d1,$fffe,$0186,$0fff

	dc.w	$3309,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$3341,$fffe,$0186,$033f,$33d1,$fffe,$0186,$0fff

	dc.w	$3499,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$3441,$fffe,$0186,$033f,$34d1,$fffe,$0186,$0fff

	dc.w	$3509,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$3541,$fffe,$0186,$066f,$35d1,$fffe,$0186,$0fff

	dc.w	$3609,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$3641,$fffe,$0186,$066f,$36d1,$fffe,$0186,$0fff

	dc.w	$3709,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$3741,$fffe,$0186,$099f,$37d1,$fffe,$0186,$0fff

	dc.w	$3809,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$3841,$fffe,$0186,$099f,$38d1,$fffe,$0186,$0fff

	dc.w	$3909,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$3941,$fffe,$0186,$0ccf,$39d1,$fffe,$0186,$0fff

	dc.w	$3a09,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$3a41,$fffe,$0186,$0ccf,$3ad1,$fffe,$0186,$0fff

	dc.w	$3b09,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$3b41,$fffe,$0186,$0fff,$3bd1,$fffe,$0186,$0fff

	dc.w	$3c09,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$3c41,$fffe,$0186,$0fff,$3cd1,$fffe,$0186,$0fff

	dc.w	$3d09,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$3d41,$fffe,$0186,$0fff,$3dd1,$fffe,$0186,$0fff

	dc.w	$3e09,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$3e41,$fffe,$0186,$0fcc,$3ed1,$fffe,$0186,$0fff

	dc.w	$3f09,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$3f41,$fffe,$0186,$0fcc,$3fd1,$fffe,$0186,$0fff

	dc.w	$4009,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$4041,$fffe,$0186,$0f99,$40d1,$fffe,$0186,$0fff

	dc.w	$4109,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$4141,$fffe,$0186,$0f99,$41d1,$fffe,$0186,$0fff

	dc.w	$4209,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$4241,$fffe,$0186,$0f66,$42d1,$fffe,$0186,$0fff

	dc.w	$4309,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$4341,$fffe,$0186,$0f66,$43d1,$fffe,$0186,$0fff

	dc.w	$4409,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$4441,$fffe,$0186,$0f33,$44d1,$fffe,$0186,$0fff

	dc.w	$4509,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$4541,$fffe,$0186,$0f33,$45d1,$fffe,$0186,$0fff

	dc.w	$4609,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$4641,$fffe,$0186,$0f00,$46d1,$fffe,$0186,$0fff

	dc.w	$4709,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$4741,$fffe,$0186,$0f00,$47d1,$fffe,$0186,$0fff

	dc.w	$4809,$fffe,bpl1mod,0,bpl2mod,0
	dc.w	$4841,$fffe,$0186,$0fff,$48d1,$fffe,$0186,$0fff

	dc.w	$4909,$fffe,bpl1mod,-80,bpl2mod,-80
	dc.w	$4941,$fffe,$0186,$0fff,$49d1,$fffe,$0186,$0fff

	dc.w	$4a09,$fffe,bpl1mod,0,bpl2mod,0

	dc.w	$ffe1,$fffe
	dc.w	$1009,$fffe,bplcon0,$1200

	DC.W	ddfstrt,$0030		
	DC.W	ddfstop,$00D4
	DC.W	bpl1mod,$0004
	DC.W	bpl2mod,$0004
	DC.W	color+$02,$0FFF
	
	DC.W	bplpt+$00		SET UP COPPER BPLANE POINTERS
SCR1H	DC.W	0,bplpt+$02
SCR1L	DC.W	0

	dc.w	$1a09,$fffe,bplcon0,$0200

	DC.W	$FFFF,$FFFE		AND WAIT FOR THE IMPOSSIBLE!

**********				LABELS CRAP FOLLOWS...

GFXname		DC.B	'graphics.library',0
		EVEN

ARPname		DC.B	'arp.library',0
		EVEN

GFXbase		DC.L	0
ARPbase		DC.L	0
STPoint		DC.L	0
DMASave		DC.W	0
CrntItem	dc.l	0
UpSens		dc.w	0
DnSens		dc.w	0
Plop		dc.w	0

**********

MenuGFX	incbin	df1:GFX-Data/TechMenu.hires.raw

HeaderFont	incbin	df1:GFX-Data/hexfont.fnt
TextFont	incbin	df1:GFX-data/g'n'g.fnt
ScrollFont	incbin	df1:GFX-data/metallion.fnt04

**********

ColPtr	dc.l	0

ColTab	dc.w	$0000,$0010,$0020,$0030,$0040,$0050
	dc.w	$0060,$0070,$0080,$0090,$00a0,$00b0
	dc.w	$00c0,$00d0,$00e0,$00f0,$00f0,$00f0,$00f0,$00f0,$00e0,$00d0
	dc.w	$00c0,$00b0,$00a0,$0090,$0080,$0070
	dc.w	$0060,$0050,$0040,$0030,$0020,$0010
	dc.w	$0000,$0000,$0000,$0000,$ffff

**********

TitleText
	dc.b	'W E L C O M E   T O   T E C H M E N U   V 1 . 0 !',0
	EVEN

**********

*	This is the list of null terminated programs which appears

ProgramText
Prg1	DC.B	'Hello there!',0
Prg2	DC.B	0
Prg3	DC.B	'And welcome to:',0
Prg4	DC.B	0
Prg5	DC.B	'TechMenu V1.0!',0
Prg6	DC.B	0
Prg7	DC.B	'Coded By Neil Johnston',0
Prg8	DC.B	0
Prg9	DC.B	0
Prg10	DC.B	'Click On Me To Quit!',0
Prg11	DC.B	0
Prg12	DC.B	0
Prg13	DC.B	0
Prg14	DC.B	0
Prg15	DC.B	0
Prg16	DC.B	0
Prg17	DC.B	0
Prg18	DC.B	0
Prg19	DC.B	0
Prg20	DC.B	0
Prg21	DC.B	0
Prg22	DC.B	0
Prg23	DC.B	0
Prg24	DC.B	0
Prg25	DC.B	0
Prg26	DC.B	0
Prg27	DC.B	0
Prg28	DC.B	0
Prg29	DC.B	0
Prg30	DC.B	0
Prg31	DC.B	0
Prg32	DC.B	0
Prg33	DC.B	0
Prg34	DC.B	0
Prg35	DC.B	0
Prg36	DC.B	0
Prg37	DC.B	0
Prg38	DC.B	0
Prg39	DC.B	0
	DC.B	$FF
	even

**********

*	Terminate all commands with a "0". 

*	Use a "DC.B 1" to seperate commands and arguments, eg:

*	DC.B	'ppmore',1,'Somedoc.doc',0

Commands

com1	dc.b	0
com2	dc.b	0
com3	dc.b	0
com4	dc.b	0
com5	dc.b	0
com6	dc.b	0
com7	dc.b	0
com8	dc.b	0
com9	dc.b	0
com10	dc.b	'run',0			Just a non-null command 2 quit!
com11	dc.b	0
com12	dc.b	0
com13	dc.b	0
com14	dc.b	0
com15	dc.b	0
com16	dc.b	0
com17	dc.b	0
com18	dc.b	0
com19	dc.b	0
com20	dc.b	0
com21	dc.b	0
com22	dc.b	0
com23	dc.b	0
com24	dc.b	0
com25	dc.b	0
com26	dc.b	0
com27	dc.b	0
com28	dc.b	0
com29	dc.b	0
com30	dc.b	0
com31	dc.b	0
com32	dc.b	0
com33	dc.b	0
com34	dc.b	0
com35	dc.b	0
com36	dc.b	0
com37	dc.b	0
com38	dc.b	0
com39	dc.b	0
	even

**********

TechText
	dc.b	'Tech ''91',0
	even

**********

ScrScreen	dcb.b	46*11,0

**********

SetUpScroll
	move.l	#ScrScreen,d0
	move.w	d0,SCR1L
	swap	d0
	move.w	d0,SCR1H

	lea	ScrollText,a4		A4 will always hold ScrollText
	lea	ScrScreen,a3		A3 will always hold Screenaddr

	rts

**********

DoScroll
	cmpi.w	#0,Plop
	bne.s	NoPlop

	moveq.l	#0,d0
	move.b	(a4)+,d0
	cmpi.b	#$ff,d0
	bne.s	.Ok

	lea	ScrollText,a4
	bra.s	DoScroll

.Ok	lea	ScrollFont,a1
	lea	ScrScreen,a3
	adda.l	#44,a3

	subi.b	#32,d0
	mulu	#8,d0
	add.w	d0,a1
	suba.l	#1,a1

	move.l	#8,d7

	move.l	a3,-(sp)

.Loop	move.b	(a1)+,(a3)
	adda.l	#48,a3
	dbra	d7,.Loop

	move.l	(sp)+,a3

	move.w	#4,Plop

NoPlop	
	bsr.s	Scroll

	subi.w	#1,Plop

	rts

**********

Scroll	move.l	a3,a0
	bsr.s	TstBBusy						
	move.l	a0,bltapt(a5)
	move.l	a0,a1
	suba.l	#1,a1
	move.l	a1,bltdpt(a5)	
	move.w	#0,bltamod(a5)		
	move.w	#0,bltdmod(a5)	
	move.w	#$ffff,bltafwm(a5)		
	move.w	#$ffff,bltalwm(a5)	
	move.w	#%1110100111110000,bltcon0(a5)	 	
	move.w	#0,bltcon1(a5)		
	move.w	#%0000001001010111,bltsize(a5)	
	rts
	
TstBBusy
	btst	#14,dmaconr(a5)		Blitter busy?
	bne.s	TstBBusy			
	rts

**********

ScrollText
	DC.B	'HI THERE! AND WELCOME TO TECHMENU V1.00, THIS PROGRAM PROVIDES A NICE MENU '
	DC.B	'SYSTEM FOR ANYBODY TO USE AND ABUSE AS THEY WISH!!!     I MAY SOON ADD '
	DC.B	'FEATURES LIKE MULTI LEVEL SUB-MENUS BUT UNTIL THEN, YOU''LL JUST HAVE TO USE '
	DC.B	'THIS VERSION! FOR ANYBODY THAT IS INTERESTED, THIS TEXT WAS TYPED ON A TEXT '
	DC.B	'EDITOR, AND THEN PROCESSED USING MY TEXTMASTER PROGRAM!    .....     TEXT ' 
	DC.B	'RESTARTS     .....                                                         '
	DC.B	'          WHY ARE YOU STILL READING THIS?     .....                       '
	DC.B	$FF
	even

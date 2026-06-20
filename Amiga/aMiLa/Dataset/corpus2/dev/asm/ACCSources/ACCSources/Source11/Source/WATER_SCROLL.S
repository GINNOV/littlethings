
*	32 X 32 BLITTER SCROLLER.
*	MAIN CODE: ©1990 MIKE CROSS
*	ALTERATIONS: ©1991 NEIL JOHNSTON

*	THIS IS MY ALTERED VERSION OF MIKE CROSS`S 32 X 28 SCROLLER.
*	MAIN ALTERATIONS ARE:

*	1. NOW SCROLLS IN LOWER AREA OF SCREEN, BUT I COULDN`T GET IT
*	   TO SCROLL IN THE PAL AREA, SO CAN SOMEBODY TELL ME HOW? -->
*	   (28-02-91: I KNOW HOW NOW!!!)

*	2. ONLY DISPLAYS AN 8 COLOUR FONT. I `CHEATED` AND JUST CLEARED
*	   THE EXTRA 8 REGISTERS. THE REASON? TO ALLOW SOMEBODY (ME?) TO 
*	   PUT AN 8 COLOUR LOGO AT THE TOP OF THE SCREEN AND USE THE LAST
*	   8 REGISTERS FOR IT`S COLOURS.
*	   NOTE: I`VE JUST REALISED HOW DAFT THIS IS BECAUSE IT WOULD BE
*	   BETTER TO JUST CHANGE ALL THE COLOURS HALF WAY DOWN THE SCREEN
*	   USING THE COPPER WAIT COMMAND. OH WELL, YOU COULD ALWAYS USE A
*	   16 COLOUR LOGO....................EXTRA BPL REMOVED..14-02-91.

*	3. WORKS WITH A PROPERLY SET OUT 32 X 32 FONT, WHICH IS THE MOST
*	   COMMON SIZE FOR A FAIRLY LARGE FONT. SEE TUTORIAL FOR SET OUT
*	   INFO.

*	WELL MIKE, I HOPE THIS SHOWS THAT AT LEAST SOME PEOPLE LIKE AND 
*	AVIDLY READ *ALL* OF YOUR TUTORIALS. HAVE I MADE ENOUGH CHANGES?
*	I WAS GOING TO DO A MULTI SPEED BIT BY DECREASING THE PLOP COUNTER
*	AND HALVING THE THE BARREL ROLL. IT WORKED BUT I COULDN`T BE BOTHERED
*	DOING ALL THE SUPPORTING CODE FOR THE REST OF THE PROGRAM, BESIDES, 
*	I PROBABLY WOULDN`T HAVE USED IT ANYWAY! OOPS! THIS `COMMENT` IS
*	GETTING JUST A TEENY WEE BIT BIG SO I`LL HAVE TO PUT ALL THE OTHER
*	THINGS I WANT TO SAY SOMEWHERE ELSE.....SEE MY FONT TUTORIAL.
*							Neil 12-02-91

*	14-02-91: ADDED THE WATER REFLECTION CODE. SIMPLE BUT NICE EH?

*	LATER...ACTUALLY GOT AROUND TO FIXING THE BUG WHERE THE TOP OF SOME
*	CHARS WAS CHOPPED OFF. TOOK ABOUT 30 SECONDS!!!!!

*	14-02-91: (PM) MADE THE CODE JUST ABOUT 9K SMALLER BY REMOVING EXCESS
*	BITPLANES, ETC.

*	19-02-91: MOVED SCREEN MEMORY AREA AND MY `KLUDGEFILL` AREA INTO A
*	BSS HUNK, TO SAVE YET MORE DISK SPACE. FILE SIZE IS NOW ABOUT 29K
*	A SAVING OF ABOUT 7K MORE! THAT MEANS THE FILE SIZE IS NOW DOWN FROM
*	ABOUT 45K TO 29K. DON`T YA JUST LOVE THESE OPTIMISATIONS? ANSWERS ON
*	THE BACK OF A POSTCARD TO MARK!

*	28-02-91: YES, I'M STILL WORKING ON THIS!:
*	AT LONG LAST, I FOUND HOW TO GET THE COPPER TO WAIT IN THE PAL AREA!
*	(IT'S EASY WHEN YOU KNOW HOW!) MADE THE SCROLLER LOWER. ADDED THE
*	BLUE COPPER BAR AS IT LOOKS BETTER THAN JUST PLAIN BLUE!

*	28-02-91: JUST ADDED A 1 BITPLANE PICTURE TO THE SCROLLER! CHANGED
*	THE COLOUR OF EACH TEXT LINE TO MAKE IT LOOK A BIT BETTER

**********

	OPT	C-

**********

	incdir	include/
	include	hardware/custom.i
	include	exec/exec_lib.i
	
*********

	movem.l  a0-a6/d0-d7,-(a7)		* Save all on stack
	move.l   a7,Stack
	
	lea	$dff000,a5
	
**********

	lea	Screen,a0
	lea	plane,a1
	moveq.l	#2,d1			* No. of planes -1	
NxtPlane	
	move.l	a0,d0
	swap	d0
	move.l	d0,a0
	move.w	a0,(a1)
	move.l	a0,d0
	swap	d0
	move.l	d0,a0
	move.w	a0,4(a1)
	adda.w	#2208,a0			* Plane size
	adda.w	#8,a1			
	dbra	d1,NxtPlane
		
**********

DRAWPIC	MOVE.L	#PIC,D0
	MOVE.W	D0,PICL
	SWAP	D0
	MOVE.W	D0,PICH

**********
		
	lea     Gfxlib,a1
	CALLEXEC	OldOpenLibrary    
	move.l 	d0,Gfxbase    		     
	beq	Q_Exit
	
	CALLEXEC	Forbid
	     
	move.w	dmaconr(a5),DMAsave		     
	move.w  #$7fff,dmacon(a5)		* Clear DMA   
	move.l  #Copper,cop1lc(a5)     
	move.w  #0,copjmp1(a5)			* Strobe list     
	move.w  #%1000011111000000,dmacon(a5)
	
**********

Main	move.l	vposr(a5),d0
	and.l	#%11111111100000000,d0
	lsr.l	#8,d0
	cmp.w	#305,d0
	
	bne.s	Main	

**********
	
	bsr.s	Scroller
	
**********
		
	btst	#6,$bfe001		* Left mouse ?
	bne.s	Main
	
**********

exit	move.w 	DMAsave,d7		* Restore operating system
	bset   	#$f,d7			* Enable copper DMA
	move.w 	d7,dmacon(a5)	
	move.l 	Gfxbase,a0
	move.l 	38(a0),cop1lc(a5)	* Retrieve Cli list	
	
	CALLEXEC	Permit
	
	move.l	Gfxbase,a1
	CALLEXEC	CloseLibrary
	
	move.l  Stack,a7
	movem.l (a7)+,A0-a6/d0-D7
	moveq.l	#0,d0
Q_Exit	rts
	
**********	

Scroller	
	btst	#2,potinp(a5)	* Right Mouse ?
	beq.s	GDOWN		* If so, pause text
	cmpi.w	#0,PauseCnt	* Is pause required ?
	beq.s	No_Pause
	subi.w	#1,PauseCnt
OutScr	rts

No_Pause	
	cmpi.w	#1,CharFlag	* Is it end of Text ?
	beq.s	No_Need
	lea	Text,a4		* Yes, then re-load counter
No_Need	move.w	#1,CharFlag
	cmpi.w	#0,Plop		* Do we need a new char ?
	beq.s	NextChar			
contscrl
	bsr	Scroll		* No, then scroll screen
	rts
**********

GDOWN	ADDI.W	#44,SCRVAL
	BRA	MAIN
	
**********

NextChar	
	bsr.s	GetChar	* Yes, then get it from text.
	move.w	#8,Plop		* Reset plop counter
	bra.s	contscrl	* And contine scrolling
	rts
	
GetChar	lea	Font,a2
	moveq.l	#0,d0
	move.b	(a4)+,d0	* Get current character

TST_CR	CMPI.B	#10,D0		* CARRIAGE RETURN?
	BNE.S	TST_00
	MOVE.B	#32,D0		* A SPACE WILL DO, THANKS!
	BRA	CONT

TST_00	CMPI.B	#00,D0		* CHECK FOR A `$00`
	BNE.S	CONT		* JUST JUMP IF NOT
	MOVE.B	#32,D0		* A SPACE WILL DO ME FINE, THANKS!

CONT	cmpi.b	#120,d0		* Is it end of text ? (x = ascii 120)
	bne.s	NotEnd
	clr.w	CharFlag	* Yes, then reload text
	bra	Main
	
NotEnd	cmpi.b	#99,d0		* Is it a pause request (c) ?
	beq.s	Pause
	cmpi.b	#57,d0		* Are we on punctuation line ?
	bls.s	Line_2
	cmpi.b	#64,d0		* Calculate line of Font1
	bgt.s	Line_1
	rts
		
Line_1	sub	#65,d0		* Find position in Font1
	mulu	#4,d0		* Line 1 conatains A-Z 	
	add.l	d0,a2
	bsr	PlopIt		* Plop character routine
	rts
		
Line_2	mulu	#4,d0		* Line 2 contains all the punctuation
	addi.w	#3224,d0	* 3328 = OFFSET TO SECOND LINE (EXTRA CHARS)
	add.l	d0,a2		* 3224
	bsr	PlopIt		* Plop character routine
	rts
	
Pause	move.w	#140,PauseCnt	* Set pause delay counter
	bra	Main
	rts
		
**********	
	
Scroll	lea	Screen,a0
	moveq.l	#2,d0			* Planes -1
ScrLp	bsr	TstBBusy						
	move.l	a0,bltapt(a5)		
	move.l	a0,a1
	suba.l	#1,a1
	move.l	a1,bltdpt(a5)	
	move.w	#0,bltamod(a5)		
	move.w	#0,bltdmod(a5)	
	move.w	#$ffff,bltafwm(a5)		
	move.w	#$ffff,bltalwm(a5)	
	move.w	#%1100100111110000,bltcon0(a5)	* D=A 	
	move.w	#0,bltcon1(a5)		
	move.w	#%0000100010010111,bltsize(a5)	* 34 x 23 	
	add.w	#2208,a0			* Add plane size
	dbra	d0,ScrLp			* Blit next plane
	subi.w	#1,Plop				* Decrease plop counter
	rts
	
**********

PlopIt	lea	Screen+44,a3
	ADD.W	SCRVAL,A3
	moveq.l	#2,d0
PlpLp	bsr.s	TstBBusy
	move.l	a2,bltapt(a5)		
	move.l	a3,bltdpt(a5)		
	move.w	#100,bltamod(a5)		* Font Modulo
	move.w	#44,bltdmod(a5)			* Screen Modulo
	move.w	#%0000100111110000,bltcon0(a5)	
	move.w	#%0000100000000010,bltsize(a5)	* 2 WORDS X 31 PIXELS
	add.w	#$1a00,a2		* $1A00 = SIZE OF 1 832 X 64 PLANE	
	add.w	#2208,a3		* NEXT PLANE ON THE SCREEN.
	dbra	d0,PlpLp
	rts
	
**********

TstBBusy	
	btst	#14,dmaconr(a5)		* Test state of Blitter
	bne.s	TstBBusy			
	rts
	

**********

	Section	Copper,code_c

Copper	dc.w	diwstrt,$2010		* Setup PAL Overscan screen	
	dc.w 	diwstop,$36d4	
	dc.w	ddfstrt,$0030	
	dc.w	ddfstop,$00d4	
	dc.w 	bplcon0,$1200	

	dc.w	bpl1mod,-4
	dc.w 	bpl2mod,-4	
	

	DC.W	$2009,$FFFE
	DC.W	$00E0
PICH	DC.W	$0,$00E2
PICL	DC.W	$0

	DC.W	$0180,$000,$182,$0FFF

	DC.W	$2009,$FFFE,$0182,$0000
	DC.W	$2209,$FFFE,$0182,$0111
	DC.W	$2409,$FFFE,$0182,$0222
	DC.W	$2609,$FFFE,$0182,$0333
	DC.W	$2809,$FFFE,$0182,$0444
	DC.W	$2A09,$FFFE,$0182,$0555
	DC.W	$2C09,$FFFE,$0182,$0666
	DC.W	$2E09,$FFFE,$0182,$0777
	DC.W	$3009,$FFFE,$0182,$0888
	DC.W	$3209,$FFFE,$0182,$0999
	DC.W	$3409,$FFFE,$0182,$0AAA
	DC.W	$3609,$FFFE,$0182,$0BBB
	DC.W	$3809,$FFFE,$0182,$0CCC
	DC.W	$3A09,$FFFE,$0182,$0BBB
	DC.W	$3C09,$FFFE,$0182,$0AAA
	DC.W	$3E09,$FFFE,$0182,$0999
	DC.W	$4009,$FFFE,$0182,$0888
	DC.W	$4209,$FFFE,$0182,$0777
	DC.W	$4409,$FFFE,$0182,$0666
	DC.W	$4609,$FFFE,$0182,$0555
	DC.W	$4809,$FFFE,$0182,$0444
	DC.W	$4A09,$FFFE,$0182,$0333
	DC.W	$4C09,$FFFE,$0182,$0222
	DC.W	$4E09,$FFFE,$0182,$0111

	DC.W	$5009,$FFFE,$0182,$00F0

	DC.W	$6009,$FFFE,$0182,$0FFF

	DC.W	$8009,$FFFE,$0182,$0F00

	DC.W	$B009,$FFFE,$0182,$005F

	DC.W	$C009,$FFFE,$0182,$0FF0



	DC.W	$F009,$FFFE
	DC.W	BPL1MOD,$0004
	DC.W	BPL2MOD,$0004


cop1:	dc.w	$0180,$0000
	dc.w	$0182,$0F99
	dc.w	$0184,$0E77
	dc.w	$0186,$0D55
	dc.w	$0188,$0A33
	dc.w	$018A,$0922
	dc.w	$018C,$0811
	dc.w	$018E,$0700
	;Generated by IFFMaster v1.0 by JUNIX / ARCANE!

	dc.w	$FA09,$fffe,bplcon0,$3200	SMALLER SCREEN THAN FULL ONE!

	dc.w	bplpt+$00
plane	dc.w 	$0000,bplpt+$02
	dc.w 	$0000,bplpt+$04
 	dc.w 	$0000,bplpt+$06
	dc.w 	$0000,bplpt+$08
 	dc.w 	$0000,bplpt+$0a
	dc.w 	$0000,bplpt+$0c
	dc.w 	$0000,bplpt+$0e
 	dc.w 	$0000

	DC.W	$FFE1,$FFFE			PAL ENABLE

	DC.W	$1009,$FFFE,$0180,$0003
	DC.W	$1209,$FFFE,$0180,$0006
	DC.W	$1409,$FFFE,$0180,$0009
	DC.W	$1609,$FFFE,$0180,$000B
	DC.W	$1809,$FFFE,$0180,$000F


	
	DC.W	$1A09,$fffe,$0180,$000f,bpl1mod,-92,bpl2mod,-92
	DC.W	$1C09,$FFFE,$0180,$000E
	DC.W	$1E09,$FFFE,$0180,$000D
	DC.W	$2009,$FFFE,$0180,$000C
	DC.W	$2209,$FFFE,$0180,$000B
	DC.W	$2409,$FFFE,$0180,$000A
	DC.W	$2609,$FFFE,$0180,$0009
	DC.W	$2809,$FFFE,$0180,$0008
	DC.W	$2A09,$FFFE,$0180,$0007
	DC.W	$2C09,$FFFE,$0180,$0006
	DC.W	$2E09,$FFFE,$0180,$0005
	DC.W	$3009,$FFFE,$0180,$0004
	DC.W	$3209,$FFFE,$0180,$0003
	DC.W	$3409,$FFFE,$0180,$0002
	DC.W	$3609,$FFFE,$0180,$0001
	DC.W	$3809,$FFFE,$0180,$0000

     	
	DC.W	$FFFF,$FFFE		<-- ANYBODY KNOW WHAT THIS DOES?!?!	


**********

DMAsave	dc.w	0

Plop	dc.w	0

PauseCnt	dc.w	0

CharFlag	dc.w	0

Memory	dc.l	0

SCRVAL	DC.W	0

Stack	dc.l	0

Gfxbase	dc.l	0

	even
	
Gfxlib	dc.b	"graphics.library",0

	even



Font	INCBIN	source:bitmaps/MYFONTX.RAW
*					I SPENT  H O U R S  JUST SETTING THIS
	even				FONT UP RIGHT! I DIDN`T EVEN DRAW IT!!!
	
**********
*	c	-	Pause Text (width 11 Chars (before c))
*	x	-	End and Wrap Text
*
********** 
*
*     NOTE: PLEASE READ THE SCROLL `IN THE PROGRAM` AS THERE ARE SOME SPECIAL
*     (& IMPORTANT?) CHARS WHICH DO NOT APPEAR OTHERWISE.  
*				       THANKS, NEIL JOHNSTON 10/02/91 - 19:38	
**********


Text	

	DC.B	'  ## +- ##  cc   MEGASCROLL V1.1 '	<-- STANDARD HEADER!


	INCBIN	source:source/SCROLLTEXT.n	<-- I 'INCBIN' THE TEXT COZ IT'S EASIER!

	DC.B	' OK, THIS IS NEIL SIGNING OFF FOR NOW. ' <-- STD. END!
	DC.B	'   WEDNESDAY 20 MARCH, 1991. 8.53 PM       $ / $ / $ / $ / $ / $ / $ / $ / $ / $ / $ / $ / $ / '
	DC.B	'$ $ $ $ $ $ $ $ $ cc             x'


*	MILDLY INTERESTING FACT #4:
*	THAT WAS (NOT) THE BIGGEST SCROLL TEXT I HAVE EVER DONE!

PIC	INCBIN	source:bitmaps/SCROLLER.CREDS.RAW

	SECTION	SCREENDATA,BSS_C



KLUDGE	dcb.b	46*15			828 BYTE KLUDGEFILL!!! TRY RUNNING
*					THIS DEMO WITHOUT IT!

Screen	DCB.B	6624,0			MY SCREEN SIZE
	EVEN





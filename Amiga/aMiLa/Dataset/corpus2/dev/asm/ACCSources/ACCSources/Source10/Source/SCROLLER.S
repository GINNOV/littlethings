
*	32 X 32 BLITTER SCROLLER.
*	MAIN CODE: ©1990 MIKE CROSS
*	ALTERATIONS: 1991 NEIL JOHNSTON

*	THIS IS MY ALTERED VERSION OF MIKE CROSS`S 32 X 28 SCROLLER.
*	MAIN ALTERATIONS ARE:

*	1. NOW SCROLLS IN LOWER AREA OF SCREEN, BUT I COULDN`T GET IT
*	   TO SCROLL IN THE PAL AREA, SO CAN SOMEBODY TELL ME HOW?

*	2. ONLY DISPLAYS AN 8 COLOUR FONT. I `CHEATED` AND JUST CLEARED
*	   THE EXTRA 8 REGISTERS. THE REASON? TO ALLOW SOMEBODY (ME?) TO 
*	   PUT AN 8 COLOUR LOGO AT THE TOP OF THE SCREEN AND USE THE LAST
*	   8 REGISTERS FOR IT`S COLOURS.
*	   NOTE: I`VE JUST REALISED HOW DAFT THIS IS BECAUSE IT WOULD BE
*	   BETTER TO JUST CHANGE ALL THE COLOURS HALF WAY DOWN THE SCREEN
*	   USING THE COPPER WAIT COMMAND. OH WELL, YOU COULD ALWAYS USE A
*	   16 COLOUR LOGO......

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

**********

	incdir	include/
	include	hardware/custom.i
	include	exec/exec_lib.i
	

**********

	clr.w	Plop
	clr.w	PauseCnt			* Clear all scroller
	clr.w	CharFlag			* Flags and counters	
	
*********

	movem.l  a0-a6/d0-d7,-(a7)		* Save all on stack
	move.l   a7,Stack
	
	lea	$dff000,a5
	
**********

	lea	Screen,a0
	lea	plane,a1
	moveq.l	#3,d1			* No. of planes -1	
NxtPlane	
	move.l	a0,d0
	swap	d0
	move.l	d0,a0
	move.w	a0,(a1)
	move.l	a0,d0
	swap	d0
	move.l	d0,a0
	move.w	a0,4(a1)
	adda.w	#1824,a0			* Plane size
	adda.w	#8,a1			
	dbra	d1,NxtPlane
		
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
	beq.s	OutScr		* If so, pause text
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

NextChar	
	bsr.s	GetChar	* Yes, then get it from text.
	move.w	#8,Plop		* Reset plop counter
	bra.s	contscrl	* And contine scrolling
	rts
	
GetChar	lea	Font,a2
	moveq.l	#0,d0
	move.b	(a4)+,d0	* Get current character
	cmpi.b	#120,d0		* Is it end of text ? (x = ascii 120)
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
	addi.w	#3328,d0	* 3328 = OFFSET TO SECOND LINE (EXTRA CHARS)
	add.l	d0,a2
	bsr	PlopIt		* Plop character routine
	rts
	
Pause	move.w	#140,PauseCnt	* Set pause delay counter
	bra	Main
	rts
		
**********	
	
Scroll	lea	Screen,a0
	moveq.l	#3,d0			* Planes -1
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
	add.w	#1824,a0			* Add plane size
	dbra	d0,ScrLp			* Blit next plane
	subi.w	#1,Plop				* Decrease plop counter
	rts
	
**********

PlopIt	lea	Screen+44,a3
	moveq.l	#3,d0
PlpLp	bsr.s	TstBBusy
	move.l	a2,bltapt(a5)		
	move.l	a3,bltdpt(a5)		
	move.w	#100,bltamod(a5)		* Font Modulo
	move.w	#44,bltdmod(a5)			* Screen Modulo
	move.w	#%0000100111110000,bltcon0(a5)	
	move.w	#%0000011111000010,bltsize(a5)	* 2 WORDS X 31 PIXELS

*	YOU MAY BE WONDERING WHY I USE A 32 X 31 BLIT FOR A 32 X 32 FONT?
*	WELL SOME OF THE EXTRA CHARS HAVE LITTLE DOTS BELOW THEM FOR SOME
*	REASON. DOING ONLY 31 LINES CUTS THESE OFF (AND THE BOTTOM OFF THE
*	FONT! BUT IT`S NOT REALLY THAT NOTICEABLE. OR IS IT?)
 
	add.w	#$1a00,a2		* $1A00 = SIZE OF 1 832 X 64 PLANE	
	add.w	#1824,a3		* NEXT PLANE ON THE SCREEN.
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
	dc.w 	bplcon0,$0200	
	
	
*	Scroll Area

	dc.w	bpl1mod,0004		
	dc.w 	bpl2mod,0004	
	
cop1:	dc.w	$0180,$0000
	dc.w	$0182,$0FFF
	dc.w	$0184,$0BBE
	dc.w	$0186,$088D
	dc.w	$0188,$055C
	dc.w	$018A,$022B
	dc.w	$018C,$000A
	dc.w	$018E,$0777
	dc.w	$0190,$0		* IF YOU`RE BORED YOU CAN TRY
	dc.w	$0192,$0		* AND PUT A LOGO AT THE TOP OF THE
	dc.w	$0194,$0		* SCROLLER SCREEN AND USE THESE
	dc.w	$0196,$0		* REGISTERS ALONG WITH THE TOP ONES
	dc.w	$0198,$0		* TO GIVE YOU 16 COLOURS. 
	dc.w	$019A,$0
	dc.w	$019C,$0
	dc.w	$019E,$0
	;Generated by IFFMaster v1.0 by JUNIX / ARCANE!
*			THE *BEST* IFF CONVERTER AROUND (I THINK!) 
	

	
	
	dc.w	$Df09,$fffe,bplcon0,$4200	SMALLER SCREEN THAN FULL ONE!

	dc.w	bplpt+$00
plane	dc.w 	$0000,bplpt+$02
	dc.w 	$0000,bplpt+$04
 	dc.w 	$0000,bplpt+$06
	dc.w 	$0000,bplpt+$08
 	dc.w 	$0000,bplpt+$0a
	dc.w 	$0000,bplpt+$0c
	dc.w 	$0000,bplpt+$0e
 	dc.w 	$0000


	dc.w	$FF09,$fffe,bplcon0,$0200	END OF SHORT SCREEN (I CAN`T 
*						GET IT ANY LOWER! HOW IS IT
*						DONE THEN?)

     	dc.l	$fffffffe	

**********

DMAsave	dc.w	0

Plop	dc.w	0

PauseCnt	dc.w	0

CharFlag	dc.w	0

Memory	dc.l	0

Stack	dc.l	0

Gfxbase	dc.l	0

	even
	
Gfxlib	dc.b	"graphics.library",0

	even
	
Screen	dcb.b	7296,0			UM. I DON`T KNOW WHAT TO CHANGE 
	EVEN				THIS TO FOR MY NEW FONT! BUT IT
*					WORKS, SO DON`T KNOCK IT!!

Font	incbin	source10:bitmaps/scrollerfont.raw	I SPENT  H O U R S  JUST SETTING THIS
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

Text 	DC.B	''
	DC.B	'  ## +- ##  cc THE MIKE CROSS SCROLLER HOMEWORK!       '
	DC.B	'YES, I THOUGHT THAT THE SCROLLER TUTORIAL BY MIKE CROSS '
	DC.B	'WAS SO GOOD, THAT I DID ALL THREE OF HIS HOMEWORK ASSIGNMENTS, '
	DC.B	'ALL IN THE ONE PROGRAM! WELL, I HAVE NOT REALLY DONE ANY OF THEM '
	DC.B	'PROPERLY BECAUSE . . .  1.  I COULD NOT GET THE COPPER TO WAIT FOR '
	DC.B	'A LINE BELOW 255, SO THIS TEXT IS NOT QUITE IN THE PAL AREA. HOW IS IT DONE THEN%  2.  '
	DC.B	'THIS FONT IS IN 8 COLOURS, BUT ALL I DID WAS STICK MY OWN 8 COLOUR '
	DC.B	'FONT IN AND CLEARED THE OTHER 8 COLOUR REGISTERS!  3.  THIS FONT IS NOT '
	DC.B	'A 32 X 64 FONT, IT IS JUST A 32 X 32 FONT AS I DID NOT HAVE A 32 X 64 '
	DC.B	'FONT, BUT SINCE THE THEORY BETWEEN CHANGING FROM 32 X 28 TO 32 X 32 IS JUST '
	DC.B	'THE SAME, YOU COULD SAY I HAVE DONE THIS ANYWAY.  '
	DC.B	'I DONT KNOW ABOUT ANYBODY ELSE WHO TRIED TO CHANGE THE FONT IN THIS SCROLLER, '
	DC.B	'BUT I DID HAVE SOME PRETTY SERIOUS PROBLEMS IN TRYING TO GET THE EXTRA CHARACTERS, '
	DC.B	'COMMAS, FULL STOPS, ETC. MAINLY BECAUSE THE LAYOUT MIKE GAVE IN THE TUTORIAL DID NOT '
	DC.B	'WORK! I THEN HAD TO SPEND A WHILE SWAPPING ALL THE CHARACTERS AROUND UNTIL I GOT THE '
	DC.B	'RIGHT COMBINATIONS. FOR THIS REASON, AND OTHERS, I HAVE WRITTEN A TUTORIAL ON GETTING '
	DC.B	'NEW FONTS OF DIFFERENT SIZES INTO THE SCROLLER, AS IT IS BY NO MEANS AS EASY AS IT MAY SEEM '
	DC.B	'AT FIRST! BELIEVE ME, I HAVE SPENT ABOUT 5 HOURS TRYING TO GET THIS ONE TO WORK PERFECTLY!!! '
	DC.B	'YOU ALSO MAY HAVE NOTICED MY EXTRA CHARACTERS (AT THE START.) THESE ARE DONE BY SIMPLY REPLACING '
	DC.B	'THE ONES YOU DO NOT USE IN THE FONT WITH YOUR OWN GRAPHICS, SIMPLE BUT EFFECTIVE! '
	DC.B	'WELL HERE COME THE MOST ORIGINAL PART OF THE SCROLLER . . . THE GREETINGS!!!!! '
	DC.B	'WELL THANKS MUST GO, AS EVER, TO      &     cI JUST HAVE TO SAY . . .     $     cWITHOUT IT '
	DC.B	'I DO NOT KNOW WHERE I WOULD BE TODAY. PROBABLY STILL STRUGGLING THROUGH OLD MAGAZINES AND BUYING '
	DC.B	'HUNDREDS OF BOOKS. EXTRA SPECIAL THANKS TO THE WRITER OF GREAT TUTORIALS . . .       *     cALL MY (COMPUTING) '
	DC.B	'LIFE, I HAVE WANTED TO DO A SCROLLER! NOW I CAN! THANKS! OH, BY THE WAY MIKE, WHO ARE PINK FLOYD% '
	DC.B	'I HAVE NEVER HEARD OF THEM!         "     cGREETINGS TO ALL ACC READERS, BUT ESPECIALLY TO THOSE WHO '
	DC.B	'CONTRIBUTE TO IT! IF YOU HAVE NEVER SENT ANYTHING TO THE ACC DISK, THEN YOU SHOULD! BESIDES, YOU CAN GET OTHER '
	DC.B	'PEOPLE TO DO ALL THAT NASTY HORRIBLE DEBUGGING FOR YOU!!!   OK, THIS IS NEIL SIGNING OFF FOR NOW. '
	DC.B	'   SUNDAY 10TH FEBRUARY, 1991,   7.27PM . . .        $ / $ / $ / $ / $ / $ / $ / $ / $ / $ / $ / $ / $ / '
	DC.B	'$ $ $ $ $ $ $ $ $ cc             x'


*	MILDLY INTERESTING FACT #3:
*	THAT WAS THE BIGGEST SCROLL TEXT I HAVE EVER DONE!

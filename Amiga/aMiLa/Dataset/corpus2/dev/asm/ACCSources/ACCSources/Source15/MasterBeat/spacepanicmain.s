
**************************

; Space Panic, v0.000002
; © 1991, S.M. Windmill (Master Beat)
; Code help by various peeps, full credit in finished game 
; (yes, honestly!)

; To MJC - Yes, my code is scruffy, waddya expect from a student!?!
 
**************************
 
	SECTION	SpacePanic,Code_C	; Let's have chip mem
	opt	o+,ow-,c-		; Squeeze the best from Devpac

**************************

	include source:include/execware.i

; This is just the standard exec_lib.i include, joined to the nice
; hardware.i file from ACC a while back. I think it was sent in by
; Treebeard

************************** 

	jmp	StartCode		; Go to the program
	
**************************

; Just a little message for any disassemblers out there...

	rept	30
	dc.b	" FUCK OFF, IT'S MY GAME!!!   "
	endr

**************************
StartCode:
**************************

; Equates

MinShipX	equ	$48		}
MaxShipX	equ	$d0		} Used to keep the ships in
MaxShipY	equ	$e0		} the right place!
MinShipY	equ	$30		}

Execbase	equ	4

**************************

	move.l	Execbase,a6		; Find Execbase
	CALLEXEC Forbid			; Atari ST emulation on
	lea	gfxlib,a1		; Gfx libby in a1
	moveq	#$00,d0			; Any version, don't care!
	CALLEXEC OldOpenLibrary		; Open it.
	move.l	d0,_gfxbase		; Store d0 (gfx add.)
	beq	nolib_exit		; Whoa! What went erong?

	move.l	_gfxbase,a0		; LOAD ADDRESS OF GRAPHICS LIB IN A0
	move.l	50(a0),oldcop		; Store copperlist to get later

	move.w	Dmaconr(a5),DMAsave	; Store old DMA
	move.w	#$7fff,Dmacon(a5)	; Clear all DMA
	move.w	#(SETIT!DMAEN!BPLEN!COPEN!BLTEN!SPREN!DSKEN!AUD3EN!AUD2EN!AUD1EN!AUD0EN),dmacon(a5)
					; Set DMA	


**************************

; This is the start of the game, to be looped back to after the Panic Over
; message.

StartOfAll
	clr.w	hcount			} These lines reset the pointers
	clr.l	strtpos			} that control the screen type
	clr.l	linestrt		} routine for the menu

	clr.w	GameLength		; Reset time counter
	
	jsr	ClearBlank		; Blit clear the text area 

	move.l	_gfxbase,a0		; LOAD ADDRESS OF GRAPHICS LIB IN A0
	move.l	#TitleCop,50(a0)	; Load in our first clist

	move.l	#BackGnd,d0		; Load in the 'SP' background
	move.w	d0,Title1l
	swap	d0
	move.w	d0,Title1h
	swap	d0
	add.l	#8000,d0
	move.w	d0,Title3l
	swap	d0
	move.w	d0,Title3h
	swap	d0
	
	move.l	#SpaceCont,d0		; Load in the bottom message
	move.w	d0,Scontl
	swap	d0
	move.w	d0,Sconth
	swap	d0

***************

; The TECH routine for putting the text in...

BEGIN	
	MOVEQ.L	#0,D0
	MOVE.L	#TEXT,A0		TEXT ADDRESS --> A0

	MOVE.L	#Scrollpl,A2		SCREEN ADDRESS --> A2
	MOVE.L	A2,STRTPOS		SAVE CURRENT SCREEN POINTER
	MOVE.L	A2,LINESTRT		SAVE LINE START POINTER

LOOP	MOVE.L	#FONT,A1		ADDRESS	OF FONT DATA --> A1

	MOVE.B	(A0)+,D0		READ CHAR
	CMPI.B	#120,D0			IS IT AN "x"?
	BEQ	END			YES: END!


SPD_DNE	CMPI.W	#40,HCOUNT		ADJUST FIRST NUMBER FOR SCREEN WIDTH
	BNE.S	NOT_EOL

	MOVE.W	#0,HCOUNT
	MOVE.L	LINESTRT,A2
	ADDA.L	#40*9,A2
	MOVE.L	A2,STRTPOS
	MOVE.L	A2,LINESTRT

NOT_EOL	CMPI.B	#59,D0
	BGT.S	ALPHA_CHAR		IT'S AN A-Z CHARACTER
	CMPI.B	#31,D0
	BGT.S	PUNC_CHAR		IT'S AN EXTRA CHARACTER
	BRA	SKIP			SKIP IF CHAR IS NOT RECOGNISED

ALPHA_CHAR
	SUBI.L	#65,D0			ASCII --> POINTER
	ADD.L	D0,A1			ADD POINTER TO FONT POINTER
	BRA	STRTPLT			PRINT CHARACTER

PUNC_CHAR
	SUBI	#32,D0			GET PROPER OFFSET
	ADDI.L	#26,D0			SKIP ALPHA CHARS
	ADD.L	D0,A1			AND ADD OFFSET

STRTPLT	MOVE.L	#7,D1			8 DBRA LOOPS

PLOTLP	MOVE.B	(A1),(A2)		MOVE 8 BITS FROM FONT TO SCREEN
	ADDA.L	#52,A1			NEXT FONT LINE
	ADDA.L	#40,A2			NEXT SCREEN LINE

	DBRA	D1,PLOTLP		DO REST OF CHARACTER

SKIP	ADDI.L	#1,STRTPOS		NEXT HORIZONTAL POSITION
	MOVE.L	STRTPOS,A2		RELOAD (NEW) SCREEN POINTER

	
	ADDI.W	#1,HCOUNT
	
	BRA	LOOP			KEEP ON GOING!

***************

END	
	move.l	#ScrollPl,d0		; Now move the text to the screen
	move.w	d0,Scrolll
	swap	d0
	move.w	d0,Scrollh

**************************

; Wait for Space to be pressed...

WaitLoop

	move.b	$BFEC01,D0		; Get Raw character
	not	D0
	ror.b	#1,D0
	cmp.b	#$40,D0			; Is it 'Space'?
	bne.s	WaitLoop		; No, so loop back

	jsr	mt_init			; Initialise the ST player

	move.l	_gfxbase,a0		; LOAD ADDRESS OF GRAPHICS LIB IN A0
	move.l	#Newcop,50(a0)		; Load in our game clist

	bsr	initalise		; Set up things
	
**********************

; The main game loop...

wait					; WAIT LOOP
	cmp.b	#255,vhposr(a5)		; Do that funky wait thang!
	bne.s	wait			


	bsr	DoCollisions		; Check for hits
	bsr	Joystick1		; Read stick 1
	jsr	Joystick0		; Read stick 0
	bsr	Sprites_45		; Move junk
		
	bsr	scroll_1		; Scroll big clouds
	bsr	scroll_2		; Scroll med clouds
	bsr	scroll_3		; Scroll small clouds
	bsr	scroll_4		; Scroll mountains
	bsr	scroll_5		; Scroll small grass 
	bsr	scroll_6		; Scroll med grass 
	bsr	scroll_7		; Scroll big grass
	
	movem.l	a0-a7/d0-d7,-(sp)	; Save registers
	jsr	mt_music		; Play that tune
	movem.l	(sp)+,a0-a7/d0-d7	; Bring back registers
	
	jsr	FlashTest1		; Check for Audio Channel 1 
	jsr	FlashTest2		; Check for Audio Channel 2
	jsr	FlashTest3		; Check for Audio Channel 3
	jsr	FlashTest4		; Check for Audio Channel 4

;DELETE!
****************************************************************	
;	Btst	#6,$bfe001		; Lefty pressed?
;	beq.s	Ended			; Yes, so end game
****************************************************************

	add.w	#1,GameLength		; Increment time counter
	cmpi.w	#6000,GameLength	; Are we at the end?
	beq.s	Ended			; Yep, so leave the game
	
	cmpi.w	#$0000,NRG2Col		; Is player two dead?
	beq.s	Play1Won		; Yep, so one has won
	
	cmpi.w	#$0000,NRG1Col		; Is player one dead?
	beq.s	Play2Won		; Yep, so two has one
	
	bra	Wait			; Loop back around

*************************

; Sort out who has won...

Play1Won
	move.b	#1,ITFlag
	bra	Ended

Play2Won
	move.b	#0,ITFlag
	
; Let us leave...

ended	
	jsr	mt_end			; Turn it off, turn it off!
	jsr	GameOverSetUp		; Set up screen

******

; Set up that copper bar for the colour effect.

startcop	lea	bar,a0
		move.l	#$5401fffe,d0	; Start position
		move.l	#$01920000,d1	; Register to load colours to
		move.w	#nobars-1,d2
startloop1	move.w	#barwidth-1,d3
startloop2	move.l	d0,(a0)+
		move.l	d1,(a0)+
		add.l	#linewidth*$00100000,d0
		dbra	d3,startloop2
		dbra	d2,startloop1

******

	cmpi.b	#1,ITFlag		; Is player one the winner?
	beq.s	Winner1			; Yep, so show it!
	
	move.l	#Win2,d0		; Set up planes for player 2 as winner
	move.w	d0,Winnerl
	swap	d0
	move.w	d0,Winnerh
	swap	d0

	move.l	#FireCont,d0		; Set up bottom message
	move.w	d0,Fcontl
	swap	d0
	move.w	d0,Fconth
	swap	d0

	bra	WaitLoop2		; Skip the `player one win' bit
	
Winner1
	move.l	#Win1,d0		; Set up planes for player 1 as winner
	move.w	d0,Winnerl
	swap	d0
	move.w	d0,Winnerh
	swap	d0

	move.l	#FireCont,d0		; Set up bottom message
	move.w	d0,Fcontl
	swap	d0
	move.w	d0,Fconth
	swap	d0
		
WaitLoop2
	jsr	MoveCop			; Change colours of Panic Over
	btst	#7,$bfe001		; Is it firebutton?

	beq	StartOfAll		; Yep, so start over

*****
; Check keyboard...

	move.b	$BFEC01,D0		; Get raw character...
	not	D0
	ror.b	#1,D0
	cmp.b	#$45,D0			; Is it 'ESC'?
	bne.s	WaitLoop2		; No, so continue looping!

**************************

; Say goodbye to it all...

	move.l	_gfxbase,a0		; Load gfx libby in a0
	move.l	oldcop,50(a0)		; Restore copper list
dealloc	
	move.w 	DMAsave,d7		
	bset   	#$f,d7			; Enable copper DMA
	move.w 	d7,dmacon(a5)		; Set DMA

	move.l	Execbase,a6		; Find that number 4...
nomem_exit	
	CALLEXEC Permit			; Only the Amiga makes it possible...
	move.l	_gfxbase,a1		; Load gfx libby in a1
	CALLEXEC CloseLibrary		; Bank Holiday for libraries

nolib_exit
	moveq	#0,d0			; Piss off, CLI errors
	rts				; I'll be back!
	
*************************************************

; Set up some variables and stuff

Initalise
	lea	$dff000,a5		; LOAD A5 WITH CUSTOM BASE ADDRESS
	move.w	#%0111000000000000,Clxcon(a5)	; Set collision types

*****
	
	move.w	#$Ff,scroll1		; Initialise big cloud scroll value
	move.w	#$ff,scroll2		;   ""  ""   med   ""     ""    ""
	move.w	#$ff,scroll3		;   ""  ""   small ""     ""    ""
	move.w	#$ff,scroll4		;   ""  ""   mountain     ""    ""
	move.w	#$ff,scroll5		;   ""  ""   small grass   ""    ""
	move.w	#$ff,scroll6		;   ""  ""   med    ""     ""    ""
	move.w	#$ff,scroll7		;   ""  ""   big    ""     ""    ""
	
	clr.b	Count_Cloud1		; Values for scroll flags
	clr.b	Count_Cloud2
	clr.b	Count_Cloud3
	clr.b	Count_Land
	clr.b	Count_Grass1
	clr.b	Count_Grass2
	clr.b	Count_Grass3

	clr.b	ItFlag			; Clear who's `it'
	clr.b	ItCount			; Clear `it' delay
	
	move.w	#$0ff0,NRG1Col		; Restore 1Up NRG to yellow
	move.w	#$0f00,NRG2Col		; Restore 2Up NRG to red

	move.w	#$0000,IT1Col		; Make this side invisible...
	move.w	#$0fff,IT2Col		; ...and this side visible

*****

; Load bitplanes...
	
Plane_Addresses				
	move.l	#clouds_1,d0		; Load Big clouds
	move.w	d0,Cl11ptl		
	swap	d0			
	move.w	d0,Cl11pth
	swap	d0
	add.l	#40*70,d0
	move.w	d0,Cl12ptl
	swap	d0
	move.w	d0,Cl12pth
	swap	d0	
	add.l	#40*70,d0
	move.w	d0,Cl13ptl
	swap	d0
	move.w	d0,Cl13pth
	swap	d0	 
			
	move.l	#clouds_2,d0		; Load med clouds
	move.w	d0,Cl21ptl
	swap	d0
	move.w	d0,Cl21pth
	swap	d0
	add.l	#40*56,d0
	move.w	d0,Cl22ptl
	swap	d0
	move.w	d0,Cl22pth
	swap	d0
	add.l	#40*56,d0
	move.w	d0,Cl23ptl
	swap	d0
	move.w	d0,Cl23pth
	swap	d0
					
	move.l	#Clouds_3,d0		; Load small clouds
	move.w	d0,Cl31ptl
	swap	d0
	move.w	d0,Cl31pth
	swap	d0
	add.l	#40*32,d0
	move.w	d0,Cl32ptl
	swap	d0
	move.w	d0,Cl32pth
	swap	d0
	add.l	#40*32,d0
	move.w	d0,Cl33ptl
	swap	d0
	move.w	d0,Cl33pth
	swap	d0

	move.l	#BlankBit,d0		; Load the bit in the middle
	move.w	d0,Bl1ptl
	swap	d0
	move.w	d0,Bl1pth
	swap	d0
	
	move.l	#Landscape,d0		; Load mountains
	move.w	d0,Lan1ptl
	swap	d0
	move.w	d0,Lan1pth
	swap	d0
	add.l	#40*160,d0
	move.w	d0,Lan2ptl
	swap	d0
	move.w	d0,Lan2pth
	swap	d0	
	add.l	#40*160,d0
	move.w	d0,Lan3ptl
	swap	d0
	move.w	d0,Lan3pth
	swap	d0	 
				
	move.l	#Grass_1,d0		; Load small grass
	move.w	d0,Gr11ptl
	swap	d0
	move.w	d0,Gr11pth
	swap	d0
	add.l	#40*16,d0
	move.w	d0,Gr12ptl
	swap	d0
	move.w	d0,Gr12pth
	swap	d0	

	move.l	#Grass_2,d0		; Load med grass
	move.w	d0,Gr21ptl
	swap	d0
	move.w	d0,Gr21pth
	swap	d0
	add.l	#40*20,d0
	move.w	d0,Gr22ptl
	swap	d0
	move.w	d0,Gr22pth
	swap	d0	

	move.l	#Grass_3,d0		; Load big grass
	move.w	d0,Gr31ptl	
	swap	d0
	move.w	d0,Gr31pth
	swap	d0
	add.l	#40*32,d0
	move.w	d0,Gr32ptl
	swap	d0
	move.w	d0,Gr32pth
	swap	d0	
	
	move.l	#NRGBar,d0		; Load NRG panel
	move.w	d0,NRG1ptl
	swap	d0
	move.w	d0,NRG1pth
	swap	d0
	add.l	#40*15,d0
	move.w	d0,NRG2ptl
	swap	d0
	move.w	d0,NRG2pth
	swap	d0

	move.l	#ITBar,d0		; Load IT panel
	move.w	d0,IT1ptl
	swap	d0
	move.w	d0,IT1pth
	swap	d0
	add.l	#40*10,d0
	move.w	d0,IT2ptl
	swap	d0
	move.w	d0,IT2pth
	swap	d0

	move.l	#SPLogo,d0		; Load the logo
	move.w	d0,Spl1l
	swap	d0
	move.w	d0,Spl1h
	swap	d0
	add.l	#40*26,d0
	move.w	d0,Spl2l
	swap	d0
	move.w	d0,Spl2h
	swap	d0
			
	move.l	#$da68e900,ShipA	; Initialise Vstart/stop, 
	move.l	#$da68e980,ShipB	; Hstart/stop, etc. for player
	move.l	#$daa8e900,Ship2A	; sprites.
	move.l	#$daa8e980,Ship2B	;
	
; Set up sprites...

; Sprites 2/3 (player 1)
	move.l	#ShipA,d0
	lea	Sprite,a0
	move.w	d0,20(a0)
	swap	d0
	move.w	d0,16(a0)
	
	move.l	#ShipB,d0
	move.w	d0,28(a0)
	swap	d0
	move.w	d0,24(a0)
		
; Sprites 0/1 (player 2)
	move.l	#Ship2A,d0
	move.w	d0,4(a0)
	swap	d0
	move.w	d0,(a0)
	
	move.l	#Ship2B,d0
	move.w	d0,12(a0)
	swap	d0
	move.w	d0,8(a0)

; Sprites 4/5 (junk)
	move.l	#Sprite4,d0		
	move.w	d0,36(a0)
	swap	d0
	move.w	d0,32(a0)
	swap	d0
	move.l	#Sprite5,d0
	move.w	d0,44(a0)
	swap	d0
	move.w	d0,40(a0)
	swap	d0

	rts

*******************

; Read joystick 1, this is a Treebeard routine (I think!)

JoyStick1
	movem.l	d0-d7/a0-a6,-(sp)	Yep - save all registers
	move.b	$dff00c,d0		get left/up movement for joystick
	beq.s	nolu			no l/u movement if it =0, so skip all l/u routine
	btst	#1,d0			bit 1 is set if it is going left or left and up
	beq.s	up			so if its clear, test for up
	bsr	Joy1Left
up	subq.b	#1,d0			take 1 from joystick position
	btst	#1,d0			now bit 1 is 0 if it is going up or up and left
	bne.s	nolu			if it ain't, go to right/down movement
	bsr	Joy1Up

nolu	move.b	$dff00d,d0		Get right/down position
	beq.s	over			if its 0, there's no movement so go away
	btst	#1,d0			bit 1 is set if joystick going right or right and down
	beq.s	down			so if its clear, test for down
	bsr	Joy1Right
	
down	subq.b	#1,d0			take 1 from r/d position
	btst	#1,d0			is bit 1 clear
	bne.s	over			No, then not going down, so quit
	bsr	Joy1Down
over	movem.l	(sp)+,d0-d7/a0-a6	old registers
	rts

****************************

*********

Joy1Right
	cmp.b	#MaxShipX,ShipA+1	; Are we at right edge of screen?
	bne.s	YesRight		; No, so move right
	rts
YesRight
	lea	ShipA,a0		; Move both sprites, 
	lea	ShipB,a1		; coz they're attached, silly!
	addi.b	#2,1(a0)		; Increase Hstart, ShipA
	addi.b	#2,1(a1)		; Increase Hstart, ShipB
	rts
	
*********
	
Joy1Left	
	cmp.b	#MinShipX,ShipA+1	; Are we at left edge of screen?
	bne.s	YesLeft			; No, so move left
	rts
YesLeft
	lea	ShipA,a0		; Move both sprites,
	lea	ShipB,a1		; coz they're attached, silly!
	subi.b	#2,1(a0)		; Decrease Hstart, ShipA		
	subi.b	#2,1(a1)		; Decrease Hstart, ShipB
	rts
	
*********
	
Joy1Down	
	cmp.b	#MaxShipY,ShipA		; Are we at bottom of screen?
	bne.s	YesDown			; No, so move down
	rts
YesDown
	lea	ShipA,a0		; Move both sprites,
	lea	ShipB,a1		; coz they're attached, silly!
	addi.b	#2,2(a0)		; Increase VStop, ShipA
	addi.b	#2,(a0)			; Increase VStart, ShipA
	addi.b	#2,2(a1)		; Increase VStop, ShipB
	addi.b	#2,(a1)			; Increase YStart, ShipB
	rts

*********

Joy1Up	
	cmp.b	#MinShipY,ShipA		; Are we at top of screen?
	bne.s	YesUp			; No, so move up
	rts
YesUp
	lea	ShipA,a0		; Move both sprites up,
	lea	ShipB,a1		; coz they're attached silly!
	subi.b	#2,2(a0)		; Decrease VStop, ShipA
	subi.b	#2,(a0)			; Decrease VStart, Shipa
	subi.b	#2,2(a1)		; Decrease VStop, ShipB
	subi.b	#2,(a1)			; Decrease VStart, ShipB
	rts
	
*********

; Read joystick 0
JoyStick0
	movem.l	d0-d7/a0-a6,-(sp)	Yep - save all registers
	move.b	$dff00a,d0		get left/up movement for joystick
	beq.s	nolu0			no l/u movement if it =0, so skip all l/u routine
	btst	#1,d0			bit 1 is set if it is going left or left and up
	beq.s	up0			so if its clear, test for up
	bsr	Joy0Left
up0	subq.b	#1,d0			take 1 from joystick position
	btst	#1,d0			now bit 1 is 0 if it is going up or up and left
	bne.s	nolu0			if it ain't, go to right/down movement
	bsr	Joy0Up

nolu0	move.b	$dff00b,d0		Get right/down position
	beq.s	over0			if its 0, there's no movement so go away
	btst	#1,d0			bit 1 is set if joystick going right or right and down
	beq.s	down0			so if its clear, test for down
	bsr	Joy0Right
	
down0	subq.b	#1,d0			take 1 from r/d position
	btst	#1,d0			is bit 1 clear
	bne.s	over0			No, then not going down, so quit
	bsr	Joy0Down
over0	movem.l	(sp)+,d0-d7/a0-a6	old registers
	rts

*********

Joy0Right
	cmp.b	#MaxShipX,Ship2A+1	; Are we at right edge of screen?
	bne.s	YesRight0		; No, so move right
	rts
YesRight0
	lea	Ship2A,a0		; Move both sprites, 
	lea	Ship2B,a1		; coz they're attached, silly!
	addi.b	#2,1(a0)		; Increase Hstart, ShipA
	addi.b	#2,1(a1)		; Increase Hstart, ShipB
	rts
	
*********
	
Joy0Left
	cmp.b	#MinShipX,Ship2A+1	; Are we at left edge of screen?
	bne.s	YesLeft0			; No, so move left
	rts
YesLeft0
	lea	Ship2A,a0		; Move both sprites,
	lea	Ship2B,a1		; coz they're attached, silly!
	subi.b	#2,1(a0)		; Decrease Hstart, ShipA		
	subi.b	#2,1(a1)		; Decrease Hstart, ShipB
	rts
	
*********
	
Joy0Down	
	cmp.b	#MaxShipY,Ship2A		; Are we at bottom of screen?
	bne.s	YesDown0			; No, so move down
	rts
YesDown0
	lea	Ship2A,a0		; Move both sprites,
	lea	Ship2B,a1		; coz they're attached, silly!
	addi.b	#2,2(a0)		; Increase VStop, ShipA
	addi.b	#2,(a0)			; Increase VStart, ShipA
	addi.b	#2,2(a1)		; Increase VStop, ShipB
	addi.b	#2,(a1)			; Increase YStart, ShipB
	rts

*********

Joy0Up	
	cmp.b	#MinShipY,Ship2A		; Are we at top of screen?
	bne.s	YesUp0			; No, so move up
	rts
YesUp0
	lea	Ship2A,a0		; Move both sprites up,
	lea	Ship2B,a1		; coz they're attached silly!
	subi.b	#2,2(a0)		; Decrease VStop, ShipA
	subi.b	#2,(a0)			; Decrease VStart, Shipa
	subi.b	#2,2(a1)		; Decrease VStop, ShipB
	subi.b	#2,(a1)			; Decrease VStart, ShipB
	rts
	
*********

DoFire					; Fire routine
	move.w	#$f00,ShipOutline	; Turn ship red
	rts

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* x	Collision checking routine (Mike Cross)				x
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
		
DoCollisions	moveq.l	#0,d0				* Ensure clear
		move.w	Clxdat(a5),d0			* Get collision
		bsr	ChkSp01ToSp23
		bsr	ChkSp01ToSp45			
		bsr	ChkSp23ToSp45
		rts

ChkSp01toSp23	move.w	d0,d1
		andi.w	#$200,d1
		beq	NoCollision2
		bne	YesCollShip2Ship
NoCollision2	rts

ChkSp01toSp45	move.w	d0,d1			* Save value
		andi.w	#$400,d1		* Check it!  
		beq	NoCollision1
		bne	YesCollShip2Aliens

NoCollision1	rts

ChkSp23toSp45	move.w	d0,d1
		andi.w	#$1000,d1
		beq	NoCollision3
		bne	YesCollShip1Aliens

NoCollision3	rts

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

********************

YesCollShip2Ship
	add.b	#1,ItCount		; There is a delay before the
	cmp.b	#8,ItCount		; IT flag is changed, or else
	beq.s	SwapIT			; it is too fast.
	rts
	
SwapIT
	move.b	#0,ItCount		; Clear the delay counter
	cmpi.b	#1,ITFlag		; Was player one it?
	beq.s	P2IsIT			; Yep, so now player two is!
	move.w	#$0fff,IT1Col		; Swap the colours round
	move.w	#$0000,IT2Col
	move.b	#1,ITFlag		; Player one is it next
	rts
	
P2IsIT
	move.w	#$0fff,IT2Col		; Swap the colours around
	move.w	#$0000,IT1Col	
	move.b	#0,ITFlag		; Player two is it next
	rts

***************

YesCollShip1Aliens
	add.b	#1,NRGCount1		; Again, there is a delay to slow
	cmp.b	#12,NRGCount1		; down the decrease rate
	beq.s	DecreaseNrg1
	rts
	
DecreaseNRG1
	move.b	#0,NRGCount1		; Clear delay counter
	sub.w	#$0110,NRG1Col		; Decrease player 1's NRG colour
	rts
	
****************


YesCollShip2Aliens
	add.b	#1,NRGCount2
	cmp.b	#12,NRGCount2
	beq.s	DecreaseNrg2
	rts
	
DecreaseNRG2
	move.b	#0,NRGCount2		; Clear delay counter
	sub.w	#$0100,NRG2Col		; Decrease player 2's NRG colour
	rts
		
*****************************

; This is the scroll routine, by FM...

scroll_1
	moveq	#3,d4			; Repeat 4 times a frame
loop1
	move.w	scroll1,d0		;IS SCROLL VALUE=0
	cmp.w	#$00,d0			;
	beq	reset			;YES INC BP POINTERS
	subi.w	#$11,scroll1		;ELSE SUBTRACT 1
	dbra	d4,loop1
	rts
reset					
	lea	scroll1,a0		;REPLACE SCROLL VALUE TO 
	move.w	#$ff,(a0)		;15
	add.b	#1,Count_Cloud1	
	cmp.b	#20,Count_Cloud1	;IS FLAG =20
	beq	swap_planes		;YES RESET BP POINTERS TO START
	addi.w	#2,Cl11ptl		;ELSE ADD 2 TO BP POINTERS
	addi.w	#2,Cl12ptl
	addi.w	#2,Cl13ptl
	rts
swap_planes
	move.b	#0,Count_Cloud1	;CLEAR FLAG
	move.l	#clouds_1,d0		;RESET BP POINTERS TO START
	move.w	d0,Cl11ptl
	swap	d0
	move.w	d0,Cl11pth
	swap	d0
	add.l	#40*70,d0
	move.w	d0,Cl12ptl
	swap	d0
	move.w	d0,Cl12pth
	swap	d0
	add.l	#40*70,d0
	move.w	d0,Cl13ptl
	swap	d0
	move.w	d0,Cl13pth
	swap	d0
	rts

**********

scroll_2	
	moveq	#1,d4			; Repeat twice a frame
loop2
	move.w	scroll2,d0
	cmp.w	#$00,d0
	beq	reset_scroll2
	sub.w	#$11,scroll2
	dbra	d4,loop2
	rts
reset_scroll2
	lea	scroll2,a0
	move.w	#$ff,(a0)
	add.b	#1,Count_Cloud2
	cmp.b	#20,Count_Cloud2
	beq	swap_planes_scroll2
	addi.w	#2,Cl21ptl
	addi.w	#2,Cl22ptl
	addi.w	#2,Cl23ptl
	rts
swap_planes_scroll2
	move.b	#0,Count_Cloud2
	move.l	#clouds_2,d0
	move.w	d0,Cl21ptl
	swap	d0
	move.w	d0,Cl21pth
	swap	d0
	add.l	#40*56,d0
	move.w	d0,Cl22ptl
	swap	d0
	move.w	d0,Cl22pth
	swap	d0
	add.l	#40*56,d0
	move.w	d0,Cl23ptl
	swap	d0
	move.w	d0,Cl23pth
	swap	d0
	rts

**********

scroll_3
	add.b	#1,Cloud3_VBL		; ONLY SCROLLED EVERY OTHER FRAME
	cmp.b	#1,Cloud3_VBL
	beq	Every_Other
	rts
Every_Other
	move.b	#0,Cloud3_VBL
	move.w	scroll3,d0
	cmp.w	#$00,d0
	beq	reset_scroll3
	sub.w	#$11,scroll3
	rts
reset_scroll3
	lea	scroll3,a0
	move.w	#$ff,(a0)
	add.b	#1,Count_Cloud3
	cmp.b	#20,Count_Cloud3
	beq	swap_planes_scroll3
	addi.w	#2,Cl31ptl
	addi.w	#2,Cl32ptl
	addi.w	#2,Cl33ptl
	rts
swap_planes_scroll3
	move.b	#0,Count_Cloud3
	move.l	#clouds_3,d0
	move.w	d0,Cl31ptl
	swap	d0
	move.w	d0,Cl31pth
	swap	d0
	add.l	#40*32,d0
	move.w	d0,Cl32ptl
	swap	d0
	move.w	d0,Cl32pth
	swap	d0
	add.l	#40*32,d0
	move.w	d0,Cl33ptl
	swap	d0
	move.w	d0,Cl33pth
	swap	d0
	rts

**********

scroll_4
	add.b	#1,Land_VBL		; Once every 3 frames
	cmp.b	#2,Land_VBL
	beq	Every_Other2
	rts
Every_Other2
	move.b	#0,Land_VBL
	move.w	scroll4,d0
	cmp.w	#$00,d0
	beq	reset_scroll4
	sub.w	#$11,scroll4
	rts
reset_scroll4
	lea	scroll4,a0
	move.w	#$ff,(a0)
	add.b	#1,Count_Land
	cmp.b	#20,Count_Land
	beq	swap_planes_scroll4
	addi.w	#2,Lan1ptl
	addi.w	#2,Lan2ptl
	addi.w	#2,Lan3ptl
	rts
swap_planes_scroll4
	move.b	#0,Count_Land
	move.l	#Landscape,d0
	move.w	d0,Lan1ptl
	swap	d0
	move.w	d0,Lan1pth
	swap	d0
	add.l	#40*160,d0
	move.w	d0,Lan2ptl
	swap	d0
	move.w	d0,Lan2pth
	swap	d0
	add.l	#40*160,d0
	move.w	d0,Lan3ptl
	swap	d0
	move.w	d0,Lan3pth
	swap	d0
	rts

**********

scroll_5
	add.b	#1,Grass1_VBL			; Every other frame
	cmp.b	#1,Grass1_VBL			
	beq	Every_Other3			
	rts
Every_Other3
	move.b	#0,Grass1_VBL
	move.w	scroll5,d0
	cmp.w	#$00,d0
	beq	reset_scroll5
	sub.w	#$11,scroll5
	rts
reset_scroll5
	lea	scroll5,a0
	move.w	#$ff,(a0)
	add.b	#1,Count_Grass1
	cmp.b	#20,Count_Grass1
	beq	swap_planes_scroll5
	addi.w	#2,Gr11ptl
	addi.w	#2,Gr12ptl
	rts
swap_planes_scroll5
	move.b	#0,Count_Grass1
	move.l	#Grass_1,d0
	move.w	d0,Gr11ptl
	swap	d0
	move.w	d0,Gr11pth
	swap	d0
	add.l	#40*16,d0
	move.w	d0,Gr12ptl
	swap	d0
	move.w	d0,Gr12pth
	swap	d0
	rts
	
**********

scroll_6
	moveq	#1,d4			; Repeat twice a frame
loop6
	move.w	scroll6,d0
	cmp.w	#$00,d0
	beq	reset_scroll6
	sub.w	#$11,scroll6
	dbra	d4,loop6
	rts
reset_scroll6
	lea	scroll6,a0
	move.w	#$ff,(a0)
	add.b	#1,Count_Grass2
	cmp.b	#20,Count_Grass2
	beq	swap_planes_scroll6
	addi.w	#2,Gr21ptl
	addi.w	#2,Gr22ptl
	rts
swap_planes_scroll6
	move.b	#0,Count_Grass2
	move.l	#Grass_2,d0
	move.w	d0,Gr21ptl
	swap	d0
	move.w	d0,Gr21pth
	swap	d0
	add.l	#40*20,d0
	move.w	d0,Gr22ptl
	swap	d0
	move.w	d0,Gr22pth
	swap	d0
	rts
	
**********

scroll_7
	moveq	#3,d4			; Repeat four times a frame
loop7
	move.w	scroll7,d0
	cmp.w	#$00,d0
	beq	reset_scroll7
	sub.w	#$11,scroll7
	dbra	d4,loop7
	rts
reset_scroll7
	lea	scroll7,a0
	move.w	#$ff,(a0)
	add.b	#1,Count_Grass3
	cmp.b	#20,Count_Grass3
	beq	swap_planes_scroll7
	addi.w	#2,Gr31ptl
	addi.w	#2,Gr32ptl
	rts
swap_planes_scroll7
	move.b	#0,Count_Grass3
	move.l	#Grass_3,d0
	move.w	d0,Gr31ptl
	swap	d0
	move.w	d0,Gr31pth
	swap	d0
	add.l	#40*32,d0
	move.w	d0,Gr32ptl
	swap	d0
	move.w	d0,Gr32pth
	swap	d0
	rts
	
**********
	
; Re-use sprite channels 4 & 5 (attached)
; for the junk sprites. Another FM routine.
 
Sprites_45				
	lea	sprite,a0		; CONTROL WORDS
	move.l	#Sprite4,d0		; ADDRESS
	move.w	d0,36(a0)		; AND UPDATE COPPER
	swap	d0
	move.w	d0,32(a0)
	swap	d0	
	move.l	#Sprite5,d0		; SAME FOR SPRITE 5
	lea	8(a0),a0		; INC PAST SP 5 CONTROL WORDS
	move.w	d0,44(a0)		; UPDATE COPPER
	swap	d0
	move.w	d0,40(a0)
	swap	d0	
	move.l	#Sprite4,a0		; A0=SPRITE 4 ADDRESS
	move.l	#Sprite5,a1		; A1=SPRITE 5 ADDRESS
	move.w	#9,d7			; NO OF SPRITES-1
	lea	Speeds1,a3		; Load Speeds into a3
Move
	move.b	(a3)+,d3		; Move speed into d3
	sub.b	d3,1(a0)		; Add Speed to horiz. control byte
	sub.b	d3,1(a1)		; SAME FOR SPRITE 5
	add.l	#68,a0			; LOCATE NEXT PAIR OF CO-ORDINATES
	add.l	#68,a1			; "    "
	dbf	d7,Move			; DECREMENT AND BRANCH WHEN =0
	rts

*************************

; Do the lame equaliser bars

flashtest1:
	cmpi.w	#0,mt_voice1		; Any noise from channel 1?
	bgt	FlashCh1		; If so, flash it!

	cmpi.w	#$0,Ch1			; Is the color black?
	bne	FadeCh1			; No, so fade it down
	rts
	
FadeCh1:
	sub.w	#$1,Ch1			; Fade Bar colour
	rts

FlashCh1:
	move.w	#$f,Ch1			; Put colour to blue
	rts

**********
	
flashtest2:
	cmpi.w	#0,mt_voice2
	bgt	FlashCh2

	cmpi.w	#0,Ch2
	bne	FadeCh2
	rts

FadeCh2:
	sub.w	#$1,Ch2
	rts	

FlashCh2:
	move.w	#$f,Ch2
	rts

**********
	
flashtest3:
	cmpi.w	#0,mt_voice3
	bgt	FlashCh3
	
	cmpi.w	#0,Ch3
	bne	FadeCh3
	rts
	
FadeCh3:
	sub.w	#$1,Ch3
	rts

FlashCh3:
	move.w	#$f,Ch3
	rts

**********	

flashtest4:
	cmpi.w	#0,mt_voice4
	bgt	FlashCh4

	cmpi.w	#0,Ch4
	bne	FadeCh4
	rts

FadeCh4:
	sub.w	#$1,Ch4
	rts	

	
FlashCh4:
	move.w	#$f,Ch4
	rts

******************************

; Initialise the screen for the end sequence

GameOverSetUp
	move.l	_gfxbase,a0		; LOAD ADDRESS OF GRAPHICS LIB IN A0
	move.l	#GameOverCop,50(a0)	; Load in our list

	bsr	ClearBlank		; Blit clear the text area
	move.l	#BackGnd,d0		; Load the `SP' background
	move.w	d0,Back1l
	swap	d0
	move.w	d0,Back1h
	swap	d0
	add.l	#8000,d0
	move.w	d0,Back3l
	swap	d0
	move.w	d0,Back3h
	swap	d0
	
	move.l	#ScrollPl,d0		; Fill in the blank spaces
	move.w	d0,Blankl
	move.w	d0,Blank2l
	move.w	d0,Blank3l
	swap	d0
	move.w	d0,Blankh
	move.w	d0,Blank2h
	move.w	d0,Blank3h
	swap	d0
	
	move.l	#GameOver,d0		; Load in the Panic Over logo
	move.w	d0,TopTex1l	
	swap	d0
	move.w	d0,TopTex1h
	swap	d0
	rts

*****************************

ClearBlank:

; Let's blit clear the text area!

	lea Scrollpl,a0			; address of text
blitready:
	btst #14,$dff002		
	bne.s blitready			; wait till blitter ready

	move.l a0,$dff054		; source address
	move.l a0,$dff050		; destination address
	clr.l $dff044			; no FWM/LWM (see hardware manual)
	clr.l $dff064			; no MODULO (see hardware manual)

	move.w #%100000000,$dff040 	; Enable DMA channel D, nothing
					; else, no minterms active. 
	clr.w $dff042			; nothing set in BLTCON1
	move.w #200*64+20,$dff058
					; Window size = 20 words wide
					; 200 lines deep
	rts

******************************

; Routine to play around with the Panic Over colours,
; author unknown.

movecop		tst.w	count
		beq.s	doit
		sub.w	#1,count
		bra	donemovin
doit		move.w	#topcount,count
		move.l	barptr,a3
		move.l	#bar+6,a0
		move.w	#nobars-1,d0
Coloop		move.l	barptr,a1
		move.w	#barwidth-1,d4
		move.l	a1,a2
cpuloop		cmp.w	#$ffff,(a2)
		bne.s	gotit
		move.l	#barcols,a2
gotit		move.w	(a2)+,(a0)
		add.l	#8,a0
		dbra	d4,cpuloop
		cmp.w	#$ffff,(a1)+
		bne.s	notend1
		move.l	#barcols,a1
notend1		move.l	a1,barptr
		dbra	d0,Coloop
		cmp.w	#$ffff,(a3)+
		bne.s	notend
		move.l	#barcols,a3
notend		move.l	a3,barptr
donemovin	rts


topcount	equ	2000
barwidth	equ	32
linewidth	equ	1
nobars		equ	18


count		dc.w	topcount
barptr		dc.l	barcols
barcols	
 DC.W $000F,$011F,$022F,$033F,$044F,$055F,$066F,$077F,$088F,$099F
 DC.W $0AAF,$0BBF,$0CCF,$0DDF,$0EEF,$0EEF,$0FFF,$0FFE,$0FFD,$0FFC
 DC.W $0FFB,$0FFA,$0FF9,$0FF8,$0FF7,$0FF6,$0FF5,$0FF4,$0FF3,$0FF2
 DC.W $0FF1,$0FF1,$0FF0,$0EF0,$0DF0,$0CF0,$0BF0,$0AF0,$09F0,$08F0
 DC.W $07F0,$06F0,$05F0,$04F0,$03F0,$02F0,$01F0,$01F0,$00F0,$01E0
 DC.W $02D0,$03C0,$04B0,$05A0,$0690,$0780,$0870,$0960,$0A50,$0B40
 DC.W $0C30,$0D20,$0E10,$0E10,$0F00,$0F01,$0F02,$0F03,$0F04,$0F05
 DC.W $0F06,$0F07,$0F08,$0F09,$0F0A,$0F0B,$0F0C,$0F0D,$0F0E,$0F0E
 DC.W $0F0F,$0E0F,$0D0F,$0C0F,$0B0F,$0A0F,$090F,$080F,$070F,$060F
 DC.W $050F,$040F,$030F,$020F,$010F,$010F,$000F
		dc.w	$ffff
	
******************************
	
	SECTION	ElloElloEllo,data_c	

; Copper, geddit?

Newcop

Clouds1
	dc.w	Dmacon,%1000001000100000
	dc.w	Bplcon0,%0011001000000000	; 3 Bitplanes
	dc.w	Bplcon1
scroll1	dc.w	$0000				; Scroll Value for Clouds1 
	dc.w	Bplcon2,%0000000000100100
	dc.w	Bpl1mod,$0024,Bpl2mod,$0024	; Modulos for wider screen
	dc.w	Ddfstrt,$0030,Ddfstop,$00d8	
	dc.w	Diwstrt,$2781,Diwstop,$38c1	
	
	dc.w	Bpl1pth				; Bitplane Pointers
Cl11pth	dc.w	$0000,Bpl1ptl
Cl11ptl	dc.w	$0000,Bpl2pth
Cl12pth	dc.w	$0000,Bpl2ptl
Cl12ptl	dc.w	$0000,Bpl3pth
Cl13pth	dc.w	$0000,Bpl3ptl
Cl13ptl	dc.w	$0000

	dc.w	Spr0pth				; Sprite pointers
Sprite	dc.w	$0000,Spr0ptl,$0000,Spr1pth
	dc.w	$0000,Spr1ptl,$0000,Spr2pth
	dc.w	$0000,Spr2ptl,$0000,Spr3pth
	dc.w	$0000,Spr3ptl,$0000,Spr4pth
	dc.w	$0000,Spr4ptl,$0000,Spr5pth
	dc.w	$0000,Spr5ptl,$0000

; Load in the funky Cloud colours!

	dc.w	$0180,$0000,$0182,$0ff8,$0184,$0777,$0186,$0888
	dc.w	$0188,$0999,$018a,$0bbb,$018c,$0ccc,$018e,$0ddd
	dc.w	$0180,$0000,$0182,$0ff8


; Load in those Sprite Colours!

	dc.w	$01a2
ShipOutline
	dc.w	$0000			; Colour of Ship outline...
	dc.w	$01a4,$055f,$01a6,$0ff0
	dc.w	$01a8,$0aa0,$01aa,$0f0f,$01ac,$0a08,$01ae,$0aaf
	dc.w	$01b0,$0fff,$01b2,$0030,$01b4,$0060,$01b6,$0f00
	dc.w	$01b8,$0a00,$01ba,$0bbb,$01bc,$0777,$01be,$0f80

	dc.w	$3a01,$fffe,$182,$fe8
***********

Clouds2
	dc.w	$4a01,$ff00
	dc.w	Bplcon0,%0011001000000000	; 3 Bitplanes		
	dc.w	Bplcon1
scroll2	dc.w	$0000				; Scroll Value for Clouds2


	dc.w	Bpl1pth				; Bitplane Pointers
Cl21pth	dc.w	$0000,Bpl1ptl
Cl21ptl	dc.w	$0000,Bpl2pth
Cl22pth	dc.w	$0000,Bpl2ptl
Cl22ptl	dc.w	$0000,Bpl3pth
Cl23pth	dc.w	$0000,Bpl3ptl
Cl23ptl	dc.w	$0000

	dc.w	$182,$fd8

	dc.w	$5a01,$fffe,$182,$fc8
	dc.w	$180
Ch1	dc.w	$f

***********

Clouds3
	dc.w	$6601,$ff00
	dc.w	Bplcon0,%0011001000000000	; 3 Bitplanes	
	dc.w	Bplcon1
scroll3	dc.w	$0000				; Scroll Value for Clouds3


	dc.w	Bpl1pth				; Bitplane Pointers
Cl31pth	dc.w	$0000,Bpl1ptl
Cl31ptl	dc.w	$0000,Bpl2pth
Cl32pth	dc.w	$0000,Bpl2ptl
Cl32ptl	dc.w	$0000,Bpl3pth
Cl33pth	dc.w	$0000,Bpl3ptl
Cl33ptl	dc.w	$0000

	dc.w	$6a01,$fffe,$182,$fb8
	dc.w	$180,$0000
	
; Urghh! A messy bit! I needed a blank space, but still had to have 
; at least one bitplane on for the sprites to be seen, so a blank 
; block of binary has to be shoved in here...

	dc.w	$7601,$fffe,Bplcon0,$1200
	dc.w	Bplcon1,$0000
	dc.w	Bpl1pth
Bl1pth	dc.w	$0000,Bpl1ptl
Bl1ptl	dc.w	$0000

	dc.w	$7a01,$fffe,$182,$fa8
	dc.w	$180
Ch2	dc.w	$f
	dc.w	$8a01,$fffe,$182,$f98
	dc.w	$180,$0000
***********

Landscene

	dc.w	$8e01,$ff00
	dc.w	Bplcon0,%0011001000000000	; 3 Bitplanes		
	dc.w	Bplcon1
scroll4	dc.w	$0000				; Scroll Value for Landscape


	dc.w	Bpl1pth				; Bitplane Pointers
Lan1pth	dc.w	$0000,Bpl1ptl
Lan1ptl	dc.w	$0000,Bpl2pth
Lan2pth	dc.w	$0000,Bpl2ptl
Lan2ptl	dc.w	$0000,Bpl3pth
Lan3pth	dc.w	$0000,Bpl3ptl
Lan3ptl	dc.w	$0000

; Right sir, just load in the landscape colours here if you don't mind:

	dc.w	$0184,$0521,$0186,$0622
	dc.w	$0188,$0733,$018a,$0844,$018c,$0956,$018e,$0a56

	dc.w	$9a01,$fffe,$182,$f88
	dc.w	$180
Ch3	dc.w	$f
	dc.w	$aa01,$fffe,$182,$f78
	dc.w	$180,$0000
	dc.w	$ba01,$fffe,$182,$f68
	dc.w	$180
Ch4	dc.w	$f
	dc.w	$ca01,$fffe,$180,$0000
	
***********

Grass1

	dc.w	$de01,$ff00

	dc.w	Bplcon0,%0010001000000000	; 2 Bitplanes	
	dc.w	Bplcon1
scroll5	dc.w	$0000			; Scroll Value for Grass1


	dc.w	Bpl1pth			; Bitplane Pointers
Gr11pth	dc.w	$0000,Bpl1ptl
Gr11ptl	dc.w	$0000,Bpl2pth
Gr12pth	dc.w	$0000,Bpl2ptl
Gr12ptl	dc.w	$0000

; Load the grass-like colours my friends

	dc.w	$0182,$3a3,$0184,$03b3,$0186,$03c3
			
***********

Grass2

	dc.w	$e601,$ff00

	dc.w	Bplcon0,%0010001000000000	; 2 Bitplanes		
	dc.w	Bplcon1
scroll6	dc.w	$0000			; Scroll Value of Grass2


	dc.w	Bpl1pth			; Bitplane Pointers
Gr21pth	dc.w	$0000,Bpl1ptl
Gr21ptl	dc.w	$0000,Bpl2pth
Gr22pth	dc.w	$0000,Bpl2ptl
Gr22ptl	dc.w	$0000

	dc.w	$0182,$282,$0184,$0292,$0186,$02a2
	
***********

Grass3

	dc.w	$ee01,$ff00

	dc.w	Bplcon0,%0010001000000000	; 2 Bitplanes	
	dc.w	Bplcon1
scroll7	dc.w	$0000			; Scroll Value of Grass3


	dc.w	Bpl1pth			; Bitplane Pointers
Gr31pth	dc.w	$0000,Bpl1ptl
Gr31ptl	dc.w	$0000,Bpl2pth
Gr32pth	dc.w	$0000,Bpl2ptl
Gr32ptl	dc.w	$0000

	dc.w	$0182,$0171,$0184,$0181,$0186,$0191

	dc.w	$fd01,$fffe,Bplcon0,$0200
	
	dc.w	$ffe1,$fffe

	dc.w	Bplcon0,$2200,Bplcon1,$0000
	dc.w	Ddfstrt,$38,Ddfstop,$d0
	dc.w	Bpl1mod,0,Bpl2mod,0
	
	dc.w	Bpl1pth
NRG1pth dc.w	$0000,Bpl1ptl
NRG1ptl	dc.w	$0000,Bpl2pth
NRG2pth	dc.w	$0000,Bpl2ptl
NRG2ptl	dc.w	$0000
	
	dc.w	$184,$0fff,$186,$0fff
	dc.w	$0101,$fffe
	
	dc.w	$0180,$0000,$0182,$0eca,$0184
NRG2Col	dc.w	$0f00,$0186
NRG1Col	dc.w	$0ff0
	
	dc.w	$0e01,$fffe,$184,$0fff,$186,$0fff
	dc.w	$0f01,$fffe,Bplcon0,$0200

	dc.w	$1101,$fffe,Bplcon0,$2200
	dc.w	Bpl1pth
IT1pth	dc.w	$0000,Bpl1ptl
IT1ptl	dc.w	$0000,Bpl2pth
IT2pth	dc.w	$0000,Bpl2ptl
IT2ptl	dc.w	$0000

	dc.w	$0180,$0000,$0182,$0000,$0184
IT1Col	dc.w	$0000,$0186
IT2Col	dc.w	$0fff

	dc.w	$1a01,$fffe,Bplcon0,$0200
	dc.w	$1b01,$fffe,Bplcon0,$2200
	dc.w	Bpl1pth
SPl1h	dc.w	$0000,Bpl1ptl
Spl1l	dc.w	$0000,Bpl2pth
Spl2h	dc.w	$0000,Bpl2ptl
Spl2l	dc.w	$0000

	dc.w	$0180,$0000,$0182,$0fff,$0184,$0aaf,$0186,$055f	

	dc.w	$ffff,$fffe		; Wait for the impossible...
	
					; ...Like Man Ure winning
					; the League!    
					;    ( Hi Leon! ;-) )

***********************

; Copper list for title

TitleCop:

	dc.w	Bplcon0,%0011011000000000	; 3 Bitplanes, Dual P
	dc.w	Bplcon2,%0000000001000000
	dc.w	Bpl1mod,$0000,Bpl2mod,$0000	 
	dc.w	Ddfstrt,$0038,Ddfstop,$00d0	 
	dc.w	Diwstrt,$2c81,Diwstop,$2cc1	

	dc.w	$0180,$0000,$0182,$0454,$0184,$0343,$0186,$0232
	dc.w	$0190,$0000,$0192,$0fff
	
	dc.w	Bpl1pth				; Bitplane Pointers
Title1h	dc.w	$0000,Bpl1ptl
Title1l	dc.w	$0000,Bpl2pth
Scrollh	dc.w	$0000,Bpl2ptl
Scrolll	dc.w	$0000,Bpl3pth
Title3h	dc.w	$0000,Bpl3ptl
Title3l	dc.w	$0000


	dc.w	Spr0pth,$0000,Spr0ptl,$0000

	dc.w	$f301,$fffe,Bplcon0,$0200
	dc.w	$ffe1,$fffe
	dc.w	$10e1,$fffe,Bplcon0,$1200
	dc.w	Bpl1pth
SConth	dc.w	$0000,Bpl1ptl
Scontl	dc.w	$0000
	dc.w	$182,$0fff

	dc.w	$1901,$fffe,Bplcon0,$0200

	dc.w	$ffff,$fffe

**********************

; Copper list for game over...

GameOverCop:

	dc.w	Bplcon0,%0011011000000000	; 3 Bitplanes
	dc.w	Bplcon2,%0000000001000000
	dc.w	Bpl1mod,$0000,Bpl2mod,$0000	
	dc.w	Spr0pth,$0000,Spr0ptl,$0000	; Pointer Off
	dc.w	Ddfstrt,$0038,Ddfstop,$00d0	
	dc.w	Diwstrt,$2c81,Diwstop,$2cc1	

	dc.w	$0180,$0000,$0182,$0454,$0184,$0343,$0186,$0232
	dc.w	$0190,$0000,$0192,$0fff
	
	dc.w	Bpl1pth				; Bitplane Pointers
Back1h	dc.w	$0000,Bpl1ptl
Back1l	dc.w	$0000,Bpl2pth
Blankh	dc.w	$0000,Bpl2ptl
Blankl	dc.w	$0000,Bpl3pth
Back3h	dc.w	$0000,Bpl3ptl
Back3l	dc.w	$0000


	dc.w	$5401,$fffe
	dc.w	Bpl2pth
TopTex1h	dc.w	$0000,Bpl2ptl
TopTex1l	dc.w	$0000
bar		ds.w	4*barwidth*nobars
		dc.w	$0192,0	

	dc.w	$7401,$fffe
	dc.w	Bpl2pth
Blank2h	dc.w	$0000,Bpl2ptl
Blank2l	dc.w	$0000
	dc.w	$0192,$0fff
	dc.w	$9001,$fffe
	dc.w	Bpl2pth
Winnerh	dc.w	$0000,Bpl2ptl
Winnerl	dc.w	$0000

	dc.w	$c401,$fffe,Bpl2pth
Blank3h	dc.w	$0000,Bpl2ptl
Blank3l	dc.w	$0000 

	dc.w	$f301,$fffe,Bplcon0,$0200
	dc.w	$ffe1,$fffe
	dc.w	$10e1,$fffe,Bplcon0,$1200
	dc.w	Bpl1pth
FConth	dc.w	$0000,Bpl1ptl
Fcontl	dc.w	$0000
	dc.w	$182,$0fff
	dc.w	$2501,$fffe,Bplcon0,$0200
	
	dc.w	$ffff,$fffe

*************************************

; Ye olde inclusione of ye Binariesesiesis....

Clouds_1		incbin	source:bitmaps/clouds1
Clouds_2		incbin	source:bitmaps/clouds2
Clouds_3		incbin	source:bitmaps/clouds3
Landscape		incbin	source:bitmaps/landscape1
Grass_1			incbin	source:bitmaps/grass2
Grass_2			incbin 	source:bitmaps/grass1
Grass_3			incbin  source:bitmaps/grass3
NRGBar			incbin  source:bitmaps/NRGPanel
BackGnd			incbin  source:bitmaps/Infoback.raw
ITBar			incbin  source:bitmaps/IT!.raw
SPLogo			incbin  source:bitmaps/smallsplogo.raw

GameOver		incbin	source:bitmaps/PanicOver.raw
Win1			incbin	source:bitmaps/winplay1.raw
Win2			incbin	source:bitmaps/winplay2.raw
SpaceCont		incbin	source:bitmaps/Barcont.raw
FireCont		incbin	source:bitmaps/Firecont.raw

Font			incbin	source:bitmaps/Nice8x8font
ScrollPl		dcb.b	8000,0

mt_data 		incbin df1:Modules/spacepanicextra

*************************************

; Data Declaration Area

gfxlib	dc.b	"graphics.library",0	
	even
_gfxbase	dc.l	0			; Graphics Lib. Address
oldcop		dc.l	0			; Old Copperlist address
DMASave		dc.w	0


Count_Cloud1		dc.b	0		;} Flags controlling
Count_Cloud2		dc.b	0		;} how far each layer has
Count_Cloud3		dc.b	0		;} moved.
Count_Land		dc.b	0		;}
Count_Grass1		dc.b	0		;}
Count_Grass2		dc.b	0		;}
Count_Grass3		dc.b	0		;}

Cloud3_VBL		dc.b	0		;} Flags for the speed
Land_VBL		dc.b	0		;} of these layers.
Grass1_VBL		dc.b	0		;}

NRGCount1		dc.b	0
NRGCount2		dc.b	0

ItFlag			dc.b	0
ItCount			dc.b	0

GameLength		dc.w	0

HCOUNT		DC.W	0
STRTPOS		DC.L	0
LINESTRT	DC.L	0

**********

; The Intro text....

*	REMEMBER: SMALL FUNCTION CHARS WILL APPEAR AS SPACES ON SCREEN.

*	COMMANDS: 
*			'x' --> END TEXT
*	ENTER ALL TEXT IN CAPITALS!
**********

* TEXT WIDTH:	' 1234567890123456789012345678901234567  '
* 20 Lines, leave first one blank!

TEXT	

	dc.b	"                                        "
	dc.b	"              INSTRUCTIONS              "
	DC.B	"             --------------             "
	DC.B	"                                        "
	DC.B	" + PLAYER ONE HAS SHIP WITH YELLOW TOP  "
	DC.B	"   PLAYER TWO HAS A RED TOP.            "
	DC.B	"                                        "
	DC.B	" + EACH GAME LASTS ABOUT TWO MINUTES.   "
	DC.B	"                                        "
	DC.B	" + HITTING ANY OF THE SPACE JUNK WILL   "
	DC.B	"   LOSE SOME ENERGY.                    "
	DC.B	"                                        "
	DC.B	" + IF, AFTER 2 MINUTES, BOTH SHIPS ARE  "
	DC.B	"   STILL IN, THE PLAYER WHO ISN'T 'IT'  "
	DC.B	"   IS THE WINNER.                       "
	DC.B	"                                        "
	DC.B	" + A PLAYER BECOMES 'IT' BY BEING HIT   "
	DC.B	"   BY THE OTHER PLAYER'S SHIP.          "
	DC.B	"                                        "
	DC.B	"                                       x"

	EVEN
	
*****************


;­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­
;­     NoisetrackerV2.0 FASTreplay      ­
;­  Uses lev6irq - takes 8 rasterlines  ­
;­ Do not disable Master irq in $dff09a ­
;­ Used registers: d0-d3/a0-a7|	=INTENA ­
;­  Mahoney & Kaktus - (C) E.A.S. 1990  ­
;­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­

mt_init:lea	mt_data,a0
	lea	mt_mulu(pc),a1
	move.l	#mt_data+$c,d0
	moveq	#$1f,d1
	moveq	#$1e,d3
mt_lop4:move.l	d0,(a1)+
	add.l	d3,d0
	dbf	d1,mt_lop4

	lea	$3b8(a0),a1
	moveq	#$7f,d0
	moveq	#0,d1
	moveq	#0,d2
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop:	dbf	d0,mt_lop2
	addq.w	#1,d2

	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts(pc),a1
	add.w	#$2a,a0
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.b	d1,2(a0)
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbf	d0,mt_lop3

	move.l	$78.w,mt_oldirq-mt_samplestarts-$7c(a1)
	or.b	#2,$bfe001
	move.b	#6,mt_speed-mt_samplestarts-$7c(a1)
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.b	d0,mt_songpos-mt_samplestarts-$7c(a1)
	move.b	d0,mt_counter-mt_samplestarts-$7c(a1)
	move.w	d0,mt_pattpos-mt_samplestarts-$7c(a1)
	rts


mt_end:	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$dff096
	rts


mt_music:
	lea	mt_data,a0
	lea	mt_voice1(pc),a4
	addq.b	#1,mt_counter-mt_voice1(a4)
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blt	mt_nonew
	moveq	#0,d0
	move.b	d0,mt_counter-mt_voice1(a4)
	move.w	d0,mt_dmacon-mt_voice1(a4)
	lea	mt_data,a0
	lea	$3b8(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	lsl.w	#8,d1
	lsl.w	#2,d1
	add.w	mt_pattpos(pc),d1

	lea	$dff0a0,a5
	lea	mt_samplestarts-4(pc),a1
	lea	mt_playvoice(pc),a6
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a4
	jsr	(a6)

	move.w	mt_dmacon(pc),d0
	beq.s	mt_nodma

	lea	$bfd000,a3
	move.b	#$7f,$d00(a3)
	move.w	#$2000,$dff09c
	move.w	#$a000,$dff09a
	move.l	#mt_irq1,$78.w
	moveq	#0,d0
	move.b	d0,$e00(a3)
	move.b	#$a8,$400(a3)
	move.b	d0,$500(a3)
	or.w	#$8000,mt_dmacon-mt_voice4(a4)
	move.b	#$11,$e00(a3)
	move.b	#$81,$d00(a3)

mt_nodma:
	add.w	#$10,mt_pattpos-mt_voice4(a4)
	cmp.w	#$400,mt_pattpos-mt_voice4(a4)
	bne.s	mt_exit
mt_next:clr.w	mt_pattpos-mt_voice4(a4)
	clr.b	mt_break-mt_voice4(a4)
	addq.b	#1,mt_songpos-mt_voice4(a4)
	and.b	#$7f,mt_songpos-mt_voice4(a4)
	move.b	-2(a2),d0
	cmp.b	mt_songpos(pc),d0
	bne.s	mt_exit
	move.b	-1(a2),mt_songpos-mt_voice4(a4)
	clr.b	mt_songpos                <------ Bug Fix by MASTER BEAT!
mt_exit:tst.b	mt_break-mt_voice4(a4)
	bne.s	mt_next
	rts

mt_nonew:
	lea	$dff0a0,a5
	lea	mt_com(pc),a6
	jsr	(a6)
	lea	mt_voice2(pc),a4
	lea	$dff0b0,a5
	jsr	(a6)
	lea	mt_voice3(pc),a4
	lea	$dff0c0,a5
	jsr	(a6)
	lea	mt_voice4(pc),a4
	lea	$dff0d0,a5
	jsr	(a6)
	tst.b	mt_break-mt_voice4(a4)
	bne.s	mt_next
	rts

mt_irq1:tst.b	$bfdd00
	move.w	mt_dmacon(pc),$dff096
	move.l	#mt_irq2,$78.w
	move.w	#$2000,$dff09c
	rte

mt_irq2:tst.b	$bfdd00
	movem.l	a3/a4,-(a7)
	lea	mt_voice1(pc),a4
	lea	$dff000,a3
	move.l	$a(a4),$a0(a3)
	move.w	$e(a4),$a4(a3)
	move.l	$a+$1c(a4),$b0(a3)
	move.w	$e+$1c(a4),$b4(a3)
	move.l	$a+$38(a4),$c0(a3)
	move.w	$e+$38(a4),$c4(a3)
	move.l	$a+$54(a4),$d0(a3)
	move.w	$e+$54(a4),$d4(a3)
	movem.l	(a7)+,a3/a4
	move.b	#0,$bfde00
	move.b	#$7f,$bfdd00
	move.l	mt_oldirq(pc),$78.w
	move.w	#$2000,$dff09c
	move.w	#$2000,$dff09a
	rte

mt_playvoice:
	move.l	(a0,d1.l),(a4)
	moveq	#0,d2
	move.b	2(a4),d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq	mt_oldinstr

	asl.w	#2,d2
	move.l	(a1,d2.l),4(a4)
	move.l	mt_mulu(pc,d2.w),a3
	move.w	(a3)+,8(a4)
	move.w	(a3)+,$12(a4)
	move.l	4(a4),d0
	moveq	#0,d3
	move.w	(a3)+,d3
	beq	mt_noloop
	asl.w	#1,d3
	add.l	d3,d0
	move.l	d0,$a(a4)
	move.w	-2(a3),d0
	add.w	(a3),d0
	move.w	d0,8(a4)
	bra	mt_hejaSverige

mt_mulu:dcb.l	$20,0

mt_noloop:
	add.l	d3,d0
	move.l	d0,$a(a4)
mt_hejaSverige:
	move.w	(a3),$e(a4)
	move.w	$12(a4),8(a5)

mt_oldinstr:
	move.w	(a4),d3
	and.w	#$fff,d3
	beq	mt_com2
	tst.w	8(a4)
	beq.s	mt_stopsound
	move.b	2(a4),d0
	and.b	#$f,d0
	cmp.b	#5,d0
	beq.s	mt_setport
	cmp.b	#3,d0
	beq.s	mt_setport

	move.w	d3,$10(a4)
	move.w	$1a(a4),$dff096
	clr.b	$19(a4)

	move.l	4(a4),(a5)
	move.w	8(a4),4(a5)
	move.w	$10(a4),6(a5)

	move.w	$1a(a4),d0
	or.w	d0,mt_dmacon-mt_playvoice(a6)
	bra	mt_com2

mt_stopsound:
	move.w	$1a(a4),$dff096
	bra	mt_com2

mt_setport:
	move.w	(a4),d2
	and.w	#$fff,d2
	move.w	d2,$16(a4)
	move.w	$10(a4),d0
	clr.b	$14(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge	mt_com2
	move.b	#1,$14(a4)
	bra	mt_com2
mt_clrport:
	clr.w	$16(a4)
	rts

mt_port:moveq	#0,d0
	move.b	3(a4),d2
	beq.s	mt_port2
	move.b	d2,$15(a4)
	move.b	d0,3(a4)
mt_port2:
	tst.w	$16(a4)
	beq.s	mt_rts
	move.b	$15(a4),d0
	tst.b	$14(a4)
	bne.s	mt_sub
	add.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
mt_portok:
	move.w	$10(a4),6(a5)
mt_rts:	rts

mt_sub:	sub.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
	move.w	$10(a4),6(a5)
	rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_vib:	move.b	$3(a4),d0
	beq.s	mt_vib2
	move.b	d0,$18(a4)

mt_vib2:move.b	$19(a4),d0
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	mt_sin(pc,d0.w),d2
	move.b	$18(a4),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	$10(a4),d0
	tst.b	$19(a4)
	bmi.s	mt_vibsub
	add.w	d2,d0
	bra.s	mt_vib3
mt_vibsub:
	sub.w	d2,d0
mt_vib3:move.w	d0,6(a5)
	move.b	$18(a4),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,$19(a4)
	rts


mt_arplist:
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arp:	moveq	#0,d0
	move.b	mt_counter(pc),d0
	move.b	mt_arplist(pc,d0.w),d0
	beq.s	mt_normper
	cmp.b	#2,d0
	beq.s	mt_arp2
mt_arp1:move.b	3(a4),d0
	lsr.w	#4,d0
	bra.s	mt_arpdo
mt_arp2:move.b	3(a4),d0
	and.w	#$f,d0
mt_arpdo:
	asl.w	#1,d0
	move.w	$10(a4),d1
	lea	mt_periods(pc),a0
mt_arp3:cmp.w	(a0)+,d1
	blt.s	mt_arp3
	move.w	-2(a0,d0.w),6(a5)
	rts

mt_normper:
	move.w	$10(a4),6(a5)
	rts

mt_com:	move.w	2(a4),d0
	and.w	#$fff,d0
	beq.s	mt_normper
	move.b	2(a4),d0
	and.b	#$f,d0
	beq.s	mt_arp
	cmp.b	#6,d0
	beq.s	mt_volvib
	cmp.b	#4,d0
	beq	mt_vib
	cmp.b	#5,d0
	beq.s	mt_volport
	cmp.b	#3,d0
	beq	mt_port
	cmp.b	#1,d0
	beq.s	mt_portup
	cmp.b	#2,d0
	beq.s	mt_portdown
	move.w	$10(a4),6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$71,d0
	bpl.s	mt_portup2
	move.w	#$71,$10(a4)
mt_portup2:
	move.w	$10(a4),6(a5)
	rts

mt_portdown:
	moveq	#0,d0
	move.b	3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$358,d0
	bmi.s	mt_portdown2
	move.w	#$358,$10(a4)
mt_portdown2:
	move.w	$10(a4),6(a5)
	rts

mt_volvib:
	 bsr	mt_vib2
	 bra.s	mt_volslide
mt_volport:
	 bsr	mt_port2

mt_volslide:
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	beq.s	mt_vol3
	add.b	d0,$13(a4)
	cmp.b	#$40,$13(a4)
	bmi.s	mt_vol2
	move.b	#$40,$13(a4)
mt_vol2:move.w	$12(a4),8(a5)
	rts

mt_vol3:move.b	3(a4),d0
	and.b	#$f,d0
	sub.b	d0,$13(a4)
	bpl.s	mt_vol4
	clr.b	$13(a4)
mt_vol4:move.w	$12(a4),8(a5)
	rts

mt_com2:move.b	2(a4),d0
	and.b	#$f,d0
	beq	mt_rts
	cmp.b	#$e,d0
	beq.s	mt_filter
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_songjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_filter:
	move.b	3(a4),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	move.b	#1,mt_break-mt_playvoice(a6)
	rts

mt_songjmp:
	move.b	#1,mt_break-mt_playvoice(a6)
	move.b	3(a4),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos-mt_playvoice(a6)
	rts

mt_setvol:
	cmp.b	#$40,3(a4)
	bls.s	mt_sv2
	move.b	#$40,3(a4)
mt_sv2:	moveq	#0,d0
	move.b	3(a4),d0
	move.b	d0,$13(a4)
	move.w	d0,8(a5)
	rts

mt_setspeed:
	moveq	#0,d0
	move.b	3(a4),d0
	cmp.b	#$1f,d0
	bls.s	mt_sp2
	moveq	#$1f,d0
mt_sp2:	tst.w	d0
	bne.s	mt_sp3
	moveq	#1,d0
mt_sp3:	move.b	d0,mt_speed-mt_playvoice(a6)
	rts

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000

mt_speed:	dc.b	6
mt_counter:	dc.b	0
mt_pattpos:	dc.w	0
mt_songpos:	dc.b	0
mt_break:	dc.b	0
mt_dmacon:	dc.w	0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	13,0
		dc.w	1
mt_voice2:	dcb.w	13,0
		dc.w	2
mt_voice3:	dcb.w	13,0
		dc.w	4
mt_voice4:	dcb.w	13,0
		dc.w	8
mt_oldirq:	dc.l	0



******************************

***********************************

; Sprite Data for player's ship (16 Col. Attached Sprite)

ShipA	dc.w	$0000,$0000
	dc.w	$0f00,$0000,$31c0,$0000,$4d30,$0cc0,$5d4c,$1cf0
	dc.w	$bd8a,$3cfc,$8111,$00fe,$ffff,$0000,$8001,$7ffe
	dc.w	$bffd,$4002,$bffa,$4004,$5ff4,$2008,$4f98,$3060
	dc.w	$3060,$0f80,$0f80,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000
	
ShipB	dc.w	$0000,$0000	
	dc.w	$0000,$0000,$0e00,$0000,$3200,$0000,$2240,$0000
	dc.w	$4288,$0000,$7e10,$0000,$0000,$0000,$7ffe,$0000
	dc.w	$7ffe,$0000,$7ffc,$0000,$3ff8,$0000,$3fe0,$0000
	dc.w	$0f80,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000

Ship2A	dc.w	$0000,$0000
	dc.w	$0f00,$0000,$31c0,$0000,$4d30,$0cc0,$5d0c,$1cb0
	dc.w	$bd02,$3c74,$8101,$00ee,$ffff,$0000,$8001,$7ffe
	dc.w	$bffd,$7ffe,$bffa,$7ffc,$5ff4,$3ff8,$4f98,$3fe0
	dc.w	$3060,$0f80,$0f80,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000
	
Ship2B	dc.w	$0000,$0000
	dc.w	$0000,$0000,$0e00,$0e00,$32c0,$3ec0,$22b0,$3ef0
	dc.w	$4274,$7efc,$7eee,$7efe,$0000,$0000,$0000,$0000
	dc.w	$3ffc,$0000,$3ff8,$0000,$1ff0,$0000,$0f80,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000

*******

; Sprite data for the junk...

Sprite4

	dc.w    $38D0,$4800		; CO-ORDINATES
	dc.w	$07c0,$0000,$1830,$07c0,$2008,$1ff0,$4004,$37f8
	dc.w	$4004,$23f8,$803e,$77c0,$803e,$7fc0,$8036,$7fc8
	dc.w	$8062,$7f9c,$80ea,$7f1c,$4fc8,$303c,$4f14,$30f8
	dc.w	$2e68,$11f0,$1f10,$00e0,$07c0,$0000,$0000,$0000

	dc.w	$4943,$5900
	dc.w	$07e0,$0000,$1818,$07e0,$27e4,$19d8,$6f72,$3370
	dc.w	$641a,$3804,$e40d,$3802,$f409,$1800,$fa7d,$1c7a
	dc.w	$fa3d,$1c32,$f40d,$1802,$e611,$3800,$6722,$3a04
	dc.w	$6ffa,$31e4,$27e4,$1818,$1818,$07e0,$07e0,$0000
	
	dc.w	$6087,$7000
	dc.w	$07c0,$0000,$1e30,$0600,$3f88,$0f80,$7fc4,$1fc0
	dc.w	$7fe4,$3fe0,$ffe2,$7fe0,$bfe2,$3fe0,$bfc2,$3fc0
	dc.w	$9fc2,$1fc0,$8702,$0700,$4004,$0000,$4004,$0000
	dc.w	$2008,$0000,$1830,$0000,$07c0,$0000,$0000,$0000
	
	dc.w    $71af,$8100
	dc.w	$0180,$0000,$03c0,$0000,$07e0,$0200,$0ff0,$0600
	dc.w	$1ff8,$0e00,$3ffc,$1e00,$7ffe,$3e00,$ffff,$0000
	dc.w	$ffff,$0000,$4182,$3e7c,$2184,$1e78,$1188,$0e70
	dc.w	$0990,$0660,$05a0,$0240,$03c0,$0000,$0180,$0000
	
	dc.w    $8213,$9200
	dc.w	$07e0,$0000,$1818,$07e0,$27e4,$19d8,$6f72,$3370
	dc.w	$641a,$3804,$e40d,$3802,$f409,$1800,$fa7d,$1c7a
	dc.w	$fa3d,$1c32,$f40d,$1802,$e611,$3800,$6722,$3a04
	dc.w	$6ffa,$31e4,$27e4,$1818,$1818,$07e0,$07e0,$0000

	dc.w    $93D0,$a300
	dc.w	$0ff0,$0000,$0ff0,$05a0,$0ef0,$04a0,$0e50,$0400
	dc.w	$0ad0,$0080,$0bf0,$01a0,$0ff0,$05a0,$0ff0,$05a0
	dc.w	$0ff0,$05a0,$1ff8,$0db0,$17e8,$0180,$2664,$0000
	dc.w	$4a52,$0000,$4a52,$0000,$524a,$0000,$63c6,$0000

	dc.w	$a443,$b400
	dc.w	$0180,$0000,$03c0,$0000,$07e0,$0200,$0ff0,$0600
	dc.w	$1ff8,$0e00,$3ffc,$1e00,$7ffe,$3e00,$ffff,$0000
	dc.w	$ffff,$0000,$4182,$3e7c,$2184,$1e78,$1188,$0e70
	dc.w	$0990,$0660,$05a0,$0240,$03c0,$0000,$0180,$0000

	dc.w	$b587,$c500
	dc.w	$07c0,$0000,$1e30,$0600,$3f88,$0f80,$7fc4,$1fc0
	dc.w	$7fe4,$3fe0,$ffe2,$7fe0,$bfe2,$3fe0,$bfc2,$3fc0
	dc.w	$9fc2,$1fc0,$8702,$0700,$4004,$0000,$4004,$0000
	dc.w	$2008,$0000,$1830,$0000,$07c0,$0000,$0000,$0000

	dc.w	$c621,$d600
	dc.w	$ffff,$0000,$9ff1,$7ffe,$9ff1,$7ffe,$9ff5,$7ffa
	dc.w	$9ff5,$7ffe,$9ff1,$7ffe,$9ff1,$7ffe,$9ff1,$7ffe
	dc.w	$8fe1,$7ffe,$8001,$7ffe,$8001,$7ffe,$8001,$707e
	dc.w	$8781,$707e,$8781,$707e,$4001,$3ffe,$3fff,$0000

	dc.w	$e458,$f400	
	dc.w	$ffff,$0000,$400a,$3ff4,$4da6,$0258,$4ed2,$112c
	dc.w	$4e96,$0168,$5dd2,$022c,$4e26,$01d8,$ffff,$0000
	dc.w	$4006,$3ff8,$4da2,$025c,$4ed6,$1128,$4e92,$016c
	dc.w	$5dd6,$0228,$4e22,$01dc,$5986,$0678,$ffff,$0000

Sprite5
	dc.w    $38D0,$4880	; CO-ORDINATES WITH ATTACH BIT SET 
	dc.w	$0000,$0000,$0000,$07c0,$0000,$1ff0,$0000,$3ff8
	dc.w	$0000,$3ff8,$0000,$7ffc,$0000,$7ffc,$0000,$7ffc
	dc.w	$0000,$7ffc,$0000,$7ff4,$0000,$3ff4,$0000,$3fe8
	dc.w	$0000,$1f90,$0000,$07e0,$0000,$0000,$0000,$0000

	dc.w	$4943,$5980
	dc.w	$0000,$0000,$07e0,$07e0,$1e38,$1ff8,$2c0c,$0ffc
	dc.w	$241c,$07fc,$240e,$07fe,$140e,$07fe,$1a06,$03fe
	dc.w	$1a0e,$03fe,$140e,$07fe,$261e,$07fe,$253c,$07fc
	dc.w	$2e1c,$0ffc,$1ff8,$1ff8,$07e0,$07e0,$0000,$0000

	dc.w	$6087,$7080
	dc.w	$0000,$0000,$01c0,$07c0,$0070,$0ff0,$0038,$1bf8
	dc.w	$0018,$31f8,$001c,$7bfc,$401c,$7ffc,$403c,$7ffc
	dc.w	$603c,$7ffc,$78fc,$7ffc,$3ff8,$3ff8,$3ff8,$3ff8
	dc.w	$1ff0,$1ff0,$07c0,$07c0,$0000,$0000,$0000,$0000

	dc.w    $71af,$8180
	dc.w	$0000,$0000,$0000,$0000,$0040,$0000,$0060,$0000
	dc.w	$0070,$0000,$0078,$0000,$007c,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007c,$0000,$0078,$0000,$0070
	dc.w	$0000,$0060,$0000,$0040,$0000,$0000,$0000,$0000

	dc.w    $8213,$9280
	dc.w	$0000,$0000,$07e0,$07e0,$1e38,$1ff8,$2c0c,$0ffc
	dc.w	$241c,$07fc,$240e,$07fe,$140e,$07fe,$1a06,$03fe
	dc.w	$1a0e,$03fe,$140e,$07fe,$261e,$07fe,$253c,$07fc
	dc.w	$2e1c,$0ffc,$1ff8,$1ff8,$07e0,$07e0,$0000,$0000

	dc.w    $93D0,$a380	
	dc.w	$0000,$0000,$0000,$0000,$0100,$0000,$01a0,$0000
	dc.w	$05a0,$0080,$05a0,$01a0,$05a0,$05a0,$0400,$05a0
	dc.w	$0000,$05a0,$0000,$0db0,$0810,$0990,$1998,$1998
	dc.w	$318c,$318c,$318c,$318c,$2184,$2184,$0000,$0000

	dc.w	$a443,$b480
	dc.w	$0000,$0000,$0000,$0000,$0040,$0000,$0060,$0000
	dc.w	$0070,$0000,$0078,$0000,$007c,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007c,$0000,$0078,$0000,$0070
	dc.w	$0000,$0060,$0000,$0040,$0000,$0000,$0000,$0000

	dc.w	$b587,$c580
	dc.w	$0000,$0000,$01c0,$07c0,$0070,$0ff0,$0038,$1bf8
	dc.w	$0018,$31f8,$001c,$7bfc,$401c,$7ffc,$403c,$7ffc
	dc.w	$603c,$7ffc,$78fc,$7ffc,$3ff8,$3ff8,$3ff8,$3ff8
	dc.w	$1ff0,$1ff0,$07c0,$07c0,$0000,$0000,$0000,$0000

	dc.w	$c621,$d680
	dc.w	$0000,$0000,$1ff0,$0fe0,$1010,$0000,$1ff0,$0fe0
	dc.w	$1014,$0000,$1ff0,$0fe0,$1010,$0000,$1ff0,$0fe0
	dc.w	$0fe0,$0000,$0000,$0000,$0000,$0000,$0040,$0ff8
	dc.w	$07c0,$0fc8,$07c0,$0fc8,$0fc0,$0fc8,$0000,$0000

	dc.w	$e458,$f480	
	dc.w	$0000,$0000,$3ff4,$3ff4,$0ff8,$3ff8,$1ffc,$3ffc
	dc.w	$0ff8,$3ff8,$1ffc,$3ffc,$0ff8,$3ff8,$0000,$0000
	dc.w	$3ff8,$3ff8,$0ffc,$3ffc,$1ff8,$3ff8,$0ffc,$3ffc
	dc.w	$1ff8,$3ff8,$0ffc,$3ffc,$1ff8,$3ff8,$0000,$0000

************************************

Blankbit
	dcb.b	1900,$ff

Speeds1:			; Speed of junk
	dc.b 04,03,02,04,03,02,04,04,03,02

	even

	end

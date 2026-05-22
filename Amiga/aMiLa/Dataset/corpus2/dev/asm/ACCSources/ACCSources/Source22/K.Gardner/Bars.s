		*********************************
		*				*
		*	  COPPER BARS		*
		*				*
		*     Something different	*
		*				*
		*   Written By Kevin Gardner	*
		*				*
		*        February 1992		*
		*				*
		*********************************
	
*************************************************************************
* What it does is to show four copper bars that seem to be revoling.	*
* WHY ???								*
* Well after seeing all the Mega demo's by DOC MABUSE and such like	*
* all showing bouncing bars up and down the screen i decided to do	*
* something that was slightly different, which i have not seen done	*
* on any demo yet ????							*
* Which is exactly what programming is all about.			*
* ( Show i am led to believe )						*
*************************************************************************
 
	SECTION REVOLINGBARS,CODE_C

Bars	equ	200

*****************************************************************************
* MAIN SETUP ROUTINE				    			    *
*****************************************************************************

Take_Over_System:	
	MOVEM.L A0-A6/D0-D7,-(A7)		Save all Registers
	MOVE.L  A7,Stackpoint			Save Pointer
	Jsr	Init_bar
	Jsr	InitBarStruc
	JSR 	Kill_OS
	JSR	Main
	JSR 	Help_OS
	MOVE.L  Stackpoint,A7			Restore Pointer
	MOVEM.L (A7)+,A0-A6/D0-D7		Restore Registers
	RTS

*****************************************************************************
* MAIN RUN ROUTINE			            			    *
*****************************************************************************

Main:
	Cmpi.b	#255,$dff006
	Bne.s	Main
	Bsr	Color_bar
	Bsr	Bubble
	Bsr.s	Waste_Time
	btst	#6,$bfe001
	bne.s	Main
	Rts

*****************************************************************************
* WASTE TIME ROUTINE			            			    *
*****************************************************************************

; As the Color_bar routine in the program is the only one that does anything
; i needed to slow the whole thing down so you can see what is happening
; Try commenting out the Bsr.s Waste_Time code in the main run routine to
; see the effect on the speed.
; This is not the best way to waste time but it is a more convenient
; way to show you.

Waste_Time:
	Move.w	#$6fff,d6
.loop	subq.w	#1,d6
	Bne.s	.loop
	rts

*****************************************************************************
* KILL OS				            			    *
*****************************************************************************

Kill_OS:
	MOVE.L	 $4.w,A6
	CLR.L    D0
	LEA	 GFXlib(PC),A1
	JSR	 -552(A6)		     	Open GFX Lib
	MOVE.L   D0,GFXBase    
	JSR	 -132(A6)		     	LVO_Forbid
	MOVE.W	 $DFF002,DMAsave		Save DMA
	MOVE.W	 $DFF01C,INTensave		Save Interupt Enable
	MOVE.W   $DFF01E,INTrqsave		Save Interupt Request
Wt	BTST	 #0,$DFF004			Test MSB of VPOS
	BNE.S	 Wt
Wtt	CMPI.B	 #55,$DFF006			Wait Line 310
	BNE.S	 Wtt				(stops Spurious Sprite Data)
	MOVE.W   #$7FFF,$DFF09A   	     	Disable	Interupts
	MOVE.W   #$7FFF,$DFF096   		Disable DMA
	MOVE.L   #CopperList,$DFF080		Replace Copper 
	MOVE.W   $DFF088,D0			Strobe Copper
	MOVE.W   #%1000001111100000,$DFF096	Copper/Bitplane/Blit/Sprite
	RTS 
 

*****************************************************************************
* RESTORE OS				    				    *
*****************************************************************************

Help_OS:
	MOVE.W  INTensave,D7
	BSET    #$F,D7				Set Write Bit
	MOVE.W  D7,$DFF09A			Restore INTen
	MOVE.W  INTrqsave,D7
	BSET    #$F,D7
	MOVE.W  D7,$DFF09C			Restore INTrq
	MOVE.W  DMAsave,D7
	BSET    #$F,D7
	MOVE.W  D7,$DFF096	  		Restore DMA
	MOVE.L  GFXBase,A0
	MOVE.L  $26(A0),$DFF080			Find/Replace System Copper
	MOVE.L  $4.w,A6
	JSR     -138(A6)			LVO_Permit
	RTS 

*****************************************************************************
* INITALIZE BARS			    				    *
*****************************************************************************

; This routine place all the copper wait,move and color infomation into
; in the copper list at the point where you should see Baradd ds.b Bars

Init_bar:
	moveq	#Bars/4-1,d0
	Move.l	#$3009fffe,d1
	Move.l	#Baradd,a0
.Loop	move.l	d1,(a0)
	addq.l	#4,a0
	move.l	#$01800000,(a0)
	addq.l	#4,a0
	add.l	#$01000000,d1
	dbra	d0,.Loop		; Last number = $5709,$fffe	
	Rts

*****************************************************************************
* INITALIZE BAR STRUCTURE		    				    *
*****************************************************************************

InitBarStruc:
	Lea	ColourBars,a5
	Move.l	#Pos1,Bar1(a5)
	Move.l	#BarColour1,Colour1(a5)
	Move.l	#Pos2,Bar2(a5)
	Move.l	#BarColour2,Colour2(a5)
	Move.l	#Pos3,Bar3(a5)
	Move.l	#BarColour3,Colour3(a5)
	Move.l	#Pos4,Bar4(a5)
	Move.l	#BarColour4,Colour4(a5)
	Jsr	Bubble
	rts

*****************************************************************************
* BUBBLE SORT BARS			    				    *
*****************************************************************************

; This is a bubble sort routine that sorts the bar colours and postions
; so that the bars revolve instead of bounce up and down.
; To see what effect it makes on the program comment out the
; Jsr Bubble Code in the Main run routine.
; It also shows that you should never neglect the good old basic programming
; examples out of all those books that try to teach you programming.

Bubble:
	Lea	ColourBars,a5
	clr.l	d0
.BLoop	Move.l	(a5),d1
	cmp.l	8(a5),d1
	ble.s	.NoSwap
	Move.l	8(a5),(a5)
	Move.l	d1,8(a5)
	Move.l	4(a5),d1
	Move.l	12(a5),4(a5)
	Move.l	d1,12(a5)
	Moveq	#1,d0
.NoSwap	Addq.l	#8,a5
	Cmpa.l	#endbuf,a5
	blo.s	.BLoop
	Tst.w	d0
	Bne.s	Bubble
	Rts

*****************************************************************************
* COLOR BARS				    				    *
*****************************************************************************

Color_bar:
	Btst	#$0a,$dff016		; test right mouse button
	Bne.s	.Cont			; continue if not pressed
	Rts				; else pause
.Cont
	Moveq.l	#3,d7
	Lea	ColourBars,a5
.loop	Move.l	(a5),d0			; get next position
	Move.l	4(a5),a0		; get bar colours
	Jsr	PutBar
	Move.l	d0,(a5)			; save new position
	addq.l	#8,a5			; get ready for next bar
	dbf	d7,.loop
	rts

*****************************************************************************
* PUT COLOR BAR INTO COPPER LIST	    				    *
*****************************************************************************

PutBar:
	Lsl.l	#1,d0		; multiply start by 2 (so it's even)
	Move.l	#PosList,a1	; get address of bar position list
	add.l	d0,a1		; add offset to position list
	cmp.w	#$ffff,(a1)	; test if end of list reached
	bne.s	.NotEnd		; if no then move on
	clr.l	d0		; if yes reset start position
	move.l	#PosList,a1
.NotEnd	clr.l	d2
	move.w	(a1),d2
	lsl.l	#3,d2
	move.l	#Baradd,a2
	add.l	d2,a2
	moveq	#10,d1		; Number of colours do read
.Loop	move.w	(a0)+,6(a2)
	addq.l	#8,a2
	dbra	d1,.Loop
	lsr.l	#1,d0
	addi.l	#1,d0
	rts	

*	List of bar colours

BarColour1:	; Colour of 1st bar
	dc.w	$100,$300,$500,$700,$900,$a00,$900,$700,$500,$300,$100

BarColour2:	; Colour of 2nd bar
	dc.w	$010,$030,$050,$070,$090,$0a0,$090,$070,$050,$030,$010

BarColour3:	; Colour of 3rd bar
	dc.w	$111,$333,$555,$777,$999,$AAA,$999,$777,$555,$333,$111

BarColour4:	; Colour of 4th bar
	dc.w	$001,$003,$005,$007,$009,$00b,$009,$007,$005,$003,$001

* list of where the bar is to be placed next *

PosList:	DC.W 0,2,4,6,8,10,12,14,16,18,20
		DC.W 22,24,26,28,30,28,26,24,22
		DC.W 20,18,16,14,12,10,8,6,4,2,0
		DC.W $ffff

* Holds a list of the starting postions in the poslist *

Pos1	equ	0
Pos2	equ	7
Pos3	equ	15
Pos4	equ	23

	rsreset
Bar1	rs.l	1	; will hold the current position
Colour1	rs.l	1 	; will hold the address of the first colour bar
Bar2	rs.l	1
Colour2	rs.l	1
Bar3	rs.l	1
Colour3	rs.l	1
Bar4	rs.l	1
Colour4	rs.l	1
BarLen	rs.b	1
ColourBars	ds.b	BarLen
endbuf	equ	*-8

*****************************************************************************
* COPPERLIST								    *
*****************************************************************************

CopperList:
	dc.w	$0a01,$ff00,$100,$0200
	dc.w	$092,$0038,$094,$00d0
	dc.w	$08e,$2c81,$090,$2cc1

Baradd	ds.w	Bars			* Storage for copper bars

	dc.w	$ffff,$fffe

*****************************************************************************
* LABELS								    *
*****************************************************************************

GFXlib			DC.B "graphics.library"
Stackpoint		DC.L 0
GFXBase			DC.L 0
INTrqsave		DC.W 0
INTensave		DC.W 0
DMAsave			DC.W 0


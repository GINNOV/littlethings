
* Yo Kevin, I love problems that are this easy to solve!

* You have used long word data writes to hardware registers that only
* required word values .... common error.

* See the Blit_Bob subroutine for corrected writes. MM


	SECTION BOB,CODE_C		Force Code To Chip RAM
	OPT C+,D+			Case Independant


*****************************************************************************
* MAIN SETUP SEQUENCE				    			    *
*****************************************************************************

Take_Over_System:	
	MOVEM.L A0-A6/D0-D7,-(A7)	Save all Registers
	MOVE.L  A7,Stackpoint		Save Pointer
	JSR	Put_Screen		Put Screen address in copperlist
	JSR 	Kill_OS			Kill system
	JSR	Main
	JSR 	Help_OS			Restore system
	MOVE.L  Stackpoint,A7		Restore Pointer
	MOVEM.L (A7)+,A0-A6/D0-D7	Restore Registers
	RTS

*****************************************************************************
* MAIN RUN ROUTINE			            			    *
*****************************************************************************

Main:	Cmpi.b	#255,$dff006
	Bne.s	Main
	Jsr	Blit_Bob
	btst	#6,$bfe001
	bne	Main
	Rts

*****************************************************************************
* PUT SCREEN INTO COPPER LIST						    *
*****************************************************************************

Put_Screen:
	move.l	#BitMap,d0
	lea	NewCopper,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	rts

*****************************************************************************
* BLIT BOB DATA INTO SCREEN 						    *
*****************************************************************************

* Strictly speaking, you should check BBUSY at the start of the Blit. In this
* small example ( or extremly well timed code executed with fingers crossed )
* there is no need. Never forget the 68OOO will continue with your program
* once a Blit is started and, in a program using more than one Bob, could
* start trashing the Bob being Blitted while setting up for the next. MM

Blit_Bob:
	MOVE.L	#Bob.dat,A0			SOURCE
	MOVE.L	#BitMap+100*40+18,A1			DESTINATION
	MOVE.L	A0,$DFF050			Source a
	MOVE.L	A1,$DFF054			Destination d
	MOVE.W  #0,$DFF064			Mod a
	MOVE.W	#36,$DFF066			Mod d
	
;	MOVE.L	#-1,$DFF044			First word mask a
	move.w	#-1,$dff044			MM
	
;	MOVE.L	#-1,$DFF046			Last  word mask a
	move.w	#-1,$dff046			MM

;	MOVE.L	#%0000100111110000,$DFF040	Blit con 0
	move.w	#%0000100111110000,$dff040	MM

;	CLR.L	$DFF042				Blit con 1
	clr.w	$dff042				MM

	MOVE.W  #8*64+2,$DFF058			BLISIZE
.WtB1	BTST    #14,$DFF002			
	BNE.S   .WtB1
	RTS

*****************************************************************************
* KILL OS				            			    *
*****************************************************************************

Kill_OS	MOVE.L	 $4,A6
	CLR.L    D0
	LEA	 GFXlib(PC),A1
	JSR	 -552(A6)		     	Open GFX Lib
	MOVE.L   D0,GFXBase    
	JSR	 -132(A6)		     	Forbid
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
	MOVE.W   #%1000001111000000,$DFF096	Copper/Bitplane/Blitter
	RTS 
 

*****************************************************************************
* RESTORE OS				    				    *
*****************************************************************************

Help_OS	MOVE.W  INTensave,D7
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
	MOVE.L  $4,A6
	JSR     -138(A6)			LVO_Permit
	RTS 

*****************************************************************************
* LABELS,INCLUDES							    *
*****************************************************************************

GFXlib		DC.B 	"graphics.library"
Stackpoint	DC.L	0
GFXBase		DC.L	0
INTrqsave	DC.W	0
INTensave	DC.W	0
DMAsave		DC.W	0

	even
	
*****************************************************************************
* COPPERLIST								    *
*****************************************************************************

CopperList:
	dc.w	$0a01,$ff00
NewCopper:
	dc.w	$0e0,$0000
	dc.w	$0e2,$0000
	dc.w	$100,$1200
	dc.w	$102,$0000,$108,$0000
	dc.w	$104,$0000,$10a,$0000
	dc.w	$092,$0038,$094,$00d0
	dc.w	$08e,$2c81,$090,$f4c1

colours	dc.w	$180,$0000,$182,$0fff

	DC.W	$FFFF,$FFFE

	even

Bob.dat:
	dc.w	%1111111111111111,%1111111111111111
	dc.w	%1000000000000001,%1000000000000001
	dc.w	%1000000000000001,%1000000000000001
	dc.w	%1000000011111111,%1111111100000001
	dc.w	%1000000011111111,%1111111100000001
	dc.w	%1000000000000001,%1000000000000001
	dc.w	%1000000000000001,%1000000000000001
	dc.w	%1111111111111111,%1111111111111111

	even
	
BitMap	DCB.B	200*40,0	( 200 pixels height * 320 pixels width )
	
	even



*****************************************************************************
* 4 BITPLANE PICTURE BASE (Uses An OverScan Screen,44 Bytes Wide)	    *
* Code By Andy Lucas Aka Count Zero					    *
*---------------------------------------------------------------------------*
* This Code Sets up a 4 Bitplane Picture,I do not load the colour map,as I  *
* find it easier to work out the colours on Dpaint,and insert them in the   *
* Copper myself.							    *
* The Code is as optimised as I can get it.I have inserted some labels for  *
* those that need them 							    *
*****************************************************************************

 SECTION LOWMEM,CODE_C				Force Code To Chip RAM
 OPT C-						Case Independant


*****************************************************************************
* EXECUTE SEQUENCE				    			    *
*****************************************************************************

	MOVEM.L A0-A6/D0-D7,-(A7)		Save all Registers
	MOVE.L  A7,Stackpoint			Save Pointer
	JSR 	Kill_OS
	JSR 	SetUp
	JSR 	Main
	JSR 	Help_OS
	MOVE.L  Stackpoint,A7			Restore Pointer
	MOVEM.L (A7)+,A0-A6/D0-D7		Restore Registers
	RTS

*****************************************************************************
* KILL OS				            			    *
*****************************************************************************

Kill_OS	MOVE.L	 $4,A6
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
	MOVE.L   #Copperlist,$DFF080		Replace Copper 
	MOVE.W   $DFF088,D0			Strobe Copper
	MOVE.W   #%1000001110000000,$DFF096	Enable Copper/Bitplane DMA
	RTS 
 
*****************************************************************************
* SET UP ROUTINES							    *
*****************************************************************************

SetUp	MOVE.L	 #Planes,A0			Bpl Pointer In Copper
	MOVE.L   #Picture,D0			Picture Block
	MOVE.L	 #3,D1				No. Planes-1
PlLp   	MOVE.W   D0,6(A0)			Load Low Word
	SWAP     D0				Swap Words
	MOVE.W   D0,2(A0)			Load High Word
	SWAP     D0				Swap Words
	ADD.L    #290*44,D0			Add Size of plane
	ADD.L    #8,A0				Next Bpl Pointer In copper
	DBRA.W   D1,PlLp  			
	RTS 

*****************************************************************************
* MAIN					    				    *
*****************************************************************************

Main	CMPI.B	#255,$DFF006			Wait For line 255
	BNE.S	Main				
	BTST   	#6,$BFE001			Test Mouse
	BNE.S  	Main
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
	MOVE.L  GFXbase,A0
	MOVE.L  $26(A0),$DFF080			Find/Replace System Copper
	MOVE.L  $4,A6
	JSR     -138(A6)			LVO_Permit
	RTS 
 
*****************************************************************************
*			        COPPER				    	    *
*****************************************************************************

Copperlist

	DC.L $01080000,$010A0000,$01004200,$01020000	Mod / Con 0/1		
	DC.L $00920030,$009400D8,$008E1A64,$009039D1	Display/Data Fetch		
Planes	DC.L $00E00000,$00E20000,$00E40000,$00E60000	
	DC.L $00E80000,$00EA0000,$00EC0000,$00EE0000
Col     DC.L $01800000,$01820000,$01840000,$01860000	
	DC.L $01880000,$018A0000,$018C0000,$018E0000
	DC.L $01900000,$01920000,$01940000,$01960000
	DC.L $01980000,$019A0000,$019C0000,$019E0000
	DC.L $01040000					Video Priority
	DC.L $FFFFFFFE

*****************************************************************************
* LABELS,INCLUDES							    *
*****************************************************************************

GFXlib			DC.B "graphics.library"
Stackpoint		DC.L 0
GFXbase			DC.L 0
INTrqsave		DC.W 0
INTensave		DC.W 0
DMAsave			DC.W 0


 SECTION  LOWMEM,DATA_C					Section Data

Picture			DCB.B (290*44)*4







*****************************************************************************
* Basic 1 Bitplane Blitter Scroller,In Overscan				    *
* Code By Count Zero							    * 
*---------------------------------------------------------------------------*
* This is a basic blitter scroller,the only trouble with this type of       *
* scroller is that if a font is an exact integer of 16 pixels it is not     *
* possible to have spaces betwen the characters,without using complex masks *									    *
* to clear the spaces in between the characters.Try increasing the amount of*
* delay to see what I mean (1st line in GetChar Routine) 		    *
* There are many other ways of doing this type of scroller,but I find this  *
* to be the best,for ease of alteration 				    * 
* Lables included if ya need them!					    *
*****************************************************************************

 SECTION LOWMEM,CODE_C				Code Into Chip RAM
 OPT C-						Case Independant


*****************************************************************************
*			EXECUTE SEQUENCE				    *
*****************************************************************************

	MOVEM.L A0-A6/D0-D7,-(A7)		Save Regs
	MOVE.L  A7,Stackpoint			Save Stackpoint Pointer
	JSR 	SetUp
	JSR     Kill_OS
	JSR 	Main
	JSR 	Help_OS
	MOVE.L  Stackpoint,A7			Restore Pointer
	MOVEM.L (A7)+,A0-A6/D0-D7		Restore Regs
	RTS

*****************************************************************************
*			KILL OPERATING SYSTEM				    *
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
	MOVE.W   #%1000001111000000,$DFF096	Copper/Bitplane DMA
	RTS 

*****************************************************************************
*			     LOAD COPPERLIST				    *
*****************************************************************************

SetUp   LEA 	Planes,A0		Bpl Pointer in Copperlist
	MOVE.L  #Picture,D0		Picture
	MOVE.L	D0,Offset		Save Screen Start Address
	ADD.L	#(120*46),Offset	Pointer for Scroller
        MOVE.W  D0,6(A0)		Load Low Word
	SWAP    D0			Swap Words
	MOVE.W  D0,2(A0)		Load High Word
	RTS

*****************************************************************************
*				  MAIN					    *
*****************************************************************************

Main    CMPI.B	 #255,$DFF006		Wait for line 255
	BNE.S	 Main
;	MOVE.W	 #$F00,$DFF180		Raster Time Monitor!
	JSR	 Scroller
;	MOVE.W	 #$000,$DFF180
	BTST	 #6,$BFE001		Test Mouse
	BNE.S	 Main
	RTS

*****************************************************************************
*				BLIITER 				    *
*****************************************************************************

Scroller
	BTST	#$0A,$DFF016			Test Right Mouse 
	BNE.S	Nxt				If Not Equal Carry on
	RTS					Else Pause!
Nxt	MOVE.L  #$C9F00000,$DFF040		A=D,12 bits Shift
	MOVE.L  #$00000000,$DFF064		Mod
	MOVE.L	#$FFFFFFFF,$DFF044		Masks
	MOVE.L	Offset,$DFF050		        Source
	MOVE.L	Offset,A1			
	SUBQ.L	#1,A1				Subtract 16 Pxls
	MOVE.L	A1,$DFF054			Destination
	MOVE.W	#23+64*16,$DFF058		BLTSIZE
WtB	BTST    #14,$DFF002			Wait for Blit to End 
	BNE.S   WtB
	SUBQ.B	#$1,Delay			Need New Character?
	BEQ.S	GetChar				If Zero Branch
	RTS					Else Return
GetChar MOVE.B  #$4,Delay			New Char Delay
	ADD.L	#$1,TextPos			Next Scroller Character
	MOVE.L	#Checker,A0			Valid Chars
	MOVE.L	#Text,A1			Start of Text
	MOVE.L	TextPos,D2			Move Text Pos,D2
	MOVE.L	#0,D0				Clear for char byte
	MOVE.L	#0,D1				Clear for Char Count
	MOVE.B	(A1,D2),D0			Get Character
	BGT.S	Ch_Lp				If Not Zero,Not End
	MOVE.L	#$0000,TextPos			If Zero Wrap Text
Ch_Lp	CMP.B	(A0)+,D0			Buffer to Checker
	BEQ.S	Match				Branch If Char Found
	ADDQ.B	#1,D1				Add to Char Count
	CMPI.B	#53,D1				All Chars checked?
	BNE.S	Ch_Lp				If Not,loop
	MOVE.B	#36,D1				Invalid Char = space 
Match	MOVE.L	D1,D0				Save Char number
	DIVU	#20,D1				No.Chars per row in font
	MOVE.L	D1,D2				Save Row to D2
	MULU	#640,D1				40bytesx16pxls (1 line)
	MULU	#20,D2				Row no. x no. Chars
	SUB.L	D2,D0				Calc Char Horiz Pos
	MULU	#2,D0				2bytes x Horiz Pos
	ADD.L	D1,D0				Add Vert+Horiz Pos
Blit	MOVE.W  #$09F0,$DFF040			A = D Miniterm
	MOVE.L	Offset,A1			Scroller pos on screen
	MOVE.L	#Font,A0			Font
	ADD.L	D0,A0				Add CharPos
	MOVE.L  A0,$DFF050			A
	ADD.L   #44,A1				Display in Modulo border
	MOVE.L	A1,$DFF054			D
	MOVE.W  #0038,$DFF064			BLTAMOD
	MOVE.W	#0044,$DFF066			BLTDMOD
	MOVE.W  #1+64*15,$DFF058		BLISIZE
WtB1	BTST    #14,$DFF002			
	BNE.S   WtB1
	RTS

*****************************************************************************
*			RESTORE OPERATING SYSTEM			    *
*****************************************************************************

Help_OS MOVE.W INTensave,D7
	BSET   #$F,D7
	MOVE.W D7,$DFF09A			Restore INTen
	MOVE.W INTrqsave,D7
	BSET   #$F,D7
	MOVE.W D7,$DFF09C			Restore INTrq
	MOVE.W DMAsave,D7
	BSET   #$F,D7
	MOVE.W D7,$DFF096			Restore DMA
	MOVE.L GFXbase,A0
	MOVE.L $26(A0),$DFF080			Restore Copper
	MOVE.L $4,A6
	JSR    -138(A6)				LVO Permit
	RTS

*****************************************************************************
*				COPPERLIST				    *
*****************************************************************************

Copperlist

Planes	DC.L $00E00000,$00E20000	BPL1PTH/L
Col     DC.L $01800000,$01820DDD	COLOR0/1
	DC.L $01001200,$01020000	BPLCON0/1
	DC.L $01080002,$010A0002	BPL1/2MOD
	DC.L $00920030,$009400D8	DDFSTRT/DDFSTOP
	DC.L $008E1A64,$009039D1	DIWSTRT/DIWSTOP
	DC.L $FFFFFFFE

*****************************************************************************
*			DATA,VARIABLES AND INCLUDES			    *
*****************************************************************************

GFXlib		DC.B 	"graphics.library"
GFXbase		DC.L 	0
INTensave	DC.W 	0
INTrqsave	DC.W 	0
DMAsave		DC.W 	0
Stackpoint	DC.L    0
Offset		DC.L    0
Delay		DC.B 	$12
TextPos		DC.L	0
Picture		DCB.B   (290*46),0
Font		IncBin  "source_1:bitmaps/Font.Bm"
		Even

Checker	DC.B    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ?.,[]`:;-+/%*()!"
;[] means speech marks

*****************************************************************************
*				SCROLL TEXT				    *
*****************************************************************************
 Even

Text

	DC.B "    "
	DC.B " THIS IS A BASIC BLITTER SCROLLER,IF YOU REMOVE THE "
	DC.B "SEMI-COLONS IN THE MAIN ROUTINE,THEN YOU CAN SEE HOW "
	DC.B "LITTLE RASTER TIME THIS SCROLLER USES.ONLY CAPITALS ARE"
	DC.B " SUPPORTED IN THE SCROLL TEXT,ANY LOWER CASE LETTERS WILL"
	DC.B " BE REPLACED BY A SPACE CHARACTER.IF YOU ARE UNFAMILIAR "
	DC.B "WITH THE BLITTER,REMEMBER THE FOLLOWING POINTS. BLIT WIDTH"
	DC.B " IS IN WORDS (IE. 1 WORD IS 2 BYTES,EQUALS 16 PIXELS),THE "
	DC.B " MODULO VALUE IS IN BYTES.IT IS CALCULATED AS FOLLOWS: "
	DC.B "SCREEN SIZE IN BYTES,INCLUDING SCREEN MODULO - BLIT WIDTH"
	DC.B " IN WORDS * 2 EQUALS MODULO IN BYTES. AND ALSO IF YOU DIDN`T "
	DC.B " ALREADY KNOW,IN THE MAIN ROUTINE,DO NOT WAIT FOR A LINE "
	DC.B " BELOW 58,AS THIS WILL OCCUR TWICE EVERY FRAME,THIS IS "
	DC.B "DUE TO DFF006 ONLY CONTAINING 1 BYTE  FOR THE SCREEN POS,"
	DC.B "SO ONLY 256 LINES ARE POSSIBLE,BUT THERE ARE 313 LINES ON A"
	DC.B " PAL SCREEN,THE MOST SIGNIFICANT BIT IS BIT 0 IN DFF004,AND"
	DC.B " SO WHEN 256 IS REACHED IS WRAPS BACK TO ZERO,AND THIS WILL"
	DC.B " OCCUR TWICE PER FRAME.WELL THATS ABOUT IT,IF YOU USE THIS"
	DC.B " ROUTINE IN YOUR OWN INTRO`S THEN DO NOT CREDIT ME!,THAT`S "
	DC.B "ALL FOLKS!.......             "














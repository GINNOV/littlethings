****************************************************************************
* 3 Layer Sprite StarField 						   *
* Code By Andy Lucas,Alias Count Zero 					   *
* ------------------------------------------------------------------------ *
* 									   *
* This is the standard type of starfield,it re-uses one sprite DMA channel *
* a multiple number of times,the move routine is very short,and not hard   *
* to follow.								   *
****************************************************************************

 	SECTION LOWMEM,CODE_C
 	OPT C-

	MOVEM.L A0-A6/D0-D7,-(A7)
	MOVE.L  A7,Stackpoint
	JSR	Kill_OS
	JSR	SetUp_Planes
	JSR     SetUp_Sprite
	JSR	Main
	JSR	Help_OS
	MOVE.L	Stackpoint,A7
	MOVEM.L (A7)+,A0-A6/D0-D7
	RTS

****************************************************************************
*			       KILL OS					   *
****************************************************************************

Kill_OS MOVE.L  $4,A6
	CLR.L   D0
	LEA     GFXlib(PC),A1
	JSR	-552(A6)		     Open graphics library
	MOVE.L  D0,GFXBase    
	JSR	-132(A6)		     LVO Forbid
	MOVE.W	$DFF002,DMAsave
	MOVE.W	$DFF01C,INTensave			
	MOVE.W  $DFF01E,INTrqsave			
	MOVE.W	#%0111111111111111,$DFF09A   Switch INTENA off
	MOVE.W  #%0111111111111111,$DFF096   Switch all DMA off
	MOVE.L  #Copperlist,$DFF080
	MOVE.W  $DFF088,D0
	MOVE.W  #%1000001110100000,$DFF096   DMA:Cop/Bit/Sprite
	RTS

****************************************************************************
*				SETUP				 	   *
****************************************************************************

SetUp_Planes
	LEA 	Planes,A0		Set only 1 Plane
	MOVE.L  #Picture,D0
	MOVE.W  D0,6(A0)
	SWAP    D0
	MOVE.W  D0,2(A0)
	RTS

****************************************************************************
*				SETUP STARS				   *
****************************************************************************

SetUp_Sprite
	MOVE.L	#Sprite,D0		Address of Stars
	LEA  	Sp_Ptr,A0  		pointers in Coperlist
        MOVE.W  D0,6(A0)		Load high word
	SWAP 	D0			swap words
	MOVE.W  D0,2(A0)		Load low words
        MOVE.L  #Sprite_Empty,D0	Empty Sprite
	LEA  	Sp_Ptr,A0		Pointers in copper
	ADD.L   #8,A0			Point Past Sprite0
	MOVE.L  #6,D1			Loop Value
Sp_Lp	MOVE.W  D0,6(A0) 		Load Blank Sprites Loop
	SWAP    D0
	MOVE.W  D0,2(A0)
	SWAP    D0
	ADD.L	#8,A0			Next pointer in Copper
	DBF     D1,Sp_Lp		Loop
	RTS

****************************************************************************
*				  MAIN					   *
****************************************************************************

Main    CMPI.B   #240,$DFF006		
	BNE.S    Main
;	MOVE.W	 #$000,$DFF180		Raster Time Monitor!!
	JSR	 Stars
;	MOVE.W	 #$003,$DFF18		Try Removing both semi-colons
	BTST 	 #6,$BFE001
	BNE.S    Main
	RTS

****************************************************************************
*				STARS					   *
****************************************************************************

Stars   MOVE.L	#SpriteE-Sprite,D2	Length (N) of Star data block
	DIVU	#(8*3),D2		No.Layers (3)
	MOVE.L	#Sprite,A0		Address of stars
Ch	CMPI.B	#$DF,1(A0)		Reached far right of screen?
	BNE.S   Mv			No,branch
	MOVE.B	#$38,1(A0)		Yes,reset to far left 
Mv	ADDQ.B  #$1,1(A0)		1st layer speed
	ADDQ.B	#$2,9(A0)		2nd layer speed
	ADDQ.B	#$3,17(A0)		3rd layer speed
	ADD.L	#24,A0			Next 3 stars
	DBF.W	D2,Ch			Loop N times
	RTS				Cool Routine Huh?

****************************************************************************
*				HELP OS					   *
****************************************************************************

Help_OS MOVE.W INTensave,D7		
	BSET   #$F,D7			
	MOVE.W D7,$DFF09A		Restore INTen
	MOVE.W INTrqsave,D7		
	BSET   #$F,D7			
	MOVE.W D7,$DFF09C		Restore INTrq
	MOVE.W DMAsave,D7
	BSET   #$F,D7
	MOVE.W D7,$DFF096		Restore DMA
	MOVE.L GFXbase,A0
	MOVE.L $26(A0),$DFF080
	MOVE.L $4,A6
	JSR    -138(A6)			LVO Permit
	RTS

****************************************************************************
*				COPPER					   *
****************************************************************************


Copperlist


Planes	DC.L $00E00000,$00E20000	BPL1PTH/L
Col     DC.L $01800003,$01820000	COLOR0/1
Sp_Ptr	DC.L $01200000,$01220000	Sprite0 PTH/L
	DC.L $01240000,$01260000	Sprite1 PTH/L
	DC.L $01280000,$012A0000	Sprite2 PTH/L
	DC.L $012C0000,$012E0000	Sprite3 PTH/L
	DC.L $01300000,$01320000	Sprite4 PTH/L
	DC.L $01340000,$01360000	Sprite5 PTH/L
	DC.L $01380000,$013A0000	Sprite6 PTH/L
	DC.L $013C0000,$013E0000	Sprite7 PTH/L
Sp_Col	DC.L $01A20999			COLOR 17
	DC.L $01A40BBB			COLOR 18
	DC.L $01A80000			COLOR 19
	DC.L $01001200,$01020000	BPLCON0/1
	DC.L $01080000,$010A0000	BPL1/2MOD
	DC.L $00920030,$009400D8	DDFSTRT/DDFSTOP
	DC.L $008E1A64,$009039D1	DIWSTRT/DIWSTOP


	DC.L $FFFFFFFE



****************************************************************************
*				LABELS					   *
****************************************************************************


INTrqsave	DC.W 0
INTensave	DC.W 0
DMAsave		DC.W 0
GFXBase		DC.L 0
SYSStackpoint	DC.L 0
Stackpoint	DC.L 0
GFXlib		DC.B "graphics.library"

Picture		DCB.B 290*44,0
Sprite_Empty    DCB.B 10,0




****************************************************************************
*				STAR POS				   *
****************************************************************************


Sprite
	dc.w    $307A,$3100,$1000,$0000,$3220,$3300,$1000,$0000
	dc.w    $34C0,$3500,$1000,$0000,$3650,$3700,$1000,$0000
	dc.w    $3842,$3900,$1000,$0000,$3A6D,$3B00,$1000,$0000
	dc.w    $3CA2,$3D00,$1000,$0000,$3E9C,$3F00,$1000,$0000
	dc.w    $40DA,$4100,$1000,$0000,$4243,$4300,$1000,$0000
	dc.w    $445A,$4500,$1000,$0000,$4615,$4700,$1000,$0000
	dc.w    $4845,$4900,$1000,$0000,$4A68,$4B00,$1000,$0000
	dc.w    $4CB8,$4D00,$1000,$0000,$4EB4,$4F00,$1000,$0000
	dc.w    $5082,$5100,$1000,$0000,$5292,$5300,$1000,$0000
	dc.w    $54D0,$5500,$1000,$0000,$56D3,$5700,$1000,$0000
	dc.w    $58F0,$5900,$1000,$0000,$5A6A,$5B00,$1000,$0000
	dc.w    $5CA5,$5D00,$1000,$0000,$5E46,$5F00,$1000,$0000
	dc.w    $606A,$6100,$1000,$0000,$62A0,$6300,$1000,$0000
	dc.w    $64D7,$6500,$1000,$0000,$667C,$6700,$1000,$0000
	dc.w    $68C4,$6900,$1000,$0000,$6AC0,$6B00,$1000,$0000
	dc.w    $6C4A,$6D00,$1000,$0000,$6EDA,$6F00,$1000,$0000
	dc.w    $70D7,$7100,$1000,$0000,$7243,$7300,$1000,$0000
	dc.w    $74A2,$7500,$1000,$0000,$7699,$7700,$1000,$0000
	dc.w    $7872,$7900,$1000,$0000,$7A77,$7B00,$1000,$0000
	dc.w    $7CC2,$7D00,$1000,$0000,$7E56,$7F00,$1000,$0000
	dc.w    $805A,$8100,$1000,$0000,$82CC,$8300,$1000,$0000
	dc.w    $848F,$8500,$1000,$0000,$8688,$8700,$1000,$0000
	dc.w    $88B9,$8900,$1000,$0000,$8AAF,$8B00,$1000,$0000
	dc.w    $8C48,$8D00,$1000,$0000,$8E68,$8F00,$1000,$0000
	dc.w    $90DF,$9100,$1000,$0000,$924F,$9300,$1000,$0000
	dc.w    $9424,$9500,$1000,$0000,$96D7,$9700,$1000,$0000
	dc.w    $9859,$9900,$1000,$0000,$9A4F,$9B00,$1000,$0000
	dc.w    $9C4A,$9D00,$1000,$0000,$9E5C,$9F00,$1000,$0000
	dc.w    $A046,$A100,$1000,$0000,$A2A6,$A300,$1000,$0000
	dc.w    $A423,$A500,$1000,$0000,$A6FA,$A700,$1000,$0000
	dc.w    $A86C,$A900,$1000,$0000,$AA44,$AB00,$1000,$0000
	dc.w    $AC88,$AD00,$1000,$0000,$AE9A,$AF00,$1000,$0000
	dc.w    $B06C,$B100,$1000,$0000,$B2D4,$B300,$1000,$0000
	dc.w    $B42A,$B500,$1000,$0000,$B636,$B700,$1000,$0000
	dc.w    $B875,$B900,$1000,$0000,$BA89,$BB00,$1000,$0000
	dc.w    $BC45,$BD00,$1000,$0000,$BE24,$BF00,$1000,$0000
	dc.w    $C0A3,$C100,$1000,$0000,$C29D,$C300,$1000,$0000		
	dc.w    $C43F,$C500,$1000,$0000,$C634,$C700,$1000,$0000		
	dc.w    $C87C,$C900,$1000,$0000,$CA1D,$CB00,$1000,$0000		
	dc.w    $CC6B,$CD00,$1000,$0000,$CEAC,$CF00,$1000,$0000		
	dc.w    $D0CF,$D100,$1000,$0000,$D2FF,$D300,$1000,$0000		
	dc.w    $D4A5,$D500,$1000,$0000,$D6D6,$D700,$1000,$0000		
	dc.w    $D8EF,$D900,$1000,$0000,$DAE1,$DB00,$1000,$0000		
	dc.w    $DCD9,$DD00,$1000,$0000,$DEA6,$DF00,$1000,$0000		
	dc.w    $E055,$E100,$1000,$0000,$E237,$E300,$1000,$0000		
	dc.w    $E47D,$E500,$1000,$0000,$E62E,$E700,$1000,$0000		
	dc.w    $E8AF,$E900,$1000,$0000,$EA46,$EB00,$1000,$0000
	dc.w	$EC65,$ED00,$1000,$0000,$EE87,$EF00,$1000,$0000
	dc.w	$F0D4,$F100,$1000,$0000,$F2F5,$F300,$1000,$0000
	dc.w	$F4FA,$F500,$1000,$0000,$F62C,$F700,$1000,$0000
	dc.w	$F84D,$F900,$1000,$0000,$FAAC,$FB00,$1000,$0000
	dc.w	$FCB2,$FD00,$1000,$0000,$FE9A,$FF00,$1000,$0000
	dc.w	$009A,$0106,$1000,$0000,$02DF,$0306,$1000,$0000
	dc.w	$0446,$0506,$1000,$0000,$0688,$0706,$1000,$0000
	dc.w	$0899,$0906,$1000,$0000,$0ADD,$0B06,$1000,$0000
	dc.w	$0CEE,$0D06,$1000,$0000,$0EFF,$0F06,$1000,$0000
	dc.w	$10CD,$1106,$1000,$0000,$1267,$1306,$1000,$0000
	dc.w	$1443,$1506,$1000,$0000,$1664,$1706,$1000,$0000
	dc.w	$1823,$1906,$1000,$0000,$1A6D,$1B06,$1000,$0000
	dc.w	$1C4F,$1D06,$1000,$0000,$1E5F,$1F06,$1000,$0000
	dc.w	$2055,$2106,$1000,$0000,$2267,$2306,$1000,$0000
	dc.w	$2445,$2506,$1000,$0000,$2623,$2706,$1000,$0000
	dc.w	$2834,$2906,$1000,$0000,$2AF0,$2B06,$1000,$0000
	dc.w	$2CBC,$2D06,$1000,$0000
SpriteE	dc.w 	$0000,$0000


 END








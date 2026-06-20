	SECTION LOWMEM,CODE_C		Force Code To Chip RAM
*----------------------------------------------------------------------------
	OPT C-				Case Independant
*----------------------------------------------------------------------------
	include	sys:include/hardware/custom.i
*----------------------------------------------------------------------------
*----------------------------------------------------------------------------
number	=	8-1
*----------------------------------------------------------------------------
*----------------------------------------------------------------------------
*		THE MAIN ROUTINE
*----------------------------------------------------------------------------
	movem.l	a0-a6/d0-d7,-(a7)		Save all Registers
	move.l	a7,Stackpoint		Save Pointer
	jsr	Kill_OS			Kill Operating System
	jsr	SetUp2			Setup bitplanes
	jsr	Main			Mouse Wait Routine
	jsr	Help_OS			This is for the return
	move.l	Stackpoint,a7		Restore Pointer
	movem.l	(a7)+,a0-a6/d0-d7		Restore Registers
	rts
*----------------------------------------------------------------------------
Kill_OS:
*----------------------------------------------------------------------------
	move.l	$4,a6			Execbase
	clr.l	d0			Any Version
	lea	GFXlib(PC),a1		
	jsr	-552(a6)		     	Open GFX Lib
	move.l	d0,GFXBase    
	jsr	-132(a6)		     	LVO_Forbid
	move.w	$DFF002,DMAsave		Save DMA
	move.w	$DFF01C,INTensave		Save Interupt Enable
	move.w	$DFF01E,INTrqsave		Save Interupt Request
Wt:	
	btst	#0,$DFF004		Test MSB of VPOS
	bne.s	Wt
Wtt:
	cmpi.b	#55,$DFF006		Wait Line 310
	bne.s	wtt			(stops Spurious Sprite Data)
	move.w	#$7FFF,$DFF09A   	     	Disable	Interupts
	move.w	#$7FFF,$DFF096   		Disable DMA
	move.l	#Copperlist,$DFF080		Replace Copper 
	move.w	$DFF088,d0		Strobe Copper
	move.w	#%1000001111000000,$DFF096	Copper/Bitplane/Blit DMA
	rts
*----------------------------------------------------------------------------
SetUp2:
*----------------------------------------------------------------------------
	move.l	#Planes,a0		Bpl Pointer In Copper
	move.l	#Picture,d0		Picture Block
	move.l	d0,Offset			Save Screen Start Address
	add.l	#(23*46)-1,Offset		Pointer for Scroller
PlLp:
	move.w	d0,6(a0)			Load Low Word
	swap	d0			Swap Words
	move.w	d0,2(a0)			Load High Word
	rts
*----------------------------------------------------------------------------
sat:			;The BLITTER starts this
*----------------------------------------------------------------------------
	lea	Logo,a0
	lea	col,a1
	move.l	#Number,d4
loop:	move.w	(a0)+,(a1)+
	add.w	#2,a1
	dbra	d4,loop
	move.l	a0,d0
	  
	move.w	d0,Pl1l
	swap	d0
	move.w	d0,Pl1h
	swap	d0
	add.l	#256*40,d0
	move.w	d0,Pl2l
	swap	d0
	move.w	d0,Pl2h
	swap	d0
	add.l	#256*40,d0
	move.w	d0,Pl3l
	swap	d0
	move.w	d0,Pl3h
;--------------------------------------------------------------------------------------
	lea  	Logo2,a0
	lea	col2,a1
	move.l	#Number,d4
loop_2:	move.w	(a0)+,(a1)+
	add.w	#2,a1
	dbra	d4,loop_2
	move.l	a0,d0
	  
	move.w	d0,Cl1l
	swap	d0
	move.w	d0,Cl1h
	swap	d0
	add.l	#256*40,d0
	move.w	d0,Cl2l
	swap	d0
	move.w    D0,Cl2h
	swap	d0
	add.l	#256*40,d0
	move.w	d0,Cl3l
	swap	d0
	move.w	d0,Cl3h
	rts
*----------------------------------------------------------------------------
Main:	
*----------------------------------------------------------------------------
	cmpi.b	#255,$DFF006		Wait For line 255
	bne	Main
	jsr	Scroller
	bsr	Colour_Roll
	btst	#6,$BFE001		Test Mouse
	bne	Main
 	rts 
*----------------------------------------------------------------------------
Colour_Roll:
*----------------------------------------------------------------------------
	move.l	#Roll,a0
	moveq	#13,d0
Rolloop:
	move.b	7(a0),15(a0)
	sub.l	#8,a0
	dbra	d0,Rolloop
Rolloop1:
	move.l	Colourptr,a1
	move.b	(a1)+,d0
	cmp.b	#$00,d0
	bne	Colourok
	move.l	#ColourTable,Colourptr
	bra	Rolloop1
Colourok:
	move.l	a1,Colourptr
	move.b	d0,15(a0)
	rts
Colourptr:	
	dc.l	ColourTable

ColourTable:
	dc.b	$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$1f,$2f,$3f,$4f,$5f,$6f,$7f,$8f,$9f,$af,$bf,$cf,$df,$ef,$ff
	dc.b	$fe,$fd,$fc,$fb,$fa,$f9,$f8,$f7,$f6,$f5,$f4,$f3,$f2,$f1,$f0,$e0,$d0,$c0,$b0,$a0,$90,$80,$70,$60,$50,$40,$30
	dc.b	$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f,$5f,$6f,$7f,$8f,$9f,$af,$bf,$cf,$df,$ef,$ff
	dc.b	$ee,$dd,$cc,$bb,$aa,$99,$88,$77,$66,$55,$44,$33,$22,$11,$00
	even
*----------------------------------------------------------------------------
Scroller:
*----------------------------------------------------------------------------
Nxt	MOVE.L	#$C9F00000,$DFF040		A=D,12 bits Shift
	MOVE.L	#$00000000,$DFF064		Mod
	MOVE.L	#$FFFFFFFF,$DFF044		Masks
	MOVE.L	Offset,$DFF050		        Source
	MOVE.L	Offset,A1			
	SUBQ.L	#1,A1				Subtract 16 Pxls
	MOVE.L	A1,$DFF054			Destination
	MOVE.W	#23+64*16,$DFF058		BLTSIZE
WtB	BTST	#14,$DFF002			Wait for Blit to End 
	BNE.S	WtB
	SUBQ.B	#$1,Delay			Need New Character?
	BEQ.S	GetChar				If Zero Branch
	RTS					Else Return
GetChar 
	MOVE.B	#$4,Delay			New Char Delay
	ADD.L	#$1,TextPos			Next Scroller Character
	MOVE.L	#Checker,A0			Valid Chars
	MOVE.L	#Text,A1			Start of Text
	MOVE.L	TextPos,D2			Move Text Pos,D2
	MOVE.L	#0,D0				Clear for char byte
	MOVE.L	#0,D1				Clear for Char Count
	MOVE.B	(A1,D2),D0			Get Character
	BGT.S	Ch_Lp				If Not Zero,Not End
	MOVE.L	#$0000,TextPos			If Zero Wrap Text
Ch_Lp
	CMP.B	(A0)+,D0			Buffer to Checker
	BEQ.S	Match				Branch If Char Found
	ADDQ.B	#1,D1				Add to Char Count
	CMPI.B	#53,D1				All Chars checked?
	CMPI.B	#50,d1	*		50 = ascii 2 for the pause
	BEQ	Show_Off	*
	BNE.S	Ch_Lp				If Not,loop
	MOVE.B	#36,D1				Invalid Char = space 
Match
	MOVE.L	D1,D0				Save Char number
	DIVU	#20,D1				No.Chars per row in font
	MOVE.L	D1,D2				Save Row to D2
	MULU	#640,D1				40bytesx16pxls (1 line)
	MULU	#20,D2				Row no. x no. Chars
	SUB.L	D2,D0				Calc Char Horiz Pos
	MULU	#2,D0				2bytes x Horiz Pos
	ADD.L	D1,D0				Add Vert+Horiz Pos
Blit	MOVE.W	#$09F0,$DFF040			A = D Miniterm
	MOVE.L	Offset,A1			Scroller pos on screen
	MOVE.L	#Font,A0			Font
	ADD.L	D0,A0				Add CharPos
	MOVE.L	A0,$DFF050			A
	ADD.L	#44,A1				Display in Modulo border
	MOVE.L	A1,$DFF054			D
	MOVE.W	#0038,$DFF064			BLTAMOD
	MOVE.W	#0044,$DFF066			BLTDMOD
	MOVE.W	#1+64*15,$DFF058		BLISIZE
WtB1	BTST	#14,$DFF002			
	BNE.S	WtB1
	rts
*----------------------------------------------------------------------------
Show_Off:
*----------------------------------------------------------------------------
	moveq.l	#$0,d6
	jsr	sat
So_Loop:
	move.l	Add_Counter,d0
	bsr	Addition
	move.l	d0,Add_Counter
	cmp.w	#30000,d0
	bsr	Move_It
	bsr	Move_It_2
	beq	Ret
	btst	#6,$bfe001
	beq	Ret
	bra	So_Loop
Addition:
	add.w	#0001,d0
	rts
Ret:
	moveq.l	#0,d6
	rts
	even

Add_Counter:	dc.l	0
*----------------------------------------------------------------------------
Move_it:
*----------------------------------------------------------------------------
	cmpi	#31,Scflag_1
	bne	Up
	cmpi	#31,Scflag_2
	bne	Down
	bsr	pause
	clr.w	Scflag_1
	clr.w	Scflag_2
	rts
Up:	
	add.w	#40,Pl1l
	bsr	pause
	add.w	#40,Pl2l
	bsr	pause
	add.w	#40,Pl3l
	bsr	pause
	addq	#1,Scflag_1
	rts
Down:
	sub.w	#40,Pl1l
	bsr	pause
	sub.w	#40,Pl2l
	bsr	pause
	sub.w	#40,Pl3l
	bsr	pause
	addq	#1,Scflag_2
	rts

Scflag_1:	
	dc.w	0

Scflag_2:
	dc.w	0
*----------------------------------------------------------------------------
Move_it_2:
*----------------------------------------------------------------------------
	cmpi	#31,Scflag_3
	bne	Up_2
	cmpi	#31,Scflag_4
	bne	Down_2
	bsr	pause
	clr.w	Scflag_3
	clr.w	Scflag_4
	rts
Up_2:	
	sub.w	#40,Cl1l
	bsr	pause
	sub.w	#40,Cl2l
	bsr	pause
	sub.w	#40,Cl3l
	bsr	pause
	addq	#1,Scflag_3
	rts
Down_2:
	add.w	#40,Cl1l
	bsr	pause
	add.w	#40,Cl2l
	bsr	pause
	add.w	#40,Cl3l
	bsr	pause
	addq	#1,Scflag_4
	rts
Scflag_3:	
	dc.w	0
Scflag_4:
	dc.w	0
*----------------------------------------------------------------------------
pause:
*----------------------------------------------------------------------------
	move.l	#$ff,d7
ploop:
	subq	#1,d7
	cmp	0,d7
	bne	ploop
	rts
*----------------------------------------------------------------------------
Help_OS:
*----------------------------------------------------------------------------
	move.w	INTensave,d7
	bset	#$F,d7		Set Write Bit
	move.w	d7,$DFF09A	Restore INTen
	move.w	INTrqsave,d7
	bset	#$F,D7
	move.w	d7,$DFF09C	Restore INTrq
	move.w	DMAsave,d7
	bset	#$F,d7
	move.w	d7,$DFF096	Restore DMA
	move.l	GFXbase,a0
	move.l	$26(a0),$DFF080	Find/Replace System Copper
	move.l	$4,a6
	jsr	-138(a6)		LVO_Permit
	rts 
*----------------------------------------------------------------------------
Copperlist:
*----------------------------------------------------------------------------
	dc.w	$0001,$fffe
	dc.w	diwstrt,$2010
	dc.w	diwstop,$2cc9
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0

	dc.w	bplcon0,$3000
	dc.w	$108,$0
	dc.w	$10a,$0
	dc.w	$180
Col	dc.w	$0,$182,$0,$184,$0,$186,$0,$188,$0
	dc.w	$18a,$0,$18c,$0,$18e,$0

	dc.w	$e0
Pl1h	dc.w	0,$e2				
Pl1l	dc.w	0,$e4	
Pl2h	dc.w	0,$e6				
Pl2l	dc.w	0,$e8
Pl3h	dc.w	0,$ea
Pl3l	dc.w	0
	dc.w	$180,$0,$182,$0,$184,$0	;,$186,$0

	dc.w	$5601,$fffe,$0100,$0000
; --------------------------------------------------------------------------------------------
	dc.w	$0108,$0002
	dc.w	$010A,$0002
	dc.w	$6401,$fffe
	dc.w	bplcon0,$1200
	dc.w	$0102,$0000		
	dc.w	ddfstrt,$0030
	dc.w	ddfstop,$00d8

Planes
	dc.w	$00E0,$0000
	dc.w	$00E2,$0000
Bat1:
	dc.w	$6501,$fffe,$180,$0000
	dc.w	$6601,$fffe,$180,$0014
	dc.w	$6701,$fffe,$180,$0024
	dc.w	$6801,$fffe,$180,$0034
	dc.w	$6901,$fffe,$180,$0044
	dc.w	$6a01,$fffe,$180,$0054
	dc.w	$6b01,$fffe,$180,$0064
	dc.w	$6c01,$fffe,$180,$0074
	dc.w	$6d01,$fffe,$180,$0084
	dc.w	$6e01,$fffe,$180,$0094
	dc.w	$6f01,$fffe,$180,$00a4
	dc.w	$7001,$fffe,$180,$00a4
	dc.w	$7101,$fffe,$180,$0094
	dc.w	$7201,$fffe,$180,$0084
	dc.w	$7301,$fffe,$180,$0074
	dc.w	$7401,$fffe,$180,$0064
	dc.w	$7501,$fffe,$180,$0054
	dc.w	$7601,$fffe,$180,$0044
	dc.w	$7701,$fffe,$180,$0034
	dc.w	$7801,$fffe,$180,$0024
	dc.w	$7901,$fffe,$180,$0014
	dc.w	$7a01,$fffe,$180,$0000
	
	dc.w	$7b01,$fffe,$182,$0fff
	dc.w	$7c01,$fffe,$182,$0e00
	dc.w	$7d01,$fffe,$182,$0d00
	dc.w	$7e01,$fffe,$182,$0c00
	dc.w	$7f01,$fffe,$182,$0b00
	dc.w	$8001,$fffe,$182,$0a00
	dc.w	$8101,$fffe,$182,$0900
	dc.w	$8201,$fffe,$182,$0800
	dc.w	$8301,$fffe,$182,$0900	;Middle
	dc.w	$8401,$fffe,$182,$0a00
	dc.w	$8501,$fffe,$182,$0b00
	dc.w	$8601,$fffe,$182,$0c00
	dc.w	$8701,$fffe,$182,$0d00
roll	dc.w	$8801,$fffe,$182,$0e00	     
	dc.w	$8901,$fffe,$182,$0f00
	dc.w	$8a01,$fffe,$180,$0000
Bat2:
	dc.w	$8c01,$fffe,$180,$0014
	dc.w	$8d01,$fffe,$180,$0024
	dc.w	$8e01,$fffe,$180,$0034
	dc.w	$8f01,$fffe,$180,$0044
	dc.w	$9001,$fffe,$180,$0054
	dc.w	$9101,$fffe,$180,$0064
	dc.w	$9201,$fffe,$180,$0074
	dc.w	$9301,$fffe,$180,$0084
	dc.w	$9401,$fffe,$180,$0094
	dc.w	$9501,$fffe,$180,$00a4
	dc.w	$9601,$fffe,$180,$00a4
	dc.w	$9701,$fffe,$180,$00a4
	dc.w	$9801,$fffe,$180,$00a4
	dc.w	$9901,$fffe,$180,$0094
	dc.w	$9a01,$fffe,$180,$0084
	dc.w	$9b01,$fffe,$180,$0074
	dc.w	$9c01,$fffe,$180,$0064
	dc.w	$9d01,$fffe,$180,$0054
	dc.w	$9e01,$fffe,$180,$0044
	dc.w	$9f01,$fffe,$180,$0034
	dc.w	$a001,$fffe,$180,$0024
	dc.w	$a101,$fffe,$180,$0014
	dc.w	$a201,$fffe,$180,$0000
; ------------------------------------------------------------------------------------
	dc.w	$a301,$fffe
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0

	dc.w	$180
Col2	dc.w	$0,$182,$0,$184,$0,$186,$0,$188,$0
	dc.w	$18a,$0,$18c,$0,$18e,$0
	dc.w	$108,0
	dc.w	$10a,0
	dc.w	$a401,$fffe,$0100,$3200

	dc.w	$e0
Cl1h	dc.w	0,$e2				
Cl1l	dc.w	0,$e4	
Cl2h	dc.w	0,$e6				
Cl2l	dc.w	0,$e8
Cl3h	dc.w	0,$ea
Cl3l	dc.w	0
	dc.w	$180,$0,$182,$0,$184,$0	;,$186,$0

	dc.w	$ffff,$fffe		
*----------------------------------------------------------------------------
*		Variables and includes
*----------------------------------------------------------------------------
GFXlib		dc.b	"graphics.library"
		even
Stackpoint	dc.l	0
GFXbase		dc.l	0
INTrqsave		dc.w	0
INTensave		dc.w	0
DMAsave		dc.w	0
Offset		dc.l	0
Delay		dc.b	$12
	even
TextPos		dc.l	0
	even
Font		Incbin	"source:bitmaps1/scroll+font.raw"
	even
logo		incbin	"source:bitmaps1/scroll+dis.raw"
	Even	
logo2		incbin	"source:bitmaps1/scroll+crime.raw"
	Even	
Checker		dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXY"
		dc.b	"Z0123456789 ?.,[]`:;-+/%*()!"
			;[] means speech marks

Picture		dcb.b	(290*46),0
*----------------------------------------------------------------------------
*				SCROLL TEXT				    *
*----------------------------------------------------------------------------
	Even
Text:
	dc.b " WELCOME TO ANOTHER "
	dc.b " "
	dc.b "     AMIGA CODERS CLUB   ",2
	dc.b "  DISK "
	dc.b "PACKED WITH SOURCE AND TUTORIALS"
	dc.b " TO HELP "
	dc.b "           YOU         ",2
	dc.b " THE BUDDING PROGRAMMER, "
	dc.b " THE INTRO WAS PUT TOGETHER BY"
	dc.b "         MEGABASS      ",2
	dc.b "  [GIVING DISORGANIZED CRIME A PLUG AT THE SAME TIME]"
	dc.b "   BUT ONLY WITH THE HELP OF ACC"
	dc.b "                                           "
*----------------------------------------------------------------------------
	end

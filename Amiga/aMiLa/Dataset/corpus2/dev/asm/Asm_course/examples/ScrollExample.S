;*******************************************************
;* Example Of An Scroller Which Uses The Topaz RomFont *
;*                                                     *
;*      ASM-One Example Coded By Mads Henriksen.       *
;*    Non-System Startup Coded by Rune Gram-Madsen     *
;*                                                     *
;*       All rights reserved. Copyright (c) 1990       *
;*******************************************************

;*****************
;*   Constants   *
;*****************

OldOpenLibrary	= -408
CloseLibrary	= -414
OpenFont	= -72
CloseFont	= -78

DMASET=	%1000010111000000
;	 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA (if this isn't set, sprites disappear!)
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA

START:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack

;***********************************
;*   CLOSE ALL SYSTEM INTERRUPTS   *
;*                                 *
;*      START DEMO INTERRUPTS      *
;***********************************

	MOVE.L	$4.W,A6			; Exec pointer to A6
	LEA.L	GfxName(PC),A1		; Set library pointer
	MOVEQ	#0,D0
	JSR	OldOpenLibrary(A6)	; Open graphics.library
	MOVE.L	D0,A1			; Use Base-pointer
	MOVE.L	$26(A1),OLDCOP1		; Store copper1 start addr
	MOVE.L	$32(A1),OLDCOP2		; Store copper1 start addr
	MOVE.L	A1,-(SP)		; Save The GfxBase Pointer

OPENROMFONT:
	MOVE.L	A1,A6			; Use The GfxBase Pointer
	LEA.L	TxtAttr(PC),A0		; FontStructure Pointer To A0
	JSR	OpenFont(A6)		; Open The Font
	MOVE.L	D0,A1			; Save The Font Pointer

FINDROMFONT:
	MOVE.L	34(A1),FONTPTR		; Save The RomFont Pointer
	MOVE.W	38(A1),FONTMOD		; Save The RomFont Modulo

CLOSEROMFONT
	JSR	CloseFont(A6)		; Close The Font

	MOVE.L	(SP)+,A1		; Get The GfxBase Pointer
	JSR	CloseLibrary(A6)	; Close graphics library

	LEA	$DFF000,A6
	MOVE.W	$1C(A6),INTENA		; Store old INTENA
	MOVE.W	$2(A6),DMACON		; Store old DMACON
	MOVE.W	$10(A6),ADKCON		; Store old ADKCON

	MOVE.W	#$7FFF,$9A(A6)		; Clear interrupt enable

	BSR.L	Wait_Vert_Blank

	MOVE.W	#$7FFF,$96(A6)		; Clear DMA channels
	MOVE.L	#COPLIST,$80(A6)	; Copper1 start address
	MOVE.W	#DMASET!$8200,$96(A6)	; DMA kontrol data
	MOVE.L	$6C.W,OldInter		; Store old inter pointer
	MOVE.L	#INTER,$6C.W		; Set interrupt pointer

	MOVE.W	#$7FFF,$9C(A6)		; Clear request
	CLR.W	$88(A6)			; Start copper1
	MOVE.W	#$C020,$9A(A6)		; Interrupt enable

;************************************
;*   MAIN LOOP  TEST MOUSE BOTTON   *
;************************************

LOOP:
	BTST	#6,$BFE001		; Test left mouse button
	BNE.S	LOOP

;*****************************************
;*					 *
;*   RESTORE SYSTEM INTERRUPTS ECT ECT   *
;*					 *
;*****************************************

	LEA	$DFF000,A6

	MOVE.W	#$7FFF,$9A(A6)		; Disable interrupts

	BSR.S	Wait_Vert_Blank

	MOVE.W	#$7FFF,$96(A6)
	MOVE.L	OldCop1(PC),$80(A6)	; Restore old copper1
	MOVE.L	OldCop2(PC),$84(A6)	; Restore old copper1
	MOVE.L	OldInter(PC),$6C.W	; Restore inter pointer
	MOVE.W	DMACON,D0		; Restore old DMACON
	OR.W	#$8000,D0
	MOVE.W	D0,$96(A6)		
	MOVE.W	ADKCON,D0		; Restore old ADKCON
	OR.W	#$8000,D0
	MOVE.W	D0,$9E(A6)
	MOVE.W	INTENA,D0		; Restore inter data
	OR.W	#$C000,D0
	MOVE.W	#$7FFF,$9C(A6)
	MOVE.W	D0,$9A(A6)
	CLR.W	$88(A6)			; Restart old copper1
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	RTS

;*** WAIT VERTICAL BLANK ***

Wait_Vert_Blank:
	TST.B	$5(A6)
	BEQ.S	Wait_Vert_Blank
.loop	TST.B	$5(A6)
	BNE.S	.loop
	RTS

;*** DATA AREA ***

GfxName		DC.B	'graphics.library',0
		even
DosBase		DC.L	0
OldInter	DC.L	0
OldCop1		DC.L	0
OldCop2		DC.L	0
INTENA		DC.W	0
DMACON		DC.W	0
ADKCON		DC.W	0

TxtAttr		DC.L	FNTNAME
		DC.W	8
		DC.B	0
		DC.B	0
FntName		DC.B	'topaz.font',0,0

FontPtr		DC.L	0
FontMod		DC.W	0

SCROLLCOUNT	DC.W	0
SCROLLPTR	DC.L	SCROLLTEXT
SCROLLTEXT	DC.B	'This Is Just A Test...          ',0,0

;**********************************
;*				  *
;*   INTERRUPT ROUTINE. LEVEL 3   *
;*				  *
;**********************************

INTER:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack
	LEA.L	$DFF000,A6
	MOVE.L	#SCREEN,$E0(A6)

;---  Place your interrupt routine here  ---

	BSR.S	MAKESCROLL		; Call Our Scroll Routine

	MOVE.W	#$4020,$9C(A6)		; Clear interrupt request
	MOVEM.L	(A7)+,D0-D7/A0-A6 	; Get registers from stack
	RTE

;******  Scroll Routine  ******

MAKESCROLL:
	TST.W	SCROLLCOUNT		; Have There Been Scrolled 8 Times?
	BEQ.S	MAKESCROLL1		; Yes, Jump To MakeScroll1
	SUBQ.W	#1,SCROLLCOUNT		; No, Sub ScrollCount
	BRA.S	MAKESCROLL5		; And Jump To Scroll Routine

MAKESCROLL1:
	MOVE.L	SCROLLPTR(PC),A0	; ScrollText Pointer To A0
	MOVEQ	#0,D0			; Clear D0
	MOVE.B	(A0)+,D0		; Get The New Character In D0
	BNE.S	MAKESCROLL2		; If Not Zero Then Jump To MakeScroll2
	MOVE.L	#SCROLLTEXT,SCROLLPTR	; If Zero Then Restore Text Pointer
	BRA.S	MAKESCROLL1		; And Repeat The Same Procedure Again

MAKESCROLL2:
	MOVE.L	A0,SCROLLPTR		; Save The Increased ScrollText Pointer
	MOVE.W	#7,SCROLLCOUNT		; ScrollCounter = 8/ScrollSpeed-1 ('7')

MAKESCROLL3:
	LEA.L	SCREEN+120*42+40,A0	; Screen Pointer In A0
	MOVE.L	FONTPTR(PC),A1		; Get The RomFont Pointer In A1
	SUB.B	#32,D0			; Sub #32 To Fetch The Right Char
	ADD.W	D0,A1			; And Add To RomFont Pointer In A1
	MOVEQ	#0,D0			; Clear D0
	MOVEQ	#7,D7			; FontHeight-1 In D7

MAKESCROLL4:
	MOVE.B	(A1,D0.W),(A0)		; Load Characters To Screen
	ADD.W	FONTMOD(PC),D0		; Add Font Modulo To D0
	ADD.W	#42,A0			; And Add ScreenWidth To A0
	DBF	D7,MAKESCROLL4		; Loop FontHeight Times To MakeScroll4

MAKESCROLL5:
	BTST	#14,$02(A6)		; Test If Blitter Is Finished
	BNE.S	MAKESCROLL5		; No Sir, And Wait Again
	MOVE.L	#$19F00002,$40(A6)	; '1' = ScrollSpeed... Look 19 Lines Up
	MOVE.L	#$FFFFFFFF,$44(A6)	; Source A : First/Last Masking
	MOVE.L	#SCREEN+128*42-2,$50(A6); Source A : Pointer To ScrollArea
	MOVE.L	#SCREEN+128*42-2,$54(A6); Destination : Pointer To ScrollArea
	MOVE.L	#0,$64(A6)		; Source A And Destination Modulo
	MOVE.W	#8*64+21,$58(A6)	; BlitterSize And BlitterStart
	RTS				; Return From This Routine

;*****************************
;*			     *
;*      COPPER1 PROGRAM      *
;*			     *
;*****************************

	SECTION	Copper,DATA_C

COPLIST:
	DC.W	$0100,$1200	; Bit-Plane control reg.
	DC.W	$0102,$0000	; Hor-Scroll
	DC.W	$0104,$0010	; Sprite/Gfx priority
	DC.W	$0108,$0002	; Modolu (odd)
	DC.W	$010A,$0000	; Modolu (even)
	DC.W	$008E,$2C81	; Screen Size
	DC.W	$0090,$2CC1	; Screen Size
	DC.W	$0092,$0038	; H-start
	DC.W	$0094,$00D0	; H-stop
	DC.W	$0180,$0000	; Color #0 = 000 (Black)
	DC.W	$A401,$FFFE	; And Wait For The Right ScanLine
	DC.W	$0182,$0CDE	; Now Some Color Exchanging
	DC.W	$A501,$FFFE	; To Make The Right Scroll Colors.
	DC.W	$0182,$0ABC	; Bla.Bla.Bla.
	DC.W	$A601,$FFFE	; Bla.Bla.
	DC.W	$0182,$089A	; Bla.
	DC.W	$A701,$FFFE
	DC.W	$0182,$0678
	DC.W	$A801,$FFFE
	DC.W	$0182,$0876
	DC.W	$A901,$FFFE
	DC.W	$0182,$0A98
	DC.W	$AA01,$FFFE
	DC.W	$0182,$0CBA
	DC.W	$AB01,$FFFE
	DC.W	$0182,$0EDC
	DC.W	$AC01,$FFFE
	DC.W	$0182,$0FED
	DC.L	$FFFFFFFE	; This Means : End Of CopperList.

;*****************************
;*			     *
;*      SCREEN DATA AREA     *
;*			     *
;*****************************

	SECTION	Screen,BSS_C

SCREEN	DS.B	256*42		; Clear Our ScrollScreen

;************************************************
;*	   Non-System Draw Line Example		*
;*    Made as help to demo and game creaters	*
;*						*
;*  ASM-One example coded by Rune Gram-Madsen	*
;*						*
;*   All rights reserved. Copyright (c) 1990	*
;************************************************

; Move the mouse around to draw a lot of lines.

;*****************
;*   Constants   *
;*****************

OldOpenLibrary	= -408
CloseLibrary	= -414

DMASET=	%1000000111000000
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
	MOVE.W	#$C020,$9A(A6)		; Interrupt enable

;****       Your main routine      ****


;**** Main Loop  Test mouse button ****

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
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	RTS

;*** WAIT VERTICAL BLANK ***

Wait_Vert_Blank:
	BTST	#0,$5(A6)
	BEQ.S	Wait_Vert_Blank
.loop	BTST	#0,$5(A6)
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

;**********************************
;*				  *
;*    INTERRUPT ROUTINE. LEVEL 3  *
;*				  *
;**********************************

INTER:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack
	LEA.L	$DFF000,A6
	MOVE.L	#SCREEN,$E0(A6)

;---  Place your interrupt routine here  ---

	BSR.S	INITLINE	; Init line registers

	MOVEQ	#0,D0		; Start X - Y coords
	MOVEQ	#0,D1

	MOVEQ	#0,D3		; End X - Y coords
	MOVEQ	#0,D2

	MOVE.W	$A(a6),D3	; Get mouse position
	MOVE.B	D3,D2
	LSR.W	#8,D3

	BSR.S	DRAWLINE	; Draw the line

	MOVE.W	#$4020,$9C(A6)		; Clear interrupt request
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	RTE

;********************
;*  Init line draw  *
;********************

SINGLE = 0		; 2 = SINGLE BIT WIDTH
BYTEWIDTH = 40

; The below registers only have to be set once each time
; you want to draw one or more lines.

INITLINE:
	LEA.L	$DFF000,A6

.WAIT:	BTST	#$E,$2(A6)
	BNE.S	.WAIT

	MOVEQ	#-1,D1
	MOVE.L	D1,$44(A6)		; FirstLastMask
	MOVE.W	#$8000,$74(A6)		; BLT data A
	MOVE.W	#BYTEWIDTH,$60(A6)	; Tot.Screen Width
	MOVE.W	#$FFFF,$72(A6)
	LEA.L	SCREEN,A5
	RTS

;*****************
;*   DRAW LINE   *
;*****************

; USES D0/D1/D2/D3/D4/D7/A5/A6

DRAWLINE:
	SUB.W	D3,D1
	MULU	#40,D3		; ScreenWidth * D3

	MOVEQ	#$F,D4
	AND.W	D2,D4		; Get lowest bits from D2

;--------- SELECT OCTANT ---------

	SUB.W	D2,D0
	BLT.S	DRAW_DONT0146
	TST.W	D1
	BLT.S	DRAW_DONT04

	CMP.W	D0,D1
	BGE.S	DRAW_SELECT0
	MOVEQ	#$11+SINGLE,D7		; Select Oct 4
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT0:
	MOVEQ	#1+SINGLE,D7		; Select Oct 0
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED

DRAW_DONT04:
	NEG.W	D1
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT1
	MOVEQ	#$19+SINGLE,D7		; Select Oct 6
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT1:
	MOVEQ	#5+SINGLE,D7		; Select Oct 1
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED


DRAW_DONT0146:
	NEG.W	D0
	TST.W	D1
	BLT.S	DRAW_DONT25
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT2
	MOVEQ	#$15+SINGLE,D7		; Select Oct 5
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT2:
	MOVEQ	#9+SINGLE,D7		; Select Oct 2
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED
DRAW_DONT25:
	NEG.W	D1
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT3
	MOVEQ	#$1D+SINGLE,D7		; Select Oct 7
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT3:
	MOVEQ	#$D+SINGLE,D7		; Select Oct 3
	EXG	D0,D1

;---------   CALCULATE START   ---------

DRAW_OCTSELECTED:
	ADD.W	D1,D1			; 2*dy
	ASR.W	#3,D2			; x=x/8
	EXT.L	D2
	ADD.L	D2,D3			; d3 = x+y*40 = screen pos
	MOVE.W	D1,D2			; d2 = 2*dy
	SUB.W	D0,D2			; d2 = 2*dy-dx
	BGE.S	DRAW_DONTSETSIGN
	ORI.W	#$40,D7			; dx < 2*dy
DRAW_DONTSETSIGN:

;---------   SET BLITTER   ---------

.WAIT:
	BTST	#$E,$2(A6)		; Wait on the blitter
	BNE.S	.WAIT

	MOVE.W	D2,$52(A6)		; 2*dy-dx
	MOVE.W	D1,$62(A6)		; 2*d2
	SUB.W	D0,D2			; d2 = 2*dy-dx-dx
	MOVE.W	D2,$64(A6)		; 2*dy-2*dx

;---------   MAKE LENGTH   ---------

	ASL.W	#6,D0			; d0 = 64*dx
	ADD.W	#$0042,D0		; d0 = 64*(dx+1)+2

;---------   MAKE CONTROL 0+1   ---------

	ROR.W	#4,D4
	ORI.W	#$BEA,D4		; $B4A - DMA + Minterm
	SWAP	D7
	MOVE.W	D4,D7
	SWAP	D7
	ADD.L	A5,D3		; SCREEN PTR

	MOVE.L	D7,$40(A6)		; BLTCON0 + BLTCON1
	MOVE.L	D3,$48(A6)		; Source C
	MOVE.L	D3,$54(A6)		; Destination D
	MOVE.W	D0,$58(A6)		; Size
	RTS

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
	DC.W	$0108,$0000	; Modolu (odd)
	DC.W	$010A,$0000	; Modolu (even)
	DC.W	$008E,$2C81	; Screen Size
	DC.W	$0090,$2CC1	; Screen Size
	DC.W	$0092,$0038	; H-start
	DC.W	$0094,$00D0	; H-stop

	DC.W	$0180,$0000	; Color #0 = 000
	DC.W	$0182,$0FFF	; Color #1 = fff
	DC.L	$FFFFFFFE

;*****************************
;*			     *
;*      SCREEN DATA AREA     *
;*			     *
;*****************************

	SECTION	Screen,BSS_C

SCREEN	DS.B	40*256

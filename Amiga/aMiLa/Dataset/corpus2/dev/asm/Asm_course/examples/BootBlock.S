;************************************************
;*	 Non-system virus check bootblock	*
;*    An example of how to make Boot Blocks	*
;*						*
;*   ASM-One example coded by Rune Gram-Madsen	*
;*						*
;*   All rights reserved. Copyright (c) 1990	*
;************************************************

WriteFlag = 0	; 1 to write bootblock

;*****************
;*   Constants   *
;*****************

	IF	WriteFlag=1
	AUTO	WS\BEGIN\0\2\CC\
	ENDC

DMASET=		%1000000110000000
;		 -----a-bcdefghij

;		a: Blitter Nasty
;		b: Bitplane DMA (if this isn't set sprites disapear!)
;		c: Copper DMA
;		d: Blitter DMA
;		e: Sprite DMA
;		f: Disk DMA
;	      g-j: Audio 3-0 DMA

OpenLibrary=	-408
CloseLibrary=	-414
OpenFont=	-72
AllocRaster=	-492
FreeRaster=	-498

	SECTION	FIRST,CODE_C

START	MOVE.W	#$4E75,EndAddr	; Put RTS into code
	BRA.B	GO

;*******  Boot block  *******

BEGIN	DC.B	'DOS',0
	DC.L	0
	DC.L	880

; A5 / FONTPTR
; D7 / MODULU

	RSRESET

OldCopper	RS.L	1
ScreenPtr	RS.L	1

GO:	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA.L	START(PC),A4
	MOVE.L	$4.W,A6
	LEA.L	GRAPNAME(PC),A1		; Gfx Name
	MOVEQ	#0,D0
	JSR	OPENLIBRARY(A6)
	MOVE.L	D0,A6			; Gfx Base
	MOVE.L	$26(A6),OldCopper(A4)	; Get old Copper Ptr.

;---  Get charset  ---

	LEA	TEXTATTR(PC),A0
	LEA	FONTNAME(PC),A1
	MOVE.L	A1,(A0)
	JSR	OPENFONT(A6)
	MOVE.L	D0,A0
	MOVE.L	34(A0),A5		; Bit ptr
	MOVE.W	38(A0),D7		; Modulo

;---  Allocate Raster  ---

	MOVE.W	#320,D0			; Width
	MOVE.W	#260,D1			; Higth
	JSR	AllocRaster(A6)
	MOVE.L	D0,ScreenPtr(A4)

;--- Clear screen  ---

	MOVE.L	D0,A0
	MOVE.W	#320/8*260/4-1,D1	; Clear 320/8 bytes wide
	MOVEQ	#0,D2			; times 260 bytes high
.LOOPC	MOVE.L	D2,(A0)+		; in longwords / 4
	DBF	D1,.LOOPC

;---  Set BPL ptrs  ---

	LEA.L	BITPLANES+2(PC),A0
	MOVEQ	#40,D1
	ADD.L	D0,D1
	SWAP	D0		; High word of pointer
	MOVE.W	D0,(A0)		; Store high 1
	ADDQ.W	#4,A0
	SWAP	D0		; Low word of pointer
	MOVE.W	D0,(A0)		; Store low 1
	ADDQ.W	#4,A0
	SWAP	D1		; High word of pointer
	MOVE.W	D1,(A0)		; Store high 2
	ADDQ.W	#4,A0
	SWAP	D1		; Low word of pointer
	MOVE.W	D1,(A0)		; Store low 2

	MOVE.L	A6,-(A7)	; Store Graphics library base

;---  Set DMA registers  ---

	MOVE.L	#$DFF000,A6
	MOVE.W	$1C(A6),-(A7)		; Store old inter data
	MOVE.W	$02(A6),-(A7)		; Store old DMA data
	MOVE.L	#$7FFF7FFF,$9A(A6)	; Disable interrupts
	MOVE.W	#$7FFF,$96(A6)		; Disable all DMA's

	LEA	COPLIST(PC),A0
	MOVE.L	A0,$80(A6)		; Copper1 start adress
	MOVE.W	#DMASET!$8200,$96(A6)	; Enable DMA's
	CLR.W	$88(A6)			; Start copper1

; A5 = CHARSET
; D7 = CHARDIST

PRINTTEXT:
	MOVE.L	ScreenPtr(A4),A1	; Screenptr
	LEA.L	TEXT(PC),A0
	ADD.W	#40,A1
	MOVEQ	#0,D1
.LOOP0
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0		; Get char
	BEQ.S	.END			; Last char ???

	CMP.B	#10,D0			; A return char
	BNE.S	.CONT
	MOVEQ	#0,D1			; first column
	ADD.W	#40*8,A1		; next line
	BRA.S	.LOOP0			; Get next char

.CONT	CMP.B	#1,D0			; Space mark
	BNE.S	.CONT2
	MOVE.B	(A0)+,D0		; Get spaces
	ADD.W	D0,D1			; Add spaces
	BRA.S	.LOOP0

.CONT2	MOVE.L	A1,A2			; a2 = screen ptr
	ADD.W	D1,A2			; a2 = screen char ptr
	MOVE.L	A5,A3
	SUB.W	#$20,D0
	ADD.W	D0,A3			; A3 = Char pointer

	MOVEQ	#8-1,D0			; copy 8 bytes
.LOOP1	MOVE.B	(A3),(A2)		; Copy one byte from char
	ADD.W	D7,A3			; next byte in char
	ADD.W	#40,A2			; next raster line
	DBF	D0,.LOOP1		; Loop ^
	ADDQ.W	#1,D1			; move 1 right
	BRA.S	.LOOP0			; Loop ^^

.END	BTST	#6,$BFE001		; Wait mouse
	BNE.S	.END			; Pressed ???

;---  The End  ---

	MOVE.L	#$7FFF7FFF,$9A(A6)	; Disable interrupts
	OR.L	#$8000C000,(A7)		; Set enable bits
	MOVE.W	(A7)+,$96(A6)		; Enable interruptr
	MOVE.W	(A7)+,$9A(A6)		; Restore old inter data
	MOVE.L	OldCopper(A4),$80(A6)	; Restore old copper ptr
	CLR.W	$88(A6)			; Start Copper

;---  DeAllocate Raster  ---

	MOVE.L	(A7)+,A6
	MOVE.L	ScreenPtr(A4),A0
	MOVE.W	#320,D0			; Width
	MOVE.W	#260,D1			; Higth
	JSR	FreeRaster(A6)

	MOVE.L	A6,A1			; Close graphics library
	MOVE.L	$4.W,A6
	JSR	CLOSELIBRARY(A6)

	MOVEM.L	(A7)+,D0-D7/A0-A6

EndAddr	MOVE.L	$0004.W,A6
	LEA	DOSNAME(PC),A1
	MOVE.W	#'do',(A1)
	JSR	-96(A6)
	MOVE.L	D0,A0
	MOVE.L	22(A0),A0
	MOVEQ	#0,D0
	RTS

TEXTATTR:
	DC.L	0
	DC.W	8
	DC.B	0
	DC.B	0
	DC.W	8
FONTNAME:	DC.B	'topaz.font',0
GRAPNAME:	DC.B	'graph'
DOSNAME:	DC.B	'ics.library',0

;*****************************
;*			     *
;*      COPPER1 PROGRAM      *
;*			     *
;*****************************

COPLIST:
	DC.L	$0182057C
	DC.L	$01840D85
	DC.L	$01860FA7
	DC.L	$01A20AAA
	DC.L	$01A40666
	DC.L	$01A60FFF
BITPLANES:
	DC.L	$00E00000
	DC.L	$00E20000
	DC.L	$00E40000
	DC.L	$00E60000
	DC.L	$01002200
	DC.L	$01020001
	DC.L	$01040000
	DC.L	$01080000
	DC.L	$010A0000
	DC.L	$008E2C78
	DC.L	$00902CC8
	DC.L	$00920038
	DC.L	$009400D0
	DC.L	$01800000
	DC.L	$3007FFFE
	DC.L	$01800220
	DC.L	$4007FFFE
	DC.L	$01800330
	DC.L	$5007FFFE
	DC.L	$01800440
	DC.L	$6007FFFE
	DC.L	$01800550
	DC.L	$7007FFFE
	DC.L	$01800660
	DC.L	$8007FFFE
	DC.L	$01800770
	DC.L	$9007FFFE
	DC.L	$01800880
	DC.L	$A007FFFE
	DC.L	$01800990
	DC.L	$B007FFFE
	DC.L	$01800880
	DC.L	$C007FFFE
	DC.L	$01800770
	DC.L	$D007FFFE
	DC.L	$01800660
	DC.L	$E007FFFE
	DC.L	$01800550
	DC.L	$F007FFFE
	DC.L	$01800440
	DC.L	$FFDFFFFE
	DC.L	$0007FFFE
	DC.L	$01800330
	DC.L	$1007FFFE
	DC.L	$01800220
	DC.L	$2007FFFE
	DC.L	$01800110
	DC.L	$FFFFFFFE

TEXT:
 DC.B	10
 DC.B	10
 DC.B	10
 DC.B	10
 DC.B	10
 DC.B	10
 DC.B	10
 DC.B	1,8,'This disk was installed',10
 DC.B	10
 DC.B	1,15,'using the',10
 DC.B	10
 DC.B	1,9,'AsmOne Macro Assembler',10
 DC.B	10
 DC.B	10
 DC.B	10
 DC.B	1,2,'---  NO VIRUS ON THIS BOOTBLOCK  ---',10
 DC.B	10
 DC.B	10
 DC.B	10
 DC.B	1,8,'! Press mouse to boot !',0

END:
	IF	END-BEGIN>1024
	FAIL
	ENDC

*
*	Sine-Sprite 2 -- This version uses a list of absolute coordinates
*	so you can use a program like Sinus Producer
*
*	Note: This version flickers a bit -- Sorry!

	SECTION SINE-SPRITE2,CODE
	OPT	C-			NO CASE SENSITIVITY

**********

	INCDIR	SYS:INCLUDE/
	INCLUDE	HARDWARE/CUSTOM.I
	INCLUDE	EXEC/EXEC_LIB.I

**********

START	MOVE.L	A7,STPOINT		SAVE STACK POINTER
	MOVEM.L	A0-A6/D0-D7,-(A7)	SAVE ALL REGISTERS
	MOVE.L	#$DFF000,A5		I USE A5 AS MY HARDWARE OFFSET REG.
	CALLEXEC FORBID			TURN OFF MULTITASKING
	LEA	GFXNAME(PC),A1
	
	CLR.L	D0
	CALLEXEC OPENLIBRARY		OPEN GFX LIBRARY
	MOVE.L	D0,GFXBASE
	MOVE.W	DMACONR(A5),DMASAVE	SAVE CLI DMA SETTINGS


WAIT1	BTST	#0,VPOSR(A5)		WAIT FOR VBL
	BNE.S	WAIT1			BEFORE TURNING
WAIT2	CMPI.B	#55,VHPOSR(A5)		SPRITE DMA OFF TO
	BNE.S	WAIT2			PREVENT CRAP APPEARING

SET_UP	MOVE.W	#$7FFF,DMACON(A5)	ALL DMA OFF
	MOVE.L	#NEWCOP,COP1LC(A5)	STICK MY NEW COPPER IN...
	MOVE.L	COPJMP1(A5),D0		...AND STROBE IT
	MOVE.W	#%1000001110100000,DMACON(A5)	COP/BPL/SPR DMA

**********

	move.l	#Sprite1,d0
	move.w	d0,Spr0l
	swap	d0
	move.w	d0,Spr0h

	move.l	#Screen,d0
	move.w	d0,Pl1l
	swap	d0
	move.w	d0,Pl1h

	lea	Sintab,a0		A0 aloways contains Sine pointer

	move.l	$6c,OldInt+2
	move.l	#NewInt,$6c		Setup interrupt

.Wait	btst	#6,$bfe001
	bne.s	.Wait

	bra	quit

NewInt	move.b	(a0)+,Spr1Y
	move.b	(a0)+,Spr1X	

	move.b	Spr1Y,d0
	add.b	#17,d0
	move.b	d0,Spr1Y2

	cmpi.l	#$fffffffe,(a0)
	bne.s	.Cont

	lea	Sintab,a0

.Cont	move.b	(a0)+,Spr1Y			Moves 2 bytes for more speed!
	move.b	(a0)+,Spr1X	

	move.b	Spr1Y,d0
	add.b	#17,d0
	move.b	d0,Spr1Y2

	cmpi.l	#$fffffffe,(a0)
	bne.s	OldInt

	lea	Sintab,a0

OldInt	jmp	$0

**********

*	This list was produced entirely by hand....

*	Only joking! I used Sinus Producer + Translator v1.1 to do it

SinTab

	dc.b	$8B,$66,$8B,$67,$8B,$68,$8B,$69,$8A,$6A,$8A,$6B,$89,$6C,$89
	dc.b	$6D,$88,$6E,$87,$6F,$86,$70,$85,$71,$85,$72,$84,$73,$82,$74
	dc.b	$82,$75,$80,$76,$7F,$76,$7E,$77,$7D,$78,$7C,$79,$7B,$79,$7A
	dc.b	$7A,$78,$7A,$77,$7B,$77,$7B,$75,$7C,$74,$7C,$73,$7C,$72,$7C
	dc.b	$72,$7D,$71,$7D,$70,$7D,$70,$7D,$6F,$7D,$6F,$7C,$6E,$7D,$6E
	dc.b	$7C,$6E,$7C,$6E,$7C,$6E,$7C,$6E,$7C,$6E,$7B,$6F,$7B,$6F,$7B
	dc.b	$70,$7A,$70,$7A,$71,$7A,$72,$79,$73,$79,$74,$79,$75,$79,$76
	dc.b	$79,$78,$78,$79,$78,$7B,$78,$7C,$78,$7E,$78,$7F,$78,$81,$78
	dc.b	$83,$78,$84,$78,$86,$78,$88,$78,$8A,$78,$8B,$78,$8C,$79,$8E
	dc.b	$79,$90,$79,$92,$7A,$94,$7A,$96,$7A,$97,$7B,$99,$7B,$9B,$7C
	dc.b	$9C,$7D,$9F,$7D,$A0,$7E,$A2,$7F,$A3,$7F,$A4,$80,$A5,$81,$A6
	dc.b	$82,$A7,$83,$A8,$84,$A8,$85,$A9,$86,$A9,$87,$AA,$88,$AA,$89
	dc.b	$AA,$89,$AA,$8A,$AA,$8B,$A9,$8C,$A9,$8D,$A8,$8E,$A8,$8F,$A7
	dc.b	$90,$A6,$91,$A5,$91,$A4,$92,$A3,$93,$A2,$94,$A0,$95,$9F,$95
	dc.b	$9C,$96,$9B,$97,$99,$97,$97,$98,$96,$98,$94,$99,$92,$99,$90
	dc.b	$99,$8E,$9A,$8C,$9A,$8B,$9A,$8A,$9A,$88,$9B,$86,$9B,$84,$9B
	dc.b	$83,$9B,$81,$9B,$7F,$9B,$7E,$9B,$7C,$9B,$7B,$9B,$79,$9A,$78
	dc.b	$9A,$76,$9A,$75,$9A,$74,$99,$73,$99,$72,$99,$71,$99,$70,$98
	dc.b	$70,$98,$6F,$98,$6F,$98,$6E,$97,$6E,$97,$6E,$97,$6E,$97,$6E
	dc.b	$96,$6E,$96,$6E,$96,$6F,$96,$6F,$96,$70,$96,$70,$96,$71,$96
	dc.b	$72,$96,$72,$96,$73,$96,$74,$97,$75,$97,$77,$97,$77,$98,$78
	dc.b	$98,$7A,$99,$7B,$99,$7C,$9A,$7D,$9B,$7E,$9B,$7F,$9C,$80,$9D
	dc.b	$82,$9E,$82,$9F,$84,$A0,$85,$A1,$85,$A1,$86,$A2,$87,$A4,$88
	dc.b	$A5,$89,$A6,$89,$A7,$8A,$A8,$8A,$A9,$8B,$AA,$8B,$AB,$8B,$AC
	dc.b	$8B,$AD,$8B,$AE,$8B,$AF,$8B,$B0,$8B,$B1,$8B,$B2,$8B,$B3,$8B
	dc.b	$B4,$8B,$B5,$8A,$B6,$8A,$B7,$89,$B8,$89,$B8,$88,$B9,$87,$BA
	dc.b	$87,$BA,$86,$BB,$85,$BB,$84,$BC,$84,$BC,$83,$BC,$82,$BC,$81
	dc.b	$BC,$80,$BC,$80,$BC,$7F,$BC,$7E,$BC,$7E,$BB,$7D,$BB,$7C,$BB
	dc.b	$7C,$BA,$7B,$BA,$7B,$B9,$7B,$B8,$7A,$B8,$7B,$B7,$7A,$B6,$7A
	dc.b	$B5,$7B,$B4,$7B,$B3,$7B,$B2,$7B,$B1,$7C,$B0,$7D,$AF,$7D,$AE
	dc.b	$7E,$AC,$7F,$AB,$80,$AA,$82,$A9,$82,$A8,$84,$A6,$85,$A5,$87
	dc.b	$A4,$88,$A3,$8A,$A2,$8B,$A0,$8C,$9F,$8E,$9E,$90,$9D,$92,$9C
	dc.b	$93,$9B,$95,$9A,$97,$99,$99,$98,$9B,$97,$9D,$96,$9F,$95,$A1
	dc.b	$94,$A3,$93,$A5,$92,$A8,$92,$AA,$91,$AB,$90,$AD,$90,$AF,$8F
	dc.b	$B0,$8E,$B3,$8E,$B4,$8D,$B6,$8D,$B7,$8C,$B8,$8C,$B9,$8C,$BB
	dc.b	$8B,$BC,$8B,$BD,$8B,$BD,$8A,$BE,$8A,$BE,$8A,$BF,$8A,$BF,$89
	dc.b	$BF,$89,$BF,$89,$BF,$89,$BE,$89,$BE,$88,$BD,$88,$BD,$88,$BC
	dc.b	$88,$BB,$87,$B9,$87,$B8,$86,$B7,$86,$B6,$86,$B4,$85,$B3,$85
	dc.b	$B0,$84,$AF,$83,$AD,$83,$AB,$82,$AA,$82,$A8,$81,$A5,$80,$A3
	dc.b	$7F,$A1,$7E,$9F,$7E,$9D,$7D,$9B,$7C,$99,$7B,$97,$7A,$95,$79
	dc.b	$93,$78,$92,$77,$90,$76,$8E,$74,$8C,$73,$8B,$72,$8A,$71,$88
	dc.b	$70,$87,$6F,$85,$6D,$84,$6C,$82,$6B,$82,$6A,$80,$68,$7F,$67
	dc.b	$7E,$66,$7D,$65,$7D,$64,$7C,$62,$7B,$61,$7B,$60,$7B,$5F,$7B
	dc.b	$5E,$7A,$5D,$7A,$5C,$7B,$5C,$7A,$5B,$7B,$5A,$7B,$59,$7B,$59
	dc.b	$7C,$58,$7C,$58,$7D,$57,$7E,$57,$7E,$57,$7F,$57,$80,$56,$80
	dc.b	$56,$81,$56,$82,$56,$83,$57,$84,$57,$84,$57,$85,$58,$86,$58
	dc.b	$87,$59,$87,$59,$88,$5A,$89,$5B,$89,$5B,$8A,$5C,$8A,$5D,$8B
	dc.b	$5E,$8B,$5F,$8B,$5F,$8B,$60,$8B,$61,$8B,$62,$8B,$63,$8B,$65
	dc.b	$8B,$66
	dc.l	$fffffffe	End List
	even

**********

QUIT	move.l	OldInt+2,$6c		Restore Lvl3 int
	MOVE.W	DMASAVE,D7
	BSET	#$F,D7
	MOVE.W	D7,DMACON(A5)

	MOVE.L	GFXBASE,A0
	MOVE.L	$26(A0),COP1LC(A5)	FIND/REPLACE SYSTEM COPPER
	CLR.L	D0
	MOVE.L	GFXBASE,A1
	CALLEXEC CLOSELIBRARY		CLOSE GRAPHICS LIBRARY
	CALLEXEC PERMIT			TURN ON MULTITASKING
	MOVEM.L	(A7)+,A0-A6/D0-D7	RESTORE REGISTERS...
	MOVE.L	STPOINT,A7		...AND OLD STACK
	RTS				GOODBYE CRUEL WORLD (SOB!)

**********


GFXNAME		DC.B	'graphics.library'
		EVEN

GFXBASE		DC.L	0
STPOINT		DC.L	0
DMASAVE		DC.W	0


**********

	Section	SPR,Code_c

Screen		DCB.B	10240,0

Sprite1

Spr1Y	dc.b	$00
Spr1X	dc.b	$00
Spr1Y2	dc.b	$b1,$00
	dc.w	$FFFF,$0000
	dc.w	$FFFF,$0000
	dc.w	$FFFF,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$03C0,$0000
	dc.w	$0000,$0000

**********

NEWCOP	DC.W	BPLCON0,$1200
	DC.W	BPLCON1,$0000
	DC.W	DIWSTRT,$2281
	DC.W	DIWSTOP,$22C1
	DC.W	DDFSTRT,$0038
	DC.W	DDFSTOP,$00D0
	DC.W	BPL1MOD,$0000
	DC.W	BPL2MOD,$0000
	DC.W	COLOR+$00,$0000
	DC.W	COLOR+$02,$0FFF
	DC.W	COLOR+$22,$0FFF

	DC.W	SPRPT+$00
SPR0H	DC.W	0,SPRPT+$02
SPR0L	DC.W	0,SPRPT+$04
SPR1H	DC.W	0,SPRPT+$06
SPR1L	DC.W	0,SPRPT+$08
SPR2H	DC.W	0,SPRPT+$0a
SPR2L	DC.W	0,SPRPT+$0c
SPR3H	DC.W	0,SPRPT+$0e
SPR3L	DC.W	0,SPRPT+$10
SPR4H	DC.W	0,SPRPT+$12
SPR4L	DC.W	0,SPRPT+$14
SPR5H	DC.W	0,SPRPT+$16
SPR5L	DC.W	0,SPRPT+$18
SPR6H	DC.W	0,SPRPT+$1a
SPR6L	DC.W	0,SPRPT+$1c
SPR7H	DC.W	0,SPRPT+$1e
SPR7L	DC.W	0


	DC.W	BPLPT+$00		SET UP COPPER BPLANE POINTERS
PL1H	DC.W	0,BPLPT+$02
PL1L	DC.W	0,BPLPT+$04
PL2H	DC.W	0,BPLPT+$06
PL2L	DC.W	0,BPLPT+$08
PL3H	DC.W	0,BPLPT+$0A
PL3L	DC.W	0,BPLPT+$0C
PL4H	DC.W	0,BPLPT+$0E
PL4L	DC.W	0,BPLPT+$10
PL5H	DC.W	0,BPLPT+$12
PL5L	DC.W	0


	DC.W	$FFFF,$FFFE		AND WAIT FOR THE IMPOSSIBLE -


*					LIKE WINNING THE POOLS!!!!!!

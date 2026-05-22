*
*
*	Sine-Sprite 1 -- This version uses a series of offsets to 	
*	                 produce the motion.
*

	SECTION SINE-SPRITE,CODE_C	CODE 2 CHIPMEM
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

Setup	move.l	#Sprite0,d0		Setup 1st Sprite:
	move.w	d0,Spr0l
	swap	d0
	move.w	d0,Spr0h

	move.l	#Sprite1,d0		Setup 2nd Sprite
	move.w	d0,Spr1l
	swap	d0
	move.w	d0,Spr1h

	move.l	#Sprite2,d0		Setup 3rd Sprite:
	move.w	d0,Spr2l
	swap	d0
	move.w	d0,Spr2h

	move.l	#Sprite3,d0		Setup 4th Sprite
	move.w	d0,Spr3l
	swap	d0
	move.w	d0,Spr3h

	move.l	#Screen,d0		Setup Screen
	move.w	d0,Pl1l
	swap	d0
	move.w	d0,Pl1h

	lea	Data,a0			Address of 'X' pos data
	lea	Data2,a1		Address of 'Y' pos data
	move.l	a0,a2			A2 = 2nd X Pos
	move.l	a1,a3			A3 = 2nd Y Pos
	
	move.l	$6c,IntSave		Save interrupt pointer
	move.l	#NewInt,$6c		And stick my routine in

.Wait	btst	#6,$bfe001
	bne.s	.Wait

	bra	quit

**********

NewInt	move.w	Sprite0,d0		Get Sprite Control Word (X/Y Pos)
	add.b	(a0)+,d0		Add offset from data table
	move.w	d0,Sprite0		Use new X value for first sprite
	move.w	d0,Sprite1		Use new X value for second sprite

	move.w	Sprite1,d0
	ror.w	#8,d0			Rotate bits to get Vetical component
	add.b	(a1),d0			Add new offset
	rol.w	#8,d0			De-Rotate the bits
	move.w	d0,Sprite0		And Use
	move.w	d0,Sprite1

	move.w	Sprite0+2,d0		Get 2nd CTRL Word for Sprite end
	ror.w	#8,d0			Rotate it
	add.b	(a1)+,d0		Add offset
	rol.w	#8,d0			De-Rotate it
	move.w	d0,Sprite0+2		And use it
	move.w	d0,Sprite1+2

	cmpi.b	#$99,(a0)		Reached end of X Table data?
	bne	.Cont

	lea	Data,a0			Reset X pointer

.Cont	cmpi.b	#$99,(a1)		Reached end of Y Table data?
	bne	DoSpr2

	lea	Data2,a1		Reset Y pointer

**********

DoSpr2	tst.b	GoOne			Must call this routine once before
	beq.s	Test			pausing!!!

	move.b	#$00,GoOne
	bra	SprCont

Test	tst.w	Pause
	beq	SprCont

	subi.w	#1,Pause

	bra	OldInt

SprCont	move.w	Sprite2,d0		Get Sprite Control Word (X/Y Pos)
	add.b	(a2)+,d0		Add offset from data table
	move.w	d0,Sprite2		Use new X value for first sprite
	move.w	d0,Sprite3		Use new X value for second sprite

	move.w	Sprite3,d0
	ror.w	#8,d0			Rotate bits to get Vertical component
	add.b	(a3),d0			Add new offset
	rol.w	#8,d0			De-Rotate the bits
	move.w	d0,Sprite2		And Use
	move.w	d0,Sprite3

	move.w	Sprite2+2,d0		Get 2nd CTRL Word for Sprite end
	ror.w	#8,d0			Rotate it
	add.b	(a3)+,d0		Add offset
	rol.w	#8,d0			De-Rotate it
	move.w	d0,Sprite2+2		And use it
	move.w	d0,Sprite3+2

	cmpi.b	#$99,(a2)		Reached end of X Table data?
	bne.s	.Cont2

	lea	Data,a2			Reset X pointer

.Cont2	cmpi.b	#$99,(a3)		Reached end of Y Table data?
	bne.s	OldInt

	lea	Data2,a3		Reset Y pointer

**********

OldInt	move.l	IntSave,-(sp)		Store address on stack
	rts				and jump to the routine

**********

Data	dc.b	0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,1,1,1,1,1,1,0,0,0,0
	dc.b	0,0,0,0,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3
	dc.b	-3,-3,-3,-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,0,0,0,0,$99
	Even

Data2	dc.b	0,0,1,1,1,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,1,1,1,0,0
	dc.b	0,0,-1,-1,-1,-2,-2,-2,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-2,-2,-2,-1,-1,-1,0,0,$99
	Even


**********

QUIT	move.l	IntSave,$6c
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

NEWCOP	DC.W	BPLCON0,$1200		CHANGE 1ST DIGIT FOR 1-5 BPL
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

Cols	dc.w	$01A2,$0DDD
	dc.w	$01A4,$0CCC
	dc.w	$01A6,$0AAA
	dc.w	$01A8,$0999
	dc.w	$01AA,$0888
	dc.w	$01AC,$0666
	dc.w	$01AE,$0555

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


	DC.W	$FFFF,$FFFE		AND WAIT FOR THE IMPOSSIBLE!

**********				LABELS CRAP FOLLOWS...

GFXNAME		DC.B	'graphics.library'
		EVEN

GFXBASE		DC.L	0
STPOINT		DC.L	0
DMASAVE		DC.W	0
IntSave		DC.L	0
Pause		DC.W	5
GoOne		DC.B	$ff
		EVEN

Screen		DCB.B	10240,0

**********


	;Even ATTACH pair follows:
Sprite0	dc.w	$8040,$9080
	dc.w	$FFFC,$0000
	dc.w	$99FC,$1E04
	dc.w	$CCFC,$0F04
	dc.w	$E67C,$0784
	dc.w	$FFFC,$7FFC
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0F80,$0000
	dc.w	$0E80,$0180
	dc.w	$0B80,$0080
	dc.w	$0880,$0080
	dc.w	$0E80,$0680
	dc.w	$0B80,$0780
	dc.w	$0980,$0780
	dc.w	$0880,$0780
	dc.w	$0F80,$0780
	dc.w	$0000,$0000
	;Odd ATTACH pair follows:
Sprite1	dc.w	$8040,$0080
	dc.w	$0000,$0000
	dc.w	$601C,$0000
	dc.w	$700C,$0000
	dc.w	$7804,$0000
	dc.w	$7FFC,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0780,$0000
	dc.w	$0780,$0000
	dc.w	$0780,$0000
	dc.w	$0180,$0000
	dc.w	$0080,$0000
	dc.w	$0080,$0000
	dc.w	$0080,$0000
	dc.w	$0780,$0000
	dc.w	$0000,$0000

**********

Sprite2	dc.w	$8040,$9080
	dc.w	$FFFC,$0000
	dc.w	$99FC,$1E04
	dc.w	$CCFC,$0F04
	dc.w	$E67C,$0784
	dc.w	$FFFC,$7FFC
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0F80,$0000
	dc.w	$0E80,$0180
	dc.w	$0B80,$0080
	dc.w	$0880,$0080
	dc.w	$0E80,$0680
	dc.w	$0B80,$0780
	dc.w	$0980,$0780
	dc.w	$0880,$0780
	dc.w	$0F80,$0780
	dc.w	$0000,$0000
	;Odd ATTACH pair follows:
Sprite3	dc.w	$8040,$0080
	dc.w	$0000,$0000
	dc.w	$601C,$0000
	dc.w	$700C,$0000
	dc.w	$7804,$0000
	dc.w	$7FFC,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0780,$0000
	dc.w	$0780,$0000
	dc.w	$0780,$0000
	dc.w	$0180,$0000
	dc.w	$0080,$0000
	dc.w	$0080,$0000
	dc.w	$0080,$0000
	dc.w	$0780,$0000
	dc.w	$0000,$0000



RASTER = $ff
BEGIN = 90

WIDTH = 20
HIGH = 150

Xc = [WIDTH*4]
Yc = [HIGH/2]
SIZE = WIDTH*HIGH
DEEP = 3

BASE = $0007
BPL1 = $0000
BPL2 = BPL1 + SIZE
BPL3 = BPL2 + SIZE
DATA = $7ff00

D = 720
K = 240

C = 126

;------------------------------------------------------------------------
******************************************************************************
;    680X0 AND AGA STARTUP CODED BY RANDY/CMX 1992-93 (100% PC RELATIVE)     *
******************************************************************************
	SECTION CMXINTRO,CODE_C		;TRY TO ASSEBLE IN FAST RAM

S:
MAINCODE:
	movem.l	d0-d7/a0-a6,-(SP)	; Save registers to stack
	LEA	$DFF000,A5		; CUSTOM REG FOR OFFSETS
	LEA	S(PC),A4		; A4=OFFSET FOR VARIABLES
	MOVE.W	2(A5),OLDDMA-S(A4)	; SAVE OLD DMA STATUS
	move.l	4.w,a6
	LEA	LIBNAME(PC),A1
	JSR	-$198(A6)
	TST.L	D0
	BEQ.W	EXIT
	MOVE.L	D0,A6
	MOVE.L	A6,GFXBASE-S(A4)
	MOVE.L	$22(A6),WBVIEW-S(A4)	; save actual view
	SUBA.L	A1,A1
	JSR	-$DE(A6)	; null loadview for reset
				; AGA OR AAA strange VIDEO modes ...
	JSR	-$10E(A6)	; waitof (if was interlace)
	JSR	-$10E(A6)	; waitof
	move.l	4.w,a6		; get execbase
	JSR	-$84(a6)	; FORBID - DISABLE MULTITASKING
	JSR	-$78(A6)	; DISABLE - DISABLE ALSO INTERRUPTS

	LEA	HEAVYINIT(PC),A5
	JSR	-$1e(a6)		; Execute the code as Exception!

	MOVEA.L	4.w,A6
	JSR	-$7E(A6)		; ENABLE
	JSR	-$8A(A6)		; PERMIT

	MOVE.L	WBVIEW(PC),A1		; OLD WBVIEW IN A1
	MOVE.L	GFXBASE(PC),A6		; GFXBASE IN A6
	JSR	-$DE(A6)		; loadview *fix OLD view
	JSR	-$10E(A6)
	JSR	-$10E(A6)
	MOVE.L	$26(a6),$dff080		; point Sys cop1
	MOVE.L	$32(a6),$dff084		; point Sys cop2
	MOVE.W	D0,$dff088		; START COP 1
	MOVE.W	OLDDMA(PC),$96(A5)	; RESTORE OLD DMA STATUS 2nd time
	MOVE.L	A6,A1
	move.l	4.w,a6
	jsr	-$19E(a6)		; graphics lib closed
EXIT:
	movem.l	(SP)+,d0-d7/a0-a6	; Restore old registers
	MOVEQ	#0,d0
	RTS

;	FROM HERE NO LAME SYSTEM CALLS =)

HEAVYINIT:
	LEA	S(PC),A4
	LEA	$DFF000,A5
	MOVE.W	$1C(A5),OLDINTENA-S(A4)	; SAVE OLD INTENA STATUS
	MOVE.W	$10(A5),OLDADKCON-S(A4)	; SAVE OLD ADKCON STATUS
	MOVE.W	$1E(A5),OLDINTREQ-S(A4)	; SAVE OLD INTREQ STATUS
	MOVE.L	#$80008000,d0
	OR.L	d0,OLDDMA-S(a4)		; Set the 15th bit of all hard reg
	OR.L	d0,OLDADKCON-S(a4)

	MOVE.L	#$7FFF7FFF,$9A(a5)	; DISABLE INTERRUPTS AND INTREQS
	MOVE.W	#$7FFF,$96(a5)		; DISABLE DMA

	MOVEA.L	4.w,A1
	btst.b	#0,$129(a1)	; Tests for a 68010 or higher Processor
	beq.S	VBRDONE		; is a 68000!!
	dc.l	$4e7a9801	; Movec Vbr,A1 (68010+ instruction)
	move.l  a1,VBRBASE-S(A4)	; Save VbrBase
VBRDONE:

	MOVE.L	VBRBASE(PC),A1
	move.l	$64(a1),OLDINT1-S(A4) ; Sys lev 1 int saved (softint,dskblk)
	move.l	$68(a1),OLDINT2-S(A4) ; Sys lev 2 int saved (I/O,ciaa,int2)
	move.l	$6c(a1),OLDINT3-S(A4) ; Sys lev 3 int saved (coper,vblanc,blit)
	move.l	$70(a1),OLDINT4-S(A4) ; Sys lev 4 int saved (audio)
	move.l	$74(a1),OLDINT5-S(A4) ; Sys lev 5 int saved (rbf,dsksync)
	move.l	$78(a1),OLDINT6-S(A4) ; Sys lev 6 int saved (exter,ciab,inten)

	movem.l	d0-d7/a0-a6,-(Sp)	; Save registers to stack
	bsr.w	START
	movem.l	(sp)+,d0-d7/a0-a6	; restore registers from stack

	MOVE.W	#$7FFF,$96(A5)		; DISABLE ALL DMA
	MOVE.L	#$7FFF7FFF,$9A(A5)	; DISABLE ALL INTERRUPTS & INTREQS

	MOVE.L	VBRBASE(PC),A1
	MOVE.L	OLDINT1(PC),$64(A1)	; RESTORE Sys LEVEL 1 INTERRUPT
	MOVE.L	OLDINT2(PC),$68(A1)	; RESTORE Sys LEVEL 2 INTERRUPT
	MOVE.L	OLDINT3(PC),$6C(A1)	; RESTORE Sys LEVEL 3 INTERRUPT
	MOVE.L	OLDINT4(PC),$70(A1)	; RESTORE Sys LEVEL 4 INTERRUPT
	MOVE.L	OLDINT5(PC),$74(A1)	; RESTORE Sys LEVEL 5 INTERRUPT
	MOVE.L	OLDINT6(PC),$78(A1)	; RESTORE Sys LEVEL 6 INTERRUPT
	MOVE.W	OLDDMA(PC),$96(A5)	; RESTORE OLD DMA STATUS
	MOVE.W	#$7fff,$9E(a5)
	MOVE.W	OLDADKCON(PC),$9E(A5)	; RESTORE OLD ADKCON STATUS
	MOVE.W	OLDINTREQ(PC),$9C(A5)	; RESTORE OLD INTREQ
	MOVE.W	OLDINTENA(PC),$9A(A5)	; RESTORE OLD INTENA STATUS
	RTE

OLDSP:
	dc.l	0
VBRBASE:		; Pointer to the Vector Base
	dc.l 	0
WBVIEW:			; Sys WorkBench View Address
	DC.L	0
OLDINT1:
	DC.L	0
OLDINT2:
	DC.L	0
OLDINT3:
	DC.L	0
OLDINT4:
	DC.L	0
OLDINT5:
	DC.L	0
OLDINT6:
	DC.L	0
LIBNAME:
	dc.b	'graphics.library',0,0
GFXBASE:		; Pointer to the Graphics Library Base
	dc.l	0
OLDDMA:			; Old DMACON status
	dc.w	0
OLDINTENA:		; Old INTENA status
	dc.w	0
OLDADKCON:		; Old ADKCON status
	DC.W	0
OLDINTREQ:		; Old INTREQ status
	DC.W	0

;			     MAIN PROGRAM

START:
b:		lea 	$dff000,a6
		lea	COPPER(pc),a0
		move.w	#$7fff,$96(a6)
		move.l	a0,$80(a6)
		move.w	d0,$88(a6)
		move.w	#0,$1fc(a6)
		move.l	#0,$108(a6)
		move.w	#$83c0,$96(a6)

		lea	DATA,a5
		moveq	#BASE,d0
		swap	d0
		move.l	d0,(a5)

LOOP:		bsr.s	FLIP
		bsr.s	CLS
		bsr.w	CUBE
		bsr.s	FILL
		btst	#6,$bfe001
		bne.s	LOOP

		bsr	BLT
		move.w	#0,$100(a6)
		move.w	#$83f0,$96(a6)
		moveq	#0,d0
		rts

;------------------------------------------------------------------------

FLIP:		cmpi.b	#RASTER,$6(a6)
		bne.s	FLIP
		move.l	(a5),d0
		move.w	#SIZE,d1
		lea	LIST(pc),a0
		move.w	d0,(a0)
		add.w	d1,d0
		move.w	d0,4(a0)
		add.w	d1,d0
		move.w	d0,8(a0)
		add.w	d1,d0
		cmpi.w	#[SIZE*DEEP]*3,d0
		bne.s	FLIP1
		clr.w	d0
FLIP1:		move.l	d0,(a5)
		rts

;------------------------------------------------------------------------

FILL:
		move.l	(a5),d0
		addi.w	#[SIZE*DEEP]-2,d0
		move.l	#$09f0000a,d1
		bra.s	BLITTER

CLS:		move.l	(a5),d0
		addi.w	#[SIZE*DEEP],d0
		cmpi.w	#[SIZE*DEEP]*3,d0
		bne.s	CLS1
		clr.w	d0
CLS1:		move.l	#$01000000,d1

BLITTER:	bsr.s	BLT
		move.l	d0,$50(a6)
		move.l	d0,$54(a6)
		move.l	#0,$64(a6)
		move.l	d1,$40(a6)
		move.w	#[DEEP*HIGH*64]+[WIDTH/2],$58(a6)
		rts

;------------------------------------------------------------------------

BLT:		btst	#6,$2(a6)
		bne.s	BLT
		rts

;------------------------------------------------------------------------

; d0		reserved

LINEINIT:	bsr.s	BLT
		moveq	#-1,d0
		move.l	d0,$44(a6)
		move.w	#$8000,d0
		move.l	d0,$72(a6)
		rts

; d0-d1	:	(x1,y1)
; d2-d3	:	(x2,y2)
; d4-d5	:	reserved
; a0	:	screen

LINEDRAW:	cmp.w	d1,d3
		bne.s	LINE1
		rts

LINE1:		blt.s	LINE2
		exg	d2,d0
		exg	d3,d1
LINE2:		addq.w	#1,d3
		moveq	#0,d4
		sub.w	d1,d3
		bpl.s	LINE3
		neg.w	d3
		bra.s	LINE4
LINE3:		ori.b	#1,d4
LINE4:		sub.w	d0,d2
		bpl.s	LINE5
		neg.w	d2
		bra.s	LINE6
LINE5:		ori.b	#2,d4
LINE6:		move.w	d2,d5
		sub.w	d3,d5
		bpl.s	LINE7
		exg	d3,d2
		bra.s	LINE8
LINE7:		ori.b	#4,d4
LINE8:		ror.w	#4,d0
		ori.w	#$0b00,d0
		moveq	#0,d5
		move.b	d0,d5
		add.w	d5,d5
		move.b	#$4a,d0
		mulu	#WIDTH,d1
		add.w	d5,d1
		add.w	d1,a0
		move.b	TABLE(pc,d4.w),d4
		add.w	d3,d3
		bsr.s	BLT
		move.w	d3,$62(a6)
		sub.w	d2,d3
		bpl.s	LINE9
		ori.b	#$42,d4
LINE9:
		move.w	d4,$42(a6)
		move.l	d3,$50(a6)
		sub.w	d2,d3
		move.w	d3,$64(a6)
		move.w	d0,$40(a6)
		move.l	a0,$48(a6)
		move.l	a0,$54(a6)
		moveq	#WIDTH,d0
		move.w	d0,$60(a6)
		move.w	d0,$66(a6)
		asl.w	#6,d2
		addi.w	#64+2,d2
		move.w	d2,$58(a6)
		rts

TABLE:		dc.b	15,11,07,03,31,23,27,19

;------------------------------------------------------------------------

; d0-d2		(x,y,z)
; d3		sin
; d4		cos
; d5-d6		reserved
; a0		sin table

ROTATION:	lea	SINUS(pc),a0
		move.b	Alpha-DATA(a5),d5
		bsr.s	ROTATION1
		move.b	Beta-DATA(a5),d5
		bsr.s	ROTATION1
		move.b	Gamma-DATA(a5),d5

ROTATION1:	bsr.s	ROTATION2
		move.w	d6,d3
		addi.b	#$40,d5
		bsr.s	ROTATION2
		move.w	d6,d4

		move.w	d0,d5
		move.w	d1,d6
		muls	d4,d5
		muls	d3,d6
		add.l	d5,d6
		asr.l	#8,d6
		move.w	d0,d5
		move.w	d6,d0
		move.w	d1,d6
		muls	d3,d5
		muls	d4,d6
		sub.l	d5,d6
		asr.l	#8,d6
		move.w	d6,d1
		exg	d1,d2
		exg	d0,d1
		rts

ROTATION2:	move.b	d5,d6
		andi.w	#$007f,d6
		move.b	(a0,d6.w),d6
		tst.b	d5
		bpl.s	ROTATION3
		neg.w	d6
ROTATION3:	rts

SINUS:		dc.b	0,6,12,18,25,31,37,43,49,56,62,68,74,80,86,92,97
		dc.b	103,109,115,120,126,131,136,142,147,152,157,162
		dc.b	167,171,176,181,185,189,193,197,201,205,209,212
		dc.b	216,219,222,225,228,231,234,236,238,241,243,244
		dc.b	246,248,249,251,252,253,254,254,255,255,255,255
		dc.b	255,255,255,254,254,253,252,251,249,248,246,244
		dc.b	243,241,238,236,234,231,228,225,222,219,216,212
		dc.b	209,205,201,197,193,189,185,181,176,171,167,162
		dc.b	157,152,147,142,136,131,126,120,115,109,103,97
		dc.b	92,86,80,74,68,62,56,49,43,37,31,25,18,12,6

;------------------------------------------------------------------------

; d0-d2	:	(x,y,z)
; d3	:	reserved

PROJECTION:	move.w	#K,d3
		addi.w	#D,d2			; z+D
		ble.s	PROJECTION1
		muls	d3,d0			; x*K
		muls	d3,d1			; y*K
		divs	d2,d0			; x' = x*K / z+D
		divs	d2,d1			; y' = y*K / z+D
		addi.w	#Xc,d0
		addi.w	#Yc,d1
PROJECTION1:	rts

;------------------------------------------------------------------------

CUBE:		addq.b	#1,Alpha-DATA(a5)
		addq.b	#2,Beta-DATA(a5)
		subq.b	#1,Gamma-DATA(a5)

		movem.w	Palette-DATA(a5),d1/d2/d4
		moveq	#$0,d0
		move.l	d2,d3
		move.l	d4,d5
		move.l	d4,d6
		move.l	d4,d7
		movem.w	d0-d7,$180(a6)

		lea	COORDS(pc),a1
		lea	Points-DATA(a5),a2
		move.l	a2,a3
		lea	Z-DATA(a5),a4
		moveq	#7,d7
CUBE1:		move.b (a1)+,d0
		move.b (a1)+,d1
		move.b (a1)+,d2
		ext.w	d0
		ext.w	d1
		ext.w	d2
		bsr	ROTATION
		move.l	d2,(a4)+
		bsr.s	PROJECTION
		movem.w	d0/d1,(a2)
		addq.w	#4,a2
		dbf	d7,CUBE1

		pea	Palette-DATA(a5)

		lea	FACES(pc),a1
		move.l	(a5),a4
		moveq	#%01010100,d7
	
CUBE2:		lea	Buffer-DATA(a5),a0
		move.l	a0,a2
		moveq	#0,d0
		moveq	#4-1,d1
CUBE3:		move.b	(a1)+,d0
		move.l	(a3,d0.w),(a0)
		addq.w	#4,a0
		dbf	d1,CUBE3
		move.l	(a2),(a0)

		movem.w	(a2),d0-d5
		sub.w	d0,d2			; x2-x1
		sub.w	d0,d4			; x3-x1
		sub.w	d1,d3			; y2-y1
		sub.w	d1,d5			; y3-y1
		muls	d5,d2			; (y3-y1)*(x2-x1)
		muls	d4,d3			; (x3-x1)*(y2-y1)
		sub.l	d2,d3
		ble.s	CUBE6

		lea	Z-DATA(a5),a0
		moveq	#0,d2
		move.b	-1(a1),d2
		move.l	(a0,d2.w),d0
		move.b	-3(a1),d2
		move.l	(a0,d2.w),d1
		add.w	d1,d0
		bge.s	CUBE4
		neg.w	d0
CUBE4:		lsr.w	#4,d0
		move.l	(sp),a0
		move.w	d0,(a0)
	
		bsr	LINEINIT
		moveq	#4-1,d6
CUBE5:		movem.w	(a2),d0-d3
		move.l	a4,a0
		bsr	LINEDRAW
		addq.w	#4,a2
		dbf	d6,CUBE5

CUBE6:		add.b	d7,d7
		bcc.s	CUBE7
		addq.l	#2,(sp)
		add.w	#SIZE,a4
CUBE7:		tst.b	d7
		bne	CUBE2
		addq.l	#4,sp
		rts

;------------------------------------------------------------------------

COPPER:		dc.w	$008e
		dc.b	$5a	;BEGIN
		dc.b	$d1
		dc.w	$0090
		dc.b	$f0	;BEGIN + HIGH
		dc.b	$7e	;$71
		dc.w	$0092,$0060
		dc.w	$0094,$00a8
		dc.w	$00e0,BASE
		dc.w	$00e4,BASE
		dc.w	$00e8,BASE
		dc.w	$00e2
LIST:		dc.w	BPL1
		dc.w	$00e6,BPL2
		dc.w	$00ea,BPL3
		dc.w	$0100,$3000
		dc.l	$f709fffe
		dc.l	$01000000
		dc.l	-2
		dc.l	-2

COORDS:		dc.b	 C, C, C
		dc.b	 C,-C, C
		dc.b	 C,-C,-C
		dc.b	 C, C,-C
		dc.b	-C, C, C
		dc.b	-C,-C, C
		dc.b	-C,-C,-C
		dc.b	-C, C,-C

FACES:		dc.b	0,4,8,12
		dc.b	20,16,28,24
		dc.b	0,12,28,16
		dc.b	8,4,20,24
		dc.b	0,16,20,4
		dc.b	28,12,8,24

		dc.b	'*'
GFX:		dc.b	"graphics.library"
DOS:		dc.b	"ics.library",0
		dc.b	169,"sep92 Z-One"
x:
;------------------------------------------------------------------------

	org DATA
	load DATA
Screen:		dc.l	0

Palette:	dc.w	0
		dc.w	0
		dc.w	0

Z:		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0

Points:		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0

Buffer:		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0

Alpha:		dc.b	0
Beta:		dc.b	0
Gamma:		dc.b	0

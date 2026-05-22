;************************************************
;*                    3D VU_METER               *
;*             3D ROTATIONS OF VU_METERS        *
;*  Coder: EXECUTOR                             *
;*  Date:  20/10/1991                           *
;************************************************

;*****************
;*   Constants   *
;*****************

OldOpenLibrary	= -408
CloseLibrary	= -414

DMASET=	%1000010111000000
;	 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA (if this isn't set, sprites disappear!)
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA

INIT:
;	jmp	START

;	ORG	$50000
;	LOAD	$50000

	section	bau,code_c

START:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack
	BSR.W	DEMOIRQ			; demo irq

	move.l	#SCREEN1,SC1
	move.l	#SCREEN2,SCREENPTH
	move.w	#$0000,SCREENFLAG
	BSR.W	SETSCREEN	
;	jsr	mt_init
*******Here There is your code*********
	bsr.w	BLTCLS
	
LOOP:
	bsr	WaitOF
	bsr.w	CHANGESCREEN			
	bsr.w	SETSCREEN
	bsr.w	BLTCLS
;	bsr	VU_METER
	bsr.b	INITVECT
	bsr.w	ROTATE
	bsr	MAKELINES
	BTST	#6,$BFE001		; Test left mouse button
	BNE.B	LOOP

***************************************

;	jsr	mt_end
	BSR.W	SYSTEMIRQ		; system irq
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	RTS

;**********************************
WAITOF:	move.l	$dff004,d2		;Wait the start of the vertirq
	and.l	#$0001ff00,d2		;and the start of the video scan
	cmp.l	#$0000f000,d2
	bne	WAITOF
OK:	rts
;**********************************

************************
*     MAIN 3D PROG     * 
************************

INITVECT:
	lea	COS,a2
	lea	SIN,a3
	lea	COSX,a4
	move.w	AX,d0
	move.w	AY,d1
	move.w	AZ,d2
	
	move.w	(a2,d0.w),(a4)+		;cos(x)
	move.w	(a3,d0.w),(a4)+		;sin(x) 
	move.w	(a2,d1.w),(a4)+		;cos(y)
	move.w	(a3,d1.w),(a4)+		;sin(y)
	move.w	(a2,d2.w),(a4)+ 	;cos(z)
	move.w	(a3,d2.w),(a4)+		;sin(z)
	rts
	

ROTATE:
	lea	D_OBJ(pc),a1		;object points coordinates
	lea	D_BUFFER(pc),a2		;rotations buffer
	lea	COORD_X(pc),a3		;store X
	lea	COORD_Y(pc),a4		;store Y
	lea	COORD_Z(pc),a5		;store Z
	move.w	ROTX(pc),d0		;Make rotations
	add.w	d0,AX
	and.w	#$03ff,AX
	move.w	ROTY(pc),d0
	add.w	d0,AY
	and.w	#$03ff,AY
	move.w	ROTZ(pc),d0
	add.w	d0,AZ			
	and.w	#$03ff,AZ
	moveq.l	#$0c,d7
	move.w	POINTS(pc),a0		;number of points	

D_LOOP:
ROTATE_X:
	lea	COSX(pc),a6		;load cosines and sines table

	move.w	(a1)+,d0		;d0 = x
	move.w	(a1)+,d1		;d1 = y
	move.w	(a1)+,d2		;d2 = z
	move.w	d0,(a2)			;x -> buffer
	move.w	(a6),d4			;d4 = cos(x)*4096
	muls	d1,d4			;d4 = y*cos(x)*4096
	move.w	2(a6),d5		;d5 = sin(x)*4096
	muls	d2,d5			;d5 = z*sin(x)*4096
	sub.l	d5,d4			;d4 = (y*cos(x)-z*sin(x))*4096
	asr.l	d7,d4			;d4 = y*cos(x)-z*sin(x)
	move.w	d4,$02(a2)		;d4 -> buffer+2
	move.w	(a6)+,d4		;d4 = cos(x)*4096
	muls	d2,d4			;d4 = z*cos(x)*4096
	move.w	(a6)+,d5		;d5 = sin(x)*4096
	muls	d1,d5			;d5 = y*sin(x)*4096
	add.l	d5,d4			;d4 = (z*cos(x)+y*sin(x))*4096
	asr.l	d7,d4			;d4 = z*cos(x)+y*sin(x)
	move.w	d4,$04(a2)		;d4 -> buffer+4

ROTATE_Y:
	move.w	(a2),d0			;d0 = x
	move.w	$02(a2),d2		;d2 = y
	move.w	$04(a2),d1		;d1 = z
	move.w	(a6),d4			;d4 = cos(y)*4096
	muls	d0,d4			;d4 = x*cos(y)*4096
	move.w	2(a6),d5		;d5 = sin(y)*4096
	muls	d1,d5			;d5 = z*sin(y)*4096
	sub.l	d5,d4			;d4 = (x*cos(y)-z*sin(y))*4096
	asr.l	d7,d4			;d4 = x*cos(y)-z*sin(y)
	move.w	d4,(a2)			;d4 -> buffer
	move.w	d2,$02(a2)		;d2 -> buffer+2
	move.w	(a6)+,d4		;d4 = cos(y)*4096
	muls	d1,d4			;d4 = z*cos(y)*4096
	move.w	(a6)+,d5		;d5 = sin(y)*4096
	muls	d0,d5			;d5 = x*sin(y)*4096
	add.l	d5,d4			;d4 = (z*cos(y)+x*sin(y))*4096
	asr.l	d7,d4			;d4 = z*cos(y)+x*sin(y)
	move.w	d4,$04(a2)		;d4 -> buffer+4

ROTATE_Z:
	move.w	(a2),d1			;d1 = x
	move.w	$02(a2),d2		;d2 = y
	move.w	$04(a2),d0		;d0 = z
	move.w	(a6),d4			;d4 = cos(z)*4096
	muls	d1,d4			;d4 = x*cos(z)*4096
	move.w	2(a6),d5		;d5 = sin(z)*4096
	muls	d2,d5			;d5 = y*sin(z)*4096
	sub.l	d5,d4			;d4 = (x*cos(z)-y*sin(z))*4096
	asr.l	d7,d4			;d4 = x*cos(z)-y*sin(z)
	move.w	d4,(a2)			;d4 -> buffer
	move.w	(a6)+,d4		;d4 = cos(z)*4096
	muls	d2,d4			;d4 = y*cos(z)*4096
	move.w	(a6),d5			;d5 = sin(z)
	muls	d1,d5			;d5 = x*sin(z)
	add.l	d5,d4			;d4 = (y*cos(z)+x*sin(z))*4096
	asr.l	d7,d4			;d4 = y*cos(z)+x*sin(z)
	sub.w	D,d0			;sub an offset value (distance)
	move.w	d0,(a5)+		;d0 -> store Z
	move.w	d0,d2			;d0 -> d2
	move.w	(a2),d0			;d0 = X
	move.w	d4,d1			;d1 = Y
	move.w	#$00f0,d4		;d4 = distance
	move.w	d4,d5			;d4 -> d5
	muls	d4,d0			;d0 = distance*x
	muls	d4,d1			;d1 = distance*y
	sub.w	d2,d5			;d5 = distance-z
	divs	d5,d0			;d0 = x(relative)
	divs	d5,d1			;d1 = y(relative)
	move.w	d0,(a3)+		;d0 -> store X
	move.w	d1,(a4)+		;d1 -> store Y
	cmp.w	#0,a0			;move all points...
	beq	EX
	subq.w	#1,a0
	bra	D_LOOP
EX:	rts				;end...
	
*************************

MAKELINES:
	btst	#$0e,$dff002
	bne	MAKELINES
	lea	$dff000,a6
	move.w	#$ffff,$72(a6)
	move.w	#$8000,$74(a6)
	moveq.l	#-1,d5
	move.l	d5,$44(a6)
	move.w	#40,$60(a6)
	move.w	#40,$66(a6)
	move.l	SCREENPTH,a2
	lea	CONNECTS,a3
	lea	COORD_X,a4
	lea	COORD_Y,a5
	move.w	NCONS,d7
LINES:	moveq.l	#00,d0
	moveq.l	#00,d1
	moveq.l	#40,d4
	move.l	a2,a0
	move.w	(a3)+,d6
	add.w	d6,d6
	move.w	(a4,d6.w),d0
	move.w	(a5,d6.w),d1
	add.w	#160,d0
	add.w	#128,d1
	move.w	(a3)+,d6
	add.w	d6,d6
	move.w	(a4,d6.w),d2
	move.w	(a5,d6.w),d3
	add.w	#160,d2
	add.w	#128,d3
	cmp.w	d3,d1
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	a2,a5
	bsr	DRAWLINE
	movem.l	(a7)+,d0-d7/a0-a6
NOLINE:	dbf	d7,LINES		
	rts
	


;*****************************
;*     PROGRAM FUNCTIONS     *
;*****************************

	; BLITTER CLS ROUTINE

BLTCLS:
	lea	$dff000,a6
	move.l	SCREENPTH,a0
	add.l	#14,a0
	add.l	#40*82,a0
	bsr	WaitB
	clr.l	$44(a6)
	move.w	#28,$64(a6)
	move.w	#28,$66(a6)
	move.l	#$01000000,$40(a6)
	move.l	a0,$54(a6)
	move.w	#112*64+6,$58(a6)
	rts


WaitB:
	btst	#$0e,$dff002			;Wait free blitter
	bne.b WaitB
	rts
	
;********************************
;*          DRAW LINE           *
;*            v2.0              *
;*                              *
;*  coder: EXECUTOR             *
;*  date: xx/04/1991            *
;********************************


;Input:
;	d0.w	[x1]
;	d1.w	[y1]
;	d2.w	[x2]
;	d3.w	[y2]
;Output:
;	d0	[Trashed]
;	d1	[Trashed]
;	d2	[Trashed]
;	d3	[Trashed]
;	a0	[Trashed]


DRAWLINE:

SINGLE = 0		; 2 = SINGLE BIT WIDTH
BYTEWIDTH = 40		; bytewidth of the screen

	LEA.L	$DFF000,A6

.WAIT:	BTST	#$E,$2(A6)
	BNE.S	.WAIT

	MOVE.L	#-1,$44(A6)		; FirstLastMask
	MOVE.W	#$8000,$74(A6)		; BLT data A
	MOVE.W	#BYTEWIDTH,$60(A6)	; Tot.Screen Width
	MOVE.W	#$FFFF,$72(A6)

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


*****************************

CHANGESCREEN:
	lea	SC1(pc),a0
	move.w	SCREENFLAG(pc),d0
	tst.w	d0
	beq.b	CS2
	move.w	#$0000,SCREENFLAG	
	move.l	#SCREEN1,(a0)+
	move.l	#SCREEN2,(a0)
	rts

CS2:	move.w	#$ffff,SCREENFLAG
	move.l	#SCREEN2,(a0)+
	move.l	#SCREEN1,(a0)
	rts


;***********************************
;*   CLOSE ALL SYSTEM INTERRUPTS   *
;*                                 *
;*      START DEMO INTERRUPTS      *
;***********************************
DEMOIRQ:
	MOVE.L	$4.W,A6			; Exec pointer to A6
	LEA.L	GfxName(PC),A1		; Set library pointer
	MOVEQ	#0,D0
	JSR	OldOpenLibrary(A6)	; Open graphics.library
	MOVE.L	D0,A1			; Use Base-pointer
	MOVE.L	$26(A1),OLDCOP1		; Store copper1 start addr
	MOVE.L	$32(A1),OLDCOP2		; Store copper1 start addr
	JSR	CloseLibrary(A6)	; Close graphics library

	MOVE.W	$DFF01C,INTENA		; Store old INTENA
	MOVE.W	$DFF002,DMACON		; Store old DMACON
	MOVE.W	$DFF010,ADKCON		; Store old ADKCON

	MOVE.W	#$7FFF,$DFF09A		; Clear interrupt enable

	BSR.W	WAITOF

	MOVE.W	#$7FFF,$DFF096		; Clear DMA channels
	MOVE.L	#COPLIST,$DFF080	; Copper1 start address
	move.w	d0,$dff088
	move.w	#0,$dff1fc
	move.l	#0,$dff108

	MOVE.W	#DMASET!$8200,$DFF096	; DMA kontrol data
	MOVE.L	$6C.W,OldIrq3		; Store old inter pointer
	MOVE.L	#IRQ3,$6C.W		; Set interrupt pointer

	MOVE.W	#$7FFF,$DFF09C		; Clear request
	MOVE.W	#$C020,$DFF09A		; Interrupt enable
	RTS
	
;*****************************************
;*					 *
;*   RESTORE SYSTEM INTERRUPTS ECT ECT   *
;*					 *
;*****************************************
SYSTEMIRQ:
	MOVE.W	#$7FFF,$DFF09A		; Disable interrupts

	BSR.W	WAITOF

	MOVE.W	#$7FFF,$DFF096
	MOVE.L	OldCop1(PC),$DFF080	; Restore old copper1
	MOVE.L	OldCop2(PC),$DFF084	; Restore old copper1
	MOVE.L	OldIrq3(PC),$6C.W	; Restore inter pointer
	MOVE.W	DMACON,D0		; Restore old DMACON
	OR.W	#$8000,D0
	MOVE.W	D0,$DFF096		
	MOVE.W	ADKCON,D0		; Restore old ADKCON
	OR.W	#$8000,D0
	MOVE.W	D0,$DFF09E
	MOVE.W	INTENA,D0		; Restore inter data
	OR.W	#$C000,D0
	MOVE.W	#$7FFF,$DFF09C
	MOVE.W	D0,$DFF09A
	RTS
	
;*** DATA AREA ***

GfxName		DC.B	'graphics.library',0
		even
OldIrq3		DC.L	0
OldCop1		DC.L	0
OldCop2		DC.L	0
INTENA		DC.W	0
DMACON		DC.W	0
ADKCON		DC.W	0
VERTB		dc.w	0


;**********************************
;*				  *
;*    INTERRUPT ROUTINE. LEVEL 3  *
;*				  *
;**********************************

IRQ3:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack
;	jsr	MT_MUSIC
	MOVE.W	#$01,VERTB
	MOVE.W	#$4020,$DFF09C		; Clear interrupt request
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	RTE

	

VU_CHAN0: dc.b	1,0
VU_CHAN1: dc.b 	1,0
VU_CHAN2: dc.b 	1,0
VU_CHAN3: dc.b 	1,0



;**********************************
;*				  *
;*       SET USER'S SCREEN        *
;*	     & SPRITES		  *
;**********************************

SETSCREEN:
	
	move.l	SC1,d0		; insert screen1 in copperlist
	lea	BPL1,a0
	move.w	d0,6(a0)
	swap.w	d0
	move.w	d0,2(a0)
	swap.w	d0
	
	rts
	

	CNOP	0,4
	
************************
*         DATA         *
************************

; Angles to rotate
AX:	dc.w	570
AY:	dc.w	0
AZ:	dc.w	0

; Angles rotated
COSX:	dc.w	0
SINX:	dc.w	0
COSY:	dc.w	0
SINY:	dc.w	0
COSZ:	dc.w	0
SINZ:	dc.w	0


OBJECT:
	dc.w	0
POINTS:
	dc.w	31

D_OBJ:
	dc.w	128,128,32
	dc.w	64,128,32
	dc.w	128,-128,32
	dc.w	64,-128,32

	dc.w	128,128,-32
	dc.w	64,128,-32
	dc.w	128,-128,-32
	dc.w	64,-128,-32

	dc.w	64,128,32
	dc.w	0,128,32
	dc.w	64,-128,32
	dc.w	0,-128,32

	dc.w	64,128,-32
	dc.w	0,128,-32
	dc.w	64,-128,-32
	dc.w	0,-128,-32

	

	dc.w	0,128,32
	dc.w	-64,128,32
	dc.w	0,-128,32
	dc.w	-64,-128,32

	dc.w	0,128,-32
	dc.w	-64,128,-32
	dc.w	0,-128,-32
	dc.w	-64,-128,-32



	dc.w	-64,128,32
	dc.w	-128,128,32
	dc.w	-64,-128,32
	dc.w	-128,-128,32

	dc.w	-64,128,-32
	dc.w	-128,128,-32
	dc.w	-64,-128,-32
	dc.w	-128,-128,-32





CONS:
	dc.w	0
NCONS:
	dc.w	47

CONNECTS:
	dc.w	0,1
	dc.w	0,2
	dc.w	2,3
	dc.w	1,3	

	dc.w	4,5
	dc.w	4,6
	dc.w	6,7
	dc.w	5,7	

	dc.w	0,4
	dc.w	1,5
	dc.w	2,6
	dc.w	3,7



	dc.w	8,9
	dc.w	8,10
	dc.w	10,11
	dc.w	9,11	

	dc.w	12,13
	dc.w	12,14
	dc.w	14,15
	dc.w	13,15	

	dc.w	8,12
	dc.w	9,13
	dc.w	10,14
	dc.w	11,15



	dc.w	16,17
	dc.w	16,18
	dc.w	18,19
	dc.w	17,19	

	dc.w	20,21
	dc.w	20,22
	dc.w	22,23
	dc.w	21,23	

	dc.w	16,20
	dc.w	17,21
	dc.w	18,22
	dc.w	19,23
	


	dc.w	24,25
	dc.w	24,26
	dc.w	26,27
	dc.w	25,27	

	dc.w	28,29
	dc.w	28,30
	dc.w	30,31
	dc.w	29,31	

	dc.w	24,28
	dc.w	25,29
	dc.w	26,30
	dc.w	27,31




D_BUFFER:
	blk.b	1000
	
COORD_X:
	blk.w	100
COORD_Y:
	blk.w	100
COORD_Z:
	blk.w	100
		
ROTX:	dc.w	0			;value to rotate around X
ROTY:	dc.w	4			;			Y
ROTZ:	dc.w	0			;			Z

D:
	dc.w	750			;distance

		
SCREENFLAG:
	dc.w	0

SC1:	dc.l	0
	
SCREENPTH:
	dc.l	0


COS:
	DC.W	$1000,$1000,$0FFF,$0FFD,$0FFB,$0FF8
	DC.W	$0FF5,$0FF1,$0FEC,$0FE7,$0FE1,$0FDB
	DC.W	$0FD4,$0FCC,$0FC4,$0FBB,$0FB1,$0FA7
	DC.W	$0F9C,$0F91,$0F85,$0F79,$0F6C,$0F5E
	DC.W	$0F50,$0F41,$0F31,$0F21,$0F11,$0EFF
	DC.W	$0EEE,$0EDB,$0EC8,$0EB5,$0EA1,$0E8C
	DC.W	$0E77,$0E61,$0E4B,$0E34,$0E1C,$0E04
	DC.W	$0DEC,$0DD3,$0DB9,$0D9F,$0D85,$0D69
	DC.W	$0D4E,$0D32,$0D15,$0CF8,$0CDA,$0CBC
	DC.W	$0C9D,$0C7E,$0C5E,$0C3E,$0C1E,$0BFC
	DC.W	$0BDB,$0BB9,$0B97,$0B74,$0B50,$0B2D
	DC.W	$0B08,$0AE4,$0ABF,$0A99,$0A73,$0A4D
	DC.W	$0A26,$09FF,$09D8,$09B0,$0988,$095F
	DC.W	$0937,$090D,$08E4,$08BA,$088F,$0865
	DC.W	$083A,$080E,$07E3,$07B7,$078B,$075E
	DC.W	$0732,$0705,$06D7,$06AA,$067C,$064E
	DC.W	$061F,$05F1,$05C2,$0593,$0564,$0534
	DC.W	$0505,$04D5,$04A5,$0475,$0444,$0414
	DC.W	$03E3,$03B2,$0381,$0350,$031F,$02EE
	DC.W	$02BC,$028B,$0259,$0227,$01F5,$01C3
	DC.W	$0191,$015F,$012D,$00FB,$00C9,$0097
	DC.W	$0065,$0032,$0000,$FFCF,$FF9C,$FF6A
	DC.W	$FF38,$FF06,$FED4,$FEA2,$FE70,$FE3E
	DC.W	$FE0C,$FDDA,$FDA8,$FD76,$FD45,$FD13
	DC.W	$FCE2,$FCB1,$FC80,$FC4F,$FC1E,$FBED
	DC.W	$FBBD,$FB8C,$FB5C,$FB2C,$FAFC,$FACD
	DC.W	$FA9D,$FA6E,$FA3F,$FA10,$F9E2,$F9B3
	DC.W	$F985,$F957,$F92A,$F8FC,$F8CF,$F8A3
	DC.W	$F876,$F84A,$F81E,$F7F2,$F7C7,$F79C
	DC.W	$F772,$F747,$F71D,$F6F4,$F6CA,$F6A2
	DC.W	$F679,$F651,$F629,$F602,$F5DB,$F5B4
	DC.W	$F58E,$F568,$F542,$F51D,$F4F9,$F4D4
	DC.W	$F4B1,$F48D,$F46A,$F448,$F426,$F405
	DC.W	$F3E3,$F3C3,$F3A3,$F383,$F364,$F345
	DC.W	$F327,$F309,$F2EC,$F2CF,$F2B3,$F298
	DC.W	$F27C,$F262,$F248,$F22E,$F215,$F1FD
	DC.W	$F1E5,$F1CD,$F1B0,$F1A0,$F18A,$F175
	DC.W	$F160,$F14C,$F139,$F126,$F113,$F102
	DC.W	$F0F0,$F0E0,$F0D0,$F0C0,$F0B1,$F0A3
	DC.W	$F095,$F088,$F07C,$F070,$F065,$F05A
	DC.W	$F050,$F046,$F03D,$F035,$F02D,$F026
	DC.W	$F020,$F01A,$F015,$F010,$F00C,$F009
	DC.W	$F006,$F004,$F002,$F001,$F001,$F001
	DC.W	$F002,$F004,$F006,$F009,$F00C,$F010
	DC.W	$F015,$F01A,$F020,$F026,$F02D,$F035
	DC.W	$F03D,$F046,$F050,$F05A,$F065,$F070
	DC.W	$F07C,$F088,$F095,$F0A3,$F0B1,$F0C0
	DC.W	$F0D0,$F0E0,$F0F0,$F102,$F113,$F126
	DC.W	$F139,$F14C,$F160,$F175,$F18A,$F1A0
	DC.W	$F1B6,$F1CD,$F1E5,$F1FD,$F215,$F22E
	DC.W	$F248,$F262,$F27D,$F298,$F2B3,$F2D0
	DC.W	$F2EC,$F309,$F327,$F345,$F364,$F383
	DC.W	$F3A3,$F3C3,$F3E4,$F405,$F426,$F448
	DC.W	$F46B,$F48D,$F4B1,$F4D4,$F4F9,$F51D
	DC.W	$F542,$F568,$F58E,$F5B4,$F5DB,$F602
	DC.W	$F629,$F651,$F679,$F6A2,$F6CB,$F6F4
	DC.W	$F71D,$F747,$F772,$F79C,$F7C7,$F7F3
	DC.W	$F81E,$F84A,$F876,$F8A3,$F8CF,$F8FC
	DC.W	$F92A,$F957,$F985,$F9B3,$F9E2,$FA10
	DC.W	$FA3F,$FA6E,$FA9D,$FACD,$FAFC,$FB2C
	DC.W	$FB5C,$FB8C,$FBBD,$FBED,$FC1E,$FC4F
	DC.W	$FC80,$FCB1,$FCE2,$FD13,$FD45,$FD76
	DC.W	$FDA8,$FDDA,$FE0C,$FE3E,$FE70,$FEA2
	DC.W	$FED4,$FF06,$FF38,$FF6A,$FF9D,$FFCF
	DC.W	$0000,$0032,$0065,$0097,$00C9,$00FB
	DC.W	$012D,$015F,$0192,$01C4,$01F5,$0227
	DC.W	$0259,$028B,$02BC,$02EE,$031F,$0350
	DC.W	$0382,$03B2,$03E3,$0414,$0445,$0475
	DC.W	$04A5,$04D5,$0505,$0535,$0564,$0593
	DC.W	$05C2,$05F1,$0620,$064E,$067C,$06AA
	DC.W	$06D7,$0705,$0732,$075E,$078B,$07B7
	DC.W	$07E3,$080F,$083A,$0865,$088F,$08BA
	DC.W	$08E4,$090D,$0937,$095F,$0988,$09B0
	DC.W	$09D8,$09FF,$0A27,$0A4D,$0A73,$0A99
	DC.W	$0ABF,$0AE4,$0B08,$0B2D,$0B50,$0B74
	DC.W	$0B97,$0BB9,$0BDB,$0BFD,$0C1E,$0C3E
	DC.W	$0C5E,$0C7E,$0C9D,$0CBC,$0CDA,$0CF8
	DC.W	$0D15,$0D32,$0D4E,$0D69,$0D85,$0D9F
	DC.W	$0DB9,$0DD3,$0DEC,$0E04,$0E1C,$0E34
	DC.W	$0E4B,$0E61,$0E77,$0E8C,$0EA1,$0EB5
	DC.W	$0EC8,$0EDB,$0EEE,$0EFF,$0F11,$0F21
	DC.W	$0F31,$0F41,$0F50,$0F5E,$0F6C,$0F79
	DC.W	$0F85,$0F91,$0F9C,$0FA7,$0FB1,$0FBB
	DC.W	$0FC4,$0FCC,$0FD4,$0FDB,$0FE1,$0FE7
	DC.W	$0FEC,$0FF1,$0FF5,$0FF8,$0FFB,$0FFD
	DC.W	$0FFF,$1000,$0000,$0000,$0000,$0000

SIN:
	DC.W	$0000,$0032,$0065,$0097,$00C9,$00FB
	DC.W	$012D,$015F,$0192,$01C4,$01F5,$0227
	DC.W	$0259,$028B,$02BC,$02EE,$031F,$0350
	DC.W	$0382,$03B2,$03E3,$0414,$0445,$0475
	DC.W	$04A5,$04D5,$0505,$0535,$0564,$0593
	DC.W	$05C2,$05F1,$0620,$064E,$067C,$06AA
	DC.W	$06D7,$0705,$0732,$075E,$078B,$07B7
	DC.W	$07E3,$080F,$083A,$0865,$088F,$08BA
	DC.W	$08E4,$090D,$0937,$095F,$0988,$09B0
	DC.W	$09D8,$09FF,$0A27,$0A4D,$0A73,$0A99
	DC.W	$0ABF,$0AE4,$0B08,$0B2D,$0B50,$0B74
	DC.W	$0B97,$0BB9,$0BDB,$0BFD,$0C1E,$0C3E
	DC.W	$0C5E,$0C7E,$0C9D,$0CBC,$0CDA,$0CF8
	DC.W	$0D15,$0D32,$0D4E,$0D69,$0D85,$0D9F
	DC.W	$0DB9,$0DD3,$0DEC,$0E04,$0E1C,$0E34
	DC.W	$0E4B,$0E61,$0E77,$0E8C,$0EA1,$0EB5
	DC.W	$0EC8,$0EDB,$0EEE,$0EFF,$0F11,$0F21
	DC.W	$0F31,$0F41,$0F50,$0F5E,$0F6C,$0F79
	DC.W	$0F85,$0F91,$0F9C,$0FA7,$0FB1,$0FBB
	DC.W	$0FC4,$0FCC,$0FD4,$0FDB,$0FE1,$0FE7
	DC.W	$0FEC,$0FF1,$0FF5,$0FF8,$0FFB,$0FFD
	DC.W	$0FFF,$1000,$1000,$1000,$0FFF,$0FFD
	DC.W	$0FFB,$0FF8,$0FF5,$0FF1,$0FEC,$0FE7
	DC.W	$0FE1,$0FDB,$0FD4,$0FCC,$0FC4,$0FBB
	DC.W	$0FB1,$0FA7,$0F9C,$0F91,$0F85,$0F79
	DC.W	$0F6C,$0F5E,$0F50,$0F41,$0F31,$0F21
	DC.W	$0F11,$0EFF,$0EEE,$0EDB,$0EC8,$0EB5
	DC.W	$0EA1,$0E8C,$0E77,$0E61,$0E4B,$0E34
	DC.W	$0E1C,$0E04,$0DEC,$0DD3,$0DB9,$0D9F
	DC.W	$0D85,$0D69,$0D4E,$0D32,$0D15,$0CF8
	DC.W	$0CDA,$0CBC,$0C9D,$0C7E,$0C5E,$0C3E
	DC.W	$0C1E,$0BFC,$0BDB,$0BB9,$0B97,$0B74
	DC.W	$0B50,$0B2D,$0B08,$0AE4,$0ABF,$0A99
	DC.W	$0A73,$0A4D,$0A26,$09FF,$09D8,$09B0
	DC.W	$0988,$095F,$0937,$090D,$08E4,$08BA
	DC.W	$088F,$0865,$083A,$080E,$07E3,$07B7
	DC.W	$078B,$075E,$0732,$0705,$06D7,$06AA
	DC.W	$067C,$064E,$061F,$05F1,$05C2,$0593
	DC.W	$0564,$0534,$0505,$04D5,$04A5,$0475
	DC.W	$0444,$0414,$03E3,$03B2,$0381,$0350
	DC.W	$031F,$02EE,$02BC,$028B,$0259,$0227
	DC.W	$01F5,$01C3,$0191,$015F,$012D,$00FB
	DC.W	$00C9,$0097,$0065,$0032,$0000,$FFCF
	DC.W	$FF9C,$FF6A,$FF38,$FF06,$FED4,$FEA2
	DC.W	$FE70,$FE3E,$FE0C,$FDDA,$FDA8,$FD76
	DC.W	$FD45,$FD13,$FCE2,$FCB1,$FC80,$FC4F
	DC.W	$FC1E,$FBED,$FBBD,$FB8C,$FB5C,$FB2C
	DC.W	$FAFC,$FACD,$FA9D,$FA6E,$FA3F,$FA10
	DC.W	$F9E2,$F9B3,$F985,$F957,$F92A,$F8FC
	DC.W	$F8CF,$F8A3,$F876,$F84A,$F81E,$F7F2
	DC.W	$F7C7,$F79C,$F772,$F747,$F71D,$F6F4
	DC.W	$F6CA,$F6A2,$F679,$F651,$F629,$F602
	DC.W	$F5DB,$F5B4,$F58E,$F568,$F542,$F51D
	DC.W	$F4F9,$F4D4,$F4B1,$F48D,$F46A,$F448
	DC.W	$F426,$F405,$F3E3,$F3C3,$F3A3,$F383
	DC.W	$F364,$F345,$F327,$F309,$F2EC,$F2CF
	DC.W	$F2B3,$F298,$F27C,$F262,$F248,$F22E
	DC.W	$F215,$F1FD,$F1E5,$F1CD,$F1B6,$F1A0
	DC.W	$F18A,$F175,$F160,$F14C,$F139,$F126
	DC.W	$F113,$F102,$F0F0,$F0E0,$F0D0,$F0C0
	DC.W	$F0B1,$F0A3,$F095,$F088,$F07C,$F070
	DC.W	$F065,$F05A,$F050,$F046,$F03D,$F035
	DC.W	$F02D,$F026,$F020,$F01A,$F015,$F010
	DC.W	$F00C,$F009,$F006,$F004,$F002,$F001
	DC.W	$F001,$F001,$F002,$F004,$F006,$F009
	DC.W	$F00C,$F010,$F015,$F01A,$F020,$F026
	DC.W	$F02D,$F035,$F03D,$F046,$F050,$F05A
	DC.W	$F065,$F070,$F07C,$F088,$F095,$F0A3
	DC.W	$F0B1,$F0C0,$F0D0,$F0E0,$F0F0,$F102
	DC.W	$F113,$F126,$F139,$F14C,$F160,$F175
	DC.W	$F18A,$F1A0,$F1B6,$F1CD,$F1E5,$F1FD
	DC.W	$F215,$F22E,$F248,$F262,$F27D,$F298
	DC.W	$F2B3,$F2D0,$F2EC,$F309,$F327,$F345
	DC.W	$F364,$F383,$F3A3,$F3C3,$F3E4,$F405
	DC.W	$F426,$F448,$F46B,$F48D,$F4B1,$F4D4
	DC.W	$F4F9,$F51D,$F542,$F568,$F58E,$F5B4
	DC.W	$F5DB,$F602,$F629,$F651,$F679,$F6A2
	DC.W	$F6CB,$F6F4,$F71D,$F747,$F772,$F79C
	DC.W	$F7C7,$F7F3,$F81E,$F84A,$F876,$F8A3
	DC.W	$F8CF,$F8FC,$F92A,$F957,$F985,$F9B3
	DC.W	$F9E2,$FA10,$FA3F,$FA6E,$FA9D,$FACD
	DC.W	$FAFC,$FB2C,$FB5C,$FB8C,$FBBD,$FBED
	DC.W	$FC1E,$FC4F,$FC80,$FCB1,$FCE2,$FD13
	DC.W	$FD45,$FD76,$FDA8,$FDDA,$FE0C,$FE3E
	DC.W	$FE70,$FEA2,$FED4,$FF06,$FF38,$FF6A
	DC.W	$FF9D,$FFCF,$0000,$0000,$0000,$0000



;*****************************
;*			     *
;*      COPPER1 PROGRAM      *
;*			     *
;*****************************

COPLIST:
	DC.W	$0100,$1200	; Bit-Plane control reg.
	DC.W	$0102,$0000	; Hor-Scroll
	DC.W	$0104,$0010	; Sprite/Gfx priority
	DC.W	$0108,$0000	; Modulo (odd)
	DC.W	$010A,$0000	; Modulo (even)
	DC.W	$008E,$2C71	; Screen Size
	DC.W	$0090,$2Cd1	; Screen Size
	DC.W	$0092,$0038	; H-start
	DC.W	$0094,$00D0	; H-stop
	dc.w	$0180,$0222
	dc.w	$0182,$0FDE

BPL1:	dc.w	$00e0,$0000	;Handler for 6 bitplanes
	dc.w	$00e2,$0000
	DC.L	$FFFFFFFE

	CNOP	0,4
	
;*****************************
;*			     *
;*      SCREEN DATA AREA     *
;*			     *
;*****************************

SCREEN1:
	BLK.B	40*256
	
SCREEN2:
	blk.b	40*256


MT_DATA:
	blk.b	100000
	


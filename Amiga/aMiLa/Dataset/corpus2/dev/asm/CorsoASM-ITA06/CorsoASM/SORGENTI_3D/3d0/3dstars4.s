;************************************************
;*                3D STARTBALLS                 *
;*						*
;*  Coder: EXECUTOR                             *
;*  Date:  xx/04/1992                           *
;************************************************

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

	section	bau,code_C

START:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack
	BSR.B	DEMOIRQ			; demo irq
	BSR.W	SETSCREEN	
	bsr	MAKETABLES

*******Here There is your code*********

LOOP:
	BSR.W	WAITOF			; Wait start of VBlank
	bsr	BLTCLS
	bsr	MOVESTARS	
	bsr	PLOTSTARS
	bsr	SWAPSCREEN	
;	move.w	#$0fff,$dff180
	
	BTST	#6,$BFE001		; Test left mouse button
	BNE.S	LOOP

***************************************

	BSR.W	SYSTEMIRQ		; system irq
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	MOVEQ.L	#$00,D0			; OK..........
	RTS


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


;**********************************
;*				  *
;*       SET USER'S SCREEN        *
;*	     & SPRITES		  *
;**********************************

SETSCREEN:
	
	move.l	#SCREEN1,d0		; insert screen1 in copperlist
	lea	BPL1,a0
	move.w	d0,6(a0)
	swap.w	d0
	move.w	d0,2(a0)
	swap.w	d0
		
	add.l	#44*256,d0
	lea	BPL2,a0
	move.w	d0,6(a0)
	swap.w	d0
	move.w	d0,2(a0)

	rts
	
SWAPSCREEN:
	move.l	SCREEN,a0
	move.l	SCREEN+4,a1
	move.l	a1,SCREEN
	move.l	a0,SCREEN+4

	move.l	SCREEN,d0		; insert screen1 in copperlist
	lea	BPL1,a0
	move.w	d0,6(a0)
	swap.w	d0
	move.w	d0,2(a0)
	swap.w	d0
		
	add.l	#44*256,d0
	lea	BPL2,a0
	move.w	d0,6(a0)
	swap.w	d0
	move.w	d0,2(a0)

	rts


SCREEN:	dc.l	SCREEN1,SCREEN2



;**********************************
;*				  *
;*    INTERRUPT ROUTINE. LEVEL 3  *
;*				  *
;**********************************

IRQ3:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack

;---  Place your interrupt routine here  ---

	MOVE.W	#$4020,$DFF09C		; Clear interrupt request
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	RTE

;**********************************
WAITOF:	move.l	$dff004,d2		;Wait the start of the vertirq
	and.l	#$0001ff00,d2		;and the start of the video scan
	cmp.l	#$00012c00,d2
	bne.b	WAITOF
	rts
;**********************************
	
WAITBLIT:
	btst.b	#6,$dff002
	btst.b	#6,$dff002
	bne.b	WAITBLIT
	rts

BLTCLS:
	move.l	SCREEN+4,a0
	lea	$dff000,a6
WAITB:	btst.b	#6,$02(a6)
	bne	WAITB
	clr.l	$44(a6)
	clr.l	$64(a6)
	move.l	#$01000000,$40(a6)
	move.l	a0,$54(a6)
	move.w	#512*64+22,$58(a6)
	rts

MAKETABLES:
	lea	VALUES,a0
	move.w	#$effc,d0
	move.w	#$1000,d1
LOOP1:	move.w	#$2bc,d2
	move.w	#$2bc,d4
	move.w	#$8000,d3
	muls	d3,d2
	sub.w	d0,d4
	divs	d4,d2
	move.w	d2,(a0)+
	add.w	#$1,d0
	dbf	d1,LOOP1

	lea	STARFIELD,a0
	move.w	NSTARS,d7
LOOP2:
	move.w	#$40,d0
	bsr	RNDSTAR
	sub.w	#$20,d0
	muls	#$20,d0
	move.w	d0,(a0)+
	move.w	#$40,d0
	bsr	RNDSTAR
	sub.w	#$20,d0
	muls	#$20,d0
	move.w	d0,(a0)+
	move.w	#$1f4,d0
	bsr	RNDSTAR
	mulu	#$10,d0
	move.w	d0,(a0)+
	dbf	d7,LOOP2		

	lea	YVALUE,a0
	move.w	#$0,d0
	move.w	#$1ff,d7
LOOP3:	move.w	d0,d1
	muls	#$2c,d1
	move.w	d1,(a0)+
	add.w	#$1,d0
	dbf	d7,LOOP3	
	rts
	
RNDSTAR:
	move.w	d0,d5
	move.w	d5,d4
	subq.w	#$1,d4
	move.l	CARRY,d0
RND2:	add.l	d0,d0
	bhi	RND1
	eor.l	#$1d872b41,d0
RND1:	lsr.w	#$1,d4
	bne	RND2
	move.l	d0,CARRY
	tst.w	d5
	bne	RND3
	swap.w	d0
	bra	RND4
RND3:	mulu.w	d5,d0
RND4:	clr.w	d0
	swap.w	d0
	rts

MOVESTARS:
	lea	HEIGHT,a0
	move.w	addx,d0
	move.w	addy,d1
	move.w	addz,d2
	add.w	d0,X
	add.w	d1,Y
	add.w	d2,Z
	move.w	X,d0
	move.w	Y,d1
	move.w	Z,d2
	and.w	#$7ff,X
	and.w	#$7ff,Y
	and.w	#$7ff,Z
	move.w	(a0,d0.w),d0
	add.w	d0,d0
	move.w	(a0,d1.w),d1
	add.w	d1,d1
	move.w	(a0,d2.w),d2
	asl.w	#$3,d2
	lea	STARFIELD,a0
	move.w	NSTARS,d7
	move.w	#$400,d6
	move.w	#$1fff,d5
	move.w	#$7fe,d4
	add.w	#$400,d0
	add.w	#$400,d1
SLOOP:	add.w	d0,(a0)
	and.w	d4,(a0)
	sub.w	d6,(a0)+
	add.w	d1,(a0)
	and.w	d4,(a0)
	sub.w	d6,(a0)+
	add.w	d2,(a0)
	and.w	d5,(a0)+
	dbf	d7,SLOOP
	rts
	
PLOTSTARS:
	lea	STARFIELD,a0
	lea	PIXEL,a3
	lea	YVALUE,a4
	lea	VALUES,a5
	move.w	NSTARS,d7
	move.w	XADD,d4
	move.w	YADD,d3
	move.l	SCREEN+4,a1
	move.l	a1,a2
	lea	$2c00(a2),a2
ULOOP1:	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	muls	0(a5,d2.w),d0
	muls	0(a5,d2.w),d1
	swap.w	d0
	swap.w	d1
	add.w	d4,d0
	add.w	d3,d1
	cmp.w	#254,d1
	bhi	DELOOP
	cmp.w	#351,d0
	bhi	DELOOP
	cmp.w	#2000,d2
	blt	PRINT1
	cmp.w	#5000,d2
	blt	PRINT2
	move.b	0(a3,d0.w),d6
	asr.w	#$3,d0
	add.w	d1,d1
	add.w	0(a4,d1.w),d0
	or.b	d6,$0(a1,d0.w)
	dbf	d7,ULOOP1		
	rts

PRINT1:	move.b	0(a3,d0.w),d6
	asr.w	#$3,d0
	add.w	d1,d1
	add.w	0(a4,d1.w),d0
	or.b	d6,$0(a1,d0.w)
	or.b	d6,$0(a2,d0.w)
	dbf	d7,ULOOP1
	rts

PRINT2:	move.b	0(a3,d0.w),d6
	asr.w	#$3,d0
	add.w	d1,d1
	add.w	0(a4,d1.w),d0
	or.b	d6,$0(a2,d0.w)
	dbf	d7,ULOOP1
	rts

DELOOP:	dbf	d7,ULOOP1
	rts
	


NSTARS:	dc.w	180		;number of stars
YADD:	dc.w	128
XADD:	dc.w	176
CARRY:	dc.l	$000000b3


X:	dc.w	0
Y:	dc.w	0
Z:	dc.w	0
addx:	dc.w	8
addy:	dc.w	12
addz:	dc.w	4



VALUES:	blk.w	$1000
	blk.w	$1000
	
STARFIELD:
	blk.w	3*180,0	
	blk.w	3*180,0	
	blk.w	3*180,0	
	blk.w	3*180,0	
	blk.w	3*180,0	
	blk.w	3*180,0	
	blk.w	3*180,0	
	
YVALUE:
	blk.w	$2ff

	CNOP	0,4
	
HEIGHT:	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$09,$00,$09,$00,$09,$00,$09
	DC.B	$00,$09,$00,$09,$00,$09,$00,$09
	DC.B	$00,$09,$00,$09,$00,$09,$00,$09
	DC.B	$00,$09,$00,$09,$00,$09,$00,$09
	DC.B	$00,$09,$00,$09,$00,$09,$00,$09
	DC.B	$00,$08,$00,$08,$00,$08,$00,$08
	DC.B	$00,$08,$00,$08,$00,$08,$00,$08
	DC.B	$00,$08,$00,$08,$00,$08,$00,$08
	DC.B	$00,$08,$00,$08,$00,$08,$00,$08
	DC.B	$00,$08,$00,$08,$00,$07,$00,$07
	DC.B	$00,$07,$00,$07,$00,$07,$00,$07
	DC.B	$00,$07,$00,$07,$00,$07,$00,$07
	DC.B	$00,$07,$00,$07,$00,$07,$00,$07
	DC.B	$00,$07,$00,$07,$00,$07,$00,$06
	DC.B	$00,$06,$00,$06,$00,$06,$00,$06
	DC.B	$00,$06,$00,$06,$00,$06,$00,$06
	DC.B	$00,$06,$00,$06,$00,$06,$00,$06
	DC.B	$00,$06,$00,$06,$00,$06,$00,$05
	DC.B	$00,$05,$00,$05,$00,$05,$00,$05
	DC.B	$00,$05,$00,$05,$00,$05,$00,$05
	DC.B	$00,$05,$00,$05,$00,$05,$00,$05
	DC.B	$00,$05,$00,$05,$00,$04,$00,$04
	DC.B	$00,$04,$00,$04,$00,$04,$00,$04
	DC.B	$00,$04,$00,$04,$00,$04,$00,$04
	DC.B	$00,$04,$00,$04,$00,$04,$00,$04
	DC.B	$00,$03,$00,$03,$00,$03,$00,$03
	DC.B	$00,$03,$00,$03,$00,$03,$00,$03
	DC.B	$00,$03,$00,$03,$00,$03,$00,$03
	DC.B	$00,$03,$00,$03,$00,$02,$00,$02
	DC.B	$00,$02,$00,$02,$00,$02,$00,$02
	DC.B	$00,$02,$00,$02,$00,$02,$00,$02
	DC.B	$00,$02,$00,$02,$00,$02,$00,$02
	DC.B	$00,$01,$00,$01,$00,$01,$00,$01
	DC.B	$00,$01,$00,$01,$00,$01,$00,$01
	DC.B	$00,$01,$00,$01,$00,$01,$00,$01
	DC.B	$00,$01,$00,$01,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$FF,$FF,$FF,$FF,$FF,$FF
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE
	DC.B	$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE
	DC.B	$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE
	DC.B	$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE
	DC.B	$FF,$FE,$FF,$FD,$FF,$FD,$FF,$FD
	DC.B	$FF,$FD,$FF,$FD,$FF,$FD,$FF,$FD
	DC.B	$FF,$FD,$FF,$FD,$FF,$FD,$FF,$FD
	DC.B	$FF,$FD,$FF,$FD,$FF,$FD,$FF,$FC
	DC.B	$FF,$FC,$FF,$FC,$FF,$FC,$FF,$FC
	DC.B	$FF,$FC,$FF,$FC,$FF,$FC,$FF,$FC
	DC.B	$FF,$FC,$FF,$FC,$FF,$FC,$FF,$FC
	DC.B	$FF,$FC,$FF,$FC,$FF,$FB,$FF,$FB
	DC.B	$FF,$FB,$FF,$FB,$FF,$FB,$FF,$FB
	DC.B	$FF,$FB,$FF,$FB,$FF,$FB,$FF,$FB
	DC.B	$FF,$FB,$FF,$FB,$FF,$FB,$FF,$FB
	DC.B	$FF,$FB,$FF,$FB,$FF,$FA,$FF,$FA
	DC.B	$FF,$FA,$FF,$FA,$FF,$FA,$FF,$FA
	DC.B	$FF,$FA,$FF,$FA,$FF,$FA,$FF,$FA
	DC.B	$FF,$FA,$FF,$FA,$FF,$FA,$FF,$FA
	DC.B	$FF,$FA,$FF,$FA,$FF,$FA,$FF,$F9
	DC.B	$FF,$F9,$FF,$F9,$FF,$F9,$FF,$F9
	DC.B	$FF,$F9,$FF,$F9,$FF,$F9,$FF,$F9
	DC.B	$FF,$F9,$FF,$F9,$FF,$F9,$FF,$F9
	DC.B	$FF,$F9,$FF,$F9,$FF,$F9,$FF,$F9
	DC.B	$FF,$F9,$FF,$F8,$FF,$F8,$FF,$F8
	DC.B	$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8
	DC.B	$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8
	DC.B	$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8
	DC.B	$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8
	DC.B	$FF,$F8,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F5,$FF,$F5,$FF,$F5,$FF,$F5
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F6
	DC.B	$FF,$F6,$FF,$F6,$FF,$F6,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F7,$FF,$F7,$FF,$F7,$FF,$F7
	DC.B	$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8
	DC.B	$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8
	DC.B	$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8
	DC.B	$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8
	DC.B	$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8
	DC.B	$FF,$F9,$FF,$F9,$FF,$F9,$FF,$F9
	DC.B	$FF,$F9,$FF,$F9,$FF,$F9,$FF,$F9
	DC.B	$FF,$F9,$FF,$F9,$FF,$F9,$FF,$F9
	DC.B	$FF,$F9,$FF,$F9,$FF,$F9,$FF,$F9
	DC.B	$FF,$F9,$FF,$F9,$FF,$FA,$FF,$FA
	DC.B	$FF,$FA,$FF,$FA,$FF,$FA,$FF,$FA
	DC.B	$FF,$FA,$FF,$FA,$FF,$FA,$FF,$FA
	DC.B	$FF,$FA,$FF,$FA,$FF,$FA,$FF,$FA
	DC.B	$FF,$FA,$FF,$FA,$FF,$FA,$FF,$FB
	DC.B	$FF,$FB,$FF,$FB,$FF,$FB,$FF,$FB
	DC.B	$FF,$FB,$FF,$FB,$FF,$FB,$FF,$FB
	DC.B	$FF,$FB,$FF,$FB,$FF,$FB,$FF,$FB
	DC.B	$FF,$FB,$FF,$FB,$FF,$FB,$FF,$FC
	DC.B	$FF,$FC,$FF,$FC,$FF,$FC,$FF,$FC
	DC.B	$FF,$FC,$FF,$FC,$FF,$FC,$FF,$FC
	DC.B	$FF,$FC,$FF,$FC,$FF,$FC,$FF,$FC
	DC.B	$FF,$FC,$FF,$FC,$FF,$FD,$FF,$FD
	DC.B	$FF,$FD,$FF,$FD,$FF,$FD,$FF,$FD
	DC.B	$FF,$FD,$FF,$FD,$FF,$FD,$FF,$FD
	DC.B	$FF,$FD,$FF,$FD,$FF,$FD,$FF,$FD
	DC.B	$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE
	DC.B	$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE
	DC.B	$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE
	DC.B	$FF,$FE,$FF,$FE,$FF,$FF,$FF,$FF
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$01
	DC.B	$00,$01,$00,$01,$00,$01,$00,$01
	DC.B	$00,$01,$00,$01,$00,$01,$00,$01
	DC.B	$00,$01,$00,$01,$00,$01,$00,$01
	DC.B	$00,$01,$00,$02,$00,$02,$00,$02
	DC.B	$00,$02,$00,$02,$00,$02,$00,$02
	DC.B	$00,$02,$00,$02,$00,$02,$00,$02
	DC.B	$00,$02,$00,$02,$00,$02,$00,$03
	DC.B	$00,$03,$00,$03,$00,$03,$00,$03
	DC.B	$00,$03,$00,$03,$00,$03,$00,$03
	DC.B	$00,$03,$00,$03,$00,$03,$00,$03
	DC.B	$00,$03,$00,$04,$00,$04,$00,$04
	DC.B	$00,$04,$00,$04,$00,$04,$00,$04
	DC.B	$00,$04,$00,$04,$00,$04,$00,$04
	DC.B	$00,$04,$00,$04,$00,$04,$00,$05
	DC.B	$00,$05,$00,$05,$00,$05,$00,$05
	DC.B	$00,$05,$00,$05,$00,$05,$00,$05
	DC.B	$00,$05,$00,$05,$00,$05,$00,$05
	DC.B	$00,$05,$00,$05,$00,$06,$00,$06
	DC.B	$00,$06,$00,$06,$00,$06,$00,$06
	DC.B	$00,$06,$00,$06,$00,$06,$00,$06
	DC.B	$00,$06,$00,$06,$00,$06,$00,$06
	DC.B	$00,$06,$00,$06,$00,$07,$00,$07
	DC.B	$00,$07,$00,$07,$00,$07,$00,$07
	DC.B	$00,$07,$00,$07,$00,$07,$00,$07
	DC.B	$00,$07,$00,$07,$00,$07,$00,$07
	DC.B	$00,$07,$00,$07,$00,$07,$00,$08
	DC.B	$00,$08,$00,$08,$00,$08,$00,$08
	DC.B	$00,$08,$00,$08,$00,$08,$00,$08
	DC.B	$00,$08,$00,$08,$00,$08,$00,$08
	DC.B	$00,$08,$00,$08,$00,$08,$00,$08
	DC.B	$00,$08,$00,$09,$00,$09,$00,$09
	DC.B	$00,$09,$00,$09,$00,$09,$00,$09
	DC.B	$00,$09,$00,$09,$00,$09,$00,$09
	DC.B	$00,$09,$00,$09,$00,$09,$00,$09
	DC.B	$00,$09,$00,$09,$00,$09,$00,$09
	DC.B	$00,$09,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0A,$00,$0A
	DC.B	$00,$0A,$00,$0A,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0B,$00,$0B,$00,$0B
	DC.B	$00,$0B,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	DC.B	$00,$0C,$00,$0C,$00,$0C,$00,$0C
	
PIXEL:	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01
	DC.B	$80,$40,$20,$10,$08,$04,$02,$01

	
	CNOP	0,4
	
;*****************************
;*			     *
;*      COPPER1 PROGRAM      *
;*			     *
;*****************************

COPLIST:
	DC.W	$0100,$2200	; Bit-Plane control reg.
	DC.W	$0102,$0000	; Hor-Scroll
	DC.W	$0104,$0010	; Sprite/Gfx priority
	DC.W	$0108,$0000	; Modulo (odd)
	DC.W	$010A,$0000	; Modulo (even)
	DC.W	$008E,$2C71	; Screen Size
	DC.W	$0090,$2CD1	; Screen Size
	DC.W	$0092,$0030	; H-start
	DC.W	$0094,$00D8	; H-stop

BPL1:	dc.w	$00e0,$0000	;Handler for 6 bitplanes
	dc.w	$00e2,$0000
BPL2:	dc.w	$00e4,$0000
	dc.w	$00e6,$0000

cop1:	dc.w	$0180,$0000
	dc.w	$0182,$0FFF
	dc.w	$0184,$077A
	dc.w	$0186,$0336
	
	dc.w	$2c09,$fffe
	dc.w	$0180,$0000
	dc.w	$ffdf,$fffe
	dc.w	$2c09,$fffe
	dc.w	$0180,$0000
	
	DC.L	$FFFFFFFE

	CNOP	0,4
	
;*****************************
;*			     *
;*      SCREEN DATA AREA     *
;*			     *
;*****************************

SCREEN1:
	BLK.B	44*256*2
SCREEN2:
	BLK.B	44*256*2
	
	

; =============================================================================
; -----------------------------------------------------------------------------
; File:		ChunkyCopper_xx.s
; Contents:	Chunky on copper
; Author:	Jacek (Noe) Cybularczyk / Venus Art
; Copyright:	©1995 by Noe
; -----------------------------------------------------------------------------
; History:
; 05.04.1995	created first version
; 06.04.1995	debug

; -----------------------------------------------------------------------------
; resolution: 128*86
; pixel size: 2*3
; -----------------------------------------------------------------------------
; =============================================================================

CINS_PER_LINE	=	134/3
WIDTH		=	128
HEIGHT		=	86
X_ASPECT	=	2
Y_ASPECT	=	3
VPOS		=	$2c

; =============================================================================

		SECTION	ChunkyCopper_0,code

; -----------------------------------------------------------------------------
; Procedure:	ChunktOn
; Function:	On copper chunky
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ChunkyOn	lea	CUSTOM,a5

		move.w	dmaconr(a5),OldDmaControl
		move.w	#$7fff,dmacon(a5)

		lea	CopperList,a0

		lea	cl_Planes,a1

		move.l	#Planes,d0
		moveq	#6,d7

is_Loop0	swap	d0
		move.w	d0,2(a1)
		swap	d0
		move.w	d0,6(a1)

		add.l	#32,d0
		addq.w	#8,a1
		dbra	d7,is_Loop0

		lea	cl_Chunky,a1
		move.w	#HEIGHT-1,d7

		move.l	#(VPOS-Y_ASPECT)<<24+$01fffe,d1	wait line instruction
		move.l	#bplcon4<<16,d2		magic the change line bit

is_Loop1	moveq	#0,d6
		move.l	#bplcon3<<16+$0020,d5

		move.l	d1,(a1)+
		add.l	#Y_ASPECT<<24,d1
		move.l	d2,(a1)+
		add.w	#$8000,d2
		btst	#15,d2
		beq.b	is_Loop2
		add.w	#$8000,d5

is_Loop2	move.w	d6,d4
		andi.w	#$001f,d4
		bne.b	is_NoBanking
		move.l	d5,(a1)+
		add.w	#$2000,d5

is_NoBanking	lsl.w	#1,d4
		or.w	#color,d4
		move.w	d4,(a1)+
		move.w	#$000,(a1)+

		addq.w	#1,d6

		cmpi.w	#WIDTH,d6
		blt.b	is_Loop2

		dbra	d7,is_Loop1

		move.l	a0,cop1lc(a5)
		move.w	#0,copjmp1(a5)

		move.w	#$83c0,dmacon(a5)
		rts


; -----------------------------------------------------------------------------
; Procedure:	ChunkyOff
; Function:	Off copper chunky
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ChunkyOff	lea	CUSTOM,a5
		move.w	#$7fff,dmacon(a5)
		move.l	#cl_End,cop1lc(a5)
		move.w	#0,copjmp1(a5)
		bset.b	#7,OldDmaControl
		move.w	OldDmaControl,dmacon(a5)

		move.w	#$0020,beamcon0(a5)

		rts


; -----------------------------------------------------------------------------
; Procedure:	ClearChunky
; Function:	Clear chunky buffer
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ClearChunky	lea	Chunky,a0
		move.w	#WIDTH*HEIGHT-1,d7

cc_Loop		move.w	#0,(a0)+
		dbra	d7,cc_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	ChunkyToCopper
; Function:	Convert chunky to copper list
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ChunkyToCopper	lea	Chunky,a0
		lea	cl_Chunky+3*4+2,a1

		moveq	#HEIGHT-1,d6

ctc_Loop1	moveq	#3,d7

ctc_Loop0	move.w	(a0)+,(a1)
		move.w	(a0)+,4(a1)
		move.w	(a0)+,8(a1)
		move.w	(a0)+,12(a1)
		move.w	(a0)+,16(a1)
		move.w	(a0)+,20(a1)
		move.w	(a0)+,24(a1)
		move.w	(a0)+,28(a1)
		move.w	(a0)+,32(a1)
		move.w	(a0)+,36(a1)
		move.w	(a0)+,40(a1)
		move.w	(a0)+,44(a1)
		move.w	(a0)+,48(a1)
		move.w	(a0)+,52(a1)
		move.w	(a0)+,56(a1)
		move.w	(a0)+,60(a1)
		move.w	(a0)+,64(a1)
		move.w	(a0)+,68(a1)
		move.w	(a0)+,72(a1)
		move.w	(a0)+,76(a1)
		move.w	(a0)+,80(a1)
		move.w	(a0)+,84(a1)
		move.w	(a0)+,88(a1)
		move.w	(a0)+,92(a1)
		move.w	(a0)+,96(a1)
		move.w	(a0)+,100(a1)
		move.w	(a0)+,104(a1)
		move.w	(a0)+,108(a1)
		move.w	(a0)+,112(a1)
		move.w	(a0)+,116(a1)
		move.w	(a0)+,120(a1)
		move.w	(a0)+,124(a1)

		lea	128+4(a1),a1
		dbra	d7,ctc_Loop0

		addq.l	#2*4,a1
		dbra	d6,ctc_Loop1

		rts

; -----------------------------------------------------------------------------
; Special data
; -----------------------------------------------------------------------------

OldDmaControl	DC.W	0

; -----------------------------------------------------------------------------

		SECTION	ChunkyCopper_1,data_c

CopperList	CNOP	0,2
		DC.W	color,$000
		DC.W	diwstrt,VPOS<<8+$a1
		DC.W	diwstop,(VPOS+HEIGHT*Y_ASPECT-256)<<8+$a1
		DC.W	ddfstrt,$0038
		DC.W	ddfstop,$00b0
		DC.W	bplcon0,$7201
		DC.W	bplcon1,$8800
		DC.W	bplcon2,$0224
		DC.W	bplcon3,$0020
		DC.W	bplcon4,$0011
		DC.W	bpl1mod,-32-8
		DC.W	bpl2mod,-32-8

		DC.W	fmode,$0003

cl_Planes	DC.W	bplpt,0
		DC.W	bplpt+2,0
		DC.W	bplpt+4,0
		DC.W	bplpt+6,0
		DC.W	bplpt+8,0
		DC.W	bplpt+10,0
		DC.W	bplpt+12,0
		DC.W	bplpt+14,0
		DC.W	bplpt+16,0
		DC.W	bplpt+18,0
		DC.W	bplpt+20,0
		DC.W	bplpt+22,0
		DC.W	bplpt+24,0
		DC.W	bplpt+26,0

cl_Chunky	; 2+1+32+1+32+1+32+1+32 = 128 colors

		DCB.L	134*HEIGHT

cl_End		DC.L	-2


Planes		CNOP	0,8

		REPT	8
		DC.L	$33333333
		ENDR

		REPT	8
		DC.L	$0f0f0f0f
		ENDR

		REPT	8
		DC.L	$00ff00ff
		ENDR

		REPT	8
		DC.L	$0000ffff
		ENDR

		REPT	4
		DC.L	$00000000,$ffffffff
		ENDR

		REPT	2
		DC.L	$00000000,$00000000,$ffffffff,$ffffffff
		ENDR

		DC.L	$00000000,$00000000,$00000000,$00000000
		DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff

; -----------------------------------------------------------------------------

		SECTION	ChunkyCopper_2,bss_c

Chunky		DCB.W	WIDTH*HEIGHT

; -----------------------------------------------------------------------------
; =============================================================================

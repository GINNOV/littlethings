; ===========================================================================
; Name:		CommancheText
; File:		CommancheText_xx.s
; Author:	Noe / Venus Art
; Copyright:	© 1995 by Venus Art
; ---------------------------------------------------------------------------
; History:
; 04.07.1995	

; ===========================================================================

COMT_WIDTH	=	576
COMT_HEIGHT	=	123

COMT_WIDTH_B	=	COMT_WIDTH>>3


		INCDIR	"DEMO:"

; ---------------------------------------------------------------------------

		SECTION	ComancheText_0,CODE

ComancheText1

COMT_Start	move.l	(a0),a0
		addq.w	#MAGIC_NUMBER,a0
		move.l	a0,COMT_Picture
		move.l	a0,COMT_Picture1
		add.l	#17568,COMT_Picture1
		move.l	COMT_Picture1,COMT_Picture2
		adda.l	#35424,a0
		move.l	a0,COMT_Palette

	IFEQ	DEBUG

		lea	CUSTOM,a5

;		move.w	dmaconr(a5),DMA_old
;		move.w	#$01f0,dmacon+CUSTOM
;		move.w	#$83cf,dmacon(a5)

	ENDC

;		move.l	#$ff0000,TextPalette+8*4
		bsr.w	COMT_InitView

		moveq	#5,d0
		jsr	Wait

		move.l	COMT_Picture1,d5
		move.w	#$6801,d1
		move.l	COMT_Picture2,d2
		move.w	#$e1e1,d3
		moveq	#61,d6
COMT_MainLoop
		moveq	#0,d0
		jsr	Wait
		bsr.w	COMT_SetUpPlanes
		bsr.w	COMT_SetDownPlanes

		subi.l	#288,d5
		addi.w	#$0100,d1
		subi.w	#$0100,d3

		dbra	d6,COMT_MainLoop

		rts

ComancheText2
		bsr.w	COMT_Dissolve

;		moveq	#100,d0
;		jsr	Wait

		rts

ComancheText3
		bsr.w	COMT_FadeOut

COMT_End
	IFEQ	DEBUG

		lea	CUSTOM,a5

;		move.w	DMA_old,d0
;		bset.l	#15,d0
;		move.w	#$7fff,dmacon(a5)
;		move.w	d0,dmacon(a5)

	ENDC

		moveq	#0,d0
		rts

DMA_old		DC.W	0


; ===========================================================================
; Procedure:	COMT_InitView
; Function:	Initialize view
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COMT_InitView
		lea	CUSTOM,a5

		move.l	COMT_Palette,a0
		moveq	#16-1,d7
		jsr	SetPalette

		move.l	COMT_Picture1,d5
		move.w	#$6801,d1
		bsr.w	COMT_SetUpPlanes

		move.l	COMT_Picture2,d2
		move.w	#$e401,d3
		bsr.w	COMT_SetDownPlanes

		move.l	#$c2014400,bplcon0(a5)
		move.w	#$0000,bplcon2(a5)
		move.w	#$0000,bplcon4(a5)

		move.w	#-8+3*COMT_WIDTH_B,bpl1mod(a5)
		move.w	#-8+3*COMT_WIDTH_B,bpl2mod(a5)

		move.w	#3,fmode(a5)

		move.w	#$6891,diwstrt(a5)
		move.w	#$e3b1,diwstop(a5)

		move.w	#$0038,ddfstrt(a5)
		move.w	#$00c0,ddfstop(a5)

		move.l	#COMT_CopperList,cop1lc(a5)
		move.w	d0,copjmp1(a5)

		rts


; ===========================================================================
; Procedure:	COMT_SetDownPlanes
; Function:	Set pointers to planes displayed down screen
; In:
;	d2.l	pointer to planes
;	d3.w	down start position (<<8 + $01)
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COMT_SetDownPlanes
		lea	COMT_DownPlanes,a0
		move.l	d2,d4
		move.w	d3,COMT_DownStart
		bra.b	COMT_SetPlanes


; ===========================================================================
; Procedure:	COMT_SetUpPlanes
; Function:	Set pointers to planes displayed up screen
; In:
;	d5.l	pointer to planes
;	d1.w	up stop position (<<8 + $01)
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COMT_SetUpPlanes
		lea	COMT_UpPlanes,a0
		move.l	d5,d4
		move.w	d1,COMT_UpStop
COMT_SetPlanes
		moveq	#3,d7
COMT_sp_Loop
		move.w	d4,6(a0)
		swap	d4
		move.w	d4,2(a0)
		swap	d4

		addq.w	#8,a0
		addi.l	#COMT_WIDTH_B,d4

		dbra	d7,COMT_sp_Loop

		rts


; ===========================================================================
; Procedure:	COMT_FadeOut
; Function:	Fade out...
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COMT_FadeOut
COMT_fo_Loop1
		move.l	COMT_Palette,a1
		adda.w	#4*8,a1
		moveq	#0,d1

		moveq	#7,d5
COMT_fo_Loop0
		move.b	1(a1),d0
		beq.b	COMT_fo0
		moveq	#1,d1
		subq.b	#1,d0
		move.b	d0,1(a1)
COMT_fo0
		move.b	2(a1),d0
		beq.b	COMT_fo1
		moveq	#1,d1
		subq.b	#1,d0
		move.b	d0,2(a1)
COMT_fo1
		move.b	3(a1),d0
		beq.b	COMT_fo2
		moveq	#1,d1
		subq.b	#1,d0
		move.b	d0,3(a1)
COMT_fo2
		addq.w	#4,a1

		dbra	d5,COMT_fo_Loop0

		moveq	#80,d0
		jsr	RasterLineWait

		move.w	d1,d5

		move.l	COMT_Palette,a0
		moveq	#15,d7
		jsr	SetPalette

		dbra	d5,COMT_fo_Loop1

		rts


; ===========================================================================
; Procedure:	COMT_Dissolve
; Function:	Dissolve "AND NOW ..." into "COMANCHE ..."
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COMT_Dissolve

COMT_d_Loop1
		move.l	COMT_Palette,a1
		moveq	#0,d1

		moveq	#7,d5
COMT_d_Loop0
		move.b	1(a1),d0
		beq.b	COMT_d0
		moveq	#1,d1
		subq.b	#1,d0
		move.b	d0,1(a1)
COMT_d0
		move.b	2(a1),d0
		beq.b	COMT_d1
		moveq	#1,d1
		subq.b	#1,d0
		move.b	d0,2(a1)
COMT_d1
		move.b	3(a1),d0
		beq.b	COMT_d2
		moveq	#1,d1
		subq.b	#1,d0
		move.b	d0,3(a1)
COMT_d2
		addq.w	#4,a1

		dbra	d5,COMT_d_Loop0

		moveq	#7,d5
COMT_d_Loop2
		move.b	1(a1),d0
		addq.b	#1,d0
		beq.b	COMT_d3
		moveq	#1,d1
		move.b	d0,1(a1)
COMT_d3
		move.b	2(a1),d0
		addq.b	#1,d0
		beq.b	COMT_d4
		moveq	#1,d1
		move.b	d0,2(a1)
COMT_d4
		move.b	3(a1),d0
		addq.b	#1,d0
		beq.b	COMT_d5
		moveq	#1,d1
		move.b	d0,3(a1)
COMT_d5
		addq.w	#4,a1

		dbra	d5,COMT_d_Loop2

		moveq	#80,d0
		jsr	RasterLineWait

		move.w	d1,d5

		move.l	COMT_Palette,a0
		moveq	#15,d7
		jsr	SetPalette

		dbra	d5,COMT_d_Loop1

		rts

; ---------------------------------------------------------------------------

COMT_Picture	DC.L	0
COMT_Picture1	DC.L	0
COMT_Picture2	DC.L	0
COMT_Palette	DC.L	0

; ---------------------------------------------------------------------------

		SECTION	ComancheText_1,DATA


; ---------------------------------------------------------------------------

		SECTION	ComancheText_2,DATA_C

COMT_CopperList

COMT_UpPlanes
TMP1		SET	bplpt
		REPT	8
		DC.W	TMP1,0
TMP1		SET	TMP1+2
		ENDR

COMT_UpStop	DC.W	$6801,-2
		DC.W	bplcon0,$8201

COMT_DownStart	DC.W	$e401,-2
		DC.W	bplcon0,$c201

COMT_DownPlanes
TMP2		SET	bplpt
		REPT	8
		DC.W	TMP2,0
TMP2		SET	TMP2+2
		ENDR

		DC.L	-2

; ---------------------------------------------------------------------------

; ===========================================================================

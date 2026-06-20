; =============================================================================
; -----------------------------------------------------------------------------
; File:		DoomPicture_xx.s
; Contents:	Next part of demo (Show and fade picture)
; Author:	Jacek (Noe) Cybularczyk / Venus Art
; Copyright:	©1994/1995 by Noe
; -----------------------------------------------------------------------------
; History:
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
; =============================================================================

DP_WIDTH	=	640
DP_WIDTH2	=	DP_WIDTH>>1
DP_WIDTH_B	=	DP_WIDTH>>3
DP_WIDTH_W	=	DP_WIDTH>>4
DP_HEIGHT	=	512
DP_HEIGHT2	=	DP_HEIGHT>>1
DP_PLANE_SIZE	=	DP_WIDTH_B*DP_HEIGHT
DP_DEPTH	=	8

DP_SPRITE_POS_X	=	28+64
DP_SPRITE_POS_Y	=	210
DP_SPRITE_HEIGHT	=	58

; =============================================================================

		SECTION	DoomPicture_0,CODE

DoomPicture
			move.l	#EmptyCprList,cop1lc+CUSTOM
			move.w	#0,copjmp1+CUSTOM

		move.l	(a0)+,a1
		addq.w	#MAGIC_NUMBER,a1
		move.l	a1,DP_Palette
		adda.w	#840,a1
		move.l	a1,DP_FSpeedBuffer
		adda.w	#1280,a1
		move.l	a1,DP_FadeInOffset
		adda.w	#72,a1
		move.l	a1,DP_FadeInTable
		move.l	(a0),a1
		addq.w	#MAGIC_NUMBER,a1
		move.l	a1,DP_Picture
		adda.l	#327680,a1
		move.l	a1,DP_Sprite

		AllocMemBlocks	DP_MemEntry
		bne.w	DP_AllocMemError
		move.l	d0,DP_MemEntryPtr

		sub.l	a0,a0
		move.w	#255,d7
		jsr	SetPalette

		move.w	#$0200,bplcon0+CUSTOM

		bsr.w	DP_SetMemPtrs

		bsr.w	DP_InitLineTable

		bsr.w	DP_InitFadeIn

		bsr.w	DP_InitScreen

		move.w	#20,d0
		jsr	Wait

		bsr.w	DP_FadeIn

		move.w	#150,d0
		jsr	Wait

		bsr.w	DP_ShowText

		move.w	#200,d0
		jsr	Wait

		bsr.w	DP_DoomFade

		move.w	#100,d0
		jsr	Wait

		bsr.w	DP_FadeOut

		lea	CUSTOM,a5

		move.w	#$0000,bplcon0(a5)

		move.w	#$01a0,dmacon(a5)
		move.w	#$83d0,dmacon(a5)

		FreeMemBlocks	DP_MemEntryPtr

DP_AllocMemError
		moveq	#0,d0
		rts


; ===========================================================================
; Procedure:	DP_SetmemPtrs
; Function:	Set pointers to allocated memory blocks
; In:
;	none
; Out:
;	none
; Crash regs:
;	a0
; ===========================================================================

DP_SetMemPtrs
		move.l	DP_MemEntryPtr,a0
		lea	14+2(a0),a0

		move.l	(a0),DP_CopperList1
		move.l	8(a0),DP_FVPosBuffer
		move.l	2*8(a0),DP_LineAddress
		move.l	3*8(a0),DP_PlanesDisplay
		move.l	4*8(a0),DP_FadeInAddr
		move.l	5*8(a0),DP_FadeInCntr

		rts


; -----------------------------------------------------------------------------
; Procedure:	DP_FadeOut
; Function:	Fade out all
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

DP_FadeOut
		move.l	DP_BackColor1,a0
		move.l	DP_BackColor2,a1
		move.l	DP_SPalette1,a2
		move.l	DP_SPalette2,a3

		moveq	#14,d7
DP_fo_Loop0
		subi.w	#$0011,2(a2)
		subi.w	#$0011,6(a2)
		subi.w	#$0011,10(a2)
		subi.w	#$0011,14(a2)

		subi.w	#$0011,2(a3)
		subi.w	#$0011,6(a3)
		subi.w	#$0011,10(a3)
		subi.w	#$0011,14(a3)

		moveq	#5,d0
		jsr	Wait

		dbra	d7,DP_fo_Loop0

		moveq	#14,d7
DP_fo_Loop1
		subi.w	#$0100,2(a0)
		subi.w	#$0100,2(a1)

		subi.w	#$0100,2(a2)
		subi.w	#$0100,6(a2)
		subi.w	#$0100,10(a2)
		subi.w	#$0100,14(a2)

		subi.w	#$0100,2(a3)
		subi.w	#$0100,6(a3)
		subi.w	#$0100,10(a3)
		subi.w	#$0100,14(a3)

		moveq	#5,d0
		jsr	Wait

		dbra	d7,DP_fo_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	DP_InitScreen
; Function:	Initialize planes and copper list
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

DP_InitScreen	movem.l	d0-d7/a0-a6,-(sp)

		lea	CUSTOM,a5

		move.w	#$7df0,dmacon(a5)

		move.w	#$2a81,diwstrt(a5)
		move.w	#$2ac1,diwstop(a5)
		move.w	#$2100,diwhigh(a5)

		move.w	#$0038,ddfstrt(a5)
		move.w	#$00d0,ddfstop(a5)

		move.w	#-8+DP_WIDTH_B*15,bpl1mod(a5)
		move.w	#-8+DP_WIDTH_B*15,bpl2mod(a5)

		move.l	#$82140000,bplcon0(a5)
		move.l	#$02240080,bplcon2(a5)
		move.w	#$00ff,bplcon4(a5)

		move.w	#$000f,fmode(a5)


		move.l	DP_CopperList1,a0
		move.l	DP_Palette,a1
		move.w	#210-1,d7
		jsr	SetCopperPalette

		move.l	DP_PlanesDisplay,d0
		moveq	#DP_DEPTH-1,d7
		moveq	#DP_WIDTH_B,d1
		jsr	SetCopperBplPtrs

		move.w	#sprpt,d2
		move.l	DP_Sprite,d0
		moveq	#8-1,d7
		move.l	#(DP_SPRITE_HEIGHT+2)*64/8*2,d1
		jsr	sbp_Loop

		move.l	#bplcon3<<16+$e080,(a0)+

		move.l	a0,DP_SPalette1
		move.l	#(color+17*2)<<16,(a0)+
		move.l	#(color+(17+4)*2)<<16,(a0)+
		move.l	#(color+(17+8)*2)<<16,(a0)+
		move.l	#(color+(17+12)*2)<<16,(a0)+

		move.l	a0,DP_BackColor1
		move.l	#(color+(31)*2)<<16+$f00,(a0)+

		move.l	#cop1lc<<16,(a0)+
		move.l	#(cop1lc+2)<<16,(a0)+

		move.l	#-2,(a0)+

		move.l	a0,DP_CopperList2
		move.l	a0,d0
		move.w	d0,-6(a0)
		swap	d0
		move.w	d0,-10(a0)

		move.l	DP_Palette,a1
		move.w	#210-1,d7
		jsr	SetCopperPalette

		move.l	DP_PlanesDisplay,d0
		addi.l	#DP_DEPTH*DP_WIDTH_B,d0
		moveq	#DP_DEPTH-1,d7
		moveq	#DP_WIDTH_B,d1
		jsr	SetCopperBplPtrs

		move.w	#sprpt,d2
		move.l	DP_Sprite,d0
		moveq	#8-1,d7
		move.l	#(DP_SPRITE_HEIGHT+2)*64/8*2,d1
		jsr	sbp_Loop

		move.l	#bplcon3<<16+$e080,(a0)+

		move.l	a0,DP_SPalette2
		move.l	#(color+17*2)<<16,(a0)+
		move.l	#(color+(17+4)*2)<<16,(a0)+
		move.l	#(color+(17+8)*2)<<16,(a0)+
		move.l	#(color+(17+12)*2)<<16,(a0)+

		move.l	a0,DP_BackColor2
		move.l	#(color+(31)*2)<<16+$f00,(a0)+

		move.l	DP_CopperList1,d0

		move.w	#cop1lc,(a0)+
		swap	d0
		move.w	d0,(a0)+
		swap	d0
		move.w	#cop1lc+2,(a0)+
		move.w	d0,(a0)+

		move.l	#-2,(a0)


		move.l	DP_Sprite,a0
		move.w	#DP_SPRITE_POS_Y<<8+DP_SPRITE_POS_X,d0
		move.w	#(DP_SPRITE_POS_Y+DP_SPRITE_HEIGHT-256)<<8+2,d1
		moveq	#6,d7

DP_is_Loop2	move.w	d0,(a0)
		move.w	d1,8(a0)

		lea	(DP_SPRITE_HEIGHT+2)*64/8*2(a0),a0
		add.w	#16,d0

		dbra	d7,DP_is_Loop2


		move.w	#$83c0,dmacon(a5)

		move.l	DP_CopperList1,cop1lc(a5)
		move.w	#0,copjmp1(a5)

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	DP_InitfadeIn
; Function:	Initialize FadeIn tables
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

DP_InitFadeIn
		move.l	DP_FadeInOffset,a0
		move.l	DP_FadeInTable,d0

		moveq	#17,d7
DP_ifi_Loop0
		add.l	d0,(a0)+

		dbra	d7,DP_ifi_Loop0

		move.l	DP_FadeInOffset,a0
		move.l	DP_PlanesDisplay,d1
		move.l	DP_Picture,d2

		moveq	#17,d7
DP_ifi_Loop1
		move.l	(a0)+,a1
DP_ifi_Loop2
		move.l	(a1),d0
		bmi.b	DP_ifi0

		add.l	d2,(a1)+
		add.l	d1,(a1)+
		addq.w	#4,a1
		bra.b	DP_ifi_Loop2
DP_ifi0
		move.l	#0,(a1)

		dbra	d7,DP_ifi_Loop1

		move.l	DP_FadeInAddr,a0
		move.l	DP_FadeInCntr,a1

		moveq	#0,d0
		moveq	#-18,d1
		moveq	#2,d2

		moveq	#7,d7
DP_ifi_Loop3
		moveq	#9,d6
DP_ifi_Loop4
		move.l	d0,(a0)+
		addq.l	#8,d0

		move.w	d1,(a1)+
		add.w	d2,d1

		dbra	d6,DP_ifi_Loop4

		subi.w	#8,d1
		neg.w	d2

		addi.l	#511*80,d0

		dbra	d7,DP_ifi_Loop3

		rts


; -----------------------------------------------------------------------------
; Procedure:	DP_FadeIn
; Function:	FadeIn effect
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

DP_FadeIn
		move.l	DP_FadeInAddr,a1
		move.l	DP_FadeInCntr,a2

DP_fi_Loop1
		move.w	#3,d0
		jsr	Wait

		moveq	#0,d7
DP_fi_Loop0
		move.w	(a2,d7.w*2),d1
		bmi.b	DP_fi0

		cmpi.w	#18,d1
		beq.b	DP_fi1

		move.l	(a1,d7.w*4),d0
		bsr.b	DP_FadeInOne

DP_fi0		addq.w	#1,(a2,d7.w*2)

DP_fi1
		addq.w	#1,d7
		cmpi.w	#80,d7
		blt.b	DP_fi_Loop0

		cmp.w	#18,79*2(a2)
		bne.b	DP_fi_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	DP_FadeInOne
; Function:	FadeIn one segment
; In:
;	d0.l	offset on picture (and plane)
;	d1.w	fase number (0-17)
; Out:
;	none
; Crash regs:
;	d2/d3/d4/a0/a5
; -----------------------------------------------------------------------------

DP_FadeInOne	move.l	DP_FadeInOffset,a0
		move.l	(a0,d1.w*4),a0

DP_fio_Loop0
		move.l	(a0)+,d2
		beq.b	DP_fio0

		add.l	d0,d2
		move.l	(a0)+,d3
		add.l	d0,d3
		move.w	(a0),d4
		addq.w	#4,a0

		lea	CUSTOM,a5

		WaitBlitter

		move.l	d2,bltapt(a5)
		move.l	d3,bltdpt(a5)
		move.l	#$09f00000,bltcon0(a5)
		move.l	#$ffffffff,bltafwm(a5)
		move.w	#72,bltamod(a5)
		move.w	#72,bltdmod(a5)
		move.w	d4,bltsize(a5)


		bra.b	DP_fio_Loop0
DP_fio0

		rts


; -----------------------------------------------------------------------------
; Procedure:	DP_InitLineTable
; Function:	Initialize LineAddress
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

DP_InitLineTable
		move.l	DP_LineAddress,a0
		move.l	DP_PlanesDisplay,a1
		move.w	#DP_HEIGHT-1,d7

DP_ilt_Loop	move.l	a1,(a0)+
		lea	DP_WIDTH_B*DP_DEPTH(a1),a1
		dbra	d7,DP_ilt_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	DP_ShowText
; Function:	Show text: The Multimediality Virtual ...
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

DP_ShowText
		move.w	#$83e0,dmacon+CUSTOM

		lea	CUSTOM+vposr,a5
		move.l	DP_SPalette1,a0
		move.l	DP_SPalette2,a1
		moveq	#0,d0
		moveq	#15,d7

DP_st_Loop0	move.w	d0,2(a0)
		move.w	d0,2(a1)
		move.w	d0,6(a0)
		move.w	d0,6(a1)
		move.w	d0,10(a0)
		move.w	d0,10(a1)
		move.w	d0,14(a0)
		move.w	d0,14(a1)

		add.w	#$0111,d0

		moveq	#2,d6
DP_st_Loop1
DP_st_wait0	move.l	(a5),d1
		andi.l	#$0001ff00,d1
		cmpi.l	#$00012d00,d1
		bne.b	DP_st_wait0

DP_st_wait1	move.l	(a5),d1
		andi.l	#$0001ff00,d1
		cmpi.l	#$00012d00,d1
		beq.b	DP_st_wait1

		dbra	d6,DP_st_Loop1
		dbra	d7,DP_st_Loop0

		rts


; -----------------------------------------------------------------------------
; Procedure:	DP_DoomFade
; Function:	Fade like doom
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

DP_DoomFade

DP_df_Loop3	move.l	DP_FSpeedBuffer,a0
		move.l	DP_FVPosBuffer,a1
		move.l	DP_LineAddress,a2
		moveq	#0,d4
		moveq	#-128,d5
		moveq	#0,d6
		move.w	#DP_WIDTH-1,d7

DP_df_Loop1	move.w	(a0)+,d0
		move.w	(a1)+,d1
		cmpi.w	#DP_HEIGHT,d1
		beq.b	DP_df0
		moveq	#1,d6
		move.l	(a2,d1.w*4),a3

		lsr.w	#8,d0
		move.w	d0,d2
		add.w	d1,d2
		cmpi.w	#DP_HEIGHT,d2
		blt.b	DP_df2
		move.w	#DP_HEIGHT,d2
DP_df2		move.w	d2,-2(a1)
		sub.w	d1,d2

		add.w	d0,d0
		addq.w	#1,d0
		add.w	d0,-2(a0)

		subq.w	#1,d2
		bmi.b	DP_df0

		lea	(a3,d4.w),a3

DP_df_Loop2	or.b	d5,(a3)
		or.b	d5,DP_WIDTH_B(a3)
		or.b	d5,2*DP_WIDTH_B(a3)
		or.b	d5,3*DP_WIDTH_B(a3)
		or.b	d5,4*DP_WIDTH_B(a3)
		or.b	d5,5*DP_WIDTH_B(a3)
		or.b	d5,6*DP_WIDTH_B(a3)
		or.b	d5,7*DP_WIDTH_B(a3)

		lea	DP_WIDTH_B*8(a3),a3
		dbra	d2,DP_df_Loop2
		bra.b	DP_df4

DP_df0		moveq	#25,d2
DP_df_Loop0	nop
		dbra	d2,DP_df_Loop0

DP_df4		ror.b	d5
		bpl.b	DP_df1
		addq.w	#1,d4
DP_df1		dbra	d7,DP_df_Loop1

		tst.b	d6
		bne.w	DP_df_Loop3

DP_df3		rts


; -----------------------------------------------------------------------------
; Special data
; -----------------------------------------------------------------------------

DP_MemEntry	DCB.B	14
		DC.W	6
	DC.L	MEMF_CHIP,(8*8+8*8+434*4+9*4)*2			; CopperList
	DC.L	MEMF_PUBLIC+MEMF_CLEAR,DP_WIDTH*2		; FVPosBuffer
	DC.L	MEMF_PUBLIC,DP_HEIGHT*4				; LineAddress
 DC.L	MEMF_CHIP+MEMF_CLEAR,DP_WIDTH_B*DP_HEIGHT*DP_DEPTH	; PlanesDiplay
	DC.L	MEMF_PUBLIC,80*4				; FadeInAddr
	DC.L	MEMF_PUBLIC,80*2				; FadeInCntr

DP_MemEntryPtr	DC.L	0


DP_CopperList1	DC.L	0
DP_CopperList2	DC.L	0
DP_Sprite	DC.L	0
DP_PlanesDisplay	DC.L	0
DP_Picture	DC.L	0
DP_Palette	DC.L	0
DP_SPalette1	DC.L	0
DP_SPalette2	DC.L	0
DP_FSpeedBuffer	DC.L	0
DP_FVPosBuffer	DC.L	0
DP_LineAddress	DC.L	0
DP_FadeInOffset	DC.L	0
DP_FadeInTable	DC.L	0
DP_FadeInAddr	DC.L	0
DP_FadeInCntr	DC.L	0
DP_BackColor1	DC.L	0
DP_BackColor2	DC.L	0

; -----------------------------------------------------------------------------

; =============================================================================

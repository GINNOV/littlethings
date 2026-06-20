; =============================================================================
; -----------------------------------------------------------------------------
; File:		TunnelLogo_xx.s
; Contents:	Next part of demo (Logo for tunnel)
; Author:	Jacek (Noe) Cybularczyk / Venus Art
; Copyright:	©1994/1995 by Noe
; -----------------------------------------------------------------------------
; History:
; -----------------------------------------------------------------------------
; 23.08.1995	no history, only reallity
; -----------------------------------------------------------------------------
; =============================================================================

TL_WIDTH	=	640
TL_WIDTH2	=	TL_WIDTH>>1
TL_WIDTH_B	=	TL_WIDTH>>3
TL_WIDTH_W	=	TL_WIDTH>>4
TL_HEIGHT	=	256
TL_HEIGHT2	=	TL_HEIGHT>>1
TL_PLANE_SIZE	=	TL_WIDTH_B*TL_HEIGHT
TL_DEPTH	=	3

; =============================================================================

		SECTION	TunnelLogo_0,CODE

TunnelLogo
		move.l	(a0),a0
		addq.w	#MAGIC_NUMBER,a0
		move.l	a0,TL_Palette
		lea	32(a0),a0
		move.l	a0,TL_Picture

		bsr.w	TL_InitScreen

		bsr.w	TL_FadeIn

		rts

TunnelLogoOut
		bsr.w	TL_FadeOut

		moveq	#0,d0
		rts


; -----------------------------------------------------------------------------
; Procedure:	TL_InitScreen
; Function:	Initialize planes and copper list
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TL_InitScreen	movem.l	d0-d7/a0-a6,-(sp)

		lea	CUSTOM,a5

		move.w	#$71e0,dmacon(a5)

		move.w	#$2a81,diwstrt(a5)
		move.w	#$2ac1,diwstop(a5)
		move.w	#$2100,diwhigh(a5)

		move.w	#$0038,ddfstrt(a5)
		move.w	#$00d0,ddfstop(a5)

		move.w	#-8+TL_WIDTH_B*2,bpl1mod(a5)
		move.w	#-8+TL_WIDTH_B*2,bpl2mod(a5)

		move.l	#$b2010000,bplcon0(a5)
		move.l	#$00000080,bplcon2(a5)
		move.w	#$0000,bplcon4(a5)

		move.w	#$0003,fmode(a5)

		lea	TL_CopperList,a0

		move.l	TL_Picture,d0
		moveq	#TL_DEPTH-1,d7
		moveq	#TL_WIDTH_B,d1
		jsr	SetCopperBplPtrs

		move.l	#-2,(a0)+

		move.w	#$83c0,dmacon(a5)

		move.l	#TL_CopperList,cop1lc(a5)
		move.w	#0,copjmp1(a5)

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	TL_FadeIn
; Function:	Fade picture in
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TL_FadeIn
		move.w	#127,d7
TL_fi_Loop0
		move.l	TL_Palette,a0
		lea	TL_TmpPalette,a1

		move.w	#128,d5
		sub.w	d7,d5
		add.w	d5,d5
		moveq	#7,d6
TL_fi_Loop1
		move.l	(a0)+,d0

		moveq	#0,d1
		move.b	d0,d1
		mulu	d5,d1
		lsr.w	#8,d1
		move.b	d1,d0
		ror.l	#8,d0

		moveq	#0,d1
		move.b	d0,d1
		mulu	d5,d1
		lsr.w	#8,d1
		move.b	d1,d0
		ror.l	#8,d0

		moveq	#0,d1
		move.b	d0,d1
		mulu	d5,d1
		lsr.w	#8,d1
		move.b	d1,d0
		ror.l	#8,d0
		ror.l	#8,d0

		move.l	d0,(a1)+

		dbra	d6,TL_fi_Loop1

		move.w	d7,-(sp)

		lea	TL_TmpPalette,a0
		moveq	#7,d7
		jsr	SetPalette

		moveq	#0,d0
		jsr	Wait

		move.w	(sp)+,d7

		dbra	d7,TL_fi_Loop0

		rts


; -----------------------------------------------------------------------------
; Procedure:	TL_FadeOut
; Function:	Fade picture out
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TL_FadeOut
		move.w	#127,d7
TL_fo_Loop0
		move.l	TL_Palette,a0
		lea	TL_TmpPalette,a1

		move.w	d7,d5
		add.w	d5,d5
		moveq	#7,d6
TL_fo_Loop1
		move.l	(a0)+,d0

		moveq	#0,d1
		move.b	d0,d1
		mulu	d5,d1
		lsr.w	#8,d1
		move.b	d1,d0
		ror.l	#8,d0

		moveq	#0,d1
		move.b	d0,d1
		mulu	d5,d1
		lsr.w	#8,d1
		move.b	d1,d0
		ror.l	#8,d0

		moveq	#0,d1
		move.b	d0,d1
		mulu	d5,d1
		lsr.w	#8,d1
		move.b	d1,d0
		ror.l	#8,d0
		ror.l	#8,d0

		move.l	d0,(a1)+

		dbra	d6,TL_fo_Loop1

		move.w	d7,-(sp)

		lea	TL_TmpPalette,a0
		moveq	#7,d7
		jsr	SetPalette

		moveq	#0,d0
		jsr	Wait

		move.w	(sp)+,d7

		dbra	d7,TL_fo_Loop0

		rts


; -----------------------------------------------------------------------------
; Special data
; -----------------------------------------------------------------------------

TL_Picture	DC.L	0
TL_Palette	DC.L	0

		section	xxx,data_c

TL_CopperList	DCB.L	7
TL_TmpPalette	DCB.L	8

; -----------------------------------------------------------------------------

; =============================================================================

; =============================================================================
; -----------------------------------------------------------------------------
; File:		Greetz_xx.s
; Contents:	Next part of demo (Greetings)
; Author:	Jacek (Noe) Cybularczyk / Venus Art
; Copyright:	©1995 by Noe, licenced by B.J.Sebo / Venus Art
; -----------------------------------------------------------------------------
; History:
; -----------------------------------------------------------------------------
; 23.08.1995	Bassed on creditz.s by B.J.Sebo

; -----------------------------------------------------------------------------
; =============================================================================

; =============================================================================

		SECTION	Greetz_0,code
Greetz
		move.l	(a0)+,a1
		adda.w	#MAGIC_NUMBER,a1
		move.l	a1,GRE_Palette
		adda.w	#512,a1
		move.l	a1,GRE_Text0
		adda.w	#4096,a1
		move.l	a1,GRE_Text1
		adda.w	#4096,a1
		move.l	a1,GRE_Text2
		adda.w	#4096,a1
		move.l	a1,GRE_Text3
		adda.w	#4096,a1
		move.l	a1,GRE_Text4

		AllocMemBlocks	GRE_MemEntry
		bne.w	GRE_AllocMemError
		move.l	d0,GRE_MemEntryPtr

		bsr.w	GRE_SetMemPtrs

		move.l	#Chunky,GRE_Chunky
		jsr	ClearChunky
		jsr	ChunkyOn


		move.l	GRE_Text0,a0
		bsr.w	GRE_CopyText
		jsr	ChunkyToCopper

		move.w	#160,d0
		jsr	Wait

		moveq	#20,d0
		bsr.w	GRE_FadeOut

		move.l	GRE_Text1,a0
		bsr.w	GRE_CopyText
		jsr	ChunkyToCopper

		move.w	#160,d0
		jsr	Wait

		moveq	#13,d0
		bsr.w	GRE_FadeOut

		move.l	GRE_Text2,a0
		bsr.w	GRE_CopyText
		jsr	ChunkyToCopper

		move.w	#160,d0
		jsr	Wait

		moveq	#20,d0
		bsr.w	GRE_FadeOut

		move.l	GRE_Text3,a0
		bsr.w	GRE_CopyText
		jsr	ChunkyToCopper

		move.w	#160,d0
		jsr	Wait

		moveq	#13,d0
		bsr.w	GRE_FadeOut

		move.l	GRE_Text4,a0
		bsr.w	GRE_CopyText
		jsr	ChunkyToCopper

		move.w	#160,d0
		jsr	Wait

		moveq	#25,d0
		bsr.w	GRE_FadeOut


GRE_Stop
		jsr	ChunkyOff

		FreeMemBlocks	GRE_MemEntryPtr
GRE_AllocMemError
		moveq	#0,d0
		rts


; ===========================================================================
; Procedure:	GRE_SetmemPtrs
; Function:	Set pointers to allocated memory blocks
; In:
;	none
; Out:
;	none
; Crash regs:
;	a0
; ===========================================================================

GRE_SetMemPtrs
		move.l	GRE_MemEntryPtr,a0
		lea	14+2(a0),a0

		move.l	(a0),GRE_Chunky1
		move.l	8(a0),GRE_Chunky2

		rts


; ===========================================================================
; Procedure:	GRE_CopyChunky
; Function:	Copy chunky buffer to chunky on copper buffer
; In:
;	none
; Out:
;	none
; Crash regs:
;	a0
; ===========================================================================

GRE_CopyChunky
		move.l	GRE_Chunky1,a0
		move.l	GRE_Chunky,a1
		lea	2*(11*107+21)(a1),a1
		move.l	GRE_Palette,a2

		moveq	#0,d0

		moveq	#64-1,d7
GRE_cc_Loop0
		moveq	#64-1,d6
GRE_cc_Loop1
		move.b	(a0)+,d0
		move.w	(a2,d0.w*2),(a1)+

		dbra	d6,GRE_cc_Loop1

		lea	43*2(a1),a1

		dbra	d7,GRE_cc_Loop0

		rts


; ===========================================================================
; Procedure:	GRE_CopyText
; Function:	Copy text to chunky
; In:
;	a0.l	pointer to text
; Out:
;	none
; Crash regs:
;	a0
; ===========================================================================

GRE_CopyText
		move.l	GRE_Chunky1,a1

		move.w	#64*64-1,d7
GRE_ct_Loop0
		move.b	(a0)+,d0
		beq.b	GRE_ct0
		move.b	d0,(a1)
GRE_ct0
		addq.w	#1,a1

		dbra	d7,GRE_ct_Loop0

		bsr.w	GRE_CopyChunky

		rts


; ===========================================================================
; Procedure:	GRE_MakeBlur
; Function:	Make blur on chunky
; In:
;	none
; Out:
;	none
; Crash regs:
;	a0
; ===========================================================================

GRE_MakeBlur
		move.l	GRE_Chunky1,a0
		move.l	GRE_Chunky2,a1

		moveq	#0,d0
		moveq	#64/4-1,d7
GRE_Loop2
		move.l	d0,63*64(a1)
		move.l	d0,(a1)+

		dbra	d7,GRE_Loop2

		moveq	#64-2-1,d7
GRE_mb_Loop0
		move.b	#0,(a1)+

		moveq	#64-2-1,d6
GRE_mb_Loop1
		move.b	(a0)+,d0
		add.b	1-1(a0),d0
		add.b	2-1(a0),d0
		add.b	64-1(a0),d0
		add.b	66-1(a0),d0
		add.b	128-1(a0),d0
		add.b	129-1(a0),d0
		add.b	130-1(a0),d0

		lsr.w	#3,d0
		move.b	d0,(a1)+

		dbra	d6,GRE_mb_Loop1

		move.b	#0,(a1)+

		addq.w	#2,a0

		dbra	d7,GRE_mb_Loop0

		rts


; ===========================================================================
; Procedure:	GRE_FadeOut
; Function:	Make fade out
; In:
;	d0.w	numbers of blur phases
; Out:
;	none
; Crash regs:
;	a0
; ===========================================================================

GRE_FadeOut
GRE_fo_Loop
		move.w	d0,-(sp)

		bsr.w	GRE_MakeBlur
		move.l	GRE_Chunky1,d0
		move.l	GRE_Chunky2,d1
		move.l	d0,GRE_Chunky2
		move.l	d1,GRE_Chunky1

		bsr.w	GRE_MakeBlur
		move.l	GRE_Chunky1,d0
		move.l	GRE_Chunky2,d1
		move.l	d0,GRE_Chunky2
		move.l	d1,GRE_Chunky1

		bsr.w	GRE_CopyChunky
		jsr	ChunkyToCopper

		moveq	#0,d0
		jsr	Wait

		move.w	(sp)+,d0

		dbra	d0,GRE_fo_Loop

		rts


; ---------------------------------------------------------------------------

GRE_MemEntry	DCB.B	14
		DC.W	2
	DC.L	MEMF_PUBLIC|MEMF_CLEAR,64*64			; Chunky1
	DC.L	MEMF_PUBLIC|MEMF_CLEAR,64*64			; Chunky2

GRE_MemEntryPtr	DC.L	0

GRE_Chunky	DC.L	0
GRE_Chunky1	DC.L	0
GRE_Chunky2	DC.L	0
GRE_Palette	DC.L	0
GRE_Text0	DC.L	0
GRE_Text1	DC.L	0
GRE_Text2	DC.L	0
GRE_Text3	DC.L	0
GRE_Text4	DC.L	0

; ---------------------------------------------------------------------------

		INCLUDE	"ChunkyCopper/ChunkyCopper_107x86_dither.s


; ---------------------------------------------------------------------------

; ===========================================================================

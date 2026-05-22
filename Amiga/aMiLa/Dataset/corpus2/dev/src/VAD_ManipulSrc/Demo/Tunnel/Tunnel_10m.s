; =============================================================================
; -----------------------------------------------------------------------------
; File:		Tunnel_xx.s
; Contents:	Next part of demo (Tunnel)
; Author:	Jacek (Noe) Cybularczyk / Venus Art
; Copyright:	©1995 by Noe
; -----------------------------------------------------------------------------
; History:
; -----------------------------------------------------------------------------
; 24.07.1995	Bassed on Part5_05.s
; 26.07.1995	it look funny ??? and stuff from B.J.Sebo
; 27.07.1995	it's work !!!
; -----------------------------------------------------------------------------
; =============================================================================

TUN_TEXTURE_WIDTH	=	256
TUN_TEXTURE_WIDTH_W	=	TUN_TEXTURE_WIDTH<<1
TUN_TEXTURE_HEIGHT	=	256-1

; =============================================================================

		SECTION	Tunnel_0,code
Tunnel
		move.l	(a0),a0
		addq.w	#MAGIC_NUMBER,a0
		move.l	a0,TUN_Texture
		add.l	#131072,a0
		move.l	a0,TUN_CurveTable

		AllocMemBlocks	TUN_MemEntry
		bne.w	TUN_AllocMemError
		move.l	d0,TUN_MemEntryPtr

		bsr.w	TUN_SetMemPtrs

		bsr.w	TUN_InitSegments
		bsr.w	TUN_InitShadePalette
		bsr.w	TUN_InitTunnel
		bsr.w	TUN_InitPerspectiveTable

		move.l	#TUN_AChunky,TUN_Chunky
		jsr	TUN_ClearChunky
		jsr	TUN_ChunkyOn

		move.l	TUN_TunnelTable,a0
		move.l	TUN_FadeTable,a1

		move.w	#TUN_PERSPECTIVE_LEN-1,d7
TUN_Loop0
		move.l	t_Shade(a0),(a1)+
		move.l	TUN_ShadePalette,t_Shade(a0)
		lea	t_SIZEOF(a0),a0
		dbra	d7,TUN_Loop0

		move.l	TUN_Texture,TUN_TxtPtr
		add.l	#TUN_TEXTURE_WIDTH_W*128,TUN_TxtPtr
TUN_Loop1
		bsr.w	TUN_MakeWay
		move.l	TUN_TxtPtr,a4
		bsr.w	TUN_RenderTunnel
		bsr.w	TUN_KillBlackHoles
		jsr	TUN_ChunkyToCopper
		jsr	TUN_ClearChunky

		move.l	TUN_TxtPtr,a0
		adda.l	TUN_SPEED,a0
		adda.l	TUN_ROTATION,a0
		move.l	TUN_Texture,a1
		adda.l	#TUN_TEXTURE_WIDTH_W*TUN_TEXTURE_HEIGHT,a1
		cmpa.l	a1,a0
		ble.b	TUN_Skip1
		suba.l	#TUN_TEXTURE_WIDTH_W*TUN_TEXTURE_HEIGHT,a0
TUN_Skip1
		move.l	a0,TUN_TxtPtr

		bsr.w	TUN_FadeIn
		tst.b	d0
		bne.w	TUN_Loop1

		move.w	#100,TUN_RotCntr
		move.l	#2,TUN_ROTATION
TUN_MainLoop
		bsr.w	TUN_MakeWay
		move.l	TUN_TxtPtr,a4
		bsr.w	TUN_RenderTunnel
		bsr.w	TUN_KillBlackHoles
		jsr	TUN_ChunkyToCopper
		jsr	TUN_ClearChunky

		move.l	TUN_TxtPtr,a0
		adda.l	TUN_SPEED,a0
		adda.l	TUN_ROTATION,a0
		move.l	TUN_Texture,a1
		adda.l	#TUN_TEXTURE_WIDTH_W*TUN_TEXTURE_HEIGHT,a1
		cmpa.l	a1,a0
		ble.b	TUN_Skip0
		suba.l	#TUN_TEXTURE_WIDTH_W*TUN_TEXTURE_HEIGHT,a0
;		bra.b	TUN_Stop
TUN_Skip0
		move.l	a0,TUN_TxtPtr

		subq.w	#1,TUN_RotCntr
		bpl.b	TUN_Skip0a
		neg.l	TUN_ROTATION
		move.w	#100,TUN_RotCntr
TUN_Skip0a
		tst.w	SynchroCntr
		bne.w	TUN_MainLoop
TUN_Stop
TUN_Loop2
		bsr.w	TUN_MakeWay
		move.l	TUN_TxtPtr,a4
		bsr.w	TUN_RenderTunnel
		bsr.w	TUN_KillBlackHoles
		jsr	TUN_ChunkyToCopper
		jsr	TUN_ClearChunky

		move.l	TUN_TxtPtr,a0
		adda.l	TUN_SPEED,a0
		adda.l	TUN_ROTATION,a0
		move.l	TUN_Texture,a1
		adda.l	#TUN_TEXTURE_WIDTH_W*TUN_TEXTURE_HEIGHT,a1
		cmpa.l	a1,a0
		ble.b	TUN_Skip2
		suba.l	#TUN_TEXTURE_WIDTH_W*TUN_TEXTURE_HEIGHT,a0
TUN_Skip2
		move.l	a0,TUN_TxtPtr

		bsr.w	TUN_FadeOut
		tst.b	d0
		bne.w	TUN_Loop2

		jsr	TUN_ChunkyOff

		FreeMemBlocks	TUN_MemEntryPtr
TUN_AllocMemError
		moveq	#0,d0
		rts


; ===========================================================================
; Procedure:	TUN_SetmemPtrs
; Function:	Set pointers to allocated memory blocks
; In:
;	none
; Out:
;	none
; Crash regs:
;	a0
; ===========================================================================

TUN_SetMemPtrs
		move.l	TUN_MemEntryPtr,a0
		lea	14+2(a0),a0

		move.l	(a0),TUN_QuarterCircleBuffer
		move.l	8(a0),TUN_TunnelSegmentTable
		move.l	2*8(a0),TUN_Scaling
		move.l	3*8(a0),TUN_Segments
		move.l	4*8(a0),TUN_TunnelTable
		move.l	5*8(a0),TUN_ShadePalette
		move.l	6*8(a0),TUN_HWayTable
		move.l	7*8(a0),TUN_VWayTable
		move.l	8*8(a0),TUN_PerspectiveTable
		move.l	9*8(a0),TUN_FadeTable

		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_CalcQuarterCircle
; Function:	Calculate quarter of circle
; In:
;	d0.w	radius
; Out:
;	none
; -----------------------------------------------------------------------------

TUN_CalcQuarterCircle
		movem.l	d0-d7/a0-a6,-(sp)

		move.l	TUN_QuarterCircleBuffer,a0

		moveq	#0,d1
		moveq	#0,d2

TUN_cqc_Loop	move.w	d0,(a0)+
		move.w	d1,(a0)+

		move.w	d2,d3
		sub.w	d0,d3
		sub.w	d0,d3
		addq.w	#1,d3
		move.w	d3,d4
		bpl.b	TUN_cqc0
		neg.w	d4

TUN_cqc0	move.w	d2,d5
		sub.w	d1,d5
		sub.w	d1,d5
		addq.w	#1,d5
		move.w	d5,d6
		bpl.b	TUN_cqc1
		neg.w	d6

TUN_cqc1	move.w	d3,d7
		add.w	d5,d7
		sub.w	d2,d7
		move.w	d7,d2
		bpl.b	TUN_cqc2
		neg.w	d2

TUN_cqc2	cmp.w	d6,d4
		bgt.b	TUN_cqc3
		cmp.w	d2,d4
		bgt.b	TUN_cqc5
		move.w	d3,d2
		subq.w	#1,d0
		bra.b	TUN_cqc4

TUN_cqc3	cmp.w	d2,d6
		bgt.b	TUN_cqc5
		move.w	d5,d2
		subq.w	#1,d1
		bra.b	TUN_cqc4

TUN_cqc5	move.w	d7,d2
		subq.w	#1,d0
		subq.w	#1,d1

TUN_cqc4	tst.w	d0
		bpl.b	TUN_cqc_Loop

		move.w	#-1,(a0)

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_CalcCircle
; Function:	Calculate one circle
; In:
;	d0.w	radius
;	a0.l	pointer to buffer
; Out:
;	d2.w	number of points
; -----------------------------------------------------------------------------

TUN_CalcCircle	movem.l	d0/d1/d3-d7/a1-a6,-(sp)

		bsr.w	TUN_CalcQuarterCircle
		moveq	#0,d2
		move.l	TUN_QuarterCircleBuffer,a1

TUN_cc_Loop0	move.w	(a1)+,d0
		bmi.b	TUN_cc0
		move.w	(a1)+,d1
		add.b	#64,d0
		add.b	#64,d1
		move.b	d1,(a0)+
		move.b	d0,(a0)+
		addq.w	#1,d2
		bra.b	TUN_cc_Loop0

TUN_cc0		move.l	TUN_QuarterCircleBuffer,a1
		addq.w	#4,a1
TUN_cc_Loop1	move.w	(a1)+,d1
		bmi.b	TUN_cc1
		move.w	(a1)+,d0
		neg.w	d1
		add.b	#64,d0
		add.b	#64,d1
		move.b	d1,(a0)+
		move.b	d0,(a0)+
		addq.w	#1,d2
		bra.b	TUN_cc_Loop1

TUN_cc1		move.l	TUN_QuarterCircleBuffer,a1
		addq.w	#4,a1
TUN_cc_Loop2	move.w	(a1)+,d0
		bmi.b	TUN_cc2
		move.w	(a1)+,d1
		neg.w	d0
		neg.w	d1
		add.b	#64,d0
		add.b	#64,d1
		move.b	d1,(a0)+
		move.b	d0,(a0)+
		addq.w	#1,d2
		bra.b	TUN_cc_Loop2

TUN_cc2		move.l	TUN_QuarterCircleBuffer,a1
		addq.w	#4,a1
TUN_cc_Loop3	tst.w	4(a1)
		bmi.b	TUN_cc3
		move.w	(a1)+,d1
		move.w	(a1)+,d0
		neg.w	d0
		add.b	#64,d0
		add.b	#64,d1
		move.b	d1,(a0)+
		move.b	d0,(a0)+
		addq.w	#1,d2
		bra.b	TUN_cc_Loop3
TUN_cc3
		movem.l	(sp)+,d0/d1/d3-d7/a1-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_InitScaling
; Function:	Initialize scaling tables
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TUN_InitScaling	movem.l	d0-d7/a0-a6,-(sp)

		move.l	TUN_TunnelSegmentTable,a0
		move.l	TUN_Scaling,a1

		move.w	#TUN_SEGMENT_NUMBER-1,d7

TUN_isct_Loop0	move.l	a1,ts_Scale(a0)
		move.w	ts_Perimeter(a0),d5
		lea	ts_SIZEOF(a0),a0

		move.l	#TUN_TEXTURE_WIDTH,d0
		divu	d5,d0
		move.w	d0,d1
		swap	d0

		moveq	#0,d2
		moveq	#0,d3
		move.w	d5,d6
		subq.w	#1,d6

TUN_isct_Loop1	move.w	d2,(a1)
		add.w	d2,(a1)+

		add.w	d1,d2
		add.w	d0,d3
TUN_isct1	cmp.w	d5,d3
		blt.b	TUN_isct0
		sub.w	d5,d3
		addq.w	#1,d2
		bra.b	TUN_isct1
TUN_isct0	dbra	d6,TUN_isct_Loop1

		dbra	d7,TUN_isct_Loop0

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_InitSegments
; Function:	Initialize segments table
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TUN_InitSegments
		movem.l	d0-d7/a0-a6,-(sp)

		move.l	TUN_Segments,a0
		move.l	TUN_TunnelSegmentTable,a1

		moveq	#TUN_MIN_RADIUS,d0

TUN_ist_Loop	move.l	a0,ts_Segment(a1)
		bsr.w	TUN_CalcCircle
		subq.w	#1,d2
		move.w	d2,ts_Perimeter(a1)
		lea	ts_SIZEOF(a1),a1

		addq.w	#1,d0
		cmpi.w	#TUN_MAX_RADIUS,d0
		ble.b	TUN_ist_Loop

		bsr.w	TUN_InitScaling

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_InitShadePalette
; Function:	Initialize ShadePalette
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TUN_InitShadePalette
		move.l	TUN_ShadePalette,a0
		moveq	#1,d0

TUN_isp_Loop1	moveq	#0,d1

TUN_isp_Loop0	move.w	d1,d2
		andi.w	#$000f,d2
		mulu	d0,d2
		lsr.w	#4,d2

		move.w	d1,d3
		andi.w	#$00f0,d3
		mulu	d0,d3
		lsr.w	#4,d3
		andi.w	#$00f0,d3

		move.w	d1,d4
		andi.w	#$0f00,d4
		mulu	d0,d4
		lsr.w	#4,d4
		andi.w	#$0f00,d4

		or.w	d3,d2
		or.w	d4,d2
		move.w	d2,(a0)+

		addi.w	#1,d1
		cmpi.w	#4095,d1
		ble.b	TUN_isp_Loop0

		addq.w	#1,d0
		cmpi.w	#16,d0
		ble.b	TUN_isp_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_InitTunnel
; Function:	Initialize tunnel table
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TUN_InitTunnel
		move.l	TUN_TunnelTable,a0
		move.l	TUN_TunnelSegmentTable,a1

		move.w	#TUN_MIN_PERSP_LEN,d7
TUN_it_Loop0
		move.w	d7,d6
		addi.w	#TUN_OBSERVER_Z,d6
		move.l	#TUN_REAL_RADIUS*TUN_OBSERVER_Z,d5
		divs	d6,d5
		subi.w	#TUN_MIN_RADIUS,d5
		mulu	#ts_SIZEOF,d5
		move.l	ts_Segment(a1,d5.w),t_Segment(a0)
		move.l	ts_Scale(a1,d5.w),t_Scale(a0)
		move.w	ts_Perimeter(a1,d5.w),t_Perimeter(a0)

		move.w	d7,d6
		subi.w	#TUN_MAX_PERSP_LEN,d6
		move.w	d6,d5
		mulu	#TUN_TEXTURE_WIDTH_W,d6
		move.l	d6,t_Perspective(a0)

		subi.w	#TUN_MIN_PERSP_LEN,d5
		neg.w	d5
		mulu	#30,d5
		divu	#TUN_PERSPECTIVE_LEN,d5
		ext.l	d5
		cmpi.l	#15,d5
		ble.b	TUN_ipt0
		moveq	#15,d5
TUN_ipt0	lsl.l	#8,d5
		lsl.l	#5,d5
		add.l	TUN_ShadePalette,d5
		move.l	d5,t_Shade(a0)

		move.w	#0,t_PosY(a0)
		move.b	#0,t_PosX(a0)

		lea	t_SIZEOF(a0),a0

		subq.w	#1,d7
		cmpi.w	#TUN_MAX_PERSP_LEN,d7
		bge.b	TUN_it_Loop0

		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_InitPerspectiveTable
; Function:	Initialize PerspectiveTable
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TUN_InitPerspectiveTable

		move.l	TUN_PerspectiveTable,a0

		move.w	#1,d7
TUN_ipt_Loop0
		move.w	#0,d6
TUN_ipt_Loop1
		move.b	d6,d0
		ext.w	d0

		move.w	d7,d1
		add.w	#TUN_OBSERVER2_Z,d1
		muls	#TUN_OBSERVER2_Z,d0
		divs	d1,d0
		move.b	d0,(a0)+

		addq.b	#1,d6
		bne.b	TUN_ipt_Loop1

		addq.w	#1,d7
		cmpi.w	#TUN_PERSPECTIVE_LEN+1,d7
		blt.b	TUN_ipt_Loop0

		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_KillBlackHoles
; Function:	Kill black holes on the chunky
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TUN_KillBlackHoles
		move.l	TUN_Chunky,a0
		lea	21*256(a0),a0
		move.w	#86*128-1,d7
TUN_kbh_Loop
		move.w	(a0)+,d0
		bpl.b	TUN_kbh0
		move.w	d1,-2(a0)
		move.w	d1,d0
TUN_kbh0
		move.w	d0,d1
		dbra	d7,TUN_kbh_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_RenderTunnel
; Function:	Render full tunnel
; In:
;	a4.l	pointer to current first line in texture
; Out:
;	none
; -----------------------------------------------------------------------------

TUN_RenderTunnel
		movem.l	d0-d7/a0-a6,-(sp)

		move.l	TUN_TunnelTable,a0

		moveq	#0,d0
		move.w	t_PosY(a0),d0
		move.b	t_PosX(a0),d0

		addi.w	#(64-TUN_MIN_RADIUS)<<8,d0
		addi.b	#64-TUN_MIN_RADIUS,d0
		lsl.b	#1,d0
		move.l	TUN_Chunky,a1
		adda.w	d0,a1

		move.w	#$0000,d1

		moveq	#TUN_MIN_RADIUS*2-1,d7
TUN_rt_Loop2
		moveq	#TUN_MIN_RADIUS*2-1,d6
TUN_rt_Loop3
		move.w	d1,(a1)+

		dbra	d6,TUN_rt_Loop3

		adda.w	#(128-TUN_MIN_RADIUS*2)<<1,a1

		dbra	d7,TUN_rt_Loop2


		move.b	#0,t_Flag(a0)
		lea	t_SIZEOF(a0),a0

		move.l	-t_SIZEOF+t_Segment(a0),d2
		move.w	-t_SIZEOF+t_PosX(a0),d4

		move.w	#TUN_PERSPECTIVE_LEN-2,d7
TUN_rt_Loop4
		moveq	#0,d1
		move.l	t_Segment(a0),d3
		move.w	t_PosX(a0),d5
		cmp.l	d3,d2
		bne.b	TUN_rt1
		cmp.w	d5,d4
		bne.b	TUN_rt1
		moveq	#1,d1
TUN_rt1
		move.l	d3,d2
		move.w	d5,d4
		move.b	d1,t_Flag(a0)
		lea	t_SIZEOF(a0),a0
		dbra	d7,TUN_rt_Loop4

		moveq	#0,d5

		move.l	TUN_TunnelTable,a0
		move.l	TUN_Chunky,a5

		move.w	#TUN_PERSPECTIVE_LEN-1,d7
TUN_rt_Loop0
		tst.b	t_Flag(a0)
		bne.b	TUN_rt4

		move.w	t_PosY(a0),d1
		move.b	t_PosX(a0),d2

		move.l	t_Segment(a0),a1
		move.l	t_Scale(a0),a2
		move.l	t_Shade(a0),a3
		move.w	t_Perimeter(a0),d6

TUN_rt_Loop1
		move.w	(a1)+,d3
		move.w	(a2)+,d4

		add.w	d1,d3
		bmi.b	TUN_rt0
		add.b	d2,d3
		bmi.b	TUN_rt0

		lsl.b	#1,d3

		move.w	(a4,d4.w),d5
		move.w	(a3,d5.w*2),d0
		move.w	d0,(a5,d3.w)
		move.w	d0,2(a5,d3.w)
TUN_rt0
		dbra	d6,TUN_rt_Loop1
TUN_rt4
		lea	-512(a4),a4
		cmpa.l	TUN_Texture,a4
		bge.b	TUN_rt2
		adda.l	#TUN_TEXTURE_WIDTH_W*TUN_TEXTURE_HEIGHT,a4
TUN_rt2
		lea	t_SIZEOF(a0),a0

		dbra	d7,TUN_rt_Loop0

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_MakeWay
; Function:	Make way
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TUN_MakeWay
		move.w	TUN_HCurvePhase,d0
		move.l	TUN_HWayTable,a0
		bsr.w	TUN_CalcWay

		move.w	TUN_VCurvePhase,d0
		move.l	TUN_VWayTable,a0
		bsr.w	TUN_CalcWay

		move.l	TUN_TunnelTable,a0
		move.l	TUN_HWayTable,a1
		move.l	TUN_VWayTable,a2

		lea	TUN_PERSPECTIVE_LEN(a1),a1
		lea	TUN_PERSPECTIVE_LEN(a2),a2

		move.w	#TUN_PERSPECTIVE_LEN-1,d7

		tst.w	TUN_HCurveDir
		bmi.b	TUN_mw2
		tst.w	TUN_VCurveDir
		bmi.w	TUN_mw3
TUN_mw_Loop0
		move.b	-(a1),t_PosX(a0)
		move.b	-(a2),t_PosY(a0)

		lea	t_SIZEOF(a0),a0
		dbra	d7,TUN_mw_Loop0
TUN_mw4
		move.w	TUN_HCurvePhase,d0
		addq.w	#4,d0
		cmpi.w	#3*TUN_PERSPECTIVE_LEN,d0
		blt.b	TUN_mw0
		moveq	#0,d0
		neg.w	TUN_HCurveDir
TUN_mw0
		move.w	d0,TUN_HCurvePhase

		move.w	TUN_VCurvePhase,d0
		addq.w	#2,d0
		cmpi.w	#3*TUN_PERSPECTIVE_LEN,d0
		blt.b	TUN_mw1
		moveq	#0,d0
		neg.w	TUN_VCurveDir
TUN_mw1
		move.w	d0,TUN_VCurvePhase

		rts

TUN_mw2		tst.w	TUN_VCurveDir
		bmi.w	TUN_mw5
TUN_mw_Loop1
		move.b	-(a1),d0
		neg.b	d0
		move.b	d0,t_PosX(a0)
		move.b	-(a2),t_PosY(a0)

		lea	t_SIZEOF(a0),a0
		dbra	d7,TUN_mw_Loop1
		bra.b	TUN_mw4
TUN_mw5
TUN_mw_Loop2
		move.b	-(a1),d0
		neg.b	d0
		move.b	d0,t_PosX(a0)
		move.b	-(a2),d0
		neg.b	d0
		move.b	d0,t_PosY(a0)

		lea	t_SIZEOF(a0),a0
		dbra	d7,TUN_mw_Loop2
		bra.b	TUN_mw4
TUN_mw3
TUN_mw_Loop3
		move.b	-(a1),t_PosX(a0)
		move.b	-(a2),d0
		neg.b	d0
		move.b	d0,t_PosY(a0)

		lea	t_SIZEOF(a0),a0
		dbra	d7,TUN_mw_Loop3
		bra.w	TUN_mw4


; -----------------------------------------------------------------------------
; Procedure:	TUN_CalcWay
; Function:	Calculate way table
; In:
;	d0.w	curve phase (0 ÷ 3*TUN_PERSPECTIVE_LEN)
;	a0.l	pointer to way table
; Out:
;	none
; Crash regs:
;	d0-d2/d7/a0-a2
; -----------------------------------------------------------------------------

TUN_CalcWay
		move.l	TUN_PerspectiveTable,a2
		moveq	#0,d2
		move.w	#TUN_PERSPECTIVE_LEN-1,d1
		move.w	d1,d7

		sub.w	d0,d1
		bmi.b	TUN_cw0
TUN_cw_Loop0
		move.b	#0,(a0)+
		lea	256(a2),a2
		subq.w	#1,d7
		dbra	d1,TUN_cw_Loop0
		tst.w	d7
		bmi.b	TUN_cw1
TUN_cw0
		move.w	#3*TUN_PERSPECTIVE_LEN,d1
		sub.w	d0,d1
		move.l	TUN_CurveTable,a1
TUN_cw_Loop1
		move.b	(a1)+,d2
		move.b	(a2,d2.w),(a0)+
		lea	256(a2),a2
		subq.w	#1,d7
		bmi.b	TUN_cw1
		dbra	d1,TUN_cw_Loop1

		move.b	(a1),d2
TUN_cw_Loop2
		move.b	(a2,d2.w),(a0)+
		lea	256(a2),a2
		dbra	d7,TUN_cw_Loop2
TUN_cw1
		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_FadeIn
; Function:	Fade in tunnel
; In:
;	none
; Out:
;	d0.b	if end then 0
; Crash regs:
;	all
; -----------------------------------------------------------------------------

TUN_FadeIn
		move.l	TUN_FadeTable,a0
		move.l	TUN_TunnelTable,a1

		moveq	#0,d0
		move.w	#TUN_PERSPECTIVE_LEN-1,d7
TUN_fi_Loop
		move.l	t_Shade(a1),d1
		cmp.l	(a0)+,d1
		beq.b	TUN_fi0
		add.l	#4096*2,d1
		move.l	d1,t_Shade(a1)
		moveq	#1,d0
TUN_fi0
		lea	t_SIZEOF(a1),a1

		dbra	d7,TUN_fi_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	TUN_FadeOut
; Function:	Fade out tunnel
; In:
;	none
; Out:
;	d0.b	if end then 0
; Crash regs:
;	all
; -----------------------------------------------------------------------------

TUN_FadeOut
		move.l	TUN_TunnelTable,a0

		moveq	#0,d0
		move.w	#TUN_PERSPECTIVE_LEN-1,d7
TUN_fo_Loop
		move.l	t_Shade(a0),d1
		cmp.l	TUN_ShadePalette,d1
		beq.b	TUN_fo0
		sub.l	#4096*2,d1
		move.l	d1,t_Shade(a0)
		moveq	#1,d0
TUN_fo0
		lea	t_SIZEOF(a0),a0

		dbra	d7,TUN_fo_Loop

		rts


; ---------------------------------------------------------------------------

TUN_SPEED	DC.L	512*4
TUN_ROTATION	DC.L	0
TUN_TxtPtr	DC.L	0
TUN_RotCntr	DC.L	0

TUNNEL_SEGMENT	RSRESET
ts_Segment	RS.L	1
ts_Scale	RS.L	1
ts_Perimeter	RS.W	1
ts_SIZEOF	RS.B	0

TUNNEL		RSRESET
t_Segment	RS.L	1
t_Scale		RS.L	1
t_Perimeter	RS.W	1
t_Flag		RS.B	1
t_PosX		RS.B	1
t_PosY		RS.W	1
t_Shade		RS.L	1
t_Perspective	RS.L	1
t_SIZEOF	RS.B	0

; ---------------------------------------------------------------------------

TUN_MemEntry	DCB.B	14
		DC.W	10
	DC.L	MEMF_PUBLIC,256*4			; QuarterCircleBuffer
	DC.L	MEMF_PUBLIC,ts_SIZEOF*TUN_SEGMENT_NUMBER	; TunnelSegmentTable
	DC.L	MEMF_PUBLIC,65536*2			; Scaling
	DC.L	MEMF_PUBLIC,65536*2			; Segments
	DC.L	MEMF_PUBLIC,t_SIZEOF*TUN_PERSPECTIVE_LEN	; TunnelTable
	DC.L	MEMF_PUBLIC,4096*2*16			; ShadePalette
	DC.L	MEMF_PUBLIC,TUN_PERSPECTIVE_LEN		; HWay
	DC.L	MEMF_PUBLIC,TUN_PERSPECTIVE_LEN		; VWay
	DC.L	MEMF_PUBLIC,TUN_PERSPECTIVE_LEN*256	; Perspective
	DC.L	MEMF_PUBLIC,TUN_PERSPECTIVE_LEN*4	; FadeTable

TUN_MemEntryPtr	DC.L	0

TUN_QuarterCircleBuffer
		DC.L	0
TUN_TunnelSegmentTable
		DC.L	0
TUN_Scaling	DC.L	0
TUN_Segments	DC.L	0
TUN_TunnelTable	DC.L	0
TUN_ShadePalette
		DC.L	0
TUN_CurveTable	DC.L	0
TUN_Texture	DC.L	0
TUN_HWayTable	DC.L	0
TUN_VWayTable	DC.L	0
TUN_PerspectiveTable
		DC.L	0
TUN_Chunky	DC.L	0
TUN_FadeTable	DC.L	0

TUN_HCurvePhase	DC.W	0
TUN_VCurvePhase	DC.W	0
TUN_HCurveDir	DC.W	1
TUN_VCurveDir	DC.W	-1

; ---------------------------------------------------------------------------

		INCLUDE	"Tunnel/TChunkyCopper_107x86_dither.s

TCC_WIDTH2	=	TCC_WIDTH>>1
TCC_HEIGHT2	=	TCC_HEIGHT>>1
TCC_WIDTH_W	=	TCC_WIDTH<<1

TUN_MIN_RADIUS	=	10
TUN_MAX_RADIUS	=	71-2
TUN_SEGMENT_NUMBER	=	TUN_MAX_RADIUS-TUN_MIN_RADIUS+1
TUN_REAL_RADIUS	=	80

TUN_OBSERVER_Z	=	20
TUN_OBSERVER2_Z	=	1000

TUN_MAX_PERSP_LEN	=	TUN_REAL_RADIUS*TUN_OBSERVER_Z/TUN_MAX_RADIUS-TUN_OBSERVER_Z
TUN_MIN_PERSP_LEN	=	TUN_REAL_RADIUS*TUN_OBSERVER_Z/TUN_MIN_RADIUS-TUN_OBSERVER_Z
TUN_PERSPECTIVE_LEN	=	TUN_MIN_PERSP_LEN-TUN_MAX_PERSP_LEN+1

; ---------------------------------------------------------------------------

; ===========================================================================

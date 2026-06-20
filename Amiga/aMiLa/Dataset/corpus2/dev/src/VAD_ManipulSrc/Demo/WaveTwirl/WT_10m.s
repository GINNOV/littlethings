; ===========================================================================
; Name:		Wave and twirl
; File:		WT_xx.s
; Author:	Noe / Venus Art
; Copyright:	© 1995 by Venus Art
; ---------------------------------------------------------------------------
; History:
; 20.08.1995	Based on my and Sebo's sources
; 21.08.1995	by night: make wave
; 22.08.1995	make twirl and pixelize
; 23.08.1995	
; ===========================================================================

WT_HOFFSET	=	$81
WT_VOFFSET	=	$2c
WT_WIDTH	=	320
WT_HEIGHT	=	256
WT_DEPTH	=	8

WT_WIDTH_B	=	WT_WIDTH>>3
WT_WIDTH_W	=	WT_WIDTH>>4

WT_WIDTH2	=	WT_WIDTH>>1
WT_HEIGHT2	=	WT_HEIGHT>>1

WT_PLANE_SIZE	=	WT_WIDTH_B*WT_HEIGHT

WT_WWIDTH	=	160
WT_WHEIGHT	=	160
WT_WWIDTH2	=	WT_WWIDTH>>1
WT_WHEIGHT2	=	WT_WHEIGHT>>1
WT_WWIDTH_B	=	WT_WWIDTH>>3
WT_WWIDTH_W	=	WT_WWIDTH>>4

WT_MWIDTH	=	256
WT_MHEIGHT	=	256

WT_OBSERVER_Z	=	200
WT_SPEED	=	10

WT_WAVE_LEN	=	63

; ---------------------------------------------------------------------------

		SECTION	WaveTwirl_0,CODE

WaveTwirl
		move.l	(a0)+,a1
		adda.w	#MAGIC_NUMBER,a1
		move.l	a1,WT_Palette
		adda.w	#1024,a1
		move.l	a1,WT_LechPalette
		adda.w	#1024,a1
		move.l	a1,WT_MilekPalette
		adda.w	#1024,a1
		move.l	a1,WT_LenMap
		adda.w	#25600,a1
		move.l	a1,WT_TmpWave
		adda.w	#63,a1
		move.l	a1,WT_Lech
		adda.w	#25600,a1
		move.l	a1,WT_Milek
		adda.w	#25600,a1
		move.l	a1,WT_RotXTable
		adda.l	#288000,a1
		move.l	a1,WT_RotYTable
		move.l	(a0)+,a1
		adda.w	#MAGIC_NUMBER,a1
		move.l	a1,WT_PlanesDisplay
		adda.l	#81920,a1
		move.l	a1,WT_Clip
		adda.w	#5184,a1
		move.l	a1,WT_Mask

		move.l	#WT_EmptyCL,cop1lc+CUSTOM
		move.w	d0,copjmp1+CUSTOM

		suba.l	a0,a0
		move.w	#256-1,d7
		jsr	SetPalette

		AllocMemBlocks	WT_MemEntry
		bne.w	WT_AllocMemError
		move.l	d0,WT_MemEntryPtr

		bsr.w	WT_SetMemPtrs

	IFEQ	DEBUG

		lea	CUSTOM,a5

		move.w	#$71f0,dmacon(a5)
		move.w	#$83c0,dmacon(a5)

	ENDC

		move.l	WT_Palette,a0
		lea	64*4(a0),a0
		move.l	WT_LechPalette,a1
		move.w	#192-1,d7
WT_Loop1
		move.l	(a1)+,(a0)+
		dbra	d7,WT_Loop1

		bsr.w	WT_InitView

		bsr.w	WT_InitTextures

		move.l	WT_Chunky,a0
		move.l	WT_PlanesRender,a1
		lea	16+WT_WIDTH_B*29*8(a1),a1
		bsr.w	WT_ChunkyToPlanar

		bsr.w	WT_CopyMask
		WaitBlitter

		bsr.w	WT_SwitchView

		moveq	#10,d0
		jsr	Wait

		moveq	#0,d5
		moveq	#15,d6
WT_Loop0
		move.w	d6,-(sp)
		move.l	WT_Palette,a0
		move.w	#1<<WT_DEPTH-1,d7
		bsr.w	WT_FadePhase

		moveq	#3,d0
		jsr	Wait

		move.w	(sp)+,d6

		addq.w	#1,d5
		dbra	d6,WT_Loop0

		bsr.w	WT_MakePixelizeTable
		bsr.w	WT_WaveSection

		bsr.w	WT_TwirlSection

WT_End
		FreeMemBlocks	WT_MemEntryPtr
WT_AllocMemError

		moveq	#0,d0
		rts


; ===========================================================================
; Procedure:	WT_SetmemPtrs
; Function:	Set pointers to allocated memory blocks
; In:
;	none
; Out:
;	none
; Crash regs:
;	a0
; ===========================================================================

WT_SetMemPtrs
		move.l	WT_MemEntryPtr,a0
		lea	14+2(a0),a0

		move.l	(a0),WT_CopperList
		move.l	1*8(a0),WT_PlanesRender
		move.l	2*8(a0),WT_Chunky
		move.l	3*8(a0),WT_Chunky2
		move.l	4*8(a0),WT_PerspTableH
		move.l	5*8(a0),WT_PerspTableV
		move.l	6*8(a0),WT_Wave
		move.l	7*8(a0),WT_PixelizeTable
		move.l	8*8(a0),WT_LenMap2
		move.l	9*8(a0),WT_Milek2
		move.l	10*8(a0),WT_AngleTableTmp
		move.l	11*8(a0),WT_SpeedTable

		rts


; ===========================================================================
; Procedure:	WT_InitView
; Function:	Initialize view
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

WT_InitView
		lea	CUSTOM,a5

		WaitBlitter
		move.l	WT_PlanesDisplay,bltapt(a5)
		move.l	WT_PlanesRender,bltdpt(a5)
		move.l	#$09f00000,bltcon0(a5)
		move.l	#$ffffffff,bltafwm(a5)
		move.w	#0,bltamod(a5)
		move.w	#0,bltdmod(a5)
		move.w	#WT_HEIGHT*8,bltsizv(a5)
		move.w	#WT_WIDTH_W,bltsizh(a5)
		WaitBlitter

		move.l	#$02110000,bplcon0(a5)
		move.w	#$0000,bplcon2(a5)
		move.w	#$0000,bplcon4(a5)

		move.w	#WT_WIDTH_B*7-8,bpl1mod(a5)
		move.w	#WT_WIDTH_B*7-8,bpl2mod(a5)

		move.w	#3,fmode(a5)

		SetView	WT_HOFFSET,WT_VOFFSET,WT_WIDTH,WT_HEIGHT,LORES

		move.l	WT_CopperList,a0

		move.l	a0,WT_CopperDisplay

		move.l	WT_PlanesDisplay,d0	; first CL
		moveq	#WT_DEPTH-1,d7
		moveq	#WT_WIDTH_B,d1
		jsr	SetCopperBplPtrs

		move.l	#-2,(a0)+		; end of first CL

		move.l	a0,WT_CopperRender

		move.l	WT_PlanesRender,d0	; second CL
		moveq	#WT_DEPTH-1,d7
		moveq	#WT_WIDTH_B,d1
		jsr	SetCopperBplPtrs

		move.l	#-2,(a0)		; end of second CL

		move.w	#$0020,bplcon3(a5)
		move.w	#$0000,color(a5)

		move.l	WT_CopperDisplay,cop1lc(a5)
		move.w	d0,copjmp1(a5)

		rts


; ===========================================================================
; Procedure:	WT_SwitchView
; Function:	Switch view display and render
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

WT_SwitchView
		lea	CUSTOM,a5

		move.l	WT_PlanesDisplay,a0
		move.l	WT_PlanesRender,a1
		move.l	a0,WT_PlanesRender
		move.l	a1,WT_PlanesDisplay

		move.l	WT_CopperDisplay,a0
		move.l	WT_CopperRender,a1
		move.l	a0,WT_CopperRender
		move.l	a1,WT_CopperDisplay

WT_sv_wait	move.l	vposr(a5),d0
		andi.l	#$0001ff00,d0
		cmpi.l	#$00012d00,d0
		bne.b	WT_sv_wait

		move.l	a1,cop1lc(a5)
		move.w	d0,copjmp1(a5)

		rts


; -----------------------------------------------------------------------------
; Procedure:	WT_FadePhase
; Function:	Fade palette (one phase)
; In:
;	a0.l	pointer to 32bit palette
;	d5.l	fade phase (1/16)
;	d7.w	number of colors  -1
; Out:
;	none
; -----------------------------------------------------------------------------

WT_FadePhase
		move.w	#$0020,d0
		move.w	#$0220,d1
WT_fp_cheat
		lea	CUSTOM,a5
WT_fp_Loop1
		moveq	#31,d6
		cmpi.w	#32,d7
		bge.b	WT_fp0

		move.w	d7,d6
WT_fp0
		move.w	#color,d2
WT_fp_Loop0
		move.l	(a0)+,d3
		move.l	d3,d4
		andi.l	#$0000ff00,d3
		andi.l	#$00ff00ff,d4
		mulu.l	d5,d3
		mulu.l	d5,d4
		lsr.l	#4,d3
		andi.l	#$0000ff00,d3
		lsr.l	#4,d4
		andi.l	#$00ff00ff,d4
		or.l	d4,d3
		move.l	d3,d4

		lsr.l	#4,d3
		lsl.b	#4,d3
		lsl.w	#4,d3
		lsr.l	#8,d3

		lsl.b	#4,d4
		lsl.w	#4,d4
		lsr.l	#8,d4
		andi.w	#$0fff,d4

		move.w	d0,bplcon3(a5)
		move.w	d3,(a5,d2.w)
		move.w	d1,bplcon3(a5)
		move.w	d4,(a5,d2.w)

		addq.w	#2,d2

		subq.w	#1,d7
		dbra	d6,WT_fp_Loop0

		addi.w	#$2000,d0
		addi.w	#$2000,d1

		tst.w	d7
		bpl.b	WT_fp_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	WT_CopyMask
; Function:	Copy mask to chunky
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

WT_CopyMask
		move.l	WT_PlanesRender,a0
		lea	16+WT_WIDTH_B*92*8(a0),a0

		lea	CUSTOM,a5
		WaitBlitter

		move.l	a0,bltdpt(a5)
		move.l	a0,bltcpt(a5)
		move.l	WT_Clip,bltbpt(a5)
		move.l	WT_Mask,bltapt(a5)
		move.l	#$0fca0000,bltcon0(a5)
		move.l	#$ffffffff,bltafwm(a5)
		move.w	#WT_WIDTH_B-96>>3,bltdmod(a5)
		move.w	#WT_WIDTH_B-96>>3,bltcmod(a5)
		move.w	#0,bltamod(a5)
		move.w	#0,bltbmod(a5)
		move.w	#54*8,bltsizv(a5)
		move.w	#96>>4,bltsizh(a5)

		rts


; -----------------------------------------------------------------------------
; Procedure:	WT_InitPerspTable
; Function:	Initialize perspective table
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

WT_InitPerspTable
		move.l	 WT_PerspTableH,a0
		move.l	 WT_PerspTableV,a1

		moveq	#0,d1
WT_ipt_Loop1
		move.l	d1,d2
		extb.l	d2
		addi.l	#WT_OBSERVER_Z,d2
		moveq	#-WT_WWIDTH2+1,d0
WT_ipt_Loop0
		move.w	d0,d3
		muls	d2,d3
		divs	#WT_OBSERVER_Z,d3
		addi.w	#WT_WWIDTH2-1,d3
		bmi.b	WT_ipt0
		cmpi.w	#WT_WWIDTH,d3
		blt.b	WT_ipt1
WT_ipt0
		move.w	#0,d3
WT_ipt1
		move.w	d3,(a0)+
		mulu	#WT_WWIDTH,d3
		move.w	d3,(a1)+

		addq.w	#1,d0
		cmpi.w	#WT_WWIDTH2,d0
		ble.b	WT_ipt_Loop0

		addq.w	#1,d1
		cmpi.w	#255,d1
		ble.b	WT_ipt_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	WT_InitTextures
; Function:	Initialize textures
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

WT_InitTextures
		move.l	WT_Chunky,a0
		move.l	WT_Lech,a1
		move.l	a1,WT_Texture
		move.w	#WT_WWIDTH*WT_WHEIGHT/4-1,d7
WT_it_Loop0
		move.l	(a1),d0
		addi.l	#$40404040,d0
		move.l	d0,(a0)+
		move.l	d0,(a1)+

		dbra	d7,WT_it_Loop0

		move.l	WT_Milek,a0
		move.w	#WT_WWIDTH*WT_WHEIGHT/4-1,d7
WT_it_Loop1
		move.l	(a0),d0
		addi.l	#$40404040,d0
		move.l	d0,(a0)+

		dbra	d7,WT_it_Loop1

		move.l	WT_Milek,a0
		move.l	WT_Milek2,a1
		move.l	a1,a2
		adda.l	#256*208,a2

		move.w	#(WT_MHEIGHT-WT_WHEIGHT)*128/4-1,d7
WT_it_Loop3
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a2)+
		dbra	d7,WT_it_Loop3

		move.w	#WT_WHEIGHT-1,d7
WT_it_Loop2
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+

		move.w	#WT_WWIDTH/4-1,d6
WT_it_Loop4
		move.l	(a0)+,d0
		move.l	d0,(a1)+

		dbra	d6,WT_it_Loop4

		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+
		move.l	#$40404040,(a1)+

		dbra	d7,WT_it_Loop2

		rts


; -----------------------------------------------------------------------------
; Procedure:	WT_InitWave
; Function:	Initialize wave table
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

WT_InitWave
		move.l	WT_TmpWave,a0
		move.l	WT_Wave,a1
		lea	WT_WAVE_LEN*2*2(a1),a1
		moveq	#WT_WAVE_LEN-1,d7

WT_iw_Loop	moveq	#0,d0
		move.b	(a0)+,d0
		add.b	#136,d0
		mulu	#WT_WWIDTH*2,d0
		move.w	d0,WT_WAVE_LEN*2*2(a1)
		move.w	d0,WT_WAVE_LEN*2(a1)
		move.w	d0,(a1)+

		dbra	d7,WT_iw_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	WT_MakeWave
; Function:	Make one frame of wave
; In:
;	a0.l	pointer to wave table
; Out:
;	none
; -----------------------------------------------------------------------------

WT_MakeWave
		move.l	WT_Chunky,a1
		move.l	WT_Texture,a2
		move.l	WT_LenMap,a3
		move.l	WT_PerspTableV,a4

		move.w	#WT_WHEIGHT-1,d7

		move.l	WT_PerspTableH,d5

		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
WT_mw_Loop1
		moveq	#WT_WWIDTH/4-1,d6

		move.l	d5,a5

WT_mw_Loop0	move.l	(a3)+,d3

		move.b	d3,d0
		move.w	(a0,d0.w*2),d2
		move.w	(a4,d2.l),d1
		add.w	6(a5,d2.l),d1
		move.b	(a2,d1.l),d3
		ror.l	#8,d3

		move.b	d3,d0
		move.w	(a0,d0.w*2),d2
		move.w	(a4,d2.l),d1
		add.w	4(a5,d2.l),d1
		move.b	(a2,d1.l),d3
		ror.l	#8,d3

		move.b	d3,d0
		move.w	(a0,d0.w*2),d2
		move.w	(a4,d2.l),d1
		add.w	2(a5,d2.l),d1
		move.b	(a2,d1.l),d3
		ror.l	#8,d3

		move.b	d3,d0
		move.w	(a0,d0.w*2),d2
		move.w	(a4,d2.l),d1
		add.w	(a5,d2.l),d1
		move.b	(a2,d1.l),d3
		ror.l	#8,d3

		move.l	d3,(a1)+

		addq.w	#2*4,a5

		dbra	d6,WT_mw_Loop0

		addq.w	#2,a4

		dbra	d7,WT_mw_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	WT_WaveSection
; Function:	Wave
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

WT_WS_TIME	=	77
WT_WaveSection
		bsr.w	WT_InitPerspTable
		bsr.w	WT_InitWave
		move.l	WT_Wave,WT_WaveTmp

		move.w	#WT_WS_TIME,WT_Cntr
WT_ws_Loop
		move.l	WT_WaveTmp,a0
		bsr.w	WT_MakeWave

		move.l	WT_Chunky,a0

		subq.w	#1,WT_Cntr
		cmpi.w	#15,WT_Cntr
		bgt.b	WT_ws1

		move.w	#15,d0
		sub.w	WT_Cntr,d0
		move.l	WT_Chunky2,a0
		move.l	WT_Chunky,a1
		bsr.w	WT_MakePixelize
		move.l	WT_Lech,WT_Texture
		move.l	WT_Chunky2,a0
WT_ws1
		move.l	WT_PlanesRender,a1
		lea	16+WT_WIDTH_B*29*8(a1),a1
		bsr.w	WT_ChunkyToPlanar

		bsr.w	WT_CopyMask
		WaitBlitter

		bsr.w	WT_SwitchView

		move.l	WT_WaveTmp,a0
	IFLT	WT_SPEED-9
		addq.w	#WT_SPEED,a0
	ELSE
		adda.w	#WT_SPEED,a0
	ENDC
		move.l	WT_Wave,a1
		lea	WT_WAVE_LEN*2*3(a1),a1
		cmpa.l	a1,a0
		blt.b	WT_ws0
		lea	-WT_WAVE_LEN*2(a0),a0
WT_ws0
		move.l	a0,WT_WaveTmp

		tst.w	WT_Cntr
		bpl.w	WT_ws_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	WT_MakeTwirl
; Function:	Make one frame of twirl
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

WT_MakeTwirl
		move.l	WT_Chunky,a0
		move.l	WT_Texture,a1
		adda.l	#128*256+128,a1
		move.l	WT_LenMap2,a2
		move.l	WT_RotXTable,a5
		move.l	WT_RotYTable,a6
		adda.l	#160*2*90*2,a6

		move.w	#WT_WHEIGHT-1,d7

		move.l	WT_RotYTable,d3
		move.l	WT_RotXTable,d4
		addi.l	#160*2*90*2,d4

		moveq	#0,d0
		moveq	#0,d2
WT_mt_Loop1
		moveq	#WT_WWIDTH/2/4-1,d6

		move.l	d3,a3
		move.l	d4,a4

WT_mt_Loop0	move.l	(a2)+,d5

		move.b	d5,d0
		move.l	(WT_AngleTable,pc,d0.w*4),d2
		move.w	6*2(a4,d2.l),d1
		add.w	(a5,d2.l),d1
		add.w	(a6,d2.l),d1
		sub.w	6*2(a3,d2.l),d1
		move.b	(a1,d1.w),d5
		ror.l	#8,d5

		move.b	d5,d0
		move.l	(WT_AngleTable,pc,d0.w*4),d2
		move.w	4*2(a4,d2.l),d1
		add.w	(a5,d2.l),d1
		add.w	(a6,d2.l),d1
		sub.w	4*2(a3,d2.l),d1
		move.b	(a1,d1.w),d5
		ror.l	#8,d5

		move.b	d5,d0
		move.l	(WT_AngleTable,pc,d0.w*4),d2
		move.w	2*2(a4,d2.l),d1
		add.w	(a5,d2.l),d1
		add.w	(a6,d2.l),d1
		sub.w	2*2(a3,d2.l),d1
		move.b	(a1,d1.w),d5
		ror.l	#8,d5

		move.b	d5,d0
		move.l	(WT_AngleTable,pc,d0.w*4),d2
		move.w	(a4,d2.l),d1
		add.w	(a5,d2.l),d1
		add.w	(a6,d2.l),d1
		sub.w	(a3,d2.l),d1
		move.b	(a1,d1.w),d5
		ror.l	#8,d5

		move.l	d5,(a0)+

		lea	8*2(a3),a3
		lea	8*2(a4),a4

		dbra	d6,WT_mt_Loop0

		addq.w	#2,a5
		addq.w	#2,a6

		dbra	d7,WT_mt_Loop1
 
		rts


; -----------------------------------------------------------------------------
; Procedure:	WT_TwirlSection
; Function:	Wave
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

WT_TS_TIME1	=	70
WT_TS_TIME2	=	50

WT_TwirlSection
		move.l	WT_Palette,a0
		lea	64*4(a0),a0
		move.l	WT_MilekPalette,a1
		move.w	#192-1,d7
WT_ts_Loop3
		move.l	(a1)+,(a0)+
		dbra	d7,WT_ts_Loop3

		move.l	WT_LenMap,a0
		move.l	WT_LenMap2,a1
		move.w	#80*160-1,d7
WT_ts_Loop1
		move.b	(a0)+,(a1)+
		addq.w	#1,a0
		dbra	d7,WT_ts_Loop1

		moveq	#16,d5
		move.l	WT_MilekPalette,a0
		move.w	#192-1,d7
		move.w	#$4020,d0
		move.w	#$4220,d1
		bsr.w	WT_fp_cheat

		move.w	#15,WT_Cntr
WT_ts_Loop2
		move.w	WT_Cntr,d0

		move.l	WT_Chunky,a0
		move.l	WT_Milek,a1
		bsr.w	WT_MakePixelize

		move.l	WT_Chunky,a0
		move.l	WT_PlanesRender,a1
		lea	16+WT_WIDTH_B*29*8(a1),a1
		bsr.w	WT_ChunkyToPlanar

		bsr.w	WT_CopyMask
		WaitBlitter

		bsr.w	WT_SwitchView

		subq.w	#1,WT_Cntr
		bpl.b	WT_ts_Loop2

		move.l	WT_AngleTableTmp,a0
		move.l	WT_SpeedTable,a1
		moveq	#113-1,d7
WT_ts_Loop5
		move.l	#0,(a0)+
		move.l	#0,(a1)+

		dbra	d7,WT_ts_Loop5

		move.l	WT_Milek2,WT_Texture
		move.w	#WT_TS_TIME1,WT_Cntr
WT_ts_Loop
		bsr.w	WT_MakeTwirl

		move.l	WT_Chunky,a0
		move.l	WT_PlanesRender,a1
		lea	16+WT_WIDTH_B*29*8(a1),a1
		bsr.w	WT_ChunkyToPlanar2

		bsr.w	WT_CopyMask
		WaitBlitter

		bsr.w	WT_SwitchView

		move.w	WT_Cntr,d0
		subi.w	#WT_TS_TIME1,d0
		neg.w	d0
		lsl.w	#2,d0
		cmpi.w	#112,d0
		bge.b	WT_ts6

WT_TS_SPEED	=	4*512
WT_TS_RANGE	=	15*512

		move.l	WT_SpeedTable,a0
		move.l	#WT_TS_SPEED,(a0,d0.w*4)
		move.l	#WT_TS_SPEED,4(a0,d0.w*4)
		move.l	#WT_TS_SPEED,8(a0,d0.w*4)
		move.l	#WT_TS_SPEED,12(a0,d0.w*4)
WT_ts6
		move.l	WT_AngleTableTmp,a0
		move.l	WT_SpeedTable,a1
		moveq	#113-1,d7
WT_ts_Loop0
		move.l	(a0),d0
		add.l	(a1)+,d0
		cmpi.l	#WT_TS_RANGE,d0
		bge.b	WT_ts0
		cmpi.l	#-WT_TS_RANGE,d0
		bgt.b	WT_ts2
WT_ts0
		neg.l	-4(a1)
WT_ts2
		move.l	d0,(a0)+
		dbra	d7,WT_ts_Loop0

		move.l	WT_AngleTableTmp,a0
		lea	WT_AngleTable,a1
		moveq	#113-1,d7
WT_ts_Loop4
		move.l	(a0)+,d0
		bpl.b	WT_ts3
WT_ts4
		addi.l	#720*256,d0
		bmi.b	WT_ts4
WT_ts3
		cmpi.l	#720*256,d0
		blt.b	WT_ts5
		subi.l	#720*256,d0
		bra.b	WT_ts3
WT_ts5
		lsr.l	#8,d0
		lsl.l	#6,d0
		move.l	d0,d1
		lsl.l	#2,d0
		add.l	d1,d0
		move.l	d0,(a1)+

		dbra	d7,WT_ts_Loop4

		subq.w	#1,WT_Cntr
		bpl.w	WT_ts_Loop

WT_ts_Loop10
		bsr.w	WT_MakeTwirl

		move.l	WT_Chunky,a0
		move.l	WT_PlanesRender,a1
		lea	16+WT_WIDTH_B*29*8(a1),a1
		bsr.w	WT_ChunkyToPlanar2

		bsr.w	WT_CopyMask
		WaitBlitter

		bsr.w	WT_SwitchView

		move.w	#0,WT_Cntr

		move.l	WT_AngleTableTmp,a0
		move.l	WT_SpeedTable,a1
		moveq	#113-1,d7
WT_ts_Loop11
		move.l	(a1)+,d1
		move.l	(a0)+,d0
		beq.b	WT_ts18
		bpl.b	WT_ts16
		add.l	d1,d0
		bmi.b	WT_ts17
		moveq	#0,d0
		move.w	#1,WT_Cntr
		bra.b	WT_ts15
WT_ts16
		add.l	d1,d0
WT_ts17
		cmpi.l	#WT_TS_RANGE,d0
		bge.b	WT_ts14
		cmpi.l	#-WT_TS_RANGE,d0
		bgt.b	WT_ts15
WT_ts14
		neg.l	-4(a1)
WT_ts15
		move.l	d0,-4(a0)
WT_ts18
		dbra	d7,WT_ts_Loop11

		move.l	WT_AngleTableTmp,a0
		lea	WT_AngleTable,a1
		moveq	#113-1,d7
WT_ts_Loop12
		move.l	(a0)+,d0
		bpl.b	WT_ts12
WT_ts11
		addi.l	#720*256,d0
		bmi.b	WT_ts11
WT_ts12
		cmpi.l	#720*256,d0
		blt.b	WT_ts13
		subi.l	#720*256,d0
		bra.b	WT_ts12
WT_ts13
		lsr.l	#8,d0
		lsl.l	#6,d0
		move.l	d0,d1
		lsl.l	#2,d0
		add.l	d1,d0
		move.l	d0,(a1)+

		dbra	d7,WT_ts_Loop12

		tst.w	WT_Cntr
		bne.w	WT_ts_Loop10

		move.l	WT_SpeedTable,a0
		moveq	#120,d6
		moveq	#112/2-1,d7
WT_ts_Loop9
		move.l	d6,(a0)+
		move.l	d6,(a0)+

		addi.w	#120,d6

		dbra	d7,WT_ts_Loop9

		move.w	#WT_TS_TIME2,WT_Cntr
WT_ts_Loop8
		bsr.w	WT_MakeTwirl

		move.l	WT_Chunky,a0
		move.l	WT_PlanesRender,a1
		lea	16+WT_WIDTH_B*29*8(a1),a1
		bsr.w	WT_ChunkyToPlanar2

		bsr.w	WT_CopyMask
		WaitBlitter

		bsr.w	WT_SwitchView

		move.l	WT_AngleTableTmp,a0
		move.l	WT_SpeedTable,a1
		moveq	#113-1,d7
WT_ts_Loop6
		move.l	(a0),d0
		add.l	(a1)+,d0
		move.l	d0,(a0)+
		dbra	d7,WT_ts_Loop6

		move.l	WT_AngleTableTmp,a0
		lea	WT_AngleTable,a1
		moveq	#113-1,d7
WT_ts_Loop7
		move.l	(a0)+,d0
		bpl.b	WT_ts7
WT_ts8
		addi.l	#720*256,d0
		bmi.b	WT_ts8
WT_ts7
		cmpi.l	#720*256,d0
		blt.b	WT_ts9
		subi.l	#720*256,d0
		bra.b	WT_ts7
WT_ts9
		lsr.l	#8,d0
		lsl.l	#6,d0
		move.l	d0,d1
		lsl.l	#2,d0
		add.l	d1,d0
		move.l	d0,(a1)+

		dbra	d7,WT_ts_Loop7

		subq.w	#1,WT_Cntr
		bmi.b	WT_ts10
		move.w	WT_Cntr,d5
		cmpi.w	#15,d5
		bgt.w	WT_ts_Loop8

		move.l	WT_Palette,a0
		move.w	#256-1,d7
		bsr.w	WT_FadePhase

		bra.w	WT_ts_Loop8
WT_ts10
		rts


; -----------------------------------------------------------------------------
; Procedure:	WT_MakePixelizeTable
; Function:	Make table for pixelize effect
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

WT_MakePixelizeTable
		move.l	WT_PixelizeTable,a0

		moveq	#1,d7
WT_mpt_Loop0
		moveq	#0,d6
WT_mpt_Loop1
		move.l	d6,d0
		divu	d7,d0
		mulu	d7,d0
		move.b	d0,(a0)+

		addq.w	#1,d6
		cmpi.w	#160,d6
		blt.b	WT_mpt_Loop1

		addq.w	#1,d7
		cmpi.w	#160,d7
		ble.b	WT_mpt_Loop0

		rts


; -----------------------------------------------------------------------------
; Procedure:	WT_MakePixelize
; Function:	Make one frame of pixelize effect
; In:
;	d0.w	size of pixel (0÷159) -1
;	a0.l	pointer to chunky
;	a1.l	pointer to texture
; Out:
;	none
; -----------------------------------------------------------------------------

WT_MakePixelize
		move.l	WT_PixelizeTable,a2
		move.w	d0,d2
		mulu	#160,d2
		adda.l	d2,a2

		moveq	#0,d1
		move.w	d0,d5
		moveq	#0,d2
		move.w	d0,d2
		addq.w	#1,d2
		mulu	#160,d2

		move.w	#WT_WHEIGHT-1,d7
WT_mp_Loop1
		move.w	#WT_WWIDTH-1,d6
WT_mp_Loop0
		move.b	(a2,d6.w),d1
		move.b	(a1,d1.w),(a0,d6.w)

		dbra	d6,WT_mp_Loop0

		lea	WT_WWIDTH(a0),a0

		subq.w	#1,d5
		bpl.b	WT_mp0
		adda.l	d2,a1
		move.w	d0,d5
WT_mp0
		dbra	d7,WT_mp_Loop1

		rts


; -----------------------------------------------------------------------------

		INCLUDE	"WaveTwirl/WT_C2P.s"
		INCLUDE	"WaveTwirl/WT_C2P.2.s"

; ---------------------------------------------------------------------------

		CNOP	0,2
WT_MemEntry	DCB.B	14
		DC.W	12
	DC.L	MEMF_CHIP,WT_DEPTH*8*2+4*2			; CopperList
	DC.L	MEMF_CHIP,WT_DEPTH*WT_PLANE_SIZE		; Planes1
	DC.L	MEMF_PUBLIC,WT_WWIDTH*WT_WHEIGHT		; Chunky
	DC.L	MEMF_PUBLIC,WT_WWIDTH*WT_WHEIGHT		; Chunky2
	DC.L	MEMF_PUBLIC,WT_WWIDTH*256*2			; PerspTableH
	DC.L	MEMF_PUBLIC,WT_WHEIGHT*256*2			; PerspTableV
	DC.L	MEMF_PUBLIC|MEMF_CLEAR,WT_WAVE_LEN*2*5		; Wave
	DC.L	MEMF_PUBLIC,160*160				; PixelizeTable
	DC.L	MEMF_PUBLIC,80*160				; LenMap2
	DC.L	MEMF_PUBLIC,256*256				; Milek2
	DC.L	MEMF_PUBLIC,113*4				; AngleTableTmp
	DC.L	MEMF_PUBLIC,113*4				; SpeedTable

WT_MemEntryPtr	DC.L	0

WT_CopperList	DC.L	0
WT_CopperDisplay	DC.L	0
WT_CopperRender	DC.L	0
WT_PlanesDisplay	DC.L	0
WT_PlanesRender	DC.L	0
WT_Chunky	DC.L	0
WT_Chunky2	DC.L	0
WT_Palette	DC.L	0
WT_PerspTable	DC.L	0
WT_Clip		DC.L	0
WT_Mask		DC.L	0
WT_Lech		DC.L	0
WT_LechPalette	DC.L	0
WT_Milek	DC.L	0
WT_Milek2	DC.L	0
WT_MilekPalette	DC.L	0
WT_LenMap	DC.L	0
WT_LenMap2	DC.L	0
WT_TmpWave	DC.L	0
WT_Wave		DC.L	0
WT_PerspTableH	DC.L	0
WT_PerspTableV	DC.L	0
WT_Texture	DC.L	0
WT_RotXTable	DC.L	0
WT_RotYTable	DC.L	0
WT_EmptyCL	DC.L	-2
WT_Cntr		DC.L	0
WT_WaveTmp	DC.L	0
WT_PixelizeTable	DC.L	0
WT_AngleTableTmp	DC.L	0
WT_SpeedTable	DC.L	0

WT_AngleTable	REPT	113
		DC.L	0
		ENDR

; ---------------------------------------------------------------------------

; ===========================================================================

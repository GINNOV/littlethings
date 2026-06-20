; ===========================================================================
; Name:		Gouraud and texture face
; File:		GTFace_xx.s
; Author:	Noe / Venus Art
; Copyright:	© 1995 by Venus Art
; ---------------------------------------------------------------------------
; History:
; 13.08.1995	Based on GouraudFace_37.s
; 18.08.1995	4:50 ... I kill fucked bug (ONE letter fixed !!!)
; 19.08.1995	by night: add light sourceing section
;		by day: add candle (light source) to Light sourceing
;
; ===========================================================================

SAFE		=	0

GF_HOFFSET	=	$81
GF_VOFFSET	=	$2c+15
GF_WIDTH	=	320
GF_HEIGHT	=	225
GF_DEPTH	=	8

GF_WIDTH_B	=	GF_WIDTH>>3
GF_WIDTH_W	=	GF_WIDTH>>4

GF_WIDTH2	=	GF_WIDTH>>1
GF_HEIGHT2	=	GF_HEIGHT>>1

GF_PLANE_SIZE	=	GF_WIDTH_B*GF_HEIGHT

GF_CWIDTH	=	256
GF_CHEIGHT	=	256
GF_CWIDTH2	=	GF_CWIDTH>>1
GF_CHEIGHT2	=	GF_CHEIGHT>>1

GF_WWIDTH	=	160
GF_WHEIGHT	=	119
GF_WWIDTH2	=	GF_WWIDTH>>1
GF_WHEIGHT2	=	GF_WHEIGHT>>1
GF_WWIDTH_B	=	GF_WWIDTH>>3
GF_WWIDTH_W	=	GF_WWIDTH>>4

GF_OBSERVER_Z	=	500
TF_OBSERVER_Z	=	190


; ---------------------------------------------------------------------------

		SECTION	GTFace_0,CODE

GTFace
		move.l	(a0)+,a1
		addq.w	#MAGIC_NUMBER,a1
		move.l	a1,GF_PlanesDisplay
		adda.l	#72000,a1
		move.l	a1,GF_MulsTable
		move.l	a1,TF_PerspTableH
		move.l	a1,LS_PowerTable
		move.l	a1,a2
		adda.l	#131072,a2
		move.l	a2,GF_DivTable
		move.l	a1,a2
		adda.l	#160*256*2,a2
		move.l	a2,TF_PerspTableV
		move.l	a1,a2
		adda.l	#127*256*2+127*2,a2
		move.l	a2,LS_Power2Table
		move.l	a1,GF_Screens
		adda.w	#19040,a1
		move.l	a1,GF_Screens+4
		move.l	a1,GF_Screens+13*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+2*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+3*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+4*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+5*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+6*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+7*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+8*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+9*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+10*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+11*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+12*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+14*4
		move.l	a1,GF_Screens+22*4
		move.l	a1,GF_Screens+25*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+15*4
		move.l	a1,GF_Screens+23*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+16*4
		move.l	a1,GF_Screens+24*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+17*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+18*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+19*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+20*4
		adda.w	#19040,a1
		move.l	a1,GF_Screens+21*4
		adda.w	#19040,a1
		move.l	a1,GF_GouraudLogo
		move.l	(a0)+,a1
		addq.w	#MAGIC_NUMBER,a1
		move.l	a1,GF_SPHERE
		adda.w	#11060,a1
		move.l	a1,GF_WAVE_SPHERE
		adda.w	#11060,a1
		move.l	a1,GF_TORUS
		adda.w	#15928,a1
		move.l	a1,GF_CHOPHAND
		adda.w	#10846,a1
		move.l	a1,GF_CHOPHEAD
		adda.w	#10020,a1
		move.l	a1,GF_HEAD
		adda.w	#28324,a1
		move.l	a1,GF_HEAD_BASE
		adda.w	#908,a1
		move.l	a1,GF_GLASSES
		adda.w	#2208,a1
		move.l	a1,GF_Palette
		adda.w	#1024,a1
		move.l	a1,GF_Palette0
		adda.w	#1024,a1
		move.l	a1,GF_Palette1
		adda.w	#1024,a1
		move.l	a1,GF_Palette2
		adda.w	#1024,a1
		move.l	a1,GF_Palette3
		adda.w	#1024,a1
		move.l	a1,GF_Palette4
		adda.w	#1024,a1
		move.l	a1,GF_Palette5
		adda.w	#1024,a1
		move.l	a1,GF_BPalette0
		adda.w	#64,a1
		move.l	a1,GF_BPalette1
		adda.w	#64,a1
		move.l	a1,GF_BPalette2
		adda.w	#64,a1
		move.l	a1,GF_BPalette3
		adda.w	#64,a1
		move.l	a1,GF_BPalette4
		adda.w	#64,a1
		move.l	a1,GF_SinusTable
		adda.w	#23040,a1
		move.l	a1,GF_Pointer
		adda.w	#96,a1
		move.l	a1,GF_PointerMask
		adda.w	#96,a1
		move.l	a1,GF_PointerPalette
		adda.w	#64,a1
		move.l	a1,GF_SPalettes
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+4
		move.l	a1,GF_SPalettes+13*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+2*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+3*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+4*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+5*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+6*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+7*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+8*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+9*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+10*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+11*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+12*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+14*4
		move.l	a1,GF_SPalettes+22*4
		move.l	a1,GF_SPalettes+25*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+15*4
		move.l	a1,GF_SPalettes+23*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+16*4
		move.l	a1,GF_SPalettes+24*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+17*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+18*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+19*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+20*4
		adda.w	#64,a1
		move.l	a1,GF_SPalettes+21*4
		adda.w	#64,a1
		move.l	a1,GF_GouraudPalette
		adda.w	#64,a1
		move.l	a1,GF_GuruPalette
		adda.w	#128,a1
		move.l	a1,GF_GuruPalette2
		adda.w	#128,a1
		move.l	a1,GF_Texts
		adda.w	#480,a1
		move.l	a1,GF_Texts+4
		adda.w	#480,a1
		move.l	a1,GF_Texts+2*4
		adda.w	#480,a1
		move.l	a1,GF_Texts+3*4
		adda.w	#480,a1
		move.l	a1,GF_Texts+4*4
		adda.w	#480,a1
		move.l	a1,GF_Texts+5*4
		adda.w	#480,a1
		move.l	a1,GF_Texts+6*4
		adda.w	#480,a1
		move.l	a1,GF_MouseMTable
		move.l	(a0)+,a1
		addq.w	#MAGIC_NUMBER,a1
		move.l	a1,GF_Background0
		adda.w	#19040,a1
		move.l	a1,GF_Background1
		adda.w	#19040,a1
		move.l	a1,GF_Background2
		adda.w	#19040,a1
		move.l	a1,GF_Background3
		adda.w	#19040,a1
		move.l	a1,GF_Background4
		adda.w	#19040,a1
		move.l	a1,GF_GuruScreen

		AllocMemBlocks	GF_MemEntry
		bne.w	GF_AllocMemError
		move.l	d0,GF_MemEntryPtr

		bsr.w	GF_SetMemPtrs

		AllocMemBlocks	GF_MemEntry2
		bne.w	GF_AllocMemError2
		move.l	d0,GF_MemEntryPtr2

		bsr.w	GF_SetMemPtrs2

		suba.l	a0,a0
		move.w	#1<<GF_DEPTH-1,d7
		jsr	SetPalette

	IFEQ	DEBUG

		lea	CUSTOM,a5

		move.w	#$0120,dmacon(a5)
		move.w	#$83c0,dmacon(a5)

	ENDC

		bsr.w	GF_InitSinPtrTable
		bsr.w	GF_InitBackgrounds

		move.l	GF_Palette,a0
		lea	240*4(a0),a0
		move.l	GF_PaletteAux,a1
		moveq	#16-1,d7
GF_xxx
		move.l	(a0)+,16*4(a1)
		move.l	#0,(a1)+
		dbra	d7,GF_xxx

		bsr.w	GF_InitView

		move.l	GF_Palette,a0
		move.l	#$00000000,223*4(a0)


		move.w	#0,d5
GF_FadeIn_Loop
		moveq	#2,d0
		jsr	Wait

		move.l	GF_Palette,a0
		move.w	#16-1,d7
		bsr.w	GF_FadePhase

		move.l	GF_Palette,a0
		lea	224*4(a0),a0
		move.w	#32-1,d7
		move.w	#$e000,d0
		move.w	#$e200,d1
		bsr.w	GF_fp_cheat

		addq.w	#1,d5
		cmpi.w	#15,d5
		ble.b	GF_FadeIn_Loop

		move.w	#$0020,bplcon3+CUSTOM

		bsr.w	GF_WBPhase

		bsr.w	GF_DisplayGLogo

		bsr.w	GF_RotateSphere
		tst.b	d0
		beq.w	GF_AllocMemError2

		bsr.w	GF_RotateWaveSphere
		tst.b	d0
		beq.w	GF_AllocMemError2

		bsr.w	GF_RotateTorus
		tst.b	d0
		beq.w	GF_AllocMemError2

		bsr.w	GF_RotateChopper
		tst.b	d0
		beq.w	GF_AllocMemError2

		bsr.w	GF_RotateHead
		tst.b	d0
		beq.w	GF_AllocMemError2

		FreeMemBlocks	GF_MemEntryPtr2

		bsr.w	GF_GuruSection

		rts

GTFace2
		move.l	(a0),a1
		addq.w	#MAGIC_NUMBER,a1
		move.l	a1,LS_BurnPalette
		adda.w	#1024,a1
		move.l	a1,LS_CandlePalette
		adda.w	#64,a1
		move.l	a1,GF_Texts+7*4
		adda.w	#480,a1
		move.l	a1,GF_Texts+8*4
		adda.w	#480,a1
		move.l	a1,GF_Texts+9*4
		adda.w	#480,a1
		move.l	a1,GF_Texts+10*4
		adda.w	#480,a1
		move.l	a1,GF_Texts+11*4
		adda.w	#480,a1
		move.l	a1,TF_Heads
		move.l	a1,TF_Heads+29*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+4
		move.l	a1,TF_Heads+28*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+2*4
		move.l	a1,TF_Heads+27*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+3*4
		move.l	a1,TF_Heads+26*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+4*4
		move.l	a1,TF_Heads+25*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+5*4
		move.l	a1,TF_Heads+24*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+6*4
		move.l	a1,TF_Heads+23*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+7*4
		move.l	a1,TF_Heads+22*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+8*4
		move.l	a1,TF_Heads+21*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+9*4
		move.l	a1,TF_Heads+20*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+10*4
		move.l	a1,TF_Heads+19*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+11*4
		move.l	a1,TF_Heads+18*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+12*4
		move.l	a1,TF_Heads+17*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+13*4
		move.l	a1,TF_Heads+16*4
		adda.w	#19040,a1
		move.l	a1,TF_Heads+14*4
		move.l	a1,TF_Heads+15*4
		adda.w	#19040,a1
		move.l	a1,TF_BinTexture
		adda.l	#15840*3,a1
		move.l	a1,LS_HeadMap
		adda.w	#19040,a1
		move.l	a1,LS_Candle
		adda.w	#336,a1
		move.l	a1,LS_Candle+4
		adda.w	#336,a1
		move.l	a1,LS_Candle+2*4
		adda.w	#336,a1
		move.l	a1,LS_Candle+3*4
		adda.w	#336,a1
		move.l	a1,LS_CandleMoveTable
		adda.w	#800,a1
		move.l	a1,LS_SqrtTable

		bsr.w	GF_GuruSection2

		bsr.w	TF_InitPerspTable
		bsr.w	TF_TextureSection

		bsr.w	LS_InitPowerTable
		bsr.w	LS_LightSection

		move.w	#15,d5
GF_FadeOut_Loop
		moveq	#2,d0
		jsr	Wait

		move.l	GF_PaletteAux,a0
		move.w	#32-1,d7
		move.w	#$e000,d0
		move.w	#$e200,d1
		bsr.w	GF_fp_cheat

		dbra	d5,GF_FadeOut_Loop

GF_End
		FreeMemBlocks	GF_MemEntryPtr
GF_AllocMemError

		moveq	#0,d0
		rts

GF_AllocMemError2
		FreeMemBlocks	GF_MemEntryPtr2
		FreeMemBlocks	GF_MemEntryPtr
		moveq	#1,d0
		rts

; ---------------------------------------------------------------------------

GF_SPHERE_ROTX_SPEED	=	1
GF_SPHERE_ROTY_SPEED	=	-1
GF_SPHERE_ROTZ_SPEED	=	-1

GF_SPHERE_L_ROTX_SPEED	=	-1
GF_SPHERE_L_ROTY_SPEED	=	-1
GF_SPHERE_L_ROTZ_SPEED	=	1

GF_SPHERE_TIME		=	100

GF_RotateSphere
		lea	GF_World,a0
		move.w	#1-1,w_ObjectsNumber(a0)
		move.l	GF_SPHERE,GF_ObjectsList
		move.l	#NULL,GF_ObjectsList+4

		move.w	#0,GF_Light1+lt_RotX
		move.w	#0,GF_Light1+lt_RotY
		move.w	#0,GF_Light1+lt_RotZ

		move.l	GF_SPHERE,a1
		move.w	#10,o_RotX(a1)
		move.w	#60,o_RotY(a1)
		move.w	#40,o_RotZ(a1)

		bsr.w	GF_InitWorld
		tst.b	d0
		beq.w	GF_rs0

		move.l	GF_Texts,a0
		bsr.w	GF_CopyText

		move.l	GF_Background0,GF_Background
		bsr.w	GF_ClearChunky

		move.l	GF_Palette2,a0
		lea	224*4(a0),a1
		move.l	GF_BPalette0,a2
		moveq	#16-1,d7
GF_rs_Loop1
		move.l	(a2)+,(a1)+
		dbra	d7,GF_rs_Loop1

		move.l	#GF_SPHERE_TIME,GF_Cntr
GF_rs_Loop0
		lea	CUSTOM,a5
		WaitBlitter

		bsr.w	GF_RenderWorld

		move.l	GF_Chunky,a0
		lea	48+68*GF_CWIDTH(a0),a0
		move.l	GF_PlanesRender,a1
		lea	4+GF_WIDTH_B*30*8(a1),a1
		bsr.w	GF_ChunkyToPlanar

		bsr.w	GF_ClearChunky

		bsr.w	GF_SwitchView

		move.l	GF_Cntr,d5
		cmpi.l	#16,d5
		ble.b	GF_rs7

		cmpi.l	#GF_SPHERE_TIME-16,d5
		blt.b	GF_rs8
		subi.l	#GF_SPHERE_TIME,d5
		neg.l	d5
GF_rs7
		move.l	GF_Palette2,a0
		move.w	#240-1,d7
		bsr.w	GF_FadePhase
GF_rs8
		move.l	GF_SPHERE,a0
		move.w	o_RotX(a0),d0
		addi.w	#GF_SPHERE_ROTX_SPEED,d0
		bpl.b	GF_rs1
		add.w	#72,d0
		bra.b	GF_rs1a
GF_rs1
		cmpi.w	#72,d0
		blt.b	GF_rs1a
		subi.w	#72,d0
GF_rs1a
		move.w	d0,o_RotX(a0)

		move.w	o_RotY(a0),d0
		addi.w	#GF_SPHERE_ROTY_SPEED,d0
		bpl.b	GF_rs2
		add.w	#72,d0
		bra.b	GF_rs2a
GF_rs2
		cmpi.w	#72,d0
		blt.b	GF_rs2a
		subi.w	#72,d0
GF_rs2a
		move.w	d0,o_RotY(a0)

		move.w	o_RotZ(a0),d0
		addi.w	#GF_SPHERE_ROTZ_SPEED,d0
		bpl.b	GF_rs3
		add.w	#72,d0
		bra.b	GF_rs3a
GF_rs3
		cmpi.w	#72,d0
		blt.b	GF_rs3a
		subi.w	#72,d0
GF_rs3a
		move.w	d0,o_RotZ(a0)

		move.w	GF_Light1+lt_RotX,d0
		addi.w	#GF_SPHERE_L_ROTX_SPEED,d0
		bpl.b	GF_rs4
		add.w	#72,d0
		bra.b	GF_rs4a
GF_rs4
		cmpi.w	#72,d0
		blt.b	GF_rs4a
		subi.w	#72,d0
GF_rs4a
		move.w	d0,GF_Light1+lt_RotX

		move.w	GF_Light1+lt_RotY,d0
		addi.w	#GF_SPHERE_L_ROTY_SPEED,d0
		bpl.b	GF_rs5
		add.w	#72,d0
		bra.b	GF_rs5a
GF_rs5
		cmpi.w	#72,d0
		blt.b	GF_rs5a
		subi.w	#72,d0
GF_rs5a
		move.w	d0,GF_Light1+lt_RotY

		move.w	GF_Light1+lt_RotZ,d0
		addi.w	#GF_SPHERE_L_ROTZ_SPEED,d0
		bpl.b	GF_rs6
		add.w	#72,d0
		bra.b	GF_rs6a
GF_rs6
		cmpi.w	#72,d0
		blt.b	GF_rs6a
		subi.w	#72,d0
GF_rs6a
		move.w	d0,GF_Light1+lt_RotZ

		subq.l	#1,GF_Cntr
		bpl.w	GF_rs_Loop0

		lea	GF_World,a0
		bsr.w	GF_FreeWorld

		moveq	#1,d0
GF_rs0
		rts


; ---------------------------------------------------------------------------

GF_WAVE_SPHERE_ROTX_SPEED	=	-1
GF_WAVE_SPHERE_ROTY_SPEED	=	-1
GF_WAVE_SPHERE_ROTZ_SPEED	=	1

GF_WAVE_SPHERE_L_ROTX_SPEED	=	-1
GF_WAVE_SPHERE_L_ROTY_SPEED	=	1
GF_WAVE_SPHERE_L_ROTZ_SPEED	=	1
GF_WAVE_SPHERE_TIME	=	100

GF_RotateWaveSphere
		lea	GF_World,a0
		move.w	#1-1,w_ObjectsNumber(a0)
		move.l	GF_WAVE_SPHERE,GF_ObjectsList
		move.l	#NULL,GF_ObjectsList+4

		move.w	#0,GF_Light1+lt_RotX
		move.w	#0,GF_Light1+lt_RotY
		move.w	#0,GF_Light1+lt_RotZ

		move.l	GF_WAVE_SPHERE,a1
		move.w	#60,o_RotX(a1)
		move.w	#10,o_RotY(a1)
		move.w	#30,o_RotZ(a1)

		bsr.w	GF_InitWorld
		tst.b	d0
		beq.w	GF_rws0

		move.l	GF_Texts+4,a0
		bsr.w	GF_CopyText

		move.l	GF_Background1,GF_Background
		bsr.w	GF_ClearChunky

		move.l	GF_Palette1,a0
		lea	224*4(a0),a1
		move.l	GF_BPalette1,a2
		moveq	#16-1,d7
GF_rws_Loop1
		move.l	(a2)+,(a1)+
		dbra	d7,GF_rws_Loop1

		move.l	#GF_WAVE_SPHERE_TIME,GF_Cntr
GF_rws_Loop0
		lea	CUSTOM,a5
		WaitBlitter

		bsr.w	GF_RenderWorld

		move.l	GF_Chunky,a0
		lea	48+68*GF_CWIDTH(a0),a0
		move.l	GF_PlanesRender,a1
		lea	4+GF_WIDTH_B*30*8(a1),a1
		bsr.w	GF_ChunkyToPlanar

		bsr.w	GF_ClearChunky

		bsr.w	GF_SwitchView

		move.l	GF_Cntr,d5
		cmpi.l	#16,d5
		ble.b	GF_rws7

		cmpi.l	#GF_WAVE_SPHERE_TIME-16,d5
		blt.b	GF_rws8
		subi.l	#GF_WAVE_SPHERE_TIME,d5
		neg.l	d5
GF_rws7
		move.l	GF_Palette1,a0
		move.w	#240-1,d7
		bsr.w	GF_FadePhase
GF_rws8
		move.l	GF_WAVE_SPHERE,a0
		move.w	o_RotX(a0),d0
		addi.w	#GF_WAVE_SPHERE_ROTX_SPEED,d0
		bpl.b	GF_rws1
		add.w	#72,d0
		bra.b	GF_rws1a
GF_rws1
		cmpi.w	#72,d0
		blt.b	GF_rws1a
		subi.w	#72,d0
GF_rws1a
		move.w	d0,o_RotX(a0)

		move.w	o_RotY(a0),d0
		addi.w	#GF_WAVE_SPHERE_ROTY_SPEED,d0
		bpl.b	GF_rws2
		add.w	#72,d0
		bra.b	GF_rws2a
GF_rws2
		cmpi.w	#72,d0
		blt.b	GF_rws2a
		subi.w	#72,d0
GF_rws2a
		move.w	d0,o_RotY(a0)

		move.w	o_RotZ(a0),d0
		addi.w	#GF_WAVE_SPHERE_ROTZ_SPEED,d0
		bpl.b	GF_rws3
		add.w	#72,d0
		bra.b	GF_rws3a
GF_rws3
		cmpi.w	#72,d0
		blt.b	GF_rws3a
		subi.w	#72,d0
GF_rws3a
		move.w	d0,o_RotZ(a0)

		move.w	GF_Light1+lt_RotX,d0
		addi.w	#GF_WAVE_SPHERE_L_ROTX_SPEED,d0
		bpl.b	GF_rws4
		add.w	#72,d0
		bra.b	GF_rws4a
GF_rws4
		cmpi.w	#72,d0
		blt.b	GF_rws4a
		subi.w	#72,d0
GF_rws4a
		move.w	d0,GF_Light1+lt_RotX

		move.w	GF_Light1+lt_RotY,d0
		addi.w	#GF_WAVE_SPHERE_L_ROTY_SPEED,d0
		bpl.b	GF_rws5
		add.w	#72,d0
		bra.b	GF_rws5a
GF_rws5
		cmpi.w	#72,d0
		blt.b	GF_rws5a
		subi.w	#72,d0
GF_rws5a
		move.w	d0,GF_Light1+lt_RotY

		move.w	GF_Light1+lt_RotZ,d0
		addi.w	#GF_WAVE_SPHERE_L_ROTZ_SPEED,d0
		bpl.b	GF_rws6
		add.w	#72,d0
		bra.b	GF_rws6a
GF_rws6
		cmpi.w	#72,d0
		blt.b	GF_rws6a
		subi.w	#72,d0
GF_rws6a
		move.w	d0,GF_Light1+lt_RotZ

		subq.l	#1,GF_Cntr
		bpl.w	GF_rws_Loop0

		lea	GF_World,a0
		bsr.w	GF_FreeWorld

		moveq	#1,d0
GF_rws0
		rts


; ---------------------------------------------------------------------------

GF_TORUS_ROTX_SPEED	=	1
GF_TORUS_ROTY_SPEED	=	1
GF_TORUS_ROTZ_SPEED	=	-1

GF_TORUS_L_ROTX_SPEED	=	-1
GF_TORUS_L_ROTY_SPEED	=	1
GF_TORUS_L_ROTZ_SPEED	=	-1

GF_TORUS_TIME	=	80

GF_RotateTorus
		lea	GF_World,a0
		move.w	#1-1,w_ObjectsNumber(a0)
		move.l	GF_TORUS,GF_ObjectsList
		move.l	#NULL,GF_ObjectsList+4

		move.w	#0,GF_Light1+lt_RotX
		move.w	#0,GF_Light1+lt_RotY
		move.w	#0,GF_Light1+lt_RotZ

		move.l	GF_TORUS,a1
		move.w	#60,o_RotX(a1)
		move.w	#10,o_RotY(a1)
		move.w	#30,o_RotZ(a1)

		bsr.w	GF_InitWorld
		tst.b	d0
		beq.w	GF_rt0

		move.l	GF_Texts+8,a0
		bsr.w	GF_CopyText

		move.l	GF_Background2,GF_Background
		bsr.w	GF_ClearChunky

		move.l	GF_Palette0,a0
		lea	224*4(a0),a1
		move.l	GF_BPalette2,a2
		moveq	#16-1,d7
GF_rt_Loop1
		move.l	(a2)+,(a1)+
		dbra	d7,GF_rt_Loop1

		move.l	#GF_TORUS_TIME,GF_Cntr
GF_rt_Loop0
		lea	CUSTOM,a5
		WaitBlitter

		bsr.w	GF_RenderWorld

		move.l	GF_Chunky,a0
		lea	48+68*GF_CWIDTH(a0),a0
		move.l	GF_PlanesRender,a1
		lea	4+GF_WIDTH_B*30*8(a1),a1
		bsr.w	GF_ChunkyToPlanar

		bsr.w	GF_ClearChunky

		bsr.w	GF_SwitchView

		move.l	GF_Cntr,d5
		cmpi.l	#16,d5
		ble.b	GF_rt7

		cmpi.l	#GF_TORUS_TIME-16,d5
		blt.b	GF_rt8
		subi.l	#GF_TORUS_TIME,d5
		neg.l	d5
GF_rt7
		move.l	GF_Palette0,a0
		move.w	#240-1,d7
		bsr.w	GF_FadePhase
GF_rt8
		move.l	GF_TORUS,a0
		move.w	o_RotX(a0),d0
		addi.w	#GF_TORUS_ROTX_SPEED,d0
		bpl.b	GF_rt1
		add.w	#72,d0
		bra.b	GF_rt1a
GF_rt1
		cmpi.w	#72,d0
		blt.b	GF_rt1a
		subi.w	#72,d0
GF_rt1a
		move.w	d0,o_RotX(a0)

		move.w	o_RotY(a0),d0
		addi.w	#GF_TORUS_ROTY_SPEED,d0
		bpl.b	GF_rt2
		add.w	#72,d0
		bra.b	GF_rt2a
GF_rt2
		cmpi.w	#72,d0
		blt.b	GF_rt2a
		subi.w	#72,d0
GF_rt2a
		move.w	d0,o_RotY(a0)

		move.w	o_RotZ(a0),d0
		addi.w	#GF_TORUS_ROTZ_SPEED,d0
		bpl.b	GF_rt3
		add.w	#72,d0
		bra.b	GF_rt3a
GF_rt3
		cmpi.w	#72,d0
		blt.b	GF_rt3a
		subi.w	#72,d0
GF_rt3a
		move.w	d0,o_RotZ(a0)

		move.w	GF_Light1+lt_RotX,d0
		addi.w	#GF_TORUS_L_ROTX_SPEED,d0
		bpl.b	GF_rt4
		add.w	#72,d0
		bra.b	GF_rt4a
GF_rt4
		cmpi.w	#72,d0
		blt.b	GF_rt4a
		subi.w	#72,d0
GF_rt4a
		move.w	d0,GF_Light1+lt_RotX

		move.w	GF_Light1+lt_RotY,d0
		addi.w	#GF_TORUS_L_ROTY_SPEED,d0
		bpl.b	GF_rt5
		add.w	#72,d0
		bra.b	GF_rt5a
GF_rt5
		cmpi.w	#72,d0
		blt.b	GF_rt5a
		subi.w	#72,d0
GF_rt5a
		move.w	d0,GF_Light1+lt_RotY

		move.w	GF_Light1+lt_RotZ,d0
		addi.w	#GF_TORUS_L_ROTZ_SPEED,d0
		bpl.b	GF_rt6
		add.w	#72,d0
		bra.b	GF_rt6a
GF_rt6
		cmpi.w	#72,d0
		blt.b	GF_rt6a
		subi.w	#72,d0
GF_rt6a
		move.w	d0,GF_Light1+lt_RotZ

		subq.l	#1,GF_Cntr
		bpl.w	GF_rt_Loop0

		lea	GF_World,a0
		bsr.w	GF_FreeWorld

		moveq	#1,d0
GF_rt0
		rts


; ---------------------------------------------------------------------------

GF_CHOPPER_ROTX_SPEED	=	1
GF_CHOPPER_ROTY_SPEED	=	-1
GF_CHOPPER_ROTZ_SPEED	=	1

GF_CHOPPER_L_ROTX_SPEED	=	1
GF_CHOPPER_L_ROTY_SPEED	=	-1
GF_CHOPPER_L_ROTZ_SPEED	=	-1

GF_CHOPPER_TIME	=	100

GF_RotateChopper
		lea	GF_World,a0
		move.w	#2-1,w_ObjectsNumber(a0)
		move.l	GF_CHOPHAND,GF_ObjectsList
		move.l	GF_CHOPHEAD,GF_ObjectsList+4
		move.l	#NULL,GF_ObjectsList+8

		move.w	#0,GF_Light1+lt_RotX
		move.w	#0,GF_Light1+lt_RotY
		move.w	#0,GF_Light1+lt_RotZ

		move.l	GF_CHOPHEAD,a1
		move.w	#10,o_RotX(a1)
		move.w	#60,o_RotY(a1)
		move.w	#40,o_RotZ(a1)

		move.l	GF_CHOPHAND,a1
		move.w	#10,o_RotX(a1)
		move.w	#60,o_RotY(a1)
		move.w	#40,o_RotZ(a1)

		bsr.w	GF_InitWorld
		tst.b	d0
		beq.w	GF_rc0

		move.l	GF_Texts+12,a0
		bsr.w	GF_CopyText

		move.l	GF_Background3,GF_Background
		bsr.w	GF_ClearChunky

		move.l	GF_Palette3,a0
		lea	224*4(a0),a1
		move.l	GF_BPalette3,a2
		moveq	#16-1,d7
GF_rc_Loop1
		move.l	(a2)+,(a1)+
		dbra	d7,GF_rc_Loop1

		move.l	#GF_CHOPPER_TIME,GF_Cntr
GF_rc_Loop0
		lea	CUSTOM,a5
		WaitBlitter

		bsr.w	GF_RenderWorld

		move.l	GF_Chunky,a0
		lea	48+68*GF_CWIDTH(a0),a0
		move.l	GF_PlanesRender,a1
		lea	4+GF_WIDTH_B*30*8(a1),a1
		bsr.w	GF_ChunkyToPlanar

		bsr.w	GF_ClearChunky

		bsr.w	GF_SwitchView

		move.l	GF_Cntr,d5
		cmpi.l	#16,d5
		ble.b	GF_rc7

		cmpi.l	#GF_CHOPPER_TIME-16,d5
		blt.b	GF_rc8
		subi.l	#GF_CHOPPER_TIME,d5
		neg.l	d5
GF_rc7
		move.l	GF_Palette3,a0
		move.w	#240-1,d7
		bsr.w	GF_FadePhase
GF_rc8
		move.l	GF_CHOPHAND,a0
		move.l	GF_CHOPHEAD,a1
		move.w	o_RotX(a0),d0
		addi.w	#GF_CHOPPER_ROTX_SPEED,d0
		bpl.b	GF_rc1
		add.w	#72,d0
		bra.b	GF_rc1a
GF_rc1
		cmpi.w	#72,d0
		blt.b	GF_rc1a
		subi.w	#72,d0
GF_rc1a
		move.w	d0,o_RotX(a0)
		move.w	d0,o_RotX(a1)

		move.w	o_RotY(a0),d0
		addi.w	#GF_CHOPPER_ROTY_SPEED,d0
		bpl.b	GF_rc2
		add.w	#72,d0
		bra.b	GF_rc2a
GF_rc2
		cmpi.w	#72,d0
		blt.b	GF_rc2a
		subi.w	#72,d0
GF_rc2a
		move.w	d0,o_RotY(a0)
		move.w	d0,o_RotY(a1)

		move.w	o_RotZ(a0),d0
		addi.w	#GF_CHOPPER_ROTZ_SPEED,d0
		bpl.b	GF_rc3
		add.w	#72,d0
		bra.b	GF_rc3a
GF_rc3
		cmpi.w	#72,d0
		blt.b	GF_rc3a
		subi.w	#72,d0
GF_rc3a
		move.w	d0,o_RotZ(a0)
		move.w	d0,o_RotZ(a1)

		move.w	GF_Light1+lt_RotX,d0
		addi.w	#GF_CHOPPER_L_ROTX_SPEED,d0
		bpl.b	GF_rc4
		add.w	#72,d0
		bra.b	GF_rc4a
GF_rc4
		cmpi.w	#72,d0
		blt.b	GF_rc4a
		subi.w	#72,d0
GF_rc4a
		move.w	d0,GF_Light1+lt_RotX

		move.w	GF_Light1+lt_RotY,d0
		addi.w	#GF_CHOPPER_L_ROTY_SPEED,d0
		bpl.b	GF_rc5
		add.w	#72,d0
		bra.b	GF_rc5a
GF_rc5
		cmpi.w	#72,d0
		blt.b	GF_rc5a
		subi.w	#72,d0
GF_rc5a
		move.w	d0,GF_Light1+lt_RotY

		move.w	GF_Light1+lt_RotZ,d0
		addi.w	#GF_CHOPPER_L_ROTZ_SPEED,d0
		bpl.b	GF_rc6
		add.w	#72,d0
		bra.b	GF_rc6a
GF_rc6
		cmpi.w	#72,d0
		blt.b	GF_rc6a
		subi.w	#72,d0
GF_rc6a
		move.w	d0,GF_Light1+lt_RotZ

		subq.l	#1,GF_Cntr
		bpl.w	GF_rc_Loop0

		lea	GF_World,a0
		bsr.w	GF_FreeWorld

		moveq	#1,d0
GF_rc0
		rts

; ---------------------------------------------------------------------------

GF_HEAD_ROTX_SPEED	=	1
GF_HEAD_ROTY_SPEED	=	-1
GF_HEAD_ROTZ_SPEED	=	-1

GF_HEAD_L_ROTX_SPEED	=	-1
GF_HEAD_L_ROTY_SPEED	=	1
GF_HEAD_L_ROTZ_SPEED	=	-1

GF_HEAD_TIME	=	80

GF_RotateHead
		lea	GF_World,a0
		move.w	#3-1,w_ObjectsNumber(a0)
		move.l	GF_HEAD,GF_ObjectsList
		move.l	GF_HEAD_BASE,GF_ObjectsList+4
		move.l	GF_GLASSES,GF_ObjectsList+8

		move.w	#0,GF_Light1+lt_RotX
		move.w	#10,GF_Light1+lt_RotY
		move.w	#0,GF_Light1+lt_RotZ

		move.l	GF_HEAD,a3
		move.l	GF_HEAD_BASE,a1
		move.l	GF_GLASSES,a2

		move.w	#0,o_RotX(a3)
		move.w	#0,o_RotY(a3)
		move.w	#36,o_RotZ(a3)

		move.w	#0,o_RotX(a1)
		move.w	#0,o_RotY(a1)
		move.w	#36,o_RotZ(a1)

		move.w	#0,o_RotX(a2)
		move.w	#0,o_RotY(a2)
		move.w	#36,o_RotZ(a2)

		bsr.w	GF_InitWorld
		tst.b	d0
		beq.w	GF_rh0

		bsr.w	GF_ScaleHead

		move.l	GF_Texts+16,a0
		bsr.w	GF_CopyText

		move.l	GF_Background4,GF_Background
		bsr.w	GF_ClearChunky

		move.l	GF_Palette4,a0
		lea	224*4(a0),a1
		move.l	GF_BPalette4,a2
		moveq	#16-1,d7
GF_rh_Loop1
		move.l	(a2)+,(a1)+
		dbra	d7,GF_rh_Loop1

		move.l	#GF_HEAD_TIME,GF_Cntr
GF_rh_Loop0
		lea	CUSTOM,a5
		WaitBlitter

		bsr.w	GF_RenderWorld

		move.l	GF_Chunky,a0
		lea	48+68*GF_CWIDTH(a0),a0
		move.l	GF_PlanesRender,a1
		lea	4+GF_WIDTH_B*30*8(a1),a1
		bsr.w	GF_ChunkyToPlanar

		bsr.w	GF_ClearChunky

		bsr.w	GF_SwitchView

		move.l	GF_Cntr,d5
		cmpi.l	#8,d5
		ble.b	GF_rh7

		cmpi.l	#GF_HEAD_TIME-8,d5
		blt.b	GF_rh8
		subi.l	#GF_HEAD_TIME,d5
		neg.l	d5
GF_rh7
		add.w	d5,d5
		move.l	GF_Palette4,a0
		move.w	#240-1,d7
		bsr.w	GF_FadePhase
GF_rh8
		move.l	GF_HEAD,a0
		move.l	GF_HEAD_BASE,a1
		move.l	GF_GLASSES,a2

		move.w	o_RotX(a0),d0
		addi.w	#GF_HEAD_ROTX_SPEED,d0
		bpl.b	GF_rh1
		add.w	#72,d0
		bra.b	GF_rh1a
GF_rh1
		cmpi.w	#72,d0
		blt.b	GF_rh1a
		subi.w	#72,d0
GF_rh1a
		move.w	d0,o_RotX(a0)
		move.w	d0,o_RotX(a1)
		move.w	d0,o_RotX(a2)

		move.w	o_RotY(a0),d0
		addi.w	#GF_HEAD_ROTY_SPEED,d0
		bpl.b	GF_rh2
		add.w	#72,d0
		bra.b	GF_rh2a
GF_rh2
		cmpi.w	#72,d0
		blt.b	GF_rh2a
		subi.w	#72,d0
GF_rh2a
		move.w	d0,o_RotY(a0)
		move.w	d0,o_RotY(a1)
		move.w	d0,o_RotY(a2)

		move.w	o_RotZ(a0),d0
		addi.w	#GF_HEAD_ROTZ_SPEED,d0
		bpl.b	GF_rh3
		add.w	#72,d0
		bra.b	GF_rh3a
GF_rh3
		cmpi.w	#72,d0
		blt.b	GF_rh3a
		subi.w	#72,d0
GF_rh3a
		move.w	d0,o_RotZ(a0)
		move.w	d0,o_RotZ(a1)
		move.w	d0,o_RotZ(a2)

		move.w	GF_Light1+lt_RotX,d0
		addi.w	#GF_HEAD_L_ROTX_SPEED,d0
		bpl.b	GF_rh4
		add.w	#72,d0
		bra.b	GF_rh4a
GF_rh4
		cmpi.w	#72,d0
		blt.b	GF_rh4a
		subi.w	#72,d0
GF_rh4a
		move.w	d0,GF_Light1+lt_RotX

		move.w	GF_Light1+lt_RotY,d0
		addi.w	#GF_HEAD_L_ROTY_SPEED,d0
		bpl.b	GF_rh5
		add.w	#72,d0
		bra.b	GF_rh5a
GF_rh5
		cmpi.w	#72,d0
		blt.b	GF_rh5a
		subi.w	#72,d0
GF_rh5a
		move.w	d0,GF_Light1+lt_RotY

		move.w	GF_Light1+lt_RotZ,d0
		addi.w	#GF_HEAD_L_ROTZ_SPEED,d0
		bpl.b	GF_rh6
		add.w	#72,d0
		bra.b	GF_rh6a
GF_rh6
		cmpi.w	#72,d0
		blt.b	GF_rh6a
		subi.w	#72,d0
GF_rh6a
		move.w	d0,GF_Light1+lt_RotZ

		subq.l	#1,GF_Cntr
		bpl.w	GF_rh_Loop0

		lea	GF_World,a0
		bsr.w	GF_FreeWorld

		moveq	#1,d0
GF_rh0
		rts

; ---------------------------------------------------------------------------

GF_GuruSection
		move.l	GF_GuruPalette,a0
		move.w	#32-1,d7
		jsr	SetPalette

		move.w	#$c000,bplcon3+CUSTOM
		move.w	#$0f00,color+31*2+CUSTOM

		lea	CUSTOM,a5
		WaitBlitter

		move.l	GF_GuruScreen,bltapt(a5)
		move.l	GF_PlanesDisplay,a0
		lea	4+GF_WIDTH_B*30*8(a0),a0
		move.l	a0,bltdpt(a5)
		move.l	#$09f00000,bltcon0(a5)
		move.l	#$ffffffff,bltafwm(a5)
		move.l	#20,bltamod(a5)
		move.w	#(119*8)<<6+10,bltsize(a5)

		move.l	GF_Texts+20,a0
		bsr.w	GF_CopyText

		move.w	#49,GF_Cntr
		move.w	IntFlag,d0
GF_gs_Loop0
		cmp.w	IntFlag,d0
		beq.b	GF_gs_Loop0

		move.l	#GF_InterruptSection,UserInt

		rts

GF_GuruSection2
		move.w	IntFlag,d0
GF_gs_Loop2
		cmp.w	IntFlag,d0
		beq.b	GF_gs_Loop2

		move.l	#NoneCode,UserInt

		moveq	#15,d5
GF_gs_Loop1
		move.l	GF_GuruPalette,a0
		move.w	#20,d7
		bsr.w	GF_FadePhase

		move.w	d5,d0
		lsl.w	#8,d0
		move.w	#$c000,bplcon3+CUSTOM
		move.w	d0,color+31*2+CUSTOM

		bsr.w	GF_InterruptSection
		moveq	#0,d0
		jsr	Wait

		dbra	d5,GF_gs_Loop1

		rts

GF_InterruptSection

		subq.w	#1,GF_Cntr
		bpl.b	GF_is0

		move.l	GF_GuruPalette,a0
		move.l	GF_GuruPalette2,a1

		move.l	13*4(a1),d0
		eor.l	d0,13*4(a0)
		move.l	14*4(a1),d0
		eor.l	d0,14*4(a0)
		move.l	15*4(a1),d0
		eor.l	d0,15*4(a0)
		move.l	16*4(a1),d0
		eor.l	d0,16*4(a0)
		move.l	17*4(a1),d0
		eor.l	d0,17*4(a0)
		move.l	18*4(a1),d0
		eor.l	d0,18*4(a0)
		move.l	19*4(a1),d0
		eor.l	d0,19*4(a0)
		move.l	20*4(a1),d0
		eor.l	d0,20*4(a0)

		move.l	GF_GuruPalette,a0
		move.w	#20,d7
		jsr	SetPalette

		move.w	#49,GF_Cntr
GF_is0

		rts


; ===========================================================================
; Procedure:	GF_SetmemPtrs
; Function:	Set pointers to allocated memory blocks
; In:
;	none
; Out:
;	none
; Crash regs:
;	a0
; ===========================================================================

GF_SetMemPtrs
		move.l	GF_MemEntryPtr,a0
		lea	14+2(a0),a0

		move.l	(a0),GF_CopperList
		move.l	1*8(a0),GF_PlanesRender
		move.l	2*8(a0),GF_Chunky
		move.l	3*8(a0),GF_PaletteAux

		rts

GF_SetMemPtrs2
		move.l	GF_MemEntryPtr2,a0
		lea	14+2(a0),a0

		move.l	(a0),GF_HGouraudBuffer
		move.l	1*8(a0),GF_SinPtrTable
		move.l	2*8(a0),GF_PerspTable
		move.l	3*8(a0),GF_PointerBuffer

		rts


; ===========================================================================
; Procedure:	GF_InitView
; Function:	Initialize view
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

GF_InitView
		lea	CUSTOM,a5

		WaitBlitter
		move.l	GF_PlanesDisplay,bltapt(a5)
		move.l	GF_PlanesRender,bltdpt(a5)
		move.l	#$09f00000,bltcon0(a5)
		move.l	#$ffffffff,bltafwm(a5)
		move.w	#0,bltamod(a5)
		move.w	#0,bltdmod(a5)
		move.w	#((GF_HEIGHT*4)<<6)+GF_WIDTH_W*2,bltsize(a5)
		WaitBlitter

		move.l	#$02110000,bplcon0(a5)
		move.w	#$0000,bplcon2(a5)
		move.w	#$0000,bplcon4(a5)

		move.w	#GF_WIDTH_B*7-8,bpl1mod(a5)
		move.w	#GF_WIDTH_B*7-8,bpl2mod(a5)

		move.w	#3,fmode(a5)

		SetView	GF_HOFFSET,GF_VOFFSET,GF_WIDTH,GF_HEIGHT,LORES

		move.l	GF_CopperList,a0

		move.l	a0,GF_CopperDisplay

		move.l	GF_PlanesDisplay,d0	; first CL
		moveq	#GF_DEPTH-1,d7
		moveq	#GF_WIDTH_B,d1
		jsr	SetCopperBplPtrs

		move.l	#-2,(a0)+		; end of first CL

		move.l	a0,GF_CopperRender

		move.l	GF_PlanesRender,d0	; second CL
		moveq	#GF_DEPTH-1,d7
		moveq	#GF_WIDTH_B,d1
		jsr	SetCopperBplPtrs

		move.l	#-2,(a0)		; end of second CL

		move.l	GF_CopperDisplay,cop1lc(a5)
		move.w	d0,copjmp1(a5)

		rts


; ===========================================================================
; Procedure:	GF_SwitchView
; Function:	Switch view display and render
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

GF_SwitchView
		lea	CUSTOM,a5

		move.l	GF_PlanesDisplay,a0
		move.l	GF_PlanesRender,a1
		move.l	a0,GF_PlanesRender
		move.l	a1,GF_PlanesDisplay

		move.l	GF_CopperDisplay,a0
		move.l	GF_CopperRender,a1
		move.l	a0,GF_CopperRender
		move.l	a1,GF_CopperDisplay

GF_sv_wait	move.l	vposr(a5),d0
		andi.l	#$0001ff00,d0
		cmpi.l	#$00012d00,d0
		bne.b	GF_sv_wait

		move.l	a1,cop1lc(a5)
		move.w	d0,copjmp1(a5)

		rts


; ===========================================================================
; Procedure:	GF_ClearChunky
; Function:	Clear chunky buffer
; In:
;	none
; Out:
;	none
; Crash regs:
;	a5
; ===========================================================================

GF_ClearChunky
		move.l	GF_Chunky,a0
		lea	68*GF_CWIDTH+48(a0),a0
		move.l	GF_Background,a1

		moveq	#119-1,d7
GF_cc_Loop2
		moveq	#160/4-1,d6
GF_cc_Loop1
		move.l	(a1)+,(a0)+

		dbra	d6,GF_cc_Loop1

		lea	256-160(a0),a0

		dbra	d7,GF_cc_Loop2

		rts

; ===========================================================================
; Procedure:	GT_ClearScreen
; Function:	Clear screen (on monitor)
; In:
;	none
; Out:
;	none
; Crash regs:
;	a5
; ===========================================================================

GT_ClearScreen
		lea	CUSTOM,a5

		WaitBlitter

		move.l	GF_PlanesDisplay,a0
		lea	4+GF_WIDTH_B*30*8(a0),a0
		move.l	a0,bltdpt(a5)
		move.l	#$01000000,bltcon0(a5)
		move.w	#GF_WIDTH_B-GF_WWIDTH_B,bltdmod(a5)
		move.w	#GF_WHEIGHT*8*64+GF_WWIDTH_W,bltsize(a5)

		WaitBlitter

		move.l	GF_PlanesRender,a0
		lea	4+GF_WIDTH_B*30*8(a0),a0
		move.l	a0,bltdpt(a5)
;		move.l	#$01000000,bltcon0(a5)
;		move.w	#GF_WIDTH_B-GF_WWIDTH_B,bltdmod(a5)
		move.w	#GF_WHEIGHT*8*64+GF_WWIDTH_W,bltsize(a5)

		rts


; ===========================================================================
; Procedure:	GF_CalcLine
; Function:	Calculate and interpolate line to buffer
; In:
;	a1.l	pointer to LINE structure
; Out:
;	none
; Crash regs:
;	d0-d7/a4-a6
; ===========================================================================

GF_CalcLine	movem.l	a0-a3,-(sp)

		move.l	l_Point1(a1),a2
		move.l	l_Point2(a1),a3

		move.w	p2d_Y(a3),d0
		sub.w	p2d_Y(a2),d0
		beq.w	GF_cl3
		bpl.b	GF_cl0
		neg.w	d0
		exg	a2,a3
GF_cl0
		move.w	d0,l_DYLength(a1)

		move.l	GF_DivTable,a0

		moveq	#0,d1
		move.w	p2d_X(a3),d1
		sub.w	p2d_X(a2),d1
		bpl.b	GF_cl1
		moveq	#-1,d5
		neg.w	d1
		lsl.w	#8,d1
		move.b	d0,d1
		move.w	(a0,d1.l*4),a5
		move.w	2(a0,d1.l*4),d1
		neg.w	d1
		bra.b	GF_cl2
GF_cl1
		moveq	#1,d5
		lsl.w	#8,d1
		move.b	d0,d1
		move.w	(a0,d1.l*4),a5
		move.w	2(a0,d1.l*4),d1
GF_cl2
		move.w	p2d_Y+1(a2),d2
		move.b	p2d_X+1(a2),d2
		move.w	d2,l_StartPos(a1)

		moveq	#0,d4
		move.w	p2d_Bright(a2),d3
		move.w	p2d_Bright(a3),d4
		sub.w	d3,d4
		bpl.b	GF_cl5
		moveq	#-1,d6
		neg.w	d4
		lsl.w	#8,d4
		move.b	d0,d4
		move.w	(a0,d4.l*4),a3
		move.w	2(a0,d4.l*4),d4
		neg.w	d4
		bra.b	GF_cl6
GF_cl5
		moveq	#1,d6
		lsl.w	#8,d4
		move.b	d0,d4
		move.w	(a0,d4.l*4),a3
		move.w	2(a0,d4.l*4),d4
GF_cl6
		move.l	l_Buffer(a1),a2
		move.w	#0,a6
		moveq	#0,d7
		move.w	d0,a4
GF_cl_Loop
		move.w	d2,(a2)+
		move.w	d3,(a2)+

		add.b	d1,d2
		add.w	a5,a6
		cmpa.w	a4,a6
		blt.b	GF_cl4
		sub.w	a4,a6
		add.b	d5,d2
GF_cl4
		add.w	d4,d3
		add.w	a3,d7
		cmp.w	a4,d7
		blt.b	GF_cl7
		sub.w	a4,d7
		add.w	d6,d3
GF_cl7
		addi.w	#$0100,d2

		dbra	d0,GF_cl_Loop

		bset.b	#LB_LINECALC,l_Flags+1(a1)

		movem.l	(sp)+,a0-a3
		rts

GF_cl3
		move.w	p2d_Y+1(a2),d2
		move.b	p2d_X+1(a2),d2
		cmp.b	p2d_X+1(a3),d2
		ble.b	GF_cl8
		move.b	p2d_X+1(a3),d2
GF_cl8
		move.w	d2,l_StartPos(a1)

		bset.b	#LB_HORIZLINE,l_Flags+1(a1)

		bset.b	#LB_LINECALC,l_Flags+1(a1)

		movem.l	(sp)+,a0-a3
		rts


; ===========================================================================
; Procedure:	GF_HGouraud
; Function:	Calculate horizonthal Gouraud shading
; In:
;	d3.w	length
;	d4.w	from...
;	d5.w	...to
; Out:
;	none
; Crash regs:
;	none
; ===========================================================================

GF_HGouraud
		move.l	GF_HGouraudBuffer,a0

		tst.w	d3
		beq.b	GF_hg0
		sub.w	d4,d5
		bpl.b	GF_hg1
		neg.w	d5
		lsl.w	#8,d5
		move.b	d3,d5
		move.w	2(a1,d5.l*4),d7
		move.w	(a1,d5.l*4),d5

		moveq	#0,d1
		move.w	d3,d6
GF_hg_Loop1
		move.b	d4,(a0)+
		sub.b	d7,d4
		add.w	d5,d1
		cmp.w	d3,d1
		blt.b	GF_hg4
		sub.w	d3,d1
		subq.b	#1,d4
GF_hg4
		dbra	d6,GF_hg_Loop1

		move.l	GF_HGouraudBuffer,a0

		rts

GF_hg1
		lsl.w	#8,d5
		move.b	d3,d5
		move.w	2(a1,d5.l*4),d7
		move.w	(a1,d5.l*4),d5

		moveq	#0,d1
		move.w	d3,d6
GF_hg_Loop0
		move.b	d4,(a0)+
		add.b	d7,d4
		add.w	d5,d1
		cmp.w	d3,d1
		blt.b	GF_hg3
		sub.w	d3,d1
		addq.b	#1,d4
GF_hg3
		dbra	d6,GF_hg_Loop0

		move.l	GF_HGouraudBuffer,a0

		rts

GF_hg0
		move.b	d4,(a0)

		rts


; ===========================================================================
; Procedure:	GF_RenderFace
; Function:	Render face (triangle)
; In:
;	a0.l	pointer to FACE structure
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

GF_RenderFace	movem.l	d7/a0/a5,-(sp)

;		btst.b	#FB_RENDER,f_Flags+1(a0)	; checked before
;		beq.w	GF_rf9				; deep sorting

		move.l	f_Line3(a0),a1
		btst.b	#LB_LINECALC,l_Flags+1(a1)
		bne.b	GF_rf0
		bsr.w	GF_CalcLine
GF_rf0
		movea.l	a1,a3
		move.l	f_Line2(a0),a1
		btst.b	#LB_LINECALC,l_Flags+1(a1)
		bne.b	GF_rf1
		bsr.w	GF_CalcLine
GF_rf1
		movea.l	a1,a2
		move.l	f_Line1(a0),a1
		btst.b	#LB_LINECALC,l_Flags+1(a1)
		bne.b	GF_rf2
		bsr.w	GF_CalcLine
GF_rf2
		btst.b	#LB_HORIZLINE,l_Flags+1(a1)
		bne.w	GF_rf6

		btst.b	#LB_HORIZLINE,l_Flags+1(a2)
		bne.b	GF_rf14

		btst.b	#LB_HORIZLINE,l_Flags+1(a3)
		bne.b	GF_rf5

		move.w	l_StartPos(a1),d0
		cmp.w	l_StartPos(a2),d0
		beq.b	GF_rf5
		cmp.w	l_StartPos(a3),d0
		bne.b	GF_rf6
GF_rf14
		exg	a2,a3
		exg	a1,a2
		bra.b	GF_rf5
GF_rf6
		exg	a1,a2
		exg	a2,a3
GF_rf5
		move.w	l_StartPos(a1),d0
		cmp.w	l_StartPos(a2),d0
		beq.b	GF_rf11
		exg	a1,a2
GF_rf11
		move.l	l_Buffer(a1),a5
		move.l	l_Buffer(a2),a6
		move.l	GF_Chunky,a4
		moveq	#0,d2

		move.w	l_DYLength(a1),d0
		move.w	l_DYLength(a2),d1
		cmp.w	d1,d0
		beq.w	GF_rf8
		bgt.w	GF_rf7
		move.l	GF_DivTable,a1
		moveq	#0,d5
GF_rf_Loop1
		move.w	(a5)+,d3
		move.w	(a6)+,d2
		sub.w	d2,d3
	IFNE	SAFE
		bmi.w	GF_rf_safe
	ENDC
		move.w	(a5)+,d5
		move.w	(a6)+,d4
		bsr.w	GF_HGouraud
GF_rf_Loop0
		move.b	(a0)+,(a4,d2.l)
		addq.w	#1,d2
		dbra	d3,GF_rf_Loop0

		dbra	d0,GF_rf_Loop1

		move.w	l_DYLength(a3),d0
		move.l	l_Buffer(a3),a5
		addq.w	#4,a5
		subq.w	#1,d0
GF_rf_Loop2
		move.w	(a5)+,d3
		move.w	(a6)+,d2
		sub.w	d2,d3
	IFNE	SAFE
		bmi.w	GF_rf_safe
	ENDC
		move.w	(a5)+,d5
		move.w	(a6)+,d4
		bsr.w	GF_HGouraud
GF_rf_Loop3
		move.b	(a0)+,(a4,d2.l)
		addq.w	#1,d2
		dbra	d3,GF_rf_Loop3

		dbra	d0,GF_rf_Loop2
GF_rf9
		movem.l	(sp)+,d7/a0/a5
		rts

GF_rf7
		move.l	GF_DivTable,a1
		moveq	#0,d5
		move.w	d1,d0
GF_rf_Loop6
		move.w	(a5)+,d3
		move.w	(a6)+,d2
		sub.w	d2,d3
	IFNE	SAFE
		bmi.w	GF_rf_safe
	ENDC
		move.w	(a5)+,d5
		move.w	(a6)+,d4
		bsr.w	GF_HGouraud
GF_rf_Loop7
		move.b	(a0)+,(a4,d2.l)
		addq.w	#1,d2
		dbra	d3,GF_rf_Loop7

		dbra	d0,GF_rf_Loop6

		move.w	l_DYLength(a3),d0
		move.l	l_Buffer(a3),a6
		addq.w	#4,a6
		subq.w	#1,d0
GF_rf_Loop4
		move.w	(a5)+,d3
		move.w	(a6)+,d2
		sub.w	d2,d3
	IFNE	SAFE
		bmi.w	GF_rf_safe
	ENDC
		move.w	(a5)+,d5
		move.w	(a6)+,d4
		bsr.w	GF_HGouraud
GF_rf_Loop5
		move.b	(a0)+,(a4,d2.l)
		addq.w	#1,d2
		dbra	d3,GF_rf_Loop5

		dbra	d0,GF_rf_Loop4
GF_rf10
		movem.l	(sp)+,d7/a0/a5
		rts

GF_rf8
		move.l	GF_DivTable,a1
		moveq	#0,d5
GF_rf_Loop8
		move.w	(a5)+,d3
		move.w	(a6)+,d2
		sub.w	d2,d3
	IFNE	SAFE
		bmi.w	GF_rf_safe
	ENDC
		move.w	(a5)+,d5
		move.w	(a6)+,d4
		bsr.w	GF_HGouraud
GF_rf_Loop9
		move.b	(a0)+,(a4,d2.l)
		addq.w	#1,d2
		dbra	d3,GF_rf_Loop9

		dbra	d0,GF_rf_Loop8

		movem.l	(sp)+,d7/a0/a5
		rts


	IFNE	SAFE
GF_rf_safe	
		move.w	#0,bplcon3+CUSTOM
		move.w	#$f00,color+CUSTOM
		movem.l	(sp)+,d7/a0/a5
		rts
	ENDC


; ===========================================================================
; Procedure:	GF_RenderWorld
; Function:	Render all objects
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

GF_RenderWorld
		lea	GF_World,a6

		move.w	w_LightsNumber(a6),d7
		move.l	w_LightsList(a6),a3
		move.l	GF_SinPtrTable(pc),a5
GF_rw_Loop0					; rotate light
		move.l	(a3)+,a4
		move.w	lt_RotX(a4),d0
		move.l	(a5,d0.w*4),a0

		move.w	lt_RotY(a4),d0
		move.l	(a5,d0.w*4),a1

		move.w	lt_RotZ(a4),d0
		move.l	(a5,d0.w*4),a2

		move.w	#0,d0
		move.w	#0,d1
		move.b	(18*256,a2,d0.w),d2
		add.b	(a2,d1.w),d2
		move.b	(18*256,a2,d1.w),d1
		sub.b	(a2,d0.w),d1
		ext.w	d2			; x
		ext.w	d1			; y
		move.w	#FMUL,d0
		move.b	(18*256,a1,d2.w),d3
		sub.b	(a1,d0.w),d3
		move.b	(a1,d2.w),d2
		add.b	(18*256,a1,d0.w),d2
		ext.w	d3			; x
		ext.w	d2			; z
		move.b	(18*256,a0,d1.w),d0
		add.b	(a0,d2.w),d0
		move.b	(18*256,a0,d2.w),d2
		sub.b	(a0,d1.w),d2
		ext.w	d0			; y
		ext.w	d2			; z

		move.w	d3,lt_VectorX(a4)
		move.w	d0,lt_VectorY(a4)
		move.w	d2,lt_VectorZ(a4)

		lea	lt_SIZEOF(a4),a4

		dbra	d7,GF_rw_Loop0

		move.l	w_DepthBuffer(a6),GF_DepthBuffer
		move.w	#0,GF_VisibleFacesNumber

		move.l	w_ObjectsList(a6),a0
GF_rw_Loop1
		move.l	(a0)+,a6
		tst.l	a6
		beq.b	GF_rw3
		move.l	a0,-(sp)
		bsr.b	GF_RenderObject
		move.l	(sp)+,a0
		add.w	d6,GF_VisibleFacesNumber

		bra.b	GF_rw_Loop1
GF_rw3
		lea	GF_World,a6
		move.w	GF_VisibleFacesNumber,d6
		subq.w	#1,d6
		move.w	d6,d7
		bmi.b	GF_rw4
		beq.b	GF_rw5

		move.l	w_DepthBuffer(a6),a0
GF_rw_Loop9
		move.w	#-32768,d0
		move.w	d6,d1
GF_rw_Loop8
		cmp.w	db_DepthZ+2(a0,d1.w*8),d0
		bge.b	GF_rw6
		move.w	db_DepthZ+2(a0,d1.w*8),d0
		move.w	d1,d2
GF_rw6
		dbra	d1,GF_rw_Loop8

		move.l	db_Address(a0,d2.w*8),d3
		move.l	db_Address(a0),db_Address(a0,d2.w*8)
		move.l	db_DepthZ(a0),db_DepthZ(a0,d2.w*8)
		move.l	d3,(a0)+
		move.l	d0,(a0)+
		dbra	d6,GF_rw_Loop9
GF_rw5
		move.l	w_DepthBuffer(a6),a5
GF_rw_Loop7					; render all visible face
		move.l	(a5),a0
		bsr.w	GF_RenderFace
		addq.w	#db_SIZEOF,a5

		dbra	d7,GF_rw_Loop7
GF_rw4						; all done
		rts


; ===========================================================================
; Procedure:	GF_RenderObject
; Function:	Render object
; In:
;	a6.l	pointer to OBJECT
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

GF_RenderObject
		move.l	GF_SinPtrTable(pc),a5

		move.w	o_RotX(a6),d0
		move.l	(a5,d0.w*4),a0

		move.w	o_RotY(a6),d0
		move.l	(a5,d0.w*4),a1

		move.w	o_RotZ(a6),d0
		move.l	(a5,d0.w*4),a2

		move.w	o_PointsNumber(a6),d7
		move.l	o_Points3D(a6),a5
		move.l	o_Points2D(a6),a4
		move.l	GF_PerspTable,a3
GF_ro_Loop0					; rotate points
		move.w	p3d_X(a5),d0
		move.w	p3d_Y(a5),d1
		move.b	(18*256,a2,d0.w),d2
		add.b	(a2,d1.w),d2
		move.b	(18*256,a2,d1.w),d1
		sub.b	(a2,d0.w),d1
		ext.w	d2			; x
		ext.w	d1			; y
		move.w	p3d_Z(a5),d0
		move.b	(18*256,a1,d2.w),d3
		sub.b	(a1,d0.w),d3
		move.b	(a1,d2.w),d2
		add.b	(18*256,a1,d0.w),d2
		ext.w	d3			; x
		ext.w	d2			; z
		move.b	(18*256,a0,d1.w),d0
		add.b	(a0,d2.w),d0
		move.b	(18*256,a0,d2.w),d2
		sub.b	(a0,d1.w),d2
		ext.w	d0			; y
		ext.w	d2			; z

		move.w	d2,p2d_DepthZ(a4)

		addi.w	#127,d2
		lsl.w	#8,d2
		andi.l	#$0000ff00,d2

		move.b	d3,d2
		move.b	(a3,d2.l),p2d_X+1(a4)
		move.b	d0,d2
		move.b	(a3,d2.l),p2d_Y+1(a4)

		lea	p3d_SIZEOF(a5),a5
		addq.w	#p2d_SIZEOF,a4

		dbra	d7,GF_ro_Loop0

		move.w	o_NormalsNumber(a6),d7
		move.l	o_Normals(a6),a5
		move.l	o_CalcNormals(a6),a4
GF_ro_Loop3					; rotate normal
		move.w	n_VectorX(a5),d0
		move.w	n_VectorY(a5),d1
		move.b	(18*256,a2,d0.w),d2
		add.b	(a2,d1.w),d2
		move.b	(18*256,a2,d1.w),d1
		sub.b	(a2,d0.w),d1
		ext.w	d2			; x
		ext.w	d1			; y
		move.w	n_VectorZ(a5),d0
		move.b	(18*256,a1,d2.w),d3
		sub.b	(a1,d0.w),d3
		move.b	(a1,d2.w),d2
		add.b	(18*256,a1,d0.w),d2
		ext.w	d3			; x
		ext.w	d2			; z
		move.b	(18*256,a0,d1.w),d0
		add.b	(a0,d2.w),d0
		move.b	(18*256,a0,d2.w),d2
		sub.b	(a0,d1.w),d2
		ext.w	d0			; y
		ext.w	d2			; z

		move.w	d3,cn_VectorX(a4)
		move.w	d0,cn_VectorY(a4)
		move.w	d2,cn_VectorZ(a4)

		addq.w	#n_SIZEOF,a5
		addq.w	#cn_SIZEOF,a4

		dbra	d7,GF_ro_Loop3

		move.l	o_CalcNormals(a6),a0
		lea	GF_Light1,a1
		moveq	#0,d0
		move.w	lt_VectorX+1(a1),d0
		moveq	#0,d1
		move.w	lt_VectorY+1(a1),d1
		moveq	#0,d2
		move.w	lt_VectorZ+1(a1),d2
		move.l	o_LightTable(a6),a2
		adda.w	#4096,a2
		move.l	GF_MulsTable,a1
		move.w	o_NormalsNumber(a6),d7
GF_ro_Loop5					; calc light of point (I)
		move.b	cn_VectorX+1(a0),d0
		move.w	(a1,d0.l*2),d3
		move.b	cn_VectorY+1(a0),d1
		add.w	(a1,d1.l*2),d3
		move.b	cn_VectorZ+1(a0),d2
		add.w	(a1,d2.l*2),d3
		move.b	(a2,d3.w),cn_Bright+1(a0)

		addq.w	#cn_SIZEOF,a0
		dbra	d7,GF_ro_Loop5

		move.l	o_Points3D(a6),a0
		move.l	o_Points2D(a6),a1
		move.w	o_PointsNumber(a6),d7
GF_ro_Loop6					; calc light of point (II)
		move.l	p3d_Normal(a0),a2
		move.w	cn_Bright(a2),p2d_Bright(a1)

		lea	p3d_SIZEOF(a0),a0
		addq.w	#p2d_SIZEOF,a1

		dbra	d7,GF_ro_Loop6

		move.l	o_Lines(a6),a0
		move.w	o_LinesNumber(a6),d7
GF_ro_Loop2
		move.w	#0,l_Flags(a0)
		lea	l_SIZEOF(a0),a0
		dbra	d7,GF_ro_Loop2

		move.l	o_Faces(a6),a0
		move.l	GF_DepthBuffer,a5
		moveq	#0,d6
		move.w	o_FacesNumber(a6),d7
GF_ro_Loop1					; check visible face
		btst.b	#FB_RENDER,f_Flags+1(a0)
		beq.b	GF_ro0
		move.l	f_Line1(a0),a2
		move.l	l_Point1(a2),a1
		move.l	l_Point2(a2),a2
		move.l	f_Line2(a0),a4
		move.l	l_Point1(a4),a3
		cmp.l	a2,a3
		bne.b	GF_ro1
		move.l	l_Point2(a4),a3
GF_ro1
		move.w	p2d_X(a1),d0
		sub.w	p2d_X(a2),d0
		move.w	p2d_Y(a3),d1
		sub.w	p2d_Y(a2),d1
		muls	d1,d0
		move.w	p2d_X(a2),d1
		sub.w	p2d_X(a3),d1
		move.w	p2d_Y(a2),d2
		sub.w	p2d_Y(a1),d2
		muls	d2,d1
		cmp.l	d1,d0
		ble.b	GF_ro0
		move.w	p2d_DepthZ(a1),d0
		add.w	p2d_DepthZ(a2),d0
		add.w	p2d_DepthZ(a3),d0
		move.l	a0,(a5)+
		move.l	d0,(a5)+
		addq.w	#1,d6
GF_ro0
		lea	f_SIZEOF(a0),a0
		dbra	d7,GF_ro_Loop1

		move.l	a5,GF_DepthBuffer

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_FreeWorld
; Function:	Free memory allocated to Gouraud World
; In:
;	a0.l	pointer to WORLD
; Out:
;	none
; -----------------------------------------------------------------------------

GF_FreeWorld
		move.l	a0,a3

		move.l	4.w,a6
		move.l	w_LineBuffer(a3),a1
		tst.l	a1
		beq.b	GF_fw1
		move.l	w_LBSize(a3),d0
		jsr	_LVOFreeMem(a6)
GF_fw1
		move.l	w_DepthBuffer(a3),a1
		tst.l	a1
		beq.b	GF_fw2
		move.l	w_DBSize(a3),d0
		jsr	_LVOFreeMem(a6)
GF_fw2
		move.w	w_ObjectsNumber(a3),d7
		move.l	w_ObjectsList(a3),a5
GF_fw_Loop0
		move.l	(a5)+,a4

		move.l	o_Points2D(a4),a1
		tst.l	a1
		beq.b	GF_fw0
		move.w	o_PointsNumber(a4),d0
		addq.w	#1,d0
		mulu	#p2d_SIZEOF,d0
		jsr	_LVOFreeMem(a6)
GF_fw0
		move.l	o_CalcNormals(a4),a1
		tst.l	a1
		beq.b	GF_fw3
		move.w	o_NormalsNumber(a4),d0
		addq.w	#1,d0
		mulu	#cn_SIZEOF,d0
		jsr	_LVOFreeMem(a6)
GF_fw3
		move.l	o_LightTable(a4),a1
		tst.l	a1
		beq.b	GF_fw4
		move.l	#4096*2+1,d0
		jsr	_LVOFreeMem(a6)
GF_fw4
		dbra	d7,GF_fw_Loop0

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_InitWorld
; Function:	Initialize Gouraud World
; In:
;	a0.l	pointer to WORLD
; Out:
;	none
; -----------------------------------------------------------------------------

GF_InitWorld
		move.l	a0,a3
		move.w	w_ObjectsNumber(a3),d7
		move.l	w_ObjectsList(a3),a5
		moveq	#0,d0
		moveq	#0,d6
GF_iw_Loop1
		move.l	(a5)+,a4
		add.w	o_LinesNumber(a4),d0
		addq.w	#1,d0
		add.w	o_FacesNumber(a4),d6
		addq.w	#1,d6
		dbra	d7,GF_iw_Loop1

		mulu	#LINE_BUFFER_SIZE*4,d0
		move.l	d0,w_LBSize(a3)

		move.l	4.w,a6
		moveq	#MEMF_PUBLIC,d1
		jsr	_LVOAllocMem(a6)
		move.l	d0,w_LineBuffer(a3)
		beq.w	GF_iw0

		move.w	d6,d0
		mulu	#db_SIZEOF,d0
		move.l	d0,w_DBSize(a3)

		moveq	#MEMF_PUBLIC,d1
		jsr	_LVOAllocMem(a6)
		move.l	d0,w_DepthBuffer(a3)
		beq.w	GF_iw0

		move.l	w_LineBuffer(a3),a2
		move.w	w_ObjectsNumber(a3),d7
		move.l	w_ObjectsList(a3),a5
GF_iw_Loop0
		move.l	(a5)+,a4

		move.l	o_Points3D(a4),d0
		add.l	a4,d0
		move.l	d0,o_Points3D(a4)
		move.l	o_Lines(a4),d0
		add.l	a4,d0
		move.l	d0,o_Lines(a4)
		move.l	o_Faces(a4),d0
		add.l	a4,d0
		move.l	d0,o_Faces(a4)
		move.l	o_Normals(a4),d0
		add.l	a4,d0
		move.l	d0,o_Normals(a4)

		move.w	o_PointsNumber(a4),d0
		addq.w	#1,d0
		mulu	#p2d_SIZEOF,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		jsr	_LVOAllocMem(a6)
		move.l	d0,o_Points2D(a4)
		beq.w	GF_iw0

		move.w	o_NormalsNumber(a4),d0
		addq.w	#1,d0
		mulu	#cn_SIZEOF,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		jsr	_LVOAllocMem(a6)
		move.l	d0,o_CalcNormals(a4)
		beq.w	GF_iw0

		move.l	#4096*2+1,d0
		moveq	#MEMF_PUBLIC,d1
		jsr	_LVOAllocMem(a6)
		move.l	d0,o_LightTable(a4)
		beq.w	GF_iw0

		move.l	o_Points3D(a4),a3
		move.l	o_CalcNormals(a4),a1
		move.w	o_PointsNumber(a4),d6
GF_iw_Loop2
		move.l	p3d_Normal(a3),d0
		mulu	#cn_SIZEOF,d0
		add.l	a1,d0
		move.l	d0,p3d_Normal(a3)

		lea	p3d_SIZEOF(a3),a3

		dbra	d6,GF_iw_Loop2

		move.l	o_Lines(a4),a3
		move.l	o_Points2D(a4),a1
		move.w	o_LinesNumber(a4),d6
GF_iw_Loop3
		move.l	l_Point1(a3),d0
		mulu	#p2d_SIZEOF,d0
		add.l	a1,d0
		move.l	d0,l_Point1(a3)

		move.l	l_Point2(a3),d0
		mulu	#p2d_SIZEOF,d0
		add.l	a1,d0
		move.l	d0,l_Point2(a3)

		move.l	a2,l_Buffer(a3)
		lea	LINE_BUFFER_SIZE*4(a2),a2

		lea	l_SIZEOF(a3),a3

		dbra	d6,GF_iw_Loop3

		move.l	o_Faces(a4),a3
		move.l	o_Lines(a4),a1
		move.w	o_FacesNumber(a4),d6
GF_iw_Loop4
		move.l	f_Line1(a3),d0
		mulu	#l_SIZEOF,d0
		add.l	a1,d0
		move.l	d0,f_Line1(a3)

		move.l	f_Line2(a3),d0
		mulu	#l_SIZEOF,d0
		add.l	a1,d0
		move.l	d0,f_Line2(a3)

		move.l	f_Line3(a3),d0
		mulu	#l_SIZEOF,d0
		add.l	a1,d0
		move.l	d0,f_Line3(a3)

		lea	f_SIZEOF(a3),a3

		dbra	d6,GF_iw_Loop4

		move.w	o_ColorsNumber(a4),d3
		move.w	o_ColorsOffset(a4),d2
		move.l	o_LightTable(a4),a1
		move.w	#-4096,d5
		move.w	#4096*2,d6
GF_iw_Loop5
		move.w	d5,d4
		muls	d3,d4
		asr.l	#8,d4
		asr.l	#4,d4
		bpl.b	GF_iw1
		moveq	#0,d4
GF_iw1
		add.b	d2,d4
		move.b	d4,(a1)+

		addq.w	#1,d5

		dbra	d6,GF_iw_Loop5

		dbra	d7,GF_iw_Loop0

		moveq	#1,d0
		rts
GF_iw0
		lea	GF_World,a0
		bsr.w	GF_FreeWorld

		moveq	#0,d0
		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_InitPerspTable
; Function:	Initialize PerspTable
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

GF_InitPerspTable
		move.l	GF_PerspTable,a0

		move.w	#GF_OBSERVER_Z,d0
GF_ipt_Loop0
		moveq	#0,d1
GF_ipt_Loop1
		move.w	#GF_OBSERVER_Z,d2
		move.b	d1,d3
		ext.w	d3
		muls	d3,d2
		divs	d0,d2
		addi.w	#GF_CWIDTH2,d2
		move.b	d2,(a0)+

		addq.w	#1,d1
		cmpi.w	#255,d1
		ble.b	GF_ipt_Loop1

		addq.w	#1,d0
		cmpi.w	#255+GF_OBSERVER_Z,d0
		ble.b	GF_ipt_Loop0

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_InitMulsTable
; Function:	Initialize MulsTable
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

GF_InitMulsTable
		move.l	GF_MulsTable,a0

		moveq	#0,d7
GF_imt_Loop0
		moveq	#0,d6
GF_imt_Loop1
		move.b	d7,d0
		ext.w	d0
		move.b	d6,d1
		ext.w	d1
		muls	d1,d0
		move.w	d0,(a0)+

		addq.b	#1,d6
		bne.b	GF_imt_Loop1

		addq.b	#1,d7
		bne.b	GF_imt_Loop0

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_InitDivTable
; Function:	Initialize DivTable
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

GF_InitDivTable
		move.l	GF_DivTable,a0

		moveq	#0,d0
GF_idt_Loop1
		moveq	#1,d1
		addq.w	#4,a0
GF_idt_Loop0
		move.l	d0,d2
		divu	d1,d2
		move.l	d2,(a0)+

		addq.w	#1,d1
		cmpi.w	#255,d1
		ble.b	GF_idt_Loop0

		addq.w	#1,d0
		cmpi.w	#255,d0
		ble.b	GF_idt_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_InitSinPtrTable
; Function:	Initialize SinPtrTable
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

GF_InitSinPtrTable
		move.l	GF_SinPtrTable(pc),a0
		move.l	GF_SinusTable,d0
		addi.l	#128,d0
		move.w	#89,d1

GF_ispt_Loop	move.l	d0,(a0)+
		addi.l	#256,d0
		dbra	d1,GF_ispt_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_InitBackgrounds
; Function:	Initialize backgrounds (0-3)
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

GF_InitBackgrounds
		move.l	GF_Background0,a0
		move.w	#GF_WWIDTH*GF_WHEIGHT/4-1,d7
GF_ib_Loop0
		addi.l	#$e0e0e0e0,(a0)+
		dbra	d7,GF_ib_Loop0

		move.l	GF_Background1,a0
		move.w	#GF_WWIDTH*GF_WHEIGHT/4-1,d7
GF_ib_Loop1
		addi.l	#$e0e0e0e0,(a0)+
		dbra	d7,GF_ib_Loop1

		move.l	GF_Background2,a0
		move.w	#GF_WWIDTH*GF_WHEIGHT/4-1,d7
GF_ib_Loop2
		addi.l	#$e0e0e0e0,(a0)+
		dbra	d7,GF_ib_Loop2

		move.l	GF_Background3,a0
		move.w	#GF_WWIDTH*GF_WHEIGHT/4-1,d7
GF_ib_Loop3
		addi.l	#$e0e0e0e0,(a0)+
		dbra	d7,GF_ib_Loop3

		move.l	GF_Background4,a0
		move.w	#GF_WWIDTH*GF_WHEIGHT/4-1,d7
GF_ib_Loop4
		addi.l	#$e0e0e0e0,(a0)+
		dbra	d7,GF_ib_Loop4

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_ScaleHead
; Function:	Scale head object (HEAD, HEAD_BASE and GLASSES)
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

GF_SCALE_HEAD	=	20

GF_ScaleHead
		move.l	GF_HEAD,a1
		move.l	o_Points3D(a1),a0
		move.w	o_PointsNumber(a1),d7
GF_sh_Loop0
		move.w	p3d_X(a0),d0
		muls	#GF_SCALE_HEAD,d0
		divs	#100,d0
		move.w	d0,p3d_X(a0)

		move.w	p3d_Y(a0),d0
		muls	#GF_SCALE_HEAD,d0
		divs	#100,d0
		move.w	d0,p3d_Y(a0)

		move.w	p3d_Z(a0),d0
		muls	#GF_SCALE_HEAD,d0
		divs	#100,d0
		move.w	d0,p3d_Z(a0)

		lea	p3d_SIZEOF(a0),a0
		dbra	d7,GF_sh_Loop0

		move.l	GF_HEAD_BASE,a1
		move.l	o_Points3D(a1),a0
		move.w	o_PointsNumber(a1),d7
GF_sh_Loop1
		move.w	p3d_X(a0),d0
		muls	#GF_SCALE_HEAD,d0
		divs	#100,d0
		move.w	d0,p3d_X(a0)

		move.w	p3d_Y(a0),d0
		muls	#GF_SCALE_HEAD,d0
		divs	#100,d0
		move.w	d0,p3d_Y(a0)

		move.w	p3d_Z(a0),d0
		muls	#GF_SCALE_HEAD,d0
		divs	#100,d0
		move.w	d0,p3d_Z(a0)

		lea	p3d_SIZEOF(a0),a0
		dbra	d7,GF_sh_Loop1

		move.l	GF_GLASSES,a1
		move.l	o_Points3D(a1),a0
		move.w	o_PointsNumber(a1),d7
GF_sh_Loop2
		move.w	p3d_X(a0),d0
		muls	#GF_SCALE_HEAD,d0
		divs	#100,d0
		move.w	d0,p3d_X(a0)

		move.w	p3d_Y(a0),d0
		muls	#GF_SCALE_HEAD,d0
		divs	#100,d0
		move.w	d0,p3d_Y(a0)

		move.w	p3d_Z(a0),d0
		muls	#GF_SCALE_HEAD,d0
		divs	#100,d0
		move.w	d0,p3d_Z(a0)

		lea	p3d_SIZEOF(a0),a0
		dbra	d7,GF_sh_Loop2

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_RefreshPointer
; Function:	Refresh area under mouse pointer
; In:
;	d0.w	x position
;	d1.w	y position
; Out:
;	none
; -----------------------------------------------------------------------------

GF_RefreshPointer
		move.l	GF_PlanesDisplay,a2
		move.l	GF_PointerBuffer,a3
		lea	4+GF_WIDTH_B*30*8(a2),a2

		mulu	#GF_WIDTH_B*8,d1
		adda.l	d1,a2
		move.w	d0,d1
		lsr.w	#3,d1
		adda.w	d1,a2
		andi.w	#$0007,d0

		moveq	#6*8-1,d7
GF_rp_Loop1
		move.w	(a3)+,(a2)

		lea	GF_WIDTH_B(a2),a2

		dbra	d7,GF_rp_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_RenderPointer
; Function:	Render mouse pointer
; In:
;	d0.w	x position
;	d1.w	y position
; Out:
;	none
; -----------------------------------------------------------------------------

GF_RenderPointer
		move.l	GF_Pointer,a0
		move.l	GF_PointerMask,a1
		move.l	GF_PlanesDisplay,a2
		move.l	GF_PointerBuffer,a3
		lea	4+GF_WIDTH_B*30*8(a2),a2

		mulu	#GF_WIDTH_B*8,d1
		adda.l	d1,a2
		move.w	d0,d1
		lsr.w	#3,d1
		adda.w	d1,a2
		andi.w	#$0007,d0

		moveq	#6*8-1,d7
GF_rp_Loop0
		move.w	(a0)+,d1
		lsr.w	d0,d1
		move.w	(a1)+,d2
		ror.w	d0,d2
		move.w	(a2),d3
		move.w	d3,(a3)+
		and.w	d2,d3
		or.w	d1,d3
		move.w	d3,(a2)

		lea	GF_WIDTH_B(a2),a2

		dbra	d7,GF_rp_Loop0

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_DisplayGLogo
; Function:	Display gouraud logo
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

GF_DisplayGLogo
		move.w	#16-1,d7
		sub.l	a0,a0
		jsr	SetPalette

		lea	CUSTOM,a5
		WaitBlitter

		move.l	GF_GouraudLogo,bltapt(a5)
		move.l	GF_PlanesDisplay,a0
		lea	4+GF_WIDTH_B*30*8(a0),a0
		move.l	a0,bltdpt(a5)
		move.l	#$09f00000,bltcon0(a5)
		move.l	#$ffffffff,bltafwm(a5)
		move.l	#20,bltamod(a5)
		move.w	#(119*8)<<6+10,bltsize(a5)

		WaitBlitter

		moveq	#15,d7
GF_dgl_Loop0
		move.w	d7,-(sp)

		moveq	#3,d0
		jsr	Wait

		move.w	#16,d5
		sub.w	d7,d5
		move.l	GF_GouraudPalette,a0
		move.w	#16-1,d7
		bsr	GF_FadePhase

		move.w	(sp)+,d7

		dbra	d7,GF_dgl_Loop0

		bsr.w	GF_InitPerspTable
		bsr.w	GF_InitDivTable
		bsr.w	GF_InitMulsTable

		moveq	#100,d0
		jsr	Wait

		moveq	#15,d5
GF_dgl_Loop1
		moveq	#2,d0
		jsr	Wait

		move.l	GF_GouraudPalette,a0
		move.w	#16-1,d7
		bsr	GF_FadePhase

		dbra	d5,GF_dgl_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_WBPhase
; Function:	Animate WB and Devpac
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

GF_WBPhase
		move.l	GF_PointerPalette,a0
		move.l	GF_Palette,a1
		lea	16*4(a1),a1

		moveq	#16-1,d7
GF_wb_Loop0
		move.l	(a0)+,(a1)+
		dbra	d7,GF_wb_Loop0

		move.l	GF_Palette,a0
		move.w	#32-1,d7
		jsr	SetPalette

		moveq	#0,d0
		move.w	d0,GF_MouseX
		moveq	#0,d1
		move.w	d1,GF_MouseY
		bsr.w	GF_RenderPointer

		move.l	GF_MouseMTable,a6
		move.w	(a6)+,d4
		subq.w	#1,d4
		move.w	d4,GF_MouseCntr
GF_wb_WaitLoop
		move.w	GF_MouseX,d0
		move.w	GF_MouseY,d1

		move.w	(a6)+,GF_MouseX
		move.w	(a6)+,GF_MouseY
		tst.w	GF_MouseY
		bpl.b	GF_wb0

		move.w	GF_ScreenCntr,d2
		cmpi.w	#26,d2
		beq.w	GF_wb_End

		addq.w	#1,GF_ScreenCntr

		lea	CUSTOM,a5
		WaitBlitter

		move.l	(GF_Screens,pc,d2.w*4),bltapt(a5)
		move.l	GF_PlanesDisplay,a0
		lea	4+GF_WIDTH_B*30*8(a0),a0
		move.l	a0,bltdpt(a5)
		move.l	#$09f00000,bltcon0(a5)
		move.l	#$ffffffff,bltafwm(a5)
		move.l	#20,bltamod(a5)
		move.w	#(119*8)<<6+10,bltsize(a5)

		move.l	(GF_SPalettes,pc,d2.w*4),a0
		move.w	#16-1,d7
		jsr	SetPalette

		WaitBlitter

		andi.w	#$7fff,GF_MouseY

		bra.b	GF_wb1
GF_wb0
		bsr.w	GF_RefreshPointer
GF_wb1
		move.w	GF_MouseX,d0
		move.w	GF_MouseY,d1
		bsr.w	GF_RenderPointer

		moveq	#0,d0
		jsr	Wait

		move.w	GF_MouseCntr,d4
		dbra	d4,GF_wb_WaitLoop
GF_wb_End
		rts

; -----------------------------------------------------------------------------
; Procedure:	GF_FadePhase
; Function:	Fade palette (one phase)
; In:
;	a0.l	pointer to 32bit palette
;	d5.l	fade phase (1/16)
;	d7.w	number of colors  -1
; Out:
;	none
; -----------------------------------------------------------------------------

GF_FadePhase
		move.w	#$0000,d0
		move.w	#$0200,d1
GF_fp_cheat
		lea	CUSTOM,a5
GF_fp_Loop1
		moveq	#31,d6
		cmpi.w	#32,d7
		bge.b	GF_fp0

		move.w	d7,d6
GF_fp0
		move.w	#color,d2
GF_fp_Loop0
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
		dbra	d6,GF_fp_Loop0

		addi.w	#$2000,d0
		addi.w	#$2000,d1

		tst.w	d7
		bpl.b	GF_fp_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	GF_CopyText
; Function:	Copy text right monitor
; In:
;	a0.l	pointer to text raw
; Out:
;	none
; -----------------------------------------------------------------------------

GF_CT		MACRO	; reg
		move.l	d0,7*40(\1)
		move.l	d0,6*40(\1)
		move.l	d0,4*40(\1)
		move.l	d0,3*40(\1)
		move.l	d0,2*40(\1)
		move.l	d0,40(\1)
		move.l	d0,(\1)+
		ENDM

GF_CopyText
		move.l	GF_PlanesDisplay,a1
		adda.w	#28+75*40*8,a1
		move.l	GF_PlanesRender,a2
		adda.w	#28+75*40*8,a2

		moveq	#40-1,d7
GF_ct_Loop
		move.l	(a0)+,d0
		GF_CT	a1
		GF_CT	a2
		move.l	(a0)+,d0
		GF_CT	a1
		GF_CT	a2
		move.l	(a0)+,d0
		GF_CT	a1
		GF_CT	a2

		lea	28+40*7(a1),a1
		lea	28+40*7(a2),a2

		dbra	d7,GF_ct_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	TF_InitPerspTable
; Function:	Initialize perspective table
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TF_InitPerspTable
		move.l	TF_PerspTableH,a0
		move.l	TF_PerspTableV,a1

		moveq	#-79,d0
TF_ipt_Loop1
		move.w	#255,d1
TF_ipt_Loop0
		move.b	d1,d2
		extb.l	d2
		addi.l	#TF_OBSERVER_Z,d2
		muls	d0,d2
		divs	#TF_OBSERVER_Z,d2
		move.w	d2,d3
		addi.w	#79,d2
		bmi.b	TF_ipt0
		cmpi.w	#160,d2
		blt.b	TF_ipt1
TF_ipt0
		move.w	#0,d2
TF_ipt1
		move.w	d2,(a0)+

		cmpi.w	#-59,d0
		blt.b	TF_ipt2
		cmpi.w	#59,d0
		bgt.b	TF_ipt2

		addi.w	#59,d3
		bmi.b	TF_ipt3
		cmpi.w	#119,d3
		blt.b	TF_ipt4
TF_ipt3
		move.w	#0,d3
TF_ipt4
		mulu	#160,d3
		move.w	d3,(a1)+
TF_ipt2
		subq.w	#1,d1
		bpl.b	TF_ipt_Loop0

		addq.w	#1,d0
		cmpi.w	#80,d0
		ble.b	TF_ipt_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	TF_TexturedFace
; Function:	Textured face with simple light sourceing
; In:
;	a0.l	Pointer to altitude map
;	a1.l	Pointer to texture
;	d0.w	height of texture
; Out:
;	none
; -----------------------------------------------------------------------------

TF_TexturedFace
		move.l	GF_Chunky,a2
		move.l	TF_PerspTableV,a3

		moveq	#0,d1
		moveq	#0,d3

		moveq	#GF_WHEIGHT-1,d7
TF_tf_Loop1
		move.l	TF_PerspTableH,a4
		move.w	#GF_WWIDTH-1,d6
TF_tf_Loop0
		move.b	(a0)+,d1
		sub.b	d0,d1
		bgt.b	TF_tf1

		move.b	(a1,d3.w),(a2)+
		bra.b	TF_tf2
TF_tf1
		move.w	(a4,d1.w*2),d2
		add.w	(a3,d1.w*2),d2
		tst.b	(a1,d2.w)
		bne.b	TF_tf0
		lsr.b	#1,d1
		add.b	#127,d1
TF_tf0
		addq.b	#1,d1
		move.b	d1,(a2)+
TF_tf2
		addq.w	#1,d3
		adda.w	#256*2,a4

		dbra	d6,TF_tf_Loop0

		adda.w	#256*2,a3

		dbra	d7,TF_tf_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	TF_TextureSection
; Function:	Textured face section
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

TF_TextureSection
		move.l	GF_Texts+6*4,a0
		bsr.w	GF_CopyText

		moveq	#0,d5
		moveq	#15,d6
TF_ts_Loop2
		movem.w	d5-d6,-(sp)

		move.l	GF_Palette5,a0
		move.w	#224-1,d7
		bsr.w	GF_FadePhase

		move.l	(TF_Heads),a0
		move.l	TF_BinTexture,a1
		move.w	TF_TxtPos,d0
		mulu	#160,d0
		adda.w	d0,a1
		move.w	#127,d0
		bsr.w	TF_TexturedFace
		move.l	GF_Chunky,a0
		move.l	GF_PlanesRender,a1
		lea	4+GF_WIDTH_B*30*8(a1),a1
		bsr.w	TF_ChunkyToPlanar

		bsr.w	GF_SwitchView

		addq.w	#1,TF_TxtPos
		cmpi.w	#99,TF_TxtPos
		blt.b	TF_ts4
		move.w	#0,TF_TxtPos
TF_ts4
		movem.w	(sp)+,d5-d6

		addq.w	#1,d5

		dbra	d6,TF_ts_Loop2

		move.l	#255,GF_Cntr
TF_ts_Loop1
		move.w	TF_TxtCntr,d0
		lea	TF_Heads,a0
		move.l	(a0,d0.w*4),a0
		move.l	TF_BinTexture,a1
		move.w	TF_TxtPos,d0
		mulu	#160,d0
		adda.w	d0,a1
		move.w	TF_TxtHeight,d0
		bsr.w	TF_TexturedFace
		move.l	GF_Chunky,a0
		move.l	GF_PlanesRender,a1
		lea	4+GF_WIDTH_B*30*8(a1),a1
		bsr.w	TF_ChunkyToPlanar

		bsr.w	GF_SwitchView

		addq.w	#1,TF_TxtCntr
		cmpi.w	#30,TF_TxtCntr
		blt.b	TF_ts0
		move.w	#0,TF_TxtCntr
TF_ts0
		move.w	TF_TxtHAdd,d0
		add.w	d0,TF_TxtHeight
		bpl.b	TF_ts1
		neg.w	d0
		move.w	d0,TF_TxtHAdd
		add.w	d0,TF_TxtHeight
		bra.b	TF_ts2
TF_ts1
		cmpi.w	#128,TF_TxtHeight
		blt.b	TF_ts2
		neg.w	d0
		move.w	d0,TF_TxtHAdd
		add.w	d0,TF_TxtHeight
TF_ts2
		addq.w	#1,TF_TxtPos
		cmpi.w	#99,TF_TxtPos
		blt.b	TF_ts3
		move.w	#0,TF_TxtPos
TF_ts3
		cmpi.l	#192,GF_Cntr
		bne.b	TF_ts8

		move.l	GF_Texts+7*4,a0
		bsr.w	GF_CopyText
		bra.w	TF_ts7
TF_ts8
		cmpi.l	#128,GF_Cntr
		bne.b	TF_ts6

		move.l	GF_Texts+8*4,a0
		bsr.w	GF_CopyText
		bra.w	TF_ts7
TF_ts6
		cmpi.l	#64,GF_Cntr
		bne.b	TF_ts7

		move.l	GF_Texts+9*4,a0
		bsr.w	GF_CopyText
TF_ts7
		subq.l	#1,GF_Cntr
		bpl.w	TF_ts_Loop1

		moveq	#15,d5
TF_ts_Loop3
		move.w	d5,-(sp)

		move.l	GF_Palette5,a0
		move.w	#224-1,d7
		bsr.w	GF_FadePhase

		move.l	(TF_Heads),a0
		move.l	TF_BinTexture,a1
		move.w	TF_TxtPos,d0
		mulu	#160,d0
		adda.w	d0,a1
		move.w	#127,d0
		bsr.w	TF_TexturedFace
		move.l	GF_Chunky,a0
		move.l	GF_PlanesRender,a1
		lea	4+GF_WIDTH_B*30*8(a1),a1
		bsr.w	TF_ChunkyToPlanar

		bsr.w	GF_SwitchView

		addq.w	#1,TF_TxtPos
		cmpi.w	#99,TF_TxtPos
		blt.b	TF_ts5
		move.w	#0,TF_TxtPos
TF_ts5
		move.w	(sp)+,d5

		dbra	d5,TF_ts_Loop3

		rts


; -----------------------------------------------------------------------------
; Procedure:	LS_InitPowerTable
; Function:	Initialize  power table for Light sourceing section
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

LS_InitPowerTable
		move.l	LS_PowerTable,a0

		moveq	#-127,d7
LS_ipt_Loop0
		move.w	d7,d0
		muls	d0,d0
		moveq	#-127,d6
LS_ipt_Loop1
		move.w	d6,d1
		muls	d1,d1
		add.w	d0,d1
		move.w	d1,(a0)+

		addq.w	#1,d6
		cmpi.w	#128,d6
		ble.b	LS_ipt_Loop1

		addq.w	#1,d7
		cmpi.w	#128,d7
		ble.b	LS_ipt_Loop0

		rts


; -----------------------------------------------------------------------------
; Procedure:	LS_LightSourceing
; Function:	Light sourceing
; In:
;	d0.w	light x position
;	d1.l	light y position
; Out:
;	none
; -----------------------------------------------------------------------------

LS_LightSourceing
		move.l	GF_Chunky,a0
		move.l	LS_PowerTable,a1
		move.l	LS_Power2Table,a2
		move.l	LS_SqrtTable,a3
		move.l	LS_HeadMap,a4

		addi.w	#127-GF_WWIDTH2,d0
		add.w	d0,d0

		addi.l	#127-GF_WHEIGHT2,d1
		lsl.l	#8,d1
		add.l	d1,d1
		adda.l	d1,a1

		moveq	#0,d2
		moveq	#0,d3

		moveq	#GF_WHEIGHT-1,d7
LS_ls_Loop0
		move.w	d0,d1
		move.w	#GF_WWIDTH-1,d6
LS_ls_Loop1
		move.b	(a4)+,d2
		beq.b	LS_ls0
		move.w	(a2,d2.w*2),d3
		add.w	(a1,d1.w),d3
		move.b	(a3,d3.l),d2
LS_ls0
		move.b	d2,(a0)+

		addq.w	#2,d1

		dbra	d6,LS_ls_Loop1

		lea	256*2(a1),a1

		dbra	d7,LS_ls_Loop0

		rts


; -----------------------------------------------------------------------------
; Procedure:	LS_RenderCandle
; Function:	Render candle on the chunky
; In:
;	d0.w	light x position
;	d1.l	light y position
;	d2.w	candle animation phase
; Out:
;	none
; -----------------------------------------------------------------------------

LS_RenderCandle
		lea	LS_Candle,a0
		move.l	(a0,d2.w*4),a0
		move.l	GF_Chunky,a1

		neg.w	d0
		neg.w	d1
		addi.w	#GF_WWIDTH2-3,d0
		addi.w	#GF_WHEIGHT2-7,d1
		move.w	d1,d2
		muls	#GF_WWIDTH,d2
		add.l	d2,a1

		subq.w	#1,d1
		moveq	#48-1,d7
LS_rc_Loop1
		addq.w	#1,d1
		bpl.b	LS_rc1
		addq.w	#7,a0
		bra.b	LS_rc3
LS_rc1
		cmpi.w	#GF_WHEIGHT,d1
		bge.b	LS_rc2

		move.w	d0,d2
		moveq	#7-1,d6
LS_rc_Loop0
		move.b	(a0)+,d3
		beq.b	LS_rc0
		move.b	d3,(a1,d2.w)
LS_rc0
		addq.w	#1,d2

		dbra	d6,LS_rc_Loop0
LS_rc3
		lea	GF_WWIDTH(a1),a1

		dbra	d7,LS_rc_Loop1
LS_rc2
		rts


; -----------------------------------------------------------------------------
; Procedure:	LS_LightSection
; Function:	Light sourceing section
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

LS_LightSection

		move.l	GF_Texts+10*4,a0
		bsr.w	GF_CopyText

		bsr.w	GT_ClearScreen

		move.l	LS_SqrtTable,a0

		move.w	#48387,d7
LS_Loop1
		moveq	#0,d0
		move.b	(a0),d0
		lsl.w	#2,d0
		cmpi.w	#223,d0
		blt.b	LS_0
		move.b	#222,d0
LS_0
		move.b	d0,(a0)+

		subq.w	#1,d7
		bne.b	LS_Loop1

		move.l	LS_Candle,a0
		move.w	#4*7*48-1,d7
LS_Loop3
		move.b	(a0)+,d0
		beq.b	LS_1
		addi.b	#224,-1(a0)
LS_1
		dbra	d7,LS_Loop3

		move.l	LS_BurnPalette,a0
		lea	224*4(a0),a1
		move.l	LS_CandlePalette,a2
		moveq	#16-1,d7
LS_Loop2
		move.l	(a2)+,(a1)+
		dbra	d7,LS_Loop2

		move.l	#$00ffff00,223*4(a0)

		WaitBlitter

		move.w	#224+16-1,d7
		jsr	SetPalette

		move.w	#0,LS_CandlePhase
		move.l	#-70,GF_Cntr
LS_Loop0
		moveq	#0,d0
		move.l	GF_Cntr,d1
		bmi.b	LS_3
		moveq	#0,d1
LS_3
		move.w	LS_CandlePhase,d2
		movem.l	d0-d2,-(sp)
		add.w	(LS_LightShift,pc,d2.w*4),d0
		add.w	(LS_LightShift+2,pc,d2.w*4),d1
		bsr.w	LS_LightSourceing
		movem.l	(sp)+,d0-d2
		bsr.w	LS_RenderCandle

		move.l	GF_Chunky,a0
		move.l	GF_PlanesRender,a1
		lea	4+GF_WIDTH_B*30*8(a1),a1
		bsr.w	TF_ChunkyToPlanar

		bsr.w	GF_SwitchView

		addq.w	#1,LS_CandlePhase
		andi.w	#$0003,LS_CandlePhase

		addq.l	#2,GF_Cntr
		cmpi.l	#50,GF_Cntr
		ble.b	LS_Loop0

		move.w	#0,LS_CandleMovePhase
LS_Loop4
		move.w	LS_CandleMovePhase,d2
		move.l	LS_CandleMoveTable,a0
		move.b	(a0,d2.w*2),d0
		ext.w	d0
		move.b	1(a0,d2.w*2),d1
		extb.l	d1
		move.w	LS_CandlePhase,d2
		movem.l	d0-d2,-(sp)
		add.w	(LS_LightShift,pc,d2.w*4),d0
		add.w	(LS_LightShift+2,pc,d2.w*4),d1
		bsr.w	LS_LightSourceing
		movem.l	(sp)+,d0-d2
		bsr.w	LS_RenderCandle

		move.l	GF_Chunky,a0
		move.l	GF_PlanesRender,a1
		lea	4+GF_WIDTH_B*30*8(a1),a1
		bsr.w	TF_ChunkyToPlanar

		bsr.w	GF_SwitchView

		addq.w	#1,LS_CandlePhase
		andi.w	#$0003,LS_CandlePhase

		addq.w	#3,LS_CandleMovePhase
		cmpi.w	#198,LS_CandleMovePhase
		bne.b	LS_4

		move.l	GF_Texts+11*4,a0
		bsr.w	GF_CopyText
LS_4
		cmpi.w	#400,LS_CandleMovePhase
		blt.w	LS_Loop4

		move.l	#50,GF_Cntr
LS_Loop5
		moveq	#0,d0
		moveq	#0,d1
		move.w	LS_CandlePhase,d2
		movem.l	d0-d2,-(sp)
		add.w	(LS_LightShift,pc,d2.w*4),d0
		add.w	(LS_LightShift+2,pc,d2.w*4),d1
		bsr.w	LS_LightSourceing
		movem.l	(sp)+,d0-d2
		bsr.w	LS_RenderCandle

		move.l	GF_Chunky,a0
		move.l	GF_PlanesRender,a1
		lea	4+GF_WIDTH_B*30*8(a1),a1
		bsr.w	TF_ChunkyToPlanar

		bsr.w	GF_SwitchView

		addq.w	#1,LS_CandlePhase
		andi.w	#$0003,LS_CandlePhase

		subq.l	#1,GF_Cntr
		bmi.b	LS_2

		move.l	GF_Cntr,d5
		cmpi.w	#15,d5
		bgt.b	LS_Loop5
		move.l	LS_BurnPalette,a0
		move.w	#224+16-1,d7
		bsr.w	GF_FadePhase

		bra.w	LS_Loop5
LS_2
		rts

; ---------------------------------------------------------------------------

		INCLUDE	"GTFace/GF_C2P.s"
		INCLUDE	"GTFace/TF_C2P.s"


; ---------------------------------------------------------------------------

		CNOP	0,2
GF_MemEntry	DCB.B	14
		DC.W	4
	DC.L	MEMF_CHIP,GF_DEPTH*8*2+4*2			; CopperList
	DC.L	MEMF_CHIP,GF_DEPTH*GF_PLANE_SIZE		; Planes1
	DC.L	MEMF_PUBLIC,256*256				; Chunky
	DC.L	MEMF_PUBLIC,32*4				; PaletteAux

GF_MemEntry2	DCB.B	14
		DC.W	4
	DC.L	MEMF_PUBLIC,256					; HGouraudBuffer
	DC.L	MEMF_PUBLIC,90*4				; SinPtrTable
	DC.L	MEMF_PUBLIC,256*256				; PerspTable
	DC.L	MEMF_PUBLIC,2*8*6				; PointerBuffer

GF_MemEntryPtr	DC.L	0
GF_MemEntryPtr2	DC.L	0

GF_CopperList	DC.L	0
GF_CopperDisplay	DC.L	0
GF_CopperRender	DC.L	0
GF_PlanesDisplay	DC.L	0
GF_PlanesRender	DC.L	0
GF_Chunky	DC.L	0
GF_Palette	DC.L	0
GF_PaletteAux	DC.L	0
GF_Palette0	DC.L	0
GF_Palette1	DC.L	0
GF_Palette2	DC.L	0
GF_Palette3	DC.L	0
GF_Palette4	DC.L	0
GF_Palette5	DC.L	0
GF_BPalette0	DC.L	0
GF_BPalette1	DC.L	0
GF_BPalette2	DC.L	0
GF_BPalette3	DC.L	0
GF_BPalette4	DC.L	0
GF_Background	DC.L	0
GF_Background0	DC.L	0
GF_Background1	DC.L	0
GF_Background2	DC.L	0
GF_Background3	DC.L	0
GF_Background4	DC.L	0
GF_HGouraudBuffer	DC.L	0
GF_SinPtrTable	DC.L	0
GF_SinusTable	DC.L	0
GF_PerspTable	DC.L	0
GF_DivTable	DC.L	0
GF_MulsTable	DC.L	0
GF_DepthBuffer	DC.L	0
GF_VisibleFacesNumber
		DC.W	0
GF_ScreenCntr	DC.W	0
GF_Cntr		DC.L	0

GF_Pointer	DC.L	0
GF_PointerMask	DC.L	0
GF_PointerPalette	DC.L	0
GF_PointerBuffer	DC.L	0
GF_MouseX	DC.W	0
GF_MouseY	DC.W	0
GF_MouseMTable	DC.L	0
GF_MouseCntr	DC.W	0
		CNOP	0,4

GF_Screens	DCB.L	26
GF_GouraudLogo	DC.L	0
GF_GuruScreen	DC.L	0

GF_SPalettes	DCB.L	26
GF_GouraudPalette
		DC.L	0
GF_GuruPalette	DC.L	0
GF_GuruPalette2	DC.L	0

GF_Texts	DCB.L	12

TF_Heads	DCB.L	30

TF_TxtCntr	DC.W	6

TF_BinTexture	DC.L	0
TF_PerspTableH	DC.L	0
TF_PerspTableV	DC.L	0
TF_TxtHeight	DC.W	127
TF_TxtHAdd	DC.W	-2
TF_TxtPos	DC.W	0

LS_BurnPalette	DC.L	0
LS_HeadMap	DC.L	0
LS_PowerTable	DC.L	0
LS_Power2Table	DC.L	0
LS_SqrtTable	DC.L	0
LS_Candle	DCB.L	4
LS_CandlePalette
		DC.L	0
LS_CandleMoveTable
		DC.L	0
LS_CandlePhase	DC.W	0
LS_CandleMovePhase
		DC.W	0
LS_LightShift	DC.W	0,0
		DC.W	0,-2
		DC.W	-2,-4
		DC.W	-1,-2

POINT3D		RSRESET
p3d_X		RS.W	1
p3d_Y		RS.W	1
p3d_Z		RS.W	1
p3d_Normal	RS.L	1
p3d_SIZEOF	RS.B	0

POINT2D		RSRESET
p2d_X		RS.W	1
p2d_Y		RS.W	1
p2d_DepthZ	RS.W	1
p2d_Bright	RS.W	1
p2d_SIZEOF	RS.B	0

LINE		RSRESET
l_Point1	RS.L	1
l_Point2	RS.L	1
l_StartPos	RS.W	1
l_DYLength	RS.W	1
l_Flags		RS.W	1
l_Buffer	RS.L	1
l_SIZEOF	RS.B	0

LB_LINECALC	=	0
LB_HORIZLINE	=	1

LINE_BUFFER_SIZE	=	40

FACE		RSRESET
f_Line1		RS.L	1
f_Line2		RS.L	1
f_Line3		RS.L	1
f_Flags		RS.W	1
f_SIZEOF	RS.B	0

FB_RENDER	=	0

NORMAL		RSRESET
n_VectorX	RS.W	1
n_VectorY	RS.W	1
n_VectorZ	RS.W	1
n_SIZEOF	RS.B	0

CALCNORMAL	RSRESET
cn_VectorX	RS.W	1
cn_VectorY	RS.W	1
cn_VectorZ	RS.W	1
cn_Bright	RS.W	1
cn_SIZEOF	RS.B	0

LIGHT		RSRESET
lt_RotX		RS.W	1
lt_RotY		RS.W	1
lt_RotZ		RS.W	1
lt_VectorX	RS.W	1
lt_VectorY	RS.W	1
lt_VectorZ	RS.W	1
lt_SIZEOF	RS.B	0

OBJECT		RSRESET
o_PosX		RS.W	1
o_PosY		RS.W	1
o_PosZ		RS.W	1
o_RotX		RS.W	1
o_RotY		RS.W	1
o_RotZ		RS.W	1
o_ColorsNumber	RS.W	1
o_ColorsOffset	RS.W	1
o_PointsNumber	RS.W	1
o_LinesNumber	RS.W	1
o_FacesNumber	RS.W	1
o_NormalsNumber	RS.W	1
o_Points3D	RS.L	1
o_Points2D	RS.L	1
o_Lines		RS.L	1
o_Faces		RS.L	1
o_Normals	RS.L	1
o_CalcNormals	RS.L	1
o_LightTable	RS.L	1
o_SIZEOF	RS.B	0

DEPTH_BUFFER	RSRESET
db_Address	RS.L	1
db_DepthZ	RS.L	1
db_SIZEOF	RS.B	0

WORLD		RSRESET
w_ObjectsList	RS.L	1
w_LightsList	RS.L	1
w_LineBuffer	RS.L	1
w_DepthBuffer	RS.L	1
w_ObjectsNumber	RS.W	1
w_LightsNumber	RS.W	1
w_LBSize	RS.L	1
w_DBSize	RS.L	1
w_SIZEOF	RS.B	0

FMUL		=	64

GF_World	DC.L	GF_ObjectsList,GF_LightsList,NULL,NULL
		DC.W	0,1-1
		DC.L	0,0

GF_ObjectsList	DC.L	NULL
		DC.L	NULL
		DC.L	NULL
		DC.L	NULL

GF_LightsList	DC.L	GF_Light1
		DC.L	NULL

GF_Light1	DC.W	0,0,0,0,0,0

GF_SPHERE	DC.L	0
GF_WAVE_SPHERE	DC.L	0
GF_TORUS	DC.L	0
GF_CHOPHAND	DC.L	0
GF_CHOPHEAD	DC.L	0

GF_HEAD		DC.L	0
GF_HEAD_BASE	DC.L	0
GF_GLASSES	DC.L	0


; ===========================================================================

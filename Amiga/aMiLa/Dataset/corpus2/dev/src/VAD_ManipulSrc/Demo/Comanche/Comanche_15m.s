; ===========================================================================
; Name:		Comanche
; File:		Comanche_xx.s
; Author:	Noe / Venus Art
; Copyright:	© 1995 by Venus Art
; ---------------------------------------------------------------------------
; History:
; 15.06.1995	first version
; 27.06.1995	new dimension based on VoxelTerain_33.s
; 29.06.1995	sky (28.06.1995 I thing) and IR scaner (EXCELLENCE!)
; 03.07.1995	auto moving

; ===========================================================================

COM_HOFFSET	=	$81
COM_VOFFSET	=	$2c+20
COM_WIDTH	=	320
COM_HEIGHT	=	128
COM_DEPTH	=	8
COM_BOARD_HEIGHT	=	90

COM_WIDTH_B	=	COM_WIDTH>>3
COM_WIDTH_W	=	COM_WIDTH>>4

COM_WIDTH2	=	COM_WIDTH>>1
COM_HEIGHT2	=	COM_HEIGHT>>1

COM_PLANE_SIZE	=	COM_WIDTH_B*(COM_HEIGHT+COM_BOARD_HEIGHT)

COM_MAP_WIDTH	=	256
COM_MAP_HEIGHT	=	256

COM_OBSERVER_DIST	=	30
COM_OBSERVER_Y	=	260
COM_OBSERVER_Z	=	100
COM_SKY_ALT	=	100

COM_TERAIN_WIDTH	=	320
COM_TERAIN_LINES	=	128
COM_TERAIN_HEIGHT	=	200

C2P_PLANE_SIZE	=	COM_PLANE_SIZE
C2P_CONV_NUM	=	COM_WIDTH/32*COM_HEIGHT

SIN_CONST	=	165		; 40
COS_CONST	=	196

MAX_ROTATE_SPEED	=	14
MAX_MOVE_SPEED	=	7
TURN_SPEED	=	2

; ---------------------------------------------------------------------------

		SECTION	Comanche_0,CODE

ComancheMax
		move.l	(a0)+,a1
		addq.w	#MAGIC_NUMBER,a1
		move.l	a1,COM_Palette
		adda.w	#1024,a1
		move.l	a1,COM_ColorToGray
		adda.w	#256,a1
		move.l	a1,COM_Maps
		adda.l	#131072,a1
		move.l	a1,COM_Sky
		adda.l	#65536,a1
		move.l	a1,COM_TurnTable
		adda.w	#19520,a1
		move.l	a1,COM_RayTable
		adda.l	#245760,a1
		move.l	a1,COM_MovingTable
		adda.w	#24000,a1
		move.l	a1,COM_Board_down
		adda.w	#28800,a1
		move.l	a1,COM_BoardPalette
		adda.w	#1024,a1
		move.l	a1,COM_MapCorrect

		move.l	(a0),a1
		addq.w	#MAGIC_NUMBER,a1
		move.l	a1,COM_Board_up
		adda.l	#40960,a1
		move.l	a1,COM_Board_up_mask
		adda.l	#40960,a1
		move.l	a1,COM_Board_map
		adda.l	#33216,a1
		move.l	a1,COM_Helicopter
		adda.w	#18560,a1
		move.l	a1,COM_Helicopter_mask
		adda.w	#18560,a1
		move.l	a1,COM_Rotor
		adda.w	#1856,a1
		move.l	a1,COM_Rotor_mask


		AllocMemBlocks	COM_MemEntry
		bne.w	COM_AllocMemError
		move.l	d0,COM_MemEntryPtr

		bsr.w	COM_SetMemPtrs

		move.l	#COM_EmptyCL,cop1lc+CUSTOM
		move.w	d0,copjmp1+CUSTOM

		suba.l	a0,a0
		move.w	#1<<COM_DEPTH-1,d7
		jsr	SetPalette

	IFEQ	DEBUG

		lea	CUSTOM,a5

		move.w	dmaconr(a5),DMA_old
		move.w	#$71f0,dmacon(a5)
		move.w	#$83c0,dmacon(a5)

	ENDC

		bsr.w	COM_InitRayOffset

		bsr.w	COM_InitPerspTables

		bsr.w	COM_InitBoard

		bsr.w	COM_InitView

		move.l	#$f80000,COM_RSeed

		bsr.w	COM_CopyUpBoard
		move.l	COM_PlanesRender,a0
		adda.l	#(COM_HEIGHT+13)*COM_WIDTH_B*COM_DEPTH+10,a0
		bsr.w	COM_NoiseOnMonitor
		move.l	COM_PlanesRender,a0
		adda.l	#(COM_HEIGHT+13)*COM_WIDTH_B*COM_DEPTH+10+12,a0
		bsr.w	COM_NoiseOnMonitor
		bsr.w	COM_SwitchView

		bsr.w	COM_CopyUpBoard
		move.l	COM_PlanesRender,a0
		adda.l	#(COM_HEIGHT+13)*COM_WIDTH_B*COM_DEPTH+10,a0
		bsr.w	COM_NoiseOnMonitor
		move.l	COM_PlanesRender,a0
		adda.l	#(COM_HEIGHT+13)*COM_WIDTH_B*COM_DEPTH+10+12,a0
		bsr.w	COM_NoiseOnMonitor
		bsr.w	COM_SwitchView

		moveq	 #80,d5
COM_Loop0
		move.l	COM_PlanesRender,a0
		adda.l	#(COM_HEIGHT+13)*COM_WIDTH_B*COM_DEPTH+10,a0
		bsr.w	COM_NoiseOnMonitor
		move.l	COM_PlanesRender,a0
		adda.l	#(COM_HEIGHT+13)*COM_WIDTH_B*COM_DEPTH+10+12,a0
		bsr.w	COM_NoiseOnMonitor
		bsr.w	COM_SwitchView

		dbra	d5,COM_Loop0

		bsr.w	COM_CopyMap
		bsr.w	COM_SwitchView
		eor.w	#32*29,COM_RotorCtrl
		bsr.w	COM_CopyMap
		bsr.w	COM_SwitchView

		moveq	#40,d5
COM_Loop1
		move.l	COM_PlanesRender,a0
		adda.l	#(COM_HEIGHT+13)*COM_WIDTH_B*COM_DEPTH+10+12,a0
		bsr.w	COM_NoiseOnMonitor
		bsr.w	COM_SwitchView

		dbra	d5,COM_Loop1

		move.l	COM_PlanesRender,a0
		adda.l	#(COM_HEIGHT+13)*COM_WIDTH_B*COM_DEPTH+10+12,a0
		bsr.w	COM_ClearIRMonitor

		move.l	COM_PlanesDisplay,a0
		adda.l	#(COM_HEIGHT+13)*COM_WIDTH_B*COM_DEPTH+10+12,a0
		bsr.w	COM_ClearIRMonitor

COM_Loop2
		bsr.w	COM_RenderTerain

		bsr.w	COM_SwitchView

		bsr.w	COM_CopyMap

		move.l	COM_Chunky,a0
		move.l	COM_PlanesRender,a1
		bsr.w	COM_ChunkyToPlanar

		bsr.w	COM_CopyUpBoard

		bsr.w	COM_ChunkyToIRChunky
		move.l	COM_IRChunky,a0
		move.l	COM_PlanesRender,a1
		adda.l	#(COM_HEIGHT+15)*COM_WIDTH_B*COM_DEPTH+10+12,a1
		bsr.w	COM_ChunkyToPlanarIR

		move.b	COM_PosZ,d1
		add.w	COM_MoveSpeed,d1
		move.b	d1,COM_PosZ

		cmp.w	#MAX_MOVE_SPEED-1,COM_MoveSpeed
		beq.b	COM3
		addq.w	#1,COM_MoveSpeed

		bra.b	COM_Loop2
COM3
		move.b	COM_PosZ,COM_Z
COM_MainLoop
		bsr.w	COM_RenderTerain

		bsr.w	COM_SwitchView

		bsr.w	COM_CopyMap

		move.l	COM_Chunky,a0
		move.l	COM_PlanesRender,a1
		bsr.w	COM_ChunkyToPlanar

		bsr.w	COM_CopyUpBoard

		bsr.w	COM_ChunkyToIRChunky
		move.l	COM_IRChunky,a0
		move.l	COM_PlanesRender,a1
		adda.l	#(COM_HEIGHT+15)*COM_WIDTH_B*COM_DEPTH+10+12,a1
		bsr.w	COM_ChunkyToPlanarIR

		move.l	COM_MovingTable,a0
		move.w	COM_MoveSpeed,d0
		mulu	#1200*2,d0
		adda.l	d0,a0

		move.w	COM_RotY,d0
		lsr.w	#1,d0
		add.w	#80*2,d0
		cmpi.w	#960*2,d0
		blt.b	COM1
		subi.w	#960*2,d0
COM1
		move.w	COM_X,d1
		add.w	(a0,d0.w),d1
		move.w	d1,COM_X
		lsr.w	#8,d1
		move.b	d1,COM_PosX+1

		lea	240*2(a0),a0
		move.w	COM_Z,d1
		add.w	(a0,d0.w),d1
		move.w	d1,COM_Z
		lsr.w	#8,d1
		move.b	d1,COM_PosZ

		move.w	COM_RotY,d0
		add.w	COM_RotYSpeed,d0
		bpl.b	COM2
		addi.w	#960*4,d0
		bra.b	COM0
COM2		cmpi.w	#960*4,d0
		blt.b	COM0
		subi.w	#960*4,d0
COM0		move.w	d0,COM_RotY

		move.w	COM_RotYSpeed,d0
		add.w	d0,d0
		addi.w	#30*4,d0
		mulu	#320/4,d0
		move.w	d0,COM_Turn

		move.w	COM_RotYSpeed,d1
		add.w	COM_Spec,d1
		cmpi.w	#-MAX_ROTATE_SPEED*4,d1
		blt.b	COM5
		cmpi.w	#MAX_ROTATE_SPEED*4,d1
		bgt.b	COM5
		move.w	d1,COM_RotYSpeed
COM5
		tst.w	COM_JoyActive
		beq.b	COM7

		move.w	joy1dat+CUSTOM,d0
COM11		btst	#1,d0
		beq.b	COM8
COM13		move.w	#8,COM_Spec
		bra.b	COM6
COM8		btst	#9,d0
		beq.b	COM9
COM12		move.w	#-8,COM_Spec
		bra.b	COM6
COM9		move.w	COM_RotYSpeed,d1
		bmi.b	COM13
		bne.b	COM12
		move.w	#0,COM_Spec
		bra.b	COM6

COM7		move.w	joy1dat+CUSTOM,d0
		andi.w	#$0202,d0
		beq.b	COM10
		move.w	#1,COM_JoyActive
		bra.b	COM11

COM10		subq.w	#1,COM_Cntr
		bpl.b	COM6
		neg.w	COM_Spec
		move.b	$bfe701,d0
		andi.w	#$001f,d0
		move.w	d0,COM_Cntr
COM6
		tst.w	SynchroCntr
		bne.w	COM_MainLoop

		bsr.w	COM_Fade

		subq.w	#1,COM_FadeCntr
		bne.w	COM_MainLoop

COM_End
	IFEQ	DEBUG

		lea	CUSTOM,a5

		move.w	DMA_old,d0
		bset.l	#15,d0
		move.w	#$71f0,dmacon(a5)
		move.w	d0,dmacon(a5)

	ENDC

		FreeMemBlocks	COM_MemEntryPtr

COM_AllocMemError
		moveq	#0,d0
		rts


; ===========================================================================
; Procedure:	COM_SetmemPtrs
; Function:	Set pointers to allocated memory blocks
; In:
;	none
; Out:
;	none
; Crash regs:
;	a0
; ===========================================================================

COM_SetMemPtrs
		move.l	COM_MemEntryPtr,a0
		lea	14+2(a0),a0

		move.l	(a0),COM_CopperList
		move.l	8(a0),COM_PlanesDisplay
		move.l	2*8(a0),COM_PlanesRender
		move.l	3*8(a0),COM_Chunky
		move.l	4*8(a0),COM_PerspTable
		move.l	5*8(a0),COM_RayOffset
		move.l	6*8(a0),COM_IRChunky

		rts


; ===========================================================================
; Procedure:	COM_InitView
; Function:	Initialize view
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_CON1	=	-10

COM_InitView
		lea	CUSTOM,a5

		move.l	#$02110000,bplcon0(a5)
		move.w	#$0000,bplcon2(a5)
		move.w	#$0000,bplcon4(a5)

		move.w	#-8+7*COM_WIDTH_B,bpl1mod(a5)
		move.w	#-8+7*COM_WIDTH_B,bpl2mod(a5)

		move.w	#3,fmode(a5)

 SetView COM_HOFFSET,COM_VOFFSET,COM_WIDTH,COM_HEIGHT+COM_BOARD_HEIGHT,LORES

		move.l	COM_CopperList,a0

		move.l	a0,COM_CopperDisplay

		move.l	COM_Palette,a1
		move.w	#1<<COM_DEPTH-1,d7
		jsr	SetCopperPalette

		move.l	COM_PlanesDisplay,d0	; first CL
		moveq	#COM_DEPTH-1,d7
		moveq	#COM_WIDTH_B,d1
		jsr	SetCopperBplPtrs

	move.l	#(COM_VOFFSET+COM_HEIGHT+COM_CON1)<<24+$01fffe,(a0)+

		move.l	a0,COM_CopBPDisplay

		move.l	COM_BoardPalette,a1
		move.w	#255,d7
		jsr	SetCopperPalette

		move.l	#-2,(a0)+		; end of first CL

		move.l	a0,COM_CopperRender

		move.l	COM_Palette,a1
		move.w	#1<<COM_DEPTH-1,d7
		jsr	SetCopperPalette

		move.l	COM_PlanesRender,d0	; second CL
		moveq	#COM_DEPTH-1,d7
		moveq	#COM_WIDTH_B,d1
		jsr	SetCopperBplPtrs

	move.l	#(COM_VOFFSET+COM_HEIGHT+COM_CON1)<<24+$01fffe,(a0)+

		move.l	a0,COM_CopBPRender

		move.l	COM_BoardPalette,a1
		move.w	#255,d7
		jsr	SetCopperPalette

		move.l	#-2,(a0)		; end of second CL

;		move.w	#$0020,bplcon3(a5)

		move.l	COM_CopperDisplay,cop1lc(a5)
		move.w	d0,copjmp1(a5)

		rts


; ===========================================================================
; Procedure:	COM_SwitchView
; Function:	Switch view display and render
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_SwitchView
		lea	CUSTOM,a5

		move.l	COM_PlanesDisplay,a0
		move.l	COM_PlanesRender,a1
		move.l	a0,COM_PlanesRender
		move.l	a1,COM_PlanesDisplay

		move.l	COM_CopBPDisplay,a0
		move.l	COM_CopBPRender,a1
		move.l	a0,COM_CopBPRender
		move.l	a1,COM_CopBPDisplay

		move.l	COM_CopperDisplay,a0
		move.l	COM_CopperRender,a1
		move.l	a0,COM_CopperRender
		move.l	a1,COM_CopperDisplay

		WaitBlitter

COM_sv_wait	move.l	vposr(a5),d0
		andi.l	#$0001ff00,d0
		cmpi.l	#$00012d00,d0
		bne.b	COM_sv_wait

		move.l	a1,cop1lc(a5)
		move.w	d0,copjmp1(a5)

		rts


; ===========================================================================
; Procedure:	COM_Fade
; Function:	Fade out
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_Fade
		move.l	COM_Palette,a0
		move.l	COM_BoardPalette,a1

		move.w	#255,d7
COM_f_Loop
		move.l	(a0),d0
		lsr.l	#1,d0
		andi.l	#$007f7f7f,d0
		move.l	d0,(a0)+

		move.l	(a1),d0
		lsr.l	#1,d0
		andi.l	#$007f7f7f,d0
		move.l	d0,(a1)+

		dbra	d7,COM_f_Loop

		move.l	COM_CopperRender,a0
		move.l	COM_Palette,a1
		move.w	#1<<COM_DEPTH-1,d7
		jsr	SetCopperPalette

		move.l	COM_CopBPRender,a0
		move.l	COM_BoardPalette,a1
		move.w	#255,d7
		jsr	SetCopperPalette

		rts


; ===========================================================================
; Procedure:	COM_InitRayOffset
; Function:	Initialize RayOffset table
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_InitRayOffset
		move.l	COM_RayOffset,a0
		move.l	COM_RayTable,d0
		move.l	d0,a1
		lea	127*2(a1),a1

		move.l	#960-1,d7

COM_iro_Loop	move.l	d0,960*4(a0)
		move.l	d0,(a0)+
		addi.l	#128*2,d0

		move.w	#0,(a1)
		lea	128*2(a1),a1

		dbra	d7,COM_iro_Loop

		rts


; ===========================================================================
; Procedure:	COM_InitPerspTables
; Function:	Initialize perspective tables
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_InitPerspTables

		move.l	COM_PerspTable,a0

		move.w	#(0-COM_OBSERVER_DIST)<<1,d7

COM_ipt_Loop0	move.w	#-COM_OBSERVER_Y,d6

COM_ipt_Loop1
		move.w	d6,d0
		muls	#COS_CONST,d0
		asr.l	#8,d0
		move.w	d7,d1
		muls	#SIN_CONST,d1
		asr.l	#8,d1
		add.l	d1,d0

		move.w	d7,d1
		muls	#COS_CONST,d1
		asr.l	#8,d1
		move.w	d6,d2
		muls	#SIN_CONST,d2
		asr.l	#8,d2
		sub.l	d2,d1

;	d0.l	y
;	d1.l	z

		move.l	#COM_OBSERVER_Z*256,d2
		add.l	#COM_OBSERVER_Z,d1
		divs	d1,d2
		muls	d0,d2
		asr.l	#8,d2

		neg.l	d2
		add.l	#48,d2

		move.w	d2,(a0)+

		addq.w	#1,d6
		cmpi.w	#255-COM_OBSERVER_Y,d6
		ble.b	COM_ipt_Loop1

		addq.w	#2,d7
		cmpi.w	#(128-COM_OBSERVER_DIST)*2,d7
		blt.b	COM_ipt_Loop0

		lea	COM_SkyPerspTable,a0

		move.w	#128,d7

COM_ipt_Loop2	move.l	#COM_OBSERVER_Z*COM_SKY_ALT,d0
		divu	d7,d0
		subi.w	#COM_OBSERVER_Z*COM_SKY_ALT/128,d0

		move.w	d0,(a0)+

		subq.w	#1,d7
		bgt.b	COM_ipt_Loop2

		rts


; ===========================================================================
; Procedure:	COM_ClearIRMonitor
; Function:	Clear IR monitor
; In:
;	a0.l	pointer to planes
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_ClearIRMonitor
		lea	CUSTOM,a5

		WaitBlitter

		move.l	a0,bltdpt(a5)
		move.l	#$01000000,bltcon0(a5)
		move.w	#32,bltdmod(a5)
		move.w	#46*8*64+4,bltsize(a5)

		rts


; ===========================================================================
; Procedure:	COM_NoiseOnMonitor
; Function:	Render noise on helicopter monitor
; In:
;	a0.l	pointer to screen region
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_NoiseOnMonitor
		move.l	COM_RSeed,a1

		moveq	#45,d7
COM_nom_Loop
		move.l	(a1)+,(a0)
		move.l	(a1)+,4(a0)

		move.l	(a1)+,40(a0)
		move.l	(a1)+,44(a0)

		move.l	(a1)+,80(a0)
		move.l	(a1)+,84(a0)

		move.l	(a1)+,120(a0)
		move.l	(a1)+,124(a0)

		lea	320(a0),a0

		dbra	d7,COM_nom_Loop

		move.l	a1,COM_RSeed

		rts


; ===========================================================================
; Procedure:	COM_InitBoard
; Function:	Initialize board
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_InitBoard
		move.l	COM_Board_down,a0
		move.l	COM_PlanesRender,a1
		move.l	COM_PlanesDisplay,a2

		adda.l	#(COM_WIDTH_B*COM_HEIGHT*COM_DEPTH),a1
		adda.l	#(COM_WIDTH_B*COM_HEIGHT*COM_DEPTH),a2

		move.w	#COM_WIDTH_B*COM_BOARD_HEIGHT*COM_DEPTH/4-1,d7

COM_ib_Loop0	move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		dbra	d7,COM_ib_Loop0

		rts


; ===========================================================================
; Procedure:	COM_ChunkyToIRChunky
; Function:	Copy and scaling chunky to IR chunky
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_ChunkyToIRChunky
		move.l	COM_Chunky,a0
		move.l	COM_IRChunky,a1
		move.l	COM_ColorToGray,a2

		moveq	#0,d0
		moveq	#41,d7
COM_ctirc_Loop0
		move.b	(a0),d0
		move.b	(a2,d0.w),(a1)+
TMP3		SET	5
		REPT	31
		move.b	TMP3(a0),d0
		move.b	(a2,d0.w),(a1)+
TMP3		SET	TMP3+5
		ENDR

		lea	3*160(a0),a0

		dbra	d7,COM_ctirc_Loop0

		rts


; ===========================================================================
; Procedure:	COM_CopyMap
; Function:	Copy map and helicopter icon to board
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_CopyMap
		move.l	COM_MapCorrect,a2

		move.w	#80*4,d3
		add.w	COM_RotY,d3
		cmpi.w	#960*4,d3
		blt.b	COM_cm0
		subi.w	#960*4,d3

COM_cm0		move.w	d3,d2
		lsr.w	#2,d2

		moveq	#0,d0
		move.b	COM_PosZ,d0
		neg.b	d0
		subi.b	#25*2,d0
		sub.b	(240,a2,d2.w),d0
		lsr.b	#1,d0
		addi.w	#46,d0

		mulu	#192/8*COM_DEPTH,d0
		subi.l	#192/8,d0

		move.w	COM_PosX,d1
		subi.b	#32*2,d1
		add.b	(a2,d2.w),d1
		lsr.b	#1,d1
		moveq	#0,d2
		move.w	d1,d2
		lsr.w	#3,d2
		andi.l	#$fffffffe,d2
		addq.l	#8,d2
		add.l	d2,d0

		andi.w	#$000f,d1

		lea	MapConTable,a0
		move.l	(a0,d1.w*4),d7

		lea	MapMaskTable,a0
		move.l	(a0,d1.w*4),d6

		move.l	COM_Board_map,a0
		adda.l	d0,a0

		move.l	COM_PlanesRender,a1
 adda.l	#(COM_HEIGHT+13+46)*COM_WIDTH_B*COM_DEPTH+10+8-COM_WIDTH_B,a1

		lea	CUSTOM,a5

		WaitBlitter

;	a0.l	source
;	a1.l	destination
;	d6.l	bltafwm, bltalwm
;	d7.l	bltcon

		move.l	a0,bltbpt(a5)
		move.l	a1,bltcpt(a5)
		move.l	a1,bltdpt(a5)
		move.l	d7,bltcon0(a5)
		move.l	d6,bltafwm(a5)
		move.w	#$ffff,bltadat(a5)
		move.w	#14,bltbmod(a5)
		move.w	#30,bltcmod(a5)
		move.w	#30,bltdmod(a5)
		move.w	#46*8*64+5,bltsize(a5)

		move.l	COM_Helicopter,a0
		move.l	COM_Helicopter_mask,a1

		move.l	COM_PlanesRender,a2
		adda.l	#(COM_HEIGHT+13+10)*COM_WIDTH_B*COM_DEPTH+12,a2

		divu	#48*4,d3
		mulu	#32*29,d3
		adda.l	d3,a0
		adda.l	d3,a1

		WaitBlitter

		move.l	a2,bltdpt(a5)
		move.l	a0,bltapt(a5)
		move.l	a1,bltbpt(a5)
		move.l	a2,bltcpt(a5)
		move.l	#$0fe20000,bltcon0(a5)
		move.l	#$ffffffff,bltafwm(a5)
		move.l	#(36<<16),bltcmod(a5)
		move.l	#36,bltamod(a5)
		move.w	#29*8*64+32/16,bltsize(a5)

		move.l	COM_Rotor,a0
		move.l	COM_Rotor_mask,a1

		move.w	COM_RotorCtrl,d0
		adda.w	d0,a0
		adda.w	d0,a1

		eor.w	#32*29,d0
		move.w	d0,COM_RotorCtrl

		WaitBlitter

		move.l	a2,bltdpt(a5)
		move.l	a0,bltapt(a5)
		move.l	a1,bltbpt(a5)
		move.l	a2,bltcpt(a5)
		move.l	#$0fe20000,bltcon0(a5)
		move.l	#$ffffffff,bltafwm(a5)
		move.l	#(36<<16),bltcmod(a5)
		move.l	#36,bltamod(a5)
		move.w	#29*8*64+32/16,bltsize(a5)

		rts


; ===========================================================================
; Procedure:	COM_CopyUpBoard
; Function:	Copy up board with mask
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_CopyUpBoard
		move.l	COM_PlanesRender,a0

		lea	CUSTOM,a5

		WaitBlitter

		move.l	a0,bltdpt(a5)
		move.l	COM_Board_up,bltapt(a5)
		move.l	COM_Board_up_mask,bltbpt(a5)
		move.l	a0,bltcpt(a5)
		move.l	#$0fe20000,bltcon0(a5)
		move.l	#$ffffffff,bltafwm(a5)
		move.l	#0,bltcmod(a5)
		move.l	#0,bltamod(a5)
;		move.w	#COM_HEIGHT*COM_DEPTH*64+COM_WIDTH_W,bltsize(a5)
		move.w	#COM_WIDTH_W,bltsize(a5)

		rts


; ===========================================================================
; Procedure:	COM_RenderTerain
; Function:	Render terain
; In:
;	none
; Out:
;	none
; Crash regs:
;	all
; ===========================================================================

COM_RenderTerain

		move.l	COM_RayOffset,a0
		adda.w	COM_RotY,a0
		move.l	COM_Maps,a1
		move.l	COM_PerspTable,a2
		move.l	COM_Sky,a3
		move.l	COM_Chunky,a4
		lea	((COM_HEIGHT-1)*COM_WIDTH2)(a4),a4
		move.l	COM_TurnTable,a5
		adda.w	COM_Turn,a5

		move.w	COM_PosZ,d0
		move.b	COM_PosX+1,d1
		moveq	#0,d2

		move.w	#COM_WIDTH2-1,d7

COM_rt_Loop0
		move.l	(a0)+,a6

		moveq	#0,d3

		move.w	#COM_HEIGHT-1,d5

		move.w	(a5)+,d6

		move.w	(a6)+,d2
		beq.b	COM_rt2

COM_rt_Loop1
		add.w	d0,d2
		add.b	d1,d2

		move.b	(a1,d2.l*2),d3

;		move.b	#0,d3

		move.w	(a2,d3.w*2),d4
		add.w	d6,d4

		cmp.w	d5,d4
		bgt.b	COM_rt0

		move.b	1(a1,d2.l*2),d3
		move.b	(COM_ShadePalette,pc,d3.w),d3

COM_rt_Loop2	move.b	d3,(a4)
		suba.w	#COM_WIDTH2,a4
		subq.w	#1,d5
		bmi.b	COM_rt1
		cmp.w	d5,d4
		ble.b	COM_rt_Loop2

COM_rt0
		addi.w	#256,d3

		move.w	(a6)+,d2
		bne.b	COM_rt_Loop1

COM_rt2
		move.l	-4(a0),a6

COM_rt_Loop3	move.w	(COM_SkyPerspTable,pc,d5.w*2),d2
		move.w	(a6,d2.w*2),d2
		add.w	d0,d2
		add.b	d1,d2
		move.b	(a3,d2.l),(a4)
		suba.w	#COM_WIDTH2,a4
		dbra	d5,COM_rt_Loop3
COM_rt1
		lea	(COM_HEIGHT*COM_WIDTH2+1)(a4),a4

		dbra	d7,COM_rt_Loop0

		rts


; ---------------------------------------------------------------------------

		INCLUDE	"Comanche/C2P.COM.s"
		INCLUDE	"Comanche/C2P.IRCOM.s"

COM_SkyPerspTable	DCB.W	COM_HEIGHT
COM_ShadePalette	INCBIN	"Chunky/VoxelTexture7.shadepalette"

; ---------------------------------------------------------------------------

COM_MemEntry	DCB.B	14
		DC.W	7
	DC.L	MEMF_CHIP,COM_DEPTH*8*2+530*4*2+530*4*2+4*2	; CopperList
	DC.L	MEMF_CHIP+MEMF_CLEAR,COM_DEPTH*COM_PLANE_SIZE	; Planes0
	DC.L	MEMF_CHIP+MEMF_CLEAR,COM_DEPTH*COM_PLANE_SIZE	; Planes1
	DC.L	MEMF_PUBLIC,COM_WIDTH2*COM_HEIGHT		; ChunkyMap
	DC.L	MEMF_PUBLIC,128*256*2				; PerspTable
	DC.L	MEMF_PUBLIC,960*4*2				; RayOffset
	DC.L	MEMF_CHIP,32*42					; IRChunky

COM_MemEntryPtr	DC.L	0

COM_CopperList	DC.L	0
COM_CopperDisplay	DC.L	0
COM_CopperRender	DC.L	0
COM_PlanesDisplay	DC.L	0
COM_PlanesRender	DC.L	0
COM_Chunky	DC.L	0
COM_Palette	DC.L	0
COM_Maps	DC.L	0
COM_RayOffset	DC.L	0
COM_RayTable	DC.L	0
COM_PerspTable	DC.L	0
COM_MovingTable	DC.L	0
COM_TurnTable	DC.L	0
COM_RotorCtrl	DC.W	0
COM_Sky		DC.L	0
COM_MapCorrect	DC.L	0
COM_IRChunky	DC.L	0
COM_ColorToGray	DC.L	0
COM_Board_down	DC.L	0
COM_BoardPalette	DC.L	0
COM_Board_up	DC.L	0
COM_Board_up_mask	DC.L	0
COM_Board_map	DC.L	0
COM_Helicopter	DC.L	0
COM_Helicopter_mask	DC.L	0
COM_Rotor	DC.L	0
COM_Rotor_mask	DC.L	0
COM_CopBPDisplay	DC.L	0
COM_CopBPRender	DC.L	0

COM_PosX	DC.W	0
COM_PosZ	DC.W	0
COM_RotY	DC.W	(960-80)*4
COM_Turn	DC.W	30*160*2
COM_X		DC.W	0
COM_Z		DC.W	0
COM_MoveSpeed	DC.W	0
COM_RotYSpeed	DC.W	0
COM_Spec	DC.W	4
COM_Cntr	DC.W	0
COM_RSeed	DC.L	0
COM_JoyActive	DC.W	0
COM_FadeCntr	DC.W	10

TMP1		SET	0
MapConTable	REPT	16
		DC.L	(TMP1<<28)+(7<<24)+($ca<<16)+(TMP1<<12)+2
TMP1		SET	TMP1+1
		ENDR

MapMaskTable	DC.L	$0000ffff,$80007fff,$c0003fff,$e0001fff
		DC.L	$f0000fff,$f80007ff,$fc0003ff,$fe0001ff
		DC.L	$ff0000ff,$ff80007f,$ffc0003f,$ffe0001f
		DC.L	$fff0000f,$fff80007,$fffc0003,$fffe0001

COM_EmptyCL	DC.L	-2

; ---------------------------------------------------------------------------

; ===========================================================================

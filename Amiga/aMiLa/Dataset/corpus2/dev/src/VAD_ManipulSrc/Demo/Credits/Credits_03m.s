; =============================================================================
; -----------------------------------------------------------------------------
; File:		Credits_xx.s
; Contents:	Scaling texture with credits and background effect
; Author:	Jacek (Noe) Cybularczyk / Venus Art
; Copyright:	©1995 by Noe
; -----------------------------------------------------------------------------
; History:
; -----------------------------------------------------------------------------
; 15.08.1995	bassed on DemoPart2_16.s
; 16.08.1995	text scaling and background animations in the same time
;		(precalculated scaling), add Juma to credits
; 24.08.1995	add picture from Juma

; -----------------------------------------------------------------------------
; =============================================================================

CR_SCREEN_WIDTH	=	320
CR_SCREEN_WIDTH2	=	CR_SCREEN_WIDTH>>1
CR_SCREEN_WIDTH_B	=	CR_SCREEN_WIDTH>>3
CR_SCREEN_WIDTH_W	=	CR_SCREEN_WIDTH>>4
CR_SCREEN_HEIGHT	=	256
CR_SCREEN_HEIGHT2	=	CR_SCREEN_HEIGHT>>1
CR_PLANE_SIZE	=	CR_SCREEN_WIDTH_B*CR_SCREEN_HEIGHT
CR_PLANES_NUMBER	=	1

CR_H_OFFSET	=	$81
CR_V_OFFSET	=	$2a

		RSRESET
RawMap
rm_Address	RS.L	1
rm_BytesPerLine	RS.W	1
rm_PosX		RS.W	1
rm_PosY		RS.W	1
rm_Width	RS.W	1
rm_Height	RS.W	1
rm_SIZEOF	RS.B	0

CR_OBSERVER_Z	=	60
CR_FLY_SPEED	=	5
CR_ANIM_FRAMES	=	(CR_OBSERVER_Z-1)/CR_FLY_SPEED+2

CR_POINTS_NUMBER	=	2
CR_ROTATE_SPEED	=	7

; =============================================================================

; -----------------------------------------------------------------------------

		SECTION	Credits_0,code

Credits
		move.l	(a0)+,a1
		adda.w	#MAGIC_NUMBER,a1
		move.l	a1,CR_Raw0
		adda.w	#1128,a1
		move.l	a1,CR_Raw1
		adda.w	#1920,a1
		move.l	a1,CR_Raw2
		adda.w	#1952,a1
		move.l	a1,CR_Raw3
		adda.w	#2196,a1
		move.l	a1,CR_Raw4
		adda.w	#1586,a1
		move.l	a1,CR_Raw5
		adda.w	#1368,a1
		move.l	a1,CR_Raw6
		adda.w	#1320,a1
		move.l	a1,CR_Raw7
		adda.w	#2232,a1
		move.l	a1,CR_MMPalette
		adda.w	#64,a1
		move.l	a1,CR_PosTable1
		adda.w	#800,a1
		move.l	a1,CR_PosTable2
		move.l	(a0)+,a1
		adda.w	#MAGIC_NUMBER,a1
		move.l	a1,CR_ManipulationsMotif

		AllocMemBlocks	CR_MemEntry
		bne.w	CR_AllocMemError
		move.l	d0,CR_MemEntryPtr

		bsr.w	CR_SetMemPtrs

		suba.w	a0,a0
		move.w	#256-1,d7
		jsr	SetPalette

		bsr.w	CR_InitScreen
		bsr.w	CR_InitMulTable
		bsr.w	CR_InitPerspTable
		bsr.w	CR_ClearPBuffer

		move.w	#190,d0
		move.w	#47,d1
		move.l	CR_Raw0,a2
		move.l	CR_Anim0,a3
		bsr	CR_InitFlyText

		move.w	#254,d0
		move.w	#60,d1
		move.l	CR_Raw1,a2
		move.l	CR_Anim1,a3
		bsr	CR_InitFlyText

		move.w	#255,d0
		move.w	#61,d1
		move.l	CR_Raw2,a2
		move.l	CR_Anim2,a3
		bsr	CR_InitFlyText

		move.w	#283,d0
		move.w	#61,d1
		move.l	CR_Raw3,a2
		move.l	CR_Anim3,a3
		bsr	CR_InitFlyText

		move.w	#201,d0
		move.w	#61,d1
		move.l	CR_Raw4,a2
		move.l	CR_Anim4,a3
		bsr	CR_InitFlyText

		move.w	#188,d0
		move.w	#57,d1
		move.l	CR_Raw5,a2
		move.l	CR_Anim5,a3
		bsr	CR_InitFlyText

		move.w	#187,d0
		move.w	#55,d1
		move.l	CR_Raw6,a2
		move.l	CR_Anim6,a3
		bsr	CR_InitFlyText

		move.w	#140,d0
		move.w	#124,d1
		move.l	CR_Raw7,a2
		move.l	CR_Anim7,a3
		bsr	CR_InitFlyText

		bsr.w	CR_InitScreen2

		moveq	#80,d2
		bsr.w	CR_Efect

		move.l	CR_Anim0,a0
		bsr.w	CR_FlyText

		moveq	#85,d2
		bsr.w	CR_Efect

		move.l	CR_Anim1,a0
		bsr.w	CR_FlyText

		moveq	#85,d2
		bsr.w	CR_Efect

		move.l	CR_Anim2,a0
		bsr.w	CR_FlyText

		moveq	#84,d2
		bsr.w	CR_Efect

		move.l	CR_Anim3,a0
		bsr.w	CR_FlyText

		moveq	#84,d2
		bsr.w	CR_Efect

		move.l	CR_Anim4,a0
		bsr.w	CR_FlyText

		moveq	#84,d2
		bsr.w	CR_Efect

		move.l	CR_Anim5,a0
		bsr.w	CR_FlyText

		moveq	#84,d2
		bsr.w	CR_Efect

		move.l	CR_Anim6,a0
		bsr.w	CR_FlyText

		moveq	#84,d2
		bsr.w	CR_Efect

		move.l	CR_Anim7,a0
		bsr.w	CR_FlyText

		moveq	#60,d2
		bsr.w	CR_Efect

		jsr	MUSIC_STOP

		moveq	#0,d2
CR_b3
		bsr.w	CR_Efect

		btst.b	#6,$bfe001
		bne.w	CR_b3

CR_Stop		lea	CUSTOM,a5
		move.w	#$83f0,dmacon(a5)

		FreeMemBlocks	CR_MemEntryPtr
CR_AllocMemError
		moveq	#0,d0
		rts


; ===========================================================================
; Procedure:	CR_SetmemPtrs
; Function:	Set pointers to allocated memory blocks
; In:
;	none
; Out:
;	none
; Crash regs:
;	a0
; ===========================================================================

CR_SetMemPtrs
		move.l	CR_MemEntryPtr,a0
		lea	14+2(a0),a0

		move.l	(a0),CR_MulTable
		move.l	8(a0),CR_HScalingBuffer
		addq.l	#4,CR_HScalingBuffer
		move.l	2*8(a0),CR_VScalingBuffer
		move.l	3*8(a0),CR_PerspTable
		move.l	4*8(a0),a1
		move.l	a1,CR_Planes
		lea	CR_PLANE_SIZE(a1),a1
		move.l	a1,CR_Planes+4
		lea	CR_PLANE_SIZE(a1),a1
		move.l	a1,CR_Planes+8
		lea	CR_PLANE_SIZE(a1),a1
		move.l	a1,CR_Planes+12
		lea	CR_PLANE_SIZE(a1),a1
		move.l	a1,CR_PBuffer
		move.l	5*8(a0),CR_Anim0
		move.l	6*8(a0),CR_Anim1
		move.l	7*8(a0),CR_Anim2
		move.l	8*8(a0),CR_Anim3
		move.l	9*8(a0),CR_Anim4
		move.l	10*8(a0),CR_Anim5
		move.l	11*8(a0),CR_Anim6
		move.l	12*8(a0),CR_Anim7
		move.l	13*8(a0),CR_NullAnim

		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_InitScreen
; Function:	Initialize planes and copper list
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

CR_InitScreen	movem.l	d0-d7/a0-a6,-(sp)

		lea	CUSTOM,a5

		move.w	#$71f0,dmacon(a5)

		move.l	#$c2000000,bplcon0(a5)
		move.l	#$02240c40,bplcon2(a5)
		move.w	#$0011,bplcon4(a5)

		move.w	#-8+80*3,bpl1mod(a5)
		move.w	#-8+80*3,bpl2mod(a5)

		move.w	#$0003,fmode(a5)

		move.w	#$2c81,diwstrt(a5)
		move.w	#$2cc1,diwstop(a5)

		move.w	#$38,ddfstrt(a5)
		move.w	#$d8,ddfstop(a5)

		move.l	CR_ManipulationsMotif,d0
		lea	CR_CopperList,a1

		moveq	#4-1,d7
CR_is_Loop
		swap	d0
		move.w	d0,2(a1)
		swap	d0
		move.w	d0,6(a1)

		addq.w	#8,a1

		addi.l	#80,d0

		dbra	d7,CR_is_Loop

		move.l	CR_MMPalette,a0
		moveq	#16-1,d7
		jsr	SetPalette

		move.l	#$02240c40,bplcon2(a5)

		move.l	#CR_CopperList,cop1lc(a5)
		move.w	#0,copjmp1(a5)

		move.w	#$83c0,dmacon(a5)

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_InitScreen2
; Function:	Initialize planes and copper list
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

CR_InitScreen2	movem.l	d0-d7/a0-a6,-(sp)

		lea	CUSTOM,a5

		move.w	#$7100,dmacon(a5)

		move.w	#$2c81,diwstrt(a5)
		move.w	#$2cc1,diwstop(a5)

		move.w	#$38,ddfstrt(a5)
		move.w	#$d0,ddfstop(a5)

		move.w	#-8,bpl1mod(a5)
		move.w	#-8,bpl2mod(a5)

		move.l	#$52000000,bplcon0(a5)
		move.w	#0,bplcon2(a5)

		move.w	#$0003,fmode(a5)

		lea	CR_Palette,a0
		moveq	#32-1,d7
		jsr	SetPalette

		bsr.w	CR_CreateCList

		move.l	CR_NullAnim,CR_CurrentAnimFrame

		bsr.b	CR_SwitchScreen

		move.l	#CR_CopperList2,cop1lc(a5)
		move.w	#$7fff,copjmp1(a5)

		move.w	#$83c0,dmacon(a5)

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_SwitchScreen
; Function:	Switch render and display screen
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

CR_SwitchScreen	movem.l	d0-d2/a0/a1/a5,-(sp)

		lea	CR_CopperList2+2,a0
		lea	CUSTOM+vposr,a5

		move.l	CR_CurrentAnimFrame,d1

CR_ss_wait	move.l	(a5),d0
		andi.l	#$0001ff00,d0
		cmpi.l	#$00012d00,d0
		bne.b	CR_ss_wait

		move.w	d1,4(a0)
		swap	d1
		move.w	d1,(a0)

		movem.l	(sp)+,d0-d2/a0/a1/a5
		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_Wait
; Function:	Wait n frames
; In:
;	d0	how much frames wait
; Out:
;	none
; -----------------------------------------------------------------------------

CR_Wait		movem.l	d1/a5,-(sp)

		lea	CUSTOM+vposr,a5

CR_wait_	move.l	(a5),d1
		andi.l	#$0001ff00,d1
		cmpi.l	#$00012d00,d1
		bne.b	CR_wait_

CR_wait_2	move.l	(a5),d1
		andi.l	#$0001ff00,d1
		cmpi.l	#$00001000,d1
		bne.b	CR_wait_2

		dbra	d0,CR_wait_

		movem.l	(sp)+,d1/a5
		rts

; -----------------------------------------------------------------------------
; Procedure:	CR_InitMulTable
; Function:	Initialize MulTable
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

CR_InitMulTable	movem.l	d0/a0/a1,-(sp)

		move.l	CR_MulTable(pc),a0
		moveq	#0,d1
		move.w	#CR_SCREEN_HEIGHT-1,d0

CR_imt_loop	move.w	d1,(a0)+
		add.w	#CR_SCREEN_WIDTH_B,d1
		dbra	d0,CR_imt_loop

		movem.l	(sp)+,d0/a0/a1
		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_InitPerspTable
; Function:	Initialization PerspTable
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

CR_InitPerspTable
		move.l	CR_PerspTable,a0

		moveq	#CR_OBSERVER_Z-1,d7

CR_ipt_Loop	move.l	#CR_OBSERVER_Z<<8,d0
		move.w	#CR_OBSERVER_Z,d1
		sub.w	d7,d1
		divu	d1,d0
		move.w	d0,(a0)+

		subq.w	#CR_FLY_SPEED,d7
		bpl.b	CR_ipt_Loop

		move.w	#256,(a0)+
		move.w	#0,(a0)

		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_FlyText
; Function:	Animation fly text
; In:
;	a0.l	pointer to animation frames
; Out:
;	none
; -----------------------------------------------------------------------------

CR_FlyText
		move.l	a0,CR_CurrentAnimFrame

		moveq	#CR_ANIM_FRAMES-1,d7
CR_ft_Loop
		moveq	#2,d2
		bsr.w	CR_Efect
		bsr.w	CR_SwitchScreen

		add.l	#CR_PLANE_SIZE,CR_CurrentAnimFrame

		dbra	d7,CR_ft_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_InitFlyText
; Function:	Initialize animation fly text
; In:
;	d0.w	width of raw map
;	d1.w	height of raw map
;	a2.l	pointer to source raw map
;	a3.l	pointer to destination
; Out:
;	none
; -----------------------------------------------------------------------------

CR_InitFlyText	lea	CR_SourceRawMap,a0
		lea	CR_DestRawMap,a1

		move.l	a2,(a0)
		move.l	a3,(a1)
		move.w	d0,d2
		addi.w	#8,d2
		andi.w	#$fff8,d2
		lsr.w	#3,d2
		move.w	d2,rm_BytesPerLine(a0)
		move.w	#CR_SCREEN_WIDTH_B,rm_BytesPerLine(a1)

		move.l	CR_PerspTable,a2

CR_ift_Loop	move.w	(a2)+,d7
		beq.w	CR_ift_Stop

		move.w	d0,d2
		mulu	d7,d2
		lsr.l	#8,d2

		cmpi.w	#CR_SCREEN_WIDTH,d2
		bgt.b	CR_ift_WidthBigger

		move.w	#0,rm_PosX(a0)
		move.w	d0,rm_Width(a0)
		move.w	#CR_SCREEN_WIDTH,d3
		sub.w	d2,d3
		lsr.w	#1,d3
		move.w	d3,rm_PosX(a1)
		move.w	d2,rm_Width(a1)
		bra.b	CR_ift_Skip0

CR_ift_WidthBigger
		move.l	#CR_SCREEN_WIDTH<<8,d2
		divu	d7,d2
		move.w	d0,d3
		sub.w	d2,d3
		lsr.w	#1,d3
		move.w	d3,rm_PosX(a0)
		move.w	d2,rm_Width(a0)
		move.w	#0,rm_PosX(a1)
		move.w	#CR_SCREEN_WIDTH,rm_Width(a1)

CR_ift_Skip0	move.w	d1,d2
		mulu	d7,d2
		lsr.l	#8,d2

		cmpi.w	#CR_SCREEN_HEIGHT,d2
		bgt.b	CR_ift_HeightBigger

		move.w	#0,rm_PosY(a0)
		move.w	d1,rm_Height(a0)
		move.w	#CR_SCREEN_HEIGHT,d3
		sub.w	d2,d3
		lsr.w	#1,d3
		move.w	d3,rm_PosY(a1)
		move.w	d2,rm_Height(a1)
		bra.b	CR_ift_Skip1

CR_ift_HeightBigger
		move.l	#CR_SCREEN_HEIGHT<<8,d2
		divu	d7,d2
		move.w	d1,d3
		sub.w	d2,d3
		lsr.w	#1,d3
		move.w	d3,rm_PosY(a0)
		move.w	d2,rm_Height(a0)
		move.w	#0,rm_PosY(a1)
		move.w	#CR_SCREEN_HEIGHT,rm_Height(a1)
CR_ift_Skip1
		bsr.b	CR_Scaling

		add.l	#CR_PLANE_SIZE,(a1)

		bra.w	CR_ift_Loop
CR_ift_Stop
		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_Scaling
; Function:	Scaling
; In:
;	a0.l	pointer to source RawMap
;	a1.l	pointer to destination RawMap
; Out:
;	none
; Destination must be bigger than source (maximal *32)
; -----------------------------------------------------------------------------

CR_Scaling	movem.l	d0-d7/a0-a6,-(sp)

		move.l	CR_HScalingBuffer,a2

		moveq	#0,d1
		move.w	rm_Width(a0),d1
		move.w	rm_Width(a1),d6
		divu	d6,d1
		move.w	d1,d0
		swap	d1

; d0.w	integer
; d1.w	fp
; d6.w	destination width

		move.w	rm_PosX(a0),d3
		move.b	d3,d2
		lsr.w	#3,d3
		move.w	d3,a3
		andi.b	#$07,d2
		eori.b	#$07,d2

		move.w	rm_PosX(a1),d4
		move.b	d4,d3
		lsr.w	#3,d4
		andi.w	#$fffc,d4
		move.w	d4,a4
		andi.b	#$1f,d3

; a3.w	src addr
; a4.w	dest addr
; d2.b	src offset
; d3.b	dest offset

		moveq	#0,d5
		subq.b	#1,d2
		move.b	d2,-4(a2)
		addq.b	#1,d2
		move.w	d6,d7
		subq.w	#1,d7

CR_sh_Loop0
		move.w	d0,d4
		add.w	d1,d5
CR_sh_Skip1	cmp.w	d6,d5
		blt.b	CR_sh_Skip0
		sub.w	d6,d5
		addq.w	#1,d4
		bra.b	CR_sh_Skip1

CR_sh_Skip0	cmp.b	-4(a2),d2
		bne.b	CR_sh_Skip4
		addq.w	#1,-2(a2)
		bra.b	CR_sh_Skip5

CR_sh_Skip4	move.w	a3,(a2)+
		move.w	a4,(a2)+
		move.b	d2,(a2)+
		move.b	d3,(a2)+
		move.w	#0,(a2)+

CR_sh_Skip5	addq.b	#1,d3
		andi.b	#$1f,d3
		bne.b	CR_sh_Skip2
		addq.w	#4,a4
CR_sh_Skip2	sub.b	d4,d2
		bpl.b	CR_sh_Skip3
		addi.b	#8,d2
		addq.w	#1,a3
CR_sh_Skip3	dbra	d7,CR_sh_Loop0

		move.w	#-1,(a2)


		move.l	CR_VScalingBuffer,a2

		moveq	#0,d1
		move.w	rm_Height(a1),d1
		move.w	rm_Height(a0),d6
		divu	d6,d1
		move.w	d1,d0
		swap	d1

; d0.w	integer
; d1.w	fp
; d6.w	destination height

		moveq	#0,d5
		move.w	d6,d7
		subq.w	#1,d7

CR_sv_Loop0
		move.w	d0,d4
		add.w	d1,d5
CR_sv_Skip1	cmp.w	d6,d5
		blt.b	CR_sv_Skip0
		sub.w	d6,d5
		addq.w	#1,d4
		bra.b	CR_sv_Skip1

CR_sv_Skip0	move.w	d4,(a2)+

		dbra	d7,CR_sv_Loop0

		move.w	#-1,(a2)


; preset blitter registers

CR_ss_WaitBlitter1
		btst	#6,dmaconr+CUSTOM
		bne.b	CR_ss_WaitBlitter1

		move.l	#$09f00000,bltcon0+CUSTOM
		move.l	#-1,bltafwm+CUSTOM
		move.w	#-CR_SCREEN_WIDTH_B,bltamod+CUSTOM
		move.w	#0,bltdmod+CUSTOM


		move.l	(a0),a3
		move.l	(a1),a4

		move.w	rm_PosY(a0),d0
		mulu	rm_BytesPerLine(a0),d0
		lea	(a3,d0.l),a3

		move.w	rm_PosY(a1),d0
		mulu	rm_BytesPerLine(a1),d0
		lea	(a4,d0.l),a4

		move.w	rm_BytesPerLine(a0),a5
		move.w	rm_BytesPerLine(a1),a6
		move.w	rm_Height(a0),d7
		subq.w	#1,d7

		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4

		moveq	#1,d5

		move.l	CR_VScalingBuffer,a0
		move.l	CR_MulTable,a6

CR_ss_Loop1	move.l	CR_HScalingBuffer,a2

		move.w	(a2)+,d0
		bmi.b	CR_ss_Skip0

CR_ss_Loop0	move.w	(a2)+,d1
		move.b	(a2)+,d2
		move.b	(a2)+,d3
		move.w	(a2)+,d4

		btst	d2,(a3,d0.w)
		beq.b	CR_ss_Skip2
CR_ss_Loop2	bfins	d5,(a4,d1.w){d3:1}

		addq.b	#1,d3
		dbra	d4,CR_ss_Loop2

CR_ss_Skip2	move.w	(a2)+,d0
		bpl.b	CR_ss_Loop0

CR_ss_Skip0	move.w	(a0)+,d0
		cmpi.w	#1,d0
		ble.b	CR_ss_Skip1

		subq.w	#1,d0
		move.w	d0,d1
		lsl.w	#6,d1
		ori.w	#CR_SCREEN_WIDTH_W,d1

CR_ss_WaitBlitter0
		btst	#6,dmaconr+CUSTOM
		bne.b	CR_ss_WaitBlitter0

		move.l	a4,bltapt+CUSTOM
		adda.w	#CR_SCREEN_WIDTH_B,a4
		move.l	a4,bltdpt+CUSTOM
		move.w	d1,bltsize+CUSTOM

CR_ss_Skip1	add.w	(a6,d0.w*2),a4
		add.w	a5,a3

		dbra	d7,CR_ss_Loop1

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_Efect
; Function:	Make efect
; In:
;	d2.w	how much repeat
; Out:
;	none
; -----------------------------------------------------------------------------

CR_Efect	movem.l	d0-d7/a0-a6,-(sp)

CR_e_Loop	bsr.w	CR_CreateFrame
		bsr.w	CR_SwitchPlanes
		bsr.w	CR_ClearPBuffer
		bsr.w	CR_NextFrame
		bsr.w	CR_RotateNPoints

		dbra	d2,CR_e_Loop

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_SwitchPlanes
; Function:	Rotate planes and plane buffer and call CreateCList
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

CR_SwitchPlanes	move.l	d0,-(sp)

		move.l	CR_Planes(pc),d0
		move.l	CR_Planes+4(pc),CR_Planes
		move.l	CR_Planes+8(pc),CR_Planes+4
		move.l	CR_Planes+12(pc),CR_Planes+8
		move.l	CR_PBuffer(pc),CR_Planes+12
		move.l	d0,CR_PBuffer

		bsr.w	CR_CreateCList

		move.l	(sp)+,d0
		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_ClearPBuffer
; Function:	Clear plane buffer (with blitter of course)
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

CR_ClearPBuffer
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		suba.l	a0,a0
		suba.l	a1,a1

		move.l	CR_PBuffer(pc),a2
		lea	CR_PLANE_SIZE(a2),a2
		moveq	#CR_PLANE_SIZE/1024-1,d7

CR_cpb_Loop	REPT	32
		movem.l	d0-d1/d3-d6/a0-a1,-(a2)
		ENDR
		dbra	d7,CR_cpb_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_CreateCList
; Function:	Wait for bottom of view and create new copper list
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

CR_CreateCList	movem.l	d0/a0/a1/a5,-(sp)

		lea	CR_CopperList+2+8,a0
		lea	CR_Planes(pc),a1
		lea	CUSTOM,a5

CR_ccl_wait	move.l	vposr(a5),d0
		andi.l	#$0001ff00,d0
		cmpi.l	#$00012d00,d0
		bne.b	CR_ccl_wait

		move.w	(a1)+,(a0)
		move.w	(a1)+,4(a0)
		move.w	(a1)+,8(a0)
		move.w	(a1)+,12(a0)
		move.w	(a1)+,16(a0)
		move.w	(a1)+,20(a0)
		move.w	(a1)+,24(a0)
		move.w	(a1)+,28(a0)

		movem.l	(sp)+,d0/a0/a1/a5
		rts

; -----------------------------------------------------------------------------
; Procedure:	CR_RotateNPoints
; Function:	Rotate node points (around screen)
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

CR_RotateNPoints
		movem.l	d0-d7/a0-a6,-(sp)

		lea	CR_NodePoints,a0
		moveq	#CR_NODE_POINTS_NUMBER-1,d7

CR_rnp_loop	move.w	4(a0),d6
		bne.b	CR_rnp0
		subq.w	#CR_ROTATE_SPEED,(a0)
		bge.b	CR_rnp3
		move.w	(a0),d0
		sub.w	d0,2(a0)
		move.w	#0,(a0)
		move.w	#3,4(a0)
		bra.b	CR_rnp3

CR_rnp0		cmpi.w	#1,d6
		bne.b	CR_rnp1
		subq.w	#CR_ROTATE_SPEED,2(a0)
		bge.b	CR_rnp3
		move.w	2(a0),d0
		add.w	#CR_SCREEN_WIDTH,d0
		move.w	d0,(a0)
		move.w	#0,2(a0)
		move.w	#0,4(a0)
		bra.b	CR_rnp3

CR_rnp1		cmpi.w	#2,d6
		bne.b	CR_rnp2
		addq.w	#CR_ROTATE_SPEED,(a0)
		cmpi.w	#CR_SCREEN_WIDTH,(a0)
		blt.b	CR_rnp3
		move.w	(a0),d0
		sub.w	#CR_SCREEN_HEIGHT+CR_SCREEN_WIDTH-1,d0
		neg.w	d0
		move.w	d0,2(a0)
		move.w	#CR_SCREEN_WIDTH-1,(a0)
		move.w	#1,4(a0)
		bra.b	CR_rnp3

CR_rnp2		addq.w	#CR_ROTATE_SPEED,2(a0)
		cmpi.w	#CR_SCREEN_HEIGHT,2(a0)
		blt.b	CR_rnp3
		move.w	2(a0),d0
		sub.w	#CR_SCREEN_HEIGHT,d0
		move.w	d0,(a0)
		move.w	#CR_SCREEN_HEIGHT-1,2(a0)
		move.w	#2,4(a0)

CR_rnp3		adda.w	#6,a0
		dbra	d7,CR_rnp_loop

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_NextFrame
; Function:	Calculate (x,y) of next frame
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

CR_NextFrame	movem.l	d0-d7/a0-a6,-(sp)

		lea	CR_Positions,a0
		move.l	CR_PosTable1,a1
		move.l	CR_PosTable2,a2

		moveq	#CR_POINTS_NUMBER-1,d7

CR_nf_loop	move.w	4(a0),d6
		move.b	(a1,d6.w),d0
		move.b	1(a1,d6.w),d1
		ext.w	d0
		ext.w	d1
		addi.w	#160,d0
		addi.w	#128,d1
;		move.w	#160,d0
;		move.w	#128,d1
		move.w	6(a0),d5
		move.b	(a2,d5.w),d2
		move.b	1(a2,d5.w),d3
		ext.w	d2
		ext.w	d3
		add.w	d2,d0
		add.w	d3,d1
		move.w	d0,(a0)
		move.w	d1,2(a0)

		add.w	8(a0),d6
		bpl.b	CR_nf0
		moveq	#0,d6
		neg.w	8(a0)
		bra.b	CR_nf1
CR_nf0		cmpi.w	#400,d6
		blt.b	CR_nf1
		move.w	#398,d6
		neg.w	8(a0)
CR_nf1		move.w	d6,4(a0)

		add.w	10(a0),d5
		bpl.b	CR_nf2
		moveq	#0,d5
		neg.w	10(a0)
		bra.b	CR_nf3
CR_nf2		cmpi.w	#2000,d5
		blt.b	CR_nf3
		move.w	#1998,d5
		neg.w	10(a0)
CR_nf3		move.w	d5,6(a0)

		adda.w	#12,a0
		dbra	d7,CR_nf_loop

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_CreateFrame
; Function:	Draw one frame in planes buffer
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

CR_CreateFrame	movem.l	d0-d7/a0-a6,-(sp)

		lea	CR_Positions,a2
		lea	$dff002,a5
		movea.l	CR_PBuffer,a0

		moveq	#CR_POINTS_NUMBER-1,d5
CR_cf_loop2	move.w	(a2),d2
		move.w	2(a2),d3
		lea	CR_NodePoints,a1
		moveq	#CR_NODE_POINTS_NUMBER-1,d4
CR_cf_loop	move.w	(a1),d0
		move.w	2(a1),d1
		adda.w	#6,a1
		bsr.b	CR_DrawLine
		dbra	d4,CR_cf_loop
		adda.w	#12,a2
		dbra	d5,CR_cf_loop2

		adda.w	#40*256-2,a0
CR_cf_wait	btst	#6,(a5)
		bne.b	CR_cf_wait

		move.l	a0,bltapt-2(a5)			; Fill
		move.l	a0,bltdpt-2(a5)
		move.l	#$09f00012,bltcon0-2(a5)
		move.l	#$ffffffff,bltafwm-2(a5)
		move.w	#0,bltamod-2(a5)
		move.w	#0,bltdmod-2(a5)
		move.w	#$4014,bltsize-2(a5)

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	CR_DrawLine
; Function:	Draw line with blitter
; In:
;	d0	x1
;	d1	y1
;	d2	x2
;	d3	x3
;	a0	pointer to plane
;	a5	$dff002
; Out:
;	none
; Copyright:	DrawLine V1.01 By TIP/SPREADPOINT
; -----------------------------------------------------------------------------

DL_Width	=	40
DL_Fill		=	1		; 0=NOFILL / 1=FILL

	IFEQ	DL_Fill
DL_MInterns	=	$CA
	ELSE
DL_MInterns	=	$4A
	ENDC

	IFNE	DL_Fill
SML		= 	2
	ELSE
SML		=	0
	ENDC


CR_DrawLine	movem.l	d0-d6/a0/a1/a2/a5,-(sp)

		moveq	#-1,d4
		moveq	#DL_Width,d5
		moveq	#6,d6

CR_wb1		btst	d6,(a5)		; Waiting for the Blitter...
		bne.b	CR_wb1

		move.w	d4,bltbdat-2(a5)
		move.w	#$8000,bltadat-2(a5)
		move.w	d5,bltcmod-2(a5)
		move.w	d5,bltdmod-2(a5)

		cmp.w	d1,d3		; Drawing only from Top to Bottom is
		bge.s	CR_.y1ly2	; necessary for:
		exg	d0,d2		; 1) Up-down Differences (same coords)
		exg	d1,d3		; 2) Blitter Invert Bit (only at top of
					;    line)
CR_.y1ly2	sub.w	d1,d3		; D3 = yd

		move.l	CR_MulTable(pc),a2
		add.w	d1,d1
		move.w	(a2,d1.w),d1

		add.w	d1,a0		; Please don't use add.w here !!!
		moveq	#0,d1		; D1 = Quant-Counter
		sub.w	d0,d2		; D2 = xd
		bge.s	CR_.xdpos
		addq.w	#2,d1		; Set Bit 1 of Quant-Counter (here it
					; could be a moveq)
		neg.w	d2
CR_.xdpos	moveq	#$f,d4		; D4 full cleaned (for later oktants
					; move.b)
		and.w	d0,d4
	IFNE	DL_Fill
		move.b	d4,d5		; D5 = Special Fill Bit
		not.b	d5
	ENDC
		lsr.w	#3,d0		; Yeah, on byte (necessary for bchg)...
		add.w	d0,a0		; ...Blitter ands automagically
		ror.w	#4,d4		; D4 = Shift
		or.w	#$B00+DL_MInterns,d4	; BLTCON0-codes
		swap	d4
		cmp.w	d2,d3		; Which Delta is the Biggest ?
		bge.s	CR_.dygdx
		addq.w	#1,d1		; Set Bit 0 of Quant-Counter
		exg	d2,d3		; Exchange xd with yd
CR_.dygdx	add.w	d2,d2		; D2 = xd*2
		move.w	d2,d0		; D0 = Save for $52(a5)
		sub.w	d3,d0		; D0 = xd*2-yd
		addx.w	d1,d1		; Bit0 = Sign-Bit
		move.b	CR_Oktants(PC,d1.w),d4	; In Low Byte of d4
						; (upper byte cleaned above)
		swap	d2
		move.w	d0,d2
		sub.w	d3,d2		; D2 = 2*(xd-yd)
		moveq	#6,d1		; D1 = ShiftVal (not necessary) 
					; + TestVal for the Blitter
		lsl.w	d1,d3		; D3 = BLTSIZE
		add.w	#$42,d3
		lea	bltapt+2-2(a5),a1	; A1 = CUSTOM+$52

; WARNING : If you use FastMem and an extreme DMA-Access (e.g. 6
; Planes and Copper), you should Insert a tst.b (a5) here (for the
; shitty AGNUS-BUG)

CR_wb2		btst	d1,(a5)		; Waiting for the Blitter...
		bne.b	CR_wb2
	IFNE	DL_Fill
		bchg	d5,(a0)		; Inverting the First Bit of Line
	ENDC

		move.l	d4,bltcon0-2(a5)	; Writing to the Blitter Regs as fast
		move.l	d2,bltbmod-2(a5)	; as possible
		move.l	a0,bltcpt-2(a5)
		move.w	d0,(a1)+
		move.l	a0,(a1)+	; Shit-Word Buffer Ptr...
		move.w	d3,(a1)

		movem.l	(sp)+,d0-d6/a0/a1/a2/a5
		rts


; -----------------------------------------------------------------------------
; Special data
; -----------------------------------------------------------------------------

CR_Oktants	DC.B	SML+1,SML+1+$40
		DC.B	SML+17,SML+17+$40
		DC.B	SML+9,SML+9+$40
		DC.B	SML+21,SML+21+$40


CR_MemEntry	DCB.B	14
		DC.W	14
	DC.L	MEMF_PUBLIC,CR_SCREEN_HEIGHT*2			; MulTable
	DC.L	MEMF_PUBLIC,321*8+4				; HScalingBuffer
	DC.L	MEMF_PUBLIC,257*8				; VScalingBuffer
	DC.L	MEMF_PUBLIC,(CR_OBSERVER_Z+1)*2			; PerspTable
	DC.L	MEMF_CHIP+MEMF_CLEAR,CR_PLANE_SIZE*5		; BVRAM
	DC.L	MEMF_CHIP+MEMF_CLEAR,CR_PLANE_SIZE*CR_ANIM_FRAMES	; Anim0
	DC.L	MEMF_CHIP+MEMF_CLEAR,CR_PLANE_SIZE*CR_ANIM_FRAMES	; Anim1
	DC.L	MEMF_CHIP+MEMF_CLEAR,CR_PLANE_SIZE*CR_ANIM_FRAMES	; Anim2
	DC.L	MEMF_CHIP+MEMF_CLEAR,CR_PLANE_SIZE*CR_ANIM_FRAMES	; Anim3
	DC.L	MEMF_CHIP+MEMF_CLEAR,CR_PLANE_SIZE*CR_ANIM_FRAMES	; Anim4
	DC.L	MEMF_CHIP+MEMF_CLEAR,CR_PLANE_SIZE*CR_ANIM_FRAMES	; Anim5
	DC.L	MEMF_CHIP+MEMF_CLEAR,CR_PLANE_SIZE*CR_ANIM_FRAMES	; Anim6
	DC.L	MEMF_CHIP+MEMF_CLEAR,CR_PLANE_SIZE*CR_ANIM_FRAMES	; Anim7
	DC.L	MEMF_CHIP+MEMF_CLEAR,CR_PLANE_SIZE		; NullAnim

CR_MemEntryPtr	DC.L	0

CR_NullAnim	DC.L	0
CR_Anim0	DC.L	0
CR_Anim1	DC.L	0
CR_Anim2	DC.L	0
CR_Anim3	DC.L	0
CR_Anim4	DC.L	0
CR_Anim5	DC.L	0
CR_Anim6	DC.L	0
CR_Anim7	DC.L	0
CR_CurrentAnimFrame	DC.L	0
CR_PosTable1	DC.L	0
CR_PosTable2	DC.L	0

CR_Raw0		DC.L	0
CR_Raw1		DC.L	0
CR_Raw2		DC.L	0
CR_Raw3		DC.L	0
CR_Raw4		DC.L	0
CR_Raw5		DC.L	0
CR_Raw6		DC.L	0
CR_Raw7		DC.L	0
CR_ManipulationsMotif
		DC.L	0
CR_MMPalette	DC.L	0

CR_MulTable	DC.L	0

CR_SourceRawMap	DC.L	CR_Raw0
		DC.W	32
		DC.W	0,0
		DC.W	254,60

CR_DestRawMap	DC.L	0
		DC.W	40
		DC.W	10,0
		DC.W	300,256

CR_HScalingBuffer	DC.L	0
CR_VScalingBuffer	DC.L	0

CR_PerspTable	DC.L	0

CR_Planes	DC.L	0,0,0,0
CR_PBuffer	DC.L	0

CR_Positions	DC.W	0,0,0,0,2,6	; x,y,pos1,pos2,dpos1,dpos2
		DC.W	0,0,200,1000,-2,-4
	
CR_NODE_POINTS_NUMBER	=	36

CR_NodePoints	DC.W	0,0,3
		DC.W	32,0,0
		DC.W	64,0,0
		DC.W	96,0,0
		DC.W	128,0,0
		DC.W	160,0,0
		DC.W	192,0,0
		DC.W	224,0,0
		DC.W	256,0,0
		DC.W	288,0,0
		DC.W	319,0,0
		DC.W	319,32,1
		DC.W	319,64,1
		DC.W	319,96,1
		DC.W	319,128,1
		DC.W	319,160,1
		DC.W	319,192,1
		DC.W	319,224,1
		DC.W	319,255,1
		DC.W	288,255,2
		DC.W	256,255,2
		DC.W	224,255,2
		DC.W	192,255,2
		DC.W	160,255,2
		DC.W	128,255,2
		DC.W	96,255,2
		DC.W	64,255,2
		DC.W	32,255,2
		DC.W	0,255,2
		DC.W	0,224,3
		DC.W	0,192,3
		DC.W	0,160,3
		DC.W	0,128,3
		DC.W	0,96,3
		DC.W	0,64,3
		DC.W	0,32,3

; -----------------------------------------------------------------------------

		SECTION	Credits_1,data

CR_Palette	DC.L	$000000,$110000,$220000,$330000
		DC.L	$440000,$550000,$660000,$770000
		DC.L	$880000,$990000,$aa0000,$bb0000
		DC.L	$cc0000,$dd0000,$ee0000,$ff0000
		REPT	16
		DC.L	$ffffff
		ENDR

; -----------------------------------------------------------------------------

		SECTION	Credits_2,data_c

CR_CopperList2	DC.W	bplpt+16,0
		DC.W	bplpt+18,0
CR_CopperList
		DC.W	bplpt,0
		DC.W	bplpt+2,0
		DC.W	bplpt+4,0
		DC.W	bplpt+6,0
		DC.W	bplpt+8,0
		DC.W	bplpt+10,0
		DC.W	bplpt+12,0
		DC.W	bplpt+14,0

		DC.L	-2

; -----------------------------------------------------------------------------

; =============================================================================

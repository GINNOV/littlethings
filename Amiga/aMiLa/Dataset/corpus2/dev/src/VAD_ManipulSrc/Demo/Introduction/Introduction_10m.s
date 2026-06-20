; =============================================================================
; -----------------------------------------------------------------------------
; File:		Introduction_xx.s
; Contents:	First part of demo (texture, lightsourceing, shading cube
;		with logo)
; Author:	Jacek (Noe) Cybularczyk / Venus Art
; Copyright:	©1994 by Noe
; -----------------------------------------------------------------------------
; History:
; -----------------------------------------------------------------------------
; 02.03.1995	Based on Cube_xx.s (revision 13/20)
; 		AGA 8-planes, shared ChunkyToPlanar converter (8/32-pixels)
; 03.03.1995	Debuging!
; 04.03.1995	Add space (stars)
; 08.03.1995	Space color <<8 in table
; 10.03.1995	Replace space-anim with space-picture
; 10.03.1995	Use new C2P procedure (with comparise buffer)
; 16.03.1995	Shared TC procedures
; 07.05.1995	Profi version directly to demo

; -----------------------------------------------------------------------------
; =============================================================================

ID_WIDTH	=	320
ID_HEIGHT	=	204
ID_DEPTH	=	8

ID_WIDTH2	=	ID_WIDTH>>1
ID_WIDTH_B	=	ID_WIDTH>>3
ID_WIDTH_W	=	ID_WIDTH>>4

ID_HEIGHT2	=	ID_HEIGHT>>1
ID_PLANE_SIZE	=	ID_WIDTH_B*ID_HEIGHT

ID_HOFFSET	=	$81
ID_VOFFSET	=	$2a+24

X_CUBE_SIZE	=	195
Y_CUBE_SIZE	=	81
Z_CUBE_SIZE	=	31
X_CUBE_SIZE2	=	X_CUBE_SIZE>>1
Y_CUBE_SIZE2	=	Y_CUBE_SIZE>>1
Z_CUBE_SIZE2	=	Z_CUBE_SIZE>>1

ID_PERSPECTIVE_Z	=	400
MAX_DISTANCE	=	1920
MIN_DISTANCE	=	-10
ID_MOVE_SPEED	=	80

NORMAL_LIGHT_VECTOR_LEN	=	1		; precalculated

NORMAL_FRONT_VECTOR_LEN	=	211		; precalculated
NORMAL_LEFT_VECTOR_LEN	=	87		; precalculated
NORMAL_TOP_VECTOR_LEN	=	197		; precalculated
ID_LIGHT_CONSTANT0	=	NORMAL_LIGHT_VECTOR_LEN*NORMAL_FRONT_VECTOR_LEN
ID_LIGHT_CONSTANT1	=	NORMAL_LIGHT_VECTOR_LEN*NORMAL_LEFT_VECTOR_LEN
ID_LIGHT_CONSTANT2	=	NORMAL_LIGHT_VECTOR_LEN*NORMAL_TOP_VECTOR_LEN

ID_BACKGROUND_LIGHT	=	8

; =============================================================================

		SECTION	Introduction_0,code

PLANE_SIZE	=	ID_PLANE_SIZE

Introduction
ID_Start	move.l	(a0),a0
		addq.w	#MAGIC_NUMBER,a0
		move.l	a0,ID_SinusTable
		adda.w	#23040,a0
		move.l	a0,ID_SpaceTable
		move.l	ID_SpaceTable,ID_SpacePointer
		adda.w	#15822,a0
		move.l	a0,ID_ShadePalette
		adda.w	#4096,a0
		move.l	a0,ID_Palette
		adda.w	#2976,a0
		move.l	a0,ID_Txt1Ptr
		adda.w	#15795,a0
		move.l	a0,ID_Txt1bPtr
		adda.w	#15795,a0
		move.l	a0,ID_Txt1cPtr
		adda.w	#15795,a0
		move.l	a0,ID_Txt2Ptr
		adda.w	#15795,a0
		move.l	a0,ID_Txt3Ptr
		adda.w	#2511,a0
		move.l	a0,ID_Txt4Ptr
		adda.w	#2511,a0
		move.l	a0,ID_Txt5Ptr
		adda.w	#6045,a0
		move.l	a0,ID_Txt6Ptr


		move.w	dmaconr+CUSTOM,OldDMACon
		move.w	#$01f0,dmacon+CUSTOM

		move.w	#255,d7
		sub.l	a0,a0
		jsr	SetPalette

		AllocMemBlocks	ID_MemEntry
		bne.w	ID_AllocMemError
		move.l	d0,ID_MemEntryPtr

		bsr.w	ID_SetMemPtrs

		bsr.w	ID_InitMulTable

		bsr.w	ID_InitSinPtrTable

		bsr.w	ID_CreateSpaceFadeTable
		bsr.w	ID_CorectSpaceTable

		bsr.w	ID_InitScreen

		move.w	#550,d0
		bsr.w	ID_SynchroInit

		move.w	#0,ID_SpaceBright

		move.w	#30,ID_MovingCntr

ID_Loop0	bsr.w	ID_ClearScreen
		bsr.w	ID_RenderSpace
		bsr.w	ChunkyToPlanar
		bsr.w	ID_SwitchScreen

		move.w	ID_SpaceBright(pc),d0
		add.w	#16*2,d0
		cmpi.w	#16*16*2,d0
		beq.b	ID_Skip0
		move.w	d0,ID_SpaceBright
ID_Skip0
		subq.w	#1,ID_MovingCntr
		bne.b	ID_Loop0

		move.w	#0,ID_RotX
		move.w	#0,ID_RotY
		move.w	#0,ID_RotZ

		move.w	#0,ID_PosX
		move.w	#0,ID_PosY
		move.w	#5000,ID_PosZ

		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#-100,d3
		moveq	#0,d4
		moveq	#55,d7
		bsr.w	ID_Moving

		bsr.w	ID_MoveSpace

		move.w	#700,d0
		bsr.w	ID_SynchroInit

		moveq	#4,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#50,d3
		move.w	#1000,d4
		moveq	#18,d7
		bsr.w	ID_Moving

		move.l	ID_Txt1bPtr,ID_Txt1Ptr

		moveq	#4,d0
		moveq	#-4,d1
		moveq	#0,d2
		moveq	#-50,d3
		move.w	#0,d4
		moveq	#18,d7
		bsr.w	ID_Moving

		moveq	#-2,d0
		moveq	#0,d1
		moveq	#-2,d2
		moveq	#0,d3
		move.w	#0,d4
		moveq	#36,d7
		bsr.w	ID_Moving

		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		move.w	#0,d4
		moveq	#1,d7
		bsr.w	ID_Moving

		bsr.w	ID_MoveSpace

		move.w	#730,d0
		bsr.w	ID_SynchroInit

		moveq	#0,d0
		moveq	#0,d1
		moveq	#8,d2
		moveq	#100,d3
		move.w	#2000,d4
		moveq	#18,d7
		bsr.w	ID_Moving

		move.l	ID_Txt1cPtr,ID_Txt1Ptr

		moveq	#6,d0
		moveq	#6,d1
		moveq	#2,d2
		moveq	#-50,d3
		move.w	#0,d4
		moveq	#36,d7
		bsr.w	ID_Moving

		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#-10,d3
		move.w	#-50,d4
		moveq	#6,d7
		bsr.w	ID_Moving

		move.w	#16,ID_MovingCntr

ID_Loop1	bsr.w	ID_ClearScreen
		bsr.w	ID_RenderSpace
		bsr.w	ID_CalcNodePoints
		bsr.w	ID_DisplayCube
		bsr.w	ChunkyToPlanar
		bsr.w	ID_SwitchScreen

		move.w	ID_SpaceBright(pc),d0
		sub.w	#16*2,d0
		bmi.b	ID_Skip1
		move.w	d0,ID_SpaceBright
ID_Skip1
		subq.w	#1,ID_MovingCntr
		bne.b	ID_Loop1

		bsr.w	ID_Synchronized

		bsr.w	ID_FadeOut

stop
		bset.b	#7,OldDMACon
		move.w	OldDMACon(pc),dmacon+CUSTOM

		FreeMemBlocks	ID_MemEntryPtr

ID_AllocMemError
		moveq	#0,d0
		rts


ID_Transform3D
		move.w	ID_PosZ,d0
		addi.w	#ID_PERSPECTIVE_Z,d0
		move.l	#ID_PERSPECTIVE_Z*256,d1
		divu	d0,d1
		move.w	d1,ID_DistScale

		rts


ID_MoveSpace	bsr.w	ID_ClearScreen
		bsr.w	ID_RenderSpace
		bsr.w	ID_CalcNodePoints
		bsr.w	ID_DisplayCube
		bsr.w	ChunkyToPlanar
		bsr.w	ID_SwitchScreen

		tst.w	SynchroCntr
		bne.b	ID_MoveSpace

		rts


ID_Synchronized	tst.w	SynchroCntr
		bne.b	ID_Synchronized

		rts


ID_SynchroInit	move.w	d0,SynchroCntr
		rts


ID_Moving	move.w	d0,ID_RotXSpeed
		move.w	d1,ID_RotYSpeed
		move.w	d2,ID_RotZSpeed
		move.w	d3,ID_MoveZSpeed
		move.w	d4,ID_MoveZDest
		move.w	d7,ID_MovingCntr

ID_m_Loop	bsr.w	ID_Transform3D
		bsr.w	ID_ClearScreen
		bsr.w	ID_RenderSpace

		bsr.w	ID_CalcNodePoints
		bsr.w	ID_DisplayCube

		bsr.w	ChunkyToPlanar
		bsr.w	ID_SwitchScreen

		move.w	ID_PosZ,d0
		add.w	ID_MoveZSpeed,d0
		cmp.w	ID_MoveZDest,d0
		beq.b	ID_m0

		move.w	d0,ID_PosZ
ID_m0
		move.w	ID_RotZ,d0
		add.w	ID_RotZSpeed,d0
		bpl.b	ID_m1
		addi.w	#144,d0
ID_m1		cmpi.w	#144,d0
		blt.b	ID_m2
		subi.w	#144,d0
ID_m2		move.w	d0,ID_RotZ

		move.w	ID_RotY,d0
		add.w	ID_RotYSpeed,d0
		bpl.b	ID_m3
		addi.w	#144,d0
ID_m3		cmpi.w	#144,d0
		blt.b	ID_m4
		subi.w	#144,d0
ID_m4		move.w	d0,ID_RotY

		move.w	ID_RotX,d0
		add.w	ID_RotXSpeed,d0
		bpl.b	ID_m5
		addi.w	#144,d0
ID_m5		cmpi.w	#144,d0
		blt.b	ID_m6
		subi.w	#144,d0
ID_m6		move.w	d0,ID_RotX
		subq.w	#1,ID_MovingCntr
		bne.w	ID_m_Loop

		rts


ID_FadeOut	move.w	#8,ID_MovingCntr

ID_fo_Loop0	move.l	ID_Palette,a0
		move.w	#255,d7

ID_fo_Loop1	move.l	(a0),d0
		lsr.l	#1,d0
		andi.l	#$007f7f7f,d0
		move.l	d0,(a0)+

		dbra	d7,ID_fo_Loop1

		move.w	#2,d0
		jsr	Wait

		move.l	ID_Palette,a0
		move.w	#255,d7
		jsr	SetPalette

		subq.w	#1,ID_MovingCntr
		bne.b	ID_fo_Loop0

		rts


; ===========================================================================
; Procedure:	ID_SetMemPtrs
; Function:	Set pointers to allocated memory blocks
; In:
;	none
; Out:
;	none
; Crash regs:
;	a0,d0
; ===========================================================================

ID_SetMemPtrs
		move.l	ID_MemEntryPtr,a0
		lea	14+2(a0),a0

		move.l	(a0),ID_MulTable
		move.l	8(a0),ChunkyMap
		move.l	16(a0),d0
		addq.l	#4,d0
		andi.l	#$fffffff8,d0
		move.l	d0,ID_VRAM_Display
		move.l	24(a0),d0
		addq.l	#4,d0
		andi.l	#$fffffff8,d0
		move.l	d0,ID_VRAM_Render
		move.l	32(a0),ID_CopperList
		move.l	40(a0),ID_SinPtrTable
		move.l	48(a0),ID_NodePoints
		move.l	56(a0),ID_HGouraudTable
		move.l	64(a0),ID_HLineBuffer
		move.l	72(a0),ID_VLineBuffer
		move.l	80(a0),ID_HScalingBuffer
		move.l	88(a0),ID_VScalingBuffer
		move.l	96(a0),ID_VGouraudTable1
		move.l	104(a0),ID_VGouraudTable2
		move.l	112(a0),ID_SpaceFade

		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_CreateSpaceFadeTable
; Function:	Create table for fading (in/out) of space
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ID_CreateSpaceFadeTable
		move.l	ID_SpaceFade(pc),a0

		moveq	#0,d0
ID_csft_Loop1	moveq	#0,d1

ID_csft_Loop0	move.w	d1,d2
		mulu	d0,d2
		divu	#15,d2
		lsl.w	#8,d2
		move.w	d2,(a0)+

		addq.w	#1,d1
		cmpi.w	#16,d1
		blt.b	ID_csft_Loop0

		addq.w	#1,d0
		cmpi.w	#16,d0
		blt.b	ID_csft_Loop1

		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_CorectSpaceTable
; Function:	Right shift bright value
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ID_CorectSpaceTable
		move.l	ID_SpaceTable(pc),a0

ID_cst_Loop	tst.l	(a0)
		beq.b	ID_cst_End

		move.w	4(a0),d0
		lsr.w	#7,d0
		move.w	d0,4(a0)
		addq.w	#6,a0
		bra.b	ID_cst_Loop
ID_cst_End
		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_InitSinPtrTable
; Function:	Initialize SinPtrTable
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ID_InitSinPtrTable
		move.l	ID_SinPtrTable(pc),a0
		move.w	#128,d0
		move.w	#89,d1

ID_ispt_Loop	move.w	d0,(a0)+
		addi.w	#256,d0
		dbra	d1,ID_ispt_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_InitMulTable
; Function:	Initialize MulTable
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ID_InitMulTable
		move.l	ID_MulTable(pc),a0
		move.l	ChunkyMap,a1
		move.w	#ID_HEIGHT-1,d0

ID_imt_Loop	move.l	a1,(a0)+
		lea	ID_WIDTH(a1),a1
		dbra	d0,ID_imt_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_InitScreen
; Function:	Initialize planes and copper list
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ID_InitScreen	movem.l	d0-d7/a0-a6,-(sp)

		lea	CUSTOM,a5

		move.w	#(ID_VOFFSET<<8)+ID_HOFFSET,diwstrt(a5)
 move.w	#(((ID_VOFFSET+ID_HEIGHT)&$00ff)<<8)+((ID_HOFFSET+ID_WIDTH)&$00ff),diwstop(a5)

		move.w	#(ID_HOFFSET>>1)-8,ddfstrt(a5)
		move.w	#(ID_HOFFSET>>1)-8+((ID_WIDTH_W-1)<<3),ddfstop(a5)

		move.w	#-8,bpl1mod(a5)
		move.w	#-8,bpl2mod(a5)

		move.l	#$02100000,bplcon0(a5)
		move.w	#0,bplcon2(a5)

		move.w	#$0003,fmode(a5)

		move.l	ID_CopperList,a0
		move.l	ID_VRAM_Display,d0
		moveq	#ID_DEPTH-1,d7
		moveq	#ID_DEPTH,d1
		jsr	SetCopperBplPtrs

		move.l	ID_CopperList,a0
		move.l	#-2,64(a0)

		bsr.b	ID_SwitchScreen

		move.l	ID_CopperList,cop1lc(a5)
		move.w	#0,copjmp1(a5)

		move.l	ID_Palette,a0
		move.w	#255,d7
		jsr	SetPalette

		lea	CUSTOM,a5
		move.w	#$83c0,dmacon(a5)

		movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_SwitchScreen
; Function:	Switch render and display screen
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ID_SwitchScreen	movem.l	d0-d2/a0/a1/a5,-(sp)

		move.l	ID_VRAM_Display(pc),a0
		move.l	ID_VRAM_Render(pc),a1
		move.l	a1,ID_VRAM_Display
		move.l	a0,ID_VRAM_Render

		move.l	ID_CopperList,a0
		addq.w	#2,a0
		lea	CUSTOM+vposr,a5
		moveq	#ID_DEPTH-1,d2

		move.l	a1,d1

ss_wait		move.l	(a5),d0
		andi.l	#$0001ff00,d0
		cmpi.l	#$00012d00,d0
		bne.b	ss_wait

ss_loop		swap	d1
		move.w	d1,(a0)
		swap	d1
		move.w	d1,4(a0)
		addq.w	#8,a0
		addi.l	#ID_WIDTH_B*ID_HEIGHT,d1
		dbra	d2,ss_loop

		movem.l	(sp)+,d0-d2/a0/a1/a5
		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_ClearScreen
; Function:	Clear render screen
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ID_ClearScreen	movem.l	d0-d7/a0/a6,-(sp)

		lea	CUSTOM+2,a0		; blitter phase...
		moveq	#0,d0

ID_cs_WaitBlitter	btst	#6,(a0)
		bne.b	ID_cs_WaitBlitter

		move.l	ChunkyMap,bltdpt-2(a0)
		move.l	#$01000000,bltcon0-2(a0)
		move.w	d0,bltdmod-2(a0)
		move.w	#(ID_HEIGHT<<6)+(ID_WIDTH2>>2),bltsize-2(a0)

		moveq	#0,d1			; ...and processor phase
		moveq	#0,d2			; blitter:processor = 1:3
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		movea.l	d0,a0

		move.l	ChunkyMap,a6
		adda.l	#ID_WIDTH*ID_HEIGHT,a6
		move.w	#(ID_WIDTH*ID_HEIGHT/32/4*3)-1,d7

ID_cs_Loop		movem.l	d0-d6/a0,-(a6)
		dbra	d7,ID_cs_Loop

		movem.l	(sp)+,d0-d7/a0/a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_CalcNodePoints
; Function:	Calculate 8 node points
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ID_CalcNodePoints
		move.l	ID_SinPtrTable(pc),a6

		move.w	ID_RotX(pc),d0
		move.w	(a6,d0.w),d0
		move.l	ID_SinusTable(pc),a0
		lea	(a0,d0.w),a0
		lea	18*256(a0),a1

		move.w	ID_RotY(pc),d0
		move.w	(a6,d0.w),d0
		move.l	ID_SinusTable(pc),a2
		lea	(a2,d0.w),a2

		lea	18*256(a2),a3

		move.w	ID_RotZ(pc),d0
		move.w	(a6,d0.w),d0
		move.l	ID_SinusTable(pc),a4
		lea	(a4,d0.w),a4
		lea	18*256(a4),a5

		move.l	ID_NodePoints(pc),a6

		move.w	#-Z_CUBE_SIZE2,d3
		move.w	#-X_CUBE_SIZE2,d4
		move.w	#-Y_CUBE_SIZE2,d5
		move.w	#X_CUBE_SIZE2,d6
		move.w	#Y_CUBE_SIZE2,d7

; calculate point -X_WALL_SIZE2, -Y_WALL_SIZE2, -Z_WALL_SIZE2

		move.b	(a5,d4.w),d0
		add.b	(a4,d5.w),d0
		move.b	(a5,d5),d1
		sub.b	(a4,d4),d1
		ext.w	d0			; x
		ext.w	d1			; y
		move.b	(a3,d0.w),d2
		sub.b	(a2,d3.w),d2
		move.b	(a2,d0.w),d0
		add.b	(a3,d3.w),d0
		ext.w	d2			; x
		ext.w	d0			; z
		move.w	d2,P1(a6)
		neg.w	d2
		move.w	d2,P7(a6)
		move.b	(a1,d1.w),d2
		add.b	(a0,d0.w),d2
		move.b	(a1,d0.w),d0
		sub.b	(a0,d1.w),d0
		ext.w	d2			; y
		ext.w	d0			; z
		move.w	d2,P1+2(a6)
		neg.w	d2
		move.w	d2,P7+2(a6)
		move.w	d0,P1+4(a6)
		neg.w	d0
		move.w	d0,P7+4(a6)

; calculate point X_WALL_SIZE2, -Y_WALL_SIZE2, -Z_WALL_SIZE2

		move.b	(a5,d6.w),d0
		add.b	(a4,d5.w),d0
		move.b	(a5,d5.w),d1
		sub.b	(a4,d6.w),d1
		ext.w	d0			; x
		ext.w	d1			; y
		move.b	(a3,d0.w),d2
		sub.b	(a2,d3.w),d2
		move.b	(a2,d0.w),d0
		add.b	(a3,d3.w),d0
		ext.w	d2			; x
		ext.w	d0			; z
		move.w	d2,P2(a6)
		neg.w	d2
		move.w	d2,P8(a6)
		move.b	(a1,d1.w),d2
		add.b	(a0,d0.w),d2
		move.b	(a1,d0.w),d0
		sub.b	(a0,d1.w),d0
		ext.w	d2			; y
		ext.w	d0			; z
		move.w	d2,P2+2(a6)
		neg.w	d2
		move.w	d2,P8+2(a6)
		move.w	d0,P2+4(a6)
		neg.w	d0
		move.w	d0,P8+4(a6)

; calculate point X_WALL_SIZE2, Y_WALL_SIZE2, -Z_WALL_SIZE2

		move.b	(a5,d6.w),d0
		add.b	(a4,d7.w),d0
		move.b	(a5,d7.w),d1
		sub.b	(a4,d6.w),d1
		ext.w	d0			; x
		ext.w	d1			; y
		move.b	(a3,d0.w),d2
		sub.b	(a2,d3.w),d2
		move.b	(a2,d0.w),d0
		add.b	(a3,d3.w),d0
		ext.w	d2			; x
		ext.w	d0			; z
		move.w	d2,P3(a6)
		neg.w	d2
		move.w	d2,P5(a6)
		move.b	(a1,d1.w),d2
		add.b	(a0,d0.w),d2
		move.b	(a1,d0.w),d0
		sub.b	(a0,d1.w),d0
		ext.w	d2			; y
		ext.w	d0			; z
		move.w	d2,P3+2(a6)
		neg.w	d2
		move.w	d2,P5+2(a6)
		move.w	d0,P3+4(a6)
		neg.w	d0
		move.w	d0,P5+4(a6)

; calculate point -X_WALL_SIZE2, Y_WALL_SIZE2, -Z_WALL_SIZE2

		move.b	(a5,d4.w),d0
		add.b	(a4,d7.w),d0
		move.b	(a5,d7.w),d1
		sub.b	(a4,d4.w),d1
		ext.w	d0			; x
		ext.w	d1			; y
		move.b	(a3,d0.w),d2
		sub.b	(a2,d3.w),d2
		move.b	(a2,d0.w),d0
		add.b	(a3,d3.w),d0
		ext.w	d2			; x
		ext.w	d0			; z
		move.w	d2,P4(a6)
		neg.w	d2
		move.w	d2,P6(a6)
		move.b	(a1,d1.w),d2
		add.b	(a0,d0.w),d2
		move.b	(a1,d0.w),d0
		sub.b	(a0,d1.w),d0
		ext.w	d2			; y
		ext.w	d0			; z
		move.w	d2,P4+2(a6)
		neg.w	d2
		move.w	d2,P6+2(a6)
		move.w	d0,P4+4(a6)
		neg.w	d0
		move.w	d0,P6+4(a6)

		rts


; -----------------------------------------------------------------------------
; Procedures:	ID_DisplayCube
; Function:	Display cube
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ID_DisplayCube
		bsr.w	ID_CalcGouraudPass1

		move.l	ID_NodePoints(pc),a1

ID_TMP0		SET	0
		REPT	8

	IFEQ	ID_TMP0
		move.w	(a1),d0
	ELSE
		move.w	ID_TMP0(a1),d0
	ENDC
		muls	ID_DistScale(pc),d0
		asr.l	#8,d0
		add.w	#ID_WIDTH2,d0
		add.w	ID_PosX(pc),d0
	IFEQ	ID_TMP0
		move.w	d0,(a1)
	ELSE
		move.w	d0,ID_TMP0(a1)
	ENDC
		move.w	ID_TMP0+2(a1),d0
		muls	ID_DistScale(pc),d0
		asr.l	#8,d0
		add.w	#ID_HEIGHT2,d0
		add.w	ID_PosY(pc),d0
		move.w	d0,ID_TMP0+2(a1)

ID_TMP0		SET	ID_TMP0+8
		ENDR

		move.w	P1+4(a1),d0
		cmp.w	P5+4(a1),d0
		beq.b	ID_dc1a
		bgt.b	ID_dc0
		move.l	ID_Txt1Ptr(pc),a0
		moveq	#P1,d0
		moveq	#P2,d1
		moveq	#P3,d2
		moveq	#P4,d3
		bra.b	ID_dc1

ID_dc0		move.l	ID_Txt2Ptr(pc),a0
		moveq	#P6,d0
		moveq	#P5,d1
		moveq	#P8,d2
		moveq	#P7,d3
ID_dc1		move.w	#X_CUBE_SIZE,ID_HTextureSize+2
		move.w	#Y_CUBE_SIZE,ID_VTextureSize+2
		bsr.w	ID_DisplayWall

ID_dc1a		move.w	P1+4(a1),d0
		cmp.w	P2+4(a1),d0
		beq.b	ID_dc3a
		bgt.b	ID_dc2
		move.l	ID_Txt3Ptr(pc),a0
		moveq	#P4,d0
		moveq	#P8,d1
		moveq	#P5,d2
		moveq	#P1,d3
		bra.b	ID_dc3

ID_dc2		move.l	ID_Txt4Ptr(pc),a0
		moveq	#P2,d0
		moveq	#P6,d1
		moveq	#P7,d2
		moveq	#P3,d3
ID_dc3		move.w	#Y_CUBE_SIZE,ID_HTextureSize+2
		move.w	#Z_CUBE_SIZE,ID_VTextureSize+2
		bsr.w	ID_DisplayWall

ID_dc3a		move.w	P1+4(a1),d0
		cmp.w	P4+4(a1),d0
		beq.b	ID_dc5a
		bgt.b	ID_dc4
		move.l	ID_Txt5Ptr(pc),a0
		moveq	#P2,d0
		moveq	#P1,d1
		moveq	#P5,d2
		moveq	#P6,d3
		bra.b	ID_dc5

ID_dc4		move.l	ID_Txt6Ptr(pc),a0
		moveq	#P4,d0
		moveq	#P3,d1
		moveq	#P7,d2
		moveq	#P8,d3
ID_dc5		move.w	#X_CUBE_SIZE,ID_HTextureSize+2
		move.w	#Z_CUBE_SIZE,ID_VTextureSize+2
		bsr.w	ID_DisplayWall

ID_dc5a		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_CalcLightPoint
; Function:	Calculate Lighting of point
; In:
;	d0.w	offset to 1st node point	; start of vectors
;	d1.w	offset to 2nd node point	; end of first vector
;	d2.w	offset to 3rd node point	; end of secon vector
; Out:
;	d2.w	bright of point
; -----------------------------------------------------------------------------

ID_CalcLightPoint
		movem.l	d0/d1/d3-d7/a0,-(sp)

		move.l	ID_NodePoints(pc),a0

		move.w	(a0,d2.w),d5
		move.w	2(a0,d2.w),d6
		sub.w	(a0,d0.w),d5
		sub.w	2(a0,d0.w),d6

		move.w	(a0,d1.w),d2
		move.w	2(a0,d1.w),d3
		sub.w	(a0,d0.w),d2
		sub.w	2(a0,d0.w),d3

; d3*d7-d6*d4,d5*d4-d2*d7,d2*d6-d5*d3

		muls	d6,d2
		muls	d3,d5
		sub.l	d5,d2		; d2=nz

; d0,d1,d2
;		muls	#ID_LIGHT_Z,d2	; LIGHT_Z=1

		movem.l	(sp)+,d0/d1/d3-d7/a0
		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_CalcGouraudPass1
; Function:	Calculate Gouraud smothing (pass 1)
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ID_CalcGouraudPass1
		move.w	#P1,d0
		move.w	#P2,d1
		move.w	#P4,d2
		bsr.b	ID_CalcLightPoint
		divs	#ID_LIGHT_CONSTANT2,d2
		move.w	d2,d7
		addq.w	#ID_BACKGROUND_LIGHT,d7
		cmpi.w	#15,d7
		ble.b	ID_cgp_0
		moveq	#15,d7

ID_cgp_0
		move.w	#P1,d0
		move.w	#P4,d1
		move.w	#P5,d2
		bsr.b	ID_CalcLightPoint
		divs	#ID_LIGHT_CONSTANT1,d2
		move.w	d2,d6
		addq.w	#ID_BACKGROUND_LIGHT,d6
		cmpi.w	#15,d6
		ble.b	ID_cgp_1
		moveq	#15,d6

ID_cgp_1
		move.w	#P1,d0
		move.w	#P5,d1
		move.w	#P2,d2
		bsr.w	ID_CalcLightPoint
		divs	#ID_LIGHT_CONSTANT0,d2
		move.w	d2,d5
		addq.w	#ID_BACKGROUND_LIGHT,d5
		cmpi.w	#15,d5
		ble.b	ID_cgp_2
		moveq	#15,d5

ID_cgp_2
		move.w	#P7,d0
		move.w	#P6,d1
		move.w	#P8,d2
		bsr.w	ID_CalcLightPoint
		divs	#ID_LIGHT_CONSTANT2,d2
		move.w	d2,d4
		addq.w	#ID_BACKGROUND_LIGHT,d4
		cmpi.w	#15,d4
		ble.b	ID_cgp_3
		moveq	#15,d4

ID_cgp_3
		move.w	#P7,d0
		move.w	#P3,d1
		move.w	#P6,d2
		bsr	ID_CalcLightPoint
		divs	#ID_LIGHT_CONSTANT1,d2
		move.w	d2,d3
		addq.w	#ID_BACKGROUND_LIGHT,d3
		cmpi.w	#15,d3
		ble.b	ID_cgp_4
		moveq	#15,d3

ID_cgp_4
		move.w	#P7,d0
		move.w	#P8,d1
		move.w	#P3,d2
		bsr	ID_CalcLightPoint
		divs	#ID_LIGHT_CONSTANT0,d2
		addq.w	#ID_BACKGROUND_LIGHT,d2
		cmpi.w	#15,d2
		ble.b	ID_cgp_5
		moveq	#15,d2

ID_cgp_5
		lsl.w	#8,d2
		lsl.w	#8,d3
		lsl.w	#8,d4
		lsl.w	#8,d5
		lsl.w	#8,d6
		lsl.w	#8,d7

		move.l	ID_NodePoints(pc),a0

		move.w	d5,d0
		add.w	d6,d0
		add.w	d7,d0
		ext.l	d0
		divs	#3,d0
		move.w	d0,P1+6(a0)

		move.w	d3,d0
		add.w	d5,d0
		add.w	d7,d0
		ext.l	d0
		divs	#3,d0
		move.w	d0,P2+6(a0)

		move.w	d2,d0
		add.w	d3,d0
		add.w	d7,d0
		ext.l	d0
		divs	#3,d0
		move.w	d0,P3+6(a0)

		move.w	d2,d0
		add.w	d6,d0
		add.w	d7,d0
		ext.l	d0
		divs	#3,d0
		move.w	d0,P4+6(a0)

		move.w	d4,d0
		add.w	d5,d0
		add.w	d6,d0
		ext.l	d0
		divs	#3,d0
		move.w	d0,P5+6(a0)

		move.w	d3,d0
		add.w	d4,d0
		add.w	d5,d0
		ext.l	d0
		divs	#3,d0
		move.w	d0,P6+6(a0)

		move.w	d2,d0
		add.w	d3,d0
		add.w	d4,d0
		ext.l	d0
		divs	#3,d0
		move.w	d0,P7+6(a0)

		move.w	d2,d0
		add.w	d4,d0
		add.w	d6,d0
		ext.l	d0
		divs	#3,d0
		move.w	d0,P8+6(a0)

		rts


; -----------------------------------------------------------------------------
; Procedures:	ID_InterpolationLine
; Function:	Interpolation line to buffer
; In:
;	d4.w	x1
;	d5.w	y1
;	d6.w	x2
;	d7.w	y2
;	a1.l	pointer to buffer
; Out:
;	d1.w	number of points
; -----------------------------------------------------------------------------

ID_InterpolationLine
		movem.l	d0/d2-d7/a0-a6,-(sp)

		cmp.w	d4,d6
		bne.b	ID_il_00
		cmp.w	d5,d7
		beq.w	ID_il_ZeroLen

ID_il_00	move.l	a1,ID_aux0

		moveq	#1,d0
		move.w	d7,d1
		sub.w	d5,d1
		move.w	#ID_WIDTH,d2
		swap	d2
		move.w	#1,d2
		move.w	d4,d3
		sub.w	d6,d3

		cmp.w	d4,d6
		bgt.b	ID_il0
		neg.w	d0
		neg.w	d1
ID_il0		cmp.w	d5,d7
		bgt.b	ID_il1
		neg.w	d2
		swap	d2
		neg.w	d2
		swap	d2
		neg.w	d3
ID_il1
		movea	d6,a0
		movea	d7,a6
; d0=dx d1=vx d2=dy d3=vy

		move.w	#0,a2			; fa

ID_il_Loop
		movea.w	a2,a3
		adda.w	d1,a3			; fx

		movea.w	a2,a4
		adda.w	d3,a4			; fy

		movea.w	a3,a5
		adda.w	a4,a5
		suba.w	a2,a5			; fxy

		move.w	a3,d6
		bpl.b	ID_il2
		neg.w	d6
ID_il2		move.w	a4,d7
		bpl.b	ID_il3
		neg.w	d7
ID_il3		cmp.w	d7,d6
		bgt.b	ID_il4
; ax<=ay
		move.w	a5,d7
		bpl.b	ID_il5
		neg.w	d7
ID_il5		cmp.w	d7,d6
		bgt.b	ID_il6
; ax<=ay and ax<=axy
		movea.w	a3,a2
		add.w	d0,d4
		move.w	d0,(a1)+
		bra.b	ID_il7
ID_il6
; (ax<=ay and ax>axy) or (ay<ax and ay>axy)
		movea.w	a5,a2
		add.w	d0,d4
		add.w	d2,d5
		move.w	d0,(a1)
		swap	d2
		add.w	d2,(a1)+
		swap	d2
		bra.b	ID_il7
ID_il4
; ay<ax
		move.w	a5,d6
		bpl.b	ID_il8
		neg.w	d6
ID_il8		cmp.w	d6,d7
		bgt.b	ID_il6
; ay<ax and ay<axy
		movea.w	a4,a2
		add.w	d2,d5
		swap	d2
		move.w	d2,(a1)+
		swap	d2

ID_il7		cmpa.w	d4,a0
		bne.b	ID_il_Loop
		cmpa.w	d5,a6
		bne.b	ID_il_Loop

		move.w	#0,(a1)+

		suba.l	ID_aux0(pc),a1
		move.w	a1,d1
		lsr.w	d1

		movem.l	(sp)+,d0/d2-d7/a0-a6
		rts

ID_il_ZeroLen	move.w	#0,(a1)
		moveq	#0,d1

		movem.l	(sp)+,d0/d2-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_VScalingTexture
; Function:	Scaling vertical texture
; In:
;	d1.w	destination size
; Out:
;	none
; -----------------------------------------------------------------------------

ID_VScalingTexture	
		movea.l	ID_VScalingBuffer(pc),a4
		move.l	ID_VTextureSize(pc),d6
		divu	d1,d6
		move.w	d6,d5
		swap	d6

; d6=float d7=integer

		subq.w	#1,d5
		move.w	ID_HTextureSize+2(pc),d7
		mulu	d7,d5
		moveq	#0,d3

		move.w	d1,d4
		subq.w	#1,d4

ID_vst_Loop	move.w	d5,a1
		add.w	d6,d3
		cmp.w	d1,d3
		blt.b	ID_vst0
		add.w	d7,a1
		sub.w	d1,d3
ID_vst0
		move.w	a1,(a4)+
		dbra	d4,ID_vst_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_HScalingTexture
; Function:	Scaling horizonthal texture
; In:
;	d2.w	destination size
; Out:
;	none
; -----------------------------------------------------------------------------

ID_HScalingTexture	
		movea.l	ID_HScalingBuffer(pc),a5
		move.l	ID_HTextureSize(pc),d6
		divu	d2,d6
		move.w	d6,d7
		swap	d6

; d6=float d7=integer

		move.w	ID_HTextureSize+2(pc),a1

		moveq	#0,d3
		move.w	d2,d4
		subq.w	#1,d4

ID_hst_Loop	move.w	d7,d5
		add.w	d6,d3
		cmp.w	d2,d3
		blt.b	ID_hst0
		addq.w	#1,d5
		sub.w	d2,d3
ID_hst0
		move.w	d5,(a5)+
		dbra	d4,ID_hst_Loop

		rts


; -----------------------------------------------------------------------------
; Procedures:	ID_DisplayWall
; Function:	Display one wall
; In:
;	d0.w	offset to 1st node point
;	d1.w	offset to 2nd node point
;	d2.w	offset to 3rd node point
;	d3.w	offset to 4th node point
;	a0.l	pointer to texture
; Out:
;	none
; -----------------------------------------------------------------------------

ID_DisplayWall	movem.l	d0-d7/a0-a6,-(sp)

		move.l	ID_NodePoints(pc),a2
		move.w	6(a2,d0.w),ID_Bright1
		move.w	6(a2,d1.w),ID_Bright2
		move.w	6(a2,d2.w),ID_Bright3
		move.w	6(a2,d3.w),ID_Bright4

		move.w	(a2,d0.w),d4
		move.w	2(a2,d0.w),d5
		move.w	(a2,d1.w),d6
		move.w	2(a2,d1.w),d7
		move.l	ID_HLineBuffer(pc),a1
		bsr.w	ID_InterpolationLine

		move.w	(a2,d3.w),d6
		move.w	2(a2,d3.w),d7
		move.w	d1,d2
		move.l	ID_VLineBuffer(pc),a1
		bsr.w	ID_InterpolationLine

		tst.w	d1
		beq.w	ID_dw_End1
		tst.w	d2
		beq.w	ID_dw_End1

; d1=vertical line length
; d2=horizonthal line length

		bsr.b	ID_CalcGouraudPass2

		bsr.w	ID_VScalingTexture

		bsr.w	ID_HScalingTexture

		movea.l	ID_NodePoints(pc),a1
		move.w	(a1,d0.w),d4
		move.w	2(a1,d0.w),d5
		move.l	([ID_MulTable,pc],d5.w*4),a3
		lea	(a3,d4.w),a3

;	d1.w	vertical line length
;	d2.w	horizonthal line length
;	a0.l	pointer to texture
;	a3.l	pointer to 1st point on chunky

		bsr.w	ID_CalcGouraudPass3

		move.l	ID_HGouraudTable(pc),a1
		move.l	ID_ShadePalette(pc),a2
		move.l	a3,d1
		move.l	ID_VLineBuffer(pc),a6
		moveq	#0,d2

ID_dw_Loop1	movea.l	ID_HScalingBuffer(pc),a4
		move.l	ID_HLineBuffer(pc),a5
		movea.l	d1,a3

ID_dw_Loop0	move.w	(a1)+,d0
		ble.b	ID_dw0
		move.b	(a0),d0
		move.b	(a2,d0.w),d0
		move.b	d0,(a3)
		move.b	d0,1(a3)

		adda.w	(a4)+,a0
		move.w	(a5)+,d0
		beq.b	ID_dw_End0
		adda.w	d0,a3
		bra.b	ID_dw_Loop0

ID_dw0		move.w	#0,(a3)
		adda.w	(a4)+,a0
		move.w	(a5)+,d0
		beq.b	ID_dw_End0
		adda.w	d0,a3
		bra.b	ID_dw_Loop0

ID_dw_End0	move.w	(a6)+,d0
		beq.b	ID_dw_End1

		ext.l	d0
		add.l	d0,d1
		adda.w	([ID_VScalingBuffer,pc],d2.w),a0
		addq.w	#2,d2
		bra.b	ID_dw_Loop1

ID_dw_End1	movem.l	(sp)+,d0-d7/a0-a6
		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_CalcGouraudPass2
; Function:	Calculate Gouraud smothing (pass 2)
; In:
;	d1.w	length of vertical line
; Out:
;	none
; -----------------------------------------------------------------------------

ID_CalcGouraudPass2
		movem.l	d0-d2/a0,-(sp)

		move.w	d1,d2

		movea.l	ID_VGouraudTable1(pc),a0
		move.w	ID_Bright1(pc),d0
		move.w	ID_Bright4(pc),d1
		bsr.b	ID_InterpolationLight

		movea.l	ID_VGouraudTable2(pc),a0
		move.w	ID_Bright2(pc),d0
		move.w	ID_Bright3(pc),d1
		bsr.b	ID_InterpolationLight

		movem.l	(sp)+,d0-d2/a0
		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_InterpolationLight
; Function:	Interpolation light between two points
; In:
;	d0.w	bright of 1st point
;	d1.w	bright of 2nd point
;	d2.w	distance between points
;	a0.l	pointer to destination table
; Out:
;	none
; -----------------------------------------------------------------------------

ID_InterpolationLight
		movem.l	d2-d4,-(sp)

;		(B2-B1)/(D-1)

		sub.w	d0,d1
		subq.w	#1,d2
		ext.l	d1
		divs	d2,d1
		move.w	d1,d3
		swap	d1
		move.w	d2,d5

		moveq	#0,d4
		moveq	#1,d6
		tst.w	d1
		bpl.b	ID_ill1
		neg.w	d1
		moveq	#-1,d6

ID_ill1		move.w	d0,(a0)+
		add.w	d3,d0
		add.w	d1,d4
		cmp.w	d5,d4
		blt.b	ID_ill0
		sub.w	d5,d4
		add.w	d6,d0
ID_ill0		dbra	d2,ID_ill1

		movem.l	(sp)+,d2-d4
		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_CalcGouraudPass3
; Function:	Calculate Gouraud smothing (pass 3)
; In:
;	d1.w	length of vertical line
;	d2.w	length of horizonthal line
; Out:
;	none
; -----------------------------------------------------------------------------

ID_CalcGouraudPass3
		move.l	ID_HGouraudTable(pc),a4
		movea.l	ID_VGouraudTable1(pc),a1
		movea.l	ID_VGouraudTable2(pc),a2

		subq.w	#1,d2

		moveq	#0,d7

ID_cgp3_Loop	move.w	(a1,d7.w*2),d0
		move.w	(a2,d7.w*2),d6

		sub.w	d0,d6
		ext.l	d6
		divs	d2,d6
		move.w	d6,d3
		swap	d6
		move.w	d2,d5

		moveq	#0,d4

		tst.w	d6
		bmi.b	ID_cgp3_3

ID_cgp3_0	move.w	d0,(a4)+
		add.w	d3,d0
		addq.w	#1,d4
		cmp.w	d2,d4
		blt.b	ID_cgp3_1
		sub.w	d2,d4
		addq.w	#1,d0
ID_cgp3_1	dbra	d5,ID_cgp3_0

		addq.w	#1,d7
		cmp.w	d1,d7
		bne.b	ID_cgp3_Loop

		rts

ID_cgp3_3	move.w	d0,(a4)+
		add.w	d3,d0
		subq.w	#1,d4
		cmp.w	d2,d4
		blt.b	ID_cgp3_4
		sub.w	d2,d4
		subq.w	#1,d0
ID_cgp3_4	dbra	d5,ID_cgp3_3

		addq.w	#1,d7
		cmp.w	d1,d7
		bne.b	ID_cgp3_Loop

		rts


; -----------------------------------------------------------------------------
; Procedure:	ID_RenderSpace
; Function:	Render one frame space (stars) on ChunkyMap
; In:
;	none
; Out:
;	none
; -----------------------------------------------------------------------------

ID_RenderSpace	move.l	ID_SpacePointer,a0

		move.l	ID_MulTable(pc),a1
		move.l	ID_ShadePalette(pc),a3
		move.l	ID_SpaceFade(pc),a4
		adda.w	ID_SpaceBright(pc),a4

ID_rs_Loop	move.w	(a0)+,d0
		bmi.b	ID_rs_End
		move.w	(a0)+,d1
		move.w	(a0)+,d2
		move.w	(a4,d2.w),d2

		move.l	(a1,d1.w*4),a2
		move.b	21(a3,d2.w),(a2,d0.w)

		bra.b	ID_rs_Loop

ID_rs_End	addq.w	#4,a0
		tst.w	(a0)
		bpl.b	ID_rs_End1
		move.l	ID_SpaceTable,a0

ID_rs_End1	move.l	a0,ID_SpacePointer
		rts


; -----------------------------------------------------------------------------

P1		=	0
P2		=	8
P3		=	16
P4		=	24
P5		=	32
P6		=	40
P7		=	48
P8		=	56

		INCLUDE	"ChunkyToPlanar/C2P.8.8.CheckZero.s"

; -----------------------------------------------------------------------------
; Special data
; -----------------------------------------------------------------------------

ID_MemEntry	DCB.B	14
		DC.W	15
	DC.L	MEMF_PUBLIC,ID_HEIGHT*4				; MulTable
	DC.L	MEMF_CHIP,ID_WIDTH*ID_HEIGHT			; ChunkyMap
	DC.L	MEMF_CHIP|MEMF_CLEAR,ID_PLANE_SIZE*ID_DEPTH+4	; VRAM0
	DC.L	MEMF_CHIP|MEMF_CLEAR,ID_PLANE_SIZE*ID_DEPTH+4	; VRAM1
	DC.L	MEMF_CHIP,ID_DEPTH*8+4				; CopperList
	DC.L	MEMF_PUBLIC,90*2				; SinPtrTable
	DC.L	MEMF_PUBLIC,4*8*2				; NodePoints
	DC.L	MEMF_PUBLIC,256*256*2				; HGouraudTable
	DC.L	MEMF_PUBLIC,256*2				; HLineBuffer
	DC.L	MEMF_PUBLIC,256*2				; VLineBuffer
	DC.L	MEMF_PUBLIC,256*2				; HScalingBuffer
	DC.L	MEMF_PUBLIC,256*2				; VScalingBuffer
	DC.L	MEMF_PUBLIC,256*2				; VGouraudTable1
	DC.L	MEMF_PUBLIC,256*2				; VGouraudTable2
	DC.L	MEMF_PUBLIC,16*16*2				; SpaceFade

ID_MemEntryPtr	DC.L	0

ID_MulTable	DC.L	0
ChunkyMap	DC.L	0
ID_VRAM_Display	DC.L	0
VRAM_Render
ID_VRAM_Render	DC.L	0
ID_CopperList	DC.L	0
ID_SinPtrTable	DC.L	0
ID_NodePoints	DC.L	0
ID_HGouraudTable	DC.L	0
ID_HLineBuffer	DC.L	0
ID_VLineBuffer	DC.L	0
ID_HScalingBuffer	DC.L	0
ID_VScalingBuffer	DC.L	0
ID_VGouraudTable1	DC.L	0
ID_VGouraudTable2	DC.L	0
ID_SpaceFade	DC.L	0

ID_SinusTable	DC.L	0
ID_ShadePalette	DC.L	0
ID_Palette	DC.L	0

ID_RotX		DC.W	0
ID_RotY		DC.W	0
ID_RotZ		DC.W	0

OldDMACon	DC.W	0

ID_SpacePointer	DC.L	0
ID_SpaceTable	DC.L	0

ID_DistScale	DC.W	1
ID_PosX		DC.W	0
ID_PosY		DC.W	0
ID_PosZ		DC.W	0
ID_MoveDirect	DC.W	ID_MOVE_SPEED

ID_HTextureSize	DC.L	0
ID_VTextureSize	DC.L	0

ID_aux0		DC.L	0

ID_RotXSpeed	DC.W	0
ID_RotYSpeed	DC.W	0
ID_RotZSpeed	DC.W	0
ID_MoveZSpeed	DC.W	0
ID_MoveZDest	DC.W	0
ID_MovingCntr	DC.W	0

ID_SpaceBright	DC.W	0

ID_Bright1	DC.W	0
ID_Bright2	DC.W	0
ID_Bright3	DC.W	0
ID_Bright4	DC.W	0
ID_TextureBright	DC.W	0

ID_Txt1Ptr	DC.L	0
ID_Txt1bPtr	DC.L	0
ID_Txt1cPtr	DC.L	0
ID_Txt2Ptr	DC.L	0
ID_Txt3Ptr	DC.L	0
ID_Txt4Ptr	DC.L	0
ID_Txt5Ptr	DC.L	0
ID_Txt6Ptr	DC.L	0


; -----------------------------------------------------------------------------

		SECTION	Introduction_2,data_c

; -----------------------------------------------------------------------------

		SECTION	Introduction_3,bss

; -----------------------------------------------------------------------------

		SECTION	Introduction_4,bss_c

; -----------------------------------------------------------------------------

		INCLUDE	"Shared/MainShared.s"

; =============================================================================

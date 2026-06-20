
 * This program shows you how to correctly set up bob gel-gel collisions.
 * Regardless of what you might have read in various Amiga books the way
 * collision works is as follows:
 *
 * If bob 2 collides with bob 0 for example it is the HitMask of bob 2 that
 * is ANDed with the MeMask of bob 0. This means. When a collision happens
 * bob 2 says to itself "Let me check my HitMask to see what bobs I can
 * hit/collide with". Once this is done it then checks (ANDs) bob 0's MeMask
 * to see if it can collide with bob 0. If it can, the ANDed result (the
 * set bit/s) will reveal what collision number/s (routine/s) to call. If
 * bob 2 cannot collide with bob 0 the ANDed result will have bit/s cleared
 * to denote no collision possible between these two bobs. In other words,
 * think of each bob's MeMask as its own Collision ID. And think of each
 * bob's HitMask as the Collision IDs it can hit/collide with.
 *
 * This code shows, by drawing a coloured rectangle, what happens (what
 * colour) when a collision happens. It also shows what happens when a bob
 * goes through another bob. I.e. normally if a bob collides with another
 * bob your collision routine should re-position one of the bobs. I have not
 * done this. I have shown that the collision routine that gets called is
 * originally from the colliding bob but when the colliding bob has collided
 * it is then the hit bob's collision routine that gets called. This happens
 * when the colliding bob goes straight through the hit bob.

	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE dos/dosextens.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/text.i
	INCLUDE	graphics/gels.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	workbench/workbench.i

LIB_VER		EQU	39
TRUE		EQU	-1
FALSE		EQU	0
BMW		EQU	640
BMH		EQU	256
BMF		EQU	0
BMD		EQU	4
BMP		EQU	0
BMB		EQU	20480
BMR		EQU	$8000

	lea	membuf(pc),a4

 * membuf (Memory Buffer) is set-up so that this code can be
 * position-independant. The memory buffer contains the following
 * addresses and their data:
 *
 *   0  Startup Return Message
 *   4  _DOSBase
 *   8  _IntuitionBase
 *  12 _IconBase
 *  16 Old Directory from CurrentDir()
 *  20 Disk Object from GetDiskObject()
 *  24 Argument addresses (30*4)
 * 144 ReadArgs() return value
 * 148 Task address
 * 152 _GfxBase
 * 156 window rastport
 * 160 viewport
 * 164
 * 165
 * 166 Memory Buffer (12 bytes)
 * 178 window
 * 182 value 1 (for ToolType/CLI result)
 * 183 value 2 (for ToolType/CLI result)
 * 184 screen rastport
 * 188
 * 192
 * 194
 * 196
 * 200
 * 202
 * 204 screen
 * 208 colourmap
 * 212 bitmap0
 * 216 bitmap1
 * 220

 * The Startup code below reads two CLI Arguments/WB ToolTypes as an example
 * of how to programme CLI Arguments/WB ToolTypes.
 *
 * Note: The CLI Arguments/WB ToolTypes are done after Startup and Library
 *       opening, so there is no use for the A0 pointer (which contains
 *       pr_CLI).

	suba.l	a1,a1
	move.l	4.w,a6
	jsr	_LVOFindTask(a6)
	tst.l	d0
	beq	exit
	move.l	d0,a5
	move.l	a5,148(a4)
	tst.l	pr_CLI(a5)		; Was this task started from CLI?
	bne.s	_main			; Yes.
	lea	pr_MsgPort(a5),a0	; No. From Workbench.
	jsr	_LVOWaitPort(a6)
	lea	pr_MsgPort(a5),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,(a4)			; D0 = A WBStartup Message.

_main
	moveq	#LIB_VER,d0
        lea     dos_name(pc),a1
	move.l	4.w,a6
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,4(a4)
        beq     quit

        moveq	#LIB_VER,d0
        lea     int_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,8(a4)
        beq     cl_dos

        moveq	#LIB_VER,d0
        lea     gfx_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GfxBase
        move.l  d0,152(a4)
        beq     cl_int

        moveq	#LIB_VER,d0
        lea     icon_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,12(a4)
        beq     cl_gfx

 * Check the ToolTypes/CLI Arguments.

        move.l	(a4),a0
        tst.l   a0
        beq	fromcli
	move.l	sm_ArgList(a0),a5
        move.l  (a5),d1
	beq	zero_args
	move.l	4(a4),a6
	jsr	_LVOCurrentDir(a6)
        move.l  d0,16(a4)
        move.l	wa_Name(a5),a0
	move.l	12(a4),a6
	jsr	_LVOGetDiskObject(a6)
        move.l  d0,20(a4)
        beq     zero_args
        move.l	d0,a5
        move.l  do_ToolTypes(a5),a5

	move.l	a5,a0
        lea	ftstg0(pc),a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	tt1
	move.l	d0,a3
	move.l	a3,a0
	lea	mtstg0(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto1
	clr.b	182(a4)
	bra.s	tt1
tto1	move.l	a3,a0
	lea	mtstg1(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tt1
	move.b	#1,182(a4)
tt1	move.l	a5,a0
        lea	ftstg1(pc),a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	tt2
	move.l	d0,a3
	move.l	a3,a0
	lea	mtstg2(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto2
	clr.b	183(a4)
	bra.s	tt2
tto2	move.l	a3,a0
	lea	mtstg3(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto3
	move.b	#1,183(a4)
	bra.s	tt2
tto3	move.l	a3,a0
	lea	mtstg4(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto4
	move.b	#2,183(a4)
	bra.s	tt2
tto4	move.l	a3,a0
	lea	mtstg5(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tt2
	move.b	#3,183(a4)
tt2
	nop


free_diskobj
        move.l	20(a4),a0
        jsr	_LVOFreeDiskObject(a6)
	bra	zero_args

fromcli	lea	template(pc),a0
	move.l  a0,d1
        lea	24(a4),a5
        move.l  a5,d2
        moveq	#0,d3
	move.l	4(a4),a6
        jsr	_LVOReadArgs(a6)
        move.l  d0,144(a4)
        beq	zero_args

	move.l	(a5),a0
	lea	mtstg0(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao1
	clr.b	182(a4)
	bra.s	ca1
cao1	move.l	(a5),a0
	lea	mtstg1(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	ca1
	move.b	#1,182(a4)
ca1	move.l	4(a5),a0
	lea	mtstg2(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao2
	clr.b	183(a4)
	bra.s	ca2
cao2	move.l	4(a5),a0
	lea	mtstg3(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao3
	move.b	#1,183(a4)
	bra.s	ca2
cao3	move.l	4(a5),a0
	lea	mtstg4(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao4
	move.b	#2,183(a4)
	bra.s	ca2
cao4	move.l	4(a5),a0
	lea	mtstg5(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	ca2
	move.b	#3,183(a4)
ca2
	nop


free_cliargs
        move.l	144(a4),d1
        jsr	_LVOFreeArgs(a6)

zero_args

	moveq	#bm_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,bm0ptr
	move.l	d0,212(a4)
	beq	cl_icon

	move.l	212(a4),a0
	moveq	#BMD,d0
	move.w	#BMW,d1
	move.w	#BMH,d2
	move.l	152(a4),a6
	jsr	_LVOInitBitMap(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	212(a4),a0
	move.l	d0,8(a0)
	beq	free_bm0
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	212(a4),a0
	move.l	d0,12(a0)
	beq	free_plane0
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	212(a4),a0
	move.l	d0,16(a0)
	beq	free_plane1
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	212(a4),a0
	move.l	d0,20(a0)
	beq	free_plane2
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	moveq	#bm_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,216(a4)
	beq	free_plane3

	move.l	216(a4),a0
	moveq	#BMD,d0
	move.w	#BMW,d1
	move.w	#BMH,d2
	move.l	152(a4),a6
	jsr	_LVOInitBitMap(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	216(a4),a0
	move.l	d0,8(a0)
	move.l	d0,a1
	beq	free_bm1
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	216(a4),a0
	move.l	d0,12(a0)
	move.l	d0,a1
	beq	free_plane4
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	216(a4),a0
	move.l	d0,16(a0)
	move.l	d0,a1
	beq	free_plane5
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	216(a4),a0
	move.l	d0,20(a0)
	move.l	d0,a1
	beq	free_plane6
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	suba.l	a0,a0
	lea	scrntags(pc),a1
	move.l	8(a4),a6
	jsr	_LVOOpenScreenTagList(a6)
	move.l	d0,wndwscrn
	beq	free_plane7

	suba.l	a0,a0
	lea	wndwtags(pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,178(a4)
	beq	exit_closescreen

	move.l	178(a4),a0
	move.l	wd_RPort(a0),wndwrp
	move.l	wndwrp(pc),156(a4)
	move.l	wndwscrn(pc),a0
	lea	sc_RastPort(a0),a1
	move.l	a1,scrnrp
	lea	sc_ViewPort(a0),a0
	move.l	a0,160(a4)

	lea	colours(pc),a1
	move.w	#16,d0
	move.l	152(a4),a6
	jsr	_LVOLoadRGB4(a6)

	move.l	156(a4),a1
	move.b	#1,d0
	jsr	_LVOSetDrMd(a6)

	move.l	156(a4),a1
	move.b	#6,d0
	jsr	_LVOSetAPen(a6)

	move.l	156(a4),a1
	move.b	#1,d0
	jsr	_LVOSetBPen(a6)

	move.l	156(a4),a1
	clr.w	d0
	clr.w	d1
	move.w	#20,d2
	move.w	#20,d3
	jsr	_LVORectFill(a6)

	move.w	#16,d0
	move.w	#26,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	lea	bmstg0(pc),a0
	moveq	#15,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)
	jsr	_LVOWaitTOF(a6)

	lea	vshead0(pc),a0
	lea	vstail0(pc),a1
	lea	gi0ptr(pc),a2
	move.l	156(a4),a3
	move.l	a2,rp_GelsInfo(a3)
	move.b	#3,(a2)				; gi_sprRsrvd(a2)
	lea	nl0ptr(pc),a3
	move.l	a3,gi_nextLine(a2)
	lea	lc0ptr(pc),a3
	move.l	a3,gi_lastColor(a2)
	clr.l	gi_collHandler(a2)
	clr.w	gi_leftmost(a2)
	clr.w	gi_topmost(a2)
	clr.w	gi_rightmost(a2)
	clr.w	gi_bottommost(a2)
	jsr	_LVOInitGels(a6)

	lea	vs0ptr(pc),a0
	lea	bob0ptr(pc),a2
	move.w	#VSF_SAVEBACK!VSF_OVERLAY,vs_VSFlags(a0)
	move.w	#20,vs_Y(a0)
	move.w	#20,vs_X(a0)
	move.w	#8,vs_Height(a0)
	move.w	#2,vs_Width(a0)
	move.w	#4,vs_Depth(a0)
	clr.w	vs_MeMask(a0)
	clr.w	vs_HitMask(a0)
	lea	image0,a1
	move.l	a1,vs_ImageData(a0)
	lea	bl0ptr(pc),a1
	move.l	a1,vs_BorderLine(a0)
	lea	mask0,a1
	move.l	a1,vs_CollMask(a0)
	clr.l	vs_SprColors(a0)
	move.l	a2,vs_VSBob(a0)
	move.b	#$0F,vs_PlanePick(a0)
	clr.b	vs_PlaneOnOff(a0)

	clr.w	(a2)				; bob_BobFlags(a2)
	lea	sbuf0,a1
	move.l	a1,bob_SaveBuffer(a2)
	lea	mask0,a1
	move.l	a1,bob_ImageShadow(a2)
	clr.l	bob_Before(a2)
	clr.l	bob_After(a2)
	move.l	a0,bob_BobVSprite(a2)
	clr.l	bob_BobComp(a2)
	clr.l	bob_DBuffer(a2)
	jsr	_LVOInitMasks(a6)

	lea	bob0ptr(pc),a0
	move.l	156(a4),a1
	jsr	_LVOAddBob(a6)

	lea	vs1ptr(pc),a0
	lea	bob1ptr(pc),a2
	move.w	#VSF_OVERLAY,vs_VSFlags(a0)
	move.w	#60,vs_Y(a0)
	move.w	#60,vs_X(a0)
	move.w	#8,vs_Height(a0)
	move.w	#2,vs_Width(a0)
	move.w	#4,vs_Depth(a0)
	clr.w	vs_MeMask(a0)
	clr.w	vs_HitMask(a0)
	lea	image1,a1
	move.l	a1,vs_ImageData(a0)
	lea	bl1ptr(pc),a1
	move.l	a1,vs_BorderLine(a0)
	lea	mask1,a1
	move.l	a1,vs_CollMask(a0)
	clr.l	vs_SprColors(a0)
	move.l	a2,vs_VSBob(a0)
	move.b	#$0F,vs_PlanePick(a0)
	clr.b	vs_PlaneOnOff(a0)

	move.w	#BF_SAVEBOB,(a2)			; bob_BobFlags(a2)
	lea	sbuf1,a1
	move.l	a1,bob_SaveBuffer(a2)
	lea	mask1,a1
	move.l	a1,bob_ImageShadow(a2)
	clr.l	bob_Before(a2)
	clr.l	bob_After(a2)
	move.l	a0,bob_BobVSprite(a2)
	clr.l	bob_BobComp(a2)
	clr.l	bob_DBuffer(a2)
	jsr	_LVOInitMasks(a6)

	lea	bob1ptr(pc),a0
	move.l	156(a4),a1
	jsr	_LVOAddBob(a6)

	move.w	#20,d5

loop0	lea	vs0ptr(pc),a0
	move.w	d5,vs_X(a0)
	bsr	draw_bob
	addq.w	#1,d5
	cmp.w	#500,d5
	blt.s	loop0

	move.w	#500,d5
	clr.b	d4

loop1	lea	vs0ptr,a0
	move.w	d5,vs_X(a0)
	cmp.b	#1,d4
	beq.s	one
	lea	image0,a1
	move.l	a1,vs_ImageData(a0)
	move.b	#1,d4
	bra.s	do_bob
one	lea	image1,a1
	move.l	a1,vs_ImageData(a0)
	clr.b	d4
do_bob	bsr	draw_maskbob
	moveq	#12,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)
	move.l	152(a4),a6
	jsr	_LVOWaitTOF(a6)
	sub.w	#40,d5
	cmp.w	#20,d5
	bgt.s	loop1

	move.w	#60,d5

loop2	lea	vs1ptr(pc),a0
	move.w	d5,vs_X(a0)
	bsr	draw_bob
	moveq	#15,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)
	add.w	#40,d5
	cmp.w	#580,d5
	blt.s	loop2

	moveq	#100,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

cleanup_rp
	move.l	156(a4),a0
	clr.l	rp_GelsInfo(a0)

exit_closewindow
	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

exit_closescreen
	move.l	wndwscrn(pc),a0
	move.l	8(a4),a6
	jsr	_LVOCloseScreen(a6)

free_plane7
	move.l	216(a4),a0
	move.l	bm_Planes+12(a0),a0
	tst.l	a0
	beq.s	free_plane6
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

free_plane6
	move.l	216(a4),a0
	move.l	bm_Planes+8(a0),a0
	tst.l	a0
	beq.s	free_plane5
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

free_plane5
	move.l	216(a4),a0
	move.l	bm_Planes+4(a0),a0
	tst.l	a0
	beq.s	free_plane4
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

free_plane4
	move.l	216(a4),a0
	move.l	bm_Planes(a0),a0
	tst.l	a0
	beq.s	free_bm1
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

free_bm1
	move.l	216(a4),a1
	moveq	#bm_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

free_plane3
	move.l	212(a4),a0
	move.l	bm_Planes+12(a0),a0
	tst.l	a0
	beq.s	free_plane2
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

free_plane2
	move.l	212(a4),a0
	move.l	bm_Planes+8(a0),a0
	tst.l	a0
	beq.s	free_plane1
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

free_plane1
	move.l	212(a4),a0
	move.l	bm_Planes+4(a0),a0
	tst.l	a0
	beq.s	free_plane0
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

free_plane0
	move.l	212(a4),a0
	move.l	bm_Planes(a0),a0
	tst.l	a0
	beq.s	free_bm0
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

free_bm0
	move.l	212(a4),a1
	moveq	#bm_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

cl_icon	move.l  12(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_gfx	move.l  152(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_int	move.l  8(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_dos	move.l  4(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

quit	move.l  #8000000,d0
        moveq	#MEMF_CHIP,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	cleanup
	move.l	d0,a1
	move.l	#8000000,d0
	jsr	_LVOFreeMem(a6)
cleanup	tst.l	(a4)
	beq.s	exit			; Exit - Task was started from CLI.
	move.l	4.w,a6
	jsr	_LVOForbid(a6)
	move.l	(a4),a1			; Reply to the WB Startup Message and
	jsr	_LVOReplyMsg(a6)	; Exit - Task was started from WB.
exit	moveq	#0,d0
	rts


 * Branch-To Routines.


 * Sub-Routines.

draw_maskbob
	move.l	152(a4),a6
	jsr	_LVOInitMasks(a6)

draw_bob
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOSortGList(a6)

	move.l	160(a4),a0
	move.l	156(a4),a1
	jsr	_LVODrawGList(a6)

	jsr	_LVOWaitTOF(a6)
	rts

cmpbyte	move.b  (a0)+,d0
        move.b  (a1)+,d1
        tst.b   d0
        beq.s   byte0
        cmp.b   d1,d0
        beq.s   cmpbyte
byte0	sub.b   d1,d0
        ext.w   d0
        ext.l   d0
        rts

findlen	move.l	a0,a1
	moveq	#0,d0
not_nil	tst.b	(a1)+
	beq.s	gotlen
	addq.l	#1,d0
	bra.s	not_nil
gotlen	rts


 * Structures/Definitions.

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

scrn_title
	dc.b	'Bob_MovePaste.s',0
	even

scrntags
	dc.l	SA_Top,0
	dc.l	SA_Left,0
	dc.l	SA_Width,BMW
	dc.l	SA_Height,BMH
	dc.l	SA_Depth,BMD
	dc.l	SA_DetailPen,0
	dc.l	SA_BlockPen,1
	dc.l	SA_Title,scrn_title
	dc.l	SA_DisplayID,BMR
	dc.l	SA_Type,CUSTOMSCREEN!CUSTOMBITMAP
	dc.l	SA_BitMap
bm0ptr
	dc.l	0
	dc.l	SA_Font,topaz9
	dc.l	SA_Quiet,TRUE
	dc.l	0

wndwtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,BMW
	dc.l	WA_Height,BMH
	dc.l	WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS
	dc.l	WA_Activate,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_SmartRefresh,TRUE
	dc.l	WA_CustomScreen
wndwscrn
	dc.l	0
	dc.l	0

colours	dc.w	$0FD4,$0FFF,$0F00,$0FF0,$000F,$00F0,$0F0F,$0888,$0444,$0222,$0DC8,$028F,$0F69,$0ABC,$0749,$0FFF


 * Long Variables.

_GfxBase	dc.l	0
scrnrp		dc.l	0
wndwrp		dc.l	0


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
mtstg0		dc.b	'ARG_ONE',0
mtstg1		dc.b	'ARG_TWO',0
mtstg2		dc.b	'ARG_THREE',0
mtstg3		dc.b	'ARG_FOUR',0,0
mtstg4		dc.b	'ARG_FIVE',0,0
mtstg5		dc.b	'ARG_SIX',0
ftstg0          dc.b    'TOOLTYPE_ONE',0,0
ftstg1          dc.b    'TOOLTYPE_TWO',0,0
template	dc.b	'KEYWORD_ONE/K,KEYWORD_TWO/K',0
font_name	dc.b	'topaz.font',0,0
bmstg0		dc.b	'A Bob Over Text',0


 * Buffer Variables.

membuf		dcb.b	300,0
gi0ptr		dcb.b	gi_SIZEOF,0
vshead0		dcb.b	vs_SIZEOF,0
vstail0		dcb.b	vs_SIZEOF,0
vs0ptr		dcb.b	vs_SIZEOF,0
vs1ptr		dcb.b	vs_SIZEOF,0
vs2ptr		dcb.b	vs_SIZEOF,0
bob0ptr		dcb.b	bob_SIZEOF,0
bob1ptr		dcb.b	bob_SIZEOF,0
bob2ptr		dcb.b	bob_SIZEOF,0
bl0ptr		dcb.b	4,0
bl1ptr		dcb.b	4,0
bl2ptr		dcb.b	4,0
lc0ptr		dcb.l	8,0
ch0ptr		dcb.l	16,0
nl0ptr		dcb.w	8,0


	SECTION	GFX,DATA_C

mask0	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

mask1	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

sbuf0	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

sbuf1	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000

image0	dc.w	$FF00,$FF00
	dc.w	$FF00,$FF00
	dc.w	$FF00,$FF00
	dc.w	$FF00,$FF00
	dc.w	$FF00,$FF00
	dc.w	$FF00,$FF00
	dc.w	$FF00,$FF00
	dc.w	$FF00,$FF00

	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00

	dc.w	$0000,$00FF
	dc.w	$0000,$00FF
	dc.w	$FFFF,$FF00
	dc.w	$FFFF,$FF00
	dc.w	$00FF,$00FF
	dc.w	$00FF,$00FF
	dc.w	$FFFF,$FF00
	dc.w	$FFFF,$FF00

	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$00FF
	dc.w	$0000,$00FF
	dc.w	$FF00,$FFFF
	dc.w	$FF00,$FFFF
	dc.w	$FFFF,$FF00
	dc.w	$FFFF,$FF00

image1	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF

	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF

	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF

	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00
	dc.w	$00FF,$FF00


	SECTION	VERSION,DATA

	dc.b	'$VER: Bob_MovePaste.s V1.01 (22.4.2001)',0


	END
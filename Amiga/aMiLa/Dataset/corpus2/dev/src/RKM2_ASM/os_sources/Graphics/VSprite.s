
 * This program shows you how to correctly set up a VSprite, with Border
 * collision.

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
 * 212

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

	suba.l	a0,a0
	lea	scrntags(pc),a1
	move.l	8(a4),a6
	jsr	_LVOOpenScreenTagList(a6)
	move.l	d0,wndwscrn
	beq	cl_icon

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

	move.l	152(a4),a6
	jsr	_LVOWaitTOF(a6)

	lea	vshead0(pc),a0
	lea	vstail0(pc),a1
	lea	gi0ptr(pc),a2
	move.l	156(a4),a3
	move.l	a2,rp_GelsInfo(a3)
	move.b	#252,(a2)				; gi_sprRsrvd(a2)
	lea	nl0ptr(pc),a3
	move.l	a3,gi_nextLine(a2)
	lea	lc0ptr(pc),a3
	move.l	a3,gi_lastColor(a2)
	lea	ch0ptr(pc),a3
	move.l	a3,gi_collHandler(a2)
	move.w	#2,gi_leftmost(a2)
	move.w	#2,gi_topmost(a2)
	move.w	#600,gi_rightmost(a2)
	move.w	#190,gi_bottommost(a2)
	jsr	_LVOInitGels(a6)

	lea	vs0ptr(pc),a0
	move.w	#VSF_VSPRITE,vs_VSFlags(a0)
	move.w	#100,vs_Y(a0)
	move.w	#500,vs_X(a0)
	move.w	#16,vs_Height(a0)
	move.w	#1,vs_Width(a0)
	move.w	#2,vs_Depth(a0)
	clr.w	vs_MeMask(a0)
	move.w	#$0001,vs_HitMask(a0)
	lea	image0,a1
	move.l	a1,vs_ImageData(a0)
	lea	bl0ptr(pc),a1
	move.l	a1,vs_BorderLine(a0)
	lea	mask0,a1
	move.l	a1,vs_CollMask(a0)
	lea	spritecols0(pc),a1
	move.l	a1,vs_SprColors(a0)
	clr.l	vs_VSBob(a0)
	clr.b	vs_PlanePick(a0)
	clr.b	vs_PlaneOnOff(a0)
	jsr	_LVOInitMasks(a6)

	lea	vs0ptr(pc),a0
	move.l	156(a4),a1
	jsr	_LVOAddVSprite(a6)

	lea	vs1ptr(pc),a0
	move.w	#VSF_VSPRITE,vs_VSFlags(a0)
	move.w	#50,vs_Y(a0)
	move.w	#500,vs_X(a0)
	move.w	#16,vs_Height(a0)
	move.w	#1,vs_Width(a0)
	move.w	#2,vs_Depth(a0)
	clr.w	vs_MeMask(a0)
	move.w	#$0001,vs_HitMask(a0)
	lea	image1,a1
	move.l	a1,vs_ImageData(a0)
	lea	bl1ptr(pc),a1
	move.l	a1,vs_BorderLine(a0)
	lea	mask1,a1
	move.l	a1,vs_CollMask(a0)
	lea	spritecols1(pc),a1
	move.l	a1,vs_SprColors(a0)
	clr.l	vs_VSBob(a0)
	clr.b	vs_PlanePick(a0)
	clr.b	vs_PlaneOnOff(a0)
	jsr	_LVOInitMasks(a6)

	lea	vs1ptr(pc),a0
	move.l	156(a4),a1
	jsr	_LVOAddVSprite(a6)

	moveq	#0,d0
	lea	border_check(pc),a0
	lea	gi0ptr(pc),a1
	jsr	_LVOSetCollision(a6)

	bsr	draw_vsprite

	moveq	#55,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

	move.w	#500,d5

loop0	lea	vs0ptr(pc),a0
	move.w	d5,vs_X(a0)
	bsr	draw_vsprite
	addq.w	#1,d5
	cmp.w	#607,d5
	blt.s	loop0

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

draw_vsprite
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOSortGList(a6)

	move.l	156(a4),a1
	jsr	_LVODoCollision(a6)

	move.l	156(a4),a1
	jsr	_LVOSortGList(a6)

	move.l	160(a4),a0
	move.l	156(a4),a1
	jsr	_LVODrawGList(a6)
*	jsr	_LVOWaitTOF(a6)

	move.l	8(a4),a6
	jsr	_LVORethinkDisplay(a6)
	rts

border_check

 * Draw a rectangle to show the collision. Really. You should check d0/d1
 * (flags/mask), a0 (the address of the vsprite hit) and a1 (the returned
 * gelinfo structure for this screen/window). Note: a2/a3 are trashed by
 * DoCollision.

	move.l	wndwrp(pc),a1
	clr.w	d0
	clr.w	d1
	move.w	#300,d2
	move.w	#100,d3
	move.l	_GfxBase(pc),a6
	jsr	_LVORectFill(a6)
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
	dc.b	'VSprite.s',0
	even

scrntags
	dc.l	SA_Top,0
	dc.l	SA_Left,0
	dc.l	SA_Width,640
	dc.l	SA_Height,256
	dc.l	SA_Depth,2
	dc.l	SA_DetailPen,0
	dc.l	SA_BlockPen,1
	dc.l	SA_Title,scrn_title
	dc.l	SA_DisplayID,$8000
	dc.l	SA_Type,CUSTOMSCREEN
	dc.l	SA_Font,topaz9
	dc.l	SA_Quiet,TRUE
	dc.l	TAG_DONE

wndwtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,640
	dc.l	WA_Height,256
	dc.l	WA_IDCMP,0
	dc.l	WA_Activate,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_SmartRefresh,TRUE
	dc.l	WA_CustomScreen
wndwscrn
	dc.l	0
	dc.l	TAG_DONE

spritecols0	dc.w	$0F00,$0000,$0FFF
spritecols1	dc.w	$0FF0,$00F0,$0FF0


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


 * Buffer Variables.

membuf		dcb.b	300,0
gi0ptr		dcb.b	gi_SIZEOF,0
vshead0		dcb.b	vs_SIZEOF,0
vstail0		dcb.b	vs_SIZEOF,0
vs0ptr		dcb.b	vs_SIZEOF,0
vs1ptr		dcb.b	vs_SIZEOF,0
vs2ptr		dcb.b	vs_SIZEOF,0
bl0ptr		dcb.b	2,0
bl1ptr		dcb.b	2,0
bl2ptr		dcb.b	2,0
lc0ptr		dcb.l	8,0
ch0ptr		dcb.l	16,0
nl0ptr		dcb.w	8,0


	SECTION	GFX,DATA_C

mask0	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000

mask1	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000

image0	dc.w	$0400,$07C0
	dc.w	$0000,$07C0
	dc.w	$0100,$0380
	dc.w	$0000,$07E0
        dc.w	$07C0,$1FF8
	dc.w	$1FF0,$3FEC
	dc.w	$3FF8,$7FDE
	dc.w	$3FF8,$7FBE
        dc.w	$7FFC,$FF7F
	dc.w	$7EFC,$FFFF
	dc.w	$7FFC,$FFFF
	dc.w	$3FF8,$7FFE
        dc.w	$3FF8,$7FFE
	dc.w	$1FF0,$3FFC
	dc.w	$07C0,$1FF8
	dc.w	$0000,$07E0

image1	dc.w	$FFFF,$0000
	dc.w	$FFFF,$0000
	dc.w	$FFFF,$0000
	dc.w	$FFFF,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$FFFF
	dc.w	$0000,$FFFF
	dc.w	$0000,$FFFF
	dc.w	$0000,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
	dc.w	$FFFF,$FFFF


	SECTION	VERSION,DATA

	dc.b	'$VER: VSprite.s V1.01 (22.4.2001)',0


	END
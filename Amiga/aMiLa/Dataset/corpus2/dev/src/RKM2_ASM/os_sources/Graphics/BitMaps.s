
 * This code shows how to set-up two Bitmaps for one screen. It draws on
 * bitmap 0, flips to bitmap 1 (after displaying bitmap 0) and then draws
 * on bitmap 1 before displaying bitmap 1.

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
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	workbench/workbench.i

LIB_VER		EQU	39
TRUE		EQU	-1
FALSE		EQU	0
BMW		EQU	320
BMH		EQU	256
BMF		EQU	0
BMD		EQU	2
BMP		EQU	0
BMB		EQU	10240		; $00002800
BMR		EQU	0

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
	move.l	d0,212(a4)
	move.l	d0,bm0ptr
	beq	cl_icon

	move.l	d0,a0
	move.b	#BMD,d0
	move.w	#BMW,d1
	move.w	#BMH,d2
	move.l	152(a4),a6
	jsr	_LVOInitBitMap(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	212(a4),a0
	move.l	d0,8(a0)
	beq	fr_bm0

	move.l	d0,a1
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	212(a4),a0
	move.l	d0,12(a0)
	beq	fr_plane0

	move.l	d0,a1
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	moveq	#bm_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,216(a4)
	beq	fr_plane1

	move.l	d0,a0
	move.b	#BMD,d0
	move.w	#BMW,d1
	move.w	#BMH,d2
	move.l	152(a4),a6
	jsr	_LVOInitBitMap(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	216(a4),a0
	move.l	d0,8(a0)
	beq	fr_bm1

	move.l	d0,a1
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	move.w	#BMW,d0
	move.w	#BMH,d1
	jsr	_LVOAllocRaster(a6)
	move.l	216(a4),a0
	move.l	d0,12(a0)
	beq	fr_plane2

	move.l	d0,a1
	move.l	#BMB,d0
	moveq	#0,d1
	jsr	_LVOBltClear(a6)

	suba.l	a0,a0
	lea	scrntags(pc),a1
	move.l	8(a4),a6
	jsr	_LVOOpenScreenTagList(a6)
	move.l	d0,wndwscrn
	move.l	d0,204(a4)
	beq	fr_plane3

	suba.l	a0,a0
	lea	wndwtags(pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,178(a4)
	beq	cl_scrn

	move.l	d0,a0
	move.l	wd_RPort(a0),156(a4)

	move.l	204(a4),a0
	lea	sc_RastPort(a0),a1
	move.l	a1,184(a4)
	lea	sc_ViewPort(a0),a2
	move.l	a2,160(a4)

	move.l	a2,a0
	move.l	vp_ColorMap(a0),208(a4)

	move.l	184(a4),a1
	move.b	#3,d0
	move.l	152(a4),a6
	jsr	_LVOSetAPen(a6)

	clr.w	d0
	move.w	#40,d1
	move.w	#319,d2
	move.w	#127,d3
	move.l	184(a4),a1
	jsr	_LVORectFill(a6)

	move.w	#16,d0
	move.w	#26,d1
	move.l	184(a4),a1
	jsr	_LVOMove(a6)

	lea	bmstg0(pc),a0
	moveq	#8,d0
	move.l	184(a4),a1
	jsr	_LVOText(a6)

	jsr	_LVOWaitTOF(a6)

	moveq	#100,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

	move.l	184(a4),a1
	move.l	216(a4),rp_BitMap(a1)

	move.l	160(a4),a1
	move.l	vp_RasInfo(a1),a1
	move.l	216(a4),ri_BitMap(a1)

	move.l	184(a4),a1
	move.b	#2,d0
	move.l	152(a4),a6
	jsr	_LVOSetAPen(a6)

	clr.w	d0
	move.w	#128,d1
	move.w	#319,d2
	move.w	#255,d3
	move.l	184(a4),a1
	jsr	_LVORectFill(a6)

	move.w	#16,d0
	move.w	#36,d1
	move.l	184(a4),a1
	jsr	_LVOMove(a6)

	lea	bmstg1(pc),a0
	moveq	#8,d0
	move.l	184(a4),a1
	jsr	_LVOText(a6)

	jsr	_LVOWaitTOF(a6)

	move.l	204(a4),a0
	move.l	8(a4),a6
	jsr	_LVOMakeScreen(a6)
	jsr	_LVORethinkDisplay(a6)

	move.l	152(a4),a6
	jsr	_LVOWaitTOF(a6)

	moveq	#100,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)


cl_wndw	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

cl_scrn	move.l	204(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseScreen(a6)

fr_plane3
	move.l	216(a4),a0
	move.l	bm_Planes+4(a0),a0
	tst.l	a0
	beq.s	fr_plane2
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

fr_plane2
	move.l	216(a4),a0
	move.l	bm_Planes(a0),a0
	tst.l	a0
	beq.s	fr_bm1
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

fr_bm1	move.l	216(a4),a1
	moveq	#bm_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

fr_plane1
	move.l	212(a4),a0
	move.l	bm_Planes+4(a0),a0
	tst.l	a0
	beq.s	fr_plane0
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

fr_plane0
	move.l	212(a4),a0
	move.l	bm_Planes(a0),a0
	tst.l	a0
	beq.s	fr_bm0
	move.w	#BMW,d0
	move.w	#BMH,d1
	move.l	152(a4),a6
	jsr	_LVOFreeRaster(a6)

fr_bm0	move.l	212(a4),a1
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


 * Sub-Routines.

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


 * Structure Definitions.

pens
	dc.l	-1

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

scrntags
	dc.l	SA_Top,0
	dc.l	SA_Left,0
	dc.l	SA_Width,BMW
	dc.l	SA_Height,BMH
	dc.l	SA_Depth,BMD
	dc.l	SA_DetailPen,0
	dc.l	SA_BlockPen,1
	dc.l	SA_Pens,pens
	dc.l	SA_DisplayID,BMR
	dc.l	SA_Type,CUSTOMSCREEN!CUSTOMBITMAP
	dc.l	SA_BitMap
bm0ptr
	dc.l	0
	dc.l	SA_Font,topaz9
	dc.l	SA_Quiet,TRUE
	dc.l	TAG_DONE

wndwtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,BMW
	dc.l	WA_Height,BMH
	dc.l	WA_DetailPen,0
	dc.l	WA_BlockPen,1
	dc.l	WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS
	dc.l	WA_Activate,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_SmartRefresh,TRUE
	dc.l	WA_CustomScreen
wndwscrn
	dc.l	0
	dc.l	TAG_DONE


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
bmstg0		dc.b	'Bitmap 1',0,0
bmstg1		dc.b	'Bitmap 2',0,0


 * Buffer Variables.

membuf		dcb.b	300,0


	SECTION	VERSION,DATA

	dc.b	'$VER: BitMaps.s V1.01 (22.4.2001)',0


	END
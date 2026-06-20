
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

 * SA_LEFT is -12 (side of screen) + -20 Character/Graphic (pixel) width.
 * Screen width is 360 * 2 (2 screens) + 20 character/graphic width. The
 * screen is 20+320+20 (the 20's are the extra width needed to cover your
 * TV screen).

 * The screen is offset so that the 20 character/graphic (pixel) width
 * is hidden in the left-side of your tv. These pixels, 0 to 19, are classed
 * as screen 0.

 * pixels 20 to 379 are classed as screen 1. You can see this screen.
 * pixels 380 to 739 are classed as screen 2. You cannot see this screen
 * as it is at the right-side of your tv.

 * Note:
 *
 * With horizontal scrolling you may accur Banding problems on the right
 * side of your tv screen when using HIRES for example. Thus, either use a
 * screen width size that does not go to the right side of your tv or use a
 * different scrolling method (i.e ScrollRaster()). I have only used a
 * screen that goes to the right side of my tv to show how to do a scroll
 * with hidden screen parts. You might not experience Banding problems
 * (depends on your tv/monitor etc). Also. If you use images and/or text you
 * should clear the space for that image or text with RectFill() for example
 * first, before applying your image and/or text. I did not clear the space
 * in this program because my text was the same length all the time (i.e one
 * character overwriting another character).

	suba.l	a0,a0
	lea	scrntags(pc),a1
	move.l	8(a4),a6
	jsr	_LVOOpenScreenTagList(a6)
	move.l	d0,wndwscrn
	beq	cl_icon

	move.l	d0,a0
	lea	sc_RastPort(a0),a1
	move.l	a1,184(a4)
	lea	sc_ViewPort(a0),a0
	move.l	a0,160(a4)

	move.l	160(a4),a0
	clr.w	d0
	clr.w	d1
	clr.w	d2
	clr.w	d3
	move.l	152(a4),a6
	jsr	_LVOSetRGB4(a6)

	move.l	160(a4),a0
	move.w	#1,d0
	clr.w	d1
	clr.w	d2
	clr.w	d3
	jsr	_LVOSetRGB4(a6)

	move.l	160(a4),a0
	move.w	#2,d0
	clr.w	d1
	clr.w	d2
	clr.w	d3
	jsr	_LVOSetRGB4(a6)

	move.l	160(a4),a0
	move.w	#3,d0
	clr.w	d1
	clr.w	d2
	clr.w	d3
	jsr	_LVOSetRGB4(a6)

	clr.w	d0
	move.l	184(a4),a1
	jsr	_LVOSetRast(a6)

	suba.l	a0,a0
	lea	wndwtags(pc),a1
	move.l	8(a4),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,178(a4)
	beq	cl_scrn

	move.l	d0,a0
	move.l	wd_RPort(a0),156(a4)

	move.l	160(a4),a0
	move.w	#1,d0
	move.w	#15,d1
	move.w	#15,d2
	move.w	#15,d3
	move.l	152(a4),a6
	jsr	_LVOSetRGB4(a6)

	move.l	160(a4),a0
	move.w	#2,d0
	move.w	#15,d1
	clr.w	d2
	clr.w	d3
	jsr	_LVOSetRGB4(a6)

	move.l	160(a4),a0
	move.w	#3,d0
	move.w	#15,d1
	move.w	#15,d2
	move.w	#0,d3
	jsr	_LVOSetRGB4(a6)

	jsr	_LVOWaitTOF(a6)

 * These next drawings are just to define screen starts and ends, so that I
 * know where screens 0, 1 and 2 are. Note: Banding might cause some of your
 * drawings/graphics to be deleted, if using HIRES for example.

	move.b	#2,d0
	move.l	184(a4),a1
	jsr	_LVOSetAPen(a6)

	clr.b	d0
	move.l	184(a4),a1
	jsr	_LVOSetBPen(a6)

	move.l	184(a4),a1
	clr.w	d0
	clr.w	d1
	move.w	#19,d2
	move.w	#199,d3
	jsr	_LVORectFill(a6)

	move.b	#3,d0
	move.l	184(a4),a1
	jsr	_LVOSetAPen(a6)

	move.l	184(a4),a1
	move.w	#20,d0
	clr.w	d1
	move.w	#379,d2
	move.w	#199,d3
	jsr	_LVORectFill(a6)

	move.b	#2,d0
	move.l	184(a4),a1
	jsr	_LVOSetAPen(a6)

	move.l	184(a4),a1
	move.w	#380,d0
	clr.w	d1
	move.w	#743,d2
	move.w	#199,d3
	jsr	_LVORectFill(a6)

	clr.b	d0
	move.l	184(a4),a1
	jsr	_LVOSetAPen(a6)

	move.b	#1,d0
	move.l	184(a4),a1
	jsr	_LVOSetBPen(a6)

	clr.w	d2
	clr.w	d4
	clr.w	d6
	move.l	160(a4),a3
	move.l	vp_RasInfo(a3),a3

	moveq	#50,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

 * Scroll 360 pixels across - One screen width.

scroll_one
	move.l	184(a4),a1
	move.w	d2,d0
	move.w	#10,d1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	lea	166(a4),a0
	move.b	#65,d1
	add.b	d4,d1
	move.b	d1,(a0)
	moveq	#1,d0
	move.l	184(a4),a1
	jsr	_LVOText(a6)
	move.l	184(a4),a1
	move.w	#380,d0
	add.w	d2,d0
	move.w	#10,d1
	jsr	_LVOMove(a6)
	lea	166(a4),a0
	move.b	#65,d1
	add.b	d4,d1
	move.b	d1,(a0)
	moveq	#1,d0
	move.l	184(a4),a1
	jsr	_LVOText(a6)

 * Scroll 20 pixels across at a time - The width of your text.

	move.w	#-1,d5

scroll_loop
	addq.w	#1,d5
	cmp.w	#20,d5
	beq.s	scroll_end
	move.w	d2,d6
	add.w	d5,d6
	move.w	d6,ri_RxOffset(a3)
	clr.w	ri_RyOffset(a3)
	move.l	160(a4),a0
	jsr	_LVOScrollVPort(a6)
	bra.s	scroll_loop

scroll_end
	add.w	#20,d2
	addq.w	#1,d4
	cmp.w	#360,d2
	beq.s	scroll_complete
	bra.s	scroll_one

 * One screen width (360 pixels) has been scrolled.

scroll_complete

	move.l	184(a4),a1
	move.w	#440,d0
	move.w	#100,d1
	jsr	_LVOMove(a6)
	move.l	184(a4),a1
	lea	bmstg0(pc),a0
	moveq	#27,d0
	jsr	_LVOText(a6)
	move.l	184(a4),a1
	move.w	#440,d0
	move.w	#110,d1
	jsr	_LVOMove(a6)
	move.l	184(a4),a1
	lea	bmstg1(pc),a0
	moveq	#18,d0
	jsr	_LVOText(a6)

	move.l	#200,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

 * Reset the viewport, to bring screen 0 and 1 into focus.
 *
 * Note: You may have to adjust this reset value, depending on your TV and/or
 *       screen resolution, as TVs differ.

	move.w	#-21,ri_RxOffset(a3)
	clr.w	ri_RyOffset(a3)

	move.l	184(a4),a1
	move.w	#40,d0
	move.w	#70,d1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	move.l	184(a4),a1
	lea	bmstg2(pc),a0
	moveq	#27,d0
	jsr	_LVOText(a6)
	move.l	184(a4),a1
	move.w	#40,d0
	move.w	#80,d1
	jsr	_LVOMove(a6)
	move.l	184(a4),a1
	lea	bmstg3(pc),a0
	moveq	#27,d0
	jsr	_LVOText(a6)
	move.l	184(a4),a1
	move.w	#40,d0
	move.w	#90,d1
	jsr	_LVOMove(a6)
	move.l	184(a4),a1
	lea	bmstg4(pc),a0
	moveq	#27,d0
	jsr	_LVOText(a6)

	move.l	wndwscrn(pc),a0
	move.l	8(a4),a6
	jsr	_LVOMakeScreen(a6)
	jsr	_LVORethinkDisplay(a6)

	move.l	#200,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

	move.l	184(a4),a1
	move.w	d2,d0
	move.w	#10,d1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	lea	166(a4),a0
	move.b	#65,d1
	add.b	d4,d1
	move.b	d1,(a0)
	moveq	#1,d0
	move.l	184(a4),a1
	jsr	_LVOText(a6)
	move.l	184(a4),a1
	move.w	#380,d0
	add.w	d2,d0
	move.w	#10,d1
	jsr	_LVOMove(a6)
	lea	166(a4),a0
	move.b	#65,d1
	add.b	d4,d1
	move.b	d1,(a0)
	moveq	#1,d0
	move.l	184(a4),a1
	jsr	_LVOText(a6)

 * Now scroll screens 0 and 1, 20 pixels, so that screen 0 is hidden again.

	move.w	ri_RxOffset(a3),d5	; this will be -21.

scroll2_loop
	addq.w	#1,d5
	cmp.w	#-1,d5
	beq.s	scroll2_end
	move.w	d5,ri_RxOffset(a3)
	clr.w	ri_RyOffset(a3)
	move.l	160(a4),a0
	jsr	_LVOScrollVPort(a6)
	bra.s	scroll2_loop

scroll2_end

	move.l	#200,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

	move.b	#2,d0
	move.l	184(a4),a1
	move.l	152(a4),a6
	jsr	_LVOSetAPen(a6)

	clr.b	d0
	move.l	184(a4),a1
	jsr	_LVOSetBPen(a6)

 * clear screen 2.

	move.l	184(a4),a1
	move.w	#380,d0
	clr.w	d1
	move.w	#743,d2
	move.w	#199,d3
	jsr	_LVORectFill(a6)

 * The viewport offsets are now 0,0.

 * Repeat the whole scroll process again, by putting `T' at the side of
 * screen 1 and at the side of screen 2.

	clr.b	d0
	move.l	184(a4),a1
	jsr	_LVOSetAPen(a6)

	move.b	#1,d0
	move.l	184(a4),a1
	jsr	_LVOSetBPen(a6)

	clr.w	d2
	move.w	#19,d4
	clr.w	d6

scroll_three
	move.l	184(a4),a1
	move.w	d2,d0
	move.w	#10,d1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	lea	166(a4),a0
	move.b	#65,d1
	add.b	d4,d1
	move.b	d1,(a0)
	moveq	#1,d0
	move.l	184(a4),a1
	jsr	_LVOText(a6)
	move.l	184(a4),a1
	move.w	#380,d0
	add.w	d2,d0
	move.w	#10,d1
	jsr	_LVOMove(a6)
	lea	166(a4),a0
	move.b	#65,d1
	add.b	d4,d1
	move.b	d1,(a0)
	moveq	#1,d0
	move.l	184(a4),a1
	jsr	_LVOText(a6)

	move.w	#-1,d5

scroll3_loop
	addq.w	#1,d5
	cmp.w	#20,d5
	beq.s	scroll3_end
	move.w	d2,d6
	add.w	d5,d6
	move.w	d6,ri_RxOffset(a3)
	clr.w	ri_RyOffset(a3)
	move.l	160(a4),a0
	jsr	_LVOScrollVPort(a6)
	bra.s	scroll3_loop

scroll3_end
	add.w	#20,d2
	addq.w	#1,d4
	cmp.w	#360,d2
	beq.s	scroll3_complete
	bra.s	scroll_three

 * One screen width (360 pixels) has been scrolled.

scroll3_complete

	move.l	184(a4),a1
	clr.b	d0
	jsr	_LVOSetAPen(a6)

	move.l	184(a4),a1
	move.b	#1,d0
	jsr	_LVOSetBPen(a6)

	move.l	184(a4),a1
	move.w	#440,d0
	move.w	#100,d1
	jsr	_LVOMove(a6)
	move.l	184(a4),a1
	lea	bmstg0(pc),a0
	moveq	#27,d0
	jsr	_LVOText(a6)
	move.l	184(a4),a1
	move.w	#440,d0
	move.w	#110,d1
	jsr	_LVOMove(a6)
	move.l	184(a4),a1
	lea	bmstg5(pc),a0
	moveq	#27,d0
	jsr	_LVOText(a6)

	move.l	#200,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

	move.w	#-21,ri_RxOffset(a3)
	clr.w	ri_RyOffset(a3)

	move.l	184(a4),a1
	clr.b	d0
	move.l	152(a4),a6
	jsr	_LVOSetAPen(a6)

	move.l	184(a4),a1
	move.b	#1,d0
	jsr	_LVOSetBPen(a6)

	move.l	184(a4),a1
	move.w	#40,d0
	move.w	#70,d1
	jsr	_LVOMove(a6)
	move.l	184(a4),a1
	lea	bmstg2(pc),a0
	moveq	#27,d0
	jsr	_LVOText(a6)
	move.l	184(a4),a1
	move.w	#40,d0
	move.w	#80,d1
	jsr	_LVOMove(a6)
	move.l	184(a4),a1
	lea	bmstg6(pc),a0
	moveq	#29,d0
	jsr	_LVOText(a6)
	move.l	184(a4),a1
	move.w	#40,d0
	move.w	#90,d1
	jsr	_LVOMove(a6)
	move.l	184(a4),a1
	lea	bmstg7(pc),a0
	moveq	#29,d0
	jsr	_LVOText(a6)

	move.l	wndwscrn(pc),a0
	move.l	8(a4),a6
	jsr	_LVOMakeScreen(a6)
	jsr	_LVORethinkDisplay(a6)

	move.l	184(a4),a1
	move.b	#2,d0
	move.l	152(a4),a6
	jsr	_LVOSetAPen(a6)

	move.l	184(a4),a1
	clr.b	d0
	jsr	_LVOSetBPen(a6)

	move.l	184(a4),a1
	move.w	#380,d0
	clr.w	d1
	move.w	#739,d2
	move.w	#199,d3
	jsr	_LVORectFill(a6)

	move.l	#400,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)


cl_wndw	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

cl_scrn	move.l	wndwscrn(pc),a0
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

pens
	dc.l	-1

scrntags
	dc.l	SA_Top,0
	dc.l	SA_Left,-32
	dc.l	SA_Width,744
	dc.l	SA_Height,200
	dc.l	SA_Depth,2
	dc.l	SA_Pens,pens
	dc.l	SA_DetailPen,0
	dc.l	SA_BlockPen,1
	dc.l	SA_Title,scrn_title
	dc.l	SA_DisplayID,0
	dc.l	SA_Type,CUSTOMSCREEN
	dc.l	SA_Font,topaz9
	dc.l	SA_Quiet,TRUE
	dc.l	TAG_DONE

wndwtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,744
	dc.l	WA_Height,200
	dc.l	WA_IDCMP,0
	dc.l	WA_Activate,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_SmartRefresh,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_RMBTrap,TRUE
	dc.l	WA_CustomScreen
wndwscrn
	dc.l	0
	dc.l	TAG_DONE

colours	dc.w	$0000,$0FFF,$0F00,$03FF


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
scrn_title	dc.b	'Horizontal_Scroll.s',0
bmstg0		dc.b	'You have just scrolled this',0
bmstg1		dc.b	'screen - Screen 2.',0,0
bmstg2		dc.b	'The bitmap is now offset to',0
bmstg3		dc.b	'screens 0 and 1 - which is ',0
bmstg4		dc.b	'an exact copy of screen 2  ',0
bmstg5		dc.b	'screen - Screen 2 again.   ',0
bmstg6		dc.b	'screens 0 and 1 again - which',0
bmstg7		dc.b	'is an exact copy of screen 2.',0


 * Buffer Variables.

membuf		dcb.b	300,0


	SECTION	VERSION,DATA

	dc.b	'$VER: Horizontal_Scroll.s V1.01 (22.4.2001)',0


	END
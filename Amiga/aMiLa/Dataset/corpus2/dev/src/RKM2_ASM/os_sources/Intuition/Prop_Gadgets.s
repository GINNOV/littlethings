
 * This code shows some of the work involved in Prop gadgets and window
 * re-sizing. I have purposely left some of the code raw so that you can
 * see the image arrows for example when the window is inactive. I used
 * images for the arrows because gadgets are no good when a window is
 * inactive (they keep their highlighted colour). Play around with the
 * window (deactivate it/resize it) to see how I have used certain graphic
 * drawings to clear/update the window. This, to me, is prop/resizing at its
 * most basic. I suppose Boopsi is now the in-thing for creating props, etc.
 * This code also shows some graphic and intuition functions, like SetRGB4(),
 * AddGadget(), etc. Hence why I have not opted to use their multiple
 * functions, like LoadRGB4(), AddGList(), etc.
 *
 * Note: SetRGB4() needs to be moveq #0,d0 for example instead of clr.b d0
 *       (i.e Long instead of Byte) for the index otherwise you may get a
 *       crash. The r g b can be Byte but as SetRGB4() uses the swap
 *       instruction it might be a good idea to use Word. I have stuck with
 *       byte as I am using the GetRGB4() array of (byte) colours. SetRGB4()
 *       also calls SetRGB32(). So it might be worth avoiding GetRGB4() and
 *       stick to using GetRGB32(), SetRGB32(), etc.
 *
 * By the way. I have only shown how to do prop1 (the vertical prop). Just
 * do the same things for the horizontal prop (prop2).

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
	INCLUDE	graphics/videocontrol.i
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
 * 164 vpot
 * 165 hpot
 * 166 Memory Buffer (12 bytes)
 * 178 window
 * 182 value 1 (for ToolType/CLI result)
 * 183 value 2 (for ToolType/CLI result)
 * 184 screen rastport
 * 188 iclass
 * 192 icode
 * 194 iqualifier
 * 196 iaddress
 * 200 mousex
 * 202 mousey
 * 204 screen
 * 208 colourmap
 *

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

	suba.l	a0,a0
	lea	scrntags(pc),a1
	move.l	8(a4),a6
	jsr	_LVOOpenScreenTagList(a6)
	move.l	d0,wndwscrn
	move.l	d0,204(a4)
	beq	cl_icon

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

	lea	rgbs(pc),a3
	moveq	#0,d2
	move.l	152(a4),a6
loop1	move.l	208(a4),a0
	move.l	d2,d0
	jsr	_LVOGetRGB4(a6)
	cmp.l	#-1,d0
	beq	cl_wndw

	move.w	d0,d1
	lsr.w	#8,d1			; Get the Red value.
	move.b	d1,(a3)+		; Poke rgbs with the red value.

	move.w	d0,d1
	and.w	#$00FF,d1
	lsr.b	#4,d1			; Get the Green value.
	move.b	d1,(a3)+		; Poke rgbs with the green value.

	move.w	d0,d1
	and.w	#$000F,d1		; Get the Blue value.
	move.b	d1,(a3)+		; Poke rgbs with the blue value.

	addq.b	#1,d2
	cmp.b	#4,d2
	blt.s	loop1

	bsr	new_colours		Set my own colours.

	bsr	draw_rastport		Draw the Interface.

	jsr	_LVOWaitTOF(a6)

	bsr	add_gadgets

	move.l	208(a4),a0
	lea	vtags(pc),a1
	move.l	152(a4),a6
	jsr	_LVOVideoControl(a6)
	tst.l	d0
	bne	cl_wndw

	move.l	204(a4),a0
	move.l	8(a4),a6
	jsr	_LVOMakeScreen(a6)
	jsr	_LVORethinkDisplay(a6)

mainloop
	move.l	178(a4),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
	move.l	178(a4),a0
	move.l	wd_UserPort(a0),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,a1
	move.l	im_Class(a1),188(a4)
	move.w	im_Code(a1),192(a4)
	move.w	im_Qualifier(a1),194(a4)
	move.l	im_IAddress(a1),196(a4)
	move.w	im_MouseX(a1),200(a4)
	move.w	im_MouseY(a1),202(a4)
	jsr	_LVOReplyMsg(a6)

	cmp.l	#IDCMP_GADGETUP,188(a4)
	beq.s	which_gadgetup

	cmp.l	#IDCMP_GADGETDOWN,188(a4)
	beq	which_gadgetdown

	cmp.l	#IDCMP_VANILLAKEY,188(a4)
	beq	which_vanillakey

	cmp.l	#IDCMP_RAWKEY,188(a4)
	beq	which_rawkey

	cmp.l	#IDCMP_MOUSEBUTTONS,188(a4)
	beq	which_mousebutton

	cmp.l	#IDCMP_REFRESHWINDOW,188(a4)
	beq	refresh_window

	cmp.l	#IDCMP_NEWSIZE,188(a4)
	beq	newsize_window

	cmp.l	#IDCMP_SIZEVERIFY,188(a4)
	beq	sizeverify_window

	cmp.l	#IDCMP_INACTIVEWINDOW,188(a4)
	beq	window_inactive

	cmp.l	#IDCMP_ACTIVEWINDOW,188(a4)
	beq	window_active

	cmp.l	#IDCMP_CLOSEWINDOW,188(a4)
	beq	cl_wndw

	bra	mainloop

which_gadgetup
	cmp.l	#gad0,196(a4)
	beq	do_up

	cmp.l	#gad1,196(a4)
	beq	do_down

	cmp.l	#gad2,196(a4)
	beq	which_upid

	cmp.l	#gad3,196(a4)
	beq	which_upid

	cmp.l	#gad4,196(a4)
	beq.s	do_prop1

	cmp.l	#gad5,196(a4)
	beq	which_upid

	bra	mainloop

do_prop1
	move.l	196(a4),a0
	move.l	gg_SpecialInfo(a0),a0
	moveq	#0,d2
	move.w	pi_VertPot(a0),d2
	divu	#$2492,d2
	move.b	d2,164(a4)
	and.l	#$0000FFFF,d2
	mulu	#$2492,d2
	lea	gad4(pc),a0
	move.l	178(a4),a1
	suba.l	a2,a2
	moveq	#AUTOKNOB!FREEVERT!PROPNEWLOOK,d0
	clr.w	d1
	clr.w	d3
	move.w	#$2000,d4
	moveq	#-1,d5
	move.l	8(a4),a6
	jsr	_LVONewModifyProp(a6)
	bra	mainloop

do_up	moveq	#0,d2
	move.b	164(a4),d2
	subq.b	#1,d2
	tst.b	d2
	blt.s	vpot_e1
	move.b	d2,164(a4)
	mulu	#$2492,d2
	bra.s	vpot_c0
vpot_e1	clr.b	164(a4)
	moveq	#0,d2
	bra.s	vpot_c0
do_down	moveq	#0,d2
	move.b	164(a4),d2
	addq.b	#1,d2
	cmp.b	#7,d2
	bgt.s	vpot_e0
	move.b	d2,164(a4)
	mulu	#$2492,d2
	bra.s	vpot_c0
vpot_e0	move.b	#8,164(a4)
	move.w	#$FFFF,d2
vpot_c0	lea	gad4(pc),a0
	move.l	178(a4),a1
	suba.l	a2,a2
	moveq	#AUTOKNOB!FREEVERT!PROPNEWLOOK,d0
	clr.w	d1
	clr.w	d3
	move.w	#$2000,d4
	moveq	#-1,d5
	move.l	8(a4),a6
	jsr	_LVONewModifyProp(a6)
	bra	mainloop

which_upid

	bra	mainloop

which_gadgetdown

	bra	mainloop

which_downid

	bra	mainloop

which_vanillakey

	bra	mainloop

which_rawkey

	bra	mainloop

which_mousebutton

	bra	mainloop

do_nothing

	bra	mainloop


cl_wndw	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

cl_scrn	move.l	204(a4),a0
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

refresh_window
	bsr	begin_refresh

 * Do some updating here.

	bsr	end_refresh

	bra	mainloop

newsize_window
	move.l	178(a4),a0
	move.w	wd_LeftEdge(a0),wx
	move.w	wd_TopEdge(a0),wy
	move.w	wd_Width(a0),ww
	move.w	wd_Height(a0),wh

	move.b	#3,d0
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOSetAPen(a6)

	move.l	156(a4),a1
	move.w	#4,d0
	move.w	#12,d1
	move.w	ww,d2
	sub.w	#19,d2
	move.w	wh,d3
	sub.w	#11,d3
	jsr	_LVORectFill(a6)

	move.l	178(a4),a0
	lea	gad0(pc),a1
	move.l	8(a4),a6
	jsr	_LVORemoveGadget(a6)

	move.l	178(a4),a0
	lea	gad1(pc),a1
	jsr	_LVORemoveGadget(a6)

	move.l	178(a4),a0
	lea	gad2(pc),a1
	jsr	_LVORemoveGadget(a6)

	move.l	178(a4),a0
	lea	gad3(pc),a1
	jsr	_LVORemoveGadget(a6)

	move.l	178(a4),a0
	lea	gad4(pc),a1
	jsr	_LVORemoveGadget(a6)

	move.l	178(a4),a0
	lea	gad5(pc),a1
	jsr	_LVORemoveGadget(a6)

	move.l	178(a4),a0
	jsr	_LVORefreshWindowFrame(a6)

	move.w	ww,d2
	sub.w	#18,d2
	move.w	wh,d3
	sub.w	#32,d3
	lea	gad0(pc),a0
	move.w	d2,gg_LeftEdge(a0)
	move.w	d3,gg_TopEdge(a0)

	move.w	ww,d2
	sub.w	#18,d2
	move.w	wh,d3
	sub.w	#21,d3
	lea	gad1(pc),a0
	move.w	d2,gg_LeftEdge(a0)
	move.w	d3,gg_TopEdge(a0)

	move.w	ww,d2
	sub.w	#14,d2
	move.w	wh,d3
	sub.w	#46,d3
	lea	gad4(pc),a0
	move.w	d2,gg_LeftEdge(a0)
	move.w	d3,gg_Height(a0)

	move.w	ww,d2
	sub.w	#50,d2
	move.w	wh,d3
	sub.w	#10,d3
	lea	gad2(pc),a0
	move.w	d2,gg_LeftEdge(a0)
	move.w	d3,gg_TopEdge(a0)

	move.w	ww,d2
	sub.w	#34,d2
	move.w	wh,d3
	sub.w	#10,d3
	lea	gad3(pc),a0
	move.w	d2,gg_LeftEdge(a0)
	move.w	d3,gg_TopEdge(a0)

	move.w	ww,d2
	sub.w	#56,d2
	move.w	wh,d3
	subq.w	#8,d3
	lea	gad5(pc),a0
	move.w	d2,gg_Width(a0)
	move.w	d3,gg_TopEdge(a0)

	move.l	178(a4),a0
	lea	gad0(pc),a1
	moveq	#0,d0
	jsr	_LVOAddGadget(a6)

	move.l	178(a4),a0
	lea	gad1(pc),a1
	moveq	#0,d0
	jsr	_LVOAddGadget(a6)

	move.l	178(a4),a0
	lea	gad2(pc),a1
	moveq	#0,d0
	jsr	_LVOAddGadget(a6)

	move.l	178(a4),a0
	lea	gad3(pc),a1
	moveq	#0,d0
	jsr	_LVOAddGadget(a6)

	move.l	178(a4),a0
	lea	gad4(pc),a1
	moveq	#0,d0
	jsr	_LVOAddGadget(a6)

	move.l	178(a4),a0
	lea	gad5(pc),a1
	moveq	#0,d0
	jsr	_LVOAddGadget(a6)

	move.l	178(a4),a1
	lea	gad0(pc),a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	move.l	178(a4),a1
	lea	gad1(pc),a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	move.l	178(a4),a1
	lea	gad2(pc),a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	move.l	178(a4),a1
	lea	gad3(pc),a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	move.l	178(a4),a1
	lea	gad4(pc),a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	move.l	178(a4),a1
	lea	gad5(pc),a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	bsr	draw_rastport

	jsr	_LVOWaitTOF(a6)

	bra	mainloop

sizeverify_window

	bra	mainloop

window_inactive
	bsr	old_colours

	move.l	178(a4),a0
	lea	gad0(pc),a1
	move.l	8(a4),a6
	jsr	_LVORemoveGadget(a6)

	move.l	178(a4),a0
	lea	gad1(pc),a1
	jsr	_LVORemoveGadget(a6)

	move.l	178(a4),a0
	lea	gad2(pc),a1
	jsr	_LVORemoveGadget(a6)

	move.l	178(a4),a0
	lea	gad3(pc),a1
	jsr	_LVORemoveGadget(a6)

	move.l	178(a4),a0
	move.w	wd_LeftEdge(a0),wx
	move.w	wd_TopEdge(a0),wy
	move.w	wd_Width(a0),ww
	move.w	wd_Height(a0),wh

	move.w	ww,d2
	sub.w	#18,d2
	move.w	wh,d3
	sub.w	#32,d3
	lea	arrowi2(pc),a1
	move.w	d2,(a1)				; ig_LeftEdge(a1)
	move.w	d3,ig_TopEdge(a1)
	moveq	#0,d0
	moveq	#0,d1
	bsr	draw_image

	move.w	ww,d2
	sub.w	#18,d2
	move.w	wh,d3
	sub.w	#21,d3
	lea	arrowi3(pc),a1
	move.w	d2,(a1)				; ig_LeftEdge(a1)
	move.w	d3,ig_TopEdge(a1)
	moveq	#0,d0
	moveq	#0,d1
	bsr	draw_image

	bra	mainloop

window_active
	bsr	new_colours

	move.l	178(a4),a0
	lea	gad0(pc),a1
	moveq	#0,d0
	move.l	8(a4),a6
	jsr	_LVOAddGadget(a6)

	move.l	178(a4),a0
	lea	gad1(pc),a1
	moveq	#0,d0
	jsr	_LVOAddGadget(a6)

	move.l	178(a4),a0
	lea	gad2(pc),a1
	moveq	#0,d0
	jsr	_LVOAddGadget(a6)

	move.l	178(a4),a0
	lea	gad3(pc),a1
	moveq	#0,d0
	jsr	_LVOAddGadget(a6)

	move.l	178(a4),a1
	lea	gad0(pc),a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	move.l	178(a4),a1
	lea	gad1(pc),a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	move.l	178(a4),a1
	lea	gad2(pc),a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	move.l	178(a4),a1
	lea	gad3(pc),a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

	bra	mainloop


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

add_gadgets
	move.l	178(a4),a0
	lea	gad4(pc),a1
	moveq	#0,d0
	move.l	8(a4),a6
	jsr	_LVOAddGadget(a6)
	move.l	178(a4),a1
	lea	gad4(pc),a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)
	move.l	178(a4),a0
	lea	gad5(pc),a1
	moveq	#0,d0
	jsr	_LVOAddGadget(a6)
	move.l	178(a4),a1
	lea	gad5,a0
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)
	rts

begin_refresh
	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOBeginRefresh(a6)
	rts

end_refresh
	move.l	178(a4),a0
	moveq	#-1,d0
	move.l	8(a4),a6
	jsr	_LVOEndRefresh(a6)
	rts

old_colours
	lea	rgbs(pc),a3
	move.l	160(a4),a0
	moveq	#0,d0
	move.b	(a3),d1
	move.b	1(a3),d2
	move.b	2(a3),d3
	move.l	152(a4),a6
	jsr	_LVOSetRGB4(a6)
	move.l	160(a4),a0
	moveq	#1,d0
	move.b	3(a3),d1
	move.b	4(a3),d2
	move.b	5(a3),d3
	jsr	_LVOSetRGB4(a6)
	move.l	160(a4),a0
	moveq	#2,d0
	move.b	6(a3),d1
	move.b	7(a3),d2
	move.b	8(a3),d3
	jsr	_LVOSetRGB4(a6)
	move.l	160(a4),a0
	moveq	#3,d0
	move.b	9(a3),d1
	move.b	10(a3),d2
	move.b	11(a3),d3
	jsr	_LVOSetRGB4(a6)
	rts

new_colours
	move.l	160(a4),a0
	moveq	#0,d0
	move.b	#13,d1
	move.b	#12,d2
	move.b	#10,d3
	move.l	152(a4),a6
	jsr	_LVOSetRGB4(a6)
	move.l	160(a4),a0
	moveq	#1,d0
	clr.b	d1
	clr.b	d2
	clr.b	d3
	jsr	_LVOSetRGB4(a6)
	move.l	160(a4),a0
	moveq	#2,d0
	move.b	#15,d1
	move.b	#15,d2
	move.b	#15,d3
	jsr	_LVOSetRGB4(a6)
	move.l	160(a4),a0
	moveq	#3,d0
	move.b	#15,d1
	move.b	#2,d2
	move.b	#2,d3
	jsr	_LVOSetRGB4(a6)
	rts

draw_image
	move.l	156(a4),a0
        move.l	8(a4),a6
        jsr	_LVODrawImage(a6)
        rts

draw_rastport
	move.b	#1,d0
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOSetAPen(a6)
	move.b	#3,d0
	move.l	156(a4),a1
	jsr	_LVOSetBPen(a6)
	move.w	#4,d0
	move.w	#11,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.w	#4,d0
	move.w	wh,d1
	sub.w	#11,d1
	move.l	156(a4),a1
	jsr	_LVODraw(a6)
	move.b	#2,d0
	move.l	156(a4),a1
	jsr	_LVOSetAPen(a6)
	move.w	ww,d0
	sub.w	#19,d0
	move.w	#11,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.w	ww,d0
	sub.w	#19,d0
	move.w	wh,d1
	sub.w	#11,d1
	move.l	156(a4),a1
	jsr	_LVODraw(a6)
	rts

do_hex	and.l	#$0000FFFF,d0
	lea	numstg(pc),a0
	bsr.s	num2hex
	lea	numstg(pc),a0
	bsr.s	spaces
	rts

 * Convert d0.l into an Hex string.

num2hex	moveq	#7,d1
hex_l	rol.l	#4,d0
	move.l	d0,d2
	and.b	#$0F,d0
	cmp.b	#9,d0
	ble.s	hexdig
	addq.b	#7,d0
hexdig	add.b	#48,d0
	move.b	d0,(a0)+
	move.l	d2,d0
	dbf	d1,hex_l
	rts

 * convert hex `0' into character 32 (Space).

spaces	moveq	#7,d0
space_l	cmp.b	#48,(a0)
	bne.s	not_48
	move.b	#32,(a0)+
	dbf	d0,space_l
not_48	rts


 * Structure Definitions.

image3
	dc.w	32,0,32,14,2
	dc.l	id3
	dc.b	3,0
	dc.l	0

image2
	dc.w	0,0,32,14,2
	dc.l	id2
	dc.b	3,0
	dc.l	image3

image1
	dc.w	32,0,32,14,2
	dc.l	id1
	dc.b	3,0
	dc.l	0

image0
	dc.w	0,0,32,14,2
	dc.l	id0
	dc.b	3,0
	dc.l	image1

prop1	dc.w	0,0,0,0

 * Slider PositionX: 65536 ($FFFF) / 32768 ($8000) = 2 (Middle position)
 * Slider Movements: 65536 ($FFFF) / 8192 ($2000)  = 8 (8 movements)
 *
 * Note: To calculate how big each movement will be, do: movements-1 = moves.
 *       65536/moves = movement size. Then simply get the VPot position for
 *       example and devide it by movement size to give you a byte or word
 *       value that you can use as a page number for example.

pi1
	dc.w	AUTOKNOB!FREEHORIZ!PROPNEWLOOK,$0,$0,$2000,$0,0,0,0,0,0,0

gad5
	dc.l	0
	dc.w	3,192,584,6,GFLG_GADGHCOMP,GACT_RELVERIFY,GTYP_PROPGADGET
	dc.l	prop1,0,0,0,pi1
	dc.w	5
        dc.l	0

prop0	dc.w	0,0,0,0

 * Slider PositionY: 65536 ($FFFF) / 32768 ($8000) = 2 (Middle position)
 * Slider Movements: 65536 ($FFFF) / 8192 ($2000)  = 8 (8 movements)
 *
 * Note: To calculate how big each movement will be, do: movements-1 = moves.
 *       65536/moves = movement size. Then simply get the VPot position for
 *       example and devide it by movement size to give you a byte or word
 *       value that you can use as a page number for example.

pi0
	dc.w	AUTOKNOB!FREEVERT!PROPNEWLOOK,$0,$0,$0,$2000,0,0,0,0,0,0

gad4
	dc.l	0
	dc.w	626,13,10,154,GFLG_GADGHCOMP,GACT_RELVERIFY,GTYP_PROPGADGET
	dc.l	prop0,0,0,0,pi0
	dc.w	4
        dc.l	0

gi6
	dc.w	0,0,16,10,2
	dc.l	gd6
	dc.b	3,0
	dc.l	0

gi7
	dc.w	0,0,16,10,2
	dc.l	gd7
	dc.b	3,0
	dc.l	0

gad3
	dc.l	0
	dc.w	606,190,16,10,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	gi6,gi7,0,0,0
	dc.w	3
        dc.l	0

gi4
	dc.w	0,0,16,10,2
	dc.l	gd4
	dc.b	3,0
	dc.l	0

gi5
	dc.w	0,0,16,10,2
	dc.l	gd5
	dc.b	3,0
	dc.l	0

gad2
	dc.l	0
	dc.w	590,190,16,10,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	gi4,gi5,0,0,0
	dc.w	2
        dc.l	0

gi2
	dc.w	0,0,18,11,2
	dc.l	gd2
	dc.b	3,0
	dc.l	0

gi3
	dc.w	0,0,18,11,2
	dc.l	gd3
	dc.b	3,0
	dc.l	0

gad1
	dc.l	0
	dc.w	622,179,18,11,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	gi2,gi3,0,0,0
	dc.w	1
        dc.l	0

gi0
	dc.w	0,0,18,11,2
	dc.l	gd0
	dc.b	3,0
	dc.l	0

gi1
	dc.w	0,0,18,11,2
	dc.l	gd1
	dc.b	3,0
	dc.l	0

gad0
	dc.l	0
	dc.w	622,168,18,11,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	gi0,gi1,0,0,0
	dc.w	0
        dc.l	0

arrowi3
	dc.w	0,0,18,11,2
	dc.l	ad3
	dc.b	3,0
	dc.l	0

arrowi2
	dc.w	0,0,18,11,2
	dc.l	ad2
	dc.b	3,0
	dc.l	0

pens
	dc.l	-1

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

scrntags
	dc.l	SA_Top,0
	dc.l	SA_Left,0
	dc.l	SA_Width,640
	dc.l	SA_Height,256
	dc.l	SA_Depth,2
	dc.l	SA_DetailPen,0
	dc.l	SA_BlockPen,1
	dc.l	SA_Pens,pens
	dc.l	SA_DisplayID,$8000
	dc.l	SA_Type,CUSTOMSCREEN
	dc.l	SA_Font,topaz9
	dc.l	SA_Quiet,TRUE
	dc.l	SA_AutoScroll,FALSE
	dc.l	TAG_DONE

wndwtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,640
	dc.l	WA_Height,200
	dc.l	WA_DetailPen,0
	dc.l	WA_BlockPen,1
	dc.l	WA_MinWidth,320
	dc.l	WA_MinHeight,100
	dc.l	WA_MaxWidth,640
	dc.l	WA_MaxWidth,200
	dc.l	WA_Title,wndw_title
	dc.l	WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW!IDCMP_NEWSIZE!IDCMP_SIZEVERIFY!IDCMP_INACTIVEWINDOW!IDCMP_ACTIVEWINDOW
	dc.l	WA_Activate,TRUE
	dc.l	WA_CloseGadget,TRUE
	dc.l	WA_DepthGadget,TRUE
	dc.l	WA_DragBar,TRUE
	dc.l	WA_SizeGadget,TRUE
	dc.l	WA_SizeBRight,TRUE
	dc.l	WA_SizeBBottom,TRUE
	dc.l	WA_SimpleRefresh,TRUE
	dc.l	WA_CustomScreen
wndwscrn
	dc.l	0
	dc.l	TAG_DONE

vtags
	dc.l	VTAG_BORDERBLANK_SET,0
	dc.l	VTAG_BORDERNOTRANS_SET,0
	dc.l	TAG_DONE


 * Word Variables.

wx	dc.w	0
wy	dc.w	0
ww	dc.w	640
wh	dc.w	200


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
diskfont_name	dc.b	'diskfont.library',0,0
utility_name	dc.b	'utility.library',0
mtstg0		dc.b	'ARG_ONE',0
mtstg1		dc.b	'ARG_TWO',0
mtstg2		dc.b	'ARG_THREE',0
mtstg3		dc.b	'ARG_FOUR',0,0
mtstg4		dc.b	'ARG_FIVE',0,0
mtstg5		dc.b	'ARG_SIX',0
ftstg0          dc.b    'TOOLTYPE_ONE',0,0
ftstg1          dc.b    'TOOLTYPE_TWO',0,0
template	dc.b	'KEYWORD_ONE/K,KEYWORD_TWO/K',0
wndw_title	dc.b	'Prop_Gadgets.s',0,0
font_name	dc.b	'topaz.font',0,0
numstg		dc.b	'                                '
numstglen	equ	*-numstg


 * Buffer Variables.

membuf		dcb.b	300,0
rgbs		ds.b	12


	SECTION	GFX,DATA_C

ad3
	dc.l	%00000000000000000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%00001100000011000100000000000000
	dc.l	%00000011001100000100000000000000
	dc.l	%00000000110000000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%01111111111111111100000000000000

	dc.l	%11111111111111111000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000

ad2
	dc.l	%00000000000000000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%00000000110000000100000000000000
	dc.l	%00000011001100000100000000000000
	dc.l	%00001100000011000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%00000000000000000100000000000000
	dc.l	%01111111111111111100000000000000

	dc.l	%11111111111111111000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000
	dc.l	%10000000000000000000000000000000


id0
	dc.l	%00000000000000000000000000000000
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00000000000000000000000000000000


	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111

id1
	dc.l	%00000000000000000000000000000000
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%00000000000000000000000000000000

	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111
	dc.l	%11111111111111111111111111111111

id2
	dc.l	%00000000000000000000000000000000
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00000000000000000000000000000000

	dc.l	%00000000000000000000000000000000
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00111111111111111111111111111111
	dc.l	%00000000000000000000000000000000

id3
	dc.l	%00000000000000000000000000000000
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%00000000000000000000000000000000

	dc.l	%00000000000000000000000000000000
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%11111111111111111111111111111100
	dc.l	%00000000000000000000000000000000

gd0
	dc.l	%00000000000000000100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000

	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111001111111000000000000000
	dc.l	%11111100110011111000000000000000
	dc.l	%11110011111100111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%10000000000000000000000000000000

gd1
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%10000000000000000000000000000000

	dc.l	%00000000000000000100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111001111111100000000000000
	dc.l	%01111100110011111100000000000000
	dc.l	%01110011111100111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000

gd2
	dc.l	%00000000000000000100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000

	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11110011111100111000000000000000
	dc.l	%11111100110011111000000000000000
	dc.l	%11111111001111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%10000000000000000000000000000000

gd3
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%11111111111111111000000000000000
	dc.l	%10000000000000000000000000000000

	dc.l	%00000000000000000100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01110011111100111100000000000000
	dc.l	%01111100110011111100000000000000
	dc.l	%01111111001111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000
	dc.l	%01111111111111111100000000000000

gd4
	dc.w	%0000000000000000
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111110
	dc.w	%1111111110011110
	dc.w	%1111111001111110
	dc.w	%1111100111111110
	dc.w	%1111111001111110
	dc.w	%1111111110011110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%0000000000000000

gd5
	dc.w	%1111111111111111
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0111111111111111
	dc.w	%0111111110011111
	dc.w	%0111111001111111
	dc.w	%0111100111111111
	dc.w	%0111111001111111
	dc.w	%0111111110011111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%1111111111111111

gd6
	dc.w	%0000000000000000
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111110
	dc.w	%1111100111111110
	dc.w	%1111111001111110
	dc.w	%1111111110011110
	dc.w	%1111111001111110
	dc.w	%1111100111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%0000000000000000

gd7
	dc.w	%1111111111111111
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%1111111111111110
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0111111111111111
	dc.w	%0111100111111111
	dc.w	%0111111001111111
	dc.w	%0111111110011111
	dc.w	%0111111001111111
	dc.w	%0111100111111111
	dc.w	%0111111111111111
	dc.w	%0111111111111111
	dc.w	%1111111111111111


	SECTION	VERSION,DATA

	dc.b	'$VER: Prop_Gadgets.s V1.01 (22.4.2001)',0


	END
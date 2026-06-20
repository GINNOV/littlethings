
 * Simply compile this file (lgui.s), as Linkable, to make the object file
 * (lgui.o) for BLink.
 *
 * BLink lgui.o with:
 *
 * BLINK lgui.o TO lgui LIB Libs:amiga.lib
 *

	INCDIR	WORK:Include/

	INCLUDE	WORK:devpac/system.gs

	XREF	_RangeRand

LIB_VER			EQU	39	; MC68020 specific instructions used.
TRUE            	EQU     -1
FALSE           	EQU     0
CONFIG_SAVESIZE		EQU	478	; Do not expand this size as it is
					; the same size used for STM V3.

	suba.l	a1,a1
	move.l	4.w,a6
	jsr	_LVOFindTask(a6)
	tst.l	d0
	beq	exit
	move.l	d0,a5
	tst.l	pr_CLI(a5)		; Was this task started from CLI?
	bne.s	_main			; Yes.
	lea	pr_MsgPort(a5),a0	; No. From Workbench.
	jsr	_LVOWaitPort(a6)
	lea	pr_MsgPort(a5),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,returnMsg		; D0 = A WBStartup Message.

_main
	move.l	4.w,a6

        moveq	#LIB_VER,d0
        lea     dos_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_DOSBase
        beq     quit

        moveq	#LIB_VER,d0
        lea     int_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_IntuitionBase
        beq     cl_dos

        moveq	#LIB_VER,d0
        lea     graf_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_GfxBase
        beq     cl_int

        moveq	#LIB_VER,d0
        lea     icon_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_IconBase
        beq     cl_gfx

        moveq	#37,d0
        lea     trans_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_TranslatorBase
        beq     cl_icon

 * Check the ToolTypes/CLI Arguments.

        move.l	returnMsg(pc),a0
        tst.l   a0
        beq     fromcli
	move.l	sm_ArgList(a0),a5
        move.l  (a5),d1
	beq	zero_args
	move.l	_DOSBase(pc),a6
	jsr	_LVOCurrentDir(a6)
        move.l  d0,olddir
        move.l	wa_Name(a5),a0
	move.l	_IconBase(pc),a6
	jsr	_LVOGetDiskObject(a6)
        move.l  d0,doptr
        beq     zero_args
        move.l	d0,a5
        move.l  do_ToolTypes(a5),a5
	moveq	#-1,d6
	move.l	#255,d7
	move.l	a5,a0
        lea	ftstg0(pc),a1
	jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	tt1
	move.l	d0,a0
	bsr	tt_num
	tst.l	d2
	bne.s	tt1
	move.b	d1,401(a4)
tt1	move.l	a5,a0
        lea	ftstg1(pc),a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	tt2
	move.l	d0,a4
	move.l	a4,a0
	lea	yes(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto1
	move.b	#1,clwb
	bra.s	tt2
tto1	move.l	a4,a0
	lea	no(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tt2
	clr.b	clwb
tt2	move.l	a5,a0
        lea	ftstg2(pc),a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	tt3
	move.l	d0,a4
	clr.w	d7
tto2_l	lea	ttlist0(pc),a3
	move.l	0(a3,d7.w),a1
	move.l	a4,a0
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto2_0
	move.b	d7,fnload
	bra.s	tt3
tto2_0	addq.b	#4,d7
	cmp.b	#44,d7
	blt.s	tto2_l
tt3	move.l	a5,a0
        lea	ftstg3(pc),a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	tt4
	move.l	d0,a4
	clr.w	d7
tto3_l	lea	ttlist0(pc),a3
	move.l	0(a3,d7.w),a1
	move.l	a4,a0
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto3_0
	move.b	d7,fnsave
	bra.s	tt4
tto3_0	addq.b	#4,d7
	cmp.b	#44,d7
	blt.s	tto3_l
tt4
	nop

free_diskobj
        move.l	doptr(pc),a0
        jsr	_LVOFreeDiskObject(a6)
	bra	zero_args

fromcli	lea	template(pc),a0
	move.l  a0,d1
        lea     argv(pc),a5
        move.l  a5,d2
        moveq	#0,d3
	move.l	_DOSBase(pc),a6
        jsr	_LVOReadArgs(a6)
        move.l  d0,rdargs
        beq	zero_args
	moveq	#-1,d6
	move.l	#255,d7
	move.l	(a5),a0
        bsr     findlen
	cmp.l	#4,d0
	bne.s	ca1
	bsr	arg_num
	cmp.l	#-1,d0
	beq.s	ca1
	move.b	d0,401(a4)
ca1	move.l	4(a5),a0
	lea	yes(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao1
	move.b	#1,clwb
	bra.s	ca2
cao1	move.l	4(a5),a0
	lea	no(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	ca2
	clr.b	clwb
ca2	clr.w	d7
ca2_l	lea	ttlist0(pc),a3
	move.l	0(a3,d7.w),a1
	move.l	8(a5),a0
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao2_0
	move.b	d7,fnload
	bra.s	ca3
cao2_0	addq.b	#4,d7
	cmp.b	#44,d7
	blt.s	ca2_l
ca3	clr.w	d7
ca3_l	lea	ttlist0(pc),a3
	move.l	0(a3,d7.w),a1
	move.l	12(a5),a0
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao3_0
	move.b	d7,fnsave
	bra.s	ca4
cao3_0	addq.b	#4,d7
	cmp.b	#44,d7
	blt.s	ca3_l
ca4
	nop

free_cliargs
        move.l  rdargs(pc),d1
        jsr	_LVOFreeArgs(a6)

zero_args

	lea	config,a4
	bsr	def_cf

	lea	topaz9(pc),a0
	move.l	_GfxBase(pc),a6
	jsr	_LVOOpenFont(a6)
	move.l	d0,stgfnt
	beq.s	no_font
	move.l	d0,sefnt0
	move.l	d0,sefnt1
	move.l	d0,sefnt2
	move.l	d0,sefnt3
	move.l	d0,sefnt4
	move.l	d0,sefnt5
	move.l	d0,sefnt6
	bra.s	do_lgui

no_font

	bra	cl_tran

do_lgui	suba.l	a0,a0
	lea	scrn0tags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenScreenTagList(a6)
	move.l	d0,scrn0ptr
	move.l	d0,wndw0scrn
	move.l	d0,aboutscrn
	move.l	d0,btnscrn
	beq	cl_font
	move.l	d0,a0
	lea	sc_RastPort(a0),a5
	move.l	a5,scrn0rp
	lea	sc_ViewPort(a0),a2
	move.l	a2,vp0ptr
	clr.b	d0
	move.l	a5,a1
	move.l	_GfxBase(pc),a6
	jsr	_LVOSetRast(a6)
	suba.l	a0,a0
	lea	wndw0tags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,wndw0ptr
	beq	cl_scrn0
	move.l	wndw0ptr(pc),a1
	move.l	wd_RPort(a1),a1
	move.l	a1,wndw0rp
	bsr	basic
	lea	image2(pc),a1
	bsr	drawi
	lea	image4(pc),a1
	bsr	drawi
	lea	image6(pc),a1
	bsr	drawi
	lea	image48(pc),a1
	bsr	drawi
	lea	image49(pc),a1
	bsr	drawi
	lea	image50(pc),a1
	bsr	drawi
	lea	image51(pc),a1
	bsr	drawi
	lea	image52(pc),a1
	bsr	drawi
	lea	image53(pc),a1
	bsr	drawi
	move.l	_GfxBase(pc),a6
	bsr	pen_a6
	move.l	a5,a1
	move.w	#103,d0
	move.w	#6,d1
	move.w	#104,d2
	move.w	#7,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#83,d0
	move.w	#110,d1
	move.w	#84,d2
	move.w	#111,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#96,d0
	move.w	#110,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#97,d0
	move.w	#110,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#130,d0
	move.w	#110,d1
	move.w	#131,d2
	move.w	#111,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#83,d0
	move.w	#148,d1
	move.w	#84,d2
	move.w	#149,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#145,d0
	move.w	#148,d1
	move.w	#146,d2
	move.w	#149,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a14
	move.l	a5,a1
	move.w	#187,d0
	move.w	#5,d1
	move.w	#625,d2
	move.w	#32,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#187,d0
	move.w	#38,d1
	move.w	#625,d2
	move.w	#65,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a13
	move.l	a5,a1
	move.w	#189,d0
	move.w	#5,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#625,d0
	move.w	#5,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#624,d0
	move.w	#6,d1
	move.w	#625,d2
	move.w	#31,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#189,d0
	move.w	#38,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#625,d0
	move.w	#38,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#624,d0
	move.w	#39,d1
	move.w	#625,d2
	move.w	#64,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a15
	move.l	a5,a1
	move.w	#187,d0
	move.w	#6,d1
	move.w	#188,d2
	move.w	#32,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#189,d0
	move.w	#32,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#623,d0
	move.w	#32,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#187,d0
	move.w	#39,d1
	move.w	#188,d2
	move.w	#65,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#189,d0
	move.w	#65,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#623,d0
	move.w	#65,d1
	jsr	_LVODraw(a6)
	move.w	#71,d4
nav_l0	bsr	pen_a14
	move.l	a5,a1
	move.w	#187,d0
	move.w	d4,d1
	move.w	#625,d2
	move.w	#13,d3
	add.w	d4,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a13
	move.l	a5,a1
	move.w	#189,d0
	move.w	d4,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#625,d0
	move.w	d4,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#624,d0
	move.w	#1,d1
	add.w	d4,d1
	move.w	#625,d2
	move.w	#12,d3
	add.w	d4,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a15
	move.l	a5,a1
	move.w	#187,d0
	move.w	#1,d1
	add.w	d4,d1
	move.w	#188,d2
	move.w	#13,d3
	add.w	d4,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#189,d0
	move.w	#13,d1
	add.w	d4,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#623,d0
	move.w	#13,d1
	add.w	d4,d1
	jsr	_LVODraw(a6)
	add.w	#19,d4
	cmp.w	#167,d4
	blt	nav_l0
	suba.l	a0,a0
	lea	scrn1tags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenScreenTagList(a6)
	move.l	d0,scrn1ptr
	move.l	d0,wndw1scrn
	move.l	d0,prefsscrn
	move.l	d0,searchscrn
	beq	cl_wndw0
	move.l	d0,a0
	lea	sc_RastPort(a0),a5
	move.l	a5,scrn1rp
	lea	sc_ViewPort(a0),a2
	move.l	a2,vp1ptr
	clr.b	d0
	move.l	a5,a1
	move.l	_GfxBase(pc),a6
	jsr	_LVOSetRast(a6)
	move.l	vp0ptr(pc),a0
	lea	scv0(pc),a1
	move.w	#16,d0
	jsr	_LVOLoadRGB4(a6)
	jsr	_LVOWaitTOF(a6)
	suba.l	a0,a0
	lea	wndw1tags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,wndw1ptr
	beq	cl_scrn1
	move.l	wndw1ptr(pc),a1
	move.l	wd_RPort(a1),a1
	move.l	a1,wndw1rp
	bsr	basic
	move.w	#6,d4
nav_l1	bsr	pen_a14
	move.l	a5,a1
	move.w	#16,d0
	move.w	d4,d1
	move.w	#309,d2
	move.w	#11,d3
	add.w	d4,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#330,d0
	move.w	d4,d1
	move.w	#623,d2
	move.w	#11,d3
	add.w	d4,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a13
	move.l	a5,a1
	move.w	#18,d0
	move.w	d4,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#309,d0
	move.w	d4,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#308,d0
	move.w	#1,d1
	add.w	d4,d1
	move.w	#309,d2
	move.w	#10,d3
	add.w	d4,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#332,d0
	move.w	d4,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#623,d0
	move.w	d4,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#622,d0
	move.w	#1,d1
	add.w	d4,d1
	move.w	#623,d2
	move.w	#10,d3
	add.w	d4,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a15
	move.l	a5,a1
	move.w	#16,d0
	move.w	#1,d1
	add.w	d4,d1
	move.w	#17,d2
	move.w	#11,d3
	add.w	d4,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#330,d0
	move.w	#1,d1
	add.w	d4,d1
	move.w	#331,d2
	move.w	#11,d3
	add.w	d4,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#18,d0
	move.w	#11,d1
	add.w	d4,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#307,d0
	move.w	#11,d1
	add.w	d4,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#332,d0
	move.w	#11,d1
	add.w	d4,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#621,d0
	move.w	#11,d1
	add.w	d4,d1
	jsr	_LVODraw(a6)
	add.w	#16,d4
	cmp.w	#166,d4
	ble	nav_l1
	bsr	pen_a8
	move.l	a5,a1
	move.w	#256,d0
	move.w	#187,d1
	move.w	#400,d2
	move.w	#198,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a7
	move.l	a5,a1
	move.w	#256,d0
	move.w	#186,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#400,d0
	move.w	#186,d1
	jsr	_LVODraw(a6)
	bsr	pen_a9
	move.l	a5,a1
	move.w	#256,d0
	move.w	#199,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#400,d0
	move.w	#199,d1
	jsr	_LVODraw(a6)
	lea	image30(pc),a1
	bsr	drawi
	lea	image31(pc),a1
	bsr	drawi
	lea	image38(pc),a1
	bsr	drawi
	lea	image39(pc),a1
	bsr	drawi
	bsr	stf0
	move.l	_GfxBase(pc),a6
	move.l	vp1ptr(pc),a0
	lea	scv1(pc),a1
	move.w	#16,d0
	jsr	_LVOLoadRGB4(a6)
	jsr	_LVOWaitTOF(a6)
	bsr	set_mse
	tst.b	clwb
	beq.s	load_lt
	jsr	_LVOCloseWorkBench(a6)
load_lt	bsr	load_titles
	tst.b	d6
	beq.s	load_cf
	moveq	#9,d6
	move.b	#100,d7
	bsr	btn_req
load_cf	bsr	load_config
	tst.b	d6
	beq.s	ud_cf
	moveq	#10,d6
	move.b	#100,d7
	bsr	btn_req
ud_cf	bsr	update_config
	bsr	load_files
	tst.b	d6
	bne	clr_pointer
	bsr	update_seq
	move.w	456(a4),458(a4)
	move.w	456(a4),460(a4)
	lea	wb0(pc),a0
	lea	sb0(pc),a1
	move.w	84(a0),470(a4)
	move.w	84(a1),472(a4)
	tst.b	435(a4)
	beq.s	load_sf
	move.w	#1,84(a0)
	move.w	#1,84(a1)
load_sf	move.b	#12,d7
	moveq	#21,d4
	bsr	load_file
	move.b	#10,d7
	moveq	#21,d4
	bsr	load_file
	bsr	clr_mse
	clr.b	count
zerkeys	tst.b	454(a4)
	bne.s	xyz
	move.l	wndw0ptr(pc),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
	move.l	wndw0ptr(pc),a0
	bsr	get_msg
	bra.s	xyz_c0
xyz	move.l	4.w,a6
	move.l	wndw0ptr(pc),a0
	move.l	wd_UserPort(a0),a0
	jsr	_LVOGetMsg(a6)
	tst.l	d0
	beq.s	zk_auto
	move.l	d0,a1
	move.l	im_Class(a1),iclass
	move.w	im_Code(a1),icode
	move.w	im_Qualifier(a1),iqual
	move.l	im_IAddress(a1),iadr
	move.w	im_MouseX(a1),msex
	move.w	im_MouseY(a1),msey
	jsr	_LVOReplyMsg(a6)
	move.l	iclass,d0

xyz_c0	cmp.l	#IDCMP_VANILLAKEY,d0
	beq	zerk_vk

	cmp.l	#IDCMP_RAWKEY,d0
	beq	zerk_rk

	cmp.l	#IDCMP_MOUSEBUTTONS,d0
	beq	zerk_mb

zk_auto	tst.b	430(a4)
	bne.s	zk_c9
	bsr	clr_words
	bsr	show_words
	tst.b	422(a4)
	beq.s	zk_c4
	tst.b	423(a4)
	bne.s	zk_c1
	bra.s	zk_d0
zk_c1	tst.b	424(a4)
	beq.s	zk_c5
	tst.b	425(a4)
	bne.s	zk_c2
	bra.s	zk_d0
zk_c2	tst.b	426(a4)
	beq.s	zk_c6
	tst.b	427(a4)
	bne.s	zk_c3
	bra.s	zk_d0
zk_c4	tst.b	423(a4)
	beq.s	zk_c3
	bra.s	zk_d0
zk_c5	tst.b	425(a4)
	beq.s	zk_c3
	bra.s	zk_d0
zk_c6	tst.b	427(a4)
	beq.s	zk_c3
zk_d0	move.w	444(a4),d1
	tst.w	d1
	beq.s	zk_c7
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
zk_c7	bsr	reveal_words
	move.w	438(a4),d1
	tst.w	d1
	beq.s	zk_c3
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
zk_c3	bra	say_it
zk_c9	bsr	clr_sents
	bsr	show_sentences
	tst.b	420(a4)
	beq.s	zk_c10
	tst.b	421(a4)
	bne.s	zk_c11
	bra.s	zk_d2
zk_c10	tst.b	421(a4)
	beq.s	zk_c11
zk_d2	move.w	444(a4),d1
	tst.w	d1
	beq.s	zk_c12
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
zk_c12	bsr	reveal_sents
	move.w	438(a4),d1
	tst.w	d1
	beq.s	zk_c11
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
zk_c11	bra	say_it

zerk_vk	move.w	iqual,d0
	move.w	icode,d1
	cmp.w	#$8001,d0
	bne.s	numkeys
	cmp.b	#27,d1
	beq	freedfs
	bra	zvk_end
numkeys	cmp.w	#$8100,d0
	bne.s	zkeys
	tst.b	454(a4)
	bne	zvk_end
	cmp.b	#56,d1
	beq	up_bf
	cmp.b	#50,d1
	beq	down_bf
	bra.s	zvk_end
zkeys	tst.b	454(a4)
	bne.s	autm
	cmp.b	#$52,d1
	beq	rvealws
	cmp.b	#$72,d1
	beq	rvealws
	cmp.b	#$4E,d1
	beq	nextws
	cmp.b	#$6E,d1
	beq	nextws
	cmp.b	#$53,d1
	beq	say_it
	cmp.b	#$73,d1
	beq	say_it
	cmp.b	#$41,d1
	beq	do_amm
	cmp.b	#$61,d1
	beq	do_amm
	cmp.b	#$3F,d1
	beq	about
	cmp.b	#$4F,d1
	beq.s	do_stf1
	cmp.b	#$6F,d1
	beq.s	do_stf1
	bra.s	zvk_end
autm	cmp.b	#$4D,d1
	beq	do_man
	cmp.b	#$6D,d1
	beq	do_man
	cmp.b	#$50,d1
	beq	paus_it
	cmp.b	#$70,d1
	beq	paus_it
zvk_end	bra	zerkeys

do_stf1	bsr	stf1
	bra	onekeys

zerk_rk	move.w	iqual,d0
	move.w	icode,d1
	cmp.w	#$8000,d0
	bne.s	zshft_l
	tst.b	454(a4)
	bne.s	zrk_end	
	cmp.b	#80,d1
	beq.s	zrk_f1
	cmp.b	#81,d1
	beq.s	zrk_f2
	cmp.b	#82,d1
	beq.s	zrk_f3
	cmp.b	#83,d1
	beq.s	zrk_f4
	cmp.b	#84,d1
	beq.s	zrk_f5
	cmp.b	#85,d1
	beq.s	zrk_f6
	cmp.b	#86,d1
	beq.s	zrk_f7
	cmp.b	#87,d1
	beq.s	zrk_f8
	bra.s	zrk_end
zshft_l	cmp.w	#$8001,d0
	bne.s	zrk_end
	nop
zrk_end	bra	zerkeys

zrk_f1	bsr	do_but0
	bsr	onoffds
	bra	zerkeys

zrk_f2	bsr	do_but1
	bsr	onofffs
	bra	zerkeys

zrk_f3	bsr	do_but2
	bsr	onoffdp
	bra	zerkeys

zrk_f4	bsr	do_but3
	bsr	onofffp
	bra	zerkeys

zrk_f5	bsr	do_but4
	bsr	onoffdj
	bra	zerkeys

zrk_f6	bsr	do_but5
	bsr	onofffj
	bra	zerkeys

zrk_f7	bsr	do_but6
	bsr	onoffdv
	bra	zerkeys

zrk_f8	bsr	do_but7
	bsr	onofffv
	bra	zerkeys

do_amm	tst.b	454(a4)
	beq.s	do_am

do_man	clr.b	454(a4)
	lea	image6(pc),a1
	bsr	drawi
	bra	zerkeys

do_am	move.b	#1,454(a4)
	lea	image7(pc),a1
	bsr	drawi
	bra	zerkeys

paus_it	lea	image3(pc),a1
	bsr	drawi
	moveq	#0,d1
	move.w	446(a4),d1
	tst.w	d1
	beq.s	paus_m
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
	bra.s	paus_e
paus_m	bsr.s	pm_loop
paus_e	lea	image2(pc),a1
	bsr	drawi
	bra	zerkeys

pm_loop	move.l	wndw0ptr(pc),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOGetMsg(a6)
	tst.l	d0
	beq.s	pm_loop
	move.l	d0,a1
	move.l	im_Class(a1),iclass
	move.w	im_Code(a1),icode
	move.w	im_Qualifier(a1),iqual
	move.l	im_IAddress(a1),iadr
	move.w	im_MouseX(a1),msex
	move.w	im_MouseY(a1),msey
	jsr	_LVOReplyMsg(a6)
	cmp.l	#IDCMP_MOUSEBUTTONS,iclass
	beq.s	chk_mb2
	bra.s	pm_loop

chk_mb2	cmpi.w	#MENUDOWN,icode
	bne.s	pm_loop
	rts

say_it	tst.b	433(a4)
	beq.s	si_end
	move.w	456(a4),d0
	cmp.w	460(a4),d0
	beq.s	si_end
	tst.b	430(a4)
	bne.s	say_s
	tst.b	468(a4)
	beq.s	si_end
	tst.b	422(a4)
	bne.s	sound
	tst.b	423(a4)
	bne.s	sound
	tst.b	424(a4)
	bne.s	sound
	tst.b	425(a4)
	bne.s	sound
	tst.b	426(a4)
	bne.s	sound
	tst.b	427(a4)
	bne.s	sound
	bra.s	si_end
say_s	tst.b	469(a4)
	beq.s	si_end
	tst.b	420(a4)
	bne.s	sound
	tst.b	421(a4)
	bne.s	sound
	bra.s	si_end
sound	lea	image5(pc),a1
	bsr	drawi
	bsr	speakToMe
	lea	image4(pc),a1
	bsr	drawi
si_end	bra	zerkeys

rvealws	tst.b	466(a4)
	beq.s	rws_end
	tst.b	467(a4)
	bne.s	rws_end
	tst.b	430(a4)
	beq.s	rvealw
	bra.s	rveals
rvealw	bsr	reveal_words
	bra.s	rws_end
rveals	bsr	reveal_sents
rws_end	bra	zerkeys

nextws	tst.b	430(a4)
	beq.s	nextw
	bra.s	nexts

nextw	bsr	clr_words
	bsr	show_words
	bra	zerkeys

nexts	bsr	clr_sents
	bsr	show_sentences
	bra	zerkeys

up_bf	tst.b	430(a4)
	bne.s	u_sents
	bsr	clr_words
	bsr	wordsbf
	lea	wb0(pc),a0
	bra.s	uo_c0
u_sents	bsr	clr_sents
	bsr	sentsbf
	lea	sb0(pc),a0
uo_c0	move.w	456(a4),460(a4)
	addq.w	#1,456(a4)
	moveq	#0,d0
	move.b	428(a4),d0
	move.w	2(a0,d0.w*4),d1
	move.w	456(a4),d2
	cmp.w	d1,d2
	ble.s	uo_c1
	move.w	0(a0,d0.w*4),456(a4)
uo_c1	move.w	456(a4),458(a4)
	move.b	#1,466(a4)
	clr.b	467(a4)
	bra	zerkeys

down_bf	move.w	460(a4),456(a4)
	move.w	460(a4),458(a4)
	subq.w	#1,456(a4)
	tst.b	430(a4)
	bne.s	d_sents
	lea	wb0(pc),a0
	moveq	#0,d0
	move.b	428(a4),d0
	move.w	0(a0,d0.w*4),d1
	move.w	456(a4),d2
	cmp.w	d1,d2
	bge.s	do_c0
	move.w	2(a0,d0.w*4),456(a4)
do_c0	move.w	456(a4),460(a4)
	bsr	clr_words
	bsr	wordsbf
	bra.s	do_c2
d_sents	lea	sb0(pc),a0
	moveq	#0,d0
	move.b	428(a4),d0
	move.w	0(a0,d0.w*4),d1
	move.w	456(a4),d2
	cmp.w	d1,d2
	bge.s	do_c1
	move.w	2(a0,d0.w*4),456(a4)
do_c1	move.w	456(a4),460(a4)
	bsr	clr_words
	bsr	sentsbf
do_c2	move.w	458(a4),456(a4)
	move.b	#1,466(a4)
	move.b	#1,467(a4)
	bra	zerkeys

zerk_mb	move.w	msex,d0
	move.w	msey,d1
	cmp.w	#SELECTDOWN,icode
	bne	chk_md
	tst.b	454(a4)
	bne	sdaut
	cmp.w	#186,d1
	blt	mse_z0
	cmp.w	#199,d1
	bgt	mse_z0
	cmp.w	#96,d0
	blt.s	mse_zc1
	cmp.w	#202,d0
	bgt.s	mse_zc1
	bra	rvealws
mse_zc1	cmp.w	#207,d0
	blt.s	mse_zc2
	cmp.w	#283,d0
	bgt.s	mse_zc2
	bra	nextws
mse_zc2	cmp.w	#287,d0
	blt.s	mse_zc3
	cmp.w	#378,d0
	bgt.s	mse_zc3
	bra	say_it
	bra	zmb_end
mse_zc3	cmp.w	#383,d0
	blt.s	mse_zc4
	cmp.w	#489,d0
	bgt.s	mse_zc4
	bra	do_amm
mse_zc4	cmp.w	#494,d0
	blt.s	mse_zc5
	cmp.w	#514,d0
	bgt.s	mse_zc5
	bra	about
mse_zc5	cmp.w	#519,d0
	blt.s	mse_zc6
	cmp.w	#595,d0
	bgt.s	mse_zc6
	bra	do_stf1
mse_zc6	cmp.w	#601,d0
	blt.s	mse_zc7
	cmp.w	#617,d0
	bgt.s	mse_zc7
	bra	up_bf
mse_zc7	cmp.w	#622,d0
	blt	zmb_end
	cmp.w	#638,d0
	bgt	zmb_end
	bra	down_bf
mse_z0	cmp.w	#19,d0
	blt	zmb_end
	cmp.w	#44,d0
	bgt	zmb_end
	cmp.w	#8,d1
	blt.s	mse_cz0
	cmp.w	#15,d1
	bgt.s	mse_cz0
	bsr	do_but0
	bsr	onoffds
	bra	zmb_end
mse_cz0	cmp.w	#41,d1
	blt.s	mse_cz1
	cmp.w	#48,d1
	bgt.s	mse_cz1
	bsr	do_but1
	bsr	onofffs
	bra	zmb_end
mse_cz1	cmp.w	#74,d1
	blt.s	mse_cz2
	cmp.w	#81,d1
	bgt.s	mse_cz2
	bsr	do_but2
	bsr	onoffdp
	bra	zmb_end
mse_cz2	cmp.w	#93,d1
	blt.s	mse_cz3
	cmp.w	#100,d1
	bgt.s	mse_cz3
	bsr	do_but3
	bsr	onofffp
	bra	zmb_end
mse_cz3	cmp.w	#112,d1
	blt.s	mse_cz4
	cmp.w	#119,d1
	bgt.s	mse_cz4
	bsr	do_but4
	bsr	onoffdj
	bra	zmb_end
mse_cz4	cmp.w	#130,d1
	blt.s	mse_cz5
	cmp.w	#137,d1
	bgt.s	mse_cz5
	bsr	do_but5
	bsr	onofffj
	bra.s	zmb_end
mse_cz5	cmp.w	#150,d1
	blt.s	mse_cz6
	cmp.w	#157,d1
	bgt.s	mse_cz6
	bsr	do_but6
	bsr	onoffdv
	bra.s	zmb_end
mse_cz6	cmp.w	#170,d1
	blt.s	zmb_end
	cmp.w	#177,d1
	bgt.s	zmb_end
	bsr.s	do_but7
	bsr	onofffv
	bra.s	zmb_end
sdaut	cmp.w	#186,d1
	blt.s	zmb_end
	cmp.w	#199,d1
	bgt.s	zmb_end
	tst.w	d0
	blt.s	zmb_end
	cmp.w	#91,d0
	bgt.s	zmb_end
	bra	paus_it
chk_md	cmp.w	#MENUDOWN,icode
	bne.s	zmb_end
	cmp.w	#186,d1
	blt.s	zmb_end
	cmp.w	#199,d1
	bgt.s	zmb_end
	cmp.w	#383,d0
	blt.s	zmb_end
	cmp.w	#489,d0
	bgt.s	zmb_end
	bra	do_man
zmb_end	bra	zerkeys

do_but0	lea	420(a4),a0
	bra.s	do_but
do_but1	lea	421(a4),a0
	bra.s	do_but
do_but2	lea	422(a4),a0
	bra.s	do_but
do_but3	lea	423(a4),a0
	bra.s	do_but
do_but4	lea	424(a4),a0
	bra.s	do_but
do_but5	lea	425(a4),a0
	bra.s	do_but
do_but6	lea	426(a4),a0
	bra.s	do_but
do_but7	lea	427(a4),a0
do_but	addq.b	#1,(a0)
	cmp.b	#1,(a0)
	ble.s	but_ok
	clr.b	(a0)
but_ok	rts

onekeys	move.l	wndw1ptr(pc),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
	move.l	wndw1ptr(pc),a0
	bsr	get_msg

	cmp.l	#IDCMP_VANILLAKEY,d0
	beq.s	onek_vk

	cmp.l	#IDCMP_RAWKEY,d0
	beq.s	onek_rk

	cmp.l	#IDCMP_MOUSEBUTTONS,d0
	beq	onek_mb

	bra.s	onekeys

onek_vk	move.w	iqual,d0
	move.w	icode,d1
	cmp.w	#$8001,d0
	bne.s	nkeys
	cmp.b	#127,d1
	beq	ls_del
	cmp.b	#27,d1
	beq	freedfs
	bra.s	vk_end
nkeys	cmp.b	#127,d1
	beq	rk_del
	cmp.b	#$57,d1
	beq	wordt
	cmp.b	#$77,d1
	beq	wordt
	cmp.b	#$53,d1
	beq	sentt
	cmp.b	#$73,d1
	beq	sentt
	cmp.b	#$45,d1
	beq.s	do_stf0
	cmp.b	#$65,d1
	beq.s	do_stf0
vk_end	bra	onekeys

do_stf0	move.l	scrn0rp,a5
	bsr	clr_words
	bsr	clr_sents
	bsr	stf0
	bra	zerkeys

onek_rk	move.w	iqual,d0
	move.w	icode,d1
	cmp.w	#$8000,d0
	bne.s	shift_l
	cmp.b	#80,d1
	blt.s	rk_end
	cmp.b	#89,d1
	ble.s	rk_keys
	bra.s	rk_end
shift_l	cmp.w	#$8001,d0
	bne.s	rk_end
	cmp.b	#80,d1
	blt.s	rk_end
	cmp.b	#89,d1
	ble.s	ls_keys
rk_end	bra	onekeys

ls_del	move.b	#90,d1
ls_keys	add.b	#11,d1
	bra.s	rk_keys
rk_del	move.b	#90,d1
rk_keys	move.b	428(a4),429(a4)
	sub.b	#80,d1
	move.b	d1,428(a4)
	move.b	429(a4),d0
	cmp.b	d1,d0
	beq.s	rk_c0
	bsr	drawnb
rk_c0	bra	onekeys

do_wst	tst.b	430(a4)
	beq.s	sentt

wordt	clr.b	430(a4)
	bsr.s	ud_ws
	bra	onekeys

sentt	move.b	#1,430(a4)
	bsr.s	ud_ws
	bra	onekeys

ud_ws	move.l	scrn0rp,a5
	bsr	clr_words
	bsr	clr_sents
	bsr	update_seq
	move.w	456(a4),458(a4)
	move.l	scrn1rp,a5
	bsr	show_titles
	rts

onek_mb	move.w	msex,d0
	move.w	msey,d1
	cmp.w	#SELECTDOWN,icode
	bne	mb_end
	cmp.w	#186,d1
	blt.s	mse_n0
	cmp.w	#199,d1
	bgt.s	mse_n0
	tst.w	d0
	blt.s	mse_c22
	cmp.w	#107,d0
	bgt.s	mse_c22
	bsr	search
	bra	mb_end
mse_c22	cmp.w	#112,d0
	blt.s	mse_c23
	cmp.w	#204,d0
	bgt.s	mse_c23
	bsr	prefs
	bra	mb_end
mse_c23
	nop

mse_c26	cmp.w	#469,d0
	blt.s	mse_c27
	cmp.w	#561,d0
	bgt.s	mse_c27
	bra	do_wst
mse_c27	cmp.w	#566,d0
	blt	mb_end
	cmp.w	#639,d0
	bgt	mb_end
	bra	do_stf0
mse_n0	cmp.w	#16,d0
	blt	mse_n1
	cmp.w	#309,d0
	bgt	mse_n1
	cmp.w	#6,d1
	blt.s	mse_c1
	cmp.w	#17,d1
	bgt.s	mse_c1
	move.b	#80,d1
	bra	rk_keys
mse_c1	cmp.w	#22,d1
	blt.s	mse_c2
	cmp.w	#33,d1
	bgt.s	mse_c2
	move.b	#81,d1
	bra	rk_keys
mse_c2	cmp.w	#38,d1
	blt.s	mse_c3
	cmp.w	#49,d1
	bgt.s	mse_c3
	move.b	#82,d1
	bra	rk_keys
mse_c3	cmp.w	#54,d1
	blt.s	mse_c4
	cmp.w	#65,d1
	bgt.s	mse_c4
	move.b	#83,d1
	bra	rk_keys
mse_c4	cmp.w	#70,d1
	blt.s	mse_c5
	cmp.w	#81,d1
	bgt.s	mse_c5
	move.b	#84,d1
	bra	rk_keys
mse_c5	cmp.w	#86,d1
	blt.s	mse_c6
	cmp.w	#97,d1
	bgt.s	mse_c6
	move.b	#85,d1
	bra	rk_keys
mse_c6	cmp.w	#102,d1
	blt.s	mse_c7
	cmp.w	#113,d1
	bgt.s	mse_c7
	move.b	#86,d1
	bra	rk_keys
mse_c7	cmp.w	#118,d1
	blt.s	mse_c8
	cmp.w	#129,d1
	bgt.s	mse_c8
	move.b	#87,d1
	bra	rk_keys
mse_c8	cmp.w	#134,d1
	blt.s	mse_c9
	cmp.w	#145,d1
	bgt.s	mse_c9
	move.b	#88,d1
	bra	rk_keys
mse_c9	cmp.w	#150,d1
	blt.s	mse_c10
	cmp.w	#161,d1
	bgt.s	mse_c10
	move.b	#89,d1
	bra	rk_keys
mse_c10	cmp.w	#166,d1
	blt	mb_end
	cmp.w	#177,d1
	bgt	mb_end
	move.b	#90,d1
	bra	rk_keys
mse_n1	cmp.w	#330,d0
	blt	mse_n2
	cmp.w	#623,d0
	bgt	mse_n2
	cmp.w	#6,d1
	blt.s	mse_c12
	cmp.w	#17,d1
	bgt.s	mse_c12
	move.b	#91,d1
	bra	rk_keys
mse_c12	cmp.w	#22,d1
	blt.s	mse_c13
	cmp.w	#33,d1
	bgt.s	mse_c13
	move.b	#92,d1
	bra	rk_keys
mse_c13	cmp.w	#38,d1
	blt.s	mse_c14
	cmp.w	#49,d1
	bgt.s	mse_c14
	move.b	#93,d1
	bra	rk_keys
mse_c14	cmp.w	#54,d1
	blt.s	mse_c15
	cmp.w	#65,d1
	bgt.s	mse_c15
	move.b	#94,d1
	bra	rk_keys
mse_c15	cmp.w	#70,d1
	blt.s	mse_c16
	cmp.w	#81,d1
	bgt.s	mse_c16
	move.b	#95,d1
	bra	rk_keys
mse_c16	cmp.w	#86,d1
	blt.s	mse_c17
	cmp.w	#97,d1
	bgt.s	mse_c17
	move.b	#96,d1
	bra	rk_keys
mse_c17	cmp.w	#102,d1
	blt.s	mse_c18
	cmp.w	#113,d1
	bgt.s	mse_c18
	move.b	#97,d1
	bra	rk_keys
mse_c18	cmp.w	#118,d1
	blt.s	mse_c19
	cmp.w	#129,d1
	bgt.s	mse_c19
	move.b	#98,d1
	bra	rk_keys
mse_c19	cmp.w	#134,d1
	blt.s	mse_c20
	cmp.w	#145,d1
	bgt.s	mse_c20
	move.b	#99,d1
	bra	rk_keys
mse_c20	cmp.w	#150,d1
	blt.s	mse_c21
	cmp.w	#161,d1
	bgt.s	mse_c21
	move.b	#100,d1
	bra	rk_keys
mse_c21	cmp.w	#166,d1
	blt.s	mb_end
	cmp.w	#177,d1
	bgt.s	mb_end
	move.b	#101,d1
	bra	rk_keys
mse_n2
	nop
mb_end	bra	onekeys


clr_pointer
	bsr	clr_mse

freedfs	lea	filesizes(pc),a0
	move.l	(a0),d0
	move.l	dfsmem(pc),a1
	tst.l	a1
	beq.s	freedss
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

freedss	lea	filesizes(pc),a0
	move.l	4(a0),d0
	move.l	dssmem(pc),a1
	tst.l	a1
	beq.s	freeffs
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

freeffs	lea	filesizes(pc),a0
	move.l	8(a0),d0
	move.l	ffsmem(pc),a1
	tst.l	a1
	beq.s	freefss
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

freefss	lea	filesizes(pc),a0
	move.l	12(a0),d0
	move.l	fssmem(pc),a1
	tst.l	a1
	beq.s	freewdn
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

freewdn	lea	filesizes(pc),a0
	move.l	16(a0),d0
	move.l	wdnmem(pc),a1
	tst.l	a1
	beq.s	freewfn
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

freewfn	lea	filesizes(pc),a0
	move.l	20(a0),d0
	move.l	wfnmem(pc),a1
	tst.l	a1
	beq.s	freewdj
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

freewdj	lea	filesizes(pc),a0
	move.l	24(a0),d0
	move.l	wdjmem(pc),a1
	tst.l	a1
	beq.s	freewfj
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

freewfj	lea	filesizes(pc),a0
	move.l	28(a0),d0
	move.l	wfjmem(pc),a1
	tst.l	a1
	beq.s	freewdv
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

freewdv	lea	filesizes(pc),a0
	move.l	32(a0),d0
	move.l	wdvmem(pc),a1
	tst.l	a1
	beq.s	freewfv
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

freewfv	lea	filesizes(pc),a0
	move.l	36(a0),d0
	move.l	wfvmem(pc),a1
	tst.l	a1
	beq.s	free_sf
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

free_sf	bsr	freenyw
	bsr	freenya
	bsr	freesyw
	bsr	freesya

cl_wndw1
	move.l	wndw1ptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseWindow(a6)

cl_scrn1
	move.l	wndw1scrn(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseScreen(a6)

cl_wndw0
	move.l	wndw0ptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseWindow(a6)

cl_scrn0
	move.l	wndw0scrn(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseScreen(a6)

cl_font	move.l	stgfnt(pc),a1
	move.l	_GfxBase(pc),a6
	jsr	_LVOCloseFont(a6)

cl_tran	move.l  _TranslatorBase(pc),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_icon	move.l	_IconBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

cl_gfx	move.l	_GfxBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

cl_int	move.l	_IntuitionBase(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

cl_dos	move.l	_DOSBase(pc),a1
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
cleanup	tst.l	returnMsg
	beq.s	exit			; Exit - Task was started from CLI.
	move.l	4.w,a6
	jsr	_LVOForbid(a6)
	move.l	returnMsg(pc),a1	; Reply to the WB Startup Message and
	jsr	_LVOReplyMsg(a6)	; Exit - Task was started from WB.
exit	tst.b	clwb
	beq.s	fin
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWorkBench(a6)
fin	moveq	#0,d0
	rts


 * Sub-Routines.

stf0	move.l	scrn0ptr(pc),a0
	bsr.s	stf
	move.l	scrn0rp,a5
	move.l	wndw0ptr(pc),a0
	jsr	_LVOActivateWindow(a6)
	rts

stf1	move.l	scrn1ptr(pc),a0
	bsr.s	stf
	move.l	scrn1rp,a5
	move.l	wndw1ptr(pc),a0
	jsr	_LVOActivateWindow(a6)
	rts

stf	move.l	_IntuitionBase(pc),a6
	jsr	_LVOScreenToFront(a6)
	rts

about	suba.l	a0,a0
	lea	abouttags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,aboutwndw
	beq	about_e
	move.l	d0,a5
	move.l	wd_RPort(a5),a5
	move.l	a5,aboutrp
	move.l	_GfxBase(pc),a6
	bsr	pen_a0
	move.l	a5,a1
	clr.w	d0
	clr.w	d1
	move.w	#201,d2
	move.w	#127,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a2
	move.l	a5,a1
	move.w	#2,d0
	move.w	#1,d1
	move.w	#199,d2
	move.w	#126,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a5
	move.l	a5,a1
	move.w	#2,d0
	move.w	#1,d1
	move.w	#3,d2
	move.w	#126,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#4,d0
	move.w	#126,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#198,d0
	move.w	#126,d1
	jsr	_LVODraw(a6)
	bsr	pen_a1
	move.l	a5,a1
	move.w	#3,d0
	move.w	#1,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#199,d0
	move.w	#1,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#198,d0
	move.w	#2,d1
	move.w	#199,d2
	move.w	#125,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#199,d0
	move.w	#126,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#12,d0
	move.w	#104,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#190,d0
	move.w	#104,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#10,d0
	move.w	#5,d1
	move.w	#11,d2
	move.w	#104,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a5
	move.l	a5,a1
	move.w	#11,d0
	move.w	#5,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#191,d0
	move.w	#5,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#190,d0
	move.w	#6,d1
	move.w	#191,d2
	move.w	#103,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#191,d0
	move.w	#104,d1
	jsr	_LVOWritePixel(a6)
	bsr	pen_a14
	move.l	a5,a1
	move.w	#76,d0
	move.w	#110,d1
	move.w	#125,d2
	move.w	#120,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a15
	move.l	a5,a1
	move.w	#74,d0
	move.w	#109,d1
	move.w	#75,d2
	move.w	#121,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#76,d0
	move.w	#121,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#126,d0
	move.w	#121,d1
	jsr	_LVODraw(a6)
	bsr	pen_a13
	move.l	a5,a1
	move.w	#126,d0
	move.w	#110,d1
	move.w	#127,d2
	move.w	#120,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#127,d0
	move.w	#121,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#75,d0
	move.w	#109,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#127,d0
	move.w	#109,d1
	jsr	_LVODraw(a6)
	bsr	pen_a6
	bsr	pen_b14
	move.w	#81,d0
        move.w	#118,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt25(pc),a0
	bsr	text_4
	bsr	pen_a4
	move.w	#91,d0
        move.w	#118,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt15(pc),a0
	bsr	text_1
	bsr	pen_b2
	move.w	#16,d0
        move.w	#16,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt19(pc),a0
	bsr	text_17
	move.w	#20,d0
        move.w	#98,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt26(pc),a0
	bsr	text_16
	bsr	pen_a6
	move.w	#27,d0
        move.w	#31,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt27(pc),a0
	bsr	text_10
	move.w	#27,d0
        move.w	#42,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt28(pc),a0
	bsr	text_15
	move.w	#27,d0
        move.w	#52,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt29(pc),a0
	bsr	text_12
	move.w	#27,d0
        move.w	#62,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt30(pc),a0
	bsr	text_10
	move.w	#27,d0
        move.w	#72,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt31(pc),a0
	bsr	text_14
	move.w	#27,d0
        move.w	#83,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt32(pc),a0
	bsr	text_7
aboutk	move.l	aboutwndw(pc),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
	move.l	aboutwndw(pc),a0
	bsr	get_msg

        cmp.l   #IDCMP_VANILLAKEY,d0
        beq.s	aboutvk

	cmp.l	#IDCMP_MOUSEBUTTONS,d0
	beq.s	aboutmb

        cmp.l   #IDCMP_INACTIVEWINDOW,d0
        beq.s	clabout

	bra.s	aboutk

clabout	move.l	aboutwndw(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseWindow(a6)
about_e	move.l	scrn0rp(pc),a5
	bra	zerkeys

aboutvk	move.w	icode,d0
	cmp.b	#$58,d0
	beq.s	clabout
	cmp.b	#$78,d0
	beq.s	clabout
	bra.s	aboutk

aboutmb	move.w	msex,d0
	move.w	msey,d1
	cmp.w	#SELECTDOWN,icode
	bne.s	amb_end
	cmp.w	#109,d1
	blt.s	amb_end
	cmp.w	#121,d1
	bgt.s	amb_end
	cmp.w	#74,d0
	blt.s	amb_end
	cmp.w	#127,d0
	bgt.s	amb_end
	bra.s	clabout
amb_end	bra	aboutk

search	suba.l	a0,a0
	lea	searchtags(pc),a1
	move.l	#36,4(a1)
	cmp.b	#9,428(a4)
	ble.s	osw
	cmp.b	#10,428(a4)
	beq.s	ssw
	cmp.b	#20,428(a4)
	ble.s	osw
ssw	move.l	#19,4(a1)
osw	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,searchwndw
	beq	srch_e
	move.l	d0,a5
	move.l	wd_RPort(a5),a5
	move.l	a5,searchrp
	move.l	_GfxBase(pc),a6
	bsr	pen_a0
	move.l	a5,a1
	clr.w	d0
	clr.w	d1
	move.w	#632,d2
	move.w	#128,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a14
	move.l	a5,a1
	move.w	#2,d0
	move.w	#1,d1
	move.w	#630,d2
	move.w	#127,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a13
	move.l	a5,a1
	move.w	#4,d0
	move.w	#1,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#630,d0
	move.w	#1,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#629,d0
	move.w	#2,d1
	move.w	#630,d2
	move.w	#126,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a15
	move.l	a5,a1
	move.w	#2,d0
	move.w	#2,d1
	move.w	#3,d2
	move.w	#127,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#4,d0
	move.w	#127,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#628,d0
	move.w	#127,d1
	jsr	_LVODraw(a6)
	bsr	pen_a8
	move.l	a5,a1
	move.w	#16,d0
	move.w	#8,d1
	move.w	#102,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#119,d0
	move.w	#8,d1
	move.w	#207,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#225,d0
	move.w	#8,d1
	move.w	#322,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#340,d0
	move.w	#8,d1
	move.w	#416,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#444,d0
	move.w	#8,d1
	move.w	#521,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#539,d0
	move.w	#8,d1
	move.w	#616,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a9
	move.l	a5,a1
	move.w	#14,d0
	move.w	#7,d1
	move.w	#15,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#16,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#103,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#118,d0
	move.w	#7,d1
	move.w	#119,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#120,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#208,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#223,d0
	move.w	#7,d1
	move.w	#224,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#225,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#323,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#338,d0
	move.w	#7,d1
	move.w	#339,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#340,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#417,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#442,d0
	move.w	#7,d1
	move.w	#443,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#444,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#522,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#537,d0
	move.w	#7,d1
	move.w	#538,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#539,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#617,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	bsr	pen_a7
	move.l	a5,a1
	move.w	#103,d0
	move.w	#8,d1
	move.w	#104,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#104,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#15,d0
	move.w	#7,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#104,d0
	move.w	#7,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#208,d0
	move.w	#8,d1
	move.w	#209,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#209,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#120,d0
	move.w	#7,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#209,d0
	move.w	#7,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#323,d0
	move.w	#8,d1
	move.w	#324,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#324,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#224,d0
	move.w	#7,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#324,d0
	move.w	#7,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#417,d0
	move.w	#8,d1
	move.w	#418,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#418,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#339,d0
	move.w	#7,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#418,d0
	move.w	#7,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#522,d0
	move.w	#8,d1
	move.w	#523,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#523,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#443,d0
	move.w	#7,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#523,d0
	move.w	#7,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#617,d0
	move.w	#8,d1
	move.w	#618,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#618,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#538,d0
	move.w	#7,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#618,d0
	move.w	#7,d1
	jsr	_LVODraw(a6)

	bsr	pen_a5
	move.l	a5,a1
	move.w	#18,d0
	move.w	#49,d1
	move.w	#104,d2
	move.w	#59,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a12
	move.l	a5,a1
	move.w	#16,d0
	move.w	#48,d1
	move.w	#17,d2
	move.w	#60,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#18,d0
	move.w	#60,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#105,d0
	move.w	#60,d1
	jsr	_LVODraw(a6)
	bsr	pen_a2
	move.l	a5,a1
	move.w	#105,d0
	move.w	#49,d1
	move.w	#106,d2
	move.w	#59,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#106,d0
	move.w	#60,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#17,d0
	move.w	#48,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#106,d0
	move.w	#48,d1
	jsr	_LVODraw(a6)

	bsr	pen_a10
	move.l	a5,a1
	move.w	#287,d0
	move.w	#49,d1
	move.w	#333,d2
	move.w	#59,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a3
	move.l	a5,a1
	move.w	#285,d0
	move.w	#48,d1
	move.w	#286,d2
	move.w	#60,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#287,d0
	move.w	#60,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#334,d0
	move.w	#60,d1
	jsr	_LVODraw(a6)
	bsr	pen_a11
	move.l	a5,a1
	move.w	#334,d0
	move.w	#49,d1
	move.w	#335,d2
	move.w	#59,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#335,d0
	move.w	#60,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#286,d0
	move.w	#48,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#335,d0
	move.w	#48,d1
	jsr	_LVODraw(a6)

	bsr	pen_a2
	move.l	a5,a1
	move.w	#175,d0
	move.w	#28,d1
	move.w	#614,d2
	move.w	#39,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a1
	move.l	a5,a1
	move.w	#173,d0
	move.w	#27,d1
	move.w	#174,d2
	move.w	#40,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#175,d0
	move.w	#40,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#615,d0
	move.w	#40,d1
	jsr	_LVODraw(a6)
	bsr	pen_a5
	move.l	a5,a1
	move.w	#615,d0
	move.w	#28,d1
	move.w	#616,d2
	move.w	#39,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#616,d0
	move.w	#40,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#174,d0
	move.w	#27,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#616,d0
	move.w	#27,d1
	jsr	_LVODraw(a6)

	bsr	pen_a2
	move.l	a5,a1
	move.w	#354,d0
	move.w	#49,d1
	move.w	#614,d2
	move.w	#60,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#18,d0
	move.w	#71,d1
	move.w	#614,d2
	move.w	#117,d3
	jsr	_LVORectFill(a6)

	bsr	pen_a5
	move.l	a5,a1
	move.w	#352,d0
	move.w	#48,d1
	move.w	#353,d2
	move.w	#61,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#354,d0
	move.w	#61,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#615,d0
	move.w	#61,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#16,d0
	move.w	#70,d1
	move.w	#17,d2
	move.w	#118,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#18,d0
	move.w	#118,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#615,d0
	move.w	#118,d1
	jsr	_LVODraw(a6)

	bsr	pen_a1
	move.l	a5,a1
	move.w	#615,d0
	move.w	#49,d1
	move.w	#616,d2
	move.w	#60,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#616,d0
	move.w	#61,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#353,d0
	move.w	#48,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#616,d0
	move.w	#48,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#615,d0
	move.w	#71,d1
	move.w	#616,d2
	move.w	#117,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#616,d0
	move.w	#118,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#17,d0
	move.w	#70,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#616,d0
	move.w	#70,d1
	jsr	_LVODraw(a6)


	bsr	pen_a9
	bsr	pen_b8
	move.w	#30,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt11(pc),a0
	bsr	text_7
	move.w	#134,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt12(pc),a0
	bsr	text_7
	move.w	#239,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt13(pc),a0
	bsr	text_8
	move.w	#344,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt14(pc),a0
	bsr	text_7
	move.w	#458,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt15(pc),a0
	bsr	text_6
	move.w	#553,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt16(pc),a0
	bsr	text_6

	bsr	pen_a12
	bsr	pen_b5
	move.w	#32,d0
        move.w	#57,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt17(pc),a0
	bsr	text_7

	bsr	pen_a6
	bsr	pen_b14
	move.w	#22,d0
        move.w	#36,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt18(pc),a0
	bsr	text_13

	bsr	pen_a3
	bsr	pen_b10
	move.w	#291,d0
        move.w	#57,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt25(pc),a0
	bsr	text_4

	bsr	pen_a4
	move.w	#301,d0
        move.w	#57,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt15(pc),a0
	bsr	text_1

	bsr	pen_b8
	move.w	#20,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt2(pc),a0
	bsr	text_1
	move.w	#124,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt5(pc),a0
	bsr	text_1
	move.w	#229,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt1(pc),a0
	bsr	text_1
	move.w	#374,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt6(pc),a0
	bsr	text_1
	move.w	#448,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt0(pc),a0
	bsr	text_1
	move.w	#543,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt8(pc),a0
	bsr	text_1

	bsr	pen_b5
	move.w	#22,d0
        move.w	#57,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt7(pc),a0
	bsr	text_1

	bsr	pen_b14
	move.w	#102,d0
        move.w	#36,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt9(pc),a0
	bsr	text_1

	bsr	pen_a4
	bsr	pen_b2
	move.w	#24,d0
        move.w	#80,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt55(pc),a0
	bsr	text_7
	bsr	pen_a6
	move.w	#24,d0
        move.w	#102,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt56(pc),a0
	bsr	text_7

	move.l	_IntuitionBase(pc),a6
	lea	gd6(pc),a1
	bsr	asg
	lea	gd6(pc),a0
	bsr	rsg
	bsr	update_search
	move.b	#1,455(a4)
srchkey	move.l	searchwndw(pc),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
	move.l	searchwndw(pc),a0
	bsr	get_msg

        cmp.l   #IDCMP_GADGETUP,d0
        beq.s	srch_gu

        cmp.l   #IDCMP_GADGETDOWN,d0
        beq.s	srch_gd

        cmp.l   #IDCMP_VANILLAKEY,d0
        beq	srch_vk

	cmp.l	#IDCMP_RAWKEY,d0
	beq	srch_rk

	cmp.l	#IDCMP_MOUSEBUTTONS,d0
	beq	srch_mb

	cmp.l	#IDCMP_INACTIVEWINDOW,d0
	beq.s	cl_srch

	bra.s	srchkey

cl_srch	move.l	searchwndw(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseWindow(a6)
srch_e	move.l	scrn1rp(pc),a5
	rts

srch_gu	move.l  iadr(pc),a0
        move.w  gg_GadgetID(a0),d0
	cmp.w	#6,d0
	beq.s	do_sstg
	bra.s	srchkey

srch_gd

	bra.s	srchkey

do_sstg	move.l	_GfxBase(pc),a6
	bsr	pen_a2
	move.l	a5,a1
	move.w	#160,d0
	move.w	#71,d1
	move.w	#608,d2
	move.w	#117,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a6
	bsr	pen_b2
	move.w	#360,d0
        move.w	#57,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt58(pc),a0
	bsr	text_25
	clr.b	455(a4)
	moveq	#0,d5
	moveq	#0,d7
	move.b	428(a4),d5
	tst.b	453(a4)
	beq.s	sfsw_s
	lea	wb0(pc),a0
	bra.s	sfsw_c0
sfsw_s	lea	sb0(pc),a0
sfsw_c0	move.w	2(a0,d5.w*4),d7
	move.w	0(a0,d5.w*4),d5
	mulu	#42,d5
	mulu	#42,d7
	lea	searchb,a0
	bsr	findlen
	tst.l	d0
	ble.s	sfsw_e
	move.l	d0,d4
	tst.b	453(a4)
	beq.s	sfsw_c1
	bsr	search_words
	bra.s	sfsw_e
sfsw_c1	bsr	search_sents
sfsw_e	bra	srchkey

srch_vk	move.w	icode,d1
	cmp.b	#$53,d1
	beq	do_senb
	cmp.b	#$73,d1
	beq	do_senb
	cmp.b	#$50,d1
	beq	do_prob
	cmp.b	#$70,d1
	beq.s	do_prob
	cmp.b	#$41,d1
	beq.s	do_adjb
	cmp.b	#$61,d1
	beq.s	do_adjb
	cmp.b	#$56,d1
	beq.s	do_advb
	cmp.b	#$76,d1
	beq.s	do_advb
	cmp.b	#$44,d1
	beq.s	do_defb
	cmp.b	#$64,d1
	beq.s	do_defb
	cmp.b	#$46,d1
	beq.s	do_forb
	cmp.b	#$66,d1
	beq.s	do_forb
	cmp.b	#$54,d1
	beq.s	do_acts
	cmp.b	#$74,d1
	beq.s	do_acts
	cmp.b	#$43,d1
	beq.s	do_cont
	cmp.b	#$63,d1
	beq.s	do_cont
	cmp.b	#$58,d1
	beq	cl_srch
	cmp.b	#$78,d1
	beq	cl_srch
	bra	srchkey

do_forb	move.b	#1,452(a4)
	bra.s	do_dfb
do_defb	clr.b	452(a4)
do_dfb	bsr	chk_dfb
	move.b	#2,455(a4)
	bra	srchkey

do_senb	clr.b	453(a4)
	bra.s	do_spav
do_prob	move.b	#1,453(a4)
	bra.s	do_spav
do_adjb	move.b	#2,453(a4)
	bra.s	do_spav
do_advb	move.b	#3,453(a4)
do_spav	bsr	chkspav
	move.b	#2,455(a4)
	bra	srchkey

do_acts	lea	gd6(pc),a0
	bsr	actsg
acts_e	bra	srchkey

do_cont	tst.b	455(a4)
	bne.s	cont_e
	move.l	474(a4),a1
	cmp.l	a3,a1
	bge.s	cont_e
	bsr.s	find_ag
	tst.b	d1
	bne.s	cont_e
	bsr	unfound
cont_e	bra	srchkey

find_ag	lea	searchb,a0
	move.l	474(a4),a1
	bsr	instg_f
	tst.b	d1
	beq.s	fia_end
	lea	searchb,a1
	bsr	instg_c
	cmp.w	d4,d2
	blt.s	find_ag
	tst.b	453(a4)
	beq.s	fia_0
	cmp.b	#1,453(a4)
	beq.s	fia_1
	cmp.b	#2,453(a4)
	beq.s	fia_2
	bra.s	fia_3
fia_0	bsr	show_st
	bra.s	fia_p
fia_1	bsr	show_1
	bra.s	fia_p
fia_2	bsr	show_2
	bra.s	fia_p
fia_3	bsr	show_3
fia_p	moveq	#1,d1
fia_end	rts

srch_rk
	nop
	bra	srchkey

srch_mb	move.w	msex,d0
	move.w	msey,d1
	cmp.w	#SELECTDOWN,icode
	bne	smb_end
	cmp.w	#7,d1
	blt.s	mse_sn1
	cmp.w	#18,d1
	bgt.s	mse_sn1
	cmp.w	#14,d0
	blt.s	mse_sc1
	cmp.w	#104,d0
	bgt.s	mse_sc1
	bra	do_senb
mse_sc1	cmp.w	#118,d0
	blt.s	mse_sc2
	cmp.w	#209,d0
	bgt.s	mse_sc2
	bra	do_prob
mse_sc2	cmp.w	#223,d0
	blt.s	mse_sc3
	cmp.w	#324,d0
	bgt.s	mse_sc3
	bra	do_adjb
mse_sc3	cmp.w	#338,d0
	blt.s	mse_sc4
	cmp.w	#418,d0
	bgt.s	mse_sc4
	bra	do_advb
mse_sc4	cmp.w	#442,d0
	blt.s	mse_sc5
	cmp.w	#523,d0
	bgt.s	mse_sc5
	bra	do_defb
mse_sc5	cmp.w	#537,d0
	blt.s	smb_end
	cmp.w	#618,d0
	bgt.s	smb_end
	bra	do_forb
mse_sn1	cmp.w	#48,d1
	blt.s	mse_sn2
	cmp.w	#60,d1
	bgt.s	mse_sn2
	cmp.w	#16,d0
	blt.s	mse_sc6
	cmp.w	#106,d0
	bgt.s	mse_sc6
	bra	do_cont
mse_sc6	cmp.w	#285,d0
	blt.s	smb_end
	cmp.w	#335,d0
	bgt.s	smb_end
	bra	cl_srch
mse_sn2
	nop

smb_end	bra	srchkey

prefs	suba.l	a0,a0
	lea	prefstags(pc),a1
	move.l	#101,4(a1)
	cmp.b	#4,428(a4)
	ble.s	opw
	cmp.b	#10,428(a4)
	ble.s	spw
	cmp.b	#15,428(a4)
	ble.s	opw
spw	move.l	#5,4(a1)
opw	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,prefswndw
	beq	prefs_e

	move.l	prefswndw(pc),a5
	move.l	wd_RPort(a5),a5
	move.l	a5,prefsrp

	move.l	_GfxBase(pc),a6
	bsr	pen_a0
	move.l	a5,a1
	clr.w	d0
	clr.w	d1
	move.w	#609,d2
	move.w	#78,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a14
	move.l	a5,a1
	move.w	#2,d0
	move.w	#1,d1
	move.w	#607,d2
	move.w	#77,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a13
	move.l	a5,a1
	move.w	#4,d0
	move.w	#1,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#607,d0
	move.w	#1,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#606,d0
	move.w	#2,d1
	move.w	#607,d2
	move.w	#76,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a15
	move.l	a5,a1
	move.w	#2,d0
	move.w	#77,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#605,d0
	move.w	#77,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#2,d0
	move.w	#2,d1
	move.w	#3,d2
	move.w	#76,d3
	jsr	_LVORectFill(a6)


	bsr	pen_a12
	move.l	a5,a1
	move.w	#14,d0
	move.w	#6,d1
	move.w	#15,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#16,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#113,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#192,d0
	move.w	#6,d1
	move.w	#193,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#194,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#241,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#320,d0
	move.w	#6,d1
	move.w	#321,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#322,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#409,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#488,d0
	move.w	#6,d1
	move.w	#489,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#490,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#537,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#14,d0
	move.w	#24,d1
	move.w	#15,d2
	move.w	#36,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#16,d0
	move.w	#36,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#83,d0
	move.w	#36,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#162,d0
	move.w	#24,d1
	move.w	#163,d2
	move.w	#36,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#164,d0
	move.w	#36,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#221,d0
	move.w	#36,d1
	jsr	_LVODraw(a6)

	bsr	pen_a2
	move.l	a5,a1
	move.w	#113,d0
	move.w	#7,d1
	move.w	#114,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#114,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#15,d0
	move.w	#6,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#114,d0
	move.w	#6,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#241,d0
	move.w	#7,d1
	move.w	#242,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#242,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#193,d0
	move.w	#6,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#242,d0
	move.w	#6,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#409,d0
	move.w	#7,d1
	move.w	#410,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#410,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#321,d0
	move.w	#6,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#410,d0
	move.w	#6,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#537,d0
	move.w	#7,d1
	move.w	#538,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#538,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#489,d0
	move.w	#6,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#538,d0
	move.w	#6,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#83,d0
	move.w	#25,d1
	move.w	#84,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#84,d0
	move.w	#36,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#15,d0
	move.w	#24,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#84,d0
	move.w	#24,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#221,d0
	move.w	#25,d1
	move.w	#222,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#222,d0
	move.w	#36,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#163,d0
	move.w	#24,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#222,d0
	move.w	#24,d1
	jsr	_LVODraw(a6)

	bsr	pen_a5
	move.l	a5,a1
	move.w	#16,d0
	move.w	#7,d1
	move.w	#112,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#194,d0
	move.w	#7,d1
	move.w	#240,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#322,d0
	move.w	#7,d1
	move.w	#408,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#490,d0
	move.w	#7,d1
	move.w	#536,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#16,d0
	move.w	#25,d1
	move.w	#82,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#164,d0
	move.w	#25,d1
	move.w	#220,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)


	bsr	pen_a1
	move.l	a5,a1
	move.w	#121,d0
	move.w	#6,d1
	move.w	#122,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#123,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#170,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#249,d0
	move.w	#6,d1
	move.w	#250,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#251,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#298,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#417,d0
	move.w	#6,d1
	move.w	#418,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#419,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#466,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#545,d0
	move.w	#6,d1
	move.w	#546,d2
	move.w	#18,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#547,d0
	move.w	#18,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#594,d0
	move.w	#18,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#91,d0
	move.w	#24,d1
	move.w	#92,d2
	move.w	#36,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#93,d0
	move.w	#36,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#140,d0
	move.w	#36,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#229,d0
	move.w	#24,d1
	move.w	#230,d2
	move.w	#36,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#231,d0
	move.w	#36,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#278,d0
	move.w	#36,d1
	jsr	_LVODraw(a6)

	bsr	pen_a5
	move.l	a5,a1
	move.w	#170,d0
	move.w	#7,d1
	move.w	#171,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#171,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#122,d0
	move.w	#6,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#171,d0
	move.w	#6,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#298,d0
	move.w	#7,d1
	move.w	#299,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#299,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#250,d0
	move.w	#6,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#299,d0
	move.w	#6,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#466,d0
	move.w	#7,d1
	move.w	#467,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#467,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#418,d0
	move.w	#6,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#467,d0
	move.w	#6,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#594,d0
	move.w	#7,d1
	move.w	#595,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#595,d0
	move.w	#18,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#546,d0
	move.w	#6,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#595,d0
	move.w	#6,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#140,d0
	move.w	#25,d1
	move.w	#141,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#141,d0
	move.w	#36,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#92,d0
	move.w	#24,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#141,d0
	move.w	#24,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#278,d0
	move.w	#25,d1
	move.w	#279,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#279,d0
	move.w	#36,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#230,d0
	move.w	#24,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#279,d0
	move.w	#24,d1
	jsr	_LVODraw(a6)

	bsr	pen_a2
	move.l	a5,a1
	move.w	#123,d0
	move.w	#7,d1
	move.w	#169,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#251,d0
	move.w	#7,d1
	move.w	#297,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#419,d0
	move.w	#7,d1
	move.w	#465,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#547,d0
	move.w	#7,d1
	move.w	#593,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#93,d0
	move.w	#25,d1
	move.w	#139,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#231,d0
	move.w	#25,d1
	move.w	#277,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)

	bsr	pen_a9
	move.l	a5,a1
	move.w	#300,d0
	move.w	#24,d1
	move.w	#301,d2
	move.w	#36,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#302,d0
	move.w	#36,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#359,d0
	move.w	#36,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#14,d0
	move.w	#42,d1
	move.w	#15,d2
	move.w	#54,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#16,d0
	move.w	#54,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#124,d0
	move.w	#54,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#193,d0
	move.w	#42,d1
	move.w	#194,d2
	move.w	#54,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#195,d0
	move.w	#54,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#252,d0
	move.w	#54,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#321,d0
	move.w	#42,d1
	move.w	#322,d2
	move.w	#54,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#323,d0
	move.w	#54,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#390,d0
	move.w	#54,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#459,d0
	move.w	#42,d1
	move.w	#460,d2
	move.w	#54,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#461,d0
	move.w	#54,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#529,d0
	move.w	#54,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#14,d0
	move.w	#60,d1
	move.w	#15,d2
	move.w	#72,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#16,d0
	move.w	#72,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#194,d0
	move.w	#72,d1
	jsr	_LVODraw(a6)

	bsr	pen_a7
	move.l	a5,a1
	move.w	#359,d0
	move.w	#25,d1
	move.w	#360,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#360,d0
	move.w	#36,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#301,d0
	move.w	#24,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#360,d0
	move.w	#24,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#124,d0
	move.w	#43,d1
	move.w	#125,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#125,d0
	move.w	#54,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#15,d0
	move.w	#42,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#125,d0
	move.w	#42,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#252,d0
	move.w	#43,d1
	move.w	#253,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#253,d0
	move.w	#54,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#194,d0
	move.w	#42,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#253,d0
	move.w	#42,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#390,d0
	move.w	#43,d1
	move.w	#391,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#391,d0
	move.w	#54,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#322,d0
	move.w	#42,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#391,d0
	move.w	#42,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#529,d0
	move.w	#43,d1
	move.w	#530,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#530,d0
	move.w	#54,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#460,d0
	move.w	#42,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#530,d0
	move.w	#42,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#194,d0
	move.w	#61,d1
	move.w	#195,d2
	move.w	#71,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#195,d0
	move.w	#72,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#15,d0
	move.w	#60,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#195,d0
	move.w	#60,d1
	jsr	_LVODraw(a6)

	bsr	pen_a8
	move.l	a5,a1
	move.w	#302,d0
	move.w	#25,d1
	move.w	#358,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#16,d0
	move.w	#43,d1
	move.w	#123,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#195,d0
	move.w	#43,d1
	move.w	#251,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#323,d0
	move.w	#43,d1
	move.w	#389,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#461,d0
	move.w	#43,d1
	move.w	#528,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#16,d0
	move.w	#61,d1
	move.w	#193,d2
	move.w	#71,d3
	jsr	_LVORectFill(a6)

	bsr	pen_a5
	move.l	a5,a1
	move.w	#367,d0
	move.w	#24,d1
	move.w	#368,d2
	move.w	#36,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#369,d0
	move.w	#36,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#467,d0
	move.w	#36,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#132,d0
	move.w	#42,d1
	move.w	#133,d2
	move.w	#54,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#134,d0
	move.w	#54,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#171,d0
	move.w	#54,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#260,d0
	move.w	#42,d1
	move.w	#261,d2
	move.w	#54,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#262,d0
	move.w	#54,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#299,d0
	move.w	#54,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#398,d0
	move.w	#42,d1
	move.w	#399,d2
	move.w	#54,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#400,d0
	move.w	#54,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#437,d0
	move.w	#54,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#537,d0
	move.w	#42,d1
	move.w	#538,d2
	move.w	#54,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#539,d0
	move.w	#54,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#576,d0
	move.w	#54,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#202,d0
	move.w	#60,d1
	move.w	#203,d2
	move.w	#72,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#204,d0
	move.w	#72,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#241,d0
	move.w	#72,d1
	jsr	_LVODraw(a6)

	bsr	pen_a1
	move.l	a5,a1
	move.w	#467,d0
	move.w	#25,d1
	move.w	#468,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#468,d0
	move.w	#36,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#368,d0
	move.w	#24,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#468,d0
	move.w	#24,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#171,d0
	move.w	#43,d1
	move.w	#172,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#172,d0
	move.w	#54,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#133,d0
	move.w	#42,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#172,d0
	move.w	#42,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#299,d0
	move.w	#43,d1
	move.w	#300,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#300,d0
	move.w	#54,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#261,d0
	move.w	#42,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#300,d0
	move.w	#42,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#437,d0
	move.w	#43,d1
	move.w	#438,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#438,d0
	move.w	#54,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#399,d0
	move.w	#42,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#438,d0
	move.w	#42,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#576,d0
	move.w	#43,d1
	move.w	#577,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#577,d0
	move.w	#54,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#538,d0
	move.w	#42,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#577,d0
	move.w	#42,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#241,d0
	move.w	#61,d1
	move.w	#242,d2
	move.w	#71,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#242,d0
	move.w	#72,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#203,d0
	move.w	#60,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#242,d0
	move.w	#60,d1
	jsr	_LVODraw(a6)

	bsr	pen_a2
	move.l	a5,a1
	move.w	#369,d0
	move.w	#25,d1
	move.w	#466,d2
	move.w	#35,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#134,d0
	move.w	#43,d1
	move.w	#170,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#262,d0
	move.w	#43,d1
	move.w	#298,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#400,d0
	move.w	#43,d1
	move.w	#436,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#539,d0
	move.w	#43,d1
	move.w	#575,d2
	move.w	#53,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#204,d0
	move.w	#61,d1
	move.w	#240,d2
	move.w	#71,d3
	jsr	_LVORectFill(a6)

	bsr	pen_a3
	move.l	a5,a1
	move.w	#410,d0
	move.w	#60,d1
	move.w	#411,d2
	move.w	#72,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#412,d0
	move.w	#72,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#531,d0
	move.w	#72,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#545,d0
	move.w	#60,d1
	move.w	#546,d2
	move.w	#72,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#547,d0
	move.w	#72,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#594,d0
	move.w	#72,d1
	jsr	_LVODraw(a6)

	bsr	pen_a11
	move.l	a5,a1
	move.w	#531,d0
	move.w	#61,d1
	move.w	#532,d2
	move.w	#71,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#532,d0
	move.w	#72,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#411,d0
	move.w	#60,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#532,d0
	move.w	#60,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#594,d0
	move.w	#61,d1
	move.w	#595,d2
	move.w	#71,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#595,d0
	move.w	#72,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#546,d0
	move.w	#60,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#595,d0
	move.w	#60,d1
	jsr	_LVODraw(a6)

	bsr	pen_a10
	move.l	a5,a1
	move.w	#412,d0
	move.w	#61,d1
	move.w	#530,d2
	move.w	#71,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#547,d0
	move.w	#61,d1
	move.w	#593,d2
	move.w	#71,d3
	jsr	_LVORectFill(a6)


	bsr	pen_a12
	bsr	pen_b5
	move.w	#30,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt0(pc),a0
	bsr	text_8
	move.w	#208,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt1(pc),a0
	bsr	text_3
	move.w	#336,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt2(pc),a0
	bsr	text_4
	move.w	#375,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt6(pc),a0
	bsr	text_1
	move.w	#385,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt7(pc),a0
	bsr	text_1
	move.w	#396,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt8(pc),a0
	bsr	text_1
	move.w	#504,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt3(pc),a0
	bsr	text_3
	move.w	#30,d0
        move.w	#33,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt4(pc),a0
	bsr	text_5
	move.w	#178,d0
        move.w	#33,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt5(pc),a0
	bsr	text_4


	bsr	pen_a4
	move.w	#20,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt0(pc),a0
	bsr	text_1
	move.w	#198,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt1(pc),a0
	bsr	text_1
	move.w	#326,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt2(pc),a0
	bsr	text_1
	move.w	#494,d0
        move.w	#15,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt3(pc),a0
	bsr	text_1
	move.w	#20,d0
        move.w	#33,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt4(pc),a0
	bsr	text_1
	move.w	#168,d0
        move.w	#33,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt5(pc),a0
	bsr	text_1

	bsr	pen_a9
	bsr	pen_b8
	move.w	#317,d0
        move.w	#33,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt10(pc),a0
	bsr	text_1
	move.w	#326,d0
        move.w	#33,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt53(pc),a0
	bsr	text_3
	move.w	#21,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt20(pc),a0
	bsr	text_10
	move.w	#199,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt21(pc),a0
	bsr	text_5
	move.w	#327,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt22(pc),a0
	bsr	text_6
	move.w	#465,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt23(pc),a0
	bsr	text_6
	move.w	#30,d0
        move.w	#69,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt24(pc),a0
	bsr	text_16
	bsr	pen_a3
	bsr	pen_b10
	move.w	#417,d0
        move.w	#69,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt44(pc),a0
	bsr	text_11
	move.w	#551,d0
        move.w	#69,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt25(pc),a0
	bsr	text_4

	bsr	pen_a4
	bsr	pen_b8
	move.w	#306,d0
        move.w	#33,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt6(pc),a0
	bsr	text_1
	move.w	#31,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt10(pc),a0
	bsr	text_1
	move.w	#229,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt11(pc),a0
	bsr	text_1
	move.w	#357,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt12(pc),a0
	bsr	text_1
	move.w	#485,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt13(pc),a0
	bsr	text_1
	move.w	#20,d0
        move.w	#69,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt14(pc),a0
	bsr	text_1

	bsr	pen_b10
	move.w	#467,d0
        move.w	#69,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt7(pc),a0
	bsr	text_1
	move.w	#561,d0
        move.w	#69,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt15(pc),a0
	bsr	text_1

	bsr	show_v

	move.w	#138,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt9(pc),a0
	bsr	text_3
	move.w	#266,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt9(pc),a0
	bsr	text_3

	move.w	#404,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt9(pc),a0
	bsr	text_3

	move.w	#543,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt9(pc),a0
	bsr	text_3

	move.w	#208,d0
        move.w	#69,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt9(pc),a0
	bsr	text_3

	move.l	_IntuitionBase(pc),a6
	lea	prefslist(pc),a2
	clr.b	d3
gad_l	move.l	(a2)+,a1
	bsr	apg
	addq.b	#1,d3
	cmp.b	#6,d3
	blt.s	gad_l
	lea	gd0(pc),a0
	bsr	rpg
	bsr	update_prefs

prefkey	move.l	prefswndw(pc),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
	move.l	prefswndw(pc),a0
	bsr	get_msg

        cmp.l   #IDCMP_GADGETUP,d0
        beq.s	pref_gu

        cmp.l   #IDCMP_GADGETDOWN,d0
        beq.s	pref_gd

        cmp.l   #IDCMP_VANILLAKEY,d0
        beq.s	pref_vk

	cmp.l	#IDCMP_RAWKEY,d0
	beq	pref_rk

	cmp.l	#IDCMP_MOUSEBUTTONS,d0
	beq	pref_mb

	cmp.l	#IDCMP_INACTIVEWINDOW,d0
	beq.s	cl_pref

	bra.s	prefkey

cl_pref	move.l	prefswndw(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseWindow(a6)
prefs_e	move.l	scrn1rp(pc),a5
	rts

pref_gu	move.l  iadr(pc),a0
        move.w  gg_GadgetID(a0),d0
	tst.w	d0
	beq	d_dfl
	cmp.w	#1,d0
	beq	d_auto
	cmp.w	#2,d0
	beq	d_spell
	cmp.w	#3,d0
	beq	d_word
	cmp.w	#4,d0
	beq	d_rveal
	cmp.w	#5,d0
	beq	d_pause

	bra	prefkey

pref_gd

	bra	prefkey

pref_vk	move.w	icode,d1
	cmp.b	#$44,d1
	beq	k_dfl
	cmp.b	#$64,d1
	beq	k_dfl
	cmp.b	#$41,d1
	beq	k_auto
	cmp.b	#$61,d1
	beq	k_auto
	cmp.b	#$53,d1
	beq	k_spell
	cmp.b	#$73,d1
	beq	k_spell
	cmp.b	#$57,d1
	beq	k_word
	cmp.b	#$77,d1
	beq	k_word
	cmp.b	#$52,d1
	beq	k_rveal
	cmp.b	#$72,d1
	beq	k_rveal
	cmp.b	#$50,d1
	beq	k_pause
	cmp.b	#$70,d1
	beq	k_pause
	cmp.b	#$4F,d1
	beq	dosplit
	cmp.b	#$6F,d1
	beq	dosplit
	cmp.b	#$56,d1
	beq	dovoice
	cmp.b	#$76,d1
	beq	dovoice
	cmp.b	#$4C,d1
	beq	do_spel
	cmp.b	#$6C,d1
	beq	do_spel
	cmp.b	#$45,d1
	beq	do_spch
	cmp.b	#$65,d1
	beq	do_spch
	cmp.b	#$4E,d1
	beq	do_rand
	cmp.b	#$6E,d1
	beq	do_rand
	cmp.b	#$4D,d1
	beq	do_misc
	cmp.b	#$6D,d1
	beq	do_misc
	cmp.b	#$43,d1
	beq	save_config
	cmp.b	#$63,d1
	beq	save_config
	cmp.b	#$58,d1
	beq	cl_pref
	cmp.b	#$78,d1
	beq	cl_pref
	bra	prefkey

k_dfl	lea	gd0(pc),a0
	bra.s	act_key
k_auto	lea	gd1(pc),a0
	bra.s	act_key
k_spell	lea	gd2(pc),a0
	bra.s	act_key
k_word	lea	gd3(pc),a0
	bra.s	act_key
k_rveal	lea	gd4(pc),a0
	bra.s	act_key
k_pause	lea	gd5(pc),a0
act_key	bsr	actpg
	bra	prefkey

dosplit	move.l	_GfxBase(pc),a6
	bsr	pen_a6
	bsr	pen_b2
        move.w	#138,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l  a5,a1
	lea	431(a4),a0
	addq.b	#1,(a0)
	cmp.b	#1,(a0)
	ble.s	splitok
	clr.b	(a0)
splitok	tst.b	(a0)
	beq.s	split_0
	lea     pmt10(pc),a0
	bra.s	split_e
split_0	lea     pmt9(pc),a0
split_e	bsr	text_3
	bra	prefkey

do_spel	move.l	_GfxBase(pc),a6
	bsr	pen_a6
	bsr	pen_b2
        move.w	#266,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l  a5,a1
	lea	432(a4),a0
	addq.b	#1,(a0)
	cmp.b	#1,(a0)
	ble.s	spellok
	clr.b	(a0)
spellok	tst.b	(a0)
	beq.s	spell_0
	lea     pmt10(pc),a0
	bra.s	spell_e
spell_0	lea     pmt9(pc),a0
spell_e	bsr	text_3
	bra	prefkey

do_spch	move.l	_GfxBase(pc),a6
	bsr	pen_a6
	bsr	pen_b2
        move.w	#404,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l  a5,a1
	lea	433(a4),a0
	addq.b	#1,(a0)
	cmp.b	#1,(a0)
	ble.s	spechok
	clr.b	(a0)
spechok	tst.b	(a0)
	beq.s	spech_0
	lea     pmt10(pc),a0
	bra.s	spech_e
spech_0	lea     pmt9(pc),a0
spech_e	bsr	text_3
	bra	prefkey

do_rand	move.l	_GfxBase(pc),a6
	bsr	pen_a6
	bsr	pen_b2
        move.w	#543,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l  a5,a1
	lea	434(a4),a0
	addq.b	#1,(a0)
	cmp.b	#1,(a0)
	ble.s	randok
	clr.b	(a0)
randok	tst.b	(a0)
	beq.s	rand_0
	lea     pmt10(pc),a0
	bra.s	rand_e
rand_0	lea     pmt9(pc),a0
rand_e	bsr	text_3
	bra	prefkey

dovoice	lea	390(a4),a1
	addq.w	#1,(a1)
	cmp.w	#9,(a1)
	ble.s	voiceok
	clr.w	(a1)
voiceok	move.l	_GfxBase(pc),a6
	bsr	show_v
	bra	prefkey

do_misc	move.l	_GfxBase(pc),a6
	bsr	pen_a6
	bsr	pen_b2
        move.w	#208,d0
        move.w	#69,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l  a5,a1
	lea	435(a4),a0
	addq.b	#1,(a0)
	cmp.b	#1,(a0)
	ble.s	miscok
	clr.b	(a0)
miscok	lea	wb0(pc),a2
	lea	sb0(pc),a3
	tst.b	(a0)
	beq.s	misc_0
	move.w	#1,84(a2)
	move.w	#1,84(a3)
	lea     pmt10(pc),a0
	bra.s	misc_e
misc_0	move.w	470(a4),84(a2)
	move.w	472(a4),84(a3)
	lea     pmt9(pc),a0
misc_e	bsr	text_3
	cmp.b	#21,428(a4)
	bne.s	misc_f	
	bsr	update_seq
	move.w	456(a4),458(a4)
misc_f	bra	prefkey

d_dfl	lea	gd0(pc),a3
	moveq	#0,d3
	move.l	#700,d4
	move.l	#$31353000,d5
	bsr	stg2num
	cmp.l	#-3,d0
	bne.s	pokedfl
	move.w	#150,d0
pokedfl	move.w	d0,436(a4)
	bra	prefkey

d_auto	lea	gd1(pc),a3
	moveq	#0,d3
	move.l	#700,d4
	move.l	#$31353000,d5
	bsr	stg2num
	cmp.l	#-3,d0
	bne.s	pokeaut
	move.w	#150,d0
pokeaut	move.w	d0,438(a4)
	bra	prefkey

d_spell	lea	gd2(pc),a3
	moveq	#0,d3
	move.l	#700,d4
	move.l	#$31353000,d5
	bsr	stg2num
	cmp.l	#-3,d0
	bne.s	pokespl
	move.w	#150,d0
pokespl	move.w	d0,440(a4)
	bra	prefkey

d_word	lea	gd3(pc),a3
	moveq	#0,d3
	move.l	#700,d4
	move.l	#$31353000,d5
	bsr	stg2num
	cmp.l	#-3,d0
	bne.s	pokewrd
	move.w	#150,d0
pokewrd	move.w	d0,442(a4)
	bra	prefkey

d_rveal	lea	gd4(pc),a3
	moveq	#0,d3
	move.l	#700,d4
	move.l	#$31353000,d5
	bsr	stg2num
	cmp.l	#-3,d0
	bne.s	pokervl
	move.w	#150,d0
pokervl	move.w	d0,444(a4)
	bra	prefkey

d_pause	lea	gd5(pc),a3
	moveq	#0,d3
	move.l	#700,d4
	move.l	#$31353000,d5
	bsr	stg2num
	cmp.l	#-3,d0
	bne.s	pokepse
	move.w	#150,d0
pokepse	move.w	d0,446(a4)
	bra	prefkey


pref_rk
	nop
	bra	prefkey

pref_mb	move.w	msex,d0
	move.w	msey,d1
	cmp.w	#SELECTDOWN,icode
	bne	pmb_end
	cmp.w	#6,d1
	blt.s	mse_pn1
	cmp.w	#18,d1
	bgt.s	mse_pn1
	cmp.w	#14,d0
	blt.s	mse_pc1
	cmp.w	#114,d0
	bgt.s	mse_pc1
	bra	k_dfl
mse_pc1	cmp.w	#192,d0
	blt.s	mse_pc2
	cmp.w	#242,d0
	bgt.s	mse_pc2
	bra	k_auto
mse_pc2	cmp.w	#320,d0
	blt.s	mse_pc3
	cmp.w	#410,d0
	bgt.s	mse_pc3
	bra	k_spell
mse_pc3	cmp.w	#488,d0
	blt	pmb_end
	cmp.w	#538,d0
	bgt	pmb_end
	bra	k_word
mse_pn1	cmp.w	#24,d1
	blt.s	mse_pn2
	cmp.w	#36,d1
	bgt.s	mse_pn2
	cmp.w	#14,d0
	blt.s	mse_pc5
	cmp.w	#84,d0
	bgt.s	mse_pc5
	bra	k_rveal
mse_pc5	cmp.w	#162,d0
	blt.s	mse_pc6
	cmp.w	#222,d0
	bgt.s	mse_pc6
	bra	k_pause
mse_pc6	cmp.w	#300,d0
	blt	pmb_end
	cmp.w	#360,d0
	bgt	pmb_end
	bra	dovoice
mse_pn2	cmp.w	#42,d1
	blt.s	mse_pn3
	cmp.w	#54,d1
	bgt.s	mse_pn3
	cmp.w	#14,d0
	blt.s	mse_pc7
	cmp.w	#125,d0
	bgt.s	mse_pc7
	bra	dosplit
mse_pc7	cmp.w	#193,d0
	blt.s	mse_pc8
	cmp.w	#253,d0
	bgt.s	mse_pc8
	bra	do_spel
mse_pc8	cmp.w	#321,d0
	blt.s	mse_pc9
	cmp.w	#391,d0
	bgt.s	mse_pc9
	bra	do_spch
mse_pc9	cmp.w	#459,d0
	blt.s	pmb_end
	cmp.w	#530,d0
	bgt.s	pmb_end
	bra	do_rand
mse_pn3	cmp.w	#60,d1
	blt.s	pmb_end
	cmp.w	#72,d1
	bgt.s	pmb_end
	cmp.w	#14,d0
	blt.s	mse_pc11
	cmp.w	#195,d0
	bgt.s	mse_pc11
	bra	do_misc
mse_pc11
	cmp.w	#264,d0
	blt.s	mse_pc12
	cmp.w	#334,d0
	bgt.s	mse_pc12
	nop
mse_pc12
	cmp.w	#410,d0
	blt.s	mse_pc13
	cmp.w	#532,d0
	bgt.s	mse_pc13
	bra.s	save_config
mse_pc13
	cmp.w	#545,d0
	blt.s	pmb_end
	cmp.w	#595,d0
	bgt.s	pmb_end
	bra	cl_pref
pmb_end	bra	prefkey

save_config
	moveq	#-1,d6
	move.b	fnload,d0
	moveq	#17,d2
	bsr	copy_fn
	lea	filename(pc),a3
	move.l	a3,d1
	move.l	#MODE_NEWFILE,d2
	move.l	_DOSBase(pc),a6
	jsr	_LVOOpen(a6)
	move.l	d0,fh
	beq.s	erropen
	move.l	fh(pc),d1
	move.l	a4,d2
	move.l	#CONFIG_SAVESIZE,d3
	jsr	_LVOWrite(a6)
	cmp.l	#CONFIG_SAVESIZE,d0
	bne.s	writerr
	moveq	#0,d6
	bra.s	closecf
writerr	moveq	#8,d6
closecf	move.l	fh(pc),d1
	move.l	_DOSBase(pc),a6
	jsr	_LVOClose(a6)
	bra.s	sc_end
erropen	moveq	#6,d6
sc_end	bra	prefkey

get_fileinfo
	moveq	#-1,d6
	move.l	#fib_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,fibptr
	beq.s	no_fib
	move.b	#1,d3
	move.l	a3,d1
	moveq	#SHARED_LOCK,d2
	move.l	_DOSBase(pc),a6
	jsr	_LVOLock(a6)
	move.l	d0,lockptr
	beq.s	lockerr
	clr.b	d3
	move.l	lockptr(pc),d1
	move.l	fibptr(pc),d2
	jsr	_LVOExamine(a6)
	cmp.l	#TRUE,d0
	bne.s	examerr
	move.l	fibptr(pc),a0
	move.l	fib_Size(a0),d5
	bra.s	freefib
lockerr	moveq	#2,d6
	bra.s	freefib
examerr	moveq	#3,d6
freefib	move.l	fibptr(pc),a1
	move.l	#fib_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	cmp.b	#1,d3
	beq.s	gfs_end
freelok	move.l	lockptr(pc),d1
	move.l	_DOSBase(pc),a6
	jsr	_LVOUnLock(a6)
	tst.l	d5
	blt.s	nofile
	cmp.l	d4,d5
	blt.s	sizeerr
	moveq	#0,d6
	bra.s	gfs_end
nofile	moveq	#4,d6
	bra.s	gfs_end
sizeerr	moveq	#5,d6
	bra.s	gfs_end
no_fib	moveq	#1,d6
gfs_end	rts

open_file
	move.l	a3,d1
	move.l	#MODE_OLDFILE,d2
	move.l	_DOSBase(pc),a6
	jsr	_LVOOpen(a6)
	move.l	d0,fh
	beq.s	openerr
	bra.s	of_end
openerr	moveq	#5,d6
of_end	rts

read_file
	move.l	fh(pc),d1
	move.l	a2,d2
	move.l	d5,d3
	move.l	_DOSBase(pc),a6
	jsr	_LVORead(a6)
	cmp.l	d5,d0
	bne.s	readerr
	bra.s	rf_end
readerr	moveq	#6,d6
rf_end	rts

close_file
	move.l	fh(pc),d1
	move.l	_DOSBase(pc),a6
	jsr	_LVOClose(a6)
	rts

copy_fn	lea	filename(pc),a3
	cmp.b	#4,d0
	beq.s	dirn_1
	cmp.b	#8,d0
	beq.s	dirn_2
	cmp.b	#12,d0
	beq.s	dirn_3
	cmp.b	#16,d0
	beq.s	dirn_4
	cmp.b	#20,d0
	beq.s	dirn_5
	cmp.b	#24,d0
	beq.s	dirn_6
	cmp.b	#28,d0
	beq.s	dirn_7
	cmp.b	#32,d0
	beq.s	dirn_8
	cmp.b	#36,d0
	beq.s	dirn_9
	cmp.b	#40,d0
	beq.s	dirn_10
	move.l	#$52414D3A,(a3)+
	bra.s	drawer
dirn_1	move.l	#$4446303A,(a3)+
	bra.s	drawer
dirn_2	move.l	#$4446313A,(a3)+
	bra.s	drawer
dirn_3	move.l	#$4446323A,(a3)+
	bra.s	drawer
dirn_4	move.l	#$4446333A,(a3)+
	bra.s	drawer
dirn_5	move.l	#$4448303A,(a3)+
	bra.s	drawer
dirn_6	move.l	#$4448313A,(a3)+
	bra.s	drawer
dirn_7	move.l	#$4448323A,(a3)+
	bra.s	drawer
dirn_8	move.l	#$4448333A,(a3)+
	bra.s	drawer
dirn_9	move.l	#$574F524B,(a3)+
	move.b	#$3A,(a3)+
	bra.s	drawer
dirn_10	move.l	#$4C475549,(a3)+
	move.b	#$3A,(a3)+
drawer	moveq	#11,d0
	lea	lfn18(pc),a0
drw_l	move.b	(a0)+,(a3)+
	dbf	d0,drw_l
	move.l	a3,a0
	cmp.b	#1,d2
	beq.s	fn_1
	cmp.b	#2,d2
	beq.s	fn_2
	cmp.b	#3,d2
	beq.s	fn_3
	cmp.b	#4,d2
	beq.s	fn_4
	cmp.b	#5,d2
	beq.s	fn_5
	cmp.b	#6,d2
	beq.s	fn_6
	cmp.b	#7,d2
	beq.s	fn_7
	cmp.b	#8,d2
	beq.s	fn_8
	cmp.b	#9,d2
	beq.s	fn_9
	cmp.b	#10,d2
	beq.s	fn_10
	cmp.b	#11,d2
	beq.s	fn_11
	cmp.b	#12,d2
	beq.s	fn_12
	cmp.b	#13,d2
	beq.s	fn_13
	cmp.b	#14,d2
	beq.s	fn_14
	cmp.b	#15,d2
	beq.s	fn_15
	cmp.b	#16,d2
	beq.s	fn_16
	cmp.b	#17,d2
	beq.s	fn_17
	lea	lfn0(pc),a1
	bra.s	fn_file
fn_1	lea	lfn1(pc),a1
	bra.s	fn_file
fn_2	lea	lfn2(pc),a1
	bra.s	fn_file
fn_3	lea	lfn3(pc),a1
	bra.s	fn_file
fn_4	lea	lfn4(pc),a1
	bra.s	fn_file
fn_5	lea	lfn5(pc),a1
	bra.s	fn_file
fn_6	lea	lfn6(pc),a1
	bra.s	fn_file
fn_7	lea	lfn7(pc),a1
	bra.s	fn_file
fn_8	lea	lfn8(pc),a1
	bra.s	fn_file
fn_9	lea	lfn9(pc),a1
	bra.s	fn_file
fn_10	lea	lfn10(pc),a1
	bra.s	fn_file
fn_11	lea	lfn11(pc),a1
	bra.s	fn_file
fn_12	lea	lfn12(pc),a1
	bra.s	fn_file
fn_13	lea	lfn13(pc),a1
	bra.s	fn_file
fn_14	lea	lfn14(pc),a1
	bra.s	fn_file
fn_15	lea	lfn15(pc),a1
	bra.s	fn_file
fn_16	lea	lfn16(pc),a1
	bra.s	fn_file
fn_17	lea	lfn17(pc),a1
fn_file	bsr	stgcopy
	add.l	d0,a3
	clr.b	(a3)+
	clr.b	(a3)+
	rts

load_titles
	move.b	fnload,d0
	moveq	#0,d2
	bsr	copy_fn
	lea	filename(pc),a3
	move.l	#1276,d4
	bsr	get_fileinfo
	tst.b	d6
	bne	lt_err
	cmp.l	d4,d5
	beq.s	lt_ok
	moveq	#11,d6
	bra	lt_err
lt_ok	move.l	d5,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,titlesmem
	beq.s	no_tmem
	move.l	d0,a2
	bsr	open_file
	tst.b	d6
	bne.s	lte_o
	bsr	read_file
	tst.b	d6
	bne.s	lte_r
	move.l	a2,a3
	lea	638(a3),a3
	moveq	#0,d1
swl_l	clr.b	d0
	lea	wordlist(pc),a0
	lea	sentlist(pc),a1
	move.l	0(a0,d1.l),a0
	move.l	0(a1,d1.l),a1
wsl_l	move.l	(a2)+,(a0)+
	move.l	(a3)+,(a1)+
	addq.b	#4,d0
	cmp.b	#28,d0
	blt.s	wsl_l
	addq.l	#1,a2
	addq.l	#1,a3
	addq.l	#4,d1
	cmp.b	#88,d1
	blt.s	swl_l
	bra.s	cl_ltf
lte_r	clr.b	d7
	bsr	btn_req
cl_ltf	bsr	close_file
	bra.s	freetm
lte_o	clr.b	d7
	bsr	btn_req
freetm	move.l	titlesmem(pc),a1
	move.l	d5,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	bra.s	lt_end
no_tmem	moveq	#1,d6
	clr.b	d7
	bsr	btn_req
	bra.s	lt_end
lt_err	clr.b	d7
	bsr	btn_req
lt_end	rts

load_files
	move.b	count,d7
	move.l	#3960,d4
	bsr.s	load_file
	tst.b	d6
	bne.s	laf_end
	addq.b	#1,count
	cmp.b	#3,count
	blt.s	load_files
lf_l2	move.b	count,d7
	move.l	#2068,d4
	bsr.s	load_file
	tst.b	d6
	bne.s	laf_end
	addq.b	#1,count
	cmp.b	#9,count
	blt.s	lf_l2
laf_end	rts

load_file
	move.b	d7,d2
	move.b	fnload,d0
	bsr	copy_fn
	lea	filename(pc),a3
	bsr	get_fileinfo
	tst.b	d6
	bne	lf_err
	move.l	d5,fl
	move.l	d5,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,memptr
	beq	no_fmem
	move.l	d0,a2
	bsr	open_file
	tst.b	d6
	bne	lfe_o
	bsr	read_file
	tst.b	d6
	bne	lfe_r
	cmp.b	#1,d7
	beq.s	lf1
	cmp.b	#2,d7
	beq.s	lf2
	cmp.b	#3,d7
	beq.s	lf3
	cmp.b	#4,d7
	beq.s	lf4
	cmp.b	#5,d7
	beq.s	lf5
	cmp.b	#6,d7
	beq.s	lf6
	cmp.b	#7,d7
	beq.s	lf7
	cmp.b	#8,d7
	beq.s	lf8
	cmp.b	#10,d7
	beq.s	lf10
	cmp.b	#12,d7
	beq.s	lf12
	bra	cl_lff
lf1	bsr	ec_ds
	bra.s	lf1_e
lf2	bsr	ec_fs
	bra.s	lf2_e
lf3	bsr	ec_dn
	bra.s	lf3_e
lf4	bsr	ec_fn
	bra.s	lf4_e
lf5	bsr	ec_dj
	bra.s	lf5_e
lf6	bsr	ec_fj
	bra.s	lf6_e
lf7	bsr	ec_dv
	bra.s	lf7_e
lf8	bsr	ec_fv
	bra.s	lf8_e
lf10	bsr	ec_fssp
	move.l	d6,d0
	bne.s	lf10_e
	move.b	#1,469(a4)
	bra.s	cl_lff
lf12	bsr	ec_fnsp
	move.l	d6,d0
	bne.s	lf12_e
	move.b	#1,468(a4)
	bra.s	cl_lff
lf1_e	move.b	#1,d7
	bra.s	lfn_e
lf2_e	move.b	#2,d7
	bra.s	lfn_e
lf3_e	move.b	#3,d7
	bra.s	lfn_e
lf4_e	move.b	#4,d7
	bra.s	lfn_e
lf5_e	move.b	#5,d7
	bra.s	lfn_e
lf6_e	move.b	#6,d7
	bra.s	lfn_e
lf7_e	move.b	#7,d7
	bra.s	lfn_e
lf8_e	move.b	#8,d7
	bra.s	lfn_e
lf10_e	move.b	#10,d7
	bra.s	lfn_e
lf12_e	move.b	#12,d7
lfn_e	move.b	d0,d6
	beq.s	cl_lff
	bsr.s	btn_req
	bra.s	cl_lff
lfe_r	bsr.s	btn_req
cl_lff	bsr	close_file
	bra.s	freelf
lfe_o	bsr.s	btn_req
freelf	move.l	memptr(pc),a1
	move.l	d5,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	bra.s	lf_end
no_fmem	moveq	#1,d6
	bsr.s	btn_req
	bra.s	lf_end
lf_err	bsr.s	btn_req
lf_end	rts

btn_req	bsr	clr_mse
	suba.l	a0,a0
	lea	btntags(pc),a1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,btnwndw
	beq	btn_e
	move.l	d0,a5
	move.l	wd_RPort(a5),a5
	move.l	a5,btnrp
	move.l	_GfxBase(pc),a6
	bsr	pen_a0
	move.l	a5,a1
	clr.w	d0
	clr.w	d1
	move.w	#201,d2
	move.w	#22,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a2
	move.l	a5,a1
	move.w	#4,d0
	move.w	#2,d1
	move.w	#555,d2
	move.w	#20,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a5
	move.l	a5,a1
	move.w	#2,d0
	move.w	#1,d1
	move.w	#3,d2
	move.w	#21,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#4,d0
	move.w	#21,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#556,d0
	move.w	#21,d1
	jsr	_LVODraw(a6)
	bsr	pen_a1
	move.l	a5,a1
	move.w	#3,d0
	move.w	#1,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#557,d0
	move.w	#1,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#556,d0
	move.w	#2,d1
	move.w	#557,d2
	move.w	#20,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#557,d0
	move.w	#21,d1
	jsr	_LVOWritePixel(a6)
	bsr	pen_a14
	move.l	a5,a1
	move.w	#499,d0
	move.w	#6,d1
	move.w	#545,d2
	move.w	#16,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a15
	move.l	a5,a1
	move.w	#497,d0
	move.w	#5,d1
	move.w	#498,d2
	move.w	#17,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#499,d0
	move.w	#17,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#546,d0
	move.w	#17,d1
	jsr	_LVODraw(a6)
	bsr	pen_a13
	move.l	a5,a1
	move.w	#546,d0
	move.w	#6,d1
	move.w	#547,d2
	move.w	#16,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#547,d0
	move.w	#17,d1
	jsr	_LVOWritePixel(a6)
	move.l	a5,a1
	move.w	#498,d0
	move.w	#5,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#547,d0
	move.w	#5,d1
	jsr	_LVODraw(a6)
	bsr	pen_a0
	bsr	pen_b2
	move.w	#12,d0
        move.w	#14,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea     pmt33(pc),a0
	bsr	text_10
	bsr	pen_a6
	move.w	#129,d0
        move.w	#14,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	cmp.b	#1,d6
	beq.s	te1
	cmp.b	#2,d6
	beq.s	te2
	cmp.b	#3,d6
	beq.s	te3
	cmp.b	#4,d6
	beq	te4
	cmp.b	#5,d6
	beq	te5
	cmp.b	#6,d6
	beq	te6
	cmp.b	#7,d6
	beq	te7
	cmp.b	#8,d6
	beq	te8
	cmp.b	#9,d6
	beq	te9
	cmp.b	#10,d6
	beq	te10
	cmp.b	#11,d6
	beq	te11
	cmp.b	#12,d6
	beq	te12
	cmp.b	#13,d6
	beq	te13
	cmp.b	#14,d6
	beq	te14
	cmp.b	#15,d6
	beq	te15
	bra	tebut
te1	lea     pmt36(pc),a0
	bsr	text_15
	bra	tebut
te2	lea     pmt34(pc),a0
	bsr	text_16
	bra	tebut
te3	lea     pmt35(pc),a0
	bsr	text_19
	bra	tebut
te4	lea     pmt37(pc),a0
	bsr	text_14
	bra	tebut
te5	lea     pmt38(pc),a0
	bsr	text_19
	bra.s	tebut
te6	lea     pmt40(pc),a0
	bsr	text_16
	bra.s	tebut
te7	lea     pmt41(pc),a0
	bsr	text_16
	bra.s	tebut
te8	lea     pmt42(pc),a0
	bsr	text_17
	bra.s	tebut
te9	lea     pmt43(pc),a0
	bsr	text_33
	bra.s	tebut
te10	lea     pmt45(pc),a0
	bsr	text_32
	bra.s	tebut
te11	lea     pmt46(pc),a0
	bsr	text_19
	bra.s	tebut
te12	lea     pmt47(pc),a0
	bsr	text_19
	bra.s	tebut
te13	lea     pmt48(pc),a0
	bsr	text_19
	bra.s	tebut
te14	lea     pmt49(pc),a0
	bsr	text_25
	bra.s	tebut
te15	lea     pmt50(pc),a0
	bsr	text_19
	bra.s	tebut
te16	lea     pmt51(pc),a0
	bsr	text_19
	bra.s	tebut
te17	lea     pmt52(pc),a0
	bsr	text_19
tebut	bsr	pen_a4
	move.w	#334,d0
        move.w	#14,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	tst.b	d7
	beq	ft0
	cmp.b	#1,d7
	beq	ft1
	cmp.b	#2,d7
	beq	ft2
	cmp.b	#3,d7
	beq	ft3
	cmp.b	#4,d7
	beq	ft4
	cmp.b	#5,d7
	beq	ft5
	cmp.b	#6,d7
	beq	ft6
	cmp.b	#7,d7
	beq	ft7
	cmp.b	#8,d7
	beq	ft8
	cmp.b	#9,d7
	beq	ft9
	cmp.b	#10,d7
	beq	ft10
	cmp.b	#11,d7
	beq	ft11
	cmp.b	#12,d7
	beq	ft12
	cmp.b	#13,d7
	beq	ft13
	cmp.b	#14,d7
	beq	ft14
	cmp.b	#15,d7
	beq	ft15
	cmp.b	#16,d7
	beq	ft16
	cmp.b	#17,d7
	beq	ft17
	bra	ft_end
ft0	lea	lfn0(pc),a0
	bsr	text_11
	bra	ft_end
ft1	lea	lfn1(pc),a0
	bsr	text_15
	bra	ft_end
ft2	lea	lfn2(pc),a0
	bsr	text_15
	bra	ft_end
ft3	lea	lfn3(pc),a0
	bsr	text_11
	bra	ft_end
ft4	lea	lfn4(pc),a0
	bsr	text_11
	bra	ft_end
ft5	lea	lfn5(pc),a0
	bsr	text_16
	bra.s	ft_end
ft6	lea	lfn6(pc),a0
	bsr	text_16
	bra.s	ft_end
ft7	lea	lfn7(pc),a0
	bsr	text_11
	bra.s	ft_end
ft8	lea	lfn8(pc),a0
	bsr	text_11
	bra.s	ft_end
ft9	lea	lfn9(pc),a0
	bsr	text_13
	bra.s	ft_end
ft10	lea	lfn10(pc),a0
	bsr	text_13
	bra.s	ft_end
ft11	lea	lfn11(pc),a0
	bsr	text_13
	bra.s	ft_end
ft12	lea	lfn12(pc),a0
	bsr	text_13
	bra.s	ft_end
ft13	lea	lfn13(pc),a0
	bsr	text_13
	bra.s	ft_end
ft14	lea	lfn14(pc),a0
	bsr	text_13
	bra.s	ft_end
ft15	lea	lfn15(pc),a0
	bsr	text_13
	bra.s	ft_end
ft16	lea	lfn16(pc),a0
	bsr	text_13
	bra.s	ft_end
ft17	lea	lfn17(pc),a0
	bsr	text_11
ft_end	bsr	pen_a6
	bsr	pen_b14
	move.w	#503,d0
        move.w	#14,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	cmp.b	#1,d7
	blt.s	ftb1
	cmp.b	#8,d7
	ble.s	ftb2
ftb1	lea     pmt25(pc),a0
	bra.s	ftb_end
ftb2	lea     pmt39(pc),a0
ftb_end	bsr	text_4
	bsr	pen_a4
	move.w	#533,d0
        move.w	#14,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     plt9(pc),a0
	bsr	text_1
btnk	move.l	btnwndw(pc),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
	move.l	btnwndw(pc),a0
	bsr	get_msg

        cmp.l   #IDCMP_VANILLAKEY,d0
        beq.s	btnvk

	cmp.l	#IDCMP_MOUSEBUTTONS,d0
	beq.s	btnmb

        cmp.l   #IDCMP_INACTIVEWINDOW,d0
        beq.s	clbtn

	bra.s	btnk

clbtn	move.l	btnwndw(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOCloseWindow(a6)
btn_e	move.l	scrn0rp(pc),a5
	bsr	set_mse
	rts

btnvk	move.w	icode,d0
	cmp.b	#$54,d0
	beq.s	clbtn
	cmp.b	#$74,d0
	beq.s	clbtn
	bra.s	btnk

btnmb	move.w	msex,d0
	move.w	msey,d1
	cmp.w	#SELECTDOWN,icode
	bne.s	bmb_end
	cmp.w	#5,d1
	blt.s	bmb_end
	cmp.w	#17,d1
	bgt.s	bmb_end
	cmp.w	#497,d0
	blt.s	bmb_end
	cmp.w	#547,d0
	bgt.s	bmb_end
	bra.s	clbtn
bmb_end	bra	btnk

load_config
	move.b	fnload,d0
	moveq	#17,d2
	bsr	copy_fn
	lea	filename(pc),a3
	move.l	#CONFIG_SAVESIZE,d4
	bsr	get_fileinfo
	tst.b	d6
	bne.s	lc_err
	cmp.l	d4,d5
	beq.s	lc_ok
	moveq	#11,d6
	bra.s	lc_err
lc_ok	move.l	d5,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,memptr
	beq.s	no_cmem
	move.l	d0,a2
	bsr	open_file
	tst.b	d6
	bne.s	lce_o
	bsr	read_file
	tst.b	d6
	bne.s	lce_r
	move.l	memptr(pc),a0
	move.l	a4,a1
	moveq	#0,d0
conf_l	move.l	(a0)+,(a1)+
	addq.w	#4,d0
	cmp.l	#CONFIG_SAVESIZE,d0
	blt.s	conf_l
	bra.s	cl_lcf
lce_r	move.b	#17,d7
	bsr	btn_req
cl_lcf	bsr	close_file
	bra.s	freecm
lce_o	move.b	#17,d7
	bsr	btn_req
freecm	move.l	memptr(pc),a1
	move.l	d5,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	bra.s	lcf_end
no_cmem	moveq	#1,d6
	move.b	#17,d7
	bsr	btn_req
	bra.s	lcf_end
lc_err	move.b	#17,d7
	bsr	btn_req
lcf_end	rts

show_titles
	lea	image8(pc),a1
	lea	wordlist(pc),a3
	tst.b	430(a4)
	beq.s	do_t
	lea	image9(pc),a1
	lea	sentlist(pc),a3
do_t	bsr	drawi
	move.l	_GfxBase(pc),a6
	bsr	pen_a1
	bsr	pen_b14
	move.w	#14,d4
	clr.w	d5
st_loop	move.w	#22,d0
        move.w	d4,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l	0(a3,d5.w*4),a0
	bsr	text_28
	move.w	#336,d0
        move.w	d4,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea	44(a3),a0
        move.l	0(a0,d5.w*4),a0
	bsr	text_28
	add.b	#16,d4
	addq.b	#1,d5	
	cmp.b	#11,d5
	blt.s	st_loop
	rts

basic	clr.b	d0
	move.l	_GfxBase(pc),a6
	jsr	_LVOSetRast(a6)
	bsr	pen_a2
	move.l	a5,a1
	clr.w	d0
	clr.w	d1
	move.w	#639,d2
	move.w	#184,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a1
	move.l	a5,a1
	move.w	#2,d0
	clr.w	d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#639,d0
	clr.w	d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#638,d0
	move.w	#1,d1
	move.w	#639,d2
	move.w	#183,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#2,d0
	move.w	#2,d1
	move.w	#3,d2
	move.w	#183,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#4,d0
	move.w	#183,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#635,d0
	move.w	#183,d1
	jsr	_LVODraw(a6)
	bsr	pen_a5
	move.l	a5,a1
	move.w	#4,d0
	move.w	#1,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#637,d0
	move.w	#1,d1
	jsr	_LVODraw(a6)
	move.l	a5,a1
	move.w	#636,d0
	move.w	#2,d1
	move.w	#637,d2
	move.w	#182,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	clr.w	d0
	move.w	#1,d1
	move.w	#1,d2
	move.w	#184,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#2,d0
	move.w	#184,d1
	jsr	_LVOMove(a6)
	move.l	a5,a1
	move.w	#637,d0
	move.w	#184,d1
	jsr	_LVODraw(a6)
	rts

onoffds	lea	image1(pc),a1
	tst.b	420(a4)
	bne.s	draw_ds
	lea	image0(pc),a1
draw_ds	move.w	#7,ig_TopEdge(a1)
	bsr	drawi
	rts

onofffs	lea	image1(pc),a1
	tst.b	421(a4)
	bne.s	draw_fs
	lea	image0(pc),a1
draw_fs	move.w	#40,ig_TopEdge(a1)
	bsr	drawi
	rts

onoffdp	lea	image1(pc),a1
	tst.b	422(a4)
	bne.s	draw_dp
	lea	image0(pc),a1
draw_dp	move.w	#73,ig_TopEdge(a1)
	bsr	drawi
	rts

onofffp	lea	image1(pc),a1
	tst.b	423(a4)
	bne.s	draw_fp
	lea	image0(pc),a1
draw_fp	move.w	#92,ig_TopEdge(a1)
	bsr	drawi
	rts

onoffdj	lea	image1(pc),a1
	tst.b	424(a4)
	bne.s	draw_dj
	lea	image0(pc),a1
draw_dj	move.w	#111,ig_TopEdge(a1)
	bsr	drawi
	rts

onofffj	lea	image1(pc),a1
	tst.b	425(a4)
	bne.s	draw_fj
	lea	image0(pc),a1
draw_fj	move.w	#129,ig_TopEdge(a1)
	bsr	drawi
	rts

onoffdv	lea	image1(pc),a1
	tst.b	426(a4)
	bne.s	draw_dv
	lea	image0(pc),a1
draw_dv	move.w	#149,ig_TopEdge(a1)
	bsr	drawi
	rts

onofffv	lea	image1(pc),a1
	tst.b	427(a4)
	bne.s	draw_fv
	lea	image0(pc),a1
draw_fv	move.w	#169,ig_TopEdge(a1)
	bsr	drawi
	rts

pen_a0	clr.b	d0
	bra.s	do_pena
pen_a1	move.b	#1,d0
	bra.s	do_pena
pen_a2	move.b	#2,d0
	bra.s	do_pena
pen_a3	move.b	#3,d0
	bra.s	do_pena
pen_a4	move.b	#4,d0
	bra.s	do_pena
pen_a5	move.b	#5,d0
	bra.s	do_pena
pen_a6	move.b	#6,d0
	bra.s	do_pena
pen_a7	move.b	#7,d0
	bra.s	do_pena
pen_a8	move.b	#8,d0
	bra.s	do_pena
pen_a9	move.b	#9,d0
	bra.s	do_pena
pen_a10	move.b	#10,d0
	bra.s	do_pena
pen_a11	move.b	#11,d0
	bra.s	do_pena
pen_a12	move.b	#12,d0
	bra.s	do_pena
pen_a13	move.b	#13,d0
	bra.s	do_pena
pen_a14	move.b	#14,d0
	bra.s	do_pena
pen_a15	move.b	#15,d0
do_pena	move.l	a5,a1
	jsr	_LVOSetAPen(a6)
	rts

pen_b2	move.b	#2,d0
	bra.s	do_penb
pen_b5	move.b	#5,d0
	bra.s	do_penb
pen_b8	move.b	#8,d0
	bra.s	do_penb
pen_b10	move.b	#10,d0
	bra.s	do_penb
pen_b14	move.b	#14,d0
do_penb	move.l	a5,a1
	jsr	_LVOSetBPen(a6)
	rts

text_1	moveq	#1,d0
	bra.s	do_text
text_3	moveq	#3,d0
	bra.s	do_text
text_4	moveq	#4,d0
	bra.s	do_text
text_5	moveq	#5,d0
	bra.s	do_text
text_6	moveq	#6,d0
	bra.s	do_text
text_7	moveq	#7,d0
	bra.s	do_text
text_8	moveq	#8,d0
	bra.s	do_text
text_10	moveq	#10,d0
	bra.s	do_text
text_11	moveq	#11,d0
	bra.s	do_text
text_12	moveq	#12,d0
	bra.s	do_text
text_13	moveq	#13,d0
	bra.s	do_text
text_14	moveq	#14,d0
	bra.s	do_text
text_15	moveq	#15,d0
	bra.s	do_text
text_16	moveq	#16,d0
	bra.s	do_text
text_17	moveq	#17,d0
	bra.s	do_text
text_19	moveq	#19,d0
	bra.s	do_text
text_25	moveq	#25,d0
	bra.s	do_text
text_28	moveq	#28,d0
	bra.s	do_text
text_32	moveq	#32,d0
	bra.s	do_text
text_33	moveq	#33,d0
	bra.s	do_text
text_42	moveq	#42,d0
do_text	move.l  a5,a1
	jsr	_LVOText(a6)
	rts

drawi	move.l	a5,a0
	clr.w	d0
	clr.w	d1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVODrawImage(a6)
	rts

drawnb	move.b	428(a4),d0
	cmp.b	429(a4),d0
	beq.s	db_end
drawbb	moveq	#0,d0
	move.b	429(a4),d0
	move.b	#2,d1
	bsr.s	drawb
drawbc	moveq	#0,d0
	move.b	428(a4),d0
	clr.b	d1
drawb	lea	border0(pc),a1
	cmp.b	#11,d0
	bge.s	boxr
	move.w	#14,(a1)
	bra.s	draw_b
boxr	move.w	#328,(a1)
	sub.b	#11,d0
draw_b	mulu	#16,d0
	addq.b	#5,d0
	move.w	d0,bd_TopEdge(a1)
	move.b	d1,bd_FrontPen(a1)
bord	move.l	a5,a0
	clr.w	d0
	clr.w	d1
	move.l	_IntuitionBase(pc),a6
	jsr	_LVODrawBorder(a6)
	bsr	update_seq
	move.w	456(a4),458(a4)
db_end	rts

update_config
	move.l	scrn1rp,a5
	bsr	show_titles
	bsr.s	drawbb
	move.l	scrn0rp,a5
	bsr	onoffds
	bsr	onofffs
	bsr	onoffdp
	bsr	onofffp
	bsr	onoffdj
	bsr	onofffj
	bsr	onoffdv
	bsr	onofffv
	lea	image6(pc),a1
	tst.b	454(a4)
	beq.s	am_m
	lea	image7(pc),a1
am_m	bsr	drawi
	rts

update_search
	bsr.s	chk_dfb
	bsr.s	chkspav
	rts

chk_dfb	tst.b	452(a4)
	beq.s	defb_0
	lea	border5(pc),a1
	move.w	#440,(a1)
	move.b	#14,bd_FrontPen(a1)
	bsr.s	bord
	lea	border5(pc),a1
	move.w	#535,(a1)
	clr.b	bd_FrontPen(a1)
	bsr	bord
	bra.s	defb_e
defb_0	lea	border5(pc),a1
	move.w	#535,(a1)
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border5(pc),a1
	move.w	#440,(a1)
	clr.b	bd_FrontPen(a1)
	bsr	bord
defb_e	rts

chkspav	cmp.b	#1,453(a4)
	beq.s	spav_1
	cmp.b	#2,453(a4)
	beq.s	spav_2
	cmp.b	#3,453(a4)
	beq	spav_3
	lea	border2(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border3(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border4(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border1(pc),a1
	clr.b	bd_FrontPen(a1)
	bsr	bord
	bra	spav_e
spav_1	lea	border3(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border4(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border1(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border2(pc),a1
	clr.b	bd_FrontPen(a1)
	bsr	bord
	bra.s	spav_e
spav_2	lea	border1(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border2(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border4(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border3(pc),a1
	clr.b	bd_FrontPen(a1)
	bsr	bord
	bra.s	spav_e
spav_3	lea	border1(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border2(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border3(pc),a1
	move.b	#14,bd_FrontPen(a1)
	bsr	bord
	lea	border4(pc),a1
	clr.b	bd_FrontPen(a1)
	bsr	bord
spav_e	rts

update_prefs
	move.l	_GfxBase(pc),a6
	bsr	pen_a6
	bsr	pen_b2
	move.w	#138,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea     pmt10(pc),a0
	tst.b	431(a4)
	bne.s	ws_e
	lea     pmt9(pc),a0
ws_e	bsr	text_3
	move.w	#266,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea     pmt10(pc),a0
	tst.b	432(a4)
	bne.s	spel_e
	lea     pmt9(pc),a0
spel_e	bsr	text_3
	move.w	#404,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea     pmt10(pc),a0
	tst.b	433(a4)
	bne.s	spch_e
	lea     pmt9(pc),a0
spch_e	bsr	text_3
	move.w	#543,d0
        move.w	#51,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea     pmt10(pc),a0
	tst.b	434(a4)
	bne.s	rnd_e
	lea     pmt9(pc),a0
rnd_e	bsr	text_3
	move.w	#208,d0
        move.w	#69,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea     pmt10(pc),a0
	tst.b	435(a4)
	bne.s	msc_e
	lea     pmt9(pc),a0
msc_e	bsr	text_3
	move.l	_IntuitionBase(pc),a6

	lea	gd0(pc),a1
	bsr	rmpg
	moveq	#0,d1
	move.w	436(a4),d1
	lea	numb0(pc),a0
	move.w	#700,d6
	clr.w	d5
	bsr	plusthree
	lea	gd0(pc),a1
	bsr	apg

	lea	gd1(pc),a1
	bsr	rmpg
	moveq	#0,d1
	move.w	438(a4),d1
	lea	numb1(pc),a0
	move.w	#700,d6
	clr.w	d5
	bsr	plusthree
	lea	gd1(pc),a1
	bsr	apg

	lea	gd2(pc),a1
	bsr	rmpg
	moveq	#0,d1
	move.w	440(a4),d1
	lea	numb2(pc),a0
	move.w	#700,d6
	clr.w	d5
	bsr	plusthree
	lea	gd2(pc),a1
	bsr	apg

	lea	gd3(pc),a1
	bsr	rmpg
	moveq	#0,d1
	move.w	442(a4),d1
	lea	numb3(pc),a0
	move.w	#700,d6
	clr.w	d5
	bsr.s	plusthree
	lea	gd3(pc),a1
	bsr	apg

	lea	gd4(pc),a1
	bsr	rmpg
	moveq	#0,d1
	move.w	444(a4),d1
	lea	numb4(pc),a0
	move.w	#700,d6
	clr.w	d5
	bsr.s	plusthree
	lea	gd4(pc),a1
	bsr	apg

	lea	gd5(pc),a1
	bsr	rmpg
	moveq	#0,d1
	move.w	446(a4),d1
	lea	numb5(pc),a0
	move.w	#700,d6
	clr.w	d5
	bsr.s	plusthree
	lea	gd5(pc),a1
	bsr	apg

	lea	gd0(pc),a0
	bsr	rpg
	rts

plusfive
	cmp.w	d6,d1
	bgt.s	plus0
	cmp.w	d5,d1
	bge.s	plus5
	cmp.w	#5000,d1
	bge.s	plus4
	bra.s	plus0
plusthree
	cmp.w	d6,d1
	bgt.s	plus0
	cmp.w	d5,d1
	bge.s	plus3
	bra.s	plus0
plustwo
	cmp.w	d6,d1
	bgt.s	plus0
	cmp.w	d5,d1
	bge.s	plus2
	bra.s	plus0
minusplus
	cmp.b	d6,d1
	bgt.s	plus0
	cmp.b	d5,d1
	bge.s	plus2
	tst.b	d1
	beq.s	plus0
	cmp.b	#224,d1
	blt.s	plus0
	bra.s	minus
plus0	move.l	#$30000000,(a0)
	bra.s	plus_e
minus	neg.b	d1
	move.b	#$2D,(a0)+
	bra.s	plus2
plus5	divu	#10000,d1
	bsr.s	do_vle
plus4	divu	#1000,d1
	bsr.s	do_vle
plus3	divu	#100,d1
	bsr.s	do_vle
plus2	divu	#10,d1
	bsr.s	do_vle
plus1	bsr.s	do_vle
	clr.b	(a0)
plus_e	rts

do_vle	add.w	#$30,d1
	move.b	d1,(a0)+
no_vle	clr.w	d1
	swap	d1
	rts

stgcopy	moveq	#0,d0
        move.l  a0,a2
again   move.b  (a1)+,(a2)+
        bne.s	again
        subq.w  #1,a2
        suba.l	a0,a2
        move.l  a2,d0
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

 * Default Config - S.T.M is the first 420 bytes.

def_cf	lea	130(a4),a0
	lea	210(a4),a1
	moveq	#9,d0
cf_loop	move.b	#77,0(a4,d0.w)		; Sex
	clr.b	10(a4,d0.w)		; Mode
	move.b	#64,20(a4,d0.w)		; Volume
	move.b	#32,30(a4,d0.w)		; Enthusiasm
	move.b	#100,40(a4,d0.w)	; Articulate
	clr.b	50(a4,d0.w)		; Perturb
	clr.b	60(a4,d0.w)		; AVBias
	clr.b	70(a4,d0.w)		; AFBias
	clr.b	80(a4,d0.w)		; Amplify1
	clr.b	90(a4,d0.w)		; Amplify2
	clr.b	100(a4,d0.w)		; Amplify3
	clr.b	110(a4,d0.w)		; Vowel
	clr.b	120(a4,d0.w)		; Vowel Centphon
	clr.b	0(a0,d0.w)		; Echo1
	clr.b	10(a0,d0.w)		; Echo2
	clr.b	20(a0,d0.w)		; Echo3
	move.b	#52,30(a0,d0.w)		; #Channels
	move.b	#3,40(a0,d0.w)		; Channel 1 Values
	move.b	#5,50(a0,d0.w)		; Channel 2 Values
	move.b	#10,60(a0,d0.w)		; Channel 3 Values
	move.b	#12,70(a0,d0.w)		; Channel 4 Values
	move.w	#110,0(a1,d0.w*2)	; Pitch
	move.w	#150,20(a1,d0.w*2)	; Rate
	move.w	#22000,40(a1,d0.w*2)	; Frequency
	dbra	d0,cf_loop
	lea	langlist(pc),a0
	lea	270(a4),a2
	moveq	#9,d0
lang_l	move.l	(a0)+,a1
	move.l	(a1),(a2)
	move.l	4(a1),4(a2)
	move.l	8(a1),8(a2)
	lea	12(a2),a2
	dbra	d0,lang_l
	move.w	#2,(a2)+		; 390 sph (voice 2: english)
	move.w	#2,(a2)+		; 392 oldsph
	move.l	#0,(a2)+		; 394 amplify
					; 395 echo
					; 396 mouth
					; 397 cvle
	move.l	#$01010164,(a2)+	; 398 ssf
					; 399 wsf
					; 400 fcf
					; 401 speech priority
	move.l	#$03050A0C,(a2)+	; 402 masks (values: 3, 5, 10 and 12)
					; 406

 * 406 to 419 is reserved for STM.

	move.l	#$01000100,420(a4)	; 420 default sentences
					; 421 foreign sentences
					; 422 default pro/nouns
					; 423 foreign pro/nouns
	move.l	#$01000100,424(a4)	; 424 default adjectives
					; 425 foreign adjectives
					; 426 default ad/verbs
					; 427 foreign ad/verbs
					; 428 selected box
					; 429 old selected box
					; 430 learn words or sentences
					; 431 word split off/on
					; 432 spell off/on
	move.b	#1,433(a4)		; 433 speech off/on
					; 434 random/in-sequence
					; 435 miscellaneous all off/on
	move.w	#100,436(a4)		; 436 d/f lines delay
	move.w	#320,438(a4)		; 438 auto delay
	move.w	#5,440(a4)		; 440 spelling delay
	move.w	#100,442(a4)		; 442 word delay
	move.w	#100,444(a4)		; 444 reveal delay
	move.w	#200,446(a4)		; 446 pause delay
					; 448 s.l.v for words
					; 450 s.l.v for sentences
					; 452 default/foreign search
					; 453 spav mode
					; 454 manual/auto mode
	move.b	#1,455(a4)		; 455 search status
					; 456 current sequence
					; 458 next sequence
					; 460 old sequence
	move.l	#$05DC05DC,462(a4)	; 462 wb total (dummy value: 1500)
					; 464 sb total (dummy value: 1500)
					; 466 nx
					; 467 forward
					; 468 nvb
					; 469 svb
					; 470 wb miscellaneous start
					; 472 sb miscellaneous start
					; 474 search's last position
					; 478
	rts

actsg	move.l  searchwndw(pc),a1
	bra.s	actg
actpg	move.l  prefswndw(pc),a1
actg	suba.l  a2,a2
        move.l  _IntuitionBase(pc),a6
        jsr	_LVOActivateGadget(a6)
	rts

rmsg	move.l	searchwndw(pc),a0
	bra.s	rmg
rmpg	move.l	prefswndw(pc),a0
rmg	jsr	_LVORemoveGadget(a6)
	rts

asg	move.l	searchwndw(pc),a0
	bra.s	adg
apg	move.l	prefswndw(pc),a0
adg	moveq	#-1,d0
	jsr	_LVOAddGadget(a6)
	rts

rsg	move.l	searchwndw(pc),a1
	bra.s	rfg
rpg	move.l	prefswndw(pc),a1
rfg	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)
	rts

stg2num	move.l	a3,a0
	move.l  gg_SpecialInfo(a0),a0
        move.l  (a0),a0				; si_Buffer(a0),a0
	move.l	a0,a2
        bsr.s	findlen
        tst.l   d0
        ble.s   val_nil
        move.l  a2,d1
        move.l  #longval,d2
	move.l	_DOSBase(pc),a6
	jsr	_LVOStrToLong(a6)
        cmp.l  #TRUE,d0
        beq.s   val_nil
	move.l	longval,d0
        cmp.l	d4,d0
        bgt.s   val_nil
        cmp.l	d3,d0
        blt.s   val_nil
	rts
val_nil	move.l	_IntuitionBase(pc),a6
	move.l	a3,a1
	bsr.s	rmpg
	move.l	d5,(a2)
	move.l	a3,a1
	bsr.s	apg
	move.l	a3,a0
	bsr.s	rpg
	moveq	#-3,d0
	rts

findlen	move.l	a0,a1
        moveq	#0,d0
not_nil	tst.b   (a1)+
        beq.s	got_len
        addq.b	#1,d0
        bra.s	not_nil
got_len	rts

get_msg	move.l	wd_UserPort(a0),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,a1
	move.l	im_Class(a1),iclass
	move.w	im_Code(a1),icode
	move.w	im_Qualifier(a1),iqual
	move.l	im_IAddress(a1),iadr
	move.w	im_MouseX(a1),msex
	move.w	im_MouseY(a1),msey
	jsr	_LVOReplyMsg(a6)
	move.l	iclass,d0
	rts

tt_num	moveq	#-1,d2
	bsr.s	findlen
	cmp.l	#4,d0
	bne	ttn_end
	cmp.b	#$30,(a0)
	blt.s	ttn_end
	cmp.b	#$39,(a0)
	bgt.s	ttn_end
	cmp.b	#$30,1(a0)
	blt.s	ttn_end
	cmp.b	#$39,1(a0)
	bgt.s	ttn_end
	cmp.b	#$30,2(a0)
	blt.s	ttn_end
	cmp.b	#$39,2(a0)
	bgt.s	ttn_end
	cmp.b	#$30,3(a0)
	blt.s	ttn_end
	cmp.b	#$39,3(a0)
	bgt.s	ttn_end
	moveq	#0,d1
	moveq	#0,d0
	move.b	(a0),d0
	sub.w	#$30,d0
	mulu	#1000,d0
	add.w	d0,d1
	moveq	#0,d0
	move.b	1(a0),d0
	sub.w	#$30,d0
	mulu	#100,d0
	add.w	d0,d1
	moveq	#0,d0
	move.b	2(a0),d0
	sub.w	#$30,d0
	mulu	#10,d0
	add.w	d0,d1
	moveq	#0,d0
	move.b	3(a0),d0
	sub.w	#$30,d0
	add.w	d0,d1
        cmp.l	d6,d1
        ble.s   ttn_end
        cmp.l	d7,d1
        bgt.s   ttn_end
	moveq	#0,d2
ttn_end	rts

arg_num	move.l  a0,d1
        move.l	#longval,d2
	move.l	_DOSBase(pc),a6
	jsr	_LVOStrToLong(a6)
        cmp.l	#TRUE,d0
        beq.s   vle_nil
        lea	longval,a0
        and.l   #$0000FFFF,(a0)
	move.l	(a0),d0
        cmp.l	d6,d0
        ble.s   vle_nil
        cmp.l	d7,d0
        bgt.s   vle_nil
        bra.s	an_end
vle_nil	moveq	#-1,d0
an_end	rts

set_mse	move.l	wndw0ptr(pc),a0
	move.l	#md0,a1
	moveq	#16,d0
	moveq	#16,d1
	moveq	#-6,d2
	moveq	#0,d3
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOSetPointer(a6)
	rts

clr_mse	move.l	wndw0ptr(pc),a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVOClearPointer(a6)
	rts

clr_words
	move.l	_GfxBase(pc),a6
	bsr	pen_a14
	move.w	#72,d1
	move.w	#83,d3
	bsr.s	rect_1
	move.w	#91,d1
	move.w	#102,d3
	bsr.s	rect_1
	move.w	#110,d1
	move.w	#121,d3
	bsr.s	rect_1
	move.w	#129,d1
	move.w	#140,d3
	bsr.s	rect_1
	move.w	#148,d1
	move.w	#159,d3
	bsr.s	rect_1
	move.w	#167,d1
	move.w	#178,d3
	bsr.s	rect_1
	rts

rect_1	move.l	a5,a1
	move.w	#189,d0
	move.w	#623,d2
	jsr	_LVORectFill(a6)
	rts

clr_sents
	move.l	_GfxBase(pc),a6
	bsr	pen_a14
	move.w	#6,d1
	move.w	#31,d3
	bsr.s	rect_1
	move.w	#39,d1
	move.w	#64,d3
	bsr.s	rect_1
	rts

show_sentences
	move.l	_GfxBase(pc),a6
	bsr	pen_a4
	bsr	pen_b14
	tst.b	420(a4)
	beq.s	ss_c2
	tst.b	432(a4)
	beq.s	sp_off0
	move.w	#14,d3
	move.l	dfsmem(pc),a2
	bsr	ss_l1
	move.w	#26,d3
	move.l	dssmem(pc),a2
	bsr	ss_l1
	bra.s	ss_c2
sp_off0	move.w	#14,d1
	bsr	bas_pos
	move.l	dfsmem(pc),a0
	bsr	bas_txt
	moveq	#0,d1
	move.w	436(a4),d1
	tst.w	d1
	beq.s	spo_c1
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
spo_c1	move.w	#26,d1
	bsr	bas_pos
	move.l	dssmem(pc),a0
	bsr	bas_txt
ss_c2	move.l	_GfxBase(pc),a6
	bsr	pen_a6
	tst.b	420(a4)
	beq.s	ss_c3
	tst.b	421(a4)
	beq.s	ss_c3
	moveq	#0,d1
	move.w	444(a4),d1
	tst.w	d1
	beq.s	ss_c3
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
ss_c3	move.l	_GfxBase(pc),a6
	tst.b	421(a4)
	beq.s	ss_end
	tst.b	432(a4)
	beq.s	sp_off1
	move.w	#47,d3
	move.l	ffsmem(pc),a2
	bsr	ss_l1
	move.w	#59,d3
	move.l	fssmem(pc),a2
	bsr	ss_l1
	bra.s	ss_end
sp_off1	move.w	#47,d1
	bsr	bas_pos
	move.l	ffsmem(pc),a0
	bsr	bas_txt
	moveq	#0,d1
	move.w	436(a4),d1
	tst.w	d1
	beq.s	spo_c2
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
spo_c2	move.w	#59,d1
	bsr	bas_pos
	move.l	fssmem(pc),a0
	bsr	bas_txt
ss_end	tst.b	454(a4)
	beq.s	nscont0
	tst.b	420(a4)
	beq.s	nscont0
	tst.b	421(a4)
	beq.s	nscont0
	moveq	#0,d1
	move.w	438(a4),d1
	tst.w	d1
	beq.s	nscont0
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
nscont0	move.w	456(a4),460(a4)
	lea	sb0(pc),a0
	moveq	#0,d0
	move.b	428(a4),d0
	tst.b	434(a4)
	bne.s	isrnd9
	addq.w	#1,456(a4)
	move.w	2(a0,d0.w*4),d1
	move.w	456(a4),d2
	cmp.w	d1,d2
	ble.s	nscont1
	move.w	0(a0,d0.w*4),456(a4)
	bra.s	nscont1
isrnd9	move.w	0(a0,d0.w*4),456(a4)
	lea	sv0(pc),a0
	bsr	do_rnd
nscont1	move.w	456(a4),458(a4)
	move.b	#1,466(a4)
	clr.b	467(a4)
	rts

ss_l1	moveq	#0,d2
ss_l2	move.l	d2,d1
	mulu	#10,d1
	move.l	a5,a1
	move.w	#196,d0
	add.w	d1,d0
	move.w	d3,d1
	move.l	_GfxBase(pc),a6
	jsr	_LVOMove(a6)
	move.l	a2,a0
	moveq	#0,d0
	move.w	456(a4),d0
	mulu	#42,d0
	add.w	d2,d0
	add.l	d0,a0
	bsr	text_1
	moveq	#0,d1
	move.w	440(a4),d1
	tst.w	d1
	beq.s	ss_c1
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
ss_c1	addq.b	#1,d2
	cmp.b	#42,d2
	blt.s	ss_l2
	rts

show_words
	tst.b	422(a4)
	beq.s	sw_c1
	move.w	#80,d3
	move.l	wdnmem(pc),a2
	bsr	show_naj
	tst.b	423(a4)
	beq.s	sw_c1
	moveq	#0,d1
	move.w	444(a4),d1
	tst.w	d1
	beq.s	sw_c1
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
sw_c1	tst.b	423(a4)
	beq.s	sw_c2
	move.w	#99,d3
	move.l	wfnmem(pc),a2
	bsr	show_naj
sw_c2	tst.b	422(a4)
	beq.s	sw_c3
	tst.b	423(a4)
	beq.s	sw_c3
	tst.b	454(a4)
	beq.s	sw_c3
	moveq	#0,d1
	move.w	438(a4),d1
	tst.w	d1
	beq.s	sw_c3
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
sw_c3	tst.b	424(a4)
	beq.s	sw_c4
	move.w	#118,d3
	move.l	wdjmem(pc),a2
	bsr	show_naj
	tst.b	425(a4)
	beq.s	sw_c4
	moveq	#0,d1
	move.w	444(a4),d1
	tst.w	d1
	beq.s	sw_c4
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
sw_c4	tst.b	425(a4)
	beq.s	sw_c5
	move.w	#137,d3
	move.l	wfjmem(pc),a2
	bsr	show_naj
sw_c5	tst.b	424(a4)
	beq.s	sw_c6
	tst.b	425(a4)
	beq.s	sw_c6
	tst.b	454(a4)
	beq.s	sw_c6
	moveq	#0,d1
	move.w	438(a4),d1
	tst.w	d1
	beq.s	sw_c6
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
sw_c6	tst.b	426(a4)
	beq.s	sw_c7
	move.w	#156,d3
	move.l	wdvmem(pc),a2
	bsr	show_naj
	tst.b	427(a4)
	beq.s	sw_c7
	moveq	#0,d1
	move.w	444(a4),d1
	tst.w	d1
	beq.s	sw_c7
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
sw_c7	tst.b	427(a4)
	beq.s	sw_c8
	move.w	#175,d3
	move.l	wfvmem(pc),a2
	bsr.s	show_naj
sw_c8	tst.b	426(a4)
	beq.s	sw_c9
	tst.b	427(a4)
	beq.s	sw_c9
	tst.b	454(a4)
	beq.s	sw_c9
	moveq	#0,d1
	move.w	438(a4),d1
	tst.w	d1
	beq.s	sw_c9
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
sw_c9	move.w	456(a4),460(a4)
	lea	wb0(pc),a0
	moveq	#0,d0
	move.b	428(a4),d0
	tst.b	434(a4)
	bne.s	sw_c11
	addq.w	#1,456(a4)
	move.w	2(a0,d0.w*4),d1
	move.w	456(a4),d2
	cmp.w	d1,d2
	ble.s	sw_c12
	move.w	0(a0,d0.w*4),456(a4)
	bra.s	sw_c12
sw_c11	move.w	0(a0,d0.w*4),456(a4)
	lea	wv0(pc),a0
	bsr	do_rnd
sw_c12	move.w	456(a4),458(a4)
	move.b	#1,466(a4)
	clr.b	467(a4)
	rts

show_naj
	move.l	_GfxBase(pc),a6
	bsr	pen_a4
	bsr	pen_b14
	tst.b	431(a4)
	beq.s	sw_off0
	tst.b	432(a4)
	beq.s	sn_off0
	bsr.s	sn_l1
	bra.s	sn_c5
sn_off0	bsr	sn_l3
	bra.s	sn_c5
sw_off0	tst.b	432(a4)
	beq.s	sn_off1
	bsr	ss_l1
	bra.s	sn_c5
sn_off1	move.w	d3,d1
	bsr	bas_pos
	move.l	a2,a0
	bsr	bas_txt
sn_c5	move.l	_GfxBase(pc),a6
	rts

sn_l1	moveq	#0,d2
	moveq	#1,d4
sn_l2	move.l	d2,d1
	mulu	#10,d1
	move.l	a5,a1
	move.w	#196,d0
	add.w	d1,d0
	move.w	d3,d1
	move.l	_GfxBase(pc),a6
	jsr	_LVOMove(a6)
	move.l	a2,a0
	moveq	#0,d0
	move.w	456(a4),d0
	mulu	#42,d0
	add.w	d2,d0
	add.l	d0,a0
	move.l	a0,a3
	bsr	text_1
	moveq	#0,d1
	move.w	440(a4),d1
	tst.w	d1
	beq.s	sn_c0
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
sn_c0	addq.b	#1,d2
	move.l	d4,d0
	mulu	#14,d0
	cmp.b	d0,d2
	blt.s	sn_l2
	addq.b	#1,d4
	cmp.b	#4,d4
	bge.s	sn_c2
	moveq	#0,d1
	move.w	442(a4),d1
	tst.w	d1
	beq.s	sn_c1
	cmp.b	#32,1(a3)
	ble.s	sn_c1
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
sn_c1	bra.s	sn_l2
sn_c2	rts

sn_l3	moveq	#0,d2
	moveq	#0,d4
sn_l4	move.l	d2,d1
	mulu	#140,d1
	move.l	a5,a1
	move.w	#196,d0
	add.w	d1,d0
	move.w	d3,d1
	move.l	_GfxBase(pc),a6
	jsr	_LVOMove(a6)
	move.l	a2,a0
	moveq	#0,d0
	move.w	456(a4),d0
	mulu	#42,d0
	add.l	d0,a0
	add.l	d4,a0
	move.l	a0,a3
	bsr	text_13
	moveq	#0,d1
	move.w	442(a4),d1
	tst.w	d1
	beq.s	sn_c3
	cmp.b	#32,1(a3)
	ble.s	sn_c3
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)
sn_c3	addq.b	#1,d2
	cmp.b	#3,d2
	bge.s	sn_c4
	add.b	#14,d4
	bra.s	sn_l4
sn_c4	rts

reveal_words
	move.l	_GfxBase(pc),a6
	bsr	pen_a4
	bsr	pen_b14
	move.w	460(a4),456(a4)
	tst.b	422(a4)
	bne.s	rw_c0
	tst.b	423(a4)
	beq.s	rw_c0
	move.w	#80,d3
	move.l	wdnmem(pc),a2
	bsr	show_naj
rw_c0	bsr	pen_a6
	tst.b	422(a4)
	beq.s	rw_c1
	tst.b	423(a4)
	bne.s	rw_c1
	move.w	#99,d3
	move.l	wfnmem(pc),a2
	bsr	show_naj
rw_c1	bsr	pen_a4
	tst.b	424(a4)
	bne.s	rw_c2
	tst.b	425(a4)
	beq.s	rw_c2
	move.w	#118,d3
	move.l	wdjmem(pc),a2
	bsr	show_naj
rw_c2	bsr	pen_a6
	tst.b	424(a4)
	beq.s	rw_c3
	tst.b	425(a4)
	bne.s	rw_c3
	move.w	#137,d3
	move.l	wfjmem(pc),a2
	bsr	show_naj
rw_c3	bsr	pen_a4
	tst.b	426(a4)
	bne.s	rw_c4
	tst.b	427(a4)
	beq.s	rw_c4
	move.w	#156,d3
	move.l	wdvmem(pc),a2
	bsr	show_naj
rw_c4	bsr	pen_a6
	tst.b	426(a4)
	beq.s	rw_c5
	tst.b	427(a4)
	bne.s	rw_c5
	move.w	#175,d3
	move.l	wfvmem(pc),a2
	bsr	show_naj
rw_c5	move.w	458(a4),456(a4)
	move.b	#2,466(a4)
	rts

reveal_sents
	move.l	_GfxBase(pc),a6
	bsr	pen_a4
	bsr	pen_b14
	move.w	460(a4),456(a4)
	tst.b	420(a4)
	bne.s	rs_c0
	tst.b	421(a4)
	beq.s	rs_c0
	tst.b	432(a4)
	beq.s	rs_off0
	move.w	#14,d3
	move.l	dfsmem(pc),a2
	bsr	ss_l1
	move.w	#26,d3
	move.l	dssmem(pc),a2
	bsr	ss_l1
	bra.s	rs_c0
rs_off0	move.w	#14,d1
	bsr	bas_pos
	move.l	dfsmem(pc),a0
	bsr	bas_txt
	move.w	#26,d1
	bsr	bas_pos
	move.l	dssmem(pc),a0
	bsr	bas_txt
rs_c0	move.l	_GfxBase(pc),a6
	bsr	pen_a6
	tst.b	420(a4)
	beq.s	rs_c1
	tst.b	421(a4)
	bne.s	rs_c1
	tst.b	432(a4)
	beq.s	rs_off1
	move.w	#47,d3
	move.l	ffsmem(pc),a2
	bsr	ss_l1
	move.w	#59,d3
	move.l	fssmem(pc),a2
	bsr	ss_l1
	bra.s	rs_c1
rs_off1	move.w	#47,d1
	bsr	bas_pos
	move.l	ffsmem(pc),a0
	bsr	bas_txt
	move.w	#59,d1
	bsr	bas_pos
	move.l	fssmem(pc),a0
	bsr	bas_txt
rs_c1	move.w	458(a4),456(a4)
	move.b	#2,466(a4)
	rts

wordsbf	move.l	_GfxBase(pc),a6
	bsr	pen_a4
	bsr	pen_b14
	move.w	#80,d1
	bsr	bas_pos
	move.l	wdnmem(pc),a0
	bsr	bas_txt
	bsr	pen_a6
	move.w	#99,d1
	bsr	bas_pos
	move.l	wfnmem(pc),a0
	bsr	bas_txt
	bsr	pen_a4
	move.w	#118,d1
	bsr	bas_pos
	move.l	wdjmem(pc),a0
	bsr	bas_txt
	bsr	pen_a6
	move.w	#137,d1
	bsr	bas_pos
	move.l	wfjmem(pc),a0
	bsr	bas_txt
	bsr	pen_a4
	move.w	#156,d1
	bsr	bas_pos
	move.l	wdvmem(pc),a0
	bsr	bas_txt
	bsr	pen_a6
	move.w	#175,d1
	bsr	bas_pos
	move.l	wfvmem(pc),a0
	bsr	bas_txt
	rts

sentsbf	move.l	_GfxBase(pc),a6
	bsr	pen_a4
	bsr	pen_b14
	move.w	#14,d1
	bsr	bas_pos
	move.l	dfsmem(pc),a0
	bsr	bas_txt
	move.w	#26,d1
	bsr	bas_pos
	move.l	dssmem(pc),a0
	bsr	bas_txt
	bsr	pen_a6
	move.w	#47,d1
	bsr	bas_pos
	move.l	ffsmem(pc),a0
	bsr	bas_txt
	move.w	#59,d1
	bsr	bas_pos
	move.l	fssmem(pc),a0
	bsr	bas_txt
	rts

update_seq
	moveq	#0,d0
	move.b	428(a4),d0
	lea	sb0(pc),a1
	lea	sv0(pc),a0
	tst.b	430(a4)
	bne.s	uds_c0
	lea	wb0(pc),a1
	lea	wv0(pc),a0
uds_c0	move.w	0(a1,d0.w*4),456(a4)
	tst.b	434(a4)
	beq.s	uds_end
	bsr	do_rnd
uds_end	rts

ec_ds	movem.l	d2-d5/a2-a6,-(a7)
	lea	sv0(pc),a4
	lea	sb0(pc),a3
	bsr	do_ecds
	tst.b	d0
	bne.s	ecds_e
	cmp.w	#22,d4
	bne.s	dse_22
	addq.l	#1,d7
	mulu	#42,d7
	move.l	d7,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,dfsmem
	beq.s	no_dfs
	lea	filesizes(pc),a0
	move.l	d7,(a0)
	move.l	d7,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,dssmem
	beq.s	no_dss
	lea	filesizes(pc),a0
	move.l	d7,4(a0)
	move.l	dfsmem(pc),a5
	move.l	dssmem(pc),a4
	bsr	do_ecfs
	bra.s	ecds_e
no_dss	moveq	#1,d0
	bra.s	ecds_e
no_dfs	moveq	#1,d0
	bra.s	ecds_e
dse_22	moveq	#14,d0
ecds_e	movem.l	(a7)+,d2-d5/a2-a6
	rts

ec_fs	movem.l	d2-d5/a2-a6,-(a7)
	lea	sv0(pc),a4
	lea	sb0(pc),a3
	bsr.s	do_ecds
	tst.b	d0
	bne.s	ecfs_e
	cmp.w	#22,d4
	bne.s	fse_22
	addq.l	#1,d7
	mulu	#42,d7
	move.l	d7,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,ffsmem
	beq.s	no_ffs
	lea	filesizes(pc),a0
	move.l	d7,8(a0)
	move.l	d7,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,fssmem
	beq.s	no_fss
	lea	filesizes(pc),a0
	move.l	d7,12(a0)
	move.l	ffsmem(pc),a5
	move.l	fssmem(pc),a4
	bsr.s	do_ecfs
	bra.s	ecfs_e
no_fss	moveq	#1,d0
	bra.s	ecfs_e
no_ffs	moveq	#1,d0
	bra.s	ecfs_e
fse_22	moveq	#14,d0
ecfs_e	movem.l	(a7)+,d2-d5/a2-a6
	rts

do_ecds	move.l	memptr(pc),a5
	moveq	#0,d5			; file position
	moveq	#0,d4			; counter
	moveq	#1,d3			; category values counter
	moveq	#0,d7			; value counter
ecds_l	cmp.b	#64,0(a5,d5.l)		; check for @
	bne.s	dse_64
	bsr	stg2la5			; get category length
        tst.w	d0
        ble.s	dse_0
        cmp.w	#1500,d0
        bgt.s	dse_0
	move.w	d0,0(a4,d4.w*2)		; sv = c.l 
	move.w	d3,0(a3,d4.w*4)		; sb = start value for this category
	add.w	d0,d3
	subq.w	#1,d3
	move.w	d3,2(a3,d4.w*4)		; sb = end value for this category
	moveq	#0,d1
	move.w	d0,d1
	mulu	#86,d1
	addq.l	#8,d5
	add.l	d1,d5			; position now past all sentences
	add.w	d0,d7			; overall (all categories) total
	addq.w	#1,d3
	addq.w	#1,d4
	cmp.w	#22,d4
	bge.s	dse_ok
	move.l	fl,d0
	cmp.l	d0,d5
	blt.s	ecds_l
	bra.s	dse_ok
dse_64	moveq	#15,d0
	bra.s	ds_end
dse_0	moveq	#13,d0
	bra.s	ds_end
dse_ok	moveq	#0,d0
ds_end	rts

do_ecfs	moveq	#0,d5			; file position
	moveq	#42,d4			; counter
	move.l	memptr(pc),a6
ecfs_l1	cmp.b	#64,0(a6,d5.l)
	bne.s	fse_64
	addq.l	#6,d5
ecfs_l3	moveq	#0,d0
ecfs_l2	lea	0(a6,d5.l),a0
	add.l	d0,a0
	lea	43(a6,d5.l),a1
	add.l	d0,a1
	lea	0(a5,d4.l),a2
	add.l	d0,a2
	lea	0(a4,d4.l),a3
	add.l	d0,a3
	move.b	(a0),(a2)
	move.b	(a1),(a3)
	addq.b	#1,d0
	cmp.b	#42,d0
	blt.s	ecfs_l2
	add.l	#86,d5
	add.l	#42,d4
	cmp.b	#42,0(a6,d5.l)
	bne.s	ecfs_l3
	addq.l	#2,d5
	move.l	fl,d0
	cmp.l	d0,d5
	blt.s	ecfs_l1
	moveq	#0,d0
	bra.s	ecdf_e
fse_64	moveq	#15,d0
ecdf_e	rts

ec_dn	movem.l	d2-d5/a2-a6,-(a7)
	lea	wv0(pc),a4
	lea	wb0(pc),a3
	bsr	do_ecdn
	tst.b	d0
	bne.s	ecdn_e
	cmp.w	#22,d4
	bne.s	dne_22
	addq.l	#1,d7
	mulu	#42,d7
	move.l	d7,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,wdnmem
	beq.s	no_wdn
	lea	filesizes(pc),a0
	move.l	d7,16(a0)
	move.l	wdnmem(pc),a5
	bsr	do_ecfn
	bra.s	ecdn_e
no_wdn	moveq	#1,d0
	bra.s	ecdn_e
dne_22	moveq	#14,d0
ecdn_e	movem.l	(a7)+,d2-d5/a2-a6
	rts

ec_fn	movem.l	d2-d5/a2-a6,-(a7)
	lea	wv1(pc),a4
	lea	wb1(pc),a3
	bsr	do_ecdn
	tst.b	d0
	bne.s	ecfn_e
	cmp.w	#22,d4
	bne.s	fne_22
	addq.l	#1,d7
	mulu	#42,d7
	move.l	d7,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,wfnmem
	beq.s	no_wfn
	lea	filesizes(pc),a0
	move.l	d7,20(a0)
	move.l	wfnmem(pc),a5
	bsr	do_ecfn
	bra.s	ecfn_e
no_wfn	moveq	#1,d0
	bra.s	ecfn_e
fne_22	moveq	#14,d0
ecfn_e	movem.l	(a7)+,d2-d5/a2-a6
	rts

ec_dj	movem.l	d2-d5/a2-a6,-(a7)
	lea	wv2(pc),a4
	lea	wb2(pc),a3
	bsr	do_ecdn
	tst.b	d0
	bne.s	ecdj_e
	cmp.w	#22,d4
	bne.s	dje_22
	addq.l	#1,d7
	mulu	#42,d7
	move.l	d7,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,wdjmem
	beq.s	no_wdj
	lea	filesizes(pc),a0
	move.l	d7,24(a0)
	move.l	wdjmem(pc),a5
	bsr	do_ecfn
	bra.s	ecdj_e
no_wdj	moveq	#1,d0
	bra.s	ecdj_e
dje_22	moveq	#14,d0
ecdj_e	movem.l	(a7)+,d2-d5/a2-a6
	rts

ec_fj	movem.l	d2-d5/a2-a6,-(a7)
	lea	wv3(pc),a4
	lea	wb3(pc),a3
	bsr	do_ecdn
	tst.b	d0
	bne.s	ecfj_e
	cmp.w	#22,d4
	bne.s	fje_22
	addq.l	#1,d7
	mulu	#42,d7
	move.l	d7,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,wfjmem
	beq.s	no_wfj
	lea	filesizes(pc),a0
	move.l	d7,28(a0)
	move.l	wfjmem(pc),a5
	bsr	do_ecfn
	bra.s	ecfj_e
no_wfj	moveq	#1,d0
	bra.s	ecfj_e
fje_22	moveq	#14,d0
ecfj_e	movem.l	(a7)+,d2-d5/a2-a6
	rts

ec_dv	movem.l	d2-d5/a2-a6,-(a7)
	lea	wv4(pc),a4
	lea	wb4(pc),a3
	bsr	do_ecdn
	tst.b	d0
	bne.s	ecdv_e
	cmp.w	#22,d4
	bne.s	dve_22
	addq.l	#1,d7
	mulu	#42,d7
	move.l	d7,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,wdvmem
	beq.s	no_wdv
	lea	filesizes(pc),a0
	move.l	d7,32(a0)
	move.l	wdvmem(pc),a5
	bsr	do_ecfn
	bra.s	ecdv_e
no_wdv	moveq	#1,d0
	bra.s	ecdv_e
dve_22	moveq	#14,d0
ecdv_e	movem.l	(a7)+,d2-d5/a2-a6
	rts

ec_fv	movem.l	d2-d5/a2-a6,-(a7)
	lea	wv5(pc),a4
	lea	wb5(pc),a3
	bsr	do_ecdn
	tst.b	d0
	bne.s	ecfv_e
	cmp.w	#22,d4
	bne.s	fve_22
	addq.l	#1,d7
	mulu	#42,d7
	move.l	d7,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,wfvmem
	beq.s	no_wfv
	lea	filesizes(pc),a0
	move.l	d7,36(a0)
	move.l	wfvmem(pc),a5
	bsr	do_ecfn
	bra.s	ecfv_e
no_wfv	moveq	#1,d0
	bra.s	ecfv_e
fve_22	moveq	#14,d0
ecfv_e	movem.l	(a7)+,d2-d5/a2-a6
	rts

ec_fnsp	movem.l	d2-d5/a2-a6,-(a7)
	move.l	#37500,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,nywmem
	beq.s	no_nyw
	move.l	#75000,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,nyamem
	beq.s	no_nya
	bsr.s	do_rsfn
	tst.b	d6
	bne.s	free_ny
	bsr.s	do_rvfn
	tst.b	d6
	bne.s	free_ny
	bra.s	ecfnsp
free_ny	bsr.s	freenyw
	bsr.s	freenya
	bra.s	ecfnsp
no_nya	bsr.s	freenyw
no_nyw	moveq	#1,d6
ecfnsp	movem.l	(a7)+,d2-d5/a2-a6
	rts

freenyw	move.l	nywmem(pc),a1
	tst.l	a1
	beq.s	fnyw_e
	move.l	#37500,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	move.l	#0,nywmem
fnyw_e	rts

freenya	move.l	nyamem(pc),a1
	tst.l	a1
	beq.s	fnya_e
	move.l	#75000,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	move.l	#0,nyamem
fnya_e	rts

do_rsfn	bsr	get_slv
	tst.b	d6
	bne.s	rsfn_f
	move.w	d2,448(a4)
	move.l	nywmem(pc),a1
	lea	nylmem(pc),a0
	bsr	get_slb
rsfn_f	rts

do_rvfn	moveq	#0,d4
	clr.b	d3			; 25 loops counter
	cmp.b	#35,0(a3,d5.l)
	beq.s	ptw_ok
	cmp.b	#37,0(a3,d5.l)
	bne.s	rvfn_ok
ptw_ok	bsr	stg2la3
        tst.w	d0
        ble.s	rvfn_0
        cmp.w	#1500,d0
        bgt.s	rvfn_0
	move.w	d0,d4
	subq.w	#1,d4
	lea	nynmem(pc),a0
	move.b	#1,0(a0,d4.l)		; switch on syllable line number
	lea	ptwmem(pc),a0
	cmp.b	#37,0(a3,d5.l)
	beq.s	ptw37
	clr.b	0(a0,d4.l)		; switch off if # (narrator only)
	bra.s	ptw_end
ptw37	move.b	#1,0(a0,d4.l)		; switch on if % (translator only)
ptw_end	addq.l	#6,d5			; advance to syllable line values
	mulu	#50,d4
rvfn_l5	cmp.b	#42,0(a3,d5.l)		; is s.l.v a *
	beq.s	char_42			; yes
	bsr	stg2la1
        tst.w	d0			; test if s.l.v is out of range
        ble.s	rvfn_0
        cmp.w	#1500,d0
        bgt.s	rvfn_0
	move.w	462(a4),d1
	cmp.w	d1,d0			; is s.l.v out of wb total range?
	bgt.s	rvfn_17			; yes - error
	move.l	nyamem(pc),a0
	move.w	d0,0(a0,d4.l)
	addq.l	#4,d5
	addq.l	#2,d4
	addq.b	#1,d3
	cmp.b	#25,d3
	blt.s	rvfn_l5
char_42	addq.l	#2,d5
	bra	do_rvfn
rvfn_0	moveq	#13,d6
	bra.s	rvfn_f
rvfn_17	moveq	#17,d6
	bra.s	rvfn_f
rvfn_16	moveq	#16,d6
	bra.s	rvfn_f
rvfn_ok	moveq	#0,d6
rvfn_f	rts

get_slv	move.l	memptr(pc),a3
	moveq	#0,d5			; file position
	cmp.b	#64,0(a3,d5.l)
	bne.s	slv_64
	bsr	stg2la3
        tst.w	d0
        ble.s	slv_0
        cmp.w	#1500,d0
        bgt.s	slv_0
	move.w	d0,d2			; #syllable lines
	moveq	#6,d5
	moveq	#0,d6
	bra.s	slv_end
slv_0	moveq	#13,d6
	bra.s	slv_end
slv_64	moveq	#15,d6
slv_end	rts

get_slb	moveq	#0,d4			; s.l counter
rsfs_l1	moveq	#0,d3			; 25 loops counter
rsfs_l2	move.b	0(a3,d5.l),d0
	cmp.b	#10,d0
	beq.s	char_10
	cmp.b	#32,d0
	blt.s	rsfs_32
	move.b	d0,0(a1,d3.l)		; nyw - bytes in syllable word
	addq.l	#1,d5
	addq.l	#1,d3
	cmp.l	#25,d3
	blt.s	rsfs_l2
char_10	move.b	d3,0(a0,d4.l)		; nyl - length of syllable word
	lea	25(a1),a1
	addq.l	#1,d5
	addq.l	#1,d4
	cmp.w	d2,d4
	blt.s	rsfs_l1
	addq.l	#2,d5
	moveq	#0,d6
	bra.s	slb_end
rsfs_32	moveq	#12,d6
slb_end	rts

ec_fssp	movem.l	d2-d5/a2-a6,-(a7)
	move.l	#37500,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,sywmem
	beq.s	no_syw
	move.l	#75000,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,syamem
	beq.s	no_sya
	bsr.s	do_rsfs
	tst.b	d6
	bne.s	free_yn
	bsr.s	do_rvfs
	tst.b	d6
	bne.s	free_yn
	bra.s	ecfssp
free_yn	bsr.s	freesyw
	bsr.s	freesya
	bra.s	ecfssp
no_sya	bsr.s	freesyw
no_syw	moveq	#1,d6
ecfssp	movem.l	(a7)+,d2-d5/a2-a6
	rts

freesyw	move.l	sywmem(pc),a1
	tst.l	a1
	beq.s	fsyw_e
	move.l	#37500,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	move.l	#0,sywmem
fsyw_e	rts

freesya	move.l	syamem(pc),a1
	tst.l	a1
	beq.s	fsya_e
	move.l	#75000,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	move.l	#0,syamem
fsya_e	rts

do_rsfs	bsr	get_slv
	tst.w	d6
	bne.s	rsfs_f
	move.w	d2,450(a4)
	move.l	sywmem(pc),a1
	lea	sylmem(pc),a0
	bsr	get_slb
rsfs_f	rts

do_rvfs	moveq	#0,d4
	clr.b	d3			; 25 loops counter
	cmp.b	#35,0(a3,d5.l)
	beq.s	pts_ok
	cmp.b	#37,0(a3,d5.l)
	bne.s	rvfs_ok
pts_ok	bsr	stg2la3
        tst.w	d0
        ble.s	rvfs_0
        cmp.w	#1500,d0
        bgt.s	rvfs_0
	move.w	d0,d4
	subq.w	#1,d4
	lea	synmem(pc),a0
	move.b	#1,0(a0,d4.l)		; switch on syllable line number
	lea	ptsmem(pc),a0
	cmp.b	#37,0(a3,d5.l)
	beq.s	pts37
	clr.b	0(a0,d4.l)		; switch off if # (narrator only)
	bra.s	pts_end
pts37	move.b	#1,0(a0,d4.l)		; switch on if % (translator only)
pts_end	addq.l	#6,d5			; advance to syllable line values
	mulu	#50,d4
rvfs_l5	cmp.b	#42,0(a3,d5.l)		; is s.l.v a *
	beq.s	chr_42			; yes
	bsr	stg2la1
        tst.w	d0			; test if s.l.v is out of range
        ble.s	rvfs_0
        cmp.w	#1500,d0
        bgt.s	rvfs_0
	move.w	464(a4),d1
	cmp.w	d1,d0			; is s.l.v out of wb total range?
	bgt.s	rvfs_17			; yes - error
	move.l	syamem(pc),a0
	move.w	d0,0(a0,d4.l)
	addq.l	#4,d5
	addq.l	#2,d4
	addq.b	#1,d3
	cmp.b	#25,d3
	blt.s	rvfs_l5
chr_42	addq.l	#2,d5
	bra	do_rvfs
rvfs_0	moveq	#13,d6
	bra.s	rvfs_f
rvfs_17	moveq	#17,d6
	bra.s	rvfs_f
rvfs_16	moveq	#16,d6
	bra.s	rvfs_f
rvfs_ok	moveq	#0,d6
rvfs_f	rts

do_ecdn	move.l	memptr(pc),a5
	moveq	#0,d5			; file position
	moveq	#0,d4			; counter
	moveq	#1,d3			; nu value
	moveq	#0,d7			; value counter
ecdn_l	cmp.b	#64,0(a5,d5.l)
	bne.s	dne_64
	bsr	stg2la5
        tst.w	d0
        ble.s	dne_0
        cmp.w	#1500,d0
        bgt.s	dne_0
	move.w	d0,0(a4,d4.w*2)
	move.w	d3,0(a3,d4.w*4)
	add.w	d0,d3
	subq.w	#1,d3
	move.w	d3,2(a3,d4.w*4)
	moveq	#0,d1
	move.w	d0,d1
	mulu	#43,d1
	addq.l	#8,d5
	add.l	d1,d5
	add.w	d0,d7
	addq.w	#1,d3
	addq.w	#1,d4
	cmp.w	#22,d4
	bge.s	dne_ok
	move.l	fl,d0
	cmp.l	d0,d5
	blt.s	ecdn_l
	bra.s	dne_ok
dne_64	moveq	#15,d0
	bra.s	dn_end
dne_0	moveq	#13,d0
	bra.s	dn_end
dne_ok	moveq	#0,d0
dn_end	rts

do_ecfn	moveq	#0,d5			; file position
	moveq	#42,d4			; counter
	move.l	memptr(pc),a6
ecdn_l1	cmp.b	#64,0(a6,d5.l)
	bne.s	fne_64
	addq.l	#6,d5
ecdn_l3	moveq	#0,d0
ecdn_l2	lea	0(a6,d5.l),a0
	add.l	d0,a0
	lea	0(a5,d4.l),a1
	add.l	d0,a1
	move.b	(a0),(a1)
	addq.b	#1,d0
	cmp.b	#42,d0
	blt.s	ecdn_l2
	add.l	#43,d5
	add.l	#42,d4
	cmp.b	#42,0(a6,d5.l)
	bne.s	ecdn_l3
	addq.l	#2,d5
	move.l	fl,d0
	cmp.l	d0,d5
	blt.s	ecdn_l1
	moveq	#0,d0
	bra.s	ecw_e
fne_64	moveq	#15,d0
ecw_e	rts

do_rnd	move.w	0(a0,d0.w*2),d3
	move.w	456(a4),d2
	add.w	d2,d3
	subq.w	#1,d3
	bsr.s	rndnum
	add.w	d0,d2
	cmp.w	456(a4),d2
	blt.s	drn_end
	cmp.w	d3,d2
	bgt.s	drn_end
	move.w	d2,456(a4)
drn_end	rts

rndnum	move.l	seed,d0
	clr.b	count
rnd_l1	jsr	_RangeRand
	and.l	#$000000FF,d0		; Make seed a byte value.
	move.l	d0,seed			; Move the byte value into Seed.
	move.w	d2,d0			; Work out the range that Seed has
	move.w	d3,d1			; to be within.
	sub.w	d0,d1
	move.l	seed,d0
	addq.b	#1,count
	cmp.b	#40,count
	bge.s	rnd_0
	tst.w	d0
	blt.s	rnd_l1
	cmp.w	d1,d0
	bgt.s	rnd_l1
	bra.s	rnd_end
rnd_0	moveq	#0,d0
rnd_end	clr.b	count
	rts

bas_pos	move.l	a5,a1
	move.w	#196,d0
	move.l	_GfxBase(pc),a6
	jsr	_LVOMove(a6)
	rts

bas_txt	moveq	#0,d0
	move.w	456(a4),d0
	mulu	#42,d0
	add.l	d0,a0
	bsr	text_42
	rts

search_words
	tst.b	452(a4)
	bne.s	forw
	cmp.b	#2,453(a4)
	beq.s	forw2
	cmp.b	#3,453(a4)
	beq.s	forw3
	move.l	wdnmem(pc),a1
	bra.s	forw_c
forw2	move.l	wdjmem(pc),a1
	bra.s	forw_c
forw3	move.l	wdvmem(pc),a1
forw_c	move.l	a1,a3
	add.l	d7,a3
	add.l	d5,a1
	move.l	a1,a2
	bsr	find_it
	tst.b	d1
	bne.s	ffw_e
	bsr	unfound
	bra.s	ffw_e
forw	cmp.b	#2,453(a4)
	beq.s	forw4
	cmp.b	#3,453(a4)
	beq.s	forw5
	move.l	wfnmem(pc),a1
	bra.s	forw_c1
forw4	move.l	wfjmem(pc),a1
	bra.s	forw_c1
forw5	move.l	wfvmem(pc),a1
forw_c1	move.l	a1,a3
	add.l	d7,a3
	add.l	d5,a1
	move.l	a1,a2
	bsr	find_it
	tst.b	d1
	bne.s	ffw_e
	bsr	unfound
ffw_e	rts

show_1	move.l	_GfxBase(pc),a6
	bsr	pen_a4
	bsr	pen_b2
	move.w	#176,d0
        move.w	#80,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	move.l	wdnmem(pc),a0
	add.l	d5,a0
	add.l	d6,a0
	bsr	text_42
	bsr	pen_a6
	move.w	#176,d0
        move.w	#102,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l	wfnmem(pc),a0
	add.l	d5,a0
	add.l	d6,a0
	bsr	text_42
	rts

show_2	move.l	_GfxBase(pc),a6
	bsr	pen_a4
	bsr	pen_b2
	move.w	#176,d0
        move.w	#80,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	move.l	wdjmem(pc),a0
	add.l	d5,a0
	add.l	d6,a0
	bsr	text_42
	bsr	pen_a6
	move.w	#176,d0
        move.w	#102,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l	wfjmem(pc),a0
	add.l	d5,a0
	add.l	d6,a0
	bsr	text_42
	rts

show_3	move.l	_GfxBase(pc),a6
	bsr	pen_a4
	bsr	pen_b2
	move.w	#176,d0
        move.w	#80,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	move.l	wdvmem(pc),a0
	add.l	d5,a0
	add.l	d6,a0
	bsr	text_42
	bsr	pen_a6
	move.w	#176,d0
        move.w	#102,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l	wfvmem(pc),a0
	add.l	d5,a0
	add.l	d6,a0
	bsr	text_42
	rts

show_st	move.l	_GfxBase(pc),a6
	bsr	pen_a4
	bsr	pen_b2
	move.w	#176,d0
        move.w	#80,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	move.l	dfsmem(pc),a0
	add.l	d5,a0
	add.l	d6,a0
	bsr	text_42
	move.w	#176,d0
        move.w	#91,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l	dssmem(pc),a0
	add.l	d5,a0
	add.l	d6,a0
	bsr	text_42
	bsr	pen_a6
	move.w	#176,d0
        move.w	#102,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l	ffsmem(pc),a0
	add.l	d5,a0
	add.l	d6,a0
	bsr	text_42
	move.w	#176,d0
        move.w	#113,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        move.l	fssmem(pc),a0
	add.l	d5,a0
	add.l	d6,a0
	bsr	text_42
	rts

find_it	lea	searchb(pc),a0
	bsr	instg_f
	tst.b	d1
	beq.s	fi_end
	lea	searchb(pc),a1
	bsr	instg_c
	cmp.w	d4,d2
	blt.s	find_it
	tst.b	453(a4)
	beq.s	fi_0
	cmp.b	#1,453(a4)
	beq.s	fi_1
	cmp.b	#2,453(a4)
	beq.s	fi_2
	bra.s	fi_3
fi_0	bsr	show_st
	bra.s	fi_poke
fi_1	bsr	show_1
	bra.s	fi_poke
fi_2	bsr	show_2
	bra.s	fi_poke
fi_3	bsr	show_3
fi_poke	moveq	#1,d1
fi_end	rts

unfound	move.l	_GfxBase(pc),a6
	bsr	pen_a3
	bsr	pen_b2
	move.w	#360,d0
        move.w	#57,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     pmt57(pc),a0
	bsr	text_25
	rts

search_sents
	tst.b	452(a4)
	bne.s	fors
	move.l	dfsmem(pc),a1
	move.l	a1,a3
	add.l	d7,a3
	add.l	d5,a1
	move.l	a1,a2
	bsr	find_it
	tst.b	d1
	bne.s	ffs_e
	move.l	dssmem(pc),a1
	move.l	a1,a3
	add.l	d7,a3
	add.l	d5,a1
	move.l	a1,a2
	bsr	find_it
	tst.b	d1
	bne.s	ffs_e
	bsr.s	unfound
	bra.s	ffs_e
fors	move.l	ffsmem(pc),a1
	move.l	a1,a3
	add.l	d7,a3
	add.l	d5,a1
	move.l	a1,a2
	bsr	find_it
	tst.b	d1
	bne.s	ffs_e
	move.l	fssmem(pc),a1
	move.l	a1,a3
	add.l	d7,a3
	add.l	d5,a1
	move.l	a1,a2
	bsr	find_it
	tst.b	d1
	bne.s	ffs_e
	bsr.s	unfound
ffs_e	rts

 * find the first character of `search string' within memory string.
 *
 * return values: a0 start address of found character within memory string.
 *                a1 start address of memory string.
 *                d0 length (byte distance) between a0 and a1.
 *                d1 0=character not found and 1=character found.

instg_f	move.b  (a0),d0
	move.l	a1,a0
instg_0	move.b  (a0)+,d1
	tst.b   d1
        beq.s   equ_0
	cmp.b   d0,d1
        bne.s   instg_0
	subq.l	#1,a0
	move.l	a0,d0
	move.l	a2,d1
	sub.l	d1,d0
	move.l	d0,d6
	divu	#42,d6
	and.l	#$0000FFFF,d6
	mulu	#42,d6
	moveq	#1,d1
	bra.s	instg_e
equ_0	moveq	#0,d1
instg_e	rts


 * find out how many characters match within the above memory string.
 *
 * return values: a1 start address of the first unmatched `search string'
 *                   character within memory string.
 *                d2 length (number) of characters that match.

instg_c	moveq	#0,d2
instg_1	move.b  (a0)+,d0
        move.b  (a1)+,d1
	addq.w	#1,d2
	tst.b   d1
        beq.s   end0
	cmp.b   d0,d1
        beq.s   instg_1
end0	subq.w	#1,d2
	subq.l	#1,a0
	move.l	a0,a1
	move.l	a1,474(a4)
	cmp.l	a3,a1
	blt.s	instg_r
	moveq	#0,d2
	move.b	#1,455(a4)
instg_r	rts

test_vowel
	tst.b	(a0)
	beq.s	vowel_0
	cmpi.b	#1,(a0)
	beq.s	vowel_1
	cmpi.b	#2,(a0)
	beq.s	vowel_2
	cmpi.b	#3,(a0)
	beq.s	vowel_3
	cmpi.b	#4,(a0)
	beq.s	vowel_4
	cmpi.b	#5,(a0)
	beq.s	vowel_5
	cmpi.b	#6,(a0)
	beq.s	vowel_6
	cmpi.b	#7,(a0)
	beq.s	vowel_7
	cmpi.b	#8,(a0)
	beq.s	vowel_8
	cmpi.b	#9,(a0)
	beq.s	vowel_9
	cmpi.b	#10,(a0)
	beq.s	vowel_10
	lea     vowel11(pc),a0
	bra.s	vowel_e
vowel_0	lea     vowel0(pc),a0
	bra.s	vowel_e
vowel_1	lea     vowel1(pc),a0
	bra.s	vowel_e
vowel_2	lea     vowel2(pc),a0
	bra.s	vowel_e
vowel_3	lea     vowel3(pc),a0
	bra.s	vowel_e
vowel_4	lea     vowel4(pc),a0
	bra.s	vowel_e
vowel_5	lea     vowel5(pc),a0
	bra.s	vowel_e
vowel_6	lea     vowel6(pc),a0
	bra.s	vowel_e
vowel_7	lea     vowel7(pc),a0
	bra.s	vowel_e
vowel_8	lea     vowel8(pc),a0
	bra.s	vowel_e
vowel_9	lea     vowel9(pc),a0
	bra.s	vowel_e
vowel_10
	lea     vowel10(pc),a0
vowel_e	rts

speakToMe
	clr.w	d6
	move.w	390(a4),d7
	lea	110(a4,d7.w),a0
	bsr	test_vowel
	move.l	a0,a6			; points to Vowel String.
	move.l	a5,-(a7)
	lea	402(a4),a5
	lea	160(a4),a3
	move.b	0(a3,d7.w),d6		; Number of Channels.
	lea	10(a3),a3		; points to Channel 1 Value.
	move.l	a3,a0
	lea	10(a3),a3		; points to Channel 2 Value.
	move.l	a3,a1
	lea	10(a3),a3		; points to Channel 3 Value.
	move.l	a3,a2
	lea	10(a3),a3		; points to Channel 4 Value.
	cmp.b	#49,d6
	beq.s	mask_1
	cmp.b	#50,d6
	beq.s	mask_2
	cmp.b	#51,d6
	beq.s	mask_3
	move.b	0(a0,d7.w),(a5)
	move.b	0(a1,d7.w),1(a5)
	move.b	0(a2,d7.w),2(a5)
	move.b	0(a3,d7.w),3(a5)
	bra.s	mask_e
mask_1	move.b	0(a0,d7.w),(a5)
	clr.b	1(a5)
	clr.b	2(a5)
	clr.b	3(a5)
	bra.s	mask_e
mask_2	move.b	0(a0,d7.w),(a5)
	move.b	0(a1,d7.w),1(a5)
	clr.b	2(a5)
	clr.b	3(a5)
	bra.s	mask_e
mask_3	move.b	0(a0,d7.w),(a5)
	move.b	0(a1,d7.w),1(a5)
	move.b	0(a2,d7.w),2(a5)
	clr.b	3(a5)
mask_e	move.l	a6,a3
	move.l	(a7)+,a5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,writeport
	beq	stm_end
	move.l	d0,a0
	moveq	#NDI_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,writeio
	beq	free_wport
	move.l	d0,a1
	move.b	#NDF_NEWIORB,NDI_FLAGS(a1)
	lea	nar_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	free_writeio
	move.l	writeio(pc),a1
	move.b	#NDF_NEWIORB,NDI_FLAGS(a1)
	tst.b	399(a4)
	bne.s	chk_ssf
	bset	#NDB_WORDSYNC,NDI_FLAGS(a1)
	bra.s	fill_io
chk_ssf	tst.b	398(a4)
	bne.s	fill_io
	bset	#NDB_SYLSYNC,NDI_FLAGS(a1)
fill_io	move.l	a3,NDI_CENTPHON(a1)
	lea	402(a4),a3
	move.l	a3,NDI_CHMASKS(a1)
	lea	0(a4,d7.w),a0
	cmp.b	#77,(a0)
	beq.s	sex_m
	move.b	#1,NDI_SEX+1(a1)
	bra.s	sex_end
sex_m	clr.b	NDI_SEX+1(a1)
sex_end	lea	10(a0),a0
	move.b	(a0),NDI_MODE+1(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_VOLUME+1(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_F0ENTHUSIASM(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_ARTICULATE(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_F0PERTURB(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_AVBIAS(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_AFBIAS(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_A1ADJ(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_A2ADJ(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_A3ADJ(a1)
	lea	20(a0),a0
	move.b	(a0),NDI_CENTRALIZE(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_F1ADJ(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_F2ADJ(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_F3ADJ(a1)
	lea	10(a0),a0
	move.b	(a0),NDI_NUMMASKS+1(a1)
	lea	210(a4),a0
	move.w	(a0,d7.w*2),NDI_PITCH(a1)
	lea	20(a0),a0
	move.w	0(a0,d7.w*2),NDI_RATE(a1)
	lea	20(a0),a0
	move.w	0(a0,d7.w*2),NDI_SAMPFREQ(a1)
	clr.b	NDI_MOUTHS(a1)
	move.b	401(a4),d0
	move.b	d0,NDI_PRIORITY(a1)
	clr.b	NDI_PAD1(a1)
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	lea	narb(pc),a0
	move.l	a0,IO_DATA(a1)
	move.l	#88,IO_LENGTH(a1)
	clr.b	d7
	moveq	#0,d2
	move.w	460(a4),d2	; osq
	subq.w	#1,d2		; osq-1
	moveq	#0,d3
	move.w	d2,d3
	mulu	#50,d3		; (osq-1)*50
	lea	synmem(pc),a0
	tst.b	430(a4)
	bne.s	stm_c0
	lea	nynmem(pc),a0
stm_c0	cmp.b	#1,0(a0,d2.l)
	bne	cl_dev
stm_c1	bsr	clrengb
	bsr	clrnarb
	moveq	#0,d4
	move.l	syamem(pc),a0
	tst.b	430(a4)
	bne.s	stm_c2
	move.l	nyamem(pc),a0
stm_c2	move.w	0(a0,d3.l),d4
	tst.w	d4
	ble	cl_dev
	tst.b	430(a4)
	bne.s	stm_c3
	cmp.w	448(a4),d4
	bgt	cl_dev
	bra.s	stm_c4
stm_c3	cmp.w	450(a4),d4
	bgt	cl_dev
stm_c4	subq.w	#1,d4
	lea	sylmem(pc),a0
	tst.b	430(a4)
	bne.s	stm_c5
	lea	nylmem(pc),a0
stm_c5	move.b	0(a0,d4.l),d5
	mulu	#25,d4
	move.l	sywmem(pc),a0
	tst.b	430(a4)
	bne.s	stm_c6
	move.l	nywmem(pc),a0
stm_c6	lea	engb(pc),a1
	clr.b	d0
stm_c7	move.b	0(a0,d4.l),(a1)+
	addq.l	#1,d4
	addq.b	#1,d0
	cmp.b	d5,d0
	blt.s	stm_c7
	lea	engb(pc),a0
	lea	narb(pc),a1
	lea	ptsmem(pc),a2
	tst.b	430(a4)
	bne.s	stm_c8
	lea	ptwmem(pc),a2
stm_c8	tst.b	0(a2,d2.l)
	beq.s	is_nar
	moveq	#42,d0
	moveq	#88,d1
	move.l	_TranslatorBase(pc),a6
	jsr	_LVOTranslate(a6)
	bra.s	speakit
is_nar	clr.b	d0
nar0	move.l	(a0)+,(a1)+
	addq.b	#4,d0
	cmp.b	#88,d0
	blt.s	nar0	
speakit	move.l	writeio(pc),a1
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
	addq.l	#2,d3
	addq.b	#1,d7
	cmp.b	#25,d7
	blt	stm_c1

cl_dev	move.l	writeio(pc),a1
	jsr	_LVOCloseDevice(a6)

free_writeio
	move.l	writeio(pc),a0
	jsr	_LVODeleteIORequest(a6)

free_wport
	move.l	writeport(pc),a0
	jsr	_LVODeleteMsgPort(a6)

stm_end	rts

clrengb	lea	engb(pc),a0
	bra.s	do_clr
clrnarb	lea	narb(pc),a0
do_clr	clr.b	d0
clrbuf	clr.l	(a0)+
	addq.b	#4,d0
	cmp.b	#88,d0
	blt.s	clrbuf
	rts

stg2la3	lea	bytebuf(pc),a0
	move.l	#0,(a0)
	move.b	1(a3,d5.l),(a0)
	move.b	2(a3,d5.l),1(a0)
	move.b	3(a3,d5.l),2(a0)
	move.b	4(a3,d5.l),3(a0)
	bra.s	do_stl
stg2la1	lea	bytebuf(pc),a0
	move.l	#0,(a0)
	move.b	0(a3,d5.l),(a0)
	move.b	1(a3,d5.l),1(a0)
	move.b	2(a3,d5.l),2(a0)
	move.b	3(a3,d5.l),3(a0)
	bra.s	do_stl
stg2la5	lea	bytebuf(pc),a0
	move.l	#0,(a0)
	move.b	1(a5,d5.l),(a0)
	move.b	2(a5,d5.l),1(a0)
	move.b	3(a5,d5.l),2(a0)
	move.b	4(a5,d5.l),3(a0)
do_stl	move.l  a0,d1
        move.l  #longval,d2
	move.l	_DOSBase(pc),a6
	jsr	_LVOStrToLong(a6)
        cmp.l	#TRUE,d0
        beq.s	stl_0
        and.l   #$0000FFFF,longval
	move.l	longval,d0
	bra.s	stl_end
stl_0	moveq	#0,d0
stl_end	rts

show_v	bsr	pen_a6
	bsr	pen_b2
	move.w	#373,d0
        move.w	#33,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea	270(a4),a0
	moveq	#0,d0
	move.w	390(a4),d0
	mulu	#12,d0
	lea	2(a0,d0.w),a0
        bsr	findlen
        tst.l   d0
        ble.s   blankv
	cmp.l	#11,d0
	bgt.s	blankv
	bsr	do_text
	bra.s	bv_end
blankv	lea     pmt54(pc),a0
	bsr	text_11
bv_end	rts


 * Structures/Definitions.

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

pens
	dc.l	-1

coltags
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0001,$0000,$0000,$0000
	dc.w	$0002,$0000,$0000,$0000
	dc.w	$0003,$0000,$0000,$0000
	dc.w	$0004,$0000,$0000,$0000
	dc.w	$0005,$0000,$0000,$0000
	dc.w	$0006,$0000,$0000,$0000
	dc.w	$0007,$0000,$0000,$0000
	dc.w	$0008,$0000,$0000,$0000
	dc.w	$0009,$0000,$0000,$0000
	dc.w	$000A,$0000,$0000,$0000
	dc.w	$000B,$0000,$0000,$0000
	dc.w	$000C,$0000,$0000,$0000
	dc.w	$000D,$0000,$0000,$0000
	dc.w	$000E,$0000,$0000,$0000
	dc.w	$000F,$0000,$0000,$0000
	dc.w	-1,0,0,0

image53
	dc.w	60,150,96,8,4
	dc.l	bd53
	dc.b	15,0
	dc.l	0


image52
	dc.w	60,112,128,8,4
	dc.l	bd52
	dc.b	15,0
	dc.l	0


image51
	dc.w	60,74,112,8,4
	dc.l	bd51
	dc.b	15,0
	dc.l	0


image50
	dc.w	60,8,112,8,4
	dc.l	bd50
	dc.b	15,0
	dc.l	0

image48
	dc.w	95,186,192,14,4
	dc.l	bd48
	dc.b	15,0
	dc.l	0

image49
	dc.w	479,186,160,14,4
	dc.l	bd49
	dc.b	15,0
	dc.l	0

image39
	dc.w	544,186,96,14,4
	dc.l	bd39
	dc.b	15,0
	dc.l	0

image38
	dc.w	401,186,64,14,4
	dc.l	bd38
	dc.b	15,0
	dc.l	0

image31
	dc.w	192,186,64,14,4
	dc.l	bd31
	dc.b	15,0
	dc.l	0

image30
	dc.w	0,186,192,14,4
	dc.l	bd30
	dc.b	15,0
	dc.l	0


image9
	dc.w	469,186,96,14,4
	dc.l	bd9
	dc.b	15,0
	dc.l	0

image8
	dc.w	469,186,96,14,4
	dc.l	bd8
	dc.b	15,0
	dc.l	0

image7
	dc.w	383,186,96,14,4
	dc.l	bd7
	dc.b	15,0
	dc.l	0

image6
	dc.w	383,186,96,14,4
	dc.l	bd6
	dc.b	15,0
	dc.l	0

image5
	dc.w	287,186,96,14,4
	dc.l	bd5
	dc.b	15,0
	dc.l	0

image4
	dc.w	287,186,96,14,4
	dc.l	bd4
	dc.b	15,0
	dc.l	0

image3
	dc.w	0,186,96,14,4
	dc.l	bd3
	dc.b	15,0
	dc.l	0

image2
	dc.w	0,186,96,14,4
	dc.l	bd2
	dc.b	15,0
	dc.l	0

image1
	dc.w	17,7,30,10,4
	dc.l	bd1
	dc.b	15,0
	dc.l	0

image0
	dc.w	17,7,30,10,4
	dc.l	bd0
	dc.b	15,0
	dc.l	0

coords5
	dc.w	0,0,85,0,85,13,0,13,0,1,1,1,1,13,84,13,84,1

border5
	dc.w	440,6
	dc.b	3,14,0,9
	dc.l	coords5,0

coords4
	dc.w	0,0,84,0,84,13,0,13,0,1,1,1,1,13,83,13,83,1

border4
	dc.w	336,6
	dc.b	3,14,0,9
	dc.l	coords4,0

coords3
	dc.w	0,0,105,0,105,13,0,13,0,1,1,1,1,13,104,13,104,1

border3
	dc.w	221,6
	dc.b	3,14,0,9
	dc.l	coords3,0

coords2
	dc.w	0,0,95,0,95,13,0,13,0,1,1,1,1,13,94,13,94,1

border2
	dc.w	116,6
	dc.b	3,14,0,9
	dc.l	coords2,0

coords1
	dc.w	0,0,94,0,94,13,0,13,0,1,1,1,1,13,93,13,93,1

border1
	dc.w	12,6
	dc.b	3,14,0,9
	dc.l	coords1,0

coords0
	dc.w	0,0,297,0,297,13,0,13,0,1,1,1,1,13,296,13,296,1

border0
	dc.w	14,5
	dc.b	3,2,0,9
	dc.l	coords0,0

scrn0tags
	dc.l	SA_Top,0
	dc.l	SA_Left,0
	dc.l	SA_Width,640
	dc.l	SA_Height,200
	dc.l	SA_Depth,4
	dc.l	SA_Pens,pens
	dc.l	SA_DetailPen,0
	dc.l	SA_BlockPen,1
	dc.l	SA_Title,scrn0title
	dc.l	SA_DisplayID,$8000
	dc.l	SA_Colors,coltags
	dc.l	SA_Type,CUSTOMSCREEN
	dc.l	SA_Font,topaz9
	dc.l	SA_Quiet,TRUE
	dc.l	TAG_DONE

scrn1tags
	dc.l	SA_Top,0
	dc.l	SA_Left,0
	dc.l	SA_Width,640
	dc.l	SA_Height,200
	dc.l	SA_Depth,4
	dc.l	SA_Pens,pens
	dc.l	SA_DetailPen,0
	dc.l	SA_BlockPen,1
	dc.l	SA_Title,scrn1title
	dc.l	SA_DisplayID,$8000
	dc.l	SA_Colors,coltags
	dc.l	SA_Type,CUSTOMSCREEN
	dc.l	SA_Font,topaz9
	dc.l	SA_Quiet,TRUE
	dc.l	TAG_DONE

wndw0tags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,640
	dc.l	WA_Height,200
	dc.l	WA_IDCMP,IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS
	dc.l	WA_Activate,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_CustomScreen
wndw0scrn
	dc.l	0
	dc.l	WA_RMBTrap,TRUE
	dc.l	TAG_DONE

wndw1tags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,640
	dc.l	WA_Height,200
	dc.l	WA_IDCMP,IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS
	dc.l	WA_Activate,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_CustomScreen
wndw1scrn
	dc.l	0
	dc.l	WA_RMBTrap,TRUE
	dc.l	TAG_DONE

prefstags
	dc.l	WA_Top,101
	dc.l	WA_Left,15
	dc.l	WA_Width,610
	dc.l	WA_Height,79
	dc.l	WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_INACTIVEWINDOW
	dc.l	WA_Activate,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_CustomScreen
prefsscrn
	dc.l	0
	dc.l	WA_RMBTrap,TRUE
	dc.l	TAG_DONE

searchtags
	dc.l	WA_Top,36
	dc.l	WA_Left,0
	dc.l	WA_Width,633
	dc.l	WA_Height,129
	dc.l	WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_INACTIVEWINDOW
	dc.l	WA_Activate,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_CustomScreen
searchscrn
	dc.l	0
	dc.l	WA_RMBTrap,TRUE
	dc.l	TAG_DONE

abouttags
	dc.l	WA_Top,26
	dc.l	WA_Left,306
	dc.l	WA_Width,202
	dc.l	WA_Height,128
	dc.l	WA_IDCMP,IDCMP_VANILLAKEY!IDCMP_MOUSEBUTTONS!IDCMP_INACTIVEWINDOW
	dc.l	WA_Activate,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_CustomScreen
aboutscrn
	dc.l	0
	dc.l	WA_RMBTrap,TRUE
	dc.l	TAG_DONE

btntags
	dc.l	WA_Top,108
	dc.l	WA_Left,58
	dc.l	WA_Width,560
	dc.l	WA_Height,23
	dc.l	WA_IDCMP,IDCMP_VANILLAKEY!IDCMP_MOUSEBUTTONS!IDCMP_INACTIVEWINDOW
	dc.l	WA_Activate,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_CustomScreen
btnscrn
	dc.l	0
	dc.l	WA_RMBTrap,TRUE
	dc.l	TAG_DONE

scv0	dc.w	$0222,$0FEA,$0CB7,$0222,$0FFF,$0984,$0762,$0BDB,$08A8,$0575,$0FD6,$0CA3,$0970,$0ED9,$0BA6,$0873
scv1	dc.w	$0000,$0FEA,$0CB7,$0531,$0FFF,$0984,$0762,$0DB7,$0A84,$0751,$0864,$0B97,$0651,$0ED9,$0BA6,$0873

se6
sefnt6
	dc.l	0
	dc.b	6,2,15,2
	dc.l	0,0,0,0,0,0,0

si6
	dc.l	searchb,searchub
	dc.w	0,43,0,0,0,0,0,0
	dc.l	se6,0,0

gd6
	dc.l	0
	dc.w	180,30,434,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si6
	dc.w	6
        dc.l	0

se5
sefnt5
	dc.l	0
	dc.b	6,2,15,2
	dc.l	0,0,0,0,0,0,0

si5
	dc.l	numb5,numub5
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se5,0,0

gd5
	dc.l	0
	dc.w	234,27,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si5
	dc.w	5
        dc.l	0

se4
sefnt4
	dc.l	0
	dc.b	6,2,15,2
	dc.l	0,0,0,0,0,0,0

si4
	dc.l	numb4,numub4
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se4,0,0

gd4
	dc.l	0
	dc.w	96,27,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si4
	dc.w	4
        dc.l	0

se3
sefnt3
	dc.l	0
	dc.b	6,2,15,2
	dc.l	0,0,0,0,0,0,0

si3
	dc.l	numb3,numub3
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se3,0,0

gd3
	dc.l	0
	dc.w	550,9,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si3
	dc.w	3
        dc.l	0

se2
sefnt2
	dc.l	0
	dc.b	6,2,15,2
	dc.l	0,0,0,0,0,0,0

si2
	dc.l	numb2,numub2
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se2,0,0

gd2
	dc.l	0
	dc.w	422,9,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si2
	dc.w	2
        dc.l	0

se1
sefnt1
	dc.l	0
	dc.b	6,2,15,2
	dc.l	0,0,0,0,0,0,0

si1
	dc.l	numb1,numub1
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se1,0,0

gd1
	dc.l	0
	dc.w	254,9,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si1
	dc.w	1
        dc.l	0

se0
sefnt0
	dc.l	0
	dc.b	6,2,15,2
	dc.l	0,0,0,0,0,0,0

si0
	dc.l	numb0,numub0
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se0,0,0

gd0
	dc.l	0
	dc.w	126,9,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si0
	dc.w	0
        dc.l	0

prefslist
	dc.l	gd0,gd1,gd2,gd3,gd4,gd5

langlist
	dc.l	tagalog,danish,english,french,german,icelandic,italian,norwegian,spanish,swedish

wordlist
	dc.l	wt0,wt1,wt2,wt3,wt4,wt5,wt6,wt7,wt8,wt9,wt10,wt11,wt12,wt13,wt14,wt15,wt16,wt17,wt18,wt19,wt20,wt21

sentlist
	dc.l	st0,st1,st2,st3,st4,st5,st6,st7,st8,st9,st10,st11,st12,st13,st14,st15,st16,st17,st18,st19,st20,st21

ttlist0
	dc.l	dfn0,dfn1,dfn2,dfn3,dfn4,dfn5,dfn6,dfn7,dfn8,dfn9,dfn10


 * Long Variables.

returnMsg	dc.l	0
_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
_IconBase	dc.l	0
_TranslatorBase	dc.l    0
longval         dc.l    0
wndw0ptr	dc.l	0
wndw0rp		dc.l	0
scrn0ptr	dc.l	0
scrn0rp		dc.l	0
vp0ptr		dc.l	0
wndw1ptr	dc.l	0
wndw1rp		dc.l	0
scrn1ptr	dc.l	0
scrn1rp		dc.l	0
vp1ptr		dc.l	0
prefswndw	dc.l	0
prefsrp		dc.l	0
searchwndw	dc.l	0
searchrp	dc.l	0
aboutwndw	dc.l	0
aboutrp		dc.l	0
btnwndw		dc.l	0
btnrp		dc.l	0
scrnptr		dc.l	0
wndwptr		dc.l	0
iclass		dc.l	0
iadr		dc.l	0
rdargs          dc.l    0
doptr           dc.l    0
ttptr           dc.l    0
olddir          dc.l    0
ckstg           dc.l    0
fh		dc.l	0
fl		dc.l	0
fibptr		dc.l	0
lockptr		dc.l	0
stgfnt		dc.l	0
titlesmem	dc.l	0
dfsmem		dc.l	0
dssmem		dc.l	0
ffsmem		dc.l	0
fssmem		dc.l	0
wdnmem		dc.l	0
wfnmem		dc.l	0
wdjmem		dc.l	0
wfjmem		dc.l	0
wdvmem		dc.l	0
wfvmem		dc.l	0
nywmem		dc.l	0
nyamem		dc.l	0
sywmem		dc.l	0
syamem		dc.l	0
memptr		dc.l	0
seed		dc.l	-1
writeport	dc.l	0
writeio		dc.l	0


 * Word Variables.

icode		dc.w	0
iqual		dc.w	0
msex		dc.w	0
msey		dc.w	0


 * Byte Variables.

clwb		dc.b	0
fnload		dc.b	0
fnsave		dc.b	0
count		dc.b	1


 * String Varaiables.

int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0,0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
trans_name	dc.b    'translator.library',0,0
nar_name	dc.b    'narrator.device',0
font_name	dc.b    'topaz.font',0,0
scrn0title	dc.b	'LGUI - MS',0
scrn1title	dc.b	'LGUI - OS',0
tagalog		dc.b	'  TAGALOG  ',0
danish		dc.b	'  DANISH   ',0
english		dc.b	'  ENGLISH  ',0
french		dc.b	'  FRENCH   ',0
german		dc.b	'  GERMAN   ',0
icelandic	dc.b	'  ICELANDIC',0
italian		dc.b	'  ITALIAN  ',0
norwegian	dc.b	'  NORWEGIAN',0
spanish		dc.b	'  SPANISH  ',0
swedish		dc.b	'  SWEDISH  ',0
vowel0		dc.b	'  ',0,0
vowel1		dc.b	'AA',0,0
vowel2		dc.b	'AE',0,0
vowel3		dc.b	'AH',0,0
vowel4		dc.b	'AO',0,0
vowel5		dc.b	'EH',0,0
vowel6		dc.b	'ER',0,0
vowel7		dc.b	'IH',0,0
vowel8		dc.b	'IY',0,0
vowel9		dc.b	'OW',0,0
vowel10		dc.b	'UH',0,0
vowel11		dc.b	'UW',0,0
pmt0		dc.b	'/F LINES',0,0
pmt1		dc.b	'UTO',0
pmt2		dc.b	'PELL',0
pmt3		dc.b	'ORD',0
pmt4		dc.b	'EVEAL',0
pmt5		dc.b	'AUSE',0
pmt6		dc.b	'I',0
pmt7		dc.b	'N',0
pmt8		dc.b	'G',0
pmt9		dc.b	'OFF',0
pmt10		dc.b	'ON ',0
pmt11		dc.b	'ENTENCE',0
pmt12		dc.b	'RO/NOUN',0
pmt13		dc.b	'DJECTIVE',0,0
pmt14		dc.b	'AD/VERB',0
pmt15		dc.b	'EFAULT',0,0
pmt16		dc.b	'OREIGN',0,0
pmt17		dc.b	'ONTINUE',0
pmt18		dc.b	'Search String',0
pmt19		dc.b	'LanguageGUI V3.01',0
pmt20		dc.b	'WORD SPLIT',0,0
pmt21		dc.b	'SPELL',0
pmt22		dc.b	'SPEECH',0
pmt23		dc.b	'RANDOM',0
pmt24		dc.b	'ISCELLANEOUS ALL',0
pmt25		dc.b	'Exit',0,0
pmt26		dc.b	'TEL 07949 645637',0
pmt27		dc.b	'John White',0,0
pmt28		dc.b	'91 Comber House',0
pmt29		dc.b	'Comber Grove',0,0
pmt30		dc.b	'Camberwell',0,0
pmt31		dc.b	'London SE5 0LL',0,0
pmt32		dc.b	'ENGLAND',0
pmt33		dc.b	'FILE ERROR',0,0
pmt34		dc.b	'Could Not Find: ',0,0
pmt35		dc.b	'Could Not Examine: ',0
pmt36		dc.b	'No Memory For: ',0
pmt37		dc.b	'Invalid File: ',0,0
pmt38		dc.b	'File Size Too Small',0
pmt39		dc.b	'Quit',0,0
pmt40		dc.b	'Could Not Load: ',0,0
pmt41		dc.b	'Could Not Read: ',0,0
pmt42		dc.b	'Could Not Write: ',0
pmt43		dc.b	'The Default Titles Have Been Used',0
pmt44		dc.b	'Save Config',0
pmt45		dc.b	'The Default Config has Been Used',0,0
pmt46		dc.b	'File Size Too Large',0
pmt47		dc.b	'Invalid Character',0
pmt48		dc.b	'Not In Range 1-1500',0
pmt49		dc.b	'22 Categories Not Found: ',0
pmt50		dc.b	'@ Character Missing',0
pmt51		dc.b	'# or % Character Missing',0,0
pmt52		dc.b	'Out Of Valid Range ',0
pmt53		dc.b	'ICE',0
pmt54		dc.b	'Unknown    ',0
pmt55		dc.b	'DEFAULT',0
pmt56		dc.b	'FOREIGN',0
pmt57		dc.b	'String Search - Complete ',0
pmt58		dc.b	'                         ',0
lfn0		dc.b	'Titles.Lgui',0
lfn1		dc.b	'DSentences.Lgui',0
lfn2		dc.b	'FSentences.Lgui',0
lfn3		dc.b	'DNouns.Lgui',0
lfn4		dc.b	'FNouns.Lgui',0
lfn5		dc.b	'DAdjectives.Lgui',0,0
lfn6		dc.b	'FAdjectives.Lgui',0,0
lfn7		dc.b	'DVerbs.Lgui',0
lfn8		dc.b	'FVerbs.Lgui',0
lfn9		dc.b	'DSSpeech.Lgui',0
lfn10		dc.b	'FSSpeech.Lgui',0
lfn11		dc.b	'DNSpeech.Lgui',0
lfn12		dc.b	'FNSpeech.Lgui',0
lfn13		dc.b	'DJSpeech.Lgui',0
lfn14		dc.b	'FJSpeech.Lgui',0
lfn15		dc.b	'DVSpeech.Lgui',0
lfn16		dc.b	'FVSpeech.Lgui',0
lfn17		dc.b	'LGUI.Config',0
lfn18		dc.b	'LanguageGUI/',0,0
dfn0		dc.b	'Ram:',0,0
dfn1		dc.b	'DF0:',0,0
dfn2		dc.b	'DF1:',0,0
dfn3		dc.b	'DF2:',0,0
dfn4		dc.b	'DF3:',0,0
dfn5		dc.b	'DH0:',0,0
dfn6		dc.b	'DH1:',0,0
dfn7		dc.b	'DH2:',0,0
dfn8		dc.b	'DH3:',0,0
dfn9		dc.b	'WORK:',0
dfn10		dc.b	'LGUI:',0
yes		dc.b	'YES',0
no		dc.b	'NO',0,0
plt0		dc.b	'D',0
plt1		dc.b	'A',0
plt2		dc.b	'S',0
plt3		dc.b	'W',0
plt4		dc.b	'R',0
plt5		dc.b	'P',0
plt6		dc.b	'V',0
plt7		dc.b	'C',0
plt8		dc.b	'F',0
plt9		dc.b	't',0
plt10		dc.b	'O',0
plt11		dc.b	'L',0
plt12		dc.b	'E',0
plt13		dc.b	'N',0
plt14		dc.b	'M',0
plt15		dc.b	'x',0
ftstg0          dc.b    'SPEECH_PRIORITY',0
ftstg1          dc.b    'WORKBENCH_CLOSE',0
ftstg2          dc.b    'DEVICE_LOADFROM',0
ftstg3          dc.b    'DEVICE_SAVETO',0
template	dc.b	'SPEECH_PRIORITY/K,WORKBENCH_CLOSE/K,DEVICE_LOADFROM/K,DEVICE_SAVETO/K',0
wt0	dc.b	'Names of Relations, Etc     ',0,0
wt1	dc.b	'Date, Time, Etc             ',0,0
wt2     dc.b	'Kitchen Items/Words         ',0,0
wt3     dc.b	'Question and Answer Words   ',0,0
wt4     dc.b	'Occupations                 ',0,0
wt5     dc.b	'General Words (Conversation)',0,0
wt6     dc.b	'The Body and Senses         ',0,0
wt7     dc.b	'Opposite/Related Words      ',0,0
wt8     dc.b	'Reading and Writing         ',0,0
wt9     dc.b	'Colours                     ',0,0
wt10    dc.b	'The Weather                 ',0,0
wt11	dc.b	'Directions                  ',0,0
wt12    dc.b	'Religion                    ',0,0
wt13    dc.b	'Clothes and Things Worn, Etc',0,0
wt14    dc.b	'Numbers                     ',0,0
wt15    dc.b	'Money                       ',0,0
wt16    dc.b	'Household Items/Words       ',0,0
wt17    dc.b	'Measurement                 ',0,0
wt18    dc.b	'School                      ',0,0
wt19    dc.b	'Animals, Insects, Etc       ',0,0
wt20    dc.b	'Leisure Activities/Hobbies  ',0,0
wt21    dc.b	'Miscellaneous Words         ',0,0
st0	dc.b	'The Telephone               ',0,0
st1	dc.b	'Talking To/Meeting People   ',0,0
st2	dc.b	'Date, Time, Etc             ',0,0
st3	dc.b	'The Weather                 ',0,0
st4     dc.b    'Asking Directions, Etc      ',0,0
st5     dc.b    'Money                       ',0,0
st6     dc.b    'Eating and Drinking         ',0,0
st7     dc.b    'In The Kitchen              ',0,0
st8     dc.b    'Shopping                    ',0,0
st9     dc.b    'Leave, Go, Come, Arrive, Etc',0,0
st10	dc.b	'Reading and Writing         ',0,0
st11    dc.b    'Senses                      ',0,0
st12    dc.b    'Awake, Asleep, Etc          ',0,0
st13    dc.b    'At Home, The House, Etc     ',0,0
st14	dc.b    'Clothes                     ',0,0
st15    dc.b    'Religion                    ',0,0
st16    dc.b    'Travel and Transport        ',0,0
st17    dc.b    'Leisure Activities/Hobbies  ',0,0
st18    dc.b    'Sickness And Health         ',0,0
st19    dc.b    'Chatting-Up, Dating, Etc    ',0,0
st20    dc.b    'Various COMMON Comments, Etc',0,0
st21    dc.b    'Various (Misc.) Sentences   ',0,0


 * Buffer Variables.

argv            dcb.l	30,0
filesizes	dcb.l	44,0
wb0		dcb.w	88,0
wv0		dcb.w	44,0
wb1		dcb.w	88,0
wv1		dcb.w	44,0
wb2		dcb.w	88,0
wv2		dcb.w	44,0
wb3		dcb.w	88,0
wv3		dcb.w	44,0
wb4		dcb.w	88,0
wv4		dcb.w	44,0
wb5		dcb.w	88,0
wv5		dcb.w	44,0
sb0		dcb.w	88,0
sv0		dcb.w	44,0
sb1		dcb.w	88,0
sv1		dcb.w	44,0
nynmem		dcb.b	1500,0
nylmem		dcb.b	1500,0
ptwmem		dcb.b	1500,0
synmem		dcb.b	1500,0
sylmem		dcb.b	1500,0
ptsmem		dcb.b	1500,0
config		dcb.b	500,0
filename	dcb.b	100,0
engb		dcb.b	88,0
narb		dcb.b	88,0
searchb		dcb.b	128,0
searchub	dcb.b	128,0
bytebuf		dcb.b	12,0
numb0		dcb.b	8,0
numub0		dcb.b	8,0
numb1		dcb.b	8,0
numub1		dcb.b	8,0
numb2		dcb.b	8,0
numub2		dcb.b	8,0
numb3		dcb.b	8,0
numub3		dcb.b	8,0
numb4		dcb.b	8,0
numub4		dcb.b	8,0
numb5		dcb.b	8,0
numub5		dcb.b	8,0
numb6		dcb.b	8,0
numub6		dcb.b	8,0


	SECTION	GFX,DATA_C

bd0  dc.w    %1111111111111111,%1111111111111100
     dc.w    %1100111111111111,%1111111111111100
     dc.w    %1111000000000000,%0000000000111100
     dc.w    %1111000000000000,%0000000000111100
     dc.w    %1111000000000000,%0000000000111100
     dc.w    %1111000000000000,%0000000000111100
     dc.w    %1111000000000000,%0000000000111100
     dc.w    %1111000000000000,%0000000000111100
     dc.w    %1111111111111111,%1111111111001100
     dc.w    %1111111111111111,%1111111111111100

     dc.w    %1111111111111111,%1111111111111100
     dc.w    %1111000000000000,%0000000000001100
     dc.w    %1111111111111111,%1111111111001100
     dc.w    %1111111111111111,%1111111111001100
     dc.w    %1111111111111111,%1111111111001100
     dc.w    %1111111111111111,%1111111111001100
     dc.w    %1111111111111111,%1111111111001100
     dc.w    %1111111111111111,%1111111111001100
     dc.w    %1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111100

     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0000000000000000,%0000000000000000

     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0000000000000000,%0000000000000000

bd1  dc.w    %1111111111111111,%1111111111111100
     dc.w    %1111000000000000,%0000000000001100
     dc.w    %1100111111111111,%1111111111001100
     dc.w    %1100111111111111,%1111111111001100
     dc.w    %1100111111111111,%1111111111001100
     dc.w    %1100111111111111,%1111111111001100
     dc.w    %1100111111111111,%1111111111001100
     dc.w    %1100111111111111,%1111111111001100
     dc.w    %1100000000000000,%0000000000111100
     dc.w    %1111111111111111,%1111111111111100

     dc.w    %1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111100
     dc.w    %1100111111111111,%1111111111111100
     dc.w    %1100111111111111,%1111111111111100
     dc.w    %1100111111111111,%1111111111111100
     dc.w    %1100111111111111,%1111111111111100
     dc.w    %1100111111111111,%1111111111111100
     dc.w    %1100111111111111,%1111111111111100
     dc.w    %1100000000000000,%0000000000111100
     dc.w    %1111111111111111,%1111111111111100

     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0011000000000000,%0000000000000000
     dc.w    %0011000000000000,%0000000000000000
     dc.w    %0011000000000000,%0000000000000000
     dc.w    %0011000000000000,%0000000000000000
     dc.w    %0011000000000000,%0000000000000000
     dc.w    %0011000000000000,%0000000000000000
     dc.w    %0011111111111111,%1111111111000000
     dc.w    %0000000000000000,%0000000000000000

     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111110000
     dc.w    %0000000000000000,%0000000000000000

bd2  dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000011111,%1110000001100000,%0110000001111111,%1000000111111111,%1000000000110000
     dc.w    %1100000000000000,%0000000000110000,%0011000001100000,%0110000011000000,%1100000110000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000110000,%0011000001100000,%0110000011000000,%0000000110000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000111111,%1111000001100000,%0110000001111111,%1000000111111110,%0000000000110000
     dc.w    %1100000000000000,%0000000000110000,%0011000001100000,%0110000000000000,%1100000110000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000110000,%0011000001100000,%0110000011000000,%1100000110000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000110000,%0011000000111111,%1100000001111111,%1000000111111111,%1000000000110000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000011111,%1111000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000011000,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000011000,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000011111,%1111000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111100000,%0000111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111100111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111100111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111100000,%0000111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000

bd3  dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %0011111111100000,%0000111111100000,%0001111110011111,%1001111110000000,%0111111000000000,%0111111111000000
     dc.w    %0011111111100111,%1110011111001111,%1100111110011111,%1001111100111111,%0011111001111111,%1111111111000000
     dc.w    %0011111111100111,%1110011111001111,%1100111110011111,%1001111100111111,%1111111001111111,%1111111111000000
     dc.w    %0011111111100000,%0000111111000000,%0000111110011111,%1001111110000000,%0111111000000001,%1111111111000000
     dc.w    %0011111111100111,%1111111111001111,%1100111110011111,%1001111111111111,%0011111001111111,%1111111111000000
     dc.w    %0011111111100111,%1111111111001111,%1100111110011111,%1001111100111111,%0011111001111111,%1111111111000000
     dc.w    %0011111111100111,%1111111111001111,%1100111111000000,%0011111110000000,%0111111000000000,%0111111111000000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000

     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0011111111100000,%0000111111100000,%0001111110011111,%1001111110000000,%0111111000000000,%0111111111110000
     dc.w    %0011111111100111,%1110011111001111,%1100111110011111,%1001111100111111,%0011111001111111,%1111111111110000
     dc.w    %0011111111100111,%1110011111001111,%1100111110011111,%1001111100111111,%1111111001111111,%1111111111110000
     dc.w    %0011111111100000,%0000111111000000,%0000111110011111,%1001111110000000,%0111111000000001,%1111111111110000
     dc.w    %0011111111100111,%1111111111001111,%1100111110011111,%1001111111111111,%0011111001111111,%1111111111110000
     dc.w    %0011111111100111,%1111111111001111,%1100111110011111,%1001111100111111,%0011111001111111,%1111111111110000
     dc.w    %0011111111100111,%1111111111001111,%1100111111000000,%0011111110000000,%0111111000000000,%0111111111110000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000

     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000011111,%1111000000011111,%1110000001100000,%0110000001111111,%1000000111111111,%1000000000000000
     dc.w    %1100000000011000,%0001100000110000,%0011000001100000,%0110000011000000,%1100000110000000,%0000000000000000
     dc.w    %1100000000011000,%0001100000110000,%0011000001100000,%0110000011000000,%0000000110000000,%0000000000000000
     dc.w    %1100000000011111,%1111000000111111,%1111000001100000,%0110000001111111,%1000000111111110,%0000000000000000
     dc.w    %1100000000011000,%0000000000110000,%0011000001100000,%0110000000000000,%1100000110000000,%0000000000000000
     dc.w    %1100000000011000,%0000000000110000,%0011000001100000,%0110000011000000,%1100000110000000,%0000000000000000
     dc.w    %1100000000011000,%0000000000110000,%0011000000111111,%1100000001111111,%1000000111111111,%1000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000

     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000

bd4  dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000111111,%1110000001111111,%1110000001111111,%1000000110000001,%1000000000110000
     dc.w    %1100000000000000,%0000000000110000,%0011000001100000,%0000000011000000,%1100000110000110,%0000000000110000
     dc.w    %1100000000000000,%0000000000110000,%0011000001100000,%0000000011000000,%1100000110011000,%0000000000110000
     dc.w    %1100000000000000,%0000000000111111,%1110000001111111,%1000000011111111,%1100000111100000,%0000000000110000
     dc.w    %1100000000000000,%0000000000110000,%0000000001100000,%0000000011000000,%1100000110011000,%0000000000110000
     dc.w    %1100000000000000,%0000000000110000,%0000000001100000,%0000000011000000,%1100000110000110,%0000000000110000
     dc.w    %1100000000000000,%0000000000110000,%0000000001111111,%1110000011000000,%1100000110000001,%1000000000110000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000001111,%1111000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000011000,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000001111,%1111000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000011000,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000001111,%1111000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111110000,%0000111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111100111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111110000,%0000111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111111111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111100111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111110000,%0000111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000

bd5  dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %0011111111110000,%0000111111000000,%0001111110000000,%0001111110000000,%0111111001111110,%0111111111000000
     dc.w    %0011111111100111,%1110011111001111,%1100111110011111,%1111111100111111,%0011111001111001,%1111111111000000
     dc.w    %0011111111100111,%1111111111001111,%1100111110011111,%1111111100111111,%0011111001100111,%1111111111000000
     dc.w    %0011111111110000,%0000111111000000,%0001111110000000,%0111111100000000,%0011111000011111,%1111111111000000
     dc.w    %0011111111111111,%1110011111001111,%1111111110011111,%1111111100111111,%0011111001100111,%1111111111000000
     dc.w    %0011111111100111,%1110011111001111,%1111111110011111,%1111111100111111,%0011111001111001,%1111111111000000
     dc.w    %0011111111110000,%0000111111001111,%1111111110000000,%0001111100111111,%0011111001111110,%0111111111000000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000

     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0011111111110000,%0000111111000000,%0001111110000000,%0001111110000000,%0111111001111110,%0111111111110000
     dc.w    %0011111111100111,%1110011111001111,%1100111110011111,%1111111100111111,%0011111001111001,%1111111111110000
     dc.w    %0011111111100111,%1111111111001111,%1100111110011111,%1111111100111111,%0011111001100111,%1111111111110000
     dc.w    %0011111111110000,%0000111111000000,%0001111110000000,%0111111100000000,%0011111000011111,%1111111111110000
     dc.w    %0011111111111111,%1110011111001111,%1111111110011111,%1111111100111111,%0011111001100111,%1111111111110000
     dc.w    %0011111111100111,%1110011111001111,%1111111110011111,%1111111100111111,%0011111001111001,%1111111111110000
     dc.w    %0011111111110000,%0000111111001111,%1111111110000000,%0001111100111111,%0011111001111110,%0111111111110000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000

     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000001111,%1111000000111111,%1110000001111111,%1110000001111111,%1000000110000001,%1000000000000000
     dc.w    %1100000000011000,%0001100000110000,%0011000001100000,%0000000011000000,%1100000110000110,%0000000000000000
     dc.w    %1100000000011000,%0000000000110000,%0011000001100000,%0000000011000000,%1100000110011000,%0000000000000000
     dc.w    %1100000000001111,%1111000000111111,%1110000001111111,%1000000011111111,%1100000111100000,%0000000000000000
     dc.w    %1100000000000000,%0001100000110000,%0000000001100000,%0000000011000000,%1100000110011000,%0000000000000000
     dc.w    %1100000000011000,%0001100000110000,%0000000001100000,%0000000011000000,%1100000110000110,%0000000000000000
     dc.w    %1100000000001111,%1111000000110000,%0000000001111111,%1110000011000000,%1100000110000001,%1000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000

     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000

bd6  dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000011111,%1110000001110000,%0110000011000000,%1100000011111111,%0000001100000000
     dc.w    %1100000000000000,%0000000000110000,%0011000001111000,%0110000011000000,%1100000110000001,%1000001100000000
     dc.w    %1100000000000000,%0000000000110000,%0011000001101100,%0110000011000000,%1100000110000001,%1000001100000000
     dc.w    %1100000000000000,%0000000000111111,%1111000001100110,%0110000011000000,%1100000111111111,%1000001100000000
     dc.w    %1100000000000000,%0000000000110000,%0011000001100011,%0110000011000000,%1100000110000001,%1000001100000000
     dc.w    %1100000000000000,%0000000000110000,%0011000001100001,%1110000011000000,%1100000110000001,%1000001100000000
     dc.w    %1100000000000000,%0000000000110000,%0011000001100000,%1110000001111111,%1000000110000001,%1000001111111111
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011100,%0011100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011110,%0111100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011011,%1101100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011001,%1001100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100011,%1100011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100001,%1000011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100100,%0010011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100110,%0110011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

bd7  dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000001100000,%0110000011111111,%1100000011111111,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000001100000,%0110000000001100,%0000000110000001,%1000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000001100000,%0110000000001100,%0000000110000001,%1000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000001100000,%0110000000001100,%0000000110000001,%1000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000001100000,%0110000000001100,%0000000110000001,%1000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000001100000,%0110000000001100,%0000000110000001,%1000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000111111,%1100000000001100,%0000000011111111,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000011111,%1110000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000110000,%0011000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000110000,%0011000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000111111,%1111000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000110000,%0011000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000110000,%0011000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000110000,%0011000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111100000,%0001111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111001111,%1100111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111001111,%1100111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111000000,%0000111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111001111,%1100111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111001111,%1100111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111001111,%1100111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

bd8  dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %1100000000000000,%0000000000001111,%1111000000111111,%1110000001111111,%1100000001111111,%1000000000011000
     dc.w    %1100000000000000,%0000000000011000,%0001100000110000,%0011000001100000,%0110000011000000,%1100000000011000
     dc.w    %1100000000000000,%0000000000011000,%0001100000110000,%0011000001100000,%0110000011000000,%0000000000011000
     dc.w    %1100000000000000,%0000000000011000,%0001100000111111,%1110000001100000,%0110000001111111,%1000000000011000
     dc.w    %1100000000000000,%0000000000011000,%0001100000110000,%1100000001100000,%0110000000000000,%1100000000011000
     dc.w    %1100000000000000,%0000000000011000,%0001100000110000,%0110000001100000,%0110000011000000,%1100000000011000
     dc.w    %1100000000000000,%0000000000001111,%1111000000110000,%0011000001111111,%1100000001111111,%1000000000011000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000011000,%0000110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000011000,%1000110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000011001,%1100110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000011011,%0110110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000011110,%0011110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000011100,%0001110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000011000,%0000110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111100111,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111100111,%0111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111100110,%0011001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111100100,%1001001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111100001,%1100001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111100011,%1110001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111100111,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000

bd9  dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %1100000000000000,%0000000000111111,%1111000001110000,%0110000011111111,%1100000011111111,%0000000000011000
     dc.w    %1100000000000000,%0000000000110000,%0000000001111000,%0110000000001100,%0000000110000001,%1000000000011000
     dc.w    %1100000000000000,%0000000000110000,%0000000001101100,%0110000000001100,%0000000110000000,%0000000000011000
     dc.w    %1100000000000000,%0000000000111111,%1100000001100110,%0110000000001100,%0000000011111111,%0000000000011000
     dc.w    %1100000000000000,%0000000000110000,%0000000001100011,%0110000000001100,%0000000000000001,%1000000000011000
     dc.w    %1100000000000000,%0000000000110000,%0000000001100001,%1110000000001100,%0000000110000001,%1000000000011000
     dc.w    %1100000000000000,%0000000000111111,%1111000001100000,%1110000000001100,%0000000011111111,%0000000000011000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000001111,%1111100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000011000,%0000110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000001111,%1111100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000011000,%0000110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000001111,%1111100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111110000,%0000011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111100111,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111110000,%0000011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111111111,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111100111,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111110000,%0000011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000


bd30 dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000,%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000001111,%1111100000011111,%1111100000011111,%1110000001111111,%1100000000000000,%0000000110000001,%1000000000110000,%1100000000000000,%0000000000011111,%1111000000111111,%1111000001111111,%1110000001111111
     dc.w    %1100000000011000,%0000110000011000,%0000000000110000,%0011000001100000,%0110000000000000,%0000000110000001,%1000000000110000,%1100000000000000,%0000000000011000,%0001100000110000,%0000000001100000,%0000000011000000
     dc.w    %1100000000011000,%0000000000011000,%0000000000110000,%0011000001100000,%0110000000000000,%0000000110000001,%1000000000110000,%1100000000000000,%0000000000011000,%0001100000110000,%0000000001100000,%0000000011000000
     dc.w    %1100000000001111,%1111100000011111,%1110000000111111,%1111000001111111,%1100000000000000,%0000000111111111,%1000000000110000,%1100000000000000,%0000000000011111,%1111000000111111,%1100000001111111,%1000000001111111
     dc.w    %1100000000000000,%0000110000011000,%0000000000110000,%0011000001100001,%1000000000000000,%0000000110000001,%1000000000110000,%1100000000000000,%0000000000011000,%0110000000110000,%0000000001100000,%0000000000000000
     dc.w    %1100000000011000,%0000110000011000,%0000000000110000,%0011000001100000,%1100000000000000,%0000000110000001,%1000000000110000,%1100000000000000,%0000000000011000,%0011000000110000,%0000000001100000,%0000000011000000
     dc.w    %1100000000001111,%1111100000011111,%1111100000110000,%0011000001100000,%0110000000000000,%0000000110000001,%1000000000110000,%1100000000000000,%0000000000011000,%0001100000111111,%1111000001100000,%0000000001111111
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000,%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000,%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000001111111,%1000000000000000,%0000000000110000,%0000000000011111,%1111100000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000011000000,%1100000000000000,%0000000000110000,%0000000000011000,%0000110000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000011000000,%0000000000000000,%0000000000110000,%0000000000011000,%0000110000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000011000000,%0000000000000000,%0000000000110000,%0000000000011111,%1111100000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000011000000,%0000000000000000,%0000000000110000,%0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000011000000,%1100000000000000,%0000000000110000,%0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000001111111,%1000000000000000,%0000000000110000,%0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000,%0111111111111111,%1111111111000000,%1111111111100000,%0000011111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100111111,%0011111111111111,%1111111111000000,%1111111111100111,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100111111,%1111111111111111,%1111111111000000,%1111111111100111,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100111111,%1111111111111111,%1111111111000000,%1111111111100000,%0000011111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100111111,%1111111111111111,%1111111111000000,%1111111111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100111111,%0011111111111111,%1111111111000000,%1111111111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000,%0111111111111111,%1111111111000000,%1111111111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

bd31 dc.w    %1111111111111000,%0001111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %1000000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %1000000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %1000000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111

     dc.w    %1111111111111000,%0001111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1111111111111000,%0001111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0000000000000000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111100000,%0111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111000,%0111111111111111,%1111111111111111,%1111111111111111

bd36 dc.w    %0011111111111111,%1111111111111111
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111

     dc.w    %0011111111111111,%1111111111111111
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000

     dc.w    %0011111111111111,%1111111111111111
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000

     dc.w    %1100000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111

bd38 dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100

     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

bd39 dc.w    %1111111111111111,%1100000011111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%1100000110000011,%1111110000011111,%1111100000000011
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%0110001100000000,%0110000000000001,%1000000000000011
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%0011011000000000,%0110000000000001,%1000000000000011
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%0001110000000000,%0110000000000001,%1000000000000011
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%0011011000000000,%0110000000000001,%1000000000000011
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%0110001100000000,%0110000000000001,%1000000000000011
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%1100000110000011,%1111110000000001,%1000000000000011
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100001100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %1111111111111111,%0000001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100

     dc.w    %1111111111111111,%1100000011111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1111111111111111,%1100000011111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0111111111100000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0110000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0110000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0111111110000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0110000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0110000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0111111111100000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0000000000000000,%0000001100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1111111111111111,%0000001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%0000001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%0000001111111111,%1000000000011111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%0000001111111111,%1001111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%0000001111111111,%1001111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%0000001111111111,%1000000001111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%0000001111111111,%1001111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%0000001111111111,%1001111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%0000001111111111,%1000000000011111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%0000001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%0000001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%0000001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
     dc.w    %1111111111111111,%1100001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111


bd48 dc.w    %1001111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1110000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1110000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1110000000000000,%0000000000011111,%1111100000110000,%0011000001111111,%1110000001111111,%1000000110000000,%0000000000111111,%1100000000000000,%0000000000111111,%1111000001100000,%0110000011111111,%1100000000011111
     dc.w    %1110000000000000,%0000000000011000,%0000000000110000,%0011000001100000,%0000000011000000,%1100000110000000,%0000000000111111,%1100000000000000,%0000000000110000,%0000000000110000,%1100000000001100,%0000000000011111
     dc.w    %1110000000000000,%0000000000011000,%0000000000110000,%0011000001100000,%0000000011000000,%1100000110000000,%0000000000111111,%1100000000000000,%0000000000110000,%0000000000011001,%1000000000001100,%0000000000011111
     dc.w    %1110000000000000,%0000000000011111,%1110000000110000,%0011000001111111,%1000000011111111,%1100000110000000,%0000000000111111,%1100000000000000,%0000000000111111,%1100000000001111,%0000000000001100,%0000000000011111
     dc.w    %1110000000000000,%0000000000011000,%0000000000110000,%0011000001100000,%0000000011000000,%1100000110000000,%0000000000111111,%1100000000000000,%0000000000110000,%0000000000011001,%1000000000001100,%0000000000011111
     dc.w    %1110000000000000,%0000000000011000,%0000000000011100,%1110000001100000,%0000000011000000,%1100000110000000,%0000000000111111,%1100000000000000,%0000000000110000,%0000000000110000,%1100000000001100,%0000000000011111
     dc.w    %1110000000000000,%0000000000011111,%1111100000000111,%1000000001111111,%1110000011000000,%1100000111111111,%1000000000111111,%1100000000000000,%0000000000111111,%1111000001100000,%0110000000001100,%0000000000011111
     dc.w    %1110000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1110000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1110000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111001111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100111

     dc.w    %1001111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000111111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011111
     dc.w    %1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000001111,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000111

     dc.w    %0001111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000,%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000001111,%1111100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000011100,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000001100,%0000110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000011110,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000001100,%0000110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000011011,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000001111,%1111100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000011001,%1001100000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000001100,%0011000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000011000,%1101100000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000001100,%0001100000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000011000,%0111100000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000001100,%0000110000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000011000,%0011100000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000011000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0110000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%1100000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111110000,%0000011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111100011,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111110011,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111100001,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111110011,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111100100,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111110000,%0000011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111100110,%0110011111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111110011,%1100111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111100111,%0010011111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111110011,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111100111,%1000011111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111110011,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111100111,%1100011111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
     dc.w    %0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111110000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000

bd49 dc.w    %1111111111111110,%0111111111111111,%1111111100111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111001111,%1111111111111110,%0111111111111111
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0011111111100000,%0111111111100000,%0111111110000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0011000000110000,%0000011000000000,%1100000011000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0011000000110000,%0000011000000000,%1100000000000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0011111111100000,%0000011000000000,%0111111110000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0011000000000000,%0000011000000000,%0000000011000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0011000000000000,%0000011000000000,%1100000011000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0011000000000000,%0000011000000000,%0111111110000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %0000000001111111,%1000000000000000,%0011111111000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111110000,%0000000001111111,%1000000000000011
     dc.w    %1111111110011111,%1111111111111111,%1100111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110011111111111,%1111111110011111,%1111111111111100

     dc.w    %1111111111111110,%0111111111111111,%1111111100111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111001111,%1111111111111110,%0111111111111111
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000001111110,%0000000000000000,%0011111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001111111000000,%0000000001111110,%0000000000000011
     dc.w    %0000000000011110,%0000000000000000,%0000111100000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000011111000000,%0000000000011110,%0000000000000000

     dc.w    %1111111111100000,%0111111111111111,%1111000000111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111100000001111,%1111111111100000,%0111111111111111
     dc.w    %0000000001100000,%0000000000000000,%0011000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000000,%0000000001100000,%0000000000000011
     dc.w    %0000000001100000,%0000000000000000,%0011000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000000,%0010000001100000,%0000000000000011
     dc.w    %0000000001100000,%0000001111111000,%0011000000000000,%0000111111110000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000000,%0111000001100000,%0000011111000011
     dc.w    %0000000001100000,%0000011000001100,%0011000000000000,%0001100000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000000,%1111100001100000,%0000011111000011
     dc.w    %0000000001100000,%0000011000001100,%0011000000000000,%0001100000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000001,%1111110001100000,%0000011111000011
     dc.w    %0000000001100000,%0000000000011000,%0011000000000000,%0001100000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000011,%1111111001100000,%0001111111110011
     dc.w    %0000000001100000,%0000000001110000,%0011000000000000,%0001100000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000000,%1111100001100000,%0000111111100011
     dc.w    %0000000001100000,%0000000011000000,%0011000000000000,%0001100000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000000,%1111100001100000,%0000011111000011
     dc.w    %0000000001100000,%0000000000000000,%0011000000000000,%0000111111110000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000000,%1111100001100000,%0000001110000011
     dc.w    %0000000001100000,%0000000011000000,%0011000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000000,%0000000001100000,%0000000100000011
     dc.w    %0000000001100000,%0000000000000000,%0011000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000000,%0000000001100000,%0000000000000011
     dc.w    %0000000001100000,%0000000000000000,%0011000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001100000000000,%0000000001100000,%0000000000000011
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %0000000000000001,%1000000000000000,%0000000011000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000110000,%0000000000000001,%1000000000000000
     dc.w    %1111111110000001,%1111111111111111,%1100000011111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111111,%1111111110000001,%1111111111111100
     dc.w    %1111111110000001,%1111111111111111,%1100000011111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111111,%1101111110000001,%1111111111111100
     dc.w    %1111111110000001,%1111110000000111,%1100000011111111,%1111000000001111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111111,%1000111110000001,%1111100000111100
     dc.w    %1111111110000001,%1111100111110011,%1100000011111111,%1110011111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111111,%0000011110000001,%1111100000111100
     dc.w    %1111111110000001,%1111100111110011,%1100000011111111,%1110011111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111110,%0000001110000001,%1111100000111100
     dc.w    %1111111110000001,%1111111111100111,%1100000011111111,%1110011111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111100,%0000000110000001,%1110000000001100
     dc.w    %1111111110000001,%1111111110001111,%1100000011111111,%1110011111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111111,%0000011110000001,%1111000000011100
     dc.w    %1111111110000001,%1111111100111111,%1100000011111111,%1110011111100111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111111,%0000011110000001,%1111100000111100
     dc.w    %1111111110000001,%1111111111111111,%1100000011111111,%1111000000001111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111111,%0000011110000001,%1111110001111100
     dc.w    %1111111110000001,%1111111100111111,%1100000011111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111111,%1111111110000001,%1111111011111100
     dc.w    %1111111110000001,%1111111111111111,%1100000011111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111111,%1111111110000001,%1111111111111100
     dc.w    %1111111110000001,%1111111111111111,%1100000011111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000111111,%1111111110000001,%1111111111111100
     dc.w    %1111111111100001,%1111111111111111,%1111000011111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111100000111111,%1111111111100001,%1111111111111111



bd50 dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

     dc.w    %0111111111000000,%0000000000000000,%0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000001100000,%0000000000000000,%0000000000011000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000000000000,%1111111100000110,%1111110000011111,%1000000001111111,%1000001101111110,%0000011111111000,%0001111111100000
     dc.w    %0111111111000001,%1000000110000111,%1000011000011000,%0000000011000000,%1100001111000011,%0000110000001100,%0011000000110000
     dc.w    %0000000001100001,%1111111110000110,%0000011000011000,%0000000011111111,%1100001100000011,%0000110000000000,%0011111111110000
     dc.w    %0000000001100001,%1000000000000110,%0000011000011000,%0000000011000000,%0000001100000011,%0000110000000000,%0011000000000000
     dc.w    %1100000001100001,%1000000110000110,%0000011000011000,%0011000011000000,%1100001100000011,%0000110000001100,%0011000000110000
     dc.w    %0111111111000000,%1111111100000110,%0000011000001111,%1110000001111111,%1000001100000011,%0000011111111000,%0001111111100000

     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

bd51 dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

     dc.w    %1111111111000000,%0000000000000000,%0000000000000000,%0011000011100000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000001100000,%0000000000000000,%0000000000000000,%0110000011110000,%0110000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000001100001,%1011111100000011,%1111110000000000,%1100000011011000,%0110000011111111,%0000011000000110,%0001101111110000
     dc.w    %1100000001100001,%1110000110000110,%0000011000000001,%1000000011001100,%0110000110000001,%1000011000000110,%0001111000011000
     dc.w    %1111111111000001,%1000000000000110,%0000011000000011,%0000000011000110,%0110000110000001,%1000011000000110,%0001100000011000
     dc.w    %1100000000000001,%1000000000000110,%0000011000000110,%0000000011000011,%0110000110000001,%1000011000000110,%0001100000011000
     dc.w    %1100000000000001,%1000000000000110,%0000011000001100,%0000000011000001,%1110000110000001,%1000011000001110,%0001100000011000
     dc.w    %1100000000000001,%1000000000000011,%1111110000011000,%0000000011000000,%1110000011111111,%0000001111110110,%0001100000011000

     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

bd52 dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

     dc.w    %0111111111000000,%0000000110000000,%0000110000000000,%0000000000000000,%0000001100000000,%0001100000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000001100000,%0000000110000000,%0000110000000000,%0000000000000000,%0000001100000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %1100000001100000,%1111111110000000,%0000110000011111,%1110000001111111,%1000001111110000,%0001100001100000,%0110000011111111,%0000000000000000
     dc.w    %1111111111100001,%1000000110000000,%0000110000110000,%0011000011000000,%1100001100000000,%0001100001100000,%0110000110000001,%1000000000000000
     dc.w    %1100000001100001,%1000000110000000,%0000110000111111,%1111000011000000,%0000001100000000,%0001100001100000,%0110000111111111,%1000000000000000
     dc.w    %1100000001100001,%1000000110000110,%0000110000110000,%0000000011000000,%0000001100000000,%0001100000110000,%1100000110000000,%0000000000000000
     dc.w    %1100000001100001,%1000000110000110,%0000110000110000,%0011000011000000,%1100001100000110,%0001100000011001,%1000000110000001,%1000000000000000
     dc.w    %1100000001100000,%1111111110000011,%1111100000011111,%1110000001111111,%1000000111111100,%0001100000001111,%0000000011111111,%0000000000000000

     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

bd53 dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111
     dc.w    %1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

     dc.w    %0111111111000000,%0000000110000000,%0000110000110000,%0001100000000000,%0000000000000000,%0000011000000000
     dc.w    %1100000001100000,%0000000110000000,%0001100000110000,%0001100000000000,%0000000000000000,%0000011000000000
     dc.w    %1100000001100000,%1111111110000000,%0011000000110000,%0001100000111111,%1100000110111111,%0000011111111100
     dc.w    %1111111111100001,%1000000110000000,%0110000000110000,%0001100001100000,%0110000111100001,%1000011000000110
     dc.w    %1100000001100001,%1000000110000000,%1100000000110000,%0001100001111111,%1110000110000000,%0000011000000110
     dc.w    %1100000001100001,%1000000110000001,%1000000000011000,%0011000001100000,%0000000110000000,%0000011000000110
     dc.w    %1100000001100001,%1000000110000011,%0000000000001100,%0110000001100000,%0110000110000000,%0000011000000110
     dc.w    %1100000001100000,%1111111110000110,%0000000000000111,%1100000000111111,%1100000110000000,%0000011111111100

     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
     dc.w    %0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

md0	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000010000000000,%0000011111000000
	dc.w	%0000000000000000,%0000011111000000
	dc.w	%0000000100000000,%0000001110000000
	dc.w	%0000000000000000,%0000011111100000
	dc.w	%0000011111000000,%0001111111111000
	dc.w	%0001111111110000,%0011111111101100
	dc.w	%0011111111111000,%0111111111011110
	dc.w	%0011111111111000,%0111111110111110
	dc.w	%0111111111111100,%1111111101111111
	dc.w	%0111111011111100,%1111111111111111
	dc.w	%0111111111111100,%1111111111111111
	dc.w	%0011111111111000,%0111111111111110
	dc.w	%0011111111111000,%0111111111111110
	dc.w    %0001111111110000,%0011111111111100
	dc.w	%0000011111000000,%0001111111111000
	dc.w	%0000000000000000,%0000011111100000
	dc.w	%0000000000000000,%0000000000000000


	SECTION	VERSION,DATA

	dc.b	'$VER: LanguageGUI V3.00 (26.3.2001)',0


	END
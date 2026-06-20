
	INCDIR  WORK:Include/

        INCLUDE exec/exec_lib.i
        INCLUDE exec/memory.i
        INCLUDE intuition/intuition_lib.i
        INCLUDE intuition/intuition.i
        INCLUDE graphics/graphics_lib.i
        INCLUDE graphics/text.i
        INCLUDE dos/dos_lib.i
        INCLUDE dos/dos.i
        INCLUDE dos/dosextens.i
        INCLUDE workbench/icon_lib.i
        INCLUDE workbench/startup.i
        INCLUDE workbench/workbench.i
        INCLUDE utility/utility_lib.i
        INCLUDE utility/utility.i
        INCLUDE libraries/translator_lib.i
        INCLUDE libraries/translator.i
        INCLUDE libraries/asl_lib.i
        INCLUDE libraries/asl.i
        INCLUDE devices/narrator.i

LIB_VER			EQU	39	; MC68020 specific instructions used.
TRUE            	EQU     -1
FALSE           	EQU     0
CONFIG_SAVESIZE		EQU	478	; Do not expand this size as it is
					; the same size used for LGUI V3.
	lea	config,a4
	bsr	def_cf

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
	move.l	d0,478(a4)		; D0 = A WBStartup Message.

_main
	moveq	#LIB_VER,d0
        lea     dos_name(pc),a1
	move.l	4.w,a6
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,702(a4)
        beq     quit

        moveq	#LIB_VER,d0
        lea     int_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,694(a4)
        beq     cl_dos

        moveq	#LIB_VER,d0
        lea     gfx_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,698(a4)
        beq     cl_int

        moveq	#LIB_VER,d0
        lea     icon_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,706(a4)
        beq     cl_gfx

        moveq	#37,d0
        lea     tran_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,714(a4)
        beq     cl_icon

 * Check the ToolTypes/CLI Arguments.

        move.l	478(a4),a0
        tst.l   a0
        beq     fromcli
	move.l	sm_ArgList(a0),a5
        move.l  (a5),d1
	beq	zero_args
	move.l	702(a4),a6
	jsr	_LVOCurrentDir(a6)
        move.l  d0,530(a4)
        move.l	wa_Name(a5),a0
	move.l	706(a4),a6
	jsr	_LVOGetDiskObject(a6)
        move.l  d0,522(a4)
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
tt1	moveq	#-1,d6
	move.l	#900,d7
	move.l	a5,a0
        lea	ftstg1(pc),a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	tt2
	move.l	d0,a0
	bsr	tt_num
	tst.l	d2
	bne.s	tt2
	move.w	d1,562(a4)
tt2
	nop

free_diskobj
        move.l	522(a4),a0
        jsr	_LVOFreeDiskObject(a6)
	bra.s	zero_args

fromcli	lea	template(pc),a0
	move.l  a0,d1
        lea     574(a4),a5
        move.l  a5,d2
        moveq	#0,d3
	move.l	702(a4),a6
        jsr	_LVOReadArgs(a6)
        move.l  d0,526(a4)
        beq.s	zero_args
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
ca1	moveq	#-1,d6
	move.l	#900,d7
	move.l	4(a5),a0
        bsr     findlen
	cmp.l	#4,d0
	bne.s	ca2
	bsr	arg_num
	cmp.l	#-1,d0
	beq.s	ca2
	move.w	d0,562(a4)
ca2
	nop

free_cliargs
        move.l  526(a4),d1
        jsr	_LVOFreeArgs(a6)

zero_args

	lea	topaz9(pc),a0
	move.l	698(a4),a6
	jsr	_LVOOpenFont(a6)
	move.l	d0,568(a4)
	beq.s	no_font
	move.l	d0,sefnt0
	move.l	d0,sefnt1
	move.l	d0,sefnt2
	move.l	d0,sefnt3
	move.l	d0,sefnt4
	move.l	d0,sefnt5
	move.l	d0,sefnt6
	move.l	d0,sefnt7
	move.l	d0,sefnt8
	move.l	d0,sefnt9
	move.l	d0,sefnt10
	move.l	d0,sefnt11
	move.l	d0,sefnt12
	move.l	d0,sefnt13
	move.l	d0,sefnt14
	move.l	d0,sefnt15
	bra.s	lock_screen

no_font
	nop
	bra	cl_tran

lock_screen
	suba.l  a0,a0
	move.l	694(a4),a6
	jsr	_LVOLockPubScreen(a6)
        move.l  d0,wndwscrn
        beq     cl_font

        move.l  d0,a1
        suba.l  a0,a0
	jsr	_LVOUnlockPubScreen(a6)

        suba.l  a0,a0
        lea     wndwtags(pc),a1
	move.l	694(a4),a6
	jsr	_LVOOpenWindowTagList(a6)
        move.l  d0,494(a4)
        beq     cl_font

        move.l  d0,a0
        move.l  wd_RPort(a0),a5

	move.l	a5,a1
	move.l	568(a4),a0
	move.l	698(a4),a6
	jsr	_LVOSetFont(a6)
	jsr	_LVOWaitTOF(a6)

	bsr	pen_a1
	move.l	a5,a1
	move.w	#71,d0
	move.w	#17,d1
	move.w	#93,d2
	move.w	#28,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#185,d0
	move.w	#17,d1
	move.w	#267,d2
	move.w	#28,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a2
	move.l	a5,a1
	move.w	#73,d0
	move.w	#18,d1
	move.w	#91,d2
	move.w	#27,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#187,d0
	move.w	#18,d1
	move.w	#265,d2
	move.w	#27,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#381,d0
	move.w	#17,d1
	move.w	#426,d2
	move.w	#28,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#519,d0
	move.w	#17,d1
	move.w	#574,d2
	move.w	#28,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#81,d0
	move.w	#36,d1
	move.w	#136,d2
	move.w	#47,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#274,d0
	move.w	#36,d1
	move.w	#349,d2
	move.w	#47,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#442,d0
	move.w	#35,d1
	move.w	#575,d2
	move.w	#48,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#147,d0
	move.w	#55,d1
	move.w	#202,d2
	move.w	#66,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#350,d0
	move.w	#55,d1
	move.w	#405,d2
	move.w	#66,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#520,d0
	move.w	#55,d1
	move.w	#575,d2
	move.w	#66,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#103,d0
	move.w	#74,d1
	move.w	#158,d2
	move.w	#85,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#262,d0
	move.w	#74,d1
	move.w	#317,d2
	move.w	#85,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#519,d0
	move.w	#74,d1
	move.w	#574,d2
	move.w	#85,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a1
	move.l	a5,a1
	move.w	#383,d0
	move.w	#18,d1
	move.w	#424,d2
	move.w	#27,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#521,d0
	move.w	#18,d1
	move.w	#572,d2
	move.w	#27,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#83,d0
	move.w	#37,d1
	move.w	#134,d2
	move.w	#46,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#276,d0
	move.w	#37,d1
	move.w	#347,d2
	move.w	#46,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#444,d0
	move.w	#36,d1
	move.w	#573,d2
	move.w	#47,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#149,d0
	move.w	#56,d1
	move.w	#200,d2
	move.w	#65,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#352,d0
	move.w	#56,d1
	move.w	#403,d2
	move.w	#65,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#522,d0
	move.w	#56,d1
	move.w	#573,d2
	move.w	#65,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#105,d0
	move.w	#75,d1
	move.w	#156,d2
	move.w	#84,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#264,d0
	move.w	#75,d1
	move.w	#315,d2
	move.w	#84,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#521,d0
	move.w	#75,d1
	move.w	#572,d2
	move.w	#84,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#92,d0
	move.w	#93,d1
	move.w	#127,d2
	move.w	#104,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a2
	move.l	a5,a1
	move.w	#94,d0
	move.w	#94,d1
	move.w	#125,d2
	move.w	#103,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#285,d0
	move.w	#93,d1
	move.w	#340,d2
	move.w	#104,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#509,d0
	move.w	#93,d1
	move.w	#564,d2
	move.w	#104,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a1
	move.l	a5,a1
	move.w	#287,d0
	move.w	#94,d1
	move.w	#338,d2
	move.w	#103,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#511,d0
	move.w	#94,d1
	move.w	#562,d2
	move.w	#103,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#147,d0
	move.w	#112,d1
	move.w	#172,d2
	move.w	#123,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a2
	move.l	a5,a1
	move.w	#149,d0
	move.w	#113,d1
	move.w	#170,d2
	move.w	#122,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#436,d0
	move.w	#112,d1
	move.w	#481,d2
	move.w	#123,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a1
	move.l	a5,a1
	move.w	#438,d0
	move.w	#113,d1
	move.w	#479,d2
	move.w	#122,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a2
	move.l	a5,a1
	move.w	#161,d0
	move.w	#130,d1
	move.w	#482,d2
	move.w	#143,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#161,d0
	move.w	#149,d1
	move.w	#482,d2
	move.w	#162,d3
	jsr	_LVORectFill(a6)
	bsr	pen_a1
	move.l	a5,a1
	move.w	#163,d0
	move.w	#131,d1
	move.w	#480,d2
	move.w	#142,d3
	jsr	_LVORectFill(a6)
	move.l	a5,a1
	move.w	#163,d0
	move.w	#150,d1
	move.w	#480,d2
	move.w	#161,d3
	jsr	_LVORectFill(a6)
	move.l	694(a4),a6
	lea	image40(pc),a1
	bsr	drawi
	lea	image40(pc),a1
	move.w	#459,(a1)
	move.l	#id27,ig_ImageData(a1)
	bsr	drawi
	lea	image40(pc),a1
	move.w	#488,(a1)
	bsr	drawi
	lea	image40(pc),a1
	move.w	#420,(a1)
	move.w	#92,ig_TopEdge(a1)
	move.l	#id28,ig_ImageData(a1)
	bsr	drawi
	lea	image40(pc),a1
	move.w	#449,(a1)
	move.l	#id27,ig_ImageData(a1)
	bsr	drawi
	lea	image40(pc),a1
	move.w	#478,(a1)
	bsr	drawi
	lea	image40(pc),a1
	move.w	#318,(a1)
	move.w	#111,ig_TopEdge(a1)
	move.l	#id28,ig_ImageData(a1)
	bsr	drawi
	lea	image40(pc),a1
	move.w	#347,(a1)
	move.l	#id27,ig_ImageData(a1)
	bsr	drawi
	lea	image40(pc),a1
	move.w	#376,(a1)
	bsr	drawi
	lea	image40(pc),a1
	move.w	#405,(a1)
	bsr	drawi
	move.l	698(a4),a6
	bsr	pen_a3
	bsr	pen_b0
	move.w	#18,d0
        move.w	#139,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     lt0(pc),a0
	bsr	text_13
        move.w	#18,d0
        move.w	#158,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     lt1(pc),a0
	bsr	text_13
	bsr	pen_a1
        move.w	#48,d0
        move.w	#139,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     lt2(pc),a0
	bsr	text_1
        move.w	#48,d0
        move.w	#158,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     lt3(pc),a0
	bsr	text_1
	bsr	pen_a2
	bsr	pen_b0
        move.w	#435,d0
        move.w	#82,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num1(pc),a0
	bsr	text_1
        move.w	#425,d0
        move.w	#101,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num1(pc),a0
	bsr	text_1
        move.w	#323,d0
        move.w	#120,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num1(pc),a0
	bsr	text_1

	move.l	694(a4),a6
	lea	gadlist(pc),a2
	clr.b	d3
gad_l	move.l	(a2)+,a1
	bsr	adg
	addq.b	#1,d3
	cmp.b	#36,d3
	blt.s	gad_l
	lea	gd0(pc),a0
	bsr	rfg
	bsr	update_config
	bsr	set_menu
	tst.l	d0
        beq     cl_wndw

mloop	move.l	698(a4),a6
	bsr	pen_a2
	bsr	pen_b1
	move.l  494(a4),a0
        move.l  wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
        move.l  494(a4),a0
        move.l  wd_UserPort(a0),a0
	jsr	_LVOGetMsg(a6)
        move.l  d0,a1
        move.l  im_Class(a1),498(a4)
        move.l  im_IAddress(a1),502(a4)
        move.w  im_Code(a1),554(a4)
        move.w  im_Qualifier(a1),556(a4)
        move.w  im_MouseX(a1),558(a4)
        move.w  im_MouseY(a1),560(a4)
	jsr	_LVOReplyMsg(a6)

	move.l	498(a4),d0
        cmp.l   #IDCMP_GADGETUP,d0
        beq     what_gu

        cmp.l   #IDCMP_GADGETDOWN,d0
        beq     what_gd

        cmp.l   #IDCMP_VANILLAKEY,d0
        beq     what_vk

        cmp.l   #IDCMP_RAWKEY,d0
        beq     what_rk

        cmp.l   #IDCMP_MOUSEBUTTONS,d0
        beq     what_mb

        cmp.l   #IDCMP_MENUPICK,d0
        beq     what_mi

        cmp.l   #IDCMP_MENUHELP,d0
        beq     what_mi

        cmp.l  #IDCMP_CLOSEWINDOW,d0
        beq.s   clear_menustrip

        bra	mloop

clear_menustrip
	bsr	clear_menu

cl_wndw	move.l  494(a4),a0
	move.l	694(a4),a6
	jsr	_LVOCloseWindow(a6)

cl_font	move.l	568(a4),a1
	move.l	698(a4),a6
	jsr	_LVOCloseFont(a6)

cl_tran	move.l  714(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_icon	move.l  706(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_gfx	move.l  698(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_int	move.l  694(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_dos	move.l  702(a4),a1
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
cleanup	tst.l	478(a4)
	beq.s	exit			; Exit - Task was started from CLI.
	move.l	4.w,a6
	jsr	_LVOForbid(a6)
	move.l	478(a4),a1	; Reply to the WB Startup Message and
	jsr	_LVOReplyMsg(a6)	; Exit - Task was started from WB.
exit	moveq	#0,d0
	rts


 * Branch-To Routines.

what_gu	move.l  502(a4),a0
        move.w  gg_GadgetID(a0),d0
	cmp.w	#4,d0
	blt.s	chk_n
	cmp.w	#16,d0
	bgt.s	chk_n
	subq.w	#4,d0
	lea	stglist(pc),a1
	move.l	0(a1,d0.w*4),a0
	bsr	actg
	bra	mloop
chk_n	tst.w	d0
	beq	do_tran
	cmp.w	#1,d0
	beq	do_nar
	cmp.w	#2,d0
	beq	do_sex
	cmp.w	#3,d0
	beq	do_mode
	cmp.w	#17,d0
	beq	do_vowel
	cmp.w	#18,d0
	beq	do_chan
	cmp.w	#19,d0
	beq	do_voice
	cmp.w	#20,d0
	beq	do_tran
	cmp.w	#21,d0
	beq	do_nar
	cmp.w	#22,d0
	beq	do_vol
	cmp.w	#23,d0
	beq	do_pitch
	cmp.w	#24,d0
	beq	do_rate
	cmp.w	#25,d0
	beq	do_freq
	cmp.w	#26,d0
	beq	do_enthus
	cmp.w	#27,d0
	beq	do_artic
	cmp.w	#28,d0
	beq	do_perturb
	cmp.w	#29,d0
	beq	do_av
	cmp.w	#30,d0
	beq	do_af
	cmp.w	#31,d0
	beq	do_amplify
	cmp.w	#32,d0
	beq	do_vowelc
	cmp.w	#33,d0
	beq	do_echo
	cmp.w	#34,d0
	beq	do_chanval
	cmp.w	#35,d0
	beq	do_voicebuf
	bra     mloop

do_sex	move.l	698(a4),a6
	bsr	pen_a1
	bsr	pen_b2
        move.w	#77,d0
        move.w	#25,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	move.w	390(a4),d7
	lea	0(a4,d7.w),a0
	cmp.b	#77,(a0)
	beq.s	sex_f
	move.b	#77,(a0)
	bra.s	sex_ok
sex_f	move.b	#70,(a0)
sex_ok	bsr	text_1
	bra	mloop

do_mode	move.l	698(a4),a6
	bsr	pen_a1
	bsr	pen_b2
        move.w	#192,d0
        move.w	#25,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	move.w	390(a4),d7
	lea	10(a4,d7.w),a0
	addq.b	#1,(a0)
	cmp.b	#2,(a0)
	ble.s	mode_ok
	clr.b	(a0)
mode_ok	tst.b	(a0)
	beq.s	mode_0
	cmp.b	#1,(a0)
	beq.s	mode_1
	lea     mode2(pc),a0
	bra.s	mode_e
mode_0	lea     mode0(pc),a0
	bra.s	mode_e
mode_1	lea	mode1(pc),a0
mode_e	bsr	text_7
	bra	mloop

do_vol	lea	gd22(pc),a3
	moveq	#0,d3
	moveq	#64,d4
	move.l	#$36340000,d5
	bsr	stg2num
	move.w	390(a4),d7
	tst.b	d0
	bne.s	pokevol
	move.b	#64,d0
pokevol	move.b	d0,20(a4,d7.w)
	bra	mloop

do_pitch
	lea	gd23(pc),a3
	moveq	#65,d3
	move.l	#320,d4
	move.l	#$31313000,d5
	bsr	stg2num
	move.w	390(a4),d7
	lea	210(a4),a0
	tst.w	d0
	bne.s	pokepit
	move.w	#110,d0
pokepit	move.w	d0,0(a0,d7.w*2)
	bra	mloop

do_rate	lea	gd24(pc),a3
	moveq	#40,d3
	move.l	#400,d4
	move.l	#$31353000,d5
	bsr	stg2num
	move.w	390(a4),d7
	lea	230(a4),a0
	tst.w	d0
	bne.s	pokerat
	move.w	#150,d0
pokerat	move.w	d0,0(a0,d7.w*2)
	bra	mloop

do_freq	lea	gd25(pc),a3
	move.l	#5000,d3
	move.l	#28000,d4
	move.l	#$32323230,d5
	bsr	stg2num
	move.w	390(a4),d7
	lea	250(a4),a0
	tst.w	d0
	bne.s	pokefrq
	move.w	#22200,d0
pokefrq	move.w	d0,0(a0,d7.w*2)
	bra	mloop

do_enthus
	lea	gd26(pc),a3
	moveq	#0,d3
	move.l	#255,d4
	move.l	#$33320000,d5
	bsr	stg2num
	move.w	390(a4),d7
	tst.b	d0
	bne.s	pokeent
	move.b	#32,d0
pokeent	move.b	d0,30(a4,d7.w)
	bra	mloop

do_artic
	lea	gd27(pc),a3
	moveq	#0,d3
	move.l	#255,d4
	move.l	#$31303000,d5
	bsr	stg2num
	move.w	390(a4),d7
	tst.b	d0
	bne.s	pokeart
	move.b	#100,d0
pokeart	move.b	d0,40(a4,d7.w)
	bra	mloop

do_perturb
	lea	gd28(pc),a3
	moveq	#0,d3
	move.l	#255,d4
	move.l	#$30000000,d5
	bsr	stg2num
	move.w	390(a4),d7
	move.b	d0,50(a4,d7.w)
	bra	mloop

do_av	lea	gd29(pc),a3
	moveq	#-32,d3
	moveq	#31,d4
	move.l	#$30000000,d5
	bsr	stg2num
	move.w	390(a4),d7
	move.b	d0,60(a4,d7.w)
	bra	mloop

do_af	lea	gd30(pc),a3
	moveq	#-32,d3
	moveq	#31,d4
	move.l	#$30000000,d5
	bsr	stg2num
	move.w	390(a4),d7
	move.b	d0,70(a4,d7.w)
	bra	mloop

do_amplify
	lea	gd31(pc),a3
	moveq	#-32,d3
	moveq	#31,d4
	move.l	#$30000000,d5
	bsr	stg2num
	move.w	390(a4),d7
	add.b	394(a4),d7
	move.b	d0,80(a4,d7.w)
	bra	mloop

do_vowel
	move.l	698(a4),a6
	bsr	pen_a1
	bsr	pen_b2
        move.w	#100,d0
        move.w	#101,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	move.w	390(a4),d7
	lea	110(a4,d7.w),a0
	addq.b	#1,(a0)
	cmp.b	#11,(a0)
	ble.s	vowelok
	clr.b	(a0)
vowelok	bsr	test_vowel
	bsr	text_2
	bra	mloop

do_vowelc
	lea	gd32(pc),a3
	moveq	#0,d3
	moveq	#100,d4
	move.l	#$30000000,d5
	bsr	stg2num
	move.w	390(a4),d7
	move.b	d0,120(a4,d7.w)
	bra	mloop

do_echo
	lea	gd33(pc),a3
	moveq	#-32,d3
	moveq	#31,d4
	move.l	#$30000000,d5
	bsr	stg2num
	move.w	390(a4),d7
	add.w	#130,d7
	add.b	395(a4),d7
	move.b	d0,0(a4,d7.w)
	bra	mloop

do_chan	move.l	698(a4),a6
	bsr	pen_a1
	bsr	pen_b2
        move.w	#155,d0
        move.w	#120,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	move.w	390(a4),d7
	lea	160(a4),a0
	lea	0(a0,d7.w),a0
	addq.b	#1,(a0)
	cmp.b	#52,(a0)
	ble.s	chan_ok
	move.b	#49,(a0)
chan_ok	bsr	text_1
	bra	mloop

do_voice
	lea	gd35(pc),a0
	move.l	gg_SpecialInfo(a0),a1
	move.w	#2,si_BufferPos(a1)
	bsr	actg
	bra	mloop

do_chanval
	lea	gd34(pc),a3
	moveq	#0,d3
	moveq	#15,d4
	move.l	#$30000000,d5
	bsr	stg2num
	move.w	390(a4),d7
	add.w	#170,d7
	add.b	397(a4),d7
	move.b	d0,0(a4,d7.w)
	bra	mloop

do_voicebuf
	bsr	clear_menu
	lea	voiceb(pc),a0
	lea	270(a4),a1
	moveq	#0,d0
	move.w	390(a4),d0
	move.l	d0,d1
	mulu	#12,d0
	mulu	#4,d1
	add.l	d0,a1
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	lea	langlist(pc),a1
	add.l	d1,a1
	move.l	(a1),a1
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	bsr	set_menu
	tst.l	d0
        beq     cl_wndw
	bra	mloop

do_tran	bsr	clrtran
	lea	engb(pc),a0
	moveq	#71,d0
	lea	transbuf(pc),a1
	move.l	#142,d1
	move.l	714(a4),a6
	jsr	_LVOTranslate(a6)
	move.l	694(a4),a6	
	lea	gd1(pc),a1
	bsr	rmg
	lea	transbuf(pc),a1
	lea	narb(pc),a0
	bsr	stgcopy
	lea	gd1(pc),a1
	bsr	adg
	lea	gd1(pc),a0
	bsr	rfg
	bsr	speakToMe
	bra	mloop

do_nar	bsr	clrtran
	lea	narb(pc),a1
	lea	transbuf(pc),a0
	bsr	stgcopy
	bsr	speakToMe
	bra	mloop

what_gd

        bra     mloop

what_mi	move.w  554(a4),d0
        cmp.w	#$F800,d0
        beq     aslload
	cmp.w	#$F820,d0
	beq	aslsave
	cmp.w	#$F840,d0
	beq	clear_menustrip
	cmp.w	#$F801,d0
	beq.s	sph_0
	cmp.w	#$F821,d0
	beq.s	sph_1
	cmp.w	#$F841,d0
	beq.s	sph_2
	cmp.w	#$F861,d0
	beq.s	sph_3
	cmp.w	#$F881,d0
	beq.s	sph_4
	cmp.w	#$F8A1,d0
	beq.s	sph_5
	cmp.w	#$F8C1,d0
	beq.s	sph_6
	cmp.w	#$F8E1,d0
	beq.s	sph_7
	cmp.w	#$F901,d0
	beq.s	sph_8
	cmp.w	#$F921,d0
	beq.s	sph_9
	cmp.w	#$F802,d0
	beq.s	do_udf
	cmp.w	#$F822,d0
	beq	do_wsf
	cmp.w	#$F842,d0
	beq	do_ssf
	cmp.w	#$F862,d0
	beq	do_fcf
	bra     mloop

sph_0	clr.w	390(a4)
	bra.s	sph_cnt
sph_1	move.w	#1,390(a4)
	bra.s	sph_cnt
sph_2	move.w	#2,390(a4)
	bra.s	sph_cnt
sph_3	move.w	#3,390(a4)
	bra.s	sph_cnt
sph_4	move.w	#4,390(a4)
	bra.s	sph_cnt
sph_5	move.w	#5,390(a4)
	bra.s	sph_cnt
sph_6	move.w	#6,390(a4)
	bra.s	sph_cnt
sph_7	move.w	#7,390(a4)
	bra.s	sph_cnt
sph_8	move.w	#8,390(a4)
	bra.s	sph_cnt
sph_9	move.w	#9,390(a4)
sph_cnt	move.w	390(a4),392(a4)
	bsr	update_config
	bra	mloop

do_udf	tst.b	396(a4)
	beq.s	udf_1
	clr.b	396(a4)
	bra.s	udf_e
udf_1	move.b	#1,396(a4)
udf_e	bra	mloop

do_wsf	tst.b	399(a4)
	beq.s	wsf_1
	clr.b	399(a4)
	bra.s	wsf_e
wsf_1	move.b	#1,399(a4)
wsf_e	bra	mloop

do_ssf	tst.b	398(a4)
	beq.s	ssf_1
	clr.b	398(a4)
	bra.s	ssf_e
ssf_1	move.b	#1,398(a4)
ssf_e	bra	mloop

do_fcf	tst.b	400(a4)
	beq.s	fcf_1
	clr.b	400(a4)
	bra.s	fcf_e
fcf_1	move.b	#1,400(a4)
fcf_e	bra	mloop

what_vk	move.w	554(a4),d0
        cmp.w   #$58,d0
        beq	do_sex
        cmp.w   #$78,d0
        beq	do_sex
        cmp.w   #$44,d0
        beq	do_mode
        cmp.w   #$64,d0
        beq	do_mode
        cmp.w   #$4D,d0
        beq	k_vol
        cmp.w   #$6D,d0
        beq	k_vol
        cmp.w   #$50,d0
        beq	k_pitch
        cmp.w   #$70,d0
        beq	k_pitch
        cmp.w   #$52,d0
        beq	k_rate
        cmp.w   #$72,d0
        beq	k_rate
        cmp.w   #$51,d0
        beq	k_freq
        cmp.w   #$71,d0
        beq	k_freq
        cmp.w   #$45,d0
        beq	k_voice
        cmp.w   #$65,d0
        beq	k_voice
        cmp.w   #$55,d0
        beq	k_enth
        cmp.w   #$75,d0
        beq	k_enth
        cmp.w   #$43,d0
        beq	k_artic
        cmp.w   #$63,d0
        beq	k_artic
        cmp.w   #$54,d0
        beq	k_pert
        cmp.w   #$74,d0
        beq	k_pert
        cmp.w   #$42,d0
        beq	k_av
        cmp.w   #$62,d0
        beq	k_av
        cmp.w   #$46,d0
        beq	k_af
        cmp.w   #$66,d0
        beq	k_af
        cmp.w   #$49,d0
        beq	k_amp
        cmp.w   #$69,d0
        beq	k_amp
        cmp.w   #$57,d0
        beq	do_vowel
        cmp.w   #$77,d0
        beq	do_vowel
        cmp.w   #$4F,d0
        beq	k_vc
        cmp.w   #$6F,d0
        beq	k_vc
        cmp.w   #$48,d0
        beq	k_echo
        cmp.w   #$68,d0
        beq	k_echo
        cmp.w   #$41,d0
        beq	do_chan
        cmp.w   #$61,d0
        beq	do_chan
        cmp.w   #$56,d0
        beq	k_chans
        cmp.w   #$76,d0
        beq	k_chans
        cmp.w   #$47,d0
        beq	k_lt
        cmp.w   #$67,d0
        beq	k_lt
        cmp.w   #$4E,d0
        beq	k_pt
        cmp.w   #$6E,d0
        beq.s	k_pt
        cmp.w   #$4B,d0
        beq	do_tran
        cmp.w   #$6B,d0
        beq	do_tran
        cmp.w   #$53,d0
        beq	do_nar
        cmp.w   #$73,d0
        beq	do_nar
	bra     mloop

k_vol	lea	gd22(pc),a0
	bra.s	act_key
k_pitch	lea	gd23(pc),a0
	bra.s	act_key
k_rate	lea	gd24(pc),a0
	bra.s	act_key
k_freq	lea	gd25(pc),a0
	bra.s	act_key
k_voice	lea	gd35(pc),a0
	bra.s	act_key
k_enth	lea	gd26(pc),a0
	bra.s	act_key
k_artic	lea	gd27(pc),a0
	bra.s	act_key
k_pert	lea	gd28(pc),a0
	bra.s	act_key
k_av	lea	gd29(pc),a0
	bra.s	act_key
k_af	lea	gd30(pc),a0
	bra.s	act_key
k_amp	lea	gd31(pc),a0
	bra.s	act_key
k_vc	lea	gd32(pc),a0
	bra.s	act_key
k_echo	lea	gd33(pc),a0
	bra.s	act_key
k_chans	lea	gd34(pc),a0
	bra.s	act_key
k_lt	lea	gd0(pc),a0
	bra.s	act_key
k_pt	lea	gd1(pc),a0
act_key	bsr	actg
	bra	mloop

what_rk	move.w	556(a4),d0
	move.w	554(a4),d1
	cmp.w	#$8000,d0
	bne.s	shift_l
	cmp.w	#$50,d1
	beq	rk_f1
	cmp.w	#$51,d1
	beq	rk_f2
	cmp.w	#$52,d1
	beq	rk_f3
	cmp.w	#$53,d1
	beq	rk_f4
	cmp.w	#$54,d1
	beq	rk_f5
	cmp.w	#$55,d1
	beq	rk_f6
	cmp.w	#$56,d1
	beq	rk_f7
	cmp.w	#$57,d1
	beq	rk_f8
	cmp.w	#$58,d1
	beq	rk_f9
	cmp.w	#$59,d1
	beq	rk_f10
	bra.s	rk_end
shift_l	cmp.w	#$8001,d0
	bne.s	rk_end
	cmp.w	#$50,d1
	beq	ls_f1
	cmp.w	#$51,d1
	beq	ls_f2
	cmp.w	#$52,d1
	beq	ls_f3
	cmp.w	#$53,d1
	beq	ls_f4
	cmp.w	#$54,d1
	beq	ls_f5
	cmp.w	#$55,d1
	beq	ls_f6
	cmp.w	#$56,d1
	beq	ls_f7
	cmp.w	#$57,d1
	beq	ls_f8
	cmp.w	#$58,d1
	beq	ls_f9
	cmp.w	#$59,d1
	beq	ls_f10
rk_end	bra	mloop

rk_f1	clr.b	394(a4)
	bsr	drawamp
	bra     mloop
rk_f2	move.b	#10,394(a4)
	bsr	drawamp
	bra     mloop
rk_f3	move.b	#20,394(a4)
	bsr	drawamp
	bra     mloop
rk_f4	clr.b	395(a4)
	bsr	drawech
	bra     mloop
rk_f5	move.b	#10,395(a4)
	bsr	drawech
	bra     mloop
rk_f6	move.b	#20,395(a4)
	bsr	drawech
	bra     mloop
rk_f7	clr.b	397(a4)
	bsr	drawcv
	bra     mloop
rk_f8	move.b	#10,397(a4)
	bsr	drawcv
	bra     mloop
rk_f9	move.b	#20,397(a4)
	bsr	drawcv
	bra     mloop
rk_f10	move.b	#30,397(a4)
	bsr	drawcv
	bra     mloop

ls_f1	clr.b	394(a4)
	bsr	drawamp
	bra     mloop
ls_f2	move.b	#10,394(a4)
	bsr	drawamp
	bra     mloop
ls_f3	move.b	#20,394(a4)
	bsr	drawamp
	bra     mloop
ls_f4	clr.b	395(a4)
	bsr	drawech
	bra     mloop
ls_f5	move.b	#10,395(a4)
	bsr	drawech
	bra     mloop
ls_f6	move.b	#20,395(a4)
	bsr	drawech
	bra     mloop
ls_f7	clr.b	397(a4)
	bsr	drawcv
	bra     mloop
ls_f8	move.b	#10,397(a4)
	bsr	drawcv
	bra     mloop
ls_f9	move.b	#20,397(a4)
	bsr	drawcv
	bra     mloop
ls_f10	move.b	#30,397(a4)
	bsr	drawcv
	bra     mloop

what_mb	move.w	558(a4),d0
	move.w	560(a4),d1
	cmp.w	#SELECTDOWN,554(a4)
	bne	mb_end
	cmp.w	#73,d1
	blt.s	mse_n1
	cmp.w	#86,d1
	bgt.s	mse_n1
	cmp.w	#430,d0
	blt.s	mse_c1
	cmp.w	#450,d0
	bgt.s	mse_c1
	clr.b	394(a4)
	bsr	drawamp
	bra	mb_end
mse_c1	cmp.w	#459,d0
	blt.s	mse_c2
	cmp.w	#479,d0
	bgt.s	mse_c2
	move.b	#10,394(a4)
	bsr	drawamp
	bra	mb_end
mse_c2	cmp.w	#488,d0
	blt	mb_end
	cmp.w	#508,d0
	bgt	mb_end
	move.b	#20,394(a4)
	bsr	drawamp
	bra	mb_end
mse_n1	cmp.w	#92,d1
	blt.s	mse_n2
	cmp.w	#105,d1
	bgt.s	mse_n2
	cmp.w	#420,d0
	blt.s	mse_c3
	cmp.w	#440,d0
	bgt.s	mse_c3
	clr.b	395(a4)
	bsr	drawech
	bra	mb_end
mse_c3	cmp.w	#449,d0
	blt.s	mse_c4
	cmp.w	#469,d0
	bgt.s	mse_c4
	move.b	#10,395(a4)
	bsr	drawech
	bra	mb_end
mse_c4	cmp.w	#478,d0
	blt.s	mb_end
	cmp.w	#498,d0
	bgt.s	mb_end
	move.b	#20,395(a4)
	bsr	drawech
	bra.s	mb_end
mse_n2	cmp.w	#111,d1
	blt.s	mb_end
	cmp.w	#124,d1
	bgt.s	mb_end
	cmp.w	#318,d0
	blt.s	mse_c5
	cmp.w	#338,d0
	bgt.s	mse_c5
	clr.b	397(a4)
	bsr	drawcv
	bra.s	mb_end
mse_c5	cmp.w	#347,d0
	blt.s	mse_c6
	cmp.w	#367,d0
	bgt.s	mse_c6
	move.b	#10,397(a4)
	bsr	drawcv
	bra.s	mb_end
mse_c6	cmp.w	#376,d0
	blt.s	mse_c7
	cmp.w	#396,d0
	bgt.s	mse_c7
	move.b	#20,397(a4)
	bsr	drawcv
	bra.s	mb_end
mse_c7	cmp.w	#405,d0
	blt.s	mb_end
	cmp.w	#425,d0
	bgt.s	mb_end
	move.b	#30,397(a4)
	bsr	drawcv
mb_end	bra	mloop

aslload	lea	loadtitle(pc),a0
	lea	asltitle(pc),a1
	move.l	a0,a1
	bsr.s	asl_requester
	tst.b	d6
	beq.s	lcf
	bsr	err_asl
	bra.s	load_e
lcf	bsr	load_config
	tst.b	d6
	beq.s	load_ud
	lea	error_title1(pc),a0
	move.l	a0,easy_title0
	bsr	err_req
	bra.s	load_e
load_ud	bsr	clear_menu
	bsr	update_config
	bsr	set_menu
load_e	bra     mloop

aslsave	lea	savetitle(pc),a0
	lea	asltitle(pc),a1
	move.l	a0,a1
	bsr.s	asl_requester
	tst.b	d6
	beq.s	scf
	bsr	err_asl
	bra.s	save_e
scf	bsr	save_config
	tst.b	d6
	beq.s	save_e
	lea	error_title2(pc),a0
	move.l	a0,easy_title0
	bsr	err_req
save_e	bra     mloop


 * Sub-Routines.

asl_requester
	moveq	#LIB_VER,d0
	lea     asl_name(pc),a1
	move.l	4.w,a6
	jsr	_LVOOpenLibrary(a6)
	move.l  d0,710(a4)
	beq     lib_failed
	moveq	#ASL_FileRequest,d0
	lea	asltags(pc),a0
	move.l	710(a4),a6
	jsr	_LVOAllocAslRequest(a6)
	move.l	d0,550(a4)
	beq	aar_failed
	move.l	d0,a0
	suba.l	a1,a1
	jsr	_LVOAslRequest(a6)
	tst.l	d0
	beq	asl_cancelled
	move.l	550(a4),a3

	move.l	#132,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,564(a4)
	beq.s	no_pathbuf
	move.l	d0,a2

	move.l	a2,d1
	move.l	fr_Drawer(a3),d2
	move.l	#132,d3
	move.l	702(a4),a6
	jsr	_LVOAddPart(a6)
	tst.l	d0
	beq.s	part_failed

	move.l	a2,d1
	move.l	fr_File(a3),d2
	move.l	#132,d3
	jsr	_LVOAddPart(a6)
	tst.l	d0
	beq.s	part_failed

	lea	dirbuf(pc),a0
	move.l	a0,d1
	move.l	fr_Drawer(a3),d2
	moveq	#100,d3
	move.l	702(a4),a6
	jsr	_LVOAddPart(a6)
	tst.l	d0
	beq.s	part_failed

	move.l	fr_File(a3),a1
	lea	filebuf(pc),a0
	bsr	stgcopy

	move.l	564(a4),a1
	lea	aslbuf(pc),a0
	bsr	stgcopy
	moveq	#0,d6
	bra.s	free_pb

part_failed
	moveq	#10,d6

free_pb	move.l	564(a4),a1
	move.l	#132,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	bra.s	free_asl

no_pathbuf
	moveq	#11,d6
	bra.s	free_asl

asl_cancelled
	moveq	#-1,d6

free_asl
	move.l	550(a4),a0
	move.l	710(a4),a6
	jsr	_LVOFreeAslRequest(a6)
	bra.s	cl_asl

aar_failed
	moveq	#14,d6
	bra.s	cl_asl

lib_failed
	moveq	#13,d6

cl_asl	move.l	710(a4),a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)
asl_end	rts

load_config
	move.l	#CONFIG_SAVESIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,572(a4)
	beq	no_cfmem
	move.l	#fib_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	jsr	_LVOAllocMem(a6)
	move.l	d0,518(a4)
	beq	no_fibmem
	moveq	#1,d7
	lea	aslbuf(pc),a3
	move.l	a3,d1
	moveq	#SHARED_LOCK,d2
	move.l	702(a4),a6
	jsr	_LVOLock(a6)
	move.l	d0,514(a4)
	beq.s	lockerr
	clr.b	d7
	move.l	514(a4),d1
	move.l	518(a4),d2
	jsr	_LVOExamine(a6)
	cmp.l	#TRUE,d0
	bne.s	examerr
	move.l	518(a4),a0
	move.l	fib_Size(a0),d5
	bra.s	freefib

lockerr
	moveq	#3,d6

	bra.s	freefib

examerr
	moveq	#4,d6


freefib	move.l	518(a4),a1
	move.l	#fib_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	cmp.b	#1,d7
	beq.s	free_cfmem

freelok	move.l	514(a4),d1
	move.l	702(a4),a6
	jsr	_LVOUnLock(a6)

	tst.l	d5
	blt.s	nofile
	cmp.l	#CONFIG_SAVESIZE,d5
	bne.s	sizeerr
	move.l	#MODE_OLDFILE,d2
	move.l	a3,d1
	jsr	_LVOOpen(a6)
	move.l	d0,506(a4)
	beq.s	erropen
	move.l	506(a4),d1
	move.l	572(a4),d2
	move.l	#CONFIG_SAVESIZE,d3
	jsr	_LVORead(a6)
	cmp.l	#CONFIG_SAVESIZE,d0
	bne.s	readerr
	moveq	#0,d0
	move.l	572(a4),a0
	move.l	a4,a1
peek	move.l	(a0)+,(a1)+
	addq.w	#4,d0
	cmp.w	#CONFIG_SAVESIZE,d0
	blt.s	peek
	moveq	#0,d6
	bra.s	cfclose

readerr
	moveq	#5,d6

cfclose	move.l	506(a4),d1
	move.l	702(a4),a6
	jsr	_LVOClose(a6)
	bra.s	free_cfmem

erropen
	moveq	#6,d6
	bra.s	free_cfmem

nofile
	moveq	#7,d6
	bra.s	free_cfmem

sizeerr
	moveq	#8,d6
	bra.s	free_cfmem

no_fibmem
	moveq	#2,d6

free_cfmem
	move.l	572(a4),a1
	move.l	#CONFIG_SAVESIZE,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	bra.s	lc_end

no_cfmem
	moveq	#1,d6

lc_end	rts

save_config
	lea	aslbuf(pc),a3
	move.l	a3,d1
	move.l	#MODE_NEWFILE,d2
	move.l	702(a4),a6
	jsr	_LVOOpen(a6)
	move.l	d0,506(a4)
	beq.s	openerr
	move.l	506(a4),d1
	move.l	a4,d2
	move.l	#CONFIG_SAVESIZE,d3
	jsr	_LVOWrite(a6)
	cmp.l	#CONFIG_SAVESIZE,d0
	bne.s	writeerr

	moveq	#0,d6
	bra.s	closecf

writeerr
	moveq	#9,d6
closecf	move.l	506(a4),d1
	move.l	702(a4),a6
	jsr	_LVOClose(a6)
	bra.s	sc_end
openerr	moveq	#6,d6
sc_end	rts

speakToMe
	move.b	396(a4),d5
	beq.s	no_cfw
	move.l	#cname,d1
	move.b	400(a4),d0
	beq.s	conmode
	move.l	#fname,d1
conmode	move.l	#MODE_NEWFILE,d2
	move.l	702(a4),a6
	jsr	_LVOOpen(a6)
	move.l	d0,510(a4)
	beq	no_con
	move.l	510(a4),d1
	lea	header(pc),a0
	move.l	a0,d2
	moveq	#34,d3
	jsr	_LVOWrite(a6)
no_cfw	clr.w	d6
	move.w	390(a4),d7
	lea	110(a4,d7.w),a0
	bsr	test_vowel
	move.l	a0,a6			; points to Vowel String.
	move.l	a5,-(sp)
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
	move.l	(sp)+,a5
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,542(a4)
	beq	cl_confile
	move.l	d0,a0
	moveq	#MRB_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,546(a4)
	beq	free_rport
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,534(a4)
	beq	free_readio
	move.l	d0,a0
	moveq	#NDI_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,538(a4)
	beq	free_wport
	move.l	d0,a1
	move.b	#NDF_NEWIORB,NDI_FLAGS(a1)
	lea	nar_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	free_writeio
	move.l	538(a4),a1
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
	move.b	(a0),d0
	cmp.b	#77,d0
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

	move.b	d5,NDI_MOUTHS(a1)
	move.b	401(a4),d0
	move.b	d0,NDI_PRIORITY(a1)
	clr.b	NDI_PAD1(a1)

	move.w	#CMD_WRITE,IO_COMMAND(a1)
	lea	transbuf(pc),a0
	move.l	a0,IO_DATA(a1)
	move.l	#142,IO_LENGTH(a1)

	tst.b	d5
	beq	no_mouth

	move.l	a1,a0
	move.l	546(a4),a1
	moveq	#NDI_SIZE,d0
	jsr	_LVOCopyMem(a6)
	move.l	546(a4),a0
	move.l	542(a4),a1
	move.l	a1,MN_REPLYPORT(a0)
	move.l	538(a4),a1
	move.l	IO_DEVICE(a1),IO_DEVICE(a0)
	move.l	IO_UNIT(a1),IO_UNIT(a0)
	move.w	#CMD_READ,IO_COMMAND(a0)
	clr.b	IO_ERROR(a0)
	clr.b	MRB_WIDTH(a0)
	clr.b	MRB_HEIGHT(a0)
	jsr	_LVOSendIO(a6)
mouth_l	move.l	4.w,a6
	move.l	546(a4),a1
	jsr	_LVODoIO(a6)
	move.l	546(a4),a1
	cmp.b	#ND_NoWrite,IO_ERROR(a1)
	beq	err_nw
	move.b	MRB_SYNC(a1),d0
	btst	#NDB_WORDSYNC,d0
	beq.s	chk_ss

	nop

chk_ss	move.b	MRB_SYNC(a1),d0
	btst	#NDB_SYLSYNC,d0
	beq.s	chk_m

	nop

chk_m	move.b	MRB_SYNC(a1),d0
	btst	#NDB_NEWIORB,d0
	beq.s	doio_m

	move.l	510(a4),d4
	beq.s	doio_m
	move.l	d4,d1
	lea	widthtxt(pc),a0
	move.l	a0,d2
	moveq	#7,d3
	move.l	702(a4),a6
	jsr	_LVOWrite(a6)

	moveq	#0,d1
	move.l	546(a4),a1
	move.b	MRB_WIDTH(a1),d1
	lea	482(a4),a0
	move.w	#255,d6
	move.w	#1,d5
	bsr	plusthree

	bsr	txt_con

	move.l	d4,d1
	move.l	#spaces,d2
	moveq	#4,d3
	jsr	_LVOWrite(a6)

	move.l	d4,d1
	lea	heighttxt(pc),a0
	move.l	a0,d2
	moveq	#8,d3
	jsr	_LVOWrite(a6)

	moveq	#0,d1
	move.l	546(a4),a1
	move.b	MRB_HEIGHT(a1),d1
	lea	482(a4),a0
	move.w	#255,d6
	move.w	#1,d5
	bsr	plusthree

	bsr	txt_con

	move.l	d4,d1
	move.l	#eol,d2
	moveq	#1,d3
	jsr	_LVOWrite(a6)

doio_m	bra	mouth_l

err_nw	move.l	4.w,a6
	move.l	538(a4),a1
	jsr	_LVOCheckIO(a6)
	tst.l	d0
	bne.s	wait
	move.l	538(a4),a1
	jsr	_LVOAbortIO(a6)
wait	move.l	538(a4),a1
	jsr	_LVOWaitIO(a6)
	tst.l	d0
	beq.s	cl_dev
	bra.s	err_nw			; STM should never execute this.

no_mouth
	jsr	_LVODoIO(a6)

cl_dev	move.l	538(a4),a1
	jsr	_LVOCloseDevice(a6)

free_writeio
	move.l	538(a4),a0
	jsr	_LVODeleteIORequest(a6)

free_wport
	move.l	534(a4),a0
	jsr	_LVODeleteMsgPort(a6)

free_readio
	move.l	546(a4),a0
	jsr	_LVODeleteIORequest(a6)

free_rport
	move.l	542(a4),a0
	jsr	_LVODeleteMsgPort(a6)

cl_confile
	move.b	396(a4),d0
	beq.s	stm_end
	move.l	510(a4),d1
	move.l	#eol,d2
	moveq	#1,d3
	move.l	702(a4),a6
	jsr	_LVOWrite(a6)
	move.l	510(a4),d1
	lea	tailend(pc),a0
	move.l	a0,d2
	moveq	#31,d3
	jsr	_LVOWrite(a6)
	move.b	400(a4),d0
	bne.s	no_dly
	moveq	#0,d1
	move.w	562(a4),d1
	jsr	_LVODelay(a6)
no_dly	move.l	510(a4),d1
	jsr	_LVOClose(a6)
	bra.s	stm_end
no_con
	nop

stm_end	rts

txt_con	move.l	d4,d1
	lea	482(a4),a0
	move.l	a0,d2
	moveq	#3,d3
	jsr	_LVOWrite(a6)
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
	move.l	702(a4),a6
	jsr	_LVOStrToLong(a6)
        cmp.l  #TRUE,d0
        beq.s   val_nil
	move.l	longval,d0
        cmp.l	d4,d0
        bgt.s   val_nil
        cmp.l	d3,d0
        blt.s   val_nil
	rts
val_nil	move.l	694(a4),a6
	move.l	a3,a1
	bsr	rmg
	move.l	d5,(a2)
	move.l	#$30000000,4(a2)
	move.l	a3,a1
	bsr	adg
	move.l	a3,a0
	bsr	rfg
	moveq	#0,d0
	rts

findlen	move.l	a0,a1
        moveq	#0,d0
not_nil	tst.b   (a1)+
        beq.s	got_len
        addq.b	#1,d0
        bra.s	not_nil
got_len	rts

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
        move.l  #longval,d2
	move.l	702(a4),a6
	jsr	_LVOStrToLong(a6)
        cmp.l  #TRUE,d0
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

drawamp	move.l	694(a4),a6
	move.b	394(a4),d3
	lea	image40(pc),a1
	move.w	#430,(a1)
	move.w	#73,ig_TopEdge(a1)
	tst.b	d3
	beq.s	mm0
	move.l	#id27,ig_ImageData(a1)
	bra.s	mm0_d
mm0	move.l	#id28,ig_ImageData(a1)
mm0_d	bsr	drawi
	lea	image40(pc),a1
	move.w	#459,(a1)
	cmp.b	#10,d3
	beq.s	mm1
	move.l	#id27,ig_ImageData(a1)
	bra.s	mm1_d
mm1	move.l	#id28,ig_ImageData(a1)
mm1_d	bsr	drawi
	lea	image40(pc),a1
	move.w	#488,(a1)
	cmp.b	#20,d3
	beq.s	mm2
	move.l	#id27,ig_ImageData(a1)
	bra.s	mm2_d
mm2	move.l	#id28,ig_ImageData(a1)
mm2_d	bsr	drawi
	move.l	698(a4),a6
	bsr	pen_a2
	bsr	pen_b0
	tst.b	d3
	beq.s	mt0
	cmp.b	#10,d3
	beq.s	mt1
	move.w	#493,d0
        move.w	#82,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num3(pc),a0
	bra.s	di1_d
mt0	move.w	#435,d0
        move.w	#82,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num1(pc),a0
	bra.s	di1_d
mt1	move.w	#464,d0
        move.w	#82,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num2(pc),a0
di1_d	bsr	text_1
	move.l	694(a4),a6
	lea	gd31(pc),a1
	bsr	rmg
	move.w	390(a4),d7
	add.b	394(a4),d7
	lea	80(a4,d7.w),a0
	moveq	#0,d1
	move.b	(a0),d1
	lea	numb11(pc),a0
	move.b	#31,d6
	move.b	#1,d5
	bsr	minusplus
	lea	gd31(pc),a1
	bsr	adg
	lea	gd31(pc),a0
	bsr	rfg
	rts

drawech	move.l	694(a4),a6
	move.b	395(a4),d3
	lea	image40(pc),a1
	move.w	#420,(a1)
	move.w	#92,ig_TopEdge(a1)
	tst.b	d3
	beq.s	mm3
	move.l	#id27,ig_ImageData(a1)
	bra.s	mm3_d
mm3	move.l	#id28,ig_ImageData(a1)
mm3_d	bsr	drawi
	lea	image40(pc),a1
	move.w	#449,(a1)
	cmp.b	#10,d3
	beq.s	mm4
	move.l	#id27,ig_ImageData(a1)
	bra.s	mm4_d
mm4	move.l	#id28,ig_ImageData(a1)
mm4_d	bsr	drawi
	lea	image40(pc),a1
	move.w	#478,(a1)
	cmp.b	#20,d3
	beq.s	mm5
	move.l	#id27,ig_ImageData(a1)
	bra.s	mm5_d
mm5	move.l	#id28,ig_ImageData(a1)
mm5_d	bsr	drawi
	move.l	698(a4),a6
	bsr	pen_a2
	bsr	pen_b0
	tst.b	d3
	beq.s	mt3
	cmp.b	#10,d3
	beq.s	mt4
	move.w	#483,d0
        move.w	#101,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num3(pc),a0
	bra.s	di2_d
mt3	move.w	#425,d0
        move.w	#101,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num1(pc),a0
	bra.s	di2_d
mt4	move.w	#454,d0
        move.w	#101,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num2(pc),a0
di2_d	bsr	text_1
	move.l	694(a4),a6
	lea	gd33(pc),a1
	bsr	rmg
	move.w	390(a4),d7
	add.w	#130,d7
	add.b	395(a4),d7
	moveq	#0,d1
	move.b	0(a4,d7.w),d1
	lea	numb13(pc),a0
	move.b	#31,d6
	move.b	#1,d5
	bsr	minusplus
	lea	gd33(pc),a1
	bsr	adg
	lea	gd33(pc),a0
	bsr	rfg
	rts

drawcv	move.l	694(a4),a6
	move.b	397(a4),d3
	lea	image40(pc),a1
	move.w	#318,(a1)
	move.w	#111,ig_TopEdge(a1)
	tst.b	d3
	beq.s	mm6
	move.l	#id27,ig_ImageData(a1)
	bra.s	mm6_d
mm6	move.l	#id28,ig_ImageData(a1)
mm6_d	bsr	drawi
	lea	image40(pc),a1
	move.w	#347,(a1)
	cmp.b	#10,d3
	beq.s	mm7
	move.l	#id27,ig_ImageData(a1)
	bra.s	mm7_d
mm7	move.l	#id28,ig_ImageData(a1)
mm7_d	bsr	drawi
	lea	image40(pc),a1
	move.w	#376,(a1)
	cmp.b	#20,d3
	beq.s	mm8
	move.l	#id27,ig_ImageData(a1)
	bra.s	mm8_d
mm8	move.l	#id28,ig_ImageData(a1)
mm8_d	bsr	drawi
	lea	image40(pc),a1
	move.w	#405,(a1)
	cmp.b	#30,d3
	beq.s	mm9
	move.l	#id27,ig_ImageData(a1)
	bra.s	mm9_d
mm9	move.l	#id28,ig_ImageData(a1)
mm9_d	bsr	drawi
	move.l	698(a4),a6
	bsr	pen_a2
	bsr	pen_b0
	tst.b	d3
	beq.s	mt6
	cmp.b	#10,d3
	beq.s	mt7
	cmp.b	#20,d3
	beq.s	mt8
	move.w	#410,d0
        move.w	#120,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num4(pc),a0
	bra.s	di3_d
mt6	move.w	#323,d0
        move.w	#120,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num1(pc),a0
	bra.s	di3_d
mt7	move.w	#352,d0
        move.w	#120,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num2(pc),a0
	bra.s	di3_d
mt8	move.w	#381,d0
        move.w	#120,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
        lea     num3(pc),a0
di3_d	bsr	text_1
	move.l	694(a4),a6
	lea	gd34(pc),a1
	bsr	rmg
	move.w	390(a4),d7
	add.w	#170,d7
	add.b	397(a4),d7
	moveq	#0,d1
	move.b	0(a4,d7.w),d1
	lea	numb14(pc),a0
	move.w	#15,d6
	move.w	#1,d5
	bsr	plustwo
	lea	gd34(pc),a1
	bsr	adg
	lea	gd34(pc),a0
	bsr	rfg
	rts

drawi	move.l	a5,a0
	clr.w	d0
	clr.w	d1
	jsr	_LVODrawImage(a6)
	rts

pen_a0	clr.b	d0
	bra.s	do_pena
pen_a1	move.b	#1,d0
	bra.s	do_pena
pen_a2	move.b	#2,d0
	bra.s	do_pena
pen_a3	move.b	#3,d0
do_pena	move.l	a5,a1
	jsr	_LVOSetAPen(a6)
	rts

pen_b0	clr.b	d0
	bra.s	do_penb
pen_b1	move.b	#1,d0
	bra.s	do_penb
pen_b2	move.b	#2,d0
	bra.s	do_penb
pen_b3	move.b	#3,d0
do_penb	move.l	a5,a1
	jsr	_LVOSetBPen(a6)
	rts

text_1	moveq	#1,d0
	bra.s	do_text
text_2	moveq	#2,d0
	bra.s	do_text
text_7	moveq	#7,d0
	bra.s	do_text
text_13	moveq	#13,d0
do_text	move.l  a5,a1
	jsr	_LVOText(a6)
	rts

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
lang_loop
	move.l	(a0)+,a1
	move.l	(a1),(a2)
	move.l	4(a1),4(a2)
	move.l	8(a1),8(a2)
	lea	12(a2),a2
	dbra	d0,lang_loop
	move.w	#2,(a2)+		; 390 sph
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

 * LGUI Config starts here.

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

 * Misc. STM program variable values.
					; 478 task's return message
					; 482 12 bytes buffer
					; 494 window address
					; 498 iclass
					; 502 iaddress
					; 506 File Handler address
					; 510 CLI File Handler address
					; 514 Lock address
					; 518 FIB address
					; 522 doptr
					; 526 rdargs
					; 530 old directory
					; 534 writeport
					; 538 writeio
					; 542 readport
					; 546 readio
					; 550 reqptr
					; 554 icode 
					; 556 iqual
					; 558 msex
					; 560 msey
	move.w	#100,562(a4)		; 562 pause
					; 564 path buffer address
					; 568 string font address
					; 572 cfmem
					; 574 30 argv addresses
					; 694 _IntuitionBase
					; 698 _GfxBase
					; 702 _DOSBase
					; 706 _IconBase
					; 710 _AslBase
					; 714 _TranslatorBase
	rts

update_config
	lea	menulist(pc),a0
	move.w	390(a4),d7
	move.l	0(a0,d7.w*4),a1
	move.w	mi_Flags(a1),d0
	bclr	#8,d0
	move.w	d0,mi_Flags(a1)
	lea	390(a4),a1
	move.w	(a1)+,d7
	move.w	d7,390(a4)
	move.w	(a1),d6
	move.w	d6,392(a4)
	move.l	0(a0,d6.w*4),a1
	move.w	mi_Flags(a1),d0
	bclr	#8,d0
	move.w	d0,mi_Flags(a1)
	move.l	0(a0,d7.w*4),a1
	or.w	#CHECKED,mi_Flags(a1)
	move.l	698(a4),a6
	bsr	pen_a1
	bsr	pen_b2
	move.w	#77,d0
        move.w	#25,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea	0(a4,d7.w),a0
	bsr	text_1
        move.w	#192,d0
        move.w	#25,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea	10(a4,d7.w),a0
	tst.b	(a0)
	beq.s	manual
	cmp.b	#1,(a0)
	beq.s	robotic
        lea     mode2(pc),a0
	bra.s	mode
manual	lea     mode0(pc),a0
	bra.s	mode
robotic	lea     mode1(pc),a0
mode	bsr	text_7
        move.w	#100,d0
        move.w	#101,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea	110(a4,d7.w),a0
	tst.b	(a0)
	beq.s	blank
	cmp.b	#1,(a0)
	beq.s	aa
	cmp.b	#2,(a0)
	beq.s	ae
	cmp.b	#3,(a0)
	beq.s	ah
	cmp.b	#4,(a0)
	beq.s	ao
	cmp.b	#5,(a0)
	beq.s	eh
	cmp.b	#6,(a0)
	beq.s	er
	cmp.b	#7,(a0)
	beq.s	ih
	cmp.b	#8,(a0)
	beq.s	iy
	cmp.b	#9,(a0)
	beq.s	ow
	cmp.b	#10,(a0)
	beq.s	uh
	lea     vowel11(pc),a0
	bra.s	vowel
blank	lea     vowel0(pc),a0
	bra.s	vowel
aa	lea     vowel1(pc),a0
	bra.s	vowel
ae	lea     vowel2(pc),a0
	bra.s	vowel
ah	lea     vowel3(pc),a0
	bra.s	vowel
ao	lea     vowel4(pc),a0
	bra.s	vowel
eh	lea     vowel5(pc),a0
	bra.s	vowel
er	lea     vowel6(pc),a0
	bra.s	vowel
ih	lea     vowel7(pc),a0
	bra.s	vowel
iy	lea     vowel8(pc),a0
	bra.s	vowel
ow	lea     vowel9(pc),a0
	bra.s	vowel
uh	lea     vowel10(pc),a0
vowel	bsr	text_2
        move.w	#155,d0
        move.w	#120,d1
        move.l  a5,a1
	jsr	_LVOMove(a6)
	lea	160(a4),a0
	lea	0(a0,d7.w),a0
	cmp.b	#49,(a0)
	beq.s	ch_1
	cmp.b	#50,(a0)
	beq.s	ch_2
	cmp.b	#51,(a0)
	beq.s	ch_3
        lea     num4(pc),a0
	bra.s	ch_num
ch_1	lea     num1(pc),a0
	bra.s	ch_num
ch_2	lea     num2(pc),a0
	bra.s	ch_num
ch_3	lea     num3(pc),a0
ch_num	bsr	text_1
	move.l	694(a4),a6

	lea	gd22(pc),a1
	bsr	rmg
	moveq	#0,d1
	move.b	20(a4,d7.w),d1
	lea	numb2(pc),a0
	move.w	#64,d6
	move.w	#1,d5
	bsr	plustwo
	lea	gd22(pc),a1
	bsr	adg

	lea	gd23(pc),a1
	bsr	rmg
	move.l	a4,a0
	lea	210(a0),a0
	moveq	#0,d1
	move.w	0(a0,d7.w*2),d1
	lea	numb3(pc),a0
	move.w	#320,d6
	move.w	#65,d5
	bsr	plusthree
	lea	gd23(pc),a1
	bsr	adg

	lea	gd24(pc),a1
	bsr	rmg
	move.l	a4,a0
	lea	230(a0),a0
	moveq	#0,d1
	move.w	0(a0,d7.w*2),d1
	lea	numb4(pc),a0
	move.w	#400,d6
	move.w	#40,d5
	bsr	plusthree
	lea	gd24(pc),a1
	bsr	adg

	lea	gd25(pc),a1
	bsr	rmg
	move.l	a4,a0
	lea	250(a0),a0
	moveq	#0,d1
	move.w	0(a0,d7.w*2),d1
	lea	numb5(pc),a0
	move.w	#28000,d6
	move.w	#10000,d5
	bsr	plusfive
	lea	gd25(pc),a1
	bsr	adg

	lea	gd26(pc),a1
	bsr	rmg
	moveq	#0,d1
	move.b	30(a4,d7.w),d1
	lea	numb6(pc),a0
	move.w	#255,d6
	move.w	#1,d5
	bsr	plusthree
	lea	gd26(pc),a1
	bsr	adg

	lea	gd27(pc),a1
	bsr	rmg
	moveq	#0,d1
	move.b	40(a4,d7.w),d1
	lea	numb7(pc),a0
	move.w	#255,d6
	move.w	#1,d5
	bsr	plusthree
	lea	gd27(pc),a1
	bsr	adg

	lea	gd28(pc),a1
	bsr	rmg
	moveq	#0,d1
	move.b	50(a4,d7.w),d1
	lea	numb8(pc),a0
	move.w	#255,d6
	move.w	#1,d5
	bsr	plusthree
	lea	gd28(pc),a1
	bsr	adg

	lea	gd29(pc),a1
	bsr	rmg
	moveq	#0,d1
	move.b	60(a4,d7.w),d1
	lea	numb9(pc),a0
	move.w	#31,d6
	move.w	#1,d5
	bsr	minusplus
	lea	gd29(pc),a1
	bsr	adg

	lea	gd30(pc),a1
	bsr	rmg
	moveq	#0,d1
	move.b	70(a4,d7.w),d1
	lea	numb10(pc),a0
	move.w	#31,d6
	move.w	#1,d5
	bsr	minusplus
	lea	gd30(pc),a1
	bsr	adg

	lea	gd31(pc),a1
	bsr	rmg
	move.w	d7,d6
	add.b	394(a4),d6
	moveq	#0,d1
	move.b	80(a4,d6.w),d1
	lea	numb11(pc),a0
	move.w	#31,d6
	move.w	#1,d5
	bsr	minusplus
	lea	gd31(pc),a1
	bsr	adg

	lea	gd32(pc),a1
	bsr	rmg
	moveq	#0,d1
	move.b	120(a4,d7.w),d1
	lea	numb12(pc),a0
	move.w	#100,d6
	move.w	#1,d5
	bsr	plusthree
	lea	gd32(pc),a1
	bsr	adg

	lea	gd33(pc),a1
	bsr	rmg
	move.w	d7,d6
	add.w	#130,d6
	add.b	395(a4),d6
	moveq	#0,d1
	move.b	0(a4,d6.w),d1
	lea	numb13(pc),a0
	move.w	#31,d6
	move.w	#1,d5
	bsr	minusplus
	lea	gd33(pc),a1
	bsr	adg

	lea	gd34(pc),a1
	bsr	rmg
	move.w	d7,d6
	add.w	#170,d6
	add.b	397(a4),d6
	moveq	#0,d1
	move.b	0(a4,d6.w),d1
	lea	numb14(pc),a0
	move.w	#31,d6
	move.w	#1,d5
	bsr	minusplus
	lea	gd34(pc),a1
	bsr	adg

	lea	gd35(pc),a1
	bsr	rmg

	lea	voiceb(pc),a0
	lea	270(a4),a1
	moveq	#0,d0
	move.w	390(a4),d0
	mulu	#12,d0
	add.l	d0,a1
	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.l	8(a1),8(a0)

	lea	gd35(pc),a1
	bsr	adg

	lea	gd22(pc),a0
	bsr	rfg

	lea	270(a4),a0
	lea	langlist(pc),a1
	moveq	#9,d0
mt_loop	move.l	(a1),a2
	move.l	(a0),(a2)
	move.l	4(a0),4(a2)
	move.l	8(a0),8(a2)
	lea	12(a0),a0
	addq.l	#4,a1
	dbra	d0,mt_loop
	
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

actg	move.l  494(a4),a1
        suba.l  a2,a2
        move.l  694(a4),a6
        jsr	_LVOActivateGadget(a6)
	rts

rmg	move.l	494(a4),a0
	jsr	_LVORemoveGadget(a6)
	rts

adg	move.l	494(a4),a0
	moveq	#-1,d0
	jsr	_LVOAddGadget(a6)
	rts

rfg	move.l	494(a4),a1
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)
	rts

clear_menu
	move.l  494(a4),a0
	move.l	694(a4),a6
	jsr	_LVOClearMenuStrip(a6)
	rts

set_menu
	move.l  494(a4),a0
        lea     menu0(pc),a1
	move.l	694(a4),a6
	jsr	_LVOSetMenuStrip(a6)
	rts

test_vowel
	tst.b	(a0)
	beq.s	vowel_0
	cmp.b	#1,(a0)
	beq.s	vowel_1
	cmp.b	#2,(a0)
	beq.s	vowel_2
	cmp.b	#3,(a0)
	beq.s	vowel_3
	cmp.b	#4,(a0)
	beq.s	vowel_4
	cmp.b	#5,(a0)
	beq.s	vowel_5
	cmp.b	#6,(a0)
	beq.s	vowel_6
	cmp.b	#7,(a0)
	beq.s	vowel_7
	cmp.b	#8,(a0)
	beq.s	vowel_8
	cmp.b	#9,(a0)
	beq.s	vowel_9
	cmp.b	#10,(a0)
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

err_req	move.l	494(a4),a0
	lea	easy_defs0(pc),a1
	lea	easy_args0(pc),a3
	move.l	d5,4(a3)
	lea	errorlist(pc),a2
	move.l	0(a2,d6.w*4),8(a3)
	suba.l	a2,a2
	move.l	694(a4),a6
	jsr	_LVOEasyRequestArgs(a6)
	rts

err_asl	cmp.l	#-1,d6
	beq.s	ea_end
	move.l	494(a4),a0
	lea	easy_defs1(pc),a1
	lea	easy_args1(pc),a3
	lea	errorlist(pc),a2
	move.l	0(a2,d6.w*4),(a3)
	suba.l	a2,a2
	move.l	694(a4),a6
	jsr	_LVOEasyRequestArgs(a6)
ea_end	rts

clrnarb	lea	narb(pc),a0
	bra.s	do_clr
clrtran	lea	transbuf(pc),a0
do_clr	clr.b	d0
clrbuf	clr.b	(a0)+
	addq.b	#1,d0
	cmp.b	#142,d0
	bgt.s	clrbuf
	rts


 * Structure Definitions.

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

itext0
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,mistg0,0

itext1
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,mistg1,0

itext2
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,mistg2,0

itext10
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,tagalog,0

itext11
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,danish,0

itext12
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,english,0

itext13
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,french,0

itext14
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,german,0

itext15
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,icelandic,0

itext16
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,italian,0

itext17
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,norwegian,0

itext18
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,spanish,0

itext19
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,swedish,0

itext20
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,mistg20,0

itext21
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,mistg21,0

itext22
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,mistg22,0

itext23
        dc.b    0,1,0,0
        dc.w    0,0
        dc.l    topaz9,mistg23,0

menu0
        dc.l    menu1
        dc.w    0,0,188,10,MENUENABLED
        dc.l    mmstg0,menuitem0
        dc.w    0,0,0,0

menuitem0
        dc.l    menuitem1
        dc.w    0,0,180,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext0,0
        dc.b    76,0
        dc.l    0,0

menuitem1
        dc.l    menuitem2
        dc.w    0,10,180,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext1,0
        dc.b    83,0
        dc.l    0,0

menuitem2
        dc.l    0
        dc.w    0,20,180,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
        dc.l    0,itext2,0
        dc.b    81,0
        dc.l    0,0

menu1
        dc.l    menu2
        dc.w    190,0,178,10,MENUENABLED
        dc.l    mmstg1,menuitem10
        dc.w    0,0,0,0

menuitem10
        dc.l    menuitem11
        dc.w    0,0,170,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT
        dc.l    $000003FE,itext10,0
        dc.b    49,0
        dc.l    0,0

menuitem11
        dc.l    menuitem12
        dc.w    0,10,170,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT
        dc.l    $000003FD,itext11,0
        dc.b    50,0
        dc.l    0,0

menuitem12
        dc.l    menuitem13
        dc.w    0,20,170,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT
        dc.l    $000003FB,itext12,0
        dc.b    51,0
        dc.l    0,0

menuitem13
        dc.l    menuitem14
        dc.w    0,30,170,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT
        dc.l    $000003F7,itext13,0
        dc.b    52,0
        dc.l    0,0

menuitem14
        dc.l    menuitem15
        dc.w    0,40,170,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT
        dc.l    $000003EF,itext14,0
        dc.b    53,0
        dc.l    0,0

menuitem15
        dc.l    menuitem16
        dc.w    0,50,170,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT
        dc.l    $000003DF,itext15,0
        dc.b    54,0
        dc.l    0,0

menuitem16
        dc.l    menuitem17
        dc.w    0,60,170,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT
        dc.l    $000003BF,itext16,0
        dc.b    55,0
        dc.l    0,0

menuitem17
        dc.l    menuitem18
        dc.w    0,70,170,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT
        dc.l    $0000037F,itext17,0
        dc.b    56,0
        dc.l    0,0

menuitem18
        dc.l    menuitem19
        dc.w    0,80,170,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT
        dc.l    $000002FF,itext18,0
        dc.b    57,0
        dc.l    0,0

menuitem19
        dc.l    0
        dc.w    0,90,170,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT
        dc.l    $000001FF,itext19,0
        dc.b    48,0
        dc.l    0,0

menu2
        dc.l    0
        dc.w    370,0,228,10,MENUENABLED
        dc.l    mmstg2,menuitem20
        dc.w    0,0,0,0

menuitem20
        dc.l    menuitem21
        dc.w    0,0,220,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT!MENUTOGGLE
        dc.l    0,itext20,0
        dc.b    85,0
        dc.l    0,0

menuitem21
        dc.l    menuitem22
        dc.w    0,10,220,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT!MENUTOGGLE!CHECKED
        dc.l    0,itext21,0
        dc.b    87,0
        dc.l    0,0

menuitem22
        dc.l    menuitem23
        dc.w    0,20,220,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT!MENUTOGGLE!CHECKED
	dc.l    0,itext22,0
        dc.b    89,0
        dc.l    0,0

menuitem23
        dc.l    0
        dc.w    0,30,220,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT!MENUTOGGLE!CHECKED
        dc.l    0,itext23,0
        dc.b    70,0
        dc.l    0,0

easy_defs0
	dc.l	EasyStruct_SIZEOF,0
easy_title0
	dc.l	0
	dc.l	easy_txt0,easy_gads0

easy_args0
	dc.l	aslbuf
	dc.l	0
	dc.l	0

easy_defs1
	dc.l	EasyStruct_SIZEOF,0,easy_title1,easy_txt1,easy_gads0

easy_args1
	dc.l	0

scrn_title
        dc.b    'J.White, 91 Comber House, Comber Grove, Camberwell, London SE5 0LL, ENGLAND.',0
        even

wndw_title
        dc.b    'Speak To Me V3.00 - Shareware (£2.50).',0
        even

wndwtags
        dc.l    WA_Top,0
        dc.l    WA_Left,0
        dc.l    WA_Width,590
        dc.l    WA_Height,170
        dc.l    WA_DetailPen,0
        dc.l    WA_BlockPen,1
        dc.l    WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_MENUPICK!IDCMP_MENUHELP!IDCMP_CLOSEWINDOW
        dc.l    WA_ScreenTitle,scrn_title
        dc.l    WA_Title,wndw_title
        dc.l    WA_Activate,TRUE
        dc.l    WA_CloseGadget,TRUE
        dc.l    WA_DepthGadget,TRUE
        dc.l    WA_DragBar,TRUE
        dc.l    WA_NoCareRefresh,TRUE
        dc.l    WA_SmartRefresh,TRUE
        dc.l    WA_MenuHelp,TRUE
        dc.l    WA_PubScreen
wndwscrn
        dc.l    0
        dc.l    TAG_DONE

asltags
	dc.l	ASLFR_InitialLeftEdge,0
	dc.l	ASLFR_InitialTopEdge,0
	dc.l	ASLFR_InitialWidth,305
	dc.l	ASLFR_InitialHeight,150
	dc.l	ASLFR_TextAttr,topaz9
	dc.l	ASLFR_TitleText
asltitle
	dc.l	0
	dc.l	ASLFR_PositiveText,okstg
	dc.l	ASLFR_NegativeText,cancelstg
	dc.l	ASLFR_InitialDrawer,dirbuf
	dc.l	ASLFR_InitialFile,filebuf
	dc.l	TAG_DONE

image40
	dc.w	430,73,21,14,2
	dc.l	id28
	dc.b	3,0
	dc.l	0

image39
	dc.w	0,0,68,14,2
	dc.l	id7
	dc.b	3,0
	dc.l	0

image38
	dc.w	0,0,68,14,2
	dc.l	id26
	dc.b	3,0
	dc.l	0

image37
	dc.w	0,0,68,14,2
	dc.l	id7
	dc.b	3,0
	dc.l	0

image36
	dc.w	0,0,68,14,2
	dc.l	id25
	dc.b	3,0
	dc.l	0

image35
	dc.w	0,0,113,14,2
	dc.l	id15
	dc.b	3,0
	dc.l	0

image34
	dc.w	0,0,113,14,2
	dc.l	id24
	dc.b	3,0
	dc.l	0

image33
	dc.w	0,0,123,14,2
	dc.l	id17
	dc.b	3,0
	dc.l	0

image32
	dc.w	0,0,123,14,2
	dc.l	id23
	dc.b	3,0
	dc.l	0

image31
	dc.w	0,0,57,14,2
	dc.l	id3
	dc.b	3,0
	dc.l	0

image30
	dc.w	0,0,57,14,2
	dc.l	id5
	dc.b	3,0
	dc.l	0

image29
	dc.w	0,0,123,14,2
	dc.l	id17
	dc.b	3,0
	dc.l	0

image28
	dc.w	0,0,123,14,2
	dc.l	id22
	dc.b	3,0
	dc.l	0

image27
	dc.w	0,0,68,14,2
	dc.l	id7
	dc.b	3,0
	dc.l	0

image26
	dc.w	0,0,68,14,2
	dc.l	id12
	dc.b	3,0
	dc.l	0

image25
	dc.w	0,0,90,14,2
	dc.l	id20
	dc.b	3,0
	dc.l	0

image24
	dc.w	0,0,90,14,2
	dc.l	id21
	dc.b	3,0
	dc.l	0

image23
	dc.w	0,0,79,14,2
	dc.l	id9
	dc.b	3,0
	dc.l	0

image22
	dc.w	0,0,79,14,2
	dc.l	id11
	dc.b	3,0
	dc.l	0

image21
	dc.w	0,0,79,14,2
	dc.l	id9
	dc.b	3,0
	dc.l	0

image20
	dc.w	0,0,79,14,2
	dc.l	id10
	dc.b	3,0
	dc.l	0

image19
	dc.w	0,0,90,14,2
	dc.l	id20
	dc.b	3,0
	dc.l	0

image18
	dc.w	0,0,90,14,2
	dc.l	id19
	dc.b	3,0
	dc.l	0

image17
	dc.w	0,0,123,14,2
	dc.l	id17
	dc.b	3,0
	dc.l	0

image16
	dc.w	0,0,123,14,2
	dc.l	id18
	dc.b	3,0
	dc.l	0

image15
	dc.w	0,0,123,14,2
	dc.l	id17
	dc.b	3,0
	dc.l	0

image14
	dc.w	0,0,123,14,2
	dc.l	id16
	dc.b	3,0
	dc.l	0

image13
	dc.w	0,0,68,14,2
	dc.l	id7
	dc.b	3,0
	dc.l	0

image12
	dc.w	0,0,68,14,2
	dc.l	id13
	dc.b	3,0
	dc.l	0
image11
	dc.w	0,0,113,14,2
	dc.l	id15
	dc.b	3,0
	dc.l	0

image10
	dc.w	0,0,113,14,2
	dc.l	id14
	dc.b	3,0
	dc.l	0

image9
	dc.w	0,0,57,14,2
	dc.l	id3
	dc.b	3,0
	dc.l	0

image8
	dc.w	0,0,57,14,2
	dc.l	id4
	dc.b	3,0
	dc.l	0

image7
	dc.w	0,0,68,14,2
	dc.l	id7
	dc.b	3,0
	dc.l	0

image6
	dc.w	0,0,68,14,2
	dc.l	id6
	dc.b	3,0
	dc.l	0

image5
	dc.w	0,0,79,14,2
	dc.l	id9
	dc.b	3,0
	dc.l	0

image4
	dc.w	0,0,79,14,2
	dc.l	id8
	dc.b	3,0
	dc.l	0

image3
	dc.w	0,0,57,14,2
	dc.l	id3
	dc.b	3,0
	dc.l	0

image2
	dc.w	0,0,57,14,2
	dc.l	id2
	dc.b	3,0
	dc.l	0

image1
	dc.w	0,0,47,14,2
	dc.l	id1
	dc.b	3,0
	dc.l	0

image0
	dc.w	0,0,47,14,2
	dc.l	id0
	dc.b	3,0
	dc.l	0

se15
sefnt15
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si15
	dc.l	voiceb,voiceub
	dc.w	0,12,0,0,0,0,0,0
	dc.l	se15,0,0

gd35
	dc.l	0
	dc.w	450,38,120,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si15
	dc.w	35
        dc.l	0

se14
sefnt14
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si14
	dc.l	numb14,numub14
	dc.w	0,3,0,0,0,0,0,0
	dc.l	se14,0,0

gd34
	dc.l	0
	dc.w	444,114,30,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si14
	dc.w	34
        dc.l	0

se13
sefnt13
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si13
	dc.l	numb13,numub13
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se13,0,0

gd33
	dc.l	0
	dc.w	517,95,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si13
	dc.w	33
        dc.l	0

se12
sefnt12
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si12
	dc.l	numb12,numub12
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se12,0,0

gd32
	dc.l	0
	dc.w	293,95,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si12
	dc.w	32
        dc.l	0

se11
sefnt11
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si11
	dc.l	numb11,numub11
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se11,0,0

gd31
	dc.l	0
	dc.w	527,76,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si11
	dc.w	31
        dc.l	0

se10
sefnt10
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si10
	dc.l	numb10,numub10
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se10,0,0

gd30
	dc.l	0
	dc.w	270,76,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si10
	dc.w	30
        dc.l	0

se9
sefnt9
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si9
	dc.l	numb9,numub9
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se9,0,0

gd29
	dc.l	0
	dc.w	111,76,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si9
	dc.w	29
        dc.l	0

se8
sefnt8
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si8
	dc.l	numb8,numub8
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se8,0,0

gd28
	dc.l	0
	dc.w	528,57,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si8
	dc.w	28
        dc.l	0

se7
sefnt7
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si7
	dc.l	numb7,numub7
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se7,0,0

gd27
	dc.l	0
	dc.w	358,57,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si7
	dc.w	27
        dc.l	0

se6
sefnt6
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si6
	dc.l	numb6,numub6
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se6,0,0

gd26
	dc.l	0
	dc.w	155,57,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si6
	dc.w	26
        dc.l	0

se5
sefnt5
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si5
	dc.l	numb5,numub5
	dc.w	0,6,0,0,0,0,0,0
	dc.l	se5,0,0

gd25
	dc.l	0
	dc.w	282,38,60,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si5
	dc.w	25
        dc.l	0

se4
sefnt4
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si4
	dc.l	numb4,numub4
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se4,0,0

gd24
	dc.l	0
	dc.w	89,38,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si4
	dc.w	24
        dc.l	0

se3
sefnt3
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si3
	dc.l	numb3,numub3
	dc.w	0,4,0,0,0,0,0,0
	dc.l	se3,0,0

gd23
	dc.l	0
	dc.w	527,19,40,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si3
	dc.w	23
        dc.l	0

se2
sefnt2
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si2
	dc.l	numb2,numub2
	dc.w	0,3,0,0,0,0,0,0
	dc.l	se2,0,0

gd22
	dc.l	0
	dc.w	389,19,30,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_LONGINT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si2
	dc.w	22
        dc.l	0

gd21
	dc.l	0
	dc.w	498,149,90,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image38,image39,0,0,0
	dc.w	21
        dc.l	0

gd20
	dc.l	0
	dc.w	498,130,90,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image36,image37,0,0,0
	dc.w	20
        dc.l	0

gd19
	dc.l	0
	dc.w	364,35,68,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image12,image13,0,0,0
	dc.w	19
        dc.l	0

gd18
	dc.l	0
	dc.w	14,111,123,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image32,image33,0,0,0
	dc.w	18
        dc.l	0

gd17
	dc.l	0
	dc.w	14,92,68,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image26,image27,0,0,0
	dc.w	17
        dc.l	0

gd16
	dc.l	0
	dc.w	197,111,113,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image34,image35,0,0,0
	dc.w	16
        dc.l	0
gd15
	dc.l	0
	dc.w	355,92,57,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image30,image31,0,0,0
	dc.w	15
        dc.l	0

gd14
	dc.l	0
	dc.w	152,92,123,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image28,image29,0,0,0
	dc.w	14
        dc.l	0

gd13
	dc.l	0
	dc.w	332,73,90,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image24,image25,0,0,0
	dc.w	13
        dc.l	0

gd12
	dc.l	0
	dc.w	173,73,79,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image22,image23,0,0,0
	dc.w	12
        dc.l	0

gd11
	dc.l	0
	dc.w	14,73,79,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image20,image21,0,0,0
	dc.w	11
        dc.l	0

gd10
	dc.l	0
	dc.w	420,54,90,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image18,image19,0,0,0
	dc.w	10
        dc.l	0

gd9
	dc.l	0
	dc.w	217,54,123,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image16,image17,0,0,0
	dc.w	9
        dc.l	0

gd8
	dc.l	0
	dc.w	14,54,123,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image14,image15,0,0,0
	dc.w	8
        dc.l	0

gd7
	dc.l	0
	dc.w	151,35,113,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image10,image11,0,0,0
	dc.w	7
        dc.l	0

gd6
	dc.l	0
	dc.w	14,35,57,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image8,image9,0,0,0
	dc.w	6
        dc.l	0

gd5
	dc.l	0
	dc.w	441,16,68,15,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image6,image7,0,0,0
	dc.w	5
        dc.l	0

gd4
	dc.l	0
	dc.w	292,16,79,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image4,image5,0,0,0
	dc.w	4
        dc.l	0

gd3
	dc.l	0
	dc.w	118,16,57,15,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image2,image3,0,0,0
	dc.w	3
        dc.l	0

gd2
	dc.l	0
	dc.w	14,16,47,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET
	dc.l	image0,image1,0,0,0
	dc.w	2
        dc.l	0

se1
sefnt1
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si1
	dc.l	narb,narub
	dc.w	0,142,0,0,0,0,0,0
	dc.l	se1,0,0

gd1
	dc.l	0
	dc.w	169,152,310,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si1
	dc.w	1
        dc.l	0

se0
sefnt0
	dc.l	0
	dc.b	2,1,3,1
	dc.l	0,0,0,0,0,0,0

si0
	dc.l	engb,engub
	dc.w	0,71,0,0,0,0,0,0
	dc.l	se0,0,0

gd0
	dc.l	0
	dc.w	169,133,310,9,GFLG_GADGHNONE!GFLG_TABCYCLE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,si0
	dc.w	0
        dc.l	0

gadlist
	dc.l	gd0,gd1,gd2,gd3,gd4,gd5,gd6,gd7,gd8,gd9,gd10,gd11,gd12,gd13,gd14,gd15,gd16,gd17,gd18,gd19,gd20,gd21,gd22,gd23,gd24,gd25,gd26,gd27,gd28,gd29,gd30,gd31,gd32,gd33,gd34,gd35

stglist
	dc.l	gd22,gd23,gd24,gd25,gd26,gd27,gd28,gd29,gd30,gd31,gd32,gd33,gd34

langlist
	dc.l	tagalog,danish,english,french,german,icelandic,italian,norwegian,spanish,swedish

menulist
	dc.l	menuitem10,menuitem11,menuitem12,menuitem13,menuitem14,menuitem15,menuitem16,menuitem17,menuitem18,menuitem19

errorlist
	dc.l	error0,error1,error2,error3,error4,error5,error6,error7,error8,error9,error10,error11,error12,error13,error14


 * Long Variables.

longval		dc.l	0


 * String Variables.

int_name	dc.b	'intuition.library',0
gfx_name	dc.b	'graphics.library',0,0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
asl_name	dc.b    'asl.library',0
tran_name	dc.b    'translator.library',0,0
nar_name	dc.b    'narrator.device',0
font_name	dc.b    'topaz.font',0,0
lt0		dc.b	'LANGUAGE TEXT',0
lt1		dc.b	'PHONETIC TEXT',0,0
lt2		dc.b	'G',0
lt3		dc.b	'N',0
mode0		dc.b	'NATURAL',0
mode1		dc.b	'ROBOTIC',0
mode2		dc.b	'MANUAL ',0
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
num1		dc.b	'1',0
num2		dc.b	'2',0
num3		dc.b	'3',0
num4		dc.b	'4',0
mmstg0		dc.b    '   PROJECT  OPTIONS',0
mmstg1		dc.b    '  VOICE  SELECTION',0
mmstg2		dc.b    '      MOUTH  OPTIONS',0
mistg0		dc.b    'Load .Config',0,0
mistg1		dc.b    'Save .Config',0,0
mistg2		dc.b    'Quit S.T.M',0,0
mistg20		dc.b    '  Use Details',0
mistg21		dc.b    '  Word Sync.',0,0
mistg22		dc.b    '  Syllable Sync.',0,0
mistg23		dc.b    '  Info To FILE',0,0
cancelstg	dc.b	'Cancel',0,0
okstg		dc.b	'Okay',0,0
loadtitle	dc.b	'pick a Config file to LOAD',0,0
savetitle	dc.b	'pick a Config file to SAVE',0,0
widthtxt	dc.b	'Width: ',0
heighttxt	dc.b	'Height: ',0,0
header		dc.b	'***  STM Mouth Details START ***',10,10,0,0
tailend		dc.b	'***  STM Mouth Details END  ***',0
cname		dc.b	'CON:0/0/290/170/ STM Mouth Details',0,0
fname		dc.b	'Ram:Mouth_Details.stm',0
ftstg0          dc.b    'SPEECH_PRIORITY',0
ftstg1          dc.b    'CONSOLE_PAUSETIME',0
template	dc.b	'SPEECH_PRIORITY/K,CONSOLE_PAUSETIME/K',0,0
error0		dc.b	'No Error',0
error1		dc.b	'No Config Memory',0
error2		dc.b	'No FIB Memory',0
error3		dc.b	'Lock()',0
error4		dc.b	'Examine()',0
error5		dc.b	'Read()',0
error6		dc.b	'Open()',0
error7		dc.b	'No File',0
error8		dc.b	'Wrong Size',0
error9		dc.b	'Write()',0
error10		dc.b	'AddPart()',0
error11		dc.b	'No Pathname Memory',0,0
error12		dc.b	'User Cancelled',0,0
error13		dc.b	'OpenLibrary()',0
error14		dc.b	'AllocAslRequest()',0
error_title1	dc.b	' File LOAD Error.',0
error_title2	dc.b	' File SAVE Error.',0
easy_gads0	dc.b	'Okay',0,0
easy_title1	dc.b	' ASL Requester Error.',0
easy_txt0
	dc.b	' File Name  -  %s',10
	dc.b	' File Size  -  %ld',10
	dc.b	'Error Type  -  %s',0
	even

easy_txt1
	dc.b	' Error Type  -  %s',0
	even


 * Buffer Variables.

engb		dcb.b	71,0
engub		dcb.b	71,0
narb		dcb.b	142,0
narub		dcb.b	142,0
voiceb		dcb.b	12,0
voiceub		dcb.b	12,0
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
numb7		dcb.b	8,0
numub7		dcb.b	8,0
numb8		dcb.b	8,0
numub8		dcb.b	8,0
numb9		dcb.b	8,0
numub9		dcb.b	8,0
numb10		dcb.b	8,0
numub10		dcb.b	8,0
numb11		dcb.b	8,0
numub11		dcb.b	8,0
numb12		dcb.b	8,0
numub12		dcb.b	8,0
numb13		dcb.b	8,0
numub13		dcb.b	8,0
numb14		dcb.b	8,0
numub14		dcb.b	8,0
config		dcb.b	720,0
aslbuf		dcb.b	132,0
dirbuf		dcb.b	100,0
filebuf		dcb.b	32,0
transbuf	dcb.b	142,0
eol		dcb.b	1,10
spaces		dcb.b	4,32


	SECTION	GFX,DATA_C

id0	dc.w	%0000000000000000,%0000000000000000,%0000000000000010
	dc.w	%0011111111111111,%1111111111111111,%1111111111111110
	dc.w	%0011111111111111,%1111111111111111,%1111111111111110
	dc.w	%0011111110000001,%1110000000011111,%1111111111111110
	dc.w	%0011111100111100,%1110011111111111,%1111111111111110
	dc.w	%0011111100111111,%1110011111111111,%1111111111111110
	dc.w	%0011111110000001,%1110000001111111,%1111111111111110
	dc.w	%0011111111111100,%1110011111111111,%1111111111111110
	dc.w	%0011111100111100,%1110011111111111,%1111111111111110
	dc.w	%0011111110000001,%1110000000011111,%1111111111111110
	dc.w	%0011111111111111,%1111111111111111,%1111111111111110
	dc.w	%0011111111111111,%1111111111111111,%1111111111111110
	dc.w	%0011111111111111,%1111111111111111,%1111111111111110
	dc.w	%0111111111111111,%1111111111111111,%1111111111111110

	dc.w	%1111111111111111,%1111111111111111,%1111111111111100
	dc.w	%1111111111111111,%1111111111111111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111100,%1111100111111000
	dc.w	%1111111111111111,%1111111111111110,%0111001111111000
	dc.w	%1111111111111111,%1111111111111111,%0010011111111000
	dc.w	%1111111111111111,%1111111111111111,%1000111111111000
	dc.w	%1111111111111111,%1111111111111111,%0010011111111000
	dc.w	%1111111111111111,%1111111111111110,%0111001111111000
	dc.w	%1111111111111111,%1111111111111100,%1111100111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111000
	dc.w	%1000000000000000,%0000000000000000,%0000000000000000

id1	dc.w	%1111111111111111,%1111111111111111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1111111111111111,%1111111111111111,%1111111111110000
	dc.w	%1000000000000000,%0000000000000000,%0000000000000000

	dc.w	%0000000000000000,%0000000000000000,%0000000000000100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0011111111111111,%1111111111111111,%1111111111111100
	dc.w	%0111111111111111,%1111111111111111,%1111111111111100

id2	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000010000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111100111100,%1111000000111111,%1111111110000000,%0111111110000000
	dc.w	%0011111100011000,%1110011110011111,%1111111110011111,%1111111110000000
	dc.w	%0011111100000000,%1110011110011111,%1111111110011111,%1111111110000000
	dc.w	%0011111100100100,%1110011110011111,%1111111110000001,%1111111110000000
	dc.w	%0011111100111100,%1110011110011111,%1111111110011111,%1111111110000000
	dc.w	%0011111100111100,%1110011110011111,%1111111110011111,%1111111110000000
	dc.w	%0011111100111100,%1111000000111111,%1111111110000000,%0111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111110000000

	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%0000111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%1110011111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%1110011111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%0000111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id3	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000010000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111110000000

id4	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000010000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111000000111100,%0000001110000000,%0111111110000000
	dc.w	%0011111111111111,%1110011110011111,%1001111110011111,%1111111110000000
	dc.w	%0011111111111111,%1110011110011111,%1001111110011111,%1111111110000000
	dc.w	%0011111111111111,%1110000000011111,%1001111110000001,%1111111110000000
	dc.w	%0011111111111111,%1110011110011111,%1001111110011111,%1111111110000000
	dc.w	%0011111111111111,%1110011110011111,%1001111110011111,%1111111110000000
	dc.w	%0011111111111111,%1110011110011111,%1001111110000000,%0111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111110000000

	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111100000001,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111100111100,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111100111100,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111100000001,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111100110011,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111100111001,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111100111100,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id5	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000010000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111100000000,%1111000000111111,%1111111111000000,%1111111110000000
	dc.w	%0011111100111111,%1110011110011111,%1111111110011110,%0111111110000000
	dc.w	%0011111100111111,%1110011111111111,%1111111110011110,%0111111110000000
	dc.w	%0011111100000011,%1110011111111111,%1111111110011110,%0111111110000000
	dc.w	%0011111100111111,%1110011111111111,%1111111110011110,%0111111110000000
	dc.w	%0011111100111111,%1110011110011111,%1111111110011110,%0111111110000000
	dc.w	%0011111100000000,%1111000000111111,%1111111111000000,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111110000000
	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111110000000

	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%0000001111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000000000
	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id6	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1110000000011100,%0000001111000000,%1111001111001111,%1111000000000000
	dc.w	%0011111111111111,%1111110011111111,%1001111110011110,%0111001111001111,%1111000000000000
	dc.w	%0011111111111111,%1111110011111111,%1001111110011111,%1111001111001111,%1111000000000000
	dc.w	%0011111111111111,%1111110011111111,%1001111110011111,%1111000000001111,%1111000000000000
	dc.w	%0011111111111111,%1111110011111111,%1001111110011111,%1111001111001111,%1111000000000000
	dc.w	%0011111111111111,%1111110011111111,%1001111110011110,%0111001111001111,%1111000000000000
	dc.w	%0011111111111111,%1110000000011111,%1001111111000000,%1111001111001111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000

	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111100000001,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111100111100,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111100111100,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111100000001,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111100111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111100111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111100111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id7	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000

id8	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000010
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
	dc.w	%0011111100111100,%1111000000111100,%1111111110011110,%0111111111111110,%0000000111111110
	dc.w	%0011111100111100,%1110011110011100,%1111111110011110,%0111111111111110,%0111111111111110
	dc.w	%0011111100111100,%1110011110011100,%1111111110011110,%0111111111111110,%0111111111111110
	dc.w	%0011111100111100,%1110011110011100,%1111111110011110,%0111111111111110,%0000011111111110
	dc.w	%0011111110011001,%1110011110011100,%1111111110011110,%0111111111111110,%0111111111111110
	dc.w	%0011111111000011,%1110011110011100,%1111111110011110,%0111111111111110,%0111111111111110
	dc.w	%0011111111100111,%1111000000111100,%0000001111000000,%1111111111111110,%0000000111111110
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110

	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111000110001111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111000000001111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001001001111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id9	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

 	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000010
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110

id10	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000010
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111110000001,%1110011110011111,%1111111110000000,%0111100000011111,%0000001111111110
 	dc.w	%0011111100111100,%1110011110011111,%1111111111110011,%1111001111001110,%0111100111111110
 	dc.w	%0011111100111100,%1110011110011111,%1111111111110011,%1111001111001110,%0111111111111110
 	dc.w	%0011111100000000,%1110011110011111,%1111111111110011,%1111000000001111,%0000001111111110
 	dc.w	%0011111100111100,%1111001100111111,%1111111111110011,%1111001111001111,%1111100111111110
 	dc.w	%0011111100111100,%1111100001111111,%1111111111110011,%1111001111001110,%0111100111111110
 	dc.w	%0011111100111100,%1111110011111111,%1111111110000000,%0111001111001111,%0000001111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111100,%0000011111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111100,%0000011111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111100,%0000011111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id11	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000010
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111110000001,%1111111111111100,%0000011110000000,%0111100000011111,%0000001111111110
 	dc.w	%0011111100111100,%1111111111111100,%1111001111110011,%1111001111001110,%0111100111111110
 	dc.w	%0011111100111100,%1111111111111100,%1111001111110011,%1111001111001110,%0111111111111110
 	dc.w	%0011111100000000,%1111111111111100,%0000011111110011,%1111000000001111,%0000001111111110
 	dc.w	%0011111100111100,%1111111111111100,%1111001111110011,%1111001111001111,%1111100111111110
 	dc.w	%0011111100111100,%1111111111111100,%1111001111110011,%1111001111001110,%0111100111111110
 	dc.w	%0011111100111100,%1111111111111100,%0000011110000000,%0111001111001111,%0000001111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111100
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1110000000011111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1110000001111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1110011111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id12	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111100111100,%1111000000111111,%1111111110000000,%0111001111111111,%1111000000000000
 	dc.w	%0011111100111100,%1110011110011111,%1111111110011111,%1111001111111111,%1111000000000000
 	dc.w	%0011111100111100,%1110011110011111,%1111111110011111,%1111001111111111,%1111000000000000
 	dc.w	%0011111100111100,%1110011110011111,%1111111110000001,%1111001111111111,%1111000000000000
 	dc.w	%0011111110011001,%1110011110011111,%1111111110011111,%1111001111111111,%1111000000000000
 	dc.w	%0011111111000011,%1110011110011111,%1111111110011111,%1111001111111111,%1111000000000000
 	dc.w	%0011111111100111,%1111000000111111,%1111111110000000,%0111000000001111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111100,%1001001111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111100,%0000001111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111100,%0110001111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111100,%1111001111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id13	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111100111100,%1111000000111100,%0000001111000000,%1111111111111111,%1111000000000000
 	dc.w	%0011111100111100,%1110011110011111,%1001111110011110,%0111111111111111,%1111000000000000
 	dc.w	%0011111100111100,%1110011110011111,%1001111110011111,%1111111111111111,%1111000000000000
 	dc.w	%0011111100111100,%1110011110011111,%1001111110011111,%1111111111111111,%1111000000000000
 	dc.w	%0011111110011001,%1110011110011111,%1001111110011111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111000011,%1110011110011111,%1001111110011110,%0111111111111111,%1111000000000000
 	dc.w	%0011111111100111,%1111000000111100,%0000001111000000,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111000000001111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111000000111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111000000001111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id14	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111100000000,%1110000000111100,%0000001111111111,%1111100111100111,%0000000011100111,%1001111000000111,%1001111001111111,%1000000000000000
 	dc.w	%0011111100111111,%1110011110011100,%1111111111111111,%1111100111100111,%0011111111100011,%1001110011110011,%1100110011111111,%1000000000000000
 	dc.w	%0011111100111111,%1110011110011100,%1111111111111111,%1111100111100111,%0011111111100001,%1001110011111111,%1110000111111111,%1000000000000000
 	dc.w	%0011111100000011,%1110000000111100,%0000111111111111,%1111100111100111,%0000001111100100,%1001110011111111,%1111001111111111,%1000000000000000
 	dc.w	%0011111100111111,%1110011001111100,%1111111111111111,%1111100111100111,%0011111111100110,%0001110011111111,%1111001111111111,%1000000000000000
 	dc.w	%0011111100111111,%1110011100111100,%1111111111111111,%1111100111100111,%0011111111100111,%0001110011110011,%1111001111111111,%1000000000000000
 	dc.w	%0011111100111111,%1110011110011100,%0000001111111111,%1111110000001111,%0000000011100111,%1001111000000111,%1111001111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111000000,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111110011110,%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111110011110,%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111110011110,%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111110010010,%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111110011100,%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111000010,%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id15	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

 	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000

id16	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111100000000,%1110011110011100,%0000001110011110,%0111111111111111,%0000001111000000,%0011110000001111,%1000000111100111,%1001111111100000
 	dc.w	%0011111100111111,%1110001110011111,%1001111110011110,%0111111111111110,%0111100111111001,%1111100111100111,%0011110011100011,%0001111111100000
 	dc.w	%0011111100111111,%1110000110011111,%1001111110011110,%0111111111111110,%0111111111111001,%1111100111100111,%0011111111100000,%0001111111100000
 	dc.w	%0011111100000011,%1110010010011111,%1001111110000000,%0111111111111111,%0000001111111001,%1111100000000111,%1000000111100100,%1001111111100000
 	dc.w	%0011111100111111,%1110011000011111,%1001111110011110,%0111111111111111,%1111100111111001,%1111100111100111,%1111110011100111,%1001111111100000
 	dc.w	%0011111100111111,%1110011100011111,%1001111110011110,%0111111111111110,%0111100111111001,%1111100111100111,%0011110011100111,%1001111111100000
 	dc.w	%0011111100000000,%1110011110011111,%1001111110011110,%0111111111111111,%0000001111000000,%0011100111100111,%1000000111100111,%1001111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111100000011111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id17	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

 	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000

id18	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111110000001,%1110000000111100,%0000001110000000,%0111111111111110,%0111100111001111,%1111110000001111,%0000000011100000,%0001111111100000
 	dc.w	%0011111100111100,%1110011110011111,%1001111111110011,%1111111111111110,%0111100111001111,%1111100111100111,%1110011111100111,%1111111111100000
 	dc.w	%0011111100111100,%1110011110011111,%1001111111110011,%1111111111111110,%0111100111001111,%1111100111100111,%1110011111100111,%1111111111100000
 	dc.w	%0011111100000000,%1110000000111111,%1001111111110011,%1111111111111110,%0111100111001111,%1111100000000111,%1110011111100000,%0111111111100000
 	dc.w	%0011111100111100,%1110011001111111,%1001111111110011,%1111111111111110,%0111100111001111,%1111100111100111,%1110011111100111,%1111111111100000
 	dc.w	%0011111100111100,%1110011100111111,%1001111111110011,%1111111111111110,%0111100111001111,%1111100111100111,%1110011111100111,%1111111111100000
 	dc.w	%0011111100111100,%1110011110011111,%1001111110000000,%0111111111111111,%0000001111000000,%0011100111100111,%1110011111100000,%0001111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111100000011111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111100000011111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id19	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000001000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111100000001,%1110000000011100,%0000011111111111,%1111001111001110,%0000001111000000,%0111111111000000
 	dc.w	%0011111100111100,%1110011111111100,%1111001111111111,%1111001111001110,%0111100111001111,%0011111111000000
 	dc.w	%0011111100111100,%1110011111111100,%1111001111111111,%1111001111001110,%0111100111001111,%0011111111000000
 	dc.w	%0011111100000001,%1110000001111100,%0000011111111111,%1111001111001110,%0000001111000000,%0111111111000000
 	dc.w	%0011111100111111,%1110011111111100,%1100111111111111,%1111001111001110,%0110011111001111,%0011111111000000
 	dc.w	%0011111100111111,%1110011111111100,%1110011111111111,%1111001111001110,%0111001111001111,%0011111111000000
 	dc.w	%0011111100111111,%1110000000011100,%1111001111111111,%1111100000011110,%0111100111000000,%0111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111110000000,%0111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111110011,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111110011,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111110011,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111110011,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111110011,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111110011,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id20	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

 	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000001000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000

id21	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000001000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111110000001,%1110011110011100,%0000011110011111,%1111111111111110,%0000000111001111,%0011111111000000
 	dc.w	%0011111100111100,%1110001100011100,%1111001110011111,%1111111111111110,%0111111111100110,%0111111111000000
 	dc.w	%0011111100111100,%1110000000011100,%1111001110011111,%1111111111111110,%0111111111110000,%1111111111000000
 	dc.w	%0011111100000000,%1110010010011100,%0000011110011111,%1111111111111110,%0000011111111001,%1111111111000000
 	dc.w	%0011111100111100,%1110011110011100,%1111111110011111,%1111111111111110,%0111111111111001,%1111111111000000
 	dc.w	%0011111100111100,%1110011110011100,%1111111110011111,%1111111111111110,%0111111111111001,%1111111111000000
 	dc.w	%0011111100111100,%1110011110011100,%1111111110000000,%0111111111111110,%0111111111111001,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111000000001111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111001111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111001111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111001111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111001111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111001111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111000000001111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111100000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id22	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111100111100,%1111111111111100,%1111001110000000,%0111001111111111,%1111111000000111,%1000000001110011,%1100111000000001,%1111111111100000
 	dc.w	%0011111100111100,%1111111111111100,%1111001110011111,%1111001111111111,%1111110011110011,%1001111111110001,%1100111111001111,%1111111111100000
 	dc.w	%0011111100111100,%1111111111111100,%1111001110011111,%1111001111111111,%1111110011111111,%1001111111110000,%1100111111001111,%1111111111100000
 	dc.w	%0011111100111100,%1111111111111100,%1001001110000001,%1111001111111111,%1111110011111111,%1000000111110010,%0100111111001111,%1111111111100000
 	dc.w	%0011111110011001,%1111111111111100,%0000001110011111,%1111001111111111,%1111110011111111,%1001111111110011,%0000111111001111,%1111111111100000
 	dc.w	%0011111111000011,%1111111111111100,%0110001110011111,%1111001111111111,%1111110011110011,%1001111111110011,%1000111111001111,%1001111111100000
 	dc.w	%0011111111100111,%1111111111111100,%1111001110000000,%0111000000001111,%1111111000000111,%1000000001110011,%1100111111001111,%1001111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111000000111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1110011110011111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1110011110011111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1110011110011111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1110011110011111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1110011110011111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111000000111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id23	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111110000001,%1111111110011110,%0000011111111111,%1111100000011110,%0111100111111111,%1111100111100111,%1000000111110000,%0011111111100000
 	dc.w	%0011111100111100,%1111111100111100,%1111001111111111,%1111001111001110,%0111100111111111,%1111100011100111,%0011110011100111,%1001111111100000
 	dc.w	%0011111100111100,%1111111001111100,%1111111111111111,%1111001111111110,%0111100111111111,%1111100001100111,%0011111111111111,%1001111111100000
 	dc.w	%0011111100000000,%1111110011111100,%1111111111111111,%1111001111111110,%0000000111111111,%1111100100100111,%1000000111111110,%0011111111100000
 	dc.w	%0011111100111100,%1111100111111100,%1111111111111111,%1111001111111110,%0111100111111111,%1111100110000111,%1111110011111100,%1111111111100000
 	dc.w	%0011111100111100,%1111001111111100,%1111001111001111,%1111001111001110,%0111100111111111,%1111100111000111,%0011110011111111,%1111111111100000
 	dc.w	%0011111100111100,%1110011111111110,%0000011111001111,%1111100000011110,%0111100111111111,%1111100111100111,%1000000111111100,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111100000,%0111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111001111,%0011111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111001111,%0011111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111000000,%0011111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111001111,%0011111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111001111,%0011111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111001111,%0011111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111110000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id24	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111110000001,%1111111110011110,%0000011111111111,%1111111111111111,%1000000111100111,%1111110011110011,%1000000001111111,%1000000000000000
 	dc.w	%0011111100111100,%1111111100111100,%1111001111111111,%1111111111111111,%0011110011100111,%1111110011110011,%1001111111111111,%1000000000000000
 	dc.w	%0011111100111100,%1111111001111100,%1111111111111111,%1111111111111111,%0011110011100111,%1111110011110011,%1001111111111111,%1000000000000000
 	dc.w	%0011111100000000,%1111110011111100,%1111111111111111,%1111111111111111,%0000000011100111,%1111110011110011,%1000000111111111,%1000000000000000
 	dc.w	%0011111100111100,%1111100111111100,%1111111111111111,%1111111111111111,%0011110011100111,%1111110011110011,%1001111111111111,%1000000000000000
 	dc.w	%0011111100111100,%1111001111111100,%1111001111001111,%1111111111111111,%0011110011100111,%1111110011110011,%1001111111111111,%1000000000000000
 	dc.w	%0011111100111100,%1110011111111110,%0000011111001111,%1111111111111111,%0011110011100000,%0001111000000111,%1000000001111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1000000000000000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111100111100111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111100111100111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111100111100111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111100111100111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111110011001111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111000011111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111100111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111110,%0000000000000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id25	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111110000001,%1110000000111100,%0000001111000000,%1111111111111111,%1111000000000000
 	dc.w	%0011111100111100,%1110011110011100,%1111111110011110,%0111111111111111,%1111000000000000
 	dc.w	%0011111100111111,%1110011110011100,%1111111110011110,%0111111111111111,%1111000000000000
 	dc.w	%0011111110000001,%1110000000111100,%0000111110000000,%0111111111111111,%1111000000000000
 	dc.w	%0011111111111100,%1110011111111100,%1111111110011110,%0111111111111111,%1111000000000000
 	dc.w	%0011111100111100,%1110011111111100,%1111111110011110,%0111111111111111,%1111000000000000
 	dc.w	%0011111110000001,%1110011111111100,%0000001110011110,%0111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001110011111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001100111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111000001111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001100111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001110011111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111001111001111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id26	dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0001000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1110000000111100,%0000001111000000,%1111001111001111,%1111000000000000
 	dc.w	%0011111111111111,%1110011110011100,%1111111110011110,%0111001110011111,%1111000000000000
 	dc.w	%0011111111111111,%1110011110011100,%1111111110011110,%0111001100111111,%1111000000000000
 	dc.w	%0011111111111111,%1110000000111100,%0000111110000000,%0111000001111111,%1111000000000000
 	dc.w	%0011111111111111,%1110011111111100,%1111111110011110,%0111001100111111,%1111000000000000
 	dc.w	%0011111111111111,%1110011111111100,%1111111110011110,%0111001110011111,%1111000000000000
 	dc.w	%0011111111111111,%1110011111111100,%0000001110011110,%0111001111001111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0011111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000
 	dc.w	%0111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111000000000000

 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1110000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111110000001,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111100111100,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111100111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111110000001,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111100,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111100111100,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111110000001,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1100000000000000
 	dc.w	%1000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

id27	dc.w	%0000000000000000,%0000100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0111111111111111,%1111100000000000

	dc.w	%1111111111111111,%1111000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1000000000000000,%0000000000000000

id28	dc.w	%1111111111111111,%1111000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1100000000000000,%0000000000000000
	dc.w	%1000000000000000,%0000000000000000

	dc.w	%0000000000000000,%0000100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0000000000000000,%0001100000000000
	dc.w	%0111111111111111,%1111100000000000


	SECTION	VERSION,DATA

	dc.b	'$VER: Speak To Me V3.00 (26.3.2001)',0


	END
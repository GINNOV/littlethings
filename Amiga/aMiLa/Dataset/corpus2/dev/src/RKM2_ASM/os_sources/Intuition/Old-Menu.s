
 * Although this example uses the Old Menu look it can be used in conjunction
 * with Gadtools for example. You do not have to have the New Menu look.
 * Personally. I like to program this kind of menu, as opposed to GadTools
 * menu, because it is nice to be able to be in full manipulative control
 * (with ease) of a menu structure/system.

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
 * 188 iclass
 * 192 icode
 * 194 iqualifier
 * 196 iaddress
 * 200 mousex
 * 202 mousey
 * 204

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
	move.l	8(a4),a6
	jsr	_LVOLockPubScreen(a6)
	move.l	d0,178(a4)
	move.l	d0,wndwscrn
	beq	cl_icon

	suba.l	a0,a0
	move.l	178(a4),a1
	jsr	_LVOUnlockPubScreen(a6)

	suba.l	a0,a0
	lea	wndwtags(pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,178(a4)
	beq	cl_icon

	move.l	d0,a0
	move.l	wd_RPort(a0),156(a4)

	move.l	wndwscrn(pc),a0
	lea	sc_RastPort(a0),a1
	move.l	a1,184(a4)
	lea	sc_ViewPort(a0),a2
	move.l	a2,160(a4)

	move.l	178(a4),a0
	lea	menu0(pc),a1
	move.l	8(a4),a6
	jsr	_LVOSetMenuStrip(a6)
	tst.l	d0
	beq	cl_wndw

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

	cmp.l	#IDCMP_MENUPICK,188(a4)
	beq.s	do_menu

	cmp.l	#IDCMP_MENUHELP,188(a4)
	beq.s	do_mhelp

	cmp.l	#IDCMP_CLOSEWINDOW,188(a4)
	beq.s	cl_menu

	bra.s	mainloop

do_menu	cmp.w	#$F800,192(a4)
	beq.s	do_nothing
	cmp.w	#$F820,192(a4)
	beq.s	do_nothing
	cmp.w	#$40,192(a4)
	beq.s	do_nothing
	cmp.w	#$840,192(a4)
	beq.s	do_nothing
	cmp.w	#$F860,192(a4)
	beq.s	do_nothing
	cmp.w	#$F801,192(a4)
	beq.s	do_nothing
	cmp.w	#$F821,192(a4)
	beq.s	do_nothing
	cmp.w	#$F841,192(a4)
	beq.s	do_nothing
	cmp.w	#$F861,192(a4)
	beq.s	do_nothing

	bra	mainloop

do_nothing

	bra	mainloop

do_mhelp

	bra	mainloop


cl_menu	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOClearMenuStrip(a6)

cl_wndw	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

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

itext0
	dc.b	0,1,0,0
	dc.w	0,0
	dc.l	topaz9,mistg0,0

itext1
	dc.b	0,1,0,0
	dc.w	0,0
	dc.l	topaz9,mistg1,0

itext2
	dc.b	0,1,0,0
	dc.w	0,0
	dc.l	topaz9,mistg2,0

itext3
	dc.b	0,1,0,0
	dc.w	0,0
	dc.l	topaz9C,sistg0,0

itext4
	dc.b	0,1,0,0
	dc.w	0,0
	dc.l	topaz9C,sistg1,0

itext5
	dc.b	0,1,0,0
	dc.w	0,0
	dc.l	topaz9,mistg3,0

itext6
	dc.b	0,1,0,0
	dc.w	0,0
	dc.l	topaz9,mistg4,0

itext7
	dc.b	0,1,0,0
	dc.w	0,0
	dc.l	topaz9,mistg5,0

itext8
	dc.b	0,1,0,0
	dc.w	0,0
	dc.l	topaz9,mistg6,0

menuitem7
	dc.l	0
	dc.w	0,32,230,14,HIGHIMAGE!ITEMENABLED!MENUTOGGLE
	dc.l	0,image0,image2
	dc.b	0,0
	dc.l	0,0

menuitem6
	dc.l	menuitem7
	dc.w	0,20,230,10,ITEMTEXT!HIGHBOX!ITEMENABLED!COMMSEQ
	dc.l	0,itext8,0
	dc.b	51,0
	dc.l	0,0

menuitem5
	dc.l	menuitem6
	dc.w	0,10,230,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT!MENUTOGGLE
	dc.l	0,itext7,0
	dc.b	50,0
	dc.l	0,0

menuitem4
	dc.l	menuitem5
	dc.w	0,0,230,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ!CHECKIT
	dc.l	0,itext6,0
	dc.b	49,0
	dc.l	0,0

menu1
	dc.l	0
	dc.w	140,0,120,10,MENUENABLED
	dc.l	mmstg1,menuitem4
	dc.w	0,0,0,0

subitem1
	dc.l	0
	dc.w	120,10,190,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
	dc.l	0,itext4,0
	dc.b	74,0
	dc.l	0,0

subitem0
	dc.l	subitem1
	dc.w	120,0,190,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
	dc.l	0,itext3,0
	dc.b	80,0
	dc.l	0,0

menuitem3
	dc.l	0
	dc.w	0,30,120,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
	dc.l	0,itext5,0
	dc.b	81,0
	dc.l	0,0

menuitem2
	dc.l	menuitem3
	dc.w	0,20,120,10,ITEMTEXT!HIGHCOMP!ITEMENABLED
	dc.l	0,itext2,0
	dc.b	0,0
	dc.l	subitem0,0

menuitem1
	dc.l	menuitem2
	dc.w	0,10,120,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
	dc.l	0,itext1,0
	dc.b	83,0
	dc.l	0,0

menuitem0
	dc.l	menuitem1
	dc.w	0,0,120,10,ITEMTEXT!HIGHCOMP!ITEMENABLED!COMMSEQ
	dc.l	0,itext0,0
	dc.b	76,0
	dc.l	0,0

menu0
	dc.l	menu1
	dc.w	0,0,120,10,MENUENABLED
	dc.l	mmstg0,menuitem0
	dc.w	0,0,0,0

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

topaz9C
	dc.l	font_name
	dc.w	9
	dc.b	FSF_BOLD!FSF_ITALIC,FPF_ROMFONT

wndwtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,320
	dc.l	WA_Height,100
	dc.l	WA_DetailPen,0
	dc.l	WA_BlockPen,1
	dc.l	WA_Title,wndw_title
	dc.l	WA_IDCMP,IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_MENUPICK!IDCMP_MENUHELP
	dc.l	WA_Activate,TRUE
	dc.l	WA_CloseGadget,TRUE
	dc.l	WA_DepthGadget,TRUE
	dc.l	WA_DragBar,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_SmartRefresh,TRUE
	dc.l	WA_PubScreen
wndwscrn
	dc.l	0
	dc.l	TAG_DONE


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
wndw_title	dc.b	'Old_Menu.s',0,0
font_name	dc.b	'topaz.font',0,0
mmstg0		dc.b	'PROJECT',0
mistg0		dc.b	'Load',0,0
mistg1		dc.b	'Save',0,0
mistg2		dc.b	'About',0
sistg0		dc.b	'This Program',0,0
sistg1		dc.b	'John White',0,0
mistg3		dc.b	'Quit',0,0
mmstg1		dc.b	'OPTIONS',0
mistg4		dc.b	'   Tick Me',0,0
mistg5		dc.b	'   Toggle Click Me',0,0
mistg6		dc.b	'I Will Be Boxed',0


 * Buffer Variables.

membuf		dcb.b	300,0


	SECTION	GFX,DATA_C

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


	SECTION	VERSION,DATA

	dc.b	'$VER: Old_Menu.s V1.01 (22.4.2001)',0


	END
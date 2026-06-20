
 * This code shows you how to have a diskfont attached to your String, aswell
 * as being able to choose the colours for the string, using the String
 * Extend structure.

	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE	intuition/sghooks.i
	INCLUDE	intuition/cghooks.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE dos/dosextens.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/text.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	workbench/workbench.i
	INCLUDE	utility/utility_lib.i
	INCLUDE	utility/hooks.i
	INCLUDE libraries/diskfont_lib.i
	INCLUDE libraries/diskfont.i

	XDEF	_hookEntry

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
 * 204 _UtilityBase
 * 208 _DiskfontBase
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
        lea     utility_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,204(a4)
        beq     cl_gfx

        moveq	#LIB_VER,d0
        lea     diskfont_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,208(a4)
        beq     cl_util

        moveq	#LIB_VER,d0
        lea     icon_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,12(a4)
        beq     cl_font

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

	lea	dfont(pc),a0
	move.l	208(a4),a6
	jsr	_LVOOpenDiskFont(a6)
	move.l	d0,stgfnt
	beq.s	no_font
	bra.s	do_hook

no_font
	nop
	bra	cl_icon

do_hook	bsr	init_hook
	lea	hook(pc),a0
	lea	sgw(pc),a2
	lea	hookcmd(pc),a1
	move.l	204(a4),a6
	jsr	_LVOCallHookPkt(a6)

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

	move.l	156(a4),a1
	move.l	stgfnt(pc),a0
	move.l	152(a4),a6
	jsr	_LVOSetFont(a6)

	move.w	#16,d0
	move.w	#64,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	lea	dfname(pc),a0
	move.w	#7,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)
	jsr	_LVOWaitTOF(a6)

	move.l	178(a4),a0
	lea	gad0(pc),a1
	moveq	#-1,d0
	move.l	8(a4),a6
	jsr	_LVOAddGadget(a6)

	lea	gad0(pc),a0
	move.l	178(a4),a1
	suba.l	a2,a2
	jsr	_LVORefreshGadgets(a6)

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
	beq.s	do_gu

	cmp.l	#IDCMP_VANILLAKEY,188(a4)
	beq.s	do_keys

	cmp.l	#IDCMP_CLOSEWINDOW,188(a4)
	beq.s	cl_wndw

	bra.s	mainloop

do_keys

	bra.s	mainloop

do_gu

	bra.s	mainloop


cl_wndw	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

cl_icon	move.l  12(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_font	move.l  208(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_util	move.l  204(a4),a1
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

init_hook
	lea	hook(pc),a0
	lea	_hookEntry(pc),a1	; must be a C stub
	move.l	a1,h_Entry(a0)
	lea	hook_code(pc),a1	; your code routine
	move.l	a1,h_SubEntry(a0)
	move.l	#0,h_Data(a0)		; any user data you want to use
	rts

 * The _HookEntry stub pushes the registers onto the stack so that high
 * level languages, such as C, can access them.

_hookEntry
	move.l	a1,-(a7)		; pointer to the message packet
	move.l	a2,-(a7)		; pointer to the object
	move.l	a0,-(a7)		; pointer to the hook
	move.l	h_SubEntry(a0),a0	; the code routine to call
	jsr	(a0)			; jump to the code routine
	lea	12(a7),a7		; fix the stack
	rts

 * When this code gets called A0 = Hook, A1 = Hook Command and a2 = sgw
 * structure.

hook_code
	moveq	#~0,d0

	cmp.l	#SGH_KEY,(a1)
	bne.s	check_mouse

	cmp.w	#EO_REPLACECHAR,sgw_EditOp(a2)
	beq.s	do_hex
	cmp.w	#EO_INSERTCHAR,sgw_EditOp(a2)
	beq.s	do_hex

	bra.s	hook_e

do_hex	move.w	sgw_Code(a2),d1
	bsr.s	isithex
	tst.l	d1
	bne.s	its_hex
	or.l	#SGA_BEEP,sgw_Actions(a2)
	and.l	#~SGA_USE,sgw_Actions(a2)
	bra.s	hook_e

its_hex	move.l	sgw_WorkBuffer(a2),a3
	move.w	sgw_BufferPos(a2),d2
	subq.w	#1,d2
	move.b	#71,0(a3,d2.w)
	bra.s	hook_e

check_mouse
	cmp.l	#SGH_CLICK,(a1)
	bne.s	unknown
	move.w	sgw_NumChars(a2),d1
	move.w	sgw_BufferPos(a2),d2
	cmp.w	d1,d2
	bge.s	hook_e
	move.l	sgw_WorkBuffer(a2),a3
	move.w	sgw_BufferPos(a2),d2
	subq.w	#1,d2
	move.b	#71,0(a3,d2.w)
	bra.s	hook_e

unknown
	moveq	#0,d0	; Hook should return 0 if command not supported.

hook_e	rts

isithex	cmp.b	#102,d1
	bgt.s	not_hd
	cmp.b	#97,d1
	bge.s	is_hd
	cmp.b	#70,d1
	bgt.s	not_hd
	cmp.b	#65,d1
	bge.s	is_hd
	cmp.b	#57,d1
	bgt.s	not_hd
	cmp.b	#48,d1
	bge.s	is_hd
not_hd	clr.l	d1
	bra.s	iih_e
is_hd	moveq	#1,d1
iih_e	rts


 * Structure Definitions.

dfont
	dc.l	dfname
	dc.w	11
	dc.b	FS_NORMAL,FPF_DISKFONT!FPF_PROPORTIONAL

hookcmd
	dc.l	SGH_KEY

sgw
	dc.l	gad0,stginfo,workbuf,prevbuf,SGM_EXITHELP,iebuf
	dc.w	0,0,5
	dc.l	SGA_USE!SGA_REUSE!SGA_BEEP!SGA_REDISPLAY!SGA_END,0,gadinfo
	dc.w	0

stgext
stgfnt
	dc.l	0
	dc.b	2,3,3,2
	dc.l	SGM_EXITHELP,hook,workbuf,0,0,0,0

stginfo
	dc.l	dobuf,undobuf
	dc.w	0,5,0,0,0,0,0,0
	dc.l	stgext,0,0

gad0
	dc.l	0
	dc.w	16,16,160,34,GFLG_GADGHNONE!GFLG_STRINGEXTEND,GACT_RELVERIFY!GACT_STRINGLEFT!GACT_STRINGEXTEND,GTYP_STRGADGET
	dc.l	0,0,0,0,stginfo
	dc.w	0
        dc.l	0

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

wndwtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,320
	dc.l	WA_Height,100
	dc.l	WA_DetailPen,0
	dc.l	WA_BlockPen,1
	dc.l	WA_Title,wndw_title
	dc.l	WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW
	dc.l	WA_ReportMouse,TRUE
	dc.l	WA_RMBTrap,TRUE
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
wndw_title	dc.b	'String_Hook.s',0
font_name	dc.b	'topaz.font',0,0
dfname		dc.b	'jw.font',0


 * Buffer Variables.

membuf		dcb.b	300,0
dobuf		dcb.b	8,0
undobuf		dcb.b	8,0
workbuf		dcb.b	8,0	; must be as large as StringInfo.Buffer
prevbuf		dcb.b	8,0
hook		dcb.b	h_SIZEOF,0
iebuf		dcb.b	ie_SIZEOF,0
gadinfo		dcb.b	ggi_SIZEOF,0


	SECTION	VERSION,DATA

	dc.b	'$VER: String_Hook.s V1.01 (22.4.2001)',0


	END
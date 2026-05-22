
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
	INCLUDE	utility/utility_lib.i
	INCLUDE	utility/tagitem.i

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
 * 204 requester
 * 208 window screen
 * 212 _UtilityBase
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
        lea     util_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,212(a4)
        beq     cl_gfx

        moveq	#LIB_VER,d0
        lea     icon_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,12(a4)
        beq     cl_util

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

	moveq	#rq_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,204(a4)
	beq	cl_icon

	suba.l	a0,a0
	move.l	8(a4),a6
	jsr	_LVOLockPubScreen(a6)
	move.l	d0,178(a4)
	move.l	d0,208(a4)
	beq	fr_rq

	suba.l	a0,a0
	move.l	178(a4),a1
	jsr	_LVOUnlockPubScreen(a6)

	move.l	#WA_PubScreen,d0
	lea	wndwtags(pc),a0
	move.l	212(a4),a6
	jsr	_LVOFindTagItem(a6)
	tst.l	d0
	beq	fr_rq
	move.l	d0,a0			; d0 is a pointer to the tag.
	move.l	208(a4),ti_Data(a0)	; Change the tag's data.

	move.l	#WA_Title,d0
	lea	wndwtags(pc),a0
	jsr	_LVOFindTagItem(a6)
	tst.l	d0
	beq	fr_rq
	move.l	d0,a0			; d0 is a pointer to the tag.
	lea	wndw_text(pc),a1
	move.l	a1,ti_Data(a0)	; Change the tag's data.

	suba.l	a0,a0
	lea	wndwtags(pc),a1
	move.l	8(a4),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,178(a4)
	beq	fr_rq

	move.l	d0,a0
	move.l	wd_RPort(a0),156(a4)

	move.l	wndwscrn(pc),a0
	lea	sc_RastPort(a0),a1
	move.l	a1,184(a4)
	lea	sc_ViewPort(a0),a2
	move.l	a2,160(a4)

	move.w	#20,d1
	move.w	#16,d0
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)

	lea	wndw_text(pc),a0
	move.w	#26,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)

	jsr	_LVOWaitTOF(a6)

	move.l	204(a4),a0
	move.l	8(a4),a6
	jsr	_LVOInitRequester(a6)

 * Enable the Block Requester.

	move.l	204(a4),a0
	move.l	178(a4),a1
	jsr	_LVORequest(a6)
	tst.l	d0
	beq	cl_wndw

 * Do something here whilst the Window Input is blocked. I will change the
 * mouse pointer.

	move.l	178(a4),a0
	move.l	#busy,a1
	moveq	#16,d0
	moveq	#16,d1
	moveq	#-6,d2
	moveq	#0,d3
	jsr	_LVOSetPointer(a6)

	move.l	#200,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

 * Now remove the block requester (restore window input).

	move.l	204(a4),a0
	move.l	178(a4),a1
	move.l	8(a4),a6
	jsr	_LVOEndRequest(a6)

	move.l	178(a4),a0
	jsr	_LVOClearPointer(a6)

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

	cmp.l	#IDCMP_CLOSEWINDOW,188(a4)
	beq.s	cl_wndw

	bra.s	mainloop


cl_wndw	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

fr_rq	move.l	204(a4),a1
	moveq	#rq_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

cl_icon	move.l  12(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_util	move.l  212(a4),a1
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

wndwtags
	dc.l	WA_Top,100
	dc.l	WA_Left,200
	dc.l	WA_Width,320
	dc.l	WA_Height,80
	dc.l	WA_DetailPen,0
	dc.l	WA_BlockPen,1
	dc.l	WA_Title
wndwtitle
	dc.l	0
	dc.l	WA_IDCMP,IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_DELTAMOVE!IDCMP_MOUSEMOVE
	dc.l	WA_ReportMouse,TRUE
	dc.l	WA_RMBTrap,TRUE
	dc.l	WA_Activate,TRUE
	dc.l	WA_CloseGadget,TRUE
	dc.l	WA_DepthGadget,TRUE
	dc.l	WA_DragBar,TRUE
	dc.l	WA_SizeGadget,TRUE
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
util_name	dc.b	'utility.library',0
mtstg0		dc.b	'ARG_ONE',0
mtstg1		dc.b	'ARG_TWO',0
mtstg2		dc.b	'ARG_THREE',0
mtstg3		dc.b	'ARG_FOUR',0,0
mtstg4		dc.b	'ARG_FIVE',0,0
mtstg5		dc.b	'ARG_SIX',0
ftstg0          dc.b    'TOOLTYPE_ONE',0,0
ftstg1          dc.b    'TOOLTYPE_TWO',0,0
template	dc.b	'KEYWORD_ONE/K,KEYWORD_TWO/K',0
wndw_text	dc.b	'Try and CLOSE this window!',0,0
wndw_title	dc.b	'Block_Requester.s',0
font_name	dc.b	'topaz.font',0,0
lefttext	dc.b	'Yes',0
bodytext	dc.b	'Do you really wish to QUIT?',0
righttext	dc.b	'No',0,0
easy_title0	dc.b	'SAVE Options.',0
easy_txt0	dc.b	'Select a Disk Drive.',0,0
easy_gads0	dc.b	'DF0:|DF1:|DF2:|DF3:',0
easy_title1	dc.b	'SAVE Options.',0
easy_gads1	dc.b	'A500|Amiga %ld Computer|A600',0,0
easy_txt1	dc.b	'Your Text Here - First Line',10
		dc.b	'String: %s - Second Line',10
		dc.b	'Number: %ld - Third Line',0
	even


 * Buffer Variables.

membuf		dcb.b	300,0


	SECTION	GFX,DATA_C

busy	dc.w	$0000,$0000
	dc.w	$0400,$07C0
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
	dc.w	$0000,$0000


	SECTION	VERSION,DATA

	dc.b	'$VER: Block_Requester.s V1.01 (22.4.2001)',0


	END

 * This is an example of a custom requester. I Have only showed custom
 * imagery, via drawing (as opposed to bitmap), and custom buttons (gadgets).
 * You could expand this example by hooking string gadgets to my button
 * gadgets for example, thus allowing text/numbers to be typed from this
 * custom requester.

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
 * 204 _LayersBase
 * 208 requester's window
 * 212 req iclass
 * 216 req icode
 * 218 req iqualifier
 * 220 req iaddress
 * 224 req mousex
 * 226 req mousey
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
        lea     layers_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,204(a4)
        beq     cl_gfx

        moveq	#LIB_VER,d0
        lea     icon_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,12(a4)
        beq     cl_lays

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
	move.l	d0,reqwscrn
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

	move.w	#20,d1
	move.w	#16,d0
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)

	lea	wndw_text(pc),a0
	move.w	#31,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)

	jsr	_LVOWaitTOF(a6)

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

	cmp.l	#IDCMP_VANILLAKEY,188(a4)
	beq	auto_req

	cmp.l	#IDCMP_CLOSEWINDOW,188(a4)
	beq.s	cl_wndw

	bra.s	mainloop


cl_wndw	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

cl_icon	move.l  12(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_lays	move.l  204(a4),a1
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

 * When checking requester's idcmp the buttons are in backwards
 * (right to left) order. For example. With 3 buttons the rightmost button
 * will be 0, the middle button 1 and the leftmost 2.

auto_req
	suba.l	a0,a0
	lea	reqwtags(pc),a1
	move.l	8(a4),a6
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,208(a4)
	beq	mainloop

	lea	req_defs(pc),a0
	jsr	_LVOInitRequester(a6)

	lea	req_defs(pc),a0
	clr.l	(a0)				; clr.l	rq_OlderRequest(a0)
	move.w	#4,rq_LeftEdge(a0)
	move.w	#11,rq_TopEdge(a0)
	move.w	#292,rq_Width(a0)
	move.w	#77,rq_Height(a0)
	clr.w	rq_RelLeft(a0)
	clr.w	rq_RelTop(a0)
	move.l	#gad0,rq_ReqGadget(a0)
	move.l	#border,rq_ReqBorder(a0)
	move.l	#req_text0,rq_ReqText(a0)
	move.w	#USEREQIMAGE!SIMPLEREQ,rq_Flags(a0)
	clr.b	rq_BackFill(a0)
	clr.b	rq_KludgeFill00(a0)
	clr.l	rq_ReqLayer(a0)
	clr.l	rq_ImageBMap(a0)
	clr.l	rq_RWindow(a0)
	move.l	#req_image,rq_ReqImage(a0)
	move.l	208(a4),a1
	jsr	_LVORequest(a6)
	tst.l	d0
	beq	cl_reqw

req_l	move.l	208(a4),a0
	move.l	wd_UserPort(a0),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
	move.l	208(a4),a0
	move.l	wd_UserPort(a0),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,a1
	move.l	im_Class(a1),212(a4)
	move.w	im_Code(a1),216(a4)
	move.w	im_Qualifier(a1),218(a4)
	move.l	im_IAddress(a1),220(a4)
	move.w	im_MouseX(a1),224(a4)
	move.w	im_MouseY(a1),226(a4)
	jsr	_LVOReplyMsg(a6)

	cmp.l	#IDCMP_GADGETUP,212(a4)
	beq.s	req_gu

	bra.s	req_l

req_gu	move.l	220(a4),a0
	move.w	gg_GadgetID(a0),d0
	tst.b	d0
	beq.s	flash
	cmp.b	#1,d0
	beq.s	end_req
	bra.s	req_l

flash	suba.l	a0,a0
	move.l	8(a4),a6
	jsr	_LVODisplayBeep(a6)
	bra.s	req_l

end_req	lea	req_defs(pc),a0
	move.l	208(a4),a1
	move.l	8(a4),a6
	jsr	_LVOEndRequest(a6)

cl_reqw	move.l	208(a4),a0
	jsr	_LVOCloseWindow(a6)
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

gad0
	dc.l	gad1
	dc.w	14,57,64,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET!GTYP_REQGADGET
	dc.l	image0,image2,0,0,0
	dc.w	0
        dc.l	0

gad1
	dc.l	0
	dc.w	214,57,64,14,GFLG_GADGIMAGE!GFLG_GADGHIMAGE,GACT_IMMEDIATE!GACT_RELVERIFY,GTYP_BOOLGADGET!GTYP_REQGADGET
	dc.l	image0,image2,0,0,0
	dc.w	1
        dc.l	0

border
	dc.w	0,0
	dc.b	2,0,0,5
        dc.l	coords,border1

coords
	dc.w	4,2,4,50,5,50,5,2,286,2

border1
	dc.w	0,0
	dc.b	1,0,0,3
        dc.l	coords1,border2

coords1
	dc.w	5,50,287,50,287,2

border2
	dc.w	0,0
	dc.b	1,0,0,2
        dc.l	coords2,border3

coords2
	dc.w	286,3,286,49

border3
	dc.w	0,0
	dc.b	2,0,0,5
        dc.l	coords3,border4

coords3
	dc.w	4,53,4,74,5,74,5,53,286,53

border4
	dc.w	0,0
	dc.b	1,0,0,3
        dc.l	coords4,border5

coords4
	dc.w	5,74,287,74,287,53

border5
	dc.w	0,0
	dc.b	1,0,0,2
        dc.l	coords5,border6

coords5
	dc.w	286,54,286,73

border6
	dc.w	0,0
	dc.b	2,0,0,2
        dc.l	coords6,0

coords6
	dc.w	12,20,160,20

req_text0
	dc.b	2,0,0,0
	dc.w	16,9
	dc.l	topaz9,rtext0,req_text1

req_text1
	dc.b	1,0,0,0
	dc.w	86,9
	dc.l	topaz9,rtext1,req_text2

req_text2
	dc.b	1,0,0,0
	dc.w	16,33
	dc.l	topaz8,rtext2,0

req_image
	dc.w	220,7,32,23,2
	dc.l	rid0
	dc.b	3,0
	dc.l	req_image1

req_image1
	dc.w	252,7,32,23,2
	dc.l	rid1
	dc.b	3,0
	dc.l	0

topaz8
	dc.l	font_name
	dc.w	8
	dc.b	FS_NORMAL,FPF_ROMFONT

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

wndwtags
	dc.l	WA_Top,100
	dc.l	WA_Left,100
	dc.l	WA_Width,300
	dc.l	WA_Height,80
	dc.l	WA_DetailPen,0
	dc.l	WA_BlockPen,1
	dc.l	WA_Title,wndw_title
	dc.l	WA_IDCMP,IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_DELTAMOVE!IDCMP_MOUSEMOVE
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

reqwtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,300
	dc.l	WA_Height,90
	dc.l	WA_DetailPen,0
	dc.l	WA_BlockPen,1
	dc.l	WA_Title,wndw_title
	dc.l	WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_DELTAMOVE!IDCMP_MOUSEMOVE
	dc.l	WA_ReportMouse,TRUE
	dc.l	WA_RMBTrap,TRUE
	dc.l	WA_Activate,TRUE
	dc.l	WA_DepthGadget,TRUE
	dc.l	WA_DragBar,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_SmartRefresh,TRUE
	dc.l	WA_PubScreen
reqwscrn
	dc.l	0
	dc.l	TAG_DONE


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
layers_name	dc.b	'layers.library',0,0
mtstg0		dc.b	'ARG_ONE',0
mtstg1		dc.b	'ARG_TWO',0
mtstg2		dc.b	'ARG_THREE',0
mtstg3		dc.b	'ARG_FOUR',0,0
mtstg4		dc.b	'ARG_FIVE',0,0
mtstg5		dc.b	'ARG_SIX',0
ftstg0          dc.b    'TOOLTYPE_ONE',0,0
ftstg1          dc.b    'TOOLTYPE_TWO',0,0
template	dc.b	'KEYWORD_ONE/K,KEYWORD_TWO/K',0
wndw_text	dc.b	'Press any KEY for the requester',0
wndw_title	dc.b	'Custom_Requester.s',0,0
font_name	dc.b	'topaz.font',0,0
rtext0	dc.b	'ERROR:',0,0
rtext1	dc.b	'2746915',0
rtext2	dc.b	'Pick An Option',0,0


 * Buffer Variables.

membuf		dcb.b	300,0
req_defs	dcb.b	rq_SIZEOF,0
layers_defs	dcb.b	li_SIZEOF,0


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
	dc.l	%01111111111111111111111111111111


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
	dc.l	%10000000000000000000000000000000

id1
	dc.l	%00000000000000000000000000000001
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

	dc.l	%11111111111111111111111111111110
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

id2
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
	dc.l	%10000000000000000000000000000000

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
	dc.l	%01111111111111111111111111111111

id3
	dc.l	%11111111111111111111111111111110
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

	dc.l	%00000000000000000000000000000001
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

rid0
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%01111111111111111000000000000000
	dc.l	%00000001111111000000000000000000
	dc.l	%00000000111111100000000000111100
	dc.l	%00000000011111110000000001111110
	dc.l	%00000000001111110000000011111111
	dc.l	%00000000000111100000000111111111
	dc.l	%00000000000011000000001111111111
	dc.l	%00000000000000000001011111100111
	dc.l	%00000000000000000011111111000011
	dc.l	%00000000000000000111111110000001
	dc.l	%00000000000000001111111100000000
	dc.l	%00000000000000000111111000000000
	dc.l	%00000000000000000011110000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%01111111100000001111111100000011
	dc.l	%11000000110000011000000110000011
	dc.l	%11000000000000011000000110000011
	dc.l	%11000000110000011000000110000011
	dc.l	%01111111100000001111111100000011

	dc.l	%00000000000000000011111111111111
	dc.l	%00000000000000000000001111110000
	dc.l	%00000000000000000000011111100000
	dc.l	%00000000000000000000111111000000
	dc.l	%00000000000000000001111110000000
	dc.l	%00000000000000000011111100000000
	dc.l	%00000000000000000111111000000000
	dc.l	%00000000000000001111110000000000
	dc.l	%11111111111000011111100000000000
	dc.l	%00001111100000111111000000000000
	dc.l	%00000111110001111110000000000000
	dc.l	%00000011111011111100000000000000
	dc.l	%00000001111111111000000000000000
	dc.l	%00000000111111110000000000000000
	dc.l	%00000000011111100000000000000000
	dc.l	%00000000001111000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%01111111100000001111111100000011
	dc.l	%11000000110000011000000110000011
	dc.l	%11000000000000011000000110000011
	dc.l	%11000000110000011000000110000011
	dc.l	%01111111100000001111111100000011

rid1
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000111111111111111000000000
	dc.l	%00000000001111111000000000000000
	dc.l	%00000000011111110000000000000000
	dc.l	%00000000111111100000000000000000
	dc.l	%00000001111111000000000000000000
	dc.l	%10000011111110000000000000000000
	dc.l	%11000111111100000000000000000000
	dc.l	%11101111111000000000000000000000
	dc.l	%11111111110000000000000000000000
	dc.l	%11111111100000000000000000000000
	dc.l	%11111111000000000000000000000000
	dc.l	%01111110000000000000000000000000
	dc.l	%00111100000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%11111110000001111111111000000000
	dc.l	%00000011000001100000000000000000
	dc.l	%00000011000001111111100000000000
	dc.l	%00000011000001100000000000000000
	dc.l	%11111110000001111111111000000000

	dc.l	%11100000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000000000000
	dc.l	%11111110000001111111111000000000
	dc.l	%00000011000001100000000000000000
	dc.l	%00000011000001111111100000000000
	dc.l	%00000011000001100000000000000000
	dc.l	%11111110000001111111111000000000


	SECTION	VERSION,DATA

	dc.b	'$VER: Custom_Requester.s V1.01 (22.4.2001)',0


	END
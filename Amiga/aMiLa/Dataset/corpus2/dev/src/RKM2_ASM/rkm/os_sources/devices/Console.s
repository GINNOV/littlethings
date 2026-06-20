
 * This code shows how to set-up a Console Window, SendIO a read request
 * and then write the key you pressed to the console window. This code
 * only does the above once - It does not keep reading the keyboard, as
 * it is up to you to adapt this code for your own purposes.
 *
 * Notes: This code corrects the RKM console example, in that the RKM code
 *        does not work because it does not handle the cleanup routine
 *        properly. If you click on the close-window gadget before pressing
 *        a key the code hangs as CheckIO()/AbortIO() leave WaitIO() waiting
 *        forever. My solution is to just WaitIO(), if a WaitIO() is needed.
 *        A flag - 165(a4) - determines if the SendIO() has been satisfied
 *        and thus determines if a WaitIO() is needed when the close-window
 *        gadget has been clicked on and my cleanup IO routine (wait_io) is
 *        called.
 *
 *        The console window is set-up as a Cut N Paste window aswell.
 *        Simply use the mouse to highlight the `Console Text Test' text,
 *        Cut N Paste it by pressing RAmiga-C and then paste the text into
 *        a shell window for example by pressing RAmiga-V.

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
	INCLUDE	devices/console_lib.i
	INCLUDE	devices/console.i
	INCLUDE	devices/conunit.i

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
 * 156
 * 160
 * 164
 * 165 IO status
 * 166 Memory Buffer (12 bytes)
 * 178
 * 182 value 1 (for ToolType/CLI result)
 * 183 value 2 (for ToolType/CLI result)
 * 184 IClass
 * 188
 * 192
 * 196
 * 200 window
 * 204 window rastport
 * 208 screen rastport
 * 212 viewport
 * 216

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
	move.l	d0,200(a4)
	move.l	d0,wndwscrn
	beq	cl_icon

	suba.l	a0,a0
	move.l	200(a4),a1
	jsr	_LVOUnlockPubScreen(a6)

	suba.l	a0,a0
	lea	wndwtags(pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,200(a4)
	beq	cl_icon

	move.l	d0,a0
	move.l	wd_RPort(a0),204(a4)

	move.l	wndwscrn(pc),a0
	lea	sc_RastPort(a0),a1
	move.l	a1,208(a4)
	lea	sc_ViewPort(a0),a2
	move.l	a2,212(a4)

	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,writeport
	beq	cl_wndw
	move.l	d0,a0
	moveq	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,writeio
	beq	cl_writeport
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,readport
	beq	cl_writeio
	move.l	d0,a0
	moveq	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,readio
	beq	cl_readport
	move.l	writeio(pc),a1
	move.l	200(a4),IO_DATA(a1)
	move.l	#wd_Size,IO_LENGTH(a1)
	lea	con_name(pc),a0
	moveq	#CONU_SNIPMAP,d0
	moveq	#CONFLAG_DEFAULT,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	cl_readio

	move.l	readio(pc),a0
	move.l	writeio(pc),a1
	move.l	IO_DEVICE(a1),IO_DEVICE(a0)
	move.l	IO_UNIT(a1),IO_UNIT(a0)

	moveq	#0,d0
	moveq	#0,d6
	moveq	#0,d7
	move.l	200(a4),a0
	move.l	wd_UserPort(a0),a0
	move.b	MP_SIGBIT(a0),d0
	bset	d0,d6
	move.l	readport(pc),a0
	move.b	MP_SIGBIT(a0),d0
	bset	d0,d7
	move.l	d6,d5
	or.l	d7,d5

	move.l	writeio(pc),a1
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	lea	con_write(pc),a0
	move.l	a0,IO_DATA(a1)
	move.l	#-1,IO_LENGTH(a1)		
	jsr	_LVODoIO(a6)

	move.l	writeio(pc),a1
	move.l	IO_ACTUAL(a1),d0
	tst.b	IO_ERROR(a1)			; Was there an error?
	bne	con_error			; Yes. So exit.

read_con
	clr.b	165(a4)
	move.l	readio(pc),a1
	move.w	#CMD_READ,IO_COMMAND(a1)
	lea	readbuf(pc),a0
	move.l	a0,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)		
	move.l	4.w,a6
	jsr	_LVOSendIO(a6)

get_msg	move.l	d5,d0
	move.l	4.w,a6
	jsr	_LVOWait(a6)
	move.l	d0,d1
	and.l	d6,d1
	cmp.l	d6,d1
	beq.s	wndw
	move.l	d0,d1
	and.l	d7,d1
	cmp.l	d7,d1
	beq.s	port
	bra.s	get_msg

wndw	move.l	4.w,a6
	move.l	200(a4),a0
	move.l	wd_UserPort(a0),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,a1
	move.l	im_Class(a1),d2
	jsr	_LVOReplyMsg(a6)
	cmp.l	#IDCMP_CLOSEWINDOW,d2
	beq.s	wait_io
	bra.s	get_msg

port	move.l	writeio(pc),a1
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	lea	readbuf(pc),a0
	move.l	a0,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)		
	jsr	_LVODoIO(a6)

	move.b	#1,165(a4)
	bra.s	get_msg

wait_io	tst.b	165(a4)
	bne.s	cl_condev
	move.l	4.w,a6
	move.l	readio(pc),a1
	jsr	_LVOWaitIO(a6)
	tst.l	d0
	beq.s	cl_condev

con_error

	nop

cl_condev
	move.l	writeio(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

cl_readio
	move.l	readio(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

cl_readport
	move.l	readport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)

cl_writeio
	move.l	writeio(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

cl_writeport
	move.l	writeport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)

cl_wndw	move.l	200(a4),a0
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

convert_number
	lea	166(a4),a0
	move.l	d1,d7
	bsr.s	word_to_ascii
	clr.l	(a0)
	rts

word_to_ascii
	move.b	#48,(a0)
	moveq	#0,d1
	move.w	d7,d1
	divu	#1000,d1
	and.l	#$0000FFFF,d1
	divu	#10,d1
	bsr.s	do_val
	bsr.s	do_val
	moveq	#0,d1
	move.w	d7,d1
	divu	#1000,d1
	clr.w	d1
	swap	d1
	divu	#100,d1
	bsr.s	do_val
	divu	#10,d1
	bsr.s	do_val
	bsr.s	do_val
	rts

do_val	add.w	#$30,d1
	move.b	d1,(a0)+
	clr.w	d1
	swap	d1
	rts


 * Structure Definitions.

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

wndwtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width,640
	dc.l	WA_Height,200
	dc.l	WA_DetailPen,0
	dc.l	WA_BlockPen,1
	dc.l	WA_Title,wndw_title
	dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW
	dc.l	WA_Activate,TRUE
	dc.l	WA_CloseGadget,TRUE
	dc.l	WA_DepthGadget,TRUE
	dc.l	WA_DragBar,TRUE
	dc.l	WA_SizeGadget,TRUE
	dc.l	WA_MinWidth,320
	dc.l	WA_MinHeight,100
	dc.l	WA_MaxWidth,640
	dc.l	WA_MaxHeight,200
	dc.l	WA_SimpleRefresh,TRUE
	dc.l	WA_PubScreen
wndwscrn
	dc.l	0
	dc.l	TAG_DONE


 * Long Variables.

writeport	dc.l	0
writeio		dc.l	0
readport	dc.l	0
readio		dc.l	0


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
con_name	dc.b	'console.device',0,0
mtstg0		dc.b	'ARG_ONE',0
mtstg1		dc.b	'ARG_TWO',0
mtstg2		dc.b	'ARG_THREE',0
mtstg3		dc.b	'ARG_FOUR',0,0
mtstg4		dc.b	'ARG_FIVE',0,0
mtstg5		dc.b	'ARG_SIX',0
ftstg0          dc.b    'TOOLTYPE_ONE',0,0
ftstg1          dc.b    'TOOLTYPE_TWO',0,0
template	dc.b	'KEYWORD_ONE/K,KEYWORD_TWO/K',0
wndw_title	dc.b	'Console.s',0
font_name	dc.b	'topaz.font',0,0
con_write	dc.b	$1B,'[1mConsole Text Test',0


 * Buffer Variables.

membuf		dcb.b	300,0
readbuf		dcb.b	100,0


	SECTION	VERSION,DATA

	dc.b	'$VER: Console.s V1.01 (22.4.2001)',0


	END
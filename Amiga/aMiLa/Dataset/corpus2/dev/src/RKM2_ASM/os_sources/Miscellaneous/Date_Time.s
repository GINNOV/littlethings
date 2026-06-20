
	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE	intuition/gadgetclass.i
	INCLUDE	intuition/icclass.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/text.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE dos/dosextens.i
	INCLUDE	dos/datetime.i
	INCLUDE workbench/workbench_lib.i
	INCLUDE	workbench/workbench.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	utility/utility_lib.i
	INCLUDE	utility/utility.i
	INCLUDE	utility/date.i
	INCLUDE	devices/timer_lib.i
	INCLUDE	devices/timer.i

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
 * 156 Long Storage
 * 160
 * 164
 * 165
 * 166 Memory Buffer (12 bytes)
 * 178
 * 182 value 1 (for ToolType/CLI result)
 * 183 value 2 (for ToolType/CLI result)
 * 184 boopsi prop
 * 188 boopsi num0
 * 192 iclass
 * 196 icode
 * 198 iqualifier
 * 200 window
 * 204 window rastport
 * 208 screen rastport
 * 212 viewport
 * 216 iaddress
 * 220 mousex
 * 222 mousey
 * 224 _UtilityBase
 * 228
 * 232

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
        move.l  d0,224(a4)
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
	move.l	d0,timerport
	beq	cl_wndw
	move.l	d0,a0
	moveq	#IOTV_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,timerio
	beq	cl_timerport
	move.l	d0,a1
	lea	timer_name(pc),a0
	moveq	#UNIT_VBLANK,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	cl_timerio

	move.l	timerio(pc),a0
	move.l	IO_DEVICE(a0),a0
	move.l	a0,_TimerBase		; A pointer to the Timer.Library

	move.l	_TimerBase(pc),a6
	lea	timeval(pc),a0
	jsr	_LVOGetSysTime(a6)	; Fill in the timeval structure with
					; the system time. This function can
					; be called from interrupt.

	bsr	do_time

	lea	desttimeval(pc),a0	; destination.
	move.l	#100,TV_SECS(a0)
	move.l	#0,TV_MICRO(a0)
	lea	timeval(pc),a1		; source.
	move.l	_TimerBase(pc),a6
	jsr	_LVOAddTime(a6)		; The result gets put in destination.
					; This function can be called from
					; interrupt.

	lea	desttimeval(pc),a0
	lea	timeval(pc),a1
	jsr	_LVOCmpTime(a6)		; This function can be called from
	tst.l	d0			; interrupt.
	beq	same_time		; The timevals are equal in time.
	cmp.l	#-1,d0
	beq	dest_more		; destination has more time than
					; source.
dest_less				; The destination has less time than
					; source.

	bra	continue

same_time

	bra	continue
	
dest_more

continue

	lea	desttimeval(pc),a0	; destination.
	move.l	#50,TV_SECS(a0)
	move.l	#0,TV_MICRO(a0)
	lea	timeval(pc),a1		; source.
	jsr	_LVOSubTime(a6)		; The result gets put in destination.
					; This function can be called from
					; interrupt.

	lea	eclockval(pc),a0
	jsr	_LVOReadEClock(a6)	; The result gets put in eclockval.
	move.l	d0,d3			; This function can be called from
					; interrupt. D0 contains the number
					; of ticks per second count rate.

	move.l	timerio(pc),a1
	move.w	#TR_GETSYSTIME,IO_COMMAND(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)

	move.l	timerio(pc),a1
	lea	IOTV_TIME(a1),a1		; Filled by TR_GETSYSTIME
	lea	timeval(pc),a0			; Copy the timerio.timeval
	move.l	TV_SECS(a1),TV_SECS(a0)		; into timeval.
	move.l	TV_MICRO(a1),TV_MICRO(a0)

	move.l	4(a4),a6
	move.l	#100,d1
	jsr	_LVODelay(a6)

	bsr	do_time

	move.l	timerio(pc),a1
	move.w	#TR_SETSYSTIME,IO_COMMAND(a1)
	lea	IOTV_TIME(a1),a0
	move.l	#$f4d8f4,TV_SECS(a0)
	move.l	#$c20b2,TV_MICRO(a0)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)

	move.l	4(a4),a6
	move.l	#100,d1
	jsr	_LVODelay(a6)

	bsr	do_time


invalid_date
	nop

	move.l	4(a4),a6
	move.l	#500,d1
	jsr	_LVODelay(a6)

cl_timerdev
	movea.l	timerio(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

cl_timerio
	movea.l	timerio(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

cl_timerport
	movea.l	timerport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)

cl_wndw	move.l	200(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

cl_icon	move.l  12(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_util	move.l  224(a4),a1
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

do_time
	lea	timeval(pc),a0
	move.l	TV_SECS(a0),d0
	lea	clockdata(pc),a0
	move.l	224(a4),a6
	jsr	_LVOAmiga2Date(a6)	; fill in the clockdata structure.

	lea	clockdata(pc),a0
	jsr	_LVOCheckDate(a6)	; Check clockdata for a legal date.
	tst.l	d0
	beq	invalid_date

	lea	clockdata(pc),a0
	jsr	_LVODate2Amiga(a6)	; Calculate seconds from 1.1.78 to
	move.l	d0,d3			; the date in clockdata.

	bsr	print_date

	rts

print_date
	moveq	#16,d0
	moveq	#26,d1
	move.l	204(a4),a1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	lea	date_string(pc),a0
	moveq	#53,d0
	move.l	204(a4),a1
	jsr	_LVOText(a6)

	moveq	#16,d0
	moveq	#36,d1
	move.l	204(a4),a1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	lea	clockdata(pc),a1
	moveq	#0,d1
	move.w	hour(a1),d1
	bsr	convert_number
	lea	166(a4),a0
	moveq	#5,d0
	move.l	204(a4),a1
	jsr	_LVOText(a6)

	moveq	#86,d0
	moveq	#36,d1
	move.l	204(a4),a1
	jsr	_LVOMove(a6)
	lea	clockdata(pc),a1
	moveq	#0,d1
	move.w	min(a1),d1
	bsr	convert_number
	lea	166(a4),a0
	moveq	#5,d0
	move.l	204(a4),a1
	jsr	_LVOText(a6)

	move.l	#166,d0
	moveq	#36,d1
	move.l	204(a4),a1
	jsr	_LVOMove(a6)
	lea	clockdata(pc),a1
	moveq	#0,d1
	move.w	sec(a1),d1
	bsr	convert_number
	lea	166(a4),a0
	moveq	#5,d0
	move.l	204(a4),a1
	jsr	_LVOText(a6)

	move.l	#232,d0
	moveq	#36,d1
	move.l	204(a4),a1
	jsr	_LVOMove(a6)
	lea	clockdata(pc),a1
	moveq	#0,d1
	move.w	wday(a1),d1
	bsr	convert_number
	lea	166(a4),a0
	moveq	#5,d0
	move.l	204(a4),a1
	jsr	_LVOText(a6)

	move.l	#284,d0
	moveq	#36,d1
	move.l	204(a4),a1
	jsr	_LVOMove(a6)
	lea	clockdata(pc),a1
	moveq	#0,d1
	move.w	mday(a1),d1
	bsr	convert_number
	lea	166(a4),a0
	moveq	#5,d0
	move.l	204(a4),a1
	jsr	_LVOText(a6)

	move.l	#344,d0
	moveq	#36,d1
	move.l	204(a4),a1
	jsr	_LVOMove(a6)
	lea	clockdata(pc),a1
	moveq	#0,d1
	move.w	month(a1),d1
	bsr	convert_number
	lea	166(a4),a0
	moveq	#5,d0
	move.l	204(a4),a1
	jsr	_LVOText(a6)

	move.l	#406,d0
	moveq	#36,d1
	move.l	204(a4),a1
	jsr	_LVOMove(a6)
	lea	clockdata(pc),a1
	moveq	#0,d1
	move.w	year(a1),d1
	bsr	convert_number
	lea	166(a4),a0
	moveq	#5,d0
	move.l	204(a4),a1
	jsr	_LVOText(a6)
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
	dc.l	WA_Height,60
	dc.l	WA_DetailPen,0
	dc.l	WA_BlockPen,1
	dc.l	WA_Title,wndw_title
	dc.l	WA_IDCMP,IDCMP_GADGETUP!IDCMP_GADGETDOWN!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW!IDCMP_IDCMPUPDATE
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


 * Long Variables.

_TimerBase	dc.l	0
timerio		dc.l	0
timerport	dc.l	0


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
wndw_title	dc.b	'Date_Time.s',0
font_name	dc.b	'topaz.font',0,0
timer_name	dc.b	'timer.device',0,0
date_string	dc.b	'Hours   Minutes   Seconds   Day   Date   Month   Year',0


 * Buffer Variables.

membuf		dcb.b	300,0
timeval		dcb.b	TV_SIZE,0
desttimeval	dcb.b	TV_SIZE,0
eclockval	dcb.b	EV_SIZE,0
clockdata	dcb.b	CD_SIZE


	SECTION	VERSION,DATA

	dc.b	'$VER: Date_Time.s V1.01 (22.4.2001)',0


	END
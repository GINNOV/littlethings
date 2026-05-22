
 * Memory Buffer addresses.
 *
 *   0  Startup Return Message
 *   4  _DOSBase
 *   8  _IntuitionBase
 *  12 _IconBase
 *  16 Old Directory from CurrentDir()
 *  20 Disk Object from GetDiskObject()
 *  24 Argument addresses (30*4)
 * 144 ReadArgs() return value
 * 148 Input Port
 * 152 Input IO
 * 156 Handler's Interrupt
 * 160 Game Port
 * 164 Game IO
 * 168 Keyboard Port
 * 172 Keyboard IO
 * 176 Task address
 * 180 NUMERICPAD Port
 * 184 Trackdisk Port
 * 188 Trackdisk IO
 * 192 _GfxBase
 * 196 pmcommand 
 * 198 pmaction
 * 200 controller 
 * 201 gameport
 * 202 Keyboard Buffer
 * 218 pmstatus
 * 219 status
 * 220 pmdata
 * 221 Handler Priority
 * 222 pmseconds
 * 226 pmmicros
 * 230 _InputBase
 * 234 border
 * 235
 * 236
 *

	INCDIR	WORK:Include/

	INCLUDE	work:devpac/large.gs
	INCLUDE	misc/missing_keys.i

LIB_VER		EQU	39
TRUE		EQU	-1
FALSE		EQU	0

	lea	membuf(pc),a4

	move.b	#1,200(a4)		; Default Controller (Mouse)
	move.b	#100,221(a4)		; Default Handler Priority

	suba.l	a1,a1
	move.l	4.w,a6
	jsr	_LVOFindTask(a6)
	tst.l	d0
	beq	exit
	move.l	d0,a5
	move.l	a5,176(a4)
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
        move.l  d0,192(a4)
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
	clr.b	201(a4)
	bra.s	tt1
tto1	move.l	a3,a0
	lea	mtstg1(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tt1
	move.b	#1,201(a4)
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
	clr.b	200(a4)
	bra.s	tt2
tto2	move.l	a3,a0
	lea	mtstg3(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto3
	move.b	#1,200(a4)
	bra.s	tt2
tto3	move.l	a3,a0
	lea	mtstg4(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto4
	move.b	#2,200(a4)
	bra.s	tt2
tto4	move.l	a3,a0
	lea	mtstg5(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tt2
	move.b	#3,200(a4)
tt2	move.l	a5,a0
        lea	ftstg2(pc),a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	tt3
	move.l	d0,a3
	move.l	a3,a0
	lea	mtstg6(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto5
	clr.b	234(a4)
	bra.s	tt3
tto5	move.l	a3,a0
	lea	mtstg7(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tt3
	move.b	#1,234(a4)
tt3	move.l	a5,a0
        lea	ftstg3(pc),a1
        jsr	_LVOFindToolType(a6)
	tst.l	d0
        beq.s	tt4
	move.l	d0,a3
	move.l	a3,a0
	lea	mtstg8(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto6
	move.b	#-32,221(a4)
	bra.s	tt4
tto6	move.l	a3,a0
	lea	mtstg9(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto7
	move.b	#-16,221(a4)
	bra.s	tt4
tto7	move.l	a3,a0
	lea	mtstg10(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto8
	clr.b	221(a4)
	bra.s	tt4
tto8	move.l	a3,a0
	lea	mtstg11(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tto9
	move.b	#16,221(a4)
	bra.s	tt4
tto9	move.l	a3,a0
	lea	mtstg12(pc),a1
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	beq.s	tt4
	move.b	#32,221(a4)
tt4
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
	clr.b	201(a4)
	bra.s	ca1
cao1	move.l	(a5),a0
	lea	mtstg1(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	ca1
	move.b	#1,201(a4)
ca1	move.l	4(a5),a0
	lea	mtstg2(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao2
	clr.b	200(a4)
	bra.s	ca2
cao2	move.l	4(a5),a0
	lea	mtstg3(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao3
	move.b	#1,200(a4)
	bra.s	ca2
cao3	move.l	4(a5),a0
	lea	mtstg4(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao4
	move.b	#2,200(a4)
	bra.s	ca2
cao4	move.l	4(a5),a0
	lea	mtstg5(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	ca2
	move.b	#3,200(a4)
ca2	move.l	8(a5),a0
	lea	mtstg6(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao5
	clr.b	234(a4)
	bra.s	ca3
cao5	move.l	8(a5),a0
	lea	mtstg7(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	ca3
	move.b	#1,234(a4)
ca3	move.l	12(a5),a0
	lea	mtstg8(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao6
	move.b	#-32,221(a4)
	bra.s	ca4
cao6	move.l	12(a5),a0
	lea	mtstg9(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao7
	move.b	#-16,221(a4)
	bra.s	ca4
cao7	move.l	12(a5),a0
	lea	mtstg10(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao8
	clr.b	221(a4)
	bra.s	ca4
cao8	move.l	12(a5),a0
	lea	mtstg11(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	cao9
	move.b	#16,221(a4)
	bra.s	ca4
cao9	move.l	12(a5),a0
	lea	mtstg12(pc),a1
	bsr	cmpbyte
	tst.l	d0
	bne.s	ca4
	move.b	#32,221(a4)
ca4
	nop


free_cliargs
        move.l	144(a4),d1
        jsr	_LVOFreeArgs(a6)

zero_args

	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,148(a4)
	beq	cl_icon
	move.l	d0,a0
	moveq	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,152(a4)
	beq	cl_ip
	move.l	d0,a1
	lea	ip_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	cl_iio
	move.l	152(a4),a1
	move.l	IO_DEVICE(a1),a0
	move.l	a0,230(a4)

	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,168(a4)
	beq	cl_id
	move.l	d0,a0
	moveq	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,172(a4)
	beq	cl_kp
	move.l	d0,a1
	lea	kp_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	cl_kio

	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,160(a4)
	beq	cl_kd
	move.l	d0,a0
	moveq	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,164(a4)
	beq	cl_gp
	move.l	d0,a1
	lea	gp_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	cl_gio

 * Set-Up a Message Port.

        jsr	_LVOForbid(a6)
        lea     portname(pc),a1
        jsr	_LVOFindPort(a6)
        tst.l   d0
        bne.s	exists
        moveq   #MP_SIZE,d0
        move.l  #MEMF_PUBLIC!MEMF_CLEAR,d1
        jsr	_LVOAllocMem(a6)
        move.l  d0,180(a4)
        beq.s	no_pmem
        move.l  d0,a0
        clr.l	(a0)				; LN_SUCC(a0)
        clr.l	LN_PRED(a0)
        move.b  #NT_MSGPORT,LN_TYPE(a0)
        clr.b	LN_PRI(a0)
        lea     portname(pc),a1
        move.l  a1,LN_NAME(a0)
        move.b  #PA_SIGNAL,MP_FLAGS(a0)
        move.l  176(a4),MP_SIGTASK(a0)
        moveq	#-1,d0
        jsr	_LVOAllocSignal(a6)
        move.b  d0,d5
        cmp.l	#-1,d0
        bne.s	ad_port
        jsr	_LVOPermit(a6)
	bra	frmport
ad_port	move.l	180(a4),a1
        move.b  d5,MP_SIGBIT(a1)
        jsr	_LVOAddPort(a6)
        jsr	_LVOPermit(a6)
	bra.s	do_hand

exists	jsr	_LVOPermit(a6)
        bra     cl_gd

no_pmem	jsr	_LVOPermit(a6)
        bra	cl_gd

do_hand	bsr	set_gp
	bsr	set_ct
	bsr	blank
	bsr	ad_hand
	tst.b	d2
	beq	hand_err

msg_l	move.l	180(a4),a0
	move.l	4.w,a6
	jsr	_LVOWaitPort(a6)
	move.l	180(a4),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,a1
	move.w	pm_Command(a1),196(a4)
	move.w	pm_Action(a1),198(a4)
	move.l	pm_Seconds(a1),222(a4)
	move.l	pm_Micros(a1),226(a4)
	move.b	pm_Data(a1),220(a4)
	move.b	pm_Status(a1),218(a4)

 * You can reply to a Message.

	cmp.w	#PMCOMMAND_GETSTATUS,196(a4)
	bne.s	reply
	move.b	219(a4),pm_Status(a1)

reply	jsr	_LVOReplyMsg(a6)

 * Check the appropriate message field/s sent to us.

	cmp.w	#PMCOMMAND_SETGAMEPORT,196(a4)
	beq.s	do_gp

	cmp.w	#PMCOMMAND_SETCONTROLLER,196(a4)
	beq	do_ct

	cmp.w	#PMCOMMAND_SETKEYREPEATTIME,196(a4)
	beq	do_kr

	cmp.w	#PMCOMMAND_SETKEYPRESSTIME,196(a4)
	beq	do_kp

	cmp.w	#PMCOMMAND_USENUMERICPAD,196(a4)
	beq	do_keyb

	cmp.w	#PMCOMMAND_SETBORDER,196(a4)
	beq.s	do_bb

	cmp.w	#PMCOMMAND_DISKDRIVECLICK,196(a4)
	beq	do_td


	cmp.w	#PMCOMMAND_QUIT,196(a4)
	beq	exit_message

	bra	msg_l

do_gp	clr.b	201(a4)
	cmp.w	#PMGAMEPORT_MOUSEINJPORT,198(a4)
	beq.s	gp1
	bra.s	gp_c0
gp1	move.b	#1,201(a4)
gp_c0	bsr.s	set_gp
	bra	msg_l

set_gp	move.l	152(a4),a1
	move.w	#IND_SETMPORT,IO_COMMAND(a1)
	lea	201(a4),a0
	move.l	a0,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
	rts

do_bb	clr.b	234(a4)
	cmp.w	#PMBORDER_ON,198(a4)
	beq.s	bb1
	bra.s	bb_c0
bb1	move.b	#1,234(a4)
bb_c0	bsr.s	blank
	bra	msg_l

blank	move.l	192(a4),a0
	lea	gb_BP3Bits(a0),a0
	tst.b	234(a4)
	beq.s	bb0
	bset	#5,(a0)
	bra.s	bb_end
bb0	bclr	#5,(a0)
bb_end	move.l	8(a4),a6
	jsr	_LVORemakeDisplay(a6)
	rts

do_ct	cmp.w	#PMCONTROLLER_NOCONTROLLER,198(a4)
	beq.s	ct0
	cmp.w	#PMCONTROLLER_MOUSE,198(a4)
	beq.s	ct1
	cmp.w	#PMCONTROLLER_RELATIVEJOYSTICK,198(a4)
	beq.s	ct2
	cmp.w	#PMCONTROLLER_ABSOLUTEJOYSTICK,198(a4)
	beq.s	ct3
	bra	msg_l
ct0	clr.b	200(a4)
	bra.s	sct_c0
ct1	move.b	#1,200(a4)
	bra.s	sct_c0
ct2	move.b	#2,200(a4)
	bra.s	sct_c0
ct3	move.b	#3,200(a4)
sct_c0	bsr.s	set_ct
	bra	msg_l

set_ct	move.l	164(a4),a1
	move.w	#GPD_SETCTYPE,IO_COMMAND(a1)
	lea	200(a4),a0
	move.l	a0,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
	move.l	164(a4),a1
	cmp.b	#GPDERR_SETCTYPE,IO_ERROR(a1)
	beq.s	sct_end
	nop
sct_end	rts

do_td	cmp.w	#PMDF0CLICK_OFF,198(a4)
	beq.s	td0
	cmp.w	#PMDF1CLICK_OFF,198(a4)
	beq.s	td1
	cmp.w	#PMDF2CLICK_OFF,198(a4)
	beq.s	td2
	cmp.w	#PMDF3CLICK_OFF,198(a4)
	beq.s	td3
	cmp.w	#PMDF0CLICK_ON,198(a4)
	beq.s	td4
	cmp.w	#PMDF1CLICK_ON,198(a4)
	beq.s	td5
	cmp.w	#PMDF2CLICK_ON,198(a4)
	beq.s	td6
	cmp.w	#PMDF3CLICK_ON,198(a4)
	beq.s	td7
	bra	msg_l
td0	moveq	#0,d2
	bra.s	td_c3
td1	moveq	#1,d2
	bra.s	td_c3
td2	moveq	#2,d2
	bra.s	td_c3
td3	moveq	#3,d2
td_c3	clr.b	d3
	bra.s	td_c5
td4	moveq	#0,d2
	bra.s	td_c4
td5	moveq	#1,d2
	bra.s	td_c4
td6	moveq	#2,d2
	bra.s	td_c4
td7	moveq	#3,d2
td_c4	move.b	#1,d3
td_c5	bsr.s	set_td
	bra	msg_l

set_td	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,184(a4)
	beq.s	scr_end
	move.l	d0,a0
	moveq	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,188(a4)
	beq.s	cl_tdp
	move.l	d0,a1
	lea	td_name(pc),a0
	move.l	d2,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne.s	cl_tdio
	move.l	188(a4),a0
	move.l	IO_UNIT(a0),a0
	lea	TDU_PUBFLAGS(a0),a0
	tst.b	d3
	beq.s	clr_td
	bset	#TDPB_NOCLICK,(a0)
	bra.s	cl_td
clr_td	bclr	#TDPB_NOCLICK,(a0)
cl_td	move.l	188(a4),a1
	jsr	_LVOCloseDevice(a6)
cl_tdio	move.l	188(a4),a0
	jsr	_LVODeleteIORequest(a6)
cl_tdp	move.l	184(a4),a0
	jsr	_LVODeleteMsgPort(a6)
scr_end	rts

do_kr	move.l	152(a4),a1
	move.w	#IND_SETTHRESH,IO_COMMAND(a1)
	bra.s	set_krp
do_kp	move.l	152(a4),a1
	move.w	#IND_SETPERIOD,IO_COMMAND(a1)
set_krp	lea	IOTV_TIME(a1),a0
	move.l	222(a4),(a0)				; TV_SECS(a0)
	move.l	226(a4),TV_MICRO(a0)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
	bra	msg_l

do_keyb	move.l	172(a4),a1
	move.w	#KBD_READMATRIX,IO_COMMAND(a1)
	lea	202(a4),a0
	move.l	a0,IO_DATA(a1)
	move.l	#16,IO_LENGTH(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
	move.l	172(a4),a1
	move.l	IO_DATA(a1),a0		; address of your `matrix' buffer
	move.l	IO_ACTUAL(a1),d0	; #bytes put into `matrix' buffer

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.b	11(a0),d0
	move.b	9(a0),d1
	move.b	7(a0),d2
	move.b	5(a0),d3
	move.b	3(a0),d4
	move.b	8(a0),d5
	move.b	1(a0),d6
	move.b	12(a0),d7
	btst	#3,d7			; see if CTRL was pressed
	beq.s	ramiga
	btst	#2,d0			; see if ( was pressed
	bne	do_num0
	btst	#3,d0			; see if ) was pressed
	bne	do_scr0
	btst	#4,d0			; see if / was pressed
	bne	do_syr0
	btst	#5,d0			; see if * was pressed
	bne	do_prs0
	btst	#6,d0			; see if + was pressed
	bne	do_add0
	btst	#2,d1			; see if - was pressed
	bne	do_sub0
	btst	#5,d2			; see if Home was pressed
	bne	do_hme0
	btst	#7,d2			; see if PgUp was pressed
	bne	do_pup0
	btst	#5,d4			; see if End was pressed
	bne	do_end0
	btst	#7,d4			; see if PgDn was pressed
	bne	do_pdn0
	btst	#7,d6			; see if Ins was pressed
	bne.s	keyb_e
	bra	do_keyb
ramiga	move.b	12(a0),d7
	btst	#7,d7			; see if RIGHT AMIGA was pressed
	beq.s	ralt
	btst	#2,d0			; see if ( was pressed
	bne.s	do_num1
	btst	#3,d0			; see if ) was pressed
	bne.s	do_scr1
	btst	#4,d0			; see if / was pressed
	bne.s	do_syr1
	btst	#5,d0			; see if * was pressed
	bne.s	do_prs1
	btst	#6,d0			; see if + was pressed
	bne.s	do_add1
	btst	#2,d1			; see if - was pressed
	bne	do_sub1
	btst	#5,d2			; see if Home was pressed
	bne	do_hme1
	btst	#7,d2			; see if PgUp was pressed
	bne	do_pup1
	btst	#5,d4			; see if End was pressed
	bne	do_end1
	btst	#7,d4			; see if PgDn was pressed
	bne	do_pdn1
	btst	#7,d6			; see if Ins was pressed
	bne	reset
	bra	do_keyb
ralt	nop
	bra	do_keyb

keyb_e	move.b	#255,219(a4)	
	bra	msg_l

do_num0	moveq	#0,d2
	bra.s	td_c0
do_scr0	moveq	#1,d2
	bra.s	td_c0
do_syr0	moveq	#2,d2
	bra.s	td_c0
do_prs0	moveq	#3,d2
td_c0	clr.b	d3
	bra.s	td_c2
do_num1	moveq	#0,d2
	bra.s	td_c1
do_scr1	moveq	#1,d2
	bra.s	td_c1
do_syr1	moveq	#2,d2
	bra.s	td_c1
do_prs1	moveq	#3,d2
td_c1	move.b	#1,d3
td_c2	bsr	set_td
	bra	do_keyb

do_add0	clr.b	201(a4)
	bra.s	gp_c1
do_add1	move.b	#1,201(a4)
gp_c1	bsr	set_gp
	bra	do_keyb

do_sub0	clr.b	234(a4)
	bra.s	sub_c0
do_sub1	move.b	#1,234(a4)
sub_c0	bsr	blank
	bra	do_keyb

do_hme0	clr.b	200(a4)
	bra.s	do_sct
do_pup0	move.b	#1,200(a4)
	bra.s	do_sct
do_pdn0	move.b	#2,200(a4)
	bra.s	do_sct
do_end0	move.b	#3,200(a4)
do_sct	bsr	set_ct
	bra	do_keyb

do_hme1

	bra	do_keyb

do_pup1

	bra	do_keyb

do_pdn1

	bra	do_keyb

do_end1

	bra	do_keyb

reset	move.l	4.w,a6
	jsr	_LVOColdReboot(a6)
	bra	msg_l


exit_message
	moveq	#100,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

	suba.l	a0,a0
	move.l	8(a4),a6
	jsr	_LVODisplayBeep(a6)

	moveq	#100,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

	suba.l	a0,a0
	move.l	8(a4),a6
	jsr	_LVODisplayBeep(a6)

	bsr	fr_hand
	bra.s	fr_port

hand_err
	nop

fr_port	move.l	180(a4),a0
	tst.l	a0
        beq.s	cl_gd
	move.l	4.w,a6
        tst.b	MP_SIGBIT(a0)
        beq.s	no_sig
        jsr	_LVOFreeSignal(a6)
no_sig	move.l	180(a4),a1
        jsr	_LVORemPort(a6)
frmport	move.l	180(a4),a1
        moveq   #MP_SIZE,d0
	move.l	4.w,a6
        jsr	_LVOFreeMem(a6)

cl_gd	move.l	164(a4),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

cl_gio	move.l	164(a4),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

cl_gp	move.l	160(a4),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)

cl_kd	move.l	172(a4),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

cl_kio	move.l	172(a4),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

cl_kp	move.l	168(a4),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)

cl_id	move.l	152(a4),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

cl_iio	move.l	152(a4),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

cl_ip	move.l	148(a4),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)

cl_icon	move.l  12(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_gfx	move.l  192(a4),a1
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

ad_hand	clr.b	d2
	moveq	#IS_SIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,156(a4)
	beq.s	ah_end
	move.l	d0,a0
	clr.l	(a0)
	clr.l	LN_PRED(a0)
	move.b	#NT_INTERRUPT,LN_TYPE(a0)
	move.b	221(a4),LN_PRI(a0)
	lea	is_name(pc),a1
	move.l	a1,LN_NAME(a0)
	clr.l	IS_DATA(a0)
	lea	is_code,a1
	move.l	a1,IS_CODE(a0)
	move.l	152(a4),a1
	move.w	#IND_ADDHANDLER,IO_COMMAND(a1)
	move.l	a0,IO_DATA(a1)
	move.l	#IS_SIZE,IO_LENGTH(a1)
	jsr	_LVODoIO(a6)
	move.b	#1,d2
ah_end	rts

fr_hand	move.l	156(a4),a0
	move.l	152(a4),a1
	move.w	#IND_REMHANDLER,IO_COMMAND(a1)
	move.l	a0,IO_DATA(a1)
	move.l	#IS_SIZE,IO_LENGTH(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
	move.l	156(a4),a1
	moveq	#IS_SIZE,d0
	jsr	_LVOFreeMem(a6)
	rts

is_code	move.l	a0,-(a7)		; Save `event list' pointer.
ic_loop	moveq	#0,d0
	cmp.b	#IECLASS_RAWKEY,ie_Class(a0)
	bne	next_event
	move.w	ie_Qualifier(a0),d0
	and.w	#IEQUALIFIER_NUMERICPAD,d0
	beq.s	check_1
	move.w	ie_Qualifier(a0),d0
	and.w	#IEQUALIFIER_RSHIFT,d0
	beq.s	check_1
	move.w	ie_Code(a0),d0
	and.w	#IECODE_UP_PREFIX,d0
	bne	next_event
	move.w	ie_Code(a0),d0
	cmp.b	#$2F,d0
	bne.s	sftleft
        move.w  #$4E,ie_Code(a0)
	bra.s	do_shft
sftleft	cmp.b	#$2D,d0
	bne.s	sftup
        move.w  #$4F,ie_Code(a0)
	bra.s	do_shft
sftup	cmp.b	#$3E,d0
	bne.s	sftdown
        move.w  #$4C,ie_Code(a0)
	bra.s	do_shft
sftdown	cmp.b	#$1E,d0
	bne	next_event
        move.w  #$4D,ie_Code(a0)
do_shft	move.b	#IECLASS_RAWKEY,ie_Class(a0)
        move.w  #IEQUALIFIER_REPEAT!IEQUALIFIER_RSHIFT,ie_Qualifier(a0)
	bra	next_event
check_1	move.w	ie_Qualifier(a0),d0
	and.w	#IEQUALIFIER_NUMERICPAD,d0
	beq	check_2
	move.w	ie_Code(a0),d0
	and.w	#IECODE_UP_PREFIX,d0
	bne	next_event
	move.w	ie_Code(a0),d0
	cmp.b	#$2F,d0
	bne.s	numleft
        move.w  #$4E,ie_Code(a0)
	bra.s	do_num
numleft	cmp.b	#$2D,d0
	bne.s	num_up
        move.w  #$4F,ie_Code(a0)
	bra.s	do_num
num_up	cmp.b	#$3E,d0
	bne.s	numdown
        move.w  #$4C,ie_Code(a0)
	bra.s	do_num
numdown	cmp.b	#$1E,d0
	bne.s	num_del
        move.w  #$4D,ie_Code(a0)
	bra.s	do_num
num_del	cmp.b	#$3C,d0
	bne.s	num_ent
        move.w  #$46,ie_Code(a0)
	bra.s	do_num
num_ent	cmp.b	#$43,d0
	bne.s	numhome
        move.w  #$44,ie_Code(a0)
	bra.s	next_event
numhome	cmp.b	#$3D,d0
	bne.s	num_end
        move.w  #$5F,ie_Code(a0)
	bra.s	do_num
num_end	cmp.b	#$1D,d0
	bne.s	num_5
        move.w  #$45,ie_Code(a0)
	bra.s	do_num
num_5	cmp.b	#$2E,d0
	bne.s	next_event
        move.w  #$40,ie_Code(a0)
do_num	move.b	#IECLASS_RAWKEY,ie_Class(a0)
        move.w  #IEQUALIFIER_REPEAT,ie_Qualifier(a0)
	bra.s	next_event
check_2	nop

next_event
	move.l	(a0),d0		; get the next (ie.NextEvevnt) event.
	move.l	d0,a0
	bne	ic_loop		; repeat until all events have been
				; read/altered.

ic_end	move.l	(a7)+,d0	; return `event list' pointer.
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


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
ip_name		dc.b	'input.device',0,0
gp_name		dc.b	'gameport.device',0
kp_name		dc.b	'keyboard.device',0
td_name		dc.b	'trackdisk.device',0,0
is_name		dc.b	'NUMERICPAD Handler',0,0
portname        dc.b    'NUMERICPAD Port',0

mtstg0		dc.b	'MOUSEINMPORT',0,0
mtstg1		dc.b	'MOUSEINJPORT',0,0
mtstg2		dc.b	'NOCONTROLLER',0,0
mtstg3		dc.b	'MOUSE',0
mtstg4		dc.b	'RELATIVEJOYSTICK',0,0
mtstg5		dc.b	'ABSOLUTEJOYSTICK',0,0
mtstg6		dc.b	'BORDEROFF',0
mtstg7		dc.b	'BORDERON',0,0
mtstg8		dc.b	'-32',0
mtstg9		dc.b	'-16',0
mtstg10		dc.b	'0',0
mtstg11		dc.b	'16',0,0
mtstg12		dc.b	'32',0,0

ftstg0          dc.b    'SETGAMEPORT',0
ftstg1          dc.b    'SETCONTROLLER',0
ftstg2          dc.b    'SETBORDER',0
ftstg3		dc.b    'HANDLERPRIORITY',0

template	dc.b	'SETGAMEPORT/K,SETCONTROLLER/K,SETBORDER,HANDLERPRIORITY/K',0


 * Buffer Variables.

membuf		dcb.b	260,0


	SECTION	VERSION,DATA

	dc.b	'$VER: NUMERICPAD Handler V1.00 (17.4.2001)',0


	END
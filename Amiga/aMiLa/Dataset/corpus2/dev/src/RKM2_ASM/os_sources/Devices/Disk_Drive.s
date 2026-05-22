
 * This code shows the CORRECT way to do things with regards to the standard
 * 3.5 disk drive. By this I mean that various articles/books/etc with
 * trackdisk.device examples in them (I'm talking mainly of pre-1992 codes)
 * have usually only mentioned one command at a time. So, for example, they
 * might not test if a disk is in the drive but still carry out a command
 * because they assume you have a disk in the drive.
 *
 * This code not only checks if a disk is in the drive before issuing certain
 * commands but it also does things in a correct order. For example. It
 * checks that certain situations are met before trying to get a disk's
 * info. Like checking if the disk drive is empty, not issuing TD_SEEK or
 * TD_EJECT etc if the disk drive is empty. As an example run this program
 * with and then without a disk in the drive.
 *
 * This code is set up for DF1:
 *
 * Apart from Format, Read, Write (see notes in this file) and the Extended
 * commands and normal IO commands this program covers most, if not all, of
 * the other trackdisk commands.
 *
 * Note: This program reads the Bytes used, aswell as the KBs, for example
 *       of a floppy disk. FFS does not give a byte return (i.e disk 879KB
 *       and 0 Bytes used). OFS gives byte return (i.e disk 879KB and 2Bytes
 *       used). Having this byte information can be the difference between
 *       you having space for a small utility on your disk and you having to
 *       use a second disk for that small utility!!

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
	INCLUDE	devices/trackdisk.i

LIB_VER		EQU	39
TRUE		EQU	-1
FALSE		EQU	0
DISKDRIVE	EQU	1		; DF1:

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
 * 188
 * 192
 * 194
 * 196
 * 200
 * 202
 * 204 screen
 * 208 colourmap
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
	beq.s	cl_icon

	suba.l	a0,a0
	lea	wndwtags(pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,178(a4)
	beq.s	exit_closescreen

	move.l	178(a4),a0
	move.l	wd_RPort(a0),156(a4)
	move.l	wndwscrn(pc),a0
	lea	sc_RastPort(a0),a1
	move.l	a1,184(a4)
	lea	sc_ViewPort(a0),a0
	move.l	a0,160(a4)

	bra	floppydisk

floppy_done

	move.l	#500,d1
	move.l	4(a4),a6
	jsr	_LVODelay(a6)

exit_closewindow
	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

exit_closescreen
	move.l	wndwscrn(pc),a0
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

floppydisk

	move.b	#2,d0
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOSetAPen(a6)
	move.l	156(a4),a0
	lea	ddtitle(pc),a1
	moveq	#20,d0
	moveq	#19,d1
        move.l	8(a4),a6
        jsr	_LVOPrintIText(a6)
	move.l	156(a4),a0
	lea	wit1(pc),a1
	moveq	#20,d0
	moveq	#36,d1
        jsr	_LVOPrintIText(a6)
	move.l	156(a4),a0
	lea	wit17(pc),a1
	move.l	#340,d0
	moveq	#36,d1
        jsr	_LVOPrintIText(a6)

	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,tdport
	beq	td_end
	move.l	d0,a0
	moveq.l	#IOTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,tdio
	beq	cl_tdport
	move.l	d0,a1
	lea	td_name(pc),a0
	moveq	#DISKDRIVE,d0
	moveq	#TDF_ALLOW_NON_3_5,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	cl_tdio

 * Switch Off the clicking sound.

	move.l	tdio(pc),a0
	move.l	IO_UNIT(a0),a0
	lea	TDU_PUBFLAGS(a0),a0
*	bclr	#TDPB_NOCLICK,(a0)	; Switch Off the clicking sound.
	bset	#TDPB_NOCLICK,(a0)	; Switch Off the clicking sound.

	move.l	tdio(pc),a1
	move.w	#TD_GETDRIVETYPE,IO_COMMAND(a1)
	bsr	disk_sendio
	tst.b	diskerr
	bne	exit_diskerror

	move.w	#160,d0
	move.w	#42,d1
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)

	move.l	disksts,d1
	cmp.l	#DRIVE3_5,d1
	beq.s	drivetype1
	cmp.l	#DRIVE5_25,d1
	beq.s	drivetype2
	cmp.l	#DRIVE3_5_150RPM,d1
	beq.s	drivetype3
	bra.s	drivetype_unknown

drivetype1
	lea	ddstg1(pc),a0
	bra.s	drivetype_end

drivetype2
	lea	ddstg2(pc),a0
	bra.s	drivetype_end

drivetype3
	lea	ddstg3(pc),a0
	bra.s	drivetype_end

drivetype_unknown
	lea	unknown(pc),a0

drivetype_end
	move.l	156(a4),a1
	moveq	#18,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#54,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)

	move.l	tdio(pc),a1
	move.w	#TD_MOTOR,IO_COMMAND(a1)
	move.l	#0,IO_LENGTH(a1)		; 0 = Off  1 = On
	bsr	disk_sendio
	tst.b	diskerr
	bne	exit_diskerror

	move.l	disksts,d1
	tst.l	d1
	beq.s	motor0
	cmp.l	#1,d1
	beq.s	motor1
	bra.s	motor_unknown

motor0	lea	yes(pc),a0
	bra.s	motor_end

motor1	lea	no(pc),a0
	bra.s	motor_end

motor_unknown
	lea	unknown(pc),a0

motor_end
	move.l	152(a4),a6
	move.l	156(a4),a1
	moveq	#3,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#66,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)

 * Disk Swaps. Divide the result by 2 as disk-in and disk-out count as two
 * swaps (one each).

	move.l	tdio(pc),a1
	move.w	#TD_CHANGENUM,IO_COMMAND(a1)
	bsr	disk_sendio
	move.l	disksts,swaps
	tst.b	diskerr
	bne	exit_diskerror

	move.l	swaps,d1
	bsr	convert_number
	lea	166(a4),a0
	move.l	152(a4),a6
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#78,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)

	move.l	tdio(pc),a1
	move.w	#TD_CHANGESTATE,IO_COMMAND(a1)
	bsr	disk_sendio
	tst.b	diskerr
	bne	exit_diskerror
	move.l	disksts,drivests
	tst.l	drivests
	bne	driveempty_message

	lea	destg0(pc),a0
	move.l	152(a4),a6
	move.l	156(a4),a1
	moveq	#12,d0
	jsr	_LVOText(a6)

 * Important Note:
 *
 * You must check against the Drive being empty, even if you are only going
 * to use the empty drive status (drivests) as a value to print on the
 * screen for example. In other words. If you do not quit this routine upon
 * an empty drive status then you must check against 'drivests' otherwise
 * you might get a crash with the next command/s!

	moveq	#dg_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,geoptr		
	beq	cl_tdev

	move.l	tdio(pc),a1
	move.w	#TD_GETGEOMETRY,IO_COMMAND(a1)
	move.l	geoptr(pc),a0
	move.l	a0,IO_DATA(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
        tst.l	d0
        bne	fr_geo

	move.b	#0,diskerr

	move.l	152(a4),a6
	move.w	#160,d0
	move.w	#90,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	geoptr(pc),a0
	move.l	(a0),d1			; Sector Size
	move.l	d1,sectorsize
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#102,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	geoptr(pc),a0
	addq.l	#4,a0
	move.l	(a0),d1			; Total Number Of Sectors
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#114,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	geoptr(pc),a0
	addq.l	#8,a0
	move.l	(a0),d1
	move.l	d1,cylinders
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#126,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	geoptr(pc),a0
	lea	12(a0),a0
	move.l	(a0),d1			; Number Of CylSectors
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#138,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	geoptr(pc),a0
	lea	16(a0),a0
	move.l	(a0),d1			; Number Of Heads/Surfaces
	move.l	d1,heads
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#150,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	geoptr(pc),a0
	lea	20(a0),a0
	move.l	(a0),d1			; Number Of Tracks
	move.l	d1,tracksectors
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#162,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	geoptr(pc),a0
	lea	24(a0),a0
	move.l	(a0),d2			; Buffer Memory Type
	cmp.l	#MEMF_ANY,d2
	beq.s	bufmemtype0
	cmp.l	#MEMF_PUBLIC,d2
	beq.s	bufmemtype1
	cmp.l	#MEMF_CHIP,d2
	beq.s	bufmemtype2
	cmp.l	#MEMF_FAST,d2
	beq.s	bufmemtype3
	cmp.l	#MEMF_LOCAL,d2
	beq.s	bufmemtype4
	cmp.l	#MEMF_24BITDMA,d2
	beq.s	bufmemtype5
	cmp.l	#MEMF_KICK,d2
	beq.s	bufmemtype6
	bra.s	bufmemtype_unknown

bufmemtype0
	lea	bmtstg0(pc),a0
	bra.s	bufmemtype_end

bufmemtype1
	lea	bmtstg1(pc),a0
	bra.s	bufmemtype_end

bufmemtype2
	lea	bmtstg2(pc),a0
	bra.s	bufmemtype_end

bufmemtype3
	lea	bmtstg3(pc),a0
	bra.s	bufmemtype_end

bufmemtype4
	lea	bmtstg4(pc),a0
	bra.s	bufmemtype_end

bufmemtype5
	lea	bmtstg5(pc),a0
	bra.s	bufmemtype_end

bufmemtype6
	lea	bmtstg6(pc),a0
	bra.s	bufmemtype_end

bufmemtype_unknown
	lea	unknown(pc),a0

bufmemtype_end
	move.l	156(a4),a1
	moveq	#8,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#174,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	geoptr(pc),a0
	lea	28(a0),a0
	moveq	#0,d2
	move.b	(a0),d2
	cmp.b	#DG_DIRECT_ACCESS,d2
	beq.s	devicetype0
	cmp.b	#DG_SEQUENTIAL_ACCESS,d2
	beq.s	devicetype1
	cmp.b	#DG_PRINTER,d2
	beq.s	devicetype2
	cmp.b	#DG_PROCESSOR,d2
	beq.s	devicetype3
	cmp.b	#DG_WORM,d2
	beq.s	devicetype4
	cmp.b	#DG_CDROM,d2
	beq.s	devicetype5
	cmp.b	#DG_SCANNER,d2
	beq.s	devicetype6
	cmp.b	#DG_OPTICAL_DISK,d2
	beq.s	devicetype7
	cmp.b	#DG_MEDIUM_CHANGER,d2
	beq.s	devicetype8
	cmp.b	#DG_COMMUNICATION,d2
	beq.s	devicetype9
	bra.s	devicetype_unknown

devicetype0
	lea	dtstg0(pc),a0
	bra.s	devicetype_end

devicetype1
	lea	dtstg1(pc),a0
	bra.s	devicetype_end

devicetype2
	lea	dtstg2(pc),a0
	bra.s	devicetype_end

devicetype3
	lea	dtstg3(pc),a0
	bra.s	devicetype_end

devicetype4
	lea	dtstg4(pc),a0
	bra.s	devicetype_end

devicetype5
	lea	dtstg5(pc),a0
	bra.s	devicetype_end

devicetype6
	lea	dtstg6(pc),a0
	bra.s	devicetype_end

devicetype7
	lea	dtstg7(pc),a0
	bra.s	devicetype_end

devicetype8
	lea	dtstg8(pc),a0
	bra.s	devicetype_end

devicetype9
	lea	dtstg9(pc),a0
	bra.s	devicetype_end

devicetype_unknown
	lea	unknown(pc),a0

devicetype_end
	move.l	156(a4),a1
	moveq	#17,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#186,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	geoptr(pc),a0
	lea	29(a0),a0
	move.b	(a0),d3
	moveq	#0,d2
	move.b	d3,d2
	and.b	#1,d2
	cmp.b	#DGF_REMOVABLE,d2
	beq.s	deviceflag0
	bra.s	deviceflag_unknown

deviceflag0
	lea	drstg1(pc),a0
	bra.s	deviceflag_end

deviceflag_unknown
	lea	unknown(pc),a0

deviceflag_end
	move.l	156(a4),a1
	moveq	#13,d0
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#198,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	geoptr(pc),a0
	move.l	cylinders,d0
	move.l	heads,d1
	move.l	tracksectors,d2
	move.l	sectorsize,d3
	mulu	d0,d1				; Drive KB Format Capacity.
	mulu	d1,d2
	mulu	d2,d3
	divu	#1024,d3
	move.l	d3,d1
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)

fr_geo	move.l	geoptr(pc),a1
	moveq	#dg_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	move.w	#450,d0
	move.w	#54,d1
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	tst.l	drivests
	bne	driveempty_message
	move.l	tdio(pc),a1
	move.w	#TD_PROTSTATUS,IO_COMMAND(a1)
	bsr	disk_sendio
	tst.b	diskerr
	bne	exit_diskerror
	tst.l	disksts
	beq.s	disk_notprotected
	lea	yes(pc),a0
	bra.s	protected_end

disk_notprotected
	lea	no(pc),a0

protected_end
	move.l	156(a4),a1
	moveq	#3,d0
	move.l	152(a4),a6
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#210,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)

 * Move the drive heads to a certain sector. If this works it is an indication
 * that the drive is okay. 79 (Sector) should really be given a random number
 * so that each call to TD_SEEK is different, thus, the heads are moved to
 * different locations (a better indication that the drive is okay).

	move.l	tdio(pc),a1
	move.w	#TD_SEEK,IO_COMMAND(a1)
	move.l	#40448,IO_OFFSET(a1)		; 40448 = 79*512
	bsr	disk_sendio
	tst.b	diskerr
	bne	exit_diskerror
	lea	headstg(pc),a0
	move.l	156(a4),a1
	moveq	#7,d0
	move.l	152(a4),a6
	jsr	_LVOText(a6)
	move.w	#160,d0
	move.w	#222,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	tst.l	drivests
	bne.s	ejected_end
	move.l	tdio(pc),a1
	move.w	#TD_EJECT,IO_COMMAND(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
        tst.l	d0
        bne.s	not_ejected
	move.b	#0,diskerr
	lea	yes(pc),a0
	bra.s	ejected_end

not_ejected
	lea	no(pc),a0

ejected_end
	move.l	156(a4),a1
	moveq	#3,d0
	move.l	152(a4),a6
	jsr	_LVOText(a6)
	move.w	#450,d0
	move.w	#42,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)

	move.l	#fib_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,fibptr
	beq	exit_diskerror

	move.l	#df1,d1
	moveq	#SHARED_LOCK,d2
	move.l	4(a4),a6
	jsr	_LVOLock(a6)
	move.b	#100,diskerr
	move.l	d0,lockptr
	beq.s	fr_fib
	move.b	#0,diskerr
	move.l	lockptr(pc),d1
	move.l	fibptr(pc),d2
	jsr	_LVOExamine(a6)
	tst.l	d0
	beq.s	fr_fib
	move.l	fibptr(pc),a0
	addq.l	#8,a0
	bsr	findlen
	tst.l	d0
	beq.s	fr_fib
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOText(a6)

fr_fib	move.l	fibptr(pc),a1
	move.l	#fib_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	move.b	diskerr,d0
	cmp.b	#100,d0
	beq	window1loop			; Lock() failed

	moveq	#id_SIZEOF,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	jsr	_LVOAllocMem(a6)
	move.l	d0,dibptr		
	beq	fr_lock

	move.l	lockptr(pc),d1
	move.l	dibptr(pc),d2
	move.l	4(a4),a6
	jsr	_LVOInfo(a6)
	tst.l	d0
	beq	fr_dib

	move.l	152(a4),a6
	move.w	#450,d0
	move.w	#174,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	dibptr(pc),a0
	lea	24(a0),a0
	move.l	(a0),d1				; File System.
	cmp.l	#$444F5300,d1
	beq.s	dostype0
	cmp.l	#$444F5301,d1
	beq.s	dostype1
	cmp.l	#$444F5302,d1
	beq.s	dostype2
	cmp.l	#$444F5303,d1
	beq.s	dostype3
	cmp.l	#$444F5304,d1
	beq.s	dostype4
	cmp.l	#$444F5305,d1
	beq.s	dostype5
	bra.s	dostype_unknown

dostype0
	lea	dosstg0(pc),a0
	bra.s	dostype_end

dostype1
	lea	dosstg1(pc),a0
	bra.s	dostype_end

dostype2
	lea	dosstg2(pc),a0
	bra.s	dostype_end

dostype3
	lea	dosstg3(pc),a0
	bra.s	dostype_end

dostype4
	lea	dosstg4(pc),a0
	bra.s	dostype_end

dostype5
	lea	dosstg5(pc),a0
	bra.s	dostype_end

dostype_unknown
	lea	unknown(pc),a0
	move.l	156(a4),a1
	moveq	#17,d0
	jsr	_LVOText(a6)
	bra	fr_dib

dostype_end
	move.l	156(a4),a1
	moveq	#17,d0
	jsr	_LVOText(a6)
	move.w	#450,d0
	move.w	#66,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)

	move.l	dibptr(pc),a0
	move.l	(a0),d1
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#450,d0
	move.w	#78,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	dibptr(pc),a0
	addq.l	#4,a0
	move.l	(a0),d1			; Unit Number.
	bsr	convert_number
	lea	166(a4),a0
	move.l	152(a4),a6
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#450,d0
	move.w	#90,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	dibptr(pc),a0
	addq.l	#8,a0
	move.l	(a0),d1			; Disk State.
	cmp.l	#80,d1
	beq.s	diskstate0
	cmp.l	#81,d1
	beq.s	diskstate1
	cmp.l	#82,d1
	beq.s	diskstate2
	bra.s	diskstate_unknown

diskstate0
	lea	dsstg0(pc),a0
	bra.s	diskstate_end

diskstate1
	lea	dsstg1(pc),a0
	bra.s	diskstate_end

diskstate2
	lea	dsstg2(pc),a0
	bra.s	diskstate_end

diskstate_unknown
	lea	unknown(pc),a0

diskstate_end
	move.l	156(a4),a1
	moveq	#18,d0
	jsr	_LVOText(a6)
	move.w	#450,d0
	move.w	#102,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	dibptr(pc),a0
	lea	12(a0),a0
	move.l	(a0),d1			; Number Of Blocks.
	move.l	d1,d2
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#450,d0
	move.w	#114,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	dibptr(pc),a0
	lea	16(a0),a0
	move.l	(a0),d1			; Number Of Blocks Used.
	move.l	d1,d3
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#450,d0
	move.w	#126,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	dibptr(pc),a0
	lea	20(a0),a0
	move.l	(a0),d1			; Number Of Blocks Used.
	move.l	d1,d4
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#450,d0
	move.w	#138,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	d4,d5			; Move B.P.B into d5.
	mulu	d2,d5			; Multiply N.O.B by B.P.B.
	divu	#1024,d5		; Get the KB size.
	moveq	#0,d1
	move.w	d5,d1			; Get the KiloBytes of Capacity.
	move.l	dibptr(pc),a0
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#580,d0
	move.w	#138,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	swap	d5			; Get the Bytes remainder of Capacity.
	moveq	#0,d1
	move.w	d5,d1
	move.l	dibptr(pc),a0		
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#450,d0
	move.w	#150,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	d4,d5
	mulu	d3,d5			; Multiply N.O.B.U by B.P.B.
	divu	#1024,d5		; Get the KiloBytes of KB-Used.
	moveq	#0,d1
	move.w	d5,d1
	move.l	dibptr(pc),a0		
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#580,d0
	move.w	#150,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	swap	d5			; Get the Bytes remainder of KB-Used.
	moveq	#0,d1
	move.w	d5,d1
	move.l	dibptr(pc),a0		
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#450,d0
	move.w	#162,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	moveq	#0,d5
	move.l	d4,d5
	mulu	d2,d5			; Multiply N.O.B by B.P.B.
	divu	#1024,d5		; Get the KiloBytes of Capacity.
	mulu	d3,d4			; Multiply N.O.B.U by B.P.B.
	divu	#1024,d4		; Get the KiloBytes of KB-Used.
	moveq	#0,d1
	moveq	#0,d2
	move.w	d5,d1
	move.w	d4,d2
	sub.w	d2,d1			; Subtract KB-Used from Capacity.
	move.l	dibptr(pc),a0		
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#580,d0
	move.w	#162,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	swap	d5
	swap	d4
	moveq	#0,d1
	moveq	#0,d2
	move.w	d5,d1
	move.w	d4,d2
	cmp.l	d2,d1
	ble.s	ltoet
	sub.w	d2,d1			; Sub. KB-Used bytes from Capacity bytes.
	bra.s	ltoet_end

ltoet	sub.w	d1,d2			; Sub. Capacity bytes from KB-Used bytes.

ltoet_end

	move.l	dibptr(pc),a0
	bsr	convert_number
	lea	166(a4),a0
	move.l	156(a4),a1
	moveq	#5,d0
	jsr	_LVOText(a6)
	move.w	#450,d0
	move.w	#186,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	dibptr(pc),a0
	lea	32(a0),a0
	move.l	(a0),d1			; In-Use status.
	tst.l	d1
	beq.s	diskactive0
	lea	yes(pc),a0
	bra.s	diskactive_end

diskactive0
	lea	no(pc),a0

diskactive_end
	move.l	156(a4),a1
	moveq	#3,d0
	jsr	_LVOText(a6)

fr_dib	move.l	dibptr(pc),a1
	moveq	#id_SIZEOF,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

fr_lock	move.l	lockptr(pc),d1
	move.l	4(a4),a6
	jsr	_LVOUnLock(a6)

window1loop

 * I put a window loop here last time - too lazy this time!

exit_diskerror

	bra	cl_tdev

exit_diskio


cl_tdev	movea.l	tdio(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

cl_tdio	movea.l	tdio(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

cl_tdport
	movea.l	tdport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)

td_end	bra	floppy_done

driveempty_message
	move.w	#160,d0
	move.w	#78,d1
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	lea	destg(pc),a0
	moveq	#12,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)
	bra.s	exit_diskerror


 * Sub-Routines.

 * DO NOT USE THESE NEXT FOUR FUNCTIONS: format, read, write and update, as
 * I have not programmed them because I am at this time unsure of what the
 * data buffer should contain and how you actually get the commands to work!

format	moveq	#0,d2
	tst.l	drivests
	bne.s	fmt_end
fmt_l	move.l	tdio(pc),a1
	move.w	#TD_FORMAT,IO_COMMAND(a1)
	lea	one_track(pc),a0
	move.l	a0,IO_DATA(a1)
	move.l	d2,d1
	move.l	#5632,d0		; bytes per track
	mulu	d1,d0			; track number * bytes per track
	move.l	d0,IO_OFFSET(a1)
	move.l	#5632,IO_LENGTH(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
	move.l	tdio(pc),a1
	tst.b	IO_ERROR(a1)
	bne.s	fmt_end
	addq.l	#1,d2
	cmp.b	#79,d2
	ble.s	fmt_l
fmt_end	rts

read	moveq	#0,d2
	tst.l	drivests
	bne.s	read_e
read_l	move.l	tdio(pc),a1
	move.w	#CMD_READ,IO_COMMAND(a1)
	lea	one_track(pc),a0
	move.l	a0,IO_DATA(a1)
	move.l	d2,d1
	move.l	#5632,d0		; bytes per track
	mulu	d1,d0			; track number * bytes per track
	move.l	d0,IO_OFFSET(a1)
	move.l	#5632,IO_LENGTH(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
	move.l	tdio(pc),a1
	tst.b	IO_ERROR(a1)
	bne.s	read_e
	addq.l	#1,d2
	cmp.b	#79,d2
	ble.s	read_l
read_e	rts

write	moveq	#0,d2
	tst.l	drivests
	bne.s	write_e
write_l	move.l	tdio(pc),a1
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	lea	one_track(pc),a0
	move.l	a0,IO_DATA(a1)
	move.l	d2,d1
	move.l	#5632,d0		; bytes per track
	mulu	d1,d0			; track number * bytes per track
	move.l	d0,IO_OFFSET(a1)
	move.l	#5632,IO_LENGTH(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
	move.l	tdio(pc),a1
	tst.b	IO_ERROR(a1)
	bne.s	write_e
	addq.l	#1,d2
	cmp.b	#79,d2
	ble.s	write_l
write_e	rts

update	tst.l	drivests
	bne.s	ud_end
	move.l	tdio(pc),a1
	move.w	#CMD_UPDATE,IO_COMMAND(a1)
	clr.b	IO_FLAGS(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
	move.l	tdio(pc),a1
	tst.b	IO_ERROR(a1)
	bne.s	ud_end
	nop
ud_end	rts

disk_sendio
	move.l	4.w,a6
	jsr	_LVOSendIO(a6)
	move.l	tdio(pc),a1
	jsr	_LVOWaitIO(a6)
        tst.l	d0
        bne	exit_diskio
	move.l	tdio(pc),a0
        move.b	IO_ERROR(a0),diskerr
	move.l	IO_ACTUAL(a0),disksts
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


 * Structures/Definitions.

topaz9C
	dc.l	font_name
	dc.w	9
	dc.b	FSF_BOLD,FPF_ROMFONT

topaz8C
	dc.l	font_name
	dc.w	8
	dc.b	FSF_BOLD,FPF_ROMFONT

ddtitle
	dc.b	1,0,0,0
	dc.w	0,0
	dc.l	topaz9C,ddtext,0

ddtext
	dc.b	'DRIVE/DEVICE Information         DISK Information',0
	even

wit1
	dc.b	3,0,0,0
	dc.w	0,0
	dc.l	topaz8C,wit1text,wit2

wit1text
	dc.b	'     Drive Type:',0
	even

wit2
	dc.b	3,0,0,0
	dc.w	0,12
	dc.l	topaz8C,wit2text,wit3

wit2text
	dc.b	'     Motor OFF?:',0
	even

wit3
	dc.b	3,0,0,0
	dc.w	0,24
	dc.l	topaz8C,wit3text,wit4

wit3text
	dc.b	'     Disk Swaps:',0
	even

wit4
	dc.b	3,0,0,0
	dc.w	0,36
	dc.l	topaz8C,wit4text,wit5

wit4text
	dc.b	'   Drive Empty?:',0
	even

wit5
	dc.b	3,0,0,0
	dc.w	0,48
	dc.l	topaz8C,wit5text,wit6

wit5text
	dc.b	'    Sector Size:',0
	even

wit6
	dc.b	3,0,0,0
	dc.w	0,60
	dc.l	topaz8C,wit6text,wit7

wit6text
	dc.b	'   Sector Total:',0
	even

wit7
	dc.b	3,0,0,0
	dc.w	0,72
	dc.l	topaz8C,wit7text,wit8

wit7text
	dc.b	'      Cylinders:',0
	even

wit8
	dc.b	3,0,0,0
	dc.w	0,84
	dc.l	topaz8C,wit8text,wit9

wit8text
	dc.b	'        Sectors:',0
	even

wit9
	dc.b	3,0,0,0
	dc.w	0,96
	dc.l	topaz8C,wit9text,wit10

wit9text
	dc.b	' Surfaces/Heads:',0
	even

wit10
	dc.b	3,0,0,0
	dc.w	0,108
	dc.l	topaz8C,wit10text,wit11

wit10text
	dc.b	'         Tracks:',0
	even

wit11
	dc.b	3,0,0,0
	dc.w	0,120
	dc.l	topaz8C,wit11text,wit12

wit11text
	dc.b	'  Buffer Memory:',0
	even

wit12
	dc.b	3,0,0,0
	dc.w	0,132
	dc.l	topaz8C,wit12text,wit13

wit12text
	dc.b	'    Device Type:',0
	even

wit13
	dc.b	3,0,0,0
	dc.w	0,144
	dc.l	topaz8C,wit13text,wit14

wit13text
	dc.b	'          Flags:',0
	even

wit14
	dc.b	3,0,0,0
	dc.w	0,156
	dc.l	topaz8C,wit14text,wit15

wit14text
	dc.b	' Format KB-Size:',0
	even

wit15
	dc.b	3,0,0,0
	dc.w	0,168
	dc.l	topaz8C,wit15text,wit16

wit15text
	dc.b	'    Drive Heads:',0
	even

wit16
	dc.b	3,0,0,0
	dc.w	0,180
	dc.l	topaz8C,wit16text,0

wit16text
	dc.b	'Disk Ejectable?:',0
	even

wit17
	dc.b	3,0,0,0
	dc.w	0,0
	dc.l	topaz8C,wit17text,wit18

wit17text
	dc.b	'       Name:',0
	even

wit18
	dc.b	3,0,0,0
	dc.w	0,12
	dc.l	topaz8C,wit18text,wit19

wit18text
	dc.b	' Protected?:',0
	even

wit19
	dc.b	3,0,0,0
	dc.w	0,24
	dc.l	topaz8C,wit19text,wit20

wit19text
	dc.b	' S/W Errors:',0
	even

wit20
	dc.b	3,0,0,0
	dc.w	0,36
	dc.l	topaz8C,wit20text,wit21

wit20text
	dc.b	'Mounted On?:',0
	even

wit21
	dc.b	3,0,0,0
	dc.w	0,48
	dc.l	topaz8C,wit21text,wit22

wit21text
	dc.b	'Disk Status:',0
	even

wit22
	dc.b	3,0,0,0
	dc.w	0,60
	dc.l	topaz8C,wit22text,wit23

wit22text
	dc.b	'     Blocks:',0
	even

wit23
	dc.b	3,0,0,0
	dc.w	0,72
	dc.l	topaz8C,wit23text,wit24

wit23text
	dc.b	'Blocks Used:',0
	even

wit24
	dc.b	3,0,0,0
	dc.w	0,84
	dc.l	topaz8C,wit24text,wit25

wit24text
	dc.b	' Block Size:',0
	even

wit25
	dc.b	3,0,0,0
	dc.w	0,96
	dc.l	topaz8C,wit25text,wit26

wit25text
	dc.b	'Capacity KB:           Bytes:',0
	even

wit26
	dc.b	3,0,0,0
	dc.w	0,108
	dc.l	topaz8C,wit26text,wit27

wit26text
	dc.b	'    Used KB:           Bytes:',0
	even

wit27
	dc.b	3,0,0,0
	dc.w	0,120
	dc.l	topaz8C,wit27text,wit28

wit27text
	dc.b	'    Free KB:           Bytes:',0
	even

wit28
	dc.b	3,0,0,0
	dc.w	0,132
	dc.l	topaz8C,wit28text,wit29

wit28text
	dc.b	'File System:',0
	even

wit29
	dc.b	3,0,0,0
	dc.w	0,144
	dc.l	topaz8C,wit29text,0

wit29text
	dc.b	'    In Use?:',0
	even


topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

pens
	dc.l	-1

scrntags
	dc.l	SA_Top,0
	dc.l	SA_Left,0
	dc.l	SA_Width,640
	dc.l	SA_Height,256
	dc.l	SA_Depth,2
	dc.l	SA_Pens,pens
	dc.l	SA_DetailPen,0
	dc.l	SA_BlockPen,1
	dc.l	SA_Title,scrn_title
	dc.l	SA_DisplayID,$8000
	dc.l	SA_Type,CUSTOMSCREEN
	dc.l	SA_Font,topaz9
*	dc.l	SA_Quiet,TRUE
	dc.l	TAG_DONE

wndwtags
	dc.l	WA_Top,13
	dc.l	WA_Left,0
	dc.l	WA_Width,640
	dc.l	WA_Height,242
	dc.l	WA_IDCMP,0
	dc.l	WA_Activate,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_SmartRefresh,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_RMBTrap,TRUE
	dc.l	WA_CustomScreen
wndwscrn
	dc.l	0
	dc.l	TAG_DONE


 * Long Variables.

tdport		dc.l	0
tdio		dc.l	0
disksts		dc.l	0
swaps		dc.l	0
drivests	dc.l	0
geoptr		dc.l	0
fibptr		dc.l	0
dibptr		dc.l	0
lockptr		dc.l	0
diskkbsize	dc.l	0
diskkbused	dc.l	0
diskkbfree	dc.l	0
sectorsize	dc.l	0
totalsectors	dc.l	0
cylinders	dc.l	0
cylsectors	dc.l	0
heads		dc.l	0
tracksectors	dc.l	0
bufmemtype	dc.l	0
nob		dc.l	0
nobu		dc.l	0
bpb		dc.l	0


 * Byte Variables.

devicetype	dc.b	0
deviceflags	dc.b	0
diskerr		dc.b	0


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
dfont_name	dc.b	'diskfont.library',0,0
mtstg0		dc.b	'ARG_ONE',0
mtstg1		dc.b	'ARG_TWO',0
mtstg2		dc.b	'ARG_THREE',0
mtstg3		dc.b	'ARG_FOUR',0,0
mtstg4		dc.b	'ARG_FIVE',0,0
mtstg5		dc.b	'ARG_SIX',0
ftstg0          dc.b    'TOOLTYPE_ONE',0,0
ftstg1          dc.b    'TOOLTYPE_TWO',0,0
template	dc.b	'KEYWORD_ONE/K,KEYWORD_TWO/K',0
font_name	dc.b	'topaz.font',0,0
scrn_title	dc.b	'Disk_Drive.s',0,0
td_name		dc.b	'trackdisk.device',0,0
df0		dc.b	'DF0:',0,0
df1		dc.b	'DF1:',0,0
df2		dc.b	'DF2:',0,0
df3		dc.b	'DF3:',0,0
ddstg1		dc.b	'3½ Inches - Floppy',0,0
ddstg2		dc.b	'5½ Inches - Floppy',0,0
ddstg3		dc.b	'3½ 150RPM - Hard? ',0,0
ddstg		dc.b	'Not Known         ',0,0
destg0		dc.b	'Disk Present',0,0
destg		dc.b	'Disk Absent ',0,0
dtstg0		dc.b	'Direct Access    ',0
dtstg1		dc.b	'Sequential Access',0
dtstg2		dc.b	'Printer          ',0
dtstg3		dc.b	'Processor        ',0
dtstg4		dc.b	'Worm             ',0
dtstg5		dc.b	'CDRom            ',0
dtstg6		dc.b	'Scanner          ',0
dtstg7		dc.b	'Optical Disk     ',0
dtstg8		dc.b	'Medium Changer   ',0
dtstg9		dc.b	'Communication    ',0
drstg1		dc.b	'Removable    ',0
drstg		dc.b	'Not Removable',0
headstg		dc.b	'Seem OK',0
dosstg0		dc.b	'OFS              ',0
dosstg1		dc.b	'FFS              ',0
dosstg2		dc.b	'INTERNATIONAL OFS',0
dosstg3		dc.b	'INTERNATIONAL FFS',0
dosstg4		dc.b	'FASTDIR OFS      ',0
dosstg5		dc.b	'FASTDIR FFS      ',0
dosstg6		dc.b	'KICKSTART        ',0
dosstg7		dc.b	'MS-DOS           ',0
dosstg8		dc.b	'UNREADABLE       ',0
dosstg9		dc.b	'NDOS             ',0
dosstg10	dc.b	'NO DISK          ',0
dsstg0		dc.b	'Readable Only     ',0,0
dsstg1		dc.b	'Validating        ',0,0
dsstg2		dc.b	'Writeable/Readable',0,0
bmtstg0		dc.b	'Any     ',0,0
bmtstg1		dc.b	'Public  ',0,0
bmtstg2		dc.b	'Chip    ',0,0
bmtstg3		dc.b	'Fast    ',0,0
bmtstg4		dc.b	'Local   ',0,0
bmtstg5		dc.b	'24BitDMA',0,0
bmtstg6		dc.b	'Kick    ',0,0
unknown		dc.b	'Unknown             ',0,0
yes		dc.b	'Yes',0
no		dc.b	'No ',0


 * Buffer Variables.

membuf		dcb.b	300,0
one_track	dcb.b	5632,0	; NUMSECS(11)*TD_SECTOR(512)=BytesPerTrack.


	SECTION	VERSION,DATA

	dc.b	'$VER: Disk_Drive.s V1.01 (22.4.2001)',0


	END
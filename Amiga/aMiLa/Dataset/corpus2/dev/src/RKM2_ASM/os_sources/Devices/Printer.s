
 * This code shows how to determine the state of the printer (off/online,
 * paper in/out and busy/not busy) and allows basic printing of text via
 * the following keys:
 *
 * a = Reset the printer
 * b = Printer.Device print
 * c = Parallel.Device print
 *
 * This code was tested on my old Epson RX80 parallel printer (still Alive!).

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
	INCLUDE	devices/parallel.i
	INCLUDE	devices/printer.i
	INCLUDE	devices/prtbase.i
	INCLUDE	devices/prtgfx.i

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
 * 204 screen
 * 208 colourmap
 * 212 printer status
 * 216 userport
 * 220

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
	beq	cl_icon

	suba.l	a0,a0
	lea	wndwtags(pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,178(a4)
	beq	cl_scrn

	move.l	178(a4),a0
	move.l	wd_RPort(a0),156(a4)
	move.l	wndwscrn(pc),a0
	lea	sc_RastPort(a0),a1
	move.l	a1,184(a4)
	lea	sc_ViewPort(a0),a0
	move.l	a0,160(a4)

msg_l	move.l	178(a4),a0
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
	beq	which_vanillakey

	cmp.l	#IDCMP_CLOSEWINDOW,188(a4)
	beq.s	cl_wndw

	bra.s	msg_l


cl_wndw	move.l	178(a4),a0
	move.l	8(a4),a6
	jsr	_LVOCloseWindow(a6)

cl_scrn	move.l	wndwscrn(pc),a0
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

which_vanillakey
	move.w	192(a4),d0
	cmp.w	#$61,d0
	beq.s	setcmd_printer
	cmp.w	#$62,d0
	beq	prtext_printer
	cmp.w	#$63,d0
	beq	parallel_printer
	bra	msg_l


 * Sub-Routines.

setcmd_printer
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,prtport
	beq	no_prt
	move.l	d0,a0
	moveq.l	#iopcr_SIZEOF,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,prtio
	beq	cl_prtport
	move.l	d0,a1
	move.l	#PARF_SHARED,IO_FLAGS(a1)
	lea	prt_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	cl_prtio

 * This next code just cancels any printer commands (commands sequences) I
 * used inside my prtbuf text. You should cancel/change your settings, as
 * need be, if your next text to be printed is raw text (as opposed to a
 * text buffer/string with command sequences inside it).

	move.l	prtio(pc),a1
	move.w	#aRIS,io_PrtCommand(a1)		; RESET command.
	move.b	#27,io_Parm0(a1)		; Esc
	move.b	#99,io_Parm1(a1)		; Ascii c
	move.b	#0,io_Parm2(a1)
	move.b	#0,io_Parm3(a1)
	move.w	#PRD_PRTCOMMAND,IO_COMMAND(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)

	move.l	prtio(pc),a1
	move.w	#aSGR0,io_PrtCommand(a1)	; NORMAL Character Set
	move.b	#27,io_Parm0(a1)		; Esc
	move.b	#91,io_Parm1(a1)		; [
	move.b	#48,io_Parm2(a1)		; Ascii 0
	move.b	#109,io_Parm3(a1)		; Ascii m
	move.w	#PRD_PRTCOMMAND,IO_COMMAND(a1)
	jsr	_LVODoIO(a6)

 * Note: The above commands are needed by the following commands in order to
 *       work (on my Epson RX80 at least).

	move.l	prtio(pc),a1
	move.w	#aSGR3,io_PrtCommand(a1)	; ITALICS ON command.
	move.b	#27,io_Parm0(a1)		; Esc
	move.b	#91,io_Parm1(a1)		; [
	move.b	#51,io_Parm2(a1)		; Ascii 3
	move.b	#109,io_Parm3(a1)		; Ascii m
	move.w	#PRD_PRTCOMMAND,IO_COMMAND(a1)
	jsr	_LVODoIO(a6)

	move.l	prtio(pc),a1
	move.w	#aSGR4,io_PrtCommand(a1)	; BOLD ON command.
	move.b	#27,io_Parm0(a1)		; Esc
	move.b	#91,io_Parm1(a1)		; [
	move.b	#49,io_Parm2(a1)		; Ascii 1
	move.b	#109,io_Parm3(a1)		; Ascii m
	move.w	#PRD_PRTCOMMAND,IO_COMMAND(a1)
	jsr	_LVODoIO(a6)

	bra.s	cl_prtdev

prt_error
	nop

cl_prtdev
	movea.l	prtio(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

cl_prtio
	movea.l	prtio(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

cl_prtport
	movea.l	prtport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bra.s	prt_end
no_prt
	nop
prt_end	bra	msg_l

prt_sendio
	move.l	a3,a1
	move.l	4.w,a6
	jsr	_LVOSendIO(a6)
	move.l	a3,a1
	jsr	_LVOWaitIO(a6)
        tst.l	d0
        beq.s	psio_e
	move.b	IO_ERROR(a3),prterr
psio_e	rts

prt_doio
	move.l	a3,a1
	move.l	4.w,a6
	jsr	_LVODoIO(a6)
        tst.l	d0
        bne.s	pdio_e
	clr.b	prterr
	move.l	IO_ACTUAL(a3),216(a4)
pdio_e	rts

prtext_printer
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,prtextport
	beq	no_prtext
	move.l	d0,a0
	moveq.l	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,prtextio
	beq	cl_prtextport
	move.l	d0,a1
	move.l	#PARF_SHARED,IO_FLAGS(a1)
	lea	prt_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	cl_prtextio

	move.l	prtextio(pc),a3
	move.w	#PRD_QUERY,IO_COMMAND(a3)
	lea	212(a4),a0
	move.l	a0,IO_DATA(a3)
	bsr.s	prt_doio
	lea	212(a4),a0
	tst.l	(a0)
	beq	printer_end
	move.l	216(a4),d0
	cmp	#1,d0			; Is it the Parallel Port?
	beq.s	userport1		; Yes.
	cmp	#2,d0			; No. Is it the Serial Port?
	beq	userport2		; Yes.
	bra	userport_unknown	; No. So exit - Port unknown.

userport1
	move.w	#16,d0
	move.w	#26,d1
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	lea	212(a4),a0
	move.l	(a0),d3
	clr.w	d3			; Clear serial data.
	swap	d3			; Put prt status data into low word.
	btst	#8,d3
	bne	prt_offline
	move.l	#on_line,a0
	moveq	#11,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)
	move.w	#16,d0
	move.w	#36,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	btst	#9,d3
	bne.s	prt_paperout
	move.l	#paper_in,a0
	moveq	#11,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)
	btst	#10,d3
	beq.s	prt_busy
	move.w	#16,d0
	move.w	#46,d1
	move.l	156(a4),a1
	jsr	_LVOMove(a6)
	move.l	#not_busy,a0
	moveq	#11,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)
	bra.s	userport_end

userport2

 * Serial Printer status.

	bra.s	userport_end

userport_unknown
	nop

userport_end

	move.l	prtextio(pc),a3
	move.l	#prtbuf,IO_DATA(a3)
	move.l	#prtlen,IO_LENGTH(a3)
	move.w	#CMD_WRITE,IO_COMMAND(a3)
	bsr	prt_sendio
	tst.b	prterr
	bne.s	prtext_error
	bra.s	printer_end

prt_offline
	move.l	#off_line,a0
	moveq	#11,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)
	bra.s	printer_end

prt_paperout
	move.l	#paper_out,a0
	moveq	#11,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)
	bra.s	printer_end

prt_busy
	move.l	#busy,a0
	moveq	#11,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)

printer_end
	nop
	bra.s	cl_prtextdev

prtext_error
	nop

cl_prtextdev
	movea.l	prtextio(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

cl_prtextio
	movea.l	prtextio(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

cl_prtextport
	movea.l	prtextport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bra.s	prtext_end
no_prtext
	nop
prtext_end
	bra	msg_l

parallel_printer
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,parport
	beq	no_par
	move.l	d0,a0
	moveq.l	#IOEXTPar_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,pario
	beq	cl_parport
	move.l	d0,a1
	move.l	#PARF_SHARED,IO_FLAGS(a1)
	lea	par_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	cl_pario

	move.l	pario(pc),a1
	move.w	#PDCMD_QUERY,IO_COMMAND(a1)
	jsr	_LVOSendIO(a6)
	move.l	pario(pc),a1
	move.b	IO_PARSTATUS(a1),parsts
	jsr	_LVOWaitIO(a6)
        tst.l	d0
        bne	par_error

	moveq	#0,d3
	move.b	parsts,d3
	btst	#0,d3
	bne.s	par_offline
	btst	#1,d3
	bne.s	par_paperout
	btst	#2,d3
	beq.s	par_busy

	move.l	pario(pc),a1
	move.l	#parbuf,IO_DATA(a1)
	move.l	#parlen,IO_LENGTH(a1)
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	jsr	_LVOSendIO(a6)
	move.l	pario(pc),a1
	jsr	_LVOWaitIO(a6)
        tst.l	d0
        bne.s	par_error
	bra.s	cl_pardev

par_offline
	move.w	#16,d0
	move.w	#26,d1
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	move.l	#off_line,a0
	moveq	#11,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)
	bra.s	cl_pardev

par_paperout
	move.w	#16,d0
	move.w	#36,d1
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	move.l	#paper_out,a0
	moveq	#11,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)
	bra.s	cl_pardev

par_busy
	move.w	#16,d0
	move.w	#46,d1
	move.l	156(a4),a1
	move.l	152(a4),a6
	jsr	_LVOMove(a6)
	move.l	#busy,a0
	moveq	#11,d0
	move.l	156(a4),a1
	jsr	_LVOText(a6)
	bra.s	cl_pardev

par_error
	nop

cl_pardev
	movea.l	pario(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

cl_pario
	movea.l	pario(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteIORequest(a6)

cl_parport
	movea.l	parport(pc),a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)
	bra.s	par_end
no_par
	nop
par_end	bra	msg_l

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
	dc.l	TAG_DONE

wndwtags
	dc.l	WA_Top,13
	dc.l	WA_Left,0
	dc.l	WA_Width,640
	dc.l	WA_Height,242
	dc.l	WA_IDCMP,IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_CLOSEWINDOW
	dc.l	WA_Activate,TRUE
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_SmartRefresh,TRUE
	dc.l	WA_CloseGadget,TRUE
	dc.l	WA_RMBTrap,TRUE
	dc.l	WA_CustomScreen
wndwscrn
	dc.l	0
	dc.l	TAG_DONE


 * Long Variables.

parport		dc.l	0
pario		dc.l	0
prtport		dc.l	0
prtio		dc.l	0
prtextport	dc.l	0
prtextio	dc.l	0


 * Word Variables.

prtcommand	dc.w	0


 * Byte Variables.

param0	dc.b	0
param1	dc.b	0
param2	dc.b	0
param3	dc.b	0
parsts	dc.b	0
prterr	dc.b	0


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
par_name	dc.b	'parallel.device',0
prt_name	dc.b	'printer.device',0,0
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
scrn_title	dc.b	'Printer.s',0
error		dc.b	'Error      ',0
on_line		dc.b	'On-Line    ',0
off_line	dc.b	'Not On-Line',0
paper_in	dc.b	'Paper In   ',0
paper_out	dc.b	'Paper Out  ',0
not_busy	dc.b	'Not Busy   ',0
busy		dc.b	'Busy       ',0

parbuf
	dc.b	10,'Hello Parallel.Device!!',10
	dc.b	'Are you still working?!',10
	even
parlen	equ	*-parbuf

prtbuf
	dc.b	10,27,'c',27,'[1m',27,'[6wHello Printer.Device!!',10
	dc.b	10,'Are you being Bold, Large or both?!',10
	even
prtlen	equ	*-prtbuf


 * Buffer Variables.

membuf		dcb.b	300,0


	SECTION	VERSION,DATA

	dc.b	'$VER: Printer.s V1.01 (22.4.2001)',0


	END
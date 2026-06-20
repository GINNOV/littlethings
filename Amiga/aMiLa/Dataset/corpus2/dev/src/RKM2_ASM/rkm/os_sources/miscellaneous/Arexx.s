
 * This code shows how to set-up an Arexx Port and communicate with REXX
 * via strings (CreateArgstring).
 *
 * Notes: Do NOT use a DeleteArgstring() in this specific code as the
 *        string/s created with CreateArgstring() are deleted by REXX.
 *        Otherwise you will get a Guru 01000009 (exec: Memory Freed Twice)

	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE dos/dosextens.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	workbench/workbench.i
	INCLUDE rexx/rxslib.i
	INCLUDE rexx/storage.i

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
 * 156 Arexx Port (this port)
 * 160
 * 164
 * 165 Quit result
 * 166 Memory Buffer (12 bytes)
 * 178 _RexxSysBase
 * 182 value 1 (for ToolType/CLI result)
 * 183 value 2 (for ToolType/CLI result)
 * 184 Arexx Args
 * 188

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

        moveq	#36,d0
        lea     rsl_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,178(a4)
        beq     cl_gfx

        moveq	#LIB_VER,d0
        lea     icon_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,12(a4)
        beq     cl_rsl

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

 * Set-Up a Message Port.

	move.l	4.w,a6
        jsr	_LVOForbid(a6)
        lea     portname(pc),a1
        jsr	_LVOFindPort(a6)
        tst.l   d0
        bne.s	exists
        moveq   #MP_SIZE,d0
        move.l  #MEMF_PUBLIC!MEMF_CLEAR,d1
        jsr	_LVOAllocMem(a6)
        move.l  d0,156(a4)
        beq.s	no_pmem
        move.l  d0,a0
        clr.l	(a0)				; LN_SUCC(a0)
        clr.l	LN_PRED(a0)
        move.b  #NT_MSGPORT,LN_TYPE(a0)
        clr.b	LN_PRI(a0)
        lea     portname(pc),a1
        move.l  a1,LN_NAME(a0)
        move.b  #PA_SIGNAL,MP_FLAGS(a0)
        move.l  148(a4),MP_SIGTASK(a0)
        moveq	#-1,d0
        jsr	_LVOAllocSignal(a6)
        move.b  d0,d5
        cmp.l	#-1,d0
        bne.s	ad_port
        jsr	_LVOPermit(a6)
	bra	fr_pmem
ad_port	move.l	156(a4),a1
        move.b  d5,MP_SIGBIT(a1)
        jsr	_LVOAddPort(a6)
        jsr	_LVOPermit(a6)
	bra.s	do_sigbits

exists	jsr	_LVOPermit(a6)
        bra     cl_icon

no_pmem	jsr	_LVOPermit(a6)
        bra	cl_icon

do_sigbits
	moveq	#0,d6
	bset	d5,d6
	bset	#12,d6

waiting	clr.b	165(a4)
	move.l	d6,d0
	move.l	4.w,a6
	jsr	_LVOWait(a6)
	move.l	d0,d4
	move.l	156(a4),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,a3

	lea	rm_Args(a3),a0
	move.l	a0,184(a4)

	move.l	a3,a0
	move.l	178(a4),a6
	jsr	_LVOIsRexxMsg(a6)  ; This function checks for REXX string
	tst.l	d0
	beq.s	reply	           ; Reply if not an arexx message.

	move.l	184(a4),a0
	move.l	(a0),a0
	jsr	_LVOLengthArgstring(a6)
	tst.l	d0
	beq.s	cont0

	move.l	184(a4),a0
	move.l	(a0),a0
	lea	quit_stg,a1
	bsr	cmpbyte		; check if user wants to quit this program.
	tst.l	d0
	bne.s	cont0
	move.b	#1,165(a4)	; user wishes to quit this program.

cont0	clr.l	rm_Result1(a3)
	clr.l	rm_Result2(a3)

	move.l	rm_Action(a3),d2
	move.l	d2,d0
	and.l	#RXCOMM,d0		; Command
	cmp.l	#RXCOMM,d0
	bne.s	reply
	move.l	d2,d0
	and.l	#RXFF_RESULT,d0		; Is a Result String needed?
	cmp.l	#RXFF_RESULT,d0
	bne.s	reply

	lea	reply_stg(pc),a0
	moveq	#12,d0
	jsr	_LVOCreateArgstring(a6)
	move.l	d0,casptr
	beq.s	cas_error

	move.l	d0,rm_Result2(a3)

	bra.s	reply

cas_error
	nop

reply	move.l	a3,a1
	move.l	4.w,a6
	jsr	_LVOReplyMsg(a6)

	tst.b	165(a4)
	bne.s	quit_rexx
	bra	waiting

quit_rexx
	nop

fr_port	move.l	156(a4),a0
	tst.l	a0
        beq.s	cl_icon
	move.l	4.w,a6
        tst.b	MP_SIGBIT(a0)
        beq.s	no_sig
        jsr	_LVOFreeSignal(a6)
no_sig	move.l	156(a4),a1
        jsr	_LVORemPort(a6)
fr_pmem	move.l	156(a4),a1
        moveq   #MP_SIZE,d0
	move.l	4.w,a6
        jsr	_LVOFreeMem(a6)

cl_icon	move.l  12(a4),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_rsl	move.l  178(a4),a1
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


 * Long Variables.

casptr		dc.l	0


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
rsl_name	dc.b	'rexxsyslib.library',0,0
mtstg0		dc.b	'ARG_ONE',0
mtstg1		dc.b	'ARG_TWO',0
mtstg2		dc.b	'ARG_THREE',0
mtstg3		dc.b	'ARG_FOUR',0,0
mtstg4		dc.b	'ARG_FIVE',0,0
mtstg5		dc.b	'ARG_SIX',0
ftstg0          dc.b    'TOOLTYPE_ONE',0,0
ftstg1          dc.b    'TOOLTYPE_TWO',0,0
template	dc.b	'KEYWORD_ONE/K,KEYWORD_TWO/K',0
portname	dc.b	'JWAREXXPORT',0
reply_stg	dc.b	'Hello Arexx!',0,0
quit_stg	dc.b	'Goodbye',0


 * Buffer Variables.

membuf		dcb.b	300,0


	SECTION	VERSION,DATA

	dc.b	'$VER: Arexx.s V1.01 (22.4.2001)',0


	END
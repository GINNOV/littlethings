
 * This code shows you how you can use a trap (exception routine) of your
 * own to trap the divide-by-0 error. If you change the trap number to 6
 * for example you could use the exception routine to trap the CHK error.
 * Or you could change the exception routine or make one for each of your
 * traps.

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
 * 156 trap's counter value
 * 160
 * 164
 * 165
 * 166 Memory Buffer (12 bytes)
 * 178 old Trap Code pointer
 * 182 value 1 (for ToolType/CLI result)
 * 183 value 2 (for ToolType/CLI result)
 * 184

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

 * This code gets the address of this tasks TC_TRAPCODE, stores the address
 * inside the oldtrapcode variable before changing the TC_TRAPCODE address
 * to point to the custom exception routine. When this code divides by 0
 * it jumps to the custom exception routine instead of the amiga's routine
 * (usually a GURU!).Everything is restored afterwards. The custom exception
 * routine simply uses a counter to count off the exceptions. Your code
 * could set a flag and/or do something more specific to your needs.

	move.l	148(a4),a5
	move.l	TC_TRAPCODE(a5),178(a4)
	lea	div_trap(pc),a0
	move.l	a0,TC_TRAPCODE(a5)
	moveq	#1,d0
	divu	#0,d0

 * The CHK trap.

	lea	chk_trap(pc),a0
	move.l	a0,TC_TRAPCODE(a5)
	move.l	#255,d0
	chk	#169,d0

	suba.l	a0,a0
	move.l	8(a4),a6
	jsr	_LVODisplayBeep(a6)

	move.l	178(a4),TC_TRAPCODE(a5)


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

 * Trap Handler. Note: Below is using the SSP and not the USP. Trap handling
 * is done in supervisor mode.

div_trap:
	cmp.l	#5,(sp)		; top of SSP contains exception number.
	bne.s	not_divby0	; is it 5 (divide by zero) - no.
	addq.l	#1,156(a4)	; yes. so advance the counter.
end_div:
	addq.l	#4,sp		; move to the trap frame, which removes the
	rte			; exception number from the SSP.
not_divby0:
	tst.l	178(a4)		; is there another trap handler? 
	beq.s	end_div		; no. so exit.
	move.l	178(a4),-(sp)	; yes. so jump to the old trap.
	rts

chk_trap:
	cmp.l	#6,(sp)		; top of SSP contains exception number.
	bne.s	not_chk		; is it 6 (chk) - no.
	addq.l	#1,156(a4)	; yes. so advance the counter.
end_chk:
	addq.l	#4,sp		; move to the trap frame, which removes the
	rte			; exception number from the SSP.
not_chk:
	tst.l	178(a4)			; is there another trap handler? 
	beq.s	end_chk			; no. so exit.
	move.l	178(a4),-(sp)		; yes. so jump to the old trap.
	rts


 * String Variables.

int_name	dc.b	'intuition.library',0
dos_name	dc.b	'dos.library',0
icon_name       dc.b    'icon.library',0,0
gfx_name	dc.b	'graphics.library',0
mtstg0		dc.b	'ARG_ONE',0
mtstg1		dc.b	'ARG_TWO',0
mtstg2		dc.b	'ARG_THREE',0
mtstg3		dc.b	'ARG_FOUR',0,0
mtstg4		dc.b	'ARG_FIVE',0,0
mtstg5		dc.b	'ARG_SIX',0
ftstg0          dc.b    'TOOLTYPE_ONE',0,0
ftstg1          dc.b    'TOOLTYPE_TWO',0,0
template	dc.b	'KEYWORD_ONE/K,KEYWORD_TWO/K',0


 * Buffer Variables.

membuf		dcb.b	200,0


	SECTION	VERSION,DATA

	dc.b	'$VER: Trap_Exceptions.s V1.01 (22.4.2001)',0


	END
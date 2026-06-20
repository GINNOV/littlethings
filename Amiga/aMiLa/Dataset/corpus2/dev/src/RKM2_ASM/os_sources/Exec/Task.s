
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

LIB_VER		EQU	37
TRUE		EQU	-1
FALSE		EQU	0
STACK_SIZE	EQU	4000

	move.l	4.w,a6

	suba.l	a1,a1
	jsr	_LVOFindTask(a6)
	tst.l	d0
	beq	exit
	move.l	d0,a5
	tst.l	pr_CLI(a5)		; Was this task started from CLI?
	bne.s	_main			; Yes.
	lea	pr_MsgPort(a5),a0	; No. From Workbench.
	jsr	_LVOWaitPort(a6)
	lea	pr_MsgPort(a5),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,returnMsg		; D0 = A WBStartup Message.

_main
	move.l	4.w,a6

        moveq	#LIB_VER,d0
        lea     dos_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_DOSBase
        beq     quit

        moveq	#LIB_VER,d0
        lea     int_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_IntuitionBase
        beq     cl_dos

        moveq	#LIB_VER,d0
        lea     graf_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_GfxBase
        beq     cl_int

        moveq	#LIB_VER,d0
        lea     icon_name(pc),a1
        jsr	_LVOOpenLibrary(a6)
        move.l  d0,_IconBase
        beq.s	cl_gfx

	moveq	#TC_SIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	jsr	_LVOAllocMem(a6)
	move.l	d0,taskptr
	beq.s	cl_icon

	move.l	taskptr(pc),a1
	lea	task_name(pc),a0
	move.l	a0,LN_NAME(a1)
	move.b	#0,LN_PRI(a1)
	move.b	#NT_TASK,LN_TYPE(a1)
	lea	stack(pc),a0
	move.l	a0,TC_SPLOWER(a1)
	lea	STACK_SIZE(a0),a0
	move.l	a0,TC_SPUPPER(a1)
	move.l	TC_SPUPPER(a1),TC_SPREG(a1)
	lea	taskcode_start(pc),a2
*	lea	taskcode_end(pc),a3
	suba.l	a3,a3

	jsr	_LVOAddTask(a6)

	moveq	#100,d1
	move.l	_DOSBase(pc),a6
	jsr	_LVODelay(a6)


remove_task
	move.l	taskptr(pc),a1
	move.l	4.w,a6
	jsr	_LVORemTask(a6)

free_task
	move.l	taskptr(pc),a1
	moveq	#TC_SIZE,d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

cl_icon	move.l  _IconBase(pc),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_gfx	move.l  _GfxBase(pc),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_int	move.l  _IntuitionBase(pc),a1
	move.l	4.w,a6
        jsr	_LVOCloseLibrary(a6)

cl_dos	move.l  _DOSBase(pc),a1
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
cleanup	tst.l	returnMsg
	beq.s	exit			; Exit - Task was started from CLI.
	move.l	4.w,a6
	jsr	_LVOForbid(a6)
	move.l	returnMsg(pc),a1	; Reply to the WB Startup Message and
	jsr	_LVOReplyMsg(a6)	; Exit - Task was started from WB.
exit	moveq	#0,d0
	rts


 * Branch-To Routines.

taskcode_start
	suba.l	a0,a0
	move.l	_IntuitionBase(pc),a6
	jsr	_LVODisplayBeep(a6)
	rts
taskcode_end


 * Long Variables.

returnMsg	dc.l	0
_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
_IconBase       dc.l    0
taskptr		dc.l	0


 * String Variables.

dos_name	dc.b	'dos.library',0
int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0,0
icon_name       dc.b    'icon.library',0,0
task_name	dc.b	'JWTASK',0,0


 * Buffer Variables.

stack		dcb.b	STACK_SIZE


	SECTION	VERSION,DATA

	dc.b	'$VER: Task.s V1.01 (22.4.2001)',0


	END

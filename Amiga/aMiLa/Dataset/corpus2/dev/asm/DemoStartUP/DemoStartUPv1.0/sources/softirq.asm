; - [ SoftIRQ ] -

;///XDEF
	xdef	_SoftIRQ
	xdef	_StartSoftInt
	xdef    _StopSoftInt
	xdef	_si_micro
	xdef	_si_secs
	xdef	_si_func
;///
;///XREF
	xref	_DosBase
	xref	_IntuitionBase
	xref	_GfxBase
	xref	_CyberGfxBase

	xref	_screen
	xref	_thisTasksigf
	xref	_thisTask

	xref    _P61_Master
	xref	_nfsc
;///
;///Includes
        include	"basemacros.i"

	incdir	include:

	include	devices/timer.i

	include exec/interrupts.i
	include	exec/lists.i
	include	exec/execbase.i
	include exec/types.i
	include	exec/exec.i
	include exec/libraries.i
	include exec/io.i
	include exec/memory.i
	include exec/ports.i

	include utility/tagitem.i

	include	intuition/intuition.i

	include dos/dostags.i

	include	hardware/blit.i
	include	hardware/custom.i
        include hardware/dmabits.i
	include	hardware/intbits.i
	include hardware/rawkeys.i

	include	LVO/graphics_lib.i
	include	LVO/dos_lib.i
	include LVO/exec_lib.i
	include	LVO/intuition_lib.i
	include	LVO/cybergraphics_lib.i
	include	LVO/asl_lib.i

	include	libraries/asl.i
        include	libraries/dosextens.i

	include cybergraphx/cybergraphics.i

	include	graphics/view.i
;///

_SoftIRQ
	movem.l	d0-a6,-(sp)

        tst.b	_nfsc
        bne.s	.out
	
        move.l	_IntuitionBase,a0
	move.l  ib_FirstScreen(a0),a0
	move.l	_screen,a1
	cmp.l	a0,a1
	bne.s	.no

	move.l	_thisTask,a1
	move.l	_thisTasksigf,d0
	callExe	Signal

	move.w	#64,_P61_Master
        bra.s	.out
.no
	move.w	#16,_P61_Master


.out
	movem.l	(sp)+,d0-a6
	rts



_si_micro
si_micro	dc.l	0
_si_secs
si_secs		dc.l	1
_si_func
si_func		dc.l	0

_StartSoftInt:

	movem.l	d0-a6,-(sp)
	move.l	4.w,a6
	lea	_mp(pc),a0
	move.b	#PA_SOFTINT,MP_FLAGS(a0)
	lea	_si(pc),a2
	move.l	a2,MP_SOFTINT(a0)
	lea	MP_MSGLIST(a0),a1
	NEWLIST	a1

	lea	_softint_code_l1(pc),a1
	move.l  a1,IS_CODE(a2)

	lea	_tr(pc),a1
	move.l	a0,MN_REPLYPORT(a1)

	lea	TimerName(pc),a0
	move.l	#UNIT_MICROHZ,d0	;#UNIT_VBLANK,d0
	moveq	#0,d1
	call	OpenDevice
	tst.l	d0
	bne.s	.notimer
	move.w	#1,_enabled
	bsr	_softint_code_l1 ;start...

.notimer
	movem.l	(sp)+,d0-a6
	rts

_StopSoftInt
	movem.l	d0-a6,-(sp)
	move.w	#0,_enabled
	move.l	$4.w,a6
	tst.w	_active
	beq.s	.la1
	lea	_tr(pc),a1
	call	AbortIO
;.laa
;	 tst.w	 _active
;	 bne.s	 .laa ; !!!
.la1
	lea	_tr(pc),a1
	call	CloseDevice
	movem.l	(sp)+,d0-a6
	rts

_softint_code_l1:
	move.w	#0,_active
	tst.w	_enabled
	beq.s	.noten
	movem.l	d0-a6,-(sp)
	move.l	si_func(pc),d0
	beq.s	.na
	move.l	d0,a0
	jsr	(a0)
.na
	lea	_tr(pc),a0
	move.w  #TR_ADDREQUEST,IO_COMMAND(a0)
	lea	IOTV_TIME(a0),a0
	move.l	si_micro,TV_MICRO(a0)
	move.l	si_secs,TV_SECS(a0)
	move.l	4.w,a6
	lea	_tr(pc),a1
	call	SendIO
	move.w	#1,_active
	movem.l	(sp)+,d0-a6
.noten
	rts

_tr    dcb.b   IOTV_SIZE,0
_mp    dcb.b   MP_SIZE,0
_si    dcb.b   IS_SIZE,0
_enabled
	dc.w	0
_active
	dc.w	0

TimerName	dc.b	"timer.device",0


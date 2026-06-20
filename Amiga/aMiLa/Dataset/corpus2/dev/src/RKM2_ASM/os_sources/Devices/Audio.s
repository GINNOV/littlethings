
	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE devices/audio.i

	INCLUDE	misc/easystart.i

LIB_VER		EQU	39

	moveq	#LIB_VER,d0
	lea	int_name(pc),a1
	move.l	4.w,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IntuitionBase
	beq	exit_quit

	moveq	#LIB_VER,d0
	lea	graf_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GfxBase
	beq	exit_closeint

	moveq	#LIB_VER,d0
	lea	dos_name(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_DOSBase
	beq	exit_closegfx

	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,audport
	beq	exit_closedos
	move.l	d0,a0
	moveq	#ioa_SIZEOF,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,audreq
	beq	exit_audport
	move.l	d0,a1
	move.l	#masks,ioa_Data(a1)
	move.l	#4,ioa_Length(a1)
	move.w	#ADCMD_ALLOCATE,IO_COMMAND(a1)
	lea	aud_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	exit_audreq

	moveq	#0,d0
	lea	notes(pc),a0
	move.l	#254,d1

notes_l	move.w	d0,(a0)+
	addq.w	#1,d0
	dbra	d1,notes_l

	clr.w	510(a0)

	move.l	audreq(pc),a1
	move.b	#ADIOF_PERVOL,IO_FLAGS(a1)
	move.w	#64,ioa_Volume(a1)
	move.w	#7000,ioa_Period(a1)
	move.w	#1,ioa_Cycles(a1)
	lea	notes(pc),a0
	move.l	a0,ioa_Data(a1)
	move.l	#256,ioa_Length(a1)
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	bsr	beginio

	move.l	audreq(pc),a1
	move.b	#ADIOF_PERVOL,IO_FLAGS(a1)
	move.w	#7500,ioa_Period(a1)
	move.w	#2,ioa_Cycles(a1)
	bsr.s	beginio

	move.l	audreq(pc),a1
	move.b	#ADIOF_PERVOL,IO_FLAGS(a1)
	move.w	#9999,ioa_Period(a1)
	move.w	#1,ioa_Cycles(a1)
	bsr.s	beginio

	move.l	audreq(pc),a1
	move.b	#ADIOF_PERVOL,IO_FLAGS(a1)
	move.w	#3671,ioa_Period(a1)
	move.w	#2,ioa_Cycles(a1)
	bsr.s	beginio


close_audio
	move.l	audreq(pc),a1
	CALLEXEC	CloseDevice

exit_audreq
	move.l	audreq(pc),a0
	CALLEXEC	DeleteIORequest

exit_audport
	move.l	audport(pc),a0
	CALLEXEC	DeleteMsgPort

exit_closedos
	move.l	_DOSBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closegfx
	move.l	_GfxBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closeint
	move.l	_IntuitionBase(pc),a1
	CALLEXEC	CloseLibrary

exit_quit
	moveq	#0,d0
	rts


beginio

* Below is the BeginIO code. But here I will use execute's BEGINIO Macro,
* for non-assembly programmers, which is the same code as below.
*
*	move.l	a6,-(a7)
*	move.l	$14(a1),a6
*	jsr	-$1E(a6)
*	move.l	(a7)+,a6

	move.l	audreq(pc),a1
	BEGINIO
	move.l	audreq(pc),a1
	CALLEXEC	WaitIO
	tst.l	d0
	bne.s	error
	bra.s	bi_end
error	suba.l	a0,a0
	CALLINT	DisplayBeep
bi_end	rts


 * Long Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
audport		dc.l	0
audreq		dc.l	0

 * Byte Variables.

audioerr	dc.b	0
masks		dc.b	1,2,4,8
notes		dcb.b	512,0


 * String Variables.

int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0,0
dos_name	dc.b	'dos.library',0
aud_name	dc.b	'audio.device',0,0

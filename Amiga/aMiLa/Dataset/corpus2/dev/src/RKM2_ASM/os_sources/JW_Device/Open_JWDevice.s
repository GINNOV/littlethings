
	INCDIR	WORK:Include/

	INCLUDE intuition/intuition_lib.i
	INCLUDE exec/exec_lib.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE	misc/jw_device.i

	INCLUDE	misc/easystart.i

_LVOBeginIO	EQU	-30
*_LVOAbortIO	EQU	-36
_LVOFunctionA	EQU	-42
_LVOFunctionB	EQU	-48

	moveq	#37,d0
	lea	int_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit_quit

	moveq	#37,d0
	lea	graf_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_GfxBase
	beq	exit_closeint

	moveq	#37,d0
	lea	dos_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_DOSBase
	beq	exit_closegfx

 * Open a console window.

	move.l	#MODE_NEWFILE,d2
	move.l	#cname,d1
	CALLDOS	Open
	move.l	d0,cfh
	beq	exit_closedos

	CALLEXEC	CreateMsgPort
	tst.l	d0
	beq	exit_closeconfile
	move.l	d0,jwport
	move.l	d0,a0
	moveq	#IOSTD_SIZE,d0
	CALLEXEC	CreateIORequest
	tst.l	d0
	beq	exit_jwport
	move.l	d0,jwio
	move.l	d0,a1
	lea	gp_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	CALLEXEC	OpenDevice
	tst.l	d0
	bne.s	exit_jwio

	lea	bytebuf(pc),a4

	movea.l	jwio(pc),a1
	move.w	#JWD_GETDRIVETYPE,IO_COMMAND(a1)
	CALLEXEC	SendIO
	movea.l	jwio(pc),a1
	CALLEXEC	WaitIO	
        tst.l	d0
        bne.s	exit_error
	movea.l	jwio(pc),a1
	move.l	IO_ACTUAL(a1),d0
	move.b	d0,(a4)

	move.l	cfh,d1
	move.l	a4,d2
	moveq.l	#1,d3
	CALLDOS	Write
	move.l	cfh,d1
	moveq.l	#10,d2
	moveq.l	#1,d3
	CALLDOS	Write
	bra.s	exit_closedevice

exit_error
	suba.l	a0,a0
	CALLINT	DisplayBeep

exit_closedevice
	movea.l	jwio(pc),a1
	CALLEXEC	CloseDevice

exit_jwio
	movea.l	jwio(pc),a0
	CALLEXEC	DeleteIORequest

exit_jwport
	movea.l	jwport(pc),a0
	CALLEXEC	DeleteMsgPort

exit_closeconfile
	move.l	#200,d1
	CALLDOS	Delay
	move.l	cfh,d1
	CALLDOS	Close

exit_closedos
	movea.l	_DOSBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closegfx
	movea.l	_GfxBase(pc),a1
	CALLEXEC	CloseLibrary

exit_closeint
	movea.l	_IntuitionBase(pc),a1
	CALLEXEC	CloseLibrary

exit_quit
	moveq	#0,d0
	rts


 * Include Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0
dos_name	dc.b	'dos.library',0
gp_name		dc.b	'ramdev.device',0
	even


 * JW_Device Variables.

jwport		dc.l	0
jwio		dc.l	0
smpt		dcb.b	1,2


 * File Variables.

cfh		dc.l	0
cnode		dc.l	0
cname	dc.b	'CON:0/0/100/100/ Debug',0
	even


 * Misc Variables, etc.

bytebuf	dcb.b	12,0


	END


 * Here is a neat little routine from the input.device. It allows you to
 * change the position of the mouse pointer. Thus. You could check if the
 * mouse pointer is within the bounds of a window for example. If its not
 * simply call this routine to place it back inside the bounds of your
 * window. This would give you a `Limit Mouse' command like AMOS's Limit
 * Bob/Mouse commands.

	INCDIR	WORK:Include/

	INCLUDE intuition/intuition_lib.i
	INCLUDE exec/exec_lib.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE	devices/input_lib.i
	INCLUDE	devices/input.i
	INCLUDE	devices/inputevent.i

	INCLUDE	misc/easystart.i

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

	CALLEXEC	CreateMsgPort
	move.l	d0,mouseport
	beq	exit_closedos
	move.l	d0,a0
	moveq	#IOSTD_SIZE,d0
	CALLEXEC	CreateIORequest
	move.l	d0,mouseio
	beq	exit_mouseport
	move.l	d0,a1
	lea	ip_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	CALLEXEC	OpenDevice
	tst.l	d0
	bne	exit_mouseio

	movea.l	mouseio(pc),a0
	move.l	IO_DEVICE(a0),a0
	move.l	a0,_InputBase

	suba.l	a0,a0
	CALLINT	LockPubScreen
	tst.l	d0
	beq	exit_closedevice
	move.l	d0,a5

	suba.l	a0,a0
	move.l	a5,a1
	CALLINT	UnlockPubScreen

	lea	ieppbuf(pc),a4
	move.l	a5,(a4)					; iepp_Screen(a4)
	move.w	#10,iepp_PositionX(a4)
	move.w	#10,iepp_PositionY(a4)

	lea	iebuf(pc),a3
	move.l	a4,ie_EventAddress(a3)
	clr.l	(a3)					; ie_NextEvent(a3)
	move.b	#IECLASS_NEWPOINTERPOS,ie_Class(a3)
	move.b	#IESUBCLASS_PIXEL,ie_SubClass(a3)
	move.w	#IECODE_NOBUTTON,ie_Code(a3)
*	move.w	#IEQUALIFIER_RELATIVEMOUSE,ie_Qualifier(a3)
	clr.w	ie_Qualifier(a3)

	movea.l	mouseio(pc),a1
	move.w	#IND_WRITEEVENT,IO_COMMAND(a1)
	move.l	#iebuf,IO_DATA(a1)
	move.l	#ie_SIZEOF,IO_LENGTH(a1)
	CALLEXEC	DoIO

	moveq	#100,d1
	CALLDOS	Delay

	lea	ieptbuf(pc),a2
	move.l	a2,ie_EventAddress(a3)
	clr.l	(a3)					; ie_NextEvent(a3)
	move.b	#IECLASS_NEWPOINTERPOS,ie_Class(a3)
	move.b	#IESUBCLASS_TABLET,ie_SubClass(a3)
	move.w	#IECODE_NOBUTTON,ie_Code(a3)
	clr.w	ie_Qualifier(a3)
	move.w	#400,(a2)				; iept_RangeX(a2)
	move.w	#200,iept_RangeY(a2)
	move.w	#100,iept_ValueX(a2)
	move.w	#100,iept_ValueY(a2)

	movea.l	mouseio(pc),a1
	move.w	#IND_WRITEEVENT,IO_COMMAND(a1)
	move.l	#iebuf,IO_DATA(a1)
	move.l	#ie_SIZEOF,IO_LENGTH(a1)
	CALLEXEC	DoIO

 * Press the left_shift key down when this program runs and the screen will
 * flash. This means you pressed left_shift whilst the mouse was moving.
 * No flash means you did not press left_shift.

	CALLINPUT	PeekQualifier
	tst.l	d0
	beq.s	exit_closedevice
	cmpi.l	#IEQUALIFIER_LSHIFT,d0
	bne.s	exit_closedevice

	suba.l	a0,a0
	CALLINT	DisplayBeep

exit_closedevice
	movea.l	mouseio(pc),a1
	CALLEXEC	CloseDevice

exit_mouseio
	movea.l	mouseio(pc),a0
	CALLEXEC	DeleteIORequest

exit_mouseport
	movea.l	mouseport(pc),a0
	CALLEXEC	DeleteMsgPort

exit_message

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


 * Long Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
_InputBase	dc.l	0
mouseport	dc.l	0
mouseio		dc.l	0

 * String Variables.

int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0,0
dos_name	dc.b	'dos.library',0
ip_name		dc.b	'input.device',0,0


 * Buffer Variables.

iebuf		dcb.b	ie_SIZEOF,0
ieppbuf		dcb.b	IEPointerPixel_SIZEOF,0
ieptbuf		dcb.b	IEPointerTablet_SIZEOF,0
smpt		dcb.b	1,2

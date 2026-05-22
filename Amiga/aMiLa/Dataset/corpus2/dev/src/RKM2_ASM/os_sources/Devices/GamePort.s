
	INCDIR	WORK:Include/

	INCLUDE intuition/intuition_lib.i
	INCLUDE exec/exec_lib.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE	devices/gameport.i
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
	beq.s	exit_mouseport
	move.l	d0,a1
	lea	gp_name(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	CALLEXEC	OpenDevice
	tst.l	d0
	bne.s	exit_mouseio

 * I'm not really sure the exact purpose of SETTRIGGER? The RKM gives no
 * real definition as to its purpose, other than it reports events at
 * certain periods.

 * The below is for the mouse. X and Y deltas should be set to 1 for the
 * joystick.
 
	lea	trigger(pc),a2
	move.w	#GPTB_DOWNKEYS!GPTB_UPKEYS,(a2)		; gpt_Keys(a2)
	move.w	#1800,gpt_Timeout(a2)
	move.w	#10,gpt_XDelta(a2)
	move.w	#10,gpt_YDelta(a2)
	movea.l	mouseio(pc),a1
	move.w	#GPD_SETTRIGGER,IO_COMMAND(a1)
	move.l	a2,IO_DATA(a1)
	move.l	#gpt_SIZEOF,IO_LENGTH(a1)
	CALLEXEC	DoIO


 * To control the mouse with a Joystick put a value of 2 into smpt.

*	movea.l	mouseio(pc),a1
*	move.w	#GPD_SETCTYPE,IO_COMMAND(a1)
*	move.l	#smpt,IO_DATA(a1)
*	move.l	#1,IO_LENGTH(a1)
*	CALLEXEC	DoIO

*	movea.l	mouseio(pc),a1
*	cmpi.b	#GPDERR_SETCTYPE,IO_ERROR(a1)
*	beq	exit_closedevice


 * This checks what controller type is in the port. smpt stores the byte
 * result.

*	movea.l	mouseio(pc),a1
*	move.w	#GPD_ASKCTYPE,IO_COMMAND(a1)
*	move.l	#smpt,IO_DATA(a1)
*	move.l	#1,IO_LENGTH(a1)
*	CALLEXEC	DoIO


 * This reads a game port's inputevent into buffer. In this example I have
 * allocated a buffer to read one inputevent at a time (you can allocate
 * more buffer space if you want to).

*	movea.l	mouseio(pc),a1
*	move.w	#GPD_READEVENT,IO_COMMAND(a1)
*	move.l	#buffer,IO_DATA(a1)
*	move.l	#ie_SIZEOF,IO_LENGTH(a1)
*	CALLEXEC	DoIO

*	movea.l	mouseio(pc),a1
*	tst.b	IO_ERROR(a1)
*	bne	flash

*	move.l	#buffer,a3
*	move.b	ie_Class(a3),d0
*	cmp.b	#IECLASS_RAWMOUSE,d0
*	bne	exit_closeconfile

*	move.b	ie_SubClass(a3),d0
*	tst.b	d0
*	beq	mouse_port		; 1 joyport

*	move.w	ie_Code(a3),d0
*	cmp.w	#$00FF,d0
*	beq	no_report

*	move.w	ie_Qualifier(a3),d0
*	cmp.w	#IEQUALIFIER_RELATIVEMOUSE,d0
*	beq	rel_mouse


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
mouseport	dc.l	0
mouseio		dc.l	0


 * String Variables.

int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0,0
dos_name	dc.b	'dos.library',0
gp_name		dc.b	'gameport.device',0


 * Buffer Variables.

trigger		dcb.b	gpt_SIZEOF,0
buffer		dcb.b	ie_SIZEOF,0
smpt		dcb.b	1,2

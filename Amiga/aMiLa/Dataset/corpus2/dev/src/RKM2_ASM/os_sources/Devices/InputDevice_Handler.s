
	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	exec/interrupts.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE dos/dosextens.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	workbench/workbench.i
	INCLUDE	hardware/intbits.i
	INCLUDE	devices/input.i

	INCLUDE	misc/easystart.i

LIB_VER		EQU	37
MEM_TYPE	EQU	MEMF_CHIP!MEMF_CLEAR
FILE_SIZE	EQU	100
TRUE		EQU	-1
FALSE		EQU	0

	moveq	#LIB_VER,d0
	lea	int_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit_quit

	moveq	#LIB_VER,d0
	lea	graf_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_GfxBase
	beq	exit_closeint

	moveq	#LIB_VER,d0
	lea	dos_name(pc),a1
	CALLEXEC	OpenLibrary
	move.l	d0,_DOSBase
	beq	exit_closegfx

	suba.l	a1,a1
	jsr	_LVOFindTask(a6)
	tst.l	d0
	beq	exit_closedos
	move.l	d0,a5

	clr.l	d5
	moveq	#-1,d0
	jsr	_LVOAllocSignal(a6)
	move.b	d0,d5
	cmp.l	#-1,d0
	beq	exit_closedos

	move.l	d5,d0		; Signal Bit (a bit number between 0 and 31),
				; which was allocated by AllocSignal().
	clr.l	d6
	bset	d0,d6		; Set the `signal bit' of d6. So. If the
				; `signal bit' (inside d0) is 29 d6 will
				; have its 29th bit set. d6 is then known
				; as the `signal mask'.

	bset	#12,d6		; Set the SIGBREAKF_CTRL_C bit aswell.

	CALLEXEC	CreateMsgPort
	tst.l	d0
	beq	exit_freesignal
	move.l	d0,mouseport
	move.l	d0,a0
	moveq	#IOSTD_SIZE,d0
	CALLEXEC	CreateIORequest
	tst.l	d0
	beq	exit_mouseport
	move.l	d0,mouseio
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

	moveq	#IS_SIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,interrupt
	beq	exit_closedevice

	move.l	interrupt(pc),a0
	clr.l	(a0)					; LN_SUCC(a0)
	clr.l	LN_PRED(a0)
	move.b	#NT_INTERRUPT,LN_TYPE(a0)
	move.b	#100,LN_PRI(a0)
	lea	is_name(pc),a1
	move.l	a1,LN_NAME(a0)
	lea	counter,a1
	move.l	a1,IS_DATA(a0)
	lea	is_code,a1
	move.l	a1,IS_CODE(a0)
	movea.l	mouseio(pc),a1
	move.w	#IND_ADDHANDLER,IO_COMMAND(a1)
	move.l	a0,IO_DATA(a1)
	move.l	#IS_SIZE,IO_LENGTH(a1)
	CALLEXEC	DoIO

mainloop

 * The Wait() instruction waits for another task (program) to signal this
 * task (program). In the meantime it puts this task to sleep (in the
 * waiting state). It is waiting for a signal mask (a 32 bit signal). Wait
 * waits only for those signals (bits) you have set inside the signal mask.
 * It does not wait for any other signals (bits). So if it only waiting for
 * signals 29 and 12 for example it will not awaken this task if it receives
 * signal 23.

waiting	move.l	d6,d0
	CALLEXEC	Wait	      ; Wait for another task to signal us.
	move.l	d0,d4		      ; d4 contains a Signal Mask of signals
				      ; this task/wait has received.

	move.l	d4,d0		      ; It is up to you to check each signal
	and.l	#SIGBREAKF_CTRL_C,d0  ; by ANDing the signal mask.
	cmpi.l	#SIGBREAKF_CTRL_C,d0  ; did I receive a Ctrl_C signal?
	beq.s	ctrl_c		      ; yes. so exit.

	move.l	TC_SIGWAIT(A5),d0     ; no. get the signals I am waiting for.
	cmp.l	d4,d0		      ; did I receive the same signals?
	bne.s	waiting		      ; no. so wait() again.

	suba.l	a0,a0		      ; yes. so exit with a flash.
	CALLINT	DisplayBeep
	bra.s	exit_freehandler

ctrl_c
	moveq	#100,d1
	CALLDOS	Delay

	suba.l	a0,a0
	CALLINT	DisplayBeep

	moveq	#100,d1
	CALLDOS	Delay

	suba.l	a0,a0
	CALLINT	DisplayBeep


exit_freehandler
	move.l	interrupt(pc),a0
	movea.l	mouseio(pc),a1
	move.w	#IND_REMHANDLER,IO_COMMAND(a1)
	move.l	a0,IO_DATA(a1)
	move.l	#IS_SIZE,IO_LENGTH(a1)
	CALLEXEC	DoIO

exit_freemem
	move.l	interrupt(pc),a1
	moveq	#IS_SIZE,d0
	CALLEXEC	FreeMem

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

exit_freesignal
	move.l	d5,d0
	CALLEXEC	FreeSignal

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


 * Branch-To Routines.

do_keys

	bra	mainloop


 * Sub-Routines.

is_code	move.l	a0,-(sp)			; Save `event list' pointer.

loop	move.w	ie_Qualifier(a0),d1		; Store the qualifiers
	move.w	d1,d0				; inside d0 and d1.

check_rmb
	btst	#IEQUALIFIERB_RBUTTON,d1	; Was the rmb pressed?
	beq.s	not_right			; no.
	bset	#IEQUALIFIERB_LEFTBUTTON,d0	; yes. so set lmb bit in d0.
	beq.s	check_lmb			; now check the lmb.
not_right
	bclr	#IEQUALIFIERB_LEFTBUTTON,d0	; clr the lmb bit in d0.

check_lmb
	btst	#IEQUALIFIERB_LEFTBUTTON,d1	; Was the lmb pressed?
	beq.s	not_left			; no.
	bset	#IEQUALIFIERB_RBUTTON,d0	; yes. so set rmb bit in d0.
	beq.s	save_qual
not_left
	bclr	#IEQUALIFIERB_RBUTTON,d0	; clr the rmb bit in d0.

save_qual
	move.w	d0,ie_Qualifier(a0)		; put the new bits inside
						; the qualifier field of
						; this event.

	cmp.b	#IECLASS_RAWMOUSE,ie_Class(a0)	; This should be RAWMOUSE
	bne.s	next_event			; for game ports.

	move.w	ie_Code(a0),d0			; get the icode value.
	move.w	d0,d1
	and.w	#$7F,d0				; take out the UP_PREFIX.
	cmp.w	#IECODE_LBUTTON,d0		; was the lmb used?
	beq.s	swap_them			; yes.
	cmp.w	#IECODE_RBUTTON,d0		; was the rmb used?
	bne.s	next_event			; no. so get the next event.
swap_them
	eor.w	#1,d1				; EOR adds or subtracts one
						; depending on bit 0. So
						; LBUTTON becomes RBUTTON
						; and vice versa.

	move.w	d1,ie_Code(a0)			; put the new button value
						; inside the code field of
						; this event.
next_event
	move.l	(a0),d0				; get the next ie_NextEvent
	move.l	d0,a0
	bne.s	loop				; repeat until all events
						; have been read/altered.

	addi.l	#1,(a1)				; increase counter (IS_DATA)
	move.l	(sp)+,d0			; return `event list' pointer.
	rts


 * Structure Definitions.

font_name
	dc.b	'topaz.font',0
	even

topaz9
	dc.l	font_name
	dc.w	9
	dc.b	FS_NORMAL,FPF_ROMFONT

wndwdefs
	dc.w	200,100,320,80
	dc.b	0,1
	dc.l	IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEBUTTONS!IDCMP_DELTAMOVE!IDCMP_MOUSEMOVE!IDCMP_CLOSEWINDOW
	dc.l	WFLG_NOCAREREFRESH!WFLG_SMART_REFRESH!WFLG_REPORTMOUSE!WFLG_RMBTRAP!WFLG_ACTIVATE!WFLG_CLOSEGADGET!WFLG_DRAGBAR!WFLG_DEPTHGADGET
	dc.l	0,0,0,0,0
	dc.w	0,0,0,0,WBENCHSCREEN


 * Long Variables.

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
_InputBase	dc.l	0
vpptr		dc.l	0
wndwptr		dc.l	0
wndwrp		dc.l	0
iclass		dc.l	0
iadr		dc.l	0
mouseport	dc.l	0
mouseio		dc.l	0
interrupt	dc.l	0


 * Word Variables.

icode		dc.w	0
iqual		dc.w	0
msex		dc.w	0
msey		dc.w	0


 * String Variables.
 
int_name	dc.b	'intuition.library',0
graf_name	dc.b	'graphics.library',0,0
dos_name	dc.b	'dos.library',0
ip_name		dc.b	'input.device',0,0
is_name		dc.b	'JW Handler',0,0


 * Buffer Variables.

iebuf		dcb.b	ie_SIZEOF,0
counter		dcb.b	4,0
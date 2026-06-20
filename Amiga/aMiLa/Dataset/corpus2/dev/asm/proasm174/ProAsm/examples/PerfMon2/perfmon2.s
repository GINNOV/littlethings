;-------------------------------------------------------------------------------
*                                                                              *
* PerfMon  2                                                                   *
*                                                                              *
* Copyright © 1993,1994 by Daniel Weber                                        *
* All Rights Reserved Worldwide                                                *
*                                                                              *
*                                                                              *
*       Filename        perfmon.s                                              *
*       Author          Daniel Weber                                           *
*       Version         1.40                                                   *
*       Start           30.10.93                                               *
*                                                                              *
*       Last Revision   19.11.94                                               *
*                                                                              *
;-------------------------------------------------------------------------------
*                                                                              *
*       NOTE            Since AddPort(exec) attaches a message port structure  *
*                       to the system's public message port list, and I        *
*                       decided that the PerfMon ports are no public at all    *
*                       no ports will be added to the system's public message  *
*                       port list. Thus no AddPort() and no RemPort() are      *
*                       needed.                                                *
*                                                                              *
*                       This version uses the progressbar.r routine file...    *
*                                                                              *
;-------------------------------------------------------------------------------

	output	'ram:perfmon2'

	opt	o+,q+,ow-,qw-,sw-
	verbose
	base	progbase

	filenote	'PerfMon2, Copyright © 1993,1994 by Daniel Weber'

;	equfile		ram:perfmon2.equ
;	creffile	ram:perfmon2.cref

;-------------------------------------------------------------------------------

	incdir	'include:'
	incdir	'routines:'

	incequ	'LVO.s'
	include	'basicmac.r'

	include	'devices/timer.i'
	include	'exec/execbase.i'
	include	'exec/tasks.i'
	include	'exec/ports.i'
	include	'intuition/intuition.i'
	include	'graphics/rastport.i'
	include	'dos/dos.i'
	include	'support.mac'
	include	'tasktricks.r'

;-------------------------------------------------------------------------------

version		equr	"1.40"
gea_progname	equr	"PerfMon2"

;-- startup control  --
cws_V36PLUSONLY	set	1
cws_DETACH	set	1			;detach from CLI
cws_EASYLIB	set	1

;-- user definitions --
AbsExecBase	equ	4

DOS.LIB		equ	36
INTUITION.LIB	equ	36
GRAPHICS.LIB	equ	36

Daemon_Pri	equ	-128

seconds:	equ	1
micros		equ	0			;5*100000


workspace	equ	32

WindowHeight	equ	12
WindowWidth	equ	88
textxstart:	equ	4
textystart	equ	8

bar1_x		EQU	4			; ProgressBar dimensions
bar1_y		EQU	2
bar1_width	EQU	WindowWidth-2*bar1_x
bar1_height	EQU	WindowHeight-2*bar1_y


;-------------------------------------------------------------------------------
progbase:
	jmp	AutoDetach(pc)
	dc.b	"DAW!"
	dc.b	0,"$VER: ",gea_progname," ",version," (",__date2,")",0
	even

;----------------------------
clistartup:
	lea	progbase(pc),a5
	lea	PrintTitle(pc),a0
	bsr	ReplySync

	sub.l	a0,a0				;detach completely
	bsr	ReplySync

wbstartup:
	lea	progbase(pc),a5

	lea	dxstart(pc),a1			;clear DX area
	move.w	#(dxend-dxstart)/2-1,d7
.clr:	clr.w	(a1)+
	dbra	d7,.clr

	InitList_	TimePort+MP_MSGLIST	; init port structures
	InitList_	TimePort2+MP_MSGLIST	; correctly (empty list)


.allocsignal:					;allocate handshake signal
	move.l	4.w,a6
	move.l	ThisTask(a6),MasterTask(a5)

	moveq	#-1,d0
	jsr	_LVOAllocSignal(a6)
	move.l	d0,HandShakeSig(a5)
	bmi	.nosignal
	moveq	#0,d1
	bset	d0,d1
	move.l	d1,HandShakeMask(a5)

	moveq	#-1,d0
	jsr	_LVOAllocSignal(a6)
	move.l	d0,SignalNumber2(a5)
	move.l	d0,d2
	bmi	.nosignal2

.port:	lea	TimePort2(pc),a1
	move.l	4.w,a6
	move.b	#NT_MSGPORT,LN_TYPE(a1)
	move.b	#PA_SIGNAL,MP_FLAGS(a1)
	move.b	d2,MP_SIGBIT(a1)
	move.l	ThisTask(a6),MP_SIGTASK(a1)
	clr.l	LN_NAME(a1)
;	jsr	_LVOAddPort(a6)

.device:					;open timer device
	lea	TimeRequest2(pc),a1
	moveq	#UNIT_MICROHZ,d0
	moveq	#0,d1
	lea	TimerName(pc),a0
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	.freesignal
	seq	timeropened(a5)			;flag if timer.device open
	move.l	TimeRequest+IO_DEVICE(pc),TimerBase(a5)


.main:	lea	NewWindowStructure(pc),a0
	move.l	IntBase(pc),a6
	jsr	_LVOOpenWindow(a6)
	move.l	d0,Windowhandle(a5)
	move.l	d0,bar1_wd(a5)
	beq	.cleanup
	move.l	d0,a0				;add menu list to window
	lea	MenuList(pc),a1
	jsr	_LVOSetMenuStrip(a6)

	move.l	Windowhandle(pc),a3		;set font and pens...
	move.l	wd_RPort(a3),a3
	move.l	a3,a1
	moveq	#1,d0
	move.l	GfxBase(pc),a6
	jsr	_LVOSetAPen(a6)
	move.l	a3,a1
	moveq	#0,d0
	jsr	_LVOSetBPen(a6)

	move.l	a3,a1
	moveq	#RP_COMPLEMENT,d0
	jsr	_LVOSetDrMd(a6)

	lea	Topaz80(pc),a0
	jsr	_LVOOpenFont(a6)
	move.l	d0,WindowFont(a5)
	beq.s	.install
	move.l	d0,a0
	move.l	a3,a1
	jsr	_LVOSetFont(a6)



	lea	bar1(pc),a0
	move.l	Windowhandle(pc),a1
	clr.l	pgb_value(a0)
	CALL_	InitProgressBar

.install:
	bsr	InstallDaemon
	beq	.nodaemon

	bsr	main


.killslave:
	move.l	4.w,a6
	jsr	_LVOForbid(a6)
	lea	TaskReady(a6),a0	;slave should be in the ready list
	lea	DaemonNameReal(pc),a1
	jsr	_LVOFindName(a6)
	tst.l	d0
	beq.s	.nos
	move.l	#SIGBREAKF_CTRL_C,d0
	move.l	DaemonTask(pc),d1
	beq.s	.nos
	move.l	d1,a1
	jsr	_LVOSignal(a6)
.nos:	jsr	_LVOPermit(a6)

;
; clean up and exit
;
.nodaemon:				;NOTE:  if a setup error occures, no
.nosignal:				;message will be reported to the user
.nosignal2:				;

.cleanup:				;close window
	move.l	WindowFont(pc),d0
	beq.s	.closewd
	move.l	d0,a1
	move.l	GfxBase(pc),a6
	jsr	_LVOCloseFont(a6)

.closewd:
	move.l	Windowhandle(pc),d6
	beq.s	.closedevice
	move.l	d6,a0
	move.l	IntBase(pc),a6
	jsr	_LVOClearMenuStrip(a6)
	move.l	d6,a0
	jsr	_LVOCloseWindow(a6)

.closedevice:
	tst.b	timeropened(a5)		;timer.device open?
	beq.s	.freesignal
	lea	TimeRequest2(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

.freesignal:				;free the handshake & timer signal (good)
	move.l	SignalNumber2(pc),d0
	bmi.s	.sig1
	move.l	4.w,a6
	jsr	_LVOFreeSignal(a6)

.rport:
;	lea	TimePort2(pc),a1
;	move.l	4.w,a6
;	jsr	_LVORemPort(a6)

.sig1:	tst.l	HandShakeMask(a5)
	beq.s	.exit
	move.l	4.w,a6
	move.l	HandShakeSig(pc),d0
	jsr	_LVOFreeSignal(a6)

.exit:	moveq	#0,d0			;exit...
	bra	ReplyWBMsg



;-------------------------------------------------------------------------------
*
* main
*
;-------------------------------------------------------------------------------


main:	lea	progbase(pc),a5

.wait:	lea	TimeRequest2(pc),a1
	mea	TimePort2(pc),MN_REPLYPORT(a1)
	move.w	#TR_GETSYSTIME,IO_COMMAND(a1)
	move.b	#IOF_QUICK,IO_FLAGS(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)				;get system time...
	move.l	TimerBase(pc),a6
	lea	ResultTime2(pc),a0
	lea	TimeRequest2+IOTV_TIME(pc),a1
	clr.l	TV_SECS(a0)
	clr.l	TV_MICRO(a0)
	jsr	_LVOSubTime(a6)
	clr.l	ResultTime+TV_SECS(a5)
	clr.l	ResultTime+TV_MICRO(a5)

	lea	TimeRequest2(pc),a1
	mea	TimePort2(pc),MN_REPLYPORT(a1)
	move.w	#TR_ADDREQUEST,IO_COMMAND(a1)
	move.l	#seconds,IOTV_TIME+TV_SECS(a1)
	move.l	#micros,IOTV_TIME+TV_MICRO(a1)
	move.l	4.w,a6
	jsr	_LVOSendIO(a6)				;wait time (1 sec)

.loop:	move.l	SignalNumber2(pc),d1
	moveq	#0,d0
	bset	d1,d0
	move.l	d0,d7
	move.l	Windowhandle(pc),a0
	move.l	wd_UserPort(a0),a0
	move.l	a0,a3
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	move.l	4.w,a6
	jsr	_LVOWait(a6)

	cmp.l	d7,d0
	beq.s	.timer

;
; a window message received... (only MENUPICK as IDCMP set)
;
; a3: wd_UserPort
; a6: execbase
;
.window:
	move.l	4.w,a6
	move.l	Windowhandle(pc),a0
	move.l	wd_UserPort(a0),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,a1
	move.l	a1,d0
	beq.s	.exit
	move.l	im_Class(a1),d4		;IDCMP flags
	move.w	im_Code(a1),d5		;menu number
	move.l	im_IAddress(a1),d6	;pointer to a gadget or menu item etc.
	jsr	_LVOReplyMsg(a6)

	lea	.eventtable(pc),a0
.event:	move.w	(a0)+,d0
	beq.s	.window
	cmp.w	d0,d5
	movea.l	(a0)+,a1
	bne.s	.event
	jsr	(a1)
	bra.s	.window
.exit:	tst.b	quitflag(a5)		;exit if quitflag set
	beq	.loop
	rts


.eventtable:				;dc.w <im_Code>; dc.l <routine>
	dc.w	(-1<<11)|(0<<5)|(0)	;About
	dc.l	DoAbout
	dc.w	(-1<<11)|(1<<5)|(0)	;Quit
	dc.l	DoQuit
	dc.w	0


;
; message received from timer...
;
; a6: execbase
;
.timer:
	lea	progbase(pc),a5
	move.l	4.w,a6
	jsr	_LVOForbid(a6)
	lea	TimeRequest2(pc),a1
	mea	TimePort2(pc),MN_REPLYPORT(a1)
	move.w	#TR_GETSYSTIME,IO_COMMAND(a1)
	move.b	#IOF_QUICK,IO_FLAGS(a1)
	jsr	_LVODoIO(a6)				;get system time
	move.l	TimerBase(pc),a6
	lea	ResultTime2(pc),a0
	lea	TimeRequest2+IOTV_TIME(pc),a1
	jsr	_LVOAddTime(a6)				;=> passed time

.evaluate:
	move.l	ResultTime2+TV_SECS(pc),d0
	move.l	#1000000,d1				;10^6
	bsr	mulu32
	add.l	ResultTime2+TV_MICRO(pc),d0		;passed time in micros
	move.l	d0,d7

	move.l	ResultTime+TV_SECS(pc),d0
	move.l	#1000000,d1				;10^6
	bsr	mulu32
	add.l	ResultTime+TV_MICRO(pc),d0		;slave time in micros

	move.l	d7,d4
	sub.l	d0,d7
	exg	d7,d0
	move.l	#1000,d1
	bsr	mulu32
	move.l	d4,d1
	bsr	divu32
	move.w	d0,bar1+pgb_value+2(a5)
	divu	#10,d0
	move.l	d0,d1
	swap	d1					;remainder

	move.l	4.w,a6
	jsr	_LVOPermit(a6)

	move.w	d0,rawlist(a5)
	move.w	d1,rawlist+2(a5)


	lea	cpuloadtxt(pc),a0
	lea	rawlist(pc),a1
	lea	workbuffer(pc),a3
	bsr	DoRawFmt

	lea	bar1(pc),a0
	CALL_	SetProgressBar

	move.l	GfxBase(pc),a6
	move.l	Windowhandle(pc),a1
	move.l	wd_RPort(a1),a1
	move.l	a1,a3
	moveq	#textxstart,d0
	moveq	#textystart,d1
	jsr	_LVOMove(a6)
	move.l	a3,a1
	lea	workbuffer(pc),a0
	moveq	#-1,d0
	move.l	a0,a3
.cnt:	addq.l	#1,d0
	tst.b	(a3)+
	bne.s	.cnt
	jsr	_LVOText(a6)
	clr.l	ResultTime+TV_SECS(a5)
	clr.l	ResultTime+TV_MICRO(a5)
	bra	.wait




;------------------------------------------------
;
; DoQuit	- (CCR =>  0: don't  -:quit)
;
DoQuit:
	st	quitflag(a5)
	rts

	
;------------------------------------------------
;
; DoAbout	- (CCR => must be 0)
;
DoAbout:
	move.l	IntBase(pc),a6
	move.l	Windowhandle(pc),a0
	lea	easystruct(pc),a1
	suba.l	a2,a2
	lea	rawlist(pc),a3
	jsr	_LVOEasyRequestArgs(a6)
	rts


;-------------------------------------------------------------------------------
*
* subroutines
*
;-------------------------------------------------------------------------------



;------------------------------------------------
;
; (simple) arithmetic subroutines
;
; d0=d0*d1
;
; d0/d1/d5/d6 affected...
;
mulu32:
	move.l	d0,d6
	move.w	d0,d5
	mulu	d1,d5			;lo*lo
	swap	d1
	mulu	d1,d0			;hi*lo
	swap	d0
	add.l	d5,d0
	swap	d6
	move.w	d6,d5
	mulu	d1,d5			;hi*hi
	swap	d1
	mulu	d1,d6			;lo*hi
	swap	d6
	add.l	d6,d0
	rts

;
; d0=d0/d1 (divu.l d1,d0)
; => d2: remainder
;
;
; d0/d1/d2/d5/d6 affected
;
divu32:
	cmp.l	d0,d1
	bls.s	1$
	move.l	d0,d2
	moveq	#0,d0
	rts

1$:	moveq	#0,d2
	moveq	#0,d5
	moveq	#31,d6
\loop:	add.l	d0,d0
	addx.l	d2,d2
	add.l	d5,d5
	cmp.l	d1,d2
	dbge	d6,\loop
	blt.s	\out
	sub.l	d1,d2
	addq.b	#1,d5
	dbra d6,\loop
\out:	move.l	d5,d0
	rts


;------------------------------------------------
;
; PrintTitle	- print title to the StdOut channel using the parent task...
;
PrintTitle:
	lea	progbase(pc),a5
	lea	TitleText(pc),a0
	printtext_	,,,bra


;------------------------------------------------
;
; DoRawFmt	- Format a string
;
; a0: format
; a1: data stream
; a3: dest. buffer
;
DoRawFmt:
	movem.l	d0-a6,-(a7)
	lea	.setin(pc),a2
	move.l	4.w,a6
	jsr	_LVORawDoFmt(a6)
	movem.l	(a7)+,d0-a6
	rts

.setin:	move.b	d0,(a3)+
	rts


;------------------------------------------------
;
; InstallDaemon	- install a 'busy looping' slave process
;
; => d0: daemon task structure (CCR)
;
InstallDaemon:
	lea	progbase(pc),a5
	move.l	4.w,a6

	lea	DaemonName(pc),a0		; generate a unique process name
	lea	rawlist(pc),a1
	move.l	ThisTask(a6),(a1)
	lea	DaemonNameReal(pc),a3
	bsr	DoRawFmt

	jsr	_LVOForbid(a6)

	mea	DaemonNameReal(pc),d1
	moveq	#Daemon_Pri,d2
	mea	DaemonCode-4(pc),d3
	lsr.l	#2,d3				;BCPL
	move.l	#700,d4				;stack
	move.l	DosBase(pc),a6
	jsr	_LVOCreateProc(a6)

	move.l	4.w,a6
	jsr	_LVOPermit(a6)			;does not affect d0

	move.l	d0,DaemonTask(a5)
	beq.s	1$

	move.l	HandShakeMask(pc),d0		;wait for reply (if started)
	jsr	_LVOWait(a6)
	move.l	DaemonTask(pc),d0
1$:	rts



;
; daemon code
;
	align.l
	dc.l	0				;length
	dc.l	0

DaemonCode:
	lea	progbase(pc),a5
	clr.l	DaemonTask(a5)
	pea	de_signal(pc)			;if error  ->  de_signal

	moveq	#-1,d0				;allocate signal bit for port
	move.l	4.w,a6
	jsr	_LVOAllocSignal(a6)
	move.l	d0,SignalNumber(a5)
	move.l	d0,d2
	bmi	de_exit

.port:	lea	TimePort(pc),a1			;add port
	move.l	4.w,a6
	move.b	#NT_MSGPORT,LN_TYPE(a1)
	move.b	#PA_SIGNAL,MP_FLAGS(a1)
	move.b	d2,MP_SIGBIT(a1)
	move.l	ThisTask(a6),MP_SIGTASK(a1)
	clr.l	LN_NAME(a1)
;	jsr	_LVOAddPort(a6)

.device:					;open timer device
	lea	TimeRequest(pc),a1
	moveq	#UNIT_MICROHZ,d0
	moveq	#0,d1
	lea	TimerName(pc),a0
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	de_remport
	move.l	TimeRequest+IO_DEVICE(pc),TimerBase(a5)
	beq	de_closedevice

	move.l	ThisTask(a6),a0
	move.l	a0,DaemonTask(a5)
	mea	Switch(pc),TC_SWITCH(a0)
	mea	Launch(pc),TC_LAUNCH(a0)
	or.b	#TF_SWITCH|TF_LAUNCH,TC_FLAGS(a0)

	addq.l	#4,a7				;remove 'de_signal' from stack
	bsr	de_signal

waitloop:					;busy wait loop
	move.l	#$1000,d7
	move.l	d7,d1
	moveq 	#0,d0
	move.l	4.w,a6
	jsr	_LVOSetSignal(a6)
	and.l	d7,d0				;Ctrl-C?
	beq.s	waitloop

	move.l	ThisTask(a6),a0
	and.b	#(~(TF_SWITCH|TF_LAUNCH))&$ff,TC_FLAGS(a0)
	clr.l	TC_SWITCH(a0)
	clr.l	TC_LAUNCH(a0)


de_closedevice:					;close timer device
	lea	TimeRequest(pc),a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

de_remport:					;remove port
;	lea	TimePort(pc),a1
;	move.l	4.w,a6
;	jsr	_LVORemPort(a6)

de_freesignal:					;free signal
	move.l	SignalNumber(pc),d0
	bmi.s	de_exit
	move.l	4.w,a6
	jsr	_LVOFreeSignal(a6)

de_exit:
	rts

;
; send a signal to the master task
;
de_signal:
	move.l	4.w,a6
	move.l	HandShakeMask(pc),d0
	move.l	MasterTask(pc),a1
	jmp	_LVOSignal(a6)



DaemonName:	dc.b	gea_progname,"_slave.%08lx",0
DaemonNameReal:	dc.b	gea_progname,"_slave.00000000",0
		even



;-------------------------------------------------------------------------------
*
* Switch & Launch
*
;-------------------------------------------------------------------------------

;
; task loses CPU
;
Switch:
	movem.l	d0-a6,-(a7)
	move.l	4.w,a6
	lea	TimeRequest(pc),a1
	mea	TimePort(pc),MN_REPLYPORT(a1)
	move.w	#TR_GETSYSTIME,IO_COMMAND(a1)
	move.b	#IOF_QUICK,IO_FLAGS(a1)
	jsr	_LVODoIO(a6)
	move.l	TimerBase(pc),a6
	lea	ResultTime(pc),a0
	lea	TimeRequest+IOTV_TIME(pc),a1
	jsr	_LVOAddTime(a6)
	movem.l	(a7)+,d0-a6
	rts

;
; task gets CPU
;
Launch:	
	movem.l	d0-a6,-(a7)
	move.l	4.w,a6
	lea	TimeRequest(pc),a1
	mea	TimePort(pc),MN_REPLYPORT(a1)
	move.w	#TR_GETSYSTIME,IO_COMMAND(a1)
	move.b	#IOF_QUICK,IO_FLAGS(a1)
	jsr	_LVODoIO(a6)
	move.l	TimerBase(pc),a6
	lea	ResultTime(pc),a0
	lea	TimeRequest+IOTV_TIME(pc),a1
	jsr	_LVOSubTime(a6)
	movem.l	(a7)+,d0-a6
	rts



;-------------------------------------------------------------------------------
*
* external routines
*
;-------------------------------------------------------------------------------
	include	startup4.r
	include	progressbars.r

;-------------------------------------------------------------------------------
*
* data area
*
;-------------------------------------------------------------------------------
processname:	dc.b	gea_progname,0
TimerName:	dc.b	"timer.device",0

TitleText:	dc.b	$9b,"1m",gea_progname,$9b,"0m v",version
		dc.b	" - Written 1993 by Daniel Weber",$a,0

cpuloadtxt:	dc.b	" %3d.%1d%%  ",0
		even

;
; easy requester structure
;
easystruct:	dc.l	EasyStruct_SIZEOF
		dc.l	0			;flags
		dc.l	.title			;title
		dc.l	.about
		dc.l	.ok
.title:		dc.b	gea_progname," v",version," - About...",0
.ok:		dc.b	"Continue",0
.about:		dc.b	gea_progname," v",version,$a
		dc.b	"Written 1993 by Daniel Weber",$a
		dc.b	"(assembled on the ",__date,")",$a,$a
		dc.b	"Written using the ProAsm assembler.",$a,$a
		dc.b	"This program is Public Domain.",$a
		dc.b	"No Warranty, use at your own risk!",$a,0
		even


;
; window and its gadget(s)
;
NewWindowStructure:
	dc.w	0,0		;window XY origin relative to TopLeft of screen
	dc.w	WindowWidth,WindowHeight	;window width and height
	dc.b	0,1				;detail and block pens
	dc.l	MENUPICK			;IDCMP flags
	dc.l	WFLG_SMART_REFRESH		;other window flags
	dc.l	Gadget1				;first gadget in gadget list
	dc.l	0				;custom CHECKMARK imagery
	dc.l	0				;window title
	dc.l	0				;custom screen pointer
	dc.l	0				;custom bitmap
	dc.w	WindowWidth,WindowHeight	;minimum width and height
	dc.w	WindowWidth,WindowHeight	;maximum width and height
	dc.w	WBENCHSCREEN			;destination screen type

;
; used GTYP_WDRAGGING gadget type to simulate a dragbar (V37)
;
Gadget1:dc.l	0		;next gadget
	dc.w	0,0		;origin XY of hit box relative to window TopLeft
	dc.w	0,0		;hit box width and height
	dc.w	GADGHBOX+GRELWIDTH+GRELHEIGHT+GADGHIMAGE	;flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	GTYP_WDRAGGING	;gadget type flags
	dc.l	0		;gadget border or image to be rendered
	dc.l	0		;alternate imagery for selection
	dc.l	0		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	.info		;SpecialInfo structure
	dc.w	0		;user-definable data (ID)
	dc.l	0		;pointer to user-definable data

.info:	dc.w	0		;PropInfo flags
	dc.w	0,1800		;horizontal and vertical pot values
	dc.w	2000,256	;horizontal and vertical body values
	dc.w	0,0,0,0,0,0	;Intuition initialized and maintained variables

;
; menu structure of perfmon
;
MenuList:
	dc.l	0			;next Menu structure
	dc.w	0,0			;XY origin of Menu hit box
	dc.w	63,0			;Menu hit box width and height
	dc.w	MENUENABLED		;Menu flags
	dc.l	MenuName		;text of Menu name
	dc.l	MenuItem1		;MenuItem linked list pointer
	dc.w	0,0,0,0			;Intuition variables


MenuItem1:				;ABOUT
	dc.l	MenuItem2		;next MenuItem structure
	dc.w	0,0			;XY of Item hitbox
	dc.w	84,10			;hit box width and height
	dc.w	ITEMTEXT+ITEMENABLED+HIGHCOMP	;Item flags
	dc.l	0
	dc.l	.text			;Item render
	dc.l	0			;Select render
	dc.b	0			;alternate command-key
	dc.b	0			;fill byte
	dc.l	0			;SubItem list
	dc.w	MENUNULL

.text:	dc.b	0,0			;front and back text pens
	dc.b	RP_JAM1,0		;drawmode and fill byte
	dc.w	2,1			;XY origin
	dc.l	Topaz80			;font pointer or NULL for default
	dc.l	texttext1		;pointer to text
	dc.l	0			;next IntuiText structure

MenuItem2:				;QUIT
	dc.l	0			;next MenuItem structure
	dc.w	0,12			;XY of Item hitbox
	dc.w	84,10			;hit box width and height
	dc.w	ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP	;Item flags
	dc.l	0
	dc.l	.text			;Item render
	dc.l	0			;Select render
	dc.b	'Q'			;alternate command-key
	dc.b	0			;fill byte
	dc.l	0			;SubItem list
	dc.w	MENUNULL		;MENUNULL=$FFFF

.text:	dc.b	0,0			;front and back text pens
	dc.b	RP_JAM1,0		;drawmode and fill byte
	dc.w	2,1			;XY origin
	dc.l	Topaz80			;font pointer or NULL for default
	dc.l	texttext2		;pointer to text
	dc.l	0			;next IntuiText structure

MenuName:	dc.b	'Project',0
texttext1:	dc.b	'About...',0
texttext2:	dc.b	'Quit',0
		even

;
; font...
;
	align.l
Topaz80:dc.l	.font			;ta_name
	dc.w	8			;ta_ysize
	dc.b	0,1			;ta_style, ta_flags
.font:	dc.b	"topaz.font",0
	even


bar1:		ProgressStruct_ bar1,1000,0
bar1_wd:	EQU	bar1+pgb_window
bar1_val:	EQU	bar1+pgb_value
	



dxstart:
;-------------------------------------------------------------------------------
InitSP:		dx.l	1		; initial sp

;-- system ------------------------------------------------
Windowhandle:	dx.l	1		; window handle
WindowFont:	dx.l	1		; window font
tickcounter:	dx.w	1		; tick counter for intuiticks
MasterTask:	dx.l	1		; task address for PerfMon
rawlist:	dx.l	1		; rawlist for DoRawFmt

;-- daemon ------------------------------------------------
DaemonTask:	dx.l	1		; daemon task
HandShakeSig:	dx.l	1		; signal number
HandShakeMask:	dx.l	1		; sigbit mask for task communication

;-- flags -------------------------------------------------
quitflag:	dx.b	1		; 0: do not              -: quit...
timeropened:	dx.b	1		; 0: timer devive not... -: open
		aligndx.w

;-- timer -------------------------------------------------
TimerBase:	dx.l	1		; timer base (daemon)
TimerBase2:	dx.l	1		; timer base (master)
SignalNumber:	dx.l	1		; signal number for port (demon task)
SignalNumber2:	dx.l	1		; signal number for port (master task)

TimeRequest:	dx.b	IOTV_SIZE	; timer request structure (daemon)
TimeRequest2:	dx.b	IOTV_SIZE	; timer request structure (master)

ResultTime:	dx.b	TV_SIZE		; result time (daemon)
ResultTime2:	dx.b	TV_SIZE		; result time (master)

TimePort:	dx.b	MP_SIZE		; (daemon)
TimePort2:	dx.b	MP_SIZE		; (master)

;-- buffer ------------------------------------------------
workbuffer:	dx.b	workspace

;-------------------------------------------------------------------------------
	aligndx.w
dxend:
	end

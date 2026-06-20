
; Small utility that allows the contents of any window to be printed.

; © M.Meany, April 1991.

		opt 		o+

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		devices/printer.i

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"



		bsr.s		Openlibs	open libraries
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr.s		Openwin		open window
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		WaitForMsg	wait for user

		bsr		Closewin	close our window

		bsr		DumpWindow	print window for user

no_libs		bsr		Closelibs	close open libraries

		rts				finish


;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		intname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		gfxname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_GfxBase	save base ptr

.lib_error	rts

*************** Open An Intuition Window

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

Openwin		lea		MyWindow,a0	a0->window args
		CALLINT		OpenWindow	and open it
		move.l		d0,window.ptr	save struct ptr
		beq.s		.win_error	quit if error

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),window.up ;save up ptr
		move.l		wd_RPort(a0),window.rp    ;save rp ptr

;--------------	Display basic usage text for user

		move.l		window.rp,a0
		lea		WinText,a1
		moveq.l		#0,d0
		move.l		d0,d1
		CALLINT		PrintIText

.win_error	rts

*************** Wait for user to de-activate the window.


WaitForMsg	move.l		window.up,a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.up,a0	a0-->window pointer
		CALLEXEC	GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		CALLEXEC	ReplyMsg	answer os or it get angry

		cmp.l		#INACTIVEWINDOW,d2  ;window deactivated ?
		bne.s		WaitForMsg

		rts


*************** Dump window contents to printer

	
;--------------	Initialise a port to use with printer device

DumpWindow	lea		MyPortName,a0	name for port ( public )
		moveq.l		#0,d0		priority
		bsr		CreatePort	get a port
		move.l		d0,MyPort	save its address

;--------------	Initialise printer io structure

		lea		print_io,a5		io request
		move.l		d0,MN_REPLYPORT(a5)	port addr
		move.w		#PRD_DUMPRPORT,IO_COMMAND(a5)	command write

;--------------	Pointers to the currently active screen and its window are
;		is obtained from Intuition Base. From these structures it is
;		possible to pull the data required in the IODRPReq structure.
		
		move.l		_IntuitionBase,a1
		move.l		ib_ActiveWindow(a1),a0
		move.w		wd_Width(a0),io_SrcWidth(a5)
		move.w		wd_Height(a0),io_SrcHeight(a5)
		move.l		wd_RPort(a0),a0
		move.l		a0,io_RastPort(a5)

		move.l		ib_ActiveScreen(a1),a1	a1->screen
		lea		sc_ViewPort(a1),a0	a0->viewport
		move.l		vp_ColorMap(a0),io_ColorMap(a5)
		move.l		vp_Modes(a0),io_Modes(a5)
		move.w		#0,io_SrcX(a5)
		move.w		#0,io_SrcY(a5)
		move.l		#0,io_DestCols(a5)
		move.l		#0,io_DestRows(a5)
		move.w		#SPECIAL_ASPECT!SPECIAL_FULLROWS,io_Special(A5)


;--------------	Open the printer device

		move.l		a5,a1		a1->device io structure
		moveq.l		#0,d0		unit 0
		move.l		d0,d1		no special flags
		lea		printername,a0	a0->device name
		CALLEXEC	OpenDevice	attempt to open it
		tst.l		d0		all ok ?
		bne.s		error2		leave if not
		
;--------------	Dump rastport to printer

		move.l		a5,a1		a1->io structure
		CALLEXEC	SendIO		and print screen

;--------------	Wait for printer to finish. This puts this process to sleep
;		and stops the system from slowing down.

		move.l		a5,a1		a1->io structure
		CALLEXEC	WaitIO		wait for a reply from device

;--------------	Close printer device

		move.l		a5,a1
		CALLEXEC	CloseDevice
		
;--------------	Release the Port

error2		move.l		MyPort,a0
		bsr		DeletePort


		rts

*************** Close the Intuition window.

Closewin	move.l		window.ptr,a0
		CALLINT		CloseWindow
		rts

***************	Close all open libraries

; Closes any libraries the program managed to open.

Closelibs	move.l		_DOSBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_IntuitionBase,d0	d0=base ptr	
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_GfxBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts


* port = CreatePort(Name,Pri)
* a0 = name
* d0 = pri
* returns d0 = port, NULL if couldn't do it

* d1/d7/a1 corrupt

* NON-MODIFIABLE.


CreatePort	movem.l	d0/a0,-(sp)	;save parameters
		moveq	#-1,d0
		CALLEXEC	AllocSignal	;get a signal bit
		tst.l	d0
		bmi.s	cp_error1
		move.l	d0,d7		;save signal bit

* got signal bit. Now create port structure.

		move.l	#MP_SIZE,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l	d0
		beq.s	cp_error2	;couldn't create port struct!

* Here initialise port node structure.

		move.l	d0,a0
		movem.l	(sp)+,d0/d1	;get parms off stack
		move.l	d1,LN_NAME(a0)	;set name pointer
		move.b	d0,LN_PRI(a0)	;and priority

		move.b	#NT_MSGPORT,LN_TYPE(a0)	;ensure it's a message
						;port

* Here initialise rest of port.

		move.b	#PA_SIGNAL,MP_FLAGS(a0)	;signal if msg received
		move.b	d7,MP_SIGBIT(a0)		;signal bit here
		move.l	a0,-(sp)
		sub.l	a1,a1
		CALLEXEC	FindTask		;find THIS task
		move.l	(sp)+,a0
		move.l	d0,MP_SIGTASK(a0)	;signal THIS task if msg arrived

* Here, if public port, add to public port list, else
* initialise message list header.

		tst.l	LN_NAME(a0)	;got a name?
		beq.s	cp_private	;no

		move.l	a0,-(sp)
		move.l	a0,a1
		CALLEXEC	AddPort		;else add to public port list
		move.l	(sp)+,d0		;(which also NewList()s the
		rts			;mp_MsgList)

* Here initialise list header.

cp_private	lea	MP_MSGLIST(a0),a1	;ptr to list structure
		exg	a0,a1		;for now
		move.b	#NT_MESSAGE,d0	;type = message list
		bsr	NewList		;do it!

		move.l	a1,d0		;return ptr to port
		rts

* Here couldn't allocate. Release signal bit.

cp_error2	move.l	d7,d0
		CALLEXEC	FreeSignal

* Here couldn't get a signal so quit NOW.

cp_error1	movem.l	(sp)+,d0/a0
		moveq	#0,d0		;signal no port exists!

		rts


* DeletePort(Port)
* a0 = port

* a1 corrupt

* NON-MODIFIABLE.


DeletePort	move.l	a0,-(sp)
		tst.l	LN_NAME(a0)	;public port?
		beq.s	dp_private	;no

		move.l	a0,a1
		CALLEXEC	RemPort		;remove port

* here make it difficult to re-use the port.

dp_private	move.l	(sp)+,a0
		moveq	#-1,d0
		move.l	d0,MP_SIGTASK(a0)
		move.l	d0,MP_MSGLIST(a0)

* Now free the signal.

		moveq	#0,d0
		move.b	MP_SIGBIT(a0),d0
		CALLEXEC	FreeSignal

* Now free the port structure.

		move.l	a0,a1
		move.l	#MP_SIZE,d0
		CALLEXEC	FreeMem

		rts


* NewList(list,type)
* a0 = list (to initialise)
* d0 = type

* NON-MODIFIABLE.

NewList		move.l	a0,(a0)		;lh_head points to lh_tail
		addq.l	#4,(a0)
		clr.l	4(a0)		;lh_tail = NULL
		move.l	a0,8(a0)		lh_tailpred points to lh_head

		move.b	d0,12(a0) ;list type

		rts


***************
*************** DATA SECTION
***************

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even
printername	dc.b		'printer.device',0
		even
MyPortName	dc.b		'MMsPort',0
		even

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1
MyPort		ds.l		1


print_io	ds.b		iodrpr_SIZEOF

***************


MyWindow	dc.w		75,85
		dc.w		384,23
		dc.b		0,3
		dc.l		INACTIVEWINDOW
		dc.l		ACTIVATE+NOCAREREFRESH
		dc.l		0
		dc.l		0
		dc.l		WinName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

WinName		dc.b		'     Window Printer © M.Meany April 1991',0
		even


WinText		dc.b		2,0,RP_JAM2,0
		dc.w		72,12
		dc.l		0
		dc.l		msg
		dc.l		0

msg		dc.b		'Click in window to print !',0
		even





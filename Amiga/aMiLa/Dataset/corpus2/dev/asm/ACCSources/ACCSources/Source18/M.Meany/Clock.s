

*****	Function	A Small and simple clock program.
*****	Size		62O bytes
*****	Author		M.Meany.
*****	Date		11 Nov 91.

; This program demonstrates that INTUITICKS are only sent to the UserPort
; of the currently active window. It also shows how to decipher the time
; from the DateStamp obtained from DOS.


		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"

		opt o+

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base ptr
		beq		error		quit if error

		lea		intname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq		error1		quit if error

		lea		MyWindow,a0	a0->window args
		CALLINT		OpenWindow	and open it
		move.l		d0,window.ptr	save struct ptr
		beq.s		error2		quit if error

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),window.up ;save up ptr
		move.l		wd_RPort(a0),window.rp    ;save rp ptr

		moveq.l		#1,d7		init counter

WaitForMsg	move.l		window.up,a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.up,a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.w		im_Code(a1),d3	code ( for VANILLAKEY )
		CALLSYS		ReplyMsg	answer os or it get angry

; If an INTUITICK, update counter. If counter = 7 update clock in title bar.

.test_tick	cmp.l		#INTUITICKS,d2	check for tick
		bne.s		.test_win
		subq.l		#1,d7		d7 is our counter
		bne.s		WaitForMsg	loop back if not zero
		moveq.l		#5,d7		reset counter!
		bsr.s		DoClock		and update clock
		bra.s		WaitForMsg	loop back

.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		WaitForMsg	 if not then jump

		move.l		window.ptr,a0	a0->Window struct
		CALLINT		CloseWindow	and close it

error2		move.l		_IntuitionBase,a1	a1=base ptr
		CALLEXEC	CloseLibrary		close lib

error1		move.l		_DOSBase,d0		a1=base ptr	
		CALLEXEC	CloseLibrary		close lib

error		rts


DoClock		move.l		#DSDays,d1	d1=addr of buffer
		CALLDOS		DateStamp	and get stamp

		lea		DataStream,a0	a0->RDF data buffer

		move.l		DSMin,d0	d0=mins past midnight
		divu		#60,d0		convert to hours

		swap		d0		mins in low word, hrs in high
		move.l		d0,(a0)+	save in RDF data buffer

		move.l		DSSec60,d0	get seconds x 60
		divu		#50,d0		convert to secs
		move.w		d0,(a0)

		lea		Template,a0	a0->rdf template
		lea		DataStream,a1	a1->rdf datastream
		lea		PutChar,a2	a2->PutChar subroutine
		lea		Tim,a3		a3->dest buffer
		CALLEXEC	RawDoFmt	built window title

		move.l		window.rp,a0
		lea		TimeString,a1
		moveq.l		#0,d0
		move.l		d0,d1
		CALLINT		PrintIText

		rts

PutChar		move.b		d0,(a3)+
		rts


dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even

Template	dc.b		'Mark  %02d:%02d:%02d ',0
		even

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************


MyWindow	dc.w		20,0
		dc.w		210,10
		dc.b		0,1
		dc.l		CLOSEWINDOW+INTUITICKS
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
		dc.l		0		;gadgets
		dc.l		0
		dc.l		WindowName
		dc.l		0
		dc.l		0
		dc.w		100,25
		dc.w		640,200
		dc.w		WBENCHSCREEN

WindowName	dc.b		' ',0
		even


TimeString	dc.b		0,1		front and back text pens
		dc.b		RP_JAM2,0	drawmode and fill byte
		dc.w		38,1		XY org relative to TopLeft
		dc.l		0		font pointer (default)
		dc.l		Tim		pointer to text
		dc.l		0		no more IntuiTexts



;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_DOSBase	ds.l		1		space for lib base pointer
_IntuitionBase	ds.l		1		space for lib base pointer

window.ptr	ds.l		1		space for window pointer
window.rp	ds.l		1		space for rastport pointer
window.up	ds.l		1		space for user port pointer

DSDays		ds.l		1		space for DateStamp
DSMin		ds.l		1
DSSec60		ds.l		1

DataStream	ds.l		3		room for rdf buffer

Tim		ds.b		20		space for ASCII string


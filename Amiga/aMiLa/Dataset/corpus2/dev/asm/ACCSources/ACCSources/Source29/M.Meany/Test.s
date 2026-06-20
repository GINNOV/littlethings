
; Implementing WinGfx.i and Zone.i in one example. First a window is drawn
;and a requester thrown up. Once the requester has been satisfied, some
;areas of the screen are drawn and zone checking commences running off mouse
;moves! MM.

		incdir		sys:Include/
		include		exec/exec.i
		include		exec/exec_lib.i
		include		intuition/intuition.i
		include		intuition/intuition_lib.i
		include		graphics/graphics_lib.i
		incdir		ACC29_A:Include/
		include		reqtools.i
		include		reqtools_lib.i



		*****************************************
		*	  	Main			*
		*****************************************

Start		bsr		Openlibs
		tst.l		d0
		beq.s		.done

		bsr		OpenWin
		tst.l		d0
		beq.s		.Error1

		bsr		ShowReq

		bsr		DoGfx
		
		bsr		Monitor

		bsr		CloseWin

.Error1		bsr		Closelibs
		
.done		moveq.l		#0,d0
		rts

		*****************************************
		*        Monitor IDCMP Messages		*
		*****************************************

Monitor		move.l		win.up,a0		a0->port
		CALLEXEC	WaitPort		wait for message
		move.l		win.up,a0		a0->port
		CALLEXEC	GetMsg			get message
		tst.l		d0			bogus ?
		beq.s		Monitor			yep! ignore it

		move.l		d0,a1			a1->Message
		move.l		im_Class(a1),d2		get IDCMP value
		move.w		im_MouseX(a1),d3	X
		move.w		im_MouseY(a1),d4	Y
		CALLEXEC	ReplyMsg		reply
		
		cmp.l		#MOUSEMOVE,d2		mouse moved?
		bne.s		.TestWin		no, skip
		bsr		CheckMouse		else test it
		bra.s		Monitor			and loop
		
.TestWin	cmp.l		#CLOSEWINDOW,d2		close?
		bne.s		Monitor			no, loop!
		rts					else exit

		*****************************************
		*        Monitor Mouse Movements	*
		*****************************************

CheckMouse	move.w		d3,d0			x coord
		move.w		d4,d1			y coord
		lea		WindowZones,a0		zone table
		bsr		_GetZone

		lea		ZoneText,a0		a0->format string
		move.l		d0,ZoneDS		write zone number
		bne.s		.InZone
		lea		NoZoneText,a0		a0->format string

.InZone		lea		ZoneDS,a1		Data Stream
		lea		ZoneBuffer,a2		buffer
		bsr		_SPrintF
		
		move.l		win.rp,a0		RastPort
		lea		ZoneIText,a1		IntuiText
		moveq.l		#0,d0			X offset
		move.l		d0,d1			Y offset
		CALLINT		PrintIText		print it

		rts

		*****************************************
		*	Display Graphics in Window	*
		*****************************************

DoGfx		lea		WindowGraf,a0
		move.l		win.rp,a1
		bsr		_WinGfx
		
		rts

		*****************************************
		*     Display Initial Requestor		*
		*****************************************

ShowReq		lea		BodyText,a1		gadget text
		lea		GadgetText,a2		text for buttons
		suba.l		a3,a3			no special info
		suba.l		a4,a4			no arg array
		suba.l		a0,a0			no tags
		CALLREQ		rtEZRequestA		display requester
		
BREAK		rts

		*****************************************
		*	  Open Intuition Window		*
		*****************************************

OpenWin		lea		Win,a0			a0->NewWindow
		CALLINT		OpenWindow		open it
		move.l		d0,win.ptr		save pointer
		beq.s		.done
		
		move.l		d0,a0			a0->Window
		move.l		wd_RPort(a0),win.rp	save RastPort
		move.l		wd_UserPort(a0),win.up	Save UserPort

.done		rts

		*****************************************
		*	  Close Intuition Window	*
		*****************************************

CloseWin	move.l		win.ptr,a0
		CALLINT		CloseWindow
		rts

		*****************************************
		*	  Open Required Libraries	*
		*****************************************

; Open Reqtools library.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		reqname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_reqBase		save base ptr

; reqtools opens DOS, Intuition and Graphics libraries and we can use the
;base pointers stored in it's base structure :-)

		move.l		d0,a0			a0->library base
		move.l		rt_IntuitionBase(a0),_IntuitionBase
		move.l		rt_GfxBase(a0),_GfxBase
		move.l		rt_DOSBase(a0),_DOSBase

.lib_error	rts

		*****************************************
		*	  Close All Libraries		*
		*****************************************

; Closes any libraries the program managed to open.

Closelibs	move.l		_reqBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts

		*****************************************
		*	  Include Subroutine Files	*
		*****************************************

		include		WinGfx.i
		include		Zone.i
		include		SPrintF.i

		*****************************************
		*	  Initialised Data		*
		*****************************************

reqname		dc.b		'reqtools.library',0
		even

BodyText	dc.b		'Click below to see zones',0
		even

GadgetText	dc.b		'Draw Zones',0
		even

NoZoneText	dc.b		'In Zone: None',0
		even

ZoneText	dc.b		'In Zone: %ld   ',0
		even

Win		dc.w		70,20
		dc.w		460,160
		dc.b		0,1
		dc.l		MOUSEMOVE+CLOSEWINDOW
		dc.l		WINDOWCLOSE+WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+ACTIVATE+RMBTRAP+NOCAREREFRESH+REPORTMOUSE
		dc.l		0
		dc.l		0
		dc.l		.Name
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

.Name		dc.b		'Test: Zones.i , WinGfx.i and SPrintF.i',0
		even

ZoneIText	dc.b		1,0,RP_JAM2,0
		dc.w		219,14
		dc.l		0
		dc.l		ZoneBuffer
		dc.l		0

WindowZones	dc.w		10,10,50,50
		dc.w		10,60,400,100
		dc.w		218,32,324,42
		dc.w		68,32,174,42
		dc.l		-1

WindowGraf	dc.l		1,2			pen 2
		dc.l		2,218,22		move to (218,22)
		dc.l		3,218,12		draw to (218,12)
		dc.l		3,324,12		draw to (324,12)
		dc.l		1,1			pen 1
		dc.l		3,324,22		draw to (324,22)
		dc.l		3,218,22		draw to (218,22)
		
		dc.l		1,1			pen 1
		dc.l		5,10,10,50,50		rectangle 1 gfx
		dc.l		1,2			pen 2
		dc.l		5,10,60,400,100		rectangle 2 gfx

		dc.l		1,2			pen 2
		dc.l		2,218,42		move to (218,42)
		dc.l		3,218,32		draw to (218,32)
		dc.l		3,324,32		draw to (324,32)
		dc.l		1,1			pen 1
		dc.l		3,324,42		draw to (324,42)
		dc.l		3,218,42		draw to (218,42)
		dc.l		1,3			pen 3
		dc.l		5,219,33,323,41		rectangle 3 gfx

		dc.l		1,2			pen 2
		dc.l		2,68,42			move to (68,42)
		dc.l		3,68,32			draw to (68,32)
		dc.l		3,174,32		draw to (174,32)
		dc.l		1,1			pen 1
		dc.l		3,174,42		draw to (174,42)
		dc.l		3,68,42			draw to (68,42)
		dc.l		1,3			pen 3

		dc.l		0			all done!
		
		*****************************************
		*	  Uninitialised Data		*
		*****************************************

		section		vars,BSS

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_reqBase	ds.l		1

win.ptr		ds.l		1
win.rp		ds.l		1
win.up		ds.l		1

ZoneDS		ds.l		1
ZoneBuffer	ds.b		50



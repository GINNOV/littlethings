
; Another device usage example. This time it's the printer. This program
;will dump the contents of the currently active screen to the printer.

; Of course this will only work if you have a printer capable of graphics
;printing ( such as a Star LC10 ). 

; M.Meany, March 91.

; Here is an outline of the IODRPReq fields you need to initialise

;	io_Command		set to PRD_DUMPRPORT
;	io_RastPort		pointer to rastport 
;	io_ColorMap		pointer to required colormap
;	io_Modes		video display modes ( from vp_Modes )
;	io_SrcX			x offset into rastport
;	io_SrcY			y offset into rastport
;	io_SrcWidth		num of screen pixels to print from io_SrcX
;	io_SrcHeight		num of screen lines to print after io_SrcY
;	io_DestCols		width of dump in printer pixels
;	io_DestRows		Height of dump in printer lines
;	io_Special		special flags ( aspect control etc )


		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		intuition/intuition_lib.i
		include		intuition/intuitionbase.i
		include		intuition/intuition.i
		include		libraries/dos_lib.i
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		devices/printer.i

;--------------	Open the DOS library

		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		error

;--------------	Open Intuition. No Intuition functions are called, but a
;		pointer is obtained from IntuitionBase to the currently
;		active screen.

		lea		intname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_IntuitionBase
		beq		error1
	
;--------------	Initialise a port to use with printer device

		lea		MyPortName,a0	name for port ( public )
		moveq.l		#0,d0		priority
		bsr		CreatePort	get a port
		move.l		d0,MyPort	save its address

;--------------	Initialise printer io structure

		lea		print_io,a5		io request
		move.l		d0,MN_REPLYPORT(a5)	port addr
		move.w		#PRD_DUMPRPORT,IO_COMMAND(a5)	command write

;--------------	A pointer to the currently active screen is obtained from
;		Intuition Base. From this structure it is possible to pull
;		the data required in the IODRPReq structure.
		
		move.l		_IntuitionBase,a1
		move.l		ib_ActiveScreen(a1),a1	a1->screen
		lea		sc_RastPort(a1),a0
		move.l		a0,io_RastPort(a5)
		lea		sc_ViewPort(a1),a0	a0->viewport
		move.l		vp_ColorMap(a0),io_ColorMap(a5)
		move.l		vp_Modes(a0),io_Modes(a5)
		move.w		#0,io_SrcX(a5)
		move.w		#0,io_SrcY(a5)
		move.w		sc_Width(a1),io_SrcWidth(a5)
		move.w		sc_Height(a1),io_SrcHeight(a5)
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
		bne		error2		leave if not
		
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

		move.l		MyPort,a0
		bsr		DeletePort

;--------------	Close Intuition

error2		move.l		_IntuitionBase,a1
		CALLEXEC	CloseLibrary
		
;--------------	Close DOS

error1		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary
		
;--------------	And finish

error		rts

		Include		source:subroutines/exec_support.i


dosname		DOSNAME
		even
_DOSBase	dc.l		0

intname		INTNAME
		even
_IntuitionBase	dc.l		0

printername	dc.b		'printer.device',0
		even

MyPortName	dc.b		'Meanys-Port',0
		even

print_io	ds.l		iodrpr_SIZEOF	printer IO request block

MyPort		ds.l		1		pointer to initialised port



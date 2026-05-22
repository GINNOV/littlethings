
; All the basic routines required for gadget style utility programs. This
;starting code will assemble and run as is.

; © M.Meany, June 1991.

		opt 		o+

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"misc/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"
		

;*****************************************

CALLSYS    MACRO		;CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
*****************************************************************************

; The main routine that opens and closes things
;** OPENARP moved to front as it will print a message on the CLI then **
;**   return to easystart if it can't find the ARP library ,we don't  **
;**                need to do any error checking of our own           **

start		OPENARP				;use arp's own open macro
		movem.l		(sp)+,d0/a0	;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt
						;stack

		move.l		a6,_ArpBase	;store arpbase
		
;--------------	the ARP library opens and uses the graphics and intuition 
;		libs and it is quite legal for us to get these bases for 
;		our own use

		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GFXBase(a6),_GfxBase

		bsr.s		Openwin		open window
		tst.l		d0		any errors?
		beq.s		no_win		if so quit

		bsr		WaitForMsg	wait for user

		bsr		Closewin	close our window

no_win		bsr		Closelibs	close open libraries

		rts				finish

;--------------
;-------------- Open An Intuition Window
;--------------

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

		move.l		window.rp,a0	rastport
		lea		WinText,a1	IntuiText
		moveq.l		#0,d0		x start
		move.l		d0,d1		y start
		CALLSYS		PrintIText	print it
		moveq.l		#1,d0		no errors

.win_error	rts				return

;--------------
;--------------	Deal with gadget selection.
;--------------

; At present only supports gadget selection. Address of routine to call
;when a gadget is selected should be stored in the gg_UserData field
;of that gadgets structure. All gadget service subroutines should set
;d2=0 to ensure accidental QUIT is not forced. If a QUIT gadget is used
;it should set d2=CLOSEWINDOW.


WaitForMsg	move.l		window.up,a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.up,a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure
		CALLSYS		ReplyMsg	answer os or it get angry

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		.test_win
		move.l		gg_UserData(a5),a0
		jsr		(a0)

.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		WaitForMsg	 if not then jump
		rts

;--------------
;-------------- Close the Intuition window.
;--------------

Closewin	move.l		window.ptr,a0
		CALLINT		CloseWindow
		rts

;--------------
;-------------- Close ARP library
;--------------

; Closes any libraries the program managed to open.

Closelibs	move.l		_ArpBase,a1		a1=base ptr
		CALLEXEC	CloseLibrary		close lib

		rts


*****************************************************************************
*			Data Section					    *
*****************************************************************************

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************


MyWindow	dc.w		101,9
		dc.w		400,190
		dc.b		1,2
		dc.l		GADGETDOWN+GADGETUP+CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
		dc.l		0		;gadgets
		dc.l		0
		dc.l		WindowName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

WindowName	dc.b		' Test ',0
		even


WinText		dc.b		1
		dc.b		0
		dc.b		RP_JAM2
		dc.b		0
		dc.w		10
		dc.w		15
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Utility set up text :',0
		even
;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_ArpBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1


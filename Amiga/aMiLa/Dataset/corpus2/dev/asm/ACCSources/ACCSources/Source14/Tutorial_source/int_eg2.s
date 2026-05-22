
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
		include		"source:include/arpbase.i"

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

; Test for either gadget up or gadget down events. If one has occurred , get
;the address of appropriate subroutine from gadget structure and call it.

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		.test_win
		move.l		gg_UserData(a5),d0
		beq		.test_win
		move.l		d0,a0
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


MyWindow	dc.w		100,9
		dc.w		400,190
		dc.b		1,2
		dc.l		GADGETDOWN+GADGETUP+CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH+WINDOWSIZING
		dc.l		CancelGadg		;gadgets
		dc.l		0
		dc.l		WindowName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

WindowName	dc.b		' Test ',0
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

;***********************************************************
;		GADGET  SPECIFIC CODE AND DATA
;***********************************************************

		section		GadgSrc,code

;--------------	The Subroutines Grouped Together.


Cancel		move.l		#CLOSEWINDOW,d2
		rts


GoRed		move.l		window.ptr,a0		a0->the window
		CALLINT		ViewPortAddress		get addr of ViewPort
		move.l		d0,a0			a0->ViewPort
		moveq.l		#0,d0			d0=WBench background
		moveq.l		#$f,d1			max RED component
		moveq.l		#0,d2			no GREEN
		moveq.l		#0,d3			no BLUE
		CALLGRAF	SetRGB4
		moveq.l		#0,d2			ensure no quit
		rts


GoBlue		move.l		window.ptr,a0		a0->the window
		CALLINT		ViewPortAddress		get addr of ViewPort
		move.l		d0,a0			a0->ViewPort
		moveq.l		#0,d0			d0=WBench background
		moveq.l		#0,d1			no RED
		moveq.l		#0,d2			no GREEN
		moveq.l		#$f,d3			max BLUE component
		CALLGRAF	SetRGB4
		moveq.l		#0,d2			ensure no quit
		rts


;--------------	The gadget structures

CancelGadg:
	dc.l	RedGadg		next gadget
	dc.w	29,24		origin XY of hit box relative to window TopLeft
	dc.w	78,13		hit box width and height
	dc.w	GADGHBOX	gadget flags
	dc.w	RELVERIFY	activation flags
	dc.w	BOOLGADGET	gadget type flags
	dc.l	.Border		gadget border or image to be rendered
	dc.l	0		alternate imagery for selection
	dc.l	.IText		first IntuiText structure
	dc.l	0		gadget mutual-exclude long word
	dc.l	0		SpecialInfo structure
	dc.w	0		user-definable data
	dc.l	Cancel		address of subroutine to call on selection

.Border
	dc.w	-2,-1		XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM1	front pen, back pen and drawmode
	dc.b	5		number of XY vectors
	dc.l	.Vectors	pointer to XY vectors
	dc.l	0		next border in list

.Vectors
	dc.w	0,0
	dc.w	81,0
	dc.w	81,14
	dc.w	0,14
	dc.w	0,0

.IText
	dc.b	1,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
	dc.w	16,3		XY origin relative to container TopLeft
	dc.l	0		font pointer or 0 for default
	dc.l	.String		pointer to text
	dc.l	0		next IntuiText structure

.String
	dc.b	'CANCEL',0
	even


RedGadg:
	dc.l	BlueGadg	next gadget
	dc.w	120,50		origin XY of hit box relative to window TopLeft
	dc.w	78,13		hit box width and height
	dc.w	GADGHBOX	gadget flags
	dc.w	RELVERIFY	activation flags
	dc.w	BOOLGADGET	gadget type flags
	dc.l	.Border		gadget border or image to be rendered
	dc.l	0		alternate imagery for selection
	dc.l	.IText		first IntuiText structure
	dc.l	0		gadget mutual-exclude long word
	dc.l	0		SpecialInfo structure
	dc.w	0		user-definable data
	dc.l	GoRed		pointer to user-definable data

.Border
	dc.w	-2,-1		XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM1	front pen, back pen and drawmode
	dc.b	5		number of XY vectors
	dc.l	.Vectors	pointer to XY vectors
	dc.l	0		next border in list

.Vectors
	dc.w	0,0
	dc.w	81,0
	dc.w	81,14
	dc.w	0,14
	dc.w	0,0

.IText
	dc.b	1,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
	dc.w	16,3		XY origin relative to container TopLeft
	dc.l	0		font pointer or 0 for default
	dc.l	.String		pointer to text
	dc.l	0		next IntuiText structure

.String
	dc.b	' RED ',0
	even



BlueGadg:
	dc.l	0		next gadget
	dc.w	120,80		origin XY of hit box relative to window TopLeft
	dc.w	78,13		hit box width and height
	dc.w	GADGHBOX	gadget flags
	dc.w	RELVERIFY	activation flags
	dc.w	BOOLGADGET	gadget type flags
	dc.l	.Border		gadget border or image to be rendered
	dc.l	0		alternate imagery for selection
	dc.l	.IText		first IntuiText structure
	dc.l	0		gadget mutual-exclude long word
	dc.l	0		SpecialInfo structure
	dc.w	0		user-definable data
	dc.l	GoBlue		pointer to user-definable data

.Border
	dc.w	-2,-1		XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM1	front pen, back pen and drawmode
	dc.b	5		number of XY vectors
	dc.l	.Vectors	pointer to XY vectors
	dc.l	0		next border in list

.Vectors
	dc.w	0,0
	dc.w	81,0
	dc.w	81,14
	dc.w	0,14
	dc.w	0,0

.IText
	dc.b	1,0,RP_JAM2,0	front and back text pens, drawmode and fill byte
	dc.w	16,3		XY origin relative to container TopLeft
	dc.l	0		font pointer or 0 for default
	dc.l	.String		pointer to text
	dc.l	0		next IntuiText structure

.String
	dc.b	' BLUE',0
	even



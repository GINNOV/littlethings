;Tab Setting = 12


	Incdir	sys:Include/
	Include	exec/exec_lib.i
	Include	intuition/intuition.i
	Include	intuition/intuition_lib.i

;Open the intuition library
	lea	intname,a1
	moveq.l	#0,d0		
	CALLEXEC	OpenLibrary
	beq	error
	move.l	d0,_IntuitionBase

;The routine to open the window
	lea	windowdata,a0		; A0=Window data structure
	CALLINT	OpenWindow		; Open the window
	move.l	d0,window.ptr		; Save add of int struct
	beq	error			; leave if addr was 0

;Find and then save pointer to UserPort
	move.l	d0,a0			; Pointer to window in a0
	move.l	wd_UserPort(a0),window.up ; Offset for user port

;Set-up a menu
	move.l	window.ptr,a0		; Pointer to window 
	lea	menu,a1			; Address of menu struc in a0
	CALLINT	SetMenuStrip		; Call the set menu function

;Event loop
Loop	move.l	window.up,a0		; a0=Port
	CALLEXEC	WaitPort	; Wait for msg
	move.l	window.up,a0		; A0=Port
	CALLEXEC	GetMsg		; Get address of msg
	move.l	d0,a1			; A1=Message struc
	move.l	im_Class(a1),d5		; D5=IDCMP flag
	CALLEXEC	ReplyMsg	; answer intuition

;Find out what the message meant
	cmpi.l	#CLOSEWINDOW,d5		; close gadet?
	bne	Loop			; Loop back if not
	
;Clear the menus
	move.l	window.ptr,a0		; Pointer to window in a0
	CALLINT	ClearMenuStrip		; Clear the menu

;Close gadget must have been pressed
	move.l	window.ptr,a0		; A0=Window struc
	CALLINT	CloseWindow		; close window


;Close the intuition library
	move.l	_IntuitionBase,a1	; Lib base address in a0
	CALLEXEC	CloseLibrary	; Close lib
error	rts


;Variables
intname	dc.b	'intuition.library',0
	even
_IntuitionBase	dc.l	0

window.ptr	dc.l	0
window.up	dc.l	0

;The Window Structure
windowdata	dc.w	0,10
	dc.w	640,189
	dc.b	-1,-1
	dc.l	CLOSEWINDOW
	dc.l	WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+SIZEBRIGHT+ACTIVATE+NOCAREREFRESH
	dc.l	0
	dc.l	0
	dc.l	WindowName
	dc.l	0
	dc.l	0
	dc.w	50,50
	dc.w	640,256
	dc.w	WBENCHSCREEN

WindowName	dc.b	'Raistlins Window',0
	even

;The Menu Structure
menu
	dc.l	0			; Pointer to next menu 
	dc.w	10,30			; X Y pos of menu strip
	dc.w	50,10			; Width Height of menu
	dc.w	1			; Availiable flag
	dc.l	menutxt			; Pointer to title for menu
	dc.l	menuitem01		; Pointer to Items for menu
	dc.w	0,0,0,0			; Don't know
menutxt	dc.b	'Raist menu',0		; Title of menu

	even

menuitem01	
	dc.l	0			; Pointer to next item
	dc.w	0,0			; X Y Posistion of an entry
	dc.w	130,12			; Width & height in pixels
	dc.w	ITEMTEXT+COMMSEQ+ITEMENABLED+HIGHCOMP ; Mode flag
	dc.l	0			; Not sure
	dc.l	text01			; Pointer to name of item
	dc.l	0			; Any highlighting
	dc.b	'A'			; Short cut key
	even				
	dc.l	0			; Pointer to submenu structure
	dc.w	0			; For Intuition
text01	dc.b	2,1			; Colours for text
	dc.b	0			; Mode :Overwrite
	even				
	dc.w	5,3			; X Y posistion
	dc.l	0			; Character set
	dc.l	text01txt		; Pointer to text
	dc.l	0			; Not sure
text01txt
	dc.b	'Hello!',0		; Text

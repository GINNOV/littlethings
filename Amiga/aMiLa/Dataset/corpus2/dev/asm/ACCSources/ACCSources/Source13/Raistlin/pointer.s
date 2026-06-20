; These is a teensy weency program to set-up a window in intuition
; with a custom mouse pointer.  Please remember that the pointer is a
; sprite and so needs chip mem (I forgot & it took me 15 mins to figure
; out why the program wasn't working!!!!)

; Treebeard has got some AMAZING programs under construction that take
; use of intuition, Exec, etc.  I'll see if he'll let me send 'em next
; month (Hes very modest you see! -just like me really!)


;Tab Setting = 12




;Those ever long disc access' to the includes	-Boring!
	Incdir	sys:Include/
	Include	exec/exec_lib.i
	Include	intuition/intuition.i
	Include	intuition/intuition_lib.i

;Open the intuition library		; How exiting!
	lea	intname,a1		; Address of library name
	moveq.l	#0,d0			; Any version (I'm nee fussy)
	CALLEXEC	OpenLibrary	; Open Intuition
	beq	error			; Was there an error?
	move.l	d0,_IntuitionBase	; Save int lib base

;The routine to open the window
	lea	windowdata,a0		; A0=Window data structure
	CALLINT	OpenWindow		; Open the window
	move.l	d0,window.ptr		; Save add of int struct
	beq	error			; leave if addr was 0

;Find and then save pointer to UserPort
	move.l	d0,a0			; Window pointer in a0
	move.l	wd_UserPort(a0),window.up	

;Activate my mouse pointer
	move.l	window.ptr,a0		; A0=pointer to window
	move.l	#Sprite,a1		; A1=pointer to sprite
	move.l	#17,d0			; D0=Height of sprite
	move.l	#16,d1			; D1=Width of sprite
	move.l	#0,d2			; D2=Hot Spot x offset
	move.l	#0,d3			; D3=Hot Spot y offset
	CALLINT	SetPointer		; Library Call

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
	
;Clear the mouse pointer
	move.l	window.ptr,a0		;Address of window
	CALLINT	ClearPointer		;Clear the pointer

;Close gadget must have been pressed
	move.l	window.ptr,a0		; A0=Window struc
	CALLINT	CloseWindow		; close window


;Close the intuition library
	move.l	_IntuitionBase,a1		; Lib base address in a0
	CALLEXEC	CloseLibrary	; Close lib
error	rts


;Variables
intname	dc.b	'intuition.library',0
	even
_IntuitionBase	dc.l	0

window.ptr	dc.l	0
window.up	dc.l	0

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




;Sprite Data Structure
	Section	Sprites_need_chip,code_c

Sprite	dc.w	$0000,$0000	SPRxPOS,SPRxCTL
	dc.w	$ffff,$ffff
	dc.w	$aa49,$aa49
	dc.w	$ce4d,$ce4d
	dc.w	$aa45,$aa45
	dc.w	$aaed,$ffff
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$f79e,$f790
	dc.w	$441e,$4400
	dc.w	$4798,$4784
	dc.w	$4098,$4082
	dc.w	$f780,$f783
	dc.w	$0000,$0001
	dc.w	$eee8,$eee8
	dc.w	$8aa8,$8aa8
	dc.w	$8aa8,$8aa8
	dc.w	$eeee,$eeee
	dc.w	$0000,$0000	Sprite End	

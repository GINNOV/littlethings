
; Program to attatch a console device to an Intuition window for text
;input and output. Idea taken from Reference Manual: Libraries and Devices
;page 648. © 1990, M.Meany.

		opt 		o+,ow-

;		incdir		"ACC-Source:include/"
		incdir		vd0:include/
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"exec/ports.i"
		include		"devices/console_lib.i"
		include		"devices/inputevent.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"misc/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"
		
ciaapra		equ		$bfe001
NULL		equ		0

;*****************************************

CALLSYS    MACRO		;added CALLSYS macro - using CALLARP
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

start		OPENARP				
		movem.l		(sp)+,d0/a0


		move.l		a6,_ArpBase
		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GfxBase(a6),_GfxBase

;--------------	Create a reply port for writing to console

bp1		lea		con_out_name,a0
		moveq.l		#0,d0
		CALLARP		CreatePort
		move.l		d0,WritePort
		beq		error1

;--------------	Attatch this to a standard io request block

		lea		WriteReqBlock,a0
		move.l		d0,MN_REPLYPORT(a0)

;--------------	Create a reply port for reading from console

		lea		con_in_name,a0
		moveq.l		#0,d0
		CALLARP		CreatePort
		move.l		d0,ReadPort
		beq		error2

;--------------	Attatch this to a standard io request block

		lea		ReadReqBlock,a0
		move.l		d0,MN_REPLYPORT(a0)

;--------------	Open an intuition window

		lea		test_window,a0
		CALLINT		OpenWindow
		move.l		d0,window.ptr
		beq		error3
		move.l		d0,a0
		move.l		wd_UserPort(a0),window.up

;-------------- Open the console device, attatched to window.

; First attatch window to write io block

		lea		WriteReqBlock,a1
		move.l		d0,IO_DATA(a1)
		move.l		#wd_Size,IO_LENGTH(a1)

; Now open the device, a1 already points to io block. OpenDevice returns
;a zero value in d0 if all went well, else an error number.
		
		lea		console_name,a0
		moveq.l		#0,d0
		moveq.l		#0,d1
		CALLEXEC	OpenDevice
		move.l		d0,d0
		bne		error4
		
; Now attatch console device to read io block.
		
		lea		WriteReqBlock,a0
		lea		ReadReqBlock,a1
		move.l		IO_DEVICE(a0),IO_DEVICE(a1)
		move.l		IO_UNIT(a0),IO_UNIT(a1)
		
;-------------------------------------------------------------------------

		move.l		#msg1,d0
		bsr		ConPut

;--------------	Wait for close gadget to be hit

WaitForMsg	move.l		window.up,a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.up,a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		CALLEXEC	ReplyMsg	answer os or it get angry
		cmp.l		#CLOSEWINDOW,d2	window closed ?
		bne.s		WaitForMsg	if not wait some more


;-------------------------------------------------------------------------

;--------------	Close the console device

		lea		WriteReqBlock,a1
		CALLEXEC	CloseDevice
		
;--------------	Close the window

error4		lea		window.ptr,a1
		CALLINT		CloseWindow
		
;--------------	Close the read port

error3		move.l		ReadPort,a1
		CALLARP		DeletePort
		
;--------------	Close the write port

error2		move.l		WritePort,a1
		CALLARP		DeletePort
		
;--------------	Close the ARP Library

error1		move.l		_ArpBase,a1
		CALLEXEC	CloseLibrary

;--------------	And finish

		rts

***********************************
;-------------	Subroutines
***********************************

;--------------	Write a string of chars to the window.

;Entry		d0=address of null terminated character string

ConPut		lea		WriteReqBlock,a0
		move.l		#CMD_WRITE,IO_COMMAND(a0)
		move.l		d0,IO_DATA(a0)
		move.l		#-1,IO_LENGTH(a0)
		CALLEXEC	DoIO
		rts

***********************************
;-------------	DATA
***********************************

con_out_name	dc.b	'marks.console.out',0
		even
con_in_name	dc.b	'marks.console.in',0
		even

console_name	dc.b	'console.device',0
		even

msg1		dc.b	'Does this work ????',$0a,0
		even

test_window	dc.w	10,10		x,y of top left corner
		dc.w	620,180		width,height
		dc.b	-1,-1		default pens
		dc.l	CLOSEWINDOW	IDCMP flags
		dc.l	WINDOWDEPTH!WINDOWSIZING!WINDOWDRAG!WINDOWCLOSE!SMART_REFRESH!ACTIVATE
		dc.l	0		no gadgets
		dc.l	0		no user checkmark
		dc.l	win.name	pointer to title
		dc.l	0		screen pointer
		dc.l	0		bitmap pointer
		dc.w	100,45		min width, height
		dc.w	640,200		max width,height
		dc.w	WBENCHSCREEN	on WB screen
		
win.name	dc.b	'Page 648 of Libraries and Devices, M.Meany',0
		even
		
		section ports,bss

_ArpBase	ds.l	1
_IntuitionBase	ds.l	1
_GfxBase	ds.l	1

window.ptr	ds.l	1
window.up	ds.l	1
WritePort	ds.l	1
ReadPort	ds.l	1

WriteReqBlock	ds.b	IOSTD_SIZE
		even
ReadReqBlock	ds.b	IOSTD_SIZE
		even

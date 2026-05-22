
; Program to attach a console device to an Intuition window for text
;input and output. Idea taken from Reference Manual: Libraries and Devices
;page 648. © 1990, M.Meany.

		opt 		o+

; I have now moved all my include files to a separate disk called 'Include'
; This frees up a lot of room on my Devpac disk and is much more convenient.
; I can now always find my includes with the following incdir. 
		incdir		sys:include/
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"exec/ports.i"
		include		"devices/console_lib.i"
		include		"devices/inputevent.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		incdir		source9:include/
		include		"misc/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"sys:include/misc/easystart.i"
		
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
		
;--------------	Open an intuition window

		lea		test_window,a0
		CALLINT		OpenWindow
		move.l		d0,window.ptr
		beq		error1
		move.l		d0,a0
		move.l		wd_UserPort(a0),window.up

;--------------	Create a reply port for writing to console

bp1		lea		con_out_name,a0
		moveq.l		#0,d0
		CALLARP		CreatePort
		move.l		d0,WritePort
		beq		error2

;--------------	Attatch this to a standard io request block

		lea		WriteReqBlock,a0
		move.l		d0,MN_REPLYPORT(a0)

;--------------	Create a reply port for reading from console

		lea		con_in_name,a0
		moveq.l		#0,d0
		CALLARP		CreatePort
		move.l		d0,ReadPort
		beq		error3

;--------------	Attatch this to a standard io request block

		lea		ReadReqBlock,a0
		move.l		d0,MN_REPLYPORT(a0)

;-------------- Open the console device, attatched to window.

; First attatch window to write io block

		lea		WriteReqBlock,a1
		move.l		window.ptr,IO_DATA(a1)
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
		bsr		ConPut			;print message
		
		move.l		#ControlSeq,d0		;set event types
		bsr		ConPut

;--------------	Wait for Input Events - and not a WaitPort in sight

WaitForMsg	
		bsr		ConRead			;wait for an event
		
		lea		ReadBuffer,a0		;get buffer address
		
		cmpi.b		#$9b,(a0)		;test for CSI
		bne.s		NotCSI			;no CSI do KB input
		
		move.l		(a0),d0			;get first long

		cmpi.l		#$9b31313b,d0		;CloseWindow ?
		beq		CleanUp			;branch if closewindow

		cmpi.l		#$9b31323b,d0		;NewSize ?
		bne.s		NotSize			;branch if not newsize
		bsr		NewSize			;do newsize
		bra.s		WaitForMsg		;get next event
		
NotSize
		cmpi.l		#$9b31303b,d0		;Menu ?
		bne.s		NotMenu			;branch if not menu
		bsr		DoMenu			;do menu
		bra.s		WaitForMsg		;get next event
		
NotMenu
		cmpi.l		#$9b323b30,d0		;mouse  ?
		bne.s		KeyDone			;branch if not mouse
		
		cmpi.l		#$3b313034,4(a0)	;mouse select down ?
		bne.s		KeyDone			;branch if not down
		
		bsr		DoMouse			;do mouse
		bra.s		WaitForMsg		;get next event
		
NotCSI	
;--------------	we will now assume that we have keyboard input
		cmpi.b		#$7f,(a0)		;check delete
		bne.s		NoDelete		;branch if not del
		move.l		#$9b500000,(a0)		;convert del
		bra.s		KeyDone
		
NoDelete
		cmpi.b		#$0d,(a0)		;test <Return>
		bne.s		NotReturn
		lea		Return(pc),a0		;correct return
		bra.s		KeyDone

NotReturn
		cmpi.b		#$08,(a0)		;test backspace
		bne.s		NotBackSpace
		move.l		#$089b5000,(a0)		;correct backspace
		bra.s		KeyDone

;--------------	should be printable chars, so count number of legal chars 
;		so we can insert them
NotBackSpace
		move.l		a0,-(sp)		;store a0 (buffer)
		moveq		#0,d0			;clear d0
Charloop
		tst.b		(a0)			;test for null terminator
		beq.s		CharDone		;quit if found
		
		cmpi.b		#$20,(a0)+		;test for printable char
		blt.s		Charloop		;loop if non printable
		
		addq.w		#1,d0			;bump char count
		bra.s		Charloop		;loop for next char
CharDone	
		move.w		d0,-(sp)		;push result onto stack
		lea		InsertString(pc),a0	;get format string
		bsr		sprintf			;create control string
		addq.l		#2,sp			;correct stack
		move.l		#String,d0		;get ctrl string
		bsr.s		ConPut			;and write to console
		move.l		(sp)+,a0		;restore a0
		
KeyDone
		move.l		a0,d0			;buffer to d0		
		bsr.s		ConPut			;put to window
		bra		WaitForMsg		;get next event
		
		
;-------------------------------------------------------------------------


CleanUp
;--------------	Close the console device

		lea		WriteReqBlock,a1
		CALLEXEC	CloseDevice
		
;--------------	Close the read port

error4		move.l		ReadPort,a1
		CALLARP		DeletePort
		
;--------------	Close the write port

error3		move.l		WritePort,a1
		CALLARP		DeletePort
		
;--------------	Close the window

error2		move.l		window.ptr,a0
		CALLINT		CloseWindow
		
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

ConPut		lea		WriteReqBlock,a1
		move.w		#CMD_WRITE,IO_COMMAND(a1)
		move.l		d0,IO_DATA(a1)
		move.l		#-1,IO_LENGTH(a1)
		CALLEXEC	DoIO
		rts
		
;--------------	Read input events from console

;Entry		None - just call. Works similar to WaitPort etc
;return		d0 = number of chars

ConRead		lea		ReadReqBlock,a1
		move.w		#CMD_READ,IO_COMMAND(a1)
		move.l		#ReadBuffer,IO_DATA(a1)
		move.l		#80,IO_LENGTH(a1)
		CALLEXEC	DoIO
		
;--------------	We will null terminate input for convenience
		lea		ReadReqBlock,a1
		move.l		IO_ACTUAL(a1),d0
		move.l		#ReadBuffer,a1
		move.b		#0,0(a1,d0)		
		rts
		
NewSize
		move.l		#msg2,d0
		bsr.s		ConPut
		rts
		
DoMenu
		move.l		#msg3,d0
		bsr.s		ConPut
		rts
		
DoRawKey
		move.l		#msg4,d0
		bsr.s		ConPut
		rts
		
DoMouse
		move.l		window.ptr,a0		;get window
		moveq		#0,d0			;clear d0
		moveq		#0,d1			;and d1
		move.w		wd_MouseX(a0),d0	;current mouse x pos
		move.w		wd_MouseY(a0),d1	;and y pos
		move.l		wd_RPort(a0),a0		;get rastport
		subq.w		#4,d0			;adjust for left border
		sub.w		#10,d1			;and title bar
		divu		rp_TxWidth(a0),d0	;divide by font width
		divu		rp_TxHeight(a0),d1	;and height
		addq.w		#1,d0			;correct for coord type
		addq.w		#1,d1			;ditto
		move.w		d0,-(sp)		;parameter onto stack
		move.w		d1,-(sp)		;ditto
		lea		CursorString(pc),a0	;get format string
		bsr.s		sprintf			;and create control string
		addq.l		#4,sp			;corect stack
		move.l		#String,d0		;get ctrl string
		bsr		ConPut			;output to console
		rts

;===========================================================
sprintf:
		lea		4(sp),a1
		lea		PutChar(pc),a2
		lea		String,a3
		CALLEXEC	RawDoFmt
		rts
	
PutChar:
		move.b		d0,(a3)+
		rts
		
;===========================================================

		
***********************************
;-------------	DATA
***********************************

con_out_name	dc.b	'marks.console.out',0
		even
con_in_name	dc.b	'marks.console.in',0
		even

console_name	dc.b	'console.device',0
		even

msg1		dc.b	'Does this work ????  - YES!!!',$0a,0
		even

msg2		dc.b	'Newsize Event ',$0a,0
		even		

msg3		dc.b	'Menu Event ',$0a,0
		even

msg4		dc.b	'Rawkey Event',$0a,0
		even

CursorString	dc.b	$9b,'%d',$3b,'%d',$48,0
		even

CSI		EQU	$9b

InsertString	dc.b	CSI,'%d',$40,0

ControlSeq	dc.b	CSI,'2;10;11;12{',0	;set event types

Return		dc.b	$0d,$0a,CSI,$4c,0

String		dcb.b	20,0
		EVEN


test_window	dc.w	10,10		x,y of top left corner
		dc.w	620,180		width,height
		dc.b	-1,-1		default pens
		dc.l	0		IDCMP flags
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

ReadBuffer	ds.b	82

WriteReqBlock	ds.b	IOSTD_SIZE
		even
ReadReqBlock	ds.b	IOSTD_SIZE
		even

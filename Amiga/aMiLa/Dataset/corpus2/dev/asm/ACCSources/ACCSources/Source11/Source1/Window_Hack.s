
; A little tester. This is one of them little WB Hacks. Just to show that
;each window is dealt with as a seperate entity by the same main body of
;routines. Hit the close gadget of the windows opened and a new window
;opens. Don't panic! the size gadget will close a window, but only the
;one. Keep opening windows and the system slows down to ST standards ( yes,
;a quick kick between the knees for all those  poor people, as if they never
;had enough to put up with ).

; Note that closing loads of windows rapidly will crash the system !!!

; Raistlin & Nipper, if you read this or the PPMuchMore source what about
;modifying your helper progs to support multiple windows ?

; Started 10/3/91 -- Finishes  10/3/91  ( A novelty in itself )

; This source is of course PD.

; © M.Meany 1991

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		incdir		source:include/
		include		"arpbase.i"
		include		"sys:include/misc/easystart.i"
		

;*****************************************

CALLSYS    MACRO		;added CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
*****************************************************************************

; The main routine that opens and closes things

start		OPENARP				;use arp's own open macro
		movem.l		(sp)+,d0/a0	;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt stack

		move.l		a6,_ArpBase	;store arpbase
		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GfxBase(a6),_GfxBase

		bsr		GoForIt		the program actual

;--------------	Close libraries and finish

		move.l		_ArpBase,a1	a1->base addr of arp.library
		CALLEXEC	CloseLibrary	and close it
		rts

**************************************************************************

;-------------- 
;--------------	Program proper starts here
;-------------- 

GoForIt		
		bsr		OpenPort	open port for IDCMP
		tst.l		d0		all ok ?
		beq.s		.error		leave if not

		bsr		OpenAWindow	opens window
		tst.l		d0		all ok ?
		beq.s		.error1		leave if not

		bsr		WaitOnUser	deal with user interaction
.error1		bsr		ClosePort	close IDCMP port
.error		rts				and leave

;-------------- 
;-------------- Open a port to recieve IDCMP from the windows
;-------------- 

;-------------- Create a port

OpenPort	lea		MyPortName,a0	a0->name for port
		moveq.l		#20,d0		d0=ports priority
		bsr		CreatePort	and get a port
		move.l		d0,MyPort	save its address
		rts				and return


;--------------	
;--------------	Open a window
;--------------	


; Note that a port must already be created and it's address stored at
;MyPort. This is attached to the user port field of the window after
;creation.

; M.Meany 10/3/91

OpenAWindow	lea		MyWindow,a0
		CALLINT		OpenWindow
		tst.l		d0
		beq.s		.error
		move.l		d0,a0

;--------------	Attach a user port

		move.l		MyPort,wd_UserPort(a0)

;--------------	Set IDCMP flags

		move.l		#CLOSEWINDOW!NEWSIZE,d0
		CALLINT		ModifyIDCMP

;--------------	This bit is just for this hack !!!

		add.l		#$00050005,MyWindow

;--------------	All went ok so set d0 ( d0=0 => an error )

		moveq.l		#1,d0
		add.l		d0,StillHere

.error		rts




;-------------- 
;-------------- Deal with user interaction
;-------------- 

; First wait for a message to arrive at MyPort.

WaitOnUser	move.l		MyPort,a0	a0-->window user port
		CALLEXEC	WaitPort	wait for something to happen

; Message arrived, so get its address

		move.l		MyPort,a0	a0-->window user port
		CALLSYS		GetMsg		get any messages

; If no address returned this was a bogus message, ignore it.

		tst.l		d0		was there a message ?
		beq		WaitOnUser	if not loop back

; Obtain message class and message source from message structure returned.

		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure
		move.l		im_IDCMPWindow(a1),a4 a4=ptr to window

; Answer the message now.

		CALLSYS		ReplyMsg	answer o/s or it gets angry

; Check if user has hit close gadget on either window

		cmp.l		#CLOSEWINDOW,d2	 flag=CLOSEWINDOW ?
		bne.s		.test_resize	 if not jump
		bsr		OpenAWindow	 else open a new window
		bra		WaitOnUser		

.test_resize	cmp.l		#NEWSIZE,d2	flag=NEWSIZE ?
		bne.s		WaitOnUser	loop back if not

; If we get here, user has re sized the window. Close this window.

		move.l		a4,a0		a0->window
		bsr		CloseWinSafe	close the window
		sub.l		#1,StillHere	decrease window count
		bne.s		WaitOnUser	if win still open, loop

; Control passes to this point when user has closed all windows

done		rts				 finish

;-------------- 
;--------------	Delete the port
;-------------- 


;--------------	If pointer to port exsists, delete the port

ClosePort	move.l		MyPort,d0	d0=addr of port
		beq		.ok		quit if not set
		move.l		d0,a0		a0->port
		bsr		DeletePort	and delete it

.ok		rts				all done so return


;--------------	
;--------------	A routine that safely closes a window
;--------------	

; Before closing a window that shares a port, it is necessary to reply
;to all outstanding messages. This routine is mercyless as it does not
;bother checking which window the messages were destined for. Once all
;the messages have been disposed of the port is detached from the window
;and the window is closed. To ensure no messages are generated while we 
;are doing this it is necessary to lock the system out using the hardware
;bashers favorite - Forbid ().

;Entry		a0 must point to an open windows structure

;Exit		nothing useful

;Corrupt	a0,a1,d0,d1

CloseWinSafe	CALLEXEC	Forbid		lock out system

;--------------	Reply all outstanding messages

		move.l		a0,-(sp)	save pointer to window
		
.loop		move.l		MyPort,a0	a0->port
		CALLEXEC	GetMsg		check for messages
		tst.l		d0		was there one ?
		beq.s		.no_msg		if not continue
		
		move.l		d0,a1		a1->message
		CALLEXEC	ReplyMsg	answer it
		bra		.loop		and go back for more

;--------------	Now Detach port from window

.no_msg		move.l		(sp)+,a0	retrieve window pointer
		move.l		#0,wd_UserPort(a0) and clear user port

;--------------	Close the window

		CALLINT		CloseWindow

;--------------	Wake up the OS

		CALLEXEC	Permit

;--------------	And finish

		rts


;--------------	
;--------------	Include Dave Edwards support subroutines
;--------------	

		include		df1:subroutines/exec_support.i

;--------------	
;--------------	Window Def's
;--------------	

MyWindow	dc.w		41,41
		dc.w		228,92
		dc.b		0,1
		dc.l		0
		dc.l		WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE
		dc.l		0
		dc.l		0
		dc.l		.WindowName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

.WindowName	dc.b		' !! Succer !! ',0
		even

;--------------	
;--------------	Port name ( the port is not private, so it must be named ).
;--------------	

MyPortName	dc.b		'M.Meanys-Port',0
		even

;--------------	
;--------------	Variables
;--------------	

		section	vars,BSS

_ArpBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

MyPort		ds.l		1
StillHere	ds.l		1


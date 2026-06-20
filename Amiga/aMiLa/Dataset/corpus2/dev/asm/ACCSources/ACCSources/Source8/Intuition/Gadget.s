
; Gadget Example Source. Uses ARP library, so ARP include files should
;be in the include/misc directory of your Devpac work disc and arp.library
;should be in the libs: directory of the same disc and any disc you wish 
;to run the assembled program from.

; M.Meany Jan 91

		incdir		"sys:include/"
;		incdir		vd0:include/
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

start		OPENARP				;use arp's own open macro
		movem.l		(sp)+,d0/a0	;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt stack
		move.l		a6,_ArpBase	;store arpbase
		
;--------------	the ARP library opens and uses the graphics and intuition 
;		libs and it is quite legal for us to get these bases for 
;		our own use

		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GfxBase(a6),_GfxBase

;--------------	Open the intuition window

		lea		window,a0
		CALLINT		OpenWindow
		move.l		d0,window.ptr
		beq		error1
				
;--------------	Determine address of this windows rastport and userport.
;		save these for later use.

		move.l		d0,a0
		move.l		wd_RPort(a0),window.rp
		move.l		wd_UserPort(a0),window.up
		
;--------------	Wait for a message to arrive and process it.

; First wait for a message to arrive at the windows user port.

WaitForMsg	move.l		window.up,a0	a0-->window user port
		CALLEXEC	WaitPort	wait for something to happen

; Message arrived, so get its address

		move.l		window.up,a0	a0-->window user port
		CALLEXEC	GetMsg		get any messages

; If no address returned this was a bogus message, ignore it.

		tst.l		d0		was there a message ?
		beq		WaitForMsg	if not loop back

; Obtain message class and message source from message structure returned.

		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure

; Answer the message now.

		CALLEXEC	ReplyMsg	answer o/s or it gets angry

; If message class was GADGETUP, a gadget has been selected. Jump to the
;gadget handaling code.

		cmp.l		#GADGETUP,d2
		beq		DoGadget

; If message class was CLOSEWINDOW user has hit the close window gadget
;on the window. If not then we ignore the message and loop back to wait for
;the next one to arrive.

		cmp.l		#CLOSEWINDOW,d2
		bne.s		WaitForMsg
		bra		done

; Message class was GADGETUP so a gadget has been selected. Register a5
;holds the address of the source of the message. This will be the gadget
;structure. We have stored the address of the subroutine to deal with 
;a gadgets selection in the UserData field, so now we retrieve this address
;and call the subroutine. This will work for any amount of gadgets of any
;type, providing you store the address of the appropriate subroutine to call
;in the UserData field. This is much simpler than the A & W way.

DoGadget	move.l		gg_UserData(a5),a0
		jsr		(a0)

; When the subroutine has finished control returns to this point, so branch
;back and wait for another message.

		bra		WaitForMsg
		
; If the windows close gadget was selected then control passes to this point.
;First the window is closed and the the ARP library is closed. The program
;then finishes.

done		move.l		window.ptr,a0
		CALLINT		CloseWindow
		
error1		move.l		_ArpBase,a1
		CALLEXEC	CloseLibrary
		
		rts
		
;--------------	Variables

_ArpBase	dc.l		0
_IntuitionBase	dc.l		0
_GfxBase	dc.l		0

window.ptr	dc.l		0
window.rp	dc.l		0
window.up	dc.l		0

;--------------	Window Defenition Data

		include		workdisk:intuition/window.s
		
;--------------	Gadget Defenition Data and Service Subroutine

; Remove the ; from the start of one of the following include lines.
;this will cause the appropriate data and code to be read in. Only
;remove ONE ; per assembly.

;		include		workdisk:intuition/boolean.s

;		include		workdisk:intuition/toggle.s

;		include		workdisk:intuition/string.s

;		include		workdisk:intuition/integer.s

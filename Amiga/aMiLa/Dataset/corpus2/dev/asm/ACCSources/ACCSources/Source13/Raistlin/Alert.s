; Program to display an Alert by Raistlin 1991


;Tab Setting 8

	incdir	sys:include/			; Set include directory
	include	intuition/intuition.i		; Include files
	include	intuition/intuition_lib.i
	include	exec/exec_lib.i	
	
;Open Intuition					; as it says
	move.l	#0,d0				; Any version
	lea	intname,a1			; Address of lib name
	CALLEXEC	OpenLibrary		; Open Intuition
	tst.l	d0				; Did it open
	beq	quit				; If not quit
	move.l	d0,_IntuitionBase		; Store int lib base
	
;Call the Alert					; Bring alert on screen
CALLALERT
	move.l	RECOVERY_ALERT,d0		; Not a fatal alert
	lea	string,a0			; address of info for text
	move.l	#50,d1				; Height of alert box
	CALLINT	DisplayAlert			; Display the alert

	cmpi.b	#0,d0				; Was RMB pressed?
	beq	CALLALERT			; If so redisplay Alert

	move.l	_IntuitionBase,a1		; Int lib base in a1
	CALLEXEC	CloseLibrary		; close intuition
quit	rts					; BYE!


;Variables			
_IntuitionBase	dc.l	0			; Pointer to intuition base address
intname	dc.b	'intuition.library',0	
	even
string	dc.w	160				; X pos of text 
	dc.b	25				; Y Pos of text
	dc.b	'MANCHESTER UNITED RULE O.K. !!!',0 ;Text -Null terminated
	dc.b	0				;No more text to follow


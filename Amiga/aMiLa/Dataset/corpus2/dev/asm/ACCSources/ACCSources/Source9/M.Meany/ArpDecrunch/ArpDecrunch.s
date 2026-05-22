
; Added imagery to About window. Picture original was done for me by Wizard
;of Pendle Europa. Cheers mate !



; Utility that allows user to load a powerpacked file and save the decrunched
;version. Loading and saving is done via ARP filerequester.

; Source © M.Meany Feb 1991

; This version : 3 Feb 91

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		intuition/intuition_lib.i
		include		intuition/intuition.i
		incdir		source9:include/
		include		ppbase.i
		include		powerpacker_lib.i
		include		"arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"df0:include/misc/easystart.i"
		
;*****************************************

CALLSYS    MACRO		;added CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
CALLNICO	Macro		Simplifies calling powerpacker.library
	move.l	_PPBase,a6	M.M
	jsr	_LVO\1(a6)
	endm
	
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

;-------------- Open PowerPacker library

		lea		pplibname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_PPBase
		beq		error1

;--------------	Initialise Variables Memory Block

; Get memory for variable storage

		move.l		#vars_SIZEOF,d0
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1
		CALLARP		ArpAllocMem
		move.l		d0,a4
		tst.l		d0
		beq		error2
		
; Initialise file requester structures

		move.l		#Requesterflags,d0
		
		lea		LoadFileStruct(a4),a0
		move.l		#LoadText,(a0)+
		lea		LoadFileData(a4),a1
		move.l		a1,(a0)+
		lea		LoadDirData(a4),a1
		move.l		a1,(a0)+
		addq.l		#4,a0
		move.b		d0,(a0)
		lea		LoadFileStruct(a4),a0
		lea		LoadPathName(a4),a1
		move.l		a1,fr_SIZEOF(a0)
		
		or.b		#FRF_DoColor,d0
		
		lea		SaveFileStruct(a4),a0
		move.l		#SaveText,(a0)+
		lea		SaveFileData(a4),a1
		move.l		a1,(a0)+
		lea		SaveDirData(a4),a1
		move.l		a1,(a0)+
		addq.l		#4,a0
		move.b		d0,(a0)
		lea		SaveFileStruct(a4),a0
		lea		SavePathName(a4),a1
		move.l		a1,fr_SIZEOF(a0)

;--------------	Open the main intuition window

		lea		window,a0
		CALLINT		OpenWindow
		move.l		d0,window.ptr(a4)
		beq		error2

;--------------	Determine address of this windows rastport and userport.
;		save these for later use.

		move.l		d0,a0
		move.l		wd_RPort(a0),window.rp(a4)
		move.l		wd_UserPort(a0),window.up(a4)

;-------------- Display two lines of basic info for familiar users.	

		move.l		window.rp(a4),a0
		lea		window_text,a1
		moveq.l		#0,d0
		move.l		d0,d1
		CALLSYS		PrintIText
		
;--------------	Wait for a message to arrive and process it.

; First wait for a message to arrive at the windows user port.

WaitForMsg	move.l		window.up(a4),a0	a0-->window user port
		CALLEXEC	WaitPort	wait for something to happen

; Message arrived, so get its address

		move.l		window.up(a4),a0	a0-->window user port
		CALLSYS		GetMsg		get any messages

; If no address returned this was a bogus message, ignore it.

		tst.l		d0		was there a message ?
		beq		WaitForMsg	if not loop back

; Obtain message class and message source from message structure returned.

		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure

; Answer the message now.

		CALLSYS		ReplyMsg	answer o/s or it gets angry

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

; When the subroutine has finished control returns to this point. If the
;QUIT gadget was hit then the Z flag will be set, else the Z flag will be
;clear. For this reason beq is used to determine if we need to branch
;back and wait for another message.

		beq		WaitForMsg
		
; If the windows close gadget was selected then control passes to this point.
;First the window is closed and the the ARP library is closed. The program
;then finishes.

done		move.l		window.ptr(a4),a0
		CALLINT		CloseWindow

;--------------	Check if buffer memory exsists, if so release it

		tst.l		buffer(a4)
		beq.s		error2
		move.l		buffer(a4),a1
		move.l		length(a4),d0
		CALLEXEC	FreeMem
		
;--------------	Close PowerPacker library

error2		move.l		_PPBase,a1
		CALLEXEC	CloseLibrary

;--------------	Close ARP library

error1		move.l		_ArpBase,a1
		CALLEXEC	CloseLibrary
		
;--------------	Finish

		rts
		
***************************************

;--------------	This subroutine is called when QUIT gadget is selected

; Clear the Z flag

Quit		moveq.l		#1,d0
		rts

;--------------	This subroutine is called when ABOUT gadget is selected

; First open the About window

About		lea		about_win,a0
		CALLINT		OpenWindow
		move.l		d0,about.ptr(a4)
		beq		error_n

; Determine address of this windows rastport and userport.
;		save these for later use.

		move.l		d0,a0
		move.l		wd_RPort(a0),about.rp(a4)
		move.l		wd_UserPort(a0),about.up(a4)

;--------------	Wait for a message to arrive and process it.

; First wait for a message to arrive at the windows user port.

WaitAbout	move.l		about.up(a4),a0	a0-->window user port
		CALLEXEC	WaitPort	wait for something to happen

; Message arrived, so get its address

		move.l		about.up(a4),a0	a0-->window user port
		CALLSYS		GetMsg		get any messages

; If no address returned this was a bogus message, ignore it.

		tst.l		d0		was there a message ?
		beq		WaitAbout	if not loop back

; Obtain message class from message structure returned.

		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags

; Answer the message now.

		CALLSYS		ReplyMsg	answer o/s or it gets angry

; If message class was GADGETUP, an OK  gadget has been selected. So quit

		cmp.l		#GADGETUP,d2
		bne		WaitAbout

; Message class was GADGETUP so a gadget has been selected. 

		move.l		about.ptr(a4),a0
		CALLINT		CloseWindow

error_n		moveq.l		#0,d0
		rts

;--------------	This subroutine is called when LOAD gadget is selected

; Check if a file is already loaded

Load		bsr		PointerOn
		tst.l		buffer(a4)
		beq.s		.ok

; If so free the memory it occupies ( ie scrap it )
		
		move.l		buffer(a4),a1
		move.l		length(a4),d0
		CALLEXEC	FreeMem
			
		move.l		#0,buffer(a4)

; Use ARP filerequester to get a filename, return if none specified

.ok		bsr.s		arpload
		beq.s		load_error

; Use powerpacker.library to load/decrunch the file

		lea		LoadPathName(a4),a0
		moveq.l		#DECR_POINTER,d0
		moveq.l		#0,d1
		lea		buffer(a4),a1
		lea		length(a4),a2
		move.l		d1,a3
		CALLNICO	ppLoadData
		tst.l		d0
		beq.s		load_error

; If file was not loaded for some reason, flash the screen

		move.l		#0,a0
		CALLINT		DisplayBeep
		
load_error	bsr		PointerOff
		moveq.l		#0,d0
		rts

; Uses ARP filerequester to get source filename.
	
arpload		lea		LoadFileStruct(a4),a0	;get file struct
		CALLARP		FileRequest 		;and open requester
		tst.l		d0			;did the user cancel ?
		beq.s		NoPath
		lea		LoadFileStruct(a4),a0	;get file struct
		move.l		fr_File(a0),a1
		tst.b		(a1)
		beq.s		NoPath
		bsr		CreatePath		;make full pathname
		tst.b		LoadPathName(a4)	;is there a pathname ?
NoPath		rts					;and return to calling routine

;--------------	This subroutine is called when SAVE gadget is selected

; First, check a file is in memory, quit if not

Save		bsr		PointerOn
		tst.l		buffer(a4)
		beq		save_error

; Use ARP filerequester to get filename, quit if none specified

		bsr.s		arpsave
		tst.b		SavePathName(a4)
		beq.s		save_error

; Open the desired file

		move.l		a4,d1
		add.l		#SavePathName,d1
		move.l		#MODE_NEWFILE,d2
		CALLARP		Open
		move.l		d0,d7
		bne.s		.ok

; If file would not open flash screen and quit

		move.l		#0,a0
		CALLINT		DisplayBeep
		bra.s		save_error

; Copy buffer to desired file
		
.ok		move.l		d0,d1
		move.l		buffer(a4),d2
		move.l		length(a4),d3
		CALLSYS		Write

; Close the file

		move.l		d7,d1
		CALLSYS		Close

; And finish

save_error	bsr		PointerOff
		moveq.l		#0,d0
		rts

; Use ARP file requester to obtain save file name.

arpsave		lea		SaveFileStruct(a4),a0	;get file struct
		CALLARP		FileRequest 		;and open requester 
		tst.l		d0			;did the user cancel ?
		beq.s		NoPath2			;yes then quit
		lea		SaveFileStruct(a4),a0	;get file struct
		move.l		fr_File(a0),a1
		tst.b		(a1)
		beq.s		NoPath2
		bsr.s		CreatePath		;make full pathname
NoPath2		rts					;and return to calling routine

*****************************************************************************
;	General subroutines called by anybody
*****************************************************************************

;Subroutine to create a single pathname from the seperate directory
;and filename strings.Adds ':' or '/' as needed.Called by

;CreatePath(FileRequest)
;		a0

;This routine assumes that a pointer to the pathname buffer
;is placed directly after the FileRequest structure.(My extension)
		

CreatePath:
	move.l		a2,-(sp)		;save a2
	move.l		a0,a2			;file struct to a2
	move.l		fr_Dir(a2),a0		;directory string to a0
	move.l		fr_SIZEOF(a2),a1	;get destination address
	moveq		#DSIZE,d0		;get size
	CALLEXEC	CopyMem			;and copy dir string
	
	move.l		fr_SIZEOF(a2),a0	;get path (dest) address
	move.l		fr_File(a2),a1		;get file string
	CALLARP		TackOn			;and tack onto dir string
	move.l		(sp)+,a2		;restore a2
	rts					;and quit

***************************************
;--------------	Routine to display custom 'sleeping' pointer

PointerOn	move.l		window.ptr(a4),a0
		lea		newptr,a1
		moveq.l		#16,d0
		move.l		d0,d1
		moveq.l		#0,d2
		move.l		d2,d3
		CALLINT		SetPointer
		rts

;--------------	Routine to display default Intuition pointer

PointerOff	move.l		window.ptr(a4),a0
		CALLINT		ClearPointer
		rts

***************************************

		incdir		df1:m.meany/arpdecrunch/

		include		win.s

		include		dec_vars

	section		pointer,data_c
newptr
	dc.w		$0000,$0000

	dc.w		$0000,$7ffe
	dc.w		$3ffc,$4002
	dc.w		$3ffc,$5ff6
	dc.w		$0018,$7fee
	dc.w		$0030,$7fde
	dc.w		$0060,$7fbe
	dc.w		$00c0,$7f7e
	dc.w		$0180,$7efe
	dc.w		$0300,$7dfe
	dc.w		$0600,$7bfe
	dc.w		$0c00,$77fe
	dc.w		$1ffc,$6ffa
	dc.w		$3ffc,$4002
	dc.w		$0000,$7ffe
	dc.w		$0000,$0000
	dc.w		$0000,$0000

	dc.w		$0000,$0000





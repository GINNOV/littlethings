

*****	Title		IntAudio
*****	Function	Allows use of prop gadget to alter playback
*****			period of a raw sound sample. Playback period is
*****			displayed in hex and decimal.
*****			
*****	Size		35134 bytes
*****	Author		Mark Meany
*****	Date Started	28 Jan 92
*****	This Revision	
*****	Notes		
*****			Needs a 'Play' boolean gadget & poss Int & Load.


		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"devices/audio.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		move.l		a0,_args	save addr of CLI args
		move.l		d0,_argslen	and the length

		bsr.s		Openlibs	open libraries
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		Init		Initialise data
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		bsr		Openwin		open window
		tst.l		d0		any errors?
		beq.s		no_win		if so quit

		bsr		WaitForMsg	wait for user

		bsr		Closewin	close our window

no_win		bsr		DeInit		free resources

no_libs		bsr		Closelibs	close open libraries

		rts				finish


;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base ptr
		beq		.lib_error	quit if error

		lea		intname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLSYS		OpenLibrary	and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		gfxname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLSYS		OpenLibrary	and open it
		move.l		d0,_GfxBase	save base ptr
		beq.s		.lib_error

; Get a message port

		moveq.l		#0,d0			priority
		lea		portname,a0		name
		bsr		CreatePort		and get it
		move.l		d0,MyPort		save port ptr
		beq		.lib_error

; Attach port to IO structure and init structure

		lea		AudioReq,a1		IO request struct
		move.l		d0,MN_REPLYPORT(a1)	attach port
		move.w		#ADCMD_ALLOCATE,IO_COMMAND(a1) command
		move.b		#ADIOF_NOWAIT,IO_FLAGS(a1) flag bits
		move.w		#0,ioa_AllocKey(a1)	no lock
		move.l		#Channels,ioa_Data(a1)	channels requested
		move.l		#4,ioa_Length(a1)	number of requests

; Open audio device

		lea		audioname,a0		device name
		moveq.l		#0,d0			unit
		move.l		d0,d1			flags
		CALLSYS		OpenDevice		open & get channels
		tst.l		d0			errors
		bne		.noDevice		quit if no device
		moveq.l		#1,d0			no errors
		move.l		d0,GotAud		set flag
		bra.s		.lib_error		return

.noDevice	moveq.l		#0,d0			set error
		move.l		d0,GotAud		clear flag

.lib_error	rts

*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		tst.l		returnMsg	are we from WorkBench?
		bne.s		.ok		if so ignore usage bit

		CALLDOS		Output		determine CLI handle
		move.l		d0,STD_OUT	and save it for later
		beq.s		.err		quit if there is no handle

		move.l		_args,a0	get addr of CLI args
		cmpi.b		#'?',(a0)	is the first arg a ?
		bne.s		.ok		if not skip the next bit

		lea		_UsageText,a0	a0->the usage text
		bsr		DosMsg		and display it
.err		moveq.l		#0,d0		set an error
		bra.s		.error		and finish

;--------------	Your Initialisations should start here

.ok		moveq.l		#1,d0		no errors
		move.l		#0,GadgMoving	clear flag

.error		rts				back to main


*************** Open An Intuition Window

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

Openwin		lea		MyWindow,a0	a0->window args
		CALLINT		OpenWindow	and open it
		move.l		d0,window.ptr	save struct ptr
		beq.s		.win_error	quit if error

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),window.up ;save up ptr
		move.l		wd_RPort(a0),window.rp    ;save rp ptr

		lea		HGadg,a5
		bsr		DoHProp

.win_error	rts				all done so return

*************** Deal with User interaction

; At present only supports gadget selection. Address of routine to call
;when a gadget is selected should be stored in the gg_UserData field
;of that gadgets structure. All gadget/menu service subroutines should set
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

		cmp.l		#GADGETUP,d2	gadget released?
		bne.s		.CheckDown
		move.l		gg_UserData(a5),a0
		cmpa.l		#0,a0
		beq.s		WaitForMsg
		jsr		(a0)
		bra.s		WaitForMsg

.CheckDown	cmp.l		#GADGETDOWN,d2	gadget pressed?
		bne.s		.CheckTicks
		move.l		#1,GadgMoving	set flag
		bra.s		WaitForMsg

.CheckTicks	cmp.l		#INTUITICKS,d2	tick tock?
		bne.s		.CheckWin
		bsr		Ticking		update display
		bra.s		WaitForMsg

.CheckWin	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		WaitForMsg	 if not then jump
		rts


*************** Close the Intuition window.

Closewin	move.l		window.ptr,a0	a0->Window struct
		CALLINT		CloseWindow	and close it
		rts

***************	Release any additional resources used

DeInit
		rts

***************	Close all open libraries

; Closes any libraries the program managed to open.

Closelibs	move.l		_DOSBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_IntuitionBase,d0	d0=base ptr	
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLSYS		CloseLibrary		close lib

		move.l		_GfxBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLSYS		CloseLibrary		close lib

		tst.l		GotAud			audio device open?
		beq.s		.noAudio		skip if not
		lea		AudioReq,a1		IO Request struct
		CALLSYS		CloseDevice		kill audio

.noAudio	move.l		MyPort,d0		port
		beq.s		.lib_error		quit if no port
		move.l		d0,a0
		bsr		DeletePort		free it

.lib_error	rts


*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

***************	Subroutine to display any message in the CLI window

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosMsg		movem.l		d0-d3/a0-a3,-(sp) save registers

		tst.l		STD_OUT		test for open console
		beq		.error		quit if not one

		move.l		a0,a1		get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3		reset counter
.loop		addq.l		#1,d3		bump counter
		tst.b		(a1)+		is this byte a 0
		bne.s		.loop		if not loop back

;--------------	Make sure there was a message

		tst.l		d3		was there a message ?
		beq.s		.error		if not, graceful exit

;--------------	Get handle of output file

		move.l		STD_OUT,d1	d1=file handle
		beq.s		.error		leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2		d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3 restore registers
		rts

****************************************************************************

;--------------
;--------------	Amiga.lib routines. See 'Includes & AutoDocs'.
;--------------


* NewList(list,type)
* a0 = list (to initialise)
* d0 = type

NewList		move.l	a0,(a0)		;lh_head points to lh_tail
		addq.l	#4,(a0)
		clr.l	4(a0)		;lh_tail = NULL
		move.l	a0,8(a0)		lh_tailpred points to lh_head

		move.b	d0,12(a0) ;list type

		rts

;--------------
;--------------	Note that as of Workbench 2.0, these functions can be found
;-------------- in the exec.library, still included here for downward
;--------------	compatability!
;--------------


* port = CreatePort(Name,Pri)
* a0 = name
* d0 = pri
* returns d0 = port, NULL if couldn't do it

* d1/d7/a1 corrupt

CreatePort	movem.l	d0/a0,-(sp)	;save parameters
		moveq	#-1,d0
		CALLEXEC	AllocSignal	;get a signal bit
		tst.l	d0
		bmi.s	cp_error1
		move.l	d0,d7		;save signal bit

* got signal bit. Now create port structure.

		move.l	#MP_SIZE,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l	d0
		beq.s	cp_error2	;couldn't create port struct!

* Here initialise port node structure.

		move.l	d0,a0
		movem.l	(sp)+,d0/d1	;get parms off stack
		move.l	d1,LN_NAME(a0)	;set name pointer
		move.b	d0,LN_PRI(a0)	;and priority

		move.b	#NT_MSGPORT,LN_TYPE(a0)	;ensure it's a message
						;port

* Here initialise rest of port.

		move.b	#PA_SIGNAL,MP_FLAGS(a0)	;signal if msg received
		move.b	d7,MP_SIGBIT(a0)		;signal bit here
		move.l	a0,-(sp)
		sub.l	a1,a1
		CALLEXEC	FindTask		;find THIS task
		move.l	(sp)+,a0
		move.l	d0,MP_SIGTASK(a0)	;signal THIS task if msg arrived

* Here, if public port, add to public port list, else
* initialise message list header.

		tst.l	LN_NAME(a0)	;got a name?
		beq.s	cp_private	;no

		move.l	a0,-(sp)
		move.l	a0,a1
		CALLEXEC	AddPort		;else add to public port list
		move.l	(sp)+,d0		;(which also NewList()s the
		rts			;mp_MsgList)

* Here initialise list header.

cp_private	lea	MP_MSGLIST(a0),a1	;ptr to list structure
		exg	a0,a1		;for now
		move.b	#NT_MESSAGE,d0	;type = message list
		bsr	NewList		;do it!

		move.l	a1,d0		;return ptr to port
		rts

* Here couldn't allocate. Release signal bit.

cp_error2	move.l	d7,d0
		CALLEXEC	FreeSignal

* Here couldn't get a signal so quit NOW.

cp_error1	movem.l	(sp)+,d0/a0
		moveq	#0,d0		;signal no port exists!

		rts


* DeletePort(Port)
* a0 = port

* a1 corrupt

DeletePort	move.l	a0,-(sp)
		tst.l	LN_NAME(a0)	;public port?
		beq.s	dp_private	;no

		move.l	a0,a1
		CALLEXEC	RemPort		;remove port

* here make it difficult to re-use the port.

dp_private	move.l	(sp)+,a0
		moveq	#-1,d0
		move.l	d0,MP_SIGTASK(a0)
		move.l	d0,MP_MSGLIST(a0)

* Now free the signal.

		moveq	#0,d0
		move.b	MP_SIGBIT(a0),d0
		CALLEXEC	FreeSignal

* Now free the port structure.

		move.l	a0,a1
		move.l	#MP_SIZE,d0
		CALLEXEC	FreeMem

		rts


*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		DOSNAME
		even
intname		INTNAME
		even
gfxname		GRAFNAME
		even
audioname	AUDIONAME				device name
		even
portname	dc.b		'Sara',0			port name
		even

; when calling the audio device you specify which channels you want allocated
;for your programs use. Each byte in the following four byte table is a
;seperate channel request, if one request fails the next is attempted. If all
;attempts fail OpenDevice will return an error in d0, else d0=0.

; To ask for a channel, set the appropriate bit in the byte. For example,
;to allocate all four channels ( 0,1,2 & 3 ), you require the byte %00001111.
; If you require a pair of stereo channels, say 1 and 3, use %00001010.

; For this example we only require a single channel as only one sample is
;going to be played:

Channels	dc.b		%00000001	try for channel 1 first
		dc.b		%00000010	if failed try for channel 2
		dc.b		%00000100	if failed try for channel 3
		dc.b		%00001000	if failed try for channel 4

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'Audio Device example written for:'
		dc.b		$0a
		dc.b		'       ACC disc 21!'
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************

		include		IntAudio.i

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

MyPort		ds.l		1
GotAud		ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1

GadgMoving	ds.l		1

STD_OUT		ds.l		1

AudioReq	ds.b		ioa_SIZEOF		IO request struct

		section		Skeleton,code

;--------------
;--------------	Update display if gadget active and moving
;--------------

Ticking		tst.l		GadgMoving
		beq.s		.Done
		
		lea		HGadg,a0		a0->Gadget
		move.l		#50,d1			Start
		swap		d1
		move.w		#400,d1			Range
		bsr		GetPropVal		get setting

		move.w		d0,DStream
		move.l		d0,DStream+2

		lea		HPotTemplate,a0		template
		lea		DStream,a1		data stream
		lea		PutChar,a2		subroutine
		lea		HPotText,a3		buffer
		CALLEXEC	RawDoFmt		build text		

		move.l		window.rp,a0	a0->windows RastPort
		lea		HPotIText,a1	a1->IText structure
		moveq.l		#0,d0		X offset
		moveq.l		#0,d1		Y offset
		CALLINT		PrintIText	print this text

.Done		rts

;--------------
;--------------	Gadget released, so update display & play sample
;--------------

; a5->gadget structure, a4 corrupted.

DoHProp		move.l		#0,GadgMoving		clear flag

		move.l		a5,a0			a0->Gadget
		move.l		#50,d1			Start
		swap		d1
		move.w		#400,d1			Range
		bsr		GetPropVal		get setting

		move.w		d0,DStream
		move.l		d0,DStream+2

		lea		HPotTemplate,a0		template
		lea		DStream,a1		data stream
		lea		PutChar,a2		subroutine
		lea		HPotText,a3		buffer
		CALLEXEC	RawDoFmt		build text		

		move.l		window.rp,a0	a0->windows RastPort
		lea		HPotIText,a1	a1->IText structure
		moveq.l		#0,d0		X offset
		moveq.l		#0,d1		Y offset
		CALLINT		PrintIText	print this text

; Play a raw sample, use period value set by user.

		lea		AudioReq,a1			IO struct
		move.w		#CMD_WRITE,IO_COMMAND(a1)	write
		move.b		#IOF_QUICK+ADIOF_PERVOL,IO_FLAGS(a1)
		move.l		#Sample,ioa_Data(a1)		sample addr
		move.l		#SampleLen,ioa_Length(a1)	sample len
		move.w		DStream,ioa_Period(a1)		period
		move.w		#64,ioa_Volume(a1)		max volume
		move.w		#1,ioa_Cycles(a1)		play once

; Send command to device, this macro is defined in the include
;		file exec/

		BEGINIO					BeginIO macro

; See if we need to fetch a reply from audio.device

		lea		AudioReq,a1		IO structure
		btst		#0,IO_FLAGS(a1)		QUICK_IO flag set?
		bne.s		.NoReply		no reply, so skip

; Determine ports signal mask

		movea.l		MyPort,a1		Port
		moveq.l		#0,d0			clear d0
		moveq		#0,d1			clear d1
		move.b		MP_SIGBIT(a1),d1	msgport signal number in d1
		bset		d1,d0			change to mask

; wait for message arriving at port, ie sound finished

		CALLEXEC	Wait			wait for reply
		
; Get the message
		
		move.l		MyPort,a0		port
		CALLSYS		GetMsg			get reply

.NoReply	moveq.l		#0,d2		dont quit
		rts				return

PutChar		move.b		d0,(a3)+
		rts


;--------------
;--------------	Get the value represented by a prop gadget
;--------------

* Function	Examines a prop gadget and returns the value it represents.

* Entry		a0->Gadget
;		d1=Start,Range of value represented

* Exit		d0=value represented

* Corrupted	d0,d1,a0

* Author	M.Meany


GetPropVal	move.l		gg_SpecialInfo(a0),a0	a0->PropInfo struct
		moveq.l		#0,d0			clear
		move.w		pi_HorizPot(a0),d0	get setting
		mulu		d1,d0			calc actual
		divu		#-1,d0			div by max value
		and.l		#$ffff,d0		mask off remainder
		
		move.w		#0,d1			clear range
		swap		d1			get start value
		add.l		d1,d0			add start to value
		
		rts

;--------------	More data :-)


HPotTemplate	dc.b		'Period =$%04x,%6ld   ',0
		even

DStream		dc.w		0,0,0,0

HPotIText	dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		20		x position
		dc.w		20		y position
		dc.l		0		font
		dc.l		HPotText	address of text to print
		dc.l		0		next text structure

HPotText	ds.b		30		the text itself
		even



		section		sound,data_c

Sample		incbin		dig.inst
SampleLen	equ		*-Sample
		even



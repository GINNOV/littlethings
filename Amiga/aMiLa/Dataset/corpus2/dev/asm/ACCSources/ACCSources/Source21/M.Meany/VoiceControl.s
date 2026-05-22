

*****	Title		IntSpeech
*****	Function	Allows use of prop gadgets to alter charecteristics
*****			of the Amigas voice
*****			
*****	Size		3362 bytes
*****	Author		Mark Meany
*****	Date Started	5th feb 92
*****	This Revision	
*****	Notes		
*****			


		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"devices/narrator.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		libraries/translator_lib.i
		include		libraries/translator.i
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
		beq		.lib_error	quit if error

		lea		gfxname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLSYS		OpenLibrary	and open it
		move.l		d0,_GfxBase	save base ptr
		beq		.lib_error

		lea		translatorname,a1	lib name
		moveq.l		#0,d0			any version
		CALLSYS		OpenLibrary		and open it
		move.l		d0,_TranslatorBase	save base ptr
		beq		.lib_error		.quit if error

; Get a message port

		moveq.l		#0,d0			priority
		lea		portname,a0		name
		bsr		CreatePort		and get it
		move.l		d0,MyPort		save port ptr
		beq		.lib_error

; Attach port to IO structure and init structure

		lea		SpeakReq,a1		IO request struct
		move.l		d0,MN_REPLYPORT(a1)	attach port

; Open narrator device

		lea		narratorname,a0		device name
		moveq.l		#0,d0			unit
		move.l		d0,d1			flags
		CALLSYS		OpenDevice		open & get channels
		tst.l		d0			errors
		bne		.noDevice		quit if no device
		move.l		#1,GotAud		set flag

		lea		SpeakReq,a1		io structure
		move.l		#Channels,NDI_CHMASKS(a1)
		move.w		#4,NDI_NUMMASKS(a1)
		move.w		#CMD_WRITE,IO_COMMAND(a1)
		move.l		#PhoneBuffer,IO_DATA(A1)
		move.w		#105,NDI_PITCH(a1)
		move.w		#1,NDI_MODE(a1)
		move.w		#92,NDI_RATE(a1)
		move.w		#0,NDI_SEX(a1)
		move.w		#20590,NDI_SAMPFREQ(a1)
		move.w		#64,NDI_VOLUME(a1)
		moveq.l		#1,d0			no errors
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

		move.l		window.rp,a0	a0->windows RastPort
		lea		WinText,a1	a1->IText structure
		moveq.l		#0,d0		X offset
		moveq.l		#0,d1		Y offset
		CALLINT		PrintIText	print this text

		bsr		PrintSettings

		lea		IntroMsg,a0
		bsr		SayIt

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

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		.test_win
		move.l		gg_UserData(a5),a0
		cmpa.l		#0,a0
		beq.s		.test_win
		jsr		(a0)

.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
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

		tst.l		GotAud			narrator device open?
		beq.s		.noAudio		skip if not
		lea		SpeakReq,a1		IO Request struct
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
translatorname	TRANSNAME
		even
narratorname	dc.b		'narrator.device',0
		even
portname	dc.b		'Sara',0			port name
		even

IntroMsg	dc.b		'Welcome to the Amiga voice controler',0
		even

; when calling the audio device you specify which channels you want allocated
;for your programs use. Each byte in the following four byte table is a
;seperate channel request, if one request fails the next is attempted. If all
;attempts fail OpenDevice will return an error in d0, else d0=0.

; To ask for a channel, set the appropriate bit in the byte. For example,
;to allocate all four channels ( 0,1,2 & 3 ), you require the byte %00001111.
; If you require a pair of stereo channels, say 1 and 3, use %00001010.

; The narrator requires a pair of channels:

Channels	dc.b		%00000011	try for channels 0&1 first
		dc.b		%00000101	if failed try channel 0&2
		dc.b		%00001010	if failed try channel 1&3
		dc.b		%00001100	if failed try channel 2&3

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'Narrator Device example written for:'
		dc.b		$0a
		dc.b		'       ACC disc 21!'
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************

		include		voicecontrol.i

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_TranslatorBase	ds.l		1

MyPort		ds.l		1
GotAud		ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1

STD_OUT		ds.l		1


PhoneBuffer	ds.b		200
SpeakReq	ds.b		NDI_SIZE		IO request struct

		section		Skeleton,code


VCQuit		move.l		#CLOSEWINDOW,d2
		rts

VCTestVoice	bsr		PrintSettings
		lea		TestTextBuff,a0
		bsr		SayIt
		moveq.l		#0,d2
		rts

VCSetMode	lea		ModePropSInfo,a0	a0->PropInfo struct
		moveq.l		#0,d0			set for monotonic
		tst.w		pi_HorizPot(a0)		check setting
		bpl.s		.ok			skip if correct
		moveq.l		#1,d0			else set expressive
.ok		lea		SpeakReq,a0		IO structure
		move.w		d0,NDI_MODE(a0)		set mode
		bsr		VCTestVoice		test new setting
		rts

VCSetRate	lea		RatePropSInfo,a0	a0->PropInfo struct
		moveq.l		#0,d0			clear
		move.w		pi_HorizPot(a0),d0	get setting
		mulu		#360,d0			calc actual
		divu		#-1,d0
		add.w		#40,d0			add MINVALUE
		lea		SpeakReq,a0		IO Structure
		move.w		d0,NDI_RATE(a0)		set rate
		bsr		VCTestVoice		test new setting
		rts
		
VCSetPitch	lea		PitchPropSInfo,a0	a0->PropInfo struct
		moveq.l		#0,d0			clear
		move.w		pi_HorizPot(a0),d0	get setting
		mulu		#255,d0			calc actual
		divu		#-1,d0
		add.w		#65,d0			add MINVALUE
		lea		SpeakReq,a0		IO Structure
		move.w		d0,NDI_PITCH(a0)	set pitch
		bsr		VCTestVoice		test new setting
		rts

VCSetFreq	lea		FreqPropSInfo,a0	a0->PropInfo struct
		moveq.l		#0,d0			clear
		move.w		pi_HorizPot(a0),d0	get setting
		mulu		#23000,d0			calc actual
		divu		#-1,d0
		add.w		#5000,d0		add MINVALUE
		lea		SpeakReq,a0		IO Structure
		move.w		d0,NDI_SAMPFREQ(a0)	set frequency
		bsr		VCTestVoice		test new setting
		rts

VCSetVol	lea		VolPropSInfo,a0		a0->PropInfo struct
		moveq.l		#0,d0			clear
		move.w		pi_HorizPot(a0),d0	get setting
		mulu		#64,d0			calc actual
		divu		#-1,d0
		lea		SpeakReq,a0		IO Structure
		move.w		d0,NDI_VOLUME(a0)	set volume
		bsr		VCTestVoice		test new setting
		rts

VCSetSex	lea		SexPropSInfo,a0		a0->PropInfo struct
		moveq.l		#0,d0			set for male
		tst.w		pi_HorizPot(a0)		check setting
		bpl.s		.ok			skip if correct
		moveq.l		#1,d0			else set female
.ok		lea		SpeakReq,a0		IO structure
		move.w		d0,NDI_SEX(a0)		set mode
		bsr		VCTestVoice		test new setting
		rts

PrintSettings	movem.l		d0-d7/a0-a6,-(sp)
		
		lea		SpeakReq,a5		IO Structure
		moveq.l		#25,d5			initial y pos

		move.w		NDI_RATE(a5),.DStream	set data
		lea		.Tmp1,a0		template
		bsr		.BuildBuffer		form text
		bsr		.PrintLine		print it
		add.l		#10,d5			bump y pos

		move.w		NDI_PITCH(a5),.DStream	set data
		lea		.Tmp1,a0		template
		bsr		.BuildBuffer		form text
		bsr		.PrintLine		print it
		add.l		#10,d5			bump y pos

		move.w		NDI_SAMPFREQ(a5),.DStream	set data
		lea		.Tmp1,a0		template
		bsr		.BuildBuffer		form text
		bsr		.PrintLine		print it
		add.l		#10,d5			bump y pos

		move.w		NDI_VOLUME(a5),.DStream	set data
		lea		.Tmp1,a0		template
		bsr		.BuildBuffer		form text
		bsr		.PrintLine		print it
		add.l		#10,d5			bump y pos

		lea		.Tmp4,a0
		tst.w		NDI_SEX(a5)
		beq.s		.gotsex
		lea		.Tmp5,a0
.gotsex		bsr		.BuildBuffer
		bsr		.PrintLine
		add.l		#10,d5

		lea		.Tmp3,a0
		tst.w		NDI_MODE(a5)
		beq.s		.gotmode
		lea		.Tmp2,a0
.gotmode	bsr		.BuildBuffer
		bsr		.PrintLine

		movem.l		(sp)+,d0-d7/a0-a6
		rts


.PrintLine	move.l		window.rp,a0	a0->windows RastPort
		lea		SettingsText,a1	a1->IText structure
		move.l		#290,d0		X offset
		move.l		d5,d1		Y offset
		CALLINT		PrintIText	print this text
		rts

; Entry		a0->Template
; Exit		TempSetBuf contains required text

.BuildBuffer	lea		.DStream,a1
		lea		.PutCh,a2
		lea		TempSetBuf,a3
		CALLEXEC	RawDoFmt
		rts

.PutCh		move.b		d0,(a3)+
		rts

.DStream	ds.l		1
.Tmp1		dc.b		'$%04x',0
		even
.Tmp2		dc.b		'Expressive',0
		even
.Tmp3		dc.b		'Monotonic ',0
		even
.Tmp4		dc.b		'Male  ',0
		even
.Tmp5		dc.b		'Female',0
		even
****************************************************************************
*		Narrator Subroutines					   *
****************************************************************************

;--------------	
;--------------	Speak! will convert and say a text string
;--------------

; Entry		a0->null terminated text string
; Exit		Nothing useful
; Corrupted	None

SayIt		movem.l		d0-d7/a0-a6,-(sp)	save registers

		bsr		StrLen			its length into d0
		lea		PhoneBuffer,a1		destination buffer
		move.l		#199,d1			max size
		CALLTRANS	Translate		and translate it

; now determine the length of the converted text

		lea		PhoneBuffer,a0		the converted text
		bsr		StrLen			length into d0
		
; now speak!

		lea		SpeakReq,a1		a1->converted text
		move.l		d0,IO_LENGTH(a1)	its length
		CALLEXEC	DoIO			issue command

; wait for the system to shut up

		lea		SpeakReq,a1		io requester
		CALLSYS		WaitIO			and wait

		movem.l		(sp)+,d0-d7/a0-a6	restore registers
		rts

;--------------
;--------------	Calculate the length of a null terminated string
;--------------	

;Entry		a0->string
;Exit		d0=length
;Corrupted	d0

StrLen		move.l		a0,-(sp)
		moveq.l		#0,d0
		
.loop		tst.b		(a0)+
		beq.s		.done
		addq.l		#1,d0
		bra.s		.loop
		
.done		move.l		(sp)+,a0
		rts


;--------------
;--------------	Copy a null terminated text string
;--------------

; Entry		a0->string
; 		a1->dest buffer
; Exit		None
; Corrupted	None

StrCpy		move.l		a0,-(sp)
		move.l		a1,-(sp)
		
.loop		move.b		(a0)+,(a1)+	copy char
		bne.s		.loop		and loop

		move.l		(sp)+,a1
		move.l		(sp)+,a0
		
		rts




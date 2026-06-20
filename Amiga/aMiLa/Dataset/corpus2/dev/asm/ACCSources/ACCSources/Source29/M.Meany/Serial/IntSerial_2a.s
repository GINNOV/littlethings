

*****	Title		Serial Control
*****	Function	Intuition based serial.device utility for use with
*****			a NULL modem cable. I will gain access to my GVP
*****			52Mg Hard drive attached to my 500+ from this 1200!
*****
*****			Now uses reqtools.library !
*****			
*****	Size		
*****	Author		Mark Meany
*****	Date Started	Dec 92
*****	This Revision	Dec 92

*****	Notes		All machine-machine commands start with an $ff byte

*****			Program may be launched from WB in which case the
*****			windows close gadget MUST be used exit. If launched
*****			from the CLI, the option of killing the program by
*****			sending a break exsists. This can be done by first
*****			issuing a status command and observing the process
*****			ID for the program and then issuing a break command
*****			or by activating the CLI and pressing CTRL-C.
*****
*****			Any character received from the serial device are
*****			displayed in the window.
*****			

EOL		equ		$0d			line feed byte

		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/exec.i
		include		intuition/intuition_lib.i
		include		intuition/intuition.i
		include		libraries/dos_lib.i
		include		libraries/dos.i
		include		libraries/dosextens.i
		include		graphics/gfx.i
		include		graphics/graphics_lib.i
		include		devices/serial.i
		incdir		ACC29_A:Include/
		include		reqtools.i
		include		reqtools_lib.i
		include		marks/MM_Macros.i

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

		include		sys:include/misc/easystart.i

		*****************************************
		*	  	Main			*
		*****************************************

; Save CLI parameters

		move.l		a0,_args		save addr of CLI args
		move.l		d0,_argslen		and the length

; Open all required libraries

		bsr		Openlibs		open libraries
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

; Open the serial device

		bsr		OpenSer			open serial device
		tst.l		d0
		beq		no_libs			exit if not open

; Do program specific initialisations

		bsr		Init			Initialise data
		tst.l		d0			any errors?
		beq.s		no_win			if so quit

; Open Intuition window

		bsr		Openwin			open window
		tst.l		d0			any errors?
		beq.s		no_win			if so quit

; Handle all incomming messages

		bsr		WaitForMsg		program control

; Close the Intuition window

		bsr		Closewin		close our window

; Do other cleaning up

no_win		bsr		DeInit			free resources

; Close the serial device

no_res		bsr		CloseSer		free serial device

; Close all libraries

no_libs		bsr		Closelibs		close open libraries

		moveq.l		#0,d0			no dos errors
		rts					finish

		*****************************************
		*	       Event Loop		*
		*****************************************

; Multi-purpose event handler. Task sleeps until:

; a. IDCMP event occurs.
; b. User break is issued ( via CLI break command ).
; c. Data arrives from serial device.

; Start by posting an asynchronus read request to srial device.

WaitForMsg	bsr		SetWLED			activate LED

		move.l		SerialRead,a1		a1->request
		move.w		#CMD_READ,IO_COMMAND(a1) request a read
		move.l		#1,IO_LENGTH(a1)	just one bytes enough
		move.l		#InBuffer,IO_DATA(a1)	address of buffer
		CALLEXEC	SendIO			issue request

; Now go to sleep until something wakes us up

.NextEvent	move.l		WinSigMask,d0		windows signal bit
		or.l		SerRSigMask,d0		serials signal bit
		ori.l		#$1000,d0		allow CTRLF_C breaks
		CALLEXEC	Wait			sleep

; If a user break received, exit.

		btst		#12,d0			user break?
		beq.s		.TryCon			no, check console
		bra		.done			else exit

; See if it was the console that woke us up. If not, skip to next test.

.TryCon		move.l		SerRSigMask,d1		get serial sig bit
		and.l		d0,d1			test
		beq.s		.TryIntui		no serial so skip
		bsr		handleSerial		else get data
		bra.s		WaitForMsg		and go back to sleep

; See if it was an IDCMP message that woke us up. If not go back to sleep

.TryIntui	move.l		WinSigMask,d1		get window sig bit
		and.l		d0,d1			test
		beq.s		.NextEvent		sleep if not IDCMP
		bsr		handleIDCMP		deal with message
		tst.l		d0			Quit selected?
		bne.s		.NextEvent		loop if not!

.done		rts					else exit

		*****************************************
		*	  Handle Console Messages	*
		*****************************************

handleSerial	bsr		SetRLED			activate LED

		move.l		SerialRead,a1		a1->request
		CALLEXEC	WaitIO			remove request

		cmp.b		#$ff,InBuffer		a command?
		beq.s		.IsCommand		yep, deal with it
		
		bsr		PrintChar		nope, display byte
		bra		.Done			and exit

; Need next byte to determine which command

.IsCommand	move.l		SerialRead,a1		a1->request
		move.w		#CMD_READ,IO_COMMAND(a1) request a read
		move.l		#1,IO_LENGTH(a1)	1 byte
		move.l		#InBuffer,IO_DATA(a1)	address of buffer
		CALLEXEC	DoIO			issue request

		moveq.l		#0,d0			clear
		move.b		InBuffer,d0		get command
		
		subq.w		#1,d0
		bne.s		.NotDownload
		bsr		DownloadFile
		bra		.Done

.NotDownload	nop

.Done		bsr		SetWLED
		rts

		*****************************************
		*	  Echo Received Characters	*
		*****************************************

; Print the byte read for the time being :-)

PrintChar	cmp.b		#EOL,InBuffer		line feed?
		beq.s		.LineFeed		yep, do it!

		move.l		window.rp,a0		a0->windows RastPort
		lea		WinText,a1		a1->IText structure
		move.l		ReadCurX,d0			X offset
		moveq.l		#0,d1			Y offset
		CALLINT		PrintIText		print this text
				
; Update cursor position

		move.l		ReadCurX,d0		get X count
		addq.w		#8,d0			bump
		cmp.w		#70*8+40,d0		EOL?
		blt.s		.done			no, skip

; Scroll receive section and reset cursor it if at end of line

.LineFeed	move.l		window.rp,a1		RastPort
		moveq.l		#0,d0			dx
		moveq.l		#8,d1			dy
		moveq.l		#40,d2			x1
		moveq.l		#31,d3			y1
		move.l		#599,d4			x2
		moveq.l		#70,d5			y2
		CALLGRAF	ScrollRaster		scroll it up!		

		moveq.l		#40,d0			reset cursor

.done		move.l		d0,ReadCurX		and store		

		rts					and exit		

		*****************************************
		*	Handle IDCMP Messages		*
		*****************************************

handleIDCMP	moveq.l		#0,d2			clear register
		move.l		window.up,a0		a0->window port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.test_win		if not exit

; Extract useful information and reply.

		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_Code(a1),d3		ascii code
		move.l		im_IAddress(a1),a5 	a5=addr of structure
		CALLSYS		ReplyMsg		answer os

; Check for gadget messages and act accordingly

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0	source a gadget?
		beq.s		.test_key		skip if not.
		move.l		gg_UserData(a5),a0	else a0->subroutine
		cmpa.l		#0,a0			check for NULL
		beq.s		.test_win		skip if it is
		jsr		(a0)			else call routine
		bra.s		.test_win		and exit

; check keys

.test_key	cmp.l		#VANILLAKEY,d2
		bne.s		.test_win
		bsr		SendChar
		bsr		SetWLED

; If message was CLOSEWINDOW, exit from event loop.

.test_win	moveq.l		#1,d0			default to quit
		cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne.s		.done		 	yep, exit!

		lea		QuitText,a1		a1-> texts
		lea		QuitReq,a2		a2-> gadget defs
		suba.l		a3,a3			no special info
		suba.l		a4,a4			no args
		lea		QuitTags,a0		a0-> tag list
		CALLREQ		rtEZRequestA		display request
		
.done		rts					and exit

		*****************************************
		*	Send A char to Serial Device	*
		*****************************************

SendChar	cmp.b		#$0a,d3
		bne.s		.NotLF
		move.b		#EOL,d3
.NotLF		move.b		d3,OutBuffer

		bsr		SetTLED

		move.l		SerialWrite,a1		a1->request
		move.w		#CMD_WRITE,IO_COMMAND(a1) request a read
		move.l		#1,IO_LENGTH(a1)	just one bytes enough
		move.l		#OutBuffer,IO_DATA(a1)	address of buffer
		CALLEXEC	DoIO			issue request

		cmp.b		#EOL,OutBuffer
		beq.s		.LineFeed

		move.l		window.rp,a0		a0->windows RastPort
		lea		WriteText,a1		a1->IText structure
		move.l		WriteCurX,d0		X offset
		moveq.l		#0,d1			Y offset
		CALLINT		PrintIText		print this text
				
; Update cursor position

		move.l		WriteCurX,d0		get X count
		addq.w		#8,d0			bump
		cmp.w		#70*8+40,d0		EOL?
		blt.s		.done			no, skip

; Scroll receive section and reset cursor it if at end of line

.LineFeed	move.l		window.rp,a1		RastPort
		moveq.l		#0,d0			dx
		moveq.l		#8,d1			dy
		moveq.l		#40,d2			x1
		moveq.l		#88,d3			y1
		move.l		#599,d4			x2
		moveq.l		#127,d5			y2
		CALLGRAF	ScrollRaster		scroll it up!		

		moveq.l		#40,d0			reset cursor

.done		move.l		d0,WriteCurX		and store		

		rts
		
		*****************************************
		*	  Set An LED Screen LEDs	*
		*****************************************

SetWLED		bsr		ClearLEDs		clear em all

		moveq.l		#3,d0			select pen
		move.l		window.rp,a4		RastPort
		move.l		a4,a1
		CALLGRAF	SetAPen			set it

; Set LED

		move.l		a4,a1			RastPort
		moveq.l		#49,d0			x1
		move.l		#143,d1			y1
		moveq.l		#65,d2			x2
		move.l		#144,d3			y2
		CALLSYS		RectFill		clear it

		rts

SetTLED		bsr		ClearLEDs		clear em all

		moveq.l		#3,d0			select pen
		move.l		window.rp,a4		RastPort
		move.l		a4,a1
		CALLGRAF	SetAPen			set it

; Set LED

		move.l		a4,a1			RastPort
		moveq.l		#49,d0			x1
		move.l		#154,d1			y1
		moveq.l		#65,d2			x2
		move.l		#155,d3			y2
		CALLSYS		RectFill		clear it

		rts

SetRLED		bsr		ClearLEDs		clear em all

		moveq.l		#3,d0			select pen
		move.l		window.rp,a4		RastPort
		move.l		a4,a1
		CALLGRAF	SetAPen			set it

; Set LED

		move.l		a4,a1			RastPort
		moveq.l		#49,d0			x1
		move.l		#165,d1			y1
		moveq.l		#65,d2			x2
		move.l		#166,d3			y2
		CALLSYS		RectFill		clear it

		rts

		****************************************
		*	  Clear Screen LEDs	       *
		****************************************

; Screen contains 3 LEDs that show state of serial port. Clear the three of
;them.

ClearLEDs	moveq.l		#0,d0			select pen
		move.l		window.rp,a4		RastPort
		move.l		a4,a1
		CALLGRAF	SetAPen			set it

; Clear 1st LED

		move.l		a4,a1			RastPort
		moveq.l		#49,d0			x1
		move.l		#143,d1			y1
		moveq.l		#65,d2			x2
		move.l		#144,d3			y2
		CALLSYS		RectFill		clear it

; Clear 2nd LED

		move.l		a4,a1			RastPort
		moveq.l		#49,d0			x1
		move.l		#154,d1			y1
		moveq.l		#65,d2			x2
		move.l		#155,d3			y2
		CALLSYS		RectFill		clear it

; Clear 3rd LED

		move.l		a4,a1			RastPort
		moveq.l		#49,d0			x1
		move.l		#165,d1			y1
		moveq.l		#65,d2			x2
		move.l		#166,d3			y2
		CALLSYS		RectFill		clear it

		rts

		****************************************
		*	  Send A Complete Mesage       *
		****************************************

; Use string requester to define mesage

SendMsg		move.b		#0,OutBuffer		clear buffer

		lea		OutBuffer,a1		a1-> text buffer
		moveq.l		#70,d0			max number of chars
		lea		MsgTitle,a2		Requester Title
		suba.l		a3,a3			no special info
		suba.l		a0,a0			no tags
		CALLREQ		rtGetStringA		display requester

; Display Text in transmit message area

		move.l		window.rp,a1		RastPort
		moveq.l		#0,d0			dx
		moveq.l		#8,d1			dy
		moveq.l		#40,d2			x1
		moveq.l		#88,d3			y1
		move.l		#599,d4			x2
		moveq.l		#127,d5			y2
		CALLGRAF	ScrollRaster		scroll it up!		

		move.l		#40,WriteCurX		reset cursor

		move.l		window.rp,a0		a0->windows RastPort
		lea		WriteText,a1		a1->IText structure
		move.l		WriteCurX,d0		X offset
		moveq.l		#0,d1			Y offset
		CALLINT		PrintIText		print this text

		move.l		window.rp,a1		RastPort
		moveq.l		#0,d0			dx
		moveq.l		#8,d1			dy
		moveq.l		#40,d2			x1
		moveq.l		#88,d3			y1
		move.l		#599,d4			x2
		moveq.l		#127,d5			y2
		CALLGRAF	ScrollRaster		scroll it up!		

; Locate end of string and append a line feed

		lea		OutBuffer,a0
.loop		tst.b		(a0)+
		bne.s		.loop
		subq.l		#1,a0
		
		move.b		#$0d,(a0)+
		move.b		#$0,(a0)

; Set transmitting LED

		bsr		SetTLED
		
; Now send the message

		move.l		SerialWrite,a1		a1->request
		move.w		#CMD_WRITE,IO_COMMAND(a1) request a read
		move.l		#-1,IO_LENGTH(a1)	complete string
		move.l		#OutBuffer,IO_DATA(a1)	address of buffer
		CALLEXEC	DoIO			issue request

		bsr		SetWLED
		
		rts

		*****************************************
		*	      Upload A File		*
		*****************************************

; Allow user to select file to send

SendFile	move.l		UpLoadReq,a1		a1-> request struct
		lea		ULName,a2		a2-> filename buffer
		lea		UpLoadTitle,a3		Requester Title
		lea		UpLoadTags,a0		tags
		CALLREQ		rtFileRequestA		display requester
		tst.l		d0			cancel selected?
		beq		.Done			yep, skip!

; Change to directory in which file is located

		move.l		UpLoadReq,a0		a0->Tags
		move.l		rtfi_Dir(a0),d1		d1->dir name
		moveq.l		#ACCESS_READ,d2		access mode
		CALLDOS		Lock			lock directory
		move.l		d0,d7			save lock
		beq		.Done
		
		move.l		d0,d1			dir lock
		CALLDOS		CurrentDir		change directory
		move.l		d0,d6

; Load file into memory

		LOADFILE	#ULName
		move.l		a0,filebuff
		move.l		d0,filesize
		beq		.Error1
		
; Can now start transmitting data, set transmitt led and write $ff01 filesize
;This signals a file is being transmitted and it's size:)

		move.w		#$ff01,OutBuffer
		move.l		d0,OutBuffer+2
		
		bsr		SetTLED

		move.l		SerialWrite,a1		a1->request
		move.w		#CMD_WRITE,IO_COMMAND(a1) request a read
		move.l		#6,IO_LENGTH(a1)	send 6 bytes
		move.l		#OutBuffer,IO_DATA(a1)	address of buffer
		CALLEXEC	DoIO			issue request

; Send the file!

		move.l		SerialWrite,a1		a1->request
		move.w		#CMD_WRITE,IO_COMMAND(a1) request a read
		move.l		filesize,IO_LENGTH(a1)	send entire file
		move.l		filebuff,IO_DATA(a1)	address of buffer
		CALLEXEC	DoIO			issue request

		bsr		SetWLED

; Release memory used to hold file

		move.l		filebuff,a1
		move.l		filesize,d0
		CALLEXEC	FreeMem

; Reset current directory

.Error1		move.l		d6,d1
		CALLDOS		CurrentDir

; Release Lock on specified directory

		move.l		d7,d2
		CALLDOS		UnLock
		
.Done		move.w		#0,OutBuffer		clear buffer
		rts

		*****************************************
		*	     Download A File		*
		*****************************************

; Receive a file from other machine

; Must start by issuing file request so user can select filename

DownloadFile	move.l		DownLoadReq,a1		a1-> request struct
		lea		DLName,a2		a2-> filename buffer
		lea		DownLoadTitle,a3	Requester Title
		lea		DownLoadTags,a0		tags
		CALLREQ		rtFileRequestA		display requester
		tst.l		d0			cancel selected?
		beq		.Done			yep, skip!

; Now get size of file from other machine

		move.l		SerialRead,a1		a1->request
		move.w		#CMD_READ,IO_COMMAND(a1) request a read
		move.l		#4,IO_LENGTH(a1)	1 long word
		move.l		#InBuffer,IO_DATA(a1)	address of buffer
		CALLEXEC	DoIO			issue request

; Allocate memory for the file

		move.l		InBuffer,d0
		beq		.Done
		move.l		d0,filesize		save size of file
		moveq.l		#0,d1			any memory will do
		CALLEXEC	AllocMem		get memory
		move.l		d0,filebuff		save address
		beq		.Done

; Change to directory in which file is to be created

		move.l		DownLoadReq,a0		a0->Tags
		move.l		rtfi_Dir(a0),d1		d1->dir name
		moveq.l		#ACCESS_READ,d2		access mode
		CALLDOS		Lock			lock directory
		move.l		d0,d7			save lock
		beq		.Error1
		
		move.l		d0,d1			dir lock
		CALLDOS		CurrentDir		change directory
		move.l		d0,d6

; Create the file

		move.l		#DLName,d1		file name
		move.l		#MODE_NEWFILE,d2	access mode
		CALLDOS		Open
		move.l		d0,d5			save handle
		beq		.Error2

; Download data

		move.l		SerialRead,a1		a1->request
		move.w		#CMD_READ,IO_COMMAND(a1) request a read
		move.l		filesize,IO_LENGTH(a1)	complete file
		move.l		filebuff,IO_DATA(a1)	address of buffer
		CALLEXEC	DoIO			issue request

; Write data to file

		move.l		d5,d1			handle
		move.l		filebuff,d2		buffer
		move.l		filesize,d3		size
		CALLDOS		Write			write bytes

; Close the file

		move.l		d5,d1			handle
		CALLDOS		Close

; Reset current directory

.Error2		move.l		d6,d1			lock
		CALLDOS		CurrentDir		reset

; Unlock the directory

		move.l		d7,d1			lock
		CALLDOS		UnLock			free

; Free file buffer

.Error1		move.l		filebuff,a1		buffer
		move.l		filesize,d0		size
		CALLEXEC	FreeMem			release

; Switch LED back to wait and exit

.Done		bsr		SetWLED
		rts

		*****************************************
		*	  Allow Quit by Gadget		*
		*****************************************

DoQuitGadg	move.l		#CLOSEWINDOW,d2
		rts

		*****************************************
		*	  Open Serial Device		*
		*****************************************

; Opens the serial device and extracts the signal mask for read requests.
;Since the program must be capable of sending data to serial device while
;waiting to hear from the device, two IO structures must be created. One
;will be used for reads and one for writes. Some Read requests will be
;asynchronus, write requests always synchronus.

; Get a port for use with read requester.

OpenSer		lea		readport,a0		a0->port name
		moveq.l		#0,d0			priority
		bsr		CreatePort		get a port
		move.l		d0,AccRPort		save pointer
		beq		.Error1			exit if no port

; Get port signal mask and save it

		move.l		d0,a0			a0->port
		moveq.l		#1,d0			
		moveq.l		#0,d1
		move.b		MP_SIGBIT(a0),d1
		asl.l		d1,d0
		move.l		d0,SerRSigMask

; Create an IO structure for read requests

		moveq.l		#IOEXTSER_SIZE,d0	size of structure
		bsr		CreateExtIO		get structure
		move.l		d0,SerialRead		save address
		beq		.Error2

; Get a port for use with write requester.

		lea		writeport,a0		a0->port name
		moveq.l		#0,d0			priority
		bsr		CreatePort		get a port
		move.l		d0,AccWPort		save pointer
		beq		.Error3			exit if no port

; Get port signal mask and save it

		move.l		d0,a0			a0->port
		moveq.l		#1,d0			
		moveq.l		#0,d1
		move.b		MP_SIGBIT(a0),d1
		asl.l		d1,d0
		move.l		d0,SerWSigMask

; Create an IO structure for write requests

		moveq.l		#IOEXTSER_SIZE,d0	size of structure
		bsr		CreateExtIO		get structure
		move.l		d0,SerialWrite		save address
		beq		.Error4

; Open the serial device

		lea		sername,a0		a0->device name
		moveq.l		#0,d0			unit number
		move.l		SerialRead,a1		a1->IO structure
		moveq.l		#0,d0			no flags
		CALLEXEC	OpenDevice		open serial device
		tst.l		d0			open OK?
		bne		.Error5			no, exit now!

; Copy initialisation data from read request into write request

		move.l		SerialRead,a0		src
		move.l		SerialWrite,a1		dest
		moveq.l		#IOEXTSER_SIZE,d0	size of structure
		CALLEXEC	CopyMem			copy data

; Must attach correct port to write request

		move.l		SerialWrite,a0		a0->request
		move.l		AccWPort,MN_REPLYPORT(a0) attach correct port

; Signal no errors and exit

		moveq.l		#1,d0			no errors
		rts					so return

; All errors are dealt with below:

; Release the write IO structure

.Error5		move.l		SerialWrite,a1		a1->IO structure
		bsr		DeleteExtIO		release it

; Free the write port

.Error4		move.l		AccWPort,a0		a0->Port
		bsr		DeletePort		release it


; Release the read IO structure

.Error3		move.l		SerialRead,a1		a1->IO structure
		bsr		DeleteExtIO		release it

; Free the read port

.Error2		move.l		AccRPort,a0		a0->Port
		bsr		DeletePort		release it

		moveq.l		#0,d0			signal error

.Error1		rts					exit

		****************************************
		*	  Close Serial Device	       *
		****************************************

; As asynchronus IO is being preformed, it will be necessary to abort any
;pending requests from the port prior to quitting!

CloseSer	move.l		SerialRead,a1		a1->request
		CALLEXEC	AbortIO			abort it

; Wait for abort request to be serviced

		move.l		SerialRead,a1		a1->request
		CALLEXEC	WaitIO			wait for abort

; Now can close device

		move.l		SerialRead,a1		a1->request
		CALLEXEC	CloseDevice		close serial device

; Release the write IO structure

		move.l		SerialWrite,a1		a1->IO structure
		bsr		DeleteExtIO		release it

; Free the write port

		move.l		AccWPort,a0		a0->Port
		bsr		DeletePort		release it


; Release the read IO structure

		move.l		SerialRead,a1		a1->IO structure
		bsr		DeleteExtIO		release it

; Free the read port

		move.l		AccRPort,a0		a0->Port
		bsr		DeletePort		release it

; all freed so return

		rts

		*****************************************
		*	  Open Required Libraries	*
		*****************************************

; Open Reqtools library.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		reqname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_reqBase		save base ptr

; reqtools opens DOS, Intuition and Graphics libraries and we can use the
;base pointers stored in it's base structure :-)

		move.l		d0,a0			a0->library base
		move.l		rt_IntuitionBase(a0),_IntuitionBase
		move.l		rt_GfxBase(a0),_GfxBase
		move.l		rt_DOSBase(a0),_DOSBase

.lib_error	rts

		*****************************************
		*	  Close All Libraries		*
		*****************************************

; Closes any libraries the program managed to open.

Closelibs	move.l		_reqBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts

		*****************************************
		*	  Initialisation Code		*
		*****************************************

; At present just set STD_OUT and check for usage text

Init		tst.l		returnMsg		from WorkBench?
		bne.s		.ok			yep, ignore usage bit

		CALLDOS		Output			determine CLI handle
		move.l		d0,STD_OUT		save it for later
		beq.s		.err			quit if not one

		move.l		_args,a0		get addr of CLI args
		cmpi.b		#'?',(a0)		is the first arg a ?
		bne.s		.ok			skip if not

		lea		_UsageText,a0		a0->the usage text
		bsr		DosMsg			and display it
.err		moveq.l		#0,d0			set an error
		bra.s		.error			and finish

; Your Initialisations should start here

.ok		move.l		#40,ReadCurX		set cursor
		move.l		#40,WriteCurX		set cursor

; Open and initialise file requester structures

		moveq.l		#RT_FILEREQ,d0		structure required
		suba.l		a0,a0			tag list
		CALLREQ		rtAllocRequestA		get structure
		move.l		d0,UpLoadReq		save addr
		beq.s		.error
		
		moveq.l		#RT_FILEREQ,d0		structure required
		suba.l		a0,a0			tag list
		CALLREQ		rtAllocRequestA		get structure
		move.l		d0,DownLoadReq		save addr
		beq.s		.error

		moveq.l		#1,d0			no errors

.error		rts					back to main


		*****************************************
		*	  Deinitialisation		*
		*****************************************

; Free requester structures used for up/down loading

DeInit		move.l		DownLoadReq,d0
		beq.s		.TryLoad
		move.l		d0,a1
		CALLREQ		rtFreeRequest
		
.TryLoad	move.l		UpLoadReq,d0
		beq.s		.done
		move.l		d0,a1
		CALLREQ		rtFreeRequest
		
.done		rts

		*****************************************
		*	  Open Main Window		*
		*****************************************

; Opens an intuition window. If d0=0 on return then window could not be
;opened.

Openwin		lea		MyWindow,a0		a0->window args
		CALLINT		OpenWindow		and open it
		move.l		d0,window.ptr		save struct ptr
		beq.s		.win_error		quit if error

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),window.up ;save up ptr
		move.l		wd_RPort(a0),window.rp    ;save rp ptr

; Get window signal bit

		move.l		window.up,a0
		moveq.l		#1,d0
		moveq.l		#0,d1
		move.b		MP_SIGBIT(a0),d1
		asl.l		d1,d0
		move.l		d0,WinSigMask

; Display window gfx

		move.l		window.rp,a0		a0->windows RastPort
		lea		WindowGfx,a1		a1->Image structure
		moveq.l		#0,d0			X offset
		moveq.l		#0,d1			Y offset
		CALLSYS		DrawImage		display gfx

; Attach gadgets and refresh them

		move.l		window.ptr,a0		Window
		lea		ReadGadg,a1		Gadget
		moveq.l		#0,d0			position
		moveq.l		#12,d1			num gadgets
		suba.l		a2,a2			no requester
		CALLSYS		AddGList
		
		lea		ReadGadg,a0		Gadget
		move.l		window.ptr,a1		Window
		suba.l		a2,a2			Requester
		moveq.l		#12,d0			num gadgets
		CALLSYS		RefreshGList		display them

		moveq.l		#1,d0			no errors
.win_error	rts					all done so return

		*****************************************
		*	  Close Main Window		*
		*****************************************

Closewin	move.l		window.ptr,a0		a0->Window struct
		CALLINT		CloseWindow		and close it
		rts

		*****************************************
		*	  Write To CLI Window		*
		*****************************************

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosMsg		movem.l		d0-d3/a0-a3,-(sp)	save registers

		tst.l		STD_OUT			test for open console
		beq		.error			quit if not one

		move.l		a0,a1			get a working copy

; Determine length of message

		moveq.l		#-1,d3			reset counter
.loop		addq.l		#1,d3			bump counter
		tst.b		(a1)+			is this byte a 0
		bne.s		.loop			if not loop back

; Make sure there was a message

		tst.l		d3			was there a message ?
		beq.s		.error			if not, graceful exit

; Get handle of output file

		move.l		STD_OUT,d1		d1=file handle
		beq.s		.error			leave if no handle

; Now print the message. At this point, d3 already holds length of message
;and d1 holds the file handle.

		move.l		a0,d2			d2=address of message
		CALLDOS		Write			and print it

; All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3	restore registers
		rts

		*****************************************
		*	  Include Subroutines		*
		*****************************************

		include		exec_support.i
		include		marks/MM_subs.i

		*****************************************
		*	  Initialised Data		*
		*****************************************

reqname		dc.b		'reqtools.library',0
		even
readport	dc.b		'AmiganutsRead',0
		even
writeport	dc.b		'AmiganutsWrite',0
		even
sername		dc.b		'serial.device',0
		even

; Strings used with reqtools requesters

MsgTitle	dc.b		'Enter Message:',0
		even

GenTitle	dc.b		'Comms Program Request',0
		even

UpLoadTitle	dc.b		'Select File To UpLoad:',0
		even

DownLoadTitle	dc.b		'Download to which file:',0
		even

QuitText	dc.b		'Are you sure you wish to quit?',$0a
		dc.b		' Please confirm your request.',0
		even

; Tag lists used with reqtools requesters

QuitTags	dc.l		RT_ReqPos,REQPOS_CENTERSCR
		dc.l		RTEZ_ReqTitle,QuitTitle
		dc.l		TAG_DONE

QuitTitle	dc.b		'              Amiganuts',0
		even

UpLoadTags	dc.l		RT_ReqPos,REQPOS_CENTERSCR	centralise
		dc.l		RTFI_Flags,FREQF_PATGAD
		dc.l		TAG_DONE

DownLoadTags	dc.l		RT_ReqPos,REQPOS_CENTERSCR	centralise
		dc.l		RTFI_Flags,FREQF_PATGAD
		dc.l		TAG_DONE

; Gadget texts for use with reqtools requesters

QuitReq		dc.b		'Cancel|Confirm',0
		even
		
; CLI usage text

_UsageText	dc.b		$0a
		dc.b		'Serial Device utility by M.Meany, Amiganuts.'
		dc.b		$0a
		dc.b		'For use with NULL modem cable.'
		dc.b		$0a
		dc.b		0
		even

		*****************************************
		*	  Intuition Data		*
		*****************************************

MyWindow:
    DC.W    0,12,640,188
    DC.B    0,1
    DC.L    CLOSEWINDOW+VANILLAKEY+GADGETUP
    DC.L    WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+SMART_REFRESH+ACTIVATE
    DC.L    0,0
    DC.L    MyWindow_title
    DC.L    0,0
    DC.W    150,50,640,256,WBENCHSCREEN

MyWindow_title:
    DC.B    'Amiganuts, 12 Hinkler Rd., Southampton, Hants. SO2 6FT ',0
    EVEN

		include		Comm_Gadg.i

WinText		dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		63		y position
		dc.l		0		font
		dc.l		InBuffer	address of text to print
		dc.l		0		no more text

WriteText	dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		120		y position
		dc.l		0		font
		dc.l		OutBuffer	address of text to print
		dc.l		0		no more text

WindowGfx	dc.w		38,15
		dc.w		576,165
		dc.w		2
		dc.l		gfxData
		dc.b		$0003,$0000
		dc.l		0


		*****************************************
		*	  Uninitialised Data		*
		*****************************************

		section		vars,BSS

_args		ds.l		1
_argslen	ds.l		1

_reqBase	ds.l		1
_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1

; Reqtools related vars

UpLoadReq	ds.l		1
DownLoadReq	ds.l		1

WinSigMask	ds.l		1		signal mask for window
SerRSigMask	ds.l		1		signal mask for read IO port
SerWSigMask	ds.l		1		signal mask for write IO port

AccRPort	ds.l		1		port for serial reads
AccWPort	ds.l		1		Port for serial writes
SerialRead	ds.l		1		IO read structure
SerialWrite	ds.l		1		IO write structure

filesize	ds.l		1
filebuff	ds.l		1

ReadCurX	ds.l		1
WriteCurX	ds.l		1
BufferX		ds.w		1


STD_OUT		ds.l		1

InBuffer	ds.b		90

OutBuffer	ds.b		90

ULName		ds.b		110

DLName		ds.b		110

		*****************************************
		*	  Data For CHIP Memory		*
		*****************************************

		section		gfx,data_c

gfxData		incbin		comm.bm

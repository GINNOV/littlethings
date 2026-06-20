
*****	Title		WBScroll
*****	Function	Adds a scroll text to the Workbench screen by switching
*****			workbench into Dual Playfield mode add supplying a
*****			backdrop playfield.
*****	Size		6052 bytes.
*****	Author		Mark Meany
*****	Date Started	13th Dec 1991
*****	This Revision	14th Dec 1991
*****	Notes		Use only on 64Ox256 or 64Ox2OO Workbenches!
*****			Slows down drives.
*****			Can't quit from it once started.
*****			Will load a file from disc and convert this into
*****			a scroll text. If file not present, uses a default
*****			text programmed into it.
*****			THIS IS REALLY MESSY.

*****			Someone could modify this so that a filename can be
*****			passed as a CLI parameter, that's not to difficult.

		incdir		"df0:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"resources/cia.i"
		include		"hardware/cia.i"

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

		LIBINIT	LIB_BASE		;lib offsets for CIA resource
		LIBDEF	CIA_ADDICRVECTOR	;as not defined in recources/cia.i :-)
		LIBDEF	CIA_REMICRVECTOR	;I think these are correct anyway the 
		LIBDEF	CIA_ABLEICR		;two used in this program are.Does 
		LIBDEF	CIA_SETICR		;Commodore think we are telepathic ?
	
PALTIME		EQU	14187		;sets interrupt timer to 50Hz
NTSCTIME	EQU	14318

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

		bsr		LoadText	get scroll text

		bsr		Openwin		open window
		tst.l		d0		any errors?
		beq.s		no_libs		if so quit

		CALLGRAF	WaitTOF
		bsr		IntOn

		bsr		WaitForMsg

no_libs		bsr		Closelibs	close open libraries

		rts				finish


;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		intname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq.s		.lib_error	quit if error

		lea		gfxname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_GfxBase	save base ptr

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
		beq		.win_error	quit if error

		move.l		d0,a0			  ;a0->win struct	
		move.l		wd_UserPort(a0),window.up ;save up ptr
		move.l		wd_RPort(a0),window.rp    ;save rp ptr

; Get pointer to Workbench screen

		move.l		window.ptr,a0	a0->new window
		move.l		wd_WScreen(a0),WBScreen  save screen pointer

; Allocate memory for new playfields RasInfo structure

		move.l		#ri_SIZEOF,d0	size
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,D1
		CALLEXEC	AllocMem
		move.l		d0,rinfo2	save structure pointer
		beq		.win_error	quit if error

; Allocate memory for new playfields BitMap structure

		move.l		#bm_SIZEOF,d0	size
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,D1
		CALLEXEC	AllocMem
		move.l		d0,bmap2	save structure pointer
		beq		.win_error	quit if error

; Initialise the BitMap structure

		move.l		d0,a0		a0->BitMap
		move.l		WBScreen,a1	a1->screen
		move.w		sc_Width(a1),d1	d1=width of display
		move.w		sc_Height(a1),d2 d2=height of display
		moveq.l		#1,d0		depth
		CALLGRAF	InitBitMap	and initialise

; Allocate memory for bitplane

		moveq.l		#0,d0		clear them to be safe!
		move.l		d0,d1
		move.l		WBScreen,a0
		move.w		sc_Width(a0),d0		width
		asr.w		#3,d0			div by 8
		mulu		sc_Height(a0),d0	x Height
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1
		CALLEXEC	AllocMem		get memory
		move.l		d0,d7
		beq		.win_error

; Copy raw data into allocated Raster

;		move.l		WBScreen,a0
;		moveq.l		#0,d0
;		move.w		sc_Width(a0),d0
;		asr.w		#3,d0			divide by 8
;
;		mulu		sc_Height(a0),d0	size of Raster
;		lea		piccy,a0		a0->raw data
;		move.l		d7,a1			a1->Raster
;		CALLEXEC	CopyMem			and copy it

; Set up registers for scroll text

		move.l		d7,d0			d0=addr of raster
		add.l		#800,d0
		move.l		d0,bpl1
		add.l		#80,d0
		move.l		d0,scrnpoint

; Attach raw bitplane data to BitMap structure

		move.l		bmap2,a0	a0->BitMap structure
		move.l		d7,bm_Planes(a0)

; Allocate memory for RastPort structure

		move.l		#rp_SIZEOF,d0	size
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,rport2
		beq		.win_error

; Initialise the RastPort

		move.l		d0,a1
		CALLGRAF	InitRastPort

; Attach BitMap to RastPort

		move.l		rport2,a0
		move.l		bmap2,rp_BitMap(a0)

; Now for the fun, shove dual-playfield onto workbench

		CALLEXEC	Forbid		*** Freeze Frame ***

; Attach BitMap to RasInfo

		move.l		rinfo2,a0
		move.l		bmap2,ri_BitMap(a0)

; Attach RasInfo to WorkBench screen

		move.l		WBScreen,a0
		lea		sc_ViewPort(a0),a1
		move.l		vp_RasInfo(a1),a0
		move.l		rinfo2,ri_Next(a0)

; Set dual-playfield mode

		or.w		#V_DUALPF,vp_Modes(a1)
		move.l		a1,-(sp)
		CALLEXEC	Permit

; Set foreground to RED for new playfield

		move.l		(sp)+,a0
		moveq.l		#9,d0
		moveq.l		#$c,d1		RED
		move.l		d1,d2		GREEN
		move.l		d2,d3		BLUE
		CALLGRAF	SetRGB4

; 'Turn It On' ......

		move.l		WBScreen,a0
		CALLINT		MakeScreen
		CALLINT		RethinkDisplay

		moveq.l		#1,d0
.win_error	rts				all done so return

***************	Wait for ever!!!

WaitForMsg	move.l		window.up,a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.up,a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		CALLSYS		ReplyMsg	answer os or it get angry
		bra.s		WaitForMsg


***************	Close all open libraries

; Closes any libraries the program managed to open.

Closelibs	move.l		_DOSBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_IntuitionBase,d0	d0=base ptr	
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

		move.l		_GfxBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

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



LoadText	lea		TextFile,a0
		bsr		FileLen
		tst.l		d0
		bne.s		.ok1

		move.l		#MSG,Text.ptr
		bra		.error

.ok1		move.l		d0,d7			save length
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,Text.ptr
		bne.s		.ok2

		move.l		#MSG,Text.ptr
		bra		.error

.ok2		move.l		#TextFile,d1
		move.l		#MODE_OLDFILE,d2
		CALLDOS		Open
		move.l		d0,d6			save handle
		bne.s		.ok3

		move.l		d7,d0
		move.l		Text.ptr,a0
		CALLEXEC	FreeMem

		move.l		#MSG,Text.ptr
		bra		.error1

.ok3		move.l		d6,d1
		move.l		Text.ptr,d2
		move.l		d7,d3
		CALLDOS		Read			get text

		move.l		Text.ptr,a0
		move.l		d7,d0
		subq.l		#1,d0

.outer		cmp.b		#' ',(a0)+
		bge.s		.t2
		move.b		#' ',-1(a0)
		bra.s		.loopend

.t2		cmp.b		#'~',-1(a0)
		ble.s		.loopend
		move.b		#' ',-1(a0)

.loopend	dbra		d0,.outer

.error1		move.l		d6,d1
		CALLDOS		Close

.error		move.l		Text.ptr,msgpoint
		rts

***************	Subroutine that returns the length of a file in bytes.

; Entry		a0 = address of file name

; Exit		d0 = length of file in bytes or 0 if any error occurred

; Corrupted	a0

;-------------- Save register values

FileLen		movem.l		d1-d4/a1-a4,-(sp)

;-------------- Save address of filename and clear file length

		move.l		a0,RFfile_name
		move.l		#0,RFfile_len

;-------------- Allocate some memory for the File Info block

		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,RFfile_info
		beq		.error1
		
;-------------- Lock the file
		
		move.l		RFfile_name,d1
		move.l		#ACCESS_READ,d2
		CALLDOS		Lock
		move.l		d0,RFfile_lock
		beq		.error2

;-------------- Use Examine to load the File Info block

		move.l		d0,d1
		move.l		RFfile_info,d2
		CALLSYS		Examine

;-------------- Copy the length of the file into RFfile_len

		move.l		RFfile_info,a0
		move.l		fib_Size(a0),RFfile_len

;-------------- Release the file

		move.l		RFfile_lock,d1
		CALLSYS		UnLock

;-------------- Release allocated memory

.error2		move.l		RFfile_info,a1
		move.l		#fib_SIZEOF,d0
		CALLEXEC	FreeMem


;-------------- All done so return

.error1		move.l		RFfile_len,d0
		movem.l		(sp)+,d1-d4/a1-a4
		rts

*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even
TextFile	dc.b		's:scroll-text',0
		even


; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'Yo! What a lovely backdrop picture!'
		dc.b		$0a
		dc.b		'       Coding: Mark Meany.'
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************


MyWindow	dc.w		20,20
		dc.w		1,1
		dc.b		1,0
		dc.l		CLOSEWINDOW
		dc.l		BORDERLESS!BACKDROP!NOCAREREFRESH
		dc.l		0		;gadgets
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		5,5
		dc.w		WBENCHSCREEN

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1

WBScreen	ds.l		1
rinfo2		ds.l		1
bmap2		ds.l		1
rport2		ds.l		1

Text.ptr	ds.l		1
RFfile_name	ds.l		1
RFfile_lock	ds.l		1
RFfile_info	ds.l		1
RFfile_len	ds.l		1


_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1

STD_OUT		ds.l		1

_MatchFlag	ds.l		1

		section		Skeleton,code

;--------------	The CIA Interrupt on

; Turn CIA Interrupt ON. Will return d0=0 if could not set interrupt.

IntOn		movem.l		d0-d7/a0-a6,-(sp)

; Set up interrupt and start music playing

		lea		InterruptVector(pc),a0	;set a0 to interrupt vector
		bsr		InitCIA			;set it running
		tst.l		d0			;check for errors

.error		movem.l		(sp)+,d0-d7/a0-a6
		rts


;--------------	Turns CIA Interrupt OFF.

IntOff		movem.l		d0-d7/a0-a6,-(sp)

		lea		InterruptVector(pc),a0	;set interrupt to stop
		bsr		CIAOff			;and stop it
		clr.l		errorMsg		;no errors so clear error msg

.error		movem.l		(sp)+,d0-d7/a0-a6
		rts

InitCIA:	move.l		#0,CIAbase
		move.l		a0,-(sp)		;save a0
		lea		CIAname(pc),a1		;get cia resource name 
		CALLEXEC	OpenResource		;open resource
		move.l		d0,CIAbase		;store resource base
		beq		CIA_Error		;branch if open failed
	
		move.l		_GfxBase,d6		d6=addr of lib base
	  	beq.s		.Pal			;default to pal if no graf lib
  	
	  	move.l		d0,a1			;graphics lib base in a0
		move.w		206(a1),d1		;get Display flags
		btst		#2,d1			;does DisplayFlags = PAL
		beq.s		.Ntsc 			;branch if not PAL
.Pal
		move.w		#PALTIME,d7		;set PAL time delay
		bra.s		Timeset			;branch always
.Ntsc
		move.w		#NTSCTIME,d7		;set NTSC time delay

Timeset	
		lea		$bfd000,a5		;get peripheral data reg a
		move.l		CIAbase(pc),a6		;get cia base
		move.l		(sp),a1			;get Interrupt vector
		moveq		#1,d0			;set ICRBit (timer B)
		jsr		CIA_ADDICRVECTOR(a6)	;add interrupt
		move.l		d0,CIAFlag		;store return value
		bne.s		TryTimerA		;branch to try timer A
	
		move.b		d7,ciatblo(a5)		;set timer B low
		lsr.w		#8,d7			;shift left for high byte
		move.b		d7,ciatbhi(a5)		;set timer B high
		bset		#0,ciacrb(a5)		;start timer (continuous)
		bra.s		CIA_End			;branch to finish
	
TryTimerA:
		move.l		(sp),a1			;get Interrupt vector
		moveq		#0,d0			;set ICRBit (timer A)
		jsr		CIA_ADDICRVECTOR(a6)	;add interrupt
		tst.l		d0			;check for error
		bne.s		CIA_Error		;branch if error
  	
		move.b		d7,ciatalo(a5)		;set timer A low
		lsr.w		#8,d7			;shift left for hight byte
		move.b		d7,ciatahi(a5)		;set timer B high
		bset		#0,ciacra(a5)		;start timer A

CIA_End:
		moveq		#0,d0			;flag no error
		addq.l		#4,sp			;pop a0 from stack
		rts					;quit
	
CIAOff:
		move.l		a0,-(sp)		;save a0
		lea		$bfd000,a5		;get peripheral data reg a
		tst.l		CIAFlag			;check for timer B
		bne.s		TimerA			;branch if not timer B
	
		bclr		#0,ciacrb(a5)		;stop timer B
		moveq		#1,d0			;set ICRBit (timer B)
		bra.s		RemInt			;branch to remove
TimerA
		bclr		#0,ciacra(a5)		;stop timer A
		moveq		#0,d0			;set ICRBit (timer A)
	
RemInt
		move.l		CIAbase(pc),a6		;get CIA base
		move.l		(sp),a1			;get interrup to remove
		jsr		CIA_REMICRVECTOR(a6)	;and remove it
		move.l		#0,CIAbase
CIA_Error:	
		moveq		#-1,d0			;flag error
		addq.l		#4,sp			;pop a0 from stack
		rts					;quit

Interrupt_handler:
		movem.l		d2-d7/a2-a6,-(a7)	;save regs

		bsr		ScrollText
		bsr		ScrollText

.error		movem.l		(a7)+,d2-d7/a2-a6	;restore regs
		moveq		#0,d0			;allow other interrupts to run
		rts	

ScrollText
	bsr	scrolly
	subq.b	#1,scrlcount
	bne	.done
	bsr	printchar
	move.b	#16,scrlcount
.done	rts

printchar	move.l	msgpoint,a0
	MOVEQ.L	#0,D0
	MOVE.B	(A0),D0
	SUB.W	#' ',D0
	asl.l	#5,d0		x32
	LEA	Font,A0
	ADDA.L	D0,A0
	moveq.l	#15,d0
	moveq.l	#80,d1
	move.l	bpl1,a1
	lea	78(a1),a1
nextln	move.w	(a0)+,(a1)
	adda.l	d1,a1
	dbra	d0,nextln
	addq.l	#1,msgpoint
	move.l	msgpoint,a0
	tst.b	(a0)
	bne.s	more
	move.l	Text.ptr,msgpoint
more	RTS


scrolly	move.l	scrnpoint,a0
	moveq.l	#15,d1
.lp1	moveq.l	#39,d0
	andi.b	#%11101111,ccr
.lp2	roxl.w	-(a0)
	dbra	d0,.lp2
	lea	160(a0),a0
	dbra	d1,.lp1
	rts

bpl1		dc.l	0
scrnpoint	dc.l	0
msgpoint	dc.l	0
scrlcount	dc.b	16
	even
	DC.L	0


********** variables and structures ********
;------	Interrupt structure	
InterruptVector:
		dc.l	0	;LN_SUCC
		dc.l	0	;LN_PRED
		dc.b	0	;LN_TYPE
		dc.b	127	;LN_PRI
		dc.l	0	;LN_NAME
		dc.l	0	;is_Data
		dc.l	Interrupt_handler	;address of routine to call

errorMsg:	dc.l	0

CIAFlag:	dc.l	0		

CIAbase:	dc.l	0	

CIAname:
	CIABNAME


Font	 
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;" "
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0380,$07C0,$07C0,$07C0,$07C0,$0380,$0380,$0380	;"!"
	dc.w	$0100,$0100,$0000,$0380,$07C0,$07C0,$0380,$0000
	dc.w	$1E3C,$3E7C,$3E7C,$3E7C,$3060,$2040,$0000,$0000	;"""
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$3C78,$3C78,$FFFE,$FFFE,$FFFE,$FFFE,$3C78,$3C78	;"#"
	dc.w	$3C78,$FFFE,$FFFE,$FFFE,$FFFE,$3C78,$3C78,$0000
	dc.w	$0380,$3FFE,$7FFE,$FFFE,$FBBE,$FB80,$FFF8,$7FFC	;"$"
	dc.w	$3FFE,$03BE,$FBBE,$FFFE,$FFFC,$FFF8,$0380,$0000
	dc.w	$700E,$F81E,$F83E,$F87C,$70F8,$01F0,$03E0,$07C0	;"%"
	dc.w	$0F80,$1F00,$3E1C,$7C3E,$F83E,$F03E,$E01C,$0000
	dc.w	$1FC0,$3FE0,$7FF0,$78F0,$7DE0,$3BCC,$179E,$0F3E	;"&"	
	dc.w	$1EDC,$3DE8,$79F0,$F2F8,$FF7C,$FFBC,$7F1C,$0000	
	dc.w	$03C0,$07C0,$07C0,$07C0,$0600,$0400,$0000,$0000	;"'"	
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	
	dc.w	$07F8,$0FF0,$1FE0,$0000,$1F00,$1F00,$1F00,$1F00	;"("	
	dc.w	$1F00,$1F00,$1F00,$1F80,$1FE0,$0FF0,$07F8,$0000	
	dc.w	$3FC0,$1FE0,$0FF0,$0000,$01F0,$01F0,$01F0,$01F0	;")"	
	dc.w	$01F0,$01F0,$01F0,$03F0,$0FF0,$1FE0,$3FC0,$0000	
	dc.w	$0100,$4104,$3398,$3BB8,$1FF0,$0FE0,$3FF8,$FFFE	;"*"	
	dc.w	$3FF8,$0FE0,$1FF0,$3BB8,$3398,$4104,$0100,$0000	
	dc.w	$0000,$0000,$03C0,$03C0,$03C,$03C0,$3FFC,$3FFC	;"+"	
	dc.w	$3FFC,$3FFC,$03C0,$03C0,$03C0,$03C0,$0000,$0000	
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;","
	dc.w	$0000,$03C0,$07C0,$07C0,$07C0,$0600,$0400,$0000	
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FFC,$3FFC	;"-"
	dc.w	$3FFC,$3FFC,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;"."
	dc.w	$0000,$0000,$03C0,$07C0,$07C0,$07C0,$0780,$0000
	dc.w	$000E,$001E,$003E,$007C,$00F8,$01F0,$03E0,$07C0	;"/"
	dc.w	$0F80,$1F00,$3E00,$7C00,$F800,$F000,$E000,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F83E,$F9FE,$FBBE	;"0"
	dc.w	$FF3E,$F83E,$F83E,$FC7E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$07C0,$07C0,$07C0,$07C0,$0FC0,$0FC0,$1FC0,$1FC0	;"1"
	dc.w	$07C0,$07C0,$07C0,$07C0,$FFFE,$FFFE,$FFFE,$0000
	dc.w	$3FF0,$7FFC,$FFFE,$F800,$003E,$007E,$3FFE,$7FFC	;"2"
	dc.w	$FFF8,$FC00,$F800,$F83E,$FFFE,$FFFE,$FFFE,$0000
	dc.w	$3FF8,$7FFC,$FFFE,$F800,$003E,$007E,$07FC,$07F8	;"3"
	dc.w	$07FC,$007E,$003E,$F87E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$FC0E,$FFFE,$7FFE	;"4"
	dc.w	$3FFE,$003E,$003E,$003E,$003E,$003E,$003E,$0000
	dc.w	$FFFE,$FFFE,$FFFE,$003E,$F800,$F800,$FFF8,$FFFC	;"5"
	dc.w	$FFFE,$007E,$003E,$F87E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$3FFE,$7FFE,$FFFE,$003E,$F800,$F800,$FFF8,$FFFC	;"6"
	dc.w	$FFFE,$F87E,$F83E,$FC7E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$F800,$003E,$003E,$07FE,$07FE	;"7"
	dc.w	$07FE,$003E,$003E,$003E,$003E,$003E,$003E,$0000
	dc.w	$3FF8,$7FFC,$FFFE,$007E,$F83E,$FC7E,$7FFC,$3FF8	;"8"
	dc.w	$7FFC,$FC7E,$F83E,$FC7E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$3FF8,$7FFC,$FFFE,$007E,$F83E,$FC3E,$FFFE,$7FFE	;"9"
	dc.w	$3FFE,$003E,$003E,$F87E,$FFFE,$FFFC,$FFF8,$0000	
	dc.w	$0000,$0000,$03C0,$07C0,$07C0,$07C0,$0780,$0000	;":"
	dc.w	$0000,$03C0,$07C0,$07C0,$07C0,$0780,$0000,$0000
	dc.w	$0000,$0000,$03C0,$07C0,$07C0,$07C0,$0780,$0000	;";"
	dc.w	$0000,$03C0,$07C0,$07C0,$07C0,$0600,$0400,$0000
	dc.w	$007C,$00F8,$01F0,$03E0,$07C0,$0F80,$1F00,$3E00	;"<"
	dc.w	$1F00,$0F80,$07C0,$03E0,$01F0,$00F8,$007C,$0000
	dc.w	$0000,$0000,$0000,$3FFC,$3FFC,$3FFC,$3FFC,$0000	;"="
	dc.w	$0000,$3FFC,$3FFC,$3FFC,$3FFC,$0000,$0000,$0000
	dc.w	$7C00,$3E00,$1F00,$0F80,$07C0,$03E0,$01F0,$00F8	;">"
	dc.w	$01F0,$03E0,$07C0,$0F80,$1F00,$3E00,$7C00,$0000
	dc.w	$3FF8,$7FFC,$FFFE,$F800,$003E,$007E,$03FE,$07FC	;"?"
	dc.w	$07F8,$07C0,$07C0,$0000,$07C0,$07C0,$07C0,$0000	
	dc.w	$3FF8,$7FFC,$FFFE,$FC7E,$F83E,$F83E,$F9FE,$F9FE	;"@"
	dc.w	$F9FE,$F9FE,$F9FE,$FC00,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F83E,$FFFE,$FFFE	;"A"
	dc.w	$FFFE,$F83E,$F83E,$F83E,$F83E,$F83E,$FF3E,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F87E,$FFFC,$FFF8	;"B"
	dc.w	$FFFC,$F87E,$F83E,$F87E,$FFFE,$FFFC,$FFF8,$0000	
	dc.w	$3FFE,$7FFE,$FFFE,$003E,$F800,$F800,$F800,$F800	;"C"
	dc.w	$F800,$F800,$F800,$FC3E,$FFFE,$7FFE,$3FFE,$0000	
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F83E,$F83E,$F83E	;"D"
	dc.w	$F83E,$F83E,$F83E,$F87E,$FFFE,$FFFC,$FFF8,$0000	
	dc.w	$FFF8,$FFFC,$FFFE,$003E,$F800,$F800,$FFC0,$FFC0	;"E"
	dc.w	$FFC0,$F800,$F800,$F83E,$FFFE,$FFFC,$FFF8,$0000	
	dc.w	$FFF8,$FFFC,$FFFE,$003E,$F800,$F800,$FFC0,$FFC0	;"F"
	dc.w	$FFC0,$F800,$F800,$F800,$F800,$F800,$F800,$0000
	dc.w	$3FFE,$7FFE,$FFFE,$003E,$F800,$F800,$F8FE,$F8FE	;"G"
	dc.w	$F8FE,$F83E,$F83E,$FC3E,$FFFE,$7FFE,$3FFE,$0000	
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$F83E,$FFFE,$FFFE	;"H"
	dc.w	$FFFE,$F83E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000
	dc.w	$FFFE,$FFFE,$FFFE,$0000,$07C0,$07C0,$07C0,$07C0	;"I"	
	dc.w	$07C0,$07C0,$07C0,$07C0,$FFFE,$FFFE,$FFFE,$0000
	dc.w	$FFFE,$FFFE,$FFFE,$F800,$003E,$003E,$07FE,$07FE	;"J"
	dc.w	$07FE,$003E,$003E,$F87E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$F87E,$FFFC,$FFF8	;"K"
	dc.w	$FFFC,$F87E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000	
	dc.w	$F800,$F800,$F800,$0000,$F800,$F800,$F800,$F800	;"L"
	dc.w	$F800,$F800,$F800,$FC3E,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$F83E,$FC7E,$FEFE,$FFFE,$F7FE,$FBBE,$F93E,$F83E	;"M"
	dc.w	$F83E,$F83E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000
	dc.w	$F83E,$FC3E,$FE3E,$0F3E,$F7BE,$FBFE,$F9FE,$F8FE	;"N"
	dc.w	$F87E,$F83E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F83E,$F83E,$F83E	"O"
	dc.w	$F83E,$F83E,$F83E,$FC7E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F87E,$FFFE,$FFFC	;"P"
	dc.w	$FFF8,$F800,$F800,$F800,$F800,$F800,$F800,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F83E,$F83E,$F83E	;"Q"
	dc.w	$F83E,$F8FE,$F8FE,$FCFE,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F87E,$FFFC,$FFF8	;"R"
	dc.w	$FFFC,$F87E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000
	dc.w	$3FFE,$7FFE,$FFFE,$003E,$F800,$FC00,$FFF8,$7FFC	;"S"
	dc.w	$3FFE,$007E,$003E,$F87E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$F800,$003E,$003E,$003E,$003E	;"T"
	dc.w	$003E,$003E,$003E,$003E,$003E,$003E,$003E,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$F83E,$F83E,$F83E	;"U"
	dc.w	$F83E,$F83E,$F83E,$FC3E,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$F83E,$F83E,$F83E	;"V"
	dc.w	$F87C,$F8F8,$F9F0,$FBE0,$FFC0,$7F80,$3F00,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$F83E,$F83E,$F83E	;"W"
	dc.w	$F83E,$F93E,$FBBE,$FFFC,$FFF8,$7EF0,$3C60,$0000
	dc.w	$F01E,$F01E,$F83E,$007E,$7EFC,$3FF8,$1FF0,$0FE0	;"X"?
	dc.w	$1FF0,$3FF8,$7EFC,$FC7E,$F83E,$F01E,$F01E,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$FC3E,$FFFE,$7FFE	;"Y"
	dc.w	$3FFE,$003E,$003E,$F87E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$FFFE,$FFFE,$FFFE,$F800,$00FC,$01F8,$03F0,$07E0	;"Z"
	dc.w	$0FC0,$1F80,$3F00,$7E3E,$FFFE,$FFFE,$FFFE,$0000
	dc.w	$1FF8,$1FF8,$1FF8,$0000,$1F00,$1F00,$1F00,$1F00	;"["
	dc.w	$1F00,$1F00,$1F00,$1F00,$1FF8,$1FF8,$1FF8,$0000
	dc.w	$E000,$F000,$F800,$7C00,$3E00,$1F00,$0F80,$07C0	;"\"
	dc.w	$03E0,$01F0,$00F8,$007C,$003E,$001E,$000E,$0000
	dc.w	$3FF0,$3FF0,$3FF0,$0000,$01F0,$01F0,$01F0,$01F0	;"]"
	dc.w	$01F0,$01F0,$01F0,$01F0,$3FF0,$3FF0,$3FF0,$0000
	dc.w	$0100,$0380,$07C0,$0FE0,$1EF0,$3C78,$783C,$0000	;"^"
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;"_"
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FFFF,$FFFF
	dc.w	$0780,$07C0,$07C0,$07C0,$00C0,$0040,$0000,$0000	;"`"
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FFE,$7FFE	;"a"
	dc.w	$FFFE,$FC3E,$F83E,$FC3E,$FFBE,$7FBE,$3FBE,$0000
	dc.w	$0000,$0000,$F800,$F800,$F800,$0000,$FFF8,$FFFC	;"b"
	dc.w	$FFFE,$F87E,$F83E,$F87E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FFE,$7FFE	;"c"
	dc.w	$FFFE,$FC00,$F800,$FC00,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$003E,$003E,$003E,$0000,$3FFE,$7FFE	;"d"
	dc.w	$FFFE,$FC3E,$F83E,$FC3E,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FF8,$7FFC	;"e"
	dc.w	$FFFE,$FC3E,$FFFC,$FC00,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$1FF0,$3FF8,$7FFC,$0000,$7F80,$7F80	;"f"
	dc.w	$7F80,$7C00,$7C00,$7C00,$7C00,$7C00,$7C00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FFE,$7FFE	;"g"
	dc.w	$FFFE,$FC00,$F9FE,$FC3E,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$F800,$F800,$F800,$0000,$FFF8,$FFFC	;"h"
	dc.w	$FFFE,$F87E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000	
	dc.w	$0000,$0000,$07C0,$07C0,$07C0,$0000,$07C0,$07C0	;"i"
	dc.w	$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$0000
	dc.w	$0000,$0000,$003E,$003E,$003E,$0000,$003E,$003E	;"j"
	dc.w	$003E,$003E,$003E,$F87E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$0000,$0000,$F800,$F800,$F800,$0000,$F83E,$F83E	;"k"
	dc.w	$F87E,$FFFC,$FFF8,$FFFC,$F87E,$F83E,$F83E,$0000
	dc.w	$0000,$0000,$0FC0,$07C0,$07C0,$0000,$07C0,$07C0	;"l"
	dc.w	$07C0,$07C0,$07C0,$07C0,$07C0,$07E0,$07F0,$0000	
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FC78,$FEFC	;"m"
	dc.w	$FFFE,$FBBE,$F93E,$F83E,$F83E,$F83E,$F83E,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FFF8,$FFFC	;"n"
	dc.w	$FFFE,$F87E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000	
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FF8,$7FFC	;"o"
	dc.w	$FFFE,$FC7E,$F83E,$FC7E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FFF8,$FFFC	;"p"
	dc.w	$FFFE,$F87E,$FFFC,$F800,$F800,$F800,$F800,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FF8,$7FFC	;"q"
	dc.w	$FFFE,$FC3E,$F8FE,$FCFE,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FFF8,$FFFC	;"r"
	dc.w	$FFFE,$F87E,$FFFC,$F87E,$F83E,$F83E,$F83E,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FFE,$7FFE	;"s"
	dc.w	$FFFE,$FC08,$7FFC,$007E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$0000,$0000,$1F00,$1F00,$1F00,$0000,$3FE0,$3FE0	;"t"
	dc.w	$3FE0,$1F00,$1F00,$1F80,$1FE0,$0FE0,$07C0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$F83E,$F83E	;"u"
	dc.w	$F83E,$F83E,$F83E,$FC3E,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$F83E,$F83E	;"v"	
	dc.w	$F83E,$F83E,$F87E,$F8FC,$FFF8,$FFF0,$FFE0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$F83E,$F83E	;"w"
	dc.w	$F83E,$F83E,$F83E,$F97C,$FFF8,$FFF0,$FEE0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$F83E,$F83E	;"x"
	dc.w	$FC7E,$7FFC,$3FF8,$7FFC,$FC7E,$F83E,$F83E,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$F83E,$F83E	;"y"
	dc.w	$F83E,$7FFE,$003E,$F87E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FFFE,$FFFE	;"z"	
	dc.w	$FFFC,$0078,$1FF0,$3C00,$7FFE,$FFFE,$FFFE,$0000
	dc.w	$07F8,$0FF8,$1FF8,$0000,$1F00,$3F00,$7E00,$FC00	;"{"
	dc.w	$7E00,$3F00,$1F00,$1F80,$1FF8,$0FF8,$07F8,$0000	
	dc.w	$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$07C0	;"|"
	dc.w	$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$0000
	dc.w	$3FC0,$3FE0,$3FF0,$0000,$01F0,$01F8,$00FC,$007E	;"}"
	dc.w	$00FC,$01F8,$01F0,$03F0,$3FF0,$3FE0,$3FC0,$0000
	dc.w	$0800,$1C00,$3E00,$7700,$E380,$C1C1,$80E3,$0077	;"~"
	dc.w	$003E,$001C,$0008,$0000,$0000,$0000,$0000,$0000	
	dc.w	$CCCC,$CCCC,$3333,$3333,$CCCC,$CCCC,$3333,$3333	;""
	dc.w	$CCCC,$CCCC,$3333,$3333,$CCCC,$CCCC,$3333,$3333


MSG	dc.b	'                            There are scroll texts and there are scroll texts, and'
	dc.b	' this is a scroll text ????? Trouble is someone was to lazy to'
	dc.b	' supply any text for this one, so you are now reading a default'
	dc.b	' message that stops the proggy crashing. This rather naff util'
	dc.b	' was coded by M.Meany late one night in December 1991. If you'
	dc.b	' find some use for it, I will be amazed !!!!!!              '
	dc.b	' Here are some greets from me -----------> '
	dc.b	' MEGA HARTY HAND-SHAKES GO TO Mike Cross, Blaine, Steve Marshall,'
	dc.b	' Dave Edwards, Trev ( Artwerks ), Raistlin, Assasins,'
	dc.b	" Neil, Mark Flemans, Nipper, Dave Shaw's, Dean Ashton, Armalyte, Vandal,"
	dc.b	' MasterBeat, RBF, AMIGA FORMAT ( For the reviews, creep, creep!!! ),'
	dc.b	' TreeBeard, NotMan, Pendle Europa, Phil Boyce, Phil Lishman,'
	dc.b	" Ronnie 'The General' James, Karl Troth and Peter Wilson ( Cryptic )."
	dc.b	' Last, but by no means least, Nico Francois. Arrrrgggg I hate writing scroll texts!'
	dc.b	' Who ever reads this far anyway? Time to wrap this little WorkBench scroller'
	dc.b	' round so those who have read this far can start all over again '
	dc.b	'............................',0
	even



		section Pointer,data_c
;--------------	
;--------------	Chip ram data
;--------------	

;piccy		incbin		back




*****	Title		DOS start
*****	Function	
*****			
*****			
*****	Size		
*****	Author		Mark Meany
*****	Date Started	Apr 93
*****	This Revision	
*****	Notes		Variables accessed from register a5.
*****			If program is launched from WB, it simply quits!
*****			FileLen routine uses dos Seek() command.
*****			LoadFile releases buffer if Open() fails.



	incdir	sys:include/
	include exec/exec.i
	include exec/exec_lib.i

	include libraries/dos.i
	include libraries/dosextens.i
	include libraries/dos_lib.i

	include graphics/gfxbase.i
	include	graphics/graphics_lib.i

	include intuition/intuition.i
	include intuition/intuition_lib.i

	include	devices/console_lib.i
	include devices/inputevent.i

CALLSYS		macro			* speeds up consecutive library calls
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

PUSH		macro			* push specified registers onto stack
		movem.l	\1,-(sp)
		endm

PULL		macro			* pull specified registers off stack
		movem.l	(sp)+,\1
		endm

PUSHALL		macro			* moves d1-d7/a0-a6 onto stack
		PUSH	d1-d7/a0-a6
		endm

PULLALL		macro			* moves d1-d7/a0-a6 off stack
		PULL	d1-d7/a0-a6
		endm

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		lea		Variables,a5		a5->var base
	
		move.l		a0,_args(a5)		save addr of CLI args
		move.l		d0,_argslen(a5)		and the length
		move.b		#0,-1(a0,d0)		null terminate

		bsr.s		Openlibs		open libraries
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		Init			Initialise data
		tst.l		d0			any errors?
		beq.s		no_libs			if so quit

		bsr		Main

no_win		bsr		DeInit			free resources

no_libs		bsr		Closelibs		close open libraries

		rts					finish


;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		dosname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_DOSBase		save base ptr
		beq.s		.lib_error		quit if error

		lea		intname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq.s		.lib_error		quit if error

		lea		gfxname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_GfxBase		save base ptr

.lib_error	rts

*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		moveq.l		#0,d0
		tst.l		returnMsg		from WorkBench?
		bne.s		.error			yes, quit now!

		CALLDOS		Output			determine CLI handle
		move.l		d0,STD_OUT(a5)		save it for later
		beq.s		.err			quit if no handle

		move.l		_args(a5),a0		get addr of CLI args
		cmpi.b		#'?',(a0)		is the first arg a ?
		bne.s		.ok			no, skip next bit

		lea		_UsageText,a0		a0->the usage text
		bsr		DosPrint		and display it
.err		moveq.l		#0,d0			set an error
		bra.s		.error			and finish

;--------------	Your Initialisations should start here

.ok		moveq.l		#1,d0			no errors

.error		rts					back to main

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
		CALLEXEC	CloseLibrary		close lib

		move.l		_GfxBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts


*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

;--------------
;--------------	Writes a NULL terminated message to STD_OUT
;--------------

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosPrint	movem.l		d0-d3/a0-a3,-(sp) 	save registers

		tst.l		STD_OUT(a5)		test for open console
		beq		.error			quit if not one

		move.l		a0,a1			get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3			reset counter
.loop		addq.l		#1,d3			bump counter
		tst.b		(a1)+			is this byte a 0
		bne.s		.loop			if not loop back

;--------------	Make sure there was a message

		tst.l		d3			was there a message ?
		beq.s		.error			no, graceful exit

;--------------	Get handle of output file

		move.l		STD_OUT(a5),d1		d1=file handle
		beq.s		.error			leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2			d2=address of message
		CALLDOS		Write			and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3	restore registers
		rts

;--------------
;--------------	Build and display a text string using RawDoFmt
;--------------

; Entry		a0->format string

; Exit		Nothing Useful

; Corrupt	a6 possibly

RDFPrint	PUSH		d0-d4/a0-a4

		lea		DStream(a5),a1
		lea		.PC,a2
		lea		BuiltText(a5),a3
		CALLEXEC	RawDoFmt
		
		lea		BuiltText(a5),a0
		bsr.s		DosPrint
		
		PULL		d0-d4/a0-a4
		rts

.PC		move.b		d0,(a3)+
		rts

;--------------
;--------------	Obtain the length of a specified file
;--------------

;Entry		a0->filename

;Exit		d0=length of file or 0 on error

;corrupt	d0

FileLen		PUSHALL
		move.l		a0,d1
		move.l		#MODE_OLDFILE,d2
		CALLDOS		Open
		move.l		d0,d4			handle
		beq		.error
		
		move.l		d4,d1
		moveq.l		#0,d2
		moveq.l		#1,d3			OFFSET_END
		CALLSYS		Seek
		
		move.l		d4,d1
		moveq.l		#0,d2
		moveq.l		#-1,d3			OFFSET_BEGINNING
		CALLSYS		Seek
		move.l		d0,d3			end of file
		
		move.l		d4,d1
		CALLSYS		Close

		move.l		d3,d0			file length
.error		PULLALL
		rts

;--------------
;--------------	Load data from a file into memory
;--------------

;Entry		a0->filename
;		d0= memory type

;Exit		d0=size of file, zero on error
;		a0->buffer containing loaded data

;corrupt	d0,a0

LoadFile	PUSH		d1-d7/a1-a6

; Determine length of file

		move.l		d0,d1			save requirements
		move.l		a0,a4			save filename ptr
		bsr.s		FileLen
		move.l		d0,d4			all ok?
		beq		.error

; Allocate memory for file

		CALLEXEC	AllocMem		get buffer
		tst.l		d0
		beq		.error			exit if no memory
		move.l		d0,a3

; Open the file

		move.l		a4,d1			filename
		move.l		#MODE_OLDFILE,d2	access mode
		CALLDOS		Open
		move.l		d0,d5			save file handle
		bne.s		.GotFile

	;File failed to open! Release buffer and exit
	
		move.l		a3,a1			buffer
		move.l		d4,d0			size
		CALLEXEC	FreeMem			release it
		moveq.l		#0,d0
		bra		.error			and exit

; Read data from file into buffer

.GotFile	move.l		d5,d1			Handle
		move.l		a3,d2			buffer
		move.l		d4,d3			size
		CALLSYS		Read			get data

; Close the file

		move.l		d5,d1			handle
		CALLSYS		Close

; Set return values

		move.l		a3,a0			a0->buffer
		move.l		d4,d0			size
		

.error		PULL		d1-d7/a1-a6
		rts


*******	Subroutine to print data from memory as dc.w statements to a file

; Entry		a0->Start of data
;		d0=number of words to save
;		std_out=file handle to save to

; Exit		same

; Corrupt	none

DataPrint	movem.l		d0-d7/a0-a6,-(sp)

		move.l		a0,ta5(a5)
		move.l		d0,d5

.Loop		cmp.l		#8,d5
		blt		.LastLine
		
		lea		.Temp,a0		template
		move.l		ta5(a5),a1			data stream
		lea		.PutC,a2		PutChar routine
		lea		.Buffer,a3		buffer
		CALLEXEC	RawDoFmt		generate Text
		
		lea		.Buffer,a0		a0->text
		bsr		DosPrint		print it to file

		addq.l		#8,ta5(a5)			bump pointer
		addq.l		#8,ta5(a5)
		subq.l		#8,d5			dec counter
		beq		.AllDone		exit if no data left
		bra		.Loop			else loop

.LastLine	move.l		d5,d0
		subq.w		#1,d0
		mulu		#6,d0
		add.w		#11,d0
		lea		.Temp,a4
		add.l		d0,a4
		move.b		#$0a,(a4)
		move.b		#0,1(a4)
		
		lea		.Temp,a0		template
		move.l		ta5(a5),a1			data stream
		lea		.PutC,a2		PutChar routine
		lea		.Buffer,a3		buffer
		CALLEXEC	RawDoFmt		generate Text
		
		lea		.Buffer,a0		a0->text
		bsr		DosPrint		print it to file
		
		move.b		#',',(a4)		restore
		move.b		#'$',1(a4)		template
		
.AllDone	movem.l		(sp)+,d0-d7/a0-a6
		rts

.PutC		move.b		d0,(a3)+
		rts

.Temp	dc.b	$09,'dc.w',$09
	dc.b	'$%04x,$%04x,$%04x,$%04x,$%04x,$%04x,$%04x,$%04x',$0a,0
	even

.Buffer dc.b	' dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00',0
	 even

*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'SourceDump by M.Meany of Amiganuts.'
		dc.b		$0a
		dc.b		'SourceDump <filename> will create a new',$0a
		dc.b		'file, <filename>.src, containing dc.w',$0a
		dc.b		'statements for inclusion into asm code.',$0a
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
;	SECTION	Vars,BSS
;***********************************************************

		rsreset
_args		rs.l		1
_argslen	rs.l		1

STD_OUT		rs.l		1

ta5		rs.l		1

Length		rs.l		1
Address		rs.l		1

DStream		rs.l		10		space for 10 items
BuiltText	rs.b		260		space for 256 characters

varsize		rs.b		0

		SECTION	Vars,BSS

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

Variables	ds.b		varsize

		section		Skeleton,code

***** Your code goes here!!!

; NOTES: dos, graphics and intuition libraries are open.
;	 Register a5 is used to access variables, add your own to defenitions
;	 above.
;	 _args(a5) and _argslen(a5) contain startup values of a0,d0

; Create output filename same as input file, but with .src extension

Main		move.l		_args(a5),a0
		lea		BuiltText(a5),a1
		move.l		a1,d1
		
.Loop		move.b		(a0)+,(a1)+
		bne.s		.Loop

		move.b		#'.',-1(a1)
		move.b		#'s',(a1)
		move.b		#'r',1(a1)
		move.b		#'c',2(a1)
		move.b		#0,3(a1)

		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,STD_OUT(a5)
		beq		.Error

; Load in the source file

		move.l		_args(a5),a0		filename
		move.l		#MEMF_CLEAR,d0		mem type
		bsr		LoadFile		load it
		move.l		d0,Length(a5)
		beq.s		.Error1
		move.l		a0,Address(a5)		

; Output the source code to destination file

		asr.l		#1,d0			d0=word length
		bsr		DataPrint

; Release loaded data

		move.l		Address(a5),a1
		move.l		Length(a5),d0
		CALLEXEC	FreeMem

; Close dest file

.Error1		move.l		STD_OUT(a5),d1
		CALLDOS		Close

.Error		rts

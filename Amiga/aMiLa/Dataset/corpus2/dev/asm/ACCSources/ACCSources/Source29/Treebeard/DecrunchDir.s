*---------------------------------------------------------------------------*
* DECRDIR
*  by Treebeard '92 (who needs a real name anyway?)
*---------------------------------------------------------------------------*

DEVPAC		equ		3

;		IFEQ		Devpac-3
;		include		ram:system
;		include		sys:include/ppbase.i
;		include		sys:include/powerpacker_lib
;		ELSE

		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/types.i
		include		libraries/dos_lib.i
		include		libraries/dos.i
		include		ACC29_A:include/powerpacker_lib.i
		include		ACC29_A:Include/ppbase.i

;		ENDC

;		opt		o+,ow2-

*---------------------------------------------------------------------------*
		rsreset
mDOSBase	rs.l		1
mPPBase		rs.l		1
ReturnCode	rs.l		1
OutHandle	rs.l		1	
FileBuffer	rs.l		1
FileLength	rs.l		1
SourcePath	rs.b		256
DestPath	rs.b		256
FormatBuff	rs.b		300
vars_SIZEOF	rs.w		0
*---------------------------------------------------------------------------*
CALLSYS		Macro
		jsr		_LVO\1(a6)
		Endm
*---------------------------------------------------------------------------*
; To keep the thing residentable, the library bases must not be an absolute
; label.  So instead of using CALLDOS, use CALLDFS.
CALLDFS		Macro
		move.l		mDOSBase(a5),a6
		jsr		_LVO\1(a6)
		Endm
*---------------------------------------------------------------------------*
CALLPP		Macro
		move.l		mPPBase(a5),a6
		jsr		_LVO\1(a6)
		Endm

*---------------------------------------------------------------------------*
*				 INITIALISE				    *
*---------------------------------------------------------------------------*
*************** Boring!
		
		move.l		a0,a2		; a2=Start of parameters
		move.l		#vars_SIZEOF,d0	; d0=Size of vars needed
		moveq		#0,d1		; Any memory will do
		CALLEXEC	AllocMem
		tst.l		d0		; Did we get any?
		bne.s		GotMem		; Branch if so
		moveq		#20,d0		; Fail code
		rts
GotMem		move.l		d0,a5		; a5=Variables base
		moveq		#20,d0		; Presume an error will occur
		move.l		d0,ReturnCode(a5)
		lea		DOSLib(pc),a1	; a1='dos.library'
		moveq		#0,d0		; Any version
		CALLSYS		OpenLibrary
		move.l		d0,mDOSBase(a5)	; Save base (no checking)
		CALLDFS		Output		; Get output handle
		move.l		d0,OutHandle(a5)
		lea		PPLib(pc),a1	; a1='powerpacker.library'
		moveq		#0,d0		; Any version
		CALLEXEC	OpenLibrary
		move.l		d0,mPPBase(a5)	; Save base
		bne.s		DoneInit	; If opened, all ok

*************** Couldn't open PowerPacker library, so print an error

		move.l		OutHandle(a5),d1; d1=CLI handle
		move.l		#NoPP,d2	; d2=Message
		moveq		#NoPPLen,d3	; d3=Length of message
		CALLDFS		Write		; Print it
		bra		CloseDOS

*---------------------------------------------------------------------------*
*			      CREATE PATHNAMES				    *
*---------------------------------------------------------------------------*

*************** First of all, check if usage is required

DoneInit	cmp.b		#'?',(a2)	; Query?
		bne.s		NotQuery	; No, all ok
		cmp.b		#10,1(a2)	; Just 1 char long?
		bne.s		NotQuery
		clr.l		ReturnCode(a5)	; No error!
PrintUsage	move.l		OutHandle(a5),d1; d1=Output handle
		move.l		#Usage,d2	; d2=Usage message
		moveq		#UsageLen,d3	; d3=Length of message
		CALLDFS		Write
		bra		ClosePP

***************	Not a query, so create pathnames

NotQuery	cmp.b		#10,(a2)	; If no parameters, print error
		beq.s		PrintUsage
		lea		SourcePath(a5),a3 ; a3=Place to put source
.Loop		move.b		(a2)+,(a3)+	; Copy a byte
		cmp.b		#33,(a2)	; Reached end of source?
		bcc.s		.Loop		; No, loop back
		cmp.b		#':',-1(a3)	; Is it a volume?
		beq.s		.Ok		; If so, name's ok
		move.b		#'/',(a3)+	; Otherwise add /
.Ok		clr.b		(a3)		; Null terminate it
.SkipSpace	cmp.b		#32,(a2)+	; Skip past any spaces
		beq.s		.SkipSpace
		subq.l		#1,a2		; Adjust after (a2)+
		cmp.b		#10,(a2)	; Check if end of params
		beq.s		PrintUsage	; Yep, then error!

*************** Check to see if there's a `TO' parameter.

		move.b		(a2),d0		; d0=Next character
		and.b		#$DF,d0		; Make it ucase
		cmp.b		#'T',d0		; Is it a 'T'?
		bne.s		CreateDest	; No, then quit
		move.b		1(a2),d0	; d0=Character after that
		and.b		#$DF,d0		; Make it ucase
		cmp.b		#'O',d0		; 'O'?
		bne.s		CreateDest	; No, quit
		cmp.b		#32,2(a2)	; A space after that?
		bne.s		CreateDest	; No.

		addq.l		#3,a2		; Skip past `to'
.SkipSpace1	cmp.b		#32,(a2)+	; Skip past any more spaces
		beq.s		.SkipSpace1
		subq.l		#1,a2		; Alter after (a2)+
		cmp.b		#10,(a2)	; End of params?
		beq.s		PrintUsage	; If so, print the error...

*************** Create destination pathname

CreateDest	lea		DestPath(a5),a4	; a4=Place to create dest path
.Loop		move.b		(a2)+,(a4)+	; Copy a byte
		cmp.b		#33,(a2)	; Reached end?
		bcc.s		.Loop		; No, then loop back
		cmp.b		#':',-1(a4)	; Is it a volume?
		beq.s		.Ok		; If so, leave it alone
		move.b		#'/',(a4)+	; Otherwise add / 
.Ok		clr.b		(a4)		; Null terminate name.
		move.l		a3,a0		; a0=End of source name

***************	If the source name is not a volume, copy the last dirname
;		across to the destination.

		lea		SourcePath(a5),a1 ; a1=Start of source name
		cmp.b		#':',-(a0)	; Was it a volume?
		beq.s		.NoCopy		; Yes, don't copy dir name
.Loop1		cmp.l		a0,a1		; Reached start of path?
		beq.s		.Copy1		; Branch if so
		move.b		-(a0),d0	; d0=Previous character
		cmp.b		#':',d0		; Volume?
		beq.s		.Copy
		cmp.b		#'/',d0		; Directory?
		bne.s		.Loop1		; Neither, loop back
.Copy		addq.l		#1,a0		; Skip : or /
.Copy1		move.b		(a0)+,(a4)+	; Copy rest of name
		bne.s		.Copy1		; Until NULL
		subq.l		#1,a4		; Alter after (a4)+

*************** Call the main routine

.NoCopy		moveq		#0,d7		; Error flag.
		bsr.s		DecrunchDir	; Decrunch it
		move.l		d7,ReturnCode(a5) ; Save return code

*---------------------------------------------------------------------------*
*			         CLEAN UP				    *
*---------------------------------------------------------------------------*

ClosePP		move.l		mPPBase(a5),a1
		CALLEXEC	CloseLibrary
CloseDOS	move.l		mDOSBase(a5),a1
		CALLEXEC	CloseLibrary
		move.l		ReturnCode(a5),d2
		move.l		a5,a1
		move.l		#vars_SIZEOF,d0
		CALLSYS		FreeMem
		move.l		d2,d0
		rts

*---------------------------------------------------------------------------*
*			       THE MAIN ROUTINE				    *
*---------------------------------------------------------------------------*

***************	Firstly, if the destination directory doesn't exits, create
;		it.

DecrunchDir	lea		DestPath(a5),a2	; a2=Filename
		move.l		a2,d1		; d1=Filename
		moveq		#ACCESS_READ,d2
		CALLDFS		Lock		; Lock it
		move.l		d0,d1		; d1=Lock
		bne.s		.UnLock		; If exists, unlock and cont.
		move.b		-1(a4),d5	; d5=Last char of pathname
		cmp.b		#'/',d5		; Is it a directory indicator
		bne.s		.Ok		; No, leave it alone
		clr.b		-1(a4)		; CreateDir doesn't like '/'
.Ok		move.l		a2,d1		; d1=Filename
		CALLSYS		CreateDir	; Create directory
		move.l		d0,d1		; d1=Lock of new directory
		beq		CantCreate	; Quit if can't create
		move.b		d5,-1(a4)	; Restore character
.UnLock		CALLSYS		UnLock		; Unlock directory.

***************	Lock and examine source directory.  A different FileInfoBlock
;		is needed for each lock since ExNext() uses the old contents
;		of the FIB to decide which is the next file.

		lea		SourcePath(a5),a0
		move.l		a0,d1		; d1=Source pathname
		moveq		#ACCESS_READ,d2	; d2=Lock type
		CALLSYS		Lock
		move.l		d0,d6		; d6=Lock
		beq		CantLock
		move.l		#fib_SIZEOF,d0	; d0=Size of FileInfoBlock
		moveq		#0,d1		; Any memory
		CALLEXEC	AllocMem
		tst.l		d0		; Enough left?
		beq.s		UnLock
		move.l		d0,a2		; a2=FileInfoBlock
		move.l		d0,d2		; d2=Same
		move.l		d6,d1		; d1=Lock
		CALLDFS		Examine		; Examine it

***************	Examine next file in directory

MainLoop	move.l		d6,d1		; d1=Lock
		move.l		a2,d2		; d2=Fib
		CALLDFS		ExNext		; Examine next file/dir
		tst.l		d0		; Any more left?
		beq.s		UnLock1		; No, then unlock and quit
		tst.l		fib_DirEntryType(a2)	; Is it a file?
		bmi.s		DecrunchFile		; Yep, decrunch it

***************	Directory: add name on and call DecrunchDir() again

		movem.l		d6/a2-4,-(sp)		; Save vital stuff
		lea		fib_FileName(a2),a0	; a0=DirName
.Loop		move.b		(a0)+,d0	; Copy dir name
		move.b		d0,(a3)+	; ...to source pathname
		move.b		d0,(a4)+	; ...and to destination path
		bne.s		.Loop		; Continue until NULL
		moveq		#'/',d0		; d0=Directory indicator
		move.b		d0,-1(a3)	; End pathnames with it
		move.b		d0,-1(a4)
		clr.b		(a3)		; Null terminate paths
		clr.b		(a4)
		bsr		DecrunchDir	; Decrunch the directory
		movem.l		(sp)+,d6/a2-4	; Retrieve regs
		tst.l		d7		; Fatal error?
		beq.s		MainLoop	; No, loop back

***************	Free memory used for fib

UnLock1		move.l		a2,a1		; a1=Fib memory
		move.l		#fib_SIZEOF,d0	; d0=Size of fib needed
		CALLEXEC	FreeMem		; Free it
UnLock		move.l		d6,d1		; d1=Lock of directory
		CALLDFS		UnLock		; Free it
		rts

***************	Add filename onto source and destination paths

DecrunchFile	movem.l		a2-4,-(sp)	    ; Save regs
		lea		fib_FileName(a2),a0 ; a0=Filename
.Loop		move.b		(a0)+,d0	; Copy filename to source
		move.b		d0,(a3)+	; and destination paths
		move.b		d0,(a4)+
		bne.s		.Loop		; until null found

***************	Use powerpacker.library to load and decrunch file

		moveq		#DECR_POINTER,d0    ; d0=Decrunch type
		moveq		#0,d1
		lea		SourcePath(a5),a0   ; a0=Path of file
		lea		FileBuffer(a5),a1   ; a1=Buffer Ptr
		lea		FileLength(a5),a2   ; a2=Length Ptr
		move.l		d1,a3
		CALLPP		ppLoadData	    ; Load file
		movem.l		(sp)+,a2-4
		tst.l		d0		    ; Success?
		bne		MainLoop	    ; No, ignore it

***************	Save the decrunched buffer as a file.

		lea		DestPath(a5),a0
		move.l		a0,d1		    ; d1=File to create
		move.l		#MODE_NEWFILE,d2    ; d2=Type of open
		CALLDFS		Open		    ; Open file
		move.l		d0,d5		    ; d5=FileHandle
		beq.s		CantOpen	    ; Print error if can't
		move.l		d0,d1		    ; d1=FileHandle
		move.l		FileBuffer(a5),d2   ; d2=Buffer
		move.l		FileLength(a5),d3   ; d2=Length
		CALLSYS		Write		    ; Write it
		tst.l		d0		    ; Did it work?
		beq.s		CantWrite	    ; No, then print error
		move.l		d5,d1		    ; d1=FileHandle
		CALLSYS		Close		    ; Close file
		move.l		FileBuffer(a5),a1   ; a1=Buffer
		move.l		FileLength(a5),d0   ; d0=Length
		CALLEXEC	FreeMem		    ; Free buffer
		bra		MainLoop	    ; Do next file/dir

***************	Error: couldn't create file

CantOpen	move.l		FileBuffer(a5),a1   ; a1=Buffer
		move.l		FileLength(a5),d0   ; d0=Length
		CALLEXEC	FreeMem		    ; Free buffer
		lea		OpenFormat(pc),a2   ; a2=String format
		bra.s		UnLockedError	    ; Unlock and print error

***************	Error: couldn't write to file (probably disk full)

CantWrite	move.l		d5,d1
		CALLSYS		Close
		lea		DestPath(a5),a0
		move.l		a0,d1
		CALLSYS		DeleteFile
		lea		WriteFormat(pc),a2   ; a2=String format
UnLockedError	move.l		d6,d1		     ; d1=Dir lock
		CALLDFS		UnLock		     ; Unlock it
		move.l		a2,a0		     ; a0=Format string
		bra.s		PrintF		     ; Do it

***************	Error: can't find the directory I want to lock.

CantLock	lea		LockFormat(pc),a0   ; a0=Format
		lea		SourcePath(a5),a2   ; a2=Pathname
		bra.s		PrintF1

***************	Error: can't create the destination directory.

CantCreate	lea		CreateFormat(pc),a0 ; a0=Format
PrintF		lea		DestPath(a5),a2	    ; a2=Pathname


***************	Use RawDoFmt() to create an error, then print it to the CLI
;		window.
; On entry ->	a0=Format string
;		a2=Pathname associated with error

PrintF1		lea		ReturnCode(a5),a1   ; a1=Unused long
		move.l		a2,(a1)		    ; Save pathname
		lea		PutCharProc(pc),a2  ; a2=PutChar procedure
		lea		FormatBuff(a5),a3   ; a3=String buffer
		CALLEXEC	RawDoFmt	    ; Create error string
		lea		FormatBuff(a5),a2   ; a2=Error
		move.l		a2,d2		    ; d2=Start of error
.Loop		tst.b		(a2)+		    ; Find end
		bne.s		.Loop
		move.b		#10,-1(a2)	    ; Add a line feed
		move.l		a2,d3		    ; d3=Length of error
		sub.l		d2,d3
		move.l		OutHandle(a5),d1    ; d1=CLI handle
		CALLDFS		Write		    ; Print error
		moveq		#20,d7		    ; Set error code
		rts
PutCharProc	move.b		d0,(a3)+	; Add char to DataStream
		rts

*---------------------------------------------------------------------------*
*			       STRING VARIABLES				    *
*---------------------------------------------------------------------------*

NoPP		dc.b	'I need the powerpacker.library to be in LIBS:',10
NoPPLen		equ	*-NoPP

Usage		dc.b	'Usage: DecrDir <source> [TO] <destination>',10
UsageLen	equ	*-Usage

LockFormat	dc.b	"Unable to locate %s",0
OpenFormat	dc.b	"Unable to create file %s",0
WriteFormat	dc.b	"Unable to write to file %s - file deleted",0
CreateFormat	dc.b	"Unable to create %s - decrunch aborted",0

DOSLib		dc.b	'dos.library',0
PPLib		dc.b	'powerpacker.library',0


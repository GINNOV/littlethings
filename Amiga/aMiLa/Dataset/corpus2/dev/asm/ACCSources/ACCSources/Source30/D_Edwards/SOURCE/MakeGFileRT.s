


		opt	d+



* Little utility to concatenate binary graphics files into one huge
* file.

* NOTE : The equate MEMF_VARS is defined in my own Exec include file.
* It is equivalent to:

*	MEMF_VARS	EQU	MEMF_PUBLIC+MEMF_CLEAR

* If you're missing any of the include files below, send me a disc &
* I'll send you copies...


* NAME		: MakeGraf

* FUNCTION	: Copy files & concatenate into one large file, in
*		  an order specified by the user. Intended primarily
*		  for building a single large sprite graphics file
*		  instead of using lots of little 'incbin' files in
*		  DevPac source.

* SYNOPSIS	: MakeGraf (from CLI)

*		  Or Click on Icon from WorkBench

* This latest version uses the reqtools.library to perform the file
* selection for the MANY source files that may be wanted. The user
* is invited to select source files in order via the reqtools file
* requester, and to click on the "Done" gadget when the last file
* has been copied across. This allows file concatenation in what-
* ever order the user desires unlike the CLI copy command, which
* copies in whatever order it encounters via the Examine()/ExNext()
* combination.


* Includes:


		include	Source:D_Edwards/INCLUDES/MyExec2.i
		include	Source:D_Edwards/INCLUDES/MyDos2.i
		include	Source:D_Edwards/INCLUDES/MyProcess2.i
		include	Source:D_Edwards/INCLUDES/MyHooks2.i
		include	Source:D_Edwards/INCLUDES/MyTagitem2.i
		include	Source:D_Edwards/INCLUDES/MyReqTools2.i


* Equates


_CSICHAR		equ	$9B


* My variables


DosBase		rs.l	1	;library base(s)
RTBase		rs.l	1
DummyLib		rs.l	1	;should be -1 after OpenAllLibs()

MyTaskID		rs.l	1	;My task handle

CLIparms		rs.l	1	;ptr to CLI parameters
CLIplen		rs.l	1	;size of CLI parameter string

WinHandle	rs.l	1	;new CON: window handle

SrcHandle	rs.l	1	;user's current source file handle
DstHandle	rs.l	1	;user's destination file handle

SrcLock		rs.l	1	;for use by Lock()
SrcInfo		rs.l	1	;FileInfoBlock

SrcName		rs.l	1	;ptrs to user-supplied file names
DstName		rs.l	1

FileBuf		rs.l	1	;start of file buffer
FileEnd		rs.l	1	;end of file buffer
FileSize		rs.l	1	;size of file buffer

NameBuffer	rs.l	1	;ptr to filename buffer

IOTSize		rs.l	1	;size of I/O transfer

IOTotal		rs.l	1	;total bytes copied across

WBStartMsg	rs.l	1	;WBStartup message if from WB

HelpReq		rs.l	1	;ptr to reReqInfo

UserReq		rs.l	1	;ptr to rtRequester for file selection

LibNames		rs.l	1	;ptr to library names

Vars_Sizeof	rs.w	0


* Macro to call a reqtools.library function


CALLRT		MACRO	\1

		move.l	a6,-(sp)
		move.l	RTBase(a6),a6
		jsr	\1(a6)
		move.l	(sp)+,a6

		ENDM


* Main program


Main		movem.l	d0/a0,-(sp)	;save any CLI parms

		moveq	#Vars_Sizeof,d0	;I want my variables
		move.l	#MEMF_VARS,d1
		CALLEXEC	AllocMem
		tst.l	d0		;got them?
		bne.s	Main_1		;skip if so

		movem.l	(sp)+,d0/a0	;else tidy stack
		rts			;and leave NOW...

Main_1		move.l	d0,a6		;my variable pointer

		bsr	InitVars		;initialise my variables

		movem.l	(sp)+,d0/a0	;recover CLI parms...
		move.l	a0,CLIparms(a6)
		move.l	d0,CLIplen(a6)

		sub.l	a1,a1
		CALLEXEC	FindTask		;who am I?
		move.l	d0,MyTaskID(a6)	;save me
		move.l	d0,a0		;ptr to Process

		tst.l	pr_CLI(a0)	;from CLI or WorkBench?
		bne.s	Main_CLI		;skip if from CLI


* Here, we're from WorkBench so do a GetMsg() on the WBStartup...


		lea	pr_MsgPort(a0),a0	;ptr to Process MsgPort
		CALLEXEC	GetMsg		;get the message
		move.l	d0,WBStartMsg(a6)	;and save ptr to it
		bra.s	Main_C1


* Here, we're from CLI, so start decoding any parameters.


Main_CLI		move.l	CLIparms(a6),a0
		move.l	CLIplen(a6),d0
		clr.b	-1(a0,d0.l)	;EOS out the trailing LF


* Come here once the prelimiaries are done.


Main_C1		bsr	OpenAllLibs	;open libraries
		beq	ByeBye		;skip if any opens failed

		lea	WinText(pc),a0
		move.l	a0,d1
		move.l	#MODE_NEW,d2
		CALLDOS	Open		;open window
		move.l	d0,WinHandle(a6)	;save handle
		beq	Leave		;can't get it-leave now

		move.l	#65536,d0	;64K should be enough...
		move.l	d0,FileSize(a6)
		move.l	#MEMF_VARS,d1
		CALLEXEC	AllocMem		;get my file I/O block
		move.l	d0,FileBuf(a6)	;save ptr
		beq	Leave		;oops-get out now...

		add.l	FileSize(a6),d0	;point to end of buffer
		move.l	d0,FileEnd(a6)	;save ptr

		move.l	#260,d0		;get a FileInfoBlock
		move.l	#MEMF_VARS,d1
		CALLEXEC	AllocMem
		move.l	d0,SrcInfo(a6)	;save ptr
		beq	Leave		;oops-get out now...

		move.l	#512,d0		;Get a file name buffer
		move.l	#MEMF_VARS,d1
		CALLEXEC	AllocMem
		move.l	d0,NameBuffer(a6)	;got it?
		beq	Leave


* Now get a file requester structure from the reqtools.library for
* use in file selection.


		moveq	#RT_FILEREQ,d0	;allocate a rtRequester
		sub.l	a0,a0
		CALLRT	rtAllocRequestA
		move.l	d0,UserReq(a6)	;got it?
		beq	Leave		;get out if not

		moveq	#RT_REQINFO,d0	;allocate a rtReqInfo
		sub.l	a0,a0
		CALLRT	rtAllocRequestA
		move.l	d0,HelpReq(a6)	;got it?
		beq	Leave		;get out if not

		lea	_P1(pc),a0	;pop up a prompt
		move.l	WinHandle(a6),d1
		bsr	WriteString


* Now pop up a help requester.


		lea	_IRB1(pc),a1	;body text list
		lea	_IRG1(pc),a2	;gadget text list
		move.l	HelpReq(a6),a3	;rtReqInfo
		sub.l	a4,a4		;no RawDoFmt() vars
		lea	_MyTags(pc),a0	;Taglist
		CALLRT	rtEZRequestA	;do it

		tst.l	d0		;help req wanted?
		beq.s	Main_NoHelp	;skip if not

		bsr	HelpUser


* Now pop up a file requester for the destination file name.


Main_NoHelp	move.l	UserReq(a6),a1
		move.l	FileBuf(a6),a2
		clr.b	(a2)		;null the string out!
		lea	_RT2(pc),a3
		lea	_MyTags(pc),a0
		CALLRT	rtFileRequestA

		tst.l	d0		;requester cancelled?
		bne.s	Main_Doit	;skip if not

;		beq	Leave		;exit if so


* Here tell user that operations were aborted.


		lea	_IRB4(pc),a1	;body text list
		lea	_IRG3(pc),a2	;gadget text list
		move.l	HelpReq(a6),a3	;rtReqInfo
		sub.l	a4,a4		;no RawDoFmt() vars
		lea	_MyTags(pc),a0	;Taglist
		CALLRT	rtEZRequestA	;do it

		bra	ByeBye


* Now create the full pathname for the destination file, and if a
* file name was given, open the file.


Main_Doit		move.l	NameBuffer(a6),a0
		move.l	UserReq(a6),a1
		move.l	rtfi_Dir(a1),a1

Main_C1a		move.b	(a1)+,(a0)+	;copy chars
		bne.s	Main_C1a		;until EOS hit

		subq.l	#2,a0		;point to last char
		cmp.b	#":",(a0)	;is it a volume separator?
		beq.s	Main_C1d		;skip if so
		cmp.b	#"/",(a0)	;is it a directory separator?
		beq.s	Main_C1b		;skip if so
		addq.l	#1,a0		;else point to EOS
		move.b	#"/",(a0)+	;insert directory separator
		bra.s	Main_C1b		;and continue

Main_C1d		addq.l	#1,a0		;point past volume separator!

Main_C1b		move.l	FileBuf(a6),a1	;ptr to obtained file name

		tst.b	(a1)		;any filename given?
		beq	Leave		;skip if not

Main_C1c		move.b	(a1)+,(a0)+	;copy chars
		bne.s	Main_C1c		;until EOS hit

;		lea	_P2(pc),a0	;pop up another prompt
;		move.l	WinHandle(a6),d1	;& ask for destination
;		bsr	WriteString	;file name

;		move.l	FileBuf(a6),a0
;		move.l	WinHandle(a6),d1
;		bsr	ReadFixStr
;		move.l	FileBuf(a6),a0
;		clr.b	-1(a0,d0.l)	;remove trailing LF

;		move.l	a0,d1

		move.l	NameBuffer(a6),d1
		move.l	#MODE_NEW,d2	;new file
		CALLDOS	Open		;open destination file
		move.l	d0,DstHandle(a6)	;got it?
		bne.s	Main_C3		;skip if we have


* Here, we can't open the destination file. So report to user and
* then exit.


		lea	_E1(pc),a0
		move.l	WinHandle(a6),d1
		bsr	WriteString

		move.l	NameBuffer(a6),a0
		move.l	WinHandle(a6),d1
		bsr	WriteString

		lea	_CRLF(pc),a0
		move.l	WinHandle(a6),d1
		bsr	WriteString

		bra.s	Leave


* Here, inform user that destination file is open & ready to
* receive data.


Main_C3		move.l	NameBuffer(a6),a0
		move.l	WinHandle(a6),d1
		bsr	WriteString

		lea	_P9(pc),a0
		move.l	WinHandle(a6),d1
		bsr	WriteString


* Here, start requesting source files in order & transferring the
* file contents over.


Main_C2		move.l	UserReq(a6),a1
		move.l	FileBuf(a6),a2
		clr.b	(a2)		;null the string out!
		lea	_RT1(pc),a3
		lea	_MyTags(pc),a0
		CALLRT	rtFileRequestA

		tst.l	d0		;requester cancelled?
		beq	Leave		;exit if so


* Here, copy the directory name from the FileRequester into
* my own name buffer


		move.l	NameBuffer(a6),a0
		move.l	UserReq(a6),a1
		move.l	rtfi_Dir(a1),a1

Main_C2a		move.b	(a1)+,(a0)+	;copy chars
		bne.s	Main_C2a		;until EOS hit

		subq.l	#2,a0		;point to last char
		cmp.b	#":",(a0)	;is it a volume separator?
		beq.s	Main_C2d		;skip if so
		cmp.b	#"/",(a0)	;is it a directory separator?
		beq.s	Main_C2b		;skip if so
		addq.l	#1,a0		;else point to EOS
		move.b	#"/",(a0)+	;insert directory separator
		bra.s	Main_C2b		;and continue

Main_C2d		addq.l	#1,a0		;point past volume separator!

Main_C2b		move.l	FileBuf(a6),a1	;ptr to obtained file name

		tst.b	(a1)		;any filename given?
		beq.s	Leave		;skip if not

Main_C2c		move.b	(a1)+,(a0)+	;copy chars
		bne.s	Main_C2c		;until EOS hit

;		lea	_P3(pc),a0	;prompt for file name
;		move.l	WinHandle(a6),d1
;		bsr	WriteString

;		move.l	FileBuf(a6),a0	;read file name in
;		move.l	WinHandle(a6),d1
;		bsr	ReadFixStr

;		move.l	NameBuffer(a6),a0	;get buffer ptr
;		clr.b	-1(a0,d0.l)	;remove end linefeed
;		move.b	(a0),d0
;		beq.s	Leave		;leave if no name given

		bsr	PipeFile		;transfer file contents

		bra.s	Main_C2		;and back for another


* Here close the destination file & report total bytes copied.


Leave		move.l	IOTotal(a6),d0
		move.l	NameBuffer(a6),a0
		bsr	LtoA10
		move.l	WinHandle(a6),d1
		bsr	WriteString

		lea	_P7(pc),a0
		move.l	WinHandle(a6),d1
		bsr	WriteString

;		lea	_P8(pc),a0
;		move.l	WinHandle(a6),d1
;		bsr	WriteString

		lea	_IRB3(pc),a1	;body text list
		lea	_IRG3(pc),a2	;gadget text list
		move.l	HelpReq(a6),a3	;rtReqInfo
		lea	IOTotal(a6),a4	;RawDoFmt() vars ptr
		lea	_MyTags(pc),a0	;Taglist
		CALLRT	rtEZRequestA	;do it

;		move.l	NameBuffer(a6),a0
;		move.l	WinHandle(a6),d1
;		bsr	ReadFixStr

ByeBye		move.l	DstHandle(a6),d1	;file exists?
		beq.s	CheckCLI		;skip if not
		CALLDOS	Close		;else close the file


* Here do the Forbid()/ReplyMsg() sequence needed by WorkBench if we're
* called from WB...


CheckCLI		move.l	MyTaskID(a6),a0
		tst.l	pr_CLI(a0)	;CLI or WB?
		bne.s	BackToCLI	;skip if from CLI


* Here we're from WB so go do it...


		CALLEXEC	Forbid

		move.l	WBStartMsg(a6),a1
		CALLEXEC	ReplyMsg

		bra.s	CleanUp


* Here it's back to normal cleaning up...


BackToCLI	nop

CleanUp		nop

CockUp7		move.l	HelpReq(a6),d0	;got a rtReqInfo?
		beq.s	CockUp6		;skip if not
		move.l	d0,a1
		CALLRT	rtFreeRequest	;else remove it

CockUp6		move.l	UserReq(a6),d0	;got a rtRequester?
		beq.s	CockUp5		;skip if not
		move.l	d0,a1
		CALLRT	rtFreeRequest	;else remove it

CockUp5		move.l	NameBuffer(a6),d0	;got a file name buffer?
		beq.s	CockUp4		;skip if not
		move.l	d0,a1
		move.l	#512,d0
		CALLEXEC	FreeMem		;else release it

CockUp4		move.l	SrcInfo(a6),d0	;FileInfoBlock exists?
		beq.s	CockUp3		;skip if not
		move.l	d0,a1
		move.l	#260,d0
		CALLEXEC	FreeMem		;now deallocate it

CockUp3		move.l	FileBuf(a6),d0	;file buffer exists?
		beq.s	CockUp2		;skip if not
		move.l	d0,a1
		move.l	FileSize(a6),d0
		CALLEXEC	FreeMem		;now deallocate it

CockUp2		move.l	WinHandle(a6),d0	;window open?
		beq.s	CockUp1		;skip if not
		move.l	d0,d1
		CALLDOS	Close		;close it if so

CockUp1		bsr	CloseAllLibs

		move.l	a6,a1		;deallocate my vars
		moveq	#Vars_Sizeof,d0
		CALLEXEC	FreeMem

__Done		rts


* InitVars(a6)
* a6 = ptr to main program variables

* Initialise all variables that need it. Since i'm using MEMF_CLEAR
* all the ones to be zero will already be thus set.

* a0 corrupt


InitVars		lea	LibTexts(pc),a0	;ptr to library names
		move.l	a0,LibNames(a6)

		rts


* OpenAllLibs(a6) -> D0,A1
* a6 = ptr to main program variables
* Open all libraries required.

* Returns:

* D0=-1 if all libraries opened successfully.

* If any opens failed:
* D0=NULL, A1=ptr to library name of failed library

* a2 corrupt


OpenAllLibs	move.l	LibNames(a6),a1	;get ptr to library names
		lea	DosBase(a6),a2	;ptr to library bases

OAL_1		moveq	#0,d0		;any version will do
		movem.l	a1-a2,-(sp)	;save pointers
		CALLEXEC	OpenLibrary	;open the library
		movem.l	(sp)+,a1-a2	;recover pointers
		move.l	d0,(a2)+		;save library base
		beq.s	OAL_3		;oops-failure

OAL_2		tst.b	(a1)+		;skip to next
		bne.s	OAL_2		;library name

		tst.b	(a1)		;last library in list?
		bne.s	OAL_1		;back for more if not

		moveq	#-1,d0		;signal success
		move.l	d0,(a2)		;and signal end of lib bases

OAL_3		rts			;done!


* CloseAllLibs(a6)
* a6 = ptr to main program variables

* Close all libraries opened by OpenAllLibs().

* d0-d1/a0 corrupt


CloseAllLibs	lea	DosBase(a6),a0
		moveq	#-1,d1

CAL_1		move.l	(a0)+,d0		;this library open?
		beq.s	CAL_2		;exit if not
		cmp.l	d1,d0		;end of list?
		beq.s	CAL_2		;exit if so
		move.l	a0,-(sp)		;save ptr
		move.l	d0,a1
		CALLEXEC	CloseLibrary	;close the library
		move.l	(sp)+,a0
		bra.s	CAL_1		;and back for more

CAL_2		rts			;done!


* StrLen(a0) -> d7
* a0 = ptr to ASCIIZ string
* Returns length of string in d7.

* No other registers corrupt


StrLen		moveq	#0,d7		;initial char count
		move.l	a0,-(sp)		;save string ptr

StrLen_1		tst.b	(a0)+		;EOS met?
		beq.s	StrLen_2		;skip if so
		addq.l	#1,d7		;else update char count
		bra.s	StrLen_1		;and back for more

StrLen_2		move.l	(sp)+,a0
		rts


* WriteString(a0,d1)
* a0 = ptr to string
* d1 = ptr to DOS device to write to

* Write a string to a DOS device.

* d2-d3/d7 corrupt


WriteString	bsr	StrLen		;get string length
		move.l	d7,d3		;no. of chars to write
		move.l	a0,d2		;ptr to string
		CALLDOS	Write		;go do it!
		rts


* ReadFixStr(a0,d1)
* a0 = ptr to buffer into which to read string
* d1 = ptr to DOS device to read from

* Read a string from a DOS device. The MAXIMUM length is 256 bytes!

* d2-d3/d7 corrupt


ReadFixStr	move.l	a0,d2		;ptr to buffer
		moveq	#0,d3
		move.w	#256,d3		;max 256 bytes
		CALLDOS	Read		;go read it
		rts


* PipeFile(a6)
* a6 = ptr to main program variables
* Copy a file's contents to the specified destination
* and perform the transfer in 64K blocks if the file is
* larger than 64K.

* DO NOT CALL THIS BEFORE READING THE FILE NAME INTO THE I/O BUFFER
* OR STRANGE THINGS WILL HAPPEN!

* d0-d3/a0 corrupt


PipeFile		move.l	NameBuffer(a6),d1	;ptr to file name
		move.l	#ACCESS_READ,d2
		CALLDOS	Lock
		move.l	d0,SrcLock(a6)	;save lock
		beq	PPF_X1		;skip if can't get lock!

		move.l	d0,d1
		move.l	SrcInfo(a6),d2
		CALLDOS	Examine		;get file info

		move.l	SrcLock(a6),d1	;free the lock
		CALLDOS	UnLock

		move.l	SrcInfo(a6),a0	;get ptr to file info
		move.l	124(a0),d0	;get file size
		move.l	d0,IOTSize(a6)


* Now we have the size of the file, begin the file transfer.


		move.l	NameBuffer(a6),d1	;open the file
		move.l	#MODE_OLD,d2
		CALLDOS	Open
		move.l	d0,SrcHandle(a6)	;got it?
		bne.s	PPF_L1		;skip if so


* Here we can't open the file so get out now.


;		lea	_E1(pc),a0	;print error message
;		move.l	WinHandle(a6),d1
;		bsr	WriteString

;		move.l	NameBuffer(a6),a0
;		move.l	WinHandle(a6),d1
;		bsr	WriteString

		lea	_IRBE1(pc),a1	;body text list
		lea	_IRG2b(pc),a2	;gadget text list
		move.l	HelpReq(a6),a3	;rtReqInfo
		lea	NameBuffer(a6),a4	;RawDoFmt() vars ptr
		lea	_MyTags(pc),a0	;Taglist
		CALLRT	rtEZRequestA	;do it


		rts


* Here, file is open, so start the I/O.


PPF_L1		move.l	IOTSize(a6),d0	;check file size
		cmp.l	FileSize(a6),d0	;more than 64K?
		bcs.s	PPF_B1		;skip if not


* Here transfer 64K blocks for larger files.


		move.l	FileSize(a6),d3	;read a 64K block
		move.l	FileBuf(a6),d2
		move.l	SrcHandle(a6),d1
		CALLDOS	Read

		move.l	FileSize(a6),d3	;write a 64K block
		move.l	FileBuf(a6),d2
		move.l	DstHandle(a6),d1
		CALLDOS	Write

		move.l	IOTSize(a6),d0	;size of remaining file
		sub.l	FileSize(a6),d0
		move.l	d0,IOTSize(a6)

		bra.s	PPF_L1		;continue transfer


* Here transfer whatever portion is smaller than 64K. If the file is
* an exact multiple of 64K in size, check for a zero-byte block &
* exit if found.


PPF_B1		tst.l	d0		;exact multiple of 64K?
		beq.s	PPF_B2		;skip if so

		move.l	IOTSize(a6),d3	;read block
		move.l	FileBuf(a6),d2
		move.l	SrcHandle(a6),d1
		CALLDOS	Read

		move.l	IOTSize(a6),d3	;write block
		move.l	FileBuf(a6),d2
		move.l	DstHandle(a6),d1
		CALLDOS	Write


* And now we're done. Close the file & leave.


PPF_B2		move.l	SrcHandle(a6),d1
		CALLDOS	Close

		lea	_P4(pc),a0	;print msg part 1
		move.l	WinHandle(a6),d1
		bsr	WriteString

		move.l	NameBuffer(a6),a0	;print file name
		move.l	WinHandle(a6),d1
		bsr	WriteString

		lea	_P5(pc),a0	;print msg part 2
		move.l	WinHandle(a6),d1
		bsr	WriteString

		move.l	SrcInfo(a6),a0
		move.l	124(a0),d0	;get file size
		move.l	IOTotal(a6),d1
		add.l	d0,d1
		move.l	d1,IOTotal(a6)	;total copied so far
		move.l	FileBuf(a6),a0
		bsr	LtoA10		;make ASCIIZ string
		move.l	WinHandle(a6),d1	;print it
		bsr	WriteString

		lea	_P6(pc),a0	;print msg part 3
		move.l	WinHandle(a6),d1
		bsr	WriteString

		rts


* Come here if we can't get a lock on the file.


PPF_X1		lea	_IRBE4(pc),a1	;body text list
		lea	_IRG2b(pc),a2	;gadget text list
		move.l	HelpReq(a6),a3	;rtReqInfo
		lea	NameBuffer(a6),a4	;RawDoFmt() vars ptr
		lea	_MyTags(pc),a0	;Taglist
		CALLRT	rtEZRequestA	;do it


;		lea	_E2(pc),a0
;		move.l	WinHandle(a6),d1
;		bsr	WriteString

;		move.l	NameBuffer(a6),a0
;		move.l	WinHandle(a6),d1
;		bsr	WriteString

;		lea	_CRLF(pc),a0
;		move.l	WinHandle(a6),d1
;		bsr	WriteString

		rts


* HelpUser(a6)
* a6 = ptr to main program variables

* Pop up series of help requesters as needed by user
* if help is wanted.

* corrupt


HelpUser		lea	_IRB2a(pc),a1	;body text list
		lea	_IRG2a(pc),a2	;gadget text list
		move.l	HelpReq(a6),a3	;rtReqInfo
		sub.l	a4,a4		;no RawDoFmt() vars
		lea	_MyTags(pc),a0	;Taglist
		CALLRT	rtEZRequestA	;do it

		tst.l	d0		;more help wanted?
		bne.s	HU_1		;continue if so

		rts

HU_1		lea	_IRB2b(pc),a1	;body text list
		lea	_IRG2a(pc),a2	;gadget text list
		move.l	HelpReq(a6),a3	;rtReqInfo
		sub.l	a4,a4		;no RawDoFmt() vars
		lea	_MyTags(pc),a0	;Taglist
		CALLRT	rtEZRequestA	;do it

		tst.l	d0		;more help wanted?
		bne.s	HU_2		;continue if so

		rts

HU_2		lea	_IRB2c(pc),a1	;body text list
		lea	_IRG2b(pc),a2	;gadget text list
		move.l	HelpReq(a6),a3	;rtReqInfo
		sub.l	a4,a4		;no RawDoFmt() vars
		lea	_MyTags(pc),a0	;Taglist
		CALLRT	rtEZRequestA	;do it

		rts



* LtoA10(a0,d0)
* a0 = ptr to buffer
* d0 = long int to convert

* Convert long int to a decimal ASCIIZ string.


LtoA10		lea	_Base10(pc),a1	;get powers of 10


* ...and fall through to...


* LtoA(a0,a1,d0)
* a0 = ptr to buffer
* a1 = ptr to powers of N
* d0 = long int to convert

* Convert long int to ASCIIZ string.

* This version only works for bases 2 to 10. For bases 11 upwards
* a different version needs to be written.

* d1-d2/a2 corrupt


LtoA		tst.l	d0		;X = 0?
		bne.s	LtoA_1		;skip if not
		move.b	#"0",(a0)	;this is the safer way
		clr.b	1(a0)		;of doing it-no Gurus
		rts			;and done

LtoA_1		move.l	a0,a2		;copy string buffer ptr

LtoA_2		move.l	(a1)+,d1		;get P = power of N
		cmp.l	d1,d0		;while X < P
		bcs.s	LtoA_2		;back for next P


* Now, we've found a P such that X >=P. Now begin conversion proper.


LtoA_3		moveq	#0,d2		;value of this digit

LtoA_4		cmp.l	d1,d0		;X < P?
		bcs.s	LtoA_5		;skip if X < P
		addq.b	#1,d2		;digit = digit + 1
		sub.l	d1,d0		;X = X - P
		bra.s	LtoA_4		;and resume test

LtoA_5		add.b	#"0",d2		;make ASCII digit
		move.b	d2,(a2)+		;store in string buffer

		move.l	(a1)+,d1		;get next P
		bne.s	LtoA_3		;back for more P <> 0

		clr.b	(a2)		;append EOS

		rts			;done!!!


* Some powers of 10


_Base10		dc.l	1000000000,100000000,10000000
		dc.l	1000000,100000,10000,1000,100
		dc.l	10,1,0


* Statically initialised TagItem array (all this just to create a
* file requester? PAH!)


_MyTags		dc.l	RT_ReqPos
		dc.l	REQPOS_CENTERSCR
		dc.l	TAG_END
		dc.l	0


* Library names. These MUST be in the same order as the library base
* variables in the main variable block!


LibTexts		dc.b	"dos.library",0		;DOS library name
		dc.b	"reqtools.library",0
		dc.b	0			;end of list marker


* Window spec...


WinText		dc.b	"CON:0/22/640/140/Make Single File",0


* Prompts etc...


_P1		dc.b	_CSICHAR
		dc.b	"0;32;40m"
		dc.b	"MakeGraf Version 1.4 Reqtools Version"
		dc.b	_CSICHAR
		dc.b	"0;31;40m"
		dc.b	" By Dave Edwards"
		dc.b	10

_CRLF		dc.b	10,0

_P2		dc.b	"Specify Destination File : ",0

_P3		dc.b	"Specify Source File      : ",0

_P4		dc.b	"File "
		dc.b	34,0

_P5		dc.b	34
		dc.b	", ",0

_P6		dc.b	" Bytes Copied Across"
		dc.b	10,0

_P7		dc.b	" Bytes Total Copied Across."
		dc.b	10,0

_P8		dc.b	"Press RETURN/ENTER To Finish.",10,0

_P9		dc.b	" Ready To Receive Data",10,0

_RT1		dc.b	"Select Source File ->",0

_RT2		dc.b	"Select Destination File ->",0

_IRB1		dc.b	"Do You Require Information",10
		dc.b	"About Using This Program ?",0

_IRG1		dc.b	"Yes|No",0

_IRB2a		dc.b	" A File Requester  Will Appear. ",10
		dc.b	" The  First One  Allows  You To ",10
		dc.b	" Select A  Destination File For ",10
		dc.b	" The Copy. Select The Directory ",10
		dc.b	" And Then The File. If The File ",10
		dc.b	"Does Not Exist, Type In The Name",10
		dc.b	"Of  The  New  File  In  The File",10
		dc.b	"      Requester Name Box.",0

_IRB2b		dc.b	" All Subsequent File Requesters ",10
		dc.b	"That  Appear  Are For  Selecting",10
		dc.b	"Source  Files   To  Concatenate.",10
		dc.b	" Select Them In The Same Way, & ",10
		dc.b	"  In Whatever Order You Wish.   ",10
		dc.b	10,10,10
		dc.b	0

_IRB2c		dc.b	"To Finish Copying, Simply Click",10
		dc.b	" On The 'Cancel' Gadget Or Hit ",10
		dc.b	"'ENTER' With No Filename In The",10
		dc.b	"Requester  Filename  Box.  This",10
		dc.b	"Applies To ALL File Requesters,",10
		dc.b	"So  You Can  Quit At  Any Time!",10
		dc.b	10,0

_IRG2a		dc.b	"More|Done",0

_IRG2b		dc.b	"Continue",0

_IRB3		dc.b	"Copy Operation Complete !",10
		dc.b	"%ld Bytes Total Copied.",0

_IRG3		dc.b	"Finished",0

_IRB4		dc.b	"Program Aborted.",0


* Body texts for Error Requesters


_IRBE1		dc.b	"Cannot Open The File",10
		dc.b	34,"%s",34,0

_IRBE2		dc.b	"Cannot Read The File",10,10
		dc.b	34,"%s",34,0

_IRBE3		dc.b	"Cannot Write To The File",10,10
		dc.b	34,"%s",34,0

_IRBE4		dc.b	"Cannot Obtain A Lock On The File",10,10
		dc.b	34,"%s",34,0


* Error messages


_E1		dc.b	"Cannot Open File ",0

_E2		dc.b	"Cannot Obtain Lock For File ",0

_E3		dc.b	"Cannot Read File ",0

_E4		dc.b	"Cannot Write File ",0






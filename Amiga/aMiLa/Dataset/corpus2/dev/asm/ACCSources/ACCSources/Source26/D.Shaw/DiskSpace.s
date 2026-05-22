
; Small program to try and simulate system info command.

; Code will assemble and can be launched from WB or CLI. Opens an Console
; window if run from the WorkBench and uses this for i/o.

; A number of useful subroutines are also included. See documentation.

; © D.Shaw, July 1992.

; Thanks Mark for some very useful Subroutines, and the startup codes.

		opt 		o+,ow-

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"

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

; ************
 		bsr		Main		Your routine

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

.lib_error	rts


*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		tst.l		returnMsg	are we from WorkBench?
		bne.s		.ok		if so quit!

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


***************	Release any additional resources used


DeInit
		rts


***************	Close all open libraries

; Closes any libraries the program managed to open.

Closelibs	move.l		_DOSBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts


************** The main part of the program starts here.

; Get the args and find which drive Number.

Main		move.l		_args,a0		a0->Drive No
		
		cmpi.b		#'0',(a0)		0=DF0:
		beq		_Internal

		cmpi.b		#'1',(a0)		1=DF1:
		beq		_External1
		
		cmpi.b		#'2',(a0)		2=DF2:
		beq		_External2
		
		cmpi.b		#'3',(a0)		3=DF3:
		beq		_External3

_Internal	lea		Name0,a0		a0->df0 name
		bsr		_DoInfo
		
		bra		_WriteInfo
						
_External1	lea		Name1,a0
		bsr		_DoInfo
		
		bra		_WriteInfo

_External2	lea		Name2,a0
		bsr		_DoInfo
		
		bra		_WriteInfo

_External3	lea		Name3,a0
		bsr		_DoInfo
		

; Write Header and Drive text.

_WriteInfo	lea		Header,a0		a0->header text
		bsr		DosMsg
		move.l		#REFinfo,a1		a1->info data
		move.l		id_UnitNumber(a1),d0	d0= drive number

; Find out which drive it is.

		cmpi.l		#0,d0
		beq.s		df0
		
		cmpi.l		#1,d0
		beq.s		df1
		
		cmpi.l		#2,d0
		beq.s		df2
		
		cmpi.l		#3,d0
		beq.s		df3
		
; Print the drive name and tab to next position.

df0		lea		Name0,a0		a0->Drive name
		bsr		DosMsg
		lea		Tab,a0			a0->Tab char
		bsr		DosMsg
		bra		DoSize
		
df1		lea		Name1,a0
		bsr		DosMsg
		lea		Tab,a0
		bsr		DosMsg
		bra		DoSize
		
df2		lea		Name2,a0
		bsr		DosMsg
		lea		Tab,a0
		bsr		DosMsg
		bra		DoSize

df3		lea		Name3,a0
		bsr		DosMsg
		lea		Tab,a0
		bsr		DosMsg
		
; Print the Number of blocks on the disk.

DoSize		move.l		#REFinfo,a1		a1->Info
		move.l		id_NumBlocks(a1),d0	d0=Num blocks
		beq		NoDisk			No blocks
	
		bsr		ConvAscii		Convert dec
		bsr		Print			Display

; Print the number of blocks used.

		move.l		id_NumBlocksUsed(a1),d0	  d0=Blocks used
		bsr		ConvAscii		Convert
		bsr		Print			Display

; Print number of blocks free.
		
		move.l		id_NumBlocks(a1),d0	d0=Num blocks
		move.l		id_NumBlocksUsed(a1),d1  d1=Blocks used
		
		sub.l		d1,d0			d0=Free blocks
		bsr		ConvAscii		convert
		bsr		Print			Display

; Print number of errors on the disk.
		
		move.l		id_NumSoftErrors(a1),d0  d0=Num errors
		bsr		ConvAscii		convert
		bsr		Print			Display
		
		Bra		Status			

; Print the values here.
		
Print		lea		AsciiNum,a0		Converted Num
		bsr		DosMsg			Display
		lea		Tab,a0			tab
		bsr		DosMsg
		rts

; Find out disk status and print the infomation.

Status		move.l		id_DiskState(a1),d0	d0=Diskstate
		cmpi.l		#80,d0			Compare
		beq.s		Protected	
		
		cmpi.l		#81,d0			compare
		beq.s		Repaired
		
		cmpi.l		#82,d0			compare
		beq.s		Writeable
		
; The disk is write protected, print the info.

Protected	lea		Prot,a0
		bsr		DosMsg
		bra		Diskname
		
; The disk is being repaired, validated, print the info.

Repaired	lea		Rep,a0
		bsr		DosMsg
		bra		Diskname
		
; The disk is write enabled, print the info.

Writeable	lea		Write,a0
		bsr		DosMsg
		
; Find the disk name and print it.

Diskname	move.l		id_VolumeNode(a1),d0	
		
		asl.l		#2,d0
		move.l		d0,a4
		move.l		dl_Name(a4),d0		d0=BPTR
		asl.l		#2,d0			Convert
		move.l		d0,a0			a0->BSTR
		bsr		BPrintNL
		rts
		
; No disk present print msg and exit.

NoDisk		lea		NoMsg,a0		a0->Msg
		bsr		DosMsg
		rts
			
*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

****************

; Function	Subroutine using Exec RawDoFormat to convert
;		Hex Value to ascii decimal. Decimal value is stored
;		in var AsciiNum.

; Entry		d0= Hex number

; Exit		None

; Corrupt	None


ConvAscii	movem.l		d0/a0-a3,-(sp)

		move.l		d0,DataStream		and store value
		
		lea		Template,a0		format string
		lea		DataStream,a1		data
		lea		PutChar,a2		subroutine
		lea		AsciiNum,a3		buffer
		CALLEXEC	RawDoFmt		create text string

		moveq.l		#1,d0			no errors
		
		movem.l		(sp)+,d0/a0-a3

.error		rts

PutChar		move.b		d0,(a3)+		save next character
		rts					and return

****************

; Function 	Subroutine to get disk InfoData.

; Entry		a0-> Drive name

; Exit		a0-> Ptr Info

; Corrupt	a0

; Note		Dos library must be open. Variable REFinfo_data should
;		be declared eg: 
;				REFinfo 	ds.b	36


_DoInfo		movem.l		d0/d1/d2/d6/d7/a6,-(sp)	save regs

		move.l		a0,a6			copy name

; Lock the file.

		move.l		a6,d1			name
		move.l		#ACCESS_READ,d2		mode
		CALLDOS		Lock
		move.l		d0,d7			save lock
		beq.s		.error
		
; Now read in the info block.

		move.l		d7,d1			d1=Lock
		move.l		#REFinfo,d2		d2=36 bytes for info
		CALLDOS		Info			Get info
	
		move.l		d2,d6
		
; Unlock the file.
		
		move.l		d7,d1
		CALLDOS		UnLock
		
		move.l		d6,a0			ptr to info data
		
; Ok got all the info.

.error		movem.l		(sp)+,d0/d1/d2/d6/d7/a6
		rts
		

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

***************	Converts text string to upper case.

;Entry		a0->start of null terminated text string

;Exit		a0->end of text string ( the zero byte ).

;corrupted	a0

ucase		tst.b		(a0)
		beq.s		.error
		
.loop		cmpi.b		#'a',(a0)+
		blt.s		.ok
		
		cmp.b		#'z',-1(a0)
		bgt.s		.ok
		
		subi.b		#$20,-1(a0)
		
.ok		tst.b		(a0)
		bne.s		.loop
		
.error		rts


***************	Subroutine to display any message in the CLI window

; Prints a line feed after the message

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

PrintNL		movem.l		d0-d3/a0-a3,-(sp) save registers

		bsr		Print

;--------------	Print a line feed

		move.l		STD_OUT,d1
		beq.s		.error
		move.l		#EOL_byte,d2
		moveq.l		#1,d3
		CALLDOS		Write

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3 restore registers
		rts



;--------------
;--------------	Routine to print a BSTRING into the CLI, no EOL.
;--------------

; Entry		a0->BSTR

; Exit		none

; Corrupt	none

BPrint		movem.l		d0-d4/a0-a6,-(sp)

		moveq.l		#0,d3			clear
		move.b		(a0)+,d3		string length
		beq.s		.done			skip if NULL
		
		move.l		STD_OUT,d1		handle
		move.l		a0,d2			address
		CALLDOS		Write			print it

.done		movem.l		(sp)+,d0-d4/a0-a6
		rts

;--------------
;--------------	Print a BSTR followed by a new line
;--------------

BPrintNL	movem.l		d0-d4/a0-a6,-(sp)

		bsr		BPrint

;--------------	Print a line feed

		move.l		STD_OUT,d1
		beq.s		.error
		move.l		#EOL_byte,d2
		moveq.l		#2,d3
		CALLDOS		Write

.error		movem.l		(sp)+,d0-d4/a0-a6
		rts


*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even

Template	dc.b		'%ld',0
		even
		
Name0		dc.b		'DF0:',0
		even
		
Name1		dc.b		'DF1:',0
		even
		
Name2		dc.b		'DF2:',0
		even
		
Name3		dc.b		'DF3:',0
		even
		
Tab		dc.b		$09			Tab char
		dc.b		0
		
EOL_byte	dc.b		$0a,$0a			
		even
		
Header		dc.b		$0a
		dc.b		$9b,"0;33;40m"		Turn on bold text
		dc.b		'Unit'			Text
		dc.b		$09			Tab 
		dc.b		'Size'
		dc.b		$09
		dc.b		'Used'
		dc.b		$09
		dc.b		'Free'
		dc.b		$09
		dc.b		'Errs'
		dc.b		$09
		dc.b		'Status'
		dc.b		$09,$09
		dc.b		'Name'
		dc.b		$0a			Linefeed
		dc.b		$9b,"0;31;40m"
		dc.b		0

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		$9b,"3;33;40m",'DiskSpace Vr1.0 © Davie Shaw 1992'
		dc.b		$9b,"0;31;40m",$0a
		dc.b		'Type Diskspace DRIVE:'
		dc.b		$0a
		dc.b		'eg: Diskspace 0-3'
		dc.b		$0a,$0a
		dc.b		0
		even

Prot		dc.b		'Read Only',$09,0
		even

Rep		dc.b		'Not validated',$09,0
		even
		
Write		dc.b		'Read/Write',$09,0
		even		

NoMsg		dc.b		'No Disk Present',$0a,$0a,0
		even		
		
;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1

_DOSBase	ds.l		1

RFfile_lock	ds.l		1
RFfile_info	ds.l		1
RFfile_name	ds.l		1
RFfile_len	ds.l		1
DataStream	ds.l		1
STD_OUT		ds.l		1
AsciiNum	ds.b		40		
		even
REFinfo		ds.b		36
		even
		end


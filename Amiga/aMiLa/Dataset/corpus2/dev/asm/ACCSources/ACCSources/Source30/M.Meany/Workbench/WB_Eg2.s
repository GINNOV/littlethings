
;Purpose	To investigate an icons ToolTypes
;Programmer	M.Meany
;Date		January 1993
;Machine	Amiga A12OO
;Assembler	Devpac 3

***************	Include header files

		incdir		sys:Include/
		include		exec/exec.i
		include		exec/exec_lib.i
		include		libraries/dos_lib.i
		include		libraries/dos.i
		include		libraries/dosextens.i
		include		Workbench/workbench.i
		include		Workbench/startup.i
		include		Workbench/icon_lib.i
		include		Misc/easystart.i


		incdir		Source:M.Meany/subs/
		include		macros.i
		
***************	Program Starts Here

; Enter here with a0/d0 still set if called from CLI, or returnMsg set if
;called from WorkBench. If called from CLI display a message and exit!

; Open dos library

Start		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		Error

; If called from CLI/Shell, display an error message and exit.

		tst.l		returnMsg
		bne.s		IsWB
		
		CALLDOS		Output
		move.l		d0,std_out
		
		lea		CLIText,a0
		bsr		DOSPrint
		bra		Error

; If from the Workbench we need a console to work with, so open one and print
;an introduction.

IsWB		move.l		#conname,d1		filename
		move.l		#MODE_NEWFILE,d2	type
		CALLDOS		Open			open it up!
		move.l		d0,std_out		and save handle
		beq		Error1			exit if can't

		lea		IntroText,a0
		bsr		DOSPrint
		bsr		RMBWait

; Can now open icon.library, needed to obtain an icons ToolTypes array.

		lea		iconname,a1		library name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open it
		move.l		d0,_IconBase		save pointer
		bne		Go
		lea		ErrorText,a0
		bsr		DOSPrint
		bra		Error2

; Now get a pointer to the Workbench message and determine the number of
;arguments. If zero args, we will quit!

Go		move.l		returnMsg,a4		a4->WBStartup
		move.l		sm_NumArgs(a4),d7	get number of args
		move.l		d7,DStream		and save it
		lea		ArgCTmp,a0		a0->template
		bsr		RDFPrint		print arg count

; Time for a loop that steps through argument list, sending each WBArg to
;a subroutine that displays details about it!

		subq.w		#1,d7			dbra adjust
		moveq.l		#1,d6			init arg counter
		move.l		sm_ArgList(a4),a4	a4->arg array

ArgLoop		bsr		HandleArg		display arg details
		addq.l		#wa_SIZEOF,a4		a4->next arg
		addq.w		#1,d6			bump arg counter
		dbra		d7,ArgLoop		loop for all args

; Close icon library

		move.l		_IconBase,a1
		CALLEXEC	CloseLibrary

; Close console

Error2		lea		EndText,a0
		bsr		DOSPrint

.loop		btst		#2,$dff016
		bne.s		.loop

		move.l		std_out,d1
		CALLDOS		Close

; Close DOS library before finishing

Error1		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary

Error		moveq.l		#0,d0
		rts

***************	Subroutines

*******	Build and display a text string using RawDoFmt

; Entry		a0->format string

; Exit		Nothing Useful

; Corrupt	a6 possibly

RDFPrint	PUSH		d0-d4/a0-a4

		lea		DStream,a1
		lea		_PC,a2
		lea		BuiltText,a3
		CALLEXEC	RawDoFmt
		
		lea		BuiltText,a0
		bsr		DOSPrint
		
		PULL		d0-d4/a0-a4
		rts

_PC		move.b		d0,(a3)+
		rts

*******	Wait For RMB before continuing

; Displays a prompt for the user and waits for right mouse button ( menu ) to
;be pressed before continuing.

; Entry		none

; Exit		none

; corrupt	a0

RMBWait		lea		RMBText,a0
		bsr		DOSPrint

.loop		btst		#2,$dff016
		bne.s		.loop
		
		rts

*******	Displays Details About A WBArg

; Each WBArg can refer to either a directory or a Project, Tool icons
;selected as Project icons are treated as Project icons. The first WBArg is
;always the name of the Tool, subsequent WBArgs are distinguished by their
;wa_Name filed. If Wa_Name points to an empty string, that argument is for
;a directory and a call to Examine() is required to determine the name of
;the directory. If wa_Name is a valid string, a call to CurrentDir() will
;move us into that projects directory. From the directory we can examine
;the icon and step through the ToolTypes array maintained by it. The
;following program does all these things!

; Entry		a4->WBArg
;		d6=arg counter

; Entry		Nothing new

; Corrupt	None

HandleArg	PUSHALL

; Display argument number

		move.l		d6,DStream
		lea		ArgVTmp,a0
		bsr		RDFPrint

; If this is the first argument, it's the Tools name. Say so...

		cmpi.w		#1,d6			first?
		bne.s		NotFirstWBA		no, skip
		move.l		wa_Name(a4),DStream	else set name
		lea		ToolTmp,a0		get template
		bsr		RDFPrint		and display name
		bra		WBAdone

; Not first argument, determine if a directory or a project.

NotFirstWBA	move.l		wa_Name(a4),a0
		tst.b		(a0)
		bne		IsProject

; It's a directory. Obtain name of directory by calling Examine() and looking
;at the FileInfoBlock returned. Use the Lock provided by WBArg.

		move.l		wa_Lock(a4),d1		d1=dir lock
		move.l		#fib,d2			FileInfoBlock
		CALLDOS		Examine			get dir details
		
		lea		fib,a0			a0->FileInfoBlock
		lea		fib_FileName(a0),a0	a0->Directory name
		move.l		a0,DStream		into Data Stream
		lea		DirTmp,a0		a0->dir template
		bsr		RDFPrint		print name
		bra		WBAdone			and exit

; It's a project, display it's name.

IsProject	move.l		wa_Name(a4),DStream
		lea		ProjectTmp,a0
		bsr		RDFPrint

	; Change directory to the one containing the project
	
		move.l		wa_Lock(a4),d1		d1=dir lock
		CALLDOS		CurrentDir		change directory
		move.l		d0,d7			save old lock
	
	; Read in icon structure
	
		move.l		wa_Name(a4),a0		a0->icon name
		CALLICON	GetDiskObject		read structure
		move.l		d0,d6			save Icon pointer
		bne		GotIcon			continue if ok
		lea		IconText,a0		a0->error text
		bsr		DOSPrint		print it
		bra		IError			and exit

	; Icon has been read, step through ToolTypes array displaying them.

GotIcon		move.l		d6,a5			a5->Disk Object
		move.l		do_ToolTypes(a5),a5	a5->ToolTypes array

ToolTypesLoop	move.l		(a5)+,DStream
		beq.s		DoneToolTypes
		lea		TTypeTmp,a0
		bsr		RDFPrint
		bra.s		ToolTypesLoop

	; Free Icon structure
	
DoneToolTypes	move.l		d6,a0			a0->DiskObject
		CALLICON	FreeDiskObject		free it
		
	; Move back into original directory

IError		move.l		d7,d1			old directory lock
		CALLDOS		CurrentDir		revert back to it
		
; Finished with this argument, wait for right mouse to be pressed and exit.

WBAdone		bsr		RMBWait
		PULLALL
		rts
		
***************	Include Generic Subroutines

		include		dosprint.i

***************	Data Area

dosname		dc.b		'dos.library',0
		even

iconname	dc.b		'icon.library',0
		even

conname		dc.b		'con:0/10/640/190/Amiganuts',0
		even


CLIText		dc.b		'This program was written to test Workbench',$0a
		dc.b		'message passing on program start up. It',$0a
		dc.b		'makes no sense running it from the CLI!',$0a
		dc.b		'M.Meany, Amiganuts 1993.',$0a,0
		even

IntroText	dc.b		$0a
		dc.b		'  **********************************',$0a
		dc.b		'  ** Exploring Workbench Messages **',$0a
		dc.b		'  **   Programmed by Mark Meany   **',$0a
		dc.b		'  **********************************',$0a
		dc.b		$0a,0
		even

RMBText		dc.b		$0a
		dc.b		' ** Press The Right Mouse Button **',$0a
		dc.b		' ** To continue with the program **',$0a
 		dc.b		$0a,0
		even

ArgCTmp		dc.b		'Argument count = %ld.',$0a,0
		even

ArgVTmp		dc.b		$0a,'Argument %ld:',$0a,$0a,0
		even

ToolTmp		dc.b		'This Tools Name: "%s".',$0a,0
		even

TTypeTmp	dc.b		'"%s"',$0a
		dc.b		'                 ',0
		even

DirTmp		dc.b		'Directory Name:  "%s".',$0a,0
		even

ProjectTmp	dc.b		'Project Name:    "%s".',$0a,$0a
		dc.b		'Tool Types:      ',0
		even
		
EndText		dc.b		$0a
		dc.b		'  **********************************',$0a
		dc.b		'  **  Press RMB to exit program   **',$0a
		dc.b		'  **********************************',$0a,0
		even

ErrorText	dc.b		$0a
		dc.b		' ** Could not open icon.library **',$0a
		dc.b		$0a,0
		even

IconText	dc.b		$0a
		dc.b		' ** Could not read icon structure **',$0a
		dc.b		$0a,0
		even

***************	Uninitialised Data Area

		section		prog_data,BSS

; Note that FileInfoBlock MUST be on a long word boundary so it has been
;placed at the start of the BSS section.

fib		ds.b		fib_SIZEOF	File Info Block for Examine

_DOSBase	ds.l		1
_IconBase	ds.l		1

std_out		ds.l		1

DStream		ds.l		4		DataStream for RawDoFmt

BuiltText	ds.b		80		buffer for RawDoFmt

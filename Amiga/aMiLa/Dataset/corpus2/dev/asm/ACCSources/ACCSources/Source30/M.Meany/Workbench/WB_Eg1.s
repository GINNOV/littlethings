
;Purpose	To investigate Workbench messages
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

; Now get a pointer to the Workbench message and determine the number of
;arguments. If zero args, we will quit!

		move.l		returnMsg,a4		a4->WBStartup
		move.l		sm_NumArgs(a4),d7	get number of args
		move.l		d7,DStream		and save it
		lea		ArgCTmp,a0		a0->template
		bsr		RDFPrint		print arg count

; Time for a loop that steps through arguments printing whats there!

		move.l		#1,DStream		init counter
		subq.w		#1,d7			dbra adjust
		move.l		sm_ArgList(a4),a4	a4->arg array

ArgLoop		move.l		wa_Name(a4),DStream+4	copy name pointer
		move.l		wa_Lock(a4),DStream+8	copy Lock address
		addq.l		#wa_SIZEOF,a4		a4->next arg
		lea		ArgVTmp,a0		a0->template
		bsr		RDFPrint		print name
		addq.l		#1,DStream		bump counter
		dbra		d7,ArgLoop		loop for all args

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

***************	Include Generic Subroutines

		include		dosprint.i

***************	Data Area

dosname		dc.b		'dos.library',0
		even

intname		dc.b		'intuition.library',0
		even

gfxname		dc.b		'graphics.library',0
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
		dc.b		$0a,'Examaning Workbench Message:',$0a
		dc.b		$0a,0
		even

RMBText		dc.b		$0a
		dc.b		' ** Press The Right Mouse Button **',$0a
		dc.b		' ** To continue with the program **',$0a
		dc.b		$0a,0
		even

ArgCTmp		dc.b		'There are %ld arguments, the first is the'
		dc.b		' programs name!',$0a,$0a,0
		even

ArgVTmp		dc.b		'Arg %ld:',$09,'Name "%s"',$0a
		dc.b		$09,'Lock at $%lx',$0a,0
		even

EndText		dc.b		$0a
		dc.b		'  **********************************',$0a
		dc.b		'  **  Press RMB to exit program   **',$0a
		dc.b		'  **********************************',$0a,0
		even

***************	Uninitialised Data Area

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

std_out		ds.l		1

DStream		ds.l		4		DataStream for RawDoFmt

BuiltText	ds.b		80		buffer for RawDoFmt

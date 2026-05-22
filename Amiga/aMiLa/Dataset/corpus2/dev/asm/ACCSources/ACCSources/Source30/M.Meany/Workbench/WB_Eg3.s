
;Purpose	To create an icon for a Project
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

; Change directory to the one containing this program

Go		move.l		returnMsg,a0
		move.l		sm_ArgList(a0),a0
		move.l		wa_Lock(a0),d1
		CALLDOS		CurrentDir
		move.l		d0,d7

; Create a file in ram

		move.l		#FileName,d1
		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,d6
		beq		Error3
				
		move.l		d6,d1
		move.l		#FileText,d2
		move.l		#FileLen,d3
		CALLSYS		Write
		
		move.l		d6,d1
		CALLSYS		Close
		
		lea		FileDoneText,a0
		bsr		DOSPrint

; Append an icon to the file

		lea		FileName,a0
		lea		ProjectIcon,a1
		CALLICON	PutDiskObject
		
		lea		IconDoneText,a0
		bsr		DOSPrint
		
; Return to original directory

Error3		move.l		d7,d1
		CALLDOS		CurrentDir

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

***************	Include Generic Subroutines

		include		dosprint.i

***************	Data Area

dosname		dc.b		'dos.library',0
		even

iconname	dc.b		'icon.library',0
		even

conname		dc.b		'con:0/10/640/190/Amiganuts',0
		even

FileName	dc.b		'TextFile',0
		even

DirName		dc.b		'ram:',0
		even
		
FileText	dc.b		'This file and icon were created by a',$0a
		dc.b		'utility written by M.Meany, Jan 1993.',$0a
FileLen		equ		*-FileText
		even
		
CLIText		dc.b		'This program was written to test creation',$0a
		dc.b		'of a project icon',$0a
		dc.b		'M.Meany, Amiganuts 1993.',$0a,0
		even

IntroText	dc.b		$0a
		dc.b		'  **********************************',$0a
		dc.b		'  **   Creating Workbench Icons   **',$0a
		dc.b		'  **   Programmed by Mark Meany   **',$0a
		dc.b		'  **********************************',$0a
		dc.b		$0a,0
		even

RMBText		dc.b		$0a
		dc.b		' ** Press The Right Mouse Button **',$0a
		dc.b		' ** To continue with the program **',$0a
 		dc.b		$0a,0
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

FileDoneText	dc.b		'Created file.',$0a,0
		even

IconDoneText	dc.b		'Attached an Icon to file',$0a,0
		even
		
; A DiskObject structure for creating Project icons

ProjectIcon	dc.w		WB_DISKMAGIC		do_Magic
		dc.w		WB_DISKVERSION		do_Version

IconGadget	dc.l		0			gg_NextGadget
		dc.w		0			gg_LeftEdge
		dc.w		0			gg_TopEdge
		dc.w		40			gg_Width
		dc.w		21			gg_Height
		dc.w		GADGHCOMP!GADGIMAGE	gg_Flags
		dc.w		GADGIMMEDIATE!RELVERIFY	gg_Activation
		dc.w		BOOLGADGET		gg_GadgetType
		dc.l		IconImage		gg_GadgetRender
		dc.l		0			gg_SelectRender
		dc.l		0			gg_Text
		dc.l		0			gg_MutualExclude
		dc.l		0			gg_SpecialInfo
		dc.w		0			gg_GadgetID
		dc.l		0			gg_UserData

		dc.b		WBPROJECT		do_Type
		dc.b		0			pad byte
		dc.l		ToolName		do_DefaultTool
		dc.l		ToolTypes		do_ToolTypes
		dc.l		NO_ICON_POSITION	do_CurrentX
		dc.l		NO_ICON_POSITION	do_CurrentY
		dc.l		0			do_DrawerData
		dc.l		0			do_ToolWindow
		dc.l		4096			do_StackSize

IconImage	dc.w		0			ig_LeftEdge
		dc.w		0			ig_TopEdge
		dc.w		40			ig_Width
		dc.w		20			ig_Height
		dc.w		2			ig_Depth
		dc.l		IconData		ig_ImageData
		dc.b		3			ig_PlanePick
		dc.b		0			ig_PlaneOnOff
		dc.l		0			ig_NextImage

ToolName	dc.b		':c/txed',0
		even

ToolTypes	dc.l		Arg1
		dc.l		Arg2
		dc.l		Arg3
		dc.l		0

Arg1		dc.b		'INSERT=ON',0
		even
Arg2		dc.b		'WORDWRAP=ON',0
		even
Arg3		dc.b		'MARKMEANY',0
		even
		
***************	CHIP data for the icons image

		section	icon,DATA_C

IconData	dc.w	$0000,$0000,$0000,$3fff,$ffcc,$0000,$3fff,$ffcf
		dc.w	$0000,$3fff,$ffcf,$c000,$3803,$ffcf,$f000,$3fff
		dc.w	$ffc0,$0000,$3803,$ffff,$fc00,$3fff,$ffff,$fc00
		dc.w	$3fff,$ffff,$fc00,$3f84,$00c0,$7c00,$3fff,$ffff
		dc.w	$fc00,$3900,$8000,$7c00,$3fff,$ffff,$fc00,$3800
		dc.w	$0040,$7c00,$3fff,$ffff,$fc00,$3fff,$ffff,$fc00
		dc.w	$3fff,$fe00,$7c00,$3fff,$ffff,$fc00,$3fff,$ffff
		dc.w	$fc00,$0000,$0000,$0000
		
		dc.w	$ffff,$fffc,$0000,$c000,$0033,$0000,$0000,$0030
		dc.w	$c000,$c000,$0030,$3000,$c7fc,$0030,$0c00,$c000
		dc.w	$003f,$ff00,$c7fc,$0000,$0300,$c000,$0000,$0300
		dc.w	$c000,$0000,$0300,$c07b,$ff3f,$8300,$c000,$0000
		dc.w	$0300,$c6ff,$7fff,$8300,$c000,$0000,$0300,$c7ff
		dc.w	$ffbf,$8300,$c000,$0000,$0300,$c000,$0000,$0300
		dc.w	$c000,$01ff,$8300,$c000,$0000,$0300,$c000,$0000
		dc.w	$0300,$ffff,$ffff,$ff00


***************	Uninitialised Data Area

		section		prog_data,BSS

; Note that FileInfoBlock MUST be on a long word boundary so it has been
;placed at the start of the BSS section.

_DOSBase	ds.l		1
_IconBase	ds.l		1

std_out		ds.l		1

DStream		ds.l		4		DataStream for RawDoFmt

BuiltText	ds.b		80		buffer for RawDoFmt

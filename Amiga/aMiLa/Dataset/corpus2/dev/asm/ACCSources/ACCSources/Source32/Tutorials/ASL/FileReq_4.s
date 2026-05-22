
; Basic code for asl library tutorial

		incdir		sys:include/
		include		exec/exec.i
		include		exec/exec_lib.i
		include		dos/dos.i
		include		dos/dos_lib.i
		include		dos/dosextens.i
		include		libraries/asl.i
		include		libraries/asl_lib.i

CALLASL		macro

		move.l		_AslBase,a6
		jsr		_LVO\1(a6)
		
		endm

; Open DOS library

Start		lea		dosname,a1
		moveq.l		#36,d0			WB2+
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		Error

; Open ASL library

		lea		aslname,a1
		moveq.l		#36,d0			WB2+
		CALLEXEC	OpenLibrary
		move.l		d0,_AslBase
		beq		Error1

; Get an ASL Request structure for use in the program

		move.l		#ASL_FileRequest,d0
		lea		OpenTags,a0
		CALLASL		AllocAslRequest
		move.l		d0,OurRequest
		beq		Error2
		
; Use the requester

		bsr		TestRequester

; Free the ASL Request

Error3		move.l		OurRequest,a0
		CALLASL		FreeAslRequest

; Close ASL Library

Error2		move.l		_AslBase,a1
		CALLEXEC	CloseLibrary

; Close DOS Library

Error1		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary

; All done so exit

Error		moveq.l		#0,d0
		rts


dosname		DOSNAME
aslname		dc.b		'asl.library',0
		even

_DOSBase	dc.l		0
_AslBase	dc.l		0

OurRequest	dc.l		0

OpenTags	dc.l		ASLFR_TitleText,ReqName
		dc.l		ASLFR_RejectIcons,1
		dc.l		TAG_DONE
		
ReqName		dc.b		'Select file to load ...',0
		even
		
; Code for specific examples will follow

TestRequester	move.l		OurRequest,a0
		suba.l		a1,a1			NULL => no tags
		CALLASL		AslRequest

; check if user cancelled and exit if they did

		tst.l		d0
		beq		TR_Done

; Never cancelled, get a lock on the drawer containing the file

		move.l		OurRequest,a4
		move.l		fr_Drawer(a4),d1
		move.l		#ACCESS_READ,d2
		CALLDOS		Lock			lock the drawer
		tst.l		d0			get it?
		beq		TR_Done			no, exit!

; Switch directories. NB CurrentDir() returns lock on directory just left!

		move.l		d0,d1
		CALLDOS		CurrentDir
		move.l		d0,d7			save old lock

; Now determine length of the file by Seek()ing through it

		move.l		fr_File(a4),d1
		move.l		#MODE_OLDFILE,d2
		CALLDOS		Open
		move.l		d0,d4			handle
		beq		TR_Err
		
		move.l		d4,d1
		moveq.l		#0,d2
		moveq.l		#1,d3			OFFSET_END
		CALLDOS		Seek
		
		move.l		d4,d1
		moveq.l		#0,d2
		moveq.l		#-1,d3			OFFSET_BEGINNING
		CALLDOS		Seek
		move.l		d0,d3			end of file
		
		move.l		d4,d1
		CALLDOS		Close

		move.l		d3,DStream+4		save file length

; Switch back to original directory

TR_Err		move.l		d7,d1
		CALLDOS		CurrentDir

; Unlock the drawer containing file

		move.l		d0,d1
		CALLDOS		UnLock

; Now display name and size of file

		move.l		fr_File(a4),DStream	save ->files name

		move.l		#Template,d1		string template
		move.l		#DStream,d2
		CALLDOS		VPrintf

TR_Done		rts

Template	dc.b		"You selected  '%s'. This file is %ld bytes"
		dc.b		"long.",$0a,0
		even

DStream		dc.l		2


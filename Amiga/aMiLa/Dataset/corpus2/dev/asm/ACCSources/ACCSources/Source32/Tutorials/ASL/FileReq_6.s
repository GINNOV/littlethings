
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
		lea		SaveReqT(pc),a1		open TAGs
		CALLASL		AslRequest

; check if user cancelled and exit if they did

break		tst.l		d0
		beq.s		TR_Done

; Never cancelled, display details of file in CLI. This code cheats a little
;and uses the requester structure as it's DataStream :-)

		move.l		#Template,d1		string template
		move.l		OurRequest,a0
		lea		fr_File(a0),a0
		move.l		a0,d2
		CALLDOS		VPrintf

TR_Done		rts

Template	dc.b		"You selected  '%s'.",$0a
		dc.b		"In the drawer '%s'.",$0a,0
		even

SaveReqT	dc.l		ASLFR_InitialPattern,StartPattern
		dc.l		ASLFR_Flags1,FRF_DOPATTERNS
		dc.l		TAG_DONE

StartPattern	dc.b		'(*.s|*.asm)',0
		even


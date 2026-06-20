
; Multi-selecting files

		incdir		sys:include/
		include		exec/exec.i
		include		exec/exec_lib.i
		include		dos/dos.i
		include		dos/dos_lib.i
		include		dos/dosextens.i
		include		libraries/asl.i
		include		libraries/asl_lib.i
		include		workbench/startup.i

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
		lea		SelReqT(pc),a1		open TAGs
		CALLASL		AslRequest

; check if user cancelled and exit if they did

		tst.l		d0
		beq.s		TR_Done

; Get a counter of the number of files selected

		move.l		OurRequest,a4
		move.l		fr_NumArgs(a4),d7
		subq.l		#1,d7			dbra adjust

; Display the name of the drawer we are in

		move.l		fr_Drawer(a4),DStream
		move.l		#DStream,d2
		move.l		#DrawerTmp,d1
		CALLDOS		VPrintf

; Now loop through displaying names of all selected files

		move.l		fr_ArgList(a4),a4	a4->WBArgs array

DisplayLoop	move.l		wa_Name(a4),DStream
		move.l		#FileTmp,d1
		move.l		#DStream,d2
		CALLDOS		VPrintf

	; step to next entry in array
	
		add.l		#wa_SIZEOF,a4
		
		dbra		d7,DisplayLoop

TR_Done		rts

DrawerTmp	dc.b		"Drawer  '%s'.",$0a
		dc.b		"Files selected:",$0a,0
		even

FileTmp		dc.b		$09,'%s',$0a,0
		even
		
SelReqT		dc.l		ASLFR_Flags1,FRF_DOMULTISELECT
		dc.l		TAG_DONE

DStream		dc.l		0,0

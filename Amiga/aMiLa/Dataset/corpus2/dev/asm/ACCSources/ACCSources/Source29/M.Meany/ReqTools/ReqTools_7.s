
; Using the file requester. Note that unlike ARP, no directory name is
;returned, rather a lock on the directory. This can be used to ChangeDir()
;to that directory and then access the file. NOTE, when doing this always
;return to the directory you were in prior to the call.

		incdir		sys:Include/
		include		exec/exec.i
		include		exec/exec_lib.i
		include		intuition/intuition.i
		include		intuition/intuition_lib.i
		incdir		ACC29_A:Include/
		include		reqtools.i
		include		reqtools_lib.i

		*****************************************
		*	  	Main			*
		*****************************************

Start		bsr		Openlibs
		tst.l		d0
		beq.s		.done

; Must initialise a structure prior to using file requester

		bsr		Init
		tst.l		d0
		beq.s		.Error1

		bsr		TestReqTools

; Can now release structure used with file requester

		bsr		DeInit

.Error1		bsr		Closelibs
		
.done		moveq.l		#0,d0
		rts

		*****************************************
		*  Initialise File Requester Structures	*
		*****************************************

; I've opted for two seperate requesters, one to Load, the other to Save. 

Init		moveq.l		#RT_FILEREQ,d0		structure required
		lea		LoadTags,a0		no tags
		CALLREQ		rtAllocRequestA		get structure
		move.l		d0,LoadReq		save addr
		beq.s		.done
		
		moveq.l		#RT_FILEREQ,d0		structure required
		suba.l		a0,a0			no tags
		CALLREQ		rtAllocRequestA		get structure
		move.l		d0,SaveReq		save addr

.done		rts		

		*****************************************
		*     Test One Of ReqTools Functions	*
		*****************************************

; Use requester to obtain integer and then display it.

TestReqTools	move.l		LoadReq,a1		a1-> request struct
		lea		ReqTextBuff,a2		a2-> filename buffer
		lea		LoadTitle,a3		Requester Title
		lea		LoadTags,a0		tags
		CALLREQ		rtFileRequestA		display requester
		tst.l		d0			cancel selected?
		beq.s		.DoSave			yep, skip!
		
; Use formatting capabilities of Reqtools to display string entered.

		move.l		#ReqTextBuff,ReqDStream	set ptr to filename
		lea		BodyText,a1		gadget text
		lea		GadgetText,a2		text for buttons
		suba.l		a3,a3			no special info
		lea		ReqDStream,a4		arg array
		lea		LoadTags,a0		tags
		CALLREQ		rtEZRequestA		display requester
		
.DoSave		move.l		SaveReq,a1		a1-> request struct
		lea		ReqTextBuff,a2		a2-> filename buffer
		lea		SaveTitle,a3		Requester Title
		lea		SaveTags,a0		tags
		CALLREQ		rtFileRequestA		display requester
		tst.l		d0			cancel selected?
		beq.s		.done			yep, skip!
		
; Use formatting capabilities of Reqtools to display string entered.

		move.l		#ReqTextBuff,ReqDStream	set ptr to filename
		lea		BodyText,a1		gadget text
		lea		GadgetText,a2		text for buttons
		suba.l		a3,a3			no special info
		lea		ReqDStream,a4		arg array
		lea		LoadTags,a0		tags
		CALLREQ		rtEZRequestA		display requester

.done		rts

		*****************************************
		*     Free File Requester Structure	*
		*****************************************

DeInit		move.l		SaveReq,d0
		beq.s		.TryLoad
		move.l		d0,a1
		CALLREQ		rtFreeRequest
		
.TryLoad	move.l		LoadReq,d0
		beq.s		.done
		move.l		d0,a1
		CALLREQ		rtFreeRequest
		
.done		rts

		*****************************************
		*	  Open Required Libraries	*
		*****************************************

; Open Reqtools library.

; If d0=0 on return then one or more libraries are not open.

Openlibs	lea		reqname,a1		a1->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		and open it
		move.l		d0,_reqBase		save base ptr

; reqtools opens DOS, Intuition and Graphics libraries and we can use the
;base pointers stored in it's base structure :-)

		move.l		d0,a0			a0->library base
		move.l		rt_IntuitionBase(a0),_IntuitionBase
		move.l		rt_GfxBase(a0),_GfxBase
		move.l		rt_DOSBase(a0),_DOSBase

.lib_error	rts

		*****************************************
		*	  Close All Libraries		*
		*****************************************

; Closes any libraries the program managed to open.

Closelibs	move.l		_reqBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts

		*****************************************
		*	  Initialised Data		*
		*****************************************

reqname		dc.b		'reqtools.library',0
		even

LoadTitle	dc.b		'Download File As:',0
		even

; This is the TagList used with the load requester.

LoadTags	dc.l		RT_ReqPos,REQPOS_CENTERSCR	centralise
		dc.l		TAG_DONE

SaveTitle	dc.b		'Select File To Upload:',0
		even

SaveTags	dc.l		RT_ReqPos,REQPOS_CENTERSCR	centralise
		dc.l		RTFI_Flags,FREQF_SAVE+FREQF_PATGAD
		dc.l		TAG_DONE

BodyText	dc.b		'You selected the following file:',$0a
		dc.b		"'%s'",0
		even

GadgetText	dc.b		'I Get It!',0
		even

		*****************************************
		*	  Uninitialised Data		*
		*****************************************

		section		vars,BSS

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_reqBase	ds.l		1

LoadReq		ds.l		1
SaveReq		ds.l		1

ReqTextBuff	ds.b		82			space for text entry

ReqDStream	ds.l		10			space for argarray

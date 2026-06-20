

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

		bsr		TestReqTools

		bsr		Closelibs
		
.done		moveq.l		#0,d0
		rts

		*****************************************
		*     Test One Of ReqTools Functions	*
		*****************************************

; Display a request with 4 buttons named 1,2,3 and 0. The right most button
;always returns 0 in d0, other return a value according to their position
;from the left of the window!

TestReqTools	lea		BodyText,a1		gadget text
		lea		GadgetText,a2		text for buttons
		suba.l		a3,a3			no special info
		suba.l		a4,a4			no arg array
		suba.l		a0,a0			no tags
		CALLREQ		rtEZRequestA		display requester
		
; Use formatting capabilities of Reqtools to display value selected

		move.l		d0,ReqDStream		write return value
		lea		BodyText1,a1		gadget text
		lea		GadgetText1,a2		text for buttons
		suba.l		a3,a3			no special info
		lea		ReqDStream,a4		arg array
		suba.l		a0,a0			no tags
		CALLREQ		rtEZRequestA		display requester
		
		tst.l		ReqDStream
		bne.s		TestReqTools
		
BREAK		rts

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

BodyText	dc.b		'ACC explains use of Reqtools.',$0a
		dc.b		"It's not as hard as it seems!",$0a
		dc.b		' You keep seeing this until ',$0a
		dc.b		"you select the 'QUIT' gadget.",0
		even

GadgetText	dc.b		'1|2|3|QUIT',0
		even

BodyText1	dc.b		'That gadget returned code %ld in d0',0
		even

GadgetText1	dc.b		'I Get It!',0
		even



		*****************************************
		*	  Uninitialised Data		*
		*****************************************

		section		vars,BSS

_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1
_reqBase	ds.l		1

ReqDStream	ds.l		10			space for argarray



; Using a TagList. A TagList contains long words, each has it's own special
;meaning as can be seen from reqtools.doc, this example demonstrates use of
;tags with an integer gadget.

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

; Use requester to obtain integer and then display it.

TestReqTools	lea		ReqDStream,a1		a1-> buffer
		lea		StrTitle,a2		Requester Title
		suba.l		a3,a3			no special info
		lea		StrTag,a0		a0-> tag list
		CALLREQ		rtGetLongA		display requester
		
; Use formatting capabilities of Reqtools to display string entered.

		lea		BodyText,a1		gadget text
		lea		GadgetText,a2		text for buttons
		suba.l		a3,a3			no special info
		lea		ReqDStream,a4		arg array
		suba.l		a0,a0			no tags
		CALLREQ		rtEZRequestA		display requester
		
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

StrTitle	dc.b		'Enter Desired BAUD rate',0
		even

; This is the TagList used with the integer gadget. Note that if a tag
;requires data, the data follows the tag! A description of all tags available
;to each reqtools function can be found in reqtools.doc along with function
;descriptions.

StrTag		dc.l		RTGL_Min,1200		define minimum BAUD
		dc.l		RTGL_Max,32200		define maximum BAUD
		dc.l		RTGL_Width,200		set window width
		dc.l		TAG_DONE
		

BodyText	dc.b		'BAUD rate set to: %ld',0
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

ReqTextBuff	ds.b		82			space for text entry

ReqDStream	ds.l		10			space for argarray

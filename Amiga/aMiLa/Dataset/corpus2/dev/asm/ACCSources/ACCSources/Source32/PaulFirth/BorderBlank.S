; BorderBlank
;
; © Copyright 1993 Paul Firth
;
; Version 1.00 (3/11/93)

		incdir		sys:include/
		include		exec/exec_lib.i
		include		intuition/intuition_lib.i
		include		intuition/intuition.i
		include		graphics/graphics_lib.i
		include		graphics/videocontrol.i
		include		clarityov_macros.i

NULL		EQU		0
TRUE		EQU		1
		

OPEN_INTUITION
		lea		INTUITION_NAME,a1		;library name in a1
		moveq.l		#36,d0				;library version in d0
		CALLEXEC	OpenLibrary			;open library
		tst.l		d0
		beq		EXIT				;quit if cant
		move.l		d0,INTUITION_BASE		;get base addres

OPEN_GRAPHICS
		lea		GRAPHICS_NAME,a1
		moveq.l		#36,d0
		CALLEXEC	OpenLibrary
		tst.l		d0
		beq		CLOSE_INTUITION
		move.l		d0,GRAPHICS_BASE

LOCK_PUBLIC_SCREEN
		move.l		#0,a0
		CALLLINT		LockPubScreen
		tst.l		d0
		beq		CLOSE_GRAPHICS
		move.l		d0,PUBLIC_SCREEN

DECIDE_BORDER		
		move.l		PUBLIC_SCREEN,a0
		add.l		#sc_ViewPort,a0			;hate hate hate hate hate!!!!!!!!

		move.l		vp_ColorMap(a0),a2		;screen's color map in a2
		move.l		a2,a0
		lea		QUESTION_TAGS,a1
		CALLLGRAF	VideoControl
		
		move.l		(QUESTION_TAGS),d0		;get boderblank state
		cmpi.l		#VTAG_BORDERBLANK_SET,d0	;is it set
		beq		UNSET_BORDER			;if it is unset it

SET_BORDER
		move.l		a2,a0
		lea		BLACK_TAGS,a1
		CALLLGRAF	VideoControl
		bra		WAKE_SCREEN

UNSET_BORDER
		move.l		a2,a0
		lea		UNBLACK_TAGS,a1
		CALLLGRAF	VideoControl

WAKE_SCREEN		
		move.l		PUBLIC_SCREEN,a0
		CALLLINT		MakeScreen
		CALLLINT		RethinkDisplay
;----------------------------------------------------------------------------		
UNLOCK_PUBLIC		
		move.l		#0,a0
		move.l		PUBLIC_SCREEN,a1
		CALLLINT		UnlockPubScreen		

CLOSE_GRAPHICS
		move.l		GRAPHICS_BASE,a1
		CALLEXEC	CloseLibrary

CLOSE_INTUITION
		move.l		INTUITION_BASE,a1		;address of intuition in a1
		CALLEXEC	CloseLibrary			;close the library
		
EXIT		
		clr.l		d0				;clr d0 so no error return code
		rts						;and exit!!!						
;----------------------------------------------------------------------------				
QUESTION_TAGS	dc.l		VTAG_BORDERBLANK_GET
		dc.l		NULL
		dc.l		VTAG_END_CM
		dc.l		NULL
		dc.l		TAG_DONE


BLACK_TAGS	dc.l		VTAG_BORDERBLANK_SET
		dc.l		NULL
		dc.l		VTAG_END_CM
		dc.l		NULL
		dc.l		TAG_DONE
		
UNBLACK_TAGS	dc.l		VTAG_BORDERBLANK_CLR
		dc.l		NULL
		dc.l		VTAG_END_CM
		dc.l		NULL
		dc.l		TAG_DONE		
		
INTUITION_BASE	ds.l		1
GRAPHICS_BASE	ds.l		1

PUBLIC_SCREEN	ds.l		1

GRAPHICS_NAME	dc.b		'graphics.library',0
INTUITION_NAME	dc.b		'intuition.library',0
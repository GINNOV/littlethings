
; Example 4: Opens a HiRes, Interlaced, 16 colour Screen, 50 lines down
;            the display.

		include		int_start.i

; Open an Intuition Custom Screen

Main		lea		MyScreen,a0		NewScreen struct
		CALLINT		OpenScreen		open it
		move.l		d0,screen.ptr		save pointer
		beq.s		.error			quit if error

; Wait for mouse press

		bsr		RightMouse		wait on RMB
		
; Close the screen

		move.l		screen.ptr,a0		a0->screen struct
		CALLINT		CloseScreen		close it

.error		rts					and exit

; Static Intuition structures and variables

MyScreen
	dc.w	0,50		;screen XY origin relative to View
	dc.w	640,256		;screen width and height
	dc.w	4		;screen depth (number of bitplanes)
	dc.b	3,8		;detail and block pens
	dc.w	V_HIRES!V_LACE	;display modes for this screen
	dc.w	CUSTOMSCREEN	;screen type
	dc.l	0		;pointer to default screen font
	dc.l	.Title		;pointer to screen title
	dc.l	0		;first in list of custom screen gadgets
	dc.l	0		;pointer to custom BitMap structure

.Title	dc.b	'HiRes, Interlaced, 16 colour screen',0
	even

screen.ptr	dc.l		0
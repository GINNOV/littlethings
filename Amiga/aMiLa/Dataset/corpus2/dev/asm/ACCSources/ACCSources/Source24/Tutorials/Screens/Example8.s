
; Example 8: Opens two overscanned screens, one HiRes, one LoRes.

		include		int_start.i

; Set up NewScreen for HiRes, Overscanned screen

Main		lea		MyScreen,a0		a0->NewScreen
		move.w		#50,ns_TopEdge(a0)	set start line
		move.w		#266,ns_Height(a0)	set hieght
		move.w		#656,ns_Width(a0)	set width
		move.w		#V_HIRES,ns_ViewModes(a0) set display mode
		move.l		#HiTitle,ns_DefaultTitle(a0) set title

; Open First Custom Screen

		lea		MyScreen,a0		NewScreen struct
		CALLINT		OpenScreen		open it
		move.l		d0,screen.ptr1		save pointer
		beq.s		.error			quit if error

; Set up NewScreen for LoRes, Overscanned screen

		lea		MyScreen,a0		a0->NewScreen
		move.w		#100,ns_TopEdge(a0)	set start line
		move.w		#266,ns_Height(a0)	set hieght
		move.w		#336,ns_Width(a0)	set width
		move.w		#0,ns_ViewModes(a0)	set display mode
		move.l		#LoTitle,ns_DefaultTitle(a0) set title

; Open Second Custom Screen

		lea		MyScreen,a0		NewScreen struct
		CALLINT		OpenScreen		open it
		move.l		d0,screen.ptr2		save pointer
		beq.s		.error1			quit if error

; Wait for mouse press

		bsr		RightMouse		wait on RMB
		
; Close the second screen

		move.l		screen.ptr2,a0		a0->screen struct
		CALLINT		CloseScreen		close it

; Close the first screen

.error1		move.l		screen.ptr1,a0		a0->screen struct
		CALLINT		CloseScreen		close it

.error		rts					and exit

; Static NewScreen structure, partialy initialised

MyScreen
	dc.w	0,0		;screen XY origin relative to View
	dc.w	0,0		;screen width and height
	dc.w	4		;screen depth (number of bitplanes)
	dc.b	3,8		;detail and block pens
	dc.w	0		;display modes for this screen
	dc.w	CUSTOMSCREEN	;screen type
	dc.l	0		;pointer to default screen font
	dc.l	0		;pointer to screen title
	dc.l	0		;first in list of custom screen gadgets
	dc.l	0		;pointer to custom BitMap structure

; Screen titles

LoTitle	dc.b	'LoRes Overscanned Screen',0
	even
HiTitle	dc.b	'HiRes Overscanned Screen',0
	even

; Variables

screen.ptr1	dc.l		0
screen.ptr2	dc.l		0


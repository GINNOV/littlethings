
; Example 10: Accessing bitplane memory

		include		int_start.i

; Open an Intuition Custom Screen

Main		lea		MyScreen,a0		NewScreen struct
		CALLINT		OpenScreen		open it
		move.l		d0,screen.ptr		save pointer
		beq.s		error			quit if error

; Locate BitMap structure and hence bm_Planes field

		move.l		screen.ptr,a3		a3->Screen structure
		lea		sc_BitMap(a3),a4	a4->BitMap structure
		lea		bm_Planes(a4),a4	a4->bitplane pointer

; Obtain X,Y coordinates of mouse, exit loop when y=0

Loop		move.w		sc_MouseX(a3),d0	d0=mouse x coordinate
		move.w		sc_MouseY(a3),d1	d1=mouse y coordinate
		beq		AllDone			exit if at top line

; Obtain address and bit offset in bitplane

BREAK		move.l		(a4),a0			a0->bitplane1 memory
		move.l		#640,d2			screen width
		
		asr.l		#3,d2			w/8
		mulu		d1,d2			y*(w/8)
		
		divu		#8,d0
		swap		d0
		move.w		d0,d3			d3=MOD (x/8)
		move.w		#0,d0
		swap		d0			d0=(x/8)
		add.l		d0,d2			d2= y*(w/8) + (x/8)
		adda.l		d2,a0		a0->byte containing pixel
		
		moveq.l		#7,d0
		sub.w		d3,d0		d0=offset to required bit

; Set the bit and hence display the pixel

		bset.b		d0,(a0)			turn pixel on

; Loop back

		bra		Loop			and loop

; Close the screen

AllDone		move.l		screen.ptr,a0		a0->screen struct
		CALLINT		CloseScreen		close it

error		rts					and exit

; Static Intuition structures and variables

MyScreen
	dc.w	0,0		;screen XY origin relative to View
	dc.w	640,256		;screen width and height
	dc.w	4		;screen depth (number of bitplanes)
	dc.b	3,8		;detail and block pens
	dc.w	V_HIRES		;display modes for this screen
	dc.w	CUSTOMSCREEN	;screen type
	dc.l	0		;pointer to default screen font
	dc.l	.Title		;pointer to screen title
	dc.l	0		;first in list of custom screen gadgets
	dc.l	0		;pointer to custom BitMap structure

.Title	dc.b	'Move mouse pointer into top line to quit!',0
	even

screen.ptr	dc.l		0
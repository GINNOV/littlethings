
; Equates for a horizontal proportional gadget with custom imagery.

MyWindow	dc.w	109,44			;window XY origin
		dc.w	365,74			;window width and height
		dc.b	0,1			;detail and block pens
		dc.l	GADGETUP+CLOSEWINDOW	;IDCMP flags
		dc.l	WINDOWCLOSE+WINDOWDRAG+WINDOWDEPTH    other flags
		dc.l	HPropGadg		;first gadget in list
		dc.l	0			;custom CHECKMARK imagery
		dc.l	.WindowName		;window title
		dc.l	0			;custom screen pointer
		dc.l	0			;custom bitmap
		dc.w	5,5			;minimum width and height
		dc.w	640,200			;maximum width and height
		dc.w	WBENCHSCREEN		;destination screen type

.WindowName	dc.b	'Your new window',0
		even

HPropGadg	dc.l	0			;next gadget
		dc.w	31,49			;origin XY of hit box
		dc.w	285,15			;hit box width and height
		dc.w	GADGHIMAGE+GADGIMAGE	;gadget flags
		dc.w	RELVERIFY		;activation flags
		dc.w	PROPGADGET		;gadget type flags
		dc.l	Image1			image to be rendered
		dc.l	Image1			;alternate imagery 
		dc.l	0			;first IntuiText structure
		dc.l	0			;gadget mutual-exclude
		dc.l	.SInfo			;SpecialInfo structure
		dc.w	0			;user-definable data
		dc.l	DoHProp			;pointer to user subroutine

.SInfo		dc.w	FREEHORIZ		;PROPINFO flags
		dc.w	510,0		;horizontal and vertical pot values
		dc.w	327,-1		;horizontal and vertical body values
		dc.w	0,0,0,0,0,0	;previous requester (filled in by Intuition)

Image1		dc.w	2,-1			;XY origin
		dc.w	20,11			;Image width and height
		dc.w	2			;number of bitplanes in Image
		dc.l	FaceData		;pointer to ImageData
		dc.b	$0003,$0000		;PlanePick and PlaneOnOff
		dc.l	0			;next Image structure

		section	gfx,data_c

FaceData
		dc.w	$0000,$0000,$01FC,$0000,$0FFF,$8000,$1FFF,$C000
		dc.w	$3E73,$E000,$3FDF,$E000,$3DFD,$E000,$1E03,$C000
		dc.w	$0FFF,$8000,$01FC,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$01FC,$0000,$0FFF,$8000,$1FFF,$C000
		dc.w	$1FFF,$C000,$1FFF,$C000,$0FFF,$8000,$01FC,$0000
		dc.w	$0000,$0000,$0000,$0000

		section	skeleton,code
		
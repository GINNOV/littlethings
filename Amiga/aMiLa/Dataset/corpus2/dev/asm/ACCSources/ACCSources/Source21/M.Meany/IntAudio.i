

MyWindow
	dc.w	0,22		;window XY origin
	dc.w	640,126		;window width and height
	dc.b	0,1		;detail and block pens
	dc.l	GADGETDOWN+GADGETUP+INTUITICKS+CLOSEWINDOW	;IDCMP flags
	dc.l	WINDOWCLOSE+ACTIVATE+NOCAREREFRESH	;other window flags
	dc.l	HGadg		;first gadget in gadget list
	dc.l	0		;custom CHECKMARK imagery
	dc.l	.WindowName	;window title
	dc.l	0		;custom screen pointer
	dc.l	0		;custom bitmap
	dc.w	150,50		;minimum width and height
	dc.w	640,256		;maximum width and height
	dc.w	WBENCHSCREEN	;destination screen type
.WindowName
	dc.b	'Proportional Gadget Example',0
	even
	
HGadg
	dc.l	0		;next gadget
	dc.w	5,100		;origin XY of hit box
	dc.w	630,5		;hit box width and height
	dc.w	0		;gadget flags
	dc.w	GADGIMMEDIATE!RELVERIFY	;activation flags
	dc.w	PROPGADGET	;gadget type flags
	dc.l	.Image		;gadget border or image to be rendered
	dc.l	0		;alternate imagery for selection
	dc.l	0		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	.SInfo		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	DoHProp		;pointer to user-definable data

.SInfo
	dc.w	AUTOKNOB+FREEHORIZ	;PROPINFO flags
	dc.w	0,0		;horizontal and vertical pot values
	dc.w	$a3,-1		;horizontal and vertical body values
	dc.w	0,0,0,0,0,0	;previous requester (filled in by Intuition)

.Image
	dc.w	170,0		;XY origin relative to container TopLeft
	dc.w	6,1		;Image width and height in pixels
	dc.w	0		;number of bitplanes in Image
	dc.l	0		;pointer to ImageData
	dc.b	$0000,$0000	;PlanePick and PlaneOnOff
	dc.l	0		;next Image structure


; end of PowerWindows source generation

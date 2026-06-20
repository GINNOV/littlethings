

MyWindow
	dc.w	0,65		window XY origin
	dc.w	639,110		window width and height
	dc.b	0,1		detail and block pens
	dc.l	GADGETUP+CLOSEWINDOW	IDCMP flags
	dc.l	WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH	other window flags
	dc.l	Int1Gadg	first gadget in gadget list
	dc.l	0		custom CHECKMARK imagery
	dc.l	.WindowName	window title
	dc.l	0		custom screen pointer
	dc.l	0		custom bitmap
	dc.w	5,5		minimum width and height
	dc.w	640,200		maximum width and height
	dc.w	WBENCHSCREEN	destination screen type

.WindowName
	dc.b	'Example Integer Gadgets',0
	even

Int1Gadg
	dc.l	Int2Gadg	next gadget
	dc.w	33,28		origin XY of hit box
	dc.w	46,9		hit box width and height
	dc.w	0		gadget flags
	dc.w	RELVERIFY+LONGINT	activation flags
	dc.w	STRGADGET	gadget type flags
	dc.l	.Border		gadget border or image to be rendered
	dc.l	0		alternate imagery for selection
	dc.l	0		first IntuiText structure
	dc.l	0		gadget mutual-exclude long word
	dc.l	.SInfo		SpecialInfo structure
	dc.w	0		user-definable data
	dc.l	DoIntGadg	pointer to user-definable data

.SInfo
	dc.l	.Buff	buffer where text will be edited
	dc.l	UNDOBUFFER	optional undo buffer
	dc.w	0		character position in buffer
	dc.w	5		maximum number of characters to allow
	dc.w	0		first displayed character buffer position
	dc.w	0,0,0,0,0	Intuition init and maintained variables
	dc.l	0		Rastport of gadget
	dc.l	0		initial value for integer gadgets
	dc.l	0		alternate keymap

.Buff
	ds.b 5
	even

.Border
	dc.w	-2,-1		XY origin relative to container TopLeft
	dc.b	3,0,RP_JAM1	front pen, back pen and drawmode
	dc.b	5		number of XY vectors
	dc.l	.Vectors	pointer to XY vectors
	dc.l	0		next border in list

.Vectors
	dc.w	0,0
	dc.w	49,0
	dc.w	49,10
	dc.w	0,10
	dc.w	0,0

Int2Gadg
	dc.l	0		next gadget
	dc.w	92,28		origin XY of hit box
	dc.w	46,9		hit box width and height
	dc.w	0		gadget flags
	dc.w	RELVERIFY+LONGINT	activation flags
	dc.w	STRGADGET	gadget type flags
	dc.l	.Border		gadget border or image to be rendered
	dc.l	0		alternate imagery for selection
	dc.l	0		first IntuiText structure
	dc.l	0		gadget mutual-exclude long word
	dc.l	.SInfo		SpecialInfo structure
	dc.w	0		user-definable data
	dc.l	DoIntGadg	pointer to user-definable data

.SInfo
	dc.l	.Buff		buffer where text will be edited
	dc.l	UNDOBUFFER	optional undo buffer
	dc.w	0		character position in buffer
	dc.w	5		maximum number of characters to allow
	dc.w	0		first displayed character buffer position
	dc.w	0,0,0,0,0	Intuition init and maintained variables
	dc.l	0		Rastport of gadget
	dc.l	0		initial value for integer gadgets
	dc.l	0		alternate keymap

.Buff
	ds.b 5
	even
	
.Border
	dc.w	-2,-1		XY origin relative to container TopLeft
	dc.b	3,0,RP_JAM1	front pen, back pen and drawmode
	dc.b	5		number of XY vectors
	dc.l	.Vectors	pointer to XY vectors
	dc.l	0		next border in list

.Vectors
	dc.w	0,0
	dc.w	49,0
	dc.w	49,10
	dc.w	0,10
	dc.w	0,0

UNDOBUFFER
	ds.b 5
	even


ResultText
	dc.b	1,0,RP_JAM2,0	front/back text pens, drawmode/fill byte
	dc.w	155,29		XY origin relative to container TopLeft
	dc.l	0		font pointer or 0 for default
	dc.l	ResultBuffer	pointer to text
	dc.l	0		next IntuiText structure

ResultBuffer
	dc.b	'=                ',0
	even


; end of PowerWindows source generation

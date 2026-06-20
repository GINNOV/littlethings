

MyWindow
	dc.w	49,64		window XY origin
	dc.w	553,62		window width and height
	dc.b	0,1		detail and block pens
	dc.l	GADGETUP+CLOSEWINDOW	IDCMP flags
	dc.l	WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH	other window flags
	dc.l	WinGadg		first gadget in gadget list
	dc.l	0		custom CHECKMARK imagery
	dc.l	WinName		window title
	dc.l	0		custom screen pointer
	dc.l	0		custom bitmap
	dc.w	5,5		minimum width and height
	dc.w	640,200		maximum width and height
	dc.w	WBENCHSCREEN	destination screen type

WinGadg
	dc.l	ScrnGadg	next gadget
	dc.w	117,18		origin XY of hit box
	dc.w	283,11		hit box width and height
	dc.w	0		gadget flags
	dc.w	RELVERIFY	activation flags
	dc.w	STRGADGET	gadget type flags
	dc.l	.Border		gadget border or image to be rendered
	dc.l	0		alternate imagery for selection
	dc.l	0		first IntuiText structure
	dc.l	0		gadget mutual-exclude long word
	dc.l	.SInfo		SpecialInfo structure
	dc.w	0		user-definable data
	dc.l	DoWinGadg	pointer to user-definable data

.SInfo
	dc.l	WinName		buffer where text will be edited
	dc.l	UNDOBUFFER	optional undo buffer
	dc.w	0		character position in buffer
	dc.w	42		maximum number of characters to allow
	dc.w	0		first displayed character buffer position
	dc.w	0,0,0,0,0	Intuition initialized and maintained variables
	dc.l	0		Rastport of gadget
	dc.l	0		initial value for integer gadgets
	dc.l	0		alternate keymap (fill in if you set the flag)

.Border
	dc.w	-2,-3		XY origin relative to container TopLeft
	dc.b	3,0,RP_JAM1	front pen, back pen and drawmode
	dc.b	5		number of XY vectors
	dc.l	.Vectors	pointer to XY vectors
	dc.l	0		next border in list

.Vectors
	dc.w	0,0
	dc.w	286,0
	dc.w	286,12
	dc.w	0,12
	dc.w	0,0

ScrnGadg
	dc.l	0		next gadget
	dc.w	117,35		origin XY of hit box
	dc.w	283,11		hit box width and height
	dc.w	0		gadget flags
	dc.w	RELVERIFY	activation flags
	dc.w	STRGADGET	gadget type flags
	dc.l	.Border		gadget border or image to be rendered
	dc.l	0		alternate imagery for selection
	dc.l	0		first IntuiText structure
	dc.l	0		gadget mutual-exclude long word
	dc.l	.SInfo		SpecialInfo structure
	dc.w	0		user-definable data
	dc.l	DoScrnGadg	pointer to user-definable data

.SInfo
	dc.l	ScrnName	buffer where text will be edited
	dc.l	UNDOBUFFER	optional undo buffer
	dc.w	0		character position in buffer
	dc.w	42		maximum number of characters to allow
	dc.w	0		first displayed character buffer position
	dc.w	0,0,0,0,0	Intuition initialized and maintained variables
	dc.l	0		Rastport of gadget
	dc.l	0		initial value for integer gadgets
	dc.l	0		alternate keymap (fill in if you set the flag)

.Border
	dc.w	-2,-3		XY origin relative to container TopLeft
	dc.b	3,0,RP_JAM1	front pen, back pen and drawmode
	dc.b	5		number of XY vectors
	dc.l	.Vectors	pointer to XY vectors
	dc.l	0		next border in list

.Vectors
	dc.w	0,0
	dc.w	286,0
	dc.w	286,12
	dc.w	0,12
	dc.w	0,0

; Now for the string buffers

WinName	dc.b	'Change The Titles'
	ds.b	24
	even

ScrnName
	dc.b 	'Marks Example.'
	ds.b	30
	even

UNDOBUFFER
	ds.b 42
	even

; end of PowerWindows source generation

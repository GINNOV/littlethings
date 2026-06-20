

MyWindow
	dc.w	162,25		;window XY origin
	dc.w	353,166		;window width and height
	dc.b	0,1		;detail and block pens
	dc.l	GADGETUP+GADGETDOWN+CLOSEWINDOW		;IDCMP flags
	dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+ACTIVATE  win flags
	dc.l	LoresGadg	;first gadget in gadget list
	dc.l	0		;custom CHECKMARK imagery
	dc.l	.WindowName	;window title
	dc.l	0		;custom screen pointer
	dc.l	0		;custom bitmap
	dc.w	5,5		;minimum width and height
	dc.w	640,200		;maximum width and height
	dc.w	WBENCHSCREEN	;destination screen type

.WindowName
	dc.b	'Copper List Builder by M.Meany.',0
	even

LoresGadg
	dc.l	HiresGadg	;next gadget
	dc.w	100,20		;origin XY of hit box
	dc.w	108,10		;hit box width and height
	dc.w	GADGHIMAGE+SELECTED	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border1		;gadget border or image to be rendered
	dc.l	Border2		;alternate imagery for selection
	dc.l	.IText		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	0		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	DoLores		;pointer to user-definable data

.IText
	dc.b	1,0,RP_JAM1,0	;front/back text pens, drawmode/fill byte
	dc.w	2,2		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text		;pointer to text
	dc.l	.IText2		;next IntuiText structure

.Text
	dc.b	'LoRes ( 32O )',0
	even

.IText2
	dc.b	1,0,RP_JAM2,0	;front/back text pens, drawmode/fill byte
	dc.w	-90,2		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text2		;pointer to text
	dc.l	0		;next IntuiText structure

.Text2
	dc.b	'Mode   ->',0
	even

HiresGadg
	dc.l	NtscGadg	;next gadget
	dc.w	225,20		;origin XY of hit box
	dc.w	108,10		;hit box width and height
	dc.w	GADGHIMAGE	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border1		;gadget border or image to be rendered
	dc.l	Border2		;alternate imagery for selection
	dc.l	.IText		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	0		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	DoHires		;pointer to user-definable data

.IText
	dc.b	1,0,RP_JAM1,0	;front/back text pens, drawmode/fill byte
	dc.w	2,2		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text		;pointer to text
	dc.l	0		;next IntuiText structure

.Text
	dc.b	'HiRes ( 64O )',0
	even

NtscGadg
	dc.l	PalGadg		;next gadget
	dc.w	100,37		;origin XY of hit box
	dc.w	108,10		;hit box width and height
	dc.w	GADGHIMAGE	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border1		;gadget border or image to be rendered
	dc.l	Border2		;alternate imagery for selection
	dc.l	.IText		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	0		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	DoNtsc		;pointer to user-definable data

.IText
	dc.b	1,0,RP_JAM1,0	;front/back text pens, drawmode/fill byte
	dc.w	2,2		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text		;pointer to text
	dc.l	.IText2		;next IntuiText structure

.Text
	dc.b	'NTSC ( 2OO )',0
	even

.IText2
	dc.b	1,0,RP_JAM2,0	;front/back text pens, drawmode/fill byte
	dc.w	-90,2		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text2		;pointer to text
	dc.l	0		;next IntuiText structure


.Text2
	dc.b	'Type   ->',0
	even

PalGadg
	dc.l	WidthGadg	;next gadget
	dc.w	225,37		;origin XY of hit box
	dc.w	108,10		;hit box width and height
	dc.w	SELECTED+GADGHIMAGE	;gadget flags
	dc.w	GADGIMMEDIATE	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border1		;gadget border or image to be rendered
	dc.l	Border2		;alternate imagery for selection
	dc.l	.IText		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	0		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	DoPal		;pointer to user-definable data

.IText
	dc.b	1,0,RP_JAM1,0	;front/back text pens, drawmode/fill byte
	dc.w	6,2		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text		;pointer to text
	dc.l	0		;next IntuiText structure

.Text
	dc.b	'PAL ( 256 )',0
	even

WidthGadg
	dc.l	HeightGadg	;next gadget
	dc.w	100,72		;origin XY of hit box
	dc.w	50,9		;hit box width and height
	dc.w	0		;gadget flags
	dc.w	RELVERIFY+LONGINT	;activation flags
	dc.w	STRGADGET	;gadget type flags
	dc.l	Border3		;gadget border or image to be rendered
	dc.l	0		;alternate imagery for selection
	dc.l	.IText		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	.SInfo		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	0		;pointer to user-definable data

.SInfo
	dc.l	WidthBuff	;buffer where text will be edited
	dc.l	UNDOBUFFER	;optional undo buffer
	dc.w	0		;character position in buffer
	dc.w	5		;maximum number of characters to allow
	dc.w	0		;first displayed character buffer position
	dc.w	0,0,0,0,0	;Intuition init and maintained variables
	dc.l	0		;Rastport of gadget
	dc.l	0		;initial value for integer gadgets
	dc.l	0		;alternate keymap

.IText
	dc.b	1,0,RP_JAM2,0	;front/back text pens, drawmode/fill byte
	dc.w	-90,2		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text		;pointer to text
	dc.l	0		;next IntuiText structure

.Text
	dc.b	'Width  ->',0
	even

HeightGadg
	dc.l	DepthGadg	;next gadget
	dc.w	100,87		;origin XY of hit box
	dc.w	50,9		;hit box width and height
	dc.w	0		;gadget flags
	dc.w	RELVERIFY+LONGINT	;activation flags
	dc.w	STRGADGET	;gadget type flags
	dc.l	Border3		;gadget border or image to be rendered
	dc.l	0		;alternate imagery for selection
	dc.l	.IText		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	.SInfo		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	0		;pointer to user-definable data

.SInfo
	dc.l	HeightBuff	;buffer where text will be edited
	dc.l	UNDOBUFFER	;optional undo buffer
	dc.w	0		;character position in buffer
	dc.w	5		;maximum number of characters to allow
	dc.w	0		;first displayed character buffer position
	dc.w	0,0,0,0,0	;Intuition init and maintained variables
	dc.l	0		;Rastport of gadget
	dc.l	0		;initial value for integer gadgets
	dc.l	0		;alternate keymap

.IText
	dc.b	1,0,RP_JAM2,0	;front/back text pens, drawmode/fill byte
	dc.w	-90,2		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text		;pointer to text
	dc.l	0		;next IntuiText structure

.Text
	dc.b	'Height ->',0
	even

DepthGadg
	dc.l	CancelGadg	;next gadget
	dc.w	100,103		;origin XY of hit box
	dc.w	50,9		;hit box width and height
	dc.w	0		;gadget flags
	dc.w	RELVERIFY+LONGINT	;activation flags
	dc.w	STRGADGET	;gadget type flags
	dc.l	Border3		;gadget border or image to be rendered
	dc.l	0		;alternate imagery for selection
	dc.l	.IText		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	.SInfo		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	0		;pointer to user-definable data

.SInfo
	dc.l	DepthBuff	;buffer where text will be edited
	dc.l	UNDOBUFFER	;optional undo buffer
	dc.w	0		;character position in buffer
	dc.w	2		;maximum number of characters to allow
	dc.w	0		;first displayed character buffer position
	dc.w	0,0,0,0,0	;Intuition init and maintained variables
	dc.l	0		;Rastport of gadget
	dc.l	0		;initial value for integer gadgets
	dc.l	0		;alternate keymap

.IText
	dc.b	1,0,RP_JAM2,0	;front/back text pens, drawmode/fill byte
	dc.w	-90,2		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text		;pointer to text
	dc.l	0		;next IntuiText structure

.Text
	dc.b	'Depth  ->',0
	even
CancelGadg
	dc.l	OkGadg		;next gadget
	dc.w	12,142		;origin XY of hit box
	dc.w	83,17		;hit box width and height
	dc.w	GADGHIMAGE	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border4		;gadget border or image to be rendered
	dc.l	Border5		;alternate imagery for selection
	dc.l	.IText		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	0		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	DoQuit		;pointer to user-definable data

.IText
	dc.b	1,0,RP_JAM2,0	;front/back text pens, drawmode/fill byte
	dc.w	14,5		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text		;pointer to text
	dc.l	0		;next IntuiText structure

.Text
	dc.b	' Quit',0
	even

OkGadg
	dc.l	DefaultGadg	;next gadget
	dc.w	249,142		;origin XY of hit box
	dc.w	83,17		;hit box width and height
	dc.w	GADGHIMAGE	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border4		;gadget border or image to be rendered
	dc.l	Border5		;alternate imagery for selection
	dc.l	.IText		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	0		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	DoSave		;pointer to user-definable data

.IText
	dc.b	1,0,RP_JAM2,0	;front/back text pens, drawmode/fill byte
	dc.w	22,5		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text		;pointer to text
	dc.l	0		;next IntuiText structure

.Text
	dc.b	'OK !',0
	even
DefaultGadg
	dc.l	FileGadg	;next gadget
	dc.w	108,142		;origin XY of hit box
	dc.w	130,17		;hit box width and height
	dc.w	GADGHIMAGE	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border6		;gadget border or image to be rendered
	dc.l	Border7		;alternate imagery for selection
	dc.l	.IText		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	0		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	DoDefault	;pointer to user-definable data

.IText
	dc.b	1,0,RP_JAM2,0	;front/back text pens, drawmode/fill byte
	dc.w	3,5		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text		;pointer to text
	dc.l	0		;next IntuiText structure

.Text
	dc.b	'Restore Default',0
	even

FileGadg
	dc.l	0		;next gadget
	dc.w	100,119		;origin XY of hit box
	dc.w	230,9		;hit box width and height
	dc.w	0		;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	STRGADGET	;gadget type flags
	dc.l	Border8		;gadget border or image to be rendered
	dc.l	0		;alternate imagery for selection
	dc.l	.IText		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	.SInfo		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	0		;pointer to user-definable data

.SInfo
	dc.l	FileName	;buffer where text will be edited
	dc.l	UNDOBUFFER	;optional undo buffer
	dc.w	0		;character position in buffer
	dc.w	40		;maximum number of characters to allow
	dc.w	0		;first displayed character buffer position
	dc.w	0,0,0,0,0	;Intuition init and maintained variables
	dc.l	0		;Rastport of gadget
	dc.l	0		;initial value for integer gadgets
	dc.l	0		;alternate keymap

.IText
	dc.b	1,0,RP_JAM2,0	;front/back text pens, drawmode/fill byte
	dc.w	-90,2		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or NULL for default
	dc.l	.Text		;pointer to text
	dc.l	0		;next IntuiText structure

.Text
	dc.b	'Filename',0
	even

********************** WBench2 type gadget borders

; For mutual exclude gadgets

Border1
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors	;pointer to XY vectors
	dc.l	.Border		;next border in list

.Vectors
	dc.w	0,11
	dc.w	0,0
	dc.w	111,0

.Border
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors1	;pointer to XY vectors
	dc.l	0		;next border in list

.Vectors1
	dc.w	111,1
	dc.w	111,11
	dc.w	1,11

Border2
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors	;pointer to XY vectors
	dc.l	.Border		;next border in list

.Vectors
	dc.w	0,11
	dc.w	0,0
	dc.w	111,0

.Border
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors1	;pointer to XY vectors
	dc.l	0		;next border in list

.Vectors1
	dc.w	111,1
	dc.w	111,11
	dc.w	1,11

; Integer gadget borders

Border3
	dc.w	-2,-2		;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors	;pointer to XY vectors
	dc.l	.Border		;next border in list

.Vectors
	dc.w	0,10
	dc.w	0,0
	dc.w	53,0

.Border
	dc.w	-2,-2		;XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors1	;pointer to XY vectors
	dc.l	0		;next border in list

.Vectors1
	dc.w	53,1
	dc.w	53,10
	dc.w	1,10

; OK and cancel gadgets

Border4
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors	;pointer to XY vectors
	dc.l	.Border		;next border in list

.Vectors
	dc.w	0,18
	dc.w	0,0
	dc.w	86,0

.Border
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors1	;pointer to XY vectors
	dc.l	0		;next border in list

.Vectors1
	dc.w	86,1
	dc.w	86,18
	dc.w	1,18

Border5
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors	;pointer to XY vectors
	dc.l	.Border		;next border in list

.Vectors
	dc.w	0,18
	dc.w	0,0
	dc.w	86,0

.Border
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors1	;pointer to XY vectors
	dc.l	0		;next border in list

.Vectors1
	dc.w	86,1
	dc.w	86,18
	dc.w	1,18

; Default gadget

Border6
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors	;pointer to XY vectors
	dc.l	.Border		;next border in list

.Vectors
	dc.w	0,18
	dc.w	0,0
	dc.w	133,0

.Border
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors1	;pointer to XY vectors
	dc.l	0		;next border in list

.Vectors1
	dc.w	133,1
	dc.w	133,18
	dc.w	1,18

Border7
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors	;pointer to XY vectors
	dc.l	.Border		;next border in list

.Vectors
	dc.w	0,18
	dc.w	0,0
	dc.w	133,0

.Border
	dc.w	-2,-1		;XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors1	;pointer to XY vectors
	dc.l	0		;next border in list

.Vectors1
	dc.w	133,1
	dc.w	133,18
	dc.w	1,18

; For the filename gadget

Border8
	dc.w	-2,-2		;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors	;pointer to XY vectors
	dc.l	.Border		;next border in list

.Vectors
	dc.w	0,10
	dc.w	0,0
	dc.w	233,0

.Border
	dc.w	-2,-2		;XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM2	;front pen, back pen and drawmode
	dc.b	3		;number of XY vectors
	dc.l	.Vectors1	;pointer to XY vectors
	dc.l	0		;next border in list

.Vectors1
	dc.w	233,1
	dc.w	233,10
	dc.w	1,10

WinText
	dc.b	2,0,RP_JAM2,0	;front/back text pens, drawmode/fill byte
	dc.w	10,55		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or 0 for default
	dc.l	.Text		;pointer to text
	dc.l	0		;next IntuiText structure
.Text
	dc.b	'PlayField Dimensions',0
	even


WidthBuff	dc.b	'320',0,0
		even
HeightBuff	dc.b	'256',0,0
		even
DepthBuff	dc.b	'4',0
		even
FileName	dc.b	'ram:copper.s'
		ds.b	30
UNDOBUFFER	ds.b 	41
		even

		
; end of PowerWindows source generation

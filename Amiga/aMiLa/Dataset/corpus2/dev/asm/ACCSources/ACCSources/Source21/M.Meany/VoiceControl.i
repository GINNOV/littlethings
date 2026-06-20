

MyWindow
	dc.w	123,37			window XY origin 
	dc.w	383,159			window width and height
	dc.b	0,1			detail and block pens
	dc.l	GADGETUP		IDCMP flags
	dc.l	ACTIVATE+NOCAREREFRESH	other window flags
	dc.l	ModeProp		first gadget in gadget list
	dc.l	0			custom CHECKMARK imagery
	dc.l	0			window title
	dc.l	0			custom screen pointer
	dc.l	0			custom bitmap
	dc.w	5,5			minimum width and height
	dc.w	640,200			maximum width and height
	dc.w	WBENCHSCREEN		destination screen type

ModeProp:
	dc.l	RateProp		next gadget
	dc.w	85,75			origin XY of hit box
	dc.w	200,8			hit box width and height
	dc.w	0			gadget flags
	dc.w	RELVERIFY		activation flags
	dc.w	PROPGADGET		gadget type flags
	dc.l	Image1			gadget border or image ( rendered )
	dc.l	0			alternate imagery for selection
	dc.l	0			first IntuiText structure
	dc.l	0			gadget mutual-exclude long word
	dc.l	ModePropSInfo		SpecialInfo structure
	dc.w	0			user-definable data
	dc.l	VCSetMode		pointer to user-definable data
ModePropSInfo:
	dc.w	AUTOKNOB+FREEHORIZ	PROPINFO flags
	dc.w	-1,0			horizontal and vertical pot values
	dc.w	32767,-1		horizontal and vertical body values
	dc.w	0,0,0,0,0,0		(filled in by Intuition)
Image1:
	dc.w	1,0			XY origin relative
	dc.w	96,4			Image width and height in pixels
	dc.w	0			number of bitplanes in Image
	dc.l	0			pointer to ImageData
	dc.b	$0000,$0000		PlanePick and PlaneOnOff
	dc.l	0			next Image structure
RateProp:
	dc.l	PitchProp		next gadget
	dc.w	85,25			origin XY of hit box 
	dc.w	200,8			hit box width and height
	dc.w	0			gadget flags
	dc.w	RELVERIFY		activation flags
	dc.w	PROPGADGET		gadget type flags
	dc.l	Image2			gadget border or image
	dc.l	0			alternate imagery for selection
	dc.l	0			first IntuiText structure
	dc.l	0			gadget mutual-exclude long word
	dc.l	RatePropSInfo		SpecialInfo structure
	dc.w	0			user-definable data
	dc.l	VCSetRate		pointer to user-definable data
RatePropSInfo:
	dc.w	AUTOKNOB+FREEHORIZ	PROPINFO flags
	dc.w	9464,0			pot values ( 40 < actual )
	dc.w	182,-1			horizontal and vertical body values
	dc.w	0,0,0,0,0,0		(filled in by Intuition)
Image2:
	dc.w	0,0			XY origin
	dc.w	6,4			Image width and height in pixels
	dc.w	0			number of bitplanes in Image
	dc.l	0			pointer to ImageData
	dc.b	$0000,$0000		PlanePick and PlaneOnOff
	dc.l	0			next Image structure
PitchProp:
	dc.l	FreqProp		next gadget
	dc.w	85,35			origin XY of hit box
	dc.w	200,8			hit box width and height
	dc.w	0			gadget flags
	dc.w	RELVERIFY		activation flags
	dc.w	PROPGADGET		gadget type flags
	dc.l	Image3			gadget border or image
	dc.l	0			alternate imagery for selection
	dc.l	0			first IntuiText structure
	dc.l	0			gadget mutual-exclude long word
	dc.l	PitchPropSInfo		SpecialInfo structure
	dc.w	0			user-definable data
	dc.l	VCSetPitch		pointer to user-definable data
PitchPropSInfo:
	dc.w	AUTOKNOB+FREEHORIZ		PROPINFO flags
	dc.w	10280,0			pot values ( 65 < actual )
	dc.w	257,-1			horizontal and vertical body values
	dc.w	0,0,0,0,0,0		(filled in by Intuition)
Image3:
	dc.w	0,0			XY origin
	dc.w	6,4			Image width and height in pixels
	dc.w	0			number of bitplanes in Image
	dc.l	0			pointer to ImageData
	dc.b	$0000,$0000		PlanePick and PlaneOnOff
	dc.l	0			next Image structure
FreqProp:
	dc.l	VolProp			next gadget
	dc.w	85,45			origin XY of hit box relative to window TopLeft
	dc.w	200,8			hit box width and height
	dc.w	0			gadget flags
	dc.w	RELVERIFY		activation flags
	dc.w	PROPGADGET		gadget type flags
	dc.l	Image4			gadget border or image to be rendered
	dc.l	0			alternate imagery for selection
	dc.l	0			first IntuiText structure
	dc.l	0			gadget mutual-exclude long word
	dc.l	FreqPropSInfo		SpecialInfo structure
	dc.w	0			user-definable data
	dc.l	VCSetFreq		pointer to user-definable data
FreqPropSInfo:
	dc.w	AUTOKNOB+FREEHORIZ		PROPINFO flags
	dc.w	46770,0			horizontal and vertical pot values
	dc.w	3,-1			horizontal and vertical body values
	dc.w	0,0,0,0,0,0		previous requester (filled in by Intuition)
Image4:
	dc.w	0,0			XY origin relative to container TopLeft
	dc.w	6,4			Image width and height in pixels
	dc.w	0			number of bitplanes in Image
	dc.l	0			pointer to ImageData
	dc.b	$0000,$0000		PlanePick and PlaneOnOff
	dc.l	0			next Image structure
VolProp:
	dc.l	SexProp			next gadget
	dc.w	85,55			origin XY of hit box relative to window TopLeft
	dc.w	200,8			hit box width and height
	dc.w	0			gadget flags
	dc.w	RELVERIFY		activation flags
	dc.w	PROPGADGET		gadget type flags
	dc.l	Image5			gadget border or image to be rendered
	dc.l	0			alternate imagery for selection
	dc.l	0			first IntuiText structure
	dc.l	0			gadget mutual-exclude long word
	dc.l	VolPropSInfo		SpecialInfo structure
	dc.w	0			user-definable data
	dc.l	VCSetVol			pointer to user-definable data
VolPropSInfo:
	dc.w	AUTOKNOB+FREEHORIZ		PROPINFO flags
	dc.w	-1,0			horizontal and vertical pot values
	dc.w	1023,-1			horizontal and vertical body values
	dc.w	0,0,0,0,0,0		previous requester (filled in by Intuition)
Image5:
	dc.w	0,0			XY origin relative to container TopLeft
	dc.w	6,4			Image width and height in pixels
	dc.w	0			number of bitplanes in Image
	dc.l	0			pointer to ImageData
	dc.b	$0000,$0000		PlanePick and PlaneOnOff
	dc.l	0			next Image structure
SexProp:
	dc.l	Gadget7			next gadget
	dc.w	85,65			origin XY of hit box relative to window TopLeft
	dc.w	200,8			hit box width and height
	dc.w	0			gadget flags
	dc.w	RELVERIFY		activation flags
	dc.w	PROPGADGET		gadget type flags
	dc.l	Image6			gadget border or image to be rendered
	dc.l	0			alternate imagery for selection
	dc.l	0			first IntuiText structure
	dc.l	0			gadget mutual-exclude long word
	dc.l	SexPropSInfo		SpecialInfo structure
	dc.w	0			user-definable data
	dc.l	VCSetSex		pointer to user-definable data
SexPropSInfo:
	dc.w	AUTOKNOB+FREEHORIZ		PROPINFO flags
	dc.w	1,0			horizontal and vertical pot values
	dc.w	32767,-1		horizontal and vertical body values
	dc.w	0,0,0,0,0,0		previous requester (filled in by Intuition)
Image6:
	dc.w	0,0			XY origin relative to container TopLeft
	dc.w	96,4			Image width and height in pixels
	dc.w	0			number of bitplanes in Image
	dc.l	0			pointer to ImageData
	dc.b	$0000,$0000		PlanePick and PlaneOnOff
	dc.l	0			next Image structure
Gadget7:
	dc.l	Gadget8			next gadget
	dc.w	85,105			origin XY of hit box relative to window TopLeft
	dc.w	228,9			hit box width and height
	dc.w	0			gadget flags
	dc.w	RELVERIFY		activation flags
	dc.w	STRGADGET		gadget type flags
	dc.l	Border1			gadget border or image to be rendered
	dc.l	0			alternate imagery for selection
	dc.l	0			first IntuiText structure
	dc.l	0			gadget mutual-exclude long word
	dc.l	Gadget7SInfo		SpecialInfo structure
	dc.w	0			user-definable data
	dc.l	VCTestVoice		pointer to user-definable data
Gadget7SInfo:
	dc.l	TestTextBuff		buffer where text will be edited
	dc.l	0			optional undo buffer
	dc.w	0			character position in buffer
	dc.w	40			maximum number of characters to allow
	dc.w	0			first displayed character buffer position
	dc.w	0,0,0,0,0		Intuition initialized and maintained variables
	dc.l	0			Rastport of gadget
	dc.l	0			initial value for integer gadgets
	dc.l	0			alternate keymap (fill in if you set the flag)
TestTextBuff
	dc.b	'Hello.'
	dcb.b 35,0
	even
Border1:
	dc.w	-2,-1			XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM1		front pen, back pen and drawmode
	dc.b	5			number of XY vectors
	dc.l	BorderVectors1		pointer to XY vectors
	dc.l	0			next border in list
BorderVectors1:
	dc.w	0,0
	dc.w	231,0
	dc.w	231,10
	dc.w	0,10
	dc.w	0,0
Gadget8:
	dc.l	Gadget9			next gadget
	dc.w	27,135			origin XY of hit box relative to window TopLeft
	dc.w	81,16			hit box width and height
	dc.w	0			gadget flags
	dc.w	RELVERIFY		activation flags
	dc.w	BOOLGADGET		gadget type flags
	dc.l	Border2			gadget border or image to be rendered
	dc.l	0			alternate imagery for selection
	dc.l	IText1			first IntuiText structure
	dc.l	0			gadget mutual-exclude long word
	dc.l	0			SpecialInfo structure
	dc.w	0			user-definable data
	dc.l	0			pointer to user-definable data
Border2:
	dc.w	-2,-1			XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM1		front pen, back pen and drawmode
	dc.b	5			number of XY vectors
	dc.l	BorderVectors2		pointer to XY vectors
	dc.l	0			next border in list
BorderVectors2:
	dc.w	0,0
	dc.w	84,0
	dc.w	84,17
	dc.w	0,17
	dc.w	0,0
IText1:
	dc.b	2,0,RP_JAM2,0		front and back text pens, drawmode and fill byte
	dc.w	25,5			XY origin relative to container TopLeft
	dc.l	0			font pointer or NULL for default
	dc.l	ITextText1		pointer to text
	dc.l	0			next IntuiText structure
ITextText1:
	dc.b	'USE',0
	even
Gadget9:
	dc.l	0			next gadget
	dc.w	278,135			origin XY of hit box relative to window TopLeft
	dc.w	81,16			hit box width and height
	dc.w	0			gadget flags
	dc.w	RELVERIFY		activation flags
	dc.w	BOOLGADGET		gadget type flags
	dc.l	Border3			gadget border or image to be rendered
	dc.l	0			alternate imagery for selection
	dc.l	IText2			first IntuiText structure
	dc.l	0			gadget mutual-exclude long word
	dc.l	0			SpecialInfo structure
	dc.w	0			user-definable data
	dc.l	VCQuit			pointer to user-definable data
Border3:
	dc.w	-2,-1			XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM1		front pen, back pen and drawmode
	dc.b	5			number of XY vectors
	dc.l	BorderVectors3		pointer to XY vectors
	dc.l	0			next border in list
BorderVectors3:
	dc.w	0,0
	dc.w	84,0
	dc.w	84,17
	dc.w	0,17
	dc.w	0,0
IText2:
	dc.b	2,0,RP_JAM2,0		front and back text pens, drawmode and fill byte
	dc.w	18,5			XY origin relative to container TopLeft
	dc.l	0			font pointer or NULL for default
	dc.l	ITextText2		pointer to text
	dc.l	0			next IntuiText structure
ITextText2:
	dc.b	'CANCEL',0
	even

WinText
	dc.b	1,0,RP_JAM2,0		front and back text pens, drawmode and fill byte
	dc.w	129,9			XY origin relative to container TopLeft
	dc.l	0			font pointer or NULL for default
	dc.l	ITextText3		pointer to text
	dc.l	IText4			next IntuiText structure
ITextText3:
	dc.b	'Voice Control',0
	even
IText4:
	dc.b	1,0,RP_JAM2,0		front and back text pens, drawmode and fill byte
	dc.w	8,25			XY origin relative to container TopLeft
	dc.l	0			font pointer or NULL for default
	dc.l	ITextText4		pointer to text
	dc.l	IText5			next IntuiText structure
ITextText4:
	dc.b	'Rate',0
	even
IText5:
	dc.b	1,0,RP_JAM2,0		front and back text pens, drawmode and fill byte
	dc.w	8,35			XY origin relative to container TopLeft
	dc.l	0			font pointer or NULL for default
	dc.l	ITextText5		pointer to text
	dc.l	IText6			next IntuiText structure
ITextText5:
	dc.b	'Pitch',0
	even
IText6:
	dc.b	1,0,RP_JAM2,0		front and back text pens, drawmode and fill byte
	dc.w	8,45			XY origin relative to container TopLeft
	dc.l	0			font pointer or NULL for default
	dc.l	ITextText6		pointer to text
	dc.l	IText7			next IntuiText structure
ITextText6:
	dc.b	'Frequency',0
	even
IText7:
	dc.b	1,0,RP_JAM2,0		front and back text pens, drawmode and fill byte
	dc.w	8,55			XY origin relative to container TopLeft
	dc.l	0			font pointer or NULL for default
	dc.l	ITextText7		pointer to text
	dc.l	IText8			next IntuiText structure
ITextText7:
	dc.b	'Volume',0
	even
IText8:
	dc.b	1,0,RP_JAM2,0		front and back text pens, drawmode and fill byte
	dc.w	8,65			XY origin relative to container TopLeft
	dc.l	0			font pointer or NULL for default
	dc.l	ITextText8		pointer to text
	dc.l	IText9			next IntuiText structure
ITextText8:
	dc.b	'Sex',0
	evenIText9:
	dc.b	1,0,RP_JAM2,0		front and back text pens, drawmode and fill byte
	dc.w	8,75			XY origin relative to container TopLeft
	dc.l	0			font pointer or NULL for default
	dc.l	ITextText9		pointer to text
	dc.l	0			next IntuiText structure
IText9:
	dc.b	1,0,RP_JAM2,0		front and back text pens, drawmode and fill byte
	dc.w	8,75			XY origin relative to container TopLeft
	dc.l	0			font pointer or NULL for default
	dc.l	ITextText9		pointer to text
	dc.l	0			next IntuiText structure
ITextText9:
	dc.b	'Mode',0
	even

SettingsText
	dc.b	1,0,RP_JAM2,0		front and back text pens, drawmode and fill byte
	dc.w	0,0			XY origin relative to container TopLeft
	dc.l	0			font pointer or NULL for default
	dc.l	TempSetBuf		pointer to text
	dc.l	0			next IntuiText structure

TempSetBuf
	ds.b	14
	even


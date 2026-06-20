
; Defenition of Screen, Window, Proportional Gadget & Imagery.

MyScreen
	dc.w	0,0		;screen XY origin relative to View
	dc.w	640,256		;screen width and height
	dc.w	4		;screen depth (number of bitplanes)
	dc.b	0,1		;detail and block pens
	dc.w	V_HIRES		;display modes for this screen
	dc.w	CUSTOMSCREEN	;screen type
	dc.l	0		;pointer to default screen font
	dc.l	.Title		;screen title
	dc.l	0		;first in list of custom screen gadgets
	dc.l	0		;pointer to custom BitMap structure

.Title	dc.b	'This is a sixteen colour screen',0
	even

Palette
	dc.w	$02CD		;color #0
	dc.w	$0000		;color #1
	dc.w	$0C00		;color #2
	dc.w	$0B96		;color #3
	dc.w	$0090		;color #4
	dc.w	$03F1		;color #5
	dc.w	$0EA5		;color #6
	dc.w	$0ECA		;color #7
	dc.w	$0454		;color #8
	dc.w	$0400		;color #9
	dc.w	$0000		;color #10
	dc.w	$0101		;color #11
	dc.w	$0454		;color #12
	dc.w	$0400		;color #13
	dc.w	$0004		;color #14
	dc.w	$0C00		;color #15

ColorCount equ 16

MyWindow
	dc.w	89,24		;window XY origin
	dc.w	503,169		;window width and height
	dc.b	0,1		;detail and block pens
	dc.l	GADGETUP+CLOSEWINDOW	;IDCMP flags
	dc.l	WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE	;other window flags
	dc.l	PropGadg	;first gadget in gadget list
	dc.l	0		;custom CHECKMARK imagery
	dc.l	WindowName	;window title
win_scrn dc.l	0	;custom screen pointer
	dc.l	0		;custom bitmap
	dc.w	5,5		;minimum width and height
	dc.w	640,200		;maximum width and height
	dc.w	CUSTOMSCREEN	;destination screen type

WindowName	dc.b	'Colour Prop Gadget by M.Meany',0
	even

PropGadg:
	dc.l	0		;next gadget
	dc.w	8,13		;origin XY of hit box relative to window TopLeft
	dc.w	359,106		;hit box width and height
	dc.w	GADGHIMAGE+GADGIMAGE	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	PROPGADGET	;gadget type flags
	dc.l	Image1		;gadget border or image to be rendered
	dc.l	Image1		;alternate imagery for selection << SAME >>
	dc.l	0		;first IntuiText structure
	dc.l	0		;gadget mutual-exclude long word
	dc.l	.SInfo		;SpecialInfo structure
	dc.w	0		;user-definable data
	dc.l	DoProp		;pointer to user-definable data

.SInfo:
	dc.w	FREEHORIZ+FREEVERT	;PROPINFO flags
	dc.w	-11300,-3025	;horizontal and vertical pot values
	dc.w	327,655		;horizontal and vertical body values
	dc.w	0,0,0,0,0,0	;previous requester (filled in by Intuition)

Image1:
	dc.w	264,62		;XY origin relative to container TopLeft
	dc.w	32,37		;Image width and height in pixels
	dc.w	3		;number of bitplanes in Image
	dc.l	FaceData	;pointer to ImageData
	dc.b	$0007,$0000	;PlanePick and PlaneOnOff
	dc.l	0		;next Image structure

HPotIText
	dc.b	12,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	12,125		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or NULL for default
	dc.l	.Text		;pointer to text
	dc.l	VPotIText	;next IntuiText structure

.Text
	dc.b	'Horizontal Value ( 0 to 200 ) is '
HPotText
	ds.b	16
	even

VPotIText
	dc.b	12,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	12,136		;XY origin relative to container TopLeft
	dc.l	0		;font pointer or NULL for default
	dc.l	.Text		;pointer to text
	dc.l	0		;next IntuiText structure
.Text
	dc.b	'Vertical Value ( 0 to 100 ) is   '
VPotText
	ds.b	16
	even

	section gfx,data_c

FaceData
	dc.w	$0000,$0000,$0000,$F000,$0007,$E000,$019F,$E078
	dc.w	$03BF,$CFF0,$07FF,$FFC0,$0FFF,$FF80,$1FFF,$FFFE
	dc.w	$1FFF,$FFFE,$1FFF,$FFF8,$1FFF,$FFFC,$1FFF,$FFE6
	dc.w	$1FFF,$FFC3,$1FFF,$FFC0,$3FFF,$FFC0,$7FFF,$FFC0
	dc.w	$7FFF,$FFC0,$7FFF,$FFC0,$7FFF,$FF80,$7FFF,$FFC0
	dc.w	$3FFF,$FFE0,$1FFF,$FFF0,$1FFF,$FFF8,$3FFF,$FFFC
	dc.w	$7FFF,$FFFC,$7FFF,$FFFC,$7FFF,$FFFC,$7FFF,$FFFC
	dc.w	$7FFF,$FFF8,$7FFF,$FFF8,$7FFF,$FFF0,$3FFF,$FFE0
	dc.w	$1FFF,$FFE0,$0FFF,$FFC0,$03FF,$FF80,$01FF,$F800
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$C800,$0031,$F800,$000F,$FC00
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$03C0,$0000
	dc.w	$3FC0,$0000,$2FE0,$3000,$23E0,$7000,$3FF8,$7800
	dc.w	$3BFF,$FF80,$07FF,$FFC0,$0FFF,$FFE0,$0FCF,$FFF0
	dc.w	$1F83,$FEF8,$3F00,$0178,$3F00,$C778,$3F00,$C7F8
	dc.w	$3F00,$FFF8,$3F7C,$FFF0,$3FBD,$FFF0,$3FC3,$FFE0
	dc.w	$1FFF,$FFC0,$0FFF,$FFC0,$03FF,$FF80,$01FF,$F000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$C800,$0031,$F800
	dc.w	$000F,$FC00,$0000,$0000,$0010,$0040,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$3000,$0000,$7000
	dc.w	$0038,$7800,$00FF,$FF80,$03FF,$FFC0,$07FF,$FFE0
	dc.w	$0FCF,$FFF0,$0F83,$FEF8,$0F00,$0178,$0F00,$D778
	dc.w	$0F00,$C7F8,$0F00,$FFF8,$0700,$FFF0,$0181,$FFF0
	dc.w	$0043,$FFE0,$001F,$FFC0,$0003,$FE00,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000


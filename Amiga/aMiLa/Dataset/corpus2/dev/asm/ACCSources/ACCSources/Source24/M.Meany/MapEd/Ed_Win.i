
EdWindow
	dc.w	0,192
	dc.w	320,64
	dc.b	0,1
	dc.l	0			 GADGETDOWN+GADGETUP+RAWKEY
	dc.l	BORDERLESS+NOCAREREFRESH
	dc.l	Gadg1
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	CUSTOMSCREEN

Gadg1
	dc.l	Gadg2
	dc.w	0,48
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	20
	dc.l	SelectBlock 0

Gadg2
	dc.l	Gadg3
	dc.w	2,1
	dc.w	48,9
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border1
	dc.l	0
	dc.l	.IText1
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoFW
.Border1
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.BorderVectors1
	dc.l	0
.BorderVectors1
	dc.w	0,0
	dc.w	51,0
	dc.w	51,10
	dc.w	0,10
	dc.w	0,0
.IText1
	dc.b	3,0,RP_JAM2,0
	dc.w	0,1
	dc.l	0
	dc.l	.ITextText1
	dc.l	0
.ITextText1
	dc.b	'Files',0
	even
Gadg3
	dc.l	Gadg4
	dc.w	59,1
	dc.w	48,9
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border2
	dc.l	0
	dc.l	.IText2
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	0
.Border2
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.BorderVectors2
	dc.l	0
.BorderVectors2
	dc.w	0,0
	dc.w	51,0
	dc.w	51,10
	dc.w	0,10
	dc.w	0,0
.IText2
	dc.b	3,0,RP_JAM2,0
	dc.w	4,1
	dc.l	0
	dc.l	.ITextText2
	dc.l	0
.ITextText2
	dc.b	'Block',0
	even
Gadg4
	dc.l	Gadg5
	dc.w	116,1
	dc.w	48,9
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border3
	dc.l	0
	dc.l	.IText3
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoBME
.Border3
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.BorderVectors3
	dc.l	0
.BorderVectors3
	dc.w	0,0
	dc.w	51,0
	dc.w	51,10
	dc.w	0,10
	dc.w	0,0
.IText3
	dc.b	3,0,RP_JAM2,0
	dc.w	4,1
	dc.l	0
	dc.l	.ITextText3
	dc.l	0
.ITextText3
	dc.b	'Mask',0
	even
Gadg5
	dc.l	Gadg6
	dc.w	170,1
	dc.w	48,9
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border4
	dc.l	0
	dc.l	.IText4
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	0
.Border4
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.BorderVectors4
	dc.l	0
.BorderVectors4
	dc.w	0,0
	dc.w	51,0
	dc.w	51,10
	dc.w	0,10
	dc.w	0,0
.IText4
	dc.b	3,0,RP_JAM2,0
	dc.w	8,1
	dc.l	0
	dc.l	.ITextText4
	dc.l	0
.ITextText4
	dc.b	'CMAP',0
	even
Gadg6
	dc.l	Gadg7
	dc.w	224,1
	dc.w	48,9
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border5
	dc.l	0
	dc.l	.IText5
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	0
.Border5
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.BorderVectors5
	dc.l	0
.BorderVectors5
	dc.w	0,0
	dc.w	51,0
	dc.w	51,10
	dc.w	0,10
	dc.w	0,0
.IText5
	dc.b	3,0,RP_JAM2,0
	dc.w	8,1
	dc.l	0
	dc.l	.ITextText5
	dc.l	0
.ITextText5
	dc.b	'About',0
	even
Gadg7
	dc.l	Gadg8
	dc.w	278,1
	dc.w	37,9
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border6
	dc.l	0
	dc.l	.IText6
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	Clear
.Border6
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.BorderVectors6
	dc.l	0
.BorderVectors6
	dc.w	0,0
	dc.w	40,0
	dc.w	40,10
	dc.w	0,10
	dc.w	0,0
.IText6
	dc.b	3,0,RP_JAM2,0
	dc.w	6,1
	dc.l	0
	dc.l	.ITextText6
	dc.l	0
.ITextText6
	dc.b	'CLR',0
	even
Gadg8
	dc.l	Gadg9
	dc.w	268,54
	dc.w	48,9
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border7
	dc.l	0
	dc.l	.IText7
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	Quit
.Border7
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.BorderVectors7
	dc.l	0
.BorderVectors7
	dc.w	0,0
	dc.w	51,0
	dc.w	51,10
	dc.w	0,10
	dc.w	0,0
.IText7
	dc.b	3,0,RP_JAM2,0
	dc.w	8,1
	dc.l	0
	dc.l	.ITextText7
	dc.l	0
.ITextText7
	dc.b	'QUIT',0
	even
Gadg9
	dc.l	Gadg10
	dc.w	175,17
	dc.w	8,10
	dc.w	GADGIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Image2
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	UpBlock
Image2
	dc.w	0,0
	dc.w	8,10
	dc.w	4
	dc.l	ImageData2
	dc.b	$000d,$0000
	dc.l	0
ImageData2
	dc.w	$FF00,$FF00,$FF00,$FF00,$FF00,$FF00,$FF00,$FF00
	dc.w	$FF00,$FF00,$0000,$0000,$1800,$3C00,$1800,$1800
	dc.w	$1800,$1800,$0000,$0000,$0000,$0000,$1800,$3C00
	dc.w	$1800,$1800,$1800,$1800,$0000,$0000
Gadg10
	dc.l	Gadg11
	dc.w	175,51
	dc.w	8,10
	dc.w	GADGIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Image3
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DownBlock
Image3
	dc.w	0,0
	dc.w	8,10
	dc.w	4
	dc.l	ImageData3
	dc.b	$000d,$0000
	dc.l	0
ImageData3
	dc.w	$FF00,$FF00,$FF00,$FF00,$FF00,$FF00,$FF00,$FF00
	dc.w	$FF00,$FF00,$0000,$0000,$1800,$1800,$1800,$1800
	dc.w	$3C00,$1800,$0000,$0000,$0000,$0000,$1800,$1800
	dc.w	$1800,$1800,$3C00,$1800,$0000,$0000
Gadg11
	dc.l	Gadg12
	dc.w	214,22
	dc.w	8,10
	dc.w	GADGIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Image4
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DownScrn
Image4
	dc.w	0,0
	dc.w	8,10
	dc.w	4
	dc.l	ImageData4
	dc.b	$000d,$0000
	dc.l	0
ImageData4
	dc.w	$FF00,$FF00,$FF00,$FF00,$FF00,$FF00,$FF00,$FF00
	dc.w	$FF00,$FF00,$0000,$0000,$1800,$3C00,$1800,$1800
	dc.w	$1800,$1800,$0000,$0000,$0000,$0000,$1800,$3C00
	dc.w	$1800,$1800,$1800,$1800,$0000,$0000
Gadg12
	dc.l	Gadg13
	dc.w	214,42
	dc.w	8,10
	dc.w	GADGIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Image5
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	UpScrn
Image5
	dc.w	0,0
	dc.w	8,10
	dc.w	4
	dc.l	ImageData5
	dc.b	$000d,$0000
	dc.l	0
ImageData5
	dc.w	$FF00,$FF00,$FF00,$FF00,$FF00,$FF00,$FF00,$FF00
	dc.w	$FF00,$FF00,$0000,$0000,$1800,$1800,$1800,$1800
	dc.w	$3C00,$1800,$0000,$0000,$0000,$0000,$1800,$1800
	dc.w	$1800,$1800,$3C00,$1800,$0000,$0000
Gadg13
	dc.l	Gadg14
	dc.w	223,33
	dc.w	10,8
	dc.w	GADGIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Image6
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	LeftScrn
Image6
	dc.w	0,0
	dc.w	10,8
	dc.w	4
	dc.l	ImageData6
	dc.b	$000d,$0000
	dc.l	0
ImageData6
	dc.w	$FFC0,$FFC0,$FFC0,$FFC0,$FFC0,$FFC0,$FFC0,$FFC0
	dc.w	$0000,$0000,$0200,$3F00,$3F00,$0200,$0000,$0000
	dc.w	$0000,$0000,$0200,$3F00,$3F00,$0200,$0000,$0000
Gadg14
	dc.l	Gadg15
	dc.w	203,33
	dc.w	10,8
	dc.w	GADGIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Image7
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	RightScrn
Image7
	dc.w	0,0
	dc.w	10,8
	dc.w	4
	dc.l	ImageData7
	dc.b	$000d,$0000
	dc.l	0
ImageData7
	dc.w	$FFC0,$FFC0,$FFC0,$FFC0,$FFC0,$FFC0,$FFC0,$FFC0
	dc.w	$0000,$0000,$1000,$3F00,$3F00,$1000,$0000,$0000
	dc.w	$0000,$0000,$1000,$3F00,$3F00,$1000,$0000,$0000
Gadg15
	dc.l	Gadg16
	dc.w	17,48
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	21
	dc.l	SelectBlock 0
Gadg16
	dc.l	Gadg17
	dc.w	34,48
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	22
	dc.l	SelectBlock 0
Gadg17
	dc.l	Gadg18
	dc.w	51,48
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	23
	dc.l	SelectBlock 0
Gadg18
	dc.l	Gadg19
	dc.w	68,48
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	24
	dc.l	SelectBlock 0
Gadg19
	dc.l	Gadg20
	dc.w	85,48
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	25
	dc.l	SelectBlock 0
Gadg20
	dc.l	Gadg21
	dc.w	102,48
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	26
	dc.l	SelectBlock 0
Gadg21
	dc.l	Gadg22
	dc.w	119,48
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	27
	dc.l	SelectBlock 0
Gadg22
	dc.l	Gadg23
	dc.w	136,48
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	28
	dc.l	SelectBlock 0
Gadg23
	dc.l	Gadg24
	dc.w	153,48
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	29
	dc.l	SelectBlock 0
Gadg24
	dc.l	Gadg25
	dc.w	0,31
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	10
	dc.l	SelectBlock 0
Gadg25
	dc.l	Gadg26
	dc.w	0,14
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SelectBlock 0
Gadg26
	dc.l	Gadg27
	dc.w	17,31
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	11
	dc.l	SelectBlock 0
Gadg27
	dc.l	Gadg28
	dc.w	34,31
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	12
	dc.l	SelectBlock 0
Gadg28
	dc.l	Gadg29
	dc.w	51,31
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	13
	dc.l	SelectBlock 0
Gadg29
	dc.l	Gadg30
	dc.w	68,31
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	14
	dc.l	SelectBlock 0
Gadg30
	dc.l	Gadg31
	dc.w	85,31
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	15
	dc.l	SelectBlock 0
Gadg31
	dc.l	Gadg32
	dc.w	102,31
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	16
	dc.l	SelectBlock 0
Gadg32
	dc.l	Gadg33
	dc.w	119,31
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	17
	dc.l	SelectBlock 0
Gadg33
	dc.l	Gadg34
	dc.w	136,31
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	18
	dc.l	SelectBlock 0
Gadg34
	dc.l	Gadg35
	dc.w	153,31
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	19
	dc.l	SelectBlock 0
Gadg35
	dc.l	Gadg36
	dc.w	17,14
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	1
	dc.l	SelectBlock 0
Gadg36
	dc.l	Gadg37
	dc.w	34,14
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	2
	dc.l	SelectBlock 0
Gadg37
	dc.l	Gadg38
	dc.w	51,14
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	3
	dc.l	SelectBlock 0
Gadg38
	dc.l	Gadg39
	dc.w	68,14
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	4
	dc.l	SelectBlock 0
Gadg39
	dc.l	Gadg40
	dc.w	85,14
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	5
	dc.l	SelectBlock 0
Gadg40
	dc.l	Gadg41
	dc.w	102,14
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	6
	dc.l	SelectBlock 0
Gadg41
	dc.l	Gadg42
	dc.w	119,14
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	7
	dc.l	SelectBlock 0
Gadg42
	dc.l	Gadg43
	dc.w	136,14
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	8
	dc.l	SelectBlock 0
Gadg43
	dc.l	0
	dc.w	153,14
	dc.w	16,16
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	9
	dc.l	SelectBlock 

WinText
	dc.b	3,0,RP_JAM2,0
	dc.w	240,15
	dc.l	0
	dc.l	.ITextText8
	dc.l	.IText9
.ITextText8
	dc.b	'Map Editor',0
	even
.IText9
	dc.b	3,0,RP_JAM2,0
	dc.w	240,27
	dc.l	0
	dc.l	.ITextText9
	dc.l	0
.ITextText9
	dc.b	'by M.Meany',0
	even

; Image structure used to draw blocks into editor

BlockImage
	dc.w	0,0
	dc.w	16,16
	dc.w	0
	dc.l	0
	dc.b	$1f,$00
	dc.l	0


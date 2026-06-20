

TunerWindow
	dc.w	150,60
	dc.w	400,100
	dc.b	0,1
	dc.l	GADGETUP+CLOSEWINDOW
	dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+RMBTRAP+NOCAREREFRESH
	dc.l	EGadget
	dc.l	0
	dc.l	.Name
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
.Name
	dc.b	'Guitar Tuner, by Mark & Phil.',0
	cnop 0,2


EGadget:
	dc.l	BGadget
	dc.w	39,74
	dc.w	29,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Border1
	dc.l	0
	dc.l	IText1
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	PlayE
Border1:
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors1
	dc.l	0
BorderVectors1:
	dc.w	0,0
	dc.w	32,0
	dc.w	32,16
	dc.w	0,16
	dc.w	0,0
IText1:
	dc.b	1,0,RP_JAM2,0
	dc.w	9,4
	dc.l	0
	dc.l	ITextText1
	dc.l	0
ITextText1:
	dc.b	'E',0
	cnop 0,2
BGadget
	dc.l	GGadget
	dc.w	87,74
	dc.w	29,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Border2
	dc.l	0
	dc.l	IText2
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	PlayB
Border2:
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors2
	dc.l	0
BorderVectors2:
	dc.w	0,0
	dc.w	32,0
	dc.w	32,16
	dc.w	0,16
	dc.w	0,0
IText2:
	dc.b	1,0,RP_JAM2,0
	dc.w	9,4
	dc.l	0
	dc.l	ITextText2
	dc.l	0
ITextText2:
	dc.b	'B',0
	cnop 0,2
GGadget
	dc.l	DGadget
	dc.w	134,74
	dc.w	29,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Border3
	dc.l	0
	dc.l	IText3
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	PlayG
Border3:
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors3
	dc.l	0
BorderVectors3:
	dc.w	0,0
	dc.w	32,0
	dc.w	32,16
	dc.w	0,16
	dc.w	0,0
IText3:
	dc.b	1,0,RP_JAM2,0
	dc.w	9,4
	dc.l	0
	dc.l	ITextText3
	dc.l	0
ITextText3:
	dc.b	'G',0
	cnop 0,2
DGadget
	dc.l	AGadget
	dc.w	179,74
	dc.w	29,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Border4
	dc.l	0
	dc.l	IText4
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	PlayD
Border4:
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors4
	dc.l	0
BorderVectors4:
	dc.w	0,0
	dc.w	32,0
	dc.w	32,16
	dc.w	0,16
	dc.w	0,0
IText4:
	dc.b	1,0,RP_JAM2,0
	dc.w	9,4
	dc.l	0
	dc.l	ITextText4
	dc.l	0
ITextText4:
	dc.b	'D',0
	cnop 0,2
AGadget
	dc.l	E1Gadget
	dc.w	223,74
	dc.w	29,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Border5
	dc.l	0
	dc.l	IText5
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	PlayA
Border5:
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors5
	dc.l	0
BorderVectors5:
	dc.w	0,0
	dc.w	32,0
	dc.w	32,16
	dc.w	0,16
	dc.w	0,0
IText5:
	dc.b	1,0,RP_JAM2,0
	dc.w	9,4
	dc.l	0
	dc.l	ITextText5
	dc.l	0
ITextText5:
	dc.b	'A',0
	cnop 0,2
E1Gadget:
	dc.l	StopGadget
	dc.w	265,74
	dc.w	29,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Border6
	dc.l	0
	dc.l	IText6
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	PlayE1
Border6:
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors6
	dc.l	0
BorderVectors6:
	dc.w	0,0
	dc.w	32,0
	dc.w	32,16
	dc.w	0,16
	dc.w	0,0
IText6:
	dc.b	1,0,RP_JAM2,0
	dc.w	9,4
	dc.l	0
	dc.l	ITextText6
	dc.l	0
ITextText6:
	dc.b	'E',0
	cnop 0,2
StopGadget:
	dc.l	0		;IntGadget
	dc.w	310,77
	dc.w	68,12
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Border7
	dc.l	0
	dc.l	IText7
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	StopSample
Border7:
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors7
	dc.l	0
BorderVectors7:
	dc.w	0,0
	dc.w	71,0
	dc.w	71,13
	dc.w	0,13
	dc.w	0,0
IText7:
	dc.b	1,0,RP_JAM2,0
	dc.w	16,2
	dc.l	0
	dc.l	ITextText7
	dc.l	0
ITextText7:
	dc.b	'STOP',0
	cnop 0,2

IntGadget:
	dc.l	0
	dc.w	133,32
	dc.w	75,11
	dc.w	0
	dc.w	RELVERIFY+LONGINT
	dc.w	STRGADGET
	dc.l	Border8
	dc.l	0
	dc.l	IText8
	dc.l	0
	dc.l	IntGadgetSInfo
	dc.w	0
	dc.l	DoInt
IntGadgetSInfo:
	dc.l	IntGadgetSIBuff
	dc.l	0
	dc.w	0
	dc.w	4
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0

NewPeriod
	dc.l	428
	dc.l	0
IntGadgetSIBuff:
	dc.b	'428',0
	cnop 0,2

Border8:
	dc.w	-4,-3
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors8
	dc.l	0
BorderVectors8:
	dc.w	0,0
	dc.w	78,0
	dc.w	78,12
	dc.w	0,12
	dc.w	0,0
IText8:
	dc.b	1,0,RP_JAM2,0
	dc.w	-66,2
	dc.l	0
	dc.l	ITextText8
	dc.l	0
ITextText8:
	dc.b	'Period',0
	cnop 0,2



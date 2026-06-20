

MainWindow
	dc.w	0,60
	dc.w	640,130
	dc.b	0,1
	dc.l	GADGETDOWN+GADGETUP+CLOSEWINDOW+INTUITICKS+MOUSEBUTTONS
	dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH+RMBTRAP
	dc.l	UpGadg
	dc.l	0
	dc.l	.Name
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
.Name
	dc.b	'Helper © M.Meany, March 92.',0
	even
	
UpGadg:
	dc.l	DownGadg
	dc.w	530,15
	dc.w	17,9
	dc.w	0
	dc.w	RELVERIFY+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoUp
.Border
	dc.w	-2,-1
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	20,0
	dc.w	20,10
	dc.w	0,10
	dc.w	0,0
.IText
	dc.b	1,0,RP_JAM1,0
	dc.w	4,1
	dc.l	TOPAZ60
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'U',0
	even

DownGadg:
	dc.l	SleepGadg
	dc.w	554,15
	dc.w	17,9
	dc.w	0
	dc.w	RELVERIFY+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoDown
.Border
	dc.w	-2,-1
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	20,0
	dc.w	20,10
	dc.w	0,10
	dc.w	0,0
.IText
	dc.b	1,0,RP_JAM1,0
	dc.w	4,1
	dc.l	TOPAZ60
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'D',0
	even

SleepGadg:
	dc.l	SearchGadg
	dc.w	582,15
	dc.w	46,9
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoSleep
.Border
	dc.w	-2,-1
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	49,0
	dc.w	49,10
	dc.w	0,10
	dc.w	0,0
.IText
	dc.b	1,0,RP_JAM1,0
	dc.w	7,1
	dc.l	TOPAZ60
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'zzZ',0
	even

SearchGadg:
	dc.l	0
	dc.w	156,15
	dc.w	349,9
	dc.w	SELECTED
	dc.w	RELVERIFY
	dc.w	STRGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoSolution
.SInfo
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	31
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
.Border
	dc.w	-2,-1
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	352,0
	dc.w	352,10
	dc.w	0,10
	dc.w	0,0
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	-118,1
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Search For ->',0
	even

***************	Sleeping window structure

SleepWindow:
    DC.W    30,0,175,12
    DC.B    0,1
    DC.L    CLOSEWINDOW+MOUSEBUTTONS
    DC.L    WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+SMART_REFRESH+ACTIVATE+RMBTRAP
    DC.L    0,0
    DC.L    .title
    DC.L    0,0
    DC.W    150,50,640,256,WBENCHSCREEN

.title:
    DC.B    'StructHelp zzZ',0
    EVEN




WinText	dc.b	2,0,RP_JAM2,0
	dc.w	6,30
	dc.l	0
L1ptr	dc.l	0
	dc.l	0

TOPAZ60:
	dc.l	.name
	dc.w	TOPAZ_SIXTY
	dc.b	0,0
.name
	dc.b	'topaz.font',0
	even


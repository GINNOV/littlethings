

LabelWin
		dc.w		92,20
		dc.w		416,169
		dc.b		0,1
		dc.l		GADGETUP+CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+RMBTRAP+NOCAREREFRESH
		dc.l		0
		dc.l		0
		dc.l		.Name
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

.Name		dc.b		'Amiganuts Label Printer © M.Meany, 1992.',0
		even

LoadGadg	dc.l		PrintGadg
		dc.w		321,62
		dc.w		67,12
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		LoadIff

PrintGadg	dc.l		StopGadg
		dc.w		321,78
		dc.w		67,12
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		PrintLabels

StopGadg	dc.l		ShiftRGadg
		dc.w		321,94
		dc.w		67,12
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		5
		dc.l		0

ShiftRGadg	dc.l		ShiftLGadg
		dc.w		321,110
		dc.w		67,12
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

ShiftLGadg	dc.l		QuitGadg
		dc.w		321,126
		dc.w		67,12
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

QuitGadg	dc.l		WidthGadg
		dc.w		321,142
		dc.w		67,12
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		Quit

WidthGadg	dc.l		HeightGadg
		dc.w		122,19
		dc.w		48,10
		dc.w		0
		dc.w		RELVERIFY+LONGINT
		dc.w		STRGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		.SInfo
		dc.w		0
		dc.l		0

.SInfo		dc.l		WidthBuff
		dc.l		0
		dc.w		0
		dc.w		5
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
LabWidth	dc.l		0
		dc.l		0

WidthBuff	ds.b		5
		even

HeightGadg	dc.l		CopiesGadg
		dc.w		122,33
		dc.w		48,10
		dc.w		0
		dc.w		RELVERIFY+LONGINT
		dc.w		STRGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		.SInfo
		dc.w		0
		dc.l		0

.SInfo		dc.l		HeightBuff
		dc.l		0
		dc.w		0
		dc.w		5
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
LabHeight	dc.l		0
		dc.l		0

HeightBuff	ds.b		5
		even

CopiesGadg	dc.l		0
		dc.w		122,47
		dc.w		48,10
		dc.w		0
		dc.w		RELVERIFY+LONGINT
		dc.w		STRGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		.SInfo
		dc.w		0
		dc.l		0

.SInfo		dc.l		CopiesBuff
		dc.l		0
		dc.w		0
		dc.w		4
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
NumCopies	dc.l		0
		dc.l		0

CopiesBuff	ds.b		4
		even

WindowGfx	dc.w		6,12
		dc.w		400,150
		dc.w		2
		dc.l		WindowIm
		dc.b		$0003,$0000
		dc.l		0

LabelImage	dc.w		110,63
		dc.w		200,90
		dc.w		2
		dc.l		0
		dc.b		$0003,$0000
		dc.l		0

ProgressText	dc.b		1,0,RP_JAM2,0
		dc.w		0,0
		dc.l		0
		dc.l		ProgBuff
		dc.l		0

ProgBuff	dc.b		'                    ',0
		even

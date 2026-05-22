

LabelWin
		dc.w		0,0
		dc.w		640,256
		dc.b		0,1
		dc.l		GADGETUP+CLOSEWINDOW
		dc.l		ACTIVATE+RMBTRAP+BORDERLESS+NOCAREREFRESH
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

LoadGadg	dc.l		PrintGadg
		dc.w		415,4
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
		dc.w		502,4
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

StopGadg	dc.l		QuitGadg
		dc.w		502,20
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

QuitGadg	dc.l		WidthGadg
		dc.w		415,20
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
		dc.w		120,7
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
		dc.w		120,21
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
		dc.w		120,35
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

WindowGfx	dc.w		0,0
		dc.w		640,256
		dc.w		2
		dc.l		WindowIm
		dc.b		$0003,$0000
		dc.l		0

LabelImage	dc.w		0,0
		dc.w		0,0
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

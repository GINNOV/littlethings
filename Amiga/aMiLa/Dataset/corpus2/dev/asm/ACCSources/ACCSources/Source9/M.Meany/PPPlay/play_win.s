;--------------------------------------
;-------------- Main Window
;--------------------------------------


window		dc.w		138,60
		dc.w		341,51
		dc.b		1,2
		dc.l		GADGETUP+CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE
		dc.l		LoadGadg
		dc.l		0
		dc.l		WindowName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN
WindowName
		dc.b		'PP Play © M.Meany FEB 91',0
		even

LoadGadg	dc.l		SaveGadg
		dc.w		16,34
		dc.w		67,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		Load

.Border		dc.w		-2,-1
		dc.b		3,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0

.Vectors	dc.w		0,0
		dc.w		70,0
		dc.w		70,12
		dc.w		0,12
		dc.w		0,0

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		17,2
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'LOAD',0
		even

SaveGadg	dc.l		PlayGadg
		dc.w		97,34
		dc.w		67,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		Save

.Border		dc.w		-2,-1
		dc.b		3,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0

.Vectors	dc.w		0,0
		dc.w		70,0
		dc.w		70,12
		dc.w		0,12
		dc.w		0,0

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		17,2
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'SAVE',0
		even


PlayGadg	dc.l		AboutGadg
		dc.w		178,34
		dc.w		67,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		Play

.Border		dc.w		-2,-1
		dc.b		3,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0

.Vectors	dc.w		0,0
		dc.w		70,0
		dc.w		70,12
		dc.w		0,12
		dc.w		0,0

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		17,2
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'PLAY',0
		even

AboutGadg	dc.l		0
		dc.w		258,34
		dc.w		67,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		About

.Border		dc.w		-2,-1
		dc.b		3,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0

.Vectors	dc.w		0,0
		dc.w		70,0
		dc.w		70,12
		dc.w		0,12
		dc.w		0,0

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		14,2
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'ABOUT',0
		even

StopGadg	dc.l		0
		dc.w		178,34
		dc.w		67,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		Stop

.Border		dc.w		-2,-1
		dc.b		3,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0

.Vectors	dc.w		0,0
		dc.w		70,0
		dc.w		70,12
		dc.w		0,12
		dc.w		0,0

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		17,2
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'STOP',0
		even



window_text	dc.b		2,0,RP_JAM2,0
		dc.w		65,12
		dc.l		0
		dc.l		.String
		dc.l		.Line2

.String		dc.b		'NoiseTracker Replayer !!!!',0
		even

.Line2		dc.b		2,0,RP_JAM2,0
		dc.w		65,22
		dc.l		0
		dc.l		.String2
		dc.l		0

.String2	dc.b		'Plays PowerPacked modules.',0
		even

;--------------------------------------
;-------------- About Window
;--------------------------------------


about_win	dc.w		160,50
		dc.w		370,83
		dc.b		3,2
		dc.l		GADGETUP
		dc.l		ACTIVATE
		dc.l		OKGadg1
		dc.l		0
		dc.l		AboutName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,256
		dc.w		WBENCHSCREEN

AboutName	dc.b		'     Coded by Mark Meany   Feb 91',0
		even

OKGadg1		dc.l		OKGadg2
		dc.w		32,54
		dc.w		76,22
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

.Border		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0

.Vectors	dc.w		0,0
		dc.w		79,0
		dc.w		79,23
		dc.w		0,23
		dc.w		0,0

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		17,7
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'OK !!',0
		even

OKGadg2		dc.l		0
		dc.w		265,54
		dc.w		76,22
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

.Border		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0

.Vectors	dc.w		0,0
		dc.w		79,0
		dc.w		79,23
		dc.w		0,23
		dc.w		0,0

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		17,7
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'OK !!',0
		even


AboutText	dc.b		1,0,RP_JAM2,0
		dc.w		20,13
		dc.l		0
		dc.l		.String1
		dc.l		.line2

.String1	dc.b		'ARP Library         : Various Authors',0
		even

.line2		dc.b		1,0,RP_JAM2,0
		dc.w		20,23
		dc.l		0
		dc.l		.String2
		dc.l		.line3

.String2	dc.b		'Interrupt Routine   : Steve Marshall',0
		even

.line3		dc.b		1,0,RP_JAM2,0
		dc.w		20,33
		dc.l		0
		dc.l		.String3
		dc.l		.line4

.String3	dc.b		'PowerPacker Library : Nico Francois',0
		even

.line4		dc.b		1,0,RP_JAM2,0
		dc.w		20,43
		dc.l		0
		dc.l		.String4
		dc.l		0

.String4	dc.b		'Noisetracker Replay : Mahoney & Kaktus',0
		even


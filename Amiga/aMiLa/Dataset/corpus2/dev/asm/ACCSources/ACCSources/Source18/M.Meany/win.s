
; Window data def's for IFF2INT utility.

; © M.Meany, July 1991.


MyWindow
	dc.w	85,30
	dc.w	500,199
	dc.b	3,2
	dc.l	GADGETDOWN+GADGETUP+CLOSEWINDOW
	dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
	dc.l	LoadGadg
	dc.l	0
	dc.l	MyWindowName
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN

MyWindowName
	dc.b	' IFF2INT  © M.Meany, July 91 ',0
	even

LoadGadg
	dc.l	SaveGadg
	dc.w	14,108
	dc.w	96,21
	dc.w	GADGIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Image
	dc.l	0
	dc.l	.Text
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	Load
.Image
	dc.w	0,0
	dc.w	96,21
	dc.w	2
	dc.l	ImageData1
	dc.b	$0003,$0000
	dc.l	0
.Text
	dc.b	2,1,RP_JAM2,0
	dc.w	16,7
	dc.l	0
	dc.l	.String
	dc.l	0
.String
	dc.b	'LOAD IFF',0
	even

SaveGadg
	dc.l	ViewGagd
	dc.w	14,132
	dc.w	96,21
	dc.w	GADGIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Image
	dc.l	0
	dc.l	.Text
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	Save

.Image
	dc.w	0,0
	dc.w	96,21
	dc.w	2
	dc.l	ImageData1
	dc.b	$0003,$0000
	dc.l	0

.Text
	dc.b	2,1,RP_JAM2,0
	dc.w	30,7
	dc.l	0
	dc.l	.String
	dc.l	0
.String
	dc.b	'SAVE',0
	even

ViewGagd
	dc.l	QuitGadg
	dc.w	15,156
	dc.w	96,21
	dc.w	GADGIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Image
	dc.l	0
	dc.l	.Text
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	ShowPic
.Image
	dc.w	0,0
	dc.w	96,21
	dc.w	2
	dc.l	ImageData1
	dc.b	$0003,$0000
	dc.l	0
.Text
	dc.b	2,1,RP_JAM2,0
	dc.w	30,7
	dc.l	0
	dc.l	.String
	dc.l	0
.String
	dc.b	'VIEW',0
	even

QuitGadg
	dc.l	AsImageGadg
	dc.w	166,174
	dc.w	96,21
	dc.w	GADGIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Image
	dc.l	0
	dc.l	.Text
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	Quit
.Image
	dc.w	0,0
	dc.w	96,21
	dc.w	2
	dc.l	ImageData1
	dc.b	$0003,$0000
	dc.l	0
.Text
	dc.b	2,1,RP_JAM2,0
	dc.w	28,7
	dc.l	0
	dc.l	.String
	dc.l	0
.String
	dc.b	'QUIT',0
	even

AsImageGadg
	dc.l	AsGadgGadg
	dc.w	165,132
	dc.w	96,21
	dc.w	GADGIMAGE+SELECTED
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	.Image
	dc.l	0
	dc.l	.Text
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	AsImage
.Image
	dc.w	0,0
	dc.w	96,21
	dc.w	2
	dc.l	ImageData1
	dc.b	$0003,$0000
	dc.l	0
.Text
	dc.b	2,1,RP_JAM2,0
	dc.w	27,7
	dc.l	0
	dc.l	.String
	dc.l	0
.String
	dc.b	'IMAGE',0
	even

AsGadgGadg
	dc.l	AsRawGadg
	dc.w	268,132
	dc.w	96,21
	dc.w	GADGIMAGE
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	.Image
	dc.l	0
	dc.l	.Text
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	AsGadg
.Image
	dc.w	0,0
	dc.w	96,21
	dc.w	2
	dc.l	ImageData1
	dc.b	$0003,$0000
	dc.l	0
.Text
	dc.b	2,1,RP_JAM2,0
	dc.w	24,7
	dc.l	0
	dc.l	.String
	dc.l	0
.String
	dc.b	'GADGET',0
	even

AsRawGadg
	dc.l	0
	dc.w	371,132
	dc.w	96,21
	dc.w	GADGIMAGE
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	.Image
	dc.l	0
	dc.l	.Text
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	AsRaw
.Image
	dc.w	0,0
	dc.w	96,21
	dc.w	2
	dc.l	ImageData1
	dc.b	$0003,$0000
	dc.l	0
.Text
	dc.b	2,1,RP_JAM2,0
	dc.w	33,7
	dc.l	0
	dc.l	.String
	dc.l	0
.String
	dc.b	'RAW',0
	even

WinText
	dc.b	1,0,RP_JAM2,0
	dc.w	15,15
	dc.l	0
	dc.l	.String1
	dc.l	.Text2
.String1
	dc.b	'Number Of Planes :',0
	even

.Text2
	dc.b	1,0,RP_JAM2,0
	dc.w	15,25
	dc.l	0
	dc.l	.String2
	dc.l	.Text3
.String2
	dc.b	'Width            :',0
	even

.Text3
	dc.b	1,0,RP_JAM2,0
	dc.w	15,35
	dc.l	0
	dc.l	.String3
	dc.l	.Text4
.String3
	dc.b	'Height           :',0
	even

.Text4
	dc.b	1,0,RP_JAM2,0
	dc.w	100,60
	dc.l	0
	dc.l	.String4
	dc.l	.Text5
.String4
	dc.b	'Programmed By  :  M.Meany',0
	even

.Text5
	dc.b	1,0,RP_JAM2,0
	dc.w	100,70
	dc.l	0
	dc.l	.String5
	dc.l	.Text6
.String5
	dc.b	'ILBM Code By   :  S.Marshall',0
	even

.Text6
	dc.b	1,0,RP_JAM2,0
	dc.w	100,80
	dc.l	0
	dc.l	.String6
	dc.l	.Text7
.String6
	dc.b	'ARP Library By :  S.Ballantyne & C.Heath',0
	even

.Text7
	dc.b	1,0,RP_JAM2,0
	dc.w	169,114
	dc.l	0
	dc.l	.String7
	dc.l	.Text8
.String7
	dc.b	'STATUS :',0
	even

.Text8
	dc.b	1,0,RP_JAM2,0
	dc.w	118,140
	dc.l	0
	dc.l	.String8
	dc.l	0
.String8
	dc.b	'AS-->',0
	even

StatusText
	dc.b	1,0,RP_JAM2,0
	dc.w	249,114
	dc.l	0
StatusPtr
	dc.l	.String
	dc.l	0
.String
	dc.b	'No File Loaded!',0
	even


NumText
	dc.b	1,0,RP_JAM2,0
	dc.w	175
y_off
	dc.w	15
	dc.l	0
	dc.l	NumPtr
	dc.l	0
NumPtr
	dc.b	'    0',0
	even



ImWindow
		dc.w		132,92
		dc.w		400,90
		dc.b		0,1
		dc.l		GADGETUP
		dc.l		NOCAREREFRESH
		dc.l		.Gadget1
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN


.Gadget1	dc.l		.Gadget2	** CANCEL GADGET **
		dc.w		31,65
		dc.w		100,13
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		IMCancel

.Border		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0

.Vectors		dc.w		0,0
		dc.w		103,0
		dc.w		103,14
		dc.w		0,14
		dc.w		0,0

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		25,3
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'CANCEL',0
		even

.Gadget2	dc.l		.Gadget3	** DO IT! GADGET **
		dc.w		262,64
		dc.w		100,13
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border2
		dc.l		0
		dc.l		.Text2
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		DoSaveI

.Border2	dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors2
		dc.l		0

.Vectors2	dc.w		0,0
		dc.w		103,0
		dc.w		103,14
		dc.w		0,14
		dc.w		0,0

.Text2		dc.b		1,0,RP_JAM2,0
		dc.w		27,3
		dc.l		0
		dc.l		.String2
		dc.l		0

.String2	dc.b		'DO IT!',0
		even

.Gadget3	dc.l		.Gadget4	** FILENAME GADGET **
		dc.w		140,20
		dc.w		244,10
		dc.w		SELECTED
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		.SInfo3
		dc.w		0
		dc.l		DoNothing

.SInfo3		dc.l		SaveName
		dc.l		0
		dc.w		0
		dc.w		50
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

.Gadget4	dc.l		0		** LABEL GADGET **
		dc.w		140,34
		dc.w		244,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		.SInfo4
		dc.w		0
		dc.l		DoNothing

.SInfo4		dc.l		SourceLabel
		dc.l		0
		dc.w		0
		dc.w		50
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0


GgWindow
		dc.w		132,92
		dc.w		400,90
		dc.b		0,1
		dc.l		GADGETUP
		dc.l		NOCAREREFRESH
		dc.l		.Gadget1
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN


.Gadget1	dc.l		.Gadget2	** CANCEL GADGET **
		dc.w		31,65
		dc.w		100,13
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.Text
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		IMCancel

.Border		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0

.Vectors		dc.w		0,0
		dc.w		103,0
		dc.w		103,14
		dc.w		0,14
		dc.w		0,0

.Text		dc.b		1,0,RP_JAM2,0
		dc.w		25,3
		dc.l		0
		dc.l		.String
		dc.l		0

.String		dc.b		'CANCEL',0
		even

.Gadget2	dc.l		.Gadget3	** DO IT! GADGET **
		dc.w		262,64
		dc.w		100,13
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border2
		dc.l		0
		dc.l		.Text2
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		DoSaveI

.Border2	dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors2
		dc.l		0

.Vectors2	dc.w		0,0
		dc.w		103,0
		dc.w		103,14
		dc.w		0,14
		dc.w		0,0

.Text2		dc.b		1,0,RP_JAM2,0
		dc.w		27,3
		dc.l		0
		dc.l		.String2
		dc.l		0

.String2	dc.b		'DO IT!',0
		even

.Gadget3	dc.l		.Gadget4	** FILENAME GADGET **
		dc.w		140,20
		dc.w		244,10
		dc.w		SELECTED
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		.SInfo3
		dc.w		0
		dc.l		DoNothing

.SInfo3		dc.l		SaveName
		dc.l		0
		dc.w		0
		dc.w		50
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

.Gadget4	dc.l		0		** LABEL GADGET **
		dc.w		140,34
		dc.w		244,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		.SInfo4
		dc.w		0
		dc.l		DoNothing

.SInfo4		dc.l		SourceLabel
		dc.l		0
		dc.w		0
		dc.w		50
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0


Title1		dc.b		1,0,RP_JAM2,0
		dc.w		45,5
		dc.l		0
		dc.l		.String
		dc.l		StructText

.String		dc.b		'* Generate Intuition Image Structure *',0
		even

Title2		dc.b		1,0,RP_JAM2,0
		dc.w		45,5
		dc.l		0
		dc.l		.String
		dc.l		StructText

.String		dc.b		'* Generate Intuition Image Structure *',0
		even

StructText	dc.b		1,0,RP_JAM2,0
		dc.w		10,20
		dc.l		0
		dc.l		.String
		dc.l		.Text2

.String		dc.b		'Filename      :',0
		even

.Text2		dc.b		1,0,RP_JAM2,0
		dc.w		10,35
		dc.l		0
		dc.l		.String2
		dc.l		0

.String2	dc.b		'Source  Label :',0
		even




	section   gfx,data_c

ImageData1
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$1FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFF0,$67FF,$FFFF,$FFFF,$FFFF,$FFFF,$FFCC
	dc.w	$79FF,$FFFF,$FFFF,$FFFF,$FFFF,$FF3C,$7E00,$0000
	dc.w	$0000,$0000,$0000,$00FC,$7F7F,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FDFC,$7F7F,$FFFF,$FFFF,$FFFF,$FFFF,$FDFC
	dc.w	$7F7F,$FFFF,$FFFF,$FFFF,$FFFF,$FDFC,$7F7F,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FDFC,$7F7F,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FDFC,$7F7F,$FFFF,$FFFF,$FFFF,$FFFF,$FDFC
	dc.w	$7F7F,$FFFF,$FFFF,$FFFF,$FFFF,$FDFC,$7F7F,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FDFC,$7F7F,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FDFC,$7E00,$0000,$0000,$0000,$0000,$00FC
	dc.w	$79FF,$FFFF,$FFFF,$FFFF,$FFFF,$FF3C,$67FF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFCC,$1FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFF0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFE,$E000,$0000,$0000,$0000,$0000,$000E
	dc.w	$9800,$0000,$0000,$0000,$0000,$0032,$8600,$0000
	dc.w	$0000,$0000,$0000,$00C2,$81FF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FF02,$8080,$0000,$0000,$0000,$0000,$0202
	dc.w	$8080,$0000,$0000,$0000,$0000,$0202,$8080,$0000
	dc.w	$0000,$0000,$0000,$0202,$8080,$0000,$0000,$0000
	dc.w	$0000,$0202,$8080,$0000,$0000,$0000,$0000,$0202
	dc.w	$8080,$0000,$0000,$0000,$0000,$0202,$8080,$0000
	dc.w	$0000,$0000,$0000,$0202,$8080,$0000,$0000,$0000
	dc.w	$0000,$0202,$8080,$0000,$0000,$0000,$0000,$0202
	dc.w	$81FF,$FFFF,$FFFF,$FFFF,$FFFF,$FF02,$8600,$0000
	dc.w	$0000,$0000,$0000,$00C2,$9800,$0000,$0000,$0000
	dc.w	$0000,$0032,$E000,$0000,$0000,$0000,$0000,$000E
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000


newptr
	dc.w		$0000,$0000

	dc.w		$0000,$7ffe
	dc.w		$3ffc,$4002
	dc.w		$3ffc,$5ff6
	dc.w		$0018,$7fee
	dc.w		$0030,$7fde
	dc.w		$0060,$7fbe
	dc.w		$00c0,$7f7e
	dc.w		$0180,$7efe
	dc.w		$0300,$7dfe
	dc.w		$0600,$7bfe
	dc.w		$0c00,$77fe
	dc.w		$1ffc,$6ffa
	dc.w		$3ffc,$4002
	dc.w		$0000,$7ffe
	dc.w		$0000,$0000
	dc.w		$0000,$0000

	dc.w		$0000,$0000


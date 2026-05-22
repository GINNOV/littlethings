
***************	IText structures for OK requester

OKReqBody	dc.b		1,0,RP_JAM2,0
		dc.w		30,25		x,y
		dc.l		0,0,0

OKReqButton	dc.b		1,0,RP_JAM2,0
		dc.w		5,4		x,y
		dc.l		0,.BText,0
.BText		dc.b		'Ok',0
		even

***************	IText structures for True/False requester

TFReqBody	dc.b		1,0,RP_JAM2,0
		dc.w		30,25		x,y
		dc.l		0,0,0

TFTrue		dc.b		1,0,RP_JAM2,0
		dc.w		5,4		x,y
		dc.l		0,.BText,0
.BText		dc.b		'Cancel',0
		even

TFFalse		dc.b		1,0,RP_JAM2,0
		dc.w		5,4		x,y
		dc.l		0,.BText,0
.BText		dc.b		'Ok',0
		even

***************	General purpose IText structure

WinText		dc.b		1		FrontPen
		dc.b		0		BackPen
		dc.b		RP_JAM2		DrawMode
		dc.b		0		KludgeFill00
		dc.w		0		x position
		dc.w		0		y position
		dc.l		0		font
OurText		dc.l		.Text		address of text to print
		dc.l		0		no more text

.Text		dc.b		'',0		the text itself
		even

*****************************************************************************
*		      Main Window & Menu Equates			    *
*****************************************************************************

MainWindow	dc.w		0,10
		dc.w		640,190
		dc.b		0,1
		dc.l		MENUPICK+CLOSEWINDOW+RAWKEY
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
		dc.l		0
		dc.l		0
		dc.l		MWName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

MWName		dc.b		' HAM Log, © M.Meany 1993.       '
		dc.b		'of 00000 Operators, 00000 Log Entries',0
		even

MWTemplate	dc.b		' HAM Log, © M.Meany 1993.  '
		dc.b		'%d of %05d Operators, %05d Log Entries',0
		even


MainMenu	dc.l		Menu2
		dc.w		0,0
		dc.w		75,0
		dc.w		MENUENABLED
		dc.l		Menu1Name
		dc.l		MenuItem1
		dc.w		0,0,0,0

Menu1Name	dc.b		'Project',0
		even

MenuItem1	dc.l		MenuItem2
		dc.w		0,0
		dc.w		64,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'About  A',0
		even

MenuItem2	dc.l		0
		dc.w		0,9
		dc.w		64,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Quit   Q',0
		even

Menu2		dc.l		Menu3
		dc.w		82,0
		dc.w		84,0
		dc.w		MENUENABLED
		dc.l		Menu2Name
		dc.l		MenuItem3
		dc.w		0,0,0,0

Menu2Name	dc.b		'Log Book',0
		even

MenuItem3	dc.l		MenuItem4
		dc.w		0,0
		dc.w		152,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Show Log           F1',0
		even

MenuItem4	dc.l		MenuItem5
		dc.w		0,9
		dc.w		152,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Add Log Entry      F2',0
		even

MenuItem5	dc.l		MenuItem6
		dc.w		0,18
		dc.w		152,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Delete Last Entry sF2',0
		even

MenuItem6	dc.l		MenuItem7
		dc.w		0,27
		dc.w		152,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Print Log Window   F3',0
		even

MenuItem7	dc.l		MenuItem8
		dc.w		0,36
		dc.w		152,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Print # Entries    F4',0
		even

MenuItem8	dc.l		0
		dc.w		0,45
		dc.w		152,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Print From ddmmyy  F5',0
		even

Menu3		dc.l		Menu4
		dc.w		173,0
		dc.w		84,0
		dc.w		MENUENABLED
		dc.l		Menu3Name
		dc.l		MenuItem9
		dc.w		0,0,0,0

Menu3Name	dc.b		'Operator',0
		even

MenuItem9	dc.l		MenuItem10
		dc.w		0,0
		dc.w		160,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Show Operator       F6',0
		even

MenuItem10	dc.l		MenuItem11
		dc.w		0,9
		dc.w		160,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Add New Operator    F7',0
		even

MenuItem11	dc.l		MenuItem12
		dc.w		0,18
		dc.w		160,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Edit Operator      sF7',0
		even

MenuItem12	dc.l		MenuItem13
		dc.w		0,27
		dc.w		160,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Find Operator      F10',0
		even

MenuItem13	dc.l		MenuItem14
		dc.w		0,36
		dc.w		160,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Print Op. Details   F9',0
		even

MenuItem14	dc.l		MenuItem15
		dc.w		0,45
		dc.w		160,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Print Op. Log       F8',0
		even

MenuItem15	dc.l		MenuItem16
		dc.w		0,54
		dc.w		160,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Print Addr. Label  sF9',0
		even

MenuItem16	dc.l		0
		dc.w		0,63
		dc.w		160,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Print Confirmation sF8',0
		even

Menu4		dc.l		0
		dc.w		264,0
		dc.w		111,0
		dc.w		MENUENABLED
		dc.l		Menu4Name
		dc.l		MenuItem17
		dc.w		0,0,0,0

Menu4Name	dc.b		'Progressive',0
		even

MenuItem17	dc.l		MenuItem18
		dc.w		0,0
		dc.w		120,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Set Dates     sF3',0
		even

MenuItem18	dc.l		MenuItem19
		dc.w		0,9
		dc.w		120,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Show Log      sF4',0
		even

MenuItem19	dc.l		0
		dc.w		0,18
		dc.w		120,8
		dc.w		ITEMTEXT+ITEMENABLED+HIGHCOMP
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.b		0
		dc.b		0
		dc.l		0
		dc.w		MENUNULL

.IText		dc.b		3,1,RP_COMPLEMENT,0
		dc.w		0,0
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Print Log     sF5',0
		even



*****************************************************************************
*		    Operator Window & Gadget Equates			    *
*****************************************************************************

AddOpWindow	dc.w		0,0
		dc.w		640,172
		dc.b		0,1
		dc.l		GADGETUP+CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWCLOSE+ACTIVATE+RMBTRAP+NOCAREREFRESH
		dc.l		QRZGadg
		dc.l		0
		dc.l		.Name
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,230
		dc.w		WBENCHSCREEN

.Name		dc.b		'Add/Modify Operator',0
		even


QRZGadg		dc.l		OpGadg
		dc.w		116,16
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		IText1
		dc.l		0
		dc.l		QRZGadgSInfo
		dc.w		0
		dc.l		DoQRZGadg

QRZGadgSInfo	dc.l		QRZGadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		21
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

IText1		dc.b		1,0,RP_JAM2,0
		dc.w		-105,1
		dc.l		0
		dc.l		ITextText1
		dc.l		0

ITextText1	dc.b		'Q.R.Z.',0
		even

OpGadg		dc.l		QTHGadg
		dc.w		116,30
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		IText2
		dc.l		0
		dc.l		OpGadgSInfo
		dc.w		0
		dc.l		DoOpGadg

OpGadgSInfo	dc.l		OpGadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		21
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

IText2		dc.b		1,0,RP_JAM2,0
		dc.w		-105,1
		dc.l		0
		dc.l		ITextText2
		dc.l		0

ITextText2	dc.b		'Operator',0
		even

QTHGadg		dc.l		LocGadg
		dc.w		116,44
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		IText3
		dc.l		0
		dc.l		QTHGadgSInfo
		dc.w		0
		dc.l		DoQTHGadg

QTHGadgSInfo	dc.l		QTHGadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		31
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

IText3		dc.b		1,0,RP_JAM2,0
		dc.w		-105,1
		dc.l		0
		dc.l		ITextText3
		dc.l		0

ITextText3	dc.b		'Q.T.H.',0
		even

LocGadg		dc.l		ConGadg
		dc.w		116,58
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		IText4
		dc.l		0
		dc.l		LocGadgSInfo
		dc.w		0
		dc.l		DoLocGadg

LocGadgSInfo	dc.l		LocGadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		7
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

IText4		dc.b		1,0,RP_JAM2,0
		dc.w		-105,1
		dc.l		0
		dc.l		ITextText4
		dc.l		0

ITextText4	dc.b		'Locator',0
		even

ConGadg		dc.l		Addr1Gadg
		dc.w		116,72
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		IText5
		dc.l		0
		dc.l		ConGadgSInfo
		dc.w		0
		dc.l		DoConGadg

ConGadgSInfo	dc.l		ConGadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		11
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

IText5		dc.b		1,0,RP_JAM2,0
		dc.w		-105,1
		dc.l		0
		dc.l		ITextText5
		dc.l		0

ITextText5	dc.b		'Contribution',0
		even

Addr1Gadg	dc.l		Addr2Gadg
		dc.w		445,16
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		IText6
		dc.l		0
		dc.l		Addr1GadgSInfo
		dc.w		0
		dc.l		DoAddr1Gadg

Addr1GadgSInfo	dc.l		Addr1GadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		26
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

IText6		dc.b		1,0,RP_JAM2,0
		dc.w		-105,1
		dc.l		0
		dc.l		ITextText6
		dc.l		0

ITextText6	dc.b		'Address',0
		even

Addr2Gadg	dc.l		Addr3Gadg
		dc.w		445,28
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		Addr2GadgSInfo
		dc.w		0
		dc.l		DoAddr2Gadg

Addr2GadgSInfo	dc.l		Addr2GadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		26
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

Addr3Gadg	dc.l		Addr4Gadg
		dc.w		445,40
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		Addr3GadgSInfo
		dc.w		0
		dc.l		DoAddr3Gadg

Addr3GadgSInfo	dc.l		Addr3GadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		26
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

Addr4Gadg	dc.l		Addr5Gadg
		dc.w		445,52
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		Addr4GadgSInfo
		dc.w		0
		dc.l		DoAddr4Gadg

Addr4GadgSInfo	dc.l		Addr4GadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		26
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

Addr5Gadg	dc.l		Addr6Gadg
		dc.w		445,64
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		Addr5GadgSInfo
		dc.w		0
		dc.l		DoAddr5Gadg

Addr5GadgSInfo	dc.l		Addr5GadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		26
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

Addr6Gadg	dc.l		PhonGadg
		dc.w		445,76
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		Addr6GadgSInfo
		dc.w		0
		dc.l		DoAddr6Gadg

Addr6GadgSInfo	dc.l		Addr6GadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		26
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

PhonGadg	dc.l		FaxGadg
		dc.w		445,95
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		IText7
		dc.l		0
		dc.l		PhonGadgSInfo
		dc.w		0
		dc.l		DoPhonGadg

PhonGadgSInfo	dc.l		PhonGadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		21
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

IText7		dc.b		1,0,RP_JAM2,0
		dc.w		-105,1
		dc.l		0
		dc.l		ITextText7
		dc.l		0

ITextText7	dc.b		'Phone',0
		even

FaxGadg		dc.l		BurGadg
		dc.w		445,107
		dc.w		176,9
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		AddOpBorder
		dc.l		0
		dc.l		IText8
		dc.l		0
		dc.l		FaxGadgSInfo
		dc.w		0
		dc.l		DoFaxGadg

FaxGadgSInfo	dc.l		FaxGadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		21
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

IText8		dc.b		1,0,RP_JAM2,0
		dc.w		-105,1
		dc.l		0
		dc.l		ITextText8
		dc.l		0

ITextText8	dc.b		'Fax',0
		even

BurGadg		dc.l		OkGadg
		dc.w		445,120
		dc.w		73,9
		dc.w		GADGHNONE
		dc.w		RELVERIFY+TOGGLESELECT
		dc.w		BOOLGADGET
		dc.l		AddOpBorder1
		dc.l		0
		dc.l		IText9
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		DoBurGadg

IText9		dc.b		1,0,RP_JAM2,0
		dc.w		-105,1
		dc.l		0
		dc.l		ITextText9
		dc.l		0

ITextText9	dc.b		'Bureau',0
		even

OkGadg		dc.l		CanGadg
		dc.w		515,149
		dc.w		71,13
		dc.w		GADGHIMAGE
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		AddOpBorder2
		dc.l		AddOpInvBorder2
		dc.l		IText10
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		DoOkGadg

IText10		dc.b		1,0,RP_JAM2,0
		dc.w		26,3
		dc.l		0
		dc.l		ITextText10
		dc.l		0

ITextText10	dc.b		'Ok',0
		even

CanGadg		dc.l		0
		dc.w		50,148
		dc.w		71,13
		dc.w		GADGHIMAGE
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		AddOpBorder2
		dc.l		AddOpInvBorder2
		dc.l		IText11
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		DoCanGadg

IText11		dc.b		1,0,RP_JAM2,0
		dc.w		11,3
		dc.l		0
		dc.l		ITextText11
		dc.l		0

ITextText11	dc.b		'Cancel',0
		even

AddOpBorder	dc.w		-2,-2
		dc.b		1,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors
		dc.l		.Border

.Vectors	dc.w		0,11
		dc.w		0,0
		dc.w		179,0

.Border		dc.w		-2,-2
		dc.b		2,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors1
		dc.l		0

.Vectors1	dc.w		179,1
		dc.w		179,11
		dc.w		1,11
		
AddOpBorder1	dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors
		dc.l		.Border

.Vectors	dc.w		0,10
		dc.w		0,0
		dc.w		76,0
		
.Border		dc.w		-2,-1
		dc.b		1,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors1
		dc.l		0

.Vectors1	dc.w		76,1
		dc.w		76,10
		dc.w		1,10

AddOpBorder2	dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors
		dc.l		.Border

.Vectors	dc.w		0,14
		dc.w		0,0
		dc.w		74,0
		
.Border		dc.w		-2,-1
		dc.b		1,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors1
		dc.l		0

.Vectors1	dc.w		74,1
		dc.w		74,14
		dc.w		1,14

AddOpInvBorder2	dc.w		-2,-1
		dc.b		1,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors
		dc.l		.Border

.Vectors	dc.w		0,14
		dc.w		0,0
		dc.w		74,0
		
.Border		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors1
		dc.l		0

.Vectors1	dc.w		74,1
		dc.w		74,14
		dc.w		1,14

***************	Text for Operator window

OpWinText	dc.b		3,0,RP_JAM2,0
		dc.w		216,15
		dc.l		0
		dc.l		.Text1
		dc.l		.IText2

.Text1		dc.b		'Operator Details',0
		even

.IText2		dc.b		2,0,RP_JAM2,0
		dc.w		10,30
		dc.l		0
		dc.l		.Text2
		dc.l		.IText3

.Text2		dc.b		'Q.R.Z.',0
		even

.IText3		dc.b		2,0,RP_JAM2,0
		dc.w		10,38
		dc.l		0
		dc.l		.Text3
		dc.l		.IText4

.Text3		dc.b		'Operator',0
		even

.IText4		dc.b		2,0,RP_JAM2,0
		dc.w		10,46
		dc.l		0
		dc.l		.Text4
		dc.l		.IText5

.Text4		dc.b		'Q.T.H.',0
		even

.IText5		dc.b		2,0,RP_JAM2,0
		dc.w		10,54
		dc.l		0
		dc.l		.Text5
		dc.l		.IText6

.Text5		dc.b		'Locator',0
		even

.IText6		dc.b		2,0,RP_JAM2,0
		dc.w		10,62
		dc.l		0
		dc.l		.Text6
		dc.l		.IText7

.Text6		dc.b		'Contribution',0
		even

.IText7		dc.b		2,0,RP_JAM2,0
		dc.w		360,30
		dc.l		0
		dc.l		.Text7
		dc.l		.IText8

.Text7		dc.b		'Address',0
		even

.IText8		dc.b		2,0,RP_JAM2,0
		dc.w		360,80
		dc.l		0
		dc.l		.Text8
		dc.l		.IText9

.Text8		dc.b		'Phone',0
		even

.IText9		dc.b		2,0,RP_JAM2,0
		dc.w		360,88
		dc.l		0
		dc.l		.Text9
		dc.l		.IText10

.Text9		dc.b		'Fax',0
		even

.IText10	dc.b		2,0,RP_JAM2,0
		dc.w		360,96
		dc.l		0
		dc.l		.Text10
		dc.l		.IText11

.Text10		dc.b		'Bureau',0
		even

.IText11	dc.b		3,0,RP_JAM2,0
		dc.w		208,105
		dc.l		0
		dc.l		.Text11
		dc.l		.IText12

.Text11		dc.b		'Communication History',0
		even

.IText12	dc.b		2,0,RP_JAM2,0
		dc.w		7,115
		dc.l		0
		dc.l		.Text12
		dc.l		.IText13

.Text12		dc.b		'Date     Time    Frequency   Mode   Radio   Signal   Tone',0
		even

.IText13	dc.b		3,0,RP_JAM2,0
		dc.w		224,172
		dc.l		0
		dc.l		.Text13
		dc.l		0

.Text13		dc.b		'Notes For dd/mm/yy',0
		even

*****************************************************************************
*		    Password Window & Text Equates			    *
*****************************************************************************

PWWindow	dc.w		167,40
		dc.w		312,95
		dc.b		0,1
		dc.l		VANILLAKEY
		dc.l		WINDOWDRAG+WINDOWDEPTH+ACTIVATE+NOCAREREFRESH
		dc.l		0
		dc.l		0
		dc.l		.Name
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

.Name		dc.b		'   HAM Log Data Protection System',0
		even

PWText		dc.b		2,0,RP_JAM2,0
		dc.w		77,19
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Enter Your Password',0
		even

PWQText		dc.b		1,0,RP_JAM2,0
		dc.w		120,37
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'?',0
		even


FindOpWindow	dc.w		146,57
		dc.w		249,69
		dc.b		0,1
		dc.l		GADGETUP
		dc.l		WINDOWDRAG+WINDOWDEPTH+ACTIVATE+RMBTRAP+NOCAREREFRESH
		dc.l		LOpGadg
		dc.l		0
		dc.l		.Name
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

.Name		dc.b		'    Enter Operators Q.R.Z.',0
		even

LOpGadg		dc.l		0
		dc.w		13,30
		dc.w		223,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		STRGADGET
		dc.l		.Border
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		.SInfo
		dc.w		0
		dc.l		0

.SInfo		dc.l		LOpGadgSIBuff
		dc.l		0
		dc.w		0
		dc.w		21
		dc.w		0
		dc.w		0,0,0,0,0
		dc.l		0
		dc.l		0
		dc.l		0

.Border		dc.w		-2,-2
		dc.b		1,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors
		dc.l		.Border1

.Vectors	dc.w		0,12
		dc.w		0,0
		dc.w		226,0
		
.Border1	dc.w		-2,-2
		dc.b		2,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors1
		dc.l		0

.Vectors1	dc.w		226,1
		dc.w		226,12
		dc.w		1,12

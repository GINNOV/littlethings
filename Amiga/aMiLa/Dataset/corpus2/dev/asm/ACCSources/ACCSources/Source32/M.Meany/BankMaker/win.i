;****** Auto-Revision Header (do not edit) *******************************
;*
;* © Copyright by MMSoftware
;*
;* Filename         : win.i
;* Created on       : 01-Sep-93
;* Created by       : M.Meany
;* Current revision : V0.000
;*
;*
;* Purpose: Include file for BankMaker window.
;*                                                    M.Meany (01-Sep-93)
;*          
;*
;* V0.000 : --- Initial release ---
;*
;*************************************************************************

ShowWindow	dc.w		167,12
		dc.w		300,170
		dc.b		0,1
		dc.l		CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+RMBTRAP+NOCAREREFRESH
		dc.l		0
		dc.l		0
		dc.l		.Name
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN


.Name		dc.b		'Rough Display :-)',0
		even

MyWindow	dc.w		167,12
		dc.w		300,170
		dc.b		0,1
		dc.l		GADGETUP+CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+RMBTRAP+NOCAREREFRESH
		dc.l		LoadBankGadg
		dc.l		0
		dc.l		.Name
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

.Name		dc.b		'Object Bank Maker, © M.Meany.',0
		even


LoadBankGadg	dc.l		SaveBankGadg
		dc.w		14,29
		dc.w		62,9
		dc.w		GADGHIMAGE
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		Border2
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		1
		dc.l		LoadBank


.IText		dc.b		1,0,RP_JAM2,0
		dc.w		13,1
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Load',0
		even

SaveBankGadg	dc.l		ShowImGadg
		dc.w		14,43
		dc.w		62,9
		dc.w		GADGHIMAGE
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		Border2
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		SaveBank


.IText		dc.b		1,0,RP_JAM2,0
		dc.w		14,1
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Save',0
		even

ShowImGadg	dc.l		DelImGadg
		dc.w		15,122
		dc.w		62,9
		dc.w		GADGHIMAGE
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		Border2
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		ShowImage


.IText		dc.b		1,0,RP_JAM2,0
		dc.w		13,1
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Show',0
		even

DelImGadg	dc.l		LoadImGadg
		dc.w		85,122
		dc.w		62,9
		dc.w		GADGHIMAGE!GADGDISABLED
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		Border2
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		DeleteImage


.IText		dc.b		1,0,RP_JAM2,0
		dc.w		8,1
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Delete',0
		even

LoadImGadg	dc.l		EdMaskGadg
		dc.w		155,122
		dc.w		62,9
		dc.w		GADGHIMAGE
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		Border2
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		LoadImage


.IText		dc.b		1,0,RP_JAM2,0
		dc.w		15,1
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Load',0
		even

EdMaskGadg	dc.l		PrevImData
		dc.w		225,122
		dc.w		62,9
		dc.w		GADGHIMAGE!GADGDISABLED
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		Border2
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		EditMask


.IText		dc.b		1,0,RP_JAM2,0
		dc.w		15,1
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Mask',0
		even

PrevImData	dc.l		NextImGadg
		dc.w		15,134
		dc.w		62,9
		dc.w		GADGHIMAGE
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		Border2
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		PrevImage


.IText		dc.b		1,0,RP_JAM2,0
		dc.w		13,1
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Prev',0
		even

NextImGadg	dc.l		AboutGadg
		dc.w		85,134
		dc.w		62,9
		dc.w		GADGHIMAGE
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		Border2
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		NextImage


.IText		dc.b		1,0,RP_JAM2,0
		dc.w		16,1
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Next',0
		even

AboutGadg	dc.l		QuitGadg
		dc.w		15,152
		dc.w		62,9
		dc.w		GADGHIMAGE
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		Border2
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		DoAbout


.IText		dc.b		1,0,RP_JAM2,0
		dc.w		11,1
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'About',0
		even

QuitGadg	dc.l		0
		dc.w		225,152
		dc.w		62,9
		dc.w		GADGHIMAGE
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border1
		dc.l		Border2
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		DoQuit

.IText		dc.b		1,0,RP_JAM2,0
		dc.w		15,1
		dc.l		0
		dc.l		.Text
		dc.l		0

.Text		dc.b		'Quit',0
		even



Border1		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors1
		dc.l		.Border1
	
.Vectors1	dc.w		0,10
		dc.w		0,0
		dc.w		65,0

.Border1	dc.w		-2,-1
		dc.b		1,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors2
		dc.l		0

.Vectors2	dc.w		65,1
		dc.w		65,10
		dc.w		1,10

Border2		dc.w		-2,-1
		dc.b		1,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors1
		dc.l		.Border1
	
.Vectors1	dc.w		0,10
		dc.w		0,0
		dc.w		65,0

.Border1	dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		3
		dc.l		.Vectors2
		dc.l		0

.Vectors2	dc.w		65,1
		dc.w		65,10
		dc.w		1,10


WinText		dc.b		1,0,RP_JAM2,0
		dc.w		73,17
		dc.l		0
		dc.l		.Text1
		dc.l		.IText2

.Text1		dc.b		'Bank',0
		even

.IText2		dc.b		1,0,RP_JAM2,0
		dc.w		73,60
		dc.l		0
		dc.l		.Text2
		dc.l		.IText3

.Text2		dc.b		'Image ( 000 Loaded )',0
		even

.IText3		dc.b		1,0,RP_JAM2,0
		dc.w		14,74
		dc.l		0
		dc.l		.Text3
		dc.l		.IText4

.Text3		dc.b		'Number',0
		even

.IText4		dc.b		1,0,RP_JAM2,0
		dc.w		14,86
		dc.l		0
		dc.l		.Text4
		dc.l		.IText5

.Text4		dc.b		'Width',0
		even

.IText5		dc.b		1,0,RP_JAM2,0
		dc.w		14,98
		dc.l		0
		dc.l		.Text5
		dc.l		.IText6

.Text5		dc.b		'Height',0
		even

.IText6		dc.b		1,0,RP_JAM2,0
		dc.w		14,110
		dc.l		0
		dc.l		.Text6
		dc.l		0

.Text6		dc.b		'Depth',0
		even


GeneralIText	dc.b		1,0,RP_JAM2,0
		dc.w		0,0
		dc.l		0
		dc.l		0
		dc.l		0

GeneralImage	dc.w		0,0			X,Y
		dc.w		0,0			W,H
		dc.w		5			depth
		dc.l		0			ImageData
		dc.b		$001f,$0000
		dc.l		0

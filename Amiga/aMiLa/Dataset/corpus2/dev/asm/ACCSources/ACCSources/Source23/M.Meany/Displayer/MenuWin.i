
; This source originated from PowerWindows. I've optimised and customised it
;slightly.


;-------
;------- Load Example Window
;-------

LoadWindow
	dc.w	160,70
	dc.w	320,80
	dc.b	0,1
	dc.l	GADGETUP+CLOSEWINDOW
	dc.l	WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
	dc.l	NextLGadg
	dc.l	0
	dc.l	.Name
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
	dc.l	LoadWinText			;address of window text
	
.Name
	dc.b	'      Load Example Options',0
	even

NextLGadg:
	dc.l	PrevLGadg
	dc.w	26,58
	dc.w	79,11
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	RendBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoLoadNext

.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	23,2
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Next',0
	even

PrevLGadg
	dc.l	CancelGadg
	dc.w	122,58
	dc.w	79,11
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	RendBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoLoadPrev

.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	8,2
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Previous',0
	even

LoadWinText
	dc.b	1,0,RP_JAM2,0
	dc.w	48,29
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Select Which Example To Load',0
	even

;-------
;------- Run Example Window
;-------

RunWindow
	dc.w	160,70
	dc.w	320,80
	dc.b	0,1
	dc.l	GADGETUP+CLOSEWINDOW
	dc.l	WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
	dc.l	RunGadg
	dc.l	0
	dc.l	.Name
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
	dc.l	RunWinText

.Name
	dc.b	'       Run Current Example',0
	even

RunGadg:
	dc.l	CancelGadg
	dc.w	26,58
	dc.w	79,11
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	RendBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoRunEg

.IText	dc.b	1,0,RP_JAM2,0
	dc.w	11,2
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Run It!',0
	even

RunWinText
	dc.b	1,0,RP_JAM2,0
	dc.w	23,28
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Confirm You Want To Run The Example',0
	even

;-------
;------- Search Window
;-------

SearchWindow
	dc.w	160,70
	dc.w	320,80
	dc.b	0,1
	dc.l	GADGETUP+CLOSEWINDOW
	dc.l	WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
	dc.l	StrGadg
	dc.l	0
	dc.l	.Name
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
	dc.l	SearchWinText

.Name
	dc.b	'      String Search Options',0
	even

StrGadg
	dc.l	NextSGadg
	dc.w	122,35
	dc.w	176,10
	dc.w	SELECTED
	dc.w	RELVERIFY
	dc.w	STRGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoSearch
	
.SInfo:
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	50
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
	
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0

.Vectors
	dc.w	0,0
	dc.w	179,0
	dc.w	179,11
	dc.w	0,11
	dc.w	0,0

.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	-88,1
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'String ->',0
	even

NextSGadg:
	dc.l	PrevSGadg
	dc.w	26,58
	dc.w	79,11
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	RendBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoSearch

.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	23,2
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Next',0
	even

PrevSGadg
	dc.l	CancelGadg
	dc.w	122,58
	dc.w	79,11
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	RendBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoSPrev

.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	8,2
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Previous',0
	even

SearchWinText
	dc.b	1,0,RP_JAM2,0
	dc.w	17,15
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Select Search Option Or Enter String',0
	even

QuitWindow
	dc.w	160,70
	dc.w	320,80
	dc.b	0,1
	dc.l	GADGETUP+CLOSEWINDOW
	dc.l	WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
	dc.l	QuitGadg
	dc.l	0
	dc.l	.Name
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
	dc.l	QuitWinText

.Name
	dc.b	'    Quit Displayer Requested',0
	even

QuitGadg:
	dc.l	CancelGadg
	dc.w	26,58
	dc.w	79,11
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	RendBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoQuit
	
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	8,2
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'  Yes',0
	even

QuitWinText
	dc.b	1,0,RP_JAM2,0
	dc.w	79,28
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Sure You Want To Quit ?',0
	even

;-------
;------- Print Window
;-------

PrintWindow
	dc.w	160,70
	dc.w	320,80
	dc.b	0,1
	dc.l	GADGETUP+CLOSEWINDOW
	dc.l	WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
	dc.l	PrintPGadg
	dc.l	0
	dc.l	.Name
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
	dc.l	PrintWinText
	
.Name
	dc.b	'         Print Options',0
	even

PrintPGadg
	dc.l	PrintFGadg
	dc.w	26,58
	dc.w	79,11
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	RendBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoPrintPage

.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	23,2
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Page',0
	even

PrintFGadg
	dc.l	CancelGadg
	dc.w	122,58
	dc.w	79,11
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	RendBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoPrintFile

.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	8,2
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'  File',0
	even

PrintWinText
	dc.b	1,0,RP_JAM2,0
	dc.w	84,28
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Select Print Option',0
	even


;-------
;------- Generic Cancel Gadget
;-------

CancelGadg
	dc.l	0
	dc.w	219,58
	dc.w	79,11
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	RendBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoCancel

.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	15,2
	dc.l	0
	dc.l	.Text
	dc.l	0

.Text
	dc.b	'Cancel',0
	even

;-------
;------- Generic render border
;-------

RendBorder
	dc.w	-2,-1
	dc.b	2,0,RP_JAM1
	dc.b	3
	dc.l	.Vectors
	dc.l	.Border1
	
.Vectors
	dc.w	82,0
	dc.w	0,0
	dc.w	0,12

.Border1
	dc.w	-2,-1
	dc.b	1,0,RP_JAM1
	dc.b	3
	dc.l	.Vectors1
	dc.l	0

.Vectors1
	dc.w	1,12
	dc.w	82,12
	dc.w	82,1


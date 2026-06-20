
; About window data defenitions and support routines for PPMuchMore.

; © M.Meany, April 1991


About		tst.l		AboutFlag
		bne		.error

;--------------	Open the window

		lea		AboutWin,a0
		CALLINT		OpenWindow
		move.l		d0,about.ptr
		beq		.error

;--------------	We have a window, so now we need to print text
;		get a copy of rastport pointer.

.ok		move.l		d0,a0
		move.l		wd_RPort(a0),a0		a0->rast port
		lea		AboutText,a1		a1->the text
		moveq.l		#0,d0			no x offset
		move.l		d0,d1			no y offset
		CALLSYS		PrintIText		and print it

;--------------	Attach a user port

		move.l		about.ptr,a0		restore pointer
		move.l		MyPort,wd_UserPort(a0)

;--------------	Set IDCMP flags

		move.l		#GADGETUP,d0
		CALLSYS		ModifyIDCMP

;-------------- Attach the quit gadget to window

		move.l		about.ptr,a0		a0->window
		lea		AboutGadg,a1		a1->gadget
		moveq.l		#-1,d0			make it 1st in list
		CALLSYS		AddGadget		and add it

;--------------	Refresh the gadget to ensure it gets displayed.

		move.l		about.ptr,a1		a0->window
		lea		AboutGadg,a0		a1->gadget
		move.l		#0,a2			not a requester
		CALLSYS		RefreshGadgets		and display it

;--------------	Set screen and window titles

		move.l		about.ptr,a0		a0->window
		lea		AboutWinName,a1		a1->window title
		lea		scrn_Title,a2		a2->screen title
		CALLSYS		SetWindowTitles

;--------------	About window now open so set flag

		move.l		#1,AboutFlag

;-------------- Let main program know weve opened a window thats using ?????þ?????è???{b!w	MyPort

		add.l		#1,StillHere

;--------------	And return

.error		rts

QuitAbout	move.l		about.ptr,a0
		bsr		CloseWinSafe
		move.l		#0,AboutFlag
		sub.l		#1,StillHere
		rts


AboutWin
	dc.w	127,6
	dc.w	400,190
	dc.b	1,2
	dc.l	0
	dc.l	WINDOWDRAG+WINDOWDEPTH+NOCAREREFRESH+ACTIVATE
	dc.l	0
	dc.l	0
	dc.l	AboutWinName
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
AboutWinName
	dc.b	'PP Much More © M.Meany 1991',0
	even

AboutGadg
	dc.l	0
	dc.w	282,145
	dc.w	93,36
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	Border1
	dc.l	0
	dc.l	IText1
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	QuitAbout
Border1:
	dc.w	-2,-1
	dc.b	2,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors1
	dc.l	0
BorderVectors1:
	dc.w	0,0
	dc.w	96,0
	dc.w	96,37
	dc.w	0,37
	dc.w	0,0
IText1:
	dc.b	2,0,RP_JAM2,0
	dc.w	25,7
	dc.l	0
	dc.l	ITextText1
	dc.l	IText2
ITextText1:
	dc.b	'CLICK',0
	even
IText2:
	dc.b	2,0,RP_JAM2,0
	dc.w	25,21
	dc.l	0
	dc.l	ITextText2
	dc.l	0
ITextText2:
	dc.b	'HERE !',0
	even

AboutText
	dc.b	1,0,RP_JAM2,0
	dc.w	13,16
	dc.l	0
	dc.l	ITextText3
	dc.l	IText4
ITextText3:
	dc.b	'PPMuchMore is a text file viewer that can load',0
	even
IText4:
	dc.b	1,0,RP_JAM2,0
	dc.w	13,25
	dc.l	0
	dc.l	ITextText4
	dc.l	IText5
ITextText4:
	dc.b	'and display PowerPacked text files. Any number',0
	even
IText5:
	dc.b	1,0,RP_JAM2,0
	dc.w	14,34
	dc.l	0
	dc.l	ITextText5
	dc.l	IText6
ITextText5:
	dc.b	'of windows may be opened allowing any number',0
	even
IText6:
	dc.b	1,0,RP_JAM2,0
	dc.w	14,44
	dc.l	0
	dc.l	ITextText6
	dc.l	IText7
ITextText6:
	dc.b	'of text files to be read at any one time.',0
	even
IText7:
	dc.b	3,0,RP_JAM2,0
	dc.w	101,53
	dc.l	0
	dc.l	ITextText7
	dc.l	IText8
ITextText7:
	dc.b	'INSTRUCTION SUMMARY',0
	even
IText8:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,70
	dc.l	0
	dc.l	ITextText8
	dc.l	IText9
ITextText8:
	dc.b	'L      Load a text file',0
	even
IText9:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,80
	dc.l	0
	dc.l	ITextText9
	dc.l	IText10
ITextText9:
	dc.b	'S      Save text file ( always decrunched )',0
	even
IText10:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,90
	dc.l	0
	dc.l	ITextText10
	dc.l	IText11
ITextText10:
	dc.b	'M      Open a new window',0
	even
IText11:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,100
	dc.l	0
	dc.l	ITextText11
	dc.l	IText12
ITextText11:
	dc.b	'Q      Quit',0
	even
IText12:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,110
	dc.l	0
	dc.l	ITextText12
	dc.l	IText13
ITextText12:
	dc.b	'CURSOR UP     Line up (+shift for page up)',0
	even
IText13:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,120
	dc.l	0
	dc.l	ITextText13
	dc.l	IText14
ITextText13:
	dc.b	'CURSOR DOWN   Line down (+shift for page down)',0
	even
IText14:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,130
	dc.l	0
	dc.l	ITextText14
	dc.l	IText15
ITextText14:
	dc.b	'T      Top of file',0
	even
IText15:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,140
	dc.l	0
	dc.l	ITextText15
	dc.l	IText16
ITextText15:
	dc.b	'B      Bottom of file',0
	even
IText16:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,150
	dc.l	0
	dc.l	ITextText16
	dc.l	IText17
ITextText16:
	dc.b	'F      Search for string',0
	even
IText17:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,160
	dc.l	0
	dc.l	ITextText17
	dc.l	IText18
ITextText17:
	dc.b	'N      Find next occurence',0
	even
IText18:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,170
	dc.l	0
	dc.l	ITextText18
	dc.l	IText19
ITextText18:
	dc.b	'D      Dump file to printer',0
	even
IText19:
	dc.b	1,0,RP_JAM2,0
	dc.w	19,180
	dc.l	0
	dc.l	ITextText19
	dc.l	IText20
ITextText19:
	dc.b	'G      Goto line number xxxx',0
	even
IText20:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,60
	dc.l	0
	dc.l	ITextText20
	dc.l	0
ITextText20:
	dc.b	'HELP   This page',0
	even




***************	Present startup window for user to define screen dimensions

DoSetupWin	moveq.l		#0,d7			default to failure

; open the window

		lea		SUWindow,a0		Window
		CALLINT		OpenWindow		Open It
		move.l		d0,window.ptr(a4)	save struct ptr
		beq		.error			quit if error

; Save important structure addresses

		move.l		d0,a0			  a0->win struct	
		move.l		wd_UserPort(a0),window.up(a4) IDCMP port
		move.l		wd_RPort(a0),window.rp(a4)    save rp ptr

; Display instructions

		move.l		window.rp(a4),a0	a0->windows RastPort
		lea		SUWinText,a1		a1->IText structure
		moveq.l		#0,d0			X offset
		moveq.l		#0,d1			Y offset
		CALLINT		PrintIText		print this text

; Initialise integer gadgets

		lea		SUWGadg,a0		Gadget
		moveq.l		#20,d0			default width
		bsr		BuildIntStr		initialise it

		lea		SUHGadg,a0		Gadget
		moveq.l		#16,d0			default width
		bsr		BuildIntStr		initialise it

		lea		SUDGadg,a0		Gadget
		moveq.l		#4,d0			default width
		bsr		BuildIntStr		initialise it

		lea		SUWGadg,a0		Gadget
		move.l		window.ptr(a4),a1	Window
		suba.l		a2,a2			not requester
		moveq.l		#3,d0			numGad
		CALLINT		RefreshGList		refresh them!

; Deal with user interaction

.WaitForMsg	move.l		window.up(a4),a0 	a0->user port
		CALLEXEC	WaitPort		wait for event
		move.l		window.up(a4),a0	a0->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.WaitForMsg		if not loop back
		move.l		d0,a1			a1->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.l		im_IAddress(a1),a5	a5=addr of structure
		CALLSYS		ReplyMsg		answer OS

		cmp.l		#GADGETUP,d2		gadget?
		bne.s		.test_win		skip if not
		move.l		gg_UserData(a5),d0	get sub addr
		beq		.WaitForMsg		loop if NULL
		move.l		d0,a0
		jsr		(a0)			call sub

.test_win	cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne.s		.WaitForMsg	 	if not then jump

; Close the window

		move.l		window.ptr(a4),a0	Window
		CALLINT		CloseWindow		close it

		tst.l		d7
		beq		.error

; Set width, height and depth of display

		lea		SUWGadg,a0		a0->Gadget
		move.l		gg_SpecialInfo(a0),a0	a0->StringInfo
		move.l		si_LongInt(a0),d0	d0=block width
		asl.l		#4,d0			x pixel width
		move.l		d0,_Width(a4)		set width

		lea		SUHGadg,a0		a0->Gadget
		move.l		gg_SpecialInfo(a0),a0	a0->StringInfo
		move.l		si_LongInt(a0),d0	d0=block height
		asl.l		#4,d0			x pixel height
		move.l		d0,_Height(a4)		set height

		lea		SUDGadg,a0		a0->Gadget
		move.l		gg_SpecialInfo(a0),a0	a0->StringInfo
		move.l		si_LongInt(a0),d0	d0=screen depth
		move.l		d0,_Depth(a4)		set depth

; All done, so finish up.

.error		move.l		d7,d0			set return code
		move.l		#0,window.ptr(a4)
		move.l		#0,window.up(a4)
		move.l		#0,window.rp(a4)
		rts					and exit

***************	Check depth entered is in range 1->5.

SUSetD		move.l		gg_SpecialInfo(a5),a0	a0->StringInfo
		move.l		si_LongInt(a0),d0	depth
		beq.s		.error			skip if 0
		bmi.s		.error			skip if -ve
		
		cmp.l		#5,d0
		ble.s		.ok			skip if in range
		
.error		move.l		a5,a0			gadget
		moveq.l		#4,d0			default depth
		bsr		BuildIntStr		reset value

		lea		SUDGadg,a0		Gadget
		move.l		window.ptr(a4),a1	Window
		suba.l		a2,a2			not requester
		moveq.l		#1,d0			numGad
		CALLINT		RefreshGList		refresh them!

.ok		moveq.l		#0,d2			not quitting
		rts					and exit

***************

SUOk		moveq.l		#1,d7			go for it!
		move.l		#CLOSEWINDOW,d2
		rts

***************

SUQuit		move.l		#CLOSEWINDOW,d2
		rts

*************** Set an Integer gadget to a specified value.

; Entry		a0->Gadget structure
;		d0=long word value

BuildIntStr	movem.l		d0-d3/a0-a6,-(sp)	save registers

		move.l		gg_SpecialInfo(a0),a0	a0->StringInfo

		move.l		d0,si_LongInt(a0)	write long word

		lea		si_LongInt(a0),a1	a1->DataStream
		lea		.PutChar,a2		a2->Subroutine
		move.l		si_Buffer(a0),a3	a3->buffer
		lea		.Template,a0		a0->format string
		CALLEXEC	RawDoFmt		build text

		movem.l		(sp)+,d0-d3/a0-a6	restore registers
		rts					and return

.Template	dc.b		'%ld',0
		even

.PutChar	move.b		d0,(a3)+
		rts

SUWindow
	dc.w	180,40
	dc.w	350,150
	dc.b	0,1
	dc.l	GADGETUP+CLOSEWINDOW
	dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
	dc.l	SUWGadg
	dc.l	0
	dc.l	.Name
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
.Name
	dc.b	'ScreenDesigner © M.Meany, 1992.',0
	even

SUWGadg
	dc.l	SUHGadg
	dc.w	100,88
	dc.w	34,9
	dc.w	0
	dc.w	RELVERIFY+LONGINT
	dc.w	STRGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	0
.SInfo
	dc.l	SUWBuff
	dc.l	0
	dc.w	0
	dc.w	3
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
.Border
	dc.w	-3,-2
	dc.b	1,0,RP_JAM2
	dc.b	5
	dc.l	.BorderVectors
	dc.l	0
.BorderVectors
	dc.w	0,0
	dc.w	38,0
	dc.w	38,11
	dc.w	0,11
	dc.w	0,1
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	-80,0
	dc.l	0
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'Width  ->',0
	even
SUHGadg
	dc.l	SUDGadg
	dc.w	100,102
	dc.w	34,9
	dc.w	0
	dc.w	RELVERIFY+LONGINT
	dc.w	STRGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	0
.SInfo
	dc.l	SUHBuff
	dc.l	0
	dc.w	0
	dc.w	3
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
.Border
	dc.w	-3,-2
	dc.b	1,0,RP_JAM2
	dc.b	5
	dc.l	.BorderVectors
	dc.l	0
.BorderVectors
	dc.w	0,0
	dc.w	38,0
	dc.w	38,11
	dc.w	0,11
	dc.w	0,1
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	-80,0
	dc.l	0
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'Height ->',0
	even
SUDGadg
	dc.l	SUOkGadg
	dc.w	100,116
	dc.w	34,9
	dc.w	0
	dc.w	RELVERIFY+LONGINT
	dc.w	STRGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	SUSetD
.SInfo
	dc.l	SUDBuff
	dc.l	0
	dc.w	0
	dc.w	2
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
.Border
	dc.w	-3,-2
	dc.b	1,0,RP_JAM2
	dc.b	5
	dc.l	.BorderVectors
	dc.l	0
.BorderVectors
	dc.w	0,0
	dc.w	38,0
	dc.w	38,11
	dc.w	0,11
	dc.w	0,1
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	-80,0
	dc.l	0
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'Depth  ->',0
	even
SUOkGadg
	dc.l	SUQuitGadg
	dc.w	242,131
	dc.w	76,14
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SUOk
.Border
	dc.w	-2,-1
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	.BorderVectors
	dc.l	0
.BorderVectors
	dc.w	0,0
	dc.w	79,0
	dc.w	79,15
	dc.w	0,15
	dc.w	0,0
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	22,4
	dc.l	0
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'OK !',0
	even
SUQuitGadg
	dc.l	0
	dc.w	30,132
	dc.w	76,14
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SUQuit
.Border
	dc.w	-2,-1
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	.BorderVectors
	dc.l	0
.BorderVectors
	dc.w	0,0
	dc.w	79,0
	dc.w	79,15
	dc.w	0,15
	dc.w	0,0
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	13,4
	dc.l	0
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'QUIT !',0
	even


SUWinText
	dc.b	1,0,RP_JAM2,0
	dc.w	39,16
	dc.l	0
	dc.l	.ITextText1
	dc.l	.IText1
.ITextText1
	dc.b	'Set Playfield Width & Height in',0
	even
.IText1
	dc.b	1,0,RP_JAM2,0
	dc.w	29,26
	dc.l	0
	dc.l	.ITextText2
	dc.l	.IText2
.ITextText2
	dc.b	'blocks. Each block is 16x16 pixels.',0
	even
.IText2
	dc.b	1,0,RP_JAM2,0
	dc.w	37,37
	dc.l	0
	dc.l	.ITextText3
	dc.l	.IText3
.ITextText3
	dc.b	'Eg. A 320x256 display would have',0
	even
.IText3
	dc.b	1,0,RP_JAM2,0
	dc.w	58,49
	dc.l	0
	dc.l	.ITextText4
	dc.l	.IText4
.ITextText4
	dc.b	'Width = 20  ( 320/16 = 20 )',0
	even
.IText4
	dc.b	1,0,RP_JAM2,0
	dc.w	50,60
	dc.l	0
	dc.l	.ITextText5
	dc.l	.IText5
.ITextText5
	dc.b	'Height = 16  ( 256/16 = 16 )',0
	even
.IText5
	dc.b	1,0,RP_JAM2,0
	dc.w	16,70
	dc.l	0
	dc.l	.ITextText6
	dc.l	0
.ITextText6
	dc.b	'These are the smallest allowed values!',0
	even

SUWBuff
	dc.b	'20',0
	even

SUHBuff
	dc.b	'16',0
	even

SUDBuff
	dc.b	'4',0
	even

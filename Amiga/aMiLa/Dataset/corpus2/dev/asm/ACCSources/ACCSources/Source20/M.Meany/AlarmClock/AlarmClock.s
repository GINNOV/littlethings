
*****	Function	A Small and simple alarm clock program.
*****	Size		1362 bytes
*****	Author		M.Meany.
*****	Date		4th Jan 1992.

*---------------------------------------------------
* Gadgets created with PowerSource V3.0
* which is (c) Copyright 1990-91 by Jaba Development
* written by Jan van den Baard
*---------------------------------------------------

; Program is a modification on previous version that operated on INTUITICKS.
;The clock now functions when window is not active. Presentation stylled for
;Workbench 2.0

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"


CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

		lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base ptr
		beq		error		quit if error

		lea		intname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLSYS		OpenLibrary	and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq		error1		quit if error

		lea		MyWindow,a0	a0->window args
		CALLINT		OpenWindow	and open it
		move.l		d0,window.ptr	save struct ptr
		beq		error2		quit if error

		move.l		d0,a0			  a0->win struct	
		move.l		wd_UserPort(a0),window.up save up ptr
		move.l		wd_RPort(a0),window.rp    save rp ptr

		move.l		window.rp,a0	windows rastport ptr
		lea		RT0,a1		address of IText struct
		moveq.l		#0,d0		no x offset
		move.l		d0,d1		no y offset
		CALLSYS		PrintIText	display text

WaitForMsg	moveq.l		#5,d1		.1 of a second delay
		CALLDOS		Delay		and wait
		
		bsr.s		DoClock		update clock display

		tst.l		AlarmSet	alarm enabled?
		beq.s		.nextmsg	if not skip
		bsr		CheckAlarm	check time

.nextmsg	move.l		window.up,a0	a0-->window pointer
		CALLEXEC	GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 addr of structure
		CALLSYS		ReplyMsg	answer os or it get angry

		move.l		d2,d0		copy IDCMP
		and.l		#GADGETUP!GADGETDOWN,d0	was it a gadget
		beq.s		.test_close	if not skip
		move.l		gg_UserData(a5),d0 d0=addr of subroutine
		beq.s		.test_close	skip if not defined
		move.l		d0,a0		a0->subroutine
		jsr		(a0)		call subroutine
		bra.s		.nextmsg	and loop

.test_close	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		.nextmsg	 if not then jump

		move.l		window.ptr,a0	a0->Window struct
		CALLINT		CloseWindow	and close it

error2		move.l		_IntuitionBase,a1	a1=base ptr
		CALLEXEC	CloseLibrary		close lib

error1		move.l		_DOSBase,d0		a1=base ptr	
		CALLEXEC	CloseLibrary		close lib

error		rts


;***********************************************************
;		Subroutines
;***********************************************************

***************	Update the time in windows title bar.

DoClock		move.l		#DSDays,d1	d1=addr of buffer
		CALLDOS		DateStamp	and get stamp

		lea		DataStream,a0	a0->RDF data buffer

		move.l		DSMin,d0	d0=mins past midnight
		divu		#60,d0		convert to hours

		swap		d0		mins in low word, hrs in high
		move.l		d0,(a0)+	save in RDF data buffer

		move.l		DSSec60,d0	get seconds x 60
		divu		#50,d0		convert to secs
		move.w		d0,(a0)		save in RDF data buffer

		lea		Template,a0	a0->rdf template
		lea		DataStream,a1	a1->rdf datastream
		lea		PutChar,a2	a2->PutChar subroutine
		lea		Tim,a3		a3->dest buffer
		CALLEXEC	RawDoFmt	built window title

		move.l		window.rp,a0	window rastport pointer
		lea		TimeString,a1	addr of IText struct
		moveq.l		#0,d0		no x offset
		move.l		d0,d1		no y offset
		CALLINT		PrintIText	display time

		rts

; Subroutine used by RawDoFmt() to save converted template.

PutChar		move.b		d0,(a3)+	byte into buffer
		rts				and return

***************	Compare time to alarm, flash display if same

CheckAlarm	lea		Alarm,a0	a0->current time
		lea		Tim,a1		a1->alarm set time
		
		tst.b		AlarmBuffer	is there a time specified
		beq.s		.done		if not skip

.loop		cmp.b		(a0)+,(a1)+	check similarity
		bne.s		.done		if different quit
		
		tst.b		(a0)		end of alarm time?
		bne.s		.loop		if not loop back
		
		suba.l		a0,a0		set for all screens
		CALLINT		DisplayBeep	and flash
		
		lea		$dff180,a0	a0->color00 register
		move.l		#$0fff,d0	max colour value
.alarm		move.w		d0,(a0)		set colour
		dbra		d0,.alarm	cycle colours
		
.done		rts

***************	Deal with ON gadget selection

DoOn		moveq.l		#2,d0		num of gadgets to remove
		lea		OnGadg,a1	ptr to first gadget
		bsr.s		RemoveGad	and remove them

		move.l		#SELECTED,d0	d0=gadg flag 		
		lea		OnGadg,a0	a0->on gadget
		or.w		d0,gg_Flags(a0)	set selected
		
		not.w		d0		set for deselection
		lea		OffGadg,a0	a0->off gadget
		and.w		d0,gg_Flags(a0)	and deselect
		
		move.l		#1,AlarmSet	set flag for alarm on
		
		moveq.l		#2,d0		num of gadgets
		lea		OnGadg,a1	ptr to 1st gadget to add
		bsr.s		AddGad		add them back
		
		rts				all done so return

***************	Deal with OFF gadget selection

DoOff		moveq.l		#2,d0		num of gadgets to remove
		lea		OnGadg,a1	ptr to first gadget
		bsr.s		RemoveGad	and remove them

		move.l		#SELECTED,d0	d0=gadg flag 		
		lea		OffGadg,a0	a0->off gadget
		or.w		d0,gg_Flags(a0)	set selected
		
		not.w		d0		set for deselection
		lea		OnGadg,a0	a0->on gadget
		and.w		d0,gg_Flags(a0)	and deselect
		
		move.l		#0,AlarmSet	set flag for alarm on
		
		moveq.l		#2,d0		num of gadgets
		lea		OnGadg,a1	ptr to 1st gadget to add
		bsr.s		AddGad		add them back
		
		rts				all done so return

***************	Remove gadgets from list

; Entry		a1->first gadget structure
;		d0= number of gadgets to remove

RemoveGad	move.l		window.ptr,a0	window pointer
		CALLINT		RemoveGList	remove gadgets
		rts

***************	Add gadgets back to list

; Entry		a1->first gadget to add to list
;		d0=num of gadgets to add

AddGad		movem.l		d1/a1,-(sp)	save d1,a1 numgad,gadget
		move.l		window.ptr,a0	get window ptr
		sub.l		a2,a2		clear a2
		CALLINT		AddGList	d0 should remain unchanged
		move.l		window.ptr,a1	since RemoveGList
		movem.l		(sp)+,d0/a0	set up d0,a0 numgad,gadget  
		CALLSYS		RefreshGList	refresh gadgets	
		rts		

;***********************************************************
;	Strings and Buffer defenitions
;***********************************************************


dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even

Template	dc.b		'Time  %02d:%02d:%02d',0
		even

Alarm		dc.b		'Time  '
AlarmBuffer	ds.b		10
		even

;***********************************************************
;	Window Gadget and IText defenitions
;***********************************************************

SharedBordersPairs0:
    DC.W    -2,-1,-2,8,-1,7,-1,-1,78,-1
SharedBordersPairs1:
    DC.W    -1,8,78,8,78,0,79,-1,79,8
SharedBordersPairs2:
    DC.W    0,0,0,9,1,8,1,0,46,0
SharedBordersPairs3:
    DC.W    1,9,46,9,46,1,47,0,47,9

SharedBorders0:
    DC.W    0,0
    DC.B    2,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs0,SharedBorders1

SharedBorders1:
    DC.W    0,0
    DC.B    1,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs1,0

SharedBorders2:
    DC.W    0,0
    DC.B    1,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs0,SharedBorders3

SharedBorders3:
    DC.W    0,0
    DC.B    2,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs1,0

SharedBorders4:
    DC.W    0,0
    DC.B    2,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs2,SharedBorders5

SharedBorders5:
    DC.W    0,0
    DC.B    1,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs3,0

SharedBorders6:
    DC.W    0,0
    DC.B    1,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs2,SharedBorders7

SharedBorders7:
    DC.W    0,0
    DC.B    2,0
    DC.B    RP_JAM1,5
    DC.L    SharedBordersPairs3,0

RT0:
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    9,15
    DC.L    0
    DC.L    .RTIText0
    DC.L    0

.RTIText0:
    DC.B    'Alarm ->',0
    EVEN

OffGadg_text0:
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    13,1
    DC.L    0
    DC.L    OffGadg_itext0
    DC.L    0

OffGadg_itext0:
    DC.B    'OFF',0
    EVEN

OffGadg:
    DC.L    0
    DC.W    103,29
    DC.W    48,10
    DC.W    GADGHIMAGE+SELECTED
    DC.W    GADGIMMEDIATE
    DC.W    BOOLGADGET
    DC.L    SharedBorders4
    DC.L    SharedBorders6
    DC.L    OffGadg_text0,0
    DC.L    0
    DC.W    0
    DC.L    DoOff

OnGadg_text0:
    DC.B    1,0
    DC.B    RP_JAM1
    DC.W    16,1
    DC.L    0
    DC.L    OnGadg_itext0
    DC.L    0

OnGadg_itext0:
    DC.B    'ON',0
    EVEN

OnGadg:
    DC.L    OffGadg
    DC.W    19,29
    DC.W    48,10
    DC.W    GADGHIMAGE
    DC.W    GADGIMMEDIATE
    DC.W    BOOLGADGET
    DC.L    SharedBorders4
    DC.L    SharedBorders6
    DC.L    OnGadg_text0,0
    DC.L    0
    DC.W    0
    DC.L    DoOn

AlarmGadg_info:
    DC.L    AlarmBuffer
    DC.L    0
    DC.W    0,9
    DC.W    0,0,0,0,0,0
    DC.L    0,0,0

AlarmGadg:
    DC.L    OnGadg
    DC.W    79,14
    DC.W    79,8
    DC.W    GADGHIMAGE
    DC.W    RELVERIFY
    DC.W    STRGADGET
    DC.L    SharedBorders0
    DC.L    SharedBorders2
    DC.L    0,0
    DC.L    AlarmGadg_info
    DC.W    0
    DC.L    0

MyWindow:
    DC.W    0,25,180,45
    DC.B    0,1
    DC.L    GADGETUP+CLOSEWINDOW+GADGETDOWN
    DC.L    WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH+SMART_REFRESH
    DC.L    AlarmGadg,0
    DC.L    0
    DC.L    0,0
    DC.W    150,30,640,256,WBENCHSCREEN

TimeString	dc.b		1,0		front and back text pens
		dc.b		RP_JAM2,0	drawmode and fill byte
		dc.w		38,1		XY org relative to TopLeft
		dc.l		0		font pointer (default)
		dc.l		Tim		pointer to text
		dc.l		0		no more IntuiTexts

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_DOSBase	ds.l		1		space for lib base pointer
_IntuitionBase	ds.l		1		space for lib base pointer

window.ptr	ds.l		1		space for window pointer
window.rp	ds.l		1		space for rastport pointer
window.up	ds.l		1		space for user port pointer

DSDays		ds.l		1		space for DateStamp
DSMin		ds.l		1
DSSec60		ds.l		1

AlarmSet	ds.l		1		flag set if alarm enabled

DataStream	ds.l		3		room for rdf buffer

Tim		ds.b		20		space for ASCII string



***************	

***************	Pad out a string with spaces

; Entry		a0->string. Length of string including NULL terminator must
;		    be located in the byte preceeding the string

; Corrupt	none

ExpandString	move.l		a0,-(sp)
		move.l		d0,-(sp)

		moveq.l		#0,d0
		move.b		-1(a0),d0		d0=length

.loop		subq.w		#1,d0
		tst.b		(a0)+
		bne.s		.loop
		
		subq.w		#1,d0
		bmi.s		.done

		subq.l		#1,a0

.loop1		move.b		#' ',(a0)+
		dbra		d0,.loop1

		move.b		#0,(a0)
		
.done		move.l		(sp)+,d0
		move.l		(sp)+,a0
		rts

***************	Remove excess spaces from end of a NULL terminated string

; Entry		a0->string

; Corrupt	None

ReduceString	move.l		a0,-(sp)

.loop		tst.b		(a0)+
		bne.s		.loop
		
		subq.l		#1,a0
.loop1		cmp.b		#' ',-(a0)
		bne.s		.done
		move.b		#0,(a0)
		bra.s		.loop1

.done		move.l		(sp)+,a0
		rts

***************	Convert RAWKEY to Function Number

; Returns ASCII code of any key being pressed, 0 if no key

; Entry		d0=raw key code

; Exit		d0=number of function to call, 0 if no function

GetChar		lea		KCTable,a0	a0->lookup table
		move.b		0(a0,d0),d0	convert to ASCII

		rts		

***************	Display the next Operator in Main Window

; Entry		None

; Exit		None

; Corrupt	d0

NextOp		PUSHALL

		move.w		OpCur(a5),d0
		cmp.w		OpCount(a5),d0
		bge		.done
		addq.w		#1,OpCur(a5)
		bsr		DisplayOp

.done		PULLALL
		rts

***************	Display previous operator in Main window

PrevOp		PUSHALL

		cmp.w		#1,OpCur(a5)
		ble.s		.done
		subq.w		#1,OpCur(a5)
		bsr		DisplayOp

.done		PULLALL
		rts

***************	Display Operator Details in Main Window

DisplayOp	PUSHALL

		cmp.w		#1,win.mode(a5)		in operator mode?
		beq.s		.ok			yep, ignore

; Set up main window for displaying operators

		move.w		#1,win.mode(a5)		signal in Op mode
		bsr		ClearMain
		
		move.l		win.rp(a5),a0
		lea		OpWinText,a1
		moveq.l		#0,d0
		moveq.l		#0,d1
		CALLINT		PrintIText

; Load operator details from data file

.ok		bsr		GetOperator
		bsr		OpFromWBuff

; Display operator details in window

		lea		QRZGadgSIBuff,a0
		bsr		ExpandString
		moveq.l		#120,d0			x
		moveq.l		#30,d1			y
		bsr		WriteToMain
		
		lea		OpGadgSIBuff,a0
		bsr		ExpandString
		moveq.l		#120,d0			x
		moveq.l		#38,d1			y
		bsr		WriteToMain
		
		lea		QTHGadgSIBuff,a0
		bsr		ExpandString
		moveq.l		#120,d0			x
		moveq.l		#46,d1			y
		bsr		WriteToMain
		
		lea		Addr1GadgSIBuff,a0
		bsr		ExpandString
		move.l		#430,d0			x
		moveq.l		#30,d1			y
		bsr		WriteToMain
		
		lea		Addr2GadgSIBuff,a0
		bsr		ExpandString
		move.l		#430,d0			x
		moveq.l		#38,d1			y
		bsr		WriteToMain
		
		lea		Addr3GadgSIBuff,a0
		bsr		ExpandString
		move.l		#430,d0			x
		moveq.l		#46,d1			y
		bsr		WriteToMain
		
		lea		Addr4GadgSIBuff,a0
		bsr		ExpandString
		move.l		#430,d0			x
		moveq.l		#54,d1			y
		bsr		WriteToMain
		
		lea		Addr5GadgSIBuff,a0
		bsr		ExpandString
		move.l		#430,d0			x
		moveq.l		#62,d1			y
		bsr		WriteToMain
		
		lea		Addr6GadgSIBuff,a0
		bsr		ExpandString
		move.l		#430,d0			x
		moveq.l		#70,d1			y
		bsr		WriteToMain
		
		lea		PhonGadgSIBuff,a0
		bsr		ExpandString
		move.l		#430,d0			x
		moveq.l		#80,d1			y
		bsr		WriteToMain
		
		lea		FaxGadgSIBuff,a0
		bsr		ExpandString
		move.l		#430,d0			x
		moveq.l		#88,d1			y
		bsr		WriteToMain

		lea		BurText1,a0
		tst.w		BureauFlag(a5)
		beq.s		.NoSet
		lea		BurText2,a0

.NoSet		move.l		#430,d0			x
		moveq.l		#96,d1			y
		bsr		WriteToMain

		lea		LocGadgSIBuff,a0
		bsr		ExpandString
		moveq.l		#120,d0			x
		moveq.l		#54,d1			y
		bsr		WriteToMain
		
		lea		ConGadgSIBuff,a0
		bsr		ExpandString
		moveq.l		#120,d0			x
		moveq.l		#62,d1			y
		bsr		WriteToMain

; Reset window title

		bsr		SetWinName

; Display log in window

		PULLALL
		rts

***************	Read Operator Details From Disk

; Entry		OpCur = number of operator to load

; Exit		none

; Corrupt	d0

GetOperator	PUSHALL

		tst.w		OpCur(a5)
		bne.s		.get

		lea		NoOpText,a0
		bsr		OKReq
		bra.s		.done

.get		move.l		OpsHandle(a5),a0	handle
		moveq.l		#0,d0
		move.w		OpCur(a5),d0		record number
		bsr		LoadRecord

.done		PULLALL
		rts

***************	Clear the Main Window

ClearMain	PUSHALL

		move.l		win.rp(a5),a1		RastPort
		moveq.l		#0,d0			Pen 0
		CALLGRAF	SetAPen			set drawing colour
		
		move.l		win.ptr(a5),a0		Window
		moveq.l		#0,d0
		moveq.l		#0,d1
		moveq.l		#0,d2
		moveq.l		#0,d3
		moveq.l		#0,d4
		move.b		wd_BorderLeft(a0),d0	x start
		move.b		wd_BorderTop(a0),d1	y start
		move.w		wd_Width(a0),d2
		move.b		wd_BorderRight(a0),d4
		sub.w		d4,d2			x stop
		move.w		wd_Height(a0),d3
		move.b		wd_BorderBottom(a0),d4
		sub.w		d4,d3			y stop
		move.l		win.rp(a5),a1
		CALLSYS		RectFill

		PULLALL
		rts

***************	Write text at specified position in the Main window

; Entry		a0->Null terminated text
;		d0=x position
;		d1=y position

WriteToMain	PUSHALL

		lea		WinText,a1		a1->IntuiText
		move.l		a0,it_IText(a1)		set pointer
		move.l		win.rp(a5),a0
		CALLINT		PrintIText

		PULLALL
		rts

***************	Build & Display title for main window after data input

SetWinName	PUSHALL
		lea		MWTemplate,a0		template
		lea		OpCur(a5),a1		DSTream
		lea		.PutC,a2
		lea		MWName,a3
		CALLEXEC	RawDoFmt		format it!

		move.l		win.ptr(a5),a0
		lea		MWName,a1
		suba.l		a2,a2
		CALLINT		SetWindowTitles

		PULLALL
		rts					back to main

.PutC		move.b		d0,(a3)+
		rts

*****************************************************************************
*			Menu Handling Routines				    *
*****************************************************************************

***************	Menu servicing routine

;enter with address of Gadget or MenuItem in D0

DoMenuItem	lea		.EventTable(pc),a0	vector list

.EventLoop	move.l		(a0)+,d1		are we done?
		beq.s		.return			return if no match
		cmp.l		d1,d0			chosen object?
		movea.l		(a0)+,a1		a1=vector
		bne.s		.EventLoop		no-continue looking
		jsr		(a1)			go do the code

.return		rts

.EventTable	dc.l		MenuItem19,PNPLog
		dc.l		MenuItem18,PNShowLog
		dc.l		MenuItem17,PNSetDate
		dc.l		MenuItem16,MOPCard
		dc.l		MenuItem15,MOPLabel
		dc.l		MenuItem14,MOPLog
		dc.l		MenuItem13,MOPDetails
		dc.l		MenuItem12,MOFind
		dc.l		MenuItem11,MOEdit
		dc.l		MenuItem10,MOAdd
		dc.l		MenuItem9,MOShow
		dc.l		MenuItem8,MPLogDate
		dc.l		MenuItem7,MPLogEntries
		dc.l		MenuItem6,MPLogWin
		dc.l		MenuItem5,MLDelete
		dc.l		MenuItem4,MAddLog
		dc.l		MenuItem3,MLShow
		dc.l		MenuItem2,MQuit
		dc.l		MenuItem1,MAbout
		dc.l		0

***************	Menu routines not yet developed

PNPLog
PNShowLog
PNSetDate
MOPCard
MOPLabel
MOPLog
MOPDetails
;MOFind
;MOEdit
;MOAdd
;MOShow
MPLogDate
MPLogEntries
MPLogWin
MLDelete
MAddLog
MLShow
;MQuit
;MAbout		
		rts

***************	Menu Quit

MQuit		move.l		#CLOSEWINDOW,d7
		rts

***************	Menu Show Operator

MOShow		tst.w		OpCur(a5)
		bne.s		.IsOk
		move.w		#1,OpCur(a5)
.IsOk		bsr		DisplayOp
		rts

***************	Menu Add Operator

MOAdd		PUSHALL

		moveq.l		#0,d0
		move.w		OpCount(a5),d0
		addq.w		#1,d0
		
		move.w		OpCur(a5),d6		save old value
		move.w		d0,OpCur(a5)		set new
		
		bsr		ClearOpIn
		bsr		EditOperator
		tst.l		d0
		beq.s		.Saved
		move.w		OpCur(a5),d6
		addq.w		#1,OpCount(a5)

.Saved		move.w		d6,OpCur(a5)

		bsr		SetWinName

		bsr		DisplayOp

.done		PULLALL
		rts

***************	Menu Edit Operator

MOEdit		PUSHALL

		tst.w		OpCur(a5)
		bne.s		.Edit

		lea		NoOpText,a0
		bsr		OKReq
		bra.s		.done
		
.Edit		bsr		OpFromWBuff
		bsr		EditOperator
		tst.l		d0
		beq.s		.done

		bsr		DisplayOp

.done		PULLALL
		rts

*****************************************************************************
*			Edit Operator Routines				    *
*****************************************************************************


;--------------	Copy Operator data from input buffers to write buffer

OptToWBuff	move.l		OpsHandle(a5),a0
		move.l		rnd_Buffer(a0),a0	a0->Write Buffer

		lea		QRZGadgSIBuff,a1	copy QRZ
		moveq.l		#19,d0
.Loop1		move.b		(a1)+,(a0)+
		dbra		d0,.Loop1

		lea		OpGadgSIBuff,a1		copy Operator
		moveq.l		#19,d0
.Loop2		move.b		(a1)+,(a0)+
		dbra		d0,.Loop2

		lea		QTHGadgSIBuff,a1	copy 
		moveq.l		#29,d0
.Loop3		move.b		(a1)+,(a0)+
		dbra		d0,.Loop3

		lea		Addr1GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.Loop6		move.b		(a1)+,(a0)+
		dbra		d0,.Loop6

		lea		Addr2GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.Loop7		move.b		(a1)+,(a0)+
		dbra		d0,.Loop7

		lea		Addr3GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.Loop8		move.b		(a1)+,(a0)+
		dbra		d0,.Loop8

		lea		Addr4GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.Loop9		move.b		(a1)+,(a0)+
		dbra		d0,.Loop9

		lea		Addr5GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.LoopA		move.b		(a1)+,(a0)+
		dbra		d0,.LoopA

		lea		Addr6GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.LoopB		move.b		(a1)+,(a0)+
		dbra		d0,.LoopB

		lea		PhonGadgSIBuff,a1	copy 
		moveq.l		#19,d0
.LoopC		move.b		(a1)+,(a0)+
		dbra		d0,.LoopC

		lea		FaxGadgSIBuff,a1	copy 
		moveq.l		#19,d0
.LoopD		move.b		(a1)+,(a0)+
		dbra		d0,.LoopD
		
		move.w		BureauFlag(a5),(a0)+

		lea		LocGadgSIBuff,a1	copy 
		moveq.l		#5,d0
.Loop4		move.b		(a1)+,(a0)+
		dbra		d0,.Loop4

		lea		ConGadgSIBuff,a1	copy 
		moveq.l		#9,d0
.Loop5		move.b		(a1)+,(a0)+
		dbra		d0,.Loop5

		move.l		#0,(a0)+		no date at present

		rts

;--------------	Copy data from write buffer to input buffers

OpFromWBuff	move.l		OpsHandle(a5),a0
		move.l		rnd_Buffer(a0),a0	a0->Write Buffer

		moveq.l		#0,d1

		lea		QRZGadgSIBuff,a1	copy QRZ
		moveq.l		#19,d0
.Loop1		move.b		(a0)+,(a1)+
		dbra		d0,.Loop1
		move.b		d1,(a1)			NULL terminate

		lea		OpGadgSIBuff,a1		copy Operator
		moveq.l		#19,d0
.Loop2		move.b		(a0)+,(a1)+
		dbra		d0,.Loop2
		move.b		d1,(a1)			NULL terminate

		lea		QTHGadgSIBuff,a1	copy 
		moveq.l		#29,d0
.Loop3		move.b		(a0)+,(a1)+
		dbra		d0,.Loop3
		move.b		d1,(a1)			NULL terminate

		lea		Addr1GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.Loop6		move.b		(a0)+,(a1)+
		dbra		d0,.Loop6
		move.b		d1,(a1)			NULL terminate

		lea		Addr2GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.Loop7		move.b		(a0)+,(a1)+
		dbra		d0,.Loop7
		move.b		d1,(a1)			NULL terminate

		lea		Addr3GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.Loop8		move.b		(a0)+,(a1)+
		dbra		d0,.Loop8
		move.b		d1,(a1)			NULL terminate

		lea		Addr4GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.Loop9		move.b		(a0)+,(a1)+
		dbra		d0,.Loop9
		move.b		d1,(a1)			NULL terminate

		lea		Addr5GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.LoopA		move.b		(a0)+,(a1)+
		dbra		d0,.LoopA
		move.b		d1,(a1)			NULL terminate

		lea		Addr6GadgSIBuff,a1	copy 
		moveq.l		#24,d0
.LoopB		move.b		(a0)+,(a1)+
		dbra		d0,.LoopB
		move.b		d1,(a1)			NULL terminate

		lea		PhonGadgSIBuff,a1	copy 
		moveq.l		#19,d0
.LoopC		move.b		(a0)+,(a1)+
		dbra		d0,.LoopC
		move.b		d1,(a1)			NULL terminate

		lea		FaxGadgSIBuff,a1	copy 
		moveq.l		#19,d0
.LoopD		move.b		(a0)+,(a1)+
		dbra		d0,.LoopD
		move.b		d1,(a1)			NULL terminate

		move.w		(a0)+,BureauFlag(a5)

		lea		LocGadgSIBuff,a1	copy 
		moveq.l		#5,d0
.Loop4		move.b		(a0)+,(a1)+
		dbra		d0,.Loop4
		move.b		d1,(a1)			NULL terminate

		lea		ConGadgSIBuff,a1	copy 
		moveq.l		#9,d0
.Loop5		move.b		(a0)+,(a1)+
		dbra		d0,.Loop5
		move.b		d1,(a1)			NULL terminate

		rts

;--------------	Clear all entry buffers

ClearOpIn	moveq.l		#0,d0
		move.b		d0,QRZGadgSIBuff
		move.b		d0,OpGadgSIBuff
		move.b		d0,QTHGadgSIBuff
		move.b		d0,Addr1GadgSIBuff
		move.b		d0,Addr2GadgSIBuff
		move.b		d0,Addr3GadgSIBuff
		move.b		d0,Addr4GadgSIBuff
		move.b		d0,Addr5GadgSIBuff
		move.b		d0,Addr6GadgSIBuff
		move.b		d0,PhonGadgSIBuff
		move.b		d0,FaxGadgSIBuff
		move.w		d0,BureauFlag(a5)
		move.b		d0,LocGadgSIBuff
		move.b		d0,ConGadgSIBuff

		rts



; Entry		OpCur=ID of operator to edit. To add a new Operator, set
;		      OpCur=OpCount+1 prior to calling. If user aborts
;		      adding a new Operator, you will need to reset OpCur
;		      to it's previous value! Do not enter with OpCur=0!!!
;		      If new operator is added, don't forget to bump OpCount!

; Exit		d0=0 if operation aborted

EditOperator	moveq.l		#0,d7			default to error

; Open the window

		lea		AddOpWindow,a0		a0->window args
		CALLINT		OpenWindow		and open it
		move.l		d0,tmp.ptr(a5)		save struct ptr
		beq		.error			quit if error

		move.l		d0,a0			a0->win struct	
		move.l		wd_UserPort(a0),tmp.up(a5) save up ptr
		move.l		wd_RPort(a0),tmp.rp(a5)    save rp ptr

; Activate 1st string gadget and set text for toggle gadget

		bsr		DoBurGadg

; deal with events

.WaitMsg	move.l		tmp.up(a5),a0		a0->user port
		CALLEXEC	WaitPort		wait for message
		move.l		tmp.up(a5),a0		a0->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.WaitMsg		if not loop back
		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.l		im_IAddress(a1),a4 	a4=addr of structure
		CALLSYS		ReplyMsg		answer os

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		.test_win
		move.l		gg_UserData(a4),a0
		cmpa.l		#0,a0
		beq.s		.test_win
		jsr		(a0)

.test_win	cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne.s		.WaitMsg	 	if not then jump

; close the window

		move.l		tmp.ptr(a5),a0
		CALLINT		CloseWindow
		moveq.l		#0,d2			clear IDCMP flag

; If OK selected, save operator details

		tst.w		d7
		beq.s		.done

; Get ID of this operator

		bsr		OptToWBuff

		moveq.l		#0,d0
		move.w		OpCur(a5),d0
		move.l		OpsHandle(a5),a0
		bsr		SaveRecord

; Update the index file 

		move.l		#QRZGadgSIBuff,a0
		move.l		IndexHandle(a5),a1
		move.l		rnd_Buffer(a1),a1
		moveq.l		#20,d0
		CALLEXEC	CopyMem

		moveq.l		#0,d0
		move.w		OpCur(a5),d0
		move.l		IndexHandle(a5),a0	handle
		bsr		SaveRecord

;		bsr		UpdateIndex

; return status to caller

.done		move.l		d7,d0			signal no errors

.error		rts


DoCanGadg	move.l		#CLOSEWINDOW,d2
		rts

DoOkGadg	moveq.l		#1,d7			signal save OK
		move.l		#CLOSEWINDOW,d2
		rts

DoBurGadg	lea		BurText1,a0
		not.w		BureauFlag(a5)		toggle flag
		beq.s		.IsOk
		lea		BurText2,a0

.IsOk		move.l		a0,OurText

		move.l		tmp.rp(a5),a0		a0->RastPort
		lea		WinText,a1		a1->IText structure
		move.l		#455,d0			X offset
		moveq.l		#121,d1			Y offset
		CALLINT		PrintIText		print this text

		lea		QRZGadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoFaxGadg	lea		QRZGadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoPhonGadg	lea		FaxGadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoAddr6Gadg	lea		PhonGadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoAddr5Gadg	lea		Addr6Gadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoAddr4Gadg	lea		Addr5Gadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoAddr3Gadg	lea		Addr4Gadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoAddr2Gadg	lea		Addr3Gadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoAddr1Gadg	lea		Addr2Gadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoConGadg	lea		Addr1Gadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoLocGadg	lea		ConGadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoQTHGadg	lea		LocGadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoOpGadg	lea		QTHGadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

DoQRZGadg	lea		OpGadg,a0
		move.l		tmp.ptr(a5),a1
		suba.l		a2,a2
		CALLINT		ActivateGadget
		moveq.l		#0,d2
		rts

*****************************************************************************
*			About Window Routines				    *
*****************************************************************************

MAbout		PUSHALL

		lea		AbTable,a4		a4->Text strings
		
; Switch to About mode and clear the window

		cmp.w		#2,win.mode(a5)		in About mode?
		beq.s		.Skip			yep, skip next bit!
		move.w		#2,win.mode(a5)		in About mode?
		bsr		ClearMain

; Display each line of text for about window

.Skip		lea		AbTable,a3		a3->Text Vector Table
		moveq.l		#12,d7			Y ordinate

.loop		move.l		win.rp(a5),a0		RastPort
		lea		WinText,a1		IText
		bsr		CenterText
		move.l		(a3)+,it_IText(a1)	set text address
		beq.s		.error			exit at end
;		moveq.l		#10,d0			X
		move.l		d7,d1			Y
		CALLINT		PrintIText		print it!
		addq.w		#8,d7			bump Y
		bra.s		.loop

.error		PULLALL
		rts


CenterText	movem.l		d1/a0,-(sp)
		moveq.l		#-1,d1		length
		move.l		(a3),a0

.loop		addq.w		#1,d1
		tst.b		(a0)+
		bne.s		.loop
		
		asl.w		#3,d1		x8
		move.l		#640,d0
		sub.l		d1,d0
		asr.w		#1,d0		X

		movem.l		(sp)+,d1/a0
		rts

		*****************************************
		*    Routines to convert DateStamp()	*
		*  into useable values. M.Meany, 1992.	*
		*****************************************

; This routine will convert the day count returned by DateStamp() into the
;date proper so it can be used! MM.

; Entry		d0=days since 01-Jan-1978
;		a0->buffer for date string ( at least 12 bytes )

; Exit		buffer will be filled with date string in form dd-mmm-yyyy,
;		string will be NULL terminated.

; Corrupt	None

GetDate		movem.l		d0-d4/a0-a4/a6,-(sp)

; We want todays date, but today has not elapsed yet! Bump day count to
;accomodate this.

		addq.l		#1,d0			bump days
		move.l		a0,a1

; To calculate the year, continualy subtract the days in a year from the
;days elapsed since 01-Jan-78. If there are less days left than there are in
;a year, the year has been found. Leap years must be accounted for.

		move.l		#1978,d1		set year

.YearLoop	cmp.l		#365,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#365,d0			dec days
		
		cmp.l		#365,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#365,d0			dec days

		cmp.l		#366,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#366,d0			dec days

		cmp.l		#365,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#365,d0			dec days

		bra.s		.YearLoop

; When we get here, d7 will hold the correct year and d0 the number of days
;into the year ... getting closer:

.GotYear	move.w		d1,-(sp)		year onto stack

		lea		DaysInMonth(pc),a0	a0->days array
		move.w		#28,10(a0)		default not leap
		
		divu		#4,d1			year / 4
		swap		d1			get remainder
		tst.w		d1			is leap year?
		bne.s		.MonthLoop		no so skip
		move.w		#29,10(a0)		else feb=29 days

; When we get here, the DaysInMonth will have been set to account for leap
;years which have 29 days in february as opposed to 28 days in a normal year.


.MonthLoop	move.l		a0,d2			addr of month name
		addq.l		#4,a0			bump
		move.w		(a0)+,d1		get days in month

		cmp.w		d1,d0			found month yet?
		ble.s		.GotMonth		yes, exit loop!
		
		sub.w		d1,d0			no, dec days
		bra.s		.MonthLoop		and loop
		
.GotMonth	move.l		d2,-(sp)		addr onto stack
		move.w		d0,-(sp)		days onto stack

		lea		DS_template(pc),a0	C format string
		move.l		a1,a3			output buffer
		move.l		sp,a1			data stream
		lea		.PutC(pc),a2		subroutine
		CALLEXEC	RawDoFmt		build date

		addq.l		#8,sp			flush stack
		movem.l		(sp)+,d0-d4/a0-a4/a6
		rts

; Subroutine called by RawDoFmt()

.PutC		move.b		d0,(a3)+		copy char
		rts

		****************************************

; Convert a date into days since 1st Jan 1978 as would be returned by the DOS
;function DateStamp(). This is the reverse function of my GetDate subroutine.

; Entry		a0->string to convert, must be valid for sensible return.
;		    dd-Mmm-yyyy eg 03-Jan-1991

; Exit		d0=days, 0 => error in date string

GetDays		move.l		d1,-(sp)		save
		move.l		d2,-(sp)
		move.l		a0,-(sp)

		bsr		StrToLong		get day of week
		move.l		d0,d2

		lea		DaysInMonth(pc),a1	a1->month data
		move.b		(a0)+,d0
		asl.w		#8,d0
		move.b		(a0)+,d0
		asl.l		#8,d0
		move.b		(a0)+,d0
		asl.l		#8,d0
		addq.l		#1,a0			step over '-' char
		
		moveq.l		#0,d1
.MonthLoop	cmp.l		(a1)+,d0		this month
		beq.s		.GotMonth		yep, exit loop
		add.w		(a1)+,d1		no, bump counter
		bra.s		.MonthLoop

.GotMonth	add.l		d1,d2
		bsr		StrToLong		get year
		
		sub.w		#1978,d0		no error check!

.YearLoop	tst.w		d0
		beq.s		.GotYear
		
		add.l		#365,d2			bump days
		subq.w		#1,d0
		beq.s		.GotYear		exit if there
		
		add.l		#365,d2			bump days
		subq.w		#1,d0
		beq.s		.GotYear		exit if there

		add.l		#366,d2			bump days (leap year)
		subq.w		#1,d0
		beq.s		.GotYear		exit if there

		add.l		#365,d2			bump days
		subq.w		#1,d0
		bne.s		.YearLoop		loop if not there

.GotYear	move.l		d2,d0			into d0
		
		move.l		(sp)+,a0		restore
		move.l		(sp)+,d2
		move.l		(sp)+,d1
		rts
		
		****************************************

; Entry		a0->string terminated by a char out of range '0' - '9'

; Exit		d0=value or 0 on conversion error
;		a0->byte after end of string

; Corrupt	d0,a0

StrToLong	move.l		d1,-(sp)		save
		move.l		d2,-(sp)

		moveq.l		#0,d0			clear these
		move.l		d0,d1

.CharLoop	move.b		(a0)+,d0
		sub.b		#'0',d0
		bmi.s		.GotWord
		cmpi.b		#10,d0
		bge.s		.GotWord

; Long word multiplication by 10. Faster than mulu and handles bigger numbers

		asl.l		#1,d1			num x2
		move.l		d1,d2
		asl.l		#1,d2			num x4
		add.l		d2,d1
		add.l		d2,d1

		add.l		d0,d1
		bra.s		.CharLoop

.GotWord	move.l		d1,d0
		move.l		(sp)+,d2		restore
		move.l		(sp)+,d1
		rts

		
DaysInMonth	dc.b		'J','a','n',0
		dc.w		31
		dc.b		'F','e','b',0
		dc.w		28
		dc.b		'M','a','r',0
		dc.w		31
		dc.b		'A','p','r',0
		dc.w		30
		dc.b		'M','a','y',0
		dc.w		31
		dc.b		'J','u','n',0
		dc.w		30
		dc.b		'J','u','l',0
		dc.w		31
		dc.b		'A','u','g',0
		dc.w		31
		dc.b		'S','e','p',0
		dc.w		30
		dc.b		'O','c','t',0
		dc.w		31
		dc.b		'N','o','v',0
		dc.w		30
		dc.b		'D','e','c',0
		dc.w		31

DS_template	dc.b		'%02d-%s-%04d',0
		even


; Entry		a0->time string

; Exit		d0=encode value, no error checks!

; Corrupt	d0

GetMins		move.b		(a0),d0
		asl.w		#8,d0
		move.b		1(a0),d0
		swap		d0
		move.b		3(a0),d0
		asl.w		#8,d0
		move.b		4(a0),d0
		
		rts

; Entry		a0->Time Buffer, at least 6 bytes
;		d0=encoded time value generated by GetMins()

; Corrupt	d0


GetTime		move.b		#0,5(a0)
		move.b		d0,4(a0)
		asr.w		#8,d0
		move.b		d0,3(a0)
		move.b		#':',2(a0)
		swap		d0
		move.b		d0,1(a0)
		asr.w		#8,d0
		move.b		d0,(a0)
		
		rts

		****************************************

;		Load & Free all index entries for quick reference.

LoadIndex	PUSHALL

; Allocate memory for the index buffer

		moveq.l		#0,d0
		move.w		OpCount(a5),d0
		beq.s		.done
		mulu		#20,d0
		move.l		#MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,IndexBuffer(a5)
		beq.s		.done
		move.l		d0,a4			a4->dest buffer
		move.w		OpCount(a5),IndexCount(a5)

; Load records in one at a time, necessary for decryption of data, and copy
;QRZ field into buffer.

		move.l		IndexHandle(a5),a3
		move.l		rnd_Buffer(a3),a3	a3->Source Buffer		
		moveq.l		#0,d7
		move.w		IndexCount(a5),d7
		subq.w		#1,d7			dbcc adjusted counter
		moveq.l		#1,d6			record counter

.loop		move.l		d6,d0
		move.l		IndexHandle(a5),a0
		bsr		LoadRecord
		
		move.l		a3,a0

; Convert index to Upper case as we go!

		moveq.l		#19,d1
.loop1		move.b		(a0)+,d0
		cmp.b		#'a',d0
		blt.s		.IsUpper
		cmp.b		#'z',d0
		bgt.s		.IsUpper
		sub.b		#'a'-'A',d0
.IsUpper	move.b		d0,(a4)+
		dbra		d1,.loop1

		addq.l		#1,d6			bump rec number
		dbra		d7,.loop

.done		PULLALL
		rts


FreeIndex	move.l		IndexBuffer(a5),d0
		beq.s		.done
		
		move.l		d0,a1
		moveq.l		#0,d0
		move.w		IndexCount(a5),d0
		mulu		#20,d0
		CALLEXEC	FreeMem

.done		rts

		****************************************

; Entry		a0->Operators call sign to check!

; Exit		d0=Operator ID ( >0 ) or 0 on exit!

; Corrupt	d0

ValidateOp	PUSHALL

		bsr		UCase

		move.l		a0,a3			a3->CALL SIGN
		moveq.l		#1,d6			Init Op ID

		move.l		IndexBuffer(a5),d0
		beq.s		.Manual

; Index buffer exsists, search it for supplied operator

		move.l		d0,a4			a4->Index list
		moveq.l		#0,d7			clear
		move.w		IndexCount(a5),d7
		subq.w		#1,d7			init counter
		
.loop		move.l		a3,a0
		move.l		a4,a1
		bsr		VCheckOp
		tst.l		d0
		bne.s		.Found
		addq.w		#1,d6
		lea		20(a4),a4		a3->next index
		dbra		d7,.loop

; Operator was not found in loaded index list, but might be a new addittion.
;Now need to check any addittional records in Ops.Data file!

.Manual		move.l		OpsHandle(a5),a4
		move.l		rnd_Buffer(a4),a4	a4->buffer

.loop1		move.l		d6,d0			record number
		move.l		OpsHandle(a5),a0	handle
		bsr		LoadRecord		load next
		tst.l		d0
		bne.s		.NotEnd
		move.l		d0,d6
		bra.s		.Found
		
.NotEnd		move.l		a4,a0
		bsr		UCase
		move.l		a3,a0
		move.l		a4,a1
		bsr		VCheckOp
		tst.l		d0
		bne.s		.Found
		addq.w		#1,d6
		bra.s		.loop1

.Found		move.l		d6,d0

.done		PULLALL
		rts


; Entry		a0->Null terminated text
;		a1->buffer of any length, assumed > text

; Exit		d0=0 if no match

; Do not call with a0-> NULL

VCheckOp	movem.l		d1-d2/a0-a1,-(sp)

		moveq.l		#1,d2			assume success

.loop		tst.b		(a0)
		beq.s		.done

		cmp.b		(a0)+,(a1)+
		beq.s		.loop

		moveq.l		#0,d2

.done		move.l		d2,d0
		movem.l		(sp)+,d1-d2/a0-a1
		rts

UCase		move.l		a0,-(sp)
		move.l		d0,-(sp)
		
.loop		move.b		(a0)+,d0
		beq.s		.done
		cmp.b		#'a',d0
		blt.s		.loop
		cmp.b		#'z',d0
		bgt.s		.loop
		sub.b		#'a'-'A',d0
		move.b		d0,-1(a0)
		bra.s		.loop

.done		move.l		(sp)+,d0
		move.l		(sp)+,a0
		rts

*************** Find a given Operator

; Entry		None

; Exit		d0=0 if window would not open

; Corrupt	d0

MOFind		movem.l		d1-d7/a0-a6,-(sp)

; Clear last search string

		lea		LOpGadgSIBuff,a0
		move.b		#0,(a0)

; Open input window

		lea		FindOpWindow,a0		a0->window args
		CALLINT		OpenWindow		and open it
		move.l		d0,tmp.ptr(a5)		save struct ptr
		beq		.error			quit if error

; Extract pointers

		move.l		d0,a0			a0->win struct	
		move.l		wd_UserPort(a0),tmp.up(a5) save up ptr
		move.l		wd_RPort(a0),tmp.rp(a5)    save rp ptr

; Activate the string gadget

		lea		FindOpWindow,a0
		move.l		nw_FirstGadget(a0),a0	a0->Gadget
		move.l		tmp.ptr(a5),a1		a1->Window
		suba.l		a2,a2
		CALLINT		ActivateGadget		Activate
		
; Wait for Key Press

.WaitMsg	move.l		tmp.up(a5),a0		a0->user port
		CALLEXEC	WaitPort		wait for message
		move.l		tmp.up(a5),a0		a0->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.WaitMsg		if not loop back
		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_IAddress(a1),a3	a3->Gadget
		CALLSYS		ReplyMsg		answer os

		cmp.l		#GADGETUP,d2
		bne.s		.WaitMsg

; close the window

		move.l		tmp.ptr(a5),a0
		CALLINT		CloseWindow

; locate the desired operator!

		lea		LOpGadgSIBuff,a0
		bsr		ValidateOp
		tst.l		d0
		bne.s		.Found
		
		lea		NoSuchOpText,a0
		bsr		OKReq
		bra.s		.done

.Found		move.w		d0,OpCur(a5)

		bsr		DisplayOp

.done		moveq.l		#1,d0			no errors

		moveq.l		#0,d2

; And exit!

.error		movem.l		(sp)+,d1-d7/a0-a6
		rts

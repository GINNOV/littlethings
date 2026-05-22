
; Goto line subroutines and data defenitions for PPMuchMore.

; © M.Meany, April 1991

GotoLine	move.l		#0,LineBuffer
		lea		line_window,a0	a0-->window structure
		CALLINT		OpenWindow	open this window
		move.l		d0,line.ptr	save its pointer
		lea		LineWinText,a1	a1-->text structure
		move.l		line.ptr,a0	a0-->window
		move.l		wd_RPort(a0),a0	a0-->Rastport
		moveq.l		#0,d0		x position of text
		moveq		#0,d1		y position of text
		CALLSYS		PrintIText	print the help message
		lea		LineGadg,a0
		move.l		line.ptr,a1
		move.w		#0,a2
		CALLSYS		ActivateGadget

WaitForLine	move.l		line.ptr,a0	a0-->window
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		line.ptr,a0	a0-->window pointer
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForLine	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure
		CALLSYS		ReplyMsg	answer o/s or it gets angry
		cmp.l		#GADGETUP,d2
		bne.s		WaitForLine
		move.l		gg_UserData(a5),a5
		jsr		(a5)
		move.l		line.ptr,a0	a0-->window
		CALLINT		CloseWindow	close this window
		cmp.l		max_top_line(a4),d7
		ble.s		.ok
		move.l		max_top_line(a4),d7
.ok		move.l		d7,top_line(a4)
		bsr		refresh_display
		rts
	
GotLineNum	lea		LineGadgInfo,a5
		move.l		si_LongInt(a5),d7
		bpl.s		ok
NoLineNum	move.l		top_line(a4),d7
ok		rts


; Data for Go To Line window, gadgets and text.
	
line.ptr	dc.l		0

line_window	dc.w		150,90	
		dc.w		279,67		
		dc.b		0,2		
		dc.l		GADGETUP
		dc.l		ACTIVATE		
		dc.l		LineGadg
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.w		5,5		
		dc.w		640,200		
		dc.w		WBENCHSCREEN		

LineGadg	dc.l		LineOKGadg		
		dc.w		120,22		
		dc.w		44,8
		dc.w		0		
		dc.w		RELVERIFY+LONGINT+GADGIMMEDIATE
		dc.w		STRGADGET		
		dc.l		0
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.l		LineGadgInfo		
		dc.w		0		
		dc.l		GotLineNum

LineGadgInfo	dc.l		LineBuffer
		dc.l		0		
		dc.w		0		
		dc.w		5		
		dc.w		0		
		dc.w		0,0,0,0,0		
		dc.l		0		
		dc.l		0		
		dc.l		0		

LineBuffer	dc.b		0,0,0,0,0
		even

LineOKGadg	dc.l		LineCancelGadg		
		dc.w		33,49		
		dc.w		64,12		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		LineOKBorder
		dc.l		0		
		dc.l		LineOKStruct
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		GotLineNum		

LineOKBorder	dc.w		-2,-1		
		dc.b		2,0,RP_JAM1		
		dc.b		5		
		dc.l		LineOKVectors
		dc.l		0		

LineOKVectors	dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0

LineOKStruct	dc.b		1,0,RP_JAM2,0		
		dc.w		24,3		
		dc.l		0		
		dc.l		LineOKText	
		dc.l		0		

LineOKText	dc.b		'OK',0
		even

LineCancelGadg	dc.l		0		
		dc.w		180,49		
		dc.w		64,12		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		LineCancelBorder
		dc.l		0		
		dc.l		LineCancelStruct
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		NoLineNum

LineCancelBorder dc.w		-2,-1		
		dc.b		2,0,RP_JAM1		
		dc.b		5		
		dc.l		LineCancelVectors
		dc.l		0		

LineCancelVectors dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0

LineCancelStruct dc.b		1,0,RP_JAM2,0		
		dc.w		8,3		
		dc.l		0		
		dc.l		LineCancelText
		dc.l		0		

LineCancelText	dc.b		'CANCEL',0
		even

LineWinText	dc.b		1,0,RP_JAM2,0		
		dc.w		15,23		
		dc.l		0		
		dc.l		LineWinTextStr	
		dc.l		0		

LineWinTextStr	dc.b		'GO TO LINE :',0
		even


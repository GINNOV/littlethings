; Data for Go To Line window, gadgets and text.
	
line_window	dc.w		150,90	
		dc.w		279,67		
		dc.b		0,3		
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
		dc.w		RELVERIFY+LONGINT
		dc.w		STRGADGET		
		dc.l		LineGadgBorder
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

LineGadgBorder	dc.w		-2,-1		
		dc.b		3,0,RP_JAM1		
		dc.b		5		
		dc.l		LineGadgVectors
		dc.l		0		

LineGadgVectors	dc.w		0,0
		dc.w		47,0
		dc.w		47,9
		dc.w		0,9
		dc.w		0,0

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
		dc.b		3,0,RP_JAM1		
		dc.b		5		
		dc.l		LineOKVectors
		dc.l		0		

LineOKVectors	dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0

LineOKStruct	dc.b		3,0,RP_JAM2,0		
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
		dc.b		3,0,RP_JAM1		
		dc.b		5		
		dc.l		LineCancelVectors
		dc.l		0		

LineCancelVectors dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0

LineCancelStruct dc.b		3,0,RP_JAM2,0		
		dc.w		8,3		
		dc.l		0		
		dc.l		LineCancelText
		dc.l		0		

LineCancelText	dc.b		'CANCEL',0
		even

LineWinText	dc.b		3,0,RP_JAM2,0		
		dc.w		15,23		
		dc.l		0		
		dc.l		LineWinTextStr	
		dc.l		0		

LineWinTextStr	dc.b		'GO TO LINE :',0
		even

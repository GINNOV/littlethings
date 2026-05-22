AsmP_window	dc.w		150,90	
		dc.w		279,67		
		dc.b		0,3		
		dc.l		GADGETUP
		dc.l		ACTIVATE		
		dc.l		AsmPGadg
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.w		5,5		
		dc.w		640,200		
		dc.w		WBENCHSCREEN		

AsmPGadg	dc.l		AsmPOKGadg		
		dc.w		120,22		
		dc.w		120,8
		dc.w		0		
		dc.w		RELVERIFY
		dc.w		STRGADGET		
		dc.l		AsmPGadgBorder
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.l		AsmPGadgInfo		
		dc.w		0		
		dc.l		GotAsmPName

AsmPGadgInfo	dc.l		AsmPBuffer
		dc.l		0		
		dc.w		0		
		dc.w		32		
		dc.w		0		
		dc.w		0,0,0,0,0		
		dc.l		0		
		dc.l		0		
		dc.l		0		

AsmPGadgBorder	dc.w		-2,-1		
		dc.b		3,0,RP_JAM1		
		dc.b		5		
		dc.l		AsmPGadgVectors
		dc.l		0		

AsmPGadgVectors	dc.w		0,0
		dc.w		125,0
		dc.w		125,9
		dc.w		0,9
		dc.w		0,0

AsmPOKGadg	dc.l		AsmPCancelGadg		
		dc.w		33,49		
		dc.w		64,12		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		AsmPOKBorder
		dc.l		0		
		dc.l		AsmPOKStruct
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		GotAsmPName		

AsmPOKBorder	dc.w		-2,-1		
		dc.b		3,0,RP_JAM1		
		dc.b		5		
		dc.l		AsmPOKVectors
		dc.l		0		

AsmPOKVectors	dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0

AsmPOKStruct	dc.b		3,0,RP_JAM2,0		
		dc.w		22,3		
		dc.l		0		
		dc.l		AsmPOKText	
		dc.l		0		

AsmPOKText	dc.b		'OK',0
		even

AsmPCancelGadg	dc.l		0		
		dc.w		180,49		
		dc.w		64,12		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		AsmPCancelBorder
		dc.l		0		
		dc.l		AsmPCancelStruct
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		NoAsmPName

AsmPCancelBorder dc.w		-2,-1		
		dc.b		3,0,RP_JAM1		
		dc.b		5		
		dc.l		AsmPCancelVectors
		dc.l		0		

AsmPCancelVectors dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0

AsmPCancelStruct dc.b		3,0,RP_JAM2,0		
		dc.w		4,3		
		dc.l		0		
		dc.l		AsmPCancelText
		dc.l		0		

AsmPCancelText	dc.b		'DEFAULT',0
		even

AsmPWinText	dc.b		3,0,RP_JAM2,0		
		dc.w		15,23		
		dc.l		0		
		dc.l		AsmPWinTextStr	
		dc.l		AsmPWinText1		

AsmPWinTextStr	dc.b		'FILE NAME  :',0
		even

AsmPWinText1	dc.b		3,0,RP_JAM2,0		
		dc.w		20
plc1		dc.w		5		
		dc.l		0		
plc2		dc.l		AsmPWinText1Str	
		dc.l		0		

AsmPWinText1Str	dc.b		'Assembly Output File Name',0
		even

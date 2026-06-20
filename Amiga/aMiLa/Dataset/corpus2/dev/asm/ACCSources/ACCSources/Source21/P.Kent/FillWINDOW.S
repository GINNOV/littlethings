;This code fragment provides a few routines for
;selectively filling/wiping areas of a screen, given
;a list of coordinates.
;SetMinMax - Finds tyhe coordinates of the 'edge' of the drawing window
;   DoFIll - Fills the area of screen given by the mins/maxs
;  WipeOld - Wipes area of screen previously drawn on

;>>>>>THIS IS NOT A STAND ALONE PIECE OF CODE & HAS NOT BEEN DEBUGGED<<<<<

ENDSIG = $8000				;List terminator

; Find min/max coords
SetMinMax
	LEA	DestCoords,A5		;List of x,y cooridnate pairs
	MOVE.W	#0,D2			;Some initial mins/maxs
	MOVE.W	#1000,D3
	MOVE.W	#0,D4
	MOVE.W	#1000,D5
MM_lp	MOVE.W	(A5)+,D1
	MOVE.W	(A5)+,D0
	CMP.W	D2,D0
	BLE.S	MM_NMAXY
	MOVE.W	D0,D2
MM_NMAXY	CMP.W	D3,D0
	BGT.S	MM_NMINY
	MOVE.W	D0,D3
MM_NMINY	CMP.W	D4,D1
	BLE.S	MM_NMAXX
	MOVE.W	D1,D4
MM_NMAXX	CMP.W	D5,D1
	BGT.S	MM_NMINX
	MOVE.W	D1,D5
MM_NMINX	CMP.W	#ENDSIG,(A5)	;List is terminated with the constant
	BNE.S	MM_lp					;ENDSIG
	
; No check mins/maxs in draw window...
	TST.W	D3
	BPL.S	MMW_1
	MOVE.W	#0,D3
MMW_1	TST.W	D5
	BPL.S	MMW_2
	MOVE.W	#0,D5
MMW_2	CMP.W	#(PLWIDB*8)-1,D4	;Right hand pixel coordinate
	BLS.S	MMW_3
	MOVE.W	#(PLWIDB*8)-1,D4
MMW_3	CMP.W	#PLHGT-1,D2			;Bottom pixel coordinate
	BLS.S	MMW_4
	MOVE.W	#PLHGT-1,D2
MMW_4
	MOVE.W	D2,MaxY
	MOVE.W	D3,MinY
	MOVE.W	D4,MaxX
	MOVE.W	D5,MinX
	RTS	
 
DoFill
	MOVE.W	MaxY,D0
	MOVE.W	D0,D1
	SUB.W	MinY,D1
	BCC.S	DF_HgtOK
	MOVEQ.L	#2,D1
DF_HgtOK
	MULU	#PLWIDB*NPL,D0	; Vertical start offset... 
	MULU	#NPL,D1
	LSL.W	#6,D1			; Build up bltsize...
	MOVE.W	MaxX,D2
	MOVE.W	MinX,D3
	MOVEQ.L	#PLWIDB,D5
	MOVE.W	D2,D4
	SUB.W	D3,D4			; d4=xmax-xmin
	BCC.S	DF_WidOK
	MOVEQ.L	#1,D4			; set minimum
DF_WidOK
	LSR.W	#4,D4			; d4=words width
	ADDQ.W	#2,D4			; d4=ww+2
	LSR.W	#3,D2	
	MOVE.W	D2,D7
	LSR.W	#1,D7
	SUB.W	D4,D7
	BCC.S	DF_PosOK
	NEG.W	D7	
	ADD.W	D7,D7
	ADD.W	D7,D2
	ADDQ.W	#1,D4
DF_PosOK
	ADD.W	D2,D0			; Add to draw offset
	ADD.W	D4,D1
	ADD.W	D4,D4
	SUB.W	D4,D5			; Modulo
	MOVE.L	DrawOffset,OldDrawOffset
	MOVE.L	D0,DrawOffset
	ADD.L	DrawPtr,D0
	ADD.W	#$0040,D1
	CMP.W	#$0041,D1
	BHI.S	DF_1
	MOVE.W	#$0041,D1
DF_1
	BLITWAIT	A6
	MOVE.L	D0,bltapth(A6)
	MOVE.L	D0,bltdpth(A6)
	MOVE.W	D5,bltamod(A6)
	MOVE.W	D5,bltdmod(A6)
	MOVE.L	#$09F00012,bltcon0(A6)
	MOVE.W	D1,bltsize(A6)
	MOVE.W	FillModulo,OldFillModulo
	MOVE.W	BlitSize,OldBlitSize
	MOVE.W	D5,FillModulo
	ADD.W	#$0080,D1
	MOVE.W	D1,BlitSize
	RTS	

WipeOld
	BLITWAIT	A6
	MOVE.L	DrawPtr,D0
	ADD.L	OldDrawOffset,D0
	MOVE.L	D0,bltdpth(A6)
	MOVE.W	OldFillModulo,bltdmod(A6)
	MOVE.L	#$01000002,bltcon0(A6)
	MOVE.W	OldBlitSize,D0
	CMP.W	#$0041,D0
	BHI.S	WO_Size
	MOVE.W	#$0041,D0
Wo_Size
	MOVE.W	D0,bltsize(A6)
	RTS
	 
MaxY	dc.w	0				;Coordinate stores
MinY	dc.w	0
MaxX	dc.w	0
MinX	dc.w	0

OldDrawOffset	dc.l	0		;Old vars for subsequent wipe(old)
OldFillModulo	dc.w	0
OldBlitSize		dc.w	0

DrawOffset	dc.l	0			;Current vars for current fill operation
FillModulo	dc.w	0
BlitSize	dc.w	0


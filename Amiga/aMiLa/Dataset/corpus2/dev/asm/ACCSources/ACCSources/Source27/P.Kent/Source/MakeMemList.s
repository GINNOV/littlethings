	OPT	C-,O+
;Make a memlist: format as per Pkdos file!
;NB not checked with more than one chunk of FAST memory!

	LEA	MEML(PC),A5					; Base address for my Memlist
	BSR.S DoMemLists
	RTS
 
DoMemLists
	MOVE.W	#(8*4)-1,D0				; Wipe listing...
	MOVE.L	A5,A0
DML_Clear	CLR.L	(A0)+
	DBRA	D0,DML_Clear

	MOVE.L	A5,A1
; Get CHIP mem...
	MOVEQ.L	#1,D0					; CHIP
	BSR.S	SearchMem
	MOVE.L	#'RAMC',(A1)+
	MOVE.L	D1,(A1)+				; Save start,length
	MOVE.L	D2,(A1)+
	CLR.L	(A1)+

	MOVEQ.L	#7,D7					; Get up to n chunks of memory

	MOVEQ.L	#2,D0					; FAST
	BSR.S	SearchMem
DML_Retry	BEQ.S	DML_Done
	CMP.L	#$C00000,D1				; Slow fast ?
	BCC.S	DML_HaveFAST

	MOVE.L	#'RAMP',(A1)+
DML_PutInfo
	MOVE.L	D1,(A1)+
	MOVE.L	D2,(A1)+
	CLR.L	(A1)+
DML_Again
	SUBQ.W	#1,D7
	BMI.S	DML_Done
	BSR.S	Sm_lp					; Get next memory entry...
	BRA.S	DML_Retry
 
DML_Done	RTS	
 
DML_HaveFAST
	MOVE.L	#'RAMF',(A1)+
	BRA.S	DML_PutInfo
 
SearchMem
	MOVE.L	4.W,A0					; Get exec
	MOVE.L	$142(A0),A0				; Get listing
Sm_lp	TST.L	(A0)
	BEQ.S	Sm_Fin					; End of chain ?
	MOVE.W	14(A0),D1
	BTST	D0,D1
	BEQ.S	Sm_next					; Is there a match of memory types?
	MOVE.L	20(A0),D1
	CLR.W	D1
	MOVE.L	24(A0),D2
	ADD.L	#$FFFF,D2				; Mask get real length etc
	CLR.W	D2
	SUB.L	D1,D2
	MOVE.L	(A0),A0
Sm_Fin	RTS	
Sm_next
	MOVE.L	(A0),A0					; Get next entry
	BRA.S	Sm_lp
MEML	DS.L	4*(1+8)
		DC.L	0

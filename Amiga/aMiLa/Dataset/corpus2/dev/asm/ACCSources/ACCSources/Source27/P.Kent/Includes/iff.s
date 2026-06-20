;IFF File processor code:
;Interleaved loader :-)

;ASSUMPTIONS:
;-File structure isnt mangled in any way.
;-Palette comes before body chunk
;-NB Masks/Stencils may confuse loader!
;-Dest memory if big enough!
;
;'Straight' DPAINT saves work, and thats all I need...
;
;a0 = IFF data  
;a1 = Dest addr if NZ
;a2 = Palette buf if NZ
;Returns D0=Length else =0 : no bmhd

;This code is mostly from a disk called 'DYNAX SOURCE'(?) : no author
;was given.

ProcessIFF
	MOVEM.L	D1-D7/A0-A6,-(A7)
	LINK	A6,#-PI_VarLen

	CLR.L	L.Piclen(A6)

	LEA	12(A0),A0
PI_mlp
	MOVE.L	(A0)+,D0
	CMP.L	#'BODY',D0
	BEQ.S	PI_DecodeBODY
	CMP.L	#'CMAP',D0
	BEQ.S	PI_DecodePal
	CMP.L	#'BMHD',D0
	BEQ.S	PI_DecodeBMH
PI_Next
	ADD.L	(A0)+,A0
	Bra.S	PI_mlp
PI_DoneIt
	MOVE.L	L.PicLen(A6),d0
	UNLK	A6
	MOVEM.L	(A7)+,D1-D7/A0-A6
	RTS	 

PI_DecodePal
	MOVE.L	A2,D0					; If no ptr, skip
	BEQ.s	PI_Next

	LEA	4(A0),A3
	MOVE.L	(A0),D0					; No. of triplets
	DIVU	#3,D0
	SUBQ.W	#1,D0					; no.cols-1 for dbra
PI_Dplp
	MOVEQ.L	#0,D1
	MOVE.B	(A3)+,D1
	ROL.W	#4,D1
	MOVE.B	(A3)+,D1
	MOVE.B	(A3)+,D2
	LSR.B	#4,D2
	OR.B	D2,D1
	MOVE.W	D1,(A2)+
	DBRA	D0,PI_Dplp
	BRA.S	PI_Next
 
PI_DecodeBODY
	ADDQ.L	#4,A0
	MOVE.L	A1,D0
	BEQ.S	PI_DoneIt
	MOVE.L	L.PICHGT(A6),D7
PI_loop1
	MOVE.L	L.PICPLANES(A6),D6
PI_loop2
	MOVE.L	L.PICBWID(A6),D5
PI_loop3

	MOVEQ.L	#0,D0
	MOVE.B	(A0)+,D0
	BPL.S	PI_AltBytes
	NEG.B	D0
	BMI.S	PI_loop3
	SUB.B	D0,D5
	SUBQ.B	#1,D5
	MOVE.B	(A0)+,D1
PI_ReptBytes
	MOVE.B	D1,(A1)+
	DBRA	D0,PI_ReptBytes
	BRA.S	chkcount
 
PI_AltBytes
	SUB.B	D0,D5
	SUBQ.B	#1,D5
PI_AltByteslp
	MOVE.B	(A0)+,(A1)+
	DBRA	D0,PI_AltByteslp
chkcount
	TST.B	D5
	BNE.S	PI_loop3
	DBRA	D6,PI_loop2
	DBRA	D7,PI_loop1
	BRA.S	PI_DoneIt


PI_DecodeBMH 
;Sets variables for main loader routine ;
; also sets bitmap length
;(nb gets ACTUAL not SCREEN sizes)
	moveq	#0,d0
	move.w	4(a0),d0				; Pixel width
	LSR.W	#3,D0
	MOVE.L	D0,L.PicBWid(A6)
	move.w	6(a0),d0				; Pixel height
	SUBQ.W	#1,D0
	MOVE.L	D0,L.PicHgt(A6)
	MOVEQ	#0,D0
	move.b  12(a0),d0				; Planes
	subq.b	#1,d0
	move.l	d0,L.PicPlanes(A6)

	MOVE.L	L.PicBwid(A6),d1
	MOVE.L	L.PicPlanes(A6),d0
	addq.l	#1,d0
	MULU	D0,D1

	MOVEQ	#0,D7
	MOVE.L	L.PicHgt(A6),d0
PI_DBMHlp
	ADD.L	D1,D7
	DBRA	D0,PI_DBMHlp
	MOVE.L	D7,L.PicLen(A6)
	bra	PI_next

;Stack offsets : there must be a neater way to do this!
L.PicHgt	=		-4
L.PicBwid	=		-8
L.PicPlanes	=		-12
L.PicLen	=		-16
PI_VarLen	=		16

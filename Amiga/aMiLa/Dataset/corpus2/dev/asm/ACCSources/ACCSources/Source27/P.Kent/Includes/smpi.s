*SMPI CODE!
*USES SCRUNCH SPECIAL HEADER TO DO ITS STUFF!
*
*INITSMPI - initialise/reset
*KILLSMPI - close down
*SMPIVBI - Every frame
*PLAYSMPI(a0 : smpi (CHIP mem!) ) Play it! With pri/vol etc
*PLAYSND (a0 : smpi,d0 : channel 0-3) Play : VBI not reqd!

ac_ptr	EQU	0
ac_len	EQU	4
ac_per	EQU	6
ac_vol	EQU	8

	rsreset
smpi_len	rs.w	1
smpi_per	rs.w	1
smpi_vol	rs.w	1
smpi_rept	rs.w	1
smpi_time	rs.w	1
smpi_cut	rs.w	1
smpi_pri	rs.w	1
smpi_sample	rs.w	1

SMPIVARS	MACRO

L.CH0PTR	RS.L	1			; Ptr to channel 1 code
W.CH0TIME	RS.W	1			; VBLs since launch
L.CH1PTR	RS.L	1			; Ptr to channel 1 code
W.CH1TIME	RS.W	1			; VBLs since launch
L.CH2PTR	RS.L	1			; Ptr to channel 1 code
W.CH2TIME	RS.W	1			; VBLs since launch
L.CH3PTR	RS.L	1			; Ptr to channel 1 code
W.CH3TIME	RS.W	1			; VBLs since launch
		ENDM

InitSmpi	;Reset sound ptrs, kill sound dma
	MOVEQ	#0,D0
	MOVE.L	D0,L.CH0PTR(A5)
	MOVE.W	D0,W.CH0TIME(A5)
	MOVE.L	D0,L.CH1PTR(A5)
	MOVE.W	D0,W.CH1TIME(A5)
	MOVE.L	D0,L.CH2PTR(A5)
	MOVE.W	D0,W.CH2TIME(A5)
	MOVE.L	D0,L.CH3PTR(A5)
	MOVE.W	D0,W.CH3TIME(A5)
KillSmpi
	MOVEQ	#0,D0
	MOVE.W	D0,ac_vol+$A0(a6)
	MOVE.W	D0,ac_vol+$B0(a6)
	MOVE.W	D0,ac_vol+$C0(a6)
	MOVE.W	D0,ac_vol+$D0(a6)
	MOVE.W	#AUD0EN!AUD1EN!AUD2EN!AUD3EN,DMACON(A6)
	RTS

PlaySmpi	;a0 is smpi (CHIP MEM) ptr
	movem.l a1/a2/d0/d1,-(a7)
	bsr.s	PSblip
	movem.l	(a7)+,a1/a2/d0/d1
	rts
PSblip
;Look for a free channel..
	TST.L	L.CH0PTR(A5)
	BNE.S	PSmpiNGot0				; <<<
	MOVE.L	A0,L.CH0PTR(A5)
	CLR.W	W.CH0TIME(A5)
	RTS
PSmpiNGot0
	TST.L	L.CH1PTR(A5)
	BNE.S	PSmpiNGot1
	MOVE.L	A0,L.CH1PTR(A5)
	CLR.W	W.CH1TIME(A5)
	RTS
PSmpiNGot1
	TST.L	L.CH2PTR(A5)
	BNE.S	PSmpiNGot2
	MOVE.L	A0,L.CH2PTR(A5)
	CLR.W	W.CH2TIME(A5)
	RTS
PSmpiNGot2
	TST.L	L.CH3PTR(A5)
	BNE.S	PSmpiNGot3
	MOVE.L	A0,L.CH3PTR(A5)
	CLR.W	W.CH3TIME(A5)
	RTS
PSmpiNGot3

;Look for channel past cutoff point

	MOVE.L	L.CH0PTR(A5),A1
	MOVE.W	smpi_cut(a1),d0
	CMP.W	W.CH0Time(a5),d0
	BPL.s	PSmpiNCut0				; Past cut off point ?
	MOVE.W	#AUD0EN,dmacon(a6)		; Kill it now!
	MOVE.L	A0,L.CH0PTR(A5)			; Put in and clear timer
	CLR.W	W.CH0TIME(A5)
	RTS
PSmpinCut0
	MOVE.L	L.CH1PTR(A5),A1
	MOVE.W	smpi_cut(a1),d0
	CMP.W	W.CH1Time(a5),d0
	BPL.s	PSmpiNCut1				; Past cut off point ?
	MOVE.W	#AUD1EN,dmacon(a6)		; Kill it now!
	MOVE.L	A0,L.CH1PTR(A5)			; Put in and clear timer
	CLR.W	W.CH1TIME(A5)
	RTS
PSmpinCut1
	MOVE.L	L.CH2PTR(A5),A1
	MOVE.W	smpi_cut(a1),d0
	CMP.W	W.CH2Time(a5),d0
	BPL.s	PSmpiNCut2				; Past cut off point ?
	MOVE.W	#AUD2EN,dmacon(a6)		; Kill it now!
	MOVE.L	A0,L.CH2PTR(A5)			; Put in and clear timer
	CLR.W	W.CH2TIME(A5)
	RTS
PSmpinCut2
	MOVE.L	L.CH3PTR(A5),A1
	MOVE.W	smpi_cut(a1),d0			; end
	CMP.W	W.CH3Time(a5),d0		; cur > end ?
	BPL.s	PSmpiNCut3				; Past cut off point ?
	MOVE.W	#AUD3EN,dmacon(a6)		; Kill it now!
	MOVE.L	A0,L.CH3PTR(A5)			; Put in and clear timer
	CLR.W	W.CH3TIME(A5)
	RTS
PSmpinCut3
;Look for lowest pri sound to override...
	moveq	#0,d0
	MOVE.L	l.ch0ptr(A5),A1
	MOVE.W	Smpi_pri(a1),d1			; 1

	MOVE.L	l.ch1ptr(A5),A2
	CMP.W	Smpi_pri(a2),d1			; 2 > 1
	BMI.S	PSmpPriN1
	MOVEQ	#1,d0
	MOVE.W	smpi_pri(a2),d1
PsmpPriN1	
	MOVE.L	l.ch2ptr(A5),A2
	CMP.W	Smpi_pri(a2),d1			; 2 > 1
	BMI.S	PSmpPriN2
	MOVEQ	#2,d0
	MOVE.W	smpi_pri(a2),d1
PsmpPriN2	
	MOVE.L	l.ch3ptr(A5),A2
	CMP.W	Smpi_pri(a2),d1			; 2 > 1
	BMI.S	PSmpPriN3
	MOVEQ	#3,d0
	MOVE.W	smpi_pri(a2),d1
PsmpPriN3
	CMP.W	smpi_pri(a0),d1
	BMI.S	PsmpPriNFail				; New sample pri must be higher...
	RTS

PsmpPriNFail	
	CMP.B	#0,D0
	BNE.S	PSmpPriNC0
	MOVE.W	#AUD0EN,dmacon(a6)		; Kill it now!
	MOVE.L	A0,L.CH0PTR(A5)			; Put in and clear timer
	CLR.W	W.CH0TIME(A5)
	RTS
PSmpPriNC0
	CMP.B	#1,D0
	BNE.S	PSmpPriNC1
	MOVE.W	#AUD1EN,dmacon(a6)		; Kill it now!
	MOVE.L	A0,L.CH1PTR(A5)			; Put in and clear timer
	CLR.W	W.CH1TIME(A5)
	RTS
PSmpPriNC1
	CMP.B	#2,D0
	BNE.S	PSmpPriNC2
	MOVE.W	#AUD2EN,dmacon(a6)		; Kill it now!
	MOVE.L	A0,L.CH2PTR(A5)			; Put in and clear timer
	CLR.W	W.CH2TIME(A5)
	RTS
PSmpPriNC2
;must be channel 3
	MOVE.W	#AUD3EN,dmacon(a6)		; Kill it now!
	MOVE.L	A0,L.CH3PTR(A5)			; Put in and clear timer
	CLR.W	W.CH3TIME(A5)
	RTS
	


SmpiVBI
;For every active sound, check to see if end+add to count
;Channel0
	MOVE.L	L.CH0PTR(A5),D0
	BEQ.S	PVBI_N0
	MOVE.L	D0,A0
	TST.W	w.ch0time(A5)			; Count ?
	BNE.S	PVBI_N0FIRST
;First time!
	MOVE.W	#AUD0EN,dmacon(a6)		; Kill channel
	LEA	Smpi_sample(a0),a1
	MOVE.L	a1,ac_ptr+$A0(A6)
	MOVE.W	smpi_len(a0),ac_len+$A0(A6)
	MOVE.W	smpi_per(a0),ac_per+$A0(A6)
	MOVE.W	smpi_vol(a0),ac_vol+$A0(A6)
	MOVE.W	#SETIT!DMAEN!AUD0EN,dmacon(a6)
PVBI_N0FIRST
	ADDQ.W	#1,w.ch0time(A5)		; Add to count
	MOVE.W	W.CH0TIME(A5),D0
	CMP.W	smpi_time(a0),D0
	BNE.S	PVBI_N0
;Sound is finished! Kill DMA on channel!
	MOVE.W	#AUD0EN,dmacon(a6)
	CLR.L	L.CH0PTR(A5)			; Kill ptr
PVBI_N0

;Channel1
	MOVE.L	L.CH1PTR(A5),D0
	BEQ.S	PVBI_N1
	MOVE.L	D0,A0
	TST.W	w.ch1time(A5)			; Count ?
	BNE.S	PVBI_N1FIRST
;First time!
	MOVE.W	#AUD1EN,dmacon(a6)		; Kill channel
	LEA	Smpi_sample(a0),a1
	MOVE.L	a1,ac_ptr+$B0(A6)
	MOVE.W	smpi_len(a0),ac_len+$B0(A6)
	MOVE.W	smpi_per(a0),ac_per+$B0(A6)
	MOVE.W	smpi_vol(a0),ac_vol+$B0(A6)
	MOVE.W	#SETIT!DMAEN!AUD1EN,dmacon(a6)
PVBI_N1FIRST
	ADDQ.W	#1,w.ch1time(A5)		; Add to count
	MOVE.W	W.CH1TIME(A5),D0
	CMP.W	smpi_time(a0),D0
	BNE.S	PVBI_N1
;Sound is finished! Kill DMA on channel!
	MOVE.W	#AUD1EN,dmacon(a6)
	CLR.L	L.CH1PTR(A5)			; Kill ptr
PVBI_N1

;Channel2
	MOVE.L	L.CH2PTR(A5),D0
	BEQ.S	PVBI_N2
	MOVE.L	D0,A0
	TST.W	w.ch2time(A5)			; Count ?
	BNE.S	PVBI_N2FIRST
;First time!
	MOVE.W	#AUD2EN,dmacon(a6)		; Kill channel
	LEA	Smpi_sample(a0),a1
	MOVE.L	a1,ac_ptr+$C0(A6)
	MOVE.W	smpi_len(a0),ac_len+$C0(A6)
	MOVE.W	smpi_per(a0),ac_per+$C0(A6)
	MOVE.W	smpi_vol(a0),ac_vol+$C0(A6)
	MOVE.W	#SETIT!DMAEN!AUD2EN,dmacon(a6)
PVBI_N2FIRST
	ADDQ.W	#1,w.ch2time(A5)		; Add to count
	MOVE.W	W.CH2TIME(A5),D0
	CMP.W	smpi_time(a0),D0
	BNE.S	PVBI_N2
;Sound is finished! Kill DMA on channel!
	MOVE.W	#AUD2EN,dmacon(a6)
	CLR.L	L.CH2PTR(A5)			; Kill ptr
PVBI_N2
;Channel3
	MOVE.L	L.CH3PTR(A5),D0
	BEQ.S	PVBI_N3
	MOVE.L	D0,A0
	TST.W	w.ch3time(A5)			; Count ?
	BNE.S	PVBI_N3FIRST
;First time!
	MOVE.W	#AUD3EN,dmacon(a6)		; Kill channel
	LEA	Smpi_sample(a0),a1
	MOVE.L	a1,ac_ptr+$D0(A6)
	MOVE.W	smpi_len(a0),ac_len+$D0(A6)
	MOVE.W	smpi_per(a0),ac_per+$D0(A6)
	MOVE.W	smpi_vol(a0),ac_vol+$D0(A6)
	MOVE.W	#SETIT!DMAEN!AUD3EN,dmacon(a6)
PVBI_N3FIRST
	ADDQ.W	#1,w.ch3time(A5)		; Add to count
	MOVE.W	W.CH3TIME(A5),D0
	CMP.W	smpi_time(a0),D0
	BNE.S	PVBI_N3
;Sound is finished! Kill DMA on channel!
	MOVE.W	#AUD3EN,dmacon(a6)
	CLR.L	L.CH3PTR(A5)			; Kill ptr
PVBI_N3
	RTS


PlaySnd
;PLAYS AN SMPI SOUND: INTERRUPT VBI ROUTINE *NOT* USED
;A0=SMPI
;D0=CHAN (0-3)
;A6=CUSTOM $DFF000
	MOVE.W	D0,D1
	LSL.W	#4,D1
	LEA	(A6,D1.W),A2
	LEA	$A0(A2),A2

	move.w	d0,d1
	addq.w	#7,d1
	moveq	#0,d2
	bset	d1,d2
	MOVE.W	d2,intreq(A6)

	LEA	Smpi_sample(a0),a1
	MOVE.L	a1,ac_ptr(A2)
	MOVE.W	smpi_len(a0),ac_len(A2)
	MOVE.W	smpi_per(a0),ac_per(A2)
	MOVE.W	smpi_vol(a0),ac_vol(A2)
	MOVE.W	#$8200,d1
	BSET	D0,D1
	MOVE.W	D1,dmacon(A6)			;Enable sound

PS_lp1
	MOVE.W	intreqr(A6),D0
	AND.W	d2,D0
	BEQ.S	PS_lp1
	MOVE.W	d2,intreq(A6)

	MOVE.L	#BlankSample,ac_ptr(A2)
	MOVE.W	#2,ac_len(A5)

PS_lp2	MOVE.W	intreqr(A6),D0
	AND.W	d2,D0
	BEQ.S	PS_lp2
	MOVE.W	d2,intreq(A6)

	CLR.W	ac_vol(A2)
	AND.W	#$000F,D1
	MOVE.W	D1,dmacon(A6)
	RTS	

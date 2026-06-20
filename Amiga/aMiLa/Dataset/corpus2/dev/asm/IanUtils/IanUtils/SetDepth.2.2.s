	BRA.S	SetDepth

	Include	Libs/Exec.lib
	Include	Libs/Dos.lib
	Include	Libs/Intuition.lib
	Include	Libs/Graphics.lib

SetDepth	MOVEM.L	D2-D7/A2-A6,-(A7)	; Save registers

	MOVE.L	A0,A3	; Save argument information
	LEA	(A0,D0),A4

	OpenLib	Dos	; Open Libraries
	OpenLib	Graphics
	OpenLib	Intuition

	SUB.L	#Space,A7	; Set up data area
	MOVE.L	A7,A5

	BSR	Initialize
	BSR	Arguments
	BSR	ChangeDepth

Exit	CloseLib	Intuition	; Close libraries
	CloseLib	Graphics
	CloseLib	Dos

	MOVE.L	A5,A7	; Nuke data area
	ADD.L	#Space,A7

	MOVE.L	RC(A5),D0
	MOVEM.L	(A7)+,D2-D7/A2-A6	; Restore registers
	RTS

Initialize	MOVE.L	A3,ArgList(A5)	; Save argument information
	MOVE.L	A4,ArgEnd(A5)
	CLR.L	RC(A5)

	Dos	Output		; Get Standard Output Channel
	MOVE.L	D0,StdOutput(A5)

	Dos	Input
	MOVE.L	D0,StdInput(A5)

	CLR.W	WhatDepth(A5)	; Set WhatDepth to zero
	CLR.B	WhatScreen(A5)	; Set WhatScreen to WB Screen as default
	CLR.L	WaitSecs(A5)		; Set Wait delay to no wait

	RTS

;-----------------------------------------------------------------------

Arguments	MOVE.L	ArgList(A5),A0
	CMP.B	#10,(A0)	; Is input just a return?
	BEQ	DispInfo

	CMP.B	#"?",(A0)	; Is input a question mark?
	BNE.S	Not.QM
	CMP.B	#" ",1(A0)
	BLE	Input	; If space/tab/return, show template

Not.QM	MOVE.L	ArgEnd(A5),A1
	BSR	Capitalize

Check	MOVE.L	ArgList(A5),A0

CheckNext

CheckNum	CMP.B	#"0",(A0)
	BLT.S	Not.Num
	CMP.B	#"9",(A0)
	BGT.S	Not.Num
	BSR	GetDec
	CMP.L	#8,D0
	BHI	BadDepth
	TST.L	D0
	BEQ	BadDepth
	MOVE.W	D0,WhatDepth(A5)
	BRA.S	NextArg
Not.Num

CheckWB	LEA	keyWB(PC),A1
	BSR	Keyword
	TST.L	D0
	BEQ.S	Not.WB
	CMP.B	#" ",(A0)
	BGT.S	Not.WB
	CLR.B	WhatScreen(A5)	; Set WhatScreen to 0
	BRA.S	NextArg
Not.WB

CheckFRONT	LEA	keyFRONT(PC),A1
	BSR	Keyword
	TST.L	D0
	BEQ.S	Not.FRONT
	CMP.B	#" ",(A0)
	BGT.S	Not.FRONT
	MOVE.B	#-1,WhatScreen(A5)	; Set WhatScreen to 1
	BRA.S	NextArg
Not.FRONT

CheckACTIVE	LEA	keyACTIVE(PC),A1
	BSR	Keyword
	TST.L	D0
	BEQ.S	Not.ACTIVE
	CMP.B	#" ",(A0)
	BGT.S	Not.ACTIVE
	MOVE.B	#1,WhatScreen(A5)	; Set WhatScreen to 1
	BRA.S	NextArg
Not.ACTIVE	

CheckWAIT	LEA	keyWAIT(PC),A1
	BSR	Keyword
	TST.L	D0
	BEQ.S	Not.WAIT
	BSR	GetDec
	MOVE.L	D0,WaitSecs(A5)	; Set WaitSecs to WAIT=n value
;	BRA.S	NextArg
Not.WAIT

FindEnd	CMP.B	#" ",(A0)
	BLE.S	NextArg
	TST.B	(A0)+
	BRA.S	FindEnd

NextArg	CMP.B	#" ",(A0)
	BGT	CheckNext	; If a valid character, proceed
	BLT.S	NoMoreArgs	; If a return ($0A) encountered
	TST.B	(A0)+
	BRA.S	NextArg
NoMoreArgs	RTS
	
;-------------------------------------------------------------------------

ChangeDepth	MOVE.L	WaitSecs(A5),D4
	BLE.S	NoDelay
	LSL.L	D4
	SUBQ.L	#1,D4
	CMP.L	#$FFFF,D4
	BLE.S	OkDelay
	MOVE.L	#$FFFF,D4

OkDelay	MOVEQ	#0,D0
	MOVEQ	#-1,D1
	Exec	SetSignal

	BTST	#SIGBREAKB_CTRL_C,D0
	BNE	Break
	BTST	#SIGBREAKB_CTRL_F,D0
	BNE	Abort

	MOVEQ	#TICKS_PER_SECOND/2,D1	; Check each half second
	Dos	Delay
	DBF	D4,OkDelay

NoDelay	MOVE.L	_IntuitionBase(PC),A0
	TST.B	WhatScreen(A5)
	BGT.S	.ACTIVE
	BLT.S	.FRONT
	Intuition	OpenWorkBench	; Get Workbench Screen Pointer
	MOVE.L	D0,A4
	BRA.S	StartDepth
.FRONT	MOVE.L	ib_FirstScreen(A0),A4
	BRA.S	StartDepth
.ACTIVE	MOVE.L	ib_ActiveScreen(A0),A4

StartDepth	MOVEQ	#0,D0
	MOVEQ	#-1,D1
	Exec	SetSignal

	BTST	#SIGBREAKB_CTRL_C,D0	; One last chance
	BNE	Break
	
	MOVEQ	#8,D4
	MOVE.W	WhatDepth(A5),D5
	TST.W	D5
	BEQ	ShowDepth

	LEA	$C0(A4),A3

AllocNext	TST.B	D5
	BEQ.S	NewDepth
	TST.L	(A3)
	BNE.S	AlreadyAlloc
	MOVEM.W	12(A4),D0-D1
	ADD.W	#$F,D0	ROM subroutine
	ASR.W	#3,D0
	ANDI.W	#$FFFE,D0
	MULU.W	D1,D0
	MOVE.L	D0,-(A7)
	MOVEQ	#3,D1	ROM AllocRaster modified to clear first
	Exec	AllocMem
	MOVE.L	(A7)+,A1
	MOVE.L	D0,A0
	MOVE.L	D0,(A3)	Put address into screen structure
	ADD.L	D0,A1
	MOVEQ	#0,D0
.cloop	MOVE.W	D0,(A0)+
	CMP.L	A0,A1
	BNE.S	.cloop
AlreadyAlloc	TST.L	(A3)+
	SUBQ.B	#1,D4
	SUBQ.B	#1,D5
	BRA.S	AllocNext

NewDepth	MOVE.W	WhatDepth(A5),$BC(A4)
	Intuition	RemakeDisplay
	
FreeNext	TST.B	D4
	BEQ.S	DoneFree
	TST.L	(A3)
	BEQ.S	AlreadyFree
	MOVEM.W	12(A4),D0-D1
	MOVE.L	(A3),A0
	Graphics	FreeRaster
	MOVE.L	#0,(A3)	Clear address in screen structure
AlreadyFree	TST.L	(A3)+
	SUBQ.B	#1,D4
	BRA.S	FreeNext
	
DoneFree	RTS

GetDec	MOVEQ	#0,D0
	MOVEQ	#0,D1

NextDecDigit	MOVE.B	(A0)+,D0
	SUB.B	#"0",D0
	MULU.W	#10,D1
	ADD.L	D0,D1
	MOVE.B	(A0),D0
	CMP.B	#"9",D0
	BGT.S	DecDigError
	CMP.B	#"0",D0
	BGE.S	NextDecDigit
	CMP.B	#",",D0
	BEQ.S	EndDecOK
	CMP.B	#" ",D0
	BLE.S	EndDecOK
DecDigError	MOVEQ	#-1,D0
	RTS
EndDecOK	MOVE.L	D1,D0
	RTS
	
Input	MOVE.L	StdOutput(A5),D1
	LEA	Template(PC),A0
	MOVE.L	A0,D2
	MOVE.L	#Template.-Template,D3
	Dos	Write		; Write template

	MOVE.L	StdInput(A5),D1
	MOVE.L	ArgList(A5),D2
	MOVE.L	#$100,D3		256 byte input buffer
	Dos	Read		; Read input

	MOVE.L	ArgList(A5),A0
	LEA	(A0,D0),A0
	MOVE.L	A0,ArgEnd(A5)
	BRA	Arguments

DispInfo	MOVE.L	StdOutput(A5),D1
	LEA	Info(PC),A0
	MOVE.L	A0,D2
	MOVE.L	#Info.-Info,D3
	Dos	Write
	BRA	Exit

Break	MOVE.L	StdOutput(A5),D1
	LEA	BreakText(PC),A0
	MOVE.L	A0,D2
	MOVEQ	#BreakText.-BreakText,D3
	Dos	Write
	MOVE.L	#10,RC(A5)
	BRA	Exit

Abort	MOVE.L	StdOutput(A5),D1
	LEA	AbortText(PC),A0
	MOVE.L	A0,D2
	MOVEQ	#AbortText.-AbortText,D3
	Dos	Write
	MOVE.L	#5,RC(A5)
	BRA	NoDelay

BadDepth	MOVE.L	StdOutput(A5),D1
	LEA	BadDepthVal(PC),A0
	MOVE.L	A0,D2
	MOVEQ	#BadDepthVal.-BadDepthVal,D3
	Dos	Write
	MOVE.L	#10,RC(A5)
	BRA	Exit

ShowDepth	MOVE.L	StdOutput(A5),D1
	LEA	ShowDepthVal(PC),A0
	MOVE.L	A0,D2
	MOVEQ	#ShowDepthVal.-ShowDepthVal,D3
	MOVE.W	$BC(A4),D0
	ADD.B	#"0",D0
	MOVE.B	D0,CurrDepth
	Dos	Write
	BRA	Exit

;------------Keyword recognition function	11/29/91
;	Affects:	A0/A1/D0

;	Input:	A0=Text to be checked
;		A1=Keyword to be checked against
;	Output:	D0=Length of text if match
;		D0=0 if no match
;		A0=End of text if match
;		A0=Start of text if no match
;		A1=Start of text if match

Keyword	MOVEQ	#0,D0
	MOVE.L	A0,-(A7)
.loop	CMP.B	(A0)+,(A1)+
	BNE.S	.no
	ADDQ.L	#1,D0
	TST.B	(A1)
	BNE.S	.loop
	MOVE.L	(A7)+,A1
	RTS
.no	MOVE.L	(A7)+,A0
	MOVEQ	#0,D0
	RTS

;------------Capitalization function	11/29/91
;	Affects:	A0/A1/D0

;	Input:	A0=Start of text to be capitalized
;		A1=End of text to be checked
;	Output:	All lowercase letters between A0 and A1 are uppercased

Capitalize	MOVE.B	(A0),D0
	CMP.B	#"a",D0	; Is it less than "a"?
	BLT.S	.NotSmall
	CMP.B	#"z",D0	; Is it greater than "z"?
	BGT.S	.NotSmall
	SUB.B	#32,D0	; Capitalize it.
.NotSmall	MOVE.B	D0,(A0)+
	CMP.L	A1,A0
	BLT.S	Capitalize
	RTS

	RSRESET
ArgList	RS.L	1
ArgEnd	RS.L	1
StdOutput	RS.L	1
StdInput	RS.L	1
RC	RS.L	1
WaitSecs	RS.L	1
WhatDepth	RS.W	1
WhatScreen	RS.B	1	0=WBScreen,+=ActiveScreen,-=FrontScreen

Space	RS.W	0

keyWAIT	DC.B	"WAIT=",0
keyWB	DC.B	"WB",0
keyFRONT	DC.B	"FRONT",0
keyACTIVE	DC.B	"ACTIVE",0

	DC.B	"$VER: SetDepth 2.2 (12/18/91)",0

Info	DC.B	10,27,"[32mSetDepth 2.2",27,"[0m - Screen Depth Control Utility - © 1991 Ian Einman",10,10
	DC.B	"SetDepth WB WAIT=4 3 sets WorkBench to 8 colors after 4 seconds",10
	DC.B	"SetDepth 1 FRONT sets front screen to 2 colors immediately",10,10
	DC.B	27,"[33m",9,"Ian Einman",10
	DC.B	9,"Attn: Product Registration",10
	DC.B	9,"16810 McRae Road",10
	DC.B	9,"Arlington, WA 98223",10,10,27,"[0m"
	DC.B	"If you have no documentation, register by sending me $3.00.",10
	DC.B	"You will recieve instructions and future info regarding updates.",10,10
Info.

Template	DC.B	"WAIT=/N,WB/S,FRONT/S,ACTIVE/S,DEPTH/N: "
Template.

BreakText	DC.B	"***Break",10
BreakText.

AbortText	DC.B	"***Wait aborted",10
AbortText.

BadDepthVal	DC.B	"Depth out of range (1 to 8)",10
BadDepthVal.

ShowDepthVal	DC.B	"Current depth = "
CurrDepth	DC.B	"0",10
ShowDepthVal.

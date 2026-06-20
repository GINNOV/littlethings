	BRA.S	SetColor

	Include	Libs/Exec.lib
	Include	Libs/Dos.lib
	Include	Libs/Intuition.lib
	Include	Libs/Graphics.lib

SetColor	MOVEM.L	D0-D7/A0-A6,-(A7)	; Save registers

	MOVE.L	A0,A3	; Save argument information
	LEA	(A0,D0),A4

	OpenLib	Dos	; Open Libraries
	OpenLib	Graphics
	OpenLib	Intuition

	SUB.L	#Space,A7	; Set up data area
	MOVE.L	A7,A5

	BSR	Initialize
	BSR	Arguments
	BSR	Colormap

Exit	CloseLib	Intuition	; Close libraries
	CloseLib	Graphics
	CloseLib	Dos

	MOVE.L	A5,A7	; Nuke data area
	ADD.L	#Space,A7
	
	MOVE.L	RC(A5),(A7)
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Restore registers
	RTS

Initialize	MOVE.L	A3,ArgList(A5)	; Save argument information
	MOVE.L	A4,ArgEnd(A5)
	CLR.L	RC(A5)

	Dos	Output		; Get Standard Output Channel
	MOVE.L	D0,StdOutput(A5)

	Dos	Input
	MOVE.L	D0,StdInput(A5)

	MOVEQ	#31,D7
ClearColors	MOVE.B	#-1,Red(A5,D7)	; Set all colors to -1
	MOVE.B	#-1,Green(A5,D7)
	MOVE.B	#-1,Blue(A5,D7)	; This will mean "don't change"
	DBF	D7,ClearColors

	CLR.B	WhatScreen(A5)	; Set WhatScreen to WB Screen as default
	CLR.L	WaitSecs(A5)		; Set Wait period to no wait

	RTS

;----------------------------------------------------------------

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

CheckDec	CMP.B	#"0",(A0)
	BLT.S	Not.Dec
	CMP.B	#"9",(A0)
	BGT.S	Not.Dec
DecColor	BSR	GetDec
	BRA.S	GotColorNum
Not.Dec

CheckHex	CMP.B	#"$",(A0)
	BNE	Not.Hex
HexColor	BSR	GetHex
GotColorNum	MOVE.L	D0,D7
	BLT	BadColorNum	; If less than zero
	CMP.L	#31,D7
	BGT	BadColorNum	; If greater than 31
	TST.B	(A0)+
	CMP.B	#"$",(A0)
	BEQ.S	HexValue

DecComps	BSR	GetDec
	MOVE.L	D0,D4
	BLT	BadColorComp
	TST.B	(A0)+
	BSR	GetDec
	MOVE.L	D0,D5
	BLT	BadColorComp
	TST.B	(A0)+
	BSR	GetDec
	MOVE.L	D0,D6
	BLT	BadColorComp

	CMP.B	#16,D4
	BGE	BadColorComp
	CMP.B	#16,D5
	BGE	BadColorComp
	CMP.B	#16,D6
	BGE	BadColorComp

	MOVE.B	D4,Red(A5,D7)	; Put components in
	MOVE.B	D5,Green(A5,D7)
	MOVE.B	D6,Blue(A5,D7)
	BRA	NextArg

HexValue	BSR	GetHex
	CMP.L	#$FFF,D0
	BHI	BadColorVal
	ROR.W	#8,D0		; Put components in
	MOVE.B	D0,Red(A5,D7)
	CLR.B	D0
	ROL.W	#4,D0
	MOVE.B	D0,Green(A5,D7)
	CLR.B	D0
	ROL.W	#4,D0
	MOVE.B	D0,Blue(A5,D7)
	BRA.S	NextArg
Not.Hex

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

;-------------------------------------------------------------------

Colormap	MOVE.L	WaitSecs(A5),D4
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
	BRA.S	StartColors
.FRONT	MOVE.L	ib_FirstScreen(A0),A4
	BRA.S	StartColors
.ACTIVE	MOVE.L	ib_ActiveScreen(A0),A4

StartColors	MOVEQ	#0,D0
	MOVEQ	#-1,D1
	Exec	SetSignal

	BTST	#SIGBREAKB_CTRL_C,D0	; One last chance
	BNE	Break
	
	MOVEQ	#31,D7
NextColor	LEA	44(A4),A0	Put viewport in proper place
	MOVE.L	D7,D0	Put register in proper place

	MOVEQ	#0,D1	Set all of D1-D3 to zero
	MOVEQ	#0,D2
	MOVEQ	#0,D3

	MOVE.B	Red(A5,D7),D1	Get red byte
	BLT.S	DoNotChange
	MOVE.B	Green(A5,D7),D2	Get green byte
	BLT.S	DoNotChange
	MOVE.B	Blue(A5,D7),D3	Get blue byte
	BLT.S	DoNotChange
	
	Graphics	SetRGB4		Set the color

DoNotChange	DBF	D7,NextColor

	RTS

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

GetHex	MOVEQ	#0,D0
	MOVEQ	#0,D1
	TST.B	(A0)+	; Skip "$"

NextHexDigit	MOVE.B	(A0)+,D0
	CMP.B	#"A",D0
	BGE.S	HexLetter
HexNumber	SUB.B	#"0",D0
	BRA.S	UseHexDigit
HexLetter	SUB.B	#"A"-10,D0
UseHexDigit	LSL.L	#4,D1
	ADD.L	D0,D1
	MOVE.B	(A0),D0
	CMP.B	#"F",D0
	BGT.S	HexDigError
	CMP.B	#"A",D0
	BGE.S	NextHexDigit
	CMP.B	#"9",D0
	BGT.S	HexDigError
	CMP.B	#"0",D0
	BGE.S	NextHexDigit
	CMP.B	#",",D0
	BEQ.S	EndHexOK
	CMP.B	#" ",D0
	BLE.S	EndHexOK
HexDigError	MOVEQ	#-1,D0
	RTS
EndHexOK	MOVE.L	D1,D0
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

BadColorNum	MOVE.L	StdOutput(A5),D1
	LEA	BadReg(PC),A0
	MOVE.L	A0,D2
	MOVEQ	#BadReg.-BadReg,D3
	Dos	Write
	BRA.S	ErrExit

BadColorComp	MOVE.L	StdOutput(A5),D1
	LEA	BadComp(PC),A0
	MOVE.L	A0,D2
	MOVEQ	#BadComp.-BadComp,D3
	Dos	Write
	BRA.S	ErrExit

BadColorVal	MOVE.L	StdOutput(A5),D1
	LEA	BadVal(PC),A0
	MOVE.L	A0,D2
	MOVEQ	#BadVal.-BadVal,D3
	Dos	Write
ErrExit	MOVE.L	#10,RC(A5)
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
Red	RS.B	32
Green	RS.B	32
Blue	RS.B	32
WhatScreen	RS.B	1	0=WBScreen,+=ActiveScreen
Space	RS.W	0

keyWAIT	DC.B	"WAIT=",0
keyWB	DC.B	"WB",0
keyFRONT	DC.B	"FRONT",0
keyACTIVE	DC.B	"ACTIVE",0

	DC.B	"$VER: SetColor 2.2 (12/18/91)",0

Info	DC.B	10,27,"[32mSetColor 2.2 ",27,"[0m- Colormap Control Utility - © 1991 Ian Einman",10,10
	DC.B	"SetColor WAIT=4 0,3,0,9 sets background to dark blue in 4 seconds",10
	DC.B	"SetColor 17,$000 18,$000 19,$000 blacks out mouse",10,10
	DC.B	27,"[33m",9,"Ian Einman",10
	DC.B	9,"Attn:  Product Registration",10
	DC.B	9,"16810 McRae Road",10
	DC.B	9,"Arlington, WA 98223",10,10,27,"[0m"
	DC.B	"If you have no documentation, register by sending me $3.00.",10
	DC.B	"You will recieve instructions and future info regarding updates.",10,10
Info.

Template	DC.B	"WAIT=/N,WB/S,FRONT/S,ACTIVE/S,(REG/N,$RGB/N)/M,(REG/N,R/N,G/N,B/N)/M: "
Template.

BreakText	DC.B	"***Break",10
BreakText.

AbortText	DC.B	"***Wait aborted",10
AbortText.

BadReg	DC.B	"Color register out of range (0 to 31; $00 to $1F)",10
BadReg.

BadComp	DC.B	"Color component out of range (0 to 15)",10
BadComp.

BadVal	DC.B	"Color value out of range ($000-$FFF)",10
BadVal.

BadPreset	DC.B	"Color preset name not recognized",10
BadPreset.

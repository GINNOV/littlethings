
		Opt	o+,ow-,c-,d+

		Incdir	Inx:
		INCLUDE	macros.i
		INCLUDE	LVO.Gs
		Include	Reqtools.i

ProgStart	Move.l	4.w,a6
		Lea	Variables(PC),a5

		Lea	ReqToolsName(pc),a1
		Call	Openlibrary
		Move.l	d0,ReqToolsBase(a5)
		beq.b	NoReqtools

		Move.l	ReqToolsBase(a5),a6
		Moveq.l	#RT_ReqInfo,d0
		Sub.w	a0,a0
		Call	RTAllocRequestA
		Move.l	d0,ReqInfo(a5)


		Bsr	GetCardNumber
		Bsr	ConvertCard
		Tst.b	InvalidCard(a5)
		Bne.b	.CardInvalid

		Bsr	CheckSumCard
		Tst.b	InvalidCard(a5)
		Bne.b	.CardInvalid

		Lea	Issuer(a5),a4

		Lea	IssuerStruct(PC),a0
		Move.l	CardNumber(a5),d0

.Loop		Move.l	(a0),d1		; Get struct card #
		Beq.b	.FoundMatch
		Cmp.l	d0,d1
		Beq.b	.FoundMatch
		Addq.l	#6,a0
		Bra.b	.Loop

.FoundMatch	Lea	IssuerStruct(PC),a1
		Add.w	4(a0),a1
		Move.l	a1,(a4)
		Lea	CardValidTxt(PC),a1
		Bsr	DoEzReqArgs


.CardInvalid	Move.l	ReqToolsBase(a5),a6
		Move.l	ReqInfo(a5),a1
		Call	RTFreerequest

		Move.l	a6,a1			; RT base
		Move.l	4.w,a6
		Call	Closelibrary
		Moveq.l	#0,d0
NoReqtools	Rts


;------------------------------------------------------------------
GetCardNumber	Move.l	ReqToolsBase(a5),a6
		Lea	TagList(PC),a0
		Lea	InputBuffer(a5),a1
		Lea	Title(pc),a2
		Move.l	ReqInfo(a5),a3
		Moveq.l	#19,d0			; Max chars
		Jump	RTGetStringa

;------------------------------------------------------------------
ConvertCard	Lea	InputBuffer(a5),a0
		Lea	CardNumber(a5),a1

.Loop		Move.b	(a0)+,d0	; get char
		Beq.b	.FoundEnd

		Cmp.b	#"-",d0
		Beq.b	.Loop
		Cmp.b	#" ",d0
		Beq.b	.Loop

		Cmp.b	#"0",d0
		Blt.b	.InvalidChar
		Cmp.b	#"9",d0
		Bgt.b	.InvalidChar

		Sub.b	#'0',d0
		Move.b	d0,(a1)+
		Addq.b	#1,NumOfChars(a5)

		Cmp.b	#16,NumOfChars(a5)
		Bgt.b	.WrongNumOfDigits
		Bra.b	.Loop

.FoundEnd	
		Cmp.b	#16,NumOfChars(a5)
		Beq.b	.OkayNumOfChars

		Cmp.b	#13,NumOfChars(a5)
		Bne.b	.WrongNumOfDigits

.OkayNumOfChars	St.b	(a1)+
		Rts



.InvalidChar	Lea	InvalidCharTxt(PC),a1
		St.b	InvalidCard(a5)
		Bra.b	DoEZReq

.WrongNumOfDigits
		Lea	WrongNumCharsTxt(PC),a1
		St.b	InvalidCard(a5)

;------------------------------------------------------------------
DoEZReq		Sub.l	a4,a4
DoEZReqArgs	Move.l	ReqToolsBase(a5),a6
		Lea	EZTagList(PC),a0
		Lea	OkayGadgetTxt(pc),a2
		Move.l	ReqInfo(a5),a3
		Jump	RTEZRequestA


;------------------------------------------------------------------
;Credit cards use the Luhn Check Digit Algorithm.  The main purpose of
;this algorithm is to catch data entry errors, but it does double duty
;here as a weak security tool.
;
;For a card with an even number of digits, double every odd digit and
;subtract 9 if the product is greater than 10.  Add up all the even
;digits as well as the doubled-odd digits, and the result must be a
;multiple of 10 or it's not a valid card.  If the card has an odd
;number of digits, perform the same addition doubling the even digits
;instead.

CheckSumCard	Lea	CardNumber(a5),a0
		Moveq.l	#-1,d0
.Cnt		Addq.l	#1,d0
		Cmp.b	#-1,(a0)+
		Bne.b	.Cnt

		Push	d0

		Lea	CardNumber(a5),a0
		Btst	#0,d0			; Even # of digits?
		Beq.b	.Even
		Addq.l	#1,a0			; Read odd digits.

.Even		Lsr.l	#1,d0			; Div by 2


		Subq.l	#1,d0			; Correct for dbra
		Moveq.l	#0,d2
.Check		Move.b	(a0),d1
		Lsl.b	#1,d1
		Cmp.b	#10,d1
		Blt.b	.Ok
		Sub.b	#9,d1

.ok		Add.b	d1,d2
		Addq.l	#2,a0
		Dbra	d0,.Check


		Pop	d0

		Lea	CardNumber(a5),a0
		Btst	#0,d0			; Even # of digits?
		Bne.b	.Odd
		Addq.l	#1,a0			; Read odd digits.

.Odd		Lsr.l	#1,d0			; Div by 2

		Subq.l	#1,d0			; Correct for dbra

		Moveq.l	#0,d1
.Check2		Add.b	(a0),d1
		Addq.l	#2,a0
		Dbra	d0,.Check2

		Add.l	d1,d2

		Lea	CardInvalidTxt(PC),a1
		St.b	InvalidCard(a5)

		And.l	#%1111,d2
		Cmp.l	#%1010,d2
		Bne	DoEZReq

		Clr.b	InvalidCard(a5)
		Rts

*****************************************************************************
*****				Variables				*****	
*****************************************************************************

TagList		Dc.l	RT_WaitPointer,1
		Dc.l	RTGS_TextFmt,Text
		Dc.l	Tag_End,0

EZTagList	Dc.l	RT_WaitPointer,1
		Dc.l	RT_ReqPos,ReqPos_Pointer
		Dc.l	RT_UnderScore,"_"
		Dc.l	RTEZ_Flags,EZReqF_CenterText
		Dc.l	Tag_End,0



IssuerStruct	Dc.l	$04050309
		Dc.w	BarclaysTxt-IssuerStruct
		Dc.l	$04090201
		Dc.w	LloydsTxt-IssuerStruct
		Dc.l	$04090106
		Dc.w	MidlandVisaTxt-IssuerStruct
		Dc.l	$05040304
		Dc.w	MidlandBVisaTxt-IssuerStruct
		Dc.l	$04050007
		Dc.w	BofScotBVisaTxt-IssuerStruct
		Dc.l	0
		Dc.w	UnknownIssueTxt-IssuerStruct

BarclaysTxt	dc.b	"Barclays VISA",0
LloydsTxt	dc.b	"Lloyds VISA",0
MidlandVisaTxt	dc.b	"Midland VISA",0
MidlandBVisaTxt	dc.b	"Midland Business VISA",0
BofScotBVisaTxt	dc.b	"Bank Of Scotland Business VISA",0
UnknownIssueTxt	dc.b	"Unknown",0

		Dc.b	"$VER: CardChecker v1.1",0

Text		Dc.b	"Please enter Credit Card number.",0

InvalidCharTxt	Dc.b	"You entered an invalid character!",10
		Dc.b	"Card not processed.",0

WrongNumCharsTxt
		Dc.b	"Card should be 13 or 16 digits.",10
		Dc.b	"Card not processed.",0

CardInValidTxt	Dc.b	"Card checksum invalid.",10
		Dc.b	"Reject Card",0

CardValidTxt	Dc.b	"Card is Valid",10
		Dc.b	"Issuer & Type: %s",0

OkayGadgetTxt	Dc.b	"_Okay",0

Reqtoolsname	dc.b	"reqtools.library",0

title		dc.b	"Longword requestor",0

Variables	RsReset
reqtoolsbase	Rs.l	1
ReqInfo		Rs.l	1
;CheckSum	Rs.l	1
Issuer		Rs.l	1
InputBuffer	Rs.b	20
CardNumber	Rs.b	20+1
NumOfChars	Rs.b	1
InvalidCard	Rs.b	1
VarsSize	Rs.b	0
		Ds.b	VarsSize

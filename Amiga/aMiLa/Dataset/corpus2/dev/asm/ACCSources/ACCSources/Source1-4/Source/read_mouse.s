*****************************************************
*						    *
* Read The Mouse Routine, This Flashes Colours When *
* Mouse Is Moved Around... One Colours For Each Dir *
*						    *
* Coded By R.Capper (The Snowman)....		    *
*						    *
*****************************************************
	Section	BlahBlah,CODE_C

Lp	Bsr	CheckMouse
	Btst	#6,$bfe001		Check Left Mousey
	Bne.s	Lp
	Rts
*************************************************** Routine To Check
CheckMouse
	MOVE.B	OldMouseY,D0		Last Y
	SUB.B	$DFF00A,D0
	BEQ	NoYMov
	BMI.S	DoDown
DoUp	Move.w	#$0f00,$dff180		Up Routine Here
	BRA.S	NoYMov
DoDown	Move.w	#$0ff0,$dff180		Down Routine Here

NoYMov  MOVE.B	$DFF00A,OldMouseY	Save Y
	MOVE.B	OldMouseX,D0		Last X
	SUB.B	$DFF00B,D0
	BEQ	NoXMov
	BMI.S	DoRigh

DoLeft	Move.w	#$0f0f,$dff180		Left Routine Here
	BRA.S	NoXMov
DoRigh	Move.w	#$0fff,$dff180		Right Routine Here

NoXMov	MOVE.B	$DFF00B,OldMouseX	Save X
	RTS
*************************************************** Variables
OldMouseY	Dc.b	0
OldMouseX	Dc.b	0
***************************************************
        END

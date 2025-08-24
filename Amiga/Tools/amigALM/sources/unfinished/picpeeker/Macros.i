;---- Exec Equates

Forbid		= -132
Permit		= -138
FindTask	= -294
GetMsg		= -372
ReplyMsg	= -378
WaitPort	= -384
CloseLibrary	= -414
OpenLibrary	= -552

;---- Intuition Equates

CloseWindow	= -72
OpenWindow	= -204
SetWindowTitles	= -276

;---- Graphics Equates

LoadView	= -222
WaitTOF		= -270
OwnBlitter	= -456
DisownBlitter	= -462

;---- Dos Equates

Open		= -30
Close		= -36
Read		= -42
Write		= -48
Lock		= -84
UnLock		= -90
Examine		= -102
Delay		= -198

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
.WB\@	btst	#6,2(a5)
	bne.b	.WB\@
	ENDM

WaitBm	MACRO
.1\@	move.b	5(a5),d0
	lsl.w	#8,d0
	or.b	6(a5),d0
	and.w	#$1ff,d0
	cmp.w	#312,d0
	bne.s	.1\@
	ENDM

;-------------------;

GadStrg	MACRO
	dc.l	\1			;Next
	dc.w	\2,\3			;X & Y
	dc.w	\4*8,8			;Width & Height
	dc.w	0			;Flags
	dc.w	1			;Activation Flags
	dc.w	4			;Type
	dc.l	\5			;Select1
	dc.l	0			;Select2
	dc.l	\6			;Text
	dc.l	0			;Exclude
	dc.l	StInf\@			;Special Info
	dc.w	\9			;Gadget ID
	dc.l	0			;User Data

StInf\@	dc.l	\7			;Text Buffer
	dc.l	0			;Undo buffer
	dc.w	0			;Cursor Pos
	dc.w	\8			;Max Chars
	dc.w	0			;Output Text From Char
	dc.w	0			;Char Position In Undo
	dc.w	0			;No. Chars In Text Buffer
	dc.w	0			;No. Chars Visible in Box
	dc.w	0			;Horz Box Offset
	dc.w	0			;Vert Box offset
	dc.l	0			;RastPort
	dc.l	0			;Longword Value
	dc.l	0			;Keyboard
	ENDM

;-------------------;

Border	MACRO				;NEXT,X,Y,W,H,L,S
	dc.w	\2,\3			;X & Y
	dc.b	\6,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	Coords1\@		;Coords
	dc.l	Border2\@		;Next

Border2\@
	dc.w	\2,\3			;X & Y
	dc.b	\7,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	Coords2\@		;Coords
	dc.l	\1			;Next

Coords1\@
	dc.w	1,1
	dc.w	1,\5-2
	dc.w	0,\5-1
	dc.w	0,0
	dc.w	\4-2,0

Coords2\@
	dc.w	\4-2,\5-2
	dc.w	\4-2,1
	dc.w	\4-1,0
	dc.w	\4-1,\5-1
	dc.w	1,\5-1
	ENDM


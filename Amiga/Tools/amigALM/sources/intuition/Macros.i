;		Next,X,Y,W,H,Sel1,Sel2,Text,ID

GadText	MACRO
	dc.l	\1			;Next
	dc.w	\2,\3			;X & Y
	dc.w	\4,\5			;Width & Height
	dc.w	2			;Flags
	dc.w	1			;Activation Flags
	dc.w	1			;Type
	dc.l	\6			;Select1
	dc.l	\7			;Select2
	dc.l	\8			;Text
	dc.l	0			;Exclude
	dc.l	0			;SpecialInfo
	dc.w	\9			;Gadget ID
	dc.l	0			;User Data
	ENDM

;-------------------;

;		Next,X,Y,VisChar,MaxChars,Sel1,Text,Buffer,ID

GadStrg	MACRO
	dc.l	\1			;Next
	dc.w	\2,\3+2			;X & Y
	dc.w	\4*8,8			;Width & Height
	dc.w	0			;Flags
	dc.w	1			;Activation Flags
	dc.w	4			;Type
	dc.l	\6			;Select1
	dc.l	0			;Select2
	dc.l	\7			;Text
	dc.l	0			;Exclude
	dc.l	.1\@			;Special Info
	dc.w	\9			;Gadget ID
	dc.l	0			;User Data

.1\@	dc.l	\8			;Text Buffer
	dc.l	0			;Undo buffer
	dc.w	0			;Cursor Pos
	dc.w	\5			;Max Chars
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

;		Next,X,Y,ColF,ColB,Mode,Font,Text

IText	MACRO
	dc.b	\4,\5			;Colours
	dc.b	\6			;Mode
	even
	dc.w	\2,\3			;X & Y
	dc.l	\7			;Font
	dc.l	\8			;Text
	dc.l	\1			;Next
	ENDM

;-------------------;

;		Next,X,Y,W,H,Cols,Bpls,Data

IImage	MACRO
	dc.w	\2,\3			;X & Y
	dc.w	\4,\5			;Width & Height
	dc.w	\7			;Bitplanes
	dc.l	\8			;Data
	dc.b	\6,0			;Colours
	dc.l	\1			;Next
	ENDM

;-------------------;

;		Next,X,Y,W,H,Cols1,Cols2

Border	MACRO
	dc.w	\2,\3			;X & Y
	dc.b	\6,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	.2\@			;Coords
	dc.l	.1\@			;Next

.1\@
	dc.w	\2,\3			;X & Y
	dc.b	\7,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	.3\@			;Coords
	dc.l	\1			;Next

.2\@
	dc.w	1,1
	dc.w	1,\5-2
	dc.w	0,\5-1
	dc.w	0,0
	dc.w	\4-2,0

.3\@
	dc.w	\4-2,\5-2
	dc.w	\4-2,1
	dc.w	\4-1,0
	dc.w	\4-1,\5-1
	dc.w	1,\5-1
	ENDM


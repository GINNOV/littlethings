
MTitle	MACRO
	dc.l	\1			;Next
	dc.w	\2,\3			;X & Y
	dc.w	\4,0			;Width & Height
	dc.w	1			;Enabled
	dc.l	\5			;Text
	dc.l	\6			;Menu Item
	dc.w	0,0,0,0			;Reserved
	ENDM

;--------------------------------------;

MItem	MACRO
	dc.l	\1			;Next
	dc.w	\2,\3			;X & Y
	dc.w	\4,\5			;Width & Height
	dc.w	\6			;Flags
	dc.l	0			;Exclude
	dc.l	\8			;Text
	dc.l	0			;ItemFill
	dc.b	\7			;HotKey
	even
	dc.l	\9			;SubMenu Item
	dc.l	0			;Next Select
	ENDM

;--------------------------------------;

MSubItm	MACRO
	dc.l	\1			;Next
	dc.w	\2,\3			;X & Y
	dc.w	\4,\5			;Width & Height
	dc.w	\6			;Flags
	dc.l	0			;Exclude
	dc.l	\8			;Text
	dc.l	0			;ItemFill
	dc.b	\7			;HotKey
	even
	dc.l	0			;Unused
	dc.l	0			;Next Select
	ENDM

;--------------------------------------;

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

GadNull	MACRO
	dc.l	\1			;Next
	dc.w	\2,\3			;X & Y
	dc.w	\4,\5			;Width & Height
	dc.w	3			;Flags
	dc.w	2			;Activation Flags
	dc.w	1			;Type
	dc.l	0			;Select1
	dc.l	0			;Select2
	dc.l	0			;Text
	dc.l	0			;Exclude
	dc.l	0			;SpecialInfo
	dc.w	\6			;Gadget ID
	dc.l	0			;User Data
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

GadNmbr	MACRO
	dc.l	\1			;Next
	dc.w	\2,\3			;X & Y
	dc.w	\4*8,8			;Width & Height
	dc.w	0			;Flags
	dc.w	$801			;Activation Flags
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

IImage	MACRO
	dc.w	\2,\3			;X & Y
	dc.w	\4,\5			;Width & Height
	dc.w	\7			;Bitplanes
	dc.l	\8			;Data
	dc.b	\6,0			;Colours
	dc.l	\1			;Next
	ENDM

;-------------------;

Border	MACRO				;X,Y,W,H,L,S,NEXT
	dc.w	\1,\2			;X & Y
	dc.b	\5,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	Coords1\@		;Coords
	dc.l	Border2\@		;Next

Border2\@
	dc.w	\1,\2			;X & Y
	dc.b	\6,0			;Colours
	dc.b	0			;Mode
	dc.b	5			;Pairs
	dc.l	Coords2\@		;Coords
	dc.l	\7			;Next

Coords1\@
	dc.w	1,1
	dc.w	1,\4-2
	dc.w	0,\4-1
	dc.w	0,0
	dc.w	\3-2,0

Coords2\@
	dc.w	\3-2,\4-2
	dc.w	\3-2,1
	dc.w	\3-1,0
	dc.w	\3-1,\4-1
	dc.w	1,\4-1
	ENDM


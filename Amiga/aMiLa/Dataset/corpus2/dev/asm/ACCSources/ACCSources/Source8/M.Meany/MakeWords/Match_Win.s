
MatchWindow
	dc.w	116,10	;window XY origin relative to TopLeft of screen
	dc.w	430,70	;window width and height
	dc.b	1,2	;detail and block pens
	dc.l	GADGETUP!CLOSEWINDOW	;IDCMP flags
	dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE
	dc.l	str_gadg	;first gadget in gadget list
	dc.l	0	;custom CHECKMARK imagery
	dc.l	NewWindowName1	;window title
	dc.l	0	;custom screen pointer
	dc.l	0	;custom bitmap
	dc.w	5,5	;minimum width and height
	dc.w	640,200	;maximum width and height
	dc.w	WBENCHSCREEN	;destination screen type
NewWindowName1:
	dc.b	'Make Words © 1991 M.Meany v1.0',0
	even
GadgetList1:
str_gadg:
	dc.l	0	;next gadget
	dc.w	139,43	;origin XY of hit box relative to window TopLeft
	dc.w	268,10	;hit box width and height
	dc.w	SELECTED	;gadget flags
	dc.w	RELVERIFY+STRINGCENTER	;activation flags
	dc.w	STRGADGET	;gadget type flags
	dc.l	Border1	;gadget border or image to be rendered
	dc.l	0	;alternate imagery for selection
	dc.l	0	;first IntuiText structure
	dc.l	0	;gadget mutual-exclude long word
	dc.l	str_gadgSInfo	;SpecialInfo structure
	dc.w	0	;user-definable data
	dc.l	0	;pointer to user-definable data
str_gadgSInfo:
	dc.l	0
	dc.l	0	;optional undo buffer
cur_pos
	dc.w	0	;character position in buffer
	dc.w	20	;maximum number of characters to allow
	dc.w	0	;first displayed character buffer position
	dc.w	0,0,0,0,0	;Intuition initialized and maintained variables
	dc.l	0	;Rastport of gadget
	dc.l	0	;initial value for integer gadgets
	dc.l	0	;alternate keymap (fill in if you set the flag)
	even
Border1:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	2,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors1	;pointer to XY vectors
	dc.l	0	;next border in list
BorderVectors1:
	dc.w	0,0
	dc.w	280,0
	dc.w	280,11
	dc.w	0,11
	dc.w	0,0
IntuiTextList1:
IText1:
	dc.b	1,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	33,16	;XY origin relative to container TopLeft
	dc.l	0	;font pointer or NULL for default
	dc.l	ITextText1	;pointer to text
	dc.l	IText2	;next IntuiText structure
ITextText1:
	dc.b	'Type in the master word.',0
	even
IText2:
	dc.b	1,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	9,44	;XY origin relative to container TopLeft
	dc.l	0	;font pointer or NULL for default
	dc.l	ITextText2	;pointer to text
	dc.l	0	;next IntuiText structure
ITextText2:
	dc.b	' Master Word  =',0
	even


; end of PowerWindows source generation

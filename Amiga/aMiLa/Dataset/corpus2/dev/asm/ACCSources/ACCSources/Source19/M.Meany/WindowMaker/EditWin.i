
; Include file for Window Maker, all 1600 lines!!!

; Defenition of window and gadgets for editing window characteristics.


SetWinDefs
	dc.w	0,8
	dc.w	640,200
	dc.b	0,1
	dc.l	GADGETDOWN+GADGETUP
	dc.l	SMART_REFRESH+ACTIVATE+NOCAREREFRESH
	dc.l	EditorGadgets
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN

EditorGadgets
	dc.l	EdGadget2
	dc.w	12,14
	dc.w	120,9
	dc.w	GADGHIMAGE		
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	1

.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	20,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'SIZEVERIFY',0
	even
EdGadget2
	dc.l	EdGadget3
	dc.w	140,105
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	20

.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	4,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'INACTIVEWINDOW',0
	even
EdGadget3
	dc.l	EdGadget4
	dc.w	12,40
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	3
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	9,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'REFRESHWINDOW',0
	even
EdGadget4
	dc.l	EdGadget5
	dc.w	12,27
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	2
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	32,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'NEWSIZE',0
	even
EdGadget5
	dc.l	EdGadget6
	dc.w	12,53
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	4
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	14,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'MOUSEBUTTONS',0
	even
EdGadget6
	dc.l	EdGadget7
	dc.w	12,66
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	5
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	26,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'MOUSEMOVE',0
	even
EdGadget7
	dc.l	EdGadget8
	dc.w	12,79
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	6
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	21,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'GADGETDOWN',0
	even
EdGadget8
	dc.l	EdGadget9
	dc.w	12,92
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	7
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	29,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'GADGETUP',0
	even
EdGadget9
	dc.l	EdGadget10
	dc.w	12,105
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	8
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	37,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'REQSET',0
	even
EdGadget10
	dc.l	EdGadget11
	dc.w	12,118
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	9
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	29,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'MENUPICK',0
	even
EdGadget11
	dc.l	EdGadget12
	dc.w	12,131
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	10
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	17,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'CLOSEWINDOW',0
	even
EdGadget12
	dc.l	EdGadget13
	dc.w	12,144
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	11
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	37,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'RAWKEY',0
	even
EdGadget13
	dc.l	EdGadget14
	dc.w	12,157
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	12
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	25,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'REQVERIFY',0
	even
EdGadget14
	dc.l	EdGadget15
	dc.w	140,14
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	13
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	27,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'REQCLEAR',0
	even
EdGadget15
	dc.l	EdGadget16
	dc.w	140,92
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	19
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	13,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'ACTIVEWINDOW',0
	even
EdGadget16
	dc.l	EdGadget17
	dc.w	140,79
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	18
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	9,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'WBENCHMESSAGE',0
	even
EdGadget17
	dc.l	EdGadget18
	dc.w	140,66
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	17
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	17,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'DISKREMOVED',0
	even
EdGadget18
	dc.l	EdGadget19
	dc.w	140,53
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	16
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	13,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'DISKINSERTED',0
	even
EdGadget19
	dc.l	EdGadget20
	dc.w	140,40
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	15
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	28,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'NEWPREFS',0
	even
EdGadget20
	dc.l	EdGadget21
	dc.w	140,27
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	14
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	20,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'MENUVERIFY',0
	even
EdGadget21
	dc.l	EdGadget22
	dc.w	140,131
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	22
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	20,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'VANILLAKEY',0
	even
EdGadget22
	dc.l	EdGadget23
	dc.w	140,144
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	23
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	19,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'INTUITICKS',0
	even
EdGadget23
	dc.l	EdGadget24
	dc.w	140,118
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinidcmp
	dc.l	21
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	24,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'DELTAMOVE',0
	even
EdGadget24
	dc.l	EdGadget25
	dc.w	530,185
	dc.w	80,11
	dc.w	GADGHIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	.Border2
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	DoWinDef

.Border
	dc.w	-1,-1
	dc.b	1,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors
	dc.l	.Border1
.Vectors
	dc.w	0,13
	dc.w	0,0
	dc.w	82,0
.Border1
	dc.w	-1,-1
	dc.b	2,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors1
	dc.l	0
.Vectors1
	dc.w	82,1
	dc.w	82,13
	dc.w	1,13
.Border2
	dc.w	-1,-1
	dc.b	2,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors2
	dc.l	.Border3
.Vectors2
	dc.w	0,13
	dc.w	0,0
	dc.w	82,0
.Border3
	dc.w	-1,-1
	dc.b	1,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors3
	dc.l	0
.Vectors3
	dc.w	82,1
	dc.w	82,13
	dc.w	1,13

.IText
	dc.b	2,0,RP_JAM2,0
	dc.w	27,2
	dc.l	TOPAZ60
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'OK',0
	even
EdGadget25
	dc.l	EdGadget26
	dc.w	500,14
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	8
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	13,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'SUPER_BITMAP',0
	even
EdGadget26
	dc.l	EdGadget27
	dc.w	372,27
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	2
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	21,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'WINDOWDRAG',0
	even
EdGadget27				*** BlockPen
	dc.l	EdGadget28
	dc.w	494,158
	dc.w	36,8
	dc.w	0
	dc.w	STRINGCENTER+LONGINT
	dc.w	STRGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoNothing
.Border
	dc.w	-2,-1
	dc.b	1,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors
	dc.l	.Border1
.Vectors
	dc.w	0,9
	dc.w	0,0
	dc.w	39,0
.Border1
	dc.w	-2,-1
	dc.b	2,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors1
	dc.l	0
.Vectors1
	dc.w	39,1
	dc.w	39,9
	dc.w	1,9
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	-14,-10
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'BlockPen',0
	even
.SInfo
	dc.l	TempBPBuffer
	dc.l	0
	dc.w	0
	dc.w	3
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
TempBPBuffer
	dc.b	'1',0,0
	even
EdGadget28
	dc.l	EdGadget29
	dc.w	372,14
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	1
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	13,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'WINDOWSIZING',0
	even
EdGadget29
	dc.l	EdGadget30
	dc.w	372,40
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	3
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	17,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'WINDOWDEPTH',0
	even
EdGadget30
	dc.l	EdGadget31
	dc.w	372,53
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	4
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	17,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'WINDOWCLOSE',0
	even
EdGadget31
	dc.l	EdGadget32
	dc.w	372,66
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	5
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	21,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'SIZEBRIGHT',0
	even
EdGadget32
	dc.l	EdGadget33
	dc.w	372,79
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	6
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	16,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'SIZEBBOTTOM',0
	even
EdGadget33
	dc.l	EdGadget34
	dc.w	372,105
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	7
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	4,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'SIMPLE_REFRESH',0
	even
EdGadget34
	dc.l	EdGadget35
	dc.w	500,27
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	9
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	28,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'BACKDROP',0
	even
EdGadget35
	dc.l	EdGadget36
	dc.w	500,40
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	10
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	16,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'REPORTMOUSE',0
	even
EdGadget36
	dc.l	EdGadget37
	dc.w	500,53
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	11
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	9,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'GIMMEZEROZERO',0
	even
EdGadget37
	dc.l	EdGadget38
	dc.w	500,66
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	12
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	20,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'BORDERLESS',0
	even
EdGadget38
	dc.l	EdGadget39
	dc.w	500,79
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	13
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	28,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'ACTIVATE',0
	even
EdGadget39
	dc.l	EdGadget40
	dc.w	500,92
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	17
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	33,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'RMBTRAP',0
	even
EdGadget40
	dc.l	EdGadget41
	dc.w	500,105
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	18
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	9,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'NOCAREREFRESH',0
	even
EdGadget41
	dc.l	EdGadget42
	dc.w	372,92
	dc.w	120,9
	dc.w	GADGHIMAGE
	dc.w	TOGGLESELECT+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	EdBorder2
	dc.l	EdBorder3
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	SetWinflags
	dc.l	0
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	9,1
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'SMART_REFRESH',0
	even
EdGadget42				** Width gadget
	dc.l	EdGadget43
	dc.w	330,130
	dc.w	61,12
	dc.w	0
	dc.w	STRINGCENTER+LONGINT
	dc.w	STRGADGET
	dc.l	EdBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoNothing
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	11,-12
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'Width',0
	even
.SInfo
	dc.l	TempWBuffer
	dc.l	0
	dc.w	0
	dc.w	5
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
TempWBuffer
	dc.b	'150',0,0
	even
EdGadget43				*** Height
	dc.l	EdGadget44
	dc.w	400,130
	dc.w	61,12
	dc.w	0
	dc.w	STRINGCENTER+LONGINT
	dc.w	STRGADGET
	dc.l	EdBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoNothing
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	6,-12
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'Height',0
	even
.SInfo
	dc.l	TempHBuffer
	dc.l	0
	dc.w	0
	dc.w	5
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
TempHBuffer
	dc.b	'50',0,0,0
	even
EdGadget44				*** Min Width
	dc.l	EdGadget45
	dc.w	330,146
	dc.w	61,12
	dc.w	0
	dc.w	STRINGCENTER+LONGINT
	dc.w	STRGADGET
	dc.l	EdBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoNothing
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	-36,0
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'Min',0
	even
.SInfo
	dc.l	TempMinWBuffer
	dc.l	0
	dc.w	0
	dc.w	5
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
TempMinWBuffer
	dc.b	'5',0,0,0,0
	even
EdGadget45				*** Max width
	dc.l	EdGadget46
	dc.w	330,162
	dc.w	61,12
	dc.w	0
	dc.w	STRINGCENTER+LONGINT
	dc.w	STRGADGET
	dc.l	EdBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoNothing
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	-36,0
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'Max',0
	even
.SInfo
	dc.l	TempMaxWBuffer
	dc.l	0
	dc.w	0
	dc.w	5
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
TempMaxWBuffer
	dc.b	'640',0,0
	even
EdGadget46				*** Min Height
	dc.l	EdGadget47
	dc.w	400,146
	dc.w	61,12
	dc.w	0
	dc.w	STRINGCENTER+LONGINT
	dc.w	STRGADGET
	dc.l	EdBorder
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoNothing
.SInfo
	dc.l	TempMinHBuffer
	dc.l	0
	dc.w	0
	dc.w	5
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
TempMinHBuffer
	dc.b	'5',0,0,0,0
	even
EdGadget47				*** Max Height
	dc.l	EdGadget48
	dc.w	400,162
	dc.w	61,12
	dc.w	0
	dc.w	STRINGCENTER+LONGINT
	dc.w	STRGADGET
	dc.l	EdBorder
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoNothing
.SInfo
	dc.l	TempMaxHBuffer
	dc.l	0
	dc.w	0
	dc.w	5
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
TempMaxHBuffer
	dc.b	'200',0,0
	even
EdGadget48				*** LeftEdge
	dc.l	EdGadget49
	dc.w	480,130
	dc.w	61,12
	dc.w	0
	dc.w	STRINGCENTER+LONGINT
	dc.w	STRGADGET
	dc.l	EdBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoNothing
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	-2,-12
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'LeftEdge',0
	even
.SInfo
	dc.l	TempLEBuffer
	dc.l	0
	dc.w	0
	dc.w	5
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
TempLEBuffer
	dc.b	'75',0,0,0
	even
EdGadget49				*** TopEdge
	dc.l	EdGadget50
	dc.w	550,130
	dc.w	61,12
	dc.w	0
	dc.w	STRINGCENTER+LONGINT
	dc.w	STRGADGET
	dc.l	EdBorder
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoNothing
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	2,-12
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'TopEdge',0
	even	
.SInfo
	dc.l	TempTEBuffer
	dc.l	0
	dc.w	0
	dc.w	5
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
TempTEBuffer
	dc.b	'85',0,0,0
	even
EdGadget50				*** Detail Pen
	dc.l	EdGadget51
	dc.w	569,158
	dc.w	36,8
	dc.w	0
	dc.w	STRINGCENTER+LONGINT
	dc.w	STRGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoNothing
.Border
	dc.w	-2,-1
	dc.b	1,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors
	dc.l	.Border1
.Vectors
	dc.w	0,9
	dc.w	0,0
	dc.w	39,0
.Border1
	dc.w	-2,-1
	dc.b	2,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors1
	dc.l	0
.Vectors1
	dc.w	39,1
	dc.w	39,9
	dc.w	1,9
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	-18,-10
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'DetailPen',0
	even
.SInfo
	dc.l	TempDPBuffer
	dc.l	0
	dc.w	0
	dc.w	3
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
TempDPBuffer
	dc.b	'0',0,0
	even
EdGadget51				*** Title
	dc.l	EdGadget52
	dc.w	241,185
	dc.w	220,8
	dc.w	0
	dc.w	STRINGCENTER
	dc.w	STRGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	DoNothing
.Border
	dc.w	-2,-1
	dc.b	1,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors
	dc.l	.Border1
.Vectors
	dc.w	0,9
	dc.w	0,0
	dc.w	223,0
.Border1
	dc.w	-2,-1
	dc.b	2,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors1
	dc.l	0
.Vectors1
	dc.w	223,1
	dc.w	223,9
	dc.w	1,9
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	-48,0
	dc.l	TOPAZ80
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'Title',0
	even
.SInfo
	dc.l	TempTitleBuffer
	dc.l	0
	dc.w	0
	dc.w	81
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
TempTitleBuffer
	dc.b	'Default Window',0
	ds.b	66
	even
EdGadget52				*** Cancel
	dc.l	0
	dc.w	22,185
	dc.w	80,11
	dc.w	GADGHIMAGE
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	.Border2
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	CancelWinDef
.Border
	dc.w	-1,-1
	dc.b	1,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors
	dc.l	.Border1
.Vectors
	dc.w	0,13
	dc.w	0,0
	dc.w	82,0
.Border1
	dc.w	-1,-1
	dc.b	2,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors1
	dc.l	0
.Vectors1
	dc.w	82,1
	dc.w	82,13
	dc.w	1,13
.Border2
	dc.w	-1,-1
	dc.b	2,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors2
	dc.l	.Border3
.Vectors2
	dc.w	0,13
	dc.w	0,0
	dc.w	82,0
.Border3
	dc.w	-1,-1
	dc.b	1,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors3
	dc.l	0
.Vectors3
	dc.w	82,1
	dc.w	82,13
	dc.w	1,13
.IText
	dc.b	2,0,RP_JAM2,0
	dc.w	11,2
	dc.l	TOPAZ60
	dc.l	.ITextText
	dc.l	0
.ITextText
	dc.b	'CANCEL',0
	even

TOPAZ60
	dc.l	TOPAZname
	dc.w	9		TOPAZ_SIXTY
	dc.b	0,0
TOPAZ80
	dc.l	TOPAZname
	dc.w	8		TOPAZ_EIGHTY
	dc.b	0,0
TOPAZname
	dc.b	'topaz.font',0
	even

EdBorder
	dc.w	-2,-3
	dc.b	1,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors
	dc.l	.Border1
.Vectors
	dc.w	0,13
	dc.w	0,0
	dc.w	64,0
.Border1
	dc.w	-2,-3
	dc.b	2,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors1
	dc.l	0
.Vectors1
	dc.w	64,1
	dc.w	64,13
	dc.w	1,13
EdBorder2
	dc.w	-1,-1
	dc.b	1,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors
	dc.l	.Border1
.Vectors
	dc.w	0,10
	dc.w	0,0
	dc.w	121,0
.Border1
	dc.w	-1,-1
	dc.b	2,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors1
	dc.l	0
.Vectors1
	dc.w	1,10
	dc.w	121,10
	dc.w	121,1
EdBorder3
	dc.w	-1,-1
	dc.b	2,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors
	dc.l	.Border1
.Vectors
	dc.w	0,10
	dc.w	0,0
	dc.w	121,0
.Border1
	dc.w	-1,-1
	dc.b	1,0,RP_JAM2
	dc.b	3
	dc.l	.Vectors1
	dc.l	0
.Vectors1
	dc.w	1,10
	dc.w	121,10
	dc.w	121,1

EditWinText
	dc.b	1,0,RP_JAM2,0
	dc.w	67,3
	dc.l	0
	dc.l	.ITextText
	dc.l	.IText
.ITextText
	dc.b	'Window IDCMP Flags',0
	even
.IText
	dc.b	1,0,RP_JAM2,0
	dc.w	450,3
	dc.l	0
	dc.l	.ITextText1
	dc.l	0
.ITextText1
	dc.b	'Window Flags',0
	even






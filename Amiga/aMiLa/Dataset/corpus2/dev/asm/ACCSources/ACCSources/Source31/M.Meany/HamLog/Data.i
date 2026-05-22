
***************	Error Messages

NoOpText	dc.b		'Must select an Operator first',0
		even
NoSuchOpText	dc.b		'Could not find that QRZ!',0
		even
QuitText	dc.b		'Quit the program?',0
		even
NoFileText	dc.b		'One or more data files missing!',0
		even
		
***************	General Text Strings

BurText1	dc.b		'  Yes',0
		even
BurText2	dc.b		'  No ',0
		even


***************	Data File Names

OpsFile		dc.b		'HamLogOps:OpsFile.data',0
		even
IndexFile	dc.b		'HamLogOps:Index.data',0
		even
LogFile		dc.b		'HamLogLog:Log.data',0
		even

***************	System library names

dosname		dc.b		'dos.library',0
		even
intname		dc.b		'intuition.library',0
		even
gfxname		dc.b		'graphics.library',0
		even

***************	Operator Detail Input Buffers

		dc.b		0,21
QRZGadgSIBuff	ds.b 		22
		dc.b		0,21
OpGadgSIBuff	ds.b 		22
		dc.b		0,31
QTHGadgSIBuff	ds.b		32
		dc.b		0,7
LocGadgSIBuff	ds.b 		10
		dc.b		0,11
ConGadgSIBuff	ds.b 		12
		dc.b		0,26
Addr1GadgSIBuff	ds.b 		26
		dc.b		0,26
Addr2GadgSIBuff	ds.b 		26
		dc.b		0,26
Addr3GadgSIBuff	ds.b 		26
		dc.b		0,26
Addr4GadgSIBuff	ds.b 		26
		dc.b		0,26
Addr5GadgSIBuff	ds.b 		26
		dc.b		0,26
Addr6GadgSIBuff	ds.b 		26
		dc.b		0,21
PhonGadgSIBuff	ds.b 		22
		dc.b		0,21
FaxGadgSIBuff	ds.b 		22
		dc.b		0,21
LOpGadgSIBuff	ds.b		22
		even


***************	Vector table for mapping keypress to a subroutine

KeyVectors	dc.l	MLShow		F1	Show Log
		dc.l	MAddLog		F2	Add Log Entry
		dc.l	MPLogWin	F3	Print Log Win
		dc.l	MPLogEntries	F4	Print # Entry
		dc.l	MPLogDate	F5	Print ddmmyy
		dc.l	MOShow		F6	Show Op.
		dc.l	MOAdd		F7	add operator
		dc.l	MOPLog		F8	Print Op Log
		dc.l	MOPDetails	F9	Print Op Deta
		dc.l	MOFind		F10	Find Operator
		dc.l	MLShow		sF1
		dc.l	MLDelete	sF2	Delete Last
		dc.l	PNSetDate	sF3	Set Dates
		dc.l	PNShowLog	sF4	Show Log
		dc.l	PNPLog		sF5	Print Log
		dc.l	MOShow		sF6
		dc.l	MOEdit		sF7	Edit Op.
		dc.l	MOPCard		sF8	Print Confirm
		dc.l	MOPLabel	sF9	Print Addr
		dc.l	MOFind		sF10
		dc.l	MAbout		A
		dc.l	MQuit		Q
		dc.l	PrevOp		<-	load prev operator
		dc.l	NextOp		->	load next operator


***************	RAWKEY converion table

KCTable	dc.b	0	"'"	$00
	dc.b	0	'1'	$01
	dc.b	0	'2'	$02
	dc.b	0	'3'	$03
	dc.b	0	'4'	$04
	dc.b	0	'5'	$05
	dc.b	0	'6'	$06
	dc.b	0	'7'	$07
	dc.b	0	'8'	$08
	dc.b	0	'9'	$09
	dc.b	0	'0'	$0A
	dc.b	0	'-'	$0B
	dc.b	0	'='	$0C
	dc.b	0	'\'	$0D
	dc.b	0	0	$0E
	dc.b	0	'0'	$0F	numeric keypad
	dc.b	22	'Q'	$10	
	dc.b	0	'W'	$11
	dc.b	0	'E'	$12
	dc.b	0	'R'	$13
	dc.b	0	'T'	$14
	dc.b	0	'Y'	$15
	dc.b	0	'U'	$16
	dc.b	0	'I'	$17
	dc.b	0	'O'	$18
	dc.b	0	'P'	$19
	dc.b	0	'['	$1A
	dc.b	0	']'	$1B
	dc.b	0	0	$1C
	dc.b	0	'1'	$1D	numeric keypad
	dc.b	0	'2'	$1E	numeric keypad
	dc.b	0	'3'	$1F	numeric keypad
	dc.b	21	'A'	$20
	dc.b	0	'S'	$21
	dc.b	0	'D'	$22
	dc.b	0	'F'	$23
	dc.b	0	'G'	$24
	dc.b	0	'H'	$25
	dc.b	0	'J'	$26
	dc.b	0	'K'	$27
	dc.b	0	'L'	$28
	dc.b	0	';'	$29
	dc.b	0	'#'	$2A
	dc.b	0	0	$2B	BLANK KEY ON A1200 NEAR RETURN
	dc.b	0	0	$2C
	dc.b	0	'4'	$2D	numeric keypad
	dc.b	0	'5'	$2E	numeric keypad
	dc.b	0	'6'	$2F	numeric keypad
	dc.b	0	0	$30	BLANK KEY ON A1200 NEAR Caps Lock
	dc.b	0	'Z'	$31
	dc.b	0	'X'	$32
	dc.b	0	'C'	$33
	dc.b	0	'V'	$34
	dc.b	0	'B'	$35
	dc.b	0	'N'	$36
	dc.b	0	'M'	$37
	dc.b	0	','	$38
	dc.b	0	'.'	$39
	dc.b	0	'/'	$3A
	dc.b	0	0	$3B
	dc.b	0	'.'	$3C	numeric keypad
	dc.b	0	'7'	$3D	numeric keypad
	dc.b	0	'8'	$3E	numeric keypad
	dc.b	0	'9'	$3F	numeric keypad
	dc.b	0	' '	$40
	dc.b	0	0	$41	Backspace
	dc.b	0	0	$42	TAB
	dc.b	0	13	$43	Enter on numeric keypad
	dc.b	0	13	$44	Return
	dc.b	0	0	$45	Esc
	dc.b	0	0	$46	Del
	dc.b	0	0	$47
	dc.b	0	0	$48
	dc.b	0	0	$49
	dc.b	0	'-'	$4A	numeric keypad
	dc.b	0	0	$4B
	dc.b	0	20	$4C	Up Arrow
	dc.b	0	21	$4D	Down Arrow
	dc.b	24	22	$4E	Right Arrow
	dc.b	23	23	$4F	Left Arrow
	dc.b	1	$50	F1
	dc.b	2	$51	F2
	dc.b	3	$52	F3
	dc.b	4	$53	F4
	dc.b	5	$54	F5
	dc.b	6	$55	F6
	dc.b	7	$56	F7
	dc.b	8	$57	F8
	dc.b	9	$58	F9
	dc.b	10	$59	F10
	dc.b	0	'('	$5A	numeric keypad
	dc.b	0	')'	$5B	numeric keypad
	dc.b	0	'/'	$5C	numeric keypad
	dc.b	0	'*'	$5D	numeric keypad
	dc.b	0	'+'	$5E	numeric keypad
	dc.b	0	0	$5F	Help
	dc.b	0	0	$60	Left Shift Key
	dc.b	0	0	$61	Right Shift Key
	dc.b	0	0	$62	Caps Lock
	dc.b	0	0	$63	Ctrl
	dc.b	0	0	$64	Left Alt
	dc.b	0	0	$65	Right Alt
	dc.b	0	0	$66	Left Amiga
	dc.b	0	0	$67	Right Amiga
	dc.b	0	0	$68
	dc.b	0	0	$69
	dc.b	0	0	$6A
	dc.b	0	0	$6B
	dc.b	0	0	$6C
	dc.b	0	0	$6D
	dc.b	0	0	$6E
	dc.b	0	0	$6F
	dc.b	0	0	$70
	dc.b	0	0	$71
	dc.b	0	0	$72
	dc.b	0	0	$73
	dc.b	0	0	$74
	dc.b	0	0	$75
	dc.b	0	0	$76
	dc.b	0	0	$77
	dc.b	0	0	$78
	dc.b	0	0	$79
	dc.b	0	0	$7A
	dc.b	0	0	$7B
	dc.b	0	0	$7C
	dc.b	0	0	$7D
	dc.b	0	0	$7E
	dc.b	0	0	$7F
	dc.b	0	0	$80
	dc.b	0	0	$81
	dc.b	0	0	$82
	dc.b	0	0	$83
	dc.b	0	0	$84
	dc.b	0	0	$85
	dc.b	0	0	$86
	dc.b	0	0	$87
	dc.b	0	0	$88
	dc.b	0	0	$89
	dc.b	0	0	$8A
	dc.b	0	0	$8B
	dc.b	0	0	$8C
	dc.b	0	0	$8D
	dc.b	0	0	$8E
	dc.b	0	0	$8F
	dc.b	0	0	$90
	dc.b	0	0	$91
	dc.b	0	0	$92
	dc.b	0	0	$93
	dc.b	0	0	$94
	dc.b	0	0	$95
	dc.b	0	0	$96
	dc.b	0	0	$97
	dc.b	0	0	$98
	dc.b	0	0	$99
	dc.b	0	0	$9A
	dc.b	0	0	$9B
	dc.b	0	0	$9C
	dc.b	0	0	$9D
	dc.b	0	0	$9E
	dc.b	0	0	$9F
	dc.b	0	0	$A0
	dc.b	0	0	$A1
	dc.b	0	0	$A2
	dc.b	0	0	$A3
	dc.b	0	0	$A4
	dc.b	0	0	$A5
	dc.b	0	0	$A6
	dc.b	0	0	$A7
	dc.b	0	0	$A8
	dc.b	0	0	$A9
	dc.b	0	0	$AA
	dc.b	0	0	$AB
	dc.b	0	0	$AC
	dc.b	0	0	$AD
	dc.b	0	0	$AE
	dc.b	0	0	$AF
	dc.b	0	0	$B0
	dc.b	0	0	$B1
	dc.b	0	0	$B2
	dc.b	0	0	$B3
	dc.b	0	0	$B4
	dc.b	0	0	$B5
	dc.b	0	0	$B6
	dc.b	0	0	$B7
	dc.b	0	0	$B8
	dc.b	0	0	$B9
	dc.b	0	0	$BA
	dc.b	0	0	$BB
	dc.b	0	0	$BC
	dc.b	0	0	$BD
	dc.b	0	0	$BE
	dc.b	0	0	$BF
	dc.b	0	0	$C0
	dc.b	0	0	$C1
	dc.b	0	0	$C2
	dc.b	0	0	$C3
	dc.b	0	0	$C4
	dc.b	0	0	$C5
	dc.b	0	0	$C6
	dc.b	0	0	$C7
	dc.b	0	0	$C8
	dc.b	0	0	$C9
	dc.b	0	0	$CA
	dc.b	0	0	$CB
	dc.b	0	0	$CC
	dc.b	0	0	$CD
	dc.b	0	0	$CE
	dc.b	0	0	$CF
	dc.b	0	0	$D0
	dc.b	0	0	$D1
	dc.b	0	0	$D2
	dc.b	0	0	$D3
	dc.b	0	0	$D4
	dc.b	0	0	$D5
	dc.b	0	0	$D6
	dc.b	0	0	$D7
	dc.b	0	0	$D8
	dc.b	0	0	$D9
	dc.b	0	0	$DA
	dc.b	0	0	$DB
	dc.b	0	$DC
	dc.b	0	$DD
	dc.b	0	$DE
	dc.b	0	$DF
	dc.b	0	$E0
	dc.b	0	$E1
	dc.b	0	$E2	Caps Lock OFF
	dc.b	0	$E3
	dc.b	0	$E4
	dc.b	0	$E5
	dc.b	0	$E6
	dc.b	0	$E7
	dc.b	0	$E8
	dc.b	0	$E9
	dc.b	0	$EA
	dc.b	0	$EB
	dc.b	0	$EC
	dc.b	0	$ED
	dc.b	0	$EE
	dc.b	0	$EF
	dc.b	0	$F0
	dc.b	0	$F1
	dc.b	0	$F2
	dc.b	0	$F3
	dc.b	0	$F4
	dc.b	0	$F5
	dc.b	0	$F6
	dc.b	0	$F7
	dc.b	0	$F8
	dc.b	0	$F9
	dc.b	0	$FA
	dc.b	0	$FB
	dc.b	0	$FC
	dc.b	0	$FD
	dc.b	0	$FE
	even

***************	About Text table


AbTable		dc.l		Ab1
		dc.l		Ab2
		dc.l		Ab3
		dc.l		Ab4
		dc.l		Ab5
		dc.l		Ab6
		dc.l		Ab7
		dc.l		Ab8
		dc.l		Ab9
		dc.l		Aba
		dc.l		Abb
		dc.l		Abc
		dc.l		Abd
		dc.l		Abe
		dc.l		Abf
		dc.l		Abg
		dc.l		Abh
		dc.l		Abi
		dc.l		Abj
		dc.l		Abk
		dc.l		Abl
		dc.l		Abm
		dc.l		0


Ab1		dc.b		'HAM Log, © M.Meany 1993',0
Ab2		dc.b		'This program is NOT Public Domain.',0
Ab3		dc.b		'Accepting a pirate copy of this program constitutes theft!',0
Ab4		dc.b		' ',0
Ab5		dc.b		'If you use this program and would like to see it expand, write to',0
Ab6		dc.b		'the following address:',0
Ab7		dc.b		' ',0
Ab8		dc.b		'M.Meany',0
Ab9		dc.b		'12 Hinkler Road',0
Aba		dc.b		'Southampton',0
Abb		dc.b		'Hants',0
Abc		dc.b		'SO2 6FT',0
Abd		dc.b		'England',0
Abe		dc.b		' ',0
Abf		dc.b		"If you use the program, but don't care if it's updated, why not",0
Abg		dc.b		'send a post card just to let me know.',0
Abh		dc.b		' ',0
Abi		dc.b		'If I know there are  people  using  HAM Log  I  will continue to work on it,',0
Abj		dc.b		'improving features as  suggested.  I  tend  to  shelve  projects that do not',0
Abk		dc.b		"generate any response, so don't get  angry  at poorly implemented or missing",0
Abl		dc.b		'features. Get  updated  by  contacting  me.  Support  the program and I will',0
Abm		dc.b		"improve it. Honest, if I have time and don't loose the source while waiting!",0

***************	Usage Text displayed in CLI if requested

_UsageText	dc.b		$0a
		dc.b		'HAM Log, © M.Meany 1993.'
		dc.b		$0a
		dc.b		'Greets go to the Alpha Tango group ( Hi Dave & Nola :-).'
		dc.b		$0a
		dc.b		0
		even

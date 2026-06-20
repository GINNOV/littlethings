*
*
*	TEXTMASTER: Version 1.10
*
*	©1991 BY NEIL JOHNSTON.
*
*	added loaded filename message, MM 5.6.91

	SECTION	TEXTMASTER,CODE

**********

	INCDIR	SYS:INCLUDE/
	INCLUDE	EXEC/EXEC_LIB.I
	INCLUDE	EXEC/EXEC.I
	INCLUDE	INTUITION/INTUITION_LIB.I
	INCLUDE	INTUITION/INTUITION.I
	INCLUDE	GRAPHICS/GRAPHICS_LIB.I
	INCLUDE	MISC/ARPBASE.I
	INCLUDE	MISC/POWERPACKER_LIB.I
	INCLUDE	MISC/PPBASE.I

	INCLUDE	MISC/EASYSTART.I	ENABLE WORKBENCH STARTUP

**********

CALLSYS	MACRO				BASIC CALLSYS MACRO
	JSR	_LVO\1(A6)
	ENDM

**********

OPENLIBS
	LEA	Intname,A1
	MOVEQ.L	#0,D0
	MOVE.L	$4,A6
	CALLSYS	OpenLibrary
	MOVE.L	D0,Intbase
	BEQ	QEXIT

	LEA	Dosname,A1
	MOVEQ.L	#0,D0
	MOVE.L	$4,A6
	CALLSYS	OpenLibrary
	MOVE.L	D0,Dosbase
	BEQ	CloseInt

	LEA	Gfxname,A1
	MOVEQ.L	#0,D0
	MOVE.L	$4,A6
	CALLSYS	OpenLibrary
	MOVE.L	D0,Gfxbase
	BEQ	CloseDos

	LEA	PPname,A1
	MOVEQ.L	#0,D0
	MOVE.L	$4,A6
	CALLSYS	OpenLibrary
	MOVE.L	D0,Powerbase
	BEQ	PPError

	LEA	ARPname,A1
	MOVEQ.L	#0,D0
	MOVE.L	$4,A6
	CALLSYS	OpenLibrary
	MOVE.L	D0,ARPbase
	BNE	Main

**********

ARPError
	Move.l	Dosbase,a6

	CALLSYS	Output			Get output handle

	move.l	d0,d1
	move.l	#NoARPText,d2
	move.l	#NoARPTextLen,d3

	CALLSYS	Write

	bra	ClosePP

**********	

PPError
	Move.l	Dosbase,a6

	CALLSYS	Output			Get output handle

	move.l	d0,d1
	move.l	#NoPPText,d2
	move.l	#NoPPTextLen,d3

	CALLSYS	Write

	bra	CloseGfx

**********

Main	LEA	MainWindow,A0
	MOVE.L	Intbase,A6
	CALLSYS	OpenWindow
	MOVE.L	D0,WinPtr		WINDOW OPEN?
	BEQ	FreeMemory		NO? QUIT...

	MOVE.L	D0,A0
	MOVE.L	wd_UserPort(A0),UserPort	SAVE USERPORT
	MOVE.L	wd_RPort(A0),RPort		SAVE RASTPORT

	move.l	RPort,a0
	lea	MessageBorder,a1
	moveq.l	#0,d0
	moveq.l	#0,d1

	move.l	Intbase,a6
	CALLSYS	DrawBorder		Draw message box's border

	lea	WelcomeText,a5		Print a nice 'Welcome' Message!
	bsr	PrintMessage

WaitForMsg
	MOVE.L	UserPort,A0

	MOVE.L	$4,A6
	CALLSYS	WaitPort

	MOVE.L	UserPort,A0
	CALLSYS	GetMsg

	MOVE.L	D0,A1
	MOVE.L	im_Class(A1),D2		SAVE MESSAGE CLASS
	MOVE.L	im_IAddress(A1),A2	SAVE GADGET ADDRESS

	CALLSYS	ReplyMsg

	CMP.L	#CLOSEWINDOW,D2
	BEQ.S	CloseWin		CLOSE WINDOW (& QUIT)

	CMP.L	#GADGETUP,D2
	BEQ.S	GadgetJump		GO TO GADGET JUMP ROUTINE

	BRA.S	WaitForMsg

**********

GadgetJump
	MOVE.L	gg_UserData(A2),A0
	CMPA.L	#0,A0			GADGET ASSIGNED?
	BEQ.S	WaitForMsg		IF NOT, DON'T JUMP TO $0!!!

	JMP	(A0)			JUMP TO GADGET ROUTINE

**********

CloseWin
	MOVE.L	WinPtr,A0
	MOVE.L	Intbase,A6
	CALLSYS	CloseWindow

**********

FreeMemory
	CMPI.B	#$FF,LoadFlag
	BNE.S	CloseLibs		DON'T FREE MEM, IF NOT ALLOCATED!
	MOVE.L	SourceBuffer,A1
	MOVE.L	SourceLength,D0
	MOVE.L	$4,A6
	CALLSYS	FreeMem			FREE THE PP ALLOCATED MEM

	CMPI.B	#$FF,DestUsed
	BNE.S	CloseLibs
	MOVE.L	DestBuffer,A1
	MOVE.L	DestLength,D0
	MOVE.L	$4,A6
	CALLSYS	FreeMem			

**********

CloseLibs
	MOVE.L	$4,A6
	MOVE.L	ARPbase,A1
	CALLSYS	CloseLibrary
	
ClosePP
	MOVE.L	$4,A6
	MOVE.L	Powerbase,A1
	CALLSYS	CloseLibrary

CloseGfx
	MOVE.L	$4,A6
	MOVE.L	Gfxbase,A1
	CALLSYS	CloseLibrary

CloseDos
	MOVE.L	$4,A6
	MOVE.L	Dosbase,A1
	CALLSYS	CloseLibrary

CloseInt
	MOVE.L	$4,A6
	MOVE.L	Intbase,A1
	CALLSYS	CloseLibrary

	MOVEQ.L	#0,D0			NO CLI ERROR MESSAGE

QEXIT	RTS				BYE!!!

**********

Prefix	MOVE.L	#0,D0
	LEA	Prefix_Gadget,A0
	MOVE.W	gg_Flags(A0),D0		GET GADGET FLAGS
	AND.W	#SELECTED,D0		GADGET SELECTED?
	BNE.S	Prefix_On

Prefix_Off
	MOVE.B	#$00,PreFlag		00 = NO PREFIX

	lea	PrefixOffText,a5
	bsr	PrintMessage

	BRA	WaitForMsg

Prefix_On
	MOVE.B	#$FF,PreFlag		FF = YES PREFIX!

	lea	PrefixOnText,a5
	bsr	PrintMessage

	BRA	WaitForMsg


**********


Centre	MOVE.L	#0,D0
	LEA	Centre_Gadget,A0
	MOVE.W	gg_Flags(A0),D0		GET GADGET FLAGS
	AND.W	#SELECTED,D0		GADGET SELECTED?
	BNE.S	Centre_On

Centre_Off
	MOVE.B	#$00,CentFlag		00 = NO, CENTRE

	lea	CentreOffText,a5
	bsr	PrintMessage

	BRA	WaitForMsg

Centre_On
	MOVE.B	#$FF,CentFlag		FF = YES, CENTRE

	lea	CentreOnText,a5
	bsr	PrintMessage

	BRA	WaitForMsg

**********

Load	LEA	ReqStruct,A0
	MOVE.L	ARPbase,A6
	CALLSYS	FileRequest		STICK REQUESTER UP

	TST.L	D0
	BNE.S	.OK			USER SELECTED A FILE?

	BRA	WaitForMsg		QUIT IF NO NAME

.OK	LEA	PathBuffer,A0
	LEA	FullBuffer,A1

.Loop	MOVE.B	(A0)+,(A1)
	TST.B	(A1)			FOUND NULL TERMINATOR?
	BEQ.S	.Cont
	ADDA.L	#1,A1
	BRA	.Loop

.Cont	LEA	FullBuffer,A0
	LEA	FileBuffer,A1

	MOVE.L	ARPbase,A6
	CALLSYS	TackOn			GET FULL PATHNAME

**********

ReadData
	CMPI.B	#$FF,LoadFlag		PREVIOUS FILE LOADED?
	BNE.S	.OK

	MOVE.L	SourceBuffer,A1		FREE OLD MEMORY:
	MOVE.L	SourceLength,D0
	MOVE.L	$4,A6
	CALLSYS	FreeMem			FREE THE PP ALLOCATED MEM
	MOVE.B	#$00,LoadFlag		NO FILE LOADED

.OK	LEA	FullBuffer,A0		PATHNAME+FILENAME TO LOAD
	MOVE.L	#DECR_POINTER,D0	FLASH POINTER
	MOVE.L	#MEMF_PUBLIC,D1		ANY MEMORY
	LEA	SourceBuffer,A1		ADDRESS OF POINTER
	LEA	SourceLength,A2		ADDRESS OF POINTER
	MOVE.L	#0,A3			NOTHING SPECIAL!

	MOVE.L	Powerbase,A6
	CALLSYS	ppLoadData		READ FILE

	TST.L	D0
	BEQ.S	.OK2			NO LOADING PROBLEMS!

	lea	LoadErrText,a5
	bsr	PrintMessage		Tell 'em about the Loading problems!

	BRA	WaitForMsg

.OK2	lea	MMmsg,a5		;Print out file loaded message
	bsr	PrintMessage		;  << HAD TO DO SOMETHING >>

	move.l	SourceLength,d0		Number of bytes read
	cmp.l	#20000,d0
	bgt.s	.Error			File size too great

	MOVE.B	#$FF,LoadFlag		SO I KNOW A FILE WAS LOADED!
	MOVE.B	#$00,PrcessFlag		SO I KNOW IT HASN'T BEEN PROCESSED!

	BRA	WaitForMsg

.Error	MOVE.B	#$00,LoadFlag		SO I KNOW A FILE WASN'T LOADED!
	MOVE.B	#$00,PrcessFlag		HASN'T BEEN PROCESSED!

	MOVE.L	SourceBuffer,A1
	MOVE.L	SourceLength,D0
	MOVE.L	$4,A6
	CALLSYS	FreeMem			Free the memory
	
	lea	FileTooBigText,a5
	bsr	PrintMessage

	bra	WaitForMsg

**********

ProcessText
	CMPI.B	#$FF,LoadFlag		FILE LOADED YET?
	BEQ.S	.OK

	lea	NotLoadedText,a5	You 'aint loaded no text yet!
	bsr	PrintMessage

	BRA	WaitForMsg

.OK	cmp.b	#$ff,PrcessFlag		Text already processed?
	bne.s	.OK3

	lea	AlreadyProcessedText,a5
	bsr	PrintMessage

	bra	WaitForMsg
	
.OK3	move.l	#40000,d0		Alloc 'Bout 40K!
	MOVE.L	D0,DestLength
	MOVE.L	#MEMF_PUBLIC+MEMF_CLEAR,D1	CLEAR, PUBLIC MEMORY
	MOVE.L	$4,A6

	CALLSYS	AllocMem		GET DESTINATION MEMORY

	TST.L	D0
	BNE	.OK2			NO MEMORY = EXIT!

	lea	NoMemText,a5
	bsr	PrintMessage

	bra	WaitForMsg

.OK2	move.b	#$ff,DestUsed		So We Can Deallocate it!
	MOVE.L	D0,DestBuffer		SAVE BUFFER ADDRESS

	move.b	#$00,NoProcessMsg

	MOVE.L	SourceBuffer,A0
	move.l	DestBuffer,A1

	moveq.l	#0,d1
	moveq.l	#0,d0
	lea	WidthBuffer,a2		My VERY basic ASCII->INT Routine:
	move.b	(a2)+,d1
	sub	#$30,d1
	mulu	#10,d1

	move.b	(a2),d0
	sub	#$30,d0
	add.l	d1,d0			d0 = Integer Screen width value
	move.w	d0,FullWidth

**********

FindLength
	move.b	#$00,OddFlag		'Odd number of Bytes on line' Flag!
	move.l	a0,a4			Save A0 (Line Start Address)
	moveq.l	#0,d1

GetLength
	cmpi.b	#$0a,(a0)		Return Char ($0a)
	beq.s	GotLength
	cmpi.b	#$00,(a0)		End of text yet?
	beq	Text_End
	addi.l	#1,d1			Line Length
	adda.l	#1,a0			Next Char
	bra.s	GetLength

GotLength
	move.l	d1,d2
	btst	#0,d1			Odd number of Bytes
	beq.s	.ok
	move.b	#$ff,OddFlag		Set OddFlag!

.ok	move.l	a4,a0			Restore A0
	moveq.l	#0,d0
	move.w	FullWidth,d0
	cmp.w	d0,d1			Is Line longer than screen width?
	blt.s	.ok2			No Problems!

	add.l	d1,a0			Problems! -- Sod that line then!
	adda.l	#1,a0			Bump a0 past Line's CR

	lea	LineClippedText,a5
	bsr	PrintMessage
	move.b	#$ff,NoProcessMsg

	bra	FindLength

.ok2	cmpi.l	#0,d1			Blank line? (Just CR)
	beq.s	BlankLine
	cmpi.b	#$ff,PreFlag
	bne	No_Prefix
	bra	Do_Prefix

**********

BlankLine
	adda.l	#1,a0			Bump A0 past offending CR
	cmpi.b	#$ff,PreFlag
	bne.s	.No

	cmpi.b	#$ff,CentFlag
	bne.s	.Exit			Just do nothing

	lea	DCtext,a2
	move.l	#DCtextLen-1,d7
.Loop	move.b	(a2)+,(a1)+		Build "DC.B" Prefix
	move.b	(a2),$dff180		Supposed to make screen flicker->
	dbra	d7,.Loop		but it's a bit too quick!

	moveq.l	#0,d7
	move.w	FullWidth,d7
	subi.w	#1,d7			Correct D0 for DBRA loop
.Loop2	move.b	#$20,(a1)+		Print Space
	move.b	(a1),$dff180

	dbra	d7,.Loop2

	move.b	#"'",(a1)+		terminating "'"

.No	move.b	#$0a,(a1)+		CR
.Exit	bra	FindLength

**********

Do_Prefix
	lea	DCtext,a2
	move.l	#DCtextLen-1,d7
.Loop	move.b	(a2)+,(a1)+		Build "DC.B" Prefix
	move.b	(a2),$dff180
	dbra	d7,.Loop

No_Prefix
	move.l	d1,d2			d1 = Line's Length
	moveq.l	#0,d0

	cmpi.b	#$ff,PreFlag		Centre text if no prefix found
	bne.s	.OK

	cmpi.b	#$ff,CentFlag
	bne.s	DoText			Just do the text without pre-spaces

.OK	move.w	FullWidth,d0		Get screen's full width

	sub.l	d2,d0			Screen Width - Line Width
	and.l	#$fffffffe,d0		d1=even number (mask lsb)
	divu	#2,d0			Divide difference by 2

	subi.l	#1,d0			Correct D1 for DBRA Loop
	move.l	d0,d6			Save For Later!
	move.l	d0,d7
.Loop	move.b	#$20,(a1)+		Preceding Spaces
	move.b	(a1),$dff180
	dbra	d7,.Loop

DoText	move.l	d2,d7			Get Line Length
	sub.l	#1,d7			Correct D7 For DBRA Loop

.Loop2	cmpi.b	#"'",(a0)		GenAm takes ' to be '' in quotes
	bne.s	.Cont3

	cmpi.b	#$ff,PreFlag		Prfix requested?
	bne.s	.Cont3

	move.b	#"'",(a1)+		Double ['']s required 

.Cont3	move.b	(a0)+,(a1)+		Move byte from source to dest
	move.b	(a0),$dff180
	dbra	d7,.Loop2

	cmpi.b	#$ff,PreFlag
	bne.s	No_Prefix2

	cmpi.b	#$ff,CentFlag
	bne.s	.Cont			Just skip closing spaces

	move.l	d6,d7
.Loop3	move.b	#$20,(a1)+		Closing spaces
	move.b	(a1),$dff180
	dbra	d7,.Loop3

	cmpi.b	#$ff,CentFlag		Was a centre requested?
	beq.s	.Cont

	cmpi.b	#$ff,PreFlag		Was prefix requested?
	bne.s	.Cont

	move.b	#$20,(a1)+		Need another space!

.Cont	cmpi.b	#$ff,OddFlag
	bne.s	.Cont2
	move.b	#$20,(a1)+		Odd length lines require extra Byte!

.Cont2	move.b	#"'",(a1)+

No_Prefix2
	adda.l	#1,a0
	move.b	#$0a,(a1)+		Insert Return code

	move.l	SourceLength,d6
	move.l	a0,d5
	sub.l	SourceBuffer,d5
	cmp.l	d6,d5			End of Text?
	bge.s	Text_End		Branch if greater/equal

	bra	FindLength		Keep On Running.....

Text_End
	move.b	#$00,(a1)+		Null Terminator (just in case!)
	move.b	#$FF,PrcessFlag		So I know text has been processed

	cmp.b	#$ff,NoProcessMsg
	beq.s	.Cont

	lea	ProcessedText,a5
	bsr	PrintMessage

.Cont	bra	WaitForMsg

**********

Save	cmp.b	#$ff,PrcessFlag		Have we processed text?
	beq	.OK2		No? Don't try to save then!

	lea	NotLoadedText,a5
	bsr	PrintMessage

	bra	WaitForMsg

.OK2	lea	ReqStruct,A0
	move.l	ARPbase,A6
	CALLSYS	FileRequest		STICK REQUESTER UP

	TST.L	D0
	BNE.S	.OK			USER SELECTED A FILE?

	BRA	WaitForMsg		QUIT IF NO NAME

.OK	LEA	PathBuffer,A0
	LEA	FullBuffer,A1

.Loop	MOVE.B	(A0)+,(A1)		Copy Path to A Buffer
	TST.B	(A1)			Found NULL Terminator?
	BEQ.S	.Cont
	ADDA.L	#1,A1
	BRA	.Loop

.Cont	LEA	FullBuffer,A0
	LEA	FileBuffer,A1

	MOVE.L	ARPbase,A6
	CALLSYS	TackOn			Get Full Pathname

**********

GetSaveLength
	moveq.l	#0,d0
	move.l	DestBuffer,a0
.Loop	tst.b	(a0)+			Null Terminator?
	beq.s	.Cont
	addi.l	#1,d0
	bra.s	.Loop

	bra	WaitForMsg

.Cont	move.l	d0,SaveLength
	move.l	#FullBuffer,d1
	move.l	#MODE_NEWFILE,d2

	move.l	Dosbase,a6
	CALLSYS	Open			Open new file

	move.l	d0,SaveHD
	beq	WaitForMsg

	move.l	SaveHD,d1
	move.l	DestBuffer,d2
	move.l	SaveLength,d3

	CALLSYS	Write			Save our text!!!

	move.l	SaveHD,d1
	CALLSYS	Close			Close File

	lea	TextSavedText,a5
	bsr	PrintMessage

	bra	WaitForMsg

**********

*	MESSAGE PRINTER -- ENTRY:
*					A5 = POINTER TO TEXT

*		           EXIT:
*					BUGGER ALL!!

**********

PrintMessage

	bsr	ClearMessage		Clear old Message

	lea	MessageStruct,a0
	move.l	a5,it_IText(a0)		Stick string's address in IT struct	

	move.l	Intbase,a6
	CALLSYS	IntuiTextLength		Get pixel width of string

	move.l	#408,d1			Window's Width
	sub.l	d0,d1			Get Excess space
	divu	#2,d1			And divide by 2

	move.l	d1,d0
	moveq.l	#0,d1
	move.l	RPort,a0
	lea	MessageStruct,a1	Address of Intuitext Structure

	CALLSYS	PrintIText		Print the Message!!!

	rts

**********

ClearMessage
	move.l	RPort,a1
	move.l	#0,d0
	move.l	Gfxbase,a6

	CALLSYS	SetAPen			Crnt pen = BG colour

	move.l	RPort,a0		Window's rastport

	move.l	#21,d0			\
	move.l	#159,d1			 \ Definition of 
	move.l	#387,d2			 / Message box
	move.l	#166,d3			/

	CALLSYS	RectFill		Blank out message area

	rts

**********

Intname	DC.B	'intuition.library',0
	EVEN

Dosname	DC.B	'dos.library',0
	EVEN

Gfxname	DC.B	'graphics.library',0
	EVEN

PPname	DC.B	'powerpacker.library',0
	EVEN

ARPname	DC.B	'arp.library',0
	EVEN

Intbase		DC.L	0
Dosbase		DC.L	0
Gfxbase		DC.L	0
Powerbase	DC.L	0		'PPBASE' ALREADY DEFINED!
ARPbase		DC.L	0

WinPtr		DC.L	0
UserPort	DC.L	0
RPort		DC.L	0
SaveHD		DC.L	0
SaveLength	DC.L	0

SourceBuffer	DC.L	0
SourceLength	DC.L	0
DestBuffer	DC.L	0
DestLength	DC.L	0
FullWidth	DC.W	0

PreFlag		DC.B	0
CentFlag	DC.B	0
LoadFlag	DC.B	0
PrcessFlag	DC.B	0
DestUsed	DC.B	0
OddFlag		DC.B	0
NoProcessMsg	DC.B	0
		EVEN

MMmsg		dc.b	'Loaded..'
FullBuffer	DS.B	80

DCtext		DC.B	"	DC.B	'"
DCtextLen	EQU	*-DCtext
		EVEN

**********	STRUCTURES!!!

MainWindow
	DC.W	116,30			X/Y ORIGIN
	DC.W	408,175			WIDTH/HEIGHT
	DC.B	0,1			PEN COLOURS
	DC.L	CLOSEWINDOW+GADGETUP	IDCMP FLAGS
	DC.L	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE	WINDOW FLAGS
	DC.L	Load_Gadget		START OF GADGET LIST
	DC.L	0			CHECKMARK
	DC.L	WindowName		PONTER TO NAME
	DC.L	0,0			CUSTOM SCREEN/BITMAP
	DC.W	0,0			MIN WIDTH/HEIGHT
	DC.W	0,0			MAX WIDTH/HEIGHT
	DC.W	WBENCHSCREEN		SCREENTYPE

WindowName
	DC.B	'TEXTMASTER V1.10  ©1991 BY NEIL JOHNSTON',0
	EVEN

**********

Load_Gadget
	DC.L	Save_Gadget		NEXT GADGET
	DC.W	20,15			X/Y ORIGIN
	DC.W	172,26			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY		ACTIVATION FLAGS
	DC.W	BOOLGADGET		GADGET TYPES
	DC.L	Load_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	0			SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	Load			USER DATA

Load_Image
	DC.W	0,0			X/Y ORIGIN
	DC.W	172,26			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Load_Image_Data		POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

**********

Save_Gadget
	DC.L	Prefix_Gadget		NEXT GADGET
	DC.W	220,15			X/Y ORIGIN
	DC.W	166,26			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY		ACTIVATION FLAGS
	DC.W	BOOLGADGET		GADGET TYPES
	DC.L	Save_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	0			SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	Save			USER DATA

Save_Image
	DC.W	0,0			X/Y ORIGIN
	DC.W	166,26			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Save_Image_Data		POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

**********

Prefix_Gadget
	DC.L	Process_Gadget		NEXT GADGET
	DC.W	113,46			X/Y ORIGIN
	DC.W	180,26			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY+TOGGLESELECT	ACTIVATION FLAGS
	DC.W	BOOLGADGET		GADGET TYPES
	DC.L	Prefix_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	0			SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	Prefix			USER DATA

Prefix_Image
	DC.W	0,0			X/Y ORIGIN
	DC.W	180,26			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Prefix_Image_Data	POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

**********

Process_Gadget
	DC.L	Centre_Gadget		NEXT GADGET
	DC.W	92,108			X/Y ORIGIN
	DC.W	221,26			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY		ACTIVATION FLAGS
	DC.W	BOOLGADGET		GADGET TYPES
	DC.L	Process_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	0			SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	ProcessText		USER DATA

Process_Image
	DC.W	0,0			X/Y ORIGIN
	DC.W	221,26			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Process_Image_Data	POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

**********

Centre_Gadget
	DC.L	Width_Gadget		NEXT GADGET
	DC.W	95,77			X/Y ORIGIN
	DC.W	215,26			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY+TOGGLESELECT	ACTIVATION FLAGS
	DC.W	BOOLGADGET		GADGET TYPES
	DC.L	Centre_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	0			SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	Centre			USER DATA

Centre_Image
	DC.W	0,0			X/Y ORIGIN
	DC.W	215,26			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Centre_Image_Data	POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

**********

Width_Gadget
	DC.L	0			NEXT GADGET
	DC.W	272,142			X/Y ORIGIN
	DC.W	24,8			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY		ACTIVATION FLAGS
	DC.W	STRGADGET		GADGET TYPES
	DC.L	Width_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	Width_Info		SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	0			USER DATA

Width_Image
	DC.W	-166,-3			X/Y ORIGIN
	DC.W	194,13			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Width_Image_Data	POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

Width_Info
	DC.L	WidthBuffer		POINTER TO BUFFER
	DC.L	0			UNDO BUFFER
	DC.W	0			CHARACTER POSITION IN BUFFER
	DC.W	3			MAX NO CHARS+1 (TERMINATING NULL)
	DC.W	0			FIRST CHARACTER POSITION
	DC.W	0			UNDO POS
	DC.W	0			NUM CHARS IN BUFFER
	DC.W	0			NO OF CHARS DISPLAYED
	DC.W	0			CONTAINER LEFT OFFSET
	DC.W	0			CONTAINER TOP OFFSET
	DC.L	RPort			GADGET'S RASTPORT
	DC.L	0			LONGINT
	DC.L	0			ALTERNATIVE KEYMAP

WidthBuffer
	DC.B	'80',0
	EVEN

**********

ReqStruct
	DC.L	ReqText			REQUESTER TEXT
	DC.L	FileBuffer		FILENAME BUFFER
	DC.L	PathBuffer		PATHNAME BUFFER
	DC.L	0			WINDOW (0=WB)
	DC.B	0			NO SPECIAL FUNCTIONS
	DC.B	0			RESERVED 1
	DC.L	0			FUNCTION
	DC.L	0			RESERVED 2

ReqText
	DC.B	'TEXTMASTER V1.10',0
	EVEN

FileBuffer
	DS.B	40			SPACE FOR FILENAME

PathBuffer
	DS.B	60			SPACE FOR PATHNAME

**********

MessageStruct
	DC.B	1,0			FRONTPEN+BACKPEN
	DC.B	RP_JAM2,0		MODE+FILLBYTE
	DC.W	0			LEFTEDGE
	DC.W	160			TOPEDGE
	DC.L	0			DEFAULT FONT
	DC.L	0			STRING POINTER
	DC.L	0			NEXT TEXT

**********

MessageBorder
	DC.W	20			LEFTEDGE
	DC.W	158			TOPEDGE
	DC.B	1,0			FRONTPEN+BACKPEN
	DC.B	RP_JAM1,5		DRAWMODE+COUNT
	DC.L	BorderVectors		XY VECTORS
	DC.L	0			NO OTHER BORDER

**********

BorderVectors
	DC.W	0,0
	DC.W	368,0
	DC.W	368,11
	DC.W	0,11
	DC.W	0,0

**********				Messages!!!

WelcomeText
	DC.B	'Welcome To Textmaster V1.10',0

LoadErrText
	DC.B	'Could Not Load File!',0

NotLoadedText
	DC.B	'You Haven''t Loaded A File Yet!',0

NoMemText
	DC.B	'Out Of Memory!',0

ProcessedText
	DC.B	'Your Text Has Been Processed.',0

TextSavedText
	DC.B	'Your Text Has Been Saved.',0

LineClippedText
	DC.B	'Warning: A Line Has Been Clipped!',0

PrefixOnText
	DC.B	'Prefix Now On.',0

PrefixOffText
	DC.B	'Prefix Now Off.',0

CentreOnText
	DC.B	'Centre "DC.B" Text Now On.',0

CentreOffText
	DC.B	'Centre "DC.B" Text Now Off.',0

AlreadyProcessedText
	DC.B	'You''ve Already Processed The Text!',0

FileTooBigText
	DC.B	'Sorry! That File Is Bigger Than 20K!',0

**********

NoARPText	DC.B	'This Program Requires The ARP Library',10
NoARPTextLen	EQU	*-NoARPText
		EVEN

NoPPText	DC.B	'This Program Requires The PowerPacker Library',10
NoPPTextLen	EQU	*-NoPPText
		EVEN

**********

	SECTION	IMAGEDATA,DATA_C

**********

Load_Image_Data

	INCBIN	source:bitmaps/TM.LOAD.RAW

**********

Save_Image_Data

	INCBIN	source:bitmaps/TM.SAVE.RAW

**********

Process_Image_Data

	INCBIN	source:bitmaps/TM.PROCESS.RAW

**********

Prefix_Image_Data

	INCBIN	source:bitmaps/TM.PREFIX.RAW

**********

Width_Image_Data

	INCBIN	source:bitmaps/TM.WIDTH.RAW

**********

Centre_Image_Data

	INCBIN	source:bitmaps/TM.CENTRE.RAW

**********

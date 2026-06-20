*
*
*	TEXTMASTER: V1.0 (NOT FINISHED!!!)
*
*	©1991 BY NEIL JOHNSTON.
*
*
*	WARNING! THIS CODE HASN'T BEEN TESTED, AND HAS GOT SEVERAL BUGS,
*	SO DON'T EXPECT IT TO WORK PROPERLY YET!

;	Fixed bug so code now handles files that contain blank lines.
;	This required the addition of about five lines of code and one
;	data declaration. M.Meany, April 91.

;	Added custom sleeping pointer routines. M.Meany, April 91.

;	INCLUDED misc/easystart.i for WB startup code, MM.

;	Nice one Neil !

	SECTION	TEXTMASTER,CODE

**********

	INCDIR	SYS:INCLUDE/
	INCLUDE	EXEC/EXEC_LIB.I
	INCLUDE	EXEC/EXEC.I
	INCLUDE	INTUITION/INTUITION_LIB.I
	INCLUDE	INTUITION/INTUITION.I
;	INCLUDE	LIBRARIES/DOS_LIB.I
;	INCLUDE	LIBRARIES/DOS.I
	INCLUDE	MISC/ARPBASE.I
	INCLUDE	MISC/POWERPACKER_LIB.I
	INCLUDE	MISC/PPBASE.I

	INCLUDE	misc/easystart.i	for WB startup code

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

	LEA	PPname,A1
	MOVEQ.L	#0,D0
	MOVE.L	$4,A6
	CALLSYS	OpenLibrary
	MOVE.L	D0,Powerbase
	BEQ	CloseDos

	LEA	ARPname,A1
	MOVEQ.L	#0,D0
	MOVE.L	$4,A6
	CALLSYS	OpenLibrary
	MOVE.L	D0,ARPbase
	BEQ	ClosePP

**********

Main	LEA	MainWindow,A0
	MOVE.L	Intbase,A6
	CALLSYS	OpenWindow
	MOVE.L	D0,WinPtr		WINDOW OPEN?
	BEQ	FreeMemory		NO? QUIT...

	MOVE.L	D0,A0
	MOVE.L	wd_UserPort(A0),UserPort	SAVE USERPORT
	MOVE.L	wd_RPort(A0),RPort		SAVE RASTPORT

WaitForMsg
	bsr	PointerOff		Default Intuition pointer
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

	move.l	a0,-(sp)
	bsr	PointerOn		Display sleeping pointer
	move.l	(sp)+,a0
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

CloseLibs
	MOVE.L	$4,A6
	MOVE.L	ARPbase,A1
	CALLSYS	CloseLibrary
	
ClosePP
	MOVE.L	$4,A6
	MOVE.L	Powerbase,A1
	CALLSYS	CloseLibrary

CloseDos
	MOVE.L	Dosbase,A1
	CALLSYS	CloseLibrary

CloseInt
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
	BRA	WaitForMsg

Prefix_On
	MOVE.B	#$FF,PreFlag		FF = YES PREFIX!
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

	BRA	WaitForMsg

.OK2	MOVE.B	#$FF,LoadFlag		SO I KNOW A FILE WAS LOADED!

	BRA	WaitForMsg

**********

PROCess
	CMPI.B	#$FF,LoadFlag		FILE LOADED YET?
	BEQ.S	.OK
	BRA	WaitForMsg

.OK	
;	MOVE.L	SourceLength,D0
;	MULU	#10,D0			ALLOCATE BIGGER MEMSPACE FOR DEST
	move.l	#40000,d0		Alloc 'Bout 40K!
	MOVE.L	D0,DestLength
	MOVE.L	#MEMF_PUBLIC+MEMF_CLEAR,D1	CLEAR, PUBLIC MEMORY
	MOVE.L	$4,A6

	CALLSYS	AllocMem		GET DESTINATION MEMORY
	TST.L	D0
	BEQ	WaitForMsg		NO MEMORY = EXIT!

	move.b	#$ff,DestUsed		So We Can Deallocate it!
	MOVE.L	D0,DestBuffer		SAVE BUFFER ADDRESS

	MOVE.L	SourceBuffer,A0
	move.l	DestBuffer,A1

FindLength
	move.l	a0,-(sp)		Save A0 (Line Start Address)
	moveq.l	#0,d1

GetLength
	cmpi.b	#$0a,(a0)		Return Char ($0a)
	beq.s	GotLength
	addi.l	#1,d1			Line Length
	adda.l	#1,a0			Next Char
	bra.s	GetLength

GotLength
	move.l	(sp)+,a0		restore A0
	tst.l	d1			A BLANK LINE
	beq	BlankLine
	cmpi.b	#$ff,PreFlag
	bne.s	No_Prefix

Do_Prefix
	lea	DCtext,a2
	move.l	#DCtextLen-1,d7
.Loop	move.b	(a2)+,(a1)+		Build "DC.B" Prefix
	dbra	d7,.Loop

No_Prefix
	move.l	d1,d2			d1 = Line's Length
	moveq.l	#0,d0

	lea	WidthBuffer,a2		My VERY basic ASCII->INT Routine:
	move.b	(a2)+,d1
	sub	#$30,d1
	mulu	#10,d1

	move.b	(a2),d0
	sub	#$30,d0
	add.l	d1,d0			d0 = Integer Screen width value

	sub.l	d2,d0			Screen Width - Line Width
	and.l	#$fffffffe,d0		d1=even number (mask lsb)
	divu	#2,d0			Divide difference by 2

	subi.l	#1,d0			Correct D1 for DBRA Loop
	move.l	d0,d6			Save For Later!
	move.l	d0,d7
.Loop	move.b	#$20,(a1)+		Preceding Spaces
	dbra	d7,.Loop

	move.l	d2,d7			Get Line Length
	sub.l	#1,d7			Correct D7 For DBRA Loop

.Loop2	move.b	(a0)+,(a1)+
	dbra	d7,.Loop2

	cmpi.b	#$ff,PreFlag
	bne.s	No_Prefix2

	move.l	d6,d7
.Loop3	move.b	#$20,(a1)+		Preceding Spaces
	dbra	d7,.Loop3

	move.b	#"'",(a1)+

No_Prefix2
	adda.l	#1,a0
	move.b	#$0a,(a1)+		Insert Return code

	move.l	SourceLength,d6
	move.l	a0,d5
	sub.l	SourceBuffer,d5
	cmp.l	d5,d6			End of Text?
	beq.s	Text_End

	bra	FindLength		Keep On Running.....

Text_End
	move.b	#$00,(a1)+		Null Terminator (just in case!)
	move.b	#$FF,ProcessFlag	So I know text has been processed
	bra	WaitForMsg


BlankLine
	cmpi.b	#$ff,PreFlag		test if dc.b required
	bne.s	No_Prefix2		if not leave
	lea	BLtext,a2		else get addr of data
	move.l	#BLLen-1,d7		and its len
.Loop	move.b	(a2)+,(a1)+		Build "DC.B" Prefix
	dbra	d7,.Loop
	bra	No_Prefix2
**********

Save	cmp.b	#$ff,ProcessFlag	Have we processed text?
	bne	WaitForMsg		No? Don't try to save then!

	lea	ReqStruct,A0
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
.Loop	tst.b	(a0)+
	beq.s	.Cont
	addi.l	#1,d0
	bra.s	.Loop

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

	bra	WaitForMsg

;--------------	Routine to display custom sleeping pointer
;		M.Meany, April 91

PointerOn	move.l		WinPtr,a0
		lea		newptr,a1
		moveq.l		#16,d0
		move.l		d0,d1
		moveq.l		#0,d2
		move.l		d2,d3
		move.l		Intbase,a6
		CALLSYS		SetPointer
		rts

;--------------	Routine to display default Intuition pointer
;		M.Meany, April 91

PointerOff	move.l		WinPtr,a0
		move.l		Intbase,a6
		CALLSYS		ClearPointer
		rts

**********

Intname	DC.B	'intuition.library',0
	EVEN

Dosname	DC.B	'dos.library',0
	EVEN

PPname	DC.B	'powerpacker.library',0
	EVEN

ARPname	DC.B	'arp.library',0
	EVEN

Intbase		DC.L	0
Dosbase		DC.L	0
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

PreFlag		DC.B	0		PREFIX FLAG $FF = PRE-ON
LoadFlag	DC.B	0
ProcessFlag	DC.B	0
DestUsed	DC.B	0

FullBuffer	DS.B	80

DCtext		DC.B	"	DC.B	'"
DCtextLen	EQU	*-DCtext
		EVEN

BLtext		dc.b	'	DC.B	$0A'
BLLen		equ	*-BLtext
		even

**********	STRUCTURES!!!

MainWindow
	DC.W	116,30			X/Y ORIGIN
	DC.W	408,152			WIDTH/HEIGHT
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
	DC.B	'TEXTMASTER V1.0 - ©1991 BY NEIL JOHNSTON',0
	EVEN

**********

Load_Gadget
	DC.L	Save_Gadget		NEXT GADGET
	DC.W	20,20			X/Y ORIGIN
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
	DC.W	220,20			X/Y ORIGIN
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
	DC.W	103,56			X/Y ORIGIN
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
	DC.L	Width_Gadget		NEXT GADGET
	DC.W	83,92			X/Y ORIGIN
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
	DC.L	PROCess			USER DATA

Process_Image
	DC.W	0,0			X/Y ORIGIN
	DC.W	221,26			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Process_Image_Data	POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

**********

Width_Gadget
	DC.L	0			NEXT GADGET
	DC.W	262,130			X/Y ORIGIN
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
	DC.B	'TEXTMASTER V1.0 BY NEIL JOHNSTON',0
	EVEN

FileBuffer
	DS.B	40			SPACE FOR FILENAME

PathBuffer
	DS.B	60			SPACE FOR PATHNAME

**********

	SECTION	IMAGEDATA,DATA_C
	incdir	source:bitmaps/

**********

Load_Image_Data

	INCBIN	TM.LOAD.RAW

**********

Save_Image_Data

	INCBIN	TM.SAVE.RAW

**********

Process_Image_Data

	INCBIN	TM.PROCESS.RAW

**********

Prefix_Image_Data

	INCBIN	TM.PREFIX.RAW

**********

Width_Image_Data

	INCBIN	TM.WIDTH.RAW

**********




	section		pointer,data_c
newptr
	dc.w		$0000,$0000

	dc.w		$0000,$7ffe
	dc.w		$3ffc,$4002
	dc.w		$3ffc,$5ff6
	dc.w		$0018,$7fee
	dc.w		$0030,$7fde
	dc.w		$0060,$7fbe
	dc.w		$00c0,$7f7e
	dc.w		$0180,$7efe
	dc.w		$0300,$7dfe
	dc.w		$0600,$7bfe
	dc.w		$0c00,$77fe
	dc.w		$1ffc,$6ffa
	dc.w		$3ffc,$4002
	dc.w		$0000,$7ffe
	dc.w		$0000,$0000
	dc.w		$0000,$0000

	dc.w		$0000,$0000


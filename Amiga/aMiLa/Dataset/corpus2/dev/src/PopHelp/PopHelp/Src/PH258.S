; PopHelp v2.58(a) By MpL '94
;----------------------------
; $VER: PopHelp.S v1021
; This source code is freeware, but (C) Mika Lundell.
; Use it as you like. Compiles straight with A68k.
;
A68k ;Enable this if compiled with A68k and change all .x to x$ (eg. .1->1$)
		ifd	A68k				;CHANGE THEM IN INCLUDES TOO!!!
	;	include	'bb.i'
		endc
		ifnd	A68k
	;	incdir	'PopComp:PH258/Inc/'
	;	incdir	'PopData:Inc/'
		endc

		include	'Equs21.i'
		include	'InitMacros21.i'
		include	'Menus4.i'
		include	'Gadgets3.i'
		include	'Borders.i'
		include	'DataStuff31.i'
		include	'Gfx3.i'
		include	'VarTab2.i'

		xdef	_main

MsgY		equ	113
Msg2Y		equ	126
Msg3Y		equ	143
MsgX		equ	30

		section	PopHelp,CODE
_main		move.l	$4,a6
		move.l	#dm_SIZEOF,d0
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		tst.l	d0
		beq	CompleteFailure
		move.l	d0,a5
		cmpi.w	#36,LIB_VERSION(a6)
		bcs.s	1$
		bset	#NewKS,CTRL_4(a5)
1$		_InitVars

		move.l	#gm_SIZEOF,d0
		moveq	#MEMF_CHIP,d1
		jsr	AllocMem(a6)
		move.l	d0,GfxMem(a5)
		beq	CleanUp
		_InitGfxVars

		_OpenLib Dos
		_OpenLib Gfx
		_OpenLib I
		_OpenLib Math

		bsr	BuildBorders
		tst.b	BorderError(a5)
		bne	CleanUp
		bsr	BuildGadgets
		tst.b	GadgetError(a5)
		bne	CleanUp

		_InitIntStuff
		move.l	IBase(a5),a6
		move.l	a2,a0			; PHWindow
		jsr	OpenWindow(a6)
		move.l	d0,MyWindow(a5)
		beq	CleanUp
		move.l	d0,a0
		move.l	wd_RPort(a0),RPort(a5)
		_InitIntStuff2

		move.l	GfxBase(a5),a6
		lea	TextAttr(pc),a0
		jsr	OpenFont(a6)
		move.l	d0,Font(a5)
		beq	CleanUp
		move.l	RPort(a5),a1
		move.l	d0,a0
		jsr	SetFont(a6)

		bsr	BuildMenus
		tst.b	MenuError(a5)
		bne	CleanUp

		move.l	IBase(a5),a6
		move.l	MyWindow(a5),a0
		move.l	FirstMenu(a5),a1
		jsr	SetMenuStrip(a6)

		move.w	#$0411,d0
		bsr	FindMenuStruct
		move.l	$4,a6
		cmpi.b	#50,VBlankFrequency(a6)
		beq.s	2$	; Is_PAL
		move.l	mi_NextItem(a0),a0
2$		ori.w	#CHECKED,mi_Flags(a0)
		move.w	#$0421,d0
		bsr	FindMenuStruct
		btst	#NewKS,CTRL_4(a5)
		beq.s	3$
		move.l	mi_NextItem(a0),a0
3$		ori.w	#CHECKED,mi_Flags(a0)
		bsr	LoadPrefs

Begin		btst	#Exit,CTRL_1(a5)
		bne	CleanUp
		move.l	RPort(a5),a1
		move.l	a1,CurrRP(a5)
		move.l	MyWindow(a5),a0
		move.l	a0,IDCMPWin(a5)

		move.l	GfxBase(a5),a6
		move.b	wd_DetailPen(a0),d0
		move.b	wd_BlockPen(a0),d2
		move.l	a1,a2
		jsr	SetAPen(a6)
		move.l	a2,a1
		move.b	d2,d0
		jsr	SetBPen(a6)

		bsr	GetOldMsgs
		bsr	MenusOn
		move.l	MyWindow(a5),a0
		lea	PrgTitle(pc),a1
		moveq	#-1,d0
		move.l	d0,a2
		jsr	SetWindowTitles(a6)
		bsr	ArrowOn

Loop		subq.b	#1,VecCheck(a5)
		bne.s	NoChecking
		bsr	TakeVecs
		addq.b	#6,VecCheck(a5)

NoChecking	move.l	$4,a6
		moveq	#MEMF_CHIP,d1
		jsr	AvailMem(a6)
		move.l	d0,Para(a5)
		moveq	#MEMF_FAST,d1
		jsr	AvailMem(a6)
		move.l	d0,Para2(a5)

		move.l	DosBase(a5),a6
		lea	LONG_1(a5),a0		; 3 Longs
		move.l	a0,d1
		jsr	DateStamp(a6)

		move.l	LONG_2(a5),d0
		divu	#60,d0
		moveq	#0,d1
		move.w	d0,d1
		move.l	d1,Para3(a5)		; Hours
		swap	d0
		move.w	d0,d1
		move.l	d1,Para4(a5)		; Minutes
		move.l	LONG_3(a5),d0
		divu	#50,d0
		move.w	d0,d1
		move.l	d1,Para5(a5)		; Seconds

		btst	#NewKS,CTRL_4(a5)
		beq.s	2$
		move.l	GfxBase(a5),a6
		move.l	MyWindow(a5),a0
		move.l	CurrRP(a5),a1
		moveq	#1,d1
		ror.w	#3,d1		; ACTIVE
		move.l	wd_Flags(a0),d2
		moveq	#3,d0
		and.l	d1,d2
		bne.s	1$
		moveq	#0,d0
1$		jsr	SetBPen(a6)

2$		lea	TitleForm(pc),a0
		move.w	#285,d2
		moveq	#7,d3
		bsr	DpyMsg

		bsr	TakeIDCMP
		moveq	#0,d6
		lsr.l	#8,d2
		subq.b	#2,d2		; CLOSEWINDOW
		beq	CleanUp
		addq.b	#1,d2		; MENUPICK
		beq.s	MenuH

NoMenu		move.l	DosBase(a5),a6
		moveq	#45,d1
		jsr	Delay(a6)
		bra	Loop

MenuH		addq.w	#1,d3		; MENUNULL=$FFFF
		beq	Loop
		subq.w	#1,d3
		bsr	MenusOff

MenuHandle	moveq	#0,d6
		addq.w	#1,d3
		beq	Begin	; $FFFF
		subq.w	#1,d3

TakeItem	move.w	d3,d0
		andi.w	#$1f,d0
		move.w	d0,MenuNum(a5)
		move.w	d3,d0
		lsr.w	#5,d0
		move.w	d0,d1
		andi.w	#$3f,d0
		move.w	d0,ItemNum(a5)
		lsr.w	#6,d1
		move.w	d1,SubNum(a5)

		move.l	IBase(a5),a6
		move.l	FirstMenu(a5),a0
		move.w	d3,d0
		jsr	ItemAddress(a6)
		move.l	d0,a4

		move.l	a4,-(sp)
		move.w	#Msg3Y,CurrMsgY(a5)
		bset	#NumStrings,CTRL_1(a5)
		bsr.s	HandleItem
		move.l	(sp)+,a4
		move.w	mi_NextSelect(a4),d3
		move.w	#MENUNULL,mi_NextSelect(a4)
		bra.s	MenuHandle

HandleItem	move.w	MenuNum(a5),d0
		subq.b	#1,d0
		beq.s	CommsMenu
		subq.b	#1,d0
		beq	DiskMenu
		subq.b	#1,d0
		beq	SpecialMenu
		subq.b	#1,d0
		beq	PrefsMenu
		move.w	ItemNum(a5),d0
		beq	About
		bset	#Exit,CTRL_1(a5)
		rts

CommsMenu	move.w	ItemNum(a5),d0
		beq	Copy
		subq.b	#1,d0
		beq	Ren
		subq.b	#1,d0
		beq	Delete
		subq.b	#1,d0
		beq	MMove
		subq.b	#1,d0
		beq	MDir
		subq.b	#1,d0
		beq	Protect
		subq.b	#1,d0
		beq	Dir
		subq.b	#1,d0
		beq	Exe
		subq.b	#1,d0
		beq	FileNote
		subq.b	#1,d0
		beq	Type
		move.w	SubNum(a5),d0
		beq	SetClock_load
		subq.b	#1,d0
		beq	SetClock_save
		bra	SetClock_reset

DiskMenu	move.w	ItemNum(a5),d0
		beq	Relabel
		subq.b	#1,d0
		beq	Install
		subq.b	#1,d0
		beq	Format
		bra	DiskCopy

SpecialMenu	move.w	ItemNum(a5),d0
		subq.b	#1,d0
		beq	Create.fd
		subq.b	#1,d0
		beq	ShowGfx
		rts

PrefsMenu	move.w	ItemNum(a5),d0
		beq	TakeSize
		subq.b	#1,d0
		beq	TakeScreenMode
		subq.b	#1,d0
		beq	TakeBorders
		subq.b	#1,d0
		beq	TakeBADD
		subq.b	#1,d0
		beq	TakePointer
		bra	SavePrefs
		rts

About		lea	Empty_txt(pc),a2
		lea	Empty_txt(pc),a3
		moveq	#-1,d2
		bsr	RemGs
		move.l	StringGadget1(a5),a3
		moveq	#5,d7
		bsr	OffGs
		bsr	AddGs
        lea Empty_txt(pc),a3        ; BUGFIX ;-)
		bsr	BigWindow
		lea	PrgTitle(pc),a2
		bsr	SimpleMsg_xy
		lea	Cpr_txt(pc),a2
		move.w	#245,d0
		move.w	#Msg3Y,d1
		bsr	SimpleMsg
		lea	About2_txt(pc),a2
		bsr	SimpleMsg_xy
		lea	About3_txt(pc),a2
		bsr	SimpleMsg_xy
		bsr	KeyToCont_Sub
		bsr	SmallWindow
		bsr	RemGs
		move.l	StringGadget1(a5),a3
		moveq	#5,d7
		bsr	OnGs
		bsr	AddGs
		rts

Copy		lea	COPY_txt(pc),a2
		lea	TO_txt(pc),a3
		move.l	#Comment_txt,LONG_1(a5)
		move.l	#Flags_txt,LONG_2(a5)
		moveq	#2-1,d2
		bclr	#NumStrings,CTRL_1(a5)		; 0=2Parm 1=1Parm
		bsr	DoVakio
		beq.s	1$
		bsr	CopyIt
1$		bsr	SmallWindow
		rts

Ren		lea	REN_txt(pc),a2
		lea	AS_txt(pc),a3
		moveq	#-1,d2
		bclr	#NumStrings,CTRL_1(a5)
		bsr	DoVakio
		beq.s	1$
		bsr	RenameIt
1$		bsr	SmallWindow
		rts

Delete		lea	DEL_txt(pc),a2
		lea	Empty_txt(pc),a3
		move.l	#All_txt,LONG_1(a5)
		moveq	#1-1,d2
		bsr	DoVakio
		beq.s	1$
		lea	DeleteIt(pc),a1
		bsr	Public_DoIt
1$		bsr	SmallWindow
		bsr	String2On
		rts

MMove		lea	MOVE_txt(pc),a2
		lea	TO_txt(pc),a3
		moveq	#-1,d2
		bclr	#NumStrings,CTRL_1(a5)
		bsr	DoVakio
		beq.s	1$
		bset	#Command_Move,CTRL_2(a5)
		bset	#Option1,CTRL_3(a5)
		bset	#Option2,CTRL_3(a5)
		bsr	CopyIt
		bclr	#Command_Move,CTRL_2(a5)
1$		bsr	SmallWindow
		rts

MDir		lea	MDIR_txt(pc),a2
		lea	Empty_txt(pc),a3
		moveq	#-1,d2
		bsr	DoVakio
		beq.s	1$
		bsr	MakeTheDir
1$		bsr	SmallWindow
		bsr	String2On
		rts

Protect		lea	PROT_txt(pc),a2
		lea	Empty_txt(pc),a3
		move.l	#Hide_txt,LONG_1(a5)
		move.l	#Script_txt,LONG_2(a5)
		move.l	#Pure_txt,LONG_3(a5)
		move.l	#Archive_txt,LONG_4(a5)
		move.l	#Read_txt,LONG_5(a5)
		move.l	#Write_txt,LONG_6(a5)
		move.l	#Execute_txt,LONG_7(a5)
		move.l	#Delete_txt,LONG_8(a5)
		moveq	#8-1,d2
		bsr	DoVakio
		beq.s	1$
		lea	ProtectIt(pc),a1
		bsr	Public_DoIt
1$		bsr	SmallWindow
		bsr	String2On
		rts

Dir		lea	DIR_txt(pc),a2
		lea	Empty_txt(pc),a3
		move.l	#fd_txt,LONG_1(a5)
		move.l	#TrkDir_txt,LONG_2(a5)
		move.l	#LastDir_txt,LONG_3(a5)
		moveq	#3-1,d2
		bsr	DoVakio
		tst.b	d0
		bmi.s	1$
		bsr	BusyOn
		bsr	DirIt
		move.l	MyWindow(a5),IDCMPWin(a5)
		bsr	ArrowOn
1$		bsr	SmallWindow
		bsr	String2On
		rts

Exe		lea	EXE_txt(pc),a2
		lea	Empty_txt(pc),a3
		moveq	#-1,d2
		bsr	DoVakio
		beq.s	1$
		bsr	ExecuteIt
1$		bsr	SmallWindow
		bsr	String2On
		rts

FileNote	lea	NOTE_txt(pc),a2
		lea	COMMENT_txt(pc),a3
		moveq	#-1,d2
		bclr	#NumStrings,CTRL_1(a5)
		bsr	DoVakio
		tst.b	(a2)
		beq.s	1$			; Jos Kom.=0 -> Se Poistuu
		lea	FileNoteIt(pc),a1
		bsr	Public_DoIt
1$		bsr	SmallWindow
		rts

Type		lea	ASC_txt(pc),a2
		lea	Empty_txt(pc),a3
		moveq	#-1,d2
		bsr	DoVakio
		beq.s	1$
		bsr	BusyOn
		bsr	TypeIt
		move.l	MyWindow(a5),IDCMPWin(a5)
		bsr	ArrowOn
1$		bsr	SmallWindow
		bsr	String2On
		rts

SetClock_save	bsr	RemGs
		move.l	FirstDevGadget(a5),a3
		moveq	#3,d7
		bsr	OffGs
		bsr	AddGs
		lea	DATE_txt(pc),a2
		lea	Empty_txt(pc),a3
		moveq	#-1,d2
		bsr	DoVakio
		beq.s	1$
		bsr	SetClockIt
1$		bsr	SmallWindow
		bsr	RemGs
		move.l	StringGadget2(a5),a3
		moveq	#4,d7
		bsr	OnGs
		bsr	AddGs
		rts

Relabel		lea	REL_txt(pc),a2
		lea	NAME_txt(pc),a3
		moveq	#-1,d2
		bclr	#NumStrings,CTRL_1(a5)
		bsr	DoVakio
		beq.s	1$
		bsr	RelabelIt
1$		bsr	SmallWindow
		rts

Install		lea	INS_txt(pc),a2
		lea	Empty_txt(pc),a3
		move.l	#NoBoot_txt,LONG_1(a5)
		move.l	#FFS_txt,LONG_2(a5)
		moveq	#2-1,d2
		bsr	DoVakio
		beq.s	1$
		bsr	InstallIt
1$		bsr	SmallWindow
		bsr	String2On
		rts

DiskCopy	lea	SRC_txt(pc),a2
		lea	DEST_txt(pc),a3
		move.l	#Verify_txt,LONG_1(a5)
		move.l	#Date_txt,LONG_2(a5)
		moveq	#2-1,d2
		bclr	#NumStrings,CTRL_1(a5)
		bsr	DoVakio
		beq.s	1$
		bsr	DiskCopyIt
1$		bsr	SmallWindow
		rts

Format		lea	FORMAT_txt(pc),a2
		lea	NAME_txt(pc),a3
		move.l	#Quick_txt,LONG_1(a5)
		move.l	#Verify_txt,LONG_2(a5)
		move.l	#IText202,LONG_3(a5)
		move.l	#FFS_txt,LONG_4(a5)
		move.l	#BADD_txt,LONG_5(a5)
		moveq	#5-1,d2
		bclr	#NumStrings,CTRL_1(a5)
		bsr	DoVakio
		beq.s	1$
		bsr	FormatIt
1$		bsr	SmallWindow
		rts

Create.fd	lea	CREA_txt(pc),a2
		lea	Empty_txt(pc),a3
		moveq	#-1,d2
		bsr	DoVakio
		beq.s	1$
		bsr	CreateIt.fd
1$		bsr	SmallWindow
		bsr	String2On
		rts

ShowGfx		lea	GFX_txt(pc),a2
		lea	Empty_txt(pc),a3
		moveq	#-1,d2
		bsr	DoVakio
		beq.s	1$
		bsr	ShowGfxIt
1$		bsr	SmallWindow
		bsr	String2On
		rts

DoVakio		btst	#NumStrings,CTRL_1(a5)
		beq.s	TwoParas
		movem.l	a2-a3,-(sp)
		bsr	String2Off
		movem.l	(sp)+,a2-a3
TwoParas	bsr	BigWindow
		bsr	WaitStrings
		move.l	IBase(a5),a6
		move.l	MyWindow(a5),a0
		move.l	a2,a4
		move.b	d0,d4
		lea	WorkingTitle(pc),a1
		moveq	#-1,d0
		move.l	d0,a2
		jsr	SetWindowTitles(a6)
		move.l	a4,a2
		move.b	d4,d0
		btst	#NumStrings,CTRL_1(a5)
		bne.s	2$
		tst.b	(a3)
		beq.s	1$
2$		move.b	(a2),d1
1$		rts

PtrOff		movem.l	d2-d3,-(sp)
		move.l	IBase(a5),a6
		move.l	IDCMPWin(a5),a0
		move.l	OffPtr(a5),a1
		moveq	#1,d0
		moveq	#16,d1
		moveq	#0,d2
		moveq	#0,d3
		jsr	SetPointer(a6)
		movem.l	(sp)+,d2-d3
		rts

ArrowOn		bclr	#IsBusyPtrOn,CTRL_2(a5)
		btst	#PointerPtr,CTRL_2(a5)
		beq.s	PHPtrOff
		move.l	IBase(a5),a6
		move.l	IDCMPWin(a5),a0
		move.l	ArrowPtr(a5),a1
		moveq	#11,d0
		moveq	#16,d1
		moveq	#0,d2
		moveq	#0,d3
		jsr	SetPointer(a6)
		rts

BusyOn		bset	#IsBusyPtrOn,CTRL_2(a5)
BusyKey		move.l	IBase(a5),a6
		move.l	IDCMPWin(a5),a0
		move.l	BusyPtr(a5),a1
		moveq	#16,d0
		moveq	#16,d1
		moveq	#-6,d2
		moveq	#0,d3
		jsr	SetPointer(a6)
		rts

PHPtrOff	move.l	IBase(a5),a6
		move.l	IDCMPWin(a5),a0
		jsr	ClearPointer(a6)
		rts

**** Check If Jokers Used On String ****
CheckForJokers	bclr	#Jokers_Found,CTRL_2(a5); Extract path ja jokers
		move.l	JokerBuf(a5),a3		; -> df0:C/ and *.asm.?
		move.l	NoJokerPath(a5),a4
		clr.b	(a3)
		clr.b	(a4)
		move.l	a3,a1
		moveq	#0,d1

ExtractPath	move.b	(a2)+,d0
		bne.s	NotStringEnd
		moveq	#1,d1
		bra.s	AddToPath		; And quit=1
NotStringEnd	cmpi.b	#':',d0
		beq.s	AddToPath
		cmpi.b	#'/',d0
		beq.s	AddToPath
		cmpi.b	#'*',d0
		beq.s	EndNoJokerPath
		cmpi.b	#'?',d0
		beq.s	EndNoJokerPath
		move.b	d0,(a1)+
		bra.s	ExtractPath

AddToPath	move.b	d0,(a1)+
		clr.b	(a1)

		move.l	a3,a0
1$		move.b	(a0)+,(a4)+		; Add to path without jokers
		bne.s	1$
		subq.l	#1,a4
		move.l	a3,a1
		tst.b	d1			; End of chars?
		beq.s	ExtractPath
		bra.s	End_Joker

EndNoJokerPath	move.b	d0,(a1)+		; Joker(s) found...
1$		move.b	(a2)+,(a1)+
		bne.s	1$
		bset	#Jokers_Found,CTRL_2(a5)

End_Joker	btst	#Jokers_Found,CTRL_2(a5)
		bne.s	1$
		clr.b	(a3)

1$		move.l	JokerBuf(a5),a0		; jokeri pieniksi kirjaimiksi
2$		move.b	(a0),d0
		beq.s	3$
		bset	#5,d0
		move.b	d0,(a0)+
		bra.s	2$
3$		move.l	NoJokerPath(a5),a2
		rts

CheckMatch	move.l	d0,a0			; vastaako filename jokereita ?
		move.l	UseOnlyNowBuf(a5),a1	; -> XYZ.asm = *.asm

NameToLow	move.b	(a0)+,d1		; muutetaan myos FileName
		beq.s	1$			; valiaikaisesti pieniksi
		bset	#5,d1			; kirjaimiksi ja kopioidaan
		move.b	d1,(a1)+		; muualle...
		bra.s	NameToLow
1$		move.b	d1,(a1)

		move.l	JokerBuf(a5),a0		; varsinainen testaus alkaa
		move.l	UseOnlyNowBuf(a5),a1
Matchaa		move.b	(a0)+,d0		; mahtava rutiini...
		beq.s	J_2
1$		move.b	(a1)+,d1
		cmp.b	d0,d1
		beq.s	Matchaa
		cmpi.b	#'*',d0
		bne.s	NotTahti
		move.b	(a0)+,d0
		beq.s	Match
		cmpi.b	#'?',d0
		bne.s	J_3
		move.b	(a0)+,d0
		beq.s	Match
		cmpi.b	#'?',d0
		beq.s	1$
NoMatchko	move.b	(a1)+,d1
		beq.s	NoMatch
		cmp.b	d0,d1
		beq.s	Matchko
		bra.s	NoMatchko
Matchko		cmp.b	1(a1),d0
		bne.s	Matchaa
		bra.s	NoMatchko
NotTahti	cmpi.b	#'?',d0
		bne.s	NoMatch
		tst.b	d1
		beq.s	NoMatch
		bra.s	Matchaa
J_2		move.b	(a1)+,d1
		beq.s	Match
		bra.s	NoMatch
J_3		cmp.b	d0,d1
		beq.s	Matchaa
		move.b	(a1)+,d1
		bne.s	J_3
NoMatch		moveq	#-1,d0
		rts
Match		moveq	#0,d0
		rts

**** Public Joker-Routine ****
OrigSource	set	LONG_1
OrigDestin	set	LONG_2
TheName		set	LONG_3
TheRoutine	set	LONG_4
AddNameHere	set	LONG_6
NumToSkip	set	LONG_7

Public_DoIt	move.l	a1,TheRoutine(a5)
		move.l	a2,OrigSource(a5)
		move.l	a3,OrigDestin(a5)
		bclr	#Public_Jokers,CTRL_2(a5)
		clr.l	NumToSkip(a5)
		bsr	RemGs
		bsr	BusyOn

		move.l	a2,a0
1$		tst.b	(a0)+
		bne.s	1$
		subq.l	#2,a0
		cmpi.b	#':',(a0)		; DFx: not enough!
		bne.s	2$
		lea	MoreVol_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	Pub_Error
2$		cmpi.b	#'/',(a0)		; A/b/c/ = -censored- error!
		bne.s	Pub_GetStarted		;      ^ = -Stupid user-
		lea	MoreClear_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	Pub_Error

Pub_GetStarted	move.l	DosBase(a5),a6
		move.l	a2,d1
		moveq	#SHARED_LOCK,d2
		jsr	Lock(a6)
		move.l	d0,Lukko(a5)
		bne.s	Pub_WeGotPath
		btst	#Public_Jokers,CTRL_2(a5)
		bne.s	Pub_Checked
		bset	#Public_Jokers,CTRL_2(a5)
		bsr	CheckForJokers
		bra.s	Pub_GetStarted
Pub_Checked	bsr	LockErr_Sub
		bra	Pub_Error

Pub_WeGotPath	move.l	d0,d1
		move.l	FIB(a5),d2
		jsr	Examine(a6)
		tst.l	d0
		bne.s	1$
		bsr	ExamineErr_Sub
		bra	Pub_Error

1$		btst	#Public_Jokers,CTRL_2(a5)
		bne.s	Pub_DoPath
		move.l	Lukko(a5),d1
		jsr	UnLock(a6)
		clr.l	Lukko(a5)
		move.l	#DeleteIt,d0
		cmp.l	TheRoutine(a5),d0
		bne.s	OneEntry
		btst	#Option1,CTRL_3(a5)	; Delete ALL?
		beq.s	OneEntry

DeleteALL	move.l	OrigSource(a5),a2
		move.l	a2,a0
		move.l	fastBuf(a5),a1
1$		move.b	(a0)+,(a1)+
		bne.s	1$
		subq.l	#1,a0
		move.b	#'/',(a0)+
		move.b	#'*',(a0)+
		clr.b	(a0)
		bsr	Pub_GetStarted
		bclr	#Public_Jokers,CTRL_2(a5)
		move.l	fastBuf(a5),TheName(a5)
		bsr	DeleteIt
		move.l	fastBuf(a5),a0
		move.l	OrigSource(a5),a1	; Restore old string
2$		move.b	(a0)+,(a1)+
		bne.s	2$
		rts

OneEntry	move.l	OrigSource(a5),TheName(a5)
		move.l	TheRoutine(a5),a0
		jsr	(a0)
		bra	Pub_Clean

Pub_DoPath	move.l	NoJokerPath(a5),a0	; Create path where individual
		move.l	DestBuf(a5),a1		; filenames can be added
		tst.b	(a0)
		beq.s	3$
1$		move.b	(a0)+,(a1)+
		bne.s	1$
		subq.l	#2,a1
		cmpi.b	#':',(a1)
		beq.s	2$
		cmpi.b	#'/',(a1)
		beq.s	2$
		move.b	#'/',1(a1)
		addq.l	#1,a1
2$		addq.l	#1,a1
3$		move.l	a1,AddNameHere(a5)

Pub_DoLoop	cmpi.b	#$74,$bfec01
		beq.s	Pub_Clean
		move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		move.l	FIB(a5),d2
		jsr	ExNext(a6)
		tst.l	d0
		beq.s	Pub_Clean

		addq.l	#1,NumToSkip(a5)
		move.l	d2,a0
		tst.l	fib_DirEntryType(a0)
		bpl.s	Pub_DoLoop		; No subdirs
		lea	fib_FileName(a0),a2

		move.l	JokerBuf(a5),a0
		tst.b	(a0)	;JokerBuf
		beq.s	Pub_NoJoksUsed
		move.l	a2,d0
		bsr	CheckMatch
		bmi.s	Pub_DoLoop

Pub_NoJoksUsed	move.l	a2,a0
		move.l	AddNameHere(a5),a1
1$		move.b	(a0)+,(a1)+
		bne.s	1$
		move.l	DestBuf(a5),TheName(a5)
		move.l	TheRoutine(a5),a0
		jsr	(a0)
		bra.s	Pub_DoLoop

Pub_Error	bsr	KeyToCont_Sub

Pub_Clean	move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		beq.s	1$
		jsr	UnLock(a6)
		clr.l	Lukko(a5)
1$		bsr	AddGs
		rts

**** File/Dir-Copy/Move ****
OrigSource	set	LONG_1
OrigDestin	set	LONG_2
FileToCopy	set	LONG_3
SrcDirLock	set	LONG_4
SrcDirString	set	LONG_5
AddNamesHere	set	LONG_6
CopyBuffer	set	LONG_7
NumToSkip	set	LONG_8

CopyIt		move.l	a2,OrigSource(a5)
		move.l	a3,OrigDestin(a5)
		clr.l	SrcDirLock(a5)
		clr.l	CopyBuffer(a5)
		clr.l	NumToSkip(a5)
		bclr	#Jokers_Found,CTRL_2(a5)
		bclr	#Public_Jokers,CTRL_2(a5)
		bsr	RemGs
		bsr	BusyOn

StartCopy	move.l	DosBase(a5),a6
		move.l	a2,d1
		moveq	#SHARED_LOCK,d2
		jsr	Lock(a6)
		move.l	d0,Lukko(a5)
		bne.s	FinallyGotIt
		btst	#Public_Jokers,CTRL_2(a5)
		bne.s	CheckedForJoks
		bset	#Public_Jokers,CTRL_2(a5)
		bsr	CheckForJokers
		bra.s	StartCopy
CheckedForJoks	bsr	LockErr_Sub
		bra	Copy_Err

FinallyGotIt	move.l	d0,d1
		move.l	FIB(a5),d2
		jsr	Examine(a6)
		tst.l	d0
		bne.s	1$
		bsr	ExamineErr_Sub
		bra	Copy_Err

1$		move.l	d2,a0
		move.l	fib_Size(a0),FileLength(a5)
		lea	fib_FileName(a0),a1
		move.l	a1,FileToCopy(a5)
		move.l	fib_DirEntryType(a0),d2

		move.l	Lukko(a5),d1
		jsr	UnLock(a6)
		clr.l	Lukko(a5)

		tst.l	d2
		bpl.l	CopyDir
		bsr	CopyFile	; Copy one file
		bsr	AddGs
		btst	#Command_Move,CTRL_2(a5)
		beq	Copy_Clean
		tst.l	DidError(a5)
		bne	Copy_Clean
		move.l	OrigSource(a5),a0
		bsr	Simple_Delete
		bra	Copy_Clean

CopyDir		move.l	OrigSource(a5),a2
		btst	#Jokers_Found,CTRL_2(a5)
		beq.s	1$
		move.l	NoJokerPath(a5),a2
1$		move.l	OrigDestin(a5),a3
		move.l	a3,d1
		moveq	#SHARED_LOCK,d2
		jsr	Lock(a6)
		move.l	d0,Lukko(a5)
		bne.s	DestDirExists

		movem.l	a2-a3,-(sp)
		lea	CreaDestDir_txt(pc),a2
		bsr	SimpleMsg_xy
		bsr	WaitKey
		movem.l	(sp)+,a2-a3
		cmpi.b	#'y',d3
		bne	Copy_Err
		bsr	ClrMsgBorder
		move.l	DosBase(a5),a6
		move.l	a3,d1
		jsr	CreateDir(a6)
		tst.l	d0
		beq	Copy_Err

DestDirExists	move.l	d0,d1
		jsr	UnLock(a6)
		clr.l	Lukko(a5)

		move.l	a2,d1
		moveq	#SHARED_LOCK,d2
		jsr	Lock(a6)
		move.l	a2,SrcDirString(a5)
		move.l	d0,SrcDirLock(a5)
		beq	Copy_Err
		move.l	d0,d1
		move.l	DirFIB(a5),d2
		jsr	Examine(a6)
		tst.l	d0
		beq	Copy_Err

		move.l	Buf1(a5),a4
		move.l	a2,a0
		move.l	a4,a1
		tst.b	(a0)
		beq.s	3$
1$		move.b	(a0)+,(a1)+
		bne.s	1$

		subq.l	#2,a1
		cmpi.b	#':',(a1)
		beq.s	2$
		cmpi.b	#'/',(a1)
		beq.s	2$
		addq.l	#1,a1
		move.b	#'/',(a1)
2$		addq.l	#1,a1
3$		move.l	a1,AddNamesHere(a5)

CopyDirLoop	cmpi.b	#$74,$bfec01
		beq	DirCopy_Clean
		move.l	DosBase(a5),a6
		move.l	SrcDirLock(a5),d1
		move.l	DirFIB(a5),d2
		jsr	ExNext(a6)
		tst.l	d0
		bne.s	1$

		btst	#Jokers_Found,CTRL_2(a5)
		bne	DirCopy_Clean
		btst	#Command_Move,CTRL_2(a5)
		beq	DirCopy_Clean
		move.l	SrcDirLock(a5),d1
		jsr	UnLock(a6)
		clr.l	SrcDirLock(a5)
		move.l	OrigSource(a5),a0
		bsr	Simple_Delete
		bra	DirCopy_Clean

1$		addq.l	#1,NumToSkip(a5)
		move.l	d2,a0
		tst.l	fib_DirEntryType(a0)		; Ei subdirreja !
		bpl.s	CopyDirLoop
		move.l	fib_Size(a0),FileLength(a5)
		lea	fib_FileName(a0),a2
		move.l	a2,FileToCopy(a5)

		move.l	JokerBuf(a5),a0
		tst.b	(a0)	;JokerBuf
		beq.s	NoJokersUsed
		move.l	a2,d0
		bsr	CheckMatch
		bmi.s	CopyDirLoop	; nimi ei sovi jokeripatterniin !

NoJokersUsed	move.l	a2,a0
		move.l	AddNamesHere(a5),a1
1$		move.b	(a0)+,(a1)+
		bne.s	1$

		move.l	Buf1(a5),a2
		move.l	OrigDestin(a5),a3
		bsr	CopyFile
		btst	#Command_Move,CTRL_2(a5)
		beq	CopyDirLoop
		tst.l	DidError(a5)
		bne	CopyDirLoop
		bsr	Move_Delete
		bra	CopyDirLoop

DirCopy_Clean	move.l	DosBase(a5),a6
		move.l	SrcDirLock(a5),d1
		beq.s	1$
		jsr	UnLock(a6)
1$		bsr	KeyToCont_Sub
		bsr	AddGs
		bra	Copy_Clean

Move_Delete	move.l	DosBase(a5),a6
		move.l	SrcDirLock(a5),d1
		jsr	UnLock(a6)
		move.l	Buf1(a5),a0
		bsr	Simple_Delete
		tst.l	d0
		beq.s	Not_Deleted
Was_Deleted	subq.l	#1,NumToSkip(a5)
Not_Deleted	move.l	SrcDirString(a5),d1
		moveq	#SHARED_LOCK,d2
		jsr	Lock(a6)
		move.l	d0,SrcDirLock(a5)
		move.l	d0,d1
		move.l	DirFIB(a5),d2
		jsr	Examine(a6)
		move.l	NumToSkip(a5),d7
		beq.s	MoveDel_rts
		subq.l	#1,d7
1$		move.l	SrcDirLock(a5),d1
		jsr	ExNext(a6)
		dbf	d7,1$
MoveDel_rts	rts

Copying_Msg	movem.l	a2-a3,-(sp)
		lea	CopyingFrom_txt(pc),a0
		btst	#Command_Move,CTRL_2(a5)
		beq.s	1$
		lea	MovingFrom_txt(pc),a0
1$		move.l	a2,Para(a5)
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		lea	CopyingTo_txt(pc),a0
		move.l	4(sp),Para(a5)
		moveq	#MsgX,d2
		moveq	#Msg2Y,d3
		bsr	DpyMsg
		movem.l	(sp)+,a2-a3
		rts

CopyFile	clr.l	DidError(a5)
		move.l	DosBase(a5),a6
		move.l	a2,d1
		moveq	#SHARED_LOCK,d2
		jsr	Lock(a6)
		move.l	d0,Lokki1(a5)
		beq.s	1$
		move.l	d0,d1
		move.l	FIB(a5),d2		; Preserve this for later use
		jsr	Examine(a6)		; in comment&flags...
		move.l	Lokki1(a5),d1
		jsr	UnLock(a6)

1$		move.l	a2,SourceFile(a5)
		move.l	a2,d1
		move.l	#MODE_OLDFILE,d2
		jsr	Open(a6)
		move.l	d0,FileHandle1(a5)
		bne.s	ExamDestin
		jsr	IoErr(a6)
		move.l	d0,DidError(a5)

ExamDestin	move.l	DosBase(a5),a6
		move.l	a3,d1
		moveq	#SHARED_LOCK,d2
		jsr	Lock(a6)
		move.l	d0,Lukko(a5)
		beq	Begin_Copy

		move.l	d0,d1
		move.l	FIB2(a5),d2
		jsr	Examine(a6)
		tst.l	d0
		bne.s	1$
		bsr	ExamineErr_Sub
		bra	Copy_Err

1$		move.l	Lukko(a5),d1
		jsr	UnLock(a6)
		clr.l	Lukko(a5)

		move.l	d2,a0
		tst.l	fib_DirEntryType(a0)
		bmi.s	DestIsAFile

DestIsADir	move.l	DestBuf(a5),a4
		move.l	a4,a1
		tst.b	(a3)
		beq.s	CurrDir
1$		move.b	(a3)+,(a1)+
		bne.s	1$

		subq.l	#2,a1
		cmpi.b	#'/',(a1)
		beq.s	2$
		cmpi.b	#':',(a1)
		beq.s	2$
		addq.l	#1,a1
		move.b	#'/',(a1)
2$		addq.l	#1,a1

CurrDir		move.l	FileToCopy(a5),a0	; SrcNameAddr (from FIB1)
1$		move.b	(a0)+,(a1)+		; Add Src after Dir
		bne.s	1$
		move.l	a4,a3
		bra.s	ExamDestin

DestIsAFile	bsr	Copying_Msg
		movem.l	a2-a3,-(sp)
		lea	Replace_txt(pc),a2
		bsr	SimpleMsg_xy
		bsr	WaitKey
		movem.l	(sp)+,a2-a3
		move.b	d3,d7
		bsr	ClrMsgBorder
		cmpi.b	#'y',d7
		bne	Copy_Err2
		bra.s	BeginCopy

Begin_Copy	bsr	Copying_Msg
BeginCopy	tst.l	FileHandle1(a5)		; Was Src ok?
		bne.s	1$			; Changed to reduce disk-swaps
		bsr	CopyOpnSrcErr
		bra	Copy_Err

1$		moveq	#0,d2
		move.l	$4,a6
		btst	#AutoSize,CTRL_4(a5)
		beq.s	2$
		move.l	FileLength(a5),BufSize(a5)
2$		move.l	BufSize(a5),d0
		moveq	#MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		move.l	d0,CopyBuffer(a5)
		bne.s	4$

		btst	#AutoSize,CTRL_4(a5)	; If can't allocate FileLength
		beq.s	3$			; on AutoSize, try BufSize...
		tst.l	d2
		bne.s	3$
		move.l	SetBufSize(a5),d2
		lsl.l	#8,d2
		lsl.l	#2,d2
		move.l	d2,BufSize(a5)
		bra.s	2$
3$		lea	NoBufMem_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	Copy_Err

4$		move.l	DosBase(a5),a6
		move.l	(a3),d0
		moveq	#5,d1
		ror.l	#8,d0
		bclr	d1,d0
		ror.l	#8,d0
		bclr	d1,d0
		ror.l	#8,d0
		bclr	d1,d0
		ror.l	#8,d0

		cmpi.l	#'RAM:',d0
		beq.s	Mahtuu

NotRam		move.l	a3,d1
		move.l	#MODE_NEWFILE,d2
		jsr	Open(a6)
		move.l	d0,d4
		beq.s	Mahtuu

		move.l	d4,d1
		moveq	#0,d2
		moveq	#1,d3
		jsr	Write(a6)

		move.l	d4,d1
		jsr	Close(a6)

		move.l	a3,d1
		moveq	#SHARED_LOCK,d2
		jsr	Lock(a6)
		move.l	d0,d4
		beq.s	Mahtuu

		move.l	d4,d1
		move.l	FIB2(a5),d2		; InfoData -> FIBiin2
		jsr	Info(a6)
		move.l	d4,d1
		jsr	UnLock(a6)

		move.l	d2,a0
		move.l	id_NumBlocks(a0),d0
		move.l	id_NumBlocksUsed(a0),d1
		sub.l	d1,d0
		mulu	#488,d0
		cmp.l	FileLength(a5),d0
		bhi.s	Mahtuu

EiMahdu		move.l	a3,-(sp)
		lea	NoSpace_txt(pc),a2
		bsr	SimpleMsg_xy
		move.l	(sp)+,a0
		bsr	Simple_Delete
		bra	Copy_Err

Mahtuu		move.l	a3,DestinFile(a5)
		move.l	a3,d1
		move.l	#MODE_NEWFILE,d2
		jsr	Open(a6)
		move.l	d0,FileHandle2(a5)
		bne.s	1$
		move.l	a3,a2
		bsr	OpenFileErr_Sub
		bra	Copy_Err

1$		move.l	FileLength(a5),d0
		cmp.l	BufSize(a5),d0
		bhi.s	PieceCopy

FullCopy	move.l	FileLength(a5),d3	; Z if succeeded !
		bsr	ReadBytes		; -1 if not...
		bmi	Copy_Err
		bsr	DisposeHandle1

		bsr	WriteBytes
		bmi	Copy_Err
		bsr	DisposeHandle2
		bra.s	CpyOptions		; Everything OK

PieceCopy	move.l	FileLength(a5),d4
1$		cmp.l	BufSize(a5),d4
		bcs.s	NoMoreFullBuf

		move.l	BufSize(a5),d3
		bsr	ReadBytes
		bmi	Copy_Err

		bsr	WriteBytes
		bmi	Copy_Err

		move.l	BufSize(a5),d0
		sub.l	d0,d4
		bra.s	1$

NoMoreFullBuf	move.l	d4,d3
		bsr	ReadBytes
		bmi	Copy_Err
		bsr	DisposeHandle1

		bsr	WriteBytes
		bmi	Copy_Err
		bsr	DisposeHandle2

; Comment/Flags/Dates?
CpyOptions	tst.l	Lokki1(a5)		; FIB taken in beginning of
		beq.s	Copy_Clean		; 'CopyFile' to reduce swapping

Cpy_Comment	btst	#Option1,CTRL_3(a5)
		beq.s	Cpy_Flags

		move.l	FIB(a5),a2
		lea	fib_Comment(a2),a2
		tst.b	(a2)
		beq.s	Cpy_Flags
		move.l	DestinFile(a5),d1
		move.l	a2,d2
		jsr	SetComment(a6)

Cpy_Flags	btst	#Option2,CTRL_3(a5)
		beq.s	Copy_Clean

		move.l	DestinFile(a5),d1
		move.l	FIB(a5),a2
		move.l	fib_Protection(a2),d2
		jsr	SetProtection(a6)
		bra.s	Copy_Clean

Copy_Err	bsr	KeyToCont_Sub
		bsr	ClrMsgBorder
Copy_Err2	addq.b	#1,DidError(a5)
Copy_Clean	move.l	DosBase(a5),a6	; Accessed also from Read/WriteBytes!!!
		move.l	Lukko(a5),d1
		beq.s	1$
		jsr	UnLock(a6)
		clr.l	Lukko(a5)
1$		clr.l	Lokki1(a5)
		bsr.s	DisposeHandle1
		bsr.s	DisposeHandle2
		move.l	CopyBuffer(a5),d2
		beq.s	2$
		move.l	$4,a6
		move.l	BufSize(a5),d0
		move.l	d2,a1
		jsr	FreeMem(a6)
		clr.l	CopyBuffer(a5)
2$		rts

DisposeHandle1	move.l	DosBase(a5),a6
		move.l	FileHandle1(a5),d1
		beq.s	1$
		jsr	Close(a6)
		clr.l	FileHandle1(a5)
1$		rts
DisposeHandle2	move.l	DosBase(a5),a6
		move.l	FileHandle2(a5),d1
		beq.s	1$
		jsr	Close(a6)
		clr.l	FileHandle2(a5)
1$		rts

ReadBytes	move.l	FileHandle1(a5),d1
		move.l	CopyBuffer(a5),d2
		jsr	Read(a6)
		cmp.l	d3,d0
		bne.s	1$
		moveq	#0,d0
		rts
1$		jsr	IoErr(a6)
		move.l	d0,DidError(a5)
		bsr.s	Copy_Clean	; Can't do Delete() without this!!!
		move.l	DestinFile(a5),a0
		bsr.s	Simple_Delete
		lea	ReadErr_txt(pc),a2
		bsr	SimpleMsg_xy
		bsr	DErrDpyMsg
		moveq	#-1,d0
		rts

WriteBytes	move.l	FileHandle2(a5),d1
		move.l	CopyBuffer(a5),d2
		jsr	Write(a6)
		tst.l	d0
		bmi.s	1$
		moveq	#0,d0
		rts
1$		jsr	IoErr(a6)
		move.l	d0,DidError(a5)
		bsr	Copy_Clean
		move.l	DestinFile(a5),a0
		bsr.s	Simple_Delete
		lea	WriteErr_txt(pc),a2
		bsr	SimpleMsg_xy
		bsr	DErrDpyMsg
		moveq	#-1,d0
		rts

Simple_Delete	move.l	DosBase(a5),a6
		move.l	a0,d1
		jsr	DeleteFile(a6)
		rts

RenameIt	bsr	RemGs
		move.l	DosBase(a5),a6
		move.l	a2,d1
		move.l	a3,d2
		jsr	Rename(a6)
		tst.l	d0
		bne.s	1$
		move.l	#IText102,Para(a5)
		bsr	DOS_Err
1$		bsr	AddGs
		rts

**** Delete_Sub ****
NumToSkip	set	LONG_7

DeleteIt	move.l	TheName(a5),Para(a5)
		lea	Deleting_txt(pc),a0
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		beq.s	DelDo
		jsr	UnLock(a6)
		clr.l	Lukko(a5)
DelDo		move.l	TheName(a5),d1
		jsr	DeleteFile(a6)
		tst.l	d0
		bne.s	WasDeleted
		jsr	IoErr(a6)
		cmpi.w	#222,d0
		beq.s	1$
		move.l	#IText103,Para(a5)
		bsr	DOS_Err
		bra.s	NotDeleted
1$		lea	Protected_txt(pc),a2
		bsr	SimpleMsg_xy
		bsr	WaitKey
		move.b	d3,d7
		bsr	ClrMsgBorder
		cmpi.b	#'y',d7
		bne.s	NotDeleted
		move.l	DosBase(a5),a6
		move.l	TheName(a5),d1
		moveq	#0,d2
		jsr	SetProtection(a6)
		tst.l	d0
		bne.s	DelDo
		bra.s	NotDeleted
WasDeleted	subq.l	#1,NumToSkip(a5)
NotDeleted	move.l	DosBase(a5),a6
		btst	#Public_Jokers,CTRL_2(a5)
		beq.s	DelReturn
		move.l	NoJokerPath(a5),d1
		moveq	#SHARED_LOCK,d2
		jsr	Lock(a6)
		move.l	d0,Lukko(a5)
		beq.s	DelReturn
		move.l	d0,d1
		move.l	FIB(a5),d2
		jsr	Examine(a6)
		move.l	NumToSkip(a5),d7
		beq.s	DelReturn
		subq.l	#1,d7
1$		move.l	Lukko(a5),d1
		jsr	ExNext(a6)	; FIB in d2
		dbf	d7,1$
DelReturn	rts

MakeTheDir	bsr	RemGs
		move.l	DosBase(a5),a6
		move.l	UseOnlyNowBuf(a5),a3
		move.l	a3,a4

CreateLoop	move.b	(a2)+,d3
		beq.s	1$
		cmpi.b	#'/',d3
		beq.s	1$
		move.b	d3,(a3)+
		bra.s	CreateLoop

1$		clr.b	(a3)
		move.l	a4,d1
		moveq	#SHARED_LOCK,d2
		jsr	Lock(a6)
		tst.l	d0
		bne.s	2$
		bsr.s	CreateOne
2$		move.l	d0,d1
		beq.s	3$
		jsr	UnLock(a6)
3$		move.b	d3,(a3)+
		beq.s	4$
		tst.b	(a2)
		bne.s	CreateLoop
4$		bsr	AddGs
		rts

CreateOne	movem.l	d3/a2-a4/a6,-(sp)
		move.l	a4,Para(a5)
		lea	MakingDir_txt(pc),a0
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		movem.l	(sp),d3/a2-a4/a6

		move.l	a4,d1
		jsr	CreateDir(a6)
		tst.l	d0
		bne.s	1$
		move.l	#IText105,Para(a5)
		bsr	DOS_Err
		moveq	#0,d0
1$		movem.l	(sp)+,d3/a2-a4/a6
		rts

ProtectIt	move.l	TheName(a5),Para(a5)
		lea	Protecting_txt(pc),a0
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		move.l	DosBase(a5),a6
		move.l	TheName(a5),d1
		move.b	CTRL_3(a5),d0
		moveq	#0,d2
		btst	#Option1,d0	; H
		beq.s	1$
		bset	#7,d2
1$		btst	#Option2,d0	; S
		beq.s	2$
		bset	#6,d2
2$		btst	#Option3,d0	; P
		beq.s	3$
		bset	#5,d2
3$		btst	#Option4,d0	; A
		beq.s	4$
		bset	#4,d2
4$		btst	#Option5,d0	; R
		bne.s	5$
		bset	#3,d2
5$		btst	#Option6,d0	; W
		bne.s	6$
		bset	#2,d2
6$		btst	#Option7,d0	; E
		bne.s	7$
		bset	#1,d2
7$		btst	#Option8,d0	; D
		bne.s	8$
		bset	#0,d2
8$		jsr	SetProtection(a6)
		tst.l	d0
		bne.s	9$
		move.l	#IText106,Para(a5)
		bsr	DOS_Err
9$		rts

BeginDir	bclr	#FirstDir_avail,CTRL_1(a5)
	;	bclr	#FirstDir,CTRL_1(a5)
		bclr	#TDir,CTRL_1(a5)
		bclr	#OnlyHandler,CTRL_1(a5)
		bsr	OpnBWinWithFont
		beq.s	2$
		move.l	IBase(a5),a6
		move.l	RP(a5),d2
		move.l	d2,a0
		move.l	DirBorder(a5),a1
		move.l	a1,d3
		moveq	#7,d0
		moveq	#12,d1
		jsr	DrawBorder(a6)
		move.l	d2,a0
		move.l	d3,a1
		move.w	#321,d0
		moveq	#12,d1
		jsr	DrawBorder(a6)
		btst	#Option3,CTRL_3(a5)
		bne.s	3$			; (But NOT if this is LastDir)
		btst	#Option2,CTRL_3(a5)	; RemGs done earlier on TDir
		bne.s	1$
3$		bsr	RemGs
1$		moveq	#1,d0
2$		rts

DGadgsOff	bsr	RemIGs
		move.l	DownArrow1(a5),a3
		moveq	#12,d7
		bsr	OffGs
		bsr	AddIGs
		rts
DGadgsOn	bsr	RemIGs
		move.l	DownArrow1(a5),a3
		moveq	#5,d7
		bsr	OnGs
		move.l	DownArrow2(a5),a3
		moveq	#5,d7
		bsr	OnGs
		btst	#MousePickEnable,CTRL_1(a5)
		beq.s	NoFirstEnabled
		move.l	First_Gadget(a5),a3
		and.w	d0,gg_Flags(a3)
		move.l	GfxBase(a5),a6
		move.l	RP(a5),a1
		move.l	a1,d2
		moveq	#0,d0
		jsr	SetAPen(a6)
		move.l	d2,a1
		move.w	#152,d0
		moveq	#0,d1
		move.l	BetaWindow(a5),a0
		move.w	nw_Height(a0),d1	;BWinSize
		subi.b	#17,d1
		move.w	#198,d2
		move.l	d1,d3
		addq.l	#8,d3
		addq.l	#4,d3
		jsr	RectFill(a6)
NoFirstEnabled	bsr	AddIGs
		rts

InitDBufs	move.l	DirBufs(a5),a0
		clr.l	(a0)
		move.l	a0,CurrDBuf(a5)
		moveq	#4,d0
		move.l	d0,CurrDPos(a5)
		move.l	FileBufs(a5),a0
		clr.l	(a0)
		move.l	a0,CurrFBuf(a5)
		move.l	d0,CurrFPos(a5)
		rts

EndDBufs	move.l	CurrDBuf(a5),a0
		move.l	CurrDPos(a5),d0
		st.b	0(a0,d0.w)
		move.l	CurrFBuf(a5),a0
		move.l	CurrFPos(a5),d0
		st.b	0(a0,d0.w)
		rts

StartDStuff	clr.l	Dirs(a5)
		clr.l	Files(a5)
		clr.l	Bytes(a5)
		bset	#MousePickEnable,CTRL_1(a5)
	;	bclr	#FirstDir,CTRL_1(a5)
		move.l	a2,a4
		bsr	BusyOn
		bsr	DGadgsOff
		btst	#FirstDir_avail,CTRL_1(a5)
		bne.s	FDIsAvail
		move.l	a4,a0
		move.l	FirstPathBuf(a5),a1
1$		move.b	(a0)+,(a1)+
		bne.s	1$
FDIsAvail	move.l	a4,Para(a5)
		lea	DTitle_txt(pc),a0
		bsr	Dpy
		move.l	TxtBuffer(a5),a0
		move.l	UseOnlyNowBuf(a5),a1
1$		move.b	(a0)+,(a1)+
		bne.s	1$
		move.l	IBase(a5),a6
		move.l	BWindow(a5),a0
		move.l	UseOnlyNowBuf(a5),a1
		moveq	#-1,d0
		move.l	d0,a2
		jsr	SetWindowTitles(a6)
		rts

LockDir		move.l	DosBase(a5),a6
		move.l	a2,d1
		moveq	#SHARED_LOCK,d2
		jsr	Lock(a6)
		move.l	d0,Lukko(a5)
		bne.s	LockExam_ok
		jsr	IoErr(a6)
		move.l	d0,DidError(a5)
		lea	DirLockErr_txt(pc),a2
		bsr	SimpleMsg_xy
		bsr	DErrDpyMsg
		moveq	#-1,d0
		rts
LockExam_ok	moveq	#0,d0
		rts

ExamineLock	move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		move.l	FIB(a5),d2
		jsr	Examine(a6)
		tst.l	d0
		bne.s	LockExam_ok
		jsr	IoErr(a6)
		move.l	d0,DidError(a5)
		lea	DirExamErr_txt(pc),a2
		bsr	SimpleMsg_xy
		bsr	DErrDpyMsg
		moveq	#-1,d0
		rts

NotDir		lea	DirIsFile_txt(pc),a2
		bsr	SimpleMsg_xy
		rts			; This should probably be here ?!?

InitFirstBufs	move.l	Dirs(a5),FDs(a5)
		move.l	Files(a5),FFs(a5)
		move.l	Bytes(a5),FBs(a5)
		bsr	FlushFirstBufs

		move.l	$4,a6
		moveq	#8,d2		; 2048
		lsl.l	#8,d2
		move.l	DirBufs(a5),a2
		move.l	FirstDirBufs(a5),a3

CpyDBufs	bsr.s	CpyBuf_Sub
		clr.l	(a3)
		tst.l	(a2)
		beq.s	NoMoreDBs
		move.l	(a2),a2
		move.l	d2,d0
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		tst.l	d0
		beq.s	FirstBufErr
		move.l	d0,(a3)
		move.l	d0,a3
		bra.s	CpyDBufs

NoMoreDBs	move.l	FileBufs(a5),a2
		move.l	FirstFileBufs(a5),a3

CpyFBufs	bsr.s	CpyBuf_Sub
		clr.l	(a3)
		tst.l	(a2)
		beq.s	FirstBufsOK
		move.l	(a2),a2
		move.l	d2,d0
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		tst.l	d0
		beq.s	FirstBufErr
		move.l	d0,(a3)
		move.l	d0,a3
		bra.s	CpyFBufs

CpyBuf_Sub	move.l	a2,a0
		move.l	a3,a1
		move.w	d2,d7
		subq.w	#1,d7
1$		move.b	(a0)+,(a1)+
		dbf	d7,1$
		rts

FirstBufsOK	bset	#FirstDir_avail,CTRL_1(a5)
		move.l	DWinTBuf(a5),a0
		move.l	FirstTitleBuf(a5),a1
1$		move.b	(a0)+,(a1)+
		bne.s	1$
FirstBufErr	rts

HandleBufStuff	btst	#OnlyHandler,CTRL_1(a5)
		bne.s	DataHandler
	;	bsr	DGadgsOn		Moved to NoMore_Print...
		btst	#MousePickEnable,CTRL_1(a5)
		beq.s	PrintDirs
		bsr	ArrowOn

PrintDirs	move.l	PALNTSC(a5),d4
		tst.l	Dirs(a5)
		beq.s	PrintFiles
		clr.l	DNamNum(a5)
		bsr	Print_18D

PrintFiles	tst.l	Files(a5)
		beq.s	PrintData
		clr.l	FNamNum(a5)
		bsr	Print_18F

PrintData	bsr	PrintDiskData
		bsr	GetOldMsgs
		bset	#OnlyHandler,CTRL_1(a5)

DataHandler	tst.b	Seq(a5)			; Ei BusyLooppia !!!
		bne.s	EiWoiWentata		; PerfMon On Hyodyllinen, jep...
		bsr	WaitIDCMP
		bra.s	WastausWenttiin
EiWoiWentata	bsr	TakeIDCMP
WastausWenttiin	move.l	d2,d0
		lsr.l	#5,d0
		subq.b	#1,d0			; GADGETDOWN
		beq.s	DH_GadgetDown
		subq.b	#1,d0			; GADGETUP
		bne.s	DH_NotGadget
		move.l	d4,a0
		cmpi.w	#1,gg_GadgetID(a0)
		bne.s	DH_NotFirsti
		clr.b	Seq(a5)
		moveq	#1,d0
		rts
DH_NotFirsti	clr.b	Seq(a5)
		bra.s	DataHandler

DH_NotGadget	move.b	Seq(a5),d0
		beq.s	DH_NoSequenceOn
		rts

DH_NoSequenceOn	move.l	d2,d0
		subq.b	#MOUSEBUTTONS,d0
		bne.s	DH_NoMouseBut
		cmpi.w	#SELECTDOWN,d3
		bne.s	DH_NoMouseBut
		moveq	#2,d0
		rts

DH_NoMouseBut	lsr.l	#8,d2		; CLOSEWINDOW
		subq.b	#2,d2
		bne	DataHandler
		moveq	#-1,d0
		rts

DH_GadgetDown	clr.b	Seq(a5)
		move.l	d4,a0
		move.w	gg_GadgetID(a0),d0
		move.w	d0,d1
		subi.b	#30,d1
		bne.s	NotDUpSeq
		move.b	d0,Seq(a5)
NotDUpSeq	subq.b	#1,d1
		bne.s	NotDDownSeq
		move.b	d0,Seq(a5)
NotDDownSeq	subi.b	#9,d1
		bne.s	NotFUpSeq
		move.b	d0,Seq(a5)
NotFUpSeq	subq.b	#1,d1
		bne.s	NotFDownSeq
		move.b	d0,Seq(a5)
NotFDownSeq	rts

FPageDown	cmp.l	Files(a5),d4
		bcc	ComeBack

		move.l	FNamNum(a5),d0
		add.l	d4,d0
		move.l	Files(a5),d1
		sub.l	d4,d1
		subq.l	#1,d1
		cmp.l	d1,d0
		bhi.s	FBottom
		move.l	d0,FNamNum(a5)
		bsr	Print_18F
		bra	ComeBack

FBottom		cmp.l	Files(a5),d4
		bcc	ComeBack

		move.l	Files(a5),d0
		sub.l	d4,d0
		move.l	d0,FNamNum(a5)
		bra.s	Dwn_F

FDown		cmp.l	Files(a5),d4
		bcc	ComeBack

FDEnabled	move.l	Files(a5),d1
		sub.l	d4,d1
		subq.l	#1,d1
		move.l	FNamNum(a5),d0
		cmp.l	d1,d0
		bhi	ComeBack

		addq.l	#1,FNamNum(a5)
Dwn_F		bsr	Print_18F
		bra	ComeBack

FPageUp		cmp.l	Files(a5),d4
		bcc	ComeBack

		move.l	FNamNum(a5),d0
		sub.l	d4,d0
		bmi.s	FTop
		move.l	d0,FNamNum(a5)
		bsr	Print_18F
		bra	ComeBack

FTop		tst.l	Files(a5)
		beq	ComeBack
		clr.l	FNamNum(a5)
		bra.s	Up_F

FUp		cmp.l	Files(a5),d4
		bcc	ComeBack

FUEnabled	tst.l	FNamNum(a5)
		beq	ComeBack

		subq.l	#1,FNamNum(a5)
Up_F		bsr	Print_18F
		bra	ComeBack

DPageDown	cmp.l	Dirs(a5),d4
		bcc	ComeBack

		move.l	DNamNum(a5),d0
		add.l	d4,d0
		move.l	Dirs(a5),d1
		sub.l	d4,d1
		subq.l	#1,d1
		cmp.l	d1,d0
		bhi.s	DBottom
		move.l	d0,DNamNum(a5)
		bsr	Print_18D
		bra	ComeBack

DBottom		cmp.l	Dirs(a5),d4
		bcc	ComeBack
		move.l	Dirs(a5),d0
		sub.l	d4,d0
		move.l	d0,DNamNum(a5)
		bra.s	Dwn_D

DDown		cmp.l	Dirs(a5),d4
		bcc	ComeBack

DDEnabled	move.l	Dirs(a5),d1
		sub.l	d4,d1
		subq.l	#1,d1
		move.l	DNamNum(a5),d0
		cmp.l	d1,d0
		bhi	ComeBack

		addq.l	#1,DNamNum(a5)
Dwn_D		bsr	Print_18D
		bra	ComeBack

DPageUp		cmp.l	Dirs(a5),d4
		bcc	ComeBack

		move.l	DNamNum(a5),d0
		sub.l	d4,d0
		bmi.s	DTop
		move.l	d0,DNamNum(a5)
		bsr	Print_18D
		bra	ComeBack

DTop		tst.l	Dirs(a5)
		beq	ComeBack
		clr.l	DNamNum(a5)
		bra.s	Up_D

DUp		cmp.l	Dirs(a5),d4
		bcc	ComeBack

DUEnabled	tst.l	DNamNum(a5)
		beq	ComeBack

		subq.l	#1,DNamNum(a5)
Up_D		bsr	Print_18D
		bra	ComeBack

Print_18D	move.l	#11,x(a5)
		move.l	#22,y(a5)
		move.l	GfxBase(a5),a6
		move.l	RP(a5),a1
		moveq	#3,d0
		jsr	SetAPen(a6)
		move.l	DNamNum(a5),d7
		btst	#FirstDir,CTRL_1(a5)
		beq.s	1$
		move.l	FirstDirBufs(a5),a2
		bra.s	Print_18
1$		move.l	DirBufs(a5),a2
		bra.s	Print_18

Print_18F	move.l	#325,x(a5)
		move.l	#22,y(a5)
		move.l	GfxBase(a5),a6
		move.l	RP(a5),a1
		moveq	#1,d0
		jsr	SetAPen(a6)
		move.l	FNamNum(a5),d7
		btst	#FirstDir,CTRL_1(a5)
		beq.s	1$
		move.l	FirstFileBufs(a5),a2
		bra.s	Print_18
1$		move.l	FileBufs(a5),a2

Print_18	bsr	Jump52s
		bpl.s	NotMYet
		rts
NotMYet		tst.l	d7
		beq.s	StartOfString

		bsr	SearchName

StartOfString	move.l	d4,d7
		subq.l	#1,d7
.Find		bsr	Print_1
		add.w	#39,a2
		tst.b	(a2)
		bmi.s	.NxtBuf
.Loop		add.w	#9,y+2(a5)
		dbf	d7,.Find
.Err		rts
.NxtBuf		move.l	(a3),a2
		move.l	a2,d0
		beq.s	.Err
		move.l	a2,a3
		addq.l	#4,a2
		bra.s	.Loop

Print_1		move.l	CurrRP(a5),a1
		move.l	x(a5),d0
		move.l	y(a5),d1
		jsr	xMove(a6)
		move.l	CurrRP(a5),a1
		move.l	a2,a0
		moveq	#38,d0
		jsr	Text(a6)
		rts
********
Jump52s		move.l	d7,d0			; Optimized
		divu	#52,d0			; Hyppii kokonaisten
		move.w	d0,d1			; bufferien yli
		beq.s	Jumped			; -> ei tartte selata kaikkia
		subq.w	#1,d1			; lapi joka kerta...
1$		move.l	(a2),a2
		dbf	d1,1$
		moveq	#0,d7
		swap	d0
		move.w	d0,d7
Jumped		moveq	#0,d0
		move.l	a2,a3
		addq.l	#4,a2
		tst.b	(a2)
		rts
****
SearchName	add.w	#39,a2
		addq.l	#1,d0
1$		tst.b	(a2)
		bmi.s	2$
		cmp.l	d0,d7
		bne.s	SearchName
		rts
2$		move.l	(a3),a2
		move.l	a2,a3
		addq.l	#4,a2
		bra.s	1$

**** Handle .fastdir Directory ****
Handle.fastdir	move.l	Mem(a5),a2
		move.w	(a2)+,d5
		subq.w	#1,d5

fd_Loop		move.l	a2,Para(a5)
		tst.w	36(a2)
		beq.s	fd_File

fd_Dir		addq.l	#1,Dirs(a5)
		lea	DirForm(pc),a0
		move.l	a2,-(sp)
		bsr	Dpy
		move.l	(sp)+,a2

		bsr	DNamePut_Sub
fd_Cont		bmi.s	fd_Err
		add.w	#38,a2
		dbf	d5,fd_Loop
fd_Err		rts

fd_File		addq.l	#1,Files(a5)
		move.l	32(a2),d0
		move.l	d0,Para2(a5)
		add.l	d0,Bytes(a5)
		lea	FileForm(pc),a0
		move.l	a2,-(sp)
		bsr	Dpy
		move.l	(sp)+,a2

		bsr	FNamePut_Sub
		bra.s	fd_Cont

**** Directory ****
DirIt		btst	#Option3,CTRL_3(a5)
		bne.s	1$
		btst	#Option2,CTRL_3(a5)
		bne	TrackDirIt
1$		bsr	BeginDir
		beq	Dir_Clean

		btst	#Option3,CTRL_3(a5)
		beq.s	NoDirPtr
MemDir		move.l	BWindow(a5),d2
		move.l	d2,a0
		move.l	DWinTBuf(a5),a1
		btst	#FirstDir,CTRL_1(a5)
		beq.s	1$
		move.l	FirstTitleBuf(a5),a1
1$		moveq	#-1,d0
		move.l	d0,a2
		jsr	SetWindowTitles(a6)
		move.l	First_Gadget(a5),a0
		move.l	d2,a1
		sub.l	a2,a2
		jsr	OffGadget(a6)
		bsr	BusyOn
		move.l	MDs(a5),Dirs(a5)
		move.l	MFs(a5),Files(a5)
		move.l	MBs(a5),Bytes(a5)
		btst	#FirstDir,CTRL_1(a5)
		beq.s	2$
		move.l	FDs(a5),Dirs(a5)	; If FIRST was last in screen,
		move.l	FFs(a5),Files(a5)	; Bring IT back...
		move.l	FBs(a5),Bytes(a5)
2$		bclr	#MousePickEnable,CTRL_1(a5)
		bra	NoMore_Print

NoDirPtr	bsr	StartDStuff
		move.l	GfxBase(a5),a6
		move.l	RP(a5),a1
		moveq	#1,d0
		jsr	SetAPen(a6)

		move.l	a4,a2
		bsr	LockDir
		bmi	Dir_Err
		bsr	ExamineLock
		bmi	Dir_Err

		move.l	d2,a0
		tst.l	fib_DirEntryType(a0)
		bpl.s	Flushaa
		bsr	NotDir
		bra	Dir_Err

Flushaa		bclr	#FirstDir,CTRL_1(a5)
		move.l	UseOnlyNowBuf(a5),a0	; We really have a new dir and
		move.l	DWinTBuf(a5),a1		; old WILL be destoyed...
1$		move.b	(a0)+,(a1)+
		bne.s	1$
		move.l	IBase(a5),a6
		move.l	BWindow(a5),a0
		move.l	DWinTBuf(a5),a1
		moveq	#-1,d0
		move.l	d0,a2
		jsr	SetWindowTitles(a6)

		bsr	FlushDirBufs
		bsr	InitDBufs

		btst	#Option1,CTRL_3(a5)
		beq	Nofastdir
		move.l	a4,a0
		move.l	fastBuf(a5),a1
		move.l	a1,d2
2$		move.b	(a0)+,(a1)+
		bne.s	2$

		move.l	d2,a1
		tst.b	(a1)
		beq.s	NoExtPath
3$		tst.b	(a1)+
		bne.s	3$
		subq.l	#2,a1
		cmpi.b	#':',(a1)
		beq.s	4$
		cmpi.b	#'/',(a1)
		beq.s	4$
		addq.l	#1,a1
		move.b	#'/',(a1)
4$		addq.l	#1,a1

NoExtPath	lea	fd_txt(pc),a0
1$		move.b	(a0)+,(a1)+
		bne.s	1$

		move.l	DosBase(a5),a6
		move.l	a6,d6
		move.l	d2,d1
		move.l	#MODE_OLDFILE,d2
		jsr	Open(a6)
		move.l	d0,FileHandle1(a5)
		move.l	d0,d4
		beq.s	Nofastdir
		lea	Read.fast_txt(pc),a2
		moveq	#70,d0
		moveq	#80,d1
		bsr	SimpleMsg
		move.l	d6,a6
		move.l	d4,d1
		moveq	#0,d2
		moveq	#OFFSET_END,d3
		jsr	Seek(a6)
		move.l	d4,d1
		jsr	Seek(a6)
		move.l	d0,FileLength(a5)
		move.l	$4,a6
		moveq	#MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		move.l	d0,Mem(a5)
		beq.s	2$
		move.l	d6,a6
		move.l	d4,d1
		moveq	#0,d2
		moveq	#OFFSET_BEGINNING,d3
		jsr	Seek(a6)
		move.l	d4,d1
		move.l	Mem(a5),d2
		move.l	FileLength(a5),d3
		jsr	Read(a6)
		move.l	d4,d1
		jsr	Close(a6)
		bsr	Handle.fastdir
		move.l	$4,a6
		move.l	FileLength(a5),d0
		move.l	Mem(a5),a1
		jsr	FreeMem(a6)
		bra	AllGot

2$		move.l	DosBase(a5),a6
		move.l	d4,d1
		jsr	Close(a6)

Nofastdir	lea	ReadDir_txt(pc),a2
		moveq	#70,d0
		moveq	#80,d1
		bsr	SimpleMsg
		lea	ESCToCancel_txt(pc),a2
		moveq	#70,d0
		moveq	#90,d1
		bsr	SimpleMsg

NextEntry	cmpi.b	#$74,$bfec01
		bne.s	1$
		bsr	EndDBufs
		bra	Dir_Clean

1$		bsr	GetEntry
		beq.s	NextEntry

AllGot		bsr	EndDBufs
		move.l	Dirs(a5),MDs(a5)
		move.l	Files(a5),MFs(a5)
		move.l	Bytes(a5),MBs(a5)

		bsr	ClrDirScr
		btst	#FirstDir_avail,CTRL_1(a5)
		bne.s	NoMore_Print
		bsr	InitFirstBufs

NoMore_Print	bsr	DGadgsOn	; Moved from HandleBufStuff to prevent
NMP		moveq	#0,d0		; FIRST-Gadget from flashing when click
		bsr	HandleBufStuff
		tst.b	d0
		bmi	Dir_Clean
		move.l	PALNTSC(a5),d4
		move.b	d0,d1
		subq.b	#1,d1
		beq.s	Firsti
		subq.b	#1,d1
		beq.s	Selected
		bsr.s	CeePeeAm
		bra.s	NMP

Firsti		bsr	First_Sub
		bra.s	NMP

Selected	bsr	Selected_Sub
		bmi.s	NMP
		bra	NoDirPtr

CeePeeAm	subi.b	#30,d0
		beq	DUp
		subq.b	#1,d0
		beq	DDown
		subq.b	#1,d0
		beq	DPageDown
		subq.b	#1,d0
		beq	DPageUp
		subq.b	#1,d0
		beq	DBottom
		subq.b	#1,d0
		beq	DTop
		subq.b	#5,d0
		beq	FUp
		subq.b	#1,d0
		beq	FDown
		subq.b	#1,d0
		beq	FPageDown
		subq.b	#1,d0
		beq	FPageUp
		subq.b	#1,d0
		beq	FBottom
		subq.b	#1,d0
		beq	FTop
ComeBack	rts

;Rootti		move.l	StringSInfo1,a0
;OtaRootti	move.b	(a0)+,d0
;		beq.s	NoDev_2
;		cmpi.b	#':',d0
;		bne.s	OtaRootti
;		clr.b	(a0)
;		bra.s	NewDir_1
;NoDev_2	move.l	StringSInfo1,a0
;		clr.b	(a0)
;		bra.s	NewDir_1

PrintDiskData	move.l	GfxBase(a5),a6
		move.l	RP(a5),a1
		moveq	#1,d0
		jsr	SetAPen(a6)

		move.l	Dirs(a5),Para(a5)
		lea	NumDirs_txt(pc),a0
		moveq	#10,d2
		move.l	BetaWindow(a5),a1
		move.w	nw_Height(a1),d3	;BWinSize
		subi.b	#12,d3
		bsr	DpyMsg

		move.l	Files(a5),Para(a5)
		lea	NumFiles_txt(pc),a0
		move.w	#330,d2
		bsr	DpyMsg

		addq.w	#8,d3
		move.l	Bytes(a5),Para(a5)
		lea	NumBytes_txt(pc),a0
		bsr	DpyMsg

		move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		bne.s	1$			;NoMemory
		move.l	Kilos(a5),d0
		bra.s	2$			;Memory
1$		move.l	FIB(a5),d2		; InfoData -> FIBiin
		jsr	Info(a6)
		move.l	d2,a0
		move.l	id_NumBlocks(a0),d0
		move.l	id_NumBlocksUsed(a0),d1
		move.l	id_BytesPerBlock(a0),d7	; 488-OFS/512-FFS
		sub.l	d1,d0
		move.l	d0,d6	; BlksFree
		moveq	#4,d5
		lsl.l	#8,d5	; 1024

		move.l	MathBase(a5),a6
		move.l	d5,d0
		jsr	SPFlt(a6)
		move.l	d0,d5
		move.l	d6,d0
		jsr	SPFlt(a6)
		move.l	d0,d6
		move.l	d7,d0
		jsr	SPFlt(a6)
		move.l	d0,d7
		move.l	d6,d0
		move.l	d7,d1
		jsr	SPMul(a6)
		move.l	d5,d1
		jsr	SPDiv(a6)
		jsr	SPFix(a6)
		move.l	d0,Kilos(a5)		; This many kbs free

2$		move.l	d0,Para(a5)
		lea	KilosFree_txt(pc),a0
		moveq	#10,d2
		bsr	DpyMsg
		rts

GetEntry	move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		move.l	FIB(a5),d2
		jsr	ExNext(a6)
		tst.l	d0
		bne.s	MoreFiles
		moveq	#-1,d0
		rts

MoreFiles	move.l	d2,a0
		lea	fib_FileName(a0),a1
		move.l	a1,Para(a5)
		tst.l	fib_DirEntryType(a0)
		bmi.s	ItsAFile

ItsADirectory	addq.l	#1,Dirs(a5)
		lea	DirForm(pc),a0
		bsr	Dpy
		bsr	DNamePut_Sub
		rts

ItsAFile	lea	fib_Size(a0),a1
		move.l	(a1),Para2(a5)
		move.l	(a1),d0
		add.l	d0,Bytes(a5)
		addq.l	#1,Files(a5)
		lea	FileForm(pc),a0
		bsr	Dpy
		bsr	FNamePut_Sub
		rts

Dir_Err		bsr	WaitIDCMP
		lsr.l	#8,d2
		subq.b	#2,d2		; CLOSEWINDOW
		bne.s	Dir_Err
Dir_Clean	bsr	GetOldMsgs
		move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		beq.s	1$
		jsr	UnLock(a6)
		clr.l	Lukko(a5)
1$		move.l	IBase(a5),a6
		move.l	BWindow(a5),d2
		beq.s	2$
		move.l	d2,a0
		jsr	ClearPointer(a6)
		move.l	d2,a0
		jsr	CloseWindow(a6)
		clr.l	BWindow(a5)
2$		bsr	AddGs
		rts

**** Trackdisk Directory ****	; CHECKED
Memory1		set	LONG_1
Memory2		set	LONG_2
CurrentRoot	set	LONG_3
NumTab		set	LONG_4
NumNums		set	LONG_5
Swapper		set	LONG_6

TrackDirIt	clr.l	Memory1(a5)
		clr.l	Memory2(a5)
		clr.l	CurrentRoot(a5)
		clr.b	WhichTD(a5)
		bsr	RemGs
		bsr	GetDiskUnitNum
		bmi	TD_Err
		bsr	PrepareUnit
		bmi	TD_Err
		bsr	BeginDir
		beq	TD_Clean

		move.l	$4,a6
		moveq	#4,d0
		lsl.l	#8,d0		; 1024
		move.l	#MEMF_CLEAR!MEMF_CHIP,d1
		jsr	AllocMem(a6)
		move.l	d0,Memory1(a5)
		bne.s	1$
		lea	NoBufMem_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	TD_CLOSEWIN_Err		;TD_Err
1$		addi.l	#512,d0
		move.l	d0,Memory2(a5)

TD_NewDir	move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		beq.s	1$
		jsr	UnLock(a6)
		clr.l	Lukko(a5)

1$		bsr	StartDStuff
		move.l	a4,a2

		bsr	LockDir
		bmi	TD_CLOSEWIN_Err		;TD_Err
		bsr	ExamineLock
		bmi	TD_CLOSEWIN_Err		;TD_Err
		move.l	d2,a0
		tst.l	fib_DirEntryType(a0)
		bmi	TD_Clean
		move.l	fib_DiskKey(a0),d0
		lsl.l	#8,d0
		lsl.l	#1,d0	; *512
		move.l	d0,CurrentRoot(a5)

		bclr	#FirstDir,CTRL_1(a5)
		move.l	UseOnlyNowBuf(a5),a0
		move.l	DWinTBuf(a5),a1
2$		move.b	(a0)+,(a1)+
		bne.s	2$
		move.l	IBase(a5),a6
		move.l	BWindow(a5),a0
		move.l	DWinTBuf(a5),a1
		moveq	#-1,d0
		move.l	d0,a2
		jsr	SetWindowTitles(a6)

		lea	ReadTDir_txt(pc),a2
		moveq	#70,d0
		moveq	#80,d1
		bsr	SimpleMsg
		lea	ESCToCancel_txt(pc),a2
		moveq	#70,d0
		moveq	#90,d1
		bsr	SimpleMsg

		move.l	$4,a6
		moveq	#2,d0
		lsl.l	#8,d0
		moveq	#CMD_READ,d1
		move.l	IOReq0(a5),a1
		move.l	CurrentRoot(a5),IO_OFFSET(a1)
		move.l	d0,IO_LENGTH(a1)
		move.l	Memory1(a5),IO_DATA(a1)
		move.w	d1,IO_COMMAND(a1)
		jsr	DoIO(a6)

		move.l	Memory1(a5),a0
		lea	24(a0),a0
		move.l	a0,NumTab(a5)
		moveq	#72,d0
		move.l	d0,NumNums(a5)
		bsr	SmallestFirst

		bsr	FlushDirBufs
		bsr	InitDBufs

		move.l	Memory1(a5),a4
		add.w	#24,a4
		moveq	#$48-1,d5

TD_NextEntry	cmpi.b	#$74,$bfec01
		beq.s	TD_Break
		move.l	(a4)+,d0
		beq.s	1$
		bsr.s	GetTDEntry
		bmi.s	EntryError
1$		dbf	d5,TD_NextEntry
		bsr	EndDBufs
		move.l	Dirs(a5),MDs(a5)
		move.l	Files(a5),MFs(a5)
		move.l	Bytes(a5),MBs(a5)
		bsr	ClrDirScr
		btst	#FirstDir_avail,CTRL_1(a5)
		bne	TD_Wait
		bsr	InitFirstBufs
		bra	TD_Wait

EntryError	bsr	EndDBufs
		move.l	Dirs(a5),MDs(a5)
		move.l	Files(a5),MFs(a5)
		move.l	Bytes(a5),MBs(a5)
		bsr	InitFirstBufs
		bra	TD_Clean
TD_Break	bsr	EndDBufs
		bra	TD_Clean

GetTDEntry	move.l	$4,a6
		moveq	#2,d1
		lsl.l	#8,d1
		mulu	d1,d0
		move.l	IOReq0(a5),a1
		move.l	d0,IO_OFFSET(a1)
		move.l	d1,IO_LENGTH(a1)
		move.l	Memory2(a5),IO_DATA(a1)
		move.w	#CMD_READ,IO_COMMAND(a1)
		jsr	DoIO(a6)

		move.l	Memory2(a5),a2
		moveq	#-3,d0		; $fffffffd
		cmp.l	508(a2),d0
		beq.s	TD_ItsAFile

		bsr	CpyNam_Sub
		move.l	UseOnlyNowBuf(a5),Para(a5)
		lea	DirForm(pc),a0
		bsr	Dpy
		addq.l	#1,Dirs(a5)

		move.l	a4,-(sp)
		bsr	DNamePut_Sub
		move.l	(sp)+,a4
		bpl.s	GotTDEntry
		rts

TD_ItsAFile	bsr	CpyNam_Sub
		move.l	UseOnlyNowBuf(a5),Para(a5)
		move.l	324(a2),d0
		move.l	d0,Para2(a5)
		add.l	d0,Bytes(a5)
		lea	FileForm(pc),a0
		bsr	Dpy
		addq.l	#1,Files(a5)

		move.l	a4,-(sp)
		bsr	FNamePut_Sub
		move.l	(sp)+,a4
		bpl.s	GotTDEntry
		rts

GotTDEntry	move.l	Memory2(a5),a2
		move.l	496(a2),d0
		bne	GetTDEntry		; more hash
		rts

TD_Wait		bsr	Motor0Off
TDNoMore_Print	bsr	DGadgsOn
TDNMP		moveq	#0,d0
		bsr	HandleBufStuff
		tst.b	d0
		bmi.s	TD_Clean
		move.l	PALNTSC(a5),d4
		move.b	d0,d1
		subq.b	#1,d1
		beq.s	TDFirsti
		subq.b	#1,d1
		beq.s	TDSelected
		bsr	CeePeeAm
		bra.s	TDNMP

TDFirsti	bsr	First_Sub
		bra.s	TDNMP

TDSelected	bsr	Selected_Sub
		bmi.s	TDNMP
		bra	TD_NewDir

TD_CLOSEWIN_Err	bsr	WaitIDCMP
		lsr.l	#8,d2
		subq.b	#2,d2		; CLOSEWINDOW
		bne.s	TD_CLOSEWIN_Err
		bra.s	TD_Clean

TD_Err		bsr	KeyToCont_Sub

TD_Clean	tst.b	DeviceFlag0(a5)
		beq.s	1$
		bsr	Motor0Off
1$		bsr	TrackClean
		move.l	Memory1(a5),d0
		beq.s	2$
		move.l	d0,a1
		moveq	#2,d0
		lsl.l	#8,d0
		jsr	FreeMem(a6)
2$		move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		beq.s	3$
		jsr	UnLock(a6)
		clr.l	Lukko(a5)
3$		bsr	GetOldMsgs
		move.l	BWindow(a5),d2
		beq.s	4$
		bsr	PHPtrOff
		move.l	d2,a0
		jsr	CloseWindow(a6)
		clr.l	BWindow(a5)
4$		bsr	AddGs
		rts

CpyNam_Sub	lea	432(a2),a0		; Get entry name
		move.l	UseOnlyNowBuf(a5),a1
		moveq	#0,d7
		move.b	(a0)+,d7
		subq.b	#1,d7
1$		move.b	(a0)+,(a1)+
		dbf	d7,1$
		clr.b	(a1)
		rts

****************
First_Sub	clr.b	Seq(a5)
		bclr	#OnlyHandler,CTRL_1(a5)
		btst	#FirstDir_avail,CTRL_1(a5)
		beq.s	2$
		bset	#FirstDir,CTRL_1(a5)
		move.l	FDs(a5),Dirs(a5)
		move.l	FFs(a5),Files(a5)
		move.l	FBs(a5),Bytes(a5)
		move.l	IBase(a5),a6
		move.l	BWindow(a5),a0
		move.l	FirstTitleBuf(a5),a1
		moveq	#-1,d0
		move.l	d0,a2
		jsr	SetWindowTitles(a6)
		move.l	FirstPathBuf(a5),a0
		move.l	StringGadget1(a5),a1
		move.l	gg_SIZEOF+si_Buffer(a1),a1
1$		move.b	(a0)+,(a1)+
		bne.s	1$
		bsr	ClrDirScr
2$		rts

Selected_Sub	clr.b	Seq(a5)
		bclr	#OnlyHandler,CTRL_1(a5)
		btst	#MousePickEnable,CTRL_1(a5)
		beq	Selected_Fail
		moveq	#0,d5		; must
		moveq	#0,d6		; be!
		move.w	MusseX(a5),d5
		move.w	MusseY(a5),d6
		subq.w	#2,d6

		cmpi.w	#14,d6
		bcs	Selected_Fail
		move.l	BetaWindow(a5),a0
		move.w	nw_Height(a0),d0	;BWinSize
		subi.b	#25,d0
		cmp.w	d0,d6
		bhi	Selected_Fail
		cmpi.w	#315,d5
		bhi	Selected_Fail

		subi.w	#13,d6
		divu	#9,d6
		andi.l	#$0000ffff,d6
		add.l	DNamNum(a5),d6
		move.l	Dirs(a5),d5
		subq.l	#1,d5
		cmp.l	d5,d6
		bhi	Selected_Fail
		move.l	d6,d7

		move.l	FirstDirBufs(a5),a2
		btst	#FirstDir,CTRL_1(a5)
		bne.s	1$
		move.l	DirBufs(a5),a2
1$		bsr	Jump52s
		bmi	Selected_Fail
		tst.l	d7
		beq.s	StartOfString2
		bsr	SearchName

StartOfString2	move.l	StringGadget1(a5),a0
		move.l	gg_SIZEOF+si_Buffer(a0),a0
		move.l	a0,a1
		addq.l	#1,a1
1$		tst.b	(a0)+
		bne.s	1$
		cmp.l	a0,a1
		bne.s	NotEmpty
		subq.l	#1,a0
		bra.s	CpyIt
NotEmpty	subq.l	#2,a0
		cmpi.b	#':',(a0)
		beq.s	Device
		cmpi.b	#'/',(a0)
		beq.s	Device
		addq.l	#1,a0
		move.b	#'/',(a0)+
		bra.s	CpyIt
Device		addq.l	#1,a0
CpyIt		move.b	(a2)+,d0
		cmpi.b	#' ',d0
		beq.s	CheckIfEnd
		move.b	d0,(a0)+
		bra.s	CpyIt
CheckIfEnd	move.b	(a2)+,d0
		cmpi.b	#' ',d0
		beq.s	ItIsEnd
		move.b	#' ',(a0)+
		move.b	d0,(a0)+
		bra.s	CpyIt
ItIsEnd		clr.b	(a0)
		move.l	StringGadget1(a5),a2
		move.l	gg_SIZEOF+si_Buffer(a2),a2
		move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		jsr	UnLock(a6)
		clr.l	Lukko(a5)
		bsr	ClrDirScr
		moveq	#0,d0
		rts
Selected_Fail	moveq	#-1,d0
		rts
****
DNamePut_Sub	move.l	CurrDBuf(a5),a4
		move.l	CurrDPos(a5),d6
		bsr.s	Cpy1Nam

		move.l	d6,CurrDPos(a5)
		cmpi.w	#2025,d6
		bcs.s	1$		; NotFull
		bsr.s	AddBlock
		bmi.s	2$		; Error
		move.l	a0,CurrDBuf(a5)
		moveq	#4,d0
		move.l	d0,CurrDPos(a5)
1$		moveq	#0,d0
2$		rts

FNamePut_Sub	move.l	CurrFBuf(a5),a4
		move.l	CurrFPos(a5),d6
		bsr.s	Cpy1Nam

		move.l	d6,CurrFPos(a5)
		cmpi.w	#2025,d6
		bcs.s	1$
		bsr.s	AddBlock
		bmi.s	2$
		move.l	a0,CurrFBuf(a5)
		moveq	#4,d0
		move.l	d0,CurrFPos(a5)
1$		moveq	#0,d0
2$		rts

Cpy1Nam		move.l	TxtBuffer(a5),a0
		moveq	#38,d7
1$		move.b	(a0)+,0(a4,d6.l)
		addq.l	#1,d6
		dbf	d7,1$
		rts

AddBlock	move.l	$4,a6
		moveq	#8,d0
		lsl.l	#8,d0
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		tst.l	d0
		beq.s	1$
		move.l	d0,a0
		move.l	d0,(a4)
		st.b	0(a4,d6.l)
		moveq	#0,d0
		rts
1$		st.b	0(a4,d6.l)
		moveq	#-1,d0
		rts

********
ExecuteIt	bsr	BusyOn
		bsr	RemGs
		move.l	DosBase(a5),a6
		lea	CONFile(pc),a0
		move.l	a0,d1
		move.l	#MODE_NEWFILE,d2
		jsr	Open(a6)
		move.l	d0,FileHandle1(a5)
		beq.s	2$

		move.l	a2,d1
		moveq	#0,d2
	;	moveq	#0,d3
	;	move.l	FileHandle1(a5),d2
		move.l	FileHandle1(a5),d3
		jsr	Execute(a6)

		move.l	DosBase(a5),a6
		move.l	FileHandle1(a5),d1
		jsr	Close(a6)
1$		bsr	AddGs
		rts
2$		move.l	#IText110,Para(a5)
		bsr	DOS_Err
		bra.s	1$

**** FileNote_Sub ****
OrigDestin	set	LONG_2

FileNoteIt	move.l	TheName(a5),Para(a5)
		lea	Noting_txt(pc),a0
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		move.l	DosBase(a5),a6
		move.l	TheName(a5),d1
		move.l	OrigDestin(a5),d2
		jsr	SetComment(a6)
		tst.l	d0
		bne.s	1$
		move.l	#IText111,Para(a5)
		bsr	DOS_Err
1$		rts

**** Type ASCII *****	Checked
NumLines	set	LONG_1
CurrTopLine	set	LONG_2
CurrLineNum	set	LONG_3
MaxCurrLineNum	set	LONG_4
MaxLine		set	LONG_5
FileMem		set	LONG_6
TheLastLine	set	LONG_7

TypeIt		clr.l	FileHandle1(a5)
		clr.l	FileMem(a5)
		bset	#OnlyHandler,CTRL_1(a5)
		clr.b	Seq(a5)
		move.l	BetaWindow(a5),a0
		move.l	DownArrow2(a5),nw_FirstGadget(a0)	;BGadgets
		move.l	a2,a4
		move.l	PALNTSC(a5),d5
		bsr	OpnBWinWithFont
		beq	Type_Clean

		move.l	IBase(a5),a6
		move.l	RP(a5),a0
		move.l	TypeBorder(a5),a1
		moveq	#7,d0
		moveq	#12,d1
		jsr	DrawBorder(a6)
		bsr	BusyOn
		bsr	RemGs

		bsr	RemIGs
		move.l	DownArrow2(a5),a3
		moveq	#5,d7
		bsr	OffGs
		bsr	AddIGs

		move.l	BWindow(a5),a0
		move.l	a4,a1
		moveq	#-1,d0
		move.l	d0,a2
		jsr	SetWindowTitles(a6)

		move.l	DosBase(a5),a6
		move.l	a4,d1
		move.l	a4,a2
		move.l	#MODE_OLDFILE,d2
		jsr	Open(a6)
		move.l	d0,FileHandle1(a5)
		bne.s	1$
		bsr	OpenFileErr_Sub
		bra	Type_Err

1$		move.l	d0,d4
		move.l	d0,d1
		lea	NumLines(a5),a2
		move.l	a2,d2
		moveq	#4,d3
		jsr	Read(a6)
		cmpi.w	#'20',2(a2)
		bne.s	NotP_20
		cmpi.w	#'PP',(a2)	; Normal
		beq.s	2$
		cmpi.w	#'PX',(a2)	; Encrypted
		bne.s	NotP_20
		bsr	OpenRT
		beq.s	NotP_20
2$		bsr	LoadPP20
		move.l	PPBuffer(a5),FileMem(a5)
		beq.s	NotP_20
		move.l	PPLen(a5),FileLength(a5)
		bra.s	CountLines

NotP_20		move.l	DosBase(a5),a6
		move.l	d4,d1
		moveq	#0,d2
		moveq	#OFFSET_END,d3
		jsr	Seek(a6)
		move.l	d4,d1
		jsr	Seek(a6)
		move.l	d0,FileLength(a5)
		move.l	d4,d1
		moveq	#0,d2
		moveq	#OFFSET_BEGINNING,d3
		jsr	Seek(a6)
		move.l	$4,a6
		move.l	FileLength(a5),d0
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		move.l	d0,FileMem(a5)
		bne.s	2$
		lea	NoBufMem_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	Type_Err
2$		move.l	DosBase(a5),a6
		move.l	d4,d1
		move.l	d0,d2
		move.l	FileLength(a5),d3
		jsr	Read(a6)
		move.l	d4,d1
		jsr	Close(a6)
		clr.l	FileHandle1(a5)

CountLines	bsr	ClrTypeScr
		move.l	FileMem(a5),a0
		move.l	a0,a1
		moveq	#$0a,d1
		moveq	#$09,d2
		moveq	#$20,d3
		move.l	FileLength(a5),d4
		addq.l	#1,d4
		moveq	#0,d6
		moveq	#0,d7
KillChars	move.b	(a0)+,d0
		cmp.b	d1,d0
		bne.s	NoLF
		clr.b	-1(a0)
		addq.l	#1,d6
		move.l	a0,a1
NoLF		cmp.b	d2,d0
		bne.s	NoTAB
		move.b	d3,-1(a0)
NoTAB		addq.l	#1,d7
		cmp.l	d4,d7
		bne.s	KillChars
		move.l	d6,NumLines(a5)
		move.l	a1,CurrTopLine(a5)
		bsr	LineUp
		move.l	CurrTopLine(a5),TheLastLine(a5)
		move.l	d5,d7		; PAL/NTSC
		subq.l	#2,d7
1$		bsr	LineUp
		dbf	d7,1$		;GetMaxLine
		move.l	CurrTopLine(a5),MaxLine(a5)

		moveq	#1,d0
		move.l	d0,CurrLineNum(a5)
		move.l	d6,d0
		sub.l	d5,d0
		addq.l	#1,d0
		move.l	d0,MaxCurrLineNum(a5)
		move.l	FileMem(a5),CurrTopLine(a5)

		bsr	Type_18
		bsr	ArrowOn
		bsr	RemIGs
		move.l	DownArrow2(a5),a3
		moveq	#5,d7
		bsr	OnGs
		bsr	AddIGs

PrintASCII	moveq	#0,d0
		bsr	HandleBufStuff
		tst.b	d0
		bmi	Type_Clean
		move.l	PALNTSC(a5),d5
		cmp.l	NumLines(a5),d5
		bhi.s	PrintASCII
		subi.b	#40,d0
		beq.s	TUp
		subq.b	#1,d0
		beq.s	TDown
		subq.b	#1,d0
		beq	TPgDown
		subq.b	#1,d0
		beq	TPgUp
		subq.b	#1,d0
		beq	TBot
		subq.b	#1,d0
		beq	TTop
		bra.s	PrintASCII

TUp		moveq	#1,d0
		cmp.l	CurrLineNum(a5),d0
		beq.s	PrintASCII
		addq.l	#1,d0
		cmp.l	CurrLineNum(a5),d0
		bne.s	NotSecondLine
		move.l	FileMem(a5),CurrTopLine(a5)
		bra.s	UpCont
NotSecondLine	bsr.s	LineUp
UpCont		subq.l	#1,CurrLineNum(a5)
		bsr	TScrollDown
		bsr	Type_18
		bra.s	PrintASCII

TDown		move.l	CurrTopLine(a5),a0
		move.l	CurrLineNum(a5),d0
		cmp.l	MaxCurrLineNum(a5),d0
		beq	PrintASCII
		bsr.s	LineDown
		addq.l	#1,CurrLineNum(a5)
		bsr	TScrollUp
		bsr	Type_18
		bra	PrintASCII

LineUp		move.l	CurrTopLine(a5),a0
		subq.w	#1,a0
1$		tst.b	-(a0)
		bne.s	1$
		addq.w	#1,a0
		move.l	a0,CurrTopLine(a5)
		rts

LineDown	move.l	CurrTopLine(a5),a0
1$		tst.b	(a0)+
		bne.s	1$
		move.l	a0,CurrTopLine(a5)
		rts

TPgUp		sub.l	d5,CurrLineNum(a5)
		beq.s	TTop
		bmi.s	TTop
		move.l	d5,d7
		subq.l	#1,d7
T_PgUp		bsr.s	LineUp
		dbf	d7,T_PgUp
		bsr	ClrTypeScr
		bsr.s	Type_18
		bra	PrintASCII

TPgDown		move.l	CurrLineNum(a5),d0
		add.l	d5,d0
		cmp.l	MaxCurrLineNum(a5),d0
		bcc.s	TBot
		move.l	d0,CurrLineNum(a5)
		move.l	d5,d7
		subq.l	#1,d7
T_PgDown	bsr.s	LineDown
		dbf	d7,T_PgDown
		bsr	ClrTypeScr
		bsr.s	Type_18
		bra	PrintASCII

TTop		move.l	FileMem(a5),CurrTopLine(a5)
		moveq	#1,d0
		move.l	d0,CurrLineNum(a5)
		bsr	ClrTypeScr
		bsr.s	Type_18
		bra	PrintASCII

TBot		move.l	MaxLine(a5),CurrTopLine(a5)
		move.l	MaxCurrLineNum(a5),CurrLineNum(a5)
		bsr	ClrTypeScr
		bsr.s	Type_18
		bra	PrintASCII

Type_18		move.l	GfxBase(a5),a6
		move.l	RP(a5),a1
		moveq	#1,d0
		jsr	SetAPen(a6)		; Pitaa olla
		move.l	PALNTSC(a5),d5
		move.l	d5,d7
		subq.l	#1,d7
		move.l	#11,x(a5)
		move.l	#22,y(a5)
		move.l	CurrTopLine(a5),a2

Typing_18	cmp.l	TheLastLine(a5),a2
		bhi.s	Typing_Over
		bsr.s	PrintTill0
		addq.l	#1,d6
		add.l	d6,a2
		moveq	#9,d0
		add.l	d0,y(a5)
		dbf	d7,Typing_18
Typing_Over	move.l	NumLines(a5),Para(a5)
		move.l	CurrLineNum(a5),Para2(a5)
		subq.l	#1,d5			; 18-1=17...
		cmp.l	NumLines(a5),d5
		bls.s	ManyLines
		move.l	NumLines(a5),Para3(a5)
		bra.s	TDoIt
ManyLines	move.l	CurrLineNum(a5),Para3(a5)
		add.l	d5,Para3(a5)
TDoIt		lea	LineInfo_txt(pc),a0
		moveq	#10,d2
		moveq	#0,d3
		move.l	BetaWindow(a5),a1
		move.w	nw_Height(a1),d3	;BWinSize
		subi.b	#11,d3
		bsr	DpyMsg
		rts

PrintTill0	move.l	a2,a0
		bsr	LenOfa0
		move.l	d0,d6
		cmpi.w	#77,d0
		bls.s	1$
		moveq	#77,d0
1$		move.l	d0,d2
		move.l	RP(a5),a1
		move.l	x(a5),d0
		move.l	y(a5),d1
		jsr	xMove(a6)
		move.l	RP(a5),a1
		move.l	a2,a0
		move.l	d2,d0
		jsr	Text(a6)
		rts

Type_Err	bsr	WaitIDCMP
		lsr.l	#8,d2
		subq.b	#2,d2
		bne.s	Type_Err

Type_Clean	tst.l	BWindow(a5)
		beq.s	1$
		bsr	PHPtrOff
1$		move.l	DosBase(a5),a6
		move.l	FileHandle1(a5),d1
		beq.s	2$
		jsr	Close(a6)
		clr.l	FileHandle1(a5)
2$		move.l	$4,a6
		move.l	FileMem(a5),d0
		beq.s	3$
		move.l	d0,a1
		move.l	FileLength(a5),d0
		jsr	FreeMem(a6)
		clr.l	PPBuffer(a5)
		clr.l	PPLen(a5)
3$		move.l	IBase(a5),a6
		move.l	BWindow(a5),d0
		beq.s	4$
		move.l	d0,a0
		jsr	CloseWindow(a6)
		clr.l	BWindow(a5)
4$		move.l	BetaWindow(a5),a0
		move.l	DownArrow1(a5),nw_FirstGadget(a0)	;BGadgets
		bsr	AddGs
		rts

OpenRT		move.l	$4,a6
		lea	ReqTName(pc),a1
		moveq	#0,d0
		jsr	OpenLibrary(a6)
		move.l	d0,ReqTBase(a5)
		rts

LoadPP20	movem.l	d4/a6,-(sp)
		move.l	$4,a6
		lea	PPName(pc),a1
		moveq	#0,d0
		jsr	OpenLibrary(a6)
		move.l	d0,PPBase(a5)
		beq.s	PP_Clean

		lea	LoadingPP_txt(pc),a2
		moveq	#MsgX,d0
		moveq	#MsgY,d1
		bsr	SimpleMsg

		move.l	PPBase(a5),a6
		move.l	a4,a0
		lea	PPBuffer(a5),a1
		lea	PPLen(a5),a2
		sub.l	a3,a3
		moveq	#DECR_POINTER,d0
		moveq	#MEMF_PUBLIC,d1
		jsr	ppLoadData(a6)

PP_Clean	move.l	$4,a6
		move.l	PPBase(a5),d0
		beq.s	1$
		move.l	d0,a1
		jsr	CloseLibrary(a6)
		clr.l	PPBase(a5)
1$		move.l	ReqTBase(a5),d0
		beq.s	2$
		move.l	d0,a1
		jsr	CloseLibrary(a6)
		clr.l	ReqTBase(a5)
2$		movem.l	(sp)+,d4/a6
		rts

**** SetClock ****	Checked
Secs		set	LONG_1
Mins		set	LONG_2
MinSecs		set	LONG_3
HourSecs	set	LONG_4
DaySecs		set	LONG_5
YearSecs	set	LONG_6

SetClock_load	move.l	$4,a6
		bsr	CreatePort
		move.l	d0,TrackPort0(a5)
		beq	TimerClean

		move.l	d0,a0
		bsr	CreateIO
		move.l	d0,IOReq0(a5)
		beq	TimerClean

		lea	TR_Name(pc),a0
		move.l	IOReq0(a5),a1
		moveq	#UNIT_MICROHZ,d0
		moveq	#0,d1
		jsr	OpenDevice(a6)
		tst.l	d0
		bne	TimerClean
Timer_ok	st.b	DeviceFlag0(a5)

ConvertTime	lea	$dc0000,a2
		move.l	(a2)+,d0	; Seconds
		move.l	(a2)+,d1
		bsr	Conv_dx
		add.l	d0,d1
		move.l	d1,Secs(a5)

		move.l	(a2)+,d0	; Mins
		move.l	(a2)+,d1
		bsr	Conv_dx
		add.l	d0,d1
		mulu	#SecsPerMin,d1
		move.l	d1,MinSecs(a5)

		move.l	(a2)+,d0	; Hours
		move.l	(a2)+,d1
		bsr	Conv_dx
		add.l	d0,d1
		mulu	#SecsPerHour,d1
		move.l	d1,HourSecs(a5)

		move.l	(a2)+,d0	; Days
		move.l	(a2)+,d1
		bsr	Conv_dx
		add.l	d0,d1
		subq.l	#1,d1
		move.l	#SecsPerDay,d0
		moveq	#0,d2
1$		add.l	d0,d2
		dbf	d1,1$
		move.l	d2,DaySecs(a5)

		move.l	(a2)+,d0	; Months
		move.l	(a2)+,d1	; -> How many days in passed months
		bsr	Conv_dx
		add.l	d0,d1
		move.l	d1,d5
		subq.l	#1,d1
		beq.s	MsDone

		lea	Calendar(pc),a0	; Num of days in various months
		moveq	#0,d0
		moveq	#0,d2
2$		add.w	(a0)+,d2
		addq.b	#1,d0
		cmp.b	d1,d0
		bne.s	2$

		moveq	#0,d0
		move.l	#SecsPerDay,d1
		subq.w	#1,d2
3$		add.l	d1,d0
		dbf	d2,3$
		add.l	d0,DaySecs(a5)

MsDone		move.l	(a2),d0		; Years
		move.l	2(a2),d1
		bsr	Conv_dx
		add.l	d0,d1
		subi.w	#78,d1
		beq.s	All_Cntd
		move.l	d1,d6
		subq.l	#1,d1
		move.l	#SecsPerYear,d0
		moveq	#0,d2
1$		add.l	d0,d2
		dbf	d1,1$
		move.l	d2,YearSecs(a5)

		lea	K_Vuodet(pc),a0
		moveq	#7,d7
Eti_Vuosi	subq.b	#1,d7
		beq.s	All_Cntd
		cmp.w	(a0)+,d6
		bcs.s	All_Cntd
Karkaa		bhi.s	1$
		cmpi.b	#3,d5		; Jos tana kkvuonna kulunut kk<3, ei
		bcs.s	Eti_Vuosi	; lisata koska ylim. paiva on 2. kkssa!
1$		add.l	#SecsPerDay,DaySecs(a5)	; Lisaa pv jokaista kulunutta
		bra.s	Eti_Vuosi		; karkausvuotta kohden

All_Cntd	move.l	YearSecs(a5),d0		; TotalSecs
		add.l	DaySecs(a5),d0
		add.l	HourSecs(a5),d0
		add.l	MinSecs(a5),d0
		add.l	Secs(a5),d0
		subi.l	#SecsPerDay,d0

		move.l	IOReq0(a5),a1
		move.l	d0,IOTV_TIME+TV_SECS(a1)
		clr.l	IOTV_TIME+TV_MICRO(a1)
		move.w	#TR_SETSYSTIME,IO_COMMAND(a1)
		jsr	DoIO(a6)

TimerClean	bsr	TrackClean
		rts

Conv_dx		moveq	#15,d2
		and.l	d2,d0
		and.l	d2,d1
		subq.b	#5,d2
		mulu	d2,d1	; d2=10
		rts

SetClock_reset	moveq	#15,d7
		lea	$dc0000,a0
1$		clr.l	(a0)+
		dbf	d7,1$
		rts

SetClockIt	bsr	RemGs
		move.l	a2,a0
		lea	LONG_1(a5),a3	; save time
		moveq	#5,d7
1$		bsr.s	ConvertDec
		bmi.s	NotRight
		move.b	d0,d1
		bsr.s	ConvertDec
		bmi.s	2$		;OneDigit
		move.b	d0,(a3)+
		move.b	d1,(a3)+
		bsr.s	ConvertDec	; CheckSlash
		bpl.s	NotRight
		bra.s	3$		;NextBite
2$		move.b	d1,(a3)+
		clr.b	(a3)+
3$		dbf	d7,1$

		moveq	#2,d7
		moveq	#0,d0
		lea	LONG_1+11(a5),a0
		lea	$dc0000,a1
4$		move.b	-1(a0),d0	; Time
		move.l	d0,(a1)+
		move.b	(a0),d0
		move.l	d0,(a1)+
		subq.w	#2,a0
		dbf	d7,4$

		moveq	#5,d7
		lea	LONG_1(a5),a0
5$		move.b	(a0)+,d0
		move.l	d0,(a1)+
		dbf	d7,5$		; Date
		clr.l	(a1)
		rts

NotRight	lea	SetClkErr_txt(pc),a2
		bsr	SimpleMsg_xy
		bsr	KeyToCont_Sub
		bsr	AddGs
		rts

ConvertDec	move.b	(a0)+,d0
		subi.b	#'0',d0
		bmi.s	1$
		cmpi.b	#9,d0
		bhi.s	1$
		tst.b	d0
		rts
1$		moveq	#-1,d0		; NoNumeric
		rts

**** Relabel Disk ****	Checked
RootMemory	set	LONG_1

RelabelIt	clr.l	RootMemory(a5)
		clr.b	WhichTD(a5)
		bsr	RemGs
		bsr	GetDiskUnitNum
		bmi	Rel_Err
		bsr	PrepareUnit
		bmi	Rel_Err

		move.l	IOReq0(a5),a1
		bsr	TestDisk
		bmi	Rel_Err
		bsr	TestWProt
		bmi	Rel_Err

		move.b	2(a2),DriveID0(a5)
		bsr	DiskBusyOn

		moveq	#4,d0
		lsl.l	#8,d0
		move.l	#MEMF_CLEAR!MEMF_CHIP,d1
		jsr	AllocMem(a6)
		move.l	d0,RootMemory(a5)
		bne.s	1$
		lea	NoBufMem_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	Rel_Err

1$		moveq	#2,d3
		lsl.l	#8,d3
		move.l	d3,d2
		mulu	#880,d2
		move.l	IOReq0(a5),a1
		move.l	d2,IO_OFFSET(a1)
		move.l	d3,IO_LENGTH(a1)
		move.l	RootMemory(a5),IO_DATA(a1)
		move.w	#CMD_READ,IO_COMMAND(a1)
		jsr	DoIO(a6)

		move.l	RootMemory(a5),a0
		moveq	#2,d0
		moveq	#$48,d1
		cmp.l	(a0),d0
		bne	NotDOSDisk
		cmp.l	12(a0),d1
		bne	NotDOSDisk
		tst.l	16(a0)
		bne	NotDOSDisk
		subq.b	#1,d0
		cmp.l	508(a0),d0
		bne	NotDOSDisk

		add.w	#432,a0			; Clr old name
		moveq	#6,d7
2$		clr.l	(a0)+
		dbf	d7,2$
		move.l	RootMemory(a5),a2
		bsr	DiskName		; Put new name

3$		moveq	#CMD_WRITE,d4
		move.l	IOReq0(a5),a2
		move.l	a2,a1
		move.l	d2,IO_OFFSET(a1)
		move.l	d3,IO_LENGTH(a1)
		move.l	RootMemory(a5),IO_DATA(a1)
		move.w	d4,IO_COMMAND(a1)
		jsr	DoIO(a6)
		move.l	a2,a1
		moveq	#CMD_UPDATE,d4
		move.w	d4,IO_COMMAND(a1)
		jsr	DoIO(a6)

		move.b	IO_ERROR(a2),d0
		beq.s	4$
		bsr	RWError_Sub
		bmi.s	4$
		subq.b	#1,d0
		beq.s	3$

4$		bsr	Motor0Off

RelClean	cmpi.b	#'x',DriveID+2(a5)
		beq.s	1$
		bsr	DiskBusyOff
1$		bsr	TrackClean
		move.l	RootMemory(a5),d0
		beq.s	2$
		move.l	d0,a1
		moveq	#4,d0
		lsl.l	#8,d0
		jsr	FreeMem(a6)
2$		bsr	AddGs
		rts

NotDOSDisk	bsr	Motor0Off
		lea	NotDOSDisk_txt(pc),a2
		bsr	SimpleMsg_xy

Rel_Err		bsr	KeyToCont_Sub
		bra.s	RelClean

**** Install Disk ****	Checked
WriteMemory	set	LONG_1

InstallIt	clr.l	WriteMemory(a5)
		clr.b	WhichTD(a5)
		bclr	#InstallAfter,CTRL_2(a5)
		bsr	RemGs
		bsr	GetDiskUnitNum
		bmi	Ins_Err
		bsr	PrepareUnit
		bmi	Ins_Err

		move.l	IOReq0(a5),a1
		bsr	TestDisk
		bmi	Ins_Err
		bsr	TestWProt
		bmi	Ins_Err

		moveq	#4,d0
		lsl.l	#8,d0
		move.l	#MEMF_CHIP,d1
		jsr	AllocMem(a6)
		move.l	d0,WriteMemory(a5)
		bne.s	ClearBoot
		lea	NoBufMem_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	Ins_Err

ClearBoot	move.w	#((512*2)/4)-1,d7
		move.l	WriteMemory(a5),a2
		move.l	a2,a1
1$		clr.l	(a1)+
		dbf	d7,1$

		move.l	#$444f5300,d0		; 'DOS',0
		btst	#InstallAfter,CTRL_2(a5)
		bne.s	3$			; FormIns
		btst	#Option2,CTRL_3(a5)	; FFS?...
		beq.s	BuildBoot
2$		addq.b	#1,d0			; ->'DOS',1
		bra.s	BuildBoot
3$		btst	#Option4,CTRL_3(a5)
		bne.s	2$

BuildBoot	lea	BootMsg(pc),a0
		lea	$80(a2),a1
4$		move.b	(a0)+,(a1)+
		bne.s	4$
		subq.l	#1,a1
		move.l	a0,-(sp)
		lea	PrgTitle(pc),a0
		moveq	#17,d7
5$		move.b	(a0)+,(a1)+
		dbf	d7,5$
		move.l	(sp)+,a0
6$		move.b	(a0)+,(a1)+
		bne.s	6$

		move.l	a2,a1
		move.l	d0,(a1)
		btst	#InstallAfter,CTRL_2(a5)
		beq.s	1$
		btst	#Option3,CTRL_3(a5)	; FormInstall?
		beq.s	InstallNow
		bra.s	2$
1$		btst	#Option1,CTRL_3(a5)	; NoBoot?
		bne.s	InstallNow

2$		addq.l	#8,a1
		move.l	#880,(a1)+

		lea	Boot13(pc),a0
		moveq	#(B13Len/4)-1,d7
		tst.b	d0
		beq.s	3$
		lea	Boot20(pc),a0
		moveq	#(B20Len/4)-1,d7
3$		move.l	(a0)+,(a1)+
		dbf	d7,3$

BootChkSum	move.l	a2,a1
		moveq	#0,d0
		move.w	#($200/4)-1,d7		; Rest is 0...
1$		add.l	(a1)+,d0
		bcc.s	2$
		addq.l	#1,d0
2$		dbf	d7,1$
		sub.l	d0,4(a2)
		bcc.s	InstallNow
		subq.l	#1,4(a2)

InstallNow	moveq	#4,d0
		lsl.l	#8,d0
		moveq	#CMD_WRITE,d2
		move.l	IOReq0(a5),a1
		clr.l	IO_OFFSET(a1)
		move.l	d0,IO_LENGTH(a1)
		move.l	a2,IO_DATA(a1)
		move.w	d2,IO_COMMAND(a1)
		jsr	DoIO(a6)
		move.l	IOReq0(a5),a1
		addq.b	#1,d2
		move.w	d2,IO_COMMAND(a1)
		jsr	DoIO(a6)

		btst	#InstallAfter,CTRL_2(a5)
		beq.s	1$
		rts

1$		bsr	Motor0Off
InsClean	bsr	TrackClean
		move.l	WriteMemory(a5),d0
		beq.s	1$
		move.l	d0,a1
		moveq	#4,d0
		lsl.l	#8,d0
		jsr	FreeMem(a6)
1$		bsr	AddGs
		rts

Ins_Err		bsr	KeyToCont_Sub
		bra.s	InsClean

**** Disk-Copy Routines ****	Checked
ReadMem1	set	LONG_1
ReadMem2	set	LONG_2
VerifyMem	set	LONG_3
ReadAddr	set	LONG_4
WriteAddr	set	LONG_5
TwoCpyAmountMem	set	LONG_6

BufTable	set	LONG_1		; OneDrive
CurrBufTab	set	LONG_2
CHIPBuf		set	LONG_3
CurrCylNum	set	LONG_4
CurrNumCylsRead	set	LONG_5
StartCyl	set	LONG_6
LatestBuf	set	LONG_7
VerifyBuf	set	LONG_8

DiskCopyIt	clr.l	BufTable(a5)
		clr.l	CurrBufTab(a5)
		clr.l	CHIPBuf(a5)
		bclr	#OneDraivi,CTRL_1(a5)
		clr.b	WhichTD(a5)
		bsr	BusyOn
		bsr	RemGs

		moveq	#0,d6
		move.b	2(a3),d0
		cmp.b	2(a2),d0
		bne.s	TwoDrives
		bset	#OneDraivi,CTRL_1(a5)
		bra.s	OneDrive

TwoDrives	bsr	GetDiskUnitNum		; String1=SRC
		move.b	Unit(a5),d6
		swap	d6
		bsr	PrepareUnit
		bmi	DC_Err

OneDrive	addq.b	#1,WhichTD(a5)
		bsr	GetDiskUnitNum		; String2=DEST
		move.b	Unit(a5),d6
		swap	d6
		bsr	PrepareUnit
		bmi	DC_Err

		clr.b	WhichTD(a5)
		btst	#OneDraivi,CTRL_1(a5)
		beq.s	1$
		swap	d6
		move.b	2(a2),DriveID0(a5)
		bsr	DiskBusyOn
		bra	OneDriveCopy
1$		move.b	2(a2),DriveID0(a5)
		move.b	2(a3),DriveID1(a5)
		move.b	#2,WhichTD(a5)
		bsr	DiskBusyOn

		moveq	#44,d0
		lsl.l	#8,d0
		moveq	#2,d1
		btst	#Option1,CTRL_3(a5)
		beq.s	2$
		moveq	#3,d1
2$		mulu	d1,d0
		move.l	d0,TwoCpyAmountMem(a5)	; No VerifyBuf if no verify!
		move.l	#MEMF_CLEAR!MEMF_CHIP,d1
		jsr	AllocMem(a6)
		move.l	d0,ReadMem1(a5)
		bne.s	3$
		lea	NoBufMem_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	DC_Err

3$		lea	DCInsert_txt(pc),a2
		bsr	SimpleMsg_xy
		bsr	KeyToContClr_Sub

		move.l	$4,a6
		move.b	d6,Unit(a5)
		move.l	IOReq0(a5),a1
		bsr	TestDisk
		bmi	DC_Err
		swap	d6
		move.b	d6,Unit(a5)
		move.l	IOReq1(a5),a1
		bsr	TestDisk
		bmi	DC_Err
		bsr	TestWProt
		bmi	DC_Err

		moveq	#44,d3
		lsl.l	#8,d3
		move.l	ReadMem1(a5),d0
		add.l	d3,d0
		move.l	d0,ReadMem2(a5)
		add.l	d3,d0
		move.l	d0,VerifyMem(a5)	; May not exist! ^^^
		move.l	IOReq0(a5),a2
		move.l	IOReq1(a5),a3

DoubleBufCpy	moveq	#79,d2		; ReadHere
		moveq	#80,d4		; WriteHere
		move.l	ReadMem1(a5),ReadAddr(a5)
		bsr	GetCyl
		bsr	ReadChkErr
		bmi.s	3$

1$		subq.b	#1,d4
		subq.b	#1,d2
		move.l	ReadMem2(a5),ReadAddr(a5)
		move.l	ReadMem1(a5),WriteAddr(a5)
		bsr	PutCyl
		bsr.s	GetCyl
		bsr	WriteChkErr
		bmi.s	3$
		bsr	ReadChkErr
		bmi.s	3$
		cmpi.b	#$74,$bfec01
		beq.s	3$
		subq.b	#1,d4
		subq.b	#1,d2
		bmi.s	2$
		move.l	ReadMem1(a5),ReadAddr(a5)
		move.l	ReadMem2(a5),WriteAddr(a5)
		bsr	PutCyl
		bsr.s	GetCyl
		bsr	WriteChkErr
		bmi.s	3$
		bsr.s	ReadChkErr
		bmi.s	3$
		cmpi.b	#$74,$bfec01
		beq.s	3$
		bra.s	1$

2$		move.l	ReadMem2(a5),WriteAddr(a5)
		bsr.s	PutCyl
		bsr	WriteChkErr

3$		bsr	DateDestination		; +UPDATE
		bsr	Motor0Off
		bsr	Motor1Off

		lea	DCRemDisk_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	DC_Err

GetCyl		move.l	a2,a1
		move.l	d3,d0
		mulu	d2,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	d3,IO_LENGTH(a1)
		move.l	ReadAddr(a5),IO_DATA(a1)
		move.w	#CMD_READ,IO_COMMAND(a1)
		jsr	SendIO(a6)
		rts

ReadChkErr	move.l	a2,a1
		jsr	WaitIO(a6)

		move.b	IO_ERROR(a2),d0
		beq.s	1$
		bsr	RWError_Sub
		beq.s	1$
		bmi.s	1$
		bsr.s	GetCyl
		bra.s	ReadChkErr
1$		rts

PutCyl		move.l	a3,a1
		move.l	d3,d0
		mulu	d4,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	d3,IO_LENGTH(a1)
		move.l	WriteAddr(a5),IO_DATA(a1)
		move.w	#TD_FORMAT,IO_COMMAND(a1)
		jsr	SendIO(a6)

		movem.l	d2-d4/a2-a3/a6,-(sp)
		move.l	#Copying_txt,Para(a5)
		move.l	d4,Para2(a5)
		lea	DC_txt(pc),a0
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		movem.l	(sp)+,d2-d4/a2-a3/a6
		rts

WriteChkErr	move.l	a3,a1
		jsr	WaitIO(a6)
		btst	#Option1,CTRL_3(a5)	; Verify
		bne.s	1$
		moveq	#0,d0
		rts
1$		move.l	a3,a1
		move.l	d3,d0
		mulu	d4,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	d3,IO_LENGTH(a1)
		move.l	VerifyMem(a5),IO_DATA(a1)
		move.w	#CMD_READ,IO_COMMAND(a1)
		jsr	SendIO(a6)

		movem.l	d2-d4/a2-a3/a6,-(sp)
		move.l	#Verifying_txt,Para(a5)
		lea	DC_txt(pc),a0
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		movem.l	(sp)+,d2-d4/a2-a3/a6

		move.l	a3,a1
		jsr	WaitIO(a6)

		move.l	WriteAddr(a5),a0
		move.l	VerifyMem(a5),a1
		move.w	#((22*512)/4)-1,d7
2$		cmpm.l	(a0)+,(a1)+
		bne.s	3$
		dbf	d7,2$
		moveq	#0,d0
		rts

3$		bsr	VerifyError_Sub
		beq.s	4$
		bmi.s	4$
		bsr	PutCyl
		bra.s	WriteChkErr
4$		rts

DateDestination	btst	#Option2,CTRL_3(a5)
		beq	JustUpDate

		move.l	ReadMem1(a5),d0
		btst	#OneDraivi,CTRL_1(a5)
		beq.s	1$
		move.l	CHIPBuf(a5),d0
1$		move.l	d0,a2

		move.l	DosBase(a5),a6
		move.l	d0,d1
		jsr	DateStamp(a6)

		move.l	a2,a0
		move.l	(a0)+,d5
		move.l	(a0)+,d6
		move.l	(a0)+,d7

		move.l	$4,a6
		move.l	IOReq1(a5),a3
		moveq	#2,d2
		lsl.l	#8,d2
		move.l	#880,d3
		mulu	d2,d3
		move.l	a3,a1
		move.l	d3,IO_OFFSET(a1)
		move.l	d2,IO_LENGTH(a1)
		move.l	a2,IO_DATA(a1)
		move.w	#CMD_READ,IO_COMMAND(a1)
		jsr	DoIO(a6)

		move.l	d5,420(a2)
		move.l	d6,424(a2)
		move.l	d7,428(a2)
		move.l	d5,484(a2)
		move.l	d6,488(a2)
		move.l	d7,492(a2)
		bsr	CalcRootChkSum

		move.l	a3,a1
		move.l	d3,IO_OFFSET(a1)
		move.l	d2,IO_LENGTH(a1)
		move.l	a2,IO_DATA(a1)
		move.w	#CMD_WRITE,IO_COMMAND(a1)
		jsr	DoIO(a6)

JustUpDate	move.l	$4,a6
		move.l	IOReq1(a5),a1
		move.w	#CMD_UPDATE,IO_COMMAND(a1)
		jsr	DoIO(a6)
		rts

DC_Err		bsr	KeyToCont_Sub
DCClean		cmpi.b	#'x',DriveID+2(a5)
		beq.s	1$
		clr.b	WhichTD(a5)
		bsr	DiskBusyOff
		btst	#OneDraivi,CTRL_1(a5)
		bne.s	1$
		move.l	DosBase(a5),a6
		moveq	#30,d1
		jsr	Delay(a6)	; Delay between busys to prevent
		bsr	DiskBusyOff1	; disk trashing !
1$		bsr	TrackClean
		btst	#OneDraivi,CTRL_1(a5)
		bne.s	3$
		move.l	ReadMem1(a5),d0
		beq.s	5$
		move.l	d0,a1
		move.l	TwoCpyAmountMem(a5),d0
		jsr	FreeMem(a6)
		bra.s	5$
3$		move.l	CHIPBuf(a5),d0
		beq.s	4$
		move.l	d0,a1
		moveq	#88,d0
		lsl.l	#8,d0
		jsr	FreeMem(a6)
4$		bsr	OneFreeBufs
		move.l	BufTable(a5),d0
		beq.s	5$
		move.l	d0,a1
		moveq	#80,d0	; 80*4
		lsl.l	#2,d0
		jsr	FreeMem(a6)
5$		bsr	AddGs
		rts

**** DiskCopy With One Drive **** Checked
BufTable	set	LONG_1
CurrBufTab	set	LONG_2
CHIPBuf		set	LONG_3
CurrCylNum	set	LONG_4
CurrNumCylsRead	set	LONG_5
StartCyl	set	LONG_6
LatestBuf	set	LONG_7
VerifyBuf	set	LONG_8

OneDriveCopy	clr.l	CurrCylNum(a5)
		move.l	$4,a6
		moveq	#80,d0
		lsl.l	#2,d0
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		tst.l	d0
		bne.s	One_GotMem
One_NoMem	lea	NoBufMem_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	DC_Err

One_GotMem	move.l	d0,BufTable(a5)
		move.l	d0,CurrBufTab(a5)

		moveq	#88,d0
		lsl.l	#8,d0
		move.l	d0,d2
		lsr.l	#1,d2
		move.l	#MEMF_CLEAR!MEMF_CHIP,d1
		jsr	AllocMem(a6)
		tst.l	d0
		beq.s	One_NoMem
		move.l	d0,CHIPBuf(a5)
		add.l	d2,d0
		move.l	d0,VerifyBuf(a5)

OneContCopy	lea	InsertSrc_txt(pc),a0	; Begin READ...
		clr.l	Para(a5)
		move.b	Unit(a5),Para+3(a5)
		bsr	DpyMsg_xy
		bsr	KeyToContClr_Sub

		move.l	$4,a6
		move.l	IOReq1(a5),a1
		bsr	TestDisk
		bmi	DC_Err

		clr.l	CurrNumCylsRead(a5)
		move.l	CurrCylNum(a5),d2
		move.l	d2,StartCyl(a5)
		moveq	#44,d3
		lsl.l	#8,d3
OneGoRead	cmpi.b	#80,d2
		beq.s	OneReadEnd
		cmpi.b	#$74,$bfec01
		bne.s	NoOneBreak
OneBreak	moveq	#-1,d6
		bra	One_Breaked

NoOneBreak	bsr	AllocDestBuf
		moveq	#0,d6
		tst.l	d0
		bmi.s	NoMoreMem

		bsr	ReadCyl
		bpl.s	1$
		bsr	Motor1Off
		bra	DCClean
1$		addq.l	#1,CurrNumCylsRead(a5)
		addq.l	#1,d2
		bra.s	OneGoRead

OneReadEnd	moveq	#-1,d6

NoMoreMem	move.l	d2,CurrCylNum(a5)
		subq.l	#1,CurrNumCylsRead(a5)
		bsr	Motor1Off

		tst.l	CurrNumCylsRead(a5)	; No Mem For Even 1 Buf ?!
		bmi	OneERROR_MEM

		lea	InsertDest_txt(pc),a0	; Begin WRITE...
		clr.l	Para(a5)
		move.b	Unit(a5),Para+3(a5)
		bsr	DpyMsg_xy
		move.l	d6,-(sp)
		bsr	KeyToContClr_Sub
		move.l	(sp)+,d6

		move.l	$4,a6
		move.l	IOReq1(a5),a1
		bsr	TestDisk
		bmi	DC_Err
		bsr	TestWProt
		bmi	DC_Err

		move.l	StartCyl(a5),d2
		move.l	CurrNumCylsRead(a5),d4
		moveq	#44,d3
		lsl.l	#8,d3
		move.l	BufTable(a5),a2
WriteThese	cmpi.b	#$74,$bfec01
		beq	OneBreak
		bsr	WriteCyl
		addq.l	#4,a2
		addq.l	#1,d2
		dbf	d4,WriteThese
		bsr	OneFreeBufs

One_Breaked	move.l	IOReq1(a5),a1
		move.w	#CMD_UPDATE,IO_COMMAND(a1)
		jsr	DoIO(a6)
		bsr	Motor1Off
		move.l	BufTable(a5),CurrBufTab(a5)
		tst.l	d6
		bpl	OneContCopy
		bsr	DateDestination
		bra	DCClean

WriteCyl	move.l	(a2),a0
		move.l	CHIPBuf(a5),a1
		move.l	d3,d0
		jsr	CopyMemQuick(a6)	; FAST to CHIP

		move.l	IOReq1(a5),a3
		move.l	a3,a1
		move.l	d3,d0
		mulu	d2,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	d3,IO_LENGTH(a1)
		move.l	CHIPBuf(a5),IO_DATA(a1)
		move.w	#TD_FORMAT,IO_COMMAND(a1)
		jsr	SendIO(a6)

		movem.l	d2-d4/a2-a3/a6,-(sp)
		move.l	#Writing_txt,Para(a5)
		move.l	d2,Para2(a5)
		lea	DC_txt(pc),a0
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		movem.l	(sp)+,d2-d4/a2-a3/a6
		move.l	a3,a1
		jsr	WaitIO(a6)

OneVerify	btst	#Option1,CTRL_3(a5)	; Verify
		beq.s	2$

		move.l	a3,a1
		move.l	d3,d0
		mulu	d2,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	d3,IO_LENGTH(a1)
		move.l	VerifyBuf(a5),IO_DATA(a1)
		move.w	#CMD_READ,IO_COMMAND(a1)
		jsr	SendIO(a6)

		movem.l	d2-d4/a2-a3/a6,-(sp)
		move.l	#Verifying_txt,Para(a5)
		move.l	d2,Para2(a5)
		lea	DC_txt(pc),a0
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		movem.l	(sp)+,d2-d4/a2-a3/a6
		move.l	a3,a1
		jsr	WaitIO(a6)

		move.l	CHIPBuf(a5),a0
		move.l	VerifyBuf(a5),a1
		move.w	#((22*512)/4)-1,d7
1$		cmpm.l	(a0)+,(a1)+
		bne.s	OneVError
		dbf	d7,1$
2$		rts

OneVError	bsr	VerifyError_Sub
		tst.b	d0
		bmi.s	1$			; cancel
		subq.b	#1,d0
		beq	WriteCyl		; retry
		rts
1$		moveq	#0,d4
		moveq	#-1,d6
		rts

ReadCyl		move.l	IOReq1(a5),a3
		move.l	a3,a1
		move.l	d3,d0
		mulu	d2,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	d3,IO_LENGTH(a1)
		move.l	CHIPBuf(a5),IO_DATA(a1)
		move.w	#CMD_READ,IO_COMMAND(a1)
		jsr	SendIO(a6)

		movem.l	d2-d3/a2-a3/a6,-(sp)
		move.l	#Reading_txt,Para(a5)
		move.l	d2,Para2(a5)
		lea	DC_txt(pc),a0
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		movem.l	(sp)+,d2-d3/a2-a3/a6
		move.l	a3,a1
		jsr	WaitIO(a6)

		move.b	IO_ERROR(a3),d0
		beq.s	2$
		bsr	RWError_Sub
		bpl.s	1$
		rts
1$		subq.b	#1,d0
		beq.s	ReadCyl

2$		move.l	CHIPBuf(a5),a0		; CHIP to FAST
		move.l	LatestBuf(a5),a1
		move.l	d3,d0
		jsr	CopyMemQuick(a6)
		moveq	#0,d0
		rts

OneFreeBufs	move.l	$4,a6
		move.l	BufTable(a5),a2
		moveq	#44,d2
		lsl.l	#8,d2
		moveq	#79,d7
1$		move.l	(a2),d0
		beq.s	2$
		move.l	d0,a1
		move.l	d2,d0
		jsr	FreeMem(a6)
		clr.l	(a2)+
		dbf	d7,1$
2$		rts

AllocDestBuf	move.l	$4,a6
		moveq	#MEMF_PUBLIC,d1
		jsr	AvailMem(a6)
		cmpi.l	#50000,d0		; Safety limit (min mem)
		bls.s	1$

		moveq	#44,d0
		lsl.l	#8,d0
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		tst.l	d0
		beq.s	1$
		move.l	CurrBufTab(a5),a0
		move.l	d0,(a0)+
		move.l	a0,CurrBufTab(a5)
		move.l	d0,LatestBuf(a5)
		moveq	#0,d0
		rts
1$		moveq	#-1,d0
		rts

OneERROR_MEM	lea	OutOfMem_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	DC_Err

**** Format Disk ****	Checked
WriteMem	set	LONG_1
VerifyMem	set	LONG_2
FormDiskName	set	LONG_3
BAM		set	LONG_4

FormatIt	clr.l	BADCount(a5)
		clr.l	WriteMem(a5)
		clr.l	VerifyMem(a5)
		clr.l	BAM(a5)
		clr.b	WhichTD(a5)
		bset	#InstallAfter,CTRL_2(a5)
		move.l	a3,FormDiskName(a5)
		bsr	RemGs
		bsr	BusyOn
		bsr	GetDiskUnitNum
		bmi	Form_Err
		bsr	PrepareUnit
		bmi	Form_Err

		move.b	2(a2),DriveID0(a5)
		bsr	DiskBusyOn

		lea	FormInsert_txt(pc),a0
		clr.l	Para(a5)
		move.b	Unit(a5),Para+3(a5)
		bsr	DpyMsg_xy
		bsr	KeyToContClr_Sub

		move.l	$4,a6
		move.l	IOReq0(a5),a1
		bsr	TestDisk
		bmi	Form_Err
		bsr	TestWProt
		bmi	Form_Err

		moveq	#92,d0
		lsl.l	#8,d0			; ((22*512)*2)+1024
		move.l	#MEMF_CLEAR!MEMF_CHIP,d1
		jsr	AllocMem(a6)
		move.l	d0,WriteMem(a5)
		bne.s	1$
		lea	NoBufMem_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	Form_Err

1$		moveq	#44,d2
		lsl.l	#8,d2
		add.l	d2,d0
		move.l	d0,VerifyMem(a5)
		add.l	d2,d0
		move.l	d0,BAM(a5)		; Root & BAM

		move.w	#((22*512)/16)-1,d7	; Asetetaan jokin patterni
		move.l	WriteMem(a5),a0		; jota verifioidaan
2$		move.l	#'PopH',(a0)+
		move.l	#'elp ',(a0)+
		move.l	#'©MpL',(a0)+
		move.l	#$27393421,(a0)+	; "'94!"
		dbf	d7,2$

		bsr	InitRootBAM
		move.l	$4,a6
		btst	#Option1,CTRL_3(a5)
		bne.s	InitializeDisk		; Quick

		moveq	#79,d2
		moveq	#44,d3
		lsl.l	#8,d3
FormatLoop	bsr	FormatCyl
		cmpi.b	#$74,$bfec01
		beq	FormBreak
		dbf	d2,FormatLoop

InitializeDisk	bsr	ClearBoot		; Call Install

		move.l	BAM(a5),a2		; Root already initialized
		add.w	#512,a2
		move.l	a2,a0
		moveq	#0,d0
		moveq	#127,d7
1$		sub.l	(a0)+,d0
		dbf	d7,1$
		move.l	d0,(a2)

		moveq	#4,d0
		lsl.l	#8,d0
		moveq	#CMD_WRITE,d2
		move.l	IOReq0(a5),a1
		move.l	#880*512,IO_OFFSET(a1)
		move.l	d0,IO_LENGTH(a1)
		move.l	BAM(a5),IO_DATA(a1)
		move.w	d2,IO_COMMAND(a1)
		jsr	DoIO(a6)
FormBreak	move.l	IOReq0(a5),a1
		move.w	#CMD_UPDATE,IO_COMMAND(a1)
		jsr	DoIO(a6)

		bsr	Motor0Off
		btst	#Option5,CTRL_3(a5)
		beq	FormatClean
		lea	ReportErrs_txt(pc),a0
		move.l	BADCount(a5),Para(a5)
		bsr	DpyMsg_xy
		bsr	KeyToCont_Sub
		bra	FormatClean

FormatCyl	move.l	IOReq0(a5),a2
		move.l	a2,a1
		move.l	d3,d0
		mulu	d2,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	d3,IO_LENGTH(a1)
		move.l	WriteMem(a5),IO_DATA(a1)
		move.w	#TD_FORMAT,IO_COMMAND(a1)
		jsr	SendIO(a6)

		movem.l	d2-d3/a2/a6,-(sp)
		move.l	d3,d7
		move.l	#Formatting_txt,Para(a5)
		move.l	d2,Para2(a5)
		lea	DC_txt(pc),a0
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		move.l	VerifyMem(a5),a1
		move.l	d7,d0
		moveq	#1,d1
		jsr	BltClear(a6)
		movem.l	(sp)+,d2-d3/a2/a6

		move.l	a2,a1
		jsr	WaitIO(a6)

		btst	#Option5,CTRL_3(a5)	; MarkBADD
		beq.s	VerifyFormat

WriteTestCyl	move.l	a2,a1			; If BADDFormat...
		move.l	d3,d0
		mulu	d2,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	d3,IO_LENGTH(a1)
		move.l	WriteMem(a5),IO_DATA(a1)
		move.w	#CMD_WRITE,IO_COMMAND(a1)
		jsr	DoIO(a6)

VerifyFormat	btst	#Option5,CTRL_3(a5)	; If BADD, verify always
		bne.s	1$
		btst	#Option2,CTRL_3(a5)	; Verify on?
		bne.s	1$
		rts				; No verify

1$		move.l	a2,a1
		move.l	d3,d0
		mulu	d2,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	d3,IO_LENGTH(a1)
		move.l	VerifyMem(a5),IO_DATA(a1)
		move.w	#CMD_READ,IO_COMMAND(a1)
		jsr	SendIO(a6)

		movem.l	d2-d3/a2/a6,-(sp)
		move.l	#Verifying_txt,Para(a5)
		lea	DC_txt(pc),a0
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		movem.l	(sp)+,d2-d3/a2/a6

		move.l	a2,a1
		jsr	WaitIO(a6)

		btst	#Option5,CTRL_3(a5)
		beq.s	NormalVerify
		tst.b	IO_ERROR(a2)
		bne.s	BAD_Error		; BADD verify...
	;	bra.s	BAD_Error		; Which one is better?...
		rts

NormalVerify	move.l	WriteMem(a5),a0
		move.l	VerifyMem(a5),a1
		move.w	#((22*512)/4)-1,d7
1$		cmpm.l	(a0)+,(a1)+
		bne.s	FormatVError
		dbf	d7,1$
		rts

FormatVError	bsr	VerifyError_Sub
		subq.b	#1,d0
		beq	FormatCyl		; ReTry=1
		rts

Form_Err	bsr	KeyToCont_Sub

FormatClean	cmpi.b	#'x',DriveID+2(a5)
		beq.s	1$
		bsr	DiskBusyOff
1$		bsr	TrackClean
		move.l	WriteMem(a5),d0
		beq.s	2$
		move.l	d0,a1
		moveq	#92,d0
		lsl.l	#8,d0
		jsr	FreeMem(a6)
2$		bsr	AddGs
		rts

; If error, find out BAD blocks and allocate them...
; Put BAD blocks in bits into d5
BAD_Error	move.l	VerifyMem(a5),a4	; Cyl image
		moveq	#2,d4
		lsl.l	#8,d4			; d4=512
		moveq	#0,d5			; BAD blocks in bits 21-0=22

		moveq	#-1,d7
ChkCyl		addq.l	#1,d7			; Chk 22 Blks=Cyl
		cmpi.b	#22,d7
		beq.s	CylChecked
		move.l	a4,a0

		moveq	#31,d6
1$		cmpi.l	#'PopH',(a0)+		; Chk one Blk condition
		bne.s	2$
		cmpi.l	#'elp ',(a0)+
		bne.s	2$
		cmpi.l	#'©MpL',(a0)+
		bne.s	2$
		cmpi.l	#$27393421,(a0)+	; "'94!"
		bne.s	2$
		dbf	d6,1$
		bra.s	3$

2$		bset	d7,d5			; Block n.d7 (0-21) is BAD
3$		add.l	d4,a4			; Next Blk
		bra.s	ChkCyl

; If d5<>0 mark BAD blocks as allocated...
CylChecked	tst.l	d5
		beq.s	NoBADs
		btst	#MarkTrckOrSecs,CTRL_2(a5)
		beq.s	AllocBADs
		move.w	#%11111111111,d0
		move.l	#%1111111111100000000000,d1
		move.l	d5,d7			; Mark whole upper/lower side
		and.w	d0,d7			; (track)
		beq.s	1$
		or.w	d0,d5
1$		move.l	d5,d7
		and.l	d1,d7
		beq.s	AllocBADs
		or.l	d1,d5

AllocBADs	move.l	BAM(a5),a4
		addq.l	#4,d4
		add.l	d4,a4			; d4=516
		move.l	d2,d4			; Cyl Num
		mulu	#22,d4			; Cyl begins from blk d4...

		moveq	#-1,d7
1$		addq.l	#1,d7
		cmpi.b	#22,d7
		beq.s	NoBADs
		btst	d7,d5			; Is blk d7 in this cyl BAD?
		beq.s	1$
		bsr.s	MarkAsAllocated		; Yes -> allocate it
		bra.s	1$
NoBADs		rts

MarkAsAllocated	movem.l	d2-d3,-(sp)
		addq.l	#1,BADCount(a5)
		move.l	d7,d0
		add.l	d4,d0
		moveq	#32,d6

		moveq	#0,d2		; Allocate blk in d0
		moveq	#0,d3
		subq.w	#2,d0
		divu	d6,d0
		move.w	d0,d2		; Full longwords
		lsl.w	#2,d2
		swap	d0
		move.w	d0,d3		; Extra bits (31-0)
		beq.s	1$

		subq.b	#1,d6		; d6=32-1 -> 31
		moveq	#31,d1
		sub.l	d3,d1
		exg.l	d1,d3
		sub.l	d6,d3
		neg.l	d3

1$		move.l	0(a4,d2.l),d0
		bclr	d3,d0		; Allocate it!
		move.l	d0,0(a4,d2.l)
		movem.l	(sp)+,d2-d3
		rts

InitRootBAM	move.l	DosBase(a5),a6
		move.l	FIB(a5),d1
		jsr	DateStamp(a6)

InitRoot	moveq	#2,d0
		moveq	#$48,d1
		move.l	FIB(a5),a0
		move.l	BAM(a5),a1
		move.l	d0,(a1)
		move.l	d1,12(a1)
		subq.b	#1,d0
		move.l	d0,312(a1)
		move.l	#881,316(a1)
		move.l	(a0),420(a1)
		move.l	4(a0),424(a1)
		move.l	8(a0),428(a1)
		move.l	(a0),484(a1)
		move.l	4(a0),488(a1)
		move.l	8(a0),492(a1)
		move.l	d0,508(a1)

		move.l	a1,a2
		move.l	FormDiskName(a5),a3
		bsr	DiskName

InitBAM		add.w	#516,a2
		move.l	a2,a0
		moveq	#54,d7
		moveq	#-1,d0
1$		move.l	d0,(a0)+
		dbf	d7,1$
		move.l	a2,a0
		move.l	#$ffff3fff,112-4(a0)
		move.l	#$3fffffff,220-4(a0)
		rts

RWError_Sub	movem.l	d2-d4/a2-a3/a6,-(sp)
		lea	TDErr_txt(pc),a0
		clr.l	Para(a5)
		move.b	d0,Para+3(a5)
		bsr	DpyMsg_xy
		bra.s	CylErr_Sub

VerifyError_Sub	movem.l	d2-d4/a2-a3/a6,-(sp)
		lea	VeriCylErr_txt(pc),a2
		bsr	SimpleMsg_xy

CylErr_Sub	lea	RIC_txt(pc),a2		; retry=1, cancel=-1
		bsr	SimpleMsg_xy		; ignore=continue=0
1$		bsr	WaitKey
		cmpi.b	#'r',d3
		bne.s	2$
		bsr	ClrMsgBorder
		moveq	#1,d0
		bra.s	4$
2$		cmpi.b	#'i',d3
		bne.s	3$
		bsr	ClrMsgBorder
		moveq	#0,d0
		bra.s	4$
3$		cmpi.b	#'c',d3
		bne.s	1$
		moveq	#-1,d0
		moveq	#0,d2			; Cancel » last cyl (0)
4$		movem.l	(sp)+,d2-d4/a2-a3/a6
		tst.b	d0
		rts

**** UpDate vectors ****	Checked
TakeVecs	move.l	$4,a6
		lea	Vector_num(pc),a0
		lea	_ColdCaptureBuf+14(a5),a4
		move.l	a0,d2
		move.l	ColdCapture(a6),Para(a5)
		bsr.s	CpyVec_Sub

		move.l	CoolCapture(a6),Para(a5)
		bsr.s	CpyVec_Sub

		move.l	WarmCapture(a6),Para(a5)
		bsr.s	CpyVec_Sub

		move.l	KickMemPtr(a6),Para(a5)
		bsr.s	CpyVec_Sub

		move.l	KickTagPtr(a6),Para(a5)
		bsr.s	CpyVec_Sub

		lea	DoIO(a6),a1
		addq.w	#2,a1
		move.l	(a1),Para(a5)
		bsr.s	CpyVec_Sub

		lea	SendIO(a6),a1
		addq.w	#2,a1
		move.l	(a1),Para(a5)

CpyVec_Sub	move.l	d2,a0
		bsr	Dpy
		move.l	TxtBuffer(a5),a0
		move.l	a4,a1
1$		move.b	(a0)+,(a1)+
		bne.s	1$
		lea	14+9(a4),a4
		rts

**** Create .fastdir ****	; Checked
Names		set	LONG_1
IsCurrDirattu	set	LONG_2
OldDir		set	LONG_3

CreateIt.fd	clr.l	Names(a5)
		clr.l	IsCurrDirattu(a5)
		bsr	RemGs
		bsr	BusyOn

		bsr	FlushFirstBufs

		bsr	LockDir
		bmi	Create_Err
		bsr	ExamineLock
		bmi	Create_Err

		move.l	d2,a0
		tst.l	fib_DirEntryType(a0)
		bpl.s	1$
		bsr	NotDir
		bra	Create_Err

1$		lea	Creatingfd_txt(pc),a2
		moveq	#MsgX,d0
		moveq	#MsgY,d1
		bsr	SimpleMsg

		move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		jsr	CurrentDir(a6)
		move.l	d0,OldDir(a5)
		not.b	IsCurrDirattu(a5)

		lea	fd_txt(pc),a2
		move.l	a2,d1
		move.l	#MODE_NEWFILE,d2
		jsr	Open(a6)
		move.l	d0,FileHandle1(a5)
		bne.s	2$
		bsr	OpenFileErr_Sub
		bra	Create_Err

2$		move.l	d0,d1
		moveq	#0,d2
		moveq	#2,d3
		jsr	Write(a6)

BeginNewBuf	move.l	FirstDirBufs(a5),a4
		moveq	#0,d6
		moveq	#0,d5

ReadDir.fd	move.l	DosBase(a5),a6
		move.l	Lukko(a5),d1
		move.l	FIB(a5),d2
		jsr	ExNext(a6)
		tst.l	d0
		beq.s	Got.fd

		move.l	d2,a0
		lea	fib_FileName(a0),a1
		cmpi.l	#'.fas',(a1)
		bne.s	1$
		cmpi.l	#'tdir',4(a1)
		bne.s	1$
		tst.b	8(a1)
		beq.s	ReadDir.fd

1$		addq.l	#1,Names(a5)
		addq.l	#1,d5

		moveq	#31,d7
2$		move.b	(a1)+,0(a4,d6.w)
		addq.w	#1,d6
		dbf	d7,2$

		move.l	fib_Size(a0),0(a4,d6.w)
		addq.w	#4,d6
		clr.w	0(a4,d6.w)
		tst.l	fib_DirEntryType(a0)
		bmi.s	WasFile.fd
		addq.w	#1,0(a4,d6.w)

WasFile.fd	addq.w	#2,d6
		cmpi.w	#2014,d6	; 53*38=2014 (54*38=2052)
		bcs.s	ReadDir.fd

WFullBuf.fd	bsr.s	WriteBuf_Sub
		bra.s	BeginNewBuf

Got.fd		tst.l	Names(a5)
		beq.s	EmptyDir
		bsr.s	WriteBuf_Sub
		move.l	FileHandle1(a5),d1
		moveq	#0,d2
		moveq	#OFFSET_BEGINNING,d3
		jsr	Seek(a6)
		move.l	FileHandle1(a5),d1
		move.w	Names+2(a5),(a4)
		move.l	a4,d2
		moveq	#2,d3
		jsr	Write(a6)

Create_Clean	move.l	DosBase(a5),a6
		move.l	FileHandle1(a5),d1
		beq.s	1$
		jsr	Close(a6)
		clr.l	FileHandle1(a5)
1$		tst.b	IsCurrDirattu(a5)
		beq.s	2$
		move.l	OldDir(a5),d1
		jsr	CurrentDir(a6)
2$		move.l	Lukko(a5),d1
		beq.s	3$
		jsr	UnLock(a6)
		clr.l	Lukko(a5)
3$		move.l	FirstDirBufs(a5),a4
		clr.l	(a4)
		bsr	AddGs
		rts

WriteBuf_Sub	move.l	FileHandle1(a5),d1
		move.l	a4,d2
		move.l	d5,d3
		mulu	#38,d3
		beq.s	1$
		jsr	Write(a6)
1$		rts

EmptyDir	move.l	FileHandle1(a5),d1
		jsr	Close(a6)
		clr.l	FileHandle1(a5)
		move.l	#fd_txt,d1
		jsr	DeleteFile(a6)
		lea	EmptyDir_txt(pc),a2
		bsr	SimpleMsg_xy
Create_Err	bsr	KeyToCont_Sub
		bra.s	Create_Clean

**** Show IFF Or Icon ****
ShowMem		equ	LONG_1
CAmg		equ	LONG_2	; CAmg,PicRealHeight
ShowScreen	equ	LONG_3
BODYData	equ	LONG_4
Packed		equ	LONG_5	; Compressed,NumCols
PicBytesPerRow	equ	LONG_7	; PicBytesPerRow,PicRealWidth
IconBase	equ	LONG_6
ScrRPort	equ	LONG_7
IconAddr	equ	LONG_8

ShowGfxIt	clr.l	ShowMem(a5)
		clr.l	CAmg(a5)
		clr.l	ShowScreen(a5)
		clr.l	IconBase(a5)
		clr.l	IconAddr(a5)
		bsr	RemGs
		bsr	BusyOn

		move.l	DosBase(a5),a6
		move.l	a2,d1
		move.l	#MODE_OLDFILE,d2
		jsr	Open(a6)
		move.l	d0,FileHandle1(a5)
		bne.s	1$
		bsr	OpenFileErr_Sub
		bra	Show_Err

1$		move.l	d0,d5
		move.l	d0,d1
		moveq	#0,d2
		moveq	#OFFSET_END,d3
		jsr	Seek(a6)
		move.l	d5,d1
		jsr	Seek(a6)
		move.l	d0,FileLength(a5)
		move.l	d5,d1
		moveq	#0,d2
		moveq	#OFFSET_BEGINNING,d3
		jsr	Seek(a6)
		move.l	$4,a6
		move.l	FileLength(a5),d0
		moveq	#MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		move.l	d0,ShowMem(a5)
		move.l	d0,d4
		bne.s	2$
		lea	NoBufMem_txt(pc),a2
		bsr	SimpleMsg_xy
		bra	Show_Err

2$		move.l	DosBase(a5),a6		; DoBMHDPrev
		move.l	d5,d1
		move.l	d4,d2
		moveq	#120,d3
		jsr	Read(a6)
		move.l	d4,a4
		cmpi.w	#'20',2(a4)
		bne.s	7$
		cmpi.w	#'PP',(a4)
		beq.s	6$
		cmpi.w	#'PX',(a4)
		bne.s	7$
		bsr	OpenRT
		beq	ShowTypE
6$		move.l	$4,a6
		move.l	ShowMem(a5),a1
		move.l	FileLength(a5),d0
		jsr	FreeMem(a6)
		clr.l	ShowMem(a5)
		move.l	a2,a4
		bsr	LoadPP20
		move.l	PPBuffer(a5),d4
		beq	ShowTypE
		move.l	d4,a4
		move.l	d4,ShowMem(a5)
		move.l	PPLen(a5),FileLength(a5)
		bsr	CheckIfILBM
		bne	ShowTypE
		bra	PPPic
7$		cmpi.l	#WB_DISKMAGIC.VERSION,(a4)
		beq	ShowIcon
		bsr	CheckIfILBM
		bne	ShowTypE

		moveq	#((120-$14)/4)-1,d7	; Print picsizes while loading
3$		cmpi.l	#'BMHD',(a4)+		; the rest if possible...
		beq.s	4$
		dbf	d7,3$
		bra.s	5$
4$		movem.l	d4-d5/a6,-(sp)
		subq.l	#4,a4
		bsr	GetBMHD_Sub
		movem.l	(sp)+,d4-d5/a6

5$		move.l	d5,d1
		moveq	#0,d2
		moveq	#OFFSET_BEGINNING,d3
		jsr	Seek(a6)
		move.l	d5,d1
		move.l	d4,d2
		move.l	FileLength(a5),d3
		jsr	Read(a6)
		cmp.l	d0,d3
		bne	Show_Clean

PPPic		move.l	d4,a4
		lea	12(a4),a4

ChunkLoop	cmpi.l	#'BMHD',(a4)
		bne.s	Check_CMAP
		bsr.s	GetBMHD_Sub
		add.l	(a4)+,a4

Check_CMAP	cmpi.l	#'CMAP',(a4)
		bne.s	Check_CAMG
		addq.l	#4,a4
		move.l	a4,a0
		addq.l	#4,a0
		moveq	#$0f,d3
		lsl.l	#4,d3
		move.l	(a4),d7
		divu	#3,d7
		move.w	d7,Packed+2(a5)
		subq.w	#1,d7
		move.l	Buf1(a5),a1
1$		move.b	(a0)+,d0
		move.b	(a0)+,d1
		move.b	(a0)+,d2
		and.w	d3,d0
		and.w	d3,d1
		and.w	d3,d2
		lsl.w	#4,d0
		lsr.w	#4,d2
		or.w	d0,d2
		or.w	d1,d2
		move.w	d2,(a1)+
		dbf	d7,1$
		add.l	(a4)+,a4
		bra.s	ChunkLoop

Check_CAMG	cmpi.l	#'CAMG',(a4)
		bne.s	Check_BODY
		move.w	8+2(a4),CAmg(a5); Who needs those 2 first bytes?
		addq.l	#4,a4
		add.l	(a4)+,a4
		bra.s	ChunkLoop

Check_BODY	cmpi.l	#'BODY',(a4)
		beq	FoundBODY
		addq.l	#4,a4
		move.l	(a4)+,d0
		btst	#0,d0
		beq.s	1$
		addq.l	#1,d0		; If not even length (Brilliance1.0!)
1$		add.l	d0,a4
		bra.s	ChunkLoop

GetBMHD_Sub	addq.l	#4,a4
		move.l	a4,a0
		addq.l	#4,a0
		move.l	ShowScr(a5),a1
		move.b	10(a0),Packed(a5)
		move.w	(a0),d0
		move.w	d0,PicBytesPerRow+2(a5)	; Real width of pic -used later
		move.w	16(a0),ns_Width(a1)
		moveq	#0,d1			; !!! Don't remove...
		move.w	d0,d1
		divu	#16,d1
		move.w	d1,d2
		swap	d1
		tst.w	d1
		beq.s	1$
		addq.w	#1,d2
1$		lsl.w	#1,d2
		andi.w	#$00ff,d2	; Puhdista paska ylemmasta tavusta!
		move.w	d2,PicBytesPerRow(a5)
		move.w	2(a0),d1
		move.w	d1,CAmg+2(a5)	; PicRealHeight - used later
		moveq	#16,d2		; Can't open too small screen -crash!
		cmp.w	d2,d1
		bcc.s	2$
		move.w	d2,ns_Height(a1)
		bra.s	3$
2$		move.w	d1,ns_Height(a1)
3$		moveq	#0,d2
		move.b	8(a0),d2
		move.w	d2,ns_Depth(a1)
		move.w	16(a0),Para2+2(a5)
		move.w	18(a0),Para3(a5)
		lea	PicSize_txt(pc),a0
		move.w	d0,Para(a5)
		move.w	d1,Para+2(a5)
		move.w	d2,Para2(a5)
		moveq	#MsgX,d2
		moveq	#MsgY,d3
		bsr	DpyMsg
		rts

FoundBODY	addq.l	#8,a4
		move.l	a4,BODYData(a5)
		move.l	ShowScr(a5),a0
		move.w	CAmg(a5),ns_ViewModes(a0)
		move.l	IBase(a5),a6
		jsr	OpenScreen(a6)
		move.l	d0,ShowScreen(a5)
		beq	Show_Clean
		move.l	d0,a2
		move.l	GfxBase(a5),a6
		lea	sc_ViewPort(a2),a0
		move.l	Buf1(a5),a1
		move.w	Packed+2(a5),d0
		jsr	LoadRGB4(a6)

		bsr	PicToScrn
		bsr	PtrOff
		move.l	ShowScreen(a5),a0
		jsr	ScreenToFront(a6)

		move.l	GfxBase(a5),a6
3$		jsr	WaitTOF(a6)
		btst	#6,$bfe001
		bne.s	3$

Show_Clean	move.l	IBase(a5),a6
		move.l	ShowScreen(a5),d0
		beq.s	1$
		move.l	d0,a0
		jsr	CloseScreen(a6)
1$		move.l	DosBase(a5),a6
		move.l	FileHandle1(a5),d1
		beq.s	2$
		jsr	Close(a6)
		clr.l	FileHandle1(a5)
2$		move.l	IconBase(a5),a6
		move.l	IconAddr(a5),d0
		beq.s	3$
		move.l	d0,a0
		jsr	FreeDiskObject(a6)
3$		move.l	$4,a6
		move.l	ShowMem(a5),d0
		beq.s	4$
		move.l	d0,a1
		move.l	FileLength(a5),d0
		jsr	FreeMem(a6)
4$		move.l	IconBase(a5),d0
		beq.s	5$
		move.l	d0,a1
		jsr	CloseLibrary(a6)
5$		clr.l	PPBuffer(a5)
		clr.l	PPLen(a5)
		bsr	BusyOn
		bsr	AddGs
		rts

ShowTypE	lea	FileTypeErr_txt(pc),a2
		bsr	SimpleMsg_xy
Show_Err	bsr	KeyToCont_Sub
		bra.s	Show_Clean

ShowIcon	move.l	$4,a6
		lea	IconName(pc),a1
		moveq	#0,d0
		jsr	OpenLibrary(a6)
		move.l	d0,IconBase(a5)
		bne.s	1$
		lea	NeedIconLib_txt(pc),a2
		bsr	SimpleMsg_xy
		bra.s	Show_Err

1$		move.l	a2,a0
		move.l	Buf1(a5),a1
2$		move.b	(a0)+,(a1)+
		bne.s	2$
		subq.l	#6,a1
		clr.b	(a1)

		move.l	d0,a6
		move.l	Buf1(a5),a0
		jsr	GetDiskObject(a6)
		move.l	d0,IconAddr(a5)
		beq	Show_Err

		move.l	d0,a0
		lea	do_Gadget(a0),a0
		move.w	#640,d3
		sub.w	gg_Width(a0),d3
		lsr.w	#1,d3
		move.w	#256,d4
		sub.w	gg_Height(a0),d4
		lsr.w	#1,d4
		move.l	gg_GadgetRender(a0),a2
		move.l	gg_SelectRender(a0),a3
		move.l	a3,d0
		bne.s	3$
		move.l	a2,a3
3$		move.l	a2,d2

		move.l	IBase(a5),a6
		move.l	ShowScr(a5),a0
		move.w	#640,ns_Width(a0)
		move.w	#256,ns_Height(a0)
		move.w	ig_Depth(a2),ns_Depth(a0)
		move.w	#V_HIRES,ns_ViewModes(a0)
		jsr	OpenScreen(a6)
		move.l	d0,ShowScreen(a5)
		beq	Show_Clean
		move.l	d0,a0
		lea	sc_RastPort(a0),a0
		move.l	a0,ScrRPort(a5)
		bsr	PtrOff

DrawIcon	move.l	IBase(a5),a6
		move.l	ScrRPort(a5),a0
		move.l	d2,a1
		move.w	d3,d0
		move.w	d4,d1
		jsr	DrawImage(a6)

		move.l	ShowScreen(a5),a0
		jsr	ScreenToFront(a6)

		move.l	GfxBase(a5),a6
1$		jsr	WaitTOF(a6)
		cmpi.b	#$77,$bfec01
		beq.s	Altern8
2$		btst	#6,$bfe001
		bne.s	1$
		bra	Show_Clean

Altern8		cmp.l	a2,d2
		beq.s	1$
		move.l	a2,d2
		bra.s	2$
1$		move.l	a3,d2
2$		cmpi.b	#$77,$bfec01
		beq.s	2$
		bra.s	DrawIcon

PicToScrn	lea	sc_BitMap(a2),a2
		lea	bm_Planes(a2),a3

		move.w	PicBytesPerRow+2(a5),d0	; Real width of pic!
		move.w	d0,d1
		divu	#8,d0	; May be different than from divu#16!
		move.w	d0,d2
		swap	d0
		tst.w	d0
		beq.s	1$
		addq.w	#1,d2
1$		swap	d0
		lsl.w	#3,d0	; *8
		sub.w	d0,d1
		lea	PixsLeft(pc),a1	; Remove leftover pixels with AND
		move.b	0(a1,d1.w),d3

		move.w	PicBytesPerRow(a5),d4
		move.w	bm_BytesPerRow(a2),d5
	;	move.w	bm_Rows(a2),d6
		move.w	CAmg+2(a5),d6
		subq.w	#1,d6
		move.l	BODYData(a5),a0

		move.l	UseOnlyNowBuf(a5),a1
		moveq	#7,d7
2$		move.l	(a3)+,(a1)+		; Max 8 planes?
		dbf	d7,2$
		clr.l	(a1)

		tst.b	Packed(a5)
		bne.s	UnCompress

NoCompress	move.l	UseOnlyNowBuf(a5),a2
1$		move.w	d4,d7
		subq.w	#1,d7
		move.l	(a2),a1
		move.l	a1,a3
2$		move.b	(a0)+,(a1)+
		dbf	d7,2$
		add.w	d2,a3
		and.b	d3,-1(a3)	; Remove possible leftover crap-bits
		cmp.b	d2,d5
		bls.s	5$
		clr.b	(a3)		; and next byte if not last
5$		move.w	d4,d0
3$		cmp.w	d0,d5
		bls.s	4$
		addq.w	#1,d0
		clr.b	(a1)+
		bra.s	3$

4$		move.l	a1,(a2)+
		tst.l	(a2)
		bne.s	1$
		dbf	d6,NoCompress
		rts

UnCompress	move.l	UseOnlyNowBuf(a5),a2
1$		move.l	(a2),a1
		move.l	a1,a3
		moveq	#0,d7

2$		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.s	4$
		add.l	d0,d7
		addq.l	#1,d7
3$		move.b	(a0)+,(a1)+	; Identical
		dbf	d0,3$
		bra.s	6$

4$		move.b	(a0)+,d1
		neg.b	d0
		add.l	d0,d7
		addq.l	#1,d7
5$		move.b	d1,(a1)+	; Duplicate
		dbf	d0,5$

6$		cmp.w	d4,d7
		bcs.s	2$
		add.w	d2,a3
		and.b	d3,-1(a3)
		cmp.b	d2,d5
		bls.s	7$
		clr.b	(a3)
7$		cmp.w	d7,d5
		beq.s	8$
		addq.w	#1,d7
		clr.b	(a1)+
		bra.s	7$

8$		move.l	a1,(a2)+
		tst.l	(a2)
		bne.s	1$
		dbf	d6,UnCompress
		rts

CheckIfILBM	cmpi.l	#'FORM',(a4)
		bne.s	1$
		addq.l	#8,a4
		cmpi.l	#'ILBM',(a4)+
		bne.s	1$
		moveq	#0,d0
1$		rts

**** Take size of CopyBuffer ****
TakeSize	move.w	#$0401,d0
		bsr	FindMenuStruct
		move.w	mi_Flags(a0),d0
		andi.w	#CHECKED,d0
		beq.s	SetSize_Manual

		bset	#AutoSize,CTRL_4(a5)
		rts

SetSize_Manual	bclr	#AutoSize,CTRL_4(a5)
		bsr	RemGs
		move.l	StringGadget1(a5),a1
		ori.w	#LONGINT,gg_Activation(a1)
		moveq	#5,d0
		lea	gg_SIZEOF(a1),a1
		move.w	d0,si_MaxChars(a1)
		move.l	SetBufSize(a5),si_LongInt(a1)
		move.l	si_Buffer(a1),a0
		move.l	BufSizeBuf(a5),(a0)+
		clr.b	(a0)
		subq.b	#1,d0
		move.w	d0,si_BufferPos(a1)
		move.l	FirstDevGadget(a5),a3
		moveq	#3,d7
		bsr	OffGs
		bsr	AddGs
		lea	BUF_txt(pc),a2
		lea	Empty_txt(pc),a3
		moveq	#-1,d2
		bset	#NumStrings,CTRL_1(a5)
		bsr	DoVakio
		move.l	StringGadget1(a5),a0
		lea	gg_SIZEOF(a0),a0
		tst.b	(a2)
		bne.s	2$
1$		move.l	SetBufSize(a5),si_LongInt(a0)
		move.l	si_Buffer(a0),a1
		move.l	BufSizeBuf(a5),(a1)+
		clr.b	(a1)
		clr.l	BufSize(a5)
		bra.s	4$
2$		cmpi.b	#'0',(a2)		; '064' = '0'!!!
		beq.s	1$
		move.l	si_LongInt(a0),d0
		bpl.s	3$			; '-' not allowed
		neg.l	d0
3$		move.l	d0,SetBufSize(a5)
		lsl.l	#8,d0
		lsl.l	#2,d0			; *1024
		move.l	d0,BufSize(a5)
4$		bsr	SmallWindow
		bsr	RemGs
		move.l	StringGadget1(a5),a0
		andi.w	#RELVERIFY!GADGIMMEDIATE,gg_Activation(a0)
		move.w	#79,gg_SIZEOF+si_MaxChars(a0)
		move.l	gg_SIZEOF+si_Buffer(a0),a1
		move.l	(a1),BufSizeBuf(a5)
		clr.b	(a1)
		clr.w	gg_SIZEOF+si_BufferPos(a0)
		move.l	FirstDevGadget(a5),a3
		moveq	#3,d7
		bsr	OnGs
		bsr	AddGs
		bsr	String2On

		tst.l	BufSize(a5)
		bne.s	5$
		move.w	#$0401,d0
		bsr	FindMenuStruct
		ori.w	#CHECKED,mi_Flags(a0)
		move.l	mi_NextItem(a0),a0
		andi.w	#~CHECKED,mi_Flags(a0)
		bset	#AutoSize,CTRL_4(a5)
5$		rts

TakePointer	bclr	#PointerPtr,CTRL_2(a5)
		move.w	#$0440,d0
		bsr	FindMenuStruct
		move.w	mi_Flags(a0),d0
		andi.w	#CHECKED,d0
		beq.s	1$
		bset	#PointerPtr,CTRL_2(a5)
1$		rts

TakeBorders	move.w	#$0421,d0
		bsr	FindMenuStruct
		move.w	mi_Flags(a0),d0
		move.w	#CHECKED,d5
		and.w	d5,d0
		beq.s	AsKick20
AsKick13	moveq	#1,d0
		moveq	#2,d1
		cmp.b	FPen(a5),d0
		beq.s	1$
		bsr.s	BorderCols_Sub
		move.w	#$0421,d0
		bsr	FindMenuStruct
		or.w	d5,mi_Flags(a0)
		move.l	mi_NextItem(a0),a0
		not.w	d5
		and.w	d5,mi_Flags(a0)
1$		rts
AsKick20	moveq	#2,d0
		moveq	#1,d1
		cmp.b	FPen(a5),d0
		beq.s	1$
		bsr.s	BorderCols_Sub
		move.w	#$0421,d0
		bsr	FindMenuStruct
		not.w	d5
		and.w	d5,mi_Flags(a0)
		move.l	mi_NextItem(a0),a0
		not.w	d5
		or.w	d5,mi_Flags(a0)
1$		rts
BorderCols_Sub	move.b	d0,FPen(a5)
		move.b	d1,BPen(a5)
		lea	ActBorder(a5),a0
		moveq	#6,d7
1$		move.l	(a0)+,a1
		move.b	d0,bd_FrontPen(a1)
		move.b	d1,bd_BackPen(a1)
		move.b	d1,bd_SIZEOF+bd_FrontPen(a1)
		move.b	d0,bd_SIZEOF+bd_BackPen(a1)
		dbf	d7,1$

ModifyImages	move.l	DwnData(a5),a0		; Turn wht to blck & vice versa
		move.w	#%1111111111111100,d1
		move.w	#%1100000000000000,d2
		move.w	#%0011111111111111,d3
		move.w	#%0000000000000011,d4
		subq.b	#1,d0
		beq.s	1$
		exg	d1,d3
		exg	d2,d4
1$		moveq	#5,d7

Mod2Planes	moveq	#8,d6
		not.w	(a0)+
1$		and.w	d1,(a0)
		or.w	d2,(a0)+
		dbf	d6,1$
		not.w	(a0)+
;----
		moveq	#8,d6
		not.w	(a0)+
2$		and.w	d3,(a0)
		or.w	d4,(a0)+
		dbf	d6,2$
		not.w	(a0)+
		dbf	d7,Mod2Planes
		rts

TakeBADD	bset	#MarkTrckOrSecs,CTRL_2(a5)	; Tracks
		move.w	#$0431,d0
		bsr	FindMenuStruct
		move.w	mi_Flags(a0),d0
		andi.w	#CHECKED,d0
		bne.s	1$
		bclr	#MarkTrckOrSecs,CTRL_2(a5)
1$		rts

TakeScreenMode	move.l	$4,a6
		move.w	#$0411,d0
		bsr	FindMenuStruct
		move.w	mi_Flags(a0),d0
		move.l	BetaWindow(a5),a0
		move.w	#CHECKED,d3
		and.w	d3,d0
		beq.s	NTSC_On
		cmpi.b	#50,VBlankFrequency(a6)
		bne.s	NTSC_On
PAL_On		move.w	#255,nw_Height(a0)	;BWinSize
		moveq	#24,d0
		move.w	#239,d1
		move.w	#223,d2
		bsr.s	ScrSize_Sub
		move.w	#$0411,d0
		bsr	FindMenuStruct
		or.w	d3,mi_Flags(a0)
		move.l	mi_NextItem(a0),a0
		not.w	d3
		and.w	d3,mi_Flags(a0)
		bset	#ScreenMode,CTRL_2(a5)
		rts
NTSC_On		move.w	#199,nw_Height(a0)	;BWinSize
		moveq	#18,d0
		move.w	#183,d1
		move.w	#167,d2
		bsr.s	ScrSize_Sub
		move.w	#$0411,d0
		bsr	FindMenuStruct
		not.w	d3
		and.w	d3,mi_Flags(a0)
		move.l	mi_NextItem(a0),a0
		not.w	d3
		or.w	d3,mi_Flags(a0)
		bclr	#ScreenMode,CTRL_2(a5)
		rts

ScrSize_Sub	move.l	d0,PALNTSC(a5)
		move.l	DownArrow1(a5),a0
		move.l	TypeBorder(a5),a1
		move.l	bd_XY(a1),a1
		bsr.s	ChangePos_Sub
		move.l	First_Gadget(a5),a0
		move.w	d1,gg_TopEdge(a0)
		move.l	DownArrow2(a5),a0
		move.l	DirBorder(a5),a1
		move.l	bd_XY(a1),a1

ChangePos_Sub	moveq	#5,d7
1$		move.w	d1,gg_TopEdge(a0)
		move.l	gg_NextGadget(a0),a0
		dbf	d7,1$
		move.w	d2,6(a1)
		move.w	d2,10(a1)
		move.w	d2,22(a1)
		move.w	d2,34(a1)
		move.w	d2,38(a1)
		rts

LoadPrefs	move.l	IBase(a5),a6		; Prefs V.'P2' used...
		move.l	MyWindow(a5),a0
		lea	LoadPrefsTitle(pc),a1
		moveq	#-1,d0
		move.l	d0,a2
		jsr	SetWindowTitles(a6)

		move.l	DosBase(a5),a6
		move.l	#PrefsFile,d1
		move.l	#MODE_OLDFILE,d2
		jsr	Open(a6)
		move.l	d0,d4
		beq.s	2$

		move.l	d4,d1
		move.l	UseOnlyNowBuf(a5),d2
		moveq	#32,d3
		jsr	Read(a6)
		move.l	d0,d5
		move.l	d4,d1
		jsr	Close(a6)
		cmp.l	d5,d3
		bne.s	2$
		move.l	d2,a2
		cmpi.w	#'P2',(a2)+
		bne.s	2$

		move.w	#$0400,d0
		bsr	FindMenuStruct
		move.l	a0,a1
		move.l	(a2)+,BufSize(a5)
		move.l	(a2)+,SetBufSize(a5)
		move.l	(a2)+,BufSizeBuf(a5)
		move.l	mi_SubItem(a1),a1
		move.w	(a2)+,mi_Flags(a1)
		move.l	mi_NextItem(a1),a1
		move.w	(a2)+,mi_Flags(a1)

		bsr.s	LoadTwoSubs
		bsr.s	LoadTwoSubs
		bsr.s	LoadTwoSubs
		move.l	mi_NextItem(a0),a1
		move.w	(a2)+,mi_Flags(a1)

2$		bsr	TakeBADD
		bsr	TakePointer
		bsr	TakeVecs
		bsr	TakeScreenMode
		bsr	TakeBorders
		rts

LoadTwoSubs	move.l	mi_NextItem(a0),a1
		move.l	a1,a0
		move.l	mi_SubItem(a1),a1
		move.w	(a2)+,mi_Flags(a1)
		move.l	mi_NextItem(a1),a1
		move.w	(a2)+,mi_Flags(a1)
		rts

SavePrefs	move.l	IBase(a5),a6
		move.l	MyWindow(a5),a0
		lea	SavePrefsTitle(pc),a1
		moveq	#-1,d0
		move.l	d0,a2
		jsr	SetWindowTitles(a6)

		move.w	#$0400,d0
		bsr	FindMenuStruct
		move.l	a0,a1
		move.l	UseOnlyNowBuf(a5),a2

		move.w	#'P2',(a2)+		; PrefsVersion
		move.l	BufSize(a5),(a2)+
		move.l	SetBufSize(a5),(a2)+
		move.l	BufSizeBuf(a5),(a2)+
		move.l	mi_SubItem(a1),a1
		move.w	mi_Flags(a1),(a2)+
		move.l	mi_NextItem(a1),a1
		move.w	mi_Flags(a1),(a2)+

		bsr.s	SaveTwoSubs
		bsr.s	SaveTwoSubs
		bsr.s	SaveTwoSubs
		move.l	mi_NextItem(a0),a1
		move.w	mi_Flags(a1),(a2)+

		move.l	DosBase(a5),a6
		move.l	#PrefsFile,d1
		move.l	#MODE_NEWFILE,d2
		jsr	Open(a6)
		move.l	d0,d4
		beq.s	2$

		move.l	d4,d1
		move.l	UseOnlyNowBuf(a5),d2
		moveq	#32,d3
		jsr	Write(a6)
		move.l	d4,d1
		jsr	Close(a6)
2$		rts

SaveTwoSubs	move.l	mi_NextItem(a0),a1
		move.l	a1,a0
		move.l	mi_SubItem(a1),a1
		move.w	mi_Flags(a1),(a2)+
		move.l	mi_NextItem(a1),a1
		move.w	mi_Flags(a1),(a2)+
		rts

KeyToContClr_Sub bsr.s	KeyToCont_Sub
		bsr	ClrMsgBorder
		rts
KeyToCont_Sub	bsr	BusyKey
		lea	PressKey_txt(pc),a2
		bsr	SimpleMsg_xy
		bsr	WaitKey
		move.w	#Msg3Y,CurrMsgY(a5)
		btst	#IsBusyPtrOn,CTRL_2(a5)
		bne.s	1$
		bsr	ArrowOn
1$		rts

OpenFileErr_Sub	move.l	#OpenErr_txt,d2
		bra.s	Error_Sub
LockErr_Sub	move.l	#LockErr_txt,d2
		bra.s	Error_Sub
ExamineErr_Sub	move.l	#ExamineErr_txt,d2
Error_Sub	jsr	IoErr(a6)
		move.l	d0,DidError(a5)
COSE		move.l	d2,a2
		bsr	SimpleMsg_xy
		bsr.s	DErrDpyMsg
		rts

CopyOpnSrcErr	move.l	#OpenErr_txt,d2
		bra.s	COSE

DOS_Err		bsr.s	Beeppaa
		move.l	DosBase(a5),a6
		jsr	IoErr(a6)
		move.l	d0,DidError(a5)
		lea	IDFailed_txt(pc),a0
		bsr	DpyMsg_xy
		bsr.s	DErrDpyMsg
		bsr	KeyToCont_Sub
		bsr	ClrMsgBorder
		rts

Beeppaa		move.l	IBase(a5),a6
		sub.l	a0,a0
		jsr	DisplayBeep(a6)
		rts

DErrDpyMsg	moveq	#NumKnownErrs-1,d7
		lea	ErrNums(pc),a0
		lea	ErrAddrs(pc),a1
		move.l	DidError(a5),d0
1$		cmp.b	(a0)+,d0
		beq.s	2$
		addq.l	#4,a1
		dbf	d7,1$
		lea	Unknwn(pc),a0
		move.l	a0,Para2(a5)
		bra.s	3$
2$		move.l	(a1),Para2(a5)
3$		move.l	d0,Para(a5)
		move.l	GfxBase(a5),a6
		move.l	CurrRP(a5),a1
		moveq	#3,d0
		jsr	SetAPen(a6)
		lea	DErr_txt(pc),a0
		bsr.s	DpyMsg_xy
		move.l	CurrRP(a5),a1
		moveq	#1,d0
		jsr	SetAPen(a6)
		bsr.s	Beeppaa
		rts

DpyMsg_xy	moveq	#MsgX,d2
		move.w	CurrMsgY(a5),d3
		addi.w	#9,CurrMsgY(a5)

DpyMsg		bsr.s	Dpy
		bsr.s	TakeLen
		move.l	d2,d0
		move.l	d3,d1
		bsr.s	WMsg
		rts

WMsg		move.l	GfxBase(a5),a6
		move.l	CurrRP(a5),a1
		andi.l	#$0000ffff,d1
		jsr	xMove(a6)
		move.l	CurrRP(a5),a1
		move.l	TxtBuffer(a5),a0
		move.l	MsgLength(a5),d0
		jsr	Text(a6)
		rts

TakeLen		move.l	TxtBuffer(a5),a0
		bsr	LenOfa0
		cmpi.b	#76,d0
		bls.s	1$
		moveq	#76,d0
1$		move.l	d0,MsgLength(a5)
		rts

Dpy		move.l	$4,a6
		lea	Para(a5),a1
		lea	PutChar(pc),a2
		move.l	TxtBuffer(a5),a3
		jsr	RawDoFmt(a6)
		rts

SimpleMsg_xy	moveq	#MsgX,d0
		move.w	CurrMsgY(a5),d1
		addi.w	#9,CurrMsgY(a5)

SimpleMsg	move.l	GfxBase(a5),a6
		move.l	CurrRP(a5),a1
		move.l	a1,d2
		andi.l	#$0000ffff,d1
		jsr	xMove(a6)
		move.l	d2,a1
		moveq	#0,d0
		move.b	(a2)+,d0
		move.l	a2,a0
		jsr	Text(a6)
		rts

PutChar		move.b	d0,(a3)+
		rts

WaitIDCMP	bsr	TakeIDCMP
		tst.l	d2
		bne.s	2$
		move.l	a6,-(sp)
		move.l	$4,a6
1$		move.l	IDCMPWin(a5),a0
		move.l	wd_UserPort(a0),a2
		moveq	#0,d0
		moveq	#0,d1
		move.b	MP_SIGBIT(a2),d1
		bset	d1,d0
		jsr	Wait(a6)
		move.l	a2,a0
		jsr	GetMsg(a6)
		tst.l	d0
		beq.s	1$
		bsr.s	IDCMPSub
		move.l	(sp)+,a6
2$		rts

IDCMPSub	move.l	d0,a2
		move.l	im_Class(a2),d2
		move.w	im_Code(a2),d3
		move.l	im_IAddress(a2),d4
		move.w	im_Qualifier(a2),d5
		move.w	im_MouseX(a2),MusseX(a5)
		move.w	im_MouseY(a2),MusseY(a5)
		move.l	a2,a1
		jsr	ReplyMsg(a6)
		rts

TakeIDCMP	move.l	a6,-(sp)
		move.l	$4,a6
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		move.l	IDCMPWin(a5),a0
		move.l	wd_UserPort(a0),a2
		move.l	a2,a0
		jsr	GetMsg(a6)
		tst.l	d0
		beq.s	1$
		bsr.s	IDCMPSub
1$		move.l	(sp)+,a6
		rts

WaitKey		movem.l	d6/a6,-(sp)
		move.l	IBase(a5),a6
		move.l	IDCMPWin(a5),d6
		moveq	#$20,d7
		swap	d7			; VANILLAKEY
		move.l	d6,a0
		move.l	d7,d0
		jsr	ModifyIDCMP(a6)
1$		bsr	WaitIDCMP
		cmp.l	d7,d2
		bne.s	1$
		move.l	d6,a0
		move.l	#IDCMP,d0
		jsr	ModifyIDCMP(a6)
		movem.l	(sp)+,d6/a6
		rts

GetOldMsgs	bsr.s	TakeIDCMP
		tst.l	d2
		bne.s	GetOldMsgs
		rts

WaitStrings	bsr	ActivateString1
WaitString	bsr	WaitIDCMP
		move.l	d4,a2
		move.l	d2,d0
		lsr.l	#5,d0
		subq.b	#1,d0		; GADGETDOWN
		beq.s	StringActivated
		subq.b	#1,d0		; GADGETUP
		beq.s	GotGadget
		subi.b	#14,d0		; CLOSEWINDOW
		bne.s	WaitString
		lea	ZeroAnswer(a5),a2
		moveq	#-1,d0
		rts
GotGadget	move.w	gg_GadgetID(a2),d0
		subi.b	#11,d0
		beq.s	GotString1
		subq.b	#1,d0
		beq.s	GotString2
		subi.b	#88,d0
		beq	GotDev0
		subq.b	#1,d0
		beq	GotDev1
		subq.b	#1,d0
		beq	GotDev2
		bra	GotDev3

GotString1	btst	#NumStrings,CTRL_1(a5)	; Need only 1 Parm ?
		bne.s	GotString2
		bsr	ActivateString2
		bra.s	WaitString

GotString2	move.l	StringGadget1(a5),a0
		move.l	gg_SIZEOF+si_Buffer(a0),a2
		move.l	StringGadget2(a5),a0
		move.l	gg_SIZEOF+si_Buffer(a0),a3

		clr.b	CTRL_3(a5)
		move.l	FirstOptGadget(a5),a0
		move.w	#SELECTED,d1
		moveq	#7,d7
1$		move.w	gg_Flags(a0),d0
		and.w	d1,d0
		beq.s	2$
		bset	d7,CTRL_3(a5)
2$		move.l	gg_NextGadget(a0),a0
		dbf	d7,1$
		rts

StringActivated	move.w	gg_GadgetID(a2),d0
		cmpi.w	#12,d0
		bls.s	WasString
		move.b	ActiveString(a5),d0
		beq.s	2$
		subq.b	#1,d0
		bne.s	1$
		bsr	ActivateString1
		bra.s	2$
1$		bsr	ActivateString2
2$		bra	WaitString

WasString	clr.b	ActiveString(a5)
		move.w	#SELECTED,d1
		move.l	StringGadget1(a5),a0
		move.w	gg_Flags(a0),d0
		and.w	d1,d0
		bne.s	2$
1$		move.l	StringGadget2(a5),a0
		move.w	gg_Flags(a0),d0
		and.w	d1,d0
		beq.s	3$
		addq.b	#1,ActiveString(a5)
2$		addq.b	#1,ActiveString(a5)
3$		bra	WaitString

GotDev0		lea	Dev0_txt(pc),a0
		bra.s	WriteIntoString
GotDev1		lea	Dev1_txt(pc),a0
		bra.s	WriteIntoString
GotDev2		lea	Dev2_txt(pc),a0
		bra.s	WriteIntoString
GotDev3		lea	Dev3_txt(pc),a0

WriteIntoString	moveq	#4,d1
		move.b	ActiveString(a5),d0
		beq.s	4$
		subq.b	#1,d0
		beq.s	2$

		move.l	StringGadget2(a5),a1
		move.w	d1,gg_SIZEOF+si_BufferPos(a1)
		move.l	gg_SIZEOF+si_Buffer(a1),a1
1$		move.b	(a0)+,(a1)+
		bne.s	1$
		bsr.s	FreshGs
		bsr.s	ActivateString2
		bra.s	4$
2$		move.l	StringGadget1(a5),a1
		move.w	d1,gg_SIZEOF+si_BufferPos(a1)
		move.l	gg_SIZEOF+si_Buffer(a1),a1
3$		move.b	(a0)+,(a1)+
		bne.s	3$
		bsr.s	FreshGs
		bsr.s	ActivateString1
4$		bra	WaitString

ActivateString1	move.l	StringGadget1(a5),a0
		move.l	MyWindow(a5),a1
		sub.l	a2,a2
		jsr	ActivateGadget(a6)
		move.b	#1,ActiveString(a5)
		rts
ActivateString2	move.l	StringGadget2(a5),a0
		move.l	MyWindow(a5),a1
		sub.l	a2,a2
		jsr	ActivateGadget(a6)
		move.b	#2,ActiveString(a5)
		rts
FreshGs		move.l	StringGadget1(a5),a0
		move.l	MyWindow(a5),a1
		sub.l	a2,a2
		moveq	#2,d0
		btst	#NumStrings,CTRL_1(a5)	; No need to fresh 'ghosted'...
		beq.s	1$
		moveq	#1,d0
1$		jsr	RefreshGList(a6)
		rts

BigWindow	move.l	MyWindow(a5),a4
		move.l	IBase(a5),a6
		move.l	a2,d3
		move.l	a4,a0
		lea	EnterParmsTitle(pc),a1
		moveq	#-1,d0
		move.l	d0,a2
		jsr	SetWindowTitles(a6)
		move.l	d3,a2

		move.l	StringGadget1(a5),a0
		lea	gg_SIZEOF+si_SIZEOF(a0),a0
		move.l	StringGadget2(a5),a1
		lea	gg_SIZEOF+si_SIZEOF(a1),a1
		move.l	a2,it_IText(a0)
		move.l	a3,it_IText(a1)

		move.w	d2,d7
		bmi.s	NoOptsOn
		bsr	RemGs
		lea	LONG_1(a5),a0
		move.l	FirstOptGadget(a5),d3
		move.l	d3,a3
1$		move.l	(a0)+,gg_SIZEOF+it_IText(a3)
		move.l	gg_NextGadget(a3),a3
		dbf	d7,1$

		move.l	d3,a3
		move.w	d2,d7
		bsr	OnGs

		cmp.l	LastComm(a5),a2
		beq.s	3$
		move.l	a2,LastComm(a5)
		move.l	d3,a3
		move.w	#~SELECTED,d0
		move.w	#~ACTIVEGADGET,d1
		moveq	#7,d7
2$		and.w	d0,gg_Flags(a3)
		and.w	d1,gg_Activation(a3)
		move.l	gg_NextGadget(a3),a3
		dbf	d7,2$
3$		bsr	AddGs

NoOptsOn	move.l	a4,a0
		moveq	#0,d0
		moveq	#0,d1
		move.w	wd_TopEdge(a0),d1
		neg.w	d1
		addq.w	#1,d1
		jsr	MoveWindow(a6)
		move.l	a4,a0
		moveq	#0,d0
		move.w	#167,d1
		jsr	SizeWindow(a6)
		move.l	DosBase(a5),a6
		moveq	#100,d2
1$		moveq	#5,d1		; Own NEWSIZE routine...
		jsr	Delay(a6)
		cmp.w	wd_Height(a4),d2
		bhi.s	1$
		move.l	GfxBase(a5),a6
		move.l	RPort(a5),d5
		move.l	d5,a1
		moveq	#0,d0
		move.b	BPen(a5),d0
		jsr	SetAPen(a6)
		move.l	d5,a1
		moveq	#RP_JAM1,d0
		jsr	SetDrMd(a6)
		lea	PrgTitle(pc),a3
		lea	NextGen(pc),a4

		move.l	a3,a2
		moveq	#30,d0
		moveq	#20,d1
		bsr	SimpleMsg
		move.l	a4,a2
		move.w	#280,d0
		moveq	#20,d1
		bsr	SimpleMsg
		move.l	d5,a1
		moveq	#20,d0
		moveq	#23,d1
		jsr	xMove(a6)
		move.l	d5,a1
		move.w	#620,d0
		moveq	#23,d1
		jsr	Draw(a6)

		move.l	d5,a1
		moveq	#0,d0
		move.b	FPen(a5),d0
		jsr	SetAPen(a6)
		move.l	a3,a2
		moveq	#28,d0
		moveq	#19,d1
		bsr	SimpleMsg
		move.l	a4,a2
		move.w	#278,d0
		moveq	#19,d1
		bsr	SimpleMsg
		move.l	d5,a1
		moveq	#18,d0
		moveq	#22,d1
		jsr	xMove(a6)
		move.l	d5,a1
		move.w	#618,d0
		moveq	#22,d1
		jsr	Draw(a6)

		move.l	d5,a1
		moveq	#1,d0
		jsr	SetAPen(a6)
		move.l	d5,a1
		moveq	#0,d0
		jsr	SetBPen(a6)
		move.l	d5,a1
		moveq	#RP_JAM2,d0
		jsr	SetDrMd(a6)

		move.l	IBase(a5),a6
		move.l	d5,a0
		lea	MpLImage(pc),a1
		move.w	#516,d0
		moveq	#12,d1
		jsr	DrawImage(a6)

		move.l	d5,a0
		move.l	ActBorder(a5),a2
		move.l	a2,a1
		moveq	#17,d0
		moveq	#105,d1
		jsr	DrawBorder(a6)
		move.l	d5,a0
		move.l	a2,a1
		moveq	#17,d0
		moveq	#118,d1
		jsr	DrawBorder(a6)
		move.l	d5,a0
		move.l	MsgBorder(a5),a1
		moveq	#17,d0
		move.w	#134,d1
		jsr	DrawBorder(a6)
		move.l	MyWindow(a5),a0
		jsr	WindowToFront(a6)
		rts

SmallWindow	bsr.s	RemGs
		move.l	MyWindow(a5),a4
		move.l	a4,IDCMPWin(a5)
		move.l	a4,a0
		jsr	ActivateWindow(a6)
		move.l	a4,a0
		moveq	#0,d0
		move.w	#-167,d1
		jsr	SizeWindow(a6)
		move.l	DosBase(a5),a6
		moveq	#100,d2
1$		moveq	#5,d1
		jsr	Delay(a6)
		cmp.w	wd_Height(a4),d2
		bcs.s	1$
		move.l	FirstOptGadget(a5),a3
		moveq	#7,d7
		bsr.s	OffGs
		bsr.s	AddGs
		rts

OffGs		moveq	#1,d0	; a3=List, d7=Counter
		lsl.l	#8,d0	; GADGDISABLED
1$		or.w	d0,gg_Flags(a3)
		move.l	gg_NextGadget(a3),a3
		dbf	d7,1$
		rts
OnGs		move.w	#~GADGDISABLED,d0
1$		and.w	d0,gg_Flags(a3)
		move.l	gg_NextGadget(a3),a3
		dbf	d7,1$
		rts
RemGs		move.l	IBase(a5),a6
		move.l	MyWindow(a5),a0
		move.l	StringGadget1(a5),a1
		moveq	#2+4+8,d0
		jsr	RemoveGList(a6)
		rts
AddGs		move.l	IBase(a5),a6
		move.l	MyWindow(a5),a0
		move.l	StringGadget1(a5),a1
		moveq	#-1,d0
		moveq	#2+4+8,d1
		sub.l	a2,a2
		jsr	AddGList(a6)
		rts
RemIGs		move.l	IBase(a5),a6
		move.l	BWindow(a5),a0
		move.l	BetaWindow(a5),a1
		move.l	nw_FirstGadget(a1),a1
		moveq	#6+1+6,d0
		cmp.l	DownArrow1(a5),a1
		beq.s	1$
		moveq	#6,d0
1$		jsr	RemoveGList(a6)
		rts
AddIGs		move.l	IBase(a5),a6
		move.l	BWindow(a5),a0
		move.l	BetaWindow(a5),a1
		move.l	nw_FirstGadget(a1),a1
		moveq	#-1,d0
		moveq	#6+1+6,d1
		sub.l	a2,a2
		cmp.l	DownArrow1(a5),a1
		beq.s	1$
		moveq	#6,d1
1$		movem.l	d0-d1/a0-a1,-(sp)
		jsr	AddGList(a6)
		movem.l	(sp)+,d0-d1/a0-a1
		exg	a0,a1
		exg	d0,d1
		jsr	RefreshGList(a6)
		rts

String2On	move.l	#OnGadget,d3
		bra.s	SOO
String2Off	move.l	#OffGadget,d3
SOO		move.l	IBase(a5),a6
		move.l	StringGadget2(a5),a0
		move.l	MyWindow(a5),a1
		sub.l	a2,a2
		jsr	0(a6,d3.l)
		rts

MenusOn		move.l	#OnMenu,d4
		bra.s	MOO
MenusOff	move.l	#OffMenu,d4
MOO		move.l	d3,-(sp)
		move.l	IBase(a5),a6
		move.l	MyWindow(a5),d2
		move.l	#2016,d3		; %0000011111100000
		moveq	#4,d7
1$		move.l	d2,a0
		move.l	d3,d0
		jsr	0(a6,d4.l)
		addq.b	#1,d3
		dbf	d7,1$
		move.l	(sp)+,d3
		rts

OpnBWinWithFont	move.l	IBase(a5),a6
		move.l	BetaWindow(a5),a0
		jsr	OpenWindow(a6)
		move.l	d0,BWindow(a5)
		beq.s	1$
		move.l	d0,a0
		move.l	d0,IDCMPWin(a5)
		move.l	wd_RPort(a0),d2
		move.l	d2,RP(a5)
		move.l	d2,CurrRP(a5)
		move.l	GfxBase(a5),a6
		move.l	d2,a1
		move.l	Font(a5),a0
		jsr	SetFont(a6)
		move.l	d2,a1
		moveq	#1,d0
		jsr	SetAPen(a6)
		moveq	#1,d0
1$		rts

PrepareUnit	movem.l	a2-a3,-(sp)
		move.l	$4,a6
		bsr	CreatePort
		tst.b	WhichTD(a5)
		bne.s	1$
		move.l	d0,TrackPort0(a5)
		bra.s	2$
1$		move.l	d0,TrackPort1(a5)
2$		bne.s	Port_Ok

		clr.l	Para(a5)
		move.b	Unit(a5),Para+3(a5)
		lea	NoPort_txt(pc),a0
		bsr	DpyMsg_xy
		moveq	#-1,d0
		movem.l	(sp)+,a2-a3
		rts

Port_Ok		move.l	d0,a0
		bsr	CreateIO
		tst.b	WhichTD(a5)
		bne.s	1$
		move.l	d0,IOReq0(a5)
		bra.s	2$
1$		move.l	d0,IOReq1(a5)
2$		bne.s	IO_Ok

		clr.l	Para(a5)
		move.b	Unit(a5),Para+3(a5)
		lea	NoIO_txt(pc),a0
		bsr	DpyMsg_xy
		moveq	#-1,d0
		movem.l	(sp)+,a2-a3
		rts

IO_Ok		tst.b	WhichTD(a5)
		bne.s	1$
		move.l	IOReq0(a5),a1
		bra.s	OpenDev
1$		move.l	IOReq1(a5),a1

OpenDev		lea	TD_Name(pc),a0
		moveq	#0,d0
		move.b	Unit(a5),d0
		moveq	#0,d1
		jsr	OpenDevice(a6)
		tst.l	d0
		bne.s	DevError
		moveq	#0,d0
		tst.b	WhichTD(a5)
		bne.s	1$
		st.b	DeviceFlag0(a5)
		bra.s	2$
1$		st.b	DeviceFlag1(a5)
2$		movem.l	(sp)+,a2-a3
		rts

DevError	move.l	d0,Para2(a5)
		clr.l	Para(a5)
		move.b	Unit(a5),Para+3(a5)
		lea	NoUnit_txt(pc),a0
		bsr	DpyMsg_xy
		moveq	#-1,d0
		movem.l	(sp)+,a2-a3
		rts

CreatePort	moveq	#MP_SIZE+4,d0
		moveq	#MP_SIZE+4,d2
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		tst.l	d0
		beq.s	GotNoMem
		move.l	d0,a2
		move.l	d2,(a2)+
		moveq	#-1,d0
		jsr	AllocSignal(a6)
		move.b	d0,MP_SIGBIT(a2)
		bmi.s	GotNoSignal
		sub.l	a1,a1
		jsr	FindTask(a6)
		move.l	d0,MP_SIGTASK(a2)
		move.b	#NT_MSGPORT,LN_TYPE(a2)
		clr.b	MP_FLAGS(a2)
		lea	MP_MSGLIST(a2),a0
		_NEWLIST a0
		move.l	a2,d0
		rts
GotNoSignal	move.l	-(a2),d0
		move.l	a2,a1
		jsr	FreeMem(a6)
GotNoMem	rts

DeletePort	move.l	a0,a2
		moveq	#0,d0
		move.b	MP_SIGBIT(a2),d0
		jsr	FreeSignal(a6)
		move.l	-(a2),d0
		move.l	a2,a1
		jsr	FreeMem(a6)
		rts

CreateIO	move.l	a0,a2
		moveq	#IOSTD_SIZE+4,d0
		moveq	#IOSTD_SIZE+4,d2
		move.l	#MEMF_CLEAR!MEMF_PUBLIC,d1
		jsr	AllocMem(a6)
		tst.l	d0
		beq.s	1$
		move.l	d0,a0
		move.l	d2,(a0)+
		move.l	a2,MN_REPLYPORT(a0)
		move.b	#NT_MESSAGE,LN_TYPE(a0)
		subq.l	#4,d2
		move.w	d2,MN_LENGTH(a0)
		move.l	a0,d0
1$		rts

DeleteIO	move.l	a0,a1
		move.l	-(a1),d0
		jsr	FreeMem(a6)
		rts

GetDiskUnitNum	move.l	a2,a0		; From String1/2?
		tst.b	WhichTD(a5)
		beq.s	1$
		move.l	a3,a0
1$		cmpi.w	#'df',(a0)
		beq.s	2$
		cmpi.w	#'DF',(a0)
		beq.s	2$
		cmpi.w	#'Df',(a0)
		beq.s	2$
		cmpi.w	#'dF',(a0)
		bne.s	3$
2$		move.b	2(a0),d0
		subi.b	#'0',d0
		move.b	d0,Unit(a5)
		moveq	#0,d0
		rts
3$		lea	NoFloppy_txt(pc),a2
		bsr	SimpleMsg_xy
		moveq	#-1,d0
		rts

Motor0Off	move.l	IOReq0(a5),a1
		bra.s	Motor
Motor1Off	move.l	IOReq1(a5),a1
Motor		clr.l	IO_LENGTH(a1)
		move.w	#TD_MOTOR,IO_COMMAND(a1)
		move.l	$4,a6
		jsr	DoIO(a6)
		rts

**** TrackDisk CleanUp ****
TrackClean	move.l	$4,a6
		tst.b	DeviceFlag0(a5)
		beq.s	1$
		move.l	IOReq0(a5),a1
		jsr	CloseDevice(a6)
		clr.b	DeviceFlag0(a5)
1$		move.l	IOReq0(a5),d0
		beq.s	2$
		move.l	d0,a0
		bsr	DeleteIO
		clr.l	IOReq0(a5)
2$		move.l	TrackPort0(a5),d0
		beq.s	3$
		move.l	d0,a0
		bsr	DeletePort
		clr.l	TrackPort0(a5)
3$		tst.b	DeviceFlag1(a5)
		beq.s	4$
		move.l	IOReq1(a5),a1
		jsr	CloseDevice(a6)
		clr.b	DeviceFlag1(a5)
4$		move.l	IOReq1(a5),d0
		beq.s	5$
		move.l	d0,a0
		bsr	DeleteIO
		clr.l	IOReq1(a5)
5$		move.l	TrackPort1(a5),d0
		beq.s	6$
		move.l	d0,a0
		bsr	DeletePort
		clr.l	TrackPort1(a5)
6$		rts

**** Count Lenght Of String In a0 ****
LenOfa0		moveq	#0,d0
1$		addq.w	#1,d0
		tst.b	(a0)+
		bne.s	1$
		subq.w	#1,d0
		rts

**** Insert Disk Name In Root ****
DiskName	move.l	a3,a0
		bsr.s	LenOfa0

		cmpi.b	#27,d0
		bls.s	Len_Ok
		moveq	#27,d0
Len_Ok		move.l	a2,a1		;RootMemory(a5),a1
		add.w	#432,a1
		move.b	d0,(a1)+

		subq.b	#1,d0
		move.l	a3,a0
1$		move.b	(a0)+,(a1)+
		dbf	d0,1$

CalcRootChkSum	moveq	#127,d7
		move.l	a2,a0
		clr.l	20(a2)
		moveq	#0,d0
1$		sub.l	(a0)+,d0
		dbf	d7,1$
		move.l	d0,20(a2)
		rts

**** Check Disk And Write Protection ****
TestDisk	move.l	a1,a4
		move.w	#TD_CHANGESTATE,IO_COMMAND(a1)
		jsr	DoIO(a6)
		moveq	#0,d0
		tst.l	IO_ACTUAL(a4)
		beq.s	1$
		clr.l	Para(a5)
		move.b	Unit(a5),Para+3(a5)
		lea	NoDisk_txt(pc),a0
		bsr	DpyMsg_xy
		moveq	#-1,d0
1$		rts

TestWProt	move.l	a4,a1
		move.w	#TD_PROTSTATUS,IO_COMMAND(a1)
		jsr	DoIO(a6)
		moveq	#0,d0
		tst.l	IO_ACTUAL(a4)
		beq.s	1$
		clr.l	Para(a5)
		move.b	Unit(a5),Para+3(a5)
		lea	DiskProt_txt(pc),a0
		bsr	DpyMsg_xy
		moveq	#-1,d0
1$		rts

ClrTypeScr	move.l	GfxBase(a5),a6
		move.l	RP(a5),a2
		move.l	a2,a1
		moveq	#0,d0
		jsr	SetAPen(a6)
		move.l	a2,a1
		moveq	#10,d0
		moveq	#14,d1
		move.w	#629,d2
		moveq	#0,d3
		move.l	BetaWindow(a5),a0
		move.w	nw_Height(a0),d3	;BWinSize
		subi.b	#22,d3
		jsr	RectFill(a6)
		rts
TScrollUp	move.l	GfxBase(a5),a6
		jsr	WaitTOF(a6)
		move.l	RP(a5),a1
		moveq	#0,d0
		moveq	#9,d1
		moveq	#10,d2
		moveq	#15,d3
		move.w	#629,d4
		moveq	#0,d5
		move.l	BetaWindow(a5),a0
		move.w	nw_Height(a0),d5	;BWinSize
		subi.b	#22,d5
		jsr	ScrollRaster(a6)
		rts
TScrollDown	move.l	GfxBase(a5),a6
		jsr	WaitTOF(a6)
		move.l	RP(a5),a1
		moveq	#0,d0
		moveq	#-9,d1
		moveq	#10,d2
		moveq	#15,d3
		move.w	#629,d4
		moveq	#0,d5
		move.l	BetaWindow(a5),a0
		move.w	nw_Height(a0),d5	;BWinSize
		subi.b	#22,d5
		btst	#ScreenMode,CTRL_2(a5)
		beq.s	1$
		subq.w	#2,d5			; 2 lisaa jos PAL
1$		jsr	ScrollRaster(a6)
		rts

ClrDirScr	move.l	GfxBase(a5),a6
		moveq	#0,d4
		move.l	BetaWindow(a5),a0
		move.w	nw_Height(a0),d4	;BWinSize
		subi.b	#22,d4
		move.l	RP(a5),a3
		move.l	a3,a1
		moveq	#0,d0
		jsr	SetAPen(a6)
		move.l	a3,a1
		moveq	#10,d0
		moveq	#14,d1
		move.w	#315,d2
		move.l	d4,d3
		jsr	RectFill(a6)
		move.l	a3,a1
		move.w	#324,d0
		moveq	#14,d1
		move.w	#629,d2
		jsr	RectFill(a6)
		move.l	a3,a1
		moveq	#8,d0
		addq.l	#4,d4
		move.l	d4,d1
		move.w	#148,d2
		move.l	d4,d3
		addi.b	#15,d3
		jsr	RectFill(a6)
		move.l	a3,a1
		move.w	#322,d0
		move.l	d4,d1
		move.w	#518,d2
		jsr	RectFill(a6)
		move.l	a3,a1
		moveq	#1,d0
		jsr	SetAPen(a6)
		rts

ClrMsgBorder	move.l	GfxBase(a5),a6
		move.l	RPort(a5),d5
		move.l	d5,a1
		moveq	#0,d0
		jsr	SetAPen(a6)
		move.l	d5,a1
		moveq	#20,d0
		move.w	#136,d1
		move.w	#614,d2
		move.w	#172,d3
		jsr	RectFill(a6)
		move.l	d5,a1
		moveq	#1,d0
		jsr	SetAPen(a6)
		move.w	#Msg3Y,CurrMsgY(a5)
		rts

FlushFirstBufs	move.l	FirstDirBufs(a5),a0	; Free all but the first one...
		move.l	a0,a1
		tst.l	(a0)
		beq.s	1$
		move.l	(a0),a0
		clr.l	(a1)
		bsr.s	FreeBufs
1$		move.l	FirstFileBufs(a5),a0
		move.l	a0,a1
		tst.l	(a0)
		beq.s	2$
		move.l	(a0),a0
		clr.l	(a1)
		bsr.s	FreeBufs
2$		rts
FlushDirBufs	move.l	DirBufs(a5),a0
		move.l	a0,a1
		tst.l	(a0)
		beq.s	1$
		move.l	(a0),a0
		clr.l	(a1)
		bsr.s	FreeBufs
1$		move.l	FileBufs(a5),a0
		move.l	a0,a1
		tst.l	(a0)
		beq.s	2$
		move.l	(a0),a0
		clr.l	(a1)
		bsr.s	FreeBufs
2$		rts

FreeBufs	move.l	$4,a6
1$		move.l	(a0),d3
		move.l	a0,a1
		moveq	#8,d0
		lsl.l	#8,d0
		jsr	FreeMem(a6)
		move.l	d3,a0
		tst.l	d3
		bne.s	1$
		rts

**** SmallFirst (BubbleSort) ****
NumTab		set	LONG_4
NumNums		set	LONG_5
Swapper		set	LONG_6

SmallestFirst	clr.l	Swapper(a5)
		move.l	NumTab(a5),a2
		move.l	NumNums(a5),d7
		subq.l	#2,d7
1$		move.l	(a2),d0
		move.l	4(a2),d1
		cmp.l	d0,d1
		bcc.s	2$		; NoSwap
		move.l	d1,(a2)
		move.l	d0,4(a2)
		addq.l	#1,Swapper(a5)
2$		addq.l	#4,a2
		dbf	d7,1$
		tst.l	Swapper(a5)
		bne.s	SmallestFirst
		rts

DiskBusyOn	move.b	DriveID0(a5),DriveID+2(a5)
		moveq	#TRUE,d2
		bsr.s	Disk_Busy
		tst.b	WhichTD(a5)
		beq.s	1$
		move.b	DriveID1(a5),DriveID+2(a5)
		bsr.s	Disk_Busy
1$		rts
DiskBusyOff	move.b	DriveID0(a5),DriveID+2(a5)
		moveq	#FALSE,d2
		bsr.s	Disk_Busy
		tst.b	WhichTD(a5)
		beq.s	Busy_off
DiskBusyOff1	move.b	DriveID1(a5),DriveID+2(a5)
		moveq	#FALSE,d2
		bsr.s	Disk_Busy
Busy_off	move.b	#'x',DriveID+2(a5)
		rts

Disk_Busy	move.l	$4,a6
		sub.l	a1,a1
		jsr	FindTask(a6)
		move.l	d0,d3

		move.l	UseOnlyNowBuf(a5),d4
		move.l	d4,a0
		lea	sp_Pkt(a0),a1
		lea	sp_Msg(a0),a2
		move.l	a1,LN_NAME(a2)
		move.l	a2,dp_Link(a1)

		move.l	d3,a0
		lea	pr_MsgPort(a0),a0
		move.l	a0,dp_Port(a1)
		move.l	#ACTION_INHIBIT,dp_Type(a1)
		move.l	d2,dp_Arg1(a1)

		move.l	DosBase(a5),a6
		lea	DriveID(a5),a2
		move.l	a2,d1
		jsr	DeviceProc(a6)
		move.l	d0,a0

		move.l	$4,a6
		move.l	d4,a1
		jsr	PutMsg(a6)

		move.l	d3,a2
		lea	pr_MsgPort(a2),a0
		jsr	WaitPort(a6)
		lea	pr_MsgPort(a2),a0
		jsr	GetMsg(a6)
		rts

CleanUp		move.l	MyWindow(a5),d0
		beq.s	1$
		move.l	d0,IDCMPWin(a5)
		bsr	GetOldMsgs
		move.l	IBase(a5),a6
		move.l	MyWindow(a5),d2
		move.l	d2,a0
		jsr	ClearMenuStrip(a6)
		move.l	d2,a0
		jsr	ClearPointer(a6)
		move.l	d2,a0
		jsr	CloseWindow(a6)

1$		bsr	SmashMenus
		bsr	SmashGadgets
		bsr	SmashBorders

		move.l	Font(a5),d0
		beq.s	2$
		move.l	GfxBase(a5),a6
		move.l	d0,a1
		jsr	CloseFont(a6)

2$		move.l	$4,a6
		move.l	MathBase(a5),d0
		beq.s	3$
		move.l	d0,a1
		jsr	CloseLibrary(a6)
3$		move.l	IBase(a5),d0
		beq.s	4$
		move.l	d0,a1
		jsr	CloseLibrary(a6)
4$		move.l	GfxBase(a5),d0
		beq.s	5$
		move.l	d0,a1
		jsr	CloseLibrary(a6)
5$		move.l	DosBase(a5),d0
		beq.s	6$
		move.l	d0,a1
		jsr	CloseLibrary(a6)

6$		bsr	FlushDirBufs
		bsr	FlushFirstBufs

		move.l	GfxMem(a5),d2
		beq.s	7$
		move.l	#gm_SIZEOF,d0
		move.l	d2,a1
		jsr	FreeMem(a6)

7$		move.l	#dm_SIZEOF,d0
		move.l	a5,a1
		jsr	FreeMem(a6)
CompleteFailure	moveq	#0,d0
		rts

		_BuildMenus
		_BuildGadgets
		_BuildBorders
		_MenuData
		_GadgetData
		_BorderData

		_DataStuff

		ifd	A68k
		section	Gfx,DATA,CHIP
		endc
		ifnd	A68k
		section	Gfx,DATA_C
		endc

MpLLogo		_MpLLogo_
		end

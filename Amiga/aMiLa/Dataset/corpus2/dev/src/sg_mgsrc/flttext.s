;	==================================================================
;	NAME: FltText			VERSION: 2.01
;	AUTHOR:	Richard Tew  aka  Soltan Gris
;	NOTE: The conditions of distrution are:-
;		a) You may not redistribute this archive in any other form,
;		    but keep in mind you may use the contents in your own
;		    productions, if and only if you credit me .. in plain
;		    sight :)
;		b) You may not use/read any further this archive, unless
;		    you agree to the terms of uploadware :), that is:
;			- If you use the contents of this archive,
;			   you must upload any sources, at least one of
;			   your own to Aminet, or if you have no ftp access
;			   to a local BBS.
;	IMPORTANT: Condition b) overrides a) if this makes sense..
;	------------------------------------------------------------------
;	$VER: FltText V2.01 (08/11/94)
;	------------------------------------------------------------------
;				    Includes
;	------------------------------------------------------------------

	incdir	"Include2.0:"
	include	"hardware/customregisters.i"
	include	"intuition/intuition.i"
	include	"exec/exec_lib.i"
	include	"exec/memory.i"
	include	"exec/interrupts.i"
	include	"exec/nodes.i"
	include	"dos/dos_lib.i"
	include	"dos/dos.i"
	include	"intuition/intuition_lib.i"
	include	"graphics/gfxbase.i"
	
;	------------------------------------------------------------------
;				     Equates
;	------------------------------------------------------------------

wk_QuitFlag		equ	0
wk_Buffer		equ	wk_QuitFlag+4

wk_Bitplane1		equ	wk_Buffer+4
wk_Bitplane2		equ	wk_Bitplane1+4
wk_Bitplane3		equ	wk_Bitplane2+4
wk_Bitplane4		equ	wk_Bitplane3+4
wk_DoubleBuffer		equ	wk_Bitplane4+4

wk_DosBase		equ	wk_DoubleBuffer+4
wk_IntuiBase		equ	wk_DosBase+4

wk_DMAConSave		equ	wk_IntuiBase+4
wk_IntenaSave		equ	wk_DMAConSave+2

wk_CursXCoord		equ	wk_IntenaSave+2
wk_CursYCoord		equ	wk_CursXCoord+2

wk_OldJoy0Dat		equ	wk_CursYCoord+2
wk_KeyBuffer		equ	wk_OldJoy0Dat+2
wk_SpriteXCoord		equ	wk_KeyBuffer+2
wk_SpriteYCoord		equ	wk_SpriteXCoord+2
wk_OldJoy1Dat		equ	wk_SpriteYCoord+2

wk_CharBuffer		equ	wk_OldJoy1Dat+2

wk_BlankSprite		equ	wk_CharBuffer+4

wk_IrqStruct		equ	wk_BlankSprite+80

wk_PrintCounter		equ	wk_IrqStruct+30

wk_FileNamePtr		equ	wk_PrintCounter+2
wk_LockHandle		equ	wk_FileNamePtr+4
wk_FileHandle		equ	wk_LockHandle+4

wk_FileSize		equ	wk_FileHandle+4
wk_FileBufferPtr	equ	wk_FileSize+4
wk_OldFileSize		equ	wk_FileBufferPtr+4
wk_OldFileBufferPtr	equ	wk_OldFileSize+4

wk_FileInfoBlock	equ	wk_OldFileBufferPtr+4
wk_OldAutoRequest	equ	wk_FileInfoBlock+fib_SIZEOF+4

wk_IndexSize		equ	wk_OldAutoRequest+4
wk_IndexBufferPtr	equ	wk_IndexSize+4
wk_PageNameBuffer	equ	wk_IndexBufferPtr+4
wk_PageSize		equ	wk_PageNameBuffer+50
wk_PageBufferPtr	equ	wk_PageSize+4
wk_DecrunchedFileSize	equ	wk_PageBufferPtr+4
wk_DecrunchedFilePtr	equ	wk_DecrunchedFileSize+4

wk_CurrentNumber	equ	wk_DecrunchedFilePtr+4
wk_CurrentLineNum	equ	wk_CurrentNumber+2
wk_OwnerFlag		equ	wk_CurrentLineNum+4
wk_PageTablePtr		equ	wk_OwnerFlag+4
wk_PageTableSize	equ	wk_PageTablePtr+4
wk_PageNumLines		equ	wk_PageTableSize+4
wk_PageOffsetPtr	equ	wk_PageNumLines+4

wk_SpecOffset1Ptr	equ	wk_PageOffsetPtr+4
wk_SpecOffset2Ptr	equ	wk_SpecOffset1Ptr+4
wk_SpecNumLines		equ	wk_SpecOffset2Ptr+4
wk_SpecLineNum		equ	wk_SpecNumLines+4
wk_SpecArticleFlag	equ	wk_SpecLineNum+4

Workspace_SizeOf	equ	wk_SpecArticleFlag+4

;	------------------------------------------------------------------
;				    Constants
;	------------------------------------------------------------------

;	Code:
;	a6=ExecBase
;	a5=Custom
;	a4=Workspace

NumberOfPlanes	equ	4
ScreenWidth	equ	640
ScreenHeight	equ	256
BytesPerLine	equ	ScreenWidth/8

LogoWidth	equ	224
LogoHeight	equ	32
LogoDepth	equ	4
LogoBWidth	equ	LogoWidth/8

CursorYMinimum	equ	6
CursorYMaximum	equ	28

OneSecond	equ	TICKS_PER_SECOND

TAB		equ	9

ON		equ	1
OFF		equ	0
OWNER		equ	OFF

;	==================================================================
;				Start of the Code
;	------------------------------------------------------------------

	SECTION	DMClone,CODE
	
	move.l	4.w,a6
	jsr	_LVOForbid(a6)

	bsr	Setup
	tst.l	d0
	bne	SetupError

;	------------------------------------------------------------------

	lea	EntropyTitleCTxt(pc),a0
	bsr	PrintString

	cmp.b	#ON,wk_OwnerFlag(a4)
	bne.s	SkipMouseCrap

	lea	ProgramDataCTxt(pc),a0
	bsr	PrintString
	bsr	PrintCoords

SkipMouseCrap

;	------------------------------------------------------------------

	bsr	OpenDos
	tst.l	d0
	bne	DosError

	bsr	OpenIntui
	tst.l	d0
	bne	IntuiError

;	------------------------------------------------------------------

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	su_SkipReadText1

	lea	ReadingFile1Txt(pc),a0
	bsr	PrintText

su_SkipReadText1

	lea	IndexName(pc),a0

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	su_SkipReadText2

	move.l	a0,-(sp)
	bsr	PrintText
	lea	ReadingFile2Txt(pc),a0
	bsr	PrintText
	move.l	(sp)+,a0

su_SkipReadText2

	move.l	a0,d0
	bsr	ReadFile
	tst.l	d0
	bne	Error
	move.l	d1,wk_IndexBufferPtr(a4)
	move.l	d2,wk_IndexSize(a4)

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	su_SkipReadyText

	lea	ReadyTxt(pc),a0
	bsr	PrintText
su_SkipReadyText

	moveq	#0,d0
	move.l	d0,wk_FileSize(a4)	; Clear so not freed twice
	move.l	d0,wk_FileBufferPtr(a4)	;  " "  "   "   " "   "  "

	bsr	DecrunchIndex
	tst.l	d0
	bne.s	ni_Continue

	move.l	wk_IndexBufferPtr(a4),a0
	cmp.l	#'INDX',(a0)
	bne	NotIndexFile

	lea	TitleName(pc),a0
	lea	IndexTitle(pc),a1
	bsr	ReadPage

;	------------------------------------------------------------------

	lea	TitleText(pc),a0
	bsr	PrintString

;	------------------------------------------------------------------

MainLoop:
	bsr	CheckKeys
	bsr	CheckSpriteSelection

	tst.b	wk_QuitFlag(a4)
	beq.s	MainLoop

;	-----------------------------------------------------------------


	tst.l	wk_PageSize(a4)
	beq.s	Error
	move.l	wk_PageSize(a4),d0
	move.l	wk_PageBufferPtr(a4),a1
	bsr	FreeMem

ni_Continue
	tst.l	wk_IndexSize(a4)
	beq.s	Error
	move.l	wk_IndexSize(a4),d0
	move.l	wk_IndexBufferPtr(a4),a1
	bsr	FreeMem

;	-----------------------------------------------------------------
	
Error
	bsr	CloseIntui
IntuiError
	bsr	CloseDos
DosContinue
	bsr	CloseDown

Exit	jsr	_LVOPermit(a6)
	moveq	#0,d0
	rts

;	=================================================================
;	FUNCTION:	Setup
;	USAGE:		To set up the general set up stuff i.e. interrup-
;			ts, copperlists.....
;	INPUTS:		None
;	OUTPUTS:	a4	=	Workspace address
;			a5	=	Custom Hardware
;	------------------------------------------------------------------

Setup	lea	_custom,a5			; Store Custom address

	move.l	#Workspace_SizeOf,d0
	move.l	#(MEMF_CLEAR!MEMF_PUBLIC),d1
	jsr	_LVOAllocMem(a6)
	move.l	d0,a4				; Store Workspace address
	lea	MemAddress(pc),a0
	move.l	d0,(a0)
	beq	WorkMemAllocError

;	------------------------------------------------------------------
;	Save all the REALLY IMPORTANT variables for later restoral
;	so the system can be left as it was on exit...

	move.w	dmaconr(a5),wk_DMAConSave(a4)
	move.w	intenar(a5),wk_IntenaSave(a4)

;	He he .. get initial joy and mouse datas.

	move.w	joy0dat(a5),wk_OldJoy0Dat(a4)
	move.w	joy1dat(a5),wk_OldJoy1Dat(a4)

;	------------------------------------------------------------------
;	Initialize all the important variables:

	move.w	#000,wk_SpriteXCoord(a4)		; Mouse coordinates
	move.w	#000,wk_SpriteYCoord(a4)		;   "      "   "
	clr.w	wk_CursXCoord(a4)			; Cursor coordinates
	move.w	#CursorYMinimum,wk_CursYCoord(a4)	;   "      "   "
	move.w	#'00',wk_CurrentNumber(a4)		; Initial page number
	move.b	#OWNER,wk_OwnerFlag(a4)			; Owner status
	clr.w	wk_PrintCounter(a4)

;	------------------------------------------------------------------
;	Allocate the double buffer for the smooth switches..
;	Chip for the custom hardwares use...

	move.l	#((ScreenWidth*ScreenHeight)/8),d0
	move.l	#(MEMF_CLEAR!MEMF_CHIP),d1
	jsr	_LVOAllocMem(a6)

	move.l	d0,wk_DoubleBuffer(a4)
	beq	DblBufferAllocError

;	------------------------------------------------------------------
;	Allocate the display memory for the NumberOfPlanes bitplanes
;	Chip memory used for the custom hardware...
	
	move.l	#NumberOfPlanes*((ScreenWidth*ScreenHeight)/8),d0
	move.l	#(MEMF_CLEAR!MEMF_CHIP),d1
	jsr	_LVOAllocMem(a6)

	move.l	d0,wk_Bitplane1(a4)
	beq	PlaneMem1AllocError
	lea	CprPln1,a0
	bsr	InstallAddrToCopper

	add.l	#((ScreenWidth*ScreenHeight)/8),d0
	move.l	d0,wk_Bitplane2(a4)
	lea	CprPln2,a0
	bsr	InstallAddrToCopper

	add.l	#((ScreenWidth*ScreenHeight)/8),d0
	move.l	d0,wk_Bitplane3(a4)
	lea	CprPln3,a0
	bsr	InstallAddrToCopper

	add.l	#((ScreenWidth*ScreenHeight)/8),d0
	move.l	d0,wk_Bitplane4(a4)
	lea	CprPln4,a0
	bsr	InstallAddrToCopper

;	------------------------------------------------------------------

	lea	CprSpr1,a0
	lea	wk_BlankSprite(a4),a1	; Default pointer is none..
	move.l	a1,d0

	cmp.b	#OFF,wk_OwnerFlag(a4)	; If the owner flag is set
	beq.s	su_SpriteOff

	move.l	#SpriteData,d0		; turn the sprites on

su_SpriteOff
	bsr	InstallAddrToCopper	; Set sprite pointer

;	------------------------------------------------------------------
;	Clear all the unused sprites.

	lea	CprSpr2,a0
	lea	wk_BlankSprite(a4),a1
	move.l	a1,d0
	bsr	InstallAddrToCopper
	lea	CprSpr3,a0
	lea	wk_BlankSprite(a4),a1
	move.l	a1,d0
	bsr	InstallAddrToCopper
	lea	CprSpr4,a0
	lea	wk_BlankSprite(a4),a1
	move.l	a1,d0
	bsr	InstallAddrToCopper
	lea	CprSpr5,a0
	lea	wk_BlankSprite(a4),a1
	move.l	a1,d0
	bsr	InstallAddrToCopper
	lea	CprSpr6,a0
	lea	wk_BlankSprite(a4),a1
	move.l	a1,d0
	bsr	InstallAddrToCopper
	lea	CprSpr7,a0
	lea	wk_BlankSprite(a4),a1
	move.l	a1,d0
	bsr	InstallAddrToCopper
	lea	CprSpr8,a0
	lea	wk_BlankSprite(a4),a1
	move.l	a1,d0
	bsr	InstallAddrToCopper

;	------------------------------------------------------------------
;	Draw in logo!!!

	lea	EntropyLogo,a0			; Aaargh, no PC relativity
	move.l	wk_Bitplane1(a4),a1
	lea	((BytesPerLine-LogoBWidth)/2)(a1),a1
	move.l	a1,a2

	moveq	#LogoDepth-1,d5
CopyLogo
	moveq	#LogoHeight-1,d7		;Height
	moveq	#LogoBWidth-1,d6		;Width
CopyAPlane
	move.b	(a0)+,(a1)+
	dbra	d6,CopyAPlane

	moveq	#LogoBWidth-1,d6		;Set Next Line Width
	add.w	#BytesPerLine-LogoBWidth,a1	;Logo NL Strt Amount
	dbra	d7,CopyAPlane

	lea	(BytesPerLine*ScreenHeight)(a2),a2
	move.l	a2,a1

	dbra	d5,CopyLogo

;	------------------------------------------------------------------
;	Install our copperlist.

	lea	CopperList,a0
	move.l	a0,cop1lch(a5)
	clr.w	copjmp1(a5)

	move.w	#0,spr0ctl(a5)
	move.w	#0,spr1ctl(a5)
	move.w	#0,spr2ctl(a5)
	move.w	#0,spr3ctl(a5)
	move.w	#0,spr4ctl(a5)
	move.w	#0,spr5ctl(a5)
	move.w	#0,spr6ctl(a5)
	move.w	#0,spr7ctl(a5)

;	Install our interrupt.

	bsr	InstallInterrupt

;	Initialize DMACon.

	move.w	#%1000001111100000,dmacon(a5)
	moveq	#0,d0
	rts

InstallAddrToCopper
	move.w	d0,6(a0)	; Install lo-word
	swap	d0
	move.w	d0,2(a0)	; Install hi-word
	swap	d0
	rts

DblBufferAllocError
	moveq	#4,d0		; No memory for double-buffer
	rts

PlaneMem1AllocError
	moveq	#1,d0		; No memory for display
	rts

WorkMemAllocError
	moveq	#3,d0		; No memory for workspace
	rts
	
SetupError
	cmp.l	#1,d0		; Handle errors and exiting
	beq.s	PlaneError
	cmp.l	#4,d0
	beq.s	DblBufferError
	bra	Exit

PlaneError
	bsr	Plane2Error
	bra	Exit

DblBufferError
	bsr	FreeWorkMem
	bra	Exit	

;	======================================================================
;	Open intuition.library for use in handling Autorequest.

OpenIntui
	lea	IntuiName(pc),a1
	jsr	_LVOOldOpenLibrary(a6)
	move.l	d0,wk_IntuiBase(a4)
	beq.s	oi_OpenError

	move.l	d0,a1
	move.l	_LVOAutoRequest+2(a1),wk_OldAutoRequest(a4)
	lea	AutoRequest(pc),a0
	move.l	a0,_LVOAutoRequest+2(a1)

	moveq	#0,d0
	rts

oi_OpenError
	moveq	#-1,d0		; Fatal error, no intuition library!!!!!!
	rts

;	======================================================================

AutoRequest:
	move.l	a3,-(sp)
	move.l	a2,-(sp)
	move.l	a1,-(sp)
	move.l	4.w,a6
	lea	$dff000,a5		; Set our values
	move.l	MemAddress(pc),a4
	
	jsr	_LVOPermit(a6)		; Restore multitasking
	bsr	RemoveInterrupt		; Restore old interrupt

	bsr	ClearText
	lea	AutoRequestTxt(pc),a0
	bsr	PrintText

	move.l	(sp)+,a0
ar_PrintErrorString
	move.l	a0,-(sp)
	move.l	it_IText(a0),a0		; Get the stupid text
	bsr	PrintText		; We all know what its gonna be...
	addq.w	#1,wk_CursXCoord(a4)	; Naughty, should only be changed
	move.l	(sp)+,a0		; by a print routine.....
	tst.l	it_NextText(a0)
	beq.s	ar_NoMoreText
	move.l	it_NextText(a0),a0
	bra.s	ar_PrintErrorString

ar_NoMoreText
	lea	LeftButtonTxt(pc),a0
	bsr	PrintText
	move.l	(sp)+,a0
ar_PrintLeftOptions
	move.l	a0,-(sp)
	move.l	it_IText(a0),a0		; Get the stupid text
	bsr	PrintText		; We all know what its gonna be...
	addq.w	#1,wk_CursXCoord(a4)	; Naughty, should only be changed
	move.l	(sp)+,a0		; by a print routine.....
	tst.l	it_NextText(a0)
	beq.s	ar_NoMoreLeftOptions
	move.l	it_NextText(a0),a0
	bra.s	ar_PrintLeftOptions

ar_NoMoreLeftOptions
	lea	RightButtonTxt(pc),a0
	bsr	PrintText
	move.l	(sp)+,a0
ar_PrintRightOptions
	move.l	a0,-(sp)
	move.l	it_IText(a0),a0		; Get the stupid text
	bsr	PrintText		; We all know what its gonna be...
	addq.w	#1,wk_CursXCoord(a4)	; Naughty, should only be changed
	move.l	(sp)+,a0		; by a print routine.....
	tst.l	it_NextText(a0)
	beq.s	ar_NoMoreRightOptions
	move.l	it_NextText(a0),a0
	bra.s	ar_PrintRightOptions

ar_NoMoreRightOptions
	lea	RequesterChoiceTxt(pc),a0
	bsr	PrintText
ar_WaitMouseButton
	btst	#6,ciaapra
	beq.s	ar_Retry
	btst	#10,potinp(a5)
	bne.s	ar_WaitMouseButton
	moveq	#12-1,d0
ar_Cancel
	btst	#10,potinp(a5)
	beq.s	ar_Cancel
	dbra	d0,ar_Cancel
	bsr	InstallInterrupt
	jsr	_LVOForbid(a6)
	moveq	#0,d0
	rts

ar_Retry
	moveq	#12-1,d0
ar_WaitNoLMouse
	btst	#6,ciaapra
	beq.s	ar_WaitNoLMouse
	dbra	d0,ar_WaitNoLMouse
	bsr	InstallInterrupt
	jsr	_LVOForbid(a6)
	moveq	#1,d0
	rts

NextLine
	clr.w	wk_CursXCoord(a4)
	addq.l	#1,wk_CursYCoord(a4)
	rts

;	======================================================================

OpenDos
	lea	DosLibName(pc),a1
	jsr	_LVOOldOpenLibrary(a6)
	move.l	d0,wk_DosBase(a4)
	beq.s	od_OpenError
	moveq	#0,d0
	rts

od_OpenError
	moveq	#-1,d0		; Fatal error, cannot open DOS!!!
	rts

DosError
	bsr	ClearText
	lea	DosErrorCTxt(pc),a0
	bsr	PrintString
	bsr	WaitMouse
	bra	DosContinue

;	======================================================================
;	FUNCTION: ReadFile
;	USE:	  To read a file into a allocated buffer
;	PARAMS:	  d0 - Address of filename
;	RESULT:	  d0 - Error status
;			 0= No errors
;			-1= Unable to locate file
;			-2= Unable to examine file
;			-3= Unable to allocate file buffer
;			-4= Unable to open the file
;		  d1 - Address of file buffer
;		  d2 - Length of file buffer

ReadFile
	move.l	d0,-(sp)

	jsr	_LVOPermit(a6)

	move.l	(sp)+,d0

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	rf_SkipLockText

	move.l	d0,-(sp)
	lea	LockTxt(pc),a0
	bsr	PrintText
	move.l	(sp)+,d0

rf_SkipLockText

	move.l	d0,wk_FileNamePtr(a4)
	move.l	d0,d1
	moveq	#ACCESS_READ,d2
	bsr	LockFile
	move.l	d0,wk_LockHandle(a4)
	beq	rf_FileLocationError

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	rf_SkipExamText

	move.l	d0,-(sp)
	lea	ExamineTxt(pc),a0
	bsr	PrintText
	move.l	(sp)+,d0

rf_SkipExamText

	move.l	d0,d1
	lea	wk_FileInfoBlock(a4),a0
	move.l	a0,d2
	bsr	ExamineFile
	tst.l	d0
	beq	rf_ExamineError

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	rf_SkipUnLockText

	lea	UnLockTxt(pc),a0
	bsr	PrintText

rf_SkipUnLockText

	move.l	wk_LockHandle(a4),d1
	bsr	UnLockFile

	lea	wk_FileInfoBlock(a4),a0
	move.l	122(a0),wk_FileSize(a4)
	addq.l	#8,wk_FileSize(a4)

	move.l	wk_FileSize(a4),d0
	move.l	#(MEMF_CLEAR!MEMF_PUBLIC),d1
	bsr	AllocMem
	move.l	d0,wk_FileBufferPtr(a4)
	beq	rf_NoFileMemoryError

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	rf_SkipOpenText

	move.l	d0,-(sp)
	lea	OpenTxt(pc),a0
	bsr	PrintText
	move.l	(sp)+,d0

rf_SkipOpenText

	move.l	wk_FileNamePtr(a4),d1
	move.l	#MODE_OLDFILE,d2
	bsr	OpenFile
	move.l	d0,wk_FileHandle(a4)
	beq	rf_FileOpenError

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	rf_SkipReadText

	move.l	d0,-(sp)
	lea	ReadTxt(pc),a0
	bsr	PrintText
	move.l	(sp)+,d0

rf_SkipReadText

	move.l	d0,d1
	move.l	wk_FileBufferPtr(a4),d2
	move.l	wk_FileSize(a4),d3
	bsr	ReadFileData

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	rf_SkipCloseText

	lea	CloseTxt(pc),a0
	bsr	PrintText

rf_SkipCloseText

	move.l	wk_FileHandle(a4),d1
	bsr	CloseFile

	move.l	wk_FileBufferPtr(a4),d1
	move.l	wk_FileSize(a4),d3
	move.l	d1,a0
	subq.l	#8,d3
	clr.b	0(a0,d3.l)
	clr.b	1(a0,d3.l)
	clr.b	2(a0,d3.l)
	clr.b	3(a0,d3.l)

	jsr	_LVOForbid(a6)

	move.l	wk_FileBufferPtr(a4),d1
	move.l	wk_FileSize(a4),d2
	moveq	#0,d0
	rts

rf_FileLocationError
	lea	FileLockErrTxt(pc),a0
	bsr	PrintText
	bsr	WaitMouse
	moveq	#-1,d0
	rts
	
rf_ExamineError
	lea	FileExamErrTxt(pc),a0
	bsr	PrintText
	move.l	wk_LockHandle(a4),d1
	bsr	UnLockFile
	bsr	WaitMouse
	moveq	#-2,d0
	rts

rf_NoFileMemoryError
	lea	NoFileMemErrTxt(pc),a0
	bsr	PrintText
	bsr	WaitMouse
	moveq	#-3,d0
	rts
	
rf_FileOpenError
	lea	FileOpenErrTxt(pc),a0
	bsr	PrintText
	move.l	wk_FileSize(a4),d0
	move.l	wk_FileBufferPtr(a4),a1
	bsr	FreeMem
	bsr	WaitMouse
	moveq	#-4,d0
	rts


;	======================================================================
;	FUNCTION: LockFile
;	USE:	  Get a lock on a file
;	PARAMS:	  d1 - Address of filename 
;		  d2 - Lock type
;	RESULT:	  d0 - Error status

LockFile:
	move.l	a6,-(sp)
	moveq	#0,d0
	move.l	wk_DosBase(a4),a6
	jsr	_LVOLock(a6)
	move.l	(sp)+,a6
	rts


;	======================================================================
;	FUNCTION: UnLockFile
;	USE:	  Remove a lock on a file
;	PARAMS:	  d1 - FileLock
;	RESULT:	  None

UnLockFile:
	move.l	a6,-(sp)
	move.l	wk_DosBase(a4),a6
	jsr	_LVOUnLock(a6)
	move.l	(sp)+,a6
	rts

;	======================================================================
;	FUNCTION: ExamineFile
;	USE:	  Find out the info on the file e.g size...
;	PARAMS:	  d1 - LockHandle
;		  d2 - File info block buffer address
;	RESULT:	  d0 - Error status

ExamineFile:
	move.l	a6,-(sp)
	moveq	#0,d0
	move.l	wk_DosBase(a4),a6
	jsr	_LVOExamine(a6)
	move.l	(sp)+,a6
	rts


;	======================================================================
;	FUNCTION: AllocMem
;	USE:	  Allocate a block of memory
;	PARAMS:	  d0 - Size in bytes
;		  d1 - Memory type
;	RESULT:	  d0 - Error status

AllocMem:
	jmp	_LVOAllocMem(a6)

;	======================================================================
;	FUNCTION: FreeMem
;	USE:	  Free a block of memory
;	PARAMS:	  d0 - Size in bytes
;		  a1 - Memory block address
;	RESULT:	  None

FreeMem:
	jmp	_LVOFreeMem(a6)


;	======================================================================
;	FUNCTION: OpenFile
;	USE:	  To get a handle on a file
;	PARAMS:	  d1 - Address of the filename
;		  d2 - Access mode
;	RESULT:	  d0 - FileHandle (or NULL if error)


OpenFile:
	move.l	a6,-(sp)
	move.l	wk_DosBase(a4),a6
	jsr	_LVOOpen(a6)
	move.l	(sp)+,a6
	rts


;	======================================================================
;	FUNCTION: ReadFileData
;	USE:	  To read a file into a buffer
;	PARAMS:	  d1 - FileHandle
;		  d2 - Address of buffer
;		  d3 - Length of file
;	RESULT:	  None

ReadFileData:
	move.l	a6,-(sp)
	move.l	wk_DosBase(a4),a6
	jsr	_LVORead(a6)
	move.l	(sp)+,a6
	rts


;	======================================================================
;	FUNCTION: CloseFile
;	USE:	  To remove a handle on a file
;	PARAMS:	  d1 - FileHandle
;	RESULT:	  None


CloseFile:
	move.l	a6,-(sp)
	move.l	wk_DosBase(a4),a6
	jsr	_LVOClose(a6)
	move.l	(sp)+,a6
	rts


;	======================================================================
;	FUNCTION: WaitTime
;	USE:	  To wait a specified amount of time
;	PARAMS:	  d1 - Number of ticks???
;	RESULT:	  None


WaitTime:
	move.l	a6,-(sp)
	move.l	wk_DosBase(a4),a6
	jsr	_LVODelay(a6)
	move.l	(sp)+,a6
	rts


;	======================================================================
;	FUNCTION: ReadPage
;	USE:	  To read in a specific page
;	PARAMS:	  a0 - Address of the file name
;		  a1 - Address of the page title
;	RESULT:	  d0 - Error status


ReadPage
	move.l	a1,-(sp) ; Page title	  (in this routine....	   )
	move.l	a0,-(sp) ; Save file name

	bsr	ClearText		; Clear the screen we dont

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	rp_SkipReadText

	lea	ReadingFile1Txt(pc),a0	; wanna wrap back to the top...
	bsr	PrintText

	move.l	(sp)+,a0	; Get filenames address
	move.l	a0,-(sp)	; Save again for posterity
	bsr	PrintText
	lea	ReadingFile2Txt(pc),a0
	bsr	PrintText

rp_SkipReadText
	move.l	(sp)+,d0	; Get filenames address

	move.l	wk_FileSize(a4),wk_OldFileSize(a4)
	move.l	wk_FileBufferPtr(a4),wk_OldFileBufferPtr(a4)

	bsr	ReadFile
	tst.l	d0
	bne.s	rp_Continue
	move.l	d1,wk_PageBufferPtr(a4)
	move.l	d2,wk_PageSize(a4)

	move.l	wk_OldFileSize(a4),d0
	tst.l	d0
	beq.s	rp_NoMemToFree

	move.l	wk_OldFileBufferPtr(a4),a1
	bsr	FreeMem

rp_NoMemToFree
	moveq	#0,d0
	move.l	d0,wk_FileSize(a4)	; Clear these so they arent
	move.l	d0,wk_FileBufferPtr(a4)	; freed more than once  ;(
	move.l	d0,wk_OldFileSize(a4)	; ;( = Sad face
	move.l	d0,wk_OldFileBufferPtr(a4) 

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	rp_SkipReadyText

	lea	ReadyTxt(pc),a0		; Notify user that disk functions
	bsr	PrintText		; are finished

rp_SkipReadyText

	lea	BlankTitle(pc),a0
	bsr	PrintString

	move.l	(sp)+,a0		; Get Title address
	moveq	#07,d1			; Print the page title
	moveq	#CursorYMaximum+2,d2	; same place...
	bsr	ps_PrintNextChar	; Jump into printstring

	bsr.s	DecrunchPage
	tst.l	d0
	bne.s	DecrunchError		; Not crunched ? No Mem

	bsr	CountLines		; Count the lines in the article
	bsr	FindLines
	
	bra	RefreshPage		; Print the new display

rp_Continue
	move.l	wk_OldFileSize(a4),wk_FileSize(a4)
	move.l	wk_OldFileBufferPtr(a4),wk_FileBufferPtr(a4)
	bra	RefreshPage

DecrunchError
	bra	ck_RefreshIndex

;	======================================================================

DecrunchPage
	move.l	wk_PageBufferPtr(a4),a0
	cmp.l	#'FLT0',(a0)
	bne	dp_NotCrunchedError

	move.l	4(a0),d0	; Crunched data length
	
	move.l	wk_PageBufferPtr(a4),a1
	addq.l	#8,a1
	add.l	d0,a1
	move.l	-4(a1),d6	; Decrunched data length
	move.l	a1,-(sp)

	; Alloc Dest mem
	move.l	d6,d0
	move.l	d6,wk_DecrunchedFileSize(a4)
	move.l	#(MEMF_CLEAR!MEMF_PUBLIC),d1
	bsr	AllocMem
	tst.l	d0
	beq.s	dp_AllocError
	move.l	d0,wk_DecrunchedFilePtr(a4)

	move.l	(sp)+,a0			; Source address
	move.l	wk_DecrunchedFilePtr(a4),a1	; Dest address
	bsr	DecrunchFile

	move.l	wk_PageSize(a4),d0
	move.l	wk_PageBufferPtr(a4),a1
	bsr	FreeMem

	move.l	wk_DecrunchedFilePtr(a4),wk_PageBufferPtr(a4) ; Save address
	move.l	wk_DecrunchedFilePtr(a4),wk_PageOffsetPtr(a4) ; Start offset
	move.l	wk_DecrunchedFileSize(a4),wk_PageSize(a4)     ; Save length
	clr.l	wk_CurrentLineNum(a4)
	moveq	#0,d0
	rts

dp_NotCrunchedError
	move.w	vhposr(a5),color00(a5)
	moveq	#-1,d0
	rts

dp_AllocError
	move.l	(sp)+,a0	; Unload off stack
	moveq	#-2,d0
	rts

;	======================================================================

DecrunchIndex
	move.l	wk_IndexBufferPtr(a4),a0
	cmp.l	#'FLT0',(a0)
	bne	di_NotCrunchedError

	move.l	4(a0),d0	; Crunched data length
	
	move.l	wk_IndexBufferPtr(a4),a1
	addq.l	#8,a1
	add.l	d0,a1
	move.l	-4(a1),d6	; Decrunched data length
	move.l	a1,-(sp)

	; Alloc Dest mem
	move.l	d6,d0
	move.l	d6,wk_DecrunchedFileSize(a4)
	move.l	#(MEMF_CLEAR!MEMF_PUBLIC),d1
	bsr	AllocMem
	tst.l	d0
	beq.s	di_AllocError
	move.l	d0,wk_DecrunchedFilePtr(a4)

	move.l	(sp)+,a0			; Source address
	move.l	wk_DecrunchedFilePtr(a4),a1	; Dest address
	bsr	DecrunchFile

	move.l	wk_PageSize(a4),d0
	move.l	wk_PageBufferPtr(a4),a1
	bsr	FreeMem

	move.l	wk_DecrunchedFilePtr(a4),wk_IndexBufferPtr(a4)	; Save address
	move.l	wk_DecrunchedFilePtr(a4),wk_PageOffsetPtr(a4)	; Start offset
	move.l	wk_DecrunchedFileSize(a4),wk_IndexSize(a4)	; Save length
	clr.l	wk_CurrentLineNum(a4)
	moveq	#0,d0
	rts

di_NotCrunchedError
	moveq	#-1,d0
	rts

di_AllocError
	move.l	(sp)+,a0	; Unload off stack
	moveq	#-2,d0
	rts

;	======================================================================
;	****	ROUTINE: DecrunchFile	  	  ****
;	****	AUTHOR:	 Unknown	  	  ****
;	****	PARAMS:	 A0 - Source file buffer  ****
;	****		 A1 - Dest file buffer	  ****


DecrunchFile
	move.l	-(a0),a2
	add.l	a1,a2
	move.l	-(a0),d5
	move.l	-(a0),d0
	eor.l	d0,d5
Decrunch01
	lsr.l	#1,d0
	bne.s	Decrunch02
	bsr	Decrunch16
Decrunch02
	bcs	Decrunch9
	moveq	#8,d1
	moveq	#1,d3
	lsr.l	#1,d0
	bne.s	Decrunch03
	bsr	Decrunch16
Decrunch03
	bcs	Decrunch11
	moveq	#3,d1
	clr.w	d4
Decrunch04
	bsr	Decrunch17
	move.w	d2,d3
	add.w	d4,d3
Decrunch05
	moveq	#7,d1
Decrunch06
	lsr.l	#1,d0
	bne.s	Decrunch07
	bsr	Decrunch16
Decrunch07
	roxl.l	#1,d2
	dbra	d1,Decrunch06

	move.b	d2,-(a2)
	dbra	d3,Decrunch05

	bra	Decrunch13

Decrunch08
	moveq	#8,d1
	moveq	#8,d4
	bra.s	Decrunch04

Decrunch9
	moveq	#2,d1
	bsr	Decrunch17
	cmp.b	#2,d2
	blt.s	Decrunch10
	cmp.b	#3,d2
	beq.s	Decrunch08
	moveq	#8,d1
	bsr	Decrunch17
	move.w	d2,d3
	move.w	#12,d1
	bra	Decrunch11

Decrunch10
	move.w	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3
Decrunch11
	bsr	Decrunch17
Decrunch12
	subq.w	#1,a2
	move.b	0(a2,d2.w),(a2)
;	move.w	a2,_custom+color0	; Flash
	dbra	d3,Decrunch12

Decrunch13
	cmp.l	a2,a1
	blt	Decrunch01
	tst.l	d5
	bne.s	Decrunch14
	rts

Decrunch14
	move.w	#$FFFF,d0
Decrunch15
	move.w	d0,_custom+color0
	subq.l	#1,d0
	bne.s	Decrunch15
	rts

Decrunch16
	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
	rts

Decrunch17
	subq.w	#1,d1
	clr.w	d2
Decrunch18
	lsr.l	#1,d0
	bne.s	Decrunch19
	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
Decrunch19
	roxl.l	#1,d2
	dbra	d1,Decrunch18

	rts

;	======================================================================
;	FUNCTION: CountLines
;	USE:	  To get the number of lines in the article..
;	PARAMS:	  None
;	RESULT:	  None

CountLines:
	move.l	wk_PageBufferPtr(a4),a0
	moveq	#0,d0		; Loop counter
	moveq	#0,d1		; Character buffer
	moveq	#1,d2		; Line counter

CountALine:
	moveq	#BytesPerLine-1,d0
cal_Loop:
	move.b	(a0),d1		; Start of current line
	cmp.b	#10,d1		; Is char == Newline/CR
	beq.s	cal_FoundEOL

	tst.b	d1		; Is char == NULL
	beq.s	cl_FoundEOF

	lea	1(a0),a0	; Increment address
	dbra	d0,cal_Loop	; Check next byte

	bra.s	call_FoundEOL

cal_FoundEOL:
	lea	1(a0),a0	; Increment address

call_FoundEOL:
	addq.l	#1,d2		; Increment Linecount
	bra.s	CountALine	; Get Next line.....

cl_FoundEOF:
	move.l	d2,wk_PageNumLines(a4)
	rts

;	======================================================================
;	FUNCTION: FindLines
;	USE:	  To get the offsets of all the lines in the article..
;	PARAMS:	  None
;	RESULT:	  None

FindLines:
	tst.l	wk_PageTableSize(a4)
	beq.s	fl_NoPreviousTable

	move.l	wk_PageTableSize(a4),d0
	move.l	wk_PageTablePtr(a4),a1
	jsr	_LVOFreeMem(a6)		; Free table of ptrs to newlines.

fl_NoPreviousTable:
	move.l	wk_PageNumLines(a4),d0
	lsl.l	#2,d0		; NumLines * 4
	add.l	#200,d0		; Xtra space..
	move.l	d0,wk_PageTableSize(a4)

	move.l	#(MEMF_CLEAR!MEMF_PUBLIC),d1
	bsr	AllocMem

	;	Assume there's enuff mem...

	move.l	d0,wk_PageTablePtr(a4)

	move.l	wk_PageBufferPtr(a4),a0
	move.l	d0,a1		; Page Table
	moveq	#0,d0		; Loop counter
	moveq	#0,d1		; Character buffer
	move.l	a0,(a1)
	addq.l	#4,a1		; Get start of first line
	
FindALine:
	moveq	#BytesPerLine-1,d0
fal_Loop:
	move.b	(a0),d1		; Start of current line
	cmp.b	#10,d1		; Is char == Newline/CR
	beq.s	fal_FoundEOL

	tst.b	d1		; Is char == NULL
	beq.s	fl_FoundEOF

	lea	1(a0),a0	; Increment address
	dbra	d0,fal_Loop	; Check next byte

	bra.s	fall_FoundEOL

fal_FoundEOL:
	lea	1(a0),a0	; Increment address

fall_FoundEOL:
	move.l	a0,(a1)		; Save address of the line.
	addq.l	#4,a1		; Next offset
	bra.s	FindALine	; Get Next line.....

fl_FoundEOF:
	rts

;	======================================================================
;	FUNCTION: CloseDown
;	USE:	  Restore copper, free allocated memory
;	PARAMS:	  None
;	RESULT:	  None


CloseDown
	bsr	RemoveInterrupt		; Kill our interrupt.

	move.w	wk_DMAConSave(a4),d0
	or.w	#%1000000000000000,d0	; Set 'Set' bit of register.
	move.w	d0,dmacon(a5)		; Restore DMA Control register.

	move.w	wk_IntenaSave(a4),d0
	or.w	#%1100000000000000,d0
	move.w	d0,intena(a5)		; Restore Interrrupt enable register.

	lea	GfxName(pc),a1
	jsr	_LVOOldOpenLibrary(a6)
	move.l	d0,a1			; Open graphics library.
	tst.l	d0
	beq	NoGfxLib

	move.l	gb_copinit(a1),cop1lch(a5)
	clr.w	copjmp1(a5)		; Restore old copperlist.

	jsr	_LVOCloseLibrary(a6)	; Close graphics library.

FreeLineTable
	tst.l	wk_PageTableSize(a4)
	beq.s	Plane2Error		; Check table is not free..

	move.l	wk_PageTableSize(a4),d0
	move.l	wk_PageTablePtr(a4),a1
	jsr	_LVOFreeMem(a6)		; Free table of ptrs to newlines.
	
Plane2Error
	move.l	#NumberOfPlanes*((ScreenWidth*ScreenHeight)/8),d0
	move.l	wk_Bitplane1(a4),a1
	jsr	_LVOFreeMem(a6)		; Free bitplanes/display memory.

	tst.l	wk_DoubleBuffer(a4)
	beq.s	FreeWorkMem		; Check table is not free..

	move.l	#((ScreenWidth*ScreenHeight)/8),d0
	move.l	wk_DoubleBuffer(a4),a1
	jsr	_LVOFreeMem(a6)		; Free Double Buffer.

FreeWorkMem
	move.l	#Workspace_SizeOf,d0
	move.l	a4,a1
	jmp	_LVOFreeMem(a6)	

CloseDos
	move.l	wk_DosBase(a4),a1
	jmp	_LVOCloseLibrary(a6)

CloseIntui
	move.l	wk_IntuiBase(a4),a1
	move.l	wk_OldAutoRequest(a4),_LVOAutoRequest+2(a1)
	jmp	_LVOCloseLibrary(a6)

NoGfxLib
	move.l	#$0E03,d0
ngl_Loop
	add.w	#$0100,d0	
	move.w	d0,color00(a5)
	bra.s	ngl_Loop

;	======================================================================
;	FUNCTION: FetchPage
;	USE:	  Fetches the wanted page
;	PARAMS:	  a0 - Address of buffer
;	RESULT:	  None


FetchPage:
	moveq	#0,d0
	move.l	wk_IndexBufferPtr(a4),a0	
	cmp.w	#'00',wk_CurrentNumber(a4)
	beq	ck_RefreshIndex

si_FindPageDataLine
	moveq	#0,d0
	move.w	wk_CurrentNumber(a4),d1
si_FindPageNumber
	move.b	(a0),d0
	addq.l	#1,a0
	cmp.b	#'#',d0			; Have we found a page?
	bne.s	si_ContNumSearch	; If not skip

	move.l	a0,-(sp)		; Routine to avoid odd addresses in A0
	move.b	(a0)+,d2		; Get first number
	rol.w	#8,d2			; Put in right place
	move.b	(a0)+,d2		; Put second number in right place
	move.l	(sp)+,a0		; Restore old A0

	cmp.w	d2,d1			; Is it CurrentNumber page?
	beq.s	si_FindPageName		; If so branch to next routine
si_ContNumSearch
	tst.b	d0			; Have we reached the end of the file
	beq	si_NoSuchPage
	bra.s	si_FindPageNumber	; Check next byte

si_FindPageName
	move.l	a0,-(sp)
	bsr	ClearText
	move.l	(sp)+,a0

si_FindNameLoop
	move.b	(a0),d0
	addq.l	#1,a0
	cmp.b	#'"',d0			; Is it the start of a filename?
	beq	si_FoundPageName
	bra.s	si_FindNameLoop

si_FoundPageName
	lea	wk_PageNameBuffer(a4),a1
si_FindEOP
	move.b	(a0),d0
	addq.l	#1,a0
	cmp.b	#TAB,d0		; Another stupid TAB???
	beq.s	si_FindEOP
	cmp.b	#'"',d0		; Is it the end of the name?
	beq	si_FoundEOPName
	tst.b	d0		; Have we reached the EOF
	beq.s	si_NoSuchPage
	move.b	d0,(a1)+	; Must be a valid value then??
	bra.s	si_FindEOP

si_FoundEOPName
	clr.b	(a1)+		; EOS = NULL, so PrintString can pick it up

	move.w	wk_CurrentNumber(a4),d0
	lea	TextNumberBuffer(pc),a0
	move.w	d0,(a0)

	lea	TextName(pc),a0
	lea	wk_PageNameBuffer(a4),a1
	bra	ReadPage

si_NoSuchPage
	move.l	#$FF,d0
np_FlashLoop
	move.w	#$0FFF,color00(a5)
	dbra	d0,np_FlashLoop
	rts

NotIndexFile
	bsr	ClearText
	lea	NotIndexFileErrCTxt(pc),a0
	bsr	PrintString
	bsr	WaitMouse
	bra	ni_Continue

;	======================================================================
****	   Start of the Interrupt Code	     ****


InstallInterrupt:
	lea	wk_IrqStruct(a4),a1
	move.b	#NT_INTERRUPT,8(a1)	; Node type
	move.b	#127,9(a1)		; Interrupt priority
	lea	FLTInterrupt(pc),a0	; Actual interrupt code address
	move.l	a0,18(a1)
	moveq	#5,d0			; Interrupt type = ??
	jsr	_LVOAddIntServer(a6)	; Start interrupt
	rts

RemoveInterrupt:
	lea	wk_IrqStruct(a4),a1
	moveq	#5,d0			; Interrupt type = ??
	jsr	_LVORemIntServer(a6)	; Kill interrupt
	rts

FLTInterrupt:
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	4.w,a6
	lea	$dff000,a5
	move.l	MemAddress(pc),a4

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	ir_SkipPrint
	addq.w	#1,wk_PrintCounter(a4)
	cmp.w	#10,wk_PrintCounter(a4)
	ble.s	ir_SkipPrint
	clr.w	wk_PrintCounter(a4)
	bsr	PrintCoords

ir_SkipPrint
	bsr	GetKey			; Collect keypresses
	bsr	PrintPageNumber		; Print page number...

	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	ir_SkipMouseStuff
	bsr	GetMouseCoords		; Read sprite movement
	bsr	CheckCoords		; Check screen boundaries
	bsr	MoveMouse		; Move mouse now

ir_SkipMouseStuff
	movem.l	(sp)+,d0-d7/a0-a6
	rts


;	*****			End of the Interrupt Code		 *****

;	======================================================================
;	FUNCTION: WaitMouse
;	USE:	  Waits for left mouse button
;	PARAMS:	  None
;	RESULT:	  None


WaitMouse
	btst	#6,ciaapra
	bne.s	WaitMouse
	rts

;	======================================================================
;	FUNCTION: WaitBlitter
;	USE:	  Waits for blitter to finish current operation
;	PARAMS:	  None
;	RESULT:	  None


WaitBlitter
	btst	#14,dmaconr(a5)		; For safeties sake
	btst	#14,dmaconr(a5)
	bne.s	WaitBlitter
	rts


;	======================================================================
;	FUNCTION: WaitKeyRelease
;	USE:	  Waits for the key held down to be released
;	PARAMS:	  d0 = Old key code
;	RESULT:	  None

WaitKeyRelease
	or.b	#%10000000,d0
wkr_WaitLoop
	move.w	wk_KeyBuffer(a4),d1
	and.w	#%00000000000000001111111111111111,d1
	cmp.b	d0,d1
	bne.s	wkr_WaitLoop

	rts


;	======================================================================
;	FUNCTION: RefreshPage
;	USE:	  Refreshs the current page
;	PARAMS:	  None
;	RESULT:	  None


RefreshPage
	move.l	wk_PageOffsetPtr(a4),a0
	bra	PrintText


;	======================================================================
;	FUNCTION: ClearText
;	USE:	  Clears the text bitplane
;	PARAMS:	  None
;	RESULT:	  None


OnePlaneOnly	equ	1

ClearText
	move.w	#0,wk_CursXCoord(a4)
	move.w	#CursorYMinimum,wk_CursYCoord(a4)

	moveq	#0,d0
	move.l	wk_Bitplane1(a4),a0
	lea	CursorYMinimum*8*BytesPerLine(a0),a0

	move.l	#((CursorYMaximum-CursorYMinimum+1)*8)*OnePlaneOnly*64+BytesPerLine/2,d3

ct_Clear1MoreLine

	bsr	WaitBlitter		; Wait till blitter has finished
ctl_WaitVPos
	move.l	vposr(a5),d1
	and.l	#$1FF00,d1
	cmp.l	#$13700,d1
	bne.s	ctl_WaitVPos

	move.l	a0,bltdpth(a5)		; Dest screen address.
	clr.w	bltdmod(a5)
	move.l	#$ffffffff,bltafwm(a5)
	move.l	#$01000000,bltcon0(a5)	; Only dest channel so nothing is
	move	d3,bltsize(a5)		; is copied, hence clearing....
	bra	WaitBlitter		; Wait till blitter has finished


;	======================================================================
;	FUNCTION: ClearDoubleBuffer
;	USE:	  Clears the double buffer bitplane
;	PARAMS:	  None
;	RESULT:	  None

ClearDoubleBuffer
	move.w	#0,wk_CursXCoord(a4)
	move.w	#CursorYMinimum,wk_CursYCoord(a4)

	moveq	#0,d0
	move.l	wk_DoubleBuffer(a4),a0
	lea	CursorYMinimum*ScreenWidth(a0),a0

	move.l	#((CursorYMaximum-CursorYMinimum+1)*8)*OnePlaneOnly*64+BytesPerLine/2,d3

cdb_Clear1MoreLine

	bsr	WaitBlitter		; Wait till blitter has finished
cdbl_WaitVPos
	move.l	vposr(a5),d1
	and.l	#$1FF00,d1
	cmp.l	#$13700,d1
	bne.s	cdbl_WaitVPos

	move.l	a0,bltdpth(a5)		; Dest screen address.
	clr.w	bltdmod(a5)
	move.l	#$ffffffff,bltafwm(a5)
	move.l	#$01000000,bltcon0(a5)	; Only dest channel so nothing is
	move	d3,bltsize(a5)		; is copied, hence clearing....
	bra	WaitBlitter		; Wait till blitter has finished


;	======================================================================
;	FUNCTION: ScrollText
;	USE:	  Scrolls the text bitplane
;	PARAMS:	  None
;	RESULT:	  None

First	equ	0
Next	equ	1

BlitScrollUp
	bsr	ClearDoubleBuffer

	move.l	#CursorYMinimum*ScreenWidth,d0
	move.l	wk_Bitplane1(a4),a0
	lea	(CursorYMinimum+Next)*ScreenWidth(a0),a0
	move.l	wk_DoubleBuffer(a4),a1
	lea	(CursorYMinimum+First)*ScreenWidth(a1),a1
	bsr	ScrollText

	clr.w	wk_CursXCoord(a4)	; Print the new line
	move.w	#CursorYMaximum,wk_CursYCoord(a4)
	move.l	wk_CurrentLineNum(a4),d0
	add.l	#CursorYMaximum-CursorYMinimum,d0
	lsl.l	#2,d0		; Multiply by 4
	move.l	wk_PageTablePtr(a4),a0
	move.l	0(a0,d0.l),a0
	bsr	PrintALine

	bra.s	ScrollMoreText

BlitScrollDown
	bsr	ClearDoubleBuffer

	move.l	#CursorYMinimum*ScreenWidth,d0
	move.l	wk_Bitplane1(a4),a0
	lea	(CursorYMinimum+First)*ScreenWidth(a0),a0
	move.l	wk_DoubleBuffer(a4),a1
	lea	(CursorYMinimum+Next)*ScreenWidth(a1),a1
	bsr.s	ScrollText

	clr.w	wk_CursXCoord(a4)	; Print the new line
	move.w	#CursorYMinimum,wk_CursYCoord(a4)
	move.l	wk_PageOffsetPtr(a4),a0
	bsr	PrintALine

ScrollMoreText
	move.l	#CursorYMinimum*ScreenWidth,d0
	move.l	wk_Bitplane1(a4),a1
	lea	(CursorYMinimum+First)*ScreenWidth(a1),a1
	move.l	wk_DoubleBuffer(a4),a0
	lea	(CursorYMinimum+First)*ScreenWidth(a0),a0

	move.l	#((CursorYMaximum-CursorYMinimum+1)*8)*OnePlaneOnly*64+BytesPerLine/2,d3
	bra.s	st_Do1MoreLine

ScrollText
	move.l	#((CursorYMaximum-CursorYMinimum)*8)*OnePlaneOnly*64+BytesPerLine/2,d3
st_Do1MoreLine
	bsr	WaitBlitter		; Wait till blitter has finished

	move.l	a0,bltapth(a5)		; Dest screen address.
	move.l	a1,bltdpth(a5)
	clr.w	bltamod(a5)
	clr.w	bltdmod(a5)
	move.l	#$ffffffff,bltafwm(a5)
	move.l	#$9F00000,bltcon0(a5)	; Activate A and D channels for
	move	d3,bltsize(a5)		; straight copy of data
	bra	WaitBlitter


;	======================================================================
;	FUNCTION: CheckCoords
;	USE:	  Ensure mouse stays within sight boundaries
;	PARAMS:	  None
;	RESULT:	  None.

		
CheckCoords
	move.w	wk_SpriteXCoord(a4),d0
	cmp.w	#0,d0
	bge.s	SpriteXIsHighEnough
	move.w	#0,wk_SpriteXCoord(a4)
SpriteXIsHighEnough
	cmp.w	#320,d0
	ble.s	SpriteXIsLowEnough
	move.w	#320,wk_SpriteXCoord(a4)
SpriteXIsLowEnough	
	move.w	wk_SpriteYCoord(a4),d0
	cmp.w	#0,d0
	bge.s	SpriteYIsHighEnough
	move.w	#0,wk_SpriteYCoord(a4)
SpriteYIsHighEnough
	cmp.w	#256,d0
	ble.s	SpriteYIsLowEnough
	move.w	#256,wk_SpriteYCoord(a4)
SpriteYIsLowEnough		
	rts


;	======================================================================
;	FUNCTION: GetMouseCoords
;	USE:	  To calculate mouse X and Y coords
;	PARAMS:	  None
;	RESULT:	  None


GetMouseCoords
	move.w	joy0dat(a5),d0
	move.w	wk_OldJoy0Dat(a4),d1
	move.w	d0,d2
	and.w	#%1111111100000000,d1
	and.w	#%1111111100000000,d2
	asr.w	#8,d1
	asr.w	#8,d2
	sub.w	d2,d1
	move.w	d1,d2
	bpl.s	LBC002232
	eor.w	#%1111111111111111,d2
LBC002232
	cmp.w	#128,d2
	bcs.s	LBC00223C
	move.w	#0,d1
LBC00223C
	sub.w	d1,wk_SpriteYCoord(a4)
	move.w	wk_OldJoy0Dat(a4),d1
	move.w	d0,d2
	and.w	#%0000000011111111,d1
	and.w	#%0000000011111111,d2
	sub.w	d2,d1
	move.w	d1,d2
	bpl.s	LBC002276
	eor.w	#%1111111111111111,d2
LBC002276
	cmp.w	#128,d2
	bcs.s	LBC002280
	move.w	#0,d1
LBC002280
	sub.w	d1,wk_SpriteXCoord(a4)
	move.w	d0,wk_OldJoy0Dat(a4)
	rts


;	======================================================================
;	FUNCTION: MoveMouse
;	USE:	  Move the actual sprite
;	PARAMS:	  None
;	RESULT:	  None


MoveMouse
	lea	SpriteData,a0
	move.b	#1,3(a0)
	move.w	wk_SpriteXCoord(a4),d0
	add.w	#128,d0
	btst	#0,d0
	bne.s	SprWidthIsEven
	and.b	#$FE,3(a0)
SprWidthIsEven
	asr.w	#1,d0
	move.b	d0,1(a0)
	move.w	wk_SpriteYCoord(a4),d0
	add.w	#44,d0
	btst	#8,d0
	beq.s	SprStrtIsGT200
	or.b	#%0100,3(a0)
SprStrtIsGT200
	move.b	d0,0(a0)
	add.w	#13,d0
	btst	#8,d0
	beq.s	SprStopIsGT200
	or.b	#0010,3(a0)
SprStopIsGT200
	move.b	d0,2(a0)
	rts
	

;	======================================================================
;	FUNCTION: CheckSpriteSelection
;	USE:	  To check coords for box selection
;	PARAMS:	  None
;	RESULT:	  None


CheckSpriteSelection
	btst	#06,ciaapra
	beq.s	LMouseClicked
	btst	#10,potinp(a5)
	beq.s	RMouseClicked
	rts

RMouseClicked
	bsr	RemoveSpecArticle
	move.b	#1,wk_QuitFlag(a4)
	rts	

LMouseClicked
	move.w	wk_SpriteXCoord(a4),d0
	move.w	wk_SpriteYCoord(a4),d1

	move.l	CurrentButtonTable(pc),a0
TestIfEnd
	cmp.l	#0,8(a0)
	beq.s	UnknownCoords
	move.w	0(a0),d2
	move.w	2(a0),d3
	move.w	4(a0),d4
	move.w	6(a0),d5
	cmp.w	d0,d2
	bgt.s	TryNextCoordSet
	cmp.w	d0,d4
	ble.s	TryNextCoordSet
	cmp.w	d1,d3
	bgt.s	TryNextCoordSet
	cmp.w	d1,d5
	ble.s	TryNextCoordSet
	move.l	8(a0),a0
	jmp	(a0)

TryNextCoordSet
	lea	12(a0),a0
	bra.s	TestIfEnd
UnknownCoords
	rts
	
Quit	move.b	#1,wk_QuitFlag(a4)
	rts


;	==================================================================
;	FUNCTION:	CheckKeys
;	USE:		To check for and handle keypresses
;	INPUTS:		None
;	OUTPUTS:	None
;	------------------------------------------------------------------

CheckKeys
	moveq	#0,d0
	move.w	wk_KeyBuffer(a4),d0	; Do we have a keycode waiting?
	beq.s	ck_NoKeyPressed

;	------------------------------------------------------------------

	cmp.b	#$66,d0
	beq.s	ck_IsLAmiga

;	------------------------------------------------------------------

	cmp.b	#$59,d0		; Is it F10
	beq	ck_RefreshIndex	; If so refresh index

;	------------------------------------------------------------------

	cmp.b	#$58,d0		; Is it F09
	beq.s	ck_RefreshPage	; If so refresh page

;	------------------------------------------------------------------

	cmp.b	#$57,d0		; Is it F08
	beq	ck_IsMeInfo	; If so print my info

;	------------------------------------------------------------------

	cmp.b	#$45,d0		; Is it Escape
	beq.s	ck_Quit		; If so quit

;	------------------------------------------------------------------

	cmp.b	#$5F,d0		; Help key code
	beq	ck_IsHelp

;	------------------------------------------------------------------

	cmp.b	#$4C,d0		; Cursor up
	beq	ck_ScrollUpLine

;	------------------------------------------------------------------

	cmp.b	#$4D,d0		; Cursor down
	beq	ck_ScrollDownLine

;	------------------------------------------------------------------

	cmp.b	#$4E,d0		; Cursor right
	beq	ck_NextPage

;	------------------------------------------------------------------

	cmp.b	#$4F,d0		; Cursor left
	beq	ck_PrevPage

;	------------------------------------------------------------------

	cmp.b	#$43,d0
	beq	ck_FetchPage

;	------------------------------------------------------------------

	cmp.b	#$44,d0
	beq	ck_FetchPage

;	------------------------------------------------------------------

	cmp.b	#$01,d0
	blt.s	ck_Cont

;	------------------------------------------------------------------

	cmp.b	#$0A,d0
	ble	ck_Number

;	------------------------------------------------------------------

ck_Cont
	cmp.b	#OFF,wk_OwnerFlag(a4)
	beq.s	ck_SkipCodePrint

	bsr	PrintKeyCode

ck_SkipCodePrint
	clr.w	wk_KeyBuffer(a4)
ck_NoKeyPressed
	rts


;	------------------------------------------------------------------

ck_Quit
	bsr	RemoveSpecArticle
	st.b	wk_QuitFlag(a4)
	bra.s	ck_Cont


;	------------------------------------------------------------------

ck_IsLAmiga
	bsr	SetupSpecArticle
	move.w	#$0FFF,color00(a5)
	bra.s	ck_Cont


;	------------------------------------------------------------------

ck_RefreshPage
	bsr	WaitKeyRelease
	bra	RemoveSpecArticle


;	------------------------------------------------------------------

ck_RefreshIndex
	bsr	WaitKeyRelease
	bsr	RemoveSpecArticle
	lea	TitleName(pc),a0
	lea	IndexTitle(pc),a1
	bra	ReadPage


;	------------------------------------------------------------------

ck_IsHelp
	bsr	WaitKeyRelease

	lea	HelpTxt(pc),a0
	moveq	#Help__Article,d0
	bsr	SetupSpecArticle
	lea	HelpTxt(pc),a0
	bsr	PrintNewText
	bra.s	ck_Cont

;	------------------------------------------------------------------

ck_ScrollUpLine:
	bsr	WaitKeyRelease

	move.l	wk_CurrentLineNum(a4),d0
	tst.l	d0
	ble.s	cksu_AtTopOfScreen

	subq.l	#1,d0		; If not, go up...
	move.l	d0,wk_CurrentLineNum(a4)
	lsl	#2,d0		; Multiply by 4
	move.l	wk_PageTablePtr(a4),a0
	lea	0(a0,d0.l),a0
	move.l	(a0),wk_PageOffsetPtr(a4)

	bsr	BlitScrollDown	; Scroll the ^Text^ down
	
cksu_AtTopOfScreen
	
	rts


;	------------------------------------------------------------------

ck_ScrollDownLine:
	bsr	WaitKeyRelease

	move.l	wk_PageNumLines(a4),d0
	cmp.l	#CursorYMaximum-CursorYMinimum,d0
	ble.s	cksd_AtBottomOfScreen

	move.l	wk_CurrentLineNum(a4),d0
	move.l	wk_PageNumLines(a4),d1
	sub.l	#20,d1	
	cmp.l	d0,d1		; Are we at the end of the article?
	ble.s	cksd_AtBottomOfScreen

	move.l	wk_CurrentLineNum(a4),d0
	addq.l	#1,d0		; If not, go down...
	move.l	d0,wk_CurrentLineNum(a4)
	lsl.l	#2,d0		; Multiply by 4
	move.l	wk_PageTablePtr(a4),a0
	lea	0(a0,d0.l),a0
	move.l	(a0),wk_PageOffsetPtr(a4)

	bsr	BlitScrollUp	; Scroll the ^Text^ up
	
cksd_AtBottomOfScreen
	rts


;	------------------------------------------------------------------

ck_NextPage:
	bsr	WaitKeyRelease

;	-----
;	I will try and make this simpler with assignments to variables:
;	a := Number of lines in the article.
;	b := Current line number.
;	c := Number of lines to display at the end of the article.
;	d := Next page's line number.
;	e := Length of page less one line.
;	so (a-c) will be the maximum page line number.

	move.l	wk_CurrentLineNum(a4),d0		; b
	move.l	wk_PageNumLines(a4),d1			; a

;	Here we check that there is actually enough lines to scroll..
;	If there isn't we don't scroll.

	cmp.l	#CursorYMaximum-CursorYMinimum,d1	; Is (a<=plen)
	ble.s	cksd_AtBottomOfScreen

	moveq	#(CursorYMaximum-CursorYMinimum)-2,d2	; c
	moveq	#(CursorYMaximum-CursorYMinimum),d4	; e
	move.l	d0,d3					; a
	add.l	d4,d3					; d
	sub.l	d2,d1					; (a-c)

;	If b = (a-c) then no change/no update. This makes sure the page
;	is not updated if it doesn't need to be.

	cmp.l	d1,d0					; Is (b=(a-c))
	beq.s	cknp_AtBottomOfArticle

;	If d > (a-c) then b=(a-c), what this ensures is that the maximum
;	page displayed will always be at the wanted position (a-c) and
;	no more.

	cmp.l	d1,d3					; Is (d<=(a-c))
	ble.s	cknp_DownAPage
	
;	Take the maximum line as the current line and refresh to it.

	move.l	d1,wk_CurrentLineNum(a4)
	move.l	d1,d0
	bra.s	cknp_JumpToLine

;	Skip one whole page forward.

cknp_DownAPage
	move.l	wk_CurrentLineNum(a4),d0		; Get current line number
	add.l	#(CursorYMaximum-CursorYMinimum),d0	; Alter by set amount
	move.l	d0,wk_CurrentLineNum(a4)		; Replace old value

;	Skip d0 lines forward.

cknp_JumpToLine
	lsl.l	#2,d0					; Multiply by 4
	move.l	wk_PageTablePtr(a4),a0			; Get table of line addresses
	move.l	0(a0,d0.l),wk_PageOffsetPtr(a4)		; Get address of the new line

	bsr	RefreshPage				; Get the Next page
	
cknp_AtBottomOfArticle
	
	rts

;	------------------------------------------------------------------

ck_PrevPage:
	bsr	WaitKeyRelease

	move.l	wk_CurrentLineNum(a4),d0
	tst.l	d0		; Are we at the start of the article?
	ble.s	ckpp_AtTopOfArticle
	
	move.l	wk_CurrentLineNum(a4),d0
	sub.l	#CursorYMaximum-CursorYMinimum,d0
	tst.l	d0
	bgt.s	ckpp_BackWholePage

	moveq	#0,d0
	bra.s	ckpp_GotoStart

ckpp_BackWholePage
	move.l	wk_CurrentLineNum(a4),d0
	sub.l	#CursorYMaximum-CursorYMinimum,d0
ckpp_GotoStart
	move.l	d0,wk_CurrentLineNum(a4)
	lsl.l	#2,d0		; Multiply by 4
	move.l	wk_PageTablePtr(a4),a0
	move.l	0(a0,d0.l),wk_PageOffsetPtr(a4)

	bsr	RefreshPage	; Print the previous page
	
ckpp_AtTopOfArticle
	
	rts

;	------------------------------------------------------------------

ck_Number
	move.b	d0,-(sp)
	moveq	#0,d1
	moveq	#'0',d1		; Specify base zero
	cmp.b	#$0A,d0		; Is zero so don't adjust
	beq.s	ck_GotZero

	add.b	d0,d1		; Calculate ascii-code of character

ck_GotZero
	and.w	#$00FF,d1		; Ensure 2nd number's in right byte
	move.w	wk_CurrentNumber(a4),d0
	rol.w	#8,d0			; Shift 1st number to left byte
	and.w	#$FF00,d0		; Clear obselete number
	or.w	d0,d1			; Combine both bytes
	move.w	d1,wk_CurrentNumber(a4)	; and save... phew

	moveq	#0,d0
	moveq	#0,d1
	move.b	(sp)+,d0
	bsr	WaitKeyRelease

	bra	ck_Cont

;	------------------------------------------------------------------

ck_FetchPage
	bsr	WaitKeyRelease
	bsr	RemoveSpecArticle
	bsr	FetchPage
	bra	ck_Cont

;	------------------------------------------------------------------

ck_IsMeInfo
	bsr	WaitKeyRelease
	lea	SoltanGrisTxt(pc),a0
	moveq	#About_Article,d0
	bsr	SetupSpecArticle
	lea	SoltanGrisTxt(pc),a0
	bsr	PrintNewText
	bra	ck_Cont

;	==================================================================
;	+		   Special Article Equates:			 +
;	------------------------------------------------------------------

Help__Article	equ	1
About_Article	equ	2


;	==================================================================
;	FUNCTION:	SetupSpecArticle
;	USE:		Setup & display special article.
;	INPUTS:		a0 = Address of internal article
;			d0 = Number of the article
;	OUTPUTS:	None
;	------------------------------------------------------------------

SetupSpecArticle:
	tst.w	wk_SpecArticleFlag(a4)
	bne.s	ssa_ANewSpecialArticle

	move.w	d0,wk_SpecArticleFlag(a4)

	move.l	wk_CurrentLineNum(a4),wk_SpecLineNum(a4)
	move.l	wk_PageOffsetPtr(a4),wk_SpecOffset1Ptr(a4)
	move.l	wk_PageBufferPtr(a4),wk_SpecOffset2Ptr(a4)
	
ssa_ANewSpecialArticle
	move.l	a0,wk_PageOffsetPtr(a4)
	move.l	a0,wk_PageBufferPtr(a4)
	bsr	CountLines
	bsr	FindLines
	clr.l	wk_CurrentLineNum(a4)
	rts


;	==================================================================
;	FUNCTION:	RemoveSpecArticle
;	ABOUT:		Initialize display of old article.
;	INPUTS:		None
;	OUTPUTS:	None
;	------------------------------------------------------------------

RemoveSpecArticle:
	tst.w	wk_SpecArticleFlag(a4)
	beq.s	rsa_NoSpecialArticle

	clr.w	wk_SpecArticleFlag(a4)

	bsr	CountLines
	bsr	FindLines

	move.l	wk_SpecLineNum(a4),wk_CurrentLineNum(a4)
	move.l	wk_SpecOffset1Ptr(a4),wk_PageOffsetPtr(a4)
	move.l	wk_SpecOffset2Ptr(a4),wk_PageBufferPtr(a4)
rsa_NoSpecialArticle	
	bra	RefreshPage


;	==================================================================
;	FUNCTION: GetKey
;	USE:	  To collect keypresses
;	PARAMS:	  None
;	RESULT:	  None
;	------------------------------------------------------------------


GetKey
	moveq	#0,d0
	move.b	$bfec01,d0	; Get the key-byte
	beq.s	gk_NoKeyPressed

	ror.b	#1,d0		; Decode the raw keycode...
	not	d0

	move.w	d0,wk_KeyBuffer(a4)
	clr.b	$bfec01		; Got it, so clear old one..

gk_NoKeyPressed
	rts


;	==================================================================
;	FUNCTION: PrintCoords
;	USE:	  Updates general text on the screen
;	PARAMS:	  None
;	RESULT:	  None
;	------------------------------------------------------------------


PrintCoords
	move.l	#0,wk_CharBuffer(a4)	; Clear buffer to be used
	move.w	wk_SpriteXCoord(a4),d0	; Get actual binary X coord
	bsr	ConvHexToAsc		; Convert it
	bsr.s	PrintXCoord		; Print it

	move.l	#0,wk_CharBuffer(a4)	; Clear buffer for reuse
	move.w	wk_SpriteYCoord(a4),d0	; Get actual binary Y coord
	bsr	ConvHexToAsc		; Convert it
	bra.s	PrintYCoord		; Print it

PrintKeyCode
	move.l	#0,wk_CharBuffer(a4)	; Clear buffer for reuse
	move.w	wk_KeyBuffer(a4),d0	; Get actual binary Y coord
	bsr	ConvHexToAsc		; Convert it
	bsr	PrintKey		; Print it
	rts

;	------------------------------------------------------------------

PrintYCoord
	moveq	#0,d0
	move.b	wk_CharBuffer+2(a4),d0	; Get the second char of Y coord
	moveq	#21,d1			; X coord
	moveq	#CursorYMaximum,d2	; Y coord
	bsr	DrawCharacter		; Print it

	moveq	#0,d0
	move.b	wk_CharBuffer+3(a4),d0	; Get the third char of Y coord
	moveq	#22,d1			; X coord
	moveq	#CursorYMaximum,d2	; Y coord
	bra	DrawCharacter		; Print it

PrintXCoord
	moveq	#0,d0
	move.b	wk_CharBuffer+2(a4),d0	; Get second char of X coord
	moveq	#9,d1			; X coord
	moveq	#CursorYMaximum,d2	; Y coord
	bsr	DrawCharacter		; Print it

	moveq	#0,d0
	move.b	wk_CharBuffer+3(a4),d0	; Get third char of X coord
	moveq	#10,d1			; X coord
	moveq	#CursorYMaximum,d2	; Y coord
	bra	DrawCharacter		; Print it

;	------------------------------------------------------------------

PrintKey
	moveq	#0,d0
	move.b	wk_CharBuffer+2(a4),d0	; Get second char of KeyCode
	moveq	#34,d1			; X coord
	moveq	#CursorYMaximum,d2	; Y coord
	bsr	DrawCharacter		; Print it

	moveq	#0,d0
	move.b	wk_CharBuffer+3(a4),d0	; Get third char of KeyCode
	moveq	#35,d1			; X coord
	moveq	#CursorYMaximum,d2	; Y coord
	bra	DrawCharacter		; Print it

;	------------------------------------------------------------------

PrintPageNumber
	moveq	#0,d0
	move.w	wk_CurrentNumber(a4),d0	; Get the second char of Y coord
	ror.w	#8,d0
	and.w	#$00FF,d0
	moveq	#78,d1			; X coord
	moveq	#00,d2			; Y coord
	bsr	DrawCharacter		; Print it

	moveq	#0,d0
	move.w	wk_CurrentNumber(a4),d0	; Get the second char of Y coord
	and.w	#$00FF,d0
	moveq	#79,d1			; X coord
	moveq	#00,d2			; Y coord
	bra	DrawCharacter		; Print it


;	==================================================================
;	FUNCTION: ConvHexToAsc
;	USE:	  Converts a hex number to ascii
;	PARAMS:	  d0=Hex number
;	RESULT:	  Buffer=Ascii number
;	------------------------------------------------------------------

ConvHexToAsc
	lea	wk_CharBuffer(a4),a0
	ext.l	d0

	move	d0,d2
	lsr	#8,d2	
	lsr	#4,d2	

	bsr	pn_Nibble

	move.b	d2,0(a0)
	move	d0,d2
	lsr	#8,d2	

	bsr	pn_Nibble

	move.b	d2,1(a0)
	move	d0,d2
	lsr	#4,d2	

	bsr	pn_Nibble

	move.b	d2,2(a0)
	move	d0,d2

	bsr	pn_Nibble

	move.b	d2,3(a0)
	rts

pn_Nibble
	and	#%0000000000001111,d2
	add	#$30,d2
	cmp	#$3a,d2
	bcs	pn_ok

	add	#7,d2
pn_ok	rts


;	==================================================================
;	FUNCTION: PrintNewText
;	USE:	  Prints text as from new page
;	PARAMS:	  a0=address of string (null terminated)
;	RESULT:	  Character printed on screen.
;	------------------------------------------------------------------


PrintNewText:
	clr.w	wk_CursXCoord(a4)
	move.w	#CursorYMinimum,wk_CursYCoord(a4)


;	==================================================================
;	FUNCTION: PrintText
;	USE:	  Prints text at cursor X and Y coords.
;	PARAMS:	  a0=address of string (null terminated)
;	RESULT:	  Character printed on screen.
;	------------------------------------------------------------------


PrintText:
	move.l	a0,-(sp)
	bsr	ClearDoubleBuffer
	move.l	(sp)+,a0

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
pt_PrintNextChar
	move.b	(a0)+,d0
	beq.s	pt_EndOfString

;	------------------------------------------------------------------

	cmp.b	#10,d0		; EOL or carriage return
	beq.s	pt_IsNewLine

;	------------------------------------------------------------------

	cmp.b	#TAB,d0		; Is it a TAB?
	beq.s	pt_IsTAB

	cmp.w	#(BytesPerLine-1),wk_CursXCoord(a4)
	ble.s	pt_StillInRHS	; Because of 0-79==80

;	------------------------------------------------------------------

	sub.w	#(BytesPerLine-1),wk_CursXCoord(a4)
	addq.w	#1,wk_CursYCoord(a4)
pt_StillInRHS
	cmp.w	#CursorYMaximum,wk_CursYCoord(a4)
	bgt.s	pt_EndOfString

;	------------------------------------------------------------------

	move.w	wk_CursXCoord(a4),d1	; Pass X and Y coords and also
	move.w	wk_CursYCoord(a4),d2	; the character
	move.l	a0,-(sp)
	move.w	#'DB',d4		; Draw characters - DBL Buffering
	bsr	DrawCharacter
	move.l	(sp)+,a0

	addq.w	#1,wk_CursXCoord(a4)	; Move cursor across

	bra.s	pt_PrintNextChar	; Print the next character
	
;	------------------------------------------------------------------

pt_EndOfString
	bra	ScrollMoreText		; Copy Buffer to Display

;	------------------------------------------------------------------

pt_IsNewLine
	clr.w	wk_CursXCoord(a4)	; Move cursor back to far LHS and
	addq.w	#1,wk_CursYCoord(a4)	; one line down..
	bra.s	pt_PrintNextChar

;	------------------------------------------------------------------

pt_IsTAB
	move.w	wk_CursXCoord(a4),d3
	lsr.w	#3,d3		; Divide the number of spaces by 8
	addq.w	#1,d3		; Add a tab spacing..
	lsl.w	#3,d3		; Multiply the number of tabs by 8

	move.w	#(BytesPerLine-1),d4
	cmp.w	d4,d3
	ble.s	ptt_IsMaximumXCoord
	move.w	d4,d3
ptt_IsMaximumXCoord
	move.w	d3,wk_CursXCoord(a4)
	bra.s	pt_PrintNextChar


;	==================================================================
;	FUNCTION: PrintALine
;	USE:	  Prints a line of text at cursor X and Y coords.
;	PARAMS:	  a0=address of string
;	RESULT:	  Character printed on screen.
;	------------------------------------------------------------------

PrintALine:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

pal_PrintNextChar
	move.b	(a0)+,d0
	beq.s	pal_EndOfString

;	------------------------------------------------------------------

	cmp.b	#10,d0		; EOL or carriage return
	beq.s	pal_IsNewLine

;	------------------------------------------------------------------

	cmp.b	#TAB,d0		; Is TAB ???
	beq.s	pal_IsTAB

;	------------------------------------------------------------------

	cmp.w	#BytesPerLine-1,wk_CursXCoord(a4)  ; Because of 0-79==80 
	ble.s	pal_StillInRHS
	clr.w	wk_CursXCoord(a4)
	addq.w	#1,wk_CursYCoord(a4)
	bra.s	pal_IsNewLine

;	------------------------------------------------------------------

pal_StillInRHS
	cmp.w	#CursorYMaximum,wk_CursYCoord(a4)
	bgt.s	pal_EndOfString

;	------------------------------------------------------------------

	move.w	wk_CursXCoord(a4),d1
	move.w	wk_CursYCoord(a4),d2
	move.l	a0,-(sp)
	move.w	#'DB',d4

	bsr	DrawCharacter

	move.l	(sp)+,a0
	addq.w	#1,wk_CursXCoord(a4)

	bra.s	pal_PrintNextChar
	
;	------------------------------------------------------------------

pal_IsNewLine
pal_EndOfString
	rts

;	------------------------------------------------------------------

pal_IsTAB
	move.w	wk_CursXCoord(a4),d3
	lsr.w	#3,d3
	addq.w	#1,d3
	lsl.w	#3,d3
	move.w	#(BytesPerLine-1),d4
	cmp.w	d4,d3
	ble.s	palt_IsMaximumXCoord
	move.w	d4,d3
palt_IsMaximumXCoord
	move.w	d3,wk_CursXCoord(a4)
	bra.s	pal_PrintNextChar


;	======================================================================
;	FUNCTION: PrintString
;	USE:	  Prints a string at specified X and Y coords.
;	PARAMS:	  a0=address of string (null terminated)
;	RESULT:	  Character printed on screen.
;	------------------------------------------------------------------

PrintString:
	moveq	#0,d0
	moveq	#0,d1			; Clear registers the fast way
	moveq	#0,d2
	move.b	(a0)+,d0		; Get cmd character
	cmp.b	#'@',d0			; Is it the move cursor code?
	bne.s	ps_EndOfString

;	------------------------------------------------------------------

	move.b	(a0)+,d1		; Right now get X coord
	move.b	(a0)+,d2		;	   then Y coord
ps_PrintNextChar
	moveq	#0,d0
	move.b	(a0)+,d0		; Fetch next actual character
	beq.s	ps_EndOfString		; If NULL then finished

;	------------------------------------------------------------------

	cmp.b	#10,d0			; Is it CR
	beq.s	PrintString		; If so start a new string

	move.l	a0,-(sp)
	movem.w	d1-d2,-(sp)		; Save registers hopefully

	bsr	DrawCharacter

	movem.w	(sp)+,d1-d2		; Get them back???
	move.l	(sp)+,a0
	addq.w	#1,d1			; Increment X coord

	cmp.w	#BytesPerLine-1,d1	; Are we past RHS
	ble.s	ps_StillInRHS		; If not skip

;	------------------------------------------------------------------

	moveq	#0,d1			; Otherwise reset X coord
	addq.w	#1,d2			; And increment Y coord
ps_StillInRHS
	cmp.w	#CursorYMaximum+2,d2	; Are we past BOS
	ble.s	ps_PrintNextChar	; Is not loop

;	------------------------------------------------------------------

ps_EndOfString
	rts				; Done
	

;	==================================================================
;	FUNCTION: DrawCharacter
;	USE:	  Prints a character at specified X,Y coords.
;	PARAMS:	  d0=Character d1=XCoord d2=YCoord
;	RESULT:	  Character printed on screen.
;	------------------------------------------------------------------

;	The significance of the x*BytesPerLine from below is to get the proper
;	offset to handle lo-res and hires... and the significance of 192 is
;	approximately the number of characters in the charset stored top line
;	one after the other..

DrawCharacter	
	cmp.w	#'DB',d4
	bne.s	dc_IsOnBitplane

;	------------------------------------------------------------------

	moveq	#0,d4
	move.l	wk_DoubleBuffer(a4),a0
	bra.s	dc_GotPlaneAddress

;	------------------------------------------------------------------

dc_IsOnBitplane
	move.l	wk_Bitplane1(a4),a0	; BitPlaneAddr
dc_GotPlaneAddress
	mulu	#ScreenWidth,d2		; Get start of screen line
	add.w	d2,a0			; Add to base of 1st bitplane
	add.w	d1,a0			; Add the x-coord offset
	sub.w	#32,d0			; ' ' := 32, is whitespace/first char
	lea	CharSet(pc),a1		; in the font/charset
	add.w	d0,a1
	move.b	0*192(a1),0*BytesPerLine(a0)
	move.b	1*192(a1),1*BytesPerLine(a0)
	move.b	2*192(a1),2*BytesPerLine(a0)
	move.b	3*192(a1),3*BytesPerLine(a0)
	move.b	4*192(a1),4*BytesPerLine(a0)
	move.b	5*192(a1),5*BytesPerLine(a0)
	move.b	6*192(a1),6*BytesPerLine(a0)
	move.b	7*192(a1),7*BytesPerLine(a0)
	rts

;	==================================================================
;	Button Resource Tables:
;		These are used to determine which function the user is
;	clicking on a button for.
;	------------------------------------------------------------------

CurrentButtonTable
	dc.l	DiskMagazine_BRT

;	------------------------------------------------------------------

DiskMagazine_BRT
	dc.w	0,0
	dc.w	640,256
	dc.l	Quit

	dc.w	0,0
	dc.w	0,0
	dc.l	0

;	======================================================================

CharSet	incdir	'Entropy:'
	incbin	'SGFont1.bin'
;	incbin	'Binary/SGFont1.bin'	; Charset/Font for magazine
	even

;	------------------------------------------------------------------
;	Library names, but are the evens needed every time? Have to look it up

GfxName	dc.b	'graphics.library',0	; For the copperlist.
	even

DosLibName
	dc.b	'dos.library',0		; For file handling.
	even

IntuiName
	dc.b	'intuition.library',0	; For AutoRequest patching.
	even

;	======================================================================

IndexName
	dc.b	'Entropy:Index.FLT',0

IndexTitle
	dc.b	'The Index - Press the help key for the help page...',0

IndexPageNum
	dc.b	'@',78,2
	dc.b	'00',0

;	------------------------------------------------------------------

BlankTitle
	dc.b	'@',07,CursorYMaximum+2
	dc.b	'                                                                   ',0

TitleName
	dc.b	'Entropy:Page00.txt',0

;	------------------------------------------------------------------
;	This following string is used for the general storage of page filenames
;	the numbers are obviously inserted in the 'Buffer' bit..

TextName
	dc.b	'Entropy:Page'
TextNumberBuffer
	dc.b	'  .txt',0
	even

;	------------------------------------------------------------------
;	Temporary buffer for the workspace memory address so we can snarf it
;	for use in interrupts, (We had a problem there ;-)

MemAddress:
	dc.l	0

;	======================================================================

VersionString
	dc.b	'$VER:  ENTROPY DiskMag V2.01 by Soltan Gris (08/11/94)',0
	even

;	------------------------------------------------------------------

TitleText
	dc.b	'@',(BytesPerLine-44)/2,4	; Centered text, 44=length
	dc.b	'A Soltan Gris production for Entropy in 1994',0

;	======================================================================

HelpTxt
	dc.b	'------------------------------------------------------------------------------',10
	dc.b	'  _   _  ____  _     ___',10
	dc.b	' | |_| || ___|| |   |_  \  _		Entropy Diskmag V2.01	      08/11/94',10
	dc.b	' |     ||__/  | |    _|  ||_|',10
	dc.b	' |  _  | ____ | |__ |  _/  _      		   Coded in 100% Assembler by:',10
	dc.b	' |_| |_||____||____||_|   |_|			      -+= Soltan Gris =+-',10,10
	dc.b	'------------------------------------------------------------------------------',10
	dc.b	'				Keyboard Commands:',10
	dc.b	'------------------------------------------------------------------------------',10,10
	dc.b	'		Help	- This page	F08	- My Messages/Adds',10
	dc.b	'		Escape	- Exit		F09	- Reload index page',10
	dc.b	'					F10	- Refresh page',10,10
	dc.b	'		Left Mouse		- Exit',10
	dc.b	'		Right Mouse		- Exit',10
	dc.b	'		Up Cursor Key		- Scroll one line up',10
	dc.b	'		Down Cursor Key		- Scroll one line down',10
	dc.b	'		Left Cursor Key		- Next page',10
	dc.b	'		Right Cursor Key	- Previous page',10,10
	dc.b	'------------------------------------------------------------------------------',10,10
	dc.b	'	  The top row number keys can be used to select page numbers and are',10
	dc.b	'   taken in succession. The numbers can be viewed on the top right of the',10
	dc.b	'   titlebar, second line down. If the file corresponding to  a number does',10
	dc.b	'   not exist then you will be left on the page you were already on.',10,10
	dc.b	'   To get my address, see some adds, read some messages etc, try the F8',10
	dc.b	'   the F8 function (Just press the damn key....',10,10
	dc.b	'						Yours Soltan.....',10,10
	dc.b	'------------------------------------------------------------------------------',0

;	------------------------------------------------------------------

SoltanGrisTxt
	dc.b	'------------------------------------------------------------------------------',10
	dc.b	'  _   _   _    ___   __',10
	dc.b	' | | | | | |  / __| /  \  _		Entropy Diskmag V2.01	      08/11/94',10
	dc.b	' | | |  \| | |  __|| /  ||_|',10
	dc.b	' | | | |\  | | |   |  / | _			   Coded in 100% Assembler by:',10
	dc.b	' |_| |_| |_| |/     \__/ |_|			      -+= Soltan Gris =+-',10,10
	dc.b	'------------------------------------------------------------------------------',10
	dc.b	'				About this Program:',10
	dc.b	'------------------------------------------------------------------------------',10,10
	dc.b	'	If you''re wondering why this program is titled "Entropy", it is for',10
	dc.b	'  for lack of a better name, suggestions are welcome and can be given/sent',10
	dc.b	'  whatever to Jericho at the usual postal address for Entropy, as to the',10
	dc.b	'  address, I don''t have it with me so I can''t put it here for you...',10,10
	dc.b	'	This diskmag has been approximately half a year in the making!!!!',10
	dc.b	'  You may be wondering how it took that long to code it, well it didn''t really',10
	dc.b	'  what caused the big wait was the lack of a computer.... and also a year',10
	dc.b	'  ( maybe wasted :-) at a tertiary institution.',10,10
	dc.b	'	Some information about the program:',10
	dc.b	'	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^',10
	dc.b	'  Source code size:			12419 lines,	61182 bytes.',10
	dc.b	'  Binary size:				15998 bytes.',10
	dc.b	'  Other included binaries are:		The font, and the logo.',10,10
	dc.b	'  Assembler used:			Devpac 2, Trash''m''one V?.??',10,10
	dc.b	'	Bugs remaining:',10
	dc.b	'	^^^^^^^^^^^^^^^',10
	dc.b	'	The only error remaining that I am aware of is, in requester/error',10
	dc.b	'  handling in Kickstart 3.1, I''m not sure if Kickstart 2.04 has the same',10
	dc.b	'  problem, as I have been working in 1.3, and 3.1 and my 2.04 chip is in',10
	dc.b	'  storage..',10,10
	dc.b	'  	If you discover any bugs, I may have found and forgotten or not even',10
	dc.b	'  known about please contact me about it, in the address I have supplied.',10,10
	dc.b	'------------------------------------------------------------------------------',10
	dc.b	'				My Advertisements:',10
	dc.b	'------------------------------------------------------------------------------',10,10
	dc.b	'  o	If you want to swap demos, intros or trainers, ripped from games or',10
	dc.b	'	whatever, feel free to contact me',10,10
	dc.b	'  o	If you want to swap disk magazines (not the disks you get with mags',10
	dc.b	'	like Amiga Shopper!!. The ones by crackers/demo groups are the ones',10
	dc.b	'	I want e.g Crackers Journal, Stolen Data, Tech Times, LSD Grapevine..',10
	dc.b	'	with me, send a list, 100% reply rate...',10,10
	dc.b	'  o	Do you want help with your assembler source codes, to swap assemblers',10
	dc.b	'	swap source codes, coding tips etc.. fell free to write..',10,10
	dc.b	'------------------------------------------------------------------------------',10
	dc.b	'				    My Address:',10
	dc.b	'------------------------------------------------------------------------------',10,10
	dc.b	'  Permanent contact address:',10
	dc.b	'  ^^^^^^^^^^^^^^^^^^^^^^^^^^',10
	dc.b	'			Soltan Gris,',10
	dc.b	'			Richard Tew,',10
	dc.b	'			146 Alford Forest Road,',10
	dc.b	'			Ashburton,',10
	dc.b	'			New Zealand.',10,10
	dc.b	'  E-Mail Addresses:',10
	dc.b	'  ^^^^^^^^^^^^^^^^^',10
	dc.b	'	I have 1 NZ email address and 3 overseas, but the only one I can',10
	dc.b	'  is:-			misc206@csc.canterbury.ac.nz',10
	dc.b	'  and it should be usable for the next couple of years... ( I Hope!! )',10
	dc.b	'						Ave,',10
	dc.b	'							Soltan 12/11/94.',10,10
	dc.b	'------------------------------------------------------------------------------',0

;	======================================================================

EntropyTitleCTxt
	dc.b	'@',71,00
	dc.b	'Page: #--',10
	dc.b	'@',0,CursorYMaximum+2
	dc.b	'Title: Loading index file and sorting....',0

PageNumbersCTxt
	dc.b	'@',78,00
PageNumBuffer
	dc.b	'  ',0

;	======================================================================
;	In progress messages:

ReadingFile1Txt
	dc.b	'Proceeding to read in file: ',0
ReadingFile2Txt
	dc.b	'...',10,0
LockTxt
	dc.b	'  Attempting to lock file',10,0
ExamineTxt
	dc.b	'  Examining file',10,0
UnLockTxt
	dc.b	'  Unlocking file',10,0
OpenTxt
	dc.b	'  Attempting to open file',10,0
ReadTxt
	dc.b	'  Reading data....',10,0
CloseTxt
	dc.b	'  Closing file',10,0
ReadyTxt
	dc.b	'Ready.',10,10,0

AutoRequestTxt
	dc.b	10,'AutoRequest:  ',0
LeftButtonTxt
	dc.b	10,'LEFT  button: ',0
RightButtonTxt
	dc.b	10,'RIGHT button: ',0
RequesterChoiceTxt
	dc.b	10,10,'Please select the appropriate choice by pressing your left or right mouse button',10,10,0

ProgramDataCTxt
	dc.b	'@',00,CursorYMaximum
	dc.b	'MouseX: $',10
	dc.b	'@',12,CursorYMaximum
	dc.b	'MouseY: $',10
	dc.b	'@',24,CursorYMaximum
	dc.b	'KeyCode: $',0

;	======================================================================
;	Error Messages:

DosErrorCTxt
	dc.b	'@',00,CursorYMinimum
	dc.b	'Internal Error #01: Unable to open dos. library',10
	dc.b	'@',00,CursorYMinimum+1
	dc.b	'-> This utility will quit in 10 seconds...',0

FileLockErrTxt
	dc.b	'Internal Error #02: Unable to locate file',10
	dc.b	'Is the volume Entropy: available? (either in the drive or assigned)',10,0

FileExamErrTxt
	dc.b	'Internal Error #03: Unable to examine file',10,0

NoFileMemErrTxt
	dc.b	'Internal Error #04: Unable to allocate file buffer',10,0

FileOpenErrTxt
	dc.b	'Internal Error #05: Unable to open file',10,0

NotIndexFileErrCTxt
	dc.b	'@',00,CursorYMinimum
	dc.b	'Internal Error #06: Not an index file',10
	dc.b	'@',00,CursorYMinimum+1
	dc.b	' The index file has been tampered with!!!',10
	dc.b	'@',00,CursorYMinimum+2
	dc.b	' Releasing virus into memory.......',0

IndexErrTxt
	dc.b	10,'Internal Error #07: Unable to load Index file',0
	even

;	======================================================================

	SECTION	Gfx,DATA_C

CopperList
	Mov	%1100001000000000,bplcon0
	Mov	0,bplcon1
	Mov	0,bpl1mod
	Mov	0,bpl2mod
	Mov	$003C,ddfstrt
	Mov	$00D4,ddfstop
	Mov	$2C81,diwstrt
	Mov	$2CC1,diwstop
CopperListColors
	Mov	$029,color00
	Mov	$0FFF,color01
	Mov	$0FEF,color02
	Mov	$0EDE,color03
	Mov	$0DCD,color04
	Mov	$0CBC,color05
	Mov	$0BAB,color06
	Mov	$0A9A,color07
	Mov	$0989,color08
	Mov	$0878,color09
	Mov	$0768,color10
	Mov	$0657,color11
	Mov	$0546,color12
	Mov	$0435,color13
	Mov	$0324,color14
	Mov	$0213,color15
	Mov	$0000,color16
	Mov	$0000,color17
	Mov	$0000,color18
	Mov	$0000,color19
	Mov	$0000,color20
	Mov	$0000,color21
	Mov	$0000,color22
	Mov	$0000,color23
	Mov	$0000,color24
	Mov	$0000,color25
	Mov	$0000,color26
	Mov	$0000,color27
	Mov	$0000,color28
	Mov	$0000,color29
	Mov	$0000,color30
	Mov	$0000,color31

CprSpr1
	Mov	0,spr0pth
	Mov	0,spr0ptl
CprSpr2
	Mov	0,spr1pth
	Mov	0,spr1ptl
CprSpr3
	Mov	0,spr2pth
	Mov	0,spr2ptl
CprSpr4
	Mov	0,spr3pth
	Mov	0,spr3ptl
CprSpr5
	Mov	0,spr4pth
	Mov	0,spr4ptl
CprSpr6
	Mov	0,spr5pth
	Mov	0,spr5ptl
CprSpr7
	Mov	0,spr6pth
	Mov	0,spr6ptl
CprSpr8
	Mov	0,spr7pth
	Mov	0,spr7ptl

CprPln1
	Mov	0,bpl1pth
	Mov	0,bpl1ptl
CprPln2
	Mov	0,bpl2pth
	Mov	0,bpl2ptl
CprPln3
	Mov	0,bpl3pth
	Mov	0,bpl3ptl
CprPln4
	Mov	0,bpl4pth
	Mov	0,bpl4ptl

	Wait	007,88
	Mov	$FFF,color00		; Draw start-of-text white line
	Wait	007,89

	Mov	$0000,color00		; Main text bit......
	Mov	$0FFF,color01
	Mov	$0FFF,color02

	Wait	224,255			; Wait to get into PAL screen area

	Wait	007,021
	Mov	$FFF,color00		; Draw end-of-text white line
	Wait	007,022

	Mov	$029,color00		; Start outside color

	Wait	254,255			; End-of-copper wait, twice for
	Wait	254,255			; safety....

;	======================================================================

SpriteData
	dc.l	$9A88B700		; Coolest mouse pointer, tho the old
MouseData
	dc.l	$C0004000		; hand one I used to get with pirated
	dc.l	$7000B000		; software from copysoft was pretty
	dc.l	$3C004C00		; snazzy... ;-)
	dc.l	$3F004300
	dc.l	$1FC020C0
	dc.l	$1FC02000
	dc.l	$0F001100
	dc.l	$0D801280
	dc.l	$04C00940
	dc.l	$046008A0
	dc.l	$00200040,0,0

;	======================================================================
;	Gfx Binary Files:


EntropyLogo				; Snazzy title, of 'Entropy'
	incbin	'ENTY.bin'
;	incbin	'binary/enty.bin'	; Where oh where have my binaries gone?
					; Hey, you're not in DMClone now Dr
					; Ropata!


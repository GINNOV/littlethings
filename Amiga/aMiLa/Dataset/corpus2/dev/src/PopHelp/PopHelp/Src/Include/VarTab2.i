; Variables moved from stack to allocated memory block...
; Plus some other data added...
; Base address still in a5  ->  move.l variable(a5),d0  or something.
; $VER: Include v1.00 / PH v2.58
; (C) Mika Lundell
;
; This source code is part of the PopHelp package.
; Freeware, use it as you like.

 STRUCTURE	VariableTable,0
	LONG	DosBase
	LONG	GfxBase
	LONG	IBase
	LONG	MathBase
	LONG	MyWindow
	LONG	RPort
	LONG	Font
	LONG	GfxMem
	LONG	Borders

	LONG	ReqTBase
	LONG	PPBase
	LONG	PPBuffer
	LONG	PPLen

	BYTE	CTRL_1
	BYTE	CTRL_2
	BYTE	CTRL_3
	BYTE	CTRL_4
	LONG	LONG_1
	LONG	LONG_2
	LONG	LONG_3
	LONG	LONG_4
	LONG	LONG_5
	LONG	LONG_6
	LONG	LONG_7
	LONG	LONG_8

	LONG	FIB
	LONG	FIB2
	LONG	DirBufs
	LONG	FirstDirBufs
	LONG	FileBufs
	LONG	FirstFileBufs
	LONG	CurrRP
	LONG	RP
	LONG	IDCMPWin

	BYTE	VecCheck
	BYTE	Seq
	BYTE	ActiveString
	BYTE	aaaa
	LONG	LastComm

	LONG	Para
	LONG	Para2
	LONG	Para3
	LONG	Para4
	LONG	Para5
	WORD	MenuNum
	WORD	ItemNum
	WORD	SubNum
	LONG	BWindow
	LONG	FileHandle1
	LONG	FileHandle2
	LONG	FileLength
	LONG	CurrMsgY
	LONG	Lukko

	LONG	TrackPort0
	LONG	IOReq0
	LONG	TrackPort1
	LONG	IOReq1

	LONG	Dirs
	LONG	MDs
	LONG	Files
	LONG	MFs
	LONG	Bytes
	LONG	MBs
	LONG	FDs
	LONG	FFs
	LONG	FBs

; These were in DATA hunk...
	BYTE	FPen
	BYTE	BPen
	LONG	SourceFile
	LONG	DestinFile
	LONG	Lokki1

	LONG	BADCount
	LONG	PALNTSC
	LONG	DirFIB

	LONG	ShowScr
	LONG	BetaWindow
	WORD	MusseX
	WORD	MusseY

	LONG	DNamNum
	LONG	FNamNum
	LONG	CurrDBuf
	LONG	CurrDPos
	LONG	CurrFBuf
	LONG	CurrFPos
	LONG	DNamePos
	LONG	FNamePos

	LONG	BufSize
	LONG	DidError
	BYTE	Unit
	BYTE	DeviceFlag0
	BYTE	DeviceFlag1
	BYTE	WhichTD
	LONG	Mem
	LONG	MsgLength
	LONG	Kilos
	LONG	x
	LONG	y

	LONG	FirstMenu
	LONG	PrevMenu
	LONG	PrevItem
	LONG	PrevSubItem
	WORD	SubItemWidth
	BYTE	MenuError

	BYTE	GadgetError
	LONG	FirstGadget
	LONG	PrevGadget
	LONG	FirstIGadget
	LONG	FirstIGadget2
	LONG	PrevIGadget
	LONG	First_Gadget

	LONG	StringGadget1
	LONG	StringGadget2
	LONG	DownArrow1
	LONG	DownArrow2
	LONG	FirstDevGadget
	LONG	FirstOptGadget
	LONG	Err_pad

	LONG	SetBufSize
	LONG	BufSizeBuf

	LONG	StringBuf1
	LONG	StringBuf2
	LONG	StringUnDoBuf
	LONG	TxtBuffer
	LONG	Buf1
	LONG	JokerBuf
	LONG	NoJokerPath
	LONG	DestBuf
	LONG	fastBuf
	LONG	FirstPathBuf
	LONG	DWinTBuf
	LONG	FirstTitleBuf
	LONG	UseOnlyNowBuf

	LONG	DriveID
	BYTE	ZeroAnswer
	BYTE	DriveID0
	BYTE	DriveID1
	BYTE	BorderError

	LONG	ArrowPtr
	LONG	BusyPtr
	LONG	DwnData
	LONG	UpData
	LONG	PDwnData
	LONG	PUpData
	LONG	BotData
	LONG	TopData
	LONG	OffPtr

	LONG	ActBorder
	LONG	MsgBorder
	LONG	OptionBorder
	LONG	FirstBorder
	LONG	DirBorder
	LONG	TypeBorder
	LONG	StringBorder
	LABEL	vt_SIZEOF

 STRUCTURE	DataMemory,vt_SIZEOF
	STRUCT	_nw_Struct,nw_SIZE
	STRUCT	_ns_Struct,ns_SIZEOF

	STRUCT	_DirVecs,20*2
	STRUCT	_TypeVecs,20*2

	STRUCT	_FIB,fib_SIZEOF
	STRUCT	_FIB2,fib_SIZEOF
	STRUCT	_DirFIB,fib_SIZEOF
	STRUCT	_DirBufs,2048
	STRUCT	_FileBufs,2048
	STRUCT	_FirstDirBufs,2048
	STRUCT	_FirstFileBufs,2048

	STRUCT	_TxtBuffer,128
	STRUCT	_Buf1,256
	STRUCT	_JokerBuf,128
	STRUCT	_NoJokerPath,128
	STRUCT	_DestBuf,256
	STRUCT	_fastBuf,256
	STRUCT	_FirstPathBuf,84
	STRUCT	_DWinTBuf,128
	STRUCT	_FirstTitleBuf,128
	STRUCT	_UseOnlyNowBuf,256
	STRUCT	_StringBuf1,82
	STRUCT	_StringBuf2,82
	STRUCT	_StringUnDoBuf,82

	STRUCT	_ColdCaptureBuf,14+9
	STRUCT	_CoolCaptureBuf,14+9
	STRUCT	_WarmCaptureBuf,14+9
	STRUCT	_KickMemPtrBuf,14+9
	STRUCT	_KickTagPtrBuf,14+9
	STRUCT	_DoIOBuf,14+9
	STRUCT	_SendIOBuf,14+9
	BYTE	dm_pad
	LABEL	dm_SIZEOF

 STRUCTURE	GfxMemory,0
	STRUCT	_gfx_ArrowPtr,52	;aptr_SIZE
	STRUCT	_gfx_BusyPtr,72		;bptr_SIZE
	STRUCT	_gfx_DwnData,44		;dwn_SIZE
	STRUCT	_gfx_UpData,44
	STRUCT	_gfx_PDwnData,44
	STRUCT	_gfx_PUpData,44
	STRUCT	_gfx_BotData,44
	STRUCT	_gfx_TopData,44
	STRUCT	_gfx_OffPtr,12
	LABEL	gm_SIZEOF

; CTRL_1
Exit		equ	0
NumStrings	equ	1
FirstDir_avail	equ	2
FirstDir	equ	3
MousePickEnable	equ	4
TDir		equ	5
OnlyHandler	equ	6
OneDraivi	equ	7

; CTRL_2
PointerPtr	equ	0
ScreenMode	equ	1
Command_Move	equ	2
InstallAfter	equ	3
Public_Jokers	equ	4
Jokers_Found	equ	5
MarkTrckOrSecs	equ	6
IsBusyPtrOn	equ	7

; CTRL_3
Option1		equ	7
Option2		equ	6
Option3		equ	5
Option4		equ	4
Option5		equ	3
Option6		equ	2
Option7		equ	1
Option8		equ	0

; CTRL_4
AutoSize	equ	0
NewKS		equ	1

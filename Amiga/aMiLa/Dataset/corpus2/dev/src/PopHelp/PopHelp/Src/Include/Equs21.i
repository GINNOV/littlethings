; Types for assemblers sake... equalities, macros, structures
; $VER: Include v1.00 / PH v2.58
;
; This source code is part of the PopHelp package.
; Freeware, use it as you like.

STRUCTURE	macro
\1	=	0
SOFFSET	set	\2
		endm
BYTE		macro
\1	=	SOFFSET
SOFFSET	set	SOFFSET+1
		endm
UBYTE		macro
\1	=	SOFFSET
SOFFSET	set	SOFFSET+1
		endm
WORD		macro
\1	=	SOFFSET
SOFFSET	set	SOFFSET+2
		endm
UWORD		macro
\1	=	SOFFSET
SOFFSET	set	SOFFSET+2
		endm
LONG		macro
\1	=	SOFFSET
SOFFSET	set	SOFFSET+4
		endm
ULONG		macro
\1	=	SOFFSET
SOFFSET	set	SOFFSET+4
		endm
APTR		macro
\1	=	SOFFSET
SOFFSET	set	SOFFSET+4
		endm
STRUCT		macro
\1	=	SOFFSET
SOFFSET	set	SOFFSET+\2
		endm
LABEL		macro
\1	=	SOFFSET
		endm
BITDEF		macro	* prefix,&name,&bitnum
		BITDEF0	\1,\2,B_,\3
\@BITDEF	set	1<<\3
		BITDEF0	\1,\2,F_,\@BITDEF
		endm
BITDEF0		macro	* prefix,&name,&type,&value
\1\3\2		equ	\4
		endm

_OpenLib	macro	* LibName
		lea	\1Name(pc),a1
		moveq	#0,d0
		jsr	OpenLibrary(a6)
		move.l	d0,\1Base(a5)
		beq	CleanUp
		endm

_NEWLIST	macro	* List
		move.l	\1,(\1)
		addq.l	#LH_TAIL,(\1)
		clr.l	LH_TAIL(\1)
		move.l	(\1),(LH_TAIL+LN_PRED)(\1)
		endm

TIMERNAME	macro
		dc.b	'timer.device',0
		endm
TD_NAME		macro
		dc.b	'trackdisk.device',0
		endm
ICONNAME	macro
		dc.b	'icon.library',0
		endm
DOSNAME		macro
		dc.b	'dos.library',0
		endm
GFXNAME		macro
		dc.b	'graphics.library',0
		endm
INTUINAME	macro
		dc.b	'intuition.library',0
		endm
TOPAZNAME	macro
		dc.b	'topaz.font',0
		endm
PPNAME		macro
		dc.b	'powerpacker.library',0
		endm
REQTOOLSNAME	macro
		dc.b	'reqtools.library',0
		endm
MATHNAME	macro
		dc.b	'mathffp.library',0
		endm

DEVINIT		macro	* [baseOffset]
		ifc	'\1',''
CMD_COUNT	set	CMD_NONSTD
		endc
		ifnc	'\1',''
CMD_COUNT	set	\1
		endc
		endm
DEVCMD		macro	* cmdname
\1		equ	CMD_COUNT
CMD_COUNT	set	CMD_COUNT+1
		endm

 STRUCTURE	LN,0
	APTR	LN_SUCC
	APTR	LN_PRED
	UBYTE	LN_TYPE
	BYTE	LN_PRI
	APTR	LN_NAME
	LABEL	LN_SIZE

 STRUCTURE	LH,0
	APTR	LH_HEAD
	APTR	LH_TAIL
	APTR	LH_TAILPRED
	UBYTE	LH_TYPE
	UBYTE	LH_pad
	LABEL	LH_SIZE

 STRUCTURE	MP,LN_SIZE
	UBYTE	MP_FLAGS
	UBYTE	MP_SIGBIT
	APTR	MP_SIGTASK
	STRUCT	MP_MSGLIST,LH_SIZE
	LABEL	MP_SIZE

 STRUCTURE	MN,LN_SIZE
	APTR	MN_REPLYPORT
	UWORD	MN_LENGTH
	LABEL	MN_SIZE

 STRUCTURE	NewScreen,0
	WORD	ns_LeftEdge
	WORD	ns_TopEdge
	WORD	ns_Width
	WORD	ns_Height
	WORD	ns_Depth
	BYTE	ns_DetailPen
	BYTE	ns_BlockPen
	WORD	ns_ViewModes
	WORD	ns_Type
	APTR	ns_Font
	APTR	ns_DefaultTitle
	APTR	ns_Gadgets
	APTR	ns_CustomBitMap
	LABEL	ns_SIZEOF

vp_SIZEOF	equ	$28
rp_SIZEOF	equ	$64
bm_SIZEOF	equ	$28
li_SIZEOF	equ	$66

 STRUCTURE	Screen,0
	APTR	sc_NextScreen
	APTR	sc_FirstWindow
	WORD	sc_LeftEdge
	WORD	sc_TopEdge
	WORD	sc_Width
	WORD	sc_Height
	WORD	sc_MouseY
	WORD	sc_MouseX
	WORD	sc_Flags
	APTR	sc_Title
	APTR	sc_DefaultTitle
	BYTE	sc_BarHeight
	BYTE	sc_BarVBorder
	BYTE	sc_BarHBorder
	BYTE	sc_MenuVBorder
	BYTE	sc_MenuHBorder
	BYTE	sc_WBorTop
	BYTE	sc_WBorLeft
	BYTE	sc_WBorRight
	BYTE	sc_WBorBottom
	BYTE	sc_KludgeFill00
	APTR	sc_Font
	STRUCT	sc_ViewPort,vp_SIZEOF
	STRUCT	sc_RastPort,rp_SIZEOF
	STRUCT	sc_BitMap,bm_SIZEOF
	STRUCT	sc_LayerInfo,li_SIZEOF
	APTR	sc_FirstGadget
	BYTE	sc_DetailPen
	BYTE	sc_BlockPen
	WORD	sc_SaveColor0
	APTR	sc_BarLayer
	APTR	sc_ExtData
	APTR	sc_UserData
	LABEL	sc_SIZEOF

 STRUCTURE	NewWindow,0
	WORD	nw_LeftEdge
	WORD	nw_TopEdge
	WORD	nw_Width
	WORD	nw_Height
	BYTE	nw_DetailPen
	BYTE	nw_BlockPen
	LONG	nw_IDCMPFlags
	LONG	nw_Flags
	APTR	nw_FirstGadget
	APTR	nw_CheckMark
	APTR	nw_Title
	APTR	nw_Screen
	APTR	nw_BitMap
	WORD	nw_MinWidth
	WORD	nw_MinHeight
	WORD	nw_MaxWidth
	WORD	nw_MaxHeight
	WORD	nw_Type
	LABEL	nw_SIZE

 STRUCTURE	Window,0
	APTR	wd_NextWindow
	WORD	wd_LeftEdge
	WORD	wd_TopEdge
	WORD	wd_Width
	WORD	wd_Height
	WORD	wd_MouseY
	WORD	wd_MouseX
	WORD	wd_MinWidth
	WORD	wd_MinHeight
	WORD	wd_MaxWidth
	WORD	wd_MaxHeight
	LONG	wd_Flags
	APTR	wd_MenuStrip
	APTR	wd_Title
	APTR	wd_FirstRequest
	APTR	wd_DMRequest
	WORD	wd_ReqCount
	APTR	wd_WScreen
	APTR	wd_RPort
	BYTE	wd_BorderLeft
	BYTE	wd_BorderTop
	BYTE	wd_BorderRight
	BYTE	wd_BorderBottom
	APTR	wd_BorderRPort
	APTR	wd_FirstGadget
	APTR	wd_Parent
	APTR	wd_Descendant
	APTR	wd_Pointer
	BYTE	wd_PtrHeight
	BYTE	wd_PtrWidth
	BYTE	wd_XOffset
	BYTE	wd_YOffset
	ULONG	wd_IDCMPFlags
	APTR	wd_UserPort
	APTR	wd_WindowPort
	APTR	wd_MessageKey
	BYTE	wd_DetailPen
	BYTE	wd_BlockPen
	APTR	wd_CheckMark
	APTR	wd_ScreenTitle
	WORD	wd_GZZMouseX
	WORD	wd_GZZMouseY
	WORD	wd_GZZWidth
	WORD	wd_GZZHeight
	APTR	wd_ExtData
	APTR	wd_UserData
	APTR	wd_WLayer
	APTR	IFont
	LABEL	wd_Size

 STRUCTURE	IntuiText,0
	BYTE	it_FrontPen
	BYTE	it_BackPen
	BYTE	it_DrawMode
	BYTE	it_pad
	WORD	it_LeftEdge
	WORD	it_TopEdge
	APTR	it_ITextFont
	APTR	it_IText
	APTR	it_NextText
	LABEL	it_SIZEOF

 STRUCTURE	Menu,0
	APTR	mu_NextMenu
	WORD	mu_LeftEdge
	WORD	mu_TopEdge
	WORD	mu_Width
	WORD	mu_Height
	WORD	mu_Flags
	APTR	mu_MenuName
	APTR	mu_FirstItem
	WORD	mu_JazzX
	WORD	mu_JazzY
	WORD	mu_BeatX
	WORD	mu_BeatY
	LABEL	mu_SIZEOF

 STRUCTURE	MenuItem,0
	APTR	mi_NextItem
	WORD	mi_LeftEdge
	WORD	mi_TopEdge
	WORD	mi_Width
	WORD	mi_Height
	WORD	mi_Flags
	LONG	mi_MutualExclude
	APTR	mi_ItemFill
	APTR	mi_SelectFill
	BYTE	mi_Command
	BYTE	mi_pad
	APTR	mi_SubItem
	WORD	mi_NextSelect
	LABEL	mi_SIZEOF

 STRUCTURE	Gadget,0
	APTR	gg_NextGadget
	WORD	gg_LeftEdge
	WORD	gg_TopEdge
	WORD	gg_Width
	WORD	gg_Height
	WORD	gg_Flags
	WORD	gg_Activation
	WORD	gg_GadgetType
	APTR	gg_GadgetRender
	APTR	gg_SelectRender
	APTR	gg_GadgetText
	LONG	gg_MutualExclude
	APTR	gg_SpecialInfo
	WORD	gg_GadgetID
	APTR	gg_UserData
	LABEL	gg_SIZEOF

 STRUCTURE	StringInfo,0
	APTR	si_Buffer
	APTR	si_UndoBuffer
	WORD	si_BufferPos
	WORD	si_MaxChars
	WORD	si_DispPos
	WORD	si_UndoPos
	WORD	si_NumChars
	WORD	si_DispCount
	WORD	si_CLeft
	WORD	si_CTop
	APTR	si_LayerPtr
	LONG	si_LongInt
	APTR	si_AltKeyMap
	LABEL	si_SIZEOF

 STRUCTURE	Border,0
	WORD	bd_LeftEdge
	WORD	bd_TopEdge
	BYTE	bd_FrontPen
	BYTE	bd_BackPen
	BYTE	bd_DrawMode
	BYTE	bd_Count
	APTR	bd_XY
	APTR	bd_NextBorder
	LABEL	bd_SIZEOF

 STRUCTURE	Image,0
	WORD	ig_LeftEdge
	WORD	ig_TopEdge
	WORD	ig_Width
	WORD	ig_Height
	WORD	ig_Depth
	APTR	ig_ImageData
	BYTE	ig_PlanePick
	BYTE	ig_PlaneOnOff
	APTR	ig_NextImage
	LABEL	ig_SIZEOF

 STRUCTURE	IntuiMessage,0
	STRUCT	im_ExecMessage,MN_SIZE
	LONG	im_Class
	WORD	im_Code
	WORD	im_Qualifier
	APTR	im_IAddress
	WORD	im_MouseX
	WORD	im_MouseY
	LONG	im_Seconds
	LONG	im_Micros
	APTR	im_IDCMPWindow
	APTR	im_SpecialLink
	LABEL	im_SIZEOF

 STRUCTURE	IO,MN_SIZE
	APTR	IO_DEVICE
	APTR	IO_UNIT
	UWORD	IO_COMMAND
	UBYTE	IO_FLAGS
	BYTE	IO_ERROR
	LABEL	IO_SIZE
	ULONG	IO_ACTUAL
	ULONG	IO_LENGTH
	APTR	IO_DATA
	ULONG	IO_OFFSET
	LABEL	IOSTD_SIZE

 STRUCTURE	DateStamp_,0
	LONG	ds_Days
	LONG	ds_Minute
	LONG	ds_Tick
	LABEL	ds_SIZEOF

 STRUCTURE	FileInfoBlock,0
	LONG	fib_DiskKey
	LONG	fib_DirEntryType
	STRUCT	fib_FileName,108
	LONG	fib_Protection
	LONG	fib_EntryType
	LONG	fib_Size
	LONG	fib_NumBlocks
	STRUCT	fib_DateStamp,ds_SIZEOF
	STRUCT	fib_Comment,80
	STRUCT	fib_padding,36
	LABEL	fib_SIZEOF

 STRUCTURE	InfoData,0
	LONG	id_NumSoftErrors
	LONG	id_UnitNumber
	LONG	id_DiskState
	LONG	id_NumBlocks
	LONG	id_NumBlocksUsed
	LONG	id_BytesPerBlock
	LONG	id_DiskType
	APTR	id_VolumeNode
	LONG	id_InUse
	LABEL	id_SIZEOF

 STRUCTURE	TIMEVAL,0
	ULONG	TV_SECS
	ULONG	TV_MICRO
	LABEL	TV_SIZE

 STRUCTURE	TIMEREQUEST,IO_SIZE
	STRUCT	IOTV_TIME,TV_SIZE
	LABEL	IOTV_SIZE
UNIT_MICROHZ	equ	0

	BITDEF	MEM,PUBLIC,0
	BITDEF	MEM,CHIP,1
	BITDEF	MEM,FAST,2
	BITDEF	MEM,CLEAR,16
	BITDEF	MEM,LARGEST,17

	DEVINIT	0
	DEVCMD	CMD_INVALID
	DEVCMD	CMD_RESET
	DEVCMD	CMD_READ
	DEVCMD	CMD_WRITE
	DEVCMD	CMD_UPDATE
	DEVCMD	CMD_CLEAR
	DEVCMD	CMD_STOP
	DEVCMD	CMD_START
	DEVCMD	CMD_FLUSH
	DEVCMD	CMD_NONSTD

	DEVINIT
	DEVCMD	TD_MOTOR
	DEVCMD	TD_SEEK
	DEVCMD	TD_FORMAT
	DEVCMD	TD_REMOVE
	DEVCMD	TD_CHANGENUM
	DEVCMD	TD_CHANGESTATE
	DEVCMD	TD_PROTSTATUS
	DEVCMD	TD_RAWREAD
	DEVCMD	TD_RAWWRITE
	DEVCMD	TD_GETDRIVETYPE
	DEVCMD	TD_GETNUMTRACKS
	DEVCMD	TD_ADDCHANGEINT
	DEVCMD	TD_REMCHANGEINT
	DEVCMD	TD_LASTCOMM

	DEVINIT
	DEVCMD	TR_ADDREQUEST
	DEVCMD	TR_GETSYSTIME
	DEVCMD	TR_SETSYSTIME

ACTION_INHIBIT	equ	$1f
TRUE		equ	1
FALSE		equ	0
SHARED_LOCK	equ	-2
EXCLUSIVE_LOCK	equ	-1
MODE_OLDFILE	equ	1005
MODE_NEWFILE	equ	1006
OFFSET_BEGINNING equ	-1
OFFSET_CURRENT	equ	0
OFFSET_END	equ	1
NT_MSGPORT	equ	4
NT_MESSAGE	equ	5
WBENCHSCREEN	equ	1
CUSTOMSCREEN	equ	15
SCREENQUIET	equ	$100
SCREENBEHIND	equ	$80
MENUENABLED	equ	1
SELECTED	equ	$80
ITEMTEXT	equ	2
ITEMENABLED	equ	$10
HIGHCOMP	equ	$40
HIGHBOX		equ	$80
MENUNULL	equ	$ffff
CHECKED		equ	$100
CLR_CHECKED	equ	$feff
CHECKIT		equ	1
CHECKWIDTH	equ	19
COMMWIDTH	equ	27
MENUTOGGLE	equ	8
GADGHCOMP	equ	0
GADGHNONE	equ	3
GADGDISABLED	equ	$100
RELVERIFY	equ	1
GADGIMMEDIATE	equ	2
STRGADGET	equ	4
LONGINT		equ	$800
ACTIVEGADGET	equ	$4000
BOOLGADGET	equ	1
ENDGADGET	equ	4
REQGADGET	equ	$1000
TOGGLESELECT	equ	$100
COMMSEQ		equ	4
GADGHIMAGE	equ	2
GADGIMAGE	equ	4
GADGETDOWN	equ	$20
GADGETUP	equ	$40
INTUITICKS	equ	$400000
VANILLAKEY	equ	$200000
RAWKEY		equ	$400
MENUPICK	equ	$100
CLOSEWINDOW	equ	$200
MOUSEBUTTONS	equ	8
WBENCHMESSAGE	equ	$20000
WBENCHOPEN	equ	1
WBENCHCLOSE	equ	2
WINDOWDRAG	equ	2
WINDOWDEPTH	equ	4
WINDOWSIZING	equ	1
WINDOWCLOSE	equ	8
ACTIVATE	equ	$1000
ACTIVE		equ	$2000
NOCAREREFRESH	equ	$20000
SIMPLE_REFRESH	equ	$40
SMART_REFRESH	equ	0
NEWSIZE		equ	2
RP_JAM1		equ	0
RP_JAM2		equ	1
LALT		equ	$10
RALT		equ	$20
LAMIGA		equ	$40
RAMIGA		equ	$80
LSHFT		equ	1
RSHFT		equ	2
CAPSLOCK	equ	4
CTRL		equ	8
SELECTDOWN	equ	$68
SELECTUP	equ	$e8
MENUDOWN	equ	$69
MENUUP		equ	$e9
SecsPerMin	equ	60
SecsPerHour	equ	60*60
SecsPerDay	equ	60*60*24
SecsPerYear	equ	60*60*24*365
ColdCapture	equ	$002a
CoolCapture	equ	$002e
WarmCapture	equ	$0032
KickMemPtr	equ	$0222
KickTagPtr	equ	$0226
VBlankFrequency	equ	$212
CTRL_C		equ	12
V_HIRES		equ	$8000
V_LACE		equ	4
DECR_POINTER	equ	2

IDCMP	set	CLOSEWINDOW!MENUPICK!GADGETDOWN!GADGETUP	;!NEWSIZE
WFLAGS	set	ACTIVATE!WINDOWDEPTH!WINDOWCLOSE!WINDOWDRAG!NOCAREREFRESH
IDCMP2	set	CLOSEWINDOW!GADGETDOWN!GADGETUP!MOUSEBUTTONS

do_Gadget	equ	4
WB_DISKMAGIC.VERSION equ $e3100001
LIB_VERSION	equ	20
pr_CLI		equ	$ac
pr_MsgPort	equ	$5c
bm_BytesPerRow	equ	0
bm_Rows		equ	2
bm_Depth	equ	5
bm_Planes	equ	8
sp_Pkt		equ	20
sp_Msg		equ	0
sp_SIZEOF	equ	68
dp_Link		equ	0
dp_Port		equ	4
dp_Type		equ	8
dp_Arg1		equ	20

; Icon.lib
GetDiskObject	equ	-$004e
FreeDiskObject	equ	-$005a

; Exec.lib
Disable		equ	-$0078
Enable		equ	-$007e
Forbid		equ	-$0084
Permit		equ	-$008a
OpenLibrary	equ	-$0228
CloseLibrary	equ	-$019e
WaitPort	equ	-$0180
Wait		equ	-$013e
GetMsg		equ	-$0174
ReplyMsg	equ	-$017a
PutMsg		equ	-$016e
RawDoFmt	equ	-$020a
AllocMem	equ	-$00c6
FreeMem		equ	-$00d2
AvailMem	equ	-$00d8
FindTask	equ	-$0126
AddPort		equ	-$0162
RemPort		equ	-$0168
DoIO		equ	-$01c8
SendIO		equ	-$01ce
WaitIO		equ	-$01da
OpenDevice	equ	-$01bc
CloseDevice	equ	-$01c2
AllocSignal	equ	-$014a
FreeSignal	equ	-$0150
SetSignal	equ	-$0132
CopyMem		equ	-$0270
CopyMemQuick	equ	-$0276

; Intuition.lib
OpenScreen	equ	-$00c6
CloseScreen	equ	-$0042
OpenWindow	equ	-$00cc
CloseWindow	equ	-$0048
SetMenuStrip	equ	-$0108
ClearMenuStrip	equ	-$0036
DrawImage	equ	-$0072
DrawBorder	equ	-$006c
ItemAddress	equ	-$0090
SizeWindow	equ	-$0120
OnMenu		equ	-$00c0
OffMenu		equ	-$00b4
OffGadget	equ	-$00ae
OnGadget	equ	-$00ba
ActivateGadget	equ	-$01ce
AddGList	equ	-$01b6
RemoveGList	equ	-$01bc
AddGadget	equ	-$002a
RemoveGadget	equ	-$00e4
RefreshGList	equ	-$01b0
MoveWindow	equ	-$00a8
WindowToFront	equ	-$0138
ScreenToFront	equ	-$00fc
SetWindowTitles	equ	-$0114
ActivateWindow	equ	-$01c2
RefreshWindowFrame equ	-$01c8
SetPointer	equ	-$010e
ClearPointer	equ	-$003c
DisplayBeep	equ	-$0060
ModifyIDCMP	equ	-$0096
Request		equ	-$00f0
EndRequest	equ	-$0078
AlohaWorkbench	equ	-$0192

; Graphics.lib
xMove		equ	-$00f0
Text		equ	-$003c
Draw		equ	-$00f6
WaitTOF		equ	-$010e
SetAPen		equ	-$0156
SetBPen		equ	-$015c
SetDrMd		equ	-$0162
SetRast		equ	-$00ea
OpenFont	equ	-$0048
CloseFont	equ	-$004e
SetFont		equ	-$0042
ClearScreen	equ	-$0030
RectFill	equ	-$0132
ScrollRaster	equ	-$018c
ClipBlit	equ	-$0228
BltClear	equ	-$012c
LoadRGB4	equ	-$00c0

; Dos.lib
Rename		equ	-$004e
IoErr		equ	-$0084
Lock		equ	-$0054
UnLock		equ	-$005a
Open		equ	-$001e
Close		equ	-$0024
Read		equ	-$002a
Write		equ	-$0030
Seek		equ	-$0042
Examine		equ	-$0066
ExNext		equ	-$006c
CurrentDir	equ	-$007e
DeleteFile	equ	-$0048
CreateDir	equ	-$0078
SetProtection	equ	-$00ba
DateStamp	equ	-$00c0
Delay		equ	-$00c6
Execute		equ	-$00de
Info		equ	-$0072
SetComment	equ	-$00b4
DeviceProc	equ	-$00ae

; PPLib
ppLoadData	equ	-$001e

; Mathffp.lib
SPFix		equ	-$001e
SPFlt		equ	-$0024
SPCmp		equ	-$002a
SPMul		equ	-$004e
SPDiv		equ	-$0054

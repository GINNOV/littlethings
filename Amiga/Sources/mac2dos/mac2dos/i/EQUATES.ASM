*********************************************************
*							*
*	Mac-2-Dos common equates			*
*							*
*	author: George E. Chamberlain			*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*	    268 Bowie Dr, Los Osos, CA 93402		*
*	     All rights reserved, worldwide		*
*********************************************************

LIBVER		EQU	33	;AmigaDOS V1.2 Lib or later

MN_SIZE		EQU	20

BLUE	EQU	0
WHITE	EQU	1
BLACK	EQU	2
ORANGE	EQU	3

JAM1	EQU	0
JAM2	EQU	1

EXISTING EQU	1005	;AmigaDOS OPEN EXISTING FILE ACCESS MODE
NEW	EQU	1006	;AmigaDOS OPEN NEW FILE ACCESS MODE

TRUE	EQU	-1	;BOOLEAN CONSTANT
FALSE	EQU	0	;DITTO

MEM_PUBLIC	EQU	1	;EITHER CHIP OR FAST
MEM_CHIP	EQU	2	;CHIP MEMORY
MEM_FAST	EQU	4	;NON-CHIP MEMORY
MEM_CLEAR	EQU	$10000	;clear mem

SELECTUP	EQU	$E8
SELECTDN	EQU	$68
MENUUP		EQU	$E9
MENUDN		EQU	$69

ACCESS_READ	EQU	-2
ACCESS_WRITE	EQU	-1

BlockBufSize	EQU	1024		;SIZE OF BLOCK BUFFER
ADosBufSize	EQU	512		;SIZE OF AMIGA-DOS TEXT BUFFER
LineBufSize	EQU	128		;SIZE OF TEXT BUFFER

SectorSize	EQU	512	;size of ADos block
PathSize	EQU	512	;size of path buffers
TmpSize		EQU	550	;must be at least 30 more than PathSize

REQ_WD		EQU	280	;STANDARD REQUESTER WIDTH
REQ_HT		EQU	60	;DITTO HEIGHT

IPEN		EQU	15	;OFFSET TO PEN IN IMAGE
TaskPort	EQU	$5C	;offset to task's port in task control block

* STRINGINFO OFFSETS

STG_BPOS	EQU	8
STG_MAXC	EQU	10
STG_NUMC	EQU	16

* window borders

W_LBorder	EQU	4	;left border margins
W_RBorder	EQU	18	;right scroll bar + border
W_TBorder	EQU	10	;title bar
W_BBorder	EQU	10	;bottom scroll bar + border

* ascii char constants

TAB	EQU	9
LF	EQU	10
CR	EQU	13
SPACE	EQU	32

* FILE WINDOW VALUES

FW_LE	EQU	144
FW_TE	EQU	30
FW_WD	EQU	352
FW_HT	EQU	120
ZWIDTH	EQU	304
FGID	EQU	100
FCHARS	EQU	32
DIR_SIZ	EQU	50

 STRUCTURE DirFib,0
	APTR	df_Next		;link to next entry or 0
	APTR	df_Size		;file size or ptr to next level
df_SubLevel EQU	df_Size
	WORD	df_Date		;days since Jan 1, 1978
	WORD	df_Time		;minutes since midnight
	WORD	df_Ticks	;ticks in this minute
	WORD	df_FilCnt	;dir count of items 
	BYTE	df_Prot		;archive and protection bits (0-3)
	BYTE	df_Flags	;DIR (7), SELECTED (6), ERROR (5), ODDlength (4)
	STRUCT	df_Name,112	;30-char file name, 80-comment, plus 2 nulls
	LABEL	df_SIZEOF

 STRUCTURE DirLevel,0
	LONG	dl_DirLock	;lock for this dirctory level
dl_FilCnt EQU	dl_DirLock
	APTR	dl_ParLevel	;ptr to parent DirLevel block
	APTR	dl_GNFib	;current FIB for GetNextFile
	APTR	dl_ChildPtr	;ptr to first (sorted) FIB entry
	APTR	dl_CurFib	;ptr to current FIB at this level
	LONG	dl_CurEnt
	LABEL	dl_SIZEOF

 STRUCTURE	Dev,0
	APTR	DevPort
	APTR	DevIOB
	APTR	DevProc
	APTR	DevVec
	APTR	DevNamePtr
	WORD	DevStLE
	WORD	DevStTE
	WORD	DevRMsgLE
	WORD	DevRMsgTE
	WORD	DevLMsgLE
	WORD	DevLMsgTE
	LONG	DevFlags
	WORD	DevUnit
	BYTE	DevSelFlg
	BYTE	DevStatus
	BYTE	DevChgFlg
	BYTE	DevMsg
	BYTE	FILLER

 STRUCTURE Menu,0
    APTR  mu_NextMenu
    WORD mu_LeftEdge
    WORD mu_TopEdge
    WORD mu_Width
    WORD mu_Height
    WORD mu_Flags
    APTR mu_MenuName
    APTR  mu_FirstItem
    WORD mu_JazzX
    WORD mu_JazzY
    WORD mu_BeatX
    WORD mu_BeatY
    LABEL mu_SIZEOF

MENUENABLED EQU $0001
MIDRAWN EQU $0100

 STRUCTURE MenuItem,0
    APTR mi_NextItem
    WORD mi_LeftEdge
    WORD mi_TopEdge
    WORD mi_Width
    WORD mi_Height
    WORD mi_Flags
    LONG mi_MutualExclude
    APTR mi_ItemFill
    APTR mi_SelectFill
    BYTE mi_Command
    BYTE mi_KludgeFill00
    APTR mi_SubItem
    WORD mi_NextSelect
    WORD mi_ROUTINE	;local addition
    LABEL  mi_SIZEOF

CHECKIT         EQU $0001
ITEMTEXT        EQU $0002
COMMSEQ         EQU $0004
MENUTOGGLE      EQU $0008
ITEMENABLED     EQU $0010
HIGHFLAGS       EQU $00C0
HIGHIMAGE       EQU $0000
HIGHCOMP        EQU $0040
HIGHBOX         EQU $0080
HIGHNONE        EQU $00C0
CHECKED         EQU $0100
ISDRAWN         EQU $1000
HIGHITEM        EQU $2000
MENUTOGGLED     EQU $4000

 STRUCTURE Gadget,0
    APTR gg_NextGadget
    WORD gg_LeftEdge
    WORD gg_TopEdge
    WORD gg_Width
    WORD gg_Height
    WORD gg_Flags
    WORD gg_Activation
    WORD gg_GadgetType
    APTR gg_GadgetRender
    APTR gg_SelectRender
    APTR gg_GadgetText
    LONG gg_MutualExclude
    APTR gg_SpecialInfo
    WORD gg_GadgetID
    APTR  gg_UserData
    LABEL gg_SIZEOF

GADGHIGHBITS    EQU $0003
GADGHCOMP       EQU $0000
GADGHBOX        EQU $0001
GADGHIMAGE      EQU $0002
GADGHNONE       EQU $0003
GADGIMAGE       EQU $0004
GRELBOTTOM      EQU $0008
GRELRIGHT       EQU $0010
GRELWIDTH       EQU $0020
GRELHEIGHT      EQU $0040
SELECTED        EQU $0080
GADGDISABLED    EQU $0100
RELVERIFY       EQU $0001
GADGIMMEDIATE   EQU $0002
ENDGADGET       EQU $0004
FOLLOWMOUSE     EQU $0008
RIGHTBORDER     EQU $0010
LEFTBORDER      EQU $0020
TOPBORDER       EQU $0040
BOTTOMBORDER    EQU $0080
TOGGLESELECT    EQU $0100
STRINGCENTER    EQU $0200
STRINGRIGHT     EQU $0400
LONGINT         EQU $0800
ALTKEYMAP       EQU $1000
BOOLEXTEND      EQU $2000
GADGETTYPE      EQU $FC00
SYSGADGET       EQU $8000
SCRGADGET       EQU $4000
GZZGADGET       EQU $2000
REQGADGET       EQU $1000
SIZING          EQU $0010
WDRAGGING       EQU $0020
SDRAGGING       EQU $0030
WUPFRONT        EQU $0040
SUPFRONT        EQU $0050
WDOWNBACK       EQU $0060
SDOWNBACK       EQU $0070
CLOSE           EQU $0080
BOOLGADGET      EQU $0001
GADGET0002      EQU $0002
PROPGADGET      EQU $0003
STRGADGET       EQU $0004

 STRUCTURE BoolInfo,0
    WORD    bi_Flags
    APTR    bi_Mask
    LONG    bi_Reserved
    LABEL   bi_SIZEOF

BOOLMASK        EQU     $0001

 STRUCTURE PropInfo,0
    WORD pi_Flags
    WORD pi_HorizPot
    WORD pi_VertPot
    WORD pi_HorizBody
    WORD pi_VertBody
    WORD pi_CWidth
    WORD pi_CHeight
    WORD pi_HPotRes
    WORD pi_VPotRes
    WORD pi_LeftBorder
    WORD pi_TopBorder
    LABEL  pi_SIZEOF

AUTOKNOB        EQU $0001
FREEHORIZ       EQU $0002
FREEVERT        EQU $0004
PROPBORDERLESS  EQU $0008
KNOBHIT         EQU $0100
KNOBHMIN        EQU 6
KNOBVMIN        EQU 4
MAXBODY         EQU $FFFF
MAXPOT          EQU $FFFF

 STRUCTURE StringInfo,0
    APTR  si_Buffer
    APTR  si_UndoBuffer
    WORD si_BufferPos
    WORD si_MaxChars
    WORD si_DispPos
    WORD si_UndoPos
    WORD si_NumChars
    WORD si_DispCount
    WORD si_CLeft
    WORD si_CTop
    APTR  si_LayerPtr
    LONG  si_LongInt
    APTR si_AltKeyMap
    LABEL si_SIZEOF

 STRUCTURE IntuiText,0
    BYTE it_FrontPen
    BYTE it_BackPen
    BYTE it_DrawMode
    BYTE it_KludgeFill00
    WORD it_LeftEdge
    WORD it_TopEdge
    APTR  it_ITextFont
    APTR it_IText
    APTR  it_NextText
    LABEL it_SIZEOF

 STRUCTURE IntuiMessage,0
    STRUCT im_ExecMessage,$14
    LONG im_Class
    WORD im_Code
    WORD im_Qualifier
    APTR im_IAddress
    WORD im_MouseX
    WORD im_MouseY
    LONG im_Seconds
    LONG im_Micros
    APTR im_IDCMPWindow
    APTR im_SpecialLink
    LABEL  im_SIZEOF

SIZEVERIFY      EQU     $00000001
NEWSIZE         EQU     $00000002
REFRESHWINDOW   EQU     $00000004
MOUSEBUTTONS    EQU     $00000008
MOUSEMOVE       EQU     $00000010
GADGETDOWN      EQU     $00000020
GADGETUP        EQU     $00000040
REQSET          EQU     $00000080
MENUPICK        EQU     $00000100
CLOSEWINDOW     EQU     $00000200
RAWKEY          EQU     $00000400
REQVERIFY       EQU     $00000800
REQCLEAR        EQU     $00001000
MENUVERIFY      EQU     $00002000
NEWPREFS        EQU     $00004000
DISKINSERTED    EQU     $00008000
DISKREMOVED     EQU     $00010000
WBENCHMESSAGE   EQU     $00020000
ACTIVEWINDOW    EQU     $00040000
INACTIVEWINDOW  EQU     $00080000
DELTAMOVE       EQU     $00100000
VANILLAKEY      EQU     $00200000
INTUITICKS      EQU     $00400000
LONELYMESSAGE   EQU     $80000000
MENUHOT         EQU     $0001
MENUCANCEL      EQU     $0002
MENUWAITING     EQU     $0003
OKOK            EQU     MENUHOT
OKABORT         EQU     $0004
OKCANCEL        EQU     MENUCANCEL
WBENCHOPEN      EQU $0001
WBENCHCLOSE     EQU $0002

 STRUCTURE Window,0
    APTR wd_NextWindow
    WORD wd_LeftEdge
    WORD wd_TopEdge
    WORD wd_Width
    WORD wd_Height
    WORD wd_MouseY
    WORD wd_MouseX
    WORD wd_MinWidth
    WORD wd_MinHeight
    WORD wd_MaxWidth
    WORD wd_MaxHeight
    LONG wd_Flags
    APTR wd_MenuStrip
    APTR wd_Title
    APTR wd_FirstRequest
    APTR wd_DMRequest
    WORD wd_ReqCount
    APTR wd_WScreen
    APTR wd_RPort
    BYTE wd_BorderLeft
    BYTE wd_BorderTop
    BYTE wd_BorderRight
    BYTE wd_BorderBottom
    APTR wd_BorderRPort
    APTR wd_FirstGadget
    APTR wd_Parent
    APTR wd_Descendant
    APTR wd_Pointer
    BYTE wd_PtrHeight
    BYTE wd_PtrWidth
    BYTE wd_XOffset
    BYTE wd_YOffset
    LONG wd_IDCMPFlags
    APTR wd_UserPort
    APTR wd_WindowPort
    APTR wd_MessageKey
    BYTE wd_DetailPen
    BYTE wd_BlockPen
    APTR wd_CheckMark
    APTR wd_ScreenTitle
    WORD wd_GZZMouseX
    WORD wd_GZZMouseY
    WORD wd_GZZWidth
    WORD wd_GZZHeight
    APTR wd_ExtData
    APTR wd_UserData
    APTR wd_WLayer
    APTR IFont
    LABEL wd_Size

WINDOWSIZING    EQU $0001
WINDOWDRAG      EQU $0002
WINDOWDEPTH     EQU $0004
WINDOWCLOSE     EQU $0008
SIZEBRIGHT      EQU $0010
SIZEBBOTTOM     EQU $0020
REFRESHBITS     EQU $00C0
SMART_REFRESH   EQU $0000
SIMPLE_REFRESH  EQU $0040
SUPER_BITMAP    EQU $0080
OTHER_REFRESH   EQU $00C0
BACKDROP        EQU $0100
REPORTMOUSE     EQU $0200
GIMMEZEROZERO   EQU $0400
BORDERLESS      EQU $0800
ACTIVATE        EQU $1000
WINDOWACTIVE    EQU $2000
INREQUEST       EQU $4000
MENUSTATE       EQU $8000
RMBTRAP         EQU $00010000
NOCAREREFRESH   EQU $00020000
WINDOWREFRESH   EQU $01000000
WBENCHWINDOW    EQU $02000000
WINDOWTICKED    EQU $04000000
SUPER_UNUSED    EQU $FCFC0000

*********************************************************
*							*
*		Mac file system offsets			*
*							*
*********************************************************

	INCLUDE	"EXEC/TYPES.I"

MaxFileGads	EQU	19		;max number of files on screen at once
ACCESS_READ	EQU	-2
MaxVolName	EQU	27
MaxFileName	EQU	31
MaxDosVolName	EQU	51

VolBufSize	EQU	2*512		;Mac volume buffer
DosBufSize	EQU	20480
MacBufSize	EQU	512

PathSize	EQU	512

ExtKeyLen	EQU	7		;FM
IdxKeyLen	EQU	37		;FM

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

* structure of catalog tree node 0.

 STRUCTURE	VolumeBlock,0
	WORD	VB_SigWord		;$D2D7 (SS) or $4244 (DS)
	LONG	VB_CDate		;creation date
	LONG	VB_MDate		;last mod
	WORD	VB_Attrib		;volume attributes
	WORD	VB_NbrFiles		;number of files in dir
	LABEL	VB_FirstDirBlk
	WORD	VB_BitMapBlk		;first block of volume bitmap
	WORD	VB_DirLen
	WORD	VB_NumAllocBlks		;max number of allocation blocks
	LONG	VB_AllocBlkSize
	LONG	VB_ClumpSize		;default clump size
	WORD	VB_FirstAlloc		;first block in bitmap
	LONG	VB_NextID		;next unused dir or file ID
	WORD	VB_FreeAllocBlks	;unused allocation blocks
	BYTE	VB_NameLen
	STRUCT	VB_Name,MaxVolName	;27
	LABEL	VB_BlockMap
	LONG	VB_BDate
	WORD	VB_SeqNbr
	LONG	VB_WrtCnt
	LONG	VB_ExtClmpSize		;clump size of extents file
	LONG	VB_CatClmpSize		;clump size of catalog file
	WORD	VB_RootDirs		;number of dirs in root
	LONG	VB_FilCnt		;number of files on volume
	LONG	VB_DirCnt		;number of dirs on volume
	STRUCT	VB_Finder,32		;Finder info
	WORD	VB_Res1
	WORD	VB_Res2
	WORD	VB_Res3
	LONG	VB_ExtSize		;size of extents tree
	STRUCT	VB_XTXRec,12		;first extent rec for extents tree
	LONG	VB_CatSize		;size of catalog tree
	STRUCT	VB_CTXRec,12		;first extent rec for cat tree
	LABEL	VB_SIZE
	
 STRUCTURE	NodeLink,0
	LONG	NL_FLink		;leaf fwd link
	LONG	NL_BLink		;leaf bwd link
	BYTE	NL_Type			;node type: 0=index, $FF=leaf, 1=base node
	BYTE	NL_Level		;index level
	WORD	NL_NbrRecs		;number of records in node
	WORD	NL_pad			;I don't know why
	LABEL	NL_SIZE

 STRUCTURE	CatKey,0
	BYTE	CK_KeyLen		;length not counting self and pad
	BYTE	CK_pad
	LONG	CK_ParID		;dir number of parent directory
	BYTE	CK_NameLen		;length of file or dir name
	LABEL	CK_Name			;variable-length name field

 STRUCTURE	BaseNode,0
	STRUCT	BN_NodeLink,NL_SIZE	;standard node linkage
	WORD	BN_TopLevel		;top index level
	LONG	BN_RootNode		;node number of root node
	LONG	BN_LeafRecs		;number of leaf RECORDS (not nodes)
	LONG	BN_FLink		;leaf forward link
	LONG	BN_BLink		;leaf backward link
	WORD	BN_NodeSize		;in bytes
	WORD	BN_IdxKeyLen		;length of index key
	LONG	BN_MaxNodes		;number of allocated nodes
	LONG	BN_FreeNodes		;number of free nodes
	LABEL	BN_SIZE			;end of node 0
	STRUCT	BN_pad,512-BN_SIZE-6	;offset to record offsets
	WORD	BN_BMOffset		;offset to node bitmap (rec2)
	WORD	BN_Rec1Offset		;offset to rec1
	WORD	BN_Rec0Offset		;offset to rec0

 STRUCTURE	FileRecord,0
	BYTE	FR_Type			;file record type = 2
	BYTE	FR_pad
	BYTE	FR_Flags		;bit 7=1 record used, bit 0=1 locked
	BYTE	FR_FileType
	LONG	FR_FinderType		;4 ASCII
	LONG	FR_FinderCreator	;4 ASCII
	WORD	FR_FinderFlags
	WORD	FR_VertPos
	WORD	FR_HorizPos
	WORD	FR_FolderID
	LONG	FR_FileNbr		;file number
	WORD	FR_DataBlk		;starting block of data fork
	LONG	FR_DataLEOF		;data fork logical EOF
	LONG	FR_DataPEOF		;data fork physical EOF
	WORD	FR_ResBlk		;starting block of resource fork
	LONG	FR_ResLEOF		;resource fork logical EOF
	LONG	FR_ResPEOF		;resource fork physical EOF
	LONG	FR_CDate		;creation date
	LONG	FR_MDate		;date of last modification
	LONG	FR_BDate		;date of last backup
	STRUCT	FR_FndrInfo,16		;more Finder info
	WORD	FR_ClumpSize		;file clump size
	STRUCT	FR_DExtRec,12		;first entent record, data fork
	STRUCT	FR_RExtRec,12		;first extent record, resource fork
	LONG	FR_Res			;reserved
	LABEL	FR_SIZE

 STRUCTURE	DirRecord,0
	BYTE	DR_Type			;directory record type = 1
	BYTE	DR_pad
	WORD	DR_Flags
	WORD	DR_Valence
	LONG	DR_DirID		;directory id number
	LONG	DR_CDate
	LONG	DR_MDate
	LONG	DR_BDate
	STRUCT	DR_UseInfo,16		;used by Finder
	STRUCT	DR_FndrInfo,16		;ditto
	STRUCT	DR_Res,16		;reserved
	LABEL	DR_SIZE

 STRUCTURE	ThreadRecord,0
	BYTE	TR_Type			;thread record type = 3
	BYTE	TR_pad
	STRUCT	TR_Res,8
	LONG	TR_ParentID		;dir number of parent directory
	BYTE	TR_NameLen		;length of name of directory
	STRUCT	TR_Name,31		;27?
	LABEL	TR_SIZE

 STRUCTURE	IndexRec,0
	BYTE	IR_KeyLen		;fixed at 37?
	BYTE	IR_pad
	LONG	IR_ParentID		;dir number of parent directory
	BYTE	IR_NameLen
	STRUCT	IR_NAME,31
	LONG	IR_NodePtr		;pointer to node in lower level
	LABEL	IR_SIZE

 STRUCTURE	FlatFile,0
	BYTE	FF_Flags		;bit 7=1 if entry used
	BYTE	FF_Type			;version number
	LONG	FF_FinderType		;4 ASCII
	LONG	FF_FinderCreator	;4 ASCII
	WORD	FF_FinderFlags
	WORD	FF_VertPos
	WORD	FF_HorizPos
	WORD	FF_FolderID
	LONG	FF_FileNbr
	WORD	FF_DataBlk		;starting block of data fork
	LONG	FF_DataLEOF		;data fork logical EOF
	LONG	FF_DataPEOF		;data fork physical EOF
	WORD	FF_ResBlk		;starting block of resource fork
	LONG	FF_ResLEOF		;resource fork logical EOF
	LONG	FF_ResPEOF		;resource fork physical EOF
	LONG	FF_CDate		;creation date
	LONG	FF_MDate		;date of last modification
	BYTE	FF_NameLen
	STRUCT	FF_NAME,MaxFileName
	LABEL	FF_SIZE

 STRUCTURE	DirFib,0
	APTR	df_Next		;link to next entry or 0
	APTR	df_Size		;file size or ptr to next level
df_SubLevel EQU	df_Size
	WORD	df_Date		;days since Jan 1, 1978 or secs since 1904
	WORD	df_Time		;mins since midnight
	LONG	df_FilNbr	;HFS file number
df_DirID EQU	df_FilNbr	;HFS dir ID if this dir
	WORD	df_FilCnt	;dir count of items 
df_ConvType EQU	df_FilCnt	;conversion type for selected file
	BYTE	df_Flags	;DIR (7), SELECTED (6)
	BYTE	df_NameLen	;length of name in bytes
	STRUCT	df_Name,32	;31-char file name plus 1 null term
	LABEL	df_SIZEOF

 STRUCTURE	DirLevel,0
	LONG	dl_DirLock	;lock for this dirctory level
dl_FilCnt EQU	dl_DirLock
	APTR	dl_ParLevel	;ptr to parent DirLevel block
	APTR	dl_LevFib	;current FIB for par/lower level
dl_DirID EQU	dl_LevFib	;dir id of all items at this level
	APTR	dl_ChildPtr	;ptr to first (sorted) FIB entry
	APTR	dl_CurFib	;ptr to first FIB for dir file display
	APTR	dl_ScanPtr	;working ptr for scanning level
	LONG	dl_CurEnt
	LABEL	dl_SIZEOF

 STRUCTURE OptionsRecord,0
	BYTE	so_ConvFlag
	BYTE	so_AmyIcon
	BYTE	so_AskMac
	BYTE	so_AskAmy
	BYTE	so_AutoRep
	BYTE	so_HiRes
	BYTE	so_Pad2
	BYTE	so_Pad3
	LABEL	so_TypeTbl
	STRUCT	so_NCType,5
	STRUCT	so_NCCreator,5
;	STRUCT	so_MBType,5
;	STRUCT	so_MBCreator,5
	STRUCT	so_ASType,5
	STRUCT	so_ASCreator,5
	STRUCT	so_PSType,5
	STRUCT	so_PSCreator,5
	STRUCT	so_MPType,5
	STRUCT	so_MPCreator,5
	LABEL	so_ToolTbl
	STRUCT	so_NCTool,64
;	STRUCT	so_MBTool,64
	STRUCT	so_ASTool,64
	STRUCT	so_PSTool,64
	STRUCT	so_MPTool,64
	LABEL	so_SizeOf


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
WBENCHOPEN      EQU 	$0001
WBENCHCLOSE     EQU 	$0002

REQ_WD	EQU	280	;STANDARD REQ WIDTH
REQ_HT	EQU	60	;STANDARD REQ HEIGHT

IM_DATA	EQU	10

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


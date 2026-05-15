*****************************************************************
*								*
*			Mac-2-Dos				*
*								*
*	The Mac to/from Amiga file conversion utility.		*
*								*
*	Copyright (c) 1989 Central Coast Software		*
*	424 Vista Avenue, Golden, CO 80401			*
*	     All rights reserved, worldwide			*
*								*
*****************************************************************

DEMO	EQU	0

;	INCLUDE	"MAC.I"	
;	INCLUDE	"VD0:MACROS.ASM"
	INCLUDE "PRE.OBJ"
	INCLUDE	"BOXES.ASM"

	XDEF	MainEx1
	XDEF	AboutM2D
	XDEF	SaveOptions,LoadOptions
	XDEF	AutoReplace,AmyIcon
	XDEF	MacFileType,AmyToolType
	XDEF	HiResFlg
	XDEF	EditDefaults,EditGadHit
	XDEF	ESaveHit,EUseHit,ECanHit
;	XDEF	FileInfo
	XDEF	AmyRes,LowRes,HiRes
	XDEF	WaitForMsg,CheckForMsg,ProcessMsg
	XDEF	DisableMenu,EnableMenu			;gec 1/23/90

	XDEF	_SysBase,SysBase,DosBase,IntuitionBase
	XDEF	GraphicsBase,IconBase
	XDEF	FontPtr,MacTask
	XDEF	WINDOW
	XDEF	GAD_PTR,MSG_CLASS,MSG_CODE
	XDEF	RefreshRoutine,RefreshDirWind
	XDEF	OptionsBuffer
	XDEF	AskAmyFlg,AskMacFlg
	XDEF	AutoRepFlg,AmyIconFlg

*	gadget routines

	XDEF	DUMMY

* EXTERNALS IN GADGETS.ASM

	XREF	WINI,WinBox
	XREF	GadgetList
;	XREF	ABUF
	XREF	BOX_TABLE
	XREF	T80
	XREF	G_APAR,G_AROOT
	XREF	G_MPAR,G_MROOT
	XREF	AboutTxt
	XREF	NCTypeInfo
	XREF	NCCreatorInfo
	XREF	NCToolInfo 
	XREF	ASTypeInfo 
	XREF	ASCreatorInfo
	XREF	ASToolInfo
	XREF	PSTypeInfo
	XREF	PSCreatorInfo
	XREF	PSToolInfo
	XREF	MPTypeInfo
	XREF	MPCreatorInfo
	XREF	MPToolInfo
	XREF	EditGads
	XREF	ESaveGad,EUseGad,ECanGad

* EXTERNALS IN WIND

	XREF	BuildMacDir,BuildDosDir
	XREF	UpdLWinFlg,UpdRWinFlg
	XREF	ScrollLeftWindow,ScrollRightWindow
	XREF	NoMacDisk
	XREF	UpdateMacWindow,UpdateDosWindow
	XREF	UpdateMacPath
	XREF	UpdateMacVol
	XREF	UpdateDosPath
	XREF	UpdateMacSpace
	XREF	UpdateDosSpace

* Externals in DosFiles, MacFiles

	XREF	FreeBuffers,FreeMacDirBlocks,FreeDosDirBlocks
	XREF	ChgOrigDir
	XREF	DosVolName.

* Externals in CMDS.ASM

	XREF	ConvFlag
;	XREF	LoadConvParams

* EXTERNALS IN DISK

	XREF	OpenMacDrive,CloseMacDrive,MotorOff
	XREF	DiskChanged
;	XREF	DiskChgFlag
	XREF	GetDriveStatus
	XREF	Eject

* EXTERNALS IN FUN

	XREF	MOVE_CHARS,PRINT_WIN,DISP_WIN
	XREF	CLEAR_BOX
	XREF	ClearWindow
	XREF	AddGadgets,RemoveGadgets
	XREF	RefreshWindow
	XREF	ReqOkay

* EXTERNALS IN BUFFER

	XREF	LINBUF,VolBuf
	XREF	GTLIST,CPLST1,CPLST2

* Externals in MENU

	XREF	MacMenuStrip
	XREF	FCONV_ITEMS
	XREF	OPT_ITEMS
	XREF	RES_ITEMS
	XREF	NCtxt.,AStxt.,PStxt.,MPtxt.

* externals in Version.asm

	XREF	ProgName.

* Externals in NDCMD.asm

	XREF	SetClickDelay


LibVer		EQU	33		;AmigaDOS V1.2 required
TaskPort	EQU	$5C		;OFFSET TO TASK PORT IN TASK CONTROL BLOCK
MP_MSGLIST	EQU	$14		
MP_SIGBIT	EQU	$F		;signal bit number in msg port
CheckMask	EQU	$FEFF		;
MenuNbr		EQU	$7E0		;all menu items		;gec 1/23/90
MaxMenus	EQU	6		;number of menus	;gec 1/23/90

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
    LONG mi_ROUTINE	;local addition
    LABEL  mi_SIZEOF

GO:
	MOVE.L  A7,initialSP		;initial task stack pointer
	MOVEA.L 4,A6
	MOVE.L  A6,SysBase
	LEA     DosName,A1
	MOVEQ   #LibVer,D0
	CALLSYS	OpenLibrary		;OPEN DOS LIBRARY
	MOVE.L  D0,DosBase
	BEQ	Abort
	SUB.L	A1,A1			;find this task
	CALLSYS	FindTask
	MOVE.L	D0,MacTask		;save ptr to our task
	MOVEA.L D0,A4
	TST.L   $AC(A4)			;invoked from cli?
	BNE.S	fromCLI
fromWBench:
;	CALLSYS	Debug
	LEA     TaskPort(A4),A0
	CALLSYS	WaitPort
	LEA     TaskPort(A4),A0
	CALLSYS	GetMsg
	MOVE.L	D0,WBenchMsg		;save WBench msg for reply
	MOVE.L	D0,A2
	MOVE.L	36(A2),D0		;GET PARAM LIST
	BEQ.S	fromCLI
	MOVE.L	D0,A0
	MOVE.L	(A0),D1			;GET BPTR TO LOCK
	CALLSYS	CurrentDir,DosBase
fromCLI:
	LEA	GraphicsName,A1
	MOVEQ   #LibVer,D0
	CALLSYS	OpenLibrary,SysBase		;OPEN GRAPHICS LIBRARY
	MOVE.L	D0,GraphicsBase
	BEQ	Abort
	LEA	IntuitionName,A1
	MOVEQ   #LibVer,D0
	CALLSYS	OpenLibrary
	MOVE.L	D0,IntuitionBase
	BEQ	Abort
	LEA	IconName,A1
	MOVEQ   #LibVer,D0
	CALLSYS	OpenLibrary
	MOVE.L	D0,IconBase
	BEQ	Abort
	LEA	T80,A0
	CALLSYS	OpenFont,GraphicsBase	;open Topaz 80
	MOVE.L	D0,FontPtr		;save ptr to this font
	BEQ	Abort

MAIN:	BSR	OpenWindow		;open our window
	MOVE.L	#RefreshDirWind,RefreshRoutine
	BSR	RefreshDirWind
	LEA	GadgetList,A0		;main screen gadgets
	BSR	AddGadgets
	BSR	OpenMacDrive
	NOERROR	3$			;ok
	DispErr	NoMacDrv.
	BRA	MainEx2
3$:	BSR	LoadOptions
	BSR	GetDriveStatus		;disk loaded?
	IFZL	D0,1$			;yes...build dir
	BSR	NoMacDisk
	BRA.S	2$
1$:	BSR	BuildMacDir		;else load root dir
2$:	CLR.B	DosVolName.		;start with current Dos dir
	BSR	BuildDosDir		;display current ADOS dir
	MOVE.L	WINDOW,A5
	MOVE.L	wd_UserPort(A5),A0
	ZAP	D0
	MOVE.B	MP_SIGBIT(A0),D1	;signal bit number=number to shift
	BSET	D1,D0			;this is IDCMP signal
	MOVE.L	D0,IDCMPMask
	ZAP	D0
	MOVEQ	#9,D1			;from NDCMD inittable
	BSET	D1,D0
	MOVE.L	D0,TimerMask
	BSR	SetClickDelay		;kick off the 0.5-sec timer
MsgLoop:
	BSR	WaitForMsg		;wait for input
	NOERROR	MsgLoop			;terminate the program

* Operator wants to exit...clean up and go home

MainEx1:
	BSR	Eject			;dump the Mac disk
	MOVE.L	TimerMask,D0		;wait for final timer tick
	CALLSYS	Wait,SysBase		;wait for msg or timeout
	BSR	CloseMacDrive		;free driver resources
	BSR	FreeMacDirBlocks	;release Mac directory blocks
	BSR	FreeDosDirBlocks	;release Dos directory blocks
	BSR	FreeBuffers		;release other buffers
	BSR	FreeOptionsBuf		;and this one too
	BSR	ChgOrigDir		;back to where we started
MainEx2:
	BSR	CloseWindow		;watch out for IDCMP msgs
	ZAP	D0			;good return code
	BRA	ExitToDos

Abort:	MOVEQ   #$64,D0			;non-zero return code

ExitToDos:
	MOVEA.L initialSP,A7
	PUSH	D0			;SAVE RETURN CODE
	MOVEA.L SysBase,A6
	MOVE.L  DosBase,D0
	BEQ.S   1$
	MOVEA.L D0,A1
	CALLSYS	CloseLibrary		;CLOSE THE LIBRARIES
1$:	MOVE.L	GraphicsBase,D0
	BEQ.S	2$
	MOVEA.L	D0,A1
	CALLSYS	CloseLibrary
2$:	MOVE.L	IntuitionBase,D0
	BEQ.S	3$
	MOVEA.L	D0,A1
	CALLSYS	CloseLibrary
3$:	TST.L   WBenchMsg
	BEQ.S   4$
	CALLSYS	Forbid
	MOVEA.L WBenchMsg,A1
	CALLSYS	ReplyMsg
4$:	POP	D0			;RETURN CODE
	RTS

DUMMY:	RTS


* Waits at IDCMP msg port for a msg.  Saves msg class, code, and gadget ptr,
* then replies msg.  Returns msg class in D0.  Handles
* refresh requests.  Returns CY=1 on CloseWindow request.

WaitForMsg:
1$:	BSR	CheckForMsg		;got a msg?
	RTSERR				;op want to bail out
	IFNZL	D0,ProcessMsg		;got msg...process it
	IFZB	UpdLWinFlg,3$		;else housekeeping before wait
	BSR	ScrollLeftWindow
3$:	IFZB	UpdRWinFlg,4$
	BSR	ScrollRightWindow
4$:	MOVE.L	TimerMask,D0		;load signal bits we want
	OR.L	IDCMPMask,D0
	CALLSYS	Wait,SysBase		;wait for msg or timeout
	AND.L	TimerMask,D0		;timeout?
	BEQ.S	1$			;no...look for a msg
	BSR	DiskChanged		;check for disk event
	BSR	SetClickDelay		;restart the timer
	BRA.S	1$			;check for incoming msg

* Come here to process a msg when it is received.

ProcessMsg:
	MOVE.L	MSG_CLASS,D0
	IFEQIB	D0,#GADGETDOWN,1$	;gadget hit?
	IFNEIB	D0,#GADGETUP,2$		;not gadget...maybe mouse?
1$:	MOVE.L	GAD_PTR,A0		;ptr to gadget
	MOVE.L	gg_UserData(A0),A6	;proper routine for this gadget
	JSR	(A6)			;and away we go...
	BRA	9$

2$:	IFNEIB	D0,#MOUSEMOVE,4$	;not mouse action
	IFGEIW	MouseX,#400,3$
	SETF	UpdLWinFlg
	BRA.S	9$
3$:	SETF	UpdRWinFlg
	BRA.S	9$

4$:	IFNEIW	D0,#MENUPICK,9$		;not menu

	MOVE.W	MSG_CODE,D0		;MENU NUMBER TO D0
5$:	LEA	MacMenuStrip,A0
	CALLSYS	ItemAddress,IntuitionBase
	IFZL	D0,9$			;NULL...NO MENU SELECTED
	MOVE.L	D0,A0			;POINT TO MENUITEM
	MOVE.L	A0,MenuPtr		;SAVE PTR TO THIS MENUITEM
	MOVE.L	mi_ROUTINE(A0),A6	;GET ADDRESS OF MENU ROUTINE
	JSR	(A6)			;PROCESS THIS MENU ITEM
	MOVE.L	MenuPtr,A0		;RESTORE PTR TO LAST MENU ITEM
	MOVE.W	mi_NextSelect(A0),D0	;CHECK FOR EXTENDED SELECT
	BRA.S	5$			;TRY NEXT

9$:	CLC
	RTS

* Come here to check for a msg and process it, if any.
* Returns CY=1 on close gadget.

CheckForMsg:
1$:	MOVEA.L	WINDOW,A0
	MOVE.L	wd_UserPort(A0),A0
	CALLSYS	GetMsg,SysBase		;GET IDCMP MSG, if any
	IFNZL	D0,2$			;got one, process it
	RTS				;got none
2$:	MOVE.L	D0,A1
	MOVE.L	im_Class(A1),MSG_CLASS	;SAVE MSG CLASS
	MOVE.W	im_Code(A1),MSG_CODE
	MOVE.L	im_IAddress(A1),GAD_PTR	;SAVE PTR TO POSSIBLE GADGET
	MOVE.W	im_MouseX(A1),MouseX	;save possible mouse position
	CALLSYS	ReplyMsg,SysBase	;LET INTUITION KNOW WE HAVE IT
	MOVE.L	MSG_CLASS,D0
	CMP.L	#CLOSEWINDOW,D0		;TERMINATE PROGRAM?
	BNE.S	3$			;EXIT PROGRAM IMMEDIATELY
	STC
	RTS
3$:	CMP.L	#REFRESHWINDOW,D0	;REFRESH REQUEST?
	BNE.S	9$			;no...process normal request
	BSR	RefreshWindow
	BRA	1$
9$:	CLC
	RTS

* Opens Mac-2-Dos window

OpenWindow:
	LEA	ScnData,A0		;screen data goes here
	MOVEQ	#16,D0			;16 bytes of screen data only
	MOVEQ	#1,D1			;workbench screen
	CALLSYS	GetScreenData,IntuitionBase
	IFZL	D0,8$			;oops...problem...bail out
	LEA	NewWindow,A0		;this is our window
	LEA	WinBox,A1		;window size variables
	LEA	WINI,A2
	MOVEQ	#2,D0			;Win_LE
	MOVE.W	D0,(A1)+
	MOVE.W	D0,(A2)+
	MOVEQ	#10,D0			;Win_TE
	MOVE.W	D0,(A1)+
	MOVE.W	D0,(A2)+
	MOVE.W	ScnData+12,D0
	MOVE.W	D0,4(A0)		;width of new window
	SUBQ	#4,D0
	MOVE.W	D0,(A1)+		;Win_WD
	MOVE.W	D0,(A2)+
	MOVE.W	ScnData+14,D0
	MOVE.W	D0,6(A0)		;height of new window
1$:	SUB.W	#11,D0
	MOVE.W	D0,(A1)+		;Win_HT
	MOVE.W	D0,(A2)+
	CALLSYS	OpenWindow,IntuitionBase
	MOVE.L	D0,WINDOW		;SAVE PTR TO WINDOW STRUCTURE
	BEQ	8$
	MOVE.L	D0,A0
	LEA	MacMenuStrip,A1
	CALLSYS	SetMenuStrip
	CLC
	RTS
8$:	STC
	RTS

* Closes Mac-2-Dos window safely.

CloseWindow:
	PUSH	A3-A4
	MOVE.L	WINDOW,A4
	CALLSYS	Forbid,SysBase		;Don't let Intuition run now
	MOVE.L	wd_UserPort(A4),A3
	ADD.L	#MP_MSGLIST,A3		;point to head cell in list
1$:	MOVE.L	(A3),A3
	IFZL	A3,3$			;NO MORE MSGS IN USER PORT
	IFNEL	im_IDCMPWindow(A3),A4,1$
	MOVE.L	A3,A1			;ELSE GET RID OF THIS MSG
	CALLSYS	Remove,SysBase	
	MOVE.L	A3,A1
	CALLSYS	ReplyMsg
	BRA.S	1$			;Loop for all msgs
3$:	MOVE.L	A4,A0
	CLR.L	wd_UserPort(A0)		;ZAP USER PORT FOR INTUITION
	ZAP	D0
	CALLSYS	ModifyIDCMP,IntuitionBase ;no more msgs
	CALLSYS	Permit,SysBase		;OKAY FOR TASK SWAP NOW
	MOVE.L	A4,A0
	CALLSYS	CloseWindow,IntuitionBase
	POP	A3-A4
	RTS


DRAW_BOXES:
	LEA	BOX_TABLE,A4	;WORK THE BOX TABLE
1$:	MOVE.L	(A4)+,D0	;GET LE, TE
	BEQ.S	9$		;DONE
	MOVE.L	(A4)+,D1	;GET WD, HT
	MOVE.W	(A4)+,D2	;PEN COLORS
	PUSH	D0-D2		;SAVE PARAMS
	SWAB	D2
	BSR	CLEAR_BOX	;CLEAR IT TO BORDER COLOR
	POP	D0-D2
	ADD.L	#$20001,D0	;MOVE OVER BY 2, DOWN BY 1
	SUB.L	#$40002,D1	;REDUCE WIDTH BY 4, HT BY 2
	BSR	CLEAR_BOX	;CLEAR INSIDES TO PROPER COLOR
	BRA.S	1$
9$:	RTS

RefreshDirWind:
	BSR	ClearWindow
	DispMsg	#AVOL_LE,#AVOL_TE,Dos.
	DispMsg	#MVOL_LE,#MVOL_TE,Mac.
	GadColor G_APAR,ORANGE
	GadColor G_AROOT,ORANGE
	GadColor G_MPAR,ORANGE
	GadColor G_MROOT,ORANGE
	BSR	DRAW_BOXES		;PUT UP VARIOUS BOXES
	BSR	UpdateMacWindow
	BSR	UpdateDosWindow
	BSR	UpdateMacVol
	BSR	UpdateMacPath
	BSR	UpdateDosPath
	BSR	UpdateMacSpace
	BSR	UpdateDosSpace
	RTS

ACTIVATE_GADGET:
	MOVE.L	WINDOW,A1
	ZAPA	A2
	CALLSYS	ActivateGadget,IntuitionBase
	RTS

* Loads options from options file, the closes it.

LoadOptions:
	PUSH	D2-D5/A2-A3
	IFNZL	OptionsBuffer,1$,L		;already have buffer
	MOVE.L	#so_SizeOf,D0			;else get one now
	MOVE.L	#$10000,D1			;MEMF_CLEAR
	CALLSYS	AllocMem,SysBase
	MOVE.L	D0,OptionsBuffer
	BEQ	9$				;didn't get one...
	MOVE.L	D0,A3
	LEA	so_NCType(A3),A2		;else init info ptrs
	MOVE.L	A2,NCTypeInfo
	LEA	so_NCCreator(A3),A2
	MOVE.L	A2,NCCreatorInfo
	LEA	so_NCTool(A3),A2
	MOVE.L	A2,NCToolInfo
	LEA	so_ASType(A3),A2
	MOVE.L	A2,ASTypeInfo
	LEA	so_ASCreator(A3),A2
	MOVE.L	A2,ASCreatorInfo
	LEA	so_ASTool(A3),A2
	MOVE.L	A2,ASToolInfo
	LEA	so_PSType(A3),A2
	MOVE.L	A2,PSTypeInfo
	LEA	so_PSCreator(A3),A2
	MOVE.L	A2,PSCreatorInfo
	LEA	so_PSTool(A3),A2
	MOVE.L	A2,PSToolInfo
	LEA	so_MPType(A3),A2
	MOVE.L	A2,MPTypeInfo
	LEA	so_MPCreator(A3),A2
	MOVE.L	A2,MPCreatorInfo
	LEA	so_MPTool(A3),A2
	MOVE.L	A2,MPToolInfo
1$:	MOVE.L	#Options.,D1		;name of options file
	MOVE.L	#EXISTING,D2		;read in existing options, if any
	CALLSYS	Open,DosBase		;try to open it
	MOVE.L	D0,D5			;save handle for close
	BNE.S	4$			;got it
	LEA	DefaultOptions,A0
	MOVE.L	OptionsBuffer,A1
	MOVE.W	#so_SizeOf-1,D0		;this many
5$:	MOVE.B	(A0)+,(A1)+
	DBF	D0,5$
	BRA.S	6$
4$:	MOVE.L	D5,D1
	MOVE.L	OptionsBuffer,D2	;they are stored here
	MOVE.L	#so_SizeOf,D3		;this many
	CALLSYS	Read			;do it
	MOVE.L	D5,D1
	CALLSYS	Close
6$:	MOVE.L	OptionsBuffer,A3
	MOVE.B	(A3)+,D0		;conversion flag
	MOVE.B	D0,ConvFlag		;update conversion flag
	ZAP	D2
	LEA	FCONV_ITEMS,A2		;work the conversion items menu
3$:	MOVE.W	mi_Flags(A2),D1
	AND.W	#CheckMask,D1
	IFNEB	D2,D0,2$		;don't check this one
	OR.W	#$100,D1		;else this is item to check
2$:	MOVE.W	D1,mi_Flags(A2)		;set or clear check, as needed
	INCW	D2
	MOVE.L	mi_NextItem(A2),A2	;point to next menu item
	IFNZL	A2,3$			;loop till end of list	
	LEA	OPT_ITEMS,A2
	MOVE.B	(A3)+,D0
	MOVE.B	D0,AmyIconFlg
	BSR	SetCheckMark
	MOVE.B	(A3)+,D0
	MOVE.B	D0,AskAmyFlg
	BSR	SetCheckMark
	MOVE.B	(A3)+,D0
	MOVE.B	D0,AskMacFlg
	BSR	SetCheckMark
	MOVE.B	(A3)+,D0
	MOVE.B	D0,AutoRepFlg
	BSR	SetCheckMark
	MOVE.B	(A3)+,D0		;1=hires
	MOVE.B	D0,HiResFlg
	LEA	RES_ITEMS,A2
	BCHG	#0,D0			;reverse state
	BSR	SetCheckMark
	BCHG	#0,D0			;reverse again
	BSR	SetCheckMark
;	BSR	LoadConvParams
9$:	POP	D2-D5/A2-A3
	RTS

SetCheckMark:
1$:	MOVE.W	mi_Flags(A2),D1
	AND.W	#CheckMask,D1
	IFZB	D0,2$			;don't check this one
	OR.W	#$100,D1		;else set checkmark
2$:	MOVE.W	D1,mi_Flags(A2)		;set or clear check, as needed
	MOVE.L	mi_NextItem(A2),A2
	RTS

SaveOptions:
	PUSH	D5
	MOVE.L	OptionsBuffer,A0	;load current flag params
	MOVE.B	ConvFlag,(A0)+
	MOVE.B	AmyIconFlg,(A0)+
	MOVE.B	AskAmyFlg,(A0)+
	MOVE.B	AskMacFlg,(A0)+
	MOVE.B	AutoRepFlg,(A0)+
	MOVE.B	HiResFlg,(A0)+
	MOVE.L	#Options.,D1		;name of param file
	MOVE.L	#NEW,D2			;write out a new version
	CALLSYS	Open,DosBase		;try to open it
	MOVE.L	D0,D5			;handle for write
	BEQ.S	9$			;oops...open failed
	MOVE.L	D5,D1
	MOVE.L	OptionsBuffer,D2	;they are stored here
	MOVE.L	#so_SizeOf,D3		;this many
	CALLSYS	Write			;do it
	MOVE.L	D5,D1
	CALLSYS	Close
9$:	POP	D5
	RTS

FreeOptionsBuf:
	MOVE.L	OptionsBuffer,D0
	BEQ.S	1$
	MOVE.L	D0,A1
	MOVE.L	#so_SizeOf,D0
	CALLSYS	FreeMem,SysBase
	CLR.L	OptionsBuffer
1$:	RTS

AboutM2D:
	LEA	AboutTxt,A0
	BRA	ReqOkay

* Allows editing of default file type/creator and default tool names.

EditDefaults:
	BSR	OpenEditWind
	RTS

EditGadHit:
	RTS

ESaveHit:
	BSR	SaveOptions
EUseHit:
ECanHit:
	BSR	CloseEditWind
	RTS

OpenEditWind:
	BSR	DisableMenu				;gec 1/23/90
	LEA	GadgetList,A0
	BSR	RemoveGadgets
	MOVE.L	#RefreshEditWind,RefreshRoutine
	BSR	RefreshEditWind
	LEA	EditGads,A0
	BSR	AddGadgets
	RTS

CloseEditWind:
	LEA	EditGads,A0
	BSR	RemoveGadgets
	MOVE.L	#RefreshDirWind,RefreshRoutine
	BSR	RefreshDirWind
	LEA	GadgetList,A0
	BSR	AddGadgets
	BSR	EnableMenu				;gec 1/23/90
	RTS

Title_LE	EQU	256
Title_TE	EQU	22

RefreshEditWind:
	BSR	ClearWindow
	DispCent #320,#Title_TE,EditTitle.
	DispMsg	#TypeCol_LE-8,#TypeCol_TE,Type.
	DispMsg	#CreatorCol_LE-4,#CreatorCol_TE,Creator.
	DispMsg	#ToolCol_LE,#ToolCol_TE,ToolName.
	DispMsg	#FirstConv_LE,#NCType_TE,NCtxt.
	DispMsg	#FirstConv_LE,#ASType_TE,AStxt.
	DispMsg	#FirstConv_LE,#PSType_TE,PStxt.
	DispMsg	#FirstConv_LE,#MPType_TE,MPtxt.
	GadColor ESaveGad,WHITE
	GadColor EUseGad,WHITE
	GadColor ECanGad,ORANGE
	RTS

AutoReplace:
	BCHG	#0,AutoRepFlg
	RTS

AmyIcon:
	BCHG	#0,AmyIconFlg
	RTS

MacFileType:
	BCHG	#0,AskMacFlg
	RTS

AmyToolType:
	BCHG	#0,AskAmyFlg
	RTS

HiRes:	BSET	#0,HiResFlg
AmyRes:	RTS
LowRes:	BCLR	#0,HiResFlg
	RTS

* Routines to enable/disable the menu bar.  Added 1/23/90

DisableMenu:
	PUSH	D2-D3
	MOVE.L	#MenuNbr,D3
	MOVEQ	#MaxMenus-1,D2
1$:	MOVE.L	D3,D0
	MOVE.L	WINDOW,A0
	CALLSYS	OffMenu,IntuitionBase
	INCL	D3
	DBF	D2,1$
	POP	D2-D3
	RTS

EnableMenu:
	PUSH	D2-D3
	MOVE.L	#MenuNbr,D3
	MOVEQ	#MaxMenus-1,D2
1$:	MOVE.L	D3,D0
	MOVE.L	WINDOW,A0
	CALLSYS	OnMenu,IntuitionBase
	INCL	D3
	DBF	D2,1$
	POP	D2-D3
	RTS

_SysBase
SysBase		DC.L	0
DosBase		DC.L	0
GraphicsBase	DC.L	0
IntuitionBase	DC.L	0
IconBase	DC.L	0
WBenchMsg	DC.L	0		;0 IF CLI, <>0 IF WORKBENCH
initialSP	DC.L	0
MacTask		DC.L	0
WINDOW		DC.L	0		;OUR OWN WINDOW
MSG_CLASS	DC.L	0		;IDCMP MSG CLASS
GAD_PTR		DC.L	0		;POINTER TO SELECTED GADGET
FontPtr		DC.L	0		;ptr to Topaz 80 font
MenuPtr		DC.L	0		;ptr to next selected menu item
RefreshRoutine	DC.L	0		;routine to call for window refresh
OptionsBuffer	DC.L	0		;ptr to options
ScnData		DC.L	0,0,0,0		;16 bytes of screen data
TimerMask	DC.L	0
IDCMPMask	DC.L	0
MSG_CODE	DC.W	0		;IDCMP MSG CODE
MouseX		DC.W	0		;mouse pos
AmyIconFlg	DC.B	1		;1=create icon file
AskAmyFlg	DC.B	1		;1=ask default tool
AskMacFlg	DC.B	1		;1=ask file type/creator
AutoRepFlg	DC.B	0		;1=dont ask, just replace
HiResFlg	DC.B	0		;1=hi res (640x400)

DosName		TEXTZ	'dos.library'
GraphicsName	TEXTZ	'graphics.library'
IntuitionName	TEXTZ	'intuition.library'
IconName	TEXTZ	'icon.library'
Mac.		TEXTZ	<'Mac volume: '>
Dos.		TEXTZ	<'Amiga volume: '>
EditTitle.	TEXTZ	<'Edit File type/creator and Default tool names'>
Options.	TEXTZ	<'S:M2D.OPT'>
Type.		TEXTZ	<'Mac Type'>
Creator.	TEXTZ	<'Creator'>
ToolName.	TEXTZ	<'Amiga Default Tool Name'>
NoMacDrv.	TEXTZ	<'Can''t find Mac disk drive...quitting'>

* WINDOW DEFINITION

	CNOP	0,4

NewWindow
NW_LE	DC.W	0		;Ledt edge
NW_TE	DC.W	0		;Top edge
NW_WD	DC.W	640		;Width
NW_HT	DC.W	200		;Height
	DC.B	BLUE,WHITE	;DetailPen, BlockPen
NW_IDCMP DC.L	$3E4		;CLOSEWIN, GADUP, GADDN, MENUPICK, REQSET
NW_FLAGS DC.L	$100F		;Flags - DEPTH+CLOSE GADGETS, ACTIVATE
	DC.L	0		;FirstGadget (CUSTOM)
	DC.L	0		;CheckMark=DEFAULT
NW_TITLE DC.L	ProgName. 	;Title  
	DC.L	0		;NO CUSTOM Screen
	DC.L	0		;NO CUSTOM BitMap
	DC.W	200,60		;MinWidth, MinHeight
	DC.W	999,999		;MaxWidth, MaxHeight
	DC.W	1		;WORKBENCH TYPE

DefaultOptions
	DC.L	$00010101,$00010000,$57504443,$00535349
	DC.L	$57005445,$5854004D,$41434100,$54455854
	DC.L	$004D4143,$4100504E,$5447004D,$504E5400
	DC.L	$3A575000,$20202020,$20202020,$20202020
	DC.L	$20202020,$20202020,$20202020,$20202000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$5359533A,$5554696C,$69746965,$732F4E4F
	DC.L	$54455041,$44002020,$20202020,$20202000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$5359533A,$5574696C,$69746965,$732F4E4F
	DC.L	$54455041,$44002020,$20202020,$20202000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$3A647061,$696E7478,$00202020,$20202020
	DC.L	$20202020,$20202020,$20202020,$20202000
	DC.L	$00000000,$00000000,$00000000,$00000000
	DC.L	$00000000,$00000000,$00000000,$00000000

	END

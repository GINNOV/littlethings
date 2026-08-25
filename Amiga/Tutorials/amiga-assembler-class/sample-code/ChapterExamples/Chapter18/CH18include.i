; CH18include.i - this include file contains the definitions which allow 
; you to assemble the chapter 18 example without requiring the official 
; Amiga system include files!


LINKLIB     MACRO   ; requires functionOffset and libraryBase parameters
	IFGT NARG-2
	    FAIL    ; fail if wrong number of arguments are provided!
	ENDC
	    MOVE.L  A6,-(SP)
	    MOVE.L  \2,A6
	    JSR     \1(A6)
	    MOVE.L  (SP)+,A6
	    ENDM



NM_TITLE		EQU	   1

NM_ITEM			EQU	   2

NM_END			EQU	   0

IDCMP_MENUPICK		EQU     $00000100

MENUNULL		EQU	$FFFFFFFF
		
IDCMP_CLOSEWINDOW	EQU     $00000200
		
im_Class		EQU	 $14

im_Code			EQU	 $18

wd_UserPort		EQU	 $56

wd_RPort		EQU	 $32

TAG_DONE		EQU	   0

TAG_END			EQU	   0

WA_BASE			EQU 	$80000063
WA_Left			EQU	WA_BASE+$01
WA_Top			EQU	WA_BASE+$02
WA_Width		EQU	WA_BASE+$03
WA_Height		EQU	WA_BASE+$04
WA_IDCMP		EQU	WA_BASE+$07
WA_Gadgets		EQU	WA_BASE+$09
WA_Title		EQU	WA_BASE+$0B
WA_MinWidth  		EQU	WA_BASE+$0F
WA_MaxWidth 		EQU	WA_BASE+$11
WA_MinHeight 		EQU	WA_BASE+$10
WA_MaxHeight		EQU	WA_BASE+$12
WA_SizeGadget 		EQU	WA_BASE+$1E
WA_DragBar		EQU	WA_BASE+$1F
WA_PubScreen		EQU	WA_BASE+$16
WA_DepthGadget 		EQU	WA_BASE+$20
WA_CloseGadget 		EQU	WA_BASE+$21


MODE_OLDFILE		EQU	1005

MEMF_ANY		EQU	   0

DOS_FIB			EQU	   2

fib_Size		EQU	 124

rf_File			EQU	   4

rf_Dir			EQU	   8

TEXT_KIND		EQU	  13

gng_TopEdge		EQU	   2

gng_VisualInfo		EQU	  22

gng_GadgetText		EQU	   8

RP_JAM1			EQU	   0

RP_JAM2			EQU	   1

PLACETEXT_IN		EQU	 $10

GTTX_Border		EQU	$80080039


_LVOOpenLibrary		EQU	-552

_LVOCloseLibrary	EQU	-414

_LVODisplayBeep		EQU	 -96

_LVOLockPubScreen	EQU	-510

_LVOUnlockPubScreen	EQU	-516

_LVOOpenWindowTagList	EQU	-606

_LVOCloseWindow		EQU	 -72

_LVOWaitPort		EQU	-384

_LVOGetMsg		EQU	-372

_LVOReplyMsg		EQU	-378

_LVOGetVisualInfoA	EQU	-126

_LVOFreeVisualInfo	EQU	-132

_LVOCreateMenusA	EQU	 -48

_LVOFreeMenus		EQU	 -54

_LVOLayoutMenusA	EQU	 -66

_LVOSetMenuStrip	EQU	-264

_LVOClearMenuStrip	EQU	 -54

_LVOAllocFileRequest	EQU	 -30

_LVOFreeFileRequest	EQU	 -36

_LVOAslRequest		EQU	 -60

_LVOExamineFH		EQU	-390

_LVOAllocMem		EQU	-198

_LVOFreeMem		EQU	-210

_LVOOpen		EQU	 -30

_LVOClose		EQU	 -36

_LVOAllocDosObject	EQU	-228

_LVOFreeDosObject	EQU	-234

_LVORead		EQU	 -42

_LVOAddPart		EQU	-882

_LVOCreateContext	EQU	-114

_LVOCreateGadgetA	EQU	-30

_LVOFreeGadgets		EQU	-36

_LVOGT_RefreshWindow	EQU	-84

_LVOPrintIText		EQU	-216

_LVORawDoFmt		EQU	-522

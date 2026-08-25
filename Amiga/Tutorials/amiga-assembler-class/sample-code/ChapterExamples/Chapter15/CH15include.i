; CH15include.i - this include file contains the definitions which allow 
; you to assemble the chapter 15 example without requiring the official 
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

TAG_DONE		EQU	   0

TAG_END			EQU	   0

WA_BASE			EQU 	$80000063
WA_Left			EQU	WA_BASE+$01
WA_Top			EQU	WA_BASE+$02
WA_Width		EQU	WA_BASE+$03
WA_Height		EQU	WA_BASE+$04
WA_IDCMP		EQU	WA_BASE+$07
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


_LVOOpenLibrary		EQU	-552

_LVOCloseLibrary	EQU	-414

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




; ClarityOV_Macros.I
;
; a usefull set of macros,
;
; Version 0.1 © Copyright (26/10/93)
;

JSREQ		MACRO
		CALLEXEC	GetCC				;get conditions codes
		and.l		#4,d0				;see if equal
		cmpi.l		#4,d0
		beq		JUMP\@
		bra		END_EQ\@			;end

JUMP\@
		jsr		\1				;jump to subroutine

END_EQ\@
		ENDM
;---------------
JSRLE		MACRO
		CALLEXEC	GetCC				;get conditions codes
		and.l		#9,d0				;see if equal
		cmpi.l		#9,d0
		beq		JUMP_LE\@
		bra		END_LE\@			;end

JUMP_LE\@
		jsr		\1				;jump to subroutine

END_LE\@
		ENDM
;---------------
PUSH		MACRO
		movem.l		\1,-(sp)
		ENDM

PULL		MACRO
		movem.l		(sp)+,\1
		ENDM
;---------------
WAITVBL		MACRO
.VBL\@
		btst		#5,$DFF01F
		beq.s		.VBL\@
		ENDM
;---------------
OPEN_LIBRARY	MACRO		LIBRARY_NAME,VERSION,LIBRARY_BASE
		lea		\1,a1
		move.l		#\2,d0
		CALLEXEC	OpenLibrary
		move.l		d0,\3
		ENDM
		
CLOSE_LIBRARY	MACRO		LIBRARY_BASE
		move.l		\1,a1
		CALLEXEC	CloseLibrary
		ENDM
		
		
IF_NOT		MACRO		BRANCH TO
		tst.l		d0
		beq		\1
		ENDM
		
OPEN_WINDOW	MACRO		NEW_WINDOW,TAG_LIST,POINTER
		move.l		\1,a0
		lea		\2,a1
		CALLINT		OpenWindowTagList
		move.l		d0,\3
		ENDM
		
OPEN_SCREEN	MACRO		NEW_SCREEN,TAG_LIST,POINTER
		move.l		\1,a0
		lea		\2,a1
		CALLINT		OpenScreenTagList
		move.l		d0,\3
		ENDM
		
EASY_REQUEST	MACRO		WINDOW_REF,STRUCT,IDCMP,ARGS
		move.l		\1,a0
		lea		\2,a1
		lea		\3,a2
		lea		\4,a3
		CALLINT		EasyRequestArgs
		ENDM
		
CREATE_GADGET	MACRO		STRUCT,KIND,OLD_GAD,TAGS,POINTER,POINTER2
		lea		\1,a0
		move.l		VISUAL_INFO,gng_VisualInfo(a0)
		
		move.l		#\2,d0
		move.l		\3,a0
		lea		\1,a1
		lea		\4,a2
		CALLGAD		CreateGadgetA
		move.l		d0,\5
		move.l		d0,\6
		ENDM

LOCK_PUBLIC	MACRO		NAME,POINTER
		lea		\1,a0
		CALLINT		LockPubScreen
		move.l		d0,\2
		ENDM
		
GET_VI		MACRO		SCREEN,TAGS,POINTER
		move.l		\1,a0
		lea		\2,a1
		CALLGAD		GetVisualInfo
		move.l		d0,\3
		ENDM
		
CREATE_CONTEXT	MACRO		GADGET_LIST,GADGET_LIST
		lea		\1,a0
		CALLGAD		CreateContext
		move.l		d0,\2
		ENDM														
;----------------------------------------------------------------------------		
ALLOC_MEM	MACRO		BYTE_SIZE,REQUIREMENTS
		move.l		#\1,d0
		move.l		#\2,d1
		CALLEXEC	AllocMem
		ENDM
;----------------------------------------------------------------------------		
FREE_MEM	MACRO		MEM_ADDRESS,BYTE_SIZE
		move.l		#\2,d0
		move.l		\1,a1
		CALLEXEC	FreeMem
		ENDM
;----------------------------------------------------------------------------		

CALLWB		macro

		move.l		WB_BASE,a6
		jsr		_LVO\1(a6)

		endm

CALLLINT	macro
		move.l		INTUITION_BASE,a6
		jsr		_LVO\1(a6)
		endm
		
CALLLDOS	macro
		move.l		DOS_BASE,a6
		jsr		_LVO\1(a6)
		endm
		
CALLLGRAF	macro
		move.l		GRAPHICS_BASE,a6
		jsr		_LVO\1(a6)
		endm
		
CALLLEXEC	macro
		CALLEXEC	\1
		endm



; Library calling macros that are not in WB2 include files


CALLUTIL	macro
		move.l		_UtilityBase,a6
		jsr		_LVO\1(a6)
		endm

CALLIFF		macro
		move.l		_IFFParseBase,a6
		jsr		_LVO\1(a6)
		endm

CALLASL		macro
		move.l		_AslBase,a6
		jsr		_LVO\1(a6)
		endm

CALLCOMMOD	macro
		move.l		_CxBase,a6
		jsr		_LVO\1(a6)
		endm

CALLICON	macro
		move.l		_IconBase,a6
		jsr		_LVO\1(a6)
		endm

CALLWB		macro
		move.l		_WorkbenchBase,a6
		jsr		_LVO\1(a6)
		endm

CALLGAD		macro
		move.l		_GadToolsBase,a6
		jsr		_LVO\1(a6)
		endm

CALLREXX	macro
		move.l		_RexxSysBase,a6
		jsr		_LVO\1(a6)
		endm

CALLNICO	macro
		move.l		_PPBase,a6
		jsr		_LVO\1(a6)
		endm

CALLREQ		macro
		move.l		_ReqToolsBase,a6
		jsr		_LVO\1(a6)
		endm

CALLSYS		macro
		jsr		_LVO\1(a6)
		endm

PUSH		macro
		movem.l		\1,-(sp)
		endm

PULL		macro
		movem.l		(sp)+,\1
		endm

PUSHALL		macro
		PUSH		d1-d7/a0-a6
		endm

PULLALL		macro
		PULL		d1-d7/a0-a6
		endm

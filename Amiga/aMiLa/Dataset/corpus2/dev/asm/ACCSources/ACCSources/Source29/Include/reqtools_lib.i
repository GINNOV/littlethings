	IFND LIBRARIES_REQTOOLS_LIB_I
LIBRARIES_REQTOOLS_LIB_I SET 1
**
**	$Filename: libraries/reqtools_lib.i $
**	$Release: 1.0 $
**
**	(C) Copyright 1991 Nico François
**	    All Rights Reserved
**

	IFND    EXEC_TYPES_I
	include "exec/types.i"
	ENDC
	IFND    EXEC_NODES_I
	include "exec/nodes.i"
	ENDC
	IFND    EXEC_LISTS_I
	include "exec/lists.i"
	ENDC
	IFND    EXEC_LIBRARIES_I
	include "exec/libraries.i"
	ENDC

	LIBINIT

	LIBDEF _LVOrtAllocRequestA
	LIBDEF _LVOrtFreeRequest
	LIBDEF _LVOrtFreeReqBuffer
	LIBDEF _LVOrtChangeReqAttrA
	LIBDEF _LVOrtFileRequestA
	LIBDEF _LVOrtFreeFileList
	LIBDEF _LVOrtEZRequestA
	LIBDEF _LVOrtGetStringA
	LIBDEF _LVOrtGetLongA
	LIBDEF _LVOrtInternalGetPasswordA	; private!
	LIBDEF _LVOrtInternalEnterPasswordA	; private!
	LIBDEF _LVOrtFontRequestA
	LIBDEF _LVOrtPaletteRequestA
	LIBDEF _LVOrtReqHandlerA
	LIBDEF _LVOrtSetWaitPointer
	LIBDEF _LVOrtGetVScreenSize
	LIBDEF _LVOrtSetReqPosition
	LIBDEF _LVOrtSpread
	LIBDEF _LVOrtScreenToFrontSafely

CALLREQ	macro					; added for easier use, MM.
	move.l	_reqBase,a6
	jsr	_LVO\1(a6)
	endm

	ENDC ; LIBRARIES_REQTOOLS_LIB_I

; acc.library assembler include file. © M.Meany, 1991.

; First a few constants for use with library functions.

PUBLICMEM	equ	0
FASTMEM		equ	1
CHIPMEM		equ	2

; Now the structure for nodes in the supported list code:

		rsreset
nd_Succ	rs.l		1
nd_Pred	rs.l		1
nd_Data	rs.l		1
nd_SIZEOF	rs.l		1

; Next come the name and calling macros:

ACCNAME		macro
		dc.b		'acc.library',0
		even
		endm

CALLACC		macro
		move.l		_AccBase,a6
		jsr		_LVO\1(a6)
		endm

; Finally the function offsets themselves:


accVERSION	equ	1
_LVOGetLibs		equ	-30
_LVOLoadFile		equ	-36
_LVOSaveFile		equ	-42
_LVOFileLen		equ	-48
_LVOStringCmp		equ	-54
_LVOFindStr		equ	-60
_LVOUcase		equ	-66
_LVOLcase		equ	-72
_LVOUcaseMem		equ	-78
_LVOLcaseMem		equ	-84
_LVODOSPrint		equ	-90
_LVOGetDirList		equ	-96
_LVOFreeDirList		equ	-102
_LVONewList		equ	-108
_LVOAddNode		equ	-114
_LVODeleteNode		equ	-120
_LVOFreeList		equ	-126

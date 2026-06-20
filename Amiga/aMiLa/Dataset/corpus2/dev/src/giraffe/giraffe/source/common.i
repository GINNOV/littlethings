
	IFND	EXEC_TYPES_I
	INCLUDE	"exec/types.i"
	ENDC	; EXEC_TYPES_I

	IFND	EXEC_LISTS_I
	INCLUDE	"exec/lists.i"
	ENDC	; EXEC_LISTS_I

	IFND	EXEC_LIBRARIES_I
	INCLUDE	"exec/libraries.i"
	ENDC	; EXEC_LIBRARIES_I

	include "exec/nodes.i"


 structure Object,0
	STRUCT  obj_node,MLN_SIZE
	UBYTE	obj_type
	UBYTE	obj_sizes
	USHORT	obj_match
	LABEL	obj_SIZEOF

GT_Null	equ	0
GT_Layer	equ	1
GT_Region	equ	2
GT_ClipList     equ	3
GT_InputEvent	equ	4
GT_Font		equ	5
GT_Stack        equ     6
GT_TOTAL	equ	7

;--------------------------------------------------------------------------
;
; library data structures
;
;--------------------------------------------------------------------------

;  Note that the library base begins with a library node

	STRUCTURE	GarpBase,LIB_SIZE
	UBYTE	gb_Flags
	UBYTE	gb_pad
	;We are now longword aligned
	ULONG	gb_SysLib
	ULONG	gb_DosLib
	ULONG	gb_SegList

	STRUCT gb_resources,GT_TOTAL*4
	STRUCT gb_inuse,GT_TOTAL*4

	LABEL	GiraffeBase_SIZEOF


GIRAFFENAME	MACRO
	dc.b	'giraffe.library',0
	ENDM



	IFND	EARTH_EARTHBASE_I
EARTH_EARTHBASE_I	set	1

	include	earth/libraries.i
	include	exec/semaphores.i
	IFD	LIBRARY_MINIMUM
	include	utility/hooks.i
	ENDC
;
; Define the library base structure.
;
			rsset	stl_SIZE	struct EarthBase
earth_ArpBase		rs.l	1
earth_UtilityBase	rs.l	1
earth_IconBase		rs.l	1
earth_CharTable		rs.b	256		Character table
earth_Semaphore		rs.b	SS_SIZE
earth_RandSeed		rs.l	1
earth_SIZE		rs.w	0
;
; Macro to create a name string.
;
EARTHNAME	MACRO	;[NONULL]
	LIBNAME	earth,\1
	ENDM
;
; Current version number.
;
EARTHVERSION	equ	1
;
;==========================
; Character attribute flags
;==========================

		rsreset
CHRB_CTRL	rs.b	1
CHRB_SPACE	rs.b	1
CHRB_DIGIT	rs.b	1
CHRB_HEX	rs.b	1
CHRB_LOWER	rs.b	1
CHRB_UPPER	rs.b	1
CHRB_PUNCT	rs.b	1
CHRB_GRAPH	rs.b	1

CHRF_CTRL	equ	1<<CHRB_CTRL
CHRF_SPACE	equ	1<<CHRB_SPACE
CHRF_DIGIT	equ	1<<CHRB_DIGIT
CHRF_HEX	equ	1<<CHRB_HEX
CHRF_LOWER	equ	1<<CHRB_LOWER
CHRF_UPPER	equ	1<<CHRB_UPPER
CHRF_PUNCT	equ	1<<CHRB_PUNCT
CHRF_GRAPH	equ	1<<CHRB_GRAPH

;==============================================================
; Macros for testing/converting characters, assuming a6 correct
;==============================================================

_ISALNUM MACRO	;[reg]
	IFC	'\1',''
	move.b	earth_CharTable(a6,d0),-(sp)
	ELSEIF
	move.b	earth_CharTable(a6,\1),-(sp)
	ENDC
	and.b	#CHRF_UPPER!CHRF_LOWER!CHRF_DIGIT,(sp)+
	ENDM

_ISALPHA MACRO	;[reg]
	IFC	'\1',''
	move.b	earth_CharTable(a6,d0),-(sp)
	ELSEIF
	move.b	earth_CharTable(a6,\1),-(sp)
	ENDC
	and.b	#CHRF_UPPER!CHRF_LOWER,(sp)+
	ENDM

_ISCNTRL MACRO	;[reg]
	IFC	'\1',''
	btst	#CHRB_CTRL,earth_CharTable(a6,d0)
	ELSEIF
	btst	#CHRB_CTRL,earth_CharTable(a6,\1)
	ENDC
	ENDM

_ISDIGIT MACRO	;[reg]
	IFC	'\1',''
	btst	#CHRB_DIGIT,earth_CharTable(a6,d0)
	ELSEIF
	btst	#CHRB_DIGIT,earth_CharTable(a6,\1)
	ENDC
	ENDM

_ISGRAPH MACRO	;[reg]
	IFC	'\1',''
	btst	#CHRB_GRAPH,earth_CharTable(a6,d0)
	ELSEIF
	btst	#CHRB_GRAPH,earth_CharTable(a6,\1)
	ENDC
	ENDM

_ISLOWER MACRO	;[reg]
	IFC	'\1',''
	btst	#CHRB_LOWER,earth_CharTable(a6,d0)
	ELSEIF
	btst	#CHRB_LOWER,earth_CharTable(a6,\1)
	ENDC
	ENDM

_ISPRINT MACRO	;[reg]
	IFC	'\1',''
	btst	#CHRB_CTRL,earth_CharTable(a6,d0)
	ELSEIF
	btst	#CHRB_CTRL,earth_CharTable(a6,\1)
	ENDC
	eori.b	#4,ccr
	ENDM

_ISPUNCT MACRO	;[reg]
	IFC	'\1',''
	btst	#CHRB_PUNCT,earth_CharTable(a6,d0)
	ELSEIF
	btst	#CHRB_PUNCT,earth_CharTable(a6,\1)
	ENDC
	ENDM

_ISSPACE MACRO	;[reg]
	IFC	'\1',''
	btst	#CHRB_SPACE,earth_CharTable(a6,d0)
	ELSEIF
	btst	#CHRB_SPACE,earth_CharTable(a6,\1)
	ENDC
	ENDM

_ISUPPER MACRO	;[reg]
	IFC	'\1',''
	btst	#CHRB_UPPER,earth_CharTable(a6,d0)
	ELSEIF
	btst	#CHRB_UPPER,earth_CharTable(a6,\1)
	ENDC
	ENDM

_ISHEX MACRO	;[reg]
	IFC	'\1',''
	btst	#CHRB_HEX,earth_CharTable(a6,d0)
	ELSEIF
	btst	#CHRB_HEX,earth_CharTable(a6,\1)
	ENDC
	ENDM

_TOUPPER MACRO	;[d-reg]
	IFC	'\1',''
	btst	#CHRB_LOWER,earth_CharTable(a6,d0)
	beq.b	*+6
	andi.b	#$DF,d0
	ELSEIF
	btst	#CHRB_LOWER,earth_CharTable(a6,\1)
	beq.b	*+6
	andi.b	#$DF,\1
	ENDC
	ENDM

_TOLOWER MACRO	;[reg]
	IFC	'\1',''
	btst	#CHRB_UPPER,earth_CharTable(a6,d0)
	beq.b	*+6
	ori.b	#$20,d0
	ELSEIF
	btst	#CHRB_UPPER,earth_CharTable(a6,\1)
	beq.b	*+6
	ori.b	#$20,\1
	ENDC
	ENDM

;================================================================
; Macros for testing/converting characters, assuming a6 incorrect
;================================================================

ISALNUM	MACRO	;[reg]
	XMACRO	Earth,_ISALNUM,\1
	ENDM

ISALPHA	MACRO	;[reg]
	XMACRO	Earth,_ISALPHA,\1
	ENDM

ISCNTRL	MACRO	;[reg]
	XMACRO	Earth,_ISCNTRL,\1
	ENDM

ISDIGIT	MACRO	;[reg]
	XMACRO	Earth,_ISDIGIT,\1
	ENDM

ISGRAPH	MACRO	;[reg]
	XMACRO	Earth,_ISGRAPH,\1
	ENDM

ISLOWER	MACRO	;[reg]
	XMACRO	Earth,_ISLOWER,\1
	ENDM

ISPRINT	MACRO	;[reg]
	XMACRO	Earth,_ISPRINT,\1
	ENDM

ISPUNCT	MACRO	;[reg]
	XMACRO	Earth,_ISPUNCT,\1
	ENDM

ISSPACE	MACRO	;[reg]
	XMACRO	Earth,_ISSPACE,\1
	ENDM

ISUPPER	MACRO	;[reg]
	XMACRO	Earth,_ISUPPER,\1
	ENDM

ISHEX	MACRO	;[reg]
	XMACRO	Earth,_ISHEX,\1
	ENDM

TOUPPER	MACRO	;[reg]
	XMACRO	Earth,_TOUPPER,\1
	ENDM

TOLOWER	MACRO	;[reg]
	XMACRO	Earth,_TOLOWER,\1
	ENDM

;=======================
; Binary tree structures
;=======================

		rsreset			struct TreeHeader
th_Head		rs.l	1		Address of first node in tree
th_HookList	rs.b	MLH_SIZE	List of comparison callback hooks
th_SIZE		rs.w	0

		rsreset		struct TreeNode
tn_Less		rs.l	1	Address of less-than node
tn_Greater	rs.l	1	Address of greater-than node
mtn_SIZE	rs.l	0	<Minimal structure size>
tn_Value	rs.l	0	Node value )_ A union
tn_Name		rs.l	1	Node name  )
tn_SIZE		rs.w	0
;

; Constants to pass to ForEachTreeNode()...

			rsreset
ORDER_DEPTHFIRST	rs.b	1
ORDER_DEPTHLAST		rs.b	1
ORDER_ASCENDING		rs.b	1
ORDER_DESCENDING	rs.b	1

;========================================================
; Hook structure (for users who don't have release 2.0+)
;========================================================

	IFND	LIBRARY_MINIMUM		(ie. if release 1.3 or less)
		rsreset			struct Hook
h_MinNode	rs.b	MLN_SIZE	Node for linked list
h_Entry		rs.l	1		Function entry point
h_SubEntry	rs.l	1		High-Level-Language entry point
h_Data		rs.l	1		Address of private data
h_SIZEOF	rs.w	0
	ENDC

	ENDC

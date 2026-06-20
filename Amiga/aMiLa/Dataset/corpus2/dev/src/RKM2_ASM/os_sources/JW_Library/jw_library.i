	IFND    JW_LIBRARY_I
JW_LIBRARY_I    SET     1
**
**	$VER: jw_library.i 1.0 (14.11.2000)
**	Includes Release 40.15
**
**	Interface definitions for the John White library
**
**	Written By: John White, 14.11.2000
**	This include is PUBLIC DOMAIN
**

JWVER	EQU	39
JWREV	EQU	1

JWNAME	MACRO
	DC.B	'jw.library',0
	ENDM

JWID	MACRO
	DC.B	'jwlib 39.1 (2.3.92)',13,10,0
	ENDM

LINKSYS	MACRO
	MOVE.L	A6,-(SP)
	MOVE.L	\2,A6
	JSR	_LVO\1(A6)
	MOVE.L	(SP)+,A6
	ENDM

XLIB	MACRO
	XREF	_LVO\1
	ENDM

; ======================================================================== 
; === Library ============================================================ 
; ======================================================================== 
;
;

    STRUCTURE	JwBase,0
	STRUCT	jw_LibBase,LIB_SIZE
	UBYTE	jw_Flags
	UBYTE	jw_pad
	ULONG	jw_SysLib
	ULONG	jw_DosLib
	ULONG	jw_SegList
	LABEL	JwBase_SIZEOF

	ENDC

 ifnd EXEC_TYPES_I
EXEC_TYPES_I set 1
*
*  exec/types.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

INCLUDE_VERSION = 36

	macro	EXTERN_LIB
	xref	_LVO\1
	endm

	macro	STRUCTURE
	rsset	\2
	endm

	macro	FPTR
\1	rs.l	1
	endm

	macro	BOOL
\1	rs.w	1
	endm

	macro	BYTE
\1	rs.b	1
	endm

	macro	UBYTE
\1	rs.b	1
	endm

	macro	WORD
\1	rs.w	1
	endm

	macro	UWORD
\1	rs.w	1
	endm

	macro	SHORT
\1	rs.w	1
	endm

	macro	USHORT
\1	rs.w	1
	endm

	macro	LONG
\1	rs.l	1
	endm

	macro	ULONG
\1	rs.l	1
	endm

	macro	FLOAT
\1	rs.f	1
	endm

	macro	DOUBLE
\1	rs.d	1
	endm

	macro	APTR
\1	rs.l	1
	endm

	macro	CPTR
\1	rs.l	1
	endm

	macro	RPTR
\1	rs.l	1
	endm

	macro	STRUCT
\1	rs.b	\2
	endm

	macro	LABEL
\1	rs
	endm

	macro	ALIGNWORD
ALGN\@$ rs
	rsset	(ALGN\@$+1)&$fffffffe
	endm

	macro	ALIGNLONG
ALGN\@$ rs
	rsset	(ALGN\@$+3)&$fffffffc
	endm

	macro	ENUM
	ifc	'\1',''
	rsreset
	else
	rsset	\1
	endc
	endm

	macro	EITEM
\1	rs.b	1
	endm

	macro	BITDEF		; prefix,&name,&bitnum
\1B_\2	equ	\3
\1F_\2	equ	1<<\3
	endm

LIBRARY_MINIMUM equ 33

 endc	 ; EXEC_TYPES_I

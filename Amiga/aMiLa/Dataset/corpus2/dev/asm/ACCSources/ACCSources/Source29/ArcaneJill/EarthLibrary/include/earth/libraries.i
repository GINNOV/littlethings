	IFND	EARTH_LIBRARIES_I
EARTH_LIBRARIES_I	set	1

;$VER: earth_libraries_i 1.0 (20.08.92)

	include	earth/earth.i
	include	exec/libraries.i

;============================
; Standard Library structure
;============================

		rsset	LIB_SIZE	struct Stdibrary
stl_Reserved1	rs.w	1		For future expansion
stl_SegList	rs.l	1		Library segment list
stl_SysBase	rs.l	1		Base of "exec.library"
stl_DOSBase	rs.l	1		Base of "dos.library"
stl_IntuiBase	rs.l	1		Base of "intuition.library"
stl_SIZE	rs.w	0		Size of this structure

;=====================================
; Macros for creating special strings
;=====================================

LIBNAME	MACRO	;name[,NONULL]
	dc.b	'\1.library'
	IFNC	'\2','NONULL'
	dc.b	0
	ENDC
	ENDM

IDSTRING MACRO	;name,date
	dc.b	'\1.library'
	dc.b	' \<_VERSION>.\<_REVISION> '
	dc.b	'\2'
	dc.b	$A,$D,0
	ENDM

;====================================
; Calling your own library functions
;====================================
;
; Use the following macro to call your own library functions from
; within your library.

BSRME	MACRO	;function
	IFNE	_data_h-$A6
	IFNE	_a6MODE
	movem.l	a6,-(sp)
	ENDC
	move.l	_data,a6
	ENDC
	IFD	DEBUG
	jsr	\1
	ELSEIF
	CALL	\1
	ENDC
	IFNE	_data_h-$A6
	IFNE	_a6MODE
	movem.l	(sp)+,a6
	ENDC
	ENDC
	ENDM

;=====================================
; Function header (and footer) macros
;=====================================

FUNCTION MACRO	;name[,regs]
	SECTION FUNCTIONS,DATA
	XDEF	_FN_\1
_FN_\1	dc.l	\1
	CODE
	XDEF	\1
\1	;
	IFEQ	_data_h-$A6
	IFC	'\2',''
_REG_\1	equ	0
	ELSEIF
_REG_\1	reg	\2
	ENDC
	ELSEIF
	IFC	'\2',''
_REG_\1	reg	_data/a6
	ELSEIF
_REG_\1	reg	\2/_data/a6
	ENDC
	ENDC
	OPT	NOWARN
	IFNE	_REG_\1
	movem.l	_REG_\1,-(sp)
	ENDC
	OPT	WARN
	IFNE	_data_h-$A6
	move.l	a6,_data
	ENDC
	ENDM

ENDFUNC	MACRO
	OPT	NOWARN
	IFNE	_REG_\1
	movem.l	(sp)+,_REG_\1
	ENDC
	OPT	WARN
	rts
	ENDM

	ENDC

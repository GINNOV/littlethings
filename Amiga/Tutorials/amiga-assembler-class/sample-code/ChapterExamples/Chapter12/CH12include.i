; CH12include.i - this include file contains the definitions which allow 
; you to assemble the chapter 12 examples without requiring the official 
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


_LVOOpenLibrary		EQU	-552

_LVOCloseLibrary	EQU	-414

_LVOWrite		EQU	-48

_LVOOutput		EQU	-60

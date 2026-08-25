; CH21flash_include.i - this include file contains the definitions which 
; allow you to assemble the interrupt based chapter 21 example without 
; requiring the official Amiga system include files!


LINKLIB     MACRO   ; requires functionOffset and libraryBase parameters
	IFGT NARG-2
	    FAIL    ; fail if wrong number of arguments are provided!
	ENDC
	    MOVE.L  A6,-(SP)
	    MOVE.L  \2,A6
	    JSR     \1(A6)
	    MOVE.L  (SP)+,A6
	    ENDM


CALLSYS	    MACRO
	    LINKLIB	_LVO\1,\2
	    ENDM


CALLEXEC    MACRO
            CALLSYS \1,_AbsExecBase
            ENDM

            
CALLGRAF    MACRO
	    CALLSYS \1,_GfxBase
	    ENDM

_AbsExecBase		EQU	4

IS_DATA			EQU 	14
IS_CODE			EQU 	18
LN_PRI			EQU	9
LN_TYPE			EQU	8

NT_INTERRUPT		EQU	2
INTB_VERTB		EQU	5
IS_SIZE			EQU	22

_LVOAddIntServer	EQU	-168
_LVORemIntServer	EQU	-174
_LVOSetRGB4		EQU	-288
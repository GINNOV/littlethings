 IFND FTYPES_I
FTYPES_I   SET 1
*****************************************************************************
* This file stands for the frametypes.i
*
* This file can be used almost any assembler and its here to support
* SNMA.
*
* ftypes.i has the same type of macros as in exec/types.i, expect
* that they DECREASE the SOFFSET pointer and set it before decrease.
* You can use these macros to create variable equates to the variables
* which are allocated from the stack.
*
* I keep these macros in exec/types.i.	I suggest that if you use these,
* remove the comments from the file you are using. In fact, remove the
* comments from all the include files you are using. The size of the includes
* almost halves when you strip the comments and blank lines out. (There are
* tools for doing that).
*
* Example:
*	STRUCTURE LocalData,0
*	    flong var1
*	    flong var2
*	    fword word1
*	    fword word2
*	    fstruct stringbuf,80
*	    label LocalSize		(note: flabel NOT needed)
*   ; remember to keep stack long aligned
*
* Routine:
*	    link    a5,#LocalSize
*	    move.l  #10,(var1,a5)       set var1
*	    clr.w   (word2,a5)          clear word2
*	    ; do something
*	    unlk    a5
*	    rts
*

fBYTE	MACRO
SOFFSET SET	SOFFSET-1
\1	EQU	SOFFSET
	ENDM
fUBYTE	MACRO
SOFFSET SET	SOFFSET-1
\1	EQU	SOFFSET
	ENDM
fWORD	MACRO
SOFFSET SET	SOFFSET-2
\1	EQU	SOFFSET
	ENDM
fUWORD	MACRO
SOFFSET SET	SOFFSET-2
\1	EQU	SOFFSET
	ENDM
fSHORT	MACRO
SOFFSET SET	SOFFSET-2
\1	EQU	SOFFSET
	ENDM
fUSHORT MACRO
SOFFSET SET	SOFFSET-2
\1	EQU	SOFFSET
	ENDM
fLONG	MACRO
SOFFSET SET	SOFFSET-4
\1	EQU	SOFFSET
	ENDM
fULONG	MACRO
SOFFSET SET	SOFFSET-4
\1	EQU	SOFFSET
	ENDM
fFLOAT	MACRO
SOFFSET SET	SOFFSET-4
\1	EQU	SOFFSET
	ENDM
fAPTR	MACRO
SOFFSET SET	SOFFSET-4
\1	EQU	SOFFSET
	ENDM
fDOUBLE MACRO
SOFFSET SET	SOFFSET-8
\1	EQU	SOFFSET
	ENDM
fSTRUCT MACRO
SOFFSET SET	SOFFSET-\2
\1	EQU	SOFFSET
	ENDM
 ENDC

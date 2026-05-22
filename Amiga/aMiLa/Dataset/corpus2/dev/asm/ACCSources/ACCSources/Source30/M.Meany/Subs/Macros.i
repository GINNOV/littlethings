
;Purpose	General purpose macros for an easy life!
;Programmer	M.Meany
;Date		January 1993
;Machine	Amiga A12OO
;Assembler	Devpac 3

CALLSYS		macro
		jsr		_LVO\1(a6)
		endm

PUSH		macro
		movem.l		\1,-(sp)
		endm

PULL		macro
		movem.l		(sp)+,\1
		endm

PUSHALL		macro
		movem.l		d0-d7/a0-a6,-(sp)
		endm

PULLALL		macro
		movem.l		(sp)+,d0-d7/a0-a6
		endm

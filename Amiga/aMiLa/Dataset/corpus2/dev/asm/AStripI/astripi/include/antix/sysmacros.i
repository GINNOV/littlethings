		IFND	SYSMACROS_I
SYSMACROS_I
GLIB:		MACRO
		move.l	_\1Base(pc),a6
		ENDM
CALL:		MACRO
		jsr	_LVO\1(a6)
		ENDM
JLIB:		MACRO
		jmp	_LVO\1(a6)
		ENDM
PUSH:		MACRO
		move.l	\1,-(sp)
		ENDM
POP:		MACRO
		move.l	(sp)+,\1
		ENDM
PUSHM:		MACRO
		movem.l	\1,-(sp)
		ENDM
POPM:		MACRO
		movem.l	(sp)+,\1
		ENDM
PUSHA:		MACRO
		movem.l	d1-d7/a0-a6,-(sp)
		ENDM
POPA:		MACRO
		movem.l	(sp)+,d1-d7/a0-a6
		ENDM
		ENDC

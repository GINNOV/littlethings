_LVOFlash	EQU	-30
CALLJW  MACRO
	move.l	_JWBase,a6
	jsr	_LVO\1(a6)
	ENDM

JWNAME  MACRO
        dc.b	'jw.library',0
	ENDM

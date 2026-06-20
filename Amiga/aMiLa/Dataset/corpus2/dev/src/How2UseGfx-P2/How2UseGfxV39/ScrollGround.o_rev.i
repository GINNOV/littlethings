VERSION		EQU	1
REVISION	EQU	2
DATE	MACRO
		dc.b	'30.11.96'
	ENDM
VERS	MACRO
		dc.b	'ScrollGround.o 1.2'
	ENDM
VSTRING	MACRO
		dc.b	'ScrollGround.o 1.2 (30.11.96)',13,10,0
	ENDM
VERSTAG	MACRO
		dc.b	0,'$VER: ScrollGround.o 1.2 (30.11.96)',0
	ENDM

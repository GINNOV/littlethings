VERSION		EQU	2
REVISION	EQU	5
DATE	MACRO
		dc.b	'2.10.97'
	ENDM
VERS	MACRO
		dc.b	'ToggleFormat 2.5'
	ENDM
VSTRING	MACRO
		dc.b	'ToggleFormat 2.5 (2.10.97)',13,10,0
	ENDM
VERSTAG	MACRO
		dc.b	0,'$VER: ToggleFormat 2.5 (2.10.97)',0
	ENDM

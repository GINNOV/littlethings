VERSION		EQU	2
REVISION	EQU	19
DATE	MACRO
		dc.b	'1.10.97'
	ENDM
VERS	MACRO
		dc.b	'ConfigFile.library 2.19'
	ENDM
VSTRING	MACRO
		dc.b	'ConfigFile.library 2.19 (1.10.97)',13,10,0
	ENDM
VERSTAG	MACRO
		dc.b	0,'$VER: ConfigFile.library 2.19 (1.10.97)',0
	ENDM

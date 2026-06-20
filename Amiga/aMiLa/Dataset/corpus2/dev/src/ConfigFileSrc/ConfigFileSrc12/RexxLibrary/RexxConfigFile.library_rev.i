VERSION		EQU	1
REVISION	EQU	1
DATE	MACRO
		dc.b	'1.10.97'
	ENDM
VERS	MACRO
		dc.b	'RexxConfigFile.library 1.1'
	ENDM
VSTRING	MACRO
		dc.b	'RexxConfigFile.library 1.1 (1.10.97)',13,10,0
	ENDM
VERSTAG	MACRO
		dc.b	0,'$VER: RexxConfigFile.library 1.1 (1.10.97)',0
	ENDM

VERSION		EQU	1
REVISION	EQU	1

DATE	MACRO
		dc.b '7.10.2018'
		ENDM

VERS	MACRO
		dc.b 'uuid.library 1.1'
		ENDM

VSTRING	MACRO
		dc.b 'uuid.library 1.1 (7.10.2018)',13,10,0
		ENDM

VERSTAG	MACRO
		dc.b 0,'$VER: uuid.library 1.1 (7.10.2018)',0
		ENDM

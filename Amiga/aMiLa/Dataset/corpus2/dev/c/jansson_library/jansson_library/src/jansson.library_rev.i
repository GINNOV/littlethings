VERSION		EQU	2
REVISION	EQU	12

DATE	MACRO
		dc.b '19.4.2020'
		ENDM

VERS	MACRO
		dc.b 'amijansson_source/jansson.library 2.12'
		ENDM

VSTRING	MACRO
		dc.b 'amijansson_source/jansson.library 2.12 (19.4.2020)',13,10,0
		ENDM

VERSTAG	MACRO
		dc.b 0,'$VER: amijansson_source/jansson.library 2.12 (19.4.2020)',0
		ENDM

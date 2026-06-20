VERSION		EQU	51
REVISION	EQU	1

DATE	MACRO
		dc.b '16.6.2006'
		ENDM

VERS	MACRO
		dc.b 'ramdev.device 51.1'
		ENDM

VSTRING	MACRO
		dc.b 'ramdev.device 51.1 (16.6.2006)',13,10,0
		ENDM

VERSTAG	MACRO
		dc.b 0,'$VER: ramdev.device 51.1 (16.6.2006)',0
		ENDM

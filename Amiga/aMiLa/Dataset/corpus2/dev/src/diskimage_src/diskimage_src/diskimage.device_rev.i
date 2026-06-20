VERSION		EQU	0
REVISION	EQU	2

DATE	MACRO
		dc.b '12.11.2007'
		ENDM

VERS	MACRO
		dc.b 'diskimage.device 0.2'
		ENDM

VSTRING	MACRO
		dc.b 'diskimage.device 0.2 (12.11.2007)',13,10,0
		ENDM

VERSTAG	MACRO
		dc.b 0,'$VER: diskimage.device 0.2 (12.11.2007)',0
		ENDM

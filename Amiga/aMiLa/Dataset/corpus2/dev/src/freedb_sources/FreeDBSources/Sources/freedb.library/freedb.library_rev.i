VERSION EQU 3
REVISION EQU 1
DATE MACRO
    dc.b '12.12.2001'
    ENDM
VERS MACRO
    dc.b 'freedb.library 3.1'
    ENDM
VSTRING MACRO
    dc.b 'freedb.library 3.1 (12.12.2001)',13,10,0
    ENDM
VERSTAG MACRO
    dc.b 0,'$VER: freedb.library 3.1 (12.12.2001)',0
    ENDM

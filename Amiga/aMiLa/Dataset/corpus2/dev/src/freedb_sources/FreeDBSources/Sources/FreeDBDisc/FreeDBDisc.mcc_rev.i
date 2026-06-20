VERSION EQU 16
REVISION EQU 6
DATE MACRO
    dc.b '12.12.2001'
    ENDM
VERS MACRO
    dc.b 'FreeDBDisc.mcc 16.6'
    ENDM
VSTRING MACRO
    dc.b '$VER: FreeDBDisc.mcc 16.6 (12.12.2001) 2001 Alfonso Ranieri <alforan@tin.it>',13,10,0
    ENDM
VERSTAG MACRO
    dc.b 0,'$VER: FreeDBDisc.mcc 16.6 (12.12.2001)',0
    ENDM

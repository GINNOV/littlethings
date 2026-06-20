VERSION EQU 16
REVISION EQU 6
DATE MACRO
    dc.b '12.12.2001'
    ENDM
VERS MACRO
    dc.b 'FreeDBConfig.mcc 16.6'
    ENDM
VSTRING MACRO
    dc.b '$VER: FreeDBConfig.mcc 16.6 (12.12.2001) 2001 Alfonso Ranieri <alforan@tin.it>',13,10,0
    ENDM
VERSTAG MACRO
    dc.b 0,'$VER: FreeDBConfig.mcc 16.6 (12.12.2001)',0
    ENDM

;library/TDRender.i
;Include File For 3DRender.library
; V 1.0


    IFND LIBRARIES_TDRENDER_I
LIBRARIES_TDRENDER_I    SET     1

ST_VERNUM   equ 1
ST_REVNUM   equ 0

    IFND    EXEC_TYPES_I
    include "exec/types.i"
    ENDC
    
    IFND    EXEC_LIBRARIES_I
    include "exec/libraries.i"
    ENDC
    
    STRUCTURE   TDRenderBase,LIB_SIZE
     ULONG      stb_SegList
     APTR       stb_ExecBase
     APTR       stb_UtilityBase
    LABEL       stb_SIZEOF
    
TDRENDERNAME    MACRO
    dc.b        "tdrender.library",0
    ENDM
    
    ENDC

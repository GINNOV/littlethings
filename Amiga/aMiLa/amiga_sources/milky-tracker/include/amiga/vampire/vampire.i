        IFND    _RESOURCES_VAMPIRE_I
_RESOURCES_VAMPIRE_I    EQU     1

;******************************************************************************************
;*
;* $id: vampire.i $
;*
;* Unit numbers and library call offsets for vampire.resource
;*
;* (C) 2017 Apollo Team
;*
;* author: Henryk Richter
;*
;******************************************************************************************

        IFND    EXEC_TYPES_I
        include "exec/types.i"
        ENDC

        IFND    EXEC_LIBRARIES_I
        include "exec/libraries.i"
        ENDC

;*
;* Library vector offsets
;*
        LIBINIT LIB_BASE
        LIBDEF  V_AllocExpansionPort ;-6  (V44)
        LIBDEF  V_FreeExpansionPort  ;-12 (V44)
        LIBDEF  V_EnableAMMX         ;-18 (V45)

;*
;* Name
;*
V_VAMPIRENAME  MACRO
               dc.b    "vampire.resource",0
               ENDM

;* Unit number definitions: Ownership of a resource grants low-level
;* bit access to the hardware registers.  You are still obligated to follow
;* the rules for shared access of the interrupt system.
;*
V_SDPORT        EQU     0       ;SD port on V500/600
V_WIFIPORT      EQU     1       ;WiFi expansion port on V500+
V_PAMELA_45	EQU     2	;Pamela channels 4,5 = first two 16 bit capable channels
V_PAMELA_67	EQU     3	;Pamela channels 6,7 = second two 16 bit capable channels
V_PIP           EQU     4       ;Saga Picture in Picture
V_V4NET         EQU     5       ;Vampire V4 Net

        ENDC    ;_RESOURCES_VAMPIRE_I

;* AMMX enable variants 
;* Supported right now are AMMX1 (and associated checks) and AMMX2
;*
;* note: enumerate as binary exponential sequence
V_AMMX_DISABLE  EQU	0
V_AMMX_V1       EQU     1
V_AMMX_V2       EQU     2

;*
;* AMMX enable return codes
;*
VRES_ERROR       EQU    0
VRES_OK          EQU    1
VRES_AMMX_WAS_ON EQU    2


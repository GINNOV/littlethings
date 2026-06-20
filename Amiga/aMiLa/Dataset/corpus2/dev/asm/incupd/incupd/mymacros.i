 IFND MYMACROS_I
MYMACROS_I SET 1
call MACRO
 jsr (_LVO\1,a6)
 ENDM
ldef MACRO
_LVO\1=-$\2
 ENDM
push MACRO
 IFC '\0',''
 movem.l \1,-(sp)
 ELSE
 movem.\0 \1,-(sp)
 ENDC
 ENDM
pop MACRO
 IFC '\0',''
 movem.l (sp)+,\1
 ELSE
 movem.\0 (sp)+,\1
 ENDC
 ENDM
rcreset MACRO
 RSRESET
 ENDM
rcset MACRO
 RSSET \1
 ENDM
rc MACRO
 IFC '\0',''
\1 rs.w \2
 ds.w \2
 ELSE
\1 rs.\0 \2
 ds.\0 \2
 ENDC
 ENDM
local MACRO
 IFC '\0','b'
__LOCALADD SET 1
 ELSE
 IFC '\0','w'
__LOCALADD SET 2
 ELSE
 IFC '\0','l'
__LOCALADD SET 4
 ELSE
__LOCALADD SET \2
 ENDC
 ENDC
 ENDC
__LOCAL SET __LOCAL-__LOCALADD
\1=__LOCAL
 ENDM
localend MACRO
\1=__LOCAL&$fffffffe
__LOCAL SET 0
 ENDM
__LOCAL SET 0
 ENDC

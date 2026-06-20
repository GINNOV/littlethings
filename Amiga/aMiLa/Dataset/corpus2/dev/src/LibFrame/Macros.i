	IFND    MY_MACROS_I
MY_MACROS_I     SET     1
*****
*****   Macros.I
*****
*****   Version 1.0
*****

		IFND    EXEC_TYPES_I
		INCLUDE Exec/Types.I
		ENDC

		IFND    MY_ALLLIBS_I
		INCLUDE My/AllLibs.I
		ENDC

VGET                    MACRO
			Move.\0 var_\1(a5),\2
			ENDM

VPUT                    MACRO
			Move.\0 \1,var_\2(a5)
			ENDM

VADD                    MACRO
			IFEQ    NARG-1
			 Add.\0  #1,var_\1(a5)
			ELSE
			 Add.\0  \1,var_\2(a5)
			ENDC
			ENDM

VSUB                    MACRO
			IFEQ    NARG-1
			 Sub.\0  #1,var_\1(a5)
			ELSE
			 Sub.\0  \1,var_\2(a5)
			ENDC
			ENDM

VTST                    MACRO
			Tst.\0  var_\1(a5)
			ENDM

VCMP                    MACRO
			IFC     '\*LEFT(\1,1)','#'
			 Cmp.\0  \1,var_\2(a5)
			ELSE
			 Cmp.\0  var_\2(a5),\1
			ENDC
			ENDM

VLEA                    MACRO
			Lea     var_\1(a5),\2
			ENDM

VOR                     MACRO
			Or.\0   \1,var_\2(a5)
			ENDM

VAND                    MACRO
			And.\0  \1,var_\2(a5)
			ENDM

VNOT                    MACRO
			Not.\0  var_\1(a5)
			ENDM

SGET                    MACRO
			Move.\0 var_\1(sp),\2
			ENDM

SPUT                    MACRO
			Move.\0 \1,var_\2(sp)
			ENDM

SPUTM                   MACRO
			Movem.\0 \1,var_\2(sp)
			ENDM

SADD                    MACRO
			IFEQ    NARG-1
			 Add.\0  #1,var_\1(sp)
			ELSE
			 Add.\0  \1,var_\2(sp)
			ENDC
			ENDM

SSUB                    MACRO
			IFEQ    NARG-1
			 Sub.\0  #1,var_\1(sp)
			ELSE
			 Sub.\0  \1,var_\2(sp)
			ENDC
			ENDM

SNOT                    MACRO
			Not.\0  var_\1(sp)
			ENDM

STST                    MACRO
			Tst.\0  var_\1(sp)
			ENDM

SCMP                    MACRO
			IFC     '\*LEFT(\1,1)','#'
			 Cmp.\0  \1,var_\2(sp)
			ELSE
			 Cmp.\0  var_\2(sp),\1
			ENDC
			ENDM

SLEA                    MACRO
			Lea     var_\1(sp),\2
			ENDM

INITVARS                MACRO
\1                      EQU     \2
_VARCNT                 SET     \2
			ENDM

LVAR                    MACRO
var_\1                  EQU     _VARCNT
_VARCNT                 SET     _VARCNT+4
			ENDM

WVAR                    MACRO
var_\1                  EQU     _VARCNT
_VARCNT                 SET     _VARCNT+2
			ENDM

BVAR                    MACRO
var_\1                  EQU     _VARCNT
_VARCNT                 SET     _VARCNT+1
			ENDM

IVAR                    MACRO
var_\1                  EQU     _VARCNT
_VARCNT                 SET     _VARCNT+\2
			ENDM

ENDVARS                 MACRO
\1_SIZE                 SET     _VARCNT
			ENDM

TAGS                    MACRO
\1
_TAGOFFSET              SET     0
			ENDM

TAG                     MACRO
_TAGOFFSET              SET     _TAGOFFSET+8
			Dc.l    \1,\2
			ENDM

ENDTAGS                 MACRO
			Dc.l    TAG_DONE
			ENDM

CALL                    MACRO
			IFEQ    NARG-2
			 IFC     '\1','Exec'
			  Move.l 4.w,a6
			 ELSE
			  VGET.l \1Base,a6
			 ENDC
			 Jsr    _LVO\2(a6)
			ELSE
			 Jsr    _LVO\1(a6)
			ENDC
			ENDM

OLIB                    MACRO
			Lea     \1Name(pc),a1
			Moveq   #\2,d0
			CALL    Exec,OpenLibrary
			VPUT.l  d0,\1Base
			ENDM

CLIB                    MACRO
			VGET.l  \1Base,a1
			CALL    Exec,CloseLibrary
			ENDM

GETMEM                  MACRO
			Move.l  #\1,d0
			Move.l  #\2,d1
			CALL    Exec,AllocVec
			VPUT.l  d0,\3
			ENDM

FREEMEM                 MACRO
			VGET.l  \1,a1
			CALL    Exec,FreeVec
			ENDM
 ENDC

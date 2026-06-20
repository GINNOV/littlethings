* DOD-2-DOS COMMON 68000 MACROS

DEMO	EQU	2	;0=production, 1=demo, 2=eval

EXISTING EQU	1005	;AMIGA-DOS OPEN EXISTING FILE ACCESS MODE
NEW      EQU	1006	;AMIGA-DOS OPEN NEW FILE ACCESS MODE
TRUE     EQU	-1	;BOOLEAN CONSTANT
FALSE    EQU	0	;DITTO

DR_GetUnit    EQU  -18  ;SIEZE DISK CONTROLLER
DR_GiveUnit   EQU  -24  ;RELEASE DISK CONTROLLER
DR_GetUnitID  EQU  -30  ;GET DISK DRIVE TYPE


DISABLE MACRO
        MOVE.W  #$4000,$DFF09A
        ENDM

ENABLE  MACRO
        MOVE.W  #$C000,$DFF09A
        ENDM

NODE    MACRO
        DC.L    0       ;SUCC
        DC.L    0       ;PRED
        DC.B    \1      ;TYPE
        DC.B    \2      ;PRI
        DC.L    \3      ;NAME POINTER
        ENDM

SETF    MACRO
        BSET    #0,\1
        ENDM

PUSH    MACRO
        MOVEM.L \1,-(A7)
        ENDM

POP     MACRO
        MOVEM.L (A7)+,\1
        ENDM

CALL    MACRO
        JSR     \1
        ENDM

INCB    MACRO
        ADDQ.B #1,\1
        ENDM

DECB    MACRO
        SUBQ.B #1,\1
        ENDM

INCW    MACRO
        ADDQ.W #1,\1
        ENDM

DECW    MACRO
        SUBQ.W #1,\1
        ENDM

INCL    MACRO
        ADDQ.L #1,\1
        ENDM

DECL    MACRO
        SUBQ.L #1,\1
        ENDM

ZAP     MACRO
        MOVEQ  #0,\1
        ENDM

ZAPA	MACRO
	SUB.L	\1,\1
	ENDM

STC     MACRO
        ORI.B  #1,CCR
        ENDM

CLC     MACRO
        CMP.B  D0,D0
        ENDM

SWAB    MACRO
        ROL.W   #8,\1
        ENDM

IFZ     MACRO
        TST.B   \1
        BEQ     \2
        ENDM

IFNZ    MACRO
        TST.B   \1
        BNE     \2
        ENDM

IFZL	MACRO
	TST.L	\1
	BEQ	\2
	ENDM

IFEQ.   MACRO   ;STG1,STG2,LABEL
        XREF    CMP..
        LEA     \1,A0
        LEA     \2,A1
        JSR     CMP..
        BEQ     \3
        ENDM

IFNE.   MACRO   ;STG1,STG2,LABEL
        XREF    CMP..
        LEA     \1,A0
        LEA     \2,A1
        JSR     CMP..
        BNE     \3
        ENDM

SCAN.   MACRO   ;SOURCE,DEST
        XREF    SCAN..
        LEA     \1,A0
        LEA     \2,A1
        JSR     SCAN..
        ENDM

MOVE.   MACRO   ;SOURCE,DEST
        XREF    MOVE..
        LEA     \1,A0
        LEA     \2,A1
        JSR     MOVE..
        ENDM

LEFT.   MACRO   ;SRC,LEN,DEST
        XREF    LEFT..
        LEA     \1,A0
        MOVE.W  \2,D0
        LEA     \3,A1
        JSR     LEFT..
        ENDM

RIGHT.  MACRO   ;SRC,LEN,DEST
        XREF    RIGHT..
        LEA     \1,A0
        MOVE.W  \2,D0
        LEA     \3,A1
        JSR     RIGHT..
        ENDM

STRIP_LB.   MACRO
        XREF    STRIP_LB..
        LEA     \1,A0
        JSR     STRIP_LB..
        ENDM

STRIP_TB.  MACRO
        XREF    STRIP_TB..
        LEA     \1,A0
        JSR     STRIP_TB..
        ENDM

UCASE.  MACRO
        XREF    UCASE..
        LEA     \1,A0
        JSR     UCASE..
        ENDM

APPEND. MACRO
        XREF    APPEND..
        LEA     \1,A0
        LEA     \2,A1
        JSR     APPEND..
        ENDM

STG_Z.  MACRO
        XREF    STG_Z..
        LEA     \1,A0
        JSR     STG_Z..
        ENDM

Z_STG.  MACRO
        XREF    Z_STG..
        LEA     \1,A0
        LEA     \2,A1
        JSR     Z_STG..
        ENDM

STR.    MACRO   ;VARIABLE TYPE (B,W,L),VARIABLE NAME,STG,FILL CHAR
        XREF    STR..
        ZAP     D0
        MOVE.\1 \2,D0
        LEA     \3,A0
        MOVE.B  \4,D1
        JSR     STR..
        ENDM

STRING. MACRO   ;CHAR,COUNT,DEST
        XREF    STRING..
        MOVE.B  \1,D0
        MOVE.W  \2,D1
        LEA     \3,A0
        JSR     STRING..
        ENDM

DISP.   MACRO
        XREF    DISP..
        LEA     \1,A0
        JSR     DISP..
        ENDM

PROMPT. MACRO
        XREF    PROMPT..
        LEA     \1,A0
        JSR     PROMPT..
        ENDM

CRLF.   MACRO
        XREF    CRLF..
        JSR     CRLF..
        ENDM

ACHAR.  MACRO ;CHAR,DEST
        XREF    ACHAR..
        MOVE.B  \1,D0
        LEA     \2,A0
        JSR     ACHAR..
        ENDM

STR2.   MACRO   ;DEST,FILL CHAR
        XREF    STR2..
        LEA     \1,A0
        MOVE.W  \2,D1
        JSR     STR2..
        ENDM

CLIP.   MACRO   ;COUNT,DEST
        XREF    CLIP..
        MOVE.W  \1,D0
        LEA     \2,A0
        JSR     CLIP..
        ENDM

ERROR   MACRO
        BCS   \1
        ENDM

NOERROR MACRO
        BCC   \1
        ENDM

RETERR   MACRO
         BCC RETERR\@
         RTS
RETERR\@:
         ENDM

WRITEFILE   MACRO ;FILE, STRING, LEN
   MOVE.L   \1,D1
   MOVE.L   \2,D2
   MOVE.L   \3,D3
   MOVE.L   LIBRARY_BASE,A6
   JSR      _LVOWrite(A6)
   ENDM

READFILE    MACRO ;FILE, STRING, LEN
   MOVE.L   \1,D1
   MOVE.L   \2,D2
   MOVE.L   \3,D3
   MOVE.L   LIBRARY_BASE,A6
   JSR      _LVORead(A6)
   ENDM

CALLSYS	MACRO	;OFFSET, BASE
	IFEQ	NARG-2
	MOVE.L	\2,A6
	ENDC
	IFND	_LVO\1
	XREF	_LVO\1
	ENDC
	JSR	_LVO\1(A6)
	ENDM

   XREF  _AbsExecBase
   XREF  _LVOOpenLibrary
   XREF  _LVOInput
   XREF  _LVOOutput
   XREF  _LVOOpen
   XREF  _LVOClose
   XREF  _LVORead
   XREF  _LVOWrite
   XREF  _LVODeleteFile
   XREF  _LVOSetIntVector
   XREF  _LVOOpenDevice
   XREF  _LVOCloseDevice
   XREF  _LVOSendIO
   XREF  _LVODateStamp
   XREF  _LVOLock
   XREF  _LVOUnLock
   XREF  _LVOExamine
   XREF  _LVOExNext
   XREF  _LVOInfo
   XREF  _LVOCurrentDir
   XREF  _LVOParentDir
   XREF  _LVODelay
   XREF  _LVOOpenResource
   XREF  _LVODeviceProc
   XREF  _LVOPutMsg
   XREF  _LVOGetMsg
   XREF  _LVOWaitPort
   XREF  _LVOAllocMem
   XREF  _LVOFreeMem
   XREF  _LVOWaitBlit
   XREF  _LVOOwnBlitter
   XREF  _LVODisownBlitter
   XREF  _LVOFindTask
   XREF  _LVORemTask
   XREF  _LVOWaitForChar


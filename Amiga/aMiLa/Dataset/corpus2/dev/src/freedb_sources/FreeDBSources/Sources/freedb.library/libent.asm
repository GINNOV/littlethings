        SECTION FreeDB,CODE

        NOLIST

        INCLUDE "freedb.library_rev.i"
        INCLUDE "exec/libraries.i"
        INCLUDE "exec/resident.i"
        INCLUDE "exec/initializers.i"
        INCLUDE "exec/lists.i"
        INCLUDE "exec/semaphores.i"
        INCLUDE "utility/hooks.i"

        LIST

        STRUCTURE rexxLibBase,LIB_SIZE
        ULONG   segList
        APTR    sysBase
        APTR    rexxSysBase
        APTR    dosBase
        APTR    utilityBase
        APTR    intuitionBase
        APTR    localeBase
        APTR    muiMasterBase
        STRUCT  libSem,SS_SIZE
        STRUCT  memSem,SS_SIZE
        APTR    pool
        STRUCT  messages,MLH_SIZE
        ULONG   freeMessages
        APTR    appClass
        APTR    opts
        APTR    cat
        ULONG   flags
        ULONG   use
        APTR    iconBase
        LABEL LIBSIZE

        XREF    _LinkerDB
        XREF    _LIBNAME
        XREF    ENDCODE
        XDEF    _ID

        XREF    _openLib
        XREF    _closeLib
        XREF    _expungeLib
        XREF    _initLib
        XREF    _dispatch

        XREF    _FreeDBReadTOCA
        XREF    _FreeDBAllocObjectA
        XREF    _FreeDBClearObject
        XREF    _FreeDBFreeObject
        XREF    _FreeDBGetLocalDiscA
        XREF    _FreeDBSaveLocalDiscA
        XREF    _FreeDBHandleCreateA
        XREF    _FreeDBHandleCommandA
        XREF    _FreeDBHandleSignal
        XREF    _FreeDBHandleWait
        XREF    _FreeDBHandleAbort
        XREF    _FreeDBHandleCheck
        XREF    _FreeDBHandleFree
        XREF    _FreeDBGetDiscA
        XREF    _FreeDBGetString
        XREF    _FreeDBFreeMessage
        XREF    _FreeDBFreeConfig
        XREF    _FreeDBReadConfig
        XREF    _FreeDBSaveConfig
        XREF    _FreeDBConfigChanged
        XREF    _FreeDBPlayMSFA
        XREF    _FreeDBMatchStartA
        XREF    _FreeDBMatchNext
        XREF    _FreeDBMatchEnd
        XREF    _FreeDBSetDiscInfoA
        XREF    _FreeDBSetDiscInfoTrackA
        XREF    _FreeDBCreateAppA

PRI     EQU 0

start:  moveq   #-1,d0
        rts

romtag:
        dc.w    RTC_MATCHWORD
        dc.l    romtag
        dc.l    ENDCODE
        dc.b    RTF_AUTOINIT
        dc.b    VERSION
        dc.b    NT_LIBRARY
        dc.b    PRI
        dc.l    _LIBNAME
        dc.l    _ID
        dc.l    init

_ID:    VSTRING

        CNOP    0,4

init:   dc.l    LIBSIZE
        dc.l    funcTable
        dc.l    dataTable
        dc.l    _initLib

V_DEF   MACRO
    dc.w    \1+(*-funcTable)
    ENDM

funcTable:
        DC.W    -1

        V_DEF   _openLib
        V_DEF   _closeLib
        V_DEF   _expungeLib
        V_DEF   nil
        V_DEF   query

        V_DEF   _FreeDBGetString
        V_DEF   _FreeDBReadTOCA
        V_DEF   _FreeDBAllocObjectA
        V_DEF   _FreeDBClearObject
        V_DEF   _FreeDBFreeObject
        V_DEF   _FreeDBGetLocalDiscA
        V_DEF   _FreeDBSaveLocalDiscA
        V_DEF   _FreeDBHandleCreateA
        V_DEF   _FreeDBHandleCommandA
        V_DEF   _FreeDBHandleSignal
        V_DEF   _FreeDBHandleWait
        V_DEF   _FreeDBHandleAbort
        V_DEF   _FreeDBHandleCheck
        V_DEF   _FreeDBHandleFree
        V_DEF   _FreeDBFreeMessage
        V_DEF   _FreeDBGetDiscA
        V_DEF   _FreeDBFreeConfig
        V_DEF   _FreeDBReadConfig
        V_DEF   _FreeDBSaveConfig
        V_DEF   _FreeDBConfigChanged
        V_DEF   _FreeDBPlayMSFA
        V_DEF   _FreeDBMatchStartA
        V_DEF   _FreeDBMatchNext
        V_DEF   _FreeDBMatchEnd
        V_DEF   _FreeDBSetDiscInfoA
        V_DEF   _FreeDBSetDiscInfoTrackA
        V_DEF   _FreeDBCreateAppA

        DC.W    -1

dataTable:
        INITBYTE LN_TYPE,NT_LIBRARY
        INITLONG LN_NAME,_LIBNAME
        INITBYTE LIB_FLAGS,(LIBF_SUMUSED!LIBF_CHANGED)
        INITWORD LIB_VERSION,VERSION
        INITWORD LIB_REVISION,REVISION
        INITLONG LIB_IDSTRING,_ID
        dc.w     0

        CNOP    0,4

nil:    moveq   #0,d0
        rts

query:  movem.l a1/a4,-(sp)
        lea     _LinkerDB,a4
        subq.l  #4,sp
        movea.l sp,a1
        bsr     _dispatch
        movem.l (sp)+,a0/a1/a4
        rts

        END

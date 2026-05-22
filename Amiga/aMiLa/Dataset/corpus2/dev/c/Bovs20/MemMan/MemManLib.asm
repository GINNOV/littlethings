* Lib.asm - Runtime library interface for Guido - © 1991 Bryan Ford *

        include "exec/types.i"
        include "exec/initializers.i"
        include "exec/libraries.i"
        include "exec/lists.i"
        include "exec/alerts.i"
        include "exec/resident.i"
        include "exec/semaphores.i"
        include "exec/funcdef.i"
        include "exec/exec_lib.i"
        include "bry/macros.i"

VERSION equ     1               ; Don't forget to change the idstring
REVISION equ    0

 STRUCTURE      MemManLibrary,0
        STRUCT  lib_Node,LIB_SIZE
        UBYTE   lib_Flags               ; Defined below
        BYTE    lib_pad
        LONG    lib_SegList             ; Library SegList
        APTR    lib_SysBase             ; A bunch of library pointers
        APTR    lib_DOSBase
        APTR    lib_GfxBase
        APTR    lib_IntuitionBase
        APTR    lib_GadToolsBase        ; From here on are optional libraries
        APTR    lib_AslBase
        APTR    lib_ArpBase
        LABEL   lib_Size

        code    text

        xref    MMInit,MMFinish

dosentry:
        moveq   #-1,d0
        rts

idstring:
        dc.b    "memman.library 1.0 (4-Dec-91) Copyright 1991 Bryan Ford"
        ds.w    0

initdescrip:
        DC.W    RTC_MATCHWORD   ; UWORD RT_MATCHWORD
        DC.L    initdescrip     ; APTR  RT_MATCHTAG
        DC.L    endcode         ; APTR  RT_ENDSKIP
        DC.B    RTF_AUTOINIT    ; UBYTE RT_FLAGS
        DC.B    VERSION         ; UBYTE RT_VERSION
        DC.B    NT_LIBRARY      ; UBYTE RT_TYPE
        DC.B    0               ; BYTE  RT_PRI
        DC.L    libname         ; APTR  RT_NAME
        DC.L    idstring        ; APTR  RT_IDSTRING
        DC.L    init            ; APTR  RT_INIT

init:
        DC.L    lib_Size        ; size of library base data space
        DC.L    functable       ; pointer to function initializers
        DC.L    datatable       ; pointer to data initializers
        DC.L    initroutine     ; routine to run

functable:
        ;------ standard system routines
        dc.l    Open
        dc.l    Close
        dc.l    Expunge
        dc.l    Null

        ;------ my libraries definitions
        dcx.l   MMAddNode
        dcx.l   MMRemNode

        ;------ function table end marker
        dc.l    -1

datatable:
        INITBYTE        LN_TYPE,NT_LIBRARY
        INITLONG        LN_NAME,libname
        INITBYTE        LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
        INITWORD        LIB_VERSION,VERSION
        INITWORD        LIB_REVISION,REVISION
        INITLONG        LIB_IDSTRING,idstring
        dc.l   0

initroutine:
        push    a5
        move.l  d0,a5
        move.l  a6,lib_SysBase(a5)
        move.l  a0,lib_SegList(a5)

        bsr     MMInit
        tst.l   d0
        bz.s    \err

        move.l  a5,d0
\err
        pop     a5
        rts

Open:      ; ( libptr:a6, version:d0 )
        addq.w  #1,LIB_OPENCNT(a6)
        bclr    #LIBB_DELEXP,lib_Flags(a6)
        move.l  a6,d0
        rts

Close:      ; ( libptr:a6 )
        cq      d0
        subq.w  #1,LIB_OPENCNT(a6)
        bnz.s   \noexp
        btst    #LIBB_DELEXP,lib_Flags(a6)
        bnz.s   Expunge
\noexp
        rts

Expunge:   ; ( libptr: a6 )
        apush
        move.l  a6,a5
        move.l  lib_SysBase(a5),a6

        ;------ see if anyone has us open
        tst.w   LIB_OPENCNT(a5)
        bz.s   1$

        ;------ it is still open.  set the delayed expunge flag
        bset    #LIBB_DELEXP,lib_Flags(a5)
        cq      d0
        b.s     9$
1$
        bsr     MMFinish

        move.l  lib_SegList(a5),d2

        ;------ unlink from library list
        move.l  a5,a1
        jsr     _LVORemove(a6)

        ;------ free our memory
        moveq   #0,d0
        move.l  a5,a1
        move.w  LIB_NEGSIZE(a5),d0
        sub.l   d0,a1
        add.w   LIB_POSSIZE(a5),d0
        jsr     _LVOFreeMem(a6)

        move.l  d2,d0
9$
        apop
        rts

Null:
        moveq   #0,d0
        rts

libname         dc.b    "memman.library",0

endcode:

        end

********************************************************************************
*
*                                  MemMan
*                                Version 3.0
*                            Low-Memory Manager
*                       Copyright 1992 Bryan Ford
*               See MemMan.doc for distribution requirements
*
********************************************************************************
* $Id$
* Assemble with A68k version >2.71.

        include "exec/types.i"
        include "exec/lists.i"
        include "exec/ables.i"
        include "exec/memory.i"
        include "exec/libraries.i"
        include "exec/semaphores.i"
        include "exec/funcdef.i"
        include "exec/exec_lib.i"
        include "bry/macros.i"
        include "bry/memman.i"

_intena equ     $dff09a

 STRUCTURE      MemManSem,SS_SIZE       ; SignalSemaphore
        UBYTE   mms_MemCrunch           ; Flag: we're currently having a memory crunch
        BYTE    mms_pad
        ULONG   mms_AppCount            ; Number of apps using MemMan now
        STRUCT  mms_MMList,MLH_SIZE     ; List we link MMNodes onto
        LABEL   mms_Code                ; Copied MemMan library code
        ; Structure is continued farther down... (hehe)

        code    text

        xdef    MMInit,MMFinish,MMAddNode,MMRemNode
        xdef    _MMInit,_MMFinish,_MMAddNode,_MMRemNode

* This code is copied into the global MemManSem structure.
* The first six bytes are overwritten with a JMP instruction
* whenever MemMan is not in use.
* Immediately after that is the old AllocMem vector
* (the last part of the JSR instruction).
* Yup, self-modifying code - isn't it beautiful? :-)
* This makes each AllocMem() call slightly faster and should be fine if we
* are very careful of caching (which we are).  Since the only self-modifying
* code we use is in MEMF_PUBLIC memory, there should be no virtual or protected
* memory problems either.
codest:
        movem.l d0/d1,-(sp)             ; Save registers (4 bytes)

jsrinst:
        jsr     $12345678               ; Call regular AllocMem() (2 + 4 bytes)
        tst.l   d0
        bz.b    \failed

\out
        addq    #8,sp                   ; Succeeded on the first try
        rts

\failed:
        cmp.b   codest-mms_Code+mms_MemCrunch(pc),d0    ; Avoid recursion from GetRidFuncs
        bz.b    \out

        movem.l a2-a3,-(sp)

        DISABLE a0      ; AllocMem only requires FORBID, but the MMList requires DISABLE

        lea     codest-mms_Code+mms_MemCrunch(pc),a0
        st.b    (a0)

        move.l  codest-mms_Code+mms_MMList+LH_HEAD(pc),a2
        move.l  jsrinst+2(pc),a3

\retry:
        move.l  LN_SUCC(a2),d1          ; Traverse the list forwards
        bz.s    \fin                    ; (kill HIGHEST priority nodes first)

        move.l  mmn_GetRidFunc(a2),a1   ; Call the GetRidFunc
        move.l  mmn_GetRidData(a2),a0
        move.l  d1,a2                   ; Find next node BEFORE call
        movem.l 8(sp),d0/d1
        jsr     (a1)
        tst.l   d0
        bz.b    \retry

        movem.l 8(sp),d0/d1             ; Try allocating again
        jsr     (a3)
        tst.l   d0
        bz.b    \retry

\fin:
        move.l  a0,-(sp)                ; Some nasty apps rely on d1/a0/a1...

        lea     codest-mms_Code+mms_MemCrunch(pc),a0
        clr.b   (a0)

        ENABLE  a0

        movem.l (sp)+,a0/a2-a3
        addq.l  #8,sp                   ; Pop AllocMem args off stack
        rts

semname:
        dc.b    "MemMan21",0
        ds.w    0

codefin:

        ; Continuation of MemManSem structure (now that we know the code size)
        STRUCT  mms_Code_def2,(codefin-codest)
        LABEL   mms_SIZEOF

*** Initialize MemMan - patches AllocMem()
* Returns:
* d0 = Nonzero if successful, zero if failed
MMInit:
_MMInit:
        apush
        move.l  4,a6

        FORBID

        lea     semname(pc),a1          ; See if the semaphore already exists
        jsr     _LVOFindSemaphore(a6)
        move.l  d0,semaphore
        bnz     \oldsem

\newsem:
        move.l  #mms_SIZEOF,d0          ; Allocate the public memory block
        move.l  #MEMF_PUBLIC!MEMF_CLEAR,d1
        jsr     _LVOAllocMem(a6)
        move.l  d0,semaphore
        bz      \outnomem
        move.l  d0,a5

        lea     mms_MMList(a5),a0       ; Initialize the data area
        NEWLIST a0
        move.w  #1,mms_AppCount(a5)
        lea     mms_Code+(semname-codest)(a5),a0
        move.l  a0,LN_NAME(a5)

        lea     codest(pc),a0           ; Copy the public code
        lea     mms_Code(a5),a1
        move.l  #codefin-codest,d0
        jsr     _LVOCopyMem(a6)

        move.l  a6,a1                   ; SetFunction AllocMem()
        lea     mms_Code(a5),a0
        move.l  a0,d0
        movea.w #_LVOAllocMem,a0
        jsr     _LVOSetFunction(a6)

        move.l  d0,mms_Code+(jsrinst-codest)+2(a5)      ; Set JSR vector

        cmpi.w  #36,LIB_VERSION(a6)     ; Clear the cache after setting vector
        blo.b   \newsemcc
        jsr     _LVOCacheClearU(a6)
\newsemcc:

        move.l  a5,a1                   ; Add to system semaphore list
        move.l  a5,a0                   ; BUUUUUUUUUUUUUUUG in 1.3!!!
        jsr     _LVOAddSemaphore(a6)

        bra     \outok

\oldsem:                                ; Semaphore was already in memory
        move.l  d0,a5

        addq.w  #1,mms_AppCount(a5)

        cmp.w   #$4ef9,mms_Code(a5)     ; See if we have to reactivate the code
        bne.s   \codefine

        move.l  codest(pc),mms_Code(a5) ; Restore the first six bytes
        move.w  codest+4(pc),mms_Code+4(a5) ; No more or we'll trash the vector

        cmpi.w  #36,LIB_VERSION(a6)     ; Clear the cache after changing code
        blo.s   \oldsemcc
        jsr     _LVOCacheClearU(a6)
\oldsemcc:
\codefine:
\outok:
        lea     mms_MMList(a5),a0
        move.l  a0,mmlist

        PERMIT

        moveq   #1,d0
\out:
        apop
        rts

\outnomem
        PERMIT
        moveq   #0,d0
        bra.b   \out

*** Uninstall our application from the memory manager
MMFinish:
_MMFinish:
        apush
        move.l  4,a6

        move.l  semaphore,d0            ; Never successfully initialized?
        bz      \out
        move.l  d0,a5

        FORBID

        subq.w  #1,mms_AppCount(a5)
        bnz.s   \otherapps

        move.w  #$4ef9,mms_Code(a5)     ; Quick bounce with a JMP instruction
        move.l  mms_Code+(jsrinst-codest)+2(a5),mms_Code+2(a5)

        cmpi.w  #36,LIB_VERSION(a6)     ; Clear the cache after changing code
        blo.s   \cc
        jsr     _LVOCacheClearU(a6)
\cc:

\otherapps:

        PERMIT

        clr.l   semaphore               ; Safety

\out:
        apop
        rts


*** Add an MMNode (if it wasn't already on the MMList)
* a1 = Pointer to MMNode
MMAddNode:
_MMAddNode:
        DISABLE a0

        cmp.b   #MMNT_LINKED,LN_TYPE(a1)        ; Don't add a node twice
        bne.b   mmadd

        ENABLE  a0,NOFETCH
        rts

mmadd
        move.l  a6,-(sp)
        move.l  a0,a6

        move.b  #MMNT_LINKED,LN_TYPE(a1)        ; Mark it as added

        move.l  mmlist,a0       ; Add it to the global list in prioritized order
        jsr     _LVOEnqueue(a6)

        ENABLE
        move.l  (sp)+,a6
        rts


*** Remove an MMNode (only if it was on the MMList)
* a1 = Pointer to MMNode
MMRemNode:
_MMRemNode:
        DISABLE a0
        cmp.b   #MMNT_LINKED,LN_TYPE(a1)        ; Don't remove unless it was added
        beq.b   mmremove
        ENABLE  a0,NOFETCH
        rts

mmremove
        clr.b   LN_TYPE(a1)     ; Mark it as not added

        REMOVE                  ; Remove it from the public MMList

        ENABLE  a0
        rts

        bss     __MERGED

semaphore       ds.l    1               ; Pointer to public semaphore
mmlist          ds.l    1               ; Points to mms_MMList in MemManSem

        end

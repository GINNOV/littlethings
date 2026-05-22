********************************************************************
*
*                                 Bovs.asm
*                        Bryan's Overlay Supervisor
*                       Copyright (C) 1991 Bryan Ford
*
********************************************************************
* $Id: Bovs.asm,v 1.2 92/04/10 15:36:56 BAF Exp $
* Assemble with A68k version >2.71

* If OVERLAY is 0, the overlay system is disabled.
OVERLAY set     1

* If DETACH is 0, the startup code loses the ability to auto-detach.
DETACH  set     1

        include "exec/types.i"
        include "exec/tasks.i"
        include "exec/libraries.i"
        include "exec/alerts.i"
        include "exec/memory.i"
        include "exec/execbase.i"
        include "exec/funcdef.i"
        include "exec/exec_lib.i"
        include "dos/dos.i"
        include "dos/dosextens.i"
        include "dos/rdargs.i"
        include "dos/dos_lib.i"
        include "workbench/startup.i"
        include "bry/macros.i"
        include "bry/memman.i"

* Main program must define these:
        xref    _stack                  ; Stack size for subprocess when run from CLI
        xref    _progname               ; Pointer to program name string
        xref    _priority               ; Priority for process detached from CLI

        xref    _argtemplate            ; Pointer to ReadArgs template for 2.0 startup
        xref    _argexthelp             ; Pointer to ReadArgs extended help string
        xref    _argarray               ; ReadArgs array of longwords to fill

        xdef    LockOverlay,UnlockOverlay,ResCall
        xdef    @LockOverlay,@UnlockOverlay,_ResCall

        IFNE    OVERLAY
* OvNode - Structure used to keep track of loaded overlays
 STRUCTURE      OvNode,mmn_SIZEOF       ; First a MemMan node
        BPTR    on_SegList              ; SegList for node if currently loaded
        UWORD   on_LockCount            ; Number of times this node is locked
        LABEL   on_SIZEOF

* OvTabEntry - Offsets within the overlay table.
 STRUCTURE      OvTabEntry,0
        ULONG   ot_SeekOfs              ; Load file position
        APTR    ot_OvNode               ; Pointer to OvNode structure
        LONG    ot_dummy2
        ULONG   ot_Level                ; Overlay level - always 1
        ULONG   ot_Ordinate             ; Ordiinate number of node
        ULONG   ot_FirstHunk            ; Position to load into in hunk table
        ULONG   ot_SymbolHunk           ; Where symbol is found
        ULONG   ot_SymbolOfs            ; Where in that hunk
        LABEL   ot_SIZEOF
        ENDC

        code    NTRYHUNK

        xref    _LinkerDB,__BSSBAS,__BSSLEN
        xref    MMInit
        xref    @Main,@PreStart

first:
        IFNE    OVERLAY
        bra     startup
        cnop    0,4

* This next word serves to identify the overlay
* supervisor to 'unloader'.

                dc.l    $ABCD           ; Magic unloader cookie
loaddat:
loadstream      ds.l    1               ; Overlay input stream
loadovtab       ds.l    1               ; Overlay table (Machine address)
loadhtab        ds.l    1               ; Hunk table    (BCPL address)
loadglobvec     ds.l    1               ; Global vector (Machine address)
        ENDC

*** startup - Startup code to initialize the overlay system and detach CLI processes
startup:
        lea     _LinkerDB,a4            ; Find data segment
        move.l  4,a6                    ; Find exec.library

        lea     __BSSBAS,a2             ; Clear uninitialized data
        moveq   #0,d1
        move.l  #__BSSLEN,d2
        bra.s   12$
11$     move.l  d1,(a2)+
12$     dbf     d2,11$

        move.l  a6,_SysBase(a4)         ; Store SysBase for everyone else
        move.l  sp,origsp(a4)           ; Save original SP (may change later if we detach)

        movem.l d0/a0,cliargs(a4)       ; Store CLI argument line

        lea     dosname(pc),a1          ; Open dos.library
        moveq   #33,d0                  ; Requires at least Kickstart 1.2
        jsr     _LVOOpenLibrary(a6)
        moveq   #ERROR_INVALID_RESIDENT_LIBRARY,d1
        move.l  d0,_DOSBase(a4)
        bz      \fatalerr

        IFNE    OVERLAY
        lea     loadstream(pc),a2       ; Steal the file handle
        move.l  (a2),stream(a4)
        clr.l   (a2)+

        move.l  (a2)+,a5                ; Overlay data table (a5)
        move.l  (a2),a3                 ; Hunk table (a3)
        add.l   a3,a3
        add.l   a3,a3

        move.l  -(a3),d0                ; Allocate room for a copy of both tables
        add.l   -(a5),d0
        subq.l  #4,d0
        move.l  d0,d2
        moveq   #0,d1
        jsr     _LVOAllocMem(a6)
        moveq   #ERROR_NO_FREE_STORE,d1
        tst.l   d0
        bz      \fatalerr

        move.l  d0,a0                   ; Copy hunk table
        move.l  d2,(a0)+
        move.l  a0,htab(a4)
        move.l  (a3)+,d0
        lsr.l   #2,d0
        subq.l  #1+1,d0
21$     move.l  (a3)+,(a0)+
        dbra    d0,21$
        move.l  (a5)+,d0
        move.l  (a5),d1                 ; Find first overlay data table node
        lsl.l   #2,d1
        add.l   a0,d1
        move.l  d1,ovdtab(a4)
        lsr.l   #2,d0                   ; Copy overlay table
        subq.l  #1+1,d0
22$     move.l  (a5)+,(a0)+
        dbra    d0,22$
        move.l  a0,ovdtabend(a4)
        ENDC

        jsr     MMInit                  ; Initialize the memory manager
        moveq   #ERROR_NO_FREE_STORE,d1
        tst.l   d0
        bz      \fatalerr

        move.l  ThisTask(a6),a2         ; Find our process (a2)

        move.l  a2,a1                   ; Set our priority (save old priority and restore it later)
        move.l  _priority,d0
        jsr     _LVOSetTaskPri(a6)
        move.b  d0,origpri(a4)
        st.b    prichanged(a4)

        move.l  pr_CurrentDir(a2),olddir(a4)    ; Save the current directory

        tst.l   pr_CLI(a2)
        bnz.s   \fromcli

\fromwb:
        lea     pr_MsgPort(a2),a0       ; Get the startup message
        move.l  a0,d2
        jsr     _LVOWaitPort(a6)
        move.l  d2,a0
        jsr     _LVOGetMsg(a6)
        move.l  d0,a3
        move.l  a3,_WBenchMsg(a4)

        move.l  sm_ArgList(a3),a1       ; Use program's directory
        move.l  wa_Lock(a1),d1
        move.l  _DOSBase(a4),a6
        jsr     _LVOCurrentDir(a6)

        moveq   #0,d0                   ; Call PreStart routine
        move.l  a3,a0
        jsr     @PreStart

        pea     _BExit                  ; Call the main program routine
        moveq   #0,d0
        move.l  a3,a0
        jmp     @Main

\fromcli:
        move.l  _DOSBase(a4),a6

        cmp.w   #36,LIB_VERSION(a6)     ; Use 2.0's ReadArgs if possible
        blo.s   79$
        moveq   #DOS_RDARGS,d1
        moveq   #0,d2
        jsr     _LVOAllocDosObject(a6)
        move.l  d0,rdargs(a4)
        bz      \doserr
        move.l  d0,d3
        move.l  d0,a0
        move.l  _argexthelp,RDA_ExtHelp(a0)
        move.l  _argtemplate,d1
        move.l  #_argarray,d2
        jsr     _LVOReadArgs(a6)
        tst.l   d0
        bz      \doserr
        moveq   #-1,d0
        move.l  d0,_argsparsed(a4)
79$

        movem.l cliargs(a4),d0/a0       ; Call the PreStart routine
        jsr     @PreStart

        IFNE    DETACH
        move.l  a2,parenttask(a4)       ; Make sure child knows where to find us

        move.l  #SIGBREAKF_CTRL_F,d7    ; Make sure CTRL-F flag is cleared
        move.l  d7,d1
        moveq   #0,d0
        move.l  _SysBase(a4),a6
        jsr     _LVOSetSignal(a6)

        move.l  pr_CurrentDir(a2),d1    ; Get an initial directory for the subprocess
        move.l  _DOSBase(a4),a6
        jsr     _LVODupLock(a6)
        move.l  d0,dupdir(a4)

        lea     first-4(pc),a0          ; Detach the segment list
        move.l  (a0),splitseg(a4)
        clr.l   (a0)

        move.l  _progname,d1            ; Start the child process
        move.l  _priority,d2
        move.l  #cliseg,d3
        lsr.l   #2,d3
        move.l  _stack,d4
        jsr     _LVOCreateProc(a6)
        tst.l   d0
        bz.b    \callmainimmed

        move.l  _SysBase(a4),a6

        tst.b   prichanged(a4)          ; Restore the CLI priority level
        bz.b    \noresetpri
        move.l  ThisTask(a6),a1
        move.b  origpri(a4),d0
        jsr     _LVOSetTaskPri(a6)
\noresetpri

        move.l  d7,d0                   ; Wait for the go-ahead from the child
        jsr     _LVOWait(a6)

        moveq   #0,d0                   ; Return success code immediately
        rts

\callmainimmed
        move.l  splitseg(a4),first-4    ; Couldn't create process - reattach and run normally
        clr.l   splitseg(a4)
        ENDC

        pea     _BExit                  ; Call the main program
        movem.l cliargs(a4),d0/a0
        jmp     @Main

\doserr:
        jsr     _LVOIoErr(a6)           ; Find the secondary error code
        move.l  d0,d1

\fatalerr:
        cmp.w   #36,LIB_VERSION(a6)     ; Display an appropriate error message
        blo.b   \no20err
        move.l  d1,d3
        move.l  _progname,d2
        jsr     _LVOPrintFault(a6)
        move.l  d3,d1
\no20err
        moveq   #10,d0
\brexit
        jmp     BRExit

dosname dc.b    "dos.library",0

        code    text

        xref    MMFinish,MMAddNode,MMRemNode

        IFNE    OVERLAY
*** _ovlyMgr - Entrypoint called by the linker when overlaid functions are called
* d0 = Entrypoint number
* a0/a1 = Parameters from caller
        xdef    _ovlyMgr
_ovlyMgr:
        movem.l d2-d3/a0-a3/a5-a6,-(sp) ; 8 longwords

        move.l  ovdtab,a3               ; Find overlay data table node (a3)
        move.l  a3,a2
        lsl.w   #2,d0
        adda.w  d0,a3

        move.l  ot_OvNode(a3),d0        ; See if we already know its OvNode
        bnz.s   \alreadyfound

        move.l  ot_SeekOfs(a3),d0       ; Find the first entry in this node (a2)
        moveq   #ot_SIZEOF,d1
        bra.s   \findfirst_a
\findfirst:
        add.l   d1,a2
\findfirst_a:
        cmp.l   ot_SeekOfs(a2),d0
        bne.s   \findfirst

        move.l  ot_OvNode(a2),d0        ; See if the OvNode is already allocated
        bnz.s   \alreadyallocated

\retryalloc:
        moveq   #on_SIZEOF,d0           ; Allocate the OvNode
        move.l  #MEMF_PUBLIC!MEMF_CLEAR,d1
        move.l  4,a6
        jsr     _LVOAllocMem(a6)
        move.l  d0,ot_OvNode(a2)        ; Store the OvNode in the first OvTabEntry
        bz.s    \retryalloc             ; FIXME: Shouldn't there be a better way?

        move.l  d0,a0                   ; Initialize the node
        lea     getridfunc(pc),a1
        move.l  a1,mmn_GetRidFunc(a0)
        move.l  a0,mmn_GetRidData(a0)

\alreadyallocated:
        move.l  d0,ot_OvNode(a3)        ; Store OvNode into current OvTabEntry

\alreadyfound:
        move.l  d0,a5                   ; OvNode into (a5)

        move.l  a5,a1                   ; Lock this node in memory during the call
        bsr     lockoverlay

        move.l  on_SegList(a5),d0       ; See if the code is loaded
        bnz     \alreadyloaded

        lea     rescallret(pc),a0       ; Don't load if the call is coming through ResCall
        cmp.l   8*4(sp),a0
        beq     \rescallquit            ; Note: D0 = 0 from above test

* Now seek to the segment and load it.  If we fail (probably because
* the user removed the disk), then retry until successful.  This has
* the effect of continually reprompting the user to insert the disk
* until he/she obeys.
        move.l  _DOSBase,a6
\retryload:
        move.l  stream,d1               ; Find hunk position in load file
        move.l  ot_SeekOfs(a3),d2
        moveq   #OFFSET_BEGINNING,d3
        jsr     _LVOSeek(a6)
        tst.l   d0
        bmi.s   \retryload

        moveq   #0,d1                   ; Special calling format - NULL for name
        move.l  htab,d2                 ; Hunk table
        lsr.l   #2,d2
        move.l  stream,d3               ; File handle
        jsr     _LVOLoadSeg(a6)
        move.l  d0,on_SegList(a5)
        ble.s   \retryload

\alreadyloaded:
        move.w  ot_SymbolHunk+2(a3),d1  ; Find hunk function is in
        sub.w   ot_FirstHunk+2(a3),d1
        bra.b   \hunkhuntin
\hunkhunt
        move.l  (a2),d0
\hunkhuntin
        lsl.l   #2,d0
        move.l  d0,a2
        dbra    d1,\hunkhunt

        add.l   ot_SymbolOfs(a3),a2     ; Call function (d0=OvNode, a0-a1=Passed)
        move.l  a5,d0
        movem.l 8(sp),a0-a1
        jsr     (a2)

\rescallquit
        move.l  d0,d2                   ; Unlock the node
        move.l  a5,a1
        bsr     unlockoverlay
        move.l  d2,d0

        movem.l (sp)+,d2-d3/a0-a3/a5-a6
        rts

*** LockOverlay - Lock an OvNode
LockOverlay:
@LockOverlay:
        move.l  d0,a1
lockoverlay:
        addq.w  #1,on_LockCount(a1)     ; Increment nesting counter

        bra     MMRemNode               ; Take the node off the dead-list

*** UnlockOverlay - Unlock an OvNode
UnlockOverlay:
@UnlockOverlay:
        move.l  d0,a1
unlockoverlay:
        subq.w  #1,on_LockCount(a1)     ; Decrement nesting counter
        bz      MMAddNode               ; If zero, add to the dead-list
        rts

*** ResCall - Special call routine - calls a function ONLY if it's already resident
*** (if it's not resident, it returns immediately without loading the function.)
* a2 = Pointer to routine to call
* a0-a1 = Parameters to routine
* d0 = Return value from routine if resident, zero if the routine wasn't resident.
ResCall:
_ResCall:
        jsr     (a2)
rescallret                              ; ovlyMgr watches for this return address...
        rts
        ENDC

        IFEQ    OVERLAY
*** Fake the LockOverlay and UnlockOverlay functions for the non-overlaid versions
LockOverlay:
@LockOverlay:
UnlockOverlay:
@UnlockOverlay:
        rts

ResCall:
_ResCall:
        jmp     (a2)
        ENDC

        IFNE    DETACH
*** cliseg - Fake SegList for the CLI subprocess to start at
        cnop    0,4
        dc.l    0                       ; Segment size
cliseg: dc.l    0                       ; Link to next segment

        lea     _LinkerDB,a4            ; Find the data segment
        move.l  sp,origsp(a4)           ; Save the stack pointer

        movem.l cliargs(a4),d2/a0       ; Copy the arguments
        move.l  d2,d0
        addq.l  #4-1,d0
        andi.b  #$fc,d0
        sub.l   d0,sp
        move.l  sp,a1
        move.l  d2,d0
        bra.s   12$
11$     move.b  (a0)+,(a1)+
12$     dbra    d0,11$

        move.l  _SysBase(a4),a6         ; Signal parent task to get lost
        move.l  parenttask(a4),a1
        move.l  #SIGBREAKF_CTRL_F,d0
        jsr     _LVOSignal(a6)

        move.l  _DOSBase(a4),a6         ; Set the initial directory
        move.l  dupdir(a4),d1
        jsr     _LVOCurrentDir(a6)
        move.l  d0,olddir(a4)

        move.l  d2,d0                   ; Call the main program
        move.l  sp,a0
        jsr     @Main

        ENDC
        ; fall through...
*** BExit - Exit the program with a success return code
        xdef    BExit,_BExit,@BExit
BExit:
_BExit:
@BExit:
        moveq   #0,d0
        moveq   #0,d1
        ; fall through...
*** BRExit - Exit the program with a given return code
* d0 = Return code
* d1 = Secondary return code
        xdef    BRExit,@BRExit
BRExit:
@BRExit:
        lea     _LinkerDB,a4            ; Restore data segment
        move.l  origsp(a4),sp           ; Restore SP

        movem.l d0/d1,-(sp)             ; Save returncode

        move.l  _DOSBase(a4),a6

        move.l  rdargs(a4),d1           ; Free all command-line arguments
        bz.b    79$
        move.l  d1,d2
        jsr     _LVOFreeArgs(a6)
        moveq   #DOS_RDARGS,d1
        jsr     _LVOFreeDosObject(a6)
79$
        IFNE    OVERLAY
        move.l  stream(a4),d1           ; Close load file
        bz.s    49$
        jsr     _LVOClose(a6)
        ENDC
49$
        move.l  olddir(a4),d1           ; Return to the original current directory
        bz.b    \noolddir
        jsr     _LVOCurrentDir(a6)
\noolddir

        move.l  dupdir(a4),d1           ; Free the initial directory
        bz.s    59$
        jsr     _LVOUnLock(a6)
59$
        move.l  _SysBase(a4),a6

        IFNE    OVERLAY
        move.l  ovdtab(a4),d0           ; Free all overlays
        bz.s    19$
        move.l  d0,a2
        move.l  ovdtabend(a4),a3
1$      move.l  ot_OvNode(a2),d0
        bz.s    18$
        move.l  d0,a5
        move.l  a2,a0                   ; Clear out all later nodes pointing to this same OvNode
        bra.b   \clrseekin
\clrseek
        cmp.l   ot_OvNode(a0),a5
        bne.b   \clrseekin
        clr.l   ot_OvNode(a0)
\clrseekin
        lea     ot_SIZEOF(a0),a0
        cmp.l   a3,a0
        bne.b   \clrseek
        move.l  a5,a0                   ; Unload the SegList
        bsr     getridfunc
        move.l  a5,a1
        moveq   #on_SIZEOF,d0
        jsr     _LVOFreeMem(a6)
18$     lea     ot_SIZEOF(a2),a2
        cmp.l   a2,a3
        bne.s   1$
19$
        move.l  htab(a4),d0             ; Free the hunk and overlay tables
        bz.s    29$
        move.l  d0,a1
        move.l  -(a1),d0
        jsr     _LVOFreeMem(a6)
        ENDC
29$
        move.l  ThisTask(a6),a2         ; Find our process pointer

        tst.b   prichanged(a4)          ; Set our priority back to what it was originally
        bz.b    \noresetpri
        move.l  a2,a1
        move.b  origpri(a4),d0
        jsr     _LVOSetTaskPri(a6)
\noresetpri

        move.l  _WBenchMsg(a4),d2       ; Return the Workbench message
        bz.b    39$
        jsr     _LVOForbid(a6)          ; Don't let Workbench unload us yet!
        move.l  d2,a1
        jsr     _LVOReplyMsg(a6)
39$
        move.l  _DOSBase(a4),d7         ; Close dos.library
        bz.b    69$
        move.l  d7,a1
        jsr     _LVOCloseLibrary(a6)
69$
        bsr     MMFinish                ; Close down the memory manager

        move.l  (sp)+,d0                ; Pop the returncode
        move.l  (sp)+,pr_Result2(a2)

        IFNE    DETACH
        move.l  splitseg(a4),d1         ; Unload the program code
        bz.b    99$
        move.l  d7,a6
        jmp     _LVOUnLoadSeg(a6)
        ENDC
99$     rts

        IFNE    OVERLAY
*** getridfunc - Get rid of an OvNode's SegList
* a0 = OvNode
* Returns:
* d0 = Nonzero if we freed anything
getridfunc:
        movem.l a2/a6,-(sp)
        move.l  a0,a2

        move.l  a0,a1                   ; No need to keep it on the dead-list
        bsr     MMRemNode

        move.l  on_SegList(a2),d0       ; Un-load the SegList
        bz.b    \out
        move.l  d0,d1
        move.l  _DOSBase,a6
        jsr     _LVOUnLoadSeg(a6)
        clr.l   on_SegList(a2)

        moveq   #1,d0
\out    movem.l (sp)+,a2/a6
        rts
        ENDC

        bss     __MERGED

        xdef    _SysBase,_DOSBase,_WBenchMsg,_argsparsed

_SysBase        ds.l    1               ; System libraries
_DOSBase        ds.l    1

_WBenchMsg      ds.l    1               ; If we came from Workbench

_argsparsed     ds.l    1               ; Nonzero if arguments were already parsed with ReadArgs()

                IFNE    OVERLAY
stream          ds.l    1               ; Load file handle
htab            ds.l    1               ; Fake hunk table
ovdtab          ds.l    1               ; Overlay data table
ovdtabend       ds.l    1               ; End of overlay data table
                ENDC

                IFNE    DETACH
splitseg        ds.l    1               ; First segment after NTRYHUNK

parenttask      ds.l    1               ; Original CLI process
                ENDC

origsp          ds.l    1               ; Original sub-process SP

cliargs:                                ; Command-line arguments
cliarglen       ds.l    1
cliargstr       ds.l    1

dupdir          ds.l    1               ; DupLock'd directory we need to free
olddir          ds.l    1               ; Original current directory supplied by the OS

rdargs          ds.l    1               ; RDArgs structure returned by ReadArgs

prichanged      ds.b    1               ; Flag: Priority changed
origpri         ds.b    1               ; Original task priority


        end


;***************************************************************************;
;
; SysTracker version 0.x assembly patch support routines.
;
; Created: Thu/4/Nov/1999
;
; Copyright © 1999 Andrew Bell. All rights reserved.
;
;***************************************************************************;

                ; Because of the random and really annoying lock up
                ; bugs between Hisoft C++ and MaxonASM, This source is
                ; compiled with the excellent PhxAss assembler v4.xx by
                ; Frank Wille. This time the free software wins over the
                ; expensive commercial bugware. :-/

                MC68020

                IFD     _PHXASS_
                OPT     3
                TTL     st_patches
                ENDC

;***************************************************************************;
; System Includes ;

                incdir  mdev:amiga/asm-inc
                include exec/macros.i
                include exec/ports.i
                include exec/nodes.i
                include exec/memory.i
                include dos/dosextens.i
                include utility/tagitem.i
                include graphics/text.i

;***************************************************************************;
; Defines and external references ;

FALSE           =       0
TRUE            =       1

PATCHREGS       reg     d1-d7/a0-a6     ; Keep all but D0.
PATCHREGS_ALL   reg     d0-d7/a0-a6     ; Keep all.

                        rsset   0               ; PatchMsg
pmsg_MsgHeader          rs.b    MN_SIZE
pmsg_ID                 rs.l    1
pmsg_TaskPtr            rs.l    1
pmsg_TaskName           rs.l    1
pmsg_TaskType           rs.l    1
pmsg_TaskFrozen         rs.w    1
pmsg_Padding01          rs.w    1
pmsg_CmdName            rs.l    1
pmsg_LaunchType         rs.l    1
pmsg_SegList            rs.l    1
pmsg_LibType            rs.l    1
pmsg_LibName            rs.l    1
pmsg_LibVer             rs.l    1
pmsg_LibBase            rs.l    1
pmsg_DevName            rs.l    1
pmsg_DevUnitNum         rs.l    1
pmsg_DevIOReq           rs.l    1
pmsg_DevFlags           rs.l    1
pmsg_FontTextAttr       rs.l    1
pmsg_FontTextFont       rs.l    1
pmsg_FontName           rs.l    1
pmsg_FontYSize          rs.w    1
pmsg_FontStyle          rs.b    1
pmsg_FontFlags          rs.b    1
pmsg_FHName             rs.l    1       ; UBYTE *
pmsg_FHMode             rs.l    1       ; Signed LONG
pmsg_FH                 rs.l    1       ; BPTR
pmsg_LockName           rs.l    1       ; UBYTE *
pmsg_LockMode           rs.l    1       ; Signed LONG
pmsg_Lock               rs.l    1       ; BPTR
pmsg_CurDirName         rs.l    1       ; UBYTE *
pmsg_SIZEOF             rs.l    0

LT_NA                   = 0        ; For pmsg_LaunchType
LT_CLI                  = 1
LT_WB                   = 2

PMSGID_ALL              = -1
PMSGID_UNKNOWN          =  0
PMSGID_OPENLIBRARY      =  1
PMSGID_OPENDEVICE       =  2
PMSGID_CLOSELIBRARY     =  3
PMSGID_CLOSEDEVICE      =  4
PMSGID_OPENFONT         =  5
PMSGID_CLOSEFONT        =  6
;PMSGID_OPENDISKFONT    =  7 ; *** Obsolete ***
;PMSGID_MAKELIBRARY     =  8 ; *** Obsolete ***
PMSGID_OPEN             =  9
PMSGID_CLOSE            =  10
PMSGID_LOCK             =  11
PMSGID_UNLOCK           =  12
PMSGID_OPENFROMLOCK     =  13

BUFLEN                  = 256

                xref    _LVOPutMsg
                xref    _LVOFindTask
                xref    _LVOOpenLibrary
                xref    _LVOCloseLibrary
                xref    _LVOObtainSemaphore
                xref    _LVOReleaseSemaphore
                xref    _LVOAllocPooled
                xref    _LVOFreePooled
                xref    _LVOLock
                xref    _LVOUnLock
                xref    _LVOOpenFont
                xref    _LVOCloseFont
                xref    _LVONameFromLock
                xref    _LVOGetCurrentDirName
                xref    _LVOIoErr
                xref    _LVOSetIoErr

;***************************************************************************;
; Assorted macros ;

PUSH            MACRO
                movem.l \1,-(sp)
                ENDM

PULL            MACRO
                movem.l (sp)+,\1
                ENDM

CALLOS          MACRO
                jsr     _LVO\1(a6)
                ;move.l #$a000dead,a0   ; This is temporary.
                ;move.l #$a100dead,a1
                ENDM

PATCHID         MACRO
                ;
                ; This is a small sig that allows virus checkers and the
                ; like to quickly identify our patches.
                ;
                bra.b   \@_SkipID
                dc.b    "«« SysTracker-Patch »»"
                cnop    0,4
\@_SkipID       
                ENDM

NEWPMSG         MACRO   ; \1 = ID, \2 = Exit label
                ;
                bsr     _PATCH_CreatePatchMsg
                beq.b   \2
                move.l  d0,a2
                move.l  \1,d0
                move.l  d0,pmsg_ID(a2)
                ;
                ENDM

;***************************************************************************;
; Notes ;
;
; - Most of the code below is called on the context of alien tasks, this
;   means all of the code MUST be thread safe, if this is not possible
;   semaphores need to be used.
;
; - Always make sure the IoErr() code is kept intact if calling functions
;   that modify it. Programs like Multiview and CED v4 tend to get very
;   upset when their IoErr() code is modified by a patch. In fact, it took
;   me many hours to track down a bug that was caused by this.
;
; - Stack usage *really* needs to be reduced. ATM, the patches push all
;   registers onto the stack, regardless of whether they're being used or
;   not.
;
; - Some of these routines could easily be upcoded to C, but this would
;   probably impact on SysTracker's performance, in a big way.
;

;**************************************************************************;
; Patch for exec.library/OpenLibrary() ;

                xdef    _PATCH_NewOpenLibrary
                xref    _OriginalOpenLibrary

_PATCH_NewOpenLibrary           ; d0=LibVersion, a1=LibName, a6=SysBase
                PATCHID
                PUSH    PATCHREGS

                move.l  a1,d6           ; d6=library name
                move.l  d0,d7           ; d7=version
.CallReal       move.l  _OriginalOpenLibrary,a3
                jsr     (a3)
                move.l  d0,d5           ; d5=Base

                move.l  d6,d0           ; No library name?
                beq.b   .Exit

                NEWPMSG #PMSGID_OPENLIBRARY,.Exit
                move.l  d7,pmsg_LibVer(a2)
                move.l  d5,pmsg_LibBase(a2)
                move.l  d6,a0
                bsr     _PATCH_StrToVec
                move.l  d0,pmsg_LibName(a2)
                beq.b   .FailFreePM
                bsr     _PATCH_DispatchPatchMsg
                bra.b   .Exit
.FailFreePM     move.l  a2,a0
                bsr     _PATCH_DeletePatchMsg

.Exit           move.l  d5,d0
                PULL    PATCHREGS
                rts

;***************************************************************************;
; Patch for exec.library/CloseLibrary() ;

                xdef    _PATCH_NewCloseLibrary
                xref    _OriginalCloseLibrary

_PATCH_NewCloseLibrary                  ; a1=LibBase, a6=SysBase
                PATCHID
                PUSH    PATCHREGS_ALL

                move.l  a1,d2           ; d2=LibBase
                beq.b   .Exit
                move.l  LN_NAME(a1),a0
                bsr     _PATCH_StrToVec
                move.l  d0,d3           ; d3=LibNameVec

                move.l  _OriginalCloseLibrary,a3
                jsr     (a3)
                tst.l   d3
                beq.b   .Exit

                NEWPMSG #PMSGID_CLOSELIBRARY,.Exit
                move.l  d2,pmsg_LibBase(a2)
                move.l  d3,pmsg_LibName(a2)
                bsr     _PATCH_DispatchPatchMsg

.Exit           PULL    PATCHREGS_ALL
                rts

;***************************************************************************;
; Patch for exec.library/OpenDevice() ;

                xdef    _PATCH_NewOpenDevice
                xref    _OriginalOpenDevice

_PATCH_NewOpenDevice ; a0=DevName, d0=UnitNum, a1=IOReq, d1=Flags, a6=SysBase
                PATCHID
                PUSH    PATCHREGS

                move.l  _OriginalOpenDevice,a3
                PUSH    a0-a1/d0-d1
                jsr     (a3)
                PULL    a0-a1/d1-d2
                move.l  d0,d3
                bne.b   .Exit           ; Note: 0 for success

                move.l  a0,d4
                beq.b   .Exit

                NEWPMSG #PMSGID_OPENDEVICE,.Exit
                bsr     _PATCH_StrToVec
                move.l  d0,pmsg_DevName(a2)
                beq.b   .FailFreePM             
                move.l  a1,pmsg_DevIOReq(a2)
                move.l  d1,pmsg_DevUnitNum(a2)
                move.l  d2,pmsg_DevFlags(a2)
                bsr     _PATCH_DispatchPatchMsg
                bra.b   .Exit
.FailFreePM     move.l  a2,a0
                bsr     _PATCH_DeletePatchMsg

.Exit           move.l  d3,d0
                PULL    PATCHREGS
                rts

;***************************************************************************;
; Patch for exec.library/CloseDevice() ;

                xdef    _PATCH_NewCloseDevice
                xref    _OriginalCloseDevice

_PATCH_NewCloseDevice           ; a1=IOReq, a6=SysBase
                PATCHID
                PUSH    PATCHREGS_ALL

                move.l  a1,a4
                move.l  _OriginalCloseDevice,a3
                jsr     (a3)
                move.l  a4,d0
                beq.b   .Exit

                NEWPMSG #PMSGID_CLOSEDEVICE,.Exit
                move.l  a4,pmsg_DevIOReq(a2)
                bsr     _PATCH_DispatchPatchMsg

.Exit           PULL    PATCHREGS_ALL
                rts

;***************************************************************************;
; Patch for graphics.library/OpenFont() + diskfont.library/OpenDiskFont() ;

                xdef    _PATCH_NewOpenFont
                xref    _OriginalOpenFont
                xref    _OriginalOpenDiskFont
                xref    _SysBase

                REM

                xdef    _PATCH_NewOpenDiskFont

_PATCH_NewOpenDiskFont                  ; a0=TextAttr
                PATCHID
                PUSH    PATCHREGS
                moveq   #PMSGID_OPENDISKFONT,d4
                move.l  _OriginalOpenDiskFont,a3
                bra.b   _PATCH_OpenFontEntry

                EREM

_PATCH_NewOpenFont                      ; a0=TextAttr
                PATCHID
                PUSH    PATCHREGS
                moveq   #PMSGID_OPENFONT,d4
                move.l  _OriginalOpenFont,a3

_PATCH_OpenFontEntry
                move.l  a0,a4
                jsr     (a3)
                move.l  d0,d3
                move.l  a4,d0
                beq.b   .Exit

                NEWPMSG d4,.Exit
                move.l  a4,pmsg_FontTextAttr(a2)
                move.l  d3,pmsg_FontTextFont(a2)        ; Note: May be NULL
                move.w  ta_YSize(a4),pmsg_FontYSize(a2)
                move.b  ta_Style(a4),pmsg_FontStyle(a2)
                move.b  ta_Flags(a4),pmsg_FontFlags(a2)
                move.l  ta_Name(a4),a0
                move.l  a0,d0
                bne.b   .FontNameOK
                lea.l   STR_UnnamedFont(pc),a0
.FontNameOK     bsr     _PATCH_StrToVec
                move.l  d0,pmsg_FontName(a2)
                beq.b   .FailFreePM
                bsr     _PATCH_DispatchPatchMsg
                bra.b   .Exit
.FailFreePM     move.l  a2,a0
                bsr     _PATCH_DeletePatchMsg

.Exit           move.l  d3,d0
                PULL    PATCHREGS
                rts

;***************************************************************************;
; Patch for graphics.library/CloseFont() ;

                xdef    _PATCH_NewCloseFont
                xref    _OriginalCloseFont

_PATCH_NewCloseFont             ; a1=TextFont
                PATCHID
                PUSH    PATCHREGS_ALL

                move.l  a1,a4
                move.l  _OriginalCloseFont,a3
                jsr     (a3)
                move.l  a4,d0
                beq.b   .Exit

                NEWPMSG #PMSGID_CLOSEFONT,.Exit
                move.l  a4,pmsg_FontTextFont(a2)
                bsr     _PATCH_DispatchPatchMsg

.Exit           PULL    PATCHREGS_ALL
                rts

;***************************************************************************;
; Patch for dos.library/Open() ;

                xdef    _PATCH_NewOpen
                xref    _OriginalOpen

_PATCH_NewOpen
                PATCHID                 ; d1=Name, d2=AccessMode
                PUSH    PATCHREGS

                move.l  d1,d6
                move.l  d2,d7

                move.l  _OriginalOpen,a3
                jsr     (a3)
                move.l  d0,d5           ; d5=filehandle

                move.l  d6,d0           ; No file name?
                beq.b   .Exit

                NEWPMSG #PMSGID_OPEN,.Exit
                move.l  d7,pmsg_FHMode(a2)
                move.l  d5,pmsg_FH(a2)
                move.l  d6,a0
                bsr     _PATCH_StrToVec
                move.l  d0,pmsg_FHName(a2)
                beq.b   .FailFreePM
                bsr     _PATCH_StoreCDName
                bsr     _PATCH_DispatchPatchMsg
                bra.b   .Exit
.FailFreePM     move.l  a2,a0
                bsr     _PATCH_DeletePatchMsg

.Exit           move.l  d5,d0
                PULL    PATCHREGS
                rts

;***************************************************************************;
; Patch for dos.library/Close() ;

                xdef    _PATCH_NewClose
                xref    _OriginalClose

_PATCH_NewClose PATCHID                 ; d1=FileHandle
                PUSH    PATCHREGS_ALL

                move.l  d1,d2
                move.l  _OriginalClose,a3
                jsr     (a3)
                tst.l   d2
                beq.b   .Exit

                NEWPMSG #PMSGID_CLOSE,.Exit
                move.l  d2,pmsg_FH(a2)
                bsr     _PATCH_DispatchPatchMsg

.Exit           PULL    PATCHREGS_ALL
                rts


;***************************************************************************;
; Patch for dos.library/Lock() ;

                xdef    _PATCH_NewLock
                xref    _OriginalLock

_PATCH_NewLock  PATCHID
                PUSH    d2-d7/a0-a6     ; d1=Name, d2=AccessMode

                move.l  d1,d6
                move.l  d2,d7

                move.l  _OriginalLock,a3
                jsr     (a3)
                move.l  d1,-(sp)
                move.l  d0,d5           ; d5=Lock

                move.l  d6,d0           ; No file name?
                beq.b   .Exit

                NEWPMSG #PMSGID_LOCK,.Exit
                move.l  d7,pmsg_LockMode(a2)
                move.l  d5,pmsg_Lock(a2)
                move.l  d6,a0
                bsr     _PATCH_StrToVec
                move.l  d0,pmsg_LockName(a2)
                beq.b   .FailFreePM
                bsr     _PATCH_StoreCDName
                bsr     _PATCH_DispatchPatchMsg
                bra.b   .Exit
.FailFreePM     move.l  a2,a0
                bsr     _PATCH_DeletePatchMsg

.Exit           move.l  (sp)+,d1        ; Just in case ;)
                move.l  d5,d0
                PULL    d2-d7/a0-a6
                rts

;***************************************************************************;
; Patch for dos.library/UnLock() ;

                xdef    _PATCH_NewUnLock
                xref    _OriginalUnLock

_PATCH_NewUnLock
                PATCHID                 ; d1=Lock
                PUSH    PATCHREGS_ALL

                move.l  d1,d2
                move.l  _OriginalUnLock,a3
                jsr     (a3)

                NEWPMSG #PMSGID_UNLOCK,.Exit
                move.l  d2,pmsg_Lock(a2)
                bsr     _PATCH_DispatchPatchMsg

.Exit           PULL    PATCHREGS_ALL
                rts

;***************************************************************************;
; Patch for dos.library/OpenFromLock() ;

                xdef    _PATCH_NewOpenFromLock
                xref    _OriginalOpenFromLock

        ; [Note: if original call succeeds, then the lock is no more]

_PATCH_NewOpenFromLock
                PATCHID         ; d1=lock 
                PUSH    PATCHREGS

                bsr     _PATCH_LockNameToVec
                move.l  d0,d2

                move.l  d1,d3
                move.l  _OriginalOpenFromLock,a3
                jsr     (a3)
                move.l  d0,d5                   ; d5=FileHandle

                tst.l   d2              ; ...LockNameToVec() failed?
                beq.b   .Exit

                NEWPMSG #PMSGID_OPENFROMLOCK,.Exit
                move.l  d3,pmsg_Lock(a2)
                move.l  d5,pmsg_FH(a2)
                move.l  d2,pmsg_FHName(a2)

                bsr     _PATCH_DispatchPatchMsg

.Exit           move.l  d5,d0
                PULL    PATCHREGS
                rts

;***************************************************************************;
; PATCH_CreatePatchMsg() ; Allocate and initialize a patch message. ;
;
; Will also setup some defaults too and collect information on the
; calling task.
;
; void PATCH_CreatePatchMsg();

                xref    _SysTrackerProcess
                xref    _ARTLProcess

_PATCH_CreatePatchMsg
                PUSH    d1-a6

                move.l  _SysBase,a6

                suba.l  a1,a1
                CALLOS  FindTask
                tst.l   d0
                beq     .Exit                   ; Just in case ;)
                move.l  d0,a4                   ; a4=ThisTask

                moveq   #0,d0                   ; Don't send msgs on the 
                move.l  _SysTrackerProcess,d1   ; context of our own task.
                cmp.l   a4,d1
                beq.b   .Exit
                move.l  _ARTLProcess,d1         ; Nor the ARTLProcess'
                cmp.l   a4,d1
                beq.b   .Exit

                move.l  #pmsg_SIZEOF,d0
                bsr     _PATCH_AllocVec
                beq.b   .Exit
                move.l  d0,a2

                move.l  a4,pmsg_TaskPtr(a2)     ; Setup the basics
                move.w  #pmsg_SIZEOF,MN_LENGTH(a2)
                move.b  #NT_MESSAGE,LN_TYPE(a2)

                moveq   #0,d1
                move.b  LN_TYPE(a4),d1
                move.l  d1,pmsg_TaskType(a2)
                move.l  LN_NAME(a4),a0
                bsr     _PATCH_StrToVec
                move.l  d0,pmsg_TaskName(a2)
                beq.b   .Fail

                moveq   #LT_NA,d2               ; Let's assume we're just an
                move.l  d2,pmsg_LaunchType(a2)  ;  ordinary exec task.

                cmp.b   #NT_PROCESS,d1          ; Must be a process to
                bne.b   .SetResAndExit          ;  proceed with the next part.
                moveq   #LT_WB,d2               ; OK, so we're not a task,
                move.l  d2,pmsg_LaunchType(a2)  ;  but we're a process, so
                                                ;  lets assume we're from WB.
                move.l  pr_CLI(a4),d0
                beq.b   .SetResAndExit
                moveq   #LT_CLI,d2              ; OK, at this point, we know
                move.l  d2,pmsg_LaunchType(a2)  ;  we're from CLI, not WB.

                lsl.l   #2,d0
                move.l  d0,a0
                move.l  cli_Module(a0),pmsg_SegList(a2)
                move.l  cli_CommandName(a0),d0  ; Get the command name
                beq.b   .SetResAndExit
                bsr     _PATCH_BSTRToVec
                move.l  d0,pmsg_CmdName(a2)     ; It's OK if this fails.

.SetResAndExit  move.l  a2,d0
                bra.b   .Exit

.Fail           move.l  a2,a0
                bsr.b   _PATCH_DeletePatchMsg
                moveq   #0,d0

.Exit           PULL    d1-a6
                tst.l   d0
                rts

;***************************************************************************;
; PATCH_StoreCDName() ; Store the current dir name in a PMsg;
;
; void PATCH_StoreCDName( register __a2 struct PatchMsg *PMsg );

                xdef    _PATCH_StoreCDName

_PATCH_StoreCDName:
                PUSH    d1-d3/d7/a0-a1/a6

                move.l  _DOSBase,a6

                CALLOS  IoErr   ; Note: We *MUST* keep the existing IoErr
                move.l  d0,d7   ;       code intact!

                move.l  #256,d2
                move.l  d2,d0
                bsr     _PATCH_AllocVec
                move.l  d0,d3
                beq.b   .Exit
                move.l  d0,d1

                CALLOS  GetCurrentDirName
                tst.l   d0
                bne.b   .Exit   ; OK

                move.l  d3,a1
                bsr     _PATCH_FreeVec
                moveq   #0,d3

.Exit           move.l  d7,d1
                CALLOS  SetIoErr

                move.l  d3,pmsg_CurDirName(a2)
                move.l  d3,d0
                PULL    d1-d3/d7/a0-a1/a6
                tst.l   d0
                rts

;***************************************************************************;
; PATCH_DeletePatchMsg() ; Free a patch message ;
;
; void PATCH_DeletePatchMsg( register __a0 struct PatchMsg *PMsg );

                xdef    _PATCH_DeletePatchMsg
                xdef    @PATCH_DeletePatchMsg   ; DICE needs this

@PATCH_DeletePatchMsg
_PATCH_DeletePatchMsg
                PUSH    a0-a2/d0-d1

                move.l  a0,d0
                beq.b   .Exit

                moveq   #-1,d1
                move.l  d1,-(sp)
                move.l  a0,-(sp)

                move.l  pmsg_CurDirName(a0),-(sp)
                move.l  pmsg_LockName(a0),-(sp)
                move.l  pmsg_FHName(a0),-(sp)
                move.l  pmsg_TaskName(a0),-(sp)
                move.l  pmsg_LibName(a0),-(sp)
                move.l  pmsg_CmdName(a0),-(sp)
                move.l  pmsg_DevName(a0),-(sp)
                move.l  pmsg_FontName(a0),-(sp)
                lea.l   _PATCH_FreeVec(pc),a2

.Lp             move.l  (sp)+,d0
                beq.b   .Lp
                cmp.l   d1,d0
                beq.b   .Exit
                move.l  d0,a1
                jsr     (a2)
                bra.b   .Lp

.Exit           PULL    a0-a2/d0-d1
                rts

;***************************************************************************;
; _PATCH_DispatchPatchMsg() ; Dispatch a Patch message ;
;
; void PATCH_DispatchPatchMsg( register __a2 struct PatchMsg *PMsg );

                xdef    _PATCH_DispatchPatchMsg
                xref    _PatchPort

_PATCH_DispatchPatchMsg
                PUSH    d0-d1/a0-a1/a6

                move.l  _SysBase,a6

                move.l  _PatchPort,d0
                beq.b   .Exit
                move.l  d0,a0           ; Dispatch the information
                move.l  a2,a1
                CALLOS  PutMsg

.Exit           PULL    d0-d1/a0-a1/a6
                rts

;***************************************************************************;
; PATCH_StrToVec() ; Copy a string to a vector ;
;
; UBYTE *PATCH_StrToVec( register __a0 UBYTE *Str );

                xdef    _PATCH_StrToVec

_PATCH_StrToVec PUSH    a0-a2/d1

                move.l  a0,d0
                beq.b   .Fail

                move.l  a0,a2
                moveq   #-1,d0
.StrLenLp       tst.b   (a0)+
                dbeq    d0,.StrLenLp
                not.l   d0
                addq.l  #1,d0
                bsr     _PATCH_AllocVec
                beq.b   .Fail

                move.l  d0,a0
.CopyStrLp      move.b  (a2)+,(a0)+
                bne.b   .CopyStrLp

.Fail           PULL    a0-a2/d1
                tst.l   d0
                rts

;***************************************************************************;
; PATCH_StrCatVec ; Join two string and save in a vector ;
;
; UBYTE *PATCH_StrToVec( register __a0 UBYTE *Str1,
;                        register __a1 UBYTE *Str2 );

                xdef    _PATCH_StrCatVec

_PATCH_StrCatVec
                PUSH    d1/a0-a3

                move.l  a0,a2
                move.l  a1,a3
                moveq   #-1,d0
.StrLenLp1      tst.b   (a0)+
                dbeq    d0,.StrLenLp1
                not.l   d0
                moveq   #-1,d1
.StrLenLp2      tst.b   (a1)+
                dbeq    d1,.StrLenLp2
                not.l   d1
                add.l   d1,d0
                addq.l  #1,d0           ; Room for NULL termination
                bsr     _PATCH_AllocVec
                beq.b   .Exit

                move.l  d0,a0
.CopyLp1        move.b  (a2)+,(a0)+
                bne.b   .CopyLp1
                subq.l  #1,a0
.CopyLp2        move.b  (a3)+,(a0)+
                bne.b   .CopyLp2

.Exit           PULL    d1/a0-a3
                tst.l   d0
                rts

;***************************************************************************;
; PATCH_BSTRToVec() ; Copy a BSTR to a vector ;
;
; UBYTE *PATCH_BSTRToVec( register __d0 BSTR Str );

                xdef    _PATCH_BSTRToVec

_PATCH_BSTRToVec
                PUSH    a0-a2/d1-d2

                tst.l   d0
                beq.b   .Fail

                lsl.l   #2,d0
                move.l  d0,a2
                moveq   #0,d2
                move.b  (a2)+,d2
                moveq   #4,d0           ; NULL + safety
                add.l   d2,d0
                bsr     _PATCH_AllocVec
                beq.b   .Fail

                move.l  d0,a0
                bra.b   .IntoCopyLp
.CopyLp         move.b  (a2)+,(a0)+
.IntoCopyLp     dbf.w   d2,.CopyLp
                clr.b   (a0)

.Fail           PULL    a0-a2/d1-d2
                tst.l   d0
                rts

;***************************************************************************;
; PATCH_AllocVec() ; Thread-safe pool allocation ;
;
; APTR PATCH_AllocVec( register __d0 ULONG ByteSize );

                xdef    _PATCH_AllocVec
                xref    _PatchPool
                xref    _PatchPoolKey

_PATCH_AllocVec PUSH    a0-a3/a6/d1-d3

                move.l  d0,d2           ; d2=ByteSize
                beq.b   .Exit
                move.l  _PatchPool,d0
                beq.b   .Exit
                move.l  d0,a2           ; a2=PatchPool

                move.l  _SysBase,a6

                lea.l   _PatchPoolKey,a0
                move.l  a0,a3           ; a3=PatchPoolKey
                CALLOS  ObtainSemaphore

                addq.l  #4,d2
                move.l  a2,a0
                move.l  d2,d0
                CALLOS  AllocPooled
                move.l  d0,d3
                beq.b   .NoMem

                move.l  d0,a0
                move.l  d2,(a0)+
                move.l  a0,d3

.NoMem          move.l  a3,a0
                CALLOS  ReleaseSemaphore

                move.l  d3,d0
.Exit           PULL    a0-a3/a6/d1-d3
                tst.l   d0
                rts

;***************************************************************************;
; PATCH_FreeVec() ; Free the memory obtained by PATCH_AllocVec() ;
;
; void PATCH_FreeVec( register __a1 APTR Vec );

                xdef    _PATCH_FreeVec

_PATCH_FreeVec  PUSH    a0-a3/a6/d0-d2

                move.l  a1,d2           ; d2=Vec
                beq.b   .Exit

                move.l  _PatchPool,d0
                beq.b   .Exit
                move.l  d0,a2           ; a2=PatchPool

                move.l  _SysBase,a6

                lea.l   _PatchPoolKey,a0
                move.l  a0,a3           ; a3=PatchPoolKey
                CALLOS  ObtainSemaphore

                move.l  a2,a0
                move.l  d2,a1
                move.l  -(a1),d0
                CALLOS  FreePooled

                move.l  a3,a0
                CALLOS  ReleaseSemaphore

.Exit           PULL    a0-a3/a6/d0-d2
                rts

;***************************************************************************;
; _PATCH_LockNameToVec() ; Get the path of a lock in a vector ;
;
; void PATCH_LockNameToVec( register __d1 BPTR InLock );

                xdef    _PATCH_LockNameToVec

                xref    _DOSBase

_PATCH_LockNameToVec
                PUSH    d1-d3/d7/a0-a1/a6

                move.l  d1,d2

                move.l  _DOSBase,a6
                CALLOS  IoErr   ; Note: We *MUST* keep the existing IoErr
                move.l  d0,d7   ;       code intact!

                move.l  d2,d1
                move.l  #256,d3         ; d3=Length
                move.l  d3,d0
                bsr     _PATCH_AllocVec
                move.l  d0,d2           ; d2=Buf
                beq.b   .Exit

                CALLOS  NameFromLock    ; d1=Lock, d2=Buf, d3=BufLen
                tst.l   d0
                bne.b   .Exit

                move.l  d2,a1
                lea.l   STR_DefaultName(pc),a0
.StrCpyLp       move.b  (a0)+,(a1)+
                bne.b   .StrCpyLp

.Exit           move.l  d7,d1
                CALLOS  SetIoErr

                move.l  d2,d0
                PULL    d1-d3/d7/a0-a1/a6
                tst.l   d0
                rts

;***************************************************************************;

STR_UnnamedFont dc.b    "(unnamed font)",0
STR_DefaultName dc.b    "(unable to get name)",0
STR_DOSName     dc.b    "dos.library",0

                cnop    0,4

;***************************************************************************;

                END


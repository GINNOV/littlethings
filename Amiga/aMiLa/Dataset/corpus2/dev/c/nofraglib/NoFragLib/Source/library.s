        opt     l+,o+,ow-,inconce

*-- AutoRev header do NOT edit!
*
*   Program         :   library.s
*   Copyright       :   © Copyright 1991-92 Jaba Development
*   Author          :   Jan van den Baard
*   Creation Date   :   06-Apr-91
*   Current version :   2.2
*   Translator      :   Devpac version 3.01
*
*   REVISION HISTORY
*
*   Date          Version         Comment
*   ---------     -------         ------------------------------------------
*   12-Apr-92     2.2             Hopefully enforcer and mungwall free.
*   19-May-91     2.1             Added 'Vec' routines.
*   06-Apr-91     1.1             Initial version!
*
*-- REV_END --*

        incdir      'sys:Asm20/'
        include     'exec/types.i'
        include     'exec/initializers.i'
        include     'exec/alerts.i'
        include     'exec/io.i'
        include     'exec/libraries.i'
        include     'exec/resident.i'
        include     'exec/strings.i'
        include     'exec/exec_lib.i'
        include     'dos/dos.i'
        include     'dos/dos_lib.i'
        include     'mymacros.i'

        STRUCTURE   NoFragBase,LIB_SIZE
        LABEL       nfb_SIZEOF

VERSION             EQU     2
REVISION            EQU     2

_SysBase            EQU     $0004

        xref        GetMemoryChain
        xref        AllocItem
        xref        FreeItem
        xref        FreeMemoryChain

        xref        AllocVecItem
        xref        FreeVecItem

        SECTION     "LIB_SKELL",CODE

        lea         dosname(pc),a1
        cldat       d0
        move.l      (_SysBase).w,a6
        libcall     OpenLibrary
        move.l      d0,a6
        tst.l       d0
        beq.s       nolib
        libcall     Output
        move.l      d0,d1
        beq.s       noout
        move.l      #idString,d2
        move.l      idSize,d3
        libcall     Write
noout:  move.l      a6,a1
        move.l      (_SysBase).w,a6
        libcall     CloseLibrary
nolib:  moveq       #RETURN_FAIL,d0
        rts

ROMTag:
        dc.w        RTC_MATCHWORD
        dc.l        ROMTag
        dc.l        EndCode
        dc.b        RTF_AUTOINIT
        dc.b        VERSION
        dc.b        NT_LIBRARY
        dc.b        0
        dc.l        libraryName
        dc.l        idString
        dc.l        Init
EndCode:
        dc.w        0

libraryName:
        dc.b        'nofrag.library',0
        even
idString:
        dc.b        CR,LF,' NOFRAG_LIB 2.2 (12-Apr-1992)'
        dc.b        ' © Copyright 1991-92 Jaba Development.',CR,LF
        dc.b        ' Written with the Devpac Assembler'
        dc.b        ' version 3.01 by Jan van den Baard.',CR,LF,CR,LF,0
idEnd:  even
idSize: dc.l        (idEnd-idString-1)
dosname:
        dc.b        'dos.library',0
        even

Init:
        dc.l        nfb_SIZEOF
        dc.l        funcTable
        dc.l        dataTable
        dc.l        InitLib

funcTable:
        dc.l        OpenLib
        dc.l        CloseLib
        dc.l        ExpungeLib
        dc.l        ExtFuncLib

        dc.l        GetMemoryChain
        dc.l        AllocItem
        dc.l        FreeItem
        dc.l        FreeMemoryChain

        dc.l        AllocVecItem
        dc.l        FreeVecItem

        dc.l        -1

dataTable:
        INITBYTE    LH_TYPE,NT_LIBRARY
        INITLONG    LN_NAME,libraryName
        INITBYTE    LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
        INITWORD    LIB_VERSION,VERSION
        INITWORD    LIB_REVISION,REVISION
        INITLONG    LIB_IDSTRING,idString
        dc.l        0

InitLib:
        move.l      a0,_SegList
Done:   rts

OpenLib:
        inc.w       LIB_OPENCNT(a6)
        bclr        #LIBB_DELEXP,LIB_FLAGS(a6)
        move.l      a6,d0
        rts

CloseLib:
        cldat       d0
        dec.w       LIB_OPENCNT(a6)
        bne.s       ret
        btst        #LIBB_DELEXP,LIB_FLAGS(a6)
        beq.s       ret
        bsr.s       ExpungeLib
ret:    rts

ExpungeLib:
        movem.l     d2/a5/a6,-(sp)
        tst.w       LIB_OPENCNT(a6)
        beq.s       NDLex
        bset        #LIBB_DELEXP,LIB_FLAGS(a6)
        cldat       d0
        bra.s       DLex
NDLex:  move.l      a6,a5
        move.l      (_SysBase).w,a6
        move.l      a5,a1
        libcall     Remove
        move.l      _SegList,d2
        movea.l     a5,a1
        cldat       d0
        move.w      LIB_NEGSIZE(a5),d0
        suba.l      d0,a1
        add.w       LIB_POSSIZE(a5),d0
        libcall     FreeMem
        move.l      d2,d0
DLex:   movem.l     (sp)+,d2/a5/a6
        rts

ExtFuncLib:
        cldat       d0
        rts

_SegList:
        dc.l        0

        end

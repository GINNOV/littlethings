        ; Devpac syntax + NDK includes
        INCLUDE "exec/exec.i"
        INCLUDE "dos/dos.i"

        XREF    _DOSBase

        SECTION code,CODE

_start_asm_sample:
        move.l  4.w,a6
        lea     dosname(pc),a1
        jsr     _LVOOldOpenLibrary(a6)
        move.l  d0,_DOSBase
        beq.s   .quit

        move.l  _DOSBase,a6
        jsr     _LVOOutput(a6)        ; d0 = BPTR
        move.l  d0,d1                 ; D1 = file handle
        lea     msg(pc),a0
        move.l  a0,d2                 ; D2 = buffer
        move.l  #msg_end-msg,d3       ; D3 = length
        jsr     _LVOWrite(a6)

.quit:
        rts

        ; keep data in CODE to avoid cross-section PC-rel relocations
dosname: dc.b 'dos.library',0
        even
msg:    dc.b 'Hello from asm sample!',10
msg_end:
        even
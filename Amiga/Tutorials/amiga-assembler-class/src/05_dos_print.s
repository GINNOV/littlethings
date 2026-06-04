        SECTION code,CODE

_LVOOldOpenLibrary equ -408
_LVOWrite          equ -48
_LVOOutput         equ -60

        ; Lesson 05: print through dos.library.
        move.l  4.w,a6
        lea     dosname(pc),a1
        jsr     _LVOOldOpenLibrary(a6)
        beq.s   .quit

        move.l  d0,a6                  ; a6 = DOSBase
        jsr     _LVOOutput(a6)        ; d0 = output handle

        move.l  d0,d1                 ; D1 = file handle
        lea     msg(pc),a0
        move.l  a0,d2                 ; D2 = buffer address
        move.l  #msg_end-msg,d3       ; D3 = byte length
        jsr     _LVOWrite(a6)

.quit:
        rts

dosname:
        dc.b    'dos.library',0
        even

msg:
        dc.b    'Hello from your first Amiga assembly class!',10
msg_end:
        even

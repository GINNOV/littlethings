INCLUDE "exec/exec.i"
    INCLUDE "dos/dos.i"

    SECTION code,code

start:
    move.l  4.w,a6
    lea     dosName(pc),a1
    moveq   #0,d0
    jsr     _LVOOpenLibrary(a6)
    move.l  d0,a6

    tst.l   a6
    beq.s   .fail

    move.l  #msg,d1
    moveq   #msglen,d2
    moveq   #0,d3
    jsr     _LVOWrite(a6)

.fail:
    moveq   #0,d0
    rts

dosName:
    dc.b    "dos.library",0
msg:
    dc.b    "Hello from Amiga!",10,0
msglen = *-msg
    even
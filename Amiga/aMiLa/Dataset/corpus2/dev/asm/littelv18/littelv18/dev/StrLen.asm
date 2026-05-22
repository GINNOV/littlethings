; StrLen 4 LITTEL

        MACHINE 68020

        xdef    StrLen

        ; uses d0, d4, a6
StrLen
        move.l  4(a7), a6
        move.l  a6,d4
.loop   tst.b   (a6)+
        bne.s   .loop
        subq.l  #1,a6
        move.l  a6,d0
        sub.l   d4,d0
        rtd     #4

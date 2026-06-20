 ;LITTEL StrCmp

        MACHINE 68020

        xdef    StrCmp

        ; uses a3,a6,d0

StrCmp
        move.l 4(a7), a6
        move.l 8(a7), a3
.loop   cmpm.b  (a6)+,(a3)+
        bne.s   .nosame
        cmp.b   #0, (a3)
        beq.s   .same
        bra .loop
.same   moveq   #-1,d0
        bra.s   .finish
.nosame moveq   #0,d0
.finish rtd #8

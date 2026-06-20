; LITTEL support functions v18 © Leif Salomonson 2000

;*********************************************

StrLenMacro macro ; str = a6 -> len = d5
        code
StrLen\@
        move.l  a6, d4
.loop\@
        tst.b   (a6)+
        bne.s   .loop\@
        subq.l  #1,a6
        move.l  a6,d5
        sub.l   d4,d5
        endm

;*********************************************

StrCmpMacro macro ; str1 = a6, str2 = d5 -> result(true/false) = d5
StrCmp\@
        code
        move.l a0, -(a7)
        move.l d5, a0
.loop\@
        cmpm.b  (a6)+,(a0)+
        bne.s   .nosame\@
        cmp.b   #0, (a0)
        beq.s   .same\@
        bra .loop
.same\@
        moveq   #-1,d5
        bra.s   .finish\@
.nosame\@
        moveq   #0,d5
.finish\@
        move.l (a7)+, a0
        endm

;**********************************************


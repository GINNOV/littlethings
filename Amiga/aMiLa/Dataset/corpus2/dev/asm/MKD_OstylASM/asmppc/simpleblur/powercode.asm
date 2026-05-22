;Simple-blur
;Ostyl of Mankind
;r2 = *_LinkerDB
;r3 = *_PowerPCBase
;r4 = *temp buff
;r5 = *struct ChunkyScreen

        MACHINE     68040
        LINKABLE

        SECTION     Code_F

        INCLUDE     POWERPC/PPCMACROS.i
        INCLUDE     POWERPC/GRAPHICSPPC.i

        XDEF        PPC_SimpleBlur

local   SETR        stack

        ;---- Code options

        ;---- Equates

        ;----

PPC_SimpleBlur:
        Lwz         r6,cks_ChunkyMap(r5)
        Lhz         r7,cks_ChunkyHeight(r5)
        Lhz         r8,cks_ChunkyWidth(r5)
        Subi        r7,r7,2
        Mullw       r7,r7,r8
        Mtctr       r7

        Push        r4

        La          r4,(320*2)-2(r4)
        La          r7,320*2(r6)
        La          r8,320*2(r7)
        Li          r20,%111110000011111
        Li          r21,%000001111100000

BluLoop Lhz         r10,0(r6)
        Lhz         r11,-2(r7)
        Lhz         r12,2(r7)
        Lhz         r13,0(r8)
        Lhz         r14,0(r7)      
        And         r15,r10,r20
        And         r16,r11,r20
        And         r17,r12,r20
        And         r18,r13,r20
        And         r19,r14,r20
        Add         r15,r15,r16
        Add         r15,r15,r17
        Add         r15,r15,r18
        Srwi        r15,r15,2
        Add         r15,r15,r19
        Srwi        r15,r15,1
        And         r10,r10,r21
        And         r11,r11,r21
        And         r12,r12,r21
        And         r13,r13,r21
        And         r14,r14,r21
        Add         r10,r10,r11
        Add         r10,r10,r12
        Add         r10,r10,r13
        Srwi        r10,r10,2
        Add         r10,r10,r14
        ;Srwi        r10,r10,1
        Rlwimi      r15,r10,32-1,22,26
        Sthu        r15,2(r4)
        La          r6,2(r6)
        La          r7,2(r7)
        La          r8,2(r8)
        Bdnz+       BluLoop

        ;----

        Lwz         r6,cks_ChunkyMap(r5)
        Lhz         r7,cks_ChunkyHeight(r5)
        Lhz         r8,cks_ChunkyWidth(r5)
        Subi        r7,r7,2
        Mullw       r7,r7,r8
        Mtctr       r7

        Pop         r4
        Mr          r31,r4
        Mr          r4,r6
        Mr          r6,r31

        La          r4,(320*2)-2(r4)
        La          r7,320*2(r6)
        La          r8,320*2(r7)
        Li          r20,%111110000011111
        Li          r21,%000001111100000

BluLoop1 Lhz         r10,0(r6)
        Lhz         r11,-2(r7)
        Lhz         r12,2(r7)
        Lhz         r13,0(r8)
        Lhz         r14,0(r7)
        And         r15,r10,r20
        And         r16,r11,r20
        And         r17,r12,r20
        And         r18,r13,r20
        And         r19,r14,r20
        Add         r15,r15,r16
        Add         r15,r15,r17
        Add         r15,r15,r18
        Srwi        r15,r15,2
        Add         r15,r15,r19
        Srwi        r15,r15,1
        And         r10,r10,r21
        And         r11,r11,r21
        And         r12,r12,r21
        And         r13,r13,r21
        And         r14,r14,r21
        Add         r10,r10,r11
        Add         r10,r10,r12
        Add         r10,r10,r13
        Srwi        r10,r10,2
        Add         r10,r10,r14
        ;Srwi        r10,r10,1
        Rlwimi      r15,r10,32-1,22,26
        Sthu        r15,2(r4)
        La          r6,2(r6)
        La          r7,2(r7)
        La          r8,2(r8)
        Bdnz+       BluLoop1

        Blr

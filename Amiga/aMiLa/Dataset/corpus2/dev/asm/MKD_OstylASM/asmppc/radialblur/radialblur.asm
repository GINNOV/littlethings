;BlurRadial
;Ostyl of Mankind!
;Revdate: 28.04.02
;Registers:
;       r2  = _LinkerDB
;       r3  = _PowerPCBase
;       r4  = *rgb16source
;       r5  = *struct ckscreen
;       r6  = *tempbuffer 
;       r22 = x center
;       r23 = y center
;       r24 = depth

        INCLUDE     POWERPC/PPCMACROS.i
        INCLUDE     POWERPC/GRAPHICSPPC.i

        MACHINE     68040
        LINKABLE

        SECTION     CodePPC,Code_F

        XDEF        PPC_RadialBlur

PPC_RadialBlur:
        Lwz         r9,cks_ChunkyMap(r5)

        Mr          r31,r4
        Mr          r4,r9
        Mr          r9,r31

        Add         r22,r22,r22
        Add         r23,r23,r23
        Mr          r10,r22
        Mr          r11,r23
        Mulli       r31,r24,4
        Sub         r10,r22,r31
        Sub         r11,r23,r31
        Li          r29,4
        Liw         r19,%01111011110111100111101111011110

MegaLoop:
        Sub         r12,r22,r10
        Sub         r13,r23,r11
        Swap        r10,r10
        Swap        r11,r11
        Rlwinm      r12,r12,16-1,0,31
        Rlwinm      r13,r13,16-1,0,31
        Divwu       r14,r10,r22
        Divwu       r15,r11,r23

;--------------------------------------------------

        Lhz         r20,cks_ChunkyHeight(r5)
        La          r16,-4(r9)

YLoop:  Li          r31,320/2
        Mtctr       r31

        Rlwinm      r18,r13,16,16,31
        Mulli       r18,r18,320*2
        Add         r18,r18,r4

        Mr          r17,r12

XLoop:  Rlwinm      r7,r17,17,16,30
        Add         r17,r17,r14
        Lhzx        r7,r7,r18
        Rlwinm      r8,r17,17,16,30
        Add         r17,r17,r14
        Lhzx        r8,r8,r18
        Rlwimi      r8,r7,16,0,15
        And         r8,r8,r19
        Srwi        r8,r8,1
        Lwz         r7,4(r16)
        And         r7,r7,r19
        Srwi        r7,r7,1
        Add         r7,r7,r8
        Stwu        r7,4(r16)
        Bdnz+       XLoop

        Add         r13,r13,r15
        Subi        r20,r20,1
        Mr.         r20,r20
        Bgt+        YLoop

        ;---

        Mr          r31,r4
        Mr          r4,r9
        Mr          r9,r31

        Swap        r10,r10
        Swap        r11,r11
        Add         r10,r10,r24
        Add         r11,r11,r24
        Subi        r29,r29,1
        Mr.         r29,r29
        Bgt+        MegaLoop
        Blr

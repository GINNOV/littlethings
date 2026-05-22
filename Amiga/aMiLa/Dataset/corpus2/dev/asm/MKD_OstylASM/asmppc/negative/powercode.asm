;Negative picture
;Ostyl of Mankind
;r2 = *_LinkerDB
;r3 = *_PowerPCBase
;r4 = *struct ChunkyScreen

        MACHINE     68040
        LINKABLE

        SECTION     Code_F

        INCLUDE     POWERPC/PPCMACROS.i
        INCLUDE     POWERPC/GRAPHICSPPC.i

        XDEF        PPC_Negative

local   SETR        stack

        ;---- Code options

        ;---- Equates

        ;----

PPC_Negative:
        Lwz         r5,cks_ChunkyMap(r4)
        Lhz         r6,cks_ChunkyHeight(r4)
        Lhz         r7,cks_ChunkyWidth(r4)
        Mullw       r6,r6,r7
        Srwi        r6,r6,1
        Mtctr       r6

        Liw         r6,%1111111111111110111111111111111

NegLoop Lwz         r7,0(r5)
        Sub         r7,r6,r7
        Stw         r7,0(r5)
        La          r5,4(r5)
        Bdnz+       NegLoop
        Blr

;Rotozoom tracer
;Revdate: 3.2.03
;Ostyl Of Mankind!
;Registers: r2 = _LinkerDB
;           r3 = _PowerPCBase
;           r4 = *struct targa
;           r5 = *struct ckscreen
;           r6 = Hauteur
;           r22 = xp
;           r23 = yp
;           r24 = x_center
;           r25 = y_center

        INCLUDE POWERPC/PPCMACROS.i
        INCLUDE POWERPC/GRAPHICSPPC.i
        INCLUDE ASMPPC:ROTOZOOM/MACROS.i

        MACHINE 68040
        LINKABLE

        SECTION Code_F

        XDEF    RotoZoom1x1_PPC
        XDEF    RtZm11_16b_PPC

local   SETR        stack

;---- OPTIONS & SETUP ----

BFilter EQU     1

;-------------------------

RotoZoom1x1_PPC
        Mflr    r0
        Stwu    r0,-4(r1)

        La      r28,xy0xy1-4
        Li      r7,320
        Mtctr   r7
        Bl      Interpolate

        Mr      r0,r23
        Mr      r23,r22
        Mr      r22,r0
        Neg     r22,r22

        La      r28,xy0xy2-4
        Li      r0,240
        Mtctr   r0
        Bl      Interpolate

        La      r5,-4(r5)
        La      r7,xy0xy1-4
        La      r8,xy0xy2-4
        La      r9,256(r4)
        Mtctr   r6

Loop    Lwzu    r15,4(r8)
        Mfctr   r6              ; sauve l'ancien compteur

        Li      r0,320/4        ; nouveau
        Mtctr   r0              ; compteur

        Mr      r31,r7

Scan    Lwzu    r16,4(r31)
        Lwzu    r17,4(r31)
        Lwzu    r18,4(r31)
        Lwzu    r19,4(r31)
        Add     r16,r16,r15
        Add     r17,r17,r15
        Add     r18,r18,r15
        Add     r19,r19,r15

        WrtBfTxl r4,r9,r16
        Rlwinm  r30,r26,24,0,7
        WrtBfTxl r4,r9,r17
        Rlwimi  r30,r26,16,8,15
        WrtBfTxl r4,r9,r18
        Rlwimi  r30,r26,8,16,23
        WrtBfTxl r4,r9,r19

        Rlwimi  r30,r26,0,24,31
        Stwu    r30,4(r5)
        Bdnz+   Scan

        Mtctr   r6
        Bdnz+   Loop

        Lwz     r0,0(r1)
        Mtlr    r0
        La      r1,4(r1)
        Blr

        ;----

RtZm11_16b_PPC
        Pushlr

        Lhz     r7,cks_ChunkyHeight(r5) 
        Cmpw    r6,r7
        Ble-    HeightOk
        Mr      r6,r7

HeightOk:
        Lwz     r4,tga_Converted(r4)
        Lwz     r5,cks_ChunkyMap(r5)
        Neg     r10,r24
        Neg     r11,r25
        Slwi    r12,r26,8

        ;----

        La      r28,xy0xy1-4
        Li      r7,320
        Mtctr   r7
        Bl      Interpolate

        Mr      r0,r23
        Mr      r23,r22
        Mr      r22,r0
        Neg     r22,r22

        La      r28,xy0xy2-4
        Li      r0,240
        Mtctr   r0
        Bl      Interpolate

        ;---

        La      r5,-4(r5)
        La      r7,xy0xy1-4
        La      r8,xy0xy2-4
        Mtctr   r6
        Liw     r20,%1111111111111110111111111111111

Loop2   Lwzu    r15,4(r8)
        Mfctr   r6              ; sauve l'ancien compteur
        Li      r0,320/4        ; nouveau
        Mtctr   r0              ; compteur
        Mr      r31,r7
Scan2   Lwzu    r16,4(r31)
        Lwzu    r17,4(r31)
        Lwzu    r18,4(r31)
        Lwzu    r19,4(r31)
        Add     r16,r16,r15
        Add     r17,r17,r15
        Add     r18,r18,r15
        Add     r19,r19,r15
        Rlwimi  r16,r16,8,8,16      ; r16 = V,U | u,?
        Rlwimi  r17,r17,8,8,16
        Rlwimi  r18,r18,8,8,16
        Rlwimi  r19,r19,8,8,16
        Rlwinm  r16,r16,32-15,15,30 ; r16 = 0,0 | V,U
        Rlwinm  r17,r17,32-15,15,30
        Rlwinm  r18,r18,32-15,15,30
        Rlwinm  r19,r19,32-15,15,30
        Lhzx    r16,r16,r4
        Lhzx    r17,r17,r4
        Lhzx    r18,r18,r4
        Lhzx    r19,r19,r4
        Rlwimi  r17,r16,16,0,15
        Rlwimi  r19,r18,16,0,15
        ;Sub     r17,r20,r17
        ;Sub     r19,r20,r19
        Stwu    r17,4(r5)
        Stwu    r19,4(r5)
        Bdnz+   Scan2
        Mtctr   r6
        Bdnz+   Loop2
        Poplr
        Blr

        ;----

Interpolate
        Mullw   r24,r22,r10
        Mullw   r25,r23,r11
LoopIt  Add     r24,r24,r22
        Add     r25,r25,r23
        Srawi   r26,r24,8
        Srawi   r27,r25,8
        Rlwimi  r26,r27,16,0,15
        Add     r26,r26,r12
        Stwu    r26,4(r28)
        Bdnz+   LoopIt
        Blr

        SECTION BSS_F
xy0xy1  Ds.L    400
xy0xy2  Ds.L    400

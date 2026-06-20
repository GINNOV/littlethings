;FxInterpolation
;Revdate: 8.3.03
;Ostyl of Mankind!
;
;registers: r4 (PTR)    =   liste à interpoler*
;           r5 (PTR)    =   struct targa*
;           r6 (PTR)    =   struct ckscreen*

        INCLUDE     POWERPC/PPCMACROS.i
        INCLUDE     ASMPPC:DRAWFX/MACROS.i
        INCLUDE     POWERPC/GRAPHICSPPC.i

        MACHINE     68040
        LINKABLE

        SECTION     CodePPC,Code_F

        XDEF        DrawFxPPC

        ;---- SETUP

ChunkyWidth     EQU     320
GridWidth       EQU     40
GridHeight      EQU     25
CopyWidth       EQU     16

Transp          EQU     0
Blur            EQU     0

        ;---- EQUATES

offs    EQU     2

        ;----

DrawFxPPC:
        Lwz     r5,tga_Converted(r5)
        Lhz     r8,cks_ChunkyHeight(r6)
        Srwi    r8,r8,3
        Lwz     r6,cks_ChunkyMap(r6)
        Li      r7,1
        Li      r10,0

        IFNE    Blur
        Liw     r19,%01110011100111000111001110011100
        ENDC

yLoop   Li      r9,GridWidth

xLoop   Lwz     r23,(GridWidth+1)*4(r4)     ;b -> r23 = (ub,vb)
        Lwz     r11,0(r4)                   ;a -> r11 = (ua,va)
        Lwzu    r12,4(r4)                   ;c -> r12 = (uc,vc)
        Lwz     r22,(GridWidth+1)*4(r4)     ;d -> r22 = (ud,vd)
        Sub     r23,r23,r11                 ; (ub-vb,ua-va) -> r14 = dy1
        Sub     r22,r22,r12                 ; (ud-uc,vd-vc) -> r15 = dy2
        Slwi    r11,r11,3                   ; (ua*8,va*8)
        Slwi    r12,r12,3                   ; (uc*8,vc*8)

        ;----

        Li      r31,8
        Mtctr   r31

SquareLoop:
        Mr      r13,r11
        Mr      r14,r12
        Sub     r14,r14,r13         ; (uc-ua,vc-va) = (dux,dvx) -> r14
        Extsh   r25,r13
        Rotlwi  r31,r14,16          ; r31 = (dvx,dux)
        Srawi   r31,r31,3           ; r31 = (dvx/8,destroyed!)
        Rlwimi  r14,r31,16,16,31    ; r14 = (dux,dvx/8)
        Mr      r26,r14
        Swap    r13,r13
        Srawi   r31,r14,3           ; r31 = (dux/8,destroyed!)
        Rlwimi  r14,r31,0,0,15      ; r14 = (dux/8,dvx/8)
        Swap    r14,r14             ; r14 = (dvx/8,dux/8)
        Add     r31,r13,r14
        Mb      r13,r31
        Slwi    r13,r13,8
        Rlwimi  r13,r13,16,24,31
        Slwi    r14,r14,8
        Rlwimi  r14,r14,16,24,31
        Rlwimi  r13,r13,16,0,15
        Rlwimi  r14,r14,16,0,15
        Plot16
        Plot16
        Plot16
        Plot16
        La      r6,(ChunkyWidth-6)*offs(r6)
        Add     r11,r11,r23
        Add     r12,r12,r22
        Bdnz+   SquareLoop

        ;----

        La      r6,(-ChunkyWidth*8*offs)+(8*offs)(r6)
        Sub.    r9,r9,r7
        Bgt+    xLoop

        La      r4,4(r4)
        La      r6,ChunkyWidth*7*offs(r6)
        Sub.    r8,r8,r7
        Bgt+    yLoop

        Blr

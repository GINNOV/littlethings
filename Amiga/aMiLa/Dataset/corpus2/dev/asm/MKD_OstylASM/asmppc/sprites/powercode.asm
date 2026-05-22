;Sprite render
;Revdate: 2.3.03
;Ostyl of Mankind
;   r2 = _LinkerDB
;   r3 = _PowerPCBase
;   r4 = *struct spritelist
;   r5 = *struct ckscreen

        MACHINE     68040
        LINKABLE

        SECTION     Code_F

        INCLUDE     POWERPC/PPCMACROS.i
        INCLUDE     POWERPC/GRAPHICSPPC.i

local   SETR        stack

            ;----

            XDEF    Sprites15bPPC

Sprites15bPPC:
            Pushlr

MainLoop:   Lwz     r6,cks_ChunkyMap(r5)
            Mr.     r6,r6
            Beq-    Leave

            ;---- Check sprite visibility

            Lhz     r7,nsp_Alpha(r4)
            Tsth    r7
            Ble-    NextSpr

            ;----

            Lwz     r7,nsp_FrameList(r4)
            Lbz     r8,nsp_Frame(r4)
            Mulli   r8,r8,spf_SIZEOF
            Add     r7,r7,r8

            Lhz     r8,cks_ChunkyWidth(r5)
            Lhz     r9,cks_ChunkyHeight(r5)

            ;----

            Lwz     r10,nsp_xBeg(r4)
            Lwz     r11,nsp_yBeg(r4)
            Lwz     r12,nsp_xEnd(r4)
            Lwz     r13,nsp_yEnd(r4)

            ;----

            Sub.    r12,r12,r10             ;r12 = dx
            Ble-    NextSpr
            Sub.    r13,r13,r11             ;r13 = dy
            Ble-    NextSpr

            ;----

            Lwz     r11,spf_uBeg(r7)
            Lwz     r14,spf_uEnd(r7)
            Rlwinm  r15,r11,0,0,15
            Rlwinm  r16,r11,16,0,15
            Sub     r14,r14,r11
            Rlwinm  r11,r14,0,0,15          ;r11 = du
            Rlwinm  r14,r14,16,0,15         ;r14 = dv
            Divw    r11,r11,r12
            Divw    r14,r14,r13

            ;---- Clipping

            Lwz     r20,nsp_xBeg(r4)
            Lwz     r21,nsp_yBeg(r4)
            Lwz     r12,nsp_xEnd(r4)
            Lwz     r13,nsp_yEnd(r4)

            Mr.     r13,r13
            Ble     NextSpr
            Cmpw    r21,r9
            Bge     NextSpr
            Mr.     r12,r12
            Ble     NextSpr
            Cmpw    r20,r8
            Bge     NextSpr

ClipDroit:  Cmpw    r12,r8
            Ble     ClipGauche
            Mr      r12,r8

ClipGauche: Mr.     r20,r20
            Bge     ClipBas
            Neg     r20,r20
            Mullw   r20,r20,r11
            Add     r15,r15,r20
            Li      r20,0

ClipBas:    Cmpw    r13,r9
            Ble-    ClipHaut
            Mr      r13,r9

ClipHaut:   Mr.     r21,r21
            Bge-    ClipDone
            Neg     r21,r21
            Mullw   r21,r21,r14
            Add     r16,r16,r21
            Li      r21,0

ClipDone:   Sub     r12,r12,r20
            Sub     r13,r13,r21

            ;---- Adresse de départ du sprite

            Mullw   r21,r21,r8
            Add     r20,r20,r21
            Add     r20,r20,r20
            Add     r10,r20,r6

;-----------------------------------------------------------------
;
;           ScanLine
;
;-----------------------------------------------------------------

Scan:       Lwz     r7,spf_Map(r7)
            Lwz     r7,spm_RawMapData(r7)
            Lhz     r20,nsp_LockedRGB(r4)
            Lhz     r21,nsp_Alpha(r4)

            Cmpwi   r21,128
            Blt+    ScanMode2
ScanMode1:  Bl      FillMode1
            B       NextSpr
ScanMode2:  Bl      FillMode2

NextSpr:    Lwz     r4,LN_SUCC(r4)
            Lwz     r6,LN_SUCC(r4)
            Mr.     r6,r6
            Bne+    MainLoop
Leave:      Poplr
            Blr

            ;---- Fill

FillMode1:
VLoop1:     Mtctr   r12
            Mr      r18,r10
            Mr      r19,r15
            Rlwinm  r17,r16,24+1,15,22
HLoop1:     Rlwimi  r17,r19,16+1,23,30
            Lhzx    r28,r17,r7
            Cmpw    r28,r20
            Beq-    NextTexel1
            Sth     r28,0(r18)
NextTexel1: Add     r19,r19,r11
            La      r18,2(r18)
            Bdnz+   HLoop1
            Add     r16,r16,r14
            Add     r10,r10,r8
            Add     r10,r10,r8
            Subi    r13,r13,1
            Mr.     r13,r13
            Bne+    VLoop1
            Blr

            ;----

FillMode2:
VLoop2:     Mtctr   r12
            Mr      r18,r10
            Mr      r19,r15
            Rlwinm  r17,r16,24+1,15,22
HLoop2:     Rlwimi  r17,r19,16+1,23,30
            Lhzx    r28,r17,r7
            Cmpw    r28,r20
            Beq-    NextTexel2
            Mr      r22,r28
            Rlwinm  r22,r28,0,27,31     ;b1
            Rlwinm  r23,r28,27,27,31    ;g1
            Rlwinm  r24,r28,22,27,31    ;r1
            Lhz     r28,0(r18)
            Rlwinm  r25,r28,0,27,31     ;b2
            Rlwinm  r26,r28,27,27,31    ;g2
            Rlwinm  r27,r28,22,27,31    ;r2
            Sub     r22,r22,r25
            Sub     r23,r23,r26
            Sub     r24,r24,r27
            Mullw   r22,r22,r21
            Mullw   r23,r23,r21
            Mullw   r24,r24,r21
            Srawi   r22,r22,7
            Srawi   r23,r23,7
            Srawi   r24,r24,7
            Add     r22,r22,r25
            Add     r23,r23,r26
            Add     r24,r24,r27
            Rlwimi  r22,r23,5,22,26
            Rlwimi  r22,r24,10,17,21
            Sth     r22,0(r18)
NextTexel2: Add     r19,r19,r11
            La      r18,2(r18)
            Bdnz+   HLoop2
            Add     r16,r16,r14
            Add     r10,r10,r8
            Add     r10,r10,r8
            Subi    r13,r13,1
            Mr.     r13,r13
            Bne+    VLoop2
            Blr
